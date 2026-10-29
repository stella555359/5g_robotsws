-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_common_GlobaleNBId_t = require("xp/common/GlobaleNBId_t")
local xp_common_GlobaleNBDuId_t = require("xp/common/GlobaleNBDuId_t")
local xp_common_GlobalgNBId_t = require("xp/common/GlobalgNBId_t")
local xp_common_GlobalgNBDuId_t = require("xp/common/GlobalgNBDuId_t")


function NEIdentifier_t (fieldName, position)
    return
        fields.DynamicUnion({name="NEIdentifier_t", fieldName=fieldName, position=position, size=8, numDiscriminatorPaddingBytes=0},
            fields.uint32, fields.uint32,
            {
            fields.uint8({name="_UNKNOWN_", position=0}),
            fields.void({name="noIdentifier", position=0}),
            xp_common_GlobaleNBId_t("globaleNBId", 0),
            xp_common_GlobaleNBDuId_t("globaleNBDuId", 0),
            xp_common_GlobalgNBId_t("globalgNBId", 0),
            xp_common_GlobalgNBDuId_t("globalgNBDuId", 0),
            fields.uint32({name="globalCrmNeId", position=0}),
            },
            {255, 1, 2, 3, 4, 5, 6}
        )
end

return NEIdentifier_t
