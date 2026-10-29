-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6

local fields = require("message")
local xp_dss_MessageSetList = require("xp/dss/MessageSetList")
local xp_dss_messages_EnDssSetupReqExtensions = require("xp/dss/messages/EnDssSetupReqExtensions")


-- Direction: CRM Client -> CRM
--      This message is sent by an initiating CRM Client to a CRM to transfer the needed information to establish the EN DSS connection.
--      EN DSS SETUP REQUEST uses EN DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The initiating CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM.
--      The initiating CRM Client will send all EN DSS message sets it is supporting and are allowed to be used to the CRM. An EN DSS message is identified by its explicit discriminator value (10.4). A message set is a string identifying the explicit message discriminators. The newest EN DSS message set is at the highest position of the list (see 12.1).
function EnDssSetupReq_t (fieldName, position)
    return
        fields.Structure({name="EnDssSetupReq_t", fieldName=fieldName, position=position, size=16}, {
            xp_dss_MessageSetList("supportedEnDssMessageSets", 0),
            xp_dss_messages_EnDssSetupReqExtensions("extensions", 8),
        })
end

return EnDssSetupReq_t
