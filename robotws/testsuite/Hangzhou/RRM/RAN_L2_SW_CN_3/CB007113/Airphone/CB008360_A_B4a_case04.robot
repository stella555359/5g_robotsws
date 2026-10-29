# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# # Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# # Test Teardown    Common Test Teardown
# Force Tags    owner_pennwang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_7113_case4.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_3CELL.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${COMAVALUE}    ${CURDIR}/coma/case4.txt
# ${WTS_NAME}    BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD.cfg
# ${UE_ID}          1
# ${UE_ID2}          2
# @{Rdparameter}    
#     ...    0x58054E:1    0x580549:19    0x580548:40    0x58054C:0    0x58054D:11    0x58054B:5
#     ...    0x580547:1    0x580546:10    0x58054A:1    0x580543:50    0x580544:3    0x580545:2
#     ...    0x58059A:1    0x58059B:1
#     ...    0x420068:6    0x580612:1
#     # ...    0x58037C:1
# 
# *** Test Cases ***
# CB007113_I_2_case4_MUMIMO_3layers_with_UL_PRB_pooling_activated_3rank1ue
#     Prepare test
#     Prepare gnb onair
# #    Reboot gnb and ap via ssh
# #    Start Wts And Wait Bts Until Onair     ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}    timeout=1800
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    1
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    2    PDU_ID=2    GW_ID=2
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    3    PDU_ID=3    GW_ID=3
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    4    PDU_ID=4    GW_ID=4
#     SA send dl and ul data    1    number=5    dl_data=100M    ul_data=140M
#     SA send dl and ul data    2    number=5    dl_data=100M    ul_data=140M    pdu_id=2
#     SA send dl and ul data    3    number=2    dl_data=10M    ul_data=140M    pdu_id=3
#     SA send dl and ul data    4    number=2    dl_data=10M    ul_data=140M    pdu_id=4
#     Stop egate log and unzip with name'pair'
#     Wait '5s' for stabible
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     run keyword and continue on failure    Check ue tput is correct
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'case4'
#     # Check pair funcition is correct
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
# #    ...    ${Hindex0}    ${Vindex0}    ${Hindex9}    ${Vindex8}
# #    ...    ${Hindex5}    ${Vindex0}    ${Hindex8}    ${Vindex3}
# #    ...    ${Hindex6}    ${Vindex4}    ${Hindex17}    ${Vindex6}
# #    ...    ${Hindex10}    ${Vindex8}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex9}    ${Vindex8}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex8}    ${Vindex3}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}
#     ...    srsNumCountSwitchProfile1=0    p1_rank=1    p2_rank=1    p1_sinr=33    p2_sinr=33
#     ...    extra_modify=${extra_modify}
# 
# Modify 8360 Swconfig
#     Add GNB swconfig    @{Rdparameter}
#     Add AP swconfig    0x70005:140
# 
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=2
#     ${dl_tput3}    ${ul_tput3}    Obtain one sa ue dl and ul throught    3    pdu_id=3
#     ${dl_tput4}    ${ul_tput4}    Obtain one sa ue dl and ul throught    4    pdu_id=4
#     should be true    ${ul_tput1}>25000
#     should be true    ${ul_tput2}>25000
#     should be true    ${ul_tput3}>25000
#     should be true    ${ul_tput4}>25000
# 
# Check pair funcition is correct
#     Check Log With Au2anlysis    ${CURDIR}/ini/tti_case4.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Change ulMuMimoLinkAdaptionSwitch
#     Online change ulMuMimoLinkAdaptionSwitch to 'MCS compensation'
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'MCS_compensation'
#     run keyword and continue on failure    Check ue tput is correct
# 
# Online change ulMuMimoLinkAdaptionSwitch to '${value}'
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    ulMuMimoLinkAdaptionSwitch    ${value}    online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible