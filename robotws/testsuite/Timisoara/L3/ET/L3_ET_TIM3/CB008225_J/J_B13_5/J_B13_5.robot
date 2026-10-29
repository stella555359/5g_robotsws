*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36
...           CRT      SBTS00     NoResUsage

Documentation    :copyright: Nokia
...              :authors: Elena Sabau, Andrei Maria

Resource    ../CB008225_Keywords.robot

#Suite Setup    log to console  SS
#Suite Teardown    log to console  ST
#Test Setup    log to console  TS
#Test Teardown    log to console  TT

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

Test Setup        Run Keywords    Get Vm IP and Replace       delta_scf=Cell_Trace_MDT_Configuration.json        suite_path=${CURDIR}
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=Cell_Trace_MDT_Configuration.json
...               AND             Remove Vm IP from delta     delta_scf=Cell_Trace_MDT_Configuration.json        suite_path=${CURDIR}
...               AND             Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...            AND                Prepare and start DCAP  bts_mplane=10.0.1.2

Test Teardown    Run Keywords     Run  docker stop $(docker ps -a -q)
...               AND     Cleanup EMil dir

*** Test Cases ***
USCB008225_J_B13_Activation_of_MBA_functionality_with_MDT_content

    Set AMF To Send CNAI IE In UE Initial Context Setup Request
    Attach UE And Establish PDU Session And Wait For Release    ue_id=1    gw_id=1
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=1 gnb=2 cell=1 msg=resume_request_1
    Execute Egate Command    cmd=ue_nr_rrc_resume id=1
    Sleep  60s
    Attach UE And Establish PDU Session And Wait For Release    ue_id=2    gw_id=2
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=2 gnb=2 cell=1 msg=resume_request_1
    Execute Egate Command    cmd=ue_nr_rrc_resume id=2
    Sleep  60s
    Stop DCAP trace and download logs
    Sleep  10s
    Convert 5gm Files To Csv
    Convert lcbin Files To Csv
    Check msg in Cell Trace logs  RRCResumeComplete::rrcResumeComplete
    ${Message1}   set variable      Resume Request 1
    Ipcapture should contain Resume_Request List message    ${Message1}
