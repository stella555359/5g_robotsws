-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
