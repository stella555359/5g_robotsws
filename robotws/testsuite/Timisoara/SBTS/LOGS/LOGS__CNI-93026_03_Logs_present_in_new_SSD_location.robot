*** Settings ***
Documentation    The purpose of this Test Case is to check that the logs are present in the new SSD location under /ffs/run/logs/lifetimedata.
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot


*** Keywords ***
TC__LOGS__CNI-93026_03_Logs_present_in_new_SSD_location

    Step 0: Connect to BTS
    Step 1: Check folder contents



Step 0: Connect to BTS
    [Documentation]
    ...   In this step test cases connects to BTS

    Log    \nStep 0: Connecting to BTS    console=${True}
    SSH.Connect To      hostname=192.168.255.129    username=toor4nsn   password=oZPS0POrRieRtu     alias=connection_gnb
    Log    \nSuccesfully connected to the BTS    console=${True}
    Sleep   2


Step 1: Check folder contents
    [Documentation]
    ...   In this step we check the contents of the folder to make sure logs are present under this new location

    Log    \nStep 1: Checking /ffs/run/logs/lifetimedata folder contents, please wait...   console=${True}
    Sleep   2
    SSH.Send command    command=ls -ltr /ffs/run/logs/lifetimedata/      connection=connection_gnb
    ${folder_contents}=     ssh.read output     connection=connection_gnb
    Log    \n${folder_contents}   console=${True}
    Sleep   2
    Run Keyword   Should Contain  ${folder_contents}  blackbox
    Run Keyword   Should Contain  ${folder_contents}  blackbox_reset
    Run Keyword   Should Contain  ${folder_contents}  blackbox_alarms
    Run Keyword   Should Contain  ${folder_contents}  blackbox_temperature
    Run Keyword   Should Contain  ${folder_contents}  blackbox_adet_data
    Run Keyword   Should Contain  ${folder_contents}  blackbox_sfp.csv
    Run Keyword   Should Contain  ${folder_contents}  blackbox_post_result_A
    Run Keyword   Should Contain  ${folder_contents}  blackbox_bbtrace_data
    Run Keyword   Should Contain  ${folder_contents}  date_time.txt
    Run Keyword   Should Contain  ${folder_contents}  blackbox_ecc
#    Run Keyword   Should Contain  ${folder_contents}  mama

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


