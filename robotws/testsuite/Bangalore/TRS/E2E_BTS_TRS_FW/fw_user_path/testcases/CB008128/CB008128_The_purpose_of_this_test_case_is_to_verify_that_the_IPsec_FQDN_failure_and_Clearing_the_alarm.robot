***Settings ***
Documentation
    ...     [Procedure]             "[1] CB008128_The purpose of this test case is to verify that the IPsec FQDN
    ...     failure and Clearing the alarm"
    ...     [Date]                  "24-08-2022"
    ...     [Author]                "Dinesh"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB008128"
    ...     [Validation_status]     "Validated and Passed"

Library			ute_fsmaccess
Library			SSHLibrary
Library        taf.sw.scout    WITH NAME    scout
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/resources/common_8128.robot
#Resource        ${CURDIR}/resources/common_8128_branch.robot
variables       ta_e2e_bts_trs_fw

Suite Setup     Setup Oamops
Suite Teardown     Teardown Oamops

*** Test Cases ***
[1][1.0] CB008128 The purpose of this test case is to verify that the IPsec FQDN failure and Clearing the alarm

    Start Syslog   ${CURDIR}   background_syslog.txt
    Verify build and load Plain scfc
    common_8128.Get Hostname
    common_8128.Link SCOUT SCF to Configuration ID for Reporting        ${Hostname}
    Configure Static Ipsec and verify tunnel status
    Configure Dynamic Ipsec and verify tunnel status
    Verify Ipsec Enable and Disable
    Verify Primary FQDN changes and failures
    Verify Primary RTEP IP changes and failures
    Verify Primary and Secondary FQDN
    Verify IPsec Alarms
    Perform Site Reset and verify tunnels
    Verify Tunnels during NW fluctuation
    Verify Multi TA certificate
    Teardown testcase