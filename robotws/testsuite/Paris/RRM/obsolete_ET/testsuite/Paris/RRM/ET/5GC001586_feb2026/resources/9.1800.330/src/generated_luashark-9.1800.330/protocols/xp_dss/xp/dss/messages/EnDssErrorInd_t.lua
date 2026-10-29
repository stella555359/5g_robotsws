-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846

local fields = require("message")
local xp_dss_EnDssFailureCause = require("xp/dss/EnDssFailureCause")
local xp_dss_messages_EnDssErrorIndExtensions = require("xp/dss/messages/EnDssErrorIndExtensions")


-- Direction: DSS Client -> CRM; CRM -> CRM Client
--      This message is sent from one DSS peer to another DSS peer to inform about an error situation on the sending peer. The cause given in the error indication is used for information. Sending an error indication may be useful for protocol capturing and analysis, even if a receiving peer may ignore the message.
--      DSS ERROR INDICATION uses EN_DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols) for error indication messages, except for error indications in the context of EN DSS Keep Alive, EN DSS DL Resource Allocation and EN DSS DL Load Indication where the EN_DSS_DL_UNREL_TRS as Protocol ID shall be used. For the header IE definition see (11.1).
--      CRM Clients shall transfer their eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM. The CRM shall use its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
function EnDssErrorInd_t (fieldName, position)
    return
        fields.Structure({name="EnDssErrorInd_t", fieldName=fieldName, position=position, size=12}, {
            fields.enumeration(
                {name="enDssErrorCause", position=0, enumTerm=xp_dss_EnDssFailureCause},
                ProtoField.int32, 4, "int32"),
            xp_dss_messages_EnDssErrorIndExtensions("extensions", 4),
        })
end

return EnDssErrorInd_t
