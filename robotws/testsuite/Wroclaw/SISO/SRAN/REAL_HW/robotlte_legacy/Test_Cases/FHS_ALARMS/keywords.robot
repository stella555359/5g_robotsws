*** Settings ***

Documentation
...    Author:   tomasz.zadworny@nokia.com
...    Maintainer:    Author

Library    Collections
Library    Process
Library    String
Library    XML    use_lxml=true
Library    OperatingSystem


Library    taf.config.scf  WITH NAME  scf
Library   ../../operations.py
Library    taf.transport.ssh

Resource   ../../others.robot

*** Variables ***
&{SMOD1}  IP=192.168.255.1  USERNAME=toor4nsn  PASSWORD=oZPS0POrRieRtu
*** Keywords ***
Generate fault 1933 on FHS module by file modifications
    [Arguments]   ${fhs_under_test_serial_number}  ${alias}=${cfg.primary_node_bts_id}
    Set test variable  ${FHS_SERIAL}  ${fhs_under_test_serial_number}
    ${FHS_INFO}=  Get Infomodel Object   //BTS_L-*/EQM_L-1/FHS_L-* is [serialNumber="${FHS_SERIAL}"]    alias=${alias}
    ${FHS_IP}=   Get From Dictionary     ${FHS_INFO}    ipAddress
    Set Test Variable    ${OUT_FHS_IP}   ${FHS_IP}
    Create directory  ${cfg.test_logs_path}/backup/
    Manage host_keys
    Fetch tcs.json File On FHS
    Change Value Of Nrpm_fail and Tblock  ${cfg.test_logs_path}/backup/tcs.json  alias=${alias}
    Log To Console  Switch off the fun
    pdu.Setup Pdu
    ...  model=${FHS_FAN_DICT['fhsfan1933']['pdu']['type']}
    ...  host=${FHS_FAN_DICT['fhsfan1933']['pdu']['ip_addr']}
    ...  alias=pdu
    pdu.Power On
    ...  port=${FHS_FAN_DICT['fhsfan1933']['pdu']['port']}
    ...  pdu_device=pdu
    pdu.Teardown Pdu  pdu_device=pdu
#    PDU Turn On Unit     ${BTS_CONFIG['FHS_FAN']['fhsfan1933']['pdu']['type']}
#    ...                  ${BTS_CONFIG['FHS_FAN']['fhsfan1933']['pdu']['ip_addr']}
#    ...                  ${BTS_CONFIG['FHS_FAN']['fhsfan1933']['pdu']['port']}
    Log To Console  Wait for fault 1933 to be active
    Assert alarm active     faultId=1933, severity=Minor    timeout=210   alias=${alias}
    Log To Console  Fault 1933 is active
    Add Allowed Alarm       faultId=1933, severity=Minor    alias=${alias}

Cancel fault 1933 on FHS module by file modifications
    [Arguments]   ${alias}=${cfg.primary_node_bts_id}
    Log To Console  Switch on the fun
#    PDU Turn Off Unit    ${BTS_CONFIG['FHS_FAN']['fhsfan1933']['pdu']['type']}
#    ...                  ${BTS_CONFIG['FHS_FAN']['fhsfan1933']['pdu']['ip_addr']}
#    ...                  ${BTS_CONFIG['FHS_FAN']['fhsfan1933']['pdu']['port']}
    pdu.Setup Pdu
    ...  model=${FHS_FAN_DICT['fhsfan1933']['pdu']['type']}
    ...  host=${FHS_FAN_DICT['fhsfan1933']['pdu']['ip_addr']}
    ...  alias=pdu
    pdu.Power Off
    ...  port=${FHS_FAN_DICT['fhsfan1933']['pdu']['port']}
    ...  pdu_device=pdu
    pdu.Teardown Pdu  pdu_device=pdu
    Log To Console  Wait for fault 1933 to be inactive
    Assert alarm inactive   faultId=1933, severity=Minor    timeout=210   alias=${alias}
    Log To Console  Fault 1933 is cleared
    Change Value Of Nrpm_fail and Tblock
    ...  ${cfg.test_logs_path}/backup/ORIGINAL_tcs.json  Nrpm_value=30   Tblock_value=90  backup=False  alias=${alias}

Fetch tcs.json File On FHS
    Log to console  Fetch tcs.json file on FHS
    SSHLibrary.Open Connection    192.168.255.1    alias=FSM
    SSHLibrary.Login              toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Write              lxc-attach -n ${LXC}
    Sleep  6
    SSHLibrary.Write              ssh serviceuser@${OUT_FHS_IP}
    Sleep  6
    ${output}=      SSHLibrary.Read
    ${pass}=  Run keyword and return status  Should contain   ${output}    password:
    SSHLibrary.Write              Pl(FzaYj5~c5;q
    Sleep  6
    SSHLibrary.Write              su toor4nsn
    Sleep  6
    ${output}=      SSHLibrary.Read
    ${pass}=  Run keyword and return status  Should contain   ${output}    Password:
    ${output}=  Run keyword if  ${pass}  SSHLibrary.Write              oZPS0POrRieRtu
    Sleep  6
    SSHLibrary.Write    ServiceStarter libcoma-proxy.so.1.0 comaproxy::instance1 --addr=200 &
    Sleep  6
    SSHLibrary.Write  { echo "/ action create ConfigAccess /ca /module"; } | frmonShellClient 127.0.0.1 2000
    Sleep  6
    SSHLibrary.Write  { echo '/ca action fetch DECODED "tcs.bin" "/var/tmp/tcs.json"'; } | frmonShellClient 127.0.0.1 2000
    Sleep  6
    SSHLibrary.Write    chmod 777 /var/tmp/tcs.json
    Sleep  6
    SSHLibrary.Write    chown toor4nsn /var/tmp/tcs.json
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Close Connection
    Download file from FHS module  /var/tmp/tcs.json  ${cfg.test_logs_path}/backup/tcs.json

Change Value Of Nrpm_fail and Tblock
    [Arguments]  ${path_to_json_file}  ${Nrpm_value}=5   ${Tblock_value}=35  ${backup}=True  ${alias}=default
    Log to console  Change value of nrpm_fail and tblock
    Run keyword if  ${backup}  Copy File  ${cfg.test_logs_path}/backup/tcs.json  ${cfg.test_logs_path}/backup/ORIGINAL_tcs.json
    Change Value In Json File  ${path_to_json_file}  Nrpm_fail  ${Nrpm_value}
    Change Value In Json File  ${path_to_json_file}  Tblock  ${Tblock_value}
    Upload file to FHS module  ${path_to_json_file}  /var/tmp/tcs.json
    SSHLibrary.Open Connection    192.168.255.1    alias=FSM    prompt=:~
    SSHLibrary.Login              toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Write              lxc-attach -n ${LXC}
    Sleep  6
    SSHLibrary.Write              ssh serviceuser@${OUT_FHS_IP}
    Sleep  6
    ${output}=      SSHLibrary.Read
    ${pass}=  Run keyword and return status  Should contain   ${output}    password:
    SSHLibrary.Write              Pl(FzaYj5~c5;q
    Sleep  6

    SSHLibrary.Write              su toor4nsn
    Sleep  6
    ${output}=      SSHLibrary.Read
    ${pass}=  Run keyword and return status  Should contain   ${output}    Password:
    ${output}=  Run keyword if  ${pass}  SSHLibrary.Write              oZPS0POrRieRtu
    Sleep  6
    SSHLibrary.Write    chmod 777 /var/tmp/tcs.json
    Sleep  6
    SSHLibrary.Write    chown toor4nsn tcs.json
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Write    ServiceStarter libcoma-proxy.so.1.0 comaproxy::instance1 --addr=200 &
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Write  { echo "/ action create ConfigAccess /ca /module"; } | frmonShellClient 127.0.0.1 2000
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Write  { echo '/ca action store PERMANENT DECODED "type/tcs.bin" "/var/tmp/tcs.json"'; } | frmonShellClient 127.0.0.1 2000
    Sleep  6
    ${output}=      SSHLibrary.Read
    Should contain      ${output}  done ok
    SSHLibrary.Close Connection
    others.HW Unit Reset  ${FHS_SERIAL}  timeout=900  alias=${alias}
    Run keyword and continue on failure  Wait for infomodel event
	...  event=change /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/FHS_L-* [stateInfo.operationalState: Disabled -> Enabled]
    ...  timeout=210  alias=${alias}
    Log to console   Changed tcs.json successfully and uploaded on FHS

Generate fault 1932 on FHS module by file modifications
    [Arguments]   ${fhs_under_test_serial_number}  ${alias}=${cfg.primary_node_bts_id}
    Set test variable  ${FHS_SERIAL}  ${fhs_under_test_serial_number}
    ${FHS_INFO}=  Get Infomodel Object   //BTS_L-*/EQM_L-1/FHS_L-* is [serialNumber="${FHS_SERIAL}"]    alias=${alias}
    ${FHS_IP}=   Get From Dictionary     ${FHS_INFO}    ipAddress
    ${fhs_distName}=  Get From Dictionary     ${FHS_INFO}    dist_name
    Set Test Variable    ${OUT_FHS_IP}   ${FHS_IP}
    Set Test Variable    ${FHS_DISTNAME}   ${fhs_distName}
    Create directory  ${cfg.test_logs_path}/backup/
    Manage host_keys
    Fetch tcs.json File On FHS
    Change Value Of Nrpm_fail and Tblock  ${cfg.test_logs_path}/backup/tcs.json  alias=${alias}
    Log To Console  Switch off the fun
#    PDU Turn On Unit     ${BTS_CONFIG['FHS_FAN']['fhsfan1932']['pdu']['type']}
#    ...                  ${BTS_CONFIG['FHS_FAN']['fhsfan1932']['pdu']['ip_addr']}
#    ...                  ${BTS_CONFIG['FHS_FAN']['fhsfan1932']['pdu']['port']}
    pdu.Setup Pdu
    ...  model=${FHS_FAN_DICT['fhsfan1932']['pdu']['type']}
    ...  host=${FHS_FAN_DICT['fhsfan1932']['pdu']['ip_addr']}
    ...  alias=pdu
    pdu.Power On
    ...  port=${FHS_FAN_DICT['fhsfan1932']['pdu']['port']}
    ...  pdu_device=pdu
    pdu.Teardown Pdu  pdu_device=pdu
    Add Allowed Alarm       faultId=1933, severity=Minor    alias=${alias}
    Log To Console  Wait for fault 1932 to be active
    Assert alarm active     faultId=1932, severity=Minor    timeout=210   alias=${alias}
#    Wait Until Keyword Succeeds   300  30  Message should exist in syslog file     \\[Detector 1932 ${FHS_DISTNAME}.*\\] active.*  alias=${alias}
    Log To Console  Fault 1932 is active
    Add Allowed Alarm       faultId=1932, severity=Minor    alias=${alias}

Cancel fault 1932 on FHS module by file modifications
    [Arguments]   ${alias}=${cfg.primary_node_bts_id}
    Log To Console  Switch on the fun
#    PDU Turn Off Unit    ${BTS_CONFIG['FHS_FAN']['fhsfan1932']['pdu']['type']}
#    ...                  ${BTS_CONFIG['FHS_FAN']['fhsfan1932']['pdu']['ip_addr']}
#    ...                  ${BTS_CONFIG['FHS_FAN']['fhsfan1932']['pdu']['port']}
    pdu.Setup Pdu
    ...  model=${FHS_FAN_DICT['fhsfan1932']['pdu']['type']}
    ...  host=${FHS_FAN_DICT['fhsfan1932']['pdu']['ip_addr']}
    ...  alias=pdu
    pdu.Power Off
    ...  port=${FHS_FAN_DICT['fhsfan1932']['pdu']['port']}
    ...  pdu_device=pdu
    pdu.Teardown Pdu  pdu_device=pdu
    Log To Console  Wait for fault 1932 to be inactive
    Assert alarm inactive   faultId=1932, severity=Minor    timeout=210   alias=${alias}
#    Wait Until Keyword Succeeds   300  30  Message should exist in syslog file     \\[Detector 1932 ${FHS_DISTNAME}.*\\] inactive.*  alias=${alias}
    Log To Console  Fault 1932 is cleared
    Change Value Of Nrpm_fail and Tblock
    ...  ${cfg.test_logs_path}/backup/ORIGINAL_tcs.json  Nrpm_value=30   Tblock_value=90  backup=False  alias=${alias}

Generate fault 1936 on FHS module by file modifications
    [Arguments]   ${fhs_under_test_serial_number}  ${alias}=${cfg.primary_node_bts_id}
    Set Test variable    ${bts_id}    ${cfg.primary_node_bts_id}
    Preconditions For CNI-127210
    ${expected_alarmId}=  Prepare FHS Alarm Id  ${alias}
    Set test variable  ${FHS_SERIAL}  ${fhs_under_test_serial_number}
    ${FHS_INFO}=  Get Infomodel Object   //BTS_L-*/EQM_L-1/FHS_L-* is [serialNumber="${FHS_SERIAL}"]    alias=${alias}
    ${FHS_IP}=   Get From Dictionary     ${FHS_INFO}    ipAddress
    ${fhs_distName}=  Get From Dictionary     ${FHS_INFO}    dist_name
    Set Test Variable    ${OUT_FHS_IP}   ${FHS_IP}
    Set Test Variable    ${FHS_DISTNAME}   ${fhs_distName}
    Set Start Timestamp In IMS For CNI-127210
    Manage host_keys
    Create Temperature Sensor Object on FHS
    Upload file to FHS module
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/FHS_ALARMS/FHS_tempest_files/tempest_inst.fbs
    ...  /var/tmp/tempest_inst.fbs
    Copy file on FHS module  /var/tmp/tempest_inst.fbs  /etc/rfsw/configs/schemas/internal/tempest/tempest_inst.fbs
    Upload file to FHS module
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/FHS_ALARMS/FHS_tempest_files/tempest_modified.json
    ...  /var/tmp/tempest_modified.json
    Copy file on FHS module  /var/tmp/tempest_modified.json  /mnt/runtime/tempest_modified.json
    Write temperature  fpga_temp=92  board_temp=84  core_temp=84
#    Log To Console  Wait for fault 1936 to be active in syslog
    Log To Console  Wait for fault 1936 to be active
    ${alarmlist}  Run Keyword If  not ${PRECOND_FOR_CNI}  Assert alarm active  faultId=1936, severity=Minor   timeout=960   alias=${alias}
    ${current_alarmid}  Run Keyword If  not ${PRECOND_FOR_CNI}  Get Current AlarmId For FHS  ${alarmlist}
    ${current_alarmid}  Run Keyword If  not ${PRECOND_FOR_CNI}  Convert To String  ${current_alarmid}
    Run Keyword If  not ${PRECOND_FOR_CNI}  List Should Contain Value  ${expected_alarmId}  ${current_alarmid}
    ...  Wrong alarmId ! Please check NIDD for fault 1936
    Run Keyword If  ${PRECOND_FOR_CNI}  Run Keywords  Sleep  900s
    ...  AND  Check Active Fault In IMS For CNI-127210  fault_id=1936  severity=Minor
    Log To Console  Fault 1936 is active
    Add Allowed Alarm    faultId=1936, severity=Minor    alias=${alias}
#    Wait Until Keyword Succeeds   960  30  Message should exist in syslog file     \\[Detector 1936 ${FHS_DISTNAME}.*\\] active.*  alias=${alias}
#    Log To Console  Fault 1936 is active

Cancel fault 1936 on FHS module by file modifications
    [Arguments]   ${alias}=${cfg.primary_node_bts_id}
    Set Start Timestamp In IMS For CNI-127210
    Write temperature  fpga_temp=50  board_temp=50  core_temp=50
    Log To Console  Wait for fault 1936 to be inactive
#    Wait Until Keyword Succeeds   960  30  Message should exist in syslog file     \\[Detector 1936 ${FHS_DISTNAME}.*\\] inactive.*  alias=${alias}
    Run Keyword If  ${PRECOND_FOR_CNI}  Run Keywords  Sleep  900s
    ...  AND  Check Removed Active Fault In IMS For CNI-127210
    ...  ELSE  Assert alarm inactive   faultId=1936, severity=Minor    timeout=960   alias=${alias}
    Log To Console  Fault 1936 is cleared

Download file from FHS module
    [Arguments]  ${remote_file}  ${local_file}
    Log To Console  Download ${remote_file} file from FHS and save it as ${local_file}
    ${remote_path}  ${remote_filename}=  Split path  ${remote_file}
    ${connection}    ${session_type}    ${bts_ip}=    SSH Create Session    ${TC_ALIAS}
#    SSHLibrary.Open Connection    192.168.255.1    alias=FSM    prompt=:~
#    SSHLibrary.Login              toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Write              lxc-attach -n ${LXC}
    Sleep  6

    SSHLibrary.Write            scp -P 22 -o strictHostKeyChecking=no serviceuser@${OUT_FHS_IP}:${remote_file} /tmp/${remote_filename}_${OUT_FHS_IP}
    Sleep  6
    ${output}=  SSHLibrary.Read
    Should contain                ${output}    password:
    SSHLibrary.Write              Pl(FzaYj5~c5;q
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Close Connection
    ${command_status}  ${msg}  Run Keyword And Ignore Error  Run Keyword If    '${session_type}'=='localhost'
    ...    OperatingSystem.Run And Return Rc And Output
    ...  sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/node_${LXC}/tmp/${remote_filename}_${OUT_FHS_IP} "${local_file}"
    ...    ELSE   Run Keywords
    ...    SSHLibrary.Open Connection      host=${BTS_IP}   prompt=REGEXP:[$#>]$
    ...    AND    SSHLibrary.Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ...    AND    SSHLibrary.Set Client Configuration  timeout=20s
    ...    AND    SSHLibrary.Read Until    :~
    ...    AND    SSHLibrary.Write
    ...  sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/node_${LXC}/tmp/${remote_filename}_${OUT_FHS_IP} "${local_file}"
    ...    AND    Sleep    6
    ...    AND    SSHLibrary.Read
    ...    AND    SSHLibrary.Close Connection
    Run Keyword If  '${msg[0]}'!='0'  FAIL   Executed command failed with message: ${msg}
    ...  ELSE  Log To Console  File was downloaded successfully

Upload file to FHS module
    [Arguments]  ${local_file}  ${remote_file}
    Log To Console  Upload ${local_file} file to ${remote_file} on FHS
    ${local_path}  ${local_filename}=  Split path  ${local_file}

    ${command_status}  ${msg}=     Run Keyword If    '${session_type}'=='localhost'
    ...    OperatingSystem.Run And Return Rc And Output
    ...  sshpass -p oZPS0POrRieRtu scp "${local_file}" toor4nsn@192.168.255.1:/tmp/node_${LXC}/tmp/${local_filename}_${OUT_FHS_IP}
    ...    ELSE   Run Keywords
    ...    SSHLibrary.Open Connection      host=${BTS_IP}   prompt=REGEXP:[$#>]$
    ...    AND    SSHLibrary.Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ...    AND    SSHLibrary.Set Client Configuration  timeout=20s
    ...    AND    SSHLibrary.Read Until    :~
    ...    AND    SSHLibrary.Write
    ...  sshpass -p oZPS0POrRieRtu scp "${local_file}" toor4nsn@192.168.255.1:/tmp/node_${LXC}/tmp/${local_filename}_${OUT_FHS_IP}
#    ...    AND    SSHLibrary.put_file   ${local_file}    /tmp/node_${LXC}/tmp/${local_filename}_${OUT_FHS_IP}
    ...    AND    Sleep    6
    ...    AND    SSHLibrary.Read
    ...    AND    SSHLibrary.Close Connection
#    Run Keyword If  '${command_status}'!='PASS'  FAIL   Executed command failed with message: ${msg}
    ${connection}    ${session_type}    ${bts_ip}=    SSH Create Session    ${TC_ALIAS}
    Run Keyword If    '${session_type}'=='localhost'    SSHLibrary.Read
    ...    ELSE    SSHLibrary.Read Until    :~
    SSHLibrary.Write              lxc-attach -n ${LXC}
    SSHLibrary.Read Until    :~
    Sleep  6
    SSHLibrary.Write              cat ~/.ssh/known_hosts | grep ${OUT_FHS_IP}
    Sleep  6
    ${output}=  SSHLibrary.Read Until    :~
    ${is_key}=  Run keyword and return status  Should contain  ${output}  ${OUT_FHS_IP}
    Run keyword if  ${is_key}  Remove SSH key  host_ip=${OUT_FHS_IP}
    SSHLibrary.Write              scp -P 22 -o strictHostKeyChecking=no /tmp/${local_filename}_${OUT_FHS_IP} serviceuser@${OUT_FHS_IP}:${remote_file}
    Sleep  6
    ${output}=  SSHLibrary.Read
    Should contain                ${output}    password:
    SSHLibrary.Write              Pl(FzaYj5~c5;q
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Close Connection

Copy file on FHS module
    [Arguments]  ${source_file}  ${target_file}
    Log To Console  Copy ${source_file} file to ${target_file} on FHS
    ${connection}    ${session_type}    ${bts_ip}=    SSH Create Session    ${TC_ALIAS}
    ${target_path}  ${target_filename}  Split path  ${target_file}
#    SSHLibrary.Open Connection    192.168.255.1    alias=FSM
#    SSHLibrary.Login              toor4nsn    oZPS0POrRieRtu
    ${output}=      Run Keyword If    '${session_type}'=='localhost'    SSHLibrary.Read
    ...    ELSE    SSHLibrary.Read Until    :~
    SSHLibrary.Write              lxc-attach -n ${LXC}
    Sleep  6
    ${output}=  SSHLibrary.Read Until    :~
    SSHLibrary.Write              ssh serviceuser@${OUT_FHS_IP}
    Sleep  6
    ${output}=      SSHLibrary.Read
    ${pass}=  Run keyword and return status  Should contain   ${output}    password:
    SSHLibrary.Write              Pl(FzaYj5~c5;q
    Sleep  6

    SSHLibrary.Write              su toor4nsn
    Sleep  6
    ${output}=      SSHLibrary.Read
    ${pass}=  Run keyword and return status  Should contain   ${output}    Password:
    ${output}=  Run keyword if  ${pass}  SSHLibrary.Write              oZPS0POrRieRtu
    Sleep  6
    SSHLibrary.Write              mkdir -p ${target_path}
    Sleep  6
    SSHLibrary.Write              chmod 777 ${target_path}
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Write              cp ${source_file} ${target_file}
    Sleep  6
    SSHLibrary.Close Connection

Create Temperature Sensor Object on FHS
    Log To Console  Create temperature sensor object on FHS
    ${connection}    ${session_type}    ${bts_ip}=    SSH Create Session    ${TC_ALIAS}
#    SSHLibrary.Open Connection    192.168.255.1    alias=FSM
#    SSHLibrary.Login              toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Write              lxc-attach -n ${LXC}
    Sleep  6
    SSHLibrary.Write              ssh serviceuser@${OUT_FHS_IP}
    Sleep  6
    ${output}=      SSHLibrary.Read
    ${pass}=  Run keyword and return status  Should contain   ${output}    password:
    SSHLibrary.Write              Pl(FzaYj5~c5;q
    Sleep  6

    SSHLibrary.Write              su toor4nsn
    Sleep  6
    ${output}=      SSHLibrary.Read
    ${pass}=  Run keyword and return status  Should contain   ${output}    Password:
    ${output}=  Run keyword if  ${pass}  SSHLibrary.Write              oZPS0POrRieRtu
    Sleep  6
    SSHLibrary.Write    ServiceStarter libcoma-proxy.so.1.0 comaproxy::instance1 --addr=200 &
    Sleep  6
    SSHLibrary.Write  { echo "/ action create ThermometerDevice /board /fhs/board"; } | frmonShellClient 127.0.0.1 2000
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Write  { echo "/ action create ThermometerDevice /fpga /fhs/fpga"; } | frmonShellClient 127.0.0.1 2000
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Write  { echo "/ action create ThermometerDevice /core /fhs/core"; } | frmonShellClient 127.0.0.1 2000
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Close Connection

Write temperature
    [Arguments]  ${fpga_temp}  ${board_temp}  ${core_temp}
    Log To Console  Write temperature to temperature objects
    ${connection}    ${session_type}    ${bts_ip}=    SSH Create Session    ${TC_ALIAS}
#    SSHLibrary.Open Connection    192.168.255.1    alias=FSM
#    SSHLibrary.Login              toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Write              lxc-attach -n ${LXC}
    Sleep  6
    SSHLibrary.Write              ssh serviceuser@${OUT_FHS_IP}
    Sleep  6
    ${output}=      SSHLibrary.Read
    ${pass}=  Run keyword and return status  Should contain   ${output}    password:
    SSHLibrary.Write              Pl(FzaYj5~c5;q
    Sleep  6

    SSHLibrary.Write              su toor4nsn
    Sleep  6
    ${output}=      SSHLibrary.Read
    ${pass}=  Run keyword and return status  Should contain   ${output}    Password:
    ${output}=  Run keyword if  ${pass}  SSHLibrary.Write              oZPS0POrRieRtu
    Sleep  6
    SSHLibrary.Write    chmod 777 /etc/rfsw/configs/schemas/internal/tempest/tempest_inst.fbs
    Sleep  6
    SSHLibrary.Write    chmod 777 /mnt/runtime/tempest_modified.json
    Sleep  6
    SSHLibrary.Write    ServiceStarter libcoma-proxy.so.1.0 comaproxy::instance1 --addr=200 &
    Sleep  6
    SSHLibrary.Write  { echo "/fpga action override TEMPERATURE ${fpga_temp}"; } | frmonShellClient 127.0.0.1 2000
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Write  { echo "/board action override TEMPERATURE ${board_temp}"; } | frmonShellClient 127.0.0.1 2000
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Write  { echo "/core action override TEMPERATURE ${core_temp}"; } | frmonShellClient 127.0.0.1 2000
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Close Connection

Generate fault 1937 on FHS module by file modifications
    [Arguments]   ${fhs_under_test_serial_number}  ${severity}=Minor  ${alias}=${cfg.primary_node_bts_id}
    Set Test variable    ${bts_id}    ${cfg.primary_node_bts_id}
    Preconditions For CNI-127210
    Set test variable  ${FHS_SERIAL}  ${fhs_under_test_serial_number}
    ${FHS_INFO}=  Get Infomodel Object   //BTS_L-*/EQM_L-1/FHS_L-* is [serialNumber="${FHS_SERIAL}"]    alias=${alias}
    ${FHS_IP}=   Get From Dictionary     ${FHS_INFO}    ipAddress
    Set Test Variable    ${OUT_FHS_IP}   ${FHS_IP}
    Set Start Timestamp In IMS For CNI-127210
    Manage host_keys    ${alias}
    Create Temperature Sensor Object on FHS
    Upload file to FHS module
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/FHS_ALARMS/FHS_tempest_files/tempest_inst.fbs
    ...  /var/tmp/tempest_inst.fbs
    Copy file on FHS module  /var/tmp/tempest_inst.fbs  /etc/rfsw/configs/schemas/internal/tempest/tempest_inst.fbs
    Upload file to FHS module
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/Test_Cases/FHS_ALARMS/FHS_tempest_files/tempest_modified.json
    ...  /var/tmp/tempest_modified.json
    Copy file on FHS module  /var/tmp/tempest_modified.json  /mnt/runtime/tempest_modified.json
    Write temperature  fpga_temp=110  board_temp=110  core_temp=110
    Log To Console  Wait for fault 1937 with severity ${severity} to be active
    Run Keyword If  ${PRECOND_FOR_CNI} and "${severity}"=="Minor"  Run Keywords  Sleep  900s
    ...  AND  Check Active Fault In IMS For CNI-127210  fault_id=1937  severity=${severity}
    ...  ELSE  Assert alarm active     faultId=1937, severity=${severity}    timeout=960   alias=${alias}
    Log To Console  Fault 1937 is active
    Add Allowed Alarm       faultId=1937, severity=${severity}    alias=${alias}

Cancel fault 1937 on FHS module by file modifications
    [Arguments]   ${severity}=Minor  ${alias}=${cfg.primary_node_bts_id}
    Set Start Timestamp In IMS For CNI-127210
    Write temperature  fpga_temp=50  board_temp=50  core_temp=50
    Log To Console  Wait for fault 1937 with severity ${severity} to be inactive
    Run Keyword If  ${PRECOND_FOR_CNI} and "${severity}"=="Minor"  Run Keywords  Sleep  900s
    ...  AND  Check Removed Active Fault In IMS For CNI-127210
    ...  ELSE  Assert alarm inactive   faultId=1937, severity=${severity}    timeout=960   alias=${alias}
    Log To Console  Fault 1937 is cleared

Get active lxc
    Log To Console  Get active lxc
    Sleep  6
    ${lxc_list}=  Run Keyword If    '${session_type}'=='localhost'    SSHLibrary.Read
    ...    ELSE    SSHLibrary.Read Until    :~
    SSHLibrary.Write              lxc-ls --active
    Sleep  6
    ${lxc_list}=  SSHLibrary.Read Until    :~
    ${lxc_list}=  Split String  ${lxc_list}
    FOR  ${lxc}  IN  @{lxc_list}
#          SSHLibrary.Write
           SSHLibrary.Write        lxc-attach -n ${lxc}
           Sleep  6
           SSHLibrary.Write        arp -an ${OUT_FHS_IP} | grep -v incomplete
           Sleep  6
           ${output}=  SSHLibrary.Read
           ${lxc_active}=  Run keyword and return status  Should contain  ${output}  ${OUT_FHS_IP}
           SSHLibrary.Write        exit
           Sleep  6
           ${output}=  SSHLibrary.Read
           Run keyword if  ${lxc_active}  Run keywords  Set test variable  ${LXC}  ${lxc}
        ...  AND
        ...  Exit for loop
    END

Remove SSH key
    [Arguments]  ${host_ip}  ${known_hosts_directory}=/user/toor4nsn
    SSHLibrary.Write  ssh-keygen -f "${known_hosts_directory}/.ssh/known_hosts" -R "${host_ip}"
    Sleep  6
    ${output}=  SSHLibrary.Read
    Should contain  ${output}  .ssh/known_hosts updated

Manage host_keys
    [Arguments]    ${alias}=None
    Log To Console  Manage host_keys
    Log  Remove SSH key  console=${TRUE}

    ${status}  ${msg}  Run Keyword And Ignore Error  Run Keyword If   '${SESSION_TYPE}' != 'localhost'    Run Keywords
    ...    SSHLibrary.Open Connection      ${BTS_IP}   prompt=REGEXP:[$#>]$
    ...    AND    SSHLibrary.Login With Public Key    ute    /home/ute/.ssh/id_rsa
    ...    AND    SSHLibrary.Set Client Configuration  timeout=20s
    ...    AND    SSHLibrary.Read Until    :~
    ...    AND    SSHLibrary.Write    ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "192.168.255.1"
    ...    ELSE   Run  ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "192.168.255.1"
    Log  Send new SSH key  console=${TRUE}
    ${status}  ${msg}  Run Keyword And Ignore Error  Run Keyword If   '${SESSION_TYPE}' != 'localhost'    Run Keywords
    ...    SSHLibrary.Read Until    :~
    ...    AND    SSHLibrary.Write    sshpass -p oZPS0POrRieRtu ssh-copy-id -i ~/.ssh/toor4nsn/id_rsa.pub toor4nsn@192.168.255.1
    ...    AND    SSHLibrary.Read Until    :~
    ...    AND    SSHLibrary.Close Connection
    ...    ELSE    Run  sshpass -p oZPS0POrRieRtu ssh-copy-id -i ~/.ssh/toor4nsn/id_rsa.pub toor4nsn@192.168.255.1
#    SSHLibrary.Open Connection    192.168.255.1    alias=FSM
#    SSHLibrary.Login              toor4nsn    oZPS0POrRieRtu
    ${connection}    ${session_type}    ${bts_ip}=    SSH Create Session    ${TC_ALIAS}
    ${lxc_not_defined}=  Run keyword and return status  Variable Should Not Exist  ${LXC}
    Run keyword if  ${lxc_not_defined}  Get active lxc
    SSHLibrary.Write              lxc-attach -n ${LXC}
    Sleep  6
    SSHLibrary.Write              cat ~/.ssh/known_hosts | grep ${OUT_FHS_IP}
    Sleep  6
    ${output}=  SSHLibrary.Read
    ${is_key}=  Run keyword and return status  Should contain  ${output}  ${OUT_FHS_IP}
    Run keyword if  ${is_key}  Remove SSH key  host_ip=${OUT_FHS_IP}
    SSHLibrary.Write              ssh serviceuser@${OUT_FHS_IP}
    Sleep  6
    ${output}=  SSHLibrary.Read
    ${action}=     Run keyword and return status  Should contain  ${output}  Are you sure you want to continue connecting (yes/no/[fingerprint])?
    Run keyword if  ${action}  Run keywords
    ...  SSHLibrary.Write  yes
    ...  AND
    ...  Sleep  6
    ${output}=  Run keyword if  ${action}  SSHLibrary.Read
    ${pass}=  Run keyword if  ${action}  Run keyword and return status  Should contain   ${output}    password:
    Run keyword if  ${pass}  Run keywords
    ...  SSHLibrary.Write  Pl(FzaYj5~c5;q
    ...  AND
    ...  Sleep  6
    ...  AND
    ...  SSHLibrary.Write  exit
    SSHLibrary.Close connection

Check EAC alarms on FHS
    [Arguments]   ${fhs_under_test_serial_number}  ${alias}=${cfg.primary_node_bts_id}
    Set test variable  ${FHS_SERIAL}  ${fhs_under_test_serial_number}
    ${eac_alarm_list}=  Create EAC alarm list for tested FHS         ${FHS_SERIAL}       ${cfg.NODES['${alias}']['scf_file_path']}
    ${eac_alarms_commissionig_check}=  Get Length  ${eac_alarm_list}
    Run Keyword If  ${eac_alarms_commissionig_check} == 0
    ...  Fail  !!! There are no EAC alarms commissioned. Please set up test environment propertlly. !!!
    ${eac_ip_addr}=     Set variable  ${FHS_DICT['${FHS_SERIAL}']['eac']['ip_addr']}
    ${eac_port}=        Set variable  ${FHS_DICT['${FHS_SERIAL}']['eac']['port']}
    keywords.Info Model Check EAC Alarms Commissioning   ${FHS_SERIAL}     ${cfg.NODES['${alias}']['scf_file_path']}         alias=${alias}
    FOR    ${alarm}   IN     @{eac_alarm_list}
        keywords.Info Model Check EAC Line State Without Active Alarm
      ...                                      ${FHS_SERIAL}
      ...                                      ${alarm}
      ...                                      ${cfg.NODES['${alias}']['scf_file_path']}
      ...                                      alias=${alias}
        ${fault_id}    ${eac_alarm_startDelay}   ${eac_alarm_cancelDelay}=
      ...  keywords.Generate EAC Alarm         ${alarm}
      ...                                      ${eac_ip_addr}
      ...                                      ${eac_port}
      ...                                      ${cfg.NODES['${alias}']['scf_file_path']}
      ...                                      alias=${alias}
        keywords.EAC Alarm Should Be Generated   ${alarm}
      ...                                      ${fault_id}
      ...                                      ${eac_alarm_startDelay}
      ...                                      ${cfg.NODES['${alias}']['scf_file_path']}
      ...                                      ${FHS_SERIAL}
      ...                                      alias=${alias}
        keywords.Clear EAC alarm                 ${alarm}
      ...                                      ${eac_ip_addr}
      ...                                      ${eac_port}
      ...                                      ${cfg.NODES['${alias}']['scf_file_path']}
        keywords.EAC Alarm Should Be Cleared     ${eac_alarm_cancelDelay}
      ...                                      ${fault_id}
      ...                                      alias=${alias}
    END

Create EAC alarm list for tested FHS
  [Arguments]  ${fhs_serial_number}    ${scfc_with_eac_alarms}
  ${configdn_fhs_tested}=  Get Element Text   ${scfc_with_eac_alarms}
  ...  xpath=//managedObject[@class='com.nokia.srbts.eqmr:FHS_R'][p[@name='serialNumber']='${fhs_serial_number}']/p[@name="configDN"]
  ${object_1}=  Set Variable  xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'
  ${object_2}=  Set Variable  contains (@distName, '${configdn_fhs_tested}/EAC_IN-')][p[@name='inUse']='true']/@distName
  ${sum_object}=  Set Variable  ${object_1} and ${object_2}
  ${eac_alarm_list}=    Get Elements  ${scfc_with_eac_alarms}  ${sum_object}
  [Return]    ${eac_alarm_list}

#Info Model check EAC alarms commissioning
#    [Arguments]   ${fhs_serial_number}   ${scfc_with_eac_alarms}   ${timeout}=10     ${alias}=default
#    ${eac_alarm_list}=  Create EAC alarm list for tested FHS     ${fhs_serial_number}     ${scfc_with_eac_alarms}
#    ${fhs_dist_name}=    Info Model Get Fhs Attribute Value For FHS Serial Number   ${fhs_serial_number}    dist_name  alias=${alias}
#  FOR  ${eac_alarm}  IN    @{eac_alarm_list}
#    ${port_id}    Get Element Text  ${scfc_with_eac_alarms}
#      ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
#    ${eac_alarm_detail}=    Get Element Text  ${scfc_with_eac_alarms}
#      ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="descr"]
#    ${eac_alarm_severity}=    Get Element Text  ${scfc_with_eac_alarms}
#      ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="severity"]
#    ${eac_alarm_startDelay}=    Get Element Text  ${scfc_with_eac_alarms}
#      ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="startDelay"]
#    ${eac_alarm_cancelDelay}=    Get Element Text  ${scfc_with_eac_alarms}
#      ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="cancelDelay"]
#    ${alarm_polarity}    Get Element Text  ${scfc_with_eac_alarms}
#      ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="polarity"]
#    ${check_polarity}=    Set Variable If    '${alarm_polarity}'=='Normally_closed'  ONE_IS_HIGH    BUG
#    ${check_polarity}=    Set Variable If    '${alarm_polarity}'=='Normally_open'  ONE_IS_LOW    ${check_polarity}
#    ${object_1}=  Set Variable  query=${fhs_dist_name}/EAC_L-* is [logicalMapping=${check_polarity}, severity=${eac_alarm_severity}
#    ${object_2}=  Set Variable
#    ...  , description=${eac_alarm_detail}, startDelay=${eac_alarm_startDelay}, cancelDelay=${eac_alarm_cancelDelay}, physicalNodeId=${port_id}]
#    ${sum_object}=  Set Variable  ${object_1}${object_2}
#    Query Infomodel  ${sum_object}
#    ...  timeout=${timeout}
#    ...  alias=${alias}
#  END

Info Model Get Fhs Attribute Value For FHS Serial Number
    [Arguments]    ${fhs_serial_number}    ${attribute_name}    ${timeout}=20    ${alias}=default
    [Documentation]    Returns value of given attribute name for given FR serial number e.g. l3Protocol or stateInfo.usageState
    ...     Author:         artur.dobosz@nokia.com
    ...     Maintainer:     Author
    ${out_matched_fhs}=    Query InfoModel      query=get object //EQM_L-1/FHS_L-* is [serialNumber=${fhs_serial_number}]
    ...                                          timeout=${timeout}
    ...                                          alias=${alias}
    [Return]    ${out_matched_fhs.${attribute_name}}

#Info Model check EAC line state without active alarm
#    [Arguments]  ${fhs_serial_number}   ${eac_alarm}   ${scfc_with_eac_alarms}   ${timeout}=10     ${alias}=default
#    ${fhs_dist_name}=    Info Model Get Fhs Attribute Value For FHS Serial Number   ${fhs_serial_number}  dist_name  alias=${alias}
#    ${port_id}    Get Element Text  ${scfc_with_eac_alarms}
#    ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
#    ${matched_eac_line}=    Query infomodel      query=get object ${fhs_dist_name}/EAC_L-* is [physicalNodeId=${port_id}, direction=INPUT]
#    ...  alias=${alias}
#    ${checked_eac_line}=    Set Variable    ${matched_eac_line.dist_name}
#    ${checked_eac_line_values}=    Get Infomodel Object     ${checked_eac_line}  alias=${alias}
#    ${eac_line_logicalMapping}=    Set Variable    ${checked_eac_line_values.logicalMapping}
#    ${eac_line_expexted_state}=    Set Variable If    '${eac_line_logicalMapping}'=='ONE_IS_LOW'  HIGH    BUG
#    ${eac_line_expexted_state}=    Set Variable If    '${eac_line_logicalMapping}'=='ONE_IS_HIGH'  LOW    ${eac_line_expexted_state}
#    Query Infomodel    query=${checked_eac_line} is [lineState=${eac_line_expexted_state}]  timeout=${timeout}  alias=${alias}

#Info Model check EAC line state with active alarm
#    [Arguments]  ${fhs_serial_number}   ${eac_alarm}   ${scfc_with_eac_alarms}   ${timeout}=10     ${alias}=default
#    ${fhs_dist_name}=    Info Model Get Fhs Attribute Value For FHS Serial Number   ${fhs_serial_number}  dist_name  alias=${alias}
#    ${port_id}    Get Element Text  ${scfc_with_eac_alarms}
#    ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
#    ${matched_eac_line}=    Query infomodel      query=get object ${fhs_dist_name}/EAC_L-* is [physicalNodeId=${port_id}, direction=INPUT]
#    ...  alias=${alias}
#    ${checked_eac_line}=    Set Variable    ${matched_eac_line.dist_name}
#    ${checked_eac_line_values}=    Get Infomodel Object     ${checked_eac_line}  alias=${alias}
#    ${eac_line_logicalMapping}=    Set Variable    ${checked_eac_line_values.logicalMapping}
#    ${eac_line_expexted_state}=    Set Variable If    '${eac_line_logicalMapping}'=='ONE_IS_LOW'  LOW    BUG
#    ${eac_line_expexted_state}=    Set Variable If    '${eac_line_logicalMapping}'=='ONE_IS_HIGH'  HIGH    ${eac_line_expexted_state}
#    Query Infomodel    query=${checked_eac_line} is [lineState=${eac_line_expexted_state}]  timeout=${timeout}  alias=${alias}

#Generate EAC alarm
#    [Arguments]  ${eac_alarm}   ${eac_ip_addr_for_tested_alarm}    ${eac_port_for_tested_alarm}   ${scfc_with_eac_alarms}  ${alias}=default
#    keywords.Setup EAC Tester  ${eac_ip_addr_for_tested_alarm}
#    ${port_id}    Get Element Text  ${scfc_with_eac_alarms}
#    ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
#    ${alarm_polarity}    Get Element Text  ${scfc_with_eac_alarms}
#    ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="polarity"]
#    ${port_state}=    Set Variable If    '${alarm_polarity}'=='Normally_closed'    O   C
#    keywords.EAC change port state   ${eac_port_for_tested_alarm}${port_id}      ${port_state}
#    keywords.Teardown EAC Tester
#    ${eac_faultid}=        Evaluate    1399+${port_id}
#    ${eac_alarm_startDelay}=    Get Element Text  ${scfc_with_eac_alarms}
#    ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="startDelay"]
#    ${eac_alarm_cancelDelay}=    Get Element Text  ${scfc_with_eac_alarms}
#    ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="cancelDelay"]
#    [Return]    ${eac_faultid}    ${eac_alarm_startDelay}    ${eac_alarm_cancelDelay}

#Setup EAC Tester
#    [Arguments]  ${eac_tester_ip}
#    SSHLibrary.Open Connection  ${eac_tester_ip}
#    SSHLibrary.Login  pi  pi
#
#Teardown EAC Tester
#    SSHLibrary.Close Connection

#EAC change port state
#    [Arguments]    ${eac_port_number}  ${eac_port_state}
#    SSHLibrary.Start Command   eac ${eac_port_number} ${eac_port_state}

#EAC open port
#    [Arguments]  ${eac_tester_ip}   ${eac_port_number}
#    keywords.Setup EAC Tester  ${eac_tester_ip}
#    SSHLibrary.Start Command   eac ${eac_port_number} O
#    keywords.Teardown EAC Tester
#
#EAC close port
#    [Arguments]  ${eac_tester_ip}  ${eac_port_number}
#    keywords.Setup EAC Tester  ${eac_tester_ip}
#    SSHLibrary.Start Command   eac ${eac_port_number} C
#    keywords.Teardown EAC Tester

#EAC Alarm Should Be Generated
#    [Arguments]  ${alarm}  ${fault_id}    ${eac_alarm_startDelay}    ${scfc_eac}  ${fhs_under_test_serial_number}  ${alias}=default
#    ${show_timeout}=     Evaluate          ${eac_alarm_startDelay}+10
#    Run Keyword And Continue On Failure     keywords.Info Model check EAC line state with active alarm
#    ...  ${fhs_under_test_serial_number}   ${alarm}   ${scfc_eac}  alias=${alias}
#    Run Keyword And Continue On Failure     Info Model Wait For Alarm
#    ...    fault_id=${fault_id}    fault_count=1    timeout=${show_timeout}
#    ...  act_category_alarms=${cfg.NODES['${cfg.primary_node_bts_id}']['scf_alarms_category']}  alias=${alias}
#    ${infomodel_mandatory_alarm}    ${btssm_mandatory_alarm}=   keywords.Create Mandatory EAC Alarm   ${alarm}
#    ...  ${scfc_eac}   ${FAULT_EAC_SCHEME}  alias=${alias}
#    Run Keyword And Continue On Failure     Mandatory And Allowed Alarms Should Be As Expected
#    ...  mandatory=${infomodel_mandatory_alarm}
#    ...  alias=${alias}
#    Add Allowed Alarm   faultId=${infomodel_mandatory_alarm[0]['faultId']}, severity=${infomodel_mandatory_alarm[0]['alarmSeverity']}  alias=${alias}

#Create Mandatory EAC Alarm
#    [Arguments]    ${eac_alarm}   ${scfc_with_eac_alarms}   ${fault_scheme}  ${alias}=default
#    ${eac_alarm_distname}=    keywords.Info Model check EAC alarm parameters   ${eac_alarm}    ${scfc_with_eac_alarms}  alias=${alias}
#    ${port_id}    Get Element Text  ${scfc_with_eac_alarms}
#    ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
#    ${eac_faultid}=     Evaluate    1399+${port_id}
#    ${eac_faultid}=     Convert to String   ${eac_faultid}
#    ${eac_alarm_detail}=    Get Element Text  ${scfc_with_eac_alarms}
#    ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="descr"]
#    ${eac_alarm_severity}=    Get Element Text  ${scfc_with_eac_alarms}
#    ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="severity"]
#    @{infomodel_mandatory_alarm}=    Create list
#    ${infomodel_fault_scheme}=       Evaluate    ${fault_scheme}
#    Set to dictionary    ${infomodel_fault_scheme}    alarmDetail  ${eac_alarm_detail}    faultId  ${eac_faultid}
#    ...  alarmSeverity  ${eac_alarm_severity}   # distName  ${eac_alarm_distname}
#    Append to list       ${infomodel_mandatory_alarm}    ${infomodel_fault_scheme}
#    #sm section
#    ${eac_sm_alarm_severity}=    Set Variable If    '${eac_alarm_severity}'=='Minor'  a1  BUG
#    ${eac_sm_alarm_severity}=    Set Variable If    '${eac_alarm_severity}'=='Major'  a2  ${eac_sm_alarm_severity}
#    ${eac_sm_alarm_severity}=    Set Variable If    '${eac_alarm_severity}'=='Critical'  a3  ${eac_sm_alarm_severity}
#    @{sm_mandatory_alarm}=       Create list
#    ${sm_fault_scheme}=          Evaluate    ${fault_scheme}
#    Set to dictionary    ${sm_fault_scheme}    alarmDetail  ${eac_alarm_detail}    faultId  ${eac_faultid}\\D*
#    ...  alarmSeverity  ${eac_sm_alarm_severity}    distName  ${eac_alarm_distname}
#    Append to list       ${sm_mandatory_alarm}    ${sm_fault_scheme}
#    [Return]    ${infomodel_mandatory_alarm}   ${sm_mandatory_alarm}

#Info Model check EAC alarm parameters
#  [Arguments]  ${eac_alarm}   ${scfc_with_eac_alarms}   ${timeout}=10     ${alias}=default
#  ${port_id}    Get Element Text  ${scfc_with_eac_alarms}
#  ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
#  ${eac_faultid}=        Evaluate    1399+${port_id}
#  ${eac_alarm_number_btssm}=  Evaluate  7400+${port_id}
#  ${eac_alarm_number}=  Set Variable If  ${cfg.NODES['${cfg.primary_node_bts_id}']['scf_alarms_category']}  7103  ${eac_alarm_number_btssm}
#  ${eac_alarm_detail}=    Get Element Text  ${scfc_with_eac_alarms}
#  ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="descr"]
#  ${eac_alarm_severity}=    Get Element Text  ${scfc_with_eac_alarms}
#  ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="severity"]
#  ${eac_alarm_startDelay}=    Get Element Text  ${scfc_with_eac_alarms}
#  ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="startDelay"]
#  ${eac_alarm_cancelDelay}=    Get Element Text  ${scfc_with_eac_alarms}
#  ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="cancelDelay"]
#
#  ${object_1}=  Set Variable  alarmActivity=Set, faultId=${eac_faultid}, alarmNumber=${eac_alarm_number}
#  ${object_2}=  Set Variable  , alarmSeverity=${eac_alarm_severity}, alarmText.alarmDetail=${eac_alarm_detail}
#  ${sum_object}=  Set Variable  ${object_1}${object_2}
#
#  ${object_3}=  Set Variable
#  ...  alarmInformation.alarmActivity=Set, alarmInformation.faultId=${eac_faultid}, alarmInformation.alarmNumber=${eac_alarm_number}
#  ${object_4}=  Set Variable  , alarmInformation.alarmSeverity=${eac_alarm_severity}, alarmInformation.alarmText.alarmDetail=${eac_alarm_detail}
#  ${sum_object_2}=  Set Variable  ${object_3}${object_4}
#
#  ${alarm_query}=  Set Variable If   ${cfg.NODES['${cfg.primary_node_bts_id}']['scf_alarms_category']}
#  ...  ${sum_object}
#  ...  ${sum_object_2}
#  ${alarm_info}=  keywords.Info Model Get Alarm  alias=${alias}  query=${alarm_query}
#  ${alarm_info}=  Set Variable  ${alarm_info[0]}
#  ${eac_alarm_distname}=    Set Variable    ${alarm_info.dist_name}
#  [Return]    ${eac_alarm_distname}

#Info Model Get Alarm
#    [Arguments]  ${alias}=default  ${bts_l_id}=*  ${query}=*
#    [Documentation]  Returns list of active alarms that match the query.
#    ...              Call example: ${alarm}=  Info Model Get Alarm  ${query}=alarmActivity=Set, faultId=10
#    ${query}=        Set Variable If  '${query}'=='*'  ${EMPTY}  is [${query}]
#    @{available_alarms}=  Run Keyword If    ${cfg.NODES['${cfg.primary_node_bts_id}']['scf_alarms_category']}
#    ...      Query InfoModel    query=get list //FRI-${bts_l_id}/ALARM-* ${query}     alias=${alias}
#    ...      ELSE
#    ...      Query InfoModel    query=get list //LTS-${bts_l_id}//ALARM_L-* ${query}  alias=${alias}
#    [Return]    ${available_alarms}

#Clear EAC alarm
#    [Arguments]  ${eac_alarm}   ${eac_ip_addr_for_tested_alarm}    ${eac_port_for_tested_alarm}   ${scfc_with_eac_alarms}
#    keywords.Setup EAC Tester  ${eac_ip_addr_for_tested_alarm}
#    ${port_id}    Get Element Text  ${scfc_with_eac_alarms}
#    ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="portId"]
#    ${alarm_polarity}    Get Element Text  ${scfc_with_eac_alarms}
#    ...    xpath=//managedObject[@class='com.nokia.srbts.eqm:EAC_IN'][@distName='${eac_alarm}']/p[@name="polarity"]
#    ${port_state}=    Set Variable If    '${alarm_polarity}'=='Normally_closed'    C   O
#    keywords.EAC change port state   ${eac_port_for_tested_alarm}${port_id}      ${port_state}
#    keywords.Teardown EAC Tester
#
#EAC Alarm Should Be Cleared
#    [Arguments]      ${eac_alarm_cancelDelay}  ${fault_id}  ${alias}=default
#    ${clear_timeout}=     Evaluate          ${eac_alarm_cancelDelay}+10
#    Assert Alarm Inactive   faultId=${fault_id}  timeout=${clear_timeout}  alias=${alias}
#    Run Keyword And Continue On Failure     Mandatory And Allowed Alarms Should Be As Expected
#    ...  alias=${alias}

Prepare FHS Alarm Id
    [Arguments]  ${alias}
    Get Current SCF File  ${cfg.test_logs_path}  current_scf.xml  connection=${alias}
    scf.Load Scf  file_path=${cfg.test_logs_path}/current_scf.xml
    ${actCategoryAlarms}=  scf.Get All Values From Scf By Pattern  p_name=actCategoryAlarms
    ${alarm_id}=  Run Keyword If  '${actCategoryAlarms[0]}'=='true'  Create List  7115
    ...  ELSE  Create List  7652  7655
    [Return]  ${alarm_id}

Get Current AlarmId For FHS
    [Arguments]  ${alarmlist}
    FOR  ${alarm}  IN  @{alarmlist}
      Return From Keyword If  '${alarm['faultId']}'=='1936'  ${alarm['alarmId']}
    END

Get BTS ID For FHS
    [Arguments]    ${fhs_serial_number}
    FOR    ${node}    IN    @{cfg.active_bts_list}
        ${status}=    Run Keyword And Return Status    Evaluate    '${fhs_serial_number}' in ${cfg.NODES['${node}']['scf_hw_fhs_list']}
        Exit For Loop If  ${status}
    END
    Log    Active FHS is on BTS ID:${node}    console=True
    Set Test Variable    ${FHS_NODE}  ${node}
    ${active_fhs_related_sm}=    Get From Dictionary    ${cfg.NODES['${FHS_NODE}']}   primary_sm
    ${session_type}=    Get From Dictionary    ${cfg.NODES['${FHS_NODE}']}     bts_alias_type
    ${bts_ip}=    Get From Dictionary    ${cfg.NODES['${FHS_NODE}']}   vm_ip_LMP_address
    Set Test Variable    ${TC_ALIAS}  ${node}
    Set Test Variable    ${BTS_IP}  ${bts_ip}
    Set Test Variable    ${SESSION_TYPE}  ${session_type}
    [Return]    ${node}

SSH Create Session
    [Arguments]    ${alias}
    ${active_fhs_related_sm}=    Get From Dictionary    ${cfg.NODES['${FHS_NODE}']}   primary_sm
    ${session_type}=    Get From Dictionary    ${BTS_CONFIG.FSM['${active_fhs_related_sm}']}     bts_alias_type
    ${bts_ip}=    Get From Dictionary    ${BTS_CONFIG.FSM['${active_fhs_related_sm}']}   vm_ip_LMP_address
    ${connection}=    Run Keyword If   '${session_type}' == 'localhost'
    ...    Create Local SSH Session
    ...    ELSE   Create Remote SSH Session    ${bts_ip}
    Set Test Variable  ${BTS_IP}  ${bts_ip}
    [Return]    ${connection}    ${session_type}    ${bts_ip}

Create Local SSH Session
    SSHLibrary.Open Connection   host=192.168.255.129    prompt=REGEXP:[$#>]$
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]


Create Remote SSH Session
    [Arguments]    ${bts_ip}
    SSHLibrary.Open Connection      host=${bts_ip}    prompt=REGEXP:[$#>]$
    SSHLibrary.Login With Public Key    ute    /home/ute/.ssh/id_rsa
    SSHLibrary.Set Client Configuration  timeout=20s
    SSHLibrary.Read Until Regexp    :~
    SSHLibrary.Write   sshenb

Remove Old Configuration Files From FHS
    Log To Console  Remove Old Configuration Files From FHS
    ${connection}    ${session_type}    ${bts_ip}=    SSH Create Session    ${TC_ALIAS}
#    SSHLibrary.Open Connection    192.168.255.1    alias=FSM
#    SSHLibrary.Login              toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Write              lxc-attach -n ${LXC}
    Sleep  6
    SSHLibrary.Write              ssh serviceuser@${OUT_FHS_IP}
    Sleep  6
    ${output}=      SSHLibrary.Read
    ${pass}=  Run keyword and return status  Should contain   ${output}    password:
    SSHLibrary.Write              Pl(FzaYj5~c5;q
    Sleep  6
    SSHLibrary.Write              su toor4nsn
    Sleep  6
    ${output}=      SSHLibrary.Read
    ${pass}=  Run keyword and return status  Should contain   ${output}    Password:
    ${output}=  Run keyword if  ${pass}  SSHLibrary.Write              oZPS0POrRieRtu
    Sleep  6
    SSHLibrary.Write    rm * /configuration/runtime/configs/0/REV_2/*
    Sleep  6
    ${output}=      SSHLibrary.Read
    SSHLibrary.Close Connection
    others.HW Unit Reset  ${FHS_SERIAL}  timeout=900  alias=${TC_ALIAS}
    Run Keyword And Ignore Error    Assert Alarm Inactive    faultId=10     timeout=240 sec   alias=${TC_ALIAS}
