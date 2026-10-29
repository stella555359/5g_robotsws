*** Settings ***
Documentation
...    | Author:        | Frank; Ulm                              |
...    | Team:          | MI MN RAN RD VRF ULM                       |
...    | Contact:       | I_MN_RAN_RD_VRF_ULM_*XYZ*@nokia.com     |
...    | Description:   | Verification Keywords for CB010559      |

Library    OperatingSystem
Library    taf.analyzer.pdml    WITH NAME    pdml

Resource    ../../resources/Common/pmcounters.robot


*** Keywords ***
##############################################################################
###   Verify PM Counter
##############################################################################

Verify PmCounter CB010559_A_RE_TC01_B1_Successful_RRE_unpreparedgNB_no_HO
    [Documentation]
    ...    |  CB010559_A Performance Counters PM Values per cells.
    ...    |  the variables ${GNB1_TARGET_P_CELL_UE_1} is set as test variables in the preconditions part

    ${CB010559_A_RE_TC01_B1_Values_per_Cells}   Create List
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00043  ==  1   REESTAB_UNPREP_ACC_OTH_FAIL: Num of RRC RE cell due to other failure
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00044  ==  1   REESTAB_UNPREP_ATT_OTH_FAIL: Num of RRC RE attempts to unprep cell due to oth fail
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00045  ==  0   REESTAB_UNPREP_ACC_VONR: Num of RRC RE for VoNR UEs for any cause
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00046  ==  0   REESTAB_UNPREP_ACC_FALLBACK: Num of Succ RRC RE to unprep cell fb due gNB fail UEct
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00047  ==  0   REESTAB_UNPREP_FALLBACK: Num of RRC RE to unprep cell fb due gNB fail to retr UEct
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00048  ==  0   REESTAB_UNPREP_ACC_HO_FAIL: Num of RRC RE to unprep cell due to handover failure
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00049  ==  0   REESTAB_UNPREP_ATT_HO_FAIL: Num of RRC RE attempts to unprep cell due ho failure
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00050  ==  0   RRC_RECONF_COMP_FULLCONF_RRE: Num of RRC RE compl full co UE RRE to cell unprep gNB

    Run Keyword And Continue On Failure    pmcounters.Verify PM Counter Reference Table
    ...   reference_table=${CB010559_A_RE_TC01_B1_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${0}


Verify PmCounter CB010559_A_TC04_EC5_Fallback_RRC_Setup
    [Documentation]
    ...    |  CB010559_A Performance Counters PM Values per cells.         |
    ...    |  the variables ${GNB1_TARGET_P_CELL_UE_1} is set as test variables in the preconditions part  |

    ${CB010559_A_TC04_EC5_Values_per_Cells}   Create List
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00043  ==  0   REESTAB_UNPREP_ACC_OTH_FAIL: Num of RRC RE cell due to other failure
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00044  ==  1   REESTAB_UNPREP_ATT_OTH_FAIL: Num of RRC RE attempts to unprep cell due to oth fail
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00045  ==  0   REESTAB_UNPREP_ACC_VONR: Num of RRC RE for VoNR UEs for any cause
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00046  ==  1   REESTAB_UNPREP_ACC_FALLBACK: Num of Succ RRC RE to unprep cell fb due gNB fail UEct
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00047  ==  1   REESTAB_UNPREP_FALLBACK: Num of RRC RE to unprep cell fb due gNB fail to retr UEct
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00048  ==  0   REESTAB_UNPREP_ACC_HO_FAIL: Num of RRC RE to unprep cell due to handover failure
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00049  ==  0   REESTAB_UNPREP_ATT_HO_FAIL: Num of RRC RE attempts to unprep cell due ho failure
    ...  (NRCELL-${GNB1_TARGET_P_CELL_UE_1})M55124C00050  ==  0   RRC_RECONF_COMP_FULLCONF_RRE: Num of RRC RE compl full co UE RRE to cell unprep gNB

    Run Keyword And Continue On Failure    pmcounters.Verify PM Counter Reference Table
    ...   reference_table=${CB010559_A_TC04_EC5_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${0}


##############################################################################
###   Verify RRC RRE messages
##############################################################################
Verify RrcRreMsg CB010559_A_RE_TC01_B1_Successful_RRE_unpreparedgNB_no_HO
   Log To Console    ${\n} Verification of the RRC RRE message sequence
   Log To Console    ${\n} TO BE DONE
   Log To Console   tcpdump_gnb_${GNB_ID_0} is ${tcpdump_gnb_${GNB_ID_0}}
   Log To Console   tcpdump_gnb_${GNB_ID_1} is ${tcpdump_gnb_${GNB_ID_1}}
   Log To Console   testPc_mirrorPort_eth3 is ${testPc_mirrorPort_eth3}

   CB010559_Verification.Convert PCAP2PDML
   ...   tcp_file=tcpdump_gnb_${GNB_ID_0}   pcap_packet_filter=nokiaxnap
   CB010559_Verification.Convert PCAP2PDML
   ...   tcp_file=tcpdump_gnb_${GNB_ID_1}   pcap_packet_filter=nokiaxnap
   CB010559_Verification.Convert PCAP2PDML
   ...   tcp_file=testPc_mirrorPort_eth3   pcap_packet_filter=nokiaxnap

   Run Keyword And Continue On Failure
   ...   CB010559_Verification.Check Xn RetrieveUEContext_Request_Response
         ...   input_pdml_file=${pdml_file_tcpdump_gnb_${GNB_ID_0}}
   #  to save disc space on log directory all *.pdml files are deleted after analysis, all *.pcap are still available
   OperatingSystem.Remove File   ${pdml_file_tcpdump_gnb_${GNB_ID_0}}

   Run Keyword And Continue On Failure
   ...   CB010559_Verification.Check Xn RetrieveUEContext_Request_Response
         ...   input_pdml_file=${pdml_file_tcpdump_gnb_${GNB_ID_1}}
   OperatingSystem.Remove File   ${pdml_file_tcpdump_gnb_${GNB_ID_1}}

   Run Keyword And Continue On Failure
   ...   CB010559_Verification.Check Xn RetrieveUEContext_Request_Response
         ...   input_pdml_file=${pdml_file_testPc_mirrorPort_eth3}
   OperatingSystem.Remove File   ${pdml_file_testPc_mirrorPort_eth3}


Verify RrcRreMsg CB010559_A_TC04_EC5_Fallback_RRC_Setup
   Log To Console    ${\n} Verification of the RRC RRE message sequence
   Log To Console    ${\n} TO BE DONE
   Log To Console   tcpdump_gnb_${GNB_ID_0} is ${tcpdump_gnb_${GNB_ID_0}}
   Log To Console   tcpdump_gnb_${GNB_ID_1} is ${tcpdump_gnb_${GNB_ID_1}}
   Log To Console   testPc_mirrorPort_eth3 is ${testPc_mirrorPort_eth3}

   CB010559_Verification.Convert PCAP2PDML
   ...   tcp_file=tcpdump_gnb_${GNB_ID_0}   pcap_packet_filter=nokiaxnap
   CB010559_Verification.Convert PCAP2PDML
   ...   tcp_file=tcpdump_gnb_${GNB_ID_1}   pcap_packet_filter=nokiaxnap
   CB010559_Verification.Convert PCAP2PDML
   ...   tcp_file=testPc_mirrorPort_eth3   pcap_packet_filter=nokiaxnap

   Run Keyword And Continue On Failure
   ...   CB010559_Verification.Check Xn RetrieveUEContext_Request_Failure
         ...   input_pdml_file=${pdml_file_tcpdump_gnb_${GNB_ID_0}}
   #  to save disc space on log directory all *.pdml files are deleted after analysis, all *.pcap are still available
   OperatingSystem.Remove File   ${pdml_file_tcpdump_gnb_${GNB_ID_0}}

    Run Keyword And Continue On Failure
    ...   CB010559_Verification.Check Xn RetrieveUEContext_Request_Failure
          ...   input_pdml_file=${pdml_file_tcpdump_gnb_${GNB_ID_1}}
   OperatingSystem.Remove File   ${pdml_file_tcpdump_gnb_${GNB_ID_1}}

    Run Keyword And Continue On Failure
    ...   CB010559_Verification.Check Xn RetrieveUEContext_Request_Failure
          ...   input_pdml_file=${pdml_file_testPc_mirrorPort_eth3}
   OperatingSystem.Remove File   ${pdml_file_testPc_mirrorPort_eth3}


###  Keywords for log analysis
Check Xn RetrieveUEContext_Request_Response
   [Documentation]    Check if RRE UE Context Request is successful with Request Response
   [Arguments]    ${input_pdml_file}

    @{field_names}=    Create List
    ...    nokiaxnap.RetrieveUEContextRequest_element
    ...    nokiaxnap.RetrieveUEContextResponse_element
    #    ...    ngap.radioNetwork == 35

    ${message_sequence}=    Catenate    SEPARATOR=
    ...    RetrieveUEContextRequest.*
    ...    RetrieveUEContextResponse.*

    # This will pass if the sequence matches, fail with assertion error if not
    pdml.Check Msc
    ...    file_name=${input_pdml_file}
    ...    field_name_list=${field_names}
    ...    message_sequence=${message_sequence}

    Log To Console    Message sequence (RetrieveUEContextRequest and ...Response) validation passed!


Check Xn RetrieveUEContext_Request_Failure
   [Documentation]    Check if RRE UE Context Request ended with a Failure
   [Arguments]    ${input_pdml_file}

    @{field_names}=    Create List
    ...    nokiaxnap.RetrieveUEContextRequest_element
    ...    nokiaxnap.RetrieveUEContextFailure_element

    ${message_sequence}=    Catenate    SEPARATOR=
    ...    RetrieveUEContextRequest.*
    ...    RetrieveUEContextFailure.*

    # This will pass if the sequence matches, fail with assertion error if not
    pdml.Check Msc
    ...    file_name=${input_pdml_file}
    ...    field_name_list=${field_names}
    ...    message_sequence=${message_sequence}

    Log To Console    Message sequence (RetrieveUEContextRequest and ...Failure) validation passed!


Convert PCAP2PDML
    [Documentation]    Convert tracing file from pcap to pdml
    [Arguments]    ${tcp_file}   ${pcap_packet_filter}=None

    Log To Console   RESULT_TEST_DIR is ${RESULT_TEST_DIR}
    ute_tshark.Read Pcap And Save To File
    ...    filename=${RESULT_TEST_DIR}/${tcp_file}/${tcp_file}.pdml
    ...    packet_filter=${pcap_packet_filter}
    ...    output_type=pdml
    ...    pcap_file_path=${RESULT_TEST_DIR}/${tcp_file}/${tcp_file}.pcap

    Set Test Variable    ${pcap_file_${tcp_file}}    ${RESULT_TEST_DIR}/${tcp_file}/${tcp_file}.pcap
    Set Test Variable    ${pdml_file_${tcp_file}}   ${RESULT_TEST_DIR}/${tcp_file}/${tcp_file}.pdml

    Log To Console   pdml file is ${pdml_file_${tcp_file}}
