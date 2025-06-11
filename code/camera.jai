Camera :: struct
{
	speed := 4.0;
	ROTATION_SPEED :: 0.3;
	ROTATION_SMOOTHING :: 0.3;
	
	position : Vector3;
	euler_angles : Vector3;
	rotation : Quaternion;
	rotation_input : Vector2;
	fov := 60.0;
	transform := Matrix4_Identity;
	
	viewport : Vector2;
	
	control : bool;
}

update_2d_camera :: (using camera : *Camera, delta : float, _viewport : Vector2)
{
	viewport = _viewport;
}

update_flying_camera :: (using camera : *Camera, delta_time : float, vp : Vector2)
{
	viewport = vp;
	
	mouse_delta : Vector2;
	move_input  : Vector3;
	move_speed  : float;
	
	if control 
	{
		x, y, w, h := get_dimensions (the_window, false);
		user32 :: #system_library "User32";
		SetCursorPos :: (x : s32, y : s32) -> s32 #foreign user32;
		SetCursorPos (w / 2, h / 2);
	}
	
	if is_key_pressed(.TAB) 
	{
		toggle_cursor(xx control);
		control = !control;
	}
	
	if control 
	{
		move_speed = speed;
		mouse_delta = xy (xx mouse_delta_x, xx mouse_delta_y);
		if is_key_down (.SHIFT) then move_speed *= 10;
		move_speed *= delta_time;
		move_input.x = cast (float) is_key_down (xx #char "D")
			- cast (float) is_key_down (xx #char "A");
		move_input.y = cast (float) is_key_down (xx #char "E")
			- cast (float) is_key_down (xx #char "Q");
		move_input.z = cast (float) is_key_down (xx #char "S")
			- cast (float) is_key_down (xx #char "W");
		move_input = rotate (unit_vector (move_input), rotation);
	}
	position += move_input * move_speed;
	
	//position.y = 0.15;
	
	rotation_input = lerp (rotation_input, mouse_delta, ROTATION_SMOOTHING);
	delta := rotation_input * ROTATION_SPEED;
	euler_angles.x += delta.x * PI / 180.0;
	euler_angles.y += delta.y * PI / 180.0;
	euler_angles.y = clamp (euler_angles.y, -80.0  * PI / 180.0, 80.0 * PI / 180.0);
	yaw : Quaternion;
	// I am not sure why I need to invert the axis of rotation...
	// nor am I jon (or whoever else at thekla who on this)
	set_from_axis_and_angle (*yaw, 0, -1, 0, euler_angles.x);
	pitch : Quaternion;
	set_from_axis_and_angle (*pitch, -1, 0, 0, euler_angles.y);
	rotation = yaw * pitch;
	
	transform = make_translation_matrix4 (position) * rotation_matrix (Matrix4, rotation);
}

get_ortho_proj_and_view_matrix :: (camera : Camera) -> Matrix4, Matrix4
{
	aspect_ratio := (camera.viewport.x * 1.) / camera.viewport.y;
	
	proj := orthographic_projection_matrix(-camera.viewport.x, camera.viewport.x, -camera.viewport.y, camera.viewport.y, 0, 1);
	view := make_look_at_matrix(camera.position, camera.position + .{0, 0, -1}, .{0, 1, 0}, false);
	
	return proj, view;
}

get_perspective_proj_and_view_matrix :: (using camera : Camera) -> Matrix4, Matrix4
{
	view_matrix := inverse (transform);
	
	aspect_ratio := viewport.x / cast (float) viewport.y;
	projection_matrix := make_projection_matrix (fov * PI / 180.0, aspect_ratio, 0.1, 1000.0);
	
	return projection_matrix, view_matrix;
}