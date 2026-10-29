*** Settings ***
Documentation     [SUITE PURPOSE]  verification of CB008662 "Adaptive MCS retransmission"
...               Scope : TCs for step A
...
...               Test Case Scenario author   : yann.ah.herve@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 29-August-2022
...               Last Modified by            : vincent.boulet@nokia.com
...               Modification:
###...                    29-August-2022      | Creation
...                     \n17-May-2024         | Parity testing to introduce dRNIC RINLINE2 CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC


Resource                            ./resources/robot/CB008662_AC_keywords.robot

Suite Setup                         Suite Setup from scratch    listBackupFiles=${FD_ALL}    keepAllUeDataInCfgFile=${True}
Suite Teardown                      Suite Teardown

Test Setup                          CB008662 Test Setup
Test Teardown                       CB008662 Test Teardown


*** Test Cases ***
[1][1.0] CB008662_AC_06_UL_HARQ_Retrans_When_above target_Min_50_Target_90
    CB008662_TC_AC_06_UL_HARQ_Retrans_When_above target_Min_50_Target_90
