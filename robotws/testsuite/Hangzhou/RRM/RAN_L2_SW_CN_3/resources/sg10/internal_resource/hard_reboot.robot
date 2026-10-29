*** Settings ***
Library          taf.pdu    WITH NAME    PDU

*** Variables ***
${PDU_MODEL}                    ${tl.pdus[0].__class__.__name__}
${AP_PDU_IP}                    ${tl.ues[0].l1.common_units[0].pdu_port.pdu.addr}
${AP_PDU_PORT}                  ${tl.ues[0].l1.common_units[0].pdu_port.port_no}
${GNB_PDU_IP}                   ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${GNB_PDU_PORT}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

*** Test Cases ***
Hard Reboot
	Hard Reboot Testline


*** Keywords ***
Hard Reboot Testline
    Log To Console    Start to hard reboot testline...
    Hard Reboot Airphone
    Hard Reboot GNB

Hard Reboot Airphone
    PDU.Setup Pdu    model=${PDU_MODEL}    host=${AP_PDU_IP}    alias=pdu_alias
    PDU.Power Off    port=${AP_PDU_PORT}    pdu_device=pdu_alias
    PDU.Get Port Status    port=${AP_PDU_PORT}    pdu_device=pdu_alias
    Sleep    3s
    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias
    PDU.Get Port Status    port=${AP_PDU_PORT}    pdu_device=pdu_alias

Hard Reboot GNB
    PDU.Setup Pdu    model=${PDU_MODEL}    host=${GNB_PDU_IP}    alias=pdu_alias_2
    PDU.Power Off    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_2
    PDU.Get Port Status    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_2
    Sleep    3s
    PDU.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_2
    PDU.Get Port Status    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_2
