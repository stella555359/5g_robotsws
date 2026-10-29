*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces additional scenarios during PSCell Addition.
...
...      == TEST SET NAME ==
...      CB008490-SR-D-B401 Security procedures in PSCell Addition (MN and SN)
...
...      == TESTING SPLIT ==
...      CB008490-SR-D-B101 Measurement handling (MN)
...      CB008490-SR-D-B201 Interactions handling (MN)
...      CB008490-SR-D-B301 Admission Control (SN)
...      CB008490-SR-D-B401 Security procedures in PSCell Addition (MN and SN)
...      CB008490-SR-D-B501 Data Transmission
...
...      == TESTING SCOPE ==
...      CB008490-SR-D-B401 Security procedures in PSCell Addition (MN and SN)
...         1.	CB008490-SR-D-B401_1 SNodeAdditionRequestReject due to SN not supporting Integrity or Ciphering algorithm present
...             in the UE security capability
...         2.	CB008490-SR-D-B401_2 Successful SNode Addition - SN does not support algorithms for Integrity and Encryption supported by the MN
...         3.	CB008490-SR-D-B401_5 SN behaviour when UPIP policy is set to preferred and UPIP is activated in MN for the Offloaded PDU session
...         4.  CB008490-SR-D-B401_6 SN behaviour when UPIP policy is set to preferred and UPIP is not activated in MN for the Offloaded PDU session
...
...      == CONTACTS ==
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/00025ee1#o=8981&hlt
...
...      == HISTORY ==
...      [02.02.2024] - Create Test Suite
...      [25.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904955)
...      [18.04.2024] - merge TCs for CRT

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_D_B401_MN_UPIP_activated_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_D_B401_SN_UPIP_activated.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml
${encryption}=            ${True}
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7  171=8

*** Test Cases ***
CB008490-SR-D-B401_1_2
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...    Merged testcases from file CB008490-D-B401.robot:
    ...      1.	CB008490-SR-D-B401_1 SNodeAdditionRequestReject due to SN not supporting Integrity or Ciphering algorithm present
    ...         in the UE security capability
    ...      2.	CB008490-SR-D-B401_2 Successful SNode Addition - SN does not support algorithms for Integrity and Encryption supported by the MN
    ...
    ...  == PRECONDITION ==
    ...    See preconditions of corresponding test cases
    ...
    ...  == POSTCONDITION ==
    ...    See postconditions of corresponding test cases
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_23747
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-D#B10: NR-DC PSCell RAC (successful admission)
    ...
    ...  == HISTORY ==
    ...  [02.02.2024] - Create Test Suite
    ...  [25.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904955)

    [Setup]    Prepare test environment CB008490-D-B401_2 with security indication set to required

    # CB008490-SR-D-B401_1 SNodeAdditionRequestReject due to SN not supporting Integrity or Ciphering algorithm present in the UE security capability
    Attach UE13 and add initial PDU session to MN gNB NRCELL-1
    Verify in NGAP:InitialContextSetupRequest that SecurityIndication is set to required
    Set expected messages flows for SNodeAddition Reject for SN gNB3
    UE13 sends A4 measurement with id=1 and PCIs [52]
    Verify expected messages flows for SNodeAddition Reject for SN gNB3
    Verify in sNGRANnodeAdditionPreparationFailure supported nea: [nea0] and nia: [nia2] algorithms for SN gNB3
    Verify that SNodeAdditionRequestReject contains cause:radioNetwork:encryption-and-or-integrity-protection-algorithms-not-supported for SN gNB3
    Trigger UE13 to send deregister request

    # CB008490-SR-D-B401_2 Successful SNode Addition - SN does not support algorithms for Integrity and Encryption supported by the MN
    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Verify in NGAP:InitialContextSetupRequest that SecurityIndication is set to required
    Verify in BearerContextSetupRequest that cipheringAlgorithm is set to nEA0 and encryptionKey is present for MN gNB2
    Verify in BearerContextSetupRequest that integrityProtectionAlgorithm is set to i-128-NIA1 and integrityProtectionKey is present for MN gNB2
    Add to UE1 second PDU session after ICS
    Add to UE1 PDU2 session QoS flows with 5QI from list [171] and delete QoS flows with 5QI from list [] via amf

#    Run 10Mbps UL and 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 2 seconds

    Set expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3

    Verify in SNodeAdditionRequest that it has 8 required protocolIE items for SN gNB3
    Verify in SNodeAdditionRequest that pduSessionId is set to 1 and mn-terminated is not present and sn-terminated is present for SN gNB3
    Verify in SNodeAdditionRequest that integrityProtectionIndication is set to required for SN gNB3
    Verify in SNodeAdditionRequest that integrityProtection is enabled in MN

    Verify in BearerContextSetupRequest that cipheringAlgorithm is set to nEA0 and encryptionKey is present for SN gNB3
    Verify in BearerContextSetupRequest that integrityProtectionAlgorithm is set to i-128-NIA2 and integrityProtectionKey is present for SN gNB3
    Verify in BearerContextSetupRequest that id-UEDLMaximumIntegrityProtectedDataRate is present for SN gNB3
    Verify in BearerContextSetupRequest that SecurityIndication is set to required for SN gNB3

    Verify in SNodeAdditionRequestAck that integrityProtection is enabled in SN
    Verify in SNodeAdditionRequestAck that securityResult is not present for SN gNB3
    Verify in SNodeAdditionRequestAck SN-to-MN-Container that mcg-RB-Config is not present for SN gNB3
    Verify in SNodeAdditionRequestAck that cipheringAlgorithm is set to nea0 and integrityProtAlgorithm is set to nia2 for SN gNB3

    Verify in RRCReconfiguration that sk-Counter is set to 0 for UE1

#    Verify 10MBps DL traffic on MCG bearer for UE1
#    Verify 0MBps DL traffic on SCG bearer for UE1
#    Verify 0MBps UL traffic on MCG bearer for UE1
#    Verify 10MBps UL traffic on SCG bearer for UE1
#    Stop 10Mbps UL and DL traffic on UE1 PDU1 QFI1

    [Teardown]    D-B401_2 cleanup


CB008490-SR-D-B401_5_6
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...    Merged testcases from file CB008490-D-B401.robot:
    ...      1.	CB008490-SR-D-B401_5 SN behaviour when UPIP policy is set to preferred and UPIP is activated in MN for the Offloaded PDU session
    ...      2.	CB008490-SR-D-B401_6 SN behaviour when UPIP policy is set to preferred and UPIP is not activated in MN for the Offloaded PDU session
    ...
    ...  == PRECONDITION ==
    ...    See preconditions of corresponding test cases
    ...
    ...  == POSTCONDITION ==
    ...    See postconditions of corresponding test cases
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_23747
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-D#B10: NR-DC PSCell RAC (successful admission)
    ...
    ...  == HISTORY ==
    ...  [02.02.2024] - Create Test Suite
    ...  [25.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904955)

    [Setup]    Prepare test environment CB008490-D-B401_5_6 with security indication set to preferred

    # CB008490-SR-D-B401_5 SN behaviour when UPIP policy is set to preferred and UPIP is activated in MN for the Offloaded PDU session
    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Verify in NGAP:InitialContextSetupRequest that SecurityIndication is set to preferred
    Verify in BearerContextSetupRequest that cipheringAlgorithm is set to nEA0 and encryptionKey is present for MN gNB2
    Verify in BearerContextSetupRequest that integrityProtectionAlgorithm is set to i-128-NIA2 and integrityProtectionKey is present for MN gNB2

#    Run 10Mbps UL and 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 2 seconds

    Set expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3

    Verify in SNodeAdditionRequest that it has 8 required protocolIE items for SN gNB3
    Verify in SNodeAdditionRequest that pduSessionId is set to 1 and mn-terminated is not present and sn-terminated is present for SN gNB3
    Verify in SNodeAdditionRequest that integrityProtectionIndication is set to preferred for SN gNB3
    Verify in SNodeAdditionRequest that integrityProtection is enabled in MN

    Verify in BearerContextSetupRequest that cipheringAlgorithm is set to nEA0 and encryptionKey is present for SN gNB3
    Verify in BearerContextSetupRequest that integrityProtectionAlgorithm is set to i-128-NIA2 and integrityProtectionKey is present for SN gNB3
    Verify in BearerContextSetupRequest that id-UEDLMaximumIntegrityProtectedDataRate is present for SN gNB3
    Verify in BearerContextSetupRequest that SecurityIndication is set to required for SN gNB3

    Verify in SNodeAdditionRequestAck that integrityProtection is enabled in SN
    Verify in SNodeAdditionRequestAck that securityResult is present and integrityProtectionResult is performed for SN gNB3
    Verify in SNodeAdditionRequestAck SN-to-MN-Container that mcg-RB-Config is not present for SN gNB3
    Verify in SNodeAdditionRequestAck that cipheringAlgorithm is set to nea0 and integrityProtAlgorithm is set to nia2 for SN gNB3

#    Verify 10MBps DL traffic on MCG bearer for UE1
#    Verify 0MBps DL traffic on SCG bearer for UE1
#    Verify 0MBps UL traffic on MCG bearer for UE1
#    Verify 10MBps UL traffic on SCG bearer for UE1
#    Stop 10Mbps UL and DL traffic on UE1 PDU1 QFI1
    Trigger UE1 to send deregister request

    # CB008490-SR-D-B401_6 SN behaviour when UPIP policy is set to preferred and UPIP is not activated in MN for the Offloaded PDU session

    Configure    {'MOC': 'NRBTS', 'ID': '2', 'actUPIPSupportForPreferred': 'false'}  bts_id=1

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Verify in NGAP:InitialContextSetupRequest that SecurityIndication is set to preferred
    Verify in BearerContextSetupRequest that cipheringAlgorithm is set to nEA0 and encryptionKey is present for MN gNB2
    Verify in BearerContextSetupRequest that integrityProtectionAlgorithm is set to i-128-NIA2 and integrityProtectionKey is present for MN gNB2

#    Run 10Mbps UL and 10Mbps DL traffic on UE1 PDU1 QFI1 and wait 2 seconds

    Set expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3

    Verify in SNodeAdditionRequest that it has 8 required protocolIE items for SN gNB3
    Verify in SNodeAdditionRequest that integrityProtectionIndication is set to preferred for SN gNB3
    Verify in SNodeAdditionRequest that integrityProtection is not enabled in MN

    Verify in BearerContextSetupRequest that cipheringAlgorithm is set to nEA0 and encryptionKey is present for SN gNB3
    Verify in BearerContextSetupRequest that integrityProtectionAlgorithm is set to i-128-NIA2 and integrityProtectionKey is present for SN gNB3
    Verify in BearerContextSetupRequest that id-UEDLMaximumIntegrityProtectedDataRate is not present for SN gNB3
    Verify in BearerContextSetupRequest that SecurityIndication is set to not-needed for SN gNB3

    Verify in SNodeAdditionRequestAck that integrityProtection is not enabled in SN
    Verify in SNodeAdditionRequestAck that securityResult is present and integrityProtectionResult is not-performed for SN gNB3
    Verify in SNodeAdditionRequestAck SN-to-MN-Container that mcg-RB-Config is not present for SN gNB3
    Verify in SNodeAdditionRequestAck that cipheringAlgorithm is set to nea0 and integrityProtAlgorithm is set to nia2 for SN gNB3

#    Verify 10MBps DL traffic on MCG bearer for UE1
#    Verify 0MBps DL traffic on SCG bearer for UE1
#    Verify 0MBps UL traffic on MCG bearer for UE1
#    Verify 10MBps UL traffic on SCG bearer for UE1
#    Stop 10Mbps UL and DL traffic on UE1 PDU1 QFI1

    [Teardown]    D-B401_6 cleanup


*** Keywords ***
Attach UE${ue_id:\d+} and add initial PDU session to MN gNB NRCELL-${cell_id:\d+}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    Set expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextSetup
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextSetup

Set expected flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_id:\d+}, SN gNB${sn_id:\d+}
    Set expected messages flows for SNodeAddition for SN gNB${sn_id}
    Set expected messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Set expected not failed messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Set expected not failed messages flows for SNodeAddition for SN gNB${sn_id}

Verify expected flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_id:\d+}, SN gNB${sn_id:\d+}
    Verify expected messages flows for SNodeAddition for SN gNB${sn_id}
    Verify expected messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Verify expected not failed messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Verify expected not failed messages flows for SNodeAddition for SN gNB${sn_id}
