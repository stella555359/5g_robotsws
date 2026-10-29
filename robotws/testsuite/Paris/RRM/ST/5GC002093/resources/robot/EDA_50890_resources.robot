*** Settings ***
Documentation    EDA MNRAC 50890
...              AUTHOR (I&V):   nathalie.caudy@nokia.com
...              creation : 07/07/2022
...              update : xx/xx/2021

Library           taf.analyzer.pmcounter
Library           ../../../resources/pm_analyze.py

Resource          ../../../resources/pm_collection.robot
Resource          ../../../resources/sg_radio_perf/robot/preconditions.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
#Resource          ../../../resources_sg_radioPerf/robot/Keywords_UE.robot
Resource          keywords_EDA50890_common.robot


*** Keywords ***

EDA_Suite_Setup
    [Arguments]        ${gnb_index}=0
    Setup Testline Suite Variables
    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=all   gnb=${gnb_index}
    #keywords_EDA50890_common.Check gNB and Get reportingIntervalPm Value
    Log To Console   \n in EDA_Suite_Setup before Keywords_gNB.Check gNB State
	Keywords_gNB.Check gNB State      gNB=0
    # prepare scf
    keywords_EDA50890_common.Perform PreCommissioning For EDA

#    keywords_EDA50890_common.Make Call and ULDL Traffic and Collect Pm files in TestsuiteDir
#    ...     gNB=${gNB_id}
#    ...     ue_index=${UE_ID}
#    ...     ue_capabilities=${capabilities_ms}


EDA_Suite_Teardown
    TestSuite Basic Teardown     restore_gnb_config=False    restore_type=scf
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin


EDA_50890
    [Documentation]    The purpose of this test case is to check call establishment after on-line
    ...                modification of parameter sub6_preambleTransMax
    ...
    ...                Test Steps Executions:
    Log To Console     \n *** Fin de Test
	
