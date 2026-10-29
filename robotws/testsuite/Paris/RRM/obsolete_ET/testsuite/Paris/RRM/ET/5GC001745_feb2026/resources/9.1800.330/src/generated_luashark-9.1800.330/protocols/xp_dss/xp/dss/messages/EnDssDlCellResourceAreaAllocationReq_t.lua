-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

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
