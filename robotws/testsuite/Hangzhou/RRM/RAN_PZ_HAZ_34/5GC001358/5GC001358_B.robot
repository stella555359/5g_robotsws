# *** Settings ***
# Documentation
# ...   author: Qian Jianwu
# ...   contact: jianwu.qian@nokia-sbell.com
# ...   squad group: mmw_sg3
# ...   Feature 5GC001358_B
# 
# Resource    ./Resources/5GC001358_common_keyword.robot
# Force Tags    5G_RRM
# ...    PY36
# 
# Suite Setup    Run Keywords    Adapt SCF Name By Release    AND    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# Test Setup     Run Keywords    UE Reboot with adb command    AND    robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# *** Variables ***
# ${logsave_path}    /home/ute/dir/
# ${MR_LTE_Cell_NAME}
# *** Test Cases ***
# [1]5GC001358-B_001_5GC002035_5GC002212_4DL_2UL_4x4MIMO_non_beam_forming_without_subsector
#     [Documentation]
#     ...    The purpose of this test case is to verify traffic is success with required configuration.
#     [Tags]    CRT_TRUNK
#     Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_DEFAULT}
#     ${scf_after_modify}    Scf xml modify    scf_file_path=${scf_path}/${8T8R_scf_name}
#     ...    parameters_to_update_xml=${PARA_5GC001961}
#     Scf commition and wair for on-air    scf_name=${scf_after_modify}
#     UE attach and check tp    tp_direction=both    dl_tp=1600M    ul_tp=100M    exp_dl_tp=1400    exp_ul_tp=60
#     ...    check_times=300s
# 
# [1]5GC001358-B_002_5GC002212_5GC001451_2_subsector_open_loop_4x4_256QAM
#     [Documentation]
#     ...    The purpose of this test case is to verify traffic is success with required configuration.
#     [Tags]    CRT_TRUNK
#     Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_2_1234}
#     ${scf_after_modify}    Scf xml modify    scf_file_path=${scf_path}/${8T8R_scf_name}
#     ...    parameters_to_update_xml=${PARA_5GC001451_2}
#     Scf commition and wair for on-air    scf_name=${scf_after_modify}
#     UE attach and check tp    tp_direction=both    dl_tp=1600M    ul_tp=100M    exp_dl_tp=1400    exp_ul_tp=60
#     ...    check_times=300s
# 
# [1]5GC001358-B_003_5GC002212_5GC001451_2_subsector_close_loop_4x4_256QAM_BeamSwitch
#     [Documentation]
#     ...    The purpose of this test case is to verify traffic is success with required configuration.
#     [Tags]    CRT_TRUNK
#     ${scf_after_modify}    Scf xml modify    scf_file_path=${scf_path}/${8T8R_scf_name}
#     ...    parameters_to_update_xml=${PARA_5GC001451_2_closeloop}
#     Scf commition and wair for on-air    scf_name=${scf_after_modify}
#     Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_2_1234}
#     UE prepare and attach
#     UE start traffic   tp_direction=both   ul_tp=100M    dl_tp=1600M
#     Run keyword and continue on failure    UE check throughput by syslog    tp_direction=both
#     ...   exp_ul_tp=60    exp_dl_tp=1400    check_times=60s
#     Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_2_mid}
#     sleep    10s
#     Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_2_5678}
#     sleep    30s
#     Run keyword and continue on failure    UE check throughput by syslog    tp_direction=both
#     ...   exp_ul_tp=60    exp_dl_tp=1400    check_times=60s
#     power_ue.Stop traffic    direction=both    ue_index=${0}    ue_type=${UE_TYPE}
#     power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
#     [Teardown]    Run Keywords    Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_DEFAULT}
# 	...    AND    robot_common_operations.Common Case Teardown
# 
# [1]5GC001358-B_004_5GC002212_5GC001451_4_subsector_close_loop_2x2_256QAM
#     [Documentation]
#     ...    The purpose of this test case is to verify traffic is success with required configuration.
#     [Tags]    CRT_TRUNK
#     Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_4_12}
#     ${scf_after_modify}    Scf xml modify    scf_file_path=${scf_path}/${8T8R_scf_name}
#     ...    parameters_to_update_xml=${PARA_5GC001451_4}
#     Scf commition and wair for on-air    scf_name=${scf_after_modify}
#     UE attach and check tp    tp_direction=both    dl_tp=800M    ul_tp=100M    exp_dl_tp=680    exp_ul_tp=60
#     ...    check_times=300s
# 
# [1]5GC001358-B_005_5GC002212_5GC001451_4_subsector_open_loop_2x2_256QAM_BeamSwitch
#     [Documentation]
#     ...    The purpose of this test case is to verify traffic is success with required configuration.
#     [Tags]    CRT_TRUNK
#     ${scf_after_modify}    Scf xml modify    scf_file_path=${scf_path}/${8T8R_scf_name}
#     ...    parameters_to_update_xml=${PARA_5GC001451_4_openloop}
#     Scf commition and wair for on-air    scf_name=${scf_after_modify}
#     Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_4_12}
#     UE prepare and attach
#     UE start traffic   tp_direction=both   ul_tp=100M    dl_tp=800M
#     Run keyword and continue on failure    UE check throughput by syslog    tp_direction=both
#     ...   exp_ul_tp=60    exp_dl_tp=680    check_times=60s
#     Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_4_mid}
#     sleep    10s
#     Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_4_56}
#     sleep    30s
#     Run keyword and continue on failure    UE check throughput by syslog    tp_direction=both
#     ...   exp_ul_tp=60    exp_dl_tp=680    check_times=60s
#     power_ue.Stop traffic    direction=both    ue_index=${0}    ue_type=${UE_TYPE}
#     power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
#     [Teardown]    Run Keywords    Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_DEFAULT}
# 	...    AND    robot_common_operations.Common Case Teardown
# 
# [1]5GC001358-B_016_5GC002344_5GC000399-KC_UE_call_setup_with_digital_BF_system_without_CA_FCP_aggregation
#     [Documentation]
#     ...    The purpose of this test case is to verify traffic is success with required configuration.
#     [Tags]    CRT_TRUNK
#     run keyword if    '${MR_NAME}'=='MRBTS-937'     Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_DEFAULT}
#     Scf commition and wair for on-air    scf_name=${scf_path}/${2cells_scf_name}
#     UE attach and check tp    tp_direction=both    dl_tp=800M    ul_tp=100M    exp_dl_tp=700    exp_ul_tp=50
#     ...    check_times=300s
#     run keyword if    '${MR_NAME}'=='MRBTS-937'    Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_2ND_CELL}
#     Connect to gnb coam via ssl    connection=ENB_OAM
#     ...    bts_host=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
#     ...    username=Nemuadmin
#     ...    password=nemuuser
# 	Set LTE cell
#     Change Parameter online   ${MR_LTE_Cell_NAME}    defaultLnRelGnbCellId     update    2    connection=ENB_OAM
#     ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
#     power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
#     UE start traffic   tp_direction=dl   dl_tp=800M
#     Run keyword and continue on failure    UE check throughput by syslog    tp_direction=dl
#     ...    exp_dl_tp=650    check_times=300s
#     power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
#     power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
#     [Teardown]    Run Keywords    Change Parameter online    ${MR_LTE_Cell_NAME}    defaultLnRelGnbCellId
#     ...    update    1    connection=ENB_OAM    AND    robot_common_operations.Common Case Teardown
# 
# [1]5GC001358-B_023_5GC000920_2_subsector_open_loop_4x4MIMO_peak_throughput_and_counter_verification
#     [Documentation]
#     ...    The purpose of this test case is to verify traffic is success with required configuration.
#     [Tags]    CRT_TRUNK
#     Connect to gnb coam via ssl
#     ${Active_SW_version}    Get Active SW Version
#     set test variable      ${Active_SW_version}
#     Adjust HBTE ATT Values seperate    ${ATTENUATION_VALUE_1451_2_1234}
#     ${scf_after_modify}    Scf xml modify    scf_file_path=${scf_path}/${8T8R_scf_name}
#     ...    parameters_to_update_xml=${PARA_5GC001451_2}
#     Scf commition and wair for on-air    scf_name=${scf_after_modify}
#     UE attach and check tp    tp_direction=both    dl_tp=1600M    ul_tp=100M    exp_dl_tp=1400    exp_ul_tp=60
#     ...    check_times=900s
#     ${PM_counter_MCS}    Get lastest PM counter    counter_id=M55301C18027
#     should be true      ${PM_counter_MCS} > 1
#     ${PM_counter_transmission}    Get lastest PM counter    counter_id=M55301C10004
#     should be true      ${PM_counter_transmission} > 1
#     ${PM_counter_initial_transmission}    Get lastest PM counter    counter_id=M55300C10004
#     should be true      ${PM_counter_initial_transmission} > 1
#     ${PM_counter_HARQ}    Get lastest PM counter    counter_id=M55300C11004
#     should be true      ${PM_counter_HARQ} > 1
# *** Keywords ***
# Set LTE cell 
#     run keyword if    '${MR_NAME}'=='MRBTS-937'   Set test variable    ${MR_LTE_Cell_NAME}    MRBTS-3136/LNBTS-3136/LNCEL-54726 
#     run keyword if    '${MR_NAME}'=='MRBTS-935'   Set test variable    ${MR_LTE_Cell_NAME}    MRBTS-10592/LNBTS-10592/LNCEL-32 	