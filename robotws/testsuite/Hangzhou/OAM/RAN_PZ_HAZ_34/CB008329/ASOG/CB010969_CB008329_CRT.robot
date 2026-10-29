*** Settings ***
Documentation
...  author: Lei Nie
...  contact: lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

Force Tags   SG_07   CA_5G_OAM   STATE_SW_UPDATED   RAN_5G   RAN_5G_TDD
...   SBTS00
...   AUTHOR_lei.nie@nokia-sbell.com

Test Timeout   1h

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown
Test Setup   robot_common_operations.Common Case Setup
Test Teardown   robot_common_operations.Common Case Teardown

*** Variables ***
${UTE_FLAG}   ${True}
${DUAL_CORE}   ${False}

*** Test Cases ***
CB010969-CB008329-CRT
    [Timeout]    1h
    Run Keyword And Continue On Failure    CB010969-CB008329_001_Sanity_Checker_Detects_Netboot_Enabled
    Run Keyword And Continue On Failure    CB010969-CB008329_002_Sanity_Checker_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Active_Partition

*** Keywords ***
Common Suite Setup
    robot_common_operations.Common Suite Setup
    Log To Console   ${UTE_FLAG}
    Log To Console   ${DUAL_CORE}
    SC Internally Common Setup

Common Suite Teardown
    SC Internally Common Teardown
    robot_common_operations.Common Suite Teardown

SC Internally Common Setup
    Common Setup CB008329
    Enable SC Feature Flag
    Configure Scheduled SC

SC Internally Common Teardown
    Disable SC Feature Flag
    Run Keyword And Ignore Error   Remove Configured Scheduled SC
    Common Teardown CB008329

CB010969-CB008329_001_Sanity_Checker_Detects_Netboot_Enabled
    [Documentation]   Author: lei.nie@nokia-sbell.com
    Log To Console   NEboot Enabled
    AlarmWatchdog.add_allow_alarms    fault_id=4681
    001_Netboot_Enable
    [Teardown]   Case Teardown: 001

CB010969-CB008329_002_Sanity_Checker_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Active_Partition
    [Documentation]   Author: lei.nie@nokia-sbell.com
    Log To Console   remove FileDirectoryXML
    AlarmWatchdog.add_allow_alarms    fault_id=4681
    002_SC_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Active_Partition
    [Teardown]   Case Teardown: 002