*** Settings ***
Documentation    ...
##Suite Setup       Suite Setup Make TL Ready With DSS
#Suite Teardown    Common Suite Teardown
##Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CB008015    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_suxu    CN1_SQ6    SBTS00
#Resource          resources/CB008015_lib.robot
#Resource          ./../CUDU_L2/common_CA_DSS.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config/
#${FULL_SCFC}                 8015_full_scfc_dss_LOO.xml
#${FULL_SCFC_B033}            8015_B033_scfc_dss_LOO.xml
#${DELTA_SCFC}                Delta_8015_B017.json
##${DELTA_SCFC_B033}           Delta_8015_B033.json
#${IPHY_XML}                  ${CURDIR}/config/wts/iphy_4F_2T_AP_LOO_DSS.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/config/wts
#${WTS_CFG}                   basic_8015_DSS_LOO.cfg
#${REORDERING_WINDOW_SIZE}    500
#${REORDERING_TIMER}          300
#${CA_UE_LIST}                1,3,4,5
#${CA_UE_LIST_B033}           1,5,6,11
#${ENBID}                        2
#${GNBID}                        1
#${CELL1_ID}                     1
#${ANTP_NUM}                     2
#${MBSFN_SUBFRAME}               110000110000110000110000
#${NORMAL_SUBFRAME_P3_MODE}     0011101000-0111101110-0011101000-0111101110-0011101000-0111101110-0011101000-0111101110
#${UL_PRB_LST_10MHz}                  0,3|5,35|49,3
#${UL_PRB_LST_20MHz}                  0,5|5,45|50,70
#
#*** Test Cases ***
#CB008015_B_017_Verify_4_UEs_Of_Mix_CA_Mode_And_FDDCell_F2_As_Pcell_With_A1_Based_SCell_Addition_Method_When_SA
#    [Setup]    Run Keywords    Suite Setup Make TL Ready With DSS
#    ...        AND    Common Test Setup
#    Attach 4 CA UE And Check Scell Addition Successful
#    Start SA DL Big Traffic Internal    ue_id=1    mbps=150
#    Start SA DL Big Traffic Internal    ue_id=3    mbps=300
#    Start SA DL Big Traffic Internal    ue_id=4    mbps=150
#    Start SA DL Big Traffic Internal    ue_id=5    mbps=300
#    CA UE Start UL Traffic And Check Tput    sa_ue_list=${CA_UE_LIST}
#    [Teardown]    CB008015 B017 Teardown
#
#CB008015_B_033_Bufferbase_CA_20MHz_DSS_4UE_SA
#    [Setup]    Run Keywords    Test033 Setup Make TL Ready With DSS
#    ...        AND    Common Test Setup
#    Attach 4 CA UE And Check Scell Addition B033
#    Start SA DL Big Traffic Internal    ue_id=1    mbps=150
#    Start SA DL Big Traffic Internal    ue_id=5    mbps=300
#    Start SA DL Big Traffic Internal    ue_id=6    mbps=150
#    Start SA DL Big Traffic Internal    ue_id=11    mbps=300
#    CA UE Start UL Traffic And Check Tput B033    sa_ue_list=${CA_UE_LIST_B033}
#
#
#*** Keywords ***
#Suite Setup Make TL Ready With DSS
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    Run Keyword And Ignore Error    Delta Commission With SCF File    ${DELTA_SCFC}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And and load cfg file
#    Config DSS Resource    ${UL_PRB_LST_10MHz}    30    100    20    70
#    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#Test033 Setup Make TL Ready With DSS
#    Suite Setup Update GNB    scf_file=${FULL_SCFC_B033}    iphy_file=${IPHY_XML}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Set WTS CFG LTE To 20MHz
#    Suite Setup Start WTS And and load cfg file
#    Config DSS Resource    ${UL_PRB_LST_20MHz}    30    100    20    70
#    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#Attach 4 CA UE And Check Scell Addition Successful
#    [Documentation]    This keyword is to attach 4 CA UE:
#    ...    Fdd cell1:10MHz DSS, Fdd cell2:10MHz, Tdd cell3 60MHz
#    ...    UE1 Fdd cell1+Fdd cell2
#    ...    UE3 Fdd cell2+Tdd cell3
#    ...    UE4 Fdd cell2+Fdd cell1
#    ...    UE5 Tdd cell3+Fdd cell1
#    SA Attach    sa_ue_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=1    scell_physicalid=51    scell_index=1
#    SA Attach    sa_ue_id=3
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=3    pcell_id=51    rsrp=95    mea_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=3    scell_physicalid=52    scell_index=1
#    SA Attach    sa_ue_id=4
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=4    pcell_id=51    rsrp=95    mea_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=4    scell_physicalid=50    scell_index=1
#    SA Attach    sa_ue_id=5
#    Check SA Scell PhysicalID With UE ID    ue_id=5    scell_physicalid=50    scell_index=1
#
#Attach 4 CA UE And Check Scell Addition B033
#    [Documentation]    This keyword is to attach 4 CA UE:
#    ...    Fdd cell1:20MHz DSS, Tdd cell3:60MHz, Tdd cell6 60MHz
#    ...    UE1 Fdd cell1+Tdd cell3
#    ...    UE5 Tdd cell3+Tdd cell6
#    ...    UE6 Tdd cell3+Fdd cell1
#    ...    UE11 Tdd cell6+Tdd cell3
#    SA Attach    sa_ue_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=1    scell_physicalid=52    scell_index=1
#    SA Attach    sa_ue_id=5
#    Check SA Scell PhysicalID With UE ID    ue_id=5    scell_physicalid=55    scell_index=1
#    SA Attach    sa_ue_id=6
#    Check SA Scell PhysicalID With UE ID    ue_id=6    scell_physicalid=50    scell_index=1
#    SA Attach    sa_ue_id=11
#    Check SA Scell PhysicalID With UE ID    ue_id=11    scell_physicalid=52    scell_index=1
#
#CA UE Start UL Traffic And Check Tput
#    [Arguments]    ${sa_ue_list}
#    [Documentation]    this keyword is to start ul udp traffic, then check tput
#    @{ue_list}    Split String    ${sa_ue_list}    ,
#    : FOR    ${t_ue_id}    IN    @{ue_list}
#    \    SA Start UL Traffic Internal    ue_id=${t_ue_id}    pdu_id=1    mbps=40    trf_id=1
#    Check Tput Per UE    ueId=1    dlTput=28    ulTput=32    PcellDlTput=9    ScellDlTput=20
#    Check Tput Per UE    ueId=3    dlTput=220    ulTput=25    PcellDlTput=20    ScellDlTput=200
#    Check Tput Per UE    ueId=4    dlTput=35    ulTput=20    PcellDlTput=20    ScellDlTput=15
#    Check Tput Per UE    ueId=5    dlTput=215    ulTput=33    PcellDlTput=200    ScellDlTput=15
#
#CA UE Start UL Traffic And Check Tput B033
#    [Arguments]    ${sa_ue_list}
#    [Documentation]    this keyword is to start ul udp traffic, then check tput
#    @{ue_list}    Split String    ${sa_ue_list}    ,
#    : FOR    ${t_ue_id}    IN    @{ue_list}
#    \    SA Start UL Traffic Internal    ue_id=${t_ue_id}    pdu_id=1    mbps=50    trf_id=1
#    Check Tput Per UE    ueId=1    dlTput=130    ulTput=40    PcellDlTput=55    ScellDlTput=80
#    Check Tput Per UE    ueId=5    dlTput=260    ulTput=35    PcellDlTput=90    ScellDlTput=180
#    Check Tput Per UE    ueId=6    dlTput=120    ulTput=15    PcellDlTput=100    ScellDlTput=33
#    Check Tput Per UE    ueId=11    dlTput=250    ulTput=45    PcellDlTput=190    ScellDlTput=80
#
#Check Tput Per UE
#    [Arguments]    ${ueId}    ${dlTput}    ${ulTput}    ${PcellDlTput}    ${ScellDlTput}
#    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    30s    5s    SA UE Check Throughput    ${ueId}    ${dlTput}    ${ulTput}
#    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${PcellDlTput}
#    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=scell    scell_index=1    target_tp=${ScellDlTput}
#
#Set WTS CFG LTE To 20MHz
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    enb=2 bw=10MHz
#    @{new_params_list}    Create List    enb=2 bw=20MHz
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
#
#Config DSS Resource
#   [Arguments]    ${UL_PRB_LST}    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
#    Setup X2 Connection    ${ENBID}    ${GNBID}
#    Setup XP LINK    ${ENBID}    ${GNBID}
#    Enable DSS DMS3 Feature On    ${ENBID}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL1_ID}    ${ANTP_NUM}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL1_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL1_ID}
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL1_ID}    DL
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL1_ID}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE}    ${UL_PRB_LST}    ${ENBID}    ${GNBID}    ${CELL1_ID}
#    UE SIB Decoding Should Be Successful
#
#B017 detach UEs
#    [Arguments]    ${sa_ue_list}
#    @{ue_list}    Split String    ${sa_ue_list}    ,
#    : FOR    ${t_ue_id}    IN    @{ue_list}
#    \    SA 5G Detach    ue_id=${t_ue_id}
#
#CB008015 B017 Teardown
#    B017 detach UEs    sa_ue_list=${CA_UE_LIST}
#    ute_wtssim.Execute Egate Command    reset
