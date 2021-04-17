# My Journey Through Shaders

Hello and thank you for stopping by!
I am using this repository to learn about Shaders in Unity and HLSL. 

I am doing it old style so no ShaderGraph or any nodebase editor.
The reason is quite simple. I want to understand the underlying mechanisms for different shader techniques, plus I really enjoy playing around with math and matrices, so I think standard HLSL is the way to go.

I am using Unity _2019.4.18f1_.

## Content

The shaders are divided in different folders. At the moment I have shaders looking at the following

### Basics

- Color
- Texture
- Culling
- ZBuffering
- Zwrite/Alpha Blending
- Matrix manipulations
- Vertex animations
- Drawing shapes on textures

### Effects

- Rim
- Blur
- Distortion
- Face extruding
- Dissolve
- Lava (Jettelly based) - featuring parallax displacement
- Lava (Jetelly based)  - featuring parallax occlusion mapping

### Shader toy

This is a bonus folder where I am starting to look at shaders from shadertoy and deconstruct them to understand them and create variants.
- Bubble image effect from [Bubble shader](https://www.shadertoy.com/view/4dl3zn)

## Resources

There are plenty of resources available out there which makes this learning fun and engaging at the same time

The [Unity documentation](https://docs.unity3d.com/Manual/SL-ShadingLanguage.html) is where to start.
Together with the [HLSL reference](https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-reference) for the DirectX.

And finally here a list of amazing people sharing their knowledge with shaders. The list is mixed in terms of the level of techniques explained, but neverthless I think it useful to have a more broader idea of different uses for shaders.

- [Harry Alizavakis](https://twitter.com/HarryAlisavakis)
- [Jettelly](https://www.youtube.com/channel/UCDe9IaIvr1XOP3vbTgIekBQ)
- [Making stuff look good in Unity](https://www.youtube.com/channel/UCEklP9iLcpExB8vp_fWQseg)
- [Alan Zucconi](https://www.alanzucconi.com/tutorials/)
- [Freya Holmer](https://twitter.com/FreyaHolmer)
- [Inigo Quilez](https://iquilezles.org/index.html)
