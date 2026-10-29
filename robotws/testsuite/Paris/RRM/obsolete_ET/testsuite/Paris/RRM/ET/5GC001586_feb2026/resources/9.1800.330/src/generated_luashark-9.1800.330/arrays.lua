local structure = require("structure")
local bitset = require("bitset")
local stringtype = require("stringType")
local unions = require("unions")
local ep = require("embeddedProtocols")
local fields = require("fields")
local config = require("config")
local enum = require("enumeration")
local arrays = {}

local function mprint(msg)
  if config.debug_prints then
    print("arrays.lua: "..msg)
  end
end

function arrays.ArrayField(args, field, func, lengthField, offsetField)

  local af = {
    name = args.name,
    position = args.position,
    size = args.size,
    numSizePaddingBytes = args.numSizePaddingBytes,
    headerSize = 0,
    numItems = args.numItems,
    numPaddingBytes = args.numPaddingBytes,
    field = field,
    func = func,
    lengthField = lengthField,
    offsetField = offsetField,
    length_padding = nil,
    endPadding = nil,
  }

  local items
  local isBytesField = false

  local function getFieldLabel()
    local label = af.name
    if config.fields.display_func_name then
      label = label .. " (" .. af.func .. ")"
    end
    return label
  end

  local function printDissectorArrayItemInfo(offset, bufLen)
    mprint("  decoding "..func.." name="..af.name.." offset="..offset..
           " position="..af.position.." size="..af.size..
           " bufLen="..bufLen)
  end

  local function getStaticFieldsSize()
    if     af.func == "StaticFixedSizedArray"     then  return 0
    elseif af.func == "StaticVariableSizedArray"  then  return af.headerSize
    elseif af.func == "DynamicVariableSizedArray" then  return af.offsetField.size + af.lengthField.size
    end
  end

  local function getItemStructName()
    if af.func == "StaticFixedSizedArray" then
      return af.name
    else
      return af.name.."-Items"
    end
  end

  local function getItemStructPosition()
    return af.field.position
  end

  local function getItemStructSize()
    if af.func == "StaticFixedSizedArray" then
      return af.size
    else
      return af.size - getStaticFieldsSize()
    end
  end

  local function getItemIndexesFieldTable()
    local fieldTbl = {}
    for idx=0,af.numItems-1 do
      table.insert(fieldTbl,
        fields.Field({name=af.name.."_".. af.field.name .."_"..idx,
              position=af.position + af.field.size * idx,},
              af.field.protoFieldFunc,
              af.field.baseFunc,
              af.field.size,
              af.field.func)
      )
    end
    return fieldTbl
  end

  local function getItemIndexesStructureFieldTable()
    local fieldTbl = {}
    for idx=0,af.numItems-1 do
      table.insert(fieldTbl,
        structure.StructureField(
          {
            name=af.name.."_item_"..idx,
            position=af.position + af.field.size * idx,
            size=af.field.size,
          },
          af.field.fields)
      )
    end
    return fieldTbl
  end

  local function getItemIndexesBitsetFieldTable()
    local fieldTbl = {}
    for idx=0,af.numItems-1 do
      table.insert(fieldTbl,
        bitset.BitSetField(
          {
            name=af.name.."_item_"..idx,
            position=af.position + af.field.size * idx,
            size=af.field.size,
            subname=af.field.name
          },
          af.field.field)
      )
    end
    return fieldTbl
  end

  local function getItemIndexesStringFieldTable()
    local fieldTbl = {}
    for idx=0,af.numItems-1 do
      table.insert(fieldTbl,
        stringtype.StringField(
          {
            name=af.name.."_item_"..idx,
            position=af.position + af.field.size * idx,
            size=af.field.size,
            fieldName = af.field.fieldName.."_item_"..idx,
            capacity=af.field.capacity
          })
      )
    end
    return fieldTbl
  end

  local function getItemIndexesUnionFieldTable()
    local fieldTbl = {}
    if af.field.func == "StaticUnion" then
      for idx=0,af.numItems-1 do
        table.insert(fieldTbl,
          unions.StaticUnionField(
            {
              name=af.name.."_item_"..idx,
              position=af.position + af.field.size * idx,
              fieldName=af.name.."_item_"..idx,
              numDiscriminatorPaddingBytes=af.field.numDiscriminatorPaddingBytes,
              size=af.field.size,
              subname=af.field.name
            },
            af.field.discrimType,
            af.field.fields)
        )
      end
    else
      for idx=0,af.numItems-1 do
        table.insert(fieldTbl,
          unions.DynamicUnionField(
            {
              name=af.name.."_item_"..idx,
              position=af.position + af.field.size * idx,
              fieldName=af.name.."_item_"..idx,
              numDiscriminatorPaddingBytes=af.field.numDiscriminatorPaddingBytes,
              size=af.field.size,
              subname=af.field.name
            },
            af.field.discrimType,
            af.field.offsetType,
            af.field.fields,
            af.field.discriminators)
        )
      end
    end
    return fieldTbl
  end

  local function getItemIndexesEPFieldTable()
    local fieldTbl = {}
    if af.field.func == "StaticEmbeddedProtocol" then
      for idx=0,af.numItems-1 do
        table.insert(fieldTbl,
          ep.StaticEmbeddedProtocol({
              name=af.name.."_item_"..idx,
              position=af.position + af.field.size * idx,
              fieldName=af.name.."_item_"..idx,
              size_unit=af.field.size_unit,
              size=af.field.size,
              subname=af.field.name
            },
            af.field.lengthType,
            af.field.dissectorName)
        )
      end
    else
      for idx=0,af.numItems-1 do
        table.insert(fieldTbl,
          ep.DynamicEmbeddedProtocol({
              name=af.name.."_item_"..idx,
              position=af.position + af.field.size * idx,
              fieldName=af.name.."_item_"..idx,
              size_unit=af.field.size_unit,
              size=af.field.size,
              subname=af.field.name
            },
            af.field.lengthType,
            af.field.offsetType,
            af.field.dissectorName)
        )
      end
    end
    return fieldTbl
  end

  local function getItemIndexesEnumFieldTable()
    local fieldTbl = {}
    for idx=0,af.numItems-1 do
      table.insert(fieldTbl,
        enum.Field({name=af.name.."_".. af.field.name .."_"..idx,
              position=af.position + af.field.size * idx,
              enumTerm = af.field.enumTerm},
              af.field.protoFieldFunc,
              af.field.size,
              af.field.baseType)
      )
    end
    return fieldTbl
  end

  local function getMaxViewBytes()
    local maxViewBytes
    if af.func ~= "StaticFixedSizedArray" and
            getItemStructSize() > 32 then
        maxViewBytes = 32
    end
    return maxViewBytes
  end

  local function getItemBytesFieldTable()
      return {
        fields.BytesField({
          name=getItemStructName(),
          position=af.position,
          maxViewBytes=getMaxViewBytes(),
          size=getItemStructSize()})
        }
  end

  local function isItemField()
    return af.field.baseType == "atomic"
  end

  local function isItemStructure()
    return af.field.func == "Structure"
  end

  local function isItemBitset()
    return af.field.func == "BitSet, LSB --> MSB"
  end

  local function isItemStringType()
    return af.field.func == "String"
  end

  local function isItemEP()
    return string.match(af.field.func, "EmbeddedProtocol")
  end

  local function isItemUnion()
    return string.match(af.field.func, "Union")
  end

  local function isItemEnum()
    return string.match(af.field.func, "Enum")
  end

  local function isItemFieldExpandEnabled()
    return config.arrays.expand_item_field and
           af.numItems < config.arrays.expand_max_items
  end

  local function isItemStructureExpandEnabled()
    return config.arrays.expand_item_structure and
           af.numItems < config.arrays.expand_max_items
  end

  local function isItemBitsetExpandEnabled()
    return config.arrays.expand_item_bitset and
           af.numItems < config.arrays.expand_max_items
  end

  local function isItemEPExpandEnabled()
    return config.arrays.expand_item_ep and
           af.numItems < config.arrays.expand_max_items
  end

  local function isItemUnionExpandEnabled()
    return config.arrays.expand_item_union and
           af.numItems < config.arrays.expand_max_items
  end

  local function getVariableLength()
    if af.func == "StaticFixedSizedArray" then
      return af.numItems
    else
      return af.lengthField.value
    end
  end

  local function getDynamicOffset(offset)
    local offset = offset
    if af.offsetField ~=nil then
      offset = offset + af.offsetField.value
    else
      offset = offset + getStaticFieldsSize()
    end
    return offset
  end

  function af.generateProtoFieldOffset(proto, msgMod)
    if af.offsetField then af.offsetField.generateProtoField(proto, msgMod) end
  end

  function af.generateProtoFieldLength(proto, msgMod)
    if af.lengthField then
      if af.offsetField ~=nil then
        af.lengthField.position = args.position + af.offsetField.size
      end
      af.lengthField.generateProtoField(proto, msgMod)

      if af.numSizePaddingBytes > 0 then
        af.length_padding = fields.BytesField({
          name=af.name.."-Length_padding",
          position=args.position+af.lengthField.size,
          maxViewBytes=af.numSizePaddingBytes,
          size=af.numSizePaddingBytes})
        af.length_padding.generateProtoField(proto, msgMod, af)
      end
    end
  end

  function af.generateProtoFieldPadding(proto, msgMod)
    if af.numPaddingBytes > 0 then
      af.endPadding = fields.BytesField({
        name=af.name.."_padding",
        position=af.position + af.size - af.numPaddingBytes,
        maxViewBytes=af.numPaddingBytes,
        size=af.numPaddingBytes})
      af.endPadding.generateProtoField(proto, msgMod, af)
    end
  end

  function af.generateProtoFieldArrayItem(proto, msgMod)
    if isItemField() and isItemFieldExpandEnabled() then
      items = getItemIndexesFieldTable()
    elseif isItemStructure() and isItemStructureExpandEnabled() then
      items = getItemIndexesStructureFieldTable()
    elseif isItemBitset() and isItemBitsetExpandEnabled()  then
      items = getItemIndexesBitsetFieldTable()
    elseif isItemStringType() then
      items = getItemIndexesStringFieldTable()
    elseif isItemEP() and isItemEPExpandEnabled()  then
      items = getItemIndexesEPFieldTable()
    elseif isItemUnion() and isItemUnionExpandEnabled()  then
      items = getItemIndexesUnionFieldTable()
    elseif isItemEnum() and isItemFieldExpandEnabled()  then
      items = getItemIndexesEnumFieldTable()
    else
      isBytesField = true
      items = getItemBytesFieldTable()
    end
    for idx, field in pairs(items) do
      field.generateProtoField(proto, msgMod, af)
    end
  end

  function af.dissectOffsetField(pinfo, proto, tree, buffer, offset)
    if af.offsetField then af.offsetField.dissector(pinfo, proto, tree, buffer, offset) end
  end

  function af.dissectLengthField(pinfo, proto, tree, buffer, offset)
    if af.lengthField then
      af.lengthField.dissector(pinfo, proto, tree, buffer, offset)
      if isBytesField then
        items[1].size = af.lengthField.value * af.field.size
      end
    end
    if af.length_padding ~= nil then
      af.length_padding.dissector(pinfo, proto, tree, buffer, offset)
    end
  end

  function af.dissectArrayItem(pinfo, proto, tree, buffer, offset)
    local subtree = tree
    if af.func ~= "StaticFixedSizedArray" then
      local status, sub_buffer = pcall(buffer, offset + af.position,
        getVariableLength())
      if not status then
        sub_buffer = buffer(offset + af.position)
      end
      subtree = tree:add (proto, sub_buffer)
      subtree:set_text(af.name.."-Payload")
    else
      if isBytesField then
        items[1].size = getVariableLength() * af.field.size
      end
      subtree:set_text(getFieldLabel())
    end
    printDissectorArrayItemInfo(offset, buffer:len())
    for idx, field in pairs(items) do
      if  getVariableLength() ~= nil and idx >  getVariableLength() then
         break
      end
      field.dissector(pinfo, proto, subtree, buffer, offset)
    end
  end

  function af.dissectPadding(pinfo, proto, tree, buffer, offset)
    if af.endPadding then
      af.endPadding.dissector(pinfo, proto, tree, buffer, offset)
    end
  end

  function af.setHeaderSize()
    if af.lengthField ~= nil then
      af.headerSize = af.numSizePaddingBytes + af.lengthField.size
    end
  end

  function af.generateProtoField(proto, msgMod)
    af.setHeaderSize()
    af.generateProtoFieldOffset(proto, msgMod)
    af.generateProtoFieldLength(proto, msgMod)
    af.generateProtoFieldArrayItem(proto, msgMod)
    af.generateProtoFieldPadding(proto, msgMod)
  end

  function af.dissector(pinfo, proto, tree, buffer, offset)
    local status, sub_buffer = pcall(buffer, offset + af.position, af.size)
    if not status then
      sub_buffer = buffer(offset + af.position)
    end
    local subtree = tree:add (proto, sub_buffer)
    subtree:set_text(getFieldLabel())
    af.dissectOffsetField(pinfo, proto, subtree, buffer, offset)
    af.dissectLengthField(pinfo, proto, subtree, buffer, offset)
    af.dissectArrayItem(pinfo, proto, subtree, buffer, getDynamicOffset(offset))
    af.dissectPadding(pinfo, proto, subtree, buffer, offset)
  end

  return af
end

function arrays.StaticFixedSizedArrayField(args, field)
  return arrays.ArrayField(args, field,
  "StaticFixedSizedArray")
end

function arrays.StaticVariableSizedArrayField(args, lengthField, field)
  return arrays.ArrayField(args, field,
    "StaticVariableSizedArray",
    lengthField({name=args.name.."-Length", position=args.position})
  )
end

function arrays.DynamicVariableSizedArrayField(args, offsetField, lengthField, field)
  return arrays.ArrayField(args, field,
    "DynamicVariableSizedArray",
    lengthField({name=args.name.."-Length", position=args.position}),
    offsetField({name=args.name.."-Offset", position=args.position})
  )
end


return arrays
