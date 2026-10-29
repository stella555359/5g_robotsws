*** Settings ***
Documentation   Robot Verification keywords for feature CB014009-AA
...             Team: I_MN_RAN_RD_VRF_ULM_VT2 \n
...             Email: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com \n
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.hw.rf_attenuator               WITH NAME    attenuator
Library    ute_tshark
Library  XML  use_lxml=True

Resource    ../resources/sqd63/verification.robot
Resource    ../resources/carrier_aggregation_verification.robot


*** Keywords ***
Convert PCAP2PDML
    [Documentation]    Convert tracing file from pcap to pdml
    [Arguments]    ${tcp_file}
    ute_tshark.Read Pcap And Save To File    output_type=pdml  pcap_file_path=${resultTestDir}/${tcp_file}.pcap
    ...    filename=${resultTestDir}/${tcp_file}.pdml
    Set Test Variable    ${pcap_file}    ${resultTestDir}/${tcp_file}.pcap
    Set Test Variable    ${pdml_file}    ${resultTestDir}/${tcp_file}.pdml

Verification for CB014009_TC01
    [Arguments]    ${tcp_files}
    @{tcp_file_list}  String.Split String  ${tcp_files}  ,

    FOR  ${tcp_file_elem}  IN  @{tcp_file_list}
        CB014009_verification.Convert PCAP2PDML    tcp_file=${tcp_file_elem}
    END

    ${status_TC01_Part1}=    Run Keyword And Return Status    Verification For CB014009_TC01 Part1
    ${status_TC01_Part2}=    Run Keyword And Return Status    Verification For CB014009_TC01 Part2
    ${status_TC01_Part3}=    Run Keyword And Return Status    Verification For CB014009_TC01 Part3

    Log To Console    \nStatus TC01 Verification Part 1: ${status_TC01_Part1}
    Log To Console    \nStatus TC01 Verification Part 2: ${status_TC01_Part2}
    Log To Console    \nStatus TC01 Verification Part 3: ${status_TC01_Part3}

    IF    ${status_TC01_Part1} and ${status_TC01_Part2} and ${status_TC01_Part3}
        Set Test Variable    ${status_verification_TC}    ${True}
    ELSE
        Set Test Variable    ${status_verification_TC}    ${False}
    END

    Log To Console    \nStatus Verification TC01: ${status_verification_TC}


Verification For CB014009_TC01 Part1
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB014009_TC01_Part1.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=41,41,25,66,77
    ...  physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2},${physCellIdSourceScell3},${physCellIdSourceScell4},${physCellIdSourceScell5}
    Check BufferMonitoring Should Contain ca-activate-dl And TriggerType Equal a1  pcap_file=${pcap_file}
    Counted BufferMonitoring messages should be true  pcap_file=${pcap_file}  BufferMonitoring_counter=${4}
    Check SCellInactiveReason Should Contain bad-radio-link-quality  pcap_file=${pcap_file}  bad_Scell_ids=5,5,3
    Check BufferCriterionNotification Should Be Downlink  pcap_file=${pcap_file}  bufferCriterion_Counter=${4}

Verification For CB014009_TC01 Part2
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB014009_TC01_Part2.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=41,41,25,77
    ...  physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2},${physCellIdSourceScell3},${physCellIdSourceScell5}
    Check BufferMonitoring Should Contain ca-activate-dl And TriggerType Equal a1  pcap_file=${pcap_file}
    Counted BufferMonitoring messages should be true  pcap_file=${pcap_file}  BufferMonitoring_counter=${4}
    Check BufferMonitoring Should Contain ca-deactivate-dl  pcap_file=${pcap_file}  physCellId=${physCellIdSourcePCell}
    Check SCellInactiveReason Should Contain bad-radio-link-quality  pcap_file=${pcap_file}  bad_Scell_ids=4,4,3
    Check BufferCriterionNotification Should Be Downlink  pcap_file=${pcap_file}  bufferCriterion_Counter=${4}


Verification For CB014009_TC01 Part3
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB014009_TC01_Part3.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=41,41,77
    ...  physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2},${physCellIdSourceScell5}
    Check BufferMonitoring Should Contain ca-activate-dl And TriggerType Equal a1  pcap_file=${pcap_file}
    Counted BufferMonitoring messages should be true  pcap_file=${pcap_file}  BufferMonitoring_counter=${4}
    Check BufferMonitoring Should Contain ca-deactivate-dl  pcap_file=${pcap_file}  physCellId=${physCellIdSourcePCell}
    Check BufferCriterionNotification Should Be Downlink  pcap_file=${pcap_file}  bufferCriterion_Counter=${4}
    Check SCellInactiveReason Should Contain bad-radio-link-quality  pcap_file=${pcap_file}  bad_Scell_ids=3,3,2

##############################################################

Verification for CB014009_TC02
    [Arguments]    ${tcp_files}
    @{tcp_file_list}  String.Split String  ${tcp_files}  ,

    FOR  ${tcp_file_elem}  IN  @{tcp_file_list}
        CB014009_verification.Convert PCAP2PDML    tcp_file=${tcp_file_elem}
    END

    ${status_TC02_Part1}=    Run Keyword And Return Status    Verification For CB014009_TC02 Part1
    ${status_TC02_Part2}=    Run Keyword And Return Status    Verification For CB014009_TC02 Part2
    ${status_TC02_Part3}=    Run Keyword And Return Status    Verification For CB014009_TC02 Part3

    Log To Console    \nStatus TC02 Verification Part 1: ${status_TC02_Part1}
    Log To Console    \nStatus TC02 Verification Part 2: ${status_TC02_Part2}
    Log To Console    \nStatus TC02 Verification Part 3: ${status_TC02_Part3}

    IF    ${status_TC02_Part1} and ${status_TC02_Part2} and ${status_TC02_Part3}
        Set Test Variable    ${status_verification_TC}    ${True}
    ELSE
        Set Test Variable    ${status_verification_TC}    ${False}
    END

    Log To Console    \nStatus Verification TC02: ${status_verification_TC}

# Has to be cross checked with secification

Verification For CB014009_TC02 Part1
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB014009_TC02_Part1.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=41,41,25,66,77
    ...  physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2},${physCellIdSourceScell3},${physCellIdSourceScell4},${physCellIdSourceScell5}
    Check BufferMonitoring Should Contain ca-activate-dl And TriggerType Equal a1  pcap_file=${pcap_file}
    Counted BufferMonitoring messages should be true  pcap_file=${pcap_file}  BufferMonitoring_counter=${4}
    Check SCellInactiveReason Should Contain bad-radio-link-quality  pcap_file=${pcap_file}  bad_Scell_ids=5,5,3
    Check BufferCriterionNotification Should Be Downlink  pcap_file=${pcap_file}  bufferCriterion_Counter=${4}

Verification For CB014009_TC02 Part2
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB014009_TC02_Part2.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=41,41,25,77
    ...  physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2},${physCellIdSourceScell3},${physCellIdSourceScell5}
    Check BufferMonitoring Should Contain ca-activate-dl And TriggerType Equal a1  pcap_file=${pcap_file}
    Counted BufferMonitoring messages should be true  pcap_file=${pcap_file}  BufferMonitoring_counter=${4}
    Check BufferMonitoring Should Contain ca-deactivate-dl  pcap_file=${pcap_file}  physCellId=${physCellIdSourcePCell}
    Check SCellInactiveReason Should Contain bad-radio-link-quality  pcap_file=${pcap_file}  bad_Scell_ids=4,4,3
    Check BufferCriterionNotification Should Be Downlink  pcap_file=${pcap_file}  bufferCriterion_Counter=${4}


Verification For CB014009_TC02 Part3
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB014009_TC02_Part3.pcap
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=41,41,77
    ...  physCellId=${physCellIdSourceSCell1},${physCellIdSourceScell2},${physCellIdSourceScell5}
    Check BufferMonitoring Should Contain ca-activate-dl And TriggerType Equal a1  pcap_file=${pcap_file}
    Counted BufferMonitoring messages should be true  pcap_file=${pcap_file}  BufferMonitoring_counter=${4}
    Check BufferMonitoring Should Contain ca-deactivate-dl  pcap_file=${pcap_file}  physCellId=${physCellIdSourcePCell}
    Check BufferCriterionNotification Should Be Downlink  pcap_file=${pcap_file}  bufferCriterion_Counter=${4}
    Check SCellInactiveReason Should Contain bad-radio-link-quality  pcap_file=${pcap_file}  bad_Scell_ids=3,3,2

##############################################################

Verification for CB014009_TC03
    [Arguments]    ${tcp_files}
    @{tcp_file_list}  String.Split String  ${tcp_files}  ,

    FOR  ${tcp_file_elem}  IN  @{tcp_file_list}
        CB014009_verification.Convert PCAP2PDML    tcp_file=${tcp_file_elem}
    END


    Run Keyword And Warn On Failure  Verification For CB014009_TC03 Part1
    Run Keyword And Warn On Failure  Verification For CB014009_TC03 Part2
    Run Keyword And Warn On Failure  Verification For CB014009_TC03 Part3
    Run Keyword And Warn On Failure  Verification For CB014009_TC03 Part4


Verification For CB014009_TC03 Part1
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB014009_TC03_Part1.pcap
    Identification of Scell Index   pcap_file=${pcap_file}  filter_sCell=${physCellIdTargetScell1}
    #carrier_aggregation_verification.Mapping Of sCellIndex And physCellId  pcap_file=${pcap_file}  physCellId=${physCellIdTargetScell1}
    Check BufferMonitoring Should Contain ca-activate-dl  pcap_file=${pcap_file}  physCellId=${physCellIdSourcePCell}
    Check BufferCriterionNotification Should Be Downlink  pcap_file=${pcap_file}  bufferCriterion_Counter=${1}
    Check Ext GNB SCell Information List  pcap_file=${pcap_file}  items=${3}
    Check Ext SCell Information List For Specific SCellIndex or PhysCellId  pcap_file=${pcap_file}  sCell_id=${sCellIndex_SCell1}  scellInfo=${1}
    Check Ext SCell Information List For Specific SCellIndex or PhysCellId  pcap_file=${pcap_file}  sCell_id=${sCellIndex_SCell2}  scellInfo=${1}
    Check Ext SCell Information List For Specific SCellIndex or PhysCellId  pcap_file=${pcap_file}  sCell_id=${sCellIndex_SCell3}  scellInfo=${1}
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=25,66,78
    ...    physCellId=${physCellIdTargetSCell1},${physCellIdTargetScell2},${physCellIdTargetScell3}


Verification For CB014009_TC03 Part2
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB014009_TC03_Part2.pcap
    Identification of Scell Index   pcap_file=${pcap_file}  filter_sCell=${physCellIdTargetScell1}  num_Cells=${1}
    Check SCellInactiveReason Should Contain Inactivity-Timer  pcap_file=${pcap_file}  Scell_id=${sCellIndex_SCell1}
    Check BufferMonitoring Should Contain ca-activate-dl  pcap_file=${pcap_file}
    Check BufferCriterionNotification Should Be downlink  pcap_file=${pcap_file}  bufferCriterion_Counter=${2}
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=66,25,78
    ...    physCellId=${physCellIdTargetSCell1},${physCelIdTargetScell2},${physCellIdTargetScell3}


Verification For CB014009_TC03 Part3
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB014009_TC03_Part3.pcap
    Identification of Scell Index   pcap_file=${pcap_file}  filter_sCell=${physCellIdTargetScell1}  num_Cells=${2}
    Check SCellInactiveReason Should Contain Inactivity-Timer  pcap_file=${pcap_file}  Scell_id=${sCellIndex_SCell1}
    Check SCellInactiveReason Should Contain Inactivity-Timer  pcap_file=${pcap_file}  Scell_id=${sCellIndex_SCell2}
    Check BufferMonitoring Should Contain ca-activate-dl  pcap_file=${pcap_file}  physCellId=${physCellIdSourcePCell}
    Check BufferCriterionNotification Should Be downlink  pcap_file=${pcap_file}  bufferCriterion_Counter=${3}
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=25,66,78
    ...    physCellId=${physCellIdTargetSCell1},${physCellIdTargetScell2},${physCellIdTargetScell3}


Verification For CB014009_TC03 Part4
    [Arguments]    ${pcap_file}=${resultTestDir}/UE1_CB014009_TC03_Part4.pcap
    Identification of Scell Index   pcap_file=${pcap_file}  filter_sCell=${physCellIdTargetScell1}  num_Cells=${3}
    Check SCellInactiveReason Should Contain Inactivity-Timer  pcap_file=${pcap_file}  Scell_id=${sCellIndex_SCell1}
    Check SCellInactiveReason Should Contain Inactivity-Timer  pcap_file=${pcap_file}  Scell_id=${sCellIndex_SCell2}
    Check SCellInactiveReason Should Contain Inactivity-Timer  pcap_file=${pcap_file}  Scell_id=${sCellIndex_SCell3}
    Check BufferMonitoring Should Contain ca-activate-dl  pcap_file=${pcap_file}
    Check BufferCriterionNotification Should Be downlink  pcap_file=${pcap_file}  bufferCriterion_Counter=${1}
    carrier_aggregation_verification.Check Scell Addition  pcap_file=${pcap_file}  band_scell=66,25,78
    ...    physCellId=${physCellIdTargetSCell1},${physCellIdTargetScell2},${physCellIdTargetScell3}

##################################

Check BufferMonitoring Should Contain ca-activate-dl
    [Arguments]    ${pcap_file}  ${physCellId}=${None}

    IF    '${physCellId}' != '${None}'
        IF    '${physCellId}' != '${None}' and 'CB014009_TC03' in ${TEST TAGS}
         ${output}    ute_tshark.Read Pcap
        ...    packet_filter=(nokiaf1ap.BufferMonitoring==0) || (nr-rrc.physCellId==${physCellIdSourcePCell})
        ...    output_type=pdml    pcap_file_path=${pcap_file}
        ELSE
            ${output}    ute_tshark.Read Pcap
            ...    packet_filter=(nokiaf1ap.BufferMonitoring==0) || (nr-rrc.physCellId==${physCellIdSourcePCell}) && !(nr-rrc.sCellToAddModList)
            ...    output_type=pdml    pcap_file_path=${pcap_file}
        END
    ELSE
        ${output}    ute_tshark.Read Pcap    packet_filter=(nokiaf1ap.BufferMonitoring==0)
        ...    output_type=pdml    pcap_file_path=${pcap_file}
    END

    ${BufferMonitoring_path}=    Set Variable  .//field[@name='nokiaf1ap.BufferMonitoring']
    ${BufferMonitoring_elems}    XML.Get Elements  ${output}   ${BufferMonitoring_path}
    FOR  ${BufferMonitoring_elem}  IN  @{BufferMonitoring_elems}
        ${showname}    XML.Get Element Attribute  ${BufferMonitoring_elem}  showname
        Should Contain  ${showname}  BufferMonitoring: ca-activate-dl (0)
    END


Check BufferMonitoring Should Contain ca-deactivate-dl
    [Arguments]    ${pcap_file}  ${physCellId}=${None}

    IF    '${physCellId}' != '${None}'
        ${output}    ute_tshark.Read Pcap
        ...    packet_filter=(nokiaf1ap.BufferMonitoring==1) && (nr-rrc.physCellId==${physCellIdSourcePCell})
        ...    output_type=pdml    pcap_file_path=${pcap_file}
    ELSE
        ${output}    ute_tshark.read pcap    packet_filter=(nokiaf1ap.BufferMonitoring==1)
        ...    output_type=pdml    pcap_file_path=${pcap_file}
    END

    ${BufferMonitoring_path}=    Set Variable  .//field[@name='nokiaf1ap.BufferMonitoring']
    ${BufferMonitoring_elems}    XML.Get Elements  ${output}   ${BufferMonitoring_path}
    FOR  ${BufferMonitoring_elem}  IN  @{BufferMonitoring_elems}
        ${showname}    XML.Get Element Attribute  ${BufferMonitoring_elem}  showname
        Should Contain  ${showname}  BufferMonitoring: ca-deactivate-dl (1)
    END


Check BufferMonitoring Should Contain ca-activate-dl And TriggerType Equal a1
    [Arguments]    ${pcap_file}

    ${output}    ute_tshark.Read Pcap
    ...    packet_filter=(nokiaf1ap.BufferMonitoring==0) && (nsetapx.triggerType==0)
    ...    output_type=pdml    pcap_file_path=${pcap_file}

    ${BufferMonitoring_path}=    Set Variable  .//field[@name='nokiaf1ap.BufferMonitoring']
    ${BufferMonitoring_elems}    XML.Get Elements  ${output}   ${BufferMonitoring_path}
    ${triggerType}=              Set Variable  .//field[@name='nsetapx.triggerType']

    FOR  ${BufferMonitoring_elem}  IN  @{BufferMonitoring_elems}
        ${showname}    XML.get Element Attribute  ${BufferMonitoring_elem}  showname
        Should Contain  ${showname}  BufferMonitoring: ca-activate-dl (0)
    END

    ${event_elements}    XML.Get Elements    ${output}    ${triggerType}
    FOR  ${event_elem}  IN   @{event_elements}
        ${showname}  XML.Get Element Attribute  ${event_elem}  showname
        Should Contain  ${showname}  triggerType: a1 (0)
    END


Check If TriggerType a2 Was Detected For Pcell And Scells
    [Arguments]    ${pcap_file}  ${expected_servingPCI}

    ${output}    ute_tshark.Read Pcap
    ...    packet_filter=(nsetapx.triggerType==1)
    ...    output_type=pdml    pcap_file_path=${pcap_file}
    ${triggerType}=    Set Variable    .//field[@name='nsetapx.triggerType']

    ${event_elements}    XML.Get Elements    ${output}    ${triggerType}
    FOR  ${event_element}  IN   @{event_elements}
        ${showname}  XML.Get Element Attribute  ${event_element}  showname
        Should Contain  ${showname}  triggerType: a2 (1)
    END

    ${ueMeasRecord_path}=    Set Variable
    ...     .//field[@name='nsetapx.ueMeasRecord']//field[@name='nsetapx.data_r2_element']//field[@name='nsetapx.purpose']
    ${ueMeas_elems}    XML.Get Elements    ${output}    ${ueMeasRecord_path}
    FOR  ${ueMeas_elem}  IN  @{ueMeas_elems}
        ${showname}  XML.Get Element Attribute  ${ueMeas_elem}  showname
        Should Contain  ${showname}  purpose: carrierAggregation (5)
    END

    ${measResultServingMos_path}=    Set Variable
    ...    .//field[@name='nsetapx.ueMeasRecord']//field[@name='nsetapx.data_r2_element']//field[@name='nsetapx.measResultServingMos']
    ${measResultServingMos_elems}    XML.Get Elements    ${output}    ${measResultServingMos_path}
    FOR  ${measResultServingMos_elem}  IN  @{measResultServingMos_elems}
        ${showname}  XML.Get Element Attribute  ${measResultServingMos_elem}  showname
        Should Contain  ${showname}  measResultServingMos: 3 items
    END

    ${ServingPCI_list}    Create List
    ${ServingMoPCI_path}=    Set Variable
    ...    .//field[@name='nsetapx.measResultServingMos']//field[@name='nsetapx.MeasResultServingMo_element']//field[@name='nsetapx.pci']
    ${ServingMoPCI_elems}    XML.Get Elements    ${output}    ${ServingMoPCI_path}
    FOR  ${ServingMoPCI_elem}  IN  @{ServingMoPCI_elems}
        ${show}  XML.Get Element Attribute  ${ServingMoPCI_elem}  show
        Collections.Append To List  ${ServingPCI_list}  ${show}
    END

    @{expected_servingPCI_list}  String.Split String  ${expected_servingPCI}  ,
    @{Result_ServingPCI_list}  Collections.Remove Duplicates  ${ServingPCI_list}
    Collections.Log List  ${Result_ServingPCI_list}
    Collections.List Should Contain Sub List  ${Result_ServingPCI_list}  ${expected_servingPCI_list}


Counted BufferMonitoring Messages Should Be true
    [Arguments]    ${pcap_file}  ${BufferMonitoring_counter}  ${physCellId}=${None}

    IF    '${physCellId}' != '${None}'
        ${output}    ute_tshark.Read Pcap    packet_filter=(nokiaf1ap.BufferMonitoring==0) && (nr-rrc.physCellId==${physCellIdSourcePCell})
        ...    output_type=pdml    pcap_file_path=${pcap_file}
    ELSE
        ${output}    ute_tshark.read pcap    packet_filter=(nokiaf1ap.BufferMonitoring==0)
        ...    output_type=pdml    pcap_file_path=${pcap_file}
    END

    ${BufferMonitoring_path}=    Set Variable  .//field[@name='nokiaf1ap.BufferMonitoring']
    ${BufferMonitoring_counted}  Get Element Count  ${output}  ${BufferMonitoring_path}
    should be true  '${BufferMonitoring_counted}' == '${BufferMonitoring_counter}'


Check BufferCriterionNotification Should Be downlink
    [Arguments]    ${pcap_file}  ${bufferCriterion_Counter}
    ${output}    ute_tshark.Read Pcap    packet_filter=(nokiaf1ap.NokiaBufferCriterion==0)
    ...    output_type=pdml    pcap_file_path=${pcap_file}
    ${BufferCriterion_path}=    Set Variable  .//field[@name='nokiaf1ap.NokiaBufferCriterion']
    ${BufferCriterion_elems}    XML.Get elements  ${output}   ${BufferCriterion_path}
    FOR  ${BufferCriterion_elem}  IN  @{BufferCriterion_elems}
        ${showname}  XML.Get Element Attribute  ${BufferCriterion_elem}  showname
        Should Contain  ${showname}  BufferCriterion: ca-DL (0)
    END

    ${BufferCriterion_counted}  XML.Get Element Count  ${output}  ${BufferCriterion_path}
    Should Be true  '${bufferCriterion_Counter}' == '${BufferCriterion_counted}'


Check SCell Setup Index List Should Contain SCell-ToBeSetupMod-List
    [Arguments]    ${pcap_file}
    ${SCell_list}   Create List

    ${SCell_list_expected}   Create List
    ...    sCellIndex: 1
    ...    sCellIndex: 2
    ...    sCellIndex: 3
    ...    sCellIndex: 4
    Log To Console  ${SCell_list_expected}

    ${output}    ute_tshark.Read Pcap    packet_filter=(nokiaf1ap.SCell_ToBeSetupMod_List==4)
    ...    output_type=pdml    pcap_file_path=${pcap_file}
    ${SCell_ToBeSetupMod_path}=    Set Variable
    ...    .//field[@name='nokiaf1ap.SCell_ToBeSetupMod_List']
    ${SCell_ToBeSetupMod_elem}    XML.Get element  ${output}  ${SCell_ToBeSetupMod_path}
    ${showname}  XML.Get Element attribute  ${SCell_ToBeSetupMod_elem}  showname
    Should Contain  ${showname}  SCell-ToBeSetupMod-List: 4 items

    ${SCellIndexList_path}=    Set Variable
    ...    .//field[@name='nokiaf1ap.SCell_ToBeSetupMod_Item_element']//field[@name='nokiaf1ap.sCellIndex']
    ${SCellIndexList_elems}    XML.Get elements  ${output}  ${SCellIndexList_path}
    FOR  ${SCellIndexList_elem}  IN  @{SCellIndexList_elems}
        ${showname}  XML.Get Element attribute  ${SCellIndexList_elem}  showname
        Collections.Append to list  ${SCell_list}  ${showname}
    END
    Lists Should Be Equal  ${SCell_list}  ${SCell_list_expected}  ignore_order=True


Check SCellInactiveReason Should Contain bad-radio-link-quality
    [Arguments]    ${pcap_file}  ${bad_Scell_ids}

    ${output}    ute_tshark.Read Pcap    packet_filter=(nokiaf1ap.sCellInactiveReason == 2)
    ...    output_type=pdml    pcap_file_path=${pcap_file}

    ${SCellInactiveReason_path}=    Set Variable
    ...    .//field[@name='nokiaf1ap.SCell_Status_Item_element']//field[@name='nokiaf1ap.sCellInactiveReason']
    ${SCellIndex_path}=    Set Variable
    ...    .//field[@name='nokiaf1ap.SCell_Status_Item_element']//field[@name='nokiaf1ap.sCellIndex']
    ${SCellInactiveReason_elems}    XML.Get elements    ${output}   ${SCellInactiveReason_path}
    ${SCellIndex_elems}    XML.Get Elements    ${output}   ${SCellIndex_path}

    FOR  ${SCellInactiveReason_elem}  IN  @{SCellInactiveReason_elems}
        ${showname}  XML.Get Element Attribute  ${SCellInactiveReason_elem}  showname
        Should Contain  ${showname}  sCellInactiveReason: bad-radio-link-quality (2)
    END

    @{bad_Scell_ids_list}  String.Split String  ${bad_Scell_ids}  ,
    ${bad_SCell_list}   Create List

    ${bad_SCell_list_expected}    Create List
    FOR  ${bad_SCell_list_elem}  IN  @{bad_Scell_ids_list}
        Collections.Append To list  ${bad_SCell_list_expected}  sCellIndex: ${bad_SCell_list_elem}
    END
    Log To Console  ${bad_SCell_list_expected}

    FOR  ${SCellIndex_elem}  IN  @{SCellIndex_elems}
        ${showname}  XML.Get Element Attribute  ${SCellIndex_elem}  showname
        Collections.Append To List  ${bad_SCell_list}  ${showname}
    END
    Collections.Lists Should Be Equal  ${bad_SCell_list}  ${bad_SCell_list_expected}  ignore_order=True


Check SCellInactiveReason Should Contain Inactivity-Timer
    [Arguments]    ${pcap_file}  ${Scell_id}
    ${output}    ute_tshark.Read Pcap    packet_filter=(nokiaf1ap.sCellInactiveReason == 0) && (nokiaf1ap.sCellIndex == ${Scell_id})
    ...    output_type=pdml    pcap_file_path=${pcap_file}
    ${SCellInactiveReason_path}=    Set Variable
    ...    .//field[@name='nokiaf1ap.SCell_Status_Item_element']//field[@name='nokiaf1ap.sCellInactiveReason']
    ${SCellIndex_path}=    Set Variable
    ...    .//field[@name='nokiaf1ap.SCell_Status_Item_element']//field[@name='nokiaf1ap.sCellIndex']
    ${SCellInactiveReason_elems}    XML.Get Elements    ${output}   ${SCellInactiveReason_path}
    ${SCellIndex_elems}    XML.Get Elements    ${output}   ${SCellIndex_path}

    FOR  ${SCellInactiveReason_elem}  IN  @{SCellInactiveReason_elems}
        ${showname}  XML.Get Element Attribute  ${SCellInactiveReason_elem}  showname
        Should Contain  ${showname}  sCellInactiveReason: inactivity-timer (0)
    END

    FOR  ${SCellIndex_elem}  IN  @{SCellIndex_elems}
        ${showname}  XML.Get Element Attribute  ${SCellIndex_elem}  showname
        Should Contain  ${showname}  sCellIndex: ${Scell_id}
    END


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


Check Ext GNB SCell Information List
    [Arguments]    ${pcap_file}  ${items}
    ${output}    ute_tshark.Read Pcap    packet_filter=(nokiaf1ap.ext_gNB_SCell_Information_List==${items})
    ...    output_type=pdml    pcap_file_path=${pcap_file}

    ${ext_SCellInformation_path}=    Set Variable
    ...    .//field[@name='nokiaf1ap.ext_gNB_SCell_Information_List']

    ${ext_SCellInformationIndex_elems}    XML.Get Elements  ${output}  ${ext_SCellInformation_path}
    FOR  ${ext_SCellInformationIndex_elem}  IN  @{ext_SCellInformationIndex_elems}
        ${showname}  XML.Get Element Attribute  ${ext_SCellInformationIndex_elem}  showname
        Should Contain  ${showname}  ext-gNB-SCell-Information-List: ${items} items
    END

Check Ext SCell Information List For Specific SCellIndex or PhysCellId
    [Arguments]    ${pcap_file}  ${scellInfo}  ${sCell_id}=${None}  ${physCellId}=${None}

    IF    '${physCellId}' != '${None}'
        ${output}    ute_tshark.Read PCAP
        ...    packet_filter=(nokiaf1ap.ext_SCellInformation_List==${scellInfo})&&(nr-rrc.physCellId == ${physCellId})
        ...    output_type=pdml    pcap_file_path=${pcap_file}
    ELSE
        ${output}    ute_tshark.Read PCAP    packet_filter=(nokiaf1ap.ext_SCellInformation_List==${scellInfo})&&(nokiaf1ap.sCellIndex ==${sCell_id})
        ...    output_type=pdml    pcap_file_path=${pcap_file}
    END

    ${ext_SCellInformationList_path}    ${PhysCell_path}    Set Variable
    ...    .//field[@name='nokiaf1ap.ext_SCellInformation_List']//field[@name='nokiaf1ap.sCellIndex']
    ...    .//field[@name='nr-rrc.sCellConfigCommon_element']//field[@name='nr-rrc.physCellId']

    IF    '${physCellId}' != '${None}'
        ${physCellId_elems}    XML.Get Elements  ${output}  ${PhysCell_path}
        FOR  ${physCellId_elems}  IN  @{physCellId_elems}
            ${showname}  XML.Get Element Attribute  ${physCellId_elems}  showname
            Should Contain  ${showname}  physCellId: ${physCellId}
        END
    ELSE
        ${extSCellInformationListIndex_elems}    XML.Get Elements  ${output}  ${ext_SCellInformationList_path}
        FOR  ${extSCellInformationListIndex_elem}  IN  @{extSCellInformationListIndex_elems}
            ${showname}  XML.Get Element Attribute  ${extSCellInformationListIndex_elem}  show
            Should Contain  ${showname}  sCellIndex: ${sCell_id}
        END
    END


Check Inter_gNB_Stepwise_SCell_Addition Shall Be Supported
    [Arguments]    ${pcap_file}
    ${output1}    ute_tshark.Read Pcap    packet_filter=(nokiaxnap.Inter_gNB_Stepwise_SCell_Addition==0)
    ...    output_type=pdml    pcap_file_path=${pcap_file}
    ${output2}    ute_tshark.Read Pcap    packet_filter=(nokiaxnap.ReportedCellList==3)
    ...    output_type=pdml    pcap_file_path=${pcap_file}

    ${interGNB_SCellAddition_path}=    Set Variable
    ...    .//field[@name='nokiaxnap.Inter_gNB_Stepwise_SCell_Addition']
    ${ReportedCellList_path}=    Set Variable
    ...    .//field[@name='nokiaxnap.ReportedCellList']

    ${interGNB_SCellAddition_elems}    XML.Get Elements  ${output1}  ${interGNB_SCellAddition_path}
    FOR  ${interGNB_SCellAddition_elem}  IN  @{interGNB_SCellAddition_elems}
        ${showname}  XML.Get Element Attribute  ${interGNB_SCellAddition_elem}  showname
        Should Contain  ${showname}  Inter-gNB-Stepwise-SCell-Addition: supported (0)
    END

    ${ReportedCellList_elems}    XML.Get Elements  ${output2}  ${ReportedCellList_path}
    FOR  ${ReportedCellList_elem}  IN  @{ReportedCellList_elems}
        ${showname}  XML.Get Element Attribute  ${ReportedCellList_elem}  showname
        Should Contain  ${showname}  ReportedCellList: 3 items
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


Identification of Scell Index
    [Arguments]  ${pcap_file}  ${num_Cells}=${3}  ${filter_sCell}=${filter_sCell}
    Set Test Variable    ${filter_sCell}  ${filter_sCell}
    FOR  ${i}  IN RANGE  1  ${num_Cells}+1
        ${extracted_sCellIndex}=  carrier_aggregation_verification.Extract ScellIndex From physCellId_sCellIndex_mapping
        ...    pcap_file=${pcap_file}
        ...    physCellId_tobeextracted=${physCellIdTargetSCell${i}}
        Set Test Variable    ${sCellIndex_SCell${i}}  ${extracted_sCellIndex}
    END
    Log To Console  Extracted SCellIndex: ${sCellIndex_SCell1},${sCellIndex_SCell2},${sCellIndex_SCell3}
