*** Settings ***
Documentation    The purpose of the test case is to verify that the correctable (CE) and uncorrectable (UE) errors
...    are stored in the separated Blackbox_ecc_ce and Blackbox_ecc_ue files.
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot


*** Keywords ***
TC__LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files

    Step 0: Connect to BTS
    Step 1: Check folder contents



Step 0: Connect to BTS
    [Documentation]
    ...   In this step test case connects to BTS

    Log    \nStep 0: Connecting to BTS    console=${True}
    SSH.Connect To      hostname=192.168.255.129    username=toor4nsn   password=oZPS0POrRieRtu     alias=connection_gnb
    Log    \nSuccesfully connected to the BTS    console=${True}
    Sleep   2


Step 1: Check folder contents
    [Documentation]
    ...   In this step we check the correctable (CE) and uncorrectable (UE) errors
    ...   are stored in the separated Blackbox_ecc_ce and Blackbox_ecc_ue files.

    Log    \nStep 1: Checking /ffs/run/logs/lifetimedata folder contents, please wait...   console=${True}
    Sleep   2
    SSH.Send command    command=ls -ltr /ffs/run/logs/lifetimedata/      connection=connection_gnb
    ${folder_contents}=     ssh.read output     connection=connection_gnb
    Log    \n${folder_contents}   console=${True}
    Sleep   2
    Run Keyword   Should Contain  ${folder_contents}  blackbox_ecc_ue_
    Run Keyword   Should Contain  ${folder_contents}  blackbox_ecc_ce_

    Log    \nLogs are present under this location! [OK]   console=${True}
    Sleep   2


Disconnect from BTS
    [Documentation]
    ...   In this step test cases disconnects from BTS

    Log    \nTerminating connection with BTS   console=${True}
    Sleep   2
    SSH.Disconnect      connection=connection_gnb

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    Disconnect from BTS
    ...    AND    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
