*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
Manual_SiSo_ALD_Detect_and_setup_AL_devices_Start-up
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to verifiy ALDs detect and start-up.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Check ALDs Status.
    ...        2. Check ALD Info .
    ...        3. Check basic l3call.
    ...    - [EXPECTED RESULTS] ALDs status are normal; l3call success.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ALD_num | No | The ALD num. Default value is 1. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 18.06.2024 - - Created
    ...    *******************
    ...    * Owner: yajie.li@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T01
    ...    *******************
    [Arguments]
    ...    ${ALD_num}=${1}
    ...    ${vdu_index}=0
    ...    ${gnb_index}=0
    ...    ${with_call}=${True}
    ...    ${suite_name}=default
    ...    ${test_name}=default
    FOR    ${i}    IN RANGE   ${1}    ${ALD_num}+1
        Cloud Check ALD RETU Status   availability_status=on line    operational_state=enabled
        ...    procedural_status=${None}    type=ALD
        Cloud Check ALD RETU Info    type=ALD
        Cloud Check ALD RETU Status   availability_status=on line    operational_state=enabled
        ...    type=RETU
        Cloud Check ALD RETU Info    type=RETU
    END

    Run Keyword If  ${with_call}    log to console  \ncheck L3call...
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    Run Keyword If    ${with_call}    Cloud UE L3 Call And Throughput    cell_list=${cell_list}
    ...    test_name=${test_name}    suite_name=${suite_name}}



Cloud Check ALD RETU Status
    [Documentation]    *****************
    ...    This keyword is used to check ALD status.
    ...    - [Keyword Details]
    ...    It aims to get ALD information via webUI and then check ALDs status.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | availability_status | Yes | The availability status. |
    ...    | operational_state | Yes | The operational state. |
    ...    | procedural_status | No | The procedural status. Default is ${None}.|
    ...    | type | No | The type. Default is ALD. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | timeout | No | The value of timeout. Default is 30. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 18.06.2024 - - Created
    ...    *******************
    ...    * Owner: yajie.li@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T01
    ...    *******************
    [Arguments]    ${availability_status}
    ...    ${operational_state}
    ...    ${procedural_status}=${None}
    ...    ${type}=ALD
    ...    ${vdu_index}=0
    ...    ${gnb_index}=0
    ...    ${timeout}=${30}
    Log To Console    Info: ready to check ${type} status...
    ${info} =    Cloud Get ALD Information via webUI    type=${type}    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    Run keyword If    '${type}'=='ALD'     Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${info[0]['availability_status']}    ${availability_status}
    ...    msg=Current ${type} availability_status is not in ${availability_status} status    ignore_case=${True}
    Run keyword If    '${type}'=='ALD'     Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${info[0]['operational_state']}     ${operational_state}
    ...    msg=Current ${type} operational_state is not in ${operational_state} status    ignore_case=${True}
    Run keyword If    '${type}'=='ALD'     Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${info[0]['procedural_status']}    ${procedural_status}
    ...    msg=Current ${type} procedural_status is not in ${procedural_status} status    ignore_case=${True}

    Run keyword If    '${type}'=='RETU'     Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${info[0]['subunits'][0]['availability_status']}    ${availability_status}
    ...    msg=Current ${type} availability_status is not in ${availability_status} status    ignore_case=${True}
    Run keyword If    '${type}'=='RETU'     Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${info[0]['subunits'][0]['operational_state']}     ${operational_state}
    ...    msg=Current ${type} operational_state is not in ${operational_state} status    ignore_case=${True}


Cloud Get ALD Information via webUI
    [Documentation]    *****************
    ...    This keyword is used to check ALD status.
    ...    - [Keyword Details]
    ...    It aims to get ALD information via webUI and return the info.
    ...
    ...    | type | No | The type. Default is ALD. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | timeout | No | The value of timeout. Default is 30. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | info | Return the ALD info. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 18.06.2024 - - Created
    ...    *******************
    ...    * Owner: yajie.li@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T01
    ...    *******************
    [Arguments]    ${type}=ALD    ${vdu_index}=0    ${gnb_index}=0    ${timeout}=${30}
    Log to console    Info: ready to Get ${type} Information
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${info}    run keyword if    '${type}'=='ALD'    vdu.get_alds    timeout=${timeout}    vdu_connection=${conn_alias}
    ...    ELSE IF    '${type}'=='RETU'    vdu.get_rets_information    timeout=${timeout}    vdu_connection=${conn_alias}
    [Return]    ${info}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}


Cloud Check ALD RETU Info
    [Documentation]    *****************
    ...    This keyword is used to check ALD status.
    ...    - [Keyword Details]
    ...    It get ALD information via webUI and check the info.
    ...
    ...    | type | No | The type. Default is ALD. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | timeout | No | The value of timeout. Default is 30. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 18.06.2024 - - Created
    ...    *******************
    ...    * Owner: yajie.li@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T01
    ...    *******************
    [Arguments]    ${type}=ALD    ${vdu_index}=0    ${gnb_index}=0    ${timeout}=${30}
    ${info} =    Cloud Get ALD Information via webUI    type=${type}    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${Product_code}    Run keyword If    '${type}'=='ALD'    set variable    ${info[0]['product_code']}
    ${Serial_number}    Run keyword If    '${type}'=='ALD'    set variable    ${info[0]['serial_number']}
    ${Vendor_code}    Run keyword If    '${type}'=='ALD'    set variable    ${info[0]['vendor_code']}
    ${SW_version}    Run keyword If    '${type}'=='ALD'    set variable    ${info[0]['software_version']}
    Run keyword If    '${type}'=='ALD'    Should Not Be Equal    ${Product_code}    -    AND
    ...    Should not be empty   ${Product_code}
    Run keyword If    '${type}'=='ALD'    Should Not Be Equal    ${Serial_number}    -    AND
    ...    Should not be empty   ${Serial_number}
    Run keyword If    '${type}'=='ALD'    Should Not Be Equal    ${Vendor_code}    -    AND
    ...    Should not be empty   ${Vendor_code}
    Run keyword If    '${type}'=='ALD'    Should Not Be Equal    ${SW_version}    -    AND
    ...    Should not be empty   ${SW_version}
    ${Mechanical_Angle}    Run keyword If    '${type}'=='RETU'     set variable    ${info[0]['subunits'][0]['mechanical_angle']}
    Run keyword If    '${type}'=='RETU'    Should Not Be Equal    ${Mechanical_Angle}    -    AND
    ...    Should not be empty   ${Mechanical_Angle}





