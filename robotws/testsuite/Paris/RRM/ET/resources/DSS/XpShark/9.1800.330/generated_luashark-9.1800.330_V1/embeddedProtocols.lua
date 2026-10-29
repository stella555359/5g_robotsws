local config = require("config")
local fields = require("fields")

local ep = {}

function ep.EmbeddedProtocol(args, dissectorName, func, lengthType, offsetType)
  -----------------------
  ---- Public Fields
  -----------------------
  local ef = {
    name = args.name,
    name_path = args.name,
    position = args.position,
    size = args.size,
    size_unit = args.size_unit,
    fieldName = args.fieldName,
    func = func or "EmbeddedProtocol",
    dissectorName = dissectorName,
    lengthField = nil,
    offsetField = nil,
    lengthType = lengthType,
    offsetType = offsetType
  }

  -----------------------
  ---- Private Fields
  -----------------------

  -----------------------
  ---- Private Functions
  -----------------------

  ---- Return Embedded Protocol Field label name (the string that appears in the tree)
  local function getFieldLabel()
    local label = ef.name
    if config.fields.display_func_name then
      label = label .. " (" .. ef.func .. ")"
    end
    return label
  end

  local function get_bytes_occupied()
    if ef.size_unit == 8 then
      return ef.lengthField.value
    else
      return (ef.lengthField.value + 7) / 8
    end
  end

  -----------------------
  ---- Public Functions
  -----------------------

  local function isStatic()
    return ef.func == "StaticEmbeddedProtocol" or ef.func == "ArrayCompatibleStaticEmbeddedProtocol"
  end

  function ef.generateStatic(proto, msgMod)
    if ef.lengthType ~= nil then
      ef.lengthField = ef.lengthType({name=ef.name.."-Length", position=ef.position})
      if config.name_path_flag == true then
        ef.lengthField.generateProtoField(proto, msgMod, ef)
      else
        ef.lengthField.generateProtoField(proto, msgMod)
      end
    end
  end

  function ef.generateDynamic(proto, msgMod)
    ef.offsetField = ef.offsetType({name=ef.name.."-Offset", position=args.position})
    ef.lengthField = ef.lengthType({name=ef.name.."-Length", position=args.position + ef.offsetField.size})
    if config.name_path_flag == true then
      ef.offsetField.generateProtoField(proto, msgMod, ef)
      ef.lengthField.generateProtoField(proto, msgMod, ef)
    else
      ef.offsetField.generateProtoField(proto, msgMod)
      ef.lengthField.generateProtoField(proto, msgMod)
    end
  end

  ---- Generate EmbeddedProtocol ProtoFields
  function ef.generateProtoField(proto, msgMod, prev)
    ef.name = ef.fieldName
    ef.name_path = ef.name
    if prev ~= nil then
      ef.name_path = prev.name_path.."."..ef.name
    end
    if isStatic() then
      ef.generateStatic(proto, msgMod)
    else
      ef.generateDynamic(proto, msgMod)
    end
  end

  function ef.dissectStatic(pinfo, proto, tree, buffer, offset)
    if ef.lengthType ~= nil then
      ef.lengthField.dissector(pinfo, proto, tree, buffer, offset, ef)
      Dissector.get(ef.dissectorName):call(buffer(offset+ef.position+ef
      .lengthField.size, get_bytes_occupied()):tvb(),pinfo, tree)
    else
      Dissector.get(ef.dissectorName):call(buffer(offset+ef.position
      ,ef.size):tvb(),pinfo, tree)
    end
  end

  function ef.dissectDynamic(pinfo, proto, tree, buffer, offset)
    ef.offsetField.dissector(pinfo, proto, tree, buffer, offset, ef)
    ef.lengthField.dissector(pinfo, proto, tree, buffer, offset, ef)
    Dissector.get(ef.dissectorName):call(buffer(offset+ef.position+
            ef.offsetField.value,get_bytes_occupied()):tvb(),pinfo, tree)
  end

  local function dissectEp(pinfo, proto, tree, buffer, offset)
    local status, sub_buffer = pcall(buffer, offset + ef.position, ef.size)
    if not status then
      sub_buffer = buffer(offset + ef.position)
    end
    local subtree = tree:add (proto, sub_buffer)
    subtree:set_text(getFieldLabel())
    if isStatic() then
      ef.dissectStatic(pinfo, proto, subtree, buffer, offset)
    else
      ef.dissectDynamic(pinfo, proto, subtree, buffer, offset)
    end
  end

  function ef.dissector(pinfo, proto, tree, buffer, offset, prev)
    if not fieldOutOfRange(offset, buffer:len(), ef.position, ef.size) then
      ef.name = ef.fieldName
      ef.name_path = ef.name
      if prev ~= nil then
        ef.name_path = prev.name_path.."."..ef.name
      end
      dissectEp(pinfo, proto, tree, buffer, offset)
    else
      printMalformedWarn(tree, buffer, offset, ef)
    end
  end

  ---- return the instance
  return ef
end


function ep.StaticEmbeddedProtocol(args, lengthType, dissectorName)
  ---- inherit from EmbeddedProtocolField base class
  return ep.EmbeddedProtocol(args, dissectorName,
    "StaticEmbeddedProtocol",
    lengthType
  )
end

function ep.DynamicEmbeddedProtocol(args, offsetType, lengthType, dissectorName)
  ---- inherit from EmbeddedProtocolField base class
  return ep.EmbeddedProtocol(args, dissectorName,
    "DynamicEmbeddedProtocol",
    lengthType,
    offsetType
  )
end

function ep.ArrayCompatibleStaticEmbeddedProtocol(args, dissectorName)
  ---- inherit from EmbeddedProtocolField base class
  args.size_unit=8
  return ep.EmbeddedProtocol(args, dissectorName,
    "ArrayCompatibleStaticEmbeddedProtocol",
    nil
  )
end

function ep.ArrayCompatibleDynamicEmbeddedProtocol(args, dissectorName)
  ---- inherit from EmbeddedProtocolField base class
  args.size_unit=8
  return ep.EmbeddedProtocol(args, dissectorName,
    "ArrayCompatibleDynamicEmbeddedProtocol",
    fields.Uint32Field,
    fields.Uint32Field
  )
end


return ep;
