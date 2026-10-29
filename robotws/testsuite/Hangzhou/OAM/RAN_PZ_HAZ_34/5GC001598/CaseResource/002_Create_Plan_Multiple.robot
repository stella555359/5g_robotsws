*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Create_Plan_Multiple
    FOR   ${index}    IN RANGE    ${5}
       COAM WEBUI Create Plan
    END

Case Setup: Create_Plan_Multiple
    Common Setup

Case Teardown: Create_Plan_Multiple
    Common Teardown
