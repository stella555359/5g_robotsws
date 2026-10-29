-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
