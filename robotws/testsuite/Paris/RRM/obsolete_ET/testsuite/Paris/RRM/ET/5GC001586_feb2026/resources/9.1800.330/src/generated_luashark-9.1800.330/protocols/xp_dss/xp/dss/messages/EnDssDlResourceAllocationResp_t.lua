-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_EnDssDlAllocationInfo = require("xp/dss/EnDssDlAllocationInfo")
local xp_dss_messages_EnDssDlResourceAllocationRespExtensions = require("xp/dss/messages/EnDssDlResourceAllocationRespExtensions")


-- Direction: CRM Client -> CRM
--      This message is sent by the CRM client to the CRM to indicate that the allocation of resources was successful. The client may indicate in its response e.g. a different start time than received in the corresponding request. In the procedure always the client is responding first, that needs to release resources.
--      EN DSS DL RESOURCE ALLOCATION REQUEST uses EN_DSS_DL_UNREL_TRS as Protocol ID (Table 5: Xp Protocols).
--      The CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM.
function EnDssDlResourceAllocationResp_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlResourceAllocationResp_t", fieldName=fieldName, position=position, size=24}, {
            fields.uint32({name="dlAllocationSequenceNumber", position=0}),
            xp_dss_EnDssDlAllocationInfo("dlMbsfnAllocationInfo", 4),
            xp_dss_messages_EnDssDlResourceAllocationRespExtensions("extensions", 16),
        })
end

return EnDssDlResourceAllocationResp_t
