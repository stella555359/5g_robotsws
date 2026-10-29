# *** Settings ***
# Resource    ../Resources/5GC001596_D_Keywords.robot
# 
# Documentation
# ...   author: Liu Zheng
# ...   contact: zheng.4.liu@nokia-sbell.com
# ...   squad group: SG_04
# ...   Feature 5GC001596 in 5G19B program, RU type:AEWD
# 
# Force Tags      5G_SISO         7.1816  0.816  1596
# ...    PY36
# 
# Suite Setup     Suite preparation
# 
# Suite Teardown  Run Keyword And Ignore Error    Suite env recovery
# 
# 
# *** Test Cases ***
# [1]5GC001596_D_019_cell_onair_successful_without_alarm_non_contiguous_freq
#     [Tags]    CRT_19B    CRT_20B    CRT_21A    CRT_21B    CRT_22R1    CRT_22R4    CRT_23R1
#     [Documentation]    author: Cui Lingxue
#     ...    qc pass
#     ...    Verify whether gNB can be onair status successfully without any unexpected alarms with classical gNB configuration with
#     ...    mmWave eCPRI configuration block 1S-2CC-2DL-2UL-2CC-2DL-0UL using 1 single ABIL and non-contiguous frequency.
#     [Setup]    Case preparation with btslog collection for L3call
#     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
#     ...    allowed_faults=@{ALLOWED_FAULT_LIST}    file_path=${TS_CASE_LOG_PATH}    connection=GNB_OAM
#     Call case with QCOM UE and record throughput info for many cells many times    para_update_timeout=${TIMEOUT_MODIFY_PARA}
#     ...    repeat_times=${TEST_REPEAT_TIMES}    verify_duration=${VERIFY_DURATION}
#     ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery with btslog collection for L3call
# 
# *** Keywords ***
# Suite preparation
#     [Documentation]    author: Liu Zheng
#     [Timeout]    20 min
#     COAM Create log directory    is_set_to_test_case_level=${False}
#     set suite variable     ${PARAMS_TO_DELETE}    ${ABIL_4CC_ABIO_0CC_DEL}
#     set suite variable     ${PARAMS_TO_MODIFY}    ${ABIL_UL2CC_MODIFY}
#     Suite common setup preparation    is_pdl_checking_needed=${False}      enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
#     ...    scf_template_path=${SCF_DEFAULT_FILE_PATH}    scf_modify_parameters=${MODIFY_4CC_VIA_API_NON_CONTINOUS}
#     Get the ru index list and cell index list and cell group index list and set to suite variable
#     ${ue_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
#     set suite variable    ${UE_TYPE}    ${ue_type}
#     power_ue.Prepare UE    ue_type=${UE_TYPE}
#     ${program}    gnb_classical_hangzhou.Get program version based on stream version
#     set suite variable    ${PROGRAM}    ${program}
