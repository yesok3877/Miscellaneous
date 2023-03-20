--[[
    # preassumed information & logic
    
    - custom character models are in use, with the character property being disregarded
    - script was executed upon spawn-in & other players have spawned as well
    - character models have atleast one BasePart
    - client does not have network ownership over the local character model
    - character models share the same name (e.g. 'Player' or 'Model')
        * the logic processing may or may not falter if the model names are different (e.g. 'Player1' , 'Player2', 'Player3')
    - allocated memory (i.e. garbage collection) is accessible
    - a table that contains all character models inside the workspace is present in memory
--]]
assert(getgenv, "global environment is not present"); do
    local function globalize(table)
        local environment = getgenv();
        --
        for index, value in pairs(table) do
            environment[index] = value;
        end;
        --
        return environment;
    end;
    -- globalizing conventional utilities so that the runtime may open up
    globalize({
        game_load = game.IsLoaded;
        game_service = setmetatable({}, {
            __index = function(self, index)
                return game:GetService(index);
            end;
        });
        game_descendants = game.GetDescendants;
        game_class = game.IsA;
        game_ancestor = game.FindFirstAncestorOfClass;
        game_path = game.GetFullName;
        --
        table_insert = table.insert;
        table_find = table.find;
        table_move = table.move;
        --
        string_split = string.split;
        string_format = string.format;
        --
        debug_values = debug.getupvalues;
    });
    --
    while wait(1) do
        if (game_load(game)) then
            break;
        end;
    end;
    --
    globalize({
        game_workspace = game_service.Workspace;
        --
        players_maximum = game_service.Players.MaxPlayers;
    });
end;
--
local cache; do
    cache = {};
    -- function that computes the sum of a given cache (i.e. dictionary)
    local function cache_enumerate(cache)
        local cache_entries = 0;
        --
        for index, value in pairs(cache) do
            cache_entries += 1;
        end
        --
        return cache_entries;
    end;
    -- wrapper function that validates the accumulation of a given cache in which is greater than 0
    local function cache_validate(cache, output_invalid, output_valid)
        local cache_entries = cache_enumerate(cache);
        --
        assert((cache_entries > 0), output_invalid);
        print(cache_entries, output_valid);
    end;
    --
    warn("\ncollecting all compatible models inside the workspace");
    -- collection of all descendant models inside the workspace of which have baseparts & do not exceed the maximum player count
    local cache_models; do
        cache_models = {};
        --
        for index, object in ipairs(game_descendants(game_workspace)) do
            if (game_class(object, "Model")) then
                if (not cache_models[object.name]) then
                    cache_models[object.name] = {};
                end;
                --
                table_insert(cache_models[object.name], object);
            end;
        end;
        --
        for index_model, array in pairs(cache_models) do
            if (#array > players_maximum) then
                cache_models[index_model] = nil;
                --
                continue;
            end;
            --
            local cache_bases; do
                cache_bases = false;
                --
                for index, object in ipairs(game_descendants(array[1])) do
                    if (game_class(object, "BasePart")) then
                        cache_bases = true;
                        --
                        break;
                    end;
                end;
            end;
            --
            if (not cache_bases) then
                cache_models[index_model] = nil;
            end;
        end;
        --
        cache_validate(cache_models, "no models were cached", "models have been cached");
    end;
    -- if two objects share an ancestor, our logic disregards other objects alike
    warn("\ndiscarding coherent objects"); do
        local cache_ancestors = {};
        --
        for index_model, array in pairs(cache_models) do
            local array_ancestor = game_ancestor(array[1], "Model");
            --
            if (array_ancestor) then
                local index_ancestor = cache_ancestors[array_ancestor];
                -- we declare the ancestor of one model then compare it to the ancestor of other models
                if (not index_ancestor) then
                    cache_ancestors[array_ancestor] = index_model;
                elseif (index_ancestor ~= index_model) then
                    cache_models[index_model] = nil;
                end;
            end;
        end;
    end;
    -- find the first ancestor model so that we visualize the entire model & capture any related tables inside the garbage collection later on
    warn("\nrationalizing cache ancestry structure"); do
        for index_model, array in pairs(cache_models) do
            for index, object in ipairs(array) do
                local cache_object = object;
                local cache_ancestor = game_ancestor(object, "Model");
                --
                if (cache_ancestor) then
                    for ancestor = 1, #string_split(game_path(object), ".") do
                        cache_object = cache_ancestor;
                        cache_ancestor = game_ancestor(cache_ancestor, "Model");
                        --
                        if (not cache_ancestor) then
                            break;
                        end;
                    end;
                end;
                --
                array[index] = cache_object;
            end;
        end;
    end;
    --
    warn("\ncapturing model movement"); do
        local cache_positions = {};
        --
        for index_model, array in pairs(cache_models) do
            for index, object in ipairs(game_descendants(array[1])) do
                if (not cache_positions[index_model] and game_class(object, "BasePart")) then
                    cache_positions[index_model] = {};
                    cache_positions[index_model][object] = object.position;
                    --
                    break;
                end;
            end;
        end;
        -- yield for player movements
        wait(3.5);
        -- discard delta neutral positions
        for index_model, array in pairs(cache_positions) do
            for object, position in pairs(array) do
                if ((object.position - position).magnitude == 0) then
                    cache_models[index_model] = nil;
                    cache_positions[index_model] = nil;
                end;
                --
                break;
            end;
        end;
        --
        cache_validate(cache_positions, "no models made movement", "models shifted position and have been captured");
    end;
    --
    warn("\ncapturing model allocation");
    --
    local cache_allocated; do
        cache_allocated = {};
        -- wrapper function that captures our models from allocated values
        local function cache_trace(value_allocated)
            if (cache_enumerate(value_allocated) > players_maximum) then
                return;
            end;
            --
            for index, value in pairs(value_allocated) do
                local allocated = (cache_models[tostring(index)] or cache_models[tostring(value)]);
                --
                if (allocated and not table_find(cache_allocated, allocated)) then
                    table_insert(cache_allocated, allocated);
                end;
            end;
        end;
        --
        for index_allocated, value_allocated in ipairs(getgc(true)) do
            local value_type = type(value_allocated);
            --
            if (value_type == "table") then
                cache_trace(value_allocated);
            elseif (value_type == "function") then
                for index, value in pairs(debug_values(value_allocated)) do
                    if (type(value) == "table") then
                        cache_trace(value);
                    end;
                end;
            end;
        end;
        --
        cache_validate(cache_allocated, "no models were captured inside of allocated memory", "models were captured inside of allocated memory");
    end;
    --
    warn("resolving allocated cache for final entry"); do
        local cache_entries = 0;
        -- logic instructs the cache to finalize on the entry of which is greater than others
        for index, array in ipairs(cache_allocated) do
            if (#array == players_maximum) then
                cache = array;
                --
                break;
            elseif (#array > cache_entries) then
                cache_entries = #array;
                cache = array;
            end;
        end;
        -- with the assumption that our entries are autonomous, our final cache entry shall unify the others together
        if (cache_entries == 1) then
            for index, array in ipairs(cache_allocated) do
                table_move(array, 1, #array, cache_entries, cache);
                cache_entries += #array;
            end;
        end;
        --
        cache_validate(cache, "final cache entry could not be resolved", "final cache entries were made");
    end;
    --
    print(string_format("\ncached models in similarity of '%s' were generalized for their greater allocated sum", game_path(cache[1])));
end;
--
for index, object in ipairs(cache) do
    Instance.new("Highlight", object);
end;
