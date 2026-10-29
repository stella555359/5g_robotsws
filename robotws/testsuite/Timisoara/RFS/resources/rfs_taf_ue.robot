*** Settings ***
Documentation    Keywords using taf.ue and aashell library
...              Resource used by RF Sharing Vrf tribe
...              Author: Gabriel Stanculescu
...              Contact: gabriel.stanculescu@nokia.com

Library    taf.ue
Library    OperatingSystem
Library    Collections
Library    python_resources/LK_manager.py  WITH NAME  LK_manager
Library    python_resources/syslog_throughput_analyzer.py  WITH NAME  syslog_thput
Library    taf.ccs.aashell   WITH NAME    aashell

*** Variables ***
${lk_path} =  /cygdrive/c/users/rfsharing/Desktop/QPM_LK1.5.1       #Path to LK

*** Keyword ***
Taf Ue License Keeper Setup
    [Arguments]  ${hostname_PC_UE}  ${username_PC_UE}  ${password_PC_UE}  ${lk_username}  ${lk_password}  ${lk_path}=None  ${ssh_key_file_path}=None
    ...  ${port}=22  ${timeout}=30
    LK_manager.prepare  hostname=${hostname_PC_UE}  ssh_username=${username_PC_UE}  ssh_password=${password_PC_UE}  lk_username=${lk_username}
    ...  lk_password=${lk_password}  lk_path=${lk_path}  ssh_key_file_path=${ssh_key_file_path}
    ...  port=${port}  timeout=${timeout}
    LK_manager.login

Taf Ue Get QXDM/QCAT 5G license
    [Arguments]  ${type_of_license}  ${timeout}=30  ${retry}=10
    Run Keyword If  '${type_of_license}'=='QCAT'
    ...  LK_manager.get_licence_qcat_5g  timeout=${timeout}  retry=${retry}
    ...  ELSE IF  '${type_of_license}'=='QXDM'
    ...  LK_manager.get_licence_qxdm_5g  timeout=${timeout}  retry=${retry}

Taf Ue Release QXDM/QCAT 5G license
    [Arguments]  ${type_of_license}  ${timeout}=30  ${retry}=10
    Run Keyword If  '${type_of_license}'=='QCAT'
    ...  LK_manager.release_licence_qcat_5g  timeout=${timeout}  retry=${retry}
    ...  ELSE IF  '${type_of_license}'=='QXDM'
    ...  LK_manager.release_licence_qxdm_5g  timeout=${timeout}  retry=${retry}

Taf Ue License Keeper Teardown
    [Arguments]  ${timeout}=60
    Log  License keeper Teardown  console=True
    LK_manager.logout  timeout=${timeout}
    LK_manager.disconnect
    stop_QualcommPackageManager_client  timeout=${timeout}

Taf Ue Require Single UE
    [Documentation]
    ...  KW used to reserve one single UE defined in config to be handled by taf.ue
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter      | Man. | Description                                                                        |
    ...  | ue_alias       | No   | taf.ue alias to be asigned to UE. If not given will be generated inside KW         |
    ...  | capabilities   | Yes  | Parameter used to identify UE from config                                          |
    ...  | timeout        | No   | timeout for the require UE operation                                               |
    ...
    ...  *RETURN VALUE*
    ...  | ue_alias |
    ...
    [Arguments]  ${ue_alias}=None  ${capabilities}=None  ${timeout}=300
    [Timeout]  ${timeout} sec
    ${ue_aliases_empty}=  Create List
    ${first_ue_required}=  Run Keyword And Return Status  Variable Should Not Exist  ${ue_aliases}
    Run Keyword If  ${first_ue_required}  Set Test Variable  ${ue_aliases}  ${ue_aliases_empty}
    Set Test Variable  ${ue_aliases}
    Run Keyword If  '${capabilities}' == 'None'  Fail  Argument capabilities is mandatory in order to identify UE from config!
    ${ue_alias}=  Set Variable If  '${ue_alias}' == 'None'  ${capabilities}_alias  ${ue_alias}
    Taf Ue Start Proxy Server Single Port  ${capabilities}
    ${ue_require_succesful}=  Run Keyword And Return Status  taf.ue.Require Ue  ue_alias=${ue_alias}  capabilities=${capabilities}
    Run Keyword If  not ${ue_require_succesful}  Fail  UE Require failed!
    Run Keyword And Ignore Error  Set Ue Info Test Variable  ${ue_alias}
    Append To List  ${ue_aliases}  ${ue_alias}
    [Return]  ${ue_alias}

Taf Ue Stop Using Single UE
    [Documentation]
    ...  KW used to release one single UE defined in config from being used by taf.ue
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter      | Man. | Description                                                                        |
    ...  | ue_alias       | Yes  | taf ue alias used to identify UE                                                   |
    ...  | timeout        | No   | timeout for the stop using UE operation                                            |
    ...
    ...  *RETURN VALUE*
    ...  | ue_alias |
    ...
    [Arguments]  ${ue_alias}=None  ${timeout}=60
    [Timeout]  ${timeout} sec
    taf.ue.Stop Using UE  ue_alias=${ue_alias}
    Remove Values From List  ${ue_aliases}  ${ue_alias}
    [Return]  ${ue_alias}

Taf Ue Stop Using All UEs
    [Documentation]
    ...  KW used to release all active UE aliases from being used by taf.ue
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter      | Man. | Description                                                                        |
    ...  | timeout        | No   | timeout for the stop using all UEs operation                                       |
    ...
    ...  *RETURN VALUE*
    ...  | None |
    ...
    [Arguments]  ${timeout}=60
    [Timeout]  ${timeout} sec
    ${active_ue_aliases}=  Run Keyword And Return Status  Should Not Be Empty  ${ue_aliases}
    Run Keyword If  not ${active_ue_aliases}  Run Keywords  Log  No active ue aliases to stop  console=True
    ...  AND  Return From Keyword
    FOR  ${ue_alias}  IN  @{ue_aliases}
        taf.ue.Stop Using UE  ue_alias=${ue_alias}
        Remove Values From List  ${ue_aliases}  ${ue_alias}
    END

Taf Ue Attach Single UE
    [Documentation]
    ...  KW used to attach one single UE on serving cell and, if needed, check if the cell on which attaches is the desired one or
    ...  among the desired ones
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter                  | Man. | Description                                                                           |
    ...  | ue_alias                   | Yes  | taf ue alias used to identify UE                                                      |
    ...  | expected_serving_cell_list | No   | list of cell IDs one which attach is considered valid. Can be one or None.            |
    ...                                        in case None, any cell ID will be accepted                                            |
    ...  | timeout                    | No   | timeout for the attach operation                                                      |
    ...  | call_type                  | No   | specify call type: data, voice. Default: None                                         |
    ...  | wcdma_cell_id              | NO   | Flag indicating if attach is performed on WCDMA cell ID. Possible values: True/False. |
    ...                                      | Default value: False                                                                  |
    ...
    ...  *RETURN VALUE*
    ...  | actual_ue_ip | actual_cell_id |
    ...
    [Arguments]  ${ue_alias}=None  ${expected_serving_cell_list}=None  ${timeout}=120  ${call_type}=None  ${wcdma_cell_id}=False
    taf.ue.Attach Ue  ue_alias=${ue_alias}  timeout=${timeout}
    ${actual_cell_id}=  taf.ue.Get Ue Info  ${ue_alias}  CELL_ID
    ${ue_cid} =  Evaluate  str(${actual_cell_id} & 0xFFFF)
    ${actual_cell_id}=  Set Variable If  '${wcdma_cell_id}'=='True'  ${ue_cid}  ${actual_cell_id}
    ${actual_ue_ip}=  Run Keyword If  '${call_type.lower()}'=='data'  taf.ue.Get UE Info  ${ue_alias}  IP
    Run Keyword If  '${call_type.lower()}'=='data'  Log  UE ${ue_alias} attached with IP: ${actual_ue_ip}  console=True
    Run Keyword If  ${expected_serving_cell_list}==None  Return From Keyword  ${actual_ue_ip}  ${actual_cell_id}
    ${status}=  Run Keyword And Return Status  List Should Contain Value  ${expected_serving_cell_list}  ${actual_cell_id}
    Run Keyword If  ${status}  Log  UE ${ue_alias} is attached on expected cell! Cell id: ${actual_cell_id}   console=True
    ...  ELSE  Fail
    ...  UE ${ue_alias} is not attached on an expected cell! Expected cell id(s): ${expected_serving_cell_list}/Actual cell id: ${actual_cell_id}/
    [Return]  ${actual_ue_ip}  ${actual_cell_id}

Taf Ue Detach Single UE
    [Documentation]
    ...  KW used to detach UE one single UE from serving cell
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter                  | Man. | Description                                                                |
    ...  | ue_alias                   | Yes  | taf ue alias used to identify UE                                           |
    ...  | timeout                    | No   | timeout for the detach operation                                           |
    ...
    ...  *RETURN VALUE*
    ...  | None |
    ...
    [Arguments]  ${ue_alias}=None  ${timeout}=60
    taf.ue.Detach Ue  ue_alias=${ue_alias}  timeout=${timeout}

Taf Ue Detach All Used UEs
    [Documentation]
    ...  KW used to detach all active UE aliases used by taf.ue
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter      | Man. | Description                                                                        |
    ...  | timeout        | No   | timeout for the detach operation                                                   |
    ...
    ...  *RETURN VALUE*
    ...  | None |
    ...
    [Arguments]  ${timeout}=60
    [Timeout]  ${timeout} sec
    ${active_ue_aliases}=  Run Keyword And Return Status  Should Not Be Empty  ${ue_aliases}
    Run Keyword If  not ${active_ue_aliases}  Run Keywords  Log  No active ue aliases to dettach  console=True
    ...  AND  Return From Keyword
    FOR  ${ue_alias}  IN  @{ue_aliases}
        taf.ue.Detach Ue  ue_alias=${ue_alias}  timeout=${timeout}
    END

Taf Ue Start Data Transfer Single UE
    [Documentation]
    ...  KW used to start data transfer thread for one single UE
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter                  | Man. | Description                                                                                   |
    ...  | ue_alias                   | Yes  | taf ue alias used to identify UE                                                              |
    ...  | dt_name                    | No   | taf ue alias to be asigned to data transfer thread. If not given will be generated inside KW  |
    ...  | call_duration              | Yes  | time duration for the data transfer to be performed in sedconds. Example: 100s                |
    ...  | call_direction             | Yes  | direction of data trafic to be performed. Possible values: dl, ul                             |
    ...  | throughput                 | Yes  | throughput value in bits/second. Example: 60 Mbits/sec                                        |
    ...  | protocol                   | Yes  | protocol used for data transfer. Examples: tcp, udp                                           |
    ...  | timeout                    | No   | timeout for the starting data transfer operation                                              |
    ...
    ...  *RETURN VALUE*
    ...  | dt_name |
    ...
    [Arguments]  ${ue_alias}=None  ${dt_name}=None  ${call_duration}=None  ${call_direction}=None  ${throughput}=None  ${protocol}=None
    ...  ${timeout}=60  ${packet_size}=1400
    [Timeout]  ${timeout} sec
    ${dt_name}=  Set Variable If  '${dt_name}' == 'None'  dt_${ue_alias}_${call_direction}_${protocol}  ${dt_name}
    taf.ue.Start Data Transfer  dt_name=${dt_name}  ue_alias=${ue_alias}  direction=${call_direction}  duration=${call_duration}
    ...  throughput=${throughput}  bearer_alias=UeAutomatic  protocol=${protocol}  packet_size=${packet_size}
    [Return]  ${dt_name}

Taf Ue Await Data Transfer Finish Single UE
    [Documentation]
    ...  KW used to wait for data transfer thread to finish for one single UE
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter                  | Man. | Description                                                                                   |
    ...  | dt_name                    | Yes  | taf ue alias used to identify data transfer thread                                            |
    ...  | timeout                    | No   | timeout for the await data transfer operation finish                                          |
    ...
    ...  *RETURN VALUE*
    ...  | None |
    ...
    [Arguments]  ${dt_name}=None  ${timeout}=900
    [Timeout]  ${timeout} sec
    taf.ue.Await Data Transfer Finish  dt_name=${dt_name}

Taf Ue Stop Data Transfer Single UE
    [Documentation]
    ...  KW used to stop data transfer thread used for one single UE
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter                  | Man. | Description                                                                                   |
    ...  | dt_name                    | Yes  | taf ue alias used to identify data transfer thread                                            |
    ...  | timeout                    | No   | timeout for the await transfer stop operation                                                 |
    ...
    ...  *RETURN VALUE*
    ...  | None |
    ...
    [Arguments]  ${dt_name}=None  ${timeout}=60
    [Timeout]  ${timeout} sec
    taf.ue.Stop Data Transfer  dt_name=${dt_name}

Taf Ue Verify Average Throughput Single UE
    [Documentation]
    ...  KW used to verify data transfer valuas after thread was finished
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter                  | Man. | Description                                                                                       |
    ...  | dt_name                    | Yes  | taf ue alias used to identify data transfer thread                                                |
    ...  | tput_min                   | Yes  | Min value for the throughput to be accepted in bits/second. Example:  60 Mbits/sec                |
    ...  | tput_max                   | Yes  | Max value for the throughput to be accepted in bits/second. Example:  10 Mbits/sec                |
    ...  | omit                       | No   | delay in seconds to start counting tput ex. ‘20’ - 1st 20 seconds of datatransfer will be omited; |
    ...  |                            |      | Default Value: 0
    ...
    ...  *RETURN VALUE*
    ...  | None |
    ...
    [Arguments]  ${dt_name}=None  ${tput_min}=None  ${tput_max}=None  ${omit}=0
    taf.ue.Verify Average Throughput  dt_name=${dt_name}  tput_min=${tput_min}  tput_max=${tput_max}  omit=${omit}

Taf Ue Start Voice Call Single UE
    [Documentation]
    ...  KW used to start taf ue voice call thread for one single UE
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter                  | Man. | Description                                                                                   |
    ...  | ue_alias                   | Yes  | taf ue alias used to identify UE                                                              |
    ...  | vc_name                    | No   | taf ue alias to be asigned to voice call thread. If not given will be generated inside KW     |
    ...  | call_duration              | Yes  | time duration for the voice call to be performed in seconds. Example: 100s                    |
    ...  | number_to_call             | Yes  | destination of voice call                                                                     |
    ...  | timeout                    | No   | timeout for the starting voice call operation                                                 |
    ...
    ...  *RETURN VALUE*
    ...  | vc_name |
    ...
    [Arguments]  ${ue_alias}=None  ${vc_name}=None  ${call_duration}=None  ${number_to_call}=None  ${timeout}=60
    [Timeout]  ${timeout} sec
    ${vc_name}=  Set Variable If  '${vc_name}' == 'None'  vc_${ue_alias}_${call_duration}s  ${vc_name}
    taf.ue.Start Voice Call  vc_alias=${vc_name}  ue_alias=${ue_alias}  to=${number_to_call}  duration=${call_duration}
    [Return]  ${vc_name}

Taf Ue Await Voice Call Finish Single UE
    [Documentation]
    ...  KW used to wait for voice call thread to finish for one single UE
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter                  | Man. | Description                                                                                   |
    ...  | vc_name                    | Yes  | taf ue alias used to identify voice call thread                                               |
    ...  | timeout                    | No   | timeout for the await voice call operation finish                                             |
    ...
    ...  *RETURN VALUE*
    ...  | None |
    ...
    [Arguments]  ${vc_name}=None  ${timeout}=900
    [Timeout]  ${timeout} sec
    taf.ue.Await Voice Call Finish  vc_alias=${vc_name}

Taf Ue Stop Voice Call Single UE
    [Documentation]
    ...  KW used to stop voice call thread used for one single UE
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter                  | Man. | Description                                                                                   |
    ...  | vc_name                    | Yes  | taf ue alias used to identify voice call thread                                               |
    ...  | timeout                    | No   | timeout for the voice call stop operation                                                     |
    ...
    ...  *RETURN VALUE*
    ...  | None |
    ...
    [Arguments]  ${vc_name}=None  ${timeout}=60
    [Timeout]  ${timeout} sec
    taf.ue.Stop Voice Call  vc_alias=${vc_name}

Taf Ue Perform Voice Call
    [Arguments]  ${ue_alias}  ${vc_alias}  ${call_timeout}  ${call_duration}  ${voice_args_dict}
    [Timeout]  ${call_timeout}
    ${number_to_call}=  get from dictionary  ${voice_args_dict}  NUMBER_TO_CALL
    ${rssi_measurement_period}=  get from dictionary  ${voice_args_dict}  RSSI_MEASUREMENT_PERIOD
    taf.ue.Start Voice Call  vc_alias=${vc_alias}  ue_alias=${ue_alias}  to=${number_to_call}  duration=${call_duration}s
    Sleep  10s
    taf.ue.Await Voice Call Finish  vc_alias=${vc_alias}
    taf.ue.Stop Voice Call  vc_alias=${vc_alias}
    ${surplus_time_int}=  Subtract time from time  ${call_duration}  ${rssi_measurement_period}  result_format=number
    Run Keyword If  '${techno}'=='GSM' and ${surplus_time_int}>=0
    ...  Taf Ue Check RSSI and raise warning
    ...  ELSE IF  '${techno}'=='GSM' and ${surplus_time_int}<0
    ...  Log  Call duration lower than minimum time needed for RSSI measurement ${rssi_measurement_period}  level=WARN
    Log  Voice call for UE ${ue_alias} lasting ${call_duration} seconds performed succesfully!  console=True

Taf Ue Perform Data Call
    [Arguments]  ${ue_alias}  ${dt_name}  ${call_timeout}  ${call_duration}  ${data_args_dict}  ${techno}=NR  ${packet_size}=1400
    [Timeout]  ${call_timeout}
    Set Test Variable  ${current_cell_bw_target_from_config}  False
    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG_exists}=  Run Keyword And Return Status  Variable Should Exist  ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}
    Run Keyword If  ${IMPORT_CELL_TARGET_BW_FROM_CONFIG_exists}
    ...  Run Keyword If  '${IMPORT_CELL_TARGET_BW_FROM_CONFIG}'=='True'
    ...  Set Test Variable  ${current_cell_bw_target_from_config}  True
    ${cell_id}=  taf.ue.Get Ue Info  ${ue_alias}  CELL_ID
    Run Keyword If  ${current_cell_bw_target_from_config}  Extract current cell target BW based on cell ID  ${cell_id}  ${techno}
    ${call_direction}=  Get From Dictionary  ${data_args_dict}  call_direction
    ${protocol}=  Get From Dictionary  ${data_args_dict}  PROTOCOL
    ${bw}=  Run Keyword If  ${current_cell_bw_target_from_config}
    ...  Set Variable  ${CELL_TARGET_BW_params["Target_Bandwidth"]}
    ...  ELSE  Get From Dictionary  ${data_args_dict}  BANDWIDTH
    ${downlink_MIN_TPUT}=  Run Keyword If  ${current_cell_bw_target_from_config}
    ...  Set Variable  ${CELL_TARGET_BW_params["DL_min"]}
    ...  ELSE  Set Variable  ${downlink_MIN_TPUT}
    ${downlink_MAX_TPUT}=  Run Keyword If  ${current_cell_bw_target_from_config}
    ...  Set Variable  ${CELL_TARGET_BW_params["DL_max"]}
    ...  ELSE  Set Variable  ${downlink_MAX_TPUT}
    ${uplink_MIN_TPUT}=  Run Keyword If  ${current_cell_bw_target_from_config}
    ...  Set Variable  ${CELL_TARGET_BW_params["UL_min"]}
    ...  ELSE  Set Variable  ${uplink_MIN_TPUT}
    ${uplink_MAX_TPUT}=  Run Keyword If  ${current_cell_bw_target_from_config}
    ...  Set Variable  ${CELL_TARGET_BW_params["UL_max"]}
    ...  ELSE  Set Variable  ${uplink_MAX_TPUT}
    ${dt_name_dl}=  Catenate  SEPARATOR=  ${ue_alias}  _downlink
    ${dt_name_ul}=  Catenate  SEPARATOR=  ${ue_alias}  _uplink
    ${dt_name}=  Catenate  SEPARATOR=  ${ue_alias}  _  ${call_direction}
    ${thput_direction}=  Set Variable If  '${call_direction}' == 'dl'  downlink  '${call_direction}' == 'ul'  uplink
    Log  Starting ${call_duration} of ${call_direction.upper()} ${protocol.upper()} data transfer on UE ${ue_alias}  console=True

    Run Keyword If  '${call_direction}' == 'ul_dl'  Run Keywords
    ...  taf.ue.Start Data Transfer  dt_name=${dt_name_dl}  ue_alias=${ue_alias}  direction=dl  duration=${call_duration}  throughput=${bw}
    ...  bearer_alias=UeAutomatic  protocol=${protocol}  packet_size=${packet_size}
    ...  AND  taf.ue.Start Data Transfer  dt_name=${dt_name_ul}  ue_alias=${ue_alias}  direction=ul  duration=${call_duration}  throughput=${bw}
    ...  bearer_alias=UeAutomatic  protocol=${protocol}  packet_size=${packet_size}
    ...  AND  taf.ue.Await Data Transfer Finish  dt_name=${dt_name_dl}
    ...  AND  taf.ue.Await Data Transfer Finish  dt_name=${dt_name_ul}
    ...  AND  Taf Ue Solution display expected throughput values  ${ue_alias}  ${dt_name_dl}  dl  ${protocol}  ${downlink_MIN_TPUT}
    ...  ${downlink_MAX_TPUT}
    ...  AND  taf.ue.Verify Average Throughput  dt_name=${dt_name_dl}  tput_min=${downlink_MIN_TPUT}  tput_max=${downlink_MAX_TPUT}
    ...  AND  Taf Ue Solution display actual throughput values  ${ue_alias}  ${dt_name_dl}  dl  ${protocol}
    ...  AND  Taf Ue Solution display expected throughput values  ${ue_alias}  ${dt_name_ul}  ul  ${protocol}  ${uplink_MIN_TPUT}
    ...  ${uplink_MAX_TPUT}
    ...  AND  taf.ue.Verify Average Throughput  dt_name=${dt_name_ul}  tput_min=${uplink_MIN_TPUT}  tput_max=${uplink_MAX_TPUT}
    ...  AND  Taf Ue Solution display actual throughput values  ${ue_alias}  ${dt_name_ul}  ul  ${protocol}
    ...  ELSE  Run Keywords
    ...  taf.ue.Start Data Transfer  dt_name=${dt_name}  ue_alias=${ue_alias}  direction=${call_direction}  duration=${call_duration}
    ...  throughput=${bw}  bearer_alias=UeAutomatic  protocol=${protocol}  packet_size=${packet_size}
    ...  AND  taf.ue.Await Data Transfer Finish  dt_name=${dt_name}
    ...  AND  Taf Ue Solution display expected throughput values  ${ue_alias}  ${dt_name}  ${call_direction}  ${protocol}
    ...  ${${thput_direction.lower()}_MIN_TPUT}  ${${thput_direction.lower()}_MAX_TPUT}
    ...  AND  taf.ue.Verify Average Throughput  dt_name=${dt_name}  tput_min=${${thput_direction}_MIN_TPUT}
    ...  tput_max=${${thput_direction}_MAX_TPUT}
    ...  AND  Taf Ue Solution display actual throughput values  ${ue_alias}  ${dt_name}  ${call_direction}  ${protocol}

    Run Keyword If  '${call_direction}' == 'ul_dl'  Run Keywords
    ...  taf.ue.Stop Data Transfer  dt_name=${dt_name_dl}
    ...  AND  taf.ue.Stop Data Transfer  dt_name=${dt_name_ul}
    ...  ELSE  taf.ue.Stop Data Transfer  dt_name=${dt_name}

    Log  Data Transfer and Verify Average Troughput finished succesfully!  console=True

Taf Ue Perform taf ue data call with one UE on cell list
    [Documentation]
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...  Kw for performing taf ue data call with one UE on cell list
    ...  *USAGE*
    ...  | Parameter              | Man.| Description                                                                                            |
    ...  | common_args_dict       | YES | Dictionary containing args for data and voice call:  TECHNO, USE_ATTENUATOR, cells_list,   ...         |
    ...  | ue_index               | YES | Useful to uniquely identify UE through UE alias                                                        |
    ...  | detach_ue              | NO  | Detach UE at the end of KW; Possible values: True/False. Default value: False                          |
    ...  | check_nr_attach        | NO  | 5G call specific flag. Possible values: None, ADB, QCAT. Default value: None                           |
    ...  | wcdma_cell_id          | NO  | Flag indicating if attach is performed on WCDMA cell ID. Values: True/False. Default value: False      |
    ...  | lk_username            | NO  | The Qualcomm account's username. Default value None                                                    |
    ...  | lk_password            | NO  | The Qualcomm account's password. Default value None                                                    |
    ...  | separated_4g_5g_on_mdm | NO  | Possible values: True or False; Indicates if 4G is spearated from 5G on modem (e.g. QCT8150)           |
    ...
    ...  *EXAMPLE*
    ...   Taf Ue Perform taf ue data call with one UE on cell list | common_args_dict | 1
    ...
    ...
    [Arguments]  ${common_args_dict}  ${ue_index}  ${detach_ue}=False  ${check_nr_attach}=None  ${wcdma_cell_id}=False
    ...  ${lk_username}=None  ${lk_password}=None  ${separated_4g_5g_on_mdm}=False

    FOR  ${key}  IN  @{common_args_dict.keys()}
        Set Test Variable  ${${key}}  ${common_args_dict["${key}"]}
    END

    ${ue_alias}=  Catenate  SEPARATOR=  UE_  ${ue_index}
    ${call_duration_int}=  Remove String  ${CALL_DURATION}  s
    ${call_timeout}=  Taf Ue Evaluate Call Timeout  call_duration=${call_duration_int}  call_type=${call_type}  call_direction=${call_direction}
    ${number_of_cells}=  Taf Ue Calculate number of cells  cells_list=${cells_list}
    ${nr_alias_exists}=  Run Keyword And Return Status  Variable should exist  ${common_args_dict["admin_alias"]}
    ${nr_alias}=  Set Variable If  ${nr_alias_exists}  ${common_args_dict["admin_alias"]}  None
    ${all_NR_PCIs}=  Create List  @{EMPTY}
    FOR  ${cell}  IN  @{cells_list}
        ${NRpci_lteCellId_exists}=  Run Keyword And Return Status  Variable should exist  ${NRpci_lteCellId}
        Exit For Loop If  not ${NRpci_lteCellId_exists}
        ${all_NR_PCIs}=  Combine Lists  ${all_NR_PCIs}  ${NRpci_lteCellId[${cell}]}
    END
    Taf Ue Require Single UE  ue_alias=${ue_alias}  capabilities=${capabilities}
    Sleep  10s
    ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${common_args_dict}  TECHNO_ANCHOR
    Run Keyword If  not ${status}   Set To Dictionary  ${common_args_dict}  TECHNO_ANCHOR=${common_args_dict["TECHNO"]}
    ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${common_args_dict}  anchor_alias
    Run Keyword If  not ${status}   Set To Dictionary  ${common_args_dict}  anchor_alias=${common_args_dict["alias"]}
    Run Keyword If  '${USE_ATTENUATOR}'=='YES'  Cut Cells Signal  tech=${common_args_dict["TECHNO_ANCHOR"]}
    FOR  ${current_cell_index}  IN RANGE  0  ${number_of_cells}
        Run Keyword If  '${USE_ATTENUATOR}'=='YES'   Run Keyword If  ${current_cell_index}>0
        ...  Set Cell Attenuation  ${cells_list[${current_cell_index} - 1]}  100  ${common_args_dict["TECHNO_ANCHOR"]}
        ...  ${common_args_dict["anchor_alias"]}
        Run Keyword If  '${USE_ATTENUATOR}'=='YES'
        ...  Set Cell Attenuation  ${cells_list[${current_cell_index}]}  0  ${common_args_dict["TECHNO_ANCHOR"]}  ${common_args_dict["anchor_alias"]}
        ${cell_check}=  Set Variable If  '${USE_ATTENUATOR}'=='YES'  ${cells_list[${current_cell_index}:${current_cell_index}+1]}  ${cells_list}
        ${admin_sector_checks}=  Set Variable If  '${nr_alias}'!='None'  ${common_args_dict["anchor_alias"]}  ${common_args_dict["alias"]}
        ${techno}=  Set Variable If
        ...  'nr' in '${TECHNO.lower()}'  NR
        ...  'lte' in '${TECHNO.lower()}'  LTE
        ...  'wcdma' in '${TECHNO.lower()}'  WCDMA
        ...  'gsm' in '${TECHNO.lower()}'  GSM
        ${same_sector_cells_dict}=  Run Keyword If  '${USE_ATTENUATOR}'=='YES' and ('nr' in '${TECHNO.lower()}' or 'lte' in '${TECHNO.lower()}')
        ...  Get all sector cells  ${cells_list[${current_cell_index}]}  ${techno}  ${admin_sector_checks}
        ...  ELSE  Set Variable  None
        Set Test Variable  ${same_sector_cells_dict}
        Run Keyword If  '${USE_ATTENUATOR}'=='YES' and ('nr' in '${TECHNO.lower()}' or 'lte' in '${TECHNO.lower()}')  Run Keywords
        ...  Log  As TECHNO is identified=${TECHNO}, will proceed to barring all other cells from the same sector  console=True
        ...  AND  Set cellBarred on sector cells  ${same_sector_cells_dict}  barred
        ${mbn_profile}=  Get Variable Value  ${mbn_profile}  None
        ${mbn_profile_used}=  Set Variable if  '${mbn_profile}' == 'None'  False  True
        ${ue_info}=  Taf UE Get UE info based on capabilities  ${capabilities}  ${mbn_profile_used}
        Taf Ue Assure mbn profile presence if AT commands UE
        ...  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}  ${mbn_profile}
        Run Keyword If  '${check_nr_attach}' == 'QCAT'  Run Keywords
        ...  Taf Ue License Keeper Setup  hostname_PC_UE=${ue_info[2]}  username_PC_UE=${ue_info[3]}  password_PC_UE=${ue_info[4]}
        ...  lk_username=${lk_username}  lk_password=${lk_password}  lk_path=${lk_path}
        ...  timeout=30
        ...  AND  Taf Ue Get QXDM/QCAT 5G license  QCAT
        ...  AND  Log  Qualcomm license was acquired!  console=True
        ${status1}=  Run Keyword And Return Status  Taf Ue Perform attach and check cell  ue_alias=${ue_alias}  cell_check=${cell_check}
        ...  ue_info=${ue_info}
        ...  check_nr_attach=${check_nr_attach}  wcdma_cell_id=${wcdma_cell_id}  separated_4g_5g_on_mdm=${separated_4g_5g_on_mdm}
        ...  expected_nr_pci_list=${all_NR_PCIs}  alias_nr=${nr_alias}
        Run Keyword If  '${status1}' == 'False' and '${check_nr_attach}' != 'QCAT'  Run Keywords
        ...  Log  First attempt was not successful so the UE will be reseted!  console=True
        ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${ue_alias}  ue_class=${ue_info[0]}
        ...  AND  Sleep  60s
        ...  AND  Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}
        ...  ${mbn_profile}
        ...  AND  Taf Ue Perform attach and check cell  ue_alias=${ue_alias}  cell_check=${cell_check}  ue_info=${ue_info}
        ...  check_nr_attach=${check_nr_attach}  wcdma_cell_id=${wcdma_cell_id}  separated_4g_5g_on_mdm=${separated_4g_5g_on_mdm}
        ...  expected_nr_pci_list=${all_NR_PCIs}  alias_nr=${nr_alias}
        ...  ELSE IF  '${status1}' == 'False' and '${check_nr_attach}' == 'QCAT'  Run Keywords
        ...  Log  First attempt was not successful so the UE will be reseted!  console=True
        ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${ue_alias}  ue_class=${ue_info[0]}
        ...  AND  Sleep  60s
        ...  AND  taf.ue.Detach Ue  ue_alias=${ue_alias}  timeout=300
        ...  AND  Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}
        ...  ${mbn_profile}
        ...  AND  Taf Ue Perform attach and check cell  ue_alias=${ue_alias}  cell_check=${cell_check}  ue_info=${ue_info}  second_run=True
        ...  check_nr_attach=${check_nr_attach}  wcdma_cell_id=${wcdma_cell_id}   separated_4g_5g_on_mdm=${separated_4g_5g_on_mdm}
        ...  expected_nr_pci_list=${all_NR_PCIs}  alias_nr=${nr_alias}
        Set Test Variable  ${current_ue_alias}  ${ue_alias}
        ${packet_size}=  Set Variable If  ('gsm' in '${TECHNO.lower()}' or 'wcdma' in '${TECHNO.lower()}')  1200  1400
        Run Keyword If  '${attach_only}'=='True'  Log  Data transfer part will be skipped due to attach_only flag set to True!  console=True
        ...  ELSE  Run Keywords
        ...  Log  Launching Data Call on UE ${ue_alias}  console=True
        ...  AND  Taf Ue Perform Data Call  ue_alias=${ue_alias}  dt_name=${ue_alias}_Throughput  call_timeout=${call_timeout}
        ...  call_duration=${CALL_DURATION}  data_args_dict=${common_args_dict}  techno=${techno}  packet_size=${packet_size}
        Run Keyword If  '${detach_ue}' == 'True'  Run Keywords
        ...  Log  Performing UE detach  console=True
        ...  AND  taf.ue.Detach Ue  ue_alias=${ue_alias}  timeout=300
        Exit For Loop If  '${USE_ATTENUATOR}'=='NO'
        Run Keyword If  (${current_cell_index} < ${number_of_cells-1}) and ('nr' in '${TECHNO.lower()}' or 'lte' in '${TECHNO.lower()}')
        ...  Run Keywords
        ...  Log  As TECHNO is identified ${TECHNO}, will proceed to unbarring all other cells on the sector  console=True
        ...  AND  Set cellBarred on sector cells  ${same_sector_cells_dict}  notBarred
    END
    [Teardown]  Run Keyword If  '${USE_ATTENUATOR}'=='YES' and ('nr' in '${TECHNO.lower()}' or 'lte' in '${TECHNO.lower()}')  Run Keywords
    ...  Log  As TECHNO is identified ${TECHNO}, will proceed to unbarring all other cells on the sector  console=True
    ...  AND  Set cellBarred on sector cells  ${same_sector_cells_dict}  notBarred

Taf Ue Perform taf ue data call with one UE on NR cell list
    [Documentation]
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...  Kw for performing taf ue data call with one UE on NR cell list
    ...  *USAGE*
    ...  | Parameter              | Man.| Description                                                                                            |
    ...  | common_args_dict       | YES | Dictionary containing args for data and voice call:  TECHNO, USE_ATTENUATOR, cells_list,   ...         |
    ...  | ue_index               | YES | Useful to uniquely identify UE through UE alias                                                        |
    ...  | detach_ue              | NO  | Detach UE at the end of KW; Possible values: True/False. Default value: False                          |
    ...  | check_nr_attach        | NO  | 5G call specific flag. Possible values: ADB, QCAT, AT, aashell. Default value: None                    |
    ...  | lk_username            | NO  | The Qualcomm account's username. Default value None                                                    |
    ...  | lk_password            | NO  | The Qualcomm account's password. Default value None                                                    |
    ...  | separated_4g_5g_on_mdm | NO  | Possible values: True or False; Indicates if 4G is spearated from 5G on modem (e.g. QCT8150)           |
    ...
    ...  *EXAMPLE*
    ...   Taf Ue Perform taf ue data call with one UE on NR cell list | common_args_dict | 1
    ...
    ...
    [Arguments]  ${common_args_dict}  ${ue_index}  ${detach_ue}=False  ${check_nr_attach}=None
    ...  ${lk_username}=None  ${lk_password}=None  ${separated_4g_5g_on_mdm}=False

    FOR  ${key}  IN  @{common_args_dict.keys()}
        Set Test Variable  ${${key}}  ${common_args_dict["${key}"]}
    END

    ${ue_alias}=  Catenate  SEPARATOR=  UE_  ${ue_index}
    ${call_duration_int}=  Remove String  ${CALL_DURATION}  s
    ${call_timeout}=  Taf Ue Evaluate Call Timeout  call_duration=${call_duration_int}  call_type=${call_type}  call_direction=${call_direction}
    ${cells_list}=  Set Variable  ${common_args_dict["nr_cells_list"]}
    ${number_of_cells}=  Taf Ue Calculate number of cells  cells_list=${cells_list}
    Taf Ue Require Single UE  ue_alias=${ue_alias}  capabilities=${capabilities}
    Sleep  10s
    Run Keyword If  '${USE_ATTENUATOR}'=='YES'
    ...  Wait Until Keyword Succeeds  10 min  10 sec    Cut Cells Signal  tech=${common_args_dict["TECHNO"]}
    FOR  ${current_cell_index}  IN RANGE  0  ${number_of_cells}
        Run Keyword If  '${USE_ATTENUATOR}'=='YES'  Run Keywords
        ${nr_cell_id}=  Taf Ue Get NR cell ID based on PCI  ${cells_list[${current_cell_index}]}
        ${nr_cell_id_str}=  Convert to String  ${nr_cell_id}
        ${nr_cell_id_previous}=  Run Keyword If  ${current_cell_index}>0  Taf Ue Get NR cell ID based on PCI  ${cells_list[${current_cell_index} - 1]}
        ${nr_cell_id_previous_str}=  Run Keyword If  ${current_cell_index}>0  Convert to String  ${nr_cell_id_previous}
        Run Keyword If  ${current_cell_index}>0  Wait Until Keyword Succeeds  10 min  10 sec  Set Cell Attenuation
        ...  ${nr_cell_id_previous_str}  100%  ${common_args_dict["TECHNO"]}  ${common_args_dict["admin_alias"]}
        Wait Until Keyword Succeeds  10 min  10 sec  Set Cell Attenuation
        ...  ${nr_cell_id_str}  0  ${common_args_dict["TECHNO"]}  ${common_args_dict["admin_alias"]}
        ${cell_check}=  Set Variable If  '${USE_ATTENUATOR}'=='YES'  ${cells_list[${current_cell_index}:${current_cell_index}+1]}  ${cells_list}
        ${mbn_profile}=  Get Variable Value  ${mbn_profile}  None
        ${mbn_profile_used}=  Set Variable if  '${mbn_profile}' == 'None'  False  True
        ${lte_cell_keys}=  Get Dictionary Keys  ${NRpci_lteCellId}
        ${current_anchor_cell}=  Taf Ue Get current anchor cell  ${lte_cell_keys}  ${cells_list}  ${current_cell_index}
        ${current_anchor_cell_str}=  Convert To String  ${current_anchor_cell}
        ${current_nr_pci}=  Create List  ${cells_list[${current_cell_index}]}
        Log  Anchor cell for current NR cell ${nr_cell_id} is ${current_anchor_cell_str}  console=True
        Taf Ue Set target NR cell from defaultLnRelGnbCellId  ${current_anchor_cell_str}  ${nr_cell_id}  ${common_args_dict["anchor_alias"]}
        ${current_anchor_cell}=  Create List  ${current_anchor_cell_str}
        ${ue_info}=  Taf Ue Get UE info based on capabilities  ${capabilities}  ${mbn_profile_used}
        Taf Ue Assure mbn profile presence if AT commands UE
        ...  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}  ${mbn_profile}
        Run Keyword If  '${check_nr_attach}' == 'QCAT'  Run Keywords
        ...  Taf Ue License Keeper Setup  hostname_PC_UE=${ue_info[2]}  username_PC_UE=${ue_info[3]}  password_PC_UE=${ue_info[4]}
        ...  lk_username=${lk_username}  lk_password=${lk_password}  lk_path=${lk_path}
        ...  timeout=30
        ...  AND  Taf Ue Get QXDM/QCAT 5G license  QCAT
        ...  AND  Log  Qualcomm license was acquired!  console=True
        ${status1}=  Run Keyword And Return Status  Taf Ue Perform attach and check cell  ue_alias=${ue_alias}  cell_check=${current_anchor_cell}
        ...  ue_info=${ue_info}  check_nr_attach=${check_nr_attach}  wcdma_cell_id=False  separated_4g_5g_on_mdm=${separated_4g_5g_on_mdm}
        ...  expected_nr_pci_list=${current_nr_pci}  alias_nr=${common_args_dict["admin_alias"]}
        Run Keyword If  '${status1}' == 'False' and '${check_nr_attach}' != 'QCAT'  Run Keywords
        ...  Log  First attempt was not successful so the UE will be reseted!  console=True
        ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${ue_alias}  ue_class=${ue_info[0]}
        ...  AND  Sleep  60s
        ...  AND  Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}
        ...  ${mbn_profile}
        ...  AND  Taf Ue Perform attach and check cell  ue_alias=${ue_alias}  cell_check=${current_anchor_cell}  ue_info=${ue_info}
        ...  check_nr_attach=${check_nr_attach}  wcdma_cell_id=False  separated_4g_5g_on_mdm=${separated_4g_5g_on_mdm}
        ...  expected_nr_pci_list=${current_nr_pci}  alias_nr=${common_args_dict["admin_alias"]}
        ...  ELSE IF  '${status1}' == 'False' and '${check_nr_attach}' == 'QCAT'  Run Keywords
        ...  Log  First attempt was not successful so the UE will be reseted!  console=True
        ...  AND  Run Keyword And Ignore Error  Taf Ue Reboot UE based on UE class  ue_alias=${ue_alias}  ue_class=${ue_info[0]}
        ...  AND  Sleep  60s
        ...  AND  taf.ue.Detach Ue  ue_alias=${ue_alias}  timeout=300
        ...  AND  Taf Ue Assure mbn profile presence if AT commands UE  ${ue_info[0]}  ${ue_info[2]}  ${ue_info[3]}  ${ue_info[4]}  ${ue_info[5]}
        ...  ${mbn_profile}
        ...  AND  Taf Ue Perform attach and check cell  ue_alias=${ue_alias}  cell_check=${current_anchor_cell}  ue_info=${ue_info}  second_run=True
        ...  check_nr_attach=${check_nr_attach}  wcdma_cell_id=False   separated_4g_5g_on_mdm=${separated_4g_5g_on_mdm}
        ...  expected_nr_pci_list=${current_nr_pci}  alias_nr=${common_args_dict["admin_alias"]}
        Set Test Variable  ${current_ue_alias}  ${ue_alias}
        Run Keyword If  '${attach_only}'=='True'
        ...  Log  Data transfer part will be skipped due to attach_only flag set to True!  console=True
        ...  ELSE  Run Keywords
        ...  Log  Launching Data Call on UE ${ue_alias}  console=True
        ...  AND  Taf Ue Perform Data Call  ue_alias=${ue_alias}  dt_name=${ue_alias}_Throughput  call_timeout=${call_timeout}
        ...  call_duration=${CALL_DURATION}  data_args_dict=${common_args_dict}
        Run Keyword If  '${detach_ue}' == 'True'  Run Keywords
        ...  Log  Performing UE detach  console=True
        ...  AND  taf.ue.Detach Ue  ue_alias=${ue_alias}  timeout=300
        Exit For Loop If  '${USE_ATTENUATOR}'=='NO'
    END

Taf Ue Get current anchor cell
    [Arguments]  ${lte_cell_keys}  ${cells_list}  ${current_cell_index}
    ${current_anchor_cell}=  Set Variable  None
    FOR  ${key}  IN  @{lte_cell_keys}
        ${current_anchor_cell}=  Set Variable If  ${cells_list[${current_cell_index}]} in ${NRpci_lteCellId[${key}]}  ${key}  ${current_anchor_cell}
    END
    [Return]  ${current_anchor_cell}

Taf Ue Perform attach and check cell
    [Documentation]
    ...  *AUTHOR*
    ...  bogdan.hurduzeu@nokia.com
    ...  This kw perform attach and verify if the UE get IP and if the UE is attached on expected cell
    ...  *USAGE*
    ...  | Parameter              | Man.| Description                                                                                                |
    ...  | ue_alias               | YES | Uniquely identify UE through UE alias                                                                      |
    ...  | cell_check             | YES | List of eligible cells for UE to be attached on                                                            |
    ...  | check_nr_attach        | NO  | 5G call specific flag. Possible values: None, ADB, QCAT, AT, aashell. Default value: None                  |
    ...  | ue_info                | NO  | List containing UE_Info from config                                                                        |
    ...  | call_type              | No  | specify call type: data, voice. Default: data                                                              |
    ...  | wcdma_cell_id          | NO  | Flag indicating if attach is performed on WCDMA cell ID. Possible values: True/False. Default value: False |
    ...  | separated_4g_5g_on_mdm | NO  | Possible values: True or False; Indicates if 4G is spearated from 5G on modem (e.g. QCT8150)               |
    ...  | expected_nr_pci_list   | NO  | list of NR PCI be checked that call was performed on for the case when NR call is checked through aashell  |
    ...  | alias_nr               | NO  | Alias of NR admin for the case when NR call is checked through aashell                                     |
    ...
    [Arguments]  ${ue_alias}  ${cell_check}  ${ue_info}  ${check_nr_attach}=None  ${call_type}=data  ${wcdma_cell_id}=False
    ...  ${second_run}=False  ${separated_4g_5g_on_mdm}=False  ${expected_nr_pci_list}=None  ${alias_nr}=None

    ${mdm}=  Set Variable If  '${separated_4g_5g_on_mdm}'=='True'  mdm  ${None}
    ${use_hop}=  Set Variable If  '${alias_nr}'=='Slave'  True  False
    Run Keyword If  '${check_nr_attach.upper()}' == 'QCAT' and ${second_run} == True
    ...  Run Keyword And Ignore Error  taf.ue.Stop RRC logs  ${ue_alias}  mdm=${mdm}  timeout=600
    Run Keyword If  '${check_nr_attach.upper()}' == 'QCAT'
    ...  taf.ue.Start RRC logs  ${ue_alias}
    taf.ue.Attach Ue  ue_alias=${ue_alias}  timeout=120
    ${actual_cell_id}=  taf.ue.Get Ue Info  ${ue_alias}  CELL_ID
    ${ue_cid} =  Evaluate  str(${actual_cell_id} & 0xFFFF)
    ${actual_cell_id}=  Set Variable If  '${wcdma_cell_id}'=='True'  ${ue_cid}  ${actual_cell_id}
    ${actual_ue_ip}=  Run Keyword If  '${call_type.lower()}'=='data'  taf.ue.Get UE Info  ${ue_alias}  IP
    Run Keyword If  '${call_type.lower()}'=='data'  Log  UE ${ue_alias} attached with IP: ${actual_ue_ip}  console=True
    ${status}=  Run Keyword And Return Status  List Should Contain Value  ${cell_check}  ${actual_cell_id}
    Run Keyword If  ${status}  Log  UE is attached on expected cell! Cell id: ${actual_cell_id}   console=True
    ...  ELSE  Run Keywords
    ...  Log  UE is not attached on expected cell! Actual cell id: ${actual_cell_id}  console=True
    ...  AND  Fail  UE is not attached on expected cell! Actual cell id: ${actual_cell_id}
    ${nw_mode}=  Run Keyword If  '${check_nr_attach.upper()}' == 'ADB'
    ...  Taf Ue Verify if UE is attached on NR
    ...  ip_pc_ue=${ue_info[2]}  username_pc_ue=${ue_info[3]}  password_pc_ue=${ue_info[4]}  ue_sn=${ue_info[1]}
    ...  ELSE IF  '${check_nr_attach.upper()}' == 'AT'  Run Keywords
    ...  Log  Taf Ue Verify if UE is attached on NR with AT commands  console=True
    ...  AND  Taf Ue Verify if UE is attached on NR with AT commands  ${ue_alias}  ${actual_cell_id}
    ...  ELSE IF  '${check_nr_attach.upper()}' == 'AASHELL'  Run Keywords
    ...  Log  Taf Ue Verify if UE is attached on NR cell with aahsell  console=True
    ...  AND  Taf Ue Verify if UE is attached on NR cell with aahsell  ${ue_alias}  ${expected_nr_pci_list}  ${alias_nr}  ${use_hop}
    ...  ELSE IF  '${check_nr_attach.upper()}' == 'QCAT'  Run Keywords
    ...  Log  Taf Ue Verify if UE is attached on NR with RRC Logs  console=True
    ...  AND  taf.ue.Stop RRC logs    ${ue_alias}  mdm=${mdm}  timeout=600
    ...  AND  Taf Ue Verify if UE is attached on NR with RRC LOGS  cell_id_lte=${actual_cell_id}  ip_pc_ue=${ue_info[2]}
    ...  username_pc_ue=${ue_info[3]}  password_pc_ue=${ue_info[4]}

Taf Ue Verify if UE is attached on NR with RRC LOGS
    [Documentation]
    ...  *AUTHOR*
    ...  bogdan.hurduzeu@nokia.com, gabriel.stanculescu@nokia.com
    ...  Kw for verify if UE is attached on expected NR Cell
    ...  *USAGE*
    ...  | Parameter           | Man.  | Description                                                 |
    ...  | cell_id_lte         | Yes   |  Cell id of LTE Anchor                                      |
    ...  | ip_pc_ue            | YES   | HOST to connect SSH on PC UE                                |
    ...  | username_pc_ue      | YES   | USERNAME to login SSH on PC UE                              |
    ...  | password_pc_ue      | YES   | PASSWORD to login SSH on PC UE                              |
    ...

    [Arguments]  ${cell_id_lte}  ${ip_pc_ue}  ${username_pc_ue}  ${password_pc_ue}
    Log  Getting the RRC LOGS from PC_UE
    ${cell_id_lte_as_number}=  Convert To Integer  ${cell_id_lte}
    ${pci_NR}=  Get From Dictionary  ${NRpci_lteCellId}  ${cell_id_lte_as_number}
    ${new_pci_NR}=  Run Keyword If  type(${pci_NR}) is list
    ...  Set Variable  ${pci_NR}
    ...  ELSE
    ...  Create List  ${pci_NR}
    ${pci_NR}=  Set Variable If  type(${pci_NR}) is list  ${pci_NR}  ${new_pci_NR}
    SSHLibrary.Open Connection  host=${ip_pc_ue}  timeout=30s
    SSHLibrary.Login  username=${username_pc_ue}  password=${password_pc_ue}
    SSHLibrary.Write  ls /cygdrive/c/pyro_server/logs/diag_log_*.txt
    ${output_for_file}=  SSHLibrary.Read  delay=20sec  loglevel=TRACE
    ${file_name_incomplete}=  Fetch From Right  ${output_for_file}  /
    ${file}=  Fetch From Left  ${file_name_incomplete}  .
    ${txt_file}=  Set Variable  /cygdrive/c/pyro_server/logs/${file}.txt
    ${qdml_file}=  Set Variable  /cygdrive/c/pyro_server/logs/${file}.qdml
    SSHLibrary.Start Command
    ...  grep -A 5 ${txt_file} -e 'NR5G RRC OTA.*RRC_RECONFIG_COMPLETE' | grep -oh 'Physical Cell ID = [0-9]*' | awk -F '= ' '{print $2}' | tail -n 1
    ${pci_from_log_to_be_parsed_str}=  SSHLibrary.Read Command Output  timeout=20
    ${pci_from_log_to_be_parsed}=  Convert To Integer  ${pci_from_log_to_be_parsed_str}
    ${attach_on_nr_rrc}=  Set Variable If  ${pci_from_log_to_be_parsed} in ${pci_NR}  True  False
    SSHLibrary.Start Command  grep ${txt_file} -o -e 'RACH Result\\s*=\\s*[A-Z]*' | awk -F '= ' '{print $2}' | tail -n 1
    ${Rach_attempt_text}=  SSHLibrary.Read Command Output  timeout=20
    Run Keyword If  '${attach_on_nr_rrc}'=='True' and '${Rach_attempt_text}'=='SUCCESS'   Run Keywords
    ...  Log  Attach was succesfully on NR Cell with PCI: ${pci_from_log_to_be_parsed_str}  console=True
    ...  AND  SSHLibrary.Get File  source=${txt_file}  destination=${Temp Logs Dir}/
    ...  AND  SSHLibrary.Write  rm ${txt_file}
    ...  AND  SSHLibrary.Write  rm ${qdml_file}
    ...  ELSE  Run Keywords
    ...  SSHLibrary.Get File  ${txt_file}  ${Temp Logs Dir}/
    ...  AND  Log  Attach was not succesfully or the trace was not parsed  console=True
    ...  AND  SSHLibrary.Write  rm ${txt_file}
    ...  AND  SSHLibrary.Write  rm ${qdml_file}
    ...  AND  FAIL
    [Teardown]  SSHLibrary.Close Connection

Taf Ue Reboot UE and wait until it boots via ADB
    [Documentation]
    ...  *AUTHOR*
    ...  bogdan.hurduzeu@nokia.com
    ...  Kw for performing adb reboot and wait UE to boot
    ...  *USAGE*
    ...  | Parameter             | Man. | Description                                                 |
    ...  | ue_alias              | YES  | Uniquely identify UE through UE alias                       |
    ...  | timeout               | NO  | Timeout for reboot_ue method                                 |
    ...
    [Arguments]  ${ue_alias}  ${timeout}=75
    taf.ue.Reboot UE  ${ue_alias}  ${timeout}

Taf Ue Reboot UE and wait until it boots via AT commands
    [Documentation]
    ...  *AUTHOR*
    ...  bogdan.hurduzeu@nokia.com
    ...  Kw for performing reboot with AT commands and wait UE to boot
    ...  *USAGE*
    ...  | Parameter             | Man. | Description                                                 |
    ...  | ue_alias              | YES  | Uniquely identify UE through UE alias                       |
    ...
    [Arguments]  ${ue_alias}
    taf.ue.Reboot UE  ${ue_alias}

Taf Ue Reboot UE based on UE class
    [Documentation]
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...  Kw for performing UE reboot using adb command or AT command based on ue class
    ...  *USAGE*
    ...  | Parameter             | Man. | Description                                                 |
    ...  | ue_alias              | YES  | Uniquely identify UE through UE alias                       |
    ...  | ue_class              | YES  | Class of UE defined in config                               |
    ...  | timeout               | NO   | Timeout for reboot_ue method (applicable for adb only)      |
    ...
    [Arguments]  ${ue_alias}  ${ue_class}  ${timeout}=180
    Run Keyword If  '${ue_class}' == 'TafUeAndroid'  Taf Ue Reboot UE and wait until it boots via ADB  ${ue_alias}  ${timeout}
    ...  ELSE IF   '${ue_class}' == 'TafUeAt'  Taf Ue Reboot UE and wait until it boots via AT commands  ${ue_alias}


Taf Ue Verify if UE is attached on NR
    [Documentation]
    ...  *AUTHOR*
    ...  bogdan.hurduzeu@nokia.com, gabriel.stanculescu@nokia.com
    ...  Kw for verify if UE with given SN is attached on NR
    ...  *USAGE*
    ...  | Parameter           | Man.  | Description                                                 |
    ...  | ip_pc_ue            | YES   | HOST to connect SSH on PC UE                                |
    ...  | username_pc_ue      | YES   | USERNAME to login SSH on PC UE                              |
    ...  | password_pc_ue      | YES   | PASSWORD to login SSH on PC UE                              |
    ...  | ue_sn               | YES   | Serial number of UE                                         |
    ...
    [Arguments]  ${ip_pc_ue}  ${username_pc_ue}  ${password_pc_ue}  ${ue_sn}
    Log  Getting dumpsys telephony.registry from adb on UE ${ue_sn}  console=True
    SSHLibrary.Open Connection  host=${ip_pc_ue}    timeout=30s
    SSHLibrary.Login  username=${username_pc_ue}  password=${password_pc_ue}
    Log  Get ADB root access  console=True
    ${adb_root}=  SSHLibrary.Write  adb -s ${ue_sn} root
    Sleep  30s
    ${response}=  SSHLibrary.Write  adb -s ${ue_sn} shell dumpsys telephony.registry | grep -E "nrState="  loglevel=TRACE
    ${output}=  SSHLibrary.Read  delay=2sec  loglevel=TRACE
    ${output_parsed}=  Get Lines Matching Regexp  string=${output}  pattern=\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}.\\d{3}  partial_match=true
    @{lines}=  Split To Lines  ${output_parsed}
    Should Not Be Empty  ${lines}
    ${last_line}=  Set Variable  ${lines[-1]}
    ${timestamp_last_dump}=  Get Regexp Matches	 string=${last_line}  pattern=\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}.\\d{3}
    Should Not Be Empty  ${timestamp_last_dump}
    ${timestamp_last_dump_value}=  Set Variable  ${timestamp_last_dump[0]}
    Log  Timestamp of last telephony.registry dump ${timestamp_last_dump_value}  console=True
    Log  Getting current date from adb on UE ${ue_sn}  console=True
    ${response}=  SSHLibrary.Write  adb -s ${ue_sn} shell date +"%Y-%m-%dT%H:%M:%S.%3N"  loglevel=TRACE
    ${output}=  SSHLibrary.Read  delay=2sec  loglevel=TRACE
    ${output_parsed}=  Get Lines Matching Regexp  string=${output}  pattern=\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}.\\d{3}  partial_match=true
    @{lines}=  Split To Lines  ${output_parsed}
    Should Not Be Empty  ${lines}
    ${current_timestamp_value}=  Set Variable  ${lines[0]}
    Log  Current adb shell date is ${current_timestamp_value}  console=True
    ${time_diff}=  Subtract Date From Date  ${current_timestamp_value}  ${timestamp_last_dump_value}
    ${status_of_nrAttach}=  Run Keyword And Return Status  Should Contain  ${last_line}  nrState=CONNECTED
    Run Keyword If  ${status_of_nrAttach}
    ...  Log  NR attach succesfully verified with ADB commands!  console=True
    ...  ELSE  Fail  NR attach checked from ADB commands failed!
    Run Keyword If  ${time_diff} > 600
    ...  Log
    ...  Be aware that more than 10 min passed (${time_diff} seconds) between current time and last telephony.registry dump (containing NR attach)
    ...  level=INFO  console=True
    [Teardown]  SSHLibrary.Close Connection

Taf Ue Perform taf ue voice call with one UE on cell list
    [Documentation]
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...  Kw for performing taf ue voice call with one UE on cell list
    ...  *USAGE*
    ...  | Parameter             | Man. | Description                                                                                          |
    ...  | common_args_dict      | YES  | Dictionary containing args for data and voice call:  TECHNO, USE_ATTENUATOR, cells_list,   ...       |
    ...  | ue_index              | YES  | Useful to uniquely identify UE through UE alias                                                      |
    ...  | detach_ue             | NO   | Detach UE at the end of KW; Possible values: True/False. Default value: False                        |
    ...  | wcdma_cell_id         | NO   | Flag indicating if attach is performed on WCDMA cell ID. Values: True/False. Default value: False    |
    ...
    ...  *EXAMPLE*
    ...   Taf Ue Perform taf ue voice call with one UE on cell list | common_args_dict | 1 | True
    ...
    ...
    [Arguments]  ${common_args_dict}  ${ue_index}  ${detach_ue}=False  ${wcdma_cell_id}=False

    FOR  ${key}  IN  @{common_args_dict.keys()}
        Set Test Variable  ${${key}}  ${common_args_dict["${key}"]}
    END

    ${ue_alias}=  Catenate  SEPARATOR=  UE_  ${ue_index}
    ${call_duration_int}=  Remove String  ${CALL_DURATION}  s
    ${call_timeout}=  Taf Ue Evaluate Call Timeout  call_duration=${call_duration_int}  call_type=${call_type}  call_direction=${call_direction}
    ${number_of_cells}=  Taf Ue Calculate number of cells  cells_list=${cells_list}

    Taf Ue Require Single UE  ue_alias=${ue_alias}  capabilities=${capabilities}

    Run Keyword If  '${USE_ATTENUATOR}'=='YES'  Close All Cell Antl Signal  ${BACKUP_SCF_PATH}  ${TECHNO}  ${cells_list}
    FOR  ${current_cell_index}  IN RANGE  0  ${number_of_cells}
        Run Keyword If  '${USE_ATTENUATOR}'=='YES'  Run Keywords
        ...  Set Cell PA  ${cells_list[${current_cell_index}]}  0  ${BACKUP_SCF_PATH}  ${TECHNO}
        ...  AND  Run Keyword If  ${current_cell_index}>0  Set Cell PA  ${cells_list[${current_cell_index} - 1]}  100  ${BACKUP_SCF_PATH}  ${TECHNO}
        ${cell_check}=  Set Variable If  '${USE_ATTENUATOR}'=='YES'  ${cells_list[${current_cell_index}:${current_cell_index}+1]}  ${cells_list}
        taf.ue.Attach Ue  ue_alias=${ue_alias}  timeout=10
        ${actual_cell_id}=  taf.ue.Get Ue Info  ${ue_alias}  CELL_ID
        ${ue_cid} =  Evaluate  str(${actual_cell_id} & 0xFFFF)
        ${actual_cell_id}=  Set Variable If  '${wcdma_cell_id}'=='True'  ${ue_cid}  ${actual_cell_id}
        ${status}=  Run Keyword And Return Status  List Should Contain Value  ${cell_check}  ${actual_cell_id}
        Run Keyword If  ${status}  Log  UE is attached on expected cell! Cell id: ${actual_cell_id}   console=True
        ...  ELSE  Run Keywords
        ...  Log   UE is not attached on expected cell! Actual cell id: ${actual_cell_id}  console=True
        ...  AND  taf.ue.Detach Ue  ue_alias=${ue_alias}  timeout=10
        ...  AND  Fail  UE is not attached on expected cell! Actual cell id: ${actual_cell_id}
        Set Test Variable  ${current_ue_alias}  ${ue_alias}
        Log  Launching ${CALL_DURATION} seconds Voice Call on UE ${ue_alias}  console=True
        Taf Ue Perform Voice Call  ue_alias=${ue_alias}  vc_alias=${ue_alias}_${actual_cell_id}  call_timeout=${call_timeout}
        ...  call_duration=${CALL_DURATION}  voice_args_dict=${common_args_dict}
        Run Keyword If  '${detach_ue}' == 'True'  Run Keywords
        ...  Log  Performing UE detach  console=True
        ...  AND  taf.ue.Detach Ue  ue_alias=${ue_alias}  timeout=300
        Exit For Loop If  '${USE_ATTENUATOR}'=='NO'
    END

Taf Ue Solution display expected throughput values
    [Documentation]
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...  Kw used to display expected throughput values (UL or DL) for a specific data transfer thread for one UE
    ...  *USAGE*
    ...  | Parameter              | Man. | Description                                                                                    |
    ...  | ue_alias               | YES  | taf ue alias used to identify UE                                                               |
    ...  | dt_name                | YES  | taf ue alias used to identify data transfer thread                                             |
    ...  | direction              | YES  | Call direction. Possible values: UL, DL                                                        |
    ...  | protocol               | YES  | protocol used for data transfer. Examples: tcp, udp                                            |
    ...  | tput_min               | Yes  | Min value for the throughput to be accepted in bits/second. Example:  60 Mbits/sec             |
    ...  | tput_max               | Yes  | Max value for the throughput to be accepted in bits/second. Example:  10 Mbits/sec             |
    ...
    ...  *RETURN VALUE*
    ...  | None |
    ...
    [Arguments]  ${ue_alias}  ${dt_name}  ${direction}  ${protocol}  ${tput_min}  ${tput_max}
    Log  ============ ${direction.upper()} ${protocol.upper()} for ${ue_alias} thread ${dt_name} expected values ============  console=True
    Log  - ${direction.upper()} ${protocol.upper()} min value: ${tput_min}  console=True
    Log  - ${direction.upper()} ${protocol.upper()} max value: ${tput_max}  console=True
    Log  ============  console=True

Taf Ue Solution display actual throughput values
    [Documentation]
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...  Kw used to display actual throughput values (UL or DL) for a specific data transfer thread for one UE
    ...  *USAGE*
    ...  | Parameter              | Man. | Description                                                                                    |
    ...  | ue_alias               | YES  | taf ue alias used to identify UE                                                               |
    ...  | dt_name                | YES  | taf ue alias used to identify data transfer thread                                             |
    ...  | direction              | YES  | Call direction. Possible values: UL, DL                                                        |
    ...  | protocol               | YES  | protocol used for data transfer. Examples: tcp, udp                                            |
    ...
    ...  *RETURN VALUE*
    ...  | None |
    ...
    [Arguments]  ${ue_alias}  ${dt_name}  ${direction}  ${protocol}
    ${actual_value}=  taf.ue.Get Average Throughput  ${dt_name}
    Log  ============ ${direction.upper()} ${protocol.upper()} for ${ue_alias} thread ${dt_name} actual value ============  console=True
    Log  - ${direction.upper()} ${protocol.upper()} actual average value read from iperf report: ${actual_value} Kbps  console=True
    Log  ============  console=True

Taf Ue Get UE info based on capabilities
    [Documentation]
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...  Extract relevant info from TAF_UE_CONFIG related to one specific UE, identified by CAPABILITIES
    ...  *USAGE*
    ...  | Parameter              | Man. | Description                                                                                    |
    ...  | CAPABILITIES           | YES  | Identificator for UE from TAF_UE_CONFIG                                                        |
    ...  | mnb_profile_used       | NO   | Possible values: True, False; Default value: True                                              |
    ...
    ...  *RETURN VALUE*
    ...  | ue_info |
    ...
    [Arguments]  ${searched_capability}  ${mnb_profile_used}=True
    ${config_ues_list}=  Set Variable  ${tl.ues}
    ${ue_info}=  Create List  @{EMPTY}
    FOR  ${ue}  IN  @{config_ues_list}
        ${found_capability}=  Set Variable If  '${searched_capability}' in ${ue.capabilities}  ${TRUE}  ${FALSE}
        Continue For Loop If  not ${found_capability}
        ${ue_capabilities}=  Set Variable  ${ue.capabilities}
        ${ue_class}=  Set Variable  ${ue.__class__.__name__}
        ${ue_plugin}=    Set Variable  ${ue.class_name}
        ${ue_serial_number}=  Set Variable If  '${ue_class}' == 'TafUeAndroid'  ${ue.serial_number}  N/A
        ${ue_mbn_interface}=  Set Variable If  '${ue_class}' == 'TafUeAt' and '${mnb_profile_used}' == 'True'
        ...  ${ue.data_transfer[0].interface_name}  N/A
        ${ue_pc_ip}=  Set Variable  ${ue.ue_pc_address}
        ${login}=  Set Variable If  '${ue_class}' == 'TafUeAt'  ${ue.ue_pc_login}
        ...  '${ue_class}' == 'TafUeAndroid'  ${ue.ssh_connection_details.username}
        ${ue_pc_password}=  Set Variable If  '${ue_class}' == 'TafUeAt'  ${ue.ue_pc_password}
        ...  '${ue_class}' == 'TafUeAndroid'  ${ue.ssh_connection_details.password}
        ${ue_pc_port}=  Set Variable  ${ue.ue_pc_port}
        Append To List  ${ue_info}  ${ue_class}  ${ue_serial_number}  ${ue_pc_ip}  ${login}   ${ue_pc_password}  ${ue_mbn_interface}    ${ue_plugin}
        ...  ${ue_pc_port}
        Return From Keyword  ${ue_info}
    END
    Fail  Searched capability: ${searched_capability} not found!

Taf Ue Check mbn profile presence
    [Documentation]
    ...  *AUTHOR*
    ...  mihai-silviu.dumbrava@nokia.com, gabriel.stanculescu@nokia.com
    ...  Test if mbn profile is present on UE PC in case AT command config is used for UE
    ...  *USAGE*
    ...  | Parameter              | Man. | Description                                                                                    |
    ...  | UE_PC_IP               | YES  | IP of the Windows UE PC                                                                        |
    ...  | UE_PC_User             | YES  | User for ssh login on UE PC                                                                    |
    ...  | UE_PC_Password         | YES  | Password for ssh login on UE PC                                                                |
    ...  | MBN_Interface_name     | YES  | Name of the MBN interface used by the UE                                                       |
    ...
    ...  *RETURN VALUE*
    ...  | profile_existence |
    ...
    [Arguments]  ${UE_PC_IP}  ${UE_PC_User}  ${UE_PC_Password}  ${MBN_Interface_name}
    SSHLibrary.Open Connection    ${UE_PC_IP}    timeout=30s
    SSHLibrary.Login    ${UE_PC_User}    ${UE_PC_Password}
    ${ssh_command}=    SSHLibrary.Execute Command  netsh mbn show profiles interface="${MBN_Interface_name}"
    ${match}  ${value}=  Run Keyword And Ignore Error  Should Contain  ${ssh_command}  Profiles on interface ${MBN_Interface_name}
    ${profile_existence}=  Set Variable If  '${match}' == 'PASS'  ${True}  ${False}
    [Return]  ${profile_existence}
    [Teardown]  SSHLibrary.Close Connection

Taf Ue Add mbn profile
    [Documentation]
    ...  *AUTHOR*
    ...  mihai-silviu.dumbrava@nokia.com, gabriel.stanculescu@nokia.com
    ...  Adds mbn profile using netsh commands on Windows UE PC
    ...  *USAGE*
    ...  | Parameter              | Man. | Description                                                                                           |
    ...  | UE_PC_IP               | YES  | IP of the Windows UE PC                                                                               |
    ...  | UE_PC_User             | YES  | User for ssh login on UE PC                                                                           |
    ...  | UE_PC_Password         | YES  | Password for ssh login on UE PC                                                                       |
    ...  | MBN_Interface_name     | YES  | Name of the MBN interface used by the UE                                                              |
    ...  | Profile_path   | YES  | Local full path to the xml mbn profile; ex.:/home/ute/btsauto/{44234681-CCDB-4C88-BD59-BDAD3D3C4DBD}.xml      |
    ...
    [Arguments]  ${UE_PC_IP}  ${UE_PC_User}  ${UE_PC_Password}  ${MBN_Interface_name}  ${Profile_path}
    ${profile_name}=  Fetch From Right  string=${Profile_path}  marker=/
    SSHLibrary.Open Connection    ${UE_PC_IP}
    SSHLibrary.Login    ${UE_PC_User}    ${UE_PC_Password}
    SSHLibrary.Put File  source=${Profile_path}  destination=/cygdrive/c/cygwin64/usr/tmp
    ${ssh_command}=    SSHLibrary.Execute Command
    ...  netsh mbn add profile interface="${MBN_Interface_name}" name="C:\\cygwin64\\usr\\tmp\\${profile_name}"
    [Teardown]  SSHLibrary.Close Connection

Taf Ue Assure mbn profile presence if AT commands UE
    [Documentation]
    ...  *AUTHOR*
    ...  mihai-silviu.dumbrava@nokia.com, gabriel.stanculescu@nokia.com
    ...  Checks if mbn profile exists on Windows UE PC. If not it will be created. For the case when UE Class is TafUeAndroid this KW will be skipped
    ...  *USAGE*
    ...  | Parameter              | Man. | Description                                                                                          |
    ...  | UE_PC_IP               | YES  | IP of the Windows UE PC                                                                              |
    ...  | UE_PC_User             | YES  | User for ssh login on UE PC                                                                          |
    ...  | UE_PC_Password         | YES  | Password for ssh login on UE PC                                                                      |
    ...  | MBN_Interface_name     | YES  | Name of the MBN interface used by the UE                                                             |
    ...  | Profile_path     | YES  | Local full path to the xml mbn profile; ex:/home/ute/btsauto/{44234681-CCDB-4C88-BD59-BDAD3D3C4DBD}.xml    |
    ...
    [Arguments]  ${UE_Class}  ${UE_PC_IP}  ${UE_PC_User}  ${UE_PC_Password}  ${MBN_Interface_name}  ${Profile_path}
    Run Keyword If  '${UE_Class}' != 'TafUeAt' or '${Profile_path}' == 'None'  Return From Keyword
    ${profile_presence}=  Taf Ue Check mbn profile presence  ${UE_PC_IP}  ${UE_PC_User}  ${UE_PC_Password}  ${MBN_Interface_name}
    Run Keyword If  ${profile_presence}  Run Keywords
    ...  Log  MBN Profile found, continuing execution  console=True
    ...  AND  Return From Keyword
    ...  ELSE  Run Keywords
    ...  Log  MBN Profile not found, it will be created  console=True
    ...  AND  Taf Ue Add mbn profile  ${UE_PC_IP}  ${UE_PC_User}  ${UE_PC_Password}  ${MBN_Interface_name}  ${Profile_path}
    Sleep  5s
    ${profile_presence}=  Taf Ue Check mbn profile presence  ${UE_PC_IP}  ${UE_PC_User}  ${UE_PC_Password}  ${MBN_Interface_name}
    Run Keyword If  ${profile_presence}  Log  MBN Profile was successfully added  console=True
    ...  ELSE  Fail  MBN Profile could not be added.

Taf Ue Detach Multiple UEs
    [Documentation]
    ...  KW used to reserve multiple UEs defined in config to be handled by taf.ue
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                                                                     |
    ...  | capabilities_list    | No   | List of capabilities used to identify UEs from config separated by space                        |
    ...  | timeout              | No   | timeout for the require UEs operation                                                           |
    ...
    ...  *RETURN VALUE*
    ...  | None |
    ...
    [Arguments]  ${capabilities_list}=None  ${timeout}=300
    [Timeout]  ${timeout} sec
    Run Keyword If  '${capabilities_list}' == 'None'  Fail  Argument capabilities is mandatory in order to identify UE from config!
    ${capabilities_list}=  Split String  ${capabilities_list}  ${SPACE}
    ${detached_ues}=  Create List  @{EMPTY}
    FOR  ${capability}  IN  @{capabilities_list}
        ${ue_alias}=  Set Variable  UE_${capability}
        Taf Ue Start Proxy Server Single Port  ${capability}
        ${ue_require_succesful}=  Run Keyword And Return Status  taf.ue.Require Ue  ue_alias=${ue_alias}  capabilities=${capability}
        Run Keyword If  not ${ue_require_succesful}  Fail  UE Require failed!
        ${actual_cell_id}=  run keyword and return status  taf.ue.Get Ue Info  ${ue_alias}  CELL_ID
        Run Keyword If  '${actual_cell_id}'=='-1'
        ...  Log  UE identified by capability ${capability} is not attached on any cell! No detach needed!  console=True
        ...  ELSE  Run Keywords
        ...  Log  Detaching UE identified by capability ${capability}, ue_alias=${ue_alias}.  console=True
        ...  AND  taf.ue.Detach Ue  ue_alias=${ue_alias}  timeout=${timeout}
        ...  AND  Append To List  ${detached_ues}  ${ue_alias}
    END
    [Return]  ${detached_ues}

Taf Ue Check Hanging Resources
    [Documentation]
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...  Keyword Used To Check Haning Resources on NR or LTE
    ...  *USAGE*
    ...  | Parameter              | Man.  | Description                                                                                    |
    ...  | techno                 | No    | Technology on which Haning Resources will be checked. Possible values: NR, LTE, NR_LTE         |
    ...  | hop                    | No    | Specify whether to check hanging resources using hop (on VM2) or not (local VM);               |
    ...                                   | Possible values: True/False; Default value: False                                              |
    ...  | alias                  | No    | Admin alias connection                                                                         |
    ...  *RETURN VALUE*
    ...  | ${status_resources} |
    [Arguments]  ${techno}=NR  ${use_hop}=False  ${alias}=Master
    Log  Check Hanging Resources on ${techno} technology  console=True
    ${resources_usage}=  Taf Ue Setup aashell and Get Resources Usage  ${alias}  ${use_hop}
    ${NR_resources}=  Catenate  SEPARATOR=|  allocated  current  Ues  numOfResources  numOfUsers  admittedNsaUsers  numberOfActiveUeNsa
    ...  bearerCount  ueCount
    ${LTE_resources}=  Catenate  SEPARATOR=|  allocated  current  Ues  numContextInfo  numEnbUeS1APIds  numTeIds  numS1Connections  numContexts
    ...  numBearers  numOsaids  numGtpRoutes  numCrntis|numDRbs  numContextInfos
    ${NR_LTE_resources_regex}=  Catenate  SEPARATOR=|
    ...  ${LTE_resources}  numOfResources|numOfUsers|admittedNsaUsers|numberOfActiveUeNsa|bearerCount|ueCount
    ${resources_usage_modif}=  Taf Ue Exclude res types from resources usage dict  ${resources_usage}  ${techno}
    ${status_resources}=  Run Keyword And Return Status  Should All Be Zero  ${resources_usage_modif}  ${NR_LTE_resources_regex}
    [Return]  ${status_resources}

Taf Ue Exclude res types from resources usage dict
    [Arguments]  ${resources_usage}  ${techno}
    Run Keyword If  'NR' not in '${techno}'  Return From Keyword  ${resources_usage}
    ${excluded_resource_types}=  Create List  poolPayload  poolCtrl  poolPayloadRlcBundles  poolInd
    ${CPNRT_res}=  Set Variable  ${resources_usage["CPNRT"]["l2Resource"]["l2hiInfo"][0]["l2hiResource"]}
    ${CPRT_res}=  Set Variable  ${resources_usage["CPRT"]["l2resource"]["l2hiList"]["l2hiInfo"][0]["l2hiResource"]}
    ${CPNRT_res_modified}=  Create List  @{EMPTY}
    ${CPRT_res_modified}=  Create List  @{EMPTY}
    FOR  ${item}  IN   @{CPNRT_res}
        Run Keyword If  "${item["resourceType"]}" not in ${excluded_resource_types}  Append To List  ${CPNRT_res_modified}  ${item}
    END
    FOR  ${item}  IN   @{CPRT_res}
        Run Keyword If  "${item["resourceType"]}" not in ${excluded_resource_types}  Append To List  ${CPRT_res_modified}  ${item}
    END
    Set To Dictionary  ${resources_usage["CPNRT"]["l2Resource"]["l2hiInfo"][0]}  l2hiResource=${CPNRT_res_modified}
    Set To Dictionary  ${resources_usage["CPRT"]["l2resource"]["l2hiList"]["l2hiInfo"][0]}  l2hiResource=${CPRT_res_modified}
    [Return]  ${resources_usage}

Taf Ue Verify if UE is attached on NR with AT commands
    [Documentation]
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...  This keyword helps to check NR cell id on which UE is attached via AT commands (for Quectel UEs)
    ...  *USAGE*
    ...  | ue_alias               | YES  | taf ue alias used to identify UE      |
    ...  | cell_id_lte            | YES  | Cell id of LTE Anchor                 |
    ...
    ...  *RETURN VALUE*
    ...  | nr_cell_id |
    [Arguments]  ${ue_alias}  ${cell_id_lte}
    ${cell_id_lte_as_number}=  Convert To Integer  ${cell_id_lte}
    ${pci_NR}=  Get From Dictionary  ${NRpci_lteCellId}  ${cell_id_lte_as_number}
    Taf Ue Start Data Transfer Single UE  ue_alias=${ue_alias}  dt_name=dummy_dt_dl  call_duration=100s  call_direction=dl  throughput=60 Mbits/sec
    ...  protocol=udp  timeout=60
    Taf Ue Start Data Transfer Single UE  ue_alias=${ue_alias}  dt_name=dummy_dt_ul  call_duration=100s  call_direction=ul  throughput=60 Mbits/sec
    ...  protocol=udp  timeout=60
    Wait Until Keyword Succeeds  1 min  2 sec  Taf Ue Send Servingcell AT Command  ${ue_alias}  ${pci_NR}
    Log  Verification succesful. UE attached on NR cell as expected!  console=True
    taf.ue.Stop Data Transfer  dt_name=dummy_dt_dl
    taf.ue.Stop Data Transfer  dt_name=dummy_dt_ul

Taf Ue Send servingcell AT command
    [Arguments]  ${ue_alias}  ${pci_NR}
    Log  Checking NR serving cell belongs to ${pci_NR} through AT command console=True
    ${at_cmd_response}=  taf.ue.Send AT cmd to UE  ${ue_alias}  AT\+QENG\="servingcell"
    ${nr_cell_ids_matches}=  Get Regexp Matches  ${at_cmd_response[3]}  "NR5G\-NSA\",[0-9]+,[0-9]+,([0-9]+),  1
    ${resp_len}=  Get Length  ${nr_cell_ids_matches}
    ${nr_matched_str}=  Set Variable  ${nr_cell_ids_matches[0]}
    ${nr_matched_int} =  Convert To Integer  ${nr_matched_str}
    Run Keyword If  ${resp_len}==0  Fail  No match found!
    Run Keyword If  ${nr_matched_int} in ${pci_NR}  Log  Verification succesful. UE attached on NR PCI: ${nr_matched_int} as expected!  console=True
    ...  ELSE  Fail  Verification failed. UE attached on unexpected NR PCI: ${nr_matched_int}!

Taf Ue Verify if UE is attached on NR cell with aahsell
    [Arguments]  ${ue_alias}  ${expected_pci_list}  ${alias}   ${use_hop}=False  ${exclusive_call_check}=True
    ${expected_nr_cell_id_list}=  Create List  @{EMPTY}
    FOR  ${pci}  IN  @{expected_pci_list}
        ${expected_nr_cell_id}=  Taf Ue Get NR cell ID based on PCI  ${pci}
        Append To List  ${expected_nr_cell_id_list}  ${expected_nr_cell_id}
    END
    Taf Ue Start Data Transfer Single UE  ue_alias=${ue_alias}  dt_name=dummy_dt_dl  call_duration=100s  call_direction=dl  throughput=60 Mbits/sec
    ...  protocol=udp  packet_size=1400  timeout=60
    Taf Ue Start Data Transfer Single UE  ue_alias=${ue_alias}  dt_name=dummy_dt_ul  call_duration=100s  call_direction=ul  throughput=60 Mbits/sec
    ...  protocol=udp  packet_size=1400  timeout=60
    ${resources_usage}=  Taf Ue Setup aashell and Get Resources Usage  ${alias}  ${use_hop}
    taf.ue.Stop Data Transfer  dt_name=dummy_dt_dl
    taf.ue.Stop Data Transfer  dt_name=dummy_dt_ul
    ${aahsell_cells_info}=  Set Variable  ${resources_usage["CPRT"]["cellList"]["cellInfo"]}
    Set Test Variable  ${nr_call_checked}  False
    Set Test Variable  ${nr_cell_call_succesful}  None
    FOR  ${key}  IN  @{aahsell_cells_info}
        Run Keyword If  '${key['activeUEsPerCell']}'!='0' and ${key['nrCellIdentity']} not in ${expected_nr_cell_id_list}
        ...  Run Keyword If  '${exclusive_call_check}'=='True'
        ...  Fail  Unexpected call on NR cell ${key['nrCellIdentity']}!
        Run Keyword If  '${key['activeUEsPerCell']}'=='1' and ${key['nrCellIdentity']} in ${expected_nr_cell_id_list}  Run Keywords
        ...  Log  NR call succesfully verified on cell ${key['nrCellIdentity']}!  console=True
        ...  AND  Set Test Variable  ${nr_call_checked}  True
        ...  AND  Set Test Variable  ${nr_cell_call_succesful}   ${key['nrCellIdentity']}
    END
    Run Keyword If  '${nr_call_checked}'=='False'
    ...  Fail  NR call was not verified on aashell for NR cells ${expected_pci_list}/${expected_nr_cell_id_list}
    [Return]  ${nr_cell_call_succesful}

Taf Ue Set target NR cell from defaultLnRelGnbCellId
    [Arguments]  ${eutran_cell_id}  ${nr_cell_id}  ${anchor_alias}
    ${cells_info}=  coam.Get Cell List  connection=${anchor_alias}
    ${lte_cells_info_list}=  Set Variable  ${cells_info["cells"]["lte"]}
    FOR  ${lte_cell_info}  IN  @{lte_cells_info_list}
        Run Keyword If  '${lte_cell_info["eutranCellId"]}'=='${eutran_cell_id}'  Run Keywords
        ...  Taf Ue Determine LnRelGnbCellId to set up specific target NR cell  ${lte_cell_info['id']['internal']}  ${nr_cell_id}  ${anchor_alias}
        ...  AND  Log Long String
        ...  Performing Recommissioning of defaultLnRelGnbCellId to ${LNRELGNBCELL_value_to_set} in order to set up
        ...  desired target NR cell ${nr_cell_id}  console=True
        ...  AND  coam.Perform Parameter Recommissioning  dist_name=${lte_cell_info['id']['configuration']}  parameter=defaultLnRelGnbCellId
        ...  operation=update  value=${LNRELGNBCELL_value_to_set}  skip_parameter_relation_errors=True  should_activate=True
        ...  connection=${anchor_alias}
        ...  AND  Return From Keyword
    END
    Fail  Eutran cell id ${eutran_cell_id} not found!

Taf Ue Determine LnRelGnbCellId to set up specific target NR cell
    [Arguments]  ${LTE_cell_id}  ${nr_cell_id}  ${anchor_alias}

    ${LNRELGNBCELL_dn_list}  ${LNRELGNBCELL_dn_list_length}=  Taf Ue Get LNRELGNBCELL list for LTE cell  ${LTE_cell_id}
    ...  ${anchor_alias}
    Run Keyword If  '${LNRELGNBCELL_dn_list_length}'=='0'  Fail  Cannot find LNRELGNBCELL object for LTE cell ${LTE_cell_id}!
    FOR  ${LNRELGNBCELL_dn}  IN  @{LNRELGNBCELL_dn_list}
        ${LNRELGNBCELL_id}=  Fetch From Right  ${LNRELGNBCELL_dn}  LNRELGNBCELL-
        ${lteNrDualConnectAllowed}  ${current_nrCellId}=  Taf Ue Get lteNrDualConnectAllowed and nrCellId parameters for LNRELGNBCELL
        ...  ${LNRELGNBCELL_dn}  ${anchor_alias}
        Run Keyword If  '${current_nrCellId}' == '${nr_cell_id}'  Run Keywords
        ...  Set Test Variable  ${LNRELGNBCELL_value_to_set}  ${LNRELGNBCELL_id}
        ...  AND  Log  LNRELGNBCELL object for setting up target NR cell has id: ${LNRELGNBCELL_id}  console=True
        ...  AND  Return From Keyword
    END
    Fail  LNRELGNBCELL object for setting up target NR cell ${nr_cell_id} not found!

Taf Ue Get NR cell ID based on PCI
    [Arguments]  ${expected_pci}
    ${expected_nr_cell_id}=  Set Variable  None
    ${NRCellid_PCI_keys}=  Get Dictionary Keys  ${NRCellid_PCI}
    FOR  ${key}  IN  @{NRCellid_PCI_keys}
        ${expected_nr_cell_id}=  Set Variable If  '${NRCellid_PCI[${key}]}'=='${expected_pci}'  ${key}  ${expected_nr_cell_id}
    END
    Run Keyword If  '${expected_nr_cell_id}' == 'None'  Fail  Cell ${expected_pci} not found among NR PCIs!
    [Return]  ${expected_nr_cell_id}

Taf Ue Setup aashell and Get Resources Usage
    [Arguments]  ${alias}   ${use_hop}=False
    ${alias_pc_ip}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_PC_IP_ADDRESS
    ${alias_pc_ssh_username}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_PC_SSH_USERNAME
    ${alias_tech_ip}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH_IP_ADDRESS
    &{hop}=  Run Keyword If  '${use_hop}'!='False'  Create Dictionary  host=${alias_pc_ip}
    ...  user=${alias_pc_ssh_username}
    &{hops}=  Run Keyword If  '${use_hop}'!='False'
    ...  Create Dictionary  proxy=${hop}  host=${alias_tech_ip}
    ...  ELSE  Create Dictionary  host=${alias_tech_ip}
    aashell.Create aashell CLI  name=aashell  hops=${hops}
    aashell.Setup  aashell
    ${status}  ${resources_usage}=  Run Keyword And Ignore Error  aashell.Get Resources Usage    name=aashell  ignore_json_decoding_error=False
    ${resources_usage}=  Run Keyword If  '${status}'!='PASS'  aashell.Get Resources Usage    name=aashell  ignore_json_decoding_error=True
    ...  ELSE  Set Variable  ${resources_usage}
    [Teardown]    aashell.Teardown   aashell
    [Return]  ${resources_usage}

Taf Ue Check RSSI and raise warning
    [Documentation]
    ...  *AUTHOR*
    ...  valentin.marian@nokia.com
    ...  During voice call on GSM techno, RSSI difference between main and one of the RXs can be checked
    ${RSSI_max_difference}=  Set Variable  10
    ${difference}  ${log}=  hran_elementmanager2g.Get RSSI difference list GSM
    ${valid_result}=  Get Length  ${difference}
    Run Keyword If  ${valid_result}==0
    ...  Log  RSSI values could not be read  level=WARN
    ...  ELSE  Taf Ue Check RSSI difference on list  ${difference}  ${RSSI_max_difference}

Taf Ue Check RSSI difference on list
    [Documentation]
    ...  *AUTHOR*
    ...  valentin.marian@nokia.com
    ...  Helper Kw for Taf Ue Check RSSI and raise warning
    [Arguments]  ${diff_list}  ${treshold}
    ${result}=  Set Variable  ${True}
    FOR  ${element}  IN  @{diff_list}
        ${result}=  Set Variable If  ${element}>${treshold}  ${FALSE}  ${result}
    END
    Run Keyword If  ${result}
    ...  Log  No RSSI difference is greater than ${treshold}  console=True
    ...  ELSE  Run Keywords  Log  RSSI difference between Main and one RX is greater than ${treshold}  level=ERROR
    ...  AND  Fail  RSSI difference between Main and one RX is greater than ${treshold}
    [Return]  ${result}

Taf Ue Calculate call step timeout
    [Arguments]  ${call_duration}  ${call_type}  ${call_direction}  ${cells_list}  ${techno}  ${attenuator}
    ${number_of_cells}=  Taf Ue Calculate number of cells  ${cells_list}
    ${number_of_cells}=  Set Variable If  '${attenuator}'=='YES'  ${number_of_cells}  1
    ${techno_lower}=  Convert to Lowercase  ${techno}
    ${phones_list}=  Set Variable  ${${techno_lower}_ues}
    ${number_of_phones}=  Taf Ue Calculate number of phones  ${phones_list}
    ${call_timeout}=  Taf Ue Evaluate call timeout  ${call_duration}  ${call_type}  ${call_direction}
    ${step_timeout}=  Evaluate  2 + ${number_of_phones} * (18 + ${number_of_cells} *(12 + ${call_timeout})) + 120 + 300
    [Return]  ${step_timeout}

Taf Ue Evaluate call timeout
    [Arguments]  ${call_duration}  ${call_type}  ${call_direction}
    ${call_timeout}=  Evaluate  ${call_duration} + 4 * ${call_duration}//10 + 200
    ${double_call_timeout}=  Evaluate  2 * ${call_timeout}
    ${call_timeout}=  Set Variable If  '${call_type}'=='data' and '${call_direction}'=='uplink_downlink'  ${double_call_timeout}  ${call_timeout}
    [Return]  ${call_timeout}

Taf Ue Calculate number of cells
    [Arguments]  ${cells_list}
    ${number_of_cells}=  Get length  ${cells_list}
    [Return]  ${number_of_cells}

Taf Ue Calculate number of phones
    [Arguments]  ${phones_list}
    ${number_of_phones}=  Get length  ${phones_list}
    [Return]  ${number_of_phones}

Taf Ue Start Proxy Server single port
    [Documentation]
    ...  KW used to assure that Proxy Server is started on UE PC on common port for UEs to be handled by taf ue library.
    ...  Also this KW will terminate Proxy Server processes outside of the test scope.
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter                  | Man. | Description                                          |
    ...  | UE_capability              | Yes  | Identificator for UE from TAF_UE_CONFIG              |
    ...  *RETURN VALUE*
    ...  | None |
    ...

    [Arguments]   ${UE_capability}
    ${ue_info}=  Taf Ue Get UE info based on capabilities  ${UE_capability}  False
    ${ip_pc_ue}=  Set Variable  ${ue_info[2]}
    ${username_pc_ue}=  Set Variable  ${ue_info[3]}
    ${password_pc_ue}=  Set Variable  ${ue_info[4]}
    ${ue_pc_port}=  Set Variable  ${ue_info[7]}
    ${ue_pc_proxy_server_instance}=  Replace String  ${ip_pc_ue}  .  _
    ${current_context_proxy_PIDs_exists}=  Run Keyword And Return Status  Variable Should Exist
    ...  ${current_context_proxy_PIDs_${ue_pc_proxy_server_instance}}
    Set Test Variable  @{current_context_proxy_PIDs_${ue_pc_proxy_server_instance}}  @{EMPTY}

    Run Keyword If  ${current_context_proxy_PIDs_exists}  Run Keywords
    ...  Log  Proxy server instance already started on ${ip_pc_ue} in current context, reusing instance.  console=True
    ...  AND  Return From Keyword

    Log  Starting new proxy server instance on ${ip_pc_ue}  console=True

    SSHLibrary.Open Connection  host=${ip_pc_ue}    timeout=30s
    SSHLibrary.Login  username=${username_pc_ue}  password=${password_pc_ue}
    ${PIDs}=  Taf Ue Get current proxy server processes
    Taf Ue Stop All Existing Proxy Server Processes  ${PIDs}

    ${use_USB_Byte_Protocol}=  Get Variable Value  ${USB_Byte_Protocol}  ${FALSE}
    ${naa_protocol}=  Set Variable If  ${use_USB_Byte_Protocol}  usb_byte  socketio
    ${cmd1}=  Set Variable  export KAFKA_BOOTSTRAP_SERVER='kafka-0.taf.nsn-rdnet.net;kafka-1.taf.nsn-rdnet.net;kafka-2.taf.nsn-rdnet.net';
    ${cmd2}=  Set Variable  run_ue_proxy --naa_protocol ${naa_protocol} -p ${ue_pc_port}
    ${cmd}=  Catenate  ${cmd1}  ${cmd2}

    Run keyword and ignore error    SSHLibrary.Start Command  ${cmd}
    Sleep  120s

Taf Ue Get current proxy server processes
    ${PIDs}=  Create List  @{EMPTY}
    SSHLibrary.Start Command  ps -W | grep run_ue_proxy
    ${ssh_cmd_output}=  SSHLibrary.Read Command Output  timeout=20
    ${ssh_cmd_output_lines}=  Split To Lines  ${ssh_cmd_output}
    FOR  ${line}  IN  @{ssh_cmd_output_lines}
        ${line_strip}=  Replace String Using Regexp  ${line}  \\s+  ${SPACE}
        ${matches}=  Split String  ${line_strip}  ${SPACE}
        ${PID}=  Get From List  ${matches}  4
        ${PID_strip}=  Strip String  ${PID}
        Append To List  ${PIDs}  ${PID_strip}
    END
    ${PIDs}=  Remove Duplicates  ${PIDs}
    [Return]  ${PIDS}

Taf Ue Stop All Existing Proxy Server Processes
    [Arguments]  ${PIDs}
    FOR  ${PID}  IN  @{PIDs}
        SSHLibrary.Start Command  taskkill /F /pid ${PID}
    END

Taf Ue Get LNRELGNBCELL list for LTE cell
    [Arguments]  ${LTE_cell_id}  ${alias}
    ${scf_initial}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ...  folder_path=${BTSFiles}/${alias}
    Set Test Variable  ${${alias}_scf_initial}  ${scf_initial}
    ${LNCEL_id}=  Fetch From Right  ${LTE_cell_id}  LNCEL_R-
    ${LNRELGNBCELL_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/LNCEL-${LNCEL_id}/LNRELGNBCELL-[\\d]+$  alias=${alias}
    ${LNRELGNBCELL_dn_list_length}=  Get Length  ${LNRELGNBCELL_dn_list}
    [Return]  ${LNRELGNBCELL_dn_list}  ${LNRELGNBCELL_dn_list_length}

Taf Ue Get lteNrDualConnectAllowed and nrCellId parameters for LNRELGNBCELL
     [Arguments]  ${LNRELGNBCELL_dn}  ${alias}
     ${lteNrDualConnectAllowed}  ${nrCellId}=  Get Cell Parameters from SCF  lteNrDualConnectAllowed  nrCellId
     ...  cell_dist_name=${LNRELGNBCELL_dn}  alias=${alias}
     [Return]  ${lteNrDualConnectAllowed}  ${nrCellId}

Taf Ue Get LTE Anchor Cells NR Cells mapping
    [Arguments]  ${LTE_cell_ids}  ${alias_lte}
    ${LTE_Anchor_Cell_NR_Cell_mapping}=  Create Dictionary  @{EMPTY}
    FOR  ${LTE_cell_id}  IN  @{LTE_cell_ids}
        ${LTE_cell_params}=  Get Parameters For  class_name=LNCEL  id_num=${LTE_cell_id}  timeout=10  alias=${alias_lte}
        ${LNRELGNBCELL_dn_list}  ${LNRELGNBCELL_dn_list_length}=  Taf Ue Get LNRELGNBCELL list for LTE cell  ${LTE_cell_id}  ${alias_lte}
        Run Keyword If  '${LNRELGNBCELL_dn_list_length}' == '0'  Continue For Loop
        ${LTE_Anchor_Cell_NR_Cell_mapping}=  Taf Ue Get eutraCelIds for specific LNRELGNBCELL
        ...  ${LTE_Anchor_Cell_NR_Cell_mapping}  ${LNRELGNBCELL_dn_list}  ${LTE_cell_params}  ${alias_lte}
    END
    [Return]  ${LTE_Anchor_Cell_NR_Cell_mapping}

Taf Ue Get eutraCelIds for specific LNRELGNBCELL
    [Arguments]  ${LTE_Anchor_Cell_NR_Cell_mapping}  ${LNRELGNBCELL_dn_list}  ${LTE_cell_params}  ${alias_lte}
    ${updated_list}=  Create List  @{EMPTY}
    FOR  ${LNRELGNBCELL_dn}  IN  @{LNRELGNBCELL_dn_list}
        ${lteNrDualConnectAllowed}  ${nrCellId}=  Taf Ue Get lteNrDualConnectAllowed and nrCellId parameters for LNRELGNBCELL  ${LNRELGNBCELL_dn}
        ...  ${alias_lte}
        Run Keyword If  '${lteNrDualConnectAllowed}' == 'allowed'
        ...  Append To List  ${updated_list}  ${nrCellId}
    END
    ${status}=  Run Keyword And Return Status  Should Not Be Empty  ${updated_list}
    Run Keyword If  ${status}  Set To Dictionary  ${LTE_Anchor_Cell_NR_Cell_mapping}  ${LTE_cell_params.eutraCelId}   ${updated_list}
    [Return]  ${LTE_Anchor_Cell_NR_Cell_mapping}

Get all sector cells
    [Documentation]
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  Get all cell IDs (from all BTS and all RAT) from the same sector with current_cell_id
    ...  The KW returns a dictionary where key is BTS alias, value is a list of CELL_R_ids
    ...
    ...  *INPUT*
    ...  | Parameter                 | Mandatory | Description                                                                       |
    ...  | current_cell_id           | Yes       | Current cell ID                                                                   |
    ...  | techno_current_cell       | Yes       | Technology of current cell. Possible values: NR, LTE                              |
    ...  | alias_current_cell        | Yes       | Alias of admin instance of BTS where current cell is present                      |
    ...
    ...  *RETURN VALUE*
    ...  | sector_cells_dict |
    ...
    [Arguments]  ${current_cell_id}  ${techno_current_cell}  ${alias_current_cell}
    ${cell_obj_class}=  Set Variable If  '${techno_current_cell}'=='NR'  NRCEL  '${techno_current_cell}'=='LTE'  LNCEL
    ${BTS_current_cell_ANTL_mapping}=  Get Cell ANTLN relation  ${cell_obj_class}  ${alias_current_cell}
    ${current_cell_ANTL_mapping}=  Get From Dictionary  ${BTS_current_cell_ANTL_mapping}  ${current_cell_id}
    ${sector_cells_dict}=  Create Dictionary
    FOR  ${alias}  IN  @{alias_list}
        ${sector_cells_list}=  Create List
        ${NR_Cell_ANTL_mapping}=  Get Cell ANTLN relation  NRCEL  ${alias}
        ${nr_cells_list}=  Get BTS cells mapped on same sector  ${current_cell_ANTL_mapping}  ${NR_Cell_ANTL_mapping}
        Run Keyword If  '${techno_current_cell}' == 'NR' and '${alias_current_cell}' == '${alias}'
        ...  Set Test Variable  ${current_cell_R_id}  ${CellIdentity_cell_internal_mapping["${current_cell_id}"]}
        ${LTE_Cell_ANTL_mapping}=  Get Cell ANTLN relation  LNCEL  ${alias}
        ${lte_cells_list}=  Get BTS cells mapped on same sector  ${current_cell_ANTL_mapping}  ${LTE_Cell_ANTL_mapping}
        Run Keyword If  '${techno_current_cell}' == 'LTE' and '${alias_current_cell}' == '${alias}'
        ...  Set Test Variable  ${current_cell_R_id}  ${CellIdentity_cell_internal_mapping["${current_cell_id}"]}
        ${sector_cells_list}=  Combine Lists  ${nr_cells_list}  ${lte_cells_list}
        Run Keyword If  '${techno_current_cell}' == 'NR' and '${alias_current_cell}' == '${alias}'
        ...  Remove Values From List  ${sector_cells_list}  ${current_cell_R_id}
        Run Keyword If  '${techno_current_cell}' == 'LTE' and '${alias_current_cell}' == '${alias}'
        ...  Remove Values From List  ${sector_cells_list}  ${current_cell_R_id}
        Set To Dictionary  ${sector_cells_dict}  ${alias}=${sector_cells_list}
    END
    [Return]  ${sector_cells_dict}

Set cellBarred on sector cells
    [Documentation]
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  Set cellBarred parameter on sector cells
    ...  The KW takes as input argument the sector_cells_dict (key=admin alias; value=list of cell IDs)
    ...  and sets cellBarred parameter on all with the value from argument cellBarred_value
    ...
    ...  *INPUT*
    ...  | Parameter                 | Mandatory | Description                                                   |
    ...  | sector_cells_dict         | Yes       | Dictionary containing sector cell IDs on each BTS             |
    ...  | cellBarred_value          | Yes       | Value to set. Possible values: barred, notBarred              |
    ...
    [Arguments]  ${sector_cells_dict}  ${cellBarred_value}
    FOR  ${alias}  IN  @{alias_list}
        Set cellBarred on BTS cells  ${sector_cells_dict["${alias}"]}  ${cellBarred_value}  ${alias}
    END

Get BTS cells mapped on same sector
    [Arguments]  ${current_Cell_ANTL_mapping}  ${current_checked_BTS_ANTL_mapping}
    ${same_sector_cells_list}=  Create List
    FOR  ${cell_id}  IN  @{current_checked_BTS_ANTL_mapping}
        ${status}=  Run Keyword And Return Status   Lists Should Be Equal   ${current_checked_BTS_ANTL_mapping["${cell_id}"]}
        ...  ${current_Cell_ANTL_mapping}
        ${CELL_R_id}=  Get From Dictionary    ${CellIdentity_cell_internal_mapping}    ${cell_id}
        Run Keyword If  ${status}  Append To List  ${same_sector_cells_list}  ${CELL_R_id}
    END
    [Return]  ${same_sector_cells_list}

Set cellBarred on BTS cells
    [Arguments]  ${cells_list}  ${cellBarred_value}  ${alias}
    FOR  ${CELL_R_id}  IN  @{cells_list}
        ${cell_type}=  Set Variable If
        ...  'LNCEL' in '${CELL_R_id}'  lte
        ...  'NRCEL' in '${CELL_R_id}'  nr
        ${CELL_SCF_DN}=  Get CELL SCF runtime distinguished name  ${CELL_R_id}  ${alias}  ${cell_type}
        ${CELL_SCF_DN}=  Set Variable If
        ...  'LNCEL' in '${CELL_SCF_DN}'  ${CELL_SCF_DN}/SIB-0
        ...  'NRCEL' in '${CELL_SCF_DN}'  ${CELL_SCF_DN}
        Log  Setting cellBarred=${cellBarred_value} on BTS ${alias} - ${CELL_SCF_DN}  console=True
        coam.Perform Parameter Recommissioning  dist_name=${CELL_SCF_DN}  parameter=cellBarred  operation=update  value=${cellBarred_value}
        ...  skip_parameter_relation_errors=True  should_activate=True  timeout=600  connection=${alias}
        Sleep  10s
    END

Extract current cell target BW based on cell ID
    [Arguments]  ${cell_id}  ${techno}
    ${cell_target_bw_status}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_TARGET_BW}
    Run Keyword If  not ${cell_target_bw_status}
    ...  Fail  CELL_TARGET_BW not found! Cannot Extract cell target BW based on cell ID
    ${TECHNO_TARGET_BW_params}=  Get From Dictionary  ${CELL_TARGET_BW}  ${techno.upper()}
    ${cell_id_int}=  Convert To Integer   ${cell_id}
    ${CELL_TARGET_BW_params}=  Get From Dictionary  ${TECHNO_TARGET_BW_params}  ${cell_id_int}
    Set Test Variable  ${CELL_TARGET_BW_params}

Get Full Configuration Cell IDs
    Log  Getting Full Configuration Cell IDs  console=True
    ${full_config_cell_IDs}=  Create Dictionary
    ${NRCellid_PCI}=  Create Dictionary
    Set Test Variable  ${full_config_cell_IDs}
    Set Test Variable  ${NRCellid_PCI}
    FOR  ${alias}  IN  @{alias_list}
        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
        ...    Get all CBTS cell IDs    ${alias}
        ...    AND    Continue For Loop
        Log  Getting cell IDs on BTS ${alias}  console=True
        ${all_cell_id_internal_id_mapping}=  Create Dictionary
        Set Test Variable  ${all_cell_id_internal_id_mapping}
        ${NR_CELL_ID_LIST}  ${internal_cell_id_id_mapping}=  Get BTS Cell IDs  alias=${alias}  cell_type=NRCEL
        Set To Dictionary  ${all_cell_id_internal_id_mapping}  NR=${internal_cell_id_id_mapping}
        ${LTE_CELL_ID_LIST}  ${internal_cell_id_id_mapping}=  Get BTS Cell IDs  alias=${alias}  cell_type=LNCEL
        Set To Dictionary  ${all_cell_id_internal_id_mapping}  LTE=${internal_cell_id_id_mapping}
        ${WCMDA_CELL_ID_LIST}  ${internal_cell_id_id_mapping}=  Get BTS Cell IDs  alias=${alias}  cell_type=WNCEL
        Set To Dictionary  ${all_cell_id_internal_id_mapping}  WCDMA=${internal_cell_id_id_mapping}
        ${GSM_CELL_ID_LIST}  ${internal_cell_id_id_mapping}=  Get BTS Cell IDs  alias=${alias}  cell_type=GNCEL
        Set To Dictionary  ${all_cell_id_internal_id_mapping}  GSM=${internal_cell_id_id_mapping}
        Set Test Variable  ${${alias}_all_cell_id_internal_id_mapping}  ${all_cell_id_internal_id_mapping}

        ${cell_ids_dict}=  Create Dictionary
        Set To Dictionary  ${cell_ids_dict}  NR=${NR_CELL_ID_LIST}  LTE=${LTE_CELL_ID_LIST}  WCDMA=${WCMDA_CELL_ID_LIST}  GSM=${GSM_CELL_ID_LIST}
        Set To Dictionary  ${full_config_cell_IDs}  ${alias}=${cell_ids_dict}
        ${nr_ids_len}=  Get Length  ${NR_CELL_ID_LIST}
        Run Keyword If  ${nr_ids_len}>0  Create nrCellIdentity nrPCI mapping  ${alias}  ${NR_CELL_ID_LIST}
    END

Get all CBTS cell IDs
    [Arguments]    ${alias}
    Log  Getting cell IDs on CBTS ${alias}  console=True
    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]
    ${cell_ids_dict}=  Create Dictionary
    ${NR_CELL_ID_LIST}=  Create List
    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}
        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}
        ${VDU_CELL_info}=  vdu.Get Vdu Cells Status  vdu_connection=${vdu_alias}
        ${vdu_NR_CELL_ID_LIST}=  Get all VDU cell IDs  ${VDU_CELL_info}
        ${NR_CELL_ID_LIST}=  Combine Lists  ${NR_CELL_ID_LIST}  ${vdu_NR_CELL_ID_LIST}
        Remove Duplicates  ${NR_CELL_ID_LIST}
    END
    Set To Dictionary  ${cell_ids_dict}  NR=${NR_CELL_ID_LIST}
    Set To Dictionary  ${full_config_cell_IDs}  ${alias}=${cell_ids_dict}

Get all VDU cell IDs
    [Arguments]    ${VDU_CELL_info}
    ${NR_CELL_ID_LIST}=  Create List
    FOR  ${cell_info}  IN  @{VDU_CELL_info}
        ${nr_cell_identity}=  Get From Dictionary  ${cell_info}  nr_cell_identity
        ${physical_layer_cell_id}=  Get From Dictionary  ${cell_info}  physical_layer_cell_id
        ${NR_CelId_int}=  Convert To Integer  ${nr_cell_identity}
        ${NR_PCI_int}=  Convert To Integer  ${physical_layer_cell_id}
        Set To Dictionary  ${NRCellid_PCI}  ${NR_CelId_int}  ${NR_PCI_int}
        Append To List  ${NR_CELL_ID_LIST}  ${nr_cell_identity}
    END
    [Return]  ${NR_CELL_ID_LIST}

Get Full Configuration Anchor Cells Relations
    Log  Getting Full Configuration Anchor Cell Relations  console=True
    ${full_config_anchor_cell_relation}=  Create Dictionary
    ${extended_admin_alias_list}=  Combine Lists  ${alias_list}  ${BTS_EXT_alias_list}
    Set Test Variable  ${extended_admin_alias_list}
    FOR  ${alias}  IN  @{extended_admin_alias_list}
        ${is_ext_bts}=  Run Keyword And Return Status  Should Contain  ${alias}  BTS_EXT
        Run Keyword If  not ${is_ext_bts}  Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        Log  Getting Anchor Cell Relations on ${alias}  console=True
        ${LTE_cell_ids}=  Admin Get LTE CELL Ids list  ${alias}
        ${LTE_Anchor_Cell_NR_Cell_mapping}=  Taf Ue Get LTE Anchor Cells NR Cells mapping  ${LTE_cell_ids[0]}  ${alias}
        Set To Dictionary   ${full_config_anchor_cell_relation}  ${alias}=${LTE_Anchor_Cell_NR_Cell_mapping}
    END
    Set Test Variable  ${full_config_anchor_cell_relation}

Get cell IDs list for call
    ${cell_ids_for_call_dict}=  Create Dictionary
    Set Test Variable  ${cell_ids_for_call_dict}
    ${index}=  Set Variable  0
    FOR  ${BTS_CALL}  IN  @{UEs_BTS_CALL_LIST}
        ${ue_capability}=  Set Variable  ${UEs_CAPABILITIES_LIST[${index}]}
        ${BTS_number}=  Fetch From Right  ${BTS_CALL}  BTS
        ${BTS_number}=  Evaluate  ${BTS_number}-1
        ${alias}=  Set Variable  ${alias_list[${BTS_number}]}
        ${techno}=  Set Variable  ${UEs_TECHNOS_LIST[${index}]}
        ${alias_ue}=  Set Variable  ${ue_capability}_on_${BTS_CALL}_${techno}
        ${cell_ids_list}=  Split String  ${CELLS_LIST[${index}]}  separator=
        ${cell_ids}=  Set Variable If  "${CELLS_LIST[${index}]}"=="DEFAULT"  ${full_config_cell_IDs["${alias}"]["${techno}"]}  ${cell_ids_list}
        Set To Dictionary  ${cell_ids_for_call_dict}  ${alias_ue}=${cell_ids}
        ${index}=  Evaluate  ${index}+1
    END

Create nrCellIdentity nrPCI mapping
    [Arguments]  ${alias}  ${nr_cell_id_list}
    ${CELL_params}=  Get Parameters For All  class_name=NRCEL  alias=${alias}
    FOR  ${item}  IN  @{CELL_params}
        ${NR_CelId_int}=  Set Variable  ${item['nrCellIdentity']}
        ${NR_PCI_int}=  Set Variable  ${item['physCellId']}
        ${NR_CelId}=  Convert To String  ${NR_CelId_int}
        Run Keyword If  "${NR_CelId}" in ${nr_cell_id_list}   Set To Dictionary  ${NRCellid_PCI}  ${NR_CelId_int}  ${NR_PCI_int}
    END

Get BTS Cell IDs
    [Arguments]  ${alias}  ${cell_type}

    ${BCF_ID_defined}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${alias.upper()}}  BCF_ID
    ${BCF_ID}=  Run Keyword If  ${BCF_ID_defined}  Get From Dictionary  ${${alias.upper()}}  BCF_ID
    ${techno}=  Set Variable If
    ...  "${cell_type}"=="NRCEL"  NR
    ...  "${cell_type}"=="LNCEL"  LTE
    ...  "${cell_type}"=="WNCEL"  WCDMA
    ...  "${cell_type}"=="GNCEL"  GSM
    ${CELL_ID_LIST}  ${temp_cell_id_internal_id_mapping}=
    ...  Run Keyword If  "${techno}" in ['LTE', 'WCDMA']  Get SBTS Cell Ids from admin  ${alias}  ${techno}
    ...  ELSE IF  "${techno}"=="NR"  Get NR Cell Ids from admin  ${alias}
    ...  ELSE IF  "${techno}"=="GSM" and ${BCF_ID_defined}  Get GSM cell IDs from BSC and admin  ${alias}  ${BCF_ID}

    [Return]  ${CELL_ID_LIST}  ${temp_cell_id_internal_id_mapping}

Get GSM cell IDs from BSC and admin
    [Arguments]  ${alias}  ${BCF_ID}

    Open connection to BSC
    ${gsm_cell_id_internal_id_mapping}=  Create Dictionary
    ${CELL_ID_LIST}=  hran_bsc.Get GSM Cells IDs  ${BCF_ID}
    ${all_CelIds}=  Get Cell List  connection=${alias}

    FOR  ${item}  IN  @{all_CelIds['cells']['gsm']}
        ${GNCEL_R_Id}=  Set Variable  ${item['id']['internal']}
        ${params}=  coam.Get Parameters  dist_name=${GNCEL_R_Id}  connection=${alias}
        ${gsmBTSId}=  Get From Dictionary  ${params}  gsmBtsId
        ${GNCEL_R_conf_Id}=  Set Variable  ${item['id']['configuration']}
        ${GNBCF_dn}=  Fetch From Left  ${GNCEL_R_conf_Id}  /GNCEL
        ${GNBCF_Id}=  Fetch From Right  ${GNBCF_dn}  GNBCF-
        ${GSM Cell ID}=  Evaluate  (${GNBCF_Id}*10000)+${gsmBTSId}
        Run Keyword If  ${GSM Cell ID} in ${CELL_ID_LIST}  Set To Dictionary  ${gsm_cell_id_internal_id_mapping}  ${GSM Cell ID}  ${GNCEL_R_Id}
    END

    [Teardown]  Run Keyword And Ignore Error  hran_bsc.Close Connection
    [Return]  ${CELL_ID_LIST}  ${gsm_cell_id_internal_id_mapping}

Get Syslog Average Troughput
    [Arguments]    ${start_time}  ${hostname}  ${port}  ${username}  ${password}  ${alias_bts}  ${techno}  ${duration}  ${direction}
    ...  ${cell_id}  ${ue_group}

    syslog_thput.Setup Syslog Throughput Analyzer    hostname=${hostname}     port=${port}     username=${username}
    ...  password=${password}
    ...  syslog_file=${TEMP_LOGS_DIR}/SYSLOG_${alias_bts}UDP
    ...  duration=${duration}
    ...  direction=${direction}
    ...  start_time=${start_time}
    ...  techno=${techno}
    ...  cell_id=${cell_id}
    ...  ue_group=${ue_group}
    ...  work_dir=${UDPLogs}

    ${avg_thput}=  syslog_thput.Analyze Syslog Throughput

    [Return]  ${avg_thput}

Convert Throughput Value in Specific Unit
    [Arguments]  ${in_value}  ${in_value_unit}  ${out_value_unit}

    ${out_value}=  Run Keyword If  '${in_value_unit}'=='bits/sec' and '${out_value_unit}'=='Kbits/sec'  Evaluate  ${in_value}/1000
    ...  ELSE IF  '${in_value_unit}'=='bits/sec' and '${out_value_unit}'=='Mbits/sec'  Evaluate  ${in_value}/1000000
    ...  ELSE IF  '${in_value_unit}'=='bits/sec' and '${out_value_unit}'=='Gbits/sec'  Evaluate  ${in_value}/1000000000
    ...  ELSE IF  '${in_value_unit}'=='Kbits/sec' and '${out_value_unit}'=='bits/sec'  Evaluate  ${in_value}*1000
    ...  ELSE IF  '${in_value_unit}'=='Kbits/sec' and '${out_value_unit}'=='Mbits/sec'  Evaluate  ${in_value}/1000
    ...  ELSE IF  '${in_value_unit}'=='Kbits/sec' and '${out_value_unit}'=='Gbits/sec'  Evaluate  ${in_value}/1000000
    ...  ELSE IF  '${in_value_unit}'=='Mbits/sec' and '${out_value_unit}'=='bits/sec'  Evaluate  ${in_value}*1000000
    ...  ELSE IF  '${in_value_unit}'=='Mbits/sec' and '${out_value_unit}'=='Kbits/sec'  Evaluate  ${in_value}*1000
    ...  ELSE IF  '${in_value_unit}'=='Mbits/sec' and '${out_value_unit}'=='Gbits/sec'  Evaluate  ${in_value}/1000
    ...  ELSE IF  '${in_value_unit}'=='Gbits/sec' and '${out_value_unit}'=='bits/sec'  Evaluate  ${in_value}*1000000000
    ...  ELSE IF  '${in_value_unit}'=='Gbits/sec' and '${out_value_unit}'=='Kbits/sec'  Evaluate  ${in_value}*1000000
    ...  ELSE IF  '${in_value_unit}'=='Gbits/sec' and '${out_value_unit}'=='Mbits/sec'  Evaluate  ${in_value}*1000

    [Return]  ${out_value}

BTS Log Display Actual Throughput Values
    [Arguments]    ${thput_start_time}  ${hostname}  ${port}  ${username}  ${password}  ${alias_bts}  ${techno}
    ...  ${duration}  ${direction}  ${cell_id}  ${ue_group}  ${alias_ue}  ${protocol}
    ${avg_bts_log_thput}=  Get Syslog Average Troughput  ${thput_start_time}  ${hostname}  ${port}  ${username}  ${password}  ${alias_bts}  ${techno}
    ...  ${duration}  ${direction}  ${cell_id}  ${ue_group}
    Set Test Variable  ${avg_bts_log_thput}
    ${dt_name}=  Set Variable  dt_${alias_ue}_${direction.lower()}
    Log  ============ ${direction.upper()} ${protocol.upper()} for ${alias_ue} thread ${dt_name} actual value ============  console=True
    Log  - ${direction.upper()} ${protocol.upper()} actual average value computed from BTS Logs: ${avg_bts_log_thput} bps  console=True
    Log  ============  console=True

BTS Log Verify Average Throughput
    [Arguments]    ${avg_thput}  ${thput_min}  ${thput_max}

    ${thput_min_value}=  Fetch From Left  ${thput_min}  ${SPACE}
    ${thput_max_value}=  Fetch From Left  ${thput_max}  ${SPACE}
    ${thput_min_unit}=  Fetch From Right  ${thput_min}  ${SPACE}
    ${thput_max_unit}=  Fetch From Right  ${thput_max}  ${SPACE}
    ${thput_min_bits}=  Run Keyword If  '${thput_min_unit}'=='bits/sec'   ${thput_min_value}
    ...  ELSE  Convert Throughput Value in Specific Unit  ${thput_min_value}  ${thput_min_unit}  bits/sec
    ${thput_max_bits}=  Run Keyword If  '${thput_max_unit}'=='bits/sec'   ${thput_max_value}
    ...  ELSE  Convert Throughput Value in Specific Unit  ${thput_max_value}  ${thput_max_unit}  bits/sec
    ${thput_min_int}=  Convert To Integer  ${thput_min_bits}
    ${thput_max_int}=  Convert To Integer  ${thput_max_bits}
    ${avg_thput_int}=  Convert To Integer  ${avg_thput}
    Run Keyword If  (${avg_thput_int} >= ${thput_min_int}) and (${avg_thput_int} <= ${thput_max_int})
    ...  Log  BTS Log Throughput verification succeeded!  console=True
    ...  ELSE  Run Keywords  Log  BTS Log Throughput verification failed!  level=ERROR
    ...  AND  Fail  BTS Log Throughput verification failed!

Set Ue Info Test Variable
    [Arguments]    ${ue_alias}
    ${UE_info_test_variable_does_not_exist}=  Run Keyword And Return Status  Variable Should Not Exist  ${UE_info_test_variable}
    ${UE_info_test_variable}=  Run Keyword If  ${UE_info_test_variable_does_not_exist}  Create Dictionary  UES=@{EMPTY}
    ${all_ue_info}=  taf.ue.Get Ue Info  ${ue_alias}
    Append To List  ${UE_info_test_variable["UES"]}  ${all_ue_info}
    Set Test Variable  ${UE_info_test_variable}
