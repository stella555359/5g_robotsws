*** Settings ***
Documentation
     ...    [Procedure] "The test case is planned to validate M-PlaneIPv4 Ipsec tunnel established with expired SeGW certificate"
     ...    [Date] "30-09-2024"
     ...    [Author] "Ruchika"
     ...    [QC_Path] "QC_Path in Test Plan"
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Funtion_Hash_Tags] "IPSEC with backup ipsec enable"
     ...    [Feature_ID] "CB009741"
     ...    [Validation_status] "Validated"
     ...    [Validated_TestLine] "ASIL"
     ...    [Commissioning_comment] "This script requires 5G configuration with IPSEC Enabled."


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB009741_keywords.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown


***Test Cases***

[1][1]TRS_CB009741_M_Plane_dualstack_peercert_expiry_reauth_yes_upgrade

    Perform Recommissioning         type=delta      delta_file=${basic_CB009741}     timeout=400
    ...     skip_parameter_relation_errors=${True}
    Copy configuration files
    Read parameter BTS
    Add remote tunnel routes
    Perform Recommissioning        type=delta      delta_file=${basic_CMP_MOC_9741}     timeout=500
    ...     skip_parameter_relation_errors=${True}
    Sleep   120
    Verify cmp certificate state
    Verify tunnel establishment with valid certificate
    Perform Recommissioning        type=delta      delta_file=${Featureflag_9741}     timeout=400
    ...     skip_parameter_relation_errors=${True}
    Sleep   60
    Run    sudo ipsec restart
    Sleep   60
    Get Ipsec Tunnels Status
    Verify Alarm    faultid=61030    should_exist=${False}
    Verify Alarm    faultid=61644   severity=major    should_exist=${False}
    Sleep   10
    Verify tunnel status with expired cert
    Sleep   100
    Verify alarm with Peer certificate lifetime is Expired
    Verify Alarm        faultid=61644       occurrences=2
    Reset Bts       dut=bts     should_be_onair=${false}    wait_for=400
    Sleep   380
    Verify alarm with Peer certificate lifetime is Expired
    Verify Alarm        faultid=61644       occurrences=2
	Sleep	60
    Perform Recommissioning        type=delta      delta_file=${9741_algorithm_modify}     timeout=400
    ...     skip_parameter_relation_errors=${True}
    Verify Alarm        faultid=61645       occurrences=4
    Run    sudo cp ${ipsec_9741_algor_config} /etc/ipsec.conf
    Sleep   10
    Run    sudo ipsec restart
    Sleep   30
    Verify alarm with Peer certificate lifetime is Expired
    Verify Alarm        faultid=61644       occurrences=2
    Perform software upgrade
    Sleep   60
    Verify alarm with Peer certificate lifetime is Expired
    Verify Alarm        faultid=61644       occurrences=2
	Sleep	60
    Perform Recommissioning        type=delta      delta_file=${9741_featureflag_disable}     timeout=400
    ...     skip_parameter_relation_errors=${True}
	Sleep	60
    Verify Alarm        faultid=61644       occurrences=4
    Perform Recommissioning        type=delta      delta_file=${9741_featureflag_enable}     timeout=400
    ...     skip_parameter_relation_errors=${True}
    Verify alarm with Peer certificate lifetime is Expired
    Verify Alarm        faultid=61644       occurrences=2