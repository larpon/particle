// Copyright(C) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module particle

import particle.vec
import rand

import sokol.sgl

type Component = Emitter | RectPainter // TODO

// System
pub struct SystemConfig {
	pool	int
}

pub struct System {
	width			int
	height			int
mut:
	pool			[]&Particle
	bin				[]&Particle

	image_cache		[]Image

	emitters		[]Emitter
	painters		[]Painter
//	tmp_rot f32
}

pub fn (mut s System) init(sc SystemConfig) {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' creating $sc.pool particles')
	}
	for i := 0; i < sc.pool; i++ {
		p := particle.new_particle( s )
		s.bin << p
	}
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' created $sc.pool particles')
	}
}

pub fn (mut s System) add(c Component) {
	//e.system = s
	//println('Adding something')
	match c {
		Emitter {
			eprintln('Adding emitter')
			//e := c as Emitter
			s.emitters << c
		}
		RectPainter {
			eprintln('Adding painter')
			//e := c as Emitter
			s.painters << c
		}
		/*
		else {
			println('Unknown system component ${c} ')
			return
		}*/
	}
}

pub fn (mut s System) get_emitter(index int) &Emitter {
	return &s.emitters[index]
}

pub fn (mut s System) update(dt f64) {
	/*if dt == 0.0 {
		dt = 0.000001
	}*/

	for i := 0; i < s.emitters.len; i++ {
		s.emitters[i].update(mut s, dt)
	}

	mut p := &Particle(0)
	for i := 0; i < s.pool.len; i++ {
		p = s.pool[i]
		p.update(dt)
		if p.is_dead() {
			s.bin << p
			s.pool.delete(i)
			continue
		}
		// TODO can be optimized so particle pool is only only traversed once...
		// Draw call would be here... remove other draw calls
	}
}

pub fn (mut s System) draw() {

	//sgl.push_matrix()

		/*
		s.tmp_rot += 0.016*4

		sgl.translate(f32(s.width)*0.5, f32(s.height)*0.5, 0)
		sgl.rotate(sgl.rad(s.tmp_rot), 0, 0, 1)
		sgl.translate(-f32(s.width)*0.5, -f32(s.height)*0.5, 0)

		sgl.translate(f32(s.width)*0.5, f32(s.height)*0.5, 0)
		sgl.scale(0.5, 0.5, 1)
		sgl.translate(-f32(s.width)*0.5, -f32(s.height)*0.5, 0)

		sgl.c4f(0.2, 0.1, 0.5, 0.1)
		sgl.begin_quads()
		sgl.v2f(0, 0)
		sgl.v2f(0 + f32(s.width), 0)
		sgl.v2f(0 + f32(s.width), 0 + f32(s.height))
		sgl.v2f(0, 0 + f32(s.height))
		sgl.end()
		*/

	/**/

	mut p := &Particle(0)
	//for mut p in s.pool {
	for i := 0; i < s.pool.len; i++ {
		p = s.pool[i]
		if p.life_time <= 0 {
			continue
		}

		for painter in s.painters {
			match painter {
				RectPainter {
					if p.group in painter.groups {
						painter.draw(mut p)
					}
				}
				else {
					eprintln('Painter type ${painter} not supported')
				}
			}
		}
		//p.draw()
	}

	//sgl.pop_matrix()
}

pub fn (mut s System) reset() {
	eprintln(@MOD+'.'+@STRUCT+'::'+@FN)

	eprintln('Resetting ${s.pool.len} from pool ${s.bin.len}')
	for p in s.pool {
		mut pm := p
		pm.reset()
		pm.life_time = 0
	}

	for p in s.bin {
		mut pm := p
		pm.reset()
		pm.life_time = 0
	}
}

pub fn (mut s System) free() {

	eprintln('Freeing ${s.pool.len} from pool')
	for p in s.pool {

		if p == 0 {
			print(ptr_str(p)+' ouch')
			continue
		}

		unsafe{
			//println('Freeing from bin')
			p.free()
		}
	}
	s.pool.clear()

	eprintln('Freeing ${s.bin.len} from bin')
	for p in s.bin {

		if p == 0 {
			eprint(ptr_str(p)+' ouch')
			continue
		}

		unsafe{
			//println('Freeing from bin')
			p.free()
		}
	}
	s.bin.clear()
}