# Control a moving head light with alesis v49 keyboard 

extends Node

var aim_x = 0
var aim_y = 0
var color = 0
var gobo = 0
var strobe = 0
var dimmer = 0



var wheel = 0

var pad = 0

var knob1 =0
var knob2 =0
var knob3 =0
var knob4 =0
var padtapped = false
func _ready() -> void:
	OS.open_midi_inputs()

func _input(event: InputEvent) -> void:
	if event is InputEventMIDI:	
		#print(event, ", controler_value=",event.controller_value, ", controler_number=",event.controller_number)
		
		#wheel
		if event.message == 11:
			
			if event.controller_number == 1:
				wheel = event.controller_value * 1.6 
			
			# Knob 1
			if event.controller_number == 20:
				knob1 = event.controller_value / 160.0
			# Knob 2
			if event.controller_number == 21:
				knob2 = event.controller_value / 160.0
			# Knob 3
			if event.controller_number == 22:
				knob3 = event.controller_value / 160.0
			# Knob 4
			if event.controller_number == 23:
				knob4 = event.controller_value / 160.0
				
		if event.channel in [9]:
			pad = event.pitch - 36
			if pad == 0:
				color = 0
			if pad == 1:
				color = 10
			if pad == 2:
				color = 20
			if pad == 3:
				color = 30
			if pad == 13:
				color = 40
			if pad == 5:
				color = 50
			if pad == 6:
				color = 60
			if pad == 10:
				color = 70
			padtapped = true
			
			print(pad)
			
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	dimmer -= (dimmer/2) * (knob4/2)
	print(dimmer)
	if padtapped:
		dimmer = wheel
		padtapped = false
    
	dimmer = clamp(dimmer, 0,255)

	var data = [knob1*255, knob1, knob2*255, knob2, color, knob3 ,0,dimmer, 5]

	#print(data)
	Artnet.send(PackedByteArray(data))
