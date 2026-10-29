-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local localVarTable = {
      xp_dss_EnDssFailureCause = require("xp/dss/EnDssFailureCause"),
      xp_dss_EnDssDlReservationInfo = require("xp/dss/EnDssDlReservationInfo"),
      xp_common_TimeToWait = require("xp/common/TimeToWait"),
      xp_dss_messages_EnDssDlCellSubframeResourceCoordinationFailExtensions = require("xp/dss/messages/EnDssDlCellSubframeResourceCoordinationFailExtensions"),
}

-- Direction: CRM -> CRM Clients
--     This message is sent by the CRM to the CRM Clients to inform about a failure when performing a cell resource coordination.
--     EN DSS DL CELL SUBFRAME RESOURCE COORDINATION FAILURE uses EN_DSS_REL_TRS as Protocol ID.
function EnDssDlCellSubframeResourceCoordinationFail_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlCellSubframeResourceCoordinationFail_t", fieldName=fieldName, position=position, size=300}, {
            fields.enumeration(
                {name="enDssFailureCause", position=0, enumTerm=localVarTable.xp_dss_EnDssFailureCause},
                ProtoField.int32, 4, "int32"),
            localVarTable.xp_dss_EnDssDlReservationInfo("enDssDlReservationInfo", 4),
            fields.StaticVariableSizedArray({name="timeToWait", position=284, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.enumeration(
                    {name="item", position=284, enumTerm=localVarTable.xp_common_TimeToWait},
                    ProtoField.int32, 4, "int32")
            ),
            localVarTable.xp_dss_messages_EnDssDlCellSubframeResourceCoordinationFailExtensions("extensions", 292),
        })
end

return EnDssDlCellSubframeResourceCoordinationFail_t
