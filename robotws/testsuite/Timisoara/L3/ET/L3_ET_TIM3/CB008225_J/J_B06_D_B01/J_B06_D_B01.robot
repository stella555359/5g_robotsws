*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36
...           CRT      SBTS00     NoResUsage

Documentation    :copyright: Nokia
...              :authors: Andrei Maria
...              :contact: andrei.maria@nokia.com

Resource    ../CB008225_Keywords.robot

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get VM Password
...            AND             Get VM IP
...            AND             Start Vm Ethernet Interfaces
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=delta_8225_no_ran_sharing.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_non_ran_sharing.lua    timeout=800

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             log to console    Wait until AirPhone is ready to gather logs
...               AND             Sleep    200s
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup        Run Keywords    Get Vm IP and Replace       delta_scf=delta_8225_Subscriber_Trace.json        suite_path=${CURDIR}
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=delta_8225_Subscriber_Trace.json
...               AND             Remove Vm IP from delta     delta_scf=delta_8225_Subscriber_Trace.json      suite_path=${CURDIR}
...               AND             Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...            AND                Prepare and start DCAP  bts_mplane=10.0.1.2

Test Teardown    Run Keywords     Run  docker stop $(docker ps -a -q)
...               AND     Cleanup EMil dir

*** Test Cases ***
USCB008225_J_B06_D_B01_1_Subscriber_and_Equipment_trace_during_RRC_Inactive_to_RRC_Connected_transition
    [Documentation]    This test case validates the subscriber and equipment trace
    ...                when UE moves from RRC_Inactive to RRC_Connected state.

    Set AMF To Send CNAI IE In UE Initial Context Setup Request
    Attach Ue And Start Subscriber Trace And Establish PDU Session And Wait For Inactive    ue_id=1    gw_id=1
    Set Parameters For UE RRC Resume Request    ue_id=1    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_Signalling
    Sleep  10s
    UE RRC Resume Request via UL NAS PDU    ue_id=1
    Sleep  100s

    Stop DCAP trace and download logs
    Convert 5gm Files To Csv
    Convert lcbin Files To Csv

    Check msg in Control Plane logs  InitialContextSetupRequest::CoreNetworkAssistanceInformationForInactive
    Check msg in Control Plane logs  UEContextReleaseComplete::UEContextReleaseComplete
    Check msg in Control Plane logs  BearerContextModificationRequest::BearerContextStatusChange : suspend
    Check msg in Control Plane logs  BearerContextModificationResponse::System-BearerContextModificationResponse
    Check msg in Control Plane logs  UEContextReleaseCommand::radioNetwork : normal-release
    Check msg in Control Plane logs  rrcRelease::suspendConfig

    Check msg in Control Plane logs  TraceStart::TraceActivation
    Check msg in Control Plane logs  InitialULRRCMessageTransfer::rrcResumeRequest1
    Check msg in Control Plane logs  rrcResume::radioBearerConfig

    Check msg in Cell Trace logs  TraceStart::TraceActivation
    ${Message1}   set variable      Resume Request 1
    Ipcapture should contain Resume_Request List message    ${Message1}
    Check msg in Cell Trace logs  RRCResume::rrcResume
    Check msg in Cell Trace logs  RRCResumeComplete::rrcResumeComplete
