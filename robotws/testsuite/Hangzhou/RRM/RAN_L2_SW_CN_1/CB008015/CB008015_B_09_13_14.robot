*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHYFILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G    Owner_w13li
#...               SBTS00    SBTS23R1    SBTS22R4    CN1_SQ6    CB008015
#Resource          resources/CB008015_lib.robot
#
#*** Variables ***
#${SCF_PATH}       ${CURDIR}/config
#${FULL_SCF}       8015_full_scfc.xml
#${FULL_SCF_09}    8015_full_scfc_09.xml
#${DELTA_SCF_09}    Delta_8015_B_09.json
#${DELTA_SCF_13}    Delta_8015_B_13.json
#${DELTA_SCF_14}    Delta_8015_B_14.json
#${IPHY_FILE}      ${CURDIR}/config/wts/iphy_4F_2T.xml
#${WTS_LOCAL}      ${CURDIR}/config/wts
#${WTS_CFG}        basic_8015_DSS.cfg
#${WTS_AP_XML}     airphone.xml
#${WTS_DIR}        /opt/wts/latest
#${UE_ID}          5
#${PCELL_ID}       52
#${SCELL1_ID}      51
#${SCELL2_ID}      55
#${TRAFFIC}        400
#${RSRP_1}         80
#${RSRP_2}         100
#${RSRQ}           70
#
#*** Test Cases ***
#CB008015_B_009_Scell_Selection_Different_Weight_And_BW_Same_Cellload_Of_Blind_Scell_Addition
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_09}
#    ...               AND    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
#    ...               AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    54    1
#    Start Traffic And Check The Tput
#    Stop SA DL Big Traffic Internal    ${UE_ID}    ${TRAFFIC}
#
#
#CB008015_B_013_Verify_Scell_Change_With_RSRP_And_ActAperCsi_Is_Disabled_For_Pcell_And_Scell
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_SCF_13}
#    ...        AND    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
#    ...        AND    Common Test Setup
#
#    SA 5G CA Attach    ${UE_ID}
#    Trigger A1 For Scelladdition With RSRP And Check Tput
#    Trigger A1 With RSRP For Scell Change And Check Tput
#    Stop SA DL Big Traffic Internal    ${UE_ID}    ${TRAFFIC}
#    [Teardown]    Test Teardown 8015
#
#CB008015_B_014_Verify_Scell_Change_With_RSRPCombined_And_ActAperCsi_Is_Disabled_For_Pcell_And_Scell
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_SCF_14}
#    ...               AND    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
#    ...               AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID}
#    Trigger A1 With RSRPCombined For Scelladdition And Check Tput
#    Trigger A1 With RSRPCombined For Scell Change And Check Tput
#    Stop SA DL Big Traffic Internal    ${UE_ID}    ${TRAFFIC}
#    [Teardown]    Test Teardown 8015
#
#*** Keywords ***
#Start Traffic And Check The Tput
#    Start SA DL Big Traffic Internal    ${UE_ID}    ${TRAFFIC}
#	sleep    6s    reason=make sure DL stable
#    Run Keyword And Ignore Error    Check UE Tput With Bearer    dl    350
#    Check Tput On Target Pcell Plus Scell    ${UE_ID}    0    1    370
#    SA Start UL Traffic Internal    ${UE_ID}    1    50
#    Check UE Tput With Bearer    ul    20
#
#Trigger A1 With RSRPCombined For Scelladdition And Check Tput
#    Trigger A1 With RSRPCombined And Check Scell PhysicalID Before Scell Change
#    Start SA DL Big Traffic Internal    ${UE_ID}    ${TRAFFIC}
#    Run Keyword And Ignore Error    Check UE Tput With Bearer    dl    350
#    Check UE Pcell Scell Tput Before Scell Change
#    SA Start UL Traffic Internal    ${UE_ID}    1    50
#    Check UE Tput With Bearer    ul    20
#
#Trigger A1 With RSRPCombined For Scell Change And Check Tput
#    Trigger A1 With RSRPCombined And Check Scell PhysicalID After Scell Change
#    Run Keyword And Ignore Error    Check UE Tput With Bearer    dl    350
#    Check UE Pcell Scell Tput After Scell Change
#    Check UE Tput With Bearer    ul    40
#
#Check UE Pcell Scell Tput Before Scell Change
#    sleep    3s    reason=make sure DL stable
#    Check Tput On Target Pcell Plus Scell    ${UE_ID}    0    1    370
#
#Check UE Pcell Scell Tput After Scell Change
#    sleep    3s    reason=make sure DL stable
#    Check Tput On Target Pcell Plus Scell    ${UE_ID}    0    2    300
#
#Trigger A1 With RSRPCombined And Check Scell PhysicalID Before Scell Change
#    Trigger Scell Addition With CoverbaseA1 RsrpCombined    ${UE_ID}    ${PCELL_ID}    ${RSRP_1}    mea_id=1    rsrq=${RSRQ}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL1_ID}    1
#
#Trigger A1 With RSRPCombined And Check Scell PhysicalID After Scell Change
#    Trigger Scell Addition With CoverbaseA1 RsrpCombined    ${UE_ID}    ${PCELL_id}    ${RSRP_2}    mea_id=2    rsrq=${RSRQ}
#    Sleep    2s    reason=make sure scell addition complete
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL2_ID}    2
#    Sleep    3s    reason=make sure scell addition complete
#
#Trigger A1 For Scelladdition With RSRP And Check Tput
#    Trigger A1 With RSRP And Check Scell PhysicalID Before Scell Change
#    Start SA DL Big Traffic Internal    ${UE_ID}    ${TRAFFIC}
#    Run Keyword And Ignore Error    Check UE Tput With Bearer    dl    350
#    Check UE Pcell Scell Tput Before Scell Change
#    SA Start UL Traffic Internal    ${UE_ID}    1    50
#    Check UE Tput With Bearer    ul    20
#
#Trigger A1 With RSRP For Scell Change And Check Tput
#    Trigger A1 With RSRP And Check Scell PhysicalID After Scell Change
#    Run Keyword And Ignore Error    Check UE Tput With Bearer    dl    350
#    Check UE Pcell Scell Tput After Scell Change
#    Check UE Tput With Bearer    ul    40
#
#Trigger A1 With RSRP And Check Scell PhysicalID Before Scell Change
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ${UE_ID}    ${PCELL_ID}    ${RSRP_1}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL1_ID}    1
#
#Trigger A1 With RSRP And Check Scell PhysicalID After Scell Change
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ${UE_ID}    ${PCELL_ID}    ${RSRP_2}    mea_id=2
#    Sleep    2s    reason=make sure scell addition complete
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL2_ID}    2
#    Sleep    3s    reason=make sure scell addition complete
