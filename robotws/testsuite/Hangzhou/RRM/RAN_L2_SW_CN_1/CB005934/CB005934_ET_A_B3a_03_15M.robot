*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#Suite Teardown    Run Keywords    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    FR1    Owner_rewu    SBTS00    SBTS24R1
#...               RAN_5G    RAN_5G_FDD
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}              ${CURDIR}/Resource/Config
#${SCF_FILE}              15M_SCF.xml
#${IPHY_FILE}             ${CURDIR}/Resource/wts/15M_iphy.xml
#${DELTA_FILE}            Delta_conf_15M.json
#${RECOV_FILE}            Delta_NRREL_maxNumScellsDlFr1_recov.json
#${LOCAL_WTS_DIR}         ${CURDIR}/Resource/wts
#${WTS_CFG}               15M_setup.cfg
#${SCF_FILE_CHANGESCF}    Delta_NRREL_maxNumScellsDlFr1_remove.json
#${UE_ID}                 1
#${UE_ID_AFTER}           2
#${CC_NUM_BEFORE}         4
#${CC_NUM_AFTER}          3
#${SCELLS_INFO}           ('1', '51', '25'), ('2', '53', '71'), ('3', '54', '66')
#${SCELLS_AFTER}          ('1', '51', '25'), ('2', '54', '66')
#@{4CC_DL_TPUT_LIST}      150    150    100    150
#@{3CC_DL_TPUT_LIST}      100    100    100
#${EGATE_FILE}            /opt/iphy/latest/egate_console.log
#
#*** Test Cases ***
#CB005934_ET_A_B3a_03_deactivation_of_4CC_FDD_DL_CA_by_single_online_change
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_FILE}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    CA UE Attach And Data Transmit Then Stop Data Traffic    ${UE_ID}    ${SCELLS_INFO}    ${EGATE_FILE}
#    ...    ${4CC_DL_TPUT_LIST}    ${CC_NUM_BEFORE}
#    Delta Commission With SCF File    ${SCF_FILE_CHANGESCF}
#    Sleep    100s    reason=wait online changed succssfully
#    CA UE Attach And Data Transmit Then Stop Data Traffic    ${UE_ID_AFTER}    ${SCELLS_AFTER}    ${EGATE_FILE}
#    ...    ${3CC_DL_TPUT_LIST}    ${CC_NUM_AFTER}
#    [Teardown]    Run Keywords    Delta Commission With SCF File    ${RECOV_FILE}
#    ...    AND    Common Test Teardown
#
#*** Keywords ***
#CA UE Attach And Data Transmit Then Stop Data Traffic
#    [Arguments]    ${UE_ID}    ${SCELLS_INFO}    ${EGATE_FILE}    ${DL_TPUT_LIST}    ${CC_NUM}
#    SA 5G CA Attach    ${UE_ID}
#    Get And Check Scell Infos    ${SCELLS_INFO}    ${EGATE_FILE}
#    SA Start DL Traffic Internal    ${UE_ID}    1   800    1
#    SA Start UL Traffic Internal    ${UE_ID}    1    100    1
#    Sleep    100s    reason=Wait For Data Transmission
#    SA Get UE Average Traffic Internal    ${UE_ID}    1    dl    1
#    SA Get UE Average Traffic Internal    ${UE_ID}    1    ul    1
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${DL_TPUT_LIST}    ${CC_NUM}
#    SA Stop Data Traffic Internal    ${UE_ID}    1    dl
#    SA Stop Data Traffic Internal    ${UE_ID}    1    ul
