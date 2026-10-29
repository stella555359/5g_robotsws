# @Time    : 2023/7/26 15:14
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB009181-C.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB009181-C

Suite Setup     SISO Coam Suite Setup
Suite Teardown  SISO Coam Suite Teardown
Test Setup      MMW5 Common Case Setup
Test Teardown   MMW5 Common Case Teardown
Force Tags      CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009181/CB009181_keywords.robot

*** Variables ***
${if_commissioning}             False
${SCF_301}                      ${CURDIR}/resource/301.xml
${SCF_303}                      ${CURDIR}/resource/303.xml
${301_DELETE_AHCA}              ${CURDIR}/resource/301_DELETE_AHCA.json
${301_ADD_AHCA_WITHOUT_CELL}    ${CURDIR}/resource/301_ADD_AHCA_WITHOUT_CELL.json
${301_ADD_AHCA_CELL}            ${CURDIR}/resource/301_ADD_AHCA_CELL.json
${301_WITH_AHCA}                ${CURDIR}/resource/301_WITH_AHCA.xml
${301_WITHOUT_AHCA_CELL}        ${CURDIR}/resource/301_WITHOUT_AHCA_CELL.xml
${301_WITHOUT_AHCA}             ${CURDIR}/resource/301_WITHOUT_AHCA.xml
${AHCA_RU_INDEX}                ${9}
${303_DELETE_AZQS}              ${CURDIR}/resource/303_DELETE_AZQS.json
${303_ADD_AZQS}                 ${CURDIR}/resource/303_ADD_AZQS.json
${303_WITH_AZQS}                ${CURDIR}/resource/303_WITH_AZQS.xml
${303_WITHOUT_AZQS}             ${CURDIR}/resource/303_WITHOUT_AZQS.xml
${NO_USE}                       ${CURDIR}/resource/NO_USE.json

*** Test Cases ***
CB009181_C_301_RF_split_interworking_with_NRFDD_NRTDD_concurrent_mode_with_ABIP_reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/07 17:01
    # Precondition, need delete ahca
    COAM Commission with scf file    ${301_WITHOUT_AHCA_CELL}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf2}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    COAM Commission with scf file    ${301_WITHOUT_AHCA}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf3}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    COAM Commission with scf file    ${301_WITH_AHCA}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf4}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    COAM Commission with scf file    ${SCF_301}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf2}    ${cur_scf3}
    ...    ${NO_USE}    ${301_ADD_AHCA_WITHOUT_CELL}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf4}    ${cur_scf3}
    ...    ${301_DELETE_AHCA}    ${NO_USE}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf4}    ${cur_scf2}
    ...    ${NO_USE}    ${301_ADD_AHCA_CELL}

    coam.perform_delta_recommissioning    delta_file=${301_DELETE_AHCA}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    # Step 1: connect AHCA to ABIP physically, wait at least 600s
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    Perform RU Power Off    ru_index=${AHCA_RU_INDEX}
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    Perform RU Power ON    ru_index=${AHCA_RU_INDEX}
    Sleep    600s

    # Step 2: active one delta commission to add AHCA without cell
    coam.perform_delta_recommissioning    delta_file=${301_ADD_AHCA_WITHOUT_CELL}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    Verify BTS RUs Status Is Normal State

    # Step 3: active one delta commission to add AHCA cell
    coam.perform_delta_recommissioning    delta_file=${301_ADD_AHCA_CELL}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online

    # Step 4: make a sa call on one NRFDD cells
    UE Attach And Check Throughput With Detach    global_cell_id=16    ul_tp=10M    ul_tp_threshold=1
    ...    dl_tp=10M    dl_tp_threshold=1    min_percent=0

CB009181_C_303_FDD_CA_interworking_with_NRFDD_NRTDD_concurrent_mode
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/23 10:58
    [Tags]    c303
    # Precondition, need delete azqs
    COAM Commission with scf file    ${303_WITH_AZQS}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf2}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    COAM Commission with scf file    ${303_WITHOUT_AZQS}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf3}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    COAM Commission with scf file    ${SCF_303}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf2}    ${cur_scf3}
    ...    ${303_DELETE_AZQS}    ${303_ADD_AZQS}
    coam.perform_delta_recommissioning    delta_file=${303_DELETE_AZQS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    # Step 1: make a call under FDD 2CC cells, start TCP traffic
    ${ul_peak16_1}    ${dl_peak16_1}    UE Attach And Check TCP Throughput
    ...    global_cell_id=16    ul_tp_threshold=-1    dl_tp_threshold=-1
    ${ul_peak17_1}    ${dl_peak17_1}    UE Attach And Check TCP Throughput
    ...    global_cell_id=17    ul_tp_threshold=-1    dl_tp_threshold=-1

    # Step 2: connect AZQS to ABIP physically, then active one delta commission
    coam.perform_delta_recommissioning    delta_file=${303_ADD_AZQS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    Verify BTS OnAir Ready For L3call

    # Step 3: make a call under FDD 2CC cells(same cells with step1), start TCP traffic
    ${ul_peak16_2}    ${dl_peak16_2}    UE Attach And Check TCP Throughput
    ...    global_cell_id=16    ul_tp_threshold=-1    dl_tp_threshold=-1
    ${ul_peak17_2}    ${dl_peak17_2}    UE Attach And Check TCP Throughput
    ...    global_cell_id=17    ul_tp_threshold=-1    dl_tp_threshold=-1
    Verify Two Throughputs Are Similar    ${ul_peak16_1}    ${ul_peak16_2}    80
    Verify Two Throughputs Are Similar    ${ul_peak17_1}    ${ul_peak17_2}    80
    Verify Two Throughputs Are Similar    ${dl_peak16_1}    ${dl_peak16_2}    80
    Verify Two Throughputs Are Similar    ${dl_peak17_1}    ${dl_peak17_2}    80
    [Teardown]    Run Keywords    Close the iperf3 process on UEPC
#    ...    AND     Close the iperf3 process on APPserver
