
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