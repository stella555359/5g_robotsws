*** Settings ***
Documentation     This is a test suite to switch off testline equipment to save energy.
...               Author: Abderrahmane NEZROUK
...               Contact: abderrahmane.nezrouk@nokia.com

Library           taf.pdu                 WITH NAME  pdu
Library           OperatingSystem
Library           BuiltIn
Library           DateTime
Library           Collections
Library           String
Library           ../python/pdu_control.py       WITH NAME  pdu_control

*** Variables ***
${PDUs_ENB}       ${False}

*** Test Cases ***
Switch On TestLine
    [Tags]
    ${pdus}=          Get Bts Pdus Infos    enb_pdus=${PDUs_ENB}
    Log To Console    ${pdus}
    Set Suite Variable    ${pdus}
    Turn PDUs Power Switch   on


*** Keywords ***
 Change PDU Power State
    [Arguments]  ${PDU_PORT}  ${on_off}  ${PDU_MODEL}  ${PDU_IP}
    # Change the PDU port power state based on the desired state
    Run Keyword If  "${on_off}" == "on"
    ...    pdu.power_on   ${PDU_PORT}  pdu_device=PDU_swich
    ...    ELSE IF   "${on_off}" == "off"
    ...    pdu.power_off   ${PDU_PORT}  pdu_device=PDU_swich

    Log  Powering ${on_off} PDU port number:${PDU_PORT} of ${PDU_MODEL} (IP:${PDU_IP})

Turn PDU Power Position
    [Arguments]   ${PDU_MODEL}  ${PDU_IP}  ${PDU_PORT}   ${on_off}
    pdu.setup_pdu        model=${PDU_MODEL}   host=${PDU_IP}          alias=PDU_swich
    ${PDU_port_status}=  pdu.get_port_status  port=${PDU_PORT}    pdu_device=PDU_swich

    # Check if the PDU port status is already as desired
    Run Keyword If  "${PDU_port_status}" == "${on_off}"
    ...    Log  PDU port number:${PDU_PORT} of ${PDU_MODEL} (IP:${PDU_IP}) is already powered ${on_off}
    ...    ELSE
    ...    Change PDU Power State  ${PDU_PORT}  ${on_off}  ${PDU_MODEL}  ${PDU_IP}

Turn PDUs Power Switch
    [Documentation]    This keyword will help to check and power on/off the gNB before running tests.
    [Arguments]   ${on_off}

    # Power on/off all DU PDUs
    FOR  ${pdu_du}  IN  @{pdus['sms_pdus']}
        Turn PDU Power Position  ${pdu_du['vendor']}  ${pdu_du['ip_addr']}  ${pdu_du['port_no']}  ${on_off}
    END

    # Power on/off all RU PDUs
    FOR  ${pdu_ru}  IN  @{pdus['rus_pdus']}
        Turn PDU Power Position  ${pdu_ru['vendor']}  ${pdu_ru['ip_addr']}  ${pdu_ru['port_no']}  ${on_off}
    END


