/*
I promise I won't rathole
If I rathole, I will use dearimgui instead of wasting my time making my 5th(?) ui library.

Rows, columns, fixed size and "fill space"
*/

Widget_Key :: struct
{
	v : [4]u64;
}

Widget_Flags :: enum_flags
{
	Draw_Text;
	Draw_Bg;
	Clip;
	Fixed_Size;
}

Widget_Axis :: enum
{
	X;
	Y;
}

Widget :: struct
{
	next  : *Widget;
	prev  : *Widget;
	first : *Widget;
	last  : *Widget;
	children_count : s32;
	
	parent : *Widget;
	
	child_axis : Widget_Axis;
	
	hash_next : *Widget;
	hash_prev : *Widget;
	
	meta_next : *Widget;
	
	flags : Widget_Flags;
	
	key : Widget_Key;
	hash : u128;
	
	hot : bool;
	
	text : string;
	pos : Vector2;
	size : Vector2;
	
	font_size : s32;
	fixed_pos : Vector2;
	clip_size : Vector2;
	view_offset : Vector2;
	
	final_pos : Vector2;
	final_size : Vector2;
	clipped : bool;
	
	active : bool;
	
	last_touched : u64;
}

Widget_Slot :: struct
{
	first : *Widget;
	last : *Widget;
}

Widget_State :: struct
{
	arena : *Arena;
	widget_cache : []Widget_Slot;
	parent_stack : *Widget;
	free_stack : *Widget;
	ticks : u64;
	mpos : Vector2;
}

widget_state : Widget_State;

widget_init :: ()
{
	using widget_state;
	arena = arena_init();
	widget_cache.data = push_array(arena, Widget_Slot, 256);
	widget_cache.count = 256;
}

widget_from_key :: (key : Widget_Key) -> *Widget
{
	using widget_state;
	str_key := tprint("%", key);
	hash := hash_string(str_key);
	
	slot_index := hash.U64[0] % xx widget_cache.count;
	slot := widget_cache.data + slot_index;
	
	out : *Widget;
	
	// check if widget already exists
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
		
		if !slot.first
		{
			slot.first = out;
			slot.last = out;
		}
		else
		{
			out.hash_prev = slot.last;
			slot.last.hash_next = out;
			slot.last = out;
		}
	}
	
	// what all needs to be zeroed out?
	{
		hash_next := out.hash_next;
		hash_prev := out.hash_prev;
		
		final_pos := out.final_pos;
		final_size := out.final_size;
		clipped := out.clipped;
		
		out.* = .{};
		out.hash = hash;
		out.key = key;
		out.hash_next = hash_next;
		out.hash_prev = hash_prev;
		out.final_pos = final_pos;
		out.final_size = final_size;
		out.clipped = clipped;
	}
	
	// set up hierearchy
	out.parent = parent_stack;
	
	if out.parent
	{
		out.fixed_pos = out.parent.fixed_pos;
		if !out.parent.last
		{
			out.parent.first = out;
			out.parent.last = out;
		}
		else
		{
			out.prev = out.parent.last;
			out.parent.last.next = out;
			out.parent.last = out;
		}
		out.parent.children_count += 1;
	}
	
	out.last_touched = ticks;
	
	return out;
}

make_widget_key :: (index := 0, depth : *Widget_Key = xx 0, loc := #caller_location) -> Widget_Key {
	out : Widget_Key;
	
	out.v[0] = xx index;
	out.v[1] = xx depth;
	out.v[2] = xx loc.line_number;
	
	return out;
}

row :: (index := 0, depth : *Widget_Key = xx 0, loc := #caller_location) #expand 
{
  `_start := begin_row(index, depth, loc);
	
  `defer 
	{
    _end := end_row();
  }
}

col :: (index := 0, depth : *Widget_Key = xx 0, loc := #caller_location) #expand 
{
  `_start := begin_col(index, depth, loc);
	
  `defer 
	{
    _end := end_col();
  }
}

begin_widgets :: (_mpos : Vector2)
{
	using widget_state;
	mpos = _mpos;
}

end_widgets :: ()
{
	using widget_state;
	
	assert(!parent_stack, "creating more parents than killing");
	
	for *slot : widget_cache
	{
		w := slot.first;
		
		while w
		{
			next := w.hash_next;
			
			// prune widgets
			if w.last_touched < ticks
			{
				if w.hash_prev
				{
					w.hash_prev.hash_next = w.hash_next;
				}
				else
				{
					slot.first = w.hash_next;
				}
				
				if w.hash_next
				{
					w.hash_next.hash_prev = w.hash_prev;
				}
				else
				{
					slot.last = w.hash_prev;
				}
				
				// add to freelist
				w.meta_next = free_stack;
				free_stack = w;
			}
			
			w = next;
		}
	}
	
	ticks += 1;
}

widget_layout_and_clip :: (root : *Widget)
{
	widget_layout(root);
	clip_widgets(root);
}

widget_layout :: (root : *Widget)
{
	if root.prev
	{
		if root.parent.child_axis == .X
		{
			root.pos.x += root.prev.size.x + root.prev.pos.x;
			root.pos.y = root.prev.pos.y;
		}
		else
		{
			root.pos.y += root.prev.size.y + root.prev.pos.y;
			root.pos.x = root.prev.pos.x;
		}
	}
	else
	{
		root.pos += root.parent.pos;
	}
	
	child :=  root.first;
	while child 
	{
		widget_layout(child);
		child = child.next;
	}
	
	if root.parent.child_axis == .X
	{
		root.parent.size.x += root.size.x;
		root.parent.size.y = root.size.y;
	}
	else
	{
		root.parent.size.x = root.size.x;
		root.parent.size.y += root.size.y;
	}
	/*
	*/
}

clip_widgets :: (root : *Widget)
{
	root.final_pos = root.pos + root.fixed_pos + root.parent.view_offset;;
	root.final_size = root.size;
	
	if root.parent.flags & .Clip
	{
		clip_left := root.parent.final_pos.x;
		clip_right := root.parent.final_pos.x + root.parent.clip_size.x;
		clip_top := root.parent.final_pos.y;
		clip_bottom := root.parent.final_pos.y + root.parent.clip_size.y;
		
		root_left := root.final_pos.x;
		root_right := root.final_pos.x + root.final_size.x;
		root_top := root.final_pos.y;
		root_bottom := root.final_pos.y + root.final_size.y;
		
		if (root_right <= clip_left || root_left >= clip_right ||
				root_bottom <= clip_top || root_top >= clip_bottom)
		{
			root.clipped = true;
			root.final_size = .{0, 0};
		}
		else
		{
			root.clipped = false;
			
			visible_left := max(root_left, clip_left);
			visible_right := min(root_right, clip_right);
			visible_top := max(root_top, clip_top);
			visible_bottom := min(root_bottom, clip_bottom);
			
			root.final_size.x = visible_right - visible_left;
			root.final_size.y = visible_bottom - visible_top;
			
			//root.final_pos.x = visible_left;
			//root.final_pos.y = visible_top;
		}
	}
	
	if !root.clipped
	{
		child :=  root.first;
		while child 
		{
			clip_widgets(child);
			child = child.next;
		}
	}
	
}

draw_widgets :: (pb : *R_Push_Buffer, root : *Widget)
{
	if !root.clipped
	{
		if root.flags & .Clip
		{
			params := push_batch_group_sprite_params(pb);
			
			params.scissor = rectF32(root.final_pos, root.clip_size);
		}
		
		color := COLOR_WHITE;
		
		if root.hot
		{
			color = COLOR_ORANGE;
		}
		
		if root.active
		{
			color = COLOR_RED;
		}
		
		if root.flags & .Draw_Bg
		{
			// This is a very delulu way to draw borders
			push_ui_quad(pb, root.final_pos, root.size, 0, color, get_white_square());
			push_ui_quad(pb, root.final_pos + .{1,1}, root.size - .{2,2}, 0, COLOR_BLACK, get_white_square());
		}
		
		if root.flags & .Draw_Text
		{
			// I have no idea how to properly align text
			// Somehow, adding font_size / 2 makes it fine
			// the size.y / 2 is so it aligns to its bg rect
			pos := root.final_pos;
			pos.y += root.size.y / 2 + root.font_size / 2;
			pos.x += 6;
			
			push_ui_text(pb, root.text, pos, .Delius, root.font_size, color);
		}
		
		{
			child :=  root.first;
			while child 
			{
				draw_widgets(pb, child);
				child = child.next;
			}
		}
		
		if root.flags & .Clip
		{
			pop_batch_group_sprite_params(pb);
		}
	}
}

begin_parent :: (widget : *Widget)
{
	using widget_state;
	
	widget.meta_next = parent_stack;
	parent_stack = widget;
}

end_parent :: ()
{
	using widget_state;
	parent_stack = parent_stack.meta_next;
}

begin_row :: (index := 0, depth : *Widget_Key = xx 0, loc := #caller_location) -> *Widget
{
	using widget_state;
	key := make_widget_key(index, depth, loc);
	row := widget_from_key(key);
	row.child_axis = .X;
	
	begin_parent(row);
	
	return row;
}

end_row :: ()
{
	end_parent();
}

begin_col :: (index := 0, depth : *Widget_Key = xx 0, loc := #caller_location) -> *Widget
{
	using widget_state;
	key := make_widget_key(index, depth, loc);
	row := widget_from_key(key);
	row.child_axis = .Y;
	
	begin_parent(row);
	
	return row;
}

end_col :: ()
{
	end_parent();
}

signal_from_widget :: (label : *Widget) -> bool
{
	using widget_state;
	active : bool;
	if !label.clipped
	{
		if mpos.x > xx (label.final_pos.x) && mpos.x < xx (label.final_pos.x + label.final_size.x)
		{
			if mpos.y > xx (label.final_pos.y) && mpos.y < xx (label.final_pos.y + label.final_size.y)
			{
				label.hot = true;
				
				if is_key_pressed(.MOUSE_BUTTON_LEFT)
				{
					active = true;
				}
			}
		}
	}
	return active;
}

begin_window :: (window : *Editor_Window)
{
	root := begin_col();
	root.fixed_pos = window.pos;
	
	using widget_state;
	
	bar_key := make_widget_key();
	bar := widget_from_key(bar_key);
	
	begin_parent(bar);
	bar.child_axis = .X;
	
	hide_key := make_widget_key();
	hide := widget_from_key(hide_key);
	
	title_key := make_widget_key();
	title := widget_from_key(title_key);
	
	node_view_key := make_widget_key();
	node_view := widget_from_key(node_view_key);
	
	mesh_view_key := make_widget_key();
	mesh_view := widget_from_key(mesh_view_key);
	
	end_parent();
	
	spacer := widget_from_key(make_widget_key());
	spacer.size = .{0, 2};
	
	// styling
	title.text = window.title;
	title.size = .{160, 20};
	title.flags |= .Draw_Text | .Draw_Bg;
	title.font_size = 12;
	
	hide.text = ifx window.hide then "v" else ">"; 
	hide.size = .{20, 20};
	hide.flags |= .Draw_Text | .Draw_Bg;
	hide.font_size = 12;
	
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
	
	if current_asset_viewer_tab == .Mesh
	{
		mesh_view.active = true;
	}
	
	// interactions
	if signal_from_widget(title)
	{
		window.is_dragging = true;
	}
	
	if signal_from_widget(hide)
	{
		window.hide = !window.hide;
	}
	
	if signal_from_widget(node_view)
	{
		current_asset_viewer_tab = .Node;
	}
	
	if signal_from_widget(mesh_view)
	{
		current_asset_viewer_tab = .Mesh;
	}
	
	window.widget_root = root;
	
	x,y := get_mouse_pointer_position(the_window, false);
	
	if window.is_dragging
	{
		delta := Vector2.{xx x, xx y} - Vector2.{xx last_mpos_x, xx last_mpos_y};
		window.pos += delta;
	}
	
	last_mpos_x, last_mpos_y = get_mouse_pointer_position(the_window, false);
	
	if !is_key_down(.MOUSE_BUTTON_LEFT) && window.is_dragging
	{
		window.is_dragging = false;
	}
}

end_window :: (pb : *R_Push_Buffer, window : *Editor_Window)
{
	end_col();
	
	window.widget_root.parent = *nil_widget;
	widget_layout_and_clip(window.widget_root);
	draw_widgets(pb, window.widget_root);
}

fixed_label :: (text : string, index := 0, depth : *Widget_Key = xx 0, loc := #caller_location) -> bool, *Widget
{
	using widget_state;
	key := make_widget_key(index, depth, loc);
	
	label := widget_from_key(key);
	
	label.text = text;
	label.flags |= .Draw_Text | .Draw_Bg;
	label.font_size = 16;
	label.size = .{300, 50};
	
	active := signal_from_widget(label);
	
	return active, label;
}

widget_test4 :: () -> *Widget
{
	row();
	out := _start;
	fixed_label("hi");
	
	{
		col();
		fixed_label("down1");
		fixed_label(tprint("%", _start.final_size));
		{
			col();
			fixed_label("down11");
			fixed_label("down12");
			fixed_label("down13");
			fixed_label("down14");
			fixed_label("down15");
			fixed_label(tprint("%", _start.final_size));
		}
	}
	fixed_label("hi");
	fixed_label("hi");
	fixed_label(tprint("%", out.final_size));
	return out;
}

widget_test :: () -> *Widget
{
	col();
	out := _start;
	
	fixed_label("1");
	{
		col();
		fixed_label("2");
		fixed_label("3");
	}
	fixed_label("4");
	
	return out;
}

widget_test2 :: () -> *Widget
{
	row();
	out := _start;
	
	fixed_label("1");
	{
		col();
		fixed_label("2");
		fixed_label("3");
	}
	fixed_label("4");
	
	return out;
}

widget_test3 :: () -> *Widget
{
	col();
	out := _start;
	
	fixed_label("1");
	{
		col();
		fixed_label("2");
		fixed_label("3");
	}
	fixed_label("4");
	
	return out;
}

Editor_Window :: struct
{
	title : string;
	pos : Vector2;
	size : Vector2;
	mouse_last_pos : Vector2;
	is_dragging : bool;
	hide : bool;
	widget_root : *Widget;
	counter : f32;
}

init_editor_window :: (title : string, pos : Vector2, size : Vector2) -> Editor_Window
{
	out : Editor_Window;
	out.title = title;
	out.pos = pos;
	out.size = size;
	
	return out;
}

nil_widget : Widget;

update_asset_viewer_window :: (window : *Editor_Window, delta : float, pb : *R_Push_Buffer)
{
	window.counter += delta;
	entity_widget_root := *nil_widget;
	placer_widget_root := *nil_widget;
	
	new_context := context;
	push_context new_context
	{
		{
			col();
			entity_widget_root = _start;
			
			format_float := *context.print_style.default_format_float;
			format_float.trailing_width = 1;
			
			if active_entity
			{
				txt := tprint("pos: % % %", active_entity.pos.x, active_entity.pos.y, active_entity.pos.z);
				fixed_label(txt);
				
				rot : Vector3i;
				rot.x = xx rad_to_deg(active_entity.rot.x);
				rot.y = xx rad_to_deg(active_entity.rot.y);
				rot.z = xx rad_to_deg(active_entity.rot.z);
				
				rot.x %= 360;
				rot.y %= 360;
				rot.z %= 360;
				
				txt = tprint("rot: % % %", rot.x, rot.y, rot.z);
				fixed_label(txt);
				
				txt = tprint("size: % % %", active_entity.size.x, active_entity.size.y, active_entity.size.z);
				fixed_label(txt);
			}
		}
		
		//if false 
		{
			begin_window(window);
			
			if window.hide
			{
				
				{
					col();
					placer_widget_root = _start;
					
					view_offset : Vector2;
					view_offset.y += wheel_delta;
					
					placer_widget_root.view_offset = view_offset;
					placer_widget_root.clip_size = window.size;
					placer_widget_root.flags |= .Clip;
					
					asset_index : int;
					
					if current_asset_viewer_tab == 
					{
						case .Mesh;
						
						for slot : asset_store.meshes
						{
							asset := slot.first;
							while asset
							{
								active, widg := fixed_label(tprint("%", asset.key), asset_index);
								
								if active_node_asset_hash == asset.hash
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
							set_from_axis_and_angle (*yaw, 0, -1, 0, window.counter);
							push_mesh(pb, rotation_matrix(Matrix4, yaw), active_mesh_asset_hash);
						}
						
						case .Node;
						for slot : asset_store.nodes
						{
							asset := slot.first;
							while asset
							{
								if !asset.parent_key.count
								{
									active, widg := fixed_label(tprint("%", asset.key), it_index);
									
									if active_node_asset_hash == asset.hash
									{
										widg.active = true;
									}
									
									if active
									{
										active_node_asset_hash = asset.hash;
									}
								}
								
								asset = asset.hash_next;
							}
						}
						
						if active_node_asset_hash.U64[0]
						{
							yaw : Quaternion;
							set_from_axis_and_angle (*yaw, 0, -1, 0, window.counter);
							push_mesh_node(pb, rotation_matrix(Matrix4, yaw), active_node_asset_hash);
						}
						
					}
				}
			}
			end_window(pb, window);
		}
	}
	
	entity_widget_root.parent = *nil_widget;
	widget_layout_and_clip(entity_widget_root);
	draw_widgets(pb, entity_widget_root);
}

last_mpos_x, last_mpos_y : int;

current_asset_viewer_tab : Asset_Viewer_Tab;

Asset_Viewer_Tab :: enum
{
	Node;
	Mesh;
}