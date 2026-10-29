*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_LWG_1ASIB_1ABIO_2ABIA_1FXDB_1AHFIC_1AHFIB   SBTS00
Library           XML  use_lxml=True
Resource        ../../LOGS/LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal.robot

*** Variables ***
${SCF_ID}         01
${COMMISSIONING_PATH}=    SEPARATOR=
...  /home/ute/btsauto/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_5009_Rossi/commissioning/SCF_01_TRUNK.xml

*** Test Cases ***
[1]Automated__LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal
    [Setup]    Run Keywords
    ...    LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal
    ...    AND    Set Library Search Order
    ...    LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal
    [Timeout]    14400
    TC__LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal
    [Teardown]    Run Keywords
    ...    LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
