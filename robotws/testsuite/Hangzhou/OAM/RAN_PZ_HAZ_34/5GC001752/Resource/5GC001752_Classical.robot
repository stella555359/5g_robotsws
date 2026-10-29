*** Settings ***
Documentation      author: Lixia Wang
...                 contact: lixia.wang@nokia-sbell.com
...                 These cases are testing 5G20B feature 5GC001752 Zero Touch Commissioning UI for 5G NB for classical Part
...                 There are four parts in BTS startup view, Transport, Configuration, Hardware and Cells.
...                 These cases are to check the content of startup view is aligned with current gnb state/configuration.
...                 Test case does not require special test configuration.

Library           taf.collectors.btslog  WITH NAME   btslog
Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.sbts.oam.coam.admin  WITH NAME   admin
Library           ../../../../RRM/RAN_PZ_HAZ_34/5GC000638/Resources/coam_close.py

*** Variables ***
#Configure the TL specific variable
${USER_LOG_DIR}        /opt/ute/Logs
#${CFGFILE_PATH}        /home/ute/TAF/cfgfile/
${WTS_FILE_PATH}       ${tl.core.dir_path}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${UTE_IP}              ${tl.core.default_ssh_connection_details.addr}
${UTE_USERNAME}        ${tl.core.default_ssh_connection_details.username}
${UTE_PASSWORD}        ${tl.core.default_ssh_connection_details.password}

${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#${ASIK_IP}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}

${PB_ASIK_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}


##################define these variable for convenient############################
${ALIAS_ASIK}     asik    ##
${ALIAS_ASIK_SLAVE}    asik_slave    ##
${ALIAS_UTE}      ute    ##
${ALIAS_ENBCTLPC}    ENB_PC    ##
########################END of alias Define#######################################

*** Keywords ***
TC.5GC001752_001_BTS_EM_displays_BTS_Startup_View_with_Classical_and_SA_Mode
     COAM_Admin.Login
     ${active_sw_release_name}    coam.get_sw_release_name    connection=COAM
     COAM_Admin.Logout
     set test variable    ${active_sw_release_name}
     Get Start Up View Content
     Verify Item Status in Transport Area
     Verify Item Status in Configuration Area



     ${bb_conf_num}  ${bb_detect_num}  ${bb_fail_num}  ${bb_online_num}=   Get Configuration and Dectected BBMOD number
     ${ru_conf_num}  ${ru_detect_num}  ${ru_fail_num}  ${ru_online_num}=   Get Configuration and Dectected RMOD number
     ${cell_conf_num}  ${cell_online_num}  ${cell_fail_num}  ${cell_lock_num}=    Get Cell number and status

    Verfy Baseband modules detection status
    Check Item in Start_up_view is As Expected     ${Hardware}[Configured baseband modules detected]    ${bb_detect_num}
    Check Item in Start_up_view is As Expected     ${Hardware}[Configured baseband modules]    ${bb_conf_num}
    Check Item in Start_up_view is As Expected     ${Hardware}[Configured baseband modules failed]    ${bb_fail_num}

    Verfy Radio modules detection status
    Check Item in Start_up_view is As Expected     ${Hardware}[Configured radio modules detected]    ${ru_detect_num}
    Check Item in Start_up_view is As Expected     ${Hardware}[Configured radio modules]    ${ru_conf_num}
    Check Item in Start_up_view is As Expected     ${Hardware}[Configured radio modules failed]    ${ru_fail_num}

    &{NRcells}     Verfy NR cells status
    Check Item in Start_up_view is As Expected     ${NRcells}[Cells in configuration]    ${cell_conf_num}
    Check Item in Start_up_view is As Expected     ${NRcells}[Cells On Air]    ${cell_online_num}
    Check Item in Start_up_view is As Expected     ${NRcells}[Cells failed]    ${cell_fail_num}
#    COAM_Admin.Logout

TC.5GC001752_007_Startup_View_is_Auto-opening_by_the_BTS_EM_Application
    Power.ResetgNB   model=${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}
    sleep   2min
    #wait until keyword succeeds  20x  2s  COAM_WebEM.Login_WO_Close_MsgBox
    #Get content of start_up_view
    ${gNB_on_air}    run keyword and return status   COAM_VerifyOnAirViaFrontendAndBackend
    log   ${gNB_on_air}
    COAM_WebEM.Login
    ${startup_view_content}   selenium_coam.get_bts_start_up_view_info   timeout=300
    log   ${startup_view_content}
    COAM_WebEM.Logout

TC.5GC001752_002_BTS_EM_displays_BTS_Startup_View_with_Classical_and_NSA_Mode
    Get Start Up View Content
    Verify Item Status in Transport Area

TC.5GC001752_003_Show_Transport_Status_in_BTS_Startup_View
    Get Start Up View Content
    Verify Item Status in Transport Area

TC.5GC001752_004_Show_Configuration_Status_in_BTS_Startup_View
    Verify Item Status in Configuration Area

TC.5GC001752_005_Show_HW_Status_in_BTS_Startup_View
    Verfy Baseband modules detection status
    Check Item in Start_up_view is As Expected     ${Hardware}[Configured baseband modules detected]    ${bb_detect_num}
    Check Item in Start_up_view is As Expected     ${Hardware}[Configured baseband modules]    ${bb_conf_num}
    Check Item in Start_up_view is As Expected     ${Hardware}[Configured baseband modules failed]    ${bb_fail_num}

    Verfy Radio modules detection status
    Check Item in Start_up_view is As Expected     ${Hardware}[Configured radio modules detected]    ${ru_detect_num}
    Check Item in Start_up_view is As Expected     ${Hardware}[Configured radio modules]    ${ru_conf_num}
    Check Item in Start_up_view is As Expected     ${Hardware}[Configured radio modules failed]    ${ru_fail_num}

TC.5GC001752_006_Show_Cell_Status_in_BTS_Startup_View
    &{NRcells}      Verfy NR cells status
    Check Item in Start_up_view is As Expected     ${NRcells}[Cells in configuration]    ${cell_conf_num}
    Check Item in Start_up_view is As Expected     ${NRcells}[Cells On Air]    ${cell_online_num}
    Check Item in Start_up_view is As Expected     ${NRcells}[Cells failed]    ${cell_fail_num}

Setup Case
    [Arguments]
    TestCase.Start
    Run Keyword And Ignore Error    Start BTSlogs Collection

Teardown Case
    [Arguments]
    Run Keyword And Ignore Error     Stop BTSlogs Collection and get logs
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
    Run Keyword And Ignore error     selenium_coam.disable_virtual_display
    Run Keyword And Ignore error     force_close_coam_webdriver
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver
    Conn.ResetCache
    TestCase.Stop

Start BTSlogs Collection
    [Documentation]    collect syslogs from ute VM.
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/home/ute/btslog/btslog
    ...   btslog_launcher_path=/home/ute/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "")}_SYSLOG.tgz ${LOG_PATH}


Get Start Up View Content
    COAM_WebEM.Login
    ${startup_view_content}   selenium_coam.get_bts_start_up_view_info   timeout=300
    COAM_WebEM.Logout
    set suite variable      ${startup_view_content}
    ${Cells}   set variable     ${startup_view_content}[Cells]
    ${Hardware}   set variable    ${startup_view_content}[Hardware]
    ${Transport}   set variable     ${startup_view_content}[Transport]
    ${Configuration_in_startup}   set variable    ${startup_view_content}[Configuration]
    set suite variable   ${Cells}
    set suite variable   ${Hardware}
    set suite variable   ${Transport}
    set suite variable   ${Configuration_in_startup}

Verify Item Status in Transport Area
    [Documentation]  Connection to NMS:  Pending for NetAct SW readiness.
    ...   Connection to CU: should alway be NA for classical gNB
    ...   Connection to 5G Core: should be NA for NSA, Succeeded or Ongoing for SA depending on current NGlink status.
    COAM_WebEM.Login
    ${gnb_cu_type}   Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.get_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}    filter_param=gNB CU type
    set suite variable    ${gnbcutype}
    run keyword if    ${AF_PATH.count('SBTS')}==${0}    Check Item in Start_up_view is As Expected    ${Transport}[Connection to CU]    N/A
    run keyword if   '${gnbcutype}' == 'NSA'      Check Item in Start_up_view is As Expected    ${Transport}[Connection to 5G core]    N/A
    ...   ELSE    The state of Connection to 5G Core is algined with NG link state
    COAM_WebEM.Logout

Verify Item Status in Configuration Area
    [Documentation]  Data conversion: Status change can only be triggered by sit migration or upgrade, which is not possible to TA.
    ...   thus the status should alway be NA.
    ...   Configuration validation: This case only check the final status, which should be succeeded.
    Check Item in Start_up_view is As Expected     ${Configuration_in_startup}[Configuration validation]    Succeeded

Check Item in Start_up_view is As Expected
    [Arguments]    ${item}   ${expected_value}=N/A
    [Documentation]  This keyword is checking start-up view iteam should be equal to expected value
    should be equal as strings  ${item}   ${expected_value}

Get Configuration and Dectected RMOD number
    [Documentation]  This KW to get configured /Detected RMOD number.
       COAM_WebEM.Login
       COAM_Admin.Login
       ${frm_list}     admin.get_frm     connection=COAM
       set suite variable    ${ru_conf_num}    ${0}
       set suite variable    ${ru_detect_num}    ${0}
       set suite variable    ${ru_fail_num}    ${0}
       set suite variable    ${ru_online_num}    ${0}
       FOR    ${item}    IN    @{frm_list}
               ${item['status']['operationalState']}  Evaluate   '${item['status']['operationalState']}'.lower()
               ${ru_conf_num}=    Run keyword if  '${item['id']['configuration']}'!='empty'  Evaluate    ${ru_conf_num}+1
           ...    ELSE    set variable   ${ru_conf_num}
               ${ru_detect_num}=    Run keyword if  '${item['id']['runtime']}'!='empty'  Evaluate    ${ru_detect_num}+1
           ...    ELSE    set variable   ${ru_detect_num}
                ${ru_fail_num}=    Run keyword if  '${item['status']['operationalState']}'!='enabled'      Evaluate    ${ru_fail_num}+1
                #${ru_fail_num}=    Run keyword if  '${item['status']['availabilityStatus']}'=='failed'      Evaluate    ${ru_fail_num}+1
           ...   ELSE   set variable   ${ru_fail_num}
               ${ru_online_num}=    Run keyword if   '${item['status']['operationalState']}'=='enabled'
           #...   '${item['status']['availabilityStatus']}'=='Online' or '${item['status']['availabilityStatus']}'=='Degrade'
           ...    Evaluate    ${ru_online_num}+1
           ...   ELSE   set variable   ${ru_online_num}
       END
       BuiltIn.log  message=ru info ${ru_conf_num} ${ru_detect_num} ${ru_fail_num} ${ru_online_num}
       set suite variable    ${ru_conf_num}    
       set suite variable    ${ru_detect_num}    
       set suite variable    ${ru_fail_num}    
       set suite variable    ${ru_online_num}
       COAM_WebEM.Logout
       COAM_Admin.Logout
       [return]  ${ru_conf_num}  ${ru_detect_num}  ${ru_fail_num}  ${ru_online_num}

Get Configuration and Dectected BBMOD number
    [Documentation]  This KW to get configured /Detected BBMOD number.
       COAM_WebEM.Login
       COAM_Admin.Login
       ${bb_list}      admin.get_fbb_info    connection=COAM
        set suite variable   ${bb_conf_num}    ${0}
        set suite variable   ${bb_detect_num}  ${0}
        set suite variable    ${bb_fail_num}   ${0}
        set suite variable    ${bb_online_num}   ${0}
       FOR    ${item}    IN    @{bb_list}
           ${item['status']['operationalState']}  Evaluate   '${item['status']['operationalState']}'.lower()
               ${bb_conf_num}=    Run keyword if  '${item['id']['configuration']}'!='empty'    Evaluate    ${bb_conf_num}+1
           ...    ELSE   set variable   ${bb_conf_num}
               ${bb_detect_num}=    Run keyword if  '${item['id']['runtime']}'!='empty'    Evaluate    ${bb_detect_num}+1
           ...    ELSE   set variable   ${bb_detect_num}
               ${bb_fail_num}=    Run keyword if  '${item['status']['operationalState']}'!='enabled'      Evaluate    ${bb_fail_num}+1
               #${bb_fail_num}=    Run keyword if  '${item['status']['availabilityStatus']}'=='failed'      Evaluate    ${bb_fail_num}+1
           ...   ELSE   set variable   ${bb_fail_num}
               ${bb_online_num}=    Run keyword if    '${item['status']['operationalState']}'=='enabled'
           #...   '${item['status']['availabilityStatus']}'=='Online' or '${item['status']['availabilityStatus']}'=='Degrade'
           ...   Evaluate    ${bb_online_num}+1
           ...   ELSE   set variable   ${bb_online_num}
       END
       ${sm_list}      admin.get_fsm_info    connection=COAM
        set suite variable   ${sm_conf_num}    ${1}
        set suite variable   ${sm_detect_num}  ${1}
        set suite variable    ${sm_fail_num}   ${0}
        set suite variable    ${sm_online_num}   ${0}
        FOR    ${item}    IN    @{sm_list}
                ${item['status']['operationalState']}  Evaluate   '${item['status']['operationalState']}'.lower()
                ${sm_fail_num}=    Run keyword if  '${item['status']['operationalState']}'!='enabled'    Evaluate    ${sm_fail_num}+1
                #${sm_fail_num}=    Run keyword if  '${item['status']['availabilityStatus']}'=='failed'      Evaluate    ${sm_fail_num}+1
            ...   ELSE   set variable   ${sm_fail_num}
                ${sm_online_num}=    Run keyword if     '${item['status']['operationalState']}'=='enabled'
            #...   '${item['status']['availabilityStatus']}'=='Online' or '${item['status']['availabilityStatus']}'=='Degrade'
            ...    Evaluate    ${sm_online_num}+1
            ...   ELSE   set variable   ${sm_online_num}
        END
       ${bb_conf_num}  Evaluate    ${bb_conf_num}+${sm_conf_num}
       ${bb_detect_num}  Evaluate  ${bb_detect_num}+${sm_detect_num}
       ${bb_fail_num}  Evaluate  ${bb_fail_num}+${sm_fail_num}
       ${bb_online_num}  Evaluate  ${bb_online_num}+${sm_online_num}
       BuiltIn.log  message=baseband info ${bb_conf_num} ${bb_detect_num} ${bb_fail_num} ${bb_online_num}
       set suite variable   ${bb_conf_num}    
       set suite variable   ${bb_detect_num}  
       set suite variable    ${bb_fail_num}   
       set suite variable    ${bb_online_num}
       COAM_WebEM.Logout
       COAM_Admin.Logout
       [return]  ${bb_conf_num}  ${bb_detect_num}  ${bb_fail_num}  ${bb_online_num}

Get Cell number and status
     COAM_WebEM.Login
     COAM_Admin.Login
     ${cell_list}    admin.get_cells_info    connection=COAM
       set suite variable   ${cell_conf_num}  ${0}
       set suite variable  ${cell_online_num}  ${0}
       set suite variable  ${cell_fail_num}    ${0}
       set suite variable  ${cell_lock_num}    ${0}
       FOR    ${item}    IN    @{cell_list}
           ${item['status']['operationalState']}  Evaluate   '${item['status']['operationalState']}'.lower()
                ${cell_conf_num}=    Run keyword if  '${item['id']['configuration']}'!='empty'  Evaluate    ${cell_conf_num}+1
           ...    ELSE    set variable   ${cell_conf_num}
                ${cell_fail_num}=    Run keyword if      '${item['status']['operationalState']}'!='enabled'
           #...   '${item['status']['availabilityStatus']}'=='Failed' or '${item['status']['availabilityStatus']}'=='Dependency'
           ...   Evaluate    ${cell_fail_num}+1
           ...   ELSE   set variable   ${cell_fail_num}
               ${cell_online_num}=    Run keyword if    '${item['status']['operationalState']}'=='enabled'
           #...   '${item['status']['availabilityStatus']}'=='Online' or '${item['status']['availabilityStatus']}'=='Degrade'
           ...    Evaluate    ${cell_online_num}+1
           ...   ELSE   set variable   ${cell_online_num}
               ${cell_lock_num}=    Run keyword if
           ...   '${item['status']['administrativeState']}'=='Locked'
           #and '${item['status']['availabilityStatus']}'=='Offline'
           ...    Evaluate    ${cell_lock_num}+1
           ...   ELSE   set variable   ${cell_lock_num}
       END
       set suite variable   ${cell_conf_num}
       set suite variable  ${cell_online_num}
       set suite variable  ${cell_fail_num}
       set suite variable  ${cell_lock_num}
       COAM_WebEM.Logout
       COAM_Admin.Logout
       [return]  ${cell_conf_num}  ${cell_online_num}  ${cell_fail_num}  ${cell_lock_num}

Verfy NR cells status
     ${cell_success_num}=    Evaluate    ${cell_lock_num}+${cell_online_num}
     set test variable    ${cell_success_num}
     ${NRcells}    set variable      ${Cells}[NR cells]
     run keyword if    '${cell_fail_num}'!='0'    Check Item in Start_up_view is As Expected    ${NRcells}[Status]     Failed
     ...  ELSE IF    '${cell_success_num}'=='${cell_conf_num}'    Check Item in Start_up_view is As Expected
       ...    ${NRcells}[Status]     Succeeded
     ...  ELSE       Check Item in Start_up_view is As Expected     ${NRcells}[Status]    Ongoing
      [Return]    &{NRcells}
Verfy Baseband modules detection status
     run keyword if    '${bb_fail_num}'!='0'    Check Item in Start_up_view is As Expected    ${Hardware}[Baseband modules detection]    Failed
     ...  ELSE IF    '${bb_online_num}'=='${bb_conf_num}'    Check Item in Start_up_view is As Expected
     ...    ${Hardware}[Baseband modules detection]    Succeeded
     ...  ELSE       Check Item in Start_up_view is As Expected     ${Hardware}[Baseband modules detection]    Ongoing

Verfy Radio modules detection status
     run keyword if    '${ru_fail_num}'!='0'    Check Item in Start_up_view is As Expected    ${Hardware}[Radio modules detection]    Failed
     ...  ELSE IF    '${ru_online_num}'=='${ru_conf_num}'    Check Item in Start_up_view is As Expected
     ...    ${Hardware}[Radio modules detection]    Succeeded
     ...  ELSE       Check Item in Start_up_view is As Expected     ${Hardware}[Radio modules detection]    Ongoing

The state of Connection to 5G Core is algined with NG link state
    &{amf_status}    selenium_coam.get_amf_info
    set test variable    ${ng_link_status}    ${amf_status}[NG link status]
    run keyword if  '${ng_link_status}'=='Active'    Check Item in Start_up_view is As Expected   ${Transport}[Connection to 5G core]   Succeeded
    ...   ELSE    Check Item in Start_up_view is As Expected   ${Transport}[Connection to 5G core]   Ongoing

COAM_WebEM.Login_WO_Close_MsgBox
    [Documentation]   parameter should be ${True} or ${False}
    [Arguments]      ${virtual_enable}=${TRUE}
    run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    url=${WEBUI_URL}   username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}  timeout=${30}
    selenium_coam.disable_screen_lock
    selenium_coam.disable_message_box
    sleep    15
