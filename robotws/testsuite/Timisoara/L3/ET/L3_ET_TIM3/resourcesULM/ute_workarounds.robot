*** Settings ***
Documentation     Keywords related to UTE Cloud Testline handling

Library    OperatingSystem
Library    String

Library    python/robot_extension.py          WITH NAME    rbext_py
Library    python/ute_workarounds.py
Library    python/testline_information.py

Resource   connect.robot
Resource   gnb.robot
Resource   tcpdump.robot
Resource   testline.robot
Resource   wts_ue.robot
Resource   core.robot
Resource   networking.robot
Resource   aic_vdu.robot
Resource   aic_cu.robot

*** Variables ***
@{IP_LIST}    10.0.1.121    10.0.1.131    10.0.1.132    10.0.1.133    10.0.1.134    10.0.1.135    10.0.1.136    10.0.1.137

*** Keywords ***

UTE Cloud Workaround
    [Documentation]
    ...    To be used as FRIST keyword in Suite Setup
    ...    patch testline configure with missing configuration,
    ...    to add other IPs on test VM, you can define @{IP_LIST} in your testsuite Variables part.
    ...    Used for UTE Cloud Airphone TL
    ...
    Patch testline configuration for UTE Cloud
    FOR    ${ip}    IN    @{IP_LIST}
        Configure IP on VM    ip=${ip}    interface=eth3
    END
    WTS Config Files Are Present


Bring Airphone TL to on Air status without reboot
    [Documentation]
    ...    This keyword is used for Suite Setup, which need gnb on air as pre-condition without GNB reboot
    ...    by default, gNbCuType both will be handled as SA TL
    ...
    ...    | remove_logs              | remove existing wts logs |
    ...    | cfg_file                 | path of wts config file to be used |
    ...    | force_cu_type            | define SA / NSA TL if gNbCuType is configured as SA+NSA |
    ...    | capture_cell_setup_trace | Captures a tcpdump on the interface between L2-PS and CP-RT (not for AiC) | 
    ...    | cell_setup_trace_dir     | Places the captured L2-PS, CP-RT interface trace in the provided directory (not for AiC) |
    ...    | kw_timeout               | overall TO for the whole KW |
    ...
    [Arguments]    ${remove_logs}=${False}    ${cfg_file}=${tl.core.cfg_filename}    ${force_cu_type}=SA+NSA   ${capture_cell_setup_trace}=${FALSE}
    ...            ${cell_setup_trace_dir}=${EMPTY}   ${kw_timeout}=60min
    [Timeout]      ${kw_timeout}

    Run Keyword If   '${tl_info.deployment_type()}' == 'aic'
    ...   Run Keywords
    ...         Bring Airphone TL to On air status with aic   remove_logs=${remove_logs}
    ...                                                       cfg_file=${cfg_file}
    ...                                                       force_cu_type=${force_cu_type}
    ...                                                       kw_timeout=${kw_timeout}
    ...                                                       reboot=${False}
    ...   AND   Return From Keyword

    gnb.Wait until F1 link up for all gNBs    timeout=10min
    Run Keyword If   ${capture_cell_setup_trace}   Start Trace on L2_PS CP_RT interface
    Configure WTS for UTE Cloud Airphone TL    remove_logs=${remove_logs}    cfg_file=${cfg_file}    force_cu_type=${force_cu_type}
    Verify Cell Setup
    [Teardown]   Run Keyword If   ${capture_cell_setup_trace} and '${tl_info.deployment_type()}'=='classical'
    ...             Run Keyword And Ignore Error    Stop Trace on L2_PS CP_RT interface   target_dir=${cell_setup_trace_dir}



Bring Airphone TL to on Air status
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
    ...    | Run Keyword If | '${PREV_TEST_STATUS}'=='FAIL' | Bring Airphone TL to on Air status |
    ...
    [Arguments]    ${remove_logs}=${False}    ${cfg_file}=${tl.core.cfg_filename}    ${force_cu_type}=SA+NSA   ${capture_cell_setup_trace}=${FALSE}
    ...            ${cell_setup_trace_dir}=${EMPTY}   ${kw_timeout}=60min
    [Timeout]      ${kw_timeout}


    Run Keyword If   '${tl_info.deployment_type()}' == 'aic'
    ...   Run Keywords
    ...         Bring Airphone TL to On air status with aic   remove_logs=${remove_logs}
    ...                                                       cfg_file=${cfg_file}
    ...                                                       force_cu_type=${force_cu_type}
    ...                                                       kw_timeout=${kw_timeout}
    ...   AND   Return From Keyword

    Bring Airphone TL to F1 up status
    Run Keyword If   ${capture_cell_setup_trace}   Start Trace on L2_PS CP_RT interface
    Configure WTS for UTE Cloud Airphone TL    remove_logs=${remove_logs}    cfg_file=${cfg_file}    force_cu_type=${force_cu_type}
    Verify Cell Setup
    [Teardown]   Run Keyword If   ${capture_cell_setup_trace} and '${tl_info.deployment_type()}'=='classical'
    ...             Run Keyword And Ignore Error    Stop Trace on L2_PS CP_RT interface   target_dir=${cell_setup_trace_dir}


Bring Airphone TL to F1 up status
    [Documentation]
    ...    This keyword is used for testcases, which need gnb and ap correctly startup as pre-condition
    ...    or this keyword can be used as testline recovery once testcase failed
    ...
    ...    | timeout    | timeout to wait for a single iteration of the startup sequence |
    ...    | kw_timeout | timeout for the whole KW, so over all iteration, so max. waiting time |
    ...
    ...    *Example:*
    ...    | Run Keyword If | '${PREV_TEST_STATUS}'=='FAIL' | Bring Airphone TL to F1 up status |
    ...
    [Arguments]    ${timeout}=10min     ${kw_timeout}=60min
    [Timeout]      ${kw_timeout}
    core.Kill previous WTS services
    Wait Until Keyword Succeeds    3x    30 sec    Run Keywords
    ...         wts_ue.Reset Airphone Testline
    ...   AND   gnb.Wait until F1 link up for all gNBs    ${timeout}
    Modify SCTP Settings on Test-VM and AP


Bring Airphone TL to on Air status with Aic
    [Documentation]
    ...    This keyword is used for Aic testcases, which need gnb on air as pre-condition
    ...    or this keyword can be used as testline recovery once testcase failed
    ...    by default, gNbCuType both will be handled as SA TL
    ...
    ...    | remove_logs   | remove existing wts logs |
    ...    | cfg_file      | path of wts config file to be used |
    ...    | force_cu_type | define SA / NSA TL if gNbCuType is configured as SA+NSA |
    ...    | kw_timeout    | overall TO for the whole KW |
    ...
    ...    *Example:*
    ...    | Run Keyword If | '${PREV_TEST_STATUS}'=='FAIL' | Bring Airphone TL to on Air status |
    ...
    [Arguments]    ${remove_logs}=${False}    ${cfg_file}=${tl.core.cfg_filename}    ${force_cu_type}=SA+NSA   ${kw_timeout}=60min   ${reboot}=${True}
    [Timeout]      ${kw_timeout}

    Run Keyword If    ${reboot}
    ...   Run Keywords
    ...         core.Kill previous WTS services
    ...   AND   aic_cu.Reboot CU
    ...   AND   aic_vdu.Reboot All VDUs
    ...   AND   wts_ue.Reboot Airphone via Console

    Wait Until Keyword Succeeds    15x    60 sec    Run Keywords
    ...         aic_vdu.Wait until All VDU are ready
    ...   AND   aic_cu.F1 Link Status of CU should be available

    wts_ue.Wait until Airphone board ready     timeout=3min

    Configure WTS for UTE Cloud Airphone TL    remove_logs=${remove_logs}    cfg_file=${cfg_file}    force_cu_type=${force_cu_type}
    Wait Until Keyword Succeeds    1 min    20 sec    Run Keywords
    ...         aic_vdu.Wait until all VDU are on Air
    ...   AND   wts_ue.Check Current Egate Console Status    Cell Setup completed


Prepare TL for TTITraces
    [Documentation]
    ...    This keyword helps to download and install MULTI packages needed for TTITraces
    ...
    ute_workarounds.Install Multidynamic if neeeded


Configure IP on VM
    [Documentation]
    ...    Add IP adress to specified interface
    ...    Used for UTE Cloud Airphone TL
    [Arguments]    ${ip}    ${interface}
    OperatingSystem.Run    sudo ip addr add ${ip}/24 dev ${interface}
    ${output}   OperatingSystem.Run     ip addr show dev ${interface} | grep ${ip}
    Should Contain      ${output}    ${ip}


Reset IP on VM
    [Documentation]
    ...    Reset interface to its default IP addresses
    ...    Used for UTE Cloud Airphone TL
    [Arguments]    ${interface}
    OperatingSystem.Run   sudo ifdown ${interface} ; sudo ifup ${interface}


Log TL Info as Metadata for UTE AP TL
    [Documentation]
    ...    This keyword is used to log GNB SW, GNB HW, AP SW, AP HW, Duplex Mode in Metadata section of log.html
    ...    to ease daily regression check
    ...
    ...    *Restriction* only single gNB with single DU with single Common Unit supported
    ...

    [Arguments]   ${gnb_id}=0   ${du_id}=0   ${gnb_comu}=0   ${ue_id}=0   ${ap_comu}=0
    ${status}   ${tl_name}      Run Keyword And Ignore Error                testline.Get Testline Name
    ${tl_name}                  Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${tl_name}
    ${status}   ${gnb_0_sw}     Run Keyword And Ignore Error                testline.Get gNB SW version   gnb_id=${gnb_id}   du_id=${du_id}
    ${gnb_0_sw}                 Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${gnb_0_sw}
    ${status}   ${ap_0_sw}      Run Keyword And Ignore Error                testline.Get Airphone SW version   ue_id=${ue_id}
    ${ap_0_sw}                  Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${ap_0_sw}
    ${status}   ${gnb_comu_hw}  Run Keyword And Ignore Error
    ...                         testline.Get Common Unit Type   gnb_id=${gnb_id}   du_id=${du_id}   common_unit_id=${gnb_comu}
    ${gnb_0_hw}                 Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${gnb_comu_hw}

    ${gnb_capu_num}             Get length   ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${gnb_comu}].capacity_units}
    FOR    ${capu_id}    IN RANGE   ${gnb_capu_num}
        ${status}   ${gnb_capu_hw}  Run Keyword And Ignore Error
        ...                         testline.Get Capacity Unit Type     gnb_id=${gnb_id}    gnb_id=${gnb_id}    du_id=${du_id}
        ...                                                             common_unit_id=${gnb_comu}   capu_id=${capu_id}
        ${gnb_0_hw}             Set Variable If   '${status}'=='FAIL'    ${gnb_0_hw} UNKNOWN     ${gnb_0_hw} ${gnb_capu_hw}
    END

    ${status}   ${ap_comu_hw}   Run Keyword And Ignore Error
    ...                         testline.Get Airphone Common Unit Type   ue_id=${ue_id}   comu_id=${ap_comu}
    ${ap_0_hw}                  Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${ap_comu_hw}

    ${ap_capu_num}              Get length    ${tl.ues[${ue_id}].l1.common_units[${ap_comu}].capacity_units}
    FOR    ${capu_id}    IN RANGE   ${ap_capu_num}
        ${status}   ${ap_capu_hw}   Run Keyword And Ignore Error
        ...                         testline.Get Airphone Capacity Unit Type    ue_id=${ue_id}   comu_id=${ap_comu}   capu_id=${capu_id}
        ${ap_0_hw}                  Set Variable If     '${status}'=='FAIL'     ${ap_0_hw} UNKNOWN     ${ap_0_hw} ${ap_capu_hw}
    END
    
    ${status}   ${cellTechnology}   Run Keyword And Ignore Error    wts_ue.Get cellTechnology Info
    ${cellTechnology}           Set Variable If     '${status}'=='FAIL'     UNKNOWN     ${cellTechnology}
    ${tl_info}   Catenate   SEPARATOR=\n
    ...    \nUsed SW and HW on ${tl_name}:    GNB SW: ${gnb_0_sw}    GNB HW: ${gnb_0_hw}    AP SW: ${ap_0_sw}    AP HW: ${ap_0_hw}
    ...    Duplex Mode: ${cellTechnology}
    BuiltIn.Log To Console   ${tl_info}     console=${P_console}

    FOR   ${title}            ${value}   IN
    ...   Testline Info       ${tl_name}
    ...   gNB Software Info   ${gnb_0_sw}
    ...   AP Software Info    ${ap_0_sw}
    ...   gNB Hardware Info   ${gnb_0_hw}
    ...   AP Hardware Info    ${ap_0_hw}
    ...   Duplex Mode Info    ${cellTechnology}
        Set Suite Metadata    ${title}   ${value}   top=${True}
    END


Check TL connectivity and PDU status
    [Documentation]
    ...     This KW is for information and debugging of a TL. It is intended to run before the test start.
    ...     It checks the oam and lmp to the gnb[0] and the lmp connection with the AP and the PDU ports status
    ...     of the gnb and AP.
    ...
    ${oam_ip_status}   Run Keyword And Ignore Error
    ...                 networking.Wait Until Ping Succeeds    ip_addr=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ${log_level}    Set Variable If    '${oam_ip_status}[0]'=='FAIL'    WARN    DEBUG
    BuiltIn.Log    Ping to ${tl.gnbs[0].cu.oam_http_connection_details.addr}: ${oam_ip_status}    ${log_level}    console=${P_console}
    ${lmp_ip_status}   Run Keyword And Ignore Error
    ...                 networking.Wait Until Ping Succeeds    ip_addr=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${log_level}    Set Variable If    '${lmp_ip_status}[0]'=='FAIL'    WARN    DEBUG
    BuiltIn.Log    Ping to ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}: ${lmp_ip_status}    ${log_level}    console=${P_console}
    ${ue_ip_status}    Run Keyword And Ignore Error
    ...                 networking.Wait Until Ping Succeeds    ip_addr=${tl.ues[0].l1.common_units[0].lmp_connection.addr}
    ${log_level}    Set Variable If    '${ue_ip_status}[0]'=='FAIL'    WARN    DEBUG
    BuiltIn.Log    Ping to ${tl.ues[0].l1.common_units[0].lmp_connection.addr}: ${ue_ip_status}    ${log_level}    console=${P_console}
    ${nmap_ping_result}   OperatingSystem.Run
    ...     sudo nmap -sP --send-ip -n 192.168.255.1 192.168.255.129 192.168.200.1 192.168.200.129 10.0.1.2 10.0.2.80
    BuiltIn.Log    ${nmap_ping_result}
    ${nmap_gnb_result}   OperatingSystem.Run   sudo nmap -n -p22,443 192.168.255.129
    BuiltIn.Log    ${nmap_gnb_result}
    ${nmap_ap_result}   OperatingSystem.Run   sudo nmap -n -p22 192.168.200.129
    BuiltIn.Log    ${nmap_ap_result}
    ${arp_result}   OperatingSystem.Run   /usr/sbin/arp -n
    BuiltIn.Log    ${arp_result }
    ${nmap_sctp_result_ap}   OperatingSystem.Run   sudo nmap -sY 10.0.2.80 -p 8888
    BuiltIn.Log    ${nmap_sctp_result_ap}
    ${connect_status}   ${gnb_alias}   Run Keyword And Ignore Error    connect.Connect to Node Common Unit
    ${gnb_sctp_status}   ${gnb_sctp_result}   rbext_py.run_keyword_and_warn_on_failure
    ...    ssh.execute     command=cat /proc/net/sctp/eps    connection=${gnb_alias}    timeout=30s
    BuiltIn.Log    ${gnb_sctp_result}
    ${connect_status}   ${ap_alias}    Run Keyword And Ignore Error    connect.Connect to Airphone Common Unit
    ${ap_sctp_status}   ${ap_sctp_result}   rbext_py.run_keyword_and_warn_on_failure
    ...    ssh.execute     command=cat /proc/net/sctp/eps    connection=${ap_alias}    timeout=30s
    BuiltIn.Log    ${ap_sctp_result}
    ${gnb_pdu_status}   Run Keyword And Ignore Error    testline.Get PDU power status
    ...    pdu=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}   pdu_port=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    Return From Keyword If    '${gnb_pdu_status}[0]'=='FAIL'
    ${log_level}    Set Variable If    '${gnb_pdu_status}[1]'=='off'    WARN    DEBUG
    BuiltIn.Log    GNB PDU status: ${gnb_pdu_status}[1]    ${log_level}    console=${P_console}
    ${ue_pdu_status}    Run Keyword And Ignore Error    testline.Get PDU power status
    ...    pdu=${tl.ues[0].l1.common_units[0].pdu_port.pdu}   pdu_port=${tl.ues[0].l1.common_units[0].pdu_port.port_no}
    Return From Keyword If    '${ue_pdu_status}[0]'=='FAIL'
    ${log_level}    Set Variable If    '${ue_pdu_status}[1]'=='off'    WARN    DEBUG
    BuiltIn.Log    UE PDU status: ${ue_pdu_status}[1]    ${log_level}    console=${P_console}


Patch testline configuration for UTE Cloud
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
    ...    ${tl.core.dir_path}.
    ...
    ...    *Scope*   Internal
    ...
    ...    *Returns*    ${True} if wts config files are prepared by UTE agent, ${False} if they are not found
    ...
    OperatingSystem.File Should Exist    ${tl.core.dir_path}/${tl.core.cfg_filename}    msg=WTS config files are missing!


Configure WTS for UTE Cloud Airphone TL
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
    ${scf_cu_type}   wts_ue.Get gNbCuType Info
    ${gNbCuType}     Set Variable If   '${scf_cu_type}'=='SA+NSA' or '${scf_cu_type}'=='both'   ${force_cu_type}   ${scf_cu_type}
    wts_ue.Start WTS for Airphone   remove_logs=${remove_logs}

    Run Keyword If   '${gNbCuType}'=='NSA'   Configure WTS with X2 link   cfg_file=${cfg_file}
    ...   ELSE IF    '${gNbCuType}'=='SA'    wts_ue.Config WTS for Airphone   pass_regexp=NB 2 cell 1.*SystemInformationBlockType1-NR updated
    ...                                      cfg_file=${cfg_file}    timeout=600
    ...   ELSE IF    '${gNbCuType}'=='SA+NSA'   Run Keywords
    ...              wts_ue.Config WTS for Airphone   pass_regexp=NB 2 cell 1.*SystemInformationBlockType1-NR updated
    ...                                               timeout=600   cfg_file=${cfg_file}
    ...        AND   wts_ue.Setup X2 Link
    ...   ELSE       Fail   not supported TL type

    Sleep   5s   reason=waiting for Airphone stabilized


Configure WTS with X2 link
    [Documentation]
    ...    Used for NSA Test Case
    ...
    ...    *Scope*   Internal
    ...
    ...    | cfg_file | path of wts config file to be used |
    ...
    [Arguments]    ${cfg_file}=${tl.core.cfg_filename}
    wts_ue.Config WTS for Airphone    pass_regexp=SystemInformationBlockType2 updated    cfg_file=${cfg_file}
    wts_ue.Setup X2 Link


Verify Cell Setup
    [Documentation]
    ...    Used for UTE Cloud Airphone TL
    ...    Waits until the cell setup is completed
    ...
    ...    *Scope*   Internal
    ...
    ${total_cells}    testline.Get number of all configured NRCELLs
    gnb.Wait until all gNBs to be onair state    timeout=2 min
    ${status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    1 min    20 sec    wts_ue.Check APL3 Log Ensure Cells Setup Successful   total_cells=${total_cells}
    Run Keyword If    ${status} == False
    ...    Wait Until Keyword Succeeds    1 min    20 sec    wts_ue.Check Egate Output Ensure Cells Setup Successful    total_cells=${total_cells}


Modify SCTP Settings on Test-VM and AP
    [Documentation]
    ...    Run this KW on AP/WTS VM every time reboot the machine, This should handle the timeout issue
    ...    This is for airphone testline with irfhead, to overcome testline instability.
    ...
    ...    *Scope*   Internal
    ...
    ${cmds}    Catenate    SEPARATOR=;
    ...    sudo sysctl -w net.sctp.rto_min=200
    ...    sudo sysctl -w net.sctp.rto_initial=200
    ...    sudo sysctl -w net.sctp.rto_max=800
    ...    sudo sysctl -w net.sctp.sack_timeout=10
    OperatingSystem.Run    ${cmds}
    ${cmds}    Catenate    SEPARATOR=;
    ...    sysctl -w net.sctp.rto_min=200
    ...    sysctl -w net.sctp.rto_initial=200
    ...    sysctl -w net.sctp.rto_max=800
    ...    sysctl -w net.sctp.sack_timeout=10
    ${ap_alias}    connect.Connect to Airphone Common Unit
    ssh.execute    command=${cmds}    connection=${ap_alias}    timeout=30s


Start Trace on L2_PS CP_RT interface
    [Documentation]
    ...    This Keyword starts a tcpdump on L2-PS CP-RT interface
    ...
    ...    *Scope*   Internal
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}
    ...           ${collector}=cell_setup_trace
    ${P_capu_type}    testline.Get Capacity Unit Type    gnb_id=${gnb_id}    du_id=${du_id}    common_unit_id=${comu_id}
    ...    capu_id=${capu_id}
    Set Suite Variable   ${P_capu_type}
    Run Keyword If   '${P_capu_type}'=='ABIO' or '${P_capu_type}'=='ABIP'
    ...    tcpdump.Start L2_L3 SYSCOM Trace on ABIO   gnb_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ...    capu_id=${capu_id}   interface=etha01.212   collector=${collector}


Stop Trace on L2_PS CP_RT interface
    [Documentation]
    ...    This Keyword stops the tcpdump on L2-PS CP-RT interface and stores it in the given directory
    ...
    ...    *Scope*   Internal
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${capu_id}=${0}
    ...           ${collector}=cell_setup_trace   ${target_dir}=${EMPTY}
    ${default_suite_log_dir}   Run Keyword If   '${target_dir}'=='${EMPTY}'   testline.Get test suite log directory
    ${target_dir}   Set Variable If   '${target_dir}'=='${EMPTY}'   ${default_suite_log_dir}   ${target_dir}
    Run Keyword If   '${P_capu_type}'=='ABIO' or '${P_capu_type}'=='ABIP'
    ...    tcpdump.Stop L2_L3 SYSCOM Trace on ABIO
    ...    collector=cell_setup_trace   target_dir=${target_dir}   tcpdump_filename=l2_l3_tcpdump
