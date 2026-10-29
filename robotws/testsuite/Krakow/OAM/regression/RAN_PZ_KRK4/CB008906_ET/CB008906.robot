*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases CB008906

Library    ta_emss
Library    OperatingSystem
Resource   taf/rfrl/bts/robot/gnb.robot
Resource   ./resources/Robot/CB008906_Common_Keywords.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup         Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          CB008906_Common_Keywords.Common Preconditions
Test Teardown       CB008906_Common_Keywords.Common Postconditions

*** Variables ***
${bts_id} =                             ${tl.gnbs[0].global_bts_id}
${emssim_host} =                        ${tl.test_pc.default_ssh_connection_details.addr}
${emssim_user} =                        asir1

*** Test Cases ***
CB008906-SR-A_ET_05_ATL_upload_requirements_follow_NE3S_interface_specifications_and_use_audit_as_upload_type_or_content_type_in_NE3S_messages
    [Documentation]
    ...    - Description: This test case is to verify that Audit trail logs are uploaded from ASiR to EMSsim
    ...                   using NE3S interface, NE3S Service COMMON Interface Specification and
    ...                   ASiR3S Service AUDIT TRAIL Interface Specification shall be followed, and
    ...                   EMSsim and ASiR shall use 'audit' as upload type or content type in NE3S messages.
    ...    - Preconditions: SBTS is up and operational.
    [Tags]    CRT
    Log1    Change oamTls
    perform_parameter_recommissioning
    ...    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...    parameter=oamTls
    ...    operation=update
    ...    value=forced

    Log1    Active NE3S interface and set proxy_events_format as full
    Active NE3S Interface And Set Proxy Events Format As Full

    Log1    Block and unblock pRRH from ASiR WebEM
    Block And Unblock PRRH from ASiR WebEM

    Log1    Upload Audit Trail Log to EMSSIM
    Upload Audit Trail Log To EMSSIM

    Log1    Check Audit Trail Log if there are expected information
    Check Scenario Of Audit Trail Log For Block And Unblock

CB008906-SR-B_ET_11_Migration_rule_checking_for_parameters_userEventTempBufOverwriting_and_userEventTempBufThreshold
    [Documentation]
        ...    - Description: This test case is to verify that ASiR new parameters
        ...                   ASI/SECPRM.userEventTempBufOverwriting parameter and ASI/SECPRM.userEventTempBufThreshold,
        ...                   the two parameters shall be added and set to its default value.
        ...    - Preconditions: SBTS is up and operational.
    [Tags]    CRT
    Log1    Check ASI/SECPRM.userEventTempBufOverwriting and ASI/SECPRM.userEventTempBufThreshold should be default value
    Check userEventTempBufOverwriting And userEventTempBufThreshold Should Be Default Value

*** Keywords ***
Suite Setup
    Common Suite Setup With Commissioning    prefix_tag=CB008906_ET     asir_hub=${True}
    Test Suite Preparation
    OperatingSystem.Run    sudo iptables -I INPUT --proto tcp --match multiport --dport 80,443,8080,8443,6080,8062,14601,3061 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT 1 -p tcp -i eth0 -m tcp --dport 6443 -j ACCEPT
    OperatingSystem.Run    sudo /opt/emssim/util/add_user.pl -u asir1 -ip 10.84.190.118
    gnbbbu.restore_vendor_certificate
    gnbbbu.Install Certificate
    ...    cert_file=/opt/emssim/proxy/ssl/clientcert.p12
    ...    cert_type=BtsTrustChain
    ...    cert_format=P12
    ...    password=emssim
