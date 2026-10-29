*** Settings ***
Documentation
...  contact: Szymon Startek

Library            SSHLibrary
Library            String
Library            Collections


*** Keywords ***
Check Temperature At Rmod
    [Documentation]
    ...  This KW checks highest temperature of AVQL RU sensors
    ...
    ...  | **Author:** kamila.gmerek@nokia.com
    ...
    ...  | Login on SM
    ...  | Enter lxc container
    ...  | Login to RU ( AVQL )
    ...  | Get all temperature values from sensors by frmonShellClient app to list.
    ...  | Sort list and return the highest value
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+-----------------+--------------------------------------------------+
    ...  | Parameter              | Parameter Level | Description                                      |
    ...  +========================+=================+==================================================+
    ...  | ${GNB_OAM_IP}          | global          | SM host IP                                       |
    ...  | ${USERNAME}            | global          | SM username                                      |
    ...  | ${PASSWORD}            | global          | SM password                                      |
    ...  | ${BBMODULE_ADRESS}     | global          | Address of lxc container   eg. 0x1018            |
    ...  | ${RMOD_IP}             | global          | RMOD IP                                          |
    ...  +------------------------+-----------------+--------------------------------------------------+
    Log  === Login At Rmod And Check Temperature ===  console=True
    @{TEMP_LIST}    Create List
    Open Connection    ${GNB_OAM_IP}
    Login    ${USERNAME}    ${PASSWORD}
    Set Client Configuration    timeout=10 seconds
    Write Bare    lxc-attach -n ${BBMODULE_ADRESS}\r
    ${output}    Read Until    >
    Write Bare    rm /user/toor4nsn/.ssh/known_hosts\r
    ${output}    Read Until   >
    Write Bare    ssh ${RMOD_USERNAME}@${RMOD_IP}\r
    ${output}    Read Until    ?
    Write Bare    yes\r
    ${output}    Read Until    password:
    Write Bare    ${RMOD_PASSWORD}\r
    ${output}    Read Until    \$
    Write Bare    frmonShellClient 127.0.0.1 2000\r
    ${output}    Read Until    $
    Write Bare    / action create ThermometerDevice /xd /temp/mars1/xd\r
    ${output}    Read Until    ]
    ${therm_device_list}    Split String    ${output[${output.index('[')}+1:${output.__len__()}-1]}    ,
    Set Client Configuration    timeout=0.5 seconds
    FOR    ${device}    IN RANGE    ${therm_device_list.__len__()}
        Write Bare    / action create ThermometerDevice /tm${device} ${therm_device_list[${device}]}\r
        Run Keyword And Ignore Error    Read Until    ok
        Write Bare    /tm${device} get temperature\r
        ${output}    ${temp}    Run Keyword And Ignore Error    Read Until Regexp    [0-9][0-9]\.[0-9][0-9]
        Append To List    ${temp_list}    ${temp.split()[-1]}
    END
    Remove Values From List	${temp_list}    .
    Sort List    ${temp_list}
    Log To Console    === Temperature at the hottest sensor is: ${temp_list[-1]} ===
    Return From Keyword    ${temp_list[-1]}
    [Teardown]    Close All Connections


Setup Temperature Thresholds at RMOD
    [Documentation]
    ...  This KW checks highest temperature of AVQL RU sensors
    ...
    ...  | **Author:** kamila.gmerek@nokia.com
    ...
    ...  | Login on SM
    ...  | Enter lxc container
    ...  | Login to RU ( AVQL )
    ...  | Initiate threshold file existance
    ...  | Swap appropriate values for thresholds
    ...  | Save threshold file before reboot
    ...  | Reboot RU
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+-----------------+--------------------------------------------------+
    ...  | Parameter              | Parameter Level | Description                                      |
    ...  +========================+=================+==================================================+
    ...  | ${GNB_OAM_IP}          | global          | SM host IP                                       |
    ...  | ${USERNAME}            | global          | SM username                                      |
    ...  | ${PASSWORD}            | global          | SM password                                      |
    ...  | ${BBMODULE_ADRESS}     | global          | Address of lxc container   eg. 0x1018            |
    ...  | ${RMOD_IP}             | global          | RMOD IP                                          |
    ...  | ${OFF_THRESHOLD}       | global          | Off temperature threshold                        |
    ...  | ${ON_THRESHOLD}        | global          | On temperature threshold                         |
    ...  | ${BLANK_TIMER}         | global          | Timer for blanking information update            |
    ...  +------------------------+-----------------+--------------------------------------------------+

    Log  Setup Temperature Tresholds at RMOD  console=True
    Open Connection    ${GNB_OAM_IP}
    Login    ${USERNAME}    ${PASSWORD}
    Set Client Configuration    timeout=10 seconds
    Write Bare    lxc-attach -n ${BBMODULE_ADRESS}\r
    ${output}    Read Until    >
    Write Bare    rm /user/toor4nsn/.ssh/known_hosts\r
    ${output}    Read Until    >
    Write Bare    ssh ${RMOD_USERNAME}@${RMOD_IP}\r
    ${output}    Read Until    ?
    Write Bare    yes\r
    ${output}    Read Until    password:
    Write Bare    ${RMOD_PASSWORD}\r
    ${output}    Read Until    \$
    Write Bare    cd /var/tmp\r
    ${output}    Read Until    \$
    Write Bare    sudo dapd -duc tcs_parameters\r
    ${output}    Read Until    \$
    Write Bare    sudo -i sed -i 's,"T_sym_blank_off": [0-9]*,"T_sym_blank_off": ${OFF_THRESHOLD},g' /var/tmp/tcs_parameters.json\r
    ${output}    Read Until    \$
    Write Bare    sudo -i sed -i 's,"T_sym_blank_on": [0-9]*,"T_sym_blank_on": ${ON_THRESHOLD},g' /var/tmp/tcs_parameters.json\r
    ${output}    Read Until    \$
    Write Bare    sudo -i sed -i 's,"T_sym_blank_timer": [0-9]*,"T_sym_blank_timer": ${BLANK_TIMER},g' /var/tmp/tcs_parameters.json\r
    ${output}    Read Until    \$
    Write Bare    cat tcs_parameters.json\r
    ${output}    Read Until    \$
    Write Bare    sudo -u rfsw bash -c 'source /etc/profile; dapd -ciuc tcs_parameters.json'\r
    ${output}    Read Until    \$
    Write Bare    sudo -i reboot\r
    [Teardown]    Close All Connections


Print Thresholds After RU Reboot And Validating Threshold Values
    [Documentation]
    ...  This KW prints file that contains information about thresholds
    ...
    ...  | **Author:** kamila.gmerek@nokia.com
    ...
    ...  | Login on SM
    ...  | Enter lxc container
    ...  | Login to RU ( AVQL )
    ...  | Initiate threshold file existance
    ...  | Log threshold file content
    ...  | Validating threshold values
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------------+-----------------+--------------------------------------------------+
    ...  | Parameter                    | Parameter Level | Description                                      |
    ...  +==============================+=================+==================================================+
    ...  | ${GNB_OAM_IP}                | global          | SM host IP                                       |
    ...  | ${USERNAME}                  | global          | SM username                                      |
    ...  | ${PASSWORD}                  | global          | SM password                                      |
    ...  | ${BBMODULE_ADRESS}           | global          | Address of lxc container   eg. 0x1018            |
    ...  | ${RMOD_IP}                   | global          | RMOD IP                                          |
    ...  | ${ON_THRESHOLD_CONFIGURED}   | global          | 'ON' Threshold value                             |
    ...  | ${OFF_THRESHOLD_CONFIGURED}  | global          | 'OFF' Threshold value                            |
    ...  +------------------------+-----------------+--------------------------------------------------------+


    Log  Print Thresholds After RU Reboot And Validating Threshold Values  console=True
    Open Connection    ${GNB_OAM_IP}
    Login    ${USERNAME}    ${PASSWORD}
    Set Client Configuration    timeout=10 seconds
    Write Bare    lxc-attach -n ${BBMODULE_ADRESS}\r
    ${output}    Read Until    >
    Write Bare    rm /user/toor4nsn/.ssh/known_hosts\r
    ${output}    Read Until    >
    Write Bare    ssh ${RMOD_USERNAME}@${RMOD_IP}\r
    ${output}    Read Until    ?
    Write Bare    yes\r
    ${output}    Read Until    password:
    Write Bare    ${RMOD_PASSWORD}\r
    ${output}    Read Until    \$
    Write Bare    cd /var/tmp\r
    ${output}    Read Until    \$
    Write Bare    sudo dapd -duc tcs_parameters\r
    ${output}    Read Until    \$
    Write Bare    sudo cat tcs_parameters.json\r
    ${output}    Read Until    \$
    Write Bare    sudo chmod 777 tcs_parameters.json\r
    ${output}    Read Until    \$
    Write Bare    exit\r
    ${output}    Read Until    >
    Write Bare    scp -O ${RMOD_USERNAME}@${RMOD_IP}:/var/tmp/tcs_parameters.json /user/toor4nsn\r
    ${output}    Read Until    password:
    Write Bare    ${RMOD_PASSWORD}\r
    ${output}    Read Until    >
    Write Bare    exit\r
    ${output}    Read Until    >
    Write Bare    logout\r

    ${source_file}=  Set Variable  /user/toor4nsn/tcs_parameters.json
    ${destination_file}=  Set Variable  /tmp/tcs_parameters.json
    ${result} =  Run Process
    ...  command=sshpass -p '${PASSWORD}' scp -q -O ${USERNAME}@${GNB_OAM_IP}:${source_file} ${destination_file}  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=RC is not equal to 0. There were some errors during execution of scp command.\nError message: ${result.stderr}.

    Log To Console  RC:${result.rc}, STDOUT:${result.stdout}, STDERR:${result.stderr}

    ${result}=  Run Process  test -f ${destination_file}  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=File does not exist at ${destination_file}

    ${result} =  Run Process
    ...  command=jq -r '.tcs.T_sym_blank_on' ${destination_file}  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=RC is not equal to 0. There were some errors during execution of jq command.\nError message: ${result.stderr}.
    ${msg}=  Set Variable  Errors appeared while executing command: jq -r '.tcs.T_sym_blank_on' \
    ...  ${destination_file}.\nError message: ${result.stderr}
    Should Be Equal As Strings  '${result.stderr}'  ''
    ...  msg=${msg}
    Should Not Be True  ${result.stdout} == 0
    ...  msg=Value for T_sym_blank_on is not present.
    Log To Console  Value for 'T_sym_blank_on' is present:${result.stdout}
    ${ON_THRESHOLD_CONFIGURED} =  Set Variable  ${result.stdout}

    ${result} =  Run Process
    ...  command=jq -r '.tcs.T_sym_blank_off' ${destination_file}  shell=True
    Should Be Equal As Integers  ${result.rc}  0
    ...  msg=RC is not equal to 0. There were some errors during execution of jq command.\nError message: ${result.stderr}.
    ${msg}=  Set Variable  Errors appeared while executing command: jq -r '.tcs.T_sym_blank_off' \
    ...  ${destination_file}.\nError message: ${result.stderr}
    Should Be Equal As Strings  '${result.stderr}'  ''
    ...  msg=${msg}
    Should Not Be True  ${result.stdout} == 0
    ...  msg=Value for T_sym_blank_off is not present.
    Log To Console  Value for 'T_sym_blank_off' is present:${result.stdout}
    ${OFF_THRESHOLD_CONFIGURED} =  Set Variable    ${result.stdout}

    Should Be Equal  ${ON_THRESHOLD_CONFIGURED}  ${ON_THRESHOLD}  msg='T_sym_blank_on' value has not been set correctly
    Log To Console  Value is correctly set to: ${ON_THRESHOLD_CONFIGURED}
    Should Be Equal  ${OFF_THRESHOLD_CONFIGURED}  ${OFF_THRESHOLD}  msg='T_sym_blank_off' value has not been set correctly
    Log To Console  Value is correctly set to: ${OFF_THRESHOLD_CONFIGURED}
    [Teardown]    Close All Connections
