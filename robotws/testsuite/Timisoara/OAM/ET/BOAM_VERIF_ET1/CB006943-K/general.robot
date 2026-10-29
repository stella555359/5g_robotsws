*** Settings ***

Documentation
...    Author:Razvan Purlea
...    Maintainer:razvan.purlea@nokia.com
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_VERIF_ET1/CB006943-K/general.robot

Resource    ./resources/CB006943-K.robot

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***

Test1_Test9
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...    This test case concatenates Test1 and Test9 from the original test plan (available in QC for feature CB006943-K)
    ...     Test 1. LTE_OPR_REQ_25407
    ...    - [TEST PURPOSE] - This test case is to verify that O-DU is reporting as supported
    ...     both aes128-ctr and 3des-cbc SSHv2 encryption algorithms (in this preferred order)
    ...     when default sudo Netconf user account is used.
    ...     Test 9. LTE_OPR_REQ_25407
    ...    - [TEST PURPOSE] - This test case is to verify that O-DU is reporting as supported
    ...     both hamc-sha2-256 and hamc-sha1 SSHv2 mac algorithms (in this preferred order)
    ...     when default sudo Netconf user account is used.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.08.2021  - Created

    Test1_Test9

Test2_Test10
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...    This test case concatenates Test2 and Test10 from the original test plan (available in QC for feature CB006943-K)
    ...     Test 2. LTE_OPR_REQ_25407
    ...    - [TEST PURPOSE] - This test case is to verify that O-DU is able to setup SSHv2 connection with O-RU
    ...     when O-RU is supporting only aes128-ctr encryption algorithm for the SSH session and when default
    ...     sudo Netconf user account is used.
    ...     Test10. LTE_OPR_REQ_25407
    ...     - [TEST PURPOSE] - This test case is to verify that O-DU is able to setup SSHv2 connection with O-RU
    ...     when O-RU is supporting only hmac-sha2-256 mac algorithm for the SSH session.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.08.2021  - Created

    Test2_Test10

Test3_Test11
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...    This test case concatenates Test3 and Test11 from the original test plan (available in QC for feature CB006943-K)
    ...     Test 3. LTE_OPR_REQ_25407
    ...    - [TEST PURPOSE] - This test case is to verify that O-DU is able to setup SSHv2 connection with O-RU when
    ...     O-RU is supporting only 3des-cbc encryption algorithm for the SSH session and
    ...     default sudo Netconf user account is used.
    ...     Test11. LTE_OPR_REQ_25407
    ...     - [TEST PURPOSE] - This test case is to verify that O-DU is able to setup SSHv2 connection with O-RU
    ...     when O-RU is supporting only hmac-sha1 mac algorithm for the SSH session.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.08.2021  - Created

    Test3_Test11

Test4
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...     Test 4. LTE_OPR_REQ_25407
    ...    - [TEST PURPOSE] - This test case is to verify that FID 4640:EFaultId_SshAlgorithmNegotiationFailureAI is visible
    ...     in case SSH encryption algorithm negotiation failure.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.08.2021  - Created

    Test4

Test12
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...     Test 4. LTE_OPR_REQ_25407
    ...    - [TEST PURPOSE] - This test case is to verify that FID 4640:EFaultId_SshAlgorithmNegotiationFailureAI is visible
    ...     in case SSH MAC algorithm negotiation failure.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.08.2021  - Created

    Test12



