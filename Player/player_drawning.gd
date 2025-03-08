extends Node2D

# Parametry
var min_distance_between_points = 5.0
var color_change_speed = 2.0
var recognition_tolerance = 20.0 # Tolerancja w pikselach
var min_points_for_recognition = 10

# Zmienne rysowania
var drawing = false
var points = []
var current_color = Color(1, 0, 0, 1) # Czerwony początkowy kolor
var hue = 0.0

# Rozpoznany kształt
var recognized_shape = "Brak"
var recognized_direction = "Brak"

func _ready():
	set_process(true)
	set_process_input(true)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Rozpocznij rysowanie
				drawing = true
				points = []
				points.append(event.position)
			else:
				# Zakończ rysowanie i rozpoznaj kształt
				drawing = false
				if points.size() >= min_points_for_recognition:
					recognize_shape()
				else:
					recognized_shape = "Za mało punktów"
					recognized_direction = "Brak"
				queue_redraw()

	elif event is InputEventMouseMotion and drawing:
		if points.size() > 0:
			var last_point = points[points.size() - 1]
			if last_point.distance_to(event.position) >= min_distance_between_points:
				points.append(event.position)
				queue_redraw()

func _process(delta):
	# Zmiana koloru
	if drawing:
		hue = fmod(hue + delta * color_change_speed, 1.0)
		current_color = Color.from_hsv(hue, 1.0, 1.0, 1.0)
		queue_redraw()

func _draw():
	# Rysuj punkty
	if points.size() >= 2:
		for i in range(points.size() - 1):
			var color_gradient = Color.from_hsv(
				fmod(hue - (float(i) / points.size()) * 0.5, 1.0),
				1.0, 1.0, 1.0
			)
			draw_line(points[i], points[i + 1], color_gradient, 2.0)
	
	# Wyświetl rozpoznany kształt
	var viewport_size = get_viewport_rect().size
	draw_string(
		ThemeDB.fallback_font,
		Vector2(10, viewport_size.y - 40),
		"Kształt: " + recognized_shape,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color(1, 1, 1)
	)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(10, viewport_size.y - 20),
		"Kierunek: " + recognized_direction,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color(1, 1, 1)
	)

func recognize_shape():
	# Wektor przesunięcia między pierwszym a ostatnim punktem
	var displacement = points[points.size() - 1] - points[0]
	var total_distance = calculate_path_length()
	
	# Oblicz podstawowe metryki kształtu
	var is_closed = points[0].distance_to(points[points.size() - 1]) < recognition_tolerance
	var straight_line_score = displacement.length() / total_distance if total_distance > 0 else 0
	var zigzag_score = calculate_zigzag_score()
	var triangle_score = calculate_polygon_score(4)
	var square_score = calculate_polygon_score(5)
	var spiral_score = calculate_spiral_score()
	#print(triangle_score)
	
	# Rozpoznanie kształtu na podstawie metryki z najlepszym wynikiem
	if straight_line_score > 0.7:
		recognized_shape = "Linia prosta"
		recognized_direction = get_center_direction(points[0], points[points.size() - 1])
	elif zigzag_score > 0.7:
		recognized_shape = "Zygzak"
		recognized_direction = "Brak"
	elif is_closed and triangle_score > 0.7:
		recognized_shape = "Trójkąt"
		recognized_direction = "Brak"
	elif is_closed and square_score > 0.7:
		recognized_shape = "Kwadrat"
		recognized_direction = "Brak"
	elif spiral_score > 0.6:
		recognized_shape = "Spirala"
		recognized_direction = get_spiral_direction()
	else:
		recognized_shape = "Nierozpoznany"
		recognized_direction = "Brak"

func calculate_path_length():
	var length = 0.0
	for i in range(1, points.size()):
		length += points[i].distance_to(points[i-1])
	return length

func get_center_direction(start_point, end_point):
	# Znajdź środek ekranu
	var viewport_size = get_viewport_rect().size
	var screen_center = viewport_size / 2
	
	# Oblicz odległości od środka ekranu
	var start_dist_to_center = start_point.distance_to(screen_center)
	var end_dist_to_center = end_point.distance_to(screen_center)
	
	if start_dist_to_center < end_dist_to_center:
		return "Od środka na zewnątrz"
	else:
		return "Z zewnątrz do środka"

func calculate_zigzag_score():
	if points.size() < 3:
		return 0.0
	
	var direction_changes = 0
	var last_direction = Vector2.ZERO
	
	for i in range(1, points.size() - 1):
		var current_direction = (points[i+1] - points[i]).normalized()
		if last_direction != Vector2.ZERO:
			var dot_product = current_direction.dot(last_direction)
			if dot_product < 0:  # Kąt większy niż 90 stopni
				direction_changes += 1
		last_direction = current_direction
	
	# Normalizacja wyniku względem możliwej liczby zmian kierunku
	return float(direction_changes) / (points.size() / 5.0)

func calculate_polygon_score(sides):
	if points.size() < sides + 1 or not is_shape_closed():
		return 0.0
	
	# Uproszczenie ścieżki do przybliżonych wierzchołków wielokąta
	var simplified_points = simplify_path(points, recognition_tolerance * 1.5)
	
	# Jeśli liczba uproszczonych punktów jest bliska liczbie wierzchołków wielokąta
	if abs(simplified_points.size() - sides) <= 1:
		# Sprawdź równość boków i kątów
		var side_lengths = []
		var angles = []
		
		for i in range(simplified_points.size()):
			var next_idx = (i + 1) % simplified_points.size()
			side_lengths.append(simplified_points[i].distance_to(simplified_points[next_idx]))
			
			if simplified_points.size() > 2:
				var prev_idx = (i - 1 + simplified_points.size()) % simplified_points.size()
				
				var vector1 = (simplified_points[prev_idx] - simplified_points[i]).normalized()
				var vector2 = (simplified_points[next_idx] - simplified_points[i]).normalized()
				var angle = acos(clamp(vector1.dot(vector2), -1.0, 1.0))
				angles.append(angle)
		
		# Oblicz odchylenie standardowe długości boków
		var avg_side_length = 0.0
		for length in side_lengths:
			avg_side_length += length
		avg_side_length /= side_lengths.size()
		
		var side_variance = 0.0
		for length in side_lengths:
			side_variance += pow(length - avg_side_length, 2)
		side_variance /= side_lengths.size()
		
		# Im mniejsze odchylenie standardowe, tym bardziej regularna figura
		var regularity_score = 1.0 - clamp(sqrt(side_variance) / avg_side_length, 0.0, 1.0)
		
		return regularity_score
	
	return 0.0

func simplify_path(path, epsilon):
	if path.size() <= 2:
		return path
	
	var result = []
	var stack = [[0, path.size() - 1]]
	var marked = []
	marked.resize(path.size())
	
	while not stack.is_empty():
		var current = stack.pop_back()
		var start_idx = current[0]
		var end_idx = current[1]
		
		var max_dist = 0.0
		var index = 0
		
		for i in range(start_idx + 1, end_idx):
			var dist = point_line_distance(path[i], path[start_idx], path[end_idx])
			if dist > max_dist:
				max_dist = dist
				index = i
		
		if max_dist > epsilon:
			stack.push_back([index, end_idx])
			stack.push_back([start_idx, index])
		else:
			if not marked[start_idx]:
				result.append(path[start_idx])
				marked[start_idx] = true
			if not marked[end_idx]:
				result.append(path[end_idx])
				marked[end_idx] = true
	
	# Sortuj punkty według indeksu oryginalnego
	var indexed_points = []
	for i in range(path.size()):
		if marked[i]:
			indexed_points.append([i, path[i]])
	
	indexed_points.sort_custom(sort_by_index)
	
	result = []
	for point in indexed_points:
		result.append(point[1])
	
	return result

func sort_by_index(a, b):
	return a[0] < b[0]

func point_line_distance(point, line_start, line_end):
	var line_dir = line_end - line_start
	var line_length = line_dir.length()
	
	if line_length == 0.0:
		return point.distance_to(line_start)
	
	var t = clamp(line_dir.dot(point - line_start) / (line_length * line_length), 0.0, 1.0)
	var projection = line_start + t * line_dir
	
	return point.distance_to(projection)

func is_shape_closed():
	if points.size() < 3:
		return false
	
	return points[0].distance_to(points[points.size() - 1]) < recognition_tolerance

func calculate_spiral_score():
	if points.size() < 10:
		return 0.0
	
	# Znajdź środek kształtu
	var center = Vector2.ZERO
	for point in points:
		center += point
	center /= points.size()
	
	# Oblicz dystanse od środka i kąty dla każdego punktu
	var distances = []
	var angles = []
	
	for point in points:
		var to_point = point - center
		distances.append(to_point.length())
		angles.append(atan2(to_point.y, to_point.x))
	
	# Sprawdź czy dystanse rosną/maleją monotonicznie gdy kąt się zmienia
	var monotonic_count = 0
	var increasing = distances[1] > distances[0]
	
	for i in range(1, distances.size()):
		if (increasing and distances[i] > distances[i-1]) or (not increasing and distances[i] < distances[i-1]):
			monotonic_count += 1
	
	# Spirala powinna mieć zawsze rosnący lub malejący dystans do środka
	var monotonic_score = float(monotonic_count) / (distances.size() - 1)
	
	# Oblicz całkowitą zmianę kąta - spirala powinna wykonać przynajmniej 1 obrót (2π)
	var angle_changes = []
	for i in range(1, angles.size()):
		var change = angles[i] - angles[i-1]
		# Normalizacja do zakresu -π do π
		if change > PI:
			change -= 2 * PI
		elif change < -PI:
			change += 2 * PI
		angle_changes.append(change)
	
	var total_angle_change = 0.0
	for change in angle_changes:
		total_angle_change += abs(change)
	
	var angle_score = min(total_angle_change / (2 * PI), 1.0)
	
	# Średnia z obu metryk
	return (monotonic_score + angle_score) / 2.0

func get_spiral_direction():
	# Znajdź środek spirali
	var center = Vector2.ZERO
	for point in points:
		center += point
	center /= points.size()
	
	# Sprawdź, czy dystans do środka rośnie czy maleje
	var start_dist = points[0].distance_to(center)
	var end_dist = points[points.size() - 1].distance_to(center)
	
	if start_dist > end_dist:
		return "Do środka"
	else:
		return "Na zewnątrz"
