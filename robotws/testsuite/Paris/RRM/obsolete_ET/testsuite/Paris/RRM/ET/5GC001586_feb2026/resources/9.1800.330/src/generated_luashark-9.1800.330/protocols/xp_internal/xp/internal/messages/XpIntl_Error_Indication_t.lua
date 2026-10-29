-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_internal_messages_EErrCode = require("xp/internal/messages/EErrCode")


function XpIntl_Error_Indication_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_Error_Indication_t", fieldName=fieldName, position=position, size=4}, {
            fields.enumeration(
                {name="errorCode", position=0, enumTerm=xp_internal_messages_EErrCode},
                ProtoField.int32, 4, "int32"),
        })
end

return XpIntl_Error_Indication_t
