// Copyright(C) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module particle

import rand
import particle.vec

const (
	default_size = vec.Vec2{6,6}
	default_life_time = 1000.0
	default_color = Color{255, 255, 255, 255} //Color{38, 125, 244, 255}
)


fn new_particle(system &System) &Particle {

	ip := &Particle{
		init: 0
		system:			system
		position:		vec.Vec2{0,0}
		velocity:		vec.Vec2{0,0}
		acceleration:	vec.Vec2{0,0}
		size:			default_size

		rotation:		0
		scale:			1

		color:			default_color

		life_time:		default_life_time
	}

	p := &Particle {
		init:			ip
		system:			ip.system
		position:		ip.position
		velocity:		ip.velocity
		acceleration:	ip.acceleration
		size:			ip.size

		rotation:		ip.rotation
		scale:			ip.scale

		color:			ip.color

		life_time:		ip.life_time
	}
	return p
}

/*
* Particle
*/
pub struct Particle {
	system			&System
mut:
	init			&Particle
	position		vec.Vec2
	velocity		vec.Vec2
	acceleration	vec.Vec2
	size			vec.Vec2

	rotation		f32
	scale			f32

	color			Color

	life_time		f32

	size_end		vec.Vec2

	group			string // TODO
}

pub fn (mut p Particle) set_init() {
	p.init.position = p.position
	p.init.velocity = p.velocity
	p.init.acceleration = p.acceleration
	p.init.size = p.size
	p.init.rotation = p.rotation
	p.init.scale = p.scale
	p.init.color = p.color
	p.init.life_time = p.life_time
	//p.init.size_start = p.size_start
	p.init.size_end = p.size_end
}

pub fn (mut p Particle) update(dt f64) {
	mut acc := p.acceleration
	acc.multiply_f64(dt)
	p.velocity = p.velocity.add(acc)
	p.position = p.position.add(p.velocity)

	p.life_time -= f32(1000 * dt)
	if p.life_time > 0 {
		p.color.a = byte(remap(p.life_time, p.init.life_time, 0.0, 255, 0))

		p.size.x = f32(remap(p.life_time, p.init.life_time, 0.0, p.init.size.x, p.size_end.x))
		p.size.y = f32(remap(p.life_time, p.init.life_time, 0.0, p.init.size.y, p.size_end.y))

		p.rotation += 360 * f32(dt)
		//p.scale = f32(remap(p.life_time,0.0,p.init.life_time,0,1))
		//println('lt ${p.life_time}/${p.init.life_time} s ${p.scale} a ${p.color.a}')
	} else {
		p.life_time = 0
	}

	//println('${p.life_time:.2f}')
}

pub fn (p Particle) is_dead() bool {
	return p.life_time <= 0
}

pub fn (mut p Particle) reset() {
	p.position.zero()
	p.acceleration.zero()
	p.velocity.zero()
	p.color = default_color

	p.rotation = 0
	p.scale = 1

	p.life_time = default_life_time

	p.set_init()
}

pub fn (mut p Particle) free() {
	unsafe{
		free(p.init)
		free(p)
		p = 0
	}
}

/*
pub fn (ctx &Context) draw_image(x, y, width, height f32, img_ &Image) {
	if img_.id >= ctx.image_cache.len {
		eprintln('bad img id $img_.id (img cache len = $ctx.image_cache.len)')
		return
	}
	img := ctx.image_cache[img_.id] // fetch the image from cache
	if !img.simg_ok {
		return
	}
	u0 := f32(0.0)
	v0 := f32(0.0)
	u1 := f32(1.0)
	v1 := f32(1.0)
	x0 := f32(x) * ctx.scale
	y0 := f32(y) * ctx.scale
	x1 := f32(x + width) * ctx.scale
	y1 := f32(y + height) * ctx.scale
	//
	sgl.load_pipeline(ctx.timage_pip)
	sgl.enable_texture()
	sgl.texture(img.simg)
	sgl.begin_quads()
	sgl.c4b(255, 255, 255, 255)
	sgl.v2f_t2f(x0, y0,	  u0, v0)
	sgl.v2f_t2f(x1, y0,	  u1, v0)
	sgl.v2f_t2f(x1, y1,	  u1, v1)
	sgl.v2f_t2f(x0, y1,	  u0, v1)
	sgl.end()
	sgl.disable_texture()
}

// TODO remove copy pasta, merge the functions
pub fn (ctx &Context) draw_image_flipped(x, y, width, height f32, img_ &Image) {
	if img_.id >= ctx.image_cache.len {
		eprintln('gg: draw_image() bad img id $img_.id (img cache len = $ctx.image_cache.len)')
		return
	}
	img := ctx.image_cache[img_.id] // fetch the image from cache
	if !img.simg_ok {
		return
	}
	u0 := f32(0.0)
	v0 := f32(0.0)
	u1 := f32(1.0)
	v1 := f32(1.0)
	x0 := f32(x) * ctx.scale
	y0 := f32(y) * ctx.scale
	x1 := f32(x + width) * ctx.scale
	y1 := f32(y + height) * ctx.scale
	//
	sgl.load_pipeline(ctx.timage_pip)
	sgl.enable_texture()
	sgl.texture(img.simg)
	sgl.begin_quads()
	sgl.c4b(255, 255, 255, 255)
	sgl.v2f_t2f(x0, y0,   u1, v0)
	sgl.v2f_t2f(x1, y0,   u0, v0)
	sgl.v2f_t2f(x1, y1,   u0, v1)
	sgl.v2f_t2f(x0, y1,   u1, v1)
	sgl.end()
	sgl.disable_texture()
}

pub fn (ctx &Context) draw_image_by_id(x, y, width, height f32, id int) {
	img := ctx.image_cache[id]
	ctx.draw_image(x,y,width,height,img)
}
*/
