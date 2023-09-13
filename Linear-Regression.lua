local brickcolor_new = BrickColor.new;

local cframe_look_at = CFrame.lookAt;
local cframe_new = CFrame.new;

local GRAPH_POINTS = { };
local GRAPH_POINTS_MAX = 50;
local GRAPH_POSITIONS = { };

local game_clone = game.Clone;
local game_destroy = game.Destroy;

local instance_new = Instance.new;

local CHARACTER = game.Players.PROTOSM4SHER.Character;
local HUMANOID = CHARACTER.Humanoid;

local table_clear = table.clear;
local table_insert = table.insert;

local task_wait = task.wait;

local vector3_new = Vector3.new;

do
    POINT_LINE = instance_new( "Part", workspace );

    POINT_LINE.Anchored = true;
    POINT_LINE.BrickColor = brickcolor_new( "Bright blue" );
    POINT_LINE.CanCollide = false;
end

do
    local function instance_point( part_position: Vector3 ): Instance
        local point = instance_new( "Part", workspace );

        point.Anchored = true;
        point.BrickColor = brickcolor_new( "Bright red" );
        point.CanCollide = false;
        point.Position = part_position;
        point.Size = vector3_new( 1, 1, 1 );

        return point;
    end

    local VECTOR3_NULL = vector3_new();

    local POINT_REFERENCE = CHARACTER.HumanoidRootPart.Position;

    while task_wait( 0.1 ) do
        local part_velocity = HUMANOID.MoveDirection * HUMANOID.WalkSpeed;

        if ( part_velocity ~= VECTOR3_NULL ) then
            if ( #GRAPH_POSITIONS > GRAPH_POINTS_MAX ) then
                for index = 1, #GRAPH_POINTS do
                    game_destroy( GRAPH_POINTS[index] );
                end
                
                table_clear( GRAPH_POINTS );
                table_clear( GRAPH_POSITIONS );

                warn( "cleared caches" );
            end

            POINT_REFERENCE += part_velocity * 0.1;

            local part_position = POINT_REFERENCE;

            table_insert( GRAPH_POSITIONS, {
                X = part_position.X;
                Z = part_position.Z;
            } );

            table_insert( GRAPH_POINTS, instance_point( part_position ) );

            local _graph_positions = #GRAPH_POSITIONS

            if ( _graph_positions >= 2 ) then
                local sum_x = 0;
                local sum_z = 0;

                local product_x_z = 0;
                local product_x_x = 0;

                for index = 1, _graph_positions do
                    local point = GRAPH_POSITIONS[index];

                    sum_x += point.X;
                    sum_z += point.Z;

                    product_x_z += point.X * point.Z;
                    product_x_x += point.X ^ 2;
                end

                local slope = ( _graph_positions * product_x_z - sum_x * sum_z ) / ( _graph_positions * product_x_x - sum_x ^ 2);
                local intercept = ( sum_z - slope * sum_x ) / _graph_positions;

                local inital_x = GRAPH_POSITIONS[1].X;
                local final_x = GRAPH_POSITIONS[_graph_positions].X;

                local point_origin = vector3_new( inital_x, 0, slope * inital_x + intercept );
                local point_end = vector3_new( final_x, 0, slope * final_x + intercept );

                local point_distance = (point_origin - point_end).Magnitude;

                POINT_LINE.CFrame = cframe_look_at( point_origin, point_end ) * cframe_new( 0, part_position.Y, - point_distance / 2)
                POINT_LINE.Size = vector3_new( 1, 1, point_distance );
            end
        end
    end
end
