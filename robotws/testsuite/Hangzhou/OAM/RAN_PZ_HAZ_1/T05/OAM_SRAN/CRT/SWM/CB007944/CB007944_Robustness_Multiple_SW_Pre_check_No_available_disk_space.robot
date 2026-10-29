*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py


*** Variables ***
${SW Update Timeout}               3000
&{FAULT_30}      fault_id=30
...              alarm_id=7115
...              alarm_severity=Minor
...              fault_name="BTS SW download or activation failed"
...              notifier=/MRBTS-1/EQM_R-*/APEQM_R-*/SMOD_R-*
...              EFaultId=EFaultId_SwUpdateAl
...              fault_path=/MRBTS-1/RAT-1/SWM-1
${Additional Checks Number}        5         # Number of checks which have to be perform to ensure that bts is onAir
${Sleep interval}                  1 min
${Target SW dir}      /home/ute/btsauto/TARGET_SW


*** Keywords ***
TC_loop_7944
    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order  CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_space
    FOR    ${i}     IN RANGE    ${10}
        TC Setup
        Set Test Variable     ${TEST STATUS}     ${False}
        TC_CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_spac
        Log Step Header     Iteration Done ${i}+1
        Set Test Variable    ${ENB_Trunk_Version}     ${release_list_at_select}
        Set Test Variable     ${TEST STATUS}     ${True}
        TC Teardown
    END



TC_CB007944_Robustness_Multiple_SW_Pre_check_No_available_disk_spac
    [Documentation]    Short description.
    precondition: Find path to SW package
    Step1: Precheck and check output for primary and enough
    Step2: Fill stb/tmp partition from primary
    Step3: Precheck and check output for primary and not enough
    Step4: Delete tmp from primary
    Step5: Precheck and check output for primary and enough
    Step6: Fill stb/tmp partition from secondary
    Step7: Precheck and check output for secondary and not enough
    Step8: Delete tmp from secondary
    Step9: Precheck and check output for secondary and enough
    Step10: Fill stb/tmp partition on both primary and secondary
    Step11: Precheck and check output on dual-core for not enough
    Step12: Get sw load and perform sw-upgrade with error and check fault 30
    Step13: Delete tmp from dual-core
    Step14: Perform sw download via Netact and fill stb from primary
    Step15: Execute sw activation from Netact and Check FID30
    Step16: Delete tmp from primary
    Step17: Perform sw-upgrade with no error
    Step18: Verify BTS state after upgrade
    Sleep   10min
    run keyword and ignore error     OperatingSystem.empty directory    ${Target SW dir}
    [Teardown]    Run keywords    Run Keyword And Ignore Error  Delete tmp from primary
    ...    AND  Run Keyword And Ignore Error   Delete tmp from secondary




precondition: Find path to SW package
    [Documentation]    Short description.
    Log Step Header  Find path to SW package
    @{crt_alarms}    create list    30
    set test variable    ${crt_alarms}
    Add CRT Alarms And Initial WatchAlarm    ${crt_alarms}
    Download latest SW from 40
    Find path to SW package
    Run Keyword If  '${Target SW path}'== ${None}   Fail


Download latest SW from 40
    ${Directory_status}=    run keyword and return status    directory should exist    ${Target SW dir}
    run keyword if  ${Directory_status}    OperatingSystem.empty directory    ${Target SW dir}
    ${release_list_at_all}=    get_enb    ${target_release}

    ${release_list_at_select}=     Set Variable If     '${release_list_at_all[0]}' in '${ENB_Trunk_Version}'
    ...    ${release_list_at_all[3]}        ${release_list_at_all[0]}
    Set Test Variable     ${release_list_at_select}     ${release_list_at_select}
    ${SW_path_package}       Download_Specify_Build_By_Aria    ${release_list_at_select}    Basic   ${Target SW dir}
    Set Test Variable     ${Target SW name}    ${release_list_at_select}_release_BTSSM_downloadable_A54
    #Set Test Variable    ${Target SW path}    ${SW_path_package}


Step${index}: Precheck and check output for primary and enough
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Precheck and check output  'Primary'  'Enough space on passive partition'  'Enough space on active partition'

Step${index}: Precheck and check output for primary and not enough
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Precheck and check output  'Primary'  'Not enough space on passive partition'  'Not enough space on active partition'

Step${index}: Precheck and check output for secondary and enough
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Precheck and check output  'Secondary'  'Enough space on passive partition'  'Enough space on active partition'

Step${index}: Precheck and check output for secondary and not enough
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Precheck and check output  'Secondary'  'Not enough space on passive partition'  'Not enough space on active partition'

Step14: Perform sw download via Netact and fill stb from primary
    [Documentation]    Short description.
    ${Target_build_1}    Fetch from right    ${Target SW path}    /
    ${Target_build}    Fetch from left    ${Target_build_1}    _release
    set test variable    ${Target_build}
    ${active_sw_before_master}    ${passive_sw_before_master}=    Infomodel Get SW Versions    module=MSM
    ${release_NUM}=    should match regexp    ${active_sw_before_master}    SBTS\\d+..
    set test variable    ${release_NUM}
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}=  Choose_Mid_Server4Netact  ${NETACT_SERVER_INFO.IP}
    build_download_upload_on_remote_server_and_import_to_Netact  target_sw=${Target_build}
                                                            ...  release_NUM=${release_NUM}
                                                            ...  remote_ip=${Mid_Server}
                                                            ...  remote_usr=${Mid_Server_usr}
                                                            ...  remote_pwd=${Mid_Server_pwd}
    ${sw_download_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${Target SW path}  False  ${SW Update Timeout}
    Run keyword if  '${sw_download_result}'=='FAIL'  Set Test Failed  Software download failed: ${sw_update_msg}
    Step14: Fill stb/tmp partition from primary

Step15: Execute sw activation from Netact and Check FID30
    [Documentation]    Short description.
    Log to Console    After fill stb no space, active from NMS
    sleep    10s
    ${res}    run keyword and return status  _do SW Activate from NetAct    ${sw_release_changed}    30min
    Run keyword if    ${res}    Fail    Activate software should fail after stb no space
    ...    ELSE    Log    Activate software failed as expected after stb no space
    Check fault 30

Precheck and check output
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${core}: <description>
    ...        ${feedback1}: <description>
    ...        ${feedback2}: <description>
    [Arguments]  ${core}  ${feedback1}  ${feedback2}
    ${ReportFilePrecheck_found}  ${ReportFilePrecheck_path}  Check if ReportFilePrecheck is present
    Run keyword if  ${ReportFilePrecheck_found}  Delete ReportFilePrecheck file  ${ReportFilePrecheck_path}
    Log  Start software precheck procedure  console=${TRUE}
    ${status}  ${precheck_result}=   Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Software Precheck Local  sw_package=${TARGET_SW_PATH}  precheck_type=UpgradeCheck
    ${result}  Run keyword if  '${status}'=='PASS'
    ...  Convert To String  ${precheck_result}[reportResult][diskSpaceReport]
    ...  ELSE  set variable  ${precheck_result}

#    ${feed_str}  set variable  'feedback': ${feedback}
#    ${core_str}  set variable  'role': ${core}
#    Should contain  ${result}   ${feed_str}
#    Should contain  ${result}   ${core_str}
    ${f1}  Run keyword and return status  Should contain  ${result}   'feedback': ${feedback1}
    ${f2}  Run keyword and return status  Should contain  ${result}   'feedback': ${feedback2}
    ${f}  set variable if  '${f1}' or '${f2}'  ${TRUE}  ${FALSE}
    Should be true  ${f}
    Should contain  ${result}  'role': ${core}

Step${index}: Fill stb/tmp partition from primary
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Set Connection Parameters  ${SMOD1['TRS_IP']}
#    Set Connection Parameters  ${SMOD1['TRS_IP']}  user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
#    ...  via_ip=${PC_IP1}  via_user=ute  via_password=uteUTE!
#    Login_with_multiway    ${PC_IP1}    ute    uteUTE!
    Run Remote Linux Command  ls /ffs/stb/
    Run Remote Linux Command  mount -o remount rw /ffs/stb/
    Run Remote Linux Command  mkdir /ffs/stb/temp
    Run Remote Linux Command  ls
    Run Remote Linux Command  df -h
    ${status}  Run keyword and return status  Run Remote Linux Command  cp -r /ffs/run/* /ffs/stb/temp/
    sleep  60
    ${content}=  Run Remote Linux Command  df -h
    Log   ${content}
    ${content}  Convert To String  ${content}
    Run keyword if    not ${status}   should contain   ${content}  100% /ffs/

Step${index}: Delete tmp from primary
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Delete tmp from primary

Delete tmp from primary
    [Documentation]    Short description.
    Set Connection Parameters  ${SMOD1['TRS_IP']}
#    Set Connection Parameters  ${SMOD1['TRS_IP']}  user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
#    ...  via_ip=${PC_IP1}  via_user=ute  via_password=uteUTE!
    Run Remote Linux Command  mount -o remount rw /ffs/stb/&&rm -rf /ffs/stb/temp

Step${index}: Fill stb/tmp partition from secondary
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
#    Run keyword if  ${smod2_variable_exists}  Run keywords  Set Connection Parameters  192.168.255.119
#    ...  user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}  via_ip=${PC_IP2}  via_user=ute  via_password=uteUTE!
    Run keyword if  ${smod2_variable_exists}  Run keywords  Set Connection Parameters  fct-4a    via_ip=192.168.255.1
    ...  AND  Continue with secondary common part

Step${index}: Delete tmp from secondary
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Delete tmp from secondary

Delete tmp from secondary
    [Documentation]    Short description.
#    Run keyword if  ${smod2_variable_exists}  Set Connection Parameters  192.168.255.119  user=${SMOD1['USERNAME']}
#    ...  password=${SMOD1['PASSWORD']}  via_ip=${PC_IP2}  via_user=ute  via_password=uteUTE!
    Run keyword if  ${smod2_variable_exists}  Set Connection Parameters    fct-4a    via_ip=192.168.255.1
    Run Remote Linux Command  ls /ffs/stb
    Run Remote Linux Command  mount -o remount rw /ffs/stb/
    Run Remote Linux Command  df -h
    Run Remote Linux Command  rm -r /ffs/stb/temp/
    Sleep  60
    ${content}  Run Remote Linux Command  df -h
    Log  ${content}

Step${index}: Fill stb/tmp partition on both primary and secondary
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Step${index}: Fill stb/tmp partition from primary
    Step${index}: Fill stb/tmp partition from secondary

Step${index}: Precheck and check output on dual-core for not enough
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Precheck and check output  'Primary'  'Not Enough space on passive partition'  'Not Enough space on active partition'
    Precheck and check output  'Secondary'  'Not Enough space on passive partition'  'Not Enough space on active partition'

Step${index}: Get sw load and perform sw-upgrade with error and check fault 30
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    ${pre_active}  ${pre_passive}=  Get active and passive sw versions
    set test variable  ${pre_active}
    run keyword and expect error  *AdminApiProcedureFailureException:*   taf.sbts.oam.coam.admin.Update Software  ${Target SW path}
    ...    True  ${SW Update Timeout}
    Check fault 30

Step${index}: Delete tmp from dual-core
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Delete tmp from primary
    Delete tmp from secondary

Step${index}: Perform sw-upgrade with no error
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
#    Set Connection Parameters  ${SMOD1['TRS_IP']}  user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
#    ...  via_ip=${SMOD1['TRS_IP']}  via_user=${SMOD1['USERNAME']}  via_password=${SMOD1['PASSWORD']}
    Set Connection Parameters  ${SMOD1['TRS_IP']}  user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    ...  via_ip=
    ${sw_update_result}=  taf.sbts.oam.coam.admin.Update Software  ${Target SW path}  True  ${SW Update Timeout}
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed
    sleep  5min
    Wait Until Keyword Succeeds  15 min  10 sec  Fail if connection with admin is not available
    Check fault 30 is inactive

Step${index}: Verify BTS state after upgrade
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    FOR  ${run}  IN RANGE  1  120
        ${all_cell_status}  ${cell_state_table}  Infomodel Check If All Objects From Path Are Online  ${dist_cells}
        Run keyword if  ${all_cell_status} == ${True}  Run Keywords
        ...  Log  All cells online! Check attempt: ${run}  console=${TRUE}
        ...  AND  Exit For Loop
        Sleep  10
    END

Get active and passive sw versions
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${software_info['Active SW version']}: <description>
    ...        ${software_info['Passive SW version']}: <description>
    ${software_info}  taf.sbts.oam.coam.admin.Get Software Info
    [Return]  ${software_info['Active SW version']}  ${software_info['Passive SW version']}

Check fault 30
    [Documentation]    Short description.
    ${exist}=  Run keyword and return status  taf.sbts.oam.coam.admin.assert alarm active
    ...    parameters=faultId=${FAULT_30}[fault_id], severity=${FAULT_30}[alarm_severity],
    ...    alarmId=${FAULT_30}[alarm_id], faultName=${FAULT_30}[fault_name]
    ...    timeout=80
    Should be true  ${exist}

Check fault 30 is inactive
    [Documentation]    Short description.
     ${no_exist}=  Run keyword and return status  taf.sbts.oam.coam.admin.assert alarm inactive
     ...    parameters=faultId=${FAULT_30}[fault_id], severity=${FAULT_30}[alarm_severity],
     ...    alarmId=${FAULT_30}[alarm_id], faultName=${FAULT_30}[fault_name]
     ...    timeout=30
     Should be true  ${no_exist}

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  return from keyword  ${True}
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.reset admin
    ${infomodel_reset_status}  Run keyword and return status
    ...    ute_admin_infomodel.reset infomodel  filename=${BTS Files}/IM/InfoModel_untilReset.ims2
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  return from keyword  ${True}
    Fail  ${admin_reset_status}/${infomodel_reset_status}

Continue with secondary common part
    [Documentation]    Short description.
    Sleep  5
    Run Remote Linux Command  ls /ffs/stb
    Run Remote Linux Command  mount -o remount rw /ffs/stb/
    Run Remote Linux Command  mkdir /ffs/stb/temp/
    Run Remote Linux Command  ls /ffs/stb
    Run Remote Linux Command  df -h
    ${status}   Run keyword and return status  Run Remote Linux Command  cp -r /ffs/run/* /ffs/stb/temp/
    Sleep  180
    ${content} =  Run Remote Linux Command  df -h
    Log  ${content}
    ${content}  Convert To String  ${content}
    Run keyword if    not ${status}   should contain   ${content}  100% /ffs/

Check if ReportFilePrecheck is present
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${is_found}: <description>
    ...        ${ReportFilePrecheck_path}: <description>
    Log  Check if ReportFilePrecheck.xml file is present in /ffs/run/config and delete if present  console=${TRUE}
#    Set Connection Parameters  ${SMOD1['TRS_IP']}  user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
#    ...  via_ip=${PC_IP1}  via_user=ute  via_password=uteUTE!
    Set Connection Parameters    ${SMOD1['TRS_IP']}    via_ip=
    ${status}  ${ReportFilePrecheck_path}  Run keyword and ignore error
    ...  Run Remote Linux Command  find /ffs/run/config/ReportFilePrecheck.xml
    ${is_found}  Set variable if  '${status}'=='FAIL'  ${FALSE}  ${TRUE}
    Run keyword if  '${status}'=='FAIL'  Log  ReportFilePrecheck.xml not found in /ffs/run/config/  console=${TRUE}
    ...  ELSE  Log  ReportFilePrecheck.xml found in /ffs/run/config/  console=${TRUE}
    [Return]  ${is_found}  ${ReportFilePrecheck_path}

Delete ReportFilePrecheck file
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ReportFilePrecheck_path}: <description>
    [Arguments]  ${ReportFilePrecheck_path}
    ${delete_status}  Run keyword and return status  Run Remote Linux Command  rm -f ${ReportFilePrecheck_path}
    Run keyword if  ${delete_status}  Log  ReportFilePrecheck.xml file successfully deleted  console=${TRUE}
    ...  ELSE
    ...  Log Important Message  ReportFilePrecheck.xml file not deleted  level=WARN
