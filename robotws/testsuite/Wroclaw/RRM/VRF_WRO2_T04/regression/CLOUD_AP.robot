*** Settings ***
Documentation
...    Testcases copied from Paris NPS and modified due to regression takeover
...
...    [SUITE PURPOSE]
...    1. CB008662 "Adaptive MCS retransmission"
...               Scope : TCs for step A
...
...               Test Case Scenario author   : yann.ah.herve@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...             \nCreation Date               : 29-August-2022
...             \nLast Modified by            : vincent.boulet@nokia.com
...             \nModification:
...
...                     \n17-May-2024         | Parity testing to introduce dRNIC RINLINE2 CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...
...    2. CB010850-AA_4_UL-PRB_Blanking_high_edge_10_20MHz_2cells_scheduling_SA_M55308C10004
...               \nCell 1: 10Mhz 26 High_edge blanked
...               \nCell 2: 20Mhz 5 High_edge blanked
...               \nTest Case Scenario contact  : ilakcoumi.pareemanen@nokia.com
...               \nModified Date               : 2024-09-20
...               \n1.0 - FB2407 - vincent.boulet@nokia.com - Parity testing to introduce dRNIC RINLINE2
...               \n1.1 - FB2419 - vincent.boulet@nokia.com - Configuration update on CR test
...               \n1.2 - FB2419 - richard.duthu@nokia.com - Produce Scout data through Test Teardown
...     6.02.25 - CloudRan TCs copied from NPS to WRO_2_4, whole resources replaced
...     20.05.25 - TCS adapted to TL 8672

Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB008662/resources/robot/CB008662_AC_keywords.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010850/resources/robot/CB010850_AA_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/aic_ap_setup.robot
Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library   taf.ul.hanging_resources.listener     ${False}
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/DcapLogs.py

Suite Setup    Run Keywords    Enable Cloud

*** Variables ***
${KEEP_ALIVE}=    ${True}
${BASIC_SETUP}=       /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB008662/config/custom/basic_setup_8662.cfg
${BASIC_SETUP_10850}=     /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010850/config/custom/basic_setup_CB010850.cfg

*** Test Cases ***
[1]CB008662_AC_06_UL_HARQ_Retrans_When_above target_Min_50_Target_90_VR
    [Tags]    NoResUsage    vDUCNF00
    [Setup]    With Simulator Configuration    config=${BASIC_SETUP}
    CB008662_TC_AC_06_UL_HARQ_Retrans_When_above target_Min_50_Target_90

[1]CB010850-AA_4_UL-PRB_Blanking_high_edge_10_20MHz_2cells_scheduling_SA_M55308C10004_CR
    [Tags]     NoResUsage    vDUCNF00
    [Setup]    With Simulator Configuration    config=${BASIC_SETUP_10850}
    CB010850_AA_PRB_BLANKING
