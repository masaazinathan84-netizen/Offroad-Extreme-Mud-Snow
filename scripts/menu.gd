extends Control

func _ready():
    var bg = ColorRect.new()
    bg.color = Color(0.055,0.09,0.07)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var title = Label.new()
    title.text = "OFFROAD\nEXTREME"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 46)
    title.add_theme_color_override("font_color", Color(0.91,0.69,0.28))
    title.anchor_left = 0.1
    title.anchor_right = 0.9
    title.anchor_top = 0.08
    title.anchor_bottom = 0.34
    add_child(title)
    var subtitle = Label.new()
    subtitle.text = "MUD  •  SNOW  •  WILDERNESS"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.anchor_left = 0.05
    subtitle.anchor_right = 0.95
    subtitle.anchor_top = 0.31
    subtitle.anchor_bottom = 0.39
    add_child(subtitle)
    var buttons = VBoxContainer.new()
    buttons.anchor_left = 0.2
    buttons.anchor_right = 0.8
    buttons.anchor_top = 0.46
    buttons.anchor_bottom = 0.87
    buttons.add_theme_constant_override("separation", 12)
    add_child(buttons)
    _add_button(buttons,"▶   DRIVE",func(): get_tree().change_scene_to_file("res://scenes/main.tscn"))
    _add_button(buttons,"🚙   VEHICLES",func(): _message("Vehicle garage is planned for a future build."))
    _add_button(buttons,"🗺   MAP SELECT",func(): _message("Ten environment themes are available in the prototype using MAP +."))
    _add_button(buttons,"⚙   SETTINGS",func(): _message("Low-end graphics profile: prototype mode."))
    var footer = Label.new()
    footer.text = "BUILD 01  •  OFFLINE PROTOTYPE"
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.anchor_left = 0.05
    footer.anchor_right = 0.95
    footer.anchor_top = 0.92
    footer.anchor_bottom = 0.99
    footer.add_theme_color_override("font_color", Color(0.65,0.7,0.64))
    add_child(footer)

func _add_button(parent: VBoxContainer, caption: String, action: Callable):
    var b = Button.new()
    b.text = caption
    b.custom_minimum_size = Vector2(0, 54)
    b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    b.add_theme_font_size_override("font_size", 20)
    b.pressed.connect(action)
    parent.add_child(b)

func _message(message: String):
    var dialog = AcceptDialog.new()
    dialog.dialog_text = message
    add_child(dialog)
    dialog.popup_centered()
