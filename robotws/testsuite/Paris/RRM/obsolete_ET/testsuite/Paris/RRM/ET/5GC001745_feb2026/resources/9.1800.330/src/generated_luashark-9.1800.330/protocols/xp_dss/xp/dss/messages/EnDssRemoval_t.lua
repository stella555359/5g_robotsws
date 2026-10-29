-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b

local fields = require("message")


-- Request:
--      Direction: CRM client -> CRM
--      This message is sent by an initiating CRM client to indicate that the CRM client would like to finish the DSS of a particular cell.
--      The EN DSS REMOVAL REQUEST message uses EN_DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The initiating CRM Client shall transfer its eNB ID + eNB Cell ID, gNB ID + gNB Cell ID or gNB ID + DU ID + gNB Cell ID to the CRM.
-- 
--      Response:
--      Direction: CRM -> CRM Client
--      This message is sent by the CRM to the initiating CRM Client to inform that it is safe to remove the DSS association and to bring the cell into a defined state (muted for NR and in full use for LTE).
--      The EN DSS CELL REMOVAL RESPONSE message uses EN_DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The CRM shall reply with its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID.
-- 
--      Info:
--      Direction: CRM -> CRM Client
--      This message is sent by the CRM to the indicate to a client that it has received an EN DSS REMOVAL REQUEST from an initiating client. It allows the client to remove the DSS association and to bring the cell
--      into a defined state (muted for NR and in full use for LTE). It allows further to issue an alarm/warning to the OAM that DSS has been removed from the peer cell on the other side.
--      The EN DSS REMOVAL INFO message uses EN_DSS_REL_TRS as Protocol ID (Table 5: Xp Protocols). For the header IE definition see (11.1).
--      The CRM shall use its eNB ID + CRM ID comprising the eNB Cell ID or with its gNB ID + CRM ID comprising the gNB Cell ID or the gNB ID + DU ID + CRM ID comprising the gNB Cell ID
function EnDssRemoval_t (fieldName, position)
    return
        fields.Structure({name="EnDssRemoval_t", fieldName=fieldName, position=position, size=4}, {
            fields.uint32({name="dummy", position=0}),
        })
end

return EnDssRemoval_t
