# # @Time    : 2023/7/5 14:39
# # @Author  : Jian.1.Chen
# # @Email   : jian.1.chen@nokia-sbell.com
# # @File    : CB009487_G.robot
# # @Software: PyCharm
# # @Doc     : Some Description
# *** Settings ***
# Documentation
# ...    author: Chen Jian
# ...    contact: jian.1.chen@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# ...    Feature CB009487_G
# 
# Suite Setup         SISO Coam Suite Setup
# Suite Teardown      Run Keywords    robot_common_operations.Common Case Teardown
# ...                 AND    Connect to gnb coam via ssl
# ...                 AND    COAM Commission with scf file    ${SCF_COMMON_9487D_FEADEP}    
# ...                 is_pdl_checking_needed=${False}    timeout=900
# ...                 AND    SISO Coam Suite Teardown
# Test Setup          MMW5 Common Case Setup
# Test Teardown       MMW5 Common Case Teardown
# Force Tags          CRT_TRUNK    PY36
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
# 
# *** Variables ***
# ${if_commissioning}         False
# ${SCF_COMMON_9487D_FEADEP}      ${CURDIR}/SCF_COMMON_9487D_FeaDep.xml
# ${SCF_COMMON_9487G}             ${CURDIR}/SCF_COMMON_9487G.xml
# ${BARRY_NR_CELLS}               ${CURDIR}/BARRY_6_NR_CELLS.json
# ${BARRY_LTE_CELLS}              ${CURDIR}/BARRY_6_LTE_CELLS.json
# 
# *** Test Cases ***
# [1]CB009487-5G-G_301_G1_E2E_system_setup_with L3 call verified
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    https://rep-portal.ext.net.nokia.com/qc/instance/details/32469653/
#     [Tags]    004
#     COAM Commission with scf file    ${SCF_COMMON_9487G}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
# 
#     coam.perform_delta_recommissioning    delta_file=${BARRY_NR_CELLS}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# 
#     Modify Parameter On ENB With Activate    dist_name=MRBTS-2032/LNBTS-10444/LNCEL-25
#     ...    parameter=administrativeState    value=locked
# 
#     Wait Until Keyword Succeeds    10x    15s    LTE UE Attach And Verify DL Throughput
# 
#     coam.perform_delta_recommissioning    delta_file=${BARRY_LTE_CELLS}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#     Wait Until Keyword Succeeds    5x    15s    SISO Common L3 CALL
# 
# [1][1.0] Manual_SiSo_SM_NR_cell_lock_unlock_administrative_state_change_from_GUI
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    https://rep-portal.ext.net.nokia.com/qc/instance/details/32469681/
#     [Tags]    001
#     COAM Commission with scf file    ${SCF_COMMON_9487G}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
#     coam.perform_delta_recommissioning    delta_file=${BARRY_LTE_CELLS}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# 
#     Manual_SiSo_SM_NR_cell_lock_unlock_administrative_state_change_from_GUI_1.0
# 
# [1][2.0] Manual_SiSo_SM_BTS_Block_Site
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    https://rep-portal.ext.net.nokia.com/qc/instance/details/32469684/
#     [Tags]    002
#     COAM Commission with scf file    ${SCF_COMMON_9487G}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
# 
#     coam.perform_delta_recommissioning    delta_file=${BARRY_LTE_CELLS}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# 
#     Manual_SiSo_SM_BTS_Block_Site_2.0    ul_tp=10M    dl_tp=30M    shake_tp=10
# 
# [1][2.0] Manual_SiSo_SM_NR_RAT_reset
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    https://rep-portal.ext.net.nokia.com/qc/instance/details/32469682/
#     [Tags]    003
#     COAM Commission with scf file    ${SCF_COMMON_9487G}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
# 
#     coam.perform_delta_recommissioning    delta_file=${BARRY_LTE_CELLS}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#     Manual_SiSo_SM_NR_RAT_reset_2.0    delta_ul_tp=50    delta_dl_tp=50
