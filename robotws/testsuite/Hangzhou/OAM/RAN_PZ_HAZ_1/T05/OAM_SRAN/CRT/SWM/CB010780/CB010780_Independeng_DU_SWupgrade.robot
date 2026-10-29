*** Settings ***
Documentation     [PURPOSE]
Library            taf.nms.netact
Library            ute_tshark
Library    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Library    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/OperateLog.py
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot

*** Variables ***
${SW Update Timeout}        3600s
${SW Download Timeout}      3600s
${SW Activate Timeout}      600s
${OnAir Check Number}       60
${Ping loss timeout}        ${600}
${Ping regain timeout}      ${300}
${active_Package_dir}       /home/ute/logs/

*** Keywords ***

CB010780_ST_05_02 Independent DU SW upgrade Activate RU Software from NMS
    Sleep   30s
#    [Documentation]    Short description.
#    Step1 prepare bts and choose package for RUSWonly
#    Step1-1 prepare package in NMS
#    Step2 download package to BTS
#    Step3 RU only sw activation from NMS
#    Step4 check RU reset status
#    Step5 check bts and cells OnAir status

CB010780_ST_05_03 Independent DU SW upgrade Activate RU Software_reset sequentially
    Sleep   30s
#    [Documentation]    Short description.
#    Step0 set parameter sequentialRuSwUpgrade true
#    Step1 prepare bts and choose package for RUSWonly
#    Step2 download package to BTS
#    Step3 RU only sw update from webui
#    Step4 check RU reset status
#    Step5 check bts and cells OnAir status

CB010780_ST_05_04 Independent DU SW upgrade Activate RU Software_reset simultaneously
    Sleep    30s
#    [Documentation]    Short description.
#    Step0 set parameter sequentialRuSwUpgrade false
#    Step1 prepare bts and choose package for RUSWonly
#    Step2 download package to BTS
#    Step3 RU only sw update from webui
#    Step4 check RU reset status
#    Step5 check bts and cells OnAir status

CB010780_ST_05_06 Independent DU SW upgrade software Activate WEBUI
    Sleep   30s
#    [Documentation]    Short description.
#    Step1 prepare bts and choose package
#    Step2 download package to BTS
#    Step3 RU only sw update from webui
#    Step4 check RU reset status
#    Step5 check bts and cells OnAir status
#    Step6 activate DU sw from webui
#    Step7 check BTS reset status
#    Step8 check bts and cells OnAir status
#    Step9 check Cpri and Ecpri RU not reset status
#    Step10 SW rollback to previous SW version

[1]CB010780_ST_05_07 Independent DU SW upgrade software activation_NMS
    Sleep    30s
#    [Documentation]    Short description.
#    Step0 set parameter sequentialRuSwUpgrade false
#    Step1 prepare bts and choose package
#    Step1-1 prepare package in NMS
#    Step2 download package to BTS
#   Step3 RU only sw activation from NMS
#    Step4 check RU reset status
#    Step5 check bts and cells OnAir status
#    Step6 DU only sw update from NMS
#    Step7 check BTS reset status
#    Step8 check bts and cells OnAir status
#    Step9 check Cpri and Ecpri RU not reset status
#    Step10 SW rollback to previous SW version

CB010780_ST_05_13 Independent DU SW upgrade_SW provision for RU SW only by WEBEM
    SLeep    30s
#    Step0 set parameter sequentialRuSwUpgrade false
#    Step1 prepare bts and choose package
#    #Step2 download package to BTS
#    Step3 RU only sw provision from webui
#    Step4 check RU reset status
#    Step5 check bts and cells OnAir status
#    Step6 activate DU sw from webui
#    Step7 check BTS reset status
#    Step8 check bts and cells OnAir status
#    Step9 check Cpri and Ecpri RU not reset status
#    Step10 SW rollback to previous SW version

CB010780_ST_05_12 Independent DU SW upgrade_SW provision for RU SW only by NMS
    Sleep    30s
#    [Documentation]    Short description.
#    Step0 set parameter sequentialRuSwUpgrade false
#    Step1 prepare bts and choose package
#    Step1-1 prepare package in NMS
#    Step3 RU only sw provision from NMS
#    Step4 check RU reset status
#    Step5 check bts and cells OnAir status
#    Step6 DU only sw update from NMS
#    Step7 check BTS reset status
#    Step8 check bts and cells OnAir status
#    Step9 check Cpri and Ecpri RU not reset status
#    Step10 SW rollback to previous SW version

CB010780_ST_05_14 Independent DU SW upgrade software activation_with disableSWUpdate=true
    SLeep    30s
#    [Documentation]    Short description.
#    Step0-1 set parameter disableSWUpdate
#    Step1 prepare bts and choose package
#    Step2 download package to BTS
#    Step6 activate DU sw from webui
#    Step4 check RU sw activation disabled and fault 23 reported
#    Step5 set parameter disableSWUpdate false
#    Step3 RU only sw update from webui
#    Step7 check bts and cells OnAir status
#    Step10 SW rollback to previous SW version

TC_CB013660_A_ST_05_01 upgrade during RU SW only activation via NMS Simultaneous
    [Documentation]    Short description.
    Step0 set parameter ruPhaseSwActivationResetPolicy Simultaneous
    Step1 prepare bts and choose package
    Step1-1 prepare package in NMS
    Step3 RU only sw provision from NMS
    Step4 check RU reset status
    Step5 check bts and cells OnAir status
    Sleep    5min
    Step6 DU only sw update from NMS
    Step7 check BTS reset status
    Step8 check bts and cells OnAir status
    Step9 check Cpri and Ecpri RU not reset status
    Step10 SW rollback to previous SW version


TC_CB013660_A_ST_05_04 upgrade for RU SW only by WEBEM
    Step0 set parameter ruPhaseSwActivationResetPolicy Sequential
    Step1 prepare bts and choose package
    #Step2 download package to BTS
    Step3 RU only sw provision from webui
    Step4 check RU reset status
    Step5 check bts and cells OnAir status
    Step6 activate DU sw from webui
    Step7 check BTS reset status
    Step8 check bts and cells OnAir status
    Step9 check Cpri and Ecpri RU not reset status
    Step10 SW rollback to previous SW version

Step0 set parameter sequentialRuSwUpgrade ${sequentialRuSwUpgradevalue}
    Log    ${sequentialRuSwUpgradevalue}
    Sleep   30s

Step0 set parameter ruPhaseSwActivationResetPolicy ${sequentialRuSwUpgradevalue}
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_INFO.ID}/MNL-1  parameter=ruPhaseSwActivationResetPolicy  operation=update  value=${sequentialRuSwUpgradevalue}
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=default
    set test variable    ${sequentialRuSwUpgradevalue}

Step0-1 set parameter disableSWUpdate
    [Documentation]    set disabledSWupdate for RU and get disabled RU list and non disabled RU list
    Get config RU mapping to Runtime RU list
    get disable RU list and set value

Step1 prepare bts and choose package
    [Documentation]    Short description.
    Log Step Header    Step1 prepare bts and choose package
    ${software_info}  taf.sbts.oam.coam.admin.Get Software Info
    Set test variable  ${ACTIVE_SW_BEFORE}  ${software_info['Active SW version']}
    Set test variable  ${PASSIVE_SW_BEFORE}  ${software_info['Passive SW version']}
    @{sw_temp}    split string    ${ACTIVE_SW_BEFORE}    _
    ${current_release}  set variable    ${sw_temp[0]}
    set test variable    ${current_release}
    ${target_sw_path}    Get upgrade path    ${software_info['Active SW version']}  ${software_info['Passive SW version']}
    ...    ${release_list_1}    ${release_list_2}    ${release_list_3}
    Run Keyword If  '${Target SW path}'== ${None}   Fail
    ${file_name}    OperatingSystem.List Directory    ${target_sw_path}
    ${sw_release_name to update}  Get TargetBD Node Attribute Value  softwareReleaseVersion  ${target_sw_path}${file_name[0]}
    Log  TARGET_SW Release Name: ${sw_release_name to update}  console=${TRUE}
    ${sw_version to update}  Should match regexp  $${sw_release_name to update}  SBTS2[1-9]{1}R[1-4]{1}_ENB_[0-9]{4}_[0-9]{6}_[0-9]{6}T?[0-9]?
    ${package_version}=    Run Keyword If    '9999' in '${sw_version to update}'
    ...  Replace String Using Regexp    ${sw_version to update}    SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
    ...    ELSE    Set variable    ${sw_version to update}
    Set test variable  ${TARGET_SW_FULL_PATH}  ${TARGET_SW_PATH}${file_name[0]}
    Set test variable    ${sw_version to update}
    Set test variable    ${package_version}
    check Radio Version before upgrade
    Setup infomodel    address=192.168.255.129    port=443    use_ssl=True    alias=ForRUCheck
    Connect infomodel    alias=ForRUCheck
    ${sequentialRuSwUpgradevalue}    check sequentialRuSwUpgrade value and return
    set test variable    ${sequentialRuSwUpgradevalue}

Step1 prepare bts and choose package for RUSWonly
    [Documentation]    Short description.
    Log Step Header    Step1 prepare bts and choose package for RUSWonly
    ${software_info}  taf.sbts.oam.coam.admin.Get Software Info
    Set test variable  ${ACTIVE_SW_BEFORE}  ${software_info['Active SW version']}
    Set test variable  ${PASSIVE_SW_BEFORE}  ${software_info['Passive SW version']}
    @{sw_temp}    split string    ${ACTIVE_SW_BEFORE}    _
    ${current_release}  set variable    ${sw_temp[0]}
    set test variable    ${current_release}
    ${Target SW path}    Prepare package for RUSWOnly update
    Run Keyword If  '${Target SW path}'== ${None}   Fail
    ${file_name}    OperatingSystem.List Directory    ${Target SW path}
    ${sw_release_name to update}  Get TargetBD Node Attribute Value  softwareReleaseVersion  ${target_sw_path}${/}${file_name[0]}
    Log  TARGET_SW Release Name: ${sw_release_name to update}  console=${TRUE}
    ${sw_version to update}  Should match regexp  $${sw_release_name to update}  SBTS2[1-9]{1}R[1-4]{1}_ENB_[0-9]{4}_[0-9]{6}_[0-9]{6}T?[0-9]?
    ${package_version}=    Run Keyword If    '9999' in '${sw_version to update}'
    ...  Replace String Using Regexp    ${sw_version to update}    SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
    ...    ELSE    Set variable    ${sw_version to update}
    Set test variable  ${TARGET_SW_FULL_PATH}  ${TARGET_SW_PATH}${/}${file_name[0]}
    Set test variable    ${sw_version to update}
    Set test variable    ${package_version}
    check Radio Version before upgrade
    Setup infomodel    address=192.168.255.129    port=443    use_ssl=True    alias=ForRUCheck
    Connect infomodel    alias=ForRUCheck
    ${sequentialRuSwUpgradevalue}    check sequentialRuSwUpgrade value and return
    set test variable    ${sequentialRuSwUpgradevalue}

Prepare package for RUSWOnly update
    [Documentation]    Short description: Prepare package for RUSWOnly update.
    [Arguments]    ${IP}=${down_server}  ${usr}=ute  ${pwd}=ute@dmin5
    ...   ${target_local_path}=/home/ute/logs/sw_For_RU_upgrade
    Set test Variable    ${local_path}    ${target_local_path}
    Set test Variable    ${download_path}    /home/ute/HZOAM/01_BTS_SW/CB010780/CRT
    ${status_curl}=    Run Keyword And Ignore Error    OperatingSystem.Directory Should Exist    ${local_path}
    Run Keyword If    '${status_curl[0]}'=='FAIL'    Create Directory    ${local_path}
    OperatingSystem.Directory Should Exist    ${local_path}
    SSHLibrary.Open Connection    ${IP}
    SSHLibrary.Login    ${usr}    ${pwd}
    ${all_package_list}    SSHLibrary.List Directory    ${download_path}
    ${remote_full_path}    Set Variable    ${download_path}${/}${all_package_list[0]}
    ${local_full_path}    Set Variable    ${local_path}/${all_package_list[0]}
    ${build_exist_local_before}   Run keyword and return status    OperatingSystem.File should exist    ${local_full_path}
    Run keyword if     '${build_exist_local_before}'=='False'
    ...  Run keywords   sftp download    ${IP}  ${usr}    ${pwd}    ${remote_full_path}    ${local_full_path}
    ...  AND    BuiltIn.Log To Console    Finished download build to ${local_full_path}
    SSHLibrary.Close Connection
    [Return]    ${local_path}

Step1-1 prepare package in NMS
    [Documentation]    Short description.
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}    Choose_Mid_Server4Netact
    build_download_upload_on_remote_server_and_import_to_Netact
    ...    ${package_version}    ${current_release}    Basic    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}

check Radio Version before upgrade
    [Documentation]    Short description.
    ${rc_n}  ${rmod_list}=  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all  class_name=RMOD  timeout=60
    set test variable    ${rmod_list_before_upgrade}    ${rmod_list}
    ${radio_with_reset_list}    Create List
    set test variable    ${radio_with_reset_list}

Step2 download package to BTS
    [Documentation]    Short description.
    Log Step Header    Step2 download package to BTS
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...            taf.sbts.oam.coam.admin.Update Software  ${TARGET_SW_FULL_PATH}  False  ${SW Download Timeout}
    run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  SW update failed. Reason: ${sw_update_msg}

Step3 RU only sw update from webui
    [Documentation]    Short description.
    Log Step Header    Step3 RU only sw update from webui
    ${rc_n}  ${rmod_list}=  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all  class_name=RMOD  timeout=60
    set test variable    ${rmod_list}
    Log  Will now perform SW update on RMODs    console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...    taf.sbts.oam.coam.admin.Update Software  ${TARGET_SW_FULL_PATH}  true  ${SW Activate Timeout}
    ...    independent_sw_update_type=RuSwOnly
    # independentSwUpgradeType=RuSwOnly
    run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  RU activation failed. Reason: ${sw_update_msg}

Step3 RU only sw provision from webui
    [Documentation]    Short description.
    Log Step Header    Step3 RU only sw provision from webui
    ${rc_n}  ${rmod_list}=  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all  class_name=RMOD  timeout=60
    set test variable    ${rmod_list}
    Log  Will now perform SW update on RMODs    console=${TRUE}
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...    taf.sbts.oam.coam.admin.Update Software  ${TARGET_SW_FULL_PATH}  true  ${SW Update Timeout}
    ...    independent_sw_update_type=RuSwOnly
    run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  RU activation failed. Reason: ${sw_update_msg}

Step3 RU only sw activation from NMS
    [Documentation]    Short description.
    Log Step Header    Step3 RU only sw activation from NMS
    ${rc_n}  ${rmod_list}=  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all  class_name=RMOD  timeout=60
    set test variable    ${rmod_list}
    Log  Will now perform SW update on RMODs    console=${TRUE}
    _do SW activation from NetAct with RU only  ${sw_version to update}

Step3 RU only sw provision from NMS
    [Documentation]    Short description.
    Log Step Header    Step3 RU only sw provision from NMS
    ${rc_n}  ${rmod_list}=  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all  class_name=RMOD  timeout=60
    set test variable    ${rmod_list}
    Log  Will now perform SW update on RMODs    console=${TRUE}
    _do SW provision from NetAct with RU only  ${sw_version to update}

Step4 check RU reset status
    [Documentation]    Short description.
    Log Step Header    Step4 check RU reset status
    Log  Wait until rmods reset (operationalState Disabled)  console=${TRUE}
    # ${value}    check sequentialRuSwUpgrade value and return
    run keyword if    '${sequentialRuSwUpgradevalue}'=='Sequential'    RU reset sequentially checking
    run keyword if    '${sequentialRuSwUpgradevalue}'=='Simultaneous'    RU reset simultaneously checking
    #run keyword if    '${sequentialRuSwUpgradevalue}'=='Together${Empty}per${Empty}band'    RU reset sequentially checking
    #run keyword if    '${sequentialRuSwUpgradevalue}'=='Together${Empty}per${Empty}HW${EMpty}type'    RU reset sequentially checking
    #run keyword if    '${sequentialRuSwUpgradevalue}'=='User${Empty}configuration'    RU reset sequentially checking

Step4 check RU sw activation disabled and fault 23 reported
    [Documentation]    Short description.
    Log Step Header    Step4 check RU sw activation disabled and fault 23 reported
    check fault 23 reported correct on RU

Step${n1} check bts reset status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${n1}: <description>
    Log Step Header    Step${n1} check bts reset status
    Log  Update procedure ended${\n}Waiting for ping loss  console=${TRUE}
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}
    ...  timeout=${Ping loss timeout}
#    Run Keyword If  ${ping loss status}==${False}  Set Test Failed  Ping has not been lost within timeout
    Log  Waiting for ping regain  console=${TRUE}
    ${ping_regain_status}  Run keyword and return status  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}
    ...  timeout=${Ping regain timeout}
    Run Keyword If  ${ping_regain_status}==${False}  Set Test Failed  Ping has not been regained within timeout
#    Run Keyword If  ${SMOD2_exists}  Validate ESM Update  ${esm_updater}
    Log  Checking if BTS is stable after update  console=${TRUE}
    ${bts_stability_check}  Run keyword and return status  Check if target is stable  ip=${SMOD1['TRS_IP']}
    ${Admin working state}  hran_admin.Reset admin and infomodel connection if broken
    Run keyword if    not ${Admin working state}  Fail  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}


Step${n2} check bts and cells ${status} status
    [Documentation]    Short description.
    Log Step Header  Step${n2} check bts and cells ${status} status
    check bts OnAir status
    Check all cells OnAir status

check bts ${btsstatus} status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${btsstatus}: <description>
    Log  Will now check if BTS is ${btsstatus} maximum of ${onAir Check Number} times with 10s interval.  console=${TRUE}
    FOR  ${run}  IN RANGE  1  ${onAir Check Number}
        ${Current_BTS_status}  taf.sbts.oam.coam.admin.Get Mrbts State
        Run keyword if  '${Current_BTS_status}' == '${btsstatus}'  Run Keywords  Log  BTS is ${btsstatus}! Check attempt: ${run}
        ...  console=${TRUE}
        ...  AND  Return from keyword
        Sleep  10
    END
    Set Test Failed  BTS not ${btsstatus} within timeout

Check all cells OnAir status
    [Documentation]    Short description.
    ${admin_working_state}  Run keyword and return status  hran_admin.Admin and Infomodel connections reset
    ...  reset_req=${TRUE}
    Run keyword if    not ${admin_working_state}  Fail
    ...  Admin and/or infomodel failure after reset. Interface reset did not help.  console=${TRUE}
    #Sleep    300
    ${ping_status}  Check If Target Is Stable  ip=192.168.255.129  min_uptime=300  max_downtime=300  timeout=900
    Log  Will now wait for all cells to be online. Will check every 10 seconds untill success or TC timeout (30min).
    ...  console=${TRUE}
    FOR  ${run}  IN RANGE  1  420
        ${all_cell_status}    ${cell_state_table}   Run keyword and ignore error
        ...    Infomodel Check If All Objects From Path Are Online  ${dist_cells}
        Run keyword and ignore error    Run keyword if  '${all_cell_status}' == 'PASS'  Run Keywords
        ...  Log  All cells online! Check attempt: ${run}  console=${TRUE}
        ...  AND  Exit For Loop
    END

Step6 activate DU sw from webui
    [Documentation]    Short description.
    Log Step Header    Step6 activate DU sw from webui
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...            taf.sbts.oam.coam.admin.Update Software  ${TARGET_SW_FULL_PATH}  true  ${SW Activate Timeout}
    run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  DU activation failed. Reason: ${sw_update_msg}

Step6 DU only sw update from NMS
    [Documentation]    Short description.
    Log Step Header    Step6 DU only sw update from NMS
    ${rc_n}  ${rmod_list}=  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all  class_name=RMOD  timeout=60
    set test variable    ${rmod_list}
    Log  Will now perform SW update on RMODs    console=${TRUE}
    Sleep     20min
    _do SW Activate from NetAct  ${sw_version to update}  600

Step9 check Cpri and Ecpri RU not reset status
    [Documentation]    Short description.
    Log Step Header    Step9 check Cpri and Ecpri RU not reset status
    Get Cpri and Ecpri RU list
    check Cpri and Ecpri RU not reset

Get Cpri and Ecpri RU list
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${ECpri_Cpri_RU_list}: <description>
    ${rc_n}  ${rmod_list}=  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all  class_name=RMOD  timeout=60
    ${ECpri_Cpri_RU_list}     Create List
    FOR  ${l3Pro_check_radio}  IN ZIP  ${rmod_list}
        ${status}  Check If RMOD Is Disabled  ${l3Pro_check_radio}
        Run Keyword If  '${l3Pro_check_radio['l3Protocol']}'=='ECPRI_MPLANE' or '${l3Pro_check_radio['l3Protocol']}'=='CPRI_RP1'
        ...    append to list    ${ECpri_Cpri_RU_list}    ${l3Pro_check_radio}
    END
    set test variable    ${ECpri_Cpri_RU_list}
    [Return]  ${ECpri_Cpri_RU_list}

check Cpri and Ecpri RU not reset
    [Documentation]    Short description.
    # check log : send RESET_TASK with Type_CloseVirtualConnection for BTS_L-4/EQM_L-1/RMOD_L-2/RU_L-1
    Log Step Header    check Cpri and Ecpri RU not reset
    Run Keyword If    ${infomodel_started}    Run Keyword And Continue On Failure    Teardown Infomodel    alias=default
    ${rid}    _Get Runtime ID By Infomodel for780
    Run Keyword And Continue On Failure    Start Infomodel
#    run keyword and ignore error    taf.sbts.oam.coam.admin.Teardown Admin
    ${MOID}  set variable    /MRBTS-1/RAT-1/BTS_L-${rid}/EQM_L-1/
    ${RU_L_list}    Create list
    FOR  ${ID}  IN RANGE    1    10
        ${result}=    run keyword and ignore error    Get Parameter Value By Admin    /MRBTS-1/RAT-1/BTS_L-${rid}/EQM_L-1/RMOD_L-${ID}
        ${l3Protocol}    run keyword if    "${result[0]}"=="PASS"
        ...    Get Parameter Value By Admin     /MRBTS-1/RAT-1/BTS_L-${rid}/EQM_L-1/RMOD_L-${ID}    l3Protocol
        run keyword if    "${l3Protocol}"=="ECPRI_MPLANE" or "${l3Protocol}"=="CPRI_RP1"
        ...  append to list  ${RU_L_list}
        ...  'send RESET_TASK with Type_CloseVirtualConnection for /MRBTS-1/RAT-1/BTS_L-${rid}/EQM_L-1/RMOD_L-${ID}/RU_L-1'
    END

    FOR  ${radio_Notreset_Checklog}  IN ZIP  ${RU_L_list}
#         taf.sw.syslog.message_should_exist_in_syslog_file    ${radio_Notreset_Checklog}
         syslog contains    ${UDPLogs}/     ${radio_Notreset_Checklog}
    END

check sequentialRuSwUpgrade value and return
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${value}: <description>
    run keyword and ignore error    Teardown Infomodel
    ${rid}    _Get Runtime ID By Infomodel for780
    run keyword and ignore error    taf.sbts.oam.coam.admin.Teardown Admin
    ${NPID}  set variable    /MRBTS-1/RAT-1/BTS_L-${rid}/BTS_CONF-1/NP-1
    FOR  ${ID}  IN RANGE    1    50
        ${result}=    run keyword and ignore error    Get Parameter Value By Admin    /MRBTS-1/RAT-1/BTS_L-${rid}/BTS_CONF-1/NP-${ID}
        ${NPID}    set variable if    "${result[0]}"=="PASS"    /MRBTS-1/RAT-1/BTS_L-${rid}/BTS_CONF-1/NP-${ID}    ${NPID}
        Exit For Loop If    "${result[0]}"=="PASS"
    END
    run keyword and ignore error    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    ${result}    run keyword and ignore error    Get Parameter Value By Admin
    ...    ${NPID}/SCF-1/MRBTS_A-${BTS_INFO.ID}/MNL_A-1    ruPhaseSwActivationResetPolicy
    ${value}    set variable if    "${result[0]}"=="PASS"    ${result[1]}    false
    start admin
    Start Infomodel
    [Return]  ${value}

RU reset simultaneously checking
    [Documentation]    Short description.
    ${rmod_notreset_list}    create list
    ${radio_reset_list}    create list
    set test variable    ${rmod_notreset_list}
    set test variable    ${radio_reset_list}
    sleep  600s
    Save Infomodel log    ForRUCheck.ims2    alias=ForRUCheck
#    Log to console with time  RMOD/s are resetting
    ute_admin_infomodel.Initialize Ims2 Validator    ForRUCheck.ims2
    ${rc_n}  ${rmod_list}=  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all  class_name=RMOD  timeout=60
    FOR  ${RU}  IN ZIP  ${rmod_list}
        ute_admin_infomodel.Add Expected Ims2 Event
        ...  change ${RU['id']} [operationalState: enabled -> disabled]
        ${result}=    Run Keyword And Ignore Error    ute_admin_infomodel.Validate Ims2    alias=hfv
        run keyword if    '${result[0]}'=='FAIL'    append to list    ${rmod_notreset_list}    ${RU}
        run keyword if    '${result[0]}'=='PASS'    append to list    ${radio_reset_list}    ${RU}
    END
    check Radio Version after upgrade    ${rmod_notreset_list}    ${radio_reset_list}   ${rmod_list_before_upgrade}

check RU reset test
    [Documentation]    Short description.
    ute_admin_infomodel.Initialize Ims2 Validator    /home/ute/Downloads/check.ims2
    ute_admin_infomodel.Add Expected Ims2 Event
    ...  change /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2 [operationalState: enabled -> disabled]
    ${result}=    Run Keyword And Ignore Error    ute_admin_infomodel.Validate Ims2    alias=hfv
        run keyword if    '${result[0]}'=='FAIL'    RU not reset
        run keyword if    '${result[0]}'=='PASS'    RU reset
    Log    Validation Succeed

check Radio Version after upgrade
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${NO_reset_RU_list}: <description>
    ...        ${reset_RU_list}: <description>
    ...        ${rmod_list_before_upgrade}: <description>
    [Arguments]    ${NO_reset_RU_list}    ${reset_RU_list}     ${rmod_list_before_upgrade}
    run keyword if    ${NO_reset_RU_list}!=[]    check non reset RU version not changed    ${NO_reset_RU_list}    ${rmod_list_before_upgrade}
    run keyword if    ${reset_RU_list}!=[]    check reset RU version changed    ${reset_RU_list}    ${rmod_list_before_upgrade}

check non reset RU version not changed
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${NO_reset_RU_list}: <description>
    ...        ${rmod_list_before_upgrade}: <description>
    [Arguments]    ${NO_reset_RU_list}     ${rmod_list_before_upgrade}
    ${rc_n}  ${rmod_list}=  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all  class_name=RMOD  timeout=60
    set test variable    ${rmod_list_after_upgrade}   ${rmod_list}
    # check RU version is same with version before upgrade
    FOR  ${NO_reset_RU}  IN ZIP  ${NO_reset_RU_list}
            ${buildversion}    Get RU version with SN    ${NO_reset_RU['serialNumber']}    ${rmod_list_before_upgrade}
            should be true    '${buildversion}'    '${NO_reset_RU['buildVersion']}'
    END

check reset RU version changed
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${reset_RU_list}: <description>
    ...        ${rmod_list_before_upgrade}: <description>
    [Arguments]    ${reset_RU_list}     ${rmod_list_before_upgrade}
    ${rc_n}  ${rmod_list}=  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all  class_name=RMOD  timeout=60
    set test variable    ${rmod_list_after_upgrade}   ${rmod_list}
    FOR  ${reset_RU}  IN ZIP  ${reset_RU_list}
            ${buildversion}    Get RU version with SN    ${reset_RU['serialNumber']}    ${rmod_list_before_upgrade}
            run keyword if    '${buildversion}'=='${reset_RU['buildVersion']}'    Fail    RU reset without Version update!
    END

Get RU version with SN
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SN}: <description>
    ...        ${RU_list}: <description>
    ...
    ...    Returns:
    ...        ${RUversion}: <description>
    [Arguments]    ${SN}    ${RU_list}
    ${RUversion}    set variable    ''
    FOR  ${RU}  IN ZIP  ${RU_list}
        ${RUversion}    set variable if    '${RU['serialNumber']}'=='${SN}'     ${RU['buildVersion']}
        return from keyword if    '${RU['serialNumber']}'=='${SN}'    ${RUversion}
    END
    [Return]    ${RUversion}

Check If RMOD Is Disabled
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${radio_with_reset_check}: <description>
    ...
    ...    Returns:
    ...        ${FALSE}: <description>
    [Arguments]  ${radio_with_reset_check}
    Return From Keyword If  'isabled' in '${radio_with_reset_check['operationalState']}'  ${TRUE}
    [Return]  ${FALSE}

Common Transform Wireshark to Txt
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${wiresharkcaplogpath}: <description>
    ...        ${filterconditions}: <description>
    ...        ${txtname}: <description>
    ...
    ...    Returns:
    ...        ${retFilePath}: <description>
    [Arguments]    ${wiresharkcaplogpath}    ${filterconditions}    ${txtname}=tshark.txt
    ${retFilePath}    Set Variable    ${BTSFiles}${/}${txtname}
    ${PC_connection}    open connection    ${BTS_PC_INFO.IP}
    login with public key    ${BTS_PC_INFO.USERNAME}    /home/${BTS_PC_INFO.USERNAME}/.ssh/id_rsa
    SSHLibrary.Switch Connection    ${PC_connection}
    SSHLibrary.Write    cd /home/ute/
    sleep    4s
    SSHLibrary.Write    tshark -r "${wiresharkcaplogpath}" -Y "${filterconditions}" -x -V> "${retFilePath}"
    Wait Until Keyword Succeeds    10    5s    File Should Not Be Empty    ${retFilePath}
    Comment    Append To File    ${retFilePath}    Frame 99999: 66 bytes on wire (528 bits), 66 bytes captured (528 bits)
    [Return]    ${retFilePath}

Check active alarms
    [Documentation]    Short description.
    Log Step Header  Check active alarms
    ${CRITICAL_ALARMS1}=    Create Dictionary  severity=Major
    ${CRITICAL_ALARMS2}=    Create Dictionary  severity=Critical
    ${CRITICAL_PATTERNS}=   Create List  ${CRITICAL_ALARMS1}   ${CRITICAL_ALARMS2}
    ${alarms_status}  ${alarms_return}=    Run Keyword And Ignore Error    Admin Check Active Alarms
    ...  critical_patterns=${CRITICAL_PATTERNS}
    Run keyword if   '${alarms_status}'=='FAIL'  Fail                  Major/Critical alarm found.
    Run keyword if    ${alarms_return}           Set Test Restriction  Minor alarm found.

Start to capture wireshark log
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${logname}: <description>
    [Arguments]    ${logname}
    SSHLibrary.Switch Connection    ${BTS_Connection}
    ${listen port}    Set Variable    ${BTS_INFO.IP}
    ${cmd}    Set Variable    tcpdump -i any -s 0 -n -nn ip host ${listen port} -w /tmp/${logname}
    SSHLibrary.Write    ${cmd}
    sleep    4s

Stop to capture wireshark log
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${logname}: <description>
    [Arguments]    ${logname}
    SSHLibrary.Switch Connection    ${BTS_Connection}
    SSHLibrary.Write    pkill -f \ tcpdump
    sleep    4s
    SSHLibrary.Write    du -h *RP002315_05_01*
    sleep    4s
    Sftp Download    192.168.255.1    toor4nsn    oZPS0POrRieRtu    /tmp/${logname}    ${BTSFiles}${/}${logname}
    Common Transform Wireshark to Txt    ${BTSFiles}${/}${logname}    tcp    tshark.txt

Perform SW Download
    [Documentation]    Short description.
    Setup Ta Netact Swm Operations    web_url=${NETACT_SERVER_INFO.URL}    web_user=${NETACT_SERVER_INFO.USERNAME}
    ...    web_pass=${NETACT_SERVER_INFO.PASSWORD}
    ${log}    swm download    ${BTS_INFO.MRBTS}    ${sw_release}    alias=ta_netact
    Should Contain    ${log}    SUCCESS

Perfrom SW Activation
    [Documentation]    Short description.
    Setup Ta Netact Swm Operations    ${NETACT_SERVER_INFO.URL}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ${log}    Swm Activate    ${BTS_INFO.MRBTS}    ${download_SW_build}    alias=ta_netact
    Should Contain    ${log}    SUCCESS
    Teardown Ta Netact Swm Operations

Get config RU mapping to Runtime RU list
    [Documentation]    Short description.
    ${config_mapto_RT_RU_list}    create list
    ${config_RU_list}    create list
    ${rc_n}  ${rmod_list}=  run keyword and ignore error  taf.sbts.oam.coam.admin.get_parameters_for_all  class_name=RMOD  timeout=60
    FOR  ${check_radio}  IN ZIP  ${rmod_list}
        ${configDNresult}=      Run Keyword And Ignore Error    Get Parameter Value By Admin        ${check_radio['id']}     configDN
        ${config_RU}    set variable    MRBTS-${BTS_INFO.ID}/EQM-1/APEQM-1/RMOD-${configDNresult[1]}[-1]
        Run Keyword If  '${configDNresult[0]}'=='PASS'    append to list    ${config_RU_list}    ${config_RU}
        ${RUmap}   run keyword If  '${configDNresult[0]}'=='PASS'
        ...  Create Dictionary
        ...  RUSN=${check_radio['serialNumber']}
        ...  configRU=${config_RU}
        ...  RuntimeRU=${check_radio['id']}
        Run Keyword If  '${configDNresult[0]}'=='PASS'    append to list    ${config_mapto_RT_RU_list}    ${RUmap}
    END
    set test variable   ${config_mapto_RT_RU_list}

get disable RU list and set value
    [Documentation]    Short description.
    ${RU_NUM}    evaluate    len(${config_mapto_RT_RU_list})
    ${disable_RU_NUM}    evaluate    random.randint(1, ${RU_NUM})
    ${radio_disableupgrade_map_list}    set variable    ${config_mapto_RT_RU_list}[:${disable_RU_NUM}]
    ${radio_swupgrade_map_list}    set variable    ${config_mapto_RT_RU_list}[${disable_RU_NUM}:]
    ${disabledupgrade_RUSN_list}   set parameter for RU    ${radio_disableupgrade_map_list}  true
    ${swupgrade_RUSN_list}   set parameter for RU   ${radio_swupgrade_map_list}   false
    set test variable    ${disabledupgrade_RUSN_list}
    set test variable    ${swupgrade_RUSN_list}

set parameter for RU
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${radio_list}: <description>
    ...        ${value}: <description>
    ...
    ...    Returns:
    ...        ${RUSN_list}: <description>
    [Arguments]    ${radio_list}    ${value}=true
    ${RUSN_list}    create list
    FOR  ${check_radio}  IN ZIP  ${radio_list}
        taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
        ...  dist_name=${check_radio.configRU}  parameter=disableSWUpdate  operation=update  value=${value}
        ...  skip_parameter_relation_errors=True  should_activate=True  alias=default
        append to list    ${RUSN_list}    ${check_radio.RUSN}
    END
    [Return]    ${RUSN_list}

get RU list reported with fault23
    [Documentation]    Short description.
    ...    Returns:
    ...        ${RUlist_with_Fault23}: <description>
    @{active_alarms} =  taf.sbts.oam.coam.admin.Get Active Alarms
    ${RUlist_with_Fault23}  create list
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=${TRUE}
        run keyword If
        ...  '${alarm.faultId}'=='23' and 'RMOD' in '${alarm.notifier}'
        ...  append to list  ${RUlist_with_Fault23}    ${alarm.serialNumber}
    END
    [Return]    ${RUlist_with_Fault23}


check fault 23 reported correct on RU
    [Documentation]    Short description.
    ${RUlist_with_Fault23}    get RU list reported with fault23
    should be true    ${RUlist_with_Fault23} in ${disabledupgrade_RUSN_list}
    ${disupgrade_RUlist_wo_fault23}    Evaluate    ${disabledupgrade_RUSN_list} substract ${RUlist_with_Fault23}
#    check RU SW not changed which not reported fault23    ${disupgrade_RUlist_wo_fault23}

check RU SW not changed which not reported fault23
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${radio_list}: <description>
    [Arguments]    ${radio_list}
    log  check RU SW not changed which not reported fault23 according TargetBD

Step5 set parameter disableSWUpdate false
    [Documentation]    Short description.
    set parameter for RU    ${disabledupgrade_RUSN_list}    false

RU reset sequentially checking
    [Documentation]    Short description.
    ${RU_UPDATE_SN_LIST}    Get All RU need SW update according TargetDB
    ${RU_NUM}    evaluate    len(${RU_UPDATE_SN_LIST})
    FOR   ${run}  IN RANGE  1  ${RU_NUM}
         ${reset_RU_SN}    Wait Until Keyword Succeeds     15min   10s    check only one RMOD reset
         run keyword if    ${reset_RU_SN} in ${RU_UPDATE_SN_LIST}  remove from list   ${RU_UPDATE_SN_LIST}  ${reset_RU_SN}
         run keyword if    ${reset_RU_SN} not in ${RU_UPDATE_SN_LIST}    Fail   RU reset unexpected
         Wait Until Keyword Succeeds     10min   10s    Check given RMOD enabled    ${reset_RU_SN}
    END

check only one RMOD reset
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${reset_RU_SN}: <description>
    Wait Until Keyword Succeeds    10min    1s     taf.sbts.oam.coam.admin.Assert Any     RMOD     operationalState=disabled
    @{rmod_list}=       taf.sbts.oam.coam.admin.get_parameters_for_all     class_name=RMOD
    ...    timeout=60
    ${Chance} =     Set Variable    1
    ${reset_RU_SN}    Create List
#    Log     ${rmod_list}[1]
    FOR      ${Rmod}   IN    @{rmod_list}
       Run Keyword If     '${Rmod}[operationalState]'=='enabled'     Continue For Loop
       ${Chance}=      Run Keyword If     '${Rmod}[operationalState]'=='disabled'    Evaluate     ${Chance}-1
       Run Keyword If     '${Rmod}[operationalState]'=='disabled'    append to list    ${reset_RU_SN}    ${Rmod}[serialNumber]
       Run Keyword If     ${Chance}<0     FAIL     two RMOD ${reset_RU_SN} reset at same time
    END
    [Return]    ${reset_RU_SN}

Check given RMOD enabled
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${radio_SN}: <description>
    [Arguments]    ${radio_SN}
    ${RU_STATE_Enabled}    set variable    False
    @{rmod_list}=       taf.sbts.oam.coam.admin.get_parameters_for_all     class_name=RMOD
    FOR      ${Rmod}   IN    @{rmod_list}
       ${RU_STATE_Enabled}   Run Keyword If    '${Rmod}[operationalState]'=='enabled' and '${Rmod}[serialNumber]'=='${radio_SN}[serialNumber]'
       ...     set variable    True
        Run Keyword If   '${RU_STATE_Enabled}'=='True'    Exit For Loop
    END
    Run Keyword If     '${RU_STATE_Enabled}'=='false'     FAIL     RMOD ${reset_RU_SN} still not enable

Get All RU need SW update according TargetDB
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${RU_UPDATE_SN_LIST}: <description>
#    [Arguments]    ${TargetDBfile}=${BTS Files}/TargetBD_${sw_version to update}.xml
    ${RU_UPDATE_SN_LIST}    create list
     @{rmod_list}=       taf.sbts.oam.coam.admin.get_parameters_for_all     class_name=RMOD
     FOR      ${Rmod}   IN    @{rmod_list}
       ${RU_Verion}    Get RU version from TargetDB    ${Rmod}[productName]
       ${RU_need_to_update}   Run Keyword If    '${Rmod}[buildVersion]'!='${RU_Verion}[0]'
       ...  append to list    ${RU_UPDATE_SN_LIST}   ${Rmod}[serialNumber]
    END
    [Return]    ${RU_UPDATE_SN_LIST}

Get RU version from TargetDB
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${radioType}: <description>
    ...        ${originTargetDBpath}: <description>
    ...
    ...    Returns:
    ...        ${RU_Verion}: <description>
    [Arguments]    ${radioType}    ${originTargetDBpath}=/rom/patchedFiles
    ${status}    ${result}=    Run Keyword And Ignore Error
    ...  Get File From System Module    source_path=${originTargetDBpath}/TargetBD_${sw_version to update}.xml    destination_path=${BTS Files}/
    Run Keyword If    '${status}'=='PASS'    Log    TargetBD from System module collected    console=${True}
    ...    ELSE
    ...  Run Keyword    Log    TargetBD could not be retrieved from System Module! Error: ${result}
    ...  console=${True}
    ${xml}    OperatingSystem.Get File    ${result}
    ${xpath}    set variable    //*[contains(@resourceBuildKey, '${radioType}')]/@resourceSWVersion
    ${RU_Verion}=    evaluate_xml_xpath    ${xml}    ${xpath}
    [Return]    ${RU_Verion}

Step10 SW rollback to previous SW version
    Log Step Header    Step10 SW rollback to previous SW version
    SW rollback

_Get Runtime ID By Infomodel for780
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${runtime_id}: <description>
    Start Infomodel
    ${runtime_id}   Set Variable    1
    FOR    ${index}    IN RANGE    1    5
        ${result}    Run Keyword And Return Status
        ...    ute_admin_infomodel.Query Infomodel    /MRBTS-1/RAT-1/RUNTIME_VIEW-${index}    alias=default
        ${runtime_id}=    Set Variable If    ${result}    ${index}    ${runtime_id}
        Exit For Loop If    ${result}
    END
    [Teardown]    Teardown Infomodel
    [Return]    ${runtime_id}

SW rollback
    ${result}    run keyword and return status    taf.sbts.oam.coam.admin.rollback_software
    Run Keyword If    '${result}'=='FAIL'    FAIL    rollback to previous
    sleep    480s
    ${ACTIVE_SW}    ${PASSIVE_SW}    Admin Get BTS SW Version _
    ${build_exist_local_before}   Run keyword and return status    OperatingSystem.Directory should exist    ${active_Package_dir}Basic
    run keyword if  '${build_exist_local_before}'=='False'
    ...  Download_Specify_Build_By_Aria    ${ACTIVE_SW}    Basic    ${active_Package_dir}Basic${/}
    ${package name}  OperatingSystem.List files in directory  ${active_Package_dir}Basic
    ${SW_PATH_package}=  Join Path 	${active_Package_dir}Basic${/}  ${package name[0]}
    Fault23 check and update software to Onair    ${SW_PATH_package}
