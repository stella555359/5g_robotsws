*** Settings ***
Resource    ./../common_setup_teardown.robot
*** Variables ***

*** Test Cases ***
Small Case Collect GNB Snapshort
    [Tags]    case1
    Collect GNB SnapShot Via AaShell    log_dir=${CURDIR}
*** Keywords ***
