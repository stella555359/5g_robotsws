*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Test Setup        Run Keywords    Delta Commission    delta_scf=${DELTA_SCF}
#...               AND    Suite Setup Start WTS And Check OnAir With Workaround
#...               AND    Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        Owner_w13li    CN1_SQ6    CB008015
#Resource          resources/CB008015_lib.robot
#
#*** Variables ***
#${SCF_PATH}      ${CURDIR}/config
#${FULL_SCF}      8015_full_scfc.xml
#${DELTA_SCF}     Delta_8015_B_14.json
#${IPHY_FILE}     ${CURDIR}/config/wts/iphy_4F_2T.xml
#${WTS_LOCAL}     ${CURDIR}/config/wts
#${WTS_CFG}       basic_8015_DSS.cfg
#${WTS_AP_XML}    airphone.xml
#${WTS_DIR}       /opt/wts/latest
#${UE_ID}         5
#${PCELL_ID}      52
#${SCELL1_ID}     51
#${SCELL2_ID}     55
#${TRAFFIC}       400
#${RSRP_1}        80
#${RSRP_2}        100
#${RSRQ}          70
#
#*** Test Cases ***
#CB008015_B_014_Verify_Scell_Change_With_RSRPCombined_And_ActAperCsi_Is_Disabled_For_Pcell_And_Scell
#    Set Reordering Timer    500    300
#    SA Attach    ${UE_ID}
#    Trigger A1 For Scelladdition And Check Tput
#    Trigger A1 For Scell Change And Check Tput
#    Stop SA DL Big Traffic Internal    ${UE_ID}    ${TRAFFIC}
#
#*** Keywords ***
#Trigger A1 For Scelladdition And Check Tput
#    Trigger A1 And Check Scell PhysicalID Before Scell Change
#    Start SA DL Big Traffic Internal    ${UE_ID}    ${TRAFFIC}
#    Run Keyword And Ignore Error    Check UE Tput With Bearer    dl    350
#    Check UE Pcell Scell Tput Before Scell Change
#    SA Start UL Traffic Internal    ${UE_ID}    1    50
#    Check UE Tput With Bearer    ul    20
#
#Trigger A1 For Scell Change And Check Tput
#    Trigger A1 And Check Scell PhysicalID After Scell Change
#    Run Keyword And Ignore Error     Check UE Tput With Bearer    dl    350
#    Check UE Pcell Scell Tput After Scell Change
#    Check UE Tput With Bearer    ul    40
#
#Check UE Pcell Scell Tput Before Scell Change
#    Check Tput On Target Pcell Plus Scell    ${UE_ID}    0    1    370
#
#Check UE Pcell Scell Tput After Scell Change
#    Check Tput On Target Pcell Plus Scell    ${UE_ID}    0    2    300
#
#Trigger A1 And Check Scell PhysicalID Before Scell Change
#    Trigger Scell Addition With CoverbaseA1 RsrpCombined    ${UE_ID}    ${PCELL_ID}    ${RSRP_1}    mea_id=1    rsrq=${RSRQ}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL1_ID}    1
#
#Trigger A1 And Check Scell PhysicalID After Scell Change
#    Trigger Scell Addition With CoverbaseA1 RsrpCombined    ${UE_ID}    ${PCELL_id}    ${RSRP_2}    mea_id=2    rsrq=${RSRQ}
#    Sleep    2s    reason=make sure scell addition complete
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL2_ID}    2
#    Sleep    3s    reason=make sure scell addition complete
#
