*** Settings ***
Documentation
...  author : lei.nie@nokia-sbell.com
...  contact: lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***



*** Keyword ***
004_Scheduled_SC_Netboot_Enable
    Log To Console   CB008329 004_Scheduled_SC_Netboot_Enable

    Configure Scheduled SC
    Set Netboot Variable

    Wait Until Keyword Succeeds   3m   5s   Check Netboot Detection Alarm


Case Setup: 004
    Log To Console   Case setup

Case Teardown: 004
    Log To Console   Case teardown
    Sleep   60s

    Delete Netboot Variable

    Run Keyword And Ignore Error   Repeat Keyword   2m   Check No Netboot Detection Alarm

    Trigger SC via Admin
    Run Keyword And Ignore Error   Check No Netboot Detection Alarm

    Run Keyword And Ignore Error   CI_interface.Common Case Teardown




# ===============================================================================================================================================
# ===============================================================================================================================================
# ===============================================================================================================================================
005_Scheduled_SC_Detects_Missing_Files_Referred_In_FileDirectoryXML
    Configure Scheduled SC
    Delete Active FileDirectory
    Delete Passive FileDirectory
    Wait Until Keyword Succeeds   3m   5s   Run Keywords
    ...   Check Active Missing Files Detection Alarm
    ...   Check Passive Missing Files Detection Alarm


Case Setup: 005
    Log To Console   Case setup

Case Teardown: 005
    Log To Console   Case teardown
    Sleep   60s

    Restore Active FileDirectory
    Restore Passive FileDirectory
    Run Keyword And Ignore Error   Repeat Keyword   2m   Run Keywords
    ...   Check Active No Missing Files Detection Alarm   AND
    ...   Check Passive No Missing Files Detection Alarm

    Trigger SC via Admin
    Run Keyword And Ignore Error   Check Active No Missing Files Detection Alarm
    Run Keyword And Ignore Error   Check Passive No Missing Files Detection Alarm

    Run Keyword And Ignore Error   CI_interface.Common Case Teardown
