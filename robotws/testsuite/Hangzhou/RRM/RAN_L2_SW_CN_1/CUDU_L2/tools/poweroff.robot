*** Settings ***
Documentation
...    robot -V /home/ute/Auto5G/config/Wroclaw/2_16_UTE5GCLASSICAL1686 -L trace hard_reboot.robot
Resource         ./../common_setup_teardown.robot
*** Variables ***
${AP_PDU_IP}    ${tl.ues[0].l1.common_units[0].pdu_port.pdu.addr}
${AP_PDU_PORT}    ${tl.ues[0].l1.common_units[0].pdu_port.port_no}
${GNB_PDU_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${GNB_PDU_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${AP_PDU}    ${tl.ues[0].l1.common_units[0].pdu_port.pdu}
${GNB_PDU}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
${device}    both    #gnb/ap
*** Test Cases ***
Test For PowerOff Testline
    run keyword if    "${device}"=="gnb"    Power Off GNB
    run keyword if    "${device}"=="ap"    Power Off AP
    run keyword if    "${device}"=="both"    Run Keywords    Power Off GNB    AND    Power Off AP

*** Keywords ***
