// Copyright(C) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module particle

import particle.vec

import math

type Affector = CustomAffector | GravityAffector

pub struct CustomAffector {
pub mut:
	enabled				bool

}

pub struct GravityAffector {
pub mut:
	enabled				bool

	position			vec.Vec2	// Center position of the affector
	size				vec.Vec2	// Max size of the affector

	groups				[]string	// Leave empty to affect all particles

	angle				f32
	magnitude			f32

	//
	/*location			StochasticDirection
	velocity			StochasticDirection
	acceleration		StochasticDirection*/

	relative			bool

	shape				Shape		// TODO
//mut:
	//system				&System = 0
	//dt					f64			// current delta time this frame
}

fn (mut ga GravityAffector) collides(p &Particle) bool {
	if p.position.x >= ga.position.x-(ga.size.x*0.5) && p.position.x <= ga.position.x+(ga.size.x*0.5) {
		return p.position.y >= ga.position.y-(ga.size.y*0.5) && p.position.y <= ga.position.y+(ga.size.y*0.5)
	}
	return false
}

fn (mut ga GravityAffector) affect(mut p Particle) {
	//println('Affecting particle')

	//if !magnitude {
	//	return false
	//}
	//if (need_recalc) {
	//	need_recalc = false
		dx := ga.magnitude * math.cos((ga.angle-90) * rad_pi_div_180)
		dy := ga.magnitude * math.sin((ga.angle-90) * rad_pi_div_180)
	//}
	p.velocity.x += dx*p.system.dt
	p.velocity.y += dy*p.system.dt

	//d->setInstantaneousVX(d->curVX(m_system) + m_dx*dt, m_system);
	//d->setInstantaneousVY(d->curVY(m_system) + m_dy*dt, m_system);
}
