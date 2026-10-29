-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_Time = require("xp/dss/Time")
local xp_dss_messages_KeepAliveExtensions = require("xp/dss/messages/KeepAliveExtensions")


-- Request:
--      Direction: CRM Client -> CRM
--      This message is sent to the CRM to monitor the EN DSS application link.
--      EN DSS KEEP ALIVE REQUEST uses EN_DSS_DL_UNREL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The initiating CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM.
-- 
--      Response:
--      Direction: CRM -> CRM Client
--      This response is sent to the CRM client to tell that the DSS link is alive.
--      EN DSS KEEP ALIVE RESPONSE uses EN_DSS_DL_UNREL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The CRM shall reply with its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssKeepAlive_t (fieldName, position)
    return
        fields.Structure({name="EnDssKeepAlive_t", fieldName=fieldName, position=position, size=32}, {
            fields.uint32({name="enDssKeepAliveSequenceNumber", position=0}),
            fields.StaticVariableSizedArray({name="enDssKeepAliveRequestTime", position=4, size=20, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, xp_dss_Time("enDssKeepAliveRequestTime", 4)
            ),
            xp_dss_messages_KeepAliveExtensions("extensions", 24),
        })
end

return EnDssKeepAlive_t
