-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
