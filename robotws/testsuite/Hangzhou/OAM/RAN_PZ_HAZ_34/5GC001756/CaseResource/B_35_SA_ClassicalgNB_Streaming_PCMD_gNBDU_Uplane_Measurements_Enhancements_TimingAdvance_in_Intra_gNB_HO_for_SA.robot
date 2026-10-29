*** Settings ***
Documentation
...   Author: liangliang.heng@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
B_35_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_TimingAdvance_in_Intra_gNB_Intra_cell_HO_for_SA
    log to console     check elemnet  TimingAdvance
    ${crnti_HO_list}   ${crnti_HO_length}   Get nrcti of gnb HO   ${INTRA_HO_PATH}
    FOR   ${idx}    IN RANGE    0   ${crnti_HO_length}
        Load Pcap File with Filter any Expression
        ...   pcap_file=${INTRA_HO_PATH}
        ...   any_expression=nsetapx.DuVendorExtensionRecordDataType==15&&nsetapx.crnti == ${crnti_HO_list}[${idx}]
        ...   filter=tcp.dstport==${dcap_server_port}
        ${initial_value_list}=    wireshark.get_field_value_by_xpath
        ...    xpath=.//nsetapx.timingAdvanceRecord/nsetapx.data_element/nsetapx.taData/nsetapx.initial
        ${initial_value_length}=   Get Length   ${initial_value_list}
        Should Be True   ${initial_value_length}==1
        Should Be True   ${initial_value_list}[0] >=0
    END
    Log To Console   check value is OK

Case Setup: B_35
    Log To Console   Case Setup: B_35
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

Case Teardown: B_35
    Log To Console   Case Teardown: B_35
    run keyword if  not ${rec_status}   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
    robot_common_operations.Common Case Teardown
