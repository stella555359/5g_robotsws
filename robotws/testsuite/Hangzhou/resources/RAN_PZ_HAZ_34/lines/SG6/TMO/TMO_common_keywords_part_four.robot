*** Settings ***
Documentation    This is for TMO common keywords.
...              Please do not modify the file without notification to author
...              Author: stella.lin@nokia-sbell.com

Resource    ./TMO_common_keywords.robot

*** Keywords ***
TOL PCell Locked or Unlock on gNB
    [Documentation]  Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=120    ${cell_idx}=1    ${cell_perform}=lock
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    300 sec    5 sec    Connect to gnb coam via ssl
    ${cellgrp_id}    Get Cell Group From Cell    cell_id=${cell_idx}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
                             ...    allowed_faults=@{ALLOWED_FAULT}    connection=${connection}
    Run Keyword If   '${cell_perform}'=='lock'    Perform cell lock via rest api    cell_idx=${cell_idx}    timeout=${timeout}
    Run Keyword If   '${cell_perform}'=='lock'    Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Locked
                                 ...    cell_idx=${cell_idx}    cell_group_idx=${cellgrp_id}
                                 ...    connection=${connection}
    Run Keyword If   '${cell_perform}'=='unlock'   Perform cell unlock via rest api    cell_idx=${cell_idx}    timeout=${timeout}
    Run Keyword If   '${cell_perform}'=='unlock'   Wait Until Keyword Succeeds    600 sec    3 sec    Cell Should Be Unlocked
                                 ...    cell_idx=${cell_idx}
                                 ...    cell_group_idx=${cellgrp_id}
                                 ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Lock Or Unlock Or Reset BBMOD
    [Documentation]    tingting.1.liu@nokia-sbell.com
    [Arguments]         ${cell_index}    ${expect_bbmod_status}   ${gnb_connection}=GNB_OAM0
    ...     ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}   ${cell_type}=nr   ${timeout}=300
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl   connection=${gnb_connection}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='0'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}==${False} and '${cell_type}'=='lte'
    ...    ${enb_connection}    ${gnb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        ${rmod_info}    Get From List    ${item['carrierList']}    0
        ${rmod_id}    Get Regexp Matches    ${rmod_info['antennaLineId']['configuration']}    RMOD-(\\d+)    1
        ${cell_id}    Set variable    ${item['id']['configuration'].split('-')[-1]}
        Set To Dictionary    ${cell_list_info}    ${cell_id}=${rmod_id}[0]
    END
    ${cell_index}    Convert To string    ${cell_index}
    ${cell_rmod_index}   get from dictionary   ${cell_list_info}   ${cell_index}
    ${rmod_mapping}    coam.get_detected_hw_info   connection=${connection}
    ${rmod_bbmod_mapping}   get from dictionary   ${rmod_mapping}   cables
    &{rmod_bbmod_list_info}    Create Dictionary
    &{bbmod_linkmode_list_info}    Create Dictionary
    FOR  ${bbmod}   IN  @{rmod_bbmod_mapping}
        ${rmod_port_id}    Get Regexp Matches    ${bbmod['secondEndPointId']['configuration']}   RMOD-(\\d+)    1
        ${bbmod_port_id}   Get Regexp Matches    ${bbmod['firstEndPointId']['configuration']}    BBMOD-(\\d+)    1
        ${bbmod_port_num}   Get Length  ${bbmod_port_id}
        Run Keyword If    '${bbmod_port_num}'!='0'
        ...                       Set To Dictionary    ${rmod_bbmod_list_info}    ${rmod_port_id}[0]=${bbmod_port_id}[0]
    END
    ${expect_bbmod}   get from dictionary   ${rmod_bbmod_list_info}   ${cell_rmod_index}
    FOR  ${bbmod}   IN  @{rmod_bbmod_mapping}
        ${bbmod_port_id}   Get Regexp Matches    ${bbmod['firstEndPointId']['configuration']}    BBMOD-(\\d+)    1
        ${bbmod_port_id_length}    Get Length    ${bbmod_port_id}
        ${linkmode_status}   Set Variable       ${bbmod['linkMode']['configuration']}
        Run Keyword If    '${linkmode_status}'=='True' and '${bbmod_port_id_length}'!='${0}'
        ...          Set To Dictionary    ${bbmod_linkmode_list_info}    ${bbmod_port_id}[0]=${linkmode_status}
    END
    ${whether_linkmode_contain_mplane}   Run Keyword And Return Status    get from dictionary   ${bbmod_linkmode_list_info}   ${expect_bbmod}
    ${bbmod_linkmode_status}   Set Variable If      ${whether_linkmode_contain_mplane}      True      false
    ${output}   coam.get_fbb_info   connection=${connection}
    @{bbmod_list_lockunlock}   Create List
    @{bbmod_list_reset}   Create List
    FOR  ${bbmod_info}   IN  @{output}
        ${bbmod_number}   Set Variable   ${bbmod_info['id']['configuration'].split('-')[-1]}
        &{bbmod_number_dict}   create dictionary   ${bbmod_number}=${bbmod_info['id']['runtime']}
        Append To List    ${bbmod_list_lockunlock}    ${bbmod_number_dict}
    END
    FOR  ${bbmod_info}   IN  @{output}
        ${bbmod_number}   Set Variable   ${bbmod_info['id']['configuration'].split('-')[-1]}
        &{bbmod_number_dict}   create dictionary   ${bbmod_number}=${bbmod_info['id']['internal']}
        Append To List    ${bbmod_list_reset}    ${bbmod_number_dict}
    END
    ${bbmod_list}    Set Variable If       '${expect_bbmod_status}'=='reset'   ${bbmod_list_reset}    ${bbmod_list_lockunlock}
    FOR   ${bbmod}  IN   @{bbmod_list}
        ${bbmod_configuration_name_list}   Get Dictionary Keys   ${bbmod}
        ${bbmod_configuration_name}   Set Variable   ${bbmod_configuration_name_list[0]}
        ${bbmod_runtime_name_list}   get dictionary values   ${bbmod}
        ${bbmod_runtime_name}   Set Variable   ${bbmod_runtime_name_list[0]}
        Run Keyword If   '${bbmod_configuration_name}'=='${expect_bbmod}'   Run Keywords
        ...   Set Test Variable   ${dict_name}   ${bbmod_runtime_name}   AND  Exit For Loop
    END
    Run Keyword If   '${expect_bbmod_status}'=='Locked'     Wait Until Keyword Succeeds    20 min    5 sec    coam.lock
    ...                                         dist_name=${dict_name}   connection=${connection}
    ...   ELSE IF   '${expect_bbmod_status}'=='Unlocked'    Wait Until Keyword Succeeds    20 min    5 sec    coam.unlock
    ...                                         dist_name=${dict_name}   connection=${connection}
    ...   ELSE IF   '${expect_bbmod_status}'=='reset'       coam.reset_unit    dist_name=${dict_name}
    ...                                         reset_type=Warm   connection=${connection}   timeout=${timeout}
    ${output2}   coam.get_fbb_info   connection=${connection}
    &{bbmod_status_dict}   create dictionary
    FOR  ${bbmod_info}   IN  @{output2}
        Run Keyword If  '${bbmod_info['id']['runtime']}'=='${dict_name}'    Set To Dictionary   ${bbmod_status_dict}
        ...             administrativeState=${bbmod_info['status']['administrativeState']}
        ...             operationalState=${bbmod_info['status']['operationalState']}
        ...             usageState=${bbmod_info['status']['usageState']}
#        Run Keyword If  '${bbmod_info['id']['internal']}'=='${dict_name}'    Set To Dictionary   ${bbmod_status_dict}
#        ...             administrativeState=${bbmod_info['status']['administrativeState']}
#        ...             operationalState=${bbmod_info['status']['operationalState']}
#        ...             usageState=${bbmod_info['status']['usageState']}
    END
    run keyword if   '${expect_bbmod_status}'=='Locked'    Wait Until Keyword Succeeds    10 min    5 sec
    ...      Should Be Equal As Strings    ${bbmod_status_dict['administrativeState']}    Locked
    ...    ELSE IF   '${expect_bbmod_status}'=='Unlocked'    Wait Until Keyword Succeeds    10 min    5 sec
    ...      Should Be Equal As Strings    ${bbmod_status_dict['administrativeState']}    Unlocked
#    ...    ELSE IF   '${expect_bbmod_status}'=='reset'    Wait Until Keyword Succeeds    10 min    5 sec
#    ...      Should Be Equal As Strings    ${bbmod_status_dict['operationalState']}       disabled
    [Return]     ${bbmod_linkmode_status}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='0'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

COAM get ru cable port number and linkmode type
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                get ru opt id and linkmode for each ru, for example:
    ...                OPT_IF4: configuration, OPT_IF3: data, OPT_IF2: data, OPT_IF1: data
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    ${hw_info_mapping}    coam.get_detected_hw_info   connection=${connection}
    ${cables_mapping}   get from dictionary   ${hw_info_mapping}   cables
    &{rmod_linkmode_list_info}    Create Dictionary
    FOR  ${cable}   IN  @{cables_mapping}
        ${rmod_port_id}    Get Regexp Matches    ${cable['secondEndPointId']['configuration']}   RMOD-(\\d+)    1
        ${bbmod_port_id}   Get Regexp Matches    ${cable['firstEndPointId']['configuration']}    BBMOD-(\\d+)    1
        Run Keyword If    '${rmod_port_id}[0]'=='${ru_index}'    COAM get cable linkmode type
        ...            cable=${cable}    connection=${connection}     rmod_linkmode_list_info=${rmod_linkmode_list_info}
    END
    [Return]    ${rmod_linkmode_list_info}


Get fiber switch port for linkmode type data
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                for example:
    ...                OPT_IF4: configuration, OPT_IF3: data, OPT_IF2: data, OPT_IF1: data
    [Arguments]    ${rmod_linkmode_list_info}
    ${opt_index_list}    Get Dictionary Keys    ${rmod_linkmode_list_info}
    ${rmod_data_cables_used_channel}    Create List
    FOR    ${opt_index}    IN    @{opt_index_list}
        ${fiber_switch_no_list}    Set Variable
        ...        ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['OPT${opt_index}_fiber_switch_channel']}
        ${rmod_data_cables_used_channel} 	Run Keyword If    '${rmod_linkmode_list_info['${opt_index}']}'=='data'
        ...    Combine Lists    ${rmod_data_cables_used_channel} 	${fiber_switch_no_list}
        ...    ELSE    Set Variable    ${rmod_data_cables_used_channel}
    END
    [Return]    ${rmod_data_cables_used_channel}

COAM get cable linkmode type
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                get ru linkmode type for each ru, for example:
    ...                configuration, data
    [Arguments]    ${cable}    ${rmod_linkmode_list_info}    ${connection}=GNB_OAM
    log    ${connection}
    ${linkmode_status}   Set Variable       ${cable['linkMode']['configuration']}
    ${rmod_opt_port_num}   Get Regexp Matches    ${cable['secondEndPointId']['configuration']}   OPT_IF(\\d+)    1
    ${linkmode}    Set Variable If    '${linkmode_status}'=='True'    configuration    data
    Set To Dictionary    ${rmod_linkmode_list_info}    ${rmod_opt_port_num}[0]=${linkmode}

Get BBMOD List For RU AEHC Or AZHL
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_list}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    ${sn_list_of_special_ru}    Create List
    FOR    ${ru}    IN    @{ru_list}
        ${ru_index}    Get Index From List    ${ru_list}    ${ru}
        ${sn}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].serial_number}
        ${status}    Run Keyword And Return Status   Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ${ru_type}    Set Variable If    ${status}    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ...                                           ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type}
        Run Keyword If    '${ru_type}'=='AEHC' or '${ru_type}'=='AZHL' or '${ru_type}'=='AVHA'
        ...                                           Append To List    ${sn_list_of_special_ru}    ${sn}
    END
    Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${rmod_sn_mapping}    gnbaction.get_rmod_sn_mapping
    ${rmod_index_list}    Get Dictionary Keys    ${rmod_sn_mapping}
    ${rmod_list_of_special_ru}    Create List
    FOR    ${rmod_index}    IN    @{rmod_index_list}
        ${serial_number}    Set Variable    ${rmod_sn_mapping['${rmod_index}']}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${sn_list_of_special_ru}    ${serial_number}
        Run Keyword If    ${status}    Append To List    ${rmod_list_of_special_ru}    ${rmod_index}
    END
    ${rmod_bbmod_mapping}    gnbaction.get_rmod_bbmod_mapping
    ${bbmod_list_of_special_ru}    Create List
    FOR    ${rmod}    IN    @{rmod_list_of_special_ru}
        ${vlaue_list}    Get From Dictionary    ${rmod_bbmod_mapping}    ${rmod}
        ${bbmod_list_of_special_ru}    Combine Lists    ${bbmod_list_of_special_ru}    ${vlaue_list}
        ${bbmod_list_of_special_ru}    Remove Duplicates    ${bbmod_list_of_special_ru}
    END
    ${bbmod_distname_list}    Create List
    ${output}   coam.get_fbb_info   connection=${connection}
    FOR  ${bbmod_info}   IN  @{output}
        ${bbmod_number}   Set Variable   ${bbmod_info['id']['configuration'].split('-')[-1]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${bbmod_list_of_special_ru}    ${bbmod_number}
        Run Keyword If    ${status}    Append To List    ${bbmod_distname_list}    ${bbmod_info['id']['internal']}
    END
    [Return]     ${bbmod_distname_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get BBMOD List For All FDD RU
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_list}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    ${sn_list_of_special_ru}    Create List
    FOR    ${ru}    IN    @{ru_list}
        ${ru_index}    Get Index From List    ${ru_list}    ${ru}
        ${sn}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].serial_number}
        ${status}    Run Keyword And Return Status   Set Variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ${ru_type}    Set Variable If    ${status}    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type.value}
        ...                                           ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].radio_type}
        Run Keyword If    '${ru_type}'!='AEHC' and '${ru_type}'!='AZHL'    Append To List    ${sn_list_of_special_ru}    ${sn}
    END
    Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${rmod_sn_mapping}    gnbaction.get_rmod_sn_mapping
    ${rmod_index_list}    Get Dictionary Keys    ${rmod_sn_mapping}
    ${rmod_list_of_special_ru}    Create List
    FOR    ${rmod_index}    IN    @{rmod_index_list}
        ${serial_number}    Set Variable    ${rmod_sn_mapping['${rmod_index}']}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${sn_list_of_special_ru}    ${serial_number}
        Run Keyword If    ${status}    Append To List    ${rmod_list_of_special_ru}    ${rmod_index}
    END
    ${rmod_bbmod_mapping}    gnbaction.get_rmod_bbmod_mapping
    ${bbmod_list_of_special_ru}    Create List
    FOR    ${rmod}    IN    @{rmod_list_of_special_ru}
        ${vlaue_list}    Get From Dictionary    ${rmod_bbmod_mapping}    ${rmod}
        ${bbmod_list_of_special_ru}    Combine Lists    ${bbmod_list_of_special_ru}    ${vlaue_list}
        ${bbmod_list_of_special_ru}    Remove Duplicates    ${bbmod_list_of_special_ru}
    END
    ${bbmod_distname_list}    Create List
    ${output}   coam.get_fbb_info   connection=${connection}
    FOR  ${bbmod_info}   IN  @{output}
        ${bbmod_number}   Set Variable   ${bbmod_info['id']['configuration'].split('-')[-1]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${bbmod_list_of_special_ru}    ${bbmod_number}
        Run Keyword If    ${status}    Append To List    ${bbmod_distname_list}    ${bbmod_info['id']['internal']}
    END
    [Return]     ${bbmod_distname_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get RMOD List For Special RU
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_type}=AEHC    ${connection}=GNB_OAM0    ${gnb_index}=${0}    ${du_index}=${0}
    log    ${du_index}
    Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${rmod_distname_list}    Create List
    ${output}   coam.get_frm    timeout=60    connection=${connection}
    FOR  ${rmod_info}   IN  @{output}
        ${productName}   Set Variable   ${rmod_info['productName']}
        Run Keyword If    '${productName}'=='${ru_type}'    Append To List    ${rmod_distname_list}    ${rmod_info['id']['configuration']}
    END
    [Return]     ${rmod_distname_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check Unexpect Alarm And Trunk Roll
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    ${status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    ...                                                                              connection=${connection}
    Run Keyword If    not ${status}    Run Keywords
    ...    Common_keywords.Collect Snapshot Log    connection=${connection}    gnb_index=${0}    timeout=${2400}    AND
    ...    Fail    msg=Collected snapshot logs because of unexpect alarm happened.
    Check Truck Roll Alarm And Stop Robot Testing    connection=${connection}
    [Return]     ${status}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check GNB On Air And Unexpect Alarm Should Not Exist
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0    ${is_check_cell_onAir}=${True}
    ${status}    Run Keyword If    ${is_check_cell_onAir}    Run Keyword And Return Status    Check TMO Gnb Ready And All Cell On Air
    Run Keyword If    ${is_check_cell_onAir} and not ${status}    Run Keywords
    ...    Common_keywords.Collect Snapshot Log    connection=${connection}    gnb_index=${0}    timeout=${2400}    AND
    ...    Fail    msg=Collected snapshot logs because of cells not on air.
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
    ...                                                                              connection=${connection}
#    Run Keyword If    not ${status}    Run Keywords
#    ...    Common_keywords.Collect Snapshot Log    connection=${connection}    gnb_index=${0}    timeout=${2400}    AND
#    ...    Fail    msg=Collected snapshot logs because of unexpect alarm happened.
    Check Truck Roll Alarm And Stop Robot Testing    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check ENB On Air And Unexpect Alarm Should Not Exist
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=enblte    ${is_check_cell_onAir}=${True}
    ${enb_length}    Get Length    ${tl.enbs}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Run Keyword If    ${is_check_cell_onAir}    Wait Until Keyword Succeeds    10 min    20 sec
        ...    Verify Enb All Cell On Air    enb_index=${enb_index}
        Wait Until Keyword Succeeds    2 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${connection}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}
        ...                                                                              connection=${connection}
#        Run Keyword If    not ${status}    Run Keywords
#        ...    Common_keywords.Collect Enb Snapshot Log    enb_index=${enb_index}    connection=${connection}    timeout=${2400}    AND
#        ...    Fail    msg=Collected snapshot logs because of unexpect alarm happened.
        Check Truck Roll Alarm And Stop Robot Testing    connection=${connection}
        Run Keyword And Ignore Error    Enblte close down    connection=${connection}
    END
    [Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}

Check Truck Roll Alarm And Stop Robot Testing
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM0
    @{fault}    Create List    ${10}    ${16}    ${1806}    ${1868}    ${4341}    ${4352}    ${4383}
    ${active_alarms}    coam.get_active_alarms    connection=${connection}
    FOR   ${active_alarm}    IN   @{active_alarms}
        ${roll}    Run Keyword And Return Status    List Should not Contain Value    ${fault}    ${active_alarm['faultId']}
        Run Keyword If    not ${roll}    Fatal Error    msg=Fault ${active_alarm['faultId']}, possible truck roll issue, case failed!!!!!
    END

Lock Or Unlock NG Links In vCU
    [Documentation]    tingting.1.liu@nokia-sbell.com
    ...     para:  ${expected_value} should be 'Locked' or 'Unlocked'
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    ...            ${expected_value}=Locked   ${timeout}=300
    ...            ${ru_type}=AHFIG
    ...            ${cell_type}=nr
    ...            ${allowed_faults}=${GNB_ALLOWED_FAULT}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    @{SERVEDAMF_A}    coam.get_managed_objects    class_name=SERVEDAMF_A    connection=${connection}
    ${amf_numbers}    Get Length     ${SERVEDAMF_A}
    Run keyword and ignore error    COAM Teardown gnb connections
    FOR    ${amf_num}   IN RANGE    1      ${amf_numbers}+1
        Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
        Run Keyword If    '${expected_value}'=='Locked'   Wait Until Keyword Succeeds    3 min    5 sec    coam.lock_ng_link
        ...      dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/SERVEDAMF-${amf_num}
        ...      timeout=${timeout}   connection=${connection}
        ...    ELSE IF    '${expected_value}'=='Unlocked'   Wait Until Keyword Succeeds    3 min    5 sec    coam.unlock_ng_link
        ...      dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/SERVEDAMF-${amf_num}
        ...      timeout=${timeout}   connection=${connection}
        ${ngLinkStatus}    Set Variable If     '${expected_value}'=='Locked'     Inactive    Active
        Run Keyword And Continue On Failure        Verify SERVEDAMF Status On GNB
        ...          administrativeState=${expected_value}    target_amf_number=${amf_num}   ngLinkStatus=${ngLinkStatus}
        ...          ru_type=${ru_type}    cell_type=${cell_type}    expected_value=${expected_value}
        ...          allowed_faults=${allowed_faults}
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Perform BBMOD From AEHC Or AZHL Reset
    [Documentation]    tingting.1.liu@nokia-sbell.com
    ${bbmod_distname_list}    Get BBMOD List For RU AEHC Or AZHL
    FOR    ${bbmod_distname}    IN    @{bbmod_distname_list}
        Wait Until Keyword Succeeds    2 min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM0
        ...                                                                              gnb_index=${0}
        coam.reset_unit    dist_name=${bbmod_distname}    reset_type=Warm    force_radio_reset=${True}
        ...                timeout=${300}    connection=GNB_OAM0
        Check GNB On Air And Unexpect Alarm Should Not Exist
        Check ENB On Air And Unexpect Alarm Should Not Exist
    END
    [Teardown]   Teardown GNB and ENB Connections

#--- Kpi Caluate for OAM case---#
Case Status Init
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    Set Test Variable    ${CaseAVGLoop}     ${0}
    Set Test Variable    ${CaseSUM}         ${0}

Case Status Caluate
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${duration}=${0}    ${max}=${0}
    ${CaseSUM}    Run Keyword If    ${duration}<=${max}    Evaluate    ${CaseSUM}+${duration}
    ...    ELSE    Set Variable    ${CaseSUM}
    ${CaseAVGLoop}    Run Keyword If    ${duration}<=${max}    Evaluate    ${CaseAVGLoop}+${1}
     ...    ELSE    Set Variable    ${CaseAVGLoop}
    Set Test Variable    ${CaseSUM}     ${CaseSUM}
    Set Test Variable    ${CaseAVGLoop}         ${CaseAVGLoop}

Case Status Finnal
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${duration_time_list}    ${target_value}=${930}
    ${avg}    Run Keyword If     ${CaseAVGLoop}>0   Evaluate    ${CaseSUM}/${CaseAVGLoop}
    ...    ELSE    Fail    0 loop pass
    Append Case Result To File    index=Avg_value    target_value=${target_value}    result_value=${avg}
    Sort List    ${duration_time_list}
    Append Case Result To File    index=Max_value    target_value=${target_value}    result_value=${duration_time_list}[-1]

Copy File And Verify Whether Exist
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${source_file_path}    ${dest_file_path}=/home/ute/KPI_report    ${connection}=GNB_OAM    ${gnb_index}=${0}
    Wait Until Keyword Succeeds    3min    2sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${sw_version}     coam.get_sw_version    connection=${connection}
	${time}   DateTime.Get Current Date
	${time_start}    Fetch From Left     ${time}    ${SPACE}
    ${time_end}    Fetch From Right     ${time}    ${SPACE}
    Create Directory    ${dest_file_path}
    ${file_name}    Fetch From Right    ${source_file_path}    /
	${file_name}    Fetch From Left     ${file_name}    .
    ${dest_file_path}    Join Path    ${dest_file_path}    ${file_name}_${sw_version}_${time_start}_${time_end}.csv
    Run    cp ${source_file_path} ${dest_file_path}
    File Should Not Be Empty    ${dest_file_path}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Create Kpi Csv File
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    Set Test Variable    ${case_result_save_path}    ${TS_CASE_LOG_PATH}/${TEST NAME}_${tl_prefix}_${stream_version}.csv
    Create File    ${case_result_save_path}
    ${file_head}    Catenate    SEPARATOR=,    Index    Ru_type    Ru_index
    ...    Target_value    Result_value    Case_result\n
    Append To File    ${case_result_save_path}    ${file_head}

Append Case Result To File
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]   ${index}=NA    ${ru_type}=NA    ${ru_index}=NA
    ...           ${target_value}=NA   ${result_value}=NA    ${case_result}=NA
    ${check_kpi_value}    Run Keyword If
    ...    '${result_value}'!='NA' and '${target_value}'!='NA' and ${result_value}<=${target_value} and ${result_value}>${0}
    ...    Set Variable    pass
    ...    ELSE    Set Variable    fail
    ${target_value}    DateTime.Convert Date    ${target_value}    result_format=%Mmin%Ssec
    ${result_value}    DateTime.Convert Date    ${result_value}    result_format=%Mmin%Ssec
    ${data}    Run Keyword If    '${case_result}'!='NA'
    ...   Catenate    SEPARATOR=,    ${index}    ${ru_type}
    ...   ${ru_index}    ${target_value}    ${result_value}    ${case_result}\n
    ...   ELSE    Catenate    SEPARATOR=,    ${index}    ${ru_type}
    ...   ${ru_index}    ${target_value}    ${result_value}    ${check_kpi_value}\n
    Append To File    ${case_result_save_path}    ${data}

Loop For Site Reset Via WEBUI
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    2min    20sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${timestartTmp}   DateTime.Get Current Date
    ${timestart}    DateTime.Convert Date    ${timestartTmp}    epoch
    coam.reset_site    timeout=${1800}    connection=${connection}
    ${reset_status_Tmp}    Run Keyword And Return Status    Check All Cells Should Be On Air
    ${timeendTmp}    DateTime.Get Current Date
    ${timeend}    DateTime.Convert Date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800 	  Pass    Fail
    [Return]    ${reset_status}   ${duration_time_tmp}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Loop For RU Reset Via WEBUI
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${log_timeout}=${60}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    Wait Until Keyword Succeeds    2min    20sec    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ...    timeout=${log_timeout}    gnb_index=${gnb_index}    url=${url}    username=${username}    password=${password}
    ${timestartTmp}   DateTime.Get Current Date
    ${timestart}    DateTime.Convert Date    ${timestartTmp}    epoch
    selenium_coam.reset_ru_from_site_view    ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min    5sec    Check RU Whether Should Be Offline    ru_index=${ru_index}    gnb_index=${gnb_index}
    ${reset_status_Tmp}    Run Keyword And Return Status    Check All Cells Should Be On Air
    ${timeendTmp}    DateTime.Get Current Date
    ${timeend}    DateTime.Convert Date    ${timeendTmp}     epoch
    ${duration_time_tmp}    Evaluate    ${timeend}-${timestart}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True" and ${duration_time_tmp}<1800 	  Pass    Fail
    [Return]    ${reset_status}   ${duration_time_tmp}
    [Teardown]    Run Keyword And Ignore Error    COAM selenium logout

Check RU Whether Should Be Offline
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}    ${gnb_index}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Make RU Reset With Retry
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_index}    ${reset_time}    ${max}    ${duration_time_list}    ${timeout}=${2400}
    FOR    ${i}    IN RANGE    ${reset_time}
        Run Keyword And Ignore Error    Run    command=rm /tmp/btslog2/* -rf
        Run Keyword And Ignore Error    Start To Collect Btslog    btslog_collector_name=btslog_${i+1}
        ${res}    Run Keyword And Ignore Error    Loop For RU Reset Via WEBUI    ru_index=${ru_index}
        ${reset_status}         Set Variable If    '${res[0]}'=='FAIL'      fail    ${res[1][0]}
        ${duration_time_tmp}    Set Variable If    '${res[0]}'=='FAIL'      1800    ${res[1][1]}
        Case Status Caluate    duration=${duration_time_tmp}    max=${max}
        Run Keyword If   ${duration_time_tmp}<=${max}    Append To List    ${duration_time_list}    ${duration_time_tmp}
        Log To Console     Case loop ${i+1} END
        Append Case Result To File    index=${i+1}    ru_type=AEHC    ru_index=${ru_index}
        ...    target_value=${max}    result_value=${duration_time_tmp}
        Run Keyword And Ignore Error    Stop Btslog Collection    btslog_collector_name=btslog_${i+1}
        ${unexpect_alarm_should_not_exist}    Check Unexpect Alarm And Trunk Roll
        Run Keyword If   ${unexpect_alarm_should_not_exist} and ${duration_time_tmp}>${max}
        ...    Run Keyword And Ignore Error    Common_keywords.Collect Snapshot Log    timeout=${timeout}
        ...    ELSE    Sleep    1min
    END

Check All Cells Should Be On Air
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
     Wait Until Keyword Succeeds    30min    2sec    Wait Gnb Ready And Cell On Air For Kpi

Wait Gnb Ready And Cell On Air For Kpi
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_id}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    COAM Check GNB ABIL status    connection=${connection}
    COAM Check GNB ASIK status    connection=${connection}
    COAM Check GNB RU status    connection=${connection}
    Verify all cells should be onair    connection=${connection}
    ${gnb_type}    Get gNbType SA or NSA via rest api    connection=${connection}
    Run Keyword If    'NSA' in '${gnb_type}'    COAM Check X2 link status from GNB    connection=${connection}
    Verify Gnb Type Cells Should Be Onair    cell_type=lte    connection=${connection}
    Verify Gnb Type Cells Should Be Onair    cell_type=wcdma    connection=${connection}
    Verify Gnb Type Cells Should Be Onair    cell_type=gsm    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check Counter Value For ANR
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...                Description: for case 5603104, check counter: M55124C05002、M55147C01002、M55147C01001 at the same time
    [Arguments]  ${cell_index}    ${connection}=GNB_OAM    ${change_interval}=1min
    ...          ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...          ${MRBTS_id}=${tl.gnbs[0].instance_id}
    log    ${change_interval}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    Log to console    Gathering value of counter: "M55124C05002"
    ${counters_info} =    coam.get_counters_info    connection=${connection}    timeout=120
    ${counter_groups} =    Get From Dictionary    ${counters_info}    BTS
    ${M55124C05002_path}    set variable if    '${stream_version}' == '24R1' or '${stream_version}' == '23R4'
    ...    CELLS/NRCELL-${cell_index}/NRRCC/NRRCC_NRCGI_REPORT_RECV
    ...    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_index}/NRRCC/NRRCC_NRCGI_REPORT_RECV
    ${M55147C01002_path}    set variable if    '${stream_version}' == '24R1' or '${stream_version}' == '23R4'
    ...    CELLS/NRCELL-${cell_index}/NMOCU/NMOCU_ANR_NRREL_OVER_LIMIT
    ...    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_index}/NMOCU/NMOCU_ANR_NRREL_OVER_LIMIT
    ${M55147C01001_path}    set variable if    '${stream_version}' == '24R1' or '${stream_version}' == '23R4'
    ...    CELLS/NRCELL-${cell_index}/NMOCU/NMOCU_ANR_NRREL_ADD
    ...    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_index}/NMOCU/NMOCU_ANR_NRREL_ADD
    ${M55124C05002_counter_group_keys} =    Split String    ${M55124C05002_path}     /
    ${M55147C01002_counter_group_keys} =    Split String    ${M55147C01002_path}   /
    ${M55147C01001_counter_group_keys} =    Split String    ${M55147C01001_path}   /
    ${M55124C05002_counter_groups_length} =    Get Length    ${M55124C05002_counter_group_keys}
    ${M55147C01002_counter_groups_length} =    Get Length    ${M55147C01002_counter_group_keys}
    ${M55147C01001_counter_groups_length} =    Get Length    ${M55147C01001_counter_group_keys}
    Remove From List    ${M55124C05002_counter_group_keys}    ${M55124C05002_counter_groups_length-1}
    Remove From List    ${M55147C01002_counter_group_keys}    ${M55147C01002_counter_groups_length-1}
    Remove From List    ${M55147C01001_counter_group_keys}    ${M55147C01001_counter_groups_length-1}
    ${cells_counter_groups} =    run keyword if    '${stream_version}' == '24R1' or '${stream_version}' == '23R4'
    ...    Get From Dictionary    ${counter_groups}    CELLS
    ${mrbts_counter_groups} =    run keyword if    '${stream_version}' != '24R1' and '${stream_version}' != '23R4'
    ...    Get From Dictionary    ${counter_groups}    MRBTS-${MRBTS_id}
    ${nrbts_counter_groups} =    run keyword if    '${stream_version}' != '24R1' and '${stream_version}' != '23R4'
    ...    Get From Dictionary    ${mrbts_counter_groups}    NRBTS-${nr_bts_id}
    ${counter_groups}    set variable if    '${stream_version}' == '24R1' or '${stream_version}' == '23R4'
    ...    ${cells_counter_groups}     ${nrbts_counter_groups}
    ${counter_groups} =    Get From Dictionary    ${counter_groups}    NRCELL-${cell_index}
    ${M55124C05002_counter_groups} =    Get From Dictionary    ${counter_groups}    ${M55124C05002_counter_group_keys[-1]}
    ${M55147C01002_counter_groups} =    Get From Dictionary    ${counter_groups}    ${M55147C01002_counter_group_keys[-1]}
    ${M55147C01001_counter_groups} =    Get From Dictionary    ${counter_groups}    ${M55147C01001_counter_group_keys[-1]}
    ${M55124C05002_counter_values} =    Get From Dictionary    ${M55124C05002_counter_groups}    M55124C05002
    ${M55124C05002_key_list} =     Get Dictionary Keys    ${M55124C05002_counter_values}
    Reverse List    ${M55124C05002_key_list}
    ${M55124C05002_latest_value} =    Get From Dictionary    ${M55124C05002_counter_values}    ${M55124C05002_key_list[0]}
    ${M55124C05002_value}    convert to integer     ${M55124C05002_latest_value}
    Should Be True    ${M55124C05002_value} == 1
    Log to console    Gathering value of counter: "M55147C01002"
    ${M55147C01002_counter_values} =    Get From Dictionary    ${M55147C01002_counter_groups}    M55147C01002
    ${M55147C01002_key_list} =     Get Dictionary Keys    ${M55147C01002_counter_values}
    Reverse List    ${M55147C01002_key_list}
    ${M55147C01002_latest_value} =    Get From Dictionary    ${M55147C01002_counter_values}    ${M55147C01002_key_list[0]}
    ${M55147C01002_value}    convert to integer     ${M55147C01002_latest_value}
    Should Be True    ${M55147C01002_value} == 0
    Log to console    Gathering value of counter: "M55147C01001"
    ${status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${M55147C01001_counter_groups}    M55147C01001
    ${M55147C01001_counter_values} =  Run Keyword If   ${status}
    ...           Get From Dictionary    ${M55147C01001_counter_groups}    M55147C01001
    ${M55147C01001_key_list} =     Run Keyword If   ${status}
    ...           Get Dictionary Keys    ${M55147C01001_counter_values}
    Run Keyword If   ${status}     Reverse List    ${M55147C01001_key_list}
    ${M55147C01001_latest_value} =    Run Keyword If   ${status}
    ...           Get From Dictionary    ${M55147C01001_counter_values}    ${M55147C01001_key_list[0]}
    ${M55147C01001_value}    Run Keyword If   ${status}     convert to integer     ${M55147C01001_latest_value}
    Run Keyword If   ${status}    Should Be True    ${M55147C01001_value} == 0
    [Teardown]    Run Keyword And Ignore Error     COAM Teardown gnb connections    connection=${connection}

Get cellBwpList Length From SCF
    [Arguments]      ${cell_id}=1
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${dist_name}=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_id}
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
    @{cellBwpList_param}    create list
    @{BWP_PROFILE_list}    create list
    &{cellBwpList_dict}    Create Dictionary    dist_name=${dist_name}
    ...                                                           parameter=cellBwpList
    ...                                                           value=none
    Append To List    ${cellBwpList_param}    ${cellBwpList_dict}
    ${cellBwpList}    coam_parameter.get_list_values_from_scf_file    parameters=${cellBwpList_param}
    ...                                                               connection=${connection}
    ...                                                               timeout=300
    ${cellBwpList_value}    set variable    ${cellBwpList[0]['value']}
    FOR    ${item}    IN    @{cellBwpList_value}
        ${status}    Run Keyword And Return Status    Should Contain     ${item}    BWP_PROFILE
        run keyword if    ${status}    append to list    ${BWP_PROFILE_list}    ${item}
    END
    ${BWP_PROFILE_length}      Get Length    ${BWP_PROFILE_list}
    [Return]    ${BWP_PROFILE_length}


Get nrhoirDNList value From SCF
    [Arguments]      ${cell_id}=301
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...              ${dist_name}=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_id}
    wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
    @{nrhoirDNList_list}    create list
    &{nrhoirDNList_dict}    Create Dictionary    dist_name=${dist_name}
    ...                                          parameter=nrhoirDNList
    ...                                          value=none
    Append To List    ${nrhoirDNList_list}    ${nrhoirDNList_dict}
    ${nrhoirDNList_value}    coam_parameter.get_list_values_from_scf_file    parameters=${nrhoirDNList_list}
    ...                                                               connection=${connection}
    ...                                                               timeout=300
    [Return]   ${nrhoirDNList_value[0]['value']}


Modify chBW And Related Parameters via WebUI
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...     for case:5603105, all default values are used for 80MHz configuration
    [Arguments]     ${cell_list}
    ...             ${configuration_type}=80MHz
    ...             ${bwpdn0_profile}=187
    ...             ${bwpdn1_profile}=217
    ...             ${bwpdn2_profile}=233
    ...             ${bwpdn3_profile}=87
    ...             ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...             ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...             ${cellchBW_value}=80MHz
    ...             ${nrarfcn_value}=510024
    ...             ${csirsPower_value}=17
    ...             ${cSRS_value}=23
    ...             ${maxCsirsNumber_value}=1
    ...             ${actMultipleDedicatedBWPs_value}=true
    ...             ${actEnhMultipleDedicatedBWPs_value}=true
    ...             ${actPowerSavingBWP_value}=true
    ...             ${actDynPdcchTd_value}=false
    ...             ${gscnOrSsPbchArfcn_value}=6303
    ...             ${msg1FrequencyStart_value}=28
    ...             ${reqMinNumPuschPrb_value}=189
    ...             ${ssPbchBlockPower_value}=14
    ...             ${pMax_value}=32.7
    ...             ${connection}=GNB_OAM
    ...             ${gnb_index}=0
    ...             ${timeout}=300
    ...             ${actDynPdcchTdMode}=disabled
    ...             ${actInitialBWPFlexibility_value}=false
#    ...             ${actNrRim_value}=RI detection and mitigation
    ...             ${globalF0ForRs_value}=510024
    log    ${MRBTS_id}
    log    ${timeout}
    @{update_param_list}    Create List
    @{value_list}    Create List
    @{delete_param_list}    Create List
    @{add_param_list}    Create List
    @{cellBwpList_added}    Run Keyword If    '${configuration_type}'=='80MHz'    Create list    ${0}    ${1}    ${2}    ${3}
    ...      ELSE      Create list    ${0}    ${1}
    ${actMultipleDedicatedBWPs}     Create Dictionary      dist_name=NRBTS-${nr_bts_id}
    ...                                   abbr=actMultipleDedicatedBWPs
    ...                                   filter_param=Activate multiple dedicated bandwidth parts (BWPs)
    ...                                   new_value=${actMultipleDedicatedBWPs_value}
    Append To List    ${update_param_list}    ${actMultipleDedicatedBWPs}
    FOR    ${cell}   IN    @{cell_list}
        ${dist_name}    Set Variable    NRCELL-${cell}
        ${dist_name_for_globalF0ForRs}    Set Variable    NRCELL-${cell}/NRRIM_PROFILE-1
        ${csirsPower}     Create Dictionary     dist_name=${dist_name}
        ...                                   abbr=csirsPower
        ...                                   filter_param=CSI-RS power
        ...                                   new_value=${csirsPower_value}
        ${maxCsirsNumber}     Create Dictionary     dist_name=${dist_name}
        ...                                   abbr=maxCsirsNumber
        ...                                   filter_param=Maximum CSI-RS number
        ...                                   new_value=${maxCsirsNumber_value}
        ${cSRS}     Create Dictionary         dist_name=${dist_name}
        ...                                   abbr=cSRS
        ...                                   filter_param=SRS bandwidth configuration
        ...                                   new_value=${cSRS_value}
        ${cellchBW}     Create Dictionary     dist_name=${dist_name}
        ...                                   abbr=chBw
        ...                                   filter_param=Channel bandwidth
        ...                                   new_value=${cellchBW_value}
        ${actInitialBWPFlexibility_value} = 	Set Variable If    '${stream_version}'=='23R4'
        ...                                     ${actInitialBWPFlexibility_value}      ${actPowerSavingBWP_value}
        ${actInitialBWPFlexibility}     Create Dictionary     dist_name=${dist_name}
        ...                                   abbr=actInitialBWPFlexibility
        ...                                   filter_param=Activate flexible setting of initial bandwidth part
        ...                                   new_value=${actInitialBWPFlexibility_value}
        ${actULSchedInactiveBwp}        Create Dictionary     dist_name=${dist_name}
        ...                                   abbr=actULSchedInactiveBwp
        ...                                   filter_param=Activate UL scheduling for inactive BWP
        ...                                   new_value=${actPowerSavingBWP_value}
        ${nrarfcn}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=nrarfcn
        ...                                   filter_param=NR Absolute radio frequency channel number
        ...                                   new_value=${nrarfcn_value}
        ${globalF0ForRs}     Create Dictionary      dist_name=${dist_name_for_globalF0ForRs}
        ...                                         abbr=globalF0ForRs
        ...                                         filter_param=Global F0 for RIM-RS
        ...                                         new_value=${globalF0ForRs_value}
        ${actEnhMultipleDedicatedBWPs}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=actEnhMultipleDedicatedBWPs
        ...                                   filter_param=Activate enhanced multiple dedicated bandwidth parts (BWPs)
        ...                                   new_value=${actEnhMultipleDedicatedBWPs_value}
        ${actPowerSavingBWP}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=actPowerSavingBWP
        ...                                   filter_param=Activate power saving bandwidth part
        ...                                   new_value=${actPowerSavingBWP_value}
        ${actLAForHiReliab}     Create Dictionary     dist_name=${dist_name}
        ...                                  abbr=actLAForHiReliab
        ...                                  filter_param=Activate link adaptation for high reliability DRB
        ...                                  new_value=false
        ${gscnOrSsPbchArfcn}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=gscnOrSsPbchArfcn
        ...                                   filter_param=Synchronization channel number
        ...                                   new_value=${gscnOrSsPbchArfcn_value}
        ${msg1FrequencyStart}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=msg1FrequencyStart
        ...                                   filter_param=PRACH Frequency start
        ...                                   new_value=${msg1FrequencyStart_value}
        ${pMax}     Create Dictionary         dist_name=${dist_name}
        ...                                   abbr=pMax
        ...                                   filter_param=Maximum output power
        ...                                   new_value=${pMax_value}
        ${reqMinNumPuschPrb}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=reqMinNumPuschPrb
        ...                                   filter_param=Requested minimum number of PUSCH PRBs
        ...                                   new_value=${reqMinNumPuschPrb_value}
        ${ssPbchBlockPower}     Create Dictionary      dist_name=${dist_name}
        ...                                   abbr=ssPbchBlockPower
        ...                                   filter_param=SS PBCH Block Power
        ...                                   new_value=${ssPbchBlockPower_value}
#        ${actNrRim}    Create Dictionary    dist_name=${dist_name}
#        ...                                 abbr=actNrRim
#        ...                                 filter_param=Activate NR remote interference management
#        ...                                 new_value=${actNrRim_value}
        Generate remove element for bwpDN    cell_id=${cell}    delete_param_list=${delete_param_list}
        Generate add element for bwpDN    cell=${cell}    add_param_list=${add_param_list}    cellBwpList_added=${cellBwpList_added}
        ...         bwpdn0_profile=${bwpdn0_profile}
        ...         bwpdn1_profile=${bwpdn1_profile}
        ...         bwpdn2_profile=${bwpdn2_profile}
        ...         bwpdn3_profile=${bwpdn3_profile}
        ${dynPdcchTdMgt_23R3}     Create Dictionary     dist_name=${dist_name}
        ...                                  abbr=dynPdcchTdMgt
        ...                                  filter_param=CActivate dynamic PDCCH time domain
        ...                                  new_value=${actDynPdcchTd_value}
        ${dynPdcchTdMgt_trunk}     Create Dictionary     dist_name=${dist_name}
        ...                                  abbr=actDynPdcchTdMode
        ...                                  filter_param=Active dynamic PDCCH time domain mode
        ...                                  new_value=${actDynPdcchTdMode}
        ${dynPdcchTdMgt}    Set Variable If      '${stream_version}'=='23R3'     ${dynPdcchTdMgt_23R3}    ${dynPdcchTdMgt_trunk}
        Append To List    ${update_param_list}    ${cellchBW}     ${nrarfcn}    ${globalF0ForRs}     ${actEnhMultipleDedicatedBWPs}
        ...               ${actPowerSavingBWP}    ${gscnOrSsPbchArfcn}    ${msg1FrequencyStart}    ${pMax}    ${actLAForHiReliab}
#        ...               ${reqMinNumPuschPrb}    ${ssPbchBlockPower}    ${actNrRim}    ${cSRS}   ${actULSchedInactiveBwp}
        ...               ${reqMinNumPuschPrb}    ${ssPbchBlockPower}    ${cSRS}   ${actULSchedInactiveBwp}
        ...               ${csirsPower}   ${maxCsirsNumber}    ${dynPdcchTdMgt}    ${actInitialBWPFlexibility}
    END
    ${delete_param_list_new}    Set Variable    ${delete_param_list}
    ${add_param_list_new}    Set Variable    ${add_param_list}
    ${update_param_list_new}    Set Variable    ${update_param_list}
    log to console    --- start to update bwp related params via WEBUI---
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
	${active_version}    coam.get_sw_version    timeout=60    connection=${connection}
	${version_splitted}    Split String    ${active_version}    _
    ${sw_version}    Strip string    ${version_splitted[0]}
    Selenium Login And Disable Screen Lock    browser=Chrome    version=${sw_version}
    WEBUI Remove Element For bwpDN    deleted_params=${delete_param_list_new}
    WEBUI Add Element For bwpDN    added_params=${add_param_list_new}
    WEBUI Update Param For bwpDN    updated_params=${update_param_list_new}
    log to console    --- start to validate and activate plan---
    selenium_coam.validate_plan
    Run Keyword And Continue On Failure    COAM check validation errors from webui    is_need_to_check_validation_errors=${True}
    selenium_coam.activate_plan   download_plan_without_activation=${False}    activate_plan_despite_errors=${True}
    ...   execute=${True}   timeout=600
    sleep  30s
    Close Start Up View    timeout=60
    [Teardown]    run keyword and ignore error    selenium logout and close browser


Update Parameter to prepare L3 call
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM   ${para_value}=true     ${qRxLevMin}=-60    ${gnb_index}=0
    ...          ${ulTReassemblyIBCA}=40
    ...            ${whether_check_scell_addition}=${True}
    ...            ${whether_do_barred_action}=${True}
    ...            ${whether_check_on_air}=${True}
    ...            ${whether_do_ue_prepare}=${False}
    ...            ${ue_mode}=SA
    ...            ${whether_do_lte_cell_locked}=${False}
    ...            ${b1_select_cell_index}=${PCELL_INDEX}
    ...            ${notbarred_cell_index}=${PCELL_INDEX}
    ...            ${exp_status}=notBarred
    ...            ${lte_exp_status}=notBarred
    ...            ${whether_do_lte_barred_action}=${False}
    ...            ${enb_index}=${1}
    ...            ${whether_change_fren}=${True}
    log    ${connection}
    log    ${whether_check_scell_addition}
    log    ${whether_do_ue_prepare}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    ${modify_param}    Create List
	&{actRedirect_param}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}
	...                                                      parameter=actRedirect    value=${para_value}
	Append To List    ${modify_param}    ${actRedirect_param}
	&{actNormVCFallback_param}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}
	...                                                      parameter=actNormVCFallback    value=${para_value}
	Append To List    ${modify_param}    ${actNormVCFallback_param}
    &{qRxLevMin_param}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${PCELL_INDEX}
	...                                                      parameter=qRxLevMin    value=${qRxLevMin}
	Append To List    ${modify_param}    ${qRxLevMin_param}
	&{ulTReassemblyIBCA1_param}    Create Dictionary
	...                             dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDRB_RLC_AM-1
	...                             parameter=ulTReassemblyIBCA    value=${ulTReassemblyIBCA}
	Append To List    ${modify_param}    ${ulTReassemblyIBCA1_param}
	&{ulTReassemblyIBCA2_param}    Create Dictionary
	...                             dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDRB_RLC_AM-2
	...                             parameter=ulTReassemblyIBCA    value=${ulTReassemblyIBCA}
	Append To List    ${modify_param}    ${ulTReassemblyIBCA2_param}
	&{ulTReassemblyIBCA3_param}    Create Dictionary
	...								dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRDRB_RLC_AM-3
	...                             parameter=ulTReassemblyIBCA    value=${ulTReassemblyIBCA}
	Append To List    ${modify_param}    ${ulTReassemblyIBCA3_param}
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${modify_param}    timeout=900
    Wait until keyword succeeds    10 min    20 sec   verify all cells should be onair
    Run Keyword If   '${ue_mode}'=='NSA'    Get RU Index Of LTE Cell    cell_index=${list_cell_ids}
    ...                                                                 gnb_id=${gnb_index}
    ...                                                                 enb_index=${enb_index}
    Run Keyword If   '${ue_mode}'=='NSA'    Modify PA Value Setting For Required RU    modify_ru_id=${NSA_PA_RU_INDEX}
    ...                                                                                ue_index=${ue_index}
    Run Keyword If   '${LTE_WHETHER_IN_GNB}'=='${False}' and '${ue_mode}'=='NSA'    Change cellBarred Parameter Value Of Lte Cells
    ...    list_cell_ids=all    exp_status=barred    enb_index=${0}
    Run Keyword If    ${whether_do_lte_barred_action}    Change cellBarred Parameter Value Of Lte Cells
    ...                                                      list_cell_ids=${list_cell_ids}
    ...                                                      exp_status=${lte_exp_status}
    ...                                                      enb_index=${enb_index}
    Run Keyword If    ${whether_do_barred_action}    Change cellBarred Parameter Value On Gnb    pcell_index=${notbarred_cell_index}
    ...                                                                                          exp_status=${exp_status}
    Run Keyword If   '${ue_mode}'=='NSA' and ${whether_change_fren}
    ...               Update Priority Of NR Frequency Band In ENDCDMEASCONF    cell_index=${b1_select_cell_index}
    Run Keyword If    ${whether_check_on_air}    Check TMO Gnb Ready And All Cell On Air
    Run Keyword If    ${whether_do_lte_cell_locked} and '${tl_prefix}'=='T813'      Do All TDD-LTE Cells Action
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

kill DL iperf port
    [Documentation]  xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${dl_port}     ${appserver}=APPserver
    log    ${appserver}
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    [Teardown]    csn.disconnect    connection=APPserver

Close the iperf in UE
    [Documentation]  xiangsheng.chu@nokia-sbell.com
    ...              This keyword connect to android control pc and start the iperf data.
    [Arguments]    ${ue_index}    ${ul_port}     ${appserver}=APPserver
    log    ${appserver}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}     ${iperf_index}=${2}
    ...    ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${ul_port}    serial_number=${serial_number}
    ...                                      iperf_index=${iperf_index}
    ...                                      cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}

start DL with static IP
    [Documentation]  xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}
    ...    ${appserver}=APPserver    ${protocol}=udp    ${ue_index}=${0}    ${process_num}=${2}
    ...    ${seg_size}=${1180}    ${window}=2M
    log many    ${seg_size}    ${ue_index}    ${window}    ${process_num}
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ${command}    Catenate    iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P ${process_num} -f m -b
    ...    ${dl_throughput} -l ${dl_length} -T 64 &
    run keyword if    '${protocol}'=='udp'    csn.send command
    ...    command=${command}
    ...    connection=APPserver
    sleep    1s
    Check the iperf progress exist    connection=APPserver    port=${dl_port}
    [Teardown]    csn.disconnect    connection=APPserver

Start UL in UE
    [Documentation]     xiangsheng.chu@nokia-sbell.com
    ...                 This keyword connect to android control pc and start the iperf data.
    [Arguments]    ${ue_index}    ${ul_time}    ${ul_port}    ${ul_throughput}    ${ul_length}    ${iperf_path}=iperf
    ...    ${appserver}=APPserver    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${protocol}=udp     ${process_num}=${1}   ${iperf_index}=${2}
    log    ${process_num}
    ${cmd_ul_traffic}=    run keyword if    '${appserver}'=='APPserver'       catenate    adb -s ${serial_number} shell
    ...     ${iperf_path} -c ${appserver_addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P 1 -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    run keyword if    '${protocol}'=='udp'    csn.send_command    command=${cmd_ul_traffic}    connection=cpc_${ue_index}
    sleep    3s
    Check the iperf progress exist    connection=cpc_${ue_index}    port=${ul_port}    ue_sn=${serial_number}
    ...   iperf_index=${iperf_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

MultiUE Prepare UE
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${ue_index}=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    ...               ${low_RSRP}=False    ${MultiUECFGLOWRSRPTP}=MultiUECFGLOWRSRPTP
    log    ${ue_index}
    ${RSRP_low_peak}    Set Variable If   ${low_RSRP}==True      low     good
    Modify Attenuation Vaule For KPI    attenuator_list=${attenuator_list}    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    ...            RSPR_PA=${RSRP_low_peak}
    log to console      "Prepare UE"
    Run Keyword If    '${tl_prefix}'=='T284'    power_ue.Prepare UE
    ...                      ue_type=sigspark_multiUE
    ...    multiue_traffic_config=${TL284CommonConfiglowRSRPlowTP["${MultiUECFGLOWRSRPTP}"]}
    ...        ELSE IF    '${tl_prefix}'=='T073'    Run Keyword And Ignore Error    power_ue.Prepare UE
    ...                      ue_type=sigspark_multiUE
    ...    multiue_traffic_config=${TL73CommonConfiglowRSRPlowTP["${MultiUECFGLOWRSRPTP}"]}
    ...        ELSE IF    '${tl_prefix}'=='T080'    power_ue.Prepare UE
    ...                      ue_type=sigspark_multiUE
    ...    multiue_traffic_config=${TL80CommonConfiglowRSRPlowTP["${MultiUECFGLOWRSRPTP}"]}

MultiUE Prepare UE For Spark
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${ue_index}=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    ...               ${MultiUECFGLOWRSRPTP}=MultiUECFGLOWRSRPTP
    log    ${ue_index}
    log to console      "Prepare UE"
    Run Keyword If    '${tl_prefix}'=='T284'    power_ue.Prepare UE
    ...                      ue_type=sigspark_multiUE    multiue_traffic_config=${TL284CommonConfiglowRSRPlowTP["${MultiUECFGLOWRSRPTP}"]}
    ...        ELSE IF    '${tl_prefix}'=='T073'    power_ue.Prepare UE
    ...                      ue_type=sigspark_multiUE    multiue_traffic_config=${TL73CommonConfiglowRSRPlowTP["${MultiUECFGLOWRSRPTP}"]}
    ...        ELSE IF    '${tl_prefix}'=='T080'    power_ue.Prepare UE
    ...                      ue_type=sigspark_multiUE    multiue_traffic_config=${TL80CommonConfiglowRSRPlowTP["${MultiUECFGLOWRSRPTP}"]}

MultiUE Attach KPI without prepare UE for 8311
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${logpath}    ${logname}       ${ue_index}=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...            ${start_keep_on_duration}=10    ${buffer_size}=1350B
    ...            ${appserver}=APPserver     ${protocol}=udp    ${low_RSRP}=False   ${peak_TP}=True
    ...            ${DL_400M_8311}=DL_400M_8311      ${DL_10M_8311}=DL_10M_8311
    ...            ${process_num}=${2}    ${seg_size}=${1372}    ${window}=2M      ${ul_process_num}=${1}
    log    ${low_RSRP}
    log    ${peak_TP}
    log    ${ul_process_num}
    Run Keyword And Continue On Failure       Spark_common_keywords.Spark Start multi UE Log    logpath=${logpath}
    ...    logname=${logname}
    log to console      "UE Attach"
    power_ue.UE Attach     ue_type=sigspark_multiUE
    ${DL_400M}    Set Variable     ${KPI_PA['${tl_prefix}']['${DL_400M_8311}']}
    ${DL_10M}    Set Variable     ${KPI_PA['${tl_prefix}']['${DL_10M_8311}']}
    Kill multiUE DL iperf port
    Start mutltiUE DL with static IP     dl_time=${start_keep_on_duration}
    ...                                  dl_throughput=${DL_400M}
    ...                                  dl_length=${buffer_size}
    ...                                  appserver=${appserver}
    ...                                  protocol=${protocol}
    ...                                  ue_index=${ue_index}
    ...                                  process_num=${process_num}
    ...                                  seg_size=${seg_size}
    ...                                  window=${window}
    sleep    30s
    Start mutltiUE DL with static IP     dl_time=${start_keep_on_duration}
    ...                                  dl_throughput=${DL_10M}
    ...                                  dl_length=${buffer_size}
    ...                                  appserver=${appserver}
    ...                                  protocol=${protocol}
    ...                                  ue_index=${ue_index}
    ...                                  process_num=${process_num}
    ...                                  seg_size=${seg_size}
    ...                                  window=${window}
    sleep    10s
    power_ue.UE Detach        ue_type=sigspark_multiUE
    Run Keyword And Ignore Error      Spark_common_keywords.Spark Stop multi UE Log

Start mutltiUE DL with static IP
    [Documentation]  xiangsheng.chu@nokia-sbell.com
    [Arguments]     ${dl_time}   ${dl_throughput}    ${dl_length}
    ...    ${appserver}=APPserver    ${protocol}=udp    ${ue_index}=${0}    ${process_num}=${2}
    ...    ${seg_size}=${1180}    ${window}=2M
    ${ue2_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.52
    ...                                     '${tl_prefix}'=='T080'    10.64.21.89
    ...                                     '${tl_prefix}'=='T073'    172.250.164.132
    ${ue3_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.38
    ...                                     '${tl_prefix}'=='T080'    10.64.21.81
    ...                                     '${tl_prefix}'=='T073'    172.250.164.135
    ${ue4_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.58
    ...                                     '${tl_prefix}'=='T080'    10.64.21.109
    ...                                     '${tl_prefix}'=='T073'    172.250.164.138
    ${ue5_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.60
    ...                                     '${tl_prefix}'=='T080'    10.64.21.105
    ...                                     '${tl_prefix}'=='T073'    172.250.164.141
    ${ue6_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.48
    ...                                     '${tl_prefix}'=='T080'    10.64.21.101
    ...                                     '${tl_prefix}'=='T073'    172.250.164.144
    ${ue7_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.35
    ...                                     '${tl_prefix}'=='T080'    10.64.21.97
    ...                                     '${tl_prefix}'=='T073'    172.250.164.147
    ${ue8_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.63
    ...                                     '${tl_prefix}'=='T080'    10.64.21.93
    ...                                     '${tl_prefix}'=='T073'    172.250.164.150
    ${ue9_ip_address}    Set Variable if    '${tl_prefix}'=='T284'    172.250.164.30
    ...                                     '${tl_prefix}'=='T080'    10.64.21.85
    ...                                     '${tl_prefix}'=='T073'    172.250.164.153
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
    FOR    ${i}    IN RANGE    2    10
            ${dl_port}       Set Variable If    '${tl_prefix}'=='T284'       56${i}84
            ...                                 '${tl_prefix}'=='T080'       56${i}80
            ...                                 '${tl_prefix}'=='T073'       56${i}73
            ${ue_addr}       Set Variable       ${ue${i}_ip_address}
            ${command}    Catenate    iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P ${process_num} -f m -b
            ...    ${dl_throughput} -l ${dl_length} -T 64 &
            run keyword if    '${protocol}'=='udp'    csn.send command
			...    command=${command}
			...    connection=APPserver
			...    ELSE IF    '${protocol}'=='tcp'    Start the tcp DL data via iperf    ue_index=${ue_index}
			...    dl_time=${dl_time}    ue_addr=${ue_addr}    dl_port=${dl_port}    process_num=${process_num}
			...    seg_size=${seg_size}
			...    window=${window}
			sleep    1s
            Run Keyword And Continue On Failure   Check the iperf progress exist    connection=APPserver    port=${dl_port}
    END
    [Teardown]    csn.disconnect    connection=APPserver

Kill multiUE DL iperf port
    [Documentation]  xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${appserver}=APPserver
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
    FOR    ${i}    IN RANGE    2    10
         ${dl_port}     Set Variable    56${i}84
         csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9
         ...    connection=APPserver
    END
    [Teardown]    csn.disconnect    connection=APPserver

Report Result To Reporting Portal
    [Documentation]  xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${test_result}     ${qc_lab_path}    ${qc_id}    ${alias}=default
    log    ${alias}
    &{links}   Create Dictionary
    ute_reporting_portal.report_to_rp    ca=${ca}
    ...                build=${package_version_1525-CA}
    ...                links=${links}
    ...                tool=Robot
    ...                result=${test_result}
    ...                qc_test_set_name=${qc_set_name}
    ...                qc_testlab_path=${qc_lab_path}
    ...                qc_domain=${qc_domain}
    ...                qc_project=${qc_project}
    ...                qc_id=${qc_id}
    ...                testline=${testline}
    ...                name=${case_name}

CA.Trigger A6 Scell Swap
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               Modify the expected scell swap source and target PA,trigger the Specific scell swap
    [Arguments]    ${ue_index}=${0}
    ...            ${gnb_id}=${0}
    ...            ${rounds}=${1}
    ...            ${source_swap_pa_value}=25
    ...            ${target_swap_pa_value}=25
    ...            ${tcpdump_name}=active
    ${source_swap_scell}    Set Variable    ${case_params.get('swap_scell_index').get('source_scell')}
    ${target_swap_scell}    Set Variable    ${case_params.get('swap_scell_index').get('target_scell')}
    ${source_swap_scell}   Convert To Integer    ${source_swap_scell}
    ${target_swap_scell}    Convert To Integer    ${target_swap_scell}
    ${source_swap_scell_ru_index}    Set Variable    ${SCELL_MAPPING[${source_swap_scell}]['all_cell_info']['ru_index_mapping']}
    ${target_swap_scell_ru_index}    Set Variable    ${SCELL_MAPPING[${target_swap_scell}]['all_cell_info']['ru_index_mapping']}
    ${source_swap_scell_pci}    Set Variable    ${SCELL_MAPPING[${source_swap_scell}]['all_cell_info']['physicalCellId']}
    ${target_swap_scell_pci}    Set Variable    ${SCELL_MAPPING[${target_swap_scell}]['all_cell_info']['physicalCellId']}
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=${gnb_id}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    tcpdump_collector_name=ca_scell_swap_cell${source_swap_scell}_to_cell${target_swap_scell}_rounds${rounds}_${tcpdump_name}
    ...    asik_connection_alias=ASIK Master
    ...    gnb_index=${gnb_id}
    ...    du_index=0
    Sleep    10sec
    Modify PA Value Setting For Required RU    modify_ru_id=${target_swap_scell_ru_index}
    ...    ue_index=${ue_index}
    ...    pa_off_value=${target_swap_pa_value}
    FOR    ${round}    IN RANGE    ${rounds}
        log to console  start to trigger A6 swap for round-${round}
        Modify PA Value Setting For Required RU    modify_ru_id=${source_swap_scell_ru_index}
        ...    ue_index=${ue_index}
        ...    pa_off_value=${source_swap_pa_value}
        Sleep    9sec
        Modify PA Value Setting For Required RU    modify_ru_id=${source_swap_scell_ru_index}
        ...    ue_index=${ue_index}
        ...    pa_off_value=${None}
        Sleep    9sec
    END
    Modify PA Value Setting For Required RU    modify_ru_id=${target_swap_scell_ru_index}
    ...    ue_index=${ue_index}
    ...    pa_off_value=127
    Sleep    15sec
    ${ca_scell_swap_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=ca_scell_swap_cell${source_swap_scell}_to_cell${target_swap_scell}_rounds${rounds}_${tcpdump_name}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ${scell_condition_expression}    Catenate    (nr-rrc.sCellToAddModList == 1) && (f1ap.procedureCode == 12)
    ${scell_swap_mr_expression}    Catenate    (f1ap.procedureCode == 13) && (nr-rrc.measResultNeighCells == 0)
    pcap.setup    infile=${ca_scell_swap_wireshark}    display_filter=${scell_swap_mr_expression}    alias=test0
    pcap.get_packets    filter=${scell_swap_mr_expression}   pcap_parser=test0
    ${swap_scell_pci_list}    pcap.get_field_value    field_name=nr-rrc.physCellId
    ...    filter=${scell_swap_mr_expression}
    ...    pcap_parser=test0
    ${source_pci_exist}    Evaluate     [x for x in ${swap_scell_pci_list} if ${source_swap_scell_pci} not in x]
    ${target_pci_exist}    Evaluate     [x for x in ${swap_scell_pci_list} if ${target_swap_scell_pci} not in x]
    Run Keyword And Continue On Failure    Should Not Be Empty    ${source_pci_exist}
    ...    msg=source swap scell is not in A6 MR Measurement
    Run Keyword And Continue On Failure    Should Not Be Empty    ${target_pci_exist}
    ...    msg=target swap scell is not in A6 MR Measurement
    ${swap_scell_pci_list}    Evaluate    [x[-1] for x in ${swap_scell_pci_list}]
    ${source_pci_exist}     Evaluate    [x for x in ${swap_scell_pci_list} if int(x)==int(${source_swap_scell_pci})]
    ${target_pci_exist}     Evaluate    [x for x in ${swap_scell_pci_list} if int(x)==int(${target_swap_scell_pci})]
    ${len_swap_source}     Get Length    ${source_pci_exist}
    ${len_swap_target}     Get Length    ${target_pci_exist}
    Run Keyword And Continue On Failure    Should Be True    ${len_swap_source}>=${10}    msg=swap times is less than 10 rounds
    Run Keyword And Continue On Failure    Should Be True    ${len_swap_target}>=${10}    msg=swap times is less than 10 rounds
    pcap.setup    infile=${ca_scell_swap_wireshark}    display_filter=${scell_condition_expression}    alias=test0
    pcap.get_packets    filter=${scell_condition_expression}   pcap_parser=test0
    ${scell_addition_pci_list}    pcap.get_field_value    field_name=nr-rrc.physCellId
    ...    filter=${scell_condition_expression}
    ...    pcap_parser=test0
    ${scell_addition_pci_list}    Evaluate    [x[0] for x in ${scell_addition_pci_list}]
    ${source_pci_exist_addition}     Evaluate    [x for x in ${scell_addition_pci_list} if int(x)==int(${source_swap_scell_pci})]
    ${target_pci_exist_addition}     Evaluate    [x for x in ${scell_addition_pci_list} if int(x)==int(${target_swap_scell_pci})]
    ${len_swap_source_addition}     Get Length    ${source_pci_exist_addition}
    ${len_swap_target_addition}     Get Length    ${target_pci_exist_addition}
    Run Keyword And Ignore Error    Should Be True    ${len_swap_source_addition}>=${5}    msg=addition success is less than 10 rounds
    Run Keyword And Ignore Error    Should Be True    ${len_swap_target_addition}>=${5}    msg=addition success is less than 10 rounds
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master
    ...    AND    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master

Start Ping Traffic
    [Arguments]   ${ue_index}=${1}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log    ${serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell killall ping
    ${appserver_addr}    Set Variable   ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    csn.send_command    command=adb -s ${serial_number} shell ping ${appserver_addr} &    connection=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=cygwin
    ${output}    csn.read_output    size=1000    connection=cygwin
    ${ping_pid}    evaluate    ${output.strip()}
    should be true    ${ping_pid} > ${0}    msg=ping traffic is not success.
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin

Stop Ping Traffic
    [Arguments]   ${ue_index}=${1}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log    ${serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=cygwin
    ${output}    csn.read_output    size=1000    connection=cygwin
    ${ping_pid}    evaluate    ${output.strip()}
    should be true    ${ping_pid} > ${0}    msg=ping traffic is stopped unnormally.
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${ping_pid}    connection=cygwin
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${serial_number} shell killall ping    connection=cygwin    AND
    ...    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin

Clear Ping Traffic
    [Arguments]   ${ue_index}=${1}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log    ${serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell killall ping
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin

Start Ping Traffic For Spark
    [Arguments]   ${ue_ip}=10.64.21.89    ${ue_index}=4    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log    ${serial_number}
#    Connect to control pc via cygwin    ue_index=${ue_index}
    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
#    csn.send_command    command=ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=cygwin
    ${output}   csn.execute   command=ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=APPserver
    ${status}    ${ping_pid_before}    Run Keyword And Ignore Error    evaluate    ${output.strip()}
    Run Keyword And Ignore Error    csn.send_command    command=kill -9 ${ping_pid_before}    connection=APPserver
#    ${appserver_addr}    Set Variable   ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
#    csn.send_command    command=ping ${appserver_addr} -S ${ue_ip} -t &    connection=cygwin
    csn.send_command    command=ping ${ue_ip} &    connection=APPserver
#    sleep   5s
#    ${output}   csn.execute   command=ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=APPserver
#    ${ping_pid}    evaluate    ${output.strip()}
#    should be true    ${ping_pid} > ${0}    msg=ping traffic is not success.
#    sleep   5s
#    ${output}   csn.execute   command=ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=APPserver
#    ${ping_pid}    evaluate    ${output.strip()}
#    should be true    ${ping_pid} > ${0}    msg=ping traffic is not success.
#    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=APPserver

Stop Ping Traffic For Spark
    [Arguments]   ${ue_index}=${4}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log    ${serial_number}
#    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ${output}   csn.execute   command=ps -ef |grep ping |grep -v grep |awk '{print $2}'    connection=APPserver
    ${ping_pid}    evaluate    ${output.strip()}
    should be true    ${ping_pid} > ${0}    msg=ping traffic is stopped unnormally.
    csn.send_command    command=kill -9 ${ping_pid}    connection=APPserver
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=APPserver

PA Value Setting For Required RU Required gNB
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${gnb_id}=0    ${pa_value}=${63}
    ${modify_ru_id_type}    Evaluate    type(${modify_ru_id}).__name__
    ${convert_modify_ru_id_to_list}    Create List    ${modify_ru_id}
    ${modify_ru_id_list}    Set Variable If    'list' in '${modify_ru_id_type}' or 'tuple' in '${modify_ru_id_type}'
    ...      ${modify_ru_id}    ${convert_modify_ru_id_to_list}
    FOR    ${ru_index}    IN    @{modify_ru_id_list}
        ${attenuation_ports}    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${ru_index}].attenuation_ports}
        Run Keyword If    '${attenuation_ports}'!='None'    Wait Until Keyword Succeeds    5X    5sec
        ...    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU
        ...    value=${pa_value}   RU_id=${ru_index}    gnb_id=${gnb_id}
    END

Update Params Through RestApi
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...               param:${params_need_to_modify}, List
    [Arguments]    ${params_need_to_modify}    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}   ${timeout}=300
    ...    ${skip_parameter_relation_errors}=False
    ...    ${is_verify_onair}=${True}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl    bts_host=${bts_host}    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_need_to_modify}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Run Keyword If    ${is_verify_onair}    Check TMO Gnb Ready And All Cell On Air    gnb_id=${gnb_index}
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Delete Params Through RestApi
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...               param:${params_need_to_modify}, List
    [Arguments]    ${parameters_to_delete_via_api}    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}    ${timeout}=300
    ...    ${is_verify_onair}=${True}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM delete parameters via rest api    parameters_to_delete_via_api=${parameters_to_delete_via_api}
    ...                                 timeout=${timeout}
    ...                                 connection=${connection}
    Run Keyword If    ${is_verify_onair}     Check TMO Gnb Ready And All Cell On Air    gnb_id=${gnb_index}
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Add Params Through RestApi
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...               param:${params_need_to_modify}, List
    [Arguments]    ${parameters_to_add_via_api}    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}   ${timeout}=300
    ...    ${is_verify_onair}=${True}
    log    ${timeout}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM add several parameters via rest api       parameters_to_add_via_api=${parameters_to_add_via_api}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    Run Keyword If    ${is_verify_onair}     Check TMO Gnb Ready And All Cell On Air    gnb_id=${gnb_index}
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


Perform gNB Reset site and Wait Onair
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}     ${timeout}=30min
    log    ${timeout}
    Connect to gnb coam via ssl    connection=${connection}   gnb_index=${gnb_index}
    coam.reset_site         connection=${connection}    timeout=${900}
    sleep    30s
    Check TMO Gnb Ready And All Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get_Lte_And_Nr_First_Port_Number
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}     ${timeout}=30min    ${rmod_index}=7
    log    ${timeout}
    Connect to gnb coam via ssl    connection=${connection}   gnb_index=${gnb_index}
    ${result}    coam.get_detected_hw_info         connection=${connection}    timeout=${900}
    ${all_cables_info}    Set Variable    ${result['cables']}
    ${lte_first_port_number}    ${nr_first_port_number}    get_first_port_number_for_lte_and_nr
    ...    cables_info_list=${all_cables_info}
    ...    rmod_index=${rmod_index}
    [Return]    ${lte_first_port_number}    ${nr_first_port_number}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Perform eNB Reset site and Wait Onair
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}     ${timeout}=30min
    log    ${timeout}
    log    ${connection}
    Connect to eNB via ssl
    coam.reset_site         connection=enblte    timeout=${900}
    sleep    30s
    Verify All Enbs Cell On Air
    [Teardown]    Run Keyword And Ignore Error    Enblte close down

Get_RU_Update_Time
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}   ${download_dir}=${TS_CASE_LOG_PATH}
    ${ru_index}  Convert To Integer    ${ru_index}
    Wait Until Keyword Succeeds    3x    5s    COAM Navigate to login page via webUI   download_dir=${download_dir}    timeout=${120}
    ${ru_info}    selenium_coam.get_ru_info    ru_index=${ru_index}
    ${ru_uptime}    Set Variable    ${ru_info['Uptime']}
    ${day}    Set Variable        ${ru_uptime.split('d')[0]}
    ${hour}    Set Variable        ${ru_uptime.split('h')[0].split('d')[1].strip(" ")}
    ${mins}    Set Variable        ${ru_uptime.split('m')[0].split('h')[1].strip(" ")}
    ${sec}    Set Variable        ${ru_uptime.split('s')[0].split('m')[1].strip(" ")}
    ${up_secs}    Evaluate      ${day}*24*60*60+${hour}*60*60+${mins}*60+${sec}
    [Return]    ${up_secs}
    [Teardown]  COAM selenium logout


HO.Check A5A3 Measurement Report
    [Arguments]    ${cpif_log_path}   ${exp_source_pci}=771    ${exp_target_pci}=772   ${rounds}=${3}
    ${filter_expression}    Catenate    nr-rrc.measResultNeighCells == 0
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${actual_pci}    pcap.get_field_value    field_name=nr-rrc.physCellId
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
#    ${ho_rounds}    Get Length    ${actual_pci}
#    Run Keyword And Continue On Failure     Should Be Equal As Integers    ${ho_rounds}    ${rounds}
#    ...   msg=handover success rounds is only ${ho_rounds}times triggered success, totally is ${rounds}times.
    ${pci_valid_filter}    Catenate    int(x[0])==int(${exp_source_pci}) and int(x[1])==int(${exp_target_pci})
    ${valid_mr_pci}    Evaluate    [x for x in ${actual_pci} if ${pci_valid_filter}]
    ${mr_vaild}    Get Length    ${valid_mr_pci}
    Run Keyword And Continue On Failure     Should Be True    ${mr_vaild}>=${rounds}
    ...   msg=A3/A5 MR is not triggered properly,actual is triggered ${mr_vaild} times.

HO.Check RRC Reconfigure And RRC Reconfigure Complete For Inter-gnb
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${source_cpif_log_path}    ${target_cpif_log_path}    ${rounds}=${3}
#    ${filter_expression}    Catenate    ((f1ap.procedureCode == 12 )&& (nr-rrc.ssbFrequency == ${ssbfrequency})) && (nr-rrc.gapUE == 0)
    ${filter_expression}    Catenate    ((nr-rrc.reportConfigId ) && (f1ap.procedureCode == 7) && nr-rrc) && !(f1ap.C_RNTI)
    pcap.setup    infile=${source_cpif_log_path}     display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${rrc_transaction_identifier}    pcap.get_field_value    field_name=nr-rrc.rrc_TransactionIdentifier
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
#    ${rrc_reconfigure_rounds}    Get Length    ${rrc_transaction_identifier}
#    Run Keyword And Continue On Failure     Should Be Equal As Integers    ${rrc_reconfigure_rounds}    ${rounds}
#    ...   msg=RRC Reconfigure success only ${rrc_reconfigure_rounds}times,totally is ${rounds}times.
    ${rrc_reconfiguration_complete_success_time}    Set Variable    ${0}
    FOR   ${message}    IN    @{rrc_transaction_identifier}
        ${complete_filter_expression}    Catenate    nr-rrc.rrcReconfigurationComplete_element &&
        ...                                          nr-rrc.rrc_TransactionIdentifier==${message[0]}
        pcap.setup    infile=${target_cpif_log_path}    display_filter=${complete_filter_expression}    alias=test1
        pcap.get_packets    filter=${complete_filter_expression}   pcap_parser=test1
        ${rrc_transaction_identifier_complete}    pcap.get_field_value    field_name=nr-rrc.rrc_TransactionIdentifier
        ...    filter=${complete_filter_expression}
        ...    pcap_parser=test1
        ${status}    Run Keyword And Return Status    Should Not Be Empty    ${rrc_transaction_identifier_complete}
        ...    msg=RRC Reconfiguration Complete message not triggered success.
        ${rrc_reconfiguration_complete_success_time}    Run Keyword If    '${status}'=='${True}'    Evaluate
        ...    ${rrc_reconfiguration_complete_success_time}+1
    END
    Run Keyword And Continue On Failure    Should Be True    ${rrc_reconfiguration_complete_success_time}>=${rounds}
    ...   msg=RRC Reconfigure success only ${rrc_reconfiguration_complete_success_time}times,should be ${rounds}times.

HO.Check RRC Reestablishment
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${cpif_log_path}
    ${filter_expression}    Catenate    nr-rrc.rrcReestablishmentRequest_element
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    ${status}    Run Keyword And Return Status    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${pci}    Run Keyword If    '${status}'=='${True}'     pcap.get_field_value    field_name=nr-rrc.physCellId
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    Run Keyword If    '${status}'=='${True}'    Fail    msg=cell with pci ${pci} have RRC Reestablishment happend.

Disable 9531 Function
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${disable_cells_list}=${${301},${311}}    ${connection}=GNB_OAM    ${gnb_index}=0
    ${disable_cells_list_type}    Evaluate    type(${disable_cells_list}).__name__
    ${convert_disable_cells_to_list}    Create List    ${disable_cells_list}
    ${disable_cells_list}    Set Variable If    'list' in '${disable_cells_list_type}' or 'tuple' in '${disable_cells_list_type}'
    ...      ${disable_cells_list}     ${convert_disable_cells_to_list}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${update_params}    Create List
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    FOR    ${cell_index}    IN    @{disable_cells_list}
        ${actDrxRetransTimerSupport}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'actDrxRetransTimerSupport','value':'false'}
##        ${drxProfile2}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
##        ...    'parameter':'drxProfile2',
##        ...    'value':[{'drxHarqRttTimerDl':'0slot','drxHarqRttTimerUl':'0slot',
##        ...    'drxHarqRttTimerDl':'0symbols','drxHarqRttTimerUl':'0symbols'}]}
#        ${nonGbrNrDrxDN_mo}    get_single_value_from_scf_file    parameter=nonGbrNrDrxDN
#        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
#        ...    connection=${connection}    timeout=60
#        ${voNRNrDrxDN_mo}    get_single_value_from_scf_file    parameter=voNRNrDrxDN
#        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
#        ...    connection=${connection}    timeout=60
#        ${fiveQiDrbDrx_mo}    get_single_value_from_scf_file    parameter=nrDrxDN    list_name=fiveQiDrbDrxList
#        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
#        ...    connection=${connection}    timeout=60
#        ${nonGbrNrDrxDN}   catenate   {'dist_name':'${nonGbrNrDrxDN_mo}','parameter':'drxHarqRttTimerDl','value':'0symbols'},
#        ...                            {'dist_name':'${nonGbrNrDrxDN_mo}','parameter':'drxHarqRttTimerUl','value':'0symbols'},
#        ...                            {'dist_name':'${nonGbrNrDrxDN_mo}','parameter':'drxRetransTimerDl','value':'0slot'},
#        ...                            {'dist_name':'${nonGbrNrDrxDN_mo}','parameter':'drxRetransTimerUl','value':'0slot'}
#        ${voNRNrDrxDN}    Run Keyword If    '${voNRNrDrxDN_mo}'!='${None}'
#        ...    catenate   {'dist_name':'${voNRNrDrxDN_mo}','parameter':'drxHarqRttTimerDl','value':'0symbols'},
#        ...                            {'dist_name':'${voNRNrDrxDN_mo}','parameter':'drxHarqRttTimerUl','value':'0symbols'},
#        ...                            {'dist_name':'${voNRNrDrxDN_mo}','parameter':'drxRetransTimerDl','value':'0slot'},
#        ...                            {'dist_name':'${voNRNrDrxDN_mo}','parameter':'drxRetransTimerUl','value':'0slot'}
#        ${fiveQiDrbDrx}    Run Keyword If    '${fiveQiDrbDrx_mo}'!='${None}'
#        ...    catenate   {'dist_name':'${fiveQiDrbDrx_mo}','parameter':'drxHarqRttTimerDl','value':'0symbols'},
#        ...                            {'dist_name':'${fiveQiDrbDrx_mo}','parameter':'drxHarqRttTimerUl','value':'0symbols'},
#        ...                            {'dist_name':'${fiveQiDrbDrx_mo}','parameter':'drxRetransTimerDl','value':'0slot'},
#        ...                            {'dist_name':'${fiveQiDrbDrx_mo}','parameter':'drxRetransTimerUl','value':'0slot'}
##        ${update_param}    Evaluate    [${actDrxRetransTimerSupport},${drxProfile2},${nonGbrNrDrxDN},${voNRNrDrxDN},${fiveQiDrbDrx}]
#        ${update_param}    Run Keyword If    '${voNRNrDrxDN_mo}'=='${None}'
#        ...    Evaluate    [${actDrxRetransTimerSupport},${nonGbrNrDrxDN},${fiveQiDrbDrx}]
#        ...    ELSE IF    '${fiveQiDrbDrx_mo}'=='${None}'
#        ...    Evaluate    [${actDrxRetransTimerSupport},${nonGbrNrDrxDN},${voNRNrDrxDN}]
#        ...    ELSE
#        ...    Evaluate    [${actDrxRetransTimerSupport},${nonGbrNrDrxDN},${voNRNrDrxDN},${fiveQiDrbDrx}]
        ${update_param}   Evaluate    [${actDrxRetransTimerSupport}]
        ${update_params}    Combine Lists   ${update_params}    ${update_param}
    END
    ${NRDRX_LIST}     coam.get_managed_objects    class_name=NRDRX_A    connection=${connection}    timeout=60
    ${NRDRX_INDEX_LIST}    Evaluate    [x['distName'].split('/')[-1].split('-')[-1] for x in ${NRDRX_LIST}]
    log    ${NRDRX_INDEX_LIST}
    FOR    ${index}   IN    @{NRDRX_INDEX_LIST}
        ${dist_object}   catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRX-${index}',
        ...    'parameter':'drxHarqRttTimerDl','value':'0symbols'},
        ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRX-${index}','parameter':'drxRetransTimerDl','value':'0slot'},
        ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRX-${index}','parameter':'drxHarqRttTimerUl','value':'0symbols'},
        ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRX-${index}','parameter':'drxRetransTimerUl','value':'0slot'}
        ${dist_object_list}     Evaluate     [${dist_object}]
        ${update_params}    Combine Lists   ${update_params}    ${dist_object_list}
    END
    Update Params Through RestApi    params_need_to_modify=${update_params}    connection=${connection}    gnb_index=${gnb_index}

Disable 9531 Function For 24R2
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${disable_cells_list}=${${301},${311}}    ${connection}=GNB_OAM    ${gnb_index}=0
    ${disable_cells_list_type}    Evaluate    type(${disable_cells_list}).__name__
    ${convert_disable_cells_to_list}    Create List    ${disable_cells_list}
    ${disable_cells_list}    Set Variable If    'list' in '${disable_cells_list_type}' or 'tuple' in '${disable_cells_list_type}'
    ...      ${disable_cells_list}     ${convert_disable_cells_to_list}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${update_params}    Create List
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    FOR    ${cell_index}    IN    @{disable_cells_list}
        ${actDrxRetransTimerSupport}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'actDrxRetransTimerSupport','value':'false'}
       ${drxProfile1}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'drxProfile1',
        ...    'value':[{'drxHarqRttTimerDl':'0symbols','drxHarqRttTimerUl':'14symbols',
        ...    'drxRetransTimerDl':'0slot','drxRetransTimerUl':'16slot'}]}
        ${drxProfile2}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'drxProfile2',
        ...    'value':[{'drxHarqRttTimerDl':'0symbols','drxHarqRttTimerUl':'0symbols',
        ...    'drxRetransTimerDl':'0slot','drxRetransTimerUl':'0slot'}]}
        ${update_param}    Evaluate    [${actDrxRetransTimerSupport},${drxProfile1},${drxProfile2}]
        ${update_params}    Combine Lists   ${update_params}    ${update_param}
    END
    Update Params Through RestApi    params_need_to_modify=${update_params}    connection=${connection}    gnb_index=${gnb_index}

Enable RedCap Function
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${actRedCapUeSupport}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-311',
        ...    'parameter':'actRedCapUeSupport','value':'true'}
    ${maxNumOfRrcSARedCap}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-311',
        ...    'parameter':'maxNumOfRrcSARedCap','value':'200'}
    ${cellBarredRedCap}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-311',
    ...    'parameter':'cellBarredRedCap','value':'no barring'}
    ${update_param}    Evaluate    [${actRedCapUeSupport},${maxNumOfRrcSARedCap},${cellBarredRedCap}]
    Update Params Through RestApi    params_need_to_modify=${update_param}    connection=${connection}    gnb_index=${gnb_index}

#Modify weightForSCellSelection
#    [Documentation]    Auther:Stella.lin@nokia-sbell.com
#    [Arguments]    ${disable_cells_list}=${${1},${2},${3},${21},${22},${23}}
#    ...    ${value}=100    ${connection}=GNB_OAM    ${gnb_index}=0
#    ${disable_cells_list_type}    Evaluate    type(${disable_cells_list}).__name__
#    ${convert_disable_cells_to_list}    Create List    ${disable_cells_list}
#    ${disable_cells_list}    Set Variable If    'list' in '${disable_cells_list_type}' or 'tuple' in '${disable_cells_list_type}'
#    ...      ${disable_cells_list}     ${convert_disable_cells_to_list}
#    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
#    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
#    ${update_params}    Create List
#    FOR    ${cell_index}    IN    @{disable_cells_list}
#        ${weightForSCellSelection}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
#        ...    'parameter':'weightForSCellSelection','value':'${value}'}
#        ${update_param}    Evaluate    [${weightForSCellSelection}]
#        ${update_params}    Combine Lists   ${update_params}    ${update_param}
#    END
#    Update Params Through RestApi    params_need_to_modify=${update_params}    connection=${connection}    gnb_index=${gnb_index}

Configure Relation Cells
    [Documentation]   Author: stella.lin@nokia-sbell.com
    [Arguments]    ${source_gnb_id}=0
    Connect To Multi gNb Coam
    mbca.set_pcell_index    value=${PCELL_INDEX}
    mbca.set_gnb_id    value=${source_gnb_id}
    mbca.set_gnb_operation_object
    ${inter_gnb_ho_cell}    Set Variable    ${case_params.get('inter_gnb_ho_cell')}
    ${intra_gnb_ho_cell}    Set Variable    ${case_params.get('intra_gnb_ho_cell')}
    ${scell_indexs}    Set Variable    ${case_params.get('scell_idx_list')}
    ${swap_scell_index}    Set Variable    ${case_params.get('swap_scell_index')}
    ${swap_scell_index}    Set Variable If    ${swap_scell_index}==${None}    ${swap_scell_index}
    ...                                       ${swap_scell_index['target_scell']}
    ${res}    Catenate    {'inter_gnb_ho_cell':${inter_gnb_ho_cell}},{'intra_gnb_ho_cell':${intra_gnb_ho_cell}},
    ...                   {'scell_indexs':${scell_indexs}},{'swap_scell_index':${swap_scell_index}}
    ${relation_cells_info}    Evaluate    [${res}]
    ${source_cell_mapping}    ${target_cell_mapping}   ${scell_mapping}    config_relation_cells
    ...    relation_cells_info=${relation_cells_info}
    Set Test Variable    ${SOURCE_CELL_MAPPING}    ${source_cell_mapping}
    Set Test Variable    ${TARGET_CELL_MAPPING}    ${target_cell_mapping}
    Set Test Variable    ${PCELL_MAPPING}    ${source_cell_mapping[${PCELL_INDEX}]}
    Set Test Variable    ${SCELL_MAPPING}    ${scell_mapping}
    LOG    ${SCELL_MAPPING}
    [Teardown]    Teardown Multi gNb Connections

Update actSCellReleaseForInactiveSCell in gnb
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    ...                This keyword just for 5G cell.
    [Arguments]    ${vaule}=timer_based_Fr1    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}
    ${param}    Create Dictionary    dist_name=${dist_name}    parameter=actSCellReleaseForInactiveSCell    value=${vaule}
    @{param_list}    Create List    ${param}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}
    ...                                            timeout=${timeout}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

MultiUE Attach without check TP in UE
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    [Arguments]       ${logpath}    ${logname}       ${ue_index}=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...            ${start_keep_on_duration}=20    ${buffer_size}=1350B
    ...            ${appserver}=APPserver     ${protocol}=udp    ${low_RSRP}=False   ${peak_TP}=True
    ...            ${DL_200M_8311}=DL_200M_8311      ${DL_10M_8311}=DL_10M_8311
    ...            ${process_num}=${2}    ${seg_size}=${1372}    ${window}=2M      ${ul_process_num}=${1}    ${save_ue_log}=True
    log    ${low_RSRP}
    log    ${peak_TP}
    log    ${ul_process_num}
   Run Keyword And Ignore Error    run keyword if    '${save_ue_log}'=='True'    Spark_common_keywords.Spark Start multi UE Log
    ...           logpath=${logpath}    logname=${logname}
    log to console      "UE Attach"
    power_ue.UE Attach     ue_type=sigspark_multiUE
    ${DL_200M}    Set Variable     ${KPI_PA['${tl_prefix}']['${DL_200M_8311}']}
    ${DL_10M}    Set Variable     ${KPI_PA['${tl_prefix}']['${DL_10M_8311}']}
    Kill multiUE DL iperf port
    Start mutltiUE DL with static IP     dl_time=${start_keep_on_duration}
    ...                                  dl_throughput=${DL_200M}
    ...                                  dl_length=${buffer_size}
    ...                                  appserver=${appserver}
    ...                                  protocol=${protocol}
    ...                                  ue_index=${ue_index}
    ...                                  process_num=${process_num}
    ...                                  seg_size=${seg_size}
    ...                                  window=${window}
    sleep    10s
    power_ue.UE Detach        ue_type=sigspark_multiUE
    Run Keyword And Ignore Error      Spark_common_keywords.Spark Stop multi UE Log

Save Current SCF And Save Snapshot
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Run Keyword And Ignore Error    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=${connection}
    Run Keyword And Ignore Error    COAM Save snapshot via rest api    connection=${connection}    timeout=900
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update lssIPaddress Via RestAPI
    [Arguments]    ${value}=10.57.177.22    ${mrbts_index}=11213
    ${lssIPaddress}    catenate   {'dist_name':'MRBTS-${mrbts_index}=/MNL-1/MNLENT-1/TRBLCADM-1',
    ...    'parameter':'lssConfig','value':[{'lssIPaddress':'${value}'}]}
    ${update_param}    Evaluate    [${lssIPaddress}]
    Connect to eNB via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${update_param}
    ...                                            timeout=${120}
    ...                                            connection=enblte
    ...                                            skip_parameter_relation_errors=${False}
    [Teardown]    Enblte close down

UE With ADB Reboot
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.execute    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot   connection=cpc_${ue_index}
    Sleep    10s
    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}
    ...                                                                   serial_number=${tl.ues[${ue_index}].serial_number}
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}

Delete NRREL Objects Based On Technology
    [Arguments]    ${pcell_index}=${PCELL_INDEX}    ${gnb_index}=${0}    ${connection}=GNB_OAM${gnb_index}   ${technology}=FDD
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    Get Pcell And Scell Mapping Info    pcell_index=${pcell_index}    source_gnb_id=${gnb_index}
    ${filter_scell_mapping}    Set Variable If    '${technology}'=='FDD'     ${FDD_SCELL_MAPPING}
    ...         '${technology}'=='TDD'     ${TDD_SCELL_MAPPING}
    ${dict_values}    Get Dictionary Values    ${filter_scell_mapping}
    ${NRREL_indexs}     Evaluate     [x['nrrel_id'] for x in ${dict_values}]
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${empty_list}    Create List
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    FOR    ${nrrel_index}     IN     @{NRREL_indexs}
        ${dist_name}     Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}/NRREL-${nrrel_index}
        coam.perform_object_recommissioning    dist_name=${dist_name}    parameter=${empty_list}    operation=delete
        ...     skip_parameter_relation_errors=False    should_activate=True    timeout=240    connection=${connection}
    END
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Create LNADJGNB On ENB Side
    [Arguments]   ${dist_name}=MRBTS-284284/LNBTS-284284/LNADJGNB-80
    ...           ${adjGnbId}=80
    ...           ${adjGnbIdLength}=24
    ...           ${administrativeState}=unlocked
    ...           ${cPlaneIpAddr}=10.0.183.18
    ...           ${cPlaneIpAddrCtrl}=oamControlled
    ...           ${mcc}=460
    ...           ${mnc}=2
    ...           ${mncLength}=2
    ...           ${enb_index}=0
    ...           ${connection}=enblte_${enb_index}
    ${use_for_enb_index}     Set Variable If    '${enb_index}'=='0'    17
    ...                                         '${enb_index}'=='1'    18
    enblte.connect_to    bts_host=${tl.ues[${use_for_enb_index}].ssh_connection_details.addr}
    ...    bts_port=443  use_ssl=True    name=${connection}
    Run Keyword And Ignore Error    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=${connection}
    ${status}    ${enb_version}     Run Keyword And Ignore Error    coam.get_sw_version    connection=${connection}
    ${adjGnbId_dict}    Create Dictionary    dist_name=${dist_name}    parameter=adjGnbId    value=${adjGnbId}
    ${adjGnbIdLength_dict}    Create Dictionary    dist_name=${dist_name}    parameter=adjGnbIdLength    value=${adjGnbIdLength}
    ${administrativeState_dict}    Create Dictionary    dist_name=${dist_name}    parameter=administrativeState
    ...    value=${administrativeState}
    ${cPlaneIpAddr_dict}    Create Dictionary    dist_name=${dist_name}    parameter=cPlaneIpAddr    value=${cPlaneIpAddr}
    ${cPlaneIpAddrCtrl_dict}    Create Dictionary    dist_name=${dist_name}    parameter=cPlaneIpAddrCtrl    value=${cPlaneIpAddrCtrl}
    ${plmn_context}    Create Dictionary    mcc=${mcc}    mnc=${mnc}    mncLength=${mncLength}
    ${plmn_context}    Create List     ${plmn_context}
    ${plmnId_dict}    Create Dictionary    dist_name=${dist_name}    parameter=plmnId    value=${plmn_context}
    ${object_list}   Create List   ${adjGnbId_dict}   ${adjGnbIdLength_dict}   ${administrativeState_dict}   ${cPlaneIpAddr_dict}
    ...   ${plmnId_dict}    ${cPlaneIpAddrCtrl_dict}
    ${output}    coam_parameter.create_objects_delta    parameters=${object_list}     connection=${connection}
    perform_scf_delta_commission    delta_file=${output["updated"]}
    ...                             skip_parameter_relation_errors=False
    ...                             timeout=240
    ...                             connection=${connection}
    [Teardown]    Enblte close down    connection=${connection}


Delete LNADJGNB On ENB Side
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]   ${dist_name}=MRBTS-284284/LNBTS-284284/LNADJGNB-80
    ...           ${enb_index}=0
    ...           ${connection}=enblte_${enb_index}
    ${use_for_enb_index}     Set Variable If    '${enb_index}'=='0'    17
    ...                                         '${enb_index}'=='1'    18
    enblte.connect_to    bts_host=${tl.ues[${use_for_enb_index}].ssh_connection_details.addr}
    ...    bts_port=443  use_ssl=True    name=${connection}
    ${empty_list}    Create List
    coam.perform_object_recommissioning    dist_name=${dist_name}    parameter=${empty_list}    operation=delete
    ...     skip_parameter_relation_errors=False    should_activate=True    timeout=240    connection=${connection}
    [Teardown]    Enblte close down    connection=${connection}

Lock And Unlock LNADJGNB ON ENB
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]     ${status}=unlocked
    ...             ${dist_name}=MRBTS-11213/LNBTS-11213/LNADJGNB-127
    ...             ${enb_index}=0
    ...             ${connection}=enblte_${enb_index}
    ${use_for_enb_index}     Set Variable If    '${enb_index}'=='0'    17
    ...                                         '${enb_index}'=='1'    18
    enblte.connect_to    bts_host=${tl.ues[${use_for_enb_index}].ssh_connection_details.addr}
    ...    bts_port=443  use_ssl=True    name=${connection}
    enblte.perform_parameter_recommissioning       dist_name=${dist_name}
    ...                                            parameter=administrativeState
    ...                                            operation=update
    ...                                            value=${status}
    ...                                            connection=${connection}
    [Teardown]    Enblte close down    connection=${connection}


Check LTEENB Status On Gnb Side
    [Arguments]   ${eNodeBId}=284284
    ...           ${gnb_index}=0
    ...           ${connection}=GNB_OAM${gnb_index}
    ...           ${timeout}=600
    ...           ${status}=available
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Log to console    Check X2 link status from GNB
    @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LTEENB_A    connection=${connection}    timeout=${timeout}
    @{MOs_lteenb_r}    coam.get_managed_objects    class_name=LTEENB_R    connection=${connection}    timeout=${timeout}
    ${target_lteenb_a}     Evaluate    [x for x in ${MOs_lteenb_a} if x['parameters']['eNodeBId']==${eNodeBId}]
    ${target_lteenb_r}     Evaluate    [x for x in ${MOs_lteenb_r} if x['parameters']['eNodeBId']==${eNodeBId}]
#    Run Keyword And Continue On Failure    should be equal as strings    ${target_lteenb_a[0]['parameters']['x2LinkLock']}    unlocked
#    ...    msg=x2LinkLock is not in unlocked status in gnb side    ignore_case=${True}
    should be equal as strings    ${target_lteenb_r[0]['parameters']['x2LinkStatus']}    ${status}
    ...    msg=x2LinkStatus is not in ${status} status in gnb side    ignore_case=${True}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check LNADJGNB Status On Gnb Side
    [Arguments]   ${adjGnbId}=80
    ...           ${gnb_index}=0
    ...           ${connection}=GNB_OAM${gnb_index}
    ...           ${timeout}=600
    ...           ${status}=available
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Log to console    Check X2 link status from GNB
    @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LNADJGNB_A    connection=${connection}    timeout=${timeout}
    @{MOs_lteenb_r}    coam.get_managed_objects    class_name=LNADJGNB_R    connection=${connection}    timeout=${timeout}
    ${target_lteenb_a}     Evaluate    [x for x in ${MOs_lteenb_a} if x['parameters']['adjGnbId']==${adjGnbId}]
#    ${target_lteenb_r}     Evaluate    [x for x in ${MOs_lteenb_r} if x['parameters']['eNodeBId']==${eNodeBId}]
#    Run Keyword And Continue On Failure    should be equal as strings    ${target_lteenb_a[0]['parameters']['x2LinkLock']}    unlocked
#    ...    msg=x2LinkLock is not in unlocked status in gnb side    ignore_case=${True}
    should be equal as strings    ${target_lteenb_a[0]['parameters']['x2ToGnbLinkStatus']}    ${status}
    ...    msg=x2LinkStatus is not in ${status} status in gnb side    ignore_case=${True}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check all x2link Status On Gnb Side
    [Arguments]   ${gnb_index}=0
    ...           ${connection}=GNB_OAM${gnb_index}
    ...           ${timeout}=600
    ...           ${status}=available
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Log to console    Check X2 link status from GNB
    @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LTEENB_A    connection=${connection}    timeout=${timeout}
    @{MOs_lteenb_r}    coam.get_managed_objects    class_name=LTEENB_R    connection=${connection}    timeout=${timeout}
    ${target_lteenb_r}     Evaluate    [x for x in ${MOs_lteenb_r} if x['parameters']['x2LinkStatus']=='${status}']
    ${eNodeBId_list}    Evaluate    [x['parameters']['eNodeBId'] for x in ${target_lteenb_r}]
    [Return]    ${eNodeBId_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check x2link Status On Enb Side
    [Arguments]   ${adjGnbId}=80
    ...           ${enb_index}=0
    ...           ${connection}=enblte_${enb_index}
    ...           ${timeout}=600
    ...           ${status}=available
    ${use_for_enb_index}     Set Variable If    '${enb_index}'=='0'    17
    ...                                         '${enb_index}'=='1'    18
    enblte.connect_to    bts_host=${tl.ues[${use_for_enb_index}].ssh_connection_details.addr}
    ...    bts_port=443  use_ssl=True    name=${connection}
    Log to console    Check X2 link status from ENB
    @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LNADJGNB_A    connection=${connection}    timeout=${timeout}
    ${target_lteenb_a}     Evaluate    [x for x in ${MOs_lteenb_a} if x['parameters']['adjGnbId']==${adjGnbId}]
#    Run Keyword And Continue On Failure    should be equal as strings
#    ...    ${target_lteenb_a[0]['parameters']['administrativeState']}    unlocked
#    ...    msg=x2LinkLock is not in unlocked status in enb side    ignore_case=${True}
    Run Keyword And Continue On Failure    should be equal as strings
    ...    ${target_lteenb_a[0]['parameters']['x2ToGnbLinkStatus']}    ${status}
    ...    msg=x2LinkStatus is not in ${status} status in enb side    ignore_case=${True}
    [Teardown]    Enblte close down    connection=${connection}

Modify Parameter maxNumX2Links
    [Arguments]     ${value}=256    ${gnb_index}=0    ${connection}=GNB_OAM${gnb_index}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${param}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
        ...    'parameter':'maxNumX2Links','value':'${value}'}
    ${update_params}    Evaluate    [${param}]
    Update Params Through RestApi    params_need_to_modify=${update_params}    gnb_index=${gnb_index}   connection=${connection}
    ...    skip_parameter_relation_errors=${True}

Get Enb Upgrade Flag For Target SW Version
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${sw_version}
	${version_splitted}    Split String    ${sw_version}    _
	${tmp_program_version}    Replace String Using Regexp    string=${version_splitted[0]}    pattern=SBTS|5G    replace_with=${EMPTY}
	${is_trunk}    Run Keyword And Return Status    Should Contain Any    ${sw_version}    _9999_    _9990_
	${branch}    Set Variable If    ${is_trunk}    master    ${tmp_program_version}
    ${branch_num}    Run Keyword If    '${branch}'!='master'    Set Variable    ${branch.split("R")[0]}
    ${upgrade_flag}    Set Variable If    '${branch}'=='master'    true
    ...                                   '${branch}'!='master' and '${branch_num}'=='25'    true
    ...                                   '${branch}'!='master' and '${branch_num}'=='24'    false
    [Return]    ${upgrade_flag}
