*** Settings ***
Documentation   Robot Verification keywords for feature CB012121
...             Team: 'MN 5G&SC PZ ULM 2 SqdGp63' \n
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_63@nokia.com' \n
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    ute_tshark
Library    XML  use_lxml=True
Library    CB012121_timer.py

Resource   ../../resources/Common/tcpdump.robot


*** Variables ***
${packet_filter_CellTrace}         (nr-rrc.measId)&&(nr-rrc.ssb_Index)


*** Keywords ***
Convert PCAP2PDML
    [Documentation]    Convert tracing file from pcap to pdml
    [Arguments]    ${tcp_file}
    ute_tshark.Read Pcap And Save To File    output_type=pdml  pcap_file_path=${resultTestDir}/${tcp_file}.pcap
    ...    filename=${resultTestDir}/${tcp_file}.pdml
    Set Test Variable    ${pcap_file}    ${resultTestDir}/${tcp_file}.pcap
    Set Test Variable    ${pdml_file}    ${resultTestDir}/${tcp_file}.pdml


Verify HandOver Scenario
    [Documentation]   Check A3 reports and based on it check selected target cell for HO
    ...               Check RRC reconfiguration is sent to the UE with reconfigurationWithSync including targetPhysCellId - the new PCell for UE
    ...               Check RACH-ConfigDedicated IE in the CellGroupConfig IE is included in the RRC Reconfiguration
    ...               Check UE perform RLC re-establishment, HO is successful and data traffic after HO isn’t suspended and
    ...               degraded (none of the packets are lost)
    [Arguments]    ${pcap_file}  ${HO_required}
    ${XNAP}=  tcpdump.Get XNAP Protocol Version  ${pcap_file}
    Set Suite Variable  ${XNAP}
    CB012121_verification.Check HandoverRequest Cause  pcap_file=${pcap_file}  HO_required=${HO_required}
    CB012121_verification.Check HandoverRequest RadioNetwork  pcap_file=${pcap_file}   HO_required=${HO_required}
    CB012121_verification.Check HandoverAcknowledge  pcap_file=${pcap_file}
    CB012121_verification.Check SNSStatusTranfer Message  pcap_file=${pcap_file}
    CB012121_verification.Check UEContextRelease Message  pcap_file=${pcap_file}
    CB012121_verification.Check PathSwitchRequest Message  pcap_file=${pcap_file}
    CB012121_verification.Check PathSwitchRequestAck Message  pcap_file=${pcap_file}


Check HandoverRequest Cause
    [Arguments]    ${pcap_file}  ${HO_required}
    ${output}  ute_tshark.Read Pcap  packet_filter=(${XNAP}.procedureCode == 0)&&!(tcp.port==49148)  output_type=pdml  pcap_file_path=${pcap_file}
    ${cause}  XML.Get Elements    ${output}    .//field[@name='${XNAP}.HandoverRequest_element']//field[@name='${XNAP}.Cause']
    ${status_list}    Create List
    FOR  ${i}  IN   @{cause}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        ${status}  Run Keyword And Return Status   Should Contain  ${showname}  radioNetwork
        IF   not ${status}
             Fail   HO Cause not radioNetwork
        ELSE
             Collections.Append To List   ${status_list}    ${status}
        END
    END
    ${HO_No}=  Get Length   ${status_list}
    IF   ${HO_No} != ${HO_required}   Fail   ${HO_required} HO request meessage expected but only got ${HO_No}


Check HandoverRequest RadioNetwork
    [Arguments]    ${pcap_file}  ${HO_required}
    ${output}    ute_tshark.Read Pcap    packet_filter=(${XNAP}.procedureCode == 0)&&!(tcp.port==49148)
    ...    output_type=pdml    pcap_file_path=${pcap_file}
    ${radioNetwork}    XML.Get Elements    ${output}    .//field[@name='${XNAP}.HandoverRequest_element']//field[@name='${XNAP}.radioNetwork']
    ${status_list}    Create List
    FOR  ${i}  IN   @{radioNetwork}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        ${status}  Run Keyword And Return Status   Should Contain  ${showname}  handover-desirable-for-radio-reasons
        IF   not ${status}
             Fail   radioNetwork reason not handover-desirable-for-radio-reasons
        ELSE
             Collections.Append To List   ${status_list}    ${status}
        END
    END
    ${HO_No}=  Get length   ${status_list}
    IF   ${HO_No} != ${HO_required}   Fail   2 HO request meessage expected but got ${HO_No}


Check HandoverAcknowledge
    [Arguments]    ${pcap_file}
    ${output}    ute_tshark.Read Pcap    packet_filter=(${XNAP}.procedureCode == 0)&&!(tcp.port==49148)
    ...    output_type=pdml    pcap_file_path=${pcap_file}
    ${releasecomplete}    XML.Get Element Count
    ...  ${output}    .//field[@name='${XNAP}.successfulOutcome_element']//field[@showname='HandoverRequestAcknowledge']
    Should Be True  ${releasecomplete} > ${0}


Check SNSStatusTranfer Message
    [Arguments]    ${pcap_file}
    ${output}    ute_tshark.Read Pcap    packet_filter=(${XNAP}.procedureCode == 1)&&!(tcp.port==49148)
    ...    output_type=pdml    pcap_file_path=${pcap_file}
    ${SNStatusTransfer}    XML.Get Element Count    ${output}    .//field[@name='${XNAP}.SNStatusTransfer_element']
    Should Be True  ${SNStatusTransfer} > ${0}


Check UEContextRelease Message
    [Arguments]    ${pcap_file}
    ${output}    ute_tshark.Read Pcap    packet_filter=(${XNAP}.procedureCode == 6)&&!(tcp.port==49148)
    ...    output_type=pdml    pcap_file_path=${pcap_file}
    ${UEContextRelease}    XML.Get Element Count    ${output}    .//field[@name='${XNAP}.UEContextRelease_element']
    Should Be True  ${UEContextRelease} > ${0}


Check PathSwitchRequest Message
    [Arguments]    ${pcap_file}
    ${output}    ute_tshark.Read Pcap    packet_filter=ngap.procedureCode == 25    output_type=pdml    pcap_file_path=${pcap_file}
    ${PathSwitchRequest}    XML.Get Element Count    ${output}    .//field[@name='ngap.PathSwitchRequest_element']
    Should Be True  ${PathSwitchRequest} > ${0}


Check PathSwitchRequestAck Message
    [Arguments]    ${pcap_file}
    ${output}    ute_tshark.Read Pcap    packet_filter=ngap.procedureCode == 25    output_type=pdml    pcap_file_path=${pcap_file}
    ${PathSwitchRequestAck}    XML.Get Element Count
    ...  ${output}    .//field[@showname='successfulOutcome']//field[@name='ngap.PathSwitchRequestAcknowledge_element']
    Should Be True  ${PathSwitchRequestAck} > ${0}


Check Wireshark For RRCReconfiguration
    [Arguments]    ${pcap_file}
    ${output}    ute_tshark.Read Pcap    packet_filter=nsetapx.asn1_MsgId == 172    output_type=pdml    pcap_file_path=${pcap_file}
    ${rrc_reconfig}=    Set Variable
    ...    .//field[@name='nr-rrc.c1']//field[@name='nr-rrc.rrcReconfiguration_element']
    ${rrc}    XML.Get Elements    ${output}   ${rrc_reconfig}
    FOR  ${i}  IN  @{rrc}
        ${showname}  XML.Get Element Attribute  ${rrc}  showname
        Should Contain  ${showname}  rrcReconfiguration
    END


Create Checklist And Compare Measurement Trigger, Serv Cell and NRCell
    [Arguments]    ${pcap_file}  ${ServCell}  ${NRCell}  ${eventTrigger}  ${counter}=none
    ${output}    ute_tshark.Read Pcap    packet_filter=(nsetapx.triggerType == 1 || nsetapx.triggerType == 2)
    ...    output_type=pdml    pcap_file_path=${pcap_file}

    ${Expected_Event_list}   Create List
    IF  '${NRCell}'!='none'
        Collections.Append To List  ${Expected_Event_list}
        ...    ${eventTrigger}-ServCell${ServCell}-NRCell${NRCell}
    ELSE
        Collections.Append To List  ${Expected_Event_list}
        ...        ${eventTrigger}-ServCell${ServCell}
    END

    ${triggerType}=    Set Variable
    ...    .//field[@name='nsetapx.triggerType']
    ${pci_ServCell}=    Set Variable
    ...  .//field[@name='nsetapx.measResultServingMos']//field[@name='nsetapx.MeasResultServingMo_element']//field[@name='nsetapx.pci']
    ${pci_NRCell}=    Set Variable
    ...  .//field[@name='nsetapx.measResultNeighCellsNR']//field[@name='nsetapx.MeasResultNeighCellNR_element']//field[@name='nsetapx.pci']

    Log To Console   Checking Events
    ${event}    XML.Get Elements    ${output}    ${triggerType}
    @{Event_list}   Create List
    @{Event_a2_list}  Create List
    FOR  ${i}  IN   @{event}
        ${showname}  XML.Get Element Attribute  ${i}  showname
        @{eventName}  STRING.Split String  ${showname}
        Log To Console  measurement event: ${showname} found
        Collections.Append To List  ${Event_list}  ${eventName[1]}
    END

    Log To Console   Checking PCI Serving Cell
    ${serving}    XML.Get Elements    ${output}    ${pci_ServCell}
    FOR  ${index}  ${i}  IN ENUMERATE  @{serving}
        ${show}     XML.Get Element Attribute  ${i}  show
        Log To Console    PCI Serving Cell: ${show}
        Collections.Set List Value  ${Event_list}  ${index}  ${Event_list[${index}]}-ServCell${show}
    END

    ${a2_matches}  Get Matches  ${Event_list}  a2-*
    FOR  ${i}  IN   @{a2_matches}
        ${unusedEvents}  Collections.Get Index From List  ${Event_list}  ${i}
        Collections.Append To List  ${Event_a2_list}  ${i}
        Collections.Remove From List   ${Event_list}  ${unusedEvents}
    END

    Log To Console   Checking PCI Neighbouring Cell
    ${neighbouring}    XML.Get Elements    ${output}    ${pci_NRCell}
    FOR  ${index}  ${i}  IN ENUMERATE  @{neighbouring}
        ${show}     XML.Get Element Attribute  ${i}  show
        Log To Console    PCI Neighbouring Cell: ${show}
        Collections.Set List Value  ${Event_list}  ${index}  ${Event_list[${index}]}-NRCell${show}
    END

    ${Event_full_list}  Collections.Combine Lists   ${Event_list}   ${Event_a2_list}

    Log List  ${Event_list}
    IF    'CB012121_A_05' in ${TEST TAGS}
        Verification of Event_List for CB012121_A_05  Event_list=${Event_full_list}
        ...                                           Expected_Event_list=${Expected_Event_list}
    ELSE IF  'CB012121_B_01' in ${TEST TAGS}
        Verification of Event_List for CB012121_B_01  Event_list=${Event_full_list}
        ...                                           Expected_Event_list=${Expected_Event_list}
        ...                                           counter=${counter}
    END

Verification Of Event_List For CB012121_A_05
    [Arguments]    ${Event_list}    ${Expected_Event_list}
    @{Result_list}  Collections.Remove Duplicates  ${Event_list}
    Collections.Log List  ${Result_list}
    Collections.List Should Contain Sub List  ${Result_list}  ${Expected_Event_list}


Verification Of Event_List For CB012121_B_01
    [Arguments]    ${Event_list}  ${Expected_Event_list}  ${counter}
    FOR  ${index}  ${i}  IN ENUMERATE  @{Expected_Event_list}
        ${x}=  Collections.Count Values In List  ${Event_list}  ${Expected_Event_list[${index}]}
        Should Be Equal  ${x}  ${counter}
    END

Verification Of Event Checklist For CB012121_A_05
    [Arguments]    ${pcap_file}
    FOR  ${ServCell}  ${NRCell}  ${eventTrigger}  ${counter}  IN
    ...    ${physCellIdSource}  none  a2  ${1}
    ...    ${physCellIdSource}  ${physCellIdTarget1}  a3  ${1}
    ...    ${physCellIdSource}  ${physCellIdTarget2}  a3  ${1}
    ...    ${physCellIdTarget2}  none  a2  ${1}
    ...    ${physCellIdTarget2}  ${physCellIdSource}  a3  ${1}
           CB012121_verification.Create checklist and compare measurement trigger, Serv Cell and NRCell
           ...    ServCell=${ServCell}  NRCell=${NRCell}  eventTrigger=${eventTrigger}  pcap_file=${pcap_file}
    END


Verification Of Event Checklist For CB012121_B_01
    [Arguments]    ${pcap_file}
    FOR  ${ServCell}  ${NRCell}  ${eventTrigger}  ${counter}  IN
    ...    ${physCellIdSource}  none  a2  ${1}
    ...    ${physCellIdSource}  ${physCellIdTarget1}  a3  ${4}
    ...    ${physCellIdSource}  ${physCellIdTarget2}  a3  ${1}
           CB012121_verification.Create checklist and compare measurement trigger, Serv Cell and NRCell
           ...    ServCell=${ServCell}  NRCell=${NRCell}  eventTrigger=${eventTrigger}  counter=${counter}  pcap_file=${pcap_file}
    END


Check If NRREL Object Was Created
    [Arguments]    ${cell_id}  ${nrrel_id}
    gnb.Get SCF from GNB    gnb_id=${0}    target_dir=${configSuiteDir}  scf_name=SCF_gnb0_NRREL.xml
    XML.Element Should Exist
    ...  source=${configSuiteDir}/SCF_gnb0_NRREL.xml
    ...  xpath=.//managedObject[@distName='MRBTS-${nrbts_id_0}/NRBTS-${nrbts_id_0}/NRCELL-${cell_id}/NRREL-${nrrel_id}']


Verify Successful CGICell In PCMD
    [Arguments]    ${pcap_file}
    ${output}    ute_tshark.Read Pcap    packet_filter=nsetapx.asn1_MsgId == 162    output_type=pdml    pcap_file_path=${pcap_file}
    @{Cell_list}   Create List

    ${reportType_path}=    Set Variable
    ...    .//field[@name='nr-rrc.reportType']//field[@name='nr-rrc.reportCGI_element']//field[@name='nr-rrc.cellForWhichToReportCGI']
    ${reportTypeCells}    XML.Get Elements    ${output}    ${reportType_path}
    FOR  ${index}  ${reportTypeCell}  IN ENUMERATE  @{reportTypeCells}
         ${show}  XML.Get Element Attribute  ${reportTypeCell}  show
         Log To Console  cellForWhichToReportCGI: ${show} found
         Collections.Append To List  ${Cell_list}  ${show}
    END
    Collections.List Should Contain Value  ${Cell_list}  ${physCellIdTarget2}


Verify Successful IntraGNBHoSrcRecord in PCDM
    [Arguments]    ${pcap_file}
    ${output}    ute_tshark.Read Pcap    packet_filter=nsetapx.intragNBHoSrcRecord == 0    output_type=pdml    pcap_file_path=${pcap_file}

    ${intragNBHoSrcRecord_path}=    Set Variable
    ...     .//field[@name='nsetapx.intragNBHoSrcRecord']//field[@name='nsetapx.data_element']//field[@name='nsetapx.result']
    ${intragnb_elems}    XML.Get Elements    ${output}    ${intragNBHoSrcRecord_path}
    FOR  ${intragnb_elem}  IN  @{intragnb_elems}
        ${showname}  XML.Get Element Attribute  ${intragnb_elem}  showname
        Should Contain  ${showname}  result: success (0)
    END

    ${mobilityReason_path}=    Set Variable
    ...     .//field[@name='nsetapx.intragNBHoSrcRecord']//field[@name='nsetapx.data_element']//field[@name='nsetapx.mobilityReason']
    ${mobilityReason_elems}    XML.Get Elements    ${output}   ${mobilityReason_path}
    FOR  ${mobilityReason}  IN  @{mobilityReason_elems}
        ${showname}  XML.Get Element Attribute  ${mobilityReason}  showname
        Should Contain  ${showname}  mobilityReason: radioCondition
    END


Verify Successful XnHoTgtRecord in PCDM
    [Arguments]    ${pcap_file}
    ${output}    ute_tshark.Read Pcap    packet_filter=nsetapx.xnHoTgtRecord == 0    output_type=pdml    pcap_file_path=${pcap_file}

    ${xnHoTgtRecord_path}=    Set Variable
    ...     .//field[@name='nsetapx.xnHoTgtRecord']//field[@name='nsetapx.data_element']//field[@name='nsetapx.result']
    ${intergnb_elems}    XML.Get Elements    ${output}    ${xnHoTgtRecord_path}
    FOR  ${intergnb_elem}  IN  @{intergnb_elems}
        ${showname}  XML.Get Element Attribute  ${intergnb_elem}  showname
        Should Contain  ${showname}  result: success (0)
    END
I

Verify Cgi-Info In MeasurementReport
    [Arguments]    ${pcap_file}
    ${output}    ute_tshark.Read Pcap    packet_filter=nsetapx.asn1_MsgId == 172    output_type=pdml    pcap_file_path=${pcap_file}

    ${cgiinfo_path}=    Set Variable
    ...     .//field[@name='nr-rrc.MeasResultNR_element']//field[@name='nr-rrc.cgi_Info_element']
    ${cgiinfo_elems}    XML.Get Elements    ${output}   ${cgiinfo_path}
    FOR  ${cgiinfo_elem}  IN  @{cgiinfo_elems}
        ${showname}  XML.Get Element Attribute  ${cgiinfo_elem}  showname
        Should Contain  ${showname}  cgi-Info
    END


Verification For CB012121_A_TC05
    [Arguments]    ${tcp_files}
    @{tcp_file_list}  STRING.Split String  ${tcp_files}  ,

    FOR  ${tcp_file_elem}  IN  @{tcp_file_list}
        CB012121_verification.Convert PCAP2PDML    tcp_file=${tcp_file_elem}
        CB012121_verification.Verify HandOver Scenario    pcap_file=${pcap_file}  HO_required=${2}
        CB012121_verification.Verification of event checklist for CB012121_A_05  pcap_file=${pcap_file}
        Timediff Between a3 And Handover Should Be Greater Than Max Value   file_name=${pdml_file}
    END


Verification For CB012121_A_TC11
    [Arguments]    ${tcp_file}
    CB012121_verification.Convert PCAP2PDML    tcp_file=${tcp_file}
    CB012121_verification.Check If NRREL Object Was Created  cell_id=${3}  nrrel_id=${256}
    CB012121_verification.Verify Cgi-Info In MeasurementReport  pcap_file=${pcap_file}
    CB012121_verification.Verify Successful CGICell in PCMD  pcap_file=${pcap_file}
    CB012121_verification.Verify Successful IntraGNBHoSrcRecord in PCDM  pcap_file=${pcap_file}


Verification For CB012121_B_TC01
    [Arguments]    ${tcp_file}
    CB012121_verification.Convert PCAP2PDML    tcp_file=${tcp_file}
    CB012121_verification.Verify HandOver Scenario    pcap_file=${pcap_file}  HO_required=${1}
    CB012121_verification.Verification Of Event Checklist For CB012121_B_01  pcap_file=${pcap_file}


Verification For CB012121_B_TC11
    [Arguments]    ${tcp_file}
    CB012121_verification.Convert PCAP2PDML    tcp_file=${tcp_file}
    CB012121_verification.Check If NRREL Object Was Created  cell_id=${1}  nrrel_id=${256}
    CB012121_verification.Verify HandOver Scenario    pcap_file=${pcap_file}  HO_required=${1}
    CB012121_verification.Verify Cgi-Info In MeasurementReport  pcap_file=${pcap_file}
    CB012121_verification.Verify Successful CGICell In PCMD  pcap_file=${pcap_file}
    CB012121_verification.Verify Successful XnHoTgtRecord In PCDM  pcap_file=${pcap_file}
