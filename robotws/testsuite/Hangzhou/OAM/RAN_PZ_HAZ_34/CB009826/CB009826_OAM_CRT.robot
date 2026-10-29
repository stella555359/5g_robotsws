*** Settings ***
Documentation   author: Casbo Xing
...  CB009826 OAM CA CRT
#Resource      Resource/9826_fallback_common.robot
Resource      Resource/troubleshooting_common.robot


Suite Setup    Test OAM suite setup
Suite Teardown    Test OAM suite teardown


*** Test Cases ***
CB009826_A_OAM_CRT
    [Setup]  Case Setup: CB009826_OAM_CRT
    [Timeout]    3h
#    run keyword and continue on failure   CB009826_A_1_OAM_Primary_Core_Fallback
    ${gnb_release}     Get gnb release    host=${LMP_ADDR}
    Set Suite Variable    ${gnb_release}
    Run keyword if   '${gnb_release}'=='SBTS24R2'    run keyword and continue on failure   Manual Failure and Skip Known Issue Case
    ...   ELSE   run keyword and continue on failure   CB009826_A_2_OAM_Secondary_Core_Fallback
    run keyword and continue on failure   CB009826_A_3_OAM_WebEM_Power_Reset_BTS
    [Teardown]  Case Teardown: CB009826_OAM_CRT


*** Keywords ***
CB009826_A_1_OAM_Primary_Core_Fallback
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing primary core(DC) fallback due to max reset loop
    ...    The main steps performed for the test are:
    ...     - Login to primary core and execute ddal -s ddal_boot_set_reset_loop_count 3
    ...     ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    ...     - Check if fallback occurred on primary core(with major fault 4082) and critical fault 23 on secondary core
    ...     - Provision BTS to previous running package(//To do:option 2:auto-proviosn triggered by Netact)
    ...     - Check if fault 4082 and fault 23(DN:SMOD)cleared and BTS startup
    ...     - Check final BTS state
    ...    Pass criteria: BTS startup normally after reprovision(fault 23(DN:RMOD) is as expected in this case)
    ...    In case fault 23 after sw reprovision, it shall be cleared after one more sw provision
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.04.2024 - Case Draft
    ...    - 02.04.2024 - First passed version
    ...    Author: casbo.xing@nokia-sbell.com
    Case Setup: Test Dual Core Fallback Setup
    AlarmWatchdog.add_allow_alarms    fault_id=7701
    AlarmWatchdog.add_allow_alarms    fault_id=4352
    AlarmWatchdog.add_allow_alarms    fault_id=4082
    AlarmWatchdog.add_allow_alarms    fault_id=7107
    Dual Core Trigger SW Fallback on Primary Core
    Check Status Dual Core Fallback   if_primary=${True}
    BTS Can Be Recovered From Fallback by SW update   if_primary=${True}
    Check SW Active and Passive Version on Both Core
    [Teardown]  Run keywords
    ...   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Save Logs If Case Failed
    ...   AND   Remove SW Package From VM

CB009826_A_2_OAM_Secondary_Core_Fallback
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing secondary core(DC) fallback due to max reset loop
    ...    The main steps performed for the test are:
    ...     - Login to secondary core and execute ddal -s ddal_boot_set_reset_loop_count 3
    ...     ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    ...     - Check if fallback occurred on secondary core(with critical 4082)
    ...     - Provision BTS to current running package(//To do:option 2:auto-proviosn triggered by Netact)
    ...     - Check if fault 4082 cleared and BTS startup
    ...     - Check final BTS state
    ...    Pass criteria: BTS startup normally after reprovision(fault 23 is as expected in this case)
    ...    In case fault 23 after sw reprovision, it shall be cleared after one more sw provision
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.04.2024 - Case Draft
    ...    - 02.04.2024 - First passed version
    ...    Author: casbo.xing@nokia-sbell.com
    [Timeout]    2h
    Case Setup: Test Dual Core Fallback Setup
    AlarmWatchdog.add_allow_alarms    fault_id=7701
    AlarmWatchdog.add_allow_alarms    fault_id=4352
    AlarmWatchdog.add_allow_alarms    fault_id=7107
    AlarmWatchdog.add_allow_alarms    fault_id=1806
    AlarmWatchdog.add_allow_alarms    fault_id=4401
    AlarmWatchdog.add_allow_alarms    fault_id=4082
    AlarmWatchdog.add_allow_alarms    fault_id=23
    AlarmWatchdog.add_allow_alarms    fault_id=10
    Dual Core Trigger SW Fallback on Secondary Core
    Check Status Dual Core Fallback
#    BuiltIn.sleep  5min
#    AlarmWatchdog.add_allow_alarms    fault_id=6450
#    Wait Until Keyword Succeeds    3x  10s   COAM Login
#    COAM Reset Site
    BTS Can Be Recovered From Fallback by SW update
    AlarmWatchdog.remove_allow_alarms    fault_id=4082
    AlarmWatchdog.remove_allow_alarms    fault_id=23
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    ${pri_run}   ${pri_stb}  ${sec_run}   ${sec_stb}    Check SW Active and Passive Version on Both Core
    should be equal   ${pri_run}    ${sec_run}
    should be equal   ${pri_stb}    ${sec_stb}
    [Teardown]  Run keywords
    ...   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Save Logs If Case Failed
    ...   AND   AlarmWatchdog.add_allow_alarms    fault_id=4802
    ...   AND   AlarmWatchdog.add_allow_alarms    fault_id=23
    ...   AND   AlarmWatchdog.add_allow_alarms    fault_id=10
    ...   AND   Recover SBTS from Fallback    target_version=${provision_version}
    ...   AND   Run Keyword If   "${KEYWORD_STATUS}"!="FAIL"   Remove SW Package From VM
    ...   AND   Run Keyword And Ignore Error    COAM Logout

CB009826_A_3_OAM_WebEM_Power_Reset_BTS
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing power reset BTS by WebEM
    ...    The main steps performed for the test are:
    ...     - Login to WebEM and execute BTS power reset
    ...     - Check if BTS can starup normally from remote power reset
    ...     - Check if blackbox recording power reset as expected
    ...     - Power reset will be executed in loops
    ...     - No unexpected fault or errors should be presented after BTS up from power reset
    ...    Pass criteria: BTS startup normally after power reset
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.04.2024 - Case Draft
    ...    -
    ...    Author: casbo.xing@nokia-sbell.com
    [Timeout]    1h
    Case Setup: TRBL Test Setup
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    WebEM BTS Power Reset in Loops
    [Teardown]  Run keywords
    ...   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Save Logs If Case Failed
    ...   AND   Run Keyword If   "${KEYWORD_STATUS}"!="FAIL"   Remove SW Package From VM
    ...   AND   run keyword and ignore error    COAM Logout
    ...   AND   Run Keyword And Ignore Error   COAM WEBUI Logout

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

Manual Failure and Skip Known Issue Case
    log to console    \nSkip:CB009826_A_2_OAM_Secondary_Core_Fallback cause testline broken by fault4261
    ${9826_A_2_OAM_status}   Set variable   Failure
    run keyword and continue on failure    Run Keyword IF    '${9826_A_2_OAM_status}'=='Failure'    FAIL
