*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO   VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1

Documentation    :copyright: Nokia
...              :author: Kamila Gniewek
...              :contact: kamila.gniewek@nokia.com

Library      ../../resources/Python/webem_alarms.py
Library      ta5g_enb
Library      ta5g_admin_operations

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/5G_SW_WRO_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging and Reach OnAir    lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_sansa.lua
    ...                        output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...        AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_barring_and_sctp_wait_time.json
    ...        AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Print Active Alarms
    ...           AND    Stop Default Processes And Gather Logs And Compress Logs
    ...           AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_barring_and_sctp_wait_time_default.json

Test Setup       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
${NGSCTPENDPOINTBROKENAL_FAULT}    7304
${BARRING_TIMER}    waitForRecovBeforeCellBarringTimer
${F1AP_CELL_BARRED}    f1ap.cellBarred

*** Test Cases ***
5GC000742_D_Un_Bar_SA_cell_when_NG_interfaces_is_avaliable_ET
    [Documentation]   System behaviour when NG interface fails (SCTP association fails) and then recovered this failure.
    ...               5GC000742_D_Bar_SA_cell_when_NG_interfaces_is_unavaliable_ET is included in this test.
    ${WaitingTimeBeforeCellBarringTimer}=  Get Admin Object Parameter Value    parameter_name=${BARRING_TIMER}
    Execute Egate Command And Wait For Data    cmd=drop_link link=ng by=amf:1 to=gnb:2    pass_regexp=NG Link Drop By Command
    Wait For Fault To Be Up    fault_id=${NGSCTPENDPOINTBROKENAL_FAULT}    timeout=300
    Sleep    ${WaitingTimeBeforeCellBarringTimer}
    Wait For Fault To Be Down    fault_id=${NGSCTPENDPOINTBROKENAL_FAULT}    timeout=300
    Verify Tcpdump Log    packet_filter= ${F1AP_CELL_BARRED} == 1    relation_symbol= >=
    Sleep    ${WaitingTimeBeforeCellBarringTimer}
    Verify Tcpdump Log    packet_filter=${F1AP_CELL_BARRED} == 0



