local config = require("config")

local function mprint(msg)
  if config.debug_prints then
    print("structure.lua: "..msg)
  end
end

local s = {}

function s.StructureField(args, fields)

  local sf = {
    name = args.name,
    name_path = args.name,
    position = args.position,
    size = args.size,
    fieldName = args.fieldName,
    fields = fields,
    func = "Structure",
  }

  local function getFieldLabel()
    local label = sf.name
    if config.fields.display_func_name then
      label = label .. " (" .. sf.func .. ")"
    end
    return label
  end

  local function printDissectorStructureInfo(offset, bufLen)
    mprint("  decoding structure name="..sf.name.." offset="..offset..
           " position="..sf.position.." size="..sf.size..
           " bufLen="..bufLen)
  end

  function sf.generateProtoField(proto, msgMod, prev)
    if (sf.fieldName) then
      sf.name = sf.fieldName
      sf.name_path = sf.name
    end
    if prev ~= nil then
      sf.name_path = prev.name_path.."."..sf.name
    end

    for idx, field in pairs(sf.fields) do
      field.generateProtoField(proto, msgMod, sf)
    end
  end

  function sf.dissector(pinfo, proto, tree, buffer, offset, prev, numItems)
    local subtree
    if (sf.fieldName) then
      sf.name = sf.fieldName
      sf.name_path = sf.name
    end
    if prev ~= nil then
      sf.name_path = prev.name_path.."."..sf.name
    end

    if numItems ~= nil then
        subtree = tree:add (proto, buffer(offset + sf.position, sf.fields[1].size * numItems))
    else
        local status, sub_buffer = pcall(buffer, offset + sf.position, sf.size)
        if not status then
          local status, sub_buffer = pcall(buffer, offset + sf.position)
          if not status then
            printMalformedWarn(tree, buffer, offset + sf.position, sf)
          end
        end
        subtree = tree:add (proto, sub_buffer)
    end

    subtree:set_text(getFieldLabel())
    printDissectorStructureInfo(offset, buffer:len())
    for idx, field in pairs(sf.fields) do
      if numItems ~= nil and idx > numItems then
        break
      end
      field.dissector(pinfo, proto, subtree, buffer, offset + sf.position, sf)
    end
    return subtree
  end

  return sf
end

return s
