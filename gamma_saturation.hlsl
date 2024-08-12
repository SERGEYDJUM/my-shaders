static const float saturation = 1.2;
static const float saturation_cutoff = 0.001;
static const float inv_gamma = 1.1764705;
static const float3x3 YUV_BT709_ = float3x3(float3(0.2126, -0.1146, 0.5), float3(0.7152, -0.3854, -0.4542), float3(0.0722, 0.5, -0.0458));
static const float3x3 YUV_BT709_INV = float3x3(float3(1.0, 1.0, 1.0), float3(0.0, -0.1873, 1.8556), float3(1.5748, -0.4681, 0.0));
static const float _sat_limit = 0.70710677;

Texture2D<float4> texture_ : register(t0);
SamplerState texture_sampler : register(s1);

struct Input {
    float4 _sv_position : LOC0;
    float2 texture_coord : LOC1;
};

float4 main(Input input) : SV_Target0
{
    float4 texel = texture_.Sample(texture_sampler, input.texture_coord);
    float3 yuv = mul(texel.rgb, YUV_BT709_);
    float sat = sqrt(dot(yuv.yz, yuv.yz));

    if (sat > saturation_cutoff) {
        yuv.yz = yuv.yz * (min(sat * saturation, _sat_limit) / sat);
    }

    yuv.x = pow(yuv.x, inv_gamma);

    texel = float4(mul(yuv, YUV_BT709_INV), texel.w);
    return texel;
}
