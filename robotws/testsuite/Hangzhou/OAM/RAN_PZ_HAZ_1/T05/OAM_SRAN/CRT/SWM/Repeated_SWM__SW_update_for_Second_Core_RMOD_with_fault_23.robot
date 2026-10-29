*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Library    taf.sbts.oam.coam.admin
Library    ute_admin_infomodel
Library    OperatingSystem
Library    ute_async
Library    Collections
Library    taf.hw.pdu


*** Variables ***
${Target SW name}                  ${None}                        # SW package name
${Target SW dir}                   /home/ute/btsauto/TARGET_SW    # Directory in which TC should look for sw package
${SW Update Timeout}               3600                            # Given in seconds
${Ping loss timeout}               240                            # Timeout for ping loss during reset
${Ping regain timeout}             600                            # Timeout for ping regain during reset
${Test Timeout}                    150                             # Test timeout (in minutes)
${EXPECTED_BTS_STATUS}             OnAir                          # Expected BTS state before TC starts
${onAir Check Number}              60                             # Number of checks for proceduralStatus
${RM_DETECTION_TIMEOUT}            15 min                         # Timeout for all connected RMs detection (in minutes)
${HW_OFF_ID_LIST}                                                 # Module names as defined in interfaces.yaml
${NUMBER_OF_RMODS_TO_TURN_OFF}     1                              # How many RMODs should be turned off (random choice)
${http_port}=    8080
${https_port}=    8443
${security_mode}=  no TLS
${ip_version}=  IPv4
${SW_server}    10.68.93.70
${cm2}     --all-proxy="" --continue --max-connection-per-server=16


*** Keywords ***
TC__Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${TEST_ITERATION}: <description>
    [Arguments]   ${TEST_ITERATION}=1
    Change parameter to connect netact with BTS
    FOR  ${i}  IN RANGE  1  ${TEST_ITERATION}+1
        Precondition: Import Target SW To NA
        prepare N_1 package on SBTS    sw_release=26R1    target_path=/home/ute/btsauto/
        step1: Check SW versions
        step2_1: Random select RU
        step2: Turn OFF RMODs on PDU
        step3: SW upgrade
        step4: Check NE3S status
        step5: Turn ON RMODs on PDU
        step6: Check if fault 23 is present
        Step7: Check provision triggered by NE
        step8: Check if BTS onAir
        step9: Check if fault 23 absent
        step10: Check if all cells onAir
        step10_1: Perform rollback
        Step10_2: Check BTS is onair after rollback
        step11: Choose package and upgarde
        Sleep    30min
        END

step10_1: Perform rollback
    [Documentation]    Short description.
    ${rollback_status}=  Run keyword and return status  taf.sbts.oam.coam.admin.Rollback software
    Run keyword if    not ${rollback_status}  FAIL  Software rollback was not performed.
    ${ping_status}  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=300  timeout=1200
    Run keyword if    not ${ping_status}  FAIL  BTS is not stable after rollback.
    Log  BTS is stable after rollback.  console=${TRUE}
    ${admin_working_state}  Reset admin and infomodel connection if broken
    Run keyword if    not ${admin_working_state}  Fail
    ...  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}

Step10_2: Check BTS is onair after rollback
    [Documentation]    Short description.
    Log step header    Step 7: Check BTS is onair after rollback
    check BTS is onair after update to tested software

check BTS is onair after update to tested software
    [Documentation]    Short description.
    ${ping loss status}    Run keyword and return status    Wait For Target To Be Not Reachable
    ...    hostname=${SMOD1['TRS_IP']}    timeout=600
    Run keyword if    ${ping loss status}==${FALSE}
    ...  Log    BTS RESET after successful SW activation DID NOT OCCUR    console=${TRUE}
    ...    ELSE    Log    BTS is resetting after successful SW activation...    console=${TRUE}
    ${ping regain status}    Run keyword and return status    Wait For Target To Be Reachable
    ...    hostname=${SMOD1['TRS_IP']}    timeout=300
    Run keyword if    ${ping regain status}==${FALSE}    Set Test Failed    Ping has not been regained within timeout
    ...    ELSE    Log    BTS ping regained    console=${TRUE}
    Log    Waiting for stable ping...    console=${TRUE}
    ${ping stable status}    Run keyword and return status    Check If Target Is Stable
    ...    ${SMOD1['TRS_IP']}    min_uptime=240    max_downtime=0    timeout=361
    Run keyword if    ${ping stable status}==${FALSE}    Set Test Failed    Ping has not been available for 60 seconds
    ...    ELSE    Log    Ping is stable after SWM operation    console=${TRUE}
    Wait until keyword succeeds  45 min  30 sec  Check SBTS SOAM cells and modules

step11: Choose package and upgarde
    [Documentation]    Short description.
    ${active_sw}  ${passive_sw}=  Infomodel Get SW Versions  module=MSM
    ${active_sw}  Run keyword If  '000000'in'${active_sw}'  set variable  ${active_sw}
    ...  ELSE IF  '9999'in'${active_sw}'
    ...  Replace String Using Regexp  ${active_sw}  SBTS[0-9][0-9][A-Z][0-9]?_    SBTS00_
    ${Target SW dir}=
    ...  Get upgrade path
    ...  ${active_sw}    ${Passive_build}    ${release_list_1}    ${release_list_2}    ${release_list_3}
    hran_general.Find path to SW package
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${Target SW path}  True  ${SW Update Timeout}
#   ${software_update_end}=  Get current date
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    ${ping loss status}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping loss timeout}
    Run keyword if  ${ping loss status}==${FALSE}
    ...   Log    BTS RESET after successful sw update DID NOT OCCUR   console=${TRUE}
    ...   ELSE
    ...   Log    BTS is resetting after successful sw update          console=${TRUE}
    ${ping regain status}  Run keyword and return status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping regain timeout}
    Run keyword if  ${ping regain status}==${False}  Set Test Failed  Ping has not been regained within timeout
    ${ping stable status}  Run keyword and return status
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=60  max_downtime=0  timeout=61
    Run keyword if  ${ping stable status}==${False}  Set Test Failed  Ping has not been available for 60 seconds
    Wait Until Keyword Succeeds  5 min  10 sec  Fail if connection with admin is not available

prepare N_1 package on SBTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...        ${target_path}: <description>
    [Arguments]    ${sw_release}=26R1    ${target_path}=/home/ute/btsauto/
    ${N_1_pkg_list}   Get Enb     SBTS${sw_release}
    ${N_1_pkg_num}    set variable  ${N_1_pkg_list[1]}
    ${fullpath}  Download_Specify_Build_By_Aria   enb_build=${N_1_pkg_num}  Package_type=Basic  target_path=${target_path}
    prepare pre release build on SBTS    release=${sw_release}   pkg_full_path=${fullpath}

Precondition: Import Target SW To NA
     [Documentation]
    ...  choose the target package to upgrade, first import to netact, then upgrade by netact
    Log step header  Precondition: Import Target SW To NA
    Log  Check build in Netact otherwise Import
    ${collect_snapshot}    set variable    never
    ${target_sw_path}=    Common_Find SW name    ${Target SW dir}
    set test variable    ${target_sw_path}
    ${package name}    OperatingSystem.List files in directory    ${Target SW dir}
    ${package name}    set variable    ${package_name[0]}
    ${package_release}=    Find release version    ${package name}    ${release_list_1}    ${release_list_2}    ${release_list_3}
    ${release_NUM}=    RUN KEYWORD IF    '${target_release}'=='SBTS00'     set variable    SBTS26R2
    ...    ELSE    set variable    SBTS26R1
    ${active_sw_before_master}    ${passive_sw_before_master}=    Infomodel Get SW Versions    module=MSM
    ${release_NUM}=    RUN KEYWORD IF    '${target_release}'=='SBTS00'     set variable    SBTS26R2
    ...    ELSE    should match regexp    ${active_sw_before_master}    SBTS\\d+..
    set test variable    ${release_NUM}
    ${package_release_changed}    run keyword if    '${target_release}'=='SBTS00'    Replace String Using Regexp
    ...    ${package_release}    SBTS\\d{2}[A-Z]?[0-9]?    ${release_NUM}
    ...    ELSE    set variable    ${package_release}
    set test variable    ${package_release_changed}
    Log  Check build in Netact otherwise Import
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}=  Choose_Mid_Server4Netact  ${NETACT_SERVER_INFO.IP}
    build_download_upload_on_remote_server_and_import_to_Netact  target_sw=${package_release}
                                                            ...  release_NUM=${release_NUM}
                                                            ...  remote_ip=${Mid_Server}
                                                            ...  remote_usr=${Mid_Server_usr}
                                                            ...  remote_pwd=${Mid_Server_pwd}
    ${collect_snapshot}    set variable    failed_verdict

Common_Find SW name
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SW_PATH}: <description>
    ...
    ...    Returns:
    ...        ${SW_PATH_package}: <description>
    [Arguments]    ${SW_PATH}
    ${package name}    OperatingSystem.List files in directory    ${SW_PATH}
    should not be empty    ${package name}    Required package not present in ${SW_PATH}
    ${SW_PATH_package}=    Join Path    ${SW_PATH}    ${package name[0]}
    OperatingSystem.File should exist    ${SW_PATH_package}
    [Return]    ${SW_PATH_package}

Find release version
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${package name}: <description>
    ...        ${release_1}: <description>
    ...        ${release_2}: <description>
    ...        ${release_3}: <description>
    ...
    ...    Returns:
    ...        ${release}: <description>
    [Arguments]    ${package name}    ${release_1}    ${release_2}    ${release_3}
    ${release}=    set variable if    '${release_1}' in '${package name}'    ${release_1}
    ...    '${release_2}' in '${package name}'    ${release_2}
    ...    '${release_3}' in '${package name}'    ${release_3}
    [Return]    ${release}

Downgrade to old package
    [Documentation]    Short description.
    Log    This part to download to lower bts version, to prepare for triggering fault23
    _Get Scf By Admin    /home/ute/BACK_SCF.xml
    Verify BTS proceduralState    OnAir
    Reset configuration by config removal from BTS
    ${lower_version}=    get enb    SBTS26R1
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

step2_1: Random select RU
    [Documentation]    Short description.
    @{nonF_rmod_list}    Create List
    set test variable    ${nonF_rmod_list}
    ${rc_n}  ${rmod_list}=  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all
        ...  class_name=RMOD  timeout=60
    set test variable    ${rmod_list}
    FOR    ${item}   IN    @{rmod_list}
    ${res}    ${match}    Run keyword and ignore error  Should Match Regexp  ${item['productName']}  F[X,R,Z][A-Z]{2}
    Log    ${match}
    Run keyword if    '${res}'=='FAIL'
    ...    Append to List    ${nonF_rmod_list}    ${item}
    END
    ${rmod_length}    get length   ${nonF_rmod_list}
    Run keyword if     ${rmod_length}==0    Fail    Cannot find RMOD
    ${rad_rmod}=    Run keyword if     ${rmod_length}==1    Evaluate    0
    ...    ELSE IF    ${rmod_length}>=2    Evaluate    random.randint(0, ${rmod_length}-1)    random
    ${dn_rmod}=     set variable    ${nonF_rmod_list[${rad_rmod}]['id']}
    ${sn_rmod}=     set variable    ${nonF_rmod_list[${rad_rmod}]['serialNumber']}
    FOR  ${i}  IN RANGE  len(${rmod_list})
      Run keyword if  '${INTERFACES}[RMOD${i+1}][SERIAL_NUMBER]'=='${nonF_rmod_list[${rad_rmod}]['serialNumber']}'
      ...  Run keywords  set test variable  ${PDUIP_RMOD}  ${INTERFACES}[RMOD${i+1}][PB_IP]
      ...  AND  set test variable  ${Port_RMOD}  ${INTERFACES}[RMOD${i+1}][PB_PORT]
      ...  AND  set test variable  ${pb_type}  ${INTERFACES}[RMOD${i+1}][PB_TYPE]
      Exit For Loop If  '${INTERFACES}[RMOD${i+1}][SERIAL_NUMBER]'=='${nonF_rmod_list[${rad_rmod}]['serialNumber']}'
    END

step2: Turn OFF RMODs on PDU
    [Documentation]    Short description.
    Log Step Header  step2: Turn OFF RMODs on PDU
    Wait Until Keyword Succeeds    5min    5s    taf.hw.pdu.Setup Pdu  ${pb_type}    ${PDUIP_RMOD}
    ...    timeout=10   alias=${pb_type}
    Wait Until Keyword Succeeds    5min    5s    taf.hw.pdu.Power Off  ${Port_RMOD}   ${pb_type}
    [Teardown]  Run Keyword And Ignore Error  taf.hw.pdu.Teardown Pdu    ${pb_type}

step3: SW upgrade
    [Documentation]    Short description.
    Log Step Header  step3: SW upgrade
    wait until keyword succeeds      50min    30s
     ...    taf.sbts.oam.coam.admin.Update Software  ${target_sw_path}  True  ${SW Update Timeout}
    ${ping loss status}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping loss timeout}
    Run keyword if  ${ping loss status}==${FALSE}
    ...   Log    BTS RESET after successful sw update DID NOT OCCUR   console=${TRUE}
    ...   ELSE
    ...   Log    BTS is resetting after successful sw update          console=${TRUE}
    ${ping regain status}  Run keyword and return status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping regain timeout}
    Run keyword if  ${ping regain status}==${False}  Set Test Failed  Ping has not been regained within timeout
    ${ping stable status}  Run keyword and return status
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=60  max_downtime=0  timeout=61
    Run keyword if  ${ping stable status}==${False}  Set Test Failed  Ping has not been available for 60 seconds
    Wait Until Keyword Succeeds  5 min  10 sec  Fail if connection with admin is not available

step4: Check NE3S status
    [Documentation]    Short description.
    Sleep  240
	${result}=    Integrate And Check NE Status
	Run keyword if    '${result}'=='FAIL'    Repair The NE3S And Integrate And Check BTS

step5: Turn ON RMODs on PDU
    [Documentation]    Short description.
    Log Step Header  step5: Turn ON RMODs on PDU
    Wait Until Keyword Succeeds    20min    5s    taf.hw.pdu.Setup Pdu  ${pb_type}    ${PDUIP_RMOD}
    ...    timeout=10   alias=${pb_type}
    Wait Until Keyword Succeeds    10min    5s    taf.hw.pdu.Power On  ${Port_RMOD}   ${pb_type}
    [Teardown]  Run Keyword And Ignore Error  taf.hw.pdu.Teardown Pdu    ${pb_type}

step6: Check if fault 23 is present
    [Documentation]    Short description.
    Log Step Header  step6: Check if fault 23 is present
    sleep     1min
    ${Radios_with_fault_23_dn_list}  Create list
    Set Test Variable  ${RADIOS_WITH_FAULT_23_LIST}  ${Radios_with_fault_23_dn_list}
    Log  Will now check if fault 23 if present on correct RMOD/s...  console=${TRUE}
    ${fault_23_check}  Wait until keyword succeeds  ${RM_DETECTION_TIMEOUT}  5 sec  Check fault 23 for all rmods
    Run keyword if    not ${fault_23_check}  Set test norun  No fault 23 found!  fail_test=${FALSE}
    Log  Fault 23 has been detected for following RMODs: ${RADIOS_WITH_FAULT_23_LIST}  console=${TRUE}

Step 7: Check provision triggered by NE
    [Documentation]    Short description.
    Log step header  Step7: Check provision triggered by NE
    wait until keyword succeeds   40min     10s    _check provision triggered by NE

step8: Check if BTS onAir
    [Documentation]    Short description.
    Log Step Header  step8: Check if BTS onAir
    sleep    3min
    Log  Will now check if BTS is onAir maximum of ${onAir Check Number} times with 10s interval.  console=${TRUE}
    FOR  ${run}  IN RANGE  1  ${onAir Check Number}
        ${BTS onAir}  taf.sbts.oam.coam.admin.Get Mrbts State
        Run keyword if  '${BTS onAir}' == 'OnAir'  Run Keywords  Log  BTS is onAir! Check attempt: ${run}  console=${TRUE}
        ...  AND  Return from keyword
        Sleep  10
    END
    Set Test Failed  BTS not onAir within timeout

step9: Check if fault 23 absent
    [Documentation]    Short description.
    Log Step Header  step9: Check if fault 23 absent
    ${Active Alarms}  taf.sbts.oam.coam.admin.Get Active Alarms
    ${Radios_with_fault_23_after}  Create list
    FOR  ${alarm}  IN  @{Active Alarms}
        Run keyword if   ${alarm}[faultId] == 23  Append to list  ${Radios_with_fault_23_after}  ${alarm}[notifier]
    END
    ${verification_status}  Run keyword and return status  Should be empty  ${Radios_with_fault_23_after}
    Run keyword if    not ${verification_status}  Set Test Failed
    ...    Fault 23 has been detected for following RMODS: ${Radios_with_fault_23_after}. Test failed.
    Log  Fault 23 has not been detected.  console=${TRUE}

step10: Check if all cells onAir
    [Documentation]    Short description.
    Wait until keyword succeeds  30 min  30 sec  Check SBTS SOAM cells and modules

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
    ${list_len_check}  Run keyword and return status  Length Should Be  ${RADIOS_WITH_FAULT_23_LIST}  ${NUMBER_OF_RMODS_TO_TURN_OFF}
    Should Be True  ${fault_23_presence_status} and ${list_len_check}
    [Return]  ${TRUE}

Check if right amount RMODs disabled
    [Documentation]    Short description.
    Sleep  20
    ${turned_off_rmods_serial_numbers}  Create list
    FOR  ${rmods_id}  IN  @{hw_off_id_list}
        ${serial_number}  Should Match Regexp  ${INTERFACES['${rmods_id}']['SERIAL_NUMBER']}  [A-Z0-9]{6,20}
        Append To List  ${turned_off_rmods_serial_numbers}  ${serial_number}
    END
    ${rmods_parameters}  taf.sbts.oam.coam.admin.Get Parameters For All  RMOD
    FOR  ${module_parameters}  IN  @{rmods_parameters}
        Run keyword if  '${module_parameters['serialNumber']}' in @{turned_off_rmods_serial_numbers}
        ...  Should be equal  '${module_parameters['operationalState']}'  'Disabled'
        Log  RMOD:${module_parameters['serialNumber']}${\n}operationalState:${module_parameters['operationalState']}  console=${TRUE}
    END

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Reset admin
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    Fail  ${admin_reset_status}

Download_dedicated_Build
    [Arguments]    ${enb_build}    ${Package_type}    ${target_path}
    [Documentation]    \ \ \ [Documentation] \ \ \ | Time | Release | Author | Modification | Relevant feature |
    ...    \ \ ... \ \ \ | 20200730 | SRAN21A | li yanan | New KW | SWM releated download package on UTE |
    ...    \ ...
    ...    ... \ \ \ This KW is \ about downloading specify package by using multi-progress
    ...
    ...    ... \ \ \ parameter1: enb_build (string) \u2013 e.g. SBTS00_ENB_9999_200727_000001
    ...
    ...    ... \ \ \ parameter2: Package_type(string) \u2013 e.g. Basic | T1 | T2
    ...    ... \ \ ... \ \ If Basic, SBTS00_ENB_9999_200727_000001__release_BTSSM_downloadable_A54.zip
    ...    ... \ \ If T1, \ SBTS00_ENB_9999_200727_000001_release_BTSSM_downloadable_testpackage_T1_A54.zip
    ...    ... \ \ If T2, \ SBTS00_ENB_9999_200727_000001_release_BTSSM_downloadable_testpackage_T2_A54.zip

    ${enb_build}=    Run Keyword If    '9999' in '${enb_build}'
    ...  Replace String Using Regexp    ${enb_build}    SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
    ...    ELSE    Set variable    ${enb_build}
	${release}    Fetch from left    ${enb_build}    _
	${num}    BuiltIn.Should Match Regexp    ${release}    [0-9][0-9]
	${scm_server}    Set variable    http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/${release}
	${scm_server}    Set variable    http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/${release}
    ${download_path}    Set variable    /home/ute/HZOAM/Triger_23_SW
    ${build_match_no}    Run keyword if    '${release}'=='SBTS00'    Set variable    A54
    ...    ELSE IF    '${num}'>='21'    Set variable    A54
    ...    ELSE IF    '${num}'>='20' and ('C' in '${release}')    Set variable    A54
    ...    ELSE IF    '${num}'<='20' and ('00' not in '${release}') and ('C' not in '${release}')    Set variable    A53
    ${build_url}    Set Variable If
    ...  '${Package_type}'=='Basic'    ${scm_server}/${enb_build}_release_BTSSM_downloadable_${build_match_no}.zip
    ...  '${Package_type}'=='T1'
    ...  ${scm_server}/${enb_build}_release_BTSSM_downloadable_testpackage_T1_${build_match_no}.zip
    ...  '${Package_type}'=='T2'
    ...  ${scm_server}/${enb_build}_release_BTSSM_downloadable_testpackage_T2_${build_match_no}.zip
    ${Package_full_path}    Set Variable If    '${Package_type}'=='Basic'
    ...  ${download_path}${/}${enb_build}_release_BTSSM_downloadable_${build_match_no}.zip    '${Package_type}'=='T1'
    ...  ${download_path}${/}${enb_build}_release_BTSSM_downloadable_testpackage_T1_${build_match_no}.zip
    ...  '${Package_type}'=='T2'
    ...  ${download_path}${/}${enb_build}_release_BTSSM_downloadable_testpackage_T2_${build_match_no}.zip
    log    ${target_path}
    ${curl_path}    Set Variable    ${target_path}
    ${status_curl}=    Run Keyword And Ignore Error    OperatingSystem.Directory Should Exist    ${curl_path}
    Run Keyword If    '${status_curl[0]}'=='FAIL'    Create Directory    ${curl_path}
    OperatingSystem.Directory Should Exist    ${curl_path}
    ${curl_full_path}    Set Variable If
    ...  '${Package_type}'=='Basic'    ${curl_path}${enb_build}_release_BTSSM_downloadable_${build_match_no}.zip
    ...  '${Package_type}'=='T1'
    ...  ${curl_path}${/}${enb_build}_release_BTSSM_downloadable_testpackage_T1_${build_match_no}.zip
    ...  '${Package_type}'=='T2'
    ...  ${curl_path}${/}${enb_build}_release_BTSSM_downloadable_testpackage_T2_${build_match_no}.zip
    Run keyword and ignore error    Remove File    ${curl_full_path}
    ${cmd1}    set Variable
    ...  aria2c \ --file-allocation=none ${cm2} --split=16 ${build_url} -d ${download_path}
    #connect to host    host=10.108.184.40    port=22    username=ute    password=ute    conn_type=SSH
    #set Shell Timeout    2100
    #${result}=    Wait Until Keyword Succeeds    60 minutes    5 secs    Execute Shell Command    ${cmd1}
#    set_connection_parameters   10.108.184.40    ute    ute
#    ${result}=    Wait Until Keyword Succeeds    60 minutes    5 secs    run command    ${cmd1}
#    Comment    Should Be True    'completed'in'${result}'
#    sftp_download    10.108.184.40    22    ute    ute    ${Package_full_path}    ${curl_path}
    ${build_path}    Set Variable    ${curl_full_path}
    SSHLibrary.Open Connection    ${down_server}
    SSHLibrary.Login    ute    ute@dmin5
    ${rc}=    SSHLibrary.Execute Command    find ${package_full_path}    return_stdout=False    return_rc=True
    Run keyword if    ${rc}!=0
    ...  Wait Until Keyword Succeeds    60 minutes    5 secs    SSHLibrary.Execute Command    ${cmd1}
    BuiltIn.Log To Console    Finished download ${Package_type} build to ${download_path}
    SSHLibrary.Get File    ${Package_full_path}    ${curl_path}        SCP=ALL
    sleep  30s
    SSHLibrary.Close Connection
    ${Package_size}    Get File Size    ${curl_full_path}
    Should Be True    ${Package_size} > 400000000
    [Return]    ${build_path}

Integrate And Check NE Status
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${status}: <description>
    ${MRBTS_MO_DIST_NAME}    set variable    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
    ${MRBTS_MO_ADDRESS}    set variable      ${BTS_INFO.IP}
    Precondition Netact with TAF
    ${MRBTS_MO_MR}=    Run Keyword If    '${NETACT_SERVER_INFO.IP}' == '10.110.144.154'    set variable    MRC-5GSC_HZ/MR-5GSC_HZ
	...    ELSE IF    '${NETACT_SERVER_INFO.IP}' == '10.107.183.26'    set variable    MRC-5GSC-HZ/MR-5GSC-HZ
	...    ELSE IF    '${NETACT_SERVER_INFO.IP}' == '10.68.84.15'    set variable    MRC-5GHZ/MR-5GHZ
        ...    ELSE IF    '${NETACT_SERVER_INFO.IP}' == '10.108.248.82'    set variable    MRC-5GRAN-HZ/MR-5GRAN-HZ
	...    ELSE    set variable    MRC-COMMON/MR-COMMON
    ${status}   ${integration_output}=  Run keyword and ignore error    taf.nms.netact.Integrate MRBTS With Netact
    ...  release=${release_NUM}  mr=${MRBTS_MO_MR}  mrbts_address=${MRBTS_MO_ADDRESS}  dist_name=${MRBTS_MO_DIST_NAME}
    ...  http_port=${http_port}  https_port=${https_port}  ip_version=${ip_version}  security_mode=${security_mode}
    Log  \n${integration_output}  console=${TRUE}
    Postcondition Netact with TAF
    [Return]    ${status}

Repair The NE3S And Integrate And Check BTS
    [Documentation]    Short description.
#    connect to host    host=192.168.255.129    port=22    username=toor4nsn    password=oZPS0POrRieRtu    conn_type=SSH
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Execute Command   rm /ffs/run/config/ne3sadapt/configs/ne3sadaptdata.db
    SSHLibrary.Close Connection
    taf.sbts.oam.coam.admin.reset admin
    Sleep    3min
    ${status}=    Integrate And Check NE Status
    Run keyword if    '${status}'=='Fail'    Log    repair or integrate failed.

TC_Custom Setup
    [Documentation]    Short description.
    Common Test Setup    expected_BTS_status=${EXPECTED_BTS_STATUS}
    #Common Test Setup    expected_BTS_status=Not Comissioned

TC_Custom Teardown
    [Documentation]    Short description.
    Common Test Teardown
