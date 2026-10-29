*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
#Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_pdu.robot
Library    taf.sbts.oam.coam.admin
Library    ute_admin_infomodel
Library    OperatingSystem

#Library    hran_tools
#Library    hran_file_operations

Library    ute_async
#Library    hran_ims
Library    Collections


*** Variables ***
${Target SW name}                  ${None}
# SW package name. If not given, TC will choose newest package in a directory.
${Target SW dir}                   /home/ute/btsauto/TARGET_SW
# Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SW Update Timeout}               3600
# Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}               240                            # Timeout for ping loss during reset
${Ping regain timeout}             600                            # Timeout for ping regain during reset
${Test Timeout}                    150                             # Test timeout (in minutes)
${EXPECTED_BTS_STATUS}             OnAir
# Expected BTS state before TC starts
${onAir Check Number}              60
# Number of checks for proceduralStatus: onAir after RMODs reset is complete; check interval = 10s
${RM_DETECTION_TIMEOUT}            25 min
# Timeout for all connected RMs detection (in minutes)
${HW_OFF_ID_LIST}
# Module names as defined in interfaces.yaml. Modules shall be separated by comas (eg. SMOD_K11232234,RMOD_L11232234)
# Undefined names that are in interfaces.yaml will be turned ON
${NUMBER_OF_RMODS_TO_TURN_OFF}     1
# How many RMODs should be turned off (random choice)


*** Keywords ***
TC__SWM__SW_update_for_RMOD_with_fault_23
    [Documentation]
    ...  ********************
    ...  1. Basic information
    ...  ********************
    ...
    ...  **Request ID:** TAT-17630
    ...
    ...  ***********************************************************
    ...  2. Description in reStructuredText format on what is tested
    ...  ***********************************************************
    ...
    ...  TC for genereting fault23 on RMODS (turn off RMODs -> SW update -> turn ON RMODs) and updating RMOD software
    ...
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...
    ...  - 08.11.2019 - initial creation
    ...  - 11.02.2020 - TAT-1900 Change values of 'max_downtime' and 'timeout' in Step6:KW:Check If Target Is Stable
    ...
    ...  **********************
    ...  4. Test case flowchart
    ...  **********************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/SWM__SW_update_for_RMOD_with_fault_23.png

    #[Timeout]    ${Test Timeout} minutes
    Set Tags    OWNER-mariusz.bak@nokia.com    AUTHOR-wojciech.sikora@nokia.com    MAINTAINER-wojciech.sikora@nokia.com
    ...    GROUP_IN_CHARGE-WRO_7_Vrf    CA-SWM    PHASE-CIT    SW-SBTS17    SW-SBTS18    SW-SBTS19
    ...    FEATURE-RP001486_RP000912    FEATURE-RP001145_RP000912

    Change parameter to disconnect netact with BTS
    prepare N_1 package on SBTS    sw_release=26R1    target_path=/home/ute/btsauto/
    Change parameter to disconnect netact with BTS
    step1: Check SW versions
    step2: Turn OFF RMODs on PDU
    step3: SW update
    step4: Turn ON RMODs on PDU
    step5: Check if fault 23 is present
    step6: Update SW on RMODs
    step7: Check if BTS onAir
    step8: Check if fault 23 absent
    step9: Check if all cells onAir
    Change parameter to connect netact with BTS

prepare N_1 package on SBTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...        ${target_path}: <description>
    [Arguments]    ${sw_release}=25R3    ${target_path}=/home/ute/btsauto/
#    ${build_num}  Get P7P8 Build Info    ${sw_release}
    ${N_1_pkg_list}   Get Enb     SBTS${sw_release}
#    ${N_1_pkg_num}    set variable if  '${build_num}'==''  ${N_1_pkg_list[-1]}  ${build_num}
    ${N_1_pkg_num}    set variable  ${N_1_pkg_list[1]}
    ${fullpath}  Download_Specify_Build_By_Aria   enb_build=${N_1_pkg_num}  Package_type=Basic  target_path=${target_path}
    prepare pre release build on SBTS    release=${sw_release}   pkg_full_path=${fullpath}

Downgrade to old package
    [Documentation]    Short description.
    Log    This part to download to lower bts version, to prepare for triggering fault23
    _Get Scf By Admin    /home/ute/BACK_SCF.xml
    Verify BTS proceduralState    OnAir
#    taf.sbts.oam.coam.admin.Reset Configuration    True    False    timeout=800    alias=default
    Reset configuration by config removal from BTS
    ${lower_version}=    get enb    SBTS23R2
    ${Down_path}    Download_Specify_Build_By_Aria    ${lower_version[-1]}    Basic    /home/ute/
    set test variable  ${Down_path}
    ${ping_status_after reset}  Check If Target Is Stable
    ...  ip=192.168.255.129  min_uptime=300  max_downtime=600  timeout=1800
    Run keyword if    not ${ping_status_after reset}  FAIL  BTS is not stable after downgrade.
    ${update_result}=    Run keyword and return status    SW update    ${Down_path}
    Run keyword if    '${update_result}'=='False'    SW update    ${Down_path}
    ${ping_status}  Check If Target Is Stable  ip=192.168.255.129  min_uptime=300  max_downtime=900  timeout=1800
    Restore login by json removal from BTS
    ${ping_status}  Check If Target Is Stable  ip=192.168.255.129  min_uptime=300  max_downtime=900  timeout=1800
    Run keyword if    not ${ping_status}  FAIL  BTS is not stable after downgrade.
    Restore login by json removal from BTS
    ${scf_full_path}    set variable
    ...  /home/ute/testline_configuration/${host_name}/node1/BTS_${tl_configuration}_${lower_version}.xml
    set test variable    ${scf_full_path}
    ${admin_working_state}  Run keyword and return status  hran_admin.Admin and Infomodel connections reset
    ...  reset_req=${TRUE}
    Run keyword if    not ${admin_working_state}  Fail
    ...  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}
    wait until keyword succeeds    15min    30s    _Perform Full Commision By Admin
    ...   ${scf_full_path}    ${BTS_INFO.ID}
    wait until keyword succeeds    10min    30s    Check BTS State By Admin    OnAir

step1: Check SW versions
    [Documentation]    Short description.
    Log Step Header  step1: Check SW versions
    ${Active SW}   Infomodel Get Active SW Version
    Set global variable  ${Active SW}
    ${Passive SW}  Infomodel Get Passive SW Version
    Log  Active software package is: ${Active SW}  console=${TRUE}
    Log  Passive software package is: ${Passive SW}  console=${TRUE}
    Run Keyword If  '${Active SW}'==''  Log  Active sw version was not readable  level=ERROR    console=${TRUE}
    Run Keyword If  '${Passive SW}'==''  Log  Passive sw version was not readable  level=WARN    console=${TRUE}
    Find path to SW package
    Run Keyword If  '${Target SW path}'== ${None}   Fail  No path to SW build provided

step1_1: Reconfig allowed alarm by watchdog
    [Documentation]    Short description.
    @{allowed_alarms}    create list    10    23
    Add CRT Alarms And Initial WatchAlarm    ${allowed_alarms}

step2: Turn OFF RMODs on PDU
    [Documentation]    Short description.
    Log Step Header  step2: Turn OFF RMODs on PDU
    ${hw_off_id_list}  Split String  ${HW_OFF_ID_LIST}  ,
    #Run Keyword If  '${hw_off_id_list[0]}'==''  Choose RMODs on random
    Run Keyword If  '${hw_off_id_list[0]}'==''  Traverse RMODs Exclude Obsai
    ${NUMBER_OF_RMODS_TO_TURN_OFF}  Get Length	${hw_off_id_list}
    set test variable  ${NUMBER_OF_RMODS_TO_TURN_OFF}
    Log Important Message
    ...  List of RMODs to be turned OFF:${hw_off_id_list}${\n}How many:${NUMBER_OF_RMODS_TO_TURN_OFF} module/s
    State change if needed  ${hw_off_id_list}  Off
    sleep    120
    Log  Check if turned off RMODs are disabled in ADMIN  console=${TRUE}
    Check if right amount RMODs disabled
    Log  All turned off RMODs are disabled  console=${TRUE}

step3: SW update
    [Documentation]    Short description.
    Log Step Header  step3: SW update
    Log  Will now perform software update  console=${TRUE}
    wait until keyword succeeds      25min    30s
    ...    taf.sbts.oam.coam.admin.Update Software  ${target_sw_path}  True  ${SW Update Timeout}
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable
    ...  hostname=${SMOD1['TRS_IP']}  timeout=${Ping loss timeout}
    Run keyword if  ${ping loss status}==${FALSE}   Fail   BTS RESET after successful sw update DID NOT OCCUR
    ...  ELSE                   Log to console with time   BTS is resetting after successful sw update
    ${ping regain status}  Run keyword and return status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping regain timeout}
    Run keyword if  ${ping regain status}==${False}  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE                              Log to console with time   Ping regained
    Log  Will now check if BTS ping is stable for: 200 seconds - Please Wait...  console=${TRUE}
    ${ping stable status}  Run keyword and return status  Check If Target Is Stable
    ...  ${SMOD1['TRS_IP']}  min_uptime=200  max_downtime=0  timeout=500
    Run keyword if  ${ping stable status}==${False}  Set Test Failed  Ping has not been available for 200 seconds
    ...  ELSE                              Log to console with time   Ping stable for 200 sec
    Wait Until Keyword Succeeds  5 min  10 sec  Fail if connection with admin is not available

step4: Turn ON RMODs on PDU
    [Documentation]    Short description.
    Log Step Header  step4: Turn ON RMODs on PDU
    State change if needed  ${hw_off_id_list}  On
    Log  Will now check if all radio modules are available...  console=${TRUE}

step5: Check if fault 23 is present
    [Documentation]    Short description.
    Log Step Header  step5: Check if fault 23 is present
    ${Radios_with_fault_23_dn_list}  Create list
    Set Test Variable  ${RADIOS_WITH_FAULT_23_LIST}  ${Radios_with_fault_23_dn_list}
    Log  Will now check if fault 23 if present on correct RMOD/s...  console=${TRUE}
    ${fault_23_check}  Wait until keyword succeeds  ${RM_DETECTION_TIMEOUT}  30 sec  Check fault 23 for all rmods
    Run keyword if    not ${fault_23_check}  Set test norun  No fault 23 found!  fail_test=${FALSE}
    Log  Fault 23 has been detected for following RMODs: ${RADIOS_WITH_FAULT_23_LIST}  console=${TRUE}
    sleep    900

step6: Update SW on RMODs
    [Documentation]    Short description.
    Log Step Header  step6: Update SW on RMODs
    Log  Will now start async stability ping check on SMOD  console=${TRUE}
    Start async  tool_ping  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=5  timeout=370
    Log  Will now perform software update  console=${TRUE}
    ${sw_download_result}  ${sw_download_msg}  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${Target SW path}  ${FALSE}  ${SW Update Timeout}
    Run keyword if  '${sw_download_result}'=='FAIL'  Set Test Failed  SW update failed. Reason: ${sw_download_msg}
    ${sw_update_result}  ${sw_update_msg}  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${Target SW path}  ${TRUE}  ${SW Update Timeout}
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  SW update failed. Reason: ${sw_update_msg}
    Log to console with time  SW update to RMOD/s done${\n}Result:${sw_update_result}${\n}Msg:${sw_update_msg}
    Log  Wait until rmods reset (operationalState Disabled)  console=${TRUE}RADIOS_WITH_FAULT_23_LIST
    Wait until keyword succeeds  10 min   15 sec  Check rmods operationalState Disabled  ${RADIOS_WITH_FAULT_23_LIST}
    Log to console with time  RMOD/s are resetting
    Log  Wait until rmods operationalState Enabled  console=${TRUE}
    Wait until keyword succeeds  20 min  30 sec  taf.sbts.oam.coam.admin.Assert Every
    ...  RMOD  operationalState=${_Enabled}

    Log to console with time  All RMOD/s operationalState=${_Enabled}
    Log  Wait for SMOD ping stability results  console=${TRUE}
    ${smod_ping_stable}  Wait for async result  timeout=365
    Log to console with time  SMOD stability ping check result: ${smod_ping_stable}
    Run keyword if    not ${smod_ping_stable}  Set Test Failed  SMOD lost ping during RMODs update
    [Teardown]  Stop async

step7: Check if BTS onAir
    [Documentation]    Short description.
    Log Step Header  step7: Check if BTS onAir
    Log  Will now check if BTS is onAir maximum of ${onAir Check Number} times with 10s interval.  console=${TRUE}
    FOR  ${run}  IN RANGE  1  ${onAir Check Number}
        ${BTS onAir}  taf.sbts.oam.coam.admin.Get Mrbts State
        Run keyword if  '${BTS onAir}' == 'OnAir'  Run Keywords  Log  BTS is onAir! Check attempt: ${run}
        ...  console=${TRUE}
        ...  AND  Return from keyword
        Sleep  10
    END
    Set Test Failed  BTS not onAir within timeout

step8: Check if fault 23 absent
    [Documentation]    Short description.
    Log Step Header  step8: Check if fault 23 absent
    ${Active Alarms}  taf.sbts.oam.coam.admin.Get Active Alarms
    ${Radios_with_fault_23_after}  Create list
    FOR  ${alarm}  IN  @{Active Alarms}
        Run keyword if   ${alarm}[faultId] == 23  Append to list  ${Radios_with_fault_23_after}  ${alarm}[notifier]
    END
    ${verification_status}  Run keyword and return status  Should be empty  ${Radios_with_fault_23_after}
    Run keyword if    not ${verification_status}  Set Test Failed
    ...  Fault 23 has been detected for following RMODS: ${Radios_with_fault_23_after}. Test failed.
    Log  Fault 23 has not been detected.  console=${TRUE}

step9: Check if all cells onAir
    [Documentation]    Short description.
    ${admin_working_state}  Run keyword and return status  hran_admin.Admin and Infomodel connections reset
    ...  reset_req=${TRUE}
    Run keyword if    not ${admin_working_state}  Fail
    ...  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}
    #Sleep    300
    ${ping_status}  Check If Target Is Stable  ip=192.168.255.129  min_uptime=300  max_downtime=300  timeout=900
    Log Step Header  step9: Check if all cells onAir
    Log  Will now wait for all cells to be online. Will check every 10 seconds untill success or TC timeout (30min).
    ...  console=${TRUE}
    FOR  ${run}  IN RANGE  1  420
        ${all_cell_status}    ${cell_state_table}   Run keyword and ignore error
        ...    Infomodel Check If All Objects From Path Are Online  ${dist_cells}
        Run keyword and ignore error    Run keyword if  '${all_cell_status}' == 'PASS'  Run Keywords
        ...  Log  All cells online! Check attempt: ${run}  console=${TRUE}
        ...  AND  Exit For Loop
    END
#    #Log table  ${cell_state_table}

Check rmods operationalState Disabled
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RADIOS_WITH_FAULT_23_LIST}: <description>
    [Arguments]  ${RADIOS_WITH_FAULT_23_LIST}
    ${rmods_parameters}  taf.sbts.oam.coam.admin.Get Parameters For All  RMOD
    FOR  ${radio_with_fault_23}  IN ZIP  ${RADIOS_WITH_FAULT_23_LIST}
        ${status}  Check If RMOD Is Disabled  ${radio_with_fault_23}  ${rmods_parameters}
        Run Keyword If  ${status}  Remove Values From List  ${RADIOS_WITH_FAULT_23_LIST}  ${radio_with_fault_23}
    END
    ${all_rmods_reset}  Run Keyword And Return Status  Should Be Empty  ${RADIOS_WITH_FAULT_23_LIST}
    Run keyword if    not ${all_rmods_reset}  Fail  Radios: ${RADIOS_WITH_FAULT_23_LIST} didn't reset

Check If RMOD Is Disabled
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${radio_with_fault_23}: <description>
    ...        ${rmods_parameters}: <description>
    ...
    ...    Returns:
    ...        ${FALSE}: <description>
    [Arguments]  ${radio_with_fault_23}  ${rmods_parameters}
    FOR  ${rmod_para}  IN  @{rmods_parameters}
        ${radio_23_cut}  Get Regexp Matches  ${radio_with_fault_23}
        ...  EQM_R-[0-9]+\/APEQM_R-[0-9]+\/RMOD_R-[0-9]+
        Run Keyword If  '${radio_23_cut[0]}' in '${rmod_para['id']}'  Log
        ...  ${rmod_para['id']} : ${rmod_para['operationalState']}  console=${TRUE}
        Return From Keyword If
        ...  '${radio_23_cut[0]}' in '${rmod_para['id']}' and 'isabled' in '${rmod_para['operationalState']}'  ${TRUE}
    END
    [Return]  ${FALSE}

State change if needed
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${hw_id_list}: <description>
    ...        ${pdu_target_state}: <description>
    [Arguments]  ${hw_id_list}  ${pdu_target_state}
    FOR  ${hw_id}  IN  @{hw_id_list}
      ${hw_state}  Pdu BTS Interface Get Status  ${hw_id}
      ${hw_target_state}  Set Variable  ${pdu_target_state}
      Run Keyword If  '${hw_state}'!='${hw_target_state}'  Change Pdu State And Check Status
      ...  ${hw_id}  ${hw_target_state}
      ...  ELSE  Log  ${hw_id} status already correct: ${hw_state}  console=${TRUE}
    END

Change Pdu State And Check Status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${hw_id}: <description>
    ...        ${interface_state}: <description>
    [Arguments]  ${hw_id}  ${interface_state}  #state value should be: On/Off
    Log  Turn Pdu ${interface_state} And Check Status for: ${hw_id}  console=${TRUE}
    Run Keyword If  '${interface_state}'=='Off'  Pdu BTS Interface Off  ${hw_id}
    ...  ELSE IF  '${interface_state}'=='On'
    ...  Pdu BTS Interface On  ${hw_id}
    Sleep  1
    ${hw_status}  Pdu BTS Interface Get Status  ${hw_id}
    Log  hw_status after ${interface_state} operation: ${hw_status}  console=${TRUE}

Choose RMODs on random
    [Documentation]    Short description.
    ${interfaces_modules}  Get Turned ON RMODs
    Log  All RMODs from interface.yaml:${\n}${interfaces_modules}  console=${TRUE}
    @{hw_off_id_list}  Evaluate  random.sample(${interfaces_modules},${NUMBER_OF_RMODS_TO_TURN_OFF})  random
    Set test variable  ${hw_off_id_list}

Traverse RMODs Exclude Obsai
    [Documentation]    Short description.
    ${interfaces_modules}  Get Turned ON RMODs
    Log  All RMODs from interface.yaml:${\n}${interfaces_modules}  console=${TRUE}
    @{hw_off_id_list}    Create List
    set test variable    ${hw_off_id_list}
    ${pattern}    set variable    RadioTypes.F[X,R,Z][A-Z]{2}
    ${pattern}    Convert to String    ${pattern}
    set test variable    ${pattern}
    FOR    ${item}   IN    @{interfaces_modules}
    ${res}    ${match}    Run keyword and ignore error
    ...  Should Match Regexp  "${INTERFACES['${item}']['RADIO_TYPE']}"    ${pattern}
    Log    ${match}
    Run keyword if    '${res}'=='FAIL'
    ...    Append to List    ${hw_off_id_list}    ${item}
    END

Check fault 23 for all rmods
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${TRUE}: <description>
    Log  ...checking...  console=${TRUE}
    ${Active Alarms}  taf.sbts.oam.coam.admin.Get Active Alarms
    FOR  ${alarm}  IN  @{Active Alarms}
        Run keyword if   ${alarm}[faultId] == 23  Append to list  ${RADIOS_WITH_FAULT_23_LIST}  /${alarm}[notifier]
    END
    ${fault_23_presence_status}  Run keyword and return status  Should not be empty  ${RADIOS_WITH_FAULT_23_LIST}
    ${RADIOS_WITH_FAULT_23_LIST}    remove duplicates    ${RADIOS_WITH_FAULT_23_LIST}
    ${length}    Get Length    ${RADIOS_WITH_FAULT_23_LIST}
#    ${list_len_check}  Run keyword and return status  Length Should Be
#    ...  ${RADIOS_WITH_FAULT_23_LIST}  ${NUMBER_OF_RMODS_TO_TURN_OFF}
    ${res}    Evaluate    ${length} >0 and ${length} <= ${NUMBER_OF_RMODS_TO_TURN_OFF}
    Run keyword if    ${res}     set test variable    ${list_len_check}    ${TRUE}
    ...    ELSE    Fail    fault23 not report on rmod
    Should Be True  ${fault_23_presence_status} and ${list_len_check}
    [Return]  ${TRUE}

Check if right amount RMODs disabled
    [Documentation]    Short description.
    Sleep  60
    ${turned_off_rmods_serial_numbers}  Create list
    FOR  ${rmods_id}  IN  @{hw_off_id_list}
        ${serial_number}  Should Match Regexp  ${INTERFACES['${rmods_id}']['SERIAL_NUMBER']}  [A-Z0-9]{6,20}
        Append To List  ${turned_off_rmods_serial_numbers}  ${serial_number}
    END
    ${rmods_parameters}  taf.sbts.oam.coam.admin.Get Parameters For All  RMOD
    FOR  ${module_parameters}  IN  @{rmods_parameters}
        Run keyword if  '${module_parameters['serialNumber']}' in @{turned_off_rmods_serial_numbers}
        ...  Should be equal  '${module_parameters['operationalState']}'  'disabled'
        Log  RMOD:${module_parameters['serialNumber']}${\n}operationalState:${module_parameters['operationalState']}
        ...  console=${TRUE}
    END

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Reset admin
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    Fail  ${admin_reset_status}

TC_Custom Setup
    [Documentation]    Short description.
    Common Test Setup    expected_BTS_status=${EXPECTED_BTS_STATUS}

TC_Custom Teardown
    [Documentation]    Short description.
    Common Test Teardown
