-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_DlSfAllocationInfo = require("xp/dss/DlSfAllocationInfo")
local xp_dss_messages_EnDssDlSubframeResourceAllocationReqExtensions = require("xp/dss/messages/EnDssDlSubframeResourceAllocationReqExtensions")


-- Direction: CRM -> CRM Client
--     This message is sent by the CRM to allocate resources/subframes to the CRM client.
--     Uses EN_DSS_DL_UNREL_TRS as Protocol ID.
function EnDssDlSubframeResourceAllocationReq_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlSubframeResourceAllocationReq_t", fieldName=fieldName, position=position, size=40}, {
            fields.uint32({name="dlAllocationSequenceNumber", position=0}),
            xp_dss_DlSfAllocationInfo("dlSfAllocationInfo", 4),
            xp_dss_messages_EnDssDlSubframeResourceAllocationReqExtensions("extensions", 32),
        })
end

return EnDssDlSubframeResourceAllocationReq_t
