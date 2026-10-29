*** Settings ***
Documentation    ...
#Suite Setup      Log To Console    Start cases ABB1004, AAB2002 and AAB5002
#Test Teardown    Run Keywords    Common Test Teardown
#...              AND    Teardown All Connections
#...              AND    Teardown All Aliases For Wts
#Force Tags       CLOUD_5G_I_BOO_AP_LOO    CRT    FR1    Owner_JSHEN    SBTS00
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
#CB006138_ET_ABB1004_Verify_Behavior_When_Load_Of_One_Cell_Is_Higher_Than_The_Other
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T3F_FILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    ...    AND    Delta Commission With SCF File    ${ABB1004['DELTA_FILE']}
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID_2}
#    SA 5G CA Attach    ${UE_ID_3}
#    Check 3CC UE Is Configured With Cell2 And Cell3 As Scells
#
#CB006138_ET_ABB2002_Verify_Successfully_A1_Based_Addition_And_Buffer_Based_Scells_Activation_Deactivation_With_BF_Enabled
#    [Documentation]
#    ...    bufferThesholdSCellDePrioritize=20000kB.
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T3F_FILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    ...    AND    Delta Commission With SCF File    ${ABB2002['DELTA_FILE']}
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID_6}
#    A1 Triggered Scell Addition
#    Check Scells Are Added    physCellId 55    physCellId 51    physCellId 52
#    SA Start DL And UL Traffic    ${UE_ID_6}
#    Check Scells Are Activated
#    SA Stop DL And UL Traffic    ${UE_ID_6}
#    SA Start DL And UL Traffic    ${UE_ID_6}
#
#*** Keywords ***
#Check 3CC UE Is Configured With Cell2 And Cell3 As Scells
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    ${CONTENT}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/egate_console.log
#    ${PATT}    Set Variable    physCellId\\s+\\d\\d
#    ${MATHCES}    String.Get Regexp Matches    ${CONTENT}    ${PATT}
#    ${PHYSCELLIDLIST}    Create List    physCellId 50    physCellId 55
#    Collections.Lists Should Be Equal    ${MATHCES}    ${PHYSCELLIDLIST}
#
#Check Scells Are Activated
#    Sleep    2s    reason=Wait For egate print
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    ${CONTENT}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/egate_console.log
#    ${PATT}    Set Variable    SCellIndex\\s+\\d\\s+activated successfully
#    ${MATHCES}    String.Get Regexp Matches    ${CONTENT}    ${PATT}
#    Sort List    ${MATHCES}
#    ${PHYSCELLIDLIST}    Create List    SCellIndex 1 activated successfully    SCellIndex 2 activated successfully
#    Sort List    ${PHYSCELLIDLIST}
#    Collections.Lists Should Be Equal    ${MATHCES}    ${PHYSCELLIDLIST}
#
#A1 Triggered Scell Addition
#    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID_6} meas_id=1 event=A1 srsrp_nr=90 phycell_id=${ABB2002['PHYCELL_ID_PCELL']}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
#
#
