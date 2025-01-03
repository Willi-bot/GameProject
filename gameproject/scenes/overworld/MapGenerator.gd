extends Node


func generate(plane_width, plane_height, node_count, path_count):
	# make sure that we are not going to generate the same map every time
	randomize()
	
	# step 1: generating points on a grid randomly
	var points = []
	# Starting Point
	points.append(Vector2(plane_width / 2, 0))
	# End Point
	points.append(Vector2(plane_width / 2, plane_height))
	
	var center = Vector2(plane_width / 2, plane_height / 2)
	for i in range(node_count):
		while true:
			var point = Vector2(randi() % plane_width, randi() % plane_height)
			
			var dist_from_center = (point - center).length_squared()
			# only accept points insode of a circle
			var in_circle = dist_from_center <= plane_width * plane_height / 4
			if not points.has(point) and in_circle:
				points.append(point)
				break
	
	# step 2: connect all the points into a graph without intersecting edges
	var pool = PackedVector2Array(points)
	var triangles = Geometry2D.triangulate_delaunay(pool)
	
	# step 3: finding paths from start to finish using A*
	var astar = AStar2D.new()
	for i in range(points.size()):
		astar.add_point(i, points[i])
	
	for i in range(triangles.size() / 3):
		var p1 = triangles[i * 3]
		var p2 = triangles[i * 3 + 1]
		var p3 = triangles[i * 3 + 2]
		if not astar.are_points_connected(p1, p2):
			astar.connect_points(p1, p2)
		if not astar.are_points_connected(p2, p3):
			astar.connect_points(p2, p3)
		if not astar.are_points_connected(p1, p3):
			astar.connect_points(p1, p3)
	
	var paths = []
	
	for i in range(path_count):
		var id_path = astar.get_id_path(0, 1)
		if id_path.size() == 0:
			break
		
		paths.append(id_path)
		
		# step 4: removing nodes / generating unique path every time
		for j in range(randi() % 2 + 1):
			# index between 1 and id_path.size() - 2 (inclusive)
			var index = randi() % (id_path.size() - 2) + 1
			
			var id = id_path[index]
			astar.set_point_disabled(id)
		
	var nodes = {}
	for path in paths:
		for id in path:
			nodes[id] = points[id]
	
	return [nodes, paths]
