*** Settings ***
Documentation
...    Author: Andrada Bugiu
...    Maintainer: Cristina Nicolae (cristina.nicolae@nokia.com)
...    Group in charge: BTS_OAM_CU
...    References: doors
...    Feature Description: CB007025-A
...    Execution command:  robot -L TRACE -b debug.log general.robot

Resource   ./resources/CB007025-A.robot

Force tags  QCD_MN_RAN    QCP_RAN_ET  master_vDU    RAN_5G    RAN_Aic    CIT    CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

*** Test Cases ***
[1][1.0] 8. OAM-FH process deployed in OAM-FH container inside OAM-FH pod
     [Tags]     CRT_test
     Verify process inside container

[1][1.0] 1. OAMAgent process deployed in OAMAgent container inside OAMExt pod
    [Setup]  Should Be Equal As Strings  ${PREV TEST STATUS}  PASS
    Log to console  OAMAgent process deployed in OAMAgent container inside OAMExt pod

[1][1.0] 2. OAM processes CpConfig, TrsConfig, NRTS, TAS, IMS deployed in OAMConfig container inside OAMConfig pod
    [Setup]  Should Be Equal As Strings  ${PREV TEST STATUS}   PASS
    Log to console  OAM processes CpConfig,TrsConfig, NRTS,TAS,IMS deployed in OAMConfig container inside OAMConfig pod

[1][1.0] 3. OAM-CTP process deployed in OAM-CTP container inside OAM-CTP pod
    [Setup]  Should Be Equal As Strings  ${PREV TEST STATUS}   PASS
    Log to console   OAM-CTP process deployed in OAM-CTP container inside OAM-CTP pod

[1][1.0] 4. OAM-EAXC process deployed in OAM-FH container inside OAM-FH pod
    [Setup]  Should Be Equal As Strings  ${PREV TEST STATUS}   PASS
    Log to console   OAM-EAXC process deployed in OAM-FH container inside OAM-FH pod

[1][1.0] 18. gNB-vDU cOAM supports passive supervision for OAMPM process
    [Tags]     CRT_test
    Log to console   gNB-vDU cOAM supports passive supervision for OAMPM process
    Kill process

[1][1.0] 18. gNB-vDU cOAM supports passive supervision for OAMFM process
     [Setup]  Should Be Equal As Strings  ${PREV TEST STATUS}   PASS
    Log to console  gNB-vDU cOAM supports passive supervision for OAMFM process
