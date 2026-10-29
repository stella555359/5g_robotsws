*** Settings ***

Documentation
...  Author:   Jere Jacklin
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot

Suite Setup       Common Suite Setup
Test Setup        Common Test Setup


*** Test Cases ***
Switch Power Off From All Local Units
    Run Keyword and Continue On Failure  PowerBreakers.Switch Power Off From All Local Units

