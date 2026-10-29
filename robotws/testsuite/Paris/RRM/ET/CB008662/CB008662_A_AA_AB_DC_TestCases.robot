*** Settings ***
Documentation     [SUITE PURPOSE]  verification of CB008662 "Adaptive MCS retransmission"
...               Scope : TCs for step A
...
...               Test Case Scenario author   : yann.ah.herve@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 07-October-2022
...               Modified Date               : 23-July-2025
...               Modification:
...                      07-October-2022         | Creation


Resource                            ./resources/robot/CB008662_A_keywords.robot
Resource                            ./resources/robot/CB008662_AA_keywords.robot
Resource                            ./resources/robot/CB008662_AB_keywords.robot
Resource                            ./resources/robot/CB008662_DC_keywords.robot

Force Tags                          CA_5G_SW_FR-Villarceaux    RRM
...                                 PY36    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...                                 master_classicalbts_all    SBTS00    SBTS23R1
...                                 CONFIGURED    5G_RAN    RAN_5G    CRT

Suite Setup                         Suite Setup from scratch            listBackupFiles=${FD_ALL}
Suite Teardown                      Suite Teardown

Test Setup                          CB008662 Test Setup
Test Teardown                       CB008662 Test Teardown


*** Test Cases ***

#
# Includes all TCs regarding TDD LO_LO topology to the same robot file to speed up tests execution
#

[1][1.0] CB008662_A_08_DL_HARQ_Retrans_When_multiple_NACK_Are_Received
    CB008662_TC_A_08_DL_HARQ_Retrans_When_multiple_NACK_Are_Received
