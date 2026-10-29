*** Settings ***
Documentation
...  		[Procedure]   "CB009745_B_06_Alarm_with_fault_id_61642_FTM_SECURITY_USER_ACCOUNT_on_VCU_and_VDU"
...  		[Date]     "26-09-2023"
...  		[Author]    "Megha"
...  		[QC_Path]   "QC_Path in Test Plan"
...  		[QC_ID]     "QC_ID in Test Lab for reporting"
...  		[Feature_ID]   "CB009745"
...  		[Validation_status]     "Passed"


Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Setup Preconditions for cbts    vdu
Suite Teardown  Setup Postconditions for cbts   vdu


*** Test Cases ***
[1]CB009745_B_06_Alarm_with_fault_id_61642_FTM_SECURITY_USER_ACCOUNT_on_VDU
    Setup Oamops    dut=cbts    alias=vdu
    Perform Recommissioning    type=delta    delta_file=${time_duration_vdu}    skip_parameter_relation_errors=${True}    timeout=300    dut=cbts
    ...    alias=vcu
    Teardown Oamops    alias=vdu    dut=cbts



    FOR    ${i}    IN RANGE   1     7
        ${password_try}=  Evaluate    int(${i}) + int(1)
        Run Keyword And Expect Error        *AuthenticationFailed*    Setup Oamops    dut=cbts    alias=vdu       username=Nemuadmin
        ...    password=${password_try}
        Sleep   10
    END

    Setup Oamops    dut=cbts    alias=vdu2     username=BTSSecurity    password=BTSsec@123
    Verify Alarm    alias=vdu2    faultid=${fault_id}     should_exist=${True}    dut=cbts
    Teardown Oamops     dut=cbts    alias=vdu2
    Sleep   10
    Sleep   300

    Setup Oamops    dut=cbts    alias=vdu
    Verify Alarm    alias=vdu    faultid=${fault_id}   should_exist=${False}    dut=cbts
    Teardown Oamops    alias=vdu    dut=cbts
