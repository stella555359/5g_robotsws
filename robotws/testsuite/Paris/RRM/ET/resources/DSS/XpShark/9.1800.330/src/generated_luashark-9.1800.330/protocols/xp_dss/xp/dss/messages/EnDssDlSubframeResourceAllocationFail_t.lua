-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_EnDssFailureCause = require("xp/dss/EnDssFailureCause")
local xp_dss_messages_EnDssDlSubframeResourceAllocationFailExtensions = require("xp/dss/messages/EnDssDlSubframeResourceAllocationFailExtensions")


-- Direction: CRM Client -> CRM.
--      This message is sent by the CRM client to indicate a DSS Resource Allocation failure.
--      EN DSS DL SUBFRAME RESOURCE ALLOCATION FAILURE uses EN_DSS_DL_UNREL_TRS as Protocol ID
function EnDssDlSubframeResourceAllocationFail_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlSubframeResourceAllocationFail_t", fieldName=fieldName, position=position, size=16}, {
            fields.uint32({name="dlAllocationSequenceNumber", position=0}),
            fields.enumeration(
                {name="enDssFailureCause", position=4, enumTerm=xp_dss_EnDssFailureCause},
                ProtoField.int32, 4, "int32"),
            xp_dss_messages_EnDssDlSubframeResourceAllocationFailExtensions("extensions", 8),
        })
end

return EnDssDlSubframeResourceAllocationFail_t
