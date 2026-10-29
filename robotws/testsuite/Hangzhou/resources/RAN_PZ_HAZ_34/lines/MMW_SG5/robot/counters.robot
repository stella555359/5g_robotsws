*** Settings ***
Documentation
...  Time: 2024/1/19 11:30
...  Author: Jian.1.Chen
...  Email: jian.1.chen@nokia-sbell.com
...  File: counters.robot
...  Software: PyCharm
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
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
    ${29_status}    Run Keyword And Return Status    Verify Recent Counter Value
    ...    counter_id=${counters[1]['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-1']['NNSAUE']['M55116C00029']}
    ...    except_counter_value=${29_except_counter_value}    should_equal=True    start_time=${COUNTER_START_TIME}
    Run Keyword If    '${29_status}'=='False'
    ...    Set To Dictionary    ${counter_name_value_dict}    NRDC_IA_MN_CU_REL_REQ    ${29_except_counter_value}
    ${30_status}    Run Keyword And Return Status    Verify Recent Counter Value
    ...    counter_id=${counters[1]['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-1']['NNSAUE']['M55116C00030']}
    ...    except_counter_value=1    should_equal=True
    Run Keyword If    '${30_status}'=='False'
    ...    Set To Dictionary    ${counter_name_value_dict}    NRDC_FLOW_MN_INIT_TKBCK    1
    ${35_status}    Run Keyword And Return Status    Verify Recent Counter Value
    ...    counter_id=${counters[1]['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-1']['NNSAUE']['M55116C00035']}
    ...    except_counter_value=1    should_equal=True
    Run Keyword If    '${35_status}'=='False'
    ...    Set To Dictionary    ${counter_name_value_dict}    NRDC_FLOW_MN_INIT_TKBC_A    1

    Return From Keyword If    ${counter_name_value_dict}==&{EMPTY}
    Wait Until Keyword Succeeds    5min    60s    Verify CB008717 KF Counters Update Normal Via RDBTS    ${counter_name_value_dict}
    ...    should_equal=True

Verify CB008717 KF Counters Update Normal Via RDBTS
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/18 13:28
    [Arguments]    ${counter_name_value_dict}    ${connection}=ASIK Master    ${should_equal}=False
    Connect To BTS Csn Via Lmp
    ${rd_bts_gz}    csn.execute    command=ls -ltR /tmp | grep "RD.BTS.*.xml.gz" | head -n 1 |awk -F' ' '{print$9}'
    ...    connection=${connection}
    csn.execute    command=gunzip /tmp/${rd_bts_gz[:-2]}    connection=${connection}
    csn.download_file   remote_path=/tmp/${rd_bts_gz[:-5]}   local_path=${TS_LOG_PATH_CLOUD}/${rd_bts_gz[:-5]}
    ...    connection=${connection}
    ${counter_name_value_list}    Get Dictionary Items    ${counter_name_value_dict}
    FOR    ${counter_name}    ${except_counter_value}    IN    @{counter_name_value_list}
        ${counter_value}    get_counter_value_from_rdbts    xml_file=${TS_LOG_PATH_CLOUD}/${rd_bts_gz[:-5]}
        ...    dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    counter_name=${counter_name}
        Run Keyword If    ${should_equal}==True    Should Be Equal As Numbers    ${counter_value}    ${except_counter_value}
        ...    ELSE    Should Be True    ${counter_value}>=${except_counter_value}
    END

Verify CB008717 KF02 Counters Update Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/19 11:21
    [Arguments]    ${29_except_counter_value}    ${timeout}=300    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${counter_ids}    Set Variable    M55116C00029
    ${counter_name_value_dict}    Create Dictionary
    ${counters}    Run Keyword And Ignore Error
    ...    coam.get_pm_counters    counter_ids=${counter_ids}    timeout=${timeout}    connection=${connection}
    ${29_status}    Run Keyword And Return Status    Verify Recent Counter Value
    ...    counter_id=${counters[1]['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-1']['NNSAUE']['M55116C00029']}
    ...    except_counter_value=${29_except_counter_value}    should_equal=True    start_time=${COUNTER_START_TIME}
    Run Keyword If    '${29_status}'=='False'
    ...    Set To Dictionary    ${counter_name_value_dict}    NRDC_IA_MN_CU_REL_REQ    ${29_except_counter_value}

    Return From Keyword If    ${counter_name_value_dict}==&{EMPTY}
    Wait Until Keyword Succeeds    5min    60s    Verify CB008717 KF Counters Update Normal Via RDBTS    ${counter_name_value_dict}
    ...    should_equal=True

Verify CB008717 KF08 Counters Update Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/19 11:21
    [Arguments]    ${timeout}=300    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${counter_ids}    Set Variable    M55116C00030,M55116C00035
    ${counter_name_value_dict}    Create Dictionary
    ${counters}    Run Keyword And Ignore Error
    ...    coam.get_pm_counters    counter_ids=${counter_ids}    timeout=${timeout}    connection=${connection}
    ${30_status}    Run Keyword And Return Status    Verify Recent Counter Value
    ...    counter_id=${counters[1]['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-1']['NNSAUE']['M55116C00030']}
    ...    except_counter_value=2    should_equal=True
    Run Keyword If    '${30_status}'=='False'
    ...    Set To Dictionary    ${counter_name_value_dict}    NRDC_FLOW_MN_INIT_TKBCK    2
    ${35_status}    Run Keyword And Return Status    Verify Recent Counter Value
    ...    counter_id=${counters[1]['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-1']['NNSAUE']['M55116C00035']}
    ...    except_counter_value=2    should_equal=True
    Run Keyword If    '${35_status}'=='False'
    ...    Set To Dictionary    ${counter_name_value_dict}    NRDC_FLOW_MN_INIT_TKBC_A    2

    Return From Keyword If    ${counter_name_value_dict}==&{EMPTY}
    Wait Until Keyword Succeeds    5min    60s    Verify CB008717 KF Counters Update Normal Via RDBTS    ${counter_name_value_dict}
    ...    should_equal=True

Get Recent Counter Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/19 11:18
    ...    Modify 2024/05/10 10:47: remove count
    [Arguments]    ${counters}    ${start_time}=all
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
    ...    Modify 2026/02/09: only check latest N timepoints (default 2) for latest non-zero
    [Arguments]    ${counters}    ${start_time}=all    ${max_points}=2
    Log  ${start_time}
    ${time_list}    Get Dictionary Keys    ${counters}
    Reverse List    ${time_list}
    ${counter_value}    Set Variable    0
    ${checked}    Set Variable    0
    FOR    ${time}    IN    @{time_list}
        Exit For Loop If    ${checked}>=${max_points}
        ${checked}    Evaluate    ${checked}+1

        ${counter_value}    Run Keyword If    ${counters['${time}']}>0
        ...    Set Variable    ${counters['${time}']}
        Exit For Loop If    ${counters['${time}']}>0
    END
    [Return]    ${counter_value}

Get Recent Multi Counters Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/27 20:13
    [Arguments]    ${counters}
    ${counter_values}    Create Dictionary
    ${counter_names}    Get Dictionary Keys    ${counters}
    FOR    ${counter_name}    IN    @{counter_names}
        ${values}    Get Dictionary Values    ${counters['${counter_name}']}
        Set To Dictionary    ${counter_values}    ${counter_name}=${values[-1]}
    END
    [Return]    ${counter_values}

Get Recent Multi Counters Value After Cell Block Unblock
    [Documentation]    Author: bingxi.x.zheng@nokia-sbell.com
    ...    Init Define: 2026/01/08 18:27
    [Arguments]    ${counters}
    ${counter_values}    Create Dictionary
    ${counter_names}    Get Dictionary Keys    ${counters}
    FOR    ${counter_name}    IN    @{counter_names}
        ${values}    Get Dictionary Values    ${counters['${counter_name}']}
        Set To Dictionary    ${counter_values}    ${counter_name}=${values[-2]}
    END
    [Return]    ${counter_values}

Verify Recent Counter Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/04/11 13:42
    ...    Modify 2024/05/10 10:47: remove count
    [Arguments]    ${counter_id}    ${except_counter_value}    ${should_equal}=False    ${start_time}=all
    ${counter_value}    Get Recent Counter Value    counters=${counter_id}    start_time=${start_time}
    Run Keyword If    ${should_equal}==True    Should Be Equal As Numbers    ${counter_value}    ${except_counter_value}
    ...    ELSE    Should Be True    ${counter_value}>=${except_counter_value}

Get Counter Check time
    [Documentation]    Author: liqin.yang@nokia-sbell.com
    [Arguments]  ${counter}=M55193C00001  ${meas}=${M55193}  ${NPRMQAP-id}=NRCELL-13/NRPMQAP-1
    Wait for next counter period
    Sleep  2min  reason=wait for Measurement
    Log To Console  Get Check time
    ${counter_group} =    Split String    ${NPRMQAP-id}    /
    ${len}  Get Length  ${counter_group}
    ${Counter1} =    Wait Until Keyword Succeeds  3x  10s  coam.get_counters_info    connection=GNB_OAM    timeout=600
    ...  dist_name=BTS/${GNB_PATH}/${NPRMQAP-id}/${meas}/${counter}
    &{dic_name}  Set Variable  ${Counter1['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['${counter_group[0]}']}
    FOR  ${i}  IN RANGE  1  ${len}
      &{dic_name}  Set Variable  ${dic_name['${counter_group[${i}]}']}
    END
    ${Counter10}=  Set Variable  ${dic_name['${meas}']['${counter}']}
    ${Counter11}=  Get Dictionary Keys  ${Counter10}
    ${Counter_Time}  Set Variable  ${Counter11[-1]}
    ${latest_value}  Get From Dictionary    ${Counter10}    ${Counter_Time}
    ${Counter_Time}  Run Keyword If  ${latest_value}>=${1}  set variable  ${Counter_Time}
    ...  ELSE  Set Variable    ${Counter11[-2]}
    [return]    ${Counter_Time}

Wait for next counter period
    [Documentation]    Author: liqin.yang@nokia-sbell.com
    [Arguments]    ${interval_time}=5min
	${wait_time}    Get waiting value minutes    interval=${interval_time}
    sleep    ${wait_time}min

Get waiting value minutes
    [Documentation]    Author: liqin.yang@nokia-sbell.com
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${wait_time}
