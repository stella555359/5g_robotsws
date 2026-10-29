***Settings ***
Documentation
    ...     [Procedure]             "CB012611 Support for degraded Capacity board Test cases"
    ...     [Date]                  "01-10-24"
    ...     [Author]                "Pooja K, Shivkumar Biradar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB012611"
    ...     [Requirement_ID]        "5G_RAN_USR_COM_22009;5G_RAN_USR_COM_22010;5G_RAN_USR_COM_22012;5G_RAN_USR_COM_22429"
    ...     [Requirement_ID]        "5G_RAN_USR_COM_22469;G_RAN_USR_COM_22468;5G_RAN_USR_COM_22728;5G_RAN_USR_COM_22763;5G_RAN_USR_COM_22765"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL-2216"

Library         SSHLibrary
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/DCB_both.robot

Suite setup    Run Keywords    setup oamops
...            AND    Setup Oamops     dut=chained_bts     alias=secondary
Suite Teardown     Run Keywords     Teardown oamops
...            AND    Teardown Oamops    dut=chained_bts    alias=secondary

*** Test Cases ***
[1]ABIO reset with single failed Loki - basic configuration
       Run Keywords        Suite Setup Preconditions
       Continue Keyword Execution On Failure    ${True}
       Perform Commissioning   scf_file=${base_scf}    verify_bts_status=True      timeout=300       alias=default
       BuiltIn.Sleep    300
       verify precondition
       Login Secondary Core and Execute POWER failure from FCT and verify status For LOKI A
       Login Secondary Core and Execute POWER failure restore from FCT
       Reset Bts   should_be_onair=${False}
       BuiltIn.Sleep    300
       verify LOKI status

[1]ABIO reset with single failed Loki B - basic configuration
       Continue Keyword Execution On Failure    ${True}
       verify precondition
       Login Secondary Core and Execute POWER failure from FCT and verify status For LOKI B
       Login Secondary Core and Execute POWER failure restore from FCT
       Reset Bts   should_be_onair=${False}
       BuiltIn.Sleep    300
       verify LOKI status
