*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BLLL_AP_LOO    Owner_BZW
#...               SBTS00    SBTS23R4    CN1_SQ6    CB009550    RAN_5G    RAN_5G_fDD    CRT
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_CA_DSS.robot
#Resource          ./CB009550_resource.robot
#
#*** Variables ***
#${SCF_PATH}                     ${CURDIR}/resources/config
#${FULL_SCF}                     SCFC_CB009550_DSS.xml
#${IPHY_FILE}                    ${CURDIR}/resources/config/WTS/iphy_9550_DSS.xml
#${WTS_LOCAL}                    ${CURDIR}/resources/config/WTS
#${WTS_CFG}                      DSS_9550_20M.cfg
#${WTS_DIR}                      /opt/wts/latest
#@{LOG_NAME_LIST}                snapshot    btsLog
#${ENBID}                        2
#${GNBID}                        1
#${CELL5_ID}                     5
#${ANTP_NUM}                     2
#${MBSFN_SUBFRAME}               110000110000110000110000
#${NORMAL_SUBFRAME_P3_MODE}     1111110110-0111011110-1111110110-1111011111-0111111110-0111011111-1111011110-0111011111
#${20M_DL_PRB_LIST_P1}          0:0,100+1:1,3|5,3+2:20,2+5:0,100+9:0,100+15:0,100+19:0,100+25:0,100+29:0,100+35:0,100+39:0,
#${20M_DL_PRB_LIST_P2}          100+45:0,100+49:0,100+55:0,100+59:0,100+65:0,100+69:0,100+75:0,100+79:0,100
#${20M_UL_PRB_LST}              0,5|5,25|30,20
#${SWCONFIG_PARAM}              0x89003B=1;0x58057a=4;0x58057c = 1073741824;0x58057d = 536870912
#${UE_1}              1
#${UE_2}              2
#${UE_3}              3
#${UE_4}              4
#${UE_5}              5
#${UE_1_DL_TRF}       100
#${UE_1_UL_TRF}       10
#${UE_DL_TRF}         1
#${UE_UL_TRF}         5
#${MSG3_RETR_NUM}     5
#${CAUSE_REASON}      NAS_normal_release
#
##Case06
#${TTI_LOG_NAME}           l2stream3_ttitrace
#${TTI_LOG_CASE06_DIR1}    ${TEST_LOG_DIRECTORY}/ttitrace_streaming1
#${TTI_LOG_CASE06_DIR2}    ${TEST_LOG_DIRECTORY}/ttitrace_streaming2
#${A2A_CASE06_NAME_1}      CB009550_A_ttitrace_ini_dedicated_FDM.ini
#${A2A_CASE06_NAME_2}      CB009550_A_ttitrace_ini_dedicated_NoFDM.ini
#${A2A_PATH_06}            A2A_06_DSS
#
#*** Test Cases ***
#CB009550-ET-A006_Verify__ActFdmInitialDedicatedFdd_Modification_With_SA_FDD_10MHz
#    [Tags]    Owner_zbu   A06
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#    ...           swconfig_param=${SWCONFIG_PARAM}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And and load cfg file    enb_id=2    gnb_id=1
#    ...    AND    Common Test Setup
#    Configure_CELL_DSS    30    100    20    70
#    Ue Attach And Get Ttitrace    ${UE_5}    ${TEST_LOG_DIRECTORY}/ttitrace_streaming1
#    A2A Check TTI Log    ${A2A_CASE06_NAME_1}    ${TEST_LOG_DIRECTORY}/ttitrace_streaming1      ${A2A_PATH_06}
#    Changed_ActFdmInitialDedicatedFdd_And_Check_BTS_Status
#    Configure_CELL_DSS_Onlinechange    30    100    20    70
#    Ue Attach And Get Ttitrace    ${UE_5}    ${TEST_LOG_DIRECTORY}/ttitrace_streaming2
#    A2A Check TTI Log    ${A2A_CASE06_NAME_2}    ${TEST_LOG_DIRECTORY}/ttitrace_streaming2      ${A2A_PATH_06}
#    [Teardown]    Test Teardown Recover Env    scf_file=${SCF_TEST_BAK_FILE}    iphy_file=${IPHY_TEST_BAK_FILE}
#
#*** Keywords ***
#Configure_CELL_DSS
#    [Arguments]    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
#    Setup X2 Connection    ${ENBID}    ${GNBID}
#    Setup XP LINK    ${ENBID}    ${GNBID}
#    ute_wtssim.Execute Egate Command    cmd=enb_disp id=${ENBID} type=xp_info
#    Enable DSS DMS3 Feature On    ${ENBID}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL5_ID}    ${ANTP_NUM}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL5_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL5_ID}
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL5_ID}    DL
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL5_ID}
#    ${DL_PRB_LIST}    catenate    SEPARATOR=    ${20M_DL_PRB_LIST_P1}    ${20M_DL_PRB_LIST_P2}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE}    ${20M_UL_PRB_LST}    ${ENBID}    ${GNBID}    ${CELL5_ID}    ${DL_PRB_LIST}
#    common_setup_teardown.UE SIB Decoding Should Be Successful
#    Sleep    10s    reason=waiting for SIB for all cells
#
#Configure_CELL_DSS_Onlinechange
#    [Arguments]    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
#    Setup X2 Connection    ${ENBID}    ${GNBID}
#    Setup XP LINK    ${ENBID}    ${GNBID}
#    ute_wtssim.Execute Egate Command    cmd=enb_disp id=${ENBID} type=xp_info
#    Enable DSS DMS3 Feature On    ${ENBID}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL5_ID}    ${ANTP_NUM}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL5_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL5_ID}
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL5_ID}    DL
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL5_ID}
#    ${DL_PRB_LIST}    catenate    SEPARATOR=    ${20M_DL_PRB_LIST_P1}    ${20M_DL_PRB_LIST_P2}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE}    ${20M_UL_PRB_LST}    ${ENBID}    ${GNBID}    ${CELL5_ID}    ${DL_PRB_LIST}
#    Sleep    60s    reason=waiting for DSS cell MIB SIB
#
#Changed_ActFdmInitialDedicatedFdd_And_Check_BTS_Status
#    Online Change One Para With Admin
#    ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-5    parameter=actFdmInitialDedicatedFdd    value=false
#    Verify Coam Site Is Ready
#    Verify BTS Is OnAir
