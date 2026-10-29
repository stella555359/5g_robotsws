*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown    debug
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    FR1    Owner_minmluo    SBTS00    SBTS24R1
#...               RAN_5G    RAN_5G_FDD
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/Config/
#${SCF_FILE}         CB005934_ET_A_B6a.xml
#${IPHY_FILE}        ${CURDIR}/Config/wts/ta_40M30M20M10M_iphy_ute.xml
#${LOCAL_WTS_DIR}    ${CURDIR}/Config/wts
#${WTS_CFG}          5934_5F_B9a.cfg
#${SCF_PATH}         ./Config
#${UE_ID}            1
#${SCELLS_INFO}      ('1', '51', '25'), ('2', '53', '25'), ('3', '54', '66')
#${EGATE_FILE}       /opt/iphy/latest/egate_console.log
#${PDU_ID}           1
#${SRSRP_NR}         102
#&{COUNTER1_INFO}    counter_id=M55316C03003    counter_path=CELLS/NRCELL-1/NCADU    min_value=1    max_value=20
#&{COUNTER2_INFO}    counter_id=M55316C05003    counter_path=CELLS/NRCELL-1/NCADU    min_value=0    max_value=2
#@{COUNTER_LIST}     ${COUNTER1_INFO}    ${COUNTER2_INFO}
#@{LOG_NAME_LIST}    btslog    egatelog
#
#*** Test Cases ***
#CB005934_ET_A_B6a_04_Single_FDD_4CCUE_Call_BufferBased_Scell_Activation_With_IniNumSCellsToActivate_0
#    SA 5G CA Attach    ${UE_ID}
#    Trigger A1 Scell Addition And Check Scell Infos
#    Start Low DL And UL Traffic And Check TPut
#    Send High DL Data And Check TPut
#    Verify Scells Are Activation    3
#    Moving UE To SCell Bad Coverage Area    ${UE_ID}
#    Check Tput After One Scell Released
#    Check Multi PM Counters
#
#*** Keywords ***
#Start Low DL And UL Traffic And Check TPut
#    SA Start DL Traffic Internal    ${UE_ID}    ${PDU_ID}    20    1
#    SA Start UL Traffic Internal    ${UE_ID}    ${PDU_ID}    20    1
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    pcell    0    1
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    ul    pcell    0    1
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    1    0
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    2    0
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    3    0
#
#Send High DL Data And Check TPut
#    SA Start DL Traffic Internal    ${UE_ID}    ${PDU_ID}    800    1
#    Sleep    5s
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    pcell    0    10
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    1    10
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    2    10
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    3    10
#
#Check Tput After One Scell Released
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    pcell    0    10
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    2    10
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    3    10
#
#Check Multi PM Counters
#    Wait Until PM Counter Update    5min
#    Wait Until Keyword Succeeds     2min     10s      Check Multi PM Counters Latest Value From Admin    ${COUNTER_LIST}
#
#Trigger A1 Scell Addition And Check Scell Infos
#    Trigger A1 Scell Addition    1    ${SRSRP_NR}    50
#    Get And Check Scell Infos    ${SCELLS_INFO}    ${EGATE_FILE}
#
#Moving UE To SCell Bad Coverage Area
#    [Arguments]    ${ue_id}
#    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id=1 target_mcs=5 num_dl_pkts=10000
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${ue_id} scell=1 testmode=bler action=activate profile_id=1
#    ...    pass_regexp=SCellIndex 1 deactivated successfully    timeout=3minutes
