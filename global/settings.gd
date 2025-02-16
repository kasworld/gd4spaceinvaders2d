extends Node

const Grid_X = 13
const Grid_Y = 14
const InvaderCount_X = Grid_X - 2

const Invader_Rows = [
	Invader.Type.Invader3,
	Invader.Type.Invader2,
	Invader.Type.Invader2,
	Invader.Type.Invader1,
	Invader.Type.Invader1,
	]

#const BulletCountLimit = 2
#const BulletNextFireSec = 0.3

# for demo mode
const BulletCountLimit = 10
const BulletNextFireSec = 0.1

# Invader.Type {Invader1,Invader2,Invader3}
const InvaderScore = [10,30,50]

# UFO.MoveSpeed {Low,High}
const UFOScore = [100,500]

enum MoveDir {Right,Down,Left,Up}
static func get_dir_clockwise(dir:MoveDir) -> MoveDir:
	return (dir+1)%4 as MoveDir
static var invader_move_dir_order := [MoveDir.Right,MoveDir.Down,MoveDir.Left,MoveDir.Down]
