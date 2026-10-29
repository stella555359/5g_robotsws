*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    PY36    CONFIGURED    RAN_5G_TDD    RAN_5G_TDD    RAN_5G    CRT    SBTS00    SBTS23R1
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Kamila Białczyk
...              :contact: kamila.bialczyk@nokia.com

Library      ta5g_cell_operations
Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     5GC000638_R_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Reach Onair    lua_cfg=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${ERROR_INDICATION_ON_RAN_CONFIGURATION_UPDATE}=    ${NGAP_ERROR_INDICATION} && ngap.procedureCode == 35
${NG_AMF_INIT_ERROR_IND}=    7323
${BASE_STATION_INFORMATION}=    7115

*** Test Cases ***
5GC000638-R_TC2_Error_Indication_initiated_by_AMF_on_incoming_RAN_Configuration_Update
    [Documentation]    This test case verifies gNB behavior, when Error Indication is initiated by AMF on incoming RAN Configuration Update
    ...                5G_RAN_USR_RRM_1283
    ...                Testcase checks:
    ...                - if fault 7323 (EFaultId_NgamfInitErrorIndAl) is raised
    ...                - if counter NG_CU_ERROR_IND_RCV is incremented properly

    Invoke Error Indication On RAN Configuration Update
    Lock Single Cell    cell_id=1
    Lock Single Cell    cell_id=2
    Lock Single Cell    cell_id=3
    Lock Single Cell    cell_id=4
    Unlock Single Cell    cell_id=1    timeout=50
    Verify Ngap Messages    packet_filter=${NGAP_RAN_CONFIGURATION_UPDATE}
    Verify Ngap Messages    packet_filter=${ERROR_INDICATION_ON_RAN_CONFIGURATION_UPDATE}
    Wait For Fault To Be Up    fault_id=7323
    Wait For Alarm To Be Up    alarm_id=7115
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55119C00022     +1    NG_CU_ERROR_IND_RCV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

    [Teardown]    Run Keywords    Unlock Single Cell    cell_id=2    timeout=50
    ...           AND             Unlock Single Cell    cell_id=3    timeout=50
    ...           AND             Unlock Single Cell    cell_id=4    timeout=50
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000638-R_TC3_Error_Indication_initiated_by_AMF_on_incoming_AMF_Configuration_Update_Acknowledge
    [Documentation]    Check gnb behaviour for Error Indication initiated by AMF on incoming AMF Configuration Update Acknowledge
    ...                5G_RAN_USR_RRM_3914
    ...                Testcase checks:
    ...                - if fault 7323 (EFaultId_NgamfInitErrorIndAl) is raised
    ...                - if counter NG_CU_ERROR_IND_RCV is incremented properly

    Invoke Error Indication on AMF Configuration Update Acknowledge
    Wait For Fault To Be Up    fault_id=${NG_AMF_INIT_ERROR_IND}
    Wait For Alarm To Be Up    alarm_id=${BASE_STATION_INFORMATION}
    Verify Ngap Messages    packet_filter=${NGAP_AMF_CONFIGURATION_UPDATE}
    Verify Ngap Messages    packet_filter=${NGAP_AMF_CONFIGURATION_UPDATE_ACKNOWLEDGE}
    Verify Ngap Messages    packet_filter=${NGAP_ERROR_INDICATION}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55119C00022     +1    NG_CU_ERROR_IND_RCV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

    [Teardown]    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
