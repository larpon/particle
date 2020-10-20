module c

pub const (
	used_import = 1
)

#flag -I @VROOT/c

#include "sokol_gfx.mipmap.h"

fn C.sg_make_image_with_mipmaps(desc &C.sg_image_desc) C.sg_image

[inline]
pub fn make_image_with_mipmaps(desc &C.sg_image_desc) C.sg_image {
	return C.sg_make_image_with_mipmaps(desc)
}
