*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T3F_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Delta Commission With SCF File    ${DELTA_FILE}
#...               AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown    debug
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    FR1    Owner_MINMLUO    SBTS00
#...               RAN_5G    RAN_5G_TDD
#Resource          ./CB006138_Resource.robot
#
#*** Variables ***
#${FULL_FILE}         basic_2T3F_SCFC_LOO.xml
#${IPHY_2T3F_FILE}    ${CURDIR}/Resource/wts/iphy_2T3F_LOO.xml
#${DELTA_FILE}        Delta_pCsi_multiplexing.json
#${LOCAL_WTS_DIR}     ${CURDIR}/Resource/wts
#${WTS_CFG}           basic_2T3F_LOO.cfg
#${SCF_PATH}          ${CURDIR}/Resource/Config
#
#*** Test Cases ***
#CB006138_ET_AEB1001_FR1_CA_With_TDD_PCell_Interwork_With_PCSI_Report_Multiplexing_Without_5GC002200
#    [Documentation]
#    ...    1. actPerCsiReportBundlingTddFr1=True
#    ...    actBeamforming = True
#    ...    numberOfTransmittedSsBlocks = 2
#    ...    pucchF3ModulationScheme = qpsk_4psk
#    ...    pucchF3MaxCodeRate = zeroDot15
#    ...    srPeriodicity = 160(TDD) 80(FDD)
#    ...    csiReportPeriodicity = 320(TDD)    160(FDD)
#    Single 3CC UE Blind Scell Addition And Scell Activation For DL CA Should Succeed    ${UE_ID_3}
#    SA Start DL And UL Traffic    ${UE_ID_3}
#    SA Stop DL And UL Traffic    ${UE_ID_3}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    Check PCSI Multiplexing    ${TEST_LOG_DIRECTORY}/egate_console.log
#
#*** Keywords ***
#Check PCSI Multiplexing
#    [Arguments]    ${egate_log}
#    ${content}    OperatingSystem.Get File    ${egate_log}
#    ${slot_320_regex}=    Set Variable    reportSlotConfig\\sslots320\\s:\\s(?P<slot_320>\\d+)
#    ${slot_320_list}=    String.Get Regexp Matches    ${content}    ${slot_320_regex}    slot_320
#    ${slot_320_1}=    Set Variable    @{slot_320_list}[0]
#    ${slot_320_2}=    Set Variable    @{slot_320_list}[1]
#    Should Be True    "${slot_320_1}"=="${slot_320_2}"
