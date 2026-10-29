-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssFailureCause = require("xp/dss/EnDssFailureCause"),
      xp_dss_messages_EnDssDlSubframeResourceAllocationFailExtensions = require("xp/dss/messages/EnDssDlSubframeResourceAllocationFailExtensions"),
}

-- Direction: CRM Client -> CRM.
--      This message is sent by the CRM client to indicate a DSS Resource Allocation failure.
--      EN DSS DL SUBFRAME RESOURCE ALLOCATION FAILURE uses EN_DSS_DL_UNREL_TRS as Protocol ID
function EnDssDlSubframeResourceAllocationFail_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlSubframeResourceAllocationFail_t", fieldName=fieldName, position=position, size=16}, {
            fields.uint32({name="dlAllocationSequenceNumber", position=0}),
            fields.enumeration(
                {name="enDssFailureCause", position=4, enumTerm=localVarTable.xp_dss_EnDssFailureCause},
                ProtoField.int32, 4, "int32"),
            localVarTable.xp_dss_messages_EnDssDlSubframeResourceAllocationFailExtensions("extensions", 8),
        })
end

return EnDssDlSubframeResourceAllocationFail_t
