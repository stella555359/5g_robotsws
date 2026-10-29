*** Settings ***
Documentation    :copyright: Nokia
...              :contact: I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

#Library      taf.transport.ssh    WITH NAME    SSH
Library      Process
Library      String
Library      Collections

*** Variables ***
${AP_SWCONFIG}     /ffs/run/swconfig.txt

*** Keywords ***
Connect using ssh to
    [Arguments]    ${hostname}    ${proxy}=${None}
    ssh.connect_to    hostname=${${hostname}_IP}
    ...    username=${${hostname}_USERNAME}
    ...    password=${${hostname}_PASSWORD}
    ...    alias=${hostname}    proxy=${proxy}    timeout=10 s

Get file name
    [Arguments]     ${file_params}    ${connection}
    ssh.Send command    command=find ${${file_params}.compressed_file_path} -type f -name ${${file_params}.compressed_file_name_regex}
    ...    connection=${connection}    timeout=15 s
    ${output} =    ssh.Read output    connection=${connection}
    ${path_elements} =    String.Split String From Right    ${output}    /
    ${path_elements_length} =    Get Length    ${path_elements}
    ${path_elements_length} =    Evaluate    ${path_elements_length}-1
    ${file_name} =     Get From List    ${path_elements}    ${path_elements_length}
    ${file_name} =     Set Variable    ${file_name.replace("\n", "").replace("\r", "")}
    [Return]    ${file_name}

Prepare extraction argument
    [Arguments]     ${file_name}    ${file_params}
    ${argument_1} =    Set variable    ${${file_params}.tmp_file_path}${file_name}
    ${argument_2} =    Set variable    -C ${${file_params}.tmp_file_path}
    ${argument_3} =    Set variable    ${${file_params}.compressed_file_path}
    ${argument} =    Run keyword if    "txz" in """${file_name}"""
    ...    Catenate    ${argument_1.replace("\n", "")}    ${argument_2.replace("\n", "")}
    ...    ELSE IF    "zip" in """${file_name}"""    Catenate    ${argument_3.replace("\n", "")}    ${argument_1.replace("\n", "")}
    ...    ELSE    ${argument_1.replace("\n", "")}
    [Return]    ${argument}

Extract file
    [Arguments]     ${file_name}    ${file_params}    ${connection}    ${sudo_execution}=${FALSE}
    Log to console    Extracting file: ${file_name}
    ssh.Send command    command=mkdir ${${file_params}.tmp_file_path}   connection=${connection}    timeout=10s
    ssh.Send command    command=cp ${${file_params}.compressed_file_path}${file_name} ${${file_params}.tmp_file_path}
    ...  connection=${connection}
    ...  timeout=10s
    ${argument} =    Prepare extraction argument    ${file_name}    ${file_params}
    Run keyword if    "txz" in """${file_name}""" and ${sudo_execution} == ${FALSE}
    ...    Run keywords    ssh.Send command    command=tar -xvf ${argument}    connection=${connection}    timeout=10s
    ...    AND    ssh.Await Execution End    connection=${connection}    timeout=180s
    ...    ELSE IF    "txz" in """${file_name}""" and ${sudo_execution} == ${TRUE}
    ...    ssh.Execute    sudo tar --overwrite -xvf ${argument}    connection=${connection}
    ...    ELSE IF    "xz" in """${file_name}""" and ${sudo_execution} == ${FALSE}
    ...    ssh.Execute    unxz ${argument}        connection=${connection}
    ...    ELSE IF    "xz" in """${file_name}""" and ${sudo_execution} == ${TRUE}
    ...    ssh.Execute    sudo unxz ${argument}    connection=${connection}
    ...    ELSE IF    "zip" in """${file_name}""" and ${sudo_execution} == ${FALSE}
    ...    ssh.Execute    unzip -o -d ${argument}    connection=${connection}
    ...    ELSE IF    "zip" in """${file_name}""" and ${sudo_execution} == ${TRUE}
    ...    ssh.Execute    sudo unzip -o -d ${argument}
    ...    connection=${connection}
    ...    ELSE    FAIL    msg=Unknown compression type

Compress and crasign RandD parameters file
    [Arguments]     ${file_name}    ${RandDParametersFile}    ${connection}
    ${compress_user_info} =    Catenate    SEPARATOR=
    ...    Compressing folders ${${RandDParametersFile}.tmp_file_path}opt/ and ${${RandDParametersFile}.tmp_file_path}
    ...    usr/ into file ${file_name}
    Log to console    ${compress_user_info}
    ${command_compress_randd_addon} =    Catenate    SEPARATOR=
    ...    tar --overwrite -cvf ${${RandDParametersFile}.tmp_file_path}${file_name} -C ${${RandDParametersFile}.tmp_file_path}
    ...    . ./opt/ ./usr/
    ssh.Send command    command=${command_compress_randd_addon}    connection=gNB_CLASSICAL_OAM    timeout=10s
    ssh.Await Execution End    connection=gNB_CLASSICAL_OAM    timeout=180s
    ssh.Send command    command=cp ${${RandDParametersFile}.tmp_file_path}${file_name} ${${RandDParametersFile}.compressed_file_path}${file_name}
    ...  connection=${connection}
    ...  timeout=10s
    ssh.Await Execution End    connection=gNB_CLASSICAL_OAM    timeout=180s
    ssh.Send command    command=crasign ${${RandDParametersFile}.compressed_file_path}${file_name}    connection=${connection}    timeout=10s
    ssh.Await Execution End    connection=${connection}    timeout=15s
    ssh.Send command    command=rm -rf ${${RandDParametersFile}.tmp_file_path}   connection=${connection}   timeout=10s

Change RandD flag value
    [Arguments]     ${flag}     ${value}    ${connection}
    Log to console    \nChanging flag: ${${flag}.name} value into: ${value}, in file ${${flag}.file_name}
    ssh.Send command    command=sed -i -E 's/${${flag}.name}.*/${${flag}.name}\=${value}/g' ${${flag}.file_path}${${flag}.file_name}
    ...    connection=${connection}    timeout=10s
    ssh.Await Execution End    connection=${connection}    timeout=20 s

Delete HashContainer files
    [Arguments]     ${connection}
    ssh.Send command
    ...    command=rm /ffs/run/HashContainer*
    ...    connection=${connection}
    ...    timeout=10s
    ssh.Await Execution End
    ...    connection=${connection}
    ...    timeout=20 s

Modify AP swconfig file
    [Arguments]     ${parameters_list}    ${connection}
    FOR  ${hex_with_value}   IN   @{parameters_list}
        ${flag_hex}    Fetch From Left    string=${hex_with_value}    marker=\=
        ssh.Send command    command=rm ${AP_SWCONFIG}.p7    connection=${connection}    timeout=10s
        ssh.Send command
        ...  command=grep '${flag_hex}' ${AP_SWCONFIG} && sed -i -E 's/${flag_hex}.*/${hex_with_value}/g' ${AP_SWCONFIG}
        ...  connection=${connection}
        ...  timeout=10s
        ssh.Send command
        ...  command=grep '${hex_with_value}' ${AP_SWCONFIG} || echo '${hex_with_value}' >> ${AP_SWCONFIG}
        ...  connection=${connection}
        ...  timeout=10s
        ssh.Send command    command=crasign ${AP_SWCONFIG}    connection=${connection}    timeout=10s
    END
