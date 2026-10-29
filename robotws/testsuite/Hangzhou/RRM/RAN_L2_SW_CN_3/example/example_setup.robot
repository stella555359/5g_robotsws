*** Settings ***
Resource          ../resources/KISS/robot/common_resource.robot
Force Tags    QCD_MN_RAN    QCP_RAN_ET
Suite Setup    Common Suite Setup


*** Test Cases ***
Test Common Suite Setup
    Log    test common suite setup
    #Verify CELLS Are Onair