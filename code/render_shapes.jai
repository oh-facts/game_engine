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
	
	cube_aabb.min = .{-0.5, -0.5, -0.5};
	cube_aabb.max = .{0.5, 0.5, 0.5};
	
	cube_vertex_buffer = r_buffer_create(.Static_Draw, vertices.data, vertices.count * size_of(Vertex));
	
	indices :[36]u32;
	
	for *indices
	{
		it.* = cast(u32) it_index;
	}
	
	cube_index_buffer = r_buffer_create(.Static_Draw, indices.data, indices.count * size_of(u32));
}

cube_aabb : AABB;

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

/*
points : [8]Vector3;
			
xs : [2]float = .[min.x, max.x];
ys : [2]float = .[min.y, max.y];
zs : [2]float = .[min.z, max.z];
			
for x : 0 .. 1
{
	for y : 0 .. 1
	{
		for z : 0 .. 1
		{
			point := model * m.xform * .{xs[x], ys[y], zs[z], 1};
			
			points[x * 2 * 2 + y * 2 + z] = point.xyz;
			push_debug_vertex(pb, point.xyz, COLOR_RED);
		}
	}
}
*/

/*
// NOTE(prismo):
a=['min.x', 'max.x']
a1=['min.y', 'max.y']
a2=['min.z', 'max.z']
l=[]
for i in a:
	for j in a1:
			for k in a2:
					l1=[i,j,k]
					l.append(l1)
r=[]
for i in l:
	for j in l:
			if [j,i] not in r:
					if i[1]==j[1] and i[2]==j[2] and i!=j:
							k=[i,j]
							r.append(k)
					elif i[0]==j[0] and i[2]==j[2] and i!=j:
							k=[i,j]
							r.append(k)
					elif i[0]==j[0] and i[1]==j[1] and i!=j:
							k=[i,j]
							r.append(k)
count=0
for i in r:
	count+=1
	#print(count)
	print(i)
*/

draw_aabb_wireframe :: (pb : *R_Push_Buffer, aabb : AABB, color : Vector4)
{
	using aabb;
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
		push_debug_line(pb, edge[0], edge[1], color);
	}
}

#scope_file

cube_vertex_buffer : u32;
cube_index_buffer : u32;

// init primitives
// cube
cube_vertex_helper :: (vertices : []Vertex, pos : Vector3, index : *int)
{
	v := *vertices.data[index.*];
	v.pos = pos;
	v.color = .{1, 1, 1, 1};
	
	// use last 3 vertex pos to calc normals
	if index.* % 3 == 2
	{
		v0 := *vertices.data[index.* - 2];
		v1 := *vertices.data[index.* - 1];
		v2 := *vertices.data[index.* - 0];
		
		v01 := v1.pos - v0.pos;
		v02 := v2.pos - v0.pos;
		
		norm := cross(v01, v02);
		
		v0.normal = norm;
		v1.normal = norm;
		v2.normal = norm;
	}
	
	index.* += 1;
}
