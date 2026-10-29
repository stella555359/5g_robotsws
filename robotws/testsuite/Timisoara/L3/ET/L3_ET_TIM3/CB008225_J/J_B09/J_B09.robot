*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36
...           CRT      SBTS00     NoResUsage

Documentation    :copyright: Nokia
...              :authors: Dan Moldovan

Resource    ../CB008225_Keywords.robot

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get VM Password
...            AND             Get VM IP
...            AND             Start Vm Ethernet Interfaces
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=delta_8225_no_ran_sharing.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_non_ran_sharing.lua

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
USCB008225_J_B09_1_Activation_of_MBA_functionality_Cell_Trace_and_PCMD
    [Documentation]    This test case validates Trace Session (for Cell Trace and PCMD content) is started
    ...                and Trace Recording Session of UE calls for selected UEs is also started


    Set AMF To Send CNAI IE In UE Initial Context Setup Request    command=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_mo_SMS}
    Attach UE And Establish PDU Session And Wait For Release    ue_id=1    gw_id=1

    Set Parameters For UE RRC Resume Request    ue_id=1    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_SMS
    Sleep  10s
    UE RRC Resume Request    ue_id=1
    Sleep  100s

    Stop DCAP trace and download logs
    Convert 5gm Files To Csv
    Convert lcbin Files To Csv

    ### Check messages: RRCResume, RRCResumeRequest1, RRCResumeComplete and PCMD Records are successfully captured
    Ipcapture should contain Resume_Request List message    ${ResumeRequest1}

    ### Check UeDuConnectivityTraceRecord
#    Check msg in Cell Trace logs  UeDuConnectivityTraceRecord::ueDuConnectivityRecord,releaseData

    Check msg in Cell Trace logs  RRCResumeComplete::rrcResumeComplete  #tbd after PR

