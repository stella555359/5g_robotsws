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
${GNB_PDU_IP1}    ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${GNB_PDU_PORT1}    ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.port_no}
${GNB_PDU1}    ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu}
*** Test Cases ***
Hard Reboot Testline For 2 GNB
    Log To Console    Start to power off...
    PDU.Setup Pdu    ${AP_PDU}    alias=pdu_alias_ap
    PDU.Power Off    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    PDU.Setup Pdu    ${GNB_PDU}    alias=pdu_alias_gnb
    PDU.Power Off    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    PDU.Setup Pdu    ${GNB_PDU1}    alias=pdu_alias_gnb1
    PDU.Power Off    port=${GNB_PDU_PORT1}    pdu_device=pdu_alias_gnb1
    Wait Until Keyword Succeeds    120s    5s    Check Ping NOK    10.0.1.2
    Wait Until Keyword Succeeds    120s    5s    Check Ping NOK    10.0.1.3
    Wait Until Keyword Succeeds    120s    5s    Check Ping NOK    10.0.2.80
    Log To Console    Start to power on...
    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    PDU.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    PDU.Power On    port=${GNB_PDU_PORT1}    pdu_device=pdu_alias_gnb1
    Wait Until Keyword Succeeds    120s    5s    Check Ping OK    10.0.1.2
    Wait Until Keyword Succeeds    120s    5s    Check Ping OK    10.0.1.3
    Wait Until Keyword Succeeds    120s    5s    Check Ping OK    10.0.2.80

*** Keywords ***
Check PING OK
    [Arguments]    ${ip}=192.168.255.1
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 ${ip}
    ${console_log}=    Set Variable If    "${ret}"=="0"    VM ping ${ip} OK!    VM ping ${ip} NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ping ${ip} NOK!
    [Return]    ${status}

Check Ping NOK
    [Arguments]    ${ip}=192.168.255.1
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.255.1
    ${console_log}=    Set Variable If    "${ret}"=="0"    VM ping ${ip} OK!    VM ping ${ip} NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${True}    ${False}
    Should Be True    "${ret}"=="1"    WRN:VM ping ${ip} OK!
    [Return]    ${status}