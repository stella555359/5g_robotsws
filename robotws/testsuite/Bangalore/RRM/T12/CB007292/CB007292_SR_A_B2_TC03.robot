*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO

Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  :The purpose of this test case is to verify
...             1.When /NRBTS/NRCELL/actECallOverIMS is "true", gNB is broadcast SIB1 message with
...             IE "eCallOverIMS-Support" as "True" on the cell.
...             2.When /NRBTS/NRCELL/actECallOverIMS is set from "true" to "false" in runtime,
...             gNB is not broadasting the IE "eCallOverIMS-Support " in SIB1.

Resource          resources/Keywords/CB007292_KW.robot
Suite Setup       Suite Setup for 7292
Suite Teardown     Common Suite Teardown


*** Variables ***
${feature}     eCallOverIMS-Support true
${TOPOLOGY}    CLOUD_5G_O_E_AP_LOO


*** Test Cases ***
[1][1.0] CB007292_A_3_Verify_gNB_is_not_broadcasting_the_IE_eCallOverIMS_Support_in_SIB1_when_actECallOverIMS_is_set_from_True_to_False_in_runtime
    [Setup]    Run Keywords     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND    Update BSR Package For RJIO
    ...     AND    Send Delta Commissioning     ${CURDIR}/config/scf/Delta_A_B1_TC1_B2_TC3.json
    [Tags]        QCD_MN_RAN      QCP_RAN_VRF   QC_28336
    Sleep    60s
    Wait Coam Site to be Ready
    Start UTE WTS     RJIO_basic_setup.cfg
    Read WTS Output Until Pattern Matches    ${feature}    ${Timeout_SA}
    Sleep    10s
    Send Delta Commissioning      ${CURDIR}/config/scf/Delta_A_B1_TC1_B2_TC3_disable.json
    ${output}    Run Keyword And Expect Error    *read timed out.*    Read WTS Output Until Pattern Matches    ${feature}    ${Timeout_SA}
    Should Match Regexp    ${output}    .*read timed out.*
