*** Settings ***
Documentation   Robot Verification for Carrier Aggregation
...             Team: MN RAN RD VRF ULM 2 \n
...             Email:  \n
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    ute_tshark
Library    String
Library    Collections
Library    XML

*** Variables ***
${SCELL_CONFIG}    will be set in kw Get Added SCell Info

*** Keywords ***
Check Scell Addition
    [Documentation]   This keyword checks the addition of Scells and their bandwidths for carrier aggregation
    [Arguments]    ${physCellId}  ${pcap_file}=${pcap_file}  ${band_scell}=${freq_scell}  ${packet_filter}=${PROTOCOL_NAME}.procedureCode ==7
    ${found_scells}  Create List
    ${found_bands}   Create List
    ${output}       ute_tshark.Read Pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${pcap_file}
    ${cell_type}    Evaluate     type($physCellId).__name__
    ${physCellId}   IF  "list" in "${cell_type}"  Set Variable  ${physCellId}
    ...             ELSE   String.Split String  ${physCellId}  ,
    Collections.Sort List  ${physCellId}
    Log To Console  \n arguments: phycellid: ${physCellId}
    ${band_type}    Evaluate     type($band_scell).__name__
    ${band_scell}   IF  "list" in "${band_type}"  Set Variable  ${band_scell}
    ...             ELSE      String.Split String  ${band_scell}  ,
    Collections.Sort List  ${band_scell}
    Log To Console  arguments: band_scell: ${band_scell}
    ${length_scell}  Get Length  ${physCellId}
    ${ScellAdd}      Get Element Count  ${output}    .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.physCellId']
    Should Be True  ${ScellAdd} >= ${length_scell}
    ${ScellAdd_elem}   Get Elements  ${output}  .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.physCellId']
    ${ScellFreq_elem}  Get Elements  ${output}  .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.FreqBandIndicatorNR']
    Should Not Be Empty  ${ScellAdd_elem}
    Should not be empty  ${ScellFreq_elem}
    Log To Console   Checking SCell addition
    FOR  ${i}   IN   @{ScellAdd_elem}
        ${value}    Get element attribute    ${i}    show
        Log To Console  found scell: ${value}
        Collections.Append To List  ${found_scells}  ${value}
    END
    ${unique_list}  Collections.Remove Duplicates  ${found_scells}
    Collections.Sort List  ${unique_list}
    Collections.Lists should be equal    ${physCellId}  ${unique_list}
    FOR  ${i}   IN   @{ScellFreq_elem}
         ${value}     Get Element Attribute    ${i}    show
         Log to Console   found SCell frequency: ${value}
         Collections.Append To List  ${found_bands}  ${value}
    END
    ${unique_bands}  Collections.Remove Duplicates  ${found_bands}
    ${unique_bands_expected}  remove duplicates  ${band_scell}
    Sort list  ${unique_bands}
    Lists Should Be Equal    ${unique_bands_expected}  ${unique_bands}


Mapping Of sCellIndex And physCellId
    [Documentation]   This keyword checks the addition of Scells and their bandwidths for carrier aggregation
    [Arguments]    ${pcap_file}=${pcap_file}
    ...            ${packet_filter}=(nr-rrc.physCellId == ${filter_sCell}) && (nokiaf1ap.sCellIndex == 1)
    ${found_sCellIndex}  Create List
    ${found_physCellId}  Create List

    ${output}       ute_tshark.Read Pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${pcap_file}

    ${sCellIndex_elems}   XML.Get Elements  ${output}  .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.sCellIndex']
    ${physCellId_elems}   XML.Get Elements  ${output}  .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.physCellId']
    Should Not Be Empty  ${sCellIndex_elems}
    Should Not Be Empty  ${physCellId_elems}
    FOR  ${sCellIndex_elem}   IN   @{sCellIndex_elems}
        ${value}    XML.Get Element Attribute    ${sCellIndex_elem}    show
        Log To Console  found sCellIndex: ${value}
        Collections.Append To List  ${found_sCellIndex}  ${value}
    END
    FOR  ${physCellId_elem}   IN   @{physCellId_elems}
        ${value}    XML.Get Element Attribute    ${physCellId_elem}    show
        Log To Console  found physCellId: ${value}
        Collections.Append To List  ${found_physCellId}  ${value}
    END

    ${len_found_physCellId}=  Get Length  ${found_physCellId}
    ${len_found_sCellIndex}=  Get Length  ${found_sCellIndex}
    IF  ${len_found_physCellId} != ${len_found_sCellIndex}
        BuiltIn.Log To Console    found_physCellId and found_sCellIndex lists are of unequal length. Please check!
    END
    ${physCellId_sCellIndex_mapping}     Create Dictionary
    FOR  ${key}  ${value}  IN ZIP  ${found_physCellId}  ${found_sCellIndex}
       Set To Dictionary    ${physCellId_sCellIndex_mapping}  ${key}  ${value}
    END
    Log To Console  ${physCellId_sCellIndex_mapping}
    RETURN    ${physCellId_sCellIndex_mapping}


Extract ScellIndex From physCellId_sCellIndex_mapping
    [Arguments]    ${physCellId_tobeextracted}=${physCellId_tobeextracted}  ${pcap_file}=${pcap_file}
    ${physCellId_sCellIndex_mapping}=    Mapping Of sCellIndex And physCellId  pcap_file=${pcap_file}
    ${extracted_sCellIndex}=    Collections.Get From Dictionary  ${physCellId_sCellIndex_mapping}  ${physCellId_tobeextracted}
    RETURN    ${extracted_sCellIndex}

Get Added SCell Info
    [DOCUMENTATION]
    ...   extracts sCellToAddModList from pcap file, creates dictionary with scell infos
    ...   values can be reached with syntax: ${SCELL_CONFIG}[physcellid][parameter]
    ...   | pcap_file | wireshark file  |
    ...   | packet_filter | filter for wireshark trace |
    ...   output dictionary structure:
    ...   <physicalCellId>: scellindex: 123,
    ...                     phycellid: 456,
    ...                     operationalmode: dlAndUl | dlOnly,
    ...                     ulfreq: zzz
    ...
    [Arguments]    ${pcap_file}=${pcap_file}
    ...            ${packet_filter}=nokiaf1ap.procedureCode==12
    ${root}       ute_tshark.Read Pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${pcap_file}
    &{SCELL_CONFIG}  Create Dictionary
    Set Test Variable  ${SCELL_CONFIG}
    ${scell_list}  XML.Get Elements   ${root}  *//field[@name="nr-rrc.sCellToAddModList"]
    ${scell}  set variable  ${scell_list[0]}
    ${counter}  XML.Get Element Attribute  ${scell}  show
    FOR  ${i}  IN RANGE  ${counter}
	&{temp_dict}  Create Dictionary
	${scellindex}  XML.Get Element Attribute   ${scell}  show  ./field[@show="Item ${i}"]//field[@name="nr-rrc.sCellIndex"]
	${phycellid}  XML.Get Element Attribute   ${scell}  show  ./field[@show="Item ${i}"]//field[@name="nr-rrc.physCellId"]
	${ulfreq_string}  Set Variable  ./field[@show="Item ${i}"]//field[@showname="uplinkConfigCommon"]//field[@name="nr-rrc.absoluteFrequencyPointA"]
        TRY
             ${ulfreq}  XML.Get Element Attribute   ${scell}  show  ${ulfreq_string}
	     ${operationalMode}  Set Variable  dlAndUl
        EXCEPT
	     ${ulfreq}  Set Variable  NA
	     ${operationalMode}  Set Variable  dlOnly
	END
	Collections.Set To Dictionary  ${temp_dict}  scellindex=${scellindex}  phycellid=${phycellid}  operationalmode=${operationalMode}  ulfreq=${ulfreq}
	Collections.Set To Dictionary  ${SCELL_CONFIG}  ${phycellid}=&{temp_dict}
    END
   Log Dictionary  ${SCELL_CONFIG}
   RETURN  ${SCELL_CONFIG}
