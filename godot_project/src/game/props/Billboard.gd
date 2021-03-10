extends Node


var _billboards := ["fer", "helb", "hep", "sedamit"]

func _ready():
	$Sprite.play(_billboards[Global.billboard_index])
	Global.billboard_index += 1
