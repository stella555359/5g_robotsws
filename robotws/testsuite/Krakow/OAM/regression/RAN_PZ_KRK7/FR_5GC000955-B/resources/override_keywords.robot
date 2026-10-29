*** Settings ***
Documentation
...    Author: Kasper Biegun (kasper.biegun@nokia.com)
...    Maintainer: Kasper Biegun (kasper.biegun@nokia.com)
...    Group in charge: MN 5G&SC mmW&SC Pz KRK 5 SG
...    References: doors
...    Feature Description:5GC000955-B

*** Keywords ***
Transfer ADMIN_CLI scripts
    Run    cp ${ADMIN_CLI_scripts_path}/* ~/ADMIN_CLI/
    Run    chmod 777 ~/ADMIN_CLI/*
    Run    chmod 777 ~/ADMIN_CLI/node/linux/bin/node

Delete LANE Objects
    ADMIN Perform Delta Recommissioning         ${delta_lane_object_delete}
    ...                                         skip_parameter_relation_errors=True

Lock LANE by CLI is performed successfully
    Wait Until Keyword Succeeds     120 sec     20 sec    Activate CLI feature
    ${result}=  Run Process  ${SW_DESTINATION}/ADMIN_CLI/lockLane_successfully.sh    ${mrbts_value}    shell=yes
    Should Be Equal As Integers 	${result.rc} 	0
    Wait Until Keyword Succeeds     120 sec     20 sec    Deactivate CLI feature

Unlock LANE by CLI is performed successfully
    Wait Until Keyword Succeeds     120 sec     20 sec    Activate CLI feature
    ${result}=  Run Process  ${SW_DESTINATION}/ADMIN_CLI/unlockLane_successfully.sh    ${mrbts_value}    shell=yes
    Should Be Equal As Integers 	${result.rc} 	0
    Wait Until Keyword Succeeds     120 sec     20 sec    Deactivate CLI feature
    Sleep    10s

Lane lock and unlock in Detailed Site View
    [Arguments]   ${connector_name}
    Login To Web Element Manager
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=//div[@aria-label=${connector_name}]
    ...    timeout=60
    Lock SFP-LANE
    gnb_bbu.Wait For Site To Be Onair
    Unlock SFP-LANE
    Close All Connections
    Sleep    10s

Lock SFP-LANE
    SELENIUM Mouse Over Visible Element
    ...     locator=//div[@class="details-panel-container"]
    Scroll Element Into View
    ...     locator=//div[@class="lane-info-section section"]
    SELENIUM Click Visible Element
    ...    locator=//button[@class='btn btn-small btn-defaultBlue' and @title='Lock']
    ...    timeout=60
    SELENIUM Pop Confirm Lock
    Wait Until Element Is Enabled
    ...    locator=//*[@class='lane-info-table']//td[contains(.,'disabled')]/following-sibling::td//button[@title='Unlock']
    ...    timeout=60

Unlock SFP-LANE
    SELENIUM Click Visible Element
    ...    locator=//*[@class='lane-info-table']//td[contains(.,'disabled')]/following-sibling::td//button[@title='Unlock']
    ...    timeout=60
    SELENIUM Pop Confirm Unlock
    Wait Until Element Is Enabled
    ...    locator=//button[@class='btn btn-small btn-defaultBlue' and @title='Lock']
    ...    timeout=60

Check transmission rate parameter
    ADMIN INFOMODEL Check Parameter Value
    ...    dist_name=${path_SFP}
    ...    dict_param=transmissionRate
    ...    value=9800

Check max transmission rate parameter does not exist
    Run Keyword And Expect Error    *    ADMIN INFOMODEL Check Parameter Value
                                         ...    dist_name=${path_SFP}
                                         ...    dict_param=maxTransmissionRate
                                         ...    value=9800

Check transmission distance parameter does not exist
    Run Keyword And Expect Error    *    ADMIN INFOMODEL Check Parameter Value
                                         ...    dist_name=${path_SFP}
                                         ...    dict_param=transmissionDistance
                                         ...    value=9800

Configure QSFP Lanes
    Delete LANE Objects
    Create QSFP-LANE Objects
    Lock LANE by CLI is performed successfully
    gnb_bbu.Wait For Site To Be Onair
    Unlock LANE by CLI is performed successfully
    Delete LANE Objects
    Create QSFP-LANE Objects
