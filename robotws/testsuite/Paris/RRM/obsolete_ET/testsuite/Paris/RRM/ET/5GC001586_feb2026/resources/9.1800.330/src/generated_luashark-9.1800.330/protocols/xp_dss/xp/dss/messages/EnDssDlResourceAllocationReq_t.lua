-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_EnDssDlAllocationInfo = require("xp/dss/EnDssDlAllocationInfo")
local xp_dss_messages_EnDssDlResourceAllocationReqExtensions = require("xp/dss/messages/EnDssDlResourceAllocationReqExtensions")


-- Direction: CRM -> CRM Client
--      This message is sent by the CRM to allocate resources/subframes to the CRM client.
--      EN DSS DL RESOURCE ALLOCATION REQUEST uses EN_DSS_DL UNREL_TRS as Protocol ID (Table 5: Xp Protocols).
--      The CRM uses its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssDlResourceAllocationReq_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlResourceAllocationReq_t", fieldName=fieldName, position=position, size=24}, {
            fields.uint32({name="dlAllocationSequenceNumber", position=0}),
            xp_dss_EnDssDlAllocationInfo("dlMbsfnAllocationInfo", 4),
            xp_dss_messages_EnDssDlResourceAllocationReqExtensions("extensions", 16),
        })
end

return EnDssDlResourceAllocationReq_t
