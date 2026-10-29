*** Settings ***
Documentation    Scenario specific keywords for Feature <ID>
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Keywords ***

#-----------For Test Execution -----------------#
Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    Run Keyword And Continue On Failure    Run Keywords    @{scenario_specific_keywords}
    Log    The following Keywords were Run: ${scenario_specific_keywords}

Run Feature specific keywords before attach
    RETURN


Run Feature specific keywords after attach before traffic is started
    RETURN


Run Feature specific keywords during traffic before detach
    [Arguments]  ${traffic_duration}
    Sleep  ${traffic_duration}


Run Feature specific keywords after traffic before detach
    RETURN

Run Feature specific keywords after detach
    RETURN

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

#-----------For Suite Setup -----------------#
Make necessary changes to SCF
    RETURN

Update Basic Configuration File
    RETURN
