extends Node



const MUSIC_FOLDER = "res://audio/music/"
const SFX_FOLDER = "res://audio/sfx/"

var music_player : AudioStreamPlayer

var num_sfx_players = 20
var sfx_available = []  # The available players.
var sfx_queue = []  # The queue of sounds to play.


## Usage: AudioManager.play_music("Example1.wav")
func play_music(music_file:String, audio_bus:String = "MUSIC"):
	var sound_path = MUSIC_FOLDER + music_file
	if music_player.stream and music_player.stream.resource_path == sound_path:
		return
	music_player.stop()
	music_player.stream = load(sound_path)
	music_player.bus = audio_bus
	music_player.play()

func stop_music():
	music_player.stop()


## Usage: AudioManager.play_sfx("Example1.wav")
func play_sfx(sfx_file:String, audio_bus:String = "SFX"):
	var sound_path = SFX_FOLDER + sfx_file
	
	#if not sound_path.ends_with(".ogg"): # solução temporária enquanto não substituí todas as calls
	sfx_queue.append([sound_path, audio_bus])

## https://www.youtube.com/watch?v=QgBecUl_lFs
func install_ui(node:Node):
	for child in node.get_children():
		if child is Button:
			child.mouse_entered.connect(_on_ui_button_hovered)
			child.focus_entered.connect(_on_ui_button_hovered)
			child.pressed.connect(_on_ui_button_pressed)
			#child.pressed.connect(play_sfx.bind("button_pressed"))
		#elif child is LineEdit etc etc
		
		# do recursive
		install_ui(child)


func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	music_player = AudioStreamPlayer.new()
	music_player.bus = "MUSIC"
	add_child(music_player)
	
	for i in num_sfx_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_available.append(p)
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = "SFX"


func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	sfx_available.append(stream)


func _process(_delta):
	# Play a queued sound if any players are available.
	if not sfx_queue.is_empty() and not sfx_available.is_empty():
		#assert()
		var sfx_paths = sfx_queue.pop_front()
		var loaded_sfx = load(sfx_paths[0])
		if loaded_sfx:
			#print_debug(loaded_sfx)
			sfx_available[0].stream = loaded_sfx
			sfx_available[0].bus = sfx_paths[1]
			sfx_available[0].play()
			sfx_available.pop_front()
		else:
			printerr("Couldn't load sfx \"%s\"" % sfx_paths[0])
	#if not sfx_queue.is_empty() and not sfx_available.is_empty():
		#var front_stream = sfx_available.pop_front()
		#var queued_sfx = sfx_queue.pop_front()
		# you can safely throw an error here now
		#front_stream.stream = load(queued_sfx)
		#front_stream.play()

func _on_ui_button_hovered():
	play_sfx("select2.wav")
	pass
	# play click sound


func _on_ui_button_pressed():
	play_sfx("select.wav")
	pass
	# play click sound
