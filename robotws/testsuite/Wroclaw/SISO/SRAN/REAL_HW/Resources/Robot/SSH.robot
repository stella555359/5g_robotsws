*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Library  taf.transport.ssh  WITH NAME  tafssh
Library  Collections


*** Keywords ***
SSH Get File From System Module
  [Arguments]  ${source_path}  ${destination_path}  ${via_ip}=${None}  ${via_username}=ute  ${via_password}=ute  ${target_ip}=192.168.255.1
  ...  ${alias}=via_conn  ${port}=${None}  ${proxy}=${None}  ${timeout}=30

  [Documentation]
  ...  Description:
  ...  KW downloads file from system module
  ...
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | Argument        | Man. | Description                                                                                       |
  ...  +==================+======+===================================================================================================+
  ...  | source_path      | Yes  | path to file on system module e.g /ffs/run/swconfig.txt                                          |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | destination_path | Yes  | path where file should be downloaded  e.g. /home/ute/swconfig3/swconfig.txt                       |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | via_ip           | No   | IP address for the remote host, mandatory if remote host takes part in the connection             |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | via_username     | No   | username for the remote host, mandatory if remote host takes part in the connection               |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | via_password     | No   | password for the remote host, mandatory if remote host takes part in the connection               |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | target_ip        | No   | system module IP (for connection via mplane, mplane IP)                                           |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | alias            | No   | alias that the new connection object will be identified by                                        |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | port             | No   | a port on which the connection to the server will be established                                  |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | proxy            | No   | an alias representing an already established connection that the new one should be routed through |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | timeout          | No   | timeout in seconds for the TCP connect (30.0 by default)                                          |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com
  ${via_ip_status}=  Run Keyword And Return Status  Should Not Be Empty  ${via_ip}
  Run Keyword If  ${via_ip_status}  Run Keywords
  ...  tafssh.Connect To
  ...  hostname=${via_ip}
  ...  username=${via_username}
  ...  port=${port}
  ...  proxy=${proxy}
  ...  alias=${alias}
  ...  timeout=${timeout}
  ...  AND  tafssh.Connect To
  ...  hostname=${target_ip}
  ...  username=toor4nsn
  ...  password=oZPS0POrRieRtu
  ...  alias=sm_ssh
  ...  proxy=${alias}
  ...  timeout=${timeout}
  ...  ELSE  tafssh.Connect To
  ...  hostname=${target_ip}
  ...  username=toor4nsn
  ...  password=oZPS0POrRieRtu
  ...  alias=sm_ssh
  ...  timeout=${timeout}
  tafssh.Download File
  ...  remote_path=${source_path}
  ...  local_path=${destination_path}
  ...  connection=sm_ssh
  Set Variable    ${via_password}  ${via_password}
  [Teardown]  Run Keyword And Continue On Failure  Run Keywords  tafssh.Disconnect  connection=sm_ssh  AND  Run Keyword If  ${via_ip_status}
  ...  tafssh.Disconnect  connection=${alias}

SSH Upload File On System Module
  [Arguments]  ${source_path}  ${destination_path}  ${via_ip}=${None}  ${via_username}=ute  ${via_password}=ute  ${target_ip}=192.168.255.1
  ...  ${alias}=via_conn  ${port}=${None}  ${proxy}=${None}  ${timeout}=30

  [Documentation]
  ...  Description:
  ...  KW uploads file on system module
  ...
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | Argument        | Man. | Description                                                                                        |
  ...  +==================+======+===================================================================================================+
  ...  | source_path      | Yes  |  path to file, which will be uploaded on system module e.g. /home/ute/swconfig3/swconfig.txt      |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | destination_path | Yes  | path on system module, where file should be uploaded e.g /ffs/run/swconfig.txt                    |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | via_ip           | No   | IP address for the remote host, mandatory if remote host takes part in the connection             |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | via_username     | No   | username for the remote host, mandatory if remote host takes part in the connection               |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | via_password     | No   | password for the remote host, mandatory if remote host takes part in the connection               |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | target_ip        | No   |  system module IP (for connection via mplane, mplane IP)                                          |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | alias            | No   |  alias that the new connection object will be identified by                                       |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | port             | No   |  a port on which the connection to the server will be established                                 |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | proxy            | No   |  an alias representing an already established connection that the new one should be routed through|
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | timeout          | No   |  timeout in seconds for the TCP connect (30.0 by default)                                         |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  ${via_ip_status}=  Run Keyword And Return Status  Should Not Be Empty  ${via_ip}
  Run Keyword If  ${via_ip_status}  Run Keywords
  ...  tafssh.Connect To
  ...  hostname=${via_ip}
  ...  username=${via_username}
  ...  port=${port}
  ...  proxy=${proxy}
  ...  alias=${alias}
  ...  timeout=${timeout}
  ...  AND  tafssh.Connect To
  ...  hostname=${target_ip}
  ...  username=toor4nsn
  ...  password=oZPS0POrRieRtu
  ...  alias=sm_ssh
  ...  proxy=${alias}
  ...  timeout=${timeout}
  ...  ELSE  tafssh.Connect To
  ...  hostname=${target_ip}
  ...  username=toor4nsn
  ...  password=oZPS0POrRieRtu
  ...  alias=sm_ssh
  ...  timeout=${timeout}
  tafssh.Upload File
  ...  local_path=${source_path}
  ...  remote_path=${destination_path}
  ...  connection=sm_ssh
  Set Variable    ${via_password}  ${via_password}
  [Teardown]  Run Keyword And Continue On Failure  Run Keywords  tafssh.Disconnect  connection=sm_ssh  AND  Run Keyword If  ${via_ip_status}
  ...  tafssh.Disconnect  connection=${alias}

SSH Get Bts timestamp
  [Arguments]  ${bts_id}
  [Documentation]  KW logs to specified node using ssh session and returns current timestamp for further usage
  ...  Author: anna.maciejewska@nokia.com
  ...  Maintainer: anna.maciejewska@nokia.com

  ${bts_inf}=  admin.Get Parameters For All  BTS  connection=${bts_id}
  tafssh.Connect To  hostname=${bts_inf[0]['btsMplaneIp4V']}  username=toor4nsn  password=oZPS0POrRieRtu  alias=mplane_${bts_id}
  ${bts_timestamp}=  tafssh.Execute  command=date +%Y%m%d%H%M%S  connection=mplane_${bts_id}
  tafssh.Disconnect  connection=mplane_${bts_id}
  ${bts_timestamp}=  Strip String  ${bts_timestamp}
  [Return]  ${bts_timestamp}

SSH Get File From Radio Module
  [Arguments]  ${rmod_sn}  ${file_path}  ${destination_directory}  ${remote_host}=None
  [Documentation]
  ...  Description:
  ...  KW downloads file from radio module
  ...
  ...  +------------------------+------+---------------------------------------------------------------------------------------+
  ...  | Argument               | Man. | Description                                                                           |
  ...  +========================+======+=======================================================================================+
  ...  | rmod_sn                | Yes  | Serial number of the radio module                                                     |
  ...  +------------------------+------+---------------------------------------------------------------------------------------+
  ...  | file_path              | Yes  | Path to the file on the radio module that needs to be downloaded                      |
  ...  |                        |      | e.g. /mnt/runtime/BBOX5                                                               |
  ...  +------------------------+------+---------------------------------------------------------------------------------------+
  ...  | destination_directory  | Yes  | Directory on the local system where the file should be saved                          |
  ...  |                        |      | e.g. /home/ute/PIMC_LOGS/Test Files                                                   |
  ...  +------------------------+------+---------------------------------------------------------------------------------------+
  ...  | remote_host            | No   | IP address for the remote host, mandatory if remote host takes part in the connection |
  ...  +------------------------+------+---------------------------------------------------------------------------------------+
  ...
  ...  Author: mateusz.kawka@nokia.com
  ...  Maintainer: mateusz.kawka@nokia.com

  radio.Send File Via SCP
  ...  ru_serial_number=${rmod_sn}
  ...  direction=to_smod
  ...  file_path=${file_path}
  ...  destination_directory=/ram
  ...  remote_host=${remote_host}

  ${file_name}=  Evaluate  '${file_path}'.split('/')[-1]
  ${smod}=  SSH Get SMOD IP For Connected RMOD  ${rmod_sn}  remote_host=${remote_host}
  IF  '${smod}'=='192.168.255.1'
    IF  '${remote_host}'!='None'
      tafssh.Connect To  ${remote_host}  ute  ute  alias=vm
      tafssh.Connect To  ${smod}  toor4nsn  oZPS0POrRieRtu  proxy=vm  alias=primary
    ELSE
      tafssh.Connect To  ${smod}  toor4nsn  oZPS0POrRieRtu  alias=primary
    END
    tafssh.Download File  /ram/${file_name}  ${destination_directory}/${file_name}  connection=primary
  ELSE
    IF  '${remote_host}'!='None'
      tafssh.Connect To  ${remote_host}  ute  ute  alias=vm
      tafssh.Connect To  ${smod}  toor4nsn  oZPS0POrRieRtu  proxy=vm  alias=primary
    ELSE
      tafssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu  alias=primary
    END
    tafssh.send_command  command=hostname  connection=primary
    ${primary_hostname}  tafssh.read_output  connection=primary
    ${primary_hostname}  Replace String  ${primary_hostname}  \n  ${EMPTY}
    ${secondary_hostname}  Set Variable If  "${primary_hostname}"=="fct-4a"  fct-0a  fct-4a
    tafssh.Connect To  ${secondary_hostname}  toor4nsn  oZPS0POrRieRtu  proxy=primary  alias=secondary
    tafssh.Download File  /ram/${file_name}  ${destination_directory}/${file_name}  connection=secondary
  END

SSH Get SMOD IP For Connected RMOD
  [Documentation]
  ...  KW returns SMOD IP for the RMOD connected to it.
  ...
  ...  | **Author:** mateusz.kawka@nokia.com
  ...
  ...  | **Full description:**
  ...  KW returns SMOD IP for the RMOD connected to it
  ...  according to the RU serial number passed by argument.
  ...  Keyword `Get IP For All Radio Modules` is used inside.
  ...
  ...  **Input Parameters:**
  ...
  ...  +------------------+------+---------------------------------------------------------------------------------------+
  ...  | Parameter        | Man. | Description                                                                           |
  ...  +==================+======+=======================================================================================+
  ...  | rmod_sn          | Yes  | RMOD serial number                                                                    |
  ...  +------------------+------+---------------------------------------------------------------------------------------+
  ...  | remote_host      | No   | IP address for the remote host, mandatory if remote host takes part in the connection |
  ...  +------------------+------+---------------------------------------------------------------------------------------+

  [Arguments]  ${rmod_sn}  ${remote_host}=None

  ${all_ips}=  radio.Get IP For All Radio Modules  print_table=False  remote_host=${remote_host}

  FOR  ${smod}  ${ips}  IN ZIP  ${all_ips.keys()}  ${all_ips.values()}
    ${nested_dict}=  Get From Dictionary  ${all_ips}  ${smod}
    ${is_rmod_sn}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${nested_dict}  ${rmod_sn}
    Continue For Loop If  '${is_rmod_sn}'=='False'
    RETURN  ${smod}
  END

SSH Send Command On System Module
  [Arguments]  ${bts_id}  ${command}  ${target_ip}=192.168.255.129  ${alias}=sm_ssh  ${timeout}=30
  [Documentation]
  ...  Description:
  ...  KW send command to sm, returns output
  ...
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | Argument        | Man. | Description                                                                                        |
  ...  +==================+======+===================================================================================================+
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | alias            | No   |  alias that the new connection object will be identified by                                       |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | timeout          | No   |  timeout in seconds for the TCP connect (30.0 by default)                                         |
  ...  +------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczysnki@nokia.com

  Logging With Timestamp
  ...  message=Logging Start for BTS_ID: ${bts_id}
  ${bts_alias_type}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_alias_type
  ${bts_ip_address}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_ip_address
  IF  '${bts_alias_type}' == 'localhost'
    tafssh.Connect To
    ...  hostname=${target_ip}
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  alias=sm_ssh
  ELSE IF  '${bts_ip_address}'=='${EMPTY}'
    Run Keywords
    ...  tafssh.Connect To
    ...  hostname=${CFG.NODES['${bts_id}']['vm_ip_LMP_address']}
    ...  username=ute
    ...  alias=sm_ssh_proxy
    ...  timeout=${timeout}
    ...  AND  tafssh.Connect To
    ...  hostname=${target_ip}
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  alias=sm_ssh
    ...  proxy=sm_ssh_proxy
    ...  timeout=${timeout}
  ELSE
    tafssh.Connect To
    ...  hostname=${bts_ip_address}
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  alias=sm_ssh
  END
  tafssh.send_command
  ...  command=${command}
  ...  connection=sm_ssh
  ...  timeout=${timeout}

  ${output}=  tafssh.read_output
  ...  connection=sm_ssh
  Set Variable    ${alias}  ${alias}
  [Teardown]  Run Keyword And Continue On Failure  tafssh.Disconnect  connection=sm_ssh
  [Return]  ${output}

SSH Send Command On Specific BBMOD
  [Arguments]  ${bts_id}  ${command}  ${bbmod_serial_number}  ${target_ip}=192.168.255.129  ${alias}=sm_ssh  ${platform_type}=multicore  ${timeout}=30
  [Documentation]
  ...  Description:
  ...  KW sends a command to a specific BBMOD and returns the output.
  ...
  ...  +------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | Argument               | Man. | Description                                                                                       |
  ...  +========================+======+===================================================================================================+
  ...  | bts_id                 | Yes  | BTS_ID used as alias                                                                              |
  ...  +------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | command                | Yes  | Command to be executed on the BBMOD                                                               |
  ...  +------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | bbmod_serial_number    | Yes  | Serial number of the BBMOD                                                                        |
  ...  +------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | target_ip              | No   | Target IP address for the connection (default is 192.168.255.129)                                 |
  ...  +------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | alias                  | No   | Alias that the new connection object will be identified by                                        |
  ...  +------------------------+------+---------------------------------------------------------------------------------------------------+
  ...  | timeout                | No   | Timeout in seconds                                                                                |
  ...  +------------------------+------+---------------------------------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczysnki@nokia.com

  Logging With Timestamp
  ...  message=SSH Send Command On Specific BBMOD
  ${bts_alias_type}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_alias_type
  ${bts_ip_address}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_ip_address
  IF  '${bts_alias_type}' == 'localhost'
    tafssh.Connect To
    ...  hostname=${target_ip}
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  alias=sm_ssh
  ELSE IF  '${bts_ip_address}'=='${EMPTY}'
    Run Keywords
    ...  tafssh.Connect To
    ...  hostname=${CFG.NODES['${bts_id}']['vm_ip_LMP_address']}
    ...  username=ute
    ...  alias=sm_ssh_proxy
    ...  timeout=${timeout}
    ...  AND  tafssh.Connect To
    ...  hostname=${target_ip}
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  alias=sm_ssh
    ...  proxy=sm_ssh_proxy
    ...  timeout=${timeout}
  ELSE
    tafssh.Connect To
    ...  hostname=${bts_ip_address}
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  alias=sm_ssh
  END
  IF  '${platform_type}'=='multicore'
    ${board_type}=  Set Variable    fsp
  ELSE
    ${board_type}=  Set Variable    fct
  END
  ${horizontalPosition}  ${verticalPosition}=  SCFC Get BBMOD Position Id  ${CFG.NODES['${bts_id}']['scf_file_path']}  ${bbmod_serial_number}
  ${horizontalPosition}=  Set Variable If  '${platform_type}'=='multicore'  ${horizontalPosition}  1
  ${verticalPosition}=  Set Variable If  '${platform_type}'=='multicore'  ${verticalPosition}  1
  ${sm_tunnel_needed}=  Set Variable If  ${CFG.NODES['${bts_id}']['scf_active_node']}==${horizontalPosition}  ${False}  ${True}
  ${sm_tunnel_domain}=  Set Variable If  ${CFG.NODES['${bts_id}']['scf_active_node']}==1  4  1
  IF  '${platform_type}'=='multicore'
    ${bbmod_domain_id}=  Set Variable If
    ...  ${horizontalPosition}==1 and ${verticalPosition}==2  1
    ...  ${horizontalPosition}==1 and ${verticalPosition}==3  2
    ...  ${horizontalPosition}==1 and ${verticalPosition}==4  3
    ...  ${horizontalPosition}==2 and ${verticalPosition}==2  5
    ...  ${horizontalPosition}==2 and ${verticalPosition}==3  6
    ...  ${horizontalPosition}==2 and ${verticalPosition}==4  7
    ${processor_number}=  Set Variable  0
  ELSE
    ${bbmod_domain_id}=  Set Variable  0
    ${processor_number}=  Set Variable  1
  END
  IF  '${sm_tunnel_needed}'=='True'
    Run Keywords
    ...  tafssh.Connect To
    ...  hostname=fct-${sm_tunnel_domain}a
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  alias=sm_ssh_tunnel
    ...  proxy=sm_ssh
    ...  AND  tafssh.Connect To
    ...  hostname=${board_type}${bbmod_domain_id}s${processor_number}icom
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  proxy=sm_ssh_tunnel
    ...  alias=bb_ssh
  ELSE
    tafssh.Connect To
    ...  hostname=${board_type}${bbmod_domain_id}s${processor_number}icom
    ...  username=toor4nsn
    ...  password=oZPS0POrRieRtu
    ...  proxy=sm_ssh
    ...  alias=bb_ssh
  END

  ${output}=  tafssh.execute
  ...  command=${command}
  ...  connection=bb_ssh
  ...  timeout=${timeout}
  Set Variable    ${alias}  ${alias}
  [Teardown]  Run Keywords
  ...  Run Keyword And Continue On Failure  tafssh.Disconnect  connection=bb_ssh
  ...  AND  Run Keyword If  ${sm_tunnel_needed}
  ...  Run Keyword And Continue On Failure  tafssh.Disconnect  connection=sm_ssh_tunnel
  ...  AND  Run Keyword And Continue On Failure  tafssh.Disconnect  connection=sm_ssh
  [Return]  ${output}
