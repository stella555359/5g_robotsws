*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CB006137    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_suxu    CN1_SQ6    SBTS00    SBTS23R1
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
#${GBR_TPUT_DL}               20
#${GBR_TPUT_UL}               10
#
#*** Test Cases ***
#CB006137_ET_AC501_BO_1UE_DrxVoNR_2CC_UL_CA
#    SA Attach    sa_ue_id=${CA_UE_ID}
#    Check SA Scell PhysicalID With UE ID    ${CA_UE_ID}    ${SCELL1_PCI}    1
#    Check SA Scell PhysicalID With UE ID    ${CA_UE_ID}    ${SCELL2_PCI}    2
#    Check SA Scell PhysicalID With UE ID    ${CA_UE_ID}    ${SCELL3_PCI}    3
#    Check Scell Activated And DRX Configuration    scellNum=3
#    Trigger 5QI 5 Setup    ${CA_UE_ID}
#    Trigger 5QI 1 Setup    ${CA_UE_ID}
#    Check RRC Reconfig For VoNRDrx Profile2
#    Start SA VONR GBR DL And UL Traffic    ueId=${CA_UE_ID}    qfi_id=3    dl_trf=${GBR_TPUT_DL}    ul_trf=${GBR_TPUT_UL}
#    Wait Until Keyword Succeeds    20s    5s    SA UE Check Throughput    ${CA_UE_ID}    dl_tp_threshold=19    ul_tp_threshold=9    qfi=3
#    Check Pcell And Scell Tput Per UE    ${CA_UE_ID}    19    0    9    0
#    Start nonGBR Traffic And Check Tput    ${CA_UE_ID}    600    100    500    70
#    Check Pcell And Scell UL Tput Per UE    ${CA_UE_ID}    25    0    35    0
#    Check Pcell And Scell DL Tput Per UE    ${CA_UE_ID}    40    80    150    150
#    SA UE Check Throughput    ${CA_UE_ID}    dl_tp_threshold=15    ul_tp_threshold=2    qfi=3
#
#*** Keywords ***
#Suite Setup Make TL Ready
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}    swconfig_param=0x58056B=1;0x580307=0x5FE;0x58062d=1
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#Start nonGBR Traffic And Check Tput
#    [Arguments]    ${ue}    ${dl_trf}    ${ul_trf}    ${dl_peak_tput}    ${ul_peak_tput}
#    Start SA UL Big Traffic Internal    ${ue}    ${ul_trf}
#    Start SA DL Big Traffic Internal    ${ue}    ${dl_trf}
#    Wait Until Keyword Succeeds    30s    5s    SA UE Check Throughput    ${CA_UE_ID}    ${dl_peak_tput}    ${ul_peak_tput}    qfi=1
#
