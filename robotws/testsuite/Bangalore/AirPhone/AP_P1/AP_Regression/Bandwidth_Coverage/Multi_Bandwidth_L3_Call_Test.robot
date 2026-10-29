*** Settings ***
Documentation     L3 call tests with different bandwidths
Library    OperatingSystem
Resource      Bandwidth_Keywords.robot

Suite Setup       Suite Setup For Bandwidth
Suite Teardown    Suite Teardown For Bandwidth
Test Teardown     Test Teardown For Bandwidth
Test Template     Update Bandwidth related Params and Check L3 call

*** Variables ***
${topology}    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

*** Test Cases ***                         Bandwith
Bandwidth Coverage Test for 90 MHz           90MHz
     [Tags]    AP_REG
Bandwidth Coverage Test for 50 MHz           50MHz
     [Tags]    P3_REG
Bandwidth Coverage Test for 20 MHz           20MHz
     [Tags]    AP_REG

