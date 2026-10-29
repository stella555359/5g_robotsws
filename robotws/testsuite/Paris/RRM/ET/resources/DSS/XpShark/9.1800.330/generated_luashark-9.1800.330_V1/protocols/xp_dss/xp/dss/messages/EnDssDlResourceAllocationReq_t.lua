-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssDlAllocationInfo = require("xp/dss/EnDssDlAllocationInfo"),
      xp_dss_messages_EnDssDlResourceAllocationReqExtensions = require("xp/dss/messages/EnDssDlResourceAllocationReqExtensions"),
}

-- Direction: CRM -> CRM Client
--      This message is sent by the CRM to allocate resources/subframes to the CRM client.
--      EN DSS DL RESOURCE ALLOCATION REQUEST uses EN_DSS_DL UNREL_TRS as Protocol ID (Table 5: Xp Protocols).
--      The CRM uses its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssDlResourceAllocationReq_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlResourceAllocationReq_t", fieldName=fieldName, position=position, size=24}, {
            fields.uint32({name="dlAllocationSequenceNumber", position=0}),
            localVarTable.xp_dss_EnDssDlAllocationInfo("dlMbsfnAllocationInfo", 4),
            localVarTable.xp_dss_messages_EnDssDlResourceAllocationReqExtensions("extensions", 16),
        })
end

return EnDssDlResourceAllocationReq_t
