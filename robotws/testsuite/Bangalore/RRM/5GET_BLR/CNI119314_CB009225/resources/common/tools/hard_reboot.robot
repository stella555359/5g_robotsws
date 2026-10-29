*** Settings ***
Documentation
...    cmd: you need to change 2_16_UTE5GCLASSICAL1462 to your testline name.
...    robot -V /home/ute/Auto5G/config/Wroclaw/2_16_UTE5GCLASSICAL1686 -L trace hard_reboot.robot
Resource         ./../common_setup_teardown.robot
Library          taf.pdu    WITH NAME    pdu
*** Variables ***

${PDU_MODEL}    ${tl.pdus[0].__class__.__name__}
${AP_PDU_IP}    ${tl.ues[0].l1.common_units[0].pdu_port.pdu.addr}
${AP_PDU_PORT}    ${tl.ues[0].l1.common_units[0].pdu_port.port_no}
${GNB_PDU_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${GNB_PDU_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${AP_PDU}    ${tl.ues[0].l1.common_units[0].pdu_port.pdu}
${GNB_PDU}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
*** Test Cases ***
Hard Reboot Testline
    Hard Reboot Airphone
    Hard Reboot GNB
*** Keywords ***
Hard Reboot Airphone
    pdu.Setup Pdu    ${AP_PDU}    alias=pdu_alias
    pdu.Power Off    port=${AP_PDU_PORT}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${AP_PDU_PORT}    pdu_device=pdu_alias
    Sleep    3s
    pdu.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${AP_PDU_PORT}    pdu_device=pdu_alias

Hard Reboot GNB
    pdu.Setup Pdu    ${GNB_PDU}    alias=pdu_alias_2
    pdu.Power Off    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_2
    pdu.Get Port Status    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_2
    Sleep    3s
    pdu.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_2
    pdu.Get Port Status    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_2
