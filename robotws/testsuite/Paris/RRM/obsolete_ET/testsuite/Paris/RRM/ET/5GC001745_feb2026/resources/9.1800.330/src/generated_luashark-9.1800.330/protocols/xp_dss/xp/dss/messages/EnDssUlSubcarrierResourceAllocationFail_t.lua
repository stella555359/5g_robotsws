-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_EnDssFailureCause = require("xp/dss/EnDssFailureCause")
local xp_dss_messages_EnDssUlSubcarrierResourceAllocationFailExtensions = require("xp/dss/messages/EnDssUlSubcarrierResourceAllocationFailExtensions")


-- Direction: CRM Client -> CRM.
--      This message is sent by the CRM client to indicate a DSS Resource Allocation failure.
--      EN DSS DL SUBFRAME RESOURCE ALLOCATION FAILURE uses EN_DSS_DL_UNREL_TRS as Protocol ID (Table 5: Xp Protocols).
--      The CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM.
function EnDssUlSubcarrierResourceAllocationFail_t (fieldName, position)
    return
        fields.Structure({name="EnDssUlSubcarrierResourceAllocationFail_t", fieldName=fieldName, position=position, size=16}, {
            fields.uint32({name="ulAllocationSequenceNumber", position=0}),
            fields.enumeration(
                {name="enDssFailureCause", position=4, enumTerm=xp_dss_EnDssFailureCause},
                ProtoField.int32, 4, "int32"),
            xp_dss_messages_EnDssUlSubcarrierResourceAllocationFailExtensions("extensions", 8),
        })
end

return EnDssUlSubcarrierResourceAllocationFail_t
