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
		
		out.* = .{};
		out.hash = hash;
		out.key = key;
		out.hash_next;
		out.hash_prev;
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

make_widget_key :: (index := 0, depth :*Widget_Key = xx 0, loc : Source_Code_Location) -> Widget_Key {
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

begin_widgets :: ()
{
	using widget_state;
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

widget_layout :: (root : *Widget)
{
	if root.parent
	{
		root.pos += root.parent.pos;
	}
	
	if root.prev
	{
		if root.parent.child_axis == .X
		{
			root.pos.x += root.prev.size.x + root.prev.pos.x;
		}
		else
		{
			root.pos.y += root.prev.size.y + root.prev.pos.y;
		}
	}
	
	child :=  root.first;
	while child 
	{
		widget_layout(child);
		child = child.next;
	}
	
	if root.parent
	{
		root.parent.size = root.size;
	}
}

draw_widgets :: (pb : *R_Push_Buffer, root : *Widget)
{
	pos := root.pos + root.fixed_pos;
	
	if root.flags & .Draw_Bg
	{
		// This is a very delulu way to draw borders
		push_ui_quad(pb, pos, root.size, 0, COLOR_WHITE, get_white_square());
		push_ui_quad(pb, pos + .{1,1}, root.size - .{2,2}, 0, COLOR_BLACK, get_white_square());
	}
	
	if root.flags & .Draw_Text
	{
		// I have no idea how to properly align text
		// Somehow, adding font_size / 2 makes it fine
		// the size.y / 2 is so it aligns to its bg rect
		
		pos.y += root.size.y / 2 + root.font_size / 2;
		pos.x += 6;
		push_ui_text(pb, root.text, pos, .Delius, root.font_size, COLOR_WHITE);
	}
	
	{
		child :=  root.first;
		while child 
		{
			draw_widgets(pb, child);
			child = child.next;
		}
	}
}

begin_row :: (index := 0, depth : *Widget_Key = xx 0, loc := #caller_location) -> *Widget
{
	using widget_state;
	key := make_widget_key(index, depth, loc);
	row := widget_from_key(key);
	row.child_axis = .X;
	
	row.meta_next = parent_stack;
	parent_stack = row;
	return row;
}

end_row :: ()
{
	using widget_state;
	parent_stack = parent_stack.meta_next;
}

begin_col :: (index := 0, depth : *Widget_Key = xx 0, loc := #caller_location) -> *Widget
{
	using widget_state;
	key := make_widget_key(index, depth, loc);
	row := widget_from_key(key);
	row.child_axis = .Y;
	
	row.meta_next = parent_stack;
	parent_stack = row;
	return row;
}

end_col :: ()
{
	using widget_state;
	parent_stack = parent_stack.meta_next;
}

fixed_label :: (text : string, index := 0, depth : *Widget_Key = xx 0, loc := #caller_location)
{
	key := make_widget_key(index, depth, loc);
	
	label := widget_from_key(key);
	
	label.text = text;
	label.flags |= .Draw_Text | .Draw_Bg;
	label.font_size = 16;
	label.size = .{300, 50};
}