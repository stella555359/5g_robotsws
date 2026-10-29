# @Time    : 2023/2/10 11:03
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB009919.robot.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB009919-SR-A _AEHC

Suite Setup     Run Keywords    SISO Coam Suite Setup
...    AND    Replace Swconfig Through Local File    ${CURDIR}/swconfig.txt
Suite Teardown  SISO Coam Suite Teardown
Test Setup           Run Keywords    robot_common_operations.Common Case Setup
...    AND     Connect to gnb coam via ssl
Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown
...    AND     Run Keyword And Ignore Error    COAM Teardown gnb connections
Force Tags    SBTS00    RAN_5G    PY39
...           RAN_5G_TDD    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASILR_ABIOB4_2xAEHC_ENB

Resource    CB009919_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot

*** Variables ***
${if_commissioning}    True
${CASE1_SET_tddSpecSubfConf_5}    ${CURDIR}/commission/case1_set_tddSpecSubfConf_5.json
${CASE1_SET_tddSpecSubfConf_6}    ${CURDIR}/commission/case1_set_tddSpecSubfConf_6.json
${CASE2_SET_tddSpecSubfConf_5}    ${CURDIR}/commission/case2_set_tddSpecSubfConf_5.json
${CASE2_SET_tddSpecSubfConf_6}    ${CURDIR}/commission/case2_set_tddSpecSubfConf_6.json
${CASE3_SET_tddSpecSubfConf_5}    ${CURDIR}/commission/case3_set_tddSpecSubfConf_5.json
${CASE3_SET_tddSpecSubfConf_6}    ${CURDIR}/commission/case3_set_tddSpecSubfConf_6.json
${CASE4_SET_TWO_CHBW10}    ${CURDIR}/commission/case4_2_10M.json
${CASE4_SET_TWO_CHBW15}    ${CURDIR}/commission/case4_2_15M.json
${CASE4_SET_ONE_CHBW10}    ${CURDIR}/commission/case4_1_10M.json
${LOCK_1_2_CELL}    ${CURDIR}/commission/lock_1_2_cell.json
${LOCK_2_3_CELL}    ${CURDIR}/commission/lock_2_3_cell.json
${DISABLE_MICRO_DTX}    ${CURDIR}/commission/disable_micro_dtx.json
${ENABLE_MICRO_DTX}    ${CURDIR}/commission/enable_micro_dtx.json
${SCF_01}    ${CURDIR}/commission/CB009919_Case1.xml
${SCF_02}    ${CURDIR}/commission/CB009919_Case5_Case7_Case8.xml
${SCF_03}    ${CURDIR}/commission/CB009919_Case6.xml
@{101_CELLS}    LNCEL-101
@{103_CELLS}    LNCEL-103
@{101_2_3_CELLS}    LNCEL-101    LNCEL-102    LNCEL-103
@{ALL_CELLS}    LNCEL-101    LNCEL-102    LNCEL-103    LNCEL-201    LNCEL-202    LNCEL-203

*** Test Cases ***
CB009919-SR-A_1_User Scenario CB009919-A RRMT#1 - Single cell setup and on air for chile radio
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c001
    COAM Commission with scf file    ${SCF_01}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State
    UE Attach On Different tddSpecSubfConf
    ...    ${CASE1_SET_tddSpecSubfConf_5}    ${CASE1_SET_tddSpecSubfConf_6}    ${101_CELLS}

CB009919-SR-A_5_User Scenario CB009919-A RRMT#14 - 3 Cell per Loki setup and on air for chile radio
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c002
    COAM Commission with scf file    ${SCF_02}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State
    UE Attach On Different tddSpecSubfConf
    ...    ${CASE2_SET_tddSpecSubfConf_5}    ${CASE2_SET_tddSpecSubfConf_6}    ${101_2_3_CELLS}

CB009919-SR-A_6_User Scenario CB009919-A RRMT#15- 6 Cell per Loki setup and on air for chile radio
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c003
    COAM Commission with scf file    ${SCF_03}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State
    UE Attach On Different tddSpecSubfConf
    ...    ${CASE3_SET_tddSpecSubfConf_5}    ${CASE3_SET_tddSpecSubfConf_6}    ${ALL_CELLS}

CB009919-SR-A_7_User Scenario CB009919-A RRMT#20 - Reconfiguration during runtime and mixed BW for chile radio
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c004
    COAM Commission with scf file    ${SCF_02}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State
    coam.perform_delta_recommissioning    delta_file=${CASE4_SET_TWO_CHBW10}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Sleep    60s
    UE Attach 4G And Check Throughput Normal    ${101_CELLS}
    coam.perform_delta_recommissioning    delta_file=${CASE2_SET_tddSpecSubfConf_5}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Sleep    60s
    UE Attach 4G And Check Throughput Normal    ${101_CELLS}
    coam.perform_delta_recommissioning    delta_file=${CASE4_SET_TWO_CHBW15}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Sleep    60s
    UE Attach 4G And Check Throughput Normal    ${101_CELLS}
    coam.perform_delta_recommissioning    delta_file=${CASE2_SET_tddSpecSubfConf_6}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Sleep    60s
    UE Attach 4G And Check Throughput Normal    ${101_CELLS}
    coam.perform_delta_recommissioning    delta_file=${CASE4_SET_ONE_CHBW10}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    Sleep    60s
    UE Attach 4G And Check Throughput Normal    ${103_CELLS}

[1][1.0] General_SiSo_Auto_uDTX_verification
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c005
    COAM Commission with scf file    ${SCF_03}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State
    coam.perform_delta_recommissioning    delta_file=${DISABLE_MICRO_DTX}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    ${high_rmod_powers}    Get Average Rmod RealTime Power Measurement
    coam.perform_delta_recommissioning    delta_file=${ENABLE_MICRO_DTX}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    ${low_rmod_powers}    Get Average Rmod RealTime Power Measurement
    ${rmod_length}    Get Length    ${high_rmod_powers}
    FOR    ${i}    IN RANGE    ${rmod_length}
        Should Be True    ${high_rmod_powers[${i}]}>${low_rmod_powers[${i}]}
    END

[1.0] Manual_SiSo_REC_Radio_Module_power_reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c006
    COAM Commission with scf file    ${SCF_03}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State
    ${ru_index_list}    Create List    1
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online   ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    10min    15s    Verify BTS 4G Cells Status Is Normal State
    UE Attach 4G And Check Throughput Normal    ${ALL_CELLS}
    [Teardown]    Selenium Logout And Close Browser
