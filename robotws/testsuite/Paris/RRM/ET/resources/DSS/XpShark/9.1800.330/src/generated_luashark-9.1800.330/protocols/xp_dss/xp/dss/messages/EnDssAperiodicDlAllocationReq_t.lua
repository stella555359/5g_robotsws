-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

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
