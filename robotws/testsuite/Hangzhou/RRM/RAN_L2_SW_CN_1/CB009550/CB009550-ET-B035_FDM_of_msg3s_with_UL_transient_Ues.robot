*** Settings ***
Documentation    Author
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Resource           ./CB009550_resource.robot
#Suite Setup        Common Suite Setup 2
#Suite Teardown     Common Suite Teardown 2
#Test Teardown     Common Test Teardown 2
#Force Tags        CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    CN1_SG09_SM1    CB009550
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/config/SCF/
#${LOCAL_WTS_DIR}            ${CURDIR}/config/WTS
#${WTS_DIR}                  /opt/iphy/latest
#${CB009550_BB035_SCF}       ${CURDIR}/config/SCF/CB009550_B35_SCF.xml
#${IPHY_4T}                  ${CURDIR}/config/WTS/B35iphy.xml
#${gnb_swconfig}             /home/ute/testline_init_results/configs/sm_swconfig.txt
#${ap_swconfig}              /home/ute/testline_init_results/configs/sim_swconfig.txt
#${SWCONFIG_PARAM_AP}        0x1003F=2;
#${SWCONFIG_PARAM_gnb}       0x480005=0;0x58012d=4;0x420068=4;0x450027=1;0x890008=1;0x1002A=1;0x3F007C=1024;
#${WTS_CFG_TDD_B035}         wts_CB009550_B035.cfg
#${UE1_ID}                   1
#${cell1_ID}                 50
#&{GNB_ASIK}                 ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#
#*** Test Cases ***
#CB009550-ET-B035_FDM_of_msg3s_with_UL_transient_Ues
#    [Documentation]
#    ...    Precondition:
#    ...      TDD 3CC all with 100M 48PRB
#    ...      Frame structure=1208
#    ...    Test Steps:
#    ...      Step1:Setup 3 Cells on LokiB
#    ...      Step2:Setup UE25 on Cell2 and UE26 on Cell3 and send traffic.Then register UE1-UE24 on Cell1.
#    ...      Step3:Trigger RRC Restablishment for UE1-UE24.
#    ...    Check Points:
#    ...      1)Check msg3 FDMed with msg5 or msg5 FDMed with msg5 in UE1-UE24.
#    ...      2)Check Tput for UE25 and UE26 is normal.
#    ...      3)Check SIB1 and OSI PRB is random.
#
#    [Tags]    caseB035    Manual_lading    TA_lading
#    [Setup]   Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_TDD_B035}
#    ...        AND    Suite Setup Update GNB    swconfig_param=${SWCONFIG_PARAM_gnb}    scf_file=${CB009550_BB035_SCF}
#                      ...    iphy_file=${IPHY_4T}    swconfig_param_AP=${SWCONFIG_PARAM_AP}
#    ...        AND    Copy File For Multi UEs    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    #Step1 Precondition for case
#    Verify Coam Site Is Ready
#    Suite Setup Start WTS And Check OnAir
#    Set beam_control_testmode For B035
#    #Step2 Setup 26UEs on 3Cells
#    Multi Calls For B035    25    10    8
#    #Step3 Trigger RRC Restablishment for UE1-UE24
#    Trigger RRC Reestablishment for B035
#    #Step4 Check points
#    Check Sib1 startPRB is Random    10
#    Check OSI startPRB is Random
#    Check msg5 FDMed with msg3 or msg5
#    Check Tput for UE25 and UE26 for B035
#
#*** Keywords ***


