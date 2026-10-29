-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_common_PLMNId_t = require("xp/common/PLMNId_t")


function GlobaleNBId_t (fieldName, position)
    return
        fields.Structure({name="GlobaleNBId_t", fieldName=fieldName, position=position, size=8}, {
            xp_common_PLMNId_t("plmnId", 0),
            fields.uint32({name="eNBId", position=4}),
        })
end

return GlobaleNBId_t
