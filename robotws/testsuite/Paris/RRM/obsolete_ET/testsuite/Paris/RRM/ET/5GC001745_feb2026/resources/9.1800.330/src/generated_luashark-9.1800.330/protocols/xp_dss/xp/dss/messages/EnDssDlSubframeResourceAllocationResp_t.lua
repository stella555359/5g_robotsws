-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
