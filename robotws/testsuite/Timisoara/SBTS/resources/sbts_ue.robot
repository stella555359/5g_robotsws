*** Settings ***
Library  taf.ue
Resource  ca_SBTS_general.robot

Documentation  This suite contains KWs used by UE TCs.
...  Example of Nokia UE configuration:
...  _android1 = TafUeAndroid(serial_number='AQ5003H048PA0800779',
...                           capabilities=['NR_only', 'LTE_only'],
...                           ue_pc_address='10.5.53.26',
...                           data_transfer=[_data_transfer_iperf_2,
...                                          _data_transfer_ping_2,
...                                          _data_transfer_ftp_2],
...                           ue_pc_port='8080',
...                           ssh_connection_details=_test_pc_ue,
...                           service_call_attach='16',
...                           service_call_detach='16',
...                           network_mode_switch_method='secretcode',
...                           airplane_mode_switcher_text='Airplane mode',
...                           path_to_network_mode_type='Mobile networks/Preferred network type',
...                           is_rooted='no')


*** Keywords ***
Attach UE If Needed
    [Documentation]
    ...  This keyword checks if UE is attached to one SBTS cell. If not, 2 operations
    ...  can be performed: airplane mode is turned on/off and UE is restarted. If after both of these
    ...  operations the UE is still not attached to any cell, then this keyword fails.
    ...
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${ue_alias}  ${cells_ids}

    Log  Checking if UE is on desired cell.  console=true
    ${ue_cell_id}  Get Ue Info  ${ue_alias}  CELL_ID
    ${initial_status}  Check If UE Is On Correct Cell  ${cells_ids}  ${ue_cell_id}
    IF  ${initial_status}  RETURN  ELSE  Turn On/off Airplane Mode  ${ue_alias}
    ${ue_cell_id}  Get Ue Info  ${ue_alias}  CELL_ID
    ${status_after_airplane_off_on}  Run Keyword And Return Status
    ...  Should Contain  ${cells_ids}  ${ue_cell_id}
    IF  ${status_after_airplane_off_on}  RETURN  ELSE  Reboot_UE  ${ue_alias}  300
    ${ue_cell_id}  Get Ue Info  ${ue_alias}  CELL_ID
    ${status_after_reboot}  Run Keyword And Return Status
    ...  Should Contain  ${cells_ids}  ${ue_cell_id}
    IF  ${status_after_reboot} == ${FALSE}  Fail  UE cannot be attached!
    Turn Mobile Data On  ${ue_alias}


Turn On/off Airplane Mode
    [Documentation]  This keyword is used to turn on/off airplane mode
    [Arguments]  ${ue_alias}

    Log  Turn on/off airplane mode.  console=true
    Detach Ue  ${ue_alias}  300
    Sleep  10s
    Attach Ue  ${ue_alias}  120
    Sleep  15s


Get Ids For GSM Cells
    [Documentation]
    ...  This keyword establishes a ssh connection to BSC and sends the ZEEI command to get the
    ...  cell ids for GSM. These ids are returned by this keyword because they are used by
    ...  Nokia Android Application.
    ...
    ...  *AUTHOR*: anna.benzar@nokia.com
    ...  *MAINTAINER*: anna.benzar@nokia.com

    Bsc Ssh Connection  host=${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}
    Bsc Login
    ${bcf_parameters}  coam.Get Parameters  /MRBTS-1/RAT-1/GTS-1/BCF_L-1
    ${bcf_id}  Set Variable  ${bcf_parameters}[bcfId]
    ${cell_ids}  Get Gsm Cells Ids  ${bcf_id}

    RETURN  ${cell_ids}


Get Ids For WCDMA Cells
    [Documentation]
    ...  Ids for WCDMA cells provided by Nokia Android Application are identical to ids
    ...  given by WCDMA cells runtime distname. This keyword return the wcdma cells ids from these
    ...  runtime distnames.
    ...
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com

    ${cells_ids}  Create List
    ${cells_dns}  Get Ids For All  WNCEL
    FOR  ${cell_dn}  IN  @{cells_dns}
        ${cell_id}  Fetch From Right  ${cell_dn}  -
        Append To List  ${cells_ids}  ${cell_id}
    END

    RETURN  ${cells_ids}


Get Ids For LTE Cells
    [Documentation]
    ...  This keyword takes the values of eutraCelId parameter from LTE cells runtime objects.
    ...  The eutraCelId parameter is the unique identifier of LTE cells in Nokia Android Application.
    ...
    ...  *AUTHOR*: cosmina.rebenciuc@nokia.com
    ...  *MAINTAINER*: cosmina.rebenciuc@nokia.com

    ${info_lte_cells}  Get Parameters For All  LNCEL
    ${list_lte_e_utra_cell_ids}  Create List
    FOR  ${cell}  IN  @{info_lte_cells}
        ${eutra_cell_id}  Get From Dictionary  ${cell}  eutraCelId
        ${eutra_cell_id}  Convert To String  ${eutra_cell_id}
        Append To List  ${list_lte_e_utra_cell_ids}  ${eutra_cell_id}
    END

    RETURN  ${list_lte_e_utra_cell_ids}


Get Ids For NR Cells
    [Documentation]
    ...  This keyword returns the values of nrCellIdentity parameter for each NR cell. This values
    ...  are the unique identifier for NR cells in Nokia Android Application.
    ...
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com

    ${info_nr_cells}  Get Parameters For All  NRCEL
    ${list_nr_ids}  Create List
    FOR  ${cell}  IN  @{info_nr_cells}
        ${cell_id}  Convert To String  ${cell}[nrCellIdentity]
        Append To List  ${list_nr_ids}  ${cell_id}
    END

    RETURN  ${list_nr_ids}


Check If UE Has IP Address
    [Documentation]  This keyword is used to check if UE has IP address
    [Arguments]  ${ue_alias}

    ${status}  ${ue_info}  Run Keyword And Ignore Error
    ...  Get Ue Info  ${ue_alias}  IP
    IF  '${status}'=='FAIL'  Fail  UE does not have IP address.


Start UDP Uplink
    [Documentation]  This keyword is used to start uplink
    [Arguments]  ${ue_alias}  ${duration}  ${desired_throughput}  ${min_throughput}  ${desired_cell_list}  ${nr_state}=${None}

    Log  Starting ps uplink call...  console=true
    Log  Desired uplink throughput is: ${desired_throughput}  console=true
    Log  Minimum uplink throughput is: ${min_throughput}  console=true
    Start Data Transfer  DT_UL  ${ue_alias}  direction=ul  duration=${duration}  protocol=udp  packet=1000  throughput=${desired_throughput}
    Sleep  5  Wait for call to be set on correct RAT.
    ${rat_status}  Check Data Transfer Is Made On Correct RAT  ${ue_alias}  ${desired_cell_list}  ${nr_state}
    Await Data Transfer Finish  DT_UL
    ${status}  Run Keyword And Return Status
    ...  Verify Average Throughput  DT_UL  tput_min=${min_throughput}
    IF  ${status} == ${FALSE}
      Set Test Failed  UL throughput is less than ${min_throughput}. [NOK]
    ELSE IF  ${rat_status} == ${FALSE}
      Set Test Failed  UL traffic was made on wrong technology. [NOK]
    END
    Log  PS uplink call ended.  console=true


Start UDP Downlink
    [Documentation]  This keyword is used to start downlink
    [Arguments]  ${ue_alias}  ${duration}  ${desired_throughput}  ${min_throughput}  ${desired_cell_list}  ${nr_state}=${None}

    Log  Starting ps downlink call...  console=true
    Log  Desired downlink throughput is: ${desired_throughput}  console=true
    Log  Minimum downlink throughput is: ${min_throughput}  console=true
    Start Data Transfer  DT_DL  ${ue_alias}  direction=dl  duration=${duration}  protocol=udp  packet=1000  throughput=${desired_throughput}
    Sleep  5  Wait for call to be set on correct RAT.
    ${rat_status}  Check Data Transfer Is Made On Correct RAT  ${ue_alias}  ${desired_cell_list}  ${nr_state}
    Await Data Transfer Finish  DT_DL
    ${status}  Run Keyword And Return Status
    ...  Verify Average Throughput  DT_DL  tput_min=${min_throughput}
    IF  ${status} == ${FALSE}
      Set Test Failed  DL throughput is less than ${min_throughput}. [NOK]
    ELSE IF  ${rat_status} == ${FALSE}
      Set Test Failed  DL traffic was made on wrong technology. [NOK]
    END
    Log  PS downlink call ended.  console=true


Check Data Transfer Is Made On Correct RAT
    [Arguments]    ${ue_alias}  ${desired_cell_list}  ${nr_state}

    ${ue_info}  Get UE Info  ${ue_alias}
    ${cell_status}  Check If UE Is On Correct Cell  ${desired_cell_list}  ${ue_info}[cell_id]
    IF  not ${cell_status}  Fail
    ...  UE is not attached to none of the cells from ${desired_cell_list}. UE attached to ${cell_id}.
    IF  '${nr_state}'!='${None}'
      ${rat_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${ue_info}[nr_state]  ${nr_state}
    ELSE
      ${rat_status}  Set Variable  ${TRUE}
    END
    RETURN  ${rat_status}


Check If UE Is On Correct Cell
    [Arguments]  ${desired_cell_list}  ${cell_id}

    Log  Check if UE is attached to cells from: ${desired_cell_list}  console=true
    Log  UE attached to cell ${cell_id}.  console=true
    FOR  ${cell}  IN  @{desired_cell_list}
      ${cell_status}  Run Keyword And Return Status  Should Contain  ${cell}  ${cell_id}
      IF  ${cell_status}  RETURN  ${TRUE}
    END
    RETURN  ${FALSE}


Get UE For Technology
    [Documentation]
    ...  This keyword returns UE from specific technology. The 'technology' argument
    ...  must be given as: GSM_only,LTE_only ...
    ...  *AUTHOR*: iasmin.tomici@nokia.com
    [Arguments]  ${technology}

    FOR  ${object}  IN  @{TL.ues}
        Return From Keyword If  '${technology}' in ${object.capabilities}  ${object}
    END
    Fail  No UE with ${technology} found!


Check Running Devices And Server
    [Documentation]  This keyword is used to check running devices and server
    [Arguments]  ${ue_details}

    ssh.Connect To  ${ue_details.ssh_connection_details.addr}  ${ue_details.ssh_connection_details.username}
    ...  ${ue_details.ssh_connection_details.password}
    ssh.Send Command  command=adb devices  timeout=10s
    ${adb_devices_output_from_remote}  ssh.Read Output
    @{devices_list}  Split To Lines  ${adb_devices_output_from_remote}
    FOR  ${device}  IN  @{devices_list}
        Continue For Loop If  '${ue_details.serial_number}' not in '${device}'
        ${offline_status}  Run Keyword And Return Status  Should Contain  ${device}  offline
        IF  ${offline_status}
          Fail  UE ${ue_details.serial_number} is offline. Manual reboot is needed! [NOK]
        ELSE
          Log  UE ${ue_details.serial_number} is available on PC [OK]  console=true
        END
    END
    ${port}  Get Port For Proxy Server
    ${command}  ssh.Execute  command=ss -tulnp | grep :${port}  timeout=10s
    ${listening_status}  Run Keyword And Return Status  Should Contain  ${command}  ${ue_details.ssh_connection_details.addr}:${port}
    IF  '${listening_status}' == 'False'  Start Proxy Server  ue_details=${ue_details}  port=${port}
    [Teardown]  ssh.Disconnect


Start Proxy Server
    [Documentation]  This keyword is used to start proxy server on default port 8080.
    [Arguments]  ${ue_details}  ${port}=8080  ${network_interface}=${EMPTY}

    Run  sudo iptables -I INPUT -p tcp --dport ${port} -j ACCEPT
    ssh.Send Command  command=python -m taf.ue.proxy.run_ue_proxy --port ${port} ${network_interface}
    Sleep  10  Wait for server to start.
    ssh.Connect To  ${ue_details.ssh_connection_details.addr}  ${ue_details.ssh_connection_details.username}
    ...  ${ue_details.ssh_connection_details.password}  alias=ssh_verification
    ${output}  ssh.Execute  command=ss -tulnp | grep :${port}  connection=ssh_verification  timeout=10s
    Should Not Be Empty  ${output}  Proxy server cannot be started.
    [Teardown]  ssh.Disconnect  connection=ssh_verification


Reattach UE
    [Arguments]  ${ue_alias}
    TRY
      Log  Try to reattach UE.  console=true
      Turn On/off Airplane Mode  ${ue_alias}
    EXCEPT  TimeoutError: *  RpcError: *  type=GLOB
      Log  Reattach failed. UE will be rebooted.  console=true
      Reboot UE  ${ue_alias}  300
      Attach Ue  ${ue_alias}  120
    FINALLY
      Turn Mobile Data On  ${ue_alias}
    END


Start TCP Uplink
    [Documentation]  This keyword is used to start tcp uplink
    [Arguments]  ${ue_alias}  ${duration}  ${desired_throughput}  ${min_throughput}  ${desired_cell_list}  ${nr_state}=${None}

    Log  Starting ps uplink call...  console=true
    Log  Desired uplink throughput is: ${desired_throughput}  console=true
    Log  Minimum uplink throughput is: ${min_throughput}  console=true
    Start Data Transfer  DT_UL  ${ue_alias}  direction=ul  duration=${duration}  protocol=tcp  packet=1000  throughput=${desired_throughput}
    Sleep  5  Wait for call to be set on correct RAT.
    ${rat_status}  Check Data Transfer Is Made On Correct RAT  ${ue_alias}  ${desired_cell_list}  ${nr_state}
    Await Data Transfer Finish  DT_UL
    ${status}  Run Keyword And Return Status
    ...  Verify Average Throughput  DT_UL  tput_min=${min_throughput}
    IF  ${status} == ${FALSE}
      Set Test Failed  UL throughput is less than ${min_throughput}. [NOK]
    ELSE IF  ${rat_status} == ${FALSE}
      Set Test Failed  UL traffic was made on wrong technology. [NOK]
    END
    Log  PS uplink call ended.  console=true


Start TCP Downlink
    [Documentation]  This keyword is used to start tcp downlink
    [Arguments]  ${ue_alias}  ${duration}  ${desired_throughput}  ${min_throughput}  ${desired_cell_list}  ${nr_state}=${None}

    Log  Starting ps downlink call...  console=true
    Log  Desired downlink throughput is: ${desired_throughput}  console=true
    Log  Minimum downlink throughput is: ${min_throughput}  console=true
    Start Data Transfer  DT_DL  ${ue_alias}  direction=dl  duration=${duration}  protocol=tcp  packet=1000  throughput=${desired_throughput}
    Sleep  5  Wait for call to be set on correct RAT.
    ${rat_status}  Check Data Transfer Is Made On Correct RAT  ${ue_alias}  ${desired_cell_list}  ${nr_state}
    Await Data Transfer Finish  DT_DL
    ${status}  Run Keyword And Return Status
    ...  Verify Average Throughput  DT_DL  tput_min=${min_throughput}
    IF  ${status} == ${FALSE}
      Set Test Failed  DL throughput is less than ${min_throughput}. [NOK]
    ELSE IF  ${rat_status} == ${FALSE}
      Set Test Failed  DL traffic was made on wrong technology. [NOK]
    END
    Log  PS downlink call ended.  console=true


Get Port For Proxy Server
    [Documentation]  This KW is getting proxy server port. Ssh connection to UE PC must be established first.

    ${command}  ssh.Execute  ps -aux | grep taf.ue.proxy  timeout=10s
    ${port_match}  Get Regexp Matches  ${command}  (--ueproxy_ports_range \\d+|run_ue_proxy --port \\d+)
    ${port}  Fetch From Right  ${port_match}[-1]  ${SPACE}

    RETURN  ${port}


Stop Proxy Server
    [Documentation]  run_ue_proxy process is killed.

    ${ue_details}  Get UE For Technology  LTE_only
    ssh.Connect To  ${ue_details.ssh_connection_details.addr}  ${ue_details.ssh_connection_details.username}
    ...  ${ue_details.ssh_connection_details.password}
    ${port}  Get Port For Proxy Server
    ${command}  ssh.Execute  ps -aux | grep "taf.ue.proxy.run_ue_proxy --port ${port}"  timeout=10s
    ${command}  Split String  ${command}
    ${pid}  Convert To Integer  ${command}[1]
    ${command}  ssh.Execute  kill -9 ${pid}
    Sleep  2s  Time for run_ue_proxy process to be completely killed.
    ${output}  ssh.Execute  command=ss -tulnp | grep :${port}  timeout=10s
    Should Be Empty  ${output}  Proxy server couldn't be stopped.

    [Teardown]  ssh.Disconnect