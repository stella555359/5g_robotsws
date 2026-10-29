-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_UlScAllocationInfo = require("xp/dss/UlScAllocationInfo")
local xp_dss_messages_EnDssUlSubcarrierResourceAllocationReqExtensions = require("xp/dss/messages/EnDssUlSubcarrierResourceAllocationReqExtensions")


-- Direction: CRM -> CRM Client
--      This message is sent by the CRM to allocate resources/subframes to the CRM client.
--      EN DSS DL SUBFRAME RESOURCE ALLOCATION REQUEST uses EN_DSS_DL UNREL_TRS as Protocol ID (Table 5: Xp Protocols).
--      The CRM uses its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssUlSubcarrierResourceAllocationReq_t (fieldName, position)
    return
        fields.Structure({name="EnDssUlSubcarrierResourceAllocationReq_t", fieldName=fieldName, position=position, size=76}, {
            fields.uint32({name="ulAllocationSequenceNumber", position=0}),
            xp_dss_UlScAllocationInfo("ulScAllocationInfo", 4),
            xp_dss_messages_EnDssUlSubcarrierResourceAllocationReqExtensions("extensions", 68),
        })
end

return EnDssUlSubcarrierResourceAllocationReq_t
