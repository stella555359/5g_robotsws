*** Settings ***
Documentation   Robot Verification keywords for feature CB013859
...             Team: I_MN_RAN_RD_VRF_ULM_VT2
...             Email: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library      taf.hw.rf_attenuator              WITH NAME    attenuator
Library      ute_tshark
Library      XML  use_lxml=True

Resource     ../resources/sqd63/verification.robot
Resource     ../resources/carrier_aggregation_verification.robot


Resource     ../../resources/Common/coam_ulm.robot
Resource     ../resources/pcap_analysis.robot

*** Keywords ***

Verify Test Case
   [Arguments]   ${test_name}

   Run Keyword  Verify Test Case ${test_name}

Verify Test Case Part

   Run Keyword  Verification For CB013859_A03 Part${Part}

Verify Test Case CB013859_A_RE_TC03_B3_UE_connection_setup_single_slice
    Log To Console    \nStarting TC Verification

    ${physCellIdSourcePCell}=  scf_info.Get physCellId  gnb_id=${gnb_id_0}  nrcell_id=${p_cell_1}
    Set Test Variable     ${physCellIdSourcePCell}
    ${physCellIdSourceScell1}=  scf_info.Get PhysCellId  gnb_id=${gnb_id_0}  nrcell_id=${s_cell_1}
    Set Test Variable     ${physCellIdSourceScell1}
    ${physCellIdSourceScell2}=  scf_info.Get PhysCellId  gnb_id=${gnb_id_0}  nrcell_id=${s_cell_2}
    Set Test Variable     ${physCellIdSourceScell2}
    ${physCellIdSourceScell3}=  scf_info.Get PhysCellId  gnb_id=${gnb_id_0}  nrcell_id=${s_cell_3}
    Set Test Variable     ${physCellIdSourceScell3}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id_0}
    ${sCellOperationalMode_scell1}  coam_ulm.Get SCF single Value from current xml file
    ...                             dist_name=NRBTS-${nrbts_id_${gnb_id_0}}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}
    ...                             parameter=sCellOperationalMode
    ...                             alias=${oam_alias}
    Set Test Variable     ${sCellOperationalMode_scell1}
    ${sCellOperationalMode_scell2}  coam_ulm.Get SCF single Value from current xml file
    ...                             dist_name=NRBTS-${nrbts_id_${gnb_id_0}}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}
    ...                             parameter=sCellOperationalMode
    ...                             alias=${oam_alias}
    Set Test Variable     ${sCellOperationalMode_scell2}
    ${sCellOperationalMode_scell3}  coam_ulm.Get SCF single Value from current xml file
    ...                             dist_name=NRBTS-${nrbts_id_${gnb_id_0}}/NRCELL-${p_cell_1}/NRREL-${s_cell_3}
    ...                             parameter=sCellOperationalMode
    ...                             alias=${oam_alias}
    Set Test Variable     ${sCellOperationalMode_scell3}
    CB013859_verification.Convert PCAP2PDML    tcp_file=UE1_CB013859_A03_Part${Part}

    Verify Test Case Part

Verify Test Case CB013859_A_RE_TC04_B5_UE_conn_setup_PDU_with_multiple_slices_some_not_supp_scells
    Log To Console    \nStarting TC Verification

    ${physCellIdSourcePCell}=  scf_info.Get physCellId  gnb_id=${gnb_id_0}  nrcell_id=${p_cell_1}
    Set Test Variable     ${physCellIdSourcePCell}
    ${physCellIdSourceScell1}=  scf_info.Get PhysCellId  gnb_id=${gnb_id_0}  nrcell_id=${s_cell_1}
    Set Test Variable     ${physCellIdSourceScell1}
    ${physCellIdSourceScell2}=  scf_info.Get PhysCellId  gnb_id=${gnb_id_0}  nrcell_id=${s_cell_2}
    Set Test Variable     ${physCellIdSourceScell2}
    ${physCellIdSourceScell3}=  scf_info.Get PhysCellId  gnb_id=${gnb_id_0}  nrcell_id=${s_cell_3}
    Set Test Variable     ${physCellIdSourceScell3}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id_0}
    ${sCellOperationalMode_scell1}  coam_ulm.Get SCF single Value from current xml file
    ...                             dist_name=NRBTS-${nrbts_id_${gnb_id_0}}/NRCELL-${p_cell_1}/NRREL-${s_cell_1}
    ...                             parameter=sCellOperationalMode
    ...                             alias=${oam_alias}
    ${sCellOperationalMode_scell2}  coam_ulm.Get SCF single Value from current xml file
    ...                             dist_name=NRBTS-${nrbts_id_${gnb_id_0}}/NRCELL-${p_cell_1}/NRREL-${s_cell_2}
    ...                             parameter=sCellOperationalMode
    ...                             alias=${oam_alias}
    ${sCellOperationalMode_scell3}  coam_ulm.Get SCF single Value from current xml file
    ...                             dist_name=NRBTS-${nrbts_id_${gnb_id_0}}/NRCELL-${p_cell_1}/NRREL-${s_cell_3}
    ...                             parameter=sCellOperationalMode
    ...                             alias=${oam_alias}
   ${SCELL_CONFIG}  Get Added SCell Info  pcap_file=${resultTestDir}/UE1_CB013859_A04_Part1.pcap

    CB013859_verification.Convert PCAP2PDML    tcp_file=UE1_CB013859_A04_Part${Part}

    carrier_aggregation_verification.Check Scell Addition  pcap_file=${resultTestDir}/UE1_CB013859_A04_Part1.pcap  band_scell=25,66,41
    ...    physCellId=${physCellIdSourceScell1},${physCellIdSourceScell2},${physCellIdSourceScell3}
    Should be Equal  ${SCELL_CONFIG}[${physCellIdSourceScell1}][operationalmode]  ${sCellOperationalMode_scell1}
    Should be Equal  ${SCELL_CONFIG}[${physCellIdSourceScell2}][operationalmode]  ${sCellOperationalMode_scell2}
    Should be Equal  ${SCELL_CONFIG}[${physCellIdSourceScell3}][operationalmode]  ${sCellOperationalMode_scell3}
#    Check EventId For eventA1, eventA3 And eventA4  pcap_file=${pcap_file}  expected_events=eventId: eventA1 (0)

Verify Test Case CB013859_B_RE_TC06_IWK_5_interworking_A6_based_SCell_swap_F_to_F
    [Arguments]        ${gnb_id}=${0}
    Log To Console    \nStarting TC Verification

    ${physCellIdSourcePCell}=  scf_info.Get physCellId  gnb_id=${gnb_id}  nrcell_id=${p_cell_1}
    Set Test Variable     ${physCellIdSourcePCell}
    ${physCellIdSourceScell1}=  scf_info.Get PhysCellId  gnb_id=${gnb_id}  nrcell_id=${s_cell_1}
    Set Test Variable     ${physCellIdSourceScell1}
    ${physCellIdSourceScell2}=  scf_info.Get PhysCellId  gnb_id=${gnb_id}  nrcell_id=${s_cell_2}
    Set Test Variable     ${physCellIdSourceScell2}
    ${physCellIdSourceScell3}=  scf_info.Get PhysCellId  gnb_id=${gnb_id}  nrcell_id=${s_cell_3}
    Set Test Variable     ${physCellIdSourceScell3}
    ${physCellIdTargetScell2}=  scf_info.Get PhysCellId  gnb_id=${gnb_id}  nrcell_id=${s_cell_target_2}
    Set Test Variable     ${physCellIdTargetScell2}
    ${physCellIdTargetScell3}=  scf_info.Get PhysCellId  gnb_id=${gnb_id}  nrcell_id=${s_cell_target_3}
    Set Test Variable     ${physCellIdTargetScell3}

    CB013859_verification.Convert PCAP2PDML    tcp_file=CB013859_scell_addition
    CB013859_verification.Convert PCAP2PDML    tcp_file=CB013859_scell_swap

    carrier_aggregation_verification.Check Scell Addition  pcap_file=${resultTestDir}/CB013859_scell_addition.pcap  band_scell=71,66,77
    ...    physCellId=${physCellIdSourceScell1},${physCellIdSourceScell2},${physCellIdSourceScell3}
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${resultTestDir}/CB013859_scell_swap.pcap  band_scell=71,66,77
    ...    physCellId=${physCellIdSourceScell1},${physCellIdTargetScell2},${physCellIdTargetScell3},${physCellIdSourceScell2}

Verify Test Case CB013859_B_RE_TC07_IWK_6_interworking_inter_gNB_CA
    Log To Console    \nStarting TC Verification

    ${physCellIdSourcePCell}=  scf_info.Get physCellId  gnb_id=${gnb_id_0}  nrcell_id=${p_cell_1}
    Set Test Variable     ${physCellIdSourcePCell}
    ${physCellIdExtSourceScell1}=  scf_info.Get PhysCellId  gnb_id=${gnb_id_1}  nrcell_id=${ext_s_cell_1}
    Set Test Variable     ${physCellIdExtSourceScell1}
    ${physCellIdExtSourceScell2}=  scf_info.Get PhysCellId  gnb_id=${gnb_id_1}  nrcell_id=${ext_s_cell_2}
    Set Test Variable     ${physCellIdExtSourceScell2}
    ${physCellIdExtSourceScell3}=  scf_info.Get PhysCellId  gnb_id=${gnb_id_1}  nrcell_id=${ext_s_cell_3}
    Set Test Variable     ${physCellIdExtSourceScell3}
    Log To Console    Physical PCell Id: ${physCellIdSourcePCell}
    Log To Console    Physical ext-SCell Id 1: ${physCellIdExtSourceScell1}
    Log To Console    Physical ext-SCell Id 2: ${physCellIdExtSourceScell2}
    Log To Console    Physical ext-SCell Id 3: ${physCellIdExtSourceScell3}

    CB013859_verification.Convert PCAP2PDML    tcp_file=UE1_CB013859_B07

    Verification For CB013859_B07

###

Convert PCAP2PDML
    [Documentation]    Convert tracing file from pcap to pdml
    [Arguments]    ${tcp_file}
    ute_tshark.Read Pcap And Save To File    output_type=pdml  pcap_file_path=${resultTestDir}/${tcp_file}.pcap
    ...    filename=${resultTestDir}/${tcp_file}.pdml
    Set Test Variable    ${pcap_file}    ${resultTestDir}/${tcp_file}.pcap
    Set Test Variable    ${pdml_file}    ${resultTestDir}/${tcp_file}.pdml


Verification For CB013859_A03 Part1
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB013859_A03_Part1.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=25,66,41
    ...    physCellId=${physCellIdSourceScell1},${physCellIdSourceScell2},${physCellIdSourceScell3}
    ${SCELL_CONFIG}  Get Added SCell Info  pcap_file=${pcap_file}
    Should be Equal  ${SCELL_CONFIG}[${physCellIdSourceScell1}][operationalmode]  ${sCellOperationalMode_scell1}
    Should be Equal  ${SCELL_CONFIG}[${physCellIdSourceScell2}][operationalmode]  ${sCellOperationalMode_scell2}
    Should be Equal  ${SCELL_CONFIG}[${physCellIdSourceScell3}][operationalmode]  ${sCellOperationalMode_scell3}
#    Check EventId For eventA1, eventA3 And eventA4  pcap_file=${pcap_file}  expected_events=eventId: eventA1 (0)


Verification For CB013859_A03 Part2
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB013859_A03_Part2.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=25,41
    ...    physCellId=${physCellIdSourceScell1},${physCellIdSourceScell2}
    ${SCELL_CONFIG}  Get Added SCell Info  pcap_file=${pcap_file}
    Should be Equal  ${SCELL_CONFIG}[${physCellIdSourceScell1}][operationalmode]  ${sCellOperationalMode_scell1}
    Should be Equal  ${SCELL_CONFIG}[${physCellIdSourceScell2}][operationalmode]  ${sCellOperationalMode_scell2}

Verification For CB013859_A04
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB013859_A04_Part1.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=25,66,41
    ...    physCellId=${physCellIdSourceScell1},${physCellIdSourceScell2},${physCellIdSourceScell3}
#    Check EventId For eventA1, eventA3 And eventA4  pcap_file=${pcap_file}  expected_events=eventId: eventA1 (0)

Verification For CB013859_B07
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB013859_B07.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=66,2,77
    ...    physCellId=${physCellIdExtSourceScell1},${physCellIdExtSourceScell2},${physCellIdExtSourceScell3}
#    Check EventId For eventA1, eventA3 And eventA4  pcap_file=${pcap_file}  expected_events=eventId: eventA1 (0)
##########################################################

Check SCell Setup Index List Should Contain SCell-ToBeSetupMod-List
    [Arguments]    ${pcap_file}  ${items}
    ${SCell_list}   Create List

    ${SCell_list_expected}   Create List
    FOR  ${i}  IN  ${items}
        Collections.Append To list  ${SCell_list_expected}  sCellIndex: ${i+1}
    END
    Log To Console  ${SCell_list_expected}

    ${output}    ute_tshark.Read Pcap    packet_filter=(nokiaf1ap.SCell_ToBeSetupMod_List==${items})
    ...    output_type=pdml    pcap_file_path=${pcap_file}
    ${SCell_ToBeSetupMod_path}=    Set Variable
    ...    .//field[@name='nokiaf1ap.SCell_ToBeSetupMod_List']
    ${SCell_ToBeSetupMod_elem}    XML.Get Element  ${output}  ${SCell_ToBeSetupMod_path}
    ${showname}  XML.Get Element Attribute  ${SCell_ToBeSetupMod_elem}  showname
    Should Contain  ${showname}  SCell-ToBeSetupMod-List: ${items} items

    ${SCellIndexList_path}=    Set Variable
    ...    .//field[@name='nokiaf1ap.SCell_ToBeSetupMod_Item_element']//field[@name='nokiaf1ap.sCellIndex']
    ${SCellIndexList_elems}    XML.Get Elements  ${output}  ${SCellIndexList_path}
    FOR  ${SCellIndexList_elem}  IN  @{SCellIndexList_elems}
        ${showname}  XML.Get Element Attribute  ${SCellIndexList_elem}  showname
        Collections.Append To List  ${SCell_list}  ${showname}
    END
    Lists Should Be Equal  ${SCell_list}  ${SCell_list_expected}  ignore_order=True


Check SCellIndex in UEContextModificationRequest
    [Arguments]    ${pcap_file}  ${sCell_id}
    ${output}    ute_tshark.Read Pcap    packet_filter=(nokiaf1ap.sCellIndex == ${sCell_id}) && (nokiaf1ap.id == 56)
    ...    output_type=pdml    pcap_file_path=${pcap_file}

    ${SCellStatusIndex_path}=    Set Variable
    ...    .//field[@name='nokiaf1ap.SCell_Status_Item_element']//field[@name='nokiaf1ap.sCellIndex']

    ${SCellStatusIndex_elems}    XML.Get Elements  ${output}  ${SCellStatusIndex_path}
    FOR  ${SCellStatusIndex_elem}  IN  @{SCellStatusIndex_elems}
        ${showname}  XML.Get Element Attribute  ${SCellStatusIndex_elem}  showname
        Should Contain  ${showname}  sCellIndex: ${sCell_id}
    END


Check EventId For eventA1, eventA3 And eventA4
    [Arguments]    ${pcap_file}  ${expected_events}

    @{expected_events_list}  String.Split String  ${expected_events}  ,

    ${output}    ute_tshark.Read PCAP
    ...    packet_filter=(nokiaf1ap.procedureCode == 7) && ((nr-rrc.eventId == 0)||(nr-rrc.eventId == 3)||(nr-rrc.eventId==2))
    ...    output_type=pdml    pcap_file_path=${pcap_file}

    ${reportedEvent_elem_path}=    Set Variable
    ...    .//field[@name='nr-rrc.eventTriggered_element']//field[@name='nr-rrc.eventId']

    ${ReportedEventList_elems}    XML.Get Elements  ${output}  ${reportedEvent_elem_path}
    ${received_events}  Create List
    FOR  ${reportedEvent_elem}  IN  @{ReportedEventList_elems}
        ${showname}  XML.Get Element Attribute  ${reportedEvent_elem}  showname
        Collections.Append To List  ${received_events}  ${showname}
    END
    @{received_events_list}  Collections.Remove Duplicates  ${received_events}
    Collections.Lists Should Be Equal  ${received_events_list}  ${expected_events_list}  ignore_order=True
