local config = require("config")
local unions = require("unions")

local function mprint(msg)
  if config.debug_prints then
    print("structure.lua: "..msg)
  end
end

local e = {}

function e.ExtensionPointField(args, fields)
  local eptf = {
    name = args.name,
    position = args.position,
    size = args.size,
    fieldName = args.fieldName,
    fields = fields,
    func = "Extension Point",
  }

  local items = nil

  local function getFieldLabel()
    local label = eptf.name
    if config.fields.display_func_name then
      label = label .. " (" .. eptf.func .. ")"
    end
    return label
  end

  local function printDissectorStructureInfo(offset, bufLen)
    mprint("  decoding structure name="..eptf.name.." offset="..offset..
           " position="..eptf.position.." size="..eptf.size..
           " bufLen="..bufLen)
  end

  local function getDynamicOffset(offset, field)
    local offset = offset
    offset = offset + field.offsetField.value
    return offset
  end

  local function getArrayItemIndexesUnionFieldTable(field)
    local fieldTbl = {}
    for idx=0, field.numItems-1 do
      table.insert(fieldTbl,
        unions.DynamicUnionField(
          {
            name=field.name.."_item_"..idx,
            position=field.position + field.field.size * idx,
            fieldName=field.name.."_item_"..idx,
            numDiscriminatorPaddingBytes=field.field.numDiscriminatorPaddingBytes,
            size=field.field.size,
            subname=field.field.name
          },
          field.field.discrimType,
          field.field.offsetType,
          field.field.fields,
          field.field.discriminators)
      )
    end
    return fieldTbl
  end

  local function dissectorOffset(offset, buffer, field)
    local bufferValue = buffer(offset + field.offsetField.position, field.offsetField.size)
    if config.endpoint.litte_endian then
      field.offsetField.value = tonumber(tostring(bufferValue:le_uint64()))
    else
      field.offsetField.value = tonumber(tostring(bufferValue:uint64()))
    end
  end

  local function dissectorDynArrayLength(offset, buffer, field)
    local bufferValue = buffer(offset + field.lengthField.position, field.lengthField.size)
    if config.endpoint.litte_endian then
      field.lengthField.value = tonumber(tostring(bufferValue:le_uint64()))
    else
      field.lengthField.value = tonumber(tostring(bufferValue:uint64()))
    end
  end

  local function dissectorDiscriminator(offset, bufferValue, proto, subtree, field)
    if config.endpoint.litte_endian then
      field.discrimField.value = tonumber(tostring(bufferValue:le_uint64()))
    else
      field.discrimField.value = tonumber(tostring(bufferValue:uint64()))
    end
  end

  local function dissectorUnion(pinfo, proto, subtree, buffer, offset, field)
    dissectorOffset(offset, buffer, field)
    local bufferValue = buffer(offset + field.discrimField.position, field.discrimField.size)
    dissectorDiscriminator(offset, bufferValue, proto, subtree, field)
    subtree = subtree:add (proto, bufferValue)
    subtree:set_text("Discriminator: "..field.discrimField.value)
    field.discrimIdx = nil
    for idx, discriminatorId in pairs(field.discriminators) do
      if discriminatorId == field.discrimField.value then
        field.discrimIdx = idx
      end
    end
    field.selectedField = field.fieldsWithoutPadding[field.discrimIdx]
    if field.selectedField ~= nil and field.selectedField.size > 0 then
      field.selectedField.dissector(pinfo, proto, subtree,
        buffer, offset + field.position + field.offsetField.value)
    elseif field.selectedField ~= nil and field.selectedField.size == 0 then
      subtree = subtree:add (proto, buffer(offset + field.position + field.offsetField.value,0))
      subtree:set_text(field.selectedField.name.." (Void)")
    else
      subtree = subtree:add (proto, buffer(offset + field.position + field.offsetField.value,0))
      subtree:set_text("_UNKNOWN_ (Void)")
    end
  end

  local function dissectorArrayItems(pinfo, proto, subtree, buffer, offset, field)
    for idx, item in pairs(items) do
      if  idx > field.lengthField.value then
         break
      end
      dissectorUnion(pinfo, proto, subtree, buffer, offset, item)
    end
  end

  function eptf.generateProtoField(proto, msgMod)
    if (eptf.fieldName) then
      eptf.name = eptf.fieldName
    end
    for idx, field in pairs(eptf.fields) do
      field.generateProtoField(proto, msgMod, eptf)
      items = getArrayItemIndexesUnionFieldTable(field)
    end
    for idx, field in pairs(items) do
      field.generateProtoField(proto, msgMod, eptf.fields[1])
    end
  end

  function eptf.dissector(pinfo, proto, tree, buffer, offset)
    local subtree
    local status, sub_buffer = pcall(buffer, offset + eptf.position, eptf.size)
    if not status then
      sub_buffer = buffer(offset + eptf.position)
    end
    subtree = tree:add (proto, sub_buffer)
    subtree:set_text(getFieldLabel())
    printDissectorStructureInfo(offset, buffer:len())
    for idx, field in pairs(eptf.fields) do
      dissectorOffset(offset + eptf.position, buffer, field)
      dissectorDynArrayLength(offset + eptf.position, buffer, field)
      dissectorArrayItems(pinfo, proto, subtree, buffer, getDynamicOffset(offset + eptf.position, field), field)
    end
    return subtree
  end

  return eptf
end

return e
