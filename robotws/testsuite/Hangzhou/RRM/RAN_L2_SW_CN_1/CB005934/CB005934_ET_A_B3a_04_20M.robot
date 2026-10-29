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
#${SCF_PATH}          ${CURDIR}/Resource/Config
#${SCF_FILE}          20M_SCF.xml
#${IPHY_FILE}         ${CURDIR}/Resource/wts/20M_iphy.xml
#${DELTA_FILE}        Delta_conf_15M.json
#${RECOV_FILE}        Delta_conf_15M.json
#${LOCAL_WTS_DIR}     ${CURDIR}/Resource/wts
#${WTS_CFG}           20M_setup.cfg
#${SCF_FILE_CHANGESCF}    20M_delete_CA.json
#${SCF_FILE_CHANGESCF_ADD_CA}    20M_recover_CA.json
#${UE_ID}             1
#${UE_ID_AFTER_REMOVE_CA}          2
#${UE_ID_AFTER_ADD_CA}          3
#${CC_NUM_BEFORE}       4
#${CC_NUM_AFTER_REMOVE_CA}        2
#${CC_NUM_AFTER_ADD_CA}        4
#${SCELLS_INFO}       ('1', '51', '66'), ('2', '53', '2'), ('3', '54', '66')
#${SCELLS_AFTER_REMOVE_CA}       ('1', '50', '2')
#@{4CC_DL_TPUT_LIST}          100    100    100    100
#@{2CC_DL_TPUT_LIST}          100    100
#${EGATE_FILE}        /opt/iphy/latest/egate_console.log
#${PDU_ID}            1
#
#*** Test Cases ***
#CB005934_ET_A_B3a_04_deactivation_of_4CC_FDD_DL_CA_by_multi_online_change
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_FILE}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#        ...    AND    Common Test Setup
#    CA UE Attach And Data Transmit Then Stop data traffic    ${UE_ID}    ${SCELLS_INFO}    ${EGATE_FILE}    ${4CC_DL_TPUT_LIST}    ${CC_NUM_BEFORE}
#    Delta Commission With SCF File    ${SCF_FILE_CHANGESCF}
#    Sleep    100s    reason=wait online changed succssfully
#    CA UE Attach And Data Transmit Then Stop data traffic    ${UE_ID_AFTER_REMOVE_CA}    ${SCELLS_AFTER_REMOVE_CA}
#    ...    ${EGATE_FILE}    ${2CC_DL_TPUT_LIST}    ${CC_NUM_AFTER_REMOVE_CA}
#    Backup Scf    ${TEST_LOG_DIRECTORY}    BeforeAddCA
#    Delta Commission With SCF File    ${SCF_FILE_CHANGESCF_ADD_CA}
#    Sleep    100s    reason=wait online changed succssfully
#    CA UE Attach And Data Transmit Then Stop data traffic    ${UE_ID_AFTER_ADD_CA}    ${SCELLS_INFO}    ${EGATE_FILE}
#    ...    ${4CC_DL_TPUT_LIST}    ${CC_NUM_AFTER_ADD_CA}
#    [Teardown]    Run Keywords    Delta Commission With SCF File    ${RECOV_FILE}
#    ...    AND    Common Test Teardown
#
#*** Keywords ***
#CA UE Attach And Data Transmit Then Stop data traffic
#    [Arguments]    ${UE_ID}    ${SCELLS_INFO}    ${EGATE_FILE}    ${DL_TPUT_LIST}       ${CC_NUM}
#    SA 5G CA Attach    ${UE_ID}
#    Get And Check Scell Infos    ${SCELLS_INFO}    ${EGATE_FILE}
#    SA Start DL Traffic Internal    ${UE_ID}    1    800    1
#    SA Start UL Traffic Internal    ${UE_ID}    1    100    1
#    Sleep    100s    reason=Wait For Data Transmission
#    SA Get UE Average Traffic Internal    ${UE_ID}    1    dl    1
#    SA Get UE Average Traffic Internal    ${UE_ID}    1    ul    1
#	Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${DL_TPUT_LIST}    ${CC_NUM}
#    SA Stop Data Traffic Internal    ${UE_ID}    1    dl
#    SA Stop Data Traffic Internal    ${UE_ID}    1    ul
