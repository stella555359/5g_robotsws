# @Time    : 2023/7/25 11:02
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB009181-A.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB009181-A

Suite Setup     SISO Coam Suite Setup
Suite Teardown    Run Keywords    Connect to gnb coam via ssl
...               AND    COAM Commission with scf file    ${COMMON_9181_SCF_FEADEP}
...               is_pdl_checking_needed=${False}    timeout=900
...               AND    SISO Coam Suite Teardown
Test Setup      MMW5 Common Case Setup
Test Teardown   MMW5 Common Case Teardown
Force Tags      CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009181/CB009181_keywords.robot

*** Variables ***
${if_commissioning}             False
${COMMON_9181_SCF_FEADEP}       ${CURDIR}/resource/COMMON_9181_FeaDep.xml
${COMMON_9181_SCF}              ${CURDIR}/resource/COMMON_9181.xml
${SCF_101}                      ${CURDIR}/resource/101.xml
${101_WITH_6RUS}                ${CURDIR}/resource/101_WITH_6RUS.xml
${101_WITH_3RUS}                ${CURDIR}/resource/101_WITH_3RUS.xml
${101_ADD_3RUS}                 ${CURDIR}/resource/101_ADD_3RUS.json
${101_DELETE_3RUS}              ${CURDIR}/resource/101_DELETE_3RUS.json
${SCF_103}                      ${CURDIR}/resource/103.xml
${103_DELETE_TDD}               ${CURDIR}/resource/103_DELETE_TDD.json
${103_ADD_TDD_RUS}              ${CURDIR}/resource/103_ADD_TDD_RUS.json
${103_ADD_TDD_CELLS}            ${CURDIR}/resource/103_ADD_TDD_CELLS.json
${103_WITHOUT_TDD}              ${CURDIR}/resource/103_WITHOUT_TDD.xml
${103_WITHOUT_TDD_CELLS}        ${CURDIR}/resource/103_WITHOUT_TDD_CELLS.xml
@{RU_INDEX_345}                 ${3}    ${4}    ${5}
${NO_USE}                       ${CURDIR}/resource/NO_USE.json

*** Test Cases ***
[1]CB009181_A_101_RAT_change_between_NRFDD12cells_single_duplex mode_to_NRFDD12cells_NRTDD6cells_concurrent_mode
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/08 13:29
    # Precondition, delete 3 TDD RUs
    COAM Commission with scf file    ${SCF_101}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${101_WITH_6RUS}    ${101_WITH_3RUS}
    ...    ${101_DELETE_3RUS}    ${101_ADD_3RUS}

    coam.perform_delta_recommissioning    delta_file=${101_DELETE_3RUS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    MMW5 Rus Power Off    RU_INDEX=${RU_INDEX_345}
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online

    # Step 1: do delta commission to add 3 tdd rus
    coam.perform_delta_recommissioning    delta_file=${101_ADD_3RUS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    Verify BTS Alarm Exist
    ...    fault_id=10    fault_name=No connection to unit

    # Step 2: connect 3 TDD Rus physically
    MMW5 Rus Power On    RU_INDEX=${RU_INDEX_345}
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    # Step 3: make a SA or NSA call on any of TDD cells
    UE Attach And Check Throughput With Detach    global_cell_id=31    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0

    # Step 4: delta commission remove TDD related RUs and 6 NRTDD cells
    coam.perform_delta_recommissioning    delta_file=${101_DELETE_3RUS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    5min    20s    CI_commssion.Verify all cells should be Online

[1]CB009181_A_103_RAT_change_between_NRFDD12cells_single_duplex mode_to_NRFDD12cells_NRTDD6cells_concurrent_mode_without_ABIP_reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/11 10:05
    # Precondition, need delete 3 tdd rus and 6 tdd cells
    COAM Commission with scf file    ${SCF_103}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    generate_delta_jsons_from_3_scf    ${cur_scf}    ${103_WITHOUT_TDD_CELLS}    ${103_WITHOUT_TDD}
    ...    ${NO_USE}    ${103_ADD_TDD_RUS}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${SCF_103}    ${103_WITHOUT_TDD}
    ...    ${103_DELETE_TDD}    ${NO_USE}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${SCF_103}    ${103_WITHOUT_TDD_CELLS}
    ...    ${NO_USE}    ${103_ADD_TDD_CELLS}

    coam.perform_delta_recommissioning    delta_file=${103_DELETE_TDD}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    # Step 1: connect 3 tdd rus physically, wait at least 600s
    MMW5 Rus Power Off    RU_INDEX=${RU_INDEX_345}
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    MMW5 Rus Power On    RU_INDEX=${RU_INDEX_345}
    Sleep    600s

    # Step 2: active one delta commission to add 3 tdd rus without cell
    coam.perform_delta_recommissioning    delta_file=${103_ADD_TDD_RUS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    Verify BTS RUs Status Is Normal State

    # Step 3: active one delta commission to add 6 tdd cells
    coam.perform_delta_recommissioning    delta_file=${103_ADD_TDD_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online

    # Step 4: make a sa call on one tdd cell, only nrcell 31 qRxLevMin=-65
    UE Attach And Check Throughput With Detach    global_cell_id=31    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0

    # Step 5: delete tdd rus
    coam.perform_delta_recommissioning    delta_file=${103_DELETE_TDD}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21
    ...    parameter=qRxLevMin    value=-65
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    # Step 6: make a sa call on one fdd cell, only nrcell 21 qRxLevMin=-65
    UE Attach And Check Throughput With Detach    global_cell_id=21    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0

[1][1.0] Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    COAM Commission with scf file    ${COMMON_9181_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    Manual_SiSo_SM_BTS_Site_Reset_1.0

[1][1.0] Manual_SiSo_CM_Recommissioning
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    COAM Commission with scf file    ${COMMON_9181_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    Manual_SiSo_CM_Recommissioning_1.0
