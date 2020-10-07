using SimpleDirectMediaLayer 
const SDL2 = SimpleDirectMediaLayer

struct Cube
    x::Float64
    y::Float64
    z::Float64
    l::Float64
end

struct Sphere
    x::Float64
    y::Float64
    z::Float64
    r::Float64
end

mutable struct Spherical
    r::Float64
    theta::Float64
    phi::Float64
end

mutable struct Cartesian
    x::Float64
    y::Float64
    z::Float64
end

function newpos!(key, viewer_position)
    increment = deg2rad(5) 
    if key == :D
        viewer_position.phi += increment
    elseif key == :S
        viewer_position.theta -= increment
    elseif key == :A
        viewer_position.phi -= increment
    elseif key == :W
        viewer_position.theta += increment
    end
end

function close(win, renderer)
    SDL2.DestroyRenderer(renderer)
    SDL2.DestroyWindow(win)
    SDL2.QuitSubSystem(SDL2.INIT_EVERYTHING)    
    SDL2.Quit()
    exit()
end

function distance(point::Cartesian, cube::Cube)
    dx = cube.x - point.x
    dy = cube.y - point.y
    dz = cube.z - point.z
    A = B = C = 0
    m = cube.l/2
    if Bool(prod(abs.((dx,dy,dz)) .< m)) #if all the distances are inside the cube 
        return -1
    end
    if abs(dx) > m;  A = 1 end
    if abs(dy) > m;  B = 1 end 
    if abs(dz) > m;  C = 1 end

    distance = sqrt(A*dx^2 + B*dy^2 + C*dz^2) - sqrt(A+B+C)*m
    return distance
end

function distance(point::Cartesian, sphere::Sphere)
    dx = sphere.x - point.x
    dy = sphere.y - point.y
    dz = sphere.z - point.z
    distance = sqrt(dx^2 + dy^2 + dz^2) - sphere.r
    return distance
end
    
function advance(point, dir, incr)
    return Cartesian(
                     point.x + incr*dir.x,
                     point.y + incr*dir.y,
                     point.z + incr*dir.z
                    )
end

function raymarching(solids, viewer_position, ray_dir, draw_distance, threshold)
    total = 0
    distances = zeros(length(solids))
    point = viewer_position
    increment = threshold
    while increment >= threshold 
        for (i, solid) in enumerate(solids)
            distances[i] = distance(point, solid)
        end
        increment, a = findmin(distances)
        if increment < 0
            break
        end
        point = advance(point, ray_dir, increment)
        total += increment
        if total > draw_distance
            break
        end
    end
    return total
end

function spherical2cartesian(s)
    x::Float64 = s.r * sin(s.theta) * cos(s.phi)
    y::Float64 = s.r * sin(s.theta) * sin(s.phi)
    z::Float64 = s.r * cos(s.theta)
    return x, y, z
end

function norm_dir(A, B)
    dx = B.x - A.x
    dy = B.y - A.y
    dz = B.z - A.z

    n_dx, n_dy, n_dz = (dx, dy, dz)./(sqrt(dx^2+ dy^2 + dz^2))
    return Cartesian(n_dx, n_dy, n_dz)
end

function update_canvas(renderer, solids, viewer_pos_spherical)
    #create matrix
    FOV = deg2rad(30)
    viewer_pos_cartesian = Cartesian(spherical2cartesian(viewer_pos_spherical)...)
    #A = zeros(512,512) 
    target_spherical = Spherical(0,0,0)
    target_spherical.r = viewer_pos_spherical.r
    draw_distance = 25
    threshold = 0.01
    dir1 = norm_dir(Cartesian(0,0,0), Cartesian(spherical2cartesian(Spherical(viewer_pos_spherical.r, viewer_pos_spherical.theta - pi/2, viewer_pos_spherical.phi))...))
    dir2 = norm_dir(Cartesian(0,0,0), Cartesian(spherical2cartesian(Spherical(viewer_pos_spherical.r, pi/2 , viewer_pos_spherical.phi+pi/2 ))...))
    starting_point = advance(Cartesian(0,0,0), dir1, viewer_pos_spherical.r*tan(FOV/2))
    starting_point = advance(starting_point, dir2, viewer_pos_spherical.r*tan(FOV/2))
    target_cartesian = starting_point
    for i::Int32 =1:512, j::Int32 =1:512
        #defining targer point
        target_cartesian = advance(starting_point, dir1,- viewer_pos_spherical.r*tan(FOV)*(i-1)/512)
        target_cartesian = advance(target_cartesian, dir2, -viewer_pos_spherical.r*tan(FOV)*(j-1)/512)
        #defining direction from viewer to target
        ray_dir = norm_dir(viewer_pos_cartesian, target_cartesian) 

        distance = raymarching(solids, viewer_pos_cartesian, ray_dir, draw_distance, threshold)
       # A[i,j] = distance
       #
       attenuation = 1/(1+ 0.1*distance + 0.02 *distance^2) 
        SDL2.SetRenderDrawColor(renderer, Int64(floor(255*attenuation)), Int64(floor(250*attenuation)), Int64(floor(200*attenuation)), 255)
        SDL2.RenderDrawPoint(renderer, j, i)
    end
    #push matrix to 
    SDL2.RenderPresent(renderer)
end

function main_loop(win, renderer, keys_dict, solids, viewer_position)
    update_canvas(renderer, solids, viewer_position)
    while true
        SDL2.PumpEvents()
        e = SDL2.event()
        if typeof(e) == SDL2.KeyboardEvent && e._type == SDL2.KEYDOWN
            if e.keysym.sym in keys_dict.keys 
                newpos!(keys_dict[e.keysym.sym], viewer_position)
                update_canvas(renderer, solids, viewer_position)
                #println(viewer_position)
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
    keys_dict = Dict([(119, :W), (97, :A), (115, :S), (100, :D)]);
    
    cube1 = Cube(0,0,0,1)
    cube2 = Cube(2,1,1,2)
    cube3 = Cube(-2,1,1,1)
    sphere1 = Sphere(1,3,2,2)

    solids = [cube1, cube2, cube3, sphere1]

    starting_pos = Spherical(10, 0, 0)
    main_loop(win, renderer, keys_dict, solids, starting_pos)
end

app()

