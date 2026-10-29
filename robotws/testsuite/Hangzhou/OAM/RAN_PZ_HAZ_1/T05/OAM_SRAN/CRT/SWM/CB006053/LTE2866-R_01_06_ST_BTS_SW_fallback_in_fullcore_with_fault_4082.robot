*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Library    taf.sbts.oam.coam.admin
Library    String
Library    DateTime
Library    OperatingSystem
Library    ute_async


*** Variables ***
${sw_package_path}     /home/ute/btsauto/TARGET_SW
${SW Update Timeout}    1800  # Given in seconds; That is a timeout for SW download and activation (without reset)
${ping_loss_timeout}                         240  # Timeout for ping loss during reset
${ping_regain_timeout}                       900  # Timeout for ping regain during reset
${restore_timeout}                           240  # Timeout for cells to go OnAir after last update
${esm_ip}                        192.168.255.119  # ESM trs ip
${FAULT_4001_TIMEOUT}                         15  # How long should KW wait for fault 4001 [in minutes]
#${PC_IP2}                 ${tl.test_pcs[1].default_ssh_connection_details.addr}


*** Keywords ***
LTE2866-R_01_06_ST BTS SW fallback in fullcore with fault 4082
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-9883
    ...  *****************
    ...  Basic information
    ...  ********************
    ...  **Request ID:** TAT-9883
    ...  *****************
    ...  Main purpose of TC is checking fallback functionality of SBTS SW in dual core configuration:
    ...  fallback from SBTS_SOAM to SBTS_SOAM
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.05.2018 - TC file created, implementation started
    ...  - 10.09.2018 - TAT-12126 Set test norun changed to Set test blocked in META check
    ...  - 24.12.2018 - TAT-13071 Info about active Fault 4082 added when minor faults present on BTS
    ...  - 27.12.2018 - TAT-13802
    ...  - 19.03.2019 - TAT-14934
    ...  - 18.04.2019 - TAT-15093 COMPA -
    ...  DC_SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC failed with MSM is not stable after update on ESM.
    ...  - 05.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17398 - TC OWNER changed
    ...  - 15.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-15468 -
    ...  Adds checking BM release for DC fallbacks SBTS
    ...  - 24.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17980 -
    ...  Changes timeout for fault 4001 and adds this timeout to Variables
    ...  - 08.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18645 -
    ...  Adds reset connection to admin and infomodel after fallback
    ...  - 27.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18888 - Fix problem with duplicated KW names
    ...  - 06.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-18664 - Adds support for reset due to fault 4001
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-9883.png

    Set Tags    PHASE-COMPA    CA-SWM    OWNER-dominik.jesariew@nokia.com    AUTHOR-wojciech.sikora@nokia.com
    ...         SW-SBTS17    SW-SBTS18    SW-SBTS18SP    SW-SBTS18A    SW-SBTS19
    ...         FEATURE-RP000938    FEATURE-RP001498    FEATURE-RP001621

    Pre-Conditions
    Step 0: Suite configuration
    Step 1: Check active and passive sw version
    Step 2: Software fallback
    Step 3: Wait till BTS is stable
    Step 4: Check sw after fallback
    Step 5: Fault 4082 verification
    Step 6: Check if BTS is onair with cell degraded
    Step 7: recover env to clear 4082 by upgrade sw

Pre-Conditions
    [Documentation]    Short description.
    Change parameter to disconnect netact with BTS
    Log    This part of doing upgrade to tested package and downgrade branch package to make sure the meta difference between active and passive
    @{crt_alarms}    create list    4082  23  1815
    set test variable    ${crt_alarms}
    Add CRT Alarms And Initial WatchAlarm    ${crt_alarms}
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

Step 0: Suite configuration
    [Documentation]    Short description.
    Log step header  Step 0: Suite configuration
    Setup hran compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Set global variable  ${ACTIVE_SW_PATTERN}   SBTS\\d
    Set global variable  ${PASSIVE_SW_PATTERN}  SBTS\\d
    Verify SSH connection and enable if necessary
    ${sm_variant}=  Get SM variant
    Set test variable  ${sm_variant}
    ${GSM_esm}  Run keyword and return status  Checking if GSM on ESM
    Log  GSM cells on ESM: ${GSM_esm}  console=${TRUE}
    ${WCDMA_esm}  Run keyword and return status  Checking if WCDMA on ESM
    Log  WCDMA cells on ESM: ${WCDMA_esm}  console=${TRUE}
    Set test variable  ${GSM_esm}
    Set test variable  ${WCDMA_esm}

Step 1: Check active and passive sw version
    [Documentation]    Short description.
    Log step header  Step 1: Check active and passive sw version
    ${active_sw_before_master}  ${passive_sw_before_master}=  Infomodel Get SW Versions  module=MSM
    ${active_sw_before_ext}  ${passive_sw_before_ext}=  Infomodel Get SW Versions  module=ESM
    Set tags for software  SW_BEFORE_FALLBACK_MASTER  ${active_sw_before_master}  ${passive_sw_before_master}
    Set tags for software  SW_BEFORE_FALLBACK_EXTENSION  ${active_sw_before_ext}  ${passive_sw_before_ext}
    Check if software match software pattern  ${active_sw_before_master}  ${ACTIVE_SW_PATTERN}
    Check if software match software pattern  ${passive_sw_before_master}  ${PASSIVE_SW_PATTERN}
    Check if software match software pattern  ${active_sw_before_ext}  ${ACTIVE_SW_PATTERN}
    Check if software match software pattern  ${passive_sw_before_ext}  ${PASSIVE_SW_PATTERN}
    Set test variable  ${active_sw_before_master}
    Set test variable  ${passive_sw_before_master}
    Set test variable  ${active_sw_before_ext}
    Set test variable  ${passive_sw_before_ext}

Step 2: Software fallback
    [Documentation]    Short description.
    Log step header  Step 2: Software fallback
    Log  Checking hardware version  console=${TRUE}
    Software Fallback secondary   ${sm_variant[1]}     reset_command
    Software Fallback   ${sm_variant[0]}     reset_command

Step 3: Wait till BTS is stable
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
    Log  Wait till Secondary core is stable
    ${ping_status}=  Check If Target Is Stable  fct-4a    min_uptime=200    max_downtime=360
    ...  remote_host=192.168.255.129    remote_host_username=toor4nsn
    ...  remote_host_password=oZPS0POrRieRtu    timeout=1400
    Run keyword if    not ${ping_status}  Log  Secondary core lost ping after fallback.

Step 4: Check sw after fallback
    [Documentation]    Short description.
    Log step header  Step 4: Check SW after fallback
    ${sw_after_msm_dict}  taf.sbts.oam.coam.admin.get software info
    ${active_sw_after_master}  get from dictionary  ${sw_after_msm_dict}  Active SW version
    ${passive_sw_after_master}  get from dictionary  ${sw_after_msm_dict}  Passive SW version
    Log  SW MSM${\n}active SW :${active_sw_after_master}${\n}passive SW: ${passive_sw_after_master}${\n}SW ESM  console=${True}
    ${active_sw_after_ext}  ${passive_sw_after_ext}=  Infomodel Get SW Versions  module=ESM
    Set test variable  ${active_sw_after_master}
    Set test variable  ${active_sw_after_ext}
    #add row  sw_table  After Master  ${active_sw_after_master}  ${passive_sw_after_master}
    Set tags for software  SW_AFTER_FALLBACK_MASTER  ${active_sw_after_master}  ${passive_sw_after_master}
    Check if software match software pattern  ${active_sw_after_master}  ${passive_sw_before_master}
    Check if software match software pattern  ${passive_sw_after_master}  ${active_sw_before_master}
    Check if software match software pattern  ${active_sw_after_ext}  ${passive_sw_before_ext}
    Check if software match software pattern  ${passive_sw_after_ext}  ${active_sw_before_ext}
    Log  Active SW after fallback is correct on MSM and ESM console=${TRUE}

Step 5: Fault 4082 verification
    [Documentation]    Short description.
    Log step header  Step 5: Fault 4082 verification
    ${EXPECTED_ALARM1}=     Run Keyword if     'ASIB' in "${tl.tl_cloud_topology}" and 'FSMF' in "${tl.tl_cloud_topology}"
    ...    Create Dictionary
    ...    faultName=SW fallback  faultId=4082  severity=Major  notifier=MRBTS-${BTS_INFO.ID}/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1  number=7111
    ...    ELSE
    ...    Create Dictionary
    ...    faultName=SW fallback  faultId=4082  severity=Major  notifier=MRBTS-${BTS_INFO.ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1  number=7111
    ${EXPECTED_ALARM2}=     Run Keyword if     'ASIB' in "${tl.tl_cloud_topology}" and 'FSMF' in "${tl.tl_cloud_topology}"
    ...    Create Dictionary
    ...    faultName=SW fallback  faultId=4082  severity=Major  notifier=MRBTS-${BTS_INFO.ID}/EQM_R-4/APEQM_R-1/CABINET_R-2/SMOD_R-1  number=7111
    ...    ELSE
    ...    Create Dictionary
    ...    faultName=SW fallback  faultId=4082  severity=Major  notifier=MRBTS-${BTS_INFO.ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-2  number=7111
    ${ignored_ALARM1}=     Create Dictionary  faultId=6327  severity=Major
    ${ignored_ALARM2}=     Create Dictionary  faultId=7300  severity=Major
    ${ignored_ALARM3}=     Create Dictionary  faultId=7319  severity=Major
    ${EXPECTED}=            Create List  ${EXPECTED_ALARM1}  ${EXPECTED_ALARM2}
    ${ignored_patterns}=    Create List  ${ignored_ALARM1}  ${ignored_ALARM2}  ${ignored_ALARM3}
    ${CRITICAL_ALARM1}=     Create Dictionary  severity=Major|Critical
    ${CRITICAL}=            Create List  ${CRITICAL_ALARM1}
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms  expected_patterns=${EXPECTED}  critical_patterns=${CRITICAL}
    ...  ignored_patterns=${ignored_patterns}  timeout=300
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Fail  No Fault 4082 with Major severity found or other Major|Critical occured
    ...  ELSE IF  ${alarms_msg}
    ...  Set Test Restriction  Fault 4082 active on BTS with severity=Major, but some minor faults found: ${alarms_msg}
    ...  ELSE
    ...  Log  Alarm with Fault 4082 active on BTS with severity=Major. No other active alarms.  console=${TRUE}

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
    Log step header  Step 7: recover env to clear 4082 by upgrade sw
    Change parameter to connect netact with BTS
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
    ${sw_rec_path}=    Get upgrade path    ${active_sw_bef_rec}    ${passive_sw_bef_rec}
    ...  ${release_list_1}    ${release_list_2}    ${release_list_3}
    ${sw_rec}=    Common_Find SW name    ${sw_rec_path}
    taf.sbts.oam.coam.admin.update software    ${sw_rec}    True    ${SW Update Timeout}

check BTS is onair after update to tested software
    [Documentation]    Short description.
    ${ping loss status}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}    timeout=900
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
    Wait Until Keyword Succeeds    5 min    15 sec     taf.sbts.oam.coam.admin.Setup Admin
                                                        ...  bts_host=192.168.255.129
                                                        ...  bts_port=443
                                                        ...  username=Nemuadmin
                                                        ...  password=nemuuser
                                                        ...  use_ssl=TRUE
                                                        ...  alias=recovery
                                                        ...  update_interval=1000
                                                        ...  admin_api_log_dir=${Temp Logs Dir}
    Wait until keyword succeeds  15 min  30 sec  Check SBTS SOAM cells and modules
    Log Important Message  BTS is OnAir, all cells and modules are in expected states
    taf.sbts.oam.coam.admin.teardown admin    alias=recovery

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
    Run keyword if  ${ping_loss_status_ESM_after_ESM_up}==${False}  Fail  Ping has not been lost within timeout
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

Check Fault 4001 after update
    [Documentation]    Short description.
    ${EXPECTED_ALARM1}=     Create Dictionary  faultId=4001
    ${EXPECTED}=            Create List  ${EXPECTED_ALARM1}
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms  expected_patterns=${EXPECTED}  print_alarms=${FALSE}
    Run Keyword If  '${alarms_status}'=='FAIL'  Fail

Reset after 4001
    [Documentation]    Short description.
    Log  Waiting for BTS reset...  console=${TRUE}
    ${status}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=180
    Run keyword if  '${status}'=='False'  taf.sbts.oam.coam.admin.Reset Site  600
    Log  Waiting for target to be reachable  console=${TRUE}
    Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=180
    Log  Waiting for target to be stable  console=${TRUE}
    Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=240  max_downtime=100  timeout=400

BM available
    [Documentation]    Short description.
    Run keyword if  ${META_CHECK}==${TRUE} and ${BM_CHECK}==${TRUE}   Set test norun
    ...  METAs and BMs releases of passive and active SW are the same${\n}TC: SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_INCONS_RLC should be run instead
    ...  fail_test=${False}
    ...  ELSE IF  ${META_CHECK}==${TRUE} and ${BM_CHECK}==${FALSE}
    ...  Log  METAs of passive and active SW are the same, but BM releases are different, consistent fallback is possible  console=${TRUE}
    ...  ELSE IF  ${META_CHECK}==${FALSE}
    ...  Log  METAs of passive and active SW are the different, consistent fallback is possible  console=${TRUE}

BM unavailable
    [Documentation]    Short description.
    Set test restriction  Unable to get BM release (==MAIN or EMPTY) - CHECK LOGS!!
    Log Important Message  Set test restriction - Unable to get BM release (==MAIN or EMPTY) - CHECK LOGS!!
    Run keyword if  ${META_CHECK}==${TRUE}  Set test norun
    ...  METAs of passive and active SW are the same${\n}TC: SWM__DC_SBTS_SOAM_fallback_to_SBTS_SOAM_INCONS_RLC should be run instead
    ...  fail_test=${False}
    ...  ELSE IF  ${META_CHECK}==${FALSE}
    ...  Log  METAs of passive and active SW are the different, consistent fallback is possible  console=${TRUE}

TC_Custom Setup
    [Documentation]    Short description.
    Common Test Setup
    Delete_uboot_parameters

TC_Custom Teardown_table
    [Documentation]    Short description.
#    Change parameter to connect netact with BTS
    Run keywords    Common Test Teardown    AND    Log    Nothing    #Log table    sw_table
    Add_uboot_parameters
