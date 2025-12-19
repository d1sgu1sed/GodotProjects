extends CanvasLayer

class_name UI

@onready var score_label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var coins_label = $MarginContainer/HBoxContainer/CoinsLabel

@onready var win_screen: TextureRect = $MarginContainer/TextureRect

func set_score(points: int):
	score_label.text = "SCORE: %d" % points

func set_coins(coins: int):
	coins_label.text = "COINS: %d" % coins
	
func on_finish():
	win_screen.visible = true
