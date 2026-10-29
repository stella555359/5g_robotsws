-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
