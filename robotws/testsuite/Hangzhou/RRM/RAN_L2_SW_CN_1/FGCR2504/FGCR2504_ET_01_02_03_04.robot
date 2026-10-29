*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${SCF_FILE}
#...               iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#...               AND    UE Attach Traffic And Capture BIP Log
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CRT    FR1    Owner_melwu    PRI-High    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R1    SBTS22R4
#...               CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./FGCR2504_Resource.robot
#
#*** Variables ***
#${RD_PARAM}          0x58012B=1
#${RESOURCE_PATH}     ${CURDIR}/resources
#${WTS_LOCAL}         ${CURDIR}/resources/wts
#${WTS_CFG}           basic_setup_2504.cfg
#${IPHY_FILE}         ${CURDIR}/resources/wts/iphy_2504.xml
#${SCF_PATH}          ${CURDIR}/config
#${SCF_FILE}          SCF_2504_1.xml
#${UE_ID}             11
#${PROFILE_ID}        1
#${GNB_ID}            2
#${CELL_ID}           1
#${BEARER_ID}         2
##@{OLD_CFG_PARAMS}    plmn=[0-9]+:[0-9]+
##@{NEW_CFG_PARAMS}    plmn=302:610
#@{LOG_NAME_LIST}     btslog    snapshot
#${COUNT}             0
#
#*** Test Cases ***
#FGCR2504_ET_01_Check_Cell_Setup_And_UE_Attach_Successfully
#    Run Keyword If    '${ATTACH_STATUS}'!='True'    Fail
#
#FGCR2504_ET_02_Check_S_1&S_Slot_DL_Data_Having_Not_Been_Scheduled
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}FGCR2504_ET_02.ini    i
#    ...    save_log_directory=${OUTPUT_DIR}
#
#FGCR2504_ET_03_Check_S+1&_S+2_Slot_UL_Data_Having_Been_Scheduled
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}FGCR2504_ET_03.ini    i
#    ...    save_log_directory=${OUTPUT_DIR}
#
#FGCR2504_ET_04_Check_S_2&S_1&S_Slot_Pattern
#    Run Keyword And Ignore Error    SSH.Disconnect
#    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
#    SSH.Execute    rm /tmp/node_L2RT20/tmp/ASP-*
#    SSH.Execute    bget 1:0 /tmp/node_L2RT20/tmp/ASP-2730_startup.zip /tmp/
#    SSH.Execute    unzip /tmp/ASP-2730_startup.zip -d /tmp/
#    ${slot15_res}    SSH.Execute    cat /tmp/ASP-2730_startup.log | grep "Slot\=15 Type\=DL(dl): SLOT_TYPE_B4"
#    Should Contain    ${slot15_res}    Slot=15 Type=DL(dl): SLOT_TYPE_B4
#    ${slot16_res}    SSH.Execute    cat /tmp/ASP-2730_startup.log | grep "Slot\=16 Type\=DL(dl): SLOT_TYPE_B0"
#    Should Contain    ${slot16_res}    Slot=16 Type=DL(dl): SLOT_TYPE_B0
#    Run Keyword And Ignore Error    SSH.Disconnect
#    Run Keyword And Ignore Error    OperatingSystem.Run    scp toor4nsn@192.168.255.1:/tmp/ASP-2730_startup.zip ${output_dir}
#
#*** Keywords ***
#UE Attach Traffic And Capture BIP Log
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    ${ATTACH_STATUS}    Run Keyword And Return Status    NSA Verify If Attach Passed
#    Set Suite Variable    ${ATTACH_STATUS}
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    2
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
#    Start Gnb BIP Log
#    Sleep    2s    reason=Capture BIP log
#    Stop Gnb BIP Log    ${OUTPUT_DIR}
#    Covert BIP To Csv
#    [Return]    ${ATTACH_STATUS}
#
