// Copyright(C) 2020-2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module main

import os
import time
import sokol.sapp
import sokol.gfx
import sokol.sgl
import particle
import particle.vec

fn main() {
	mut app := &App{
		width: 1200
		height: 800
		pass_action: gfx.create_clear_pass(0.0, 0.0, 0.0, 1.0)
	}
	app.init()
	app.run()
}

struct App {
	pass_action gfx.PassAction
mut:
	width  int
	height int

	frame i64

	last i64

	ps        &particle.System = unsafe { nil }
	alpha_pip sgl.Pipeline
}

fn (mut a App) init() {
	a.frame = 0
	a.last = time.ticks()

	a.ps = &particle.System{
		width: a.width
		height: a.height
	}

	flame_scale := 3.0
	fe1 := particle.Emitter{
		enabled: true
		rate: 50
		group: 'flame-outer'
		velocity: particle.PointDirection{
			point: vec.Vec2{0, -0.5 * flame_scale * 0.5}
			point_variation: vec.Vec2{0.2, 0.5}
		}
		acceleration: particle.PointDirection{
			point: vec.Vec2{0, -1.5 * flame_scale * 0.5}
			point_variation: vec.Vec2{0.4, 0.7}
		}
		start_size: vec.Vec2{70 * flame_scale, 75 * flame_scale}
		size_variation: vec.Vec2{10 * flame_scale, 10 * flame_scale}
		life_time: 2000
		life_time_variation: 1000
		movement_velocity: 50
		// movement_velocity_flip: true
	}
	a.ps.add(fe1)

	fe2 := particle.Emitter{
		enabled: true
		rate: 40
		group: 'flame-inner'
		velocity: particle.PointDirection{
			point: vec.Vec2{0, -0.45 * flame_scale * 0.5}
			point_variation: vec.Vec2{0.2, 0.5}
		}
		acceleration: particle.PointDirection{
			point: vec.Vec2{0, -1.5 * flame_scale * 0.5}
			point_variation: vec.Vec2{0.4, 0.7}
		}
		start_size: vec.Vec2{40 * flame_scale, 42 * flame_scale}
		size_variation: vec.Vec2{8 * flame_scale, 9 * flame_scale}
		life_time: 500
		life_time_variation: 500
		movement_velocity: 50
		// movement_velocity_flip: true
	}
	a.ps.add(fe2)

	bottom_right := vec.Vec2{f64(a.width), f64(a.height)}

	vwhdiv6 := vec.Vec2{f64(a.width) / 6, f64(a.height) / 6}
	e1 := particle.Emitter{
		// enabled: true
		position: vwhdiv6
		group: 'test'
		rate: 10
		velocity: particle.PointDirection{
			point_variation: vec.Vec2{0.5, 0.5}
		}
		acceleration: particle.PointDirection{
			point_variation: vec.Vec2{0.7, 0.7}
		}
		life_time: 2000
		life_time_variation: 4000
	}
	a.ps.add(e1)

	e2 := particle.Emitter{
		// enabled: true
		position: vec.Vec2{vwhdiv6.x * 2, vwhdiv6.y}
		rate: 4.5
		group: 'test'
		velocity: particle.AngleDirection{
			angle: -90
			angle_variation: 25
			magnitude: 0.2
			magnitude_variation: 0.01
		}
		acceleration: particle.AngleDirection{
			angle: -90
			angle_variation: 25
			magnitude: 1
			magnitude_variation: 0.4
		}
		life_time: 2000
		life_time_variation: 1000
	}
	a.ps.add(e2)

	e3 := particle.Emitter{
		// enabled: true
		position: vec.Vec2{vwhdiv6.x * 3, vwhdiv6.y}
		rate: 4.5
		group: 'test'
		velocity: particle.TargetDirection{
			target: bottom_right
			target_variation: vec.Vec2{0.5, 0.5}
			magnitude: 5
			magnitude_variation: 2
			// proportional_magnitude:	true
		}
		acceleration: particle.TargetDirection{
			target: bottom_right
			target_variation: vec.Vec2{bottom_right.x * 0.2, bottom_right.y * 0.2}
			magnitude: 5
			magnitude_variation: 0.5
			// proportional_magnitude: true
		}
		life_time: 2000
		life_time_variation: 1000
	}
	a.ps.add(e3)

	dot_image_path := os.join_path(@VMODROOT, 'assets', 'dot.png')

	// Fire
	imp := particle.ImagePainter{
		groups: ['flame-outer']
		color: particle.Color{221, 6, 35, 27}
		color_variation: particle.ColorVariation{0.1, 0.1, 0.1, 0.1}
		path: dot_image_path
	}
	a.ps.add(particle.Painter(imp))

	imp2 := particle.ImagePainter{
		groups: ['flame-inner']
		color: particle.Color{221, 197, 13, 200}
		color_variation: particle.ColorVariation{0, 0, 0, 0.3}
		path: dot_image_path
	}
	a.ps.add(particle.Painter(imp2))

	ga1 := particle.GravityAffector{
		enabled: true
		position: vec.Vec2{f64(a.width) * 0.5, f64(a.height)}
		size: vec.Vec2{f64(a.width), f64(a.height)}
		groups: ['flame-outer', 'flame-inner']
		angle: 180
		magnitude: 25
	}
	a.ps.add(particle.Affector(ga1))

	a.ps.init(pool: 20000)
}

fn (mut a App) cleanup() {
	eprintln(@MOD + '.' + @STRUCT + '::' + @FN + '')
	a.ps.free()
	unsafe {
		free(a.ps)
	}
	sgl.destroy_pipeline(a.alpha_pip)
}

fn cleanup(user_data voidptr) {
	mut app := &App(user_data)
	app.cleanup()
	gfx.shutdown()
}

fn (a App) run() {
	title := 'Fire Particles'
	desc := sapp.Desc{
		width: a.width
		height: a.height
		user_data: &a
		init_userdata_cb: init
		frame_userdata_cb: frame
		event_userdata_cb: event
		window_title: title.str
		html5_canvas_name: title.str
		cleanup_userdata_cb: cleanup
	}

	sapp.run(&desc)
}

fn (mut a App) draw() {
	sgl.load_pipeline(a.alpha_pip)
	a.ps.draw()
}

fn init(user_data voidptr) {
	mut app := &App(user_data)

	desc := gfx.Desc{}

	gfx.setup(&desc)

	sgl_desc := sgl.Desc{
		max_vertices: 4 * 65536
		max_commands: 2 * 16384
	}
	sgl.setup(&sgl_desc)

	mut pipdesc := gfx.PipelineDesc{}
	unsafe {
		vmemset(&pipdesc, 0, int(sizeof(pipdesc)))
	}

	color_state := gfx.ColorState{
		blend: gfx.BlendState{
			enabled: true
			src_factor_rgb: .src_alpha
			dst_factor_rgb: .one_minus_src_alpha
		}
	}
	pipdesc.colors[0] = color_state

	app.alpha_pip = sgl.make_pipeline(&pipdesc)
}

fn frame(user_data voidptr) {
	mut app := &App(user_data)

	app.width = sapp.width()
	app.height = sapp.height()

	t := time.ticks()
	dt := f64(t - app.last) / 1000.0

	// eprintln(time.ticks().str() + ' vs ' + app.last.str())
	// eprintln('${dt:.2f}')

	sgl.default_pipeline()

	app.ps.update(dt)
	draw(mut app)

	gfx.begin_default_pass(&app.pass_action, app.width, app.height)

	sgl.draw()

	gfx.end_pass()
	gfx.commit()

	app.frame++
	app.last = t
}

fn event(ev &sapp.Event, user_data voidptr) {
	mut app := &App(user_data)

	mut emitter := app.ps.get_emitter(0)
	// mut emitter1 := app.ps.get_emitter(1)

	flame_emitters := app.ps.get_emitters(['flame-outer', 'flame-inner'])

	mut target_emitter := app.ps.get_emitter(4)

	// eprintln('Mouse @'+ev.mouse_x.str()+','+ev.mouse_y.str()+' Button' )

	if ev.@type == .mouse_move {
		// eprintln('${ev.mouse_x:.4f},${ev.mouse_y:.4f}')
		for i := 0; i < flame_emitters.len; i++ {
			mut em := flame_emitters[i]
			em.position.x = ev.mouse_x
			em.position.y = ev.mouse_y
		}
	}

	if ev.@type == .mouse_up || ev.@type == .mouse_down {
		if ev.mouse_button == .left {
			is_pressed := ev.@type == .mouse_down

			// xy := ev.mouse_x.str()+','+ev.mouse_y.str()
			if is_pressed {
				// eprintln('Left pressed @'+xy)

				for i := 0; i < flame_emitters.len; i++ {
					mut em := flame_emitters[i]
					em.enabled = !em.enabled
				}
				emitter.pulse(50)
				// emitter.burst_at(500,vec.Vec2{200,200})
				// emitter.burst(500)

				mut tea := target_emitter.acceleration
				match mut tea {
					particle.TargetDirection {
						tea.target.x = emitter.position.x
						tea.target.y = emitter.position.y
					}
					else {}
				}
			} else {
				// eprintln('Left clicked @'+xy)
			}
		}

		if ev.mouse_button == .right {
			is_pressed := ev.@type == .mouse_down

			// xy := ev.mouse_x.str()+','+ev.mouse_y.str()
			if is_pressed {
				// emitter.pulse(500)
				// emitter.burst_at(500,vec.Vec2{200,200})
				// 500
				emitter.burst(20)
			} else {
				// eprintln('Left clicked @'+xy)
			}
		}
	}

	if ev.@type == .key_up || ev.@type == .key_down {
		if ev.key_code == .r {
			is_pressed := ev.@type == .key_down

			if is_pressed {
				app.ps.reset()
			}
			/*
			else {
				eprintln('Left clicked @'+xy)
			}*/
		}

		if ev.key_code == .escape {
			released := ev.@type == .key_up
			if released {
				sapp.quit()
			}
		}
	}
	// eprintln(ev.str())

	if ev.@type == .touches_began || ev.@type == .touches_moved {
		if ev.num_touches > 0 {
			touch_point := ev.touches[0]

			for i := 0; i < flame_emitters.len; i++ {
				mut em := flame_emitters[i]
				em.position.x = touch_point.pos_x
				em.position.y = touch_point.pos_y
			}
		}
	}
}

fn draw(mut a App) {
	// first, reset and setup ortho projection

	sgl.defaults()
	sgl.matrix_mode_projection()

	// sgl.perspective(60, f32(sapp.width())/f32(sapp.height()), 0.1, 1000.0)
	sgl.ortho(0, f32(sapp.width()), f32(sapp.height()), 0.0, -1.0, 1.0)
	// sgl.viewport(0, 0, sapp.width(), sapp.height(), true)

	// sgl.push_matrix()
	a.draw()
	// sgl.pop_matrix()
}
