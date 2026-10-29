*** Settings ***
Documentation  BTS Verification
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    OperatingSystem
Library    taf.sw.syslog    WITH NAME    syslog
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ./admin.robot
Resource    ../../resources/bts_scfc.robot
Resource    ../../resources/Robot/scfc.robot
Resource    ../../resources/Robot/faults.robot

*** Keywords ***
IP Address Is Pingable
    [Arguments]  ${ip_addr}
    [Documentation]
    ...  Description:
    ...  Keyword checks if IP address is pingable.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ip_addr                | Yes  | IP address of device.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rc}=  Run And Return Rc  command=ping -c 1 ${ip_addr}
    Should Be Equal As Integers  ${rc}  0

SSH Is Available
    [Arguments]  ${ip_addr}
    [Documentation]
    ...  Description:
    ...  Keyword checks whether an ssh connection to the IP address is possible.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ip_addr                | Yes  | IP address of device.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rc}  ${output}=  Run And Return Rc And Output
    ...  sshpass -p oZPS0POrRieRtu ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" ${ip_addr} 'ls'
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0

BTS Is Available
    [Arguments]  ${retry_timeout}=120  ${ip_addr}=${ENB_IP_ADDR}
    [Documentation]
    ...  Description:
    ...  Keyword checks if BTS is available (pingable).
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | retry_timeout          | Yes  | Time to retry the keyword.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ip_addr                | Yes  | IP address of BTS.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${retry_timeout}  10  IP Address Is Pingable  ip_addr=${ip_addr}

BTS Is Unavailable
    [Arguments]  ${retry_timeout}=60  ${ip_addr}=${ENB_IP_ADDR}
    [Documentation]
    ...  Description:
    ...  Keyword checks if BTS is unavailable (not pingable).
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | retry_timeout          | Yes  | Time to retry the keyword.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ip_addr                | Yes  | IP address of BTS.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${retry_timeout}  5
    ...   Run Keyword And Expect Error  *  IP Address Is Pingable  ip_addr=${ip_addr}

BTS And CUS Are Accessible
    [Arguments]  ${list_of_cus_ips}
    [Documentation]
    ...  Description:
    ...  Keyword checks if BTS and all CUS are accessible.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  300  10  IP Address Is Pingable  ip_addr=${ENB_IP_ADDR}
    Wait Until Keyword Succeeds  300  10  SSH Is Available  ip_addr=${ENB_SSH_IP_USER}
    FOR  ${cus_ip}  IN  @{list_of_cus_ips}
      Wait Until Keyword Succeeds  300  10  IP Address Is Pingable  ip_addr=${cus_ip}
      Wait Until Keyword Succeeds  300  10  SSH Is Available  ip_addr=toor4nsn@${cus_ip}
    END

CUS Is Available
    [Arguments]  ${list_of_cus_ips}  ${retry_timeout}=240
    [Documentation]
    ...  Description:
    ...  Keyword checks if all CUS are available (pingable).
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | retry_timeout          | Yes  | Time to retry the keyword.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${cus_ip}  IN  @{list_of_cus_ips}
      Wait Until Keyword Succeeds  ${retry_timeout}  10  IP Address Is Pingable  ip_addr=${cus_ip}
    END

BTS Verify Extra Configuration Setup
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword checks extra configurations parameter based on SCFC and Admin comparison.
    ...  Checklist: Bandwidth for every cell, existence of CAREL objects.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    BTS Admin And SCFC Bandwidth Should Match  ${scfc_file_path}
    ${carel_state}=  Run Keyword And Return Status  SCFC Check If CAREL Exist  ${scfc_file_path}
    Run Keyword If  ${carel_state}  Admin CAREL Should Exist

BTS Admin And SCFC Bandwidth Should Match
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword checks if bandwidth specified in SCFC file matches to bandwidth configured in Admin.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lcr_id_list}=  SCFC Create LcrId List  scfc_file_path=${scfc_file_path}
    ${lncel_id_list}=  SCFC Create LncelId List For LcrdId List
    ...  scfc_file_path=${scfc_file_path}  lcr_id_list=${lcr_id_list}
    FOR  ${lncel_id}  IN  @{lncel_id_list}
      ${lncel_bw_from_scfc}=  SCFC Get LNCEL Bandwidth  scfc_file_path=${scfc_file_path}  lncel_id=${lncel_id}
      ${lncel_bw_from_admin}=  Admin Get LNCEL Bandwidth  lncel_id=${lncel_id}
      Should Contain  ${lncel_bw_from_scfc}  ${lncel_bw_from_admin}
    END

BTS Check OnAir Stability
    [Arguments]  ${timeout}  ${allowed_alarms}  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword checks BTS stabilization - BTS should be OnAir and no not allowed alarm should occur.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | timeout                | Yes  | Time the BTS should be OnAir and no not allowed alarm should occur.        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Sleep  ${timeout}
    Log  ${log_prefix}BTS stabilization timeout ${timeout}s has finished  console=${log_to_console}
    Execute_Egate_Command  cmd=disp_state  pass_regex=The state is ACTIVE
    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
    Admin Get And Check Active Alarms  ${allowed_alarms}

BTS Verify ULCoMP Configuration
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the corresponding "ulCoMp" activation message has appeared in SysLog.
    ...  SysLog example message:
    ...  "Handle UlCellSetupReq for lnCelId:1 lCelId:1 phyCellId:1 bw:50 actMassiveMimo:0
    ...  nRxAnt:4 hasCompInfo:1 ulCoMpMode:3 supercell:0"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ulcomp_object}=  Set Variable  contains(@class, "NOKLTE:ULCOMP") and contains(@distName,"ULCOMP-0")
    ${ulcompcell_lncel_list}=  Evaluate Xpath  ${scfc_file_path}
    ...  .//managedObject[${ulcomp_object}]/list[@name="ulCoMpCellList"]/p/text()
    FOR  ${lncell_id}  IN  @{ulcompcell_lncel_list}
      Run Keyword And Continue On Failure
      ...  syslog.Message Should Exist In Syslog File  regexp=lnCelId:${lncell_id}.*hasCompInfo:1.*
    END

BTS Check ULCoMP Configuration
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword checks whether "ulCoMp" is configured and the corresponding "ulCoMp"
    ...  activation message has appeared in SysLog.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${actCoMp_value}=  SCFC Get Object Parameter Value
    ...  scfc_file_path=${scfc_file_path}  dist_name=MRBTS-1/LNBTS-1  parameter_name=actCoMp
    ${ulcomp_exist}=  Run Keyword And Return Status
    ...  SCFC Class Should Exist  scfc_file_path=${scfc_file_path}  class_name=NOKLTE:ULCOMP
    Run Keyword If  '${actCoMp_value}'!='disabled' and ${ulcomp_exist}
    ...  BTS Verify ULCoMP Configuration  scfc_file_path=${scfc_file_path}

BTS Verify Hardware Unit State
    [Arguments]  ${class_name}  ${serial_number}  ${state}  ${state_value}  ${timeout}=10
    [Documentation]
    ...  Description:
    ...  Keyword checks value of hardware unit given state.
    ...  Hardware unit is defined by class name and serial number.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | class_name             | Yes  | Class name of checking hardware unit.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | serial_number          | Yes  | Serial number of checking hardware unit.                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | state                  | Yes  | Name of the state being checked.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | state_value            |  Yes | Value of expected state.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for hardware unit expected state.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${result}=  admin.Assert Any  class_name=${class_name}
    ...  parameters=${state}=regex"(?i)${state_value}",serialNumber=${serial_number}
    ...  timeout=${timeout}
    ${result_state}=  Set Variable  ${result[0]['${state}']}
    [Return]  ${result_state}

BTS Verify All Hardware Unit State
    [Arguments]  ${class_name}  ${state}  ${state_value}  ${timeout}=10
    [Documentation]
    ...  Description:
    ...  Keyword checks value of hardware unit given state.
    ...  Hardware unit is defined by class name.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | class_name             | Yes  | Class name of checking hardware unit.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | state                  | Yes  | Name of the state being checked.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | state_value            |  Yes | Value of expected state.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for hardware unit expected state.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${result}=  admin.Assert Every  class_name=${class_name}  parameters=${state}=regex"(?i)${state_value}"
    ...  timeout=${timeout}
    ${result_state}=  Set Variable  ${result[0]['${state}']}
    [Return]  ${result_state}

