*** Settings ***
Documentation    ...
#Documentation     author: alicchen contact: alice.1.chen@nokia-sbell.com
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${RD_PARAM}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Copy WTS Config Files From Local MultiDRB    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#...               AND    SA L3 Call and Collect Sherpa logs with multi DRBs
#Suite Teardown    Common Suite Teardown 2
#Force Tags        RAN_5G_TDD    FR1
#...               Owner_alicchen    PRI-High    CRT    RAN_5G
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
#&{GNB_ASIK}            ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#${LOCAL_WTS_DIR}       ${CURDIR}/config/SA_multiDRBs
#${LOCAL_WTS_CFG}       basic_fullstack_sa_call_tdd_cmwv.cfg
#${RD_PARAM}            0x570010=1
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${BEARER_ID}           2
#@{LOG_NAME_LIST}       btslog    snapshot
#${COUNT}               0
##${multi_drbs_basic_file_path}    ${CURDIR}/config/SA_multiDRBs
#
#*** Test Cases ***
#5GC001808-ET-N005-Verify SRB1 SRB2 info in Multi-DRB cases of DU_L2LO_SDU_DL Sherpa Trace on SA mode
#    [Documentation]    The purpose of this case is to check SRB1 SRB2 info in Multi-DRB cases of DU_L2LO_SDU_DL Sherpa Trace on SA mode
#    [Tags]    FR1    IPV6    PRI-Medium    Classical    5GC001808    Owner_alicchen
#    [Timeout]    23 min
#    Read csv file    RlcFlows
#    ${result3}    get_all_values_column2_from_column1    LCID DL    TEXT    4    DataAdded:TRUE
#    ${result4}    get_all_values_column2_from_column1    LCID DL    TEXT    5    DataAdded:TRUE
#    Should Be True    ${result3}    SRB1 SRB2 is not in Multi-DRB LoCtrl_DlBufferStatusInd of DU-L2LO_SDU_DL Sherpa Trace
#    Should Be True    ${result4}    SRB1 SRB2 is not in Multi-DRB LoCtrl_DlBufferStatusInd of DU-L2LO_SDU_DL Sherpa Trace
#
#*** Keywords ***
#Copy WTS Config Files From Local MultiDRB
#    [Arguments]    ${local_wts_dir}=${CURDIR}/config/SA_multiDRBs
#    OperatingSystem.Run    cp ${local_wts_dir}/${LOCAL_WTS_CFG} ${WTS_DIR}
#    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${LOCAL_WTS_CFG}
#    Set Suite Variable    ${WTS_CFG}    ${LOCAL_WTS_CFG}
#
#SA L3 Call and Collect Sherpa logs with multi DRBs
#    Config and get All L2stream logs including attach and traffic    "SA_multi_DRBs"     #///need to modify arguments for various L3CALL
#    Makesure UTEVM Sherpa tool can work
#    Convert Pcap To Sherpa Csv    ${SUITE_LOG_DIRECTORY}
