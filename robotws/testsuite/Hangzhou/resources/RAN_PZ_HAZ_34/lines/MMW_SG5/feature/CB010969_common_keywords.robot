# @Time    : 2024/6/28 15:32
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB010969_common_keywords.robot
# @Software: PyCharm
# @Doc     : This is common robot keywords template
*** Settings ***
Documentation
...    Feature CB009508

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
CB010969 Precondition Delta Json
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/12 11:09
    # modify by jian: actEcpriPhase2 and actEcpriPhase3 removed on new trunk, but exist on branch
    ${result}    Run Keyword And Return Status    COAM Commission with scf file    ${103_NO_RU13_SCF}
    ...    is_pdl_checking_needed=${False}    timeout=900
    Run Keyword If    "${result}"=="False"    Set Test Variable    ${103_NO_RU13_SCF}    ${103_NO_RU13_25R2_SCF}
    Run Keyword If    "${result}"=="False"    Set Test Variable    ${103_NO_RU123_SCF}    ${103_NO_RU123_25R2_SCF}
    Run Keyword If    "${result}"=="False"    Set Test Variable    ${103_FULL_SCF}    ${103_FULL_25R2_SCF}
    Run Keyword If    "${result}"=="False"
    ...    COAM Commission with scf file    ${103_NO_RU13_SCF}    is_pdl_checking_needed=${False}    timeout=900
    # modify by jian: 2025/08/29 10:41

    Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${103_NO_RU13_SCF}    ${103_NO_RU123_SCF}
    ...    ${NO_USE_DELTA}    ${CREATE_RU2_NO_RU13_DELTA}

    #generate_add_json_base_delete_json_and_cur_scf    ${cur_scf}    ${REMOVE_RU2_DELTA}    ${CREATE_RU2_DELTA}
    #modify_delta_json    ${CREATE_RU2_DELTA}    ${MODIFY_RU2_NO_RU13_DELTA}    ${CREATE_RU2_NO_RU13_DELTA}

    COAM Commission with scf file    ${103_FULL_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${103_FULL_SCF}    ${103_NO_RU13_SCF}
    ...    ${NO_USE_DELTA}    ${CREATE_RU13_DELTA}

CB010969 Precondition Common Delete
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/06 11:21
    [Arguments]    ${delta_json}    ${rus_index}
    coam.perform_delta_recommissioning    delta_file=${delta_json}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    15s    Verify BTS 5G Cells Status Is Normal State

    FOR    ${index}    IN    @{rus_index}
        Perform RU Power Off    ru_index=${index}
    END
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

Power On For Restore RU
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/01/23
    [Arguments]    @{RU_INDEX_2RU}
    Log To Console    Restore ALL RU
    Connect to gnb coam via ssl
    FOR    ${index}    IN    @{RU_INDEX_2RU}
        Perform RU Power On    ru_index=${index}
    END
