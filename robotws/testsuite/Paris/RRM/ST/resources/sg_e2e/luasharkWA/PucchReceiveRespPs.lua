local UlData_PucchReceiveRespPs_t = require("UlData/PucchReceiveRespPs_t")

local message = UlData_PucchReceiveRespPs_t("PucchReceiveRespPs", 0)
require("UCI")
local msgMod = {}
local msgProto = nil

function msgMod:nameSpace()
  return 'UlData'
end

function msgMod:messageName()
  return 'PucchReceiveRespPs'
end

function msgMod:messageId()
  return 590
end

function msgMod:messageDescription()
  return 'PucchReceiveRespPs'
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
  get_pucchreceiverespps_decode_info_dissector(buffer, offset, tree)
end

return msgMod
