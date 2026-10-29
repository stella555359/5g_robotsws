*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_w13li    SBTS00    SBTS23R1
#...               CN1_SQ6    CB006137 1
#Resource          ../CB008015/resources/CB008015_lib.robot
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SCF_PATH}          ${CURDIR}/config/
#${FULL_SCF}         CB006137_AC_301_scfc_LOO.xml
#${IPHY_FILE}          ${CURDIR}/config/WTS/6137_AC_301_LOO_iphy.xml
#${WTS_LOCAL}     ${CURDIR}/config/WTS
#${WTS_AP_XML}        airphone.xml
#${WTS_CFG}           6137_AC_301_LOO.cfg
#${UE_ID}             1
#${PCELL1_ID}         52
#${SCELL1_ID}         51
#${SCELL2_ID}         60
#${SCELL3_ID}         61
#${DL_TRF}            980
#${UL_TRF}            175
#${DL_PEAK}           970
#${UL_PEAK}           92
#${M55308C11001_id}       M55308C11001
#${M55308C11001_path}     CELLS/NRCELL-3/NCELA
#${M55308C11002_id}       M55308C11002
#${M55308C11002_path}     CELLS/NRCELL-3/NCELA
#
#
#
#*** Test Cases ***
#CB006137_ET_AC301_BO_Verify_Single_UE_DRX_Scell_Blind_Addition_2CC_UL_CA
#    SA 5G CA Attach    ${UE_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL1_ID}    1
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL2_ID}    2
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL3_ID}    3
#    Verify Scells Are Activation    4
#    Check DRX Configuration
#    Wait Until PM Counter Update    5min    2
#    Check PM Counter
#    Start ULDL Traffic And Check The Tput
#
#*** Keywords ***
#Check DRX Configuration
#    Save Egate Log
#    OperatingSystem.Run    mv ${SUITE_LOG_DIRECTORY}/egate_console.log ${SUITE_LOG_DIRECTORY}/egate_console-DRX.log
#    ${egate_console_file}=    Set Variable    ${SUITE_LOG_DIRECTORY}/egate_console-DRX.log
#    ${DrxProfile1}=    Grep File    ${egate_console_file}    drx-Config setup
#    Should Contain    ${DrxProfile1}    drx-Config setup
#    ${DrxInactivityTimer}=    Grep File    ${egate_console_file}    drx-InactivityTimer ms80
#    Should Contain    ${DrxInactivityTimer}    drx-InactivityTimer ms80
#    ${output}    String.Get Lines Matching Regexp    ${DrxProfile1}    drx-Config setup    partial_match=${true}
#    Log To Console    ${output}
#
#
#Check PM Counter
#    ${M55308C11001_value}    Get PM Counter Latest Value From Admin    ${M55308C11001_id}    ${M55308C11001_path}
#	  ${M55308C11002_value}    Get PM Counter Latest Value From Admin    ${M55308C11002_id}    ${M55308C11002_path}
#    ${value}    Evaluate    float(${M55308C11002_value})/float(${M55308C11001_value})
#    should be true    ${value}>3
#    should be true    ${value}<16
#
#Start ULDL Traffic And Check The Tput
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    ${UL_TRF}
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    ${DL_TRF}
#    Wait Until Keyword Succeeds    1min    6s    Check TP On Target 4CC    ${UE_ID}    ${DL_PEAK}    ${UL_PEAK}
#
#
#
#
