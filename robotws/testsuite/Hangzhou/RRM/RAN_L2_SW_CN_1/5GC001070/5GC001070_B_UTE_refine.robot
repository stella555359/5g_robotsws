*** Settings ***
Documentation    ...
#Resource    ../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup 2
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2    #snapshot=${True}
#Suite Teardown    Common Suite Teardown 2
#Resource    ./keywords_1070_common_AP.robot
#Force Tags    Classical    FR1    IPV4    5GC001070    Owner_yuema    RAN_5G    RAN_5G_TDD
#...           SBTS00    SBTS23R1    SBTS22R4
#
#*** Variables ***
#${GNBCUTYPE}    NSA
#${SCF_PATH}    ${CURDIR}/config
#${RESOURCE_PATH}       ${CURDIR}/resources
#@{log_name_list}    btslog
#${UE_ID}               11
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#
#*** Test Cases ***
#5GC001070-B-4011-Single UE scheduling with DBF in FR1-n78-100MHz with GP2Symbols with B4 prach 149 and 1ssb
#    [Tags]    CDRT    CIT    case1    CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#    Delta Commission With SCF File    ${CURDIR}/delta_4011.json
#    Reboot TL And Check Configured
#    Start WTS And Check OnAir
#    Attach NSA UE and Get Throughput    UE_ID=11
#    Run Keyword And Ignore Error    Attach SA UE and Get Throughput    UE_ID=1
#
#5GC001070-B-4012-Single UE scheduling with DBF in FR1-n78-100MHz with GP2Symbols with B4 prach 151 and 2ssb
#    [Tags]    CRT    case2    CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#    Delta Commission With SCF File    ${CURDIR}/delta_4012.json
#    Reboot TL And Check Configured
#    Start WTS And Check OnAir
#    Attach NSA UE and Get Throughput    UE_ID=11
#    Attach SA UE and Get Throughput    UE_ID=1
#
#*** Keywords ***
#
#
#
