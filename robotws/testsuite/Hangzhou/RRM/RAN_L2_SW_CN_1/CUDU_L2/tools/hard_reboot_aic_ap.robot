*** Settings ***
Documentation
...    robot -V /home/ute/Auto5G/config/Wroclaw/2_16_UTE5GCLASSICAL1686 -L trace hard_reboot.robot
Resource         ./../common_setup_teardown.robot
*** Variables ***

*** Test Cases ***
Test For Hard Reboot Testline
    Import AIC Testline Variables
    Log To Console    Start to power off AP...
    Power Off AP
    Wait Until Keyword Succeeds    30s    5s    Check AP Ping NOK
    Log To Console    Start to power on AP...
    PDU.Setup Pdu    ${AP_PDU}    alias=pdu_alias_ap
    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    Wait Until Keyword Succeeds    100s    5s    Check AP Ping OK


*** Keywords ***
Import AIC Testline Variables
    ${ret}    ${host_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${testline_config_path}=    Set Variable    /home/ute/testline_configuration/${host_name}/
    ${ret}=    Run Keyword And Return Status    File Should Exist    ${testline_config_path}/__init__.py
    ${testline_config_path}=    Set Variable If    "${ret}"=="${True}"    ${testline_config_path}
    ...    /home/ute/testline_init_results/configs/${host_name}/
    Log    Testline init file is ${testline_config_path}      console=${True}
    Import Variables    ${testline_config_path}
    Set Suite Variable    ${AP_PDU_IP}    ${tl.ues[0].l1.common_units[0].pdu_port.pdu.addr}
    Set Suite Variable    ${AP_PDU_PORT}    ${tl.ues[0].l1.common_units[0].pdu_port.port_no}
    Set Suite Variable    ${AP_PDU}    ${tl.ues[0].l1.common_units[0].pdu_port.pdu}
    Set Suite Variable    ${TLPC_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
    Set Suite Variable    ${TLPC_SSH_UE}    ${tl.test_pc.default_ssh_connection_details.username}
    Set Suite Variable    ${TLPC_SSH_PWD}    ${tl.test_pc.default_ssh_connection_details.password}


