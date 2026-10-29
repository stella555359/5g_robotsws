*Settings ***
Documentation
    ...     [Procedure]             "EDA_SMTRS-32025"
    ...     [Date]                  "31-01-24"
    ...     [Author]                "Pooja CK"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     ""
    ...     [Feature_ID]            ""
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL-2222"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB007162_Common_Keywords.robot

Suite setup    Run Keywords    setup oamops
...            AND    Setup Oamops     dut=chained_bts     alias=secondary
Suite Teardown         Teardown oamops

*** Variables ***
${index}                    1
${length}                   1

*** Test Cases ***
[1][1.0] Verification of security related parameters configuration when cores are connected
     Run Keywords        Suite Setup Preconditions
     FOR    ${index}    IN RANGE    ${length}
        ute_btssm.Reset Bts        verify_bts=True    req_rat=5g     should_be_onair=True    wait_for=300     alias=default
        Sleep      300
        Check SSH Login       Primarybts
        Check SSH Login      Secondarybts
        Sleep    20
        Verify Alarm    expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=active
        Loginbanner Verification
        Common SecOps
     END
