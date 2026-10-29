*** Settings ***

Documentation
...   Author: lavanya.m_h@nokia.com
...   Maintainer: rajesh.1.murmu@nokia.com
...   Group in charge: I_MN_RAN_RD_VRF_BLR1_T08_TESTER_GMS <I_MN_RAN_RD_VRF_BLR1_T08_TESTER@internal.nsn.com>
...   Description: Test Suite for CB012450_TDD
...   Exe cmd:robot  --outputdir /home/ute/results -L TRACE -b debug.log -d ~/logs/CB010918_BOAM_ET_$(date +%y%m%d) general.robot



Resource    ./testsuite/Bangalore/ORAN/T08/CB012450/NR-TDD/resources/CB012450_Keywords.robot
Force Tags       CLOUD_5G_O_H_AP_LOO    SBTS00    CB012450    NR_TDD_L3call_validation


Suite setup        Suite Setup
Test Setup        Test Preconditions
Test Teardown     Test Postconditions
Suite Teardown     Suite Teardown


*** Test Cases ***
[TC_01]CB012450_Configuration of O-RU from WebEM along with L3 call validation
	CB012450_Configuration of O-RU from WebEM along with L3 call validation
    [Tags]    QC_114551   QCD_MN_RAN    QCP_RAN_VRF

[TC_02]CB012450_Verification of Successful setup of Voice over NR call with ROHC enabled with TDD
    CB012450_Verification of Successful setup of Voice over NR call with ROHC enabled with TDD
    [Tags]    QC_114550   QCD_MN_RAN    QCP_RAN_VRF

[TC_03]CB012450_Verification of delay parameters as per IOT profile
    CB012450_Verification of delay parameters as per IOT profile
    [Tags]    QC_114565   QCD_MN_RAN    QCP_RAN_VRF
