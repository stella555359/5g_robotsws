*** Settings ***
Documentation
...  author : yin.4.chen@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
D_33_SA_ClassicalgNB_PCMD_Report_after_RU_reset
    COAM Reset ALL RMOD
    Wait Until Keyword Succeeds   15m   1m   COAM Check All Cells Onair
    Make L3CALL And Get ALL PCMD MSG
    ${flag}   Set Variable   ${False}
    FOR   ${crnti}   IN   @{ALL_PCMD_MSG.keys()}
        ${flag}   Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}   ulSchedulingRecord
        Exit For Loop If   ${flag}
    END
    run keyword if  not ${flag}   Fail   Message Not Found!

Case Setup: D_33
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Common Setup 1756
    Remove And Add PCMD Object

Case Teardown: D_33
    robot_common_operations.Common Case Teardown
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    # ${status}   Run Keyword And Return Status   COAM Check All Cells Onair
    # Run Keyword Unless   ${status}   Run Keywords
    # ...   Run Keyword And Ignore Error   COAM Reset Site   AND
    # ...   Wait Until Keyword Succeeds   15m   1m   COAM Check All Cells Onair
    Run Keyword And Ignore Error   COAM Reset Site
    Sleep   1m
    Wait Until Keyword Succeeds   15m   1m   COAM Check All Cells Onair
    Common Teardown 1756
