-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_AperiodicDlAllocationReqInfo = require("xp/dss/AperiodicDlAllocationReqInfo")
local xp_dss_messages_EnDssAperiodicDlAllocationReqExtensions = require("xp/dss/messages/EnDssAperiodicDlAllocationReqExtensions")


-- Direction: CRM Client -> CRM.
--     This message is sent by a CRM Client to trigger an immediate allocation procedure to guarantee a resource share based on priority and not usual measured loads.
function EnDssAperiodicDlAllocationReq_t (fieldName, position)
    return
        fields.Structure({name="EnDssAperiodicDlAllocationReq_t", fieldName=fieldName, position=position, size=24}, {
            xp_dss_AperiodicDlAllocationReqInfo("aperiodicDlAllocationReqInfo", 0),
            xp_dss_messages_EnDssAperiodicDlAllocationReqExtensions("extensions", 16),
        })
end

return EnDssAperiodicDlAllocationReq_t
