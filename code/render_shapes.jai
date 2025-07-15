r_shapes_init :: ()
{
	vertices :[36]Vertex;
	index := 0;
	
	// Front Face
	cube_vertex_helper(vertices, .{0.5, 0.5, 0.5}, *index);
	cube_vertex_helper(vertices, .{-0.5, 0.5, 0.5}, *index);
	cube_vertex_helper(vertices, .{-0.5, -0.5, 0.5}, *index);
	
	cube_vertex_helper(vertices, .{0.5, 0.5, 0.5}, *index);
	cube_vertex_helper(vertices, .{-0.5, -0.5, 0.5}, *index);
	cube_vertex_helper(vertices, .{0.5, -0.5, 0.5}, *index);
	
	// Back Face
	cube_vertex_helper(vertices, .{-0.5, -0.5, -0.5}, *index);
	cube_vertex_helper(vertices, .{-0.5, 0.5, -0.5}, *index);
	cube_vertex_helper(vertices, .{0.5, 0.5, -0.5}, *index);
	
	cube_vertex_helper(vertices, .{0.5, -0.5, -0.5}, *index);
	cube_vertex_helper(vertices, .{-0.5, -0.5, -0.5}, *index);
	cube_vertex_helper(vertices, .{0.5, 0.5, -0.5}, *index);
	
	// Top Face
	cube_vertex_helper(vertices, .{-0.5, 0.5, 0.5}, *index);
	cube_vertex_helper(vertices, .{0.5, 0.5, 0.5}, *index);
	cube_vertex_helper(vertices, .{0.5, 0.5, -0.5}, *index);
	
	cube_vertex_helper(vertices, .{-0.5, 0.5, 0.5}, *index);
	cube_vertex_helper(vertices, .{0.5, 0.5, -0.5}, *index);
	cube_vertex_helper(vertices, .{-0.5, 0.5, -0.5}, *index);
	
	// Bot Face
	cube_vertex_helper(vertices, .{0.5, -0.5, -0.5}, *index);
	cube_vertex_helper(vertices, .{0.5, -0.5, 0.5}, *index);
	cube_vertex_helper(vertices, .{-0.5, -0.5, 0.5}, *index);
	
	cube_vertex_helper(vertices, .{-0.5, -0.5, -0.5}, *index);
	cube_vertex_helper(vertices, .{0.5, -0.5, -0.5}, *index);
	cube_vertex_helper(vertices, .{-0.5, -0.5, 0.5}, *index);
	
	// Right Face
	cube_vertex_helper(vertices, .{0.5, 0.5, 0.5}, *index);
	cube_vertex_helper(vertices, .{0.5, -0.5, 0.5}, *index);
	cube_vertex_helper(vertices, .{0.5, -0.5, -0.5}, *index);
	
	cube_vertex_helper(vertices, .{0.5, -0.5, -0.5}, *index);
	cube_vertex_helper(vertices, .{0.5, 0.5, -0.5}, *index);
	cube_vertex_helper(vertices, .{0.5, 0.5, 0.5}, *index);
	
	// Left Face
	cube_vertex_helper(vertices, .{-0.5, -0.5, -0.5}, *index);
	cube_vertex_helper(vertices, .{-0.5, -0.5, 0.5}, *index);
	cube_vertex_helper(vertices, .{-0.5, 0.5, 0.5}, *index);
	
	cube_vertex_helper(vertices, .{-0.5, 0.5, 0.5}, *index);
	cube_vertex_helper(vertices, .{-0.5, 0.5, -0.5}, *index);
	cube_vertex_helper(vertices, .{-0.5, -0.5, -0.5}, *index);
	
	cube_vertex_buffer = r_buffer_create(.Static_Draw, vertices.data, vertices.count * size_of(Vertex));
	
	indices :[36]u32;
	
	for *indices
	{
		it.* = cast(u32) it_index;
	}
	
	cube_index_buffer = r_buffer_create(.Static_Draw, indices.data, indices.count * size_of(u32));
}

draw_cube :: (pb : *R_Push_Buffer, model : Matrix4, color : Vector4)
{
	r_mesh :*R_Mesh = xx push_batch(*pb.mesh_batches, size_of(R_Mesh), xx MB(1));
	
	r_mesh.start = 0;
	r_mesh.count = 36;
	
	r_mesh.xform = model;
	
	r_mesh.vertex_buffer = cube_vertex_buffer;
	r_mesh.index_buffer = cube_index_buffer;
	
	r_mesh.color = color;
	r_mesh.color_map = tex_id_from_handle(get_white_square());
}

#scope_file

cube_vertex_buffer : u32;
cube_index_buffer : u32;

// init primitives
// cube
cube_vertex_helper :: (vertices : []Vertex, pos : Vector3, index : *int)
{
	v := *vertices.data[index.*];
	index.* += 1;
	v.pos = pos;
	v.color = .{1, 1, 1, 1};
}
