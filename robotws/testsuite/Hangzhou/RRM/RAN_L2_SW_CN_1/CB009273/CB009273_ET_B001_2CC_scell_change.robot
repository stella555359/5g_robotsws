*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Change GNB From Fullstack To L1bypass ASOE
#...               AND    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}    swconfig_param_AP=${SWCONFIG_PARAM_AP}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir    enb_id=${ENBID}    gnb_id=${GNBID}
#Suite Teardown    Run Keywords    Common Suite Teardown
#...               AND    Delta Commission With SCF File    ${RECOV_FILE}
#Test Setup        Common Test Setup    delta_jason=${DELTA_FILE}
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_O_E_AP_KL_SANSA_FS_CPRI_CMWV_FDD    CRT    FR1    Owner_rewu    SBTS00    SBTS23R1    SBTS22R4
#...               RAN_5G    RAN_5G_FDD
#Resource          Resource/CB009273_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                         ${CURDIR}/Config
#${SWCONFIG_PARAM_AP}                0x70670=0
#${SCF_FILE}                         DSS_SCF_2CC_ASOE.xml
#${SCF_FILE_CHANGESCF}               Delta_NRREL_Lcrid3.json
#${IPHY_FILE}                        ${CURDIR}/Resource/wts/DSS_3ccASOE.xml
#${DELTA_FILE}                       Delta_ASOE.json
#${RECOV_FILE}                       Delta_Recover_ASOE.json
#${LOCAL_WTS_DIR}                    ${CURDIR}/Resource/wts
#${WTS_CFG}                          DSS_3ccASOE.cfg
#${WTS_AP_XML}                       DSS_3ccASOE.xml
#${EGATE_PATH}                       /opt/iphy/latest/egate_console.log
#${UE_ID}                            1
#${PDU_ID}                           1
#${ENBID}                            2
#${GNBID}                            1
#@{CA_UE_LIST}                       1
#${2CC_DL_DATA}                      350
#${UL_DATA}                          10
#${PCELL_UL_TPUT}                    5
#${PCELL_DL_TPUT}                    5
#${SCELL1_DL_TPUT}                   5
#@{2CC_SCELL_PHYSICALID_1}           51
#@{2CC_SCELL_PHYSICALID_2}           52
#@{2CC_SCELL_PHYSICALID_LIST1}       ${2CC_SCELL_PHYSICALID_1}
#@{2CC_SCELL_PHYSICALID_LIST2}       ${2CC_SCELL_PHYSICALID_2}
#${ALLOC_SUBFRAME1}                  0011100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
#${ALLOC_SUBFRAME2}                  0011101010-0111100110-0011101010-0111100110-0011101010-0111100110-0011101010-0111100110
#${PRB_LIST_20M_WITHOUT_BLANKING}    0,5|5,35|101,5
#${CELL1_ID}                         1
#${CELL2_ID}                         2
#${CELL3_ID}                         3
#${ANTP_NUM}                         2
#
#*** Test Cases ***
#CB009273_ET_B001_Verify_CA_Relation_Of_FDD_FDD_Updated
#    Configure 3CELL DSS    ${PRB_LIST_20M_WITHOUT_BLANKING}    30    100    20    70
#    Multi 2CC UE Attach With Blind    ${CA_UE_LIST}    ${2CC_SCELL_PHYSICALID_LIST1}
#    Start Multi SA UE Big Traffic    ${CA_UE_LIST}    ${PDU_ID}    ${2CC_DL_DATA}
#    Start Multi SA UE Traffic    ${CA_UE_LIST}    ${PDU_ID}    ul    ${UL_DATA}
#    Sleep    30s    reason=Wait For Data Transmission
#    Multi 2CC UE Check TPUT    ${CA_UE_LIST}    ${PDU_ID}    ${PCELL_UL_TPUT}    ${PCELL_DL_TPUT}    ${SCELL1_DL_TPUT}
#    Delta Commission With SCF File    ${SCF_FILE_CHANGESCF}
#    Sleep    120s    reason=wait online changed succssfully
#    SA 5G CA Attach    1
#    Start Multi SA UE Big Traffic    ${CA_UE_LIST}    ${PDU_ID}    ${2CC_DL_DATA}
#    Start Multi SA UE Traffic    ${CA_UE_LIST}    ${PDU_ID}    ul    ${UL_DATA}
#    Sleep    30s    reason=Wait For Data Transmission
#    Multi 2CC UE Check TPUT    ${CA_UE_LIST}    ${PDU_ID}    ${PCELL_UL_TPUT}    ${PCELL_DL_TPUT}    ${SCELL1_DL_TPUT}
#	${physCellId_list}    Get PhysCellId From Egate Log    1    ${egate_path}
#    Should Not Be Equal    ${physCellId_list[0]}    ${physCellId_list[1]
