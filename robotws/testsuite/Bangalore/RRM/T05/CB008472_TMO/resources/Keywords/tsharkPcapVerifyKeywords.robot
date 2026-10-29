*** Settings ***
Documentation       :copyright:     Nokia
...                 :This contains pcap or tshark realted keywords required for our featurs

Library          Collections
Library          OperatingSystem
Library          Process
Library          String
Library          XML    use_lxml=true
Library          ute_fsmaccess
Library          ute_wtssim
Library          ta5g_commissioning
Library          ta5g_egate
Library          ta5g_tshark
Library          ta5g_ue_mobility
Library          taf.hw.pdu
Variables        ta5g_global_var


*** Keywords ***
Start Tcp Pcap On WTS
    [Documentation]    This help sot start pcap collection on WTS.
    [Arguments]         ${log_filename}=eth3_tcp.pcap           ${eth_interface}=eth3
    ...                 ${capture_filter}='tcp'                 ${log_dirpath}=${OUTPUT_DIR}/${TEST_NAME}
    ...                 ${alias}=tcp_pcap
    Log To Console      start PCAP capture on WTS
    Start Tshark
    ...    log_filename=${log_filename}
    ...    eth_interface=${eth_interface}
    ...    capture_filter=${capture_filter}
    ...    log_dirpath=${log_dirpath}
    ...    alias=${alias}

Stop Tcp Pcap On WTS
    [Documentation]    It Stop Tcp Pcap On WTS with the same alias with which it was started.
    [Arguments]         ${alias}=tcp_pcap
    Log To Console      stop PCAP capture on WTS
    Stop Tshark         alias=${alias}

Msg Should Be Present In PCAP
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
    ...                | ... | pcap_file_path=/home/ute/gNB.pcap | msg_name=SgNBAdditionRequestAcknowledge,
    ...                RRC Reconfiguration |
    ...                 Modified Date: 19-May-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]         ${pcap_file_path}       ${filter}       ${msg_names}
    ${tshark_output}    Get Tshark Output    ${filter}    ${pcap_file_path}
    Should Not Be Empty    ${tshark_output}    msg=Tshark output should not be Empty
    Msg Names Should Be Present In Tshark Output    ${tshark_output}    ${msg_names}
    [Return]    ${tshark_output}

Get Tshark Output
    [Documentation]    This keyword gets the tshark output by applying the filter and also checks if
    ...                tshark command is executed without errors
    ...                | Arguments | Explaination |
    ...                | filter | The filter which helps in the validation of the scenario |
    ...                | pcap_file | The tcpdump file that needs to be verified |
    ...                 Modified Date: 19-May-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]    ${filter}    ${pcap_file}
    ${rc}    ${tshark_output}    Run And Return Rc And Output    tshark -Y "${filter}" -r ${pcap_file}
    Should Be Equal As Integers   ${rc}    0    msg=tshark command has failed with return code ${rc}
    [Return]    ${tshark_output}

Msg Names Should Be Present In Tshark Output
    [Documentation]    This keyword checks the tshark output for msg names as mentioned in msg_Names variable
    ...                | Arguments | Explaination |
    ...                | msg_names | Msgs to be verified in the form of string
    ...                where Multiple messages are seperated by Comma(,) |
    ...                | tshark_output | tshark output that is got from the tshark after the application of filter |
    ...                 Modified Date: 19-May-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]    ${tshark_output}    ${msg_names}
    Should Not Be Empty    ${msg_names}    msg=No msgs available to verify in tshark output
    ${msgs}    Split String    ${msg_names}     separator=,
    Check Output Has All Msg Names    ${tshark_output}    @{msgs}

Check Output Has All Msg Names
    [Documentation]    This keyword for the msg names from tshark output
    ...                Keyword is used internally in `Msg Names Should Be Present In Tshark output`.
    ...                This Keyword can be used Independently if we have the msgs in the form of an array
    ...                | Arguments | Explaination |
    ...                | msgs | Msgs to be verified in the form of an array |
    ...                | tshark_output | tshark output that is got from the tshark after the application of filter |
    ...                 Modified Date: 19-May-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]    ${tshark_output}    @{msgs}
    FOR    ${msg}    IN    @{msgs}
        Should Contain    ${tshark_output}    ${msg}    Msg Name Not Present In pcap
    END

Msg Should Not Be Present In PCAP
    [Documentation]    This keyword checks the PCAP using tshark no msgs matching the filter is present.
    ...                Filter should not yieldany other msgs as well.
    ...                | Arguments | Explaination |
    ...                | filter    | The filter which helps in the validation of the scenario |
    ...                | pcap_file_path | The tcpdump file that needs to be verified |
    ...                Example for understanding :
    ...                | Filter PCAP Output | pcap_file_path=/home/ute/gNB.pcap |
    ...                filter=x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 1 |
    ...                 Modified Date: 19-May-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]    ${pcap_file}     ${filter}
    ${tshark_output}    Get Tshark Output    ${filter}    ${pcap_file}
    Should Be Empty    ${tshark_output}    msg=Tshark output Should Be Empty as the Msg Should Not be Present in Pcap

PCAP File Should Have Messages Defined In Filter File
    [Documentation]    This keyword validates that the required messages are present in the PCAP File.
    ...                The filter and the msg to be verified is got from a data file.
    ...                The filter should be the first component and have a delimiter '|' and
    ...                have the msg to be verified next after the delimiter.
    ...                Example of how the filter file has to be stored:
    ...                "x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 1 and nr-rrc.cipheringAlgorithm == 3 and
    ...                 nr-rrc.integrityProtAlgorithm == 3 and nr-rrc.srb_Identity == 3|SgNBAdditionRequestAcknowledge,
    ...                RRC Reconfiguration"
    ...                The above value should be in a single line.
    ...                The important things to note is the Pipesymbol(|) delimiter between
    ...                filter and msg and the multiple msgs are seperated by Comma(,)
    ...                Modified Date: 19-May-2020
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]    ${pcap_file}    ${wireshark_filter_file}
    ${filter_msg_values}    Get Filter And Message From Filter File    ${wireshark_filter_file}
    :FOR    ${filter}    ${msg}    IN    @{filter_msg_values}
    \    Msg Should Be Present in PCAP    ${pcap_file}    ${filter}    ${msg}

Get Filter And Message From Filter File
    [Documentation]    This keyword gets the filter and the msg to be verified from the file
    ...      where the filter/msg combination is stored.
    ...      The filter should be the first then have a delimiter '|' and then have the msg to be verified
    ...      Example of how the filter file has to be stored:
    ...      "x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 1 and nr-rrc.cipheringAlgorithm == 3 and
    ...      nr-rrc.integrityProtAlgorithm == 3 and nr-rrc.srb_Identity == 3|SgNBAdditionRequestAcknowledge,
    ...      RRC Reconfiguration"
    ...      The above value should be in a single line.
    ...      The important things to note is the Pipesymbol(|) delimiter between
    ...      filter and msg and the multiple msgs are seperated by Comma(,)
    ...      Modified Date: 19-May-2020
    ...      Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]    ${wireshark_filter_file}
    @{filters}    Create List
    ${data}    Get File    ${wireshark_filter_file}
    ${values}    Split To Lines    ${data}
    :FOR    ${value}    IN    @{values}
    \    ${filter}    ${msg}    Split String    ${value}     separator=|
    \    Append To List    ${filters}    ${filter}    ${msg}
    [Return]    ${filters}

Get Fields From Pcap
    [Documentation]        This Keyword helps to get the value correspoinding to the pcap file with
    ...                    given filter and filed idto get unque value please use unique filter and field id
    ...     [Arguments]    pcap_file_path : Need to give the complete file path and name of the file
    ...                    filter         : Need to give filter for the messages we need
    ...                    field          : Need to give the field for which we need the value
    ...     [Return]       Value or Output of tsark command
    ...     Get Fields from Pcap    pcap_file_path   f1ap.procedureCode == 7 and f1ap.id == 87   f1ap.GNB_CU_UE_F1AP_ID
    [Arguments]            ${pcap_file_path}        ${filter}       ${field}
    ${rc}    ${tshark_output}    Run And Return Rc And Output
    ...    tshark -Y "${filter}" -T fields -e ${field} -r ${pcap_file_path}
    Should Be Equal As Integers   ${rc}    0    msg=tshark command has failed
    [Return]    ${tshark_output}

Count Of Messages Matching Filter Should Be Equal
    [Documentation]              This Keyword helps to check no of expecting messages are correct
    ...      [Arguments]         pcap_file_path    :     Need to give the complete file path and name of
    ...                                                  the file to check message or values
    ...                          filter            :     Need to give filter for the messages we need
    ...                          msg_names         :     Need to give the message name we need to count
    ...                          expected_count_of_messages :    No of messages expected should be mentioned
    ...      [Return]            None
    [Arguments]     ${pcap_file_path}       ${filter}       ${msg_names}        ${expected_count_of_messages}
    ${messages}    Msg Should Be Present In PCAP    ${pcap_file_path}     ${filter}    ${msg_names}
    @{number_of_messages}    Split String     ${messages}    separator=\n
    ${received_count_of_messages}    Get Length    ${number_of_messages}
    ${received_count_of_messages2}    convert to integer    ${received_count_of_messages}
    Should Be True    ${received_count_of_messages2} == ${expected_count_of_messages}

Count Of Messages Matching Filter Should Be Equal to zero
    [Documentation]              This Keyword helps to check no of expecting messages are correct
    ...      [Arguments]         pcap_file_path    :     Need to give the complete file path and name of
    ...                                                  the file to check message or values
    ...                          filter            :     Need to give filter for the messages we need
    ...                          msg_names         :     Need to give the message name we need to count
    ...                          expected_count_of_messages :    No of messages expected should be mentioned
    ...      [Return]            None
    [Arguments]     ${pcap_file_path}       ${filter}       ${msg_names}        ${expected_count_of_messages}
    ${messages}    Msg Should Not Be Present In PCAP    ${pcap_file_path}     ${filter}
    Log To Console      ${msg_names} count is ${expected_count_of_messages}

