draw_mesh_asset :: (pb : *R_Push_Buffer, model : Matrix4, hash : u128, tint := COLOR_WHITE, joints : *Matrix4 = xx 0, an_batch : *Batch = xx 0)
{
	a_mesh := mesh_from_hash(hash);
	
	for 0 .. a_mesh.num_primitives - 1
	{
		r_mesh :*R_Mesh = xx push_batch(*pb.mesh_batches, size_of(R_Mesh), xx MB(1));
		a_prim := a_mesh.primitives + it;
		
		r_mesh.start = a_prim.start;
		r_mesh.count = a_prim.count;
		
		r_mesh.xform = model;
		
		r_mesh.vertex_buffer = a_mesh.vertex_buffer;
		r_mesh.index_buffer = a_mesh.index_buffer;
		
		color, color_map := material_data_from_hash(a_prim.material_hash);
		
		if color == .{}
		{
			r_mesh.color = .{1, 1, 1, 1};
		}
		else
		{
			r_mesh.color = color;
		}
		
		r_mesh.color *= tint;
		
		if color_map.U64[0]
		{
			r_mesh.color_map = tex_id_from_handle(color_map);
		}
		else
		{
			r_mesh.color_map = tex_id_from_handle(get_white_square());
		}
		
		if joints
		{
			r_mesh.flags |= .Animated;
			//r_mesh.skinning_xform_batch = pb.skinning_xforms.last;
			r_mesh.base_skinning_xform = joints;
			r_mesh.skinning_xform_batch = an_batch;
		}
	}
}

draw_node_asset :: (pb : *R_Push_Buffer, model : Matrix4, hash : u128, tint := COLOR_WHITE, joints : *Matrix4 = xx 0, an_batch : *Batch = xx 0)
{
	root_node := node_from_hash(hash);
	computed_model := model * root_node.xform;
	
	// uncomment to see a funfun
	// computed_model = root_node.xform * model;
	
	if root_node.mesh.count
	{
		draw_mesh_asset(pb, computed_model, root_node.mesh_hash, tint, joints, an_batch);
	}
	
	child_asset_node : *Asset;
	
	if root_node.first_key.count
	{
		child_asset_node = node_from_hash(root_node.first_hash);
	}
	
	while child_asset_node
	{
		draw_node_asset(pb, computed_model, child_asset_node.hash, tint, joints, an_batch);
		
		if child_asset_node.next_key.count
		{
			child_asset_node = node_from_hash(child_asset_node.next_hash);
		}
		else
		{
			break;
		}
	}
}

draw_node_asset_aabb :: (pb : *R_Push_Buffer, hash : u128, _model : Matrix4)
{
	node := node_from_hash(hash);
	model := _model * node.xform;
	
	if node.mesh.count
	{
		draw_mesh_asset_aabb(pb, node.mesh_hash, model);
	}
	
	child_asset_node : *Asset;
	
	if node.first_key.count
	{
		child_asset_node = node_from_hash(node.first_hash);
	}
	
	while child_asset_node
	{
		draw_node_asset_aabb(pb, child_asset_node.hash, model);
		
		if child_asset_node.next_key.count
		{
			child_asset_node = node_from_hash(child_asset_node.next_hash);
		}
		else
		{
			break;
		}
	}
}

draw_mesh_asset_aabb :: (pb : *R_Push_Buffer, hash : u128, model : Matrix4)
{
	m := mesh_from_hash(hash);
	
	using m.aabb;
	
	edges : [12][2]Vector3;
	
	edges[0] = .[.{min.x, min.y, min.z}, .{min.x, min.y, max.z}];
	edges[1] = .[.{min.x, min.y, min.z}, .{min.x, max.y, min.z}];
	edges[2] = .[.{min.x, min.y, min.z}, .{max.x, min.y, min.z}];
	edges[3] = .[.{min.x, min.y, max.z}, .{min.x, max.y, max.z}];
	edges[4] = .[.{min.x, min.y, max.z}, .{max.x, min.y, max.z}];
	edges[5] = .[.{min.x, max.y, min.z}, .{min.x, max.y, max.z}];
	edges[6] = .[.{min.x, max.y, min.z}, .{max.x, max.y, min.z}];
	edges[7] = .[.{min.x, max.y, max.z}, .{max.x, max.y, max.z}];
	edges[8] = .[.{max.x, min.y, min.z}, .{max.x, min.y, max.z}];
	edges[9] = .[.{max.x, min.y, min.z}, .{max.x, max.y, min.z}];
	edges[10] = .[.{max.x, min.y, max.z}, .{max.x, max.y, max.z}];
	edges[11] = .[.{max.x, max.y, min.z}, .{max.x, max.y, max.z}];
	
	// local space -> world space and drawing
	for edge : edges
	{
		for *edge
		{
			<< it = (model * .{it.x, it.y, it.z, 1}).xyz;
		}
		push_debug_line(pb, edge[0], edge[1], COLOR_WHITE);
	}
}