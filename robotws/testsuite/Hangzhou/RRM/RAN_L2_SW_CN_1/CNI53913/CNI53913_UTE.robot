*** Settings ***
Documentation    ...
#Suite Setup      Run Keywords
#...               Prepare QT LOLO Enviroment    TYPE=TDD
#...               AND    Suite Setup Update GNB    scf_file=${DELTA_FILE}    swconfig_param=0x570003=0;0x580305=1;0x5B0219=3;0x5800F4=3;0x580017=2
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Upload multi UE scripts to WTS
#Suite Teardown    Common Suite Teardown
#Force Tags    Owner_Krihu    CRT    RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1    SBTS22R4
#...           CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./resources/keywords_CNI53913_common.robot
#
#*** Variables ***
#${SCF_PATH}            ./resources/
#${DELTA_FILE}          ${CURDIR}/resources/delta.json
#${UE_ID}               11
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#@{LOG_NAME_LIST}       btslog    snapshot
#${COUNT}               0
#
#*** Test Cases ***
#CNI_53913-ET-001 Verify DL data transfer to single UE by flow control with max UDP throughput
#    [Tags]    case1
#    Case Setup Use Multi-UEs lua Start WTS And Check OnAir
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    ${DL_average1}    NSA Start 600M DL Traffic and get tput
#    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    400
#    NSA DL Stop Traffic and Detach    ${UE_ID}    ${BEARER_ID}
#    Change CQI to number    ${UE_ID}    1
#    ${DL_average2}    NSA Start 600M DL Traffic and get tput
#    NSA DL Stop Traffic and Detach    ${UE_ID}    ${BEARER_ID}
#    Change CQI to number    ${UE_ID}    15
#    ${DL_average3}    NSA Start 600M DL Traffic and get tput
#    Verify tput after CQI change for case001    ${DL_average1}    ${DL_average2}    ${DL_average3}
#    [Teardown]    Run Keywords    NSA DL Stop Traffic and Detach    ${UE_ID}    ${BEARER_ID}
#    ...    AND    Test Teardown
#
#CNI_53913-ET-002 Verify DL data transfer to multi UEs by flow control with max UDP throughput
#    [Tags]    case2
#    Reboot TL And Check Configured
#    Case Setup Use Multi-UEs lua Start WTS And Check OnAir
#    Multi-UEs attach and L3 call    5
#    Multi-UEs sgnb_release_and_detach    5
#    Multi-UEs attach and L3 call    10
#    [Teardown]    Run Keywords    Multi-UEs sgnb_release_and_detach    10
#    ...    AND    Test Teardown
#
#CNI_53913-ET-003-Verify DL scheduling to multi UEs when radio conditions are mixed with max TCP throughput
#    [Tags]    case3
#    Reboot TL And Check Configured
#    Case Setup Use Multi-UEs lua Start WTS And Check OnAir
#    Ten UEs attach with different bler and L3 call
#    Sherpa log capture and check
#    [Teardown]    Run Keywords    Multi-UEs sgnb_release_and_detach    10
#    ...    AND    Test Teardown
#
#CNI_53913-ET-004 Verify DL data transfer to multi UEs by flow control during air interface congestion
#    [Tags]    case4
#    Reboot TL And Check Configured
#    Case Setup Use Multi-UEs lua Start WTS And Check OnAir
#    Multi-UEs attach and L3 call    5
#    Multi-UEs sgnb_release_and_detach    5
#    NSA LTE Attach    11    ${PROFILE_ID}
#    NSA 5G Attach    11    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA LTE Attach    12    ${PROFILE_ID}
#    NSA 5G Attach    12    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    Change CQI to number    13    1
#    Change CQI to number    14    1
#    Change CQI to number    15    1
#    Make L3call and Verify tput for case004
#    Sherpa log capture and check
#    [Teardown]    Run Keywords    Multi-UEs sgnb_release_and_detach    5
#    ...    AND    Test Teardown
#
#CNI_53913-ET-005 Verify intermittent DL data transfer to multi UEs by flow control with max UDP throughput
#    [Tags]    case5
#    Reboot TL And Check Configured
#    Case Setup Use Multi-UEs lua Start WTS And Check OnAir
#    Two UEs attach and intermittent L3 call
#    Sherpa log capture and check
