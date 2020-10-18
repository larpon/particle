// Copyright(C) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module particle

import sokol.sgl

type Painter = CustomPainter | RectPainter

pub struct CustomPainter {
mut:
	groups		[]string
//	draw		fn(mut cp CustomPainter, mut p Particle)
//	user_data	voidptr
}

pub struct RectPainter {
mut:
	groups		[]string
	color		Color
	//system	&System
}

fn (rp RectPainter) draw(mut p Particle) {
	fast := p.rotation == 0 && p.scale == 1

	p.color.r = rp.color.r
	p.color.g = rp.color.g
	p.color.b = rp.color.b

	l := p.position
	if fast {
		lx := f32(l.x)
		ly := f32(l.y)
		width := f32(p.size.x)
		height := f32(p.size.y)

		sgl.c4b(p.color.r, p.color.g, p.color.b, p.color.a)
		sgl.begin_quads()

		sgl.v2f(lx, ly)
		sgl.v2f(lx + width, ly)
		sgl.v2f(lx + width, ly + height)
		sgl.v2f(lx, ly + height)

		sgl.end()
	} else {
		sgl.push_matrix()

		//sgl.translate(0, 0, 0)
		sgl.translate(f32(l.x), f32(l.y), 0)

		sgl.translate(f32(p.size.x)*0.5, f32(p.size.y)*0.5, 0)
		sgl.rotate(sgl.rad(p.rotation), 0, 0, 1)
		sgl.translate(-f32(p.size.x)*0.5, -f32(p.size.y)*0.5, 0)

		sgl.translate(f32(p.size.x)*0.5, f32(p.size.y)*0.5, 0)
		sgl.scale(p.scale, p.scale, 1)
		sgl.translate(-f32(p.size.x)*0.5, -f32(p.size.y)*0.5, 0)

		sgl.c4b(p.color.r, p.color.g, p.color.b, p.color.a)
		sgl.begin_quads()

		sgl.v2f(0, 0)
		sgl.v2f(0 + f32(p.size.x), 0)
		sgl.v2f(0 + f32(p.size.x), 0 + f32(p.size.y))
		sgl.v2f(0, 0 + f32(p.size.y))

		sgl.end()

		//sgl.translate(f32(l.x), f32(l.y), 0)
		//sgl.rotate(float angle_rad, float x, float y, float z)
		//sgl.scale(float x, float y, float z)

		sgl.pop_matrix()
	}
}

