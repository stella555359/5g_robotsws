*** Settings ***
Documentation    ...
#Documentation     author: bizhou contact: biao.zhou@nokia-sbell.com
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=0x580117=3;0x570010=1;
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Add Multi UE NSA    12
#...               AND    Add Multi UE NSA    13
#...               AND    Suite Setup Start WTS And Check OnAir
#...               AND    NSA L3 Call and Collect Sherpa logs
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CRT    RAN_5G_TDD
#...               FR1    Owner_q19370    PRI-High    RAN_5G
#...               SBTS00    SBTS23R1    SBTS22R4    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#Test Timeout      25 minutes
#
#Library           OperatingSystem
#Library           Process
#Library           String
#Library           Collections
#Library           DateTime
#Resource          ./AirPhone_common_resource_UTE_CR.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${UE_ID}               11
#${PROFILE_ID}          1
#${GNB_ID}              2
#${BEARER_ID}           2
#@{LOG_NAME_LIST}       btslog    snapshot
#${COUNT}               0
#
#*** Test Cases ***
#5GC001808-ET-I010-Verify the format in Event 9 UlData_PucchReceiveRespPs of L2PS_DL Sherpa log
#    [Documentation]    The purpose of this case is to check Event 9 UlData_PucchReceiveRespPs reported
#    [Timeout]    23 min
#    Read csv file    l1l2Trace
#    ${result}    SherpaCsvReader.check_all_values_for_column    MSGID    Ul MultiplePucchRespPsEvent(9)
#    Should Be True    ${result}    event 9 is not reported in l1l2Trace csv file
#
#*** Keywords ***
#NSA L3 Call and Collect Sherpa logs
#    Config and get All L2stream logs including attach and traffic    "NSA_multi_UEs"     #///need to modify arguments for various L3CALL
#    Makesure UTEVM Sherpa tool can work
#    Convert Pcap To Sherpa Csv    ${SUITE_LOG_DIRECTORY}
#
#Common Suite Teardown
#    Disconnect WTS And Egate Session
