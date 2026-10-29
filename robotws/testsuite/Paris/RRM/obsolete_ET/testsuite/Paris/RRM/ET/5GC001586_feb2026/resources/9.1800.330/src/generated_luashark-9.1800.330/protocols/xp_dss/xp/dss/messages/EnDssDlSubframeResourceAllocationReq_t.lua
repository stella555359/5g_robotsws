-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

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
