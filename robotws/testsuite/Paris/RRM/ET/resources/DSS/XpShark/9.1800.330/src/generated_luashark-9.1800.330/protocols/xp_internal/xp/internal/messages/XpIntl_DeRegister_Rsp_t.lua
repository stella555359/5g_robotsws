-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_internal_EResult = require("xp/internal/EResult")
local xp_common_XpAddress_t = require("xp/common/XpAddress_t")


function XpIntl_DeRegister_Rsp_t (fieldName, position)
    return
        fields.Structure({name="XpIntl_DeRegister_Rsp_t", fieldName=fieldName, position=position, size=12}, {
            fields.enumeration(
                {name="result", position=0, enumTerm=xp_internal_EResult},
                ProtoField.int32, 4, "int32"),
            fields.DynamicVariableSizedArray({name="allowedEndpoints", position=4, size=8, numSizePaddingBytes=0, numItems=255, numPaddingBytes=0},
                fields.uint32, fields.uint32, xp_common_XpAddress_t("allowedEndpoints", 4)
            ),
        })
end

return XpIntl_DeRegister_Rsp_t
