local config = require("config")
local fields = require("fields")

local tti = {}

function tti.TtiStreamingType(args, lengthType, streamField, func)
  -----------------------
  ---- Public Fields
  -----------------------
  local tf = {
    name = args.name,
    name_path = args.name,
    position = args.position,
    size = args.size,
    size_unit = args.size_unit,
    fieldName = args.fieldName,
    func = func or "TtiStreamingType",
    streamField = streamField,
    lengthType = lengthType,
    lengthField = nil,
    msgMod = nil
  }

  local function getFieldLabel()
    local label = tf.name
    if config.fields.display_func_name then
      label = label .. " (" .. tf.func .. ")"
    end
    return label
  end

  function tf.generateProtoFieldLength(proto, msgMod)
    tf.lengthField = tf.lengthType({name=tf.name.."-UsedSize", position=args.position})
    if config.name_path_flag == true then
      tf.lengthField.generateProtoField(proto, msgMod, tf)
    else
      tf.lengthField.generateProtoField(proto, msgMod)
    end
  end

  function tf.generateProtoField(proto, msgMod, prev)
    tf.msgMod = msgMod
    tf.name = tf.fieldName
    tf.name_path = tf.name
    if prev ~= nil then
      tf.name_path = prev.name_path.."."..tf.name
    end
    tf.generateProtoFieldLength(proto, msgMod)
    if config.name_path_flag == true then
      tf.streamField.generateProtoField(proto, msgMod, tf)
    else
      tf.streamField.generateProtoField(proto, msgMod)
    end
  end

  function tf.dissectLengthField(pinfo, proto, tree, buffer, offset)
    if tf.lengthField then tf.lengthField.dissector(pinfo, proto, tree, buffer, offset, tf) end
  end

  function tf:increaseOffset(offset)
    return offset + tf.streamField.selectedField.size + tf.streamField.headerSize
  end

  function tf.dissectEvents(pinfo, proto, subtree, buffer, offset)
    local localOffset = tf.lengthField.size
    while localOffset < tf.lengthField.value do
      tf.streamField.dissector(pinfo, proto, subtree, buffer, offset+localOffset, tf)
      localOffset = tf:increaseOffset(localOffset)
    end
  end

  function tf.dissector(pinfo, proto, tree, buffer, offset, prev)
    tf.name = tf.fieldName
    tf.name_path = tf.name
    if prev ~= nil then
      tf.name_path = prev.name_path.."."..tf.name
    end
    local subtree = tree:add (proto, buffer(offset))
    subtree:set_text(getFieldLabel())
    tf.dissectLengthField(pinfo, proto, subtree, buffer, offset)
    tf.dissectEvents(pinfo, proto, subtree, buffer, offset)
  end

  return tf
end



return tti;
