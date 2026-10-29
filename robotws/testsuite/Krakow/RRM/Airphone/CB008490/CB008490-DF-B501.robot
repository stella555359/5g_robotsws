*** Settings ***
Documentation
...      == COPYRIGHT ==
...
...      == INTRODUCTION ==
...      This sub-feature introduces RAN sharing/slicing in inter-gNB NR-DC cases.
...
...      == TEST SET NAME ==
...      CB008490-DF PSCell Addition (RAN sharing/slicing)
...
...      == TESTING SPLIT ==
...      CB008490-DF#B101 - NR-DC A4 measurements configuration with PLMN check
...      CB008490-DF#B201 - NR-DC A4 measurements handling - PLMN validation
...      CB008490-DF#B301 - SN side PLMN and SNSSAI validation
...      CB008490-DF#B401 - Dynamic Add/Remove Cell
...      CB008490-DF#B501 - Interaction with Graceful handling
...
...      == TESTING SCOPE ==
...      CB008490-DF#B501 - Interaction with Graceful handling
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
...      [19.11.2024] - Create Test Suite
...      [02.12.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=923873)

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot

Library     resources/CB008490_IP.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_DF_B501_MN.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_DF_B501_SN.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml

*** Test Cases ***
CB008490-DF-B501 Interaction with Graceful handling of PDU Session for non-configured slice - CB013052 IWK
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes interaction with CB013052 during PSCell Addition:
    ...  - sending default S-NSSAI from MN perspective
    ...  - accepting unsupported S-NSSAI from SN perspective
    ...
    ...  == PRECONDITION ==
    ...  MN gNB2 is configured to support inter-gNB NR-DC Master Node role with one FR1 cell.
    ...  NRPLMN-1 -> PLMN#1
    ...  TRACKINGAREA-1
    ...     fiveGsTac = 1
    ...     snssaiList -> SNSSAI-1, SNSSAI-2
    ...  SNSSAI-1
    ...     sst = 1
    ...     nrPlmnDnList -> NRPLMN-1
    ...  SNSSAI-2
    ...     sst = 2
    ...     nrPlmnDnList -> NRPLMN-1
    ...  NRCELL-1 (n78):
    ...     NRADJNRCELL-1 -> SN_Cell-1
    ...     trackingAreaDN -> TRACKINGAREA-1
    ...
    ...  SN gNB3 is configured to support inter-gNB NR-DC Secondary Node role with FR2 cell.
    ...  NRPLMN-1 -> PLMN#1
    ...  TRACKINGAREA-1
    ...     fiveGsTac = 1
    ...     snssaiList -> SNSSAI-1, SNSSAI-2
    ...  SNSSAI-1
    ...     sst = 3
    ...     nrPlmnDnList -> NRPLMN-1
    ...  SNSSAI-2
    ...     sst = 4
    ...     nrPlmnDnList -> NRPLMN-1
    ...  SN_Cell-1 (n257):
    ...     trackingAreaDN -> TRACKINGAREA-1
    ...
    ...  For both gNBs:
    ...  NRBTS/actSliceSwitchToDefault = true
    ...  NRBTS/actRanSharing = false
    ...  NRBTS/actSliceNumExt = false
    ...  NRBTS/miNrRSACU = 5min
    ...
    ...  UEs support MN and SN band combination for NR-DC in capabilities.
    ...  Xn link between MN and SN is established.
    ...
    ...  == POSTCONDITION ==
    ...   UE1 is in RRC-CONNECTED state on NRCELL-1 (MN-gNB) without NR-DC configured
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26131; 5G_RAN_USR_RRM_26132; 5G_PM_1884
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DF#B8: Interaction with Graceful handling of PDU Session for non-configured slice -
    ...                     sending default S-NSSAI from MN perpective
    ...  - US CB008490-DF#B9: Interaction with Graceful handling of PDU Session for non-configured slice -
    ...                     accepting unsupported S-NSSAI from SN perpective
    ...
    ...  == HISTORY ==
    ...  [19.11.2024] - Create Test Suite
    ...  [02.12.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=923873)

    [Setup]    Prepare test environment CB008490-DF-B501

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Attach UE1 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Set expected message flow for InitialContextSetupFailure
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1 and nwslice-2
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Verify in InitialContextSetup that PDUSessionResourceSetupListCxtReq contains SNSSAI with SD equal 6
    Verify InitialContextSetupFailure did not occur

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3
    Verify in SNodeAdditionRequest that PDUSessionToBeAddedAddReq contains s-NSSAI with SD equal 1 for SN gNB3

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter on bts_id=2: NRCELL-2 SLICE_FALLBACK_SUC (M55138C03540) is equal 1

    [Teardown]  Basic cleanup

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

Verify in InitialContextSetup that PDUSessionResourceSetupListCxtReq contains SNSSAI with SD equal 6
    ${flow_alias}=  get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     PDUSessionResourceSetupListCxtReq contains (s-NSSAI contains (sD eq '0x000006'))
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}

Set expected message flow for InitialContextSetupFailure
    EXPECT FLOW[timeout=2]: AMF1 NGAP initialContextSetupFailure

Verify InitialContextSetupFailure did not occur
    FAIL FLOW[timeout=2]: AMF1 NGAP initialContextSetupFailure
