-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_common_NEIdentifier_t = require("xp/common/NEIdentifier_t")
local xp_internal_EResult = require("xp/internal/EResult")


function XpIntl_ConnStatus_Unsubscribe_Rsp_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_ConnStatus_Unsubscribe_Rsp_t", fieldName=fieldName, position=position, size=12}, {
            xp_common_NEIdentifier_t("neid", 0),
            fields.enumeration(
                {name="result", position=8, enumTerm=xp_internal_EResult},
                ProtoField.int32, 4, "int32"),
        })
end

return XpIntl_ConnStatus_Unsubscribe_Rsp_t
