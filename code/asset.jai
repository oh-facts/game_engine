// TODO(mizu): Load all mesh data like you've been loading other data
// Then traverse nodes to make the node hierearchy?

// TODO(mizu): I think I will have an entity from gltf mesh
// This will read a file and set up an entity tree based on the gltf file name and mesh name

// Make a gltf cache
// GLTF :: struct
// {
// ..
// }

// mesh
// I have rejected the above idea btw

/*
GLTF_Scene
*/

// I am thinking I have asset links as generational handles?
// If one of them is invalid, I can load them?

// With hash calls, I would be doing the same right?
// If they aren't present, load them in?

// but what's the difference between asset_from_hash and asset_from_generational_handle?

// I am hooking up tracy so I can get to the bottom of this
// surely walking an asset tree recursively to draw stuff
// is more expensive than looping an array

// jblow's game uses one mesh per model. I use a tree of meshes where each
// link is a string key (+ computed hash).
// What I am doing must be much much worse computationally.

// Make a mesh, skin -> []aabb asset

// Ok, rjf told me this (asset megastruct) was stupid (he phrased it politely and provided reasoning).
// There is very little common between a texture and an asset
// Code editors should allow some kind of screenshot / text tooltip - like viewing. Not referring to comments.

Asset :: struct
{
	// Keys for asset hierearchies.
	// strings are helpful for serializing, etc.
	// Used by nodes
	next_key : string;
	prev_key : string;
	first_key : string;
	last_key : string;
	parent_key : string;
	
	// asset pointers are persistant forever
	// The vertex / skinning / joint / texture data are streamed in and out
	// Whats a bit annoying about this is that I will have to do a "get_asset()"
	// anyways because the asset might not be loaded
	// However, for an asset, the children ptrs will always be loaded, no?
	// Is there any reason for the children to not be loaded?
	// Well, one thing is that since I know their AABBs, I might not
	// even load an asset if its not in view, even if I am drawing
	// the whole thing
	// Now, this makes good sense.
	// But that still doesn't mean I can't keep asset ptrs around
	// Sure, I might crash if I access an asset directly
	// But why would I ever do that? And if I do it, its a bug and I should
	// stop doing it.
	// Never used const in my life, and if I accidentally modify something I shouldn't,
	// I stop accidentally modifying it.
	
	// Now, I have decided to go with hashed keys for now.
	
	next_hash : u128;
	prev_hash : u128;
	first_hash : u128;
	last_hash : u128;
	parent_hash : u128;
	
	xform : Matrix4;
	
	// hash link
	hash_next : *Asset;
	
	// this asset's key and hash
	key : string;
	hash : u128;
	
	// color map asset and hash.
	// Used by the material
	map : string;
	map_hash : u128;
	
	// Used by material and color override for meshes
	color : Vector4;
	
	// map gpu handle
	id : Handle;
	
	// Animation?
	anim : []Animation;
	length : float;
	
	// skin?
	skin : string;
	skin_hash : u128;
	
	// joints?
	joints : []Joint;
	
	// mesh key
	mesh : string;
	mesh_hash : u128;
	
	// mesh data
	primitives : *Primitive;
	num_primitives : u64;
	indices : *u32;
	num_indices : u64;
	
	vertices : *Vertex;
	num_vertices : u64;
	
	// mesh gpu buffers
	vertex_buffer : u32;
	index_buffer : u32;
	
	aabb : AABB;
}

//#run print("%\n", size_of(Asset));

Asset_Slot :: struct
{
	first : *Asset;
	last : *Asset;
}

asset_store : struct
{
	arena : *Arena;
	
	meshes : []Asset_Slot;
	materials : []Asset_Slot;
	textures : []Asset_Slot;
	skins : []Asset_Slot;
	animations : []Asset_Slot;
	nodes : []Asset_Slot;
}

// Can't decide if I want one big asset array
// Or multiple arrays.
// Atm, I think every asset except for meshes
// will be streamed in/out the same way.
// Meshes will first be bounds checked
asset_init :: ()
{
	using asset_store;
	arena = arena_init();
	materials.count = 256;
	materials.data = push_array(arena, Asset_Slot, xx materials.count);
	textures.count = 256;
	textures.data = push_array(arena, Asset_Slot, xx materials.count);
	skins.count = 256;
	skins.data = push_array(arena, Asset_Slot, xx skins.count);
	
	animations.count = 256;
	animations.data = push_array(arena, Asset_Slot, xx animations.count);
	
	meshes.count = 256;
	meshes.data = push_array(arena, Asset_Slot, xx meshes.count);
	
	nodes.count = 256;
	nodes.data = push_array(arena, Asset_Slot, xx nodes.count);
}

add_texture :: (data : string, name : string, min_filter : Tex_Param,
								mag_filter : Tex_Param,
								wrap : Tex_Param)
{
	asset := asset_from_key(*asset_store.textures, name);
	
	asset.id = image_create_from_memory(data, min_filter, mag_filter, wrap);
}

add_material :: (color : Vector4, texture : string, name : string)
{
	asset := asset_from_key(*asset_store.materials, name);
	
	asset.map = sprint("%", texture);
	asset.map_hash = hash_string(asset.map);
	asset.color = color;
}

add_skin :: (count : u32, name : string) -> *Asset
{
	asset := asset_from_key(*asset_store.skins, name);
	asset.joints.data = push_array(asset_store.arena, Joint, count);
	asset.joints.count = count;
	
	return asset;
}

add_animation :: (count : u32, name : string, skin_name : string) -> []Animation, *Asset
{
	asset := asset_from_key(*asset_store.animations, name);
	asset.anim.data = push_array(asset_store.arena, Animation, count);
	asset.anim.count = count;
	asset.skin = sprint("%", skin_name);
	asset.skin_hash = hash_string(asset.skin);
	
	return asset.anim, asset;
}

_dfs_pre_rec :: (body : Code, hash : u128)
{
	
	root_node := node_from_hash(hash);
	
	child_asset_node : *Asset;
	
	if root_node.first_key.count
	{
		child_asset_node = node_from_hash(root_node.first_hash);
	}
	
	while child_asset_node
	{
		_dfs_pre_rec(body, child_asset_node.hash);
		
		if child_asset_node.next_key.count
		{
			child_asset_node = node_from_hash(child_asset_node.next_hash);
		}
		else
		{
			break;
		}
	}
	
}

// @for_expansion
dfs_pre :: (root : *Asset, body: Code, flags: For_Flags) #expand
{
	stack     : [100]*Asset;
	depth     : [100]int;
	
	top       := 0;
	
	stack[top] = root;
	depth[top] = 0;
	top += 1;
	`it_index := 0;
	
	while top > 0
	{
		top -= 1;
		`it := stack[top];
		`it_depth := depth[top];
		
#insert body;
		it_index += 1;
		if it.last_key.count
		{
			//print("%\n", it.last_key);
			child := asset_from_hash(*asset_store.nodes, it.last_hash);
			d := it_depth + 1;
			//print("%\n", it.last_key);
			
			while child
			{
				stack[top] = child;
				depth[top] = d;
				top += 1;
				
				if child.prev_key.count
				{
					//print("rerere\n");
					child = asset_from_hash(*asset_store.nodes, child.prev_hash);
					//print("e%\n", child.key);
				}
				else
				{
					break;
				}
			}
		}
	}
}

add_mesh :: (name : string) -> *Asset
{
	asset := asset_from_key(*asset_store.meshes, name);
	return asset;
}

add_node :: (name : string) -> *Asset
{
	asset := asset_from_key(*asset_store.nodes, name);
	return asset;
}

equip_node_with_mesh :: (name : string, mesh_name : string) -> *Asset
{
	asset := asset_from_key(*asset_store.nodes, name);
	asset.mesh = sprint("%", mesh_name);
	asset.mesh_hash = hash_string(mesh_name);
	return asset;
}

equip_node_with_parent :: (name : string, parent : *Asset) -> *Asset
{
	asset := asset_from_key(*asset_store.nodes, name);
	child_key := sprint("%", name);
	child_hash := hash_string(child_key);
	
	asset.parent_key = sprint("%", parent.key);
	asset.parent_hash = hash_string(parent.key);
	
	if !parent.last_key.count
	{
		parent.first_key = child_key;
		parent.last_key = child_key;
		parent.first_hash = child_hash;
		parent.last_hash = child_hash;
	}
	else
	{
		asset.prev_key = sprint("%", parent.last_key);
		
		parent_last := asset_from_hash(*asset_store.nodes, parent.last_hash);
		
		parent_last.next_key = child_key;
		parent.last_key = child_key;
		
		asset.prev_hash = hash_string(asset.prev_key);
		parent_last.next_hash = child_hash;
		parent.last_hash = child_hash;
	}
	
	return asset;
}

animation_data_from_key :: (key : string) -> []Animation, []Joint, *Asset
{
	using asset_store;
	anim := asset_from_key(*animations, key);
	joints := asset_from_key(*skins, anim.skin);
	
	return anim.anim, joints.joints, anim;
}

animation_data_from_hash :: (hash : u128) -> []Animation, []Joint, *Asset
{
	using asset_store;
	anim := asset_from_hash(*animations, hash);
	joints := asset_from_hash(*skins, anim.skin_hash);
	
	return anim.anim, joints.joints, anim;
}

material_data_from_key :: (key : string) -> Vector4, Handle
{
	using asset_store;
	material_asset := asset_from_key(*materials, key);
	
	color := material_asset.color;
	
	map_asset := asset_from_key(*textures, material_asset.map);
	
	map := map_asset.id;
	
	return color, map;
}

material_data_from_hash :: (hash : u128) -> Vector4, Handle
{
	using asset_store;
	material_asset := asset_from_hash(*materials, hash);
	
	color := material_asset.color;
	
	map_asset := asset_from_hash(*textures, material_asset.map_hash);
	
	map := map_asset.id;
	
	return color, map;
}

mesh_from_key :: (key : string) -> *Asset
{
	using asset_store;
	mesh_asset := asset_from_key(*meshes, key);
	
	return mesh_asset;
}

mesh_from_hash :: (hash : u128) -> *Asset
{
	using asset_store;
	mesh_asset := asset_from_hash(*meshes, hash);
	
	return mesh_asset;
}

node_from_key :: (key : string) -> *Asset
{
	using asset_store;
	node := asset_from_key(*nodes, key);
	return node;
}

node_from_hash :: (hash : u128) -> *Asset
{
	using asset_store;
	node := asset_from_hash(*nodes, hash);
	return node;
}

asset_from_hash :: (slots : *[]Asset_Slot, hash : u128) -> *Asset
{
	using asset_store;
	out : *Asset;
	
	slot_index := hash.U64[0] % xx slots.count;
	slot := slots.data + slot_index;
	
	// check if node already exists
	{
		cur := slot.first;
		while cur {
			defer cur = cur.hash_next;
			
			if cur.hash == hash {
				out = cur;
				break;
			}
		}
	}
	
	// if not, allocate
	if !out
	{
		out = push_struct(arena, Asset);
		
		out.hash = hash;
		if !slot.first
		{
			slot.first = out;
			slot.last = out;
		}
		else
		{
			slot.last.hash_next = out;
			slot.last = out;
		}
	}
	
	return out;
}

asset_from_key :: (slots : *[]Asset_Slot, key : string) -> *Asset
{
	using asset_store;
	hash := hash_string(key);
	out := asset_from_hash(slots, hash);
	
	if !out.key.count
	{
		out.key = sprint("%", key);
	}
	
	return out;
}

// For artists using blockbench.
// We want smooth shading.
// However, the faces in blockbench aren't joined together
// so first combine all vertices using blender, then smooth shade
// I am sure there is a python (ew) script that can do this.
// https://github.com/JannisX11/blockbench/issues/2024

Material :: struct
{
	color : Vector4;
	color_map : string;
	color_map_hash : u128;
}

Primitive :: struct
{
	start : u32;
	count : u32;
	material : string;
	material_hash : u128;
};

Joint_Sample :: struct
{
	v : Vector4;
	timestamp : float;
};

Animation :: struct
{
	pos : []Joint_Sample;
	rot : []Joint_Sample;
	scale : []Joint_Sample;
	
	length : float;
}

Joint :: struct
{
	parent_index : s32;
	offset : Matrix4;
	bind_pose : Transform;
	aabb : AABB;
}

Key_Frame_Index :: struct
{
	pos : int;
	rot : int;
	scale : int;
}

image_create_from_memory :: (data : string, min_filter : Tex_Param,
														 mag_filter : Tex_Param,
														 wrap : Tex_Param) -> Handle
{
	w, h, n : s32;
	stbi_set_flip_vertically_on_load(1);
	
	bmp_data := stbi_load_from_memory(data.data, xx data.count, *w, *h, *n, 4);
	
	defer stbi_image_free(bmp_data);
	
	return r_image_create(w, h, n, bmp_data, min_filter, mag_filter, wrap);
}

gltf_load_file :: (arena : *Arena, _filename : string)
{
	gltf_it : GLTF_It;
	
	filename := tprint("%/%", models_folder, _filename);
	
	foldername_local := path_strip_filename(_filename);
	gltf_it.foldername_local = foldername_local;
	
	options : cgltf_options;
	data : *cgltf_data;
	
	if cgltf_parse_file(*options, filename.data, *data) != .cgltf_result_success {
		assert(false, "couldn't find %", filename);
	}
	
	if cgltf_load_buffers(*options, data, filename.data) != .cgltf_result_success {
		assert(false, "couldn't load buffers %", filename);
	}
	
	gltf_it.data = data;
	
	found, stripped_filename, ext := split_from_left(_filename, #char ".");
	gltf_it.asset_name = stripped_filename;
	
	// load textures
	if data.textures_count
	{
		for i : 0 .. data.textures_count - 1
		{
			texture_data : string;
			
			if data.textures[i].image.uri
			{
				uri_str := str_from_cstr(data.textures[i].image.uri);
				
				uri_str_header_check := uri_str;
				uri_str_header_check.count = 5;
				
				// gltf + embedded texture
				if uri_str.count > 5 && uri_str_header_check == "data:"
				{
					found, left, right := split_from_left(uri_str, ",");
					
					texture_data = base64_decode(right);
				}
				// gltf
				else
				{
					texture_path := tprint("%0% ", foldername_local, uri_str);
					
					full_texture_path := tprint("%/%", models_folder, texture_path);
					texture_data = read_entire_file(full_texture_path);
				}
			}
			
			// glb
			else if data.textures[i].image.buffer_view
			{
				img := data.textures[i].image;
				
				texture_data.data = cast(*u8)img.buffer_view.buffer.data + img.buffer_view.offset;
				texture_data.count = xx img.buffer_view.size;
				
			}
			else
			{
				assert(false);
			}
			// //key := tprint("%0%", foldername_local, name_str);
			
			tex_key := simple_gltf_tex_key(gltf_it, *data.textures[i]);
			
			tex_param_from_gltf_param :: (gltf_param : s32) -> Tex_Param
			{
				out : Tex_Param;
				
				if gltf_param ==
				{
					case 9728; out = .Nearest;
					case 9729; out = .Linear;
					case 9984; out = .Nearest_Mipmap_Nearest;
					case 9985; out = .Linear_Mipmap_Nearest;
					case 9986; out = .Nearest_Mipmap_Linear;
					case 9987; out = .Linear_Mipmap_Linear;
					case 33071; out = .Clamp_To_Edge;
					case 10497; out = .Repeat;
					case; assert(false, "invalid filter / tex mode");
				}
				
				return out;
			}
			
			min_filter := tex_param_from_gltf_param(data.textures[i].sampler.min_filter);
			
			mag_filter := tex_param_from_gltf_param(data.textures[i].sampler.mag_filter);
			
			wrap := tex_param_from_gltf_param(data.textures[i].sampler.wrap_s);
			
			add_texture(texture_data, tex_key, min_filter, mag_filter, wrap);
		}
	}
	
	if data.materials_count
	{
		for i : 0 .. data.materials_count - 1
		{
			texture_path : string;
			if data.materials[i].pbr_metallic_roughness.base_color_texture.texture
			{
				//uri_str := str_from_cstr(data.materials[i].pbr_metallic_roughness.base_color_texture.texture.name);
				
				texture_path = tprint("%0%", foldername_local, cgltf_texture_index(data, data.materials[i].pbr_metallic_roughness.base_color_texture.texture));
				
				//texture_path = tprint("%0%", foldername_local, uri_str);
			}
			
			name_str := str_from_cstr(data.materials[i].name);
			
			mat_key := simple_gltf_mat_key(gltf_it, *data.materials[i]);
			tex_key : string;
			if data.materials[i].pbr_metallic_roughness.base_color_texture.texture
			{
				tex_key = simple_gltf_tex_key(gltf_it, data.materials[i].pbr_metallic_roughness.base_color_texture.texture);
			}
			
			
			//material := tprint("%0%", foldername_local, cgltf_material_index(data, *data.materials[i]));;
			
			color : Vector4;
			color.component = data.materials[i].pbr_metallic_roughness.base_color_factor;
			add_material(color, tex_key, mat_key);
		}
	}
	
	joint_key : string;
	jaunt_count : u64;
	if data.skins_count
	{
		
		assert(data.skins_count == 1, "% skins", data.skins_count);
		
		for i : 0 .. data.skins_count - 1
		{
			cgltf_skin := data.skins + i;
			
			ibm_accessor := cgltf_skin.inverse_bind_matrices;
			
			//joint_name := tprint("%0%", foldername_local, str_from_cstr(cgltf_skin.name));
			
			joint_key = simple_gltf_skins_key(gltf_it, cgltf_skin);
			
			joints_asset := add_skin(xx cgltf_skin.joints_count, joint_key);
			joints := joints_asset.joints;
			
			jaunt_count = cgltf_skin.joints_count;
			
			for j : 0 .. cgltf_skin.joints_count - 1
			{
				cgltf_joint := cgltf_skin.joints[j];
				
				parent := cgltf_joint.parent;
				
				joint := *joints[j];
				
				offset_mat_data : [16]float;
				
				cgltf_accessor_read_float(ibm_accessor, j, *offset_mat_data[0], 16);
				
				//joint.offset.coef[j][i] = offset_mat_data[i * 4 + j];
				
				for i : 0 .. 4 - 1
				{
					for j : 0 .. 4 - 1
					{
						joint.offset.coef[j][i] = offset_mat_data[i * 4 + j];
					}
				}
				
				//transpose(*joint.offset);
				
				joint.bind_pose.pos.component = cgltf_joint.translation;
				joint.bind_pose.rot.component = cgltf_joint.rotation;
				joint.bind_pose.scale.component = cgltf_joint.scale;
				
				joint.parent_index = -1;
				
				if parent
				{
					for k : 0 .. cgltf_skin.joints_count - 1
					{
						if cgltf_skin.joints[k] == parent
						{
							joint.parent_index = xx k;
							break;
						}
					}
				}
				
				//print("child: % parent: %\n", j, joint.parent_index);
				
			}
		}
	}
	
	// load animations
	if data.animations_count
	{
		for i : 0 .. data.animations_count - 1
		{
			cgltf_animation := data.animations + i;
			
			anim_key := simple_gltf_anim_key(gltf_it, cgltf_animation);
			anim, asset := add_animation(xx jaunt_count, anim_key, joint_key);
			
			for j : 0 .. cgltf_animation.channels_count - 1
			{
				cgltf_animation_channel := cgltf_animation.channels + j;
				target_node := cgltf_animation_channel.target_node;
				
				joint_index : s32;
				
				for k : 0 .. data.skins_count - 1
				{
					cgltf_skin := data.skins + k;
					
					for l : 0 .. cgltf_skin.joints_count - 1
					{
						if cgltf_skin.joints[l] == target_node
						{
							//print("% %", j, l);
							joint_index = xx l;
							break;
						}
					}
				}
				
				kf_count := cgltf_animation_channel.sampler.input.count;
				
				if cgltf_animation_channel.target_path ==
				{
					case .cgltf_animation_path_type_rotation;
					anim[joint_index].rot.data = push_array(arena, Joint_Sample, kf_count);
					anim[joint_index].rot.count = xx kf_count;
					
					case .cgltf_animation_path_type_translation;
					anim[joint_index].pos.data = push_array(arena, Joint_Sample, kf_count);
					anim[joint_index].pos.count = xx kf_count;
					
					case .cgltf_animation_path_type_scale;
					anim[joint_index].scale.data = push_array(arena, Joint_Sample, kf_count);
					anim[joint_index].scale.count = xx kf_count;
				}
				
				input := cgltf_animation_channel.sampler.input;
				
				output := cgltf_animation_channel.sampler.output;
				
				for 0 .. kf_count - 1
				{
					timestamp : float;
					cgltf_accessor_read_float(input, it, *timestamp, 1);
					
					asset.length = max(asset.length, timestamp);
					
					if cgltf_animation_channel.target_path ==
					{
						case .cgltf_animation_path_type_rotation;
						cgltf_accessor_read_float(output, it, *anim[joint_index].rot[it].v.x, 4);
						anim[joint_index].rot[it].timestamp = timestamp;
						case .cgltf_animation_path_type_translation;
						cgltf_accessor_read_float(output, it, *anim[joint_index].pos[it].v.x, 3);
						anim[joint_index].pos[it].timestamp = timestamp;
						case .cgltf_animation_path_type_scale;
						cgltf_accessor_read_float(output, it, *anim[joint_index].scale[it].v.x, 3);
						anim[joint_index].scale[it].timestamp = timestamp;
					}
					
					ooga : int;
				}
				
			}
			
			ooga : int;
		}
	}
	
	// load meshes
	for i : 0 .. data.meshes_count - 1
	{
		node_mesh := data.meshes + i;
		
		mesh_key := simple_gltf_mesh_key(gltf_it, node_mesh);
		mesh := add_mesh(mesh_key);
		
		mesh.num_primitives = node_mesh.primitives_count;
		mesh.primitives = push_array(arena, Primitive, mesh.num_primitives);
		
		m_vertex_num := 0;
		m_index_num := 0;
		
		for i : 0 .. mesh.num_primitives - 1{
			node_prim := node_mesh.primitives + i;
			index_attrib := node_prim.indices;
			
			mesh.num_indices += index_attrib.count;
		}
		
		for i : 0 .. mesh.num_primitives - 1 {
			node_prim := node_mesh.primitives + i;
			
			for j : 0 .. node_prim.attributes_count - 1 {
				attrib := node_prim.attributes + j;
				
				if attrib.type == .cgltf_attribute_type_position {
					vert_attrib := attrib.data;
					mesh.num_vertices += vert_attrib.count;
					
					// for bounding boxes
					mesh.aabb.min.x = vert_attrib.min[0];
					mesh.aabb.min.y = vert_attrib.min[1];
					mesh.aabb.min.z = vert_attrib.min[2];
					
					mesh.aabb.max.x = vert_attrib.max[0];
					mesh.aabb.max.y = vert_attrib.max[1];
					mesh.aabb.max.z = vert_attrib.max[2];
				}
			}
		}
		
		mesh.indices = push_array(arena, u32, mesh.num_indices);
		mesh.vertices = push_array(arena, Vertex, mesh.num_vertices);
		
		for i : 0 .. mesh.num_primitives - 1 {
			init_vtx := m_vertex_num;
			init_index := m_index_num;
			
			node_prim := node_mesh.primitives + i;
			
			p := mesh.primitives + i;
			
			if node_prim.material
			{
				if node_prim.material.has_pbr_metallic_roughness
				{
					//c := node_prim.material.pbr_metallic_roughness.base_color_texture.texture.uri_str
					
					p.material = sprint("%", simple_gltf_mat_key(gltf_it, node_prim.material));
					p.material_hash = hash_string(p.material);
				}
				
			}
			
			index_attrib := node_prim.indices;
			
			p.start = xx init_index;
			p.count = xx index_attrib.count;
			
			// indices
			{
				for j : 0 .. index_attrib.count - 1 {
					index := cgltf_accessor_read_index(index_attrib, j);
					mesh.indices[j + xx m_index_num] = xx (index + xx init_vtx);
				}
				
				m_index_num += xx index_attrib.count;
			}
			
			// vertices
			for j : 0 .. node_prim.attributes_count - 1 {
				attrib := node_prim.attributes + j;
				
				if attrib.type == .cgltf_attribute_type_position {
					vert_attrib := attrib.data;
					m_vertex_num += xx vert_attrib.count;
					
					for k : 0 .. vert_attrib.count - 1 {
						cgltf_accessor_read_float(vert_attrib, k, mesh.vertices[k + xx init_vtx].pos.component.data, size_of(float));
					}
				}
				
				if attrib.type == .cgltf_attribute_type_normal {
					norm_attrib := attrib.data;
					
					for k : 0 .. norm_attrib.count - 1 {
						cgltf_accessor_read_float(norm_attrib, k, mesh.vertices[k + xx init_vtx].normal.component.data, size_of(float));
					}
				}
				
				if attrib.type == .cgltf_attribute_type_color {
					color_attrib := attrib.data;
					for k : 0 .. color_attrib.count - 1 {
						cgltf_accessor_read_float(color_attrib, k, mesh.vertices[k + xx init_vtx].color.component.data, size_of(float));
					}
				}
				
				if attrib.type == .cgltf_attribute_type_texcoord {
					tex_attrib := attrib.data;
					
					// TODO(mizu):  difference b/w attrib index 0 and 1
					if attrib.index == 0 {
						for k : 0 .. tex_attrib.count - 1 {
							tex : [2]float;
							
							cgltf_accessor_read_float(tex_attrib, k, tex.data, size_of(float));
							mesh.vertices[k + xx init_vtx].uv_x = tex[0];
							mesh.vertices[k + xx init_vtx].uv_y = 1 - tex[1];
						}
					}
				}
				
				if attrib.type == .cgltf_attribute_type_tangent {
					tangent_attrib := attrib.data;
					for k : 0 .. tangent_attrib.count - 1 {
						cgltf_accessor_read_float(tangent_attrib, k, mesh.vertices[k + xx init_vtx].tangent.component.data, size_of(float));
					}
				}
				
				if attrib.type == .cgltf_attribute_type_joints
				{
					joint_attrib := attrib.data;
					
					for k : 0 .. joint_attrib.count - 1
					{
						cgltf_accessor_read_uint(joint_attrib, k, mesh.vertices[k + xx init_vtx].joints.data, size_of(u32));
						ooga : int;
					}
					
				}
				
				if attrib.type == .cgltf_attribute_type_weights
				{
					weight_attrib := attrib.data;
					
					for k : 0 .. weight_attrib.count - 1
					{
						cgltf_accessor_read_float(weight_attrib, k, mesh.vertices[k + xx init_vtx].weights.component.data, size_of(float));
						ooga : int;
					}
					
				}
				
			}
		}
		
		// make vertex buffer
		{
			size := size_of(Vertex) * mesh.num_vertices;
			
			mesh.vertex_buffer = r_buffer_create(.Static_Draw, mesh.vertices, size);
		}
		
		// make index buffer
		{
			size := size_of(u32) * mesh.num_indices;
			
			mesh.index_buffer = r_buffer_create(.Static_Draw, mesh.indices, size);
		}
		
	}
	
	gltf_it.arena = arena;
	
	for i : 0 .. data.scenes_count - 1
	{
		scene := data.scenes + i;
		mesh_node : *GLTF_Mesh_Node_Checker;
		
		for j : 0 .. scene.nodes_count - 1
		{
			node := scene.nodes[j];
			mesh_node = talloc(size_of(GLTF_Mesh_Node_Checker));
			
			gltf_traverse_node(*gltf_it, node, mesh_node);
		}
		
		gltf_traverse_node2(*gltf_it, mesh_node);
		jeff : int;
		
		gltf_traverse_node3(*gltf_it, mesh_node);
		jefff : int;
		
		//		asset_node_key := simple_gltf_node_key(gltf_it, mesh_node.node);
		//		asset_node := add_node(asset_node_key);
		gltf_traverse_node4(*gltf_it, mesh_node, null);
		jeffff : int;
		
		print_asset_node(hash_string("cow.cow_root"));
	}
	
	//gltf_print(it.scene);
	
	cgltf_free(data);
}

#scope_file

cgltf_texture_index :: (data : *cgltf_data, object : *cgltf_texture) -> cgltf_size
{
	//assert(object && (cgltf_size)(object - data->textures) < data->textures_count);
	return cast(cgltf_size)(object - data.textures);
}

cgltf_material_index :: (data : *cgltf_data, object : *cgltf_material) -> cgltf_size
{
	//assert(object && (cgltf_size)(object - data->materials) < data->materials_count);
	return cast(cgltf_size)(object - data.materials);
}

cgltf_skin_index :: (data : *cgltf_data, object : *cgltf_skin) -> cgltf_size
{
	//assert(object && (cgltf_size)(object - data->materials) < data->materials_count);
	return cast(cgltf_size)(object - data.skins);
}

cgltf_animation_index :: (data : *cgltf_data, object : *cgltf_animation) -> cgltf_size
{
	//assert(object && (cgltf_size)(object - data->materials) < data->materials_count);
	return cast(cgltf_size)(object - data.animations);
}

cgltf_mesh_index :: (data : *cgltf_data, object : *cgltf_mesh) -> cgltf_size
{
	//assert(object && (cgltf_size)(object - data->materials) < data->materials_count);
	return cast(cgltf_size)(object - data.meshes);
}

cgltf_node_index :: (data : *cgltf_data, object : *cgltf_node) -> cgltf_size
{
	//assert(object && (cgltf_size)(object - data->materials) < data->materials_count);
	return cast(cgltf_size)(object - data.nodes);
}

simple_gltf_tex_key :: (gltf_it : GLTF_It, tex : *cgltf_texture) -> string
{
	str : string;
	if tex.name
	{
		str = str_from_cstr(tex.name);
	}
	else
	{
		str = tprint("%", cgltf_texture_index(gltf_it.data, tex));
	}
	
	key := tprint("%.%", gltf_it.asset_name, str);
	return key;
}

simple_gltf_mat_key :: (gltf_it : GLTF_It, tex : *cgltf_material) -> string
{
	str : string;
	if tex.name
	{
		str = str_from_cstr(tex.name);
	}
	else
	{
		str = tprint("%", cgltf_material_index(gltf_it.data, tex));
	}
	
	key := tprint("%.%", gltf_it.asset_name, str);
	return key;
}

simple_gltf_skins_key :: (gltf_it : GLTF_It, tex : *cgltf_skin) -> string
{
	str : string;
	if tex.name
	{
		str = str_from_cstr(tex.name);
	}
	else
	{
		str = tprint("%", cgltf_skin_index(gltf_it.data, tex));
	}
	
	key := tprint("%.%", gltf_it.asset_name, str);
	return key;
}

simple_gltf_anim_key :: (gltf_it : GLTF_It, tex : *cgltf_animation) -> string
{
	str : string;
	if tex.name
	{
		str = str_from_cstr(tex.name);
	}
	else
	{
		str = tprint("%", cgltf_animation_index(gltf_it.data, tex));
	}
	
	key := tprint("%.%", gltf_it.asset_name, str);
	return key;
}

simple_gltf_mesh_key :: (gltf_it : GLTF_It, tex : *cgltf_mesh) -> string
{
	str : string;
	if tex.name
	{
		str = str_from_cstr(tex.name);
	}
	else
	{
		str = tprint("%", cgltf_mesh_index(gltf_it.data, tex));
	}
	
	key := tprint("%.%", gltf_it.asset_name, str);
	return key;
}

simple_gltf_node_key :: (gltf_it : GLTF_It, tex : *cgltf_node) -> string
{
	str : string;
	if tex.name
	{
		str = str_from_cstr(tex.name);
	}
	else
	{
		str = tprint("%", cgltf_node_index(gltf_it.data, tex));
	}
	
	key := tprint("%.%", gltf_it.asset_name, str);
	return key;
}

GLTF_It :: struct
{
	arena : *Arena;
	data : *cgltf_data;
	dir : string;
	foldername_local : string;
	asset_name : string;
};

GLTF_Mesh_Node_Checker :: struct
{
	node : *cgltf_node;
	has_mesh : bool;
	visited : bool;
	
	first  : *GLTF_Mesh_Node_Checker;
	last   : *GLTF_Mesh_Node_Checker;
	next   : *GLTF_Mesh_Node_Checker;
	prev   : *GLTF_Mesh_Node_Checker;
	parent : *GLTF_Mesh_Node_Checker;
	
	children_count : int;
};

// check if node has a mesh attached or has a child at some point that has a mesh. This
// is to avoid nodes that are purely for joints
gltf_traverse_node :: (gltf_it : *GLTF_It, gltf_node : *cgltf_node, mesh_node : *GLTF_Mesh_Node_Checker)
{
	mesh_node.node = gltf_node;
	for i : 0 .. (cast(int)gltf_node.children_count) - 1
	{
		child_mesh_node : *GLTF_Mesh_Node_Checker = talloc(size_of(GLTF_Mesh_Node_Checker));
		child_mesh_node.parent = mesh_node;
		mesh_node.children_count += 1;
		if !mesh_node.last
		{
			mesh_node.first = child_mesh_node;
			mesh_node.last = child_mesh_node;
		}
		else
		{
			child_mesh_node.prev = mesh_node.last;
			mesh_node.last.next = child_mesh_node;
			mesh_node.last = child_mesh_node;
		}
		gltf_traverse_node(gltf_it, gltf_node.children[i], child_mesh_node);
	}
}

gltf_traverse_node2 :: (gltf_it : *GLTF_It, mesh_node : *GLTF_Mesh_Node_Checker)
{
	// check if node has a mesh attached or has a child at some point that has a mesh. This
	// is to avoid nodes that are purely for joints
	child_mesh_node := mesh_node.first;
	for i : 0 .. (cast(int)mesh_node.children_count) - 1
	{
		gltf_traverse_node2(gltf_it, child_mesh_node);
		child_mesh_node = child_mesh_node.next;
	}
	
	if mesh_node.node.mesh
	{
		mesh_node.visited = true;
		mesh_node.has_mesh = true;
		
		parent_mesh_node := mesh_node.parent;
		while parent_mesh_node
		{
			parent_mesh_node.visited = true;
			parent_mesh_node.has_mesh = true;
			parent_mesh_node = parent_mesh_node.parent;
		}
		
	}
}

gltf_traverse_node3 :: (gltf_it : *GLTF_It, mesh_node : *GLTF_Mesh_Node_Checker)
{
	child_mesh_node := mesh_node.first;
	for i : 0 .. (cast(int)mesh_node.children_count) - 1
	{
		while child_mesh_node && !child_mesh_node.has_mesh
		{
			if child_mesh_node.prev
			{
				child_mesh_node.prev.next = child_mesh_node.next;
			}
			else
			{
				mesh_node.first = child_mesh_node.next;
			}
			
			if child_mesh_node.next
			{
				child_mesh_node.next.prev = child_mesh_node.prev;
			}
			else
			{
				mesh_node.last = child_mesh_node.prev;
			}
			
			mesh_node.children_count -= 1;
			child_mesh_node = child_mesh_node.next;
		}
		
		if child_mesh_node
		{
			gltf_traverse_node3(gltf_it, child_mesh_node);
			child_mesh_node = child_mesh_node.next;
		}
	}
}

gltf_traverse_node4 :: (gltf_it : *GLTF_It, mesh_node : *GLTF_Mesh_Node_Checker, parent_asset_node : *Asset)
{
	node_key := simple_gltf_node_key(gltf_it, mesh_node.node);
	child_asset_node := add_node(node_key);
	
	if parent_asset_node equip_node_with_parent(node_key, parent_asset_node);
	
	mat : [16]float;
	cgltf_node_transform_local(mesh_node.node, mat.data);
	
	for i : 0 .. 4 - 1
	{
		for j : 0 .. 4 - 1
		{
			child_asset_node.xform.coef[j][i] = mat[i * 4 + j];
		}
	}
	
	if mesh_node.node.mesh
	{
		if mesh_node.node.skin
		{
			//mesh.skin = sprint("%0%", it.foldername_local, node.skin.name);
		}
		
		mesh_key := simple_gltf_mesh_key(gltf_it, mesh_node.node.mesh);
		equip_node_with_mesh(node_key, mesh_key);
	}
	
	child_mesh_node := mesh_node.first;
	for i : 0 .. (cast(int)mesh_node.children_count) - 1
	{
		gltf_traverse_node4(gltf_it, child_mesh_node, child_asset_node);
		child_mesh_node = child_mesh_node.next;
	}
}

print_asset_node :: (root : u128)
{
	node := asset_from_hash(*asset_store.nodes, root);
	child_node : *Asset;
	
	if node.first_key.count
	{
		child_node = asset_from_hash(*asset_store.nodes, node.first_hash);
	}
	
	while child_node
	{
		print_asset_node(child_node.hash);
		if child_node.next_key.count
		{
			child_node = asset_from_hash(*asset_store.nodes, child_node.next_hash);
		}
		else
		{
			break;
		}
	}
}

/*
gltf_print :: (scene : []Mesh)
{
	for i : 0 .. scene.count - 1 {
		mesh := scene[i];

		print("indices %\n", i);
		for j : 0 .. mesh.num_indices - 1 {
			print("%, ", mesh.indices[j]);
		}
		print("\n");

		print("verticess %\n", i);
		for j : 0 .. mesh.num_vertices - 1 {
			vert := mesh.vertices + j;
			print("pos:     %\n", vert.pos);
			print("joints:  %\n", vert.joints);
			print("weights: %\n", vert.weights);
		}
		print("\n\n");

		for j : 0 .. mesh.num_primitives - 1 {
			p := mesh.primitives;

			print("start: %\n", p.start);
			print("count: %\n", p.count);
		}

		print("\n");
	}
}
*/
