# @Time    : 2023/5/30
# @Author  : xudong.1.li
# @Email   : xudong.1.li@nokia-sbell.com
# @File    : CB009181_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is CB009181 common robot keywords
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Library     parse_scf_to_json9181.py

*** Keywords ***
CB009181 Generate Delta Json Precondition
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ${scf_file}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}
    generate_ru_delta_json9181    ${scf_file}    ${MRBTS_ID}    ${CURDIR}

Initialize CB009181 Case Set up
    [Documentation]  Author: xudong.1.li@nokia-sbell.com
    [Arguments]  ${delta_file}    ${RU_INDEX}    ${timeout}=600    ${connection}=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${timeout}    connection=${connection}
    sleep    10s
    MMW5 Rus Power Off    RU_INDEX=${RU_INDEX}
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    coam.reset_site    connection=${connection}
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online

MMW5 Rus Power On
    [Documentation]  Author: xudong.1.li@nokia-sbell.com
    [Arguments]  ${RU_INDEX}
    Log to console    \n*****Rus Power On
    FOR    ${index}    IN    @{RU_INDEX}
        Perform RU Power On    ru_index=${index}
    END

MMW5 Rus Power Off
    [Documentation]  Author: xudong.1.li@nokia-sbell.com
    [Arguments]  ${RU_INDEX}
    Log to console    \n*****Rus Power Off
    FOR    ${index}    IN    @{RU_INDEX}
        Perform RU Power Off    ru_index=${index}
    END

Lock Unlock ENB Cell via Coam
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]    ${lncel_id}=1    ${enb_index}=0    ${value}=unlocked    ${connection}=ENB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    connection=${connection}
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-${lncel_id}
    ...    parameter=administrativeState    value=${value}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

MMW5 Check GNB RU status Enabled
    [Documentation]  Author: xudong.1.li
    ...              Description: Support to check with multiple rmod
    [Arguments]    ${connection}=GNB_OAM
    Log to console    \n********Check RU status from GNB********
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    Should be true    ${count_RUs}>=${1}    msg=Check RU status failed as total RU number is less than 1
    FOR  ${ru}  IN  @{list_RUs}
        Should be equal as strings    ${ru['status']['administrativeState']}    ${unlocked}
        Should be equal as strings    ${ru['status']['operationalState']}    ${enabled}
#        Should be equal as strings    ${ru['status']['proceduralStatus']}    configured
#        run keyword if   ${result}    Run keyword and continue on failure
#        ...    Should be equal as strings    ${ru['status']['availabilityStatus']}    Online
#        ...  msg=Current RU availabilityStatus is not in Online status
    END

Modify Parameter On BTS With Activate Validate Relation ERR
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${dist_name}    ${parameter}    ${value}    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning    dist_name=${dist_name}
    ...    parameter=${parameter}    value=${value}    operation=update    connection=${connection}

