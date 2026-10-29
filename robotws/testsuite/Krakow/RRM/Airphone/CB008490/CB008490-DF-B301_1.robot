*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
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
...      CB008490-DF#B301 - SN side PLMN and SNSSAI validation
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

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=SN    sim_gNB=MN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_3c_n257_simMN.lua
${SCF_gnb3_SN}=           Krakow/CB008490/scf_DF_B301_1.xml
${AP_XML}=                Krakow/CB008490/iphy_3cells_n257_1xAWEUB_simMN.xml

*** Test Cases ***
CB008490-DF-B301_1 SN rejects S-Node Addition Request due to unsupported PLMN
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This User Scenario describes S-Node Addition failure when RAN Sharing is enabled on SN and:
    ...  1.	XnAP:SNodeAdditionRequest comes with Selected PLMN not supported by SN.
    ...  2.	Selected PLMN IE is not present in XnAP:SNodeAdditionRequest.
    ...
    ...  == PRECONDITION ==
    ...  MN gNB2 - simulated, configured to send PLMN#1 as Selected PLMN in S-Node Addition Request.
    ...
    ...  SN gNB3 - supports inter-gNB NR-DC Secondary Node role. It is configured MORAN manner - NRBTS parameters point
    ...  to PLMN#1, while FR2 cell is leased by different operator and points to PLMN#2.
    ...  NRPLMN-1 -> PLMN#1
    ...  NRPLMN-2 -> PLMN#2
    ...  TRACKINGAREA-1
    ...     fiveGsTac = 1
    ...     snssaiList -> SNSSAI-1
    ...  TRACKINGAREA-2
    ...     fiveGsTac = 2
    ...     snssaiList -> SNSSAI-1
    ...  SNSSAI-1
    ...     sst = 1
    ...     nrPlmnDnList -> NRPLMN-1, NRPLMN-2
    ...  SN_Cell-1 (n257):
    ...     NRPLMNSET_SA-1
    ...         trackingAreaDN -> TRACKINGAREA-2
    ...         nrPlmnList -> NRPLMN-2
    ...  NRBTS/actRanSharing = true
    ...  NRBTS/actSliceNumExt = false
    ...
    ...  UEs support MN and SN band combination for NR-DC in capabilities.
    ...  UEs selected PLMN is PLMN#1.
    ...  Xn link between MN and SN is established and the latest configuration of SN's PLMNs and Slices is stored in
    ...    MN according to content of Xn Setup Request Response or Xn NG-RAN Node Configuration Update.
    ...
    ...  == POSTCONDITION ==
    ...  UEs are in RRC-CONNECTED state on NRCELL-1 (MN-gNB) without NR-DC configured.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB simulated BTS sim_MN
    ...  - gNB classical BTS in SA mode as SN - gNB_SN
    ...  - gNB module SN (ASIL + ABIO + ABIO / ASIM + ABIP + ABIP)
    ...  - UEs configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25899
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DF#EC1 SN rejects S-Node Addition Request due to unsupported PLMN - main and ALT#1
    ...
    ...  == HISTORY ==
    ...  [19.11.2024] - Create Test Suite
    ...  [02.12.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=923873)

    [Setup]  Prepare test environment CB008490-DF-B301

    Attach UE1 without ICS to MN gNB2 NRCELL-1
    Add to UE1 initial PDU session on sim gNB with ICS and indexToRFSP equal 1
    Set expected messages flows for SNodeAddition Reject for SN gNB3
    UE1 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for SNodeAddition Reject for SN gNB3
    Verify that SNodeAdditionRequestReject contains cause:radioNetwork:unspecified for SN gNB3

    Configure gNB2 to send SNode Addition Request without selected PLMN IE

    Attach UE2 without ICS to MN gNB2 NRCELL-1
    Add to UE2 initial PDU session on sim gNB with ICS and indexToRFSP equal 1
    Set expected messages flows for SNodeAddition Reject for SN gNB3
    UE2 sends A4 measurement with target cells [2] for NR-DC PSCell addition with sim MN
    Verify expected messages flows for SNodeAddition Reject for SN gNB3
    Verify that SNodeAdditionRequestReject contains cause:radioNetwork:unspecified for SN gNB3

    [Teardown]  Basic cleanup sim SN

*** Keywords ***
Configure gNB${gnb_id} to send SNode Addition Request without selected PLMN IE
    Execute egate command    cmd=gnb_snode_addition_request_param id=${gnb_id} action=override_ie do_not_set_selected_plmn=1
