extends Sprite

var rect_region_x: int
var rect_region_y: int

func _ready():
	randomize()
	rect_region_x = floor(rand_range(0,2))
	rect_region_y = floor(rand_range(0,4))
	region_rect = Rect2(rect_region_x*16, rect_region_y * 16, 16, 16)
