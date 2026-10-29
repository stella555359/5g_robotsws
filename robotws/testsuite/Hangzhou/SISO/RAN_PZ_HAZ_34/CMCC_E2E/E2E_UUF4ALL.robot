*** Settings ***
Documentation     Author: Chen Yin
...               Email: yin.1.chen@nokia-sbell.com
...               Squad group: SG_02
Force Tags        5G_SISO
...    PY36
Resource          Resources/E2E_CMCC_common_keyword.robot
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002029-A/Resources/5GC002029_A_common_keywords.robot

*** Variables ***
&{fault_61524}             faultId=${61524}    #SSH enabled
&{fault_61652}             faultId=${61652}    #R&D Service Port enabled
&{fault_4654}              faultId=${4654}    #Ethernet port security is disabled
&{fault_4655}              faultId=${4655}    #Service account root access is enabled
&{fault_61649}             faultId=${61649}   #LMP access via port 443
@{allowed_faults}    &{fault_61524}    &{fault_61652}    &{fault_4654}    &{fault_4655}    &{fault_61649}
${runs_of_reset}     ${20}


*** Test Cases ***
E2E_TL_Site_Reset_with_runtime_log_checked
    [Setup]    5GC002029_A_common_keywords.Test Case Setup
    FOR    ${i}    IN RANGE    1    ${runs_of_reset}+1
        Perform BTS Site Reset
        Sleep      1min
        COAM Wait for gnb ready and cell setup    timeout=20min
        Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
        Check RMOD runtime log by radios
    END
    [Teardown]      5GC002029_A_common_keywords.Test Case Teardown
