*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  :The purpose of this test case is to verify gNB broadcast SIB1 message with
...                        IE "eCallOverIMS-Support" as "True" on the cell when /NRBTS/NRCELL/actECallOverIMS
...                        is enabled for cell.
Resource          resources/Keywords/CB007292_KW.robot

Suite Setup        Suite Setup for 7292
Suite Teardown     Common Suite Teardown


*** Variables ***
${feature}     eCallOverIMS-Support true
${TOPOLOGY}    CLOUD_5G_O_E_AP_LOO


*** Test Cases ***
[1][1.0] CB007292_A_1_Verify_gNB_broadcast_SIB1_message_with_IE_eCallOverIMS_Support_as_True_on_the_cell_when_actECallOverIMS_is_enabled_for_cell
    [Tags]     QCD_MN_RAN      QCP_RAN_VRF   QC_28335
    [Setup]    Run Keywords     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND      Send Delta Commissioning      ${CURDIR}/config/scf/Delta_A_B1_TC1_B2_TC3.json
    Sleep    60s
    Wait Coam Site to be Ready
    Start UTE WTS     RJIO_basic_setup.cfg
    Read WTS Output Until Pattern Matches    ${feature}    ${Timeout_SA}
