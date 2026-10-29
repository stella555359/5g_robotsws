*** Settings ***
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
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
...      TEST SET NAME: CB007333-B-ae
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
...                     CB007333-A-k Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery -
...                                                   cPlaneIpAddr eNB Controlled -
...                                                   Address not initialized - EN-DC SON Information Exchange - Failure scenarios
...                     CB007333-A-l Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery -
...                                                   cPlaneIpAddr eNB Controlled -
...                                                   Address unconfirmed - EN-DC SON Information Exchange - SCTP association failure
...                     CB007333-A-m Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery -
...                                                   cPlaneIpAddr eNB Controlled -
...                                                   Address unconfirmed - EN-DC SON Information Exchange - EN-DC X2 Setup failure
...                     CB007333-A-n Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery -
...                                                   cPlaneIpAddr eNB Controlled -
...                                                   Address unconfirmed - EN-DC SON Information Exchange - Max no of parallel procedures
...                     CB007333-B-s Requesting eNB - ANR created LNADJGNB - X2(gNB) Setup success
...                     CB007333-B-t Requesting eNB - ANR created LNADJGNB - X2(gNB) Setup success with recovery cases
...                     CB007333-B-ac Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery -
...                                                    Feature enabling/disabling and link failure interactions
...                     CB007333-B-ad Requesting eNB - Operator created LNADJGNB - X2(gNB) Setup success with recovery -
...                                                    cPlaneIpAddr eNB Controlled -
...                                                    Address not initialized or unconfirmed - EN-DC SON Information Exchange -
...                                                    IPv4, IPv6, IPv4&IPv6 checks
...                     CB007333-B-ae Update of MME information - S1 Setup and eNB Configuration Update -
...                                                               Workaround for the lack of complete Global en-gNB ID in 3GPP S1AP definition
...                     CB007333-B-af Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - LNADJGNB creation by Operator -
...                                                    cPlaneIpAddr
...                     CB007333-B-ag Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - MME CONFIGURATION TRANSFER -
...                                                    cPlaneIpAddr conflicts as a part of EN-DC SON Info Exchange
...                     CB007333-B-ah Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - EN-DC X2 SETUP RESPONSE -
...                                                    Global en-gNB ID conflict for given eNB Controlled LNADJGNB
...                     CB007333-B-ai Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - EN-DC X2 SETUP RESPONSE -
...                                                    Global en-gNB ID conflict with other LNADJGNBs
...                     CB007333-B-aj Requesting eNB - Operator created LNADJGNBs - Conflicting identifiers - LNADJGNB update in persistent storage
...
...      CONTACTS:  Malgorzata Konior        malgorzata.konior@nokia.com
...                 I_EXT_ETK56_GMS <I_EXT_ETK56@internal.nsn.com>
...
...      REFERENCES:  CB007333 CFAM
...
...       HISTORY:
...         [04.08.2020] - Created TC - Konrad Krzyzak
...         [27.01.2021] - TC aligned for CB007333 - Malgorzata Konior
...         [02.02.2021] - Approved by EFS and team members
...         [] - Test finished
...         [] - Review closed

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/EQM-1/APEQM-1/RMOD-1:plainTextConnectionAllowed=true
...    MRBTS-1/EQM-1/APEQM-1/RMOD-2:plainTextConnectionAllowed=true
...    MRBTS-1/LNBTS-1:actEndcAutoX2Setup=false
...    LNBTS-1:actX2gNB128=true
...    LNBTS-1:maxNumNrCell=32768
...    LNBTS-1:maxNumNrCellgNB=256
...    LNCEL-1:cellResourceScellMode=NoScellDefaultGroupUsage

@{CB007333_B_ae}
...    MRBTS-1/LNBTS-1:actEndcAutoX2Setup=true
...    LNMME-2:administrativeState=locked
...    LNMME-2:ipAddrPrim=10.0.1.101
...    LNMME-2:mmeRatSupport=Wideband-LTE
...    LNMME-2:transportNwId=0

...    LNBTS/LNADJGNB-2:administrativeState=locked
...    LNBTS/LNADJGNB-2:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJGNB-2:cPlaneIpAddr=10.0.1.202

...    LNBTS/LNADJGNB-3:administrativeState=locked
...    LNBTS/LNADJGNB-3:cPlaneIpAddrCtrl=enbControlled
...    LNBTS/LNADJGNB-3:cPlaneIpAddr=10.0.1.203
...    LNBTS/LNADJGNB-3:plmnId:mcc=250
...    LNBTS/LNADJGNB-3:plmnId:mnc=333
...    LNBTS/LNADJGNB-3:plmnId:mncLength=3
...    LNBTS/LNADJGNB-3:adjGnbId=19
...    LNBTS/LNADJGNB-3:adjGnbIdLength=22

...    LNBTS/LNADJGNB-4:administrativeState=locked
...    LNBTS/LNADJGNB-4:cPlaneIpAddrCtrl=enbControlled
...    LNBTS/LNADJGNB-4:cPlaneIpAddr=10.0.1.204
...    LNBTS/LNADJGNB-4:plmnId:mcc=250
...    LNBTS/LNADJGNB-4:plmnId:mnc=444
...    LNBTS/LNADJGNB-4:plmnId:mncLength=3
...    LNBTS/LNADJGNB-4:adjGnbId=20
...    LNBTS/LNADJGNB-4:adjGnbIdLength=22

@{CB007333_B_ae_1}
...    LNBTS/LNADJGNB-2:administrativeState=unlocked
...    LNBTS/LNADJGNB-3:administrativeState=unlocked
...    LNBTS/LNADJGNB-4:administrativeState=unlocked

@{CB007333_B_ae_2}
...    LNBTS/LNADJGNB-2:administrativeState=locked
...    LNBTS/LNADJGNB-3:administrativeState=locked
...    LNBTS/LNADJGNB-4:administrativeState=locked

@{CB007333_B_ae_cleanup}
...    @{CB007333_B_ae_2}
...    LNMME-2:administrativeState=locked

${UTE_WIRESHARK_FLAG}    ${False}

${plmn_list_gnb_2}=
...    0x522022 0x421411 0x422422 0x423433 0x424444 0x425455 0x522022 0x421411
...    0x422422 0x423433 0x424444 0x425455 0x522022 0x421411 0x422422 0x423433
...    0x424444 0x429499
${plmn_list_gnb_3}=
...    0x421411 0x422422 0x423433 0x424444 0x425455 0x523033 0x421411 0x422422
...    0x423433 0x523033 0x424444 0x425455 0x421411 0x523033 0x422422 0x423433
...    0x428488 0x425455
${plmn_list_gnb_4}=
...    0x421411 0x422422 0x423433 0x424444 0x425455 0x426466 0x421411 0x422422
...    0x423433 0x424444 0x425455 0x426466 0x427477 0x421411 0x422422 0x423433 0x424444 0x425455
${plmn_list_s1}=
...    0x522022 0x421411 0x422422 0x423433 0x424444 0x425455 0x522022 0x421411 0x422422 0x423433
...    0x424444 0x425455 0x523033 0x421411 0x422422 0x423433 0x424444 0x425455 0x523033 0x421411
...    0x422422 0x423433 0x424444 0x425455 0x524044 0x421411 0x422422 0x423433 0x424444 0x425455
...    0x524044 0x421411 0x422422 0x423433 0x424444 0x425455
${tac_list_s1}=     0x0001 0x0002 0x0003 0x0004 0x0005 0x0006


*** Test Cases ***
CB007333-SR-B-ae Proper handling of multiple PLMNs for NRCELL and presence of PLMN Global en-gNB in MME ANR update
    [Tags]
    [Documentation]
    ...
    ...  DESCRIPTION
    ...  == Info==
    ...    This test covers CB007333-SR-B-ae subitem. Test case verifies that eNB correctly prepares PLMN order when
    ...    sending S1_SETUP_REQUEST and S1_ENB_CONFIGURATION_UPDATE.
    ...    During test eNB will update MME with proper Connected en-gNB To Be Added List or Connected en-gNB To Be Removed List.
    ...    NRCELL PLMNs sorted according to specification, with gNB_PLMN on first position.
    ...  == Description: ==
    ...     LNADJGNB-2.administrativeState is changed to "unlocked".
    ...         gNB_2 generates ENDC_X2_SETUP_RESPONSE with expected PLMN content.
    ...     LNADJGNB-3.administrativeState is changed to "unlocked".
    ...         gNB_3 generates ENDC_X2_SETUP_RESPONSE with expected PLMN content.
    ...     LNADJGNB-4.administrativeState is changed to "unlocked".
    ...         gNB_4 generates ENDC_X2_SETUP_RESPONSE with expected PLMN content.
    ...     LNMME-2.administrativeState is changed to "unlocked".
    ...         eNB generates S1_SETUP_REQUEST with expected Broadcast PLMNs IE.
    ...         eNB sends S1_ENB_CONFIGURATION_UPDATE to MME#1 with proper "Connected en-gNB To Be Added List".
    ...     LNADJGNB-2, LNADJGNB-3, LNADJGNB-4 administrativeState is changed to "locked".
    ...         eNB sends S1_ENB_CONFIGURATION_UPDATE to MME#1 with proper "Connected en-gNB To Be Removed List"
    ...         eNB sends S1_ENB_CONFIGURATION_UPDATE to MME#2 with proper "Connected en-gNB To Be Removed List"
    ...
    ...  PRECONDITION:
    ...    actEndcAutoX2Setup.LNBTS = true
    ...    LNMME-0 is configured and unlocked
    ...    MME_1 S1LinkStatus is available
    ...    LNMME-2 is configured and locked
    ...    MME_2 S1LinkStatus is unavailable
    ...    LNADJGNB-2 for gNB2 is configured and locked
    ...    LNADJGNB-2 is set with: cPlaneIpAddr=gNB2_IP_address;
    ...    cPlaneIpAddrCtrl=oamControlled; plmnID=NOT_CONFIGURED; adjGnbId/adjGnbIdLength=NOT_CONFIGURED
    ...    LNADJGNB-3 for gNB3 is configured and locked
    ...    LNADJGNB-3 is set with: cPlaneIpAddr=gNB3_IP_address; cPlaneIpAddrCtrl=eNBControlled;
    ...    plmnID=gNB3_PLMN#3; adjGnbId/adjGnbIdLength=gNB3
    ...    LNADJGNB-4 for gNB4 is configured and locked
    ...    LNADJGNB-4 is set with: cPlaneIpAddr=gNB4_IP_address; cPlaneIpAddrCtrl=eNBControlled;
    ...    plmnID=gNB4_PLMN#4; adjGnbId/adjGnbIdLength=gNB4
    ...    MME_1 is aware about gNB_2, gNB_3, gNB_4 location in network
    ...
    ...    NRCELL PLMN configuration for "Served PLMNs" IE, TAC IE and PLMN from "Global en-gNB ID" IE:
    ...        gNB2_Global_PLMN: gNB2_PLMN#2;
    ...        gNB2_1:  gNB2_PLMN#2   PLMN#A     PLMN#B     PLMN#C       PLMN#D     PLMN#E        TAC#1
    ...        gNB2_2:  gNB2_PLMN#2   PLMN#A     PLMN#B     PLMN#C       PLMN#D     PLMN#E        TAC#2
    ...        gNB2_3:  gNB2_PLMN#2   PLMN#A     PLMN#B     PLMN#C       PLMN#D     PLMN#X        TAC#2
    ...
    ...        gNB3_Global_PLMN: gNB3_PLMN#3;
    ...        gNB3_1:  PLMN#A       PLMN#B      PLMN#C      PLMN#D      PLMN#E     gNB3_PLMN#3   TAC#3
    ...        gNB3_2:  PLMN#A       PLMN#B      PLMN#C      gNB3_PLMN#3 PLMN#D     PLMN#E        TAC#4
    ...        gNB3_3:  PLMN#A       gNB3_PLMN#3 PLMN#B      PLMN#C      PLMN#Y     PLMN#D        TAC#4
    ...
    ...        gNB4_Global_PLMN: gNB4_PLMN#4;
    ...        gNB4_1:  PLMN#A       PLMN#B      PLMN#C      PLMN#D      PLMN#E     PLMN#F        TAC#5
    ...        gNB4_2:  PLMN#A       PLMN#B      PLMN#C      PLMN#D      PLMN#E     PLMN#F        TAC#6
    ...        gNB4_3:  PLMN#Z       PLMN#A      PLMN#B      PLMN#C      PLMN#D     PLMN#E        TAC#6
    ...
    ...  POSTCONDITION:
    ...
    ...  TESTING TOOLS:  CUS, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...    HARDWARE ID:  AREA, AHHB
    ...
    ...  *REQUIREMENTS COVERAGE:   LTE_CP_106382
    ...     *REQUIREMENTS IN SCOPE:   CB007333-2174  CB007333-A-ae UC#1 Update of MME information - S1 Setup and eNB Configuration Update -
    ...                             Workaround for the lack of complete Global en-gNB ID in 3GPP S1AP definition
    ...
    ...     *BACKLOG ID:
    ...
    ...  REQUIRED LOGS:  X2, S1 pcap
    ...
    ...  CONTACTS:  malgorzata.konior@nokia.com
    ...             I_EXT_ETK56_GMS <I_EXT_ETK56@internal.nsn.com>
    ...             author: Konrad Krzyzak  konrad.krzyzak@nokia.com
    ...
    ...  REFERENCES:  CFAM CB007333
    ...  HISTORY:
    ...         [04.08.2020] - Created TC - Konrad Krzyzak
    ...         [27.01.2021] - TC aligned for CB007333 - Malgorzata Konior
    ...         [02.02.2021] - Approved by EFS and team members
    ...         [02.02.2021] - Implementation started
    ...         [<date>] - Test finished at SVN revision <svn_revision>
    ...         [<date>] - Review closed
    [Setup]       Common Test Setup And Start To Capture Logs And Prepare testcase preconditions for CB007333-SR-B-ae

    Unlock LNADJGNB-2, LNADJGNB-3, LNADJGNB-4 objects in eNB

    Verify that gNB_2 generates ENDC_X2_SETUP_RESPONSE with expected PLMN content

    Verify that gNB_3 generates ENDC_X2_SETUP_RESPONSE with expected PLMN content

    Verify that gNB_4 generates ENDC_X2_SETUP_RESPONSE with expected PLMN content

    Unlock LNMME-2 object in eNB

    Verify that eNB generates S1_SETUP_REQUEST with expected Broadcast PLMNs IE to MME_2

    Verify that eNB sends S1_ENB_CONFIGURATION_UPDATE to MME_1 with proper "Connected en-gNB To Be Added List"

    Lock LNADJGNB-2, LNADJGNB-3 and LNADJGNB-4 objects in eNB

    Verify that eNB sends S1_ENB_CONFIGURATION_UPDATE to MME_1 with proper "Connected en-gNB To Be Removed List"

    Verify that eNB sends S1_ENB_CONFIGURATION_UPDATE to MME_2 with proper "Connected en-gNB To Be Removed List"

    [Teardown]     Common Test Teardown And Stop Capture Logs And Cleanup test environment for CB007333-SR-B-ae

*** Keywords ***
Common Suite Setup And Setup Cus Env
    Common Suite Setup
    Setup Cus Env    tl_type=CB007333/3CELLs_FDD_2Band3_Band7
	PreConfigure In Egate
    Create Alias

Create Alias
    Create Ue Alias    UE_1    ue_id=1    id_type=rtg
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create MME Alias    MME_2    mme_id=2    id_type=wts
    Create Enb Alias    MeNB    enb_id=1    id_type=wts
    Create Enb Alias    SeNB    enb_id=10    id_type=wts
    Create Enb Alias    gNB_2    enb_id=2    id_type=wts
	Create Enb Alias    gNB_3    enb_id=3    id_type=wts
	Create Enb Alias    gNB_4    enb_id=4    id_type=wts
	Create Enb Alias    gNB_5    enb_id=5    id_type=wts

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

Common Test Setup And Start To Capture Logs And Prepare testcase preconditions for CB007333-SR-B-ae
    Common Test Setup And Start To Capture Logs
    Prepare testcase preconditions for CB007333-SR-B-ae

Prepare testcase preconditions for CB007333-SR-B-ae
    Parameters Configuration    ${CB007333_B_ae}
    Expect message flow
    ...     MME_1:S1AP_ENBConfigurationUpdate as MME_1_Configuration_Update
    ...     MME_1:S1AP_ENBConfigurationUpdateAcknowledge as MME_1_Configuration_Update_Acknowledge
    ...     alias=MME_1_Configuration_Update_with_MeNB   overall_timeout=1000
    sleep  5

Parameters Configuration
    [Arguments]    ${delta_params}
    Delta Commission Parameters    ${delta_params}
	Wait Until Keyword Succeeds    3min    5s    Cells Should Be OnAir

Unlock LNADJGNB-2, LNADJGNB-3, LNADJGNB-4 objects in eNB
    Create flow to verify ENDCX2 link setup between gNB_2 and eNB
    Create flow to verify ENDCX2 link setup between gNB_3 and eNB
    Create flow to verify ENDCX2 link setup between gNB_4 and eNB

    Parameters Configuration    ${CB007333_B_ae_1}

    flow occurred as expected  alias=gNB_2_x2_link_setup
    flow occurred as expected  alias=gNB_3_x2_link_setup
    flow occurred as expected  alias=gNB_4_x2_link_setup

Create flow to verify ENDCX2 link setup between gNB_${gNB_id} and eNB
    Expect message flow
    ...     gNB_${gnb_id}:X2AP_ENDCX2SetupRequest as gNB_${gNB_id}_Setup_Request
    ...     gNB_${gnb_id}:X2AP_ENDCX2SetupResponse as gNB_${gNB_id}_Setup_Response
    ...     alias=gNB_${gnb_id}_x2_link_setup    overall_timeout=200

Verify that gNB_${gNB_id} generates ENDC_X2_SETUP_RESPONSE with expected PLMN content
    ${plmn_list}=   Set variable   ${plmn_list_gNB_${gNB_id}}
    verify_plmn_in_endcx2setupresponse  gNB_${gNB_id}_Setup_Response  gNB_${gnb_id}_x2_link_setup  ${gnb_id}  ${plmn_list_gNB_${gNB_id}}

Unlock LNMME-${mme_id} object in eNB
    Create flow to verify S1 link setup between MME_${mme_id} and eNB
    Parameters Configuration  LNMME-${mme_id}:administrativeState=unlocked
    flow occurred as expected  alias=MME_${mme_id}_s1_link_setup

Create flow to verify S1 link setup between MME_${mme_id} and eNB
    Expect message flow
    ...     MME_${mme_id}:S1AP_S1SetupRequest as MME_${mme_id}_Setup_Request
    ...     MME_${mme_id}:S1AP_S1SetupResponse as MME_${mme_id}_Setup_Response
    ...     alias=MME_${mme_id}_s1_link_setup    overall_timeout=1000

Verify that eNB generates S1_SETUP_REQUEST with expected Broadcast PLMNs IE to MME_${mme_id}
    verify_plmn_in_s1_message  MME_${mme_id}_Setup_Request  MME_${mme_id}_s1_link_setup  ${mme_id}  ${plmn_list_s1}  ${tac_list_s1}

Verify that eNB sends S1_ENB_CONFIGURATION_UPDATE to MME_${mme_id} with proper "Connected en-gNB To Be Added List"
    flow occurred as expected  alias=MME_${mme_id}_Configuration_Update_with_MeNB
    verify_plmn_in_s1_message  MME_${mme_id}_Configuration_Update  MME_${mme_id}_Configuration_Update_with_MeNB  ${mme_id}
    ...    ${plmn_list_s1}  ${tac_list_s1}

Lock LNADJGNB-2, LNADJGNB-3 and LNADJGNB-4 objects in eNB
    Expect message flow
    ...     MME_1:S1AP_ENBConfigurationUpdate as MME_1_Configuration_Update
    ...     MME_1:S1AP_ENBConfigurationUpdateAcknowledge as MME_1_Configuration_Update_Acknowledge
    ...     alias=MME_1_Configuration_Update_with_MeNB   overall_timeout=1000
    Expect message flow
    ...     MME_2:S1AP_ENBConfigurationUpdate as MME_2_Configuration_Update
    ...     MME_2:S1AP_ENBConfigurationUpdateAcknowledge as MME_2_Configuration_Update_Acknowledge
    ...     alias=MME_2_Configuration_Update_with_MeNB   overall_timeout=500

    Parameters Configuration    ${CB007333_B_ae_2}

Verify that eNB sends S1_ENB_CONFIGURATION_UPDATE to MME_${mme_id} with proper "Connected en-gNB To Be Removed List"
    flow occurred as expected  alias=MME_${mme_id}_Configuration_Update_with_MeNB
    verify_plmn_in_s1_message  MME_${mme_id}_Configuration_Update  MME_${mme_id}_Configuration_Update_with_MeNB  ${mme_id}
    ...    ${plmn_list_s1}  ${tac_list_s1}

Cleanup test environment for CB007333-SR-B-ae
    Parameters Configuration  ${CB007333_B_ae_cleanup}

Common Test Teardown And Stop Capture Logs And Cleanup test environment for CB007333-SR-B-ae
    Cleanup test environment for CB007333-SR-B-ae
    Common Test Teardown And Stop Capture Logs