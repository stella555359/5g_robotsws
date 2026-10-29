*** Settings ***
Documentation     [SUITE PURPOSE]  Tools script for CB007487 integration
...               Scope : Tools for CB007487 (ABIP introduction)
...               Those scripts will be used for ABIP checks purposes
...               It performs reset and cell lock/unlock in loop and check success ratio
...               of the procedure.
...               It uses either SWENG robot or coam TAF API based on official OAM interface
...               (see https://onion.wroclaw.nsn-rdnet.net/branches/master/cli-docs/index.html )
...
...               Automation author           : yann.ah.herve@nokia.com
...               Automation contact          : davide.bacchiega@nokia.com
...               Creation Date               : 19-Oct-2021
...               Modified Date               :
...               19-Oct-2021                 |           Creation
...               Last Modified by            : yann.ah.herve@nokia.com

Resource                            ./CB007487_Operability_KPIs_Common.robot


Force Tags                          CA_5G_SW_FR-Villarceaux    RRM
...                                 CONFIGURED    5G_RAN    RAN_5G
...                                 master_classicalbts_all
...                                 SBTS00
...                                 CLOUD_5G_I_BO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup                         Suite Setup From Scratch            listBackupFiles=${FD_ALL}
Suite Teardown                      Suite Teardown

*** Variables ***

*** Test Cases ***
# This script is used to perform reset in loop by using cOAM API
# Input parameters:
# nbSiteReset: Number of reset sites to be performed
# successRatio: Expected site reset ratio (%)
# Ouput:
# If some cell(s) are not set onAir after reset or if gNB is not OnAir, errors will be displayed
# on the console
# It also displays a success ratio and average time of gNB reset at the end of the loop.
# Some parameters located inside CB007487_Operability_KPIs_Common.robot file can be used for
# further tunnings:
# onair_timeout : polling duration until cells are on air (default : 5 minutes)
# time_between_each_reset_loop : pause duration between each reset loop (default : 1 minutes)
# perform_wts_setup_anyway: False/True. Parameters used to reinitialise WTS after a gNB reset (default = False)
[1]CB007487_1_Site_Reset_Success_Ratio_TDD


    &{test_params}                  Create Dictionary       nbSiteReset=3
    ...                                                     successRatio=100

    TC_CB007487_RESET_SUCCESS_RATIO                         ${test_params}

# This script is used to perform block/unblock in loop by using cOAM API
# Input parameters:
# cellId : Id of the cell to be blocked/unblocked. It stands for the order of the cell inside OAM reports.
#          It does not stand for it's NIDD. For example if they are 2 cells, the ID 1 points to the first cell
#          reported by OAM query
# nbBlockUnblock: Number of cel block/unblock to be performed
# successRatio: Expected lock/unlock ratio (%)
# Ouput:
# Script cehck lock and unlock status after lock or unlock procedure.
# If some cell(s) are not set onAir after reset or if gNB is not OnAir, errors will be displayed
# on the console
#
# It also displays a success ratio and average time of gNB reset at the end of the loop.
#
# Some parameters located inside CB007487_Operability_KPIs_Common.robot file can be used for
# further tunnings:
# blocked_timeout : polling duration until cells is unblocked (default : 1 minutes)
# time_between_each_block_unblock_loop : pause duration between each block/unblock loop (default : 1 minutes)
[1]CB007487_2_Block_Unblock_Success_Ratio_Cell1_TDD

    &{test_params}                  Create Dictionary       cellId=1
    ...                                                     nbBlockUnblock=5
    ...                                                     successRatio=100

    TC_CB007487_BLOCK_UNBLOCK_SUCCESS_RATIO                 ${test_params}

[1]CB007487_3_Block_Unblock_Success_Ratio_Cell2_TDD

    &{test_params}                  Create Dictionary       cellId=2
    ...                                                     nbBlockUnblock=5
    ...                                                     successRatio=100

    TC_CB007487_BLOCK_UNBLOCK_SUCCESS_RATIO                 ${test_params}


# FDD entries (same scripts ad for TDD)
[1]CB007487_4_Site_Reset_Success_Ratio_FDD

    &{test_params}                  Create Dictionary       nbSiteReset=5
    ...                                                     successRatio=90

    TC_CB007487_RESET_SUCCESS_RATIO                         ${test_params}

[1]CB007487_5_Block_Unblock_Success_Ratio_Cell1_FDD

    &{test_params}                  Create Dictionary       cellId=1
    ...                                                     nbBlockUnblock=5
    ...                                                     successRatio=100

    TC_CB007487_BLOCK_UNBLOCK_SUCCESS_RATIO                 ${test_params}

[1]CB007487_6_Block_Unblock_Success_Ratio_Cell2_FDD

    &{test_params}                  Create Dictionary       cellId=2
    ...                                                     nbBlockUnblock=5
    ...                                                     successRatio=100

    TC_CB007487_BLOCK_UNBLOCK_SUCCESS_RATIO                 ${test_params}
