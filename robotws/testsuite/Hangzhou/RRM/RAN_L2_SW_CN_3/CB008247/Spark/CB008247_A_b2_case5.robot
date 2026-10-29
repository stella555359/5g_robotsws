# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       Spark Common Suite Setup
# Suite Teardown    Spark Common Suite Teardown
# Test Setup        Spark Common Test Setup
# Test Teardown     Spark Common Test Teardown
# Force Tags    spark    owner_pennwang
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot
# ${SCFC_NAME}    SCFC_8247_spark_case15.xml
# ${ATT}    ${CONFIG_DIR_PATH}/mcs/att.csv
# ${PHASE}    ${CONFIG_DIR_PATH}/mcs/phase.csv
# ${UE_ID}       1,4
# ${PORT}    5002
# &{GNBMIRRORINGCONFIG}    BB_SLOT_5='true'    BB_SLOT_1='false'    L2_L1_BIP='true'    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30    CPRT_MIRRORING='true'
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${FILTER1}        itf_l2_ps_peerctrl_UeInterCASchedulingModifyParams_t.modifType_item
# 
# *** Test Cases ***
# CB008247_A_b2_case5_CL_4x4_8DL4UL_100Mhz_best_beam_determination_Single_UE_t2r4_SA
#     Prepare environment
#     Start capture only gnb syslog in 'after_onair' file
#     ${ip}    Attach SA ue    ${UE_ID}
#     Start spark average log
#     #bip log
#     Start collect bip log
#     Wait for '5s' to stop bip log with name'bip'
#     Start spark dl and ul traffic    ${ip}    ${PORT}    5000    1400    ${UE_ID}
#     #tti trace
#     Start collect ttitrace
#     Wait for '10s' to stop ttitrace with name'tti'
#     #instant tput
#     ${dl}    ${ul}    Get dl and ul instant throughput    ${UE_ID}
#     run keyword and continue on failure    should_be_true    ${dl}[1] > 100
#     run keyword and continue on failure    should_be_true    ${ul}[1] > 30
#     #average tput
#     Stop spark dl and ul traffic    ${UE_ID}    ${ip}    ${PORT}
#     ${dl1}    ${ul1}    Get dl and ul average throughput    1
#     run keyword and continue on failure    should_be_true    ${dl1}[1] > 100
#     run keyword and continue on failure    should_be_true    ${ul1}[1] > 30
#     Detach spark ue    ${UE_ID}
#     Stop capture only gnb syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# Prepare environment
#     Set attenuation    ${ATT}    2610
#     Set phase    ${PHASE}    2610
#     Qualcomm prepare gnb onair
