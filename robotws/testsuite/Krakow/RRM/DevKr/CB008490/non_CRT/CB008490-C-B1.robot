*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This subfeature introduces successful transition of UE with established inter-gNB NR-DC connection
...      (with established SN-terminated split bearer) to RRC IDLE.
...
...      == TEST SET NAME ==
...      CB008490-C#B1: UE Release due to AMF initiated Context Release
...
...      == TESTING SPLIT ==
...      CB008490-C#B1: UE Release due to AMF initiated Context Release
...      CB008490-C#B2: UE Release without bearer takeback - due to detected RLF in the PCell
...
...      == TESTING SCOPE ==
...      CB008490-C#B1: UE Release due to AMF initiated Context Release
...      1.	CB008490-C-B1_NRDC_UE_release_AMF_initiated
...
...      == CONTACTS ==
...         - Konrad Krzyzak 		<konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek 			<tomasz.pyrek@nokia.com>
...         - Michal Szymakowski    <michal.szymakowski@nokia.com>
...
...      == MAINTAINER ==
...         - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...         - Michal Szymakowski <michal.szymakowski@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/
...
...      == HISTORY ==
...      [11.12.2023] - Create Test Suite
...      [23.12.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893194))
...
Resource    ../resources/CB008490-common_keywords.robot
Resource    ../resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIP_3xsimSN_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_SN_GA_ABIP.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml


*** Test Cases ***
CB008490-C-B1_NRDC_UE_release_AMF_initiated
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behaviour for the successful transition of UE with established inter-gNB
    ...  NR-DC connection (with established SN-terminated split bearer) to RRC IDLE. Release is initiated by AMF.
    ...  All UL/DL data traffic is stopped.
    ...
    ...  == PRECONDITION ==
    ...  Use common preconditions from AC (https://collab.ext.net.nokia.com/ui#review:id=899682)
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 on gNB2 is enabled, not degraded and without alarms
    ...  NRCELL-1 and NRCELL-2 on gNB3 are enabled, not degraded and without alarms
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO + ABIO / ASIM + ABIP + ABIP)
    ...  - *depending on AP deliveries possible TC will be executed with simulated_MN/SN at CRT stage
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...
    ...
    ...  == HISTORY ==
    ...  [11.12.2023] - Create Test Suite
    ...  [23.12.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=)

    [Setup]  Prepare test environment CB008490-C-B1

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Run 1Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2

    Set expected message flows for UE1 Release due to AMF1 Context Release, MN gNB2
    Set expected message flows for UE1 Release due to AMF1 Context Release, SN gNB3

    Trigger UE1 to send deregister request

    Verify expected message flows for UE1 Release due to AMF1 Context Release, MN gNB2
    Verify expected message flows for UE1 Release due to AMF1 Context Release, SN gNB3

    Verify that NGAP:UEContextReleaseCommand contains cause:nas:deregister for MN AMF1

    Verify that XnAP:SNodeReleaseRequest contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP:SNodeReleaseRequest contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP:SNodeReleaseRequest contains pduSessionID same as in XnAP:SNodeAdditionRequestAck
    Verify that XNAP SNodeReleaseRequest contains cause:radioNetwork:normal-release, gNB2

    Verify that XNAP:SNodeReleaseRequestAcknowledge contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:SNodeReleaseRequestAcknowledge contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:SNodeReleaseRequestAcknowledge contains pduSessionID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'drb-ID', gNB3
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'rLC-Mode', gNB3
    Verify that XNAP SNodeReleaseRequestAcknowledge dRBtoBeReleasedList contains 'qfi', gNB3

    Verify that XNAP:UeContextRelease contains id-M-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest
    Verify that XNAP:UeContextRelease contains id-S-NG-RANnodeUEXnAPID same as in XnAP:SNodeReleaseRequest

     Verify that E1AP:BearerContextModificationRequest pduSessionID same as in XNAP:SnodeReleaseRequest
     Verify that E1AP:BearerContextModificationRequest cell-Group-To-Modify includes 2 items, gNB3
     Verify that E1AP:BearerContextModificationRequest cell-Group-ID eq 0 and dL-TX-Stop eq stop, gNB3
     Verify that E1AP:BearerContextModificationRequest cell-Group-ID eq 1 and dL-TX-Stop eq stop, gNB3

     Verify that E1AP:BearerContextModificationResponse pduSessionID same as in E1AP:BearerContextModificationRequest
     Verify that E1AP:BearerContextModificationResponse dRB-ID same as in E1AP:BearerContextModificationRequest

     Verify that F1AP:UEContextModificationRequest TransmissionActionIndicator is set to 'stop' for SN gNB3

     Verify that F1AP:UEContextReleaseCommand contains cause:radioNetwork:normal-release for SN gNB3
     Verify that F1AP:UEContextReleaseCommand does NOT contain RRC-Container for SN gNB3
     Verify that F1AP:UEContextReleaseCommand does NOT contain SRB-ID for SN SN gNB3

     Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:normal-release for SN gNB3

     Verify that F1AP:UEContextReleaseCommand contains cause:radioNetwork:normal-release for MN gNB2
     Verify that F1AP:UEContextReleaseCommand contains RRCContainer for MN gNB2
     Verify that F1AP:UEContextReleaseCommand contains SRB-ID eq 1 for MN gNB2

     Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:normal-release for MN gNB2

    [Teardown]  C-B1 cleanup
