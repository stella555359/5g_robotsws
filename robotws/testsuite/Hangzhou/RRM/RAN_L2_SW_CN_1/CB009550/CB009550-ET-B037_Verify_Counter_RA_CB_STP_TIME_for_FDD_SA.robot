*** Settings ***
Documentation    ...
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Resource           ./CB009550_resource.robot
#Suite Setup        Common Suite Setup 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    RAN_5G_FDD    RAN_5G
#...               SBTS00    CN1_SG09_SM1    CB009550    CIT    CDRT
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/config/SCF/
#${LOCAL_WTS_DIR}            ${CURDIR}/config/WTS
#${WTS_DIR}                  /opt/iphy/latest
#${CB009550_B37_SCF}         ${CURDIR}/config/SCF/CB009550_B37_SCF.xml
#${iphy_B37}                 ${CURDIR}/config/WTS/B37iphy.xml
#${gnb_swconfig}             /home/ute/testline_init_results/configs/sm_swconfig.txt
#${ap_swconfig}              /home/ute/testline_init_results/configs/sim_swconfig.txt
#${wts_CB009550_B037}         wts_CB009550_B037.cfg
#${UE1_ID}                   1
#${cell1_ID}                 50
#&{GNB_ASIK}                 ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#
#*** Test Cases ***
#CB009550-ET-B037_Verify_Counter_RA_CB_STP_TIME_for_FDD_SA
#    [Documentation]
#    ...    Precondition:
#    ...      FDD 48PRB
#    ...    Test Steps:
#    ...      Step1:Setup Cell and configured feature parameters
#    ...      Step2:Setup Multi SA UEs on Cell1
#    ...    Check Points:
#    ...      1) Check counter M55306C09013.
#
#    [Tags]    caseB037    Manual_lading    TA_lading
#    [Setup]   Run Keywords    Set Test Variable    ${wts_cfg}    ${wts_CB009550_B037}
#    ...        AND    Suite Setup Update GNB        scf_file=${CB009550_B37_SCF}    iphy_file=${iphy_B37}
#    ...        AND    Copy File For Multi UEs    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    #Step1 Precondition for case
#    Verify Coam Site Is Ready
#    Suite Setup Start WTS And Check OnAir
#    #Step2 Setup 8UEs
#    Multi Calls For B037
#    #Step3 Check points
#    Check Msg2 Multiplexed With Msg2 For Same RARNTI For B037
#    Get and Check PM Counter For CBRA
#
#
#*** Keywords ***
#
#
