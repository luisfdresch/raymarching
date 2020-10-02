using SimpleDirectMediaLayer 
const SDL2 = SimpleDirectMediaLayer

struct cube
    x::Float64
    y::Float64
    z::Float64
    l::Float64
end

mutable struct polar
    r::Float64
    theta::Float64
    phi::Float64
end

mutable struct cartesian
    x::Float64
    y::Float64
    z::Float64
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

# FIXME
# fix the exit function
function close(win, renderer)
    SDL2.DestroyRenderer(renderer)
   # SDL2.DestroyWindow(win)
   # SDL2.QuitSubSystem(SDL2.INIT_EVERYTHING)    
   # SDL2.Quit()
end

function raymarching(cube, viewer_position, ray_dir, draw_distance, threshold)
    
    #  distance from point to cube
    # while distance > threshold 
    #   distance from point to cube
    #   point new position based on distance calculated and ray_dir
    #   if distance > draw_distance
    #       break
    #   end
    # end
    # 

end

function polar2cartesian(p)
    x::Float64 = p.r * sin(p.theta) * cos(p.phi)
    y::Float64 = p.r * sin(p.theta) * sin(p.phi)
    z::Float64 = p.r * cos(p.theta)
    return (x, y, z)
end

# TODO finish update_canvas function, and raymarching algorithm
function update_canvas(renderer, cube, viewer_pos_polar)
    #create matrix
    FOV = deg2rad(30)
    viewer_pos_cartesian = cartesian(ploar2cartesian(viewer_pos_polar))
     
    target_polar = polar()
    target_polar.r = viewer_pos_polar.r
    for i=1:512, j=1:512
        #defining targer point
        target_polar.theta = viewer_pos_polar.theta + pi - FOV + (i-1)*FOV*2/512
        target_polar.phi = viewer_pos_polar.phi + pi + FOV - (j-1)*FOV*2/512
        target_cartesian = cartesian(polar2cartesian(target_polar))
        #defining direction from viewer to target
        ray_dir = cartesian(
                            target_cartesian.x - viewer_pos_cartesian.x,
                            target_cartesian.y - viewer_pos_cartesian.y,
                            target_cartesian.z - viewer_pos_cartesian.z
                           )

        distance = raymarching(cube, viewer_position, ray_dir, draw_distance, threshold)
    #   raymarching
    end
    #push matrix to 
end

function main_loop(win, renderer, keys_dict, cube, viewer_position)
    update_canvas(renderer, cube, viewer_position)
    while true
        SDL2.PumpEvents()
        e = SDL2.event()
        if typeof(e) == SDL2.KeyboardEvent && e._type == SDL2.KEYDOWN
            if e.keysym.sym in keys_dict.keys 
                newpos!(keys_dict[keysym.sym], viewer_position)
                update_canvas(renderer, cube, viewer_position)
            end
        elseif typeof(e) == SDL2.WindowEvent && e.event == 14
            close(win, renderer)
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
    
    starting_pos = polar(5, 0, 0)
    main_loop(win, renderer, keys_dict, cube1, starting_pos)
end
