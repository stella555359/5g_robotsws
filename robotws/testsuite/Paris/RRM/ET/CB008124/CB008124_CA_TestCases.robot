*** Settings ***
Documentation     [SUITE PURPOSE]  CB008124 "UL Resource Reservation and Scheduling by Configured Grants Type 2"
...               Scope : TCs for step CA (link adaptation)
...               Automation of TC : CB008124_CA_03_B1_CG_deactivation_bad_radio_conditions_FDD
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 15-May-2022
...               Last Modified by            : Yann HERVE
...               Modification:
...                       15-May-2022         | Creation

Resource                            ./resources/robot/CB008124-CA_keywords.robot

Force Tags                          CA_5G_SW_FR-Villarceaux    RRM
...                                 PY36
...                                 master_classicalbts_all       SBTS00
...                                 STATE_CONFIGURED    5G_RAN    RAN_5G

Suite Setup                         Suite Setup from scratch            listBackupFiles=${FD_ALL}
Suite Teardown                      Suite Teardown

Test Setup                          CB008124 Test Setup
Test Teardown                       CB008124 Test Teardown


*** Variables ***
${TestSharkTool}        MC_SHARK


*** Test Cases ***

[1]CB008124_CA_03_B1_CG_deactivation_bad_radio_conditions_FDD
    [Documentation]             This TCs is used for checking ULCG link adaptation
    ...                         It degrades radio conditions by using UL SINR AP test mode as
    ...                         ULCG is activated. Radio conditions are degraded until it's no mode
    ...                         possible to keeps CG. Deactivation is then triggered.
    ...                         As a second step radio conditions are improved and CG reactivation
    ...                         should take place.
    ...                         PM are checked for test assessment.
    [Tags]                      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT

    # ./UteEnvRunRobot.sh -tlSite Wroclaw -tlName $(hostname|sed 's/-/_/g') -tlAddress 10.42.188.149 
    # -tlUser ute -tlPassword ute -cpInitOnly -testSuite testsuite/Paris/RRM/ET/CB008124/CB008124_CA_TestCases.robot 
    # -gnbBuildId SBTS00_ENB_9999_230514_000002 -dryrun
    CB008124_TC_CA_103_B1_CG_deactivation_bad_radio_conditions
