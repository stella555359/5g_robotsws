# # @Time    : 2022/9/7 11:30
# # @Author  : Jian.1.Chen
# # @Email   : jian.1.chen@nokia-sbell.com
# # @File    : CB008253_1978.robot
# # @Software: PyCharm
# # @Doc     : Some Description
# *** Settings ***
# Documentation
# ...    author: Chen Jian
# ...    contact: jian.1.chen@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# ...    Feature CB008253-5G-A-B2_ST_SiSo
# 
# Resource    CB008253_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND     CI_interface.Common Suite Setup
# Suite Teardown       robot_common_operations.Common Suite Teardown
# Test Setup           Run Keywords    robot_common_operations.Common Case Setup
# ...    AND     Connect to gnb coam via ssl
# ...    AND     CB008253 Generate Delta Json Precondition
# Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown
# ...    AND     Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# Force Tags      CRT_23R1    CRT_TRUNK    PY36
# 
# *** Variables ***
# ${if_commissioning}    True
# ${RU2_SFP_DISTNAME}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-3/SFP-2/LANE-1
# ${RU3_SFP_DISTNAME}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-3/SFP-1/LANE-1
# ${REMOVE_RU2_DELTA}    ${CURDIR}/${MRBTS_ID}_DELETE_RU2_DELTA.json
# ${CREATE_RU2_DELTA}    ${CURDIR}/${MRBTS_ID}_CREATE_RU2_DELTA.json
# ${REMOVE_RU3_DELTA}    ${CURDIR}/${MRBTS_ID}_DELETE_RU3_DELTA.json
# ${CREATE_RU3_DELTA}    ${CURDIR}/${MRBTS_ID}_CREATE_RU3_DELTA.json
# ${SUITE_LOG_PATH}    /home/ute/MMW_SG5
# 
# *** Test Cases ***
# CB008253_B_211_Add_ABIO_and_ecpri_TDD_RU_then_do_delta_commision_in_FR2_ASIB_ABIL_ABIO
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
#     ...    parameter=actCellAutoRecalculation    value=Autonomous
#     Disconnect RU From BBMOD Via SFP    ru_sfp_distname=${RU2_SFP_DISTNAME}
#     Disconnect RU From BBMOD Via SFP    ru_sfp_distname=${RU3_SFP_DISTNAME}
#     Control BBMOD Power Switch    power_status=1    slot=6
#     coam.perform_delta_recommissioning    delta_file=${REMOVE_RU3_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#     coam.reset_site    connection=GNB_OAM
#     Wait Until Keyword Succeeds    20min    15s    CI_commssion.Verify all cells should be Online
#     Control BBMOD Power Switch    power_status=0    slot=6
#     Sleep    600
#     #Connect RU To BBMOD Via SFP    ru_sfp_distname=${RU2_SFP_DISTNAME}
#     #Connect RU To BBMOD Via SFP    ru_sfp_distname=${RU3_SFP_DISTNAME}
#     coam.perform_delta_recommissioning    delta_file=${CREATE_RU3_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#     Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
#     ${nr_cell_identity}    Get NR Cell Identity Via Index "41"
#     Enable BTS NR Cell Via ENB Cell LnRelGnbCellId    nr_cell_id=${nr_cell_identity}    lncel_id=3
#     UE Attach And Check Throughput With Detach    global_cell_id=41
#     ...    ul_tp=100M    ul_tp_threshold=1
#     ...    dl_tp=100M    dl_tp_threshold=1    attach_mode=NSA
# 
# CB008253_B_212_Add_ecpri_TDD_RU_then_do_delta_commision_in_FR2_ASIB_ABIL_ABIO_with_actCellAutoRecalculation=2_from_NetAct
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c212
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
#     ...    parameter=actCellAutoRecalculation    value=Autonomous
#     Disconnect RU From BBMOD Via SFP    ru_sfp_distname=${RU2_SFP_DISTNAME}
#     coam.perform_delta_recommissioning    delta_file=${REMOVE_RU2_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#     coam.reset_site    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#     Connect RU To BBMOD Via SFP    ru_sfp_distname=${RU2_SFP_DISTNAME}
#     coam.perform_delta_recommissioning    delta_file=${CREATE_RU2_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#     Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
#     ${nr_cell_identity}    Get NR Cell Identity Via Index "31"
#     Enable BTS NR Cell Via ENB Cell LnRelGnbCellId    nr_cell_id=${nr_cell_identity}    lncel_id=3
#     UE Attach And Check Throughput With Detach    global_cell_id=31
#     ...    ul_tp=100M    ul_tp_threshold=1
#     ...    dl_tp=100M    dl_tp_threshold=1    attach_mode=NSA
