extends Node


var _billboards := ["fer", "helb", "hep", "sedamit"]

func _ready():
	$Sprite.play(_billboards[rand_range(0, _billboards.size())])
