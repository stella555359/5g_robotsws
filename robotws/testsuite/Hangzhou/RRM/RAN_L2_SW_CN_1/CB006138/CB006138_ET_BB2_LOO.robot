*** Settings ***
Documentation    ...
#Suite Setup      Log To Console    Start cases BB4002 and BB4004
#Test Teardown    Run Keywords    Common Test Teardown
#...              AND    Teardown All Connections
#...              AND    Teardown All Aliases For Wts
#Force Tags       CLOUD_5G_I_BOO_AP_LOO    CRT    FR1    Owner_MINMLUO    SBTS00
#...              RAN_5G    RAN_5G_TDD
#Resource         ./CB006138_Resource.robot
#Variables        ./CB006138_ET_LOO.yaml
#
#*** Variables ***
#${FULL_FILE}         basic_2T3F_SCFC_LOO.xml
#${IPHY_2T3F_FILE}    ${CURDIR}/Resource/wts/iphy_2T3F_LOO.xml
#${LOCAL_WTS_DIR}     ${CURDIR}/Resource/wts
#${WTS_CFG}           basic_2T3F_LOO.cfg
#${SCF_PATH}          ${CURDIR}/Resource/Config
#${RECOV_FILE}        Delta_recov_rac.json
#${3CC_TTF_SCELLS}    ('1', '51', '66'), ('2', '55', '41')
#${3CC_TFF_SCELLS}    ('1', '50', '71'), ('2', '51', '66')
#
#*** Test Cases ***
#CB006138_ET_BB4004_Verify_Radio_Adimission_Control_During_SCell_Addition_Of_TDD_And_FDD_SCells_In_Alternative_4
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T3F_FILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    ...    AND    Delta Commission With SCF File    ${BB4004['DELTA_FILE']}
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    3
#    Get And Check Scell Infos    ${3CC_TTF_SCELLS}
#    SA 5G CA Attach    14
#    Get And Check Scell Infos    ${3CC_TTF_SCELLS}
#    SA 5G CA Attach    15
#    Get And Check Scell Infos    ${BB4004['2CC_TF_SCELLS']}
#
#CB006138_ET_BB4002_Verify_Radio_Adimission_Control_During_SCell_Addition_Of_TDD_And_FDD_SCells_In_Alternative_2
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T3F_FILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    ...    AND    Delta Commission With SCF File    ${BB4002['DELTA_FILE']}
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    3
#    Get And Check Scell Infos    ${3CC_TTF_SCELLS}
#    SA 5G CA Attach    14
#    Get And Check Scell Infos    ${3CC_TTF_SCELLS}
#    SA 5G CA Attach    15
#    Verify No Scells Are Activation
#
#*** Keywords ***
#Verify No Scells Are Activation
#    [Arguments]
#    [Documentation]    This keyword is to check whether scell actived from egate log.
#    Log To Console    verify Scell Info...
#    ${scell_activation}    Set Variable    SCellIndex 0 activated successfully.
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    ${check_rst}    Run    cat /opt/wts/latest/egate_console.log|grep -i "${scell_activation}"|wc -l
#    Should Be True    ${check_rst}==0
#    Log To Console    No scell added and activated...
