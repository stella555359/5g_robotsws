*** Settings ***
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs And Prepare test environment for CB007333-SR-A-ad_1
Test Teardown     Common Test Teardown And Stop Capture Logs And Cleanup test environment for CB007333-SR-A-ad_1
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS    team-DevHZ5_SG4
...               owner-chendong.he    release-SRAN21B
Resource          ../../../resources/DevHZ5_resource.robot
Library           LTE4652_common.py
Library           ute_tshark

Documentation
...
...      INTRODUCTION:  CB007333 Automatic X2 link establishment.
...      Automates X2 link management (establishment, removal). X2 establishment triggered towards gNB, if no X2 link
...      exists already on addition of a new neighbor relation(manually, ANR mechanism). X2 removal triggered with
...      removal of last neighbor relation. Also "EN DC SON Information Exchange" procedure via S1 for
...      gNB X2 TNL address discovery. This new functionality is supported when the new feature flag for CB007333
...      is activated by the operator.
...
...      TEST SET NAME: CB007333-A-ad
...
...      TESTING SPLIT: CB007333-A-a Update of MME information - S1 Setup
...                     CB007333-A-b Update of MME information - eNB Configuration Update - X2(gNB) Addition
...                     CB007333-A-c Update of MME information - eNB Configuration Update - Feature enabling after X2(gNB) links setup
...                     CB007333-A-d Update of MME information - eNB Configuration Update - X2(gNB) Removal
...                     CB007333-A-e Update of MME information - eNB Configuration Update - Aggregation of triggers and interactions
...                     CB007333-A-f Responding eNB - Success - SON Information Request
...                     CB007333-A-g Responding eNB - Success - SON Information Reply
...                     CB007333-A-h Responding eNB - Other interactions and failures
...                     CB007333-A-i Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success - cPlaneIpAddr eNB Controlled -
...                                                   Address unconfirmed
...                     CB007333-A-j Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success - cPlaneIpAddr eNB Controlled -
...                                                   Address not initialized - EN-DC SON Information Exchange
...                     CB007333-A-k Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery
...                                                 - cPlaneIpAddr eNB Controlled -
...                                                   Address not initialized - EN-DC SON Information Exchange - Failure scenarios
...                     CB007333-A-l Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery
...                                                 - cPlaneIpAddr eNB Controlled -
...                                                   Address unconfirmed - EN-DC SON Information Exchange - SCTP association failure
...                     CB007333-A-m Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery
...                                                 - cPlaneIpAddr eNB Controlled -
...                                                   Address unconfirmed - EN-DC SON Information Exchange - EN-DC X2 Setup failure
...                     CB007333-A-n Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery
...                                                 - cPlaneIpAddr eNB Controlled -
...                                                   Address unconfirmed - EN-DC SON Information Exchange - Max no of parallel procedures
...                     CB007333-B-s Requesting eNB - ANR created LNADJGNB - X2(gNB) Setup success
...                     CB007333-B-t Requesting eNB - ANR created LNADJGNB - X2(gNB) Setup success with recovery cases
...                     CB007333-B-ac Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery -
...                                                    Feature enabling/disabling and link failure interactions
...                     CB007333-B-ad Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery
...                                                  - cPlaneIpAddr eNB Controlled -
...                                                    Address not initialized or unconfirmed - EN-DC SON Information Exchange
...                                                  - IPv4, IPv6, IPv4&IPv6 checks
...                     CB007333-B-ae Update of MME information - S1 Setup and eNB Configuration Update -
...                                                               Workaround for the lack of complete Global en-gNB ID in 3GPP S1AP definition
...                     CB007333-B-af Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers
...                                                  - LNADJGNB creation by Operator - cPlaneIpAddr
...                     CB007333-B-ag Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - MME CONFIGURATION TRANSFER -
...                                                    cPlaneIpAddr conflicts as a part of EN-DC SON Info Exchange
...                     CB007333-B-ah Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - EN-DC X2 SETUP RESPONSE -
...                                                    Global en-gNB ID conflict for given eNB Controlled LNADJGNB
...                     CB007333-B-ai Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - EN-DC X2 SETUP RESPONSE -
...                                                    Global en-gNB ID conflict with other LNADJGNBs
...                     CB007333-B-aj Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - LNADJGNB update in persistent storage

...      CONTACTS:  Paulina Jalowiec   paulina.jalowiec@nokia.com
...
...      REFERENCES:  CB007333 CFAM
...
...      HISTORY:
...         [06.05.2021] - Created TC
...         [xx.05.2021] - Approved by Chris Trocki - EFS, https://fisheye3.int.net.nokia.com/cru/ROBOTLTE-3481
...         [xx.xx.xxxx] - Test finished
...         [xx.xx.xxxx] - Review closed

*** Variables ***
#@{PARAMS_IN_SCF}
@{ip_address_gNB}=  10.0.1.200  10.0.1.201  10.0.1.202  10.0.1.203  10.0.1.204  10.0.1.205  10.0.1.206
@{ip_address_gNB_IPv6}=  -  -   2a00:8a00:4000:4101:4000:1:1:202  2a00:8a00:4000:4101:4000:1:1:203  2a00:8a00:4000:4101:4000:1:1:204
...    2a00:8a00:4000:4101:4000:1:1:205  2a00:8a00:4000:4101:4000:1:1:206
${gnb_2_mcc}=  250
${gnb_2_mnc}=  222
${gnb_2_adjGnbId}=  18
${gnb_3_mcc}=  250
${gnb_3_mnc}=  333
${gnb_3_adjGnbId}=  19
${gnb_4_mcc}=  250
${gnb_4_mnc}=  444
${gnb_4_adjGnbId}=  20
${gnb_5_mcc}=  250
${gnb_5_mnc}=  555
${gnb_5_adjGnbId}=  21
${gnb_5_mcc}=  250
${gnb_5_mnc}=  555
${gnb_5_adjGnbId}=  21
${gnb_6_mcc}=  250
${gnb_6_mnc}=  666
${gnb_6_adjGnbId}=  22

@{CB007333-A-ad}
...    LNBTS/LNADJGNB-2:administrativeState=locked
...    LNBTS/LNADJGNB-2:cPlaneIpAddrCtrl=enbControlled
...    LNBTS/LNADJGNB-2:plmnId:mcc=250
...    LNBTS/LNADJGNB-2:plmnId:mnc=222
...    LNBTS/LNADJGNB-2:plmnId:mncLength=3
...    LNBTS/LNADJGNB-2:adjGnbId=18
...    LNBTS/LNADJGNB-2:adjGnbIdLength=22
...    delete:LNBTS/LNADJGNB-2:cPlaneIpAddr

...    LNBTS/LNADJGNB-3:administrativeState=locked
...    LNBTS/LNADJGNB-3:cPlaneIpAddrCtrl=enbControlled
...    LNBTS/LNADJGNB-3:plmnId:mcc=250
...    LNBTS/LNADJGNB-3:plmnId:mnc=333
...    LNBTS/LNADJGNB-3:plmnId:mncLength=3
...    LNBTS/LNADJGNB-3:adjGnbId=19
...    LNBTS/LNADJGNB-3:adjGnbIdLength=22
...    delete:LNBTS/LNADJGNB-3:cPlaneIpAddr

...    LNBTS/LNADJGNB-4:administrativeState=locked
...    LNBTS/LNADJGNB-4:cPlaneIpAddrCtrl=enbControlled
...    LNBTS/LNADJGNB-4:plmnId:mcc=250
...    LNBTS/LNADJGNB-4:plmnId:mnc=444
...    LNBTS/LNADJGNB-4:plmnId:mncLength=3
...    LNBTS/LNADJGNB-4:adjGnbId=20
...    LNBTS/LNADJGNB-4:adjGnbIdLength=22
...    delete:LNBTS/LNADJGNB-4:cPlaneIpAddr

...    LNBTS/LNADJGNB-5:administrativeState=locked
...    LNBTS/LNADJGNB-5:cPlaneIpAddrCtrl=enbControlled
...    LNBTS/LNADJGNB-5:plmnId:mcc=250
...    LNBTS/LNADJGNB-5:plmnId:mnc=555
...    LNBTS/LNADJGNB-5:plmnId:mncLength=3
...    LNBTS/LNADJGNB-5:adjGnbId=21
...    LNBTS/LNADJGNB-5:adjGnbIdLength=22
...    delete:LNBTS/LNADJGNB-5:cPlaneIpAddr

...    LNBTS/LNADJGNB-6:administrativeState=locked
...    LNBTS/LNADJGNB-6:cPlaneIpAddrCtrl=enbControlled
...    LNBTS/LNADJGNB-6:plmnId:mcc=250
...    LNBTS/LNADJGNB-6:plmnId:mnc=666
...    LNBTS/LNADJGNB-6:plmnId:mncLength=3
...    LNBTS/LNADJGNB-6:adjGnbId=22
...    LNBTS/LNADJGNB-6:adjGnbIdLength=22
...    delete:LNBTS/LNADJGNB-6:cPlaneIpAddr

@{CB007333-A-ad_clean_up}
...    delete:LNBTS/LNADJGNB-2
...    delete:LNBTS/LNADJGNB-3
...    delete:LNBTS/LNADJGNB-4
...    delete:LNBTS/LNADJGNB-5
...    delete:LNBTS/LNADJGNB-6

${UTE_WIRESHARK_FLAG}    ${False}

*** Test Cases ***
CB007333-SR-A-ad_1 EN-DC SON Information Exchange IPv4, IPv6, IPv4&IPv6 checks - X2 ENDC links set up with IPv4 and IPv6
    [Documentation]
    ...  DESCRIPTION:
    ...  This test case verifies how eNB handles various combinations of IP transport address of gNB (IPv4, IPv6, IPv4&IPv6),
    ...  retrieved via EN-DC SON Information Exchange. ENB is configured with dual stack IPv4&IPv6 for X2 and S1.
    ...
    ...  PRECONDITIONS:
    ...  FEATLADM.actDualStackIpV4V6ForS1X2 = true
    ...  LNBTS.actEndcAutoX2Setup = true
    ...  LNBTS.enbConfAggWaitTimer = 60s
    ...  TRSNW.cPlane.ipV4AddressDN1 = MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ...  TRSNW.cPlane.ipV4AddressDN2 = MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2
    ...  TRSNW.cPlane.ipV6AddressDN1 = MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
    ...  TRSNW.cPlane.ipV6AddressDN2 = MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2
    ...  TRSNW.uPlane.ipV4AddressDN1 = MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3
    ...  TRSNW.uPlane.ipV6AddressDN1 = MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3
    ...  MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1.localIpAddr = 10.0.1.2
    ...  MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2.localIpAddr = 10.0.1.3
    ...  MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3.localIpAddr = 10.0.1.4
    ...  MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1.localIpAddr = 2a00:8a00:4000:4101:4000:1:1:2
    ...  MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2.localIpAddr = 2a00:8a00:4000:4101:4000:1:1:3
    ...  MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3.localIpAddr = 2a00:8a00:4000:4101:4000:1:1:4
    ...  LNCEL-1.tac = 124
    ...
    ...    LNADJGNB-2
    ...                     adjGnbId.LNADJGNB-2  18
    ...               adjGnbIdLength.LNADJGNB-2  22
    ...          administrativeState.LNADJGNB-2  locked
    ...                 cPlaneIpAddr.LNADJGNB-2  *parameter is not initialized
    ...             cPlaneIpAddrCtrl.LNADJGNB-2  enbControlled
    ...                       plmnId.LNADJGNB-2  TABLE
    ...                                          [0]: mcc  250
    ...                                          [0]: mnc  222
    ...                                          [0]: mncLength  3
    ...            x2ToGnbLinkStatus.LNADJGNB-2  unavailable
    ...
    ...    LNADJGNB-3
    ...                     adjGnbId.LNADJGNB-3  19
    ...               adjGnbIdLength.LNADJGNB-3  22
    ...          administrativeState.LNADJGNB-3  locked
    ...                 cPlaneIpAddr.LNADJGNB-3  *parameter is not initialized
    ...             cPlaneIpAddrCtrl.LNADJGNB-3  enbControlled
    ...                       plmnId.LNADJGNB-3  TABLE
    ...                                          [0]: mcc  250
    ...                                          [0]: mnc  333
    ...                                          [0]: mncLength  3
    ...            x2ToGnbLinkStatus.LNADJGNB-3  unavailable
    ...
    ...    LNADJGNB-4
    ...                     adjGnbId.LNADJGNB-4  20
    ...               adjGnbIdLength.LNADJGNB-4  22
    ...          administrativeState.LNADJGNB-4  locked
    ...                 cPlaneIpAddr.LNADJGNB-4  *parameter is not initialized
    ...             cPlaneIpAddrCtrl.LNADJGNB-4  enbControlled
    ...                       plmnId.LNADJGNB-4  TABLE
    ...                                          [0]: mcc  250
    ...                                          [0]: mnc  444
    ...                                          [0]: mncLength  3
    ...            x2ToGnbLinkStatus.LNADJGNB-4  unavailable
    ...
    ...    gNB_2 (simulated) is configured with:
    ...    - gNB ID: 18
    ...    - PLMN: 250:222
    ...    - TAC: 2
    ...    - CPlane IPv4 address: 10.0.1.202
    ...
    ...    gNB_3 (simulated) is configured with:
    ...    - gNB ID: 19
    ...    - PLMN: 250:333
    ...    - TAC: 3
    ...    - CPlane IPv6 address: 2a00:8a00:4000:4101:4000:1:1:203
    ...
    ...    gNB_4 (simulated) is configured with:
    ...    - gNB ID: 20
    ...    - PLMN: 250:444
    ...    - TAC: 4
    ...    - CPlane IPv4 address: 10.0.1.204
    ...    - CPlane IPv6 address: 2a00:8a00:4000:4101:4000:1:1:204
    ...
    ...  TEST SCENARIO:
    ...    LNADJGNB-2.administrativeState is changed to "unlocked".
    ...    eNB_1 sends S1AP:ENBConfigurationTransfer message with EN-DC SON Configuration Transfer to MME-1 filled with:
    ...      - sourceeNB contains:
    ...        * globaleNBID with macroENB-ID and pLMNidentity fields set to values corresponding to eNB_1
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to eNB_1
    ...      - targetengNB contains
    ...        * globalengNBID with en-gNB-ID and pLMNidentity fields set to values corresponding to gNB_2
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to eNB_1 (inconsistency in 3GPP
    ...        - description vs ASN.1 encoding, selectedTAI cannot be omitted)
    ...      - x2TNLConfigInfo contains:
    ...        * eNBX2TransportLayerAddresses which constains:
    ...          * 1st TransportLayerAddress with eNB_1 IPADDRESSV4-1 and IPADDRESSV6-1
    ...          * 2nd TransportLayerAddress with eNB_1 IPADDRESSV4-2 and IPADDRESSV6-2
    ...        * gTPTLAa field set to eNB_1 IPADDRESSV4-3 and IPADDRESSV6-3
    ...    MME-1 replies with S1AP:MMEConfigurationTransfer message with EN-DC SON Configuration Transfer filled with:
    ...      - transfertype field is set to "reply"
    ...      - sourceengNB contains:
    ...        * globalengNBID with en-gNB-ID and pLMNidentity fields set to values corresponding to gNB_2
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to gNB_2
    ...      - targeteNB contains
    ...        * globaleNBID with macroENB-ID and pLMNidentity fields set to values corresponding to eNB_1
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to eNB_1
    ...      - sONInformationReply contains x2TNLConfigurationInfo with
    ...          * eNBX2TransportLayerAddresses which constains:
    ...            *1st TransportLayerAddress with gNB_2 IPv4 address
    ...    eNB_1 establishes SCTP connection with gNB_2 using IPv4 address
    ...    eNB_1 sends X2AP:ENDCX2SetupRequest message to gNB_2
    ...    eNB_1 receives X2AP:ENDCX2SetupResponse message with GlobalGNB-ID matching LNADJGNB-2 data
    ...    eNB_1 starts timer enbConfAggWaitTimer
    ...      - Verify that following LNADJGNB-2 parameters are set without change:
    ...        * nrCgiPlmnId.mcc = 250
    ...        * nrCgiPlmnId.mnc = 222
    ...        * nrCgiPlmnId.mncLength = 3
    ...        * adjGnbId = 18
    ...        * adjGnbIdLength = 22
    ...      - Verify that following LNADJGNB-2 parameters are updated:
    ...        * x2ToGnbLinkStatus = available
    ...        * cPlaneIpAddr = 10.0.1.202
    ...    enbConfAggWaitTimer timer expires
    ...    eNB_1 sends S1AP:ENBConfigurationUpdate message to MME-1 filled with:
    ...      - ConnectedengNBList contains:
    ...        * en-gNB-ID field set to gNB_2 ID
    ...        * broadcastedPLMNs field set to gNB_2 PLMN
    ...
    ...    LNADJGNB-3.administrativeState is changed to "unlocked".
    ...    eNB_1 sends S1AP:ENBConfigurationTransfer message with EN-DC SON Configuration Transfer to MME-1 filled with:
    ...      - sourceeNB contains:
    ...        * globaleNBID with macroENB-ID and pLMNidentity fields set to values corresponding to eNB_1
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to eNB_1
    ...      - targetengNB contains
    ...        * globalengNBID with en-gNB-ID and pLMNidentity fields set to values corresponding to gNB_3
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to eNB_1 (inconsistency in 3GPP
    ...        - description vs ASN.1 encoding, selectedTAI cannot be omitted)
    ...      - x2TNLConfigInfo contains:
    ...        * eNBX2TransportLayerAddresses which constains:
    ...          * 1st TransportLayerAddress with eNB_1 IPADDRESSV4-1 and IPADDRESSV6-1
    ...          * 2nd TransportLayerAddress with eNB_1 IPADDRESSV4-2 and IPADDRESSV6-2
    ...        * gTPTLAa field set to eNB_1 IPADDRESSV4-3 and IPADDRESSV6-3
    ...    MME-1 replies with S1AP:MMEConfigurationTransfer message with EN-DC SON Configuration Transfer filled with:
    ...      - transfertype field is set to "reply"
    ...      - sourceengNB contains:
    ...        * globalengNBID with en-gNB-ID and pLMNidentity fields set to values corresponding to gNB_3
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to gNB_3
    ...      - targeteNB contains
    ...        * globaleNBID with macroENB-ID and pLMNidentity fields set to values corresponding to eNB_1
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to eNB_1
    ...      - sONInformationReply contains x2TNLConfigurationInfo with
    ...          * eNBX2TransportLayerAddresses which constains:
    ...            *1st TransportLayerAddress with gNB_3 IPv6 address
    ...    eNB_1 establishes SCTP connection with gNB_3 using IPv6 address
    ...    eNB_1 sends X2AP:ENDCX2SetupRequest message to gNB_3
    ...    eNB_1 receives X2AP:ENDCX2SetupResponse message with GlobalGNB-ID matching LNADJGNB-3 data
    ...    eNB_1 starts timer enbConfAggWaitTimer
    ...      - Verify that following LNADJGNB-3 parameters are set without change:
    ...        * nrCgiPlmnId.mcc = 250
    ...        * nrCgiPlmnId.mnc = 333
    ...        * nrCgiPlmnId.mncLength = 3
    ...        * adjGnbId = 19
    ...        * adjGnbIdLength = 22
    ...      - Verify that following LNADJGNB-3 parameters are updated:
    ...        * x2ToGnbLinkStatus = available
    ...        * cPlaneIpAddr = 2a00:8a00:4000:4101:4000:1:1:203
    ...    enbConfAggWaitTimer timer expires
    ...    eNB_1 sends S1AP:ENBConfigurationUpdate message to MME-1 filled with:
    ...      - ConnectedengNBList contains:
    ...        * en-gNB-ID field set to gNB_3 ID
    ...        * broadcastedPLMNs field set to gNB_3 PLMN
    ...
    ...    LNADJGNB-4.administrativeState is changed to "unlocked".
    ...    eNB_1 sends S1AP:ENBConfigurationTransfer message with EN-DC SON Configuration Transfer to MME-1 filled with:
    ...      - sourceeNB contains:
    ...        * globaleNBID with macroENB-ID and pLMNidentity fields set to values corresponding to eNB_1
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to eNB_1
    ...      - targetengNB contains
    ...        * globalengNBID with en-gNB-ID and pLMNidentity fields set to values corresponding to gNB_4
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to eNB_1 (inconsistency in 3GPP
    ...        - description vs ASN.1 encoding, selectedTAI cannot be omitted)
    ...      - x2TNLConfigInfo contains:
    ...        * eNBX2TransportLayerAddresses which constains:
    ...          * 1st TransportLayerAddress with eNB_1 IPADDRESSV4-1 and IPADDRESSV6-1
    ...          * 2nd TransportLayerAddress with eNB_1 IPADDRESSV4-2 and IPADDRESSV6-2
    ...        * gTPTLAa field set to eNB_1 IPADDRESSV4-3 and IPADDRESSV6-3
    ...    MME-1 replies with S1AP:MMEConfigurationTransfer message with EN-DC SON Configuration Transfer filled with:
    ...      - transfertype field is set to "reply"
    ...      - sourceengNB contains:
    ...        * globalengNBID with en-gNB-ID and pLMNidentity fields set to values corresponding to gNB_4
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to gNB_4
    ...      - targeteNB contains
    ...        * globaleNBID with macroENB-ID and pLMNidentity fields set to values corresponding to eNB_1
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to eNB_1
    ...      - sONInformationReply contains x2TNLConfigurationInfo with
    ...          * eNBX2TransportLayerAddresses which constains:
    ...            *1st TransportLayerAddress with gNB_4 IPv4 and IPv6 addresses
    ...    eNB_1 establishes SCTP connection with gNB_4 using IPv6 address
    ...    eNB_1 sends X2AP:ENDCX2SetupRequest message to gNB_4
    ...    eNB_1 receives X2AP:ENDCX2SetupResponse message with GlobalGNB-ID matching LNADJGNB-4 data
    ...    eNB_1 starts timer enbConfAggWaitTimer
    ...      - Verify that following LNADJGNB-4 parameters are set without change:
    ...        * nrCgiPlmnId.mcc = 250
    ...        * nrCgiPlmnId.mnc = 444
    ...        * nrCgiPlmnId.mncLength = 3
    ...        * adjGnbId = 20
    ...        * adjGnbIdLength = 22
    ...      - Verify that following LNADJGNB-4 parameters are updated:
    ...        * x2ToGnbLinkStatus = available
    ...        * cPlaneIpAddr = 2a00:8a00:4000:4101:4000:1:1:204
    ...    enbConfAggWaitTimer timer expires
    ...    eNB_1 sends S1AP:ENBConfigurationUpdate message to MME-1 filled with:
    ...      - ConnectedengNBList contains:
    ...        * en-gNB-ID field set to gNB_4 ID
    ...        * broadcastedPLMNs field set to gNB_4 PLMN
    ...
    ...  POSTCONDITIONS:
    ...    X2(gNB) links towards gNB_2, gNB_3, gNB_4 have been successfuly established and MME-1 has been notified about that
    ...
    ...  TESTING TOOLS:  CUS, EPCSIM, EMSSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...    HARDWARE ID:  AREA
    ...
    ...  REQUIREMENTS COVERAGE:
    ...    REQUIREMENTS IN SCOPE:  LTE_CP_107718
    ...
    ...  BACKLOG ID:  FCA_4G_FT_ET-8210
    ...  REQUIRED LOGS:  X2, S1 pcap
    ...  CONTACTS:  Paulina Jalowiec   paulina.jalowiec@nokia.com
    ...
    ...  REFERENCES:  CB007333 CFAM
    ...               CB007333-2178  CB007333-A-ad UC#3 Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery
    ...                              - cPlaneIpAddr eNB Controlled - Address not initialized or unconfirmed
    ...                              - EN-DC SON Information Exchange - IPv4, IPv6, IPv4&IPv6 checks - X2(gNB) links set up with IPv4 and IPv6
    ...
    ...  HISTORY:
    ...     [06.05.2021] - Created TC
    ...     [xx.05.2021] - Approved by Chris Trocki - EFS, https://fisheye3.int.net.nokia.com/cru/ROBOTLTE-3481
    ...     [xx.xx.xxxx] - Test finished
    ...     [xx.xx.xxxx] - Review closed
    [Tags]
    Set observers for SON Procedure and ENDC X2 Setup, unlock LNADJGNB-2 object
    Verify eNB with IPv4/IPv6 sends to MME_1 S1AP:ENBConfigTransfer with "EN-DC SON Configuration Transfer" with request about gNB_2
    Verify MME_1 sends S1AP:MMEConfigTransfer message with "EN-DC SON Config Transfer" with reply about gNB_2 (to dualstack enb)
    Verify that S1AP:MMEConfigurationTransfer conatins "eNB X2 Transport Layer Addresses" equal to IPv4 address of gNB_2
    Verify that eNB establishes SCTP connection with gNB_2 using IPv4 address
    Verify that EN-DC X2 link to gNB_2 was established with eNB
    Verify in LNADJGNB-2 cPlaneIpAddr is updated with gNB_2 IPv4 x2ToGnbLinkStatus is set to available global gNBID are not changed
    Verify that eNB sends to MME_1 S1AP:ENBConfigurationUpdate with "Connected en-gNB To Be Added List" with gNB_2

    Set observers for SON Procedure and ENDC X2 Setup, unlock LNADJGNB-3 object
    Verify eNB with IPv4/IPv6 sends to MME_1 S1AP:ENBConfigTransfer with "EN-DC SON Configuration Transfer" with request about gNB_3
    Verify MME_1 sends S1AP:MMEConfigTransfer message with "EN-DC SON Config Transfer" with reply about gNB_3 (to dualstack enb)
    Verify that S1AP:MMEConfigurationTransfer conatins "eNB X2 Transport Layer Addresses" equal to IPv6 address of gNB_3
    Verify that eNB establishes SCTP connection with gNB_3 using IPv6 address
    Verify that EN-DC X2 link to gNB_3 was established with eNB
    Verify in LNADJGNB-3 cPlaneIpAddr is updated with gNB_3 IPv6 x2ToGnbLinkStatus is set to available global gNBID are not changed
    Verify that eNB sends to MME_1 S1AP:ENBConfigurationUpdate with "Connected en-gNB To Be Added List" with gNB_3

    Set observers for SON Procedure and ENDC X2 Setup, unlock LNADJGNB-4 object
    Verify eNB with IPv4/IPv6 sends to MME_1 S1AP:ENBConfigTransfer with "EN-DC SON Configuration Transfer" with request about gNB_4
    Verify MME_1 sends S1AP:MMEConfigTransfer msg with "EN-DC SON Config Transfer" with reply about gNB_4 (to dualstack enb with gNB)
    Verify that S1AP:MMEConfigurationTransfer conatins "eNB X2 Transport Layer Addresses" equal to IPv4 and IPv6 addresses of gNB_4
    Verify that eNB establishes SCTP connection with gNB_4 using IPv6 address
    Verify that EN-DC X2 link to gNB_4 was established with eNB
    Verify in LNADJGNB-4 cPlaneIpAddr is updated with gNB_4 IPv6 x2ToGnbLinkStatus is set to available global gNBID are not changed
    Verify that eNB sends to MME_1 S1AP:ENBConfigurationUpdate with "Connected en-gNB To Be Added List" with gNB_4

*** Keywords ***
Common Suite Setup And Setup Cus Env
    Common Suite Setup
    Setup Cus Env    tl_type=CB007333/3CELLs_FDD_2Band3_Band7_ipv6
    Create Alias
    Config IP
    PreConfigure In Egate

Create Alias
    Create Enb Alias    MeNB    enb_id=1    id_type=wts
    Create Enb Alias    SeNB    enb_id=10    id_type=wts
    Create Enb Alias    gNB_2    enb_id=2    id_type=wts
	Create Enb Alias    gNB_3    enb_id=3    id_type=wts
	Create Enb Alias    gNB_4    enb_id=4    id_type=wts
	Create Enb Alias    gNB_5    enb_id=5    id_type=wts
	Create Enb Alias    gNB_6    enb_id=6    id_type=wts
	Create Ue Alias     UE_1    ue_id=1    id_type=rtg
	Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create MME Alias    MME_2    mme_id=2    id_type=wts

PreConfigure In Egate
    Execute Egate Command    set_param SEC_OP_KEY=01020304050607080910111213141516
    Execute Egate Command    gnb_param_endc id=2 include_reestablish_pdcp=on
    Execute Egate Command    gnb_param_endc id=3 include_reestablish_pdcp=on
    Execute Egate Command    gnb_param_endc id=4 include_reestablish_pdcp=on
    Execute Egate Command    gnb_param_endc id=5 include_reestablish_pdcp=on
    #Execute Egate Command    link_ctrl_param use_hb=off app_type=enb,mme,pgw,sgw,uec,daemon
    Execute Egate Command    enb_timer T_ShutdownNoX2TrafficTimer=none
    Execute Egate Command    enb_x2_link_up enb=10 target=2
    Execute Egate Command    enb_x2_link_up enb=11 target=3
    Execute Egate Command    enb_x2_link_up enb=11 target=4
    Execute Egate Command    enb_x2_link_up enb=10 target=5
    Execute Egate Command    enb_x2_link_up enb=10 target=6
    sleep    10
    Execute Egate Command    enb_conf_update enb=10 mme=1 connected_en_gnb_to_add=2
    Execute Egate Command    enb_conf_update enb=11 mme=1 connected_en_gnb_to_add=3
    Execute Egate Command    enb_conf_update enb=11 mme=1 connected_en_gnb_to_add=4
    Execute Egate Command    enb_conf_update enb=10 mme=1 connected_en_gnb_to_add=5
    Execute Egate Command    enb_conf_update enb=10 mme=1 connected_en_gnb_to_add=6

config IP
    Execute Cmd On Pc    sudo ip a a dev eth3 10.0.1.99/24
    Execute Cmd On Pc    sudo ip -6 addr add 2a00:8a00:4000:4101:4000::21/64 dev eth3
    Execute Cmd On Pc    sudo ip a a dev eth3 10.0.1.101/24
    Execute Cmd On Pc    sudo ip a a dev eth3 10.0.1.202/24
    Execute Cmd On Pc    sudo ip a a dev eth3 10.0.1.203/24
    Execute Cmd On Pc    sudo ip a a dev eth3 10.0.1.204/24
    Execute Cmd On Pc    sudo ip a a dev eth3 10.0.1.205/24
    Execute Cmd On Pc    sudo ip a a dev eth3 10.0.1.206/24
    Execute Cmd On Pc    sudo ip -6 addr add 2a00:8a00:4000:4101:4000:1:1:202/64 dev eth3
    Execute Cmd On Pc    sudo ip -6 addr add 2a00:8a00:4000:4101:4000:1:1:203/64 dev eth3
    Execute Cmd On Pc    sudo ip -6 addr add 2a00:8a00:4000:4101:4000:1:1:204/64 dev eth3
    Execute Cmd On Pc    sudo ip -6 addr add 2a00:8a00:4000:4101:4000:1:1:205/64 dev eth3
    Execute Cmd On Pc    sudo ip -6 addr add 2a00:8a00:4000:4101:4000:1:1:206/64 dev eth3
    Execute Cmd On Pc    sudo ip a a dev eth3 10.0.1.21/24
    Execute Cmd On Pc    sudo ip a a dev eth3 10.0.1.22/24
    Execute Cmd On Pc    sudo ip -6 addr add 2a00:8a00:4000:4101:4000::22/64 dev eth3

Common Test Setup And Start To Capture Logs And Prepare test environment for CB007333-SR-A-ad_1
    Common Test Setup And Start To Capture Logs
    Prepare test environment for CB007333-SR-A-ad_1

Prepare test environment for CB007333-SR-A-ad_1
    &{gnb_details}=   create dictionary
    set test variable   ${gnb_details}   &{gnb_details}
    Parameters Configuration    ${CB007333-A-ad}
    Execute Egate Command    gnb_endc_param id=4 replace_gnb_ip_addr_son_conf_transfer_reply=10.0.1.204/2a00:8a00:4000:4101:4000:1:1:204

Parameters Configuration
    [Arguments]    ${delta_params}
    Delta Commission Parameters    ${delta_params}
	Wait Until Keyword Succeeds    3min    5s    Cells Should Be OnAir

Cleanup test environment for CB007333-SR-A-ad_1
    Parameters Configuration  ${CB007333-A-ad_clean_up}
    Execute Egate Command    gnb_endc_param id=4 replace_gnb_ip_addr_son_conf_transfer_reply=2a00:8a00:4000:4101:4000:1:1:204
    ute_tshark.teardown_all_aliases_for_tshark

Common Test Teardown And Stop Capture Logs And Cleanup test environment for CB007333-SR-A-ad_1
    Cleanup test environment for CB007333-SR-A-ad_1
    Common Test Teardown And Stop Capture Logs

Set observers for SON Procedure and ENDC X2 Setup, unlock LNADJGNB-${gnb_id} object
    Create flow to verify ENDC Config Transfer between MME_1 and eNB with EN-DC SON Config Transfer with info about gNB_${gnb_id} in eNB Request
    Create flow to verify ENDC Config Transfer between MME_1 and eNB with EN-DC SON Config Transfer with info about gNB_${gnb_id} in MME Reply
    Create flow to verify ENDCX2 link setup between gNB_${gnb_id} and eNB
    Create flow to verify S1 link configuration update between MME_1 and eNB with info about gNB_${gnb_id}
    Prepare SCTP monitoring on X2 for gNB_${gnb_id}
    log to console   Unlocking LNADJGNB-${gnb_id}...
    Parameters Configuration    LNADJGNB-${gnb_id}:administrativeState=unlocked

Create flow to verify ENDC Config Transfer between MME_${mme_id} and eNB with EN-DC SON Config Transfer with info about gNB_${gNB_id} in MME Reply
    expect message flow
#    ...     MME_${mme_id}:S1AP_ENBConfigurationTransfer
#    ...     MME_${mme_id}:S1AP_MMEConfigurationTransfer  ##message from MME to simulated enb
    ...     MME_${mme_id}:S1AP_ENBConfigurationTransfer (transfertype contains (reply is present))  ##message from simulated enb to MME
    ...     MME_${mme_id}:S1AP_MMEConfigurationTransfer (transfertype contains (reply is present)) as ETC_reply
    ...     alias=MME_${mme_id}_ConfigTransfer_Reply_with_gNB_${gNB_id}  overall_timeout=220  #todo:lower timer after vendor file

Create flow to verify ENDC Config Transfer between MME_${mme_id} and eNB with EN-DC SON Config Transfer with info about gNB_${gNB_id} in eNB Request
    expect message flow
    ...     MME_${mme_id}:S1AP_ENBConfigurationTransfer as ETC_request
    ...     MME_${mme_id}:S1AP_MMEConfigurationTransfer as mme_config_transfer  ##message from MME to simulated enb or in A-h from MME to real enb
    ...     alias=MME_${mme_id}_ConfigTransfer_Request_with_gNB_${gNB_id}  overall_timeout=220  #todo:lower timer after vendor file

Create flow to verify ENDCX2 link setup between gNB_${gNB_id} and eNB
    Expect message flow
    ...     gNB_${gnb_id}:X2AP_ENDCX2SetupRequest as gNB_${gNB_id}_Setup_Request
    ...     gNB_${gnb_id}:X2AP_ENDCX2SetupResponse as gNB_${gNB_id}_Setup_Response
    ...     alias=gNB_${gnb_id}_x2_link_setup    overall_timeout=200

Create flow to verify S1 link configuration update between MME_${mme_id} and eNB with info about gNB_${gNB_id:.*\d+}
    Expect message flow
    ...     MME_${mme_id}:S1AP_ENBConfigurationUpdate as MME_${mme_id}_Configuration_Update
    ...     MME_${mme_id}:S1AP_ENBConfigurationUpdateAcknowledge as MME_${mme_id}_Configuration_Update_Acknowledge
    ...     alias=MME_${mme_id}_Configuration_Update_with_gNB_${gNB_id}   overall_timeout=200

Prepare SCTP monitoring on X2 for gNB_${gnb_id}
    log to console    Prepare SCTP monitoring on X2 for gNB_${gnb_id}
    Start To Capture Eth3 Wireshark Log    gnb_id=${gnb_id}

Start To Capture Eth3 Wireshark Log
    [Arguments]    ${file_name}=x2_interface    ${gnb_id}=3
    Setup tshark  interface=eth3    alias=CB007333_gtp_all_eNB_${gnb_id}    log_dir=${SAVE LOG DIRECTORY}    log_name=${file_name}.pcap
    Start capturing   alias=CB007333_gtp_all_eNB_${gnb_id}    capture_filter=less 1000

Verify that eNB sends to MME_${mme_id} S1AP:ENBConfigurationTransfer with "EN-DC SON Configuration Transfer" with request about gNB_${gNB_id:\d+}
    log to console   Waiting for flow with CT_Request for gNB_${gNB_id}...\n
    Flow occurred as expected  alias=MME_${mme_id}_ConfigTransfer_Request_with_gNB_${gNB_id}
    #reply_flow=${mme}_ConfigTransfer_Reply_with_${sgnb}
    verify_correct_content_of_son_message   gnb_to_check=${gNB_id}  request_flow=MME_${mme_id}_ConfigTransfer_Request_with_gNB_${gNB_id}


Verify that S1AP:MMEConfigurationTransfer conatins "eNB X2 Transport Layer Addresses" equal to IPv4 address of gNB_${gnb_id}
    verify_gnbx2transportaddress_in_son_message_with_lnadjgnb   gnb_to_check=None  reply_flow=MME_1_ConfigTransfer_Reply_with_gNB_${gnb_id}
    ...     ip_address=@{ip_address_gNB}[${gnb_id}]

Verify that eNB establishes SCTP connection with gNB_2 using IPv4 address
    [Arguments]    ${file_name}=x2_interface
    Stop To Capture Eth3 Wireshark Log    gnb_id=2
    ${msg_number}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/${file_name}.pcap
    ...    (sctp.chunk_type == 1) && (ip.dst == 10.0.1.202)
    Should Be True    ${msg_number}>=1

Verify that eNB establishes SCTP connection with gNB_3 using IPv6 address
    [Arguments]    ${file_name}=x2_interface
    Stop To Capture Eth3 Wireshark Log    gnb_id=3
    ${msg_number}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/${file_name}.pcap
    ...    (sctp.chunk_type == 1) && (ipv6.dst == 2a00:8a00:4000:4101:4000:1:1:203)
    Should Be True    ${msg_number}>=1

Verify that eNB establishes SCTP connection with gNB_4 using IPv6 address
    [Arguments]    ${file_name}=x2_interface
    Stop To Capture Eth3 Wireshark Log    gnb_id=4
    ${msg_number}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/${file_name}.pcap
    ...    (sctp.chunk_type == 1) && (ipv6.dst == 2a00:8a00:4000:4101:4000:1:1:204)
    Should Be True    ${msg_number}>=1

Stop To Capture Eth3 Wireshark Log
    [Arguments]    ${file_name}=x2_interface    ${gnb_id}=3
    sleep    5
    ute_tshark.stop_capturing   alias=CB007333_gtp_all_eNB_${gnb_id}
    ute_tshark.teardown_tshark   alias=CB007333_gtp_all_eNB_${gnb_id}

Verify that eNB generates SHUTDOWN_COMPLETE to gNB_3
    [Arguments]    ${file_name}=x2_interface
    ${shutdown_complete_msg_number}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/${file_name}.pcap
    ...    (sctp.chunk_type == 14) && (ip.dst == 10.0.1.203)
    Should Be True    ${shutdown_complete_msg_number}>=1

Verify that EN-DC X2 link to gNB_${gNB_id} was established with eNB
    Flow occurred as expected  alias=gNB_${gnb_id}_x2_link_setup
    &{tmp}=   store_details_about_connected_gnb   gNB_${gNB_id}_x2_link_setup   gNB_${gNB_id}_Setup_Response   gNB_${gNB_id}
    set to dictionary   ${gnb_details}   &{tmp}
    Log to console  EN-DC X2 link between eNB and gNB_${gNB_id} was etablished

Verify in LNADJGNB-${gnb_id} cPlaneIpAddr is updated with gNB_${gnb_id} IPv4 x2ToGnbLinkStatus is set to available global gNBID are not changed
    Verify that plmnId/gNBId of LNADJGNB-${gnb_id} is not changed, x2ToGnbLinkStatus is available
    Verify that LNADJGNB-${gnb_id} cPlaneIpAddr is set to @{ip_address_gNB}[${${gnb_id}}]

Verify in LNADJGNB-${gnb_id} cPlaneIpAddr is updated with gNB_${gnb_id} IPv6 x2ToGnbLinkStatus is set to available global gNBID are not changed
    Verify that plmnId/gNBId of LNADJGNB-${gnb_id} is not changed, x2ToGnbLinkStatus is available
    Verify that LNADJGNB-${gnb_id} cPlaneIpAddr is set to @{ip_address_gNB_IPv6}[${${gnb_id}}]

Verify that plmnId/gNBId of LNADJGNB-${id} is not changed, x2ToGnbLinkStatus is available
    @{LNADJGNB}    Create List
    ...    LNADJGNB-${id}:administrativeState=unlocked
    ...    LNADJGNB-${id}:x2ToGnbLinkStatus=available
    ...    LNADJGNB-${id}:adjGnbId=${gNB_${id}_adjGnbId}
    ...    LNADJGNB-${id}:plmnId:mcc=${gNB_${id}_mcc}
    ...    LNADJGNB-${id}:plmnId:mnc=${gNB_${id}_mnc}
    ...    LNADJGNB-${id}:plmnId:mncLength=3
    ...    LNADJGNB-${id}:adjGnbIdLength=22
    Object Should Exist    ${LNADJGNB}

Verify that ${object:\S+} ${param:\S+} is set to ${value:\S+}
    Object Should Exist    ${object}:${param}=${value}
    log to console  ${object}:${param}=${value}\n

Verify that eNB sends to MME_${mme_id} S1AP:ENBConfigurationUpdate with "Connected en-gNB To Be Added List" with ${gnb_list:gNB.*}
    ${alias_suffix}=  prepare_alias_suffix   ${gNB_list}
    flow occurred as expected   alias=MME_${mme_id}_Configuration_Update_with_${alias_suffix}
    verify_correct_content_of_s1_message   MME_${mme_id}_Configuration_Update_with_${alias_suffix}
    ...    MME_${mme_id}_Configuration_Update   ${gNB_list}   ${gnb_details}   id-ConnectedengNBToAddList

Verify eNB with IPv4/IPv6 sends to MME_${mme_id} S1AP:ENBConfigTransfer with "EN-DC SON Configuration Transfer" with request about gNB_${gNB_id}
    log to console   Waiting for flow with CT_Request for gNB_${gNB_id}...\n
    Flow occurred as expected  alias=MME_${mme_id}_ConfigTransfer_Request_with_gNB_${gNB_id}
    verify_correct_content_of_son_message   gnb_to_check=${gNB_id}
    ...    request_flow=MME_${mme_id}_ConfigTransfer_Request_with_gNB_${gNB_id}  enb_dual_stack=True

Verify MME_${mme_id} sends S1AP:MMEConfigTransfer message with "EN-DC SON Config Transfer" with reply about gNB_${gNB_id} (to dualstack enb)
    log to console   Waiting for flow with CT_Reply for gNB_${gNB_id}...\n
    Flow occurred as expected  alias=MME_${mme_id}_ConfigTransfer_Reply_with_gNB_${gNB_id}
    verify_correct_content_of_son_message   gnb_to_check=${gNB_id}  request_flow=MME_${mme_id}_ConfigTransfer_Request_with_gNB_${gNB_id}
    ...   reply_flow=MME_${mme_id}_ConfigTransfer_Reply_with_gNB_${gNB_id}  enb_dual_stack=True

Verify that S1AP:MMEConfigurationTransfer conatins "eNB X2 Transport Layer Addresses" equal to IPv6 address of gNB_${gnb_id}
    verify_gnbx2transportaddress_in_son_message_with_lnadjgnb   gnb_to_check=None  reply_flow=MME_1_ConfigTransfer_Reply_with_gNB_${gnb_id}
    ...    ip_address=@{ip_address_gNB_IPv6}[${gnb_id}]

Verify that S1AP:MMEConfigurationTransfer conatins "eNB X2 Transport Layer Addresses" equal to IPv4 and IPv6 addresses of gNB_${gnb_id}
    verify_gnbx2transportaddress_in_son_message_with_lnadjgnb   gnb_to_check=None  reply_flow=MME_1_ConfigTransfer_Reply_with_gNB_${gnb_id}
    ...     ip_address=@{ip_address_gNB}[${gnb_id}]  ip_address_v6=@{ip_address_gNB_IPv6}[${gnb_id}]

Verify MME_${mme_id} sends S1AP:MMEConfigTransfer msg with "EN-DC SON Config Transfer" with reply about gNB_${gNB_id} (to dualstack enb with gNB)
    log to console   Waiting for flow with CT_Reply for gNB_${gNB_id}...\n
    Flow occurred as expected  alias=MME_${mme_id}_ConfigTransfer_Reply_with_gNB_${gNB_id}
    verify_correct_content_of_son_message   gnb_to_check=${gNB_id}  request_flow=MME_${mme_id}_ConfigTransfer_Request_with_gNB_${gNB_id}
    ...   reply_flow=MME_${mme_id}_ConfigTransfer_Reply_with_gNB_${gNB_id}
    ...   enb_dual_stack=True  replaced_cplane_ip=2a00:8a00:4000:4101:4000:1:1:20${gNB_id},10.0.1.20${gNB_id}

Verify that MME_${mme_id} sends S1AP:MMEConfigurationTransfer message with "EN-DC SON Configuration Transfer" with reply about gNB_${gNB_id:\d+}
    log to console   Waiting for flow with CT_Reply for gNB_${gNB_id}...\n
    Flow occurred as expected  alias=MME_${mme_id}_ConfigTransfer_Reply_with_gNB_${gNB_id}
    verify_correct_content_of_son_message   gnb_to_check=${gNB_id}
    ...    request_flow=MME_${mme_id}_ConfigTransfer_Request_with_gNB_${gNB_id}
    ...    reply_flow=MME_${mme_id}_ConfigTransfer_Reply_with_gNB_${gNB_id}
