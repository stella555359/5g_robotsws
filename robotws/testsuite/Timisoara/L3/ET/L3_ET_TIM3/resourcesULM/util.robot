*** Settings ***
Library    taf.transport.ssh    WITH NAME    ssh
Library    String
Library    OperatingSystem
Library    python/pdml_file.py
Library    python/xml_handling.py
Library    python/log_check.py

Resource   connect.robot

*** Variables ***
&{KINFE_PACKAGE}    folder=${EMPTY}    filename=${EMPTY}

*** Keywords ***

# File modification

Extract tar file to tmp
    [Documentation]
    ...    Extract tar file on target and return extracted files location
    ...
    ...    | file_pattern |   file location and pattern, e.g. /ffs/run/swpool/OAM/psconfig_*.txz |
    ...    | connection   |   alias name |
    ...
    ...    *Returns* The extracted files location on target
    ...
    [Arguments]    ${file_pattern}    ${connection}
    ${file_path}=    Get File Path on Target    file_pattern=${file_pattern}    connection=${connection}
    ${KINFE_PACKAGE.folder}    ${KINFE_PACKAGE.filename}=    String.Split String From Right    ${file_path}    separator=/    max_split=1
    Set Test Variable    ${target_dir}    /tmp/${KINFE_PACKAGE.filename}
    ssh.execute    mkdir -p ${target_dir} && tar xvf ${file_path} -C ${target_dir}    connection=${connection}
    [Return]    ${target_dir}


Compress files into package and install
    [Documentation]
    ...    This keyword has to be used together with keyword `Extract tar file to tmp`
    ...
    ...    | files      | files needed in package |
    ...    | connection | alias name |
    ...
    ...    *Example:*
    ...
    ...    | ${gnb_asik}=   connect.Connect to Node Common Unit    node_id=0  du_id=0  comu_id=0
    ...    | Extract tar file to tmp    file_path=/ffs/run/swpool/OAM/psconfig_*.txz    connection=${gnb_asik}
    ...    | Do Something in files
    ...    | Compress files into package and install    files=*    connection=${gnb_asik}
    ...
    [Arguments]    ${files}    ${connection}
    ${output}=    ssh.execute
    ...    cd ${target_dir} && tar czvf ${KINFE_PACKAGE.filename} ${files} && knife install ${KINFE_PACKAGE.filename} ${KINFE_PACKAGE.folder}
    ...    connection=${connection}
    Log To Console    ${output}
    ssh.execute    rm -rf ${target_dir}    connection=${connection}
    Should Contain    ${output}    installed successfully


Get File Path on Target
    [Documentation]
    ...
    ...    | file_pattern | file location and pattern, e.g. /ffs/run/swpool/OAM/psconfig_*.txz |
    ...    | connection   | alias name |
    ...
    ...    *Returns* file_path
    [Arguments]    ${file_pattern}    ${connection}
    ${output}=    ssh.execute    ls ${file_pattern}    connection=${connection}
    ${file_path}=    String.Strip String    ${output}
    [Return]    ${file_path}


Convert PCAP to PDML
    [Documentation]
    ...
    ...    | source             | Path to the pcap file that has to be converted to pdml |
    ...    | target             | Path where the converted pdml file has to be stored |
    ...    | filter             | Define message filter  eg. "dldata_csirssendreq || uldata_pucchreceivereq || uldata_pucchreceiverespps" |
    ...    | option             | User defined options for tshark can be included here |
    ...
    [Arguments]  ${source}  ${target}  ${filter}=${EMPTY}  ${option}=${EMPTY}

    connect.Connect to TestPC  alias=testPC_pdmlconversion
    ${filter_arg}=    Set variable if    '${filter}'!='${EMPTY}'    -Y ${filter}    ${EMPTY}
    ${command}=  Set Variable      tshark -r "${source}" ${option} -T pdml ${filter_arg} >"${target}_"
    ssh.send_command  ${command}  connection=testPC_pdmlconversion
    ssh.await execution end  connection=testPC_pdmlconversion  timeout=60min
    pdml_file.strip headers  source_file=${target}_  target_file=${target}
    ssh.send command  sudo rm ${target}_  connection=testPC_pdmlconversion
    ssh.await execution end  connection=testPC_pdmlconversion  timeout=5min
    [Teardown]  ssh.disconnect  connection=testPC_pdmlconversion


Get latest modified file with defined pattern
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
    [Return]    ${lastModifiedFile}


Modify XML Content
    [Documentation]
    ...
    ...  | path     | absolute path to xml file |
    ...  | @updates | xml element and value in this order: element1    value1    element2    value2 |
    ...
    [Arguments]  ${file_path}  @{updates}
    xml_handling.set_values_to_xml_file  ${file_path}  @{updates}


get XML Content
    [Documentation]
    ...
    ...  | path  | absolute path to xml file |
    ...  | xpath | xpath in xml file |
    ...
    ...  *Returns* Value of xpath
    ...
    [Arguments]  ${file_path}  ${xpath}
    ${l2PsNodeId}=  xml_handling.get_value_from_xpath  ${file_path}  ${xpath}
    [Return]    ${l2PsNodeId}


Verify Sequence in File
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
    log_check.verify_sequence_in_log    ${contents}    @{patternlist}
