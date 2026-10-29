*** Settings ***
Documentation
...    Common KWs about fiber swith; Do not modify without notification.
...    Author:shasha.liu
...    contact:shasha.liu@nokia-sbell.com
...    squad group:SG_05

Library     String
Library     BuiltIn
Library     Collections
Library     OperatingSystem
Library     taf.hw.optical_switch    WITH NAME    fiberswitch
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

Resource    ./Vendors/Leoni.robot
Resource    ./Vendors/Mitron.robot
Resource    ./Vendors/Calient.robot

#Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
#Resource    taf/rfrl/common_resources/robot/gnb_classical.robot

*** Variables ***
${switch_index}   0
${switch_type}    ${tl.optical_switches[${switch_index}].__class__.__name__}

*** Keywords ***
optical_switch.General_SiSo_CPRI_link_failure_triggered_RF_module_reset
    [Arguments]    ${ru_index}=1
    run keyword and continue on failure    Create file in RU    ru_index=${ru_index}
    ${chanl_numbers}    Get Fiberswitch Channel Number For RU    ru_id=${${ru_index}-1}
    Check Current SFP links Status    exp_cablnkStat=connected    alias=GNB_OAM
    Run Keyword    ${switch_type}.Connect To Fiber Switch
    log to console    \nget all channel connections orignal
    ${all_chanl_conns}    Run Keyword   ${switch_type}.Get Fiber Switch Channels
    Run Keyword    ${switch_type}.Turn Off Fiber Switch Channels    ru_index=${ru_index}   NumofChanls=${chanl_numbers}
    log to console    \nget all channel connections after specific ones trun off
    ${all_chanl_conns_off}    Run Keyword    ${switch_type}.Get Fiber Switch Channels
    log to console    \ncheck cell Status after fiber switch trun off

    ${cell_id_list_under_RU}    Get All Cell Id    ru_index=${ru_index}
    FOR  ${cellID}  IN  @{cell_id_list_under_RU}
        ${cellgrp_id}    Get Cell Group From Cell    cell_id=${cellID}
        run keyword and continue on failure   Wait Until Keyword Succeeds   5 min   10 sec   Cell Should Be Disabled
        ...    cell_idx=${cellID}   cell_group_idx=${cellgrp_id}
    END

    run keyword and continue on failure    ${switch_type}.Turn On Fiber Switch Channels    ru_index=${ru_index}
    ...    NumofChanls=${chanl_numbers}
    log to console    \nget all channel connections after specific ones trun on
    ${all_chanl_conns_on}    Run Keyword    ${switch_type}.Get Fiber Switch Channels
    log to console    \nCheck Current SFP links Status after fiber switch trun on
    Wait until keyword succeeds    10 min    20 sec    Check Current SFP links Status    exp_cablnkStat=connected
    ...                                                                                  alias=GNB_OAM
    log to console    \ncheck RU Status after fiber switch trun on
    run keyword and continue on failure   Wait until keyword succeeds    10 min    20 sec    RU Should Be Online
    ...    ru_index=${ru_index}
    log to console    \ncheck cell Status after fiber switch trun on

    ${cell_id_list_under_RU}    Get All Cell Id    ru_index=${ru_index}
    FOR  ${cellID}  IN  @{cell_id_list_under_RU}
        ${cellgrp_id}    Get Cell Group From Cell    cell_id=${cellID}
        run keyword and continue on failure   Wait Until Keyword Succeeds   10 min   20 sec   Cell Should Be Enabled
        ...    cell_idx=${cellID}   cell_group_idx=${cellgrp_id}
    END

    ${file_Exist}   Run Keyword And Return Status    Check file Exist in RU    ru_index=${ru_index}
    Should Be True    '${file_Exist}'=='False'
    [Teardown]  Run Keywords    Selenium Logout And Close Browser   AND   ${switch_type}.Disconnect To Fiber Switch

optical_switch.General_SiSo_SFP_lock_unlock_for_configuration_testing
    [Arguments]    ${bbmode_id}=1    ${is_optical_switch}=${False}    ${is_sitereset_recovery}=${False}    ${connection}=sfp
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to verify fibers behavious by SFP lock/unlock and/or fiber switch OFF/ON
    ...    instead of hot remove/insert fibers.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Check all SFP links are normal.
    ...        2. Online Remove All Object SFP.
    ...        3. Online Add All Object SFP and LANE.
    ...        4. Lock LANE From SFP By Random, check SFP status and expected fault list.
    ...        5. Unlock LANE From SFP By Random, check SFP status and expected fault list.
    ...        6. Check all cells info should be onair.
    ...        7. Retest with fiber switch instead of SFP lock/unlock.
    ...    - [EXPECTED RESULTS] The fibers behavious meets requirements by SFP lock/unlock and/or fiber switch OFF/ON.
    ...    cells should be on air without unexpected alarms.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | is_optical_switch | No | using fiber switch or not.|
    ...    | is_sitereset_recovery | No | recovery by siterest or not |
    ...    | connection | No | the alias of connection to gnb|

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 13.06.2024 - - Created
    ...    *******************
    ...    * Owner: aaron.deng@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T05
    ...    *******************
    coam_gnb_classical.Connect to gnb coam via ssl    connection=${connection}
    ${cables_info_list}    optical_switch.Get Cablink Info    connection=${connection}
    ${is_Connected}    Run Keyword And Return Status    Check Current SFP links Status    alias=${connection}
    Run Keyword If   '${is_Connected}'=='False'    Fail    Some SFP links are not connected, please check before testing.
    log to console    \nCheck all SFP links are connected.
    &{Board_pName}    optical_switch.Get Board Product Name
    Set Test Variable    ${smod_pName}    ${Board_pName['smod_pName']}
    Set Test Variable    ${bbmod_pName}    ${Board_pName['bbmod_pName']}
    ${is_ASOx}    Run Keyword And Return Status    should contain    ${smod_pName}    ASO
    log to console    \nSMOD: ${smod_pName}, BBMOD: ${bbmod_pName}
    Return From Keyword If   '${is_ASOx}' == '${True}'    WRN: Skip checking with ASOx serial, TBD.

    bts_selenium.Selenium Login And Disable Screen Lock
    log to console    \nRemove all SFP objects for specific BBMOD - Started
    run keyword and continue on failure    Online Remove All Object SFP For Specific BBMOD    bbmode_id=${bbmode_id}
    log to console    \nRemove all SFP objects for specific BBMOD - Completed
    Sleep    5s
    log to console    \nAdd all SFP and LANE objects for specific BBMOD - Started
    run keyword and continue on failure    Online Add All Object SFP and LANE For Specific BBMOD    bbmode_id=${bbmode_id}
    ...    connection=${connection}
    Sleep    10s

    #WA for adding objects SFP and LANE stale issue
    ${SFPs_list}    selenium_coam.get_object_name_list   object_name=SFP-
    ${len_SFPs}    Get Length    ${SFPs_list}
    Run Keyword If    ${len_SFPs}!=0    log to console    \nCurrent SFP objects in the BTS: ${SFPs_list}
    Return From Keyword If    ${len_SFPs}==0    \nError: There is no SFP object in the BTS.
    ${bbmod_enable_ports}    Create List
    FOR   ${SFP}    IN    @{SFPs_list}
        ${SFP_new}    Replace String    ${SFP}    SFP-    BBMOD-${bbmode_id}/RF
        Append To List    ${bbmod_enable_ports}    ${SFP_new}
    END
    log to console    \nbbmod_enable_ports list:${bbmod_enable_ports}
    log to console    \nAdd all SFP and LANE objects for specific BBMOD - Completed

    log to console    \nLock LANE From SFP By Random - Started
#    &{lock_info}    Lock LANE From SFP By Random    bb_hw_name=${bbmod_pName}    LANE_Id=1    connection=${connection}
    &{lock_info}    Lock LANE From SFP By Random    bbmod_enable_ports=${bbmod_enable_ports}    LANE_Id=1    connection=${connection}
    ${physPort}    Set Variable    ${lock_info}[HW_port_Id_Random]
    ${port_name}    Get Regexp Matches    ${physPort}    \[A-Z\]+
    ${port_number}    Get Regexp Matches    ${physPort}    \\d+
    Wait until Keyword Succeeds    2min  30s    optical_switch.Check SFP Status Disabled Or Enabled     bbmode_id=${bbmode_id}
    ...    expectStatus=disabled    object_name=${physPort}    connection=${connection}

#    ${fault_lockLANE}    Create List
#    Run Keyword If    &{lock_info}[synchronization] and &{lock_info}[configuration] and &{lock_info}[data]    Run Keywords
#    ...    Append To List    ${fault_lockLANE}    ${10}    AND
#    ...    Append To List    ${fault_lockLANE}    ${1815}
#    ...    ELSE IF    &{lock_info}[synchronization] and not &{lock_info}[configuration] and &{lock_info}[data]   Run Keywords
#    ...    Append To List    ${fault_lockLANE}    ${16}    AND
#    ...    Append To List    ${fault_lockLANE}    ${1815}
#    ...    ELSE IF    not &{lock_info}[synchronization] and &{lock_info}[configuration] and &{lock_info}[data]
#    ...    Append To List    ${fault_lockLANE}    ${10}     #${1815} would not reported which differs from EXCEL/Requirements
#    ...    ELSE IF    not &{lock_info}[synchronization] and not &{lock_info}[configuration] and &{lock_info}[data]
#    ...    Append To List    ${fault_lockLANE}    ${1815}   #${1868} here reports or not depends on the resource allocation
#    ...    ELSE    Log to console    \nWRN: Invalid linkMode of cableLink.
#    log to console    \nGenerate fault list for locking LANE from SFP according to linkMode: ${fault_lockLANE}

    #fault 1815 was hidden by CNI-127210, for details refer to https://confluence.ext.net.nokia.com/display/M5FC/CNI-127210+Key+documents
    ${fault_lockLANE}    Create List
    Run Keyword If    ${lock_info}[synchronization] and ${lock_info}[configuration] and ${lock_info}[data]
    ...    Append To List    ${fault_lockLANE}    ${10}
    ...    ELSE IF    ${lock_info}[synchronization] and not ${lock_info}[configuration] and ${lock_info}[data]
    ...    Append To List    ${fault_lockLANE}    ${16}
    ...    ELSE IF    not ${lock_info}[synchronization] and ${lock_info}[configuration] and ${lock_info}[data]
    ...    Append To List    ${fault_lockLANE}    ${10}
    ...    ELSE    Log to console    \nWRN: Invalid linkMode of cableLink.
    log to console    \nGenerate fault list for locking LANE from SFP according to linkMode: ${fault_lockLANE}

    FOR    ${fault}    IN    @{fault_lockLANE}
        wait until keyword succeeds    10min    30s    optical_switch.Expect Fault Should Present In Active or History Alarms
        ...    faultId=${fault}
        ...    source=${None}
        ...    connection=${connection}
        ...    du_index=${0}
        ...    is_need_to_setup_gnb_connection=${True}
        ...    timeout=${300}
        ...    severity=${None}
        optical_switch.Add Fault To The Allowed History Fault List    faultId=${fault}
    END
    log to console    \nExpect fault list present in active or history alarms after LANE locked: ${fault_lockLANE}

    Run Keyword If    ${is_sitereset_recovery}==${True}    Run Keywords
    ...    selenium_coam.reset_site    AND
    ...    Sleep  8min    AND
    ...    Wait until Keyword Succeeds    2min  30s   bts_selenium.Selenium Login And Disable Screen Lock

    log to console    \nUnlock LANE From SFP By Random - Started
#    Unlock LANE From SFP    bb_hw_name=${bbmod_pName}    object_name=${physPort}    LANE_Id=1
    Unlock LANE From SFP    bb_hw_name=BBMOD-${bbmode_id}   object_name=${physPort}    LANE_Id=1
    Wait until Keyword Succeeds    5min  30s    optical_switch.Check SFP Status Disabled Or Enabled     bbmode_id=${bbmode_id}
    ...    expectStatus=enabled    object_name=${physPort}    connection=${connection}
    log to console    \nUnlock LANE From SFP By Random: ${physPort}_LANE-1 - Completed
    Wait until Keyword Succeeds    10min  30s    Check all cells info should be onair    connection=${connection}

    FOR    ${fault}    IN    @{fault_lockLANE}
        wait until keyword succeeds    5min    30s    coam_siso_common.Expect Fault Should Absent
        ...    faultId=${fault}
        ...    source=${None}
        ...    connection=${connection}
        ...    du_index=${0}
        ...    is_need_to_setup_gnb_connection=${True}
        ...    timeout=${300}
    END
    log to console    \nExpect fault list absent in active alarms after LANE unlocked: ${fault_lockLANE}

    Return From Keyword If   '${is_optical_switch}' == '${False}'    WRN: Skip checking with fiber switch.

    [Teardown]    Run Keywords    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}
    ...    AND    bts_selenium.Selenium Logout And Close Browser

Add Fault To The Allowed History Fault List
    [Arguments]    ${faultId}
    ${ALLOWED_HISTORY_FAULT_TEMP}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${fault_dic}    Create Dictionary    faultId=${faultId}
    Append To List     ${ALLOWED_HISTORY_FAULT_TEMP}    ${fault_dic}
    Set suite Variable    ${ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT_TEMP}

Expect Fault Should Present In Active or History Alarms
    [Documentation]    Auther: xuewen.zhang@nokia-sbell.com
    ...               Description: check expect alarm exist,add severity checkpoint by journey.jin@nokia-sbell.com
    ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
    ...               add checkpoint alarm id and fault id should be mapped by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['configObjectName']} due to some object don't have runtime object by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['supplAlarmInfo']} for checking supplAlarmInfo by catherine.cheng@nokia-sbell.com
    ...               add ${supplementary_not_contain} for checking supplAlarmInfo by catherine.cheng@nokia-sbell.com
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}     ${supplementary}=${None}    ${supplementary_not_contain}=${None}
    ...            ${du_index}=0    ${is_need_to_setup_gnb_connection}=${True}    ${timeout}=10

    ${present_status}    Run Keyword And Return Status    Expect Fault Should Present
    ...      faultId=${faultId}
    ...      alarmId=${alarmId}
    ...      source=${source}
    ...      connection=${connection}
    ...      du_index=${du_index}
    ...      is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}
    ...      timeout=${timeout}
    ...      severity=${severity}
    ...      configObjectName=${configObjectName}
    ...      supplementary=${supplementary}
    ...      supplementary_not_contain=${supplementary_not_contain}
    return from keyword if    ${present_status}      log to console  Expect Fault:${faultId} Present In Active Alarms

    ${present_status}    Run Keyword And Return Status    Expect Fault Should Present In History Alarms
    ...      faultId=${faultId}
    ...      source=${source}
    ...      connection=${connection}
    ...      du_index=${du_index}
    ...      is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}
    ...      timeout=${timeout}
    ...      severity=${severity}
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Expect Fault Should Present In History Alarms
    [Documentation]    Auther: xuewen.zhang@nokia-sbell.com
    ...               Description: check expect alarm exist,add severity checkpoint by journey.jin@nokia-sbell.com
    ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
    ...               add checkpoint alarm id and fault id should be mapped by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['configObjectName']} due to some object don't have runtime object by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['supplAlarmInfo']} for checking supplAlarmInfo by catherine.cheng@nokia-sbell.com
    ...               add ${supplementary_not_contain} for checking supplAlarmInfo by catherine.cheng@nokia-sbell.com
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}     ${supplementary}=${None}    ${supplementary_not_contain}=${None}
    ...            ${du_index}=0    ${is_need_to_setup_gnb_connection}=${True}    ${timeout}=100
    ${faultId}    Convert To Integer    ${faultId}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${connection}    Set variable if  '${du_index}'=='0'    ${connection}    ${connection}_du${du_index}
    Run keyword if    ${has_cbts} and ${is_need_to_setup_gnb_connection}
    ...    Cloud DU connect to gnb coam via ssl
    ...        connection=${connection}    du_index=${du_index}
    ...    ELSE IF    '${has_cbts}'=='${False}' and ${is_need_to_setup_gnb_connection}
    ...      Connect to gnb coam via ssl    connection=${connection}
    @{alarms}    coam.get_historic_alarms    connection=${connection}    timeout=${timeout}    load_history=${True}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}    AND
                  ...                      Run Keyword If    '${Supplementary}'!='${None}'
                  ...                      Should Contain   ${alarm['supplAlarmInfo']}    ${Supplementary}    AND
                  ...                      Run Keyword If    '${supplementary_not_contain}'!='${None}'
                  ...                      Should not Contain   ${alarm['supplAlarmInfo']}    ${supplementary_not_contain}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Lock LANE From SFP By Random
#    [Arguments]    ${bb_hw_name}=ABIO    ${LANE_Id}=1    ${connection}=GNB_OAM
    # [Arguments]    ${bb_hw_name}=BBMOD-1    ${LANE_Id}=1    ${connection}=GNB_OAM
    # ${cables_info_list}    optical_switch.Get Cablink Info    connection=${connection}
    # ${bbmod_enable_ports}    Create List
    # # FOR    ${item}    IN    @{cables_info_list}
    # #     Append To List    ${bbmod_enable_ports}    ${item['bbmod_enable_port']}
    # # END
    # # Sort List    ${bbmod_enable_ports}

    # FOR    ${item}    IN    @{cables_info_list}
    #     @{enable_port}    string.split string    ${item['bbmod_enable_port']}    separator=/
    #     Run Keyword If    '${enable_port}[0]' != '${bb_hw_name}'    Continue For Loop
    #     Append To List    ${bbmod_enable_ports}    ${item['bbmod_enable_port']}
    # END
    # Sort List    ${bbmod_enable_ports}

    [Arguments]    ${bbmod_enable_ports}    ${LANE_Id}=1    ${connection}=GNB_OAM
    ${cables_info_list}    optical_switch.Get Cablink Info    connection=${connection}
    ${bbmod_enable_port_random}    Evaluate    random.choice(${bbmod_enable_ports})    modules=random
    @{split_port}     string.split string    ${bbmod_enable_port_random}    separator=/
    Set Test Variable    ${HW_port_Id_Random}    ${split_port}[-1]
    Set Test Variable    ${bb_hw_name}           ${split_port}[0]
    FOR    ${item}    IN    @{cables_info_list}
        Run Keyword If    '${item['bbmod_enable_port']}'=='${bbmod_enable_port_random}'    Run Keywords
        ...    Set Test Variable    ${is_sync}    ${item['synchronization']}    AND
        ...    Set Test Variable    ${is_config}    ${item['configuration']}    AND
        ...    Set Test Variable    ${is_data}    ${item['data']}
    END
#    FOR    ${item}    IN    @{cables_info_list}
#        ${is_sync}    Set Variable    ${item['synchronization']}
#        ${is_config}    Set Variable    ${item['configuration']}
#        ${is_data}    Set Variable    ${item['data']}
#        Exit For Loop If    '${item['bbmod_enable_port']}'=='${bbmod_enable_port_random}'
#    END
    &{lock_info}    create dictionary
    ...             bbmod_enable_port_random=${bbmod_enable_port_random}
    ...             HW_port_Id_Random=${HW_port_Id_Random}
    ...             synchronization=${is_sync}
    ...             configuration=${is_config}
    ...             data=${is_data}
    log to console    \nGet the linkMode of random cableLink - ${bbmod_enable_port_random}:
    log to console    synchronization=${is_sync}, configuration=${is_config}, data=${is_data}

    selenium_coam.lock_lane_from_sfp    hw_name=${bb_hw_name}    object_name=${HW_port_Id_Random}    lane_id=LANE-${LANE_Id}
    log to console    \nLock LANE-${LANE_Id} from SFP by random cableLink ${bbmod_enable_port_random} completed.
    [Return]    &{lock_info}

Unlock LANE From SFP
    [Arguments]    ${bb_hw_name}=ABIO    ${object_name}=RF1    ${LANE_Id}=1
    selenium_coam.unlock_lane_from_sfp    hw_name=${bb_hw_name}    object_name=${object_name}    lane_id=LANE-${LANE_Id}

Online Remove All Object SFP For Specific BBMOD
    [Arguments]    ${bbmode_id}=1
    ${SFPs_list}    selenium_coam.get_object_name_list   object_name=SFP-
    ${len_SFPs}    Get Length    ${SFPs_list}
    Return From Keyword If    ${len_SFPs}==0    There is no SFP object in the BTS.
    FOR    ${SFP}    IN    @{SFPs_list}
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmode_id}/${SFP}    timeout=60
        Sleep   3s
    END
    ${pdlValidate}    optical_switch.Validate Plan and Check Errors
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}

Online Add All Object SFP and LANE For Specific BBMOD
    [Arguments]    ${bbmode_id}=1    ${LANE_Id}=1    ${connection}=GNB_OAM
    ${cables_info_list}    optical_switch.Get Cablink Info    connection=${connection}
    ${HW_port_Ids}    Create List
    FOR    ${item}    IN    @{cables_info_list}
        @{enable_port}    string.split string    ${item['bbmod_enable_port']}    separator=/
        Run Keyword If    '${enable_port}[0]' != 'BBMOD-${bbmode_id}'    Continue For Loop
        Append To List    ${HW_port_Ids}    ${enable_port}[-1]
    END
    Sort List    ${HW_port_Ids}
    Set Test Variable    ${SFP_Id}    ${1}
    ${rel}     gnb_classical_hangzhou.Get sw build version
    Set Test Variable    ${rel}
    FOR    ${HW_port_Id}    IN    @{HW_port_Ids}
        Run Keyword If    '${rel}'=='SBTS24R1' or '${rel}'=='SBTS24R2' or '${rel}'=='SBTS24R3' or '${rel}'=='SBTS25R1'
        ...    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmode_id}
        ...    object_class_name=SFP    id_value=${SFP_Id}    is_load_default_values=${True}    timeout=60
        ...    ELSE    selenium_coam.add_new_object    object_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmode_id}
        ...    class_name=SFP    object_id=${SFP_Id}    timeout=60
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmode_id}/SFP-${SFP_Id}
        ...   filter_param=HW port identifier   abbr=hwPortId   new_value=${HW_port_Id}
        Run Keyword If    '${rel}'=='SBTS24R1' or '${rel}'=='SBTS24R2' or '${rel}'=='SBTS24R3' or '${rel}'=='SBTS25R1'
        ...    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmode_id}/SFP-${SFP_Id}
        ...    object_class_name=LANE   is_load_default_values=${True}     id_value=${LANE_Id}   timeout=60
        ...    ELSE    selenium_coam.add_new_object    object_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmode_id}/SFP-${SFP_Id}
        ...    class_name=LANE    object_id=${LANE_Id}    timeout=60
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmode_id}/SFP-${SFP_Id}/LANE-${LANE_Id}
        ...   filter_param=Administrative state   abbr=administrativeState   new_value=Unlocked
        ${SFP_Id}    BuiltIn.Evaluate    ${SFP_Id}+1
        ${pdlValidate}    optical_switch.Validate Plan and Check Errors
        selenium_coam.activate_plan    activate_plan_despite_errors=${False}
        Sleep    10s
#        selenium_coam.refresh_page
#        Sleep    20s
    END
#    ${pdlValidate}    optical_switch.Validate Plan and Check Errors
#    selenium_coam.activate_plan    activate_plan_despite_errors=${False}

Validate Plan and Check Errors
    [Documentation]   Validate Plan and Report Error
    selenium_coam.validate_plan
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
#    ${hardware_errors}      selenium_coam.get_hardware_errors
#    ${errors}    combine lists    ${defination_errors}   ${relation_errors}    ${hardware_errors}
    ${errors}    combine lists    ${defination_errors}   ${relation_errors}
    ${errNum}    Get Length   ${errors}
    Run Keyword If    ${errNum} != 0    Run Keywords
    ...    Log to console    The current BTS exist ${errNum} errors.    AND
    ...    Log to console    defination_errors: ${defination_errors}    AND
    ...    Log to console    relation_errors: ${relation_errors}
#    ...    Log to console    relation_errors: ${relation_errors}        AND
#    ...    Log to console    hardware_errors: ${hardware_errors}
#    [Return]    ${errNum}   ${defination_errors}   ${relation_errors}   ${hardware_errors}
    [Return]    ${errNum}   ${defination_errors}   ${relation_errors}

Get Fiberswitch Channel Number For RU
    [Arguments]    ${ru_id}=0    ${gnb_id}=0    ${du_id}=0
    ${fiberswitch_chanls}   set variable   ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${${ru_id}}].optical_switch_channels}
    ${chanl_numbers}    Get Length    ${fiberswitch_chanls}
    [Return]    ${chanl_numbers}

Check Current SFP links Status
    [Arguments]    ${exp_cablnkStat}=connected    ${alias}=GNB_OAM
    ${sfpLinks}    coam.get_sfp_links    action=getLinks    connection=${alias}
    ${numLinks}    Get Length    ${sfpLinks}
    FOR   ${sfplnk_index}    IN RANGE    ${numLinks}
        ${linkDistName}    Set Variable    ${sfpLinks[${sfplnk_index}]['linkDistName']}
        ${spec_sfplnk}    coam.get_sfp_links     action=getParametersForLink
        ...                                            dist_name=${linkDistName}
        ...                                            connection=${alias}
        ${sfplnk_stat}   Set Variable   ${spec_sfplnk['type']}
        Should Be Equal As Strings    first=${sfplnk_stat}    second=${exp_cablnkStat}    ignore_case=True
    END

Get Cablink Info
    [Arguments]    ${connection}=GNB_OAM
    &{hw_info}       coam.get_detected_hw_info    connection=${connection}
    ${cables_info}    set variable    ${hw_info.cables}
    ${cables_info_list}    create list
    FOR    ${cables}    IN    @{cables_info}
        #Run Keyword If    '${cables['status']['operationalState']}'=='disabled'    Continue For Loop
        @{bbmod_cablink}  string.split string    ${cables['firstEndPointId']['configuration']}    separator=/
        @{bbmode_objName}  string.Split String From Right  ${cables['firstEndPointId']['configuration']}  separator=/  max_split=2
        @{ru_cablink}  string.split string    ${cables['secondEndPointId']['configuration']}    separator=/
        @{confobjectname}  string.split string    ${cables['id']['configuration']}    separator=/
        ${item}  create dictionary  bbmod_enable_port=${bbmod_cablink}[-2]/${bbmod_cablink}[-1]
        ...     ru_enable_port=${ru_cablink}[-2]/${ru_cablink}[-1]
        ...     objectname=${confobjectname}[-1]
        ...     linkSpeed=${cables['linkSpeed']}
        ...     status=${cables['status']['operationalState']}
        ...     synchronization=${cables['linkMode']['synchronization']}
        ...     configuration=${cables['linkMode']['configuration']}
        ...     data=${cables['linkMode']['data']}
        ...     bbmode_objName=${bbmode_objName}[1]
        append to list    ${cables_info_list}    ${item}
    END
    [Return]   ${cables_info_list}

Get Board Product Name
    [Documentation]    Author: Yue Liu     5G_PZ4_HZ_5_SG
    ...    Get info from testline and check if ASOD or ASOE or ASOF or ASOG or ASOH testline.
    ...    return ${True} or ${False}
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master    ${capacity_alias}=ABIL Master
    Run Keyword And Ignore Error   csn.disconnect    connection=${alias}
    Wait until keyword succeeds    1min    20s   Connect to Common Unit Master    gnb_index=${gnb_index}
    ...    du_index=${du_index}    alias=${alias}
    ${cmd_smod}    Set Variable    ddal -s ddal_sysinfo_module_get_unit_id 0 | grep 'value' | cut -d'=' -f2 | awk -F \\' '{print $2}'
    ${smod_pName}    csn.execute    command=${cmd_smod}    connection=${alias}
    ${smod_pName}    String.Strip String    ${smod_pName}
#   bsh is not applicable: PR837463 PR837529
   ${cmd_bbmod}    Set Variable    bsh 1:0 "ddal -s ddal_sysinfo_module_get_unit_id 0 | grep -E \\"^value=\\" | cut -d'=' -f2 | tr -d \\"'\\""
   ${bbmod_pName}    csn.execute    command=${cmd_bbmod}    connection=${alias}

#    #fsp1_a: ABIP-1; fsp-1a: ABIO-1
#    ${hostnames_list}    Create List    fsp1_a    fsp-1a
#    FOR  ${bbu}  IN  @{hostnames_list}
#        ${status}    Run Keyword And Return Status    ssh.Connect to    hostname=${bbu}
#        ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
#        ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
#        ...               proxy=${alias}    alias=${capacity_alias}
#        Exit For Loop If    ${status}
#    END
#    ${cmd_bbmod}    Set Variable    ddal -s ddal_sysinfo_module_get_unit_id 0 | grep 'value' | cut -d'=' -f2 | awk -F \\' '{print $2}'
#    ${bbmod_pName}    csn.execute    command=${cmd_bbmod}    connection=${capacity_alias}
    ${bbmod_pName}    String.Strip String    ${bbmod_pName}
    &{Board_pName}    Create Dictionary    smod_pName=${smod_pName}    bbmod_pName=${bbmod_pName}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=${capacity_alias}
    ...    AND    Run Keyword And Ignore Error    csn.disconnect    connection=${alias}
    [Return]    &{Board_pName}

Check SFP Status Disabled Or Enabled
    [Documentation]
    ...        check the SFP's status should be disabled or enabled
    [Arguments]    ${bbmode_id}=1    ${expectStatus}=enabled    ${object_name}=RF1    ${connection}=GNB_OAM
    ${cables_info_list}    optical_switch.Get Cablink Info    connection=${connection}
    FOR    ${cable_info}    IN    @{cables_info_list}
        Run Keyword If    "${cable_info['bbmod_enable_port']}" != "BBMOD-${bbmode_id}/${object_name}"    Continue For Loop
        ${status}    Set Variable    ${cable_info['status']}
        Should Be Equal As Strings    first=${status}    second=${expectStatus}    ignore_case=True
    END

Lock LANE From SFP For Specific RMOD with Primary Link
    [Arguments]    ${ru_index}=1    ${bb_hw_name}=ABIO    ${LANE_Id}=1    ${connection}=GNB_OAM
    ${cables_info_list}    optical_switch.Get Cablink Info    connection=${connection}
    FOR    ${item}    IN    @{cables_info_list}
        ${status}    Run Keyword And Return Status    Should Contain    ${item['ru_enable_port']}    RMOD-${ru_index}/
        ${bbmod_enable_port}    Set Variable If    ${status} and '${item['synchronization']}'=='True'
        ...    ${item['bbmod_enable_port']}    None
        ${if_sync_data}    Set Variable If
        ...    ${status} and '${item['synchronization']}'=='True' and '${item['data']}'=='True'
        ...    ${True}    ${False}
        ${if_sync_config_data}    Set Variable If
        ...    ${status} and '${item['synchronization']}'=='True' and '${item['configuration']}'=='True' and '${item['data']}'=='True'
        ...    ${True}    ${False}
        Set Test Variable    ${if_sync_data}
        Set Test Variable    ${if_sync_config_data}
        Set Test Variable    ${syncStatus}    ${item['synchronization']}
        Set Test Variable    ${configStatus}    ${item['configuration']}
        Set Test Variable    ${dataStatus}    ${item['data']}
        Exit For Loop If    ${status} and '${item['synchronization']}'=='True'
    END
    @{split_port}     string.split string    ${bbmod_enable_port}    separator=/
    Set Test Variable    ${HW_port_Id}    ${split_port}[-1]
    &{lock_info}    create dictionary
    ...             bbmod_enable_port=${bbmod_enable_port}
    ...             HW_port_Id=${HW_port_Id}
    log to console    \nGet the linkMode of primary cableLink of RMOD-${ru_index} - ${bbmod_enable_port}:
    log to console    synchronization:${syncStatus},configuration:${configStatus},data:${dataStatus}
    selenium_coam.lock_lane_from_sfp    hw_name=${bb_hw_name}    object_name=${HW_port_Id}    lane_id=LANE-${LANE_Id}
    log to console    \nLock LANE-${LANE_Id} from SFP by primary cableLink ${bbmod_enable_port} completed.
    [Return]    &{lock_info}
