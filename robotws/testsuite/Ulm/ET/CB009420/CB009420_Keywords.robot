*** Settings ***

Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB009420

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource          ../resources/SQD65/sqd65_keywords.robot
Resource          ../resources/SQD65/sqd65_commissioning.robot

*** Keywords ***

Prepare TL for CB009420
    Sqd65 Common Setup
    Bring Airphone TL to on Air status

Perform Preconditions of Test Scenario
    Create Testcase Log Directory
    IF    '${PREV_TEST_STATUS}'=='FAIL'
    ...               Perform Preconditions of Test Scenario in Case of Previous TC failed
    Start Logging                    pmcounter_enabled=${FALSE}

Perform Preconditions of Test Scenario in Case of Previous TC failed
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone
    Bring Airphone TL to on Air status

Perform Postconditions of Test Case
    run_keyword_and_warn_on_failure    Stop logging
    Collect AP Sos Report and Snapshots

NSA UE Attach and Bidirectional Data Traffic Start
    [Arguments]      ${UE_ID_NSA}  ${TARGET_CELLS}  ${BEARER_ID}  ${DL_MBPS}  ${UL_MBPS}
    Attach UE to LTE  ue_id=${UE_ID_NSA}
    Trigger LTE-NR dual connectivity for bearers  ue_id=${UE_ID_NSA}  bearer_id=${BEARER_ID}  target_gnb=2  target_cells=${TARGET_CELLS}
    ...   type=split_scg
    Start data traffic in egate  ue_id=${UE_ID_NSA}  id=${BEARER_ID}   direction=dl  mbps=${DL_MBPS}  trf_id=1
    Sleep                                   2s
    Start data traffic in egate  ue_id=${UE_ID_NSA}  id=${BEARER_ID}   direction=ul  mbps=${UL_MBPS}  trf_id=1

NSA Bidirectional Data Traffic Validation and UE Dettach
    [Arguments]      ${UE_ID_NSA}  ${BEARER_ID}
    ${DLDATA_RATE} =  Get Average Data Rate via Egate  ue_id=${UE_ID_NSA}  id=${BEARER_ID}  direction=dl  type=l3  trf_id=1
    Perform NSA DL Data Traffic Validation  DLdata_rate=${DLDATA_RATE}
    ${ULDATA_RATE} =  Get Average Data Rate via Egate  ue_id=${UE_ID_NSA}  id=${BEARER_ID}  direction=ul  type=l3  trf_id=1
    Perform NSA UL Data Traffic Validation  ULdata_rate=${ULDATA_RATE}
    Stop data traffic in egate  ue_id=${UE_ID_NSA}  direction=bi  trf_id=1
    UE Dual Connectivity Release  ue_id=${UE_ID_NSA}  bearer=${BEARER_ID}  by=enb  cause=RN_user_inactivity
    Detach UE from LTE  ue_id=${UE_ID_NSA}

SA UE Register and Bidirectional Data Traffic Start
    [Arguments]      ${UE_ID_SA}  ${GW}  ${PDU_ID}  ${DL_MBPS}  ${UL_MBPS}
    UE Register  ue_id=${UE_ID_SA}
    Set traffic type  ue_id=${UE_ID_SA}  pdu_id=${PDU_ID}  trf_type=internal
    UE PDU Session Setup  ue_id=${UE_ID_SA}  pdu=${PDU_ID}  nwslice=1  gw=${GW}
    Start data traffic in egate  ue_id=${UE_ID_SA}  direction=dl  mbps=${DL_MBPS}  trf_id=1  pdu=${PDU_ID}  qfi=1
    Sleep                                   2s
    Start data traffic in egate  ue_id=${UE_ID_SA}  direction=ul  mbps=${UL_MBPS}  trf_id=1  pdu=${PDU_ID}  qfi=1

SA Bidirectional Data Traffic Validation and UE Deregister
    [Arguments]      ${UE_ID_SA}  ${PDU_ID}
    ${DLDATA_RATE} =  Get Average Data Rate via Egate  ue_id=${UE_ID_SA}  direction=dl  trf_id=1  pdu=${PDU_ID}  qfi=1
    Perform SA DL Data Traffic Validation  DLdata_rate=${DLDATA_RATE}
    ${ULDATA_RATE} =  Get Average Data Rate via Egate  ue_id=${UE_ID_SA}  direction=ul  trf_id=1  pdu=${PDU_ID}  qfi=1
    Perform SA UL Data Traffic Validation  ULdata_rate=${ULDATA_RATE}
    Stop data traffic in egate  ue_id=${UE_ID_SA}  direction=bi  trf_id=1  pdu=${PDU_ID}  qfi=1
    UE PDU Session Release  ue_id=${UE_ID_SA}  pdu=${PDU_ID}
    UE Deregister  ue_id=${UE_ID_SA}  ue_deregister_type=switch_off

Perform NSA DL Data Traffic Validation
    [Documentation]    Used to validate the NSA DL data traffic with a successsful or unsuccessful output message.
    [Arguments]  ${DLdata_rate}
    IF  '${DLdata_rate}' >= '${${DL_MBPS}*1000000*0.9}' or '${DLdata_rate}' <= '${${DL_MBPS}*1000000*1.1}'
      ...  Print Successful NSA DL Data Traffic Message
        ...  ELSE  Fail  Unsucessful NSA DL Data Traffic

Perform NSA UL Data Traffic Validation
    [Documentation]    Used to validate the NSA UL data traffic with a successsful or unsuccessful output message.
    [Arguments]  ${ULdata_rate}
    IF  '${ULdata_rate}' >= '${${UL_MBPS}*1000000*0.9}' or '${ULdata_rate}' <= '${${UL_MBPS}*1000000*1.1}'
      ...  Print Successful NSA UL Data Traffic Message
        ...  ELSE  Fail  Unsucessful NSA UL Data Traffic

Print Successful NSA DL Data Traffic Message
    Log    Downlink NSA Data Traffic with Data Rate of ${DL_MBPS} Mbps to UE${UE_ID_NSA} with bearer ${BEARER_ID} is successful.
          ...  console=${P_console}

Print Successful NSA UL Data Traffic Message
    Log    Uplink NSA Data Traffic with Data Rate of ${UL_MBPS} Mbps from UE${UE_ID_NSA} with bearer ${BEARER_ID} is successful.
          ...  console=${P_console}

Perform SA DL Data Traffic Validation
    [Documentation]    Used to validate the SA DL data traffic with a successsful or unsuccessful output message.
    [Arguments]  ${DLdata_rate}
    IF  '${DLdata_rate}' >= '${${DL_MBPS}*1000000*0.9}' or '${DLdata_rate}' <= '${${DL_MBPS}*1000000*1.1}'
      ...  Print Successful SA DL Data Traffic Message
        ...  ELSE  Fail  Unsucessful SA DL Data Traffic

Perform SA UL Data Traffic Validation
    [Documentation]    Used to validate the SA UL data traffic with a successsful or unsuccessful output message.
    [Arguments]  ${ULdata_rate}
    IF  '${ULdata_rate}' >= '${${UL_MBPS}*1000000*0.9}' or '${ULdata_rate}' <= '${${UL_MBPS}*1000000*1.1}'
      ...  Print Successful SA UL Data Traffic Message
        ...  ELSE  Fail  Unsucessful SA UL Data Traffic

Print Successful SA DL Data Traffic Message
    Log    Downlink SA Data Traffic with Data Rate of ${DL_MBPS} Mbps to UE${UE_ID_SA} with PDU ID ${PDU_ID} is successful.
          ...  console=${P_console}

Print Successful SA UL Data Traffic Message
    Log    Uplink SA Data Traffic with Data Rate of ${UL_MBPS} Mbps from UE${UE_ID_SA} with PDU ID ${PDU_ID} is successful.
          ...  console=${P_console}
