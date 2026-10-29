*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...
...      == TEST SET NAME ==
...      CB008490-D#B201 - Interactions handling in MN
...
...      == TESTING SPLIT ==
...      CB008490-D#B101 - Measurement handling in MN
...      CB008490-D#B201 - Interactions handling in MN
...      CB008490-D#B301 - Admission control in SN
...      CB008490-D#B401 - Security procedures in PSCell Addition (MN and SN)
...      CB008490-D#B501 - Data transmission
...
...      == TESTING SCOPE ==
...      CB008490-D#B201 - Interactions handling in MN
...      1. CB008490-SR-D-B201_1 Interaction with MFBI - UE capability enquiry after ICS with insufficient UERadioCapability
...
...      == CONTACTS ==
...         - Konrad Krzyzak        <konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Michal Szymakowski    <michal.szymakowski@nokia.com>
...         - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=868
...
...      == HISTORY ==
...      [26.03.2024] - Create Test Suite
...      [25.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904812)

Resource    ../resources/CB008490-common_keywords.robot
Resource    ../resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_3c_n77_n261_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_MFBI.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_D_B101_SN.xml
${AP_XML}=                Krakow/CB008490/iphy_1cell_n78_3cells_n257_1xAWEUB.xml
&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  2=52  3=53  4=54

*** Test Cases ***
CB008490-SR-D-B201_1 Interaction with MFBI - UE capability enquiry after ICS with insufficient UERadioCapability
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes handling of UE connected on alternative band to PCell with MFBI support. Such UE is
    ...  not considered as candidate for inter-gNB NR-DC and A4 NR-DC measurements are not activated on the UE. Still
    ...  gNB requests NR-DC band combinations during UE Capability Enquiry for such UE.
    ...
    ...  == PRECONDITION ==
    ...  MN gNB and SN gNB configured according to CB008490-B common preconditions and CB008490-GA#B1, except:
    ...    - NRBTS-2.actMultiFrequencyBandIndicatorNRSupport set to TRUE
    ...    - NRBTS-2.NRCONNECTMODE_PROFILE-1.multiFreqBandIndicatorNR is set to 78
    ...    - NRCELL-1.freqBandIndicatorNR = 77 - native band
    ...    - NRCELL-1.nrConnectModeProfileDN is pointing to NRCONNECTMODE_PROFILE-1
    ...
    ...    - UE4 supports n78 and n257, but not n77. NR-DC band combination (n78-n257) is supported by UE4.
    ...    - UE2 supports n77, n78 and n257.
    ...    - UE4 performed RRCSetup procedures in NRCELL-1 on alternative band n78 and was successfully admitted
    ...         by MN gNB, NGAP: InitialUEMessage was sent to the AMF
    ...    - UE2 performed RRCSetup procedures in NRCELL-1 on native band n77 and was successfully admitted by MN gNB,
    ...         NGAP: InitialUEMessage was sent to the AMF
    ...
    ...  == POSTCONDITION ==
    ...    - UE4 is in ACTIVE state, A4 NR-DC measurement(s) are not activated on the UE4
    ...    - UE2 is in ACTIVE state, A4 NR-DC measurement(s) are activated on the UE2
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UEs configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23740
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-D#IWK1: UE connected to alternative band in cell with MFBI support is not considered for NR-DC - ALT1
    ...
    ...  == HISTORY ==
    ...      [26.03.2024] - Create Test Suite
    ...      [25.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904812)

    [Setup]    start collecting syslog from gnbs

    Attach UE4 without ICS to gNB2 cell1
    Expect that A4 measurements are not configured for UE4 connected to alternative band with DRX
    Add to UE4 initial PDU session with ICS and indexToRFSP equal 1
    Verify that A4 measurements are not configured for UE4 connected to alternative band with DRX
    Verify that AMF1 NGAP InitialContextSetup contains UERadioCapability
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE4
    Verify that gNB2 forwards UECapabilities received from UE4 to AMF1

    Attach UE2 without ICS to gNB2 cell1
    Set expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE2 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE2, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE2, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3

    UE2 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE2, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE2, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3

    [Teardown]    Basic cleanup
