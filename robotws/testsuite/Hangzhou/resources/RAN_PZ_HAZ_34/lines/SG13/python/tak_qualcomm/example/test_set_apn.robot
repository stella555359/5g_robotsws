*** Settings ***
Resource    ../../../robot/common_resource.robot

*** Variables ***
${UE_CONFIG}      config/qualcomm_multi_ue.yml
${UE1_ID}         878674d2        #get from "adb devices" command on UE PC


*** Test Cases ***
Multi Qualcomm UE Test Example
    Qualcomm Setup
    Qualcomm Attach With Adb    ${UE1_ID}
    Qualcomm Set Apn    ${UE1_ID}    123.nsn.com    123.nsn.com
    Run Keyword And Ignore Error    Qualcomm Get Ip With Adb    ${UE1_ID}
    Sleep    5
    Qualcomm Set Apn    ${UE1_ID}    SA    wap1.nokia.com
    Run Keyword And Ignore Error     Qualcomm Get Ip With Adb    ${UE1_ID}
    #Should Not Be Equal    ${nsa_ip}    ${sa_ip}
    Qualcomm Teardown
