using SimpleDirectMediaLayer 
const SDL2 = SimpleDirectMediaLayer

struct cube
    x
    y
    x
    l
end

mutable struct viewer_pos
    r
    theta
    phi
end

function newpos!(key, viewer_position)
    increment = deg2rad(5) 
    if key == :W
        viewer_position.phi += increment
    elseif key == :A
        viewer_position.theta -= increment
    elseif key == :S
        viewer_position.phi -= increment
    elseif key == :D
        viewer_position.theta += increment
    end
end

function main_loop(renderer, keys_dict, cube, viewer_position)
    update_canvas(renderer, cube, viewer_position)
    while true
        SDL2.PumpEvents()
        e = SDL2.event()
        if typeof(e) == SDL2.KeyboardEvent && e._type == SDL2.KEYDOWN
            if e.keysym.sym in keys_dict.keys
                newpos!(keys_dict[keysym.sym], viewer_position)
                update_canvas(renderer, cube, viewer_position)
            end
        end
        
end


function app()
    win_w = 512
    win_h = 512

    SDL2.init()
    win = SDL2.CreateWindow("Raymarching experiment", Int32(100), Int32(100), Int32(win_w), Int32(win_h), UInt32(SDL2.WINDOW_SHOWN))
    SDL2.SetWindowResizable(win, false)
    renderer = SDL2.CreateRenderer(win, Int32(-1), UInt32(SDL2.RENDERER_ACCELERATED | SDL2.RENDERER_PRESENTVSYNC))
    keys_dict = Dict([(119, :W), (97, :A), (100, :S), (115, :D)]);
    
    cube1 = cube(0,0,0,1)
    
    starting_pos = viewer_pos(5, 0, 0)
   # main_loop(renderer, keys_dict, cube1, starting_pos)
end
