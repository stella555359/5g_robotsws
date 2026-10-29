# @Time    : 2023/9/14 10:32
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB009493_A7.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB009493_A7

Suite Setup         SISO Coam Suite Setup
Suite Teardown      Run Keywords    Connect to gnb coam via ssl
...                 AND    COAM Commission with scf file    ${COMMON_9181_SCF_FEADEP}
...                 is_pdl_checking_needed=${False}    timeout=900
...                 AND    SISO Coam Suite Teardown
Test Setup          MMW5 Common Case Setup
Test Teardown       MMW5 Common Case Teardown

Force Tags          CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009493/CB009493_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Library     taf.selenium.sbts    WITH NAME    selenium_sbts


*** Variables ***
${if_commissioning}             False
${COMMON_9181_SCF_FEADEP}       ${CURDIR}/../CB009181/resource/COMMON_9181_FeaDep.xml
${SCF}                          ${CURDIR}/2022_9493_A7.xml
${delete_TDD_And_FDD_Cells}     ${CURDIR}/delete_TDD_And_FDD_Cells.json

*** Test Cases ***
CB009493-5G-A_106_24R1_N_CB009493_A7_Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Log To Console    All of the TCs in this robot are optimized
#    COAM Commission with scf file    ${SCF}    is_pdl_checking_needed=${False}    timeout=900
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#    Manual_SiSo_SM_BTS_Site_Reset_2.0
#
#CB009493-5G-A_107_24R1_N_CB009493_A7_Manual_SiSo_SM_NR_cell_lock_unlock_addition_deletion_administrative_state_change_from_GUI
#    [Documentation]    Author: jian.1.chen@nokia-sbell.com
#    COAM Commission with scf file    ${SCF}    is_pdl_checking_needed=${False}    timeout=900
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#    Set Test Variable    ${X2_link_shutdown_time}        30
#    Lock Unlock ENB Cell via Coam    lncel_id=${31}    value=locked
#    MMW5_Manual_SiSo_Online_Cell_addition_deletion_and_L3call    addition_deletion_cell=${3}    iperf_type=via_command
#    ${cell_id_list}    Get All Cell Id
#    FOR    ${cell}    IN    @{cell_id_list}
#        perform_cell_lock_via_admin    cell_id=${cell}   lock_timeout=120
#        Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${cell}
#        Log To Console    \n----------lock cell${cell} success
#        perform_cell_unlock_via_admin    cell_id=${cell}       lock_timeout=120
#        Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${cell}
#        Log To Console    \n----------unlock cell${cell} success
#    END
#    Lock and Unlock all Cells or Groups  lock_list=${cell_id_list}  is_group=${False}
#    SISO Common L3 CALL    iperf_type=via_command
#    coam.perform_delta_recommissioning    delta_file=${delete_TDD_And_FDD_Cells}
#    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#
#CB009493-5G-A_111_24R1_N_CB009493_A7_Manual_SiSo_CM_Recommissioning
#    [Documentation]    Author: jian.1.chen@nokia-sbell.com
#    COAM Commission with scf file    ${SCF}    is_pdl_checking_needed=${False}    timeout=900
#    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#    Manual_SiSo_CM_Recommissioning_2.0
