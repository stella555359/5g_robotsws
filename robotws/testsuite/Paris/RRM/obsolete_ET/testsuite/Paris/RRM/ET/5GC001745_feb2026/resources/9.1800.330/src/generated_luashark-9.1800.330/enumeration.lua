local config = require("config")
local ProtoField = ProtoField

local enumeration = {};

local function mprint(msg)
  if config.debug_prints then
    print("enumeration.lua: "..msg)
  end
end

function enumeration.Field(args, protoFieldFunc, size, baseType)

  local ef = {
    name = args.name,
    position = args.position,
    enumTerm = args.enumTerm,
    size = size,
    func = "Enum",
    protoFieldFunc = protoFieldFunc,
    baseFunc = base.DEC,
    value = nil,
    baseType = baseType
  }

  local protoFieldObj
  local protoFieldName
  local protoFieldDesc


  local function getFieldLabel()
    local label = ef.name
    if config.fields.display_func_name then
      label = label .. " (" .. ef.func .. ")"
    end
    return label
  end

  local function printDissectorEnumeratedFieldInfo(offset, bufLen)
    mprint(" decoding field name="..ef.name.." offset="..offset..
           " position="..ef.position.." size="..ef.size..
           " bufLen="..bufLen..
           " outOfRange="..
           tostring(fieldOutOfRange(offset, bufLen, ef.position, ef.size)))
  end

  local function setFieldValue(bufferValue)
    if ef.size <= 8 then -- max 8 bytes for int64
      if tostring(ef.baseType):find('uint') == nil then
        if config.endpoint.litte_endian then
          ef.value = tonumber(tostring(bufferValue:le_int64()))
        else
          ef.value = tonumber(tostring(bufferValue:int64()))
        end
      else
        if config.endpoint.litte_endian then
          ef.value = tonumber(tostring(bufferValue:le_uint64()))
        else
          ef.value = tonumber(tostring(bufferValue:uint64()))
        end
      end
    end
  end

  local function addFieldToTree(proto, tree, buffer, offset, fieldSize)
    local treeitem
    if fieldSize <= 0 then return 0 end
    local bufferValue = buffer(offset + ef.position, fieldSize)
    setFieldValue( bufferValue )
    ef.name = ef.enumTerm[ef.value] or " (_UNKNOWN_)"
    if config.endpoint.litte_endian then
      treeitem = tree:add_le(protoFieldObj, bufferValue)
    else
      treeitem = tree:add(protoFieldObj, bufferValue)
    end
    treeitem:append_text(ef.name)

  end

  local function handleOutOfRangeField(proto, tree, buffer, offset)
    if ef.size > buffer:len() then
      addFieldToTree(proto, tree, buffer, offset, buffer:len()-offset-ef.position)
    end
    printMalformedWarn(tree, buffer, offset, ef)
  end

  local function setProtoFieldAttr(msgMod, parent)
    if parent then
      protoFieldName = msgMod:protoName().."."..parent.name.."."..ef.name
    else
      protoFieldName = msgMod:protoName().."."..ef.name
    end
    protoFieldDesc = getFieldLabel()
  end

  function ef.generateProtoField(proto, msgMod, parent)
    setProtoFieldAttr(msgMod, parent)
    protoFieldObj = protoFieldFunc(protoFieldName, protoFieldDesc, baseFunc)
    table.insert(proto.fields, protoFieldObj)
  end

  function ef.dissector(pinfo, proto, tree, buffer, offset)
    printDissectorEnumeratedFieldInfo(offset, buffer:len())
    if not fieldOutOfRange(offset, buffer:len(), ef.position, ef.size) then
      addFieldToTree(proto, tree, buffer, offset, ef.size)
    else
      handleOutOfRangeField(proto, tree, buffer, offset)
    end
    return tree
  end

  return ef
end

return enumeration
