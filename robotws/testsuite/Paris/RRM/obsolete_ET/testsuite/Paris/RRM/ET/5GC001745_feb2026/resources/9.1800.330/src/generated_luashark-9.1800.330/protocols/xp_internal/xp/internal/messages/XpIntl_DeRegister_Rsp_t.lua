-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
