*** Settings ***
Documentation
...  general resources with common keywords

Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.config.scf  WITH NAME  scf
Library    taf.hw.pdu  WITH NAME  pdu
Library    taf.sw.ping  WITH NAME  ping
Library    ./../../../resources/ims2_parser.py
Library    ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio



*** Keywords ***

Check If Cell Is Deployed On More Than One RMOD
    [Documentation]
    ...  KW returns True of False if cell is deployed on more than one RU.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW returns True of False
    ...  | Default direction is set to RXTX.
    ...  | It means that KW returns True if cell has RX and TX deployed on more than one RU.
    ...  | Optionally direction can be changed to only RX or TX.
    ...  | Cell is mandatory parameter.
    ...  | KW uses taf.sbts.oam.coam.admin library.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | cell             | Yes  | Cell to check deployment                            |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | direction        | No   | Default RXTX, all options: TX , RX, RXTX            |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | connection       | No   | Connection name set with taf library setup          |
    ...  +------------------+------+-----------------------------------------------------+

    [Arguments]  ${cell}  ${direction}=RXTX  ${connection}=default

    ${cell_info}  admin.Get Cell Specific Info  ${cell}  connection=${connection}
    ${carriers}  Set Variable  ${cell_info['carrierList']}

    ${rx_list}  Create List
    ${tx_list}  Create List
    FOR  ${carrier}  IN  @{carriers}
        ${rmod}  Evaluate  '${carrier['antennaLineId']['runtime']}'.rsplit('/', 1)[0]
        Run Keyword If  '${carrier['direction']}'=='TX'
        ...  Append To List  ${tx_list}  ${rmod}
        ...  ELSE
        ...  Append To List  ${rx_list}  ${rmod}
    END

    ${rx_list}  Remove Duplicates  ${rx_list}
    ${tx_list}  Remove Duplicates  ${tx_list}

    ${ru_count_for_rx}  Get Length  ${rx_list}
    ${ru_count_for_tx}  Get Length  ${tx_list}

    Return From Keyword If  '${direction.lower()}'=='rx' and ${ru_count_for_rx}>1  True
    Return From Keyword If  '${direction.lower()}'=='tx' and ${ru_count_for_tx}>1  True
    Return From Keyword If  '${direction.lower()}'=='rxtx' and ${ru_count_for_rx}>1 and ${ru_count_for_rx}>1  True

    Return From Keyword  False


Get RMOD IP by Serial Number
    [Documentation]
    ...  KW returns IP of RMOD.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW returns RMOD IP
    ...  | KW uses keyword `Get RU IPs` which returns dictionary with all IPs.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | rmod_sn          | Yes  | RMOD serial number                                  |
    ...  +------------------+------+-----------------------------------------------------+

    [Arguments]  ${rmod_sn}

    ${all_ips}  radio.Get IP For All Radio Modules  print_table=False

    FOR  ${smod}  ${ips}  IN ZIP  ${all_ips.keys()}  ${all_ips.values()}
        ${nested_dict}  Get From Dictionary  ${all_ips}  ${smod}
        ${is_rmod_sn}  Run Keyword And Return Status  Dictionary Should Contain Key  ${nested_dict}  ${rmod_sn}
        Continue For Loop If  '${is_rmod_sn}'=='False'
        ${rmod_ip}  Get From Dictionary  ${nested_dict}  ${rmod_sn}
    END

    [Return]  ${rmod_ip}

Get SMOD IP For Connected RMOD
    [Documentation]
    ...  KW returns SMOD IP for the RMOD connected to it.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  KW returns SMOD IP for the RMOD connected to it
    ...  according to the RU serial number passed by argument.
    ...  Keyword Get RU IPs is used inside.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | rmod_sn          | Yes  | RMOD serial number                                  |
    ...  +------------------+------+-----------------------------------------------------+

    [Arguments]  ${rmod_sn}

    ${all_ips}  radio.Get IP For All Radio Modules  print_table=False

    FOR  ${smod}  ${ips}  IN ZIP  ${all_ips.keys()}  ${all_ips.values()}
        ${nested_dict}  Get From Dictionary  ${all_ips}  ${smod}
        ${is_rmod_sn}  Run Keyword And Return Status  Dictionary Should Contain Key  ${nested_dict}  ${rmod_sn}
        Continue For Loop If  '${is_rmod_sn}'=='False'
        Return From Keyword  ${smod}
    END

Log All Carriers Power
    [Arguments]    ${direction}    ${print_table}=${TRUE}
    [Documentation]
    ...  KW logs carriers power for all radio modules except ALU RUs.
    ...  In case of ALU, radio module is skipped in loop.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | direction        | Yes  | TX or RX carriers                                   |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | print_table      | No   | print table with carriers power                     |
    ...  +------------------+------+-----------------------------------------------------+

    ${rmod_list}    admin.Get Parameters For All    RMOD
    FOR    ${rmod}    IN    @{rmod_list}
        Continue For Loop If    '${rmod['productName']}'.startswith('U')
        Log To Console
        ...    ${direction.upper()} carriers power for RMOD: ${rmod['productName']} with SN: ${rmod['serialNumber']}:
        radio.Get Carriers Power
        ...  ru_serial_number=${rmod.serialNumber}
        ...  direction=${direction}
        ...  return_antennas=False
        ...  print_table=${print_table}
    END

Log All TX Antenna Lines Power
    [Arguments]   ${print_table}=${TRUE}
    [Documentation]
    ...  KW logs antenna lines power for all radio modules >= 5.1 via DAPD
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | print_table      | No   | print table with carriers power                     |
    ...  +------------------+------+-----------------------------------------------------+

    ${rmod_list}    admin.Get Parameters For All    RMOD
    FOR    ${rmod}    IN    @{rmod_list}
        Continue For Loop If  not '${rmod['productName']}'.startswith('A')
        Log To Console
        ...    TX antenna lines power for RMOD: ${rmod['productName']} with SN: ${rmod['serialNumber']}:
        radio.Get TX Pipes Power From DAPD
        ...  ru_serial_number=${rmod.serialNumber}
        ...  print_table=${print_table}
    END

Check If Cell Is Degraded Or Failed
    [Documentation]
    ...  KW checks if cell is degraded or failed.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  KW checks if cell is degraded or failed.
    ...  Expected state is pass by argument.
    ...  For check assertion is used.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | cell             | Yes  | Cell to check                                       |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | expected_state   | Yes  | degraded or failed                                  |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | timeout          | No   | Timeout for assertion                               |
    ...  +------------------+------+-----------------------------------------------------+

    [Arguments]  ${cell}  ${expected_state}  ${timeout}=10

    ${class_id}  Evaluate  '${cell}'.split('/')[-1].split('_')[0]
    Run Keyword If  '${class_id}'=='NRCELL'
    ...  admin.Assert  NRCEL  ${cell}  availabilityStatus=regex"(?i)${expected_state}"  timeout=${timeout}
    ...  ELSE
    ...  admin.Assert  ${class_id}  ${cell}  availabilityStatus=regex"(?i)${expected_state}"  timeout=${timeout}

Get SMOD DistName For Connected RMOD
    [Documentation]
    ...  KW returns SMOD distname for RMOD connected to it.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  KW returns SMOD distname for RMOD connected to it.
    ...  Get SFP Links keyword output must be passed by argument
    ...  because in case of link break / hot remove TCs, after RU break/remove
    ...  cablinks disapeard from output and is unavailable.
    ...  Recommend to set output from Get SFP Links as TC global variable.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | rmod_sn          | Yes  | RMOD serial number                                  |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | links            | Yes  | Output from KW "Get SFP Links"                      |
    ...  +------------------+------+-----------------------------------------------------+

    [Arguments]  ${rmod_sn}  ${links}

    ${links}  Set Variable  ${links['connected']}

    FOR  ${link}  IN  @{links}
        Continue For Loop If  '${rmod_sn}' not in '${link['parent']['source']['parameters']['serialNumber']}'
        Return From Keyword  ${link['parent']['destination']['distName']}
    END

Find BTS ID TAF
    [Documentation]
    ...    Original KW -> Admin Get BTS ID
    ...    Original resource -> hran_admin.robot
    ...    Gets BTS ID
    ...    *AUTHOR*: daniel.bartkowiak@nokia.com

    [Arguments]  ${connection}=default
    ${info}=    admin.Get BTS Info  connection=${connection}
    ${bts_id}=  Convert To String  ${info['mrbtsID']}
    [Return]  ${bts_id}

Turn Off Pdu Interface
    [Arguments]  ${if_name}
    [Documentation]
    ...  Turn off selected interface.
    ...
    ...  *AUTHOR*
    ...  daniel.bartkowiak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description  |
    ...  |  if_name     | Yes  |  Name defined in interfaces.yaml  |
    ...
    ...  *EXAMPLE*
    ...  |  Turn Off Pdu Interface  |  SMOD_1234567  |
    ...
    pdu.Setup Pdu  model=${INTERFACES['${if_name}']['TYPE']}  version=${INTERFACES['${if_name}']['PDU_VERSION']}
    ...  host=${INTERFACES['${if_name}']['IP']}  alias=${if_name}
    pdu.Power Off  port=${INTERFACES['${if_name}']['OUTLET']}  pdu_device=${if_name}

Turn On Pdu Interface
    [Arguments]  ${if_name}
    [Documentation]
    ...  Turn off selected interface.
    ...
    ...  *AUTHOR*
    ...  daniel.bartkowiak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description  |
    ...  |  if_name     | Yes  |  Name defined in interfaces.yaml  |
    ...
    ...  *EXAMPLE*
    ...  |  Turn On Pdu Interface  |  SMOD_1234567  |
    ...
    pdu.Setup Pdu  model=${INTERFACES['${if_name}']['TYPE']}  version=${INTERFACES['${if_name}']['PDU_VERSION']}
    ...  host=${INTERFACES['${if_name}']['IP']}  alias=${if_name}
    pdu.Power On  port=${INTERFACES['${if_name}']['OUTLET']}  pdu_device=${if_name}

Get Pdu Port Status TAF
    [Arguments]  ${if_name}
	[Documentation]
    ...  Turn off selected interface.
    ...
    ...  *AUTHOR*
    ...  daniel.bartkowiak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description  |
    ...  |  if_name     | Yes  |  Name defined in interfaces.yaml  |
    ...
    ...  *EXAMPLE*
    ...  |  Siso Get Pdu Port Status  |  SMOD_1234567  |
	...
	...  Return value  'on' or 'off'
	pdu.Setup Pdu
	...  model=${INTERFACES['${if_name}']['TYPE']}
	...  version=${INTERFACES['${if_name}']['PDU_VERSION']}
	...  host=${INTERFACES['${if_name}']['IP']}
	...  alias=${if_name}
	${status}=  pdu.Get Port Status
	...  port=${INTERFACES['${if_name}']['OUTLET']}
	...  pdu_device=${if_name}
	[Return]  ${status}

Siso Synchronize SMODs TAF
    [Documentation]
    ...  Synchronize two System Modules if NotCommissioned state
    ...
    ...  *AUTHOR*
    ...  daniel.bartkowiak@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Man.  | Default                      | Description                        |
    ...  | alias                 | No    | default                      | alias of taf library               |

    [Arguments]   ${alias}=default
    Log    Synchronize SMODs   level=DEBUG
    ${smods}=    admin.Get Ids For All  SMOD  connection=${alias}
    Run Keyword If    len(${smods}) == 2    Fail    Two SMODs detected. SMODs should be unsynchronized.
    ${neighbor_dn}=  admin.Get Managed Objects  NEIGHBOR_NODE_R  connection=${alias}
    ${sync_status}=    Run keyword and return status  admin.Start Sync    ${neighbor_dn[0]['distName']}    connection=${alias}
    Run keyword if    ${sync_status}    Log   Synchronization succeeded    console=${TRUE}
    ...       ELSE    Fail    Synchronization failed

SiSo Get MPLANE IP TAF
    [Documentation]
    ...     Original KW -> Admin Get MPLANE IP
    ...     Original resource -> hran_admin.robot
    ...     Get MPLANE IP
    ...     Added TAF KWs
    ...     *AUTHOR*
    ...     andrzej.cichon@nokia.com
    ...     *MAINTAINER*
    ...     daniel.bartkowiak@nokia.com

    [Arguments]  ${connection}=default
    ${bts_obj}=    admin.Get Parameters For All  BTS  connection=${connection}
    ${mplane_ip}=  Convert To String  ${bts_obj[0]['btsMplaneIp4V']}
    [Return]    ${mplane_ip}

SiSo Check mplane connection TAF
    [Documentation]
    ...  Original KW -> Admin Check mplane connection
    ...  Original resource -> hran_admin.robot
    ...  Check mplane connection on admin
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com
    ...  | **Released with version:** 45.0
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+------------------+------------------------------------------------------------------+
    ...  | Parameter name | Man. | Default          | Description                                                      |
    ...  +================+======+==================+==================================================================+
    ...  | bts_host       | no   | ${MPLANE_IP}     | BTS ip to connect, in default MPLANE_IP from node configuration  |
    ...  +----------------+------+------------------+------------------------------------------------------------------+
    ...  | bts_port       | no   | 443              | BTS port to connect                                              |
    ...  +----------------+------+------------------+------------------------------------------------------------------+
    ...  | use_ssl        | no   | TRUE             | SSL flag                                                         |
    ...  +----------------+------+------------------+------------------------------------------------------------------+
    ...  | timeout        | no   | 1 min            | Timeout for connection to admin                                  |
    ...  +----------------+------+------------------+------------------------------------------------------------------+
    ...  | alias          | no   | mplane           | Connection alias                                                 |
    ...  +----------------+------+------------------+------------------------------------------------------------------+
    ...
    [Arguments]  ${bts_host}  ${bts_port}=443  ${use_ssl}=TRUE  ${timeout}=1 min  ${connection}=mplane
    Log  Check mplane connection on Admin  console=${TRUE}
    Log  Trying to connect to admin (max ${timeout})   level=INFO  console=${TRUE}
    ${admin_started}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout}  15 sec
    ...  admin.Setup Admin  admin_api_log_dir=${BTS Files}  bts_host=${bts_host}  bts_port=${bts_port}
    ...  use_ssl=${use_ssl}  name=${connection}
    Return From Keyword If  '${admin_started}'=='False'  ${False}
    Log  Connection to admin with mplane (${bts_host}) successfully established!  level=INFO  console=${TRUE}
    ${BTS_statecheck_status}  ${BTS_state}  Run keyword and ignore error  admin.Get Mrbts State  connection=${connection}
    Return from keyword if  '${BTS_statecheck_status}'=='PASS'  ${True}
    [Return]  ${False}
    [Teardown]  admin.Teardown Admin  connection=${connection}

Siso Execute command on SM via SSH TAF
    [Documentation]
    ...  Original KW -> Execute command on SM via SSH
    ...  Original resource -> hran_general.robot
    ...  Keyword opens connection to smod via SSH. Executes the given command. Command
    ...  can be executed from remote host. Possible accessing remote host from
    ...  third host by giving ${proxy} parameter.
    ...  For more details in case of proxy please refer to
    ...  taf.transport.ssh library
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...  *MAINTAINER* daniel.bartkowiak@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                                |
    ...  | smod ip              | Yes  | IP address of smod on which command should be executed     |
    ...  | command              | Yes  | Command to execute                                         |
    ...  | remote_host          | No   | Remote host IP address (${EMPTY} as default)               |
    ...  | remote_host_username | No   | Remote host username (${EMPTY} as default)                 |
    ...  | remote_host_password | No   | Remote host password (${EMPTY} as default)                 |
    ...  | remote_key_path      | No   | Remote key path (None as default)                      |
    ...  | remote_alias         | No   | Remote alias (None as default)                         |
    ...  | remote_port          | No   | Remote port (None} as default)                          |
    ...  | proxy                | No   | proxy (None as default)                                |
    ...  | remote_timeout       | No   | Remote timeout (30s as default)                            |
    ...
    ...  *RETURN*
    ...  | Parameters | Description    |
    ...  | output     | Command output |
    ...
    ...  *EXAMPLE*
    ...  | Siso Execute command on SM via SSH TAF| 192.168.255.1 | rm -rf /flash/config/PersDataFiles/SCFC_* |
    ...
    ...  | ${output}= | Siso Execute command on SM via SSH TAF | 192.168.255.5 | ls -la / | 10.42.35.166 | ute | ute | vm_ssh | third_ssh_tunel |

    [Arguments]  ${smod_ip}  ${command}  ${remote_host}=${EMPTY}  ${remote_host_username}=${EMPTY}  ${remote_host_password}=${EMPTY}
    ...          ${remote_alias}=None  ${proxy}=None  ${remote_key_path}=None  ${remote_port}=None  ${remote_timeout}=30
    Run Keyword If  '${remote_host}'!='${EMPTY}'  ssh.connect to  hostname=${remote_host}  username=${remote_host_username}
    ...  password=${remote_host_password}  key_path=${remote_key_path}  port=${remote_port}  proxy=${proxy}
    ...  alias=${remote_alias}  timeout=${remote_timeout}
    ssh.connect to    ${smod_ip}  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}  alias=sm_ssh  proxy=${remote_alias}  timeout=30
    ${command_return}=  ssh.execute  ${command}  connection=sm_ssh
    [Return]  ${command_return}
    [Teardown]  _Siso Disconnect SSH connections TAF  sm_ssh  ${remote_alias}  ${proxy}

_Siso Disconnect SSH connections TAF
    [Documentation]
    ...  (New KW) Helper KW for disconnecting connections started by
    ...  KW "Siso Execute command on SM via SSH TAF"
    ...  *AUTHOR* daniel.bartkowiak@nokia.com
    [Arguments]  ${alias_1}  ${alias_2}  ${alias_3}
    ssh.disconnect  connection=${alias_1}
    Run Keyword If  '${alias_2}'!='None'  ssh.disconnect  connection=${alias_2}
    Run Keyword If  '${alias_3}'!='None'  ssh.disconnect  connection=${alias_3}

Siso Admin Get Modules For Interfaces TAF
    [Documentation]
    ...  Original KW -> Admin Get Modules For Interfaces TAF
    ...  Original resource -> hran_admin.robot
    ...  Return list of modules types and serial numbers
    ...
    ...  *AUTHOR*
    ...  michal.kwasniewicz@nokia.com
    ...  *MAINTAINER*
    ...  daniel.bartkowiak@nokia.com
	[Arguments]  ${connection}=default

    ${smod_param}=    admin.Get Parameters For All    SMOD    connection=${connection}
    ${rmod_param}=    admin.Get Parameters For All    RMOD    connection=${connection}

    @{serial_number_list}=    Create List

    FOR  ${mod}  IN  @{smod_param}
        Append To List  ${serial_number_list}  SMOD_${mod.serialNumber}
    END
    FOR  ${mod}  IN  @{rmod_param}
        Append To List  ${serial_number_list}  RMOD_${mod.serialNumber}
    END
    [Return]  ${serial_number_list}

Siso Admin Check Cells Number TAF
    [Documentation]
    ...  Original KW -> Admin Check Cells Number
    ...  Original resource -> hran_admin.robot
    ...  Check if number cells detected by admin is as expected
    ...  *AUTHOR*
    ...  michal.kwasniewicz@nokia.com
    ...  *MAINTAINER*
    ...  daniel.bartkowiak@nokia.com
    ...
    ...  | Parameter              | Mandatory     | Description                           |
    ...  | technology             | Yes           | Cell ID e.g: LNCEL, GNCEL or WNCEL    |
    ...  | expectted_cells_number | Yes           | Expected cells number                 |

    [Arguments]    ${technology}    ${expected_cells_number}  ${connection}=default
    Run keyword if  ${expected_cells_number}==-1  Run keywords
    ...  Log  ${technology} will be ignored for active software  console=${True}
    ...  AND  Return from keyword  ${True}
    ${id_list}=    admin.Get Ids For All    ${technology}  search_for_iot_cells=${True}  connection=${connection}
    ${admin_cells_num}=    Evaluate    len(${id_list})
    Should Be Equal As Integers    ${expected_cells_number}    ${admin_cells_num}
    ...    Admin see different cells number than expected! Expected: ${expected_cells_number} is not equal admin cells num: ${admin_cells_num}.

Siso Install IPSec certificates TAF
    [Documentation]
    ...    Original KW -> Install IPSec certificates
    ...    Original resource -> hran_general.robot
    ...    Added TAF KWs
    ...    KW for IPSec certificates installation. In default certificates should be stored under
    ...    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/certificates
    ...    For now only .p12 and .pem files extensions are supported
    ...
    ...    *AUTHOR*
    ...    patryk.furman@nokia.com
    ...    *MAINTAINER*
    ...    daniel.bartkowiak@nokia.com
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | cert_path | No        | BTS IP      |

    [Arguments]  ${cert_path}=/home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/certificates  ${connection}=default
    Log  Install IPSec certificates from ${cert_path}     console=${TRUE}
    @{p12_files}=  OperatingSystem.List files in directory  ${cert_path}  pattern=*.p12  absolute=${TRUE}
    FOR  ${p12_cert}  IN  @{p12_files}
        admin.Install certificate  ${p12_cert}  BtsTrustChain  P12  Cwirhau  connection=${connection}
        Log  Certificate ${p12_cert} installed  console=${TRUE}
    END
    @{pem_files}=  OperatingSystem.List files in directory  ${cert_path}  pattern=*.pem  absolute=${TRUE}
    FOR  ${pem_cert}  IN  @{pem_files}
        admin.Install certificate  ${pem_cert}  AdditionalCa  PEM  Cwirhau  connection=${connection}
        Log  Certificate ${pem_cert} installed  console=${TRUE}
    END

SiSo check if DSPs were restarted according to ims file TAF
    [Documentation]
    ...  Original KW -> Infomodel check if DSPs were restarted according to ims file
    ...  Original resource -> hran_infomodel.robot
    ...  KW checks given ims2 file (first argument) looking for DSPs restart event. All DSPs from given list (second
    ...  argument) are checked. User can use 'Siso Infomodel get all DSPs dist names for given RAT'
    ...  to get DSPs list. If numer of resets is not equal ${times} KW fails.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...  *MAINTAINER*
    ...  daniel.bartkowiak@nokia.com
    ...
    ...  | Parameter      | Man. | Description                             |
    ...  | im_log_path    | Yes  | Path for Infomodel ims2 file            |
    ...  | dsp_dist_names | Yes  | List of DSPs dist names fetched from IM |
    ...  | times          | No   | Number of resets required               |

    [Arguments]  ${im_log_path}  ${dsp_dist_names}  ${times}=1
    FOR  ${dsp_dist_name}  IN  @{dsp_dist_names}
        Run Keyword And Ignore Error  Find Parameter Change  ${im_log_path}  ${dsp_dist_name}  proceduralState  Regex"(?i)Resetting"  ${times}
        Log  ${dsp_dist_name} was restarted  console=${TRUE}
    END

Get Cells From Selected RATs
    [Documentation]
    ...  Author: Daniel.Bartkowiak@nokia.com
    ...  KW can be used to prepare list of cells from desired RATs.
    ...  ${rat_sign} excludes RAT cells from list.
    ...  ${rat_sign} can get LN WN GN NR letters separated by space.
    ...  By default KW creates list of all cells
    [Arguments]    ${rat_signs}=${EMPTY}  ${connection}=default
    ${impacted_cells}=  Create List
    ${not_impacted_cells}=  Create List
    ${classes}=  Create List  LNCEL  WNCEL  GNCEL  NRCEL
    ${rat_signs}=  Split String  ${rat_signs}
    FOR  ${rat}  IN  @{rat_signs}
        Remove Values From List  ${classes}  ${rat}CEL
        ${rat_cells}=  admin.Get Ids For All  ${rat}CEL  search_for_iot_cells=${True}  connection=${connection}
        ${impacted_cells}=  Combine Lists  ${impacted_cells}  ${rat_cells}
    END
    FOR  ${class}  IN  @{classes}
        ${rat_cells}=  admin.Get Ids For All  ${class}  search_for_iot_cells=${True}  connection=${connection}
        ${not_impacted_cells}=  Combine Lists  ${not_impacted_cells}  ${rat_cells}
    END
    [Return]  ${impacted_cells}  ${not_impacted_cells}

SiSo get all DSPs dist names for given RAT TAF
    [Documentation]
    ...  Original KW -> Infomodel get all DSPs dist names for given RAT
    ...  Original resource -> hran_infomodel.robot
    ...  KW for obtaining sorted list of DSPs distNames from IM
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...  *MAINTAINER*
    ...  daniel.bartkowiak@nokia.com

    [Arguments]  ${rat}  ${connection}=default
    ${dsps_dist_names}=  Create list
    ${sw_entities_objects}=  admin.Get Managed Objects  SOFTWARE_ENTITY  connection=${connection}
    FOR  ${sw_entity}  IN  @{sw_entities_objects}
        Run Keyword If  '${sw_entity['parameters']['rat']}'=='${rat}'
        ...  Append to list  ${dsps_dist_names}  ${sw_entity['parameters']['deviceDN']}
    END
    ${dsps}=  Remove Duplicates  ${dsps_dist_names}
    Sort list  ${dsps}
    [Return]  ${dsps}

Check 5G NSA Mode
    [Documentation]
    ...  KW checks if gnb works in NSA mode
    ...  KW returns 1 if NSA and 0 if not NSA
    ...  ..  *AUTHOR*
    ...  Daniel.Bartkowiak@nokia.com
    [Arguments]  ${connection}=default
    admin.Get Current SCF File  ${Test Files}  LTE_RAT_Reset_scf.xml  connection=${connection}
    scf.Load Scf  file_path=${Test Files}/LTE_RAT_Reset_scf.xml
    ${5g_mode}=  scf.Get All Values From Scf By Pattern  dist_name=.*NRBTS-\\d+  p_name=gNbCuType
    ${num}=  Count Values In List  ${5g_mode}  NSA
    [Return]  ${num}

SiSo Get Parameter Value From SCF
    [Arguments]  ${param_name}  ${scf_path}
    [Documentation]
    ...  KW finds and returns desired parameter values as a list in scf
    ...  KW needs parameter name and scf path as an input
    ...  ..  *AUTHOR*
    ...  Daniel.Bartkowiak@nokia.com
    scf.Load Scf  file_path=${scf_path}
    ${values}=  scf.Get All Values From Scf By Pattern  p_name=${param_name}
	[Return]  ${values}

Siso Start Win Process Via Cygwin
    [Arguments]  ${hostname}  ${username}  ${start_cmd}  ${password}=Ut3pa5s#1be1
    [Documentation]
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...
    ...  | **Full description:**
    ...  | Cygwin client need to be installed on remote Win PC otherwise test fail
    ...  | KW simply logs onto remote machine, and starts Win process
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | hostname         | Yes  | hostname IP                                         |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | username         | Yes  | username for login purposes                         |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | start_cmd        | Yes  | command that is executed via Cygwin                 |
    ...  +------------------+------+-----------------------------------------------------+
    ...  | password         | No   | password for remote host                            |
    ...  +------------------+------+-----------------------------------------------------+

    ssh.Connect To  hostname=${hostname}  username=${username}  password=${password}
    ssh.Send Command  command=${start_cmd}
    ${left}  ${right}=  Split String From Right  ${start_cmd}  /  1
    FOR  ${i}  IN RANGE  5
      ${output}=  ssh.Execute  command=ps -W
      ${match}=  Get Regexp Matches  ${output}  ${right}
      ${num}=  Get Length  ${match}
      Exit For Loop If  ${num}
    END
    Run Keyword If  ${num}  Log  Process ${start_cmd} running on uepc. Test can proceed.  console=${True}
    ...  ELSE  Fail  Fail! Process ${start_cmd} not running on uepc. Please check manually.

Siso Stop Win Process Via Cygwin
    [Arguments]  ${stop_cmd}
    [Documentation]
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...
    ...  | **Full description:**
    ...  | Cygwin client need to be installed on remote Win PC otherwise test fail
    ...  | KW simply executes stop command and disconnets session to win PC
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+-----------------------------------------------------+
    ...  | Parameter        | Man. | Description                                         |
    ...  +==================+======+=====================================================+
    ...  | stop_cmd         | Yes  | command that is executed via Cygwin                 |
    ...  +------------------+------+-----------------------------------------------------+
    ssh.Execute  command=${stop_cmd}
    ssh.Execute  command=ps -W
    [Teardown]  ssh.Disconnect  connection=default

Siso Check Unexpected Alarms
    [Documentation]
    ...  Check if unexpected alarms are visible.
    ...  Allowed alarms are defined inside KW (61524  61649  4654  4655  61652  4681  4592)
    ...  KW fails if any unexpected alarm found
    ...
    ...  **Author:** daniel.bartkowiak@nokia.com
    ...
    ...  +------------------+------+-----------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                               |
    ...  +==================+======+===========================================================+
    ...  | skip_fault       | No   | Additional allowed faults can by set with comma separator |
    ...  +------------------+------+-----------------------------------------------------------+
    ...  | connection       | No   | connection name                                           |
    ...  +------------------+------+-----------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...  Check If Unexpected Alarms Are Raised  skip_fault=1900,4290
    ...
    ...
    [Arguments]  ${skip_fault}=${EMPTY}  ${connection}=default
    admin.Clear Allowed Alarms List  connection=${connection}
    @{allowed_faults}=  Create List  61524  61649  4654  4655  61652  4681  4592  4590
    ${skip_faults}=  Split String  ${skip_fault}  separator=,
    ${skip_faults_additional}=  Split String  ${ADDITIONAL_IGNORED_ALARMS}  separator=,
    @{ignore_faults}=  Run Keyword If  '${skip_fault}'!='${EMPTY}'  Combine Lists  ${allowed_faults}  ${skip_faults}
    ...  ELSE IF  '${skip_fault}'=='${EMPTY}'  Set Variable  ${allowed_faults}
    @{ignore_faults}=  Run Keyword If  '${ADDITIONAL_IGNORED_ALARMS}'!='${EMPTY}'  Combine Lists  ${ignore_faults}  ${skip_faults_additional}
    ...  ELSE IF  '${ADDITIONAL_IGNORED_ALARMS}'=='${EMPTY}'  Set Variable  ${ignore_faults}
    ${ignore_faults}=  Remove Duplicates  ${ignore_faults}
    FOR  ${fault}  IN  @{ignore_faults}
      admin.Add Allowed Alarm  faultId=${fault}  connection=${connection}
    END
    ${fault_mapping}=  Siso Get Sorted Alarms  connection=${connection}
    ${unexpected_faults}=  Create List
    FOR  ${faultid}  IN  @{fault_mapping}
      ${fault}=  Convert To String  ${faultid}[faultId]
      ${verdict}  Run Keyword And Return Status  List Should Contain Value  ${ignore_faults}  ${fault}
      Run Keyword If  not ${verdict}  Append To List  ${unexpected_faults}  faultId:${faultid['faultId']} faultName:${faultid['faultName']}
    END
    ${status}  ${output}=  Run Keyword And Ignore Error  admin.Assert No Unexpected Active Alarms  connection=${connection}
    Run Keyword If  '${status}'=='PASS'
    ...  Log  There is no visible unexpected alarms  console=${true}
    ...  ELSE
    ...  Fail  Unexpected alarm(s) raised: ${unexpected_faults}
    admin.Clear Allowed Alarms List  connection=${connection}

Siso Get Sorted Alarms
    [Documentation]
    ...  Keyword returns list of active faultId, faultName and severity of fault reported on BTS.
    [Arguments]  ${connection}=default
    ${alarm_parameters}=  admin.Get Active Alarms  connection=${connection}
    ${fault_mapping}  Create List
    FOR  ${alarm}  IN  @{alarm_parameters}
        ${fault_info}=  Create Dictionary  faultId=${alarm['faultId']}  faultName=${alarm['faultName']}  severity=${alarm['severity']}
        Append To List  ${fault_mapping}  ${fault_info}
    END
    [Return]  ${fault_mapping}

Siso Admin Check SBTS states and alarms
    [Documentation]
    ...    Wrapper for methods used for system modules, radio modules, cells and alarms checking.
    ...
    ...    | **Author:** daniel.bartkowiak@nokia.com
	...
	...    | **Full description:**
	...    | Verification is done via ADMIN interface. Additionally modules SNs and amount of cells and HW is compared
	...    | with SCF. User can pass alarm patterns which should be treat as ignored. For patterns
	...    | documentation, please refer to Siso Check Unexpected Alarms KW
	...
	...    **Input Parameters:**
	...
	...    +--------------------+------+------------+----------------------------------------------------------------------------+
    ...    | Parameter name     | Man. | Default    | Description                                                                |
    ...    +====================+======+============+============================================================================+
    ...    | ignored_patterns   | No   | @{EMPTY}   | Number of faultId should be provided separated by comma ex. 1900,49        |
    ...    +--------------------+------+------------+----------------------------------------------------------------------------+
    ...
    ...    **Example of simple usage:**
    ...
    ...    .. code-block:: robotframework
    ...
    ...    Siso Admin Check SBTS states and alarms  ignored_patterns=1900,49

    [Arguments]  ${ignored_patterns}=${EMPTY}
    ${system_mods_working}=  Verify system modules states
    ${bb_mods_working}=  Verify bb modules states
    ${radio_mods_working}=  Verify radio modules states
    ${cells_GSM_onair}=  Verify GSM cells states
    ${cells_WCDMA_onair}=  Verify WCDMA cells states
    ${cells_LTE_onair}=  Verify LTE cells states
	${cells_NR_onair}=  Verify NR cells states
	${alarms_status}  ${alarms_msg}=  Run Keyword And Ignore Error  Siso Check Unexpected Alarms  skip_fault=${ignored_patterns}
    ${all_cells_status}=  Evaluate  ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair} and ${cells_NR_onair}
    [Teardown]  Run Keyword If
    ...  not (${system_mods_working} and ${radio_mods_working} and ${all_cells_status} and '${alarms_status}'!='FAIL' and ${bb_mods_working})
    ...  Fail  At least one module or cell indicates a faulty state or unexpected alarms detected!

Siso Reset configuration by config removal from BTS
    [Documentation]
	...  Original KW -> Reset configuration by config removal from BTS
    ...  Original resource -> hran_general.robot
    ...  Removes content of /ffs/run/config/ directory content on BTS and performes reset
    ...  KW supports single and dualcore BTSes
    ...    *MAINTAINER* daniel.bartkowiak@nokia.com

    ${ip_for_ping}=  Create List   192.168.255.129
    Log  MSM configuration reset will be done by removal /ffs/run/config directory content  console=${TRUE}
    Run keyword and ignore error  Siso Execute command on SM via SSH TAF  ${SMOD1["IP"]}  rm -rf /ffs/run/config/*; reboot
    Run Keyword If  ${SMOD2_exists}  Run Keywords
    ...  Log  ESM configuration reset will be done by removal /ffs/run/config directory content  console=${TRUE}
    ...  AND
    ...  Run keyword and ignore error  Siso Execute command on SM via SSH TAF  ${SMOD2["IP"]}  rm -rf /ffs/run/config/*; reboot
    ...  ${PC_IP2}  ute  ute  esm
    ping.Wait For Ping  ${ip_for_ping}  timeout=120
    Log  MSM is pingable  console=${TRUE}
    Run Keyword If  ${SMOD2_exists}  Run Keywords
    ...  ping.Wait For Ping  ${ip_for_ping}  timeout=120  remote_host_ip=${PC_IP2}  remote_host_username=ute  remote_host_password=ute
    ...  AND
    ...  Log  ESM is pingable  console=${TRUE}

Siso Get Hosted IOT Cell
    [Documentation]
    ...  Check if provided LTE cell hosts inband.
    ...  There have to be loaded scf before KW usage by executing:
    ...  scf.Load Scf  file_path=<scf_path> from taf.config.scf library
    ...
    ...  **Author:** daniel.bartkowiak@nokia.com
    ...
    ...  +------------------+------+----------------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                                |
    ...  +==================+======+============================================================================+
    ...  | cell_dn          | Yes  | ex. /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-18246/LNCEL_R-10774    |
    ...  +------------------+------+----------------------------------------------------------------------------+
    ...  | connection       | No   | connection name                                                            |
    ...  +------------------+------+----------------------------------------------------------------------------+
    ...
    ...  KW returns 'EMPTY' value if IoT is not hosted else runtime object of IoT cell
    ...
    ...  **Example of simple usage:**
    ...  {iot}  Siso Get Hosted IOT Cell  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-18246/LNCEL_R-10774


    [Arguments]  ${cell_dn}  ${connection}=default
    ${cell_inf}=  admin.Get Cell Specific Info  ${cell_dn}  connection=${connection}
    Run Keyword If  '${cell_inf['narrowbandIotMode']}'=='disabled'  Return From Keyword  ${EMPTY}
    ${linked_iot_lcrid}=  scf.Get All Values From Scf By Pattern  p_name=nbIotLinkedCellId  dist_name=${cell_inf['id']['configuration']}
    ${bts_cells}=  admin.Get Cell List  connection=${connection}
    FOR  ${lte_cell}  IN  @{bts_cells['cells']['lte']}
        ${lcrId}=  scf.Get All Values From Scf By Pattern  p_name=lcrId  dist_name=${lte_cell['id']['configuration']}
        Exit For Loop If  '${linked_iot_lcrid[0]}'=='${lcrId[0]}'
    END
    [Return]  ${lte_cell['id']['internal']}

Get LTE Cells Config Runtime Distname
    [Documentation]
    ...  KW Gets all cells LTE and sort their runtime and config distNames
    ...  into two groups: LTE wideband and IoT
    ...  KW returns 4 lists: 2 lists with IoT runtime/config distNames
    ...  and 2 lists with LTE Wideband runtime/config distNames
    ...
    ...  **Author:** daniel.bartkowiak@nokia.com
    ...
    [Arguments]  ${connection}=default
    ${not_iot_conf_dn}=  Create List
    ${iot_conf_dn}=   Create List
    ${not_iot_runtime_dn}=  Create List
    ${iot_runtime_dn}=   Create List
    ${cells}=  admin.Get Cell List  connection=${connection}
    FOR  ${cell}  IN  @{cells['cells']['lte']}
        Run Keyword If  '${cell['technology']}'!='NB-IoT-FDD' or '${cell['narrowbandIotMode']}'=='standalone'
        ...  Run Keywords
        ...  Append To List  ${not_iot_conf_dn}  ${cell['id']['configuration']}
        ...  AND
        ...  Append To List  ${not_iot_runtime_dn}  ${cell['id']['internal']}
        ...  ELSE
        ...  Run Keywords
        ...  Append To List  ${iot_conf_dn}  ${cell['id']['configuration']}
        ...  AND
        ...  Append To List  ${iot_runtime_dn}  ${cell['id']['internal']}
    END
    [Return]  ${not_iot_conf_dn}  ${iot_conf_dn}  ${not_iot_runtime_dn}  ${iot_runtime_dn}
