*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x89003B=1
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    Owner_k3chen
#...               SBTS00    SBTS23R4    CN1_SQ6    CB005934    RAN_5G    RAN_5G_TDD    CRT
#Resource          Resource/CB005934_resource.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_CA_DSS.robot
#
#*** Variables ***
#${SCF_PATH}                     ${CURDIR}/Resource/Config
#${FULL_SCF}                     CB005934_ET_A_B11_02_scfc.xml
#${IPHY_FILE}                    ${CURDIR}/Resource/wts/iphy_CB005934_ET_A_B11_02.xml
#${WTS_LOCAL}                    ${CURDIR}/Resource/wts
#${WTS_CFG}                      CB005934_ET_A_B11_02.cfg
#${4CC_DL_DATA}                  950
#${4CC_UL_DATA}                  175
#${PDU_ID}                       1
#@{exp_min_tput_list1}           375    85    280    40
#@{exp_max_tput_list1}           395    105    300    60
#@{exp_min_tput_list2}           375    55    280    25
#@{exp_max_tput_list2}           395    75    300    35
#@{4CC_UE_LIST}                  1
#${4CC_UE_ID}                    1
#@{4CC_SCELL_PHYSICALID_1}       51    53    54
#@{4CC_SCELL_PHYSICALID_LIST}    ${4CC_SCELL_PHYSICALID_1}
#@{4CC_PCELL_ID_LIST}            50
#${ENBID}                        2
#${GNBID}                        1
#${CELL1_ID}                     1
#${CELL2_ID}                     2
#${CELL3_ID}                     4
#${CELL4_ID}                     5
#${ANTP_NUM}                     2
#${CC_NUM}                       4
#${MBSFN_SUBFRAME}               110000110000110000110000
#${NORMAL_SUBFRAME_P3_MODE1}     0011101000-0111101110-0011101000-0111101110-0011101000-0111101110-0011101000-0111101110
#${NORMAL_SUBFRAME_P3_MODE2}     0010000000-0000000010-0000001000-0000000010-0010001000-0111101110-0011101000-0111101110
#${UL_PRB_LST1}                  0,5|5,45|50,70
#${UL_PRB_LST2}                  0,5|5,25|30,50
#${UL_PRB_LST3}                  0,5|5,10|15,20
#${UL_PRB_LST4}                  0,5|5,5|15,5
#
#*** Test Cases ***
#CB005934_ET_A_B11_02_Single_5G_UE_support_for_4CC_FDD_DL_CA_interworking_with_DSS_n25_2A_n66A_N71a
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And and load cfg file    enb_id=2    gnb_id=1
#    ...    AND    Common Test Setup
#    Configure 2CELL DSS    30    100    20    70
#    SA 5G CA Attach    ${4CC_UE_ID}    ${PDU_ID}
#    Check SA All Scell PhysicalID With UE ID    ${4CC_UE_ID}    ${4CC_SCELL_PHYSICALID_1}    ${CC_NUM}
#    SA Start DL Traffic Internal    ${4CC_UE_ID}    ${PDU_ID}    ${4CC_DL_DATA}
#    SA Start UL Traffic Internal    ${4CC_UE_ID}    ${PDU_ID}    ${4CC_UL_DATA}
#    Sleep    10s    reason=wait for data is stable
#    Check Single UE DL All Pcell Scell Current TPut With Range    ${4CC_UE_ID}    ${exp_min_tput_list1}    ${exp_max_tput_list1}    ${CC_NUM}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE2}    ${UL_PRB_LST3}    ${ENBID}    ${GNBID}    ${CELL2_ID}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE2}    ${UL_PRB_LST3}    ${ENBID}    ${GNBID}    ${CELL4_ID}
#    Sleep    10s    reason=wait for data is stable
#    Check Single UE DL All Pcell Scell Current TPut With Range    ${4CC_UE_ID}    ${exp_min_tput_list2}    ${exp_max_tput_list2}    ${CC_NUM}
#    SA 5G Detach    ${4CC_UE_ID}
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#Configure 2CELL DSS
#    [Arguments]    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
#	Setup X2 Connection    ${ENBID}    ${GNBID}
#    Setup XP LINK    ${ENBID}    ${GNBID}
#    Enable DSS DMS3 Feature On    ${ENBID}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL2_ID}    ${ANTP_NUM}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL4_ID}    ${ANTP_NUM}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL2_ID}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL4_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL2_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL4_ID}
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL2_ID}    DL
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL4_ID}    DL
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL2_ID}
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL4_ID}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE1}    ${UL_PRB_LST1}    ${ENBID}    ${GNBID}    ${CELL2_ID}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE1}    ${UL_PRB_LST2}    ${ENBID}    ${GNBID}    ${CELL4_ID}
#    UE SIB Decoding Should Be Successful
#
