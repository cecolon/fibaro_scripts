-- Persistent storage for VDs, heavily inspired from Krikoff's Sonos VD
local persist = { 
  persist_global_var = "lua_persist",
  load = function(this)
    local persist_table_str = fibaro:getGlobalValue(this.persist_global_var)
    if string.len(persist_table_str) > 0 and persist_table_str ~= "NaN" then
      local persist_table = json.decode(persist_table_str)
      if persist_table and type(persist_table) == "table" then 
        return persist_table
      else
        fibaro:debug("Error loading persistent table: " .. (persistent_table_str or "(empty)"))
      end
    else
      fibaro:debug("Empty table string, initializing.")
      this:init()
    end
  end,
  getId = function(this)
    return "id_" .. fibaro:getSelfId()
  end,
  loadLocalTable = function(this)
    return this:load()[this:getId()]
  end,
  commitLocalTable = function(this, commit_table)
    local persist_table = this:load()
    persist_table[this:getId()] = commit_table
    fibaro:setGlobal(this.persist_global_var, json.encode(persist_table))
  end,
  set = function(this, set_table)
      local persist_table = this:loadLocalTable()
      if persist_table then
        for key, value in pairs(set_table) do
          persist_table[key] = value
        end
      else 
        persist_table = set_table
      end;
      this:commitLocalTable(persist_table)
    end,
  get = function(this, get_key)
      local persist_table = this:loadLocalTable()
      if persist_table and type(persist_table) == "table" then 
        for key, value in pairs(persist_table) do
          if tostring(key) == tostring(get_key or "") then
            return value
          end
        end
      end;
      return nil
    end,
  clear = function(this, clear_key)
    local persist_table = this:loadLocalTable()
    persist_table[clear_key] = nil
    this:commitLocalTable(persist_table)
  end,
  reset = function(this)
    local persist_table = this:load()
    local vd_id = "id_" .. fibaro:getSelfId()
    if persist_table[vd_id] then
      persist_table[vd_id] = nil
    end
    fibaro:setGlobal(this.persist_global_var, json.encode(persist_table)) 
  end,
  init = function(this)
    fibaro:setGlobal(this.persist_global_var, json.encode({}))
  end,
}
