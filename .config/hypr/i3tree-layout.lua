-- i3-style directional moves backed by an explicit per-workspace split tree.
local states = {}
local directions = { left = true, right = true, up = true, down = true }

local GAP_IN = 5
local GAP_OUT = 20

local function leaf(id)
    return { id = id }
end

local function split(axis, children)
    return { axis = axis, children = children }
end

local function is_leaf(node)
    return node and node.id ~= nil
end

local function contains(node, id)
    if not node then
        return false
    end
    if is_leaf(node) then
        return node.id == id
    end
    for _, child in ipairs(node.children) do
        if contains(child, id) then
            return true
        end
    end
    return false
end

local function normalize(node)
    if not node or is_leaf(node) then
        return node
    end
    local children = {}
    for _, child in ipairs(node.children) do
        child = normalize(child)
        if child then
            if not is_leaf(child) and child.axis == node.axis then
                for _, grandchild in ipairs(child.children) do
                    table.insert(children, grandchild)
                end
            else
                table.insert(children, child)
            end
        end
    end
    if #children == 0 then
        return nil
    end
    if #children == 1 then
        return children[1]
    end
    node.children = children
    return node
end

local function remove_leaf(node, id)
    if not node then
        return nil, nil
    end
    if is_leaf(node) then
        if node.id == id then
            return nil, node
        end
        return node, nil
    end
    for i, child in ipairs(node.children) do
        if contains(child, id) then
            local updated, removed = remove_leaf(child, id)
            if updated then
                node.children[i] = updated
            else
                table.remove(node.children, i)
            end
            return normalize(node), removed
        end
    end
    return node, nil
end

local function insert_after(node, anchor_id, inserted, axis)
    if is_leaf(node) then
        if node.id == anchor_id then
            return split(axis, { node, inserted }), true
        end
        return node, false
    end
    for i, child in ipairs(node.children) do
        if contains(child, anchor_id) then
            if node.axis == axis then
                table.insert(node.children, i + 1, inserted)
                return node, true
            end
            local updated, done = insert_after(child, anchor_id, inserted, axis)
            node.children[i] = updated
            return normalize(node), done
        end
    end
    return node, false
end

local function insert_before(node, anchor_id, inserted, axis)
    if is_leaf(node) then
        if node.id == anchor_id then
            return split(axis, { inserted, node }), true
        end
        return node, false
    end
    for i, child in ipairs(node.children) do
        if contains(child, anchor_id) then
            if node.axis == axis then
                table.insert(node.children, i, inserted)
                return node, true
            end
            local updated, done = insert_before(child, anchor_id, inserted, axis)
            node.children[i] = updated
            return normalize(node), done
        end
    end
    return node, false
end

local function path_to(node, id, path)
    if is_leaf(node) then
        return node.id == id and path or nil
    end
    for i, child in ipairs(node.children) do
        if contains(child, id) then
            local next_path = {}
            for j, entry in ipairs(path) do
                next_path[j] = entry
            end
            table.insert(next_path, { node = node, index = i })
            return path_to(child, id, next_path)
        end
    end
    return nil
end

local function set_parent_axis(node, id, axis)
    if is_leaf(node) then return false end
    for _, child in ipairs(node.children) do
        if contains(child, id) then
            if is_leaf(child) then
                node.axis = axis
                return true
            end
            if set_parent_axis(child, id, axis) then return true end
        end
    end
    return false
end

local function edge_axis(direction)
    return (direction == "left" or direction == "right") and "h" or "v"
end

local function collect_ids(node, ids)
    if is_leaf(node) then
        table.insert(ids, node.id)
    else
        for _, child in ipairs(node.children) do
            collect_ids(child, ids)
        end
    end
end

local function two_clusters(ids, targets, axis)
    local points, sizes = {}, {}
    for _, id in ipairs(ids) do
        local box = targets[id] and targets[id].box
        if not box then return nil end
        local pos = axis == "h" and box.x or box.y
        local size = axis == "h" and box.w or box.h
        table.insert(sizes, size)
        table.insert(points, { id = id, center = pos + size / 2 })
    end
    table.sort(points, function(a, b) return a.center < b.center end)
    local largest, cut = -1, nil
    for i = 1, #points - 1 do
        local gap = points[i + 1].center - points[i].center
        if gap > largest then largest, cut = gap, i end
    end
    if not cut or cut ~= 2 then return nil end
    table.sort(sizes)
    if largest <= math.max(2, sizes[2] * 0.5) then return nil end
    return {
        { points[1].id, points[2].id },
        { points[3].id, points[4].id },
    }
end

local function reshape_2x2(state, id, direction, targets)
    local ids = {}
    collect_ids(state.root, ids)
    if #ids ~= 4 then return false end

    local columns = two_clusters(ids, targets, "h")
    local rows = two_clusters(ids, targets, "v")
    if not columns or not rows then return false end

    local row_of, column_of = {}, {}
    for r, row in ipairs(rows) do
        for _, window_id in ipairs(row) do row_of[window_id] = r end
    end
    for c, column in ipairs(columns) do
        for _, window_id in ipairs(column) do column_of[window_id] = c end
    end

    local vertical_move = direction == "up" or direction == "down"
    local paired, pair_axis
    if vertical_move then
        local column = columns[column_of[id]]
        for _, candidate in ipairs(column) do
            if candidate ~= id and ((direction == "up" and row_of[candidate] < row_of[id])
                or (direction == "down" and row_of[candidate] > row_of[id])) then
                paired = candidate
                break
            end
        end
        if not paired then
            for _, candidate in ipairs(column) do
                if candidate ~= id then paired = candidate end
            end
        end
        pair_axis = "v"
    else
        local row = rows[row_of[id]]
        for _, candidate in ipairs(row) do
            if candidate ~= id and ((direction == "left" and column_of[candidate] < column_of[id])
                or (direction == "right" and column_of[candidate] > column_of[id])) then
                paired = candidate
                break
            end
        end
        if not paired then
            for _, candidate in ipairs(row) do
                if candidate ~= id then paired = candidate end
            end
        end
        pair_axis = "h"
    end
    if not paired then return false end

    local singles = {}
    for _, window_id in ipairs(ids) do
        if window_id ~= id and window_id ~= paired then
            table.insert(singles, window_id)
        end
    end
    local outer_axis = vertical_move and "h" or "v"
    table.sort(singles, function(a, b)
        local aa, bb = targets[a].box, targets[b].box
        if outer_axis == "h" then return aa.x < bb.x end
        return aa.y < bb.y
    end)
    local pair = { id, paired }
    table.sort(pair, function(a, b)
        local aa, bb = targets[a].box, targets[b].box
        if pair_axis == "h" then return aa.x < bb.x end
        return aa.y < bb.y
    end)

    local children = { leaf(singles[1]), leaf(singles[2]), split(pair_axis, { leaf(pair[1]), leaf(pair[2]) }) }
    state.root = split(outer_axis, children)
    return true
end

local function move_window(state, id, direction, targets)
    if not state.root or not contains(state.root, id) then
        return
    end

    state.presentation = nil
    if reshape_2x2(state, id, direction, targets) then
        return
    end

    local axis = edge_axis(direction)
    local toward_start = direction == "left" or direction == "up"
    local path = path_to(state.root, id, {}) or {}
    local anchor

    -- Find the closest split on this axis with room in the requested direction.
    for i = #path, 1, -1 do
        local entry = path[i]
        local index = entry.index
        if entry.node.axis == axis then
            local neighbor_index = toward_start and (index - 1) or (index + 1)
            local neighbor = entry.node.children[neighbor_index]
            if neighbor then
                local function edge_leaf(node, first)
                    if is_leaf(node) then
                        return node.id
                    end
                    return edge_leaf(node.children[first and 1 or #node.children], first)
                end
                anchor = edge_leaf(neighbor, not toward_start)
                break
            end
        end
    end

    local old_root = state.root
    local updated_root, moved = remove_leaf(old_root, id)
    if not moved then
        return
    end

    local new_leaf = leaf(id)
    if anchor then
        if toward_start then
            updated_root = select(1, insert_before(updated_root, anchor, new_leaf, axis))
        else
            updated_root = select(1, insert_after(updated_root, anchor, new_leaf, axis))
        end
    elseif updated_root then
        if toward_start then
            updated_root = split(axis, { new_leaf, updated_root })
        else
            updated_root = split(axis, { updated_root, new_leaf })
        end
    else
        updated_root = new_leaf
    end

    state.root = normalize(updated_root)
end

local function groups_for_axis(targets, ids, axis)
    local ordered = {}
    for _, id in ipairs(ids) do
        local target = targets[id]
        local box = target and target.box
        if not box then
            return nil
        end
        local start = axis == "h" and box.x or box.y
        local size = axis == "h" and box.w or box.h
        table.insert(ordered, { id = id, start = start, finish = start + size })
    end
    table.sort(ordered, function(a, b) return a.start < b.start end)

    local best_gap, best_index = 0, nil
    for i = 1, #ordered - 1 do
        local gap = ordered[i + 1].start - ordered[i].finish
        if gap > best_gap then
            best_gap, best_index = gap, i
        end
    end
    return ordered, best_gap, best_index
end

local function build_from_geometry(targets, ids, area)
    if #ids == 1 then
        return leaf(ids[1])
    end

    local ordered_h, gap_h, cut_h = groups_for_axis(targets, ids, "h")
    local ordered_v, gap_v, cut_v = groups_for_axis(targets, ids, "v")
    local threshold_h = math.max(2, area.w * 0.001)
    local threshold_v = math.max(2, area.h * 0.001)
    local axis

    if cut_h and gap_h > threshold_h and cut_v and gap_v > threshold_v then
        axis = area.w >= area.h and "h" or "v"
    elseif cut_h and gap_h > threshold_h then
        axis = "h"
    elseif cut_v and gap_v > threshold_v then
        axis = "v"
    else
        axis = area.w >= area.h and "h" or "v"
        table.sort(ids, function(a, b)
            local aa, bb = targets[a].box, targets[b].box
            if axis == "h" then
                return aa.x < bb.x or (aa.x == bb.x and aa.y < bb.y)
            end
            return aa.y < bb.y or (aa.y == bb.y and aa.x < bb.x)
        end)
        local children = {}
        for _, id in ipairs(ids) do
            table.insert(children, leaf(id))
        end
        return split(axis, children)
    end

    local ordered, cut = axis == "h" and ordered_h or ordered_v, axis == "h" and cut_h or cut_v
    local before, after = {}, {}
    for i, item in ipairs(ordered) do
        table.insert(i <= cut and before or after, item.id)
    end
    local function bounds(group)
        local x1, y1, x2, y2
        for _, id in ipairs(group) do
            local b = targets[id].box
            x1, y1 = math.min(x1 or b.x, b.x), math.min(y1 or b.y, b.y)
            x2, y2 = math.max(x2 or (b.x + b.w), b.x + b.w), math.max(y2 or (b.y + b.h), b.y + b.h)
        end
        return { x = x1, y = y1, w = x2 - x1, h = y2 - y1 }
    end
    return split(axis, {
        build_from_geometry(targets, before, bounds(before)),
        build_from_geometry(targets, after, bounds(after)),
    })
end

local function sync(state, ctx)
    local targets, present, ids = {}, {}, {}
    local workspace_id = "unknown"
    for _, target in ipairs(ctx.targets) do
        local window = target.window
        local id = window and tostring(window.stable_id) or ("target:" .. tostring(target.index))
        targets[id] = target
        present[id] = true
        table.insert(ids, id)
        if window and window.workspace then
            workspace_id = tostring(window.workspace.id)
        end
    end

    local current_ids = {}
    local function collect(node)
        if not node then return end
        if is_leaf(node) then
            current_ids[node.id] = true
        else
            for _, child in ipairs(node.children) do collect(child) end
        end
    end
    collect(state.root)

    if not state.root and #ids > 0 then
        state.root = build_from_geometry(targets, ids, ctx.area)
    else
        for id in pairs(current_ids) do
            if not present[id] then
                state.root = select(1, remove_leaf(state.root, id))
            end
        end
        for _, id in ipairs(ids) do
            if not current_ids[id] then
                local anchor
                for _, target in ipairs(ctx.targets) do
                    if target.window and target.window.active then
                        anchor = tostring(target.window.stable_id)
                        break
                    end
                end
                if anchor and contains(state.root, anchor) then
                    state.root = select(1, insert_after(state.root, anchor, leaf(id), state.default_axis))
                elseif state.root then
                    state.root = split(state.default_axis, { state.root, leaf(id) })
                else
                    state.root = leaf(id)
                end
            end
        end
    end
    state.workspace_id = workspace_id
    return targets
end

local function place_tree(node, targets, area)
    if is_leaf(node) then
        local target = targets[node.id]
        if target then
            local half_gap = GAP_IN / 2
            target:place({
                x = area.x + half_gap,
                y = area.y + half_gap,
                w = math.max(1, area.w - GAP_IN),
                h = math.max(1, area.h - GAP_IN),
            })
        end
        return
    end

    local n = #node.children
    for i, child in ipairs(node.children) do
        local child_area
        if node.axis == "h" then
            child_area = {
                x = area.x + area.w * (i - 1) / n,
                y = area.y,
                w = area.w / n,
                h = area.h,
            }
        else
            child_area = {
                x = area.x,
                y = area.y + area.h * (i - 1) / n,
                w = area.w,
                h = area.h / n,
            }
        end
        place_tree(child, targets, child_area)
    end
end

hl.layout.register("i3tree", {
    recalculate = function(ctx)
        local workspace_id = "unknown"
        for _, target in ipairs(ctx.targets) do
            if target.window and target.window.workspace then
                workspace_id = tostring(target.window.workspace.id)
                break
            end
        end
        local state = states[workspace_id]
        if not state then
            state = { root = nil, default_axis = "h" }
            states[workspace_id] = state
        end

        local targets = sync(state, ctx)
        if not state.root then return end
        local area = {
            x = ctx.area.x + GAP_OUT,
            y = ctx.area.y + GAP_OUT,
            w = math.max(1, ctx.area.w - 2 * GAP_OUT),
            h = math.max(1, ctx.area.h - 2 * GAP_OUT),
        }
        if state.presentation == "tabbed" or state.presentation == "stacking" then
            local ordered = {}
            for _, target in ipairs(ctx.targets) do
                local id = target.window and tostring(target.window.stable_id) or ("target:" .. tostring(target.index))
                table.insert(ordered, id)
            end
            if state.presentation == "tabbed" then
                table.sort(ordered, function(a, b)
                    local a_active = targets[a] and targets[a].window and targets[a].window.active
                    local b_active = targets[b] and targets[b].window and targets[b].window.active
                    return not a_active and b_active
                end)
                for _, id in ipairs(ordered) do
                    if targets[id] then targets[id]:place(area) end
                end
            else
                local offset = math.min(28, area.h / math.max(1, #ordered))
                for i, id in ipairs(ordered) do
                    local y_offset = math.min((i - 1) * offset, area.h - 1)
                    if targets[id] then
                        targets[id]:place({ x = area.x, y = area.y + y_offset, w = area.w, h = math.max(1, area.h - y_offset) })
                    end
                end
            end
        else
            place_tree(state.root, targets, area)
        end
    end,

    layout_msg = function(ctx, msg)
        local command, direction = msg:match("^(%S+)%s*(%S*)$")
        local workspace_id, active_id, active_window = "unknown", nil, nil
        for _, target in ipairs(ctx.targets) do
            local window = target.window
            if window and window.workspace then
                workspace_id = tostring(window.workspace.id)
            end
            if window and window.active then
                active_id, active_window = tostring(window.stable_id), window
            end
        end
        local state = states[workspace_id]

        if command == "focus" and directions[direction] then
            local focused = hl.get_active_window() or active_window
            local focused_id = focused and tostring(focused.stable_id)
            local focused_box
            for _, target in ipairs(ctx.targets) do
                if target.window and tostring(target.window.stable_id) == focused_id then
                    focused_box = target.box
                    break
                end
            end

            local nearest, nearest_score
            if focused_box then
                local fx, fy = focused_box.x + focused_box.w / 2, focused_box.y + focused_box.h / 2
                for _, target in ipairs(ctx.targets) do
                    local window, box = target.window, target.box
                    if window and tostring(window.stable_id) ~= focused_id and box then
                        local dx, dy = box.x + box.w / 2 - fx, box.y + box.h / 2 - fy
                        local primary, perpendicular
                        if direction == "left" then primary, perpendicular = -dx, math.abs(dy)
                        elseif direction == "right" then primary, perpendicular = dx, math.abs(dy)
                        elseif direction == "up" then primary, perpendicular = -dy, math.abs(dx)
                        else primary, perpendicular = dy, math.abs(dx) end
                        local score = primary + perpendicular * 1.5
                        if primary > 0 and (not nearest_score or score < nearest_score) then
                            nearest, nearest_score = window, score
                        end
                    end
                end
            end

            if nearest then
                hl.timer(function()
                    hl.dispatch(hl.dsp.focus({ window = nearest }))
                end, { timeout = 1, type = "oneshot" })
            else
                -- If this workspace has no window in that direction, cross to
                -- the nearest monitor in the same direction. Focusing its
                -- active workspace also transfers focus to that monitor.
                local current_monitor = hl.get_active_monitor()
                local monitors = hl.get_monitors()
                local best_monitor, best_score
                if current_monitor then
                    local cx = current_monitor.x + current_monitor.width / 2
                    local cy = current_monitor.y + current_monitor.height / 2
                    for _, monitor in ipairs(monitors) do
                        if monitor.name ~= current_monitor.name then
                            local mx = monitor.x + monitor.width / 2
                            local my = monitor.y + monitor.height / 2
                            local dx, dy = mx - cx, my - cy
                            local primary, perpendicular
                            if direction == "left" then primary, perpendicular = -dx, math.abs(dy)
                            elseif direction == "right" then primary, perpendicular = dx, math.abs(dy)
                            elseif direction == "up" then primary, perpendicular = -dy, math.abs(dx)
                            else primary, perpendicular = dy, math.abs(dx) end
                            local score = primary + perpendicular * 1.5
                            if primary > 0 and (not best_score or score < best_score) then
                                best_monitor, best_score = monitor, score
                            end
                        end
                    end
                end
                if best_monitor and best_monitor.active_workspace then
                    hl.timer(function()
                        hl.dispatch(hl.dsp.focus({ workspace = best_monitor.active_workspace.name }))
                    end, { timeout = 1, type = "oneshot" })
                end
            end
            return true
        elseif command == "move" and directions[direction] then
            if state and active_id then
                state.presentation = nil
                move_window(state, active_id, direction, sync(state, ctx))
            end
            return true
        elseif command == "togglesplit" then
            if state and active_id then
                state.presentation = nil
                local path = path_to(state.root, active_id, {}) or {}
                local entry = path[#path]
                if entry then
                    entry.node.axis = entry.node.axis == "h" and "v" or "h"
                else
                    state.default_axis = state.default_axis == "h" and "v" or "h"
                end
            end
            return true
        elseif command == "splith" or command == "splitv" then
            if state and active_id then
                state.presentation = nil
                local axis = command == "splith" and "h" or "v"
                if set_parent_axis(state.root, active_id, axis) then
                    state.root = normalize(state.root)
                else
                    state.default_axis = axis
                end
            end
            return true
        elseif command == "stacking" or command == "tabbed" then
            if state then state.presentation = command end
            return true
        end

        return "i3tree: unsupported layout message " .. msg
    end,
})
