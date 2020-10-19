// Copyright(C) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module particle

import rand

import sokol.sgl

type Painter = CustomPainter | RectPainter | ImagePainter

pub struct CustomPainter {
mut:
	groups		[]string
//	draw		fn(mut cp CustomPainter, mut p Particle)
//	user_data	voidptr
}

pub struct RectPainter {
mut:
	groups			[]string
	color			Color = Color{255,255,255,255}
	color_variation	ColorVariation
}

fn (mut rp RectPainter) init(mut p Particle) {

	p.color.r = rp.color.r
	p.color.g = rp.color.g
	p.color.b = rp.color.b
	p.color.a = rp.color.a

	rp.color_variation.max(1.0)
	p.color.variation(rp.color_variation)
	p.init.color = p.color
}

fn (rp RectPainter) draw(mut p Particle) {
	fast := p.rotation == 0 && p.scale == 1

	p.color.a = byte(p.init.color.a * remap(p.life_time, p.init.life_time, p.end.life_time, 1, 0))
	//p.color.a = byte(remap(p.life_time, p.init.life_time, p.end.life_time, 255, 0))

	//if p.color.eq(default_color) {
	//	println('${p.life_time}/${p.init.life_time}')
	//}

	l := p.position
	if fast {
		lx := f32(l.x)-f32(p.size.x)*0.5
		ly := f32(l.y)-f32(p.size.y)*0.5
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
		sgl.translate(-f32(p.size.x)*0.5, -f32(p.size.y)*0.5, 0)

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

pub struct ImagePainter {
mut:
	groups			[]string

	color			Color
	color_variation	ColorVariation

	path			string

	image			Image
}

fn (mut ip ImagePainter) init(mut p Particle) {
	p.color.r = ip.color.r
	p.color.g = ip.color.g
	p.color.b = ip.color.b
	p.color.a = ip.color.a

	ip.color_variation.max(1.0)
	p.color.variation(ip.color_variation)
	p.init.color = p.color
}

fn (mut ip ImagePainter) draw(mut p Particle) {

	if !ip.image.ready {
		eprintln('Loading image "${ip.path}" on demand')
		ip.image = p.system.load_image(ip.path, true) or { panic(err) }
	}

	p.color.a = byte(p.init.color.a * remap(p.life_time, p.init.life_time, p.end.life_time, 1, 0))

	u0 := f32(0.0)
	v0 := f32(0.0)
	u1 := f32(1.0)
	v1 := f32(1.0)
	x0 := f32(0)
	y0 := f32(0)
	x1 := f32(p.size.x)
	y1 := f32(p.size.y)

	pre_tx := f32(p.size.x)
	pre_ty := f32(p.size.y)
	pre_tz := 0//f32(p.position.z)

	//println(pre_ty)

	sgl.push_matrix()

		sgl.enable_texture()
		sgl.texture(ip.image.sg_image)

		sgl.translate(f32(p.position.x), f32(p.position.y), pre_tz)
		sgl.translate(-pre_tx*0.5, -pre_ty*0.5, pre_tz)

		if p.rotation != 0.0 {
			sgl.translate(pre_tx*0.5, pre_ty*0.5, pre_tz)
			sgl.rotate(sgl.rad(p.rotation), 0, 0, 1)
			sgl.translate(-pre_tx*0.5, -pre_ty*0.5, pre_tz)
		}

		if p.scale != 1.0 {
			sgl.translate(pre_tx*0.5, pre_ty*0.5, pre_tz)
			sgl.scale(p.scale, p.scale, 1)
			sgl.translate(-pre_tx*0.5, -pre_ty*0.5, pre_tz)
		}

		sgl.c4b(p.color.r, p.color.g, p.color.b, p.color.a)

		sgl.begin_quads()
		sgl.v2f_t2f(x0, y0,	  u0, v0)
		sgl.v2f_t2f(x1, y0,	  u1, v0)
		sgl.v2f_t2f(x1, y1,	  u1, v1)
		sgl.v2f_t2f(x0, y1,	  u0, v1)
		sgl.end()
		sgl.disable_texture()
	sgl.pop_matrix()
}
