module particle

import os

import sokol
import sokol.sgl

import stbi

pub struct Image {
mut:
	id int
	width       int
	height      int
	nr_channels int
	ok          bool
	data        voidptr
	ext         string
	simg_ok     bool
	simg        C.sg_image
	path string
}

fn C.sg_isvalid() bool

// TODO return ?Image
pub fn (mut s System) create_image(file string) Image {
	/*if !C.sg_isvalid() {
		// Sokol is not initialized yet, add stbi object to a queue/cache
		//s.image_queue << file
		stb_img := stbi.load(file) or { return Image{} }
		img := Image{
			width: stb_img.width
			height: stb_img.height
			nr_channels: stb_img.nr_channels
			ok: false
			data: stb_img.data
			ext: stb_img.ext
			path: file
			id: s.image_cache.len
		}
		s.image_cache << img
		return img
	}*/
	mut img := create_image(file)
	img.id = s.image_cache.len
	s.image_cache << img
	return img
}

// TODO remove this
fn create_image(file string) Image {
	if !os.exists(file) {
		eprintln('File not found: $file')
		return Image{} // none
	}
	stb_img := stbi.load(file) or { return Image{} }
	mut img := Image{
		width: stb_img.width
		height: stb_img.height
		nr_channels: stb_img.nr_channels
		ok: stb_img.ok
		data: stb_img.data
		ext: stb_img.ext
		path: file
	}
	img.init_sokol_image()
	return img
}

pub fn create_image_from_memory(buf byteptr, bufsize int) Image {
	stb_img := stbi.load_from_memory(buf, bufsize) or { return Image{} }
	mut img := Image{
		width: stb_img.width
		height: stb_img.height
		nr_channels: stb_img.nr_channels
		ok: stb_img.ok
		data: stb_img.data
		ext: stb_img.ext
	}
	return img
}

pub fn create_image_from_byte_array(b []byte) Image {
	return create_image_from_memory(b.data, b.len)
}

pub fn (mut img Image) init_sokol_image() &Image {
	//eprintln('\n init sokol image $img.path ok=$img.simg_ok')
	mut img_desc := C.sg_image_desc{
		width: img.width
		height: img.height
		num_mipmaps: 0
		wrap_u: .clamp_to_edge
		wrap_v: .clamp_to_edge
		label: &byte(0)
		d3d11_texture: 0
	}
	img_desc.content.subimage[0][0] = C.sg_subimage_content{
		ptr: img.data
		size: img.nr_channels * img.width * img.height
	}
	img.simg = C.sg_make_image(&img_desc)
	img.simg_ok = true
	img.ok = true
	return img
}
