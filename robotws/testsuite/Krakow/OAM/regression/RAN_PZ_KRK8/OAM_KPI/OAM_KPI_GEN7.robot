*** Settings ***
Documentation
...              author: Damian Zak
...              maintainer: Damian Zak, Matuesz Iwankiewicz
...              contact: damian.zak@nokia.com, mateusz.iwankiewicz@nokia.com
...              description: OAM KPI KRK8 Test Suite for GEN5 configuration

Resource         resources/common_resources.robot

Suite Setup      OAM KPI Suite Setup
Suite Teardown   OAM KPI Suite Teardown
Test Setup       OAM KPI Test Setup
Test Teardown    OAM KPI Test Teardown

*** Variables ***
${NUMBER_OF_ITERATIONS}                    ${30}
${REFERENCE_CONFIGURATION_ID}              CNF_5G_32
${REPORT_TO_REP}                           ${True}
@{ADDITIONAL_ALLOWED_ALARMS}               4592  4589  4590  4125  7308  7319  4405  4153  4452  1898  4123  4298
@{CRITICAL_FAULTS}                         0010  0016  1806  1868  4341  4352  4383
${COLLECT_RU_LOGS}                         ${False}

*** Test Cases ***
Gen7_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
    Run Site Reset in Loop
    ...    iterations=${NUMBER_OF_ITERATIONS}
    ...    target=${TEST_TARGETS}
    ...    additional_allowed_alarms=${ADDITIONAL_ALLOWED_ALARMS}
    ...    report_to_rep=${REPORT_TO_REP}
    ...    collect_ru_logs=${COLLECT_RU_LOGS}

Gen7_OAM_KPI_51a_RU_Reset_Time
    Run Reset RMOD in Loop
    ...    iterations=${NUMBER_OF_ITERATIONS}
    ...    target=${TEST_TARGETS}
    ...    additional_allowed_alarms=${ADDITIONAL_ALLOWED_ALARMS}
    ...    report_to_rep=${REPORT_TO_REP}
    ...    collect_ru_logs=${COLLECT_RU_LOGS}

Gen7_OAM_KPI_17_Cell_Block_Unblock_manually
    Run Cell Block Unblock in Loop
    ...    iterations=${NUMBER_OF_ITERATIONS}
    ...    target=${TEST_TARGETS}
    ...    cell_id=random
    ...    additional_allowed_alarms=${ADDITIONAL_ALLOWED_ALARMS}
    ...    report_to_rep=${REPORT_TO_REP}
    ...    collect_ru_logs=${COLLECT_RU_LOGS}

Gen7_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
    Run BTS Power On in Loop
    ...    iterations=${NUMBER_OF_ITERATIONS}
    ...    target=${TEST_TARGETS}
    ...    additional_allowed_alarms=${ADDITIONAL_ALLOWED_ALARMS}
    ...    report_to_rep=${REPORT_TO_REP}
    ...    timeout=780
    ...    collect_ru_logs=${COLLECT_RU_LOGS}

Gen7_OAM_KPI_651_RU_Reset_Startup_Success_Rate
    Success Ratio Validation

Gen7_OAM_KPI_61a_Site_Reset_Startup_Success_Rate
    Success Ratio Validation

Gen7_OAM_KPI_63_Power_Reset_Startup_Success_Rate
    Success Ratio Validation
