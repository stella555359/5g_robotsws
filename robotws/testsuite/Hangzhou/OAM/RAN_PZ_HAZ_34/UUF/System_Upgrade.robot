*** Settings ***
Documentation   author: Casbo Xing
...  Totally 7 tests in this case set, Netact upgrade&rollback; NOM upgrade&rollback; WebEM upgrade&rollback; Fallback
...  To make the test run optionally, ${NETACT_IP} is also take the role to determain if current test would be run
...  4 values should be put into ${NETACT_IP} with x.x.x.x, if  ${NETACT_IP} set to 0.0.0.0, then current test will be skipped
...  eg. NETACT_IP=10.108.248.82,0.0.0.0,10.108.248.82,10.108.248.82, NOM cases will be skipped
...  For WebEM and fallback case, the IP could be any valid netact or nom IP
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/upgrade_rollback.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Resource/NetAct.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Resource/COAM.robot
#Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Resource/Common.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/trace_vars.py

Force Tags    HAZ4_SG_07_OAM

Suite Setup    Test regression suite setup    webui_tool=COAM    upgrade_tool=netact
Suite Teardown    Test regression suite teardown    webui_tool=COAM

*** Test Cases ***
System_Upgrade_via_Netact
    [Setup]    Test regression setup     upgrade_tool=netact    action=provision   nms_index=${0}
    run keyword if   ${if_not_run}   Log to console   Skip test
    ...   ELSE   SW Provision via NMS
    [Teardown]    Test Regression Teardown    dir=provision    upgrade_tool=netact

System_Rollback_via_Netact
    [Setup]    Test Regression setup    upgrade_tool=netact   action=rollback   nms_index=${0}
    run keyword if   ${if_not_run}   Log to console   Skip test
    ...   ELSE   run keywords   Check If Active Software Version Updated
    ...   AND   COAM NetAct Rollback
    [Teardown]    Test Regression Teardown    dir=rollback    upgrade_tool=netact

System_Upgrade_via_NOM
    [Setup]    Test regression setup     upgrade_tool=netact   action=provision   nms_index=${1}
    run keyword if   ${if_not_run}   Log to console   Skip test
    ...   ELSE   SW Provision via NMS
    [Teardown]    Test Regression Teardown    dir=provision    upgrade_tool=netact

System_Rollback_via_NOM
    [Setup]    Test Regression setup    upgrade_tool=netact    action=rollback   nms_index=${1}
    run keyword if   ${if_not_run}   Log to console   Skip test
    ...   ELSE   run keywords   Check If Active Software Version Updated
    ...   AND   COAM NetAct Rollback
    [Teardown]    Test Regression Teardown    dir=rollback    upgrade_tool=netact

System_Upgrade_via_WebEM
    [Setup]    Test regression setup     upgrade_tool=webui    action=provision   nms_index=${2}
    run keyword if   ${if_not_run}   Log to console   Skip test
    ...   ELSE   SW Provision via WebEM
    [Teardown]    Test Regression Teardown    dir=provision    upgrade_tool=webui

System_Rollback_via_WebEM
    [Setup]   Test Regression setup    upgrade_tool=webui    action=rollback   nms_index=${2}
    run keyword if   ${if_not_run}   Log to console   Skip test
    ...   ELSE   run keywords   Check If Active Software Version Updated
    ...   AND   COAM Webui Rollback
    [Teardown]    Test Regression Teardown    dir=rollback    upgrade_tool=webui

#SW_Fallback_4082
#    [Setup]    Test Fallback Setup    upgrade_tool=webui    webui_tool=COAM   nms_index=${3}
#    run keyword if   ${if_not_run}   Log to console   Skip test
#    ...   ELSE   Trigger SW Fallback
#    [Teardown]   Test Fallback Teardown      dir=fallback

*** Keywords ***
SW Provision via NMS
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_OAM-325
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  **Backlog ID:** FCA_ST_OAM-325
    ...  *****************
    ...  The purpose of this TC is check if verifiy NMS SW provision functionality
    ...  *****************
    ...  Precondition: Target software existed on NMS
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.03.2022 - First case draft created
#    Step 0: Activate Trace session before SW update
    Step 1: Trigger SW provision from NMS
    run keyword if   '${NMS_TYPE}'=='nom'   Step 2: Wait for BTS up from SW update
    Step 3: Check BTS status after SW update NMS View



SW Provision via WebEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_OAM-325
    ...
    ...  *****************
    ...  Basic information
    ...  ********************
    ...  **Backlog ID:** FCA_ST_OAM-325
    ...  *****************
    ...  The purpose of this TC is check if verifiy WebEM SW provision functionality
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.03.2022 - First case draft created
    Step 1: Trigger SW upgrade via WebEM
    Step 2: Wait for BTS up from SW update
    Step 3: Check BTS status after SW update WebEM View

#Trigger SW Fallback
#    COAM Upgrade package    package=${upgrade_version}
#    Wait Until Keyword Succeeds   50 min   10 s    Validate IP Reachability from Test PC
#    ...   ip_addr=${cu_addr}   exp_status=${False}
#    Wait Until Keyword Succeeds   10 min   30 s    Validate IP Reachability from Test PC
#    ...   ip_addr=${cu_addr}  exp_status=${True}
#    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
#    Execute reset loop
#    run keyword and continue on failure   Check connection status after reset
#    wait until keyword succeeds  7min   30s   Check Alarm after Fallback
#    Check SW Version after Fallback
#    Check if log file generated after fallback

Test regression suite setup
    [Arguments]    ${webui_tool}=COAM    ${upgrade_tool}=webui
    run keyword if  not ${${DEBUG}}   selenium_netact.enable_virtual_display
    run keyword and ignore error     Delete Code and Log from TAF
    Remove logs    savefolder=${webui_tool}
    Remove Planned Space
    Set gNB SW version and Release
    Define NMS Type and Set Run Flag   ${0}
    run keyword if  not ${if_not_run}   Switch to source build
    ${bts_id}   convert to string   ${MRBTS_ID}
    set suite variable    ${bts_id}
    Set gNB SW version and Release
    COAM Download SCF to Current Dir    filename=X2ENB_SCF_BACKUP.xml    bts_host=${ENBs[0]['addr']}
    ${x2_enb_mrbtsId}    get_bts_info.Get_LNBTS_ID    ${cpri_scf}/X2ENB_SCF_BACKUP.xml
    set suite variable    ${x2_enb_mrbtsId}
    COAM Download SCF to Current Dir
    Get SCF Param
    Check gNB memory
    Get Disk Space at Beginning
    run keyword if  not ${if_not_run}   Step 0: Activate Trace session before SW update

Test regression suite teardown
    [Arguments]     ${webui_tool}=COAM
    run keyword and ignore error    Upload TAF Log to FTP Server
    run keyword if  not ${${DEBUG}}   selenium_netact.disable_virtual_display

Test Regression setup
    [Arguments]    ${nms_index}   ${upgrade_tool}=netact    ${action}=regression
#    run key word if   '${upgrade_tool}'!='webui'   Define NMS Type   ${nms_index}
    Define NMS Type and Set Run Flag   ${nms_index}
    ${status}    ${passive_not_target}   run keyword and ignore error   Check if Passive Verison is not Target Version
    set suite variable   ${passive_not_target}
    run keyword and ignore error   COAM Download SCF to Current Dir   dir=${OUTPUT_DIR}   filename=SCF_${action}.xml
    run keyword if  not '${action}'=='rollback' or ${if_not_run}     Check if taget SW package exist
    ...   upgradetool=${upgrade_tool}    version=${upgrade_version}
    run keyword if  not '${action}'=='rollback' or ${if_not_run}    Switch to source build
    run keyword and ignore error   Start BTS LOG Collection On Gnb And Rus
    run keyword and ignore error  Start journalctl log for RU   action=${action}

#Test Fallback Setup
#    [Arguments]    ${upgrade_tool}   ${webui_tool}   ${nms_index}
#    Define NMS Type and Set Run Flag   ${nms_index}
#    run keyword unless  ${if_not_run}   Check if taget SW package exist      upgradetool=${upgrade_tool}    version=${upgrade_version}
#    Set gNB SW version and Release
#    run keyword unless  ${if_not_run}   Switch to source build
#    run keyword and ignore error   Start BTS LOG Collection On Gnb And Rus
#    selenium_coam.enable_virtual_display

Test Regression Teardown
    [Arguments]    ${dir}   ${upgrade_tool}=netact
    run keyword if  not ${if_not_run}   run keyword and continue on failure   Coam Check Site Status
    run keyword if  not ${if_not_run}   run keyword and continue on failure
    ...   Check if Unexpected Active Alarm Exist and Set Stop Flag   ${dir}
    run keyword if  not ${if_not_run}   run keyword and continue on failure
    ...   Check if Unexpected History Alarm Exist   ${dir}
    run keyword if  not ${if_not_run}   run keyword and continue on failure   Check Extra Reset from Blackbox File   ${dir}
    run keyword if  not ${if_not_run}   run keyword if test passed    Log Collection for Pass Case
    run keyword if test passed    run keyword and ignore error    Stop And Remove BTS LOG Collection On Gnb And Rus
    run keyword if test passed    Remove logs    savefolder=${TEST_NAME}/${dir}
    run keyword if test failed    _fail_case_operaton    folder=${TEST_NAME}/${dir}    webui_tool=${OAM_TYPE}

Step 0: Activate Trace session before SW update
    run keyword and ignore error   CM Upload in Backend on NetAct
    run keyword and ignore error   Deactivation PCMD Configuration From NetAct Trace Expert
    ...   TL${bts_id}-${nrbts_id}-cell   ${netact_url}   ${netact_account}   ${netact_pwd}
    Get MO from WebEM site
#    COAM Download SCF to Current Dir
    Clear And Renew Trace Configuration
    Activate PCMD Configuration From NetAct Trace Expert
    ...   TL${bts_id}-${nrbts_id}-cell   PLMN-PLMN/${mrbts_id}/${nrbts_id}/${nrcell_id}   5G Radio Cell Trace for gNB-CU-SG7-PCMD combine
    ...   ${netact_url}   ${netact_account}   ${netact_pwd}

Step 1: Trigger SW provision from NMS
    run keyword if    '${NMS_TYPE}'=='netact'   Netact SWM Precheck or Postcheck   operation=Precheck   taget_version=${upgrade_version}
    run keyword if    '${NMS_TYPE}'=='netact'    Trigger Netact Provision
    ...   ELSE    Trigger SW Operation from Nom    operation=provision   nom_nodeip=${nom_nodeip}
    ...   bts_id=${bts_id}   version=${upgrade_version}

Step 2: Wait for BTS up from SW update
    Wait Until Keyword Succeeds   60 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}

Step 3: Check BTS status after SW update NMS View
#    Catch Realtime Log    operation=provision
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   both   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
    Check If Active Software Version Updated
    Check Site Status After Upgrade or Rollback
    wait until keyword succeeds   5 min   30 s    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status
    run keyword and ignore error  run keyword if    '${NMS_TYPE}'=='netact'    Check Some Netact Status    Activation
    Validate Config by WebEM
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}
    Run Keyword    Varify CM Provsion in Bankend on ${NMS_TYPE} via Change RollbackReject
    Run Keyword    Change RollbackReject by CM Provsion in Bankend on ${NMS_TYPE}   bts=${input_btsname}   rollback_status=true
    run keyword if    '${NMS_TYPE}'=='netact'    COAM RollbackReject package
    Run Keyword    Change RollbackReject by CM Provsion in Bankend on ${NMS_TYPE}   bts=${input_btsname}   rollback_status=false
    run keyword if    '${NMS_TYPE}'=='netact'   Netact SWM Precheck or Postcheck   operation=Postcheck   taget_version=${upgrade_version}
    Check if Trace Session Alive   ${Session_Type}[DCAP]

Trigger Netact Provision
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Provision   taget_version=${upgrade_version}
    ${operation_status}   Check Operation Status in NetAct   operation=Provision
    should contain any    ${operation_status}   Successful    Timeout-Success

Define NMS Type and Set Run Flag
    [Arguments]  ${index}
    ${nms_list}   split string    ${NETACT_IP}   ,
    ${if_not_run}    run keyword and return status    should be equal   ${nms_list}[${index}]   0.0.0.0
    set suite variable   ${if_not_run}
    run keyword if  not ${if_not_run}   Get NMS input info   ${nms_list}[${index}]
    run keyword if   ${if_not_run}   set suite variable   ${NMS_TYPE}   netact

Get NMS input info
    [Arguments]  ${nms_ip}
    ${status}    run keyword and return status    dictionary should contain key    ${nom_global_configuration}    ${nms_ip}
    ${NMS_TYPE}    set variable if    ${status}    nom     netact
    set suite variable   ${NMS_TYPE}
    run keyword if  ${status}   set suite variable  ${nom_nodeip}   ${nms_ip}
    ...   ELSE   Get Netact url and access   ${nms_ip}

Get Netact url and access
    [Arguments]  ${nms_ip}
    set suite variable    ${netact_url}   ${netact_global_configuration['${nms_ip}']['url']}
    set suite variable    ${netact_account}   ${netact_global_configuration['${nms_ip}']['http_username']}
    set suite variable    ${netact_pwd}   ${netact_global_configuration['${nms_ip}']['http_password']}
    set suite variable    ${netact_nodeip}    ${nms_ip}
    set suite variable    ${netact_nodeusername}   ${netact_global_configuration['${nms_ip}']['ssh_username']}
    set suite variable    ${netact_nodepassword}   ${netact_global_configuration['${nms_ip}']['ssh_password']}

Step 1: Trigger SW upgrade via WebEM
    COAM Upgrade package    package=${upgrade_version}

Step 3: Check BTS status after SW update WebEM View
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   both   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status

Get MO from WebEM site
    [Arguments]    ${login_ip}=${WEBUI_ADDR}
    Wait Until Keyword Succeeds   3 min   5sec    WEBEM Login    https://${login_ip}/
    ${mrbts_list}   selenium_coam.get_object_name_list   MRBTS
    ${nrbts_list}   selenium_coam.get_object_name_list   NRBTS
    ${nrcell_list}   selenium_coam.get_object_name_list   NRCELL
    set suite variable    ${mrbts_id}   ${mrbts_list}[0]
    set suite variable    ${nrbts_id}   ${nrbts_list}[0]
    ${nrcell_count}   get length   ${nrcell_list}
    FOR   ${index}   IN RANGE   ${nrcell_count}
        ${if_group}   run keyword and return status   should not contain   ${nrcell_list}[${index}]  GRP
        ${if_nradj}   run keyword and return status   should not contain   ${nrcell_list}[${index}]   NRADJ
        run keyword if   ${if_group} and ${if_nradj}    set suite variable   ${nrcell_id}   ${nrcell_list}[${index}]
        exit for loop if   ${if_group} and ${if_nradj}
    END
    [Teardown]   run keyword and ignore error    WEBEM Logout

Check if Trace Related MO existed
    [Arguments]     ${SCF_path}=${CURDIR}/Resource/SCF_BACKUP.xml
    ${NRCTRLTS_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${SCF_path}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTS"]
    ${NRCTRLTSDU_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${SCF_path}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTSDU"]
    ${TCEADM_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${SCF_path}   cmData/managedObject[@class="com.nokia.srbts.mnl:TCEADM"]
    Set Suite Variable   ${NRCTRLTS_EXIST}
    Set Suite Variable   ${NRCTRLTSDU_EXIST}
    Set Suite Variable   ${TCEADM_EXIST}

Get NRBTS ID
    ${NRBTS_ID}   Split string   ${nrbts_id}   -   -1
    set suite variable    ${NRBTS_ID}

Clear And Renew Trace Configuration
    Wait Until Keyword Succeeds   2m   30s   COAM Login
    Check if Trace Related MO existed
    @{del_all_pcmd}   Create List
    Run Keyword If   ${NRCTRLTS_EXIST}   Append To List   ${del_all_pcmd}   ${del_nrctrlts}
    Run Keyword If   ${NRCTRLTSDU_EXIST}   Append To List   ${del_all_pcmd}   ${del_nrctrltsdu}
    Run Keyword If   ${TCEADM_EXIST}   Append To List   ${del_all_pcmd}   ${del_tceadm}
    ${del_str}   Convert To String   ${del_all_pcmd}
    ${del_str}   Set Variable   ${del_str.replace("'","\"")}
    Run Keyword If   ${NRCTRLTS_EXIST} or ${NRCTRLTSDU_EXIST} or ${TCEADM_EXIST}   COAM Perform Delta Recommission   delta_file=${del_str}
    Set gNB SW version and Release
    run keyword if   '${ACTIVE_GNB_RELEASE}' >= 'SBTS22R4'   COAM Add Trace Related Object   ${add_trace_mo_22r4}
    ...   ELSE IF    '${ACTIVE_GNB_RELEASE}' <= 'SBTS22R1'   COAM Add Trace Related Object   ${add_trace_mo_22r1}
    ...   ELSE    COAM Add Trace Related Object   ${add_trace_mo}
    Check if Trace Session Alive   ${Session_Type}[DCAP]
    run keyword and ignore error   Delete MO via COAM   ${mrbts_id}/${nrbts_id}/${nrcell_id}/NRCTRLTS-1/NRMTRACECU-1
    run keyword and ignore error   Remove Trace Plan on NetAct Backend   ${netact_nodeip}   ${netact_nodeusername}   ${netact_nodepassword}
    [Teardown]  run keyword and ignore error   COAM Logout


COAM Add Trace Related Object
    # COAM Update PCMD Flag   flag=true
    [Arguments]  ${add_info}
    ${add_str}   Convert To String   ${add_info}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}
