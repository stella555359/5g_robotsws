*** Settings ***
Documentation    Keywords for the CB013025

Library      String
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      ute_wtssim
Library      ta5g_testline_management
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ta5g_throughput
Library      ta5g_scfc_analysis
Library      ta5g_egate
Library      ta5g_commissioning
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/gnb.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/testline_configuration.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot


*** Keywords ***
Install Bsr Package For AQQJ
    [Documentation]
    ...  Downloads, unzip and install BSR package for AQQJ RU on SBTS
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Install Bsr Package For AQQJ

    ${artifactory_location}=    Set Variable    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/BSR
    ${bsr_filename}=            Set Variable    BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    ${bsr_target_filepath}=     Set Variable    ${OUTPUT_DIR}

    Install Bsr Package    bsr_file_path=${artifactory_location}/${bsr_filename}
    ...                    target_file_path=${bsr_target_filepath}/${bsr_filename}

Start Listening On TCE Port
    [Documentation]
    ...  Starts Netcat process to act as TCE listener on port given in the SCF
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Start Listening On TCE Port

    ${tce_port}=    Get TCE Port
    Turn On Netcat    options=-l  ip=  port=${tce_port}
    Sleep    20s    reason=Break needed for proper enabling Netcat to listening messages on NRPPA

Get TCE Port
    [Documentation]
    ...  Searches active SCF for TCE and returns its defined port number
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${tce_port}=  Get TCE Port

    ${tce_port_param_in_list}=    Create List    tcePortNumber
    coam.Setup Admin
    ${tce_list} =    coam.Get Parameter By Class    class_name=TCE    parameter_list=@{tce_port_param_in_list}
    [Return]    ${tce_list[0]['parameters']['tcePortNumber']}
    [Teardown]    Run Keywords    coam.Teardown Admin

Get TCE IP
    [Documentation]
    ...  Searches active SCF for TCE and returns its defined ip number
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${tce_ip}=  Get TCE IP

    ${tce_ip_param_in_list}=    Create List        tceIpAddress
    coam.Setup Admin
    ${tce_list} =    coam.Get Parameter By Class    class_name=TCE    parameter_list=@{tce_ip_param_in_list}
    [Return]    ${tce_list[0]['parameters']['tceIpAddress']}
    [Teardown]    Run Keywords    coam.Teardown Admin

Get srbInactivityTimerSA value
    [Documentation]
    ...  Searches active SCF for NRBTS-1 and returns its defined srbInactivityTimerSA
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${srbInactivityTimerSA_val}=  Get srbInactivityTimerSA value

    ${srbInactivityTimerSA_param_in_list}=    Create List        srbInactivityTimerSA
    coam.Setup Admin
    ${nrbts_list} =    coam.Get Parameter By Distname    dist_name=MRBTS-1/NRBTS-1   parameter_list=@{srbInactivityTimerSA_param_in_list}
    [Return]    ${nrbts_list[0]['parameters']['srbInactivityTimerSA']}
    [Teardown]    Run Keywords    coam.Teardown Admin

Stop Listening On TCE Port
    [Documentation]
    ...  Stops Netcat process acting as TCE listener
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Stop Listening On TCE Port

    Turn Off Netcat

Validate Trace Recording Session Elements SBA
    [Documentation]
    ...  KW verifies incoming tshark SBA report msgs against given filter
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | filter                 | Yes  | Filter to verify against SBA report msgs                              |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | alias                  | No   | Alias of the tshark to be verified. Default alias value assumes       |
    ...  |                        |      | existance of ${TCE_ALIAS} which is created via                        |
    ...  |                        |      | KW Start Tshark For TCE Msgs And Store Alias                          |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | number_of_messages     | No   | Expected number of msg to be found                                    |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Validate Trace Recording Session Elements SBA    filter=nsetapx.angleOfArrivalRecord    number_of_messages=1

    [Arguments]   ${filter}    ${alias}=${TCE_ALIAS}    ${number_of_messages}=1
    Log  \n==== Validate Trace Recording Session Elements SBA ====  console=True
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${alias}
    ...    packet_filter=nsetapx.traceActivationType == 1 && ${filter}
    ...    number_of_messages=${number_of_messages}

Validate Trace Recording Session Elements MBA
    [Documentation]
    ...  KW verifies incoming tshark MBA report msgs against given filter
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | filter                 | Yes  | Filter to verify against SBA report msgs                              |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | alias                  | No   | Alias of the tshark to be verified. Default alias value assumes       |
    ...  |                        |      | existance of ${TCE_ALIAS} which is created via                        |
    ...  |                        |      | KW Start Tshark For TCE Msgs And Store Alias                          |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | number_of_messages     | No   | Expected number of msg to be found                                    |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | timeout                | No   | Timeout to wait for incoming msgs                                     |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Validate Trace Recording Session Elements MBA    filter=nsetapx.directionOfArrivalRecord

    [Arguments]   ${filter}    ${alias}=${TCE_ALIAS}    ${number_of_messages}=1    ${timeout}=60
    Log  \n==== Validate Trace Recording Session Elements MBA ====  console=True
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${alias}
    ...    packet_filter=nsetapx.traceActivationType == 0 && ${filter}
    ...    number_of_messages=${number_of_messages}
    ...    timeout=${timeout}

Validate Beam Type
    [Documentation]
    ...  KW verifies incoming tshark MBA/SBA reports msgs against given beam type
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | beam_type              | Yes  | Beam type value to verify against reports msgs                        |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | alias                  | No   | Alias of the tshark to be verified. Default alias value assumes       |
    ...  |                        |      | existance of ${TCE_ALIAS} which is created via                        |
    ...  |                        |      | KW Start Tshark For TCE Msgs And Store Alias                          |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Validate Beam Type    alias=${TCE_ALIAS}    beam_type=1

    [Arguments]    ${beam_type}    ${alias}=${TCE_ALIAS}
    Log  \n==== Validate Beam Type ====  console=True
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${alias}
    ...    packet_filter=nsetapx.beamType == ${beam_type}
    ...    number_of_messages=1

Start Subscriber Trace
    [Documentation]
    ...  KW executes egate command to start subscriber trace on TCE entity
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ue_id                  | No   | Id of the ue which schoud be traced                                   |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Start Subscriber Trace  ue_id=1

    [Arguments]    ${ue_id}=1
    ${tce_ip}=    Get TCE IP
    ${start_trace_cmd}=    Catenate    ng_ue_trace_start    id=${ue_id}    trace_plmn=311:489    trace_ref_id=1    trace_rec_session_ref_id=2
    ...                                ifaces_to_trace=E1,F1-C,NG-C,Uu,Xn-C    trace_depth=maximum tce_ip=${tce_ip}
    Execute Egate Cmd    cmd=${start_trace_cmd}

Stop Subscriber Trace
    [Documentation]
    ...  KW executes egate command to stop subscriber trace on TCE entity
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ue_id                  | No   | Id of the ue which trace should be stopped                            |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Stop Subscriber Trace  ue_id=1

    [Arguments]    ${ue_id}=1
    Execute Egate Cmd    cmd=ng_ue_trace_stop id=${ue_id} trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=2

Exit Idle Mode And Start Data Traffic
    [Documentation]
    ...  KW exits simulated UE from idle mode then it starts data traffic and verifies the throughput.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW exits idle mode of the simuleted ue, if ue happend to reach it.
    ...  Then in active mode it starts data traffic and verifies the throughput.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ue_id                  | No   | Id of the ue to take part in the process                              |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | pdu_id                 | No   | PDU session id of the ue to be used in traffic process                |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Exit Idle Mode And Start Data Traffic  ue_id=1  pdu_id=2

    [Arguments]    ${ue_id}=1   ${pdu_id}=1
    Log  \n==== Start Data Traffic ====  console=True
    Exit Idle Mode Without Confirmation      ue_id=${ue_id}
    Start And Check Data Traffic    ues=${ue_id}    direction=both    pdu=${pdu_id}    throughput=100mbps    qfi=1

Start Tshark For TCE Msgs And Store Alias
    [Documentation]
    ...  KW starts custom tshark process to capture TCE msgs and stores its alias in test variable.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Start Tshark For TCE Msgs And Store Alias

    ${tce_alias}=    Start Tshark For Custom Interface    eth_interface=eth3    log_dirpath=${TC_LOGS_PATH}
    ...    log_filename_prefix=TCE    capture_filter=tcp    preferences=None
    Set Test Variable    ${tce_alias}    ${TCE_ALIAS}

Start Vm Ethernet Interfaces
    [Documentation]
    ...  KW configures additional ethernet interfaces on VM for CLOUD_5G_O_E_AP_LOOO and for listening as the TCE.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW configures additional ethernet interfaces on VM
    ...  required for the default egate configuration on TL CLOUD_5G_O_E_AP_LOOO VARIANT_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_2
    ...  and for listening as the TCE.
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Start Vm Ethernet Interfaces

    ${tce_ip}=    Get TCE IP
    ${tce_ip_last_octet}=    Fetch From Right    string=${tce_ip}    marker=.
    @{eth3_ips}=    Create List    ${tce_ip_last_octet}    101    102
    Configure Interfaces    eth=eth3    ips_range=${eth3_ips}

Stop Vm Ethernet Interfaces
    [Documentation]
    ...  KW deconfigures additional ethernet interfaces on VM for CLOUD_5G_O_E_AP_LOOO and for listening as the TCE.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW deconfigures additional ethernet interfaces on VM
    ...  required for the default egate configuration on TL CLOUD_5G_O_E_AP_LOOO VARIANT_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_2
    ...  and for listening as the TCE.
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Stop Vm Ethernet Interfaces

    ${tce_ip}=    Get TCE IP
    ${tce_ip_last_octet}=    Fetch From Right    string=${tce_ip}    marker=.
    @{eth3_ips}=    Create List    ${tce_ip_last_octet}    101    102
    Stop Interfaces    eth=eth3    ips_range=${eth3_ips}

Attach SA UE And Establish PDU Session
    [Documentation]
    ...  KW logs this step to the console. Then it attaches UE and immediately starts PDU session with given parameters.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ue_id                  | Yes  | Id of the ue to handle. Default value is test variable ${UE_ID}       |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | cell_id                | Yes  | Cell id for ue to attach to.                                          |
    ...  |                        |      | Default value is test variable ${CELL_ID}                             |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | enb_id                 | No   | eNG/gNB id holding the cell for the ue                                |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Attach SA UE And Establish PDU Session  ue_id=1  cell_id=1

    [Arguments]    ${ue_id}=${UE_ID}    ${cell_id}=${CELL_ID}    ${enb_id}=2
    Log  \n==== Attach SA UE And Establish PDU Session ====  console=True
    Attach And Establish PDU Session For UE    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${enb_id}

Set TC Logs Path Variable
    [Documentation]
    ...  KW assigns test variable with path to the TC logs created via logging policy in the test suite.
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Full description:**
    ...
    ...  KW assigns test variable with path to the TC logs created via logging policy in the test suite.
    ...  Then it is provided to ta5g libraries to store the logs in same directory.
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Set TC Logs Path Variable

    Set Test Variable    ${TC_LOGS_PATH}    ${OUTPUT_DIR}${/}Logs${/}${SUITE_NAME.replace(" ", "_")}${/}${TEST_NAME}
