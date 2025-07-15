
deg_to_rad :: inline (d : float) -> float
{
	return d * PI / 180.;
}

rad_to_deg :: inline (r : float) -> float
{
	return r * 180 / PI;
}

Handle :: struct {
	U64 : [2]u64;
}

Vector2i :: struct {
	x : s32;
	y : s32;
}

operator == :: (a : Vector2i, b : Vector2i) -> bool {
	return ((a.x == b.x) && (a.y == b.y));
}

operator -= :: (a : *Vector2i, b : Vector2i) {
	a.x -= b.x;
	a.y -= b.y;
}

operator + :: (a : Vector2i, b : Vector2i) -> Vector2i {
	out : Vector2i;
	out.x = a.x + b.x;
	out.y = a.y + b.y;
	return out;
}

operator - :: (a : Vector2i, b : Vector2i) -> Vector2i {
	out : Vector2i;
	out.x = a.x - b.x;
	out.y = a.y - b.y;
	return out;
}

distance_squared :: inline (a: Vector2i, b: Vector2i) -> s32 {
	dx := b.x - a.x;
	dy := b.y - a.y;
	
	return dx*dx + dy*dy;
}

Vector3i :: struct {
	x : s32;
	y : s32;
	z: s32;
}

operator + :: (a : Vector3i, b : Vector3i) -> Vector3i {
	out : Vector3i;
	out.x = a.x + b.x;
	out.y = a.y + b.y;
	out.z = a.z + b.z;
	return out;
}

operator - :: (a : Vector3i, b : Vector3i) -> Vector3i {
	out : Vector3i;
	out.x = a.x - b.x;
	out.y = a.y - b.y;
	out.z = a.z - b.z;
	return out;
}

RectF32 :: struct 
{
	min : Vector2;
	max : Vector2;
	size : Vector2;
};

rectF32 :: (min_x : float32, min_y : float32, max_x : float32, max_y : float32) -> RectF32 {
	out : RectF32;
	
	out.min.x = min_x;
	out.min.y = min_y;
	
	out.max.x = max_x;
	out.max.y = max_y;
	
	out.size.x = max_x - min_x;
	out.size.y = max_y - min_y;
	
	return out;
}

rectF32 :: (pos : Vector2, size : Vector2) -> RectF32 {
	out : RectF32;
	
	out.min = pos;
	out.size = size;
	out.max = pos + size;
	
	return out;
}

point_in_rect :: (point : Vector2, rect : RectF32) -> bool{
	out : bool;
	
	if (point.x > rect.min.x) && (point.y > rect.min.y) && (point.x < rect.max.x) && (point.y < rect.max.y) {
		out = true;
	}
	
	return out;
}

Transform :: struct
{
	pos : Vector3;
	rot : Quaternion;
	scale : Vector3;
}

matrix_from_transform :: (t : Transform) -> Matrix4
{
	mat := Matrix4_Identity;
	mat = translate(mat, t.pos);
	mat = rotate(mat, t.rot);
	mat = scale(mat, t.scale);
	return mat;
}

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

Plane :: struct
{
	d : float;
	n : Vector3;
	double_sided : bool;
}

ray_plane_intersection :: (ray : Ray, plane : Plane) -> float
{
	nd := dot(ray.dir, plane.n);
	pn := dot(ray.o, plane.n);
	
	if !plane.double_sided
	{
		if (nd >= 0) {
			return -1;
		}
	}
	
	t := (plane.d - pn) / nd;
	
	if (t >= 0) {
		return t;
	}
	return -1;
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

deg_rot_from_rad_rot :: (rad : Vector3) -> Vector3i
{
	rot : Vector3i;
	rot.x = cast(s32) ((xx rad_to_deg(rad.x)) % 360 + 360) % 360;
	rot.y = cast(s32) ((xx rad_to_deg(rad.y)) % 360 + 360) % 360;
	rot.z = cast(s32) ((xx rad_to_deg(rad.z)) % 360 + 360) % 360;
	
	return rot;
}
