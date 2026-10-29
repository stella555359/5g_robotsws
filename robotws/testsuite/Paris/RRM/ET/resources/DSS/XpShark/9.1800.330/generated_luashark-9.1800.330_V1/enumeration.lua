local config = require("config")
local ProtoField = ProtoField

local enumeration = {};
local protoFieldObjTable = {}

local function mprint(msg)
  if config.debug_prints then
    print("enumeration.lua: "..msg)
  end
end

function enumeration.Field(args, protoFieldFunc, size, baseType)

  local ef = {
    name = args.name,
    descript = args.name,
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
    ef.descript = ef.enumTerm[ef.value] or " (_UNKNOWN_)"
    if config.endpoint.litte_endian then
      treeitem = tree:add_le(protoFieldObj, bufferValue)
    else
      treeitem = tree:add(protoFieldObj, bufferValue)
    end
    treeitem:append_text(ef.descript)

  end

  local function handleOutOfRangeField(proto, tree, buffer, offset)
    if ef.size > buffer:len() then
      addFieldToTree(proto, tree, buffer, offset, buffer:len()-offset-ef.position)
    end
    printMalformedWarn(tree, buffer, offset, ef)
  end

  local function setProtoFieldAttr(msgMod, parent)
    if parent then
      if parent.name_path ~= nil and config.name_path_flag == true then
        protoFieldName = msgMod:protoName().."."..parent.name_path.."."..ef.name
      else
        protoFieldName = msgMod:protoName().."."..parent.name.."."..ef.name
      end
    else
      protoFieldName = msgMod:protoName().."."..ef.name
    end
    protoFieldDesc = getFieldLabel()
  end

  local function insertProtoFieldObjTable(proto, real_name, protoFieldObj)
    if protoFieldObjTable[tostring(proto)] == nil then
      protoFieldObjTable[tostring(proto)] = {}
    end

    if protoFieldObjTable[tostring(proto)][real_name.."."..ef.name] == nil then
      protoFieldObjTable[tostring(proto)][real_name.."."..ef.name] = {}
    end
    protoFieldObjTable[tostring(proto)][real_name.."."..ef.name] = protoFieldObj
  end

  function ef.generateProtoField(proto, msgMod, parent)
    setProtoFieldAttr(msgMod, parent)
    protoFieldObj = protoFieldFunc(protoFieldName, protoFieldDesc, baseFunc)
    table.insert(proto.fields, protoFieldObj)
    if parent then
      local real_name=""
      if config.name_path_flag == true then
        real_name = parent.name_path
        insertProtoFieldObjTable(proto, real_name, protoFieldObj)
      else
        real_name = parent.name
        local pattern_parent = ".+_%d+$"
        local ret  = string.match(parent.name, pattern_parent)
        if ret ~= nil then
          insertProtoFieldObjTable(proto, real_name, protoFieldObj)
        end
      end
    end
  end

  function ef.dissector(pinfo, proto, tree, buffer, offset, prev)
    if prev ~= nil and protoFieldObjTable[tostring(proto)] ~= nil then
      local real_name=""
      if config.name_path_flag == true then
        real_name = prev.name_path
      else
        real_name = prev.name
      end
      if protoFieldObjTable[tostring(proto)][real_name.."."..ef.name] ~= nil then
        protoFieldObj = protoFieldObjTable[tostring(proto)][real_name.."."..ef.name]
      end
    end
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
