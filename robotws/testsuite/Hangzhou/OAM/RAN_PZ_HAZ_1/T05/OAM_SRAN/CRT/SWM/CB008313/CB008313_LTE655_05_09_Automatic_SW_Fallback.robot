*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot
#Library    taf.sbts.oam.coam.admin
Library    String
Library    DateTime
Library    OperatingSystem
Library    ute_async


*** Variables ***
${sw_package_path}     /home/ute/btsauto/TARGET_SW
${SW Update Timeout}    1800
#...  #Given in seconds; That is a timeout for SW download and activation (without reset)
${ping_loss_timeout}    240  # Timeout for ping loss during reset
${ping_regain_timeout}    900  # Timeout for ping regain during reset
${restore_timeout}    480  # Timeout for cells to go OnAir after last update
${esm_ip}    192.168.255.119  # ESM trs ip
${FAULT_4001_TIMEOUT}    15  # How long should KW wait for fault 4001 [in minutes]
#${PC_IP2}    ${tl.test_pcs[1].default_ssh_connection_details.addr}  # Secondy PC IP


*** Keywords ***
CB008313_LTE655_05_09_Automatic_SW_Fallback
    [Documentation]    Short description.
    Set Tags    PHASE-COMPA    CA-SWM    OWNER-dominik.jesariew@nokia.com    AUTHOR-wojciech.sikora@nokia.com
    ...         SW-SBTS17     SW-SBTS18    SW-SBTS18SP    SW-SBTS18A    SW-SBTS19
    ...         FEATURE-RP000938    FEATURE-RP001498    FEATURE-RP001621
    Pre-Conditions
    Step 1: Check active and passive sw version and import to netact
    Step 2: Software fallback primary
    Step 3: Wait till cores are stable
    Step 4: Major fault 4082
#    Step 5: Check provision triggered by NE
    sleep    10m
    Step 6: Check if BTS is onair with cell degraded
    Step 7: recover env to clear 4082 by upgrade sw

Pre-Conditions
    [Documentation]    Short description.
    Change parameter to connect netact with BTS
    ${log_1}=    Catenate    This part of doing upgrade to tested package and downgrade branch package to make sure
    ...    the meta difference between active and passive
    Log    ${log_1}
    @{crt_alarms}    create list    4082
    set test variable    ${crt_alarms}
    Add CRT Alarms And Initial WatchAlarm    ${crt_alarms}
    ${Tested_package}=    Common_Find SW name    ${Target SW dir}
    set test variable    ${Tested_package}
    taf.sbts.oam.coam.admin.update software    ${Tested_package}    True    ${SW Update Timeout}
    check BTS is onair after update to tested software

Step 1: Check active and passive sw version and import to netact
    [Documentation]    Short description.
    Log step header  Step 1: Check active and passive sw version
    ${active_sw_before_master}  ${passive_sw_before_master}=  Infomodel Get SW Versions  module=MSM
    ${active_sw_before_ext}  ${passive_sw_before_ext}=  Infomodel Get SW Versions  module=ESM
    Set tags for software  SW_BEFORE_FALLBACK_MASTER  ${active_sw_before_master}  ${passive_sw_before_master}
    Set test variable  ${active_sw_before_master}
    Set test variable  ${passive_sw_before_master}

    Create Directory    /home/ute/btsauto/BASIC_SW/
    ${SW_basic_path}=    set variable    /home/ute/btsauto/BASIC_SW/
    ${full_path}    Download_Specify_Build_By_Aria    ${passive_sw_before_master}    Basic    ${SW_basic_path}
    Set test variable     ${full_path}
    ${passive_sw_before_master_normal}    Run keyword If    '000000'in'${passive_sw_before_master}'
    ...  set variable    ${passive_sw_before_master}
    ...    ELSE IF    '9999'in'${passive_sw_before_master}'
    ...  Replace String Using Regexp    ${passive_sw_before_master}    SBTS[0-9][0-9][A-Z][0-9]?_    SBTS00_
    ${release_NUM}=    should match regexp    ${passive_sw_before_master}    SBTS\\d+..
    set test variable    ${release_NUM}
    ${collect_snapshot}    set variable    never
    Log  Check build in Netact otherwise Import
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}=  Choose_Mid_Server4Netact  ${NETACT_SERVER_INFO.IP}
    build_download_upload_on_remote_server_and_import_to_Netact  target_sw=${passive_sw_before_master_normal}
                                                            ...  release_NUM=${release_NUM}
                                                            ...  remote_ip=${Mid_Server}
                                                            ...  remote_usr=${Mid_Server_usr}
                                                            ...  remote_pwd=${Mid_Server_pwd}
    ${collect_snapshot}    set variable    failed_verdict

Step 2: Software fallback primary
    [Documentation]    Short description.
    Log step header  Step 2: Software fallback
    Log  Checking hardware version  console=${TRUE}
    ${sm_variant}    hran_infomodel.Get SM variant
    Software Fallback   ${sm_variant[0]}

Step 3: Wait till cores are stable
    [Documentation]    Short description.
    Log step header  Step 3: Wait till BTS is stable
    ${ping_loss}  Run keyword and return status
    ...  Wait for target to be not reachable  hostname=192.168.255.129  timeout=480
    Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed.
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status
    ...  Wait for target to be reachable  hostname=192.168.255.129  timeout=240
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Log  Waiting for fallback second reset  console=${TRUE}
    ${ping_loss}  Run keyword and return status
    ...  Wait for target to be not reachable  hostname=192.168.255.129  timeout=1200
    Run keyword if    not ${ping_loss}  Fail  Fallback reset was not performed.

    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status
    ...  Wait for target to be reachable  hostname=192.168.255.129  timeout=900
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Log  Check if BTS is stable after fallback.  console=${TRUE}
    ${ping_status}  Check If Target Is Stable  192.168.255.129  min_uptime=360  max_downtime=420  timeout=1500
    Run keyword if    not ${ping_status}  Fail  BTS is not stable after fallback.
    Log  BTS is stable after fallback.  console=${TRUE}
    ${admin_working_state}  Run keyword and return status
    ...  hran_admin.Admin and Infomodel connections reset  reset_req=${TRUE}
    Run keyword if    not ${admin_working_state}  Fail
    ...  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}
#    Log  Wait till Secondary core is stable
#    ${ping_status}=  Check If Target Is Stable  fct-4a    min_uptime=200    max_downtime=360
#    ...  remote_host=192.168.255.129    remote_host_username=toor4nsn
#    ...  remote_host_password=oZPS0POrRieRtu    timeout=1400
    Run keyword if    not ${ping_status}  Log  Secondary core lost ping after fallback.

Step 4: Major fault 4082
    [Documentation]    Short description.
    Log step header  Step 4: Major fault 4082
    ${EXPECTED_ALARM1}=     Create Dictionary  faultId=4082  severity=Major
#    ${EXPECTED_ALARM2}=     Create Dictionary  faultId=23  severity=Critical
    ${ignored_ALARM1}=     Create Dictionary  faultId=6327  severity=Major
    ${ignored_ALARM2}=     Create Dictionary  faultId=1868  severity=Critical
    ${ignored_ALARM3}=     Create Dictionary  faultId=7300  severity=Major
    ${ignored_ALARM4}=     Create Dictionary  faultId=7319  severity=Major
    ${EXPECTED}=            Create List  ${EXPECTED_ALARM1}
    ${ignored_patterns}=    Create List  ${ignored_ALARM1}  ${ignored_ALARM2}  ${ignored_ALARM3}  ${ignored_ALARM4}
    ${CRITICAL_ALARM1}=     Create Dictionary  severity=Critical|Major
    ${CRITICAL}=            Create List  ${CRITICAL_ALARM1}
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms  expected_patterns=${EXPECTED}  critical_patterns=${CRITICAL}
    ...  ignored_patterns=${ignored_patterns}  timeout=300
    ${log_2}=    Catenate    Alarm with Fault 4082 active on BTS with severity=Major
#    ...  and alarm with Fault 23 active on BTS with severity=Critical. No other active alarms.  console=${TRUE}
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Fail  No Fault 4082 with Critical severity found or other Major|Critical occured
    ...  ELSE IF  ${alarms_msg}
    ...  Set Test Restriction  Fault 4082 active on BTS with severity=Critical but some minor fault found: ${alarms_msg}
    ...  ELSE
    ...  Log  ${log_2}

Step 5: Check provision triggered by NE
    [Documentation]    Short description.
    Log step header  Step 5: Check provision triggered by NE
    wait until keyword succeeds   30min     1s    _check provision triggered by NE

Step 6: Check if BTS is onair with cell degraded
    [Documentation]    Short description.
    Log step header  Step 6: Check if BTS is onair with cell degraded
    Log  Checking if BTS is onair ...  console=${True}
    Log  ${\n}Checking cells operationalState...  console=${True}
    ${cells_status}=  Verify cells states  Check if cells degraded
    Run keyword if  ${cells_status}
    ...  Log  ${\n}All cells operationalState is 'Enabled'  console=${True}
    ...  ELSE
    ...  Fail  Not all cells operationalState is 'Enabled'. Check logs cells_status=${cells_status}

Step 7: recover env to clear 4082 by upgrade sw
    [Documentation]    Short description.
    recover env to clear 4082 by upgrade differ sw
    check BTS is onair after update to tested software

recover env to clear 4082 by upgrade differ sw
    [Documentation]    Short description.
    ${active_sw_bef_rec}  ${passive_sw_bef_rec}=  Infomodel Get SW Versions  module=MSM
    ${active_sw_bef_rec}    run keyword if    '${target_release}'=='SBTS00'
    ...  Replace String Using Regexp    ${active_sw_bef_rec}    [0-9][0-9][A-Z][0-9]?    00
    ...    ELSE    set variable    ${active_sw_bef_rec}
    ${passive_sw_bef_rec}    run keyword if    '${target_release}'=='SBTS00'
    ...  Replace String Using Regexp    ${passive_sw_bef_rec}    [0-9][0-9][A-Z][0-9]?    00
    ...    ELSE    set variable    ${passive_sw_bef_rec}
    ${sw_rec_path}=    Get upgrade path    ${active_sw_bef_rec}
    ...  ${passive_sw_bef_rec}    ${release_list_1}    ${release_list_2}    ${release_list_3}
    ${sw_rec}=    Common_Find SW name    ${sw_rec_path}
    taf.sbts.oam.coam.admin.update software    ${sw_rec}    True    ${SW Update Timeout}

Check if cells degraded
    [Documentation]    Short description.
    ${cells_GSM_onair}=  Verify cells  GSM
    ...  expected_states=availabilityStatus=${_Degraded},usageState=Active  scf_check=${scf_parser_started}
    ${cells_WCDMA_onair}=  Verify cells  WCDMA
    ...  expected_states=availabilityStatus=${_Degraded}, usageState=Active  scf_check=${scf_parser_started}
    ${cells_LTE_onair}=   Verify cells  LTE
    ...  expected_states=availabilityStatus=${_Degraded}, blockingState=Unblocked  scf_check=${scf_parser_started}
    ${cells_NR_onair}=  Verify cells  NR
    ...  expected_states=availabilityStatus=${_Degraded}, blockingState=Unblocked   scf_check=${scf_parser_started}
    Run keyword if    not ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair} and ${cells_NR_onair}
    ...  Fail  GSM:${cells_GSM_onair} WCDMA:${cells_WCDMA_onair} LTE:${cells_LTE_onair} NR:${cells_NR_onair}

check BTS is onair after update to tested software
    [Documentation]    Short description.
    ${ping loss status}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful SW activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful SW activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}   timeout=300
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
    Log  Waiting for stable ping...  console=${TRUE}
    ${ping stable status}  Run keyword and return status
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}   min_uptime=360  max_downtime=0  timeout=361
    Run keyword if  ${ping stable status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for 60 seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=${TRUE}
    Wait until keyword succeeds  15 min  30 sec  Check SBTS SOAM cells and modules
    Log Important Message  BTS is OnAir, all cells and modules are in expected states

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

Check if modules states ok after sw updates
    [Documentation]    Short description.
    Log  Will now check if modules states are correct, for maximum of 60 times with 10s interval...  console=True
    FOR  ${run}  IN RANGE  1  60
        ${modules_status}=  Verify modules  RMOD  scf_check=${FALSE}
        run keyword if  '${modules_status}' == 'True'  Run Keywords
        ...  Log  Modules states are correct. Check attempt: ${run}  console=true
        ...  AND  Return from keyword  ${modules_status}
        Sleep  10
    END
    Set Test Failed  Modules states not correct within timeout

Verify cells states
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${cells_state_check}: <description>
    ...
    ...    Returns:
    ...        ${cells_state}: <description>
    [Arguments]  ${cells_state_check}
    ${cells_state}=  Run keyword and return status
    ...  Wait Until Keyword Succeeds  ${restore_timeout}  5s  ${cells_state_check}
    [Return]  ${cells_state}

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  return from keyword  ${True}
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.reset admin
    ${infomodel_reset_status}  Run keyword and return status
    ...  ute_admin_infomodel.reset infomodel  filename=${BTS Files}/IM/InfoModel_untilReset.ims2
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  return from keyword  ${True}
    Fail  ${admin_reset_status}/${infomodel_reset_status}

SW update for RMODs
    [Documentation]    Short description.
    Log  Will now perform SW update on RMODs  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...            taf.sbts.oam.coam.admin.Update Software  ${SW path}  True  ${SW Update Timeout}
    run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  SW update failed. Reason: ${sw_update_msg}
    Log  Wait until rmods operationalState Enabled  console=${TRUE}
    Wait until keyword succeeds  10 min  30 sec
    ...  taf.sbts.oam.coam.admin.Assert Every  RMOD  operationalState=${_Enabled}

Check ping on ESM after SW update to ESM
    [Documentation]    Short description.
    ${ping_loss_status_ESM_after_ESM_up}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${esm_ip}  timeout=${ping_loss_timeout}
    ...  remote_host=${tl.test_pcs[1].default_ssh_connection_details.addr}
    Run keyword if  ${ping_loss_status_ESM_after_ESM_up}==${False}  Fail
    ...  Ping has not been lost within timeout
    Log  ESM lost ping after update  console=${TRUE}
    ${ping_regain_status_ESM_after_ESM_up}  Run keyword and return status
    ...  Wait For Target To Be Reachable  hostname=${esm_ip}  timeout=${ping_regain_timeout}
    ...  remote_host=${tl.test_pcs[1].default_ssh_connection_details.addr}
    Set test variable  ${ping_regain_status_ESM_after_ESM_up}
    Run keyword if  ${ping_regain_status_ESM_after_ESM_up}==${False}  Fail  Ping has not been regained within timeout
    Log  ESM regained ping after reset  console=${TRUE}

Checking if GSM on ESM
    [Documentation]    Short description.
    ${object_parameter}=  Infomodel Get Objects Parameter
    ...  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/GNBTS_M-*/CELL_M-*/CHANNEL_GROUP_M-*/CHANNEL_M-*/PATH-*
    ...  devicesDNInPath
    ${list_size}  Get Length  ${object_parameter}
    FOR  ${index}  IN RANGE  0  ${list_size}
      ${list}  Get From List  ${object_parameter}  ${index}
      ${status}  Run Keyword And Return Status  Should Contain  ${list[0]}  /BTS_L-4/
      run keyword if  '${status}'=='True'  Return from keyword  ${TRUE}
    END

Checking if WCDMA on ESM
    [Documentation]    Short description.
    ${object_parameter}=  Infomodel Get Objects Parameter
    ...  /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/WNBTS_M-*/CELL_M-*/CHANNEL_GROUP_M-*/CHANNEL_M-*/PATH-*
    ...  devicesDNInPath
    ${list_size}  Get Length  ${object_parameter}
    FOR  ${index}  IN RANGE  0  ${list_size}
      ${list}  Get From List  ${object_parameter}  ${index}
      ${status}  Run Keyword And Return Status  Should Contain  ${list[0]}  /BTS_L-4/
      Run keyword if  '${status}'=='True'  Return from keyword  ${TRUE}
    END

Post update ping check without 2G or 3G cells on ESM
    [Documentation]    Short description.
    [Teardown]  Stop async
    Start async  tool_ping  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=240  max_downtime=0  timeout=250
    Check ping on ESM after SW update to ESM
    ${ping_status_MSM_after_ESM_up}  Get async result
    Log  ${\n}Was MSM ping stable after update on ESM: ${ping_status_MSM_after_ESM_up}  console=${TRUE}
    Run keyword if    not ${ping_status_MSM_after_ESM_up}  Fail  MSM is not stable after update on ESM.

Post update ping check with 2G or 3G cells on ESM
    [Documentation]    Short description.
    Check ping on ESM after SW update to ESM
    Log  Waiting ${FAULT_4001_TIMEOUT}min for fault 4001  console=${TRUE}
    ${fault_4001_status}  Run keyword and return status
    ...  Wait until keyword succeeds  ${FAULT_4001_TIMEOUT} min  5 sec  Check Fault 4001 after update
    Run keyword if  ${fault_4001_status}
    ...  Run keywords
    ...  Log Important Message  Alarm with Fault 4001 active on BTS  AND
    ...  Reset after 4001
    ...  ELSE
    ...  Log Important Message  Fault 4001 DID NOT APPEAR  level=WARN

TC_Custom Setup
    [Documentation]    Short description.
    Common Test Setup
    Delete_uboot_parameters

TC_Custom Teardown
    [Documentation]    Short description.
    Common Test Teardown
    Add_uboot_parameters
