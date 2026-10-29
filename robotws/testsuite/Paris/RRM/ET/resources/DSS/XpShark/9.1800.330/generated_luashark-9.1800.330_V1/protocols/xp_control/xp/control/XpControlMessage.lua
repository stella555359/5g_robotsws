local xp_control_messages_XpControlMessage_t = require("xp/control/messages/XpControlMessage_t")

local message = xp_control_messages_XpControlMessage_t("XpControlMessage", 0)

local msgMod = {}
local msgProto = nil

function msgMod:nameSpace()
  return 'xp_control'
end

function msgMod:messageName()
  return 'XpControlMessage'
end

function msgMod:messageId()
  return 30236
end

function msgMod:messageDescription()
  return 'XpControlMessage'
end

function msgMod:messageFields()
  return message
end

function msgMod:protoName()
  return msgMod:nameSpace()..'_'..msgMod:messageName()
end

function msgMod:getProto()
  return msgProto
end

function msgMod:setProto(newProto)
  msgProto = newProto
end

function msgMod:generateProtoFields()
  status, msgProto = pcall(Proto, msgMod:protoName(), msgMod:protoName())
  if status then
    message.generateProtoField(msgProto, msgMod)
  else
    return nil
  end
  return msgProto ~= nil
end

function msgMod:dissector(buffer, offset, pinfo, tree, msglen)
  message.dissector(pinfo, msgProto, tree, buffer, offset)
end

return msgMod
