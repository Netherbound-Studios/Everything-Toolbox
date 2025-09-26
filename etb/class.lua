local utils = require('etb.utils')

local Class = {}

local function make_class(name, super, defaults)
  local cls = {}
  cls.__name = name or '<Anonymous>'
  cls.__index = cls
  cls.__defaults = defaults or {}
  cls.__super = super
  cls.__is_class = true

  -- allow calling the class like a function: MyClass(...) -> MyClass:new(...)
  setmetatable(cls, {
    __call = function(self, ...)
      return self:new(...)
    end
  })

  function cls:new(...)
    local obj = setmetatable({}, self)
    obj.class = self

    -- merge defaults from inheritance chain (closest ancestor first)
    local merged = {}
    local cur = self
    local chain = {}
    while cur do
      table.insert(chain, 1, cur)
      cur = cur.__super
    end
    for _,c in ipairs(chain) do
      if c.__defaults then
        utils.copy_defaults(merged, c.__defaults)
      end
    end

    for k,v in pairs(merged) do obj[k] = v end

    if type(obj.init) == 'function' then
      obj:init(...)
    end
    return obj
  end

  function cls:extend(subname, subdefaults)
    subdefaults = subdefaults or {}
    local subclass = make_class(subname or (self.__name .. 'Child'), self, subdefaults)

    -- copy existing metamethods so subclass can be called
    local mt = getmetatable(self) or {}
    setmetatable(subclass, { __index = self, __call = mt.__call or function(self, ...) return self:new(...) end })

    return subclass
  end

  -- include mixin: shallow copy of functions/fields
  function cls:include(mixin)
    for k,v in pairs(mixin) do
      if k ~= '__included' then
        self[k] = v
      end
    end
    if type(mixin.__included) == 'function' then
      mixin.__included(self)
    end
    return self
  end

  -- call the superclass method with the same name as the caller (best-effort)
  function cls:super(...)
    -- try to infer method name from debug info
    -- Try several stack frames to find a named caller (works across runtimes/wrappers)
    local method_name
    for i = 2, 8 do
      local info = debug.getinfo(i, 'n')
      if info and info.name then
        method_name = info.name
        break
      end
    end

    -- Fallback: if still unknown, try to locate the caller function in the
    -- class chain by comparing function references. Be conservative: skip
    -- obvious helper keys and stop if we would pick the same function as the
    -- current caller (to avoid recursion).
    if not method_name then
      local finfo = debug.getinfo(2, 'f')
      local caller_fn = finfo and finfo.func
      if caller_fn then
        local c = self.class
        while c do
          for k,v in pairs(c) do
            if k == 'super' or k == 'supercall' or k == 'new' or k == 'extend' or k == 'include' or k == 'isInstance' then goto continue end
            if v == caller_fn then
              method_name = k
              break
            end
            ::continue::
          end
          if method_name then break end
          c = c.__super
        end
      end
    end

    if not method_name then
      error("super() couldn't determine caller method name; call with explicit method name: self:super('method', ...)")
    end

    local parent = self.class and self.class.__super
    while parent do
      local fn = parent[method_name]
      -- avoid calling the same function we believe is the caller (prevents recursion)
      if fn and not (self.class and self.class[method_name] == fn) then
        return fn(self, ...)
      end
      parent = parent.__super
    end
    error("no superclass method '" .. tostring(method_name) .. "' found")
  end

  -- explicit form: self:super('methodName', ...)
  function cls:supercall(method_name, ...)
    local parent = self.class and self.class.__super
    while parent do
      local fn = parent[method_name]
      if fn then
        return fn(self, ...)
      end
      parent = parent.__super
    end
    error("no superclass method '" .. tostring(method_name) .. "' found")
  end

  -- helper: is object instance of class or subclass
  function cls:isInstance(obj)
    if type(obj) ~= 'table' then return false end
    local c = obj.class
    while c do
      if c == self then return true end
      c = c.__super
    end
    return false
  end

  return cls
end

local function new(name_or_table, maybe)
  -- two forms: Class('Name') or Class{name=..., defaults=...} or Class('Name', defaults)
  if type(name_or_table) == 'string' then
    if type(maybe) == 'table' and maybe.__is_class then
      return make_class(name_or_table, maybe, {})
    else
      return make_class(name_or_table, nil, maybe)
    end
  elseif type(name_or_table) == 'table' then
    local name = name_or_table.name
    local super = name_or_table.super
    local defaults = name_or_table.defaults or name_or_table
    return make_class(name, super, defaults)
  else
    return make_class(nil, nil, {})
  end
end

setmetatable(Class, { __call = function(_, ...) return new(...) end })

return Class


