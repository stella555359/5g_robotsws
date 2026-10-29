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
Library    ute_async


*** Variables ***
${SW Update Timeout}  1800  # Given in seconds; That is a timeout for SW download and Activation (probably without reset - will be clarified)
${proceduralStatus Check Number}  60  # Number of checks for proceduralStatus: onAir after RMODs reset is complete; check interval = 10s
#${Target SW dir}  /home/ute/btsauto/TARGET_SW  # Directory is for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
&{IGNORED_ALARM}=  faultId=23   # PARAMETER SHOULD NOT BE EDITED
@{IGNORED_ALARMS}=  ${IGNORED_ALARM}  # PARAMETER SHOULD NOT BE EDITED
${HW_OFF_ID_LIST}
${NUMBER_OF_RMODS_TO_TURN_OFF}     1
${RM_DETECTION_TIMEOUT}            15 min
${SMOD1['TRS_IP']}    192.168.255.129
${Target SW name}
${lower_release}      SBTS24R2


*** Keywords ***
TC__SWM__SW_update_for_new_RF_unit_uncommissioned
    [Documentation]
    ...  ********************
    ...  1. Basic information
    ...  ********************
    ...
    ...  **Request ID:** TAT-8350
    ...
    ...  ***********************************************************
    ...  2. Description in reStructuredText format on what is tested
    ...  ***********************************************************
    ...
    ...  TC for updating RMOD software when fault 23 is present. There are optional parameters:
    ...
    ...  1. SW Update Timeout - Given in seconds; That is a timeout for SW download and Activation until reset
    ...  2. proceduralStatus Check Number - Number of checks for proceduralStatus: onAir (probably since the reset beginning); check interval = 10s
     ...
    ...  TC timeout: 30 min
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...
    ...  - 29.11.2017 - initial creation
    ...  - 26.02.2018 - TAT 8602
    ...  - 11.04.2018 - TAT-9691
    ...  - 24.08.2018 - TAT-11919
    ...  - 24.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17943 - Moves KW:'Check if all radio modules are available' to ca_swm_general.robo
    ...
    ...  **********************
    ...  4. Test case flowchart
    ...  **********************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/SW_update_for_new_RF_uncommissioned_TAT_8350.png#

    Set Tags    CA-SWM    PHASE-CIT    GROUP_IN_CHARGE-WRO_7_Vrf    SW-SBTS17    SW-SBTS18    SW-SBTS19
    ...    OWNER-mariusz.bak@nokia.com    AUTHOR-jaroslaw.piszczala@nokia.com    MAINTAINER-tomasz.zadworny@nokia.com
    ...    FEATURE-RP001486_RP000912    FEATURE-RP001145_RP000912

    Preconditions
    Find path to SW package
    step-1: Update to tested package
    #step0: Trigger fault 23
    #Wait until keyword succeeds    10min    1min    step1: Check if fault 23 is present
    #step2: Check SW versions
    #step4: Update SW
    #step5: Check if BTS proceduralStatus is NotCommissioned
    #step6: Check if fault 23 absent
    #Step7: Check SW versions

step-1: Update to tested package
    [Documentation]    Short description.
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${SW path}  True  ${SW Update Timeout}
    Log  sw_update_msg=${sw_update_msg}  console=${True}
    ${ping_status}  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=300  timeout=1200
    Run keyword if    not ${ping_status}  FAIL  BTS is not stable after upgrade.
    ${admin_working_state}  Reset admin and infomodel connection if broken
    Run keyword if    not ${admin_working_state}  Fail
    ...  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}

step0: Trigger fault 23
    [Documentation]    Short description.
    prepare N_1 package on SBTS    sw_release=25R2   target_path=/home/ute/btsauto/
    ${admin_working_state1}  Run keyword and return status  hran_admin.Admin and Infomodel connections reset  reset_req=${TRUE}
    Run keyword if    not ${admin_working_state1}  Restore login by json removal from BTS
    ${admin_working_state}  Run keyword and return status  hran_admin.Admin and Infomodel connections reset  reset_req=${TRUE}
    Run keyword if    not ${admin_working_state}  Fail  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}
    Turn OFF RMODs on PDU
    rollback software to higher version
    Turn ON RMODs on PDU

prepare N_1 package on SBTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...        ${target_path}: <description>
    [Arguments]    ${sw_release}=24R2    ${target_path}=/home/ute/btsauto/
#    ${build_num}  Get P7P8 Build Info    ${sw_release}
    ${N_1_pkg_list}   Get Enb     SBTS${sw_release}
#    ${N_1_pkg_num}    set variable if  '${build_num}'==''  ${N_1_pkg_list[-1]}  ${build_num}
    ${N_1_pkg_num}    set variable  ${N_1_pkg_list[1]}
    ${fullpath}  Download_Specify_Build_By_Aria   enb_build=${N_1_pkg_num}  Package_type=Basic  target_path=${target_path}
    run keyword and ignore error    prepare pre release build on SBTS    release=${sw_release}   pkg_full_path=${fullpath}

Downgrade to old package
    [Documentation]    Short description.
    Log    This part to download to lower bts version, to prepare for triggering fault23
    #_Get Scf By Admin    /home/ute/BACK_SCF.xml
    _Get Scf By Admin default    /home/ute/BACK_SCF.xml
    Verify BTS proceduralState    OnAir
#    taf.sbts.oam.coam.admin.Reset Configuration    True    False    timeout=800    alias=default
    Reset configuration by config removal from BTS
    ${lower_version}=    get enb    SBTS23R4
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

#
#SW Downgrade
#    ${Down_pack_list}    get enb    SBTS24R2
#    ${Down_path}    Download_Specify_Build_By_Aria    ${Down_pack_list[-2]}    Basic    /home/ute/
#    set test variable  ${Down_path}
#    sleep    600
#    #SW update    ${Down_path}
#    Collect Scf        /home/ute/BACK_SCF.xml      configurationAndRuntimeObjects
#    Start Admin    alias=hfv
#    run keyword and ignore error    taf.sbts.oam.coam.admin.Reset Configuration    remove_operator_certificates=False
#    ...    remove_user_account_credentials=False    alias=hfv    timeout=800    reset_type=ConfigurationWithDiagnosticAndRecoverySw
#    run keyword and ignore error    Teardown Admin    alias=hfv
#    Wait Until Keyword Succeeds  15 min  5 sec    Connected to D&RSW BTS by RC
#    ${activepartID}=    fdsw.get_active_sw_partition    timeout=10
#    fdsw.software_update  ${activepartID}  ${Down_path}  timeout=1200  activate=${True}
#    sleep    30min
#    ${ping_status}  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=300  timeout=1200
#    Run keyword if    not ${ping_status}  FAIL  BTS is not stable after downgrade.
#    ${scf_full_path}    set variable    /home/ute/testline_configuration/${host_name}/node1/BTS_${tl.tl_cloud_topology}_${lower_release}.xml
#    set test variable    ${scf_full_path}
#    ${admin_working_state}  Run keyword and return status  hran_admin.Admin and Infomodel connections reset  reset_req=${TRUE}
#    Run keyword if    not ${admin_working_state}  Fail  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}
#    SW update    ${Down_path}
#    ${admin_working_state}  Run keyword and return status  hran_admin.Admin and Infomodel connections reset  reset_req=${TRUE}
#    Run keyword if    not ${admin_working_state}  Fail  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}

rollback software to higher version
    [Documentation]    Short description.
    Log step header  rollback software to back higher version
    ${rollback_status}=    Run keyword and return status    wait until keyword succeeds    15min    1min    taf.sbts.oam.coam.admin.Rollback software
    Run keyword if    not ${rollback_status}  FAIL  Software rollback was not performed.
    Log  Software rollback triggered successfully.  console=${TRUE}
    Log  Wait till BTS is stable and ensure admin connectivity  console=${TRUE}
    ${ping_loss}  Run keyword and return status  Wait for target to be not reachable  hostname=192.168.255.129  timeout=480
    Run keyword if    not ${ping_loss}  Fail  Activation reset was not performed.
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=600
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    ${ping stable status}  Run keyword and return status  Check If Target Is Stable  ${SMOD1['TRS_IP']}   min_uptime=360  max_downtime=0  timeout=361
    Run keyword if  ${ping stable status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for 60 seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=${TRUE}
    Log  BTS is stable after rollback.  console=${TRUE}
    ${admin_working_state}  Reset admin and infomodel connection if broken
    Run keyword if    not ${admin_working_state}  Fail  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}

Turn OFF RMODs on PDU
    [Documentation]    Short description.
    Log Step Header  step2: Turn OFF RMODs on PDU
    ${hw_off_id_list}  Split String  ${HW_OFF_ID_LIST}  ,
    Run Keyword If  '${hw_off_id_list[0]}'==''  Choose RMODs on random
    ${NUMBER_OF_RMODS_TO_TURN_OFF}  Get Length	${hw_off_id_list}
    Log Important Message  List of RMODs to be turned OFF:${hw_off_id_list}${\n}How many:${NUMBER_OF_RMODS_TO_TURN_OFF} module/s
    State change if needed  ${hw_off_id_list}  Off
    #Log  Check if turned off RMODs are disabled in ADMIN  console=${TRUE}
    Check if right amount RMODs disabled
    Log  All turned off RMODs are disabled  console=${TRUE}

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
      Run Keyword If  '${hw_state}'!='${hw_target_state}'  Change Pdu State And Check Status  ${hw_id}  ${hw_target_state}
      ...  ELSE  Log  ${hw_id} status already correct: ${hw_state}  console=${TRUE}
      sleep    30s
    END

Check if right amount RMODs disabled
    [Documentation]    Short description.
    Sleep  60
    ${turned_off_rmods_serial_numbers}  Create list
    FOR  ${rmods_id}  IN  @{hw_off_id_list}
        #${serial_number}  Should Match Regexp  ${rmods_id}  [A-Z0-9]{6,20}
        ${serial_number}  Should Match Regexp  ${INTERFACES['${rmods_id}']['SERIAL_NUMBER']}  [A-Z0-9]{6,20}
        Append To List  ${turned_off_rmods_serial_numbers}  ${serial_number}
    END
    ${rmods_parameters}  taf.sbts.oam.coam.admin.Get Parameters For All  RMOD
    FOR  ${module_parameters}  IN  @{rmods_parameters}
        Run keyword if  '${module_parameters['serialNumber']}' in @{turned_off_rmods_serial_numbers}
        ...  Should be equal  '${module_parameters['operationalState']}'  'disabled'
        Log  RMOD:${module_parameters['serialNumber']}${\n}operationalState:${module_parameters['operationalState']}  console=${TRUE}
    END

Turn ON RMODs on PDU
    [Documentation]    Short description.
    Log Step Header  step4: Turn ON RMODs on PDU
    State change if needed  ${hw_off_id_list}  On
    Log  Will now check if all radio modules are available...  console=${TRUE}
    #${status}  Run keyword and return status  Wait until keyword succeeds  ${RM_DETECTION_TIMEOUT}  20s  Check if all radio modules are available
    #Run keyword if  ${status}  Log Important Message  All RMODs ON
    #...  ELSE
    #...  Set test blocked  Not all radio modules are available

Preconditions for BTS uncommissioned
    [Documentation]    Short description.
    Reset configuration by config removal from BTS

Preconditions
    [Documentation]    Short description.
    Log Step Header  Preconditions
    ${status}=  Run keyword and return status  Wait until keyword succeeds  15m  1m  Check if all radio modules are available
    Run keyword if    not ${status}  Set test blocked  Not all radio modules are available

step1: Check if fault 23 is present
    [Documentation]    Short description.
    Log Step Header  step1: Check if fault 23 is present
    ${Active Alarms}  taf.sbts.oam.coam.admin.Get Active Alarms
    ${Radios with fault 23 dn list}  Create list
    FOR  ${alarm}  IN  @{Active Alarms}
        Run keyword if   ${alarm}[faultId] == 23  Append to list  ${Radios with fault 23 dn list}  ${alarm}[notifier]
    END
    Should not be empty  ${Radios with fault 23 dn list}
    ${fault 23 presence status}=  Run keyword and return status  Should not be empty  ${Radios with fault 23 dn list}
    Run keyword if    not ${fault 23 presence status}  Set test norun  No fault 23 found!  fail_test=${False}
    Log  Fault 23 has been detected for following RMODs: ${Radios with fault 23 dn list}  console=${TRUE}
    Set Test Variable  ${Radios with fault 23 dn list}

step${Step number}: Check SW versions
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Step number}: <description>
    Log Step Header  step${Step number}: Check SW versions
    ${Active SW}   Infomodel Get Active SW Version
    Set global variable  ${Active SW}
    ${Passive SW}  Infomodel Get Passive SW Version
    Log  Active software package is: ${Active SW}  console=${TRUE}
    Log  Passive software package is: ${Passive SW}  console=${TRUE}
    Run Keyword If  '${Active SW}'==''  Log  Active sw version was not readable  level=ERROR    console=${TRUE}
    Run Keyword If  '${Passive SW}'==''  Log  Passive sw version was not readable  level=WARN    console=${TRUE}
    Run Keyword If  '${Step number}'=='2'    Set global variable  ${Active SW before update}  ${Active SW}
    Run Keyword If  '${Step number}'=='7'    Should be equal  ${Active SW before update}  ${Active SW}

step3: Find path to SW package_BackUp
    [Documentation]    Short description.
    Log Step Header  step3: Find path to SW package
    ${active sw pattern}  Get regexp matches  ${Active SW}  \\S+_(\\S+_\\d+_\\d+_\\d+)  1
    ${package name}  OperatingSystem.List files in directory  ${Target SW dir}  *${active sw pattern[0]}*
    Should not be empty  ${package name}  Required package not present in ${Target SW dir}
    ${SW path}=  Join Path 	${Target SW dir}  ${package name[0]}
    OperatingSystem.File should exist  ${SW path}
    Set global variable  ${SW path}
    Log  SW package found at: ${SW path}  console=${TRUE}

Find path to SW package
    [Documentation]    Short description.
    ${status}  ${active SW after upgrade}=  Run keyword and ignore error
    ...  Infomodel Get Active SW Version  module=MSM  im_param=activeBuildDescriptorId
    ${status}    ${passive SW after upgrade}=    Run keyword and ignore error
    ...    Infomodel Get Passive SW Version    module=MSM    im_param=passiveBuildDescriptorId
     ${active SW after upgrade}    run keyword if    '${target_release}'=='SBTS00'
    ...    Replace String Using Regexp    ${active SW after upgrade}    [0-9][0-9][A-Z][0-9]?    00
    ...    ELSE    set variable    ${active SW after upgrade}
    ${passive SW after upgrade}    run keyword if    '${target_release}'=='SBTS00'
    ...    Replace String Using Regexp    ${passive SW after upgrade}    [0-9][0-9][A-Z][0-9]?    00
    ...    ELSE    set variable    ${passive SW after upgrade}
    #${SW path}=    Get upgrade path    ${active SW after upgrade}    ${passive SW after upgrade}    ${release_list[-1]}    ${release_list[-2]}
    ${SW path}  Get SW file for SWDL  ${Target SW dir}  ${Target SW name}
    Run Keyword If  '${SW path}'== ${None}   Fail   msg=
    set test variable    ${SW path}

step4: Update SW
    [Documentation]    Short description.
    Log Step Header  step4: Update SW
    Log  Will now start async stability ping check on SMOD  console=${TRUE}
    Start async  tool_ping  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=361
    Log  Will now perform software update  console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${SW path}  True  ${SW Update Timeout}
    Run keyword if  '${sw_update_result}'=='FAIL'  Fail  SW update failed. Reason: ${sw_update_msg}
    Log  Wait until rmods reset  console=${TRUE}
    Log  Wait until rmods operationalState Disabled  console=${TRUE}
    #Wait until keyword succeeds  3 min   30 sec  Check rmods operationalState  [dD]isabled  ${Radios with fault 23 dn list}
    Log  Wait until rmods operationalState Enabled  console=${TRUE}
    Wait until keyword succeeds  10 min  30 sec  Check rmods operationalState  ${_Enabled}   ${Radios with fault 23 dn list}
    wait until keyword succeeds  365s    5s    smod_ping_success
    Log  SMOD stability ping check: ${smod_ping_stable}  console=${TRUE}
    Run keyword if    not ${smod_ping_stable}  Set Test Failed  SMOD lost ping during RMODs update
    [Teardown]  Stop async

smod_ping_success
    [Documentation]    Short description.
    ${smod_ping_stable}  Wait for async result  timeout=365
    should be true     ${smod_ping_stable}
    Run keyword if    ${smod_ping_stable}    set test variable    ${smod_ping_stable}

step5: Check if BTS proceduralStatus is NotCommissioned
    [Documentation]    Short description.
    Log Step Header  step5: Check if BTS proceduralStatus is NotCommissioned
    Log  Will check proceduralStatus maximum of ${proceduralStatus Check Number} times with 10s interval.  console=${TRUE}
    FOR  ${run}  IN RANGE  1  ${proceduralStatus Check Number}
        ${BTS proceduralStatus}  taf.sbts.oam.coam.admin.Get Mrbts State
        Run keyword if  '${BTS proceduralStatus}' == 'NotCommissioned'
        ...  Run Keywords  Log  BTS proceduralStatus: NotCommissioned Check attempt: ${run}  console=${TRUE}
        ...  AND  Return from keyword
        Sleep  10
    END
    Set Test Failed  BTS proceduralStatus has not acchieved expected value within timeout

step6: Check if fault 23 absent
    [Documentation]    Short description.
    Log Step Header  step6: Check if fault 23 absent
    Sleep  20
    ${Active Alarms}  taf.sbts.oam.coam.admin.Get Active Alarms
    ${Radios with fault 23 dn list}  Create list
    FOR  ${alarm}  IN  @{Active Alarms}
        Run keyword if   ${alarm}[faultId] == 23  Append to list  ${Radios with fault 23 dn list}  ${alarm}[notifier]
    END
    ${verification_status}=  Run keyword and return status  Should be empty  ${Radios with fault 23 dn list}
    Run keyword if    not ${verification_status}
    ...  Set Test Failed  Fault 23 has been detected for following RMODS: ${Radios with fault 23 dn list}. Test failed.
    Log  Fault 23 has not been detected.  console=${TRUE}

Check rmods operationalState
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${state}: <description>
    ...        ${radios_with_fault_23}: <description>
    [Arguments]  ${state}  ${radios_with_fault_23}
    ${rmods_parameters}  taf.sbts.oam.coam.admin.Get Parameters For All  RMOD
    FOR  ${radio_with_fault_23}  IN  @{radios_with_fault_23}
        ${status}  Loop over rmods  ${radio_with_fault_23}  ${rmods_parameters}  ${state}
        Run keyword if    not ${status}  Fail  Rmods state not ${state}
    END

Loop over rmods
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${radio_with_fault_23}: <description>
    ...        ${rmods_parameters}: <description>
    ...        ${state}: <description>
    ...
    ...    Returns:
    ...        ${False}: <description>
    [Arguments]  ${radio_with_fault_23}  ${rmods_parameters}  ${state}
    FOR  ${rmod_parameters}  IN  @{rmods_parameters}
        ${radio_with_fault_23_cut}  Get Regexp Matches  ${radio_with_fault_23}  EQM_R-[0-9]+\/APEQM_R-[0-9]+\/RMOD_R-[0-9]+
        Run Keyword If  '${radio_with_fault_23_cut[0]}' in '${rmod_parameters['id']}'
        ...  Log  ${rmod_parameters['id']} : ${rmod_parameters['operationalState']}  console=${True}
        Return From Keyword If
        ...  '${radio_with_fault_23_cut[0]}' in '${rmod_parameters['id']}' and '${rmod_parameters['operationalState']}' in '${state}'  ${True}
    END
    [Return]  ${False}

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

TC_Custom Setup
    [Documentation]    Short description.
    TC Setup
    #_Get Scf By Admin    /home/ute/BACK_SCF.xml
    _Get Scf By Admin default    /home/ute/BACK_SCF.xml
    #Preconditions for BTS uncommissioned

TC_Custom Teardown
    [Documentation]    Short description.
    wait until keyword succeeds    15min    30s    _Perform Full Commision By Admin      /home/ute/BACK_SCF.xml    ${BTS_INFO.ID}
    wait until keyword succeeds    15min    30s    Check BTS State By Admin    OnAir
    TC Teardown
