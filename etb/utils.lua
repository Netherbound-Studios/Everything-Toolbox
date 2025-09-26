local utils = {}

function utils.shallow_copy(dst, src)
  for k,v in pairs(src) do dst[k] = v end
  return dst
end

-- copy defaults only for keys that don't exist in dst
function utils.copy_defaults(dst, src)
  for k,v in pairs(src) do
    if dst[k] == nil then dst[k] = v end
  end
  return dst
end

return utils


