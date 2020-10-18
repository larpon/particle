# particle
Particle system written in V

Example `main.v`
```
module main

import time

import sokol
import sokol.sapp
import sokol.gfx
import sokol.sgl

import particle
import particle.vec

const (
	used_import = sokol.used_import
)

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
	pass_action C.sg_pass_action
mut:
	width		int
	height		int

	last		i64

	ps			&particle.System = 0
	alpha_pip	C.sgl_pipeline
}

fn (mut a App) init() {
	a.ps = &particle.System{
		width: a.width
		height: a.height
	}

	e := particle.Emitter{
		//enabled: false
		rate: 200
		velocity: particle.PointDirection{
			point_variation: vec.Vec2{0.5,0.5}
		}
		acceleration: particle.PointDirection{
			//point: vec.Vec2{0.1,5}
			point_variation: vec.Vec2{0.7,0.7}
		}
		life_time: 4000
		life_time_variation: 2000
		movement_velocity: 50
		//movement_velocity_flip: true
	}
	a.ps.add(e)

	bottom_right := vec.Vec2{f64(a.width),f64(a.height)}

	vwhdiv6 := vec.Vec2{f64(a.width)/6,f64(a.height)/6}
	e1 := particle.Emitter{
		//enabled: true
		position: vwhdiv6
		rate: 10
		velocity: particle.PointDirection{
			point_variation: vec.Vec2{0.5,0.5}
		}
		acceleration: particle.PointDirection{
			point_variation: vec.Vec2{0.7,0.7}
		}
		life_time: 2000
		life_time_variation: 4000
	}
	a.ps.add(e1)

	e2 := particle.Emitter{
		//enabled: true
		position: vec.Vec2{vwhdiv6.x*2,vwhdiv6.y}
		rate: 4.5
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
		//enabled: true
		position: vec.Vec2{vwhdiv6.x*3,vwhdiv6.y}
		rate: 4.5
		velocity: particle.TargetDirection {
			target:					bottom_right
			target_variation:		vec.Vec2{0.5,0.5}
			magnitude:				5
			magnitude_variation:	2
			//proportional_magnitude:	true
		}
		acceleration: particle.TargetDirection {
			target:					bottom_right
			target_variation:		vec.Vec2{bottom_right.x*0.2,bottom_right.y*0.2}
			magnitude:				5
			magnitude_variation:	0.5
			//proportional_magnitude: true
		}
		life_time: 2000
		life_time_variation: 1000
	}
	a.ps.add(e3)

	painter := particle.RectPainter{
		groups: [""]
		color: particle.Color{255,0,0,255}
	}
	a.ps.add(painter)

	a.ps.init({pool: 20000})
}

fn (mut a App) cleanup() {
	a.ps.free()
	free(a.ps)
	sgl.destroy_pipeline(a.alpha_pip)
}

fn cleanup(user_data voidptr) {
	mut app := &App(user_data)
	app.cleanup()
	gfx.shutdown()
}

fn (a App) run() {
	title := 'V Particles'
	desc := C.sapp_desc{
		width: a.width
		height: a.height
		user_data: &a
		init_userdata_cb: init
		frame_userdata_cb: frame
		event_userdata_cb: event
		window_title: title.str
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

	desc := C.sg_desc{
		/*mtl_device: sapp.metal_get_device()
		mtl_renderpass_descriptor_cb: sapp.metal_get_renderpass_descriptor
		mtl_drawable_cb: sapp.metal_get_drawable
		d3d11_device: sapp.d3d11_get_device()
		d3d11_device_context: sapp.d3d11_get_device_context()
		d3d11_render_target_view_cb: sapp.d3d11_get_render_target_view
		d3d11_depth_stencil_view_cb: sapp.d3d11_get_depth_stencil_view*/
	}

	gfx.setup(&desc)

	sgl_desc := C.sgl_desc_t {
		max_vertices: 4*65536
		max_commands: 2*16384
		//color_format: gfx.PixelFormat.rgba32f // C.sg_pixel_format( C.SG_PIXELFORMAT_RGBA32F )
		//color_format: .rgba32f
		//depth_format: .rgba32f
	}
	sgl.setup(&sgl_desc)

	mut pipdesc := C.sg_pipeline_desc{}
	unsafe {
		C.memset(&pipdesc, 0, sizeof(pipdesc))
	}
	pipdesc.blend.enabled = true
	pipdesc.blend.src_factor_rgb = C.SG_BLENDFACTOR_SRC_ALPHA
	pipdesc.blend.dst_factor_rgb = C.SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA
	app.alpha_pip = sgl.make_pipeline(&pipdesc)

	//gfx C.sg_query_pipeline_defaults
	//sgl.default_pipeline
}

fn frame(user_data voidptr) {
	mut app := &App(user_data)

	app.width = sapp.width()
	app.height = sapp.height()
  
	t := time.ticks()
	dt := f64(t - app.last) / 1000.0

	sgl.default_pipeline()

	app.ps.update(dt)
	draw(mut app)

	gfx.begin_default_pass(&app.pass_action, app.width, app.height)

	sgl.draw()

	gfx.end_pass()
	gfx.commit()

	app.last = t
}

fn event(ev &C.sapp_event, user_data voidptr) {
	mut app := &App(user_data)

	mut emitter := app.ps.get_emitter(0)
	mut target_emitter := app.ps.get_emitter(3)

	if ev.@type == .mouse_move {
		emitter.position.x = ev.mouse_x
		emitter.position.y = ev.mouse_y
	}

	if ev.@type == .mouse_up || ev.@type == .mouse_down {
		if ev.mouse_button == .left {
			is_pressed := ev.@type == .mouse_down

			if is_pressed {
				emitter.enabled = !emitter.enabled
				
				mut tea := target_emitter.acceleration
				match mut tea {
					particle.TargetDirection {
						tea.target.x = emitter.position.x
						tea.target.y = emitter.position.y
					}
					else { }
				}
			}
		}

		if ev.mouse_button == .right {
			is_pressed := ev.@type == .mouse_down

			if is_pressed {
				emitter.burst(500)
			}
		}
	}

	if ev.@type == .key_up || ev.@type == .key_down {
		if ev.key_code == .r {
			is_pressed := ev.@type == .key_down

			if is_pressed {
				app.ps.reset()
			}
		}

		if ev.key_code == .escape {
			released := ev.@type == .key_up
			if released {
				sapp.quit()
			}
		}
	}
	if ev.@type == .touches_began || ev.@type == .touches_moved {
		if ev.num_touches > 0 {

			touch_point := ev.touches[0]

			emitter.position.x = touch_point.pos_x
			emitter.position.y = touch_point.pos_y
		}
	}
}

fn draw(mut a App) {
	sgl.defaults()
	sgl.matrix_mode_projection()
	sgl.ortho(0, f32(sapp.width()), f32(sapp.height()), 0.0, -1.0, 1.0)
	a.draw()
}

```
