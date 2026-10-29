*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
Commissioning_Wizard_Automatically_Commission_Detected_HW
    Step1: Get One Planned Product Code
    Step2: Update Planned Product Code to unaligned
    Step3: Check CW detect unaligned HW
    Step4: Check CW Auto Commission detected HW

Case Setup: Automatically_Commission_Detected_HW
    Common Setup

Case Teardown: Automatically_Commission_Detected_HW
    Common Teardown

Step1: Get One Planned Product Code
    ${ori_value}   COAM WEBUI Get Parameter Value
    ...   dist_name=${MO_NAME}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...   filter_param=Product code planned
    ...   abbr=prodCodePlanned
    Set Test Variable   ${ori_value}

Step2: Update Planned Product Code to unaligned
    COAM WEBUI Set Parameter Value
    ...   dist_name=${MO_NAME}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...   filter_param=Product code planned
    ...   abbr=prodCodePlanned
    ...   new_value=x${ori_value}

Step3: Check CW detect unaligned HW
    Switch To CW Page
    Check BBMOD Error IN CW Site View

Step4: Check CW Auto Commission detected HW
    Auto Align BBMOD HW Type IN CW Site View
    ${now_value}   COAM WEBUI Get Parameter Value
    ...   dist_name=${MO_NAME}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...   filter_param=Product code planned
    ...   abbr=prodCodePlanned
    Should Be Equal   ${now_value}    ${ori_value}
