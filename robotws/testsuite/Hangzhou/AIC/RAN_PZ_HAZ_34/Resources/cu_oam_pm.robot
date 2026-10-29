*** Settings ***
Documentation
...   author: liting.cao@nokia-sbell.com
...   contact: liting.cao@nokia-sbell.com
...   cu_oam_pm.robot



*** Variables ***



*** Keywords ***
CU Get PM Counter Latest Values
    [Arguments]   ${counter_id}   ${measurement_id}  ${dimension_dist_name}  ${expected_value}  ${how_many}=1  ${gnb_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:   <19-Oct-2020>, <f2huang>, <Initial creation>
    ...    modified by:   <23-Mar-2021>, <huilxu>, <PM v2 Trunk>
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | measurement_id | Yes | Measurement ID |
    ...    | dimension_dist_name | No | Aggregation dimension distName of the measurement you want to retrive. |
    ...    | how_many | No | How many counter values will be get , 1 in default |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default  |
    ...
    ...    *RETURN VALUE*
    ...    Latest counter value
    ...    Example
    ...    | ${value}= | CU Get PM Counter Latest Value |  M55323C13001  |   55323   |   MRBTS-5226/NRBTS-5226  |  900  |  4  |
    CU Login    ${gnb_index}    restapi_version=cuoam_21b
    ${res}=  cu.get_counter    ${measurement_id}     ${dimension_dist_name}    ${counter_id}
    ${counter_values}=  set variable    ${res["values"]}
    ${num}=  get length   ${counter_values}
    ${expected_counter_values}=   set variable   ${counter_values[${num}-${how_many}:${num}]}
    ${flag}=   set variable   False
    FOR   ${counter_item}   IN   @{counter_values[${num}-${how_many}:${num}]}
        ${flag}=   set variable if  ${counter_item['value']}==${expected_value}   True
        exit for loop if    ${counter_item['value']}==${expected_value}
    END
    should be equal    ${flag}  True   Check counter value failed!
    [Teardown]   CU Logout


Counter Generate Remaining Time
    [Arguments]    ${internal_value}
    [Documentation]    Get the remaining counter generate time.
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:   <22-Oct-2020>, <rifeng>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | internal_value | Yes | the interval that counter generate |
    ...    *RETURN VALUE*
    ...    Latest counter value
    ...    Example
    ...    | ${value}= | Counter Generate Remaining Time |  15  |

    @{utc} =    Get Time    hour min sec    UTC
    ${utc_minute} =    convert to integer  ${utc}[1]
    set test variable  ${utc_minute}
    ${utc_minute_1} =    Evaluate    ${utc_minute}%${internal_value}
    ${utc_remain}=     Evaluate    ${internal_value} - ${utc_minute_1}
    Set test Variable    ${utc_remain}
    [return]    ${utc_remain}


Get CU Counter
    [Arguments]    ${counter_id}     ${measurement_id}    ${dimension_dist_name}    ${gnb_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:   <22-Oct-2020>, <rifeng>, <Initial creation>
    ...    modified by:   <23-Mar-2021>, <huilxu>, <trunk PM V2>
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | measurement_id | Yes | Measurement ID |
    ...    | dimension_dist_name | No | Aggregation dimension distName of the measurement you want to retrive. |
    ...    | how_many | No | How many counter values will be get , 1 in default |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default  |
    ...
    ...    *RETURN VALUE*
    ...    Latest counter value
    ...    Example
    ...    | ${value}= | Get CU Counter |  M55323C13001  |   55323   |   MRBTS-5226/NRBTS-5226  |
    CU Login    ${gnb_index}   restapi_version=cuoam_21b
    ${res}=  cu.get_counter   ${measurement_id}    ${dimension_dist_name}    ${counter_id}
    ${cv1} =  Set Variable  ${res["values"][-1]['value']}
    ${cv2} =  Set Variable  ${res["values"][-2]['value']}
    ${cv3} =  Set Variable  ${res["values"][-3]['value']}
    ${cv4} =  Set Variable  ${res["values"][-4]['value']}
    ${cv5} =  Set Variable  ${res["values"][-5]['value']}
    ${latest_counter} =  Set Variable  max(${cv1},${cv2},${cv3},${cv4},${cv5})
    [return]    ${latest_counter}
    [Teardown]   CU Logout


CU Get Specific Measurement ID Counter Values
   [Arguments]    ${counter_list}    ${measurement_id}     ${dimension_dist_name}
   [Documentation]      CU Get Specific Measurement ID Counter Values
    ...    *Author*:        jie.1.yang@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what or how |
    ...    | 06-4-2023 | jieyang | initial created |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    *Example*
    ...    | CU Get Specific Measurement ID Counter Values | ['M55320C18001', 'M55320C18002'] | | '55320' |
    ...    'MRBTS-5031/NRBTS-5031' ]
    @{counter_value_list}    create list
    FOR    ${counter_id}    IN    @{counter_list}
        ${counter_value}=   Get CU Counter     counter_id=${counter_id}   measurement_id=${measurement_id}
        ...  dimension_dist_name=${dimension_dist_name}
        append to list    ${counter_value_list}    ${counter_value}
    END
    [Return]  ${counter_value_list}
