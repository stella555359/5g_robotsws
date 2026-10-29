-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_DlPrbAllocationInfo = require("xp/dss/DlPrbAllocationInfo")
local xp_dss_messages_EnDssDlCellResourceAreaAllocationReqExtensions = require("xp/dss/messages/EnDssDlCellResourceAreaAllocationReqExtensions")


-- Direction: CRM -> CRM Client
--      This message is sent by the CRM to allocate resources/subframes to the CRM client.
--      EN DSS DL CELL RESOURCE AREA ALLOCATION REQUEST uses EN_DSS_DL UNREL_TRS as Protocol ID (Table 5: Xp Protocols).
--      The CRM uses its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssDlCellResourceAreaAllocationReq_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlCellResourceAreaAllocationReq_t", fieldName=fieldName, position=position, size=1008}, {
            fields.uint32({name="dlAllocationSequenceNumber", position=0}),
            xp_dss_DlPrbAllocationInfo("dlPrbAllocationInfo", 4),
            xp_dss_messages_EnDssDlCellResourceAreaAllocationReqExtensions("extensions", 1000),
        })
end

return EnDssDlCellResourceAreaAllocationReq_t
