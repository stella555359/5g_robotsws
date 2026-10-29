# *** Settings ***
# Resource          ./../Resources/5GC001305_keywords.robot
# 
# 
# Documentation    Suite description
# ...   author: Wang Yixiang && Huang Min
# ...   contact: xxxx@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature 5GC001305
# 
# Force Tags    5G_RRM
# ...    PY36
# Suite Setup     Suite setup 1305
# Suite Teardown    run keyword and ignore error    Common suite recovery
# 
# *** Variables ***
# @{GNB_PS_CELL_INDEX_LIST}    11
# 
# *** Test Cases ***
# [1]5GC001305_A_02_PRACH_C0_NSA_ECPRI_FR2_UE_attach_with_frame_structure_1127_prach_config_index_38_to_149_to_38_Ncs_15_with_beamforming
#     [Tags]    CIT_TRUNK     CIT_22R2    CIT_22R3    CDRT_22R2    CIT_22R4    CDRT_22R3
#     [Documentation]    Author: Wang Yixiang
#     ...    The purpose of this case is to check all calls setup procedure are successfully when frame structrue 1127 and
#     ...    PRACH format from A2 (prachConfigurationIndex=38) to C0(prachConfigurationIndex=149),then back to A2(prachConfigurationIndex=38)
#     ...    with Ncs is 15 and beamforming enabled
#     [Setup]    Common case setup    is_log_required=${True}
#     Modify NIDD via rest api and wait onair    parameters=${MODIFY_1305_02_PRECONDITION_API}
#     Modify prachConfigurationIndex via rest api and wait onair    prachConfigurationIndex=149
#     UE attach and check logs    log_name=enb_x2_149     customized_log_name=tput_pic_1
#     Modify prachConfigurationIndex via rest api and wait onair    prachConfigurationIndex=38
#     UE attach and check logs    log_name=enb_x2_38      customized_log_name=tput_pic_2
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${True}    detach_ue=${True}
# 
# 
# 
# [1]5GC001305_A_16_PRACH_C0_NSA_ECPRI_FR2_UE_attach_with_frame_structure_1127_prach_config_index_149_to_167_Ncs_69_with_beamforming
#     [Tags]    CIT_TRUNK     CIT_22R2    CRT_22R3    CDRT_22R2    CIT_22R4
#     [Documentation]    Author: HuangMin
#     ...    The purpose of this case is to check all calls setup procedure are successfully when frame structrue 1127 and
#     ...    PRACH format from C0 (prachConfigurationIndex=149) to C0(prachConfigurationIndex=167)
#     ...    with Ncs is 69 and beamforming enabled
#     [Setup]    Common case setup    is_log_required=${True}
#     Modify NIDD via rest api and wait onair    parameters=${MODIFY_1305_16_PRECONDITION_API}
#     UE attach and check logs    log_name=enb_x2_149     customized_log_name=tput_pic_1
#     Modify prachConfigurationIndex via rest api and wait onair    prachConfigurationIndex=167
#     UE attach and check logs    log_name=enb_x2_167      customized_log_name=tput_pic_2
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${True}    detach_ue=${True}
# 
# 
# [1]5GC001305_A_13_PRACH_C0_NSA_ECPRI_FR2_UE_attach_with_frame_structure_1127_prach_config_index_187_to_166_to_187_Ncs_27_without_beamforming
#     [Tags]    CIT_TRUNK      CIT_22R2    CIT_22R3    CDRT_22R2    CIT_22R4    CDRT_22R3
#     [Documentation]    Author: HuangMin
#     ...    The purpose of this case is to check all calls setup procedure are successfully when frame structrue 1127 and
#     ...    PRACH format from C2 (prachConfigurationIndex=187) to C0(prachConfigurationIndex=166),then back to A2(prachConfigurationIndex=187)
#     ...    with Ncs is 27 and beamforming enabled
#     [Setup]    Common case setup    is_log_required=${True}
#     Modify NIDD via rest api and wait onair    parameters=${MODIFY_1305_13_PRECONDITION_API}
#     Modify prachConfigurationIndex via rest api and wait onair    prachConfigurationIndex=166
#     UE attach and check logs    log_name=enb_x2_166     customized_log_name=tput_pic_1
#     Modify prachConfigurationIndex via rest api and wait onair    prachConfigurationIndex=187
#     UE attach and check logs    log_name=enb_x2_187      customized_log_name=tput_pic_2
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${True}    detach_ue=${True}
# 
# 
# *** Keywords ***
# Suite setup 1305
#     set suite variable     ${PARAMS_TO_DELETE}    ${ABIO_4CC_ABIL_0CC_DEL}
#     Suite common setup preparation
#     ...     scf_modify_parameters=${MODIFY_DEFAULT_SCF}    prepare_ue=${True}
#     Set ENB defaultLnRelGnbCellId to value     value=8
