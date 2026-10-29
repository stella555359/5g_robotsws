# @Time    : 2023/8/24 10:15
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB010543.robot.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB008717-GA

Suite Setup         SISO Coam Suite Setup
Suite Teardown      Run Keywords    Connect to gnb coam via ssl
...                 AND    COAM Commission with scf file    ${COMMON_10543_SCF_FEADEP}
...                 is_pdl_checking_needed=${False}    timeout=900
...                 AND    SISO Coam Suite Teardown
Test Setup          MMW5 Common Case Setup
Test Teardown       MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot

*** Variables ***
${if_commissioning}             False
${COMMON_10543_SCF_FEADEP}      ${CURDIR}/resource/COMMON_10543_FeaDep.xml
${COMMON_10543_SCF}             ${CURDIR}/resource/COMMON_10543.xml
${SCF_101}                      ${CURDIR}/resource/101.xml
${101_DELETE_TDD}               ${CURDIR}/resource/101_DELETE_TDD.json
${101_ADD_TDD_RUS}              ${CURDIR}/resource/101_ADD_TDD_RUS.json
${101_ADD_TDD_CELLS}            ${CURDIR}/resource/101_ADD_TDD_CELLS.json
${101_WITHOUT_TDD}              ${CURDIR}/resource/101_WITHOUT_TDD.xml
${101_WITHOUT_TDD_CELLS}        ${CURDIR}/resource/101_WITHOUT_TDD_CELLS.xml
${SCF_201}                      ${CURDIR}/resource/201.xml
${201_DELETE_AHCA}              ${CURDIR}/resource/201_DELETE_AHCA.json
${201_ADD_AHCA_WITHOUT_CELL}    ${CURDIR}/resource/201_ADD_AHCA_WITHOUT_CELL.json
${201_ADD_AHCA_CELL}            ${CURDIR}/resource/201_ADD_AHCA_CELL.json
${201_WITH_AHCA}                ${CURDIR}/resource/201_WITH_AHCA.xml
${201_WITHOUT_AHCA_CELL}        ${CURDIR}/resource/201_WITHOUT_AHCA_CELL.xml
${201_WITHOUT_AHCA}             ${CURDIR}/resource/201_WITHOUT_AHCA.xml
${NO_USE}                       ${CURDIR}/resource/NO_USE.json
${AEHC_RU_INDEX}                ${3}
${AZQS_RU_INDEX}                ${4}
${AZQU_RU_INDEX}                ${5}
${AHCA_RU_INDEX}                ${9}

*** Test Cases ***
[1]CB010543_A_101_RAT_change_between_NRFDD12cells_single_duplex_mode_to_NRFDD12cells_NRTDD3cells_concurrent_mode_without_ABIQ_reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/10 15:40
    [Tags]    101
    # Precondition, need delete 3 tdd rus and 3 tdd cells
    COAM Commission with scf file    ${101_WITHOUT_TDD_CELLS}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf2}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    COAM Commission with scf file    ${101_WITHOUT_TDD}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf3}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    COAM Commission with scf file    ${SCF_101}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf2}    ${cur_scf3}
    ...    ${NO_USE}    ${101_ADD_TDD_RUS}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf}    ${cur_scf3}
    ...    ${101_DELETE_TDD}    ${NO_USE}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf}    ${cur_scf2}
    ...    ${NO_USE}    ${101_ADD_TDD_CELLS}

    AlarmWatchdog.add_allow_alarms    fault_id=4525
    coam.perform_delta_recommissioning    delta_file=${101_DELETE_TDD}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.remove_allow_alarms    fault_id=4525

    # Step 1: connect AHCA to ABIP physically, wait at least 600s
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    Perform RU Power Off    ru_index=${AEHC_RU_INDEX}
    Perform RU Power Off    ru_index=${AZQS_RU_INDEX}
    Perform RU Power Off    ru_index=${AZQU_RU_INDEX}
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    Perform RU Power ON    ru_index=${AEHC_RU_INDEX}
    Perform RU Power ON    ru_index=${AZQS_RU_INDEX}
    Perform RU Power ON    ru_index=${AZQU_RU_INDEX}
    Sleep    600s

    # Step 2: active one delta commission to add 3 tdd rus without cell
    coam.perform_delta_recommissioning    delta_file=${101_ADD_TDD_RUS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    Verify BTS RUs Status Is Normal State

    # Step 3: active one delta commission to add 3 tdd cells
    coam.perform_delta_recommissioning    delta_file=${101_ADD_TDD_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Repeat Keyword    2mins    Verify BTS 5G FDD Cells Status Normal
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.remove_allow_alarms    fault_id=4589

    # Step 4: make a sa call on one tdd cell, only nrcell 31 qRxLevMin=-65
    UE Attach And Check Throughput With Detach    global_cell_id=31    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0

    # Step 5: delete tdd rus
    coam.perform_delta_recommissioning    delta_file=${101_DELETE_TDD}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21
    ...    parameter=qRxLevMin    value=-65
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    # Step 6: make a sa call on one fdd cell, only nrcell 21 qRxLevMin=-65
    UE Attach And Check Throughput With Detach    global_cell_id=21    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0

#[1]CB010543_C_201_RF_split_interworking_with_NRFDD_NRTDD_concurrent_mode_with_ABIQ_reset
#    [Documentation]    Author: jian.1.chen@nokia-sbell.com
#    ...    Init Define: 2023/09/12 14:10
#    # Precondition, need delete ahca
#    COAM Commission with scf file    ${SCF_201}    is_pdl_checking_needed=${False}    timeout=900
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#
#    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}
#    generate_delta_jsons_from_3_scf    ${cur_scf}    ${201_WITHOUT_AHCA_CELL}    ${201_WITHOUT_AHCA}
#    ...    ${NO_USE}    ${201_ADD_AHCA_WITHOUT_CELL}
#    generate_delta_jsons_from_3_scf    ${cur_scf}    ${201_WITH_AHCA}    ${201_WITHOUT_AHCA}
#    ...    ${201_DELETE_AHCA}    ${NO_USE}
#    generate_delta_jsons_from_3_scf    ${cur_scf}    ${201_WITH_AHCA}    ${201_WITHOUT_AHCA_CELL}
#    ...    ${NO_USE}    ${201_ADD_AHCA_CELL}
#
#    coam.perform_delta_recommissioning    delta_file=${201_DELETE_AHCA}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#
#    # Step 1: connect AHCA to ABIP physically, wait at least 600s
#    Perform RU Power Off    ru_index=${AHCA_RU_INDEX}
#    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
#    coam.reset_site    connection=GNB_OAM
#    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
#    Perform RU Power ON    ru_index=${AHCA_RU_INDEX}
#    Sleep    600s
#
#    # Step 2: active one delta commission to add AHCA without cell
#    coam.perform_delta_recommissioning    delta_file=${201_ADD_AHCA_WITHOUT_CELL}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#    Wait Until Keyword Succeeds    15min    20s    Verify BTS RUs Status Is Normal State
#
#    # Step 3: active one delta commission to add AHCA cell
#    coam.perform_delta_recommissioning    delta_file=${201_ADD_AHCA_CELL}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
#
#    # Step 4: make a sa call on one NRFDD cells
#    UE Attach And Check Throughput With Detach    global_cell_id=16    ul_tp=10M    ul_tp_threshold=1
#    ...    dl_tp=10M    dl_tp_threshold=1

[1][2.0] Manual_SiSo_CM_Recommissioning
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/24 11:17
    COAM Commission with scf file    ${COMMON_10543_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    Manual_SiSo_CM_Recommissioning_2.0

[1][2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/24 11:17
    COAM Commission with scf file    ${COMMON_10543_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    Manual_SiSo_SM_BTS_Site_Reset_2.0

[1][2.1] General_SiSo_Cell_block_and_unblock
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/24 11:17
    COAM Commission with scf file    ${COMMON_10543_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.add_allow_alarms    fault_id=49
    General_SiSo_Cell_block_and_unblock_2.1
    AlarmWatchdog.remove_allow_alarms    fault_id=49
