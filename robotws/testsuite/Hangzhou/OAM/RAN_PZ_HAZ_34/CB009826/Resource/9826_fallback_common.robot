*** Settings ***
Documentation     author: Xing Casbo
...               contact: casbo.xing@nokia-sbell.com
...               squad group: SG_07
...               feature : CB009826

#Library           OperatingSystem
#Library           Collections
#Library           taf.selenium.sbts   WITH NAME   selenium_sbts
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/COAM_Operation.robot
Library           taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Library    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009826/Resource/gnb_para.py
Library    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009826/Resource/list_common.py
#Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Resource/DownloadUtility.robot

*** Variables ***
${alarm_list_1}   [4082]
${alarm_list_2}   [23]
${Ignore_Fault_list}    61524,61652,61649,61074,4592,4655,4654,4459,4340,4293,4681,6327
*** Keywords ***
Test OAM suite setup
    ${SUITE_SETUP_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   SUITE_SETUP_START: ${SUITE_SETUP_START}
    Set Suite Variable   ${SUITE_SETUP_START}
    COAM Login
    COAM WEBUI Login
    COAM Backup Full SCF   file_name=CB009826_scf.xml
    Wait Until Keyword Succeeds   5m   30s   COAM Check all cells should be onair

Test OAM suite teardown
    run keyword and ignore error    COAM Logout
    run keyword and ignore error    COAM WEBUI Logout

Case Setup: Test Dual Core Fallback Setup
    [Documentation]   Setup WEBUI login and start btslog collection
    Run Keyword And Ignore Error    COAM Login
    Check Truck Roll Process
    Wait Until Keyword Succeeds   5m   30s   COAM Check all cells should be onair
    Set SBTS SW version and Release
    Check taget SW package on VM   version=${ACTIVE_GNB_RELEASE}_${ACTIVE_GNB_VERSION}
    run keyword and ignore error    Check SW Active and Passive Version on Both Core
    Run Keyword and Ignore Error   Start Syslog Collection
    Run Keyword And Ignore Error    COAM Logout

Test Dual Core Fallback Teardown
    Save Logs If Case Failed
    Remove SW Package From VM

Dual Core Trigger SW Fallback on Secondary Core
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=primary_core
    ${output}   csn.Execute   command=hostname   connection=primary_core
    ${host_output}   split string   ${output}   \r\n
    ${host}   set variable if   '${host_output}[0]'=='fct-0a'   fct4s0icom.local    fct0s0icom.local
    Log to console   Login to secondary core and execute SW Fallback on Secondary Core ...
    csn.Connect to   hostname=${host}    username=${asik_username}    password=${asik_password}
    ...    alias=secondary_core   proxy=primary_core
    csn.execute   command=ddal -s ddal_boot_set_reset_loop_count 3   timeout=60  connection=secondary_core
    csn.execute   command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN   connection=secondary_core
    Log to console   Execute SW Fallback on Secondary Core finished.
    [Teardown]  Run Keywords    csn.Disconnect    connection=primary_core
    ...   AND   csn.Disconnect    connection=secondary_core

Check Status Dual Core Fallback
    [Arguments]  ${if_primary}=False
    Log to console   Start Check Status Dual Core Fallback ...
    wait until keyword succeeds  7min   30s   Check Alarm Status after Fallback    ${if_primary}
    run keyword and ignore error    Check SW Active and Passive Version on Both Core
    run keyword if    ${if_primary}==${True}   Log to console    Primary core fallback!
    ...   ELSE    Log to console    Secondary core SW fallback!

Check Alarm Status after Fallback
    [Arguments]  ${if_primary}=False
    gnb_para.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
     @{return_active_alarm}   gnb_para.get_active_alarms   connection=gnb   except_alarms=${Ignore_Fault_list}
#     ${active_alarm_list}    create list
    run keyword if    ${if_primary}   Log to console   Major fault 4082 and Critical fault 23 expected in primary core fallback case after SW Fallback
    ...   ELSE   Log to console   Critical fault 4082 expected in secondary core fallback case after SW Fallback
    ${EXPECTED_ALARM1}=     Create Dictionary  faultId='4082'  severity=Critical
    ${EXPECTED_ALARM2}=     Create Dictionary  faultId='23'  severity=Critical
    ${EXPECTED_ALARM3}=     Create Dictionary  faultId='10'  severity=Critical
    ${EXPECTED_1}=   Create List  ${EXPECTED_ALARM1}  ${EXPECTED_ALARM2}
    ${EXPECTED_2}=   Create List  ${EXPECTED_ALARM1}  ${EXPECTED_ALARM3}
    ${Actual_Reported_Alarm_1}   Create Dictionary
    ${Actual_Reported_Alarm_2}   Create Dictionary
    ${Actual_Reported_Alarm_3}   Create Dictionary
    ${Actual}     Create List
     FOR   ${alarm}   IN    @{return_active_alarm}
#         ${fault}    Set Variable    ${alarm['faultName']}
         ${severity}   Set Variable    ${alarm['severity']}
         ${faultid}   Set Variable    ${alarm['faultId']}
         run keyword if   ${faultid}==4082   set to dictionary    ${Actual_Reported_Alarm_1}    faultId='${faultid}'   severity=${severity}
         run keyword if   ${faultid}==23   set to dictionary    ${Actual_Reported_Alarm_2}    faultId='${faultid}'   severity=${severity}
         run keyword if   ${faultid}==10   set to dictionary    ${Actual_Reported_Alarm_3}    faultId='${faultid}'   severity=${severity}
     END
    append to list    ${Actual}   ${Actual_Reported_Alarm_1}
    run keyword if    ${if_primary}==${True}   append to list    ${Actual}   ${Actual_Reported_Alarm_2}
    ...   ELSE    append to list    ${Actual}   ${Actual_Reported_Alarm_3}
    run keyword if    ${if_primary}==${True}   should be equal   ${Actual}   ${EXPECTED_1}
    ...   ELSE   should be equal   ${Actual}   ${EXPECTED_2}
    [Teardown]  run keyword and ignore error  gnb_para.logout

BTS Can Be Recovered From Fallback by SW update
    [Arguments]  ${if_primary}=False
    Log to console   Sleep 10min to wait BTS stable after recover From Fallback.
    BuiltIn.sleep   10min
    Log to console   Provision to clear fault 4082
    Set SBTS SW version and Release
    ${provision_version}   set variable if   ${if_primary}    ${PASSIVE_GNB_RELEASE}_${PASSIVE_GNB_VERSION}
    ...    ${ACTIVE_GNB_RELEASE}_${ACTIVE_GNB_VERSION}
    set suite variable    ${provision_version}
    Recover SBTS from Fallback   target_version=${provision_version}
    Log to console   Check If Fault 4082 Cleared After A SW update
    wait until keyword succeeds   20min   1min   Fallback Check If Alarm As Expected    ${alarm_list_1}
    Log to console   Check If Fault 23 Raised After A SW update
    ${module}   ${fault}   Check Status After SW Reprovision
    run keyword if   ${module}   wait until keyword succeeds  10 min   1min    COAM Check all cells should be onair
    run keyword if  not ${fault}   run keywords   Set SBTS SW version and Release
    ...   AND   Recover SBTS from Fallback    target_version=${ACTIVE_GNB_RELEASE}_${ACTIVE_GNB_VERSION}

Fallback Check If Alarm As Expected
    [Arguments]  ${Expected_alarm}
    gnb_para.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
    @{return_active_alarm}   gnb_para.get_active_alarms   connection=gnb   except_alarms=${Ignore_Fault_list}
    ${fault_exist}   list_common.find_value_in_list   check_list=@{return_active_alarm}   check_key=faultId   check_value_list=${Expected_alarm}
    should not be true   ${fault_exist}
    [Teardown]  run keyword and ignore error  gnb_para.logout

Check Status After SW Reprovision
    [Arguments]  ${if_module_detected}=${False}   ${if_fault_23}=${True}
    FOR  ${i}   IN RANGE  ${45}
        ${if_module_detected}   run keyword and return status   Check BTS Module Status
        exit for loop if  ${if_module_detected}
        ${if_fault_23}   run keyword and return status    Fallback Check If Alarm As Expected   ${alarm_list_2}
        exit for loop if  ${if_fault_23}==${False}
     END
    [Return]  ${if_module_detected}  ${if_fault_23}

Check BTS Module Status
     [Arguments]   ${ip}=${WEBUI_ADDR}    ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
     Log To Console    Check Module Status
     gnb_para.login   ip=${ip}   username=${username}   password=${password}   gnb_type=coam   connection=gnb
     run keyword and continue on failure    Check SMOD Status
     run keyword and continue on failure    Check BBMOD Status
     run keyword and continue on failure    Check RMOD Status
     [Teardown]   run keyword and ignore error  gnb_para.logout   connection=gnb

Check SMOD Status
     @{return_ASIK_status}   gnb_para.check_gnb_asik_status   connection=gnb
     Check Module Status Seperately    Return_Status=${return_ASIK_status}

Check BBMOD Status
     @{return_ABIL_status}   gnb_para.check_gnb_abil_status   connection=gnb
     Check Module Status Seperately   Return_Status=${return_ABIL_status}

Check RMOD Status
     @{return_RU_status}   gnb_para.check_gnb_ru_status   connection=gnb
     Check Module Status Seperately    Return_Status=${return_RU_status}

Check Module Status Seperately
     [Arguments]   ${Return_Status}   ${check_proceduralStatus}=${True}    ${check_administrativestatus}=${True}
     FOR   ${Module_Status}   IN   @{Return_Status}
        ${availability_status}    create list    Online    ${None}    online
        run keyword and continue on failure   List Should Contain Value    ${availability_status}    ${Module_Status['availabilityStatus']}
         ...   msg=[ERROR] status abnormal: ${Module_Status['name']} availabilityStatus：${Module_Status['availabilityStatus']}
        ${operational_state}    Convert To Lower Case    ${Module_Status['operationalState']}
        run keyword and continue on failure   Should Contain    ${operational_state}    enabled
         ...   msg=[ERROR] status abnormal: ${Module_Status['name']} operationalState：${Module_Status['operationalState']}
        run keyword if  ${check_proceduralStatus}   run keyword and continue on failure
         ...   Should Contain    ${Module_Status['proceduralStatus']}    configured
         ...   msg=[ERROR] status abnormal: ${Module_Status['name']} proceduralStatus：${Module_Status['proceduralStatus']}
        ${administrative_state}    run keyword if  ${check_administrativestatus}    Convert To Lower Case    ${Module_Status['administrativeState']}
        run keyword if  ${check_administrativestatus}   run keyword and continue on failure
        ...    Should Contain    ${administrative_state}   unlocked
         ...   msg=[ERROR] status abnormal: ${Module_Status['name']}administrativeState：${Module_Status['administrativeState']}
     END

Dual Core Trigger SW Fallback on Primary Core
    Execute Reset Loop CMD
    run keyword and continue on failure   Check BTS Connectivity
    wait until keyword succeeds  5min   30s    Check if fallback log file generated

Execute Reset Loop CMD
    Wait Until Keyword Succeeds    5min    1min
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.execute   command=ddal -s ddal_boot_set_reset_loop_count 3   timeout=60  connection=gnb
    csn.execute   command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN   timeout=60   connection=gnb

Check BTS Connectivity
    Wait Until Keyword Succeeds   15min   1min   Validate BTS Reachability from VM
    ...   ip_addr=${asik_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   15min   1min    Validate BTS Reachability from VM
    ...   ip_addr=${asik_addr}  exp_status=${True}
    Wait Until Keyword Succeeds   15min   1min    Validate BTS Reachability from VM
    ...   ip_addr=${asik_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   15min  1min   Validate BTS Reachability from VM
    ...   ip_addr=${asik_addr}  exp_status=${True}

Check if fallback log file generated
    csn.Connect to   hostname=${cu_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${output}   csn.execute    command=ls -l /ffs/run/config/fallbackCause.txt    timeout=15   connection=gnb
    should not contain   ${output}   No such file or directory
    [Teardown]  run keyword and ignore error    csn.Disconnect   connection=gnb

Recover SBTS from Fallback
    [Arguments]  ${target_version}
    Log to console   Recover fallback by a SW update
    Check taget SW package on VM   version=${target_version}
    WebEM Upgrade SBTS Package   file_path=/home/ute/Downloads/${target_version}.zip
    Wait Until Keyword Succeeds   3x   30s   COAM Login
    wait until keyword succeeds  25min   1min   COAM Check all cells should be onair

Set SBTS SW version and Release
     ${active_version}   ${passive_version}    Get SBTS SW version
     set suite variable   ${ACTIVE_GNB_VERSION}    ${active_version}
     set suite variable   ${PASSIVE_GNB_VERSION}   ${passive_version}
     ${active_sw_release}   ${passive_sw_release}    Get SBTS SW release
     set suite variable    ${ACTIVE_GNB_RELEASE}   ${active_sw_release}
     set suite variable    ${PASSIVE_GNB_RELEASE}  ${passive_sw_release}

Get SBTS SW version
    [Arguments]  ${ip}=${cu_addr}    ${format}=abbreviation
    ${active_sw_version}   ${passive_sw_version}   wait until keyword succeeds   3min   30s
    ...   gnb_para.get_sw_version_by_ssh   gnb_ip=${ip}    format=${format}
    [Return]    ${active_sw_version}   ${passive_sw_version}

Get SBTS SW release
    [Arguments]  ${ip}=${cu_addr}
     ${active_sw_version}   ${passive_sw_version}   wait until keyword succeeds   3min   30s
     ...   gnb_para.get_sw_version_by_ssh   gnb_ip=${ip}   format=full
     ${active_list}   Split String   ${active_sw_version}   _
     ${passive_list}   Split String   ${passive_sw_version}   _
     ${active_release}      Set Variable If
      ...   '${active_list[2]}'=='0000'   ${active_list[0]}
      ...   '${active_list[2]}'=='9999'   SBTS00
     ${passive_release}      Set Variable If
      ...   '${passive_list[2]}'=='0000'   ${passive_list[0]}
      ...   '${passive_list[2]}'=='9999'   SBTS00
    [Return]    ${active_release}   ${passive_release}

Check taget SW package on VM
    [Arguments]    ${version}
    ${status}    run keyword and return status   OperatingSystem.File Should Exist    /home/ute/Downloads/${version}.zip
    run keyword if  ${status} == ${False}   Download SBTS Package to VM    package_version=${version}

Download SBTS Package to VM
    [Arguments]   ${package_version}   ${package_folder}=/home/ute/Downloads
    ${origin_path}   Set Variable   ${package_folder}/${package_version}_release_BTSSM_downloadable_A54.zip
    ${version_path}   Set Variable   ${package_folder}/${package_version}.zip
    ${file_exists_origin}   Run Keyword and Return Status
    ...   OperatingSystem.File Should Exist   path=${origin_path}
    ${file_exists_version}   Run Keyword and Return Status
    ...   OperatingSystem.File Should Exist   path=${version_path}
    Run Keyword If   ${file_exists_origin}   OperatingSystem.Move File   ${origin_path}   ${version_path}
    ${file_exists}   Evaluate   ${file_exists_origin} or ${file_exists_version}
    ${targetBD}   Run Keyword If   ${file_exists}   OperatingSystem.Run   command=unzip -l ${version_path} | grep -i TargetBD | awk '{print $4}'
    ...   ELSE   Set Variable   ${EMPTY}
    ${fileIntegrity}   Run Keyword And Return Status   Should Not Be Empty   ${targetBD}
    Run Keyword If   not ${fileIntegrity}   OperatingSystem.Run   command=rm -rf ${version_path}
    Return From Keyword If   ${fileIntegrity}   ${version_path}
    ${package_download_link}   Set Download Link   package_version=${package_version}
    Log To Console   Package Do Not Exist, Start to Download Package From WFT!
    Log To Console   Package Download Link: ${package_download_link}
    OperatingSystem.Run   command=rm -f wget-log*
    OperatingSystem.Run   command=wget --no-check-certificate -b ${package_download_link} -O ${version_path}
    BuiltIn.sleep   10s
    ${output}   OperatingSystem.Run   command=cat wget-log | head -n 20
    Should Contain   ${output}   Saving to
    ${output}   OperatingSystem.Run   command=cat wget-log | head -n 20
    Should Not Contain   ${output}   404 Not Found
    Wait Until Keyword Succeeds   15m   1m   Wait For Wget Process Finish   package_name=${version_path}
    OperatingSystem.File Should Exist   path=${version_path}
    OperatingSystem.Run   command=rm -f wget-log*
    Log To Console   Download Classical Package Finished!
    Log To Console   Package Path: ${version_path}
    [Return]   ${version_path}

Wait For Wget Process Finish
    [Arguments]   ${package_name}
    ${output}   OperatingSystem.Run   command=cat wget-log | grep -i "saved"
    Should Contain   ${output}   ${package_name}

WebEM Upgrade SBTS Package
    [Arguments]     ${file_path}
    [Timeout]    2h
    log to console    COAM Upgrade package after SW Fallback.
    Wait Until Keyword Succeeds   3 times   2min    COAM WEBUI Login
    Load SW Package to gNB    file_path=${file_path}
    selenium_sbts.software_update    is_activate=${True}
    ${RETRY_FLAG}   Wait Until Keyword Succeeds   45m   2m   WebEM Wait Software Process Done
    Run Keyword If   "${RETRY_FLAG}"=="RETRY_FLAG"     run keywords   Log to console   BTS is busy.Waiting and Retry...
    ...   AND   BuiltIn.sleep   15min
#    ...   AND   ${RETRY_FLAG}   set variable   ${None}
    ...   AND   Load SW Package to gNB    file_path=${file_path}
    ...   AND   selenium_sbts.software_update    is_activate=${True}
#    ...   AND   ${RETRY_FLAG}   Wait Until Keyword Succeeds   60m   1m   WebEM Wait Software Process Done
#    ...   AND   Run Keyword If   "${RETRY_RESULT}"=="RETRY_FLAG"   FAIL   msg=WebEM Upgrade Failed After Retry...
    ...   AND    Wait Until Keyword Succeeds   45m   2m   WebEM Wait Software Process Done
    [Teardown]   run keyword and ignore error    COAM WEBUI Logout

WebEM Wait Software Process Done
    ${fail_list}   Create List   fail   reject
    ${pass_list}   Create List   reset   Activating software...   Activation completed   Passive software version checking...
    ${retry_list}   Create List   BTS is busy
    ${result}    selenium_sbts.check_software_update_progress
    ${result_status}   Get Variable Value   ${result["status"]}
    ${retry_status}   Run Keyword And Return Status   Should Contain Any    ${result_status}    ${retry_list}
    Return From Keyword If   ${retry_status}   RETRY_FLAG
    ${fail_status}   Run Keyword And Return Status   Should Contain Any    ${result_status}    ${fail_list}
    Run Keyword If   ${fail_status}   Fatal Error   msg=Upgrade Failed: ${result_status}
    ${empty_status}   Run Keyword And Return Status   Should Be Empty   ${result_status}
    Return From Keyword If   ${empty_status}
    Should Contain Any    ${pass_list}    ${result_status}
    Log To Console   WebEM Software Process Ongoing...

Remove SW Package From VM
    ${output}   OperatingSystem.Run   command=ls -l /home/ute/Downloads/
    ${file_exist}   run keyword and return status   should not be equal      ${output}   total 0
    run keyword if   ${file_exist}   OperatingSystem.Run   command=rm /home/ute/Downloads/*

Case Setup: CB009826_OAM_CRT
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    AlarmWatchdog.add_allow_alarms    fault_id=6261

Case Teardown: CB009826_OAM_CRT
    Run Keyword If Test Failed   Run Keyword And Ignore Error   Save Logs If Case Failed
    robot_common_operations.Common Case Teardown

Save Logs If Case Failed
    run keyword and ignore error    Capature Sreenshot COAM
    run keyword and ignore error    Catch Snapshot COAM
    run keyword and ignore error    Stop and Save Syslog Collection
    run keyword and ignore error    Stop and Delete Syslog Collection

Check SW Active and Passive Version on Both Core
    Log to console    Login to primary core and get SW version
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=primary_core
    ${pri_run_output}   csn.Execute   command=cd /ffs/run;ls -l |grep TargetBD.*.xml | grep -v .xml.   connection=primary_core
    ${pri_stb_output}   csn.Execute   command=cd /ffs/stb;ls -l |grep TargetBD.*.xml | grep -v .xml.   connection=primary_core
    ${pri_run}   Get Regexp Matches   ${pri_run_output}   SBTS\\d{2,2}\\w[0-9]?_\\D{3,5}\\d{4}_\\d{6}_\\d{6}
    ${pri_stb}   Get Regexp Matches   ${pri_stb_output}   SBTS\\d{2,2}\\w[0-9]?_\\D{3,5}\\d{4}_\\d{6}_\\d{6}
    Log to console    Login to secondary core and get SW version
    ${host_output}   csn.Execute   command=hostname   connection=primary_core
    ${host_output}   split string   ${host_output}   \r\n
    ${host}   set variable if   '${host_output}[0]'=='fct-0a'   fct4s0icom.local    fct0s0icom.local
    Log to console   Login to secondary core
    csn.Connect to   hostname=${host}     username=${asik_username}   password=${asik_password}
    ...    alias=secondary_core   proxy=primary_core
    ${sec_run_output}   csn.Execute   command=cd /ffs/run;ls -l |grep TargetBD.*.xml | grep -v .xml.   connection=secondary_core
    ${sec_stb_output}   csn.Execute   command=cd /ffs/stb;ls -l |grep TargetBD.*.xml | grep -v .xml.   connection=secondary_core
    ${sec_run}   Get Regexp Matches   ${sec_run_output}   SBTS\\d{2,2}\\w[0-9]?_\\D{3,5}\\d{4}_\\d{6}_\\d{6}
    ${sec_stb}   Get Regexp Matches   ${sec_stb_output}   SBTS\\d{2,2}\\w[0-9]?_\\D{3,5}\\d{4}_\\d{6}_\\d{6}
#    should be equal   ${pri_run}    ${sec_run}
#    should be equal   ${pri_stb}    ${sec_stb}
    [Return]  ${pri_run}   ${pri_stb}   ${sec_run}   ${sec_stb}
    [Teardown]  Run Keywords    csn.Disconnect    connection=primary_core
    ...   AND   csn.Disconnect    connection=secondary_core

Set Download Link
    [Arguments]   ${package_version}
    @{wft_services}   Create Download Full Link   package_version=${package_version}
    ${package_download_link}   Set Variable   ${EMPTY}
    FOR   ${wft_service}   IN   @{wft_services}
       ${http_code}   OperatingSystem.Run   command=echo $(curl -ksIL -w "%\{http_code\}" -o /dev/null ${wft_service})
       ${package_download_link}   Set Variable If   '${http_code.find('200')}'!='-1'   ${wft_service}   ${EMPTY}
       Exit For Loop If   '${http_code.find('200')}'!='-1'
    END
    Run Keyword If   "${package_download_link}"=="${EMPTY}"
    ...   FAIL   msg=Package Version Don't Exist In ALL Download Link. Please Download Manually.
    [Return]   ${package_download_link}

Create Download Full Link
    [Arguments]   ${package_version}
    ${package_prefix}   Split String   ${package_version}   _
    ${package_prefix}   Set Variable   ${package_prefix[0]}
    @{wft_service_list}   Create List
    ...   https://10.57.169.252/build
    ...   https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build
    ...   https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
    ...   https://10.170.21.84/artifactory/mn-cosi-sran-central-public-local/build
    ...   https://10.135.157.75/artifactory/mn-cosi-sran-central-public-remote/build

    @{wft_services}   Create List
    FOR   ${wft_service}   IN   @{wft_service_list}
        ${wft_full_link_1}   Set Variable
        ...   ${wft_service}/${package_prefix}/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
        ${wft_full_link_2}   Set Variable
        ...   ${wft_service}/${package_prefix}/${package_version}_release_BTSSM_downloadable_A54.zip
        ${wft_full_link_3}   Set Variable
        ...   ${wft_service}/SBTSCD00/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
        ${wft_full_link_4}   Set Variable
        ...   ${wft_service}/Testbuild/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
        Append To List   ${wft_services}   ${wft_full_link_1}   ${wft_full_link_2}   ${wft_full_link_3}   ${wft_full_link_4}
    END
    [Return]   ${wft_services}

UUF Get RMOD SN Cell Mapping From Full SCF
    [Arguments]   ${source}
    Log To Console   ${EMPTY}
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    &{rmod_cell_mapping}   Create Dictionary
    ${total_cells_dn}    Create List
    FOR   ${rmod_r}   IN   @{rmod_r_list}
        ${serialNumber}   XML.Get Element Text   ${rmod_r}   p[@name="serialNumber"]
        ${configDN}   XML.Get Element Text   ${rmod_r}   p[@name="configDN"]
        ${configDN}   Should Match Regexp   ${configDN}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+
        # Log To Console   serialNumber: ${serialNumber}
        # Log To Console   configDN: ${configDN}
        ${cell_dn_list}   Get Cell DN List   source=${source}   configDN=${configDN}
        # ${cell_param}   Create Dictionary   configDN=${configDN}   cellDN=${cell_dn_dict}
        ${total_cells_dn}    Combine Lists    ${total_cells_dn}    ${cell_dn_list}
        Set To Dictionary   ${rmod_cell_mapping}   ${serialNumber}=${cell_dn_list}
    END
    # Log To Console   ${rmod_serial_mapping}
    [Return]   ${rmod_cell_mapping}    len(${total_cells_dn})

UUF Get RMOD SerialNumber Mapping
    [Arguments]   ${source}
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    # @{rmod_detail_list}   Create List
    &{rmod_serial_mapping}   Create Dictionary
    FOR   ${rmod_r}   IN   @{rmod_r_list}
        ${serialNumber}   XML.Get Element Text   ${rmod_r}   p[@name="serialNumber"]
        ${configDN}   XML.Get Element Text   ${rmod_r}   p[@name="configDN"]
        ${configDN}   Should Match Regexp   ${configDN}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+
        ${productName}   XML.Get Element Text   ${rmod_r}   p[@name="productName"]
        ${serial_mapping}   Evaluate   {"configDN": "${configDN}", "productName": "${productName}"}
        Set To Dictionary   ${rmod_serial_mapping}   ${serialNumber}=${serial_mapping}
    END
    [Return]   ${rmod_serial_mapping}

Get Cell DN List
    [Arguments]   ${source}   ${configDN}
    ${narrorband_eles}
    ...   XML.Get Elements   ${source}
    ...      xpath=cmData/managedObject[@class="NOKLTE:LNCEL"]/p[@name="cellTechnology" and text()="NB-IoT-FDD"]
    ${narrorband_celldn_list}    Create List
    FOR   ${narrorband_ele}   IN   @{narrorband_eles}
         ${narrorband_cell_dn}   XML.Get Element Attribute   ${narrorband_ele}   distName   xpath=..
         Append to list    ${narrorband_celldn_list}    ${narrorband_cell_dn}
    END
    ${channel_list_xpath}   Catenate   SEPARATOR=
    ...   cmData/managedObject[@class="com.nokia.srbts.mnl:CHANNEL"]/
    ...   p[(@name="antlDN" or @name="resourceDN") and contains(text(),'${configDN}')]
    ${channel_list}   XML.Get Elements   ${source}   xpath=${channel_list_xpath}
    # Log To Console   ${rmod_r_list}
    @{nr_cell_dn_list}   Create List
    @{lte_cell_dn_list}   Create List
    FOR   ${channel}   IN   @{channel_list}
        # Log To Console   ${antlDN}
        ${local_cell}   XML.Get Element Attribute   ${channel}   distName   xpath=..
        ${local_cell}   Get Regexp Matches   ${local_cell}   CELLMAPPING-(.*)/(.*)/CHANNELGROUP   2
        # Log To Console   ${local_cell}
        Continue For Loop If   len(${local_cell})==0
        Continue For Loop If   '${local_cell[0].find("LCELNR")}'=='-1' and '${local_cell[0].find("LCELL")}'=='-1'
        ${local_cell}   Set Variable   ${local_cell[0]}
        ${local_cell_index}   Split String   ${local_cell}   -
        ${local_cell_index}   Set Variable   ${local_cell_index[1]}
        ${lcrid_ele}   Run Keyword If   '${local_cell.find("LCELNR")}'!='-1'
        ...   XML.Get Element   ${source}
        ...      xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/p[@name="lcrId" and text()="${local_cell_index}"]
        ...   ELSE IF   '${local_cell.find("LCELL")}'!='-1'
        ...   XML.Get Element   ${source}
        ...      xpath=cmData/managedObject[@class="NOKLTE:LNCEL"]/p[@name="lcrId" and text()="${local_cell_index}"]
        ${cell_dn}   XML.Get Element Attribute   ${lcrid_ele}   distName   xpath=..
        # Log To Console   ${cell_dn}
        ${status}   run keyword and return status    List Should Contain Value    ${narrorband_celldn_list}      ${cell_dn}
        Continue For Loop If   ${status}
        Run Keyword If   '${local_cell.find("LCELNR")}'!='-1'
        ...   Append To List   ${nr_cell_dn_list}   ${cell_dn}
        ...   ELSE IF   '${local_cell.find("LCELL")}'!='-1'
        ...   Append To List   ${lte_cell_dn_list}   ${cell_dn}
    END
    ${nr_cell_dn_list}   Remove Duplicates   ${nr_cell_dn_list}
    ${lte_cell_dn_list}   Remove Duplicates   ${lte_cell_dn_list}
    # &{cell_dn_dict}   Create Dictionary   NR=${nr_cell_dn_list}   LTE=${lte_cell_dn_list}
    ${cell_dn_list}   Combine Lists  ${nr_cell_dn_list}    ${lte_cell_dn_list}
    # Log To Console   ${nr_cell_index_list}
    # Log To Console   ${lte_cell_index_list}
    # Log To Console   ${cell_dn_dict}
    [Return]   ${cell_dn_list}
