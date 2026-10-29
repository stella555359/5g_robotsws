*** Settings ***
Documentation     [Procedure] "Verification_of_CB007290E_E2E_MacSec_SAK_and_CAK_Rekeying"
...               [Date] "Date of creation 21-06-2024"
...               [Author] "Vinay"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB007290"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] ASIL+ASIL
...               [Validation Date]  25-06-2024"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../CB007290_ST/resources/cak_sak_keywords.robot
Library         Telnet    prompt=$    default_log_level=DEBUG
Library         SSHLibrary
Library         ute_pdu
Library         Collections
Library         DateTime
Variables       ta_e2e_bts_trs_fw

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

*** Test Cases ***
[1]Verification_of_CB007290E_with_CellSiteSwitch_MacSec_SAK_and_CAK_Rekeying
    log    ${mplane_ip}
    Verify Macsec
    CAK_Rekeying
    SAK_Rekeying
