# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_pennwang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_b_case03.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_b.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${COMAVALUE}    ${CURDIR}/coma/case4.txt
# ${WTS_NAME}    BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD.cfg
# ${UE_ID}          1
# ${UE_ID2}          2
# @{Rdparameter}    0x58037C:1    0x58054F:0
#     ...    0x58054E:1    0x580549:19    0x580548:40    0x58054C:0    0x58054D:11    0x58054B:5
#     ...    0x580547:1    0x580546:10    0x58054A:1    0x580543:50    0x580544:3    0x580545:2
#     ...    0x58059A:1    0x58059B:1
# 
# 
# *** Test Cases ***
# CB008360_B_B1a_case03_two_rank1_Ues_8DL8UL_Max_4Layer_without_tapering
#     Prepare test
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach SA ue to 5g cell    t2r4_n2    1
#     Attach SA ue to 5g cell    t2r4_n2    2    PDU_ID=2    GW_ID=2
#     SA send dl and ul data    1    number=3    dl_data=10M    ul_data=100M
#     SA send dl and ul data    2    number=3    dl_data=10M    ul_data=100M    pdu_id=2
#     Stop egate log and unzip with name'pair'
#     Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'b_case3'  
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     run keyword and continue on failure    Check ue tput is correct
#     Check pair funcition is correct
# 
# 
# 
# 
# *** Keywords ***
# Prepare test
# #    Active GNB L2 feature debug traces
#     Modify l1bypass
#     Modify 8360 Swconfig
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     ${extra_modify}    create list
#     ...    text|28|//*[@TestProfile\="Profile-1"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-1"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-2"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-2"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|0|//*[@TestProfile\="Profile-1"]//PuschTestParams//puschNumCountSwitchProfile
#     ...    text|0|//*[@TestProfile\="Profile-2"]//PuschTestParams//puschNumCountSwitchProfile
#     ...    text|16|//ComaMultiplier
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex10}    ${Vindex9}    ${Hindex9}    ${Vindex8}
#     ...    ${Hindex12}    ${Vindex6}    ${Hindex8}    ${Vindex3}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex17}    ${Vindex6}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex9}    ${Vindex8}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex8}    ${Vindex3}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}
#     ...    srsNumCountSwitchProfile1=0    p1_rank=2    p2_rank=2    p1_sinr=33    p2_sinr=33
#     ...    extra_modify=${extra_modify}
# 
# Modify 8360 Swconfig
#     Add GNB swconfig    @{Rdparameter}
# 
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=2
#     should be true    ${ul_tput1}>98000
#     should be true    ${ul_tput2}>98000
# 
# Check pair funcition is correct
#     Check Log With Au2anlysis    ${CURDIR}/ini/tti_b_case3.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All