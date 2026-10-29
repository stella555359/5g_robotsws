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
# ${SCFC_NAME}      SCFC_8360_case6.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport
# ${COMAVALUE}    ${CURDIR}/coma/case4.txt
# ${WTS_NAME}    BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD.cfg
# @{Rdparameter}    0x58037C:1
#     ...    0x58054E:1    0x580549:19    0x580548:40    0x58054C:0    0x58054D:11    0x58054B:5
#     ...    0x580547:1    0x580546:10    0x58054A:1    0x580543:50    0x580544:3    0x580545:2
#     ...    0x58059A:1    0x58059B:1
# 
# 
# *** Test Cases ***
# CB008360_A_B4a_case04_4_rank1_Ues_paired_without_power_limit
#     Prepare test
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach 8ue
#     NSA send ue '11' mutiple trf '2' for each '10M' UL data
#     NSA send ue '12' mutiple trf '2' for each '10M' UL data
#     SA send dl and ul data    3    number=2    dl_data=10M    ul_data=10M    pdu_id=3
#     SA send dl and ul data    4    number=2    dl_data=10M    ul_data=10M    pdu_id=4
#     SA send dl and ul data    5    number=2    dl_data=10M    ul_data=2M    pdu_id=5
#     SA send dl and ul data    6    number=2    dl_data=10M    ul_data=2M    pdu_id=6
#     NSA send ue '13' mutiple trf '2' for each '10M' UL data
#     NSA send ue '14' mutiple trf '2' for each '10M' UL data
#     Wait '5s' for stabible
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     run keyword and continue on failure    Check ue tput is correct
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'case6'
#     Stop egate log and unzip with name'pair'
#     Check aperidic srs not pair with peridic srs
# 
# 
# 
# 
# *** Keywords ***
# Prepare test
# #    Active GNB L2 feature debug traces
#     Modify l1bypass
#     Add GNB swconfig    @{Rdparameter}
# 
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
#     ...    ${Hindex10}    ${Vindex9}    ${Hindex9}    ${Vindex8}
#     ...    ${Hindex12}    ${Vindex6}    ${Hindex8}    ${Vindex3}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex17}    ${Vindex6}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex24}    ${Vindex9}
#     ...    srsNumCountSwitchProfile1=0    p1_rank=1    p2_rank=1    p1_sinr=30    p2_sinr=30
#     ...    extra_modify=${extra_modify}
# 
# Check ue tput is correct
#     Check NSA ue '11' 'pcell' ul throught should '> 9000'
#     Check NSA ue '12' 'pcell' ul throught should '> 9000'
#     ${dl_tput3}    ${ul_tput3}    Obtain one sa ue dl and ul throught    3    pdu_id=3
#     ${dl_tput4}    ${ul_tput4}    Obtain one sa ue dl and ul throught    4    pdu_id=4
#     ${dl_tput5}    ${ul_tput5}    Obtain one sa ue dl and ul throught    5    pdu_id=5
#     ${dl_tput6}    ${ul_tput6}    Obtain one sa ue dl and ul throught    6    pdu_id=6
#     Check NSA ue '13' 'pcell' ul throught should '> 9000'
#     Check NSA ue '14' 'pcell' ul throught should '> 9000'
#     should be true    ${ul_tput3}>9500
#     should be true    ${ul_tput4}>9500
#     should be true    ${ul_tput5}>3500
#     should be true    ${ul_tput6}>3500
# 
# Attach 8ue
#     Airphone Nsa Attach    11
#     Airphone Nsa Attach    12
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    3    PDU_ID=3    GW_ID=3
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    4    PDU_ID=4    GW_ID=4
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    5    PDU_ID=5    GW_ID=5
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    6    PDU_ID=6    GW_ID=6
#     Airphone Nsa Attach    13
#     Airphone Nsa Attach    14
# 
# Check aperidic srs not pair with peridic srs
#     ${sa}    file match all    ${TEST_LOG_DIRECTORY()}/All/egate_pair/egate_console.log.001    .*crnti: (\\d+)
#     ${nsa}    file match all    ${TEST_LOG_DIRECTORY()}/All/egate_pair/egate_console.log.001    .*newUE-Identity (\\d+)
#     ${v1}    set variable    ${nsa}[0]
#     ${v2}    set variable    ${nsa}[1]
#     ${v3}    set variable    ${sa}[2]
#     ${v4}    set variable    ${sa}[3]
#     Check Log With Au2anlysis    ${CURDIR}/ini/tti_case6.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 
