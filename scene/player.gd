extends CharacterBody2D

const NORMAL_ANIMATION_PREFIX := &"normal" # 标识四个朝向normal状态动画的通用前缀名

@onready var body_sprite: AnimatedSprite2D = $BodySprite # 角色动画节点，负责播放四方向移动动画

var facing_suffix: StringName = &"right" # 当前朝向后缀，对应动画名中的 up/down/left/right

@export var move_speed: float = 120.0 # 玩家移动速度，单位是像素/秒

func _ready() -> void:
	_update_animation()

func _physics_process(_delta: float) -> void:
	var move_input: = Input.get_vector("move_left","move_right","move_up","move_down")#读取四个方向输入，并得到标准化后的八向输入向量
	velocity = move_input * move_speed
	move_and_slide()
	
	if move_input != Vector2.ZERO:
		facing_suffix = _vector_to_facing_suffix(move_input)
	
	_update_animation()

func _update_animation() -> void: # 根据当前朝向拼出动画名，并在动画实际变化时在切换播放
	var animation_name := StringName("%s_%s" % [NORMAL_ANIMATION_PREFIX, facing_suffix])
	
	if not body_sprite.sprite_frames.has_animation(animation_name):
		push_warning("Missing Player animation: %s" % animation_name)
		return
	
	if body_sprite.animation != animation_name:
		body_sprite.play(animation_name)

# 将任意二维向量映射为四方向动画
# 对角输入会优先取绝对值最大的轴，避免在四方向动画里出现歧义
func _vector_to_facing_suffix(direction: Vector2) -> StringName:
	if abs(direction.x) >= abs(direction.y):
		return &"right" if direction.x > 0.0 else &"left"
	
	return &"down" if direction.y > 0.0 else &"up"
