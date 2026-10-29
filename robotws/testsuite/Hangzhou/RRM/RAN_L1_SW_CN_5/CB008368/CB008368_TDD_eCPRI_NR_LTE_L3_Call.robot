*** Settings ***
Documentation
...    Contact: shujun.j.huang@nokia-sbell.com

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}
${scfc_file}      CB008368_ASOE_3AZHL_TDD_eCPRI_3NRCEL_8T8R_6LNCEL_8T8R.xml

*** Test Cases ***
CB008368_SR_F2_US09_ASOE_TDD_LTE_NR_Concurrent_mode_eCPRI_25GE_FH_L3call_trunk
    [Tags]    QC_283670    SMAwave    CB008368    Trunk
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008368${/}${scfc_file}
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:20; 10:20; 13:20; 14:20; 3:20; 4:20; 7:20; 8:20; 11:20; 12:20; 15:20; 16:20
    Adjust HBTE attenuation values    10.108.241.29    1:20; 2:20; 3:20; 4:20; 5:20; 6:20; 7:20; 8:20
    Perform 4G Cell block 12,13,22,23,32,33 via AdminCLI
    Perform NR Cell lock 21,31 via AdminCLI
    SMAwave L3 call    183861259    1400M    70M    10%    5G    41
    Perform NR Cell lock 11 via AdminCLI
    Perform 4G Cell unblock 12 via AdminCLI
    SMAwave L3 call    12    120M    10M    50%    4G    41
    Perform 4G Cell unblock 13,22,23,32,33 via AdminCLI

CB008368_SR_F2_US09_ASOE_TDD_LTE_NR_Concurrent_mode_eCPRI_25GE_FH_L3call_branch
    [Tags]    QL3    CB008368    Branch    QC_538323
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008368${/}${scfc_file}
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:20; 10:20; 13:20; 14:20; 3:20; 4:20; 7:20; 8:20; 11:20; 12:20; 15:20; 16:20
    Adjust HBTE attenuation values    10.108.241.29    1:20; 2:20; 3:20; 4:20; 5:20; 6:20; 7:20; 8:20
    Perform 4G Cell block 12,13,22,23,32,33 via AdminCLI
    Perform NR Cell lock 21,31 via AdminCLI
    SMAwave L3 call    183861259    1400M    70M    10%    5G    41
    Perform NR Cell lock 11 via AdminCLI
    Perform 4G Cell unblock 12 via AdminCLI
    SMAwave L3 call    12    120M    10M    50%    4G    41
    Perform 4G Cell unblock 13,22,23,32,33 via AdminCLI
