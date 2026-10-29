*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36
...           CRT      SBTS00     NoResUsage

Documentation    :copyright: Nokia
...              :authors: Andrei Maria, Cristina Burtea, Dan Moldovan

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

Test Setup        Run Keywords    Get Vm IP and Replace       delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration.json        suite_path=${CURDIR}
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=delta_Cell_Trace_MDT_PCMD_Configuration.json
...               AND             Remove Vm IP from delta     delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration.json        suite_path=${CURDIR}
...               AND             Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...            AND                Prepare and start DCAP  bts_mplane=10.0.1.2

Test Teardown    Run Keywords     Run  docker stop $(docker ps -a -q)
...               AND     Cleanup EMil dir

*** Test Cases ***
USCB008225_J_B01_B_B1_1_gNB_CU_UeDuConnectivity_Record_from_gNB_CU_CP_during_RRC_Connected_to_RRC_Inactive_transition
    [Documentation]    This test case tests the gNB behavior for UE in RRC_CONNECTED state that is successfully
    ...                transitioned to RRC_INACTIVE state based on the UE inactivity after Initial Context Setup.
    ...                Successful suspend procedure.
    ...                5G_RAN_USR_RRM_18017, 5G_PM_960

    Set AMF To Send CNAI IE In UE Initial Context Setup Request
    Attach UE And Establish PDU Session And Wait For Release    ue_id=2    gw_id=2
    Stop DCAP trace and download logs
    Convert 5gm Files To Csv
    Convert lcbin Files To Csv

    Check msg in Control Plane logs  InitialContextSetupRequest::CoreNetworkAssistanceInformationForInactive
    Check msg in Control Plane logs  UEContextReleaseComplete::UEContextReleaseComplete
    Check msg in Control Plane logs  BearerContextModificationRequest::BearerContextStatusChange : suspend
    Check msg in Control Plane logs  BearerContextModificationResponse::System-BearerContextModificationResponse
    Check msg in Control Plane logs  UEContextReleaseCommand::radioNetwork : normal-release
    Check msg in Control Plane logs  rrcRelease::suspendConfig
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,releaseData
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,gnb-du-Ids
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,gnb-cu-ue-f1ap-Id
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,gnb-du-ue-f1ap-Id
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,ueCtxReleaseCmdSndTime
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,ueCtxReleaseCmplRcvTime
    Check msg in Cell Trace logs  MeasurementReport::measurementReport
