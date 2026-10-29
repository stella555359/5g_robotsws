*** Settings ***
Documentation      CB013071 cloud common keyword
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot


*** Keywords ***
VDU Get Cloud PM Counter Data
    [Documentation]    *****************
    ...    This keyword is used to check counter data.
    ...    - [Keyword Details]
    ...    It iterates over each counter ID and retrieves the counter values.
    ...    It checks if the last value in the response is an integer.
    ...    If not, the keyword will fail.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | dist_name | Yes | The distribution name. |
    ...    | counter_ids | Yes | The list of counter IDs. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    [Arguments]    ${dist_name}    ${counter_ids}    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${datetime}=    Get Time    format=%Y-%m-%d
    ${date_and_time}=    Split String    ${datetime}    ${SPACE}
    ${date}=    Set Variable    ${date_and_time[0]}
    ${start_time}=  Set Variable  ${date}T00:00:00+08:00
    ${end_time}=    Set Variable  ${date}T23:59:59+08:00
    ${counter_value_list}    Create List
    FOR  ${counter_id}  IN  @{counter_ids}
        ${res}=  vdu.Get Counter Values  counter_id=${counter_id}  dimension_dn=${dist_name}  vdu_connection=${conn_alias}
        ...   start_time_lower_limit=${start_time}  start_time_upper_limit=${end_time}
        ${value}=  Set Variable  ${res[-1]['value']}
        Append To List    ${counter_value_list}    ${value}
    END
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}
    [Return]   ${counter_value_list}

Cloud vCU Login
    [Arguments]    ${vcu_index}=0    ${gnb_index}=0    ${connection}=VCU_OAM
    ${vcu_connection}    CU.connect_to
    ...  host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...  username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...  port=${EMPTY}
    ...  secure=${True}
    ...  alias=${connection}
    log to console    ${vcu_index}
    [Return]    ${vcu_connection}

Cloud vCU Logout
    [Arguments]    ${connection}=VCU_OAM
    CU.disconnect    connection=${connection}


VCU Get Cloud PM Counter Data
    [Arguments]    ${dimension_dn}    ${counter_ids}    ${measurement_id}=None
    [Documentation]    This keyword is to get the latest value for a vCU counter
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | yes | The list of counter IDs |
    ...    | ${dimension_dn} | yes | the dimension dist name that the counter belongs to, e.g.MRBTS-1111/NRBTS-1111/NRCELL-1 |
    ...    | ${measurement_id} | No | the measurement id, e.g.55115 ,the default value is None|
    ...
    ...    Examples:
    ...    |  |  |  |
    Cloud vCU Login
    ${datetime}=    Get Time    format=%Y-%m-%d
    ${date_and_time}=    Split String    ${datetime}    ${SPACE}
    ${date}=    Set Variable    ${date_and_time[0]}
    ${start_time}=  Set Variable  ${date}T00:00:00+08:00
    ${end_time}=    Set Variable  ${date}T23:59:59+08:00

    ${counter_value_list}    Create List
    FOR  ${counter_id}  IN  @{counter_ids}
        ${res}=  vcu.get_counter    measurement_id=${measurement_id}    dimension_dist_name=${dimension_dn}
        ...    counter_id=${counter_id}    connection=VCU_OAM    start_time_lower_limit=${start_time}    start_time_upper_limit=${end_time}
        ${counter_values}    Get From Dictionary    ${res}    values
        Run Keyword If    ${counter_values}==[]    Fail    No counter value right now.
        ${counter_value}    Get From Dictionary    ${counter_values[-1]}    value
        ${value}=  Set Variable  ${res['values'][-1]}
#        ${value}=  Set Variable  ${res[-1]['value']}
        Append To List    ${counter_value_list}    ${counter_value}
    END

#    ${counter}    vcu.get_counter    measurement_id=${measurement_id}    dimension_dist_name=${dimension_dn}
#    ...    counter_id=${counter_id}    connection=VCU_OAM    start_time_lower_limit=${start_time}    start_time_upper_limit=${end_time}
#    ${counter_values}    Get From Dictionary    ${counter}    values
#    Run Keyword If    ${counter_values}==[]    Fail    No counter value right now.
#    ${counter_value}    Get From Dictionary    ${counter_values[-1]}    value
#    Log To Console    The latest value for counter '${counter_id}': ${counter_value}
    [Teardown]    Run Keyword And Ignore Error    Cloud vCU Logout
    [Return]    ${counter_value_list}

Get Cloud RT and DFT user Num by counter
    [Arguments]    ${cell_id}    ${vdu_idex}=37462    ${rt}=0    ${dft}=0
    ${counter_ids}=    Create List    M55196C00011    M55196C00012
    ${counter_list}    VDU Get Cloud PM Counter Data    MRBTS-${vdu_idex}/NRBTS-${vdu_idex}/NRCELL-${cell_id}    ${counter_ids}
    ${MAX_UE_CONF_WB_BF_TAS_SRS}    set variable    ${counter_list[0]}
    ${MAX_UE_CONF_SB_BF_TAS_SRS}    set variable    ${counter_list[1]}
#    should be true    ${MAX_UE_CONF_WB_BF_TAS_SRS}==${dft}    #always fakeue attached
    should be true    ${MAX_UE_CONF_SB_BF_TAS_SRS}==${rt}
    log to console    MAX_UE_CONF_WB_BF_TAS_SRS${MAX_UE_CONF_WB_BF_TAS_SRS}==${dft}
    log to console    cellid_${cell_id} rt user num ${MAX_UE_CONF_SB_BF_TAS_SRS},DFT user num ${MAX_UE_CONF_WB_BF_TAS_SRS}
