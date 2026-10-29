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
#${SCF_PATH}             ${CURDIR}/config
#${FULL_SCF}             8015_full_scfc_09.xml
#${DELTA_SCF}            Delta_8015_B_09.json
#${IPHY_FILE}            ${CURDIR}/config/wts/iphy_4F_2T.xml
#${WTS_LOCAL}            ${CURDIR}/config/wts
#${WTS_CFG}              basic_8015_DSS.cfg
#${WTS_AP_XML}           airphone.xml
#${WTS_DIR}              /opt/wts/latest
#${UE_ID}                5
#${SCELL_ID}             54
#${TPUT}                 400
#${PCELL_TARGET_TPUT}    320
#${SCELL_TARGET_TPUT}    50
#
#*** Test Cases ***
#CB008015_B_009_Scell_Selection_Different_Weight_And_BW_Same_Cellload_Of_Blind_Scell_Addition
#    Set Reordering Timer    500    300
#    SA Attach    ${UE_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL_ID}    1
#    Start Traffic And Check The Tput
#    Stop SA DL Big Traffic Internal    ${UE_ID}    ${TPUT}
#
#*** Keywords ***
#Start Traffic And Check The Tput
#    Start SA DL Big Traffic Internal    ${UE_ID}    ${TPUT}
#    Run Keyword And Ignore Error    Check UE Tput With Bearer    dl    350
#    Check Tput On Target Pcell Plus Scell    ${UE_ID}    0    1    370
#    SA Start UL Traffic Internal    ${UE_ID}    1    50
#    Check UE Tput With Bearer    ul    20
