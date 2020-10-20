// From github user Deins (https://github.com/Deins)
// https://github.com/Deins/sokol/blob/abb7c8fd5d1a513409be8e339b2cefd26dae66bb/sokol_gfx.h#L11659-L11720

SOKOL_API_DECL sg_image sg_make_image_with_mipmaps(const sg_image_desc* desc);

SOKOL_API_IMPL sg_image sg_make_image_with_mipmaps(const sg_image_desc* desc_)
{
    sg_image_desc desc = *desc_;
    SOKOL_ASSERT(desc.pixel_format == SG_PIXELFORMAT_RGBA8
                || desc.pixel_format == SG_PIXELFORMAT_BGRA8
                || desc.pixel_format == SG_PIXELFORMAT_R8);

    unsigned pixel_size = _sg_pixelformat_bytesize(desc.pixel_format);
    static unsigned char* buffers[SG_CUBEFACE_NUM][SG_MAX_MIPMAPS] = {0}; // TODO: better allocation

    for (int cube_face = 0; cube_face < SG_CUBEFACE_NUM; ++cube_face)
    {
        int target_width = desc.width;
        int target_height = desc.height;
        for (int level = 1; level < SG_MAX_MIPMAPS; ++level)
        {
            unsigned char* source = (unsigned char*)desc.content.subimage[cube_face][level - 1].ptr;
            unsigned img_size = target_width * target_height * pixel_size;
            unsigned char* target = (unsigned char*)SOKOL_MALLOC(img_size);
            buffers[cube_face][level] = target;
            if (!source) break;
            int source_width = target_width;
            int source_height = target_height;
            target_width /= 2;
            target_height /= 2;
            if (target_width < 1 && target_height < 1) break;
            if (target_width < 1) target_width= 1;
            if (target_height < 1) target_height = 1;

            for (int x = 0; x < target_width; ++x)
            {
                for (int y = 0; y < target_height; ++y)
                {
                    uint16_t colors[8] = { 0 };
                    for (int chanell = 0; chanell < pixel_size; ++chanell)
                    {
                        int color = 0;
                        int sx = x * 2;
                        int sy = y * 2;
                        color += source[source_width * pixel_size * sx + sy * pixel_size + chanell];
                        color += source[source_width * pixel_size * (sx + 1) + sy * pixel_size + chanell];
                        color += source[source_width * pixel_size * (sx + 1) + (sy + 1) * pixel_size + chanell];
                        color += source[source_width * pixel_size * sx + (sy + 1) * pixel_size + chanell];
                        color /= 4;
                        target[target_width * pixel_size * (x) + (y) * pixel_size + chanell] = (uint8_t)color;
                    }
                }
            }
            desc.content.subimage[cube_face][level].ptr = target;
            desc.content.subimage[cube_face][level].size = img_size;
            if (desc.num_mipmaps <= level) desc.num_mipmaps = level + 1;
        }
    }

    sg_image img = sg_make_image(&desc);
    for (int cube_face = 0; cube_face < SG_CUBEFACE_NUM; ++cube_face) {
        for (int i = 0; i < SG_MAX_MIPMAPS; ++i) {
            SOKOL_FREE(buffers[cube_face][i]);
        }
    }
    return img;
}