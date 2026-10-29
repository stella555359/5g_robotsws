local xp_internal_messages_XpIfInternalMessage_t = require("xp/internal/messages/XpIfInternalMessage_t")

local message = xp_internal_messages_XpIfInternalMessage_t("XpInternalMessage", 0)

local msgMod = {}
local msgProto = nil

function msgMod:nameSpace()
  return 'xp_internal'
end

function msgMod:messageName()
  return 'XpInternalMessage'
end

function msgMod:messageId()
  return 30238
end

function msgMod:messageDescription()
  return 'XpInternalMessage'
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
