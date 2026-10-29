*** Settings ***
Documentation    General Procedures RF Sharing related Kewywords
...              Resource used by RF Sharing Vrf tribe
...              Author: Dinu Olariu
...              Contact: dinu.olariu@nokia.com

Library    XML
Library    Collections
Library    DateTime
Library    hran_bsc
Library    OperatingSystem
Library    Process
Library    String
Library    SSHLibrary
Library    Telnet
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.sw.ping  WITH NAME  ping
Library    taf.ul.verify_snapshot  WITH NAME  snapshot
Library    python_resources/snapshot_soap.py  WITH NAME  soap_trace_analysis
Library    taf.config.scf  WITH NAME  scf
Library    python_resources/tools.py
Library    python_resources/extract.py
Library    python_resources/btslogfile.py
Library    python_resources/WFTDownloader.py
Library    python_resources/BlackBox.py
Resource    rfs_infomodel.robot
Resource    rfs_pdu.robot

*** Variables ***
@{no alarms}
${DF LOG PATH}=  ${OUTPUT DIR}/df.log

*** Keywords ***
Prepare expected alarms list
    [Documentation]
    ...  Keyword for creating list of alarms multiplicated by multiplication number
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter             | Man. | Description                                    |
    ...  | exp_alarms_list       | Yes  | List with alarms prepared for multiplication   |
    ...  | multiplication_number | Yes  | Number by which alarms should be multiplicated |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description               |
    ...  | multiplicated_exp_list | List of lists with alarms |
    ...
    ...  *EXAMPLE*
    ...  | ${WCDMA_exp_alarms_multiplicated}= | Prepare expected alarms list | [['7665', 'Core']] | 5 |

    [Arguments]  ${exp_alarms_list}  ${multiplication_number}
    ${multiplicated_exp_list}=  create list
    FOR  ${index}  IN RANGE  ${multiplication_number}
        Append to list  ${multiplicated_exp_list}  @{exp_alarms_list}
    END
    [Return]  ${multiplicated_exp_list}

Open session to BSC
    [Documentation]
    ...  Connect and login to BSC
    ...
    ...  | **Author:** patryk.furman@nokia.com
    ...  | **Maintainer:** patryk.furman@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW for connecting to BSC. It sets keepalive function on with value of 5 minutes and sets 10 seconds timeout
    ...  | for Telnet feedbacks. In default it uses IP and credentials from config file.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------+---------------------------------------------+
    ...  | Parameter name | Man. | Default                    | Description                                 |
    ...  +================+======+============================+=============================================+
    ...  | bsc_ip         | no   | ${BSC['ip']}           | BSC IP address                                  |
    ...  +----------------+------+----------------------------+---------------------------------------------+
    ...  | bsc_username   | no   | ${BSC['user']}         | BSC username used for logging in                |
    ...  +----------------+------+----------------------------+---------------------------------------------+
    ...  | bsc_password   | no   | ${BSC['password']}     | BSC password used for logging in |
    ...  +----------------+------+----------------------------+---------------------------------------------+
    ...  | connection_type | no  | telnet                 | connection type used, possible values telnet/ssh|
    ...  +----------------+------+----------------------------+---------------------------------------------+

    [Arguments]  ${bsc_ip}=${BSC['ip']}  ${bsc_username}=${BSC['user']}  ${bsc_password}=${BSC['password']}  ${connection_type}=telnet
    Run Keyword If  '${connection_type}'=='telnet'  Run Keywords  hran_bsc.Bsc Connection  ${bsc_ip}
    ...  AND  hran_bsc.Bsc Login  ${bsc_username}  ${bsc_password}
    ...  ELSE  hran_bsc.Bsc Ssh Connection  host=${bsc_ip}  username=${bsc_username}  password=${bsc_password}
    hran_bsc.Set Keepalive
    hran_bsc.Set Timeout  10 seconds
    Log  Session to ${bsc_ip} started  console=${TRUE}

Get Admin Cells And RMs Number
    [Documentation]
    ...  Helper keyword providing number of NR or LTE cells and radio modules from WebEM running view.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter               | Description                             |
    ...  | runtime_cell_number     | WebEM runtime view cells number         |
    ...  | IOT_runtime_cell_number | WebEM runtime view IOT cells number     |
    ...  | runtime_rmod_number     | WebEM runtime view radio modules number |
    ...
    [Arguments]  ${alias}
    ${alias_upper}=  Convert to Uppercase  ${alias}
    ${cell_ids}  ${IOT_cell_ids}=  Admin Get CELL Ids list  ${alias}
    Set Test Variable  ${${${alias_upper}}[${alias_upper}_TECH']_cell_ids}  ${cell_ids}
    Set Test Variable  ${${${alias_upper}}[${alias_upper}_TECH]_IOT_cell_ids}  ${IOT_cell_ids}
    ${runtime_cell_number}=  Get Length  ${cell_ids}
    ${IOT_runtime_cell_number}=  Get Length  ${IOT_cell_ids}

    ${rmod_ids}=  Get Ids For All  RMOD  alias=${alias}
    Set Test Variable  ${${${alias_upper}}[${alias_upper}_TECH]_rmod_ids}  ${rmod_ids}
    ${Runtime_rmod_number}=  Get Length  ${rmod_ids}

    [Return]  ${runtime_cell_number}  ${IOT_runtime_cell_number}  ${runtime_rmod_number}

Get BTS SCF Cells And RMODs Number
    [Documentation]
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  Get BTS NR cells, LTE cells, WCDMA cells, GSM cells, LTE IOT cells and radio modules number from SCF.
    ...
    ...  | Parameter | Man. | Description            |
    ...  | alias     | Yes  | BTS alias              |
    ...  | scf_file  | Yes  | BTS SCF file full path |
    ...
    ...  *RETURN*
    ...  | Parameter                | Description                           |
    ...  | SCF_NR_cell_count        | SCF configured NR cells number        |
    ...  | SCF_LTE_cell_count       | SCF configured LTE cells number       |
    ...  | SCF_WCDMA_cell_count     | SCF configured WCDMA cells number     |
    ...  | SCF_GSM_cell_count       | SCF configured GSM cells number       |
    ...  | SCF_NBIOT_FDD_cell_count | SCF configured NBIOT FDD cells number |
    ...  | SCF_rmod_count           | SCF configured radio modules number   |
    ...
    [Arguments]  ${alias}  ${scf_file}

    ${SCF_NR_cell_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRCELL-[\\d]+$  scf_path=${scf_file}  alias=${alias}
    ${SCF_NR_cell_count}=  Get Length  ${SCF_NR_cell_list}
    ${SCF_LTE_cell_list}=  Get All Dist Names By Pattern from SCF  pattern=/LNCEL_[F|T]DD-[\\d]+$  scf_path=${scf_file}  alias=${alias}
    ${SCF_LTE_cell_count}=  Get Length  ${SCF_LTE_cell_list}
    ${SCF_WCDMA_cell_list}=  Get All Dist Names By Pattern from SCF  pattern=/WNCEL-[\\d]+$  scf_path=${scf_file}  alias=${alias}
    ${SCF_WCDMA_cell_count}=  Get Length  ${SCF_WCDMA_cell_list}
    ${SCF_GSM_cell_list}=  Get All Dist Names By Pattern from SCF  pattern=/GNCEL-[\\d]+$  scf_path=${scf_file}  alias=${alias}
    ${SCF_GSM_cell_count}=  Get Length  ${SCF_GSM_cell_list}
    ${SCF_NBIOT_FDD_cell_list}=  Get All Dist Names By Pattern from SCF  pattern=/NBIOT_FDD-[\\d]+$  scf_path=${scf_file}  alias=${alias}
    ${SCF_NBIOT_FDD_cell_count}=  Get Length  ${SCF_NBIOT_FDD_cell_list}
    ${SCF_rmod_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${scf_file}  alias=${alias}
    ${SCF_rmod_count}=  Get Length  ${SCF_rmod_list}

    [Return]  ${SCF_NR_cell_count}  ${SCF_LTE_cell_count}  ${SCF_WCDMA_cell_count}  ${SCF_GSM_cell_count}  ${SCF_NBIOT_FDD_cell_count}
    ...  ${SCF_rmod_count}

Check PM archive transfer
    [Arguments]  ${alias}  ${folder_path}
    ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${folder_path}
    Run Keyword If  ${status}
    ...  Log  ${alias} PM archive ${${alias}_PM_ARCHIVE} available at ${folder_path}  level=INFO  console=True
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${PM_collect}  ${False}
    ...  AND  Log  ${alias} PM archive ${${alias}_PM_ARCHIVE} not available at ${folder_path}  level=WARN

Check PM files on VM
    [Documentation]
    ...  KW used to check PM files info on VM.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter          | Man. | Description                                |
    ...  | PM_folder_archive  | Yes  | Absolute path for PM archive storage on VM |
    ...  | alias              | Yes  | Master or Slave                            |
    ...
    [Arguments]  ${PM_folder_archive}  ${alias}

    ${PM_file_name}=  OperatingSystem.Run  unzip -Z1 "${PM_folder_archive}" PM.BTS-*.${VM_UTC_date}*
    Log  PM files generated on ${alias} during last hour:  console=True
    ${PM_file_name}=  Replace String  ${PM_file_name}  \n  ${SPACE}
    Run Keyword If  '${PM_file_name}' != ''  Log  ${PM_file_name}  console=True
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${PM_check}  ${False}
    ...  AND  Log  No PM files generated on ${alias} during last hour!  level=WARN

    ${PM_archive_size}=  OperatingSystem.Run  du -k "${PM_folder_archive}" | cut -f1
    ${PM_archive_size}=  Convert To Integer  ${PM_archive_size}
    Run Keyword If  ${PM_archive_size} > 0  Log  PM archive size (K) for ${alias}: ${PM_archive_size}  console=True
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${PM_check}  ${False}
    ...  AND  Log  PM archive size (K) for ${alias} is empty!  level=WARN

    ${PM_file_count}=  OperatingSystem.Run  unzip -Z1 "${PM_folder_archive}" | wc -l
    Run Keyword If  ${PM_file_count} > 0  Log  Number of PM files inside PM archive for ${alias}: ${PM_file_count}  console=True
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${PM_check}  ${False}
    ...  AND  Log  No PM files inside PM archive for ${alias}!  level=WARN

Set BTS system account permissions enable feature parameter
    [Documentation]
    ...  Set BTS system account permissions enable feature parameter: systemAcctPermEnable. Possile values: false or true
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man. | Description                |
    ...  | systemAcctPermEnable | Yes  | systemAcctPermEnable value |
    ...  | alias                | Yes  | BTS admin instance alias   |
	...
    [Arguments]  ${systemAcctPermEnable}  ${alias}

    ${BTS_systemAcctPermEnable}=  Get BTS system account permissions enable feature parameter  ${alias}
    Run Keyword If  '${BTS_systemAcctPermEnable}' == '${systemAcctPermEnable}'  Run Keywords
    ...  Log  Parameter systemAcctPermEnable already set on BTS ${alias}: ${BTS_systemAcctPermEnable}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${FEATCADM_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${FEATCADM_dn}=  Get From List  ${FEATCADM_dn_list}  0

    coam.Perform Parameter Recommissioning  dist_name=${FEATCADM_dn}  parameter=systemAcctPermEnable  operation=update  value=${systemAcctPermEnable}
    ...  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  5s

    ${BTS_systemAcctPermEnable}=  Get BTS system account permissions enable feature parameter  ${alias}
    Run Keyword If  '${BTS_systemAcctPermEnable}' == '${systemAcctPermEnable}'
    ...  Log  Parameter systemAcctPermEnable set on BTS ${alias}: ${BTS_systemAcctPermEnable}, successfully commissioned!  console=True

Get BTS system account permissions enable feature parameter
    [Documentation]
    ...  Get BTS system account permissions enable feature parameter: systemAcctPermEnable
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description              |
    ...  | alias     | Yes  | BTS admin instance alias |
	...
    ...  *RETURN VALUE*
    ...  | systemAcctPermEnable_info | true, false or NA |

    [Arguments]  ${alias}

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${FEATCADM_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${FEATCADM_dn}=  Get From List  ${FEATCADM_dn_list}  0

    ${systemAcctPermEnable_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${FEATCADM_dn}
    ...  p_name=systemAcctPermEnable

    ${systemAcctPermEnable_count}=  Get Length  ${systemAcctPermEnable_dict}
    ${systemAcctPermEnable_info}=  Run Keyword If  ${systemAcctPermEnable_count} > 0
    ...  Get From Dictionary  ${systemAcctPermEnable_dict}  systemAcctPermEnable
    ...  ELSE
    ...  Set Variable  NA

    [Return]  ${systemAcctPermEnable_info}

Count Cell Tx Rx Total Number
    [Arguments]  ${Cell_DN}  ${CELL_RM_list}
    FOR  ${item}  IN  @{CELL_RM_list}
        ${Cell_Tx_count}  ${Cell_Rx_count}=  Run Keyword If  '${item[0]}' == '${Cell_DN}'
        ...  Count RM Tx Rx Total Number  ${item[5]}
        Exit For Loop If  '${item[0]}' == '${Cell_DN}'
    END
    [Return]  ${Cell_Tx_count}  ${Cell_Rx_count}

Count RM Tx Rx Total Number
    [Arguments]  ${RM_list}
    Set Test Variable  ${Cell_Tx_count}  0
    Set Test Variable  ${Cell_Rx_count}  0
    FOR  ${item}  IN  @{RM_list}
        ${Tx_count}=  Get Count  ${item[1]}  TX
        ${Rx_count}=  Get Count  ${item[1]}  RX
        ${Cell_Tx_count}=  Evaluate  ${Cell_Tx_count} + ${Tx_count}
        ${Cell_Rx_count}=  Evaluate  ${Cell_Rx_count} + ${Rx_count}
    END
    [Return]  ${Cell_Tx_count}  ${Cell_Rx_count}

Count Cell-RM Tx Rx Number
    [Arguments]  ${Cell_DN}  ${RM_DN}  ${CELL_RM_list}
    FOR  ${item}  IN  @{CELL_RM_list}
        ${Cell_RM_Tx_count}  ${Cell_RM_Rx_count}=  Run Keyword If  '${item[0]}' == '${Cell_DN}'
        ...  Count RM Tx Rx Number  ${RM_DN}  ${item[5]}
        Exit For Loop If  '${item[0]}' == '${Cell_DN}'
    END
    [Return]  ${Cell_RM_Tx_count}  ${Cell_RM_Rx_count}

Count RM Tx Rx Number
    [Arguments]  ${RM_DN}  ${RM_list}
    FOR  ${item}  IN  @{RM_list}
        Set Test Variable  ${Cell_RM_Tx_count}  0
        Set Test Variable  ${Cell_RM_Rx_count}  0
        ${Tx_count}=  Run Keyword If  '${item[0]}' == '${RM_DN}'  Get Count  ${item[1]}  TX
        ${Tx_is_none}=	Run Keyword And Return Status	Should Be Equal	${Tx_count}	 ${None}
		${Tx_count}=  Set Variable If  '${Tx_is_none}' == 'True'  0  ${Tx_count}
        ${Rx_count}=  Run Keyword If  '${item[0]}' == '${RM_DN}'  Get Count  ${item[1]}  RX
        ${Rx_is_none}=	Run Keyword And Return Status	Should Be Equal	${Rx_count}	 ${None}
		${Rx_count}=  Set Variable If  '${Rx_is_none}' == 'True'  0  ${Rx_count}
        ${Cell_RM_Tx_count}=  Run Keyword If  '${item[0]}' == '${RM_DN}'  Evaluate  ${Cell_RM_Tx_count} + ${Tx_count}
		${Cell_RM_Tx_is_none}=	Run Keyword And Return Status	Should Be Equal	${Cell_RM_Tx_count}	 ${None}
		${Cell_RM_Tx_count}=  Set Variable If  '${Cell_RM_Tx_is_none}' == 'True'  0  ${Cell_RM_Tx_count}
        ${Cell_RM_Rx_count}=  Run Keyword If  '${item[0]}' == '${RM_DN}'  Evaluate  ${Cell_RM_Rx_count} + ${Rx_count}
        ${Cell_RM_Rx_is_none}=	Run Keyword And Return Status	Should Be Equal	${Cell_RM_Rx_count}	 ${None}
		${Cell_RM_Rx_count}=  Set Variable If  '${Cell_RM_Rx_is_none}' == 'True'  0  ${Cell_RM_Rx_count}
        Exit For Loop If  '${item[0]}' == '${RM_DN}'
    END
    [Return]  ${Cell_RM_Tx_count}  ${Cell_RM_Rx_count}

Calculate MIMO Cells Alarms
    [Arguments]  ${Cell_Tx_active_count}  ${Cell_Rx_active_count}  ${Cell_Tx_count}  ${Cell_Rx_count}  ${dlMimoMode}  ${syncSigTxMod}  ${actOtdoa}
    ...  ${actPrsTxDiv}  ${Cell_DN}  ${Cell_availabilityStatus}  ${alias}

    ${condition1}=  Create Long String  ${Cell_Tx_active_count} == ${Cell_Tx_count} and ${Cell_Rx_active_count} != ${Cell_Rx_count}
    ...  and ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' != 'SingleTX'
    Run Keyword If  ${condition1}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Degraded_}  alias=${alias}

    ${condition2}=  Create Long String  ${Cell_Tx_active_count} == ${Cell_Tx_count} and ${Cell_Rx_active_count} != ${Cell_Rx_count}
    ...  and ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' == 'SingleTX'
    Run Keyword If  ${condition2}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Degraded_}  alias=${alias}

    Run Keyword If  ${Cell_Tx_count} == 8 and ${Cell_Tx_active_count} != ${Cell_Tx_count}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Failed_}  alias=${alias}

    ${condition3}=  Create Long String  ${Cell_Tx_count} != 8 and ${Cell_Tx_count} != 4 and ${Cell_Tx_active_count} != ${Cell_Tx_count} and
    ...  ${Cell_Tx_active_count} >= 1 and ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' != 'SingleTX' and '${txPathFailureMode}' ==
    ...  'keepCellInService' and '${syncSigTxMod}' == 'TxDiv' and '${actOtdoa}' == 'True' and '${actPrsTxDiv}' == 'True'
    Run Keyword If  ${condition3}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Degraded_}  alias=${alias}
    ${condition4}=  Create Long String  ${Cell_Tx_count} != 8 and ${Cell_Tx_count} != 4 and ${Cell_Tx_active_count} != ${Cell_Tx_count} and
    ...  ${Cell_Tx_active_count} >= 1 and ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' != 'SingleTX' and '${txPathFailureMode}' ==
    ...  'keepCellInService' and '${syncSigTxMod}' == 'TxDiv' and '${actOtdoa}' == 'True' and '${actPrsTxDiv}' == 'False'
    Run Keyword If  ${condition4}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Failed_}  alias=${alias}
    ${condition5}=  Create Long String  ${Cell_Tx_count} != 8 and ${Cell_Tx_count} != 4 and ${Cell_Tx_active_count} != ${Cell_Tx_count} and
    ...  ${Cell_Tx_active_count} >= 1 and ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' != 'SingleTX' and '${txPathFailureMode}' ==
    ...  'keepCellInService' and '${syncSigTxMod}' == 'TxDiv' and '${actOtdoa}' == 'False'
    Run Keyword If  ${condition5}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Degraded_}  alias=${alias}

    ${condition6}=  Create Long String  ${Cell_Tx_count} == 4 and ${Cell_Tx_active_count} != ${Cell_Tx_count} and ${Cell_Tx_active_count} >= 3
    ...  and ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' != 'SingleTX' and '${txPathFailureMode}' == 'keepCellInService' and '${syncSigTxMod}'
    ...  == 'TxDiv' and '${actOtdoa}' == 'True' and '${actPrsTxDiv}' == 'True'
    Run Keyword If  ${condition6}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Degraded_}  alias=${alias}
    ${condition7}=  Create Long String  ${Cell_Tx_count} == 4 and ${Cell_Tx_active_count} != ${Cell_Tx_count} and ${Cell_Tx_active_count} >= 3
    ...  and ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' != 'SingleTX' and '${txPathFailureMode}' == 'keepCellInService' and '${syncSigTxMod}'
    ...  == 'TxDiv' and '${actOtdoa}' == 'True' and '${actPrsTxDiv}' == 'False'
    Run Keyword If  ${condition7}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Failed_}  alias=alias=${alias}
    ${condition8}=  Create Long String  ${Cell_Tx_count} == 4 and ${Cell_Tx_active_count} != ${Cell_Tx_count} and ${Cell_Tx_active_count} >= 3
    ...  and ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' != 'SingleTX' and '${txPathFailureMode}' == 'keepCellInService' and '${syncSigTxMod}'
    ...  == 'TxDiv' and '${actOtdoa}' == 'False'
    Run Keyword If  ${condition8}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Degraded_}  alias=${alias}

    ${condition9}=  Create Long String  ${Cell_Tx_count} == 4 and ${Cell_Tx_active_count} != ${Cell_Tx_count} and ${Cell_Tx_active_count} < 3 and
    ...  ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' != 'SingleTX' and '${txPathFailureMode}' == 'keepCellInService'
    Run Keyword If  ${condition9}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Failed_}  alias=${alias}

    ${condition10}=  Create Long String  ${Cell_Tx_count} == 4 and ${Cell_Tx_active_count} != ${Cell_Tx_count} and ${Cell_Tx_active_count} >= 3
    ...  and ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' != 'SingleTX' and '${txPathFailureMode}' == 'keepCellInService' and '${syncSigTxMod}'
    ...  == 'SingleTx'
    Run Keyword If  ${condition10}
    ...  Run Keyword If  '${Cell_availabilityStatus}' in ${Degraded_}  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ${condition11}=  Create Long String  ${Cell_Tx_count} == 4 and ${Cell_Tx_active_count} != ${Cell_Tx_count} and ${Cell_Tx_active_count} >= 3
    ...  and ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' != 'SingleTX' and '${txPathFailureMode}' == 'keepCellInService' and '${syncSigTxMod}'
    ...  == 'SingleTx'
    Run Keyword If  ${condition11}
    ...  Run Keyword If  '${Cell_availabilityStatus}' in ${Failed_}  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0

    ${condition12}=  Create Long String  ${Cell_Tx_count} != 8 and ${Cell_Tx_count} != 4 and ${Cell_Tx_active_count} != ${Cell_Tx_count} and
    ...  ${Cell_Tx_active_count} >= 1 and ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' == 'SingleTX' and '${txPathFailureMode}' ==
    ...  'keepCellInService'
    Run Keyword If  ${condition12}
    ...  Run Keyword If  '${Cell_availabilityStatus}' in ${Degraded_}  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ${condition13}=  Create Long String  ${Cell_Tx_count} != 8 and ${Cell_Tx_count} != 4 and ${Cell_Tx_active_count} != ${Cell_Tx_count} and
    ...  ${Cell_Tx_active_count} >= 1 and ${Cell_Rx_active_count} >= 1 and '${dlMimoMode}' == 'SingleTX' and '${txPathFailureMode}' ==
    ...  'keepCellInService'
    Run Keyword If  ${condition13}
    ...  Run Keyword If  '${Cell_availabilityStatus}' in ${Failed_}  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0

    ${condition14}=  Create Long String  ${Cell_Tx_active_count} != ${Cell_Tx_count} and ${Cell_Tx_active_count} >= 1 and ${Cell_Rx_active_count}
    ...  >= 1 and '${txPathFailureMode}' == 'disableCell'
    Run Keyword If  ${condition14}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Degraded_}  alias=${alias}

    Run Keyword If  ${Cell_Rx_active_count} == 0  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Failed_}  alias=${alias}

    Run Keyword If  ${Cell_Tx_active_count} == 0  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  Assert  LNCEL  ${Cell_DN}  availabilityStatus=${Failed_}  alias=${alias}

Add mimo cells alarms to list
    [Arguments]  ${RM_cells_count_alarms_mimo}  ${value}
    ${RM_cells_count_alarms_mimo}=  Evaluate  ${RM_cells_count_alarms_mimo} + ${value}
    Set Test Variable  ${RM_cells_count_alarms_mimo}

Set Ethernet port security enabled feature parameter
    [Documentation]
    ...  Set Ethernet port security enabled feature parameter: ethernetPortSecurityEnabled. Possible values: false or true
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                   | Man. | Description                       |
    ...  | ethernetPortSecurityEnabled | Yes  | ethernetPortSecurityEnabled value |
    ...  | alias                       | Yes  | BTS admin instance alias          |
	...
    [Arguments]  ${ethernetPortSecurityEnabled}  ${alias}

    ${BTS_ethernetPortSecurityEnabled}=  Get Ethernet port security enabled feature parameter  ${alias}
    Run Keyword If  '${BTS_ethernetPortSecurityEnabled}' == '${ethernetPortSecurityEnabled}'  Run Keywords
    ...  Log  Parameter ethernetPortSecurityEnabled already set on BTS ${alias}: ${BTS_ethernetPortSecurityEnabled}, commissioning not needed!
    ...  console=True
    ...  AND  Return From Keyword

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${SECADM_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/SECADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${SECADM_dn}=  Get From List  ${SECADM_dn_list}  0

    coam.Perform Parameter Recommissioning  dist_name=${SECADM_dn}  parameter=ethernetPortSecurityEnabled  operation=update
    ...  value=${ethernetPortSecurityEnabled}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  5s

    ${BTS_ethernetPortSecurityEnabled}=  Get BTS system account permissions enable feature parameter  ${alias}
    Run Keyword If  '${BTS_ethernetPortSecurityEnabled}' == '${ethernetPortSecurityEnabled}'
    ...  Log  Parameter ethernetPortSecurityEnabled set on BTS ${alias}: ${BTS_ethernetPortSecurityEnabled}, successfully commissioned!  console=True

Get Ethernet port security enabled feature parameter
    [Documentation]
    ...  Get Ethernet port security enabled feature parameter: ethernetPortSecurityEnabled
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description              |
    ...  | alias     | Yes  | BTS admin instance alias |
	...
    ...  *RETURN VALUE*
    ...  | ethernetPortSecurityEnabled_info | true, false or NA |

    [Arguments]  ${alias}

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${SECADM_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/SECADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${SECADM_dn}=  Get From List  ${SECADM_dn_list}  0

    ${ethernetPortSecurityEnabled_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${SECADM_dn}
    ...  p_name=ethernetPortSecurityEnabled

    ${ethernetPortSecurityEnabled_count}=  Get Length  ${ethernetPortSecurityEnabled_dict}
    ${ethernetPortSecurityEnabled_info}=  Run Keyword If  ${ethernetPortSecurityEnabled_count} > 0
    ...  Get From Dictionary  ${ethernetPortSecurityEnabled_dict}  ethernetPortSecurityEnabled
    ...  ELSE
    ...  Set Variable  NA

    [Return]  ${ethernetPortSecurityEnabled_info}

Get Activate Temporary Radio Master Role From Slave BTS
    [Documentation]
    ...  Get Activate Temporary Radio Master Role value on slave BTS. Possible outputs: true, false or None
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description                            |
    ...  | BTS_scf   | No   | BTS SCF file full path                 |
    ...  | alias     | No   | admin instance alias, by default Slave |
    ...
    ...  *RETURN VALUE*
    ...  | BTS_actTempRadioMaster         | true, false or None |

    [Arguments]  ${BTS_scf}=${EMPTY}  ${alias}=Slave
    ${BTS_scf}=  Run Keyword If  '${BTS_scf}'==''  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ...  ELSE  Set Variable  ${BTS_scf}
    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0
    ${BTS_actTempRadioMaster}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}  parameter_to_check=actTempRadioMaster
    ...  scf_path=${BTS_scf}
    Set Variable If  '${BTS_actTempRadioMaster}' == 'true'  ${BTS_actTempRadioMaster}  ${None}

    [Return]  ${BTS_actTempRadioMaster}

Get Activate Temporary Radio Master Timers From Slave BTS
    [Documentation]
    ...  Get Activate Temporary Radio Master Timers tempRadioMasterRecovTime and tempRadioMasterTriggerTime values on slave BTS.
    ...  Outputs: 2 integer values (minutes)
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description                            |
    ...  | BTS_scf   | No   | BTS SCF file full path                 |
    ...  | alias     | No   | admin instance alias, by default Slave |
    ...
    ...  *RETURN VALUE*
    ...  | BTS_tempRadioMasterRecovTime   BTS_tempRadioMasterTriggerTime        | 2 integer values |

    [Arguments]  ${BTS_scf}=${EMPTY}  ${alias}=Slave
    ${BTS_scf}=  Run Keyword If  '${BTS_scf}'==''  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ...  ELSE  Set Variable  ${BTS_scf}
    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0
    ${BTS_tempRadioMasterRecovTime}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}  parameter_to_check=tempRadioMasterRecovTime
    ...  scf_path=${BTS_scf}
    ${BTS_tempRadioMasterTriggerTime}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}  parameter_to_check=tempRadioMasterTriggerTime
    ...  scf_path=${BTS_scf}
    Run Keyword If  not ${BTS_tempRadioMasterRecovTime}  Log  tempRadioMasterRecovTime not found in scf!  console=True
    Run Keyword If  not ${BTS_tempRadioMasterTriggerTime}  Log  tempRadioMasterTriggerTime not found in scf!  console=True
    Set Variable If  ${BTS_tempRadioMasterRecovTime}  ${BTS_tempRadioMasterRecovTime}  ${None}
    Set Variable If  ${BTS_tempRadioMasterTriggerTime}  ${BTS_tempRadioMasterTriggerTime}  ${None}

    [Return]  ${BTS_tempRadioMasterRecovTime}  ${BTS_tempRadioMasterTriggerTime}

Set Activate Temporary Radio Master Role From Slave BTS
    [Documentation]
    ...  Set Activate Temporary Radio Master Role value on slave BTS. Possible values: true, false
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                  | Man. | Description                            |
    ...  | BTS_scf                    | No   | BTS SCF file full path                 |
    ...  | actTempRadioMaster         | No   | param value                            |
    ...  | alias                      | No   | admin instance alias, by default Slave |
	...

	[Arguments]  ${BTS_scf}=${EMPTY}  ${actTempRadioMaster}=${EMPTY}  ${alias}=Slave
    ${BTS_scf}=  Run Keyword If  '${BTS_scf}'==''  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ...  ELSE  Set Variable  ${BTS_scf}
    ${BTS_actTempRadioMaster}=  Get Activate Temporary Radio Master Role From Slave BTS  ${BTS_scf}  ${alias}
    Run Keyword If  '${actTempRadioMaster}'=='' or '${actTempRadioMaster}'=='${BTS_actTempRadioMaster}'  Run Keywords
    ...  Log  Parameter actTempRadioMaster already set on BTS non radioMaster: ${BTS_actTempRadioMaster}, commissioning not needed!  console=True
    ...  AND  Set Test Variable  ${BTS_actTempRadioMaster}
    ...  AND  Return From Keyword

    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0
    coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=actTempRadioMaster  operation=update
    ...  value=${actTempRadioMaster.lower()}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}
    Sleep  5s
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_actTempRadioMaster}=  Get Activate Temporary Radio Master Role From Slave BTS  ${BTS_scf}  ${alias}
    Run Keyword If  '${BTS_actTempRadioMaster}'=='${actTempRadioMaster.lower()}'  Run Keywords
    ...  Log  Parameter actTempRadioMaster set on BTS non radioMaster: ${BTS_actTempRadioMaster}, successfully commissioned!  console=True
    ...  AND  Set Test Variable  ${BTS_actTempRadioMaster}

Set Activate Temporary Radio Master Timers On Slave BTS
    [Documentation]
    ...  Set Activate Temporary Radio Master Timers values on slave BTS. Possible values: 2 integers values (minutes)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                  | Man. | Description                            |
    ...  | BTS_scf                    | No   | BTS SCF file full path                 |
    ...  | tempRadioMasterRecovTime   | No   | param value (minutes)                  |
    ...  | tempRadioMasterTriggerTime | No   | param value (minutes)                  |
    ...  | alias                      | No   | admin instance alias, by default Slave |
	...

	[Arguments]  ${BTS_scf}=${EMPTY}  ${tempRadioMasterRecovTime}=${EMPTY}  ${tempRadioMasterTriggerTime}=${EMPTY}  ${alias}=Slave
    ${BTS_scf}=  Run Keyword If  '${BTS_scf}'==''  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ...  ELSE  Set Variable  ${BTS_scf}
    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0
    ${BTS_tempRadioMasterRecovTime}  ${BTS_tempRadioMasterTriggerTime}=  Get Activate Temporary Radio Master Timers From Slave BTS  ${BTS_scf}
    ...   ${alias}
    ${condition}=  Create Long String  ('${tempRadioMasterRecovTime}'=='' or '${BTS_tempRadioMasterRecovTime}'=='${tempRadioMasterRecovTime}')
    ...  and ('${tempRadioMasterTriggerTime}'=='' or '${BTS_tempRadioMasterTriggerTime}'=='${tempRadioMasterTriggerTime}')
    Run Keyword If  ${condition}  Run Keywords
    ...  Log  Parameter tempRadioMasterRecovTime already set on BTS non radioMaster: ${BTS_tempRadioMasterRecovTime}, commissioning not needed!
    ...  console=True
    ...  AND  Log
    ...  Parameter tempRadioMasterTriggerTime already set on BTS non radioMaster: ${BTS_tempRadioMasterTriggerTime}, commissioning not needed!
    ...  console=True  AND  Return From Keyword
    Run Keyword If  '${tempRadioMasterRecovTime}'=='' or '${tempRadioMasterRecovTime}'=='${BTS_tempRadioMasterRecovTime}'  Run Keywords
    ...  Log  Parameter tempRadioMasterRecovTime already set on BTS non radioMaster: ${BTS_tempRadioMasterRecovTime}, commissioning not needed!
    ...  console=True
    ...  AND  Set Test Variable  ${tempRadioMasterRecovTime_change}  False
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=tempRadioMasterRecovTime  operation=update
    ...  value=${tempRadioMasterRecovTime}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}
    ...  AND  Set Test Variable  ${tempRadioMasterRecovTime_change}  True
    ...  AND  Sleep  5s
    Run Keyword If  '${tempRadioMasterTriggerTime}'=='' or '${tempRadioMasterTriggerTime}'=='${BTS_tempRadioMasterTriggerTime}'  Run Keywords
    ...  Log  Parameter tempRadioMasterTriggerTime already set on BTS non radioMaster: ${BTS_tempRadioMasterTriggerTime}, commissioning not needed!
    ...  console=True  AND  Set Test Variable  ${tempRadioMasterTriggerTime_change}  False
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=tempRadioMasterTriggerTime  operation=update
    ...  value=${tempRadioMasterTriggerTime}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}
    ...  AND  Set Test Variable  ${tempRadioMasterTriggerTime_change}  True
    ...  AND  Sleep  5s
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${BTS_tempRadioMasterRecovTime}  ${BTS_tempRadioMasterTriggerTime}=  Get Activate Temporary Radio Master Timers From Slave BTS  ${BTS_scf}
    ...  ${alias}
    Run Keyword If  '${BTS_tempRadioMasterRecovTime}'=='${tempRadioMasterRecovTime}' and ${tempRadioMasterRecovTime_change}
    ...  Log  Parameter tempRadioMasterRecovTime set on BTS non radioMaster: ${BTS_tempRadioMasterRecovTime}, successfully commissioned!
    ...  console=True
    ...  ELSE IF  ${tempRadioMasterRecovTime_change}
    ...  Fail  Parameter tempRadioMasterRecovTime not properly set on BTS non radioMaster
    Run Keyword If  '${BTS_tempRadioMasterTriggerTime}'=='${tempRadioMasterTriggerTime}' and ${tempRadioMasterTriggerTime_change}
    ...  Log  Parameter tempRadioMasterTriggerTime set on BTS non radioMaster: ${BTS_tempRadioMasterTriggerTime}, successfully commissioned!
    ...  console=True
    ...  ELSE IF  ${tempRadioMasterTriggerTime_change}
    ...  Fail  Parameter tempRadioMasterTriggerTime not properly set on BTS non radioMaster

Primary Link TC Parameter Check
    Run Keyword If  '${BTS_PRIMARY_LINK}' not in ['','Master','Slave']  Run Keywords
    ...  Log  For test argument \${BTS_PRIMARY_LINK} let by default value (empty) or set one of following values: Master or Slave  level=ERROR
    ...  AND  Fail  Improper value for argument!

Get Admin Cells And RMs Number From SBTS
    [Documentation]
    ...  Helper keyword providing number of cells and radio modules from WebEM running view.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter  | Mandatory | Description                                                          |
    ...  | alias      | Yes       | Admin instance, Master or Slave                                      |
    ...  | single_BTS | No        | Possible values: True (1 SBTS), False (2 SBTS). Default value: True  |
    ...
    ...  *RETURN*
    ...  | Parameter                   | Description                                 |
    ...  | NR_runtime_cell_number      | WebEM runtime view NR cells number          |
    ...  | LTE_runtime_cell_number     | WebEM runtime view LTE cells number         |
    ...  | LTE_IOT_runtime_cell_number | WebEM runtime view LTE IOT cells number     |
    ...  | WCDMA_runtime_cell_number   | WebEM runtime view WCDMA cells number       |
    ...  | GSM_runtime_cell_number     | WebEM runtime view GSM cells number         |
    ...  | BTS_runtime_rmod_number     | WebEM runtime view BTS radio modules number |

    [Arguments]  ${alias}  ${single_BTS}=True
    ${NR_cell_ids}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    Run Keyword If   '${single_BTS}' == 'True'
    ...  Set Test Variable  ${${${alias.upper()}}[${alias.upper()}_TECH]_NR_cell_ids}  ${NR_cell_ids}
    ...  ELSE
    ...  Set Test Variable  ${${${alias.upper()}}[${alias.upper()}_TECH]_${alias}_NR_cell_ids}  ${NR_cell_ids}
    ${NR_runtime_cell_number}=  Get Length  ${NR_cell_ids}

    ${LTE_cell_ids}  ${LTE_IOT_cell_ids}=  Admin Get LTE CELL Ids list  ${alias}
    Run Keyword If   '${single_BTS}' == 'True'  Run Keywords
    ...  Set Test Variable  ${${${alias.upper()}}[${alias.upper()}_TECH]_LTE_cell_ids}  ${LTE_cell_ids}
    ...  AND  Set Test Variable  ${${${alias.upper()}}[${alias.upper()}_TECH]_LTE_IOT_cell_ids}  ${LTE_IOT_cell_ids}
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${${${alias.upper()}}[${alias.upper()}_TECH]_${alias}_LTE_cell_ids}  ${LTE_cell_ids}
    ...  AND  Set Test Variable  ${${${alias.upper()}}[${alias.upper()}_TECH]_${alias}_LTE_IOT_cell_ids}  ${LTE_IOT_cell_ids}
    ${LTE_runtime_cell_number}=  Get Length  ${LTE_cell_ids}
    ${LTE_IOT_runtime_cell_number}=  Get Length  ${LTE_IOT_cell_ids}

    ${WCDMA_cell_ids}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    Run Keyword If   '${single_BTS}' == 'True'
    ...  Set Test Variable  ${${${alias.upper()}}[${alias.upper()}_TECH]_WCDMA_cell_ids}  ${WCDMA_cell_ids}
    ...  ELSE
    ...  Set Test Variable  ${${${alias.upper()}}[${alias.upper()}_TECH]_${alias}_WCDMA_cell_ids}  ${WCDMA_cell_ids}
    ${WCDMA_runtime_cell_number}=  Get Length  ${WCDMA_cell_ids}

    ${GSM_cell_ids}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Run Keyword If   '${single_BTS}' == 'True'
    ...  Set Test Variable  ${${${alias.upper()}}[${alias.upper()}_TECH]_GSM_cell_ids}  ${GSM_cell_ids}
    ...  ELSE
    ...  Set Test Variable  ${${${alias.upper()}}[${alias.upper()}_TECH]_${alias}_GSM_cell_ids}  ${GSM_cell_ids}
    ${GSM_runtime_cell_number}=  Get Length  ${GSM_cell_ids}

    ${BTS_rmod_ids}=  Get Ids For All  RMOD  alias=${alias}
    Run Keyword If   '${single_BTS}' == 'True'
    ...  Set Test Variable  ${${${alias.upper()}}[${alias.upper()}_TECH]_rmod_ids}  ${BTS_rmod_ids}
    ...  ELSE
    ...  Set Test Variable  ${${${alias.upper()}}[${alias.upper()}_TECH]_${alias}_rmod_ids}  ${BTS_rmod_ids}
    ${BTS_runtime_rmod_number}=  Get Length  ${BTS_rmod_ids}

    [Return]  ${NR_runtime_cell_number}  ${LTE_runtime_cell_number}  ${LTE_IOT_runtime_cell_number}  ${WCDMA_runtime_cell_number}
    ...  ${GSM_runtime_cell_number}  ${BTS_runtime_rmod_number}

SFTP Download SW from remote server and rename
    [Documentation]
    ...  Keyword is downloading given SW build from remote server to local VM through SFTP.
    ...
    ...  *AUTHOR*
    ...  adelina.ivan@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Mandatory | Description                                                     |
    ...  | sw_path               | Yes       | Remote SW path of build to download                             |
    ...  | alias                 | Yes       | Admin instance alias, can be Master, Slave, Slave1, Slave2      |
    ...  | server_ip             | No        | IP Address of remote server; default 10.5.16.71                 |
    ...  | username              | No        | Username of remote server; default nokiatm                      |
    ...  | password              | No        | Password of remote server; default Aikontm9!                    |
    ...
    ...  *RETURN*
    ...  | Parameter  | Description |
    ...  | None       | None        |
    [Arguments]  ${sw_path}  ${alias}  ${tech}=None  ${server_ip}=10.5.16.78  ${username}=userbuild  ${password}=Aikon_123456*8

    ${sw_name_as_list}=  Get Regexp Matches  ${sw_path}  (BTS[M,R][0-9A-Z]{4}\\.[0-9A-Z]{3})
    ${sw_name_other_cases}=  Fetch from Right  ${sw_path}  /
    ${sw_name}=  Set Variable If  '${tech}'=='GSM'  ${sw_name_as_list[0]}  ${sw_name_other_cases}

    ${download_kw_name}=  Set Variable If  '${tech}'=='GSM'  SSHLibrary.Get Directory  SSHLibrary.Get File
    SSHLibrary.Open Connection  ${server_ip}
    SSHLibrary.Login  ${username}  ${password}

    ${file_copying_status}=  Run Keyword And Return Status
    ...  ${download_kw_name}  /sharebuild/${sw_path}  /home/ute/btsauto/TARGET_SW_${alias.upper()}/${sw_name}

    Run Keyword If  '${file_copying_status}'!='False'  Run Keyword
    ...  Log  ${sw_name} was successfully downloaded to local VM  console=True
    ...  ELSE  Fail  ${sw_name} could not be downloaded from remote server
    Set Test Variable  ${Target SW}  /home/ute/btsauto/TARGET_SW_${alias.upper()}/${sw_name}
    Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']  Rename Software Package
    [Teardown]    SSHLibrary.Close Connection

Download T1 T2 or main SW package from server
    [Documentation]
    ...  KW used to download SW packages (T1, T2 or main SW package) based on build used by agent reservation.
    ...  Applicable for 4G/SRAN and 5G builds
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Default                                     | Description                                                  |
    ...  | sw_type             | No   | main                                        | Possible values: T1, T2, main                                |
    ...  | Target_SW_dir       | No   | /home/ute/btsauto/TARGET_SW_MASTER          | Full path where to store the SW.                             |
    ...  | build_to_parse      | No   | ENB                                         | Which build should be downloaded, possible values: ENB,GNB   |
    ...  | preloaded_package   | No   | EMPTY                                       | A different SW build than the one read from reservation logs |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                                                       |
    ...  | sw_file_name full path | Local full path to the downloaded SW

    [Arguments]  ${sw_type}=main  ${Target_SW_dir}=/home/ute/btsauto/TARGET_SW_MASTER  ${preloaded_package}=${EMPTY}

    ${package_name}=  Run Keyword If  '${preloaded_package}'!= '${EMPTY}'  Set Variable  ${preloaded_package}
    ...  ELSE  Check argfile and return target SW

    Set Test Variable  ${Target SW BTS before renaming}  ${package_name}

    ${which_package_name}=  Set Variable If  '${sw_type}' == 'main'  ${False}  ${sw_type}

    ${output}=  WFTDownloader.Download Build From Wft  ${package_name}  ${Target_SW_dir}  ${which_package_name}

    Run  sudo chmod -R 777 ${Target SW dir}
    Log  SW ${package_name} succesfully stored in ${Target_SW_dir}  console=True
    [Return]  ${output}

Check argfile and return target SW
    [Documentation]
    ...  Extracts ENB variable from argfile.txt in order to find initial SW package.
    ...  This KW covers any TL reservation/SR/ZTR initial state of TL
    ...
    ...  *AUTHOR*
    ...  adelina.branc@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                                                       |
    ...  | build_variable         | package parsed from ENB variable                                  |

    ${build_variable}=  Get Variable Value  ${ENB_BUILD}  None
    Run Keyword If  '${build_variable}' == 'None'  Run Keywords
    ...  Log  Could not extract desired SW package value from argfile.txt! Please check its existence!  level=ERROR
    ...  AND  Fail  Could not extract desired SW package value from argfile.txt! Please check its existence!
    [Return]  ${build_variable}

Perform Downgrade via ute-ca
    [Documentation]
    ...  This KW will execute SW downgrade to a chosen base SW at the beginning of robot TC execution.
    ...  *AUTHOR*
    ...  adelina.branc@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Default       | Description                            |
    ...  | sw_build            | Yes  |               | Base SW version                        |
    ...  | required_state      | No   |               | Required state for ute-ca init action  |
    [Arguments]  ${sw_build}=default  ${required_state}=on_air

    FOR  ${alias}  IN  @{alias_list}
        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['GSM']
        Log  Try to start ute-ca agent services on ${alias}  console=True
        Check and start ute-ca agent service  alias=${alias}
    END

    ${tl_topology}=  tools.Get Cm Context Variables  variable=CM_TOPOLOGY_NAME
    ${agent_init_command}=  Create Long String  agentctl exec --mode init --label ${tl_topology} --sm-build ${sw_build}
    ...  --output /home/ute/ca_ute_logs_onair --required-state ${required_state} --variant ${tl_topology}
    Start agent  action=init  command=${agent_init_command}

Check and start ute-ca agent service
    [Documentation]
    ...  KW will ensure ute-ca service is active on all nodes from BTS configuration
    ...  *AUTHOR*
    ...  adelina.branc@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Default       | Description                   |
    ...  | alias               | Yes  |               | Alias of admin instance       |
    [Arguments]  ${alias}=default
    ${ute_ca_start_comand}=  Set Variable  sudo systemctl start ute-ca
    ${ute_ca_start_result}=  Execute on Linux VM  command=${ute_ca_start_comand}  alias=${alias}
    Run Keyword If  '${ute_ca_start_result}' == '0'
    ...  Log  ute-ca service started successfully; return code ${ute_ca_start_result}  console=True
    ...  ELSE  Fail  ute-ca service failed to start; return code ${ute_ca_start_result}
    ${ute_ca_status_comand}=  Set Variable  systemctl status ute-ca
    ${ute_ca_status_result}=  Execute on Linux VM  command=${ute_ca_status_comand}  alias=${alias}
    Run Keyword If  '${ute_ca_status_result}' == '0'
    ...  Log  ute-ca service status is active; return code ${ute_ca_status_result}  console=True
    ...  ELSE  Fail  ute-ca service status failed to be retrieved; return code ${ute_ca_status_result}

Start agent
    [Documentation]
    ...  KW will perform agent repair or agent init on local host
    ...  *AUTHOR*
    ...  adelina.ivan@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Default  | Description                                                       |
    ...  | action              | Yes  |          | Possible val: repair, init                                        |
    ...  | command             | Yes  |          | Agent init or repair command                                      |
    ...  | remote_host_ip      | Yes  |  False   | Flag showing if agent execution will be started locally remotely  |
    [Arguments]  ${action}  ${command}  ${remote_host_ip}=False

    Log  Starting agent ${action} procedure  console=True
    Run Keyword If  '${remote_host_ip}' == 'True'  Run Keywords
    ...  Start agent execution on remote node  action=${action}  command=${command}
    ...  AND  Return From Keyword

    ${result}=  Run Process  ${command}  stdout=STDOUT  stderr=STDOUT  shell=True  timeout=7200  alias=agent_exec
    ${result_terminate}=  Terminate Process  handle=agent_exec  kill=True
    Log  ${result.stdout}  console=True

    OperatingSystem.Create Directory  ${Test Results Dir}/Agent_Logs
    Process.Run Process  cp  -r  /home/ute/.ute-ca/executions  ${Test Results Dir}/Agent_Logs
    Log  agent logs were saved under ${Test Results Dir}/Agent_Logs  console=True

    Run Keyword If  '${result.rc}' != '${0}'
    ...  Fail  Agent ${action} failed!
    ...  ELSE  Log  Agent ${action} was successfully performed!  console=True

Start agent execution on remote node
    [Documentation]
    ...  KW will perform agent repair or agent init on remote host
    ...  *AUTHOR*
    ...  adelina.ivan@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Default       | Description                   |
    ...  | action              | Yes  |               | Possible val: repair, init    |
    ...  | command             | Yes  |               | Agent init or repair command  |
    [Arguments]  ${action}  ${command}

    Log  Starting agent ${action} procedure on remote node  console=True
    SSHLibrary.Open Connection  ${SLAVE['SLAVE_PC_IP_ADDRESS']}
    _SSHLibrary_Login_multiway  ${SLAVE['SLAVE_PC_SSH_USERNAME']}  ${SLAVE['SLAVE_PC_SSH_PASSWORD']}
    #add stderr?
    ${agent_output}  ${agent_err}  ${rc}=  SSHLibrary.Execute Command  ${command}  return_stdout=True  return_stderr=True  return_rc=True
    ...  timeout=7200  output_during_execution=True
    Log  ${agent_output}  console=True
    Run Keyword If  '${rc}' != '${0}'
    ...  Fail  Agent ${action} failed!
    ...  ELSE  Log  Agent ${action} was successfully performed!  console=True
    [Teardown]    SSHLibrary.Close Connection

Get NR first cell up time
    [Documentation]
    ...  KW will calculate and return the time that has passed between NR reset and first NR cell up
    ...  *AUTHOR*
    ...  horea.olar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Default | Description                           |
    ...  | time_nr_initial     | Yes  |         | Time when NR action was finished      |
    ...  | NR_MAX_WAIT_TIME    | Yes  |         | Maximum time to wait for NR BTS OnAir |
    [Arguments]  ${time_nr_initial}  ${NR_MAX_WAIT_TIME}

    Get Current Time  nr_before_check
    ${nr_before_check_elapsed_time}=  DateTime.Subtract Date from Date  ${time_nr_before_check}  ${time_nr_initial}  number
    ${nr_first_cell_up_remained_time}=  BuiltIn.Evaluate  ${NR_MAX_WAIT_TIME}-${nr_before_check_elapsed_time}
    ${nr_first_cell_up_remained_time}=  Set Variable If  ${nr_first_cell_up_remained_time} <= 0  5  ${nr_first_cell_up_remained_time}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${nr_first_cell_up_remained_time}  Master
    Get Current Time  nr_first_cell_up
    ${nr_first_cell_up_elapsed_time}=  DateTime.Subtract Date From Date  ${time_nr_first_cell_up}  ${time_nr_initial}  number
    [Return]   ${nr_first_cell_up_elapsed_time}

Get NR all cells up time
    [Documentation]
    ...  KW will calculate and return the time that has passed between NR reset and all NR cells up
    ...  *AUTHOR*
    ...  horea.olar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                     | Man. | Default | Description                           |
    ...  | time_nr_initial               | Yes  |         | Time when NR action was finished      |
    ...  | nr_first_cell_up_elapsed_time | Yes  |         | Time until first NR cell is up        |
    ...  | NR_MAX_WAIT_TIME              | Yes  |         | Maximum time to wait for NR BTS OnAir |
    [Arguments]  ${time_nr_initial}  ${nr_first_cell_up_elapsed_time}  ${NR_MAX_WAIT_TIME}

    ${nr_last_cell_up_remained_time}=  BuiltIn.Evaluate  ${NR_MAX_WAIT_TIME}-${nr_first_cell_up_elapsed_time}
    ${nr_last_cell_up_remained_time}=  Set Variable If  ${nr_last_cell_up_remained_time} <= 0  5  ${nr_last_cell_up_remained_time}
    Assert Every  NRCEL  blockingState=${Unblocked_}, operationalState=${Enabled_}  timeout=${nr_last_cell_up_remained_time}  alias=Master
    Get Current Time  nr_last_cell_up
    ${nr_all_cells_up_elapsed_time}=  DateTime.Subtract Date From Date  ${time_nr_last_cell_up}  ${time_nr_initial}  number
    [Return]   ${nr_all_cells_up_elapsed_time}

Check KPI
    [Documentation]
    ...  KW will compare the time between action and all cells up with maximum value of KPI
    ...  In case the time exceeds the value a warning will be raised and snapshot wil be triggered
    ...  *AUTHOR*
    ...  horea.olar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter    | Man. | Default | Description                                        |
    ...  | elapsed_time | Yes  |         | Time passed from NR action                         |
    ...  | kpi_time     | Yes  |         | Maximum value of KPI (if passed warning is raised) |
    [Arguments]  ${elapsed_time}  ${kpi_time}

    Log  Checking KPI  console=True
    Run Keyword If  ${elapsed_time} > ${kpi_time}  Run Keywords
    ...  Log  Not all cells were up after ${kpi_time}s!  level=WARN
    ...  AND  Set KPI Check Level Based on Execution Environment  ${kpi_time}
    ...  AND  Set Test Variable  ${SnapshotTriggerEndTest}  YES

Get NR txPathFailureMode from SCF
    [Documentation]
    ...  Keyword providing NR txPathFailureMode value from SCF.
    ...
    ...  *AUTHOR*
    ...  anca.tatar@nokia.com
    ...
    ...  | Parameter | Man. | Description          |
    ...  | scf_path  | No   | scf path             |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description     |
    ...  | txPathFailureMode | parameter value |
    ...
    [Arguments]  ${scf_path}=${EMPTY}  ${alias}=default

    ${scf_path}=  Set Variable If  '${scf_path}' == '${EMPTY}'  ${${alias.lower()}_scf_initial}  ${scf_path}
    OperatingSystem.File Should Exist  ${scf_path}
    ${nrbts_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRBTS-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${nrbts_dn}=  Get From List  ${nrbts_dn_list}  0

    ${txPathFailureMode}=  Check Parameter value from SCF  item_dist_name=${nrbts_dn}  parameter_to_check=txPathFailureMode
    ...  scf_path=${scf_path}

    [Return]  ${txPathFailureMode}

Check NR cells state and MIMO alarm
    [Arguments]  ${cell_list}=@{EMPTY}  ${antenna}=external  ${alias}=default
    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    ${NR_cell_state_degraded_list}=  Create List
    ${NR_cell_state_failed_list}=  Create List
    ${txPathFailureMode}=  Get NR txPathFailureMode from SCF  alias=${alias}
    ${NR_CELL_info}=  rfs_admin.Admin Get NR CELL list with cell info  cell_list=${cell_list}  alias=${alias}
    FOR  ${item}  IN  @{NR_CELL_info}
        Run Keyword If  '${item[1]}' == 'True'
        ...  Calculate NR supercells state and MIMO alarms  ${item[0]}  ${item[2]}  ${item[4]}  ${item[5]}  ${item[6]}
        ...  ${item[7]}  ${item[9]}  ${item[12]}  ${item[13]}  ${item[14]}  alias=${alias}
        ...  ELSE IF  ${item[5]} == 0
        ...  Calculate NR SDL cells state and MIMO alarms  ${item[0]}  ${item[2]}  ${item[3]}  ${item[4]}  ${item[6]}  ${item[8]}
        ...  ${item[12]}  ${txPathFailureMode}
        ...  antenna=${antenna}  alias=${alias}
        ...  ELSE
        ...  Calculate NR cells state and MIMO alarms  ${item[0]}  ${item[2]}  ${item[3]}  ${item[4]}  ${item[5]}  ${item[6]}  ${item[7]}
        ...  ${item[8]}  ${item[9]}  ${item[10]}  ${item[11]}  ${item[12]}  ${item[13]}  ${txPathFailureMode}  antenna=${antenna}
        ...  alias=${alias}
        Run Keyword If  '${MIMO_CELL_STATE}' == 'Degraded'
        ...  Append To List  ${NR_cell_state_degraded_list}  ${item[0]}
        ...  ELSE IF  '${MIMO_CELL_STATE}' == 'Failed'
        ...  Append To List  ${NR_cell_state_failed_list}  ${item[0]}
        Add MIMO alarms to list  ${ALARM_COUNT_MIMO}  ${ALARM_COUNT_MIMO_CELL}
    END
    Set Test Variable  ${ALARM_COUNT_MIMO}

    [Return]  ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}

Calculate NR supercells state and MIMO alarms
    [Arguments]  ${id}  ${actBeamforming}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}
    ...  ${RX_Failed}  ${TX_Dependency}  ${RX_Dependency}  ${CELL_TX_RX_dictionary}  ${alias}=default

    ${cell_online_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_dependency_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Dependency_}, blockingState=${Unblocked_}
    ${cell_online}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_dependency}=  Set Variable  operationalState=Disabled, availabilityStatus=Dependency, blockingState=Unblocked

    ${channel_group_TX_Total_list}=  Create List
    ${channel_group_TX_Online_list}=  Create List
    ${channel_group_RX_Online_list}=  Create List
    ${channel_group_TX_Failed_list}=  Create List
    ${channel_group_TX_Degraded_list}=  Create List
    ${channel_group_RX_Degraded_list}=  Create List
    ${CELL_TX_RX_dictionary_keys}=  Get Dictionary Keys  ${CELL_TX_RX_dictionary}
    ${CELL_TX_RX_dictionary_values}=  Get Dictionary Values  ${CELL_TX_RX_dictionary}
    FOR  ${key}  ${value}  IN ZIP  ${CELL_TX_RX_dictionary_keys}  ${CELL_TX_RX_dictionary_values}
        ${TX_Total_element}=  Get From List  ${value}  0
        Append To List  ${channel_group_TX_Total_list}   ${TX_Total_element}
        ${TX_Online_element}=  Get From List  ${value}  2
        Append To List  ${channel_group_TX_Online_list}   ${TX_Online_element}
        ${RX_Online_element}=  Get From List  ${value}  3
        Append To List  ${channel_group_RX_Online_list}   ${RX_Online_element}
        ${TX_Failed_element}=  Get From List  ${value}  4
        Append To List  ${channel_group_TX_Failed_list}   ${TX_Failed_element}
        ${TX_Degraded_element}=  Get From List  ${value}  6
        Append To List  ${channel_group_TX_Degraded_list}   ${TX_Degraded_element}
        ${RX_Degraded_element}=  Get From List  ${value}  7
        Append To List  ${channel_group_RX_Degraded_list}   ${RX_Degraded_element}
    END

    Run Keyword If  ${TX_Online} == ${TX_Total} and ${RX_Online} == ${RX_Total}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_online_check}  ${cell_online}  ${alias}  0
    ...  ELSE IF  ${RX_Failed} == ${RX_Total}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Dependency} and ${RX_Total} == ${RX_Dependency}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_dependency_check}  ${cell_dependency}  ${alias}  0
    ...  ELSE IF  '${actBeamforming}' == 'false'
    ...  Check NR supercell configuration without beamforming  ${id}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}
    ...  ${channel_group_TX_Total_list}  ${channel_group_TX_Online_list}  ${channel_group_RX_Online_list}  ${channel_group_TX_Failed_list}
    ...  ${channel_group_TX_Degraded_list}  ${channel_group_RX_Degraded_list}  ${alias}
    ...  ELSE  Run Keywords
    ...  Log  No condition for ${alias} NRCEL ${id} status was met. Please contact TA team.  console=True  level=WARN
    ...  AND  Set Test Variable  ${MIMO_CELL_STATE}  False

Calculate NR SDL cells state and MIMO alarms
    [Arguments]  ${id}  ${actBeamforming}  ${numOfSubSectors}  ${TX_Total}  ${TX_Online}  ${TX_Failed}  ${TX_Dependency}
    ...  ${txPathFailureMode}  ${antenna}=external  ${alias}=default

    ${cell_online_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_dependency_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Dependency_}, blockingState=${Unblocked_}
    ${cell_online}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_dependency}=  Set Variable  operationalState=Disabled, availabilityStatus=Dependency, blockingState=Unblocked

    Run Keyword If  ${TX_Online} == ${TX_Total}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_online_check}  ${cell_online}  ${alias}  0
    ...  ELSE IF  ${TX_Failed} == ${TX_Total}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Dependency}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_dependency_check}  ${cell_dependency}  ${alias}  0
    ...  ELSE IF  '${antenna}' == 'external' and '${actBeamforming}' == 'false'
    ...  Check NR SDL cells configured on RM with external antenna lines without beamforming  ${id}  ${TX_Total}  ${TX_Online}  ${TX_Failed}
    ...  ${txPathFailureMode}  ${alias}
    ...  ELSE IF  '${antenna}' == 'external' and '${actBeamforming}' == 'true' and '${numOfSubSectors}' == '0sub-sector'
    ...  Check NR SDL cells configured on RM with external antenna lines with beamforming without subsectors  ${id}  ${TX_Total}  ${TX_Failed}
    ...  ${alias}
    ...  ELSE IF  '${antenna}' == 'external' and '${actBeamforming}' == 'true' and '${numOfSubSectors}' != '0sub-sector'
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1
    ...  ELSE IF  '${antenna}' == 'integrated' and '${actBeamforming}' == 'true'
    ...  Check NR SDL cells configured on RM with integrated antenna lines with beamforming  ${id}  ${TX_Failed}  ${alias}

Calculate NR cells state and MIMO alarms
    [Arguments]  ${id}  ${actBeamforming}  ${numOfSubSectors}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}
    ...  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}  ${TX_Dependency}  ${RX_Dependency}  ${txPathFailureMode}
    ...  ${antenna}=external  ${alias}=default

    ${cell_online_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_dependency_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Dependency_}, blockingState=${Unblocked_}
    ${cell_online}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_dependency}=  Set Variable  operationalState=Disabled, availabilityStatus=Dependency, blockingState=Unblocked

    Run Keyword If  ${TX_Online} == ${TX_Total} and ${RX_Online} == ${RX_Total}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_online_check}  ${cell_online}  ${alias}  0
    ...  ELSE IF  ${TX_Degraded} == ${TX_Total} and ${RX_Degraded} == ${RX_Total}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  0
    ...  ELSE IF  ${TX_Failed} == ${TX_Total} or ${RX_Failed} == ${RX_Total}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Dependency} and ${RX_Total} == ${RX_Dependency}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_dependency_check}  ${cell_dependency}  ${alias}  0
    ...  ELSE IF  '${antenna}' == 'external' and '${actBeamforming}' == 'false'
    ...  Check NR cells configured on RM with external antenna lines without beamforming  ${id}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}
    ...  ${TX_Failed}  ${txPathFailureMode}  ${alias}
    ...  ELSE IF  '${antenna}' == 'external' and '${actBeamforming}' == 'true' and '${numOfSubSectors}' == '0sub-sector'
    ...  Check NR cells configured on RM with external antenna lines with beamforming without subsectors  ${id}  ${TX_Total}  ${RX_Total}
    ...  ${TX_Failed}  ${RX_Failed}  ${alias}
    ...  ELSE IF  '${antenna}' == 'external' and '${actBeamforming}' == 'true' and '${numOfSubSectors}' != '0sub-sector'
    ...  Check NR cells configured on RM with external antenna lines with beamforming with subsectors  ${id}  ${TX_Total}  ${RX_Total}  ${TX_Failed}
    ...  ${RX_Failed}  ${alias}
    ...  ELSE IF  '${antenna}' == 'integrated' and '${actBeamforming}' == 'true'
    ...  Check NR cells configured on RM with integrated antenna lines with beamforming  ${id}  ${TX_Failed}  ${RX_Failed}  ${alias}
    ...  ELSE  Run Keywords
    ...  Log  No condition for ${alias} NRCEL ${id} status was met. Please contact TA team.  console=True  level=WARN
    ...  AND  Set Test Variable  ${MIMO_CELL_STATE}  False

Check NR supercell configuration without beamforming
    [Documentation]
    ...  Helper keyword for Calculate NR supercells state and MIMO alarms; 5G supercells conditions lines 121 to 125

    [Arguments]  ${id}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${channel_group_TX_Total_list}  ${channel_group_TX_Online_list}
    ...  ${channel_group_RX_Online_list}  ${channel_group_TX_Failed_list}  ${channel_group_TX_Degraded_list}  ${channel_group_RX_Degraded_list}
    ...  ${alias}

    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked

    ${condition1}=  Set Variable  ${TX_Total} != ${TX_Online}
    FOR  ${element1}  ${element2}  ${element3}  IN ZIP  ${channel_group_TX_Total_list}  ${channel_group_TX_Online_list}
        ...  ${channel_group_TX_Degraded_list}
        Run Keyword If  ${condition1} and (${element1} == ${element2} or ${element1} == ${element3}) and ${RX_Online} == ${RX_Total}  Run Keywords
        ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  0
        ...  AND  Return From Keyword
    END

    FOR  ${element1}  ${element2}  ${element3}  ${element4}  ${element5}  IN ZIP  ${channel_group_TX_Total_list}  ${channel_group_TX_Online_list}
        ...  ${channel_group_TX_Degraded_list}  ${channel_group_RX_Online_list}  ${channel_group_RX_Degraded_list}
        Run Keyword If  (${element1} == ${element2} or ${element1} == ${element3}) and (${element4} >= 1 or ${element5} >= 1)  Run Keywords
        ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  0
        ...  AND  Return From Keyword
    END

    ${status}=  Create List
    FOR  ${element1}  ${element2}  ${element3}  ${element4}  ${element5}  IN ZIP  ${channel_group_TX_Total_list}  ${channel_group_TX_Online_list}
        ...  ${channel_group_TX_Degraded_list}  ${channel_group_RX_Online_list}  ${channel_group_RX_Degraded_list}
        Run Keyword If  (${element1} == ${element2} or ${element1} == ${element3}) and (${element4} >= 1 or ${element5} >= 1)
        ...  Append To List  ${status}  True
        ...  ELSE  Append To List  ${status}  False
    END
    ${length}=  Get Length  ${status}
    ${count}=  Get Count  ${status}  False
    Run Keyword If  ${count} == ${length}  Run Keywords
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  AND  Return From Keyword

    ${status}=  Create List
    FOR  ${element}  IN ZIP  ${channel_group_TX_Failed_list}
        Run Keyword If  ${element} >= 1
        ...  Append To List  ${status}  True
        ...  ELSE  Append To List  ${status}  False
    END
    ${length}=  Get Length  ${status}
    ${count}=  Get Count  ${status}  True
    Run Keyword If  ${count} == ${length}  Run Keywords
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  AND  Return From Keyword

Check NR SDL cells configured on RM with external antenna lines without beamforming
    [Documentation]
    ...  Helper keyword for Calculate NR SDL cells state and MIMO alarms

    [Arguments]  ${id}  ${TX_Total}  ${TX_Online}  ${TX_Failed}  ${txPathFailureMode}  ${alias}

    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked

    Run Keyword If  '${txPathFailureMode}' == '${None}' and ${TX_Failed} > 1
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  '${txPathFailureMode}' == '${None}'
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1
    ...  ELSE IF  ${TX_Failed} >= 1 and '${txPathFailureMode}' == 'disableCell'
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  ${TX_online} != ${TX_Total} and ${TX_online} >= 1 and '${txPathFailureMode}' == 'keepCellInService'
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1

Check NR SDL cells configured on RM with external antenna lines with beamforming without subsectors
    [Documentation]
    ...  Helper keyword for Calculate NR SDL cells state and MIMO alarms

    [Arguments]  ${id}  ${TX_Total}  ${TX_Failed}  ${alias}

    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked

    ${TX_limit}=  Evaluate  ${TX_Total}%8
    Run Keyword If  ${TX_Failed} > ${TX_limit}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1

Check NR SDL cells configured on RM with integrated antenna lines with beamforming
    [Documentation]
    ...  Helper keyword for Calculate NR SDL cells state and MIMO alarms

    [Arguments]  ${id}  ${TX_Failed}  ${alias}

    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked

    Run Keyword If  ${TX_Failed} >= 1
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1

Check NR cells configured on RM with external antenna lines without beamforming
    [Documentation]
    ...  Helper keyword for Calculate NR cells state and MIMO alarms

    [Arguments]  ${id}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${txPathFailureMode}  ${alias}

    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked

    ${condition1}=  Create Long String  ${TX_online} == ${TX_Total} and ${RX_online} != ${RX_Total} and ${RX_online} >= 1 and
    ...  ('${txPathFailureMode}' == 'disableCell' or '${txPathFailureMode}' == 'keepCellInService')
    ${condition2}=  Create Long String  ${TX_online} != ${TX_Total} and ${TX_online} >= 1 and ${RX_online} == ${RX_Total} and
    ...  '${txPathFailureMode}' == 'keepCellInService'
    ${condition3}=  Create Long String  ${TX_online} != ${TX_Total} and ${TX_online} >= 1 and ${RX_online} != ${RX_Total} and ${RX_online} >= 1 and
    ...  '${txPathFailureMode}' == 'keepCellInService'

    Run Keyword If  '${txPathFailureMode}' == '${None}' and (${TX_Failed} > 1 or ${RX_Failed} > 1)
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  '${txPathFailureMode}' == '${None}'
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1
    ...  ELSE IF  ${TX_Failed} >= 1 and '${txPathFailureMode}' == 'disableCell'
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  ${condition1}  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1
    ...  ELSE IF  ${condition2}  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1
    ...  ELSE IF  ${condition3}  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1

Check NR cells configured on RM with external antenna lines with beamforming without subsectors
    [Documentation]
    ...  Helper keyword for Calculate NR cells state and MIMO alarms

    [Arguments]  ${id}  ${TX_Total}  ${RX_Total}  ${TX_Failed}  ${RX_Failed}  ${alias}

    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked

    ${TX_limit}=  Evaluate  ${TX_Total}%8
    ${RX_limit}=  Evaluate  ${RX_Total}%8
    Run Keyword If  ${TX_Failed} > ${TX_limit} or ${RX_Failed} > ${RX_limit}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1

Check NR cells configured on RM with external antenna lines with beamforming with subsectors
    [Documentation]
    ...  Helper keyword for Calculate NR cells state and MIMO alarms

    [Arguments]  ${id}  ${TX_Total}  ${RX_Total}  ${TX_Failed}  ${RX_Failed}  ${alias}

    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked

    Run Keyword If  ${TX_Failed} == ${TX_Total} and ${RX_Failed} == ${RX_Total}
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1

Check NR cells configured on RM with integrated antenna lines with beamforming
    [Documentation]
    ...  Helper keyword for Calculate NR cells state and MIMO alarms

    [Arguments]  ${id}  ${TX_Failed}  ${RX_Failed}  ${alias}

    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked

    Run Keyword If  ${TX_Failed} >= 1 or ${RX_Failed} >= 1
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1

Check Cell State and MIMO alarm
    [Arguments]  ${cell_class_name}  ${id}  ${cell_state_check}  ${cell_state}  ${alias}  ${alarm_count_mimo}

    Assert  class_name=${cell_class_name}  id=${id}  parameters=${cell_state_check}  connection=${alias}
    Log  BTS ${alias} ${cell_class_name} ${id} status:\n - ${cell_state}  console=True

    Run Keyword If  'Failed' in '${cell_state_check}'
    ...  Set Test Variable  ${MIMO_CELL_STATE}  Failed
    ...  ELSE IF  'Degraded' in '${cell_state_check}'
    ...  Set Test Variable  ${MIMO_CELL_STATE}  Degraded
    ...  ELSE IF  'Dependency' in '${cell_state_check}'
    ...  Set Test Variable  ${MIMO_CELL_STATE}  Dependency
    ...  ELSE  Set Test Variable  ${MIMO_CELL_STATE}  Enabled

    Set Test Variable  ${ALARM_COUNT_MIMO_CELL}  ${alarm_count_mimo}

Get LTE txPathFailureMode from SCF
    [Documentation]
    ...  Keyword providing LTE txPathFailureMode value from SCF.
    ...
    ...  *AUTHOR*
    ...  anca.tatar@nokia.com
    ...
    ...  | Parameter | Man. | Description          |
    ...  | scf_path  | No   | scf path             |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description     |
    ...  | txPathFailureMode | parameter value |
    ...
    [Arguments]  ${scf_path}=${EMPTY}  ${alias}=default

    ${scf_path}=  Set Variable If  '${scf_path}' == '${EMPTY}'  ${${alias.lower()}_scf_initial}  ${scf_path}
    OperatingSystem.File Should Exist  ${scf_path}
    ${lnbts_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/LNBTS-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${lnbts_dn}=  Get From List  ${lnbts_dn_list}  0
    Set Test Variable  ${lnbts_dn}

    ${txPathFailureMode}=  Check Parameter value from SCF  item_dist_name=${lnbts_dn}  parameter_to_check=txPathFailureMode
    ...  scf_path=${scf_path}

    [Return]  ${txPathFailureMode}

Check LTE cells state and MIMO alarm
    [Arguments]  ${cell_list}=@{EMPTY}  ${alias}=default
    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    ${LTE_cell_state_degraded_list}=  Create List
    ${LTE_cell_state_failed_list}=  Create List
    ${txPathFailureMode}=  Get LTE txPathFailureMode from SCF  alias=${alias}
    ${LTE_CELL_info}=  rfs_admin.Admin Get LTE CELL list with cell info  cell_list=${cell_list}  alias=${alias}
    FOR  ${item}  IN  @{LTE_CELL_info}
        Run Keyword If  '${item[1]}' == 'True'
        ...  Calculate LTE supercells state and MIMO alarms  ${item[0]}  ${item[1]}
        ...  ${item[6]}  ${item[7]}  ${item[8]}  ${item[9]}  ${item[10]}  ${item[11]}  ${item[14]}   ${item[15]}
        ...  ${item[16]}  ${alias}
        ...  ELSE
        ...  Calculate LTE cells state and MIMO alarms  ${item[0]}  ${item[2]}  ${item[3]}  ${item[4]}  ${item[5]}
        ...  ${item[6]}  ${item[7]}  ${item[8]}  ${item[9]}  ${item[10]}  ${item[11]}  ${item[12]}  ${item[13]}   ${item[14]}   ${item[15]}
        ...  ${txPathFailureMode}  ${alias}
        Run Keyword If  '${MIMO_CELL_STATE}' == 'Degraded'
        ...  Append To List  ${LTE_cell_state_degraded_list}  ${item[0]}
        ...  ELSE IF  '${MIMO_CELL_STATE}' == 'Failed'
        ...  Append To List  ${LTE_cell_state_failed_list}  ${item[0]}
        Add MIMO alarms to list  ${ALARM_COUNT_MIMO}  ${ALARM_COUNT_MIMO_CELL}
    END
    Set Test Variable  ${ALARM_COUNT_MIMO}

    [Return]  ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}

Calculate LTE supercells state and MIMO alarms
    [Arguments]  ${id}  ${actSuperCell}  ${TX_Total}  ${RX_Total}  ${TX_Online}
    ...  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Dependency}  ${RX_Dependency}  ${CELL_TX_RX_dictionary}
    ...  ${alias}

    ${cell_online_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_dependency_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Dependency_}, blockingState=${Unblocked_}
    ${cell_online}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_dependency}=  Set Variable  operationalState=Disabled, availabilityStatus=Dependency, blockingState=Unblocked

    ${channel_group_TX_Total_list}=  Create List
    ${channel_group_TX_Online_list}=  Create List
    ${channel_group_RX_Online_list}=  Create List
    ${channel_group_TX_Failed_list}=  Create List
    ${channel_group_TX_Degraded_list}=  Create List
    ${channel_group_RX_Degraded_list}=  Create List
    ${CELL_TX_RX_dictionary_keys}=  Get Dictionary Keys  ${CELL_TX_RX_dictionary}
    ${CELL_TX_RX_dictionary_values}=  Get Dictionary Values  ${CELL_TX_RX_dictionary}
    FOR  ${key}  ${value}  IN ZIP  ${CELL_TX_RX_dictionary_keys}  ${CELL_TX_RX_dictionary_values}
        ${TX_Total_element}=  Get From List  ${value}  0
        Append To List  ${channel_group_TX_Total_list}   ${TX_Total_element}
        ${TX_Online_element}=  Get From List  ${value}  2
        Append To List  ${channel_group_TX_Online_list}   ${TX_Online_element}
        ${RX_Online_element}=  Get From List  ${value}  3
        Append To List  ${channel_group_RX_Online_list}   ${RX_Online_element}
        ${TX_Failed_element}=  Get From List  ${value}  4
        Append To List  ${channel_group_TX_Failed_list}   ${TX_Failed_element}
        ${TX_Degraded_element}=  Get From List  ${value}  6
        Append To List  ${channel_group_TX_Degraded_list}   ${TX_Degraded_element}
        ${RX_Degraded_element}=  Get From List  ${value}  7
        Append To List  ${channel_group_RX_Degraded_list}   ${RX_Degraded_element}
    END

    Run Keyword If  ${TX_Online} == ${TX_Total} and ${RX_Online} == ${RX_Total}
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_online_check}  ${cell_online}  ${alias}  0
    ...  ELSE IF  ${TX_Failed} == ${TX_Total} or ${RX_Failed} == ${RX_Total}
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Dependency} and ${RX_Total} == ${RX_Dependency}
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_dependency_check}  ${cell_dependency}  ${alias}  0
    ...  ELSE IF  '${actSuperCell}' == 'true'  Check LTE supercell configuration  ${id}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}
    ...  ${channel_group_TX_Total_list}  ${channel_group_TX_Online_list}  ${channel_group_RX_Online_list}  ${channel_group_TX_Failed_list}
    ...  ${channel_group_TX_Degraded_list}  ${channel_group_RX_Degraded_list}  ${alias}
    ...  ELSE  Run Keywords
    ...  Log  No condition for ${alias} LNCEL ${id} status was met. Please contact TA team.  console=True  level=WARN
    ...  AND  Set Test Variable  ${MIMO_CELL_STATE}  False

Calculate LTE cells state and MIMO alarms
    [Arguments]  ${id}  ${dlMimoMode}  ${syncSigTxMod}  ${actOtdoa}  ${actPrsTxDiv}  ${TX_Total}  ${RX_Total}  ${TX_Online}
    ...  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}  ${TX_Dependency}  ${RX_Dependency}
    ...  ${txPathFailureMode}  ${alias}

    ${cell_online_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_dependency_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Dependency_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_online}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_dependency}=  Set Variable  operationalState=Disabled, availabilityStatus=Dependency, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked
    ${TX_Working}=  Evaluate  ${TX_Online} + ${TX_Degraded}
    ${RX_Working}=  Evaluate  ${RX_Online} + ${RX_Degraded}

    ${contition1}=  Create Long String  ${TX_Total} != ${TX_Online} and ${TX_Working} >= 1 and '${txPathFailureMode}' == 'keepCellInService' and
    ...  '${syncSigTxMod}' == 'TxDiv'

    Run Keyword If  ${TX_Total} == ${TX_Online} and ${RX_Total} == ${RX_Online}
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_online_check}  ${cell_online}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Failed}
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Dependency} and ${RX_Total} == ${RX_Dependency}
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_dependency_check}  ${cell_dependency}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Online} and ${RX_Total} != ${RX_Online} and ${RX_Working} >= 1
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1
    ...  ELSE IF  ${contition1}
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1
    ...  ELSE IF  '${txPathFailureMode}' == 'keepCellInService' and '${dlMimoMode}' != 'SingleTX' and '${syncSigTxMod}' == 'TxDiv'
    ...  Check LTE cells with txPathFailureMode set on keepCellInService and dlMimoMode other than SingleTX and syncSigTxMod set on TxDiv  ${id}
    ...  ${actOtdoa}  ${actPrsTxDiv}  ${TX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}
    ...  ${TX_Dependency}  ${RX_Dependency}  ${alias}
    ...  ELSE IF  '${txPathFailureMode}' == 'keepCellInService' and '${syncSigTxMod}' == 'SingleTx'
    ...  Check LTE cells with txPathFailureMode set on keepCellInService and syncSigTxMod set on SingleTx  ${id}  ${alias}
    ...  ELSE IF  '${txPathFailureMode}' == 'disableCell'
    ...  Check LTE cells with txPathFailureMode set on disableCell  ${id}  ${TX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Degraded}  ${RX_Degraded}
    ...  ${alias}
    ...  ELSE  Run Keywords
    ...  Log  No condition for ${alias} LNCEL ${id} status was met. Please contact TA team.  console=True  level=WARN
    ...  AND  Set Test Variable  ${MIMO_CELL_STATE}  False

Check LTE supercell configuration
    [Documentation]
    ...  Helper keyword for Calculate LTE supercells state and MIMO alarms; TDD Supercell configuration conditions lines 5 to 9

    [Arguments]  ${id}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${channel_group_TX_Total_list}  ${channel_group_TX_Online_list}
    ...  ${channel_group_RX_Online_list}  ${channel_group_TX_Failed_list}  ${channel_group_TX_Degraded_list}  ${channel_group_RX_Degraded_list}
    ...  ${alias}

    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked

    ${condition1}=  Set Variable  ${TX_Total} != ${TX_Online}
    FOR  ${element1}  ${element2}  ${element3}  IN ZIP  ${channel_group_TX_Total_list}  ${channel_group_TX_Online_list}
        ...  ${channel_group_TX_Degraded_list}
        Run Keyword If  ${condition1} and (${element1} == ${element2} or ${element1} == ${element3}) and ${RX_Online} == ${RX_Total}  Run Keywords
        ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  0
        ...  AND  Return From Keyword
    END

    FOR  ${element1}  ${element2}  IN ZIP  ${channel_group_RX_Online_list}  ${channel_group_RX_Degraded_list}
        Run Keyword If  ${TX_Total} == ${TX_Online} and ${RX_Total} != ${RX_Online} and (${element1} >= 1 or ${element2} >= 1)  Run Keywords
        ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  0
        ...  AND  Return From Keyword
    END

    ${condition2}=  Set Variable  ${TX_Total} != ${TX_Online} and ${RX_Total} != ${RX_Online}
    FOR  ${element1}  ${element2}  ${element3}  ${element4}  ${element5}  IN ZIP  ${channel_group_TX_Total_list}  ${channel_group_TX_Online_list}
    ...  ${channel_group_TX_Degraded_list}  ${channel_group_RX_Online_list}  ${channel_group_RX_Degraded_list}
        Run Keyword If   ${condition2} and (${element1} == ${element2} or ${element1} == ${element3}) and (${element4} >= 1 or ${element5} >= 1)
        ...  Run Keywords  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  0
        ...  AND  Return From Keyword
    END

    ${status}=  Create List
    FOR  ${element1}  ${element2}  ${element3}  ${element4}  ${element5}  IN ZIP  ${channel_group_TX_Total_list}  ${channel_group_TX_Online_list}
        ...  ${channel_group_TX_Degraded_list}  ${channel_group_RX_Online_list}  ${channel_group_RX_Degraded_list}
        Run Keyword If  ${condition2} and (${element1} == ${element2} or ${element1} == ${element3}) and (${element4} >= 1 or ${element5} >= 1)
        ...  Append To List  ${status}  True
        ...  ELSE  Append To List  ${status}  False
    END
    ${length}=  Get Length  ${status}
    ${count}=  Get Count  ${status}  False
    Run Keyword If  ${count} == ${length}  Run Keywords
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  AND  Return From Keyword

    ${status}=  Create List
    FOR  ${element}  IN ZIP  ${channel_group_TX_Failed_list}
        Run Keyword If  ${element} >= 1
        ...  Append To List  ${status}  True
        ...  ELSE  Append To List  ${status}  False
    END
    ${length}=  Get Length  ${status}
    ${count}=  Get Count  ${status}  True
    Run Keyword If  ${count} == ${length}  Run Keywords
    ...  Check Cell State and MIMO alarm  NRCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  AND  Return From Keyword

Check LTE cells with txPathFailureMode set on keepCellInService and dlMimoMode other than SingleTX and syncSigTxMod set on TxDiv
    [Documentation]
    ...  Helper keyword for Calculate LTE cells state and MIMO alarms; FDD and TDD configuration (excluding TDD Supercell configuration)
    ...  lines 7 to 12
    [Arguments]  ${id}  ${actOtdoa}  ${actPrsTxDiv}  ${TX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}
    ...  ${RX_Degraded}  ${TX_Dependency}  ${RX_Dependency}  ${alias}

    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_dependency_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Dependency_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_dependency}=  Set Variable  operationalState=Disabled, availabilityStatus=Dependency, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked
    ${TX_Working}=  Evaluate  ${TX_Online} + ${TX_Degraded}
    ${RX_Working}=  Evaluate  ${RX_Online} + ${RX_Degraded}

    ${condition1}=  Create Long String  ${TX_Total} != 8 and ${TX_Total} != 4 and ${TX_Total} != ${TX_Online} and ${TX_Working} >= 1 and
    ...  ${RX_Working} >= 1 and '${actOtdoa}' == 'True' and '${actPrsTxDiv}' == 'True'
    ${condition2}=  Create Long String  ${TX_Total} != 8 and ${TX_Total} != 4 and ${TX_Total} != ${TX_Online} and ${TX_Working} >= 1 and
    ...  ${RX_Working} >=1 and '${actOtdoa}' == 'True' and '${actPrsTxDiv}' == 'False'
    ${condition3}=  Create Long String  ${TX_Total} != 8 and ${TX_Total} != 4 and ${TX_Total} != ${TX_Online} and ${TX_Working} >= 1 and
    ...  ${RX_Working} >=1 and '${actOtdoa}' == 'False'
    ${condition4}=  Create Long String  ${TX_Total} == 4 and ${TX_Total} != ${TX_Online} and ${TX_Working} >= 3 and ${RX_Working} >= 1 and
    ...  '${actOtdoa}' =='True' and '${actPrsTxDiv}' == 'True'
    ${condition5}=  Create Long String  ${TX_Total} == 4 and ${TX_Total} != ${TX_Online} and ${TX_Working} >= 3 and ${RX_Working} >= 1 and
    ...  '${actOtdoa}' == 'True' and '${actPrsTxDiv}' == 'False'

    Run Keyword If  ${condition1}  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1
    ...  ELSE IF  ${condition2} and (${TX_Failed} > 0 or ${RX_Failed} > 0)
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  ${condition2} and (${TX_Dependency} > 0 or ${RX_Dependency} > 0)
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_dependency_check}  ${cell_dependency}  ${alias}  0
    ...  ELSE IF  ${condition3}  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1
    ...  ELSE IF  ${condition4}  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1
    ...  ELSE IF  ${condition5} and (${TX_Failed} > 0 or ${RX_Failed} > 0)
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  ${condition5} and (${TX_Dependency} > 0 or ${RX_Dependency} > 0)
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_dependency_check}  ${cell_dependency}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == 4 and ${TX_Total} != ${TX_Online} and ${TX_Working} >= 3 and ${RX_Working} >= 1 and '${actOtdoa}' == 'False'
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1

Check LTE cells with txPathFailureMode set on keepCellInService and syncSigTxMod set on SingleTx
    [Documentation]
    ...  Helper keyword for Calculate LTE cells state and MIMO alarms; FDD and TDD configuration (excluding TDD Supercell configuration)
    ...  line 6, lines 14 to 17, lines 20-21
    [Arguments]  ${id}  ${alias}

    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_dependency_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Dependency_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_dependency}=  Set Variable  operationalState=Disabled, availabilityStatus=Dependency, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked

    ${result}=  Assert  class_name=LNCEL  id=${id}  connection=${alias}

    Run Keyword If  '${result['availabilityStatus']}' in '${Degraded_}'
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1
    Run Keyword If  '${result['availabilityStatus']}' in '${Failed_}'
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    Run Keyword If  '${result['availabilityStatus']}' in '${Dependency_}'
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_dependency_check}  ${cell_dependency}  ${alias}  0

Check LTE cells with txPathFailureMode set on disableCell
    [Documentation]
    ...  Helper keyword for Calculate LTE cells state and MIMO alarms; FDD and TDD configuration (excluding TDD Supercell configuration)
    ...  lines from 18 to 19
    [Arguments]  ${id}  ${TX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Degraded}  ${RX_Degraded}  ${alias}

    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_dependency_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Dependency_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_dependency}=  Set Variable  operationalState=Disabled, availabilityStatus=Dependency, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked
    ${TX_Working}=  Evaluate  ${TX_Online} + ${TX_Degraded}
    ${RX_Working}=  Evaluate  ${RX_Online} + ${RX_Degraded}

    ${result}=  Run Keyword If  ${TX_Total} != ${TX_Online} and ${TX_Working} >= 1 and ${RX_Working} >= 1
    ...  Assert  class_name=LNCEL  id=${id}  connection=${alias}
    Run Keyword If  ${TX_Total} != ${TX_Online} and ${TX_Working} >= 1 and ${RX_Working} >= 1
    ...  Run Keyword If  '${result['availabilityStatus']}' in '${Degraded_}'
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  1
    Run Keyword If  ${TX_Total} != ${TX_Online} and ${TX_Working} >= 1 and ${RX_Working} >= 1
    ...  Run Keyword If  '${result['availabilityStatus']}' in '${Failed_}'
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    Run Keyword If  ${TX_Total} != ${TX_Online} and ${TX_Working} >= 1 and ${RX_Working} >= 1
    ...  Run Keyword If  '${result['availabilityStatus']}' in '${Dependency_}'
    ...  Check Cell State and MIMO alarm  LNCEL  ${id}  ${cell_dependency_check}  ${cell_dependency}  ${alias}  0

Check WCDMA cells state and MIMO alarm
    [Arguments]  ${cell_list}=@{EMPTY}  ${alias}=default
    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    ${WCDMA_cell_state_degraded_list}=  Create List
    ${WCDMA_cell_state_failed_list}=  Create List
    ${WCDMA_CELL_info}=  rfs_admin.Admin Get WCDMA CELL list with cell info  cell_list=${cell_list}  alias=${alias}
    FOR  ${item}  IN  @{WCDMA_CELL_info}
        Calculate WCDMA cells state and MIMO alarms  ${item[0]}  ${item[1]}  ${item[2]}  ${item[3]}  ${item[4]}  ${item[5]}  ${item[6]}  ${item[7]}
        ...  ${item[8]}  ${item[9]}  ${item[10]}  ${alias}
        Run Keyword If  '${MIMO_CELL_STATE}' == 'Degraded'
        ...  Append To List  ${WCDMA_cell_state_degraded_list}  ${item[0]}
        ...  ELSE IF  '${MIMO_CELL_STATE}' == 'Failed'
        ...  Append To List  ${WCDMA_cell_state_failed_list}  ${item[0]}
        Add MIMO alarms to list  ${ALARM_COUNT_MIMO}  ${ALARM_COUNT_MIMO_CELL}
    END
    Set Test Variable  ${ALARM_COUNT_MIMO}

    [Return]  ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}

Calculate WCDMA cells state and MIMO alarms
    [Arguments]  ${id}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}
    ...  ${TX_Dependency}  ${RX_Dependency}  ${alias}

    ${cell_online_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_dependency_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Dependency_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_online}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_dependency}=  Set Variable  operationalState=Disabled, availabilityStatus=Dependency, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked
    ${TX_Working}=  Evaluate  ${TX_Online} + ${TX_Degraded}
    ${RX_Working}=  Evaluate  ${RX_Online} + ${RX_Degraded}

    Run Keyword If  ${TX_Total} == ${TX_Online} and ${RX_Total} == ${RX_Online}
    ...  Check Cell State and MIMO alarm  WNCEL  ${id}  ${cell_online_check}  ${cell_online}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Failed} or ${RX_Total} == ${RX_Failed}
    ...  Check Cell State and MIMO alarm  WNCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Dependency} and ${RX_Total} == ${RX_Dependency}
    ...  Check Cell State and MIMO alarm  WNCEL  ${id}  ${cell_dependency_check}  ${cell_dependency}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Online} and ${RX_Total} != ${RX_Online} and ${RX_Working} >= 1
    ...  Check Cell State and MIMO alarm  WNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  0
    ...  ELSE IF  ${TX_Total} != ${TX_Online} and ${TX_Working} >= 1 and ${RX_Working} >= 1
    ...  Check Cell State and MIMO alarm  WNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  0
    ...  ELSE  Run Keywords
    ...  Log  No condition for ${alias} WNCEL ${id} status was met. Please contact TA team.  console=True  level=WARN
    ...  AND  Set Test Variable  ${MIMO_CELL_STATE}  False

Check GSM cells state and MIMO alarm
    [Arguments]  ${cell_list}=@{EMPTY}  ${alias}=default
    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    ${GSM_cell_state_degraded_list}=  Create List
    ${GSM_cell_state_failed_list}=  Create List
    ${GSM_CELL_info}=  rfs_admin.Admin Get GSM CELL list with cell info  cell_list=${cell_list}  alias=${alias}
    FOR  ${item}  IN  @{GSM_CELL_info}
        Calculate GSM cells state and MIMO alarms  ${item[0]}  ${item[1]}  ${item[2]}  ${item[3]}  ${item[4]}  ${item[5]}  ${item[6]}  ${item[7]}
        ...  ${item[8]}  ${item[9]}  ${item[10]}  ${alias}
        Run Keyword If  '${MIMO_CELL_STATE}' == 'Degraded'
        ...  Append To List  ${GSM_cell_state_degraded_list}  ${item[0]}
        ...  ELSE IF  '${MIMO_CELL_STATE}' == 'Failed'
        ...  Append To List  ${GSM_cell_state_failed_list}  ${item[0]}
        Add MIMO alarms to list  ${ALARM_COUNT_MIMO}  ${ALARM_COUNT_MIMO_CELL}
    END
    Set Test Variable  ${ALARM_COUNT_MIMO}

    [Return]  ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}

Calculate GSM cells state and MIMO alarms
    [Arguments]  ${id}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}
    ...  ${TX_Dependency}  ${RX_Dependency}  ${alias}

    ${cell_online_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${cell_failed_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${cell_dependency_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Dependency_}, blockingState=${Unblocked_}
    ${cell_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    ${cell_online}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${cell_failed}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${cell_dependency}=  Set Variable  operationalState=Disabled, availabilityStatus=Dependency, blockingState=Unblocked
    ${cell_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked
    ${TX_Working}=  Evaluate  ${TX_Online} + ${TX_Degraded}
    ${RX_Working}=  Evaluate  ${RX_Online} + ${RX_Degraded}

    Run Keyword If  ${TX_Total} == ${TX_Online} and ${RX_Total} == ${RX_Online}
    ...  Check Cell State and MIMO alarm  GNCEL  ${id}  ${cell_online_check}  ${cell_online}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Failed} or ${RX_Total} == ${RX_Failed}
    ...  Check Cell State and MIMO alarm  GNCEL  ${id}  ${cell_failed_check}  ${cell_failed}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Dependency} or ${RX_Total} == ${RX_Dependency}
    ...  Check Cell State and MIMO alarm  GNCEL  ${id}  ${cell_dependency_check}  ${cell_dependency}  ${alias}  0
    ...  ELSE IF  ${TX_Total} == ${TX_Online} and ${RX_Total} != ${RX_Online} and ${RX_Working} >= 1
    ...  Check Cell State and MIMO alarm  GNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  0
    ...  ELSE IF  ${TX_Total} != ${TX_Online} and ${TX_Working} >= 1 and ${RX_Working} >= 1
    ...  Check Cell State and MIMO alarm  GNCEL  ${id}  ${cell_degraded_check}  ${cell_degraded}  ${alias}  0
    ...  ELSE  Run Keywords
    ...  Log  No condition for ${alias} GNCEL ${id} status was met. Please contact TA team.  console=True  level=WARN
    ...  AND  Set Test Variable  ${MIMO_CELL_STATE}  False

Add MIMO alarms to list
    [Arguments]  ${ALARM_COUNT_MIMO}  ${value}
    ${ALARM_COUNT_MIMO}=  Evaluate  ${ALARM_COUNT_MIMO} + ${value}
    Set Test Variable  ${ALARM_COUNT_MIMO}

Download And Set Current SW for SWDL
    [Documentation]
    ...  KW will perform downloading of the current main SW package from server and set the Target SW variable
    ...  to the path where the SW package was downloaded
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Default                               | Description                                                    |
    ...  | Target_SW_dir       | No   | /home/ute/btsauto/TARGET_SW_MASTER    | Full path where to store the SW.                               |
    ...                                                                         Default value: /home/ute/btsauto/TARGET_SW_MASTER
    ...  | preloaded_package   | No   | EMPTY                                 | A different SW build than the one read from reservation logs   |

    [Arguments]  ${Target_SW_dir}=/home/ute/btsauto/TARGET_SW_MASTER  ${preloaded_package}=${EMPTY}

    ${tmp_path}=  Download T1 T2 or main SW package from server  sw_type=main  Target_SW_dir=${Target_SW_dir}
    ...  preloaded_package=${preloaded_package}
    Rename Software Package  ${tmp_path}
    Log  Target SW for SWDL: ${Target SW}  console=True

Rename Software Package
    [Documentation]
    ...  KW will get the correct SW name from TargetDB file from the supplied .zip archive and rename the archive to
    ...  with the correct name.
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter          | Man. | Default                             | Description                 |
    ...  | target_sw_location | No   | ${Target SW} variable from the test | Full path to the SW archive |

    [Arguments]  ${target_sw_location}=${Target SW}

    Log  Renaming Software Package to the correct name  console=True

    ${is_SBTS_package}=  Run Keyword and Return Status
    ...  Should Match Regexp  ${target_sw_location}  SBTS[A-Z0-9]+_(ENB|FSM3)_[0-9]{4}_[0-9]{6}_[0-9]{6}(.+\.zip|.zip)
    ${package_name}=  Run Keyword If  ${is_SBTS_package}
    ...  Get Targetbd Node Attribute Value  swReleaseVersionName  ${target_sw_location}
    ...  ELSE  Get Targetbd Node Attribute Value  softwareReleaseVersion  ${target_sw_location}

    ${target_sw_path}  ${target_sw_file}=  Split Path  ${target_sw_location}
    OperatingSystem.Move File  ${target_sw_location}  ${target_sw_path}/${package_name}.zip
    Set Test Variable  ${Target Package Name}  ${package_name}
    Set Test Variable  ${Target SW}  ${target_sw_path}/${package_name}.zip
    Log  Successfully renamed ${Target SW}  console=True

Set Alarm Check Level Based on Execution Environment
    [Documentation]
    ...  KW will set alarm check level (ERROR or WARN) based on robot test running from CLOUD or HRAN environment
    ...
    ...  *AUTHOR*
    ...  adelina.ivan@nokia.com
    [Arguments]  ${wait_for_alarm_clear}  ${found_unexpected_alarms}  ${alarm_type}=current

    Run Keyword If  not ${CLOUD_ENV}  Run Keywords
    ...  Set Test Variable  ${ALARMS_LEVEL}  WARN
    ...  AND  Return From Keyword

    ${level}=  Set Variable If  '${fail_if_unexpected_alarms}'=='True'  ERROR  WARN
    Set Test Variable  ${ALARMS_LEVEL}  ${level}

    Run Keyword If  '${ALARMS_LEVEL}'=='ERROR' and '${alarm_type}'=='current'
    ...  Run Keyword And Continue on Failure  Fail
    ...  Unexpected alarms present AFTER alarm clear interval of ${wait_for_alarm_clear}: ${found_unexpected_alarms}

Set KPI Check Level Based on Execution Environment
    [Documentation]
    ...  KW will set KPI check level (ERROR or WARN) based on robot test running from CLOUD or HRAN environment
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    [Arguments]  ${kpi_time}

    Run Keyword If  not ${CLOUD_ENV}  Run Keywords
    ...  Set Test Variable  ${KPI_LEVEL}  WARN
    ...  AND  Log Long String  KPI treshold of ${kpi_time} exceeded, test verdict will be set as passed with restriction. Snapshot will be
    ...  collected at the end of the test  console=True  level=${KPI_LEVEL}
    ...  AND  Return From Keyword

    ${level}=  Set Variable If  '${fail_if_wrn_threshold}'=='True'  ERROR  WARN
    Set Test Variable  ${KPI_LEVEL}  ${level}

    Run Keyword If  '${KPI_LEVEL}'=='ERROR'
    ...  Run Keyword And Continue on Failure  Run Keywords
    ...  Log  KPI treshold of ${kpi_time} exceeded, test verdict will be set as failed. Snapshot will be collected at the end of the test
    ...  level=${KPI_LEVEL}
    ...  AND  Fail  KPI treshold of ${kpi_time} exceeded, test verdict will be set as failed. Snapshot will be collected at the end of the test
    ...  ELSE
    ...  Log  KPI treshold of ${kpi_time} exceeded, test verdict will be set as passed. Snapshot will be collected at the end of the test
    ...  level=${KPI_LEVEL}

Log Long String
    [Arguments]  @{what_to_log}  ${level}=INFO  ${console}=True

    ${to_log}=  Set Variable  ${EMPTY}
    FOR  ${part}  IN  @{what_to_log}
        ${to_log}=  Catenate  ${to_log}  ${part}
    END
    Log  ${to_log[1:]}  level=${level}  console=${console}

Create Long String
    [Arguments]  @{what_to_create}

    ${to_create}=  Set Variable  ${EMPTY}
    FOR  ${part}  IN  @{what_to_create}
        ${to_create}=  Catenate  ${to_create}  ${part}
    END

    [Return]  ${to_create[1:]}

Get TargetBD File From SW Package
    [Documentation]
    ...  Keyword providing TargetBD xml file from SW Package
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                               |
    ...  | SW_package_path | Yes  | path to directory with target SW zip file |
    ...
    ...  *RETURN*
    ...  | Parameter    | Description            |
    ...  | TargetBD_xml | TargetBD xml file info |

    [Arguments]  ${SW_package_path}
    ${file_list}=  Zip File List  ${SW_package_path}
    FOR  ${item}  IN  @{file_list}
        ${status}=  Run Keyword And Return Status  Should Match Regexp  ${item}  (?i).*TargetBD.*
        ${TargetBD_file}=  Set Variable If  ${status}  ${item}
        Exit For Loop If  ${status}
    END
    ${TargetBD_xml}=  Zip Open File  ${SW_package_path}  ${TargetBD_file}
    [Return]  ${TargetBD_xml}

Compare two RM software versions and return newer sw
    [Documentation]
    ...  Return newer software from ${RM_SW1} and ${RM_SW2}
    [Arguments]  ${RM_SW1}  ${RM_SW2}
    ${result}=  Evaluate  '${RM_SW1}' > '${RM_SW2}'
    ${newer_sw}=  Set Variable IF  ${result}  ${RM_SW1}  ${RM_SW2}
    [Return]  ${newer_sw}

Get RMOD radioMaster info
    [Documentation]
    ...  Keyword providing classical BTS controller role for configured RMOD from SCF:
    ...  - with CB009828: based on sharingConfig.controllerRole info
    ...  - without CB009828: based on radioMasterDN info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description                   |
    ...  | alias     | Yes  |         | BTS connection instance alias |
    ...
    ...  *RETURN*
    ...  | Parameter                           | Description                                                   |
    ...  | BTS_primary_controller_RMOD_id_list | List of RMOD id with BTS alias having primary controller role |

    [Arguments]  ${alias}

    ${BTS_primary_controller_RMOD_id_list}=  Create List

    ${BTS_SCF_path_file}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${BTS_CB009828_feature_dict}=  Get BTS CB009828 feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file}  alias=${alias}
    ${actRfsConfigPerUnit_info}=  Get From Dictionary  ${BTS_CB009828_feature_dict}  actRfsConfigPerUnit

    ${BTS_primary_controller_RMOD_sn_list}  ${BTS_secondary_controller_RMOD_sn_list}=
    ...  Run Keyword If  '${actRfsConfigPerUnit_info}' == 'true'
    ...  Get classical BTS controller role for configured RMOD from SCF with CB009828  BTS_SCF_path_file=${BTS_SCF_path_file}  alias=${alias}
    ...  ELSE
    ...  Get classical BTS controller role for configured RMOD from SCF without CB009828  BTS_SCF_path_file=${BTS_SCF_path_file}  alias=${alias}

    ${SN_ID_Mapping_Dict}=  Get All Modules SN ID mapping  ${alias}

    FOR  ${RMOD_sn}  IN  @{BTS_primary_controller_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${SN_ID_Mapping_Dict}  ${RMOD_sn}

        Append To List  ${BTS_primary_controller_RMOD_id_list}  ${RMOD_id}

    END

    [Return]  ${BTS_primary_controller_RMOD_id_list}

Get FHS primaryController info
    [Documentation]
    ...  Keyword providing classical BTS controller role for configured FHS from SCF:
    ...  - with CB009828: based on sharingConfig.controllerRole info
    ...  - without CB009828: based on primaryControllerDN info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description                   |
    ...  | alias     | Yes  |         | BTS connection instance alias |
    ...
    ...  *RETURN*
    ...  | Parameter                          | Description                                                  |
    ...  | BTS_primary_controller_FHS_id_list | List of FHS id with BTS alias having primary controller role |

    [Arguments]  ${alias}

    ${BTS_primary_controller_FHS_id_list}=  Create List

    ${BTS_SCF_path_file}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${BTS_CB009828_feature_dict}=  Get BTS CB009828 feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file}  alias=${alias}
    ${actRfsConfigPerUnit_info}=  Get From Dictionary  ${BTS_CB009828_feature_dict}  actRfsConfigPerUnit

    ${BTS_primary_controller_FHS_sn_list}  ${BTS_secondary_controller_FHS_sn_list}=
    ...  Run Keyword If  '${actRfsConfigPerUnit_info}' == 'true'
    ...  Get classical BTS controller role for configured FHS from SCF with CB009828  BTS_SCF_path_file=${BTS_SCF_path_file}  alias=${alias}
    ...  ELSE
    ...  Get classical BTS controller role for configured FHS from SCF without CB009828  BTS_SCF_path_file=${BTS_SCF_path_file}  alias=${alias}

    ${SN_ID_Mapping_Dict}=  Get All Modules SN ID mapping  ${alias}

    FOR  ${FHS_sn}  IN  @{BTS_primary_controller_FHS_sn_list}

        ${FHS_id}=  Get From Dictionary  ${SN_ID_Mapping_Dict}  ${FHS_sn}

        Append To List  ${BTS_primary_controller_FHS_id_list}  ${FHS_id}

    END

    [Return]  ${BTS_primary_controller_FHS_id_list}

Get Cell list mapped on shared RM
    [Arguments]  ${shared_RM_list}  ${alias}
    ${shared_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{shared_RM_list}
        ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Append To List  ${shared_RM_CELL_list}  @{CELL_RM_list}
    END
    ${shared_RM_CELL_list}=  Remove Duplicates  ${shared_RM_CELL_list}

    [Return]  ${shared_RM_CELL_list}

Get Primary Link status based on linkModeSynchronization
    [Documentation]
    ...  KW used to get shared modules (RMOD or FHS) Primary Link status based on linkModeSynchronization on Master or Slave BTS.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter   | Man. | Default | Description                     |
    ...  | module_type | Yes  |         | shared module type: RMOD or FHS |
    ...
    ...  *RETURN VALUE*
    ...  | Master_Primary_Link_dict | Dictionary with key Master shared module_type Id and value True or False |
    ...  | Slave_Primary_Link_dict  | Dictionary with key Slave shared module_type Id and value True or False  |
    ...
    [Arguments]  ${module_type}

    ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}=  Run Keyword If  '${module_type}' == 'RMOD'
    ...  Get shared RMOD Primary Link status based on linkModeSynchronization
    ...  ELSE IF  '${module_type}' == 'FHS'
    ...  Get shared FHS Primary Link status based on linkModeSynchronization

    [Return]  ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}

Get shared RMOD Primary Link status based on linkModeSynchronization
    [Documentation]
    ...  KW used to get shared RMOD Primary Link status based on linkModeSynchronization on Master or Slave BTS.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN VALUE*
    ...  | Master_Primary_Link_dict | Dictionary with key Master shared RMOD Id and value True or False |
    ...  | Slave_Primary_Link_dict  | Dictionary with key Slave shared RMOD Id and value True or False  |
    ...

    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave

    ${Master_Primary_Link_dict}=  Create Dictionary
    ${Slave_Primary_Link_dict}=  Create Dictionary

    ${Master_RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  Master
    ${Slave_RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  Slave

    ${Master_BTS_radioMaster_RMOD_list}=  Get RMOD radioMaster info  Master
    ${Slave_BTS_radioMaster_RMOD_list}=  Get RMOD radioMaster info  Slave

    ${Master_BTS_CABLINK_id_firstEndPointId_dict}  ${Master_BTS_CABLINK_id_secondEndPointId_dict}  ${Master_BTS_CABLINK_id_configuration_dict}
    ...  ${Master_BTS_CABLINK_id_data_dict}  ${Master_BTS_CABLINK_id_dc_dict}  ${Master_BTS_CABLINK_id_synchronization_dict}
    ...  ${Master_BTS_CABLINK_id_operationalState_dict}=  Admin Get CABLINK info dict  Master
    ${Slave_BTS_CABLINK_id_firstEndPointId_dict}  ${Slave_BTS_CABLINK_id_secondEndPointId_dict}  ${Slave_BTS_CABLINK_id_configuration_dict}
    ...  ${Slave_BTS_CABLINK_id_data_dict}  ${Slave_BTS_CABLINK_id_dc_dict}  ${Slave_BTS_CABLINK_id_synchronization_dict}
    ...  ${Slave_BTS_CABLINK_id_operationalState_dict}=  Admin Get CABLINK info dict  Slave

    FOR  ${Master_RMOD_id}  ${Slave_RMOD_id}  IN ZIP  ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}

        ${Master_RMOD_L3Protocol}=  Get From Dictionary  ${Master_RMOD_L3Protocol_dict}  ${Master_RMOD_id}

        ${Master_BTS_shared_RMOD_synchronization_list}=  Run Keyword If  '${Master_RMOD_L3Protocol}' in ['CPRI_RP1','ECPRI_MPLANE']
        ...  Get PL shared RMOD status from CABLINK info  ${Master_RMOD_id}  ${Master_BTS_CABLINK_id_firstEndPointId_dict}
        ...  ${Master_BTS_CABLINK_id_secondEndPointId_dict}  ${Master_BTS_CABLINK_id_synchronization_dict}
        ...  ${Master_BTS_CABLINK_id_operationalState_dict}  Master
        ...  ELSE IF  '${Master_RMOD_L3Protocol}' == 'RP301_RP1'
        ...  Get PL shared RMOD status from Primary Controller info  ${Master_RMOD_id}  ${Master_BTS_radioMaster_RMOD_list}

        Run Keyword If  ${Master_BTS_shared_RMOD_synchronization_list}
        ...  Set To Dictionary  ${Master_Primary_Link_dict}  ${Master_RMOD_id}  ${Master_BTS_shared_RMOD_synchronization_list}

        ${Slave_RMOD_L3Protocol}=  Get From Dictionary  ${Slave_RMOD_L3Protocol_dict}  ${Slave_RMOD_id}

        ${Slave_BTS_shared_RMOD_synchronization_list}=  Run Keyword If  '${Slave_RMOD_L3Protocol}' in ['CPRI_RP1','ECPRI_MPLANE']
        ...  Get PL shared RMOD status from CABLINK info  ${Slave_RMOD_id}  ${Slave_BTS_CABLINK_id_firstEndPointId_dict}
        ...  ${Slave_BTS_CABLINK_id_secondEndPointId_dict}  ${Slave_BTS_CABLINK_id_synchronization_dict}
        ...  ${Slave_BTS_CABLINK_id_operationalState_dict}  Slave
        ...  ELSE IF  '${Slave_RMOD_L3Protocol}' == 'RP301_RP1'
        ...  Get PL shared RMOD status from Primary Controller info  ${Slave_RMOD_id}  ${Slave_BTS_radioMaster_RMOD_list}

        Run Keyword If  ${Slave_BTS_shared_RMOD_synchronization_list}
        ...  Set To Dictionary  ${Slave_Primary_Link_dict}  ${Slave_RMOD_id}  ${Slave_BTS_shared_RMOD_synchronization_list}

    END

    [Return]  ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}

Get shared FHS Primary Link status based on linkModeSynchronization
    [Documentation]
    ...  KW used to get shared FHS Primary Link status based on linkModeSynchronization on Master or Slave BTS.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN VALUE*
    ...  | Master_Primary_Link_dict | Dictionary with key Master shared FHS Id and value True or False |
    ...  | Slave_Primary_Link_dict  | Dictionary with key Slave shared FHS Id and value True or False  |
    ...

    ${Master_shared_FHS_list}  ${Slave_shared_FHS_list}  ${Master_dedicated_FHS_list}  ${Slave_dedicated_FHS_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  FHS  Master  Slave

    ${Master_Primary_Link_dict}=  Create Dictionary
    ${Slave_Primary_Link_dict}=  Create Dictionary

    ${Master_BTS_CABLINK_id_firstEndPointId_dict}  ${Master_BTS_CABLINK_id_secondEndPointId_dict}  ${Master_BTS_CABLINK_id_configuration_dict}
    ...  ${Master_BTS_CABLINK_id_data_dict}  ${Master_BTS_CABLINK_id_dc_dict}  ${Master_BTS_CABLINK_id_synchronization_dict}
    ...  ${Master_BTS_CABLINK_id_operationalState_dict}=  Admin Get CABLINK info dict  Master
    ${Slave_BTS_CABLINK_id_firstEndPointId_dict}  ${Slave_BTS_CABLINK_id_secondEndPointId_dict}  ${Slave_BTS_CABLINK_id_configuration_dict}
    ...  ${Slave_BTS_CABLINK_id_data_dict}  ${Slave_BTS_CABLINK_id_dc_dict}  ${Slave_BTS_CABLINK_id_synchronization_dict}
    ...  ${Slave_BTS_CABLINK_id_operationalState_dict}=  Admin Get CABLINK info dict  Slave

    FOR  ${Master_FHS_id}  ${Slave_FHS_id}  IN ZIP  ${Master_shared_FHS_list}  ${Slave_shared_FHS_list}

        ${Master_BTS_shared_FHS_synchronization_list}=  Get PL shared FHS status from CABLINK info  ${Master_FHS_id}
        ...  ${Master_BTS_CABLINK_id_firstEndPointId_dict}  ${Master_BTS_CABLINK_id_secondEndPointId_dict}
        ...  ${Master_BTS_CABLINK_id_synchronization_dict}  ${Master_BTS_CABLINK_id_operationalState_dict}  Master

        Run Keyword If  ${Master_BTS_shared_FHS_synchronization_list}
        ...  Set To Dictionary  ${Master_Primary_Link_dict}  ${Master_FHS_id}  ${Master_BTS_shared_FHS_synchronization_list}

       ${Slave_BTS_shared_FHS_synchronization_list}=  Get PL shared FHS status from CABLINK info  ${Slave_FHS_id}
        ...  ${Slave_BTS_CABLINK_id_firstEndPointId_dict}  ${Slave_BTS_CABLINK_id_secondEndPointId_dict}
        ...  ${Slave_BTS_CABLINK_id_synchronization_dict}  ${Slave_BTS_CABLINK_id_operationalState_dict}  Slave

        Run Keyword If  ${Slave_BTS_shared_FHS_synchronization_list}
        ...  Set To Dictionary  ${Slave_Primary_Link_dict}  ${Slave_FHS_id}  ${Slave_BTS_shared_FHS_synchronization_list}

    END

    [Return]  ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}

Check if Primary Link switched on BTS
    [Arguments]  ${module_type}  ${alias}  ${module_SN_list}=@{EMPTY}

    Assert Every  class_name=RMOD  parameters=operationalState=${Enabled_}  timeout=60  connection=${alias}

    ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}=  Get Primary Link status based on linkModeSynchronization  ${module_type}
    ${BTS_keys}=  Get Dictionary Keys  ${${alias}_Primary_Link_dict}  False
    ${BTS_keys_status}=  Should Not Be Empty  ${BTS_keys}
    ${Primary_Link_status}=  Set Variable  ${True}
    FOR  ${BTS_key}  IN ZIP  ${BTS_keys}
        ${BTS_value}=  Get From Dictionary  ${${alias}_Primary_Link_dict}  ${BTS_key}
        ${module_SN}=  Get From Dictionary  ${${alias}_module_ID_SN_dict}  ${BTS_key}
        Run Keyword If  ${module_SN_list} != @{EMPTY} and '${module_SN}' not in @{module_SN_list}
        ...  Continue For Loop
        ${Primary_Link_status}=  Set Variable If  'True' in '${BTS_value}'  ${Primary_Link_status}  ${False}
    END
    Should Be True  ${Primary_Link_status}

Check Primary Link status based on linkModeSynchronization
    [Documentation]
    ...  KW used to check shared modules (RMOD or FHS) Primary Link status on Master or Slave BTS.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter      | Man. | Default  | Description                                                                                      |
    ...  | module_type    | Yes  |          | shared module type: RMOD or FHS                                                                  |
    ...  | alias          | Yes  |          | requested BTS alias to have Primary Link set                                                     |
    ...  | module_SN_list |  No  | @{EMPTY} | list of modules on which PL needs to be checked; default value means all modules will be checked |
    ...
    ...  *RETURN VALUE*
    ...  | Primary_Link_status | True (if all module_type Primary Link are set on BTS ${alias}) or False |
    ...
    [Arguments]  ${module_type}  ${alias}  ${module_SN_list}=@{EMPTY}

    ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}=  Get Primary Link status based on linkModeSynchronization  ${module_type}
    ${Master_keys}=  Get Dictionary Keys  ${Master_Primary_Link_dict}  False
    ${Slave_keys}=  Get Dictionary Keys  ${Slave_Primary_Link_dict}  False
    Set Test Variable  ${Primary_Link_status}  ${True}

    FOR  ${Master_key}  ${Slave_key}  IN ZIP  ${Master_keys}  ${Slave_keys}

        ${Master_value}=  Get From Dictionary  ${Master_Primary_Link_dict}  ${Master_key}
        ${Slave_value}=  Get From Dictionary  ${Slave_Primary_Link_dict}  ${Slave_key}
        ${module_SN}=  Get From Dictionary  ${Master_module_ID_SN_dict}  ${Master_key}

        Run Keyword If  ${module_SN_list} != @{EMPTY} and '${module_SN}' not in @{module_SN_list}  Run Keywords
        ...  Log  Primary Link check will be skipped for ${module_type}: ${module_SN}  console=True  AND  Continue For Loop

        Log  Primary Link status (linkModeSynchronization) for shared ${module_type} with SN ${module_SN}:  console=True
        Log  - BTS Master ${module_type} ${Master_key}: ${Master_value}  console=True
        Log  - BTS Slave ${module_type} ${Slave_key}: ${Slave_value}  console=True

        Run Keyword If  'True' in '${Master_value}' and 'True' in '${Slave_value}'  Run Keywords
        ...  Log  Parameter linkModeSynchronization set on True on both BTS, not reliable value!  level=ERROR
        ...  AND  Fail  Parameter linkModeSynchronization set on True on both BTS, not reliable value!
        Run Keyword If  'True' not in '${Master_value}' and 'True' not in '${Slave_value}'  Run Keywords
        ...  Log  Parameter linkModeSynchronization not set on True on any BTS, not reliable value!  level=ERROR
        ...  AND  Fail  Parameter linkModeSynchronization not set on True on any BTS, not reliable value!

        ${Primary_Link_status}=  Set Variable If
        ...  ('${alias}' == 'Master' and 'True' in '${Master_value}') or ('${alias}' == 'Slave' and 'True' in '${Slave_value}')
        ...  ${Primary_Link_status}  ${False}

    END

    [Return]  ${Primary_Link_status}

Set Primary Link status based on linkModeSynchronization
    [Documentation]
    ...  KW used to set shared modules Primary Link status on requested BTS based on linkModeSynchronization parameter by one of following
    ...  procedures:
    ...  - BTS reset; if needed continue with BTS power OFF/ON.
    ...  - LANE lock unlock procedure.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                      | Man. | Default  | Description                                                              |
    ...  | module_type                    | Yes  |          | shared module type: RMOD or FHS                                          |
    ...  | procedure_for_Primary_Link_set | Yes  |          | procedure to set Primary Link: BTS or LANE                               |
    ...  | alias                          | Yes  |          | requested BTS alias to set Primary Link                                  |
    ...  | wait_for_Primary_Link_set      | No   | 120      | time to wait for Primary Link set on BTS alias                           |
    ...  | module_SN_list |  No  | @{EMPTY} | list of modules on which PL needs to be set; default value means all modules will be set |
    ...
    [Arguments]  ${module_type}  ${procedure_for_Primary_Link_set}  ${alias}  ${peer_alias}=${EMPTY}  ${wait_for_Primary_Link_set}=120
    ...  ${module_SN_list}=@{EMPTY}

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master

    Run Keyword If  '${procedure_for_Primary_Link_set}' == 'BTS'
    ...  Set Primary Link status based on linkModeSynchronization by BTS reset procedure  module_type=${module_type}  alias=${alias}
    ...  wait_for_Primary_Link_set=${wait_for_Primary_Link_set}  module_SN_list=${module_SN_list}
    ...  ELSE IF  '${procedure_for_Primary_Link_set}' == 'LANE'
    ...  Set Primary Link status based on linkModeSynchronization by LANE lock unlock procedure  module_type=${module_type}  alias=${alias}
    ...  wait_for_Primary_Link_set=${wait_for_Primary_Link_set}  module_SN_list=${module_SN_list}

Set Primary Link status based on linkModeSynchronization by BTS reset procedure
    [Documentation]
    ...  KW used to set shared modules Primary Link status on requested BTS based on linkModeSynchronization parameter by peer BTS reset (if needed
    ...  peer BTS power off/on) procedure.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
     ...  *INPUT*
    ...  | Parameter                 | Man. | Default | Description                                |
    ...  | module_type               | Yes  |         | shared module type: RMOD or FHS            |
    ...  | alias                     | Yes  |         | requested BTS alias to set Primary Link    |
    ...  | wait_for_Primary_Link_set | No   | 120     | time to wait for Primary Link set on alias |
    ...  | module_SN_list |  No  | @{EMPTY} | list of modules on which PL needs to be checked after reset; default value means all modules |
    ...
    [Arguments]  ${module_type}  ${alias}  ${wait_for_Primary_Link_set}=120  ${module_SN_list}=@{EMPTY}

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    ${Primary_Link_status}=  Check Primary Link status based on linkModeSynchronization  ${module_type}  ${alias}  ${module_SN_list}
    Run Keyword If  ${Primary_Link_status}  Run Keywords
    ...  Log  All shared ${module_type} Primary Link already set on BTS ${alias}, no action needed!  console=True
    ...  AND  Return From Keyword

    Log  BTS ${peer_alias} reset will be performed in order to set Primary Link on BTS ${alias}!  console=True
    coam.Reset Site  alias=${peer_alias}
    Sleep  120s
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=${peer_alias}
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=${alias}

    ${Primary_Link_status}=  Check Primary Link status based on linkModeSynchronization  ${module_type}  ${alias}  ${module_SN_list}
    Run Keyword If  ${Primary_Link_status}  Run Keywords
    ...  Log  All shared ${module_type} Primary Link set on BTS ${alias}, due to BTS ${peer_alias} reset!  console=True
    ...  AND  Return From Keyword

    Log  Not all shared ${module_type} Primary Link set on BTS ${alias} due to BTS ${peer_alias} reset, try BTS ${peer_alias} power off/on!
    ...  console=True
    Log  BTS ${peer_alias} power off/on will be performed in order to set Primary Link on BTS ${alias}!  console=True
    Pdu BTS Interface Off  ${peer_alias.lower()}_fsm
    Log  Wait ${wait_for_Primary_Link_set} seconds for Primary Link establishment  console=True
    Sleep  ${wait_for_Primary_Link_set}s
    Pdu BTS Interface On  ${peer_alias.lower()}_fsm
    Sleep  180s
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=${peer_alias}
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=${alias}

    ${Primary_Link_status}=  Check Primary Link status based on linkModeSynchronization  ${module_type}  ${alias}  ${module_SN_list}
    Run Keyword If  ${Primary_Link_status}
    ...  Log  All shared ${module_type} Primary Link set on BTS ${alias}, due to BTS ${peer_alias} power off/on!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Not all shared ${module_type} Primary Link set on BTS ${alias}, failed!  level=ERROR
    ...  AND  Fail  Not all shared ${module_type} Primary Link set on BTS ${alias}, failed!

Set Primary Link status based on linkModeSynchronization by LANE lock unlock procedure
    [Documentation]
    ...  KW used to set shared modules Primary Link status on BTS based on linkModeSynchronization parameter by LANE lock unlock procedure.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                 | Man. | Default | Description                                                                    |
    ...  | module_type               | Yes  |         | shared module type: RMOD or FHS                                                |
    ...  | alias                     | Yes  |         | requested BTS alias to set Primary Link                                        |
    ...  | wait_for_Primary_Link_set | Yes  | 120     | time to wait for Primary Link set on alias                                     |
    ...  | module_SN_list |  No  | @{EMPTY} | list of modules on which PL needs to be set; default value means all modules will be set |
    ...
    [Arguments]  ${module_type}  ${alias}  ${wait_for_Primary_Link_set}=120  ${module_SN_list}=@{EMPTY}

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    ${Primary_Link_status}=  Check Primary Link status based on linkModeSynchronization  ${module_type}  ${alias}  ${module_SN_list}
    Run Keyword If  ${Primary_Link_status}  Run Keywords
    ...  Log  All shared ${module_type} Primary Link already set on BTS ${alias}, no action needed!  console=True
    ...  AND  Return From Keyword

    Log  BTS ${peer_alias} Lock Unlock LANE will be performed in order to set Primary Link on BTS ${alias} for needed shared ${module_type}!
    ...  console=True
    Get BTS MODULE LANE info dict  ${module_type}  ${peer_alias}
    Perform Lock Unlock LANE on request  ${module_type}  ${peer_alias}  ${alias}  ${wait_for_Primary_Link_set}  ${module_SN_list}
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=${peer_alias}
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=${alias}

    ${Primary_Link_status}=  Check Primary Link status based on linkModeSynchronization  ${module_type}  ${alias}  ${module_SN_list}
    Run Keyword If  ${Primary_Link_status}
    ...  Log  All shared ${module_type} Primary Link set on BTS ${alias}, after lock and unlock BTS ${peer_alias} LANE procedure !  console=True
    ...  ELSE  Run Keywords
    ...  Log  Not all shared ${module_type} Primary Link set on BTS ${alias}, failed!  level=ERROR
    ...  AND  Fail  Not all shared ${module_type} Primary Link set on BTS ${alias}, failed!

Get linkModeSynchronization from CABLINK
    [Arguments]  ${module_id}  ${connection}
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${connection}
    ${linkModeSynchronization_list}=  Create List
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${CABLINK_param}=  coam.Get Parameters  dist_name=${CABLINK_id}  connection=${connection}
        ${CABLINK_stateInfo}=  Run Keyword And Return Status  Variable Should Exist  ${CABLINK_param['stateInfo']}
        ${firstEndpointDN_FHS_R}=  Run Keyword And Return Status  Should Contain  ${CABLINK_param.firstEndpointDN}  FHS_R
        ${firstEndpointDN_BBMOD_R}=  Run Keyword And Return Status  Should Contain  ${CABLINK_param['firstEndpointDN']}  BBMOD_R
        ${firstEndpointDN_SMOD_R}=  Run Keyword And Return Status  Should Contain  ${CABLINK_param['firstEndpointDN']}  SMOD_R
        ${condition}=  Run Keyword If  ${CABLINK_stateInfo}
        ...  Create Long String
        ...  (${firstEndpointDN_FHS_R} or ${firstEndpointDN_BBMOD_R} or ${firstEndpointDN_SMOD_R})
        ...  and '${CABLINK_param['secondEndpointDN']}' == '${module_id}'
        ...  and '${CABLINK_param['stateInfo']['operationalState']}' in '${Enabled_}'
        ...  ELSE
        ...  Create Long String
        ...  (${firstEndpointDN_FHS_R} or ${firstEndpointDN_BBMOD_R} or ${firstEndpointDN_SMOD_R})
        ...  and '${CABLINK_param['secondEndpointDN']}' == '${module_id}'
        ...  and '${CABLINK_param['operationalState']}' in '${Enabled_}'
        Run Keyword If  ${condition}
        ...  Append To List  ${linkModeSynchronization_list}  ${CABLINK_param['linkModeSynchronization']}
    END
    [Return]  ${linkModeSynchronization_list}

Get BTS MODULE LANE info dict
    [Documentation]
    ...  KW used to get BTS info dict for shared modules (RMOD or FHS) LANE and CONNECTOR.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter   | Man. | Default | Description     |
    ...  | module_type | Yes  |         | RMOD or FHS     |
    ...  | alias       | Yes  |         | Master or Slave |
    ...
    [Arguments]  ${module_type}  ${alias}

    ${SFP_SMOD_list}=  Get SFP list from BTS module  SMOD  ${alias}
    ${SFP_BBMOD_list}=  Get SFP list from BTS module  BBMOD  ${alias}
    ${BTS_SFP_SMOD_BBMOD_list}=  Combine Lists  ${SFP_SMOD_list}  ${SFP_BBMOD_list}
    Set Test Variable  ${BTS_SFP_SMOD_BBMOD_list}

    ${CONNECTOR_LANE_dict}=  Get CONNECTOR LANE info dict  SFP_list=${BTS_SFP_SMOD_BBMOD_list}  connection=${alias}
    Set Test Variable  ${CONNECTOR_LANE_dict}

    ${MODULE_CONNECTOR_dict}=  Get MODULE CONNECTOR info dict  module_type=${module_type}  connection=${alias}
    Set Test Variable  ${MODULE_CONNECTOR_dict}

    ${MODULE_LANE_dict}=  Get MODULE LANE info dict
    Set Test Variable  ${MODULE_LANE_dict}

Get SFP list from BTS module
    [Arguments]  ${module_type}  ${alias}
    Run keyword if  not ('${module_type}' in ['SMOD','BBMOD','RMOD'])
    ...  Fail  Unsupported module type
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${module_list}=  Get all dist names by pattern from SCF  pattern=/${module_type}-[\\d]+$  scf_path=${BTS_scf}
    ${All_SFP_list}=  coam.Get SFP data  connection=${alias}
    ${SFP_list}=  Create list
    FOR  ${item}  IN  @{All_SFP_list['connected']}
        ${SFP_runtime_DN}=  Set Variable  ${None}
        ${SFP_source_endpoint_config_DN}=  Set Variable  ${item['source']['extendedId']['configuration']}
        ${SFP_source_internal_DN}=  Set Variable  ${item['source']['connector']['extendedId']['internal']}
        ${SFP_destination_endpoint_config_DN}=  Set Variable  ${item['destination']['extendedId']['configuration']}
        ${SFP_destination_internal_DN}=  Set Variable  ${item['destination']['connector']['extendedId']['internal']}
        ${SFP_runtime_DN}=  Set Variable if  '${SFP_source_endpoint_config_DN}' in @{module_list}
        ...  ${SFP_source_internal_DN}
        ${SFP_runtime_DN}=  Set Variable if  '${SFP_destination_endpoint_config_DN}' in @{module_list}
        ...  ${SFP_destination_internal_DN}  ${SFP_runtime_DN}
        Continue For Loop If  '${SFP_runtime_DN}'=='${None}'
        Append To List  ${SFP_list}  ${SFP_runtime_DN}
    END
    [Return]  ${SFP_list}

Get MODULE CONNECTOR info dict
    [Arguments]  ${module_type}  ${connection}
    ${BTS_module_list}=  Run Keyword If  '${module_type}' == 'RMOD'  Get Ids For All  class_name=RMOD  connection=${connection}
    ...  ELSE IF  '${module_type}' == 'FHS'  Admin Get FHS Ids  alias=${connection}
    ${MODULE_CONNECTOR_dict}=  Create Dictionary
    FOR  ${item}  IN  @{BTS_module_list}
        ${CONNECTOR_list}=  Get CONNECTOR info list  module_id=${item}  connection=${connection}
        Set To Dictionary  ${MODULE_CONNECTOR_dict}  ${item}  ${CONNECTOR_list}
    END
    [Return]  ${MODULE_CONNECTOR_dict}

Get CONNECTOR info list
    [Arguments]  ${module_id}  ${connection}
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${connection}
    ${CONNECTOR_list}=  Create List
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${CABLINK_param}=  coam.Get Parameters  dist_name=${CABLINK_id}  connection=${connection}
        ${CABLINK_stateInfo}=  Run Keyword And Return Status  Variable Should Exist  ${CABLINK_param['stateInfo']}
        ${firstEndpointDN_BBMOD_R}=  Run Keyword And Return Status  Should Contain  ${CABLINK_param['firstEndpointDN']}  BBMOD_R
        ${firstEndpointDN_SMOD_R}=  Run Keyword And Return Status  Should Contain  ${CABLINK_param['firstEndpointDN']}  SMOD_R
        ${condition}=  Run Keyword If  ${CABLINK_stateInfo}
        ...  Create Long String
        ...  (${firstEndpointDN_BBMOD_R} or ${firstEndpointDN_SMOD_R})
        ...  and '${CABLINK_param['secondEndpointDN']}' == '${module_id}'
        ...  and '${CABLINK_param['stateInfo']['operationalState']}' in '${Enabled_}'
        ...  ELSE
        ...  Create Long String
        ...  ((${firstEndpointDN_BBMOD_R} or ${firstEndpointDN_SMOD_R})
        ...  and '${CABLINK_param['secondEndpointDN']}' == '${module_id}'
        ...  and '${CABLINK_param['operationalState']}' in '${Enabled_}')
        Run Keyword If  not ${condition}  Continue For Loop
        ${CABLINK_L_param}=  Admin Get REF Object  object_dn=${CABLINK_id}  connection=${connection}
        ${CONNECTOR} =  coam.Get Parameters  dist_name=${CABLINK_L_param}  pattern=destinationDistName  connection=${connection}
        Append To List  ${CONNECTOR_list}  ${CONNECTOR['destinationDistName']}
    END
    [Return]  ${CONNECTOR_list}

Get CONNECTOR LANE info dict
    [Arguments]  ${SFP_list}  ${connection}
    ${CONNECTOR_LANE_dict}=  Create Dictionary
    Set Test Variable  ${CONNECTOR_LANE_dict}
    FOR  ${item}  IN  @{SFP_list}
        ${LANE_dn_list}=  Get Lane DN Of SFP  sfp_dn=${item}  connection=${connection}
        Continue For Loop If  not ${LANE_dn_list}
        ${CONNECTOR_LANE_dict}=  Get LANE info dict  LANE_dn_list=${LANE_dn_list}  connection=${connection}
    END
    [Return]  ${CONNECTOR_LANE_dict}

Get Lane DN Of SFP
    [Arguments]  ${sfp_dn}  ${connection}
    ${LANE_dn}=  Set Variable  ${None}
    ${LANE_dn_list}=  Create List
    ${All_LANE_list}=  coam.Get Managed Objects  class_name=LANE_R  connection=${connection}
    FOR  ${item}  IN  @{All_LANE_list}
        ${LANE_dn}=  Set Variable If  '${sfp_dn}' in '${item['distName']}'  ${item['distName']}  ${None}
        Run Keyword If  '${LANE_dn}' != '${None}'
        ...  Append to list  ${LANE_dn_list}  ${LANE_dn}
    END
    [Return]  ${LANE_dn_list}

Get LANE info dict
    [Arguments]  ${LANE_dn_list}  ${connection}
    FOR  ${item}  IN  @{LANE_dn_list}
        ${CONNECTOR_Id}=  Admin Get REF Object  object_dn=${item}  connection=${connection}
        Set To Dictionary  ${CONNECTOR_LANE_dict}  ${CONNECTOR_Id}  ${item}
    END
    [Return]  ${CONNECTOR_LANE_dict}

Get MODULE LANE info dict
    ${MODULE_LANE_dict}=  Create Dictionary
    ${MODULE_list}=  Get Dictionary Keys  ${MODULE_CONNECTOR_dict}
    FOR  ${item}  IN  @{MODULE_list}
        ${CONNECTOR_list}=  Get From Dictionary  ${MODULE_CONNECTOR_dict}  ${item}
        ${LANE_list}=  Get LANE info list  ${CONNECTOR_list}
        Set To Dictionary  ${MODULE_LANE_dict}  ${item}  ${LANE_list}
    END
    [Return]  ${MODULE_LANE_dict}

Get LANE info list
    [Arguments]  ${CONNECTOR_list}
    ${LANE_list}=  Create List
    FOR  ${item}  IN  @{CONNECTOR_list}
        ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${CONNECTOR_LANE_dict}  ${item}
        Run Keyword If  not ${status}  Continue For Loop
        ${LANE_Id}=  Get From Dictionary  ${CONNECTOR_LANE_dict}  ${item}
        Append To List  ${LANE_list}  ${LANE_Id}
    END
    [Return]  ${LANE_list}

Perform Lock Unlock LANE on request
    [Arguments]  ${module_type}  ${alias}  ${peer_alias}  ${wait_for_Primary_Link_set}  ${module_SN_list}=@{EMPTY}
    ${module_list_check}=  Create List
    ${LANE_Id_list}=  Create List
    ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}=  Run Keyword If  '${module_type}'=='RMOD'
    ...  Get Primary Link status for shared RMOD
    ...  ELSE IF  '${module_type}'=='FHS'
    ...  Get Shared FHS Primary Link status based on linkModeSynchronization
    ...  ELSE  Return From Keyword  Wrong module_type
    ${Master_keys}=  Get Dictionary Keys  ${Master_Primary_Link_dict}  False
    ${Slave_keys}=  Get Dictionary Keys  ${Slave_Primary_Link_dict}  False

    ${Master_RMOD_L3Protocol_dict}=  Run Keyword If  '${module_type}' == 'RMOD'  Admin Get RMOD L3 Protocol Info  Master

    FOR  ${Master_key}  ${Slave_key}  IN ZIP  ${Master_keys}  ${Slave_keys}

        ${Master_value}=  Get From Dictionary  ${Master_Primary_Link_dict}  ${Master_key}
        ${Slave_value}=  Get From Dictionary  ${Slave_Primary_Link_dict}  ${Slave_key}
        ${module_SN}=  Get From Dictionary  ${Master_module_ID_SN_dict}  ${Master_key}

        Run Keyword If  ${module_SN_list} != @{EMPTY} and '${module_SN}' not in @{module_SN_list}  Run Keywords
        ...  Log  Primary Link setting will be skipped for ${module_type}: ${module_SN}  console=True  AND  Continue For Loop

        ${Master_RMOD_L3Protocol}=  Run Keyword If  '${module_type}' == 'RMOD'  Get From Dictionary  ${Master_RMOD_L3Protocol_dict}  ${Master_key}
        Run Keyword If  '${module_type}' == 'RMOD'  Continue For Loop If  '${Master_RMOD_L3Protocol}' == 'RP301_RP1'

        ${LANE_list}=  Run Keyword If
        ...  ('${alias}' == 'Master' and 'True' in '${Master_value}') or ('${alias}' == 'Slave' and 'True' in '${Slave_value}')
        ...  Get and Check LANE info  ${${alias}_key}  ${alias}
        ...  ELSE  Continue For Loop

        Append To List  ${module_list_check}  ${${alias}_key}
        Append To List  ${LANE_Id_list}  @{LANE_list}

    END

    Admin Perform LANE Operation  ${LANE_Id_list}  Lock  ${alias}

    Log  Wait maximum ${wait_for_Primary_Link_set} seconds for Primary Link establishment  console=True
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  ${wait_for_Primary_Link_set}s  30s
    ...  Check if Primary Link switched on BTS  ${module_type}  ${peer_alias}  ${module_SN_list}

    Admin Perform LANE Operation  ${LANE_Id_list}  Unlock  ${alias}

    [Teardown]  Check If all module LANE Objects Are Unlocked  ${module_list_check}  60  60  ${alias}

Get and Check LANE info
    [Arguments]  ${module_id}  ${alias}
    ${LANE_list}=  Get From Dictionary  ${MODULE_LANE_dict}  ${module_id}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    FOR  ${item}  IN  @{LANE_list}
        Check SCF LANE info  ${BTS_scf}  ${item}  ${alias}
    END

    [Return]  ${LANE_list}

Perform LANE operation
    [Arguments]  ${module_id}  ${operation}  ${alias}
    ${LANE_list}=  Get From Dictionary  ${MODULE_LANE_dict}  ${module_id}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    FOR  ${item}  IN  @{LANE_list}
        Check SCF LANE info  ${BTS_scf}  ${item}  ${alias}
        ${LANE_Id_list}=  Create List  ${item}
        Admin Perform LANE Operation  ${LANE_Id_list}  ${operation}  ${alias}
    END

Check SCF LANE info
    [Arguments]  ${BTS_scf}  ${LANE_id}  ${alias}
    ${LANE_items}=  Get All Dist Names By Pattern From SCF
     ...  pattern=/LANE-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    Run Keyword If  not ${LANE_items}  Run Keywords
    ...  Log  Action Lock/Unlock LANE not valid for any LANE (no SCF LANE configured)!  level=ERROR
    ...  AND  Fail  Action Lock/Unlock LANE not valid for any LANE (no SCF LANE configured)!

    ${SFP_id}=  Fetch From Left  ${LANE_id}  /LANE_R
    ${SFP_distName}=  Get SFP SCF distinguished name  SFP_R_id=${SFP_id}  alias=${alias}
    FOR  ${LANE_distName}  IN  @{LANE_items}
        ${LANE_SCF_status}=  Run Keyword And Return Status  Should Contain  ${LANE_distName}  ${SFP_distName}
        Exit For Loop If  ${LANE_SCF_status}
    END
    Run Keyword If  not ${LANE_SCF_status}  Run Keywords
    ...  Log  Action Lock/Unlock LANE not valid for ${LANE_id} (no SCF LANE configured)!  level=ERROR
    ...  AND  Fail  Action Lock/Unlock LANE not valid for ${LANE_id} (no SCF LANE configured)!

Check If all module LANE Objects Are Unlocked
    [Arguments]  ${module_list_check}  ${timeout}  ${recover_timeout}  ${alias}
    FOR  ${item}  IN  @{module_list_check}
        Check If LANE Objects Are Unlocked  ${item}  ${timeout}  ${recover_timeout}  ${alias}
    END

Check If LANE Objects Are Unlocked
    [Arguments]  ${module_id}  ${timeout}  ${recover_timeout}  ${alias}
    ${LANE_list}=  Get From Dictionary  ${MODULE_LANE_dict}  ${module_id}
    FOR  ${item}  IN  @{LANE_list}
        Admin Check If LANE Objects Are Unlocked  ${item}  ${timeout}  ${recover_timeout}  ${alias}
    END

Get ethernetEnabled from CABLINK
    [Arguments]  ${module_id}  ${alias}
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${firstEndpointDN_FHS_R}=  Run Keyword And Return Status  Should Contain  ${item['firstEndpointDN']}  FHS_R
        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item['secondEndpointDN']}  RMOD_R
        Run Keyword If  not (${firstEndpointDN_FHS_R} and ${secondEndpointDN_RMOD_R} and '${item['secondEndpointDN']}' == '${module_id}')
        ...  Continue For Loop
        ${CABLNK_L_id}=  Admin Get REF Object  object_dn=${CABLINK_id}  connection=${alias}
        ${CABLNK_L_param}=  coam.Get Parameters  dist_name=${CABLNK_L_id}  connection=${alias}
        ${destinationDistName}=  Set Variable  ${CABLNK_L_param['destinationDistName']}
        ${CONNECTOR_L}=  coam.Get Parameters  dist_name=${destinationDistName}  connection=${alias}
        Exit For Loop
    END
    [Return]  ${CONNECTOR_L['ethernetEnabled']}

Check Entity RMs State
    [Arguments]  ${alias}

    Set Test Variable  ${RM_status_enabled}  operationalState=${Enabled_}
    ${RM_status_check}=  Run Keyword And Return Status
    ...  Assert Every  class_name=RMOD  parameters=${RM_status_enabled}  timeout=10  connection=${alias}

    Run Keyword If  ${RM_status_check}
    ...  Log  ${alias} RMs status: operationalState=Enabled  level=INFO  console=True
    ...  ELSE
    ...  Log  At least one ${alias} RM status is not operationalState=Enabled!  level=INFO  console=True

    [Return]  ${RM_status_check}

Check Entity Cells State
    [Arguments]  ${alias}

    ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
    ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  redundancyRole
    ${CELL_status_check}=  Run Keyword If  '${BTS_redundancyRole}' == 'standby'
    ...  Check standby BTS Entity Cells  ${alias}
    ...  ELSE
    ...  Check BTS Entity Cells  ${alias}

    [Return]  ${CELL_status_check}  ${BTS_redundancyRole}

Check BTS Entity Cells
    [Arguments]  ${alias}
    ${NR_cells_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${NR_cells_status}=  Run Keyword If  ${NR_cells_list}
    ...  Check cells are enabled and online  NRCEL  ${alias}
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${LTE_cells_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${LTE_cells_status}=  Run Keyword If  ${LTE_cells_list}
    ...  Check cells are enabled and online  LNCEL  ${alias}
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${WCDMA_cells_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${WCDMA_cells_status}=  Run Keyword If  ${WCDMA_cells_list}
    ...  Check cells are enabled and online  WNCEL  ${alias}
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${GSM_cells_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${GSM_cells_status}=  Run Keyword If  ${GSM_cells_list}
    ...  Check cells are enabled and online  GNCEL  ${alias}
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${BTS_cells_status}=  Set Variable If
    ...  ${NR_cells_status} and ${LTE_cells_status} and ${WCDMA_cells_status} and ${GSM_cells_status}  ${TRUE}  ${FALSE}

    [Return]  ${BTS_cells_status}

Check cells are enabled and online
    [Arguments]  ${class_name}  ${alias}  ${timeout}=10

    ${CELL_type}=  Set Variable If
    ...  '${class_name}' == 'NRCEL'  NR
    ...  '${class_name}' == 'LNCEL'  LTE
    ...  '${class_name}' == 'WNCEL'  WCDMA
    ...  '${class_name}' == 'GNCEL'  GSM
    Set Test Variable  ${CELL_status_enabled}  operationalState=${Enabled_}
    Set Test Variable  ${CELL_status_enabled_degraded}  operationalState=${Enabled_}, availabilityStatus=${Degraded_}

    ${CELL_status_check}=  Run Keyword And Return Status
    ...  Assert Every  class_name=${class_name}  parameters=${CELL_status_enabled}  timeout=${timeout}  connection=${alias}

    Run Keyword If  not ${CELL_status_check}  Run Keywords
    ...  Log  At least one ${alias} ${CELL_type} cell status is not operationalState=Enabled!  level=INFO  console=True
    ...  AND  Return From Keyword  ${CELL_status_check}

    ${CELL_status_check}=  Run Keyword And Return Status
    ...  Assert No  class_name=${class_name}  parameters=${CELL_status_enabled_degraded}  timeout=3  connection=${alias}

    Run Keyword If  ${CELL_status_check}
    ...  Log  ${alias} ${CELL_type} cells status: operationalState=Enabled, availabilityStatus=Online  level=INFO  console=True
    ...  ELSE
    ...  Log  At least one ${alias} ${CELL_type} cell status is not operationalState=Enabled, availabilityStatus=Online!  level=INFO  console=True

    [Return]  ${CELL_status_check}

Check standby BTS Entity Cells
    [Arguments]  ${alias}
    ${NR_cells_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${NR_cells_status}=  Run Keyword If  ${NR_cells_list}
    ...  Check cells are disabled and offline  NRCEL  ${alias}
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${LTE_cells_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${LTE_cells_status}=  Run Keyword If  ${LTE_cells_list}
    ...  Check cells are disabled and offline  LNCEL  ${alias}
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${WCDMA_cells_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${WCDMA_cells_status}=  Run Keyword If  ${WCDMA_cells_list}
    ...  Check cells are disabled and offline  WNCEL  ${alias}
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${GSM_cells_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${GSM_cells_status}=  Run Keyword If  ${GSM_cells_list}
    ...  Check cells are disabled and offline  GNCEL  ${alias}
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${BTS_cells_status}=  Set Variable If
    ...  ${NR_cells_status} and ${LTE_cells_status} and ${WCDMA_cells_status} and ${GSM_cells_status}  ${TRUE}  ${FALSE}

    [Return]  ${BTS_cells_status}

Check cells are disabled and offline
    [Arguments]  ${class_name}  ${alias}  ${timeout}=10

    ${CELL_type}=  Set Variable If
    ...  '${class_name}' == 'NRCEL'  NR
    ...  '${class_name}' == 'LNCEL'  LTE
    ...  '${class_name}' == 'WNCEL'  WCDMA
    ...  '${class_name}' == 'GNCEL'  GSM
    ${CELL_status_disabled_offline}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Offline_}

    ${CELL_status_check}=  Run Keyword And Return Status
    ...  Assert Every  class_name=${class_name}  parameters=${CELL_status_disabled_offline}  timeout=${timeout}  connection=${alias}

    Run Keyword If  ${CELL_status_check}
    ...  Log  ${alias} ${CELL_type} cells status: operationalState=Disabled, availabilityStatus=Offline  console=True
    ...  ELSE
    ...  Log  At least one ${alias} ${CELL_type} cell status is not operationalState=Disabled, availabilityStatus=Offline!  console=True

    [Return]  ${CELL_status_check}

Get BTS Current Plan Info
    [Arguments]  ${alias}

    ${SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=${BTSFiles}/${alias}
    Set Test Variable  ${${alias.lower()}_scf_initial}  ${SCF_path_file_info}

Check Entity BTS Configuration
    [Documentation]
    ...  Check number of configured and runtime cells and radio modules from classical BTS are properly aligned.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter          | Man. | Description                                                                            |
    ...  | alias              | Yes  | BTS alias                                                                              |
    ...  | ${entity_scf_dict} | No   | Dict with BTS entity alias as key and BTS entity scf path as value;
    ...                                - for classical BTS, key refers to BTS entity (ex. 'Master')
    ...                                - for cloud BTS, key refers to BTS CU and VDUs entities (ex 'Master CU', 'Master VDU1' |
    ...
    ...  *RETURN*
    ...  | Parameter                           | Description   |
    ...  | BTS_configuration_and_runtime_check | True or False |

    [Arguments]  ${alias}  ${entity_scf_dict}=&{EMPTY}

    ${entity_scf_dict_keys}=  Run Keyword If  ${entity_scf_dict} != &{EMPTY}  Get Dictionary Keys  ${entity_scf_dict}
    ...  ELSE  Create List

    ${entity_scf}=  Run Keyword If  '${alias}' in ${entity_scf_dict_keys}  Get From Dictionary  ${entity_scf_dict}  ${alias}
    ...  ELSE  Set Variable  ${${alias.lower()}_scf_initial}

    ${SCF_NR_cell_count}  ${SCF_LTE_cell_count}  ${SCF_WCDMA_cell_count}  ${SCF_GSM_cell_count}  ${SCF_NBIOT_FDD_cell_count}  ${SCF_rmod_count}=
    ...  Get BTS SCF Cells And RMODs Number  ${alias}  ${entity_scf}
    ${RUNTIME_NR_cell_count}  ${RUNTIME_LTE_cell_count}  ${RUNTIME_LTE_IOT_cell_count}  ${RUNTIME_WCDMA_cell_count}  ${RUNTIME_GSM_cell_number}
    ...  ${RUNTIME_rmod_count}=  Get Admin Cells And RMs Number From SBTS  ${alias}  ${single_bts}

    ${NR_cell_conf}=  Run Keyword And Return Status   Should be equal  ${SCF_NR_cell_count}  ${RUNTIME_NR_cell_count}
    ${LTE_cell_conf}=  Run Keyword And Return Status   Should be equal  ${SCF_LTE_cell_count}  ${RUNTIME_LTE_cell_count}
    ${LTE_IOT_cell_conf}=  Run Keyword And Return Status   Should be equal  ${SCF_NBIOT_FDD_cell_count}  ${RUNTIME_LTE_IOT_cell_count}
    ${WCDMA_cell_conf}=  Run Keyword And Return Status   Should be equal  ${SCF_WCDMA_cell_count}  ${RUNTIME_WCDMA_cell_count}
    ${GSM_cell_conf}=  Run Keyword And Return Status   Should be equal  ${SCF_GSM_cell_count}  ${RUNTIME_GSM_cell_number}
    ${BTS_rmod_conf}=  Run Keyword And Return Status   Should be equal  ${SCF_rmod_count}  ${RUNTIME_rmod_count}

    Log  ${alias} configured/running NR cells number: ${SCF_NR_cell_count}/${RUNTIME_NR_cell_count}  console=True
    Log  ${alias} configured/running LTE cells number: ${SCF_LTE_cell_count}/${RUNTIME_LTE_cell_count}  console=True
    Log  ${alias} configured/running LTE IOT number: ${SCF_NBIOT_FDD_cell_count}/${RUNTIME_LTE_IOT_cell_count}  console=True
    Log  ${alias} configured/running WCDMA cells number: ${SCF_WCDMA_cell_count}/${RUNTIME_WCDMA_cell_count}  console=True
    Log  ${alias} configured/running GSM cells number: ${SCF_GSM_cell_count}/${RUNTIME_GSM_cell_number}  console=True
    Log  ${alias} configured/running RMs number: ${SCF_rmod_count}/${RUNTIME_rmod_count}  console=True

    ${condition}=  Create Long String  ${NR_cell_conf} and ${LTE_cell_conf} and ${LTE_IOT_cell_conf} and ${WCDMA_cell_conf} and ${GSM_cell_conf} and
    ...  ${BTS_rmod_conf}
    ${BTS_configuration_and_runtime_check}=  Set Variable If  ${condition}  ${True}  ${False}

    [Return]  ${BTS_configuration_and_runtime_check}

Get chained RMOD from Cablink
    [Arguments]  ${module_id}  ${alias}
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    ${Chained_RMOD_id_list}=  Create List
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${CABLINK_param}=  Query Infomodel  query=get object ${CABLINK_id}  alias=${alias}
        ${firstEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${CABLINK_param.firstEndpointDN}  RMOD_R
        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${CABLINK_param.secondEndpointDN}  RMOD_R
        Run Keyword If  ${firstEndpointDN_RMOD_R} and ${secondEndpointDN_RMOD_R} and '${CABLINK_param.firstEndpointDN}' == '${module_id}'
        ...  Append To List  ${Chained_RMOD_id_list}  ${CABLINK_param.secondEndpointDN}
    END
    [Return]  ${Chained_RMOD_id_list}

Get TargetBD RMOD SW info dict
    [Documentation]
    ...  Keyword providing RMOD SW info dict from TargetBD xml file
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter    | Man. | Description            |
    ...  | TargetBD_xml | Yes  | TargetBD xml file info |
    ...  | productName  | Yes  | RMOD product name      |
    ...
    ...  *RETURN*
    ...  | Parameter                               | Description                          |
    ...  | resourceBuildKey_resourceSWVersion_dict | TargetBD RMOD resourceSWVersion dict |
    ...  | resourceBuildKey_buildTimestamp_dict    | TargetBD RMOD buildTimestamp dict    |

    [Arguments]  ${TargetBD_xml}  ${productName}
    ${resourceBuildKey_list}=  Create List  LTX_${productName}  LTX_${productName}_C1  LTX_${productName}_E1  LTX_${productName}_N1
    ...  LTX_${productName}_S1
    ${resourceBuildKey_resourceSWVersion_dict}=  Create Dictionary
    ${resourceBuildKey_buildTimestamp_dict}=  Create Dictionary

    ${TargetBD_xml_decoded}=  Decode Bytes To String  ${TargetBD_xml}  UTF-8
    ${TargetBD_xml_parsed}=  Parse xml  ${TargetBD_xml_decoded}
    FOR  ${item}  IN  @{resourceBuildKey_list}
        ${resourceBuildKey_status}=  Run Keyword And Return Status
        ...  Element Should Exist  ${TargetBD_xml_parsed}  .//hwResource[@resourceBuildKey="${item}"]
        Continue For Loop If  '${resourceBuildKey_status}' == 'False'
        ${info}=  Get Element Attributes  ${TargetBD_xml_parsed}  .//hwResource[@resourceBuildKey="${item}"]
        Set To Dictionary  ${resourceBuildKey_resourceSWVersion_dict}  ${item}  ${info['resourceSWVersion']}
        ${buildTimestamp_status}=  Run Keyword And Return Status
        ...  Variable Should Exist  ${info['buildTimestamp']}
        ${buildTimestamp_value}=  Set Variable If  ${buildTimestamp_status}  ${info['buildTimestamp']}  None
        Set To Dictionary  ${resourceBuildKey_buildTimestamp_dict}  ${item}  ${buildTimestamp_value}
    END
    [Return]  ${resourceBuildKey_resourceSWVersion_dict}  ${resourceBuildKey_buildTimestamp_dict}

Get BTS running RMOD SW info dict
    [Documentation]
    ...  Keyword providing RMOD SW info dict from BTS
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description             |
    ...  | alias     | Yes  | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                             | Description                                           |
    ...  | RMOD_serialNumber_buildVersion_dict   | RMOD SW info dict: {'serialNumber': 'buildVersion'}   |
    ...  | RMOD_serialNumber_buildTimestamp_dict | RMOD SW info dict: {'serialNumber': 'buildTimestamp'} |
    ...  | RMOD_serialNumber_productName_dict    | RMOD SW info dict: {'serialNumber': 'productName'}    |
    ...  | RMOD_serialNumber_l3Protocol_dict     | RMOD SW info dict: {'serialNumber': 'l3Protocol'}     |
    ...
    [Arguments]  ${alias}

    ${RMOD_serialNumber_buildVersion_dict}=  Create Dictionary
    ${RMOD_serialNumber_buildTimestamp_dict}=  Create Dictionary
    ${RMOD_serialNumber_productName_dict}=  Create Dictionary
    ${RMOD_serialNumber_l3Protocol_dict}=  Create Dictionary

    ${RMOD_id_list}=  coam.Get Ids For All  class_name=RMOD  connection=${alias}
    Sort List  ${RMOD_id_list}

    FOR  ${RMOD_id}  IN  @{RMOD_id_list}

        ${RMOD_param}=  coam.Get Parameters For  class_name=RMOD  id_num=${RMOD_id}  connection=${alias}

        ${RMOD_serialNumber}=  Get From Dictionary  ${RMOD_param}  serialNumber
        ${RMOD_buildVersion}=  Get From Dictionary  ${RMOD_param}  buildVersion
        ${RMOD_productName}=  Get From Dictionary  ${RMOD_param}  productName
        ${RMOD_l3Protocol}=  Get From Dictionary  ${RMOD_param}  l3Protocol

        Set To Dictionary  ${RMOD_serialNumber_buildVersion_dict}  ${RMOD_serialNumber}  ${RMOD_buildVersion}
        Set To Dictionary  ${RMOD_serialNumber_productName_dict}  ${RMOD_serialNumber}  ${RMOD_productName}
        Set To Dictionary  ${RMOD_serialNumber_l3Protocol_dict}  ${RMOD_serialNumber}  ${RMOD_l3Protocol}

        ${BUILD_DATA_L_info}=  coam.Get Managed Objects  class_name=BUILD_DATA_L  connection=${alias}

        ${RMOD_bldTimestamp}=  Get BTS running RMOD SW build timestamp info  ${RMOD_serialNumber}  ${BUILD_DATA_L_info}  ${alias}

        Set To Dictionary  ${RMOD_serialNumber_buildTimestamp_dict}  ${RMOD_serialNumber}  ${RMOD_bldTimestamp}

    END

    [Return]  ${RMOD_serialNumber_buildVersion_dict}  ${RMOD_serialNumber_buildTimestamp_dict}  ${RMOD_serialNumber_productName_dict}
    ...  ${RMOD_serialNumber_l3Protocol_dict}

Get BTS running RMOD SW build timestamp info
    [Arguments]  ${RMOD_sn}  ${BUILD_DATA_L_info}  ${alias}

    ${RU_L_info}=  coam.Get Managed Objects  class_name=RU_L  connection=${alias}

    ${RU_L_id_list}=  Create List

    FOR  ${item}  IN  @{RU_L_info}

       ${RU_L_id}=  Get From Dictionary  ${item}  distName
       ${RU_L_sn}=  Get From Dictionary  ${item['parameters']}  serialNumber

       Run Keyword If  '${RU_L_sn}' == '${RMOD_sn}'  Append To List  ${RU_L_id_list}  ${RU_L_id}

    END

    FOR  ${item}  IN  @{BUILD_DATA_L_info}

       ${BUILD_DATA_L_id}=  Get From Dictionary  ${item}  distName
       ${Obj_id}=  Fetch From Left  ${BUILD_DATA_L_id}  /STORAGE_L

       Continue For Loop If  '${Obj_id}' not in ${RU_L_id_list}

       ${RMOD_bldTimestamp}=  Get From Dictionary  ${item['parameters']}  bldTimestamp

       Exit For Loop

    END

    [Return]  ${RMOD_bldTimestamp}

Compare RMOD buildVersion from TargetBD and BTS
    [Documentation]
    ...  Return newer SW buildVersion by compare ${TargetBD_buildVersion} and ${BTS_buildVersion} based on:
    ...  - if no buildTimestamp available on both TargetBD and BTS, consider buildVersion info compare
    ...  - if no buildTimestamp available on BTS, but available on TargetBD, set TargetBD buildVersion as newer
    ...  - if no buildTimestamp available on TargetBD, but available on BTS, set BTS buildVersion as newer
    ...  - if buildTimestamp available on both TargetBD and BTS, consider buildTimestamp info compare

    [Arguments]  ${TargetBD_buildVersion}  ${BTS_buildVersion}  ${TargetBD_buildTimestamp}  ${BTS_buildTimestamp}
    Return From Keyword If  '${TargetBD_buildTimestamp}' != '' and '${BTS_buildTimestamp}' == ''  ${TargetBD_buildVersion}
    Return From Keyword If  '${TargetBD_buildTimestamp}' == '' and '${BTS_buildTimestamp}' != ''  ${BTS_buildVersion}
    ${Newer_buildVersion}=  Run Keyword If  '${TargetBD_buildTimestamp}' == '' and '${BTS_buildTimestamp}' == ''
    ...  Compare two RM software versions and return newer sw  ${TargetBD_buildVersion}  ${BTS_buildVersion}
    Return From Keyword If  '${TargetBD_buildTimestamp}' == '' and '${BTS_buildTimestamp}' == ''  ${Newer_buildVersion}
    ${Diff_Time}=  DateTime.Subtract Date From Date  ${TargetBD_buildTimestamp}  ${BTS_buildTimestamp}  number
    ${Newer_buildVersion}=  Set Variable If  ${Diff_Time} > 0  ${TargetBD_buildVersion}  ${Diff_Time} < 0  ${BTS_buildVersion}  Equal
    [Return]  ${Newer_buildVersion}


Highlight Log
    [Arguments]  ${message}  ${level}=INFO  ${console}=True
    ${delimiter}=  set variable  ==================================================================================
    ${highlight}=  set variable  *****
    Log  ${delimiter}  level=${level}  console=${console}
    Log  ${highlight} ${message} ${highlight}  level=${level}  console=${console}
    Log  ${delimiter}  level=${level}  console=${console}

Check Optical Switch definition info
    [Documentation]
    ...  Check Optical Switch definition info for optical connector (BTS module side) and optical switch port (CALIENT side)
    ...  in optical_switch_ports.yaml

    [Arguments]  ${MODULE_type}  ${MODULE_sn}  ${MODULE_connector_name}

    ${OPTICAL_SWITCH_PORTS_keys}=  Get Dictionary Keys  ${OPTICAL_SWITCH_PORTS}
    ${OPTICAL_SWITCH_PORTS_values}=  Get Dictionary Values  ${OPTICAL_SWITCH_PORTS}

    ${MODULE_label}=  Catenate  SEPARATOR=_  ${MODULE_type}  ${MODULE_sn}

    Log  Check Optical Switch definition info for ${MODULE_label} item:  console=True
    Run Keyword If  '${MODULE_label}' in ${OPTICAL_SWITCH_PORTS_keys}
    ...  Log  - ${MODULE_label} item defined in optical_switch_ports.yaml!  console=True
    ...  ELSE  Run Keywords
    ...  Log  - ${MODULE_label} item not defined in optical_switch_ports.yaml!  level=ERROR
    ...  AND  Fail  Execution ended

    Log  Check Optical Switch definition info for ${MODULE_connector_name} item:  console=True
    FOR  ${item_key}  ${item_value}  IN ZIP  ${OPTICAL_SWITCH_PORTS_keys}  ${OPTICAL_SWITCH_PORTS_values}
        Continue For Loop If  '${item_key}' != '${MODULE_label}'
        ${status}=  Run Keyword And Return Status  Variable Should Exist  ${item_value['${MODULE_connector_name}']}
        Run Keyword If  ${status}
        ...  Log  - ${MODULE_connector_name} : ${item_value['${MODULE_connector_name}']} item defined in optical_switch_ports.yaml!  console=True
        ...  ELSE  Run Keywords
        ...  Log  - ${MODULE_connector_name} item not defined in optical_switch_ports.yaml!  level=ERROR
        ...  AND  Fail  Execution ended
        Set Test Variable  ${${MODULE_type}_${MODULE_sn}_${MODULE_connector_name}_cross_connection}  ${item_value['${MODULE_connector_name}']}
        Exit For Loop If  ${status}
    END

Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values
    [Documentation]
    ...  Get feature CB007878 info related to actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description             |
    ...  | RMOD_id   | Yes  | RMOD id runtime view    |
    ...  | alias     | Yes  | alias of admin instance |
    ...
    ...  *RETURN VALUE*
    ...  | Parameter                    | Description                                |
    ...  | actSharedRUIndControl        | actSharedRUIndControl value: true or false |
    ...  | peerBtsActSharedRUIndControl | peerBtsActSharedRUIndControl value: true or false |

    [Arguments]  ${RMOD_id}  ${alias}

    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${RMOD_dn_runtime}=  Get RMOD SCF runtime distinguished name  ${RMOD_id}  ${alias}
    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects
    ${actSharedRUIndControl_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${RMOD_dn}
    ...  p_name=actSharedRUIndControl
    ${peerBtsActSharedRUIndControl_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${RMOD_dn_runtime}
    ...  p_name=peerBtsActSharedRUIndControl

    ${status}  ${actSharedRUIndControl}=  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${actSharedRUIndControl_info_dict}  actSharedRUIndControl
    ${actSharedRUIndControl}=  Set Variable If  '${status}' == 'PASS'  ${actSharedRUIndControl}  ${EMPTY}
    ${status}  ${peerBtsActSharedRUIndControl}=  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${peerBtsActSharedRUIndControl_info_dict}  peerBtsActSharedRUIndControl
    ${peerBtsActSharedRUIndControl}=  Set Variable If  '${status}' == 'PASS'  ${peerBtsActSharedRUIndControl}  ${EMPTY}

    [Return]  ${actSharedRUIndControl}  ${peerBtsActSharedRUIndControl}

Get BTS object configuration info related to object runtime info
    [Documentation]
    ...  Get BTS object configuration info related to object runtime info
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description                       |
    ...  | obj_R_id  | Yes  | Object runtime view id            |
    ...  | alias     | Yes  | alias of admin_infomodel instance |
    ...
    ...  *RETURN VALUE*
    ...  | Parameter | Description             |
    ...  | obj_A_id  | Object configuration id |

    [Arguments]  ${obj_R_id}  ${alias}
    ${obj_R_param}=  Query Infomodel  get object ${obj_R_id}  alias=${alias}
    ${configDN_status}=  Run Keyword And Return Status  Variable Should Exist  ${obj_R_param.configDN}
    Return From Keyword If  ${configDN_status}  ${obj_R_param.configDN}
    ${CONF_REF_obj}=  Query Infomodel  get object ${obj_R_id}/CONF_REF-1  alias=${alias}
    [Return]  ${CONF_REF_obj.distName}

Set actSharedRUIndControl parameter value
    [Documentation]
    ...  Set feature CB007878 actSharedRUIndControl parameter value: True or False on requested shared RMOD
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                        |
    ...  | RMOD_id   | Yes  | RMOD id runtime view                               |
    ...  | value     | Yes  | Value for actSharedRUIndControl set: True or False |
    ...  | alias     | Yes  | alias of admin instance                            |
    ...
    [Arguments]  ${RMOD_id}  ${value}  ${alias}
    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    coam.Perform Parameter Recommissioning  dist_name=${RMOD_dn}  parameter=actSharedRUIndControl  operation=update  value=${value}
    ...  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s
    ${actSharedRUIndControl}  ${EMPTY}=  Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values   ${RMOD_id}  ${alias}
    ${actSharedRUIndControl}=  Convert To String  ${actSharedRUIndControl}
    ${actSharedRUIndControl}=  Convert To Lower Case  ${actSharedRUIndControl}
    Run Keyword If  '${actSharedRUIndControl}' == '${value}'
    ...  Log  Parameter actSharedRUIndControl = ${actSharedRUIndControl}, successfully commissioned!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter actSharedRUIndControl = ${actSharedRUIndControl}, not properly commissioned!  level=ERROR
    ...  AND  Fail  Parameter actSharedRUIndControl = ${actSharedRUIndControl}, not properly commissioned!

Get RMOD SCF distinguished name
    [Documentation]
    ...  KW used to get RMOD SCF distinguished name

    [Arguments]  ${RMOD_R_id}  ${alias}
    ${BTS_info}=  Get Bts Info  connection=${alias}
    FOR  ${item}  IN  @{BTS_info['radioModules']['rmod']}
        Exit For Loop If  '${item['id']['internal']}' == '${RMOD_R_id}'
    END
    Run Keyword If  '${item['id']['internal']}' != '${RMOD_R_id}'
    ...  Fail  RMOD with id ${RMOD_R_id} not found in BTS info!
    [Return]  ${item['id']['configuration']}

Get FHS SCF distinguished name
    [Documentation]
    ...  KW used to get FHS SCF distinguished name

    [Arguments]  ${FHS_R_id}  ${alias}
    ${BTS_info}=  Get Bts Info  connection=${alias}
    FOR  ${item}  IN  @{BTS_info['fhs']}
        Exit For Loop If  '${item['id']['internal']}' == '${FHS_R_id}'
    END
    Run Keyword If  '${item['id']['internal']}' != '${FHS_R_id}'
    ...  Fail  FHS with id ${FHS_R_id} not found in BTS info!
    [Return]  ${item['id']['configuration']}

Get RMOD SCF runtime distinguished name
    [Documentation]
    ...  KW used to get RMOD SCF runtime distinguished name

    [Arguments]  ${RMOD_R_id}  ${alias}
    ${BTS_info}=  Get Bts Info  connection=${alias}
    FOR  ${item}  IN  @{BTS_info['radioModules']['rmod']}
        Exit For Loop If  '${item['id']['internal']}' == '${RMOD_R_id}'
    END
    Run Keyword If  '${item['id']['internal']}' != '${RMOD_R_id}'
    ...  Fail  RMOD with id ${RMOD_R_id} not found in BTS info!
    [Return]  ${item['id']['runtime']}

Get SMOD SCF distinguished name
    [Documentation]
    ...  KW used to get SMOD SCF distinguished name

    [Arguments]  ${SMOD_R_id}  ${alias}
    ${BTS_info}=  Get Bts Info  connection=${alias}
    FOR  ${item}  IN  @{BTS_info['systemModules']}
        Exit For Loop If  '${item['id']['internal']}' == '${SMOD_R_id}'
    END
    Run Keyword If  '${item['id']['internal']}' != '${SMOD_R_id}'
    ...  Fail  SMOD with id ${SMOD_R_id} not found in BTS info!
    [Return]  ${item['id']['configuration']}

Get BBMOD SCF distinguished name
    [Documentation]
    ...  KW used to get BBMOD SCF distinguished name

    [Arguments]  ${BBMOD_R_id}  ${alias}
    ${BTS_info}=  Get Bts Info  connection=${alias}
    FOR  ${item}  IN  @{BTS_info['basebandModules']}
        Exit For Loop If  '${item['id']['internal']}' == '${BBMOD_R_id}'
    END
    Run Keyword If  '${item['id']['internal']}' != '${BBMOD_R_id}'
    ...  Fail  BBMOD with id ${BBMOD_R_id} not found in BTS info!
    ${result}=  Get Variable Value  ${item['id']['configuration']}  ${None}
    [Return]  ${result}

Get BBMOD SCF runtime distinguished name
    [Documentation]
    ...  KW used to get BBMOD SCF runtime distinguished name

    [Arguments]  ${BBMOD_R_id}  ${alias}
    ${BTS_info}=  Get Bts Info  connection=${alias}
    FOR  ${item}  IN  @{BTS_info['basebandModules']}
        Exit For Loop If  '${item['id']['internal']}' == '${BBMOD_R_id}'
    END
    Run Keyword If  '${item['id']['internal']}' != '${BBMOD_R_id}'
    ...  Fail  BBMOD with id ${BBMOD_R_id} not found in BTS info!
    [Return]  ${item['id']['runtime']}

Get CELL SCF runtime distinguished name
    [Documentation]
    ...  KW used to get CELL SCF runtime distinguished name

	[Arguments]  ${CELL_R_id}  ${alias}  ${cell_type}=nr
    ${cell_info}=  Get Cells Info  cell_type=${cell_type}  connection=${alias}
    FOR  ${item}  IN  @{cell_info}
        Exit For Loop If  '${item['id']['internal']}' == '${CELL_R_id}'
    END
    Run Keyword If  '${item['id']['internal']}' != '${CELL_R_id}'
    ...  Fail  CELL with id ${CELL_R_id} not found in ${cell_type} cells info!
    [Return]  ${item['id']['configuration']}

Set Hardware File Flags
    [Documentation]
    ...  Set desired Hardware File(Swconfig) Flags
    ...
    ...  *AUTHOR*
    ...  horea.olar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Mandatory | Description                               |
    ...  | swconfig_flag_action | Yes       | possible values: add or remove            |
    ...  | swconfig_flag_list   | Yes       | list of flags to add/remove from swconfig |
    ...  | alias                | Yes       | admin instance alias                      |
    ...  | username             | No        | username for ssh connection               |
    ...  | password             | No        | password for ssh connection               |
    ...  | keypath              | No        | key location for ssh connection           |
    ...
    [Arguments]  ${swconfig_flag_action}  ${swconfig_flag_list}  ${alias}  ${username}=ute  ${password}=ute  ${keypath}=/home/ute/.ssh/id_rsa
    ${flags_list}=  Create List
    ${flags_list}=  Split String  ${swconfig_flag_list}
    Change SW Config Flags  action=${swconfig_flag_action}  flags=${flags_list}  alias=${alias}  username=${username}  password=${password}
    ...  key_path=${keypath}

Change SW Config Flags
    [Documentation]
    ...  Add or remove flags from swconfig.txt

    [Arguments]  ${action}  ${flags}  ${alias}  ${username}  ${password}=None  ${key_path}=None

    ${hostname}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ${remote_host}=  Set Variable If  '${alias}'=='Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ${ip_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${swconfig_status}=  Execute Command on SM via SSH TAF  command=cd /ffs/run; ls | grep swconfig.txt  via_ip=${remote_host}
    ...  via_username=${username}  via_password=${password}  key_path=${key_path}  alias=${alias}_ssh
    ${swconfig_existence}=  Get Regexp Matches  ${swconfig_status}  swconfig\.txt
    Run Keyword If  not ${swconfig_existence}  Run Keywords
    ...  Log  swconfig.txt is missing!  console=True
    ...  AND  Fail  swconfig.txt is missing!
    ${swconfig}=  Execute Command on SM via SSH TAF  command=cat /ffs/run/swconfig.txt  via_ip=${remote_host}  via_username=${username}
    ...  via_password=${password}  key_path=${key_path}  alias=${alias}_ssh
    Run Keyword If  '${action}'=='add'  Set Test Variable  ${${alias}_swconfig_initial}  ${swconfig}
    ${reset_needed}=  Set Variable  False
    FOR  ${flag}  IN  @{flags}
        ${swconfig}=  Execute Command on SM via SSH TAF  command=cat /ffs/run/swconfig.txt  via_ip=${remote_host}  via_username=${username}
        ...  via_password=${password}  key_path=${key_path}  alias=${alias}_ssh
        ${reset_needed}=  Run Keyword If  '${action}'=='add'
        ...  Add Hardware File Flag  ${swconfig}  ${flag}  ${remote_host}  ${username}  ${password}  ${key_path}  ${alias}  ${reset_needed}
        ...  ELSE IF  '${action}'=='remove'
        ...  Remove Hardware File Flag  ${swconfig}  ${flag}  ${remote_host}  ${username}  ${password}  ${key_path}  ${alias}  ${reset_needed}
    END
    Execute command on SM via SSH TAF  command=cd /ffs/run ; crasign swconfig.txt  via_ip=${remote_host}  via_username=${username}
    ...  via_password=${password}  key_path=${key_path}  alias=${alias}_ssh
    Run Keyword If  ${reset_needed}  Run Keywords
    ...  Log  Performing Site Reset in order to activate swconfig.txt changes  console=True
    ...  AND  coam.Reset  reset_coverage=Site  wait_for_reconnection=False  alias=${alias}
    ...  AND  Wait For Target To Be Not Reachable TAF  hostname=${ip_address}  remote_host=${remote_host}  timeout=300
    ...  AND  Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias}
    Set Test Variable  ${reset_needed_initial}  ${reset_needed}

Add Hardware File Flag
    [Arguments]  ${swconfig}  ${flag}  ${remote_host}  ${username}  ${password}=None  ${key_path}=None  ${alias}=None  ${reset_needed}=False
    ${status_flag=0}=  Get Lines Matching Regexp  ${swconfig}  ^${flag}=0
    ${status_flag=1}=  Get Lines Matching Regexp  ${swconfig}  ^${flag}=1
    Run Keyword If  '${status_flag=1}' != ''
    ...  Replace String  ${swconfig}  ${flag}=1  ${flag}=0
    Run Keyword If  '${status_flag=1}' != ''
    ...  Execute Command On SM via SSH TAF  command=cd /ffs/run ; echo "${sw_config}" > swconfig.txt  via_ip=${remote_host}
    ...  via_username=${username}  via_password=${password}  key_path=${key_path}  alias=${alias}_ssh
    ...  ELSE IF  '${status_flag=0}' == ''
    ...  Execute Command On SM via SSH TAF  command=cd /ffs/run/ ; echo ${flag}=0 >> swconfig.txt  via_ip=${remote_host}
    ...  via_username=${username}  via_password=${password}  key_path=${key_path}  alias=${alias}_ssh

    ${reset_needed}=  Set Variable If  '${status_flag=0}' == '' or '${status_flag=1}' != ''  True  ${reset_needed}
    Run Keyword If  '${status_flag=0}' == '' or '${status_flag=1}' != ''  Log  Adding ${flag}=0 flag to swconfig.txt  console=True

    [Return]  ${reset_needed}

Remove Hardware File Flag
    [Arguments]  ${swconfig}  ${flag}  ${remote_host}  ${username}  ${password}=None  ${key_path}=None  ${alias}=None  ${reset_needed}=False

    Run Keyword If  not ${reset_needed_initial}  Return From Keyword  False

    ${status_flag=0}=  Get Lines Matching Regexp  ${swconfig}  ^${flag}=0
    Execute Command On SM via SSH TAF  command=cd /ffs/run ; echo -n "${${alias}_swconfig_initial}" > swconfig.txt  via_ip=${remote_host}
    ...  via_username=${username}  via_password=${password}  key_path=${key_path}  alias=${alias}_ssh
    ${reset_needed}=  Set Variable If  '${status_flag=0}' == ''  ${reset_needed}  True

    [Return]  ${reset_needed}

Get actIndSwUpgradeForSharedRU parameter value
    [Documentation]
    ...  Get feature CB006028 info related to actIndSwUpgradeForSharedRU parameter value.
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description             |
    ...  | RMOD_id   | Yes  | RMOD id runtime view    |
    ...  | alias     | Yes  | alias of admin instance |
    ...
    ...  *RETURN VALUE*
    ...  | Parameter                  | Description                                             |
    ...  | actIndSwUpgradeForSharedRU | actIndSwUpgradeForSharedRU value: true or false or none |

    [Arguments]  ${RMOD_id}  ${alias}

    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects
    ${actIndSwUpgradeForSharedRU_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${RMOD_dn}
    ...  p_name=actIndSwUpgradeForSharedRU
    ${actIndSwUpgradeForSharedRU_count}=  Get Length  ${actIndSwUpgradeForSharedRU_info_dict}
    ${actIndSwUpgradeForSharedRU}=  Run Keyword If  ${actIndSwUpgradeForSharedRU_count} > 0
    ...  Get From Dictionary  ${actIndSwUpgradeForSharedRU_info_dict}  actIndSwUpgradeForSharedRU
    ...  ELSE
    ...  Set Variable  none

    [Return]  ${actIndSwUpgradeForSharedRU}

Set actIndSwUpgradeForSharedRU parameter value
    [Documentation]
    ...  Set feature CB006028 actIndSwUpgradeForSharedRU parameter value: true or false or none on requested shared RMOD
    ...
    ...  | Parameter                  | Man. | Description                            |
    ...  | RMOD_id                    | Yes  | RMOD id runtime view                   |
    ...  | actIndSwUpgradeForSharedRU | Yes  | parameter value: true or false or none |
    ...  | alias                      | Yes  | alias of admin instance                |
    ...
    [Arguments]  ${RMOD_id}  ${actIndSwUpgradeForSharedRU}  ${alias}

    ${actIndSwUpgradeForSharedRU_value}=  Get actIndSwUpgradeForSharedRU parameter value  ${RMOD_id}  ${alias}

    Run Keyword If  '${actIndSwUpgradeForSharedRU_value}' == '${actIndSwUpgradeForSharedRU}'  Run Keywords
    ...  Log Long String  Parameter actIndSwUpgradeForSharedRU: ${actIndSwUpgradeForSharedRU_value} already set on BTS ${alias} RMOD id ${RMOD_id},
    ...  commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${operation}=  Set Variable If  '${actIndSwUpgradeForSharedRU}' == 'none'  delete  update

    coam.Perform Parameter Recommissioning  dist_name=${RMOD_dn}  parameter=actIndSwUpgradeForSharedRU  operation=${operation}
    ...  value=${actIndSwUpgradeForSharedRU}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    ${actIndSwUpgradeForSharedRU_value}=  Get actIndSwUpgradeForSharedRU parameter value  ${RMOD_id}  ${alias}

    Run Keyword If  '${actIndSwUpgradeForSharedRU_value}' == '${actIndSwUpgradeForSharedRU}'
    ...  Log Long String  Parameter actIndSwUpgradeForSharedRU set on BTS ${alias} RMOD id ${RMOD_id}: ${actIndSwUpgradeForSharedRU_value},
    ...  successfully commissioned!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter actIndSwUpgradeForSharedRU not properly set on BTS ${alias} RMOD id ${RMOD_id}! (expected/found value:
    ...  ${actIndSwUpgradeForSharedRU}/${actIndSwUpgradeForSharedRU_value})  console=True
    ...  AND  Fail  Parameter actIndSwUpgradeForSharedRU not properly set on BTS ${alias} RMOD id ${RMOD_id}!

Get shutdownNogNBCellTmr parameter value
    [Documentation]
    ...  Get NR BTS shutdownNogNBCellTmr parameter value.
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description             |
    ...  | alias     | Yes  | alias of admin instance |
    ...
    ...  *RETURN VALUE*
    ...  | Parameter            | Description                                       |
    ...  | nrbts_dn             | NRBTS dn                                          |
    ...  | shutdownNogNBCellTmr | shutdownNogNBCellTmr value: integer value         |

    [Arguments]  ${alias}

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${nrbts_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRBTS-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}

    ${nrbts_dn_list_len}=  Get Length  ${nrbts_dn_list}
    Run Keyword If  ${nrbts_dn_list_len}==0  Fail  No NRBTS object found on BTS ${alias}!

    ${nrbts_dn}=  Get From List  ${nrbts_dn_list}  0

    ${shutdownNogNBCellTmr_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${nrbts_dn}
    ...  p_name=shutdownNogNBCellTmr
    ${shutdownNogNBCellTmr_count}=  Get Length  ${shutdownNogNBCellTmr_info_dict}
    Run Keyword If  ${shutdownNogNBCellTmr_count} == 0  Fail  Parameter shutdownNogNBCellTmr not found on BTS ${alias}!
    ${shutdownNogNBCellTmr}=  Get From Dictionary  ${shutdownNogNBCellTmr_info_dict}  shutdownNogNBCellTmr

    [Return]  ${nrbts_dn}  ${shutdownNogNBCellTmr}

Set shutdownNogNBCellTmr parameter value
    [Documentation]
    ...  Set NR BTS shutdownNogNBCellTmr parameter value
    ...
    ...  | Parameter              | Man. | Description                               |
    ...  | shutdownNogNBCellTmr   | Yes  | parameter value: integer value (0 to 480) |
    ...  | alias                  | Yes  | alias of admin instance                   |
    ...
    [Arguments]  ${shutdownNogNBCellTmr}  ${alias}

    ${nrbts_dn}  ${shutdownNogNBCellTmr_value}=  Get shutdownNogNBCellTmr parameter value  ${alias}

    Run Keyword If  '${shutdownNogNBCellTmr_value}' == '${shutdownNogNBCellTmr}'  Run Keywords
    ...  Log Long String  Parameter shutdownNogNBCellTmr: ${shutdownNogNBCellTmr_value} already set on BTS ${alias},
    ...  commissioning not needed!  console=True
    ...  AND  Return From Keyword

    coam.Perform Parameter Recommissioning  dist_name=${nrbts_dn}  parameter=shutdownNogNBCellTmr  operation=update
    ...  value=${shutdownNogNBCellTmr}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    ${nrbts_dn}  ${shutdownNogNBCellTmr_value}=  Get shutdownNogNBCellTmr parameter value  ${alias}

    Run Keyword If  '${shutdownNogNBCellTmr_value}' == '${shutdownNogNBCellTmr}'
    ...  Log  Parameter shutdownNogNBCellTmr set on BTS ${alias}: ${shutdownNogNBCellTmr_value}, successfully commissioned!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter shutdownNogNBCellTmr not properly set on BTS ${alias}! (expected/found value:
    ...  ${shutdownNogNBCellTmr}/${shutdownNogNBCellTmr_value})  console=True
    ...  AND  Fail  Parameter shutdownNogNBCellTmr not properly set on BTS ${alias}!

Set Primary Link status for shared RMOD
    [Documentation]
    ...  KW used to set shared RMOD Primary Link status on requested BTS by one of following procedures:
    ...  - peer BTS reset; if needed continue with peer BTS power OFF/ON.
    ...  - peer BTS LANE lock unlock procedure.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                      | Man. | Default  | Description                                    |
    ...  | procedure_for_Primary_Link_set | Yes  |          | procedure to set Primary Link: BTS or LANE     |
    ...  | alias                          | Yes  |          | requested BTS alias to set Primary Link        |
    ...  | wait_for_Primary_Link_set      | No   | 120      | time to wait for Primary Link set on BTS alias |
    ...
    [Arguments]  ${procedure_for_Primary_Link_set}  ${alias}  ${wait_for_Primary_Link_set}=120

    Run Keyword If  '${procedure_for_Primary_Link_set}' == 'BTS'
    ...  Set Primary Link status by BTS reset procedure  alias=${alias}  wait_for_Primary_Link_set=${wait_for_Primary_Link_set}
    ...  ELSE IF  '${procedure_for_Primary_Link_set}' == 'LANE'
    ...  Set Primary Link status by LANE lock unlock procedure  alias=${alias}  wait_for_Primary_Link_set=${wait_for_Primary_Link_set}

Set Primary Link status by BTS reset procedure
    [Documentation]
    ...  KW used to set shared RMOD Primary Link status on requested BTS by peer BTS reset procedure.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                 | Man. | Default | Description                                |
    ...  | alias                     | Yes  |         | requested BTS alias to set Primary Link    |
    ...  | wait_for_Primary_Link_set | Yes  | 120     | time to wait for Primary Link set on alias |
    ...
    [Arguments]  ${alias}  ${wait_for_Primary_Link_set}=120

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    ${Primary_Link_status}=  Check Primary Link status for shared RMOD  ${alias}
    Run Keyword If  ${Primary_Link_status}  Run Keywords
    ...  Log  All shared RMOD Primary Link already set on BTS ${alias}, no action needed!  console=True
    ...  AND  Return From Keyword

    Log  BTS ${peer_alias} reset will be performed in order to set Primary Link on BTS ${alias}!  console=True
    coam.Reset Site  alias=${peer_alias}
    Sleep  120s
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=${peer_alias}
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=${alias}

    ${Primary_Link_status}=  Check Primary Link status for shared RMOD  ${alias}
    Run Keyword If  ${Primary_Link_status}  Run Keywords
    ...  Log  All shared RMOD Primary Link set on BTS ${alias}, due to BTS ${peer_alias} reset!  console=True
    ...  AND  Return From Keyword

    Log  Not all shared RMOD Primary Link set on BTS ${alias} due to BTS ${peer_alias} reset, try BTS ${peer_alias} power off/on!  console=True
    Log  BTS ${peer_alias} power off/on will be performed in order to set Primary Link on BTS ${alias}!  console=True
    Pdu BTS Interface Off  ${peer_alias.lower()}_fsm
    Log  Wait ${wait_for_Primary_Link_set} seconds for Primary Link establishment  console=True
    Sleep  ${wait_for_Primary_Link_set}s
    Pdu BTS Interface On  ${peer_alias.lower()}_fsm
    Sleep  180s
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=${peer_alias}
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=${alias}

    ${Primary_Link_status}=  Check Primary Link status for shared RMOD  ${alias}
    Run Keyword If  ${Primary_Link_status}
    ...  Log  All shared RMOD Primary Link set on BTS ${alias}, due to BTS ${peer_alias} power off/on!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Not all shared RMOD Primary Link set on BTS ${alias}, failed!  level=ERROR
    ...  AND  Fail  Not all shared RMOD Primary Link Link set on BTS ${alias}, failed!

Set Primary Link status by LANE lock unlock procedure
    [Documentation]
    ...  KW used to set shared RMOD Primary Link status on requested BTS by peer BTS LANE lock unlock procedure.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                 | Man. | Default | Description                                |
    ...  | alias                     | Yes  |         | requested BTS alias to set Primary Link    |
    ...  | wait_for_Primary_Link_set | Yes  | 120     | time to wait for Primary Link set on alias |
    ...
    [Arguments]  ${alias}  ${wait_for_Primary_Link_set}=120

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    ${Primary_Link_status}=  Check Primary Link status for shared RMOD  ${alias}
    Run Keyword If  ${Primary_Link_status}  Run Keywords
    ...  Log  All shared RMOD Primary Link already set on BTS ${alias}, no action needed!  console=True
    ...  AND  Return From Keyword

    Log  BTS ${peer_alias} Lock Unlock LANE will be performed in order to set Primary Link on BTS ${alias} for needed shared RMOD!
    ...  console=True
    Get BTS MODULE LANE info dict  RMOD  ${peer_alias}
    Perform Lock Unlock LANE on request  RMOD  ${peer_alias}  ${alias}  ${wait_for_Primary_Link_set}
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=${peer_alias}
    Admin Check all BTS cells expected states  expected_state=operationalState=${Enabled_}  alias=${alias}

    ${Primary_Link_status}=  Check Primary Link status for shared RMOD  ${alias}
    Run Keyword If  ${Primary_Link_status}
    ...  Log  All shared RMOD Primary Link set on BTS ${alias}, after lock and unlock BTS ${peer_alias} LANE procedure !  console=True
    ...  ELSE  Run Keywords
    ...  Log  Not all shared RMOD Primary Link set on BTS ${alias}, failed!  level=ERROR
    ...  AND  Fail  Not all shared RMOD Primary Link set on BTS ${alias}, failed!

Check Primary Link status for shared RMOD
    [Documentation]
    ...  KW used to check shared RMOD Primary Link status on Master or Slave BTS.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter   | Man. | Default | Description                                  |
    ...  | alias       | Yes  |         | requested BTS alias to have Primary Link set |
    ...
    ...  *RETURN VALUE*
    ...  | Primary_Link_status | True (if all RMOD Primary Link are set on requested BTS ${alias}) or False |
    ...
    [Arguments]  ${alias}

    ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}=  Get Primary Link status for shared RMOD
    ${Master_keys}=  Get Dictionary Keys  ${Master_Primary_Link_dict}  False
    ${Slave_keys}=  Get Dictionary Keys  ${Slave_Primary_Link_dict}  False
    ${Primary_Link_status}=  Set Variable  ${True}
    FOR  ${Master_key}  ${Slave_key}  IN ZIP  ${Master_keys}  ${Slave_keys}
        ${Master_value}=  Get From Dictionary  ${Master_Primary_Link_dict}  ${Master_key}
        ${Slave_value}=  Get From Dictionary  ${Slave_Primary_Link_dict}  ${Slave_key}
        ${module_SN}=  Get From Dictionary  ${Master_module_ID_SN_dict}  ${Master_key}
        ${RMOD_L3Protocol}=  Get From Dictionary  ${RMOD_L3Protocol_dict}  ${Master_key}
        ${info_level}=  Set Variable If  '${RMOD_L3Protocol}' in ['CPRI_RP1','ECPRI_MPLANE']  BTS side
        ...  '${RMOD_L3Protocol}' in ['CPRI_ALU']  RMOD side
        Log  Primary Link status (${info_level}) for shared RMOD with SN ${module_SN}:  console=True
        Log  - BTS Master RMOD ${Master_key}: ${Master_value}  console=True
        Log  - BTS Slave RMOD ${Slave_key}: ${Slave_value}  console=True
        Run Keyword If  'True' in '${Master_value}' and 'True' in '${Slave_value}'  Run Keywords
        ...  Log  Primary Link status (${info_level}) set on True on both BTS, not reliable value!  level=ERROR
        ...  AND  Fail  Primary Link status (${info_level}) set on True on both BTS, not reliable value!
        Run Keyword If  'True' not in '${Master_value}' and 'True' not in '${Slave_value}'  Run Keywords
        ...  Log  Primary Link status (${info_level}) not set on True on any BTS, not reliable value!  level=ERROR
        ...  AND  Fail  Primary Link status (${info_level}) not set on True on any BTS, not reliable value!
        ${Primary_Link_status}=  Set Variable If
        ...  ('${alias}' == 'Master' and 'True' in '${Master_value}') or ('${alias}' == 'Slave' and 'True' in '${Slave_value}')
        ...  ${Primary_Link_status}  ${False}
    END
    [Return]  ${Primary_Link_status}

Get Primary Link status for shared RMOD
    [Documentation]
    ...  KW used to get shared RMOD Primary Link status on Master or Slave BTS.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN VALUE*
    ...  | Master_Primary_Link_dict | Dictionary with key Master shared RMOD Id and value True/False |
    ...  | Slave_Primary_Link_dict  | Dictionary with key Slave shared RMOD Id and value True/False  |
    ...

    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  Master
    Set Test Variable  ${RMOD_L3Protocol_dict}
    ${Master_Primary_Link_dict}=  Create Dictionary
    ${Slave_Primary_Link_dict}=  Create Dictionary
    FOR  ${Master_RMOD_id}  ${Slave_RMOD_id}  IN ZIP  ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}
        ${RMOD_L3Protocol}=  Get From Dictionary  ${RMOD_L3Protocol_dict}  ${Master_RMOD_id}
        ${Master_RMOD_Primary_Link_info}=  Run Keyword If  '${RMOD_L3Protocol}' in ['CPRI_RP1','ECPRI_MPLANE']
        ...  Get linkModeSynchronization from CABLINK   ${Master_RMOD_id}  Master
        ${Slave_RMOD_Primary_Link_info}=  Run Keyword If  '${RMOD_L3Protocol}' in ['CPRI_RP1','ECPRI_MPLANE']
        ...  Get linkModeSynchronization from CABLINK   ${Slave_RMOD_id}  Slave
        Run Keyword If  '${RMOD_L3Protocol}' in ['CPRI_RP1','ECPRI_MPLANE']  Run Keywords
        ...  Set To Dictionary  ${Master_Primary_Link_dict}  ${Master_RMOD_id}  ${Master_RMOD_Primary_Link_info}
        ...  AND  Set To Dictionary  ${Slave_Primary_Link_dict}  ${Slave_RMOD_id}  ${Slave_RMOD_Primary_Link_info}
        ${Master_RMOD_Primary_Link_info}  ${Slave_RMOD_Primary_Link_info}=  Run Keyword If  '${RMOD_L3Protocol}' == 'CPRI_ALU'
        ...  Get Primary Link status for shared fALU RMOD  ${Master_RMOD_id}
        Run Keyword If  '${RMOD_L3Protocol}' == 'CPRI_ALU'  Run Keywords
        ...  Set To Dictionary  ${Master_Primary_Link_dict}  ${Master_RMOD_id}  ${Master_RMOD_Primary_Link_info}
        ...  AND  Set To Dictionary  ${Slave_Primary_Link_dict}  ${Slave_RMOD_id}  ${Slave_RMOD_Primary_Link_info}
    END
    [Return]  ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}

Get Primary Link status for shared fALU RMOD
    [Documentation]
    ...  KW used to get Primary Link status for shared fALU RMOD on Master and Slave
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter          | Man. | Default         | Description             |
    ...  | Master_RMOD_id     | Yes  |                 | Master shared module id |
    ...  | BTS_login          | No   | ${BTS_USERNAME} | BTS username            |
    ...  | BTS_pwd            | No   | ${BTS_PASSWORD} | BTS password            |
    ...
    ...  *RETURN VALUE*
    ...  | Master_Primary_Link_status | RMOD Primary Link info |
    ...  | Slave_Primary_Link_status  | RMOD Primary Link info |

    [Arguments]  ${RMOD_id}  ${BTS_login}=${BTS_USERNAME}  ${BTS_pwd}=${BTS_PASSWORD}
    ${Master_RMOD_Primary_Link_info}=  Create List
    ${Slave_RMOD_Primary_Link_info}=  Create List
    ${FHNET_address}=  Set Variable If  '${MASTER['MASTER_SUBRACK']}' == '1'  0x1018  '${MASTER['MASTER_SUBRACK']}' == '4'  0x2018
    ${RMOD_param}=  Get Parameters For  class_name=RMOD  id_num=${RMOD_id}  connection=Master
    SSHLibrary.Open Connection  host=${MASTER['MASTER_TECH_IP_ADDRESS']}  timeout=10s  prompt=>
    SSHLibrary.Login  ${BTS_login}  ${BTS_pwd}  loglevel=TRACE
    Sleep  3
    SSHLibrary.Write  lxc-ls  loglevel=TRACE
    Sleep  1
    ${output}=  SSHLibrary.Read Until Prompt  loglevel=TRACE
    ${FHNET_address_found}=  Run Keyword And Return Status  Should Contain  ${output}  ${FHNET_address}
    Run Keyword If  ${FHNET_address_found}  Run Keywords
    ...  SSHLibrary.Write  lxc-attach -n ${FHNET_address}  loglevel=TRACE
    ...  AND  Sleep  1
    ...  AND  SSHLibrary.Read Until Prompt  loglevel=TRACE
    SSHLibrary.Set Client Configuration  prompt=REGEXP:[:>]
    SSHLibrary.Write  telnet ${RMOD_param.ipAddress}  loglevel=TRACE
    Sleep  1
    SSHLibrary.Read Until Prompt  loglevel=TRACE
    Sleep  1s
    SSHLibrary.Write  lucent
    Sleep  1
    SSHLibrary.Read Until Prompt  loglevel=TRACE
    Sleep  1s
    SSHLibrary.Write  password
    Sleep  1
    SSHLibrary.Read Until Prompt  loglevel=TRACE
    Sleep  1s
    SSHLibrary.Write  bci
    Sleep  1
    SSHLibrary.Read Until Prompt  loglevel=TRACE
    Sleep  1s
    SSHLibrary.Write  lucent  loglevel=TRACE
    Sleep  1
    SSHLibrary.Read Until Prompt  loglevel=TRACE
    Sleep  1s
    SSHLibrary.Write  password  loglevel=TRACE
    Sleep  1
    SSHLibrary.Read Until Prompt  loglevel=TRACE
    Sleep  1s
    SSHLibrary.Set Client Configuration  prompt=>
    SSHLibrary.Write  /pltf/bsp/RReg 1 0x00000001  loglevel=TRACE
    ${output}=  SSHLibrary.Read Until Prompt  loglevel=TRACE
    Sleep  1s
    SSHLibrary.Write  exit  loglevel=TRACE
    Sleep  1
    SSHLibrary.Read Until Prompt  loglevel=TRACE
    Sleep  1
    SSHLibrary.Write  exit  loglevel=TRACE
    Sleep  1
    SSHLibrary.Read Until Prompt  loglevel=TRACE
    ${line_list}=  Split String  ${output}  separator=\r\n
    ${value}=  Fetch From Right  ${line_list[1]}  :
    ${Master_Primary_Link}=  Set Variable If  '${value.strip()}' == '31c3'  ${True}  '${value.strip()}' == '30c3'  ${False}
    ${Slave_Primary_Link}=  Set Variable If  '${value.strip()}' == '30c3'  ${True}  '${value.strip()}' == '31c3'  ${False}
    SSHLibrary.Read  delay=1  loglevel=TRACE
    Append To List  ${Master_RMOD_Primary_Link_info}  ${Master_Primary_Link}
    Append To List  ${Slave_RMOD_Primary_Link_info}  ${Slave_Primary_Link}
    [Return]  ${Master_RMOD_Primary_Link_info}  ${Slave_RMOD_Primary_Link_info}
    [Teardown]  SSHLibrary.Close Connection

Get SFP SCF distinguished name
    [Documentation]
    ...  KW used to get SFP SCF distinguished name

    [Arguments]  ${SFP_R_id}  ${alias}
    ${BTS_info}=  Get Bts Info  connection=${alias}
    ${BTS_info_list}=  Combine Lists  ${BTS_info['basebandModules']}  ${BTS_info['systemModules']}
    FOR  ${item}  IN  @{BTS_info_list}
        ${SFP_distName}  ${SFP_check}=  Parse SFP info  ${item['ports']}  ${SFP_R_id}
        Exit For Loop If  ${SFP_check}
    END
    Run Keyword If  not ${SFP_check}  Fail  SFP with R id ${SFP_R_id} not found on BTS ${alias}!
    [Return]  ${SFP_distName}

Parse SFP info
    [Arguments]  ${SFP_info}  ${SFP_R_id}
    ${SFP_distName}=  Set Variable  None
    ${SFP_check}=  Set Variable  False
    FOR  ${item}  IN  @{SFP_info}
        Continue For Loop If  '${item['id']['internal']}' != '${SFP_R_id}'
        ${SFP_distName_exists}=  Run Keyword And Return Status  Variable Should Exist  ${item['id']['configuration']}
        ${SFP_distName}=  Set Variable If  ${SFP_distName_exists}  ${item['id']['configuration']}  None
        ${SFP_check}=  Set Variable  True
        Exit For Loop
    END
    [Return]  ${SFP_distName}  ${SFP_check}

Get feature CB006831 info
    [Documentation]
    ...  Get feature CB006831 info
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description                                                            |
    ...  | alias     | Yes  | admin instance alias                                                   |
    ...  | BTS_scf   | No  | BTS scf of. Default value: None - scf will be collected in this Keyword |
    ...
    ...  *RETURN VALUE*
    ...  | actPowerMeter             | true, false or None |
    ...  | mtBtsEnergyMonitoring     | disable, <time value> in min or None |
    ...  | mtSBTSRfmEnergyMonitoring | disable, <time value> in min or None |
    ...  | mtSBTSSmEnergyMonitoring  | disable, <time value> in min or None |

    [Arguments]  ${alias}  ${BTS_scf}=None
    ${BTS_scf}=  Run Keyword If  "${BTS_scf}"=="None"  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ...  ELSE  Set Variable  ${BTS_scf}
    ${actPowerMeter}=  Get BTS SCF parameter info  ${BTS_scf}  FEATCADM  actPowerMeter
    ${mtBtsEnergyMonitoring}=  Get BTS SCF parameter info  ${BTS_scf}  PMMNL  mtBtsEnergyMonitoring
    ${mtSBTSRfmEnergyMonitoring}=  Get BTS SCF parameter info  ${BTS_scf}  PMMNL  mtSBTSRfmEnergyMonitoring
    ${mtSBTSSmEnergyMonitoring}=  Get BTS SCF parameter info  ${BTS_scf}  PMMNL  mtSBTSSmEnergyMonitoring

    [Return]  ${actPowerMeter}  ${mtBtsEnergyMonitoring}  ${mtSBTSRfmEnergyMonitoring}  ${mtSBTSSmEnergyMonitoring}

Get BTS SCF parameter info
    [Arguments]  ${BTS_scf}  ${BTS_scf_class}  ${BTS_scf_param_name}
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${param_exists}=  Run Keyword And Return Status  Element Should Exist
    ...  ${BTS_scf_xml}  .//managedObject[@class="com.nokia.srbts.mnl:${BTS_scf_class}"]/p[@name="${BTS_scf_param_name}"]
    Return From Keyword If  not ${param_exists}  ${None}
    ${BTS_scf_param_value}=  Get Element Text
    ...  ${BTS_scf_xml}  .//managedObject[@class="com.nokia.srbts.mnl:${BTS_scf_class}"]/p[@name="${BTS_scf_param_name}"]

    [Return]  ${BTS_scf_param_value}

Export SBTS Energy Consumption Counters M40002Cx
    [Arguments]  ${counter_path_file}  ${counter_ids}  ${alias}
    ${BTS_param}=  Get Parameters For All  class_name=BTS  connection=${alias}
    ${btsId}=  Set Variable  ${BTS_param[0].btsId}
    ${Pm_Counters_info}=  coam.Get Pm Counters  counter_ids=${counter_ids}  timeout=60  connection=${alias}
    ${Counters_dict}=  Set Variable  ${Pm_Counters_info['BTS']['BTS']}
    ${MRBTS_list}=  Get Dictionary Keys  ${Counters_dict}
    FOR  ${item}  IN  @{MRBTS_list}
        ${item_info}=  Get From Dictionary  ${Counters_dict}  ${item}
        ${counter_dict}=  Set Variable  ${item_info['SBTS_Energy_Consumption']}
        Log  SBTS Energy Consumption counters for ${item}:  console=True
        Append To File  ${counter_path_file}  \n ================================================= \n
        Append To File  ${counter_path_file}  SBTS Energy Consumption counters for ${item}: \n
        Append To File  ${counter_path_file}  ================================================= \n
        Log Counter Info  ${counter_path_file}  ${counter_dict}
    END

Export SBTS RFM Energy Monitoring Counters M40003Cx
    [Arguments]  ${counter_path_file}  ${counter_ids}  ${alias}
    ${BTS_param}=  Get Parameters For All  class_name=BTS  connection=${alias}
    ${btsId}=  Set Variable  ${BTS_param[0].btsId}
    ${Pm_Counters_info}=  coam.Get Pm Counters  counter_ids=${counter_ids}  timeout=60  connection=${alias}
    ${Counters_dict}=  Set Variable  ${Pm_Counters_info['BTS']['BTS']['MRBTS-${btsId}']}
    ${RMOD_list}=  Get Dictionary Keys  ${Counters_dict}
    FOR  ${item}  IN  @{RMOD_list}
        ${item_info}=  Get From Dictionary  ${Counters_dict}  ${item}
        ${counter_dict}=  Set Variable  ${item_info['SBTS_RFM_Energy_Monitoring']}
        Log  SBTS RFM Energy Monitoring counters for ${item}:  console=True
        Append To File  ${counter_path_file}  \n =============================================== \n
        Append To File  ${counter_path_file}  SBTS RFM Energy Monitoring counters for ${item}: \n
        Append To File  ${counter_path_file}  =============================================== \n
        Log Counter Info  ${counter_path_file}  ${counter_dict}
    END

Export SBTS SM Energy Monitoring Counters M40004Cx
    [Arguments]  ${counter_path_file}  ${counter_ids}  ${alias}
    ${Pm_Counters_info}=  coam.Get Pm Counters  counter_ids=${counter_ids}  timeout=60  connection=${alias}
    ${Counters_dict}=  Set Variable  ${Pm_Counters_info['BTS']['SMOD']['SMOD-1']}
    ${CABINET_list}=  Get Dictionary Keys  ${Counters_dict}
    FOR  ${item}  IN  @{CABINET_list}
        ${item_info}=  Get From Dictionary  ${Counters_dict}  ${item}
        ${counter_dict}=  Set Variable  ${item_info['SBTS_SM_Energy_Monitoring']}
        Log  SBTS SM Energy Monitoring counters for ${item}:  console=True
        Append To File  ${counter_path_file}  \n ================================================= \n
        Append To File  ${counter_path_file}  SBTS SM Energy Monitoring counters for ${item}: \n
        Append To File  ${counter_path_file}  ================================================= \n
        Log Counter Info  ${counter_path_file}  ${counter_dict}
    END

Log Counter Info
    [Arguments]  ${counter_path_file}  ${counter_dict}
    ${counter_name_list}  Get Dictionary Keys  ${counter_dict}
    FOR  ${item}  IN  @{counter_name_list}
        ${item_info}=  Get From Dictionary  ${counter_dict}  ${item}
        ${timestamp_info}=  Get Dictionary Keys  ${item_info}
        Reverse List  ${timestamp_info}
        Log  Counter name: ${item}  console=True
        Append To File  ${counter_path_file}  \n Counter name: ${item} \n
        Get Counter Info  ${counter_path_file}  ${timestamp_info}  ${item_info}
    END

Get Counter Info
    [Arguments]  ${counter_path_file}  ${timestamp_info}  ${counter_dict}
    FOR  ${index}  ${item}  IN ENUMERATE  @{timestamp_info}
        ${item_info}=  Get From Dictionary  ${counter_dict}  ${item}
        ${item_number}=  Convert To Number  ${item}
        ${timeStamp}=  Convert Date  ${item_number}  exclude_millis=True
        Run Keyword If  ${index} == 0  Run Keywords
        ...  Log  Newest Pm counter info -> Timestamp: ${timeStamp} - Value: ${item_info}  console=True
        ...  AND  Append To List  ${newest_timeStamp}  ${timeStamp}
        Append To File  ${counter_path_file}  \n Timestamp info: ${timeStamp} - Value: ${item_info} \n
    END

Calculate RMs Operational State SOAM From ${RM_states_list}
    ${RM_Operational}=  Set Variable  ${TRUE}
    FOR  ${rm_items}  IN  @{RM_states_list}
        Log  RmId: ${rm_items[0]}, RM_operationalState: ${rm_items[3]}  level=DEBUG  console=${TRUE}
        ${RM_Operational}=  Set Variable If  '${rm_items[3]}' != 'Enabled'  ${FALSE}  ${RM_Operational}
        Run Keyword If  not ${RM_Operational}  Log  RM is in ${rm_items[3]} state  level=WARN
    END
    [Return]  ${RM_Operational}

Get PL shared RMOD status based on BTS info
    [Arguments]  ${BTS_shared_RMOD_list}  ${alias}
    ${BTS_PL_shared_RMOD_dict}=  Create Dictionary

    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
    ${BTS_radioMaster_RM_list}=  Get RMOD radioMaster info  ${alias}

    ${BTS_CABLINK_id_firstEndPointId_dict}  ${BTS_CABLINK_id_secondEndPointId_dict}  ${BTS_CABLINK_id_configuration_dict}
    ...  ${BTS_CABLINK_id_data_dict}  ${BTS_CABLINK_id_dc_dict}  ${BTS_CABLINK_id_synchronization_dict}  ${BTS_CABLINK_id_operationalState_dict}=
    ...  Admin Get CABLINK info dict  ${alias}

    FOR  ${RMOD_id}  IN ZIP  ${BTS_shared_RMOD_list}

        ${RMOD_L3Protocol}=  Get From Dictionary  ${RMOD_L3Protocol_dict}  ${RMOD_id}
        ${BTS_shared_RMOD_synchronization_list}=  Run Keyword If  '${RMOD_L3Protocol}' in ['CPRI_RP1','ECPRI_MPLANE']
        ...  Get PL shared RMOD status from CABLINK info  ${RMOD_id}  ${BTS_CABLINK_id_firstEndPointId_dict}
        ...  ${BTS_CABLINK_id_secondEndPointId_dict}  ${BTS_CABLINK_id_synchronization_dict}  ${BTS_CABLINK_id_operationalState_dict}  ${alias}
        ...  ELSE IF  '${RMOD_L3Protocol}' == 'RP301_RP1'
        ...  Get PL shared RMOD status from Primary Controller info  ${RMOD_id}  ${BTS_radioMaster_RM_list}
        Run Keyword If  ${BTS_shared_RMOD_synchronization_list}
        ...  Set To Dictionary  ${BTS_PL_shared_RMOD_dict}  ${RMOD_id}  ${BTS_shared_RMOD_synchronization_list}

    END

    [Return]  ${BTS_PL_shared_RMOD_dict}

Get PL shared RMOD status from CABLINK info
    [Arguments]  ${RMOD_id}  ${BTS_CABLINK_id_firstEndPointId_dict}  ${BTS_CABLINK_id_secondEndPointId_dict}  ${BTS_CABLINK_id_synchronization_dict}
    ...  ${BTS_CABLINK_id_operationalState_dict}  ${alias}

    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    ${synchronization_list}=  Create List

    FOR  ${item}  IN  @{CABLINK_list}

        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${CABLINK_secondEndPointId}=  Get From Dictionary  ${BTS_CABLINK_id_secondEndPointId_dict}  ${CABLINK_id}
        ${RMOD_id_regex}=  Regexp Escape  ${RMOD_id}
        ${secondEndPointId_RMOD_R}=  Run Keyword And Return Status  Should Match Regexp  ${CABLINK_secondEndPointId}
        ...  ${RMOD_id_regex}$|${RMOD_id_regex}\/

        Continue For Loop If  '${secondEndPointId_RMOD_R}' == 'False'
        ${CABLINK_firstEndPointId}=  Get From Dictionary  ${BTS_CABLINK_id_firstEndPointId_dict}  ${CABLINK_id}
        ${CABLINK_synchronization}=  Get From Dictionary  ${BTS_CABLINK_id_synchronization_dict}  ${CABLINK_id}
        ${CABLINK_operationalState}=  Get From Dictionary  ${BTS_CABLINK_id_operationalState_dict}  ${CABLINK_id}
        ${firstEndpoint_FHS_R}=  Run Keyword And Return Status  Should Contain  ${CABLINK_firstEndPointId}  FHS_R
        ${firstEndpoint_BBMOD_R}=  Run Keyword And Return Status  Should Contain  ${CABLINK_firstEndPointId}  BBMOD_R
        ${firstEndpoint_SMOD_R}=  Run Keyword And Return Status  Should Contain  ${CABLINK_firstEndPointId}  SMOD_R
        ${condition}=  Create Long String  '${CABLINK_operationalState}' in '${Enabled_}' and (${firstEndpoint_FHS_R} or ${firstEndpoint_BBMOD_R}
        ...  or ${firstEndpoint_SMOD_R})
        Run Keyword If  ${condition}
        ...  Append To List  ${synchronization_list}  ${CABLINK_synchronization}

    END

    [Return]  ${synchronization_list}

Get PL shared RMOD status from Primary Controller info
    [Arguments]  ${RMOD_id}  ${BTS_radioMaster_RM_list}

    ${synchronization_list}=  Create List
    Run Keyword If  '${RMOD_id}' in ${BTS_radioMaster_RM_list}
    ...  Append To List  ${synchronization_list}  ${TRUE}
    ...  ELSE
    ...  Append To List  ${synchronization_list}  ${FALSE}
    [Return]  ${synchronization_list}

Get PL shared FHS status from CABLINK info
    [Arguments]  ${FHS_id}  ${BTS_CABLINK_id_firstEndPointId_dict}  ${BTS_CABLINK_id_secondEndPointId_dict}  ${BTS_CABLINK_id_synchronization_dict}
    ...  ${BTS_CABLINK_id_operationalState_dict}  ${alias}

    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    ${synchronization_list}=  Create List

    FOR  ${item}  IN  @{CABLINK_list}

        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${CABLINK_secondEndPointId}=  Get From Dictionary  ${BTS_CABLINK_id_secondEndPointId_dict}  ${CABLINK_id}
        ${FHS_id_regex}=  Regexp Escape  ${FHS_id}
        ${secondEndPointId_FHS_R}=  Run Keyword And Return Status  Should Match Regexp  ${CABLINK_secondEndPointId}
        ...  ${FHS_id_regex}$|${FHS_id_regex}\/

        Continue For Loop If  '${secondEndPointId_FHS_R}' == 'False'
        ${CABLINK_firstEndPointId}=  Get From Dictionary  ${BTS_CABLINK_id_firstEndPointId_dict}  ${CABLINK_id}
        ${CABLINK_synchronization}=  Get From Dictionary  ${BTS_CABLINK_id_synchronization_dict}  ${CABLINK_id}
        ${CABLINK_operationalState}=  Get From Dictionary  ${BTS_CABLINK_id_operationalState_dict}  ${CABLINK_id}
        ${firstEndpoint_BBMOD_R}=  Run Keyword And Return Status  Should Contain  ${CABLINK_firstEndPointId}  BBMOD_R
        ${firstEndpoint_SMOD_R}=  Run Keyword And Return Status  Should Contain  ${CABLINK_firstEndPointId}  SMOD_R
        ${condition}=  Create Long String  '${CABLINK_operationalState}' in '${Enabled_}' and (${firstEndpoint_BBMOD_R} or ${firstEndpoint_SMOD_R})
        Run Keyword If  ${condition}
        ...  Append To List  ${synchronization_list}  ${CABLINK_synchronization}

    END

    [Return]  ${synchronization_list}

Collect and check RAT RTWP info
    [Documentation]
    ...  Collect and check RTWP info for specific RAT. Applicable only on BTS COAM architecture for following RAT: NR, LTE and WCDMA
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter      | Mandatory | Description                                      |
    ...  | RTWP_min       | Yes       | Min value for RTWP                               |
    ...  | RTWP_max       | Yes       | Max value for RTWP                               |
    ...  | alias          | Yes       | admin instance alias                             |
    ...  | RTWP_path_file | No        | Full path file to save ANTL monitoring json data |
    ...
    ...  *RETURN VALUE*
    ...  | RAT_RTWP_status_dict | True or False or None |
    ...
    [Arguments]  ${RTWP_min}  ${RTWP_max}  ${alias}  ${RTWP_path_file}=${EMPTY}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${RTWP_path_file}=  Run Keyword If  '${RTWP_path_file}' == '${EMPTY}'
    ...  Set Variable  ${Test Results Dir}/BTSFiles/${alias}/RTWP_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.json
    ...  ELSE
    ...  Set Variable  ${RTWP_path_file}

    ${RAT_RTWP_status_dict}=  Create Dictionary
    Set Test Variable  ${RAT_RTWP_status_dict}

    ${NR_CELL_ANT_RTWP_status_dict}=  Create Dictionary
    ${LTE_CELL_ANT_RTWP_status_dict}=  Create Dictionary
    ${WCDMA_CELL_ANT_RTWP_status_dict}=  Create Dictionary
    Set Test Variable  ${NR_CELL_ANT_RTWP_status_dict}
    Set Test Variable  ${LTE_CELL_ANT_RTWP_status_dict}
    Set Test Variable  ${WCDMA_CELL_ANT_RTWP_status_dict}

    ${RMOD_antenna_monitoring_list}=  Select RMOD Antenna Monitoring list  ${alias}

    ${RTWP_json}=  Perform Antenna Online Monitoring procedure  ${RMOD_antenna_monitoring_list}  ${RTWP_path_file}  30  ${alias}

    ${RAT_RTWP_status_dict}=  Check RAT RTWP info  ${${alias}_RAT_list}  ${RTWP_json}  ${RTWP_min}  ${RTWP_max}  ${alias}

    [Return]  ${RAT_RTWP_status_dict}

Select RMOD Antenna Monitoring list
    [Arguments]  ${alias}
    ${RMOD_ANT_TX_dict}  ${RMOD_ANT_RX_dict}  ${RMOD_PHYANT_dict}=  Get RMOD Antenna info dict  ${alias}
    ${RMOD_ANT_RX_keys}=  Get Dictionary Keys  ${RMOD_ANT_RX_dict}
    ${RMOD_PHYANT_keys}=  Get Dictionary Keys  ${RMOD_PHYANT_dict}
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
    ${RMOD_antenna_monitoring_list}=  Create List
    FOR  ${item}  IN  @{RMOD_ANT_RX_keys}
        ${ANT_RX_list}=  Get From Dictionary  ${RMOD_ANT_RX_dict}  ${item}
        Append To List  ${RMOD_antenna_monitoring_list}  @{ANT_RX_list}
    END
    FOR  ${item}  IN  @{RMOD_PHYANT_keys}
        ${PHYANT_list}=  Get From Dictionary  ${RMOD_PHYANT_dict}  ${item}
        Append To List  ${RMOD_antenna_monitoring_list}  @{PHYANT_list}
    END
    ${RMOD_antenna_monitoring_list}=  Remove Duplicates  ${RMOD_antenna_monitoring_list}
    Sort List  ${RMOD_antenna_monitoring_list}
    [Return]  ${RMOD_antenna_monitoring_list}

Get RMOD Antenna info dict
    [Documentation]
    ...  Get radio module antenna info dict.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Mandatory | Description          |
    ...  | alias     | Yes       | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | RMOD_ANT_TX_dict | dictionary containing RMOD id (key) and list of ANT_TX (value) |
    ...  | RMOD_ANT_RX_dict | dictionary containing RMOD id (key) and list of ANT_RX (value) |
    ...  | RMOD_PHYANT_dict | dictionary containing RMOD id (key) and list of PHYANT (value) |
    ...
    [Arguments]  ${alias}
    ${bts_info}=  Get Bts Info  connection=${alias}
    ${RMOD_ANT_TX_dict}=  Create Dictionary
    ${RMOD_ANT_RX_dict}=  Create Dictionary
    ${RMOD_PHYANT_dict}=  Create Dictionary
    FOR  ${item}  IN  @{bts_info['radioModules']['rmod']}
        ${RMOD_ANT_TX_list}  ${RMOD_ANT_RX_list}  ${RMOD_PHYANT_list}=  Get RMOD Antenna info list  ${item['antenaUsageInfo']}  ${item['ports']}
        Set To Dictionary  ${RMOD_ANT_TX_dict}  ${item['id']['internal']}  ${RMOD_ANT_TX_list}
        Set To Dictionary  ${RMOD_ANT_RX_dict}  ${item['id']['internal']}  ${RMOD_ANT_RX_list}
        Set To Dictionary  ${RMOD_PHYANT_dict}  ${item['id']['internal']}  ${RMOD_PHYANT_list}
    END
    [Return]  ${RMOD_ANT_TX_dict}  ${RMOD_ANT_RX_dict}  ${RMOD_PHYANT_dict}

Get RMOD Antenna info list
    [Arguments]  ${antenaUsageInfo}  ${ports}
    ${RMOD_ANT_TX_list}=  Create List
    ${RMOD_ANT_RX_list}=  Create List
    ${RMOD_PHYANT_list}=  Create List
    FOR  ${item}  IN  @{antenaUsageInfo}
        Run Keyword If  ('TX' or 'TX/RX') in '${item['direction']}'
        ...  Append To List  ${RMOD_ANT_TX_list}  ${item['id']['internal']}
        Run Keyword If  ('RX' or 'TX/RX') in '${item['direction']}'
        ...  Append To List  ${RMOD_ANT_RX_list}  ${item['id']['internal']}
    END
    FOR  ${item}  IN  @{ports}
        Run Keyword If  'PHYANT' in '${item['label']}'
        ...  Append To List  ${RMOD_PHYANT_list}  ${item['id']['internal']}
    END
    ${RMOD_ANT_TX_list}=  Remove Duplicates  ${RMOD_ANT_TX_list}
    ${RMOD_ANT_RX_list}=  Remove Duplicates  ${RMOD_ANT_RX_list}
    ${RMOD_PHYANT_list}=  Remove Duplicates  ${RMOD_PHYANT_list}
    Sort List  ${RMOD_ANT_TX_list}
    Sort List  ${RMOD_ANT_RX_list}
    Sort List  ${RMOD_PHYANT_list}

    [Return]  ${RMOD_ANT_TX_list}  ${RMOD_ANT_RX_list}  ${RMOD_PHYANT_list}

Perform Antenna Online Monitoring procedure
    [Documentation]
    ...  KW starting and stopping antenna online monitoring procedure.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Mandatory | Description                            |
    ...  | antenna_list        | Yes       | List of antenna RX under monitoring    |
    ...  | RTWP_path_file      | Yes       | Path to save ANTL monitoring json data |
    ...  | RTWP_measuring_time | Yes       | Monitoring time period (secs)          |
    ...  | alias               | Yes       | admin instance alias                   |
    ...
    ...  *RETURN VALUE*
    ...  | RTWP_json | RTWP json file for specific RAT |
    ...
    [Arguments]  ${antenna_list}  ${RTWP_path_file}  ${RTWP_measuring_time}  ${alias}
    Log  Selected antenna lines to monitor:  console=True
    FOR  ${item}  IN  @{antenna_list}
        Log  - ${item}  console=True
    END
    Log  Start Antenna Line Online Monitoring procedure  console=True
    ${start_status}=  Start ANTL online monitoring  ${antenna_list}  connection=${alias}
    Run Keyword If  '${start_status}' == 'Succeeded'
    ...  Log  Antenna Line Online Monitoring procedure successfully started.  console=True
    ...  ELSE  Run Keywords
    ...  Log  Antenna Line Online Monitoring procedure failed. RTWP info check will be skipped!  level=WARN
    ...  AND  Return From Keyword
    Log  Waiting for ${RTWP_measuring_time} seconds  console=True
    Sleep  ${RTWP_measuring_time}s
    Log  Stop Antenna Line Online Monitoring procedure  console=True
    ${stop_status}=  Stop ANTL online monitoring  ${RTWP_path_file}  connection=${alias}
    Run Keyword If  '${stop_status}' == 'Succeeded'
    ...  Log  Antenna Line Online Monitoring procedure successfully stopped.  console=True
    ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${RTWP_path_file}
    Run Keyword If  ${status}
    ...  Log  RTWP info available on ${RTWP_path_file}  level=INFO  console=True
    ...  ELSE  Run Keywords
    ...  Log  RTWP info not available on ${RTWP_path_file}  level=ERROR  console=True
    ...  AND  Fail  RTWP info not available on ${RTWP_path_file}

    ${RTWP_file}=  OperatingSystem.Get file  ${RTWP_path_file}
    ${RTWP_json}=  Evaluate  json.loads('''${RTWP_file}''')  json

    [Return]  ${RTWP_json}

Check RAT RTWP info
    [Documentation]
    ...  KW parsing json file for RTWP info, then checking RTWP info in range defined by ${RTWP_min} and ${RTWP_max} for specific ${RAT}.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Mandatory | Description                     |
    ...  | RAT_list  | Yes       | RAT configured list             |
    ...  | RTWP_json | Yes       | RTWP json file for specific RAT |
    ...  | RTWP_min  | Yes       | Min value for RTWP              |
    ...  | RTWP_max  | Yes       | Max value for RTWP              |
    ...  | alias     | Yes       | admin instance alias            |
    ...
    ...  *RETURN VALUE*
    ...  | RAT_RTWP_status_dict | True or False |
    ...
    [Arguments]  ${RAT_list}  ${RTWP_json}  ${RTWP_min}  ${RTWP_max}  ${alias}
    Log  Valid RTWP values for status check:  console=True
    Log  - in range [${RTWP_min} ${RTWP_max}] -> status True  console=True
    Log  - out of range [${RTWP_min} ${RTWP_max}] -> status False  console=True

    ${RTWP_json_keys}=  Get Dictionary Keys  ${RTWP_json}

    Run Keyword If  'NR' in ${RAT_list}  Set Test Variable  ${NR_RTWP_status}  True
    Run Keyword If  'LTE' in ${RAT_list}  Run Keyword If  ${${alias}_ALL_LNCEL_mMIMO_check}  Set Test Variable  ${LTE_RTWP_status}  None
    Run Keyword If  'LTE' in ${RAT_list}  Run Keyword If  not ${${alias}_ALL_LNCEL_mMIMO_check}  Set Test Variable  ${LTE_RTWP_status}  True
    Run Keyword If  'WCDMA' in ${RAT_list}  Set Test Variable  ${WCDMA_RTWP_status}  True

    Run Keyword If  'NR' in ${RAT_list} and 'RTWP' not in ${RTWP_json_keys}  Run Keywords
    ...  Set To Dictionary  ${RAT_RTWP_status_dict}  NR  None
    ...  AND  Return From Keyword  ${RAT_RTWP_status_dict}
    Run Keyword If  'RTWP' in ${RTWP_json_keys}  Analyze RTWP info  RTWP  ${RAT_list}  ${RTWP_json}  ${RTWP_min}  ${RTWP_max}  ${alias}
    Run Keyword If  'RTWP_L' in ${RTWP_json_keys}  Analyze RTWP info  RTWP_L  ${RAT_list}  ${RTWP_json}  ${RTWP_min}  ${RTWP_max}  ${alias}
    Run Keyword If  'RTWP_W' in ${RTWP_json_keys}  Analyze RTWP info  RTWP_W  ${RAT_list}  ${RTWP_json}  ${RTWP_min}  ${RTWP_max}  ${alias}

    [Return]  ${RAT_RTWP_status_dict}

Analyze RTWP info
    [Arguments]  ${RTWP_label}  ${RAT_list}  ${RTWP_json}  ${RTWP_min}  ${RTWP_max}  ${alias}
    ${antenna_measurements_list}=  Create List
    ${antenna_fullPath_list}=  Create List
    FOR  ${item}  IN  @{RTWP_json['${RTWP_label}']}
        ${measurements_list}  ${fullPath_list}=  Get Antenna Line info  ${item['antennaLines']}
        Append to list  ${antenna_measurements_list}  ${measurements_list}
        Append to list  ${antenna_fullPath_list}  ${fullPath_list}
    END
    ${LTE_RAT_list}=  Create List  LTE
    ${WCDMA_RAT_list}=  Create List  WCDMA
    ${RAT_list}=  Set Variable If  '${RTWP_label}' == 'RTWP'  ${RAT_list}  '${RTWP_label}' == 'RTWP_L'  ${LTE_RAT_list}
    ...  '${RTWP_label}' == 'RTWP_W'  ${WCDMA_RAT_list}
    ${RAT_RTWP_status_dict}=  Check RTWP measurements  ${RAT_list}  ${antenna_measurements_list}  ${antenna_fullPath_list}  ${RTWP_min}  ${RTWP_max}
    ...  ${alias}
    [Return]  ${RAT_RTWP_status_dict}

Get Antenna Line info
    [Arguments]  ${antennaLines_info}
    ${measurements_list}=  Create List
    ${fullPath_list}=  Create List
    FOR  ${item}  IN  @{antennaLines_info}
        Append to list  ${measurements_list}  ${item['measureDatas']}
        Append to list  ${fullPath_list}  ${item['fullPath']}
    END
    [Return]  ${measurements_list}  ${fullPath_list}

Check RTWP measurements
    [Arguments]  ${RAT_list}  ${antenna_measurements_list}  ${antenna_fullPath_list}  ${RTWP_min}  ${RTWP_max}  ${alias}
    FOR  ${item1}  ${item2}  IN ZIP  ${antenna_measurements_list}  ${antenna_fullPath_list}
        Check RTWP measurements for all Cells and Antennas  ${item1}  ${item2}  ${RTWP_min}  ${RTWP_max}  ${alias}
    END
    Run Keyword If  'NR' in ${RAT_list}
    ...  Set To Dictionary  ${RAT_RTWP_status_dict}  NR  ${NR_RTWP_status}
    Run Keyword If  'LTE' in ${RAT_list}
    ...  Set To Dictionary  ${RAT_RTWP_status_dict}  LTE  ${LTE_RTWP_status}
    Run Keyword If  'WCDMA' in ${RAT_list}
    ...  Set To Dictionary  ${RAT_RTWP_status_dict}  WCDMA  ${WCDMA_RTWP_status}

    [Return]  ${RAT_RTWP_status_dict}

Check RTWP measurements for all Cells and Antennas
    [Arguments]  ${cell_antenna_measurements_list}  ${cell_antenna_fullPath_list}  ${RTWP_min}  ${RTWP_max}  ${alias}
    FOR  ${item1}  ${item2}  IN ZIP  ${cell_antenna_measurements_list}  ${cell_antenna_fullPath_list}
        ${cell_name_list}=  Get Dictionary Keys  ${item1}  False
        ${cell_measurements_list}=  Get Dictionary Values  ${item1}  False
        Check RTWP measurements for all Cell Antenna  ${cell_name_list}  ${cell_measurements_list}  ${item2}  ${RTWP_min}  ${RTWP_max}  ${alias}
    END

Check RTWP measurements for all Cell Antenna
    [Arguments]  ${cell_name_list}  ${cell_measurements_list}  ${cell_antenna_name}  ${RTWP_min}  ${RTWP_max}  ${alias}
    Log  Monitoring ${cell_antenna_name} result:  console=True
    FOR  ${item1}  ${item2}  IN ZIP  ${cell_name_list}  ${cell_measurements_list}
        ${LTE_mMIMO_check}=  Run Keyword If  ${${alias}_LNCEL_id_list}  Check LTE mMIMO cell  ${item1}  ${${alias}_LTE_mMIMO_globalCellId_list}
        Run Keyword If  ${${alias}_LNCEL_id_list}  Run Keyword If  ${LTE_mMIMO_check}  Run Keywords
        ...  Log  - Cell ${item1} -> LTE mMIMO cell case: RTWP info check will be skipped!  console=True
        ...  AND  Continue For Loop
        ${LTE_IOT_check}=  Run Keyword If  ${${alias}_LNCEL_id_list}  Check LTE IOT cell  ${item1}  ${${alias}_LTE_IOT_globalCellId_list}
        Run Keyword If  ${${alias}_LNCEL_id_list}  Run Keyword If  ${LTE_IOT_check}  Run Keywords
        ...  Log  - Cell ${item1} -> LTE IOT cell case: RTWP info check will be skipped!  console=True
        ...  AND  Continue For Loop
        ${RAT_NR}=  Run Keyword And Return Status  Should Contain  ${item1}  NRCEL
        ${RAT_LTE}=  Run Keyword And Return Status  Should Contain  ${item1}  LNCEL
        ${RAT_WCDMA}=  Run Keyword And Return Status  Should Contain  ${item1}  WNCEL
        ${RAT}=  Set Variable If  ${RAT_NR}  NR  ${RAT_LTE}  LTE  ${RAT_WCDMA}  WCDMA
        ${RAT_RTWP_status}  ${RAT_CELL_ANT_RTWP_status}=  Check RTWP measurements for Cell Antenna  ${RAT}  ${item2}  ${RTWP_min}  ${RTWP_max}
        Set Test Variable   ${${RAT}_RTWP_status}  ${RAT_RTWP_status}
        Log  - Cell ${item1} RTWP status: ${RAT_CELL_ANT_RTWP_status}  console=True
        Set To Dictionary  ${${RAT}_CELL_ANT_RTWP_status_dict}  ${item1}_${cell_antenna_name}  ${RAT_CELL_ANT_RTWP_status}
    END

Check RTWP measurements for Cell Antenna
    [Arguments]  ${RAT}  ${cell_measurements_dict}  ${RTWP_min}  ${RTWP_max}
    ${RAT_CELL_ANT_RTWP_status}=  Set Variable  True
    ${cell_measurements_values}=  Get Dictionary Values  ${cell_measurements_dict}
    FOR  ${value}  IN  @{cell_measurements_values}
        Return From Keyword If  '${value}' == '-'  False  -
        ${RAT_RTWP_status}=  Set Variable If  ${RTWP_min} < ${value} < ${RTWP_max}  ${${RAT}_RTWP_status}  False
        ${RAT_CELL_ANT_RTWP_status}=  Set Variable If  ${RTWP_min} < ${value} < ${RTWP_max}  ${RAT_CELL_ANT_RTWP_status}  False
    END

    [Return]  ${RAT_RTWP_status}  ${RAT_CELL_ANT_RTWP_status}

Get LTE mMIMO globalCellId list
    [Documentation]
    ...  Get LNCEL mMIMO globalCellId list.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Mandatory | Description          |
    ...  | alias     | Yes       | admin instance alias |
    ...
    [Arguments]  ${alias}
    ${cell_id_antenna_tx_dict}  ${cell_id_antenna_rx_dict}  ${cell_globalCellId_antenna_tx_dict}  ${cell_globalCellId_antenna_rx_dict}=
    ...  Get Cell Antenna info dict  lte  ${alias}
    ${cell_globalCellId_list}=  Get Dictionary Keys  ${cell_globalCellId_antenna_rx_dict}
    ${LTE_mMIMO_globalCellId_list}=  Create List
    FOR  ${item}  IN  @{cell_globalCellId_list}
        ${antenna_rx_list}=  Get From Dictionary  ${cell_globalCellId_antenna_rx_dict}  ${item}
        ${Antenna_mMIMO_config}=  Check Antenna mMIMO config  ${antenna_rx_list}
        Run Keyword If  ${Antenna_mMIMO_config}  Append To List  ${LTE_mMIMO_globalCellId_list}  ${item}
    END
    Set Test Variable  ${${alias}_LTE_mMIMO_globalCellId_list}  ${LTE_mMIMO_globalCellId_list}

Get Cell Antenna info dict
    [Documentation]
    ...  Get cell antenna info dict.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Mandatory | Description              |
    ...  | cell_type | Yes       | RAT cell: nr, lte, wcdma |
    ...  | alias     | Yes       | admin instance alias     |
    ...
    ...  *RETURN VALUE*
    ...  | cell_id_antenna_tx_dict           | dictionary containing cell id (key) and list of TX antenna (value)           |
    ...  | cell_id_antenna_rx_dict           | dictionary containing cell id (key) and list of RX antenna (value)           |
    ...  | cell_globalCellId_antenna_tx_dict | dictionary containing cell globalCellId (key) and list of TX antenna (value) |
    ...  | cell_globalCellId_antenna_rx_dict | dictionary containing cell globalCellId (key) and list of RX antenna (value) |
    ...
    [Arguments]  ${cell_type}  ${alias}
    ${cell_info}=  Get Cells Info  cell_type=${cell_type}  connection=${alias}
    ${cell_id_antenna_tx_dict}=  Create Dictionary
    ${cell_id_antenna_rx_dict}=  Create Dictionary
    ${cell_globalCellId_antenna_tx_dict}=  Create Dictionary
    ${cell_globalCellId_antenna_rx_dict}=  Create Dictionary

    FOR  ${item}  IN  @{cell_info}
        Continue For Loop If  '${item['technology']}' not in ['FDD','TDD']
        ${cell_antenna_tx_list}  ${cell_antenna_rx_list}=  Get CELL Antenna info list  ${item['carrierList']}
        Set To Dictionary  ${cell_id_antenna_tx_dict}  ${item['id']['internal']}  ${cell_antenna_tx_list}
        Set To Dictionary  ${cell_id_antenna_rx_dict}  ${item['id']['internal']}  ${cell_antenna_rx_list}
        Set To Dictionary  ${cell_globalCellId_antenna_tx_dict}  ${item['globalCellId']}  ${cell_antenna_tx_list}
        Set To Dictionary  ${cell_globalCellId_antenna_rx_dict}  ${item['globalCellId']}  ${cell_antenna_rx_list}
    END

    [Return]  ${cell_id_antenna_tx_dict}  ${cell_id_antenna_rx_dict}  ${cell_globalCellId_antenna_tx_dict}  ${cell_globalCellId_antenna_rx_dict}

Get CELL Antenna info list
    [Arguments]  ${carrier_list}
    ${cell_antenna_tx_list}=  Create List
    ${cell_antenna_rx_list}=  Create List
    FOR  ${item}  IN  @{carrier_list}
        Run Keyword If  'TX' in '${item['direction']}'
        ...  Append To List  ${cell_antenna_tx_list}  ${item['antennaLineId']['internal']}
        Run Keyword If  'RX' in '${item['direction']}'
        ...  Append To List  ${cell_antenna_rx_list}  ${item['antennaLineId']['internal']}
    END
    ${cell_antenna_tx_list}=  Remove Duplicates  ${cell_antenna_tx_list}
    ${cell_antenna_rx_list}=  Remove Duplicates  ${cell_antenna_rx_list}
    Sort List  ${cell_antenna_tx_list}
    Sort List  ${cell_antenna_rx_list}

    [Return]  ${cell_antenna_tx_list}  ${cell_antenna_rx_list}

Check Antenna mMIMO config
    [Arguments]  ${antenna_list}
    ${Antenna_mMIMO_config}=  Set Variable  ${FALSE}
    FOR  ${item}  IN  @{antenna_list}
        ${is_mMIMO}=  Run Keyword And Return Status  Should Contain  ${item}  PHYANT
        ${Antenna_mMIMO_config}=  Set Variable If  ${is_mMIMO}  ${TRUE}  ${Antenna_mMIMO_config}
        Exit For Loop If  ${Antenna_mMIMO_config}
    END

    [Return]  ${Antenna_mMIMO_config}

Check LTE mMIMO cell
    [Arguments]  ${LNCEL_RTWP_label}  ${LTE_mMIMO_globalCellId_list}
    ${LTE_mMIMO_check}=  Set Variable  False
    FOR  ${item}  IN  @{LTE_mMIMO_globalCellId_list}
        ${item}=  Convert To String  ${item}
        ${is_mMIMO}=  Run Keyword And Return Status  Should Contain  ${LNCEL_RTWP_label}  LNCEL-${item}
        Return From Keyword If  ${is_mMIMO}  True
    END
    [Return]  ${LTE_mMIMO_check}

Get LTE HOST and IOT globalCellId list
    [Documentation]
    ...  Get LNCEL HOST and IOT globalCellId list.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Mandatory | Description          |
    ...  | alias     | Yes       | admin instance alias |
    ...
    [Arguments]  ${alias}
    ${cell_info}=  Get Cells Info  cell_type=lte  connection=${alias}
    ${LTE_HOST_globalCellId_list}=  Create List
    ${LTE_IOT_globalCellId_list}=  Create List
    FOR  ${item}  IN  @{cell_info}
        Run Keyword If  ('${item['technology']}' == 'FDD' or '${item['technology']}' == 'TDD')
        ...  Append To List  ${LTE_HOST_globalCellId_list}  ${item['globalCellId']}
        ...  ELSE IF  '${item['technology']}' == 'NB-IoT-FDD'
        ...  Append To List  ${LTE_IOT_globalCellId_list}  ${item['globalCellId']}
    END
    Set Test Variable  ${${alias}_LTE_HOST_globalCellId_list}  ${LTE_HOST_globalCellId_list}
    Set Test Variable  ${${alias}_LTE_IOT_globalCellId_list}  ${LTE_IOT_globalCellId_list}

Check LTE IOT cell
    [Arguments]  ${LNCEL_RTWP_label}  ${LTE_IOT_globalCellId_list}
    ${LTE_IOT_check}=  Set Variable  False
    FOR  ${item}  IN  @{LTE_IOT_globalCellId_list}
        ${item}=  Convert To String  ${item}
        ${is_IOT}=  Run Keyword And Return Status  Should Contain  ${LNCEL_RTWP_label}  LNCEL-${item}
        Return From Keyword If  ${is_IOT}  True
    END
    [Return]  ${LTE_IOT_check}

Get RMOD Input Voltage Threshold info
    [Documentation]
    ...  Get RMOD voltage parameters info: alVoltLowThreshold, alVoltHighThreshold, alVoltUnstableThreshold.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Mandatory | Description             |
    ...  | RMOD_id   | Yes       | RMOD distinguished name |
    ...  | alias     | Yes       | admin instance alias    |
    ...
    ...  *RETURN VALUE*
    ...  | alVoltLowThreshold      | parameter value |
    ...  | alVoltHighThreshold     | parameter value |
    ...  | alVoltUnstableThreshold | parameter value |
    ...
    [Arguments]  ${RMOD_id}  ${alias}

    ${RMOD_SCF_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${alVoltLowThreshold}=  Get BTS SCF parameter info for specific DN  ${BTS_scf}  ${RMOD_SCF_dn}  alVoltLowThreshold
    ${alVoltHighThreshold}=  Get BTS SCF parameter info for specific DN  ${BTS_scf}  ${RMOD_SCF_dn}  alVoltHighThreshold
    ${alVoltUnstableThreshold}=  Get BTS SCF parameter info for specific DN  ${BTS_scf}  ${RMOD_SCF_dn}  alVoltUnstableThreshold

    [Return]  ${alVoltLowThreshold}  ${alVoltHighThreshold}  ${alVoltUnstableThreshold}

Get RMOD Input Voltage Threshold parameter info
    [Documentation]
    ...  Get RMOD voltage parameters info: alVoltLowThreshold, alVoltHighThreshold,
    ...  alVoltLowThresholdMinor, alVoltHighThresholdMinor, alVoltUnstableThreshold.
    ...
    ...  *AUTHOR*
    ...  ariel.ciucurita@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Mandatory | Description             |
    ...  | RMOD_id   | Yes       | RMOD distinguished name |
    ...  | alias     | Yes       | admin instance alias    |
    ...
    ...  *RETURN VALUE*
    ...  | alVoltLowThreshold      | parameter value |
    ...  | alVoltHighThreshold     | parameter value |
    ...  | alVoltLowThresholdMinor      | parameter value |
    ...  | alVoltHighThresholdMinor     | parameter value |
    ...  | alVoltUnstableThreshold | parameter value |
    ...
    [Arguments]  ${RMOD_id}  ${alias}

    ${RMOD_SCF_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${alVoltLowThreshold}=  Get BTS SCF parameter info for specific DN  ${BTS_scf}  ${RMOD_SCF_dn}  alVoltLowThreshold
    ${alVoltHighThreshold}=  Get BTS SCF parameter info for specific DN  ${BTS_scf}  ${RMOD_SCF_dn}  alVoltHighThreshold
    ${alVoltLowThresholdMinor}=  Get BTS SCF parameter info for specific DN  ${BTS_scf}  ${RMOD_SCF_dn}  alVoltLowThresholdMinor
    ${alVoltHighThresholdMinor}=  Get BTS SCF parameter info for specific DN  ${BTS_scf}  ${RMOD_SCF_dn}  alVoltHighThresholdMinor
    ${alVoltUnstableThreshold}=  Get BTS SCF parameter info for specific DN  ${BTS_scf}  ${RMOD_SCF_dn}  alVoltUnstableThreshold

    [Return]  ${alVoltLowThreshold}  ${alVoltHighThreshold}
    ...  ${alVoltLowThresholdMinor}  ${alVoltHighThresholdMinor}
    ...  ${alVoltUnstableThreshold}

Get BTS SCF parameter info for specific DN

    [Arguments]  ${BTS_scf}  ${BTS_scf_distName}  ${BTS_scf_param_name}

     ${BTS_scf_param_value}=  Set Variable  ${None}
     ${BTS_scf_param_value}=  Check Parameter value from SCF  ${BTS_scf_distName}  ${BTS_scf_param_name}  ${BTS_scf}

    [Return]  ${BTS_scf_param_value}

Wait For Target To Be Reachable TAF
    [Documentation]
    ...  Waits for target IP to be reachable by ping
    ...
    ...  *INPUT*
    ...  | Parameter              | Mandatory | Description                                        |
    ...  | hostname               | Yes       | Target IP, if more items separated by comma        |
    ...  | timeout                | No        | Time in seconds to wait for target to be reachable |
    ...  | remote_host            | No        | Remote host IP if ping should be proceeded from it |
    ...  | remote_host_username   | No        | Username for remote host authentication            |
    ...  | remote_host_password   | No        | Password for remote host authentication            |
    ...
    [Arguments]  ${hostname}  ${timeout}=200  ${remote_host}=None  ${remote_host_username}=ute  ${remote_host_password}=ute
    ${ip_addresses}=  Strip String  ${hostname}
    ${ip_addresses}=  Evaluate  '${ip_addresses}'.replace(', ',',')
    ${ip_addresses}=  Split String  ${ip_addresses}  ,
    ${ping_status}  ${ping_response}=  Run Keyword And Ignore Error  ping.Wait For Ping  ip_addresses=${ip_addresses}  timeout=${timeout}
    ...  remote_host_ip=${remote_host}  remote_host_username=${remote_host_username}  remote_host_password=${remote_host_password}
    Run Keyword If  '${ping_status}' == 'FAIL'  Run Keywords
    ...  Log  ${ping_response}  level=ERROR
    ...  AND  Fail  ${ping_response}

Wait For Target To Be Not Reachable TAF
    [Documentation]
    ...  Waits for target IP to be not reachable by ping
    ...
    ...  *INPUT*
    ...  | Parameter              | Mandatory | Description                                            |
    ...  | hostname               | Yes       | Target IP, if more items separated by comma            |
    ...  | timeout                | No        | Time in seconds to wait for target to be not reachable |
    ...  | remote_host            | No        | Remote host IP if ping should be proceeded from it     |
    ...  | remote_host_username   | No        | Username for remote host authentication                |
    ...  | remote_host_password   | No        | Password for remote host authentication                |
    ...
    [Arguments]  ${hostname}  ${timeout}=200  ${remote_host}=None  ${remote_host_username}=ute  ${remote_host_password}=ute
    ${ip_addresses}=  Strip String  ${hostname}
    ${ip_addresses}=  Evaluate  '${ip_addresses}'.replace(', ',',')
    ${ip_addresses}=  Split String  ${ip_addresses}  ,
    ${no_ping_status}  ${no_ping_response}=  Run Keyword And Ignore Error  ping.Wait For No Ping  ip_addresses=${ip_addresses}  timeout=${timeout}
    ...  remote_host_ip=${remote_host}  remote_host_username=${remote_host_username}  remote_host_password=${remote_host_password}
    Run Keyword If  '${no_ping_status}' == 'FAIL'  Run Keywords
    ...  Log  ${no_ping_response}  level=ERROR
    ...  AND  Fail  ${no_ping_response}

Save BTS File
    [Documentation]
    ...  Saves a file from BTS in a specific path on VM
    ...
    ...  | Input Parameters     | Mandatory | Description                                                                                           |
    ...  | alias                | Yes       | BTS from where the file is downloaded.                                                                |
    ...  | BTS_file_names       | Yes       | Descriptive name of the desired file (ex: swconfig). Variable is a list that can have one or multiple |
    ...  |                      |           | elements. In case of multiple elements, they need to be separated by a space.                         |
    ...  |                      |           | (ex: BTS_file_names=swconfig blackbox)                                                                |
    ...  | BTS_source_paths     | Yes       | The full path from where the desired file will be downloaded from BTS (ex: /ffs/run/swconfig.txt).    |
    ...  |                      |           | Variable is a list that can have one or multiple elements. In case of multiple elements, they need to |
    ...  |                      |           | be separated by a space. (ex: BTS_source_paths=/ffs/run/swconfig.txt /rom/logs/lifetimedata/blackbox) |
    ...  | BTS_destination_path | No        | The full path where the desired file will be downloaded on VM.                                        |

    [Arguments]  ${alias}  ${BTS_file_names}  ${BTS_source_paths}  ${BTS_destination_path}=${BTSFiles}/${alias}

    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${BTS_destination_path}
    Run Keyword If  not ${status}  Create Directory  ${BTS_destination_path}
    ${file_name_list}=  Split String  ${BTS_file_names}  ${SPACE}
    ${source_path_list}=  Split String  ${BTS_source_paths}  ${SPACE}
    ${file_paths}=  Create List
    FOR  ${name}  ${path}  IN ZIP  ${file_name_list}  ${source_path_list}
        ${BTS_file_path}=  Join Path  ${BTS_destination_path}  ${name}
        Append To List  ${file_paths}  ${BTS_file_path}
        Run Keyword If  '${alias}' == 'Master'
        ...  Run Keyword And Ignore Error
        ...  Get File From System Module TAF  target_ip=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  source_path=${path}
        ...  destination_path=${BTS_file_path}
        ...  ELSE  Run Keyword And Ignore Error
        ...  Get File From System Module TAF  target_ip=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
        ...  via_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  source_path=${path}  destination_path=${BTS_file_path}
        ...  via_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]
        ...  via_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
        ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${BTS_file_path}
        ${size}=  Run Keyword If  ${status}  OperatingSystem.Get File Size  ${BTS_file_path}
        ...  ELSE  Set Variable  0
        Run Keyword If  ${status} and ${size} != 0
        ...  Log  ${alias} ${name} file succesfully saved from ${path} and it is available at ${BTS_file_path}.  level=INFO  console=True
        ...  ELSE
        ...  Log  ${alias} ${name} file couldn't be saved from ${path} or file is empty. Please check ${name} file existance!  level=INFO
    END
    [Return]  ${file_paths}

Check if BTS File Exists
    [Documentation]
    ...  Checks if a file exists in a specific path/paths on VM
    ...
    ...  | Input Parameters | Mandatory | Description                                                                                           |
    ...  | alias            | Yes       | BTS from where the file is checked                                                                    |
    ...  | file_name        | Yes       | Descriptive name of the desired file (ex: blackbox). It is used only for logging in case the file     |
    ...  |                  |           | isn't found.                                                                                          |
    ...  | file_paths       | Yes       | The full path from where the desired file will checked on VM (ex: /home/ute/btsauto/Master/blackbox). |
    ...  |                  |           | Variable is a list that can have one or multiple elements. In case of multiple elements, they need to |
    ...  |                  |           | be separated by a space.                                                                              |
    ...  |                  |           | (ex: file_paths=/home/ute/btsauto/Master/blackbox /home/ute/logs/Master/blackbox)                     |

    [Arguments]  ${alias}  ${file_name}  ${file_paths}

    FOR  ${file_path}  IN  @{file_paths}
        ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${file_path}
        ${size}=  Run Keyword If  ${status}  OperatingSystem.Get File Size  ${file_path}
        ...  ELSE  Set Variable  0
        Return From Keyword If  '${status}' == 'True' and ${size} > 0
    END

    Log  ${alias} ${file_name} file couldn't be saved or file is empty. Please check ${file_name} file existance!  level=WARN

Get PL shared RM info on all BTS
    [Documentation]
    ...  Get PL shared RM info on all BTS. KW returns PL shared RM info on all BTS as a dictionary:
    ...  - key: BTS alias
    ...  - value: info containing RM id or RM serial number for each RM L3 protocol
    ...

    ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Admin Get RM sn bts-alias info dict

    ${all_BTS_PL_shared_RM_info}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}
        ${BTS_shared_RM_sn_list}  ${BTS_shared_RM_id_list}=  Get shared RM info on specific BTS  ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}
        ...  ${alias}
        ${BTS_PL_shared_RM_dict}=  Get PL shared RMOD status based on BTS info  ${BTS_shared_RM_id_list}  ${alias}
        ${BTS_PL_shared_RM_info}=  Get PL shared RM info on specific BTS  ${BTS_PL_shared_RM_dict}  ${alias}
        Set To Dictionary  ${all_BTS_PL_shared_RM_info}  ${alias}=${BTS_PL_shared_RM_info}
    END

    [Return]  ${all_BTS_PL_shared_RM_info}

Get PL shared RM info on specific BTS
    [Documentation]
    ...  Get PL shared RM info on specific BTS. KW returns PL shared RM info on specific BTS as a dictionary:
    ...  - key: list name for each RM L3 protocol
    ...  - value: list info containing RM id or RM serial number for each RM L3 protocol
    ...
    [Arguments]  ${BTS_PL_shared_RM_dict}  ${alias}

    ${BTS_PL_CPRI_shared_RM_id_list}=  Create List
    ${BTS_non_PL_CPRI_shared_RM_id_list}=  Create List
    ${BTS_PL_ECPRI_shared_RM_id_list}=  Create List
    ${BTS_non_PL_ECPRI_shared_RM_id_list}=  Create List
    ${BTS_PL_OBSAI_shared_RM_id_list}=  Create List
    ${BTS_non_PL_OBSAI_shared_RM_id_list}=  Create List

    ${BTS_PL_CPRI_shared_RM_sn_list}=  Create List
    ${BTS_non_PL_CPRI_shared_RM_sn_list}=  Create List
    ${BTS_PL_ECPRI_shared_RM_sn_list}=  Create List
    ${BTS_non_PL_ECPRI_shared_RM_sn_list}=  Create List
    ${BTS_PL_OBSAI_shared_RM_sn_list}=  Create List
    ${BTS_non_PL_OBSAI_shared_RM_sn_list}=  Create List

    ${BTS_keys}=  Get Dictionary Keys  ${BTS_PL_shared_RM_dict}  False
    ${RM_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}

    FOR  ${BTS_key}  IN  @{BTS_keys}
        ${BTS_value}=  Get From Dictionary  ${BTS_PL_shared_RM_dict}  ${BTS_key}
        ${RM_sn}=  Get From Dictionary  ${${alias}_RM_id_sn_dict}  ${BTS_key}
        ${RM_L3Protocol}=  Get From Dictionary  ${RM_L3Protocol_dict}  ${BTS_key}
        Run Keyword If  'True' in '${BTS_value}' and '${RM_L3Protocol}' == 'CPRI_RP1'  Run Keywords
        ...  Append To List  ${BTS_PL_CPRI_shared_RM_id_list}  ${BTS_key}
        ...  AND  Append To List  ${BTS_PL_CPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  'False' in '${BTS_value}' and '${RM_L3Protocol}' == 'CPRI_RP1'  Run Keywords
        ...  Append To List  ${BTS_non_PL_CPRI_shared_RM_id_list}  ${BTS_key}
        ...  AND  Append To List  ${BTS_non_PL_CPRI_shared_RM_sn_list}  ${RM_sn}
        Run Keyword If  'True' in '${BTS_value}' and '${RM_L3Protocol}' == 'ECPRI_MPLANE'  Run Keywords
        ...  Append To List  ${BTS_PL_ECPRI_shared_RM_id_list}  ${BTS_key}
        ...  AND  Append To List  ${BTS_PL_ECPRI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  'False' in '${BTS_value}' and '${RM_L3Protocol}' == 'ECPRI_MPLANE'  Run Keywords
        ...  Append To List  ${BTS_non_PL_ECPRI_shared_RM_id_list}  ${BTS_key}
        ...  AND  Append To List  ${BTS_non_PL_ECPRI_shared_RM_sn_list}  ${RM_sn}
        Run Keyword If  'True' in '${BTS_value}' and '${RM_L3Protocol}' == 'RP301_RP1'  Run Keywords
        ...  Append To List  ${BTS_PL_OBSAI_shared_RM_id_list}  ${BTS_key}
        ...  AND  Append To List  ${BTS_PL_OBSAI_shared_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  'False' in '${BTS_value}' and '${RM_L3Protocol}' == 'RP301_RP1'  Run Keywords
        ...  Append To List  ${BTS_non_PL_OBSAI_shared_RM_id_list}  ${BTS_key}
        ...  AND  Append To List  ${BTS_non_PL_OBSAI_shared_RM_sn_list}  ${RM_sn}
    END

    ${BTS_PL_shared_RM_info}=  Create Dictionary
    ...  BTS_PL_CPRI_shared_RM_id_list=${BTS_PL_CPRI_shared_RM_id_list}
    ...  BTS_non_PL_CPRI_shared_RM_id_list=${BTS_non_PL_CPRI_shared_RM_id_list}
    ...  BTS_PL_ECPRI_shared_RM_id_list=${BTS_PL_ECPRI_shared_RM_id_list}
    ...  BTS_non_PL_ECPRI_shared_RM_id_list=${BTS_non_PL_ECPRI_shared_RM_id_list}
    ...  BTS_PL_OBSAI_shared_RM_id_list=${BTS_PL_OBSAI_shared_RM_id_list}
    ...  BTS_non_PL_OBSAI_shared_RM_id_list=${BTS_non_PL_OBSAI_shared_RM_id_list}
    ...  BTS_PL_CPRI_shared_RM_sn_list=${BTS_PL_CPRI_shared_RM_sn_list}
    ...  BTS_non_PL_CPRI_shared_RM_sn_list=${BTS_non_PL_CPRI_shared_RM_sn_list}
    ...  BTS_PL_ECPRI_shared_RM_sn_list=${BTS_PL_ECPRI_shared_RM_sn_list}
    ...  BTS_non_PL_ECPRI_shared_RM_sn_list=${BTS_non_PL_ECPRI_shared_RM_sn_list}
    ...  BTS_PL_OBSAI_shared_RM_sn_list=${BTS_PL_OBSAI_shared_RM_sn_list}
    ...  BTS_non_PL_OBSAI_shared_RM_sn_list=${BTS_non_PL_OBSAI_shared_RM_sn_list}

    [Return]  ${BTS_PL_shared_RM_info}

Get shared RM info on specific BTS
    [Arguments]  ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${alias}

    ${BTS_shared_RM_sn_list}=  Create List
    ${BTS_shared_RM_id_list}=  Create List

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        ${RM_id}=  Run Keyword If  '${alias}' in ${RM_bts-alias_list}
        ...  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        Run Keyword If  '${alias}' in ${RM_bts-alias_list}  Run Keywords
        ...  Append To List  ${BTS_shared_RM_sn_list}  ${RM_sn}
        ...  AND  Append To List  ${BTS_shared_RM_id_list}  ${RM_id}
    END

    [Return]  ${BTS_shared_RM_sn_list}  ${BTS_shared_RM_id_list}

Adding alarms to ignored list
    [Documentation]
    ...  Helper KW used for adding alarms to ignored list using a specific admin connection
    ...
    ...  *INPUT*
    ...  | Parameter              | Mandatory | Description                                            |
    ...  | IGNORED_ALARMS_LIST    | Yes       | List of ignored alarms                                 |
    ...  | connection_alias       | Yes       | Admin connection alias used                            |
    ...

    [Arguments]  ${IGNORED_ALARMS_LIST}  ${connection_alias}

    FOR  ${item}  IN  @{IGNORED_ALARMS_LIST}
        ${faultId}=  Get From Dictionary  ${item}  faultId
        coam.Add Allowed Alarm  faultId=${faultId}  connection=${connection_alias}
    END

Get BTS alias label info dict
    [Documentation]
    ...  KW providing dictionaries with info:
    ...  - ${BTS_alias_label_dict} key: BTS_alias (Master, Slave, Slave1, etc) - value: BTS_label (BTS1, BTS2, BTS3, etc)
    ...  - ${BTS_label_alias_dict} value: BTS_label (BTS1, BTS2, BTS3, etc) - key: BTS_alias (Master, Slave, Slave1, etc)
    ...
    ${BTS_alias_label_dict}=  Create Dictionary
    ${BTS_label_alias_dict}=  Create Dictionary
    FOR  ${index}  ${item}  IN ENUMERATE  @{alias_list}
        Set To Dictionary  ${BTS_alias_label_dict}  ${item}  BTS${index+1}
        Set To Dictionary  ${BTS_label_alias_dict}  BTS${index+1}  ${item}
    END

    [Return]  ${BTS_alias_label_dict}  ${BTS_label_alias_dict}

Check alarms while thread is running
    [Documentation]
    ...  Check alarms while a certain thread is running in background
    ...  For best results use this KW in combination with Wait Until Keyword Succeeds
    ...
    ...  *INPUT*
    ...  | Parameter                        | Mandatory | Description                                            |
    ...  | thread_object                    | Yes       | The object of the running thread                       |
    ...  | alias                            | Yes       | Admin connection alias used                            |
    ...  | alarms_info_response_final       | Yes       | The alarms response list to add found alarms to        |
    ...
    ...  *EXAMPLE*
    ...  | ${alarms_info_result} | ${alarms_info_response} | Wait Until Keyword Succeeds          |
    ...  | 90 min                | 10 s                    | Check alarms while thread is running |
    ...  | ${download_thread}    | ${alias_local}          | ${alarms_info_response}              |

    [Arguments]    ${thread_object}    ${alias}    ${alarms_info_response_final}
    ${alarms_info_result}  ${alarms_info_response}=  Run Keyword And Ignore Error  Assert No Unexpected Active Alarms  connection=${alias}
    Run keyword if  '${alarms_info_result}' != 'PASS'
    ...  Run Keywords
    ...  Log  Alarms found ${alarms_info_response}  console=True
    ...  AND
    ...  Append To List  ${alarms_info_response_final}  ${alarms_info_response}
    Run Keyword If  not ${thread_object._is_finished}  Fail  ${thread_object} is still running
    ${alarms_info_response_final}=  Run Keyword If  ${alarms_info_response_final}  Remove Duplicates  ${alarms_info_response_final}
    ${alarms_info_result_final}=  Set Variable If  ${alarms_info_response_final}  FAIL  PASS
    [Return]  ${alarms_info_result_final}  ${alarms_info_response_final}

Get BTS controller role shared RM SN list from SCF
    [Documentation]
    ...  Keyword providing classical BTS controller role for configured RMOD from SCF:
    ...  - with CB009828: based on sharingConfig.controllerRole info
    ...  - without CB009828: based on radioMasterDN info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                     |
    ...  | shared_RM_sn_list | Yes  |         | List of shared RM serial number |
    ...  | alias             | Yes  |         | BTS connection instance alias   |
    ...
    ...  *RETURN*
    ...  | Parameter                                  | Description                                                            |
    ...  | BTS_primary_controller_shared_RM_sn_list   | List of shared RMOD sn with BTS alias having primary controller role   |
    ...  | BTS_secondary_controller_shared_RM_sn_list | List of shared RMOD sn with BTS alias having secondary controller role |

    [Arguments]  ${shared_RM_sn_list}  ${alias}

    ${BTS_SCF_path_file}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${BTS_CB009828_feature_dict}=  Get BTS CB009828 feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file}  alias=${alias}
    ${actRfsConfigPerUnit_info}=  Get From Dictionary  ${BTS_CB009828_feature_dict}  actRfsConfigPerUnit

    ${BTS_primary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}=
    ...  Run Keyword If  '${actRfsConfigPerUnit_info}' == 'true'
    ...  Get classical BTS controller role for configured RMOD from SCF with CB009828  BTS_SCF_path_file=${BTS_SCF_path_file}
    ...  RMOD_sn_list=${shared_RM_sn_list}  alias=${alias}
    ...  ELSE
    ...  Get classical BTS controller role for configured RMOD from SCF without CB009828  BTS_SCF_path_file=${BTS_SCF_path_file}
    ...  RMOD_sn_list=${shared_RM_sn_list}  alias=${alias}

    [Return]  ${BTS_primary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}

Get BTS gNbCuType
    [Arguments]  ${alias}
    ${bts_info}=  Get Bts Info  alias=${alias}
    ${gNbCuType}=  Set Variable  ${bts_info['gNbCuType']}

    [Return]  ${gNbCuType}

Get NR Cell Deployment Type list
    [Arguments]  ${cell_list}  ${alias}
    ${SA_cell_list}=  Create List
    ${NSA_cell_list}=  Create List
    ${cells_info}=  Get Cells Info  cell_type=nr  connection=${alias}
    FOR  ${item}  IN  @{cells_info}
        Run Keyword If  '${item['id']['internal']}' not in @{cell_list}  Continue For Loop
        ${cellDepType}=  Set Variable  ${item['cellDepType']}
        Run Keyword If  '${cellDepType}' == 'SA'  Append To List  ${SA_cell_list}  ${item}
        ...  ELSE IF  '${cellDepType}' == 'NSA'  Append To List  ${NSA_cell_list}  ${item}
    END
    [Return]  ${SA_cell_list}  ${NSA_cell_list}

Get LNADJGNB list
    [Arguments]  ${alias}
    ${scf}=  coam.Get Scf  connection=${alias}  with_auto_configured_parameters=${TRUE}
    ${LNADJGNB_id_list}=  Get Regexp Matches  ${scf}  MRBTS-[0-9]*\/LNBTS-[0-9]*\/LNADJGNB-[0-9]*
    [Return]  ${LNADJGNB_id_list}

Check X2 Link Status
    [Arguments]  ${expectedState}  ${alias}
    Get Current Scf File  local_dir_path=${BTSFiles}/SCF_temp  file_name=SCF_temp.xml  connection=${alias}  with_auto_configured_parameters=${TRUE}
    scf.Load Scf  ${BTSFiles}/SCF_temp/SCF_temp.xml
    FOR  ${item}  IN  @{LNADJGNB_id_list}
        ${LNADJGNB_administrativeState}=  scf.Get Value From Scf  dist_name=${item}  p_name=administrativeState
        Run Keyword If  '${LNADJGNB_administrativeState}' != '${expectedState}'  Run Keywords
        ...  Log  LNADJGNB administrativeState not as expected!
        ...  AND  Fail  LNADJGNB administrativeState not as expected!
    END

Get BBMOD FHS info
    [Documentation]
    ...  Keyword providing dedicated and shared FHS dict for BBMOD list
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | BBMOD_list        | Yes  |         | BBMOD_id list                    |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                                  | Description                                                                       |
    ...  | BBMOD_shared_FHS_dict                      | Dict with BBMOD_id as key and shared FHS list connected to BBMOD_id as value      |
    ...  | BBMOD_dedicated_FHS_dict                   | Dict with BBMOD_id as key and dedicated FHS list connected to BBMOD_id  as value  |
    [Arguments]  ${BBMOD_list}  ${alias}
    ${BBMOD_shared_FHS_dict}=  Create Dictionary
    ${BBMOD_dedicated_FHS_dict}=  Create Dictionary
    FOR  ${item}  IN  @{BBMOD_list}
        ${shared_FHS_list}  ${dedicated_FHS_list}=  Get FHS Mapping on specific BBMOD  ${item}  ${alias}
        Set To Dictionary  ${BBMOD_shared_FHS_dict}  ${item}  ${shared_FHS_list}
        Set To Dictionary  ${BBMOD_dedicated_FHS_dict}  ${item}  ${dedicated_FHS_list}
    END
    [Return]  ${BBMOD_shared_FHS_dict}  ${BBMOD_dedicated_FHS_dict}

Get FHS Mapping on specific BBMOD
    [Documentation]
    ...  Keyword providing lists of dedicated and shared FHS connected directly to a specific BBMOD
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | BBMOD_id          | Yes  |         | BBMOD id runtime view            |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                                  | Description                                 |
    ...  | shared_FHS_list                            | List of shared FHS connected to BBMOD_id    |
    ...  | dedicated_FHS_list                         | List of dedicated FHS connected to BBMOD_id |
    [Arguments]   ${BBMOD_id}  ${alias}
    ${shared_FHS_list}=  Create List
    ${dedicated_FHS_list}=  Create List

    ${BTS_FHS_alias_connection_dict}  ${BTS_shared_FHS_id_sn_dict}  ${BTS_dedicated_FHS_id_sn_dict}  ${BTS_shared_FHS_sn_id_dict}
    ...  ${BTS_dedicated_FHS_sn_id_dict}=  Admin Get shared and dedicated module info for BTS  FHS  ${alias}

    ${BTS_shared_FHS_list}=  Get Dictionary Keys  ${BTS_shared_FHS_id_sn_dict}
    ${BTS_dedicated_FHS_list}=  Get Dictionary Keys  ${BTS_dedicated_FHS_id_sn_dict}

    FOR  ${FHS_id}  IN  @{BTS_shared_FHS_list}
        ${FHS_check}=  Check connections from CABLINK info  ${BBMOD_id}  ${FHS_id}  ${alias}
        Run Keyword If  ${FHS_check}  Append To List  ${shared_FHS_list}  ${FHS_id}
    END

    FOR  ${FHS_id}  IN  @{BTS_dedicated_FHS_list}
        ${FHS_check}=  Check connections from CABLINK info  ${BBMOD_id}  ${FHS_id}  ${alias}
        Run Keyword If  ${FHS_check}  Append To List  ${dedicated_FHS_list}  ${FHS_id}
    END
    [Return]  ${shared_FHS_list}  ${dedicated_FHS_list}

Get BBMOD RMOD info
    [Documentation]
    ...  Keyword providing dedicated and shared RMOD dict for BBMOD list
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | BBMOD_list        | Yes  |         | BBMOD_id list                    |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                                  | Description                                                                      |
    ...  | BBMOD_shared_RMOD_dict                     | Dict with BBMOD_id as key and shared RMOD list connected to BBMOD_id as value    |
    ...  | BBMOD_dedicated_RMOD_dict                  | Dict with BBMOD_id as key and dedicated RMOD list connected to BBMOD_id as value |
    [Arguments]  ${BBMOD_list}  ${alias}
    ${BBMOD_shared_RMOD_dict}=  Create Dictionary
    ${BBMOD_dedicated_RMOD_dict}=  Create Dictionary
    FOR  ${item}  IN  @{BBMOD_list}
        ${shared_RMOD_list}  ${dedicated_RMOD_list}=  Get RMOD Mapping on specific BBMOD  ${item}  ${alias}
        Set To Dictionary  ${BBMOD_shared_RMOD_dict}  ${item}  ${shared_RMOD_list}
        Set To Dictionary  ${BBMOD_dedicated_RMOD_dict}  ${item}  ${dedicated_RMOD_list}
    END
    [Return]  ${BBMOD_shared_RMOD_dict}  ${BBMOD_dedicated_RMOD_dict}

Get RMOD Mapping on specific BBMOD
    [Documentation]
    ...  Keyword providing lists of dedicated and shared RMOD connected directly to a specific BBMOD
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | BBMOD_id          | Yes  |         | BBMOD id runtime view            |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                                   | Description                                   |
    ...  | shared_RMOD_list                            | List of shared RMODs connected to BBMOD_id    |
    ...  | dedicated_RMOD_list                         | List of dedicated RMODs connected to BBMOD_id |
    [Arguments]   ${BBMOD_id}  ${alias}
    ${shared_RMOD_list}=  Create List
    ${dedicated_RMOD_list}=  Create List

    ${BTS_RM_alias_connection_dict}  ${BTS_shared_RM_id_sn_dict}  ${BTS_dedicated_RM_id_sn_dict}  ${BTS_shared_RM_sn_id_dict}
     ...  ${BTS_dedicated_RM_sn_id_dict}=  Admin Get shared and dedicated module info for BTS  RMOD  ${alias}

    ${BTS_shared_RM_list}=  Get Dictionary Keys  ${BTS_shared_RM_id_sn_dict}
    ${BTS_dedicated_RM_list}=  Get Dictionary Keys  ${BTS_dedicated_RM_id_sn_dict}

    FOR  ${RM_id}  IN  @{BTS_shared_RM_list}
        ${RM_check}=  Check connections from CABLINK info  ${BBMOD_id}  ${RM_id}  ${alias}
        Run Keyword If  ${RM_check}  Append To List  ${shared_RMOD_list}  ${RM_id}
    END

    FOR  ${RM_id}  IN  @{BTS_dedicated_RM_list}
        ${RM_check}=  Check connections from CABLINK info  ${BBMOD_id}  ${RM_id}  ${alias}
        Run Keyword If  ${RM_check}  Append To List  ${dedicated_RMOD_list}  ${RM_id}
    END

    [Return]  ${shared_RMOD_list}  ${dedicated_RMOD_list}

Get BBMOD FHS RMOD info
    [Documentation]
    ...  Keyword providing dict with RMODs connected through FHS to BBMODs
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | BBMOD_list        | Yes  |         | BBMOD_id list                    |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                             | Description                                                                       |
    ...  | BBMOD_FHS_RMOD_dict                   | Dict of BBMOD id as key and RMOD list connected to BBMOD_id through FHS as value  |
    [Arguments]  ${BBMOD_list}  ${alias}

    ${BBMOD_FHS_RMOD_dict}=  Create Dictionary
    FOR  ${item}  IN  @{BBMOD_list}
        ${shared_FHS_list}  ${dedicated_FHS_list}=  Get FHS Mapping on specific BBMOD  ${item}  ${alias}
        ${FHS_list}=  Combine Lists  ${shared_FHS_list}  ${dedicated_FHS_list}
        ${RMOD_list}=  Get RMOD Mapping on FHS list  ${FHS_list}  ${alias}
        Set To Dictionary  ${BBMOD_FHS_RMOD_dict}  ${item}  ${RMOD_list}
    END
    [Return]  ${BBMOD_FHS_RMOD_dict}

Get FHS RMOD info
    [Documentation]
    ...  Keyword providing FHS info dict for RMODs connected to FHS
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | FHS_list          | Yes  |         | FHS_id list                      |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                                  | Description                                                               |
    ...  | FHS_RMOD_dict                              | Dict with FHS_id as key and shared RMOD list connected to FHS_id as value |
    [Arguments]  ${FHS_list}  ${alias}
    ${FHS_RMOD_dict}=  Create Dictionary
    FOR  ${item}  IN  @{FHS_list}
        ${FHS_RMOD_list}=  Get RMOD Mapping on specific FHS  ${item}  ${alias}
        Set To Dictionary  ${FHS_RMOD_dict}  ${item}  ${FHS_RMOD_list}
    END
    [Return]  ${FHS_RMOD_dict}

Get RMOD Mapping on FHS list
    [Documentation]
    ...  Keyword providing RMOD list connected directly to FHS list
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | FHS_list          | Yes  |         | FHS_id list                      |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                                   | Description                          |
    ...  | FHS_RMOD_list                               | List of RMODs connected to FHS list  |
    [Arguments]  ${FHS_list}  ${alias}
    ${FHS_RMOD_dict}=  Get FHS RMOD info  ${FHS_list}  ${alias}
    ${FHS_RMOD_list}=  Create List
    FOR  ${item}  IN  @{FHS_list}
        ${RMOD_list}=  Get From Dictionary  ${FHS_RMOD_dict}  ${item}
        Append To List  ${FHS_RMOD_list}  @{RMOD_list}
    END
    [Return]  ${FHS_RMOD_list}

Get RMOD Mapping on specific FHS
    [Documentation]
    ...  Keyword providing RMOD list connected directly to a specific FHS
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | FHS_id            | Yes  |         | FHS id runtime view              |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                                   | Description                          |
    ...  | FHS_RMOD_list                               | List of RMODs connected to FHS_id    |
    [Arguments]   ${FHS_id}  ${alias}
    ${FHS_RMOD_list}=  Create List
    ${RMOD_list}=  Get Ids For All  class_name=RMOD  connection=${alias}
    FOR  ${RM_id}  IN  @{RMOD_list}
        ${RM_check}=  Check connections from CABLINK info  ${FHS_id}  ${RM_id}  ${alias}
        Run Keyword If  ${RM_check}  Append To List  ${FHS_RMOD_list}  ${RM_id}
    END
    [Return]  ${FHS_RMOD_list}

Check connections from CABLINK info
    [Arguments]  ${first_item_id}  ${second_item_id}  ${alias}
    ${connection_check}=  Set Variable  False

    ${BTS_CABLINK_id_firstEndPointId_dict}  ${BTS_CABLINK_id_secondEndPointId_dict}  ${BTS_CABLINK_id_configuration_dict}
    ...  ${BTS_CABLINK_id_data_dict}  ${BTS_CABLINK_id_dc_dict}  ${BTS_CABLINK_id_synchronization_dict}
    ...  ${BTS_CABLINK_id_operationalState_dict}=  Admin Get CABLINK info dict  ${alias}

    ${CABLINK_list}=  Get Dictionary Keys  ${BTS_CABLINK_id_firstEndPointId_dict}
    FOR  ${CABLINK_id}  IN  @{CABLINK_list}
        ${CABLINK_firstEndPointId}=  Get From Dictionary  ${BTS_CABLINK_id_firstEndPointId_dict}  ${CABLINK_id}
        ${CABLINK_secondEndPointId}=  Get From Dictionary  ${BTS_CABLINK_id_secondEndPointId_dict}  ${CABLINK_id}

        ${firstEndPoint_id_regex}=  Regexp Escape  ${first_item_id}
        ${firstEndPointId}=  Run Keyword And Return Status  Should Match Regexp  ${CABLINK_firstEndPointId}
        ...  ${firstEndPoint_id_regex}$|${firstEndPoint_id_regex}\/
        ${secondEndPoint_id_regex}=  Regexp Escape  ${second_item_id}
        ${secondEndPointId}=  Run Keyword And Return Status  Should Match Regexp  ${CABLINK_secondEndPointId}
        ...  ${secondEndPoint_id_regex}$|${secondEndPoint_id_regex}\/
        Return From Keyword If  ${firstEndPointId} and ${secondEndpointId}  True
    END
    [Return]  ${connection_check}

Get PL info for RMOD FHS on all BBMOD
    [Documentation]
    ...  Keyword providing RMODs and FHS primary link info dict for BBMODs connected to alias
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                         | Description                                                                                |
    ...  | BBMOD_PL_FHS_RM_dict              | Dict with BBMOD_id as key and dict of primary link elements connected to BBMOD_id as value |
    [Arguments]  ${alias}

    ${BBMOD_PL_FHS_RM_dict}=  Create Dictionary
    ${BBMOD_list}=  Get Ids For All  BBMOD  alias=${alias}

    FOR  ${BBMOD_id}  IN  @{BBMOD_list}
        ${BBMOD_PL_FHS_RMOD_info}=  Get PL info for RMOD FHS on specific BBMOD  ${BBMOD_id}  ${alias}
        Set To Dictionary  ${BBMOD_PL_FHS_RM_dict}  ${BBMOD_id}  ${BBMOD_PL_FHS_RMOD_info}
    END
    [Return]  ${BBMOD_PL_FHS_RM_dict}

Get PL info for RMOD FHS on specific BBMOD
    [Documentation]
    ...  Keyword providing primary link info dict for RMODs and FHS connected to a specific BBMOD
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | BBMOD_id          | Yes  |         | BBMOD id runtime view            |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                                   | Description                                                   |
    ...  | BBMOD_PL_info_dict                          | Dict with OBSAI, CPRI, ECPRI RMODs and FHS lists for BBMOD_id |
    [Arguments]  ${BBMOD_id}  ${alias}

    ${BBMOD_PL_OBSAI_RMOD_list}=  Create List
    ${BBMOD_PL_CPRI_RMOD_list}=  Create List
    ${BBMOD_PL_ECPRI_RMOD_list}=  Create List
    ${BBMOD_PL_FHS_list}=  Create List

    ${RM_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}

    ${shared_RMOD_list}  ${dedicated_RMOD_list}=  Get RMOD Mapping on specific BBMOD  ${BBMOD_id}  ${alias}
    ${RMOD_list}=  Combine Lists  ${shared_RMOD_list}  ${dedicated_RMOD_list}
    ${shared_FHS_list}  ${dedicated_FHS_list}=  Get FHS Mapping on specific BBMOD  ${BBMOD_id}  ${alias}
    ${FHS_list}=  Combine Lists  ${shared_FHS_list}  ${dedicated_FHS_list}

    FOR  ${item}  IN  @{RMOD_list}
        ${RM_L3Protocol}=  Get From Dictionary  ${RM_L3Protocol_dict}  ${item}
        ${connection_info_dict}=  Get port connection info  ${BBMOD_id}  ${item}  ${alias}
        ${synchronization_value}=  Get Dictionary Values  ${connection_info_dict}
        Run Keyword If  'True' in '${synchronization_value}' and '${RM_L3Protocol}' == 'RP301_RP1'
        ...  Append To List  ${BBMOD_PL_OBSAI_RMOD_list}  ${item}
        Run Keyword If  'True' in '${synchronization_value}' and '${RM_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${BBMOD_PL_CPRI_RMOD_list}  ${item}
        Run Keyword If  'True' in '${synchronization_value}' and '${RM_L3Protocol}' == 'ECPRI_MPLANE'
        ...  Append To List  ${BBMOD_PL_ECPRI_RMOD_list}  ${item}
    END

    FOR  ${item}  IN  @{FHS_list}
        ${connection_info_dict}=  Get port connection info  ${BBMOD_id}  ${item}  ${alias}
        ${synchronization_value}=  Get Dictionary Values  ${connection_info_dict}
        Run Keyword If  'True' in '${synchronization_value}'
        ...  Append To List  ${BBMOD_PL_FHS_list}  ${item}
    END

    ${BBMOD_PL_info_dict}=  Create Dictionary
    ...  BBMOD_PL_OBSAI_RMOD_list=${BBMOD_PL_OBSAI_RMOD_list}
    ...  BBMOD_PL_CPRI_RMOD_list=${BBMOD_PL_CPRI_RMOD_list}
    ...  BBMOD_PL_ECPRI_RMOD_list=${BBMOD_PL_ECPRI_RMOD_list}
    ...  BBMOD_PL_FHS_list=${BBMOD_PL_FHS_list}

    [Return]  ${BBMOD_PL_info_dict}

Get port connection info
    [Documentation]
    ...  Keyword providing dict for secondEndPoint port id and synchronization value regarding connection to firstEndPoint
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | first_item_id     | Yes  |         | firstEndPoint id runtime view    |
    ...  | second_item_id    | Yes  |         | secondEndPoint id runtime view   |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                                   | Description                                                           |
    ...  | port_connection_info                        | Dict with secondEndPoint port id as key and synchronization as value  |
    [Arguments]   ${first_item_id}  ${second_item_id}  ${alias}
    ${port_connection_info} =  Create Dictionary
    ${BTS_CABLINK_id_firstEndPointId_dict}  ${BTS_CABLINK_id_secondEndPointId_dict}  ${BTS_CABLINK_id_configuration_dict}
    ...  ${BTS_CABLINK_id_data_dict}  ${BTS_CABLINK_id_dc_dict}  ${BTS_CABLINK_id_synchronization_dict}
    ...  ${BTS_CABLINK_id_operationalState_dict}=  Admin Get CABLINK info dict  ${alias}

    ${CABLINK_list}=  Get Dictionary Keys  ${BTS_CABLINK_id_firstEndPointId_dict}
    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects
    FOR  ${CABLINK_id}  IN  @{CABLINK_list}
        ${CABLINK_dn}=  Get CABLINK SCF distinguished name  ${CABLINK_id}  ${alias}
        Continue For Loop If  '${CABLINK_dn}' == 'None'

        ${secondEndpointPortId}=  Check Parameter value from SCF  item_dist_name=${CABLINK_dn}  parameter_to_check=secondEndpointPortId
        ...  scf_path=${BTS_scf}
        ${CABLINK_firstEndPointId}=  Get From Dictionary  ${BTS_CABLINK_id_firstEndPointId_dict}  ${CABLINK_id}
        ${CABLINK_secondEndPointId}=  Get From Dictionary  ${BTS_CABLINK_id_secondEndPointId_dict}  ${CABLINK_id}
        ${synchronization_value}=  Get From Dictionary  ${BTS_CABLINK_id_synchronization_dict}  ${CABLINK_id}

        ${firstEndPoint_id_regex}=  Regexp Escape  ${first_item_id}
        ${firstEndPointId}=  Run Keyword And Return Status  Should Match Regexp  ${CABLINK_firstEndPointId}
        ...  ${firstEndPoint_id_regex}$|${firstEndPoint_id_regex}\/
        ${secondEndPoint_id_regex}=  Regexp Escape  ${second_item_id}
        ${secondEndPointId}=  Run Keyword And Return Status  Should Match Regexp  ${CABLINK_secondEndPointId}
        ...  ${secondEndPoint_id_regex}$|${secondEndPoint_id_regex}\/

        Run Keyword If  ${firstEndPointId} and ${secondEndPointId}
        ...  Set To Dictionary  ${port_connection_info}  ${secondEndpointPortId}  ${synchronization_value}
    END

    [Return]  ${port_connection_info}

Get cell technology distName info
    [Arguments]  ${cell_dn}  ${cell_technology}  ${alias}

    ${cell_technology_distName_list}=  Get All Dist Names By Pattern from SCF  pattern=/LNCEL_${cell_technology}-[\\d]+$
    ...  scf_path=${${alias.lower()}_scf_initial}  alias=${alias}

    ${cell_technology_distName_found}=  Set Variable  ${FALSE}

    FOR  ${cell_technology_distName}  IN  @{cell_technology_distName_list}
        ${cell_tech}=  Fetch From Right  ${cell_technology_distName}  /
        ${cell_distName}=  Remove String  ${cell_technology_distName}  /${cell_tech}
        ${cell_technology_distName_found}=  Set Variable If  '${cell_distName}' == '${cell_dn}'  ${TRUE}  ${cell_technology_distName_found}
        Exit For Loop If  ${cell_technology_distName_found}
    END

    Should Be True  ${cell_technology_distName_found}

    [Return]   ${cell_technology_distName}

Get List of Configured Channel Groups
    [Documentation]
    ...  Helper keyword for Admin Get NR CELL list with cell info; Admin Get LTE CELL list with cell info
    [Arguments]  ${carrierList}

    ${channel_group_id_list}=  Create List
    FOR  ${item}  IN  @{carrierList}
        ${channel_name}=  Fetch From Right  ${item['id']['internal']}  /
        ${channel_group}=  Remove String  ${item['id']['internal']}  /${channel_name}
        ${channel_group}=  Fetch From Right  ${channel_group}  /
        Append To List  ${channel_group_id_list}  ${channel_group}
    END
    ${channel_group_id_list}=  Remove Duplicates  ${channel_group_id_list}
    Sort List  ${channel_group_id_list}

    [Return]  ${channel_group_id_list}

Get Cell TX RX channelGroup and state info
    [Documentation]
    ...  Helper keyword for Admin Get NR CELL list with cell info; Admin Get LTE CELL list with cell info
    [Arguments]  ${channel_group_id_list}  ${carrierList}  ${alias}=default
    ${CELL_TX_RX_dictionary}=  Create Dictionary
    Set Test Variable  ${TX_Total}  0
    Set Test Variable  ${RX_Total}  0
    Set Test Variable  ${TX_Online}  0
    Set Test Variable  ${RX_Online}  0
    Set Test Variable  ${TX_Failed}  0
    Set Test Variable  ${RX_Failed}  0
    Set Test Variable  ${TX_Degraded}  0
    Set Test Variable  ${RX_Degraded}  0
    Set Test Variable  ${TX_Dependency}  0
    Set Test Variable  ${RX_Dependency}  0
    FOR  ${item}  IN  @{channel_group_id_list}
        ${label}=  Set Variable  ${item}
        ${CELL_TX_RX_list}=  Get Cell TX RX state with channelGroup info  ${label}  ${carrierList}  ${alias}
        Set To Dictionary  ${CELL_TX_RX_dictionary}  ${label}  ${CELL_TX_RX_list}
    END
    ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}  ${TX_Dependency}
    ...  ${RX_Dependency}=  Get Cell TX RX state without channelGroup info  ${carrierList}  ${alias}

    [Return]  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}  ${TX_Dependency}
    ...  ${RX_Dependency}  ${CELL_TX_RX_dictionary}

Get Cell TX RX state with channelGroup info
    [Documentation]
    ...  Helper keyword for Get Cell TX RX channelGroup and state info
    [Arguments]  ${label}  ${carrierList}  ${alias}

    ${CELL_TX_RX_list}=  Create List

    FOR  ${item}  IN  @{carrierList}
        ${channel_name}=  Fetch From Right  ${item['id']['internal']}  /
        ${channel_group}=  Remove String  ${item['id']['internal']}  /${channel_name}
        ${channel_group}=  Fetch From Right  ${channel_group}  /

        Run Keyword If  '${channel_group}' != '${label}'  Continue For Loop
        ${CHANNEL_M_param}=  coam.Get Parameters  dist_name=${item['id']['internal']}  connection=${alias}
        ${TX_Total}=  Evaluate Value  ${TX_Total}  ${CHANNEL_M_param['direction']}  TX
        ${RX_Total}=  Evaluate Value  ${RX_Total}  ${CHANNEL_M_param['direction']}  RX
        ${TX_Online}=  Evaluate Value  ${TX_Online}  ${CHANNEL_M_param['direction']}  TX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Online
        ${RX_Online}=  Evaluate Value  ${RX_Online}  ${CHANNEL_M_param['direction']}  RX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Online
        ${TX_Failed}=  Evaluate Value  ${TX_Failed}  ${CHANNEL_M_param['direction']}  TX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Failed
        ${RX_Failed}=  Evaluate Value  ${RX_Failed}  ${CHANNEL_M_param['direction']}  RX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Failed
        ${TX_Degraded}=  Evaluate Value  ${TX_Degraded}  ${CHANNEL_M_param['direction']}  TX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Degraded
        ${RX_Degraded}=  Evaluate Value  ${RX_Degraded}  ${CHANNEL_M_param['direction']}  RX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Degraded
        ${TX_Dependency}=  Evaluate Value  ${TX_Dependency}  ${CHANNEL_M_param['direction']}  TX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Dependency
        ${RX_Dependency}=  Evaluate Value  ${RX_Dependency}  ${CHANNEL_M_param['direction']}  RX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Dependency
    END

    Append To List  ${CELL_TX_RX_list}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}
    ...  ${RX_Degraded}  ${TX_Dependency}  ${RX_Dependency}

    [Return]  ${CELL_TX_RX_list}

Get Cell TX RX state without channelGroup info
    [Documentation]
    ...  Helper keyword for Get Cell TX RX channelGroup and state info
    [Arguments]  ${carrierList}  ${alias}

    FOR  ${item}  IN  @{carrierList}
        ${CHANNEL_M_param}=  coam.Get Parameters  dist_name=${item['id']['internal']}  connection=${alias}
        ${TX_Total}=  Evaluate Value  ${TX_Total}  ${CHANNEL_M_param['direction']}  TX
        ${RX_Total}=  Evaluate Value  ${RX_Total}  ${CHANNEL_M_param['direction']}  RX
        ${TX_Online}=  Evaluate Value  ${TX_Online}  ${CHANNEL_M_param['direction']}  TX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Online
        ${RX_Online}=  Evaluate Value  ${RX_Online}  ${CHANNEL_M_param['direction']}  RX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Online
        ${TX_Failed}=  Evaluate Value  ${TX_Failed}  ${CHANNEL_M_param['direction']}  TX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Failed
        ${RX_Failed}=  Evaluate Value  ${RX_Failed}  ${CHANNEL_M_param['direction']}  RX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Failed
        ${TX_Degraded}=  Evaluate Value  ${TX_Degraded}  ${CHANNEL_M_param['direction']}  TX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Degraded
        ${RX_Degraded}=  Evaluate Value  ${RX_Degraded}  ${CHANNEL_M_param['direction']}  RX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Degraded
        ${TX_Dependency}=  Evaluate Value  ${TX_Dependency}  ${CHANNEL_M_param['direction']}  TX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Dependency
        ${RX_Dependency}=  Evaluate Value  ${RX_Dependency}  ${CHANNEL_M_param['direction']}  RX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Dependency
    END

    [Return]  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}  ${TX_Dependency}
    ...  ${RX_Dependency}

Get all BTS DSS feature info
    [Documentation]
    ...  Keyword providing all BTS DSS feature info dict as described below:
    ...  - BTS XP interface info dictionary: key=BTS_alias - value=remote_BTS_alias
    ...  - NRBTS parameter actLteNrDss dictionary: key=BTS_alias - value=actLteNrDss
    ...  - LNBTS parameter actLteNrDss dictionary: key=BTS_alias - value=actLteNrDss
    ...  - BTS DSS NR-LTE scf cells dictionary: key=BTS_alias - value=dictionary (key=NRCELL - value=LNCEL)
    ...  - BTS DSS LTE-NR scf cells dictionary: key=BTS_alias - value=dictionary (key=LNCEL - value=NRCELL)
    ...  - BTS DSS NR-LTE runtime cells dictionary: key=BTS_alias - value=dictionary (key=NRCELL_R - value=LNCEL_R)
    ...  - BTS DSS LTE-NR runtime cells dictionary: key=BTS_alias - value=dictionary (key=LNCEL_R - value=NRCELL_R)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter                             | Description                       |
    ...  | ${BTS_XP_localAlias_remoteAlias_dict} | BTS XP interface info dict        |
    ...  | ${NRBTS_DSS_alias_actLteNrDss_dict}   | NRBTS parameter actLteNrDss dict  |
    ...  | ${LNBTS_DSS_alias_actLteNrDss_dict}   | LNBTS parameter actLteNrDss dict  |
    ...  | ${BTS_DSS_NR_LTE_CELL_scf_dict}       | BTS DSS NR-LTE scf cells dict     |
    ...  | ${BTS_DSS_LTE_NR_CELL_scf_dict}       | BTS DSS LTE-NR scf cells dict     |
    ...  | ${BTS_DSS_NR_LTE_CELL_runtime_dict}   | BTS DSS NR-LTE runtime cells dict |
    ...  | ${BTS_DSS_LTE_NR_CELL_runtime_dict}   | BTS DSS LTE-NR runtime cells dict |
    ...

    ${BTS_alias_scf_dict}=  Get all BTS SCF dict

    ${BTS_alias_CELL_tech_runtime_scf_dict}  ${BTS_alias_CELL_tech_scf_runtime_dict}=  Get all BTS CELL runtime and scf info dict

    ${BTS_XP_localAlias_remoteAlias_dict}=  Get all BTS XP interface info from SCF  ${BTS_alias_scf_dict}

    ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}=
    ...  Get all BTS DSS feature scf info for NR and LTE cells  ${BTS_alias_scf_dict}  ${BTS_XP_localAlias_remoteAlias_dict}
    ...  ${BTS_alias_CELL_tech_scf_runtime_dict}

    ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}=  Get all BTS DSS feature runtime info for NR and LTE cells
    ...  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_XP_localAlias_remoteAlias_dict}
    ...  ${BTS_alias_CELL_tech_scf_runtime_dict}

    [Return]  ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}
    ...  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}

Get all BTS SCF dict

    ${BTS_alias_scf_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects

        Set To Dictionary  ${BTS_alias_scf_dict}  ${alias}  ${BTS_scf}

        Sleep  2s

    END

    [Return]  ${BTS_alias_scf_dict}

Get all BTS CELL runtime and scf info dict

    ${BTS_alias_CELL_tech_runtime_scf_dict}=  Create Dictionary
    ${BTS_alias_CELL_tech_scf_runtime_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${CELL_tech_runtime_scf_dict}  ${CELL_tech_scf_runtime_dict}=  Get BTS CELL runtime and scf info dict  ${alias}

        Set To Dictionary  ${BTS_alias_CELL_tech_runtime_scf_dict}  ${alias}  ${CELL_tech_runtime_scf_dict}
        Set To Dictionary  ${BTS_alias_CELL_tech_scf_runtime_dict}  ${alias}  ${CELL_tech_scf_runtime_dict}

    END

    [Return]  ${BTS_alias_CELL_tech_runtime_scf_dict}  ${BTS_alias_CELL_tech_scf_runtime_dict}

Get all BTS XP interface info from SCF
    [Arguments]  ${BTS_alias_scf_dict}

    ${BTS_XP_localAlias_remoteAlias_dict}=  Create Dictionary
    ${BTS_alias_XP_ip_dict}=  Create Dictionary
    ${BTS_alias_XPIFREMOTE_ip_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_scf}=  Get From Dictionary  ${BTS_alias_scf_dict}  ${alias}

        ${XPIF_ip_XPIFREMOTE_ip_dict}=  Get BTS XP interface info from SCF  ${BTS_scf}  ${alias}
        ${XPIF_ip_list}=  Get Dictionary Keys  ${XPIF_ip_XPIFREMOTE_ip_dict}  False
        ${XPIFREMOTE_ip_list}=  Get Dictionary Values  ${XPIF_ip_XPIFREMOTE_ip_dict}  False

        Set To Dictionary  ${BTS_alias_XP_ip_dict}  ${alias}  ${XPIF_ip_list}
        Set To Dictionary  ${BTS_alias_XPIFREMOTE_ip_dict}  ${alias}  ${XPIFREMOTE_ip_list}

    END

    FOR  ${alias}  IN  @{alias_list}

        ${XPIFREMOTE_ip_list}=  Get From Dictionary  ${BTS_alias_XPIFREMOTE_ip_dict}  ${alias}
        ${XPIF_ip_list}=  Get From Dictionary  ${BTS_alias_XP_ip_dict}  ${alias}
        ${XPIFREMOTE_alias_list}=  Get all BTS XPIFREMOTE alias info  ${BTS_alias_XP_ip_dict}  ${XPIFREMOTE_ip_list}
        ${XPIFREMOTE_alias_list}=  Remove Duplicates  ${XPIFREMOTE_alias_list}

        Set To Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}  ${XPIFREMOTE_alias_list}

    END

    [Return]  ${BTS_XP_localAlias_remoteAlias_dict}

Get BTS XP interface info from SCF
    [Arguments]  ${BTS_scf}  ${alias}

    ${XPIF_ip_XPIFREMOTE_ip_dict}=  Create Dictionary

    ${XPAP_distName_list}=  Get All Dist Names By Pattern from SCF  pattern=/XPAP-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${XPAP_distName_count}=  Get Length  ${XPAP_distName_list}
    Return From Keyword If  ${XPAP_distName_count} == 0  ${XPIF_ip_XPIFREMOTE_ip_dict}

    ${XPIF_distName_list}=  Get All Dist Names By Pattern from SCF  pattern=/XPIF-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${XPIF_distName_count}=  Get Length  ${XPIF_distName_list}
    Return From Keyword If  ${XPIF_distName_count} == 0  ${XPIF_ip_XPIFREMOTE_ip_dict}

    FOR  ${XPIF_distName}  IN  @{XPIF_distName_list}

        ${XPIF_ipV4AddressDN1_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${XPIF_distName}
        ...  p_name=ipV4AddressDN1
        ${XPIF_ipV4AddressDN1_count}=  Get Length  ${XPIF_ipV4AddressDN1_info_dict}
        ${XPIF_ipV4AddressDN1}=  Run Keyword If  ${XPIF_ipV4AddressDN1_count} > 0
        ...  Get From Dictionary  ${XPIF_ipV4AddressDN1_info_dict}  ipV4AddressDN1
        ...  ELSE
        ...  Set Variable  NA
        Continue For Loop If  '${XPIF_ipV4AddressDN1}' == 'NA'

        ${IPADDRESSV4_localIpAddr_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${XPIF_ipV4AddressDN1}
        ...  p_name=localIpAddr
        ${IPADDRESSV4_localIpAddr_count}=  Get Length  ${IPADDRESSV4_localIpAddr_info_dict}
        ${XPIF_localIpAddr}=  Run Keyword If  ${IPADDRESSV4_localIpAddr_count} > 0
        ...  Get From Dictionary  ${IPADDRESSV4_localIpAddr_info_dict}  localIpAddr
        ...  ELSE
        ...  Set Variable  NA
        Continue For Loop If  '${XPIF_localIpAddr}' == 'NA'

        ${XPIFREMOTE_ipAddress}=  Get and check BTS XPIFREMOTE info  ${BTS_scf}  ${XPIF_distName}  ${alias}
        Continue For Loop If  '${XPIFREMOTE_ipAddress}' == 'NA'

        Set To Dictionary  ${XPIF_ip_XPIFREMOTE_ip_dict}  ${XPIF_localIpAddr}  ${XPIFREMOTE_ipAddress}

    END

    [Return]  ${XPIF_ip_XPIFREMOTE_ip_dict}

Get and check BTS XPIFREMOTE info
    [Arguments]  ${BTS_scf}  ${XPIF_distName}  ${alias}

    ${XPIFREMOTE_ipAddress}=  Set Variable  NA

    ${XPIFREMOTE_distName_list}=  Get All Dist Names By Pattern from SCF  pattern=/XPIFREMOTE-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${XPIFREMOTE_distName_count}=  Get Length  ${XPIFREMOTE_distName_list}
    Return From Keyword If  ${XPIFREMOTE_distName_count} == 0  ${XPIFREMOTE_ipAddress}

    FOR  ${XPIFREMOTE_distName}  IN  @{XPIFREMOTE_distName_list}

        ${SCF_XPIF_distName}=  Fetch From Left  ${XPIFREMOTE_distName}  /XPIFREMOTE
        Continue For Loop If  '${SCF_XPIF_distName}' != '${XPIF_distName}'

        ${XPIFREMOTE_ipAddress_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${XPIFREMOTE_distName}
        ...  p_name=ipAddress
        ${XPIF_ipV4AddressDN1_count}=  Get Length  ${XPIFREMOTE_ipAddress_info_dict}
        ${XPIFREMOTE_ipAddress}=  Run Keyword If  ${XPIF_ipV4AddressDN1_count} > 0
        ...  Get From Dictionary  ${XPIFREMOTE_ipAddress_info_dict}  ipAddress
        ...  ELSE
        ...  Set Variable  NA
        Continue For Loop If  '${XPIFREMOTE_ipAddress}' == 'NA'

    END

    [Return]  ${XPIFREMOTE_ipAddress}

Get all BTS XPIFREMOTE alias info
    [Arguments]  ${BTS_alias_XP_ip_dict}  ${XPIFREMOTE_ip_list}

    ${XPIFREMOTE_alias_list}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        ${XPIFREMOTE_alias_list}=  Get BTS XPIFREMOTE alias info  ${BTS_alias_XP_ip_dict}  ${XPIFREMOTE_ip_list}  ${XPIFREMOTE_alias_list}  ${alias}

    END

    [Return]  ${XPIFREMOTE_alias_list}

Get BTS XPIFREMOTE alias info
    [Arguments]  ${BTS_alias_XP_ip_dict}  ${XPIFREMOTE_ip_list}  ${XPIFREMOTE_alias_list}  ${alias}

    FOR  ${XPIFREMOTE_ip}  IN  @{XPIFREMOTE_ip_list}

        ${XPIF_ip_list}=  Get From Dictionary  ${BTS_alias_XP_ip_dict}  ${alias}

        Run Keyword If  '${XPIFREMOTE_ip}' in ${XPIF_ip_list}
        ...  Append To List  ${XPIFREMOTE_alias_list}  ${alias}

    END

    [Return]  ${XPIFREMOTE_alias_list}

Get all BTS DSS feature scf info for NR and LTE cells
    [Arguments]  ${BTS_alias_scf_dict}  ${BTS_XP_localAlias_remoteAlias_dict}  ${BTS_alias_CELL_tech_scf_runtime_dict}

    ${NRBTS_DSS_alias_actLteNrDss_dict}=  Create Dictionary
    ${LNBTS_DSS_alias_actLteNrDss_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_scf}=  Get From Dictionary  ${BTS_alias_scf_dict}  ${alias}

        ${NRBTS_actLteNrDss}=  Get BTS DSS feature parameter actLteNrDss info from SCF  ${BTS_scf}  NRBTS  ${alias}
        ${LNBTS_actLteNrDss}=  Get BTS DSS feature parameter actLteNrDss info from SCF  ${BTS_scf}  LNBTS  ${alias}

        Set To Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}  ${NRBTS_actLteNrDss.title()}
        Set To Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}  ${LNBTS_actLteNrDss.title()}

    END

    ${BTS_NRCELL_distName_LNCEL_phyCellId_dict}=  Create Dictionary
    ${BTS_LNCEL_distName_NRCELL_nrCellId_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_scf}=  Get From Dictionary  ${BTS_alias_scf_dict}  ${alias}
        ${CELL_tech_scf_runtime_dict}=  Get From Dictionary  ${BTS_alias_CELL_tech_scf_runtime_dict}  ${alias}

        ${NRCELL_distName_LNCEL_phyCellId_dict}  ${LNCEL_distName_NRCELL_nrCellId_dict}=  Get BTS DSS feature info from SCF  ${BTS_scf}
        ...  ${CELL_tech_scf_runtime_dict}  ${alias}

        Set To Dictionary  ${BTS_NRCELL_distName_LNCEL_phyCellId_dict}  ${alias}  ${NRCELL_distName_LNCEL_phyCellId_dict}
        Set To Dictionary  ${BTS_LNCEL_distName_NRCELL_nrCellId_dict}  ${alias}  ${LNCEL_distName_NRCELL_nrCellId_dict}

    END

    ${BTS_NRCELL_nrCellId_distName_dict}=  Create Dictionary
    ${BTS_LNCEL_phyCellId_distName_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_scf}=  Get From Dictionary  ${BTS_alias_scf_dict}  ${alias}
        ${NRBTS_actLteNrDss}=  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
        ${LNBTS_actLteNrDss}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}

        ${NRCELL_distName_LNCEL_phyCellId_dict}=  Get From Dictionary  ${BTS_NRCELL_distName_LNCEL_phyCellId_dict}  ${alias}
        ${LNCEL_distName_NRCELL_nrCellId_dict}=  Get From Dictionary  ${BTS_LNCEL_distName_NRCELL_nrCellId_dict}  ${alias}

        ${DSS_NRCELL_distName_list}=  Get Dictionary Keys  ${NRCELL_distName_LNCEL_phyCellId_dict}
        ${DSS_LNCEL_distName_list}=  Get Dictionary Keys  ${LNCEL_distName_NRCELL_nrCellId_dict}

        ${NRCELL_distName_nrCellId_dict}  ${NRCELL_nrCellId_distName_dict}=  Get NR distName nrCellId info dict  ${BTS_scf}
        ...  ${DSS_NRCELL_distName_list}
        ${LNCEL_distName_phyCellId_dict}  ${LNCEL_phyCellId_distName_dict}=  Get LTE distName phyCellId info dict  ${BTS_scf}
        ...  ${DSS_LNCEL_distName_list}

        Set To Dictionary  ${BTS_NRCELL_nrCellId_distName_dict}  ${alias}  ${NRCELL_nrCellId_distName_dict}
        Set To Dictionary  ${BTS_LNCEL_phyCellId_distName_dict}  ${alias}  ${LNCEL_phyCellId_distName_dict}

    END

    ${BTS_DSS_NR_LTE_CELL_scf_dict}=  Create Dictionary
    ${BTS_DSS_LTE_NR_CELL_scf_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_DSS_peer_alias_list}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
        ${BTS_DSS_peer_alias_count}=  Get Length  ${BTS_DSS_peer_alias_list}
        Continue For Loop If  ${BTS_DSS_peer_alias_count} == 0

        ${NRCELL_distName_LNCEL_phyCellId_dict}=  Get From Dictionary  ${BTS_NRCELL_distName_LNCEL_phyCellId_dict}  ${alias}
        ${LNCEL_distName_NRCELL_nrCellId_dict}=  Get From Dictionary  ${BTS_LNCEL_distName_NRCELL_nrCellId_dict}  ${alias}

        ${NRCELL_nrCellId_distName_dict}=  Get DSS info from peer BTS  ${BTS_NRCELL_nrCellId_distName_dict}  ${BTS_DSS_peer_alias_list}
        ${LNCEL_phyCellId_distName_dict}=  Get DSS info from peer BTS  ${BTS_LNCEL_phyCellId_distName_dict}  ${BTS_DSS_peer_alias_list}

        ${NR_LTE_CELL_DSS_scf_dict}  ${LTE_NR_CELL_DSS_scf_dict}=  Get and check NR LTE DSS association
        ...  ${NRCELL_distName_LNCEL_phyCellId_dict}  ${LNCEL_distName_NRCELL_nrCellId_dict}
        ...  ${NRCELL_nrCellId_distName_dict}  ${LNCEL_phyCellId_distName_dict}

        Set To Dictionary  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${alias}  ${NR_LTE_CELL_DSS_scf_dict}
        Set To Dictionary  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${alias}  ${LTE_NR_CELL_DSS_scf_dict}

    END

    [Return]   ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${BTS_DSS_NR_LTE_CELL_scf_dict}
    ...  ${BTS_DSS_LTE_NR_CELL_scf_dict}

Get DSS info from peer BTS
    [Arguments]    ${BTS_CELL_CellId_distName_dict}  ${BTS_DSS_peer_alias_list}

    ${all_CELL_CellId_distName_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{BTS_DSS_peer_alias_list}

        ${CELL_CellId_distName_dict}=  Get From Dictionary  ${BTS_CELL_CellId_distName_dict}  ${alias}
        ${all_CELL_CellId_distName_dict}=  Append Dictionary To Target Dictionary  ${all_CELL_CellId_distName_dict}  ${CELL_CellId_distName_dict}

    END

    [Return]  ${all_CELL_CellId_distName_dict}

Append Dictionary To Target Dictionary
    [Arguments]    ${target_dictionary}  ${dictionary_to_add}

    ${dictionary_keys}=  Get Dictionary Keys  ${dictionary_to_add}  False

    FOR  ${key}  IN  @{dictionary_keys}

        ${value}=  Get From Dictionary  ${dictionary_to_add}  ${key}
        Set To Dictionary   ${target_dictionary}  ${key}=${value}

    END

    [Return]  ${target_dictionary}

Get BTS DSS feature parameter actLteNrDss info from SCF
    [Arguments]  ${BTS_scf}  ${BTS_obj}  ${alias}

    ${BTS_actLteNrDss}=  Set Variable  None

    ${BTS_obj_distName_list}=  Get All Dist Names By Pattern from SCF  pattern=/${BTS_obj}-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${BTS_obj_distName_count}=  Get Length  ${BTS_obj_distName_list}
    Return From Keyword If  ${BTS_obj_distName_count} == 0  ${BTS_actLteNrDss}

    ${BTS_obj_distName}=  Get From List  ${BTS_obj_distName_list}  0

    ${BTS_actLteNrDss_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${BTS_obj_distName}
    ...  p_name=actLteNrDss
    ${BTS_actLteNrDss_count}=  Get Length  ${BTS_actLteNrDss_info_dict}
    ${BTS_actLteNrDss}=  Run Keyword If  ${BTS_actLteNrDss_count} > 0
    ...  Get From Dictionary  ${BTS_actLteNrDss_info_dict}  actLteNrDss
    ...  ELSE
    ...  Set Variable  None

    [Return]  ${BTS_actLteNrDss}

Get BTS DSS feature info from SCF
    [Arguments]  ${BTS_scf}  ${CELL_tech_scf_runtime_dict}  ${alias}

    ${NRCELL_scf_runtime_dict}=  Get From Dictionary  ${CELL_tech_scf_runtime_dict}  nr
    ${NRCELL_distName_list}=  Get Dictionary Keys  ${NRCELL_scf_runtime_dict}
    ${NRCELL_distName_LNCEL_phyCellId_dict}=  Get and check BTS DSS feature info for NR cells  ${BTS_scf}  ${NRCELL_distName_list}  ${alias}

    ${LNCEL_scf_runtime_dict}=  Get From Dictionary  ${CELL_tech_scf_runtime_dict}  lte
    ${LNCEL_distName_list}=  Get Dictionary Keys  ${LNCEL_scf_runtime_dict}
    ${LNCEL_distName_NRCELL_nrCellId_dict}=  Get and check BTS DSS feature info for LTE cells  ${BTS_scf}  ${LNCEL_distName_list}  ${alias}

    [Return]  ${NRCELL_distName_LNCEL_phyCellId_dict}  ${LNCEL_distName_NRCELL_nrCellId_dict}

Get and check BTS DSS feature info for NR cells
    [Arguments]  ${BTS_scf}  ${NRCELL_distName_list}  ${alias}

    ${NRCELL_distName_LNCEL_phyCellId_dict}=  Create Dictionary

    FOR  ${NRCELL_distName}  IN  @{NRCELL_distName_list}

        ${NRCELL_lteNrDssMode}=  Check NRCELL lteNrDssMode for NR cell  ${BTS_scf}  ${NRCELL_distName}
        Continue For Loop If  '${NRCELL_lteNrDssMode}' in ['NA', 'none']

        ${NRDSSLTE_ltePhyCellId}=  Check NRDSSLTE info for NR cell  ${BTS_scf}  ${NRCELL_distName}  ${alias}
        Continue For Loop If  '${NRDSSLTE_ltePhyCellId}' == 'NA'

        Set To Dictionary  ${NRCELL_distName_LNCEL_phyCellId_dict}  ${NRCELL_distName}  ${NRDSSLTE_ltePhyCellId}

    END

    [Return]  ${NRCELL_distName_LNCEL_phyCellId_dict}

Check NRCELL lteNrDssMode for NR cell
    [Arguments]  ${BTS_scf}  ${NRCELL_distName}

    ${NRCELL_lteNrDssMode}=  Set Variable  NA

    ${NRCELL_lteNrDssMode_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${NRCELL_distName}
    ...  p_name=lteNrDssMode
    ${NRCELL_lteNrDssMode_count}=  Get Length  ${NRCELL_lteNrDssMode_info_dict}
    ${NRCELL_lteNrDssMode}=  Run Keyword If  ${NRCELL_lteNrDssMode_count} > 0
    ...  Get From Dictionary  ${NRCELL_lteNrDssMode_info_dict}  lteNrDssMode
    ...  ELSE
    ...  Set Variable  NA

    [Return]  ${NRCELL_lteNrDssMode}

Check NRDSSLTE info for NR cell
    [Arguments]  ${BTS_scf}  ${NRCELL_distName}  ${alias}

    ${NRDSSLTE_ltePhyCellId}=  Set Variable  NA

    ${NRDSSLTE_distName_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRDSSLTE-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${NRDSSLTE_distName_count}=  Get Length  ${NRDSSLTE_distName_list}
    Return From Keyword If  ${NRDSSLTE_distName_count} == 0  ${NRDSSLTE_ltePhyCellId}

    FOR  ${NRDSSLTE_distName}  IN  @{NRDSSLTE_distName_list}

        ${SCF_cell_id}=  Fetch From Left  ${NRDSSLTE_distName}  /NRDSSLTE
        Continue For Loop If  '${SCF_cell_id}' != '${NRCELL_distName}'

        ${NRDSSLTE_ltePhyCellId_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${NRDSSLTE_distName}
        ...  p_name=ltePhyCellId
        ${NRDSSLTE_ltePhyCellId_count}=  Get Length  ${NRDSSLTE_ltePhyCellId_info_dict}
        ${NRDSSLTE_ltePhyCellId}=  Run Keyword If  ${NRDSSLTE_ltePhyCellId_count} > 0
        ...  Get From Dictionary  ${NRDSSLTE_ltePhyCellId_info_dict}  ltePhyCellId
        ...  ELSE
        ...  Set Variable  NA
        Continue For Loop If  '${NRDSSLTE_ltePhyCellId}' == 'NA'

        Exit For Loop

    END

    [Return]  ${NRDSSLTE_ltePhyCellId}

Get and check BTS DSS feature info for LTE cells
    [Arguments]  ${BTS_scf}  ${LNCEL_distName_list}  ${alias}

    ${LNCEL_distName_NRCELL_nrCellId_dict}=  Create Dictionary

    FOR  ${LNCEL_distName}  IN  @{LNCEL_distName_list}

        ${LNCEL_lteNrDssMode}=  Check LNCEL lteNrDssMode for LTE cell  ${BTS_scf}  ${LNCEL_distName}
        Continue For Loop If  '${LNCEL_lteNrDssMode}' in ['NA', 'none']

        ${DSSNR_dssNrCellId}=  Check DSSNR dssNrCellId for LTE cell  ${BTS_scf}  ${LNCEL_distName}  ${alias}
        Continue For Loop If  '${DSSNR_dssNrCellId}' == 'NA'

        ${LNRELGNBCELL_nrCellId}=  Check LNRELGNBCELL nrCellId for LTE cell  ${BTS_scf}  ${LNCEL_distName}  ${DSSNR_dssNrCellId}  ${alias}
        Continue For Loop If  '${LNRELGNBCELL_nrCellId}' == 'NA'

        Set To Dictionary  ${LNCEL_distName_NRCELL_nrCellId_dict}  ${LNCEL_distName}  ${LNRELGNBCELL_nrCellId}

    END

    [Return]  ${LNCEL_distName_NRCELL_nrCellId_dict}

Check LNCEL lteNrDssMode for LTE cell
    [Arguments]  ${BTS_scf}  ${LNCEL_distName}

    ${LNCEL_lteNrDssMode}=  Set Variable  NA

    ${LNCEL_lteNrDssMode_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${LNCEL_distName}
    ...  p_name=lteNrDssMode
    ${LNCEL_lteNrDssMode_count}=  Get Length  ${LNCEL_lteNrDssMode_info_dict}
    ${LNCEL_lteNrDssMode}=  Run Keyword If  ${LNCEL_lteNrDssMode_count} > 0
    ...  Get From Dictionary  ${LNCEL_lteNrDssMode_info_dict}  lteNrDssMode
    ...  ELSE
    ...  Set Variable  NA

    [Return]  ${LNCEL_lteNrDssMode}

Check DSSNR dssNrCellId for LTE cell
    [Arguments]  ${BTS_scf}  ${LNCEL_distName}  ${alias}

    ${DSSNR_dssNrCellId}=  Set Variable  NA

    ${DSSNR_distName_list}=  Get All Dist Names By Pattern from SCF  pattern=/DSSNR-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${DSSNR_distName_count}=  Get Length  ${DSSNR_distName_list}
    Return From Keyword If  ${DSSNR_distName_count} == 0  ${DSSNR_dssNrCellId}

    FOR  ${DSSNR_distName}  IN  @{DSSNR_distName_list}

        ${SCF_cell_id}=  Fetch From Left  ${DSSNR_distName}  /DSSNR
        Continue For Loop If  '${SCF_cell_id}' != '${LNCEL_distName}'

        ${DSSNR_dssNrCellId_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${DSSNR_distName}
        ...  p_name=dssNrCellId
        ${DSSNR_dssNrCellId_count}=  Get Length  ${DSSNR_dssNrCellId_info_dict}
        ${DSSNR_dssNrCellId}=  Run Keyword If  ${DSSNR_dssNrCellId_count} > 0
        ...  Get From Dictionary  ${DSSNR_dssNrCellId_info_dict}  dssNrCellId
        ...  ELSE
        ...  Set Variable  NA
        Continue For Loop If  '${DSSNR_dssNrCellId}' == 'NA'

        Exit For Loop

    END

    [Return]  ${DSSNR_dssNrCellId}

Check LNRELGNBCELL nrCellId for LTE cell
    [Arguments]  ${BTS_scf}  ${LNCEL_distName}  ${DSSNR_dssNrCellId}  ${alias}

    ${LNRELGNBCELL_nrCellId}=  Set Variable  NA

    ${LNRELGNBCELL_distName_list}=  Get All Dist Names By Pattern from SCF  pattern=/LNRELGNBCELL-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${LNRELGNBCELL_distName_count}=  Get Length  ${LNRELGNBCELL_distName_list}
    Return From Keyword If  ${LNRELGNBCELL_distName_count} == 0  ${LNRELGNBCELL_nrCellId}

    FOR  ${LNRELGNBCELL_distName}  IN  @{LNRELGNBCELL_distName_list}

        Continue For Loop If  '${LNRELGNBCELL_distName}' != '${LNCEL_distName}/LNRELGNBCELL-${DSSNR_dssNrCellId}'

        ${LNRELGNBCELL_nrCellId_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${LNRELGNBCELL_distName}
        ...  p_name=nrCellId
        ${LNRELGNBCELL_nrCellId_count}=  Get Length  ${LNRELGNBCELL_nrCellId_info_dict}
        ${LNRELGNBCELL_nrCellId}=  Run Keyword If  ${LNRELGNBCELL_nrCellId_count} > 0
        ...  Get From Dictionary  ${LNRELGNBCELL_nrCellId_info_dict}  nrCellId
        ...  ELSE
        ...  Set Variable  NA
        Continue For Loop If  '${LNRELGNBCELL_nrCellId}' == 'NA'

        Exit For Loop

    END

    [Return]  ${LNRELGNBCELL_nrCellId}

Get NR distName nrCellId info dict
    [Arguments]  ${BTS_scf}  ${DSS_NRCELL_distName_list}

    ${NRCELL_distName_nrCellId_dict}=  Create Dictionary
    ${NRCELL_nrCellId_distName_dict}=  Create Dictionary

    FOR  ${NRCELL_distName}  IN  @{DSS_NRCELL_distName_list}

        ${NRCELL_nrCellIdentity_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${NRCELL_distName}
        ...  p_name=nrCellIdentity
        ${NRCELL_nrCellIdentity_count}=  Get Length  ${NRCELL_nrCellIdentity_info_dict}
        ${NRCELL_nrCellIdentity}=  Run Keyword If  ${NRCELL_nrCellIdentity_count} > 0
        ...  Get From Dictionary  ${NRCELL_nrCellIdentity_info_dict}  nrCellIdentity
        ...  ELSE
        ...  Set Variable  NA
        Continue For Loop If  '${NRCELL_nrCellIdentity}' == 'NA'

        Set To Dictionary  ${NRCELL_distName_nrCellId_dict}  ${NRCELL_distName}  ${NRCELL_nrCellIdentity}
        Set To Dictionary  ${NRCELL_nrCellId_distName_dict}  ${NRCELL_nrCellIdentity}  ${NRCELL_distName}

    END

    [Return]  ${NRCELL_distName_nrCellId_dict}  ${NRCELL_nrCellId_distName_dict}

Get LTE distName phyCellId info dict
    [Arguments]  ${BTS_scf}  ${DSS_LNCEL_distName_list}

    ${LNCEL_distName_phyCellId_dict}=  Create Dictionary
    ${LNCEL_phyCellId_distName_dict}=  Create Dictionary

    FOR  ${LNCEL_distName}  IN  @{DSS_LNCEL_distName_list}

        ${LNCEL_phyCellId_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${LNCEL_distName}
        ...  p_name=phyCellId
        ${LNCEL_phyCellId_count}=  Get Length  ${LNCEL_phyCellId_info_dict}
        ${LNCEL_phyCellId}=  Run Keyword If  ${LNCEL_phyCellId_count} > 0
        ...  Get From Dictionary  ${LNCEL_phyCellId_info_dict}  phyCellId
        ...  ELSE
        ...  Set Variable  NA
        Continue For Loop If  '${LNCEL_phyCellId}' == 'NA'

        Set To Dictionary  ${LNCEL_distName_phyCellId_dict}  ${LNCEL_distName}  ${LNCEL_phyCellId}
        Set To Dictionary  ${LNCEL_phyCellId_distName_dict}  ${LNCEL_phyCellId}  ${LNCEL_distName}

    END

    [Return]  ${LNCEL_distName_phyCellId_dict}  ${LNCEL_phyCellId_distName_dict}

Get and check NR LTE DSS association
    [Arguments]  ${NRCELL_distName_LNCEL_phyCellId_dict}  ${LNCEL_distName_NRCELL_nrCellId_dict}  ${NRCELL_nrCellId_distName_dict}
    ...  ${LNCEL_phyCellId_distName_dict}

    ${NR_LTE_CELL_DSS_scf_dict}=  Create Dictionary
    ${LTE_NR_CELL_DSS_scf_dict}=  Create Dictionary

    ${NRCELL_distName_list}=  Get Dictionary Keys  ${NRCELL_distName_LNCEL_phyCellId_dict}
    ${LNCEL_distName_list}=  Get Dictionary Keys  ${LNCEL_distName_NRCELL_nrCellId_dict}

    FOR  ${NRCELL_distName}  IN  @{NRCELL_distName_list}

        ${LNCEL_phyCellId}=  Get From Dictionary  ${NRCELL_distName_LNCEL_phyCellId_dict}  ${NRCELL_distName}
        ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${LNCEL_phyCellId_distName_dict}  ${LNCEL_phyCellId}
        Continue For Loop If  '${status}' == 'False'

        ${LNCEL_distName}=  Get From Dictionary  ${LNCEL_phyCellId_distName_dict}  ${LNCEL_phyCellId}

        Set To Dictionary  ${NR_LTE_CELL_DSS_scf_dict}  ${NRCELL_distName}  ${LNCEL_distName}

    END

    FOR  ${LNCEL_distName}  IN  @{LNCEL_distName_list}

        ${NRCELL_nrCellId}=  Get From Dictionary  ${LNCEL_distName_NRCELL_nrCellId_dict}  ${LNCEL_distName}
        ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${NRCELL_nrCellId_distName_dict}  ${NRCELL_nrCellId}
        Continue For Loop If  '${status}' == 'False'

        ${NRCELL_distName}=  Get From Dictionary  ${NRCELL_nrCellId_distName_dict}  ${NRCELL_nrCellId}

        Set To Dictionary  ${LTE_NR_CELL_DSS_scf_dict}  ${LNCEL_distName}  ${NRCELL_distName}

    END

    [Return]  ${NR_LTE_CELL_DSS_scf_dict}  ${LTE_NR_CELL_DSS_scf_dict}

Get all BTS DSS feature runtime info for NR and LTE cells
    [Arguments]  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_XP_localAlias_remoteAlias_dict}
    ...  ${BTS_alias_CELL_tech_scf_runtime_dict}

    ${BTS_DSS_NR_LTE_CELL_runtime_dict}=  Create Dictionary
    ${BTS_DSS_LTE_NR_CELL_runtime_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_DSS_peer_alias_list}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
        ${BTS_DSS_peer_alias_count}=  Get Length  ${BTS_DSS_peer_alias_list}
        Continue For Loop If  ${BTS_DSS_peer_alias_count} == 0

        ${NR_LTE_CELL_DSS_scf_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${alias}
        ${LTE_NR_CELL_DSS_scf_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${alias}

        ${BTS_CELL_tech_scf_runtime_dict}=  Get From Dictionary  ${BTS_alias_CELL_tech_scf_runtime_dict}  ${alias}
        ${BTS_peer_CELL_tech_scf_runtime_dict}=  Get peer BTS CELL runtime and scf info dict  ${BTS_alias_CELL_tech_scf_runtime_dict}
        ...  ${BTS_DSS_peer_alias_list}

        ${BTS_NRCELL_scf_runtime_dict}=  Get From Dictionary  ${BTS_CELL_tech_scf_runtime_dict}  nr
        ${BTS_LNCEL_scf_runtime_dict}=  Get From Dictionary  ${BTS_CELL_tech_scf_runtime_dict}  lte
        ${BTS_peer_NRCELL_scf_runtime_dict}=  Get From Dictionary  ${BTS_peer_CELL_tech_scf_runtime_dict}  nr
        ${BTS_peer_LNCEL_scf_runtime_dict}=  Get From Dictionary  ${BTS_peer_CELL_tech_scf_runtime_dict}  lte

        ${NR_LTE_CELL_DSS_runtime_dict}  ${LTE_NR_CELL_DSS_runtime_dict}=  Get BTS DSS feature runtime info for NR and LTE cells
        ...  ${NR_LTE_CELL_DSS_scf_dict}  ${LTE_NR_CELL_DSS_scf_dict}  ${BTS_NRCELL_scf_runtime_dict}  ${BTS_LNCEL_scf_runtime_dict}
        ...  ${BTS_peer_NRCELL_scf_runtime_dict}  ${BTS_peer_LNCEL_scf_runtime_dict}

        Set To Dictionary  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${alias}  ${NR_LTE_CELL_DSS_runtime_dict}
        Set To Dictionary  ${BTS_DSS_LTE_NR_CELL_runtime_dict}  ${alias}  ${LTE_NR_CELL_DSS_runtime_dict}

    END

    [Return]  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}

Get BTS DSS feature runtime info for NR and LTE cells
    [Arguments]  ${NR_LTE_CELL_DSS_scf_dict}  ${LTE_NR_CELL_DSS_scf_dict}  ${BTS_NRCELL_scf_runtime_dict}  ${BTS_LNCEL_scf_runtime_dict}
    ...  ${BTS_peer_NRCELL_scf_runtime_dict}  ${BTS_peer_LNCEL_scf_runtime_dict}

    ${NR_LTE_CELL_DSS_runtime_dict}=  Create Dictionary
    ${LTE_NR_CELL_DSS_runtime_dict}=  Create Dictionary

    ${NRCELL_distName_scf_list}=  Get Dictionary Keys  ${NR_LTE_CELL_DSS_scf_dict}

    FOR  ${NRCELL_distName}  IN  @{NRCELL_distName_scf_list}

        ${LNCEL_distName_scf}=  Get From Dictionary  ${NR_LTE_CELL_DSS_scf_dict}  ${NRCELL_distName}
        ${NRCELL_distName_runtime}=  Get From Dictionary  ${BTS_NRCELL_scf_runtime_dict}  ${NRCELL_distName}
        ${LNCEL_distName_runtime}=  Get From Dictionary  ${BTS_peer_LNCEL_scf_runtime_dict}  ${LNCEL_distName_scf}

        Set To Dictionary  ${NR_LTE_CELL_DSS_runtime_dict}  ${NRCELL_distName_runtime}  ${LNCEL_distName_runtime}

    END

    ${LNCEL_distName_scf_list}=  Get Dictionary Keys  ${LTE_NR_CELL_DSS_scf_dict}

    FOR  ${LNCEL_distName}  IN  @{LNCEL_distName_scf_list}

        ${NRCELL_distName_scf}=  Get From Dictionary  ${LTE_NR_CELL_DSS_scf_dict}  ${LNCEL_distName}
        ${LNCEL_distName_runtime}=  Get From Dictionary  ${BTS_LNCEL_scf_runtime_dict}  ${LNCEL_distName}
        ${NRCELL_distName_runtime}=  Get From Dictionary  ${BTS_peer_NRCELL_scf_runtime_dict}  ${NRCELL_distName_scf}

        Set To Dictionary  ${LTE_NR_CELL_DSS_runtime_dict}  ${LNCEL_distName_runtime}  ${NRCELL_distName_runtime}

    END

    [Return]  ${NR_LTE_CELL_DSS_runtime_dict}  ${LTE_NR_CELL_DSS_runtime_dict}

Get peer BTS CELL runtime and scf info dict
    [Arguments]  ${BTS_alias_CELL_tech_scf_runtime_dict}  ${BTS_peer_alias_list}

    ${BTS_peer_CELL_tech_scf_runtime_dict}=  Create Dictionary
    ${BTS_peer_NRCELL_scf_runtime_dict}=  Create Dictionary
    ${BTS_peer_LNCEL_scf_runtime_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{BTS_peer_alias_list}

        ${CELL_tech_scf_runtime_dict}=  Get From Dictionary  ${BTS_alias_CELL_tech_scf_runtime_dict}  ${alias}
        ${NRCELL_scf_runtime_dict}=  Get From Dictionary  ${CELL_tech_scf_runtime_dict}  nr
        ${LNCEL_scf_runtime_dict}=  Get From Dictionary  ${CELL_tech_scf_runtime_dict}  lte
        ${BTS_peer_NRCELL_scf_runtime_dict}=  Append Dictionary To Target Dictionary  ${BTS_peer_NRCELL_scf_runtime_dict}
        ...  ${NRCELL_scf_runtime_dict}
        ${BTS_peer_LNCEL_scf_runtime_dict}=  Append Dictionary To Target Dictionary  ${BTS_peer_LNCEL_scf_runtime_dict}
        ...  ${LNCEL_scf_runtime_dict}

    END

    Set To Dictionary  ${BTS_peer_CELL_tech_scf_runtime_dict}  nr=${BTS_peer_NRCELL_scf_runtime_dict}  lte=${BTS_peer_LNCEL_scf_runtime_dict}

    [Return]  ${BTS_peer_CELL_tech_scf_runtime_dict}

Get BTS CELL runtime and scf info dict
    [Arguments]  ${alias}

    ${CELL_tech_runtime_scf_dict}=  Create Dictionary
    ${CELL_tech_scf_runtime_dict}=  Create Dictionary

    ${CELL_info}=  Get Cell List  connection=${alias}

    FOR  ${item}  IN  @{CELL_info['cells']}

        ${CELL_runtime_scf_dict}  ${CELL_scf_runtime_dict}=  Get CELL runtime and scf info dict  ${CELL_info}  ${item}
        Set To Dictionary  ${CELL_tech_runtime_scf_dict}  ${item}  ${CELL_runtime_scf_dict}
        Set To Dictionary  ${CELL_tech_scf_runtime_dict}  ${item}  ${CELL_scf_runtime_dict}

    END

    [Return]  ${CELL_tech_runtime_scf_dict}  ${CELL_tech_scf_runtime_dict}

Get CELL runtime and scf info dict
    [Arguments]  ${CELL_info}  ${CELL_tech}

    ${CELL_tech}=  Set Variable  ${CELL_tech}
    ${CELL_runtime_scf_dict}=  Create Dictionary
    ${CELL_scf_runtime_dict}=  Create Dictionary

    FOR  ${item}  IN  @{CELL_info['cells']['${CELL_tech}']}

        Set To Dictionary  ${CELL_runtime_scf_dict}  ${item['id']['internal']}  ${item['id']['configuration']}
        Set To Dictionary  ${CELL_scf_runtime_dict}  ${item['id']['configuration']}  ${item['id']['internal']}

    END

    [Return]  ${CELL_runtime_scf_dict}  ${CELL_scf_runtime_dict}

Get feature CB007437 info
    [Documentation]
    ...  Get feature CB007437 info
    ...
    ...  *AUTHOR*
    ...  ana.tugui@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | actCpriLinkRecovery       | parameter value: true or false              |
    ...  | stickToSyncSourcePeriod   | parameter value: <time value> in ms or none |
    ...  | actSyncLinkSwitchover     | parameter value: true or false              |

    [Arguments]  ${alias}

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0


	${actCpriLinkRecovery}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}
	...  parameter_to_check=actCpriLinkRecovery  scf_path=${scf_path}

	${actSyncLinkSwitchover}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}
	...  parameter_to_check=actSyncLinkSwitchover  scf_path=${scf_path}

	${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/MNLENT-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0

	${stickToSyncSourcePeriod}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}
    ...  parameter_to_check=stickToSyncSourcePeriod  scf_path=${scf_path}

    ${actCpriLinkRecovery}=  Convert to String  ${actCpriLinkRecovery}
    ${actCpriLinkRecovery}=  Convert To Lower Case  ${actCpriLinkRecovery}

    ${stickToSyncSourcePeriod}=  Convert To String  ${stickToSyncSourcePeriod}
    ${stickToSyncSourcePeriod}=  Convert To Lower Case  ${stickToSyncSourcePeriod}

    ${actSyncLinkSwitchover}=  Convert to String  ${actSyncLinkSwitchover}
    ${actSyncLinkSwitchover}=  Convert To Lower Case  ${actSyncLinkSwitchover}

    [Return]  ${actCpriLinkRecovery}  ${stickToSyncSourcePeriod}  ${actSyncLinkSwitchover}

Set feature CB007437 on BTS
    [Documentation]
    ...  Activate feature CB007437 on BTS
    ...
    ...  *AUTHOR*
    ...  ana.tugui@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                 | Man. | Description                                 |
    ...  | alias                     | Yes  | admin instance alias                        |
    ...  | actCpriLinkRecovery       | Yes  | parameter value: true or false              |
    ...  | stickToSyncSourcePeriod   | Yes  | parameter value: <time value> in ms or none |
    ...  | actSyncLinkSwitchover     | Yes  | parameter value: true or false              |

    [Arguments]  ${actCpriLinkRecovery_value}=true  ${stickToSyncSourcePeriod_value}=50  ${actSyncLinkSwitchover_value}=true
    ...  ${alias}=default
    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0
    ${dn_list_1}=  Get All Dist Names By Pattern from SCF  pattern=/MNLENT-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn_1}=  Get From List  ${dn_list_1}  0
    ${actCpriLinkRecovery}  ${stickToSyncSourcePeriod}  ${actSyncLinkSwitchover}=  Get feature CB007437 info  ${alias}


    ${condition}=  Create Long String  '${actCpriLinkRecovery_value}' == '${actCpriLinkRecovery}'
    ...  and '${stickToSyncSourcePeriod_value}' == '${stickToSyncSourcePeriod}'
    ...  and '${actSyncLinkSwitchover_value}' == '${actSyncLinkSwitchover}'

    Run Keyword If  ${condition}  Run Keywords
    ...  Log  Parameter actCpriLinkRecovery already set on BTS ${alias}: ${actCpriLinkRecovery}, commissioning not needed!  console=True
    ...  AND  Log  Parameter stickToSyncSourcePeriod already set on BTS ${alias}: ${stickToSyncSourcePeriod}, commissioning not needed!  console=True
    ...  AND  Log  Parameter actSyncLinkSwitchover already set on BTS ${alias}: ${actSyncLinkSwitchover}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    Run Keyword If  '${actCpriLinkRecovery}' == '${actCpriLinkRecovery_value}'
    ...  Log  Parameter actCpriLinkRecovery already set on BTS ${alias}: ${actCpriLinkRecovery}, commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=actCpriLinkRecovery  operation=update
    ...  value=${actCpriLinkRecovery_value}  skip_parameter_relation_errors=True  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

    ${operation}=  Set Variable If  '${stickToSyncSourcePeriod_value}' == 'none'  delete  update
    Run Keyword If  '${stickToSyncSourcePeriod}' == '${stickToSyncSourcePeriod_value}'
    ...  Log  Parameter stickToSyncSourcePeriod already set on BTS ${alias}: ${stickToSyncSourcePeriod}, commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn_1}  parameter=stickToSyncSourcePeriod  operation=${operation}
    ...  value=${stickToSyncSourcePeriod_value}  skip_parameter_relation_errors=True  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

    Run Keyword If  '${actSyncLinkSwitchover}' == '${actSyncLinkSwitchover_value}'
    ...  Log  Parameter actSyncLinkSwitchover already set on BTS ${alias}: ${actSyncLinkSwitchover}, commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=actSyncLinkSwitchover  operation=update
    ...  value=${actSyncLinkSwitchover_value}  skip_parameter_relation_errors=True  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

Get chained RMOD info dict
    [Documentation]
    ...  Keyword providing chained RM configuration connection info
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                        | Description                                                |
    ...  | BTS_chained_RMOD_ID_dict         | dict with RM id as key and list of chained RMs id as value |
    ...  | BTS_chained_RMOD_SN_dict         | dict with RM sn as key and list of chained RMs sn as value |

    [Arguments]  ${alias}

    ${RM_list}=  Get Ids For All  class_name=RMOD  connection=${alias}
    Set Test Variable  ${${alias}_module_list}  ${RM_list}
    Get RMOD ID SN dict  ${alias}

    ${BTS_chained_RMOD_ID_dict}=  Create Dictionary
    ${BTS_chained_RMOD_SN_dict}=  Create Dictionary
    FOR  ${RMOD_id}  IN  @{${alias}_module_list}
        ${RMOD_sn}=  Get From Dictionary  ${${alias}_module_ID_SN_dict}  ${RMOD_id}
        ${BTS_chained_RMOD_ID_list}  ${BTS_chained_RMOD_SN_list}=  Get chained RMOD info by RMOD id
        ...  ${RMOD_id}  ${${alias}_module_list}  ${${alias}_module_ID_SN_dict}  ${alias}
        Set To Dictionary  ${BTS_chained_RMOD_ID_dict}  ${RMOD_id}  ${BTS_chained_RMOD_ID_list}
        Set To Dictionary  ${BTS_chained_RMOD_SN_dict}  ${RMOD_sn}  ${BTS_chained_RMOD_SN_list}
    END

    [Return]  ${BTS_chained_RMOD_ID_dict}  ${BTS_chained_RMOD_SN_dict}

Get chained RMOD info by RMOD id
    [Arguments]  ${RMOD_id}  ${RMOD_list}  ${RMOD_ID_SN_dict}  ${alias}

    ${chained_rmod_id_list}=  Create List
    ${chained_rmod_sn_list}=  Create List
    FOR  ${i}  IN RANGE  999
        ${rmod_chained}=  Get RMOD connection  ${RMOD_id}  ${RMOD_list}  ${alias}
        ${rmod_chained_SN}=  Run Keyword If  '${rmod_chained}' != 'None'  Get From Dictionary  ${RMOD_ID_SN_dict}  ${rmod_chained}
        Run Keyword If  '${rmod_chained}' != 'None'  Run Keywords
        ...  Append To List  ${chained_rmod_id_list}  ${rmod_chained}
        ...  AND  Append To List  ${chained_rmod_sn_list}  ${rmod_chained_SN}
        ...  ELSE  Exit For Loop
        ${RMOD_id}=  Set Variable  ${rmod_chained}
    END
    [Return]  ${chained_rmod_id_list}  ${chained_rmod_sn_list}

Get RMOD connection
    [Arguments]  ${RMOD_id}  ${RMOD_list}  ${alias}
    ${rmod_chained}=  Set Variable  None

    FOR  ${item}  IN  @{RMOD_list}
        ${rmod_check}=  Check connections from CABLINK info  ${RMOD_id}  ${item}  ${alias}
        Return From Keyword If  ${rmod_check}  ${item}
    END

    [Return]  ${rmod_chained}

Get BBMOD CELL mapping based on BBPOOL info from SCF
    [Documentation]
    ...  Keyword providing BBMOD CELL mapping based on BBPOOL info from SCF
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | Yes  |         | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter               | Description                                                                      |
    ...  | BBMOD_CELL_runtime_dict | dict with runtime BBMOD id as key and list of mapped CELLs id as value           |
    ...  | BBMOD_CELL_scf_dict     | dict with scf BBMOD dist name as key and list of mapped CELLs dist name as value |
    ...
    [Arguments]  ${alias}

    ${BBMOD_CELL_runtime_dict}=  Create Dictionary
    ${BBMOD_CELL_scf_dict}=  Create Dictionary

    ${BBMOD_id_list}=  Get Ids For All  class_name=BBMOD  connection=${alias}
    Sort List  ${BBMOD_id_list}
    ${BBMOD_id_count}=  Get Length  ${BBMOD_id_list}

    Run Keyword If  ${BBMOD_id_count} == 0
    ...  Return From Keyword  ${BBMOD_CELL_runtime_dict}  ${BBMOD_CELL_scf_dict}

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects

    scf.Load Scf   file_path=${BTS_scf}

    ${BBPOOL_dn_list}=  Get All Dist Names By Pattern  pattern=/BBPOOL-[\\d]+$
    Sort List  ${BBPOOL_dn_list}

    ${BBMOD_id_dn_dict}  ${BBMOD_dn_id_dict}  ${BBMOD_id_rdn_dict}  ${BBMOD_rdn_id_dict}=  Get BBMOD id runtime distinguished name info dict
    ...  ${BBMOD_id_list}  ${alias}

    ${BTS_CELL_tech_runtime_scf_dict}  ${BTS_CELL_tech_scf_runtime_dict}=  Get BTS CELL runtime and scf info dict  ${alias}

    ${BBPOOL_dn_bbPoolCellsList_dict}  ${BBPOOL_dn_bbPwrGroupDNList_dict}  ${BBPOOL_dn_bbPoolTech_dict}
    ...  ${BBPOOL_dn_operationalState_dict}=  Get BBPOOL info dict from SCF  ${BTS_scf}

    FOR  ${item}  IN  @{BBMOD_id_list}

        ${BBMOD_dn}=  Get From Dictionary  ${BBMOD_id_dn_dict}  ${item}
        ${BBMOD_rdn}=  Get From Dictionary  ${BBMOD_id_rdn_dict}  ${item}

        ${BBMOD_CELL_id_list}  ${BBMOD_CELL_dn_list}=  Get BBMOD CELL distName mapping list  ${BTS_scf}  ${BBMOD_rdn}  ${BBPOOL_dn_list}
        ...  ${BBPOOL_dn_bbPoolCellsList_dict}  ${BBPOOL_dn_bbPwrGroupDNList_dict}  ${BBPOOL_dn_bbPoolTech_dict}  ${BTS_CELL_tech_scf_runtime_dict}
        ${BBMOD_CELL_id_list}=  Remove Duplicates  ${BBMOD_CELL_id_list}
        ${BBMOD_CELL_dn_list}=  Remove Duplicates  ${BBMOD_CELL_dn_list}

        Set To Dictionary  ${BBMOD_CELL_runtime_dict}  ${item}  ${BBMOD_CELL_id_list}
        Set To Dictionary  ${BBMOD_CELL_scf_dict}  ${BBMOD_dn}  ${BBMOD_CELL_dn_list}

    END

    [Return]  ${BBMOD_CELL_runtime_dict}  ${BBMOD_CELL_scf_dict}

Get BBPOOL info dict from SCF
    [Arguments]  ${BTS_scf}

    scf.Load Scf   file_path=${BTS_scf}

    ${BBPOOL_dn_list}=  Get All Dist Names By Pattern  pattern=/BBPOOL-[\\d]+$
    Sort List  ${BBPOOL_dn_list}

    ${BBPOOL_dn_bbPoolCellsList_dict}=  Create Dictionary
    ${BBPOOL_dn_bbPwrGroupDNList_dict}=  Create Dictionary
    ${BBPOOL_dn_bbPoolTech_dict}=  Create Dictionary
    ${BBPOOL_dn_operationalState_dict}=  Create Dictionary

    FOR  ${item}  IN  @{BBPOOL_dn_list}

        ${bbPoolCellsList_info}=  Get All Values From Scf  dist_name=${item}  list_name=bbPoolCellsList
        Set To Dictionary  ${BBPOOL_dn_bbPoolCellsList_dict}  ${item}  ${bbPoolCellsList_info}

        ${bbPwrGroupDNList_info}=  Get All Values From Scf  dist_name=${item}  list_name=bbPwrGroupDNList
        Set To Dictionary  ${BBPOOL_dn_bbPwrGroupDNList_dict}  ${item}  ${bbPwrGroupDNList_info}

        ${bbPoolTech_info}=  Get Value From Scf  dist_name=${item}  p_name=bbPoolTech
        Set To Dictionary  ${BBPOOL_dn_bbPoolTech_dict}  ${item}  ${bbPoolTech_info}

        ${operationalState_info}=  Get Value From Scf  dist_name=${item}  p_name=operationalState
        Set To Dictionary  ${BBPOOL_dn_operationalState_dict}  ${item}  ${operationalState_info}

    END

    [Return]  ${BBPOOL_dn_bbPoolCellsList_dict}  ${BBPOOL_dn_bbPwrGroupDNList_dict}  ${BBPOOL_dn_bbPoolTech_dict}  ${BBPOOL_dn_operationalState_dict}

Get BBMOD id runtime distinguished name info dict
    [Arguments]  ${BBMOD_id_list}  ${alias}

    ${BBMOD_id_dn_dict}=  Create Dictionary
    ${BBMOD_dn_id_dict}=  Create Dictionary
    ${BBMOD_id_rdn_dict}=  Create Dictionary
    ${BBMOD_rdn_id_dict}=  Create Dictionary

    FOR  ${item}  IN  @{BBMOD_id_list}

        ${BBMOD_dn}=  Get BBMOD SCF distinguished name  ${item}  ${alias}
        Set To Dictionary  ${BBMOD_id_dn_dict}  ${item}  ${BBMOD_dn}
        Set To Dictionary  ${BBMOD_dn_id_dict}  ${BBMOD_dn}  ${item}

        ${BBMOD_rdn}=  Get BBMOD SCF runtime distinguished name  ${item}  ${alias}
        Set To Dictionary  ${BBMOD_id_rdn_dict}  ${item}  ${BBMOD_rdn}
        Set To Dictionary  ${BBMOD_rdn_id_dict}  ${BBMOD_rdn}  ${item}

    END

    [Return]  ${BBMOD_id_dn_dict}  ${BBMOD_dn_id_dict}  ${BBMOD_id_rdn_dict}  ${BBMOD_rdn_id_dict}

Get BBMOD CELL distName mapping list
    [Arguments]  ${BTS_scf}  ${BBMOD_rdn}  ${BBPOOL_dn_list}  ${BBPOOL_dn_bbPoolCellsList_dict}  ${BBPOOL_dn_bbPwrGroupDNList_dict}
    ...  ${BBPOOL_dn_bbPoolTech_dict}  ${BTS_CELL_tech_scf_runtime_dict}

    ${BBMOD_CELL_dn_list}=  Create List

    FOR  ${item}  IN  @{BBPOOL_dn_list}

        ${bbPoolCellsList}=  Get From Dictionary  ${BBPOOL_dn_bbPoolCellsList_dict}  ${item}
        ${bbPwrGroupDNList}=  Get From Dictionary  ${BBPOOL_dn_bbPwrGroupDNList_dict}  ${item}
        ${bbPoolTech}=  Get From Dictionary  ${BBPOOL_dn_bbPoolTech_dict}  ${item}

        ${BBMOD_rdn_list}=  Get BBMOD runtime distName info from bbPwrGroupDNList  ${bbPwrGroupDNList}

        Continue For Loop If  '${BBMOD_rdn}' not in ${BBMOD_rdn_list}

        ${CELL_dn_list}=  Get CELL distName info from bbPoolCellsList  ${BTS_scf}  ${bbPoolCellsList}  ${bbPoolTech}
        Append To List  ${BBMOD_CELL_dn_list}  @{CELL_dn_list}

    END

    ${BBMOD_CELL_id_list}=  Get CELL id info from dn info  ${BBMOD_CELL_dn_list}  ${BTS_CELL_tech_scf_runtime_dict}

    [Return]  ${BBMOD_CELL_id_list}  ${BBMOD_CELL_dn_list}

Get BBMOD runtime distName info from bbPwrGroupDNList
    [Arguments]  ${bbPwrGroupDNList}

    ${BBMOD_rdn_list}=  Create List

    FOR  ${item}  IN  @{bbPwrGroupDNList}

        ${BBMOD_rdn}=  Fetch From Left  ${item}  /POWERGROUP_R
        Append To List  ${BBMOD_rdn_list}  ${BBMOD_rdn}

    END

    ${BBMOD_rdn_list}=  Remove Duplicates  ${BBMOD_rdn_list}

    [Return]  ${BBMOD_rdn_list}

Get CELL distName info from bbPoolCellsList
    [Arguments]  ${BTS_scf}  ${bbPoolCellsList}  ${bbPoolTech}

    ${CELL_dn_list}=  Create List

    ${CELL_class}=  Set Variable If  '${bbPoolTech}' == '5G'  NRCELL  '${bbPoolTech}' == 'LTE'  LNCEL  '${bbPoolTech}' == 'WCDMA'  WNCEL
    ...  '${bbPoolTech}' == 'GSM'  GNCEL

    ${CELL_dn_lcrId_dict}  ${CELL_lcrId_dn_dict}=  Get CELL distName lcrId info dict  ${BTS_scf}  ${CELL_class}

    FOR  ${item}  IN  @{CELL_lcrId_dn_dict}

        Continue For Loop If  '${item}' not in ${bbPoolCellsList}

        ${CELL_dn}=  Get From Dictionary  ${CELL_lcrId_dn_dict}  ${item}
        Append To List  ${CELL_dn_list}  ${CELL_dn}

    END

    Sort List  ${CELL_dn_list}

    [Return]  ${CELL_dn_list}

Get CELL distName lcrId info dict
    [Arguments]  ${BTS_scf}  ${CELL_class}

    scf.Load Scf   file_path=${BTS_scf}

    ${CELL_dn_list}=  Get All Dist Names By Pattern  pattern=/${CELL_class}-[\\d]+$
    Sort List  ${CELL_dn_list}

    ${CELL_dn_lcrId_dict}=  Create Dictionary
    ${CELL_lcrId_dn_dict}=  Create Dictionary

    ${lcrId_param}=  Set Variable If  '${CELL_class}' in ['NRCELL', 'LNCEL']  lcrId  '${CELL_class}' == 'WNCEL'  lCelwDN
    ...  '${CELL_class}' == 'GNCEL'  lcelcId

    FOR  ${item}  IN  @{CELL_dn_list}

        ${lcrId_info}=  Get Value From Scf  dist_name=${item}  p_name=${lcrId_param}

        ${lcrId}=  Run Keyword If  '${CELL_class}' == 'WNCEL'
        ...  Fetch from right  ${lcrId_info}  -
        ...  ELSE
        ...  Set Variable  ${lcrId_info}

        Set To Dictionary  ${CELL_dn_lcrId_dict}  ${item}  ${lcrId}
        Set To Dictionary  ${CELL_lcrId_dn_dict}  ${lcrId}  ${item}

    END

    [Return]  ${CELL_dn_lcrId_dict}  ${CELL_lcrId_dn_dict}

Get CELL id info from dn info
    [Arguments]  ${CELL_dn_list}  ${BTS_CELL_tech_scf_runtime_dict}

    ${CELL_id_list}=  Create List

    FOR  ${item}  IN  @{CELL_dn_list}

        ${CELL_id}=  Get CELL id info from dn info for specific tech  ${item}  ${BTS_CELL_tech_scf_runtime_dict}

        Append To List  ${CELL_id_list}  ${CELL_id}

    END

    [Return]  ${CELL_id_list}

Get CELL id info from dn info for specific tech
    [Arguments]  ${CELL_dn}  ${BTS_CELL_tech_scf_runtime_dict}

    ${tech_list}=  Create List  nr  lte  wcdma  gsm

     FOR  ${item}  IN  @{tech_list}

         ${CELL_scf_runtime_dict}=  Get From Dictionary  ${BTS_CELL_tech_scf_runtime_dict}  ${item}
         ${CELL_scf_list}=  Get Dictionary Keys  ${CELL_scf_runtime_dict}

         Continue For Loop If  '${CELL_dn}' not in ${CELL_scf_list}

         ${CELL_id}=  Get From Dictionary  ${CELL_scf_runtime_dict}  ${CELL_dn}

         Exit For Loop

    END

    [Return]  ${CELL_id}

Get PL info for RMODs connected to FHS
    [Documentation]
    ...  Keyword providing RMOD list with primary link connected to a specific FHS
    ...
    ...  *AUTHOR* andreea.szentannai@nokia.com
    ...
    ...  | Parameter         | Man. | Default | Description                      |
    ...  | FHS_id            | Yes  |         | FHS id runtime view              |
    ...  | alias             | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                          | Description                                            |
    ...  | FHS_PL_RMOD_list                   | List of RMODs with primary link connected to FHS_id    |
    [Arguments]  ${FHS_id}  ${alias}

    ${FHS_PL_RMOD_list}=  Create List

    ${RMOD_list}=  Get RMOD Mapping on specific FHS  ${FHS_id}  ${alias}

    FOR  ${item}  IN  @{RMOD_list}
        ${connection_info_dict}=  Get port connection info  ${FHS_id}  ${item}  ${alias}
        ${synchronization_value}=  Get Dictionary Values  ${connection_info_dict}
        Run Keyword If  'True' in '${synchronization_value}'
        ...  Append To List  ${FHS_PL_RMOD_list}  ${item}
    END

    [Return]  ${FHS_PL_RMOD_list}

Get CABLINK SCF distinguished name
    [Documentation]
    ...  KW used to get CABLINK SCF distinguished name

    [Arguments]  ${CABLINK_id}  ${alias}
    ${BTS_info}=  Get Bts Info  connection=${alias}
    FOR  ${item}  IN  @{BTS_info['cables']}
        Exit For Loop If  '${item['id']['internal']}' == '${CABLINK_id}'
    END

    ${var_status}=  Run Keyword And Return Status  Variable Should Exist  ${item['id']['configuration']}
    Return From Keyword If  not ${var_status}  None

    [Return]  ${item['id']['configuration']}

Get swFallbackTimer parameter value
    [Documentation]
    ...  Get swFallbackTimer parameter value.
    ...
    ...  *AUTHOR*
    ...  anca.tatar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description             |
    ...  | alias     | Yes  | alias of admin instance |
    ...
    ...  *RETURN VALUE*
    ...  | Parameter       | Description     |
    ...  | swFallbackTimer | swFallbackTimer |

    [Arguments]  ${alias}

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects
    ${swFallbackTimer_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${swFallbackTimer_dn}=  Get From List  ${swFallbackTimer_dn_list}  0
    ${swFallbackTimer}=  Check Parameter value from SCF  item_dist_name=${swFallbackTimer_dn}  parameter_to_check=swFallbackTimer
    ...  scf_path=${BTS_scf}

    [Return]  ${swFallbackTimer}

Set swFallbackTimer parameter value
    [Documentation]
    ...  Set swFallbackTimer parameter value
    ...
    ...  *AUTHOR*
    ...  anca.tatar@nokia.com
    ...
    ...  | Parameter           | Man. | Description                                                           |
    ...  | parameter_value     | Yes  | Timer in minutes. Possible values: 30, 60 or 90                       |
    ...  | parameter_operation | Yes  | Parameter recomissioning operation. Possible values: update or delete |
    ...  | alias               | Yes  | alias of admin instance                                               |

    [Arguments]  ${parameter_value}  ${parameter_operation}  ${alias}

    ${swFallbackTimer_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  alias=${alias}
    ${swFallbackTimer_dn}=  Get From List  ${swFallbackTimer_dn_list}  0
    coam.Perform Parameter Recommissioning  dist_name=${swFallbackTimer_dn}  parameter=swFallbackTimer  operation=${parameter_operation}
    ...  value=${parameter_value}  skip_parameter_relation_errors=True  should_activate=True  connection=${alias}
    Sleep  3s
    ${swFallbackTimer_value}=  Get swFallbackTimer parameter value  ${alias}
    Run Keyword If  '${parameter_operation}' == 'update' and '${swFallbackTimer_value}' == '${parameter_value}'
    ...  Log  Parameter swFallbackTimer = ${swFallbackTimer_value}, properly updated!  console=True
    ...  ELSE IF  '${parameter_operation}' == 'delete' and '${swFallbackTimer_value}' == 'None'
    ...  Log  Parameter swFallbackTimer successfully deleted from SCF, as this was the initial configuration!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter swFallbackTimer = ${swFallbackTimer_value}, not properly updated!  level=ERROR
    ...  AND  Fail  Parameter swFallbackTimer = ${swFallbackTimer_value}, not properly updated!

Get RAT reset impact on FRONTHAUL modules and cells
    [Documentation]
    ...  Keyword providing RAT reset impact on FRONTHAUL modules (FHS/RMOD) with synchronization provided by CABINET modules (SMOD/BBMOD) processing
    ...  that RAT. Also impacted cells info is available.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description                |
    ...  | RAT       | Yes  |         | RAT: NR, LTE, WCDMA or GSM |
    ...  | alias     | Yes  |         | alias of admin instance    |
    ...
    ...  *RETURN*
    ...  | Parameter               | Description                         |
    ...  | RAT_reset_FHS_id_list   | List of FHS impacted by reset RAT   |
    ...  | RAT_reset_RMOD_id_list  | List of RMOD impacted by reset RAT  |
    ...  | RAT_reset_NRCEL_id_list | List of NRCEL impacted by reset RAT |
    ...  | RAT_reset_LNCEL_id_list | List of LNCEL impacted by reset RAT |
    ...  | RAT_reset_WNCEL_id_list | List of WNCEL impacted by reset RAT |
    ...  | RAT_reset_GNCEL_id_list | List of GNCEL impacted by reset RAT |
    ...
    [Arguments]  ${RAT}  ${alias}

    ${RAT_SMOD_POWERGROUP_info_dict}=  Get RAT CABINET module POWERGROUP info dict  ${RAT}  SMOD  ${alias}

    ${RAT_BBMOD_POWERGROUP_info_dict}=  Get RAT CABINET module POWERGROUP info dict  ${RAT}  BBMOD  ${alias}

    ${SMOD_dn_port_FRONTHAUL_MOD_dn_dict}=  Get CABINET modules with ports providing synchronisation to FRONTHAUL modules info dict  SMOD  ${alias}

    ${BBMOD_dn_port_FRONTHAUL_MOD_dn_dict}=  Get CABINET modules with ports providing synchronisation to FRONTHAUL modules info dict  BBMOD  ${alias}

    ${RAT_reset_SMOD_FRONTHAUL_modules}=  Get FRONTHAUL modules impacted by RAT reset  SMOD  ${RAT_SMOD_POWERGROUP_info_dict}
    ...  ${SMOD_dn_port_FRONTHAUL_MOD_dn_dict}  ${alias}

    ${RAT_reset_BBMOD_FRONTHAUL_modules}=  Get FRONTHAUL modules impacted by RAT reset  BBMOD  ${RAT_BBMOD_POWERGROUP_info_dict}
    ...  ${BBMOD_dn_port_FRONTHAUL_MOD_dn_dict}  ${alias}

    ${RAT_reset_FRONTHAUL_modules}=  Combine Lists  ${RAT_reset_SMOD_FRONTHAUL_modules}  ${RAT_reset_BBMOD_FRONTHAUL_modules}

    ${FHS_id_list}=  Admin Get FHS Ids  alias=${alias}
    ${RMOD_id_list}=  Get Ids For All  class_name=RMOD  connection=${alias}

    ${RAT_reset_FHS_id_list}=  Create List
    ${RAT_reset_RMOD_id_list}=  Create List

    FOR  ${item}  IN  @{RAT_reset_FRONTHAUL_modules}

        Run Keyword If  '${item}' in ${FHS_id_list}
        ...  Append To List  ${RAT_reset_FHS_id_list}  ${item}
        ...  ELSE IF  '${item}' in ${RMOD_id_list}
        ...  Append To List  ${RAT_reset_RMOD_id_list}  ${item}

    END

    FOR  ${item}  IN  @{RAT_reset_FHS_id_list}

        ${RMOD_sync_list}=  Get secondEndpoint module list with synchronisation from firstEndpoint module  ${item}  ${RMOD_id_list}  ${alias}
        Append To List  ${RAT_reset_RMOD_id_list}  @{RMOD_sync_list}

    END

    ${RAT_reset_RMOD_id_list}=  Remove Duplicates  ${RAT_reset_RMOD_id_list}

    FOR  ${item}  IN  @{RAT_reset_RMOD_id_list}

        ${RMOD_sync_list}=  Get secondEndpoint module list with synchronisation from firstEndpoint module  ${item}  ${RMOD_id_list}  ${alias}
        Append To List  ${RAT_reset_RMOD_id_list}  @{RMOD_sync_list}

    END

    ${RAT_reset_RMOD_id_list}=  Remove Duplicates  ${RAT_reset_RMOD_id_list}

    ${RAT_reset_NRCEL_id_list}  ${RAT_reset_LNCEL_id_list}  ${RAT_reset_WNCEL_id_list}  ${RAT_reset_GNCEL_id_list}=  Get RAT cells mapped on RMOD list
    ...  ${RAT_reset_RMOD_id_list}  ${alias}

    [Return]  ${RAT_reset_FHS_id_list}  ${RAT_reset_RMOD_id_list}  ${RAT_reset_NRCEL_id_list}  ${RAT_reset_LNCEL_id_list}  ${RAT_reset_WNCEL_id_list}
    ...  ${RAT_reset_GNCEL_id_list}

Get RAT CABINET module POWERGROUP info dict
    [Documentation]
    ...  Keyword providing CABINET module POWERGROUP info dict related to configured RAT
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter      | Man. | Default | Description                      |
    ...  | RAT            | Yes  |         | RAT: NR, LTE, WCDMA or GSM       |
    ...  | MOD_class_name | Yes  |         | Module class name: SMOD or BBMOD |
    ...  | alias          | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                      | Description                                                          |
    ...  | RAT_MOD_POWERGROUP_info_dict   | RAT dict containing structure: {'CABINET_MOD_dn': ['POWERGROUP-id']} |
    ...
    [Arguments]  ${RAT}  ${MOD_class_name}  ${alias}

    ${RAT_MOD_POWERGROUP_info_dict}=  Create Dictionary

    ${SOC_L_info}=  coam.Get Managed Objects  class_name=SOC_L  connection=${alias}

    ${MOD_R_L_id_dict}  ${MOD_L_R_id_dict}=  Get MOD_R MOD_L distinguished name info dict  ${MOD_class_name}  ${alias}

    ${MOD_L_id_list}=  Get Dictionary Keys  ${MOD_L_R_id_dict}

    ${MOD_R_id_list}=  Get Dictionary Keys  ${MOD_R_L_id_dict}

    FOR  ${item}  IN  @{MOD_R_id_list}

        ${MOD_L_id}=  Get From Dictionary  ${MOD_R_L_id_dict}  ${item}

        ${MOD_param}=  Get Parameters For  class_name=${MOD_class_name}  id_num=${item}  connection=${alias}

        ${RAT_POWERGROUP_list}=  Get and check SOC info  ${RAT}  ${MOD_L_id}  ${MOD_param['productName']}  ${SOC_L_info}

        Set To Dictionary  ${RAT_MOD_POWERGROUP_info_dict}  ${item}  ${RAT_POWERGROUP_list}

    END

    [Return]  ${RAT_MOD_POWERGROUP_info_dict}

Get MOD_R MOD_L distinguished name info dict
    [Arguments]  ${MOD_class_name}  ${alias}

    ${MOD_R_L_id_dict}=  Create Dictionary
    ${MOD_L_R_id_dict}=  Create Dictionary

    ${MOD_R_info}=  Get Parameters For All  class_name=${MOD_class_name}  connection=${alias}

    FOR  ${item}  IN  @{MOD_R_info}

        ${MOD_L_dn}=  Get MOD_L distinguished name info  ${MOD_class_name}  ${item['serialNumber']}  ${alias}

        Set To Dictionary  ${MOD_R_L_id_dict}  ${item['id']}  ${MOD_L_dn}
        Set To Dictionary  ${MOD_L_R_id_dict}  ${MOD_L_dn}  ${item['id']}

    END

    [Return]  ${MOD_R_L_id_dict}  ${MOD_L_R_id_dict}

Get MOD_L distinguished name info
    [Arguments]  ${MOD_class_name}  ${MOD_sn}  ${alias}

    ${MOD_L_info}=  coam.Get Managed Objects  class_name=${MOD_class_name}_L  connection=${alias}

    FOR  ${item}  IN  @{MOD_L_info}

        Exit For Loop If  '${item['parameters']['serialNumber']}' == '${MOD_sn}'

    END
    Run Keyword If  '${item['parameters']['serialNumber']}' != '${MOD_sn}'
    ...  Fail  Could not find MOD_L with serial number ${MOD_sn}!
    [Return]  ${item['distName']}

Get and check SOC info
    [Arguments]  ${RAT}  ${MOD_L_id}  ${MOD_R_productName}  ${SOC_L_info}

    ${RAT_POWERGROUP_list}=  Create List

    ${status}=  Run Keyword And Return Status  Variable Should Exist  ${${MOD_R_productName}}
    Return From Keyword If  not ${status}  ${RAT_POWERGROUP_list}

    FOR  ${item}  IN  @{SOC_L_info}

        ${SOC_L_rat}=  Get From Dictionary  ${item['parameters']}  rat
        ${SOC_L_rat_count}=  Get Length  ${SOC_L_rat}
        Continue For Loop If  ${SOC_L_rat_count} == 0
        Continue For Loop If  '${RAT}' not in ${SOC_L_rat}

        ${SOC_L_dn}=  Get From Dictionary  ${item}  distName

        ${MOD_SOC_found}=  Run Keyword And Return Status  Should Contain  ${SOC_L_dn}  ${MOD_L_id}

        Continue For Loop If  '${MOD_SOC_found}' == '${FALSE}'

        ${POWER_GROUP_L_dn}=  Get Regexp Matches  ${SOC_L_dn}  POWER_GROUP_L-\\d
        ${POWER_GROUP_id}=  Fetch from right  ${POWER_GROUP_L_dn}[0]  -

        ${SOC_L_hwVariant}=  Get From Dictionary  ${item['parameters']}  hwVariant
        ${hwVariant}=  Get From Dictionary  ${${MOD_R_productName}}  hwVariant

        Continue For Loop If  '${SOC_L_hwVariant}' != '${hwVariant}'

        Append To List  ${RAT_POWERGROUP_list}  POWERGROUP-${POWER_GROUP_id}

    END

    ${RAT_POWERGROUP_list}=  Remove Duplicates  ${RAT_POWERGROUP_list}

    [Return]  ${RAT_POWERGROUP_list}

Get CABINET modules with ports providing synchronisation to FRONTHAUL modules info dict
    [Documentation]
    ...  Keyword providing CABINET modules (SMOD/BBMOD) with ports providing synchronisation to FRONTHAUL modules (FHS/RMOD) info dict
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter      | Man. | Default | Description                      |
    ...  | MOD_class_name | Yes  |         | Module class name: SMOD or BBMOD |
    ...  | alias          | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  | Parameter                                 | Description                                                                             |
    ...  | CABINET_MOD_dn_port_FRONTHAUL_MOD_dn_dict | Dict containing structure: {'CABINET_MOD_dn': {'CABINET_MOD_port': 'FRONTHAUL_MOD_dn'}} |
    ...
    [Arguments]  ${MOD_class_name}  ${alias}

    ${MOD_id_list}=  Get Ids For All  class_name=${MOD_class_name}  connection=${alias}

    ${FHS_id_list}=  Admin Get FHS Ids  alias=${alias}
    ${RMOD_id_list}=  Get Ids For All  class_name=RMOD  connection=${alias}
    ${FRONTHAUL_module_id_list}=  Combine Lists  ${FHS_id_list}  ${RMOD_id_list}

    ${CABINET_MOD_dn_port_FRONTHAUL_MOD_dn_dict}=  Create Dictionary

    FOR  ${item}  IN  @{MOD_id_list}

       ${MOD_port_sync_FRONTHAUL_MOD_dn_dict}=  Get CABINET module ports providing synchronisation to FRONTHAUL modules info dict  ${item}
       ...  ${FRONTHAUL_module_id_list}  ${alias}
       Set To Dictionary  ${CABINET_MOD_dn_port_FRONTHAUL_MOD_dn_dict}  ${item}  ${MOD_port_sync_FRONTHAUL_MOD_dn_dict}

    END

    [Return]  ${CABINET_MOD_dn_port_FRONTHAUL_MOD_dn_dict}

Get CABINET module ports providing synchronisation to FRONTHAUL modules info dict
    [Documentation]
    ...  Keyword providing CABINET module (SMOD/BBMOD) with ports providing synchronisation to FRONTHAUL modules (FHS/RMOD) info dict
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter             | Man. | Default | Description                        |
    ...  | module_id             | Yes  |         | Module distname                    |
    ...  | secondEndpointDN_list | Yes  |         | List of FRONTHAUL modules distname |
    ...  | alias                 | Yes  |         | alias of admin instance            |
    ...
    ...  *RETURN*
    ...  | Parameter                           | Description                                                         |
    ...  | MOD_port_sync_FRONTHAUL_MOD_dn_dict | Dict containing structure: {'CABINET_MOD_port': 'FRONTHAUL_MOD_dn'} |
    ...
    [Arguments]  ${module_id}  ${secondEndpointDN_list}  ${alias}

    ${CABLINK_R_info}=  coam.Get Managed Objects  class_name=CABLINK_R  connection=${alias}

    ${FHS_id_list}=  Admin Get FHS Ids  alias=${alias}
    ${RMOD_id_list}=  Get Ids For All  class_name=RMOD  connection=${alias}
    ${FHS_RMOD_id_list}=  Combine Lists  ${FHS_id_list}  ${RMOD_id_list}

    ${MOD_port_sync_FRONTHAUL_MOD_dn_dict}=  Create Dictionary

    FOR  ${item}  IN  @{CABLINK_R_info}

       ${firstEndpointDN_info}=  Get From Dictionary  ${item['parameters']}  firstEndpointDN
       Continue For Loop If  '${firstEndpointDN_info}' != '${module_id}'

       ${secondEndpointDN_info}=  Get From Dictionary  ${item['parameters']}  secondEndpointDN
       Continue For Loop If  '${secondEndpointDN_info}' not in ${secondEndpointDN_list}

       ${linkModeSynchronization_info}=  Get From Dictionary  ${item['parameters']}  linkModeSynchronization
       Continue For Loop If  '${linkModeSynchronization_info}' != 'True'

       ${firstEndpointPortId_info}=  Get From Dictionary  ${item['parameters']}  firstEndpointPortId

       Set To Dictionary  ${MOD_port_sync_FRONTHAUL_MOD_dn_dict}  ${firstEndpointPortId_info}  ${secondEndpointDN_info}

    END

    [Return]  ${MOD_port_sync_FRONTHAUL_MOD_dn_dict}

Get FRONTHAUL modules impacted by RAT reset
    [Arguments]  ${MOD_class_name}  ${RAT_MOD_SOC_info_dict}  ${MOD_dn_port_FRONTHAUL_MOD_dn_dict}  ${alias}

    ${RAT_MOD_list}=  Get Dictionary Keys  ${RAT_MOD_SOC_info_dict}

    ${RAT_reset_FRONTHAUL_modules}=  Create List

    FOR  ${item}  IN  @{RAT_MOD_list}

        ${MOD_param}=  Get Parameters For  class_name=${MOD_class_name}  id_num=${item}  connection=${alias}
        ${productName_info}=  Get From Dictionary  ${MOD_param}  productName

        ${status}=  Run Keyword And Return Status  Variable Should Exist  ${${productName_info}}
        Continue For Loop If  not ${status}

        ${POWERGROUP_info}=  Get From Dictionary  ${RAT_MOD_SOC_info_dict}  ${item}
        ${MOD_port_sync_FRONTHAUL_MOD_dn_dict}=  Get From Dictionary  ${MOD_dn_port_FRONTHAUL_MOD_dn_dict}  ${item}
        ${MOD_FRONTHAUL_MOD_list}=  Get FRONTHAUL modules  ${productName_info}  ${POWERGROUP_info}  ${MOD_port_sync_FRONTHAUL_MOD_dn_dict}

        Append To List  ${RAT_reset_FRONTHAUL_modules}  @{MOD_FRONTHAUL_MOD_list}

    END

    ${RAT_reset_FRONTHAUL_modules}=  Remove Duplicates  ${RAT_reset_FRONTHAUL_modules}
    Sort List  ${RAT_reset_FRONTHAUL_modules}

    [Return]  ${RAT_reset_FRONTHAUL_modules}

Get FRONTHAUL modules
    [Arguments]  ${MOD_productName}  ${POWERGROUP_info}  ${MOD_port_sync_FRONTHAUL_MOD_dn_dict}

    ${FRONTHAUL_MOD_list}=  Create List
    ${all_port_list}=  Create List

    FOR  ${item}  IN  @{POWERGROUP_info}

        ${port_list}=  Get From Dictionary  ${${MOD_productName}}  ${item}
        Append To List  ${all_port_list}  @{port_list}

    END

    FOR  ${item}  IN  @{all_port_list}

        ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${MOD_port_sync_FRONTHAUL_MOD_dn_dict}  ${item}
        Continue For Loop If  not ${status}

        ${FRONTHAUL_MOD_dn}=  Get From Dictionary  ${MOD_port_sync_FRONTHAUL_MOD_dn_dict}  ${item}
        Append To List  ${FRONTHAUL_MOD_list}  ${FRONTHAUL_MOD_dn}

    END

    ${FRONTHAUL_MOD_list}=  Remove Duplicates  ${FRONTHAUL_MOD_list}
    Sort List  ${FRONTHAUL_MOD_list}

    [Return]  ${FRONTHAUL_MOD_list}

Get secondEndpoint module list with synchronisation from firstEndpoint module
    [Arguments]  ${firstEndpoint_module_id}  ${secondEndpoint_module_id_list}  ${alias}

    ${CABLINK_R_info}=  coam.Get Managed Objects  class_name=CABLINK_R  connection=${alias}

    ${RMOD_id_list}=  Get Ids For All  class_name=RMOD  connection=${alias}

    ${secondEndpoint_module_sync_list}=  Create List

    FOR  ${item}  IN  @{CABLINK_R_info}

       ${firstEndpointDN_info}=  Get From Dictionary  ${item['parameters']}  firstEndpointDN
       Continue For Loop If  '${firstEndpointDN_info}' != '${firstEndpoint_module_id}'

       ${secondEndpointDN_info}=  Get From Dictionary  ${item['parameters']}  secondEndpointDN
       Continue For Loop If  '${secondEndpointDN_info}' not in ${secondEndpoint_module_id_list}

       ${linkModeSynchronization_info}=  Get From Dictionary  ${item['parameters']}  linkModeSynchronization
       Continue For Loop If  '${linkModeSynchronization_info}' != 'True'

       Append To List  ${secondEndpoint_module_sync_list}  ${secondEndpointDN_info}

    END

    [Return]  ${secondEndpoint_module_sync_list}

Get RAT cells mapped on RMOD list
    [Arguments]  ${RMOD_id_list}  ${alias}

    ${NRCEL_mapped_RMOD_id_list}=  Create List
    ${LNCEL_mapped_RMOD_id_list}=  Create List
    ${WNCEL_mapped_RMOD_id_list}=  Create List
    ${GNCEL_mapped_RMOD_id_list}=  Create List

    FOR  ${item}  IN  @{RMOD_id_list}

        ${NRCEL_RMOD_list}  ${LNCEL_RMOD_list}  ${WNCEL_RMOD_list}  ${GNCEL_RMOD_list}=  Get RAT cells mapped on RMOD  ${item}  ${alias}
        Append To List  ${NRCEL_mapped_RMOD_id_list}  @{NRCEL_RMOD_list}
        Append To List  ${LNCEL_mapped_RMOD_id_list}  @{LNCEL_RMOD_list}
        Append To List  ${WNCEL_mapped_RMOD_id_list}  @{WNCEL_RMOD_list}
        Append To List  ${GNCEL_mapped_RMOD_id_list}  @{GNCEL_RMOD_list}

    END

    ${NRCEL_mapped_RMOD_id_list}=  Remove Duplicates  ${NRCEL_mapped_RMOD_id_list}
    ${LNCEL_mapped_RMOD_id_list}=  Remove Duplicates  ${LNCEL_mapped_RMOD_id_list}
    ${WNCEL_mapped_RMOD_id_list}=  Remove Duplicates  ${WNCEL_mapped_RMOD_id_list}
    ${GNCEL_mapped_RMOD_id_list}=  Remove Duplicates  ${GNCEL_mapped_RMOD_id_list}
    Sort List  ${NRCEL_mapped_RMOD_id_list}
    Sort List  ${LNCEL_mapped_RMOD_id_list}
    Sort List  ${WNCEL_mapped_RMOD_id_list}
    Sort List  ${GNCEL_mapped_RMOD_id_list}

    [Return]  ${NRCEL_mapped_RMOD_id_list}  ${LNCEL_mapped_RMOD_id_list}  ${WNCEL_mapped_RMOD_id_list}  ${GNCEL_mapped_RMOD_id_list}

Get RAT cells mapped on RMOD
    [Arguments]  ${RMOD_id}  ${alias}

    ${NRCEL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LNCEL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WNCEL_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GNCEL_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}

    ${CELL_RMOD_list}=  Get Cell Mapping By Module Id  module_id=${RMOD_id}  connection=${alias}

    ${NRCEL_RMOD_list}=  Create List
    ${LNCEL_RMOD_list}=  Create List
    ${WNCEL_RMOD_list}=  Create List
    ${GNCEL_RMOD_list}=  Create List

    FOR  ${item}  IN  @{CELL_RMOD_list}

        Run Keyword If  '${item}' in ${NRCEL_id_list}  Append To List  ${NRCEL_RMOD_list}  ${item}
        Run Keyword If  '${item}' in ${LNCEL_id_list}  Append To List  ${LNCEL_RMOD_list}  ${item}
        Run Keyword If  '${item}' in ${WNCEL_id_list}  Append To List  ${WNCEL_RMOD_list}  ${item}
        Run Keyword If  '${item}' in ${GNCEL_id_list}  Append To List  ${GNCEL_RMOD_list}  ${item}

    END

    [Return]  ${NRCEL_RMOD_list}  ${LNCEL_RMOD_list}  ${WNCEL_RMOD_list}  ${GNCEL_RMOD_list}

Get BTSs impact due to reset BBMOD on connected FHSs
    [Documentation]
    ...  Keyword providing own BTS and peer BTS impact due to reset BBMOD from own BTS on connected FHSs based on following info:
    ...  - configured FHSs: shared or dedicated
    ...  - configured cablink number on impacted FHSs on own BTS
    ...  - cablink info: synchronization, configuration and data parameters
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description                        |
    ...  | BBMOD_id  | Yes  |         | BBMOD distname                     |
    ...  | alias     | Yes  |         | alias of admin instance on own BTS |
    ...
    ...  *RETURN*
    ...
    ...  | Parameter                                       | Description                                                        |
    ...  | expected_own_BTS_enabled_shared_FHS_id_list     | Expected own BTS enabled shared FHS id list due to BBMOD reset     |
    ...  | expected_own_BTS_disabled_shared_FHS_id_list    | Expected own BTS disabled shared FHS id list due to BBMOD reset    |
    ...  | expected_peer_BTS_enabled_shared_FHS_sn_list    | Expected peer BTS enabled shared FHS sn list due to BBMOD reset    |
    ...  | expected_peer_BTS_disabled_shared_FHS_sn_list   | Expected peer BTS disabled shared FHS sn list due to BBMOD reset   |
    ...  | expected_own_BTS_enabled_dedicated_FHS_id_list  | Expected own BTS enabled dedicated FHS id list due to BBMOD reset  |
    ...  | expected_own_BTS_disabled_dedicated_FHS_id_list | Expected own BTS disabled dedicated FHS id list due to BBMOD reset |
    ...
    [Arguments]  ${BBMOD_id}  ${alias}

    ${BBMOD_id_shared_FHS_id_CABLINK_id_sync_conf_data_info_dict}  ${BBMOD_id_shared_FHS_sn_CABLINK_id_sync_conf_data_info_dict}
    ...  ${BBMOD_id_dedicated_FHS_id_CABLINK_id_sync_conf_data_info_dict}=  Get BBMOD MODULE cablink info dict  ${BBMOD_id}  FHS  ${alias}

    ${shared_FHS_id_CABLINK_id_sync_conf_data_info_dict}=  Get From Dictionary  ${BBMOD_id_shared_FHS_id_CABLINK_id_sync_conf_data_info_dict}
    ...  ${BBMOD_id}
    ${BBMOD_shared_FHS_id_list}=  Get Dictionary Keys  ${shared_FHS_id_CABLINK_id_sync_conf_data_info_dict}

    ${dedicated_FHS_id_CABLINK_id_sync_conf_data_info_dict}=  Get From Dictionary  ${BBMOD_id_dedicated_FHS_id_CABLINK_id_sync_conf_data_info_dict}
    ...  ${BBMOD_id}
    ${BBMOD_dedicated_FHS_id_list}=  Get Dictionary Keys  ${dedicated_FHS_id_CABLINK_id_sync_conf_data_info_dict}

    ${CABLINK_R_info}=  coam.Get Managed Objects  class_name=CABLINK_R  connection=${alias}

    ${FHS_sn_id_dict}  ${FHS_id_sn_dict}=  Get FHS id sn info dict  ${alias}

    ${shared_FHS_other_firstEndpointDN_dict}=  Create Dictionary

    FOR  ${item}  IN  @{BBMOD_shared_FHS_id_list}

       ${shared_FHS_id_firstEndpointDN_info_dict}=  Get specific MODULE firstEndpointDN info dict  ${item}  ${CABLINK_R_info}
       ${shared_FHS_firstEndpointDN_list}=  Get From Dictionary  ${shared_FHS_id_firstEndpointDN_info_dict}  ${item}
       Remove Values From List  ${shared_FHS_firstEndpointDN_list}  ${BBMOD_id}
       Set To Dictionary  ${shared_FHS_other_firstEndpointDN_dict}  ${item}  ${shared_FHS_firstEndpointDN_list}

    END

    ${dedicated_FHS_other_firstEndpointDN_dict}=  Create Dictionary

    FOR  ${item}  IN  @{BBMOD_dedicated_FHS_id_list}

       ${dedicated_FHS_id_firstEndpointDN_info_dict}=  Get specific MODULE firstEndpointDN info dict  ${item}  ${CABLINK_R_info}
       ${dedicated_FHS_firstEndpointDN_list}=  Get From Dictionary  ${dedicated_FHS_id_firstEndpointDN_info_dict}  ${item}
       Remove Values From List  ${dedicated_FHS_firstEndpointDN_list}  ${BBMOD_id}
       Set To Dictionary  ${dedicated_FHS_other_firstEndpointDN_dict}  ${item}  ${dedicated_FHS_firstEndpointDN_list}

    END

    ${expected_own_BTS_enabled_shared_FHS_id_list}=  Create List
    ${expected_own_BTS_disabled_shared_FHS_id_list}=  Create List
    ${expected_peer_BTS_enabled_shared_FHS_sn_list}=  Create List
    ${expected_peer_BTS_disabled_shared_FHS_sn_list}=  Create List

    FOR  ${item}  IN  @{BBMOD_shared_FHS_id_list}

       ${FHS_sn}=  Get From Dictionary  ${FHS_id_sn_dict}  ${item}

       ${shared_FHS_other_firstEndpointDN_list}=  Get From Dictionary  ${shared_FHS_other_firstEndpointDN_dict}  ${item}
       ${shared_FHS_other_firstEndpointDN_count}=  Get Length  ${shared_FHS_other_firstEndpointDN_list}

       ${linkModeSynchronization}  ${linkModeConfiguration}  ${linkModeData}=  Get BBMOD info provided to MODULE  ${BBMOD_id}  ${item}
       ...  ${BBMOD_id_shared_FHS_id_CABLINK_id_sync_conf_data_info_dict}

       Run Keyword If  '${linkModeSynchronization}' == 'True'  Run Keywords
       ...  Append To List  ${expected_own_BTS_disabled_shared_FHS_id_list}  ${item}
       ...  AND  Append To List  ${expected_peer_BTS_disabled_shared_FHS_sn_list}  ${FHS_sn}
       ...  ELSE IF  '${linkModeConfiguration}' == 'True'  Run Keywords
       ...  Append To List  ${expected_own_BTS_disabled_shared_FHS_id_list}  ${item}
       ...  AND  Append To List  ${expected_peer_BTS_enabled_shared_FHS_sn_list}  ${FHS_sn}
       ...  ELSE  Run Keywords
       ...  Append To List  ${expected_own_BTS_enabled_shared_FHS_id_list}  ${item}
       ...  AND  Append To List  ${expected_peer_BTS_enabled_shared_FHS_sn_list}  ${FHS_sn}

    END

    ${expected_own_BTS_enabled_dedicated_FHS_id_list}=  Create List
    ${expected_own_BTS_disabled_dedicated_FHS_id_list}=  Create List

    FOR  ${item}  IN  @{BBMOD_dedicated_FHS_id_list}

       ${dedicated_FHS_other_firstEndpointDN_list}=  Get From Dictionary  ${dedicated_FHS_other_firstEndpointDN_dict}  ${item}
       ${dedicated_FHS_other_firstEndpointDN_count}=  Get Length  ${dedicated_FHS_other_firstEndpointDN_list}

       ${linkModeSynchronization}  ${linkModeConfiguration}  ${linkModeData}=  Get BBMOD info provided to MODULE  ${BBMOD_id}  ${item}
       ...  ${BBMOD_id_dedicated_FHS_id_CABLINK_id_sync_conf_data_info_dict}

       ${cond}=  Create Long String  ${dedicated_FHS_other_firstEndpointDN_count} == 0 or '${linkModeSynchronization}' == 'True' or
       ...  '${linkModeConfiguration}' == 'True'

       Run Keyword If  ${cond}
       ...  Append To List  ${expected_own_BTS_disabled_dedicated_FHS_id_list}  ${item}
       ...  ELSE
       ...  Append To List  ${expected_own_BTS_enabled_dedicated_FHS_id_list}  ${item}

    END

    [Return]  ${expected_own_BTS_enabled_shared_FHS_id_list}  ${expected_own_BTS_disabled_shared_FHS_id_list}
    ...  ${expected_peer_BTS_enabled_shared_FHS_sn_list}  ${expected_peer_BTS_disabled_shared_FHS_sn_list}
    ...  ${expected_own_BTS_enabled_dedicated_FHS_id_list}  ${expected_own_BTS_disabled_dedicated_FHS_id_list}

Get BTSs impact due to reset BBMOD on connected RMODs
    [Documentation]
    ...  Keyword providing own BTS and peer BTS impact due to reset BBMOD from own BTS on connected RMODs based on following info:
    ...  - configured RMODs: shared or dedicated
    ...  - configured cablink number on impacted RMODs on own BTS
    ...  - cablink info: synchronization, configuration and data parameters
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description                        |
    ...  | BBMOD_id  | Yes  |         | BBMOD distname                     |
    ...  | alias     | Yes  |         | alias of admin instance on own BTS |
    ...
    ...  *RETURN*
    ...
    ...  | Parameter                                        | Description                                                         |
    ...  | expected_own_BTS_enabled_shared_RMOD_id_list     | Expected own BTS enabled shared RMOD id list due to BBMOD reset     |
    ...  | expected_own_BTS_disabled_shared_RMOD_id_list    | Expected own BTS disabled shared RMOD id list due to BBMOD reset    |
    ...  | expected_peer_BTS_enabled_shared_RMOD_sn_list    | Expected peer BTS enabled shared RMOD sn list due to BBMOD reset    |
    ...  | expected_peer_BTS_disabled_shared_RMOD_sn_list   | Expected peer BTS disabled shared RMOD sn list due to BBMOD reset   |
    ...  | expected_own_BTS_enabled_dedicated_RMOD_id_list  | Expected own BTS enabled dedicated RMOD id list due to BBMOD reset  |
    ...  | expected_own_BTS_disabled_dedicated_RMOD_id_list | Expected own BTS disabled dedicated RMOD id list due to BBMOD reset |
    ...
    [Arguments]  ${BBMOD_id}  ${alias}

    ${BBMOD_id_shared_RMOD_id_CABLINK_id_sync_conf_data_info_dict}  ${BBMOD_id_shared_RMOD_sn_CABLINK_id_sync_conf_data_info_dict}
    ...  ${BBMOD_id_dedicated_RMOD_id_CABLINK_id_sync_conf_data_info_dict}=  Get BBMOD MODULE cablink info dict  ${BBMOD_id}  RMOD  ${alias}

    ${shared_RMOD_id_CABLINK_id_sync_conf_data_info_dict}=  Get From Dictionary  ${BBMOD_id_shared_RMOD_id_CABLINK_id_sync_conf_data_info_dict}
    ...  ${BBMOD_id}
    ${BBMOD_shared_RMOD_id_list}=  Get Dictionary Keys  ${shared_RMOD_id_CABLINK_id_sync_conf_data_info_dict}

    ${dedicated_RMOD_id_CABLINK_id_sync_conf_data_info_dict}=  Get From Dictionary  ${BBMOD_id_dedicated_RMOD_id_CABLINK_id_sync_conf_data_info_dict}
    ...  ${BBMOD_id}
    ${BBMOD_dedicated_RMOD_id_list}=  Get Dictionary Keys  ${dedicated_RMOD_id_CABLINK_id_sync_conf_data_info_dict}

    ${CABLINK_R_info}=  coam.Get Managed Objects  class_name=CABLINK_R  connection=${alias}

    ${RMOD_sn_id_dict}  ${RMOD_id_sn_dict}=  Get RM id sn info dict  ${alias}

    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}

    ${shared_RMOD_other_firstEndpointDN_dict}=  Create Dictionary

    FOR  ${item}  IN  @{BBMOD_shared_RMOD_id_list}

       ${shared_RMOD_id_firstEndpointDN_info_dict}=  Get specific MODULE firstEndpointDN info dict  ${item}  ${CABLINK_R_info}
       ${shared_RMOD_firstEndpointDN_list}=  Get From Dictionary  ${shared_RMOD_id_firstEndpointDN_info_dict}  ${item}
       Remove Values From List  ${shared_RMOD_firstEndpointDN_list}  ${BBMOD_id}
       Set To Dictionary  ${shared_RMOD_other_firstEndpointDN_dict}  ${item}  ${shared_RMOD_firstEndpointDN_list}

    END

    ${dedicated_RMOD_other_firstEndpointDN_dict}=  Create Dictionary

    FOR  ${item}  IN  @{BBMOD_dedicated_RMOD_id_list}

       ${dedicated_RMOD_id_firstEndpointDN_info_dict}=  Get specific MODULE firstEndpointDN info dict  ${item}  ${CABLINK_R_info}
       ${dedicated_RMOD_firstEndpointDN_list}=  Get From Dictionary  ${dedicated_RMOD_id_firstEndpointDN_info_dict}  ${item}
       Remove Values From List  ${dedicated_RMOD_firstEndpointDN_list}  ${BBMOD_id}
       Set To Dictionary  ${dedicated_RMOD_other_firstEndpointDN_dict}  ${item}  ${dedicated_RMOD_firstEndpointDN_list}

    END

    ${expected_own_BTS_enabled_shared_RMOD_id_list}=  Create List
    ${expected_own_BTS_disabled_shared_RMOD_id_list}=  Create List
    ${expected_peer_BTS_enabled_shared_RMOD_sn_list}=  Create List
    ${expected_peer_BTS_disabled_shared_RMOD_sn_list}=  Create List

    FOR  ${item}  IN  @{BBMOD_shared_RMOD_id_list}

       ${RMOD_sn}=  Get From Dictionary  ${RMOD_id_sn_dict}  ${item}

       ${shared_RMOD_other_firstEndpointDN_list}=  Get From Dictionary  ${shared_RMOD_other_firstEndpointDN_dict}  ${item}
       ${shared_RMOD_other_firstEndpointDN_count}=  Get Length  ${shared_RMOD_other_firstEndpointDN_list}

       ${linkModeSynchronization}  ${linkModeConfiguration}  ${linkModeData}=  Get BBMOD info provided to MODULE  ${BBMOD_id}  ${item}
       ...  ${BBMOD_id_shared_RMOD_id_CABLINK_id_sync_conf_data_info_dict}

       ${RMOD_L3Protocol}=  Get From Dictionary  ${RMOD_L3Protocol_dict}  ${item}

       Run Keyword If  '${linkModeSynchronization}' == 'True'  Run Keywords
       ...  Append To List  ${expected_own_BTS_disabled_shared_RMOD_id_list}  ${item}
       ...  AND  Append To List  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}  ${RMOD_sn}
       ...  ELSE IF  '${linkModeConfiguration}' == 'True'  Run Keywords
       ...  Append To List  ${expected_own_BTS_disabled_shared_RMOD_id_list}  ${item}
       ...  AND  Append To List  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${RMOD_sn}
       ...  ELSE  Run Keywords
       ...  Append To List  ${expected_own_BTS_enabled_shared_RMOD_id_list}  ${item}
       ...  AND  Append To List  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${RMOD_sn}

    END

    ${expected_own_BTS_enabled_dedicated_RMOD_id_list}=  Create List
    ${expected_own_BTS_disabled_dedicated_RMOD_id_list}=  Create List

    FOR  ${item}  IN  @{BBMOD_dedicated_RMOD_id_list}

       ${dedicated_RMOD_other_firstEndpointDN_list}=  Get From Dictionary  ${dedicated_RMOD_other_firstEndpointDN_dict}  ${item}
       ${dedicated_RMOD_other_firstEndpointDN_count}=  Get Length  ${dedicated_RMOD_other_firstEndpointDN_list}

       ${linkModeSynchronization}  ${linkModeConfiguration}  ${linkModeData}=  Get BBMOD info provided to MODULE  ${BBMOD_id}  ${item}
       ...  ${BBMOD_id_dedicated_RMOD_id_CABLINK_id_sync_conf_data_info_dict}

       ${RMOD_L3Protocol}=  Get From Dictionary  ${RMOD_L3Protocol_dict}  ${item}

       ${cond}=  Create Long String  ${dedicated_RMOD_other_firstEndpointDN_count} == 0 or '${linkModeSynchronization}' == 'True' or
       ...  '${linkModeConfiguration}' == 'True'

       Run Keyword If  ${cond}
       ...  Append To List  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  ${item}
       ...  ELSE
       ...  Append To List  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${item}

    END

    [Return]  ${expected_own_BTS_enabled_shared_RMOD_id_list}  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_peer_BTS_enabled_shared_RMOD_sn_list}  ${expected_peer_BTS_disabled_shared_RMOD_sn_list}
    ...  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}

Get BBMOD MODULE cablink info dict
    [Documentation]
    ...  Keyword providing BBMOD connected to FHS/RMOD cablink info dict about synchronization, configuration and data parameters
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter      | Man. | Default | Description                    |
    ...  | BBMOD_id       | Yes  |         | BBMOD distname                 |
    ...  | MOD_class_name | Yes  |         | Module class_name: FHS or RMOD |
    ...  | alias          | Yes  |         | alias of admin instance        |
    ...
    ...  *RETURN*
    ...  | Parameter                                                     | Description
    ...  | BBMOD_id_shared_MOD_id_CABLINK_id_sync_conf_data_info_dict    | Dict containing structure: {'BBMOD_id': 'MOD_id': ['CABLINK_id':
    ...                                                                    {'configuration': '<value>', 'synchronization': '<value>',
    ...                                                                    'data': '<value>'}]} for shared module                          |
    ...  | BBMOD_id_shared_MOD_sn_CABLINK_id_sync_conf_data_info_dict    | Dict containing structure: {'BBMOD_id': 'MOD_sn': ['CABLINK_id':
    ...                                                                    {'configuration': '<value>', 'synchronization': '<value>',
    ...                                                                    'data': '<value>'}]} for shared module                          |
    ...  | BBMOD_id_dedicated_MOD_id_CABLINK_id_sync_conf_data_info_dict | Dict containing structure: {'BBMOD_id': 'MOD_id': ['CABLINK_id':
    ...                                                                    {'configuration': '<value>', 'synchronization': '<value>',
    ...                                                                    'data': '<value>'}]} for dedicated module                       |
    ...
    [Arguments]  ${BBMOD_id}  ${MOD_class_name}  ${alias}

    ${CABLINK_R_info}=  coam.Get Managed Objects  class_name=CABLINK_R  connection=${alias}

    ${MOD_sn_bts-alias_dict}  ${shared_MOD_sn_list}  ${dedicated_MOD_sn_list}=  Run Keyword If  '${MOD_class_name}' == 'RMOD'
    ...  Admin Get RM sn bts-alias info dict
    ...  ELSE IF  '${MOD_class_name}' == 'FHS'
    ...  Admin Get FHS sn bts-alias info dict
    ${shared_MOD_count}=  Get Length  ${shared_MOD_sn_list}
    ${dedicated_MOD_count}=  Get Length  ${dedicated_MOD_sn_list}
    ${MOD_sn_id_dict}  ${MOD_id_sn_dict}=  Run Keyword If  '${MOD_class_name}' == 'RMOD'
    ...  Get RM id sn info dict  ${alias}
    ...  ELSE IF  '${MOD_class_name}' == 'FHS'
    ...  Get FHS id sn info dict  ${alias}

    ${MOD_id_list}=  Get Dictionary Keys  ${MOD_id_sn_dict}
    Sort List  ${MOD_id_list}

    ${BBMOD_id_shared_MOD_id_CABLINK_id_sync_conf_data_info_dict}=  Create Dictionary
    ${BBMOD_id_shared_MOD_sn_CABLINK_id_sync_conf_data_info_dict}=  Create Dictionary
    ${BBMOD_id_dedicated_MOD_id_CABLINK_id_sync_conf_data_info_dict}=  Create Dictionary

    ${shared_MOD_id_CABLINK_id_sync_conf_data_info_dict}=  Create Dictionary
    ${shared_MOD_sn_CABLINK_id_sync_conf_data_info_dict}=  Create Dictionary
    ${dedicated_MOD_id_CABLINK_id_sync_conf_data_info_dict}=  Create Dictionary

    FOR  ${item}  IN  @{MOD_id_list}

       ${MOD_sn}=  Get From Dictionary  ${MOD_id_sn_dict}  ${item}

       ${CABLINK_id_sync_conf_data_info_dict}=  Get specific BBMOD MODULE cablink info dict  ${BBMOD_id}  ${item}  ${CABLINK_R_info}
       ${info_status}=  Run Keyword And Return Status  Should Be Empty  ${CABLINK_id_sync_conf_data_info_dict}
       Continue For Loop If  ${info_status}

       Run Keyword If  ${shared_MOD_count} > 0  Run Keyword If  '${MOD_sn}' in ${shared_MOD_sn_list}  Run Keywords
       ...  Set To Dictionary  ${shared_MOD_id_CABLINK_id_sync_conf_data_info_dict}  ${item}  ${CABLINK_id_sync_conf_data_info_dict}
       ...  AND  Set To Dictionary  ${shared_MOD_sn_CABLINK_id_sync_conf_data_info_dict}  ${MOD_sn}  ${CABLINK_id_sync_conf_data_info_dict}

       Run Keyword If  ${dedicated_MOD_count} > 0  Run Keyword If  '${MOD_sn}' in ${dedicated_MOD_sn_list}
       ...  Set To Dictionary  ${dedicated_MOD_id_CABLINK_id_sync_conf_data_info_dict}  ${item}  ${CABLINK_id_sync_conf_data_info_dict}

    END

    Set To Dictionary  ${BBMOD_id_shared_MOD_id_CABLINK_id_sync_conf_data_info_dict}  ${BBMOD_id}
       ...  ${shared_MOD_id_CABLINK_id_sync_conf_data_info_dict}
    Set To Dictionary  ${BBMOD_id_shared_MOD_sn_CABLINK_id_sync_conf_data_info_dict}  ${BBMOD_id}
       ...  ${shared_MOD_sn_CABLINK_id_sync_conf_data_info_dict}
    Set To Dictionary  ${BBMOD_id_dedicated_MOD_id_CABLINK_id_sync_conf_data_info_dict}  ${BBMOD_id}
       ...  ${dedicated_MOD_id_CABLINK_id_sync_conf_data_info_dict}

    [Return]  ${BBMOD_id_shared_MOD_id_CABLINK_id_sync_conf_data_info_dict}  ${BBMOD_id_shared_MOD_sn_CABLINK_id_sync_conf_data_info_dict}
    ...  ${BBMOD_id_dedicated_MOD_id_CABLINK_id_sync_conf_data_info_dict}

Get specific BBMOD MODULE cablink info dict

    [Arguments]  ${BBMOD_id}  ${MOD_id}  ${CABLINK_R_info}

    ${CABLINK_id_sync_conf_data_info_dict}=  Create Dictionary

    FOR  ${item}  IN  @{CABLINK_R_info}

       ${sync_conf_data_info_dict}=  Create Dictionary

       ${firstEndpointDN_info}=  Get From Dictionary  ${item['parameters']}  firstEndpointDN
       Continue For Loop If  '${firstEndpointDN_info}' != '${BBMOD_id}'

       ${secondEndpointDN_info}=  Get From Dictionary  ${item['parameters']}  secondEndpointDN
       Continue For Loop If  '${secondEndpointDN_info}' != '${MOD_id}'

       ${linkModeSynchronization_info}=  Get From Dictionary  ${item['parameters']}  linkModeSynchronization
       ${linkModeConfiguration_info}=  Get From Dictionary  ${item['parameters']}  linkModeConfiguration
       ${linkModeData_info}=  Get From Dictionary  ${item['parameters']}  linkModeData

       Set To Dictionary  ${sync_conf_data_info_dict}  linkModeSynchronization  ${linkModeSynchronization_info}
       ...  linkModeConfiguration  ${linkModeConfiguration_info}  linkModeData  ${linkModeData_info}

       Set To Dictionary  ${CABLINK_id_sync_conf_data_info_dict}  ${item['distName']}  ${sync_conf_data_info_dict}

    END

    [Return]  ${CABLINK_id_sync_conf_data_info_dict}

Get specific MODULE firstEndpointDN info dict

    [Arguments]  ${MOD_id}  ${CABLINK_R_info}

    ${MOD_id_firstEndpointDN_info_dict}=  Create Dictionary

    ${firstEndpointDN_list}=  Create List

    FOR  ${item}  IN  @{CABLINK_R_info}

       ${secondEndpointDN_info}=  Get From Dictionary  ${item['parameters']}  secondEndpointDN
       Continue For Loop If  '${secondEndpointDN_info}' != '${MOD_id}'

       ${firstEndpointDN_info}=  Get From Dictionary  ${item['parameters']}  firstEndpointDN
       ${firstEndpointDN_SMOD_R}=  Run Keyword And Return Status  Should Contain  ${firstEndpointDN_info}  SMOD_R
       ${firstEndpointDN_BBMOD_R}=  Run Keyword And Return Status  Should Contain  ${firstEndpointDN_info}  BBMOD_R
       Continue For Loop If  '${firstEndpointDN_SMOD_R}' == 'False' and '${firstEndpointDN_BBMOD_R}' == 'False'

       Append To List  ${firstEndpointDN_list}  ${firstEndpointDN_info}

    END

    Set To Dictionary  ${MOD_id_firstEndpointDN_info_dict}  ${MOD_id}  ${firstEndpointDN_list}

    [Return]  ${MOD_id_firstEndpointDN_info_dict}

Get BBMOD info provided to MODULE

    [Arguments]  ${BBMOD_id}  ${MOD_id}  ${BBMOD_id_MOD_id_CABLINK_id_sync_conf_data_info_dict}

    ${MOD_id_CABLINK_id_sync_conf_data_info_dict}=  Get From Dictionary  ${BBMOD_id_MOD_id_CABLINK_id_sync_conf_data_info_dict}  ${BBMOD_id}
    ${CABLINK_id_sync_conf_data_info_dict}=  Get From Dictionary  ${MOD_id_CABLINK_id_sync_conf_data_info_dict}  ${MOD_id}

    ${CABLINK_id_list}=  Get Dictionary Keys  ${CABLINK_id_sync_conf_data_info_dict}

    ${linkModeSynchronization}=  Set Variable  False
    ${linkModeConfiguration}=  Set Variable  False
    ${linkModeData}=  Set Variable  False

    FOR  ${item}  IN  @{CABLINK_id_list}

       ${sync_conf_data_info_dict}=  Get From Dictionary  ${CABLINK_id_sync_conf_data_info_dict}  ${item}

       ${linkModeSynchronization_info}=  Get From Dictionary  ${sync_conf_data_info_dict}  linkModeSynchronization
       ${linkModeSynchronization}=  Set Variable If  '${linkModeSynchronization_info}' == 'True'  True  ${linkModeSynchronization}

       ${linkModeConfiguration_info}=  Get From Dictionary  ${sync_conf_data_info_dict}  linkModeConfiguration
       ${linkModeConfiguration}=  Set Variable If  '${linkModeConfiguration_info}' == 'True'  True  ${linkModeConfiguration}

       ${linkModeData_info}=  Get From Dictionary  ${sync_conf_data_info_dict}  linkModeData
       ${linkModeData}=  Set Variable If  '${linkModeData_info}' == 'True'  True  ${linkModeData}

    END

    [Return]  ${linkModeSynchronization}  ${linkModeConfiguration}  ${linkModeData}


Check all BTS cells availability status online
    [Arguments]  ${timeout}=600
    FOR  ${alias}  IN  @{alias_list}
        Check cells availability status online  ${alias}  ${timeout}
    END

Check BBMOD ABIA Reset
    [Arguments]  ${BBMOD_id}  ${BBMOD_CELL_list_BBPOOL}  ${alias}

    ${BBMOD_CELL_list_WEBEM}=  Get Cell Mapping By Module Id  module_id=${BBMOD_id}  connection=${alias}
    ${BBMOD_CELL_count_WEBEM}=  Get Length  ${BBMOD_CELL_list_WEBEM}
    ${BBMOD_CELL_count_BBPOOL}=  Get Length  ${BBMOD_CELL_list_BBPOOL}
    Return From Keyword If  ${BBMOD_CELL_count_WEBEM} != ${BBMOD_CELL_count_BBPOOL}  ${FALSE}
    ${LTE_CELL_list}=  Get Ids For All  LNCEL  ${alias}
    ${BBMOD_LTE_CELL_list}=  Create List
    FOR  ${item}  IN  @{BBMOD_CELL_list_BBPOOL}
        Run Keyword If  '${item}' in @{LTE_CELL_list}  Append To List  ${BBMOD_LTE_CELL_list}  ${item}
    END
    ${BBMOD_LTE_CELL_count}=  Get Length  ${BBMOD_LTE_CELL_list}
    ${BBMOD_ABIA_reset_allowed}=  Set Variable If  ${BBMOD_LTE_CELL_count} == ${BBMOD_CELL_count_BBPOOL}  ${TRUE}  ${FALSE}

    [Return]  ${BBMOD_ABIA_reset_allowed}

Modify Resource Search Order
    [Arguments]    ${resource_name}
    [Documentation]  Adjust Robot's library search order for the Robot-based (as opposed to JSON-based)
    ...    test sets. The KW adds a new entry at the end of the search order list (to retain search order defined
    ...    in TC Setup). To be used in [Setup] section as follows (presented here in a convenient tabular form):
    ...
    ...    [Setup] | Run Keywords | res_name.TC Setup | AND | Modify Resource Search Order | res_name
    ...
    ...    in pair with `Restore Resource Search Order` in [Teardown]:
    ...
    ...    [Teardown] | Run Keywords | res_name.TC Teardown | AND | Restore Resource Search Order
    ...
    ...    Non-existing resurces (`dummy_resource_name`) are ignored.
    [Tags]  robot:no-dry-run
    ${dummy_search_order}=    Create List    dummy_resource_name
    ${search_order}=   Set Library Search Order
    ${ORIGINAL_SEARCH_ORDER}=    Set Variable If    len(${search_order})    ${search_order}    ${dummy_search_order}
    Set Test Variable    ${ORIGINAL_SEARCH_ORDER}
    Set Library Search Order    ${resource_name}    @{search_order}
    ${TEST_RESOURCE_NAME}=  Get Variable Value  ${TEST_RESOURCE_NAME}  ${EMPTY}
    Run Keyword If  '${TEST_RESOURCE_NAME}' == '${EMPTY}'
    ...  Set Test Variable  ${TEST_RESOURCE_NAME}  ${resource_name}
    ...  ELSE  Run Keyword If  '${resource_name}' not in '${TEST_RESOURCE_NAME}'
    ...  Set Test Variable    ${TEST_RESOURCE_NAME}    ${TEST_RESOURCE_NAME};${resource_name}
    ...  ELSE  Set Test Variable    ${TEST_RESOURCE_NAME}

Restore Resource Search Order
    [Documentation]    To be used in pair with `Modify Resource Search Order`
    [Tags]  robot:no-dry-run
    ${search_order}=    Create List    @{ORIGINAL_SEARCH_ORDER}
    Remove Values From List    ${search_order}    dummy_resource_name
    Set Library Search Order   @{search_order}

Get SW file for SWDL
    [Documentation]
    ...  Verify given directory and return a path to the SW file (with given name or the newest in directory)
    ...
    ...	 *AUTHOR* tomasz.1.filipek@nokia.com
    [Arguments]  ${SW dir}  ${SW name}
    OperatingSystem.Directory should exist  ${SW dir}
    OperatingSystem.Directory should not be empty  ${SW dir}
    Run keyword and return if  '${SW name}'=='None'  get newest file from directory  ${SW dir}  *.zip
    ${SW path}=  Join Path 	${SW dir}  ${SW name}.zip
    OperatingSystem.File should exist  ${SW path}
    [Return]  ${SW path}

Check if SW already exists on BTS
    [Documentation]
    ...  pass_if_exists=False or omitted: Fail if given SW already exists on BTS (active)
    ...  pass_if_exists=True: Immediately ends the test as passed if given SW already exists on BTS (active)
    ...
    ...  *AUTHOR* tomasz.1.filipek@nokia.com
    [Arguments]  ${target SW}  ${active SW}  ${passive SW}  ${pass_if_exists}=${False}
    ${target is passive}=  run keyword and return status  Should Match Regexp  ${target SW}  (?i).*${passive SW}(?!T[12]).*
    run keyword if  ${target is passive}  log  Target SW is the same as the passive
    ${target is active}=  run keyword and return status  Should Match Regexp  ${target SW}  (?i).*${active SW}(?!T[12]).*
    run keyword if  ${target is active} and ${pass_if_exists}  pass execution  Target SW is the same as the active
    run keyword if  ${target is active}  fail  Target SW is the same as the active

Create 'Test Results Dir' and Set Test Variable
    [Documentation]
    ...   Test Results directories are created
    ...  *AUTHOR* radu.andronache@nokia.com

    ${status_basetestresultdir}=  Run Keyword And Return Status  Variable Should Exist  ${base_testresultpath}
    Run Keyword If  not ${status_basetestresultdir}  Create Base Test Result Dir

    ${testresultdir_count_string}=  Convert To String  ${testresultdir_count}
    ${run_testtimestamp}=    OperatingSystem.Run    date +%F_%H-%M-%S
    ${testresultspath}=    OperatingSystem.Join Path    ${base_testresultpath}    run_${testresultdir_count_string}_${run_testtimestamp}
    Create Directory    ${testresultspath}
    ${testresultdir_count}=    Evaluate    ${testresultdir_count} + 1
    Set Test Variable  ${testresultdir_count}
    Set Test Variable    ${Test Results Dir}    ${testresultspath}
    Log  'Test Results Dir' created: ${Test Results Dir}  level=DEBUG  console=${TRUE}

Create Base Test Result Dir
    ${testtimestamp}=    OperatingSystem.Run    date +%F_%H-%M-%S
    ${base_testresultpath}=    OperatingSystem.Join Path    ${OUTPUT DIR}    ${testtimestamp}_TEST-${TEST NAME}
    Create Directory    ${base_testresultpath}
    Set Test Variable  ${base_testresultpath}
    Set Test Variable  ${testresultdir_count}  1

Create '${dirname}' in '${rootdir}' And Set Test Variable
    [Documentation]
    ...   Log directories are created: BTSFiles, TestFiles, UDPLogs, Temp Logs Dir
    ...  *AUTHOR* radu.andronache@nokia.com
    ${dirpath}=    OperatingSystem.Join Path    ${rootdir}    ${dirname}
    Create Directory    ${dirpath}
    Set Test Variable    ${${dirname}}    ${dirpath}
    Log  '${dirname}' created: ${dirpath}  level=DEBUG

Kill process by name
    [Documentation]
    ...  Keyword killing group of process specified by name (case insensitive).
    ...
    ...  *AUTHOR* tomasz.1.filipek@nokia.com
    ...
    ...  | Parameter   | Man. | Description                                                    |
    ...  | process_name       | Yes  | string       |
    ...  | local | Yes  | boolean |
    ...  | configuration | Yes  | if local==false host_ip=<remote_host_ip>, ssh_port=<port>, ssh_username=<usenrame>, ssh_passsword=<password> |

    [Arguments]  ${process_name}  ${local}=${TRUE}  &{configuration}
    ${kill_cmd}=  Set Variable  kill -KILL $(ps -ef | grep -i ${process_name} | awk '{print $2}')
    Run Keyword If  ${local}  Process.Run process  ${kill_cmd}  shell=${TRUE}
    ...  ELSE  Run Keywords
    ...  SSHLibrary.Open Connection  host=${configuration["host_ip"]}  port=${configuration["ssh_port"]}
    ...  AND  _SSHLibrary_Login_multiway  ${configuration["ssh_username"]}  ${configuration["ssh_password"]}
    ...  AND  SSHLibrary.Execute Command  ${kill_cmd}  return_stdout=${FALSE}
    ...  AND  SSHLibrary.Close Connection
    [Return]  ${TRUE}

Get Workspace Version
    [Documentation]
    ...  KW for extraction workspace version during test execution
    ...
    ...  *AUTHOR* adelina.branc@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                |
    ...  | command         | Yes  | Command given to extract workspace version |

    ${first}  ${last}=  Split String From Right  ${SUITE_SOURCE}  /  1

    Find workspace version and set tags
    ...  git -C ${first} describe --always --tags | awk -F '[/|-g]' '{print $NF}' | cut -c 1-8

Find workspace version and set tags
    [Documentation]
    ...  KW for setting workspace version as tag
    ...
    ...  *AUTHOR* adelina.branc@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                |
    ...  | command         | Yes  | Command given to extract workspace version |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description                                  |
    ...  | workspace_version | installed workspace version during execution |

    [Arguments]  ${command}
    ${workspace_version} =  OperatingSystem.run  ${command}
    Log  Online workspace version is ${workspace_version}  level=DEBUG  console=${TRUE}
    Set tags  Online workspace version = ${workspace_version}
    [Return]  ${workspace_version}

Clean up directory
    [Documentation]
    ...  KW for removing files older than certain time
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                                      |
    ...  | clean_directory | Yes  | Absolute path to directory that needs to be  cleaned             |
    ...  | older_than_min  | Yes  | Time from where file needs to be deleted                         |
    ...  | alias           | Yes  | Alias used via taf.sbts.oam.coam.admin library (Slave or Master) |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description             |
    ...  | result        | Folder cleanup resul    |

    [Arguments]  ${clean_directory}  ${older_than_min}  ${alias}=local  &{configuration}
    Log  Removing files older than ${older_than_min} min from "${clean_directory}" on ${alias}  level=INFO  console=${TRUE}
    ${command}=  Set Variable
    ...  if [ "$(ls -A ${clean_directory})" ]; then find ${clean_directory}/* -maxdepth 0 -mmin +${older_than_min} -exec sudo rm -rf {} \\; ; fi
    ${cleaning_rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command  ${command}  ELSE
    ...  Execute Remote Command  ${command}  ${alias}  &{configuration}
    ${result}=  Run Keyword And Return Status  Should Be Equal
    ...  ${cleaning_rc}  ${0}  msg=RC of operation clean "${clean_directory}" on ${alias} is not equal 0
    run keyword if  ${result}
    ...  Log  "${clean_directory}" on ${alias} cleaned  level=INFO  console=${TRUE}  ELSE
    ...  Log   Failed to clean "${clean_directory}" on ${alias}  level=INFO  console=${TRUE}
    [Return]  ${result}

Clean up directory windows
    [Documentation]
    ...  KW for removing files older than certain time from Windows PC
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                                      |
    ...  | clean_directory | Yes  | Absolute path to directory that needs to be  cleaned             |
    ...  | older_than_min  | Yes  | Time from where file needs to be deleted                         |
    ...  | alias           | Yes  | Alias used via taf.sbts.oam.coam.admin library (Slave or Master) |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description             |
    ...  | result        | Folder cleanup resul    |

    [Arguments]  ${clean_directory}  ${older_than_min}  ${alias}=local  &{configuration}
    Log  Removing files older than ${older_than_min} min from "${clean_directory}" on ${alias}  level=INFO  console=${TRUE}
    ${command}=  Set Variable
    ...  if [ "$(ls -A ${clean_directory})" ]; then /bin/find ${clean_directory}/* -maxdepth 0 -mmin +${older_than_min} -exec rm -rf {} \\; ; fi
    ${cleaning_rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command  ${command}  ELSE
    ...  Execute Remote Command  ${command}  ${alias}  &{configuration}
    ${result}=  Run Keyword And Return Status  Should Be Equal
    ...  ${cleaning_rc}  ${0}  msg=RC of operation clean "${clean_directory}" on ${alias} is not equal 0
    run keyword if  ${result}
    ...  Log  "${clean_directory}" on ${alias} cleaned  level=INFO  console=${TRUE}  ELSE
    ...  Log  Failed to clean "${clean_directory}" on ${alias}, probably it's already cleaned!  level=INFO  console=${TRUE}
    [Return]  ${result}

Execute Local Command
    [Documentation]
    ...   Executing command on local host
    ...  *AUTHOR* radu.andronache@nokia.com

    [Arguments]  ${command}
    ${command_rc}=  Run And Return Rc  ${command}
    [Return]  ${command_rc}

Execute Remote Command
    [Documentation]
    ...   Executing command via ssh on remote host
    ...  *AUTHOR* radu.andronache@nokia.com

    [Arguments]  ${command}  ${index_or_alias}  &{configuration}
    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${command_rc}=  SSHLibrary.Execute Command  ${command}  return_stdout=False  return_rc=True
    [Teardown]  _Remote Command Teardown
    [Return]  ${command_rc}

_Remote Command Setup
    [Documentation]
    ...   Ssh conection opening and login
    ...  *AUTHOR* radu.andronache@nokia.com

    [Arguments]  ${index_or_alias}  &{configuration}
    ${check_connection}=  SSHLibrary.Get Connection  ${index_or_alias}
    Run Keyword If  ${check_connection.index}
    ...  SSHLibrary.Switch Connection  ${index_or_alias}  ELSE
    ...  SSHLibrary.Open Connection  host=${configuration["host_ip"]}  port=${configuration["ssh_port"]}
    _SSHLibrary_Login_multiway  ${configuration["ssh_username"]}  ${configuration["ssh_password"]}

_SSHLibrary_Login_multiway
    [Documentation]
    ...   KW allows ssh login via user & pass and via public key
    ...  *AUTHOR* radu.andronache@nokia.com

    [Arguments]  ${username}  ${password}
    ${status}=  Run keyword and return status  SSHLibrary.Login  ${username}  ${password}
    Return from keyword if  ${status}
    ${status}=  Run keyword and return status  SSHLibrary.Login with public key  ${username}
    ...  /home/${username}/.ssh/id_rsa
    Run Keyword If  not ${status}  Fail  Remote connection unavailable

_Remote Command Teardown
    [Documentation]
    ...   Ssh conection close
    ...  *AUTHOR* radu.andronache@nokia.com

    SSHLibrary.Close Connection

Create dirs for logs
    [Documentation]
    ...  *AUTHOR* sebastian.burniak@nokia.com
    Create 'Test Results Dir' and Set Test Variable
    Create 'BTSFiles' in '${Test Results Dir}' And Set Test Variable
    Create 'TestFiles' in '${Test Results Dir}' And Set Test Variable
    Create 'UDPLogs' in '${Test Results Dir}' And Set Test Variable
    Create Temp Logs Dir And Set Test Variable

Create Temp Logs Dir And Set Test Variable
    [Documentation]
    ...   Log directories are created during Common Test Setup
    ...  *AUTHOR* radu.andronache@nokia.com

    ${test_timestamp}=  OperatingSystem.Run  date +%F_%H-%M-%S
    ${TEST NAME WITHOUT BRACKETS}=  Replace String Using Regexp  ${TEST NAME}  \\[|\\]|\\s  _
    ${joined_path}=  OperatingSystem.Join Path  ${TEMP_LOGS_DIR}  ${test_timestamp}_TEST-${TEST NAME WITHOUT BRACKETS}
    Set Test Variable  ${TEMP_LOGS_DIR}  ${joined_path}
    ${remote_command}=  Set Variable  mkdir -p "${TEMP_LOGS_DIR}"
    FOR  ${alias}  IN  @{alias_list}
         ${result_rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
         ...  Create Directory  ${TEMP_LOGS_DIR}
         ...  ELSE
         ...  Execute Remote Command  command=${remote_command}  index_or_alias=remote
         ...  host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]
         ...  ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
         Run Keyword If  '${result_rc}' == '0' or '${result_rc}' == '${None}'
         ...  Log  Temp logs Dir created: ${TEMP_LOGS_DIR} on ${alias}  level=DEBUG
         ...  ELSE
         ...  Log  Failed to create Temp logs Dir: ${TEMP_LOGS_DIR} on ${alias}  level=WARN
    END

Hran_ta Preconditions
    [Documentation]
    ...   Preconditions executed before start of Common Test Setup
    ...  *AUTHOR* radu.andronache@nokia.com

    Log  Common Test Setup  level=INFO  console=${TRUE}
    Get Workspace Version
    Create Dirs For Logs
    Set TC Verdict Variables

Hran_ta Postconditions
    [Documentation]
    ...   Postonditions executed before end of Common Test Teardown
    ...  *AUTHOR* radu.andronache@nokia.com

    Log  End of Common Test Teardown  level=INFO  console=${TRUE}

Set TC Verdict Variables
    [Documentation]
    ...  Initialize all variables used to determine TC verdict at the end of TC execution
    ...  *AUTHOR* radu.andronache@nokia.com

    Set Test Variable  ${PreconditionMandatoryParametersDefined}  ${TRUE}
    Set Test Variable  ${PreconditionBTSConf}  ${TRUE}
    Set Test Variable  ${PreconditionCellsOnAir}  ${TRUE}
    Set Test Variable  ${PreconditionModulesWorking}  ${TRUE}
    Set Test Variable  ${PreconditionNoActiveAlarms}  ${TRUE}
    Set Test Variable  ${TcPreconditionPassed}  ${TRUE}

Check remote VM required disk space
    [Documentation]
    ...  Copy of KW 'There should be at least ${this much} MB of disk space available in ${directory}' adapted to run on
    ...  remote machine via SSH protocol and also drop of hran_verdict library usage.
    ...
    ...  *INPUT*
    ...  | Parameter     | Mandatory | Description                         |
    ...  | space_amount  | Yes       | Minimum expected free space in MB   |
    ...  | dir_path      | Yes       | Directory (or file) path to verify  |
    ...  | host_ip       | Yes       | IP address of host machine          |
    ...  | ssh_port      | Yes       | Port for SSH connection             |
    ...  | ssh_username  | Yes       | Username for log in to host via SSH |
    ...  | ssh_password  | Yes       | Password for log in to host via SSH |

    [Arguments]  ${dir_path}  ${space_amount}  ${host_ip}  ${ssh_port}  ${ssh_username}  ${ssh_password}
    SSHLibrary.Open Connection  host=${host_ip}  port=${ssh_port}
    _SSHLibrary_Login_multiway  ${ssh_username}  ${ssh_password}
    SSHLibrary.Execute Command  echo "[$(date -u)] - ${TEST NAME} \n $(df -h) \n" >> ${DF LOG PATH}  return_stdout=False  return_rc=True
    ${exists}  ${message}=  Run Keyword And Ignore Error  SSHLibrary.Directory Should Exist  ${dir_path}
    Run Keyword If  "${exists}" == "FAIL"  Run Keywords  Log  ${message}  level=WARN  AND  Return From Keyword
    ${available space}=  SSHLibrary.Execute Command  df -BM --output=avail ${dir_path} | sed 1d | sed -e 's/M//'
    Run Keyword If  ${available space} < ${space_amount}
    ...  Fail  ${available space}MB available in ${dir_path} is less than required ${space_amount}MB
    [Teardown]  SSHLibrary.Close Connection

Check local VM required disk space
    [Documentation]
    ...  Checks if there is a minimal required available disk space in given directory, sets test as norun if not
    ...  and skips to test teardown. Also dumps `df` output as log from test for future reference and also drop of
    ...  hran_verdict library usage.
    ...
    ...  *INPUT*
    ...  | Parameter        | Mandatory | Description                                   |
    ...  | this much        | Yes       | Minimum expected free space in MB             |
    ...  | directory        | Yes       | Directory (or file) path to verify            |
    ...
    ...  *RETURN*  None

    [Arguments]  ${dir_path}  ${space_amount}

    Run  echo "[$(date -u)] - ${TEST NAME} \n $(df -h) \n" >> ${DF LOG PATH}
    ${exists}  ${message}=  Run Keyword And Ignore Error  Should Exist  ${dir_path}
    Run Keyword If  "${exists}" == "FAIL"  Run Keywords  Log  ${message}  level=WARN  AND  Return From Keyword
    ${available space}=  Run  df -BM --output=avail ${dir_path} | sed 1d | sed -e 's/M//'
    Run Keyword If  ${available space} < ${space_amount}
    ...  Fail  ${available space}MB available in ${dir_path} is less than required ${space_amount}MB

Get BTS Running RM SW info dict
    [Documentation]
    ...  Keyword providing RM SW info dict from BTS
    ...
    ...  | Parameter | Man. | Description             |
    ...  | alias     | Yes  | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                        | Description                            |
    ...  | serialNumber_buildVersion_dict   | RMOD serial number buildVersion dict   |

    [Arguments]  ${alias}

    ${serialNumber_buildVersion_dict}=  Create Dictionary
    ${RM_list}=  Get Ids For All  class_name=RMOD  connection=${alias}
    Sort List  ${RM_list}
    FOR  ${item}  IN  @{RM_list}
        ${RM_param}=  Get Parameters For  class_name=RMOD  id_num=${item}  connection=${alias}
        Set To Dictionary  ${serialNumber_buildVersion_dict}  ${RM_param.serialNumber}  ${RM_param.buildVersion}
    END

    [Return]  ${serialNumber_buildVersion_dict}

Get actRatResetEnhancement from SCF
    [Documentation]
    ...  Keyword providing actRatResetEnhancement value from SCF.
    ...
    ...  *AUTHOR*
    ...  anca.tatar@nokia.com
    ...
    ...  | Parameter | Man. | Description          |
    ...  | scf_path  | No   | scf path             |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description     |
    ...  | actRatResetEnhancement | parameter value |
    ...
    [Arguments]  ${scf_path}=${EMPTY}  ${alias}=default

    ${scf_path}=  Set Variable If  '${scf_path}' == '${EMPTY}'  ${${alias.lower()}_scf_initial}  ${scf_path}
    OperatingSystem.File Should Exist  ${scf_path}
    ${actRatResetEnhancement_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  alias=${alias}
    ${actRatResetEnhancement_dn}=  Get From List  ${actRatResetEnhancement_dn_list}  0

    ${actRatResetEnhancement}=  Check Parameter value from SCF  item_dist_name=${actRatResetEnhancement_dn}
    ...  parameter_to_check=actRatResetEnhancement  scf_path=${scf_path}

    [Return]  ${actRatResetEnhancement}

Set HWF Flags
    [Documentation]
    ...  Set requested HWF flags in swconfig.txt:
    ...  - 0x190030 (OAM_DBG_EnableHwfLoading) till SBTS00_ENB_9999_211214_000014 or on maintenance branches till SBTS22R1
    ...  - 0x4F0214 (ERadLteHas_BB_PERIPHERIES_EnableHwfLoading) from SBTS00_ENB_9999_211214_000014 (current trunk use)
    ...
    ...  *INPUT*
    ...  | Parameter            | Mandatory | Description                                                                    |
    ...  | swconfig_flag_action | Yes       | possible values: add or remove                                                 |
    ...  | swconfig_flag_list   | Yes       | list of flags to add/remove from swconfig                                      |
    ...  | alias                | Yes       | admin instance alias                                                           |
    ...  | username             | No        | username for ssh connection                                                    |
    ...  | password             | No        | password for ssh connection                                                    |
    ...  | keypath              | No        | key location for ssh connection                                                |
    ...  | folder_path          | No        | folder path where SM running swconfig.txt file will be saved for set HWF flags |
    ...
    [Arguments]  ${swconfig_flag_action}  ${swconfig_flag_list}  ${alias}  ${username}=ute  ${password}=ute  ${keypath}=/home/ute/.ssh/id_rsa
    ...  ${folder_path}=/tmp

    Log  Set requested HWF flags in swconfig.txt on ${alias} BTS  console=True
    ${flags_list}=  Create List
    ${flags_list}=  Split String  ${swconfig_flag_list}

    Change HWF Flags  action=${swconfig_flag_action}  flags=${flags_list}  alias=${alias}  username=${username}  password=${password}
    ...  key_path=${keypath}  folder_path=${folder_path}

Change HWF Flags
    [Documentation]
    ...  Add or remove flags from swconfig.txt

    [Arguments]  ${action}  ${flags}  ${alias}  ${username}  ${password}  ${key_path}  ${folder_path}

    ${remote_host}=  Set Variable If  '${alias}'=='Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ${ip_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]

    Save BTS File  alias=${alias}  BTS_file_names=swconfig.txt  BTS_source_paths=/ffs/run/swconfig.txt  BTS_destination_path=${folder_path}/${alias}
    ${swconfig}=  Set Variable  ${folder_path}/${alias}/swconfig.txt
    Execute Local Command  cp ${swconfig} ${folder_path}/${alias}/swconfig_initial.txt
    Set Test Variable  ${${alias}_swconfig_initial}  ${folder_path}/${alias}/swconfig_initial.txt

    ${HWF_reset_needed}=  Run Keyword If  '${action}' == 'add'
    ...  Add HWF Flags  swconfig=${swconfig}  flags=${flags}
    ...  ELSE IF  '${action}' == 'remove'
    ...  Remove HWF Flags  swconfig=${swconfig}  flags=${flags}

    Set Test Variable  ${${alias}_HWF_reset_needed}  ${HWF_reset_needed}
    Return From Keyword If  not ${HWF_reset_needed}

    ${swconfig_content}=  OperatingSystem.Get File  ${swconfig}
    Execute Command on SM via SSH TAF  command=cd /ffs/run ; echo "${swconfig_content}" > swconfig.txt ; crasign swconfig.txt  via_ip=${remote_host}
    ...  via_username=${username}  via_password=${password}  key_path=${key_path}  alias=${alias}_ssh

    ${hwf_change_reset}=  Run Keyword And Return Status  Reset BTS for HWF Flags change  ${remote_host}  ${ip_address}  ${alias}

    Save BTS File  alias=${alias}  BTS_file_names=swconfig.txt  BTS_source_paths=/ffs/run/swconfig.txt  BTS_destination_path=${folder_path}/${alias}
    ${swconfig}=  Set Variable  ${folder_path}/${alias}/swconfig.txt
    Execute Local Command  cp ${swconfig} ${BTSFiles}/${alias}/swconfig_HWF_change.txt

    Run Keyword If  ${hwf_change_reset} != True  Fail  BTS reset failed (for HWF change)!

Reset BTS for HWF Flags change
    [Arguments]  ${remote_host}  ${ip_address}  ${alias}

    Log  Performing Site Reset in order to activate swconfig.txt changes  console=True
    coam.Reset  reset_coverage=Site  wait_for_reconnection=False  alias=${alias}
    Wait For Target To Be Not Reachable TAF  hostname=${ip_address}  remote_host=${remote_host}  timeout=300
    Wait For Target To Be Reachable TAF  hostname=${ip_address}  remote_host=${remote_host}  timeout=300
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias}
    Check cells availability status online  ${alias}  600

Add HWF Flags
    [Arguments]  ${swconfig}  ${flags}

    ${HWF_reset_needed}=  Set Variable  ${False}
    ${swconfig_content}=  OperatingSystem.Get File  ${swconfig}

    FOR  ${flag}  IN  @{flags}

        ${flag_0_status}=  Get Lines Matching Regexp  ${swconfig_content}  ^${flag}.*=.*0
        ${flag_0_count}=  Get Line Count  ${flag_0_status}
        Run Keyword If  ${flag_0_count} > 1  Run Keywords
        ...  Log  Multiple flags ${flag} set on 0 found in swconfig.txt  level=ERROR
        ...  AND  Fail  Multiple flags ${flag} set on 0 found in swconfig.txt

        Continue For Loop If  ${flag_0_count} != 0

        ${flag_1_status}=  Get Lines Matching Regexp  ${swconfig_content}  ^${flag}.*=.*1
        ${flag_1_count}=  Get Line Count  ${flag_1_status}
        Run Keyword If  ${flag_1_count} > 1  Run Keywords
        ...  Log  Multiple flags ${flag} set on 1 found in swconfig.txt  level=ERROR
        ...  AND  Fail  Multiple flags ${flag} set on 1 found in swconfig.txt

        ${swconfig_content}=  Run Keyword If  ${flag_1_count} != 0
        ...  Replace String Using Regexp  ${swconfig_content}  ${flag}.*=.*1  ${flag}=0
        ...  ELSE
        ...  Set Variable  ${swconfig_content}

        Run Keyword If  ${flag_1_count} != 0
        ...  Execute Local Command  echo "${swconfig_content}" > ${swconfig}
        ...  ELSE IF  ${flag_1_count} == 0
        ...  Execute Local Command  echo ${flag}=0 >> ${swconfig}

        Run And Return Rc And Output  cat ${swconfig}
        ${HWF_reset_needed}=  Set Variable  ${True}

        Log  Adding ${flag}=0 flag to swconfig.txt  console=True

    END

    [Return]  ${HWF_reset_needed}

Remove HWF Flags
    [Arguments]  ${swconfig}  ${flags}

    ${HWF_reset_needed}=  Set Variable  ${False}
    ${swconfig_content}=  OperatingSystem.Get File  ${swconfig}

    FOR  ${flag}  IN  @{flags}

        ${flag_0_status}=  Get Lines Matching Regexp  ${swconfig_content}  ^${flag}.*=.*0
        ${flag_0_count}=  Get Line Count  ${flag_0_status}
        Run Keyword If  ${flag_0_count} > 1  Run Keywords
        ...  Log  Multiple flags ${flag} set on 0 found in swconfig.txt  level=ERROR
        ...  AND  Fail  Multiple flags ${flag} set on 0 found in swconfig.txt

        ${flag_1_status}=  Get Lines Matching Regexp  ${swconfig_content}  ^${flag}.*=.*1
        ${flag_1_count}=  Get Line Count  ${flag_1_status}
        Run Keyword If  ${flag_1_count} > 1  Run Keywords
        ...  Log  Multiple flags ${flag} set on 1 found in swconfig.txt  level=ERROR
        ...  AND  Fail  Multiple flags ${flag} set on 1 found in swconfig.txt

        Continue For Loop If  ${flag_1_count} != 0 or (${flag_0_count} == 0 and ${flag_1_count} == 0)

        ${swconfig_content}=  Run Keyword If  ${flag_0_count} != 0
        ...  Remove String Using Regexp  ${swconfig_content}  ${flag}.*=.*0
        ...  ELSE
        ...  Set Variable  ${swconfig_content}

        Execute Local Command  echo "${swconfig_content}" > ${swconfig}

        Run And Return Rc And Output  cat ${swconfig}
        ${HWF_reset_needed}=  Set Variable  ${True}

        Log  Removing ${flag}=0 flag from swconfig.txt  console=True

    END

    [Return]  ${HWF_reset_needed}

Recover HWF Flags
    [Arguments]  ${alias}  ${username}=ute  ${password}=ute  ${keypath}=/home/ute/.ssh/id_rsa  ${folder_path}=/tmp

    ${variable_exists}=  Get Variable Value  ${${alias}_HWF_reset_needed}  None
    Return From Keyword If  not ${variable_exists}

    Log  Recover initial swconfig.txt on ${alias} BTS  console=True

    ${remote_host}=  Set Variable If  '${alias}'=='Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ${ip_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]

    ${swconfig_initial_content}=  OperatingSystem.Get File  ${${alias}_swconfig_initial}
    Execute Command on SM via SSH TAF  command=cd /ffs/run ; echo "${swconfig_initial_content}" > swconfig.txt ; crasign swconfig.txt
    ...  via_ip=${remote_host}  via_username=${username}  via_password=${password}  key_path=${key_path}  alias=${alias}_ssh

    Log  Performing Site Reset in order to recover initial swconfig.txt  console=True
    coam.Reset  reset_coverage=Site  wait_for_reconnection=False  alias=${alias}
    Wait For Target To Be Not Reachable TAF  hostname=${ip_address}  remote_host=${remote_host}  timeout=300
    Wait For Target To Be Reachable TAF  hostname=${ip_address}  remote_host=${remote_host}  timeout=300
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias}
    Check cells availability status online  ${alias}  600

    Save BTS File  alias=${alias}  BTS_file_names=swconfig.txt  BTS_source_paths=/ffs/run/swconfig.txt  BTS_destination_path=${folder_path}/${alias}
    ${swconfig}=  Set Variable  ${folder_path}/${alias}/swconfig.txt
    Execute Local Command  cp ${swconfig} ${BTSFiles}/${alias}/swconfig_HWF_recover.txt

Get baseband pool allocation mode info from SCF
    [Documentation]
    ...  Helper keyword providing baseband pool allocation mode info from SCF.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description          |
    ...  | scf_path  | No   | scf path             |
    ...  | alias     | No   | admin instance alias |
    ...
    ...  *RETURN*
    ...  | Parameter                    | Description     |
    ...  | CELL_dn_bbPoolAllocMode_dict | Dict containing structure: {'CELL_dn': 'bbPoolAllocMode'} |
    ...
    [Arguments]  ${scf_path}=${EMPTY}  ${alias}=default

    ${CELL_dn_bbPoolAllocMode_dict}=  Create Dictionary

    ${BTS_scf}=  Run Keyword If  '${scf_path}' == '${EMPTY}'  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ...  export_type=configurationAndRuntimeObjects
    ...  ELSE
    ...  Set Variable  ${scf_path}

    ${BBPOOLALLOC_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/BBPOOLALLOC-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${BBPOOLALLOC_dn_count}=  Get Length  ${BBPOOLALLOC_dn_list}

    Return From Keyword If  ${BBPOOLALLOC_dn_count} == 0  ${CELL_dn_bbPoolAllocMode_dict}

    FOR  ${item}  IN  @{BBPOOLALLOC_dn_list}

        ${CELL_dn}=  Fetch From Left  ${item}  /BBPOOLALLOC

        ${bbPoolAllocMode}=  Check Parameter value from SCF  item_dist_name=${item}  parameter_to_check=bbPoolAllocMode  scf_path=${BTS_scf}

        Set To Dictionary  ${CELL_dn_bbPoolAllocMode_dict}  ${CELL_dn}  ${bbPoolAllocMode}

        Log  BTS ${alias} ${CELL_dn} - bbPoolAllocMode: ${bbPoolAllocMode}  console=True

    END

    [Return]  ${CELL_dn_bbPoolAllocMode_dict}

Check and set KPI verdict
    [Documentation]
    ...  KW compares measured and threshold KPI values. If measured KPI exceeds threshold KPI value a warning will be raised and snapshot will be
    ...  triggered
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter     | Man. | Description         |
    ...  | kpi_name      | Yes  | KPI name            |
    ...  | kpi_measured  | Yes  | KPI measured value  |
    ...  | kpi_threshold | Yes  | KPI threshold value |
    ...
    [Arguments]  ${kpi_name}  ${kpi_measured}  ${kpi_threshold}

    Log  Check KPI ${kpi_name} value with KPI ${kpi_name} threshold:  console=True

    Run Keyword If  ${kpi_measured} <= ${kpi_threshold}
    ...  Log  - KPI ${kpi_name} value: ${kpi_measured} secs in range of KPI ${kpi_name} threshold: ${kpi_threshold}  console=True
    ...  ELSE  Run Keywords
    ...  Set KPI Check Level Based on Execution Environment  ${kpi_threshold}
    ...  AND  Set Test Variable  ${SnapshotTriggerEndTest}  YES

Check BTS cells are enabled online with exceptions
    [Documentation]
    ...  Keyword checking if all cloud/classical BTS cells excepting those defined in specific arguments are found with:
    ...  - operational state: enabled
    ...  - availability status: online
    ...  If cells specific arguments are empty, then no exceptions will be taken into account to check above states; otherwise, defined cells in
    ...  specific arguments will be exempted from above checks
    ...
    [Arguments]  ${NR_cell_info_exempted}=&{EMPTY}  ${LTE_cell_info_exempted}=&{EMPTY}  ${WCDMA_cell_info_exempted}=&{EMPTY}
    ...  ${GSM_cell_info_exempted}=&{EMPTY}  ${timeout}=5

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        ...  Check cloud BTS cells are enabled online  NR_cell_info_exempted=${NR_cell_info_exempted}  alias=${alias}  timeout=${timeout}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']
        ...  Check classical BTS cells are enabled online  NR_cell_info_exempted=${NR_cell_info_exempted}
        ...  LTE_cell_info_exempted=${LTE_cell_info_exempted}  WCDMA_cell_info_exempted=${WCDMA_cell_info_exempted}
        ...  GSM_cell_info_exempted=${GSM_cell_info_exempted}  alias=${alias}  timeout=${timeout}

    END

Check cloud BTS cells are enabled online
    [Documentation]
    ...  Keyword checking if cloud BTS VDU cells excepting those defined in specific argument are found with:
    ...  - operational state: enabled
    ...  - availability status: online
    ...
    [Arguments]  ${NR_cell_info_exempted}=&{EMPTY}  ${alias}=Master  ${timeout}=5

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_CELL_id_config_dn_dict}=  VDU Get Cells id config info  vdu_connection=${vdu_alias}
        ${VDU_CELL_id_list}=  Get Dictionary Keys  ${VDU_CELL_id_config_dn_dict}

        Run Keyword If  ${VDU_CELL_id_list}  Check cloud BTS VDU cells are enabled online
        ...  vdu_cell_list=${VDU_CELL_id_list}  vdu_cell_info_exempted=${NR_cell_info_exempted}  vdu_alias=${vdu_alias}  timeout=${timeout}

    END

Check cloud BTS VDU cells are enabled online
    [Arguments]  ${vdu_cell_list}  ${vdu_cell_info_exempted}  ${vdu_alias}  ${timeout}

    ${BTS_alias_NR_cell_exempted}=  Get Dictionary Keys  ${vdu_cell_info_exempted}

    FOR  ${item}  IN  @{vdu_cell_list}

       ${exempted_cell_status}=  Check Exempted Cell Info  ${item}  ${vdu_cell_info_exempted}  ${vdu_alias}
       Continue For Loop If  '${exempted_cell_status}' == 'True'

       Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check Cell Expected Status  cell_id=${item}  operational_state=${CBTS_Enabled_}
       ...  availability_status=${CBTS_Online_}  administrative_state==${CBTS_Unlocked_}  blocking_state=${CBTS_Unblocked_}
       ...  vdu_connection=${vdu_alias}

    END

Check classical BTS cells are enabled online
    [Documentation]
    ...  Keyword checking if classical BTS all RAT cells excepting those defined in specific arguments are found with:
    ...  - operational state: enabled
    ...  - availability status: online
    ...
    [Arguments]  ${NR_cell_info_exempted}=&{EMPTY}  ${LTE_cell_info_exempted}=&{EMPTY}  ${WCDMA_cell_info_exempted}=&{EMPTY}
    ...  ${GSM_cell_info_exempted}=&{EMPTY}  ${alias}=Master  ${timeout}=5

    ${BTS_NR_cell_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    Run Keyword If  ${BTS_NR_cell_list}  Check classical BTS RAT cells are enabled online
    ...  class_name=NRCEL  cell_list=${BTS_NR_cell_list}  cell_info_exempted=${NR_cell_info_exempted}  alias=${alias}  timeout=${timeout}

    ${BTS_LTE_cell_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    Run Keyword If  ${BTS_LTE_cell_list}  Check classical BTS RAT cells are enabled online
    ...  class_name=LNCEL  cell_list=${BTS_LTE_cell_list}  cell_info_exempted=${LTE_cell_info_exempted}  alias=${alias}  timeout=${timeout}

    ${BTS_WCDMA_cell_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    Run Keyword If  ${BTS_WCDMA_cell_list}  Check classical BTS RAT cells are enabled online
    ...  class_name=WNCEL  cell_list=${BTS_WCDMA_cell_list}  cell_info_exempted=${WCDMA_cell_info_exempted}  alias=${alias}  timeout=${timeout}

    ${BTS_GSM_cell_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Run Keyword If  ${BTS_GSM_cell_list}  Check classical BTS RAT cells are enabled online
    ...  class_name=GNCEL  cell_list=${BTS_GSM_cell_list}  cell_info_exempted=${GSM_cell_info_exempted}  alias=${alias}  timeout=${timeout}

Check classical BTS RAT cells are enabled online
    [Arguments]  ${class_name}  ${cell_list}  ${cell_info_exempted}  ${alias}  ${timeout}

    ${CELL_status_enabled_check}=  Set Variable  operationalState=${Enabled_}
    ${CELL_status_enabled_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}

    FOR  ${item}  IN  @{cell_list}

       ${exempted_cell_status}=  Check Exempted Cell Info  ${item}  ${cell_info_exempted}  ${alias}
       Continue For Loop If  '${exempted_cell_status}' == 'True'

       Assert  class_name=${class_name}  id=${item}  parameters=${CELL_status_enabled_check}  timeout=${timeout}  connection=${alias}
       ${cell_degraded}=  Run Keyword And Return Status  Assert  class_name=${class_name}  id=${item}
       ...  parameters=${CELL_status_enabled_degraded_check}  timeout=1  connection=${alias}

       Run Keyword If  ${cell_degraded}
       ...  FAIL  BTS ${alias} ${class_name} ${item} status:\n - operationalState=Enabled, availabilityStatus=Degraded

    END

Check Exempted Cell Info
    [Arguments]  ${cell_id}  ${cell_info_exempted}  ${alias}

    ${exempted_cell_status}=  Set Variable  False
    ${alias_cell_exempted}=  Get Dictionary Keys  ${cell_info_exempted}

    FOR  ${item}  IN  @{alias_cell_exempted}

       ${cell_list_exempted}=  Get From Dictionary  ${cell_info_exempted}  ${item}

       Return From Keyword If  '${cell_id}' in ${cell_list_exempted} and '${item}' == '${alias}'  True

    END

    [Return]  ${exempted_cell_status}

Get feature CB007447 info
    [Documentation]
    ...  Get feature CB007447 info
    ...
    ...  *AUTHOR*
    ...  anca.tatar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | actCpriLinkRecovery           | parameter value: true or false              |
    ...  | actSyncLinkSwitchover         | parameter value: true or false              |
    ...  | cpriSyncBreakTime             | parameter value: <time value> in ms or none |
    ...  | stickToSyncSourcePeriod       | parameter value: <time value> in ms or none |

    [Arguments]  ${alias}

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0

	${actCpriLinkRecovery}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}
	...  parameter_to_check=actCpriLinkRecovery  scf_path=${scf_path}

	${actSyncLinkSwitchover}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}
	...  parameter_to_check=actSyncLinkSwitchover  scf_path=${scf_path}

	${dn_list_1}=  Get All Dist Names By Pattern from SCF  pattern=/MNLENT-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn_1}=  Get From List  ${dn_list_1}  0

	${cpriSyncBreakTime}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn_1}
    ...  parameter_to_check=cpriSyncBreakTime  scf_path=${scf_path}

	${stickToSyncSourcePeriod}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn_1}
    ...  parameter_to_check=stickToSyncSourcePeriod  scf_path=${scf_path}

    ${actCpriLinkRecovery}=  Convert to String  ${actCpriLinkRecovery}
    ${actCpriLinkRecovery}=  Convert To Lower Case  ${actCpriLinkRecovery}

    ${actSyncLinkSwitchover}=  Convert to String  ${actSyncLinkSwitchover}
    ${actSyncLinkSwitchover}=  Convert To Lower Case  ${actSyncLinkSwitchover}

    ${cpriSyncBreakTime}=  Convert To String  ${cpriSyncBreakTime}
    ${cpriSyncBreakTime}=  Convert To Lower Case  ${cpriSyncBreakTime}

    ${stickToSyncSourcePeriod}=  Convert To String  ${stickToSyncSourcePeriod}
    ${stickToSyncSourcePeriod}=  Convert To Lower Case  ${stickToSyncSourcePeriod}

    [Return]  ${actCpriLinkRecovery}  ${actSyncLinkSwitchover}  ${cpriSyncBreakTime}  ${stickToSyncSourcePeriod}

Set feature CB007447 on BTS
    [Documentation]
    ...  Activate feature CB007447 on BTS
    ...
    ...  *AUTHOR*
    ...  anca.tatar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                     | Man. | Description                                 |
    ...  | alias                         | Yes  | admin instance alias                        |
    ...  | actCpriLinkRecovery           | No   | parameter value: true or false              |
    ...  | actSyncLinkSwitchover         | No   | parameter value: true or false              |
    ...  | cpriSyncBreakTime             | Yes  | parameter value: <time value> in ms         |
    ...  | stickToSyncSourcePeriod       | Yes  | parameter value: <time value> in ms or none |

    [Arguments]  ${actCpriLinkRecovery_value}=true  ${actSyncLinkSwitchover_value}=true  ${cpriSyncBreakTime_value}=${EMPTY}
    ...  ${stickToSyncSourcePeriod_value}=${EMPTY}  ${alias}=default

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0

    ${dn_list_1}=  Get All Dist Names By Pattern from SCF  pattern=/MNLENT-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn_1}=  Get From List  ${dn_list_1}  0

    ${actCpriLinkRecovery}  ${actSyncLinkSwitchover}  ${cpriSyncBreakTime}  ${stickToSyncSourcePeriod}=  Get feature CB007447 info  ${alias}

    Run Keyword If  '${cpriSyncBreakTime}' == '${cpriSyncBreakTime_value}'
    ...  Log  Parameter cpriSyncBreakTime: ${cpriSyncBreakTime} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn_1}  parameter=cpriSyncBreakTime  operation=update
    ...  value=${cpriSyncBreakTime_value}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

    Run Keyword If  '${actSyncLinkSwitchover_value}' == 'false'  Run Keywords
    ...  Set feature CB007447 custom on BTS  ${BTS_SCF_dn}  ${BTS_SCF_dn_1}  ${actCpriLinkRecovery_value}  ${actCpriLinkRecovery}   ${alias}
    ...  AND  Return From Keyword

    Run Keyword If  '${actCpriLinkRecovery}' == '${actCpriLinkRecovery_value}'
    ...  Log  Parameter actCpriLinkRecovery: ${actCpriLinkRecovery} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=actCpriLinkRecovery  operation=update
    ...  value=${actCpriLinkRecovery_value}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

    Run Keyword If  '${actSyncLinkSwitchover}' == '${actSyncLinkSwitchover_value}'
    ...  Log  Parameter actSyncLinkSwitchover: ${actSyncLinkSwitchover} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=actSyncLinkSwitchover  operation=update
    ...  value=${actSyncLinkSwitchover_value}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

    ${operation}=  Set Variable If  '${stickToSyncSourcePeriod_value}' == 'none'  delete  update
    Run Keyword If  '${stickToSyncSourcePeriod}' == '${stickToSyncSourcePeriod_value}'
    ...  Log  Parameter stickToSyncSourcePeriod: ${stickToSyncSourcePeriod} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn_1}  parameter=stickToSyncSourcePeriod  operation=${operation}
    ...  value=${stickToSyncSourcePeriod_value}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

Set feature CB007447 custom on BTS
    [Arguments]   ${scf_dn1}  ${scf_dn2}  ${actCpriLinkRecovery_value}   ${actCpriLinkRecovery_current_value}  ${alias}

    coam.Perform Parameter Recommissioning  dist_name=${scf_dn2}  parameter=stickToSyncSourcePeriod  operation=delete
    ...  value=none  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    coam.Perform Parameter Recommissioning  dist_name=${scf_dn1}  parameter=actSyncLinkSwitchover  operation=update
    ...  value=false  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    Run Keyword If  '${actCpriLinkRecovery_current_value}' == '${actCpriLinkRecovery_value}'
    ...  Log  Parameter actCpriLinkRecovery: ${actCpriLinkRecovery_value} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${scf_dn1}  parameter=actCpriLinkRecovery  operation=update
    ...  value=${actCpriLinkRecovery_value}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

Launch RTWP Check on Demand
    [Documentation]
    ...  Launch RTWP Check on Demand
    ...
    ...  *AUTHOR*
    ...  anca.tatar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter      | Man. | Description                                                               |
    ...  | RTWP_min       | No   | Min value for RTWP, default -108                                          |
    ...  | RTWP_max       | No   | Max value for RTWP, default -90                                           |
    ...  | alias_to_check | No   | admin instance alias                                                      |
    ...  |                |      | - if let default value: ALL, RTWP measurment will be performed on all BTS |
    ...  |                |      | - custom value: alias of desired BTS                                      |

    ...  *EXAMPLE*
    ...  | Launch RTWP Check on Demand  |
    ...  | Launch RTWP Check on Demand  | alias_to_check=Master |

    [Arguments]  ${RTWP_min}=-108  ${RTWP_max}=-90  ${alias_to_check}=ALL

    FOR  ${alias}  IN  @{alias_list}
        Run Keyword If  '${alias_to_check}' != 'ALL' and '${alias}' != '${alias_to_check}'
        ...  Continue For Loop

        Log  Check RTWP info on BTS ${alias}  console=True

        ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
        ${RMOD_L3Protocol_values}=  Get Dictionary Values  ${RMOD_L3Protocol_dict}
        ${RMOD_L3Protocol_values}=  Remove Duplicates  ${RMOD_L3Protocol_values}
        ${RMOD_L3Protocol_count}=  Get Length  ${RMOD_L3Protocol_values}
        ${ALL_RMOD_ECPRI_check}=  Set Variable If  ${RMOD_L3Protocol_count} == 1 and 'ECPRI_MPLANE' in ${RMOD_L3Protocol_values}  ${TRUE}  ${FALSE}
        Run Keyword If  ${ALL_RMOD_ECPRI_check}  Run Keywords
        ...  Log  RTWP info check will be skipped! Procedure not applicable if all ECPRI radio modules configured on BTS ${alias}  console=True
        ...  AND  Continue For Loop

        ${NRCEL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
        ${LNCEL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
        ${WNCEL_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
        Set Test Variable  ${${alias}_NRCEL_id_list}  ${NRCEL_id_list}
        Set Test Variable  ${${alias}_LNCEL_id_list}  ${LNCEL_id_list}
        Set Test Variable  ${${alias}_WNCEL_id_list}  ${WNCEL_id_list}
        ${RAT_list}=  Create List
        Run Keyword If  ${${alias}_NRCEL_id_list}  Append To List  ${RAT_list}  NR
        Run Keyword If  ${${alias}_LNCEL_id_list}  Append To List  ${RAT_list}  LTE
        Run Keyword If  ${${alias}_WNCEL_id_list}  Append To List  ${RAT_list}  WCDMA
        Set Test Variable  ${${alias}_RAT_list}  ${RAT_list}

        Run Keyword If  ${${alias}_LNCEL_id_list}  Get LTE mMIMO globalCellId list  ${alias}
        ${LTE_cell_count}=  Run Keyword If  ${${alias}_LNCEL_id_list}  Get Length  ${${alias}_LNCEL_id_list}
        ${LTE_mMIMO_cell_count}=  Run Keyword If  ${${alias}_LNCEL_id_list}  Get Length  ${${alias}_LTE_mMIMO_globalCellId_list}
        Run Keyword If  ${${alias}_LNCEL_id_list} and ${LTE_mMIMO_cell_count} == ${LTE_cell_count}
        ...  Set Test Variable  ${${alias}_ALL_LNCEL_mMIMO_check}  ${TRUE}
        ...  ELSE IF  ${${alias}_LNCEL_id_list} and ${LTE_mMIMO_cell_count} != ${LTE_cell_count}
        ...  Set Test Variable  ${${alias}_ALL_LNCEL_mMIMO_check}  ${FALSE}

        Run Keyword If  ${${alias}_LNCEL_id_list}  Get LTE HOST and IOT globalCellId list  ${alias}

        Check RTWP status on demand  ${RTWP_min}  ${RTWP_max}  ${alias}
    END

Check RTWP status on demand
    [Arguments]  ${RTWP_min}  ${RTWP_max}  ${alias}

    FOR  ${try}  IN RANGE  1  4
        ${BTS_RAT_RTWP_status_dict}=  Check RTWP status  ${RTWP_min}  ${RTWP_max}  ${alias}

        ${NR_RTWP_status}=  Run Keyword If  ${${alias}_NRCEL_id_list}  Get From Dictionary  ${BTS_RAT_RTWP_status_dict}  NR
        ${LTE_RTWP_status}=  Run Keyword If  ${${alias}_LNCEL_id_list}  Get From Dictionary  ${BTS_RAT_RTWP_status_dict}  LTE
        ${WCDMA_RTWP_status}=  Run Keyword If  ${${alias}_WNCEL_id_list}  Get From Dictionary  ${BTS_RAT_RTWP_status_dict}  WCDMA
        ${BTS_RTWP_status}=  Set Variable If
        ...  ('${NR_RTWP_status}' == 'None' and '${LTE_RTWP_status}' == 'None' and '${WCDMA_RTWP_status}' == 'None')  None
        ...  ('${NR_RTWP_status}' == 'False' or '${LTE_RTWP_status}' == 'False' or '${WCDMA_RTWP_status}' == 'False')  False  True

        Run Keyword If  '${BTS_RTWP_status}' == 'True'  Run Keywords
        ...  Log  All configured RAT RTWP info on BTS ${alias} in range [${RTWP_min} ${RTWP_max}] -> status ${BTS_RTWP_status}  console=True
        ...  AND  Exit For Loop
        ...  ELSE IF  '${BTS_RTWP_status}' == 'False' and '${try}' == '3'  Run Keywords
        ...  Log  Not all configured RAT RTWP info on BTS ${alias} in range [${RTWP_min} ${RTWP_max}] -> status ${BTS_RTWP_status}  console=True
        ...  AND  Fail  RTWP check failed after 3 tries!
    END

Get feature CB013082 info
    [Documentation]
    ...  Get feature CB013082 info
    ...
    ...  *AUTHOR*
    ...  anca.tatar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | actForceUnitAutoReset           | parameter value: true or false              |
    ...  | actRecovFromSecondaryController | parameter value: true or false              |
    ...  | actCpriLinkRecovery             | parameter value: true or false              |

    [Arguments]  ${alias}

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

	${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FMCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0

    ${actForceUnitAutoReset}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}
    ...  parameter_to_check=actForceUnitAutoReset  scf_path=${scf_path}

    ${dn_list_1}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn_1}=  Get From List  ${dn_list_1}  0

	${actRecovFromSecondaryController}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn_1}
	...  parameter_to_check=actRecovFromSecondaryController  scf_path=${scf_path}

	${actCpriLinkRecovery}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn_1}
	...  parameter_to_check=actCpriLinkRecovery  scf_path=${scf_path}

    ${actForceUnitAutoReset}=  Convert to String  ${actForceUnitAutoReset}
    ${actForceUnitAutoReset}=  Convert To Lower Case  ${actForceUnitAutoReset}

    ${actRecovFromSecondaryController}=  Convert To String  ${actRecovFromSecondaryController}
    ${actRecovFromSecondaryController}=  Convert To Lower Case  ${actRecovFromSecondaryController}

    ${actCpriLinkRecovery}=  Convert to String  ${actCpriLinkRecovery}
    ${actCpriLinkRecovery}=  Convert To Lower Case  ${actCpriLinkRecovery}

    [Return]  ${actForceUnitAutoReset}  ${actRecovFromSecondaryController}  ${actCpriLinkRecovery}

Set feature CB013082 on BTS
    [Documentation]
    ...  Activate feature CB013082 on BTS
    ...
    ...  *AUTHOR*
    ...  anca.tatar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                             | Man. | Description                                 |
    ...  | alias                                 | Yes  | admin instance alias                        |
    ...  | actForceUnitAutoReset_value           | No   | parameter value: true or false              |
    ...  | actRecovFromSecondaryController_value | No   | parameter value: true or false              |
    ...  | actCpriLinkRecovery_value             | No   | parameter value: true or false              |

    [Arguments]  ${actForceUnitAutoReset_value}=true  ${actRecovFromSecondaryController_value}=true  ${actCpriLinkRecovery_value}=false
    ...  ${alias}=default

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

	${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FMCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0

    ${dn_list_1}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn_1}=  Get From List  ${dn_list_1}  0

    ${actForceUnitAutoReset}  ${actRecovFromSecondaryController}  ${actCpriLinkRecovery}=  Get feature CB013082 info  ${alias}

    Run Keyword If  '${actForceUnitAutoReset}' == '${actForceUnitAutoReset_value}'
    ...  Log  Parameter actForceUnitAutoReset: ${actForceUnitAutoReset} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=actForceUnitAutoReset  operation=update
    ...  value=${actForceUnitAutoReset_value}  skip_parameter_relation_errors=True  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

    Run Keyword If  '${actRecovFromSecondaryController}' == '${actRecovFromSecondaryController_value}'
    ...  Log Long String  Parameter actRecovFromSecondaryController: ${actRecovFromSecondaryController} already set on BTS ${alias},
    ...  commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn_1}  parameter=actRecovFromSecondaryController  operation=update
    ...  value=${actRecovFromSecondaryController_value}  skip_parameter_relation_errors=True  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

    Run Keyword If  '${actCpriLinkRecovery}' == '${actCpriLinkRecovery_value}'
    ...  Log  Parameter actCpriLinkRecovery: ${actCpriLinkRecovery} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn_1}  parameter=actCpriLinkRecovery  operation=update
    ...  value=${actCpriLinkRecovery_value}  skip_parameter_relation_errors=True  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

Set classical BTS TRM feature parameter
    [Documentation]
    ...  Set classical BTS TRM feature parameters: actTempRadioMaster, tempRadioMasterTriggerTime or tempRadioMasterRecovTime
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Description                                                                                         |
    ...  | TRM_parameter_name  | Yes  | BTS TRM feature parameter name, one of following: actTempRadioMaster, tempRadioMasterTriggerTime or
    ...                                 tempRadioMasterRecovTime                                                                            |
    ...  | TRM_parameter_value | No   | BTS TRM feature parameter value for requested parameter name                                        |
    ...  | alias               | No   | BTS instance alias                                                                                  |
	...
	[Arguments]  ${TRM_parameter_name}  ${TRM_parameter_value}  ${alias}
    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_TRM_feature_dict}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_TRM_parameter_value}=  Get From Dictionary  ${BTS_TRM_feature_dict}  ${TRM_parameter_name}
    Run Keyword If  '${BTS_TRM_parameter_value}' == '${TRM_parameter_value}'  Run Keywords
    ...  Log  Parameter ${TRM_parameter_name} already set on ${alias} BTS: ${BTS_TRM_parameter_value}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0
    coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_FEATCADM_dn}  parameter=${TRM_parameter_name}  operation=update
    ...  value=${TRM_parameter_value}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}

    Sleep  5s

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_TRM_feature_dict}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_TRM_parameter_value}=  Get From Dictionary  ${BTS_TRM_feature_dict}  ${TRM_parameter_name}
    Run Keyword If  '${BTS_TRM_parameter_value}' == '${TRM_parameter_value}'
    ...  Log  Parameter ${TRM_parameter_name} set on ${alias} BTS: ${BTS_TRM_parameter_value}, successfully commissioning!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter ${TRM_parameter_name} not properly set on ${alias} BTS! (expected/found value:
    ...  ${TRM_parameter_value}/${BTS_TRM_parameter_value})  console=True
    ...  AND  Fail  Parameter ${TRM_parameter_name} not properly set on ${alias} BTS!

Set cloud BTS VDU TRM feature parameter
    [Documentation]
    ...  Set cloud BTS VDU TRM feature parameters: actTempRadioMaster, tempRadioMasterTriggerTime or tempRadioMasterRecovTime
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter               | Man. | Description                                                                                         |
    ...  | TRM_parameter_name      | Yes  | VDU TRM feature parameter name, one of following: actTempRadioMaster, tempRadioMasterTriggerTime or
    ...                                     tempRadioMasterRecovTime                                                                            |
    ...  | TRM_parameter_value     | Yes  | VDU TRM feature parameter value for requested parameter name                                        |
    ...  | TRM_parameter_operation | Yes  | VDU TRM feature operation for requested parameter name                                              |
    ...  | vdu_alias               | Yes  | VDU connection instance alias                                                                       |
    ...
    [Arguments]  ${TRM_parameter_name}  ${TRM_parameter_value}  ${TRM_parameter_operation}  ${vdu_alias}
    ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  vdu_connection=${vdu_alias}
    ${VDU_TRM_feature_dict}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${VDU_SCF_path_file_info}  alias=${vdu_alias}
    ${VDU_TRM_parameter_value}=  Get From Dictionary  ${VDU_TRM_feature_dict}  ${TRM_parameter_name}
    Run Keyword If  '${VDU_TRM_parameter_value}' == '${TRM_parameter_value}'  Run Keywords
    ...  Log  Parameter ${TRM_parameter_name} already set on ${vdu_alias}: ${VDU_TRM_parameter_value}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${VDU_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${VDU_SCF_path_file_info}
    ...  alias=${vdu_alias}
    ${VDU_SCF_FEATCADM_dn}=  Get From List  ${VDU_SCF_FEATCADM_list}  0
    ${mo_parameters_value_dict}=  Create Dictionary  ${TRM_parameter_name}=${TRM_parameter_value}
    ${mo_parameters_operation_dict}=  Create Dictionary  ${TRM_parameter_name}=${TRM_parameter_operation}
    Change CBTS VDU MO parameters by Delta JSON file  mo_dn=${VDU_SCF_FEATCADM_dn}  mo_operation=update
    ...  mo_parameters_value_dict=${mo_parameters_value_dict}  mo_parameters_operation_dict=${mo_parameters_operation_dict}
    ...  vdu_connection=${vdu_alias}

    Sleep  5s

    ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  vdu_connection=${vdu_alias}
    ${VDU_TRM_feature_dict}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${VDU_SCF_path_file_info}  alias=${vdu_alias}
    ${VDU_TRM_parameter_value}=  Get From Dictionary  ${VDU_TRM_feature_dict}  ${TRM_parameter_name}
    Run Keyword If  '${VDU_TRM_parameter_value}' == '${TRM_parameter_value}'
    ...  Log  Parameter ${TRM_parameter_name} set on ${vdu_alias}: ${VDU_TRM_parameter_value}, successfully commissioning!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter ${TRM_parameter_name} not properly set on ${vdu_alias}! (expected/found value:
    ...  ${TRM_parameter_value}/${VDU_TRM_parameter_value})  console=True
    ...  AND  Fail  Parameter ${TRM_parameter_name} not properly set on ${vdu_alias}!

Get BTS TRM feature parameters
    [Documentation]
    ...  Get BTS TRM feature parameters: actTempRadioMaster, tempRadioMasterTriggerTime and tempRadioMasterRecovTime
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | alias             | No   | BTS connection instance alias                                                                                 |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                                                                                  |
    ...  | BTS_TRM_feature_dict | BTS TRM feature dict containing structure: {'<TRM_parameter_name>': '<TRM_parameter_value>'} |

    [Arguments]  ${BTS_SCF_path_file}=None  ${alias}=None
    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0

    ${actTempRadioMaster_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_FEATCADM_dn}  p_name=actTempRadioMaster

    ${actTempRadioMaster_count}=  Get Length  ${actTempRadioMaster_dict}
    ${actTempRadioMaster_info}=  Run Keyword If  ${actTempRadioMaster_count} > 0
    ...  Get From Dictionary  ${actTempRadioMaster_dict}  actTempRadioMaster
    ...  ELSE
    ...  Set Variable  NA

    ${tempRadioMasterTriggerTime_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_FEATCADM_dn}  p_name=tempRadioMasterTriggerTime

    ${tempRadioMasterTriggerTime_count}=  Get Length  ${tempRadioMasterTriggerTime_dict}
    ${tempRadioMasterTriggerTime_info}=  Run Keyword If  ${tempRadioMasterTriggerTime_count} > 0
    ...  Get From Dictionary  ${tempRadioMasterTriggerTime_dict}  tempRadioMasterTriggerTime
    ...  ELSE
    ...  Set Variable  NA

    ${tempRadioMasterRecovTime_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_FEATCADM_dn}  p_name=tempRadioMasterRecovTime

    ${tempRadioMasterRecovTime_count}=  Get Length  ${tempRadioMasterRecovTime_dict}
    ${tempRadioMasterRecovTime_info}=  Run Keyword If  ${tempRadioMasterRecovTime_count} > 0
    ...  Get From Dictionary  ${tempRadioMasterRecovTime_dict}  tempRadioMasterRecovTime
    ...  ELSE
    ...  Set Variable  NA

    ${BTS_TRM_feature_dict}=  Create Dictionary  actTempRadioMaster=${actTempRadioMaster_info}
    ...  tempRadioMasterTriggerTime=${tempRadioMasterTriggerTime_info}  tempRadioMasterRecovTime=${tempRadioMasterRecovTime_info}

    [Return]  ${BTS_TRM_feature_dict}

Get BTS RF Scan feature parameters
    [Documentation]
    ...  Get BTS RF Scan feature parameters: actRfiTesting
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | alias             | No   | BTS connection instance alias                                                                                 |
    ...
    ...  *RETURN*
    ...  | Parameter                | Description                                                                                  |
    ...  | BTS_RF_Scan_feature_dict | BTS RF Scan feature dict containing structure: {'<RF_Scan_parameter_name>': '<RF_Scan_parameter_value>'} |

    [Arguments]  ${BTS_SCF_path_file}=None  ${alias}=None

    ${BTS_RF_Scan_feature_dict}=  Create Dictionary

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0

    ${actRfiTesting_status}=  Check If Parameter Exists From SCF  item_dist_name=${BTS_SCF_FEATCADM_dn}
    ...  parameter_to_check=actRfiTesting  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_actRfiTesting}=  Run Keyword If  ${actRfiTesting_status}
    ...  Check Parameter Value from SCF  item_dist_name=${BTS_SCF_FEATCADM_dn}  parameter_to_check=actRfiTesting
    ...  scf_path=${BTS_SCF_path_file_info}
    ...  ELSE
    ...  Set Variable  None

    Set To Dictionary  ${BTS_RF_Scan_feature_dict}  actRfiTesting  ${BTS_actRfiTesting}

    [Return]  ${BTS_RF_Scan_feature_dict}

Set classical BTS RF Scan feature parameter
    [Documentation]
    ...  Set classical BTS RF Scan feature parameter actRfiTesting
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter               | Man. | Description                                                                                         |
    ...  | RF_Scan_parameter_name  | No   | BTS RF Scan feature parameter name, by default actRfiTesting                                        |
    ...  | RF_Scan_parameter_value | No   | BTS RF Scan feature parameter value for requested parameter name, by default true (RF Scan enabled) |
    ...  | alias                   | No   | BTS instance alias, by default None                                                                 |
	...
	[Arguments]  ${RF_Scan_parameter_name}=actRfiTesting  ${RF_Scan_parameter_value}=true  ${alias}=None
    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_RF_Scan_feature_dict}=  Get BTS RF Scan feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_RF_Scan_parameter_value}=  Get From Dictionary  ${BTS_RF_Scan_feature_dict}  ${RF_Scan_parameter_name}
    Run Keyword If  '${BTS_RF_Scan_parameter_value}' == '${RF_Scan_parameter_value}'  Run Keywords
    ...  Log  Parameter ${RF_Scan_parameter_name} already set on ${alias} BTS: ${BTS_RF_Scan_parameter_value}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0
    coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_FEATCADM_dn}  parameter=${RF_Scan_parameter_name}  operation=update
    ...  value=${RF_Scan_parameter_value}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}

    Sleep  5s

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_RF_Scan_feature_dict}=  Get BTS RF Scan feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_RF_Scan_parameter_value}=  Get From Dictionary  ${BTS_RF_Scan_feature_dict}  ${RF_Scan_parameter_name}
    Run Keyword If  '${BTS_RF_Scan_parameter_value}' == '${RF_Scan_parameter_value}'
    ...  Log  Parameter ${RF_Scan_parameter_name} set on ${alias} BTS: ${BTS_RF_Scan_parameter_value}, successfully commissioning!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter ${RF_Scan_parameter_name} not properly set on ${alias} BTS! (expected/found value:
    ...  ${RF_Scan_parameter_value}/${BTS_RF_Scan_parameter_value})  console=True
    ...  AND  Fail  Parameter ${RF_Scan_parameter_name} not properly set on ${alias} BTS!

Get BTS CB012446 feature parameters
    [Documentation]
    ...  Get BTS CB012446 feature parameter: cntrldResetMplaneBreakTimeSite
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | alias             | No   | BTS connection instance alias                                                                                 |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description                                                                                   |
    ...  | BTS_CB012446_feature_dict | BTS CB012446 feature dict containing structure: {'cntrldResetMplaneBreakTimeSite': '<value>'} |

    [Arguments]  ${BTS_SCF_path_file}=None  ${alias}=None

    ${BTS_CB012446_feature_dict}=  Create Dictionary

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0

    ${cntrldResetMplaneBreakTimeSite_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_FEATCADM_dn}  p_name=cntrldResetMplaneBreakTimeSite

    ${cntrldResetMplaneBreakTimeSite_count}=  Get Length  ${cntrldResetMplaneBreakTimeSite_info_dict}
    ${cntrldResetMplaneBreakTimeSite_info}=  Run Keyword If  ${cntrldResetMplaneBreakTimeSite_count} > 0
    ...  Get From Dictionary  ${cntrldResetMplaneBreakTimeSite_info_dict}  cntrldResetMplaneBreakTimeSite
    ...  ELSE
    ...  Set Variable  NA

    Set To Dictionary  ${BTS_CB012446_feature_dict}  cntrldResetMplaneBreakTimeSite=${cntrldResetMplaneBreakTimeSite_info}

    [Return]  ${BTS_CB012446_feature_dict}

Set classical BTS CB012446 feature parameter
    [Documentation]
    ...  Set classical BTS CB012446 feature parameter: cntrldResetMplaneBreakTimeSite
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                | Man. | Description                                                       |
    ...  | CB012446_parameter_name  | No   | BTS CB012446 feature parameter name                               |
    ...  | CB012446_parameter_value | No   | BTS CB012446 feature parameter value for requested parameter name |
    ...  | alias                    | No   | BTS instance alias, by default None                               |
	...
	[Arguments]  ${CB012446_parameter_name}  ${CB012446_parameter_value}  ${alias}=None
    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_CB012446_feature_dict}=  Get BTS CB012446 feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_CB012446_parameter_value}=  Get From Dictionary  ${BTS_CB012446_feature_dict}  ${CB012446_parameter_name}
    Run Keyword If  '${BTS_CB012446_parameter_value}' == '${CB012446_parameter_value}'  Run Keywords
    ...  Log  Parameter ${CB012446_parameter_name} already set on BTS ${alias}: ${BTS_CB012446_parameter_value}, commissioning not needed!
    ...  console=True
    ...  AND  Return From Keyword

    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0
    coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_FEATCADM_dn}  parameter=${CB012446_parameter_name}  operation=update
    ...  value=${CB012446_parameter_value}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}

    Sleep  5s

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_CB012446_feature_dict}=  Get BTS CB012446 feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_CB012446_parameter_value}=  Get From Dictionary  ${BTS_CB012446_feature_dict}  ${CB012446_parameter_name}
    Run Keyword If  '${BTS_CB012446_parameter_value}' == '${CB012446_parameter_value}'
    ...  Log  Parameter ${CB012446_parameter_name} set on BTS ${alias}: ${BTS_CB012446_parameter_value}, successfully commissioning!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter ${CB012446_parameter_name} not properly set on BTS ${alias}! (expected/found value:
    ...  ${CB012446_parameter_value}/${BTS_CB012446_parameter_value})  console=True
    ...  AND  Fail  Parameter ${CB012446_parameter_name} not properly set on BTS ${alias}!

Get BTS CB010846 feature parameters
    [Documentation]
    ...  Get BTS CB010846 feature parameters: actRuResetResiliency, cntrldResetMplaneBreakTime, uncntrldResetMplaneBreakTime
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | alias             | No   | BTS connection instance alias                                                                                 |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description                                                                                 |
    ...  | BTS_CB010846_feature_dict | BTS CB010846 feature dict containing structure: {'actRuResetResiliency': '<value>',
    ...                                                                                 'cntrldResetMplaneBreakTime': '<value>',
    ...                                                                                 'uncntrldResetMplaneBreakTime': '<value>'} |

    [Arguments]  ${BTS_SCF_path_file}=None  ${alias}=None

    ${BTS_CB010846_feature_dict}=  Create Dictionary

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0

    ${actRuResetResiliency_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_FEATCADM_dn}  p_name=actRuResetResiliency

    ${actRuResetResiliency_count}=  Get Length  ${actRuResetResiliency_info_dict}
    ${actRuResetResiliency_info}=  Run Keyword If   ${actRuResetResiliency_count} > 0
    ...  Get From Dictionary  ${actRuResetResiliency_info_dict}  actRuResetResiliency
    ...  ELSE
    ...  Set Variable  NA

    ${cntrldResetMplaneBreakTime_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_FEATCADM_dn}  p_name=cntrldResetMplaneBreakTime

    ${cntrldResetMplaneBreakTime_count}=  Get Length  ${cntrldResetMplaneBreakTime_info_dict}
    ${cntrldResetMplaneBreakTime_info}=  Run Keyword If   ${cntrldResetMplaneBreakTime_count} > 0
    ...  Get From Dictionary  ${cntrldResetMplaneBreakTime_info_dict}  cntrldResetMplaneBreakTime
    ...  ELSE
    ...  Set Variable  NA

    ${uncntrldResetMplaneBreakTime_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_FEATCADM_dn}  p_name=uncntrldResetMplaneBreakTime

    ${uncntrldResetMplaneBreakTime_count}=  Get Length  ${uncntrldResetMplaneBreakTime_info_dict}
    ${uncntrldResetMplaneBreakTime_info}=  Run Keyword If   ${uncntrldResetMplaneBreakTime_count} > 0
    ...  Get From Dictionary  ${uncntrldResetMplaneBreakTime_info_dict}  uncntrldResetMplaneBreakTime
    ...  ELSE
    ...  Set Variable  NA

    Set To Dictionary  ${BTS_CB010846_feature_dict}  actRuResetResiliency=${actRuResetResiliency_info}
    ...  cntrldResetMplaneBreakTime=${cntrldResetMplaneBreakTime_info}  uncntrldResetMplaneBreakTime=${uncntrldResetMplaneBreakTime_info}

    [Return]  ${BTS_CB010846_feature_dict}

Set classical BTS CB010846 feature parameter
    [Documentation]
    ...  Set classical BTS CB010846 feature parameter: actRuResetResiliency, cntrldResetMplaneBreakTime, uncntrldResetMplaneBreakTime
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                | Man. | Description                                                       |
    ...  | CB010846_parameter_name  | Yes  | BTS CB010846 feature parameter name                               |
    ...  | CB010846_parameter_value | Yes  | BTS CB010846 feature parameter value for requested parameter name |
    ...  | alias                    | No   | BTS instance alias, by default None                               |
    ...

    [Arguments]  ${CB010846_parameter_name}  ${CB010846_parameter_value}  ${alias}=None

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_CB010846_feature_dict}=  Get BTS CB010846 feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_CB010846_parameter_value}=  Get From Dictionary  ${BTS_CB010846_feature_dict}  ${CB010846_parameter_name}
    Run Keyword If  '${BTS_CB010846_parameter_value}' == '${CB010846_parameter_value}'  Run Keywords
    ...  Log  Parameter ${CB010846_parameter_name} already set on BTS ${alias}: ${BTS_CB010846_parameter_value}, commissioning not needed!
    ...  console=True
    ...  AND  Return From Keyword

    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0
    coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_FEATCADM_dn}  parameter=${CB010846_parameter_name}  operation=update
    ...  value=${CB010846_parameter_value}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}

    Sleep  5s

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_CB010846_feature_dict}=  Get BTS CB010846 feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_CB010846_parameter_value}=  Get From Dictionary  ${BTS_CB010846_feature_dict}  ${CB010846_parameter_name}
    Run Keyword If  '${BTS_CB010846_parameter_value}' == '${CB010846_parameter_value}'
    ...  Log  Parameter ${CB010846_parameter_name} set on BTS ${alias}: ${BTS_CB010846_parameter_value}, successfully commissioning!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter ${CB010846_parameter_name} not properly set on BTS ${alias}! (expected/found value:
    ...  ${CB010846_parameter_value}/${BTS_CB010846_parameter_value})  console=True
    ...  AND  Fail  Parameter ${CB010846_parameter_name} not properly set on BTS ${alias}!

Get BTS CB012619 feature parameters
    [Documentation]
    ...  Get BTS CB012619 feature parameters: actPimCancellation, actPimCancellationBypass
    ...
    ...  *AUTHOR* gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | RMOD_id           | Yes  | RMOD id on which to get actPimCancellation and actPimCancellationBypass                                       |
    ...  | RMOD_SN           | Yes  | Serial Number of RMOD in question                                                                             |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | alias             | No   | BTS connection instance alias                                                                                 |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description                                                                                 |
    ...  | BTS_CB012619_RMOD_feature_dict | BTS CB012619 feature dict containing structure: {'actPimCancellation': '<value>',      |
    ...                                                                                 'actPimCancellationBypass': '<value>'}     |
    [Arguments]  ${RMOD_id}  ${RMOD_SN}  ${BTS_SCF_path_file}=None  ${alias}=None

    ${VDU_RMOD_sn_config_dict}  ${VDU_RMOD_config_sn_dict}  ${VDU_RMOD_sn_runtime_dict}  ${VDU_RMOD_runtime_sn_dict}=
    ...  Run Keyword If  '${alias}' not in ${alias_list}  VDU Get RMOD sn config runtime info  vdu_connection=${alias}
    ${RMOD_dn}=  Run Keyword If  '${alias}' in ${alias_list}  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ...  ELSE   Get From Dictionary  ${VDU_RMOD_sn_config_dict}  ${RMOD_SN}
    ${BTS_CB012619_RMOD_feature_dict}=  Create Dictionary
    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0
    ${actPimCancellation_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${RMOD_dn}  p_name=actPimCancellation
    ${actPimCancellation_count}=  Get Length  ${actPimCancellation_info_dict}
    ${actPimCancellation_info}=  Run Keyword If   ${actPimCancellation_count} > 0
    ...  Get From Dictionary  ${actPimCancellation_info_dict}  actPimCancellation
    ...  ELSE
    ...  Set Variable  NA
    ${actPimCancellationBypass_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${RMOD_dn}  p_name=actPimCancellationBypass
    ${actPimCancellationBypass_count}=  Get Length  ${actPimCancellationBypass_info_dict}
    ${actPimCancellationBypass_info}=  Run Keyword If   ${actPimCancellationBypass_count} > 0
    ...  Get From Dictionary  ${actPimCancellationBypass_info_dict}  actPimCancellationBypass
    ...  ELSE
    ...  Set Variable  NA
   Set To Dictionary  ${BTS_CB012619_RMOD_feature_dict}
    ...  actPimCancellation=${actPimCancellation_info}  actPimCancellationBypass=${actPimCancellationBypass_info}
    [Return]  ${BTS_CB012619_RMOD_feature_dict}

 Get CBTS CB012619 feature parameters
    [Documentation]
    ...  Get BTS CB012619 feature parameters: actPimCancellation, actPimCancellationBypass
    ...
    ...  *AUTHOR* gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | RMOD_Id           | Yes  | RMOD Id on which to get actPimCancellation and actPimCancellationBypass                                       |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | alias             | No   | BTS connection instance alias                                                                                 |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description                                                                                 |
    ...  | BTS_CB012619_RMOD_feature_dict | BTS CB012619 feature dict containing structure: {'actPimCancellation': '<value>',      |
    ...                                                                                 'actPimCancellationBypass': '<value>'}     |
    [Arguments]  ${RMOD_Id}  ${BTS_SCF_path_file}=None  ${alias}=None
    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${BTS_CB012619_RMOD_feature_dict}=  Create Dictionary
    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0
    ${actPimCancellation_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${RMOD_dn}  p_name=actPimCancellation
    ${actPimCancellation_count}=  Get Length  ${actPimCancellation_info_dict}
    ${actPimCancellation_info}=  Run Keyword If   ${actPimCancellation_count} > 0
    ...  Get From Dictionary  ${actPimCancellation_info_dict}  actPimCancellation
    ...  ELSE
    ...  Set Variable  NA
    ${actPimCancellationBypass_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${RMOD_dn}  p_name=actPimCancellationBypass
    ${actPimCancellationBypass_count}=  Get Length  ${actPimCancellationBypass_info_dict}
    ${actPimCancellationBypass_info}=  Run Keyword If   ${actPimCancellationBypass_count} > 0
    ...  Get From Dictionary  ${actPimCancellationBypass_info_dict}  actPimCancellationBypass
    ...  ELSE
    ...  Set Variable  NA
   Set To Dictionary  ${BTS_CB012619_RMOD_feature_dict}
    ...  actPimCancellation=${actPimCancellation_info}  actPimCancellationBypass=${actPimCancellationBypass_info}
    [Return]  ${BTS_CB012619_RMOD_feature_dict}

Get RMOD thermal monitoring counter parameters
    [Documentation]
    ...  Get BTS mtSBTSRMODTemperature mtSBTSSfpRMOD parameters
    ...
    ...  *AUTHOR* valentin.marian@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                  |
    ...  | RMOD_thermal_counter_dict | RMOD thermal counter dict containing structure: {'mtSBTSRMODTemperature': '<value>',        |
    ...  |                           |                                                  'mtSBTSSfpRMOD': '<value>'}                |

    [Arguments]  ${BTS_SCF_path_file}=None  ${alias}=None

    ${RMOD_thermal_counter_dict}=  Create Dictionary

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${BTS_SCF_PMMNL_list}=  Get All Dist Names By Pattern from SCF  pattern=/PMMNL-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_PMMNL_dn}=  Get From List  ${BTS_SCF_PMMNL_list}  0

    ${mtSBTSRMODTemperature_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_PMMNL_dn}  p_name=mtSBTSRMODTemperature

    ${mtSBTSRMODTemperature_count}=  Get Length  ${mtSBTSRMODTemperature_info_dict}
    ${mtSBTSRMODTemperature_info}=  Run Keyword If   ${mtSBTSRMODTemperature_count} > 0
    ...  Get From Dictionary  ${mtSBTSRMODTemperature_info_dict}  mtSBTSRMODTemperature
    ...  ELSE
    ...  Set Variable  NA

    ${mtSBTSSfpRMOD_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_PMMNL_dn}  p_name=mtSBTSSfpRMOD

    ${mtSBTSSfpRMOD_count}=  Get Length  ${mtSBTSSfpRMOD_info_dict}
    ${mtSBTSSfpRMOD_info}=  Run Keyword If   ${mtSBTSSfpRMOD_count} > 0
    ...  Get From Dictionary  ${mtSBTSSfpRMOD_info_dict}  mtSBTSSfpRMOD
    ...  ELSE
    ...  Set Variable  NA

    Set To Dictionary  ${RMOD_thermal_counter_dict}  mtSBTSRMODTemperature=${mtSBTSRMODTemperature_info}  mtSBTSSfpRMOD=${mtSBTSSfpRMOD_info}

    [Return]  ${RMOD_thermal_counter_dict}

Set RMOD thermal monitoring counter parameter
    [Documentation]
    ...  Used for setting mtSBTSRMODTemperature mtSBTSSfpRMOD parameters
    ...
    ...  *AUTHOR*
    ...  valentin.marian@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                            | Man. | Description                                                       |
    ...  | RMOD_thermal_counter_parameter_name  | Yes  | RMOD thermal counter parameter name                               |
    ...  | RMOD_thermal_counter_parameter_value | Yes  | RMOD thermal counter parameter value for requested parameter name |
    ...  | alias                                | No   | BTS instance alias, by default None                               |
    ...
    [Arguments]  ${RMOD_thermal_counter_parameter_name}  ${RMOD_thermal_counter_parameter_value}  ${alias}=None

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${RMOD_thermal_counter_feature_dict}=  Get RMOD thermal monitoring counter parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_RMOD_thermal_counter_parameter_value}=  Get From Dictionary  ${RMOD_thermal_counter_feature_dict}  ${RMOD_thermal_counter_parameter_name}
    Run Keyword If  '${BTS_RMOD_thermal_counter_parameter_value}' == '${RMOD_thermal_counter_parameter_value}'  Run Keywords
    ...  Log Long String  Parameter ${RMOD_thermal_counter_parameter_name} already set on BTS ${alias}: ${BTS_RMOD_thermal_counter_parameter_value},
    ...  commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${commissioning_operation}=  Set Variable If  '${RMOD_thermal_counter_parameter_value}' == 'NA'  delete  update

    ${BTS_SCF_PMMNL_list}=  Get All Dist Names By Pattern from SCF  pattern=/PMMNL-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_PMMNL_dn}=  Get From List  ${BTS_SCF_PMMNL_list}  0
    coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_PMMNL_dn}  parameter=${RMOD_thermal_counter_parameter_name}
    ...  operation=${commissioning_operation}  value=${RMOD_thermal_counter_parameter_value}  skip_parameter_relation_errors=True
    ...  should_activate=True  alias=${alias}

    Sleep  5s

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${RMOD_thermal_counter_feature_dict}=  Get RMOD thermal monitoring counter parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_RMOD_thermal_counter_parameter_value}=  Get From Dictionary  ${RMOD_thermal_counter_feature_dict}  ${RMOD_thermal_counter_parameter_name}
    Run Keyword If  '${BTS_RMOD_thermal_counter_parameter_value}' == '${RMOD_thermal_counter_parameter_value}'
    ...  Log Long String  Parameter ${RMOD_thermal_counter_parameter_name} set on BTS ${alias}: ${BTS_RMOD_thermal_counter_parameter_value},
    ...  successfully commissioning!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter ${RMOD_thermal_counter_parameter_name} not properly set on BTS ${alias}! (expected/found value:
    ...  ${RMOD_thermal_counter_parameter_value}/${BTS_RMOD_thermal_counter_parameter_value})  console=True
    ...  AND  Fail  Parameter ${RMOD_thermal_counter_parameter_name} not properly set on BTS ${alias}!

Get all BTS RMOD buildVersion and l3Protocol info
    [Documentation]
    ...  Helper KW providing radio modules build version info on BTS:
    ...  - dictionary containing structure: {'BTS_alias': {'RMOD_serial_number': 'RMOD_buildVersion'}}
    ...  - dictionary containing structure: {'BTS_alias': {'RMOD_serial_number': 'RMOD_l3Protocol'}}
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter                                | Description                                      |
    ...  | BTS_alias_RMOD_sn_RMOD_buildVersion_dict | Dict of BTS alias RMOD sn RMOD buildVersion info |
    ...  | BTS_alias_RMOD_sn_RMOD_l3Protocol_dict   | Dict of BTS alias RMOD sn RMOD l3Protocol info |

    ${BTS_alias_RMOD_sn_RMOD_buildVersion_dict}=  Create Dictionary
    ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${RMOD_sn_RMOD_buildVersion_dict}  ${RMOD_sn_RMOD_l3Protocol_dict}=  Get RMODbuildVersion and l3Protocol info  ${alias}

        Set To Dictionary  ${BTS_alias_RMOD_sn_RMOD_buildVersion_dict}  ${alias}   ${RMOD_sn_RMOD_buildVersion_dict}
        Set To Dictionary  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}  ${alias}   ${RMOD_sn_RMOD_l3Protocol_dict}

    END

    [Return]  ${BTS_alias_RMOD_sn_RMOD_buildVersion_dict}  ${BTS_alias_RMOD_sn_RMOD_l3Protocol_dict}

Get RMOD buildVersion and l3Protocol info
    [Arguments]  ${alias}

    ${RMOD_sn_RMOD_buildVersion_dict}=  Create Dictionary
    ${RMOD_sn_RMOD_l3Protocol_dict}=  Create Dictionary

    ${RMOD_R_info}=  Get Parameters For All  class_name=RMOD  connection=${alias}

    FOR  ${item}  IN  @{RMOD_R_info}

        Set To Dictionary  ${RMOD_sn_RMOD_buildVersion_dict}  ${item['serialNumber']}  ${item['buildVersion']}
        Set To Dictionary  ${RMOD_sn_RMOD_l3Protocol_dict}  ${item['serialNumber']}  ${item['l3Protocol']}

    END

    [Return]  ${RMOD_sn_RMOD_buildVersion_dict}  ${RMOD_sn_RMOD_l3Protocol_dict}

Get all BTS RMOD Uptime info
    [Documentation]
    ...  Helper KW providing radio modules uptime info on requested BTS:
    ...  - dictionary containing structure: {'BTS_alias': {'RMOD_serial_number': 'Uptime'}}
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
     ...  *INPUT*
    ...  | Parameter       | Man. | Description                                                                                                  |
    ...  | BTS_alias_list  | No   | List of BTS alias info where radio modules uptime info is requested, by default @{EMPTY} means all BTS alias |
    ...
    ...  *RETURN*
    ...  | Parameter                     | Description                           |
    ...  | BTS_alias_RMOD_sn_Uptime_dict | Dict of BTS alias RMOD sn Uptime info |
    ...
    [Arguments]  ${BTS_alias_list}=@{EMPTY}

    ${all_BTS_RMOD_sn_Uptime_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  ${BTS_alias_list} != @{EMPTY} and '${alias}' not in @{BTS_alias_list}

        ${all_BTS_RMOD_sn_Uptime_dict}=  Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']
        ...  Get classical BTS RMOD Uptime Info  ${all_BTS_RMOD_sn_Uptime_dict}  ${alias}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        ...  Get cloud BTS RMOD Uptime Info  ${all_BTS_RMOD_sn_Uptime_dict}  ${alias}

    END

    [Return]  ${all_BTS_RMOD_sn_Uptime_dict}

Get classical BTS RMOD Uptime Info
    [Arguments]  ${all_BTS_RMOD_sn_Uptime_dict}  ${alias}

    ${RMOD_sn_id_dict}  ${RMOD_id_sn_dict}=  Get RM id sn info dict  ${alias}

    ${RMOD_sn_Uptime_dict}=  Get RMOD Uptime info  ${RMOD_sn_id_dict}  ${alias}

    Set To Dictionary  ${all_BTS_RMOD_sn_Uptime_dict}  ${alias}   ${RMOD_sn_Uptime_dict}

    [Return]  ${all_BTS_RMOD_sn_Uptime_dict}

Get cloud BTS RMOD Uptime Info
    [Arguments]  ${all_BTS_RMOD_sn_Uptime_dict}  ${alias}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

        FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}=
        ...  VDU Get RMOD sn id pn interface info  ${vdu_alias}

        ${RMOD_sn_Uptime_dict}=  VDU Get VDU RMOD Uptime info  ${VDU_RMOD_sn_id_dict}  ${vdu_alias}

        Set To Dictionary  ${all_BTS_RMOD_sn_Uptime_dict}  ${vdu_alias}  ${RMOD_sn_Uptime_dict}

    END

    [Return]  ${all_BTS_RMOD_sn_Uptime_dict}

Get RMOD Uptime info
    [Arguments]  ${RMOD_sn_id_dict}  ${alias}

    ${RMOD_sn_Uptime_dict}=  Create Dictionary

    ${RMOD_sn_list}=  Get Dictionary Keys  ${RMOD_sn_id_dict}

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${RMOD_sn_id_dict}  ${RMOD_sn}

        ${RMOD_info}=  coam.Get Rmod Measurements By Id  id=${RMOD_id}  connection=${alias}

        ${Uptime_info}=  Set Variable  ${RMOD_info['uptime']['seconds']}

        Set To Dictionary  ${RMOD_sn_Uptime_dict}  ${RMOD_sn}  ${Uptime_info}

    END

    [Return]  ${RMOD_sn_Uptime_dict}

Check RMODs RESET behavior based on Uptime info on BTS
    [Arguments]  ${RMOD_sn_list}  ${RMOD_sn_Uptime_dict_initial}  ${RMOD_sn_Uptime_dict_final}  ${alias}

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        ${RMOD_sn_initial}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${RMOD_sn_Uptime_dict_initial}  ${RMOD_sn}
        ${RMOD_sn_final}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${RMOD_sn_Uptime_dict_final}  ${RMOD_sn}
        Continue For Loop If  (not ${RMOD_sn_initial}) or (not ${RMOD_sn_final})

        ${RMOD_Uptime_initial}=  Get From Dictionary  ${RMOD_sn_Uptime_dict_initial}  ${RMOD_sn}
        ${RMOD_Uptime_final}=  Get From Dictionary  ${RMOD_sn_Uptime_dict_final}  ${RMOD_sn}

        Check RMOD RESET behavior based on Uptime info on BTS  ${RMOD_sn}  ${RMOD_Uptime_initial}  ${RMOD_Uptime_final}  ${alias}

    END

Check RMOD RESET behavior based on Uptime info on BTS
    [Arguments]  ${RMOD_sn}  ${RMOD_Uptime_initial}  ${RMOD_Uptime_final}  ${alias}

    ${RMOD_Uptime_delta}=  Evaluate  ${RMOD_Uptime_final} - ${RMOD_Uptime_initial}
    ${Uptime_log}=  Set Variable  (initial/final RMOD Uptime: ${RMOD_Uptime_initial} secs/${RMOD_Uptime_final} secs)

    Run Keyword If  ${RMOD_Uptime_delta} >= 0
    ...  Log  BTS ${alias} RMOD_${RMOD_sn} reset behavior as expected ${Uptime_log}!  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS ${alias} RMOD_${RMOD_sn} reset behavior not as expected ${Uptime_log}!  level=ERROR
    ...  AND  Fail  BTS ${alias} RMOD_${RMOD_sn} reset behavior not as expected  ${Uptime_log}!

Get BTS CB009828 feature parameters
    [Documentation]
    ...  Get BTS CB009828 feature parameter: actRfsConfigPerUnit
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | alias             | No   | BTS connection instance alias                                                                                 |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description                                                                        |
    ...  | BTS_CB009828_feature_dict | BTS CB009828 feature dict containing structure: {'actRfsConfigPerUnit': '<value>'} |

    [Arguments]  ${BTS_SCF_path_file}=None  ${alias}=Master

    ${BTS_CB009828_feature_dict}=  Create Dictionary

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0

    ${actRfsConfigPerUnit_status}=  Check If Parameter Exists From SCF  item_dist_name=${BTS_SCF_FEATCADM_dn}
    ...  parameter_to_check=actRfsConfigPerUnit  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_actRfsConfigPerUnit}=  Run Keyword If  ${actRfsConfigPerUnit_status}
    ...  Check Parameter Value from SCF  item_dist_name=${BTS_SCF_FEATCADM_dn}  parameter_to_check=actRfsConfigPerUnit
    ...  scf_path=${BTS_SCF_path_file_info}
    ...  ELSE
    ...  Set Variable  None

    Set To Dictionary  ${BTS_CB009828_feature_dict}  actRfsConfigPerUnit  ${BTS_actRfsConfigPerUnit}

    [Return]  ${BTS_CB009828_feature_dict}

Get all BTS controller role for configured RMOD from SCF
    [Documentation]
    ...  Helper KW providing info about all BTS controller role for configured RMOD from SCF:
    ...  - with CB009828: based on sharingConfig.controllerRole info
    ...  - without CB009828: based on radioMasterDN info
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter                            | Description                                                            |
    ...  | all_BTS_controller_role_RMOD_sn_list | Dictionary containing structure:
    ...                                           - {<BTS_alias>:{'BTS_primary_controller_RMOD_sn_list': [<RMOD_sn>]},
    ...                                                          {'BTS_secondary_controller_RMOD_sn_list': [<RMOD_sn>]}} |
    ...

    ${all_BTS_controller_role_RMOD_sn_list}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${all_BTS_controller_role_RMOD_sn_list}=  Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        ...  Get cloud BTS controller role for configured RMOD from SCF
        ...  all_BTS_controller_role_RMOD_sn_list=${all_BTS_controller_role_RMOD_sn_list}  alias=${alias}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']
        ...  Get classical BTS controller role for configured RMOD from SCF
        ...  all_BTS_controller_role_RMOD_sn_list=${all_BTS_controller_role_RMOD_sn_list}  alias=${alias}

    END

    [Return]  ${all_BTS_controller_role_RMOD_sn_list}

Get cloud BTS controller role for configured RMOD from SCF
    [Arguments]  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_primary_controller_RMOD_sn_list}  ${VDU_secondary_controller_RMOD_sn_list}=  Get VDU controller role for configured RMOD from SCF
        ...  vdu_alias=${vdu_alias}

        ${VDU_controller_RMOD_sn_dict}=  Create Dictionary
        ...  BTS_primary_controller_RMOD_sn_list=${VDU_primary_controller_RMOD_sn_list}
        ...  BTS_secondary_controller_RMOD_sn_list=${VDU_secondary_controller_RMOD_sn_list}

        Set To Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${vdu_alias}=${VDU_controller_RMOD_sn_dict}

    END

    [Return]  ${all_BTS_controller_role_RMOD_sn_list}

Get VDU controller role for configured RMOD from SCF
    [Documentation]
    ...  Keyword providing VDU controller role for configured RMOD from SCF:
    ...  - with CB009828: based on sharingConfig.controllerRole info
    ...  - without CB009828: based on radioMasterDN info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | VDU_SCF_path_file | No   | VDU SCF path file. By default None: initial VDU SCF file get in common setup phase will be taken into account |
    ...  | vdu_alias         | No   | VDU connection instance alias                                                                                 |
    ...
    ...  *RETURN*
    ...  | Parameter                             | Description                                                  |
    ...  | VDU_primary_controller_RMOD_sn_list   | List of RMOD sn with VDU alias set primary controller role   |
    ...  | VDU_secondary_controller_RMOD_sn_list | List of RMOD sn with VDU alias set secondary controller role |
    ...
    [Arguments]  ${VDU_SCF_path_file}=None  ${vdu_alias}=None

    ${VDU_SCF_path_file_info}=  Set Variable If  '${VDU_SCF_path_file}' == 'None'  ${${vdu_alias.lower()}_scf_initial}  ${VDU_SCF_path_file}

    ${VDU_CB009828_feature_dict}=  Get BTS CB009828 feature parameters  BTS_SCF_path_file=${VDU_SCF_path_file_info}  alias=${vdu_alias}
    ${actRfsConfigPerUnit_info}=  Get From Dictionary  ${VDU_CB009828_feature_dict}  actRfsConfigPerUnit

    ${VDU_primary_controller_RMOD_sn_list}  ${VDU_secondary_controller_RMOD_sn_list}=  Run Keyword If  '${actRfsConfigPerUnit_info}' == 'true'
    ...  Get VDU controller role for configured RMOD from SCF with CB009828  VDU_SCF_path_file=${VDU_SCF_path_file_info}  vdu_alias=${vdu_alias}
    ...  ELSE
    ...  Get VDU controller role for configured RMOD from SCF without CB009828  VDU_SCF_path_file=${VDU_SCF_path_file_info}  vdu_alias=${vdu_alias}

    [Return]  ${VDU_primary_controller_RMOD_sn_list}  ${VDU_secondary_controller_RMOD_sn_list}

Get VDU controller role for configured RMOD from SCF with CB009828
    [Documentation]
    ...  Keyword providing VDU controller role for configured RMOD from SCF based on sharingConfig.controllerRole info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | VDU_SCF_path_file | No   | VDU SCF path file. By default None: initial VDU SCF file get in common setup phase will be taken into account |
    ...  | RMOD_sn_list      | No   | List of RMOD sn for which it is requested BTS alias controller role info. By default @{EMPTY}: all configured
    ...                               RMOD will be taken into account                                                                               |
    ...  | vdu_alias         | No   | VDU connection instance alias. By default Master VDU1                                                         |
    ...
    ...  *RETURN*
    ...  | Parameter                             | Description                                                     |
    ...  | VDU_primary_controller_RMOD_sn_list   | List of RMOD sn with VDU alias having primary controller role   |
    ...  | VDU_secondary_controller_RMOD_sn_list | List of RMOD sn with VDU alias having secondary controller role |
    ...
    [Arguments]  ${VDU_SCF_path_file}=None  ${RMOD_sn_list}=@{EMPTY}  ${vdu_alias}=Master VDU1

    ${VDU_primary_controller_RMOD_sn_list}=  Create List
    ${VDU_secondary_controller_RMOD_sn_list}=  Create List

    ${VDU_SCF_path_file_info}=  Set Variable If  '${VDU_SCF_path_file}' == 'None'  ${${vdu_alias.lower()}_scf_initial}  ${VDU_SCF_path_file}
    ${RMOD_sn_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${RMOD_sn_list}

    ${VDU_RMOD_sn_config_dict}  ${VDU_RMOD_config_sn_dict}  ${VDU_RMOD_sn_runtime_dict}  ${VDU_RMOD_runtime_sn_dict}=
    ...  VDU Get RMOD sn config runtime info  vdu_connection=${vdu_alias}

    ${VDU_SCF_RMOD_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${VDU_SCF_path_file_info}  alias=${vdu_alias}
    Sort List  ${VDU_SCF_RMOD_list}

    FOR  ${RMOD_dn}  IN  @{VDU_SCF_RMOD_list}

        ${RMOD_sn}=  Get From Dictionary  ${VDU_RMOD_config_sn_dict}  ${RMOD_dn}

        Continue For Loop If  '${RMOD_sn_list_isEmpty}' == 'False' and '${RMOD_sn}' not in ${RMOD_sn_list}

        ${EMPTY}  ${sharingConfig_info_dict}=  Get Object Attributes Values From Scf  scf_path=${VDU_SCF_path_file_info}  dist_name=${RMOD_dn}
        ...  list_name=sharingConfig

        ${sharingConfig_count}=  Get Length  ${sharingConfig_info_dict}
        ${controllerRole_info}=  Run Keyword If   ${sharingConfig_count} > 0
        ...  Get From Dictionary  ${sharingConfig_info_dict}  sharingConfig
        ...  ELSE
        ...  Create List  NA

        Run Keyword If   'Primary' in ${controllerRole_info} or 'NA' in ${controllerRole_info}
        ...  Append To List  ${VDU_primary_controller_RMOD_sn_list}  ${RMOD_sn}
        ...  ELSE IF  'Secondary' in ${controllerRole_info}
        ...  Append To List  ${VDU_secondary_controller_RMOD_sn_list}  ${RMOD_sn}

    END

    [Return]  ${VDU_primary_controller_RMOD_sn_list}  ${VDU_secondary_controller_RMOD_sn_list}

Get VDU controller role for configured RMOD from SCF without CB009828
    [Documentation]
    ...  Keyword providing VDU controller role for configured RMOD from SCF based on radiMasterDN info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | VDU_SCF_path_file | No   | VDU SCF path file. By default None: initial VDU SCF file get in common setup phase will be taken into account |
    ...  | RMOD_sn_list      | No   | List of RMOD sn for which it is requested BTS alias controller role info. By default @{EMPTY}: all configured
    ...                               RMOD will be taken into account                                                                               |
    ...  | vdu_alias         | No   | VDU connection instance alias. By default Master VDU1                                                         |
    ...
    ...  *RETURN*
    ...  | Parameter                             | Description                                                     |
    ...  | VDU_primary_controller_RMOD_sn_list   | List of RMOD sn with VDU alias having primary controller role   |
    ...  | VDU_secondary_controller_RMOD_sn_list | List of RMOD sn with VDU alias having secondary controller role |
    ...
    [Arguments]  ${VDU_SCF_path_file}=None  ${RMOD_sn_list}=@{EMPTY}  ${vdu_alias}=Master VDU1

    ${VDU_primary_controller_RMOD_sn_list}=  Create List
    ${VDU_secondary_controller_RMOD_sn_list}=  Create List

    ${VDU_SCF_path_file_info}=  Set Variable If  '${VDU_SCF_path_file}' == 'None'  ${${vdu_alias.lower()}_scf_initial}  ${VDU_SCF_path_file}
    ${RMOD_sn_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${RMOD_sn_list}

    ${VDU_RMOD_sn_config_dict}  ${VDU_RMOD_config_sn_dict}  ${VDU_RMOD_sn_runtime_dict}  ${VDU_RMOD_runtime_sn_dict}=
    ...  VDU Get RMOD sn config runtime info  vdu_connection=${vdu_alias}

    ${VDU_SCF_RMOD_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${VDU_SCF_path_file_info}  alias=${vdu_alias}
    Sort List  ${VDU_SCF_RMOD_list}

    FOR  ${RMOD_dn}  IN  @{VDU_SCF_RMOD_list}

        ${RMOD_sn}=  Get From Dictionary  ${VDU_RMOD_config_sn_dict}  ${RMOD_dn}

        Continue For Loop If  '${RMOD_sn_list_isEmpty}' == 'False' and '${RMOD_sn}' not in ${RMOD_sn_list}

        ${radioMasterDN_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${VDU_SCF_path_file_info}  dist_name=${RMOD_dn}
        ...  p_name=radioMasterDN

        ${radioMasterDN_count}=  Get Length  ${radioMasterDN_info_dict}
        ${radioMasterDN_info}=  Run Keyword If  ${radioMasterDN_count} > 0
        ...  Get From Dictionary  ${radioMasterDN_info_dict}  radioMasterDN
        ...  ELSE
        ...  Set Variable  NA

        Run Keyword If  '${radioMasterDN_info}' == 'NA'
        ...  Append To List  ${VDU_primary_controller_RMOD_sn_list}  ${RMOD_sn}
        ...  ELSE
        ...  Append To List  ${VDU_secondary_controller_RMOD_sn_list}  ${RMOD_sn}

    END

    [Return]  ${VDU_primary_controller_RMOD_sn_list}  ${VDU_secondary_controller_RMOD_sn_list}

Get classical BTS controller role for configured RMOD from SCF
    [Documentation]
    ...  Keyword providing classical BTS controller role for configured RMOD from SCF:
    ...  - with CB009828: based on sharingConfig.controllerRole info
    ...  - without CB009828: based on radioMasterDN info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter                            | Man. | Description                                                                        |
    ...  | BTS_SCF_path_file                    | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase
    ...                                                  will be taken into account                                                         |
    ...  | all_BTS_controller_role_RMOD_sn_list | No   | Dictionary containing structure:
    ...                                                  - {'BTS_alias':{'BTS_controller_role_RMOD_sn_list': ['RMOD_sn']}}                  |
    ...  | alias                                | No   | BTS connection instance alias. By default Master                                   |
    ...
    ...  *RETURN*
    ...  | Parameter                            | Description                                                       |
    ...  | all_BTS_controller_role_RMOD_sn_list | Dictionary containing structure:
    ...
    [Arguments]  ${BTS_SCF_path_file}=None  ${all_BTS_controller_role_RMOD_sn_list}=&{EMPTY}  ${alias}=Master

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}

    ${BTS_CB009828_feature_dict}=  Get BTS CB009828 feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${actRfsConfigPerUnit_info}=  Get From Dictionary  ${BTS_CB009828_feature_dict}  actRfsConfigPerUnit

    ${BTS_primary_controller_RMOD_sn_list}  ${BTS_secondary_controller_RMOD_sn_list}=  Run Keyword If  '${actRfsConfigPerUnit_info}' == 'true'
    ...  Get classical BTS controller role for configured RMOD from SCF with CB009828  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ...  ELSE
    ...  Get classical BTS controller role for configured RMOD from SCF without CB009828  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}

    ${BTS_controller_RMOD_sn_dict}=  Create Dictionary
    ...  BTS_primary_controller_RMOD_sn_list=${BTS_primary_controller_RMOD_sn_list}
    ...  BTS_secondary_controller_RMOD_sn_list=${BTS_secondary_controller_RMOD_sn_list}

    Set To Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}=${BTS_controller_RMOD_sn_dict}

    [Return]  ${all_BTS_controller_role_RMOD_sn_list}

Get classical BTS controller role for configured RMOD from SCF with CB009828
    [Documentation]
    ...  Keyword providing classical BTS controller role for configured RMOD from SCF based on sharingConfig.controllerRole info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | RMOD_sn_list      | No   | List of RMOD sn for which it is requested BTS alias controller role info. By default @{EMPTY}: all configured
    ...                               RMOD will be taken into account                                                                               |
    ...  | alias             | No   | BTS connection instance alias. By default Master                                                              |
    ...
    ...  *RETURN*
    ...  | Parameter                             | Description                                                     |
    ...  | BTS_primary_controller_RMOD_sn_list   | List of RMOD sn with BTS alias having primary controller role   |
    ...  | BTS_secondary_controller_RMOD_sn_list | List of RMOD sn with BTS alias having secondary controller role |
    ...
    [Arguments]  ${BTS_SCF_path_file}=None  ${RMOD_sn_list}=@{EMPTY}  ${alias}=Master

    ${BTS_primary_controller_RMOD_sn_list}=  Create List
    ${BTS_secondary_controller_RMOD_sn_list}=  Create List

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${RMOD_sn_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${RMOD_sn_list}

    ${BTS_RMOD_sn_config_dn_dict}  ${BTS_RMOD_config_dn_sn_dict}=  Admin Get RMOD sn config info  alias=${alias}

    ${BTS_SCF_RMOD_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    Sort List  ${BTS_SCF_RMOD_dn_list}

    FOR  ${RMOD_dn}  IN  @{BTS_SCF_RMOD_dn_list}

        ${RMOD_sn}=  Get From Dictionary  ${BTS_RMOD_config_dn_sn_dict}  ${RMOD_dn}

        Continue For Loop If  '${RMOD_sn_list_isEmpty}' == 'False' and '${RMOD_sn}' not in ${RMOD_sn_list}

        ${EMPTY}  ${sharingConfig_info_dict}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}  dist_name=${RMOD_dn}
        ...  list_name=sharingConfig  index=1

        ${sharingConfig_count}=  Get Length  ${sharingConfig_info_dict}
        ${controllerRole_info}=  Run Keyword If  ${sharingConfig_count} > 0
        ...  Get From Dictionary  ${sharingConfig_info_dict}  sharingConfig
        ...  ELSE
        ...  Set Variable  NA

        ${RMOD_sn}=  Get From Dictionary  ${BTS_RMOD_config_dn_sn_dict}  ${RMOD_dn}

        Run Keyword If  '${controllerRole_info}' == 'Primary' or '${controllerRole_info}' == 'NA'
        ...  Append To List  ${BTS_primary_controller_RMOD_sn_list}  ${RMOD_sn}
        ...  ELSE IF  '${controllerRole_info}' == 'Secondary'
        ...  Append To List  ${BTS_secondary_controller_RMOD_sn_list}  ${RMOD_sn}

    END

    [Return]  ${BTS_primary_controller_RMOD_sn_list}  ${BTS_secondary_controller_RMOD_sn_list}

Get classical BTS controller role for configured RMOD from SCF without CB009828
    [Documentation]
    ...  Keyword providing classical BTS controller role for configured RMOD from SCF based on radioMasterDN info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | RMOD_sn_list      | No   | List of RMOD sn for which it is requested BTS alias controller role info. By default @{EMPTY}: all configured
    ...                               RMOD will be taken into account                                                                               |
    ...  | alias             | No   | BTS connection instance alias. By default Master                                                              |
    ...
    ...  *RETURN*
    ...  | Parameter                             | Description                                                     |
    ...  | BTS_primary_controller_RMOD_sn_list   | List of RMOD sn with BTS alias having primary controller role   |
    ...  | BTS_secondary_controller_RMOD_sn_list | List of RMOD sn with BTS alias having secondary controller role |
    ...
    [Arguments]  ${BTS_SCF_path_file}=None  ${RMOD_sn_list}=@{EMPTY}  ${alias}=Master

    ${BTS_primary_controller_RMOD_sn_list}=  Create List
    ${BTS_secondary_controller_RMOD_sn_list}=  Create List

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${RMOD_sn_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${RMOD_sn_list}

    ${BTS_RMOD_sn_config_dn_dict}  ${BTS_RMOD_config_dn_sn_dict}=  Admin Get RMOD sn config info  alias=${alias}

    ${BTS_SCF_SMOD_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/SMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_BBMOD_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/BBMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_SMOD_BBMOD_dn_list}=  Combine Lists  ${BTS_SCF_SMOD_dn_list}  ${BTS_SCF_BBMOD_dn_list}
    ${BTS_SCF_RMOD_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    Sort List  ${BTS_SCF_RMOD_dn_list}

    FOR  ${RMOD_dn}  IN  @{BTS_SCF_RMOD_dn_list}

        ${RMOD_sn}=  Get From Dictionary  ${BTS_RMOD_config_dn_sn_dict}  ${RMOD_dn}

        Continue For Loop If  '${RMOD_sn_list_isEmpty}' == 'False' and '${RMOD_sn}' not in ${RMOD_sn_list}

        ${radioMasterDN_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}  dist_name=${RMOD_dn}
        ...  p_name=radioMasterDN

        ${radioMasterDN_count}=  Get Length  ${radioMasterDN_info_dict}
        ${radioMasterDN_info}=  Run Keyword If  ${radioMasterDN_count} > 0
        ...  Get From Dictionary  ${radioMasterDN_info_dict}  radioMasterDN
        ...  ELSE
        ...  Set Variable  NA

        Run Keyword If  '${radioMasterDN_info}' in ${BTS_SCF_SMOD_BBMOD_dn_list} or '${radioMasterDN_info}' == 'NA'
        ...  Append To List  ${BTS_primary_controller_RMOD_sn_list}  ${RMOD_sn}
        ...  ELSE IF  '${radioMasterDN_info}' not in ${BTS_SCF_SMOD_BBMOD_dn_list} and '${radioMasterDN_info}' != 'NA'
        ...  Append To List  ${BTS_secondary_controller_RMOD_sn_list}  ${RMOD_sn}

    END

    [Return]  ${BTS_primary_controller_RMOD_sn_list}  ${BTS_secondary_controller_RMOD_sn_list}

Get classical BTS controller role for configured FHS from SCF with CB009828
    [Documentation]
    ...  Keyword providing classical BTS controller role for configured FHS from SCF based on sharingConfig.controllerRole info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | FHS_sn_list       | No   | List of FHS sn for which it is requested BTS alias controller role info. By default @{EMPTY}: all configured
    ...                               FHS will be taken into account                                                                                |
    ...  | alias             | No   | BTS connection instance alias. By default Master                                                              |
    ...
    ...  *RETURN*
    ...  | Parameter                            | Description                                                    |
    ...  | BTS_primary_controller_FHS_sn_list   | List of FHS sn with BTS alias having primary controller role   |
    ...  | BTS_secondary_controller_FHS_sn_list | List of FHS sn with BTS alias having secondary controller role |
    ...
    [Arguments]  ${BTS_SCF_path_file}=None  ${FHS_sn_list}=@{EMPTY}  ${alias}=Master

    ${BTS_primary_controller_FHS_sn_list}=  Create List
    ${BTS_secondary_controller_FHS_sn_list}=  Create List

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${FHS_sn_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${FHS_sn_list}

    ${BTS_FHS_sn_config_dn_dict}  ${BTS_FHS_config_dn_sn_dict}=  Admin Get FHS sn config info  alias=${alias}

    ${BTS_SCF_FHS_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FHS-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    Sort List  ${BTS_SCF_FHS_dn_list}

    FOR  ${FHS_dn}  IN  @{BTS_SCF_FHS_dn_list}

        ${FHS_sn}=  Get From Dictionary  ${BTS_FHS_config_dn_sn_dict}  ${FHS_dn}

        Continue For Loop If  '${FHS_sn_list_isEmpty}' == 'False' and '${FHS_sn}' not in ${FHS_sn_list}

        ${EMPTY}  ${sharingConfig_info_dict}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}  dist_name=${FHS_dn}
        ...  list_name=sharingConfig  index=1

        ${sharingConfig_count}=  Get Length  ${sharingConfig_info_dict}
        ${controllerRole_info}=  Run Keyword If  ${sharingConfig_count} > 0
        ...  Get From Dictionary  ${sharingConfig_info_dict}  sharingConfig
        ...  ELSE
        ...  Set Variable  NA

        ${FHS_sn}=  Get From Dictionary  ${BTS_FHS_config_dn_sn_dict}  ${FHS_dn}

        Run Keyword If  '${controllerRole_info}' == 'Primary' or '${controllerRole_info}' == 'NA'
        ...  Append To List  ${BTS_primary_controller_FHS_sn_list}  ${FHS_sn}
        ...  ELSE IF  '${controllerRole_info}' == 'Secondary'
        ...  Append To List  ${BTS_secondary_controller_FHS_sn_list}  ${FHS_sn}

    END

    [Return]  ${BTS_primary_controller_FHS_sn_list}  ${BTS_secondary_controller_FHS_sn_list}

Get classical BTS controller role for configured FHS from SCF without CB009828
    [Documentation]
    ...  Keyword providing classical BTS controller role for configured FHS from SCF based on primaryControllerDN info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | FHS_sn_list       | No   | List of FHS sn for which it is requested BTS alias controller role info. By default @{EMPTY}: all configured
    ...                               FHS will be taken into account                                                                                |
    ...  | alias             | No   | BTS connection instance alias. By default Master                                                              |
    ...
    ...  *RETURN*
    ...  | Parameter                            | Description                                                    |
    ...  | BTS_primary_controller_FHS_sn_list   | List of FHS sn with BTS alias having primary controller role   |
    ...  | BTS_secondary_controller_FHS_sn_list | List of FHS sn with BTS alias having secondary controller role |
    ...
    [Arguments]  ${BTS_SCF_path_file}=None  ${FHS_sn_list}=@{EMPTY}  ${alias}=Master

    ${BTS_primary_controller_FHS_sn_list}=  Create List
    ${BTS_secondary_controller_FHS_sn_list}=  Create List

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${FHS_sn_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${FHS_sn_list}

    ${BTS_FHS_sn_config_dn_dict}  ${BTS_FHS_config_dn_sn_dict}=  Admin Get FHS sn config info  alias=${alias}

    ${BTS_SCF_SMOD_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/SMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_BBMOD_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/BBMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_SMOD_BBMOD_dn_list}=  Combine Lists  ${BTS_SCF_SMOD_dn_list}  ${BTS_SCF_BBMOD_dn_list}
    ${BTS_SCF_FHS_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FHS-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    Sort List  ${BTS_SCF_FHS_dn_list}

    FOR  ${FHS_dn}  IN  @{BTS_SCF_FHS_dn_list}

        ${FHS_sn}=  Get From Dictionary  ${BTS_FHS_config_dn_sn_dict}  ${FHS_dn}

        Continue For Loop If  '${FHS_sn_list_isEmpty}' == 'False' and '${FHS_sn}' not in ${FHS_sn_list}

        ${primaryControllerDN_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}  dist_name=${FHS_dn}
        ...  p_name=primaryControllerDN

        ${primaryControllerDN_count}=  Get Length  ${primaryControllerDN_info_dict}
        ${primaryControllerDN_info}=  Run Keyword If  ${primaryControllerDN_count} > 0
        ...  Get From Dictionary  ${primaryControllerDN_info_dict}  primaryControllerDN
        ...  ELSE
        ...  Set Variable  NA

        Run Keyword If  '${primaryControllerDN_info}' in ${BTS_SCF_SMOD_BBMOD_dn_list} or '${primaryControllerDN_info}' == 'NA'
        ...  Append To List  ${BTS_primary_controller_FHS_sn_list}  ${FHS_sn}
        ...  ELSE IF  '${primaryControllerDN_info}' not in ${BTS_SCF_SMOD_BBMOD_dn_list} and '${primaryControllerDN_info}' != 'NA'
        ...  Append To List  ${BTS_secondary_controller_FHS_sn_list}  ${FHS_sn}

    END

    [Return]  ${BTS_primary_controller_FHS_sn_list}  ${BTS_secondary_controller_FHS_sn_list}

Get classical BTS shared RMOD synchronisation impact due to reset FHGW operation
    [Documentation]
    ...  Helper KW providing classical BTS info related to specific FHGW shared RMOD synchronisation info
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter              | Man. | Description
    ...  | FHGW_RMOD_sn_list      | Yes  | List of RMOD sn connected to FHGW                        |
    ...  | RMOD_sn_BTS_alias_dict | Yes  | Dict containing structure: {'<RMOD_sn>':['<BTS_alias>']} |
    ...  | alias                  | Yes  | BTS connection instance alias                            |
    ...
    ...  *RETURN*
    ...  | Parameter                           | Description                                                            |
    ...  | CPRI_shared_RMOD_sn_SYNC_loss_list  | List of CPRI shared RMOD serial number loosing SYNC due to FHGW reset  |
    ...  | ECPRI_shared_RMOD_sn_SYNC_loss_list | List of ECPRI shared RMOD serial number loosing SYNC due to FHGW reset |
    ...
    [Arguments]  ${FHGW_RMOD_sn_list}  ${RMOD_sn_BTS_alias_dict}  ${alias}

    ${CPRI_shared_RMOD_sn_SYNC_loss_list}=  Create List
    ${ECPRI_shared_RMOD_sn_SYNC_loss_list}=  Create List

    FOR  ${RMOD_sn}  IN  @{FHGW_RMOD_sn_list}

        ${RMOD_BTS_alias_list}=  Get From Dictionary   ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

        ${RMOD_BTS_alias_count}=  Get Length  ${RMOD_BTS_alias_list}

        Continue For Loop If  ${RMOD_BTS_alias_count} == 1 or '${alias}' not in ${RMOD_BTS_alias_list}

        ${SYNC_entity}  ${NON_SYNC_entity}  ${RMOD_interface}=  Get shared RMOD synchronisation info with FHGW connected  ${RMOD_sn}
        ...  ${RMOD_BTS_alias_list}

        Run Keyword If  '${SYNC_entity}' == 'FHGW' and '${RMOD_interface}' == 'CPRI_RP1'
        ...  Append To List  ${CPRI_shared_RMOD_sn_SYNC_loss_list}  ${RMOD_sn}
        Run Keyword If  '${SYNC_entity}' == 'FHGW' and '${RMOD_interface}' == 'ECPRI_MPLANE'
        ...  Append To List  ${ECPRI_shared_RMOD_sn_SYNC_loss_list}  ${RMOD_sn}

    END

    [Return]  ${CPRI_shared_RMOD_sn_SYNC_loss_list}  ${ECPRI_shared_RMOD_sn_SYNC_loss_list}

Get shared RMOD synchronisation info with FHGW connected
    [Arguments]  ${RMOD_sn}  ${RMOD_BTS_alias_list}

    ${SYNC_entity_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        Continue For Loop If  '${alias}' not in ${alias_list}

        ${RMOD_linkModeSynchronization}  ${RMOD_interface}=  Get classical BTS RMOD synchronisation info from SCF  ${RMOD_sn}  ${alias}

        Set To Dictionary  ${SYNC_entity_dict}  ${RMOD_linkModeSynchronization}  ${alias}

    END

    ${RMOD_linkModeSynchronization_True}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${SYNC_entity_dict}  True
    ${RMOD_linkModeSynchronization_False}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${SYNC_entity_dict}  False
    ${RMOD_linkModeSynchronization_None}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${SYNC_entity_dict}  None

    ${SYNC_entity}=  Run Keyword If  ${RMOD_linkModeSynchronization_True}  Get From Dictionary  ${SYNC_entity_dict}  True
    ...  ELSE  Set Variable  FHGW
    ${NON_SYNC_entity}=  Run Keyword If  ${RMOD_linkModeSynchronization_False}  Get From Dictionary  ${SYNC_entity_dict}  False
    ...  ELSE  Set Variable  FHGW

    [Return]  ${SYNC_entity}  ${NON_SYNC_entity}  ${RMOD_interface}

Get all SMOD board types
    ${alias_SMOD_board_types_dict}=  Create Dictionary
    FOR  ${alias}  IN  @{alias_list}
        ${params_list}=  Get Parameters for all  class_name=SMOD  connection=${alias}
        ${product_names_list}=  Get BTS board types  ${params_list}
        Set To Dictionary  ${alias_SMOD_board_types_dict}  ${alias}=${product_names_list}
    END
    Set Test Variable   ${alias_SMOD_board_types_dict}

Get BTS board types
    [Arguments]  ${params_list}
    ${product_names_list}=  Create List
    FOR  ${item}  IN  @{params_list}
        ${productName}=  Get From Dictionary  ${item}  productName
        ${id}=  Get From Dictionary  ${item}  id
        ${params_dict}=  Create Dictionary
        Set To Dictionary  ${params_dict}  ${id}=${productName}
        Append To List  ${product_names_list}  ${params_dict}
    END
    [Return]  ${product_names_list}

Change CBTS VDU MOs parameters by Delta JSON file
    [Documentation]
    ...  KW used to change CBTS VDU multiple MOs parameters by Delta JSON file following steps:
    ...  - create MOs parameters specific dictionary for Delta JSON file
    ...  - perform Delta Recommissioning with created Delta JSON file
    ...  For argument ${mos_parameters_info_dict} following structure should be provided: key (string):value (list of 3 items)
    ...  {'<mo_dn>':['<mo_operation>','<mo_parameters_value_dict>','<mo_parameters_operation_dict>'] where:
    ...  - mo_dn (key) : dist name of managed object
    ...  - mo_operation (1st item from list value): type of operation to be performed on managed object. Possible values are: update, delete, create
    ...  - mo_parameters_value_dict (2nd item from list value): dict containing structure: {'<parameter_name>':'<parameter_value>'}
    ...                                                         - parameter_name: name of the parameter
    ...                                                         - parameter_value: new value of the parameter. This key is required only if the
    ...                                                         operation is update or create
    ...  - mo_parameters_operation_dict (3rd item from list value): dict containing structure: {'<parameter_name>':'<parameter_operation>'}
    ...                                                             - parameter_name: name of the parameter
    ...                                                             - parameter_operation: type of operation to be performed on the parameter.
    ...                                                             Possible values are: update, delete, create
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                    | Man. | Description                                                                                |
    ...  | mos_parameters_info_dict     | Yes  | Dict containing structure: {'<mo_dn>':['<mo_operation>','<mo_parameters_value_dict>',
    ...                                          '<mo_parameters_operation_dict>'] with above description                                   |
    ...  | wait_for_completion          | No   | If set to True, the keyword will wait for the operation to finish. Default value: True     |
    ...  | should_activate              | No   | If set to True, plan will be activated, otherwise it will be validated without activation.
    ...                                          Default value: True                                                                        |
    ...  | timeout                      | No   | Timeout for the operation. Default value: 300                                              |
    ...  | vdu_connection               | No   | VDU connection instance alias. Default value: None                                         |
    ...
    [Arguments]  ${mos_parameters_info_dict}  ${wait_for_completion}=True  ${should_activate}=True  ${timeout}=300  ${vdu_connection}=None

    ${delta_mos_parameters_info_list}=  Create List

    ${mo_dn_list}=  Get Dictionary Keys  ${mos_parameters_info_dict}

    FOR  ${mo_dn}  IN  @{mo_dn_list}

        ${mo_parameters_info_list}=  Get From Dictionary  ${mos_parameters_info_dict}  ${mo_dn}
        ${mo_operation}=  Get From List  ${mo_parameters_info_list}  0
        ${mo_parameters_value_dict}=  Get From List  ${mo_parameters_info_list}  1
        ${mo_parameters_operation_dict}=  Get From List  ${mo_parameters_info_list}  2

        ${delta_mo_parameters_info_dict}=  Create MO parameters specific dictionary for Delta JSON file  mo_dn=${mo_dn}  mo_operation=${mo_operation}
        ...  mo_parameters_value_dict=${mo_parameters_value_dict}  mo_parameters_operation_dict=&{mo_parameters_operation_dict}

        Append To List  ${delta_mos_parameters_info_list}  ${delta_mo_parameters_info_dict}

    END

    ${delta_json_file}=  Create Delta JSON file  delta_info=${delta_mos_parameters_info_list}

    VDU Perform Delta Recommissioning  delta_file=${delta_json_file}  wait_for_completion=${wait_for_completion}  should_activate=${should_activate}
    ...  timeout=${timeout}  vdu_connection=${vdu_connection}

Change CBTS VDU MO parameters by Delta JSON file
    [Documentation]
    ...  Change CBTS VDU MO parameters by Delta JSON file following steps:
    ...  - create MO parameters specific dictionary for Delta JSON file
    ...  - perform Delta Recommissioning with created Delta JSON file
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                    | Man. | Description                                                                                      |
    ...  | mo_dn                        | Yes  | Dist name of managed object                                                                      |
    ...  | mo_operation                 | Yes  | Type of operation to be performed on managed object. Possible values are: update, delete, create |
    ...  | mo_parameters_value_dict     | Yes  | Dict containing structure: {'<parameter_name>':'<parameter_value>'}
    ...                                          - parameter_name: name of the parameter
    ...                                          - parameter_value: new value of the parameter. This key is required only if the operation is
    ...                                          update or create                                                                                 |
    ...  | mo_parameters_operation_dict | Yes  | Dict containing structure: {'<parameter_name>':'<parameter_operation>'}
    ...                                          - parameter_name: name of the parameter
    ...                                          - parameter_operation: type of operation to be performed on the parameter. Possible values are:
    ...                                          update, delete, create                                                                           |
    ...  | wait_for_completion          | No   | If set to True, the keyword will wait for the operation to finish. Default value: True           |
    ...  | should_activate              | No   | If set to True, plan will be activated, otherwise it will be validated without activation.
    ...                                          Default value: True                                                                              |
    ...  | timeout                      | No   | Timeout for the operation. Default value: 300                                                    |
    ...  | vdu_connection               | No   | VDU connection instance alias. Default value: None                                               |
    ...
    [Arguments]  ${mo_dn}  ${mo_operation}  ${mo_parameters_value_dict}  ${mo_parameters_operation_dict}  ${wait_for_completion}=True
    ...  ${should_activate}=True  ${timeout}=300  ${vdu_connection}=None

    ${delta_mo_parameters_info_dict}=  Create MO parameters specific dictionary for Delta JSON file  mo_dn=${mo_dn}  mo_operation=${mo_operation}
    ...  mo_parameters_value_dict=${mo_parameters_value_dict}  mo_parameters_operation_dict=&{mo_parameters_operation_dict}

    ${delta_mo_parameters_info_list}=  Create List  ${delta_mo_parameters_info_dict}

    ${delta_json_file}=  Create Delta JSON file  delta_info=${delta_mo_parameters_info_list}

    VDU Perform Delta Recommissioning  delta_file=${delta_json_file}  wait_for_completion=${wait_for_completion}  should_activate=${should_activate}
    ...  timeout=${timeout}  vdu_connection=${vdu_connection}

Create MO parameters specific dictionary for Delta JSON file
    [Documentation]
    ...  Create MO parameters specific dictionary for Delta JSON file
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                    | Man. | Description                                                                                      |
    ...  | mo_dn                        | Yes  | Dist name of managed object                                                                      |
    ...  | mo_operation                 | Yes  | Type of operation to be performed on managed object. Possible values are: update, delete, create |
    ...  | mo_parameters_value_dict     | Yes  | Dict containing structure: {'<parameter_name>':'<parameter_value>'}
    ...                                          - parameter_name: name of the parameter
    ...                                          - parameter_value: new value of the parameter. This key is required only if the operation is
    ...                                          update or create                                                                                 |
    ...  | mo_parameters_operation_dict | Yes  | Dict containing structure: {'<parameter_name>':'<parameter_operation>'}
    ...                                          - parameter_name: name of the parameter
    ...                                          - parameter_operation: type of operation to be performed on the parameter. Possible values are:
    ...                                          update, delete, create                                                                           |
    ...
    ...  *RETURN*
    ...  | Parameter                     | Description                                                                                 |
    ...  | delta_mo_parameters_info_dict | Dict containing structure: {'distName':'<mo_dn>','operation':'<mo_operation>','parameters':
    ...                                    [{'parameterName':'<mo_parameter_name>','value':'<mo_parameter_value>',
    ...                                    'operation':'<mo_parameter_operation>'}]                                                    |
    ...
    [Arguments]  ${mo_dn}  ${mo_operation}  ${mo_parameters_value_dict}  ${mo_parameters_operation_dict}

    ${delta_mo_parameters_info_dict}=  Create Dictionary
    ${mo_parameters_info_list}=  Create List

    ${mo_parameters_names}=  Get Dictionary Keys  ${mo_parameters_operation_dict}

    FOR  ${mo_parameter_name}  IN  @{mo_parameters_names}

        ${mo_parameter_operation}=  Get From Dictionary  ${mo_parameters_operation_dict}  ${mo_parameter_name}
        Run Keyword If  '${mo_parameter_operation}' not in ['update', 'delete', 'create']  Run Keywords
        ...  Log  Not valid value for the operation to be performed on the parameter. Possible values are: update, delete, create!  level=ERROR
        ...  AND  Fail  Not valid value for the operation to be performed on the parameter. Possible values are: update, delete, create!

        ${mo_parameter_name_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${mo_parameters_value_dict}  ${mo_parameter_name}
        Run Keyword If  '${mo_parameter_operation}' in ['update', 'create'] and not ${mo_parameter_name_status}  Run Keywords
        ...  Log  No value specified for the parameter when requested operation is update or create!  level=ERROR
        ...  AND  Fail  No value specified for the parameter when requested operation is update or create!

        ${mo_parameter_value}=  Run Keyword If  '${mo_parameter_operation}' in ['update', 'create']
        ...  Get From Dictionary  ${mo_parameters_value_dict}  ${mo_parameter_name}

        ${mo_parameter_info_dict}=  Run Keyword If  '${mo_parameter_operation}' in ['update', 'create']
        ...  Create Dictionary  parameterName=${mo_parameter_name}  value=${mo_parameter_value}  operation=${mo_parameter_operation}
        ...  ELSE IF  '${mo_parameter_operation}' == 'delete'
        ...  Create Dictionary  parameterName=${mo_parameter_name}  operation=${mo_parameter_operation}

        Append To List  ${mo_parameters_info_list}  ${mo_parameter_info_dict}

    END

    Set To Dictionary  ${delta_mo_parameters_info_dict}  distName=${mo_dn}  operation=${mo_operation}  parameters=${mo_parameters_info_list}

    [Return]  ${delta_mo_parameters_info_dict}

Create Delta JSON file
    [Documentation]
    ...  Create Delta JSON file
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter  | Man. | Description                                                                                                      |
    ...  | delta_info | Yes  | List of dictionaries containing structure: [{'distName':'<mo_dn>','operation':'<mo_operation>','parameters':
    ...                        [{'parameterName':'<mo_parameter_name>','value':'<mo_parameter_value>','operation':'<mo_parameter_operation>'}]] |
    ...
    ...  *RETURN*
    ...  | Parameter       | Description                                            |
    ...  | delta_json_file | Full path of json file name containing delta json info |
    ...
    [Arguments]  ${delta_info}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${delta_json_file_name}=  Set Variable  Delta_JSON_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.json
    ${delta_json_file}=  Set Variable  ${Test Results Dir}/Delta_JSON/${delta_json_file_name}

    OperatingSystem.Remove File  ${delta_json_file}

    ${delta_json_info}=  Evaluate  json.dumps(${delta_info})  json

    OperatingSystem.Create File   ${delta_json_file}  ${delta_json_info}

    [Return]  ${delta_json_file}

Compare and parse RMOD buildVersion and buildTimestamp from TargetBD and BTS
    [Documentation]
    ...  Return newer SW buildVersion by compare ${TargetBD_buildVersion} and ${BTS_buildVersion} after parsing buildTimestamp based on:
    ...  - if buildTimestamp is single, compares directly TargetBD and BTS timestamp
    ...  - if buildTimestamp is concatenated, first splits by '+' values and then compares them
    ...
    [Arguments]  ${TargetBD_buildVersion}  ${BTS_buildVersion}  ${TargetBD_buildTimestamp}  ${BTS_buildTimestamp}

    ${TargetBD_buildTimestamp_split}=  Split String  ${TargetBD_buildTimestamp}  +
    ${BTS_buildTimestamp_split}=  Split String  ${BTS_buildTimestamp}  +
    ${TargetBD_buildTimestamp_length}=  Get Length  ${TargetBD_buildTimestamp_split}
    ${BTS_buildTimestamp_length}=  Get Length  ${BTS_buildTimestamp_split}
    ${Newer_buildVersion}=  Run Keyword If  '${TargetBD_buildTimestamp_length}' == '1' and '${BTS_buildTimestamp_length}' == '1'
    ...  Compare RMOD buildVersion from TargetBD and BTS  ${TargetBD_buildVersion}  ${BTS_buildVersion}
    ...  ${TargetBD_buildTimestamp}  ${BTS_buildTimestamp}

    ${result}=  Run Keyword And Return Status  Should Not Be Empty  ${Newer_buildVersion}
    Return From Keyword If  ${result}  ${Newer_buildVersion}

    FOR  ${item_TargetBD}  ${item_BTS}  IN ZIP  ${TargetBD_buildTimestamp_split}  ${BTS_buildTimestamp_split}
        ${Newer_buildVersion}=  Compare RMOD buildVersion from TargetBD and BTS  ${TargetBD_buildVersion}  ${BTS_buildVersion}
        ...  ${item_TargetBD}  ${item_BTS}
    END

    ${Newer_buildVersion}=  Run Keyword If  '${Newer_buildVersion}' == 'Equal' and ${TargetBD_buildTimestamp_length} > ${BTS_buildTimestamp_length}
    ...  Set Variable  ${TargetBD_buildVersion}
    ...  ELSE IF  '${Newer_buildVersion}' == 'Equal' and ${TargetBD_buildTimestamp_length} < ${BTS_buildTimestamp_length}
    ...  Set Variable  ${BTS_buildVersion}
    ...  ELSE  Set Variable   ${Newer_buildVersion}

    [Return]  ${Newer_buildVersion}

Get RESET info from blackbox file
    [Documentation]
    ...  Get RESET timestamp and reason info from blackbox file

    [Arguments]  ${alias}  ${when}
    ${reset_reason}=  Get Reset Reason Info from blackbox file  alias=${alias}  when=${when}
    Set Test Variable  ${${alias}_reset_reason_${when}}  ${reset_reason}
    Log  Last BTS ${alias} RESET timestamp and reason: ${${alias}_reset_reason_${when}}[-1]  console=True

Get Reset Reason Info from blackbox file
    [Documentation]
    ...  Get Reset Reason Info from blackbox file
    ...
    ...  | Input Parameters | Man. | Description                                               |
    ...  | alias            | Yes  | BTS instance alias from which blackbox file is downloaded |
    ...
    ...  *RETURN VALUE*
    ...  | reset_reason_info | list of all reset reasons from blackbox file |

    [Arguments]  ${alias}  ${when}
    ${blackbox_path_file_list}=  Save BTS File  alias=${alias}   BTS_file_names=blackbox_${when} blackbox1_${when}
    ...  BTS_source_paths=/rom/logs/lifetimedata/blackbox /rom/config/lifedata/blackbox
    ...  BTS_destination_path=${BTSFiles}/${alias}/Blackbox_Files

    FOR  ${file_path}  IN  @{blackbox_path_file_list}
        ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${file_path}
        ${size}=  Run Keyword If  ${status}  OperatingSystem.Get File Size  ${file_path}
        ...  ELSE  Set Variable  0
        ${reset_counter}  ${reset_reason_info}=  Run Keyword If  '${status}' == 'True' and ${size} > 0
        ...  BlackBox.Get Reset Info From File  ${file_path}
        Return From Keyword If  '${status}' == 'True' and ${size} > 0  ${reset_reason_info}
    END

    Log  ${alias} blackbox file couldn't be saved or file is empty. Please check blackbox file existance!  level=ERROR
    Fail  ${alias} blackbox file couldn't be saved or file is empty. Please check blackbox file existance!

    [Return]  ${reset_reason_info}

Get the differences between blackbox files
    [Documentation]
    ...  Get the differences between blackbox files
    ...
    ...  | Input Parameters   | Man. | Description                                                           |
    ...  | reset_reason_info_initial | Yes  | Initial reset reason info calculated by Get RESET info from blackbox file KW |
    ...  | reset_reason_info_final   | Yes  | Final reset reason info calculated by Get RESET info from blackbox file KW   |
    ...
    ...  *RETURN VALUE*
    ...  | reset_reason_info_diff | the differences between reset_reason_info_final and reset_reason_info_initial |

    [Arguments]  ${reset_reason_info_initial}  ${reset_reason_info_final}
    ${reset_reason_info_diff}=  tools.List Diff  ${reset_reason_info_final}  ${reset_reason_info_initial}
    [Return]    ${reset_reason_info_diff}

Get feature CB007878 settings on cloud BTS
    [Documentation]
    ...  Get cloud BTS feature CB007878 parameter for RMOD: actSharedRUIndControl
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | VDU_SCF_path_file | No   | VDU SCF path file. By default None: initial VDU SCF file get in common setup phase will be taken into account |
    ...  | RMOD_sn_list      | No   | List of RMOD serial number on which feature CB007878 settings is get. By default @{EMPTY}: all configured
    ...                               RMOD will be taken into account                                                                               |
    ...  | vdu_alias         | No   | VDU connection instance alias. By default Master VDU1                                                         |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description                                                                              |
    ...  | VDU_feature_CB007878_dict | VDU feature CB007878 dict containing structure: {'<RMOD_sn>': '<actSharedRUIndControl>'} |

    [Arguments]  ${VDU_SCF_path_file}=None  ${RMOD_sn_list}=@{EMPTY}  ${vdu_alias}=Master VDU1

    ${VDU_feature_CB007878_dict}=  Create Dictionary

    ${VDU_SCF_path_file_info}=  Set Variable If  '${VDU_SCF_path_file}' == 'None'  ${${vdu_alias.lower()}_scf_initial}  ${VDU_SCF_path_file}
    ${RMOD_sn_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${RMOD_sn_list}

    ${VDU_RMOD_sn_config_dict}  ${VDU_RMOD_config_sn_dict}  ${VDU_RMOD_sn_runtime_dict}  ${VDU_RMOD_runtime_sn_dict}=
    ...  VDU Get RMOD sn config runtime info  vdu_connection=${vdu_alias}

    ${VDU_SCF_RMOD_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${VDU_SCF_path_file_info}  alias=${vdu_alias}
    Sort List  ${VDU_SCF_RMOD_list}

    FOR  ${RMOD_dn}  IN  @{VDU_SCF_RMOD_list}

        ${RMOD_sn}=  Get From Dictionary  ${VDU_RMOD_config_sn_dict}  ${RMOD_dn}

        Continue For Loop If  '${RMOD_sn_list_isEmpty}' == 'False' and '${RMOD_sn}' not in ${RMOD_sn_list}

        ${actSharedRUIndControl_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${VDU_SCF_path_file_info}  dist_name=${RMOD_dn}
        ...  p_name=actSharedRUIndControl

        ${actSharedRUIndControl_count}=  Get Length  ${actSharedRUIndControl_info_dict}
        ${actSharedRUIndControl_info}=  Run Keyword If   ${actSharedRUIndControl_count} > 0
        ...  Get From Dictionary  ${actSharedRUIndControl_info_dict}  actSharedRUIndControl
        ...  ELSE
        ...  Set Variable  NA

        Set To Dictionary  ${VDU_feature_CB007878_dict}  ${RMOD_sn}  ${actSharedRUIndControl_info}

    END

    [Return]  ${VDU_feature_CB007878_dict}

Get feature CB007878 settings on classical BTS
    [Documentation]
    ...  Get classical BTS feature CB007878 parameter for RMOD: actSharedRUIndControl
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | RMOD_sn_list      | No   | List of RMOD serial number on which feature CB007878 settings is get. By default @{EMPTY}: all configured
    ...                               RMOD will be taken into account                                                                               |
    ...  | alias             | No   | BTS connection instance alias. By default Master                                                              |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description                                                                              |
    ...  | BTS_feature_CB007878_dict | BTS feature CB007878 dict containing structure: {'<RMOD_sn>': '<actSharedRUIndControl>'} |

    [Arguments]  ${BTS_SCF_path_file}=None  ${RMOD_sn_list}=@{EMPTY}  ${alias}=Master

    ${BTS_feature_CB007878_dict}=  Create Dictionary

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${RMOD_sn_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${RMOD_sn_list}

    ${BTS_RMOD_sn_config_dn_dict}  ${BTS_RMOD_config_dn_sn_dict}=  Admin Get RMOD sn config info  alias=${alias}

    ${BTS_SCF_RMOD_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    Sort List  ${BTS_SCF_RMOD_dn_list}

    FOR  ${RMOD_dn}  IN  @{BTS_SCF_RMOD_dn_list}

        ${RMOD_sn}=  Get From Dictionary  ${BTS_RMOD_config_dn_sn_dict}  ${RMOD_dn}

        Continue For Loop If  '${RMOD_sn_list_isEmpty}' == 'False' and '${RMOD_sn}' not in ${RMOD_sn_list}

        ${actSharedRUIndControl_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}  dist_name=${RMOD_dn}
        ...  p_name=actSharedRUIndControl

        ${actSharedRUIndControl_count}=  Get Length  ${actSharedRUIndControl_info_dict}
        ${actSharedRUIndControl_info}=  Run Keyword If   ${actSharedRUIndControl_count} > 0
        ...  Get From Dictionary  ${actSharedRUIndControl_info_dict}  actSharedRUIndControl
        ...  ELSE
        ...  Set Variable  NA

        Set To Dictionary  ${BTS_feature_CB007878_dict}  ${RMOD_sn}  ${actSharedRUIndControl_info}

    END

    [Return]  ${BTS_feature_CB007878_dict}

Get BBMOD and SMOD position in subrack
    [Documentation]
    ...  Get BBMOD and SMOD position in subrack
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description                    |
    ...  | BBMOD_id  | Yes  | Runtime BBMOD id.              |
    ...  | alias     | Yes  | BTS connection instance alias. |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                                                                                                     |
    ...  | BBMOD_SMOD_info_dict | Dict containing BBMOD and its corresponding SMOD position is subrack. SMOD active role is also returned.        |
    ...                           SMOD active role possible values: Primary/Secondary in case of dual-core BTS, None in case of single-core BTS.  |
    ...                           Dict structure is as follows:                                                                                   |
    ...                           {'<BBMOD_horizontalPosition>': <number_value>, '<BBMOD_verticalPosition>': <number_value>,                      |
    ...                            '<SMOD_horizontalPosition>': <number_value>, '<SMOD_verticalPosition>': <number_value>,                        |
    ...                            '<SMOD_activeRole>': '<role>',  '<SMOD_serialNumber>': '<serial_number>'}                                      |

    [Arguments]  ${BBMOD_id}  ${alias}

    ${BBMOD_SMOD_info_dict}=  Create Dictionary

    ${BBMOD_R_info} =  coam.Get Managed Objects  class_name=BBMOD_R  connection=${alias}

    FOR  ${item}  IN  @{BBMOD_R_info}

        ${BBMOD_R_id}=  Get From Dictionary  ${item}  distName

        Run Keyword If  '${BBMOD_R_id}' == '${BBMOD_id}'  Run Keywords
        ...  Set To Dictionary  ${BBMOD_SMOD_info_dict}  BBMOD_horizontalPosition  ${item['parameters']['horizontalPosition']}
        ...  AND  Set To Dictionary  ${BBMOD_SMOD_info_dict}  BBMOD_verticalPosition  ${item['parameters']['verticalPosition']}
        ...  AND  Exit For Loop

    END

    ${SMOD_R_info} =  coam.Get Managed Objects  class_name=SMOD_R  connection=${alias}

    FOR  ${item}  IN  @{SMOD_R_info}

        ${SMOD_R_productName}=  Get From Dictionary  ${item['parameters']}  productName
        ${SMOD_R_horizontalPosition}=  Get From Dictionary  ${item['parameters']}  horizontalPosition
        ${BBMOD_R_horizontalPosition}=  Get From Dictionary  ${BBMOD_SMOD_info_dict}  BBMOD_horizontalPosition
        ${is_FSMF_SMOD}=  Run Keyword And Return Status  Should Contain  ${SMOD_R_productName}  FSMF

        Run Keyword If  '${SMOD_R_horizontalPosition}' == '${BBMOD_R_horizontalPosition}' and '${is_FSMF_SMOD}' == 'False'
        ...  Run Keywords
        ...  Set To Dictionary  ${BBMOD_SMOD_info_dict}  SMOD_horizontalPosition  ${item['parameters']['horizontalPosition']}
        ...  AND  Set To Dictionary  ${BBMOD_SMOD_info_dict}  SMOD_verticalPosition  ${item['parameters']['verticalPosition']}
        ...  AND  Set To Dictionary  ${BBMOD_SMOD_info_dict}  SMOD_activeRole  ${item['parameters']['activeRole']}
        ...  AND  Set To Dictionary  ${BBMOD_SMOD_info_dict}  SMOD_serialNumber  ${item['parameters']['serialNumber']}
        ...  AND  Exit For Loop

    END

    [Return]    ${BBMOD_SMOD_info_dict}

Get RMOD ESM feature parameter on classical BTS
    [Documentation]
    ...  Get classical BTS feature ESM parameter for RMOD: energySavingMode
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | RMOD_sn_list      | No   | List of RMOD serial number on which feature ESM parameter is get. By default @{EMPTY}: all configured RMOD
    ...                               will be taken into account                                                                                    |
    ...  | alias             | No   | BTS connection instance alias. By default Master                                                              |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                                                                    |
    ...  | BTS_ESM_feature_dict | BTS feature ESM dict containing structure: {'<RMOD_sn>': '<energySavingMode>'} |

    [Arguments]  ${BTS_SCF_path_file}=None  ${RMOD_sn_list}=@{EMPTY}  ${alias}=Master

    ${BTS_ESM_feature_dict}=  Create Dictionary

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${RMOD_sn_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${RMOD_sn_list}

    ${BTS_RMOD_sn_config_dn_dict}  ${BTS_RMOD_config_dn_sn_dict}=  Admin Get RMOD sn config info  alias=${alias}

    ${BTS_SCF_RMOD_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    Sort List  ${BTS_SCF_RMOD_dn_list}

    FOR  ${RMOD_dn}  IN  @{BTS_SCF_RMOD_dn_list}

        ${RMOD_sn}=  Get From Dictionary  ${BTS_RMOD_config_dn_sn_dict}  ${RMOD_dn}

        Continue For Loop If  '${RMOD_sn_list_isEmpty}' == 'False' and '${RMOD_sn}' not in ${RMOD_sn_list}

        ${energySavingMode_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}  dist_name=${RMOD_dn}
        ...  p_name=energySavingMode

        ${energySavingMode_count}=  Get Length  ${energySavingMode_info_dict}
        ${energySavingMode_info}=  Run Keyword If   ${energySavingMode_count} > 0
        ...  Get From Dictionary  ${energySavingMode_info_dict}  energySavingMode
        ...  ELSE
        ...  Set Variable  NA

        Set To Dictionary  ${BTS_ESM_feature_dict}  ${RMOD_sn}  ${energySavingMode_info}

    END

    [Return]  ${BTS_ESM_feature_dict}

Set RMOD ESM feature parameter on classical BTS
    [Documentation]
    ...  Set classical BTS feature ESM parameter for RMOD: energySavingMode
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Description                                                  |
    ...  | ESM_parameter_name  | Yes  | BTS ESM feature parameter name, by default energySavingMode  |
    ...  | ESM_parameter_value | Yes  | BTS ESM feature parameter value for requested parameter name |
    ...  | RMOD_sn             | Yes  | BTS ESM feature parameter name                               |
    ...  | alias               | Yes  | BTS instance alias                                           |
	...
	[Arguments]  ${ESM_parameter_name}  ${ESM_parameter_value}  ${RMOD_sn}  ${alias}
	${RMOD_sn_list}=  Create List  ${RMOD_sn}
    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_ESM_feature_dict}=  Get RMOD ESM feature parameter on classical BTS  BTS_SCF_path_file=${BTS_SCF_path_file_info}
    ...  RMOD_sn_list=${RMOD_sn_list}  alias=${alias}
    ${BTS_ESM_parameter_value}=  Get From Dictionary  ${BTS_ESM_feature_dict}  ${RMOD_sn}
    Run Keyword If  '${BTS_ESM_parameter_value}' == '${ESM_parameter_value}'  Run Keywords
    ...  Log  Parameter ${ESM_parameter_name} already set on BTS ${alias}: ${BTS_ESM_parameter_value}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${BTS_RMOD_sn_config_dn_dict}  ${BTS_RMOD_config_dn_sn_dict}=  Admin Get RMOD sn config info  alias=${alias}

    ${BTS_SCF_RMOD_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    Sort List  ${BTS_SCF_RMOD_dn_list}

    FOR  ${BTS_SCF_RMOD_dn}  IN  @{BTS_SCF_RMOD_dn_list}

        ${BTS_RMOD_sn}=  Get From Dictionary  ${BTS_RMOD_config_dn_sn_dict}  ${BTS_SCF_RMOD_dn}

        Continue For Loop If  '${BTS_RMOD_sn}' != '${RMOD_sn}'

        coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_RMOD_dn}  parameter=${ESM_parameter_name}  operation=update
        ...  value=${ESM_parameter_value}  skip_parameter_relation_errors=False  should_activate=True  alias=${alias}

        Exit For Loop

    END

    Sleep  5s

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_ESM_feature_dict}=  Get RMOD ESM feature parameter on classical BTS  BTS_SCF_path_file=${BTS_SCF_path_file_info}
    ...  RMOD_sn_list=${RMOD_sn_list}  alias=${alias}
    ${BTS_ESM_parameter_value}=  Get From Dictionary  ${BTS_ESM_feature_dict}  ${RMOD_sn}
    Run Keyword If  '${BTS_ESM_parameter_value}' == '${ESM_parameter_value}'
    ...  Log  Parameter ${ESM_parameter_name} set on BTS ${alias}: ${BTS_ESM_parameter_value}, successfully commissioning!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter ${ESM_parameter_name} not properly set on BTS ${alias}! (expected/found value:
    ...  ${ESM_parameter_value}/${BTS_ESM_parameter_value})  console=True
    ...  AND  Fail  Parameter ${ESM_parameter_name} not properly set on BTS ${alias}!

Current Run Summary
    ${runs_status}=  Run Keyword And Return Status  Variable Should Exist  ${runs}
    Return From Keyword If  not ${runs_status}

    ${current_run}=  Evaluate  ${testresultdir_count} - 1
    Log  Current Run Summary:  console=True
    Log  ${TEST NAME} | Run ${current_run} | Status ${TEST STATUS}  console=True
    ${test_summary_dict}=  Get Variable Value  ${test_summary_dict}  &{EMPTY}
    Set To Dictionary  ${test_summary_dict}  ${current_run}  ${TEST STATUS}
    Set Test Variable  ${test_summary_dict}

    Run Keyword If  ${stop_run} and '${TEST STATUS}' == 'FAIL'
    ...  Fail  test failed due to stop on failed run during execution

Test Run Summary
    ${runs_status}=  Run Keyword And Return Status  Variable Should Exist  ${runs}
    Return From Keyword If  not ${runs_status}

    ${current_run}=  Evaluate  ${testresultdir_count} - 1
    Return From Keyword If  ${current_run} != ${runs}

    Log  Test Run Summary:  console=True
    ${tc_runs_verdict}=  Set Variable  PASS

    FOR  ${key}  ${value}  IN  &{test_summary_dict}

        Log  ${TEST NAME} | Run ${key} | Status ${value}  console=True
        ${tc_runs_verdict}=  Set Variable If  '${value}' == 'FAIL'  FAIL  ${tc_runs_verdict}

    END

    Run Keyword If  '${tc_runs_verdict}' == 'FAIL'
    ...  Fail  test failed due to at least one failed run during execution

Get RMOD CELL mapping based on Carrier info
    [Documentation]
    ...  Keyword providing RMOD CELL mapping based on Carrier info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | Yes  |         | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                                                   |
    ...  | RMOD_id_CELL_id_dict | dict with RMOD id as key and list of mapped CELLs id as value |
    ...
    [Arguments]  ${alias}

    ${RMOD_id_CELL_id_dict}=  Create Dictionary

    ${BTS_info}=  Get Bts Info  connection=${alias}

    ${RMOD_id_Carrier_dict}=  Get RMOD Carrier list info dict  bts_info=${BTS_info}
    ${NR_CELL_id_Carrier_dict}=  Get CELL Carrier list info dict  bts_info=${BTS_info}  cell_type=nr
    ${LTE_CELL_id_Carrier_dict}=  Get CELL Carrier list info dict  bts_info=${BTS_info}  cell_type=lte
    ${WCDMA_CELL_id_Carrier_dict}=  Get CELL Carrier list info dict  bts_info=${BTS_info}  cell_type=wcdma
    ${GSM_CELL_id_Carrier_dict}=  Get CELL Carrier list info dict  bts_info=${BTS_info}  cell_type=gsm

    ${CELL_id_Carrier_dict}=  Create Dictionary  &{NR_CELL_id_Carrier_dict}  &{LTE_CELL_id_Carrier_dict}  &{WCDMA_CELL_id_Carrier_dict}
    ...  &{GSM_CELL_id_Carrier_dict}
    ${Carrier_CELL_id_dict}=  Get Carrier CELL info dict  cell_id_carrier_dict=${CELL_id_Carrier_dict}

    FOR  ${RMOD_id}  ${carrier_list}  IN  &{RMOD_id_carrier_dict}

        ${CELL_id_list}=  Get CELL based on Carrier list info  carrier_list=${carrier_list}  carrier_cell_id_dict=${Carrier_CELL_id_dict}
        Set To Dictionary  ${RMOD_id_CELL_id_dict}  ${RMOD_id}  ${CELL_id_list}

    END

    [Return]  ${RMOD_id_CELL_id_dict}

Get RMOD Carrier list info dict
    [Arguments]  ${bts_info}

    ${RMOD_id_Carrier_dict}=  Create Dictionary

    FOR  ${item}  IN  @{bts_info['radioModules']['rmod']}

        ${RMOD_Carrier_list}=  Get Carrier list info  ${item['carrierList']}
        Set To Dictionary  ${RMOD_id_carrier_dict}  ${item['id']['internal']}  ${RMOD_carrier_list}

    END

    [Return]  ${RMOD_id_carrier_dict}

Get CELL Carrier list info dict
    [Arguments]  ${bts_info}  ${cell_type}

    ${cell_type}=  Set Variable  ${cell_type}
    ${CELL_id_carrier_dict}=  Create Dictionary

    FOR  ${item}  IN  @{bts_info['cells']['${cell_type}']}

        ${CELL_carrier_list}=  Get Carrier list info  ${item['carrierList']}
        Set To Dictionary  ${CELL_id_carrier_dict}  ${item['id']['internal']}  ${CELL_carrier_list}

    END

    [Return]  ${CELL_id_carrier_dict}

Get Carrier list info
    [Arguments]  ${carrierList_info}

    ${Carrier_list}=  Create List

    FOR  ${item}  IN  @{carrierList_info}

        Append To List  ${Carrier_list}  ${item['id']['configuration']}

    END

    ${Carrier_list}=  Remove Duplicates  ${Carrier_list}
    Sort List  ${Carrier_list}

    [Return]  ${Carrier_list}

Get Carrier CELL info dict
    [Arguments]  ${cell_id_carrier_dict}

    ${all_Carrier_CELL_id_dict}=  Create Dictionary

    FOR  ${CELL_id}  ${carrier_list}  IN  &{cell_id_carrier_dict}

        ${Carrier_CELL_id_dict}=  Set Carrier CELL info dict  carrier_list=${carrier_list}  cell_id=${CELL_id}
        Set To Dictionary  ${all_Carrier_CELL_id_dict}  &{Carrier_CELL_id_dict}

    END

    [Return]  ${all_Carrier_CELL_id_dict}

Set Carrier CELL info dict
    [Arguments]  ${carrier_list}  ${cell_id}

    ${Carrier_CELL_id_dict}=  Create Dictionary

    FOR  ${carrier}  IN  @{carrier_list}

        Set To Dictionary  ${Carrier_CELL_id_dict}  ${carrier}  ${cell_id}

    END

    [Return]  ${Carrier_CELL_id_dict}

Get CELL based on Carrier list info
    [Arguments]  ${carrier_list}  ${carrier_cell_id_dict}

    ${CELL_id_list}=  Create List

    FOR  ${carrier}  IN  @{carrier_list}

        ${CELL_id}=  Get From Dictionary  ${carrier_cell_id_dict}  ${carrier}
        Append To List  ${CELL_id_list}  ${CELL_id}

    END

    ${CELL_id_list}=  Remove Duplicates  ${CELL_id_list}
    Sort List  ${CELL_id_list}

    [Return]  ${CELL_id_list}

Get actValidationOnUpgrade parameter value
    [Documentation]
    ...  Get actValidationOnUpgrade parameter value
    ...
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | actValidationOnUpgrade | parameter value: true or false |

    [Arguments]  ${alias}

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0
    ${actValidationOnUpgrade_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${scf_path}  dist_name=${BTS_SCF_dn}
    ...  p_name=actValidationOnUpgrade
    ${actValidationOnUpgrade_count}=  Get Length  ${actValidationOnUpgrade_info_dict}
    ${actValidationOnUpgrade}=  Run Keyword If  ${actValidationOnUpgrade_count} > 0
    ...  Get From Dictionary  ${actValidationOnUpgrade_info_dict}  actValidationOnUpgrade
    ...  ELSE
    ...  Set Variable  none

    [Return]  ${actValidationOnUpgrade}

Set actValidationOnUpgrade parameter value
    [Documentation]
    ...  Set actValidationOnUpgrade parameter value: true or false on BTS
    ...
    ...  *INPUT*
    ...  | Parameter              | Man. | Description                    |
    ...  | alias                  | Yes  | admin instance alias           |
    ...  | actValidationOnUpgrade | Yes  | parameter value: true or false |


    [Arguments]  ${actValidationOnUpgrade}  ${alias}

    ${actValidationOnUpgrade_value}=  Get actValidationOnUpgrade parameter value  ${alias}

    Run Keyword If  '${actValidationOnUpgrade_value}' == '${actValidationOnUpgrade}'  Run Keywords
    ...  Log  Parameter actValidationOnUpgrade: ${actValidationOnUpgrade_value} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0

    coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=actValidationOnUpgrade  operation=update
    ...  value=${actValidationOnUpgrade}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    ${actValidationOnUpgrade_value}=  Get actValidationOnUpgrade parameter value  ${alias}

    Run Keyword If  '${actValidationOnUpgrade_value}' == '${actValidationOnUpgrade}'
    ...  Log  Parameter actValidationOnUpgrade set on BTS ${alias}: ${actValidationOnUpgrade_value}, successfully commissioned!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter actValidationOnUpgrade not properly set on BTS ${alias}! (expected/found value:
    ...  ${actValidationOnUpgrade}/${actValidationOnUpgrade_value})  console=True
    ...  AND  Fail  Parameter actValidationOnUpgrade not properly set on BTS ${alias}!

Get RMOD climate control profiling setting on BTS primary controller
    [Arguments]  ${RMOD_sn}  ${alias}  ${BTS_SCF_path_file}=None

    ${RMOD_climateControlProfiling}=  Run Keyword If  '${alias}' in ${alias_list}
    ...  Get RMOD climate control profiling setting on classical BTS  ${RMOD_sn}  ${alias}  ${BTS_SCF_path_file}
    ...  ELSE
    ...  Get RMOD climate control profiling setting on cloud BTS  ${RMOD_sn}  ${alias}  ${BTS_SCF_path_file}

    [Return]  ${RMOD_climateControlProfiling}

Get RMOD climate control profiling setting on classical BTS
    [Arguments]  ${RMOD_sn}  ${alias}  ${BTS_SCF_path_file}=None

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}

    ${BTS_RMOD_sn_config_dn_dict}  ${BTS_RMOD_config_dn_sn_dict}=  Admin Get RMOD sn config info  alias=${alias}

    ${BTS_SCF_RMOD_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}

    FOR  ${RMOD_dn}  IN  @{BTS_SCF_RMOD_dn_list}

        ${RMOD_serialNumber}=  Get From Dictionary  ${BTS_RMOD_config_dn_sn_dict}  ${RMOD_dn}

        Continue For Loop If  '${RMOD_serialNumber}' != '${RMOD_sn}'

        ${climateControlProfiling_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
        ...  dist_name=${RMOD_dn}  p_name=climateControlProfiling

        ${climateControlProfiling_count}=  Get Length  ${climateControlProfiling_info_dict}
        ${climateControlProfiling_info}=  Run Keyword If   ${climateControlProfiling_count} > 0
        ...  Get From Dictionary  ${climateControlProfiling_info_dict}  climateControlProfiling
        ...  ELSE
        ...  Set Variable  NA

    END

    [Return]  ${climateControlProfiling_info}

Get RMOD climate control profiling setting on cloud BTS
    [Arguments]  ${RMOD_sn}  ${vdu_alias}  ${VDU_SCF_path_file}=None

    ${VDU_SCF_path_file_info}=  Set Variable If  '${VDU_SCF_path_file}' == 'None'  ${${vdu_alias.lower()}_scf_initial}  ${VDU_SCF_path_file}

    ${VDU_RMOD_sn_config_dict}  ${VDU_RMOD_config_sn_dict}  ${VDU_RMOD_sn_runtime_dict}  ${VDU_RMOD_runtime_sn_dict}=
    ...  VDU Get RMOD sn config runtime info  vdu_connection=${vdu_alias}

    ${VDU_SCF_RMOD_list}=  Get All Dist Names By Pattern from SCF  pattern=/RMOD-[\\d]+$  scf_path=${VDU_SCF_path_file_info}  alias=${vdu_alias}

    FOR  ${RMOD_dn}  IN  @{VDU_SCF_RMOD_list}

        ${RMOD_serialNumber}=  Get From Dictionary  ${VDU_RMOD_config_sn_dict}  ${RMOD_dn}

        Continue For Loop If  '${RMOD_serialNumber}' != '${RMOD_sn}'

        ${climateControlProfiling_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${VDU_SCF_path_file_info}
        ...  dist_name=${RMOD_dn}  p_name=climateControlProfiling

        ${climateControlProfiling_count}=  Get Length  ${climateControlProfiling_info_dict}
        ${climateControlProfiling_info}=  Run Keyword If   ${climateControlProfiling_count} > 0
        ...  Get From Dictionary  ${climateControlProfiling_info_dict}  climateControlProfiling
        ...  ELSE
        ...  Set Variable  NA

    END

    [Return]  ${climateControlProfiling_info}

Set RMOD climateControlProfiling parameter on classical BTS
    [Arguments]  ${RMOD_climateControlProfiling_value}  ${RMOD_sn}  ${alias}

    Log  ***** Set RMOD_${RMOD_sn} climateControlProfiling: ${RMOD_climateControlProfiling_value} on ${alias} BTS *****  console=True

    ${operation}=  Set Variable If  '${RMOD_climateControlProfiling_value}' == 'NA'  delete  update

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${RMOD_climateControlProfiling}=  Get RMOD climate control profiling setting on BTS primary controller  ${RMOD_sn}  ${alias}
    ...  ${BTS_SCF_path_file_info}
    Run Keyword If  '${RMOD_climateControlProfiling}' == '${RMOD_climateControlProfiling_value}'  Run Keywords
    ...  Log  Parameter climateControlProfiling already set on ${alias} BTS: ${RMOD_climateControlProfiling_value}, commissioning not needed!
    ...  console=True
    ...  AND  Return From Keyword

    ${BTS_RMOD_sn_config_dn_dict}  ${BTS_RMOD_config_dn_sn_dict}=  Admin Get RMOD sn config info  alias=${alias}
    ${RMOD_dn}=  Get From Dictionary  ${BTS_RMOD_sn_config_dn_dict}  ${RMOD_sn}

    coam.Perform Parameter Recommissioning  dist_name=${RMOD_dn}  parameter=climateControlProfiling  operation=${operation}
    ...  value=${RMOD_climateControlProfiling_value}  skip_parameter_relation_errors=False  should_activate=True  alias=${alias}

    Sleep  5s

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${RMOD_climateControlProfiling}=  Get RMOD climate control profiling setting on BTS primary controller  ${RMOD_sn}  ${alias}
    ...  ${BTS_SCF_path_file_info}
    Run Keyword If  '${RMOD_climateControlProfiling}' == '${RMOD_climateControlProfiling_value}'
    ...  Log  Parameter climateControlProfiling set on ${alias} BTS: ${RMOD_climateControlProfiling}, successfully commissioning!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter climateControlProfiling not properly set on ${alias} BTS! (expected/found value:
    ...  ${RMOD_climateControlProfiling_value}/${RMOD_climateControlProfiling})  console=True
    ...  AND  Fail  Parameter climateControlProfiling not properly set on ${alias} BTS!

Set RMOD climateControlProfiling parameter on cloud BTS
    [Arguments]  ${RMOD_climateControlProfiling_value}  ${RMOD_sn}  ${vdu_alias}

    Log  ***** Set RMOD_${RMOD_sn} climateControlProfiling: ${RMOD_climateControlProfiling_value} on ${vdu_alias} *****  console=True

    ${operation}=  Set Variable If  '${RMOD_climateControlProfiling_value}' == 'NA'  delete  update

    ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  vdu_connection=${vdu_alias}
    ${RMOD_climateControlProfiling}=  Get RMOD climate control profiling setting on BTS primary controller  ${RMOD_sn}  ${vdu_alias}
    ...  ${VDU_SCF_path_file_info}
    Run Keyword If  '${RMOD_climateControlProfiling}' == '${RMOD_climateControlProfiling_value}'  Run Keywords
    ...  Log  Parameter climateControlProfiling already set on ${vdu_alias}: ${RMOD_climateControlProfiling_value}, commissioning not needed!
    ...  console=True
    ...  AND  Return From Keyword

    ${VDU_RMOD_sn_config_dict}  ${VDU_RMOD_config_sn_dict}  ${VDU_RMOD_sn_runtime_dict}  ${VDU_RMOD_runtime_sn_dict}=
    ...  VDU Get RMOD sn config runtime info  vdu_connection=${vdu_alias}
    ${RMOD_dn}=  Get From Dictionary  ${VDU_RMOD_sn_config_dict}  ${RMOD_sn}

    VDU Perform Parameter Recommissioning  dist_name=${RMOD_dn}  parameter=climateControlProfiling  operation=${operation}
    ...  value=${RMOD_climateControlProfiling_value}  should_activate=True  timeout=300  vdu_connection=${vdu_alias}

    Sleep  5s

    ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  vdu_connection=${vdu_alias}
    ${RMOD_climateControlProfiling}=  Get RMOD climate control profiling setting on BTS primary controller  ${RMOD_sn}  ${vdu_alias}
    ...  ${VDU_SCF_path_file_info}
    Run Keyword If  '${RMOD_climateControlProfiling}' == '${RMOD_climateControlProfiling_value}'
    ...  Log  Parameter climateControlProfiling set on ${vdu_alias}: ${RMOD_climateControlProfiling}, successfully commissioning!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter climateControlProfiling not properly set on ${vdu_alias}! (expected/found value:
    ...  ${RMOD_climateControlProfiling_value}/${RMOD_climateControlProfiling})  console=True
    ...  AND  Fail  Parameter climateControlProfiling not properly set on ${vdu_alias}!

Get BTS TFM feature parameters
    [Documentation]
    ...  Get BTS TFM feature parameters: actTempFhsPrimController, tempFhsPrimControllerTriggerTime
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | alias             | No   | BTS connection instance alias                                                                                 |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                                                                                  |
    ...  | BTS_TFM_feature_dict | BTS TFM feature dict containing structure: {'<TFM_parameter_name>': '<TFM_parameter_value>'} |

    [Arguments]  ${BTS_SCF_path_file}=None  ${alias}=None
    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0

    ${actTempFhsPrimController_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_FEATCADM_dn}  p_name=actTempFhsPrimController

    ${actTempFhsPrimController_count}=  Get Length  ${actTempFhsPrimController_dict}
    ${actTempFhsPrimController_info}=  Run Keyword If  ${actTempFhsPrimController_count} > 0
    ...  Get From Dictionary  ${actTempFhsPrimController_dict}  actTempFhsPrimController
    ...  ELSE
    ...  Set Variable  NA

    ${tempFhsPrimControllerTriggerTime_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_FEATCADM_dn}  p_name=tempFhsPrimControllerTriggerTime

    ${tempFhsPrimControllerTriggerTime_count}=  Get Length  ${tempFhsPrimControllerTriggerTime_dict}
    ${tempFhsPrimControllerTriggerTime_info}=  Run Keyword If  ${actTempFhsPrimController_count} > 0
    ...  Get From Dictionary  ${tempFhsPrimControllerTriggerTime_dict}  tempFhsPrimControllerTriggerTime
    ...  ELSE
    ...  Set Variable  NA

    ${BTS_TFM_feature_dict}=  Create Dictionary  actTempFhsPrimController=${actTempFhsPrimController_info}
    ...  tempFhsPrimControllerTriggerTime=${tempFhsPrimControllerTriggerTime_info}

    [Return]  ${BTS_TFM_feature_dict}

Set BTS TFM feature parameter
    [Documentation]
    ...  Set BTS TFM feature parameters: actTempFhsPrimController or tempFhsPrimControllerTriggerTime
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Description                                                                                  |
    ...  | TFM_parameter_name  | Yes  | BTS TFM feature parameter name: actTempFhsPrimController or tempFhsPrimControllerTriggerTime |
    ...  | TFM_parameter_value | No   | BTS TFM feature parameter value for requested parameter name                                 |
    ...  | alias               | No   | BTS instance alias                                                                           |
	...
	[Arguments]  ${TFM_parameter_name}  ${TFM_parameter_value}  ${alias}
    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_TFM_feature_dict}=  Get BTS TFM feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_TFM_parameter_value}=  Get From Dictionary  ${BTS_TFM_feature_dict}  ${TFM_parameter_name}
    Run Keyword If  '${BTS_TFM_parameter_value}' == '${TFM_parameter_value}'  Run Keywords
    ...  Log  Parameter ${TFM_parameter_name} already set on ${alias} BTS: ${BTS_TFM_parameter_value}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0
    coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_FEATCADM_dn}  parameter=${TFM_parameter_name}  operation=update
    ...  value=${TFM_parameter_value}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}

    Sleep  5s

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_TFM_feature_dict}=  Get BTS TFM feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_TFM_parameter_value}=  Get From Dictionary  ${BTS_TFM_feature_dict}  ${TFM_parameter_name}
    Run Keyword If  '${BTS_TFM_parameter_value}' == '${TFM_parameter_value}'
    ...  Log  Parameter ${TFM_parameter_name} set on ${alias} BTS: ${BTS_TFM_parameter_value}, successfully commissioning!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter ${TFM_parameter_name} not properly set on ${alias} BTS! (expected/found value:
    ...  ${TFM_parameter_value}/${BTS_TFM_parameter_value})  console=True
    ...  AND  Fail  Parameter ${TFM_parameter_name} not properly set on ${alias} BTS!

Get all BTS controller role for configured FHS from SCF
    [Documentation]
    ...  Keyword providing classical BTS controller role for configured FHS from SCF:
    ...  - with CB009828: based on sharingConfig.controllerRole info
    ...  - without CB009828: based on primaryControllerDN info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description                   |
    ...  | alias     | Yes  |         | BTS connection instance alias |
    ...
    ...  *RETURN*
    ...  | Parameter                           | Description                                                           |
    ...  | all_BTS_controller_role_FHS_sn_dict | Dictionary containing structure:
    ...                                          - {<BTS_alias>:{'BTS_primary_controller_FHS_sn_list': [<FHS_sn>]},
    ...                                                          {'BTS_secondary_controller_FHS_sn_list': [<FHS_sn>]}} |
    ...

    ${all_BTS_controller_role_FHS_sn_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_controller_FHS_sn_dict}=  Get classical BTS controller role for configured FHS from SCF  alias=${alias}
        Set To Dictionary  ${all_BTS_controller_role_FHS_sn_dict}  ${alias}=${BTS_controller_FHS_sn_dict}

    END

    [Return]  ${all_BTS_controller_role_FHS_sn_dict}

Get classical BTS controller role for configured FHS from SCF
    [Documentation]
    ...  Keyword providing classical BTS controller role for configured FHS from SCF:
    ...  - with CB009828: based on sharingConfig.controllerRole info
    ...  - without CB009828: based on primaryControllerDN info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description                   |
    ...  | alias     | Yes  |         | BTS connection instance alias |
    ...
    ...  *RETURN*
    ...  | Parameter                  | Description                                             |
    ...  | BTS_controller_FHS_sn_dict | Dictionary containing structure:
    ...                                 - {'BTS_primary_controller_FHS_sn_list': [<FHS_sn>]},
    ...                                   {'BTS_secondary_controller_FHS_sn_list': [<FHS_sn>]}} |

    [Arguments]  ${alias}

    ${BTS_SCF_path_file}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${BTS_CB009828_feature_dict}=  Get BTS CB009828 feature parameters  BTS_SCF_path_file=${BTS_SCF_path_file}  alias=${alias}
    ${actRfsConfigPerUnit_info}=  Get From Dictionary  ${BTS_CB009828_feature_dict}  actRfsConfigPerUnit

    ${BTS_primary_controller_FHS_sn_list}  ${BTS_secondary_controller_FHS_sn_list}=
    ...  Run Keyword If  '${actRfsConfigPerUnit_info}' == 'true'
    ...  Get classical BTS controller role for configured FHS from SCF with CB009828  BTS_SCF_path_file=${BTS_SCF_path_file}  alias=${alias}
    ...  ELSE
    ...  Get classical BTS controller role for configured FHS from SCF without CB009828  BTS_SCF_path_file=${BTS_SCF_path_file}  alias=${alias}

    ${BTS_controller_FHS_sn_dict}=  Create Dictionary
    ...  BTS_primary_controller_FHS_sn_list=${BTS_primary_controller_FHS_sn_list}
    ...  BTS_secondary_controller_FHS_sn_list=${BTS_secondary_controller_FHS_sn_list}

    [Return]  ${BTS_controller_FHS_sn_dict}

Get RU SW Upgrade feature info
    [Documentation]
    ...  Keyword providing RU SW Upgrade feature from SCF info: CB010780 or CB013660
    ...  - CB010780: based on sequentialRuSwUpgrade parameter
    ...  - CB013660: based on ruPhaseSwActivationResetPolicy info
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description          |
    ...  | alias     | Yes  |         | admin instance alias |
    ...
    ...  *RETURN*
    ...  | Parameter           | Description                                   |
    ...  | RuSwUpgrade_feature | CB010780, CB013660, CB010780_CB013660 or none |
    ...
    [Arguments]  ${alias}

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${MNL_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/MNL-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${MNL_dn}=  Get From List  ${MNL_dn_list}  0

    ${sequentialRuSwUpgrade_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${MNL_dn}
    ...  p_name=sequentialRuSwUpgrade
    ${sequentialRuSwUpgrade_count}=  Get Length  ${sequentialRuSwUpgrade_info_dict}
    ${sequentialRuSwUpgrade}=  Run Keyword If  ${sequentialRuSwUpgrade_count} > 0
    ...  Get From Dictionary  ${sequentialRuSwUpgrade_info_dict}  sequentialRuSwUpgrade
    ...  ELSE
    ...  Set Variable  none

    ${ruPhaseSwActivationResetPolicy_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${MNL_dn}
    ...  p_name=ruPhaseSwActivationResetPolicy
    ${ruPhaseSwActivationResetPolicy_count}=  Get Length  ${ruPhaseSwActivationResetPolicy_info_dict}
    ${ruPhaseSwActivationResetPolicy}=  Run Keyword If  ${ruPhaseSwActivationResetPolicy_count} > 0
    ...  Get From Dictionary  ${ruPhaseSwActivationResetPolicy_info_dict}  ruPhaseSwActivationResetPolicy
    ...  ELSE
    ...  Set Variable  none

    ${RuSwUpgrade_feature}=  Set Variable If
    ...  '${sequentialRuSwUpgrade}' != 'none' and '${ruPhaseSwActivationResetPolicy}' == 'none'  CB010780
    ...  '${sequentialRuSwUpgrade}' == 'none' and '${ruPhaseSwActivationResetPolicy}' != 'none'  CB013660
    ...  '${sequentialRuSwUpgrade}' == 'none' and '${ruPhaseSwActivationResetPolicy}' == 'none'  none
    ...  '${sequentialRuSwUpgrade}' != 'none' and '${ruPhaseSwActivationResetPolicy}' != 'none'  CB010780_CB013660

    [Return]  ${RuSwUpgrade_feature}

NetAct Import SW build from WFT to Netact
    [Documentation]
    ...  Keyword will perform Import SW build from WFT to Netact
    ...
    ...  *INPUT*
    ...  | Parameter    | Man. | Default                            | Description                                                                |
    ...  | local_dir    | No   | /home/ute/btsauto/TARGET_SW_MASTER | Full path where to store the SW build on VM.                               |
    ...  |                                                            Default value: /home/ute/btsauto/TARGET_SW_MASTER                          |
    ...  | package_name | No   | EMPTY                              | Leave default value Empty for automatic detection based on Single run form |
    ...  |                                                            or WFT SW name; ex: SBTS00_ENB_9999_240910_000009                          |
    ...  | remote_dir   | No   | /d/oss/global/swmanager/swm_temp   | Full path to NetAct software temporary storage                             |
    ...
    [Arguments]  ${local_dir}=/home/ute/btsauto/TARGET_SW_MASTER  ${package_name}=${EMPTY}  ${remote_dir}=/d/oss/global/swmanager/swm_temp

    ${web_url}=  netact.Detect Web URL  alias=Netact_node
    ${netact_name}=  String.Fetch From Left  ${web_url}  lb

    Download And Set Current SW for SWDL  Target_SW_dir=${local_dir}  preloaded_package=${package_name}

    ${package_name}=  Set Variable  ${Target Package Name}
    ${local_package_path}=  Set Variable  ${Target SW}

    Log  Start Import ${package_name} SW build from VM to Netact_${netact_name} at ${remote_dir}  console=True

    ${import_status}=  Run Keyword And Return Status  netact.Import Build   build_or_file_path=${local_package_path}  alias=Netact_node

    Run Keyword If  ${import_status}
    ...  Log  Import ${package_name} SW build from VM to Netact_${netact_name} at ${remote_dir} completed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${package_name} SW build could not be imported from VM to Netact_${netact_name} at ${remote_dir}!  level=ERROR
    ...  AND  Fail  ${package_name} SW build could not be imported from VM to Netact_${netact_name} at ${remote_dir}!

    [Teardown]  OperatingSystem.Remove File  ${local_package_path}

NetAct Export BTS Configuration Plan to VM
    [Documentation]
    ...  Helper keyword used to export BTS Configuration Plan from NetAct to VM
    ...
    ...  *INPUT*
    ...  | Parameter      | Man. | Description                                                                                                     |
    ...  | local_dir      | Yes  | Path to local directory where NetAct plan should be stored                                                      |
    ...  | file_name      | Yes  | File name for local stored plan                                                                                 |
    ...  | dist_names     | Yes  | MO distName                                                                                                     |
    ...  | plan_name      | No   | Specifies the plan name. Mandatory when the operation_type is set as plan. Otherwise it is optional.            |
    ...  | operation_type | No   | Specifies the type of the export operation (plan/actual/reference/template/siteTemplate). Default value: actual |
    ...  | file_format    | No   | Specifies a file format (RAML2/CSV/XLSX). Default value: RAML2                                                  |
    ...  | alias          | Yes  | admin instance alias                                                                                            |
    ...
    [Arguments]  ${local_dir}  ${file_name}  ${dist_names}  ${plan_name}=default  ${operation_type}=actual  ${file_format}=RAML2  ${alias}=default

    ${local_dir_status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${local_dir}
    Run Keyword If  not ${local_dir_status}  Create Directory  ${local_dir}

    Log  Start to Export BTS ${alias} Configuration Plan from NetAct to VM at ${local_dir}  console=True

    netact.Export Configuration  local_dir=${local_dir}  file_name=${file_name}  dist_names=${dist_names}  plan_name=${plan_name}
    ...  operation_type=${operation_type}  file_format=${file_format}  alias=Netact_node

    ${file_exists_status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${local_dir}/${file_name}
    Run Keyword If  ${file_exists_status}
    ...  Log  BTS ${alias} Configuration Plan available at ${local_dir}/${file_name}  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS ${alias} Configuration Plan not available at ${local_dir}/${file_name}!  level=ERROR
    ...  AND  Fail  BTS ${alias} Configuration Plan not available at ${local_dir}/${file_name}!

NetAct Prepare Unified PNP coam Site
    [Documentation]
    ...  Helper keyword used to Prepare Unified PNP coam Site
    ...
    ...  *INPUT*
    ...  | Parameter      | Man. | Description                                                                                                     |
    ...  | local_dir      | Yes  | Path to local directory where BTS Configuration plan is stored                                                  |
    ...  | input_file     | Yes  | File name for local stored plan                                                                                 |
    ...  | plan_name      | Yes  | Specifies the plan name                                                                                         |
    ...  | alias          | Yes  | admin instance alias                                                                                            |
    ...
    [Arguments]  ${local_dir}  ${input_file}  ${plan_name}  ${alias}=default

    OperatingSystem.File Should Exist  ${local_dir}/${input_file}

    Log  Start to Prepare Unified PNP coam Site for BTS ${alias} Configuration Plan ${local_dir}/${input_file}  console=True

    ${pnp_status}  ${return}=  Run Keyword And Ignore Error
    ...  netact.Prepare Unified PNP coam Site  plan_name=${plan_name}  input_file=${input_file}
    ...  local_dir=${local_dir}  alias=Netact_node
    ${validation_result}=  Run Keyword and Return Status  Should Contain  ${return}  Status received: Finished

    Run Keyword If  '${pnp_status}' == 'PASS' and ${validation_result}
    ...  Log  Prepare Unified PNP coam Site for BTS ${alias} Configuration Plan ${local_dir}/${input_file} succesfully performed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Prepare Unified PNP coam Site for BTS ${alias} Configuration Plan ${local_dir}/${input_file} could not be performed!  level=ERROR
    ...  AND  Fail  Prepare Unified PNP coam Site for BTS ${alias} Configuration Plan ${local_dir}/${input_file} could not be performed!

Get sequentialRuSwUpgrade parameter value
    [Documentation]
    ...  Get BTS sequentialRuSwUpgrade parameter value: true, false or none
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | sequentialRuSwUpgrade | parameter value: true, false or none |
    ...
    [Arguments]  ${alias}

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${MNL_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/MNL-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${MNL_dn}=  Get From List  ${MNL_dn_list}  0

    ${sequentialRuSwUpgrade_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${MNL_dn}
    ...  p_name=sequentialRuSwUpgrade
    ${sequentialRuSwUpgrade_count}=  Get Length  ${sequentialRuSwUpgrade_info_dict}
    ${sequentialRuSwUpgrade}=  Run Keyword If  ${sequentialRuSwUpgrade_count} > 0
    ...  Get From Dictionary  ${sequentialRuSwUpgrade_info_dict}  sequentialRuSwUpgrade
    ...  ELSE
    ...  Set Variable  none

    [Return]  ${sequentialRuSwUpgrade}

Set sequentialRuSwUpgrade parameter value
    [Documentation]
    ...  Set BTS sequentialRuSwUpgrade parameter value: true, false or none
    ...
    ...  *INPUT*
    ...  | Parameter             | Man. | Description                          |
    ...  | alias                 | Yes  | admin instance alias                 |
    ...  | sequentialRuSwUpgrade | Yes  | parameter value: true, false or none |
    ...
    [Arguments]  ${sequentialRuSwUpgrade}  ${alias}

    ${sequentialRuSwUpgrade_value}=  Get sequentialRuSwUpgrade parameter value  ${alias}
    Run Keyword If  '${sequentialRuSwUpgrade_value}' == '${sequentialRuSwUpgrade}'  Run Keywords
    ...  Log  Parameter sequentialRuSwUpgrade: ${sequentialRuSwUpgrade_value} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${MNL_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/MNL-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${MNL_dn}=  Get From List  ${MNL_dn_list}  0
    ${operation}=  Set Variable If  '${sequentialRuSwUpgrade}' == 'none'  delete  update

    coam.Perform Parameter Recommissioning  dist_name=${MNL_dn}  parameter=sequentialRuSwUpgrade  operation=${operation}
    ...  value=${sequentialRuSwUpgrade}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    ${sequentialRuSwUpgrade_value}=  Get sequentialRuSwUpgrade parameter value  ${alias}
    Run Keyword If  '${sequentialRuSwUpgrade_value}' == '${sequentialRuSwUpgrade}'
    ...  Log  Parameter sequentialRuSwUpgrade set on BTS ${alias}: ${sequentialRuSwUpgrade_value}, successfully commissioned!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter sequentialRuSwUpgrade not properly set on BTS ${alias}! (expected/found value:
    ...  ${sequentialRuSwUpgrade}/${sequentialRuSwUpgrade_value})  console=True
    ...  AND  Fail  Parameter sequentialRuSwUpgrade not properly set on BTS ${alias}!

Get ruPhaseSwActivationResetPolicy parameter value
    [Documentation]
    ...  Get BTS ruPhaseSwActivationResetPolicy parameter value: Simultaneous, Sequential, User configuration, Together per HW type,
    ...  Together per band or none
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | ruPhaseSwActivationResetPolicy | Simultaneous, Sequential, User configuration, Together per HW type, Together per band or none |
    ...
    [Arguments]  ${alias}

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${MNL_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/MNL-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${MNL_dn}=  Get From List  ${MNL_dn_list}  0
    ${ruPhaseSwActivationResetPolicy_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${MNL_dn}
    ...  p_name=ruPhaseSwActivationResetPolicy
    ${ruPhaseSwActivationResetPolicy_count}=  Get Length  ${ruPhaseSwActivationResetPolicy_info_dict}
    ${ruPhaseSwActivationResetPolicy}=  Run Keyword If  ${ruPhaseSwActivationResetPolicy_count} > 0
    ...  Get From Dictionary  ${ruPhaseSwActivationResetPolicy_info_dict}  ruPhaseSwActivationResetPolicy
    ...  ELSE
    ...  Set Variable  none

    [Return]  ${ruPhaseSwActivationResetPolicy}

Set ruPhaseSwActivationResetPolicy parameter value
    [Documentation]
    ...  Set BTS ruPhaseSwActivationResetPolicy parameter value: Simultaneous, Sequential, User configuration, Together per HW type,
    ...  Together per band or none
    ...
    ...  *INPUT*
    ...  | Parameter                      | Man. | Description                                                                          |
    ...  | alias                          | Yes  | admin instance alias                                                                 |
    ...  | ruPhaseSwActivationResetPolicy | Yes  | parameter value: Simultaneous, Sequential, User configuration, Together per HW type,
    ...                                            Together per band or none                                                            |
    ...
    [Arguments]  ${ruPhaseSwActivationResetPolicy}  ${alias}

    ${ruPhaseSwActivationResetPolicy_value}=  Get ruPhaseSwActivationResetPolicy parameter value  ${alias}
    Run Keyword If  '${ruPhaseSwActivationResetPolicy_value}' == '${ruPhaseSwActivationResetPolicy}'  Run Keywords
    ...  Log  Parameter ruPhaseSwActivationResetPolicy: ${ruPhaseSwActivationResetPolicy_value} already set on BTS ${alias}, commissioning not needed!
    ...  console=True
    ...  AND  Return From Keyword

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${MNL_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/MNL-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${MNL_dn}=  Get From List  ${MNL_dn_list}  0
    ${operation}=  Set Variable If  '${ruPhaseSwActivationResetPolicy}' == 'none'  delete  update

    coam.Perform Parameter Recommissioning  dist_name=${MNL_dn}  parameter=ruPhaseSwActivationResetPolicy  operation=${operation}
    ...  value=${ruPhaseSwActivationResetPolicy}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    ${ruPhaseSwActivationResetPolicy_value}=  Get ruPhaseSwActivationResetPolicy parameter value  ${alias}
    Run Keyword If  '${ruPhaseSwActivationResetPolicy_value}' == '${ruPhaseSwActivationResetPolicy}'
    ...  Log  Parameter ruPhaseSwActivationResetPolicy set on BTS ${alias}: ${ruPhaseSwActivationResetPolicy_value}, successfully commissioned!
    ...  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter ruPhaseSwActivationResetPolicy not properly set on BTS ${alias}! (expected/found value:
    ...  ${ruPhaseSwActivationResetPolicy}/${ruPhaseSwActivationResetPolicy_value})  console=True
    ...  AND  Fail  Parameter ruPhaseSwActivationResetPolicy not properly set on BTS ${alias}!

Get disableSWUpdate parameter value
    [Documentation]
    ...  Get RMOD disableSWUpdate parameter value: true, false or none
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description             |
    ...  | RMOD_id   | Yes  | RMOD id runtime view    |
    ...  | alias     | Yes  | alias of admin instance |
    ...
    ...  *RETURN VALUE*
    ...  | Parameter       | Description                                |
    ...  | disableSWUpdate | disableSWUpdate value: true, false or none |
    ...
    [Arguments]  ${RMOD_id}  ${alias}

    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${disableSWUpdate_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${RMOD_dn}  p_name=disableSWUpdate
    ${disableSWUpdate_count}=  Get Length  ${disableSWUpdate_info_dict}
    ${disableSWUpdate}=  Run Keyword If  ${disableSWUpdate_count} > 0
    ...  Get From Dictionary  ${disableSWUpdate_info_dict}  disableSWUpdate
    ...  ELSE
    ...  Set Variable  none

    [Return]  ${disableSWUpdate}

Set disableSWUpdate parameter value
    [Documentation]
    ...  Set RMOD disableSWUpdate parameter value: true, false or none
      ...
    ...  | Parameter       | Man. | Description                          |
    ...  | RMOD_id         | Yes  | RMOD id runtime view                 |
    ...  | disableSWUpdate | Yes  | parameter value: true, false or none |
    ...  | alias           | Yes  | alias of admin instance              |
    ...
    [Arguments]  ${RMOD_id}  ${disableSWUpdate}  ${alias}

    ${disableSWUpdate_value}=  Get disableSWUpdate parameter value  ${RMOD_id}  ${alias}
    Run Keyword If  '${disableSWUpdate_value}' == '${disableSWUpdate}'  Run Keywords
    ...  Log  Parameter disableSWUpdate: ${disableSWUpdate_value} already set on BTS ${alias} RMOD id ${RMOD_id}, commissioning not needed!
    ...  console=True
    ...  AND  Return From Keyword

    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${operation}=  Set Variable If  '${disableSWUpdate}' == 'none'  delete  update

    coam.Perform Parameter Recommissioning  dist_name=${RMOD_dn}  parameter=disableSWUpdate  operation=${operation}  value=${disableSWUpdate}
    ...  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    ${disableSWUpdate_value}=  Get disableSWUpdate parameter value  ${RMOD_id}  ${alias}
    Run Keyword If  '${disableSWUpdate_value}' == '${disableSWUpdate}'
    ...  Log  Parameter disableSWUpdate set on BTS ${alias} RMOD id ${RMOD_id}: ${disableSWUpdate_value}, successfully commissioned!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter disableSWUpdate not properly set on BTS ${alias} RMOD id ${RMOD_id}! (expected/found value:
    ...  ${disableSWUpdate}/${disableSWUpdate_value})  console=True
    ...  AND  Fail  Parameter disableSWUpdate not properly set on BTS ${alias} RMOD id ${RMOD_id}!

Get upgradePhase parameter value
    [Documentation]
    ...  Get RMOD upgradePhase parameter value: RU, DU, No upgrade or none
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | RMOD_id   | Yes  | RMOD id runtime view |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | upgradePhase | RU, DU, No upgrade or none |
    ...
    [Arguments]  ${RMOD_id}  ${alias}

    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${upgradePhase_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${RMOD_dn}  p_name=upgradePhase
    ${upgradePhase_count}=  Get Length  ${upgradePhase_info_dict}
    ${upgradePhase}=  Run Keyword If  ${upgradePhase_count} > 0
    ...  Get From Dictionary  ${upgradePhase_info_dict}  upgradePhase
    ...  ELSE
    ...  Set Variable  none

    [Return]  ${upgradePhase}

Set upgradePhase parameter value
    [Documentation]
    ...  Set RMOD upgradePhase parameter value: RU, DU, No upgrade or none
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                 |
    ...  | RMOD_id           | Yes  | RMOD id runtime view                        |
    ...  | upgradePhase      | Yes  | parameter value: RU, DU, No upgrade or none |
    ...  | alias             | Yes  | admin instance alias                        |
    ...
    [Arguments]  ${RMOD_id}  ${upgradePhase}  ${alias}

    ${upgradePhase_value}=  Get upgradePhase parameter value  ${RMOD_id}  ${alias}
    Run Keyword If  '${upgradePhase_value}' == '${upgradePhase}'  Run Keywords
    ...  Log  Parameter upgradePhase: ${upgradePhase_value} already set on BTS ${alias} RMOD id ${RMOD_id}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${operation}=  Set Variable If  '${upgradePhase}' == 'none'  delete  update

    coam.Perform Parameter Recommissioning  dist_name=${RMOD_dn}  parameter=upgradePhase  operation=${operation}  value=${upgradePhase}
    ...  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    ${upgradePhase_value}=  Get upgradePhase parameter value  ${RMOD_id}  ${alias}
    Run Keyword If  '${upgradePhase_value}' == '${upgradePhase}'
    ...  Log  Parameter upgradePhase set on BTS ${alias} RMOD id ${RMOD_id}: ${upgradePhase_value}, successfully commissioned!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter upgradePhase not properly set on BTS ${alias} RMOD id ${RMOD_id}! (expected/found value:
    ...  ${upgradePhase}/${upgradePhase_value})  console=True
    ...  AND  Fail  Parameter upgradePhase not properly set on BTS ${alias} RMOD id ${RMOD_id}!

Get ruPhaseResetOrder parameter value
    [Documentation]
    ...  Get RMOD ruPhaseResetOrder parameter value: integer in range 1-216 or none
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | RMOD_id   | Yes  | RMOD id runtime view |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | ruPhaseResetOrder | integer in range 1-216 or none |
    ...
    [Arguments]  ${RMOD_id}  ${alias}

    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${ruPhaseResetOrder_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${RMOD_dn}
    ...  p_name=ruPhaseResetOrder
    ${ruPhaseResetOrder_count}=  Get Length  ${ruPhaseResetOrder_info_dict}
    ${ruPhaseResetOrder}=  Run Keyword If  ${ruPhaseResetOrder_count} > 0
    ...  Get From Dictionary  ${ruPhaseResetOrder_info_dict}  ruPhaseResetOrder
    ...  ELSE
    ...  Set Variable  none

    [Return]  ${ruPhaseResetOrder}

Set ruPhaseResetOrder parameter value
    [Documentation]
    ...  Set RMOD ruPhaseResetOrder parameter value: integer in range 1-216 or none
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                     |                                     |
    ...  | RMOD_id           | Yes  | RMOD id runtime view                            |
    ...  | ruPhaseResetOrder | Yes  | parameter value: integer in range 1-216 or none |
    ...  | alias             | Yes  | admin instance alias                            |
    ...
    [Arguments]  ${RMOD_id}  ${ruPhaseResetOrder}  ${alias}

    ${ruPhaseResetOrder_value}=  Get ruPhaseResetOrder parameter value  ${RMOD_id}  ${alias}
    Run Keyword If  '${ruPhaseResetOrder_value}' == '${ruPhaseResetOrder}'  Run Keywords
    ...  Log  Parameter ruPhaseResetOrder: ${ruPhaseResetOrder_value} already set on BTS ${alias} RMOD id ${RMOD_id}, commissioning not needed!
    ...  console=True
    ...  AND  Return From Keyword

    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${operation}=  Set Variable If  '${ruPhaseResetOrder}' == 'none'  delete  update

    coam.Perform Parameter Recommissioning  dist_name=${RMOD_dn}  parameter=ruPhaseResetOrder  operation=${operation}  value=${ruPhaseResetOrder}
    ...  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    ${ruPhaseResetOrder_value}=  Get ruPhaseResetOrder parameter value  ${RMOD_id}  ${alias}
    Run Keyword If  '${ruPhaseResetOrder_value}' == '${ruPhaseResetOrder}'
    ...  Log  Parameter ruPhaseResetOrder set on BTS ${alias} RMOD id ${RMOD_id}: ${ruPhaseResetOrder_value}, successfully commissioned!
    ...  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter ruPhaseResetOrder not properly set on BTS ${alias} RMOD id ${RMOD_id}! (expected/found value:
    ...  ${ruPhaseResetOrder}/${ruPhaseResetOrder_value})  console=True
    ...  AND  Fail  Parameter ruPhaseResetOrder not properly set on BTS ${alias} RMOD id ${RMOD_id}!

Get configured FHGW RMOD sn list from init file
    [Documentation]
    ...  Get configured FHGW id list from init file.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter         | Description                                        |
    ...  | FHGW_RMOD_sn_list | Configured RMOD sn list to FHGW id in init.py file |
    ...
    [Arguments]  ${FHGW_id}

    ${FHGW_id}=  Set Variable  ${FHGW_id}
    ${FHGW_RMOD_sn_list}=  Create List
    ${FHGW_RMOD_info}=  Get From Dictionary  ${INTERFACES['FHGW_${FHGW_id}']}  CONNECTIONS

    FOR  ${item}  IN  @{FHGW_RMOD_info}

        ${RMOD_sn}=  Fetch From Right  ${item}  RMOD_
        Append To List  ${FHGW_RMOD_sn_list}  ${RMOD_sn}

    END

    [Return]  ${FHGW_RMOD_sn_list}

Synchronize link break event to PM generation
    [Documentation]
    ...  KW used to Synchronize link break event moment to PM generation to avoid cases where event would be too close to new PM generation
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter           | Man | Description                                                          |
    ...  | alias               | Yes | admin instance alias                                                 |
    ...  | mt_param            | Yes | mt param name used to determine PM duration - e.g. mtSbtsSfpSmodLane |
    ...  | Link_break_duration | No  | duration of link break in milliseconds, default value: 0             |
    ...
    [Arguments]  ${alias}  ${mt_param}  ${Link_break_duration}=0

    ${epoch_time_now}=  GET event epoch time
    ${Link_break_duration_sec}=  Evaluate  ${Link_break_duration}/1000
    ${Link_break_duration_sec}=  Convert To Integer  ${Link_break_duration_sec}
    ${current_PM_sec_elapsed}=  Evaluate  ${epoch_time_now}%${${alias}_${mt_param}_seconds}
    ${current_PM_sec_left}=  Evaluate  ${${alias}_${mt_param}_seconds}-${current_PM_sec_elapsed}
    ${accepted_time_left}=  Evaluate  60+${Link_break_duration_sec}
    ${sleep_interval}=  Evaluate  30+${current_PM_sec_left}
    Run Keyword If  ${current_PM_sec_left}<${accepted_time_left}  Run Keywords
    ...  Log  Waiting ${sleep_interval} sec more to synchronize event with PM generation (${current_PM_sec_left} for PM complection + 30 sec of guard)
    ...  console=True
    ...  AND  Sleep  ${sleep_interval}s

Get BTS actForceUnitAutoReset parameter value
    [Documentation]
    ...  Get BTS actForceUnitAutoReset parameter value: false, true or none
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | actForceUnitAutoReset | false, true or none |
    ...
    [Arguments]  ${alias}

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${FMCADM_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FMCADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${FMCADM_dn}=  Get From List  ${FMCADM_dn_list}  0
    ${actForceUnitAutoReset_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${FMCADM_dn}
    ...  p_name=actForceUnitAutoReset
    ${actForceUnitAutoReset_count}=  Get Length  ${actForceUnitAutoReset_info_dict}
    ${actForceUnitAutoReset}=  Run Keyword If  ${actForceUnitAutoReset_count} > 0
    ...  Get From Dictionary  ${actForceUnitAutoReset_info_dict}  actForceUnitAutoReset
    ...  ELSE
    ...  Set Variable  none

    [Return]  ${actForceUnitAutoReset}

Set BTS actForceUnitAutoReset parameter value
    [Documentation]
    ...  Set BTS actForceUnitAutoReset parameter value: false, true or none
    ...
    ...  *INPUT*
    ...  | Parameter             | Man. | Description                          |
    ...  | actForceUnitAutoReset | Yes  | parameter value: false, true or none |
    ...  | alias                 | Yes  | admin instance alias                 |
    ...
    [Arguments]  ${actForceUnitAutoReset}  ${alias}

    ${actForceUnitAutoReset_value}=  Get BTS actForceUnitAutoReset parameter value  ${alias}
    Run Keyword If  '${actForceUnitAutoReset_value}' == '${actForceUnitAutoReset}'  Run Keywords
    ...  Log  Parameter actForceUnitAutoReset: ${actForceUnitAutoReset_value} already set on BTS ${alias}, commissioning not needed!
    ...  console=True
    ...  AND  Return From Keyword

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${FMCADM_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FMCADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${FMCADM_dn}=  Get From List  ${FMCADM_dn_list}  0
    ${operation}=  Set Variable If  '${actForceUnitAutoReset}' == 'none'  delete  update

    coam.Perform Parameter Recommissioning  dist_name=${FMCADM_dn}  parameter=actForceUnitAutoReset  operation=${operation}
    ...  value=${actForceUnitAutoReset}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    ${actForceUnitAutoReset_value}=  Get BTS actForceUnitAutoReset parameter value  ${alias}
    Run Keyword If  '${actForceUnitAutoReset_value}' == '${actForceUnitAutoReset}'
    ...  Log  Parameter actForceUnitAutoReset set on BTS ${alias}: ${actForceUnitAutoReset_value}, successfully commissioned!
    ...  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter actForceUnitAutoReset not properly set on BTS ${alias}! (expected/found value:
    ...  ${actForceUnitAutoReset}/${actForceUnitAutoReset_value})  console=True
    ...  AND  Fail  Parameter actForceUnitAutoReset not properly set on BTS ${alias}!

Get BTS maintenanceWindow list values
    [Documentation]
    ...  Get BTS maintenanceWindow list values. List items are daysOfWeek, gracefulCellShutdown, inUse, startTime and windowDuration
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | maintenanceWindow_list | Yes  | list items values |
    ...
    [Arguments]  ${alias}

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${FMCADM_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FMCADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${FMCADM_dn}=  Get From List  ${FMCADM_dn_list}  0
    ${EMPTY}  ${maintenanceWindow_info_dict}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${FMCADM_dn}
    ...  list_name=maintenanceWindow
    ${maintenanceWindow_count}=  Get Length  ${maintenanceWindow_info_dict}
    ${maintenanceWindow_list}=  Run Keyword If  ${maintenanceWindow_count} > 0
    ...  Get From Dictionary  ${maintenanceWindow_info_dict}  maintenanceWindow
    ...  ELSE
    ...  Create List

    [Return]  ${maintenanceWindow_list}

Set BTS maintenanceWindow list values
    [Documentation]
    ...  Set BTS maintenanceWindow list of dict items. Dict items are daysOfWeek, gracefulCellShutdown, inUse, startTime and windowDuration
    ...
    ...  *INPUT*
    ...  | Parameter            | Man. | Description               |
    ...  | daysOfWeek           | No   | daysOfWeek info           |
    ...  | gracefulCellShutdown | No   | gracefulCellShutdown info |
    ...  | inUse                | No   | inUse info                |
    ...  | startTime            | No   | startTime info            |
    ...  | windowDuration       | No   | windowDuration info       |
    ...  | alias                | No   | admin instance alias      |
    ...
    [Arguments]  ${daysOfWeek}=none  ${gracefulCellShutdown}=none  ${inUse}=none  ${startTime}=none  ${windowDuration}=none  ${alias}=default

    ${maintenanceWindow_dict}=  Create Dictionary
    Run Keyword If  '${daysOfWeek}' != 'none'
    ...  Set To Dictionary  ${maintenanceWindow_dict}  daysOfWeek=${daysOfWeek}
    Run Keyword If  '${gracefulCellShutdown}' != 'none'
    ...  Set To Dictionary  ${maintenanceWindow_dict}  gracefulCellShutdown=${gracefulCellShutdown}
    Run Keyword If  '${inUse}' != 'none'
    ...  Set To Dictionary  ${maintenanceWindow_dict}  inUse=${inUse}
    Run Keyword If  '${startTime}' != 'none'
    ...  Set To Dictionary  ${maintenanceWindow_dict}  startTime=${startTime}
    Run Keyword If  '${windowDuration}' != 'none'
    ...  Set To Dictionary  ${maintenanceWindow_dict}  windowDuration=${windowDuration}
    ${maintenanceWindow_dict_list}=  Create List  ${maintenanceWindow_dict}

    ${maintenanceWindow_list_values}=  Get BTS maintenanceWindow list values  ${alias}
    ${maintenanceWindow_list}=  Get Dictionary Values  ${maintenanceWindow_dict}  false

    ${maintenanceWindow_check}=  Check BTS maintenanceWindow info  ${maintenanceWindow_list}  ${maintenanceWindow_list_values}
    Run Keyword If  ${maintenanceWindow_check}  Run Keywords
    ...  Log  List maintenanceWindow: ${maintenanceWindow_list} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${FMCADM_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FMCADM-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${FMCADM_dn}=  Get From List  ${FMCADM_dn_list}  0
    ${maintenanceWindow_count}=  Get Length  ${maintenanceWindow_list}
    ${operation}=  Set Variable If  ${maintenanceWindow_count} == 0  delete  update

    coam.Perform Parameter Recommissioning  dist_name=${FMCADM_dn}  parameter=maintenanceWindow  operation=${operation}
    ...  value=${maintenanceWindow_dict_list}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    ${maintenanceWindow_list_values}=  Get BTS maintenanceWindow list values  ${alias}
    ${maintenanceWindow_check}=  Check BTS maintenanceWindow info  ${maintenanceWindow_list}  ${maintenanceWindow_list_values}
    Run Keyword If  ${maintenanceWindow_check}
    ...  Log  List maintenanceWindow set on BTS ${alias}: ${maintenanceWindow_list}, successfully commissioned!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  List maintenanceWindow not properly set on BTS ${alias}! (expected/found value:
    ...  ${maintenanceWindow_list}/${maintenanceWindow_list_values})  console=True
    ...  AND  Fail  List maintenanceWindow not properly set on BTS ${alias}!

Check BTS maintenanceWindow info
    [Arguments]  ${maintenanceWindow_update_values}  ${maintenanceWindow_values}

    ${maintenanceWindow_update_count}=  Get Length  ${maintenanceWindow_update_values}
    ${maintenanceWindow_count}=  Get Length  ${maintenanceWindow_values}
    Return From Keyword If  ${maintenanceWindow_update_count} == 0 and ${maintenanceWindow_count} == 0  ${TRUE}
    Return From Keyword If  ${maintenanceWindow_update_count} > 0 and ${maintenanceWindow_count} == 0  ${FALSE}
    Return From Keyword If  ${maintenanceWindow_update_count} == 0 and ${maintenanceWindow_count} > 0  ${FALSE}

	${maintenanceWindow_check}=  Set Variable  ${TRUE}

    ${list_check}=  Run Keyword And Return Status  List Should Contain Sub List  ${maintenanceWindow_values}  ${maintenanceWindow_update_values}
    ${maintenanceWindow_check}=  Set Variable If  ${list_check}  ${maintenanceWindow_check}  ${FALSE}

	[Return]  ${maintenanceWindow_check}

Get BTS maintenanceWindowResult info
    [Documentation]
    ...  Get BTS maintenanceWindowResult info.
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | maintenanceWindowResult | Yes  | list items values |
    ...
    [Arguments]  ${alias}

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects
    ${FMCADM_R_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FMCADM_R-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${FMCADM_R_dn}=  Get From List  ${FMCADM_R_dn_list}  0
    ${maintenanceWindowResult_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${FMCADM_R_dn}
    ...  p_name=maintenanceWindowResult
    ${maintenanceWindowResult_count}=  Get Length  ${maintenanceWindowResult_info_dict}
    ${maintenanceWindowResult}=  Run Keyword If  ${maintenanceWindowResult_count} > 0
    ...  Get From Dictionary  ${maintenanceWindowResult_info_dict}  maintenanceWindowResult
    ...  ELSE
    ...  Set Variable  none

    [Return]  ${maintenanceWindowResult}

Get BTS controller time
    [Arguments]  ${date_command}  ${alias}

    ${ip_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host}=  Set Variable If  '${alias}'=='Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    ${BTS_date}=  Execute Command on SM via SSH TAF  command=${date_command}  target_ip=${ip_address}  via_ip=${remote_host}  alias=${alias}_ssh
    ${BTS_date}=  Strip String  string=${BTS_date}  characters=\r\n

    [Return]  ${BTS_date}

Get actCli parameter value
    [Documentation]
    ...  Get actCli parameter value
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description          |
    ...  | alias     | Yes  | admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | actCli | parameter value: true or false |

    [Arguments]  ${alias}

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0

    ${actCli}=  Check Parameter value from SCF  item_dist_name=${BTS_SCF_dn}
    ...  parameter_to_check=actCli  scf_path=${scf_path}

    ${actCli}=  Convert to String  ${actCli}
    ${actCli}=  Convert To Lower Case  ${actCli}

    [Return]  ${actCli}

Set actCli parameter value
    [Documentation]
    ...  Set actCli parameter value
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description                    |
    ...  | alias     | Yes  | admin instance alias           |
    ...  | actCli    | Yes  | parameter value: true or false |

    [Arguments]  ${actCli_value}=${EMPTY}  ${alias}=default

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0

    ${actCli}=  Get actCli parameter value  ${alias}

    Run Keyword If  '${actCli}' == '${actCli_value}'
    ...  Log  Parameter actCli: ${actCli} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=actCli  operation=update
    ...  value=${actCli_value}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

Get BTS CB014646 feature parameters
    [Documentation]
    ...  Get BTS CB014646 feature parameters: actAutomaticSwitchover, automaticSwitchoverTimer, minCellAvailability, redundancyRole,
    ...  priorityNrCellsList, priorityLteCellsList
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description              |
    ...  | alias     | Yes  | BTS admin instance alias |
    ...
    ...  *RETURN VALUE*
    ...  | BTS_CB014646_feature_dict | BTS CB014646 feature dict containing structure: {'actAutomaticSwitchover': '<value>',
    ...                                'automaticSwitchoverTimer': '<value>', 'minCellAvailability': '<value>', 'redundancyRole': '<value>',
    ...                                'priorityNrCellsList': '<value>', 'priorityLteCellsList': '<value>'}
    ...
    [Arguments]  ${alias}

    ${Empty_list}=  Create List
    ${BTS_CB014646_feature_dict}=  Create Dictionary  actAutomaticSwitchover=none  automaticSwitchoverTimer=none  minCellAvailability=none
    ...  redundancyRole=none  priorityNrCellsList=${Empty_list}  priorityLteCellsList=${Empty_list}

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${REDUNDANCY_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/REDUNDANCY-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${REDUNDANCY_dn_count}=  Get Length  ${REDUNDANCY_dn_list}
    Return From Keyword If  ${REDUNDANCY_dn_count} == 0  ${BTS_CB014646_feature_dict}

    ${REDUNDANCY_dn}=  Get From List  ${REDUNDANCY_dn_list}  0

    ${actAutomaticSwitchover_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${REDUNDANCY_dn}
    ...  p_name=actAutomaticSwitchover
    ${actAutomaticSwitchover_count}=  Get Length  ${actAutomaticSwitchover_dict}
    ${actAutomaticSwitchover_info}=  Run Keyword If  ${actAutomaticSwitchover_count} > 0
    ...  Get From Dictionary  ${actAutomaticSwitchover_dict}  actAutomaticSwitchover
    ...  ELSE
    ...  Set Variable  none
    Set To Dictionary  ${BTS_CB014646_feature_dict}  actAutomaticSwitchover=${actAutomaticSwitchover_info}

    ${automaticSwitchoverTimer_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${REDUNDANCY_dn}
    ...  p_name=automaticSwitchoverTimer
    ${automaticSwitchoverTimer_count}=  Get Length  ${automaticSwitchoverTimer_dict}
    ${automaticSwitchoverTimer_info}=  Run Keyword If  ${automaticSwitchoverTimer_count} > 0
    ...  Get From Dictionary  ${automaticSwitchoverTimer_dict}  automaticSwitchoverTimer
    ...  ELSE
    ...  Set Variable  none
    Set To Dictionary  ${BTS_CB014646_feature_dict}  automaticSwitchoverTimer=${automaticSwitchoverTimer_info}

    ${minCellAvailability_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${REDUNDANCY_dn}
    ...  p_name=minCellAvailability
    ${minCellAvailability_count}=  Get Length  ${minCellAvailability_dict}
    ${minCellAvailability_info}=  Run Keyword If  ${minCellAvailability_count} > 0
    ...  Get From Dictionary  ${minCellAvailability_dict}  minCellAvailability
    ...  ELSE
    ...  Set Variable  none
    Set To Dictionary  ${BTS_CB014646_feature_dict}  minCellAvailability=${minCellAvailability_info}

    ${redundancyRole_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${REDUNDANCY_dn}
    ...  p_name=redundancyRole
    ${redundancyRole_count}=  Get Length  ${redundancyRole_dict}
    ${redundancyRole_info}=  Run Keyword If  ${redundancyRole_count} > 0
    ...  Get From Dictionary  ${redundancyRole_dict}  redundancyRole
    ...  ELSE
    ...  Set Variable  none
    Set To Dictionary  ${BTS_CB014646_feature_dict}  redundancyRole=${redundancyRole_info}

    ${EMPTY}  ${priorityNrCellsList_dict}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${REDUNDANCY_dn}
    ...  list_name=priorityNrCellsList
    ${priorityNrCellsList_count}=  Get Length  ${priorityNrCellsList_dict}
    ${priorityNrCellsList_list}=  Run Keyword If  ${priorityNrCellsList_count} > 0
    ...  Get From Dictionary  ${priorityNrCellsList_dict}  priorityNrCellsList
    ...  ELSE
    ...  Create List
    Set To Dictionary  ${BTS_CB014646_feature_dict}  priorityNrCellsList=${priorityNrCellsList_list}

    ${EMPTY}  ${priorityLteCellsList_dict}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${REDUNDANCY_dn}
    ...  list_name=priorityLteCellsList
    ${priorityLteCellsList_count}=  Get Length  ${priorityLteCellsList_dict}
    ${priorityLteCellsList_list}=  Run Keyword If  ${priorityLteCellsList_count} > 0
    ...  Get From Dictionary  ${priorityLteCellsList_dict}  priorityLteCellsList
    ...  ELSE
    ...  Create List
    Set To Dictionary  ${BTS_CB014646_feature_dict}  priorityLteCellsList=${priorityLteCellsList_list}

    [Return]  ${BTS_CB014646_feature_dict}

Set BTS CB014646 feature parameters
    [Documentation]
    ...  Set BTS CB014646 feature parameters: actAutomaticSwitchover, automaticSwitchoverTimer, minCellAvailability, redundancyRole
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                | Man. | Description                                                                           |
    ...  | CB014646_parameter_name  | Yes  | One of CB014646 feature parameters: actAutomaticSwitchover, automaticSwitchoverTimer,
    ...                                      minCellAvailability, redundancyRole                                                   |
    ...  | CB014646_parameter_value | Yes  | CB014646 feature parameter value                                                      |
    ...  | alias                    | Yes  | BTS admin instance alias                                                              |
	...
    [Arguments]  ${CB014646_parameter_name}  ${CB014646_parameter_value}  ${alias}

    ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
    ${BTS_parameter_value}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  ${CB014646_parameter_name}

    Run Keyword If  '${BTS_parameter_value}' == '${CB014646_parameter_value}'  Run Keywords
    ...  Log  Parameter ${CB014646_parameter_name}: ${CB014646_parameter_value} already set on BTS ${alias}, commissioning not needed!
    ...  console=True
    ...  AND  Return From Keyword

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${REDUNDANCY_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/REDUNDANCY-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${REDUNDANCY_dn_count}=  Get Length  ${REDUNDANCY_dn_list}
    Return From Keyword If  ${REDUNDANCY_dn_count} == 0

    ${REDUNDANCY_dn}=  Get From List  ${REDUNDANCY_dn_list}  0
    ${operation}=  Set Variable If  '${CB014646_parameter_value}' == 'none'  delete  update

    coam.Perform Parameter Recommissioning  dist_name=${REDUNDANCY_dn}  parameter=${CB014646_parameter_name}  operation=${operation}
    ...  value=${CB014646_parameter_value}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
    ${BTS_parameter_value}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  ${CB014646_parameter_name}
    Run Keyword If  '${BTS_parameter_value}' == '${CB014646_parameter_value}'
    ...  Log  Parameter ${CB014646_parameter_name} set on BTS ${alias}: ${CB014646_parameter_value}, successfully commissioned!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter ${CB014646_parameter_name} not properly set on BTS ${alias}! (expected/found value:
    ...  ${BTS_parameter_value}/${CB014646_parameter_value})  console=True
    ...  AND  Fail  Parameter ${CB014646_parameter_name} not properly set on BTS ${alias}!

Set BTS CB014646 feature parameters list
    [Documentation]
    ...  Set BTS CB014646 feature parameters list: priorityNrCellsList, priorityLteCellsList
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Description                                                                        |
    ...  | CB014646_list_name  | Yes  | One of CB014646 feature parameters list: priorityNrCellsList, priorityLteCellsList |
    ...  | CB014646_list_value | Yes  | CB014646 feature parameter list value                                              |
    ...  | alias               | Yes  | BTS admin instance alias                                                           |
    ...
    [Arguments]  ${CB014646_list_name}  ${CB014646_list_value}  ${alias}

    ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
    ${BTS_list_value}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  ${CB014646_list_name}

    ${list_check}=  Check BTS parameter list info  ${BTS_list_value}  ${CB014646_list_value}
    Run Keyword If  ${list_check}  Run Keywords
    ...  Log  List ${CB014646_list_name}: ${CB014646_list_value} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${REDUNDANCY_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/REDUNDANCY-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${REDUNDANCY_dn_count}=  Get Length  ${REDUNDANCY_dn_list}
    Return From Keyword If  ${REDUNDANCY_dn_count} == 0

    ${REDUNDANCY_dn}=  Get From List  ${REDUNDANCY_dn_list}  0
    ${CB014646_list_count}=  Get Length  ${CB014646_list_value}
    ${operation}=  Set Variable If  ${CB014646_list_count} == 0  delete  update

    coam.Perform Parameter Recommissioning  dist_name=${REDUNDANCY_dn}  parameter=${CB014646_list_name}  operation=${operation}
    ...  value=${CB014646_list_value}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    Sleep  3s

    ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
    ${BTS_list_value}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  ${CB014646_list_name}
    ${list_check}=  Check BTS parameter list info  ${BTS_list_value}  ${CB014646_list_value}
    Run Keyword If  ${list_check}
    ...  Log  List ${CB014646_list_name} set on BTS ${alias}: ${CB014646_list_value}, successfully commissioned!  console=True
    ...  ELSE  Run Keywords
    ...  Log  List ${CB014646_list_name} not properly set on BTS ${alias}! (expected/found value: ${BTS_list_value}/${CB014646_list_value})
    ...  console=True
    ...  AND  Fail  List ${CB014646_list_name} not properly set on BTS ${alias}!

Check BTS parameter list info
    [Arguments]  ${parameter_list_values}  ${parameter_list_update_values}

    ${parameter_list_update_count}=  Get Length  ${parameter_list_update_values}
    ${parameter_list_count}=  Get Length  ${parameter_list_values}
    Return From Keyword If  ${parameter_list_update_count} == 0 and ${parameter_list_count} == 0  ${TRUE}
    Return From Keyword If  ${parameter_list_update_count} > 0 and ${parameter_list_count} == 0  ${FALSE}
    Return From Keyword If  ${parameter_list_update_count} == 0 and ${parameter_list_count} > 0  ${FALSE}

    ${parameter_list_check}=  Set Variable  ${TRUE}

    ${list_check}=  Run Keyword And Return Status  List Should Contain Sub List  ${parameter_list_values}  ${parameter_list_update_values}
    ${parameter_list_check}=  Set Variable If  ${list_check}  ${parameter_list_check}  ${FALSE}

    [Return]  ${parameter_list_check}

Get CBRS NR cell info
    [Arguments]  ${alias}

    ${CBRS_NR_cell_id_list}=  Create List

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${NRBTS_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRBTS-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${NRBTS_dn_count}=  Get Length  ${NRBTS_dn_list}
    Return From Keyword If  ${NRBTS_dn_count} == 0  ${CBRS_NR_cell_id_list}

    ${NRBTS_dn}=  Get From List  ${NRBTS_dn_list}  0

    ${actNrCbrs_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${NRBTS_dn}  p_name=actNrCbrs
    ${actNrCbrs_count}=  Get Length  ${actNrCbrs_dict}
    ${actNrCbrs_info}=  Run Keyword If  ${actNrCbrs_count} > 0
    ...  Get From Dictionary  ${actNrCbrs_dict}  actNrCbrs
    ...  ELSE
    ...  Set Variable  NA
    Return From Keyword If  '${actNrCbrs_info}' != 'true'  ${CBRS_NR_cell_id_list}

    ${NRCELL_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRCELL-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${NRCELL_dn_count}=  Get Length  ${NRCELL_dn_list}
    Return From Keyword If  ${NRCELL_dn_count} == 0  ${CBRS_NR_cell_id_list}

    ${CELL_runtime_scf_dict}  ${CELL_scf_runtime_dict}=  Get BTS CELL runtime and scf info dict  ${alias}
    ${NR_CELL_scf_runtime_dict}=  Get From Dictionary  ${CELL_scf_runtime_dict}  nr

    FOR  ${NR_cell_dn}  IN  @{NRCELL_dn_list}

        ${freqBandIndicatorNR_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${NR_cell_dn}
        ...  p_name=freqBandIndicatorNR
        ${freqBandIndicatorNR_count}=  Get Length  ${freqBandIndicatorNR_dict}
        ${freqBandIndicatorNR_info}=  Run Keyword If  ${freqBandIndicatorNR_count} > 0
        ...  Get From Dictionary  ${freqBandIndicatorNR_dict}  freqBandIndicatorNR
        ...  ELSE
        ...  Set Variable  NA

        Continue For Loop If  '${freqBandIndicatorNR_info}' != '48'

        ${NR_cell_id}=  Get From Dictionary  ${NR_CELL_scf_runtime_dict}  ${NR_cell_dn}
        Append To List  ${CBRS_NR_cell_id_list}  ${NR_cell_id}

    END

    [Return]  ${CBRS_NR_cell_id_list}

Get CBRS LTE cell info
    [Arguments]  ${alias}

    ${CBRS_LTE_cell_id_list}=  Create List

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${LNBTS_TDD_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/LNBTS_TDD-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${LNBTS_TDD_dn_count}=  Get Length  ${LNBTS_TDD_dn_list}
    Return From Keyword If  ${LNBTS_TDD_dn_count} == 0  ${CBRS_LTE_cell_id_list}

    ${LNBTS_TDD_dn}=  Get From List  ${LNBTS_TDD_dn_list}  0

    ${actCbrs_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${LNBTS_TDD_dn}  p_name=actCbrs
    ${actCbrs_count}=  Get Length  ${actCbrs_dict}
    ${actCbrs_info}=  Run Keyword If  ${actCbrs_count} > 0
    ...  Get From Dictionary  ${actCbrs_dict}  actCbrs
    ...  ELSE
    ...  Set Variable  NA
    Return From Keyword If  '${actCbrs_info}' != 'true'  ${CBRS_LTE_cell_id_list}

    ${LNCEL_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/LNCEL-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${LNCEL_dn_count}=  Get Length  ${LNCEL_dn_list}
    Return From Keyword If  ${LNCEL_dn_count} == 0  ${CBRS_LTE_cell_id_list}

    ${CELL_runtime_scf_dict}  ${CELL_scf_runtime_dict}=  Get BTS CELL runtime and scf info dict  ${alias}
    ${LTE_CELL_scf_runtime_dict}=  Get From Dictionary  ${CELL_scf_runtime_dict}  lte

    ${BTS_info}=  Get Bts Info  connection=${alias}

    FOR  ${item}  IN  @{BTS_info['cells']['lte']}

        Continue For Loop If  '${item['bandNumber']}' != '48'

        ${LTE_cell_id}=  Get From Dictionary  ${LTE_CELL_scf_runtime_dict}  ${item['id']['configuration']}
        Append To List  ${CBRS_LTE_cell_id_list}  ${LTE_cell_id}

    END

    [Return]  ${CBRS_LTE_cell_id_list}

Get BTS redundancy role info
    ${BTS_alias_redundancyRole_dict}=  Create Dictionary
    ${BTS_redundancyRole_alias_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}

        ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  redundancyRole
        Set To Dictionary  ${BTS_alias_redundancyRole_dict}  ${alias}  ${BTS_redundancyRole}
        Set To Dictionary  ${BTS_redundancyRole_alias_dict}  ${BTS_redundancyRole}  ${alias}

    END

    [Return]  ${BTS_alias_redundancyRole_dict}  ${BTS_redundancyRole_alias_dict}

Get BTS CB013910 feature parameter
    [Documentation]
    ...  Get BTS CB013910 feature parameter: actFronthaulSshAccess
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                                                   |
    ...  | BTS_SCF_path_file | No   | BTS SCF path file. By default None: initial BTS SCF file get in common setup phase will be taken into account |
    ...  | alias             | No   | BTS connection instance alias                                                                                 |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description                                                                                 |
    ...  | BTS_CB013910_feature_dict | BTS CB013910 feature dict containing structure: {'actFronthaulSshAccess': '<value>',
    ...                                                                                 'dist_name': '<value>'}                    |

    [Arguments]  ${BTS_SCF_path_file}=None  ${alias}=None

    ${BTS_CB013910_feature_dict}=  Create Dictionary

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${BTS_SCF_FEATCADM_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_FEATCADM_dn}=  Get From List  ${BTS_SCF_FEATCADM_list}  0

    ${actFronthaulSshAccess_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_FEATCADM_dn}  p_name=actFronthaulSshAccess

    ${actFronthaulSshAccess_count}=  Get Length  ${actFronthaulSshAccess_info_dict}
    ${actFronthaulSshAccess_info}=  Run Keyword If   ${actFronthaulSshAccess_count} > 0
    ...  Get From Dictionary  ${actFronthaulSshAccess_info_dict}  actFronthaulSshAccess
    ...  ELSE
    ...  Set Variable  NA

    Set To Dictionary  ${BTS_CB013910_feature_dict}  actFronthaulSshAccess=${actFronthaulSshAccess_info}
    ...  dist_name=${BTS_SCF_FEATCADM_dn}

    [Return]  ${BTS_CB013910_feature_dict}

Get ledControl and ledControlState parameters value
    [Arguments]  ${RMOD_id}  ${alias}

    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${RMOD_dn_runtime}=  Get RMOD SCF runtime distinguished name  ${RMOD_id}  ${alias}

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects

    ${ledControl_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${scf_path}  dist_name=${RMOD_dn}
    ...  p_name=ledControl
    ${ledControlState_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${scf_path}  dist_name=${RMOD_dn_runtime}
    ...  p_name=ledControlState

    ${status}  ${ledControl}=  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${ledControl_info_dict}  ledControl
    ${ledControl_value}=  Set Variable If  '${status}' == 'PASS'  ${ledControl}  NA

    ${status}  ${ledControlState}=  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${ledControlState_info_dict}  ledControlState
    ${ledControlState_value}=  Set Variable If  '${status}' == 'PASS'  ${ledControlState}  NA

    [Return]  ${ledControl_value}  ${ledControlState_value}

Set classical BTS CB013910 feature parameter
    [Documentation]
    ...  Set classical BTS CB013910 feature parameter: actFronthaulSshAccess
    ...
    ...  *INPUT*
    ...  | Parameter                | Man. | Description                                                       |
    ...  | CB013910_parameter_name  | Yes  | BTS CB013910 feature parameter name                               |
    ...  | CB013910_parameter_value | Yes  | BTS CB013910 feature parameter value for requested parameter name |
    ...  | alias                    | No   | BTS instance alias, by default None                               |
    ...

    [Arguments]  ${CB013910_parameter_name}  ${CB013910_parameter_value}  ${CB013910_dist_name}  ${alias}=None

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_CB013910_feature_dict}=  Get BTS CB013910 feature parameter  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_CB013910_parameter_value}=  Get From Dictionary  ${BTS_CB013910_feature_dict}  ${CB013910_parameter_name}
    Run Keyword If  '${BTS_CB013910_parameter_value}' == '${CB013910_parameter_value}'  Run Keywords
    ...  Log  Parameter ${CB013910_parameter_name} already set on BTS ${alias}: ${BTS_CB013910_parameter_value}, commissioning not needed!
    ...  console=True
    ...  AND  Return From Keyword

    ${commissioning_operation}=  Set Variable If  '${BTS_CB013910_parameter_value}' == 'NA'  delete  update

    ${CB013910_distname_value}=  Get From Dictionary  ${BTS_CB013910_feature_dict}  ${CB013910_dist_name}
    coam.Perform Parameter Recommissioning  dist_name=${CB013910_distname_value}  parameter=${CB013910_parameter_name}
    ...  operation=${commissioning_operation}  value=${CB013910_parameter_value}  skip_parameter_relation_errors=True
    ...  should_activate=True  alias=${alias}

    Sleep  5s  Short sleep to allow parameter to be set properly

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_CB013910_feature_dict}=  Get BTS CB013910 feature parameter  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_CB013910_parameter_value}=  Get From Dictionary  ${BTS_CB013910_feature_dict}  ${CB013910_parameter_name}
    Run Keyword If  '${BTS_CB013910_parameter_value}' == '${CB013910_parameter_value}'
    ...  Log  Parameter ${CB013910_parameter_name} set on BTS ${alias}: ${BTS_CB013910_parameter_value}, successfully commissioning!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter ${CB013910_parameter_name} not properly set on BTS ${alias}! (expected/found value:
    ...  ${CB013910_parameter_value}/${BTS_CB013910_parameter_value})  console=True
    ...  AND  Fail  Parameter ${CB013910_parameter_name} not properly set on BTS ${alias}!
