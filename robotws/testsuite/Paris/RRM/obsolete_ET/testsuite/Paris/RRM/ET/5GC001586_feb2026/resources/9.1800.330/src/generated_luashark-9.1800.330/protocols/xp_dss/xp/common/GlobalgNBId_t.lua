-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
