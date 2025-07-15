f32 :: float32;
f64 :: float64;

u128 :: struct 
{
	U64 : [2]u64;
};

COLOR_WHITE :: Vector4.{1, 1, 1, 1};
COLOR_BLACK :: Vector4.{0, 0, 0, 1};

COLOR_RED :: Vector4.{1, 0, 0, 1};
COLOR_GREEN :: Vector4.{0, 1, 0, 1};
COLOR_BLUE :: Vector4.{0, 0, 1, 1};
COLOR_YELLOW :: Vector4.{1, 1, 0, 1};
COLOR_CYAN :: Vector4.{0, 1, 1, 1};
COLOR_MAGENTA :: Vector4.{1, 0, 1, 1};

COLOR_ORANGE :: Vector4.{0.79, 0.33, 0, 1};

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

operator == :: (a : u128, b : u128) -> bool {
	return ((a.U64[0] == b.U64[0]) && (a.U64[1] == b.U64[1]));
}

KB :: (v : u64) -> u64 #expand {
	return v * 1024;
}

MB :: (v : u64) -> u64 #expand {
	return KB(v) * 1024;
}

GB :: (v : u64) -> u64 #expand {
	return MB(v) * 1024;
}

TB :: (v : u64) -> u64 #expand {
	return GB(v) * 1024;
}

is_pow_2 :: (addr : u64) -> bool #expand{
	return (addr & (addr-1)) == 0;
}

align_pow_2 :: (x: u64, b: u64) -> u64 #expand{
	return (((x) + (b) - 1)&(~((b) - 1)));
}

clamp_top :: (a : $A, x : A) -> A #expand {
	return min(a,x);
}

clamp_bot :: (x : $X, b : X) -> X #expand {
	return max(x,b);
}

max :: (a : float32, b : float32) -> float32 {
	if a > b {
		return a;
	} else {
		return b;
	}
}

ARENA_COMMIT_SIZE :: #run KB(64);
ARENA_RESERVE_SIZE :: #run MB(64);
ARENA_HEADER_SIZE :: 128;
DEFAULT_ALIGN :: size_of(*void);

Arena :: struct {
	used : u64;
	align: u64;
	cmt : u64;
	res : u64;
};

arena_init :: (cmt := ARENA_COMMIT_SIZE, res := ARENA_RESERVE_SIZE) -> *Arena {
	out : *Arena;
	
	page_size := get_page_size();
	res = align_pow_2(res, page_size);
	cmt = align_pow_2(cmt, page_size);
	
	memory := reserve(res);
	commit(memory, cmt);
	
	out = xx memory;
	out.used = ARENA_HEADER_SIZE;
	out.align = DEFAULT_ALIGN;
	
	out.cmt = cmt;
	out.res = res;
	
	return out;
}

arena_push_bytes :: (arena : *Arena, size : u64) -> *void {
	pmem := align_pow_2(arena.used, arena.align);
	pnew := pmem + size;
	
	if(arena.res < pnew)
	{
		// TODO(mizu): deal with reserving more (chain arenas)
		// I am not too keen on working on this because I can always reserve more, but I think it will be good for robustness so it can handle arbitrary sizes without me having to increasing reserve size and recompiling. (Argument is a bit weak because 64 bit processes have an insanely large virtual address space.)
		assert(false);
	}
	
	if(arena.cmt < pnew)
	{
		cmt_new_aligned, cmt_new_clamped, cmt_new_size : u64;
		
		cmt_new_aligned = align_pow_2(pnew, ARENA_COMMIT_SIZE);
		cmt_new_clamped = clamp_top(cmt_new_aligned, arena.res);
		cmt_new_size    = cmt_new_clamped - arena.cmt;
		commit(cast(*u8)arena + arena.cmt, cmt_new_size);
		arena.cmt = cmt_new_clamped;
	}
	
	memory : *void;
	
	if (arena.cmt >= pnew)
	{
		memory = cast(*u8)arena + pmem;
		arena.used = pnew;
	}
	
	return memory;
}

arena_free :: (arena : *Arena) {
	release(arena, arena.res);
}

push_struct :: (arena : *Arena, type : Type) -> *void #expand{
	return arena_push_bytes(arena, size_of(type));
}

push_array :: (arena : *Arena, type : Type, count : u64) -> *void #expand{
	return arena_push_bytes(arena, size_of(type) * count);
}

// Isn't zeroed!
tpush_struct :: (type : Type) -> *void #expand {
	return talloc(size_of(type));
}

tpush_array :: (type : Type, count : s64) -> *void #expand {
	return talloc(size_of(type) * count);
}

tzpush_array :: (type : Type, count : s64) -> *void #expand {
	out := talloc(size_of(type) * count);
	memset(out, 0, size_of(type));
	return out;
}

tzpush_struct :: (type : Type) -> *void #expand{
	out := tpush_struct(type);
	memset(out, 0, size_of(type));
	return out;
}

str_from_cstr :: (cstr : *u8, zero_terminate : bool = false) -> string
{
	uri_str : string;
	uri_str.data = cstr;
	
	c := uri_str.data[0];
	index : int;
	
	while c != #char "\0" 
	{
		c = uri_str.data[index];
		index += 1;
	}
	
	if !zero_terminate
	{
		index -= 1;
	}
	
	uri_str.count = index;
	
	return uri_str;
}

hash_string :: (data : string) -> u128 {
	
#asm { hash: vec; }
	
	MeowHash(MeowDefaultSeed, xx data.count, data.data, hash);
	
	out : u128;
	out.U64[0] = MeowU64From(hash, 0);
	out.U64[1] = MeowU64From(hash, 1);
	
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

reserve :: (size : u64) -> *void
{
	out := VirtualAlloc(xx 0, size, MEM_RESERVE, PAGE_READWRITE);
	assert(xx out);
	return xx out;
}

commit :: (ptr : *void, size : u64) -> bool
{
	out := VirtualAlloc(ptr, size, MEM_COMMIT, PAGE_READWRITE);
	assert(xx out);
	return xx out;
}

decommit :: (ptr : *void, size : u64)
{
	VirtualFree(ptr, size, MEM_DECOMMIT);
}

release :: (ptr : *void, size : u64)
{
	VirtualFree(ptr, 0, MEM_RELEASE);
}

get_page_size :: () -> u64
{
	sysinfo : SYSTEM_INFO;
	GetSystemInfo(*sysinfo);
	return sysinfo.dwPageSize;
}

get_perf_counter :: () -> s64
{
	counter : s64;
	QueryPerformanceCounter(*counter);
	return counter;
}

get_perf_freq :: () -> s64
{
	frequency : s64;
	QueryPerformanceFrequency(*frequency);
	return frequency;
}

sleep :: (ms : s32)
{
	Sleep(ms);
}