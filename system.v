// Copyright(C) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module particle

type Component = Emitter | RectPainter | ImagePainter // TODO

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

	image_cache		map[string]Image

	emitters		[]Emitter
	painters		[]Painter
}

pub fn (mut s System) init(sc SystemConfig) {
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' creating $sc.pool particles.')
	}
	for i := 0; i < sc.pool; i++ {
		p := s.new_particle()
		s.bin << p
	}
	$if debug {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' created $sc.pool particles.')
	}

	if s.painters.len == 0 {
		$if debug {
			eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' adding default painter.')
		}
		s.add(RectPainter{
			groups: [""]
			color: particle.default_color
		})
	}
}

pub fn (mut s System) add(c Component) {
	//eprintln('Adding something')
	match mut c {
		Emitter {
			eprintln('Adding emitter')
			//e := c as Emitter
			c.system = s
			s.emitters << c
		}
		RectPainter {
			eprintln('Adding rectangle painter')
			//e := c as Emitter
			s.painters << c
		}
		ImagePainter {
			eprintln('Adding image painter')
			//e := c as Emitter
			//c.system = s
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

pub fn (mut s System) get_emitters(groups []string) []&Emitter {
	mut collected := []&Emitter{}
	for i := 0; i < s.emitters.len; i++ {
		emitter := &s.emitters[i]
		for group in groups {
			if emitter.group == group {
				collected << emitter
			}
		}
	}
	return collected
}

pub fn (mut s System) update(dt f64) {
	/*if dt == 0.0 {
		dt = 0.000001
	}*/

	for i := 0; i < s.emitters.len; i++ {
		s.emitters[i].update(dt)
	}

	mut p := &Particle(0)
	for i := 0; i < s.pool.len; i++ {
		p = s.pool[i]

		if p.init.eq(p) {
			for mut painter in s.painters {
				match mut painter {
					RectPainter {
						if p.group in painter.groups {
							painter.init(mut p)
						}
					}
					ImagePainter {
						if p.group in painter.groups {
							painter.init(mut p)
						}
					}
					else {
						//eprintln('Painter type ${painter} not supported') // <- struct printing results in some C error
						eprintln('Painter type init not needed')
					}
				}
			}
		}

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

	mut p := &Particle(0)
	//for mut p in s.pool {
	for i := 0; i < s.pool.len; i++ {
		p = s.pool[i]
		if p.is_dead() || !p.is_ready() {
			continue
		}

		for mut painter in s.painters {
			match mut painter {
				RectPainter {
					if p.group in painter.groups {
						painter.draw(mut p)
					}
				}
				ImagePainter {
					if p.group in painter.groups {
						painter.draw(mut p)
					}
				}
				else {
					//eprintln('Painter type ${painter} not supported') // <- struct printing results in some C error
					eprintln('Painter type not supported')
				}
			}
		}
	}

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

	for key, image in s.image_cache {
		eprintln('Freeing ${key} from image cache')
		mut im := image
		im.free()
	}

	eprintln('Freeing ${s.pool.len} from pool')
	for p in s.pool {

		if p == 0 {
			print(ptr_str(p)+' ouch')
			continue
		}

		unsafe{
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