-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")
local xp_dss_EnDssFailureCause = require("xp/dss/EnDssFailureCause")
local xp_dss_EnDssDlReservationInfo = require("xp/dss/EnDssDlReservationInfo")
local xp_common_TimeToWait = require("xp/common/TimeToWait")
local xp_dss_messages_EnDssDlCellSubframeResourceCoordinationFailExtensions = require("xp/dss/messages/EnDssDlCellSubframeResourceCoordinationFailExtensions")


-- Direction: CRM -> CRM Clients
--     This message is sent by the CRM to the CRM Clients to inform about a failure when performing a cell resource coordination.
--     EN DSS DL CELL SUBFRAME RESOURCE COORDINATION FAILURE uses EN_DSS_REL_TRS as Protocol ID.
function EnDssDlCellSubframeResourceCoordinationFail_t (fieldName, position)
    return
        fields.Structure({name="EnDssDlCellSubframeResourceCoordinationFail_t", fieldName=fieldName, position=position, size=300}, {
            fields.enumeration(
                {name="enDssFailureCause", position=0, enumTerm=xp_dss_EnDssFailureCause},
                ProtoField.int32, 4, "int32"),
            xp_dss_EnDssDlReservationInfo("enDssDlReservationInfo", 4),
            fields.StaticVariableSizedArray({name="timeToWait", position=284, size=8, numSizePaddingBytes=0, numItems=1, numPaddingBytes=0},
                fields.uint32, fields.enumeration(
                    {name="item", position=284, enumTerm=xp_common_TimeToWait},
                    ProtoField.int32, 4, "int32")
            ),
            xp_dss_messages_EnDssDlCellSubframeResourceCoordinationFailExtensions("extensions", 292),
        })
end

return EnDssDlCellSubframeResourceCoordinationFail_t
