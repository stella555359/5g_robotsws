local config = require("config")
local fields = require("fields")
local ProtoField = ProtoField

local stringtype = {};
local protoFieldObjTable = {}

local function mprint(msg)
  if config.debug_prints then
    print("string.lua: "..msg)
  end
end

function stringtype.StringField(args)

  local str = {
    name = args.name,
    position = args.position,
    size = args.size,
    protoFieldFunc = ProtoField.string,
    capacity = args.capacity,
    fieldName = args.fieldName,
    length_padding = nil,
    func = "String"
  }

  local protoFieldObj
  local protoFieldName
  local protoFieldDesc

  local function getFieldLabel()
    local label = str.fieldName
    if config.fields.display_func_name then
      label = label .. " (" .. str.func .. ")"
    end
    return label
  end

  local function printDissectorStringFieldInfo(offset)
    mprint(" decoding name="..str.name.." field name="..str.fieldName.." offset="..offset..
           " position="..str.position.." size="..str.size)
  end

  local function setProtoFieldAttr(msgMod, parent)
    if parent then
      if parent.name_path ~= nil and config.name_path_flag == true then
        protoFieldName = msgMod:protoName().."."..parent.name_path.."."..str.fieldName
      else
        protoFieldName = msgMod:protoName().."."..parent.name.."."..str.fieldName
      end
    else
      protoFieldName = msgMod:protoName().."."..str.fieldName
    end
    protoFieldDesc = getFieldLabel()
  end

  local function insertProtoFieldObjTable(proto, real_name, protoFieldObj)
    if protoFieldObjTable[tostring(proto)] == nil then
      protoFieldObjTable[tostring(proto)] = {}
    end

    if protoFieldObjTable[tostring(proto)][real_name.."."..str.name] == nil then
      protoFieldObjTable[tostring(proto)][real_name.."."..str.name] = {}
    end
    protoFieldObjTable[tostring(proto)][real_name.."."..str.name] = protoFieldObj
  end

  function str.generateProtoField(proto, msgMod, parent)
    setProtoFieldAttr(msgMod, parent)
    protoFieldObj = str.protoFieldFunc(protoFieldName, protoFieldDesc, base.ASCII)
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

    local numSizePaddingBytes = str.size-str.capacity
    if numSizePaddingBytes > 0 then
      str.length_padding = fields.BytesField({
        name=str.fieldName.."_padding",
        position=str.position+str.capacity,
        maxViewBytes=numSizePaddingBytes,
        size=numSizePaddingBytes})
      str.length_padding.generateProtoField(proto, msgMod, str)
    end
  end

  local function dissectStr(pinfo, proto, tree, buffer, offset)
    printDissectorStringFieldInfo(offset)
    local status, valueBuffer = pcall(buffer, offset + str.position, str.capacity)
    if not status then
      valueBuffer = buffer(offset + str.position)
    end
    local subtree = tree:add (protoFieldObj, valueBuffer)
    subtree:append_text(" (0x"..valueBuffer..")")
    if str.length_padding ~= nil then
      str.length_padding.dissector(pinfo, proto, tree, buffer, offset)
    end
  end

  function str.dissector(pinfo, proto, tree, buffer, offset, prev)
    if prev ~= nil and protoFieldObjTable[tostring(proto)] ~= nil then
      local real_name=""
      if config.name_path_flag == true then
        real_name = prev.name_path
      else
        real_name = prev.name
      end
      if protoFieldObjTable[tostring(proto)][real_name.."."..str.name] ~= nil then
        protoFieldObj = protoFieldObjTable[tostring(proto)][real_name.."."..str.name]
      end
    end
    if not fieldOutOfRange(offset, buffer:len(), str.position, str.capacity) then
      dissectStr(pinfo, proto, tree, buffer, offset)
    else
      printMalformedWarn(tree, buffer, offset, str, str.capacity)
    end
  end

  return str
end

return stringtype
