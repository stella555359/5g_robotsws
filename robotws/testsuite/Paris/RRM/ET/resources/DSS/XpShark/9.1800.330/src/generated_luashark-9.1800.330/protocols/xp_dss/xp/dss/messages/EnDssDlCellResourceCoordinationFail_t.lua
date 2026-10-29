-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_EnDssFailureCause = require("xp/dss/EnDssFailureCause")
local xp_common_TimeToWait = require("xp/common/TimeToWait")
local xp_dss_messages_EnDssDlCellResourceCoordinationFailExtensions = require("xp/dss/messages/EnDssDlCellResourceCoordinationFailExtensions")


-- This message is sent by the CRM to the CRM Clients to inform about a failure when performing a cell resource coordination.
--      EN DSS DL CELL RESOURCE COORDINATION FAILURE uses EN_DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The CRM shall reply with its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssDlCellResourceCoordinationFail_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlCellResourceCoordinationFail_t", fieldName=fieldName, position=position, size=20}, {
            fields.enumeration(
                {name="enDssFailureCause", position=0, enumTerm=xp_dss_EnDssFailureCause},
                ProtoField.int32, 4, "int32"),
            fields.StaticVariableSizedArray({name="timeToWait", position=4, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.enumeration(
                    {name="item", position=4, enumTerm=xp_common_TimeToWait},
                    ProtoField.int32, 4, "int32")
            ),
            xp_dss_messages_EnDssDlCellResourceCoordinationFailExtensions("extensions", 12),
        })
end

return EnDssDlCellResourceCoordinationFail_t
