*** Settings ***
Library      taf.transport.ssh    WITH NAME    ssh
Library      DateTime
Library      Emil_processing_keywords.py
Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../resources/dcap.robot

*** Variables ***
${labpcip}=                                               10.5.53.96
${labpcname}=                                             NOKLAB\\rfsharing
${labpcpass}=                                             Nokia2022!@1
${sourceProfile}=                                         C:\\Program Files\\Emil\\profiles\\5G\\SourceProfile.ini
${Emil_keywords}=                                         ${CURDIR}/Emil_processing_keywords.py
${tes_emil}=                                              ${CURDIR}/test_emil.robot
${profile_path}=                                          C:\\Program Files\\Emil\\profiles
${emil_log_path}=                                         C:\\Emil_logs\\
${msg_id_info_file}=                                      ${CURDIR}/config/msg_id_emil.dat
${end_file}=                                              .5gm
${VM_ETH_IFACES}=    sudo ip addr add 10.0.2.1/24 dev eth4;
...  sudo ip addr add 10.0.1.121/24 dev eth3;
...  sudo ip addr add 10.0.1.122/24 dev eth3;
...  sudo ip addr add 10.0.1.123/24 dev eth3;
...  sudo ip addr add 10.0.1.124/24 dev eth3;
...  sudo ip addr add 10.0.1.125/24 dev eth3;
...  sudo ip addr add 10.0.1.126/24 dev eth3;
...  sudo ip addr add 10.0.1.127/24 dev eth3;
...  sudo ip addr add 10.0.1.128/24 dev eth3;
...  sudo ip addr add 10.0.1.129/24 dev eth3;
...  sudo ip addr add 10.0.1.130/24 dev eth3;
...  sudo ip addr add 10.0.1.131/24 dev eth3;
...  sudo ip addr add 10.0.1.132/24 dev eth3;
...  sudo ip addr add 10.0.1.133/24 dev eth3;
...  sudo ip addr add 10.0.1.134/24 dev eth3;
...  sudo ip addr add 10.0.1.135/24 dev eth3;
...  sudo ip addr add 10.0.1.136/24 dev eth3;
...  sudo ip addr add 10.0.1.137/24 dev eth3;
...  sudo ip addr add 10.0.1.138/24 dev eth3;
...  sudo ip addr add 10.0.1.139/24 dev eth3;
...  sudo ip addr add 10.0.1.140/24 dev eth3;
...  sudo ip addr add 10.0.1.141/24 dev eth3;
...  sudo ip addr add 10.0.1.142/24 dev eth3;
...  sudo ip addr add 10.0.1.143/24 dev eth3;
...  sudo ip addr add 10.0.1.144/24 dev eth3;
...  sudo ip addr add 10.0.1.145/24 dev eth3;
...  sudo ip addr add 10.0.1.146/24 dev eth3;
...  sudo ip addr add 10.0.1.147/24 dev eth3;
...  sudo ip addr add 10.0.1.148/24 dev eth3;
...  sudo ip addr add 10.0.1.149/24 dev eth3;
...  sudo ip addr add 10.0.1.150/24 dev eth3;
...  sudo ip addr add 10.0.1.151/24 dev eth3;
...  sudo ip addr add 10.0.1.152/24 dev eth3;
...  sudo ip addr add 10.0.1.153/24 dev eth3;
...  sudo ip addr add 10.0.1.154/24 dev eth3;
...  sudo ip addr add 10.0.1.155/24 dev eth3;
...  sudo ip addr add 10.0.1.161/24 dev eth3;
...  sudo ip addr add 10.0.1.162/24 dev eth3;
...  sudo ip addr add 10.0.1.163/24 dev eth3;
...  sudo ip addr add 10.0.2.90/24 dev eth4;
...  sudo ip addr add 10.0.2.91/24 dev eth4;
...  sudo ip addr add 10.0.2.92/24 dev eth4;
...  sudo ip addr add 10.0.2.93/24 dev eth4;
...  sudo ip addr add 10.0.2.94/24 dev eth4;
...  sudo ip addr add 10.0.2.95/24 dev eth4;
...  sudo ip addr add 10.0.2.96/24 dev eth4;
...  sudo ip addr add 10.0.2.97/24 dev eth4;
...  sudo ip addr add 10.0.2.98/24 dev eth4;
...  sudo ip addr add 10.0.2.99/24 dev eth4;
...  sudo ip addr add 10.0.2.100/24 dev eth4;
...  sudo ip addr add 10.0.1.9/24 dev eth3;
...  sudo ip addr add 10.0.1.10/24 dev eth3;
...  sudo ip addr add 10.0.1.11/24 dev eth3;
...  sudo ip addr add 10.0.1.12/24 dev eth3;
...  sudo ip addr add 10.0.1.13/24 dev eth3;
...  sudo ip addr add 10.0.1.14/24 dev eth3;
...  sudo ip addr add 10.0.1.15/24 dev eth3;
...  sudo ip addr add 10.0.1.100/24 dev eth3;
...  sudo ip addr add 10.0.1.101/24 dev eth3;
...  sudo ip addr add 10.0.1.102/24 dev eth3;
...  sudo ip addr add 10.0.1.103/24 dev eth3;
...  sudo ip addr add 10.0.1.104/24 dev eth3;
...  sudo ip addr add 10.0.1.105/24 dev eth3;
...  sudo ip addr add 10.0.1.106/24 dev eth3;
...  sudo ip addr add 10.0.1.107/24 dev eth3;
...  sudo ip addr add 10.0.1.108/24 dev eth3;
...  sudo ip addr add 10.0.1.109/24 dev eth3;
...  sudo ip addr add 10.0.1.3/24 dev eth3;
...  sudo ip addr add 10.0.1.4/24 dev eth3;
...  sudo ip addr add 10.0.1.112/24 dev eth3

*** Keywords ***
Mkdir for EMil script and logs
    ssh.connect to      hostname=${labpcip}    username=${labpcname}     password=${labpcpass}    alias=LabPC
#    ssh.send_command    command=mkdir C:/robot_script     connection=LabPC
#    ssh.send_command    command=mkdir C:/Emil_logs     connection=LabPC
    ssh.send_command    command=mkdir C:/Logs_after_test     connection=LabPC
    [Teardown]  ssh.Disconnect    connection=LabPC

Send Emil logs
    [Arguments]    ${dcap_filepath}
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable         C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\
    log to console     message=copy logs to labpc
    ssh.Connect to    hostname=${UTE_SSH_IP}    username=${UTE_SSH_USER_NAME}  password=${UTE_SSH_PASSWORD}
    ssh.Execute     command=sudo sshpass -p '${labpcpass}' scp ${dcap_filepath} ${labpcname}@${labpcip}:${log_path}
#    Run   command=sshpass -p '${labpcpass}' scp ${sourceProfile} ${labpcname}@${labpcip}:${profile_path}
#    Run   command=sshpass -p '${labpcpass}' scp ${Emil_keywords} ${labpcname}@${labpcip}:C:/robot_script
#    Run   command=sshpass -p '${labpcpass}' scp ${tes_emil} ${labpcname}@${labpcip}:C:/robot_script
#    Run   command=sshpass -p '${labpcpass}' scp ${dcap_filepath} ${labpcname}@${labpcip}:${log_path}


Generate txt files
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable         C:\\Emil_logs\\
    ssh.connect to      hostname=${labpcip}    username=${labpcname}     password=${labpcpass}    alias=LabPC
    ${output_dir_normal}    Convert_Emil_log_to_txt    log_path=${log_path}    end_file=${end_file}
	${output_dir_scrambled}    Covert_Emil_log_to_txt_with_scrambled    log_path=${log_path}    end_file=${end_file}
	set suite variable    ${output_dir_normal}    ${output_dir_normal}
	set suite variable    ${output_dir_scrambled}    ${output_dir_scrambled}
    [Teardown]  ssh.Disconnect    connection=LabPC

Generate text file
    [Documentation]        Convert 5G Control Plane logs collected from DCAP
    Log to console      \nConverting 5G Control Plane logs and verifying
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable         C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\
    ${year}    Get Current Date    result_format=%Y
    ${month}    Get Current Date    result_format=%m
    ${day}    Get Current Date    result_format=%d
    ${date}    Set Variable    ${year}${month}${day}
    SYSTEM Open SSH Connection
    ${it}=           SSHLibrary.Execute Command   cd ${log_path}${date} & cmd /c "dir /b /ad"
    @{all_log_folders}=    Split String Clean    ${it}    \n
    FOR    ${log_folder}    IN    @{all_log_folders}
        Run keyword And Ignore Error    Start Emil To Convert 5gm Files To Text File    source_path=${log_path}${date}
        ...     source_file=${log_folder}\\5g\\controlPlane
    END
	SSHLibrary.Close All Connections

Generate scrambled emil file
    [Documentation]        Scramble 5G Control Plane logs collected from DCAP
    Log to console      \nScrambling 5G Control Plane logs and verifying
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable         C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\
    ${year}    Get Current Date    result_format=%Y
    ${month}    Get Current Date    result_format=%m
    ${day}    Get Current Date    result_format=%d
    ${date}    Set Variable    ${year}${month}${day}
    SYSTEM Open SSH Connection
    ${it}=           SSHLibrary.Execute Command   cd ${log_path}${date} & cmd /c "dir /b /ad"
    @{all_log_folders}=    Split String Clean    ${it}    \n
    FOR    ${log_folder}    IN    @{all_log_folders}
        Run keyword And Ignore Error    Start Emil to Scramble Emil logs    source_path=${log_path}${date}
        ...     source_file=${log_folder}\\5g\\controlPlane
    END
	SSHLibrary.Close All Connections

Start Emil to Scramble Emil logs
    [Arguments]    ${source_path}     ${source_file}
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable      C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}
    ${source_emil_file}=    SSHLibrary.Execute Command   cd ${source_path}\\${source_file} & dir /A-D /B
    ${log_file_name}=     Remove String    ${source_emil_file}    \r    \n
    Log to console  ${log_file_name}
    ${src_file}     Set Variable     ${source_path}\\${source_file}\\${log_file_name}
    ${src_file}=    Replace String    ${src_file}    \\    \\\\
    ${dst_path}=    Set Variable     ${source_path}\\${source_file}\\SCRAMBLED\\
    ${dst_path}=    Replace String    ${dst_path}    \\    \\\\
    ${cmd_part1}  Set Variable  start /wait Emil.exe "${src_file}" -scramble -autoclose
    ${cmd_part2}  Set Variable  -ScramblePath "${dst_path}"
	${cmd} 	        Set Variable	 ${cmd_part1} ${cmd_part2}
	LOG	    ${cmd}
	${output}      SSHLibrary.Execute Command   ${cmd}
	LOG		${output}
	${src_file}=    Replace String    ${src_file}    .5gm    _scrambled.emil
    SSHLibrary.Execute Command   echo y | pscp -pw ${UTE_SSH_PASSWORD} ${src_file} ${UTE_SSH_USER_NAME}@${UTE_SSH_IP}:${OUTPUT_DIR}

Generate scrambled text file
    [Documentation]        Convert 5G Control Plane logs collected from DCAP
    Log to console      \nConverting 5G Control Plane logs and verifying
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable         C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\
    ${year}    Get Current Date    result_format=%Y
    ${month}    Get Current Date    result_format=%m
    ${day}    Get Current Date    result_format=%d
    ${date}    Set Variable    ${year}${month}${day}
    SYSTEM Open SSH Connection
    ${it}=           SSHLibrary.Execute Command   cd ${log_path}${date} & cmd /c "dir /b /ad"
    @{all_log_folders}=    Split String Clean    ${it}    \n
    FOR    ${log_folder}    IN    @{all_log_folders}
        Run keyword And Ignore Error    Start Emil To Convert Scrambled Files To Text File    source_path=${log_path}${date}
        ...     source_file=${log_folder}\\5g\\controlPlane
    END
	SSHLibrary.Close All Connections

Start Emil To Convert 5gm Files To Text File
    [Arguments]    ${source_path}     ${source_file}
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable      C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\TXT\\
    ${source_emil_file}=    SSHLibrary.Execute Command   cd ${source_path}\\${source_file} & dir /A-D /B
    ${log_file_name}=     Remove String    ${source_emil_file}    \r    \n
    ${converted_emil_file}=     Remove String   ${log_file_name}    .5gm
    Log to console  ${log_file_name}
    Log to console  ${converted_emil_file}
    ${src_file}     Set Variable     ${source_path}\\${source_file}\\${log_file_name}
    ${src_file}=    Replace String    ${src_file}    \\    \\\\
    ${cmd_part1}  Set Variable  start /wait Emil.exe "${src_file}" -AutoClose -Variable
    ${cmd_part2}  Set Variable  OutPath "C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}
    ${cmd_part3}  Set Variable  \\\\TXT\\\\${converted_emil_file}_notscrambled.txt"
    ${cmd_part4}  Set Variable  -Profile SourceProfileUser.ini -ProfilePath "C:\\\\Program Files\\\\Emil\\\\profiles\\\\5G"
	${cmd} 	      Set Variable	${cmd_part1} ${cmd_part2}${cmd_part3} ${cmd_part4}
	LOG	    ${cmd}
	${output}      SSHLibrary.Execute Command   ${cmd}
	LOG		${output}
	${log_file_name}=    Replace String    ${log_file_name}    .5gm    _notscrambled.txt
	${cp_cmd1}   Set Variable      echo y | pscp -pw ${UTE_SSH_PASSWORD} ${log_path}${log_file_name}
    ${cp_cmd2}   Set Variable      ${UTE_SSH_USER_NAME}@${UTE_SSH_IP}:${OUTPUT_DIR}
    ${cp_cmd}    Set Variable      ${cp_cmd1} ${cp_cmd2}
    SSHLibrary.Execute Command     ${cp_cmd}



Start Emil To Convert Scrambled Files To Text File
    [Arguments]    ${source_path}     ${source_file}
    ${tl_name}      Get TL hostname
    ${log_path} 	Set Variable      C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\TXT\\
    ${source_emil_file}=    SSHLibrary.Execute Command   cd ${source_path}\\${source_file} & dir /A-D /B
    ${log_file_name}=     Remove String    ${source_emil_file}    \r    \n
    ${scrambled_emil_file}=     Replace String   ${log_file_name}   .5gm   _scrambled.emil
    ${converted_emil_file}=     Remove String   ${scrambled_emil_file}    .emil
    Log to console  ${log_file_name}
    Log to console  ${scrambled_emil_file}
    Log to console  ${converted_emil_file}
    ${src_file}     Set Variable     ${source_path}\\${source_file}\\SCRAMBLED\\*_scrambled.emil
    ${src_file}=    Replace String    ${src_file}    \\    \\\\
    ${cmd_part1}  Set Variable  start /wait Emil.exe "${src_file}" -AutoClose -Variable
    ${cmd_part2}  Set Variable  OutPath "C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}
    ${cmd_part3}  Set Variable  \\\\TXT\\\\${converted_emil_file}.txt"
    ${cmd_part4}  Set Variable  -Profile SourceProfileUser.ini -ProfilePath "C:\\\\Program Files\\\\Emil\\\\profiles\\\\5G"
	${cmd} 	        Set Variable	 ${cmd_part1} ${cmd_part2}${cmd_part3} ${cmd_part4}
	LOG	    ${cmd}
	${output}      SSHLibrary.Execute Command   ${cmd}
	LOG		${output}
	${scrambled_emil_file}=    Replace String    ${scrambled_emil_file}    .emil    .txt
    ${cp_cmd1}   Set Variable      echo y | pscp -pw ${UTE_SSH_PASSWORD} ${log_path}${converted_emil_file}.txt
    ${cp_cmd2}   Set Variable      ${UTE_SSH_USER_NAME}@${UTE_SSH_IP}:${OUTPUT_DIR}
    ${cp_cmd}    Set Variable      ${cp_cmd1} ${cp_cmd2}
    SSHLibrary.Execute Command     ${cp_cmd}

Check parameter in the message has scrambled
    [Arguments]    ${msg_name}    ${para_name}
    ssh.Connect to    hostname=${UTE_SSH_IP}    username=${UTE_SSH_USER_NAME}  password=${UTE_SSH_PASSWORD}
    ssh.Execute   command=mkdir ${OUTPUT_DIR}/${TEST_NAME}/scrambled
    ssh.Execute   command=mv $(find ${OUTPUT_DIR}/*_scrambled.txt) ${OUTPUT_DIR}/${TEST_NAME}/scrambled/
    @{scrambled_list}   OperatingSystem.List Files in Directory  ${OUTPUT_DIR}/${TEST_NAME}/scrambled/
    ssh.Execute   command=mkdir ${OUTPUT_DIR}/${TEST_NAME}/notscrambled
    ssh.Execute   command=mv $(find ${OUTPUT_DIR}/*_notscrambled.txt) ${OUTPUT_DIR}/${TEST_NAME}/notscrambled/
    @{notscrambled_list}   OperatingSystem.List Files in Directory  ${OUTPUT_DIR}/${TEST_NAME}/notscrambled/
    FOR    ${notscrambled_file}    IN    @{notscrambled_list}
        ${para_normal}    get_emil_msg_parameter_value
        ...      file_path=${OUTPUT_DIR}/${TEST_NAME}/notscrambled/${notscrambled_file}    msg_name=${msg_name}    para_name=${para_name}
        EXIT FOR LOOP IF    '${para_normal}' != 'None'
        Log    ${para_normal}
    END
    FOR    ${scrambled_file}    IN    @{scrambled_list}
        ${para_scrambled}    get_emil_msg_parameter_value
        ...       file_path=${OUTPUT_DIR}/${TEST_NAME}/scrambled/${scrambled_file}         msg_name=${msg_name}    para_name=${para_name}
        EXIT FOR LOOP IF    '${para_scrambled}' != 'None'
        Log    ${para_scrambled}
    END
    should not be equal    first=${para_normal}    second=${para_scrambled}    msg=the value of ${para_name} is not scrambled.

Check parameter in the message has not scrambled
    [Arguments]    ${msg_name}    ${para_name}
    ssh.Connect to    hostname=${UTE_SSH_IP}    username=${UTE_SSH_USER_NAME}  password=${UTE_SSH_PASSWORD}
    ssh.Execute   command=mkdir ${OUTPUT_DIR}/${TEST_NAME}/scrambled
    ssh.Execute   command=mv $(find ${OUTPUT_DIR}/*_scrambled.txt) ${OUTPUT_DIR}/${TEST_NAME}/scrambled/
    @{scrambled_list}   OperatingSystem.List Files in Directory  ${OUTPUT_DIR}/${TEST_NAME}/scrambled/
    ssh.Execute   command=mkdir ${OUTPUT_DIR}/${TEST_NAME}/notscrambled
    ssh.Execute   command=mv $(find ${OUTPUT_DIR}/*_notscrambled.txt) ${OUTPUT_DIR}/${TEST_NAME}/notscrambled/
    @{notscrambled_list}   OperatingSystem.List Files in Directory  ${OUTPUT_DIR}/${TEST_NAME}/notscrambled/
    FOR    ${notscrambled_file}    IN    @{notscrambled_list}
        ${para_normal}    get_emil_msg_parameter_value
        ...      file_path=${OUTPUT_DIR}/${TEST_NAME}/notscrambled/${notscrambled_file}    msg_name=${msg_name}    para_name=${para_name}
        EXIT FOR LOOP IF    '${para_normal}' != 'None'
        Log    ${para_normal}
    END
    FOR    ${scrambled_file}    IN    @{scrambled_list}
        ${para_scrambled}    get_emil_msg_parameter_value
        ...       file_path=${OUTPUT_DIR}/${TEST_NAME}/scrambled/${scrambled_file}         msg_name=${msg_name}    para_name=${para_name}
        EXIT FOR LOOP IF    '${para_scrambled}' != 'None'
        Log    ${para_scrambled}
    END
    should be equal    first=${para_normal}    second=${para_scrambled}    msg=the value of ${para_name} is not scrambled.

Get the exact emil log
    [Arguments]    ${DCAP_log_path}
    ssh.Connect to    hostname=${UTE_SSH_IP}    username=${UTE_SSH_USER_NAME}  password=${UTE_SSH_PASSWORD}   alias=ute
    Log     \n Download DCAP log to UTE
#    csn.Execute   command=find ${TS_CASE_LOG_PATH} -type f -not -name '*.zip' -delete    connection=ute
    Run   command=unzip ${TS_CASE_LOG_PATH}*.zip -d ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    #csn.Execute   command=unzip ${DCAP_log_path} -d ${TS_CASE_LOG_PATH}/dcap_tmp    connection=ute
    ${emil_log_name}    csn.Execute   ls -R ${TS_CASE_LOG_PATH}/dcap_tmp | grep .5gm    connection=ute
    ${emil_log_name}    strip string    ${emil_log_name}
    Run   command=cp $(find ${TS_CASE_LOG_PATH} -name ${emil_log_name}) ${TS_CASE_LOG_PATH}    connection=ute
    log to console    \n Get Emil log
    Run   command=rm -rf ${TS_CASE_LOG_PATH}dcap_tmp    connection=ute
    @{emil_log}=    Create List    ${TS_CASE_LOG_PATH}${emil_log_name}
    [Return]    @{emil_log}
    [Teardown]    csn.Disconnect     connection=ute

Confirm if DCAP traces are downloaded
    ssh.Connect to    hostname=${UTE_SSH_IP}    username=${UTE_SSH_USER_NAME}  password=${UTE_SSH_PASSWORD}   alias=ute
    ${command}  set variable   find ${OUTPUT_DIR}/suite_setup_logs/DCAP_Traces.zip -type f
    Run  ${command}
    ${output_path}  SSHLibrary.Read  delay=5s
    Log to console   ${output_path}
    Should Contain  ${output_path}   ${OUTPUT_DIR}/suite_setup_logs/DCAP_Traces.zip
