*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    PY310
...           CONFIGURED    SBTS00    RAN_5G    RAN_5G_TDD    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Krzysztof Brykman
...              :contact: krzysztof.brykman@nokia.com

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_delta
Library     ta5g_enb
Library     ta5g_testline_management
Library     ta5g_iphy

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Vm Ethernet Interfaces
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=CB012118_B2_4_delta.json
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_12118_B2.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=CB012118_B2_2_delta.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${UE_ID_4}=    4
${REDIRECTION_FAILURE} =    ngap && ngap.radioNetwork == 22

*** Test Cases ***
[4]CB012118_A_B2_Rejection_Of_5QI-1_Setup_And_UE_Is_Kept_In_5G
    [Documentation]    Testsuite Description:
    ...                This user scenario describes the gNB behaviour on reception of NGAP message requesting
    ...                setup of 5QI-1. This scenario assumes the case where the condition for configuring B1 measurement
    ...                and blind redirect is not satisfied.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach UE    ue_id=${UE_ID_4}
    Establish PDU Session    ue_id=${UE_ID_4}   pdu_id=1    nwslice=1    gw_id=1
    Change Default QoS Flow To 5qi5    ue_id=${UE_ID_4}
    Additional fiveQI-1 set in PDU session
    Establish PDU Session Without Confirmation    ue_id=${UE_ID_4}    pdu_id=2    nwslice=1    gw_id=2
    Verify Ngap Messages    packet_filter=${REDIRECTION_FAILURE}    continue_on_failure=${False}

    [Teardown]    Run Keywords    Deregister UE    ue_id=${UE_ID_4}
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=CB012118_B2_4_delta.json
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
