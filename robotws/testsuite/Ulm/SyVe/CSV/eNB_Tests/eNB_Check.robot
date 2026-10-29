*** Settings ***

Documentation
...  Description:
...    check eNB using NOKIA UEs
...    author:  Michele Bertolini
...    Team: 'MN ULM R&D SqdGp64'
...    Email: 'I_PZ_ULM_SQD_64@internal.nsn.com'
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../../resources/Common/testline.robot
Resource    ../../../resources/Common/gnb.robot
Resource    ../../../resources/Common/git_handling.robot
Resource    ../../../SyVe/resources/syve_testline.robot

*** Test Cases ***
eNB_Check
    [Tags]     CRT   eNB_Check

    testline.Set Console Output
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    git_handling.Save Current Workspace Info

    ${gnb_sw_version}=    Get gNB SW version    gnb_id=${0}
    Log to console    ${\n}INFO: GNB SW Version is: ${gnb_sw_version}

    ${enb_sw_version}=    Get eNB SW version    enb_id=${0}
    Log to console    ${\n}INFO: eNB SW Version is: ${enb_sw_version}

    Get Current Alarms From Node    node_type=gnb
    Get Current Alarms From Node    node_type=enb

    Log to console    ${\n}KW needed for Offline reporting.
    syve_testline.Save current loads

    Run Keyword And Warn On Failure    Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb

    Log To Console    ${\n}Wait that gNB and eNB are Onair...
    gnb.Wait Until Node To Be Onair State    node_id=${0}
    gnb.Wait Until Node To Be Onair State    node_id=${0}    node_type=enb
    Log To Console    ${\n}Wait that X2 Link Status is Available
    gnb.Wait until X2 Link Status is Available

    Run Keyword And Warn On Failure    Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb

    Log To Console    ${\n}The End...
