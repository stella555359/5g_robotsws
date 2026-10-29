*** Settings ***
Documentation    ...
#Suite Setup       Log To Console    Start cases AAB6002 and AAB7002
#Test Teardown    Run Keywords    Common Test Teardown
#...              AND    Teardown All Connections
#...              AND    Teardown All Aliases For Wts
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    FR1    Owner_MINMLUO    SBTS00
#...               RAN_5G    RAN_5G_TDD
#Resource          ./CB006138_Resource.robot
#Variables         ./CB006138_ET_LOO.yaml
#
#*** Variables ***
#${FULL_FILE}         basic_2T3F_SCFC_LOO.xml
#${IPHY_2T3F_FILE}    ${CURDIR}/Resource/wts/iphy_2T3F_LOO.xml
#${LOCAL_WTS_DIR}     ${CURDIR}/Resource/wts
#${WTS_CFG}           basic_2T3F_LOO.cfg
#${SCF_PATH}          ${CURDIR}/Resource/Config
#
#*** Test Cases ***
#CB006138_ET_AAB6002_Verify_Single_UE_Call_Blind_Scell_Addition_And_Blind_Scell_Activation_With_BF_Enabled_1T_Plus_2F
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T3F_FILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    ...    AND    Delta Commission With SCF File    ${AAB6002['DELTA_FILE']}
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    Single 3CC UE Blind Scell Addition And Scell Activation For DL CA Should Succeed    ${UE_ID_3}
#    SA Start DL And UL Traffic    ${UE_ID_3}
#    SA Stop DL And UL Traffic    ${UE_ID_3}
#    Check Configuration Of PUCCH Format 3 Resources In The TDD Pcell Should Be Correct
#
#CB006138_ET_AAB7002_Verify_Single_UE_Call_Blind_Scell_Activation_With_BF_Enabled_And_Refine_Beam_Enabled_2T_Plus_1F
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T3F_FILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    ...    AND    Delta Commission With SCF File    ${AAB7002['DELTA_FILE']}
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    Single 3CC UE Blind Scell Addition And Scell Activation For DL CA Should Succeed    ${UE_ID_6}
#    SA Start DL And UL Traffic    ${UE_ID_6}
#    SA Stop DL And UL Traffic    ${UE_ID_6}
#    Check Configuration Of PUCCH Format 3 Resources In The TDD Pcell Should Be Correct
#
#*** Keywords ***
