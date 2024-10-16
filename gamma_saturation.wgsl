const Gamma = 0.85;
const Saturation = 1.15;

const inv_gamma = 1.0 / Gamma;
const saturation_exp = 1.0 / Saturation - 1.0;

const YUV_BT709 = mat3x3(
    0.2126, -0.1146, 0.5,
    0.7152, -0.3854, -0.4542,
    0.0722, 0.5, -0.0458
);

const YUV_BT709_INV = mat3x3(
    1.0, 1.0, 1.0,
    0.0, -0.1873, 1.8556,
    1.5748, -0.4681, 0.0
);

const YUV_SAT_LIMIT = sqrt(0.5);

struct Input {
    @location(0) _sv_position: vec4f,
    @location(1) texture_coord: vec2f,
}

@group(0) @binding(0) var texture: texture_2d<f32>;
@group(0) @binding(1) var texture_sampler: sampler;

@fragment
fn main(input: Input) -> @location(0) vec4<f32> {
    var texel = textureSample(
        texture,
        texture_sampler,
        input.texture_coord
    );

    var yuv = YUV_BT709 * texel.rgb;

    let sat = sqrt(dot(yuv.yz, yuv.yz));
    let sat_scaler = pow(sat / YUV_SAT_LIMIT, saturation_exp);
    yuv.y *= sat_scaler;
    yuv.z *= sat_scaler;
    
    yuv.x = pow(yuv.x, inv_gamma);
    texel = vec4f(YUV_BT709_INV * yuv, texel.w);
    return texel;
}