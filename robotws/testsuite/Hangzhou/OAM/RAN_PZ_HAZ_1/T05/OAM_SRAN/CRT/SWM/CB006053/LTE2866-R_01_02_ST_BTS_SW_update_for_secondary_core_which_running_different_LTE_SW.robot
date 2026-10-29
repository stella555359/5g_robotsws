*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource   ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource   ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot
Resource   ../CB007500/CB007500.robot
Library    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/extract.py
Library    taf.sbts.oam.coam.admin
Library    String
Library     ../../../resources/lib/SSHExecutor.py
Library    DateTime
Library    OperatingSystem
Library    ute_async
Library    taf.hw.pdu  WITH NAME  pdu

*** Variables ***
${sw_package_path}     /home/ute/btsauto/TARGET_SW
${SW Update Timeout}                        1800  # Given in seconds; That is a timeout for SW download and activation
${ping_loss_timeout}                         240  # Timeout for ping loss during reset
${ping_regain_timeout}                       900  # Timeout for ping regain during reset
${restore_timeout}                           240  # Timeout for cells to go OnAir after last update
${esm_ip}                        192.168.255.119  # ESM trs ip
${FAULT_4001_TIMEOUT}                         15  # How long should KW wait for fault 4001 [in minutes]
#${PC_IP2}                 ${tl.test_pcs[1].default_ssh_connection_details.addr}


*** Keywords ***
TC_LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW_R3R4
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-9883
    ...
    ...  *****************
    ...  *****************
    ...  Basic information
    ...  ********************
    ...  **Request ID:** TAT-9883
    ...  *****************
    ...  Main purpose of TC is checking fallback functionality of SBTS SW in dual core configuration:
    ...  fallback from SBTS_SOAM to SBTS_SOAM
    ...
    ...      ...
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
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-9883.png

    Change parameter to connect netact with BTS
    Step 1: Check active and passive sw version
    Step 2: Import Target SW To NA
    Step 3: configret to DNR
    Step 5: Upgrade primary core
    Step 6: Critical Fault 23 Verification
    Step 7: Check provision triggered by NE
    Step 8: Check if all cells are onair
    Step 9: Check BTS is onair
    #Step 10: Check If Fault 23 cleared on SMOD

Step 1: Check active and passive sw version
    Log step header  Step 1: Check active and passive sw version
    @{crt_alarms}    create list    4352  23  17  10
    set test variable    ${crt_alarms}
    Add CRT Alarms And Initial WatchAlarm    ${crt_alarms}
    ${active_sw_before_master}  ${passive_sw_before_master}=  Infomodel Get SW Versions  module=MSM
    ${release_NUM}=    should match regexp     ${active_sw_before_master}    SBTS\\d+..
    set test variable    ${release_NUM}

Step 2: Import Target SW To NA
    [Documentation]
    ...  choose the target package to upgrade, first import to netact, then upgrade by netact
    ${target_path}=    Common_Find SW name    ${Target SW dir}
    Set test variable    ${target_path}
    ${package name}  OperatingSystem.List files in directory    ${Target SW dir}
    ${package name}    set variable    ${package_name[0]}
    ${package_release}=    Find release version     ${package name}    ${release_list_1}
    ...  ${release_list_2}    ${release_list_3}
    ${package_release_changed}    run keyword if    '${target_release}'=='SBTS00'
    ...  Replace String Using Regexp    ${package_release}    SBTS00   ${release_NUM}
    ...    ELSE    set variable    ${package_release}
    set test variable    ${package_release_changed}
    @{sw_release_new}    Split String    ${package_release_changed}     _
    ${collect_snapshot}    set variable    never
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}=  Choose_Mid_Server4Netact  ${NETACT_SERVER_INFO.IP}
    build_download_upload_on_remote_server_and_import_to_Netact  target_sw=${package_release}
                                                            ...  release_NUM=${release_NUM}
                                                            ...  remote_ip=${Mid_Server}
                                                            ...  remote_usr=${Mid_Server_usr}
                                                            ...  remote_pwd=${Mid_Server_pwd}
    ${collect_snapshot}    set variable    failed_verdict

Step 3: configret to DNR
    Log step header  Step 3: configret to DNR
    Start Admin    username=Nemuadmin    password=nemuuser    alias=hfv
    run keyword and ignore error    taf.sbts.oam.coam.admin.Reset Configuration    remove_operator_certificates=False
    ...    remove_user_account_credentials=False    alias=hfv    timeout=800    reset_type=ConfigurationWithDiagnosticAndRecoverySw
    run keyword and ignore error    taf.sbts.oam.coam.admin.Teardown Admin    alias=hfv
    sleep    300s
    #Connected to D&RSW BTS by RC


Step 5: Upgrade primary core
    Log Step Header    installation SW from FDSW
    Connected to D&RSW BTS by RC
    ${activeslotID}    fdsw.get_active_sw_partition
    fdsw.software_update    sw_pkg_path=${SW_path_package}    sw_slot_id=1    timeout=2000     activate=${True}
    #run keyword and ignore error    fdsw.teardown
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}    timeout=200
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful plan activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful plan activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}   timeout=600
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
     Wait Until Keyword Succeeds    30min     30s        taf.sbts.oam.coam.admin.Reset Admin    alias=default
#    ${SW_Info}    Wait Until Keyword Succeeds    20min     30s     taf.sbts.oam.coam.admin.get_software_info    timeout=30
#    ${Active_SW}=  Get from dictionary  ${SW_Info}  Active SW version
#    ${SWRelease}    Should Match Regexp    ${Active_SW}    SBTS[0-9]{2}[A-Z]{0,1}[0-9]{0,1}
    wait until keyword succeeds    15min    30s    _Perform Full Commision By Admin
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/node1/BTS_${tl_configuration}_${release_NUM}.xml    ${BTS_INFO.ID}
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}    timeout=120
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful plan activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful plan activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}   timeout=600
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}


Step 6: Critical Fault 23 Verification
    Log step header  Step 7: Fault 23 for SMOD verification
    Log  Waiting for fault 23 on SMOD...  console=yes
    FOR  ${run}  IN RANGE  1  300
        ${is_fault_active_SMOD}=  Check If Fault 23 present on ESM
        Run keyword if    '${is_fault_active_SMOD}'=='True'    exit for loop
        sleep    1s
    END
    Set test variable  ${is_fault_active_SMOD}
    Log  Fault 23 For SMOD active: ${is_fault_active_SMOD}  console=${TRUE}

Step 7: Check provision triggered by NE
    wait until keyword succeeds    90min    10s    _check provision triggered by NE
    _check SW version after provision

Step 8: Check if all cells are onair
    Log step header  Step 8: Check if all cells are onair
    Log  Checking if BTS is onair ...  console=${True}
    Log  ${\n}Checking cells operationalState...  console=${True}
    sleep    600s
    ${cells_status}=  Verify all cells states  Check if all cells are onair
    Run keyword if  ${cells_status}
    ...  Log  ${\n}All cells operationalState is 'Enabled'  console=${True}
 	...  ELSE  Run keywords  SW update for RMODs
    ${cells_status}=  Verify all cells states  Check if all cells are onair
    Run keyword if  ${cells_status}
    ...  Log  ${\n}All cells operationalState is 'Enabled'  console=${True}
    ...  ELSE
    ...  Fail  Not all cells operationalState is 'Enabled'. Check logs cells_status=${cells_status}

Step 9: Check BTS is onair
    sleep    300s
    Wait Until Keyword Succeeds    10min   60   Verify BTS states

Step 10: Check If Fault 23 cleared on SMOD
    Check If Fault 23 cleared on SMOD

_check SW version after provision
    Setup eNB Fsm Access    alias=enb1
    ${active_version_after}=    Get Enb Sw Version    active    alias=enb1
    Teardown Enb Fsm Access    alias=enb1
    ${release_name}    Get Substring    ${package_release_changed}    12
    Should Contain    ${active_version_after}    ${release_name}

Find release version
    [Arguments]    ${package name}        ${release_1}    ${release_2}    ${release_3}
    ${release}=    set variable if    '${release_1}' in '${package name}'    ${release_1}
    ...    '${release_2}' in '${package name}'    ${release_2}
    ...    '${release_3}' in '${package name}'    ${release_3}
    [Return]    ${release}
Common_Find SW name
    [Arguments]    ${SW_PATH}
    ${package name}  OperatingSystem.List files in directory  ${SW_PATH}
    should not be empty  ${package name}  Required package not present in ${SW_PATH}
    ${SW_PATH_package}=  Join Path 	${SW_PATH}  ${package name[0]}
    OperatingSystem.File should exist  ${SW_PATH_package}
    [Return]    ${SW_PATH_package}

check BTS is onair after update to tested software
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
    ${ping stable status}  Run keyword and return status  Check If Target Is Stable  ${SMOD1['TRS_IP']}
    ...  min_uptime=360  max_downtime=0  timeout=361
    Run keyword if  ${ping stable status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for 60 seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=${TRUE}

Check if modules states ok after sw updates
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
    ${cells_state}=  Run keyword and return status
    ...  Wait Until Keyword Succeeds  ${restore_timeout}  5s  Fail if not all cells are on air
    [Return]  ${cells_state}

Check If Fault 23 present on ESM
    [Documentation]  If active alarm exist and is Major return True otherwise return False
    @{active_alarms} =  taf.sbts.oam.coam.admin.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=yes
        ${notifier_is_smod}  run keyword and return status  should contain  ${alarm.notifier}  SMOD_R
        Run Keyword If  '${alarm.faultId}'=='23' and '${alarm.severity}'=='Critical' and ${notifier_is_smod}
        ...  Return From Keyword  ${TRUE}
    END
    Log  Out of loop false  console=yes
    [Return]  ${FALSE}

Check If Fault 23 cleared on SMOD
    [Documentation]  If fault 23 on SMOD is not cleared return FALSE
    @{active_alarms} =  taf.sbts.oam.coam.admin.Get Active Alarms
    Log  ${\n}Active alarms on BTS:  console=${TRUE}
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=yes
        ${notifier_is_smod}  run keyword and return status  should contain  ${alarm.notifier}  SMOD_R
        Run Keyword If  '${alarm.faultId}'=='23' and ${notifier_is_smod}
        ...  Fail  Alarm with fault 23 on ESM active
    END
    Log  ${\n}Fault23 cleared on ESM  console=yes

Check If Fault 23 present after update
    Check if modules states ok after sw updates
    ${EXPECTED_ALARM1}=     Create Dictionary  faultId=4082
    ${EXPECTED}=            Create List  ${EXPECTED_ALARM1}
    ${CRITICAL_ALARM1}=     Create Dictionary  faultId=23
    ${CRITICAL}=            Create List  ${CRITICAL_ALARM1}
    Admin Check Active Alarms  expected_patterns=${EXPECTED}  critical_patterns=${CRITICAL}

Check If Fault 23 is present on RMODs
    [Documentation]  If active alarm exists and is Critical return True otherwise return False
    @{active_alarms}  taf.sbts.oam.coam.admin.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=${TRUE}
        ${expected_notifier}  Run keyword and return status  Should contain  ${alarm.notifier}  RMOD_R
        Run Keyword If  '${alarm.faultId}'=='23' and ${expected_notifier}
        ...  Return From Keyword  ${TRUE}
    END
    Fail  Fault 23 is not present on any RMOD

Sw update on RMODs
    Log  Start SW update on RMODs...  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  sw_package=${target_path}  should_activate=${TRUE}
    ...  timeout=${SW_UPDATE_TIMEOUT}
#    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    Log  Wait until all rmods are available  console=${TRUE}
    Wait until keyword succeeds  30 min  30 sec  Check if all RMODs are available after 23 cancel

Check if all cells are onair
    ${cells_GSM_onair}=  Verify cells  GSM
    ...  expected_states=operationalState=${_Enabled},usageState=Active  scf_check=${scf_parser_started}
    ${cells_WCDMA_onair}=  Verify cells  WCDMA
    ...  expected_states=operationalState=${_Enabled}, usageState=Active  scf_check=${scf_parser_started}
    ${cells_LTE_onair}=   Verify cells  LTE
    ...  expected_states=operationalState=${_Enabled}, blockingState=Unblocked  scf_check=${scf_parser_started}
    ${cells_NR_onair}=  Verify cells  NR
    ...  expected_states=operationalState=${_Enabled}, blockingState=Unblocked   scf_check=${scf_parser_started}
    ${celling_status}=    Evaluate    ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair} and ${cells_NR_onair}
    Run keyword if  not ${celling_status}
    ...  Fail  GSM:${cells_GSM_onair} WCDMA:${cells_WCDMA_onair} LTE:${cells_LTE_onair} NR:${cells_NR_onair}

SW update for RMODs
    sleep    120
    ${is_fault_23_on_RMODs}  Run keyword and return status  Wait Until Keyword Succeeds
    ...  20min  30 sec  Check If Fault 23 is present on RMODs
    Run keyword if  ${is_fault_23_on_RMODs}  Sw update on RMODs
    ...  ELSE  Log  Fault 23 on RMODs is not present (SW update is not needed)  console=${TRUE}
    sleep    300

Verify all cells states
    [Arguments]  ${cells_state_check}
    ${cells_state}=  Run keyword and return status  Wait Until Keyword Succeeds  20min  5s  ${cells_state_check}
    [Return]  ${cells_state}

Connected to D&RSW BTS by RC
    [Arguments]    ${ip_address}=192.168.255.129   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser
    ...    ${auto_discover}=True    ${secure}=True    ${name}=default
    taf.fdsw.rc.connect to    ip_address=${ip_address}   port=${port}    username=${username}    password=${password}
    ...  auto_discover=${auto_discover}    secure=${secure}    name=${name}
    Log  FDSW RC Connected to BTS successfully with IP ${ip_address}
    CB007500_enable_SSH_Access_On_RC

Check if all RMODs are available after 23 cancel
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Assert Every    RMOD    availabilityStatus!=regex"NotInstalled|Offline"
    ${scf_rmods}           Get Radios
    ${scf_count_rmods}     Get length  ${scf_rmods}
    ${runtime_rmods}       taf.sbts.oam.coam.admin.Get ids for all  RMOD
    ${final_status}        Evaluate  ${scf_count_rmods}==len(${runtime_rmods})
    Run keyword if    not ${final_status}  Fail  Not all radio modules are available

TC_Custom Setup
    Common Test Setup
    Delete_uboot_parameters
TC_Custom Teardown
    Common Test Teardown
    Add_uboot_parameters
