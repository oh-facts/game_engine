Editor_Tab :: struct
{
	camera : Camera;
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
	
	scroll_offsets : [2]float;
	
	hacker_draw : bool;
	draw_asset : bool;
	draw_aabb : bool;
	
	current_app_mode_tab : App_Mode_Tab;
	tabs : [2]Editor_Tab;
}

Asset_Viewer_Tab :: enum
{
	Node;
	Mesh;
}

App_Mode_Tab :: enum
{
	Asset_Viewer;
	Game;
}

init_editor_window :: (title : string, pos : Vector2, size : Vector2) -> Editor_Window
{
	out : Editor_Window;
	out.title = title;
	out.pos = pos;
	out.size = size;
	out.draw_asset = true;
	out.current_app_mode_tab = .Game;
	
	// nice angle
	out.tabs[App_Mode_Tab.Asset_Viewer].camera.position = .{-2, 6.4, 8.6};
	out.tabs[App_Mode_Tab.Asset_Viewer].camera.euler_angles = .{deg_to_rad(15), deg_to_rad(32), 0};
	
	// copied the above one
	out.tabs[App_Mode_Tab.Game].camera.position = .{-2, 6.4, 8.6};
	out.tabs[App_Mode_Tab.Game].camera.euler_angles = .{deg_to_rad(15), deg_to_rad(32), 0};
	
	//out.tabs[App_Mode_Tab.Game].camera.position = .{-120, 90, 1500};
	//out.tabs[App_Mode_Tab.Game].camera.euler_angles = .{deg_to_rad(35), deg_to_rad(26), 0};
	
	return out;
}

begin_editor_window :: (window : *Editor_Window)
{
	using widget_state;
	
	root := begin_col();
	root.fixed_pos = window.pos;
	
	bar_key := make_widget_key();
	bar := widget_from_key(bar_key);
	
	begin_parent(bar);
	bar.child_axis = .X;
	
	hide_key := make_widget_key();
	hide := widget_from_key(hide_key);
	
	tabs_key := make_widget_key();
	tab := widget_from_key(tabs_key);
	begin_parent(tab);
	tab.child_axis = .X;
	
	asset_tab_key := make_widget_key();
	asset_tab := widget_from_key(asset_tab_key);
	
	game_tab_key := make_widget_key();
	game_tab := widget_from_key(game_tab_key);
	
	end_parent();
	end_parent();
	
	// styling
	asset_tab.text = "asset";
	asset_tab.size = .{140, 20};
	asset_tab.flags |= .Draw_Text | .Draw_Bg;
	asset_tab.font_size = 12;
	
	game_tab.text = "game";
	game_tab.size = .{140, 20};
	game_tab.flags |= .Draw_Text | .Draw_Bg;
	game_tab.font_size = 12;
	
	hide.text = ifx !window.hide then "v" else ">"; 
	hide.size = .{20, 20};
	hide.flags |= .Draw_Text | .Draw_Bg;
	hide.font_size = 12;
	
	// interactions
	if signal_from_widget(tab) 
	{
		window.is_dragging = true;
	}
	
	else if signal_from_widget(hide)
	{
		window.hide = !window.hide;
	}
	
	if signal_from_widget(asset_tab) 
	{
		window.current_app_mode_tab = .Asset_Viewer;
	}
	
	else if signal_from_widget(game_tab) 
	{
		window.current_app_mode_tab = .Game;
	}
	
	if window.current_app_mode_tab == .Asset_Viewer
	{
		asset_tab.active = true;
	}
	
	else if window.current_app_mode_tab == .Game
	{
		game_tab.active = true;
	}
	
	window.widget_root = root;
	
	x,y := get_mouse_pointer_position(the_window, false);
	
	if window.is_dragging
	{
		delta := Vector2.{xx x, xx y} - Vector2.{xx last_mpos_x, xx last_mpos_y};
		window.pos += delta;
		
		if !is_key_down(.MOUSE_BUTTON_LEFT)
		{
			window.is_dragging = false;
		}
	}
	
	last_mpos_x, last_mpos_y = get_mouse_pointer_position(the_window, false);
	
	{
		r_flag := widget_from_key(make_widget_key());
		
		// text alignment is a bikeshed feature
		r_flag.text = "       please enjoy each flag equally";
		r_flag.size = .{300, 20};
		r_flag.flags |= .Draw_Text | .Draw_Bg;
		r_flag.font_size = 12;
	}
	
	simple_spacer_widget(0,2);
	
	{
		// pls enjoy each flag equally
		row();
		simple_radio_widget(*window.hacker_draw);
		simple_spacer_widget(20,20);
		simple_radio_widget(*window.draw_asset);
		simple_spacer_widget(20,20);
		simple_radio_widget(*window.draw_aabb);
		simple_spacer_widget(20,20);
		simple_radio_widget(*window.hide);
	}
	
	simple_spacer_widget(0,2);
}

end_editor_window :: (pb : *R_Push_Buffer, window : *Editor_Window)
{
	end_col();
	pb.hacker_draw = window.hacker_draw;
	window.widget_root.parent = *nil_widget;
	layout_and_clip_widgets(window.widget_root);
	draw_widgets(pb, window.widget_root);
}