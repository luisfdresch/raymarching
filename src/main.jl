using SimpleDirectMediaLayer 
const SDL2 = SimpleDirectMediaLayer

function app()
    win_w = 512
    win_h = 512

    SDL2.init()
    win = SDL2.CreateWindow("Raymarching experiment", Int32(100), Int32(100), Int32(win_w), Int32(win_h), UInt32(SDL2.WINDOW_SHOWN))
    SDL2.SetWindowResizable(win, false)
    renderer = SDL2.CreateRenderer(win, Int32(-1), UInt32(SDL2.RENDERER_ACCELERATED | SDL2.RENDERER_PRESENTVSYNC))
    keys_dict = Dict([(119, :W), (97, :A), (100, :S), (115, :D)])

   # main_loop(renderer, keys_dict)
end
