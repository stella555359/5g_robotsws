*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36    PY39_ready
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Radu Turcu
...              :contact: radu.turcu@nokia.com

Resource    ../CB008225_Keywords.robot

Suite Setup    Run Keywords    log to console     Suite Setup Keywords
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get VM Password
...            AND             Get VM IP
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc And Send Delta Commissioning  scfc_filename=delta_8225_no_ran_sharing.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_non_ran_sharing.lua

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             log to console    Wait until AirPhone is ready to gather logs
...               AND             Sleep    200s
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup        Run Keywords     log to console     Test Setup Keywords
...       AND         Get Vm IP and Replace       delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration.json   suite_path=${CURDIR}
...       AND         Find Scfc And Send Delta Commissioning   scfc_filename=delta_Cell_Trace_MDT_PCMD_Configuration.json
...       AND         Remove Vm IP from delta     delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration.json        suite_path=${CURDIR}
...       AND         Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...       AND         Prepare and start DCAP  bts_mplane=10.0.1.2

Test Teardown    Run Keywords     Run  docker stop $(docker ps -a -q)
...               AND     Cleanup EMil dir

*** Test Cases ***
USCB008225_J_B02_D_B1_1_ROBUSTNESS_PCMD_Cell_Trace_Records_and_MDT_measurements_from_gNB_CU_CP_during_RRC_Inactive_to_RRC_Connected_transition
    [Documentation]    This test case validates the PCMD, Cell trace records and MDT measurements reported by
    ...                gNB-CU-CP when UE moves from RRC_Inactive to RRC_Connected state.
    ...                5G_RAN_USR_RRM_188806

    Log to console     Test part
    Set AMF To Send CNAI IE In UE Initial Context Setup Request
    Attach UE And Establish PDU Session And Wait For Release   ue_id=1    gw_id=1
    Set Parameters For UE RRC Resume Request    ue_id=1    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_Signalling
    UE RRC Resume Request via UL NAS PDU    ue_id=1
    Stop DCAP trace and download logs
    Convert 5gm Files To Csv
    Convert lcbin Files To Csv
    ${Message1}   set variable      Resume Request 1
    Ipcapture should contain Resume_Request List message    ${Message1}
    Check msg in Cell Trace logs    UeDuConnectivityTraceRecord::setupData,result,success,ueCtxSetupReqSndTime
    Check msg in Cell Trace logs    CuUeSetupTraceRecord::result,success
    Check msg in Cell Trace logs    CuRrcSetupTraceRecord::rrcConnReqTriggerRcvTime,rrcConnEstablishmentCmplRcvTime
    Check msg in Cell Trace logs    MeasurementReport::measurementReport
    Check msg in Control Plane logs  rrcResumeComplete::dedicatedNAS-Message
    Check msg in Cell Trace logs    RRCResumeComplete::rrcResumeComplete
    Check msg in Cell Trace logs    CuUeSetupTraceRecord::trigger,rrcResume
    Check msg in Cell Trace logs    RRCResume::criticalExtensions,rrcResume
    Check msg in Cell Trace logs    RRCResumeComplete::rrcResumeComplete


