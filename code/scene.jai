Scene :: struct
{
	entity_state : Entity_State;
}

init_test_scene :: (using scene : *Scene)
{
	entity_state = entity_state_init();
	
	{
		po := entity_alloc(*entity_state);
		po.node_asset_hash = hash_string("watermelon_stall.root");
		set_entity_name(po, "wa'er melon s'all");
		//po.pos = .{0,101.8,0};
	}
	
	{
		po := entity_alloc(*entity_state);
		po.node_asset_hash = hash_string("cow.cow_root");
		set_entity_name(po, "moo machine");
		po.pos = .{-30, 40, -30};
	}
}