local UlData_PucchReceiveReq_t = require("UlData/PucchReceiveReq_t")

local message = UlData_PucchReceiveReq_t("PucchReceiveReq", 0)
require("UCI")

local msgMod = {}
local msgProto = nil

function msgMod:nameSpace()
  return 'UlData'
end

function msgMod:messageName()
  return 'PucchReceiveReq'
end

function msgMod:messageId()
  return 588
end

function msgMod:messageDescription()
  return 'PucchReceiveReq'
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
  get_pucchreceivreq_info_dissector(buffer, offset)
end
return msgMod
