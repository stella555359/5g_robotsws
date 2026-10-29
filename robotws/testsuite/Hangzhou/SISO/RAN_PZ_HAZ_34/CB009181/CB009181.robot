*** Settings ***
Documentation     author:              Li Xudong
...               contact:             xudong.1.li@nokia-sbell.com
...               squad group:         mmW_05
...               feature :            CB009181
...               UE:
...               DATE:                2023/6/1

Suite Setup     SISO Coam Suite Setup
Suite Teardown    Run Keywords    Connect to gnb coam via ssl
...               AND    COAM Commission with scf file    ${COMMON_9181_SCF_FEADEP}
...               is_pdl_checking_needed=${False}    timeout=900
...               AND    SISO Coam Suite Teardown

Test Setup      Run Keywords    robot_common_operations.Common Case Setup
...    AND     Connect to gnb coam via ssl
...    AND    CB009181 Generate Delta Json Precondition
...    AND    Lock Unlock ENB Cell via Coam    lncel_id=${31}    value=locked

Test Teardown    Run Keywords    robot_common_operations.Common Case Teardown
...               AND    MMW5 Common Case Teardown

Force Tags      CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009181/CB009181_keywords.robot

*** Variables ***
${if_commissioning}             False
${COMMON_9181_SCF_FEADEP}       ${CURDIR}/resource/COMMON_9181_FeaDep.xml
${case201_json}                 ${CURDIR}/delete_TDD_RUS_and_Cells.json
@{case201_power_and_off_TDD_rus}    ${3}    ${4}    ${5}
@{case202_power_and_off_FDD_rus}    ${1}    ${2}    ${6}
${case202_Add_AllFDD_RUs}                         ${CURDIR}/${MRBTS_ID}_Add_AllFDD_RUs.json
${case202_Add_AllFDD_Cells}                       ${CURDIR}/${MRBTS_ID}_Add_AllFDD_Cells.json
${case202_delete_3FDD_RUS_and_Related_Cells}      ${CURDIR}/delete_FDD_RUS_and_Cells.json
${SCF_202}                      ${CURDIR}/resource/202.xml
${202_DELETE_FDD}               ${CURDIR}/resource/202_DELETE_FDD.json
${202_ADD_FDD_RUS}              ${CURDIR}/resource/202_ADD_FDD_RUS.json
${202_ADD_FDD_CELLS}            ${CURDIR}/resource/202_ADD_FDD_CELLS.json
${202_WITHOUT_FDD}              ${CURDIR}/resource/202_WITHOUT_FDD.xml
${202_WITHOUT_FDD_CELLS}        ${CURDIR}/resource/202_WITHOUT_FDD_CELLS.xml
${NO_USE}                       ${CURDIR}/resource/NO_USE.json

*** Test Cases ***
#[1]CB009181_D_201_RAT_change_between_NRFDD9cells_single_duplex mode_to_NRFDD9cells_NRTDD4cells_concurrent_mode
#    [Documentation]    Author: xudong.1.li@nokia-sbell.com
#    [Tags]    c201
#    Set Test Variable    ${X2_link_shutdown_time}    30
#    Initialize CB009181 Case Set up    delta_file=${case201_json}    RU_INDEX=${case201_power_and_off_TDD_rus}
#    Modify Parameter On BTS With Activate Validate Relation ERR    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
#    ...    parameter=actCellAutoRecalculation    value=NoCellRecalculation
#    Modify Parameter On BTS With Activate Validate Relation ERR    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
#    ...    parameter=bbmodBoardConfigType    value=Auto
#    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
#    MMW5 Rus Power On    RU_INDEX=${case201_power_and_off_TDD_rus}
#    sleep   120s
#    CI_interface.Common Suite Setup
#    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
#    Wait Until Keyword Succeeds    10min    20s    COAM Check X2 link status from GNB
#    ${cell_id_list}    Get All Cell Id
#    ${other_cells_TDD}  Get Other Ids    id_list=${cell_id_list}    given_id=51
#    Lock cells or groups and check status  lock_list=${other_cells_TDD}  is_group=${False}  check_alarm=${False}
#    ...    gnb_type='SA+NSA'
#    Reset UE MMW5
#    SISO Common L3 CALL    cell_id=11    actCarrierAggregation=False
#    Unlock cells or groups and check status    lock_list=${other_cells_TDD}   is_group=${False}   gnb_type='SA+NSA'
#    coam.perform_delta_recommissioning    delta_file=${case201_json}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
#    Wait Until Keyword Succeeds    10min    20s    COAM Check X2 link status from GNB
#    ${other_cells_FDD}  Get Other Ids    id_list=${cell_id_list}    given_id=2
#    Lock cells or groups and check status  lock_list=${other_cells_FDD}  is_group=${False}  check_alarm=${False}
#    ...    gnb_type='SA+NSA'
#    Reset UE MMW5
#    SISO Common L3 CALL    cell_id=1    actCarrierAggregation=False
#    Unlock cells or groups and check status    lock_list=${other_cells_FDD}   is_group=${False}   gnb_type='SA+NSA'

[1]CB009181_D_202_RAT_change_between_NRTDD4cells_single_duplex mode_to_NRFDD9cells_NRTDD4cells_concurrent_mode
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Tags]    c202
    COAM Commission with scf file    ${SCF_202}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    #Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    #Wait Until Keyword Succeeds    10min    20 sec    COAM Check X2 link status from GNB
    #Set Test Variable    ${X2_link_shutdown_time}    30
    #Initialize CB009181 Case Set up    delta_file=${case202_delete_3FDD_RUS_and_Related_Cells}
    #...    RU_INDEX=${case202_power_and_off_FDD_rus}
    #Modify Parameter On BTS With Activate Validate Relation ERR    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    #...    parameter=actCellAutoRecalculation    value=NoCellRecalculation
    #Modify Parameter On BTS With Activate Validate Relation ERR    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    #...    parameter=bbmodBoardConfigType    value=NRTDD

    generate_delta_jsons_from_3_scf    ${cur_scf}    ${202_WITHOUT_FDD_CELLS}    ${202_WITHOUT_FDD}
    ...    ${NO_USE}    ${202_ADD_FDD_RUS}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${SCF_202}    ${202_WITHOUT_FDD}
    ...    ${202_DELETE_FDD}    ${NO_USE}
    generate_delta_jsons_from_3_scf    ${cur_scf}    ${SCF_202}    ${202_WITHOUT_FDD_CELLS}
    ...    ${NO_USE}    ${202_ADD_FDD_CELLS}

    coam.perform_delta_recommissioning    delta_file=${202_DELETE_FDD}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    Wait Until Keyword Succeeds    10min    20 sec    COAM Check X2 link status from GNB
    Set Test Variable    ${X2_link_shutdown_time}    30
    Modify Parameter On BTS With Activate Validate Relation ERR    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...    parameter=bbmodBoardConfigType    value=NRTDD

    #step1
    MMW5 Rus Power On    RU_INDEX=${case202_power_and_off_FDD_rus}
    sleep  120s
    #step2
    Modify Parameter On BTS With Activate Validate Relation ERR    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...    parameter=bbmodBoardConfigType    value=NRFDD_NRTDD
    Wait Until Keyword Succeeds    20min    20s    CI_commssion.Verify all cells should be Online

    #step3 add 3 FDD ru
    coam.perform_delta_recommissioning    delta_file=${202_ADD_FDD_RUS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    Verify BTS RUs Status Is Normal State

    #coam.perform_delta_recommissioning    delta_file=${case202_Add_AllFDD_RUs}
    #...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    #Wait until keyword succeeds    20min    20S    MMW5 Check GNB RU status Enabled    connection=GNB_OAM

    #step4 add 9 FDD cells
    coam.perform_delta_recommissioning    delta_file=${202_ADD_FDD_CELLS}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online

    #coam.perform_delta_recommissioning    delta_file=${case202_Add_AllFDD_Cells}
    #...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
    #Wait Until Keyword Succeeds    20min    20s    CI_commssion.Verify all cells should be Online

    #step5 make a call
    ${cell_id_list}    Get All Cell Id
    ${other_cells_FDD}  Get Other Ids    id_list=${cell_id_list}    given_id=2
    Lock cells or groups and check status  lock_list=${other_cells_FDD}  is_group=${False}  check_alarm=${False}
    ...    gnb_type='SA+NSA'
    Reset UE MMW5
    SISO Common L3 CALL    cell_id=2    actCarrierAggregation=False
    Unlock cells or groups and check status    lock_list=${other_cells_FDD}   is_group=${False}   gnb_type='SA+NSA'

    #step6 delete 3 FDD ru and all FDD cells
    coam.perform_delta_recommissioning    delta_file=${202_DELETE_FDD}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

    #coam.perform_delta_recommissioning    delta_file=${case202_delete_3FDD_RUS_and_Related_Cells}
    #...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM

[1][2.1] General_SiSo_Cell_block_and_unblock
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Tags]    c204
    COAM Commission with scf file    ${SCF_202}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online

    General_SiSo_Cell_block_and_unblock_2.1
