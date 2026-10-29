*** Settings ***
Documentation
...    Author: Adrian Alpredi
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)
...    Group in charge: BTS_OAM_CU
...    References: doors
...    Feature Description: 5GC002130-B
...    Sample execution:

Resource   ./resources/5GC002130-B.robot
Force Tags      CRT      requires-ipv4    5G_RAN    CLOUD_5G_AIC    product-vDU

*** Test Cases ***
[1][1.0] [1]5GC002130-B-Active supervision for containerized 5G OAM OamAgent service
    [Tags]     CRT   QC_    QCP_BTS_OAM    QCD_MN_BTS_OAM
    Check OAMAgent is restarted after killing process on VDU

[1][1.0] [3]5GC002130-B-Active supervision for containerized 5G OAM TRSConfig service
    [Tags]     CRT   QC_2728667    QCP_BTS_OAM    QCD_MN_BTS_OAM
    Check initial OAM container status
    Check TRSConfig is restarted after killing process on VDU
    Check if OAM container was restarted

[1][1.0] [2]5GC002130-B-Active supervision for containerized 5G OAM CPConfig service
    [Tags]     CRT   QC_2728666    QCP_BTS_OAM    QCD_MN_BTS_OAM
    Check initial OAM container status
    Check CPConfig is restarted after killing process on VDU
    Check if OAM container was restarted

#----------------------------------------------------------------------------------------------------------
#DO NOT CHANGE THIS SECTION BELOW!!FUTURE TESTS FOR THIS FEATURE.
#[5]5GC002130-B-Active supervision for containerized 5G OAMFH service
#    [Tags]     CRT   QC_    QCP_BTS_OAM    QCD_MN_BTS_OAM
#    Check initial OAMFH container status
#    Check OAMFH is restarted after killing process on VDU
#    Check if OAMFH container was restarted


