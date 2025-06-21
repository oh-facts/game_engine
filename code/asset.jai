AABB :: struct
{
	min : Vector3;
	max : Vector3;
}

Ray :: struct
{
	o : Vector3;
	dir : Vector3;
}

ray_aabb_intersection :: (ray : Ray, aabb : AABB) -> float, bool
{
	t1 := (aabb.min.x - ray.o.x) / ray.dir.x;
	t2 := (aabb.max.x - ray.o.x) / ray.dir.x;
	t3 := (aabb.min.y - ray.o.y) / ray.dir.y;
	t4 := (aabb.max.y - ray.o.y) / ray.dir.y;
	t5 := (aabb.min.z - ray.o.z) / ray.dir.z;
	t6 := (aabb.max.z - ray.o.z) / ray.dir.z;
	
	tmin := max(Max(Min(t1, t2), Min(t3, t4)), Min(t5, t6));
	tmax := min(Min(Max(t1, t2), Max(t3, t4)), Max(t5, t6));
	
	// if tmax < 0, ray (line) is intersecting AABB, but whole AABB is behing us
	if (tmax < 0) {
		return -1, false;
	}
	
	// if tmin > tmax, ray doesn't intersect AABB
	if (tmin > tmax) {
		return -1, false;
	}
	
	if (tmin < 0) {
		return tmax, true;
	}
	return tmin, true;
}

Asset :: struct
{
	next : *Asset;
	
	key : string;
	hash : u128;
	
	map : string;
	map_hash : u128;
	
	color : Vector4;
	
	id : Handle;
	
	anim : []Animation;
	length : float;
	
	skin : string;
	skin_hash : u128;
	
	joints : []Joint;
	
	meshes : []Mesh;
	aabb : AABB;
}

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
}

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

add_skin :: (count : u32, name : string) -> []Joint
{
	asset := asset_from_key(*asset_store.skins, name);
	asset.joints.data = push_array(asset_store.arena, Joint, count);
	asset.joints.count = count;
	
	return asset.joints;
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

add_meshes :: (count : u32, name : string) -> []Mesh
{
	asset := asset_from_key(*asset_store.meshes, name);
	asset.meshes.data = push_array(asset_store.arena, Mesh, count);
	asset.meshes.count = count;
	
	asset.skin = sprint("%", name);
	
	return asset.meshes;
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

meshes_from_key :: (key : string) -> []Mesh
{
	using asset_store;
	mesh_asset := asset_from_key(*meshes, key);
	
	return mesh_asset.meshes;
}

meshes_from_hash :: (hash : u128) -> []Mesh
{
	using asset_store;
	mesh_asset := asset_from_hash(*meshes, hash);
	
	return mesh_asset.meshes;
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
			defer cur = cur.next;
			
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
			slot.last.next = out;
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
	
	if !out
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
}

Mesh :: struct 
{
	primitives : *Primitive;
	num_primitives : u64;
	indices : *u32;
	num_indices : u64;
	
	vertices : *Vertex;
	num_vertices : u64;
	
	vertex_buffer : u32;
	index_buffer : u32;
	
	skin : string;
	
	aabb : AABB;
	
	// global xform
	xform : Matrix4;
};

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

gltf_loadMesh :: (arena : *Arena, _filename : string)
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
			tex_key := simple_gltf_tex_key(gltf_it, data.materials[i].pbr_metallic_roughness.base_color_texture.texture);
			
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
			
			joints := add_skin(xx cgltf_skin.joints_count, joint_key);
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
	
	gltf_it.scene = add_meshes(xx data.meshes_count, stripped_filename);;
	gltf_it.arena = arena;
	
	for i : 0 .. data.scenes_count - 1 
	{
		scene := data.scenes + i;
		
		for j : 0 .. scene.nodes_count - 1 {
			node := scene.nodes[j];
			
			gltf_traverseNode(*gltf_it, node);
		}
	}
	
	//gltf_print(it.scene);
	
	cgltf_free(data);
	
	for i : 0 .. gltf_it.scene.count - 1
	{
		mesh := *gltf_it.scene[i];
		
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

GLTF_It :: struct 
{
	arena : *Arena;
	mesh_index : u64;
	scene : []Mesh;
	data : *cgltf_data;
	dir : string;
	foldername_local : string;
	asset_name : string;
};

gltf_traverseNode :: (it : *GLTF_It, node : *cgltf_node) {
	if node.mesh {
		node_mesh := node.mesh;
		
		mesh := *it.scene[it.mesh_index];
		mesh.num_primitives = node_mesh.primitives_count;
		mesh.primitives = push_array(it.arena, Primitive, mesh.num_primitives);
		
		m_vertex_num := 0;
		m_index_num := 0;
		
		for i : 0 .. mesh.num_primitives - 1{
			node_prim := node.mesh.primitives + i;
			index_attrib := node_prim.indices;
			
			mesh.num_indices += index_attrib.count;
		}
		
		for i : 0 .. mesh.num_primitives - 1 {
			node_prim := node.mesh.primitives + i;
			
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
		
		mesh.indices = push_array(it.arena, u32, mesh.num_indices);
		mesh.vertices = push_array(it.arena, Vertex, mesh.num_vertices);
		
		for i : 0 .. mesh.num_primitives - 1 {
			init_vtx := m_vertex_num;
			init_index := m_index_num;
			
			node_prim := node.mesh.primitives + i;
			
			p := mesh.primitives + i;
			
			if node_prim.material 
			{
				if node_prim.material.has_pbr_metallic_roughness 
				{
					//c := node_prim.material.pbr_metallic_roughness.base_color_texture.texture.uri_str
					
					p.material = sprint("%", simple_gltf_mat_key(it, node_prim.material));
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
		
		mat : [16]float;
		cgltf_node_transform_world(node, mat.data);
		
		for i : 0 .. 4 - 1 {
			for j : 0 .. 4 - 1 {
				mesh.xform.coef[j][i] = mat[i * 4 + j];
			}
		}
		
		it.mesh_index+=1;
		
		if node.skin
		{
			//mesh.skin = sprint("%0%", it.foldername_local, node.skin.name);
		}
		
	}
	
	for i : 0 .. (cast(int)node.children_count) - 1 {
		gltf_traverseNode(it, node.children[i]);
	}
}

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