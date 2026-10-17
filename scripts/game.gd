extends Node3D

const MAP_NAMES = ["African Wildlands","Green Forest","Desert Frontier","Rocky Mountains","Tropical Jungle","Frozen North","Blackwater Swamp","Rural Heartland","Logging Country","Lost Wilderness"]
const MAP_COLORS = [Color(0.48,0.40,0.24),Color(0.18,0.29,0.17),Color(0.68,0.48,0.27),Color(0.42,0.43,0.42),Color(0.12,0.27,0.19),Color(0.72,0.82,0.88),Color(0.18,0.23,0.18),Color(0.37,0.34,0.20),Color(0.24,0.30,0.21),Color(0.30,0.36,0.31)]
var truck: CharacterBody3D
var camera: Camera3D
var speed_label: Label
var status_label: Label
var speed := 0.0
var steering := 0.0
var throttle := 0.0
var braking := false
var reverse_gear := false
var awd := true
var diff_lock := false
var camera_mode := 0
var map_index := 0
var props: Array[Node3D] = []
var camera_names := ["CHASE","COCKPIT","BONNET","WIDE"]

func _ready():
    _build_truck()
    camera = Camera3D.new()
    camera.current = true
    camera.fov = 72
    add_child(camera)
    _build_hud()
    _build_map()

func _box(size: Vector3, color: Color) -> MeshInstance3D:
    var n = MeshInstance3D.new()
    var m = BoxMesh.new()
    m.size = size
    n.mesh = m
    var mat = StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.9
    n.material_override = mat
    return n

func _build_truck():
    truck = CharacterBody3D.new()
    truck.name = "PlayerTruck"
    truck.position = Vector3(0, 0.9, 0)
    add_child(truck)
    var chassis = _box(Vector3(2,0.62,3.45),Color(0.13,0.24,0.17))
    chassis.position.y = 0.55
    truck.add_child(chassis)
    var cab = _box(Vector3(1.62,0.82,1.42),Color(0.21,0.34,0.24))
    cab.position = Vector3(0,1.22,-0.48)
    truck.add_child(cab)
    for x in [-1.02,1.02]:
        for z in [-1.18,0.0,1.18]:
            var wheel = MeshInstance3D.new()
            var mesh = CylinderMesh.new()
            mesh.top_radius = 0.39
            mesh.bottom_radius = 0.39
            mesh.height = 0.28
            wheel.mesh = mesh
            wheel.rotation_degrees.z = 90
            wheel.position = Vector3(x,0.08,z)
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0.04,0.04,0.04)
            wheel.material_override = mat
            truck.add_child(wheel)
    var col = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(2,1.65,3.35)
    col.shape = shape
    col.position.y = 0.75
    truck.add_child(col)

func _build_hud():
    var layer = $HUD
    var panel = PanelContainer.new()
    panel.position = Vector2(12,12)
    panel.custom_minimum_size = Vector2(330,100)
    layer.add_child(panel)
    var vb = VBoxContainer.new()
    panel.add_child(vb)
    var title = Label.new()
    title.text = "OFFROAD EXTREME • BUILD 01"
    vb.add_child(title)
    speed_label = Label.new()
    vb.add_child(speed_label)
    status_label = Label.new()
    vb.add_child(status_label)
    _button(layer,"◀",Vector2(20,420),Vector2(72,72),"left")
    _button(layer,"▶",Vector2(100,420),Vector2(72,72),"right")
    _button(layer,"BRAKE",Vector2(670,438),Vector2(100,54),"brake")
    _button(layer,"ACCEL",Vector2(785,408),Vector2(120,84),"accel")
    _button(layer,"R / D",Vector2(785,342),Vector2(120,52),"gear")
    _button(layer,"CAM",Vector2(820,12),Vector2(90,42),"camera")
    _button(layer,"AWD",Vector2(820,60),Vector2(90,42),"awd")
    _button(layer,"DIFF",Vector2(820,108),Vector2(90,42),"diff")
    _button(layer,"MAP +",Vector2(820,156),Vector2(90,42),"map")
    _refresh()

func _button(layer, caption, pos, size, action):
    var b = Button.new()
    b.text = caption
    b.position = pos
    b.size = size
    layer.add_child(b)
    if action in ["left","right","accel","brake"]:
        b.button_down.connect(func(): _hold(action,true))
        b.button_up.connect(func(): _hold(action,false))
    else:
        b.pressed.connect(func(): _tap(action))

func _hold(action, pressed):
    match action:
        "left": steering = -1.0 if pressed else (0.0 if steering < 0.0 else steering)
        "right": steering = 1.0 if pressed else (0.0 if steering > 0.0 else steering)
        "accel": throttle = 1.0 if pressed else 0.0
        "brake": braking = pressed

func _tap(action):
    match action:
        "gear": reverse_gear = not reverse_gear
        "camera": camera_mode = (camera_mode + 1) % camera_names.size()
        "awd": awd = not awd
        "diff": diff_lock = not diff_lock
        "map":
            map_index = (map_index + 1) % MAP_NAMES.size()
            _build_map()
    _refresh()

func _build_map():
    for p in props:
        if is_instance_valid(p): p.queue_free()
    props.clear()
    var ground_mat = StandardMaterial3D.new()
    ground_mat.albedo_color = MAP_COLORS[map_index]
    ground_mat.roughness = 1.0
    $Ground/GroundMesh.material_override = ground_mat
    for i in range(36):
        var rock = MeshInstance3D.new()
        var mesh = SphereMesh.new()
        mesh.radius = randf_range(0.35,1.25)
        mesh.height = mesh.radius * 1.4
        rock.mesh = mesh
        rock.position = Vector3(randf_range(-32,32),0,randf_range(-50,50))
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0.78,0.84,0.88) if map_index == 5 else Color(0.24,0.27,0.23)
        rock.material_override = mat
        add_child(rock)
        props.append(rock)
    for i in range(20):
        var tree = Node3D.new()
        var trunk = MeshInstance3D.new()
        var tm = CylinderMesh.new()
        tm.top_radius = 0.08
        tm.bottom_radius = 0.2
        tm.height = 2.4
        trunk.mesh = tm
        trunk.position.y = 1.2
        tree.add_child(trunk)
        var crown = MeshInstance3D.new()
        var cm = SphereMesh.new()
        cm.radius = 1.0
        cm.height = 1.8
        crown.mesh = cm
        crown.position.y = 2.8
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0.12,0.25,0.13) if map_index not in [2,5] else MAP_COLORS[map_index].lightened(0.1)
        crown.material_override = mat
        tree.add_child(crown)
        tree.position = Vector3(randf_range(-72,72),0,randf_range(-72,72))
        add_child(tree)
        props.append(tree)
    _refresh()

func _refresh():
    if speed_label:
        speed_label.text = "Speed: %d km/h" % int(abs(speed)*3.6)
        status_label.text = "%s | AWD %s | DIFF %s | Map %d/10: %s | %s" % ["R" if reverse_gear else "D","ON" if awd else "OFF","LOCK" if diff_lock else "OPEN",map_index+1,MAP_NAMES[map_index],camera_names[camera_mode]]

func _physics_process(delta):
    if not is_instance_valid(truck): return
    var max_speed = 10.0 if awd else 8.5
    if diff_lock: max_speed *= 0.88
    var target_speed = throttle * max_speed * (-1.0 if reverse_gear else 1.0)
    if braking: target_speed = 0.0
    speed = move_toward(speed,target_speed,(3.6 if throttle > 0 else 6.0)*delta)
    if abs(speed)>0.12:
        truck.rotate_y(-steering*1.25*delta*clamp(abs(speed)/3.0,0.25,1.0)*sign(speed))
    var forward = -truck.global_transform.basis.z
    truck.velocity.x = forward.x*speed
    truck.velocity.z = forward.z*speed
    truck.velocity.y -= 20.0*delta
    truck.move_and_slide()
    var desired = truck.global_position + truck.global_transform.basis * _camera_offset()
    camera.global_position = camera.global_position.lerp(desired,delta*4.0)
    camera.look_at(truck.global_position+Vector3(0,1.55,0),Vector3.UP)
    _refresh()

func _camera_offset():
    match camera_mode:
        1: return Vector3(0,2.05,-0.25)
        2: return Vector3(0,2.0,2.25)
        3: return Vector3(0,6.2,11.5)
        _: return Vector3(0,4.3,8.4)
