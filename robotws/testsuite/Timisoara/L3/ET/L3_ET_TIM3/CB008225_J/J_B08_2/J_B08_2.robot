*** Settings ***
Force Tags       CONFIGURED
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Andrei Maria ;Dan Moldovan
...              :contact: andrei.maria@nokia.com

Resource    ../CB008225_Keywords.robot

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get VM Password
...            AND             Get VM IP
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scfc_filename}
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg  timeout=800

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             log to console    Wait until AirPhone is ready to gather logs
...               AND             Sleep    200s
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup        Run Keywords  log to console    TestSetup
...           AND             Get Vm IP and Replace       delta_scf=${scfc_delta_filename}        suite_path=${CURDIR}
...           AND     Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=${scfc_delta_filename}
...           AND             Remove Vm IP from delta     delta_scf=${scfc_delta_filename}      suite_path=${CURDIR}
...           AND             Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...           AND             Prepare and start DCAP  bts_mplane=10.0.1.2

Test Teardown    Run Keywords     Run  docker stop $(docker ps -a -q)
...               AND     Cleanup EMil dir

*** Variables ***
${scfc_filename}          full_scf_8225.xml
${scfc_delta_filename}    delta_Cell_Trace_PCMD_DU_Configuration.json

*** Test Cases ***
USCB008225_J_B08_2_PCMD_records_from_gNB_DU_during_RRC_Inactive_to_RRC_Connected_transition_Admission_Control_fail_in_gNB_CU_CP
    [Documentation]    This user scenario validates the PCMD records reported by gNB-DU when UE moves from
    ...                RRC_Inactive to RRC_Connected state and AC fails in gNB-CU-CP.

    log to console    Start Test

    Set AMF To Send CNAI IE In UE Initial Context Setup Request   command=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE5}
    Attach UE And Establish PDU Session And Wait For Release    ue_id=5    gw_id=1
    Sleep    210s

    Set Parameters For UE RRC Resume Request plmn  ue_id=5  gnb_id=2  cell_nr=6  msg=resume_request_1  plmn=311:489   cause=mo_Data
    UE RRC Resume Request    ue_id=5

    Stop DCAP trace and download logs

    Convert 5gm Files To Csv
    Convert lcbin Files To Csv

    ### Check messeges on PC Emil
    log to console    Check messeges on PC Emil
    Check msg in Control Plane logs  InitialULRRCMessageTransfer::rrcResumeRequest1
    Check msg in Control Plane logs  UEContextReleaseCommand::rrcReject

    Check msg in Cell Trace logs  UeCtxSetupTraceRecord::ueCtxSetupRecord,result miscFailure
    Check msg in Cell Trace logs  UeCtxSetupTraceRecord::ueCtxSetupRecord,initialUeRrcMessageTransferSndTime
    Check msg in Cell Trace logs  UeCtxSetupTraceRecord::ueCtxSetupRecord,gnb-cu-ue-f1ap-Id
    Check msg in Cell Trace logs  UeCtxSetupTraceRecord::ueCtxSetupRecord,gnb-du-ue-f1ap-Id


