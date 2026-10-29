*** Settings ***
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
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
...      TEST SET NAME: CB007333-A-z
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
...                     CB007333-A-z Additional Operator triggered scenarios - cPlaneIpAddr O&M Controlled changed to eNB Controlled
...                                                 - X2 (gNB) link not available
...                     CB007333-A-aa Additional Operator triggered scenarios - cPlaneIpAddr eNB Controlled changed to O&M Controlled
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
...
...
...     Common preconditions for test suite CB007333-A-z-4_5:
...
...                 LNBTS.actEndcAutoX2Setup = true
...                 LNBTS.enbConfAggWaitTimer = 60s
...                 LNBTS.ANR.actAutoNrNeighRemoval = True
...                 TRSNW.cPlane.ipV4AddressDN1 = MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...                 TRSNW.uPlane.ipV4AddressDN1 = MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2
...                 MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1.localIpAddr = 10.0.1.2
...                 MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2.localIpAddr = 10.0.1.10
...
...                 LNMME-1
...                     administrativeState  unlocked
...                     s1LinkStatus  available
...
...                 LNCELL-1
...                         tac  124
...                         defaultLnRelGnbCellId  0
...
...                 LNADJGNB-2
...                                     adjGnbId.LNADJGNB-2  18
...                               adjGnbIdLength.LNADJGNB-2  22
...                          administrativeState.LNADJGNB-2  locked
...                                 cPlaneIpAddr.LNADJGNB-2  NOT INITIALIZED
...                             cPlaneIpAddrCtrl.LNADJGNB-2  enbControlled
...                                       plmnId.LNADJGNB-2  TABLE
...                                                          [0]: mcc  250
...                                                          [0]: mnc  222
...                                                          [0]: mncLength  3
...                            x2ToGnbLinkStatus.LNADJGNB-2  unavailable
...
...
...                 LNRELGNBCELL-1-1
...                             gnbIdLength.LNRELGNBCELL-1-1  22
...                 lteNrDualConnectAllowed.LNRELGNBCELL-1-1  allowed
...                                nrCellId.LNRELGNBCELL-1-1  294913
...                             nrCgiPlmnId.LNRELGNBCELL-1-1  TABLE
...                                                           [0]: mcc  250
...                                                           [0]: mnc  222
...                                                           [0]: mncLength  3
...                           removeAllowed.LNRELGNBCELL-1-1  true
...
...
...                 LNRELGNBCELL-1-2
...                             gnbIdLength.LNRELGNBCELL-1-2  22
...                 lteNrDualConnectAllowed.LNRELGNBCELL-1-2  allowed
...                                nrCellId.LNRELGNBCELL-1-2  294914
...                             nrCgiPlmnId.LNRELGNBCELL-1-2  TABLE
...                                                           [0]: mcc  250
...                                                           [0]: mnc  222
...                                                           [0]: mncLength  3
...                           removeAllowed.LNRELGNBCELL-1-2  true
...
...
...                 gNB_3 (simulated) is configured with:
...                 - gNB ID: 18
...                 - PLMN: 250:222
...                 - TAC: 2
...                 - CPlane IPv4 address: 10.0.1.203
...
...      CONTACTS:  Malgorzata Konior   malgorzata.konior@nokia.com
...
...      REFERENCES:  CB007333 CFAM
...
...      HISTORY:
...         [23.06.2021] - Created TC
...         [02.07.2021] - Approved by Chris Trocki - EFS, https://fisheye3.int.net.nokia.com/cru/ROBOTLTE-3511
...         [02.07.2021] - Test finished
...         [02.07.2021] - Review closed

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/LNBTS-1:actEndcAutoX2Setup=true
...    LNBTS-1:actX2gNB128=false
...    LNCEL-1:defaultLnRelGnbCellId=0
...    LNCEL-1/LNRELGNBCELL-0:nrCellId=294913
...    LNCEL-1/LNRELGNBCELL-0:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-0:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-0:removeAllowed=true
...    LNCEL-1/LNRELGNBCELL-0:nrCgiPlmnId:mcc=250
...    LNCEL-1/LNRELGNBCELL-0:nrCgiPlmnId:mnc=555
...    LNCEL-1/LNRELGNBCELL-0:nrCgiPlmnId:mncLength=3

@{delta_A-z_4}
...    LNBTS/ANR-0:actAutoNrNeighRemoval=true
...    LNBTS/LNADJGNB-2:administrativeState=locked
...    LNBTS/LNADJGNB-2:cPlaneIpAddrCtrl=enbControlled
...    LNBTS/LNADJGNB-2:plmnId:mcc=250
...    LNBTS/LNADJGNB-2:plmnId:mnc=222
...    LNBTS/LNADJGNB-2:plmnId:mncLength=3
...    LNBTS/LNADJGNB-2:adjGnbId=18
...    LNBTS/LNADJGNB-2:adjGnbIdLength=22
...    delete:LNADJGNB-2:cPlaneIpAddr

...    LNCEL-1/LNRELGNBCELL-1:nrCellId=294913
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:removeAllowed=true
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=250
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=222
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=3

...    LNCEL-1/LNRELGNBCELL-2:nrCellId=294914
...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:removeAllowed=true
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=250
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=222
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=3

...    LNCEL-1:defaultLnRelGnbCellId=1

@{delta_A-z_4_1}
...    LNBTS/LNADJGNB-2:administrativeState=unlocked

@{delta_A-z_4_2}
...    LNBTS/LNADJGNB-3:administrativeState=unlocked
...    LNBTS/LNADJGNB-3:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJGNB-3:cPlaneIpAddr=10.0.1.203
...    LNBTS/LNADJGNB-3:plmnId:mcc=250
...    LNBTS/LNADJGNB-3:plmnId:mnc=333
...    LNBTS/LNADJGNB-3:plmnId:mncLength=3
...    LNBTS/LNADJGNB-3:adjGnbId=19
...    LNBTS/LNADJGNB-3:adjGnbIdLength=22

@{delta_A-z_4_3}
...    LNBTS/LNADJGNB-3:cPlaneIpAddrCtrl=enbControlled

@{PARAMS_IN_SWCONFIG}    0x12011E=2100    ##x2SetupRspTmr
${UTE_WIRESHARK_FLAG}    ${False}

*** Test Cases ***
CB007333-SR-A-z_4 cPlaneIpAddrCtrl change from oamControlled to enbControlled during cPlaneIpAddr conflict resolution in EN-DC X2 Setup phase
    [Documentation]
    ...  DESCRIPTION:
    ...  Test verifies that X2(gNB) link with gNB can be established for another eNB Controlled LNADJGNB object if operator changes
    ...  cPlaneIpAddrCtrl from oamControlled to enbControlled during cPlaneIpAddr conflict resolution in EN-DC X2 Setup phase.
    ...
    ...  PRECONDITIONS:
    ...     Common preconditions for test suite CB007333-A-z-4_5
    ...
    ...  TEST SCENARIO:
    ...    LNADJGNB-2.administrativeState is changed to "unlocked"
    ...    eNB sends S1AP:ENBConfigurationTransfer message with EN-DC SON Configuration Transfer to MME-1 filled with:
    ...      - transfertype field is set to "request"
    ...      - sourceeNB contains:
    ...        * globaleNBID with macroENB-ID and pLMNidentity fields set to values corresponding to eNB
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to eNB
    ...      - targetengNB contains
    ...        * globalengNBID with en-gNB-ID and pLMNidentity fields set to values corresponding to gNB_3
    ...      - x2TNLConfigInfo contains:
    ...        * eNBX2TransportLayerAddresses field set to eNB-1 TRSNW-1.cPlane IP address
    ...          * gTPTLAa field set to eNB-1 TRSNW-1.uPlane IP address
    ...    eNB starts the timer endcSONINFOWaitTimer related to LNADJGNB-2
    ...    MME-1 replies with S1AP:MMEConfigurationTransfer message with EN-DC SON Configuration Transfer filled with:
    ...      - transfertype field is set to "reply"
    ...      - sourceengNB contains:
    ...        * globalengNBID with en-gNB-ID and pLMNidentity fields set to values corresponding to LNADJGNB-2
    ...      - targeteNB contains
    ...        * globaleNBID with macroENB-ID and pLMNidentity fields set to values corresponding to eNB
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to eNB
    ...      - sONInformationReply contains x2TNLConfigurationInfo with
    ...          * eNBX2TransportLayerAddresses field set to gNB_3 IP address: 10.0.1.203
    ...    eNB stops the timer endcSONINFOWaitTimer related to LNADJGNB-2
    ...    eNB starts the timer t_TotalX2gNB related to LNADJGNB-2
    ...    eNB establishes SCTP association with gNB_3 using IP address 10.0.1.203 received in S1AP:MMEConfigurationTransfer message
    ...    eNB sends X2AP:ENDCX2SetupRequest message to gNB_3
    ...    eNB starts x2SetupRspTmr timer related to LNADJGNB-2
    ...    Operator creates LNADJGNB-3 with the following settings:
    ...                                     adjGnbId.LNADJGNB-3  19
    ...                               adjGnbIdLength.LNADJGNB-3  22
    ...                          administrativeState.LNADJGNB-3  unlocked
    ...                                 cPlaneIpAddr.LNADJGNB-3  10.0.1.203
    ...                             cPlaneIpAddrCtrl.LNADJGNB-3  oamControlled
    ...                                       plmnId.LNADJGNB-3  TABLE
    ...                                                          [0]: mcc  250
    ...                                                          [0]: mnc  333
    ...                                                          [0]: mncLength  3
    ...
    ...    eNB recognizes conflict on cPlaneIpAddr and starts the t_TotalX2gNB timer related to LNADJGNB-3 as a first step of
    ...    IP confict resolution
    ...    LNADJGNB-3.cPlaneIpAddrCtrl is changed to "enbControlled"
    ...    eNB continues resolution of cPlaneIpAddr conflict by cancelling t_TotalX2gNB and starting ConflictResolutionTimer related to LNADJGNB-3
    ...    eNB receives from gNB_3 X2AP:ENDCX2SetupResponse message with following data:
    ...        * "PLMN Identity" of the "Global en-gNB ID" IE matching LNADJGNB-2.plmnId
    ...        * "en-gNB ID" of the "Global en-gNB ID" IE matching LNADJGNB-2.adjGnbId/adjGnbIdLength
    ...        * "List of Served NR Cells" contains "Served NR Cell Information" IEs corresponding to LNRELGNBCELL-1-1 and LNRELGNBCELL-1-2 objects
    ...    eNB cancels x2SetupRspTmr timer related to LNADJGNB-2
    ...    eNB continues with resolution of cPlaneIpAddr conflict as follows:
    ...      - eNB sends to gNB_3 the X2AP: ERROR INDICATION message with "Cause" IE set to "Protocol: Message not Compatible with Receiver State"
    ...      - enb removes the SCTP association with gNB_3
    ...    t_TotalX2gNB timer related to LNADJGNB-2 expires
    ...    eNB continues with resolution of cPlaneIpAddr conflict as follows:
    ...      - LNADJGNB-2 is removed
    ...      - LNRELGNBCELL-1-2 is removed
    ...    ConflictResolutionTimer related to LNADJGNB-3 expires
    ...    eNB starts the timer t_TotalX2gNB related to LNADJGNB-3
    ...    eNB establishes SCTP association with gNB_3
    ...    eNB sends X2AP:ENDCX2SetupRequest message to gNB_3 and starts the timer x2SetupRspTmr
    ...    eNB starts the timer x2SetupRspTmr related to LNADJGNB-3
    ...    eNB receives from gNB_3 X2AP:ENDCX2SetupResponse message with following data:
    ...        * "PLMN Identity" of the "Global en-gNB ID" IE matching plmnId.LNADJGNB-2
    ...        * "en-gNB ID" of the "Global en-gNB ID" IE matching adjGnbId/adjGnbIdLength.LNADJGNB-2
    ...        * "List of Served NR Cells" contains "Served NR Cell Information" IEs corresponding to LNRELGNBCELL-1-1 and LNRELGNBCELL-1-2 objects
    ...    eNB cancels the timer x2SetupRspTmr related to LNADJGNB-3
    ...    eNB recognizes reception of a different Global en-gNB ID than associated with the LNADJGNB-3 instance:
    ...      - eNB sends to gNB_3 the X2AP: ERROR INDICATION message with "Cause" IE set to "Protocol: Message not Compatible with Receiver State"
    ...      - enb removes the SCTP association with gNB_3
    ...    t_TotalX2gNB timer related to LNADJGNB-3 expires
    ...    eNB sends S1AP:ENBConfigurationTransfer message with EN-DC SON Configuration Transfer to MME-1 filled with:
    ...      - transfertype field is set to "request"
    ...      - sourceeNB contains:
    ...        * globaleNBID with macroENB-ID and pLMNidentity fields set to values corresponding to eNB
    ...        * selectedTAI with tAC and pLMNidentity fields set to values corresponding to eNB
    ...      - targetengNB contains
    ...        * globalengNBID with en-gNB-ID and pLMNidentity fields set to values corresponding to LNADJGNB-3
    ...      - x2TNLConfigInfo contains:
    ...        * eNBX2TransportLayerAddresses field set to eNB-1 TRSNW-1.cPlane IP address
    ...          * gTPTLAa field set to eNB-1 TRSNW-1.uPlane IP address
    ...
    ...  POSTCONDITIONS:
    ...    LNADJGNB-2 and LNRELGNBCELL-1-2 have been removed
    ...
    ...  TESTING TOOLS:  CUS, EPCSIM, EMSSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...    HARDWARE ID:  AREA
    ...
    ...  REQUIREMENTS COVERAGE:
    ...    REQUIREMENTS IN SCOPE: LTE_CP_110797
    ...
    ...  BACKLOG ID: FCA_4G_FT_ET-8500
    ...  REQUIRED LOGS:  X2, S1 pcap
    ...  CONTACTS:  Malgorzata Konior   malgorzata.konior@nokia.com
    ...
    ...  REFERENCES:  CB007333 CFAM
    ...               CB007333-3011  CB007333-A-z UC #4 Additional Operator triggered scenarios -
    ...                              - cPlaneIpAddr O&M Controlled changed to eNB Controlled during cPlaneIpAddr conflict resolution -
    ...                              - X2(gNB) link established for another eNB Controlled LNADJGNB
    ...
    ...  HISTORY:
    ...     [23.06.2021] - Created TC
    ...     [02.07.2021] - Approved by Chris Trocki - EFS, https://fisheye3.int.net.nokia.com/cru/ROBOTLTE-3511
    ...     [02.07.2021] - Test finished
    ...     [02.07.2021] - Review closed
    [Tags]
    Prepare test environment for CB007333-SR-A-z_4
	Change LNADJGNB-2 administrativeState to unlocked
	Verify that eNB sends to MME_1 S1AP:ENBConfigurationTransfer with "EN-DC SON Configuration Transfer" with request about LNADJGNB-2 data
    Verify that MME_1 sends S1AP:MMEConfigurationTransfer message with "EN-DC SON Configuration Transfer" with reply about LNADJGNB-2 data
    Verify that eNB sends X2AP:ENDCX2SetupRequest to gNB_3
    Create oamControlled LNADJGNB-3 object
    Change LNADJGNB-3 cPlaneIpAddrCtrl to enbControlled
    Verify that gNB_3 sends ENDCX2SetupResponse with "en-gNB ID" and "PLMN Identity" matching LNADJGNB-2
	Verify that eNB sends to gNB_3 the X2AP: ERROR INDICATION message with "Cause" IE set to "Protocol: Message not Compatible with Receiver State"
    Verify that SCTP association with gNB_3 is removed
    Wait until t_TotalX2gNB timer related to LNADJGNB-2 expires
	Verify that LNADJGNB-2 is removed
	Verify that LNRELGNBCELL-1-2 is removed
	eNB reestablishes SCTP association with gNB_3
	Verify that eNB sends X2AP:ENDCX2SetupRequest to gNB_3
    Verify that gNB_3 sends ENDCX2SetupResponse with "en-gNB ID" and "PLMN Identity" matching LNADJGNB-2
    Verify that eNB sends to gNB_3 the X2AP: ERROR INDICATION message with "Cause" IE set to "Protocol: Message not Compatible with Receiver State"
    Verify that SCTP association with gNB_3 is removed    file_name=x2_interface_1
    Wait until t_TotalX2gNB timer related to LNADJGNB-3 expires
    Verify that eNB sends to MME_1 S1AP:ENBConfigurationTransfer with "EN-DC SON Configuration Transfer" with request about LNADJGNB-3 data

*** Keywords ***
Common Suite Setup And Setup Cus Env
    Common Suite Setup
    Setup Cus Env    tl_type=CB007333/3CELLs_FDD_2Band3_Band7
	PreConfigure In Egate
    Create Alias

Create Alias
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    MeNB    enb_id=1    id_type=wts
    Create Enb Alias    SeNB    enb_id=10    id_type=wts
    Create Enb Alias    gNB_2    enb_id=2    id_type=wts
	Create Enb Alias    gNB_3    enb_id=3    id_type=wts

PreConfigure In Egate
    Execute Egate Command    gnb_endc_param enable_dl_data_forwarding=1 enable_ul_data_forwarding=1 use_nr_ran_cont=true id=2
    Execute Egate Command    gnb_endc_param scg_dl_dist_percent=50 id=2
    Execute Egate Command    gnb_cell_param gnb=2 id=21 active_eq_plmn=all gnb_plmn_pos=1
    Execute Egate Command    gnb_cell_param gnb=2 id=22 active_eq_plmn=all gnb_plmn_pos=1
    Execute Egate Command    gnb_cell_param gnb=2 id=23 active_eq_plmn=all gnb_plmn_pos=1
    Execute Egate Command    gnb_param_endc id=2 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param enable_dl_data_forwarding=1 enable_ul_data_forwarding=1 use_nr_ran_cont=true id=3
    Execute Egate Command    gnb_endc_param scg_dl_dist_percent=50 id=3
    Execute Egate Command    gnb_endc_param enable_dl_data_forwarding=1 enable_ul_data_forwarding=1 use_nr_ran_cont=true id=4
    Execute Egate Command    gnb_endc_param scg_dl_dist_percent=50 id=4
    Execute Egate Command    gnb_endc_param enable_dl_data_forwarding=1 enable_ul_data_forwarding=1 use_nr_ran_cont=true id=5
    Execute Egate Command    gnb_endc_param scg_dl_dist_percent=50 id=5
    Execute Egate Command    gnb_cell_param gnb=3 id=31 active_eq_plmn=all gnb_plmn_pos=6
    Execute Egate Command    gnb_cell_param gnb=3 id=32 active_eq_plmn=all gnb_plmn_pos=4
    Execute Egate Command    gnb_cell_param gnb=3 id=33 active_eq_plmn=all gnb_plmn_pos=2
    Execute Egate Command    gnb_cell_param gnb=4 id=41 active_eq_plmn=all x2_setup_rsp_broadcasted_plmns_replace_prim_plmn=244:111
    Execute Egate Command    gnb_cell_param gnb=4 id=42 active_eq_plmn=all x2_setup_rsp_broadcasted_plmns_replace_prim_plmn=244:111
    Execute Egate Command    gnb_cell_param gnb=4 id=43 active_eq_plmn=all x2_setup_rsp_broadcasted_plmns_replace_prim_plmn=244:777
    Execute Egate Command    gnb_param_endc id=3 include_reestablish_pdcp=on
    Execute Egate Command    gnb_param_endc id=4 include_reestablish_pdcp=on
    Execute Egate Command    gnb_param_endc id=5 include_reestablish_pdcp=on
    Execute Egate Command    mme_param id=1 s1_hb_interval=120
    Execute Egate Command    mme_param id=2 s1_hb_interval=120
    Execute Egate Command    mme_param id=3 s1_hb_interval=120
    Execute Egate Command    link_ctrl_param use_hb=off app_type=enb,mme,pgw,sgw,uec,daemon
    Execute Egate Command    enb_timer T_ShutdownNoX2TrafficTimer=none

Prepare test environment for CB007333-SR-A-z_4
    &{gnb_details}=   create dictionary
    set test variable   ${gnb_details}   &{gnb_details}
    Parameters Configuration    ${delta_A-z_4}
    Trigger sim_eNB to inform MME_1 about connected gNB_2
	Trigger sim_eNB to inform MME_1 about connected gNB_3
	Set gNB_2 to send IP address of gNB_3 during SON Transfer Reply to sim_eNB
	Delay 209s X2SetupResponse from gNB_3 to eNB-1
	Set gNB_3 to send gNB_ID of gNB_2 in ENDCX2SetupResponse
	Prepare SCTP monitoring on X2 for gNB_3
	Create flow to verify ENDC Configuration Transfer between MME_1 and eNB with EN-DC SON Config Transfer with info about gNB_2 in eNB Request
	Create flow to verify ENDC Configuration Transfer between MME_1 and eNB with EN-DC SON Config Transfer with info about gNB_2 in MME Reply
	Expect Message Flow
	...    gNB_3:X2AP_ENDCX2SetupRequest as gNB_3_Setup_Request
	...    alias=gNB_3_x2_link_setup_request
	...    overall_timeout=200
	Expect Message Flow
	...    gNB_3:X2AP_ENDCX2SetupResponse as gNB_3_Setup_Response
	...    alias=gNB_3_x2_link_setup_response
	...    overall_timeout=400
	
Parameters Configuration
    [Arguments]    ${delta_params}
    Delta Commission Parameters    ${delta_params}
	Wait Until Keyword Succeeds    3min    5s    Cells Should Be OnAir

Trigger sim_eNB to inform MME_1 about connected gNB_2
	Execute Egate Command    enb_x2_link_up enb=10 target=2
    sleep    10
    Execute Egate Command    enb_conf_update enb=10 mme=1 connected_en_gnb_to_add=2

Trigger sim_eNB to inform MME_1 about connected gNB_3
	Execute Egate Command    enb_x2_link_up enb=10 target=3
    sleep    10
    Execute Egate Command    enb_conf_update enb=10 mme=1 connected_en_gnb_to_add=3

Set gNB_2 to send IP address of gNB_3 during SON Transfer Reply to sim_eNB
    Execute Egate Command    gnb_endc_param id=2 replace_gnb_ip_addr_son_conf_transfer_reply=10.0.1.203

Delay 209s X2SetupResponse from gNB_3 to eNB-1
    Execute Egate Command    x2_link_abnormal_management_cases id=3 partner=1 x2_setup_rsp=delay x2_setup_delay=209s

Set gNB_3 to send gNB_ID of gNB_2 in ENDCX2SetupResponse
    Execute Egate Command    gnb_endc_param id=3 replace_global_id_x2_setup_response=0x12|250:222
	
Prepare SCTP monitoring on X2 for gNB_3
    log to console    Prepare SCTP monitoring on X2 for gNB_3
    Start To Capture Eth3 Wireshark Log

Create flow to verify ENDC Configuration Transfer between MME_1 and eNB with EN-DC SON Config Transfer with info about gNB_2 in eNB Request
    Expect Message Flow    
	...    MME_1:S1AP_ENBConfigurationTransfer as ETC_request
	...    MME_1:S1AP_MMEConfigurationTransfer as mme_config_transfer
	...    alias=MME_1_ConfigTransfer_Request_with_gNB_2
	...    overall_timeout=220
	
Create flow to verify ENDC Configuration Transfer between MME_1 and eNB with EN-DC SON Config Transfer with info about gNB_2 in MME Reply
    Expect Message Flow    
	...    MME_1:S1AP_ENBConfigurationTransfer (transfertype contains (reply is present))
	...    MME_1:S1AP_MMEConfigurationTransfer (transfertype contains (reply is present)) as ETC_reply
	...    alias=MME_1_ConfigTransfer_Reply_with_gNB_2
	...    overall_timeout=220

Change LNADJGNB-2 administrativeState to unlocked
    Parameters Configuration    ${delta_A-z_4_1}
	
Verify that eNB sends to MME_1 S1AP:ENBConfigurationTransfer with "EN-DC SON Configuration Transfer" with request about LNADJGNB-2 data
    Log To Console    Waiting for flow with CT_Request for gNB_2...\n
	Flow Occurred As Expected
	...    alias=MME_1_ConfigTransfer_Request_with_gNB_2
	Verify Correct Content Of Son Message
	...    gnb_to_check=2
	...    request_flow=MME_1_ConfigTransfer_Request_with_gNB_2

Verify that MME_1 sends S1AP:MMEConfigurationTransfer message with "EN-DC SON Configuration Transfer" with reply about LNADJGNB-2 data	
    Log To Console    'Waiting for flow with CT_Reply for gNB_2...\n
	Flow Occurred As Expected
	...    alias=MME_1_ConfigTransfer_Reply_with_gNB_2
	Verify Correct Content Of Son Message
	...    gnb_to_check=2
	...    request_flow=MME_1_ConfigTransfer_Request_with_gNB_2
	...    reply_flow=MME_1_ConfigTransfer_Reply_with_gNB_2
	
Verify that eNB sends X2AP:ENDCX2SetupRequest to gNB_3
    Flow Occurred As Expected
    ...    	alias=gNB_3_x2_link_setup_request
	
Create oamControlled LNADJGNB-3 object
    Parameters Configuration    ${delta_A-z_4_2}	
	Expect Message Flow
	...    gNB_3:X2AP_ErrorIndication (protocol eq 'message-not-compatible-with-receiver-state')
	...    alias=ErrorIndication
	...    overall_timeout=500
	Create flow to verify S1 link configuration update between MME_1 and eNB with info about gNB_3

Create flow to verify S1 link configuration update between MME_1 and eNB with info about gNB_3
    Expect Message Flow
	...    MME_1:S1AP_ENBConfigurationUpdate as MME_1_Configuration_Update
	...    MME_1:S1AP_ENBConfigurationUpdateAcknowledge as MME_1_Configuration_Update_Acknowledge
	...    alias=MME_1_Configuration_Update_with_gNB_3
	...    overall_timeout=200
	
Change LNADJGNB-3 cPlaneIpAddrCtrl to enbControlled	
	Parameters Configuration    ${delta_A-z_4_3}
	
Verify that gNB_3 sends ENDCX2SetupResponse with "en-gNB ID" and "PLMN Identity" matching LNADJGNB-2
    Flow Occurred As Expected
	...    alias=gNB_3_x2_link_setup_response
	Verify That Message Has Field Set To Value
	...    flow_alias=gNB_3_x2_link_setup_response
	...    message_alias=gNB_3_Setup_Response
	...    field_name=pLMN-Identity
	...    value=0x522022
	Verify That Message Has Field Set To Value
	...    flow_alias=gNB_3_x2_link_setup_response
	...    message_alias=gNB_3_Setup_Response
	...    field_name=gNB-ID
	...    value=0b0000000000000000010010
	&{tmp}=    LTE4652_common.Store Details About Connected Gnb
	...    gNB_3_x2_link_setup_response
	...    gNB_3_Setup_Response
	...    gNB_3
	Set To Dictionary    ${gnb_details}    &{tmp}
	
Verify that eNB sends to gNB_3 the X2AP: ERROR INDICATION message with "Cause" IE set to "Protocol: Message not Compatible with Receiver State"
    Flow Occurred As Expected
	...    alias=ErrorIndication

Wait until t_TotalX2gNB timer related to LNADJGNB-2 expires
    sleep    250
	
Verify that LNADJGNB-2 is removed
    Object Should not Exist    LNBTS-1/LNADJGNB-2:plmnId:mncLength=3
	
Verify that LNRELGNBCELL-1-2 is removed	
	Object Should not Exist    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
	
eNB reestablishes SCTP association with gNB_3
    Remove delay ENDCSetupResponse with gNB-3 data to eNB
    Start To Capture Eth3 Wireshark Log    file_name=x2_interface_1
    Expect Message Flow
    ...    gNB_3:X2AP_ENDCX2SetupRequest as gNB_3_Setup_Request
    ...    alias=gNB_3_x2_link_setup_request
    ...    overall_timeout=400
    Expect Message Flow
    ...    gNB_3:X2AP_ENDCX2SetupResponse as gNB_3_Setup_Response
    ...    alias=gNB_3_x2_link_setup_response
    ...    overall_timeout=400
    Expect Message Flow
    ...    gNB_3:X2AP_ErrorIndication (protocol eq 'message-not-compatible-with-receiver-state')
    ...    alias=ErrorIndication
    ...    overall_timeout=400

Remove delay ENDCSetupResponse with gNB-3 data to eNB
    Execute Egate Command    x2_link_abnormal_management_cases id=3 partner=1 x2_setup_rsp=normal_rsp

Verify that SCTP association with gNB_3 is removed
    [Arguments]    ${file_name}=x2_interface
    Stop To Capture Eth3 Wireshark Log    file_name=${file_name}
    Verify that eNB generates SHUTDOWN to gNB_3    file_name=${file_name}
    Verify that gNB_3 generates SHUTDOWN_ACK to eNB    file_name=${file_name}
    Verify that eNB generates SHUTDOWN_COMPLETE to gNB_3    file_name=${file_name}

Verify that eNB generates SHUTDOWN to gNB_3
    [Arguments]    ${file_name}=x2_interface
    ${shutdown_msg_number}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/${file_name}.pcap
    ...    (sctp.chunk_type == 7) && (ip.dst == 10.0.1.203)
    Should Be True    ${shutdown_msg_number}>=1

Verify that gNB_3 generates SHUTDOWN_ACK to eNB
    [Arguments]    ${file_name}=x2_interface
    ${shutdown_ack_msg_number}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/${file_name}.pcap
    ...    (sctp.chunk_type == 8) && (ip.dst == 10.0.1.2)
    Should Be True    ${shutdown_ack_msg_number}>=1

Verify that eNB generates SHUTDOWN_COMPLETE to gNB_3
    [Arguments]    ${file_name}=x2_interface
    ${shutdown_complete_msg_number}    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}/${file_name}.pcap
    ...    (sctp.chunk_type == 14) && (ip.dst == 10.0.1.203)
    Should Be True    ${shutdown_complete_msg_number}>=1

Wait until t_TotalX2gNB timer related to LNADJGNB-3 expires
    Set gNB_3 to send gNB_ID of gNB_3 in ENDCX2SetupResponse
    Expect Message Flow
    ...    MME_1:S1AP_ENBConfigurationTransfer as ETC_request
    ...    alias=MME_1_ConfigTransfer_Request_with_gNB_3
    ...    overall_timeout=500

Set gNB_3 to send gNB_ID of gNB_3 in ENDCX2SetupResponse
    Execute Egate Command    gnb_endc_param id=3 replace_global_id_x2_setup_response=0x13|250:333

Verify that eNB sends to MME_1 S1AP:ENBConfigurationTransfer with "EN-DC SON Configuration Transfer" with request about LNADJGNB-3 data
    log to console    Waiting for flow with CT_Request for gNB_3...\n
    Flow Occurred As Expected
    ...    alias=MME_1_ConfigTransfer_Request_with_gNB_3
    Verify Correct Content Of Son Message
    ...    gnb_to_check=3
    ...    request_flow=MME_1_ConfigTransfer_Request_with_gNB_3

Start To Capture Eth3 Wireshark Log
    [Arguments]    ${file_name}=x2_interface
    Setup tshark  interface=eth3    alias=CB007333_gtp_all_eNB_3    log_dir=${SAVE LOG DIRECTORY}    log_name=${file_name}.pcap
    Start capturing   alias=CB007333_gtp_all_eNB_3    capture_filter=less 1000

Stop To Capture Eth3 Wireshark Log
    [Arguments]    ${file_name}=x2_interface
    sleep    5
    ute_tshark.stop_capturing   alias=CB007333_gtp_all_eNB_3
    ute_tshark.teardown_tshark   alias=CB007333_gtp_all_eNB_3
