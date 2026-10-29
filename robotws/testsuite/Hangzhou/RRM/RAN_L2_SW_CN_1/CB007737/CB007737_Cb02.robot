*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               swconfig_param=${SWCONFIG_PARAM}    swconfig_param_AP=${SWCONFIG_PARAM_AP}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
#Suite Teardown    Common Suite Teardown
#Test Setup        Run Keywords    Common Test Setup
#...               AND    Block Cell With Admin    ${LOCKED_CELL}
#...               AND    Unblock Cell With Admin    ${LOCKED_CELL}
#...               AND    Wait Until Keyword Succeeds    2min    10s    Check Egate Log With Message    ${egate_path}    ${CELL_ON_AIR_MESSAGE}    2
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G    Owner_qiqluo
#...               SBTS00    SBTS23R1    SBTS22R4    CN1_SQ6    CB007737
#Resource          Resources/CB007737_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_CA_DSS.robot
#
#*** Variables ***
#${SWCONFIG_PARAM}                   0x580497=1;0x580538=1;0x580534=0x12;0x580535=0x10;0x580536=0xc;0x580537=0xa
#${SWCONFIG_PARAM_AP}                0x70670=0
#${SCF_PATH}                         ${CURDIR}/Config
#${FULL_SCF}                         CB007737_Cb02_scfc.xml
#${IPHY_FILE}                        ${CURDIR}/Resources/wts/iphy_4F_2T.xml
#${WTS_LOCAL}                        ${CURDIR}/Resources/wts
#${WTS_CFG}                          CB007737_Cb02.cfg
#${EGATE_PATH}                       /opt/iphy/latest/egate_console.log
#${LOCKED_CELL}                      MRBTS-1/NRBTS-1/NRCELL-5
#${CELL_ON_AIR_MESSAGE}              eNB 1 cell 5: SystemInformationBlockType1-NR
#${PDU_ID}                           1
#${DL_DATA}                          100
#${UL_DATA}                          50
#${3CC_DL_DATA}                      400
#@{CA_UE_LIST}                       1    2
#@{3CC_SCELL_PHYSICALID_1}           51    54
#@{3CC_SCELL_PHYSICALID_2}           50    54
#@{3CC_SCELL_PHYSICALID_LIST}        ${3CC_SCELL_PHYSICALID_1}    ${3CC_SCELL_PHYSICALID_2}
#${NONCA_START_UE_NUM}               3
#${NONCA_STOP_UE_NUM}                8
#${ENBID}                            2
#${GNBID}                            1
#${ALLOC_SUBFRAME1}                  0011100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
#${ALLOC_SUBFRAME2}                  0011101010-0111100110-0011101010-0111100110-0011101010-0111100110-0011101010-0111100110
#${PRB_LIST_20M_WITHOUT_BLANKING}    0,5|5,35|101,5
#${CELL1_ID}                         1
#${CELL2_ID}                         2
#${CELL3_ID}                         4
#${CELL4_ID}                         5
#${ANTP_NUM}                         2
#
#*** Test Cases ***
#CB007737_ET_CB02_ABIO_4F2T_MultiUE_Mixcore_CA_DPA_DSS
#    Configure 4CELL DSS    ${PRB_LIST_20M_WITHOUT_BLANKING}    30    100    20    70
#    Sleep    30s    reason=dss on
#    SA Multi UE Attach With Scell Blind Addition    ${CA_UE_LIST}    ${3CC_SCELL_PHYSICALID_LIST}    3
#    Multi NonCA UE Attach With Blind    ${NONCA_START_UE_NUM}    ${NONCA_STOP_UE_NUM}
#    SA Multi UE Start DL Traffic    ${CA_UE_LIST}    ${3CC_DL_DATA}
#    SA Multi UE Start UL Traffic    ${CA_UE_LIST}    ${UL_DATA}
#    Start NonCA Multi SA UE Traffic    ${NONCA_START_UE_NUM}    ${NONCA_STOP_UE_NUM}    dl    ${DL_DATA}
#    Start NonCA Multi SA UE Traffic    ${NONCA_START_UE_NUM}    ${NONCA_STOP_UE_NUM}    ul    ${UL_DATA}
#    Sleep    20s    reason=Wait For DLUL Transmission
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007737_Cb${/}CB007737_Cb02_dl.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007737_Cb${/}CB007737_Cb02_ul.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#
#*** Keywords ***
#Configure 4CELL DSS
#    [Arguments]    ${prb_list}    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
#    Setup XP LINK    ${ENBID}    ${GNBID}
#    Enable DSS DMS3 Feature On    ${ENBID}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL1_ID}    ${ANTP_NUM}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL2_ID}    ${ANTP_NUM}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL3_ID}    ${ANTP_NUM}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL4_ID}    ${ANTP_NUM}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL1_ID}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL2_ID}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL3_ID}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL4_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL1_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL2_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL3_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL4_ID}
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL1_ID}    DL
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL2_ID}    DL
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL3_ID}    DL
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL4_ID}    DL
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL1_ID}
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL2_ID}
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL3_ID}
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL4_ID}
#    Cell Allocation    ${ALLOC_SUBFRAME1}    ${prb_list}    ${ENBID}    ${GNBID}    ${CELL1_ID}
#    Cell Allocation    ${ALLOC_SUBFRAME1}    ${prb_list}    ${ENBID}    ${GNBID}    ${CELL2_ID}
#    Cell Allocation    ${ALLOC_SUBFRAME2}    ${prb_list}    ${ENBID}    ${GNBID}    ${CELL3_ID}
#    Cell Allocation    ${ALLOC_SUBFRAME2}    ${prb_list}    ${ENBID}    ${GNBID}    ${CELL4_ID}
