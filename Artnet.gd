# Example of sending ARTNET dmx packets from godot engine
# child.get_data() on line 39 returns a packed byte array of that fixture's dmx data


extends Node

var udp
var _seq_count = 1

var base_packet = PackedByteArray()
var low_universe = 0  # Universe
var high_universe = 0 # Not used

@onready var FixtureManager = $"../FixtureManager"


# Called when the node enters the scene tree for the first time.
func _ready():
	udp = PacketPeerUDP.new()
	udp.set_dest_address('192.168.0.200',6454)
	
	base_packet.append_array("Art-Net".to_ascii_buffer())
	# Null terminate the Art-Net string
	base_packet.append(0)
	
	# Opcode ArtDMX 0x5000 (Little endian)
	base_packet.append(0)
	base_packet.append(80)
	
	# Protocol version 14 
	base_packet.append(0)
	base_packet.append(14)
	
func _physics_process(delta):
	
	#Collect all the bytes from the virtual fixtures -> dta
	var dta = PackedByteArray()
	for child in FixtureManager.get_all_fixtures():
		dta.append_array(child.get_data())
	

	var new_packet = PackedByteArray(base_packet)
	#Sequence
	new_packet.append(_seq_count)
	_seq_count += 1
	if _seq_count > 255:
		_seq_count = 1
	#Physical
	new_packet.append(0)
	#subUni
	new_packet.append(low_universe)
	# net
	new_packet.append(high_universe)
	# Length Hi
	new_packet.append(0)
	new_packet.append(len(dta))
	# Length lo
	#Data
	new_packet.append_array(dta)

	udp.put_packet(new_packet)
	
	
