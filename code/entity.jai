Entity_Flags :: enum_flags
{
	Animated;
	Freed;
}

Entity_Model_Kind :: enum
{
	Node_Asset;
	Cube;
}

Entity :: struct
{
	// 32 chars
	// its a string view here
	short_name : string;
	short_name_memory : [32]u8;
	
	flags : Entity_Flags;
	kf_index : []Key_Frame_Index;
	counter : float;
	pos : Vector3;
	size : Vector3;
	rot : Vector3;
	animation_hash : u128;
	node_asset_hash : u128;
	model_kind : Entity_Model_Kind;
	
	// per frame artifacts
	joints : *Matrix4;
	an_batch : *Batch;
	
	// editor
	expanded : bool;
	
	free_next : *Entity;
	
	color : Vector3;
}

/*
Entity_Batch :: struct
{
	max :: 1024; 
	entities : [max]Entity; // set to zero so you can loop nicely
	next : *Entity_List;
}

Entity_List :: struct
{
	first : *Entity_Batch;
	last : *Entity_Batch;
	count : int;
}
*/

Entity_State :: struct
{
	arena : *Arena;
	
	entities : *Entity;
	used_entities_count : int;
	
	max_entities :: 1024;
	
	free_entities : *Entity;
	free_entities_count : int;
	gen_count : int;
}

get_active_entities_count :: (using es : Entity_State) -> int
{
	return used_entities_count - free_entities_count;
}

// [256]
entity_state_init :: () -> Entity_State
{
	out : Entity_State;
	using out;
	
	arena = arena_init();
	entities = push_array(arena, Entity, max_entities);
	
	return out;
}

// TODO(mizu): Finish this.

entity_alloc :: (using entity_state : *Entity_State) -> *Entity
{
	assert(used_entities_count < max_entities);
	
	out := free_entities;
	
	if out
	{
		sll_pop(*free_entities, *free_entities.free_next);
		free_entities_count -= 1;
		out.* = .{};
	}
	else
	{
		out = entities + used_entities_count;
		used_entities_count += 1;
	}
	
	out.size = .{1,1,1};
	out.short_name.data = out.short_name_memory.data;
	out.model_kind = .Cube;
	out.color = .{1,1,1};
	
	set_entity_name(out, tprint("%", gen_count));
	
	gen_count += 1;
	return out;
}

sll_push :: (stack : $T, node : T, node_next : T) #expand
{
	node_next.* = stack.*;
	stack.* = node.*;
}

sll_pop :: (stack : $T, stack_next : T) #expand
{
	stack.* = stack_next.*;
}

for_expansion :: (using es : Entity_State, body: Code, flags: For_Flags) #expand
{
	for i : 0 .. used_entities_count - 1
	{
		entity := entities + i; 
		`it := entity;
		`it_index := i;
		
		if !(entity.flags & .Freed)
		{
#insert body;
		}
		
	}
}

entity_free :: (using entity_state : *Entity_State, entity : *Entity)
{
	entity.flags |= .Freed;
	sll_push(*free_entities, *entity, *entity.free_next);
	free_entities_count += 1;
	ooga : int;
}

// still bug when setting name
// actually I think it happened before I pressed enter?
// it happened after
// also, editing the 4th entity, affected the 3rd entity
// and made the 4th entity corrupted

set_entity_name :: (e : *Entity, name : string)
{
	// names are u8
	// Will this be annoying once I have other languages?
	// Probably but its ok for now. I can't even render utf 32 text rn.
	
	count := min(e.short_name_memory.count, name.count);
	
	memcpy(e.short_name_memory.data, name.data, count);
	e.short_name.count = count;
}