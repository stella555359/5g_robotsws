*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Create_Plan_Copy
    COAM WEBUI Create Plan

Case Setup: Create_Plan_Copy
    Common Setup

Case Teardown: Create_Plan_Copy
    Common Teardown
