*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    PY310
...           CONFIGURED    SBTS00    RAN_5G    RAN_5G_TDD    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Anna Gibala-Wojtal, Krzysztof Brykman, Malgorzata Grajzer-Szmajda, Bartosz Wlodowski,
...                        Piotr Bartkowski
...              :contact: anna.gibala-wojtal@nokia.com, krzysztof.brykman@nokia.com, bartosz.wlodowski@nokia.com
...                        malgorzata.grajzer-szmajda@nokia.com, piotr.bartkowski@nokia.com

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_delta
Library     ta5g_enb
Library     ta5g_testline_management

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Vm Ethernet Interfaces
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=CB012118_B2_2_delta.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_12118_B2.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=CB012118_B2_2_delta.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${UE_ID_1}=    1
${UE_ID_2}=    2
${UE_ID_3}=    3
${UE_ID_4}=    4
${REDIRECTION_FAILURE} =    ngap && ngap.radioNetwork == 22
${INITIAL_CONTEXT_SETUP_FAILURE} =    ngap.InitialContextSetupFailure_element && ngap.radioNetwork == 22

*** Test Cases ***
[1]CB012118_A_B2_Rejection_Of_5QI-1_Setup_And_UE_Is_Kept_In_5G
    [Documentation]    Test purpose:
    ...                This user scenario describes the gNB behaviour on reception of NGAP message requesting
    ...                setup of 5QI-1. This scenario assumes the condition for configuring B1 measurement and
    ...                blind redirect is not satisfied. In the scenario, there is one PDU session with default fiveQI-6
    ...                and second PDU session with fiveQI-5, then QoF with fiveQI-1 is added to second PDU session.
    ...                After Radio Acces failure redirection is failed as UE does not support band in its capabilities.
    ...                Test case covers requirement: 5G_RAN_USR_RRM_23070

    [Setup]    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach UE    ue_id=${UE_ID_1}
    Establish PDU Session With Traffic    ue_id=${UE_ID_1}    pdu_id=1    gw_id=1    throughput='10mbps'
    Change Default QoS Flow To 5qi5    ue_id=${UE_ID_1}
    Set Traffic Type To Internal For PDU    pdu_id=2
    Additional fiveQI-1 set in PDU session
    Establish PDU Session Without Confirmation    ue_id=${UE_ID_1}    pdu_id=2    nwslice=1    gw_id=2
    Verify Ngap Messages    packet_filter=${REDIRECTION_FAILURE}

    [Teardown]    Run Keywords    Reset Smf Parameters
    ...           AND             Deregister UE    ue_id=${UE_ID_1}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


[2]CB012118_A_B2_Rejection_Of_5QI-1_Setup_And_UE_Is_Kept_In_5G
    [Documentation]    Testsuite Description:
    ...                This user scenario describes the gNB behaviour on reception of NGAP message requesting
    ...                modification of 5QI-1. This scenario assumes the condition for configuring B1 measurement and
    ...                blind redirect is not satisfied. In the scenario, there is one PDU session with default fiveQI-6
    ...                and second PDU session with fiveQI-5, then the first PDU session is modified with QFI mapped to
    ...                fiveQI-1. Modification results with failure as UE does not support band in its capabilities.

    [Setup]    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach UE    ue_id=${UE_ID_2}
    Establish PDU Session    ue_id=${UE_ID_2}    pdu_id=1    nwslice=1    gw_id=1
    Change Default QoS Flow To 5qi5    ue_id=${UE_ID_2}
    Establish PDU Session    ue_id=${UE_ID_2}    pdu_id=2    nwslice=1    gw_id=2
    Modify PDU Session    ue_id=${UE_ID_2}    pdu_id=2    qos_to_add=3
    Verify Ngap Messages    packet_filter=${REDIRECTION_FAILURE}    continue_on_failure=${False}

    [Teardown]    Run Keywords    Reset Smf Parameters
    ...           AND             Deregister UE    ue_id=${UE_ID_2}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

[3]CB012118_A_B2_Rejection_Of_5QI-1_Setup_And_UE_Is_Kept_In_5G
    [Documentation]    This test case provides a measurement based redirection to LTE, when VoNR is not supported by the
    ...                UE. It checks gNB behaviour during fallback procedure to LTE when voice call (5QI 1 + 5QI 5)
    ...                is initiated via Initial Context Setup Request.
    ...                Test case requires following flags to be added to default config:
    ...                - actVoNR set to True
    ...                - actRedirect set to True
    ...                - actVoFallBackLteB1MeaBaRedir set to True
    ...                - actNonVoNRGbrService set to True
    ...                - redirFreqEutra set to LTE cell frequency (not supported by UE)
    ...                - redirPrio set to 1
    ...                - reditRat set to eutra
    ...                During test execution Initial Context Setup Request is triggered with 5QI 1 + 5QI 5. gNB rejects
    ...                the incoming 5QI-1 setup message from AMF, becasue configured redirection targets are not
    ...                supported by UE based on the UE-Capabilities.

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Change Default QoS Flow To 5qi5    ue_id=${UE_ID_3}
    ...        AND             Additional fiveQI-1 set in PDU session

    Attach UE    ue_id=${UE_ID_3}
    Establish PDU Session Without Confirmation    ue_id=${UE_ID_3}    pdu_id=1    nwslice=1    gw_id=1
    Verify Ngap Messages    packet_filter=${INITIAL_CONTEXT_SETUP_FAILURE}    continue_on_failure=${False}

    [Teardown]    Run Keywords    Deregister UE    ue_id=${UE_ID_3}
    ...           AND             Reset Smf Parameters
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Additional fiveQI-1 set in PDU session
    Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=3

Change Default QoS Flow To 5qi5
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=qosflow_modify default=on qos_flow=2 ue=${ue_id}

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:eNB1_X2    ip_with_mask=10.0.1.138/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:eNB1_X2    ip_with_mask=10.0.1.138/24

Reset Smf Parameters
    Execute Egate Command    cmd=smf_param id=1 reset

Set Traffic Type To Internal For PDU
    [Arguments]     ${pdu_id}
    Execute Egate Command    cmd=set_pdu_param pdu=${pdu_id} ue=${UE_ID_1} trf_type=internal
