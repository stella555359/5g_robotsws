*** Settings ***
Documentation
...    Author: George Medesan (george.medesan@nokia.com)
...    Maintainer: George Medesan (george.medesan@nokia.com)
...    Group in charge: BTS_OAM_VERIF_ET1
...    References: doors
...    Feature Description: CB008993-SR-B_5GC000766-A
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB008993-SR-B_5GC000766-A/generalCIT.robot

Resource    ./resources/CB008993-SR-B_5GC000766-A.robot
Resource    ../resources/pretest_posttest.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_FDD  5G_RAN_FDD  5G_RAN  master_classicalbts_all
...    CLOUD_5G_CLASSICAL_ASIBL_ABINB1_AAFB_AAIB    
...    CA_RAN_BOAM_VERIF

Suite Setup       Run Keywords    UTE TL Preparation
...               AND             Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions  #With Reset Site

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***

CB008993-SR-B_Test1-Cells_n25_set_DualSectorBFProf_plus_minus_30degree_5MHz
    [Tags]   CIT    SBTS22R3    SBTS22R4 
    [Documentation]
    ...  RU AAFB, Cells band = n25, BW = 5MHz
    Test1 - Cells_n25_set_DualSectorBFProf_plus_minus_30degree_5MHz

#CB008993-SR-B_Test2-Cells_n66_set_DualSectorBFProf_plus_minus_30degree_5MHz
#    [Tags]   CRT         
#    [Documentation]
#    ...  RU AAIB, Cells band = n66, BW = 5MHz
#    Test2 - Cells_n66_set_DualSectorBFProf_plus_minus_30degree_5MHz

#CB008993-SR-B_Test3-Cells_n66_set_DualSectorBFProf_plus_minus_30degree_20MHz
#    [Tags]   CRT        
#    [Documentation]
#    ...  RU AAIB, Cells band = n66, BW = 20MHz
#    Test3 - Cells_n66_set_DualSectorBFProf_plus_minus_30degree_20MHz

#CB008993-SR-B_Test4-WebEM_shall_display_the_most_important_cell_parameters_in_separate_Details_panel_for_cell_selected_on_the_BTS_Runtime_View
#    [Tags]   CRT          #   TC already covered by ST team
#    [Documentation]
#    ...
#    Test4 - WebEM shall display the most important cell parameters in separate Details panel for cell selected on the BTS Runtime View









