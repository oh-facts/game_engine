// Make a camera system

// n: tl, tr, bl, br
// f: tl, tr, bl, br
/*
-1, -1, -1,
-1, -1, 1,
-1, 1, -1,
-1, 1, 1,
1, -1, -1,
1, -1, 1,
1, 1, -1,
 1, 1, 1
*/

control_camera : bool;

Frustum :: union
{
	using idk_what_to_call_this : struct
	{
		near_top_left : Vector3;
		near_top_right : Vector3;
		near_bottom_left : Vector3;
		near_bottom_right : Vector3;
		
		far_top_left : Vector3;
		far_top_right : Vector3;
		far_bottom_left : Vector3;
		far_bottom_right : Vector3;
	};
	
	v : [8]Vector3;
}

get_perspective_frustum :: (matrix : Matrix4) -> Frustum
{
	using out : Frustum;
	near_top_left = .{-1, 1, 1};
	near_top_right = .{1, 1, 1};
	near_bottom_left = .{-1, -1, 1};
	near_bottom_right = .{1, -1, 1};
	
	far_top_left = .{-1, 1, 0};
	far_top_right = .{1, 1, 0};
	far_bottom_left = .{-1, -1, 0};
	far_bottom_right = .{1, -1, 0};
	
	for *out.v
	{
		it_v4 := Vector4.{it.x, it.y, it.z, 1};
		it_v4 = matrix * it_v4;
		it_v4 /= it_v4.w;
		
		it.* = it_v4.xyz;
	}
	
	return out;
}

operator * :: (a : Matrix4, b : Frustum) -> Frustum 
{
	out := b;
	
	for *out.v
	{
		it_v4 := Vector4.{it.x, it.y, it.z, 1};
		it_v4 = a * it_v4;
		
		it.* = it_v4.xyz;
	}
	
	return out;
}

aabb_from_frustum :: (f : Frustum) -> AABB
{
	out : AABB;
	
	for f.v
	{
		out.min.x = min(it.x, out.min.x);
		out.min.y = min(it.y, out.min.y);
		out.min.z = min(it.z, out.min.z);
		
		out.max.x = max(it.x, out.max.x);
		out.max.y = max(it.y, out.max.y);
		out.max.z = max(it.z, out.max.z);
	}
	
	return out;
}

Camera :: struct
{
	speed := 4.0;
	ROTATION_SPEED :: 0.3;
	ROTATION_SMOOTHING :: 0.3;
	
	position : Vector3;
	euler_angles : Vector3;
	rotation : Quaternion;
	rotation_input : Vector2;
	fov := 45.0;
	transform := Matrix4_Identity;
	
	viewport : Vector2;
	
	mouse_delta : Vector2;
	move_input  : Vector3;
	move_speed  : float;
	
	proj : Matrix4;
	view : Matrix4;
	
	frustum : Frustum;
	
	near : float = 1.0;
	far : float = 100;
}

update_2d_camera :: (using camera : *Camera, delta : float, _viewport : Vector2)
{
	viewport = _viewport;
	
	aspect_ratio := (camera.viewport.x * 1.) / camera.viewport.y;
	
	proj = orthographic_projection_matrix(0, camera.viewport.x, camera.viewport.y, 0, 0, 1, true);
	view = make_look_at_matrix(camera.position, camera.position + .{0, 0, -1}, .{0, 1, 0}, false);
}

update_camera_controls :: (using camera : *Camera, delta_time : float)
{
	x, y, w, h := get_dimensions (the_window, false);
	user32 :: #system_library "User32";
	SetCursorPos :: (x : s32, y : s32) -> s32 #foreign user32;
	SetCursorPos (w / 2, h / 2);
	
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
	
	rotation_input = lerp (rotation_input, mouse_delta, ROTATION_SMOOTHING);
}

update_flying_camera :: (using camera : *Camera, delta_time : float, vp : Vector2)
{
	viewport = vp;
	
	position += move_input * move_speed;
	
	//position.y = 0.15;
	
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
	
	view = inverse (transform);
	//view = make_look_at_matrix(.{3, 5, -31}, .{3, 5, -31} + .{0, -0.09950, 0.995037}, .{0, 1, 0}, false);
	
	aspect_ratio := viewport.x / cast (float) viewport.y;
	proj = make_projection_matrix (fov * PI / 180.0, aspect_ratio, far, near, depth_range_01 = true);
	//proj = make_inf_proj_matrix (fov * PI/180, aspect_ratio, 0.1);
	
	clip_to_world := inverse(proj * view);
	
	frustum = get_perspective_frustum(clip_to_world);
	//frustum = get_perspective_frustum(clip_to_cam);
	
	boo : int;
}

draw_frustum :: (using frustum : Frustum, pb : *R_Push_Buffer)
{
	push_debug_line(pb, near_bottom_left, near_bottom_right, COLOR_GREEN);
	push_debug_line(pb, near_bottom_right, near_top_right, COLOR_GREEN);
	push_debug_line(pb, near_top_right, near_top_left, COLOR_GREEN);
	push_debug_line(pb, near_top_left, near_bottom_left, COLOR_GREEN);
	
	push_debug_line(pb, far_bottom_left, far_bottom_right, COLOR_RED);
	push_debug_line(pb, far_bottom_right, far_top_right, COLOR_RED);
	push_debug_line(pb, far_top_right, far_top_left, COLOR_RED);
	push_debug_line(pb, far_top_left, far_bottom_left, COLOR_RED);
	
	push_debug_line(pb, near_bottom_left, far_bottom_left, .{1, 1, 1, 1});
	push_debug_line(pb, near_bottom_right, far_bottom_right, .{1, 1, 1, 1});
	push_debug_line(pb, near_top_right, far_top_right, .{1, 1, 1, 1});
	push_debug_line(pb, near_top_left, far_top_left, .{1, 1, 1, 1});
}

// https://nlguillemot.wordpress.com/2016/12/07/reversed-z-in-opengl/
make_inf_proj_matrix :: (fovY_radians : float, aspectWbyH : float, zNear : float ) -> Matrix4
{
	f := 1.0 / tan(fovY_radians / 2.0);
	out : Matrix4;
	out._11 = f / aspectWbyH;
	out._22 = f;
	out._43 = -1.0;
	out._34 = zNear;
	return out;
}