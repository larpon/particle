module particle

import os

import particle.c

import stbi

pub const (
	used_import = c.used_import
)

pub struct ImageOptions {
mut:
	width		int
	height		int

	cache		bool
	mipmaps		int
	path		string
}


pub struct Image {
mut:
	width		int
	height		int

	cache		bool

	path		string
	//size		ImageSize

	channels	int
	ready		bool
	mipmaps		int

	data		voidptr
	ext			string

	sg_image	C.sg_image
}

//fn C.sg_isvalid() bool

pub fn (mut s System) load_image(opt ImageOptions) ?Image {
	eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' loading "${opt.path}" ...')
	//eprintln('${opt}')
	/*if !C.sg_isvalid() {
		// Sokol is not initialized yet, add stbi object to a queue/cache
		//s.image_queue << path
		stb_img := stbi.load(path) or { return Image{} }
		img := Image{
			width: stb_img.width
			height: stb_img.height
			channels: stb_img.nr_channels
			ok: false
			data: stb_img.data
			ext: stb_img.ext
			path: path
			id: s.image_cache.len
		}
		s.image_cache << img
		return img
	}*/

	if !os.is_file(opt.path) {
		return error(@MOD+'.'+@FN+' File not found: "${opt.path}"')
		//return none
	}
	uid := os.real_path(opt.path)
	if uid in s.image_cache {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' loading "${opt.path}" from cache')
		return s.image_cache[uid]
	}

	stb_img := stbi.load(opt.path) or { return error(err) }

	mut img := Image{
		width: stb_img.width
		height: stb_img.height
		channels: stb_img.nr_channels
		cache: opt.cache
		ready: stb_img.ok
		data: stb_img.data
		ext: stb_img.ext
		path: opt.path
		mipmaps: opt.mipmaps
		/*
		size: ImageSize {
			width: stb_img.width
			height: stb_img.height
		}*/
	}
	img.init_sokol_image()

	if img.cache && !(uid in s.image_cache) {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' caching "$uid"')
		s.image_cache[uid] = img
	}
	return img
}

pub fn (mut img Image) init_sokol_image() &Image {
	//eprintln('\n init sokol image $img.path ok=$img.sg_image_ok')
	mut img_desc := C.sg_image_desc{
		width: img.width
		height: img.height
		num_mipmaps: img.mipmaps
		wrap_u: .clamp_to_edge
		wrap_v: .clamp_to_edge
		label: &byte(0)
		d3d11_texture: 0
		pixel_format: C.SG_PIXELFORMAT_RGBA8
	}

	img_desc.content.subimage[0][0] = C.sg_subimage_content{
		ptr: img.data
		size: img.channels * img.width * img.height
	}
	if img.mipmaps <= 0 {
		img.sg_image = C.sg_make_image(&img_desc)
	} else {
		img.sg_image = C.sg_make_image_with_mipmaps(&img_desc)
	}
	return img
}

pub fn (mut img Image) free() {
	unsafe {
		C.sg_destroy_image(img.sg_image)
		C.stbi_image_free(img.data)
	}
}
