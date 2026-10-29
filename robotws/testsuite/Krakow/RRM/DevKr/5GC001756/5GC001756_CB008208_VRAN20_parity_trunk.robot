*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         5GC001756: PCMD for SA
...         PCMD records provide per call measurements/statistics data.
...         PCMD provides a "summary" of the UE experience in the signaling, user plane, and RF domains.
...         Feature is mainly aimed at increasing PCMD fields to cover SA scenarios.
...
...      == TEST SET NAME ==
...         5GC001756
...
...      == TESTING SPLIT==
...            5GC001756-B
...            5GC001756-B-B101 Reporting SINR related gNB-DU UP PCMD
...            5GC001756-B-B102 Reporting Timing Advance related gNB-DU UP PCMD
...            5GC001756-B-B201 Reporting gNB-DU UP PCMDs - UP internal changes in deployment
...            5GC001756-D
...            5GC001756-D-B101 Reporting Timing Advance in contention-based RA gNB-DU UP PCMD
...            5GC001756-D-B102 Reporting gNB-DU UP PCMDs - SA user scenarios for legacy PCMDs
...            5GC001756-D-B103 Reporting SINR related gNB-DU UP PCMD in SA mode
...            5GC001756-EA
...            5GC001756-EA-B101 gNB-CU PDU Session Info Record for Initial Context Setup
...            5GC001756-EA-B102 gNB-CU PDU Session Info Record for Pdu Session Resource Setup
...            5GC001756-EA-B103 gNB-CU PDU Session Info Record for Pdu Session Resource Modification
...            5GC001756-EA-B104 gNB-CU PDU Session Info Record for Pdu Session Resource Release
...            5GC001756-EA-B106 gNB-CU PDU Session Info Record for Intra-gNB mobility
...            5GC001756-EA-B107 gNB-CU PDU Session Info Record for Inter-gNB mobility
...            5GC001756-EA-B113 gNB-CU UeDuConnectivity Record for Intra-gNB Inter-DU Handover
...            5GC001756-EA-B114 gNB-CU UeDuConnectivity Record for Inter-gNB Handover (Target gNB)
...            5GC001756-EA-B116 gNB-CU UeDuConnectivity Record for RRC Re-establishment with the same gNB-DU
...            5GC001756-EA-B118 gNB-CU UeDuConnectivity Record for Initial Context Setup
...            5GC001756-EA-B119 gNB-CU UeDuConnectivity Record for PDU Session Resource Setup
...            5GC001756-EA-B121 gNB-CU UE Setup Record for Initial Context Setup
...            5GC001756-EA-B122 gNB-CU UE Setup Record for Intra-gNB mobility
...            5GC001756-EA-B123 gNB-CU UE Setup Record for Inter-gNB mobility
...            5GC001756-EA-B124 gNB-CU UE Setup Record for miscellaneous cases
...            5GC001756-EA-B125 gNB-CU Bearer Record for Initial Context Setup
...            5GC001756-EA-B126 gNB-CU Bearer Record for PDU Session Resource Setup
...            5GC001756-EA-B127 gNB-CU Bearer Record for PDU Session Resource Modification
...            5GC001756-EA-B128 gNB-CU Bearer Record for PDU Session Resource Release
...            5GC001756-EA-B129 gNB-CU Bearer Record for Intra-gNB mobility
...            5GC001756-EA-B130 gNB-CU Bearer Record for Inter-gNB mobility
...            5GC001756-EA-B201 DU UE context setup record reporting - Initial Context Setup
...            5GC001756-EA-B202 DU UE context setup record reporting - Intra/Inter gNB Inter DU HO target
...            5GC001756-EA-B203 DU UE context setup record reporting - Intra gNB Intra DU HO target
...            5GC0017656-G-B1 Uplane - Multiple Bearers reporting
...
...      == AUTHORS ==
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         5GC001756 CFAM
...
...      == HISTORY ==
...         [27.05.2021] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=819919)
...         [19.04.2022] - Create VRAN2.0 parity test suite
...         [31.08.2022] - Split trunk and 22R4 suites to separate files
...         [13.02.2023] - Switch to VRAN4.0 RANNIC
...         [23.11.2023] - Switch to VRAN4.0 Rinline2 Thor

Resource    ./resources/5GC001756-EA_keywords.robot
Resource    ./resources/5GC001756-common_keywords.robot
Resource    ./resources/5GC001756-EA-records.robot
Resource    ./resources/5GC001756-verify_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    master_vDU    vDUCNF00    DISABLE_GENERATION
    ...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
    ...    PY39

Suite Setup    Run VRAN Setup
Suite Teardown  Run keywords
...             vcu_emss_teardown    AND
...             vdu_emss_teardown

*** Variables ***
${LUA_CFG}=                     ${CURDIR}/../resources/vran_config/FS_SA_TDD_2c_1AMF.lua
${clear_pcmd_config}=           ${CURDIR}/config/VRAN/delete_objects_CU.yaml
@{yaml_paths_to_configure}=     ${CURDIR}/config/VRAN/pcmd_enable_CU.yaml
...                             ${disable_ciphering_yaml_path}

*** Test Cases ***
5GC001756-EA PCMD for SA - ICS without PDU session then initial PDU session setup success
    [Tags]    C1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  The purpose of test is to verify that gNB-CU sends correctly PCMD reports during below procedures:
    ...  Procedure: Successful Initial Context Setup without PDU session
    ...             Successful Initial PDU Session Setup with one subsequent PDU session
    ...
    ...  PCMD reports:
    ...     - gNB-CU doesn't report CU PDU Session Info Record after successful Initial Context Setup without PDU session
    ...     - gNB-CU reports CU PDU Session Info Record after successful Initial PDU Session Setup with one PDU session
    ...     - gNB-CU reports CU UE Setup Record after successful Initial Context Setup without PDU session
    ...
    ...  == Precondition: ==
    ...	 - NRCELL simulated on AEQP radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - NRCELL/cellDepType is set to SA
    ...  - Trace Session with PCMD content is activated on gNB2 cell1 for vCU:
    ...  - TCE is configured in MNL/TCEADM/TCE
    ...  - NRBTS/actPCMDReport is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/actPCMDReporting is set to True
    ...  - NRBTS/NRCTRLTS/NRMTRACECU/NRRESOURCECU is created for considered NRCELL
    ...  - Max number of traced UE/Cell is not reached on gNB-vCU (NRBTS/NRCTRLTS/NRMTRACECU /cellMaxActiveUEsTraced)
    ...  - SERVEDAMF-1 has one unique GUAMI - 311:489:1:2:1
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB VRAN4.0 BTS in SA mode
    ...  - HARDWARE ID:  VRAN4.0 gNB(vCU OE22 + vDU RANNIC) with simulated AEQP radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_COM_3036, 5G_RAN_USR_COM_3037
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - 5GC001756-EA-B101 gNB-CU PDU Session Info Record for Initial Context Setup
    ...         - User Scenario#1 Initial Context Setup without PDU session
    ...     - 5GC001756-EA-B102 gNB-CU PDU Session Info Record for Pdu Session Resource Setup
    ...         - User Scenario#1 Successful PDU Session Resource Setup - 5GC requests initial PDU Session to be setup for the UE
    ...     - 5GC001756-EA-B121 gNB-CU UE Setup Record for Initial Context Setup
    ...         - User Scenario#1 Initial Context Setup without PDU session
    ...
    ...  HISTORY:
    ...         [27.05.2021] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=819919)
    ...         [19.04.2022] - makielty: VRAN2.0 passed CB008208 on TL SKA, SW build: vCUCNF22R3_0.250.4522;vDUCNF22R3_0.300.5409
    ...         [08.02.2023] - makielty: VRAN4.0 passed CB009444 - SW build: vCUCNF23R2_0.250.10379;vDUCNF23R2_0.300.11078

    [Setup]  VRAN Prepare test environment C1

    EXPECT FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    EXPECT FLOW: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions
    EXPECT FLOW: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    EXPECT FLOW: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure

    Attach UE1 without PDU session to gNB2 cell1

    PASS FLOW: AMF1 NGAP downlinkNASTransport with first UE IDs pair
    PASS FLOW: AMF1 NGAP initialContextSetup not optimized version with 0 PDU Sessions
    PASS FLOW: AMF1 NGAP uERadioCapabilityInfoIndication in optimized ICS procedure
    PASS FLOW: UE_1 NR-RRC UECapabilityEnquiry in optimized ICS procedure

    Verify that AMF1 NGAP InitialContextSetup does not contain any PDU session

    Run keyword and Continue on Failure     Verify CuUeSetupTraceRecord in testC1

#    Verify that gNB-CU PDU Session Info Record is not sent

#    Verify that gNB-CU UE Setup Record is sent correctly:
#    	"result" set to "success"
#    	"UE setup reason" set to "other"
#    	RAN UE NGAP ID
#    	AMF UE NGAP ID
#    	Globally Unique AMF ID

    Clear PCMD records

    EXPECT FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    EXPECT FLOW: UE_1 NR-RRC RRCReconfiguration

    Add to UE1 initial PDU session with one QoS flow

    PASS FLOW: AMF1 NGAP pDUSessionResourceSetup with 1 PDU session(s)
    PASS FLOW: UE_1 NR-RRC RRCReconfiguration

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceSetup
    ...     message=PDUSessionResourceSetupRequest
    ...     list_name=PDUSessionResourceSetupListSUReq
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceSetup
    ...     message=PDUSessionResourceSetupResponse
    ...     list_name=PDUSessionResourceSetupListSURes
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceSetup
    ...     message=PDUSessionResourceSetupRequest
    ...     list_name=QosFlowSetupRequestList
    ...     element_num=1

    Verify number of elements on the list within NGAP message
    ...     amf_id=1
    ...     procedure_name=pDUSessionResourceSetup
    ...     message=PDUSessionResourceSetupResponse
    ...     list_name=associatedQosFlowList
    ...     element_num=1

    Verify in RRCReconfiguration that UE1 1 DRBs were added

    Run keyword and Continue on Failure        Verify PduSessionResourceInfoTraceRecord in testC1

#    Verify that gNB-CU PDU Session Info Record is sent correctly:
#         - "trigger" set to "PDUsessionSetupRequest"
#         - "result" is set to "success"
#         - Successfully established PDU Session with
#             - PDU Session Id
#             - S-NSSAI
#             - PDU Session Aggregated Maximum Bit Rate
#             - List of successfully setup QOS Flows with QFI, Non-dynamic 5QI, ARP and GBR QoS Information in case of GBR QoS Flow presence

    Detach UE1

    [Teardown]  Run keywords
    ...         Cleanup after test C1   AND
    ...         Reset PCMD database

*** Keywords ***
Run VRAN Setup
    Log To Console    Setup started
    Setup VRAN devices aliases
    Run keyword and ignore error
    ...     vcu.Connect to  host=${vCU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    Run keyword and ignore error
    ...     vdu.Connect to  host=${vDU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    setup_vcu_emss
    setup_vdu_emss
    Run keyword and ignore error      vcu configure       ${clear_pcmd_config}
    vcu_configure       ${yaml_paths_to_configure}
#    Send CU delta commissioning   input_filepath=${vran_PCMD_enable_CU_delta}    #sending Unmodifiable parameters in JSON is impossible
    ${run_update}    get variable value      ${configure}    True     # do not ever change that line!
    Run Keyword if  "${run_update}" == "True"
    ...         Reach OnAir in VRAN with retries   lua_cfg=${LUA_CFG}
    Run Keyword if  "${run_update}" != "True"
    ...         Setup egate  egate_port=20000  alias=default

VRAN Prepare test environment C1
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start VRAN PCMD message collection
    Execute egate command    cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
