*** Settings ***
Documentation   covers the verifcation of the TCs for CB007219
...             2 parts - verification for each TC
...                     - keywords to verify the trace
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../resources/Common/gnb.robot
Resource    ../resources/pcap_analysis.robot
Library     taf.sbts.oam.coam.admin          WITH NAME   admin


*** Keywords ***

Verify test case
   [Arguments]   ${test_name}

   run keyword  Verify test case ${test_name}

Verify test case TC25_AA_B14_Interaction_with_A1_measurement_based_PCell_switch
    log to console    \nStarting TC Verification
    Log to Console    \n Verify TC checks on gNB1

    ${physCellId_pcell_source}  @{physCellId_scell_source}  Get physCellId for scell and pcell  p_cell=${p_cell}  s_cell=${s_cell}

    Run Keyword And Continue On Failure
    ...  Check Pcell Addition  ${freq_pcell}  tcp_file=${tcp_file_gnb${gnb_id}}  physCellId=${physCellId_pcell_source}
    ...  packet_filter=(${PROTOCOL_NAME}.procedureCode ==7)&&(nr-rrc.measId)
    Run Keyword And Continue On Failure
    ...  Check Scell Addition  tcp_file=${tcp_file_gnb${gnb_id}}  physCellId=${physCellId_scell_source}
    ...  packet_filter=(${PROTOCOL_NAME}.procedureCode ==7)&&(nr-rrc.measId)
    Run Keyword And Continue On Failure
    ...  Check Pcell Swap      ${freq_scell}  tcp_file=${tcp_file_gnb${gnb_id}}  physCellId=${physCellId_scell_source}
    ...  packet_filter=(${PROTOCOL_NAME}.procedureCode ==12)&&(nr-rrc.measId)
    Run Keyword And Continue On Failure
    ...  get_measurement_mapping  pcap_file=${tcp_file_gnb${gnb_id}}
    Run Keyword And Continue On Failure
    ...  should contain    ${phycell_events}[${physCellId_scell_source[0]}]  eventA1

#keywords section

Get physCellId for scell and pcell
    [Arguments]   ${p_cell}  ${s_cell}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    @{scells}  split string  ${s_cell}   ,
    @{physCellId_scell}=    Create List
    FOR   ${scell_id}   IN   @{scells}
          ${result}   coam_ulm.Get SCF single Value from current xml file  dist_name=NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${scell_id}
          ...         parameter=physCellId  alias=${oam_alias}
          Append To List    ${physCellId_scell}   ${result}
    END
    ${physCellId_pcell}  coam_ulm.Get SCF single Value from current xml file  dist_name=NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${p_cell}
    ...            parameter=physCellId  alias=${oam_alias}
    RETURN  ${physCellId_pcell}  @{physCellId_scell}

Check Scell Addition
    [Arguments]    ${tcp_file}  ${physCellId}  ${band_scell}=${freq_scell}  ${packet_filter}=${PROTOCOL_NAME}.procedureCode ==7
    ${found_scells}  Create List
    ${found_bands}   Create List
    ${output}       ute_tshark.read pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${tcp_file}
    ${cell_type}    Evaluate     type($physCellId).__name__
    ${physCellId}   IF  "list" in "${cell_type}"  set variable  ${physCellId}
    ...             ELSE   split string  ${physCellId}  ,
    sort list  ${physCellId}
    Log to console  \n arguments: phycellid: ${physCellId}
    ${band_type}    Evaluate     type($band_scell).__name__
    ${band_scell}   IF  "list" in "${band_type}"  set variable  ${band_scell}
    ...             ELSE      split string  ${band_scell}  ,
    sort list  ${band_scell}
    Log to console  arguments: band_scell: ${band_scell}
    ${length_scell}  Get Length  ${physCellId}
    ${ScellAdd}      Get Element count  ${output}    .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.physCellId']
    should be true  ${ScellAdd} >= ${length_scell}
    ${ScellAdd_elem}   Get elements  ${output}  .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.physCellId']
    ${ScellFreq_elem}  Get elements  ${output}  .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.FreqBandIndicatorNR']
    Should not be empty  ${ScellAdd_elem}
    Should not be empty  ${ScellFreq_elem}
    Log to Console   Checking SCell addition
    FOR  ${i}   IN   @{ScellAdd_elem}
	 ${value}    Get element attribute    ${i}    show
	 Log to Console  found scell: ${value}
	 append to list  ${found_scells}  ${value}
    END
    ${unique_list}  remove duplicates  ${found_scells}
    sort list  ${unique_list}
    Lists should be equal    ${physCellId}  ${unique_list}
    FOR  ${i}   IN   @{ScellFreq_elem}
         ${value}     Get element attribute    ${i}    show
         Log to Console   found SCell frequency: ${value}
	 append to list  ${found_bands}  ${value}
    END
    ${unique_bands}  remove duplicates  ${found_bands}
    ${unique_bands_expected}  remove duplicates  ${band_scell}
    sort list  ${unique_bands}
    Lists should be equal    ${unique_bands_expected}  ${unique_bands}

Check Pcell Addition
    [Arguments]    ${band_pcell}  ${tcp_file}  ${physCellId}  ${packet_filter}=${PROTOCOL_NAME}.procedureCode ==7
    ${output}    ute_tshark.read pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${tcp_file}
    ${PcellAdd_elem}    Get elements    ${output}     .//field[@name='nr-rrc.spCellConfig_element']//field[@name='nr-rrc.physCellId']
    ${PcellFreq_elem}    Get elements    ${output}    .//field[@name='nr-rrc.spCellConfig_element']//field[@name='nr-rrc.FreqBandIndicatorNR']
    Should not be empty  ${PcellAdd_elem}
    Should not be empty  ${PcellFreq_elem}

    Log to Console   The PCell is:
    FOR  ${i}   IN   @{PcellAdd_elem}
         ${showname}     Get element attribute    ${i}    showname
         Log to Console   PCell ${showname}
         Should Contain Any  ${showname}  ${physCellId}  msg=Wrong physCellId
    END

    FOR  ${i}   IN   @{PcellFreq_elem}
         ${show}     Get element attribute    ${i}    show
         Log to Console   PCell frequency: ${show}
         IF   '${show}' == '${band_pcell}'  set test variable    ${Flag}     True
         ...    ELSE       Fail     Wrong Frequency
    END

Check Pcell Swap
    [Arguments]    ${freq_scell}    ${tcp_file}   ${physCellId}   ${packet_filter}=${PROTOCOL_NAME}.procedureCode ==12
    ${scells_freq}  split string  ${freq_scell}  ,
    ${s_cell_freq}  convert to string  ${scells_freq[1]}
    ${output}    ute_tshark.read pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${tcp_file}
    ${New_PcellAdd_elem}   Get elements  ${output}  .//field[@name='nr-rrc.spCellConfigCommon_element']//field[@name='nr-rrc.physCellId']
    ${New_PcellFreq_elem}  Get elements  ${output}  .//field[@name='nr-rrc.spCellConfigCommon_element']//field[@name='nr-rrc.FreqBandIndicatorNR']

    Should not be empty  ${New_PcellAdd_elem}
    Log to Console   The PCell after swap is:
    FOR  ${i}   IN   @{New_PcellAdd_elem}
         ${showname}     Get element attribute    ${i}    showname
         Log to Console   PCell ${showname}
         Should Contain  ${showname}   ${physCellId[0]}  msg=Wrong Scell Swap
    END

    FOR  ${i}   IN   @{New_PcellFreq_elem}
         ${show}     Get element attribute    ${i}    show
         Log to Console   PCell frequency band: ${show}
         Should Contain  ${show}   ${s_cell_freq}  msg=Wrong Frequency

    END
