-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
