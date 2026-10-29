*** Settings ***
Documentation     author: yayun zhang AP from DevHZ5 yin zhang
...                 contact: yayun.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : AP

Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/AP/SG03_DevHZ5_startup.robot

*** Variables ***
${UE1}  1
${UE2}  2
${UE3}  3
${UE4}  4
${UE5}  5

*** Keywords ***

Ap UE Reestablish
  [Arguments]  ${enb}=1  ${cell}=1  ${ue}=${UE1}  ${cause}=otherFailure
  [Documentation]  EGATE> help ue_rrc_reestablish
  ...
  ...  COMMAND:
  ...
  ...  ue_rrc_reestablish
  ...
  ...  DESCRIPTION:
  ...
  ...  Initiates UE RRC reestablishment procedure.
  ...
  ...  ARGUMENTS:
  ...
  ...  <id=1..25000+>   - local identifier of UE
  ...
  ...  [enb=1..147]  - eNB index for reestablishment (current if omitted)
  ...
  ...  [cell=1..257]   - cell index for reestablishment (current if omitted)
  ...
  ...  [cause=one of the following:]  - reestablishment cause (otherFailure if omitted)
  ...
  ...  reconfigurationFailure - Set reestablishment cause to reconfigurationFailure(0x0)
  ...
  ...  handoverFailure  - Set reestablishment cause to handoverFailure(0x1)
  ...
  ...  otherFailure - Set reestablishment cause to otherFailure(0x2)
  Execute Egate Command  ue_rrc_reestablish id=${ue} enb=${enb} cell=${cell} cause=${cause}
  ...  RRC Reestablishment sucessfully completed


Bar Cell${number}
  Delta Commission Parameters  NRCELL-${number}:cellBarred=barred
  # can't check Barring status in WEBGUI or infomodel, it is totally different thing with NRCELL:cellBarred
  # PR CNNed: PR630295: [22R2][ASOE][FDD][CPRI]: cell Barring status is not correct
  Object Should Exist  NRCELL-${number}:cellBarred=barred

Notbar Cell${number}
  Delta Commission Parameters  NRCELL-${number}:cellBarred=notBarred
  Object Should Exist  NRCELL-${number}:cellBarred=notBarred

Disable NG Link${number}
  ${delta_param}  Create List  SERVEDAMF-${number}:administrativeState=Locked  NRBTS:actNgcFlexSaMode=true
  Delta Commission Parameters  ${delta_param}
  Object Should Exist  SERVEDAMF-${number}:ngLinkStatus=Inactive

Enable NG Link${number}
  Delta Commission Parameters  SERVEDAMF-${number}:administrativeState=Unlocked
  Object Should Exist  SERVEDAMF-${number}:ngLinkStatus=Active

Lock Cell${number}
  Delta Commission Parameters  NRCELL-${number}:administrativeState=Locked
  Cell Should Be Locked  ${number}

Unlock Cell${number}
  Delta Commission Parameters  NRCELL-${number}:administrativeState=Unlocked
  Cell Should Be Unlocked  ${number}

Block Cell${number:\S+}
  ${nrcel_id}  Get cell id by configuration id  NR  ${number}
  Block_cell  ${nrcel_id}
  Assert  NRCEL  ${nrcel_id}  blockingState=Blocked
  Sleep  10s

Unblock Cell${number:\S+}
  ${nrcel_id}  Get cell id by configuration id  NR  ${number}
  Unblock_cell  ${nrcel_id}
  Assert  NRCEL  ${nrcel_id}  blockingState=Unblocked
  Cells Should Be OnAir  cell_id=${number}

Block Cell${number:\S+} GNB2
  ${nrcel_id}  Get cell id by configuration id  NR  ${number}  connection=${GNB2_ALIAS}
  Block_cell  ${nrcel_id}  connection=${GNB2_ALIAS}
  Assert  NRCEL  ${nrcel_id}  blockingState=Blocked  connection=${GNB2_ALIAS}
  Sleep  10s

Unblock Cell${number:\S+} GNB2
  ${nrcel_id}  Get cell id by configuration id  NR  ${number}  connection=${GNB2_ALIAS}
  Unblock_cell  ${nrcel_id}  connection=${GNB2_ALIAS}
  Assert  NRCEL  ${nrcel_id}  blockingState=Unblocked  connection=${GNB2_ALIAS}
  Cells Should Be OnAir Gnb2  cell_id=${number}

Set Ovlthreshold On All Bbmods
    [Arguments]    ${threshold_value}
    Get Current Scf File  local_dir_path=.    file_name=scf_ovl.xml    export_type=configurationAndRuntimeObjects
    @{bbmod_id_list}=    Get Bbmod Ids From Scfc    scf_ovl.xml
    ${cp_ue_ids}=    Get Specific Node Id    node_type=cp_ue
    ${fsp_prefix}=    Get Fsp Prefix For SSH
    FOR    ${bbmod_id}    IN    @{bbmod_id_list}
        ${output}=    Execute Cmd On Fsp    lxc-ls    ${fsp_prefix}-${bbmod_id}a
        ${container_ids}=    Set Variable    ${output.split()}
        ${avaialble_cp_ue_ids}=    evaluate    list(set(${cp_ue_ids}) & set(${container_ids}))
        Set Ovlthreshold On CPUEs    ${threshold_value}    ${fsp_prefix}-${bbmod_id}a    ${avaialble_cp_ue_ids}
    END

Get Fsp Prefix For SSH
    [Documentation]    This keyword is to get a fsp-5a or asp-5a by baseband unit type.
    ...     reason: the login command is different, after sshenb,  login ssh by asp-1a or fsp-1a.
    ${BBU_TYPE}=    Get Variable Value    ${BBU_TYPE}
    ${BBU_TYPE}=    Run Keyword If    '${BBU_TYPE}'=='None'    Get Bbu Type
    ...    ELSE
    ...    Set Variable  ${BBU_TYPE}
    ${fsp_prefix}    Set Variable If
    ...    '${BBU_TYPE}'=='ASIB'    fsp
    ...    '${BBU_TYPE}'=='ASIL'    asp
    ...    '${BBU_TYPE}'=='ASIK'    asp
    [Return]    ${fsp_prefix}

Get OvlThreshold Prerequisite
    [Documentation]    This keyword is to get prepared varible before send overload command.
    ...    the keyword purpose is to speed up the time of overload command sent.
    ...
    ...    Examples:
    ...    | Get OvlThreshold Prerequisite |
    ...    | Set Ovlthreshold On Specific Cpue Id | cpue_ids=20,21,30,31 | threshold_value=20 |
	${scf_file_exist}=    evaluate    os.path.exists("./scf_ovl.xml")    modules=os
	Run Keyword If    not ${scf_file_exist}    Get Current Scf File
	...    local_dir_path=.    file_name=scf_ovl.xml    export_type=configurationAndRuntimeObjects
	@{BBMOD_IDS}=    Get Variable Value    @{BBMOD_IDS}
	${bbmod_id_length}=    Get Length    ${BBMOD_IDS}
    @{BBMOD_IDS}=    Run Keyword If    '${bbmod_id_length}'=='0'    Get Bbmod Ids From Scfc    scf_ovl.xml
    ...    ELSE    Create List    @{BBMOD_IDS}
    Set Test Variable  @{BBMOD_IDS}
    &{CPUE_IDS_DATA}=    Get Variable Value    &{CPUE_IDS_DATA}
    ${cpue_ids_length}=    Get Length    ${CPUE_IDS_DATA}
    &{CPUE_IDS_DATA}=    Run Keyword If    '${cpue_ids_length}'=='0'    Get All Cpue Ids    ${BBMOD_IDS}
    ...    ELSE    Create Dictionary    &{CPUE_IDS_DATA}
    Set Test Variable  &{CPUE_IDS_DATA}

Check If Started By Btssw
    [Documentation]    This keyword is to check if process exists and start by btssw owner
    ...    Examples:
    ...    | Check If Started By Btssw | process_name=cp-rt | board=auto |
    [Arguments]    ${process_name}    ${board}=auto
    Execute Cmd On Gnb    ps -ef | grep ${process_name} | grep btssw | grep -v grep    board=${board}
    ${out}=   Execute Cmd On Gnb    ps -ef | grep ${process_name} | grep btssw | grep -v grep | awk '{if($1 ~ /^btssw/) {print "True"}}'
    ...    board=${board}
    Should Contain    ${out}    True

Trigger BBMOD${x}:${y} Auto Reset
    Execute Cmd On Gnb    ps aux|grep l1_application_nrt    board=fsp${x}:${y}
    ${pidinfo}    Execute Cmd On Gnb    ps aux|grep l1_application_nrt|grep -v grep|awk '{print $2}'    board=fsp${x}:${y}
    ${status}    Execute Cmd On Gnb     kill -11 ${pidinfo}    board=fsp${x}:${y}
    Should Be Empty    ${status}
    Execute Cmd On Gnb    ps aux|grep l1_application_nrt    board=fsp${x}:${y}

Trigger BBMOD${x}:${y} Reset By BTS-OAM
    Execute Cmd On Gnb    ps aux|grep sfpd    board=fsp${x}:${y}
    ${pidinfo}    Execute Cmd On Gnb    ps aux|grep sfpd|grep -v grep|awk '{print $2}'    board=fsp${x}:${y}
    ${status}    Execute Cmd On Gnb     kill -11 ${pidinfo}    board=fsp${x}:${y}
    Should Be Empty    ${status}
    Execute Cmd On Gnb    ps aux|grep sfpd    board=fsp${x}:${y}

_Get Target Container
    [Arguments]    ${process}    ${process_num}    ${board}
    Execute Cmd On Gnb    ps -ef|grep -i lxc-start|grep -i ${process}|grep -v grep    board=${board}
    ${containers}    Execute Cmd On Gnb    ps -ef|grep -i lxc-start|grep -i ${process}|grep -v grep|awk '{print $(NF-2)}'    board=${board}
    ${containers_list}    Set Variable    ${containers.split()}
    Sort List    ${containers_list}
    ${containers_len}    Get Length    ${containers_list}
    Should Be True    0 < int(${process_num}) <= ${containers_len}
    ${taget_container}    Set Variable    ${containers_list[int(${process_num})-1]}
    [Return]    ${taget_container}

Trigger CPUE${x} On BBMOD${y} Auto Reset
    ${container}    _get target container    process=cpue    process_num=${x}    board=fsp${y}:0
    Execute Cmd On Gnb    lxc-attach -n ${container} -- ps -ef|grep CCS|grep -i Daemon    board=fsp${y}:0
    Execute Cmd On Gnb    lxc-attach -n ${container} -- pkill -11 -f '/opt/CCS/CCSDaemonExe'     board=fsp${y}:0
    Execute Cmd On Gnb    lxc-attach -n ${container} -- ps -ef|grep CCS|grep -i Daemon    board=fsp${y}:0

Trigger UPUE${x} On BBMOD${y} Auto Reset
    ${container}    _get target container    process=upue    process_num=${x}    board=fsp${y}:0
    Execute Cmd On Gnb    lxc-attach -n ${container} -- ps -ef|grep CCS|grep -i Daemon    board=fsp${y}:0
    Execute Cmd On Gnb    lxc-attach -n ${container} -- pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe'     board=fsp${y}:0
    Execute Cmd On Gnb    lxc-attach -n ${container} -- ps -ef|grep CCS|grep -i Daemon    board=fsp${y}:0

Trigger L2RT${x} On BBMOD${y} Auto Reset
    ${container}    _get target container    process=l2rt    process_num=${x}    board=fsp${y}:0
    Execute Cmd On Gnb    lxc-attach -n ${container} -- ps -ef|grep CCS|grep -i Daemon    board=fsp${y}:0
    Execute Cmd On Gnb    lxc-attach -n ${container} -- pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe'     board=fsp${y}:0
    Execute Cmd On Gnb    lxc-attach -n ${container} -- ps -ef|grep CCS|grep -i Daemon    board=fsp${y}:0

Remove Blank Character
    [Arguments]    ${str}
    ${str}=    Remove String    ${str}    ${SPACE}
    ${str}=    Remove String    ${str}    \r\n
    ${str}=    Remove String    ${str}    \n
    ${str}=    Remove String    ${str}    \x1b[K
    [Return]    ${str}

Delta Commission Parameters And Wait Cells Onair
    [Arguments]    ${delta_params}    ${timeout}=120
    Delta Commission Parameters    ${delta_params}
    Cells Should Be Onair     timeout=${timeout}



