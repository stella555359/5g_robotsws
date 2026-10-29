-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_EnDssDlQosLoadMeasurement = require("xp/dss/EnDssDlQosLoadMeasurement")
local xp_dss_messages_EnDssDlQosLoadIndExtensions = require("xp/dss/messages/EnDssDlQosLoadIndExtensions")


-- Direction: CRM Client -> CRM.
--     This message is sent by a CRM Client to deliver the measured load to the CRM.
--     EN DSS DL LOAD INDICATION uses EN_DSS_DL_UNREL_TRS as Protocol ID.
function EnDssDlQosLoadInd_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlQosLoadInd_t", fieldName=fieldName, position=position, size=52}, {
            fields.uint32({name="allocationSequenceNumber", position=0}),
            xp_dss_EnDssDlQosLoadMeasurement("dssDlQosLoadMeasurement", 4),
            xp_dss_messages_EnDssDlQosLoadIndExtensions("extensions", 44),
        })
end

return EnDssDlQosLoadInd_t
