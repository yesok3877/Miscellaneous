local configuration = {
    packet_rate = 2;
    packet_latency = 0;
    sleep = true;
    bind_toggle = Enum.KeyCode.F1;
    bind_choke = Enum.KeyCode.F2;
    bind_freeze = Enum.KeyCode.F3;
};

local coroutine_create = coroutine.create;
local coroutine_resume = coroutine.resume;

local game_clone = game.Clone;
local game_clear_all_children = game.ClearAllChildren;
local game_get_children = game.GetChildren;
local game_get_service = game.GetService;
local game_is_a = game.IsA;
local game_is_loaded = game.IsLoaded;
local game_wait_for_child = game.WaitForChild;

local string_format = string.format;

local task_wait = task.wait;

do
    function set_output( _string: string, ... )
       return print( string_format( _string, ... ) );
    end

    local load_task = 0;

    function set_load()
        load_task += 1;

        task_wait();

        return set_output( "%d : 6 tasks completed", load_task );
    end

    set_load();

    while task_wait( 1 ) do
        if ( game_is_loaded( game ) ) then
            break;
        end
    end

    set_load();

    local LOCAL_PLAYER = game_get_service( game, "Players" ).LocalPlayer;

    player_spawn = LOCAL_PLAYER.CharacterAdded;
    player_character = LOCAL_PLAYER.Character or player_spawn:Wait();

    character_humanoid_root_part = game_wait_for_child( player_character, "HumanoidRootPart" );

    set_load();

    toggle_switch = false;
    toggle_packets = true;
end

do
    local _data = { };

    data = { };

    getgenv().data = setmetatable( data, {
        __index = function( _table: table, key: string ): any
            return rawget( _data, key );
        end;
        __newindex = function( _table: table, key: string, value: any ): any
            local _value = _table[key];

            if ( _value == value ) then
                return _value;
            end

            set_output( "%s -> %s", key, tostring( value ) );

            return rawset( _data, key, value );
        end;
    } );
	
	table.foreach( configuration, function( index: string, value: any )
        data[index] = value;
    end );

    set_load();
end

do
    function set_cache( array: table ): table
        for index = 1, #array do
            if ( game_is_a( array[index], "BasePart" ) ) then
                continue;
            end

            array[index] = nil;
        end

        return array;
    end

    character_clone = { };
    character_track = { };

    character_objects = set_cache( game_get_children( player_character ) );

    CHARACTER_MODEL = Instance.new( "Model", workspace );

    local MODEL_COLOR = Color3.fromRGB( 255, 255, 255 );

    function set_rate( limit: number )
        if ( not toggle_packets ) then
            limit = 0;
        end

        if ( not toggle_switch ) then
            limit = 15;
        end

        return setfflag( "S2PhysicsSenderRate", tostring( limit ) );
    end

    set_rate( 15 );

    for index = 1, #character_objects do
		local value = character_objects[index];

		if ( value ) then
			local _value = game_clone( value );

			game_clear_all_children( _value );

			_value.Anchored = true;
			_value.CanCollide = false;
			_value.Color = MODEL_COLOR;
			_value.Material = "SmoothPlastic";
			_value.Parent = CHARACTER_MODEL;
			_value.Transparency = 1;

			character_clone[_value.Name] = _value;
			character_track[_value.Name] = { };
		end
    end

    set_load();
end

do
    local function set_task( operator: any, ... ): thread
        local task = coroutine_create( operator );

        coroutine_resume( task, ... );

        return task;
    end

    set_task( player_spawn.Connect, player_spawn, function( character: Instance )
        game_wait_for_child( character, "Head" );

        character_humanoid_root_part = character.HumanoidRootPart;
        character_objects = set_cache( game_get_children(character) );

        set_output( "cached instance %s", tostring( character_humanoid_root_part ) );
    end );

    local input_began = game_get_service( game, "UserInputService" ).InputBegan;

    set_task( input_began.Connect, input_began, function( input: Instance )
        local input_key = input.KeyCode;

        if ( input_key == data.bind_toggle ) then
            toggle_switch = not toggle_switch;
			
            for index, value in pairs( character_clone ) do
                value.Transparency = toggle_switch and 0.8 or 1;
            end

            if ( not toggle_switch ) then
                toggle_packets = true;

                set_rate( 15 );
            end

            set_output( "switch --> %s", tostring( toggle_switch ) );
        elseif ( input_key == data.bind_choke and toggle_switch ) then
            if ( not toggle_packets ) then
                toggle_packets = true;

                set_output( "packets --> true" );
            end

            task_wait( ping_pad );

            toggle_packets = false;

            set_output( "packets --> false" );
        elseif ( input_key == data.bind_freeze and toggle_switch ) then
            toggle_packets = not toggle_packets;

            set_output( "packets --> %s", tostring( toggle_packets ) );
        end
    end );

    local stats_ping = game_get_service( game, "Stats" ).PerformanceStats.Ping;
    local ping_get_value = stats_ping.GetValue;

    set_task( function()
        while true do
            ping_time = ping_get_value( stats_ping );
            ping_pad = 1 / data.packet_rate + data.packet_latency - 1 / ping_time;

            if ( toggle_switch and toggle_packets ) then
                for frame = 1, ping_time / 10 do
                    for index = 1, #character_objects do
                        local value = character_objects[index];

						if ( value ) then
							local array = character_track[value.Name];

							if ( not array ) then
								continue;
							end

							array[frame] = value.CFrame;
						end
                    end
                end
            end

            task_wait();
        end
    end );

    local run_service = game_get_service( game, "RunService" );
    local run_heartbeat = run_service.Heartbeat;
    local heartbeat_connect = run_heartbeat.Connect;
    local run_render_stepped = run_service.RenderStepped;
    local render_stepped_wait = run_render_stepped.Wait;

    set_task( function()
        local function set_sleep()
            sethiddenproperty( character_humanoid_root_part, "NetworkIsSleeping", data.sleep );
        end

        while true do
            if ( toggle_switch ) then
                local choke = heartbeat_connect( run_heartbeat, set_sleep );

                set_rate( 0 );

                task_wait( ping_pad );

                choke:Disconnect();

                set_rate( data.packet_rate );

                if ( toggle_packets ) then
                    for index, value in pairs( character_track ) do
                        local _value = CHARACTER_MODEL[index];

                        if ( _value ) then
                            _value.CFrame = value[1];
                        end
                    end
                end
            end

            render_stepped_wait( run_render_stepped );
        end
    end );

    set_load();
end
