// Copyright(C) 2020 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module vec

import math

pub struct Vec2 {
pub mut:
	x f64
	y f64
}

pub fn (mut v Vec2) zero() {
	v.x = 0.0
	v.y = 0.0
}

pub fn (mut v Vec2) copy() Vec2 {
	return Vec2{ v.x, v.y }
}

pub fn (mut v Vec2) from(u Vec2) {
	v.x = u.x
	v.y = u.y
}
//
// Addition
//
// + operator overload. Adds two vectors
pub fn (v1 Vec2) + (v2 Vec2) Vec2 {
	return Vec2{v1.x + v2.x, v1.y + v2.y}
}

pub fn (v Vec2) add(u Vec2) Vec2 {
	return Vec2{ v.x + u.x, v.y + u.y }
}

pub fn (v Vec2) add_f64(scalar f64) Vec2 {
	return Vec2{ v.x + scalar, v.y + scalar }
}

pub fn (v Vec2) add_f32(scalar f32) Vec2 {
	return Vec2{ v.x + scalar, v.y + scalar }
}

pub fn (mut v Vec2) plus(u Vec2) {
	v.x += u.x
	v.y += u.y
}

pub fn (mut v Vec2) plus_f64(scalar f64) {
	v.x += scalar
	v.y += scalar
}

pub fn (mut v Vec2) plus_f32(scalar f32) {
	v.x += scalar
	v.y += scalar
}

//
// Subtraction
//
pub fn (v1 Vec2) - (v2 Vec2) Vec2 {
	return Vec2{v1.x - v2.x, v1.y - v2.y}
}

pub fn (v Vec2) sub(u Vec2) Vec2 {
	return Vec2{ v.x - u.x, v.y - u.y }
}

pub fn (v Vec2) sub_f64(scalar f64) Vec2 {
	return Vec2{ v.x - scalar, v.y - scalar }
}

pub fn (mut v Vec2) subtract(u Vec2) {
	v.x -= u.x
	v.y -= u.y
}

pub fn (mut v Vec2) subtract_f64(scalar f64) {
	v.x -= scalar
	v.y -= scalar
}

//
// Multiplication
//
pub fn (v1 Vec2) * (v2 Vec2) Vec2 {
	return Vec2{v1.x * v2.x, v1.y * v2.y}
}

pub fn (v Vec2) mul(u Vec2) Vec2 {
	return Vec2{ v.x * u.x, v.y * u.y }
}

pub fn (v Vec2) mul_f64(scalar f64) Vec2 {
	return Vec2{ v.x * scalar, v.y * scalar }
}

pub fn (mut v Vec2) multiply(u Vec2) {
	v.x *= u.x
	v.y *= u.y
}

pub fn (mut v Vec2) multiply_f64(scalar f64) {
	v.x *= scalar
	v.y *= scalar
}

//
// Division
//
pub fn (v1 Vec2) / (v2 Vec2) Vec2 {
	return Vec2{v1.x / v2.x, v1.y / v2.y}
}

pub fn (v Vec2) div(u Vec2) Vec2 {
	return Vec2{ v.x / u.x, v.y / u.y }
}

pub fn (v Vec2) div_f64(scalar f64) Vec2 {
	return Vec2{ v.x / scalar, v.y / scalar }
}

pub fn (mut v Vec2) divide(u Vec2) {
	v.x /= u.x
	v.y /= u.y
}

pub fn (mut v Vec2) divide_f64(scalar f64) {
	v.x /= scalar
	v.y /= scalar
}

//
// Utility
//
pub fn (v Vec2) length() f64 {
	if v.x == 0 && v.y == 0 { return 0.0 }
	return math.sqrt((v.x*v.x) + (v.y*v.y))
}

pub fn (v Vec2) dot(u Vec2) f64 {
	return (v.x * u.x) + (v.y*u.y)
}

// cross returns the cross product of v and u
pub fn (v Vec2) cross(u Vec2) f64 {
	return (v.x * u.y) - (v.y*u.x)
}

// unit return this vector's unit vector
pub fn (v Vec2) unit() Vec2 {
	length := v.length()
	return Vec2{ v.x/length, v.y/length }
}

pub fn (v Vec2) perp() Vec2 {
	return Vec2{ -v.y, v.x }
}

// perpendicular return the perpendicular vector of this
pub fn (v Vec2) perpendicular(u Vec2) Vec2 {
	return v - v.project(u)
}

// project returns the projected vector
pub fn (v Vec2) project(u Vec2) Vec2 {
	percent := v.dot(u) / u.dot(v)
	return u.mul_f64(percent)
}

// eq returns a bool indicating if the two vectors are equal
pub fn (v Vec2) eq(u Vec2) bool {
	return v.x == u.x && v.y == u.y
}

// eq_epsilon returns a bool indicating if the two vectors are equal within epsilon
pub fn (v Vec2) eq_epsilon(u Vec2) bool {
	return v.x.eq_epsilon(u.x) && v.y.eq_epsilon(u.y)
}

// eq_approx will return a bool indicating if vectors are approximately equal within the tolerance
pub fn (v Vec2) eq_approx(u Vec2, tolerance f64) bool {
	diff_x := math.fabs(v.x - u.x)
	diff_y := math.fabs(v.y - u.y)
	if diff_x <= tolerance && diff_y <= tolerance {
		return true
	}

	max_x := math.max(math.fabs(v.x), math.fabs(u.x))
	max_y := math.max(math.fabs(v.y), math.fabs(u.y))
	if diff_x < max_x * tolerance && diff_y < max_y * tolerance {
		return true
	}

	return false
}

// is_approx_zero will return a bool indicating if this vector is zero within tolerance
pub fn (v Vec2) is_approx_zero(tolerance f64) bool {
	if math.fabs(v.x) <= tolerance && math.fabs(v.y) <= tolerance {
		return true
	}
	return false
}

// eq_f64 returns a bool indicating if the x and y both equals the scalar
pub fn (v Vec2) eq_f64(scalar f64) bool {
	return v.x == scalar && v.y == scalar
}

// eq_f32 returns a bool indicating if the x and y both equals the scalar
pub fn (v Vec2) eq_f32(scalar f32) bool {
	return v.eq_f64(f64(scalar))
}

// distance returns the distance between the two vectors
pub fn (v Vec2) distance(u Vec2) f64 {
	return math.sqrt( (v.x-u.x) * (v.x-u.x) + (v.y-u.y) * (v.y-u.y) )
}

// manhattan_distance returns the Manhattan distance between the two vectors
pub fn (v Vec2) manhattan_distance(u Vec2) f64 {
	return math.fabs(v.x-u.x) + math.fabs(v.y-u.y)
}

// angle_between returns the angle in radians between the two vectors
pub fn (v Vec2) angle_between(u Vec2) f64 {
	return math.atan2( (v.y-u.y), (v.x-u.x) )
}

// angle returns the angle in radians of the vector
pub fn (v Vec2) angle() f64 {
	return math.atan2(v.y, v.x)
}

// abs will set x and y values to their absolute values
pub fn (mut v Vec2) abs() {
	if v.x < 0 {
		v.x = math.fabs(v.x)
	}
	if v.y < 0 {
		v.y = math.fabs(v.y)
	}
}

