*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36
...           CRT      SBTS00     NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristina Burtea, Andrei Maria

Resource    ../CB008225_Keywords.robot

#Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get VM Password
...            AND             Get VM IP
...            AND             Start Vm Ethernet Interfaces
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=delta_8225_no_ran_sharing.json
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_non_ran_sharing.lua  timeout=800
#...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             log to console    Wait until AirPhone is ready to gather logs
...               AND             Sleep    200s
...               AND             Stop Default Processes And Gather Logs And Compress Logs

#Test Setup        Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Setup        Run Keywords    Get Vm IP and Replace       delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration.json        suite_path=${CURDIR}
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=delta_Cell_Trace_MDT_PCMD_Configuration.json
...               AND             Remove Vm IP from delta     delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration.json        suite_path=${CURDIR}
...               AND             Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...            AND                Prepare and start DCAP  bts_mplane=10.0.1.2

#Test Teardown     Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords     Run  docker stop $(docker ps -a -q)
...               AND     Cleanup EMil dir

*** Test Cases ***
USCB008225_J_B03_D_E5_1_PCMD_CellTraceRecords_and_MDT_from_gNBCUCP_during_RRC_Inactive_to_RRC_Connected_transition_Fallback_to_RRC_Setup
    [Documentation]    This test case tests the gNB behavior for UE in RRC_CONNECTED state that is successfully
    ...                transitioned to RRC_INACTIVE state based on the UE inactivity after Initial Context Setup.
    ...                Successful suspend procedure.
    ...                5G_RAN_USR_RRM_18017, 5G_PM_960

    Set AMF To Send CNAI IE In UE Initial Context Setup Request   command=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE2}
    Set PDU Param Internal Traffic    ue_id=2
    Attach UE    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=1    gw_id=2
    Sleep  105s
    Set Parameters For UE RRC Resume Request With Action  ue_id=2  gnb_id=2  cell_nr=1  msg=resume_request_1  cause=mt_Access
    ...  action=invalid_short_mac_i
    Sleep  105s
    Start Data Traffic    ues=2    direction=dl    pdu=1    throughput=10kbps
    Sleep  105s
    Stop DCAP trace and download logs
    ${Message1}   set variable      Resume Request 1
    Ipcapture should contain Resume_Request List message    ${Message1}
