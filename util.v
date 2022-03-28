// Copyright(C) 2020-2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

module particle

fn remap(v f64, min f64, max f64, new_min f64, new_max f64) f64 {
	return (((v - min) * (new_max - new_min)) / (max - min)) + new_min
}
