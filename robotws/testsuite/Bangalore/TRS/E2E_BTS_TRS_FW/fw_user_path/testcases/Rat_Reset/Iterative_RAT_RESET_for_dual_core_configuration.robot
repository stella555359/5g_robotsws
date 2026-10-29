*** Settings ***
Documentation
...		[Author]				"Meghana J"
...		[Procedure]				Verify Iterative BTS reset
...		[Validated_TestLine]	10_2_T0401-ASIB07
...		[Config_Comments]		 ASIB
...		[Funtion_Hash_Tags]		All rat on air


Force Tags    CLOUD_F    CA_VRF_BLR2    SBTS00    SBTS24R2    SBTS24R3    QCD_MN_RAN    QCP_RAN_VRF    CRT

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Rat_reset_common_keywords.robot

Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for testteardown

*** Variables ***
${3G_UE}    wcdma:device_1:data

*** Test Cases ***
[1][1.0] Iterative_RAT_RESET_for_dual_core_configuration
    Verify on air status
    Initiate 3G Attach and verify call
    FOR    ${i}    IN RANGE    ${RESET_ITERATIONS}
        Reset And Verify RAT    nr
        Reset And Verify RAT    lte
        Reset And Verify RAT    wcdma
        Reset And Verify RAT    gsm
    END