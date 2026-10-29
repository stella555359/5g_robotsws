# # @Time    : 2022/9/7 11:26
# # @Author  : Jian.1.Chen
# # @Email   : jian.1.chen@nokia-sbell.com
# # @File    : CB008253_2004.robot
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
# Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
# 
# Suite Setup          CI_interface.Common Suite Setup
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
# ${ADD_CELLSCALCULATIONREQ_DELTA_PATH}    ${CURDIR}/ADD_CELLSCALCULATIONREQ.json
# ${DELETE_CELLSCALCULATIONREQ_DELTA_PATH}    ${CURDIR}/DELETE_CELLSCALCULATIONREQ.json
# ${REMOVE_RU2_DELTA}    ${CURDIR}/${MRBTS_ID}_DELETE_RU2_DELTA.json
# ${CREATE_RU2_DELTA}    ${CURDIR}/${MRBTS_ID}_CREATE_RU2_DELTA.json
# ${REMOVE_RU3_DELTA}    ${CURDIR}/${MRBTS_ID}_DELETE_RU3_DELTA.json
# ${CREATE_RU3_DELTA}    ${CURDIR}/${MRBTS_ID}_CREATE_RU3_DELTA.json
# ${REMOVE_RU5_DELTA}    ${CURDIR}/${MRBTS_ID}_DELETE_RU5_DELTA.json
# ${CREATE_RU5_DELTA}    ${CURDIR}/${MRBTS_ID}_CREATE_RU5_DELTA.json
# ${REMOVE_BB2_DELTA}    ${CURDIR}/${MRBTS_ID}_DELETE_BB2_DELTA.json
# ${CREATE_BB2_DELTA}    ${CURDIR}/${MRBTS_ID}_CREATE_BB2_DELTA.json
# ${REMOVE_BB3_DELTA}    ${CURDIR}/${MRBTS_ID}_DELETE_BB3_DELTA.json
# ${CREATE_BB3_DELTA}    ${CURDIR}/${MRBTS_ID}_CREATE_BB3_DELTA.json
# ${CELLS_NUMBER_EXCEPT_RU2}    4
# ${Active_SW_version}    SBTS23R1_ENB_9999_221020_000006
# ${SUITE_LOG_PATH}    /home/ute/MMW_SG5
# &{CROSS_PORT_SETTING_ON_201}    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[2].switch_module.module_no}=4
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[3].switch_module.module_no}=3
# &{CROSS_PORT_SETTING_OFF_201}    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[2].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[3].switch_module.module_no}=0
# &{CROSS_PORT_SETTING_ON_202}    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[0].switch_module.module_no}=2
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[1].switch_module.module_no}=1
# &{CROSS_PORT_SETTING_OFF_202}    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[0].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[1].switch_module.module_no}=0
# &{CROSS_PORT_SETTING_ON_203_205}    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[4].switch_module.module_no}=6
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[5].switch_module.module_no}=5
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[6].switch_module.module_no}=8
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[7].switch_module.module_no}=7
# &{CROSS_PORT_SETTING_OFF_203_205}    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[4].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[5].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[6].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[7].switch_module.module_no}=0
# &{CROSS_PORT_SETTING_ON_204}    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[0].switch_module.module_no}=2
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[1].switch_module.module_no}=1
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[2].switch_module.module_no}=4
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[3].switch_module.module_no}=3
# &{CROSS_PORT_SETTING_OFF_204}    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[0].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[1].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[2].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[3].switch_module.module_no}=0
# &{CROSS_PORT_SETTING_ON_301_1}    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[2].switch_module.module_no}=4
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[3].switch_module.module_no}=3
# &{CROSS_PORT_SETTING_ON_301_2}    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[4].switch_module.module_no}=6
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[5].switch_module.module_no}=5
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[6].switch_module.module_no}=8
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[7].switch_module.module_no}=7
# &{CROSS_PORT_SETTING_OFF_301}    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[2].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[3].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[4].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[5].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[6].switch_module.module_no}=0
# ...    ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[7].switch_module.module_no}=0
# 
# *** Test Cases ***
# CB008253_B_201_Delta_commision_then_add_ecpri_TDD_RU_in_FR1_primary_core_ASIK_ABIL
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
#     ...    parameter=actCellAutoRecalculation    value=OnOperatorDemand
#     Initialize Configuration Via Disconnect Optical Switch    cross_port_setting=${CROSS_PORT_SETTING_OFF_201}
#     ...    delta_file=${REMOVE_RU3_DELTA}
#     coam.perform_delta_recommissioning    delta_file=${CREATE_RU3_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#     Sleep    50s
#     Set Optical Switch Channels And Verify Status    cross_port_setting=${CROSS_PORT_SETTING_ON_201}
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-2004/NRBTS-10897/NRCELL-1    parameter=administrativeState
#     ...    value=Locked
#     ${nr_cell_identity}    Get NR Cell Identity Via Index "3"
#     Enable BTS NR Cell Via ENB Cell LnRelGnbCellId    nr_cell_id=${nr_cell_identity}    lncel_id=2
#     Wait until keyword succeeds    10min    20 sec    COAM Check X2 link status from GNB    connection=GNB_OAM
#     Wait Until Keyword Succeeds    3x    15s    UE Attach And Check Throughput With Detach    global_cell_id=3
#     ...    ul_tp=50M    ul_tp_threshold=1
#     ...    dl_tp=50M    dl_tp_threshold=1    attach_mode=NSA
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-2004/NRBTS-10897/NRCELL-1    parameter=administrativeState
#     ...    value=Unlocked
# 
# CB008253_B_202_Add_ecpri_TDD_RU_then_do_delta_commision_in_FR1_primary_core_ASIK_ABIL
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c202
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
#     ...    parameter=actCellAutoRecalculation    value=Autonomous
#     Initialize Configuration Via Disconnect Optical Switch    cross_port_setting=${CROSS_PORT_SETTING_OFF_202}
#     ...    delta_file=${REMOVE_RU2_DELTA}
#     Set Optical Switch Channels And Verify Status    cross_port_setting=${CROSS_PORT_SETTING_ON_202}
#     Sleep    50s
#     coam.perform_delta_recommissioning    delta_file=${CREATE_RU2_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#     Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-2004/NRBTS-10897/NRCELL-3    parameter=administrativeState
#     ...    value=Locked
#     ${nr_cell_identity}    Get NR Cell Identity Via Index "1"
#     Enable BTS NR Cell Via ENB Cell LnRelGnbCellId    nr_cell_id=${nr_cell_identity}    lncel_id=2
#     Wait until keyword succeeds    10min    20 sec    COAM Check X2 link status from GNB    connection=GNB_OAM
#     UE Attach And Check Throughput With Detach    global_cell_id=1
#     ...    ul_tp=50M    ul_tp_threshold=1
#     ...    dl_tp=50M    dl_tp_threshold=1    attach_mode=NSA
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-2004/NRBTS-10897/NRCELL-3    parameter=administrativeState
#     ...    value=Unlocked
# 
# CB008253_B_203_Add_ecpri_TDD_RU_then_do_delta_commision_in_FR1_second_core_ASIK_ABIL
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c203
# #    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
#     ...    parameter=actCellAutoRecalculation    value=NoCellRecalculation
#     Initialize Configuration Via Disconnect Optical Switch    cross_port_setting=${CROSS_PORT_SETTING_OFF_203_205}
#     ...    delta_file=${REMOVE_RU5_DELTA}
#     Set Optical Switch Channels And Verify Status    cross_port_setting=${CROSS_PORT_SETTING_ON_203_205}
#     coam.perform_delta_recommissioning    delta_file=${CREATE_RU5_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# #    Wait Until Keyword Succeeds    15min    15s    Verify BTS Alarm Exist    fault_id=4001    fault_name=BTS reset required
# #    coam.reset_site    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#     ${nr_cell_identity}    Get NR Cell Identity Via Index "4"
#     Enable BTS NR Cell Via ENB Cell LnRelGnbCellId    nr_cell_id=${nr_cell_identity}    lncel_id=2
#     Wait until keyword succeeds    10min    20 sec    COAM Check X2 link status from GNB    connection=GNB_OAM
#     UE Attach And Check Throughput With Detach    global_cell_id=4
#     ...    ul_tp=50M    ul_tp_threshold=1
#     ...    dl_tp=50M    dl_tp_threshold=1    attach_mode=NSA
# 
# CB008253_B_204_Add_ABIL_and_TDD_ecpri_RUs_then_do_delta_commision_in_FR1_primary_core_ASIK_ABIL
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
#     ...    parameter=actCellAutoRecalculation    value=OnOperatorDemand
#     Initialize Configuration Via Disconnect Optical Switch And Disconnect BB    cross_port_setting=${CROSS_PORT_SETTING_OFF_204}
#     ...    delta_file=${REMOVE_BB2_DELTA}    slot=2
#     Control BBMOD Power Switch    power_status=0    slot=2
#     Set Optical Switch Channels And Verify Status    cross_port_setting=${CROSS_PORT_SETTING_ON_204}
#     coam.perform_delta_recommissioning    delta_file=${CREATE_BB2_DELTA}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#     Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-2004/NRBTS-10897/NRCELL-1    parameter=administrativeState
#     ...    value=Locked
#     ${nr_cell_identity}    Get NR Cell Identity Via Index "3"
#     Enable BTS NR Cell Via ENB Cell LnRelGnbCellId    nr_cell_id=${nr_cell_identity}    lncel_id=2
#     Wait until keyword succeeds    10min    20 sec    COAM Check X2 link status from GNB    connection=GNB_OAM
#     Wait Until Keyword Succeeds    3x    15s    UE Attach And Check Throughput With Detach    global_cell_id=3
#     ...    ul_tp=50M    ul_tp_threshold=1
#     ...    dl_tp=50M    dl_tp_threshold=1    attach_mode=NSA
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-2004/NRBTS-10897/NRCELL-1    parameter=administrativeState
#     ...    value=Unlocked
# 
# #CB008253_B_205_Delta_commision_then_add_ABIL_and_TDD_ecpri_RU_in_FR1_second_core_ASIK_ABIL
# #    [Documentation]    Author:jian.1.chen@nokia-sbell.com
# #    [Tags]    c205
# #    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
# #    ...    parameter=actCellAutoRecalculation    value=Autonomous
# #    coam.perform_delta_recommissioning    delta_file=${REMOVE_BB3_DELTA}
# #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
# #
# #    Initialize Configuration Via Disconnect Optical Switch And Disconnect BB    cross_port_setting=${CROSS_PORT_SETTING_OFF_203_205}
# #    ...    delta_file=${REMOVE_BB3_DELTA}    slot=6
# #     manual plug out BB3
# #
# #    Set Optical Switch Channels And Verify Status    cross_port_setting=${CROSS_PORT_SETTING_OFF_203_205}
# #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# #    coam.reset_site    connection=GNB_OAM
# #    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
# #    coam.perform_delta_recommissioning    delta_file=${CREATE_BB3_DELTA}
# #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
# #    Wait Until Keyword Succeeds    15min    15s    Verify BTS Alarm Exist    fault_id=10    fault_name=No connection to unit
# #
# #     manual plug out BB3
# #    Control BBMOD Power Switch    power_status=0    slot=6
# #
# #    Set Optical Switch Channels And Verify Status    cross_port_setting=${CROSS_PORT_SETTING_ON_203_205}
# #    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
# #    ${nr_cell_identity}    Get NR Cell Identity Via Index "4"
# #    Enable BTS NR Cell Via ENB Cell LnRelGnbCellId    nr_cell_id=${nr_cell_identity}    lncel_id=2
# #    UE Attach And Check Throughput With Detach    global_cell_id=4
# #    ...    ul_tp=50M    ul_tp_threshold=1
# #    ...    dl_tp=50M    dl_tp_threshold=1    attach_mode=NSA    iperf_type=via_app
# 
# CB008253_C_301_First_full_commision_then_add_ecpri_TDD_RUs_in_FR1_dual_core_ASIK_ABIL
#     Initialize Configuration Via Disconnect Optical Switch    cross_port_setting=${CROSS_PORT_SETTING_OFF_201}
#     ...    delta_file=${REMOVE_RU3_DELTA}
#     Run Keyword And Ignore Error    CI_interface.Common Suite Setup
#     coam.reset_site    connection=GNB_OAM
#     Sleep    1800s
#     Wait Until Keyword Succeeds    5min    15s    Verify BTS Alarm Exist    fault_id=10    fault_name=No connection to unit
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-2004/NRBTS-10897/NRCELL-1    parameter=administrativeState
#     ...    value=Locked
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-2004/NRBTS-10897/NRCELL-1    parameter=administrativeState
#     ...    value=Unlocked
#     Set Optical Switch Channels And Verify Status    cross_port_setting=${CROSS_PORT_SETTING_ON_201}
#     Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-2004/NRBTS-10897/NRCELL-1    parameter=administrativeState
#     ...    value=Locked
#     ${nr_cell_identity}    Get NR Cell Identity Via Index "3"
#     Enable BTS NR Cell Via ENB Cell LnRelGnbCellId    nr_cell_id=${nr_cell_identity}    lncel_id=2
#     Wait until keyword succeeds    10min    20 sec    COAM Check X2 link status from GNB    connection=GNB_OAM
#     Wait Until Keyword Succeeds    3x    15s    UE Attach And Check Throughput With Detach    global_cell_id=3
#     ...    ul_tp=50M    ul_tp_threshold=1
#     ...    dl_tp=50M    dl_tp_threshold=1    attach_mode=NSA
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-2004/NRBTS-10897/NRCELL-1    parameter=administrativeState
#     ...    value=Unlocked
# 
# 
# #CB008253_C_302_First_full commision_then_add_ABIL_and_ecpri_RUs_in_FR1_primary_core_ASIK_ABIL
# #    [Documentation]    Author: jian.1.chen@nokia-sbell.com
# #    [Tags]    c302
# #    coam.perform_delta_recommissioning    delta_file=${REMOVE_BB2_DELTA}
# #    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
# #    Set Optical Switch Channels And Verify Status    cross_port_setting=${CROSS_PORT_SETTING_OFF_204}
# #    Modify Parameter On BTS With Activate    dist_name=MRBTS-2004/NRBTS-10897/NRCELL-1    parameter=administrativeState
# #    ...    value=Locked
# #    ${nr_cell_identity}    Get NR Cell Identity Via Index "3"
# #    Enable BTS NR Cell Via ENB Cell LnRelGnbCellId    nr_cell_id=${nr_cell_identity}    lncel_id=2
# #    Wait Until Keyword Succeeds    3x    15s    UE Attach And Check Throughput With Detach    global_cell_id=3
# #    ...    ul_tp=50M    ul_tp_threshold=1
# #    ...    dl_tp=50M    dl_tp_threshold=1    attach_mode=NSA    iperf_type=via_app
# #    Modify Parameter On BTS With Activate    dist_name=MRBTS-2004/NRBTS-10897/NRCELL-1    parameter=administrativeState
# #    ...    value=Unlocked
# 
# CB008253_C_313_OAM_operation_about_MO_CELLSCALCULATIONREQ_and_CELLSCALCULATIONRES_from_delta_commision
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c313
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
#     ...    parameter=actCellAutoRecalculation    value=OnOperatorDemand
#     # the value of cellsRecalculationComment is [tmp_comment]
#     coam.perform_delta_recommissioning    delta_file=${ADD_CELLSCALCULATIONREQ_DELTA_PATH}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#     CI_commssion.Verify all cells should be Online
#     Selenium Login With Version    download_dir=/tmp/snapshot_ta
#     ${comment}    selenium_coam.get_parameter_value
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1
#     ...    filter_param=Cells re-calculation command comment
#     Should Be Equal As Strings    ${comment}    tmp_comment
#     ${result}    selenium_coam.get_parameter_value
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1/CELLSCALCULATIONRES-1
#     ...    filter_param=Cells re-calculation result
#     Should Be Equal As Strings    ${result}    success
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
#     # the modify value of cellsRecalculationComment is [tmp_modify_comment]
#     coam.perform_parameter_recommissioning    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1
#     ...    parameter=cellsRecalculationComment    value=tmp_modify_comment    operation=update
#     ...    skip_parameter_relation_errors=true    connection=GNB_OAM
#     CI_commssion.Verify all cells should be Online
#     Selenium Login With Version    download_dir=/tmp/snapshot_ta
#     ${comment2}    selenium_coam.get_parameter_value
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1
#     ...    filter_param=Cells re-calculation command comment
#     Should Be Equal As Strings    ${comment2}    tmp_modify_comment
#     ${result2}    selenium_coam.get_parameter_value
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1/CELLSCALCULATIONRES-1
#     ...    filter_param=Cells re-calculation result
#     Should Be Equal As Strings    ${result2}    success
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
#     coam.perform_delta_recommissioning    delta_file=${DELETE_CELLSCALCULATIONREQ_DELTA_PATH}
#     ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${600}    connection=GNB_OAM
#     CI_commssion.Verify all cells should be Online
#     ${scf}    coam.get_scf    connection=GNB_OAM
#     Should Not Contain    ${scf}    MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1
# 
# CB008253_C_314_OAM_operation_about_MO_CELLSCALCULATIONREQ_and_CELLSCALCULATIONRES_from_WebEM_in_dual_core_ASIK
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c314
#     Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
#     ...    parameter=actCellAutoRecalculation    value=OnOperatorDemand
#     Selenium Login With Version    download_dir=/tmp/snapshot_ta
#     selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1
#     ...    object_class_name=CELLSCALCULATIONREQ    plan_to_copy_from=CURRENT_BTS_CONF-1
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1
#     ...    filter_param=Cells re-calculation command comment    new_value=tmp_comment    abbr=cellsRecalculationComment
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=300
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
#     CI_commssion.Verify all cells should be Online
#     Selenium Login With Version    download_dir=/tmp/snapshot_ta
#     ${comment}    selenium_coam.get_parameter_value
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1
#     ...    filter_param=Cells re-calculation command comment
#     Should Be Equal As Strings    ${comment}    tmp_comment
#     ${result}    selenium_coam.get_parameter_value
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1/CELLSCALCULATIONRES-1
#     ...    filter_param=Cells re-calculation result
#     Should Be Equal As Strings    ${result}    success
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
#     Selenium Login With Version    download_dir=/tmp/snapshot_ta
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1
#     ...    filter_param=Cells re-calculation command comment    new_value=tmp_modify_comment    abbr=cellsRecalculationComment
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=300
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
#     CI_commssion.Verify all cells should be Online
#     Selenium Login With Version    download_dir=/tmp/snapshot_ta
#     ${comment2}    selenium_coam.get_parameter_value
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1
#     ...    filter_param=Cells re-calculation command comment
#     Should Be Equal As Strings    ${comment2}    tmp_modify_comment
#     ${result2}    selenium_coam.get_parameter_value
#     ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1/CELLSCALCULATIONRES-1
#     ...    filter_param=Cells re-calculation result
#     Should Be Equal As Strings    ${result2}    success
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
#     Selenium Login With Version    download_dir=/tmp/snapshot_ta
#     selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=300
#     ${scf}    coam.get_scf    connection=GNB_OAM
#     Should Not Contain    ${scf}    MRBTS-${MRBTS_ID}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1
#     [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
# CB008253_C_317_Startup_time_test_after_site_reset_when_testline_was_commissioned_but_some_HW_not_install
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    c317
#     ${result}    ${release}    Run Keyword And Ignore Error
#     ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
# #    Run Keyword If    '${release}'=='SBTS24R1'    Set Suite Variable    ${CELLS_NUMBER_EXCEPT_RU2}    4
#     Set Optical Switch Channels And Verify Status    cross_port_setting=${CROSS_PORT_SETTING_OFF_202}
#     Wait Until Keyword Succeeds    15min    15s    Verify BTS Cells Enable Number    enable_number=${CELLS_NUMBER_EXCEPT_RU2}
#     ${date1}    Get Current Date
#     coam.reset_site    connection=GNB_OAM
#     Wait Until Keyword Succeeds    15min    15s    Verify BTS Cells Enable Number    enable_number=${CELLS_NUMBER_EXCEPT_RU2}
#     ${date2}    Get Current Date
#     ${time}    Subtract Date From Date    ${date2}    ${date1}
#     Should Be True    ${time} < 900
#     [Teardown]    Set Optical Switch Channels And Verify Status    cross_port_setting=${CROSS_PORT_SETTING_ON_202}
