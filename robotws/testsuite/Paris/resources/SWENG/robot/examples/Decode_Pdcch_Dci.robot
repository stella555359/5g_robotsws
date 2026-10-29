*** Settings ***
Documentation       an example about how to decode PDCCH DCI info from pcap file

Resource            ../Tools.robot
Resource            ../Connect.robot

Library             taf.converters.eventdecoder    WITH NAME    EVENTDECODER
Library             ../../python/pytest/dciDecode/Decode_pdcch_dci.py
Resource            ../../../../RRM/ET/resources/common/TtiTrace/ttitrace.robot

Suite Setup         Suite setup         listBackupFiles=${FD_ALL}

*** Variables ***
${nbBitAntennaPort}                 4
${nbOccurence}                      5

*** Test Cases ***
Test bidon
    Dated log                       Hello

Test Collect TTI Logs then Decode PdcchDciInfo then Analyze CSV file
    StringTool.printLineWithTitle   title=Collect TTI Logs
    Collect TTI Logs
    StringTool.printLineWithTitle   title=-

    StringTool.printLineWithTitle   title=Decode PDCCH Dci Info
    Decode TTI From Pcap To Csv     ${TTIpcap}          ${LOG_PATH}/tti
    Decode PDCCH Dci Info           ${LOG_PATH}/tti_dl.csv      ${nbBitAntennaPort}
    StringTool.printLineWithTitle   title=-

    StringTool.printLineWithTitle   title=Analyze CSV file
    @{tti_log_patterns}             CSV Analysis                csvFile=${TTIcsv}
    ...                                                         nbOccurence=${nbOccurence}
    ...                                                         nbBitAntennaPort=${nbBitAntennaPort}
    StringTool.printLineWithTitle   title=-


*** Keywords ***
Collect TTI Logs
    # TTI capture configuration
    ${TTIdir}                       Get TTI Trace Path          dir_suffix=TTI

    # Start TTI capture
    Dated Log New Line              ===> start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2
    Traced Sleep                    duration=3s                 msg=DL TTI traffic capture 3 seconds

    # Stop TTI capture
    Dated Log New Line              ===> stop TTI traces capture
    ${TTIpcap}                      Stop TTI Traces in Streaming mode                       tti_trace_path=${TTIdir}    tti_trace_filename=TTI_TC

    Dated Log New Line              ===> convert TTI trace to json and csv
    ${TTIjson}                      Convert TTI trace from pcap to others                   input_file_path=${TTIpcap}
    ${TTIcsv}                       decode_tti_traces_json_using_TtitraceReaderEvtDec       jsonPathName=${TTIjson}    num_of_events=10000
    set Suite Variable              ${TTIpcap}
    set Suite Variable              ${TTIjson}
    set Suite Variable              ${TTIcsv}

Decode PDCCH Dci Info
    [Arguments]                     ${csvFile}      ${nbBitAntennaPort}
    Dated Log                       csvFile=${csvFile}
    ${return}                       Decode_pdcch_dci.Decode_PDCCH_DciInfo   csv_filename=${csvFile}     nbBitAntennaPort=${nbBitAntennaPort}
    [Return]                        ${return}


Decode TTI From Pcap To Csv
    [Arguments]                     ${pcap_path}      ${output_path_with_tag}       ${decode_format}=excelCsv
    [Documentation]                 This keyword will decode TTI traces from pcap file to csv.
    ...    | Input Parameters          | Mandatory  | Description       |
    ...    | ${pcap_path}              | Yes        | pcap file path.   |
    ...    | ${output_path_with_tag}   | Yes        | Decode output file save path. |
    ...    | ${output_file_format}     |  No        | output file format can be "json", "legacyCsv" or "excelCsv", default is "excelCsv" |
    ...   Example:
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | some action | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decode TTI From Pcap To Csv | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY()}nsa_tti |
    EVENTDECODER.Create Eventdecoder Converter      name=converter
    ...                                             input_file_path=${pcap_path}
    ...                                             output_file_format=${decode_format}
    ...                                             output_file_path=${output_path_with_tag}
    ...                                             excel_csv_options=-w
    EVENTDECODER.Convert                            name=converter
    Decode_pdcch_dci.Is_Csv_File_Generated          ${output_path_with_tag}
    ${path}    ${tag}                               Split Path          ${output_path_with_tag}
    #Decode_pdcch_dci.Decode Ttitrace File           ${pcap_path}    ${output_path_with_tag}    ${output_file_format}
    #...                                             ${excel_csv_options}    ${conversion_filter}
    [Return]    ${path}

# RDH Code a finir:
CSV Analysis
    [Arguments]                     ${csvFile}
    ...                             ${nbOccurence}
    [Documentation]                 This keyword will decode pcap file to csv.
    ...             for nbOccurence
    ...                trouver la  nième ligne contenant les pattern dlPdcchDciData et dciFormat;DL_11
    ...                dans la ligne trouvée, récupèrer les infos suivantes:
    ...                 - dciDynamicParamsLength;4681
    ...                 - dciBitStream=18446516305073827840
    ...                 - dciPayloadLength;55
    ...                 - rnti;0
    ...                DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength, nbBitAntennaPort)
    ...                Ajouter au dico qui est retourné le champ rnti=X
    ...                Ajouter ce dico à la liste list_dico[]
    ...             end
    ...             retourner la liste list_dico[]
    @{dictionary_List}              Create List
    &{SA_Cell_Dict}                 Create Dictionary
    FOR  ${i}  IN RANGE  1  ${nbOccurence}+1
        ${i+1}                      Evaluate            ${i} + 1
        ${cmd1}                     Set variable        grep dlPdcchDciData ${csvFile} | grep "dciFormat" | grep -m${i+1} "DL_10" | tail -n1
        ${line}                     run                 ${cmd1}
        ${nbSeparator}              run                 ${cmd1} | awk -F";" '{print NF-1}'
        ${dciBitStream}             Find DCI value      pattern=dciBitStream             line=${line}   nbSeparator=${nbSeparator}  cmd=${cmd1}
        ${dciDynamicParamsLength}   Find DCI value      pattern=dciDynamicParamsLength   line=${line}   nbSeparator=${nbSeparator}  cmd=${cmd1}
        ${dciPayloadLength}         Find DCI value      pattern=dciPayloadLength         line=${line}   nbSeparator=${nbSeparator}  cmd=${cmd1}
        ${dciFormat}                Find DCI value      pattern=dciFormat                line=${line}   nbSeparator=${nbSeparator}  cmd=${cmd1}
        ${rnti}                     Find DCI value      pattern=rnti                     line=${line}   nbSeparator=${nbSeparator}  cmd=${cmd1}
        Dated Log                   line = ${line}
        Dated Log                   dciBitStream = ${dciBitStream}
        Dated Log                   dciDynamicParamsLength = ${dciDynamicParamsLength}
        Dated Log                   dciPayloadLength = ${dciPayloadLength}
        Dated Log                   dciFormat = ${dciFormat}
        Dated Log                   rnti = ${rnti}
        Append To List              @{dictionary_List}  ${rnti}
    END
    [Return]                        @{dictionary_List}

Find DCI value
    [Arguments]             ${line}         ${pattern}      ${nbSeparator}      ${cmd}
    ${index}                Set Variable    0
    ${found}                Set Variable    ${False}
    FOR  ${i}  IN RANGE  1  ${nbSeparator}+1
        ${string}           run                 echo "${line}" | awk -F";" '{print \$${i}}'
        ${index}            set variable if     "${string}" == "${pattern}"     ${i}
        ${found}            set variable if     "${string}" == "${pattern}"     ${True}
        ${index}            run keyword if      "${string}" == "${pattern}"     evaluate    ${index} + 1
        Exit for Loop If    "${string}" == "${pattern}"
    END
    ${value}                run                 ${cmd} | awk -F";" '{print \$${index}}'
    ${return}               set variable if     ${found}==${True}               ${value}    ${EMPTY}
    [Return]                ${return}


# exemple de code à écrire si on met les fonctions python dans une classe et qu'on crée un KW robot
Decode PDCCH Dci Info if python class
    ${return}               call method
    ...                     ${decodePdcchDci}       Decode_PDCCH_DciInfo        csv_filename=${LOG_PATH}/${csfFile}
    [Return]                ${return}
