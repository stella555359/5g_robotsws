*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36
...           CRT      SBTS00     NoResUsage

Documentation    :copyright: Nokia
...              :authors: Andrei Maria, Cristina Burtea, Dan Moldovan

Resource    ../CB008225_Keywords.robot


Suite Setup    Run Keywords    log to console     Suite Setup Keywords
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get VM Password
...            AND             Get VM IP
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc And Send Delta Commissioning  scfc_filename=delta_8225_no_ran_sharing.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_non_ran_sharing9757.lua

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             log to console    Wait until AirPhone is ready to gather logs
...               AND             Sleep    200s
...               AND             Stop Default Processes And Gather Logs And Compress Logs


Test Setup        Run Keywords     log to console     Test Setup Keywords
...       AND         Get Vm IP and Replace       delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration9757.json   suite_path=${CURDIR}
...       AND         Find Scfc And Send Delta Commissioning   scfc_filename=delta_Cell_Trace_MDT_PCMD_Configuration9757.json
...       AND         Remove Vm IP from delta     delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration9757.json        suite_path=${CURDIR}
...       AND         Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...       AND         Prepare and start DCAP  bts_mplane=10.0.1.2


Test Teardown    Run Keywords     Run  docker stop $(docker ps -a -q)
...               AND     Cleanup EMil dir

*** Variables ***

*** Test Cases ***
USCB008225_J_9757_1_Active_UEs_configured_per_cell_with_periodic_measurements_during_end_of_periodic_measurements_for_SA
    [Documentation]    This test case tests the gNB behavior for UE in RRC_CONNECTED state that is successfully
    ...                transitioned to RRC_INACTIVE state based on the UE inactivity after Initial Context Setup.
    ...                Successful suspend procedure.
    ...                5G_CP_ARC_ARG_9757


    Set AMF To Send CNAI IE In UE Initial Context Setup Request
    Attach Ue And Establish PDU Session    ue_id=1    gw_id=1
    Attach UE And Establish PDU Session And Wait For Release    ue_id=2    gw_id=2
    Stop DCAP trace and download logs
    ${MDT_list1}   set variable      UEs with MDT enabled is 1
    ${MDT_list2}   set variable      UEs with MDT enabled is 2
    Syslog should contain MDT List message    ${MDT_list1}
    Syslog should NOT contain MDT List message   ${MDT_list2}
    Convert 5gm Files To Csv
    Convert lcbin Files To Csv
    Check msg in Cell Trace logs  MeasurementReport::measurementReport


*** Keywords ***
Syslog should contain MDT List message
    [Arguments]      ${MDT_List_string}
    log to console     Verifying MDT List messages in syslog
    ${status}=   run    command=sudo cat ${OUTPUT DIR}/syslogExtracted/full_syslog.log | grep "${MDT_List_string}"
    Should Contain   ${status}  ${MDT_List_string}

Syslog should NOT contain MDT List message
    [Arguments]      ${MDT_List_string}
    log to console     Verifying MDT List messages in syslog
    ${status}=   run    command=sudo cat ${OUTPUT DIR}/syslogExtracted/full_syslog.log | grep "${MDT_List_string}"
    Should Not Contain   ${status}  ${MDT_List_string}



