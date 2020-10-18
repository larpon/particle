// Copyright(C) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module particle
import particle.vec

type Shape = Point | Rect | Ellipse

pub struct Point {
pub mut:
	position	vec.Vec2
}

pub struct Rect {
pub mut:
	position	vec.Vec2
	size		vec.Vec2
}

pub struct Ellipse {
pub mut:
	position	vec.Vec2
	radius		f32
}