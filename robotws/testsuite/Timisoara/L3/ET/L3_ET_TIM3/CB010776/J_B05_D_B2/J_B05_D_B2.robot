*** Settings ***
Force Tags    	CLOUD_5G_I_MP_AP_LO    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36
...           CRT      SBTS00     NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristina Burtea

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
USCB008225_J_B05_D_B02_1_PCMD_and_Cell_trace_records_during_RNA_Update_in_same_gNB
    [Documentation]    This test case validates the PCMD records reported by gNB-CU-CP and gNB-DU during RNA Update.


    Set AMF To Send CNAI IE In UE Initial Context Setup Request
    Attach UE And Establish PDU Session And Wait For Release    ue_id=2    gw_id=2
    Sleep  20s
    Perform Parameter Commissioning    parameter=ranAC    value=3    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    Perform Parameter Commissioning    parameter=ranAC    value=5    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1
    Sleep  240s
    Stop DCAP trace and download logs
    Convert 5gm Files To Csv
    Convert lcbin Files To Csv
    Sleep  105s

    Check msg in Control Plane logs  UEContextReleaseComplete::UEContextReleaseComplete
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,releaseData
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,gnb-du-Ids
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,gnb-cu-ue-f1ap-Id
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,gnb-du-ue-f1ap-Id
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,ueCtxReleaseCmdSndTime
    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,ueCtxReleaseCmplRcvTime
    Check msg in Cell Trace logs  CuUeSetupTraceRecord::ueSetupRecord,result success
    Check msg in Cell Trace logs  CuUeSetupTraceRecord::ueSetupRecord,trigger other
    Check msg in Control Plane logs  rrcRelease::suspendConfig
    ${Message1}   set variable      Resume Request 1
    Ipcapture should contain Resume_Request List message    ${Message1}
