*** Settings ***

Documentation
...   This robot resource file holds keywords for various uses.

Library    String
Library    OperatingSystem

Library    taf.transport.ssh    WITH NAME    ssh

Library    python/pdml_file.py
Library    python/xml_handling.py
Library    python/log_check.py

Resource   connect.robot

*** Keywords ***

# File modification

Get File Path On Target
    [Documentation]
    ...
    ...    | file_pattern | file location and pattern, e.g. /ffs/run/swpool/OAM/psconfig_*.txz |
    ...    | connection   | alias name |
    ...
    ...    *Returns* file_path
    [Arguments]    ${file_pattern}    ${connection}
    ${output}=    ssh.Execute    ls ${file_pattern}    connection=${connection}
    ${file_path}=    String.Strip String    ${output}
    RETURN    ${file_path}


Convert PCAP To PDML
    [Documentation]
    ...
    ...    | source             | Path to the pcap file that has to be converted to pdml |
    ...    | target             | Path where the converted pdml file has to be stored |
    ...    | filter             | Define message filter  eg. "dldata_csirssendreq || uldata_pucchreceivereq || uldata_pucchreceiverespps" |
    ...    | option             | User defined options for tshark can be included here |
    ...
    [Arguments]  ${source}  ${target}  ${filter}=${EMPTY}  ${option}=${EMPTY}

    ${filter_arg}=    Set Variable If    '${filter}'!='${EMPTY}'    -Y ${filter}    ${EMPTY}
    ${command}=  Set Variable      tshark -r "${source}" ${option} -T pdml ${filter_arg} >"${target}_"
    OperatingSystem.Run  ${command}
    pdml_file.Strip Headers  source_file=${target}_  target_file=${target}
    OperatingSystem.Run  sudo rm ${target}_


Convert PCAP To
    [Documentation]
    ...
    ...    | format             | Output format, e.g. "pdml|ps|psml|json|jsonraw|ek|tabs|text|fields" (see "tshark -T" option for details) |
    ...    | source             | Path to the pcap file that has to be converted to ${output_format} |
    ...    | target             | Path where the converted ${output_format} file has to be stored |
    ...    | filter             | Define message filter  eg. "dldata_csirssendreq || uldata_pucchreceivereq || uldata_pucchreceiverespps" |
    ...    | option             | User defined options for tshark can be included here |
    ...
    [Arguments]  ${format}  ${source}  ${target}  ${filter}=${EMPTY}  ${option}=${EMPTY}

    ${format}    String.Convert To Lowercase    ${format}
    ${filter_arg}    Set Variable If    '${filter}'!='${EMPTY}'    -Y ${filter}    ${EMPTY}
    OperatingSystem.Run    tshark -r "${source}" ${option} -T ${format} ${filter_arg} >"${target}"


Get Latest Modified File With Defined Pattern
    [Documentation]
    ...    It returns the latest modified file from a specified directory
    ...
    ...    | path    | Path of directory to get the files |
    ...    | pattern | Optional matching pattern |
    ...
    ...    *Returns* Latest modified file
    ...
    [Arguments]    ${path}    ${pattern}=${EMPTY}
    ${files}=    OperatingSystem.List Files In Directory    path=${path}    pattern=${pattern}
    ${lastModifiedFile}=    Get From List    ${files}    0
    ${time1}=    OperatingSystem.Get Modified Time    ${path}//${lastModifiedFile}    epoch
    FOR    ${file}    IN    @{files}
        ${time}=    OperatingSystem.Get Modified Time    ${path}//${file}    epoch
        ${lastModifiedFile}=    Set Variable If    ${time1} < ${time}    ${file}    ${lastModifiedfile}
    END
    RETURN  ${lastModifiedFile}


Modify XML Content
    [Documentation]
    ...
    ...  | path     | absolute path to xml file |
    ...  | @updates | xml element and value in this order: element1    value1    element2    value2 |
    ...
    [Arguments]  ${file_path}  @{updates}
    xml_handling.Set Values To XML File  ${file_path}  @{updates}


Get XML Content
    [Documentation]
    ...
    ...  | path  | absolute path to xml file |
    ...  | xpath | xpath in xml file |
    ...
    ...  *Returns* Value of xpath
    ...
    [Arguments]  ${file_path}  ${xpath}
    ${l2PsNodeId}=  xml_handling.Get Value From Xpath  ${file_path}  ${xpath}
    RETURN    ${l2PsNodeId}


Verify Sequence In File
    [Documentation]
    ...    verify log sequence in file, base on sequence in defined list, check is case insensitive
    ...    if message in the list not found, then the check breaks, fails the keyword and displays a log with the reason for failure
    ...
    ...    Example:
    ...       | @{interRatHo_seq}=  Create List
    ...       | ...    ue_measurement_send_nr meas_id=\\d event=B2
    ...       | ...    HANDOVER REQUIRED: gNB=2
    ...       | ...    Received Handover Required from GNB-2 with Handover Type FIVEGS-TO-EPS and cause RAN ng inter system handover triggered for UE
    ...       | ...    Received Handover Request Acknowledge Message
    ...       | ...    message c1 : mobilityFromNRCommand
    ...       | Verify Sequence in File    /opt/iphy/latest/egate_console.log    @{interRatHo_seq}
    ...
    ...    | file_path |   file location |
    ...    | patternlist |     List of wanted regular expression |
    ...
    [Arguments]  ${file_path}  @{patternlist}
    ${contents}=    OperatingSystem.Get File    ${file_path}
    log_check.Verify Sequence In Log    ${contents}    @{patternlist}
