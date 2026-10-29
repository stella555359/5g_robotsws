*** Settings ***
Documentation
...    Author:        przemyslaw.kempa@nokia.com
...    Maintainer:    Przemysław Kempa

Resource    ../tc_scenarios.robot
Resource    resources/ca_Recovery_link_break.robot
#Resource    ../SiSo_L3_Call.robot
Library     taf.sbts.oam.sc.rest   WITH NAME  rest
Library     SSHLibrary

*** Variables ***
${SISO_L3_CALL}          False

*** Keywords ***
TC_SiSo_RU_ASIR_Unplug_Plug_pRRH
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-28933
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this scenario is to cover plug in and unplug fiber between pRRH and HUB
    ...  We can provide S/N of tested pRRH or test will choose randomly one
    ...  Optional variable in cfg to perform test
    ...  e.g.
    ...  pRRH=NH230800640
    ...
    ...  *** Test Variable For L3 Call ***
    ...  ${SISO_L3_CALL}             False  #default value for L3 call is False, set test variable as True to perform test with L3 call
    ...  ${CELLS_YAML_PATH}                 #mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
    ...
    ...  *****************
    ...  History of change
    ...  *****************
    ...

    Set Tags	CA-CM    AUTHOR-przemyslaw.kempa@nokia.com    MAINTAINER-przemyslaw.kempa@nokia.com
    ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 8     PHASE-CRT  FEATURE-CB00
  Common Test Setup
  Logging With Timestamp
  ...  message=TC_SiSo_RU_ASIR_Unplug_Plug_pRRH will be executed
  ...  style=ONGOING

    FOR  ${node}  IN  @{cfg['active_bts_list']}
      Step 1: ASIR Unplug pRRH  alias=${node}
      Step 2: Check States After Unplug pRRH  alias=${node}
      Step 3: ASIR plug pRRH
      Step 4: Check States After Plug pRRH  alias=${node}
    END
  [Teardown]    Common Test Teardown



Step 1: ASIR Unplug pRRH
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 1: ASIR Unplug pRRH ===  console=${TRUE}
    Preaparing Variables Before Test ASIR Unplug Plug pRRH  alias=${alias}
    Login To ASIRHUB via SSH And Change Poeport Value  ${TESTED_IP_HUBMOD}  ${TESTED_NUM_ANTMOD}  off
    Adding Allowed Alarms After Unplug pRRH  ${AFFECTED_CELLS_CFG_LIST}

Step 2: Check States After Unplug pRRH
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 2: Check States After Unplug pRRH ===  console=${TRUE}
    Run Keyword And Continue On Failure  admin.Assert Alarm Active  faultId=4479, severity=Critical  connection=${alias}
    Verify Alarms  ${alias}
    Run Keyword And Continue On Failure  Verify Alarms In ASIR After Unplug pRRH
    Run Keyword And Continue On Failure  ASIR Check Expected States For Cells  ${AFFECTED_CELLS_DN_LIST}
    ...  operationalState=regex"(?i)Disabled", administrativeState=regex"(?i)Unlocked", availabilityStatus=regex"[Ff]ailed"  ${alias}
    Run Keyword And Continue On Failure  ASIR Check Expected States For Cells  ${NOT_AFFECTED_CELLS_DN_LIST}
    ...  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"  ${alias}

Step 3: ASIR plug pRRH
    Log  === Step 3: ASIR plug pRRH ===  console=${TRUE}
    Login To ASIRHUB via SSH And Change Poeport Value  ${TESTED_IP_HUBMOD}  ${TESTED_NUM_ANTMOD}  on

Step 4: Check States After Plug pRRH
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    Log  === Step 4: Check States After Plug pRRH ===  console=${TRUE}
    ${node}  Fetch from right  ${alias}  _
    Verify BTS State  ${node}
    Verify Alarms  ${alias}
    Asir Check Active Alarms  ${alias}
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For All Cells  ${cfg['test_logs_path']}  ${alias}
    ...    ELSE  Log To Console  L3 Call skipped  console=True

Preaparing Variables Before Test ASIR Unplug Plug pRRH
    [Arguments]  ${alias}=${cfg.primary_node_bts_id}
    ${all_antmods_dict}  Asir Get All Antmods Info  alias=${alias}
    Set Test Variable  ${ALL_ANTMODS_DICT}    ${all_antmods_dict}
    ${all_antmods_list}  Get Dictionary Keys  ${all_antmods_dict}
    ${provided_antmod_exist}   Run Keyword And Return Status  Variable Should Exist  ${cfg.pRRH}
    FOR  ${antmod}  IN  @{all_antmods_list}
        Exit For Loop If   not ${provided_antmod_exist}
        ${provided_antmod}  Run Keyword If  "${all_antmods_dict['${antmod}']['serial_number_pRRH']}"=="${cfg.pRRH}"  Set Variable  ${antmod}
        Exit For Loop If  "${all_antmods_dict['${antmod}']['serial_number_pRRH']}"=="${cfg.pRRH}"
    END
    ${empty_status}  Run Keyword If  ${provided_antmod_exist}  Run Keyword And Return Status  Should Not Be Empty  ${provided_antmod}
    Run Keyword If  ${provided_antmod_exist}  Run Keyword If  not ${empty_status}  Fail  Not correct S\N of pRRH -> ${cfg.pRRH}
    ${random_antmod_list_index}  Evaluate  random.randint(0,len(${all_antmods_list})-1)  random
    ${random_antmod}  Get From List  ${all_antmods_list}  ${random_antmod_list_index}
    ${tested_antmod}  Set Variable If  ${provided_antmod_exist}  ${provided_antmod}  ${random_antmod}
    Set Test Variable  ${TESTED_ANTMOD}  ${tested_antmod}
    ${antport_distname}  Get From Dictionary  ${all_antmods_dict['${tested_antmod}']}  antport_distname
    ${serial_number_asir}  Get From Dictionary  ${all_antmods_dict['${tested_antmod}']}  serial_number_asir
    ${affected_cells_id_list}  Get From Dictionary  ${all_antmods_dict['${tested_antmod}']}    cells_list_cfg
    Set Test Variable  ${AFFECTED_CELLS_CFG_LIST}  ${affected_cells_id_list}
    ${tested_num_antmod}  Fetch From Right  ${antport_distname}    ANTPORT-
    Set Test Variable  ${TESTED_NUM_ANTMOD}  ${tested_num_antmod}
    ${nrcels}   admin.Get ids for all  NRCEL  connection=${alias}
    ${lncels}   admin.Get ids for all  LNCEL  search_for_iot_cells=${True}  connection=${alias}
    ${wncels}   admin.Get ids for all  WNCEL  connection=${alias}
    ${gncels}   admin.Get ids for all  GNCEL  connection=${alias}
    ${all_cells_dn_list}  Combine Lists  ${nrcels}  ${lncels}  ${wncels}  ${gncels}
    ${affected_cells_runtime_list}  Create List
    FOR  ${cell_id}   IN  @{affected_cells_id_list}
        ${id}  Fetch From Right  ${cell_id}  L-
        ${nr_status}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  NRCELL
        ${lte_status}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  LNCEL
        ${wcdma_status}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  LNCEL
        ${gsm_status}  Run Keyword And Return Status  Should Match Regexp  ${cell_id}  LNCEL
        ${rat_type}=   Set Variable If   '${lte_status}' == 'True'  LTE
        ...                              '${gsm_status}' == 'True'  GSM
        ...                              '${wcdma_status}' == 'True'  WCDMA
        ...                               '${nr_status}' == 'True'  NR
        ${cell_id_runtime}  Get Cell Id By Configuration Id  ${rat_type}  ${id}  connection=${alias}
        Append To List  ${affected_cells_runtime_list}  ${cell_id_runtime}
    END
    Set Test Variable  ${AFFECTED_CELLS_DN_LIST}  ${affected_cells_runtime_list}
    Set Test Variable  ${NOT_AFFECTED_CELLS_DN_LIST}  ${all_cells_dn_list}
    Remove Values From List  ${NOT_AFFECTED_CELLS_DN_LIST}  @{AFFECTED_CELLS_DN_LIST}
    ${all_asir_parameters}  Get Parameters For All  ASIRMOD  connection=${alias}
    FOR  ${asirmod}  IN  @{all_asir_parameters}
        Run Keyword If  "${asirmod['serialNumber']}"=="${serial_number_asir}"  Set Test Variable  ${TESTED_IP_HUBMOD}  ${asirmod['ipAddress']}
        Exit For Loop If  "${asirmod['serialNumber']}"=="${serial_number_asir}"
    END

Adding Allowed Alarms After Unplug pRRH
    [Arguments]  ${cells_list}
    FOR  ${cell_cfg_dn}  IN  @{cells_list}
        Append To List  ${GLO_ADMIN_ALLOWED_ALARMS}  faultId=4479, severity=Critical, configObjectName=regex".*${cell_cfg_dn}"
    END

Verify Alarms In ASIR After Unplug pRRH
    ${asir_alarms}  Asir Get Active Alarms  ${alias}
    FOR  ${alarm}  IN  @{asir_alarms}
        ${fault_id_status}  Set Variable If  "${alarm['fault_id']}"=="4480"  ${TRUE}  ${FALSE}
        ${fault_name_status}  Set Variable If  "${alarm['fault_name']}"=="ANTMOD not detected"  ${TRUE}  ${FALSE}
        ${severity_status}  Set Variable If  "${alarm['severity']}"=="major"  ${TRUE}  ${FALSE}
        ${source_uid_status}  Set Variable If  "${alarm['source_uid']}"=="${ALL_ANTMODS_DICT['${TESTED_ANTMOD}']['uid']}"  ${TRUE}  ${FALSE}
        ${final_status}  Evaluate  ${fault_id_status} and ${fault_name_status} and ${severity_status} and ${source_uid_status}
        Exit For Loop If  ${final_status}
    END
    Run Keyword If  ${final_status}  Log To Console  Expected fault 4480 visible for ${TESTED_ANTMOD} in WebASIR
    Run Keyword If  not ${final_status}  Run Keyword And Continue On Failure  Fail  Expected fault 4480 NOT visible for ${TESTED_ANTMOD} in WebASIR

Login To ASIRHUB via SSH And Change Poeport Value
    [Arguments]  ${asirmod_ip}  ${TESTED_NUM_ANTMOD}  ${poepower_status}
    ${login}  Set Variable  toor4nsn
    ${password}  Set Variable  oZPS0POrRieRtu
    Run Keyword If  "${cfg['robot_env']}"=="remote"  _Open Connection SSH To Smod Via Remote Host  ${password}
    ...  ELSE  _Open Connection SSH To Smod  ${login}    ${password}
    ${ip_exist_master}  _LXC Attach On SMOD  ${asirmod_ip}
    Run Keyword If  not ${ip_exist_master}  _Exit And Jump To Slave  ${password}
    ${ip_exist_slave}  Run Keyword If  not ${ip_exist_master}  _LXC Attach On SMOD  ${asirmod_ip}
    Run Keyword If  ${ip_exist_master} or ${ip_exist_slave}  _Log To ASIRHUB  ${login}  ${password}  ${asirmod_ip}
    Log To Console  POEPOWER ${poepower_status} For ASIRMOD With IP ${asirmod_ip} and port ${TESTED_NUM_ANTMOD} started
    ${TESTED_PORTNUM_ANTMOD}  Evaluate  ${TESTED_NUM_ANTMOD}-1
    ${write_output}  SSHLibrary.Write  poepower ${TESTED_PORTNUM_ANTMOD} ${poepower_status}
    ${read_output}  SSHLibrary.Read Until  :~#
    ${poepower_output}  Run Keyword And Return Status   should contain  ${read_output}  success
    Run Keyword If  ${poepower_output}  Log To Console  POEPOWER ${poepower_status} Finish With Success !!!
    Run Keyword If  not ${poepower_output}  Run Keyword And Continue On Failure  FAIL  POEPOWER ${poepower_status} Finish With Error !!!
    SSHLibrary.Close Connection

_Open Connection SSH To Smod Via Remote Host
    [Arguments]  ${password}
    SSHLibrary.Open Connection  ${cfg['TL_Host_Remote'][0]}  prompt=REGEXP:[$#>]$
    SSHLibrary.Login With Public Key  ute  /home/ute/.ssh/id_rsa
    SSHLibrary.Set Client Configuration  timeout=20s
    SSHLibrary.Write  sshenb
    ${output}  SSHLibrary.Read Until Regexp   fingerprint|Password
    ${fingerprint}  Run Keyword And Return Status   should contain  ${output}  fingerprint
    ${password_required}  Run Keyword And Return Status   should contain  ${output}  Password
    ${fingerprint_output}  Run Keyword If  ${fingerprint}
    ...  Run Keywords  SSHLibrary.Write  yes  AND  SSHLibrary.Read Until  Password:  AND  SSHLibrary.Write  ${password}
    ${password_output}  Run Keyword If  ${password_required}  Run Keywords  SSHLibrary.Write  ${password}  AND  SSHLibrary.Read Until Prompt

_Open Connection SSH To Smod
    [Arguments]  ${login}  ${password}
    SSHLibrary.Open Connection  192.168.255.1  prompt=REGEXP:[$#>]$
    ${login_output}  SSHLibrary.Login  ${login}  ${password}
    SSHLibrary.Set Client Configuration  timeout=20s

_LXC Attach On SMOD
    [Arguments]  ${asirmod_ip}
    SSHLibrary.Write  lxc-ls
    ${output}  SSHLibrary.Read Until  >
    ${output}  Remove String  ${output}  \n  \r
    Run Keyword If  '0x1018' in '${output}'
    ...  SSHLibrary.Write  lxc-attach --name 0x1018
    ...  ELSE
    ...  SSHLibrary.Write  lxc-attach --name 0x2018
    SSHLibrary.Read Until  :~ >
    SSHLibrary.Set Client Configuration  timeout=40s
    SSHLibrary.Write  arp
    ${read_output}  SSHLibrary.Read Until  :~ >
    ${ip_exist}  Run Keyword And Return Status  Should Contain  ${read_output}  ${asirmod_ip}
    [Return]  ${ip_exist}

_Log To ASIRHUB
    [Arguments]  ${login}  ${password}  ${asirmod_ip}
    SSHLibrary.Write  ssh ${login}@${asirmod_ip}
    ${output}  SSHLibrary.Read Until Regexp   refused|fingerprint|[Pp]assword|#
    ${fingerprint}  Run Keyword And Return Status  Should Contain  ${output}  fingerprint
    ${password_required}   Run Keyword And Return Status  Should Contain  ${output}  Password
    Run Keyword If  ${fingerprint}  Run Keywords
    ...  SSHLibrary.Write  yes
    ...  AND  SSHLibrary.Read Until  Password:
    ...  AND  SSHLibrary.Write  ${password}
    Run Keyword If  ${password_required}  SSHLibrary.Write  ${password}
    SSHLibrary.Read Until Prompt
    Log To Console  Connection established successfully to ASIRMOD with IP ${asirmod_ip}

_Exit And Jump To Slave
    [Arguments]  ${password}
    SSHLibrary.Write  exit
    ${login_output}  SSHLibrary.Read Until  >
    ${left_side}  Run Keyword And Return Status  Should Contain  ${login_output}  root@fct-0a
    Run Keyword If  ${left_side}  SSHLibrary.Write  ssh toor4nsn@fct-4a
    Run Keyword If  not ${left_side}  SSHLibrary.Write  ssh toor4nsn@fct-0a
    ${output}  SSHLibrary.Read Until Regexp   fingerprint|[Pp]assword|>
    ${fingerprint}  Run Keyword And Return Status  Should Contain  ${output}  fingerprint
    ${password_required}  Run Keyword And Return Status  Should Match Regexp  ${output}  [Pp]assword
    ${prompt}   Run Keyword And Return Status  Should Contain  ${output}  >
    Run Keyword If  ${password_required}  Run Keywords
    ...  SSHLibrary.Write  ${password}
    ...  AND  SSHLibrary.Read Until Prompt
    ...  AND  Return From Keyword
    ...  ELSE IF  ${fingerprint}
    ...  SSHLibrary.Write  yes
    ...  ELSE IF  ${prompt}
    ...  Return From Keyword
    ${output}  SSHLibrary.Read Until Regexp   [Pp]assword|>
    ${password_required}  Run Keyword And Return Status  Should Match Regexp  ${output}  [Pp]assword
    Run Keyword If  ${password_required}  Run Keywords
    ...  SSHLibrary.Write  ${password}
    ...  AND  SSHLibrary.Read Until Prompt
