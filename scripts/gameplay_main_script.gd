extends Node2D

# скрипт для того чтобы начать геймплей

# данные
var map_name = "JDCPeiPlay"

var coaches = 1

var beats = []
var lyrics = []
var pictos = []
var moves = {}
var colors = {}

# таймы для таймлайнов
var current_time = 0.0

# последний бит/слова/пикта/мув
var last_beat = -1
var last_lyric = -1
var last_picto = -1
var last_move = {
	"index": -1,
	"id": "moves_0"
}

var next_lyrics = 0
var next_picto = 0

# линии слов
var lyrics_lines = []

var current_lyric_line = -1 
var next_lyric_line = -1

func parse_json_from_file(path):
	# функция для открытия json-файлов
	
	var file = File.new()
	file.open(path, file.READ)
	
	var text = file.get_as_text()
	file.close()

	return JSON.parse(text).result

func _ready():
	# начало геймплея
	
	var json_path = "res://songs/" + map_name + ".json"
	var json_data = parse_json_from_file(json_path)
	
	coaches = json_data["coaches"]
	
	beats = json_data["beats"]
	lyrics = json_data["lyrics"]
	pictos = json_data["pictos"]
	moves = json_data["moves"]
	colors = json_data["colors"]
	
	# lyrics lines generator
	var lyrics_line = ""
	for lyric in range(lyrics.size()):
		lyrics_line += lyrics[lyric]["text"]
		lyrics[lyric]["line"] = lyrics_lines.size()
		
		if lyrics[lyric]["end"] == true:
			lyrics_lines.append(lyrics_line)
			lyrics_line = ""
	
	var videoStream = load("res://songs/" + map_name + "/" + map_name + ".webm")
	$VideoPlayer.set_stream(videoStream)
	
	$Lyrics/CurrentLineBkg.set_text("")
	$Lyrics/NextLineBkg.set_text("")
	$Lyrics/CurrentLineColor.set_text("")
	
	var lyrics_color = Color(colors["lyrics"]["r"], colors["lyrics"]["g"], colors["lyrics"]["b"], 1)
	$Lyrics/CurrentLineColor.push_color(lyrics_color)
	
	$VideoPlayer.play()

func _process(_delta):
	current_time = $VideoPlayer.get_stream_position()
		
	for beat in range(beats.size()):
		if beats[beat] >= current_time:
			# скорость анимации
			var animation_speed = (beats[beat] - beats[beat-1]) / 0.45
			
			$Pictobar/PictobarAnim.playback_speed = animation_speed
			$Pictobar/PictobarAnim.play("beat_animation")
			
			last_beat = beat
			
			break
		
	for lyric in range(lyrics.size()):
		var start_time = lyrics[lyric]["start_time"]
		var end_time = lyrics[lyric]["end_time"]
		var text = lyrics[lyric]["text"]
		var line = lyrics[lyric]["line"]
		
		if start_time <= current_time and next_lyrics == lyric:
			var duration = end_time - start_time
			
			$Lyrics/CurrentLineBkg.set_text(lyrics_lines[line])
			if line+1 < lyrics_lines.size():
				$Lyrics/NextLineBkg.set_text(lyrics_lines[line+1])
			else:
				$Lyrics/NextLineBkg.set_text("")
			
			if lyrics[last_lyric]["line"] != line:
				$Lyrics/CurrentLineColor.set_visible_characters(0)
				$Lyrics/CurrentLineColor.set_text(lyrics_lines[line])
			
			var latest_visible_chars = $Lyrics/CurrentLineColor.get_visible_characters()
			var new_visible_chars = text.length() + latest_visible_chars
			
			$Lyrics/LyricsAnimation.interpolate_property($Lyrics/CurrentLineColor, "visible_characters",
				latest_visible_chars, new_visible_chars, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Lyrics/LyricsAnimation.start()
			
			last_lyric = lyric
			next_lyrics = lyric + 1
		
	for picto in range(pictos.size()):
		var beat
		if last_beat+1 < beats.size():
			beat = beats[last_beat+1] - beats[last_beat]
		else:
			beat = 500
		
		var jump_start = pictos[picto]["jump_start_time"]
		var move_start = jump_start - (beat * 4.0)
		
		if move_start <= current_time and next_picto == picto:
			var move_duration = beat * 4.0
			
			var sprite = Sprite.new()
			var image = load(pictos[picto]["path"])
			
			sprite.set_texture(image)
			
			if coaches == 1:
				sprite.set_position(Vector2(1373, 590))
				sprite.set_scale(Vector2(0.734, 0.734))
			else:
				sprite.set_position(Vector2(1429, 589))
				sprite.set_scale(Vector2(1.169, 1.169))
			
			sprite.set_name("Picto" + str(picto))
			
			$Pictos.add_child(sprite)
			
			var tween = Tween.new()
			
			tween.set_name("Tween" + str(picto))
			
			if coaches == 1:
				tween.interpolate_property($Pictos.get_node("Picto" + str(picto)), "position",
					Vector2(1373, 590), Vector2(892, 590), move_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
			
				tween.interpolate_property($Pictos.get_node("Picto" + str(picto)), "position",
					Vector2(892, 590), Vector2(892, 565), beat / 2, Tween.TRANS_LINEAR, Tween.EASE_OUT, move_duration)
				tween.interpolate_property($Pictos.get_node("Picto" + str(picto)), "scale",
					Vector2(0.734, 0.734), Vector2(0.922, 0.922), beat / 2, Tween.TRANS_LINEAR, Tween.EASE_OUT, move_duration)
				tween.interpolate_property($Pictos.get_node("Picto" + str(picto)), "modulate",
					sprite.modulate, Color(sprite.modulate.a, sprite.modulate.b, sprite.modulate.g, 0), beat / 2, Tween.TRANS_LINEAR, Tween.EASE_OUT, move_duration)
			else:
				tween.interpolate_property($Pictos.get_node("Picto" + str(picto)), "position",
					Vector2(1429, 589), Vector2(892, 590), move_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
			
				tween.interpolate_property($Pictos.get_node("Picto" + str(picto)), "position",
					Vector2(892, 590), Vector2(892, 570), beat / 2, Tween.TRANS_LINEAR, Tween.EASE_OUT, move_duration)
				tween.interpolate_property($Pictos.get_node("Picto" + str(picto)), "scale",
					Vector2(1.169, 1.169), Vector2(1.41, 1.41), beat / 2, Tween.TRANS_LINEAR, Tween.EASE_OUT, move_duration)
				tween.interpolate_property($Pictos.get_node("Picto" + str(picto)), "modulate",
					sprite.modulate, Color(sprite.modulate.a, sprite.modulate.b, sprite.modulate.g, 0), beat / 2, Tween.TRANS_LINEAR, Tween.EASE_OUT, move_duration)
				
			
			$Pictos.add_child(tween) 
			$Pictos.get_node("Tween" + str(picto)).start()
			
			next_picto = picto + 1
			
			break
