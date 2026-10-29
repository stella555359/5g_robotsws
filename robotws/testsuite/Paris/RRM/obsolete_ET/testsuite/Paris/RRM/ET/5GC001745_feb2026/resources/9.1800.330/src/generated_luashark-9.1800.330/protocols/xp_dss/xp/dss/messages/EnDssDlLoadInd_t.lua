-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_EnDssDlLoadMeasurements = require("xp/dss/EnDssDlLoadMeasurements")
local xp_dss_messages_EnDssDlLoadIndExtensions = require("xp/dss/messages/EnDssDlLoadIndExtensions")


-- Direction: CRM Client -> CRM.
--      This message is sent by a CRM Client to deliver the measured load to the CRM.
--      EN DSS DL LOAD INDICATION uses EN_DSS_DL_UNREL_TRS as Protocol ID (Table 5: Xp Protocols).
--      The CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM.
function EnDssDlLoadInd_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlLoadInd_t", fieldName=fieldName, position=position, size=16}, {
            fields.uint32({name="allocationSequenceNumber", position=0}),
            xp_dss_EnDssDlLoadMeasurements("enDssDlLoadMeasurement", 4),
            xp_dss_messages_EnDssDlLoadIndExtensions("extensions", 8),
        })
end

return EnDssDlLoadInd_t
