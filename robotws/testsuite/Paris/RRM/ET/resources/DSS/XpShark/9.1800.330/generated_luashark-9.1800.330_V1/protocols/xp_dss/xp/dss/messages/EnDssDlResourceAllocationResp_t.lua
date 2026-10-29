-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssDlAllocationInfo = require("xp/dss/EnDssDlAllocationInfo"),
      xp_dss_messages_EnDssDlResourceAllocationRespExtensions = require("xp/dss/messages/EnDssDlResourceAllocationRespExtensions"),
}

-- Direction: CRM Client -> CRM
--      This message is sent by the CRM client to the CRM to indicate that the allocation of resources was successful. The client may indicate in its response e.g. a different start time than received in the corresponding request. In the procedure always the client is responding first, that needs to release resources.
--      EN DSS DL RESOURCE ALLOCATION REQUEST uses EN_DSS_DL_UNREL_TRS as Protocol ID (Table 5: Xp Protocols).
--      The CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM.
function EnDssDlResourceAllocationResp_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlResourceAllocationResp_t", fieldName=fieldName, position=position, size=24}, {
            fields.uint32({name="dlAllocationSequenceNumber", position=0}),
            localVarTable.xp_dss_EnDssDlAllocationInfo("dlMbsfnAllocationInfo", 4),
            localVarTable.xp_dss_messages_EnDssDlResourceAllocationRespExtensions("extensions", 16),
        })
end

return EnDssDlResourceAllocationResp_t
