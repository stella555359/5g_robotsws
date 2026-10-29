*** Settings ***
Suite Setup       Create DataCollector Test Run
Suite Teardown    Stop DataCollector Test Run
Test Setup    Start DataCollector
Test Teardown    Stop DataCollectors and Run Analysis    ${ANALYSIS_TEMPLATE}
Resource    ../../CommonKeywords/RobotKeywords/data_collector.robot

*** Variables ***
${ANALYSIS_TEMPLATE}    Case_xyz_analysis

*** Test Cases ***
DataCollectorTest1
    Sleep    1 min
