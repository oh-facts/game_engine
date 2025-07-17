/*

// For when you return, you were going to make the entity updating thing its own thing.
// Maybe make a tab for it. Maybe put the asset viewing thing in a tab function.
// call begin and end window like normal, but process whatever tab is selected
// Entity updating its own thing bad idea.
// I will talk about an architecture idea I had
// library vs user code


[ ] skinned aabbs: I think the best way to deal with skinned mesh aabbs is to output vertex min / max
 after skinning

// [x] find out why some nodes are not centered
		// ohhh. I should render their mesh?
		// but what if mesh has child meshes?
		// This was happening because their origin was set to the center of the scene. They look fine after setting each mesh's origin to the center of the mesh

		// [ ] I am thinking about another asset kind that is just
		// a merged mesh. Like imagine I hash a bunch of root meshes to 
		// create a new mesh that is just the merged version of the base meshes.
		
// [ ] Use a frame arena for every system that needs per frame memory instead of using the global frame arena (a la temp memory). Use that for scratch memory maybe. For cache it should be better if you use a per - system frame arena, no?

That bug I was having in the WAS BECAUSE OF THE FAR PLANE

THERE WAS NO NEED TO CRANK UP RAY STEPS AND CRANK DOWN EPSILON

BASICALLY I CONVERT ray marched world space pos -> clip pos so I can fill the depth buffer
My far plane is only 1000 so things beyon that are ignored. My planet radius is like 1000 and I've been viewing it 
from outer space

[x] Higher depth precision + inf far plane. Was really annoying me. Now I can work on game.
*/

// NOTE(mizu): Global modules
#import "Basic";
#import "System";
#import "String";
#import "Math";
#import "File";
#import "File_Utilities";
#import "Random";
#import "stb_image";
#import "Window_Creation";
#import "Input";
#import "Windows";
#import "meow_hash";
#import "Base64";
#import "GL" (ENABLE_ALL_EXTENSIONS = true);
#import "Windows_Utf8";
#import "Unicode";
#import "freetype-2.12.1";
// NOTE(mizu): local modules
#import "jai_cgltf";

// NOTE(mizu): src code
#load "base.jai";
#load "render_opengl.jai";
#load "render_push_buffer.jai";
#load "render_asset.jai";
#load "render_shapes.jai";
#load "asset.jai";
#load "widgets.jai";
#load "globals.jai";
#load "entity.jai";
#load "glyph.jai";
#load "camera.jai";
#load "memory.jai";
#load "editor.jai";
#load "input.jai";
#load "platform.jai";
#load "math.jai";
#load "profiling.jai";
#load "string.jai";

#if enable_profiling
{
#import "tracy" (IMPORT_MODE=.CLIENT);
}

nil_widget : Widget;

hot_entity : *Entity;
active_entity : *Entity;
is_grabbing : bool;
grab_index : int = -1;
raycast_last_frame : Ray;
raycast : Ray;
current_gizmo_mode : Gizmo_Mode;

Gizmo_Mode :: enum
{
	Translate;
	Scale;
	Rotate;
}

active_node_asset_hash : u128;
active_mesh_asset_hash : u128;

the_window: Window_Type;

current_asset_viewer_tab : Asset_Viewer_Tab;

main :: ()
{
	print("Do not enter is written on the doorway, why can't everyone just go away\n");
	print("Except for you, you can stay\n");
	
	exe_folder = path_strip_filename(get_path_of_running_executable());
	
	// TODO(mizu): Make a sprint() that uses the perm arena
	code_folder = join(exe_folder, "../code");
	
	data_folder = join(exe_folder, "../data");
	models_folder = join(data_folder, "/models");
	fonts_folder = join(data_folder, "/fonts");
	
	SetProcessDPIAware();
	
	the_window = create_window(960, 540, tprint("The SAD Debugger by SAD Game Tools | %.%.%", major, minor, patch));
	
	saved : Saved_Window_Info;
	//toggle_fullscreen(the_window, true, *saved);
	
	boss_window := init_editor_window("asset viewer", .{32, 32}, .{300, 800});
	
	delta : float;
	time_elapsed : float;
	
	start := get_perf_counter();
	freq := get_perf_freq();
	
	r_backend_init(get_window_size(the_window));
	r_shapes_init();
	asset_init();	
	font_state_init();
	widget_init();
	
	quit := false;
	
	ui_camera : Camera;
	
	entity_state := entity_state_init();
	
	{
		po := entity_alloc(*entity_state);
		po.node_asset_hash = hash_string("watermelon_stall.root");
		po.model_kind = .Node_Asset;
		set_entity_name(po, "wa'er melon s'all");
		//po.pos = .{0,101.8,0};
	}
	
	// Make the gltf load file thing part of the node_from_key
	// then when you do cow.walk.
	// it loads cow.glb
	// and extracts walk and whatever else
	// TODO(mizu): Use frame arena or something.
	// Use temp memory for scratch stuff
	
	gltf_load_file("watermelon_stall.glb");
	gltf_load_file("cow.glb");
	
	//control_camera = true;
	//toggle_cursor(0);
	
	//watermelon_stall.root
	
	jeff : int;
	
	counter : float;
	
	while !quit
	{
		profile_tick();
		
		counter += delta;
		
		time_since_last := time_elapsed;
		wheel_delta = 0;
		win_size := get_window_size(the_window);
		
		update_window_events();
		
		for events_this_frame
		{
			if it.type == .QUIT then quit = true;
			
			if it.type == .KEYBOARD
			{
				if it.key_pressed == 0 continue;
				
				if it.key_code == .ESCAPE
				{
					quit = true;
				}
			}
			if it.type == .MOUSE_WHEEL
			{
				wheel_delta += it.wheel_delta;
			}
		}
		
		pb := begin_render();
		pb.counter = counter;
		
		x,y := get_mouse_pointer_position(the_window, false);
		
		update_2d_camera(*ui_camera, delta, .{xx win_size.x, xx win_size.y});
		
		ui_proj, ui_view := get_ortho_proj_and_view_matrix(ui_camera);
		
		pb.viewport = rectF32(0, 0, xx win_size.x, xx win_size.y);
		
		scissor := rectF32(0, 0, xx win_size.x, xx win_size.y);
		{
			params := push_batch_group_sprite_params(*pb);
			params.proj = ui_proj;
			params.view = ui_view;
			params.scissor = scissor;
		}
		
		begin_widgets(.{xx x,xx y});
		begin_editor_window(*boss_window);
		boss_window.counter += delta;
		
		// update tabs
		{
			current_editor_tab := *boss_window.tabs[boss_window.current_app_mode_tab];
			
			update_flying_camera(*current_editor_tab.camera, delta, .{xx win_size.x, xx win_size.y});
			proj, view := get_perspective_proj_and_view_matrix(current_editor_tab.camera);
			pb.proj = proj;
			pb.view = view;
			
			if is_key_pressed(.TAB)
			{
				toggle_cursor(xx current_editor_tab.camera.control);
				current_editor_tab.camera.control = !current_editor_tab.camera.control;
			}
			
			if !boss_window.hide
			{
				// idk if contexts are expensive like that
				new_context := context;
				push_context new_context
				{
					format_float := *context.print_style.default_format_float;
					format_float.trailing_width = 1;
					
					simple_label(tprint("%, %, %", current_editor_tab.camera.position.x, current_editor_tab.camera.position.y, current_editor_tab.camera.position.z), .{180, 20});
					
					rot := deg_rot_from_rad_rot(current_editor_tab.camera.euler_angles);
					
					simple_label(tprint("%, %, %", rot.x, rot.y, rot.z), .{180, 20});
				}
				simple_label(tprint("%", delta), .{180, 20});
				
				if boss_window.current_app_mode_tab ==
				{
					case .Asset_Viewer;
					node_view_key := make_widget_key();
					node_view := widget_from_key(node_view_key);
					
					mesh_view_key := make_widget_key();
					mesh_view := widget_from_key(mesh_view_key);
					
					simple_spacer_widget(0,2);
					
					node_view.text = "nodes"; 
					node_view.size = .{55, 20};
					node_view.flags |= .Draw_Text | .Draw_Bg;
					node_view.font_size = 12;
					
					mesh_view.text = "meshes"; 
					mesh_view.size = .{65, 20};
					mesh_view.flags |= .Draw_Text | .Draw_Bg;
					mesh_view.font_size = 12;
					
					if current_asset_viewer_tab == .Node
					{
						node_view.active = true;
					}
					
					else if current_asset_viewer_tab == .Mesh
					{
						mesh_view.active = true;
					}
					
					if signal_from_widget(node_view)
					{
						current_asset_viewer_tab = .Node;
					}
					
					else if signal_from_widget(mesh_view)
					{
						current_asset_viewer_tab = .Mesh;
					}
					
					col();
					placer_widget_root := _start;
					
					if point_in_rect(.{xx last_mpos_x, xx last_mpos_y}, rectF32(placer_widget_root.final_pos, placer_widget_root.final_size))
					{
						boss_window.scroll_offsets[current_asset_viewer_tab] += wheel_delta;
					}
					
					placer_widget_root.view_offset.y = boss_window.scroll_offsets[current_asset_viewer_tab];
					placer_widget_root.clip_size = boss_window.size;
					placer_widget_root.flags |= .Clip;
					
					asset_index : int;
					
					if current_asset_viewer_tab == 
					{
						case .Mesh;
						
						for slot : asset_store.meshes.slots
						{
							asset := slot.first;
							while asset
							{
								active, widg := fixed_label(tprint("%", asset.key), asset_index);
								
								if active_mesh_asset_hash == asset.hash
								{
									widg.active = true;
								}
								
								if active
								{
									active_mesh_asset_hash = asset.hash;
								}
								asset_index += 1;
								asset = asset.hash_next;
							}
						}
						
						if active_mesh_asset_hash.U64[0]
						{
							yaw : Quaternion;
							set_from_axis_and_angle (*yaw, 0, -1, 0, boss_window.counter);
							model := rotation_matrix(Matrix4, yaw);
							
							if boss_window.draw_asset
							{
								draw_mesh_asset(*pb, model, active_mesh_asset_hash);
							}
							
							if boss_window.draw_aabb
							{
								draw_mesh_asset_aabb(*pb, active_mesh_asset_hash, model);
							}
						}
						
						case .Node;
						for slot : asset_store.nodes.slots
						{
							asset := slot.first;
							while asset
							{
								if !asset.parent_key.count
								{
									active, widg := fixed_label(tprint("%", asset.key), asset_index);
									
									if active_node_asset_hash == asset.hash
									{
										widg.active = true;
									}
									
									if active
									{
										active_node_asset_hash = asset.hash;
									}
								}
								asset_index += 1;
								asset = asset.hash_next;
							}
						}
						
						if active_node_asset_hash.U64[0]
						{
							yaw : Quaternion;
							set_from_axis_and_angle (*yaw, 0, -1, 0, boss_window.counter);
							model := rotation_matrix(Matrix4, yaw);
							
							if boss_window.draw_asset
							{
								draw_node_asset(*pb, model, active_node_asset_hash);
							}
							
							if boss_window.draw_aabb
							{
								draw_node_asset_aabb(*pb, active_node_asset_hash, model);
							}
						}
					}
					
					case .Game;
					
					simple_label(tprint("%", current_gizmo_mode), .{100,20});
					
					{
						pressed := simple_label("+", .{20,20});
						if pressed
						{
							entity_alloc(*entity_state);
						}
					}
					
					// idk if contexts are expensive like that
					new_context := context;
					push_context new_context
					{
						format_float := *context.print_style.default_format_float;
						format_float.trailing_width = 1;
						
						col();
						placer_widget_root := _start;
						
						if point_in_rect(.{xx last_mpos_x, xx last_mpos_y}, rectF32(placer_widget_root.final_pos, placer_widget_root.final_size))
						{
							boss_window.scroll_offsets[current_asset_viewer_tab] += wheel_delta;
						}
						
						placer_widget_root.child_view_offset.y = boss_window.scroll_offsets[current_asset_viewer_tab];
						placer_widget_root.clip_size = boss_window.size;
						placer_widget_root.flags |= .Clip;
						
						// display entity stuff
						for e : entity_state.entities
						{
							simple_label(e.short_name, .{300, 20}, it_index);
							
							{
								row(it_index);
								simple_spacer_widget(20, 0, it_index);
								{
									col(it_index);
									simple_label(tprint("pos:  %, %, %", e.pos.x, e.pos.y, e.pos.z), .{280, 20}, it_index);
									
									rot := deg_rot_from_rad_rot(e.rot);
									
									simple_label(tprint("rot:  %, %, %", rot.x, rot.y, rot.z), .{280, 20}, it_index);
									simple_label(tprint("size: %, %, %", e.size.x, e.size.y, e.size.z), .{280, 20}, it_index);
								}
							}
						}
					}
					
					{
						ray_nds : Vector2;
						ray_nds.x = (x / cast(f32) win_size.x) * 2 - 1;
						ray_nds.y = - ((y / cast(f32) win_size.y) * 2 - 1);
						
						//print("%\n", ray_nds);
						
						ray_clip : Vector4;
						ray_clip.xy = ray_nds;
						ray_clip.z = -1;
						ray_clip.w = 1;
						
						ray_eye := inverse(proj) * ray_clip;
						ray_eye.z = -1;
						ray_eye.w = 0;
						
						ray_wor : Vector3 = (inverse(view) * ray_eye).xyz;
						ray_wor = normalize(ray_wor);
						
						start := current_editor_tab.camera.position;
						//end := start + 1000 * ray_wor;
						
						raycast_last_frame = raycast;
						raycast = .{start, ray_wor};
					}
					
					if active_entity
					{
						gizmo_size : Vector2 = .{0.5, 2};
						gizmo_delta := (gizmo_size.x + gizmo_size.y) / 2.;
						
						for 0 .. 2
						{
							axis : Vector3;
							axis.component[it] = gizmo_delta;
							gizmo_pos := active_entity.pos + axis;
							gizmo_color : Vector4;
							gizmo_color.w = 1;
							gizmo_color.component[it] = 1;
							
							gizmo_rot : Vector3;
							if it == 0 gizmo_rot.z = deg_to_rad(90);
							else if it == 2 gizmo_rot.x = deg_to_rad(90);
							
							push_quad(*pb, gizmo_pos, gizmo_size, gizmo_rot, gizmo_color, get_white_square());
						}
					}
					
					if active_entity && !current_editor_tab.camera.control
					{
						gizmo_size : Vector2 = .{0.5, 2};
						gizmo_delta := (gizmo_size.x + gizmo_size.y) / 2.;
						
						if is_grabbing && !is_key_down(.MOUSE_BUTTON_LEFT)
						{
							is_grabbing = false;
						}
						
						if is_key_pressed(#char "D")
						{
							active_entity.size = .{1,1,1};
						}
						
						if is_key_pressed(#char "S")
						{
							current_gizmo_mode = .Scale;
						}
						
						else if is_key_pressed(#char "T")
						{
							current_gizmo_mode = .Translate;
						}
						
						else if is_key_pressed(#char "R")
						{
							current_gizmo_mode = .Rotate;
						}
						
						for 0 .. 2
						{
							axis : Vector3;
							axis.component[it] = gizmo_delta;
							gizmo_pos := active_entity.pos + axis;
							gizmo_color : Vector4;
							gizmo_color.w = 1;
							gizmo_color.component[it] = 1;
							
							gizmo_rot : Vector3;
							if it == 0 gizmo_rot.z = deg_to_rad(90);
							else if it == 2 gizmo_rot.x = deg_to_rad(90);
							
							//push_quad(*pb, gizmo_pos, gizmo_size, gizmo_rot, gizmo_color, get_white_square());
							
							half_extents : Vector3;
							
							// probably a math way to generalize this
							if it == 0
							{
								half_extents = .{gizmo_size.y / 2, gizmo_size.x / 2, 0};
							}
							else if it == 1
							{
								half_extents = .{gizmo_size.x / 2, gizmo_size.y / 2, 0};
							}
							else if it == 2
							{
								half_extents = .{gizmo_size.x / 2, 0, gizmo_size.y / 2};
							}
							
							aabb : AABB;
							aabb.min = gizmo_pos - half_extents;
							aabb.max = gizmo_pos + half_extents;
							
							t, hit := ray_aabb_intersection(raycast, aabb);
							
							if hit && is_key_down(.MOUSE_BUTTON_LEFT) && !is_grabbing
							{
								is_grabbing = true;
								grab_index = it;
							}
							
							if is_grabbing && it == grab_index
							{
								t : float;
								tt : float;
								if it == 0
								{
									t = ray_plane_intersection(raycast, .{gizmo_pos.z, .{0, 0, 1}, true});
									tt = ray_plane_intersection(raycast_last_frame, .{gizmo_pos.z, .{0, 0, 1}, true});
								}
								else if it == 1
								{
									t = ray_plane_intersection(raycast, .{gizmo_pos.z, .{0, 0, 1}, true});
									tt = ray_plane_intersection(raycast_last_frame, .{gizmo_pos.z, .{0, 0, 1}, true});
								}
								else if it == 2
								{
									t = ray_plane_intersection(raycast, .{gizmo_pos.y, .{0, 1, 0}, true});
									tt = ray_plane_intersection(raycast_last_frame, .{gizmo_pos.y, .{0, 1, 0}, true});
								}
								
								hit_pos := raycast.o + raycast.dir * t;
								hit_pos_last := raycast_last_frame.o + raycast_last_frame.dir * tt;
								
								movement := dot(hit_pos - hit_pos_last, axis);
								
								if current_gizmo_mode ==
								{
									case .Translate;
									active_entity.pos += axis * movement * delta * 100;
									case .Scale;
									active_entity.size += axis * movement * delta * 100;
									case .Rotate;
									active_entity.rot += axis * movement * delta * 100;
								}
								
								//active_entity.pos.component[it] += hit_pos.component[it] - hit_pos_last.component[it];
							}
						}
						
						if is_key_down(xx #char "C")
						{
							active_entity = null;
						}
					}
					
					push_quad(*pb, .{0, 10, 0}, .{5, 5}, .{}, COLOR_RED, get_white_square());
					push_quad(*pb, .{0, 10, 0.01}, .{1, 1}, .{}, COLOR_WHITE, get_white_square());
					
					// animate entities
					for *e : entity_state.entities
					{
						if e.flags & .Animated
						{
							anim, jaunt, anim_length := animation_data_from_hash(e.animation_hash);
							
							if e.counter > anim_length
							{
								for i : 0 .. 255
								{
									e.kf_index[i].pos = 0;
									e.kf_index[i].rot = 0;
									e.counter = 0;
								}
							}
							
							e.counter += delta;
							
							joints, an_batch := push_animation(*pb, e.animation_hash, e.counter, e.kf_index);
							e.joints = joints;
							e.an_batch = an_batch;
						}
					}
					
					// draw entities
					{
						profile_scope("Draw Entities");
						
						for e : entity_state.entities
						{
							color := COLOR_WHITE;
							if 0
							{
								if *e == hot_entity
								{
									color = COLOR_YELLOW;
								}
								if *e == active_entity
								{
									color = COLOR_BLUE;
								}
							}
							
							model := translate(Matrix4_Identity, e.pos);
							
							roll : Quaternion;
							set_from_axis_and_angle (*roll, 0, 0, -1, e.rot.z);
							pitch : Quaternion;
							set_from_axis_and_angle (*pitch, -1, 0, 0, e.rot.x);
							yaw : Quaternion;
							set_from_axis_and_angle (*yaw, 0, -1, 0, e.rot.y);
							rotation := roll * yaw * pitch;
							
							model = rotate(model, rotation);
							model = scale(model, e.size);
							
							if e.model_kind == 
							{
								case .Node_Asset;
								draw_node_asset(*pb, model, e.node_asset_hash, color, e.joints, e.an_batch);
								
								case .Cube;
								draw_cube(*pb, model, color);
							}
							
						}
					}
					
					aabb_rec :: (e : *Entity, pb : *R_Push_Buffer, hash : u128, _model : Matrix4, this_frame_hot : *bool)
					{
						node := node_from_hash(hash);
						model := _model * node.xform;
						
						if node.mesh.count
						{
							m := mesh_from_hash(node.mesh_hash);
							
							// local space -> world space
							aabb := transform_aabb(m.aabb, model);
							
							_, hit := ray_aabb_intersection(raycast, aabb);
							
							color := COLOR_WHITE;
							
							if hit
							{
								color = COLOR_RED;
								hot_entity = e;
								this_frame_hot.* = true;
								
								if is_key_pressed(.MOUSE_BUTTON_LEFT) && !is_grabbing
								{
									active_entity = e;
								}
							}
							
							draw_aabb_wireframe(pb, aabb, color);
						}
						
						if !this_frame_hot
						{
							hot_entity = null;
						}
						
						child_asset_node : *Asset;
						
						if node.first_key.count
						{
							child_asset_node = node_from_hash(node.first_hash);
						}
						
						while child_asset_node
						{
							aabb_rec(e, pb, child_asset_node.hash, model, this_frame_hot);
							
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
					
					// draw aabbs
					if boss_window.draw_aabb
					{
						for *e : entity_state.entities
						{
							model := translate(Matrix4_Identity, e.pos);
							model = scale(model, e.size);
							
							this_frame_hot : bool;
							
							if e.model_kind == 
							{
								case .Node_Asset;
								aabb_rec(e, *pb, e.node_asset_hash, model, *this_frame_hot);
								
								case .Cube;
								
								aabb := transform_aabb(cube_aabb, model);
								
								_, hit := ray_aabb_intersection(raycast, aabb);
								
								color := COLOR_WHITE;
								
								if hit
								{
									color = COLOR_RED;
									hot_entity = e;
									this_frame_hot = true;
									
									if is_key_pressed(.MOUSE_BUTTON_LEFT) && !is_grabbing
									{
										active_entity = e;
									}
								}
								
								if !this_frame_hot
								{
									hot_entity = null;
								}
								
								draw_aabb_wireframe(*pb, aabb, color);
							}
						}
					}
				}
			}
		}
		
		end_editor_window(*pb, *boss_window);
		end_widgets();
		
		pop_batch_group_sprite_params(*pb);
		r_submit(pb, win_size);
		end_render(*pb);
		
		swap_buffers(the_window);
		
		end := get_perf_counter();
		time_elapsed = (end - start) / (freq * 1.);
		delta = time_elapsed - time_since_last;
		
		reset_temporary_storage();
	}
	
	print("quit safely\n");
}