*** Settings ***
Library    taf.selenium.sbts     WITH NAME     selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
#Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008680/keywords_8680.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource    ${BASIC_PATH_5G}/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource      ${BASIC_PATH_5G}/Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module.robot
Resource       ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource             ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource             ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource          ${BASIC_PATH_5G}/Manual_SiSo_SM_BTS_Site_Reset.robot
Resource    ${BASIC_PATH_5G}/Manual_SiSo_SM_RF_Module_lock_unlock.robot
Resource       ${BASIC_PATH_5G}/Manual_SiSo_REC_Radio_Module_power_reset.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
...    AND     CI_interface.Common Suite Setup
Suite Teardown   robot_common_operations.Common Suite Teardown
Test Setup       robot_common_operations.Common Case Setup
Test Teardown    robot_common_operations.Common Case Teardown

*** Variables ***

${TS_CASE_LOG_PATH}      /home/ute/test_results
${gnb_index}   0
${MAX_LOOP}       3
${mrbtsID}        ${tl.gnbs[0].instance_id}
${nrbtsID}        ${tl.gnbs[0].global_bts_id}
${SCF_PATH}       ${CURDIR}/SCF
@{timezone_list}      (GMT+8) Asia/Shanghai    (GMT+0) Europe/London
${SAVE LOG DIRECTORY}    /home/ute/test_results
${if_pdl_check}       True
${gNb_CuType}         SA
#${ue_index}     0
#${ue_type}       huawei
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${du_index}                    0


${ENB_PATH}  MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}
${lnrel_dist}  ${ENB_PATH}/LNCEL-1
${lnrel_para1}    administrativeState


*** Test Cases ***
[1.0] Common_SiSo_Call_Multi UE throughput testing
    [Tags]  test

    UE SetUp

    Connect to gnb coam via ssl
    Wait until keyword succeeds    5min    30s    verify all cells should be onair

    scf.Activate Parameter Value    dist_name=MRBTS-1911/NRBTS-10958/NRCELL-1    p_name=cellBarred    new_value=notBarred
    scf.Activate Parameter Value    dist_name=MRBTS-1911/NRBTS-10958/NRCELL-2    p_name=cellBarred    new_value=notBarred
    sleep  120s


    scf.Activate Parameter Value    dist_name=MRBTS-1911/NRBTS-10958/NRCELL-1    p_name=cellBarred    new_value=barred
    sleep  60s
    Power UE L3 Call   ue_type=huawei   ue_index=${0}   physCellId=207    cell_index=${1}
    power_ue.UE Detach    ue_type=huawei   ue_index=${0}

    scf.Activate Parameter Value    dist_name=MRBTS-1911/NRBTS-10958/NRCELL-1   p_name=cellBarred   new_value=notBarred
    scf.Activate Parameter Value    dist_name=MRBTS-1911/NRBTS-10958/NRCELL-2    p_name=cellBarred    new_value=barred
    sleep  60s


    Power UE L3 Call   ue_type=huawei   ue_index=${0}   physCellId=206  cell_index=${0}


    scf.Activate Parameter Value    dist_name=MRBTS-1911/NRBTS-10958/NRCELL-2   p_name=cellBarred   new_value=notBarred
    sleep  60s
  #  Power UE L3 Call   ue_type=huawei   ue_index=${0}   physCellId=207     cell_index=${1}

    power_ue.UE Detach    ue_type=huawei    ue_index=${0}
  # power_ue.UE Detach    ue_type=huawei   ue_index=${0}


CB009472_B_001_bbmodBoardConfigType_with_RF_split_over_ABIP
    [Tags]
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}

    log to console    ***Modify bbmodBoardConfigType parameter***

    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
        ...    filter_param=Baseband board configuration type
        ...    abbr=bbmodBoardConfigType    new_value=Auto

    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2
        ...    filter_param=Baseband board configuration type
        ...    abbr=bbmodBoardConfigType    new_value=Auto

    selenium_coam.validate_plan

    sleep   10s
    ${defErrs_dic}    selenium_coam.get_hardware_errors
    ${list_num}   Get Length   ${defErrs_dic}
    Should be true    ${list_num}!=${0}

    sleep   10s

    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
        ...    filter_param=Baseband board configuration type
        ...    abbr=bbmodBoardConfigType    new_value=NRTDD

    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2
        ...    filter_param=Baseband board configuration type
        ...    abbr=bbmodBoardConfigType    new_value=NRTDD

    selenium_coam.validate_plan
    ${defErrs_dic}    selenium_coam.get_hardware_errors
    ${list_num}   Get Length   ${defErrs_dic}
    Should be true    ${list_num}==${0}
    selenium_coam.activate_plan


    sleep    3s
    ${currentValue1}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...  filter_param=Baseband board configuration type
    ${currentValue2}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2
    ...  filter_param=Baseband board configuration type
    Should be Equal    ${currentValue1}    NRTDD
    Should be Equal    ${currentValue2}    NRTDD

    [Teardown]   selenium logout and close browser

#
#[2.0] Manual_SiSo_SM_NR_RAT_reset
#    [Tags]  9472
#    Connect to gnb coam via ssl
#    Wait until keyword succeeds    5min    30s    verify all cells should be onair
#    coam.rat_reset       rat_type=NR     timeout=300    connection=GNB_OAM
#    Sleep    120s
#    Wait until keyword succeeds    20min    30s    verify all cells should be onair
#    COAM Teardown gnb connections
#
#
#[2.1] General_SiSo_Cell_block_and_unblock
#    [Tags]   9472
#    CI_interface.Common Suite Setup
#    Connect to gnb coam via ssl
#    General_SiSo_Cell_block_and_unblock
#    COAM Teardown gnb connections
#
#[1.0] Manual_SiSo_SM_BTS_Site_Reset
#    [Tags]   9472
#    CI_interface.Common Suite Setup
#    Connect to gnb coam via ssl
#    Manual_SiSo_SM_BTS_Site_Reset
#    COAM Teardown gnb connections
#
#
#[1.0] Manual_SiSo_STARTUP_SCF
#    [Tags]     9472
#    Connect to gnb coam via ssl
#    Manual_SiSo_STARTUP_SCF
#    COAM Teardown gnb connections
#
#
#
#[1.0] Manual_SiSo_STARTUP_BTS_Power_Reset
#    [Tags]     9472
#    FOR	 ${i}	IN RANGE	3
#        Perform Site Power Off
#        sleep    180s
#        Perform Site Power On
#        sleep    180s
#        Connect to gnb coam via ssl
#        Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#        csn.reset_cache
#    END



*** Keywords ***
Power UE L3 Call
    [Arguments]  ${ue_type}    ${ue_index}  ${physCellId}   ${cell_index}    ${call_time}=200       ${log_time}=3m
    ...  ${actCarrierAggregation}=${False}    ${tput_UL}=10M      ${tput_DL}=100M

    #power_ue.Prepare UE    ue_type=${ue_type}     ue_index=${ue_index}


    #Lock nr cell
    #Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=locked
    #sleep    60s

    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    #Reboot UE If no UE IP    ue_index=${ue_index}
    Wait until keyword succeeds    3X  60s  Verify attach by adb    physCellId=${physCellId}    attach_mode=5G_SA
    ...    ue_index=${ue_index}

    ${iperf_type}   Set Variable If    "${ue_type}" == "huawei"   via_app    via_command

    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${tput_UL}    duration=${call_time}    ue_type=${ue_type}
  	...   iperf_type=${iperf_type}        #iperf_type=via_command    iperf_type=via_app   huawei
    ...    protocol=udp
    sleep    1s
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${tput_DL}    duration=${call_time}    ue_type=${ue_type}
  	...    protocol=udp    buffer_size=1400B    process_num=${1}    seg_size=1350    window=16M
    sleep    2s

    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${log_time}    filter=L2Lo   ue_index=${ue_index}

    Connect to gnb coam via ssl
    ${list_of_cell_ids}    Get List of NR Cell ID

    ${cell_list}    create list
    Run Keyword If    ${actCarrierAggregation} == ${False}      Run Keywords
    ...        Append To List    ${cell_list}    ${list_of_cell_ids}[${cell_index}]    AND
    ...   set suite variable      ${list_of_cell_ids}       ${cell_list}


    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}   ue_index=${ue_index}
    ...    ultarget_throughput=0.3    dltarget_throughput=0.3    actCarrierAggregation=${actCarrierAggregation}   min_percent=0

    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=${iperf_type}
    #iperf_type=via_command   via_app
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}

    #Unlock nr cell
    #Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=unlocked
    #sleep    60s


UE SetUp
    power_ue.Prepare UE   ue_type=huawei    ue_index=${1}
    power_ue.Prepare UE   ue_type=huawei   ue_index=${0}
    sleep   30s
    power_ue.UE Detach    ue_type=huawei    ue_index=${1}
    power_ue.UE Detach    ue_type=huawei   ue_index=${0}


Manual_SiSo_STARTUP_SCF
    [Arguments]    ${ru_index}=1    ${ue_index}=0    ${power_reset}=False
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END
    Power On RU And Check    ru_index_list=${ru_index_list}

    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        csn.reset_cache
    END
    [Teardown]    Selenium Logout And Close Browser


Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module
    [Arguments]    ${loop_times}=1
    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    FOR  ${i}  IN RANGE  ${loop_times}
        Perform RU Power Off And On    ru_index_list=${ru_index_list}
    END
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online   ru_index=${ru_index}

        check RU config    ru_index_list=${ru_index_list}
    END
#    FOR  ${ru_index}  IN  @{ru_index_list}[0]
#        log to console    "get ru ip and ping"
#        Wait until keyword succeeds  6x  5min  Get RU IP AND Check Pingable    ru_index=${ru_index}
#    END
    COAM Teardown gnb connections

Perform RU Power Off And On
    [Arguments]    ${ru_index_list}    ${ru_index}=${1}    ${gnb_index}=${0}    ${du_index}=${0}
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        sleep   100s
        Wait Until Keyword Succeeds    20min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        sleep  10s
    END

Get RU IP AND Check Pingable
    [Arguments]    ${ru_index}    ${asik_alias}=ASIK Master
    Connect to Common Unit Master  alias=${asik_alias}
    ${ip}=            ssh.execute    command=lxc-attach -n 0x2018 -- cat /ffs/run/config/FRIps.txt | cut -d";" -f3 | sed -n '${ru_index}p'
    ...                              connection=${asik_alias}
    ${ip}=    Split String    ${ip}    \r\n
    ${output}=    ssh.execute    command=lxc-attach -n 0x2018 -- ping -c 30 -W 10 ${ip[0]}    connection=${asik_alias}
    Should contain    ${output}    30 packets transmitted, 30 received
    ssh.disconnect                   connection=${asik_alias}

check RU config
    [Arguments]    ${ru_index_list}
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        Connect to all rus with allocated IP
        ${PC_soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        ${productCode_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep productCode
        ...    | sed -n '1p' | awk -F'productCode>' '{print$4}' | awk -F'<' '{print$1}' | tr -d '\r\n'
        ${output_productCode_cmd_catSOAP}    run    command=${productCode_cmd_cat}
        ${serialNum_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep serialNum |
        ...    sed -n '1p' | awk -F'serialNum>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
        ${output_serialNum_cmd_catSOAP}    run    command=${serialNum_cmd_cat}
        ${bldName_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep bldName |
        ...    sed -n '1p' | awk -F'bldName>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
        ${output_bldName_cmd_catSOAP}    run    command=${bldName_cmd_cat}
        log to console    \n***Check RF config from webui***
        Selenium Login And Disable Screen Lock
        ${radio_type}    get ru type  ru_index=${ru_index}
        ${ruSW_expect}=    get RFSW version from TargetBD    radio_type=${radio_type}
        ${pCode_webui}  ${pName_webui}  ${pName_webui}  ${serNum_webui}  ${hwVer_webui}  ${nrBand_webui}
        ...    ${ruSW_webui}  get RF configuration from webui  ru_index=${ru_index}
        Should Be Equal As Strings    ${output_productCode_cmd_catSOAP}    ${pCode_webui}
        Should Be Equal As Strings    ${output_serialNum_cmd_catSOAP}    ${serNum_webui}
        Should Be Equal As Strings    ${output_bldName_cmd_catSOAP}    ${ruSW_expect}
    END
    [Teardown]    Selenium Logout And Close Browser

Connect to all rus with allocated IP
    [Documentation]  Author: Ren Biyao
    ...    This keyword supports all establishment of rus via allocated IP.
    ...    2020-01-21 Ding Binmei: Return all ru alias
    ...    2020-02-18 Liu Zheng: get the ru list from init to cluster
    ...    2020-09-23 Yan Xin: all rus connection with multi-du scenario
    [Arguments]    ${connection}=GNB_OAM    ${du_index}=${0}    ${du_alias}=du_${du_index}
    connection_alias_store.Connect to Common Unit Master    du_index=${du_index}    alias=${du_alias}
    @{list_ru_alias}    Create list
    #${ru_index_list}    Get RU index list    connection=${connection}
    #FOR    ${ru_index}    IN    @{ru_index_list}[0]
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1
    ...    asik_alias=${du_alias}    connection=${connection}
    Append to list    ${list_ru_alias}    RU_1
    #END
    [Return]  ${list_ru_alias}

get RFSW version from TargetBD
    [Arguments]   ${radio_type}=${ru_type_init}
    ${Radio_Protocol_Type}  Get Radio Protocol
    ${TargetBD_FileName}   ${save_path}    step_keywords.check TargetBD exist and match
    set test variable    ${resBuild_key}    LTX_${radio_type}
    ${cmd_grep}   set variable   cat '${save_path}/${TargetBD_FileName}'|grep 'hwResource resourceBuildKey="${resBuild_key}'
    ${result}=    Run Process    ${cmd_grep}    shell=True   timeout=30s   alias=myproc
    ${output_resBuildKey}=    Get Process Result     myproc
    @{ru_version}    Get Regexp matches    ${output_resBuildKey.stdout}    resourceSWVersion="(.*)"    1
    ${version_length}    get length    ${ru_version}
    ${ruSW_TargetBD}    set variable if    ${version_length}==${1} or '${Radio_Protocol_Type}'=='CPRI'    ${ru_version}[0]
    ...    ${ru_version}[1]
    [Return]    ${ruSW_TargetBD}



Check Btsom Log file on ASIK
    [Documentation]    Author:jie-jessy.li@nokia-sbell.com
    [Arguments]    ${alias}=asik_conn    ${logfolder}=fct-4a_aasyslog  ${filter}=None
    Connect to Common Unit Master     alias=${alias}
    ${status}    Run Keyword And Return Status    csn.assert file exists    remote_path=/tmp/startup_BTSOM.log    connection=${alias}
    ${command}    Set Variable If    '${status}'=='True'    cat /tmp/startup_BTSOM.log |grep -i '${filter}'
    ...                              '${status}'=='False'    xzcat /ffs/run/logs/${logfolder}/startup_BTSOM.log.xz |grep -i '${filter}'
    ${output}    csn.execute    command=${command}    connection=${alias}
    csn.disconnect    connection=${alias}
    [Return]    ${output}

Test Common Teardown
    Connect to gnb coam via ssl
    Active Alarms List Should Be Empty
    COAM Teardown gnb connections

Active Alarms List Should Be Empty
  ${active_alarms_list}  Run Keyword And Continue On Failure  Get Active Alarms
  ${not_allowed_alarms_number}  Run Keyword And Continue On Failure  Remove Allowed Alarms From Active Alarm List
  ...  ${active_alarms_list}  ${ALLOWED_ALARMS}
  Run Keyword And Continue On Failure  Should Be Equal as Integers  ${not_allowed_alarms_number}  0

Get Active Alarms
  Run Keyword And Continue On Failure    Wait For Fault with Alarm to disappear    FaultID=7319
  Run Keyword And Continue On Failure    Wait For Fault with Alarm to disappear    FaultID=7300
  ${active_alarms_list}  Run Keyword And Continue On Failure   coam.get_active_alarms   connection=GNB_OAM
  ...   timeout=600s
  [Return]  ${active_alarms_list}

Remove Allowed Alarms From Active Alarm List
  [Arguments]  ${active_alarms_list}=none  ${allowed_alarms_list}=none
  ${active_alarms_number}  Run Keyword And Continue On Failure  Get Length  ${active_alarms_list}
  ${not_allowed_alarms_list}  Run Keyword And Continue On Failure  Create List
  FOR  ${alarm_id}  IN RANGE  ${active_alarms_number}
      ${checked_alarm_faultId}  Run Keyword And Continue On Failure  Set Variable
      ...    ${active_alarms_list[${alarm_id}]["faultId"]}
      ${not_on_list}  Check If Alarm Allowed   allowed_alarms_list=${allowed_alarms_list}
      ...   checked_alarm=${checked_alarm_faultId}
      ${alarm}  Run Keyword And Continue On Failure   Get From List  ${active_alarms_list}   ${alarm_id}
      Run Keyword If  ${not_on_list}   Append To List  ${not_allowed_alarms_list}   ${alarm}
  END
  ${not_allowed_alarms_number}  Run Keyword And Continue On Failure  Get Length  ${not_allowed_alarms_list}
  [Return]  ${not_allowed_alarms_number}

Check If Alarm Allowed
  [Arguments]  ${allowed_alarms_list}=none  ${checked_alarm}=none
  ${allowed_alarms_number}  Get Length  ${allowed_alarms_list}
  FOR  ${allowed_alarms_id}  IN RANGE  ${allowed_alarms_number}
    ${status}  Run Keyword And Return Status  Should Not Be Equal as Strings  ${checked_alarm}
    ...   ${allowed_alarms_list[${allowed_alarms_id}]}
    Exit For Loop If  ${status}==${FALSE}
  END
  [Return]  ${status}


Wait For Fault with Alarm to disappear
  [Arguments]  ${FaultID}
  wait until keyword succeeds  1200      5    Fault Should Not Be Present   ${FaultID}


Fault Should Not Be Present
  [Arguments]    ${fault_id}
  ${active_alarms}    coam.get_active_alarms    timeout=600s    connection=GNB_OAM
  ${len}    Get Length    ${active_alarms}
  ${alarm_id_list}    Create List
  FOR    ${i}    IN RANGE    ${len}
      ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
      Append To List    ${alarm_id_list}    ${tmp_id}
  END
  ${list}     convert to string  ${alarm_id_list}
  Should Not Contain     ${list}    ${fault_id}


General_SiSo_Online_Cell_addition_deletion
    [Arguments]    ${addition_deletion_cell}=${1}
    ${addition_deletion_cell_list}  create list  ${addition_deletion_cell}
    Online Cell addition deletion   addition_deletion_cell=${addition_deletion_cell}


Online Cell addition deletion
    [Documentation]  Online last Cell addition deletion via webem
    [Arguments]  ${addition_deletion_cell}=1  ${addition_deletion_cellgrp}=0    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}  Get All Cell Group Id
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
    log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${addition_deletion_cellgrp}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    COAM Check GNB cell on air
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}

    selenium_coam.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add object

    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    id_value=${addition_deletion_cellgrp}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${1}
    # recover NRDU-1 as prev
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR  ${i}  IN  @{cell_grp}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${i}
        ...    node_index=${i}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    sleep    60s
    wait until keyword succeeds    3x    5min     verify all cells should be onair
    [Return]  selenium logout and close browser



General_SiSo_RF_module_reset_from_GUI_with_L3call
    [Arguments]      ${connection}=GNB_OAM    ${gnb_index}=0
    ${ru_index_list}     Get All RU Index    connection=${connection}
    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        log to console    \n***RF Module index ${ru_index} Reset from GUI***
        ${ru_index}  Convert To Integer    ${ru_index}
        selenium_coam.reset_ru  ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
        Sleep    300s
        Wait Until Keyword Succeeds    20min    5s    verify all cells should be onair    connection=${connection}
        sleep    60s
        wait until keyword succeeds    3x    5min     Power UE L3 Call
    END

    Check RF Startup and Gnb Status    ${ru_index_list}    gnb_index=${gnb_index}    connection=${connection}
    verify all cells should be onair    connection=${connection}
    [Teardown]    Selenium Logout And Close Browser


Manual_SiSo_SM_RF_Module_lock_unlock

    ${ru_index_list}    get all ru index
    Selenium Login And Disable Screen Lock

    FOR  ${lock_id}  IN  ${ru_index_list}[0]
        Sleep    3s
        ${operate_list}    create list    ${lock_id}
        Lock all RUs SISO    ru_index_list=${operate_list}
        Sleep    3s
        Unlock all RUs SISO    ru_index_list=${operate_list}
    END
    [Teardown]    Selenium Logout And Close Browser


Manual_SiSo_SM_BTS_Site_Reset

    FOR	${i}	IN RANGE	3
        Selenium Logout And Close Browser
        Perform BTS Site Reset
        sleep    60s
        Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
        csn.reset_cache

    END
    [Teardown]    Selenium Logout And Close Browser

General_SiSo_Cell_lock_and_unlock

    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}    ${4G_check}=${False}
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Lock and Unlock Cells or Groups and L3  lock_list=${cell_id_list}  is_group=${False}  with_call=${with_call}  with_peak=${with_peak}
    ...    4G_check=${4G_check}
    Connect to gnb coam via ssl
    ${cellgrp_id_list}  Get All Cell Group Id
    ${cellgrp_num}    get length  ${cellgrp_id_list}
    # AQQQA暂时不支持
    #Lock and Unlock Cells or Groups and L3  lock_list=${cellgrp_id_list}  is_group=${True}  with_call=${with_call}  with_peak=${with_peak}
    #...    4G_check=${4G_check}
    run keyword if  ${cell_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cell_id_list}  is_group=${False}
    run keyword if  ${cellgrp_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cellgrp_id_list}  is_group=${True}


Lock and Unlock Cells or Groups and L3
    [Arguments]  ${lock_list}  ${is_group}=${True}  ${with_call}=${False}  ${with_peak}=${False}    ${4G_check}=${False}
    ${lock_num}    get length  ${lock_list}
    #FOR  ${lock_id}  IN  @{lock_list}
    ${lock_id}    set variable    1

    ${check_alarm}  set variable if  ${lock_num}==1  ${True}  ${False}
    ${other_cells}  Get Other Ids    id_list=${lock_list}    given_id=${lock_id}
    ${check_cell}  create list  ${lock_id}
    ${operate_list}    set variable if  ${lock_num}==1  ${check_cell}  ${other_cells}
    ${cell_list}    run keyword if  ${is_group}    Get Cell From Cell Group  cellgrp_id=${lock_id}
    ...    ELSE   set variable  ${check_cell}
    Lock cells or groups and check status  lock_list=${operate_list}  is_group=${is_group}  check_alarm=${check_alarm}
    ...    gnb_type='${gNb_CuType}'

    run keyword if  ${operate_list}[0]==2 and ${with_call}
    ...    Power UE L3 Call   cell_id=0
    run keyword if  ${operate_list}[0]==1 and ${with_call}
    ...    Power UE L3 Call   cell_id=1

    Unlock cells or groups and check status  lock_list=${operate_list}  is_group=${is_group}  check_alarm=${check_alarm}
    ...    gnb_type='${gNb_CuType}'



General_SiSo_Cell_block_and_unblock
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Block and UnBlock Cells    block_list=${cell_id_list}   with_call=${with_call}  with_peak=${with_peak}

    run keyword if  ${cell_num}>1  Block and UnBlock Cells  block_list=${cell_id_list}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${cell_id_list}
    ...    check_alarm=${True}  gnb_type='${gNb_CuType}'    AND   Selenium Logout And Close Browser

Block and UnBlock Cells
    [Arguments]  ${block_list}   ${with_call}=${True}  ${with_peak}=${False}
    ${block_num}    get length  ${block_list}
    FOR  ${block_id}  IN  @{block_list}
        ${check_alarm}  set variable if  ${block_num}==1  ${True}  ${False}
        ${other_cells}  Get Other Ids    id_list=${block_list}    given_id=${block_id}
        ${check_cell}  create list  ${block_id}
        ${operate_list}    set variable if  ${block_num}==1  ${check_cell}  ${other_cells}

        Block cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        sleep  10s

        UnBlock Cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'

    END



Generate Modify Parameters
    [Arguments]  ${modify_params}
    FOR  ${item}  IN  @{modify_params}
        ${dist_name}    get from dictionary  ${item}  dist_name
        ${mrbtsID}=    convert to string     ${mrbtsID}
        ${dist_name}    Replace String    ${dist_name}     {mrbtsID}    ${mrbtsID}
        #${dist_name}    Replace String    ${dist_name}     {nrbtsID}    ${nrbtsID}
        set to dictionary    ${item}    dist_name=${dist_name}
    END
    [Return]  ${modify_params}



Wait until cell is on air status
    [Arguments]  ${timeout}=15 min    ${connection}=GNB_OAM
    log    ${timeout}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB cell on air    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    Verify all cells should be onair

OAM_KPI_61a_SiSo_Auto_BTS_site_reset

    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
        Set Global Variable    ${TEST_LOOP}
        ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        Perform BTS Site Reset
        Sleep    30s
        COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'

        Power UE L3 Call

    END

Lock nr cell
    [Arguments]  ${cell_idx}=${2}
    Log To Console    Perform cell-${cell_idx} lock
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Perform cell lock via rest api    cell_idx=${cell_idx}
    sleep    5s
    [Teardown]  Run Keyword And Ignore Error  COAM Teardown gnb connections

Unlock nr cell
    [Arguments]  ${cell_idx}=${2}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Log To Console    Perform cell-${cell_idx} unlock
    Perform cell unlock via rest api    cell_idx=${cell_idx}
    sleep    5s
    [Teardown]  Run Keyword And Ignore Error  COAM Teardown gnb connections




Clear old log path
    csn.connect to
    ...               hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=test

    csn.send_command    command=sudo rm -rf /home/ute/BIPlog/l1l2bip/*    connection=test
    Sleep    10s
    csn.disconnect    connection=test



Common 8680_J Setup
    Verify Site On Air
    Connect to gnb coam via ssl
    Active Alarms List Should Be Empty
    COAM Teardown gnb connections
    Download MCShark To UTE

    sleep  30s


Verify Site On Air
    Connect to gnb coam via ssl
    Verify all cells should be onair
    COAM Teardown gnb connections




Lock and Unlock Cell
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    log to console  \n***Lock cell1 and check status***
    perform_cell_lock_via_admin    cell_id=1    connection=${connection}    lock_timeout=120
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=1  connection=${connection}

    log to console  \n***unLock cell1 and check status***
    perform_cell_unlock_via_admin    cell_id=1    connection=${connection}    lock_timeout=120
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=1    connection=${connection}
    COAM Teardown gnb connections
