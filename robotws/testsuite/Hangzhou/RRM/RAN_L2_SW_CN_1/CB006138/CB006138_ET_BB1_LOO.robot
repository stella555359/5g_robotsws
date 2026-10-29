*** Settings ***
Documentation    ...
#Suite Setup      Log To Console    Start cases BB1001 and BB2001
#Test Teardown    Run Keywords    Common Test Teardown
#...              AND    Teardown All Connections
#...              AND    Teardown All Aliases For Wts
#Force Tags       CLOUD_5G_I_BOO_AP_LOO   CRT    FR1    Owner_MINMLUO    SBTS00
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
#
#*** Test Cases ***
#CB006138_ET_BB1001_Verify_Successfully_Multiple_UEs_Scheduling_FDM_Activated_With_5GC001070_And_BF_Disabled
#    Multi 3CC UEs Scell Addition And Scell Activation For DL
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T3F_FILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    ...    AND    Delta Commission With SCF File    ${BB1001['DELTA_FILE']}
#	...    AND    Reboot TL And Check Configured
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    Multi 3CC UEs Send DL And UL Traffic
#    Multi 3CC UEs Stop Traffic
#
#CB006138_ET_BB2001_Verify_Successfully_Multiple_UEs_Scheduling_FDM_Activated_With_5GC001208_And_BF_Enabled
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T3F_FILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    ...    AND    Delta Commission With SCF File    ${BB2001['DELTA_FILE']}
#	...    AND    Reboot TL And Check Configured
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    Multi 3CC UEs Scell Addition And Scell Activation For DL
#    Multi 3CC UEs Send DL And UL Traffic
#    Multi 3CC UEs Stop Traffic
#
#*** Keywords ***
#Multi 3CC UEs Scell Addition And Scell Activation For DL
#    Multi UE Register    6    8
#    Sleep    3s    reason=Wait For Egate Print
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    Check All UE Scell On EGate Console Log    ${TEST_LOG_DIRECTORY}/egate_console.log
#
#Multi UE Register
#    [Arguments]    ${start_ue_num}    ${stop_ue_num}
#    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
#    Log To Console    ===============UE${ue_id} Register:==============
#    SA 5G CA Attach    ${ue_id}
#    END
#
#Check All UE Scell On EGate Console Log
#    [Arguments]    ${egate_path}
#    ${content}    OperatingSystem.Get File    ${egate_path}
#    ${patt}    Set Variable    sCellIndex\\s+(?P<index>\\w+),
#    ${matches}    String.Get Regexp Matches    ${content}    ${patt}
#    ${index}    Create List    sCellIndex 1,    sCellIndex 2,    sCellIndex 1,
#    ...    sCellIndex 2,    sCellIndex 1,    sCellIndex 2,
#    Collections.Lists Should Be Equal    ${matches}    ${index}
#
#Multi 3CC UEs Send DL And UL Traffic
#    FOR    ${ue_id}    IN RANGE    6    9
#    SA Start DL And UL Traffic    ${ue_id}
#    END
#
#Multi 3CC UEs Stop Traffic
#    FOR    ${ue_id}    IN RANGE    6    9
#    SA Stop Data Traffic Internal    ${ue_id}    ${pdu_id}
#    END
