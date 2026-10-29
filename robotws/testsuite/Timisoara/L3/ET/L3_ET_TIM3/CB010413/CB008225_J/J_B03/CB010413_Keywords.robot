*** Settings ***


Library    pharsedcap.py
#Library    DateTime
#Library    BuiltIn
#Library    ta_pcmd

*** Variables ***


${labpcname}=                                            NOKLAB\\\\rfsharing
${labpcpass}=                                            Nokia2022!@1
${labpcip}=                                              10.5.53.88
#${dest}=             C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}
#${file_path}=       "/${OUTPUT_DIR}/ipcaptureExtracted/vdu_celltrace.lcbin"

${alias}=                                                sshpc
${UTE_SSH_IP}=                                           ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_SSH_USER_NAME}=                                    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_SSH_PASSWORD}=                                     ${tl.test_pc.default_ssh_connection_details.password}

*** Keywords ***

Mkdir PC Emil
#[Arguments]      ${dirname}
    ${tl_name}      Run   uname -a|awk '{print $2}'

    ${cmd0}  Set Variable    "cd C:\\Users\\rfsharing\\Documents\\Logs\\ && rmdir /S /Q robot_script_${tl_name}"
    ${cmd1}  Set Variable    mkdir C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}
    ${cmd2}  Set Variable    mkdir C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}\\\\csv
    ${cmd3}  Set Variable    mkdir C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}\\\\5gm
    ${cmd4}  Set Variable    mkdir C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}\\\\lcbin
    Run    sshpass -p 'Nokia2022!@1' ssh ${labpcname}@${labpcip} ${cmd0}
    log to console    sleep 3s
    sleep    3s
    Run    sshpass -p 'Nokia2022!@1' ssh ${labpcname}@${labpcip} ${cmd1}
    Run    sshpass -p 'Nokia2022!@1' ssh ${labpcname}@${labpcip} ${cmd2}
    Run    sshpass -p 'Nokia2022!@1' ssh ${labpcname}@${labpcip} ${cmd3}
    Run    sshpass -p 'Nokia2022!@1' ssh ${labpcname}@${labpcip} ${cmd4}

Get TL hostname
    ${result} = 	Run   uname -a|awk '{print $2}'
    [Return]  ${result}

Convert 5gm Files To Csv
    [Documentation]        Convert 5G Control Plane logs collected from DCAP
    Log to console      \nConverting 5G Control Plane logs and verifying
    Run  rm -rf ${OUTPUT_DIR}/5gm
    Run  mkdir ${OUTPUT_DIR}/5gm
    ${tl_name}      CB010413_Keywords.Get TL hostname
    ${log_path} 	Set Variable         C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\5gm\\
#    ${year}    Get Current Date    result_format=%Y
#    ${month}    Get Current Date    result_format=%m
#    ${day}    Get Current Date    result_format=%d
#    ${date}    Set Variable    ${year}${month}${day}
    ${cmd_part1}    Set Variable    start /wait Emil.exe
    ${cmd_part2}    Set Variable     "C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}\\\\5gm\\\\*.5gm
    ${cmd_part3}    Set Variable     -tocsv -autoclose -destination
    ${cmd_part4}    Set Variable     "C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}\\\\csv\\\\
    ${cmd_part5}    Set Variable     -Profile SourceProfileUser.ini -ProfilePath "C:\\\\profiles\\\\5G"
    ${cmd} 	        Set Variable	 ${cmd_part1} ${cmd_part2} ${cmd_part3} ${cmd_part4} ${cmd_part5}
    Run    sshpass -p 'Nokia2022!@1' ssh ${labpcname}@${labpcip} ${cmd}

Convert lcbin Files To Csv
    [Documentation]        Convert Cell Trace logs collected from DCAP
    Log to console      \nConverting Cell Trace logs and verifying
    Run  rm -rf ${OUTPUT_DIR}/lcbin
    Run  mkdir ${OUTPUT_DIR}/lcbin
    ${tl_name}      CB010413_Keywords.Get TL hostname
    ${log_path} 	Set Variable         C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\
#    ${year}    Get Current Date    result_format=%Y
#    ${month}    Get Current Date    result_format=%m
#    ${day}    Get Current Date    result_format=%d
#    ${date}    Set Variable    ${year}${month}${day}
    ${cmd_part1}    Set Variable    start /wait Emil.exe
    ${cmd_part2}    Set Variable     "C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}\\\\lcbin\\\\*.lcbin
    ${cmd_part3}    Set Variable     -tocsv -autoclose -destination
    ${cmd_part4}    Set Variable     "C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}\\\\csv\\\\
    ${cmd_part5}    Set Variable     -Profile SourceProfileUser.ini -ProfilePath "C:\\\\profiles\\\\5G_Cell_Trace"
    ${cmd} 	        Set Variable	 ${cmd_part1} ${cmd_part2} ${cmd_part3} ${cmd_part4} ${cmd_part5}
    Run    sshpass -p 'Nokia2022!@1' ssh ${labpcname}@${labpcip} ${cmd}

Send csv from PC to VM
    [Documentation]        Send csv from PC to VM
    Log to console      \nConverting Cell Trace logs and verifying
    ${tl_name}      CB010413_Keywords.Get TL hostname
    ${log_path} 	Set Variable         C:\\Users\\rfsharing\\Documents\\Logs\\robot_script_${tl_name}\\
#    ${year}    Get Current Date    result_format=%Y
#    ${month}    Get Current Date    result_format=%m
#    ${day}    Get Current Date    result_format=%d
#    ${date}    Set Variable    ${year}${month}${day}
    ${cmd_part1}    Set Variable    :"C:/Users/rfsharing/Documents/Logs/robot_script_${tl_name}/csv/5gm.csv""
    ${cmd_part2}    Set Variable    /${OUTPUT_DIR}/5gm
    ${cmd_part11}    Set Variable    :"C:/Users/rfsharing/Documents/Logs/robot_script_${tl_name}/csv/vdu_emil.csv""
    ${cmd_part12}    Set Variable    /${OUTPUT_DIR}/5gm
    ${cmd_part111}    Set Variable    :"C:/Users/rfsharing/Documents/Logs/robot_script_${tl_name}/csv/vcu_emil.csv""
    ${cmd_part112}    Set Variable    /${OUTPUT_DIR}/5gm
    ${cmd_part3}    Set Variable    :"C:/Users/rfsharing/Documents/Logs/robot_script_${tl_name}/csv/lcbin.csv""
    ${cmd_part4}    Set Variable    /${OUTPUT_DIR}/lcbin
    ${cmd_part13}    Set Variable    :"C:/Users/rfsharing/Documents/Logs/robot_script_${tl_name}/csv/vdu_celltrace.csv""
    ${cmd_part14}    Set Variable    /${OUTPUT_DIR}/lcbin
    ${cmd_part113}    Set Variable    :"C:/Users/rfsharing/Documents/Logs/robot_script_${tl_name}/csv/vcu_celltrace.csv""
    ${cmd_part114}    Set Variable    /${OUTPUT_DIR}/lcbin
#    ${cmd_partt}    Set Variable     dir C:\\\\Users\\\\rfsharing\\\\Documents\\\\Logs\\\\robot_script_${tl_name}\\\\
    ${cmd1} 	        Set Variable	 ${cmd_part1} ${cmd_part2}
    ${cmd2} 	        Set Variable	 ${cmd_part11} ${cmd_part12}
    ${cmd3} 	        Set Variable	 ${cmd_part111} ${cmd_part112}
    ${cmd4} 	        Set Variable	 ${cmd_part3} ${cmd_part4}
    ${cmd5} 	        Set Variable	 ${cmd_part13} ${cmd_part14}
    ${cmd6} 	        Set Variable	 ${cmd_part113} ${cmd_part114}
    Run    sshpass -p 'Nokia2022!@1' scp "${labpcname}@${labpcip}${cmd1}
    Run    sshpass -p 'Nokia2022!@1' scp "${labpcname}@${labpcip}${cmd2}
    Run    sshpass -p 'Nokia2022!@1' scp "${labpcname}@${labpcip}${cmd3}
    Run    sshpass -p 'Nokia2022!@1' scp "${labpcname}@${labpcip}${cmd4}
    Run    sshpass -p 'Nokia2022!@1' scp "${labpcname}@${labpcip}${cmd5}
    Run    sshpass -p 'Nokia2022!@1' scp "${labpcname}@${labpcip}${cmd6}

Check msg in Control Plane logs
    [Arguments]    ${msg}
    ...            ${csv_path}=${OUTPUT_DIR}/5gm
	${result}		Parse Emil Csv File For Message 	 ${csv_path}		${msg}
	Should Be True		${result}

Check msg in Cell Trace logs
    [Arguments]    ${msg}
    ...            ${csv_path}=${OUTPUT_DIR}/lcbin
	${result}		Parse Emil Csv File For Message 	 ${csv_path}		${msg}
	Should Be True		${result}

Copy DCAP Logs on VM in classical path
#    [Arguments]    log_type
    Run    mkdir /${OUTPUT_DIR}/ipcaptureExtracted
    Run    mkdir /${OUTPUT_DIR}/ipcaptureExtracted/5gm
    Run    mkdir /${OUTPUT_DIR}/ipcaptureExtracted/lcbin
    Run    cp /home/ute/dcaplogs/${TC_Name}/gNB/vducontrolplane/vducontrol/emil.5gm /${OUTPUT_DIR}/ipcaptureExtracted/5gm/vdu_emil.5gm
    sleep    2s
    Run    cp /home/ute/dcaplogs/${TC_Name}/gNB/vcucontrolplane/vcucontrol/emil.5gm /${OUTPUT_DIR}/ipcaptureExtracted/5gm/vcu_emil.5gm
    sleep    2s
    Run    cp /home/ute/dcaplogs/${TC_Name}/gNB/vcucelltrace/vcucelltrace/*.lcbin /${OUTPUT_DIR}/ipcaptureExtracted/lcbin/vcu_celltrace.lcbin
    sleep    2s
    Run    cp /home/ute/dcaplogs/${TC_Name}/gNB/vducelltrace/vducelltrace/*.lcbin /${OUTPUT_DIR}/ipcaptureExtracted/lcbin/vdu_celltrace.lcbin

Cleanup EMil dir
    ${tl_name}      CB010413_Keywords.Get TL hostname
    ${cmd0}  Set Variable    "cd C:\\Users\\rfsharing\\Documents\\Logs\\ && rmdir /S /Q robot_script_${tl_name}"
    Run    sshpass -p 'Nokia2022!@1' ssh ${labpcname}@${labpcip} ${cmd0}

