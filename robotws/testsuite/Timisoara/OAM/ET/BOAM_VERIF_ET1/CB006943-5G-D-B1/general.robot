*** Settings ***
Documentation
...    Author: Dan Moldovan (dan.moldovan@nokia.com)
...    Maintainer: Dan Moldovan (dan.moldovan@nokia.com)
...    Group in charge: BOAM_VERIF_ET1
...    References: doors
...    Feature Description:CB006943-5G-D-B1
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB006943-5G-D-B1/general.robot

Resource    ./resources/CB006943-D-B1.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
...    CLOUD_5G_CLASSICAL_ASIL_ABIO_2xO-RU    SBTS00  SBTS22R4  SBTS23R1 
...    CA_RAN_BOAM_VERIF

Suite Setup       Run Keywords  UTE TL Preparation O-RU
...               AND  Suite O-RU_Preconditions
...               AND  Get Software Release
...               AND  Set Var For Different Branches
...               AND  Add xranuser1 to oru   ${oru2}
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

Test6_LTE_OPR_REQ_30853 Public key based SSH server authentication
    [Tags]   CRT
    [Documentation]  Purpose of the test is to check that public key based SSH server
    ...   authentication is working only if O-RUs SSH server public key is known by O-DU.

    Test6_Public key based SSH server authentication

Test8_LTE_OPR_REQ_25407 SSH client authentication failure FID 4641
    [Tags]   CRT
    [Documentation]  Purpose of the test is to check that WebEM doesn't allow
    ...  inserting a Netconf user account which doesn't respect the format.

    Test8_SSH client authentication failure FID 4641

Test9_LTE_OPR_REQ_30853 SSH server authentication failure FID 4642
    [Tags]   CRT
    [Documentation]  Purpose of the test is to check that FID 4642 is raised
    ...   in case of SSH server authentication failure.

    Test9_SSH server authentication failure FID 4642

Test13_LTE_OPR_REQ_30470_Netconf_user_account_format
    [Tags]   CRT
    [Documentation]  Purpose of the test is to check that WebEM doesn't allow
    ...  inserting a Netconf user account which doesn't respect the format.

    Test13_Netconf_user_account_format

Test18_LTE_OPR_REQ_25394_Default Netconf account setup failure_FID 4644
    [Tags]   CRT
    [Documentation]  Purpose of the test is to check that WebEM doesn't allow
    ...  inserting a Netconf user account which doesn't respect the format.

    Test18_Default Netconf account setup failure_FID 4644

Test23_LTE_OPR_REQ_27999_O-DU_shall_support_the_decommission_of_O-RUs
    [Tags]   CRT
    [Documentation]  Purpose of the test is to check that it is possible
    ...   to decommission O-RUs at O-DU level.
    Test23_LTE_OPR_REQ_27999_O-DU_shall_support_the_decommission_of_O-RUs

Test12_LTE_OPR_REQ_25394_Declare different default sudo Netconf account
    [Tags]   CRT
    [Documentation]  Purpose is to check that it is possible to declare multiple default Netconf user accounts
     ...    at O-DU level when SSH server authentication method is set to
     ...    Deactivation of SSH public key validation at first connection
     ...    and O-RUs are belonging to different manufacturers but
     ...    not possible if the O-RUs are belonging to same vendor
     ...    Precondition: 2 x ORUsim needed ! Second ORUsim with different user !
#    [Setup]    Add xranuser1 to oru   ${oru2}
    Test12_Declare different default sudo Netconf account

Test14_LTE_OPR_REQ_25743 Creation of additional sudo Netconf account
    [Tags]   CRT
    [Documentation]  Purpose of the test is to check that it is not possible to create more than one additional
    ...  "sudo" Netconf account when authentication method for the SSH server is set to "No authentication"
    ...   Precondition: 2 x ORUsim needed ! Second ORUsim with different user !
#    [Setup]    Add xranuser1 to oru   ${oru2}
    Test14_Creation of additional sudo Netconf account

