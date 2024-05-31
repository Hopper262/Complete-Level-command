function complete_level()

  if Level.calculate_completion_state() == "failed" then
    Players.print("M1 objectives are not supported")
    return
  end
  if Level.calculate_completion_state() == "finished" then
    Players.print("Level is already completed")
    return
  end
  
  local need_wait = false
  
  if Level.extermination then
    Players.print("Exterminating monsters")
    for m in Monsters() do
      if not m.player then
        -- we can't check is_alien: not exposed in Lua
        if Level.rebellion or true then
          m.type.immunities["fists"] = false
          m.active = true
          m.vitality = 0
          m:damage(1, "fists")
          need_wait = true
        end
      end
    end
  end
  
  if Level.exploration then
    Players.print("Exploring polygons")
    for p in Polygons() do
      if p.type == "must be explored" then p.type = PolygonTypes["normal"] end
    end
  end
  
  if Level.repair then
    Players.print("Toggling repair switches")
    for s in Sides() do
      local panel = s.control_panel
      if panel ~= nil and panel.repair then
        local class = panel.type.class
        if class == "platform switch" then
--          local plat = Platforms[Polygons[panel.permutation].permutation]
--          Players.print("Toggling platform " .. plat.index)
--          plat.active = true
--          plat.active = false
          panel.repair = false
        else
          panel.status = true
        end
      end
    end
  end
  
  if Level.retrieval then
    -- item.kind not exposed in Lua, so this fails on some custom MML
    Players.print("Picking up key cards and uplink chips")
    for i in Items() do
      if i.type == "key" or i.type == "uplink chip" then i:delete() end
    end
    
    if Level.calculate_completion_state() == "unfinished" then
      -- try removing all items
      Players.print("Picking up all items")
      for i in Items() do i:delete() end
    end
  end
  
  if Level.calculate_completion_state() == "finished" then
    Players.print("Level is now completed")
  else
    if need_wait then
      Players.print("Monsters are in the process of dying")
    else
      Players.print("Level could not be completed")
    end
  end
  
end
