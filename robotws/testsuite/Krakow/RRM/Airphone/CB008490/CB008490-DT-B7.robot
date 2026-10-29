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
...      CB008490-SR-DT-B7: NG-U and XN-U IP selection during PSCell Addition and TakeBack with IP version determination
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
...      [18.12.2024] - Create Test Suite
...      [22.01.2025] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=926063)

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot

Library     resources/CB008490_IP.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_DT_B7_RAN_sharing_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_SN_DT_B7_RAN_sharing.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7

&{MN_PLMN_1_IP}=    NG_IP4=10.0.1.2    NG_IP6=2a00:8a02:60:1c:0:0:4:13    XN_IP4=10.0.1.2    XN_IP6=2a00:8a02:60:1c:0:0:4:13
&{MN_PLMN_2_IP}=    NG_IP4=10.0.1.2    NG_IP6=2a00:8a02:60:1c:0:0:4:14    XN_IP4=10.0.1.2    XN_IP6=2a00:8a02:60:1c:0:0:4:14
&{SN_PLMN_1_IP}=    NG_IP4=10.0.1.4    NG_IP6=2a00:8a02:60:1c:0:0:4:384   XN_IP4=10.0.1.4    XN_IP6=2a00:8a02:60:1c:0:0:4:384
&{SN_PLMN_2_IP}=    NG_IP4=10.0.1.6    NG_IP6=2a00:8a02:60:1c:0:0:1:438   XN_IP4=10.0.1.4
@{UPF_IP}=          10.0.1.1           2a00:8a02:60:1c:0:0:4:51

*** Test Cases ***
CB008490-DT-B7_8 IP address handling in NR-DC - RAN sharing enabled
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes NG-U and XN-U IP address assignment during NR-DC establishment and release when
    ...  RAN sharing is enabled for MN and SN - PCell and PSCell are shared between two operators.
    ...  Separate NG-U and XN-U IP addresses are configured for two PLMNs on MN and SN.
    ...  Test case also verifies selection of IP protocol version when both IPv4 and IPv6 addresses are configured for
    ...  XN-U and NG-U interfaces on MN and SN.
    ...
    ...  == PRECONDITION ==
    ...  MN gNB2 is configured to support inter-gNB NR-DC Master Node role with one FR1 cell.
    ...  NRCELL-1/NRPLMNSET_SA-1 -> PLMN_1, PLMN_2
    ...  NRBTS-2/ngUplane
    ...  	nrPlmnDN -> PLMN_1
    ...     ipV4AddressDN1 -> ADDR_V4_1
    ...     ipV6AddressDN1 -> ADDR_V6_1
    ...
    ...  	nrPlmnDN -> PLMN_2
    ...  	ipV4AddressDN1 -> ADDR_V4_2
    ...  	ipV6AddressDN1 -> ADDR_V6_2
    ...
    ...  NRBTS-2/xnUplane
    ...  	nrPlmnDN -> PLMN_1
    ...     ipV4AddressDN1 -> ADDR_V4_1
    ...     ipV6AddressDN1 -> ADDR_V6_1
    ...
    ...  	nrPlmnDN -> PLMN_2
    ...  	ipV4AddressDN1 -> ADDR_V4_2
    ...  	ipV6AddressDN1 -> ADDR_V6_2
    ...
    ...  SN gNB3 is configured to support inter-gNB NR-DC Secondary Node role with FR2 cell.
    ...  NRCELL-2/NRPLMNSET_SA-1 -> PLMN_1, PLMN_2
    ...  NRBTS-3/ngUplane
    ...  	nrPlmnDN -> PLMN_1
    ...     ipV4AddressDN1 -> ADDR_V4_3
    ...     ipV6AddressDN1 -> ADDR_V6_3
    ...
    ...  	nrPlmnDN -> PLMN_2
    ...  	ipV4AddressDN1 -> ADDR_V4_4
    ...  	ipV6AddressDN1 -> ADDR_V6_4
    ...
    ...  NRBTS-3/xnUplane
    ...  	nrPlmnDN -> PLMN_1
    ...     ipV4AddressDN1 -> ADDR_V4_3
    ...     ipV6AddressDN1 -> ADDR_V6_3
    ...
    ...  	nrPlmnDN -> PLMN_2
    ...  	ipV4AddressDN1 -> ADDR_V4_3
    ...
    ...  For both gNBs:
    ...  	NRBTS/actRANSharing = true
    ...  	NRBTS/actRanSharingEnh = true
    ...  	NRBTS/actTrsSepaSARanSharing = true
    ...  	NRBTS/variableSourceUdpPortEnabled = false
    ...  	NRBTS/SNSSAI/ngUplane and NRBTS/NRTRS_PROFILE/ngUplane are not provided
    ...  	NRBTS/pathSupervisionIntfList = 'none'
    ...  	NRDRB/nrDcDrbParam/ulDataPathNrDc = ulDataSplit_PrimaryPathMCG
    ...  	NRBTS/xnCplane/ipV4AddressDN1 -> ADDR_V4
    ...  	NRBTS/ngCplane/ipV4AddressDN1 -> ADDR_V4
    ...
    ...  UEs support MN and SN band combination for NR-DC in capabilities.
    ...  for UE1 selected PLMN is PLMN-2, for UE3 selected PLMN is PLMN-2
    ...  UPF supports IPv4 / IPv6 dual stack (NG_U interface IP: UPF_V4, UPF_V6).
    ...  Xn link between MN and SN is established.
    ...
    ...  == POSTCONDITION ==
    ...   UEs are in RRC-CONNECTED state on NRCELL-1 (MN-gNB) without NR-DC configured
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26597
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...     - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DT#B7: NG-U / Xn-U IP address handling during PSCell Addition / operation in NR-DC / bearer takeback
    ...                     - main and ALT.6
    ...
    ...  == HISTORY ==
    ...  [18.12.2024] - Create Test Suite
    ...  [22.01.2025] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=926063)

    [Setup]    Basic prepare

    #================================================ UE1 ==============================================================
    Attach UE1 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Verify both versions of UPF IP provided for MN in InitialContextSetupRequest

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3

    Verify both ver of SN XN-U IP for PLMN-1 in BearerCtxModReq for MN
    Verify both ver of SN XN-U IP for PLMN-1 in UECtxModReq for MN
    Verify IPv6 ver of MN XN-U IP for PLMN-1 in UECtxModResp for MN

    Verify IPv6 ver of MN XN-U IP for PLMN-1 in XnUAddressInd for SN
    Verify both versions of UPF IP provided for SN in BearerContextSetupRequest
    Verify IPv6 ver of SN NG-U IP for PLMN-1 in BearerCtxSetResp for SN
    Verify both ver of SN XN-U IP for PLMN-1 in BearerCtxSetResp for SN
    Verify IPv6 ver of MN XN-U IP for PLMN-1 in BearerCtxModReq for SN

    Set expected messages flows for TakeBack for SN gNB3
    Set expected messages flows for TakeBack for MN gNB2

    Add QoS flows with 5QI from list [9] from NRDC splitted PDU1 at UE1 and expect TakeBack occured

    Verify expected messages flows for TakeBack for SN gNB3
    Verify expected messages flows for TakeBack for MN gNB2

    Verify both versions of UPF IP provided for MN in BearerContextModificationRequest
    Verify IPv6 ver of MN NG-U IP for PLMN-1 in BearerCtxModResp for MN
    Verify both ver of MN XN-U IP for PLMN-1 in BearerCtxModResp for MN
    Verify both ver of MN XN-U IP for PLMN-1 in XnUAddressInd for SN
    Verify both ver of MN XN-U IP for PLMN-1 in BearerCtxModReq for SN after TB

    #================================================ UE3 ==============================================================
    Attach UE3 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE3 and AMF1
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE3 and AMF1
    Verify both versions of UPF IP provided for MN in InitialContextSetupRequest

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE3, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE3, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3
    UE3 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE3, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE3, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3

    Verify IPv4 ver of SN XN-U IP for PLMN-2 in BearerCtxModReq for MN
    Verify IPv4 ver of SN XN-U IP for PLMN-2 in UECtxModReq for MN
    Verify IPv4 ver of MN XN-U IP for PLMN-2 in UECtxModResp for MN

    Verify IPv4 ver of MN XN-U IP for PLMN-2 in XnUAddressInd for SN
    Verify both versions of UPF IP provided for SN in BearerContextSetupRequest
    Verify IPv6 ver of SN NG-U IP for PLMN-2 in BearerCtxSetResp for SN
    Verify IPv4 ver of SN XN-U IP for PLMN-2 in BearerCtxSetResp for SN
    Verify IPv4 ver of MN XN-U IP for PLMN-2 in BearerCtxModReq for SN

    Set expected messages flows for TakeBack for SN gNB3
    Set expected messages flows for TakeBack for MN gNB2

    Add QoS flows with 5QI from list [9] from NRDC splitted PDU1 at UE3 and expect TakeBack occured

    Verify expected messages flows for TakeBack for SN gNB3
    Verify expected messages flows for TakeBack for MN gNB2

    Verify both versions of UPF IP provided for MN in BearerContextModificationRequest
    Verify IPv6 ver of MN NG-U IP for PLMN-2 in BearerCtxModResp for MN
    Verify both ver of MN XN-U IP for PLMN-2 in BearerCtxModResp for MN
    Verify both ver of MN XN-U IP for PLMN-2 in XnUAddressInd for SN
    Verify both ver of MN XN-U IP for PLMN-2 in BearerCtxModReq for SN after TB

    [Teardown]  Basic cleanup

*** Keywords ***
Create IP list
    [Arguments]    ${version}    ${int}   ${plmn}    ${node}
    @{IPs}      Create List
    Run Keyword If    '${version}'=='both'
    ...  Append To List      ${IPs}  ${${node}_PLMN_${plmn}_IP['${int}_IP4']}  ${${node}_PLMN_${plmn}_IP['${int}_IP6']}
    Run Keyword If    '${version}'=='IPv4'
    ...  Append To List      ${IPs}  ${${node}_PLMN_${plmn}_IP['${int}_IP4']}
    Run Keyword If    '${version}'=='IPv6'
    ...  Append To List      ${IPs}  ${${node}_PLMN_${plmn}_IP['${int}_IP6']}
    [Return]    @{IPs}

Verify both versions of UPF IP provided for MN in InitialContextSetupRequest
    ${flow_alias}=     Get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF1
    ...     protocol=NGAP
    check_ip_in_message   InitialContextSetupRequest  ${flow_alias}   ${UPF_IP}

Verify both versions of UPF IP provided for MN in BearerContextModificationRequest
    ${flow_alias}=     Get flow name
    ...     procedure=2*bearerContextModification
    ...     device=gNB2
    ...     protocol=E1AP
    check_ip_in_message   BearerContextModificationRequest_1  ${flow_alias}    ${UPF_IP}

Verify both versions of UPF IP provided for SN in BearerContextSetupRequest
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB3
    ...     protocol=E1AP
    check_ip_in_message  BearerContextSetupRequest  ${flow_alias}    ${UPF_IP}

Verify ${ver:IPv4|IPv6|both} ver of ${node:MN|SN} ${inter:XN|NG}-U IP for PLMN-${plmn} in BearerCtxModReq for MN
    ${flow_alias}=     Get flow name
    ...     procedure=2*bearerContextModification
    ...     device=gNB2
    ...     protocol=E1AP

    ${IPs}    Create IP list    version=${ver}    int=${inter}    plmn=${plmn}    node=${node}
    check_ip_in_message   BearerContextModificationRequest_1  ${flow_alias}   ${IPs}

Verify ${ver:IPv4|IPv6|both} ver of ${node:MN|SN} ${inter:XN|NG}-U IP for PLMN-${plmn} in UECtxModReq for MN
    ${flow_alias}=     Get flow name
    ...     procedure=2*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${IPs}    Create IP list    version=${ver}    int=${inter}    plmn=${plmn}    node=${node}
    check_ip_in_message   UEContextModificationRequest_1  ${flow_alias}     ${IPs}

Verify ${ver:IPv4|IPv6|both} ver of ${node:MN|SN} ${inter:XN|NG}-U IP for PLMN-${plmn} in UECtxModResp for MN
    ${flow_alias}=     Get flow name
    ...     procedure=2*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${IPs}    Create IP list    version=${ver}    int=${inter}    plmn=${plmn}    node=${node}
    check_ip_in_message   UEContextModificationResponse_1  ${flow_alias}    ${IPs}

Verify ${ver:IPv4|IPv6|both} ver of ${node:MN|SN} ${inter:XN|NG}-U IP for PLMN-${plmn} in XnUAddressInd for SN
    ${flow_alias}=     Get flow name
    ...     procedure=xnUAddressIndication
    ...     device=gNB3
    ...     protocol=XNAP

    ${IPs}    Create IP list    version=${ver}    int=${inter}    plmn=${plmn}    node=${node}
    check_ip_in_message   XnUAddressIndication  ${flow_alias}    ${IPs}

Verify ${ver:IPv4|IPv6|both} ver of ${node:MN|SN} ${inter:XN|NG}-U IP for PLMN-${plmn} in BearerCtxSetResp for SN
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB3
    ...     protocol=E1AP

    ${IPs}    Create IP list    version=${ver}    int=${inter}    plmn=${plmn}    node=${node}
    check_ip_in_message  BearerContextSetupResponse  ${flow_alias}   ${IPs}    ${inter}

Verify ${ver:IPv4|IPv6|both} ver of ${node:MN|SN} ${inter:XN|NG}-U IP for PLMN-${plmn} in BearerCtxModReq for SN
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB3
    ...     protocol=E1AP

    ${IPs}    Create IP list    version=${ver}    int=${inter}    plmn=${plmn}    node=${node}
    check_ip_in_message   BearerContextModificationRequest  ${flow_alias}   ${IPs}

Verify ${ver:IPv4|IPv6|both} ver of ${node:MN|SN} ${inter:XN|NG}-U IP for PLMN-${plmn} in BearerCtxModResp for MN
    ${flow_alias}=     Get flow name
    ...     procedure=2*bearerContextModification
    ...     device=gNB2
    ...     protocol=E1AP

    ${IPs}    Create IP list    version=${ver}    int=${inter}    plmn=${plmn}    node=${node}
    check_ip_in_message   BearerContextModificationResponse_1  ${flow_alias}   ${IPs}    ${inter}

Verify ${ver:IPv4|IPv6|both} ver of ${node:MN|SN} ${inter:XN|NG}-U IP for PLMN-${plmn} in BearerCtxModReq for SN after TB
    ${flow_alias}=     Get flow name
    ...     procedure=2*bearerContextModification
    ...     device=gNB3
    ...     protocol=E1AP

    ${IPs}    Create IP list    version=${ver}    int=${inter}    plmn=${plmn}    node=${node}
    check_ip_in_message   BearerContextModificationRequest_2  ${flow_alias}   ${IPs}
