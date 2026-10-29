
local structure = require("structure")
local fields = require("fields")
local config = require("config")

local bitset = {};

local function mprint(msg)
  if config.debug_prints then
    print("bitset.lua: "..msg)
  end
end

function bitset.BitSetField(args, field)

  local bs = {
    name = args.name,
    subname = args.subname,
    position = args.position,
    size = args.size,
    fieldName = args.fieldName,
    padding = args.padding,
    field = field,
    func = "BitSet, LSB --> MSB"
  }

  local itemStruct

  local function getNumItems()
    return (bs.size-bs.padding) / bs.field.size
  end

  local function isItemFieldExpandEnabled()
    return config.arrays.expand_item_field and getNumItems() < config.arrays.expand_max_items
  end

  local function isItemField()
    return bs.field.baseType == "atomic"
  end

  local function getItemStructSize()
    return (bs.size-bs.padding)
  end

  local function getItemStructPosition()
    return bs.field.position
  end

  local function getItemStructName()
    if bs.subname == nil then
      bs.subname = bs.name
    end
    return bs.subname
  end

  local function getItemIndexesFieldTable()
    local fieldTbl = {}
    for idx=0,getNumItems()-1 do
      field = fields.ByteField({
        name=bs.name.."_".. bs.field.name .."_"..idx,
        position=bs.field.size * idx},
        bs.field.protoFieldFunc,
        bs.field.baseFunc,
        bs.field.size,
        bs.field.func)
      mprint(field.name)
      table.insert(fieldTbl,
        field)
    end
    return fieldTbl
  end

  local function getMaxViewBytes()
    local maxViewBytes
    if getItemStructSize() > 32 then
      maxViewBytes = 32
    end
    return maxViewBytes
  end

  local function getItemBytesFieldTable()
    return {
      fields.BytesField({
        name=getItemStructName(),
        position=0,
        maxViewBytes=getMaxViewBytes(),
        size=getItemStructSize()})
    }
  end

  function bs.generateProtoFieldArrayItem(proto, msgMod)
    if isItemField() and isItemFieldExpandEnabled() then
      itemStruct = structure.StructureField(
        {
          name=getItemStructName(),
          position=getItemStructPosition(),
          size=getItemStructSize(),
        },
        getItemIndexesFieldTable()
      )
    else
      itemStruct = structure.StructureField(
        {
          name=getItemStructName(),
          position=getItemStructPosition(),
          size=getItemStructSize(),
        },
        getItemBytesFieldTable()
      )
    end
    itemStruct.generateProtoField(proto, msgMod)
  end

  function bs.dissectArrayItem(pinfo, proto, tree, buffer, offset)
    if itemStruct then
      itemStruct.dissector(pinfo, proto, tree, buffer, offset)
    else
      error("dissectArrayItem: itemStruct should not be nil!")
    end
  end

  local function getFieldLabel()
    local label = bs.name
    if config.fields.display_func_name then
      label = label .. " (" .. bs.func .. ")"
    end
    return label
  end

  function bs.generateProtoField(proto, msgMod)
    if bs.fieldName then
      bs.name = bs.fieldName
    end
    bs.generateProtoFieldArrayItem(proto, msgMod)
  end

  function bs.dissector(pinfo, proto, tree, buffer, offset)
    if isItemField() then
      itemStruct.position = bs.position
    end
    local status, sub_buffer = pcall(buffer, offset + bs.position, bs.size)
    if not status then
      sub_buffer = buffer(offset)
    end
    local subtree = tree:add (proto, sub_buffer)
    subtree:set_text(getFieldLabel())
    bs.dissectArrayItem(pinfo, proto, subtree, buffer, offset)
  end

  return bs

end

return bitset
