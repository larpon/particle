module particle

import os

//import sokol

import stbi

/*
pub struct ImageSize {
mut:
	width		int
	height		int
}
*/

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

pub fn (mut s System) load_image(path string, cache bool) ?Image {
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

	if !os.is_file(path) {
		return error(@MOD+'.'+@FN+' File not found: "$path"')
		//return none
	}
	uid := os.real_path(path)
	if uid in s.image_cache {
		eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' loading "$path" from cache')
		return s.image_cache[uid]
	}

	stb_img := stbi.load(path) or { return error(err) }

	mut img := Image{
		width: stb_img.width
		height: stb_img.height
		channels: stb_img.nr_channels
		cache: cache
		ready: stb_img.ok
		data: stb_img.data
		ext: stb_img.ext
		path: path
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
	}
	img_desc.content.subimage[0][0] = C.sg_subimage_content{
		ptr: img.data
		size: img.channels * img.width * img.height
	}
	img.sg_image = C.sg_make_image(&img_desc)
	return img
}

pub fn (mut img Image) free() {
	unsafe {
		C.sg_destroy_image(img.sg_image)
		C.stbi_image_free(img.data)
	}
}
