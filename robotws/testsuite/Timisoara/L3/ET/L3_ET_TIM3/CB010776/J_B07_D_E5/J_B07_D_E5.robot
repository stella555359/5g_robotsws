*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Dan Moldovan
...              :contact: dan.moldovan@nokia.com

Resource    ../CB008225_Keywords.robot

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get VM Password
...            AND             Get VM IP
...            AND             Start Vm Ethernet Interfaces
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=delta_8225_no_ran_sharing.json
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_non_ran_sharing.lua  timeout=800

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             log to console    Wait until AirPhone is ready to gather logs
...               AND             Sleep    200s
...               AND             Stop Default Processes And Gather Logs And Compress Logs


Test Setup        Run Keywords    Get Vm IP and Replace       delta_scf=delta_Cell_Trace_PCMD_Configuration.json        suite_path=${CURDIR}
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=delta_Cell_Trace_PCMD_Configuration.json
...               AND             Remove Vm IP from delta     delta_scf=delta_Cell_Trace_PCMD_Configuration.json       suite_path=${CURDIR}
...               AND             Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...            AND                Prepare and start DCAP  bts_mplane=10.0.1.2

Test Teardown    Run Keywords     Run  docker stop $(docker ps -a -q)
...               AND     Cleanup EMil dir

*** Variables ***
${ResumeRequest1}        Resume Request 1


*** Test Cases ***
USCB008225_J_B07_D_E5_1_PCMD_records_from_gNB_DU_during_RRC_Inactive_to_RRC_Connected_transition_Fallback_to_RRC_Setup
    [Documentation]    This test case validates the PCMD records reported by gNB-DU during RRC_Inactive to
    ...                RRC_Connected transition (Fallback to RRC Setup).

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

    Convert 5gm Files To Csv
    Convert lcbin Files To Csv

    Ipcapture should contain Resume_Request List message    ${ResumeRequest1}

    Check msg in Control Plane logs   rrcSetupRequest::rrcSetupRequest

    Check msg in Control Plane logs  rrcSetupComplete::rrcSetupComplete
