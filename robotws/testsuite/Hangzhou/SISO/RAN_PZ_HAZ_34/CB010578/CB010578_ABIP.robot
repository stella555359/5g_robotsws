# @Time    : 2024/1/15 10:32
# @Author  : echo.xu
# @Email   : echo.xu@nokia-sbell.com
# @File    : CB010578_ABIP.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Xu Echo
...    contact: echo.xu@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB010578

Suite Setup           SISO Coam Suite Setup
Suite Teardown        SISO Coam Suite Teardown
Test Setup            MMW5 Common Case Setup
Test Teardown         MMW5 Common Case Teardown
Force Tags            CRT_TRUNK    PY39

Resource                testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource                testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource                testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009181/CB009181_keywords.robot
Resource                testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource                testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010578/CB010578_keywords.robot

*** Variables ***
${if_commissioning}           False
@{case101_TDD_RU}             ${1}    ${3}
${SCF_P_L1}                   ${CURDIR}/ABIP/SCF_101_L1_Full.xml
${SCF_P_L1_no_2ecpri}         ${CURDIR}/ABIP/SCF_101_L1_no_2ecpri.xml
${101_ADD_2eCPRI_RU}          ${CURDIR}/ABIP/101_ADD_eCPRI_RU_NRCELL.json
${BARRY_CELLS_101}            ${CURDIR}/ABIP/BARRY_only_NRCELL_101.json
${SCF_P_L1_only_LTERAT}       ${CURDIR}/ABIP/SCF_case101_P_L1_only_LTERAT.xml
${101_DELETE_NRRAT}           ${CURDIR}/ABIP/101_DELETE_NRRAT.json
${scf_P_L2}                   ${CURDIR}/ABIP/SCF_P_L2.xml
${BARRY_107_eCPRI}            ${CURDIR}/ABIP/BARRY_107_eCPRI.json
${BARRY_107_CPRI}             ${CURDIR}/ABIP/BARRY_107_CPRI.json
${scf_P_N2}                   ${CURDIR}/ABIP/SCF_P_N2.xml
${SCF_case110_full}           ${CURDIR}/ABIP/case110_full_commission.xml
${SCF_N2_NO_2RU}              ${CURDIR}/ABIP/case110_step1.xml
${SCF_P_N2_NO_TDD}            ${CURDIR}/ABIP/SCF_P_N2_case110_NO_TDD.xml
${no_use}                     ${CURDIR}/ABIP/no_use.json
${110_ADD_2RU}                ${CURDIR}/ABIP/110_ADD_2RU.json
${110_DELETE_TDDNR}           ${CURDIR}/ABIP/110_DELETE_TDDNR.json
${modify_BBType_1}            ${CURDIR}/ABIP/110_NRFDD_NRTDD.json
${modify_BBType_2}            ${CURDIR}/ABIP/110_NRFDD.json
${SCF_N2_NO_2TDDRU}           ${CURDIR}/ABIP/SCF_P_N2_case116_no_2RU.xml
${116_ADD_2RU}                ${CURDIR}/ABIP/116_ADD_2RU.json

*** Test Cases ***
CB010578-D_101_RAT_change_between_LTEFDD16cells_single_duplex mode_to_LTEFDD16cells_NRTDD6cells_concurrent_mode
    [Documentation]    Author: echo.xu@nokia-sbell.com
    #precondition
    COAM Commission with scf file    ${SCF_P_L1}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    COAM Commission with scf file    ${SCF_P_L1_no_2ecpri}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    ${cur_scf2}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    COAM Commission with scf file    ${SCF_P_L1_only_LTERAT}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    ${cur_scf3}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf}    ${cur_scf2}
    ...    ${no_use}    ${101_ADD_2eCPRI_RU}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf}    ${cur_scf3}
    ...    ${101_DELETE_NRRAT}    ${no_use}
    # Step1:load case101 step1 scf. power off 2 eCPRI RU
    COAM Commission with scf file    ${SCF_P_L1_no_2ecpri}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    MMW5 Rus Power Off    RU_INDEX=${case101_TDD_RU}
    Sleep    4m
    # Step2: power on 2 eCPRI RU, check BTS Status
    MMW5 Rus Power On    RU_INDEX=${case101_TDD_RU}
    Sleep    4m
    Verify BTS All Cells Status Is Normal State
    # Step3: add 2 eCPRI RU and related TDD NECELL
    coam.perform_delta_recommissioning    delta_file=${101_ADD_2eCPRI_RU}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    20s    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    # Step4: make call on any of TDD NRCELL and FDD LNCELL
    LTE UE Attach And Verify DL Throughput
    coam.perform_delta_recommissioning    delta_file=${BARRY_CELLS_101}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    Wait Until Keyword Succeeds    3x    15s    SISO Common L3 CALL
    # Step5: remove TDD related RU and NRCELL
    coam.perform_delta_recommissioning    delta_file=${101_DELETE_NRRAT}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    20s    CI_commssion.Verify all cells should be Online
    [Teardown]    Run Keywords
    ...    MMW5 Common Case Teardown    AND
    ...    SISO_Teardown_power_on_and_load_full_commission    ${case101_TDD_RU}    ${SCF_P_L1}


CB010578-D_106_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Documentation]    Author: echo.xu@nokia-sbell.com
    COAM Commission with scf file    ${scf_P_L2}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    Sleep    600s
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_2.0

CB010578-D_107_Manual_SiSo_SM_RF_Module_lock_unlock_with_L3_call
    [Documentation]    Author: echo.xu@nokia-sbell.com
    COAM Commission with scf file    ${scf_P_L2}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    Manual_SiSo_SM_single_RF_Module_lock_unlock_LTE_1.0    ru_index=10

    coam.perform_delta_recommissioning    delta_file=${BARRY_107_CPRI}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Manual_SiSo_SM_single_RF_Module_lock_unlock_LTE_1.0    ru_index=4

    coam.perform_delta_recommissioning    delta_file=${BARRY_107_eCPRI}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Manual_SiSo_SM_single_RF_Module_lock_unlock_NR_1.0    ru_index=1

CB010578-D_110_RAT_change_between_NRTDD6cells_single_duplex mode_to_NRFDD12cells_NRTDD6cells_concurrent_mode
    [Documentation]    Author: echo.xu@nokia-sbell.com
    COAM Commission with scf file    ${SCF_case110_full}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    COAM Commission with scf file    ${SCF_N2_NO_2RU}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    ${cur_scf2}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    COAM Commission with scf file    ${SCF_P_N2_NO_TDD}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    ${cur_scf3}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf}    ${cur_scf2}
    ...    ${no_use}    ${110_ADD_2RU}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf}    ${cur_scf3}
    ...    ${110_DELETE_TDDNR}    ${no_use}

    # Step1:load case110 step1 scf, change BBmode
    COAM Commission with scf file    ${SCF_N2_NO_2RU}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    coam.perform_delta_recommissioning    delta_file=${modify_BBType_1}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State

    # Step2~3: delta add 2RU and related cell, make call
    coam.perform_delta_recommissioning    delta_file=${110_ADD_2RU}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    Wait Until Keyword Succeeds    3x    15s    SISO Common L3 CALL

    # Step4~6: delta delete NRTDD, make call. change bbmod
    coam.perform_delta_recommissioning    delta_file=${110_DELETE_TDDNR}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    Wait Until Keyword Succeeds    3x    15s    SISO Common L3 CALL
    coam.perform_delta_recommissioning    delta_file=${modify_BBType_2}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State

CB010578-D_116_SiSo_Online_Cell_Addition_NR_cell_lock_unlock_administrative_state_change_from_GUI
    [Documentation]    Author: echo.xu@nokia-sbell.com
    COAM Commission with scf file    ${scf_P_N2}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    COAM Commission with scf file    ${SCF_N2_NO_2TDDRU}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    ${cur_scf2}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    generate_delta_jsons_from_3_scf    ${cur_scf}    ${cur_scf}    ${cur_scf2}
    ...    ${no_use}    ${116_ADD_2RU}
    # Step1:load case116 step1 scf, power off 2RU, then do delta commission
    COAM Commission with scf file    ${SCF_N2_NO_2TDDRU}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    MMW5 Rus Power Off    RU_INDEX=${case101_TDD_RU}
    Sleep    4m
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=10
    coam.perform_delta_recommissioning    delta_file=${116_ADD_2RU}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Sleep    16m
    FOR    ${idx}    IN   @{case101_TDD_RU}
        Wait Until Keyword Succeeds    180s    30s    Verify Specified Object Alarm Exist
        ...    fault_id=10    fault_name=No connection to unit    object_name=RMOD-${idx}
    END
    # Step2~3：connect 2 RU
    MMW5 Rus Power On    RU_INDEX=${case101_TDD_RU}
    Sleep    4m
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    Manual_SiSo_SM_NR_cell_lock_unlock_administrative_state_change_from_GUI_1.0
    [Teardown]    Run Keywords    MMW5 Common Case Teardown    AND
    ...    SISO_Teardown_power_on_and_load_full_commission    ${case101_TDD_RU}    ${scf_P_N2}
