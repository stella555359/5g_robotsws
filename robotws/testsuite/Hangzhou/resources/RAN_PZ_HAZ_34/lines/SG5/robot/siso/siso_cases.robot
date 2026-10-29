*** Settings ***
Documentation    This is common keywords for siso related cases used in team
...              Please do not modify the file without notification to author

Resource   resources/siso_keywords.robot

*** Variables ***


*** Keywords ***
General_Fault_4308_EFaultId_MdtxConfigurationFailureAl_raise_AQQL
    [Arguments]  ${ru_index}=1
    Modify RMOD Power Parameter    power_status=true
    Modify AUTONOMOUS Value In Json File AQQL    init_value=1    target_value=0    file_cmd=touch    ru_index=${ru_index}
    log to console   \n Check fault 4308 Appear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=4308
    Modify RMOD Power Parameter    power_status=false
    log to console    \n Recovery fault 4308
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
    [Teardown]  Modify AUTONOMOUS Value In Json File AQQL    init_value=0    target_value=1    file_cmd=rm -rf    ru_index=${ru_index}
