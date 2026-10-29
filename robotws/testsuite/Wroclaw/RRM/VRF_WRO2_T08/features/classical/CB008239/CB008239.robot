*** Settings ***
Documentation
...    author: Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008239/resources/test_specific_keywords.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008239/resources/test_specific_keywords.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/utility/anr_knife.py

Force Tags      CA_VRF_WRO2

Suite Setup    ANR Knife
Test Teardown   Test Teardown

*** Variables ***
${UE_1_DRX_1}    f1ap.procedureCode == 7 and f1ap.id == 39 and nr-rrc.gapUE == 0
${UE_1_DRX_2}    f1ap.procedureCode == 7 and f1ap.id == 9 and nr-rrc.reportConfig == 1 and nr-rrc.reportType == 2
${UE_1_DRX_3}    f1ap and f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1 and f1ap.id == 39 and frame.len < 210
...              and nr-rrc.drx_LongCycleStartOffset == 13

*** Test Cases ***
[1]CB008239_A_B2_TC04 Meas Gap Release and DRX Setup in UE to allow inter-RAT EUTRA CGI measurement reporting
    [Setup]  Test Setup
    Meas Gap Release and DRX Setup in UE to allow inter-RAT EUTRA CGI measurement reporting

[1]CB008239_A_B7_TC06_New_inter_RAT_Neighbour_object_addition_to_Network_Plan_File
    [Setup]  Test Setup
    New inter-RAT Neighbour object addition to Network Plan File

[1]CB008239_B_B2_TC12 Automatic EUTRA Neighbour Removal Procedure
    [Setup]  Test Setup    auto_removal=true  idle_time_removal=2
    CB008239_B_B2_TC12 Automatic EUTRA Neighbour Removal Procedure

[1]CB008239_B_B1_TC11 Online modification idleTimeForEutraNbRemoval flag
    [Setup]  Test Setup  require_ue=${FALSE}  auto_removal=true  idle_time_removal=3
    Online modification idleTimeForEutraNbRemoval flag

[1]CB008239_B_B5_TC15 Online modification actSaUeBasedAnrEutra flag
    [Setup]  Test Setup
    Automatic EUTRA Neighbour Removal Procedure
