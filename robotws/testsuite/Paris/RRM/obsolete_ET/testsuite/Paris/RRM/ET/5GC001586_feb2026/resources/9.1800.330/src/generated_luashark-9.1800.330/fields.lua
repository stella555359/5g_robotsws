
local config = require("config")
local ProtoField = ProtoField

local function mprint(msg)
  if config.debug_prints then
    print("fields.lua: "..msg)
  end
end

local field = {};

function field.Field(args, protoFieldFunc, baseFunc, size, func)

  local f = {
    name = args.name,
    position = args.position,
    size = size,
    func = func,
    protoFieldFunc = protoFieldFunc,
    baseFunc = baseFunc,
    value = nil,
    baseType = "atomic"
  }

  local protoFieldObj
  local protoFieldName
  local protoFieldDesc


  local function getFieldLabel()
    local label = f.name
    if config.fields.display_func_name then
      label = label .. " (" .. f.func .. ")"
    end
    return label
  end

  local function fieldOutOfRange(offset, bufLen)
    return ( (offset + f.position) >= bufLen ) or ( f.size > bufLen )
  end

  local function printDissectorFieldInfo(offset, bufLen)
    mprint("  decoding field name="..f.name.." offset="..offset..
           " position="..f.position.." size="..f.size..
           " bufLen="..bufLen..
           " outOfRange="..tostring(fieldOutOfRange(offset, bufLen)))
  end

  local function setFieldValue(bufferValue)
    if f.size <= 8 then -- max 8 bytes for int64
      if config.endpoint.litte_endian then
        f.value = tonumber(tostring(bufferValue:le_uint64()))
      else
        f.value = tonumber(tostring(bufferValue:uint64()))
      end
    end
  end

  local function addFieldToTree(proto, tree, buffer, offset, fieldSize)
    local treeitem
    if fieldSize <= 0 then return 0 end
    local bufferValue = buffer(offset + f.position, fieldSize)
    setFieldValue(bufferValue)
    if config.endpoint.litte_endian then
      treeitem = tree:add_le (protoFieldObj, bufferValue)
    else
      treeitem = tree:add (protoFieldObj, bufferValue)
    end
    if f.func ~= "Bytes" and string.find(f.func,"Float") ~= 1 then
      treeitem:append_text("("..tostring(f.value)..")")
    end
  end

  local function handleOutOfRangeField(proto, tree, buffer, offset)
    if f.size > buffer:len() then
      addFieldToTree(proto, tree, buffer, offset, buffer:len()-offset-f.position)
    end
    tree:add_expert_info(PI_MALFORMED, PI_WARN,
      "Not enough bytes in buffer to read "..f.name.." field "..
      "(field.position="..f.position.." + field.size="..f.size..
      " + offset="..offset.." > buffer.size="..buffer:len()..")")
  end

  local function setProtoFieldAttr(msgMod, parent)
    if parent then
      protoFieldName = msgMod:protoName().."."..parent.name.."."..f.name
    else
      protoFieldName = msgMod:protoName().."."..f.name
    end
    protoFieldDesc = getFieldLabel()
  end

  function f.generateProtoField(proto, msgMod, parent)
    setProtoFieldAttr(msgMod, parent)
    protoFieldObj = protoFieldFunc(protoFieldName, protoFieldDesc, baseFunc)
    table.insert(proto.fields, protoFieldObj)
  end

  function f.dissector(pinfo, proto, tree, buffer, offset)
    printDissectorFieldInfo(offset, buffer:len())
    if not fieldOutOfRange(offset, buffer:len()) then
      addFieldToTree(proto, tree, buffer, offset, f.size)
    else
      handleOutOfRangeField(proto, tree, buffer, offset)
    end
    return tree
  end

  return f
end


function field.ByteField(args)

  local f = {
    name = args.name,
    position = args.position,
    size = 1,
    protoFieldFunc = ProtoField.uint8,
    func = "byte",
    baseFunc = base.HEX,
    value = nil,
    baseType = "atomic"
  }


  local function getDescription(bufferValue)
    local intBuffer = bufferValue:bitfield(0, 8)
    local binary = ""
    local i = 0
    repeat

      local val = bit.rshift(intBuffer, i)
      val = bit.band(val, 1)
      binary = binary..val
      i = i + 1
    until (i == 8)

    return f.name..": 0x"..bufferValue.." ("..binary..")"

  end

  local function addFieldToTree(proto, tree, buffer, offset, fieldSize)
    if fieldSize <= 0 then return 0 end
    local bufferValue = buffer(offset + f.position, fieldSize)
    local desc = getDescription(bufferValue)
    tree:add(ProtoField.uint8(f.name), bufferValue, desc)
  end

  local function handleOutOfRangeField(proto, tree, buffer, offset)
    if f.size > buffer:len() then
      addFieldToTree(proto, tree, buffer, offset, buffer:len()-offset-f.position)
    end
    tree:add_expert_info(PI_MALFORMED, PI_WARN,
      "Not enough bytes in buffer to read "..f.name.." field "..
              "(field.position="..f.position.." + field.size="..f.size..
              " + offset="..offset.." > buffer.size="..buffer:len()..")")
  end

  local function fieldOutOfRange(offset, bufLen)
    return ( (offset + f.position) >= bufLen ) or ( f.size > bufLen )
  end

  function f.generateProtoField(proto, msgMod, parent)
  end

  function f.dissector(pinfo, proto, tree, buffer, offset)
    if not fieldOutOfRange(offset, buffer:len()) then
      addFieldToTree(proto, tree, buffer, offset, f.size)
    else
      handleOutOfRangeField(proto, tree, buffer, offset)
    end
    return tree
  end

  return f

end

function field.VoidField(args)
    return field.Field(args, ProtoField.uint8, base.HEX, 0, "Uint8")
end

function field.BytesField(args)
  return field.Field(args, ProtoField.bytes, base.NONE, (args.maxViewBytes == nil) and args.size or args.maxViewBytes, "Bytes")
end

function field.Uint8Field(args)
  return field.Field(args, ProtoField.uint8, base.HEX, 1, "Uint8")
end

function field.Uint16Field(args)
  return field.Field(args, ProtoField.uint16, base.HEX, 2, "Uint16")
end

function field.Uint32Field(args)
  return field.Field(args, ProtoField.uint32, base.HEX, 4, "Uint32")
end

function field.Uint64Field(args)
  return field.Field(args, ProtoField.uint64, base.HEX, 8, "Uint64")
end

function field.Int8Field(args)
  return field.Field(args, ProtoField.int8, base.DEC, 1, "Int8")
end

function field.Int16Field(args)
  return field.Field(args, ProtoField.int16, base.DEC, 2, "Int16")
end

function field.Int32Field(args)
  return field.Field(args, ProtoField.int32, base.DEC, 4, "Int32")
end

function field.Int64Field(args)
  return field.Field(args, ProtoField.int64, base.DEC, 8, "Int64")
end

function field.Float32Field(args)
  return field.Field(args, ProtoField.float, base.NONE, 4, "Float32")
end

function field.BooleanField(args)
  --TODO: change boolean from unit8 to bit field or (true, false) string ?
  return field.Field(args, ProtoField.uint8, base.HEX, 1, "Boolean")
end

function field.PaddingField(args)
  return field.BytesField(args)
end

return field
