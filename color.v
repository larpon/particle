// Copyright(C) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module particle

import math
import rand

pub struct Color {
mut:
	r byte
	g byte
	b byte
	a byte
}

fn (mut c Color) copy() Color {
	return Color{c.r, c.g, c.b, c.a}
}

fn (c Color) eq(rgba Color) bool {
	return c.r == rgba.r && c.g == rgba.g && c.b == rgba.b && c.a == rgba.a
}

fn (mut c Color) variation(cv ColorVariation) {
	if !cv.has_variation() {
		return
	}
	if cv.r > 0 {
		c.r = byte(c.r * (1 - cv.r) + rand.f32_in_range(0, 255) or { 255 } * cv.r)
	}
	if cv.g > 0 {
		c.g = byte(c.g * (1 - cv.g) + rand.f32_in_range(0, 255) or { 0 } * cv.g)
	}
	if cv.b > 0 {
		c.b = byte(c.b * (1 - cv.b) + rand.f32_in_range(0, 255) or { 0 } * cv.b)
	}
	if cv.a > 0 {
		c.a = byte(c.a * (1 - cv.a) + rand.f32_in_range(0, 255) or { 255 } * cv.a)
	}
}

pub struct ColorVariation {
pub mut:
	r f32
	g f32
	b f32
	a f32
}

fn (mut cv ColorVariation) all(value f32) {
	cv.r = value
	cv.g = value
	cv.b = value
	cv.a = value
}

fn (mut cv ColorVariation) set(r f32, g f32, b f32, a f32) {
	cv.r = r
	cv.g = g
	cv.b = b
	cv.a = a
}

fn (mut cv ColorVariation) max(max f32) {
	cv.r = f32(math.min(max, cv.r))
	cv.g = f32(math.min(max, cv.g))
	cv.b = f32(math.min(max, cv.b))
	cv.a = f32(math.min(max, cv.a))
}

fn (cv ColorVariation) has_variation() bool {
	return cv.r + cv.g + cv.b + cv.a != 0.0
}
