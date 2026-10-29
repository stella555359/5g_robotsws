*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CB006137    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_zhachen    CN1_SG06    SBTS00    SBTS23R1
#Resource          ../CB008015/resources/CB008015_lib.robot
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config/
#${FULL_SCFC}                 CB006137_AC_band25_66_71_77_41_scfc.xml
#${IPHY_XML}                  ${CURDIR}/config/WTS/iphy_5cell_band25_66_71_77_41.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/config/WTS
#${WTS_AP_XML}                airphone.xml
#${WTS_CFG}                   basic_setup_vonr.cfg
#${CA_UE_ID}                  1
#${SCELL1_PCI}                51
#${SCELL2_PCI}                60
#${SCELL3_PCI}                61
#
#
#*** Test Cases ***
#CB006137_ET_AC301_BO_Verify_Single_UE_DRX_Scell_Blind_Addition_2CC_UL_CA
#    SA Attach    sa_ue_id=${CA_UE_ID}
#    Check SA Scell PhysicalID With UE ID    ${CA_UE_ID}    ${SCELL1_PCI}    1
#    Check SA Scell PhysicalID With UE ID    ${CA_UE_ID}    ${SCELL2_PCI}    2
#    Check SA Scell PhysicalID With UE ID    ${CA_UE_ID}    ${SCELL3_PCI}    3
#    Check Scell Activated And DRX Configuration    scellNum=3
#    Check PM Counter
#    Start DL and UL Tput
#	Check Pcell And Scell Tput Per UE    ${CA_UE_ID}    50    150    300    300
#
#*** Keywords ***
#Suite Setup Make TL Ready
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}    swconfig_param=0x58056B=1;0x580307=0x5FE;0x58062d=1
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#
#Check PM Counter
#    wait until keyword succeeds    6min    30sec    Get PM Counter Active    M55308C11001
#    wait until keyword succeeds    1min    10sec    Get PM Counter Sleep    M55308C11002
#    ${value}    Evaluate    float(${M55308C11002_value})/float(${M55308C11001_value})
#    should be true    ${value}>6
#    should be true    ${value}<9
#
#Get PM Counter Active
#    [Arguments]    ${counter_id}
#    ${M55308C11001_value}    Get Latest PM Counter Value With Admin    ${counter_id}
#	set suite variable    ${M55308C11001_value}
#
#Get PM Counter Sleep
#    [Arguments]    ${counter_id}
#    ${M55308C11002_value}    Get Latest PM Counter Value With Admin    ${counter_id}
#	set suite variable    ${M55308C11002_value}
#
#Check Pcell And Scell Tput Per UE
#    [Arguments]    ${ueId}    ${PcellDlTput}    ${ScellDlTput}    ${ScellDlTput_2}    ${ScellDlTput_3}
#    Sleep   10s    reason=wait traffic to be stable
#    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${PcellDlTput}
#    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=scell    scell_index=1    target_tp=${ScellDlTput}
#    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=scell    scell_index=2    target_tp=${ScellDlTput_2}
#    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=scell    scell_index=3    target_tp=${ScellDlTput_3}
#
#Start DL and UL Tput
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=150    ${ul_tp_set}=150
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=3
#	SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=4
#	SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=5
#	SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=6
#	SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=7
#	SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=8
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=10
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=11
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=12
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=13
#	SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=14
#	SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=15
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=9
#
