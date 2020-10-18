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

pub fn (mut v Vec2) from(src Vec2) {
    v.x = src.x
    v.y = src.y
}
//
// Addition
//
// + operator overload. Adds two vectors
pub fn (v1 Vec2) + (v2 Vec2) Vec2 {
    return Vec2{v1.x + v2.x, v1.y + v2.y}
}

pub fn (v Vec2) add(vector Vec2) Vec2 {
    return Vec2{ v.x + vector.x, v.y + vector.y }
}

pub fn (v Vec2) add_f64(scalar f64) Vec2 {
    return Vec2{ v.x + scalar, v.y + scalar }
}

pub fn (v Vec2) add_f32(scalar f32) Vec2 {
    return Vec2{ v.x + scalar, v.y + scalar }
}

pub fn (mut v Vec2) plus(vector Vec2) {
    v.x += vector.x
    v.y += vector.y
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

pub fn (v Vec2) sub(vector Vec2) Vec2 {
    return Vec2{ v.x - vector.x, v.y - vector.y }
}

pub fn (v Vec2) sub_f64(scalar f64) Vec2 {
    return Vec2{ v.x - scalar, v.y - scalar }
}

pub fn (mut v Vec2) subtract(vector Vec2) {
    v.x -= vector.x
    v.y -= vector.y
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


pub fn (v Vec2) mul(vector Vec2) Vec2 {
    return Vec2{ v.x * vector.x, v.y * vector.y }
}

pub fn (v Vec2) mul_f64(scalar f64) Vec2 {
    return Vec2{ v.x * scalar, v.y * scalar }
}

pub fn (mut v Vec2) multiply(vector Vec2) {
    v.x *= vector.x
    v.y *= vector.y
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

pub fn (v Vec2) div(vector Vec2) Vec2 {
    return Vec2{ v.x / vector.x, v.y / vector.y }
}

pub fn (v Vec2) div_f64(scalar f64) Vec2 {
    return Vec2{ v.x / scalar, v.y / scalar }
}

pub fn (mut v Vec2) divide(vector Vec2) {
    v.x /= vector.x
    v.y /= vector.y
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

pub fn (v Vec2) dot(vector Vec2) f64 {
    return (v.x * vector.x) + (v.y*vector.y)
}

pub fn (v Vec2) cross(vector Vec2) f64 {
    return (v.x * vector.y) - (v.y*vector.x)
}

pub fn (v Vec2) unit() Vec2 {
    length := v.length()
    return Vec2{ v.x/length, v.y/length }
}

pub fn (v Vec2) perp() Vec2 {
    return Vec2{ -v.y, v.x }
}

pub fn (v Vec2) perpendicular(vector Vec2) Vec2 {
    return v - v.project(vector)
}

pub fn (v Vec2) project(vector Vec2) Vec2 {
    percent := v.dot(vector) / vector.dot(v)
    return vector.mul_f64(percent)
}

// eq returns a bool indicating if the two vectors are equal
pub fn (v Vec2) eq(vector Vec2) bool {
    return v.x == vector.x && v.y == vector.y
}

// eq_epsilon returns a bool indicating if the two vectors are equal within epsilon
pub fn (v Vec2) eq_epsilon(vector Vec2) bool {
    return v.x.eq_epsilon(vector.x) && v.y.eq_epsilon(vector.y)
}

pub fn (v Vec2) eq_approx(vector Vec2, tolerance f64) bool {
	diff_x := math.fabs(v.x - vector.x)
	diff_y := math.fabs(v.y - vector.y)
	if diff_x <= tolerance && diff_y <= tolerance {
		return true
	}

	max_x := math.max(math.fabs(v.x), math.fabs(vector.x))
	max_y := math.max(math.fabs(v.y), math.fabs(vector.y))
	if diff_x < max_x * tolerance && diff_y < max_y * tolerance {
		return true
	}

	return false
}

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
pub fn (v Vec2) distance(vector Vec2) f64 {
    return math.sqrt( (v.x-vector.x) * (v.x-vector.x) + (v.y-vector.y) * (v.y-vector.y) )
}

// manhattan_distance returns the Manhattan distance between the two vectors
pub fn (v Vec2) manhattan_distance(vector Vec2) f64 {
    return math.fabs(v.x-vector.x) + math.fabs(v.y-vector.y)
}

// angle_between returns the angle in radians between the two vectors
pub fn (v Vec2) angle_between(vector Vec2) f64 {
    return math.atan2( (v.y-vector.y), (v.x-vector.x) )
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

