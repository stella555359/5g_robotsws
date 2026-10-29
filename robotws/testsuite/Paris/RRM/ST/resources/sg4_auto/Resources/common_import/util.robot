*** Settings ***
Documentation
...         TODO

Library    taf.transport.ssh    WITH NAME    ssh
Library    String
Library    OperatingSystem
Library    ./python/pdml_file.py
Library    ./python/xml_handling.py

Resource    ./connect.robot

*** Variables ***
&{KINFE_PACKAGE}    folder=${EMPTY}    filename=${EMPTY}

*** Keywords ***

# File modification

Extract tar file to tmp
    [Documentation]    :Author: Jing Liang
    ...    Extract tar file on target and return extracted files location
    ...
    ...    :param file_pattern:  file location and pattern, e.g. /ffs/run/swpool/OAM/psconfig_*.txz
    ...    :param connection:  alias name
    ...
    ...    :returns target_dir:  extracted files location on target
    ...
    [Arguments]    ${file_pattern}    ${connection}
    ${file_path}=    Get File Path on Target    file_pattern=${file_pattern}    connection=${connection}
    ${KINFE_PACKAGE.folder}    ${KINFE_PACKAGE.filename}=    Split String From Right    ${file_path}    separator=/    max_split=1
    Set Test Variable    ${target_dir}    /tmp/${KINFE_PACKAGE.filename}
    ssh.execute    mkdir -p ${target_dir} && tar xvf ${file_path} -C ${target_dir}    connection=${connection}
    [Return]    ${target_dir}


Compress files into package and install
    [Documentation]    :Author: Jing Liang
    ...    have to be used together with keyword  Extract tar file to tmp
    ...
    ...    :param files:  files needed in package
    ...    :param connection:  alias name
    ...
    ...    **Example:**
    ...
    ...    | ${gnb_asik}=   connect.Connect to gNB Common Unit    gnb_id=0  du_id=0  comu_id=0
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
    [Documentation]    :Author: Jing Liang
    ...
    ...    :param file_pattern:  file location and pattern, e.g. /ffs/run/swpool/OAM/psconfig_*.txz
    ...    :param connection:  alias name
    ...
    ...    :returns file_path:
    [Arguments]    ${file_pattern}    ${connection}
    ${output}=    ssh.execute    ls ${file_pattern}    connection=${connection}
    ${file_path}=    Strip String    ${output}
    [Return]    ${file_path}


Convert PCAP to PDML
    [Documentation]    :Author: Srihari Janardhan
    ...
    ...    :param source:  Path to the pcap file that has to be converted to pdml
    ...    :param target:  Path where the converted pdml file has to be stored
    ...    :param filter:  Define message filter  eg. "dldata_csirssendreq || uldata_pucchreceivereq || uldata_pucchreceiverespps"
    ...    :param luashark_path:  Defines path to luashark dissectors | by default it is /opt/luashark/
    ...    :param option: User defined options for tshark can be included here | by default it is blank
    ...
    [Arguments]  ${source}  ${target}  ${filter}=${EMPTY}  ${luashark_path}=/opt/luashark/  ${option}=${EMPTY}
    connect.Connect to TestPC  alias=testPC_pdmlconversion
    ${filter_arg}=    Set variable if    '${filter}'!='${EMPTY}'    -Y ${filter}    ${EMPTY}
    ssh.send_command
    ...  tshark -X lua_script:${luashark_path} -r "${source}" ${option} -T pdml ${filter_arg} >"${target}_"
    ...  connection=testPC_pdmlconversion
    ssh.await execution end  connection=testPC_pdmlconversion  timeout=60min
    pdml_file.strip headers  source_file=${target}_  target_file=${target}
    ssh.send command  sudo rm ${target}_  connection=testPC_pdmlconversion
    ssh.await execution end  connection=testPC_pdmlconversion  timeout=5min
    [Teardown]  ssh.disconnect  connection=testPC_pdmlconversion


Get latest modified file with defined pattern
    [Documentation]    :Author: Vasileios Papoutsis
    ...    It returns the latest modified file from a specified directory
    ...
    ...    :param path:    Path of directory to get the files
    ...    :param pattern: Optional matching pattern (default: ${EMPTY})
    ...
    ...    :returns lastModifiedFile: Latest modified file
    ...
    [Arguments]    ${path}    ${pattern}=${EMPTY}
    ${files}=    OperatingSystem.List files in directory    path=${path}    pattern=${pattern}
    ${lastModifiedFile}=    Get from list    ${files}    0
    ${time1}=    OperatingSystem.Get modified time    ${path}//${lastModifiedFile}    epoch
    FOR    ${file}    IN    @{files}
        ${time}=    Get modified time    ${path}//${file}    epoch
        ${lastModifiedFile}=    Set variable if    ${time1} < ${time}    ${file}    ${lastModifiedfile}
    END
    [Return]    ${lastModifiedFile}


Convert PCAP to TXT
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param source:        Path to the pcap file that has to be converted to pdml
    ...    :param target:        Path where the converted pdml file has to be stored
    ...    :param luashark_path: Defines path to luashark dissectors | by default it is /opt/luashark/
    ...
    [Arguments]    ${source}    ${target}    ${luashark_path}=/opt/luashark/
    ${connection}=    connect.Connect to TestPC  alias=testPC_pdmlconversion
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target}
    ...  connection=${connection}
    ssh.await execution end    connection=${connection}    timeout=30min


Modify XML Content
    [Documentation]    :Author: Guenter Doemer
    ...
    ...  :param path:      absolute path to xml file
    ...  :param @updates:  xml element and value in this order: element1    value1    element2    value2
    ...
    [Arguments]  ${file_path}  @{updates}
    xml_handling.set_values_to_xml_file  ${file_path}  @{updates}


get XML Content
    [Documentation]    :Author: Guenter Doemer
    ...
    ...  :param path:      absolute path to xml file
    ...  :param xpath:     xpath in xml file
    ...
    ...  :returns value of xpath
    [Arguments]  ${file_path}  ${xpath}
    ${l2PsNodeId}=  xml_handling.get_value_from_xpath  ${file_path}  ${xpath}
    [Return]    ${l2PsNodeId}


Kill windows process
   [Documentation]    :Author: Furkan Tombul
    ...
    ...  :param process:        name of the process to be killed
    ...
    ...  :returns value of xpath
    [Arguments]     ${process}
    ${ue_num}=    Get length    ${tl.ues}
    FOR    ${ue}    IN RANGE    ${ue_num}
        ${alias}=      Connect to UE PC   ue_id=${ue}
        Run Keyword and ignore error  ssh.Execute  taskkill /IM ${process} /F /T  connection=${alias}
    END
