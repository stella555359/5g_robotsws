*** Settings ***
Documentation       :copyright:     Nokia
...                 :This contains pcap or tshark realted keywords required for our featurs
Variables        ta5g_global_var
Variables       ../PythonLib/tshark_filters
Library         ta5g_tshark
Library          String
Library          Collections
Library          OperatingSystem
Library          XML    use_lxml=true
Library         ute_tshark
Library         ute_wtssim
Library         ute_fsmaccess
Library         ta5g_syslog
Library         ta5g_ue_mobility
Library         ta5g_egate
Library         ta5g_commissioning
Library         ta5g_admin_operations
Library         taf.hw.pdu
Library         ta5g_setups_and_teardowns
Library         Process
*** Keywords ***
Start Tcp Pcap on wts
    [Arguments]         ${log_filename}=eth3_tcp.pcap           ${eth_interface}=eth3
    ...                 ${capture_filter}='tcp'                 ${log_dirpath}=${OUTPUT_DIR}/${TEST_NAME}
    ...                 ${alias}=tcp_pcap
    log to console      start PCAP capture on WTS
    Start tshark
    ...    log_filename=${log_filename}
    ...    eth_interface=${eth_interface}
    ...    capture_filter=${capture_filter}
    ...    log_dirpath=${log_dirpath}
    ...    alias=${alias}

Stop Tcp Pcap on wts
    [Arguments]         ${alias}=tcp_pcap
    log to console      stop PCAP capture on WTS
    Stop tshark         alias=${alias}

Verify Tcp Messages
    [Arguments]         ${packet_filter}        ${number_of_messages}=1         ${pcap_file_path}=${None}
    ...                 ${timeout}=16           ${relation_symbol}= ==
    ...                 ${alias}=tcp_pcap       ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Msg Should Be Present in PCAP
    [Arguments]         ${pcap_file_path}       ${filter}       ${msg_names}
    [Documentation]    This keyword checks the PCAP using tshark whether any value matching the filter is present.
    ...                We can check if specific msgs are present by giving the msg names in ${msg_names} variable
    ...                | Arguments | Explaination |
    ...                | filter    | The filter which helps in the validation of the scenario |
    ...                | pcap_file_path | The tcpdump file that needs to be verified |
    ...                | msg_names | Msgs that needs to be verified from the tshark output when the filter is applied
    ...                              If more than one msg will be present and the same needs to be verified we can give
    ...                              more than 1 msg name by seperating them with Comma(,) |
    ...                Example for understanding :
    ...                | Filter PCAP Output | filter=x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 1 |
    ...                | ... | pcap_file_path=/home/ute/gNB.pcap | msg_name=SgNBAdditionRequestAcknowledge,RRC Reconfiguration |
    ...                 Modified Date: 19-May-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ${tshark_output}    Get Tshark Output    ${filter}    ${pcap_file_path}
    Should Not Be Empty    ${tshark_output}    msg=Tshark output should not be Empty
    Msg Names Should Be Present In Tshark output    ${tshark_output}    ${msg_names}
    [Return]    ${tshark_output}

Get Tshark Output
    [Arguments]    ${filter}    ${pcap_file}
    [Documentation]    This keyword gets the tshark output by applying the filter and also checks if
    ...                tshark command is executed without errors
    ...                | Arguments | Explaination |
    ...                | filter | The filter which helps in the validation of the scenario |
    ...                | pcap_file | The tcpdump file that needs to be verified |
    ...                 Modified Date: 19-May-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ${rc}    ${tshark_output}    Run And Return Rc And Output    tshark -Y "${filter}" -r ${pcap_file}
    Should Be Equal As Integers   ${rc}    0    msg=tshark command has failed with return code ${rc}
    [Return]    ${tshark_output}

Msg Names Should Be Present In Tshark output
    [Arguments]    ${tshark_output}    ${msg_names}
    [Documentation]    This keyword checks the tshark output for msg names as mentioned in ${msg_names} variable
    ...                | Arguments | Explaination |
    ...                | msg_names | Msgs to be verified in the form of string where Multiple messages are seperated by Comma(,) |
    ...                | tshark_output | tshark output that is got from the tshark after the application of filter |
    ...                 Modified Date: 19-May-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    Should Not Be Empty    ${msg_names}    msg=No msgs available to verify in tshark output
    ${msgs}    Split String    ${msg_names}     separator=,
    Check Output Has All Msg Names    ${tshark_output}    @{msgs}

Check Output Has All Msg Names
    [Arguments]    ${tshark_output}    @{msgs}
    [Documentation]    This keyword for the msg names from tshark output
    ...                Keyword is used internally in `Msg Names Should Be Present In Tshark output`.
    ...                This Keyword can be used Independently if we have the msgs in the form of an array
    ...                | Arguments | Explaination |
    ...                | msgs | Msgs to be verified in the form of an array |
    ...                | tshark_output | tshark output that is got from the tshark after the application of filter |
    ...                 Modified Date: 19-May-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    : FOR    ${msg}    IN    @{msgs}
    \    Should Contain    ${tshark_output}    ${msg}    Msg Name Not Present In pcap

Msg Should Not Be Present in PCAP
    [Arguments]    ${pcap_file}     ${filter}
    [Documentation]    This keyword checks the PCAP using tshark no msgs matching the filter is present. Filter should not yield
    ...                any other msgs as well.
    ...                | Arguments | Explaination |
    ...                | filter    | The filter which helps in the validation of the scenario |
    ...                | pcap_file_path | The tcpdump file that needs to be verified |
    ...                Example for understanding :
    ...                | Filter PCAP Output | pcap_file_path=/home/ute/gNB.pcap | filter=x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 1 |
    ...                 Modified Date: 19-May-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ${tshark_output}    Get Tshark Output    ${filter}    ${pcap_file}
    Should Be Empty    ${tshark_output}    msg=Tshark output Should Be Empty as the Msg Should Not be Present in the Pcap

PCAP File Should have Messages Defined in Filter File
    [Arguments]    ${pcap_file}    ${wireshark_filter_file}
    [Documentation]    This keyword validates that the required messages are present in the PCAP File.
    ...                The filter and the msg to be verified is got from a data file.The filter should be the first component and
    ...                have a delimiter '|' and have the msg to be verified next after the delimiter.
    ...                Example of how the filter file has to be stored:
    ...                "x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 1 and nr-rrc.cipheringAlgorithm == 3 and
    ...                 nr-rrc.integrityProtAlgorithm == 3 and nr-rrc.srb_Identity == 3|SgNBAdditionRequestAcknowledge,RRC Reconfiguration"
    ...                The above value should be in a single line. The important things to note is the Pipesymbol(|) delimiter between
    ...                filter and msg and the multiple msgs are seperated by Comma(,)
    ...                 Modified Date: 19-May-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ${filter_msg_values}    Get Filter And Message From Filter File    ${wireshark_filter_file}
    :FOR    ${filter}    ${msg}    IN    @{filter_msg_values}
    \    Msg Should Be Present in PCAP    ${pcap_file}    ${filter}    ${msg}

Get Filter And Message From Filter File
    [Arguments]    ${wireshark_filter_file}
    [Documentation]    This keyword gets the filter and the msg to be verified from the file where the filter/msg combination
    ...                is stored. The filter should be the first then have a delimiter '|' and then have the msg to be verified
    ...                Example of how the filter file has to be stored:
    ...                "x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 1 and nr-rrc.cipheringAlgorithm == 3 and
    ...                 nr-rrc.integrityProtAlgorithm == 3 and nr-rrc.srb_Identity == 3|SgNBAdditionRequestAcknowledge,RRC Reconfiguration"
    ...                The above value should be in a single line. The important things to note is the Pipesymbol(|) delimiter between
    ...                filter and msg and the multiple msgs are seperated by Comma(,)
    ...                 Modified Date: 19-May-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    @{filters}    Create List
    ${data}    Get File    ${wireshark_filter_file}
    ${values}    Split To Lines    ${data}
    :FOR    ${value}    IN    @{values}
    \    ${filter}    ${msg}    Split String    ${value}     separator=|
    \    Append To List    ${filters}    ${filter}    ${msg}
    [Return]    ${filters}

Get Fields from Pcap
    [Arguments]     ${pcap_file_path}        ${filter}       ${field}
    [Documentation]             This Keyword helps to get the value correspoinding to the pcap file with given filter and filed id
    ...                         to get unque value please use unique filter and field id
    ...     [Arguments]         pcap_file_path    :     Need to give the complete file path and name of the file to check message or values
    ...                         filter            :     Need to give filter for the messages we need
    ...                         field             :     Need to give the field for which we need the value
    ...     [Return]            None
    ...     [Usage]        Get Fields from Pcap    pcap_file_path     f1ap.procedureCode == 7 and f1ap.id == 87     f1ap.GNB_CU_UE_F1AP_ID
    ${rc}    ${tshark_output}    Run And Return Rc And Output    tshark -Y "${filter}" -T fields -e ${field} -r ${pcap_file_path}
    [Return]    ${tshark_output}

Count of Messages Matching Filter Should be Equal
    [Arguments]     ${pcap_file_path}       ${filter}       ${msg_names}        ${expected_count_of_messages}
    [Documentation]              This Keyword helps to check no of expecting messages are correct
    ...      [Arguments]         pcap_file_path    :     Need to give the complete file path and name of the file to check message or values
    ...                          filter            :     Need to give filter for the messages we need
    ...                          msg_names         :     Need to give the message name we need to count
    ...                          expected_count_of_messages     :    No of messages expected should be mentioned
    ...      [Return]            None
    ${messages}    Msg Should Be Present in PCAP    ${pcap_file_path}     ${filter}    ${msg_names}
    @{number_of_messages}    Split String     ${messages}    separator=\n
    ${received_count_of_messages}    Get Length    ${number_of_messages}
    Should be equal as integers    ${received_count_of_messages}    ${expected_count_of_messages}
