*** Settings ***
Documentation
...      == COPYRIGHT ==
...
...      == INTRODUCTION ==
...      This sub-feature introduces updates concerning traffic shaping and IP addresses for XN and NG interfaces in
...      inter-gNB NR-DC cases.
...
...      == TEST SET NAME ==
...      CB008490-DT Xn-C/Xn-U/NG-U transport-related aspects
...
...      == TESTING SPLIT ==
...      CB008490-SR-DT-B1: DL XN-U traffic shaping during NRDC with single and multiple bearers
...      CB008490-SR-DT-B301: DL XN-U traffic shaping for forwarded data during PScellAddition and TakeBack
...      CB008490-SR-DT-B302: DL XN-U traffic shaping for forwarded data during XN and InterRAT HOs
...      CB008490-SR-DT-B4: DL XN-U traffic shaping with PDCP Fast retransmissions and maximum throughput capacity
...      CB008490-SR-DT-B7: NG-U and XN-U IP selection during PSCell Addition and TakeBack with IP version determination
...      CB008490-SR-DT-B8: IP address modification resulting in Bulk UE release for impacted NRDC users
...      CB008490-SR-DT-B901: Dynamic firewall updates during PSCell Addition
...      CB008490-SR-DT-B902: Dynamic firewall updates during Take Back
...      CB008490-SR-DT-B903: Firewall updates related to uPlaneIpAddrList configuration or modification or removal
...      CB008490-SR-DT-B1101: Firewall updates related to XN link setup on SN
...      CB008490-SR-DT-B1102: IP selection for XN-C when DualStack or transport separation for RAN sharing configured
...      CB008490-SR-DT-B12: IPSec support
...
...      == TESTING SCOPE ==
...      CB008490-SR-DT-B8: IP address modification resulting in Bulk UE release for impacted NRDC users
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1919
...
...      == HISTORY ==
...      [28.01.2025] - Create Test Suite
...      [12.02.2025] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=928088)

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot

Library     resources/CB008490_IP.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_DT_B8_MN.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_DT_B8_SN.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7
@{MN_SNSSAI_1_NG_IP}=     2a00:8a02:60:1c:0:0:4:14

*** Test Cases ***
CB008490-DT-B8 Dynamic NG-U IP address modification
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes gNB behavior during dynamic modification of MN NG-U IP address used by PDU session
    ...  before offloading and SN NG-U IP address used by offloaded PDU session when NG-U IP addresses are configured
    ...  per specified slice and CB008288 is disabled.
    ...  Test also verifies XN link establishment for IPv4/IPv6 dual stack support on Xn-C.
    ...
    ...  == PRECONDITION ==
    ...  MN gNB2 is configured to support inter-gNB NR-DC Master Node role with one FR1 cell.
    ...  NRBTS/ngUplane
    ...     ipV4AddressDN1 -> ADDR_V4_1
    ...     ipV6AddressDN1 -> ADDR_V6_1
    ...  NRBTS/xnUplane
    ...     ipV4AddressDN1 -> ADDR_V4_1
    ...     ipV6AddressDN1 -> ADDR_V6_1
    ...  NRBTS/SNSSAI-1/ngUplane
    ...     ipV4AddressDN1 -> ADDR_V4_2
    ...     ipV6AddressDN1 -> ADDR_V6_2
    ...  NRBTS/SNSSAI-2/ngUplane
    ...     ipV4AddressDN1 -> ADDR_V4_2
    ...     ipV6AddressDN1 -> ADDR_V6_2
    ...  NRBTS/xnCplane
    ...     ipV4AddressDN1 -> ADDR_V4_1
    ...     ipV6AddressDN1 -> ADDR_V6_1
    ...  XNLINK/cPlaneIpAddr -> ADDR_V6_3
    ...
    ...  SN gNB3 is configured to support inter-gNB NR-DC Secondary Node role with FR2 cell.
    ...  NRBTS/ngUplane
    ...     ipV4AddressDN1 -> ADDR_V4_3
    ...     ipV6AddressDN1 -> ADDR_V6_3
    ...  NRBTS/xnUplane
    ...     ipV4AddressDN1 -> ADDR_V4_3
    ...     ipV6AddressDN1 -> ADDR_V6_3
    ...  NRBTS/SNSSAI-1/ngUplane
    ...     ipV4AddressDN1 -> ADDR_V4_4
    ...     ipV6AddressDN1 -> ADDR_V6_4
    ...     ipV6AddressDN2 -> ADDR_V6_5
    ...  NRBTS/SNSSAI-2/ngUplane
    ...     ipV4AddressDN1 -> ADDR_V4_4
    ...     ipV6AddressDN1 -> ADDR_V6_4
    ...  NRBTS/xnCplane
    ...     ipV4AddressDN1 -> ADDR_V4_3
    ...     ipV6AddressDN1 -> ADDR_V6_3
    ...  XNLINK/cPlaneIpAddr -> ADDR_V6_1
    ...
    ...  For both gNBs:
    ...  	NRBTS/actSliceNumeExt = false
    ...  	MRBTS/MNL/resetNeededForIpChange = false
    ...  	NRBTS/actRANSharing = false
    ...  	NRBTS/actTrsSepaSARanSharing = false
    ...  	NRBTS/variableSourceUdpPortEnabled = false
    ...  	NRBTS/NRTRS_PROFILE/ngUplane is not provided
    ...  	NRBTS/pathSupervisionIntfList = 'none'
    ...  	NRDRB/nrDcDrbParam/ulDataPathNrDc = ulDataSplit_PrimaryPathMCG
    ...
    ...  UPF supports IPv4 / IPv6 dual stack (NG_U interface IP: UPF_V4, UPF_V6).
    ...  UEs support MN and SN band combination for NR-DC in capabilities.
    ...  UEs are using IPv6 NG-U addresses.
    ...  UE1 and UE2 are using SNSSAI-1. UE9 is using SNSSAI-2.
    ...
    ...  == POSTCONDITION ==
    ...   UE1 and UE2 are in RRC-CONNECTED state on NRCELL-1 (MN-gNB) without NR-DC configured
    ...   UE9 is in RRC-CONNECTED state on NRCELL-1 (MN-gNB) with NR-DC configured
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26619; 5G_RAN_USR_RRM_26894
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DT#B8: Dynamic NG-U / Xn-U IP address modification - ALT.3 and ALT.4
    ...  - US CB008490-DT#B11: Xn link establishment (different TRS / TRS security aspects considered) - ALT.1
    ...
    ...  == HISTORY ==
    ...  [28.01.2025] - Create Test Suite
    ...  [12.02.2025] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=928088)
    ...  [17.04.2025] - Add B008490-DT#B11 scenario coverage

        [Setup]    Basic prepare

    Attach UE1, add initial PDU session with nwslice-1 and trigger PSCell Addition
    Attach UE2, add initial PDU session with nwslice-1 and trigger PSCell Addition
    Attach UE9, add initial PDU session with nwslice-2 and trigger PSCell Addition

    Set expected message flow for SN initiated bulk UE release for MN gNB2, SN gNB3
    Change eNB parameter value  SNSSAI-1.nguplane.ipV6AddressDN1  MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2  bts_id=1
    Verify bulk UE release did not occur for MN gNB2, SN gNB3

    Set expected message flow for SN initiated bulk UE release for MN gNB2, SN gNB3
    Change eNB parameter value  SNSSAI-1.nguplane.ipV6AddressDN1  MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3  bts_id=2
    Verify expected message flow for SN initiated bulk UE release for MN gNB2, SN gNB3

    Verify that XNAP ResetRequest ResetRequestTypeInfo contains 'partialReset', gNB3
    Verify that NGAP NGReset contains cause:radioNetwork:release-due-to-ngran-generated-reason, gNB2
    Verify that E1AP Reset contains cause:transport:transport-resource-unavailable, gNB3
    Verify that only UE1 is released

    Set expected message flows for UE1 reestablishment via RRC Setup
    EXPECT FLOW[timeout=10]: gNB2 E1AP bearerContextModification
    Execute egate command    cmd=amf_ue_ics_param id=1 ue=1 indexToRFSP=1
    Trigger UE1 reestablishment via RRC Setup
    Verify expected message flows for UE1 reestablishment via RRC Setup
    PASS FLOW[timeout=10]: gNB2 E1AP bearerContextModification

    Set expected messages flows for TakeBack for SN gNB3
    Set expected messages flows for TakeBack for MN gNB2

    Add QoS flows with 5QI from list [9] from NRDC splitted PDU1 at UE2 and expect TakeBack occured

    Verify expected messages flows for TakeBack for SN gNB3
    Verify expected messages flows for TakeBack for MN gNB2
    Verify that MN gNB2 selects new NG-U DL IP address for the no longer offloaded PDU session

    [Teardown]  DT-B8 cleanup


*** Keywords ***
Add to UE${ue_id:\d+} initial PDU session with ICS and indexToRFSP equal ${indexToRSFP} and nwslice-${nwslice}
    EXPECT FLOW[timeout=2]: AMF1 NGAP pDUSessionResourceSetup
    Expect message flow
    ...    AMF1:NGAP_InitialContextSetupRequest as ICSRequest
    ...    alias=ICS
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Execute egate command  cmd=amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=${indexToRSFP}

    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Run keyword and continue on failure
    ...     Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=${nwslice}
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=1 using PDU Gateway ID

    FAIL FLOW[timeout=2]: AMF1 NGAP pDUSessionResourceSetup
    Flow occurred as expected       alias=ICS
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Verify that AMF1 NGAP InitialContextSetup contains indexToRSFP equal ${indexToRSFP}

Attach UE${ue_id:\d+}, add initial PDU session with nwslice-${nwslice} and trigger PSCell Addition
    Attach UE${ue_id} without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 1 and nwslice-${nwslice}
    Verify expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE${ue_id}, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE${ue_id}, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3
    UE${ue_id} sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE${ue_id}, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE${ue_id}, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3

Set expected message flow for SN initiated bulk UE release for MN gNB${mn_gnb_id:\d+}, SN gNB${sn_gnb_id:\d+}
    EXPECT FLOW[timeout=120]: gNB${sn_gnb_id} F1AP reset
    EXPECT FLOW[timeout=120]: gNB${sn_gnb_id} E1AP reset
    EXPECT FLOW[timeout=120]: gNB${sn_gnb_id} XNAP reset
    EXPECT FLOW[timeout=120]: gNB${mn_gnb_id} F1AP reset
    EXPECT FLOW[timeout=120]: gNB${mn_gnb_id} E1AP reset
    EXPECT FLOW[timeout=120]: gNB${mn_gnb_id} NGAP nGReset

Verify expected message flow for SN initiated bulk UE release for MN gNB${mn_gnb_id:\d+}, SN gNB${sn_gnb_id:\d+}
    PASS FLOW[timeout=120]: gNB${sn_gnb_id} F1AP reset
    PASS FLOW[timeout=120]: gNB${sn_gnb_id} E1AP reset
    PASS FLOW[timeout=120]: gNB${sn_gnb_id} XNAP reset
    PASS FLOW[timeout=120]: gNB${mn_gnb_id} F1AP reset
    PASS FLOW[timeout=120]: gNB${mn_gnb_id} E1AP reset
    PASS FLOW[timeout=120]: gNB${mn_gnb_id} NGAP nGReset

Verify bulk UE release did not occur for MN gNB${mn_gnb_id:\d+}, SN gNB${sn_gnb_id:\d+}
    FAIL FLOW[timeout=120]: gNB${sn_gnb_id} F1AP reset
    FAIL FLOW[timeout=120]: gNB${sn_gnb_id} E1AP reset
    FAIL FLOW[timeout=120]: gNB${sn_gnb_id} XNAP reset
    FAIL FLOW[timeout=120]: gNB${mn_gnb_id} F1AP reset
    FAIL FLOW[timeout=120]: gNB${mn_gnb_id} E1AP reset
    FAIL FLOW[timeout=120]: gNB${mn_gnb_id} NGAP nGReset

Verify that MN gNB${mn_gnb_id:\d+} selects new NG-U DL IP address for the no longer offloaded PDU session
    ${flow_alias}=     Get flow name
    ...     procedure=2*bearerContextModification
    ...     device=gNB${mn_gnb_id}
    ...     protocol=E1AP
    check_ip_in_message   BearerContextModificationResponse_1  ${flow_alias}   ${MN_SNSSAI_1_NG_IP}    NG

Verify that only UE1 is released
    ${flow_alias}=     Get flow name
    ...     procedure=reset
    ...     device=gNB3
    ...     protocol=XNAP

    Verify That Message Fulfills Query
     ...     length(ue-contexts-ToBeReleasedList) eq 1
     ...     message_alias=ResetRequest
     ...     flow_alias=${flow_alias}
