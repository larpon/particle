module particle

import os
import sokol.gfx
import stbi

pub struct ImageOptions {
mut:
	width  int
	height int

	cache   bool
	mipmaps int
	path    string
}

[heap]
pub struct Image {
mut:
	width  int
	height int

	cache bool

	path string
	// size		ImageSize

	channels int
	ready    bool
	mipmaps  int

	data voidptr
	ext  string

	sg_image gfx.Image
}

pub fn (mut s System) load_image(opt ImageOptions) ?Image {
	eprintln(@MOD + '.' + @STRUCT + '::' + @FN + ' loading "$opt.path" ...')
	// eprintln('${opt}')
	/*
	if !gfx.isvalid() {
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

	mut image_path := opt.path
	mut buffer := []byte{}
	$if android {
		image_path = image_path.replace('assets/', '') // TODO
		buffer = os.read_apk_asset(image_path) or {
			return error(@MOD + '.' + @FN + ' (Android) file "$image_path" not found')
		}
	} $else {
		if !os.is_file(image_path) {
			return error(@MOD + '.' + @FN + ' file "$image_path" not found')
			// return none
		}
		image_path = os.real_path(image_path)
		buffer = os.read_bytes(image_path) or {
			return error(@MOD + '.' + @FN + ' file "$image_path" could not be read')
		}
	}

	uid := image_path // os.real_path(image_path)
	if uid in s.image_cache {
		eprintln(@MOD + '.' + @STRUCT + '::' + @FN + ' loading "$image_path" from cache')
		return s.image_cache[uid]
	}

	// stb_img := stbi.load(opt.path) or { return err }

	eprintln(@MOD + '.' + @STRUCT + '::' + @FN + ' loading $buffer.len bytes from memory ...')
	stb_img := stbi.load_from_memory(buffer.data, buffer.len) or {
		return error(@MOD + '.' + @FN + ' stbi failed loading "$image_path"')
	}

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
	// stb_img.free() // TODO ??

	if img.cache && uid !in s.image_cache.keys() {
		eprintln(@MOD + '.' + @STRUCT + '::' + @FN + ' caching "$uid"')
		s.image_cache[uid] = img
	}

	return img
}

pub fn (mut img Image) init_sokol_image() &Image {
	// eprintln(@MOD+'.'+@STRUCT+'::'+@FN+' init sokol image $img')
	mut img_desc := gfx.ImageDesc{
		width: img.width
		height: img.height
		wrap_u: .clamp_to_edge
		wrap_v: .clamp_to_edge
		label: &byte(0)
		d3d11_texture: 0
		pixel_format: .rgba8 // C.SG_PIXELFORMAT_RGBA8
	}

	img_desc.data.subimage[0][0] = gfx.Range{
		ptr: img.data
		size: usize(img.channels * img.width * img.height)
	}

	img.sg_image = gfx.make_image(&img_desc)
	return img
}

pub fn (mut img Image) free() {
	unsafe {
		gfx.destroy_image(img.sg_image)
		C.stbi_image_free(img.data)
	}
}
