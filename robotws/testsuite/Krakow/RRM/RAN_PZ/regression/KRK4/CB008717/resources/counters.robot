*** Settings ***
Documentation
...    Copied from testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/counters.robot
...    author/email  : Jian.1.Chen / jian.1.chen@nokia-sbell.com

Library    taf.transport.ssh    WITH NAME    csn
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    ./csvanalyzer.py
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
Connect To BTS Csn Via Lmp
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    csn.Connect to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${alias}

Connect to gnb coam via ssl
    [Arguments]  ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}
    Log to console    INFO:Connect to gnb coam via ssl successfully

Verify CB008717 KF Counters Update Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/19 11:21
    ...    M55116C00029: NRDC_IA_MN_CU_REL_REQ
    ...    M55116C00030: NRDC_FLOW_MN_INIT_TKBCK
    ...    M55116C00035: NRDC_FLOW_MN_INIT_TKBC_A
    [Arguments]    ${29_except_counter_value}    ${timeout}=300    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    Sleep    60s
    ${counter_ids}    Set Variable    M55116C00029,M55116C00030,M55116C00035
    ${counter_name_value_dict}    Create Dictionary
    ${counters}    Run Keyword And Ignore Error
    ...    coam.get_pm_counters    counter_ids=${counter_ids}    timeout=${timeout}    connection=${connection}
#    ${29_status}    Run Keyword And Return Status    Verify Recent Counter Value
    Verify Recent Counter Value
    ...    counter_id=${counters[1]['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-30']['NNSAUE']['M55116C00029']}
    ...    except_counter_value=${29_except_counter_value}    should_equal=True    start_time=${COUNTER_START_TIME}
#    Run Keyword If    '${29_status}'=='False'
#    ...    Set To Dictionary    ${counter_name_value_dict}    NRDC_IA_MN_CU_REL_REQ    ${29_except_counter_value}
#    ${30_status}    Run Keyword And Return Status    Verify Recent Counter Value
    Verify Recent Counter Value
    ...    counter_id=${counters[1]['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-30']['NNSAUE']['M55116C00030']}
    ...    except_counter_value=1    should_equal=True
#    Run Keyword If    '${30_status}'=='False'
#    ...    Set To Dictionary    ${counter_name_value_dict}    NRDC_FLOW_MN_INIT_TKBCK    1
#    ${35_status}    Run Keyword And Return Status    Verify Recent Counter Value
    Verify Recent Counter Value
    ...    counter_id=${counters[1]['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-30']['NNSAUE']['M55116C00035']}
    ...    except_counter_value=1    should_equal=True
#    Run Keyword If    '${35_status}'=='False'
#    ...    Set To Dictionary    ${counter_name_value_dict}    NRDC_FLOW_MN_INIT_TKBC_A    1

#    Return From Keyword If    ${counter_name_value_dict}==&{EMPTY}
#    Wait Until Keyword Succeeds    5min    60s    Verify CB008717 KF Counters Update Normal Via RDBTS    ${counter_name_value_dict}
#    Verify CB008717 KF Counters Update Normal Via RDBTS    ${counter_name_value_dict}
#    ...    should_equal=True

Verify CB008717 KF Counters Update Normal Via RDBTS
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/18 13:28
    [Arguments]    ${counter_name_value_dict}    ${connection}=ASIK Master    ${should_equal}=False
    Connect To BTS Csn Via Lmp
    ${rd_bts_gz}    csn.execute    command=ls -ltR /tmp | grep "RD.BTS.*.xml.gz" | head -n 1 |awk -F' ' '{print$9}'
    ...    connection=${connection}
    csn.execute    command=gunzip /tmp/${rd_bts_gz[:-2]}    connection=${connection}
    csn.download_file   remote_path=/tmp/${rd_bts_gz[:-5]}   local_path=${OUTPUT_DIR}/${rd_bts_gz[:-5]}
    ...    connection=${connection}
    ${counter_name_value_list}    Get Dictionary Items    ${counter_name_value_dict}
    FOR    ${counter_name}    ${except_counter_value}    IN    @{counter_name_value_list}
        ${counter_value}    csvanalyzer.get_counter_value_from_rdbts    xml_file=${OUTPUT_DIR}/${rd_bts_gz[:-5]}
        ...    dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-30    counter_name=${counter_name}
        Run Keyword If    ${should_equal}==True    run keyword and continue on failure    Should Be Equal As Numbers    ${counter_value}
        ...    ${except_counter_value}
        ...    ELSE    Should Be True    ${counter_value}>=${except_counter_value}
    END

Verify CB008717 KF02 Counters Update Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/19 11:21
    [Arguments]    ${29_except_counter_value}    ${timeout}=300    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    Sleep    30
    ${counter_ids}    Set Variable    M55116C00029
    ${counter_name_value_dict}    Create Dictionary
    ${counters}    Run Keyword And Ignore Error
    ...    coam.get_pm_counters    counter_ids=${counter_ids}    timeout=${timeout}    connection=${connection}
#    ${29_status}    Run Keyword And Return Status    Verify Recent Counter Value
    Verify Recent Counter Value
    ...    counter_id=${counters[1]['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-30']['NNSAUE']['M55116C00029']}
    ...    except_counter_value=${29_except_counter_value}    should_equal=True    start_time=${COUNTER_START_TIME}
    #TODO checking counters in files removed
#    Run Keyword If    '${29_status}'=='False'
#    ...    Set To Dictionary    ${counter_name_value_dict}    NRDC_IA_MN_CU_REL_REQ    ${29_except_counter_value}
#
#    Return From Keyword If    ${counter_name_value_dict}==&{EMPTY}
#    Wait Until Keyword Succeeds    5min    60s    Verify CB008717 KF Counters Update Normal Via RDBTS    ${counter_name_value_dict}
#    ...    should_equal=True


Get Recent Counter Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/19 11:18
    ...    Modify 2024/05/10 10:47: remove count
    [Arguments]    ${counters}    ${start_time}=all
    log    ${counters}
    log    ${start_time}
    ${time_list}    Get Dictionary Keys    ${counters}
    ${start_time}    Run Keyword If    ${start_time}==all    Set Variable    ${time_list[0]}
    ...    ELSE    Set Variable    ${start_time}
    ${counter_values}    Set Variable    0
    FOR    ${time}    IN    @{time_list}
        ${counter_values}    Run Keyword If    ${time}>=${start_time}
        ...    Evaluate    ${counter_values}+${counters['${time}']}
        ...    ELSE    Evaluate    ${counter_values}+0
    END
    [Return]    ${counter_values}

Get Recent Single Counter Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/19 11:18
    ...    Modify 2024/05/10 10:47: remove count
    [Arguments]    ${counters}    ${start_time}=all
    ${time_list}    Get Dictionary Keys    ${counters}
    log    ${counters}
    ${counter_value}    Set Variable    0
    FOR    ${time}    IN    @{time_list}
        ${counter_value}    Run Keyword If    ${counters['${time}']}>0
        ...    Set Variable    ${counters['${time}']}
        Exit For Loop If    ${counters['${time}']}>0
    END
    [Return]    ${counter_value}

Verify Recent Counter Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/04/11 13:42
    ...    Modify 2024/05/10 10:47: remove count
    [Arguments]    ${counter_id}    ${except_counter_value}    ${should_equal}=False    ${start_time}=all
    ${counter_value}    Get Recent Counter Value    counters=${counter_id}    start_time=${start_time}
    Run Keyword If    ${should_equal}==True    Should Be Equal As Numbers    ${counter_value}    ${except_counter_value}
    ...    ELSE    Should Be True    ${counter_value}>=${except_counter_value}
