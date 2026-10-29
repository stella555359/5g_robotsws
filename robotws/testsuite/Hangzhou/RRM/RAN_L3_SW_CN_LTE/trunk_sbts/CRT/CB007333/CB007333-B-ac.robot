*** Settings ***
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs and Establish the SCTP association with en-gNB
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS    team-DevHZ5_SG4
...               owner-chendong.he    release-SRAN21B
Resource          ../../../resources/DevHZ5_resource.robot
Library           LTE4652_common.py

Documentation
...
...      INTRODUCTION:  CB007333 Automatic X2 link establishment.
...      Automates X2 link management (establishment, removal). X2 establishment triggered towards gNB, if no X2 link
...      exists already on addition of a new neighbor relation(manually, ANR mechanism). X2 removal triggered with
...      removal of last neighbor relation. Also "EN DC SON Information Exchange" procedure via S1 for
...      gNB X2 TNL address discovery. This new functionality is supported when the new feature flag for CB007333
...      is activated by the operator.
...
...      TEST SET NAME: CB007333-B-ac
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
...                     CB007333-B-af Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - LNADJGNB creation by Operator
...                                                  - cPlaneIpAddr
...                     CB007333-B-ag Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - MME CONFIGURATION TRANSFER -
...                                                    cPlaneIpAddr conflicts as a part of EN-DC SON Info Exchange
...                     CB007333-B-ah Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - EN-DC X2 SETUP RESPONSE -
...                                                    Global en-gNB ID conflict for given eNB Controlled LNADJGNB
...                     CB007333-B-ai Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - EN-DC X2 SETUP RESPONSE -
...                                                    Global en-gNB ID conflict with other LNADJGNBs
...                     CB007333-B-aj Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers
...                                                  - LNADJGNB update in persistent storage

...      CONTACTS:  Paulina Jalowiec   paulina.jalowiec@nokia.com
...
...      REFERENCES:  CB007333 CFAM
...
...      HISTORY:
...         [04.02.2021] - Created TC
...         [10.02.2021] - Approved by Chris Trocki - EFS, https://fisheye3.int.net.nokia.com/cru/ROBOTLTE-ROBOTLTE-3400
...         [xx.xx.xxxx] - Test finished
...         [xx.xx.xxxx] - Review closed

*** Variables ***
&{gnb_details}
@{PARAMS_IN_SCF}
...    @{CB007333_B_ag_3-1}

@{CB007333_B_ag_3-1}
...    LNBTS/LNADJGNB-3:administrativeState=unlocked
...    LNBTS/LNADJGNB-3:cPlaneIpAddrCtrl=enbControlled
...    LNBTS/LNADJGNB-3:plmnId:mcc=250
...    LNBTS/LNADJGNB-3:plmnId:mnc=333
...    LNBTS/LNADJGNB-3:plmnId:mncLength=3
...    LNBTS/LNADJGNB-3:adjGnbId=3
...    LNBTS/LNADJGNB-3:adjGnbIdLength=22
...    delete:LNADJGNB-3:cPlaneIpAddr

...    LNCEL-1/LNRELGNBCELL-1:nrCellId=49156
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:removeAllowed=true
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=250
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=333
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=3


...    LNCEL-1/LNRELGNBCELL-0:nrCellId=49155
...    LNCEL-1/LNRELGNBCELL-0:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-0:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-0:removeAllowed=true
...    LNCEL-1/LNRELGNBCELL-0:nrCgiPlmnId:mcc=250
...    LNCEL-1/LNRELGNBCELL-0:nrCgiPlmnId:mnc=333
...    LNCEL-1/LNRELGNBCELL-0:nrCgiPlmnId:mncLength=3

@{enable_actendcautox2setup}
...    MRBTS-1/LNBTS-1:actEndcAutoX2Setup=true

@{disable_actendcautox2setup}
...    MRBTS-1/LNBTS-1:actEndcAutoX2Setup=false

@{PARAMS_IN_VENDOR}
...    LNBTS:enbConfAggWaitTimer=90
${UTE_WIRESHARK_FLAG}    ${False}

*** Test Cases ***
CB007333-A-ac_1 Feature enabling disabling and link failure interactions
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info==
    ...   Test verifies behaviors of eNB when feature is enabling/disabling during different phase of ANR procedure for EN_DC
    ...     Test Steps:
    ...         Follow design steps
    ...
    ...  PRECONDITIONS:
    ...    actEndcAutoX2Setup=false
    ...    actAutoNRNeighRemoval=true
    ...    plmn (mcc:mnc)= 244:09
    ...    cPlane:ipV4AddressDN1=10.0.1.2
    ...    uPlane:ipV4AddressDN1=10.0.1.3
    ...    LNCELL-1 with tac=124 and defaultLnRelGnbCellId is set to 0
    ...    LNMME1 is configured and unlocked S1LinkStatus changed to available in UC1(suite setup)
    ...    Simulated gNB3is configured
    ...    LNADJGNB3 is set with: AdministrativeState=unlocked; cPlaneIpAddr=10.0.1.26;
    ...    cPlaneIpAddrCtrl=enbControlled; plmnId=250:333; adjGnbId/adjGnbIdLength=3/22
    ...    X2LinkStatus to gNB3 is unavailable

    ...  POSTCONDITIONS:
    ...
    ...  TESTING TOOLS:  CUS, EPCSIM, EMSSIM, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...    HARDWARE ID:  AHFB
    ...
    ...  REQUIREMENTS COVERAGE:
    ...    REQUIREMENTS IN SCOPE: LTE_CP_106598, LTE_CP_106599
    ...
    ...  BACKLOG ID:  FCA_4G_FT_ET-8026
    ...  REQUIRED LOGS:  X2, S1 pcap
    ...  CONTACTS:   Bartosz Maludziński   bartosz.maludzinski@nokia.com
    ...
    ...  REFERENCES:  CB007333 CFAM
    ...               CB007333-A-ac UC#1 Requesting eNB - Operator created LNADJGNB - cPlaneIpAddr eNB Controlled - Address not initialized
    ...               - actEndcAutoX2Setup initially set to false - actEndcAutoX2Setup reconfigured to true
    ...               - EN-DC SON Information Exchange - X2(gNB) Setup success
    ...               CB007333-A-ac UC#2 Requesting eNB - Operator created LNADJGNB - cPlaneIpAddr eNB Controlled  X2(gNB) link established
    ...               - actEndcAutoX2Setup reconfigured to false
    ...               CB007333-A-ac UC#5 Requesting eNB - Operator created LNADJGNB - cPlaneIpAddr eNB Controlled  X2(gNB) link established
    ...               - SCTP association failure  X2(gNB) link reestablished
    ...               CB007333-A-ac UC#6 Requesting eNB -Operator created LNADJGNB - cPlaneIpAddr eNB Controlled  X2(gNB) link established
    ...               - SCTP association failure  X2(gNB) link reestablished after EN-DC SON Information Exchange
    ...               CB007333-A-ac UC#4 Requesting eNB - Operator created LNADJGNB - cPlaneIpAddr eNB Controlled  X2(gNB) link established
    ...               - actEndcAutoX2Setup reconfigured to false  SCTP association failure  X2(gNB) link not reestablished
    ...               CB007333-A-ac UC#8 Requesting eNB - Operator created LNADJGNB - cPlaneIpAddr eNB Controlled  X2(gNB) link established
    ...               - actEndcAutoX2Setup reconfigured to false  SCTP association failure
    ...               - actEndcAutoX2Setup reconfigured back to true - X2(gNB) link reestablishment
    ...               CB007333-A-ac UC#7 Requesting eNB - Operator created LNADJGNB - cPlaneIpAddr eNB Controlled - X2(gNB) link established
    ...               - SCTP association failure - failed reestablishment attempt -actEndcAutoX2Setup reconfigured to false
    ...  HISTORY:
    ...     [25.02.2021] - Created TC
    ...     [26.02.2021] - Approved by Chris Trocki - EFS, https://fisheye3.int.net.nokia.com/cru/ROBOTLTE-3418
    ...     [xx.xx.xxxx] - Test finished
    ...     [xx.xx.xxxx] - Review closed
    [Tags]
    Perform UC1
    #UC2
    Change actEndcAutoX2Setup to false
    sleep  60
    Verify that LNADJGNB-3 x2ToGnbLinkStatus is set to available
    #UC5
    Change actEndcAutoX2Setup to true UC_5
    Trigger SCTP association failure for X2(gNB) link with en-gNB
    Verify that LNADJGNB-3 x2ToGnbLinkStatus is set to unavailable

    Establish the SCTP association with en-gNB
    Verify that EN-DC X2 link to gNB_3 was established with eNB
    Verify that eNB configured plmn in LNADJGNB-3 based on X2ENDCSetupResponse message
    Verify that eNB configured adjGnbId in LNADJGNB-3 based on X2ENDCSetupResponse message
    Verify that eNB configured adjGnbIdLength in LNADJGNB-3 based on X2ENDCSetupResponse message
    Verify that LNADJGNB-3 x2ToGnbLinkStatus is set to available
    Verify that eNB does not send the eNBConfigurationUpdate with connectedengNBToAddList en-gNB-ID=3

    #UC4
    Change actEndcAutoX2Setup to false UC_4
    Trigger SCTP association failure for X2(gNB) link with en-gNB
    sleep  150
    Verify that LNADJGNB-3 x2ToGnbLinkStatus is set to unavailable
    Verify that eNB does not send the ENDCX2SetupRequest to gNB_3
    Verify that eNB does not send the eNBConfigurationUpdate with connectedengNBToAddList en-gNB-ID=3
#
#    #UC8
    Change actEndcAutoX2Setup to true UC_8
    Establish the SCTP association with en-gNB
    Verify that eNB sends to MME_1 S1AP:ENBConfigurationUpdate with ConnectedengNBToRemovedList en-gNB-ID=3
    Verify that EN-DC X2 link to gNB_3 was established with eNB
    Verify that eNB configured plmn in LNADJGNB-3 based on X2ENDCSetupResponse message
    Verify that eNB configured adjGnbId in LNADJGNB-3 based on X2ENDCSetupResponse message
    Verify that eNB configured adjGnbIdLength in LNADJGNB-3 based on X2ENDCSetupResponse message
    Verify that LNADJGNB-3 x2ToGnbLinkStatus is set to available
    Verify that eNB sends the eNBConfigurationUpdate with connectedengNBToAddList en-gNB-ID=3

*** Keywords ***
Common Suite Setup And Setup Cus Env
    Common Suite Setup
    &{gnb_details}=   create dictionary
    ${gnb_details}=   set variable     &{gnb_details}
    Create MME device with alias 'MME_1' identified by ip=10.0.1.1
    Create flow to verify S1 link setup between MME_1 and eNB
    Setup Cus Env    tl_type=CB007333/4CELLs_FDD_4Band2
	PreConfigure In Egate
	Trigger sim_eNB to inform MME_1 about connected gNB_3
    Create Alias
    #Parameters Configuration    ${CB007333_B_ag_3-1}
    Verify that eNB sends to MME_1 S1AP:S1SetupRequest with "Connected en-gNB List" and recives Response

Common Test Teardown And Stop Capture Logs and Establish the SCTP association with en-gNB
    Establish the SCTP association with en-gNB
    Common Test Teardown And Stop Capture Logs

Create Alias
    Create Enb Alias    MeNB    enb_id=1    id_type=wts
    Create Enb Alias    SeNB    enb_id=10    id_type=wts
    Create Enb Alias    gNB_2    enb_id=2    id_type=wts
	Create Enb Alias    gNB_3    enb_id=3    id_type=wts

PreConfigure In Egate
    Execute Egate Command    gnb_param_endc id=2 include_reestablish_pdcp=on
	Execute Egate Command    gnb_param_endc id=3 include_reestablish_pdcp=on
	Execute Egate Command    mme_param id=1 s1_hb_interval=120
	Execute Egate Command    link_ctrl_param use_hb=off app_type=enb,mme,pgw,sgw,uec,daemon
	Execute Egate Command    enb_timer T_ShutdownNoX2TrafficTimer=none

Trigger sim_eNB to inform MME_1 about connected gNB_3
    Execute Egate Command    enb_x2_link_up enb=10 target=3
    sleep    10
    Execute Egate Command    enb_conf_update enb=10 mme=1 connected_en_gnb_to_add=3

Create flow to verify S1 link setup between MME_1 and eNB
     Expect Message Flow
     ...    MME_1:S1AP_S1SetupRequest as MME_1_Setup_Request
     ...    MME_1:S1AP_S1SetupResponse as MME_1_Setup_Response
     ...    alias=MME_1_s1_link_setup
     ...    overall_timeout=1000

Parameters Configuration
    [Arguments]    ${delta_params}
    Delta Commission Parameters    ${delta_params}
	Wait Until Keyword Succeeds    3min    5s    Cells Should Be OnAir

Verify that eNB sends to MME_1 S1AP:S1SetupRequest with "Connected en-gNB List" and recives Response
    Flow Occurred As Expected
    ...    MME_1_s1_link_setup

Perform UC1
    Change actEndcAutoX2Setup to true
    Verify that eNB sends to MME_1 S1AP:ENBConfigurationTransfer with "EN-DC SON Configuration Transfer" with request about gNB_3
    Verify that MME_1 sends S1AP:MMEConfigurationTransfer message with "EN-DC SON Configuration Transfer" with reply about gNB_3
    Verify that EN-DC X2 link to gNB_3 was established with eNB
    Verify that eNB configured plmn in LNADJGNB-3 based on X2ENDCSetupResponse message
    Verify that eNB configured adjGnbId in LNADJGNB-3 based on X2ENDCSetupResponse message
    Verify that eNB configured adjGnbIdLength in LNADJGNB-3 based on X2ENDCSetupResponse message
    Verify that LNADJGNB-3 x2ToGnbLinkStatus is set to available
    Verify that eNB sends the eNBConfigurationUpdate with connectedengNBToAddList en-gNB-ID=3    #todo przeniść kw z ag do common

Change actEndcAutoX2Setup to true
    Create flow to verify ENDC Config Transfer between MME_1 and eNB with EN-DC SON Config Transfer with info about gNB_3 in eNB Request
    Create flow to verify ENDC Config Transfer between MME_1 and eNB with EN-DC SON Config Transfer with info about gNB_3 in MME Reply
    Create flow to verify ENDCX2 link setup between gNB_3 and eNB
    Create flow to verify eNBConfigurationUpdate setup between MME_1 and eNB for gNB_3

    Parameters Configuration    ${enable_actendcautox2setup}

Change actEndcAutoX2Setup to false
    Parameters Configuration    ${disable_actendcautox2setup}

Create flow to verify ENDC Config Transfer between MME_${mme_id} and eNB with EN-DC SON Config Transfer with info about gNB_${gNB_id} in eNB Request
    expect message flow
    ...     MME_${mme_id}:S1AP_ENBConfigurationTransfer as ETC_request
    ...     MME_${mme_id}:S1AP_MMEConfigurationTransfer as mme_config_transfer  ##message from MME to simulated enb or in A-h from MME to real enb
    ...     alias=MME_${mme_id}_ConfigTransfer_Request_with_gNB_${gNB_id}  overall_timeout=220  #todo:lower timer after vendor file

Create flow to verify ENDC Config Transfer between MME_${mme_id} and eNB with EN-DC SON Config Transfer with info about gNB_${gNB_id} in MME Reply
    expect message flow
#    ...     MME_${mme_id}:S1AP_ENBConfigurationTransfer
#    ...     MME_${mme_id}:S1AP_MMEConfigurationTransfer  ##message from MME to simulated enb
    ...     MME_${mme_id}:S1AP_ENBConfigurationTransfer (transfertype contains (reply is present))  ##message from simulated enb to MME
    ...     MME_${mme_id}:S1AP_MMEConfigurationTransfer (transfertype contains (reply is present)) as ETC_reply
    ...     alias=MME_${mme_id}_ConfigTransfer_Reply_with_gNB_${gNB_id}  overall_timeout=220  #todo:lower timer after vendor file

Create flow to verify ENDCX2 link setup between gNB_${gNB_id} and eNB
    Expect message flow
    ...     MeNB:X2AP_ENDCX2SetupRequest as gNB_${gNB_id}_Setup_Request
    ...     MeNB:X2AP_ENDCX2SetupResponse as gNB_${gNB_id}_Setup_Response
    ...     alias=gNB_${gnb_id}_x2_link_setup    overall_timeout=300

Create flow to verify eNBConfigurationUpdate setup between MME_${mme_id} and eNB for gNB_${gNB_id}
    Expect message flow
    ...     MME_${mme_id}:S1AP_ENBConfigurationUpdate (id eq 292) as MME_${mme_id}_Configuration_Update
    ...     MME_${mme_id}:S1AP_ENBConfigurationUpdateAcknowledge as MME_${mme_id}_Configuration_Update_Acknowledge
    ...     alias=gNB_${gNB_id}_Configuration_Update_with_connectedengNBToAddList  overall_timeout=1000

Verify that eNB sends to MME_${mme_id} S1AP:ENBConfigurationTransfer with "EN-DC SON Configuration Transfer" with request about gNB_${gNB_id:\d+}
    log to console   Waiting for flow with CT_Request for gNB_${gNB_id}...\n
    Flow occurred as expected  alias=MME_${mme_id}_ConfigTransfer_Request_with_gNB_${gNB_id}
    #reply_flow=${mme}_ConfigTransfer_Reply_with_${sgnb}
    verify_correct_content_of_son_message   gnb_to_check=${gNB_id}  request_flow=MME_${mme_id}_ConfigTransfer_Request_with_gNB_${gNB_id}

Establish the SCTP association with en-gNB
    Run  sudo iptables -D INPUT -p SCTP --chunk-types any INIT -s 10.0.1.2 -d 10.0.1.26 -j DROP
    log to console  Performing X2 link up\n

Verify that MME_${mme_id} sends S1AP:MMEConfigurationTransfer message with "EN-DC SON Configuration Transfer" with reply about gNB_${gNB_id:\d+}
    log to console   Waiting for flow with CT_Reply for gNB_${gNB_id}...\n
    Flow occurred as expected  alias=MME_${mme_id}_ConfigTransfer_Reply_with_gNB_${gNB_id}
    verify_correct_content_of_son_message   gnb_to_check=${gNB_id}  request_flow=MME_${mme_id}_ConfigTransfer_Request_with_gNB_${gNB_id}
    ...    reply_flow=MME_${mme_id}_ConfigTransfer_Reply_with_gNB_${gNB_id}

Verify that EN-DC X2 link to gNB_${gNB_id} was established with eNB
    Flow occurred as expected  alias=gNB_${gnb_id}_x2_link_setup
    &{tmp}=   store_details_about_connected_gnb   gNB_${gNB_id}_x2_link_setup   gNB_${gNB_id}_Setup_Response   gNB_${gNB_id}
    set to dictionary   ${gnb_details}   &{tmp}
    Log to console  EN-DC X2 link between eNB and gNB_${gNB_id} was etablished

Verify that eNB configured plmn in LNADJGNB-${gNB_id} based on X2ENDCSetupResponse message
    verify_MOC_setting_is_aligned_with_gNB_response   param=PLMN    gnb_id=${gnb_id}  gnb_details=${gnb_details}

Verify that eNB configured adjGnbId in LNADJGNB-${gNB_id} based on X2ENDCSetupResponse message
     verify_MOC_setting_is_aligned_with_gNB_response   param=adjGnbId    gnb_id=${gnb_id}   gnb_details=${gnb_details}

Verify that eNB configured adjGnbIdLength in LNADJGNB-${gNB_id} based on X2ENDCSetupResponse message
    verify_MOC_setting_is_aligned_with_gNB_response   param=adjGnbIdLength    gnb_id=${gnb_id}   gnb_details=${gnb_details}

Verify that LNADJGNB-3 x2ToGnbLinkStatus is set to available
    @{LNADJGNB}    Create List    LNADJGNB-3:x2ToGnbLinkStatus=available
    Object Should Exist    ${LNADJGNB}

Verify that LNADJGNB-3 x2ToGnbLinkStatus is set to unavailable
    @{LNADJGNB}    Create List    LNADJGNB-3:x2ToGnbLinkStatus=unavailable
    Object Should Exist    ${LNADJGNB}

Verify that eNB sends the eNBConfigurationUpdate with connectedengNBToAddList en-gNB-ID=${gnb_id}
    flow occurred as expected   alias=gNB_${gnb_id}_Configuration_Update_with_connectedengNBToAddList
    Log to console  Recived ConfigurationUpdate with connectedengNBToAddList\n

Change actEndcAutoX2Setup to true UC_5
    Create flow to verify ENDC Config Transfer between MME_1 and eNB with EN-DC SON Config Transfer with info about gNB_3 in eNB Request
    Create flow to verify ENDC Config Transfer between MME_1 and eNB with EN-DC SON Config Transfer with info about gNB_3 in MME Reply
    Create flow to verify ENDCX2 link setup between gNB_3 and eNB
    #    Create flow to verify that eNB does not send X2AP_ENDCX2SetupRequest to gNB_3
    #    Create flow to verify eNBConfigurationUpdate setup between MME_1 and eNB for gNB_3
    Create flow to verify that eNB does not send eNBConfigurationUpdate for gNB_3
    Parameters Configuration    ${enable_actendcautox2setup}

Change actEndcAutoX2Setup to false UC_4
    Create flow to verify that eNB does not send X2AP_ENDCX2SetupRequest to gNB_3
    Create flow to verify that eNB does not send eNBConfigurationUpdate for gNB_3
    Change actEndcAutoX2Setup to false

Create flow to verify that eNB does not send eNBConfigurationUpdate for gNB_${gNB_id}
    expect message will not occur
    ...     MME_1:S1AP_ENBConfigurationUpdate as MME_1_Configuration_Update
    ...     alias=gNB_${gNB_id}does_not_send_Configuration_Update  overall_timeout=60

Trigger SCTP association failure for X2(gNB) link with en-gNB
    Run  sudo iptables -I INPUT -p SCTP --chunk-types any INIT -s 10.0.1.2 -d 10.0.1.26 -j DROP
    Execute Egate Command  x2_reset_link from=3 to=1
    log to console  Performing X2 link failure\n

Verify that eNB does not send the eNBConfigurationUpdate with connectedengNBToAddList en-gNB-ID=${gNB_id}
    flow not occurred for message  alias=gNB_${gNB_id}does_not_send_Configuration_Update

Create flow to verify that eNB does not send X2AP_ENDCX2SetupRequest to gNB_${gNB_id}
    expect message will not occur
    ...     gNB_${gnb_id}:X2AP_ENDCX2SetupRequest as gNB_${gNB_id}_Setup_Request
    ...     alias=gNB_${gnb_id}_x2_link_not_setup    overall_timeout=60

Verify that eNB does not send the ENDCX2SetupRequest to gNB_${gnb_id}
    flow not occurred for message  alias=gNB_${gnb_id}_x2_link_not_setup

Change actEndcAutoX2Setup to true UC_8
    Create flow to verify S1 link configuration update with ConnectedengNBToRemovedList between MME_1 and eNB with info about gNB_3
    Create flow to verify ENDCX2 link setup between gNB_3 and eNB
    Create flow to verify eNBConfigurationUpdate setup between MME_1 and eNB for gNB_3
    Parameters Configuration    ${enable_actendcautox2setup}

Create flow to verify S1 link configuration update with ConnectedengNBToRemovedList between MME_${mme_id} and eNB with info about gNB_${gNB_id}
     Expect message flow
    ...     MME_${mme_id}:S1AP_ENBConfigurationUpdate (id eq 293) as MME_${mme_id}_Configuration_Update
    ...     MME_${mme_id}:S1AP_ENBConfigurationUpdateAcknowledge as MME_${mme_id}_Configuration_Update_Acknowledge
    ...     alias=MME_${mme_id}_Configuration_Update_with_ConnectedengNBToRemovedList  overall_timeout=120

Verify that eNB sends to MME_${mme_id} S1AP:ENBConfigurationUpdate with ConnectedengNBToRemovedList en-gNB-ID=3
    flow occurred as expected   alias=MME_${mme_id}_Configuration_Update_with_ConnectedengNBToRemovedList
    Execute Egate Command    gnb_param id=3 x2_listening_socket=on
    Log to console  Recived ConfigurationUpdate with ConnectedengNBToRemovedList\n