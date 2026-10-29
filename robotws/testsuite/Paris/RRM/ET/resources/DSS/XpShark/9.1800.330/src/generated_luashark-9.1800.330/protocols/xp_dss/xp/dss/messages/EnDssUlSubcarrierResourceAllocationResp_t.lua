-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_UlScAllocationInfo = require("xp/dss/UlScAllocationInfo")
local xp_dss_messages_EnDssUlSubcarrierResourceAllocationRespExtensions = require("xp/dss/messages/EnDssUlSubcarrierResourceAllocationRespExtensions")


-- Direction: CRM Client -> CRM
--      This message is sent by the CRM client to the CRM to indicate that the allocation of resources was successful. The client may indicate in its response e.g. a different start time than received in the corresponding request. In the procedure always the client is responding first, that needs to release resources.
--      EN DSS DL SUBFRAME RESOURCE ALLOCATION REQUEST uses EN_DSS_DL_UNREL_TRS as Protocol ID (Table 5: Xp Protocols).
--      The CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM.
function EnDssUlSubcarrierResourceAllocationResp_t (fieldName, position)
    return
        fields.Structure({name="EnDssUlSubcarrierResourceAllocationResp_t", fieldName=fieldName, position=position, size=76}, {
            fields.uint32({name="ulAllocationSequenceNumber", position=0}),
            xp_dss_UlScAllocationInfo("ulScAllocationInfo", 4),
            xp_dss_messages_EnDssUlSubcarrierResourceAllocationRespExtensions("extensions", 68),
        })
end

return EnDssUlSubcarrierResourceAllocationResp_t
