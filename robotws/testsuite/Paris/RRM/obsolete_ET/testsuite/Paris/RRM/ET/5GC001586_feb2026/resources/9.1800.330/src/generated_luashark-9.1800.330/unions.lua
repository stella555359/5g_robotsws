local f = require("fields")
local config = require("config")

local function mprint(msg)
  if config.debug_prints then
    print("unions.lua: "..msg)
  end
end

local unions = {}

function unions.UnionField(args, fields, func, discrimType, offsetType, discriminators)

  -----------------------
  ---- Public Fields
  -----------------------

  local uf = {
    name = args.name,
    position = args.position,
    size = args.size,
    numDiscriminatorPaddingBytes = args.numDiscriminatorPaddingBytes,
    fieldName = args.fieldName,
    fields = fields,
    func = func,
    discrimType = discrimType,
    offsetType = offsetType,
    headerSize = nil,
    discrimPaddingField = nil,
    selectedField = nil,
    fieldsWithoutPadding = {},
    discriminators = discriminators,
    discrimIdx = nil
  }

  -----------------------
  ---- Private Fields
  -----------------------

  -----------------------
  ---- Private Functions
  -----------------------

  local function printDissectorUnionInfo(offset, bufLen)
    mprint("  decoding "..func.." name="..uf.name.." offset="..offset..
            " position="..uf.position.." size="..uf.size..
            " bufLen="..bufLen)
  end

  ---- Return Union Field label name (the string that appears in the tree)
  local function getFieldLabel()
    local label = uf.name
    if config.fields.display_func_name then
      label = label .. " (" .. uf.func .. ")"
    end
    return label
  end

  -----------------------
  ---- Public Functions
  -----------------------

  local function isStatic()
    return uf.func == "StaticUnion"
  end

  local function generateStatic(proto, msgMod)
    uf.discrimField = uf.discrimType({name=uf.name.."-Discriminator", position=args.position})
    uf.discrimField.generateProtoField(proto, msgMod, uf)
    uf.headerSize = uf.discrimField.size + args.numDiscriminatorPaddingBytes
    if uf.numDiscriminatorPaddingBytes > 0 then
      uf.discrimPaddingField = f.BytesField({
        name=uf.name.."-Discriminator_padding",
        position=args.position+uf.discrimField.size,
        maxViewBytes=uf.numDiscriminatorPaddingBytes,
        size=uf.numDiscriminatorPaddingBytes})
      uf.discrimPaddingField.generateProtoField(proto, msgMod, uf)
    end
    for idx, field in pairs(uf.fields) do
      field.position = 0
      field.generateProtoField(proto, msgMod, uf)
    end
  end

  local function generateDynamic(proto, msgMod)
    uf.offsetField = uf.offsetType({name=uf.name.."-Offset", position=args.position})
    uf.discrimField = uf.discrimType({name=uf.name.."-Discriminator", position=args.position+uf.offsetField.size})
    uf.offsetField.generateProtoField(proto, msgMod, uf)
    uf.discrimField.generateProtoField(proto, msgMod, uf)
    uf.headerSize = uf.discrimField.size + uf.offsetField.size
    for idx, field in pairs(uf.fields) do
      field.position = 0
      field.generateProtoField(proto, msgMod, uf)
    end
  end

  local function setDiscriminatorIdx(discrimId)
    for idx, discriminatorId in pairs(uf.discriminators) do
      if discriminatorId == discrimId then
        uf.discrimIdx = idx
      end
    end
  end

  local function setSelectedField(discrim)
    uf.discrimIdx = nil
    if uf.discriminators ~= nil then
      setDiscriminatorIdx(discrim)
      uf.selectedField = uf.fieldsWithoutPadding[uf.discrimIdx]
    else
      uf.selectedField = uf.fieldsWithoutPadding[discrim + 1]
    end
  end

  local function dissectStatic(pinfo, proto, tree, buffer, offset)
    uf.discrimField.dissector(pinfo, proto, tree, buffer, offset)
    if uf.discrimPaddingField ~= nil then
      uf.discrimPaddingField.dissector(pinfo, proto, tree, buffer, offset)
    end
    setSelectedField(uf.discrimField.value)
    local status, sub_buffer = pcall(buffer, offset + uf.position + uf.discrimField.size + uf.numDiscriminatorPaddingBytes,
      uf.selectedField.size)
    if not status then
      sub_buffer = buffer(offset + uf.position + uf.discrimField.size + uf.numDiscriminatorPaddingBytes)
    end
    subtree = tree:add (proto, sub_buffer)
    if uf.selectedField.size > 0 then
        subtree:set_text(uf.name.."-Payload")
        uf.selectedField.dissector(pinfo, proto, subtree, buffer,
          offset + uf.position + uf.discrimField.size + uf.numDiscriminatorPaddingBytes)
    else
        subtree:set_text(uf.name.."-Payload: "..uf.selectedField.name.." (Void)")
    end
  end

  local function dissectDynamic(pinfo, proto, tree, buffer, offset)
    uf.offsetField.dissector(pinfo, proto, tree, buffer, offset)
    uf.discrimField.dissector(pinfo, proto, tree, buffer, offset)
    setSelectedField(uf.discrimField.value)
    local status = false
    local sub_buffer = nil
    if uf.selectedField ~= nil then
      status, sub_buffer = pcall(buffer, offset + uf.position + uf.offsetField.value,
        uf.selectedField.size)
    end
    if not status then
      sub_buffer = buffer(offset + uf.position + uf.offsetField.value)
    end
    subtree = tree:add (proto, sub_buffer)
    if uf.selectedField ~= nil and uf.selectedField.size > 0 then
      subtree:set_text(uf.name.."-Payload")
      uf.selectedField.dissector(pinfo, proto, subtree,
        buffer, offset + uf.position + uf.offsetField.value)
    elseif uf.selectedField ~= nil and uf.selectedField.size == 0 then
      subtree:set_text(uf.name.."-Payload: "..uf.selectedField.name.." (Void)")
    elseif uf.discriminators ~= nil then
      subtree:set_text(uf.name.."-Payload: _UNKNOWN_ (Void)")
    else
      subtree:set_text(uf.name.."-Payload: "..uf.selectedField.name.." (Void)")
    end

  end

  local function setFieldsWithoutPadding()
    for idx, field in pairs(uf.fields) do
      --if not string.find(field.name, "_padding") then
      table.insert(uf.fieldsWithoutPadding, field)
      --  end
    end
  end

  ---- Generate UnionField ProtoFields
  function uf.generateProtoField(proto, msgMod)
    if (uf.fieldName) then
      uf.name = uf.fieldName
    end
    setFieldsWithoutPadding()
    if isStatic() then
      generateStatic(proto, msgMod)
    else
      generateDynamic(proto, msgMod)
    end
  end

  ---- Dissector for UnionField
  function uf.dissector(pinfo, proto, tree, buffer, offset)
    local status, sub_buffer = pcall(buffer, offset + uf.position, uf.size)
    if not status then
      sub_buffer = buffer(offset + uf.position)
    end
    local subtree = tree:add (proto, sub_buffer)
    subtree:set_text(getFieldLabel())
    printDissectorUnionInfo(offset, buffer:len())
    if isStatic() then
      dissectStatic(pinfo, proto, subtree, buffer, offset)
    else
      dissectDynamic(pinfo, proto, subtree, buffer, offset)
    end
  end

  ---- return the instance
  return uf
end


function unions.StaticUnionField(args, discrimType, fields)
  return unions.UnionField(args, fields, "StaticUnion",
    discrimType
  )
end

function unions.DynamicUnionField(args, discrimType, offsetType, fields, discriminators)
  return unions.UnionField(args, fields, "DynamicUnion",
    discrimType,
    offsetType,
    discriminators
  )
end


return unions
