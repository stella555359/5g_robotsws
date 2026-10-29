*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot


*** Variables ***
${PASSIVE_SW_STATE}  #Expected SW state after rollback, available states: 'commissioned' 'notcommissioned'.
#Leave blank if TC shouldn't fail due BTS state.
${RESTORE_TIMEOUT}      20m   #Timeout for waiting until cells are onAir/notOnAir in Robot Framework format (600s, 10m)
${SW Update Timeout}    1800


*** Keywords ***
TC_SWM_rollback_Software_for_multi-MRBTS
    [Documentation]    Short description.
    Set Tags    CA-SWM    OWNER-henry.1.wang@nokia-sbell.com  Author-amaand.li@nokia-sbell.com
    TC Preconditions
    Step0: Upgrade to tested version
    Step1: Check active and passive sw version
    Step2: Check if fallback occurred
    Step3: Software rollback
    Step4: Wait till BTS is stable and ensure admin connectivity
    Step5: Check software version
    Step6: Check if active sw is commisioned
    Step7: BTS state verification

Step0: Upgrade to tested version
    [Documentation]    Short description.
    ${Tested_package}=    Common_Find SW name    ${Target SW dir}
    taf.sbts.oam.coam.admin.update software    ${Tested_package}    True    ${SW Update Timeout}
    check BTS is onair after update to tested software

Common_Find SW name
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SW_PATH}: <description>
    ...
    ...    Returns:
    ...        ${SW_PATH_package}: <description>
    [Arguments]    ${SW_PATH}
    ${package name}  OperatingSystem.List files in directory  ${SW_PATH}
    should not be empty  ${package name}  Required package not present in ${SW_PATH}
    ${SW_PATH_package}=  Join Path 	${SW_PATH}  ${package name[0]}
    OperatingSystem.File should exist  ${SW_PATH_package}
    [Return]    ${SW_PATH_package}

check BTS is onair after update to tested software
    [Documentation]    Short description.
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable
    ...  hostname=${SMOD1['TRS_IP']}    timeout=900
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful SW activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful SW activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status  Wait For Target To Be Reachable
    ...  hostname=${SMOD1['TRS_IP']}   timeout=300
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
    Log  Waiting for stable ping...  console=${TRUE}
    ${ping stable status}  Run keyword and return status  Check If Target Is Stable
    ...  ${SMOD1['TRS_IP']}   min_uptime=360  max_downtime=0  timeout=361
    Run keyword if  ${ping stable status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for 60 seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=${TRUE}

TC Preconditions
    [Documentation]    Short description.
    Log  ${\n}TC Preconditions  console=${True}
    Set SCF system modules count and verify product numbers
    Set SCF radio modules count and verify product numbers
    Run keyword and ignore error  Restore config from config.bak on passive partition

Step1: Check active and passive sw version
    [Documentation]    Short description.
    Log  Step1: Check active and passive sw version  console=${True}
    ${SW_PATTERN}=  Set variable  SBTS(?!16)
    ${active_sw_before_rollback}  ${passive_sw_before_rollback}=  Infomodel Get SW Versions
    set test variable    ${active_sw_before_rollback}
    set test variable    ${passive_sw_before_rollback}
    Set tags  SW_BEFORE_ROLLBACK_active-${active_sw_before_rollback}
    Set tags  SW_BEFORE_ROLLBACK_passive-${passive_sw_before_rollback}
    ${active_status}=  Run keyword and return status  Should Match Regexp
    ...  ${active_sw_before_rollback}  (?i)${SW_PATTERN}
    Run keyword if    not ${active_status}  FAIL  ${active_sw_before_rollback} not match ${SW_PATTERN} pattern
    ${passive_status}=  Run keyword and return status  Should Match Regexp
    ...  ${passive_sw_before_rollback}  (?i)${SW_PATTERN}
    Run keyword if    not ${passive_status}  FAIL  ${passive_sw_before_rollback} not match ${SW_PATTERN} pattern
    Log  Active and passive software match given patterns  console=${True}

Step2: Check if fallback occurred
    [Documentation]    Short description.
    Log  Step2: Check if fallback occurred  console=${True}

    ${baseline}    set variable    ${active_sw_before_rollback}
    #${baseline}=  OperatingSystem.Get Environment Variable  baseline            # baseline set in job variables
    ${baseline}=  Remove String Using Regexp  ${baseline}  SBTS\\d+[AB]?_

    ${active_sw_before_rollback}=  Remove String Using Regexp  ${active_sw_before_rollback}  SBTS\\d+[AB]?_
    ${active_sw_bef_rollback_normal}=  Remove String Using Regexp  ${active_sw_before_rollback}  T1
    ${passive_sw_before_rollback}=  Remove String Using Regexp  ${passive_sw_before_rollback}  SBTS\\d+[AB]?_
    ${passive_sw_before_rollback_normalized}=  Remove String Using Regexp  ${passive_sw_before_rollback}  T1

#    Checking if software fallback occurred after software update
    ${fallback_occurrence_software_update}=  Set Variable If
    ...  "${active_sw_bef_rollback_normal}" != "${baseline}"  ${True}  ${False}

#    Checking if software fallback occurred after upgradability
    ${match}  ${value}  Run Keyword And Ignore Error  Should Contain  ${active_sw_before_rollback}  T1
    ${fallback_occurrence_upgradability}  Set Variable If
    ...  "${active_sw_bef_rollback_normal}" == "${passive_sw_before_rollback_normalized}" and "${match}" == "FAIL"
    ...  ${True}  ${False}

#    Final verification of software fallback occurrence based on conditions from above
    ${fallback_occurrence}  Set Variable If
    ...  ${fallback_occurrence_software_update} == ${True} or ${fallback_occurrence_upgradability} == ${True}
    ...  ${True}  ${False}

    Set Test Variable  ${fallback_occurrence}

    Run Keyword If  ${fallback_occurrence}  FAIL
    ...  Rollback won't be executed. Either fallback occured or software download was not successful.
    ...  ELSE  Log  Fallback did not occur. Proceeding with rollback.  console=True

Step3: Software rollback
    [Documentation]    Short description.
    Log  Step2: Software rollback   console=${True}

    Return From Keyword If  ${fallback_occurrence}

    ${rollback_status}=  Run keyword and return status  _do rollback from netact
    Run keyword if    not ${rollback_status}  FAIL  Software rollback was not performed.
    Log  Software rollback ended successfully.  console=${True}

_do rollback from netact
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${status_A}: <description>
    taf.nms.netact.Add Node    cmwas    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}
    ...    ${NETACT_SERVER_INFO.PASSWORD}    alias=ta_netact
    ${sw_rollback_A_start}    Get Current Date
    ${status_A}=    taf.nms.netact.rollback_sw    PLMN-PLMN/${BTS_INFO.MRBTS}    alias=ta_netact
#    ${sw_rollback_A_end}    Get Current Date
#    set test variable    ${sw_rollback_A_start}
#    set test variable    ${sw_rollback_A_end}
#    ${operation_B}=    taf.nms.netact.Start SWM Operation     operation_type=rollback
#    ...  dist_names=${Bts_B_name}     package=${btsB_active_version}    alias=ta_netact
#    ${progress}=    taf.nms.netact.Get Progress Of SWM Operation    ${operation_B}    alias=ta_netact
#    Log    \nProgress: ${progress}    console=${TRUE}
#    taf.nms.netact.Wait For SWM Operation    ${operation_B}    timeout=1800    alias=ta_netact
    [Return]    ${status_A}
    [Teardown]    taf.nms.netact.Clean All    alias=ta_netact

Step4: Wait till BTS is stable and ensure admin connectivity
    [Documentation]    Short description.
    Log  Step3: Wait till BTS is stable and ensure admin connectivity  console=${True}
    ${ping_status}=  tool_ping.Check If Target Is Stable  ip=${SMOD1['TRS_IP']}
    ...  min_uptime=300  max_downtime=300  timeout=1200
    Run keyword if    not ${ping_status}  FAIL  BTS is not stable after rollback.
    Log  BTS is stable after rollback.  console=${True}
    ${Admin working state}  hran_admin.Reset admin and infomodel connection if broken
    Run keyword if    not ${Admin working state}  Fail
    ...  Admin and/of infomodel failure after reset. Interface reset did not help.  console=True

Step5: Check software version
    [Documentation]    Short description.
    Log  Step4: Check software version  console=${True}

    Return From Keyword If  ${fallback_occurrence}

    ${active_sw_after_rollback}  ${passive_sw_after_rollback}=  Infomodel Get SW Versions
#
#    Add row  sw_table  After   ${active_sw_after_rollback}   ${passive_sw_after_rollback}

    Set tags  SW_AFTER_ROLLBACK_active-${active_sw_after_rollback}
    Set tags  SW_AFTER_ROLLBACK_passive-${passive_sw_after_rollback}

    ${active_sw_before_rollback}  Get Regexp Matches  ${active_sw_before_rollback}  SBTS([09]{,2})(.)*
    ${active_sw_before_rollback}  Get From List  ${active_sw_before_rollback}  0

    ${active_sw_after_rollback}  Get Regexp Matches  ${active_sw_after_rollback}  SBTS([09]{,2})(.)*
    ${active_sw_after_rollback}  Get From List  ${active_sw_after_rollback}  0

    ${active_status}=  Run keyword and return status  Should Match Regexp
    ...  ${active_sw_after_rollback}  (?i)${passive_sw_before_rollback}
    Run keyword if    not ${active_status}  FAIL
    ...  ${active_sw_after_rollback} not match ${passive_sw_before_rollback} pattern
    ${passive_status}=  Run keyword and return status
    ...  Should Match Regexp  ${active_sw_before_rollback}  (?i)${passive_sw_after_rollback}
    Run keyword if    not ${passive_status}  FAIL
    ...  ${active_sw_before_rollback}  not match ${passive_sw_after_rollback} pattern
    Log  Active and passive software match given patterns  console=${True}

Step6: Check if active sw is commisioned
    [Documentation]    Short description.
    Log  Step5: Check if active sw is commisioned  console=${True}
    ${is_commissioned}=  Run keyword and return status  Query infomodel
    ...  every //SCF-* is [stateInfo.proceduralState=validated]
    Set test variable  ${IS_COMMISSIONED}  ${is_commissioned}
    Run keyword if  ${is_commissioned}  Log  Active sw is commisioned  console=${True}
    ...  ELSE
    ...  Log  Active sw is not commisioned  console=${True}

Step7: BTS state verification
    [Documentation]    Short description.
    Log  Step6: BTS state verification  console=${True}
    ${modules_status}=  Verify modules states
    ${cells_status}=  Run keyword if  ${IS_COMMISSIONED}  Verify cells states  ELSE  set variable  True

    ${CRITICAL_ALARM}=      Create dictionary  severity=Critical|Major
    ${CRITICAL}=            Create list  ${CRITICAL_ALARM}
    ${status}  ${alarms_msg}=  Run keyword and ignore error  Admin Check Active Alarms  critical_patterns=${CRITICAL}
    Run keyword if  '${status}'=='FAIL'   Set Test Failed    Critical fail while checking alarms: ${alarms_msg}
    ...  ELSE IF  ${alarms_msg}  Set Test Restriction        Unexpected alarms are present: ${alarms_msg}

    Run keyword if  ${modules_status} and ${cells_status}
    ...  Log  BTS is operational  console=${True}
    ...  ELSE
    ...  Set Test Failed  Not all modules are in the expected state. Check logs
    Check if TC should fail due TC variable

Restore config from config.bak on passive partition
    [Documentation]    Short description.
    Log  Restore config on passive partition  console=${True}
    ${rc}=  Run keyword and return status  Execute command on SM via SSH
    ...  192.168.255.1  [[ ! -d "/ffs/stb/config" && -d "/ffs/stb/config.bak" ]]
    Run keyword if  ${rc}
    ...  Run keywords
    ...  Log  Config.bak exist on passive partition, and will be restored  console=${True}  AND
    ...  Execute command on SM via SSH  192.168.255.1
    ...  mount -o remount,rw $(readlink -f /ffs/stb) && mv /ffs/stb/config.bak /ffs/stb/config

Verify cells states
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${cells_state}: <description>
    ${cells_state}=  Run keyword and return status  Wait Until Keyword Succeeds
    ...  ${RESTORE_TIMEOUT}  15s  Fail if not all cells are on air
    [Return]  ${cells_state}

Fail if not all cells are on air
    [Documentation]    Short description.
    ${cells_GSM_onair}=  Verify GSM cells states
    ${cells_WCDMA_onair}=  Verify WCDMA cells states
    ${cells_LTE_onair}=   Verify LTE cells states
    Run keyword if    not ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair}
    ...  Fail  GSM:${cells_GSM_onair} WCDMA:${cells_WCDMA_onair} LTE:${cells_LTE_onair}

Check if TC should fail due TC variable
    [Documentation]    Short description.
    ${is_empty}=  Run keyword and return status  Should be empty  ${PASSIVE_SW_STATE}
    Return from keyword if  ${is_empty}
    Run keyword if    not '${PASSIVE_SW_STATE}' == 'commissioned' and ${IS_COMMISSIONED}
    ...     Set Test Failed  Passive SW should be commissioned
    Run Keyword if	    '${PASSIVE_SW_STATE}' == 'notcommissioned' and ${IS_COMMISSIONED}
    ...  Set Test Failed  Passive SW should be notcommissioned

TC_Custom Setup
    [Documentation]    Short description.
    Common Test Setup    expected_BTS_status=Initializing|^Commissioned|Configured|IntegratedToRan|OnAir
    ...    cells_check=${TRUE}    alarms_check=${TRUE}    modules_check=${TRUE}

TC_Custom Teardown
    [Documentation]    Short description.
    Run keywords    Common Test Teardown
