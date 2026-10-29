*** Settings ***
Documentation
...   Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
EA_25_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_intra_HO
    ${status}   run keyword and return status   File Should Not Be Empty   ${INTRA_HO_PATH}
    ${SA_INTRA_target_crnti_HO_list}   run keyword if  ${status}   Get nrcti of HO    ${INTRA_HO_PATH}
    ...   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==2
#    ${SA_INTRA_source_crnti_HO_list}   run keyword if  ${status}   Get nrcti of HO    ${INTRA_HO_PATH}
#    ...   nsetapx.DuVendorExtensionRecordDataType == 15
#    ${SA_INTRA_source_crnti_HO_list}   evaluate   [item for item in ${SA_INTRA_source_crnti_HO_list} if item not in ${SA_INTRA_target_crnti_HO_list}]
    ${SA_INTRA_source_crnti_HO_list}   run keyword if  ${status}   Get nrcti of HO    ${INTRA_HO_PATH}
    ...   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==3
    ${SA_INTRA_target_crnti_HO_list}   evaluate   [item for item in ${SA_INTRA_target_crnti_HO_list} if item not in ${SA_INTRA_source_crnti_HO_list}]
    ${PDU_initial_list}   ${PDUSetup_initial_list}
    ...   Get PDU Item Lists from PDUsession Record   ${INTRA_HO_PATH}   InitialContext   ${SA_INTRA_source_crnti_HO_list}[0]
    ${PDU_resource_list}   ${PDUSetup_resource_list}
    ...   Get PDU Item Lists from PDUsession Record   ${INTRA_HO_PATH}   PDUSessionResource   ${SA_INTRA_source_crnti_HO_list}[0]
    ${PDU_HO_list}   ${PDUSetup_HO_list}
    ...   Get PDU Item Lists from PDUsession Record   ${INTRA_HO_PATH}   handover   ${SA_INTRA_target_crnti_HO_list}[0]
    should be true   ${PDU_HO_list}[2]==${PDU_initial_list}[2]
    should be true   ${PDU_HO_list}[3]==${PDU_resource_list}[2]
    should be true   ${PDU_HO_list}[1]==${PDU_initial_list}[1]==${PDU_resource_list}[1]
    ${PDUSetup_items_total}   evaluate  ${PDUSetup_initial_list}[0]+${PDUSetup_resource_list}[0]
    should be true   ${PDUSetup_HO_list}[0] == ${PDUSetup_items_total}

Case Setup: EA_25
    Log To Console   Case Setup: EA_25
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    ${rec_status}   Run Keyword And Return Status   OperatingSystem.File Should Exist   ${INTRA_HO_PATH}
    Set Suite Variable   ${rec_status}
    run keyword if  not ${rec_status}   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTRA HO

    # # SET PA Initial value
    # # Set TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 40
    # # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 127
    # Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20
    # Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=40
    # Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=127

    # Start Tcpdump To Get PCMD   pcmd_file=EA_25.pcap
    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE BETA

    # # trigger Intra gnb HO by adjust adjustable attenuation
    # # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 0
    # Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=0
    # Sleep   30s
    # Stop Tcpdump To Get PCMD   pcmd_file=EA_25.pcap
    # Detach UE BETA


Case Teardown: EA_25
    Log To Console   Case Teardown: EA_25
    run keyword if  not ${rec_status}   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
    robot_common_operations.Common Case Teardown
