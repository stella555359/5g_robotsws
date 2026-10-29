*** Settings ***
Documentation    ...
#Test Teardown      Common Test Teardown
#Suite Teardown     Common Suite Teardown
#Force Tags         CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G
#...                SBTS00    CN1_SG06    CB005934    owner_suxu
#
#Resource           Resource/CB005934_resource.robot
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Resource           ./../CUDU_L2/common_CA_DSS.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                CB005934_ET_B201_scfc.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_FILE}                ${CURDIR}/Config/wts/iphy_CB005934_ET_B201.xml
#${SWCONFIG_PARAM_GNB}       0x89003B=1
#${WTS_CFG}                  CB005934_ET_B201.cfg
#${CC_NUM}                   4
#${ANTP_NUM}                 2
#@{MIN_DLTPUT_LIST1}         12    7    7    7
#@{MAX_DLTPUT_LIST1}         25    18    18    18
#@{MIN_DLTPUT_LIST2}         6    5    3    3
#@{MAX_DLTPUT_LIST2}         16    12    10    10
#${MIN_ULTPUT_1}             15
#${MAX_ULTPUT_1}             30
#${MIN_ULTPUT_2}             6
#${MAX_ULTPUT_2}             12
#@{4CC_UE_LIST_CELL1}        1    2    3
#@{4CC_UE_LIST_CELL2}        4    5    6
#@{CA_UE_LIST}               1    2    3    4    5    6
#@{NONCA_UE_LIST}            7    8    9    10    11    12
#@{ALL_UE_LIST}              1    2    3    4    5    6    7    8    9    10    11    12
#@{CELL1_SCELL_PCI_LIST}         ${4CC_SCELL_PCI_1}    ${4CC_SCELL_PCI_1}    ${4CC_SCELL_PCI_1}
#@{4CC_SCELL_PCI_1}              51    53    54
#@{CELL2_SCELL_PCI_LIST}         ${4CC_SCELL_PCI_2}    ${4CC_SCELL_PCI_2}    ${4CC_SCELL_PCI_2}
#@{4CC_SCELL_PCI_2}              50    53    54
#${ENBID}                        2
#${GNBID}                        1
#${CELL1_ID}                     1
#${CELL2_ID}                     2
#${CELL3_ID}                     4
#${CELL4_ID}                     5
#${MBSFN_SUBFRAME}               110000110000110000110000
#${NORMAL_SUBFRAME_P3_MODE1}     0011101000-0111101110-0011101000-0111101110-0011101000-0111101110-0011101000-0111101110
#${NORMAL_SUBFRAME_P3_MODE2}     0010000000-0000000010-0000001000-0000000010-0010001000-0111101110-0011101000-0111101110
#${UL_PRB_LST1}                  0,5|5,45|50,70
#${UL_PRB_LST2}                  0,5|5,25|30,50
#
#*** Test Cases ***
#CB005934_ET_B201_6UEs_With_4CC_FDD_DLCA_Interworking_DSS_All_Cell_DssEnable
#    [Setup]    Run Keywords     Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM_GNB}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And and load cfg file    enb_id=2    gnb_id=1
#    ...        AND    Common Test Setup
#    Configure 4CELL DSS    30    100    20    70
#    Attach 12 UEs And Start DLUL Data Transfer
#    Check CA UEs DLUL Throughput    ${MIN_DLTPUT_LIST1}    ${MAX_DLTPUT_LIST1}    ${MIN_ULTPUT_1}    ${MAX_ULTPUT_1}
#    Check NonCA UEs DLUL Throughput    8    20    13    30
#    Change DSS Cell Allocation
#    Check CA UEs DLUL Throughput    ${MIN_DLTPUT_LIST2}    ${MAX_DLTPUT_LIST2}    ${MIN_ULTPUT_2}    ${MAX_ULTPUT_2}
#    Check NonCA UEs DLUL Throughput    5    12    5    11
#    SA Multi UE Stop DL And UL Traffic    ${ALL_UE_LIST}
#    SA Multi UE Detach    ${ALL_UE_LIST}
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#Configure 4CELL DSS
#    [Arguments]    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
#    Setup X2 Connection    ${ENBID}    ${GNBID}
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
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE1}    ${UL_PRB_LST1}    ${ENBID}    ${GNBID}    ${CELL1_ID}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE1}    ${UL_PRB_LST1}    ${ENBID}    ${GNBID}    ${CELL2_ID}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE1}    ${UL_PRB_LST1}    ${ENBID}    ${GNBID}    ${CELL3_ID}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE1}    ${UL_PRB_LST1}    ${ENBID}    ${GNBID}    ${CELL4_ID}
#    UE SIB Decoding Should Be Successful
#
#Attach 12 UEs And Start DLUL Data Transfer
#    SA Multi UE Attach With Scell Blind Addition    ${4CC_UE_LIST_CELL1}    ${CELL1_SCELL_PCI_LIST}    4
#    SA Multi UE Attach With Scell Blind Addition    ${4CC_UE_LIST_CELL2}    ${CELL2_SCELL_PCI_LIST}    4
#    SA Multi NonCA UE Attach    ${NONCA_UE_LIST}
#    SA Multi UE Start DL Traffic    ${CA_UE_LIST}    65
#    SA Multi UE Start UL Traffic    ${CA_UE_LIST}    30
#    SA Multi UE Start DL Traffic    ${NONCA_UE_LIST}    20
#    SA Multi UE Start UL Traffic    ${NONCA_UE_LIST}    30
#    Sleep    25s    reason=Wait For DL Transmission
#
#Check CA UEs DLUL Throughput
#    [Arguments]    ${MinDlTputList}    ${MaxDlTputList}    ${MinUlTput}    ${MaxUlTput}
#    FOR    ${ue_id}    IN    @{CA_UE_LIST}
#        Check Single UE DL All Pcell Scell Current TPut With Range    ${ue_id}    ${MinDlTputList}    ${MaxDlTputList}    ${CC_NUM}
#        Check CA UE Pcell Scell Cell Current TPut With Range    ${ue_id}    ul    0    ${MinUlTput}    ${MaxUlTput}
#    END
#
#Check NonCA UEs DLUL Throughput
#    [Arguments]    ${MinDlTput}    ${MaxDlTput}    ${MinUlTput}    ${MaxUlTput}
#    FOR    ${ue_id}    IN    @{NONCA_UE_LIST}
#        Check CA UE Pcell Scell Cell Current TPut With Range    ${ue_id}    dl    0    ${MinDlTput}    ${MaxDlTput}
#        Check CA UE Pcell Scell Cell Current TPut With Range    ${ue_id}    ul    0    ${MinUlTput}    ${MaxUlTput}
#    END
#
#Change DSS Cell Allocation
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE2}    ${UL_PRB_LST2}    ${ENBID}    ${GNBID}    ${CELL1_ID}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE2}    ${UL_PRB_LST2}    ${ENBID}    ${GNBID}    ${CELL2_ID}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE2}    ${UL_PRB_LST2}    ${ENBID}    ${GNBID}    ${CELL3_ID}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE2}    ${UL_PRB_LST2}    ${ENBID}    ${GNBID}    ${CELL4_ID}
#    Sleep    25s    reason=wait for data is stable
