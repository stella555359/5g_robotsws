*** Settings ***
Documentation     Keywords related to UTE Cloud Testline handling

Library    OperatingSystem
Library    String

Library    python/testline_information.py

Resource   connect.robot
Resource   gnb.robot
Resource   tcpdump.robot
Resource   testline.robot
Resource   wts_ue.robot
Resource   core.robot
Resource   networking.robot
Resource   airphone.robot

*** Variables ***
${ENABLE_AP_SCTP_CHANGE}    ${False}
@{IP_LIST}    10.0.1.121    10.0.1.131    10.0.1.132    10.0.1.133    10.0.1.134    10.0.1.135    10.0.1.136    10.0.1.137

*** Keywords ***

UTE Cloud Workaround
    [Documentation]
    ...    To be used as FRIST keyword in Suite Setup
    ...    patch testline configure with missing configuration,
    ...    to add other IPs on test VM, you can define @{IP_LIST} in your testsuite Variables part.
    ...    Used for UTE Cloud Airphone TL
    ...
    Patch Testline Configuration For UTE Cloud
    FOR    ${ip}    IN    @{IP_LIST}
        Configure IP On VM    ip=${ip}    interface=eth3
    END
    WTS Config Files Are Present


Bring Airphone TL To On Air Status Without Reboot
    [Documentation]
    ...    This keyword is used for Suite Setup, which need gnb on air as pre-condition without GNB reboot
    ...    by default, gNbCuType both will be handled as SA TL
    ...
    ...    | remove_logs              | remove existing wts logs |
    ...    | cfg_file                 | path of wts config file to be used |
    ...    | force_cu_type            | define SA / NSA TL if gNbCuType is configured as SA+NSA |
    ...    | capture_cell_setup_trace | Captures a tcpdump on the interface between L2-PS and CP-RT |
    ...    | cell_setup_trace_dir     | Places the captured L2-PS, CP-RT interface trace in the provided directory |
    ...    | kw_timeout               | overall TO for the whole KW |
    ...
    [Arguments]   ${remove_logs}=${False}   ${cfg_file}=${tl.core.cfg_filename}   ${force_cu_type}=SA+NSA   ${capture_cell_setup_trace}=${FALSE}
    ...           ${cell_setup_trace_dir}=${EMPTY}   ${kw_timeout}=15min
    [Timeout]     15min

    gnb.Wait For Minimum Required State For Cell Setup For All GNBs    timeout=${kw_timeout}
    Modify SCTP Settings On Test-VM And AP
    IF   ${capture_cell_setup_trace}   Start Trace On L2 PS CP RT Interface
    Configure WTS For UTE Cloud Airphone TL    remove_logs=${remove_logs}    cfg_file=${cfg_file}    force_cu_type=${force_cu_type}
    Log   ${\n}----------------------------------------------------------------------   console=${P_console}
    Verify Cell Setup
    [Teardown]      Stop Trace On L2_PS CP_RT Interface If Started      capture_cell_setup_trace=${capture_cell_setup_trace}
    ...                                                                 cell_setup_trace_dir=${cell_setup_trace_dir}


Stop Trace On L2 PS CP RT Interface If Started
    [Arguments]    ${capture_cell_setup_trace}      ${cell_setup_trace_dir}
    IF   ${capture_cell_setup_trace} and '${tl_info.deployment_type()}'=='classical'
    ...             Run Keyword And Warn On Failure    Stop Trace On L2_PS CP_RT Interface   target_dir=${cell_setup_trace_dir}


Bring Airphone TL To On Air Status
    [Documentation]
    ...    This keyword is used for testcases, which need gnb on air as pre-condition
    ...    or this keyword can be used as testline recovery once testcase failed
    ...    by default, gNbCuType both will be handled as SA TL
    ...
    ...    | remove_logs              | remove existing wts logs |
    ...    | cfg_file                 | path of wts config file to be used |
    ...    | force_cu_type            | define SA / NSA TL if gNbCuType is configured as SA+NSA |
    ...    | capture_cell_setup_trace | Captures a tcpdump on the interface between L2-PS and CP-RT |
    ...    | cell_setup_trace_dir     | Places the captured L2-PS, CP-RT interface trace in the provided directory |
    ...    | kw_timeout               | overall TO for the whole KW |
    ...
    ...    *Example*
    ...
    ...    | IF | '${PREV_TEST_STATUS}'=='FAIL' | Bring Airphone TL to on Air status |
    ...
    [Arguments]    ${remove_logs}=${False}    ${cfg_file}=${tl.core.cfg_filename}    ${force_cu_type}=SA+NSA   ${capture_cell_setup_trace}=${FALSE}
    ...            ${cell_setup_trace_dir}=${EMPTY}   ${kw_timeout}=30min
    [Timeout]      ${kw_timeout}

    Bring Airphone TL To F1 Up Status
    IF   ${capture_cell_setup_trace}   Start Trace On L2_PS CP_RT Interface
    Configure WTS For UTE Cloud Airphone TL    remove_logs=${remove_logs}    cfg_file=${cfg_file}    force_cu_type=${force_cu_type}
    Log   ----------------------------------------------------------------------   console=${P_console}
    Verify Cell Setup
    [Teardown]    Stop Trace On L2 PS CP RT Interface If Started    capture_cell_setup_trace=${capture_cell_setup_trace}
    ...                                                             cell_setup_trace_dir=${cell_setup_trace_dir}



Bring Airphone TL To F1 Up Status
    [Documentation]
    ...    This keyword is used for testcases, which need gnb and ap correctly startup as pre-condition
    ...    or this keyword can be used as testline recovery once testcase failed
    ...
    ...    | timeout    | timeout to wait for a single iteration of the startup sequence |
    ...    | kw_timeout | timeout for the whole KW, so over all iteration, so max. waiting time |
    ...
    ...    *Example:*
    ...    | IF | '${PREV_TEST_STATUS}'=='FAIL' | Bring Airphone TL to F1 up status |
    ...
    [Arguments]    ${timeout}=10min     ${kw_timeout}=60min
    [Timeout]      ${kw_timeout}
    wts_ue.Kill WTS Services
    Wait Until Keyword Succeeds    3x    30 sec    Run Keywords
    ...         wts_ue.Reset Airphone Testline
    ...   AND   gnb.Wait For Minimum Required State For Cell Setup For All GNBs    ${timeout}
    Modify SCTP Settings On Test-VM And AP


Configure IP On VM
    [Documentation]
    ...    Add IP adress to specified interface
    ...    Used for UTE Cloud Airphone TL
    [Arguments]    ${ip}    ${interface}
    OperatingSystem.Run    sudo ip addr add ${ip}/24 dev ${interface}
    ${output}   OperatingSystem.Run     ip addr show dev ${interface} | grep ${ip}
    Should Contain      ${output}    ${ip}


Reset IP On VM
    [Documentation]
    ...    Reset interface to its default IP addresses
    ...    Used for UTE Cloud Airphone TL
    [Arguments]    ${interface}
    OperatingSystem.Run   sudo ifdown ${interface} ; sudo ifup ${interface}


Log TL Info As Metadata
    [Documentation]
    ...    This keyword is used to log GNB SW, GNB HW, AP SW, AP HW, Duplex Mode in Metadata section of log.html
    ...    to ease daily regression check
    ...
    ...    *Restriction* only single gNB with single DU with single Common Unit supported
    ...
    [Arguments]   ${gnb_id}=0   ${du_id}=0   ${gnb_comu}=0   ${ue_id}=0   ${ap_comu}=0
    ${status}   ${tl_name}      Run Keyword And Ignore Error                testline.Get Testline Name
    ${tl_name}                  Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${tl_name}
    ${status}   ${gnb_0_sw}     Run Keyword And Ignore Error                testline.Get GNB SW Version   gnb_id=${gnb_id}   du_id=${du_id}
    ${gnb_0_sw}                 Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${gnb_0_sw}
    ${status}   ${ap_0_sw}      Run Keyword And Ignore Error                testline.Get Airphone SW Version   ue_id=${ue_id}
    ${ap_0_sw}                  Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${ap_0_sw}
    ${status}   ${gnb_comu_hw}  Run Keyword And Ignore Error
    ...                         testline.Get Common Unit Type   gnb_id=${gnb_id}   du_id=${du_id}   common_unit_id=${gnb_comu}
    ${gnb_0_hw}                 Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${gnb_comu_hw}
    ${gnb_0_hw}                 Log TL Info As Metadata For UTE AP TL Dump GNB Capu Num   ${gnb_id}  ${du_id}  ${gnb_comu}  ${gnb_0_hw}

    ${status}   ${ap_comu_hw}   Run Keyword And Ignore Error
    ...                         testline.Get Airphone Common Unit Type   ue_id=${ue_id}   comu_id=${ap_comu}
    ${ap_0_hw}                  Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${ap_comu_hw}

    ${status}   ${ap_capu_num}  Run Keyword And Ignore Error
    ...                         Get Length    ${tl.ues[${ue_id}].l1.common_units[${ap_comu}].capacity_units}
    ${ap_capu_num}              Set Variable If     '${status}'=='FAIL'     0     ${ap_capu_num}
    Log   ${ap_capu_num}
    FOR    ${capu_id}    IN RANGE   ${ap_capu_num}
        ${status}   ${ap_capu_hw}   Run Keyword And Ignore Error
        ...                         testline.Get Airphone Capacity Unit Type    ue_id=${ue_id}   comu_id=${ap_comu}   capu_id=${capu_id}
        ${ap_0_hw}                  Set Variable If     '${status}'=='FAIL'     ${ap_0_hw} UNKNOWN     ${ap_0_hw} ${ap_capu_hw}
    END

    ${status}   ${cellTechnology}   Run Keyword And Ignore Error    wts_ue.Get CellTechnology Info
    ${cellTechnology}           Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${cellTechnology}

    ${tl_info_string}   Catenate   SEPARATOR=\n
    ...    \nUsed SW and HW on ${tl_name}:    GNB SW: ${gnb_0_sw}    GNB HW: ${gnb_0_hw}    AP SW: ${ap_0_sw}    AP HW: ${ap_0_hw}
    ...    Duplex Mode: ${cellTechnology}

    FOR   ${title}            ${value}   IN
    ...   Testline Info               ${tl_name}
    ...   gNB Software Info           ${gnb_0_sw}
    ...   AP Software Info            ${ap_0_sw}
    ...   gNB Hardware Info           ${gnb_0_hw}
    ...   AP Hardware Info            ${ap_0_hw}
    ...   Duplex Mode Info            ${cellTechnology}
        Set Suite Metadata    ${title}   ${value}   top=${True}
    END

    Log To Console   ${tl_info_string}     console=${P_console}


Log TL Info As Metadata For UTE AP TL
    [Documentation]
    ...    This keyword is used to log GNB SW, GNB HW, AP SW, AP HW, Duplex Mode in Metadata section of log.html
    ...    to ease daily regression check
    ...
    ...    *Restriction* only single gNB with single DU with single Common Unit supported
    ...
    [Arguments]   ${gnb_id}=0   ${du_id}=0   ${gnb_comu}=0   ${ue_id}=0   ${ap_comu}=0
    ${status}   ${tl_name}      Run Keyword And Ignore Error                testline.Get Testline Name
    ${tl_name}                  Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${tl_name}
    ${status}   ${gnb_0_sw}     Run Keyword And Ignore Error                testline.Get GNB SW Version   gnb_id=${gnb_id}   du_id=${du_id}
    ${gnb_0_sw}                 Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${gnb_0_sw}
    ${status}   ${ap_0_sw}      Run Keyword And Ignore Error                testline.Get Airphone SW Version   ue_id=${ue_id}
    ${ap_0_sw}                  Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${ap_0_sw}
    ${status}   ${gnb_comu_hw}  Run Keyword And Ignore Error
    ...                         testline.Get Common Unit Type   gnb_id=${gnb_id}   du_id=${du_id}   common_unit_id=${gnb_comu}
    ${gnb_0_hw}                 Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${gnb_comu_hw}
    ${gnb_0_hw}                 Log TL Info As Metadata For UTE AP TL Dump Gnb Capu Num   ${gnb_id}  ${du_id}  ${gnb_comu}  ${gnb_0_hw}

    ${status}   ${ap_comu_hw}   Run Keyword And Ignore Error
    ...                         testline.Get Airphone Common Unit Type   ue_id=${ue_id}   comu_id=${ap_comu}
    ${ap_0_hw}                  Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${ap_comu_hw}

    ${ap_capu_num}              Get Length    ${tl.ues[${ue_id}].l1.common_units[${ap_comu}].capacity_units}
    FOR    ${capu_id}    IN RANGE   ${ap_capu_num}
        ${status}   ${ap_capu_hw}   Run Keyword And Ignore Error
        ...                         testline.Get Airphone Capacity Unit Type    ue_id=${ue_id}   comu_id=${ap_comu}   capu_id=${capu_id}
        ${ap_0_hw}                  Set Variable If     '${status}'=='FAIL'     ${ap_0_hw} UNKNOWN     ${ap_0_hw} ${ap_capu_hw}
    END

    ${status}   ${cellTechnology}   Run Keyword And Ignore Error    wts_ue.Get CellTechnology Info
    ${cellTechnology}           Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${cellTechnology}

    ${tl_info_string}   Catenate   SEPARATOR=\n
    ...    \nUsed SW and HW on ${tl_name}:    GNB SW: ${gnb_0_sw}    GNB HW: ${gnb_0_hw}    AP SW: ${ap_0_sw}    AP HW: ${ap_0_hw}
    ...    Duplex Mode: ${cellTechnology}

    FOR   ${title}            ${value}   IN
    ...   Testline Info               ${tl_name}
    ...   gNB Software Info           ${gnb_0_sw}
    ...   AP Software Info            ${ap_0_sw}
    ...   gNB Hardware Info           ${gnb_0_hw}
    ...   AP Hardware Info            ${ap_0_hw}
    ...   Duplex Mode Info            ${cellTechnology}
        Set Suite Metadata    ${title}   ${value}   top=${True}
    END

    Log To Console   ${tl_info_string}     console=${P_console}


Log TL Info As Metadata For UTE AP TL Dump GNB Capu Num
    [Documentation]
    ...    This keyword is used to log GNB Capacity Numbers in Metadata section of log.html
    ...    to ease daily regression check
    ...
    ...    *Restriction* only single gNB with single DU with single Common Unit supported
    ...
    [Arguments]   ${gnb_id}=0   ${du_id}=0   ${gnb_comu}=0  ${gnb_0_hw}=UNKNOWN
    ${gnb_1_hw}                 Set Variable    ${gnb_0_hw}
    ${gnb_capu_num}             Get Length   ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${gnb_comu}].capacity_units}
    FOR    ${capu_id}    IN RANGE   ${gnb_capu_num}
        ${status}   ${gnb_capu_hw}  Run Keyword And Ignore Error
        ...                         testline.Get Capacity Unit Type     gnb_id=${gnb_id}    gnb_id=${gnb_id}    du_id=${du_id}
        ...                                                             common_unit_id=${gnb_comu}   capu_id=${capu_id}
        ${gnb_1_hw}             Set Variable If   '${status}'=='FAIL'    ${gnb_1_hw} UNKNOWN     ${gnb_1_hw} ${gnb_capu_hw}
    END
    RETURN    ${gnb_1_hw}


Check TL Connectivity And PDU Status
    [Documentation]
    ...     This KW is for information and debugging of a TL. It is intended to run before the test start.
    ...     It checks the oam and lmp to the gnb[0] and the lmp connection with the AP and the PDU ports status
    ...     of the gnb and AP.
    ...
    ${oam_ip_status}   Run Keyword And Ignore Error
    ...                 networking.Wait Until Ping Succeeds    ip_addr=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ${log_level}    Set Variable If    '${oam_ip_status}[0]'=='FAIL'    WARN    DEBUG
    Log    Ping to ${tl.gnbs[0].cu.oam_http_connection_details.addr}: ${oam_ip_status}    ${log_level}    console=${P_console}
    ${lmp_ip_status}   Run Keyword And Ignore Error
    ...                 networking.Wait Until Ping Succeeds    ip_addr=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${log_level}    Set Variable If    '${lmp_ip_status}[0]'=='FAIL'    WARN    DEBUG
    Log    Ping to ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}: ${lmp_ip_status}    ${log_level}    console=${P_console}
    ${ue_ip_status}    Run Keyword And Ignore Error
    ...                 networking.Wait Until Ping Succeeds    ip_addr=${tl.ues[0].l1.common_units[0].lmp_connection.addr}
    ${log_level}    Set Variable If    '${ue_ip_status}[0]'=='FAIL'    WARN    DEBUG
    Log    Ping to ${tl.ues[0].l1.common_units[0].lmp_connection.addr}: ${ue_ip_status}    ${log_level}    console=${P_console}
    ${nmap_ping_result}   OperatingSystem.Run
    ...     sudo nmap -sP --send-ip -n 192.168.255.1 192.168.255.129 192.168.200.1 192.168.200.129 10.0.1.2 10.0.2.80
    Log    ${nmap_ping_result}
    ${nmap_gnb_result}   OperatingSystem.Run   sudo nmap -n -p22,443 192.168.255.129
    Log    ${nmap_gnb_result}
    ${nmap_ap_result}   OperatingSystem.Run   sudo nmap -n -p22 192.168.200.129
    Log    ${nmap_ap_result}
    ${arp_result}   OperatingSystem.Run   /usr/sbin/ip n # was arp -n
    Log    ${arp_result }
    ${nmap_sctp_result_ap}   OperatingSystem.Run   sudo nmap -sY 10.0.2.80 -p 8888
    Log    ${nmap_sctp_result_ap}
    ${_}   ${gnb_alias}   Run Keyword And Ignore Error    connect.Connect To Node Common Unit
    ${_}   ${gnb_sctp_result}   Run Keyword And Warn On Failure
    ...    ssh.Execute     command=cat /proc/net/sctp/eps    connection=${gnb_alias}    timeout=30s
    Log    ${gnb_sctp_result}
    ${_}   ${ap_alias}    Run Keyword And Ignore Error    connect.Connect To Airphone Common Unit
    ${_}   ${ap_sctp_result}   Run Keyword And Warn On Failure
    ...    ssh.Execute     command=cat /proc/net/sctp/eps    connection=${ap_alias}    timeout=30s
    Log    ${ap_sctp_result}
    ${gnb_pdu_status}   Run Keyword And Ignore Error    testline.Get PDU Power Status
    ...    pdu=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}   pdu_port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    IF    '${gnb_pdu_status}[0]'=='FAIL'   RETURN
    ${log_level}    Set Variable If    '${gnb_pdu_status}[1]'=='off'    WARN    DEBUG
    Log    GNB PDU status: ${gnb_pdu_status}[1]    ${log_level}    console=${P_console}
    ${ue_pdu_status}    Run Keyword And Ignore Error    testline.Get PDU Power Status
    ...    pdu=${tl.ues[0].l1.common_units[0].pdu_port.pdu}   pdu_port=${tl.ues[0].l1.common_units[0].pdu_port.port_no}
    IF    '${ue_pdu_status}[0]'=='FAIL'   RETURN
    ${log_level}    Set Variable If    '${ue_pdu_status}[1]'=='off'    WARN    DEBUG
    Log    UE PDU status: ${ue_pdu_status}[1]    ${log_level}    console=${P_console}


Patch Testline Configuration For UTE Cloud
    [Documentation]
    ...    Used for UTE Cloud Airphone TL. Adds needed core and enb objects to ${tl} as they are
    ...    not defined in the testline configuration __init__.py file.
    ...
    ...    *Scope*   Internal
    ...
    testline.Get Testline Name
    Import Variables    ${CURDIR}/config/ute_cloud_ap_config.py


WTS Config Files Are Present
    [Documentation]
    ...    Used for UTE Cloud Airphone TL. We expect the agent_sim will store the WTS cfg file to
    ...    ${tl.core.dir_path}. The KW raises an error if the config file doesn't exist.
    ...
    ...    *Scope*   Internal
    ...
    OperatingSystem.File Should Exist    ${tl.core.dir_path}/${tl.core.cfg_filename}    msg=WTS config files are missing!


Configure WTS For UTE Cloud Airphone TL
    [Documentation]
    ...    Used for UTE Cloud Airphone TL, by default, gNbCuType both will be handled as SA TL
    ...
    ...    *Scope* Internal
    ...
    ...    | remove_logs   | flag if existing wts logs shall be removed  |
    ...    | cfg_file      | path of wts config file to be used |
    ...    | force_cu_type | define SA / NSA TL if gNbCuType is configured as SA+NSA |
    ...
    [Arguments]   ${remove_logs}=${False}   ${cfg_file}=${tl.core.cfg_filename}   ${force_cu_type}=SA+NSA
    ${scf_cu_type}   wts_ue.Get GNbCuType Info
    ${gNbCuType}     Set Variable If   '${scf_cu_type}'=='SA+NSA' or '${scf_cu_type}'=='both'   ${force_cu_type}   ${scf_cu_type}
    wts_ue.Start WTS For Airphone   remove_logs=${remove_logs}


    IF        '${gNbCuType}'=='NSA'
        Configure WTS With X2 Link   cfg_file=${cfg_file}
    ELSE IF   '${gNbCuType}'=='SA'
        wts_ue.Config WTS For Airphone   pass_regexp=NB 2 cell 1.*SystemInformationBlockType1-NR updated    cfg_file=${cfg_file}    timeout=300
    ELSE IF   '${gNbCuType}'=='SA+NSA'
        wts_ue.Config WTS For Airphone   pass_regexp=NB 2 cell 1.*SystemInformationBlockType1-NR updated    cfg_file=${cfg_file}    timeout=300
        wts_ue.Setup X2 Link
    ELSE IF   '${gNbCuType}'=='NR-DC-SN+SA'
        wts_ue.Config WTS For Airphone   pass_regexp=NB 2 cell 1.*SystemInformationBlockType1-NR updated    cfg_file=${cfg_file}    timeout=300
    ELSE
        Fail  not supported TL type
    END

    Sleep   5s   reason=waiting for Airphone stabilized


Configure WTS With X2 Link
    [Documentation]
    ...    Used for NSA Test Case
    ...
    ...    *Scope*   Internal
    ...
    ...    | cfg_file | path of wts config file to be used |
    ...
    [Arguments]    ${cfg_file}=${tl.core.cfg_filename}
    wts_ue.Config WTS For Airphone    pass_regexp=SystemInformationBlockType2 updated    cfg_file=${cfg_file}
    wts_ue.Setup X2 Link


Verify Cell Setup
    [Documentation]
    ...    Used for UTE Cloud Airphone TL
    ...    Waits until the cell setup is completed
    ...
    ...    *Scope*   Internal
    ...
    ${total_cells}    testline.Get Number Of All Configured NRCELLs
    ${nbr_of_ignored_cells}   airphone.Get Number Of MPlaneOnly Cells
    ${nbr_of_checked_cells}   Evaluate   ${total_cells} - ${nbr_of_ignored_cells}
    gnb.Wait Until All GNBs To Be Onair State    timeout=2 min
    Wait Until Keyword Succeeds   1min   20sec   wts_ue.Check Egate Output Ensure Cells Setup Successful   total_cells=${nbr_of_checked_cells}


Modify SCTP Settings On Test-VM And AP
    [Documentation]
    ...    Run this KW on AP/WTS VM every time reboot the machine, This should handle the timeout issue
    ...    This is for airphone testline with irfhead, to overcome testline instability.
    ...
    ...    29.04.2024: after discussion with AP team we disable the AP sctp changes here!
    ...    But you can enforce the previous behaviour by setting ${ENABLE_AP_SCTP_CHANGE} to ${True}!
    ...
    ...    The UTE agent airphone hook changes during TL installation the VM sctp values
    ...    by executing /opt/wts/latest/sctp_wts_commands.sh! So our KW values must be aligned with that values!
    ...
    ...    *Scope*   Internal
    ...
    ${cmds}    Catenate    SEPARATOR=;
    ...    sudo sysctl -w net.sctp.rto_min=400
    ...    sudo sysctl -w net.sctp.rto_initial=400
    ...    sudo sysctl -w net.sctp.rto_max=800
    ...    sudo sysctl -w net.sctp.sack_timeout=20
    OperatingSystem.Run    ${cmds}

    IF   not ${ENABLE_AP_SCTP_CHANGE}   RETURN

    ${cmds}    Catenate    SEPARATOR=;
    ...    sysctl -w net.sctp.rto_min=400
    ...    sysctl -w net.sctp.rto_initial=400
    ...    sysctl -w net.sctp.rto_max=800
    ...    sysctl -w net.sctp.sack_timeout=20
    ${ap_alias}    connect.Connect To Airphone Common Unit
    ssh.Execute    command=${cmds}    connection=${ap_alias}    timeout=30s


Start Trace On L2 PS CP RT Interface
    [Documentation]
    ...    This Keyword starts a tcpdump on L2-PS CP-RT interface
    ...
    ...    *Scope*   Internal
    ...
    ...    *Returns* collector name
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}
    ...           ${collector}=cell_setup_trace
    ${capu_type}    testline.Get Capacity Unit Type    gnb_id=${gnb_id}    du_id=${du_id}
    ...    common_unit_id=${comu_id}    capu_id=${capu_id}

    IF   $capu_type in ['ABIO', 'ABIP', 'ABIN']
        tcpdump.Start L2_L3 SYSCOM Trace On ABIO   gnb_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ...     capu_id=${capu_id}   options=-i etha01.212   collector=${collector}
    END
    RETURN   ${collector}


Stop Trace On L2_PS CP_RT Interface
    [Documentation]
    ...    This Keyword stops the tcpdump on L2-PS CP-RT interface and stores it in the given directory
    ...
    ...    *Scope*   Internal
    ...
    ...    *Returns* Path to pcap file of tcpdump incl. filename
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}
    ...           ${collector}=cell_setup_trace   ${target_dir}=${EMPTY}
    IF   '${target_dir}'=='${EMPTY}'
        ${target_dir}   testline.Get Test Suite Log Directory
    END

    ${capu_type}    testline.Get Capacity Unit Type    gnb_id=${gnb_id}    du_id=${du_id}
    ...    common_unit_id=${comu_id}    capu_id=${capu_id}

    IF   $capu_type in ['ABIO', 'ABIP', 'ABIN']
        ${trace_path}    tcpdump.Stop L2_L3 SYSCOM Trace On ABIO
    ...    collector=${collector}   target_dir=${target_dir}   tcpdump_filename=l2_l3_tcpdump
    END
    RETURN   ${trace_path}
