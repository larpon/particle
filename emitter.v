// Copyright(C) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module particle

import math
import rand

import strconv

import particle.vec

pub struct Emitter {
mut:
	position_last_frame	vec.Vec2

	system				&System = 0
	dt					f64			// current delta time this frame
	elapsed				f32			// Elapsed time accumulator

	burst_position		vec.Vec2	// Center position of the burst
	burst_amount		int
	pulse_duration		int
pub mut:
	enabled				bool

	position			vec.Vec2	// Center position of the emitter
	size				vec.Vec2	// Max size of the emitter

	velocity			StochasticDirection
	acceleration		StochasticDirection

	size_start			vec.Vec2 = default_size	// Emitted particles start their life in this size
	size_end			vec.Vec2	// Emitted particles end their life in this size
	size_variation		f32			// Particle size will vary up/down to a maximum of this value

	life_time			f32 = 1000	// How long the particles emitted will last
	life_time_variation	f32			// Particle life time will vary up/down to a maximum of this value

	rate				f32 = 10.0	// Particles emitted per second

	group				string		// Logical group the particles belongs to

	shape				Shape		// TODO

	/*
	Provide an additional starting velocity to the emitted particles based on the emitter's movement.
	The added velocity vector will have the same angle as the emitter's movement,
	with a magnitude that is the magnitude of the emitters movement multiplied by the  movement_velocity.
	*/
	movement_velocity		f32
	movement_velocity_flip	bool
}

/*
pub fn (mut e Emitter) move_to(v vec.Vec2) {
	e.position.from(v)
}*/

pub fn (mut e Emitter) burst(amount int) {
	e.burst_amount = amount
}

pub fn (mut e Emitter) burst_at(amount int, position vec.Vec2) {
	e.burst_position.from(position)
	e.burst(amount)
}

pub fn (mut e Emitter) pulse(duration_ms int) {
	e.pulse_duration = duration_ms
}

pub fn (mut e Emitter) update(mut s &System, dt f64) {
	e.dt = dt
	e.system = s

	if e.burst_amount > 0 {
		e.emit()
		e.position_last_frame.from(e.position)
		return
	}

	if e.pulse_duration > 0 {
		e.pulse_duration -= int(dt * 1000)
		if e.pulse_duration <= 0 {
			e.pulse_duration = 0
			e.enabled = false
		} else {
			e.enabled = true
		}
	}

	if !e.enabled {
		return
	}
	e.emit()
	e.position_last_frame.from(e.position)
}

fn (mut e Emitter) emit() {
	mut s := e.system
	dt := e.dt
	//mut s := e.system
	e.elapsed += f32(dt)

	mut reserve := e.rate * e.elapsed

	mut bursting := false
	if e.burst_amount > 0 {
		bursting = true
		//e.burst_position.x += 0.000000000000000001
		if s.bin.len >= e.burst_amount {
			reserve = e.burst_amount
		} else {
			reserve = s.bin.len
		}
		e.burst_amount -= int(reserve)
	}

	if reserve < 1 {
		//eprintln('Accumulating time. Reserve ${reserve} elapsed ${e.elapsed} dt ${dt} rate ${e.rate}')
		return
	}
	e.elapsed = 0
	//eprintln('Reserving ${reserve} particles from pool of ${s.bin.len}')
	mut p := &Particle(0)
	for i := 0; i < s.bin.len && reserve > 0; i++ {
		p = s.bin[i]
		p.reset()

		p.group = e.group

		if bursting && !e.burst_position.eq_f64(0.0) {
			p.position.from(e.burst_position)
			e.position_last_frame.from(p.position) // Stop movement_velocity this frame
		} else {
			p.position.from(e.position)
		}

		e.apply_stochastic_direction(mut p.velocity, e.velocity)
		e.apply_stochastic_direction(mut p.acceleration, e.acceleration)

		p.life_time = e.life_time
		if e.life_time_variation != 0.0 {
			p.life_time += rand.f32_in_range(-e.life_time_variation,e.life_time_variation)
		}
		p.size = e.size_start
		p.size_end = e.size_end
		if e.size_variation != 0.0 {
			sv := rand.f32_in_range(-e.size_variation,e.size_variation)
			p.size.x = p.size.x + sv
			p.size.y = p.size.y + sv
		}
		p.set_init()
		// Send the particle into the system
		s.pool << p
		// Remove from the available particle bin
		s.bin.delete(i)
		reserve--
	}

	if e.burst_amount <= 0 {
		bursting = false
		e.burst_position.zero()
	}
}

fn (mut e Emitter) apply_stochastic_direction(mut v vec.Vec2, sd StochasticDirection) {
	match sd {
		PointDirection {
			v.from(sd.point)

			if !sd.point_variation.eq_f64(0.0) {
				mut pv := sd.point_variation + vec.Vec2{0,0} //.copy()
				pv.abs()
				if pv.x > 0 {
					v.x += rand.f64_in_range(-pv.x, pv.x)
				}
				if pv.y > 0 {
					v.y += rand.f64_in_range(-pv.y, pv.y)
				}
			}

			if e.movement_velocity != 0.0 && !e.position.eq(e.position_last_frame) {
				d := if e.movement_velocity_flip {
					e.position_last_frame - e.position
				} else {
					e.position - e.position_last_frame
				}
				fvm := (e.movement_velocity/1000)
				angle_rad := d.angle()
				magnitude := f32(e.position.manhattan_distance(d))

				v.x += fvm * (magnitude * math.cos(angle_rad)) * e.dt
				v.y += fvm * (magnitude * math.sin(angle_rad)) * e.dt
			}

		}
		AngleDirection {
			mut angle := sd.angle
			if sd.angle_variation != 0.0 {
				av := math.fabs(sd.angle_variation)
				angle += f32(rand.f64_in_range(-av, av))
			}
			mut magnitude := sd.magnitude
			if sd.magnitude_variation != 0.0 {
				mv := math.fabs(sd.magnitude_variation)
				magnitude += f32(rand.f64_in_range(-mv, mv))
			}
			v.x = magnitude * math.cos(math.radians(angle))
			v.y = magnitude * math.sin(math.radians(angle))
		}
		TargetDirection {
			mut target := e.position - sd.target
			if !sd.target_variation.eq_f64(0.0) {
				mut tv := sd.target_variation + vec.Vec2{0,0} // .copy()
				tv.abs()
				if tv.x > 0 {
					target.x += rand.f64_in_range(-tv.x, tv.x)
				}
				if tv.y > 0 {
					target.y += rand.f64_in_range(-tv.y, tv.y)
				}
			}
			mut angle_rad := f64(0)
			if target.x != 0.0 {
				angle_rad = math.atan2(-target.y, -target.x) // flip (-) values to reach screen coordinates
			}

			mut magnitude := sd.magnitude
			if sd.proportional_magnitude {
				magnitude = f32(e.position.manhattan_distance(sd.target))
			}
			if sd.magnitude_variation != 0.0 {
				mv := math.fabs(sd.magnitude_variation)
				magnitude += f32(rand.f64_in_range(-mv, mv))
			}
			v.x = magnitude * math.cos(angle_rad)
			v.y = magnitude * math.sin(angle_rad)
		}
	}
}