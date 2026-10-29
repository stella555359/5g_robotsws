*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_ims2ToSCF TC

Resource  ../test_resources/WebEM__Admin_CLI_ims2ToSCF.robot


*** Test Cases ***
WebEM__Admin_CLI_ims2ToSCF
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_ims2ToSCF
    [Teardown]  TC Teardown
