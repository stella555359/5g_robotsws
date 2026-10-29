*** Settings ***
Resource    ../../../robot/common_resource.robot

*** Variables ***
${UE_CONFIG}      config/qualcomm_multi_ue.yml
${UE1_ID}         95fe0e6e        #get from "adb devices" command on UE PC


*** Test Cases ***
Multi Qualcomm UE Test Example
    Qualcomm Setup
    Qualcomm Start Qxdm Trace    ${UE1_ID}
    Qualcomm Attach With Adb    ${UE1_ID}
    Sleep    2
    Qualcomm Detach With Adb    ${UE1_ID}
    ${path1}=    Qualcomm Stop Qxdm Trace    ${UE1_ID}    C:\\tmp\\Qualcomm\\
    Qualcomm Read Nvitem    ${UE1_ID}    65633
    Qualcomm Write Nvitem    ${UE1_ID}     65633    0x0000010000000001
    Sleep    5
    Qualcomm Read Nvitem    ${UE1_ID}    65633
    # Read the second line value for 74087
    Qualcomm Read Nvitem    ${UE1_ID}    74087    -1    2
    # Write the second line value for 74087
    Qualcomm Write Nvitem    ${UE1_ID}    74087    0,8192
    Sleep    2
    # Read the second line value for 74087
    Qualcomm Read Nvitem    ${UE1_ID}    74087    -1    2
    Qualcomm Teardown
