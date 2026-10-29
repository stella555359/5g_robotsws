-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_common_PLMNId_t = require("xp/common/PLMNId_t")


function GlobalgNBId_t (fieldName, position)
    return
        fields.Structure({name="GlobalgNBId_t", fieldName=fieldName, position=position, size=8}, {
            xp_common_PLMNId_t("plmnId", 0),
            fields.uint32({name="gNBId", position=4}),
        })
end

return GlobalgNBId_t
