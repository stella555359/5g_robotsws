# # @Time    : 2023/8/25 15:51
# # @Author  : Jian.1.Chen
# # @Email   : jian.1.chen@nokia-sbell.com
# # @File    : CB009487-D.robot.robot
# # @Software: PyCharm
# # @Doc     : Some Description
# *** Settings ***
# Documentation
# ...    author: Chen Jian
# ...    contact: jian.1.chen@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# ...    Feature CB009487_D
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
# ${if_commissioning}     False
# ${SCF_COMMON_9487D_FEADEP}      ${CURDIR}/SCF_COMMON_9487D_FeaDep.xml
# ${SCF_COMMON_9487D}             ${CURDIR}/SCF_COMMON_9487D.xml
# ${NOT_BARRY_NRCELL_1}           ${CURDIR}/NOT_BARRY_NRCELL_1.json
# ${NOT_BARRY_NRCELL_3}           ${CURDIR}/NOT_BARRY_NRCELL_3.json
# ${NOT_BARRY_NRCELL_5}           ${CURDIR}/NOT_BARRY_NRCELL_5.json
# ${NOT_BARRY_NRCELL_7}           ${CURDIR}/NOT_BARRY_NRCELL_7.json
# ${NOT_BARRY_NRCELL_89}          ${CURDIR}/NOT_BARRY_NRCELL_89.json
# 
# *** Test Cases ***
# [1]CB009487-5G-D_101_D1_E2E_system_setup_with L3 call verified
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    https://rep-portal.ext.net.nokia.com/qc/instance/details/32469148/
#     ...    Init Define: 2023/08/25 15:59
#    # Precondition
#     COAM Commission with scf file    ${SCF_COMMON_9487D}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
# 
#     # Step 1: tcp on AEHC cell 1
#     coam.perform_delta_recommissioning    delta_file=${NOT_BARRY_NRCELL_1}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#     UE Attach And Check Single Cell TCP Throughput    global_cell_id=1
#     ...    ul_tp_threshold=5    dl_tp_threshold=5    attach_mode=SA
# 
#     # Step 2: tcp on AZHL cell 3
#     coam.perform_delta_recommissioning    delta_file=${NOT_BARRY_NRCELL_3}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#     UE Attach And Check Single Cell TCP Throughput    global_cell_id=3
#     ...    ul_tp_threshold=5    dl_tp_threshold=5    attach_mode=SA
# 
#     # Step 3: tcp on AWHQU cell 5
#     coam.perform_delta_recommissioning    delta_file=${NOT_BARRY_NRCELL_5}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#     UE Attach And Check Single Cell TCP Throughput    global_cell_id=5
#     ...    ul_tp_threshold=5    dl_tp_threshold=5    attach_mode=SA
# 
#     # Step 2: tcp on AHQK cell 7
#     coam.perform_delta_recommissioning    delta_file=${NOT_BARRY_NRCELL_7}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#     UE Attach And Check Single Cell TCP Throughput    global_cell_id=7
#     ...    ul_tp_threshold=5    dl_tp_threshold=5    attach_mode=SA
# 
#     # Step 3: tcp on APHG cell 8
#     coam.perform_delta_recommissioning    delta_file=${NOT_BARRY_NRCELL_89}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#     UE Attach And Check Single Cell TCP Throughput    global_cell_id=9
#     ...    ul_tp_threshold=5    dl_tp_threshold=5    attach_mode=SA
# 
# [1][1.0] Manual_SiSo_REC_hot_remove_insert_RU_links
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    https://rep-portal.ext.net.nokia.com/qc/instance/details/32469153/
#     ...    Init Define: 2023/08/25 16:00
#     COAM Commission with scf file    ${SCF_COMMON_9487D}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
# 
#     Manual_SiSo_REC_hot_remove_insert_RU_links_1.0
# 
# [1][2.0] Manual_SiSo_SM_BTS_Site_Reset
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ...    https://rep-portal.ext.net.nokia.com/qc/instance/details/32469154/
#     ...    Init Define: 2023/08/25 16:01
#     COAM Commission with scf file    ${SCF_COMMON_9487D}    is_pdl_checking_needed=${False}    timeout=900
#     Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
# 
#     Manual_SiSo_SM_BTS_Site_Reset_2.0
# 
