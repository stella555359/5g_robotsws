-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_DlSfAllocationInfo = require("xp/dss/DlSfAllocationInfo")
local xp_dss_messages_EnDssDlSubframeResourceAllocationRespExtensions = require("xp/dss/messages/EnDssDlSubframeResourceAllocationRespExtensions")


-- Direction: CRM Client -> CRM
--     This message is sent by the CRM client to the CRM to indicate that the allocation of resources was successful.
--     The client may indicate in its response e.g. a different start time than received in the corresponding request.
--     Uses EN_DSS_DL_UNREL_TRS as Protocol ID.
function EnDssDlSubframeResourceAllocationResp_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlSubframeResourceAllocationResp_t", fieldName=fieldName, position=position, size=40}, {
            fields.uint32({name="dlAllocationSequenceNumber", position=0}),
            xp_dss_DlSfAllocationInfo("dlSfAllocationInfo", 4),
            xp_dss_messages_EnDssDlSubframeResourceAllocationRespExtensions("extensions", 32),
        })
end

return EnDssDlSubframeResourceAllocationResp_t
