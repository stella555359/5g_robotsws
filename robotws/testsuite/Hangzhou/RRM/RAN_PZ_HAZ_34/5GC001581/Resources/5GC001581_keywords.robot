*** Settings ***
Documentation
...   This is for 1581 TA common keywords
...   squad group: MMW_SG1

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    ./5GC001581_Variables.robot
#Resource    resources/common/coam_cu.robot
Variables   ../TestData/5GC001581_scf_modify.py


*** Keywords ***
Update and verify administrativeState parameters on ENB
    [Documentation]    Description: update administrativeState parameters on ENB, and verify the value after updated.
    [Arguments]    ${update_value}=${update_value}    ${parameters_to_update_via_api}=${MODIFY_ENB_ADMINISTRATIVESTATE_LOCK_VIA_API}
    Connect to eNB via ssl    connection=enblte
    ${update_status}    COAM Update several parameters via rest api    connection=enblte
    ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
    Should be true    '${update_status}'=='PASS'
    @{MOs}    enblte.get_managed_objects    class_name=LNADJGNB_A    connection=enblte
    ${idx}    Get parameter from MO multi-gnb    MOs=${MOs}    distname=LNADJGNB_A-1
    &{administrativeState}=    enblte.get_parameters    dist_name=${MOs[${idx}]['distName']}  pattern=administrativeState    connection=enblte
    Should be equal as strings    ${administrativeState['administrativeState']}    ${update_value}    msg=administrativeState is not ${update_value}
    [Teardown]    Enblte close down    connection=enblte

Get parameter from MO multi-gnb
    [Documentation]    Author Wang Yixiang
    ...    when there are more than one LNADJGNB MO, filter the expected MO status
    [Arguments]    ${MOs}    ${distname}
    ${idx}    set variable    ${0}
    ${len}    get length    ${MOs}
    FOR    ${idx}    IN RANGE    ${len}
        ${tmp_distname}    set variable    ${MOs[${idx}]['distName']}
        ${status}   run keyword and return status    should contain    ${tmp_distname}    ${distname}
        exit for loop if    '${status}'=='${True}'
    END
    [Return]    ${idx}

Unlock cell and unlock administrativeState parameters on ENB
    [Documentation]    Author Wang Yixiang
    ...    Description: unlock cell and set administrativeState to unlocked on ENB, and verify the value after updated.
    Perform cell unlock via rest api
    Update and verify administrativeState parameters on ENB
    ...    update_value=unlocked    parameters_to_update_via_api=${MODIFY_ENB_ADMINISTRATIVESTATE_UNLOCK_VIA_API}

Unlock X2 link from CU via Selenium
    [Arguments]         ${object_name}=LTEENB-1        ${gnb_id}=0
    [Documentation]  Author: Wang Yixiang
    ...              Lock x2 links via CU webEM
    Create cOAM CU session    gnb_id=${gnb_id}    browser=Firefox
    coam_cu.unlock_x2_links    object_name=${object_name}
    [Teardown]    Teardown cOAM CU session

Get X2 link status info via Selenium
    [Arguments]         ${gnb_id}=0
    [Documentation]  Author: Wang Yixiang
    ...              Get X2 link status info via Selenium
    Create cOAM CU session    gnb_id=${gnb_id}    browser=Firefox
    ${x2_status}    coam_cu.get_X2_link_status_info
    log to console  ${x2_status}
    [Teardown]    Teardown cOAM CU session

Check X2 available status
    [Documentation]    author: Wang Yixiang
    [Arguments]    ${gnb_index}=0    ${exp_status}=available
    CU Login  ${gnb_index}
    ${operation_response}    cu.get_x2_links_info
    ${operation_response}    Convert To String    ${operation_response}
    @{x2_status}    Get Regexp Matches	  ${operation_response}    'x2_link_status': u'(\\w+)'    1
    should be true    '${x2_status}[0]'    '${exp_status}'
    [Teardown]    run keyword and ignore error   CU Logout
