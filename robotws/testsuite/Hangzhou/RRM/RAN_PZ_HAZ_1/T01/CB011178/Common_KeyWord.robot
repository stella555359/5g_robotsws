*** Settings ***
Documentation     Keywords related to Testline11068
...   Author:  zhixia
...   Contact: zhixia.qin@nokia-sbell.com
Resource    ../../Resources/Cloud/AIC_Common_Resource.robot
*** Variables ***
&{dcap_info}    host=10.21.41.38    port=443    username=utfuser    password=utfadmin!
@{sub_cells_info}    1
@{phy_event_enable_ext}    EPhyEvent_PuschSnapshotVerification
&{vdu_event_based_tracer}    sub_cells_info=${sub_cells_info}    max_no_of_snapshots=1    bts_snapshot=10
...    phy_event_enable_ext=${phy_event_enable_ext}    domain=NrUlPhy
&{argument}    vdu_event_based_tracer=${vdu_event_based_tracer}    wait_stop_time=15min    check_interval=1min
&{argument_demand}     wait_stop_time=5min    check_interval=1min
${oam_url}  https://10.70.25.162/login
${case_path}   /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB011178
${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
${mcshark_plugin_addr}
...   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark
*** Keywords ***
Enable Disable 5GC002538
    [Arguments]   ${actPdschAllocAroundSsb}=true    ${actPdschAtSsbSlots}=true    ${actPdschRmCsirsForTracking}=true
    ...   ${actTrsPdschAvgCqiRatio}=false  ${mo_list_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-5   ${cudu_index}=${0}
     @{para_list}   Create List   actPdschAllocAroundSsb   actPdschAtSsbSlots    actPdschRmCsirsForTracking  actTrsPdschAvgCqiRatio
     @{value_list}   Create List   ${actPdschAllocAroundSsb}  ${actPdschAtSsbSlots}   ${actPdschRmCsirsForTracking}  ${actTrsPdschAvgCqiRatio}
     @{mo_list}   Create List   ${mo_list_name}  ${mo_list_name}  ${mo_list_name}  ${mo_list_name}
     ${res}   Parameter Operation    operation=parameter_update   product_type=vdu   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}   cudu_index=${cudu_index}

Enable Disable 5GC002538 24R3
    [Arguments]   ${actPdschAtSsbSlots}=true    ${actPdschRmCsirsForTracking}=true
    ...   ${mo_list_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-5   ${cudu_index}=${0}
     @{para_list}   Create List   actPdschAtSsbSlots    actPdschRmCsirsForTracking
     @{value_list}   Create List   ${actPdschAtSsbSlots}   ${actPdschRmCsirsForTracking}
     @{mo_list}   Create List   ${mo_list_name}  ${mo_list_name}
     ${res}   Parameter Operation    operation=parameter_update   product_type=vdu   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}   cudu_index=${cudu_index}

#Enable Disable 5GC002558
#    [Arguments]  ${actPRBBlanking}=true    ${nbrOfBlankedPRBsHighEdgeDL}=23    ${nbrOfBlankedPRBsHighEdgeUL}=23
#    ...    ${nbrOfBlankedPRBsLowEdgeDL}=3    ${nbrOfBlankedPRBsLowEdgeUL}=3    ${NRCELL}=NRCELL-5
#    ...    ${bwpDN_commdon}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-8
#    ...    ${bwpDN_dedeciated}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-88
#    ...    ${type0CoresetConfigurationIndex}=6  ${chBwDl}=20MHz   ${chBwUl}=20MHz
#    @{para_list}   Create List   actPRBBlanking   nbrOfBlankedPRBsHighEdgeDL    nbrOfBlankedPRBsHighEdgeUL
#    ...   nbrOfBlankedPRBsLowEdgeDL   nbrOfBlankedPRBsLowEdgeUL   cellBwpList/0/bwpDN   cellBwpList/1/bwpDN
#    ...   type0CoresetConfigurationIndex   chBwDl   chBwUl
#     @{value_list}   Create List   ${actPRBBlanking}   ${nbrOfBlankedPRBsHighEdgeDL}    ${nbrOfBlankedPRBsHighEdgeUL}
#     ...   ${nbrOfBlankedPRBsLowEdgeDL}   ${nbrOfBlankedPRBsLowEdgeUL}   ${bwpDN_commdon}   ${bwpDN_dedeciated}
#     ...   ${type0CoresetConfigurationIndex}   ${chBwDl}   ${chBwUl}
#     @{mo_list}   Create List   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}
#     ...   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}
#     ...   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}
#     ...   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}
#     ...   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}/NRCELL_FDD-1
#     ...   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}/NRCELL_FDD-1
#     ${res}   Parameter Operation    operation=parameter_update   product_type=vdu   para_list=${para_list}
#     ...      value_list=${value_list}   mo_list=${mo_list}   timeout=${60}

Enable Disable 5GC002558
     [Arguments]  ${delta_file_path}=${case_path}/config/5GC002558.json
     Parameter Operation    operation=delta_plan_update   product_type=vdu  delta_file_path=${delta_file_path}  wait_for_completion=${False}

Enable Disable CB008917
     [Arguments]  ${delta_file_path}=${case_path}/config/CB008917.json
     Parameter Operation    operation=delta_plan_update   product_type=vdu  delta_file_path=${delta_file_path}  wait_for_completion=${False}

#Enable Disable CB008917
#    [Arguments]  ${actSpecificBwpSize}=true  ${NRCELL}=NRCELL-5
#    ...    ${bwpDN_commdon}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-7
#    ...    ${bwpDN_dedeciated}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-77
#    ...    ${chBwDl}=15MHz   ${chBwUl}=15MHz
#    @{para_list}   Create List   actSpecificBwpSize   cellBwpList/0/bwpDN   cellBwpList/1/bwpDN  chBwDl   chBwUl
#    @{value_list}   Create List   ${actSpecificBwpSize}   ${bwpDN_commdon}   ${bwpDN_dedeciated}  ${chBwDl}   ${chBwUl}
#    @{mo_list}   Create List   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}
#     ...   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}
#     ...   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}/NRCELL_FDD-1  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}/NRCELL_FDD-1
#     ${res}   Parameter Operation    operation=parameter_update   product_type=vdu   para_list=${para_list}
#     ...      value_list=${value_list}   mo_list=${mo_list}

Activate or Deactivate 5GC001086
    [Arguments]       ${actUlSrsBm}=true   ${NRCELL}=NRCELL-2
     @{para_list}   Create List   actUlSrsBm
     @{value_list}   Create List   ${actUlSrsBm}
     @{mo_list}   Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}
     ${res}   Parameter Operation    operation=parameter_update   product_type=vdu   para_list=${para_list}  timeout=600
     ...      value_list=${value_list}   mo_list=${mo_list}

Activate or Deactivate CB006662
    [Arguments]       ${prachSequenceType}=RestrictedTypeA   ${NRCELL}=NRCELL-5
     @{para_list}   Create List   prachSequenceType
     @{value_list}   Create List   ${prachSequenceType}
     @{mo_list}   Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL}
     ${res}   Parameter Operation    operation=parameter_update   product_type=vdu   para_list=${para_list}  timeout=300
     ...      value_list=${value_list}   mo_list=${mo_list}

Compare Tput
    [Arguments]         ${tput_pdsch_on}     ${tput_pdsch_off}
    log to console      Compare Trughputs
    should be true    ${tput_pdsch_on} > ${tput_pdsch_off}

Collect and Check counter M55308C20001_M55308C21001_M55308C21002
    Log To Console      Check DU Counter
    ${du_counter_id_list}    Create List    M55308C20001    M55308C21001    M55308C21002
    ${du_counter_values_final_list}    Create List
    FOR    ${du_counter_id}    IN    @{du_counter_id_list}
        ${du_counter_values_final_list}    Check Counter For vDU   counter_id=${du_counter_id}
        ...                                            dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-5
        ...                                            expected_value=1
        ...                                            get_number=5
    END

New Check Mcshark BIP Log
    [Arguments]    ${name}=1294_bip   ${local_file_path}=null
    Log To Console    Check McShark BIP Log
    ${filter}=    Catenate        uldata_puschreceiverespps&&UlData_puschAntMeas_t.sinrOfAnt
    ${csv_title_list}   Set Variable    -e UlData_puschAntMeas_t.sinrOfAnt
    Download wireshark plugin
    Convert BIP To CSV By MCShark Local    local_file_path=${local_file_path}
    ...                              output_file=${TEST_LOG_DIRECTORY}/bip/csv_${name}.csv
    ...                              filter=${filter}
    ...                              csv_title=${csv_title_list}
    ${csv_matrix}=    read_csv_file_into_matrix    file_path=${TEST_LOG_DIRECTORY}/bip/csv_${name}.csv
    ${column_list_ant}=    get_column_from_matrix    matrix=${csv_matrix}    column_nubmer=${1}
    Remove From List    ${column_list_ant}    0
    ${len_ant}=    get length    ${column_list_ant}
    FOR    ${index}    IN RANGE    ${len_ant}
        ${len_ant_item}=    get length    ${column_list_ant[${index}]}
        Continue For Loop If        ${len_ant_item} == 4
        ${is_pass}    Set Variable If    ${len_ant_item} == 4     ${True}    ${False}
        Set Test Variable  ${is_pass}
        Exit For Loop If  ${is_pass}
    END

Full Commissioning
    [Arguments]       ${scf_name}=TC01.xml   ${product_type}=vdu
    ${scf_path}   Set Variable   ${case_path}/config/${scf_name}
    ${res}   Parameter Operation    operation=full_commission   product_type=${product_type}   scf_path=${scf_path}


Prepare Multi UEs For Dingli
   @{UEs_info}=    AIC_UE.pioneer.Detect UE and get UEs info
   @{specific_ue_list}    Create List    ${UEs_info}[0]    ${UEs_info}[1]   ${UEs_info}[2]  ${UEs_info}[3]
   FOR    ${index}    IN    @{specific_ue_list}
        ${ue_alias}   set variable    UE_${0}
        AIC_UE.pioneer.Prepare UE     imei=${index}[imei]    ue_alias=${ue_alias}
        AIC_UE.pioneer.UE Attach    ue_alias=${ue_alias}
        AIC_UE.pioneer.UE Detach    ue_alias=${ue_alias}
        sleep  5s
   END

Prepare UE For Dingli
    [Arguments]     ${ue_index}=${0}
    Log    connect UEs for pioneer   console=True
    FOR    ${index}    IN RANGE    3
        ${res_bool}   Run Keyword And Return Status     Prepare UE For Dingli with status   ue_index=${ue_index}
		Run Keyword If    '${res_bool}' == 'False'   Stop single UE For Dingli  ue_index=${ue_index}
        Run Keyword If    '${res_bool}' == 'True'    Exit For Loop
    END

Prepare UE For Dingli with status
    [Arguments]     ${ue_index}=${0}
    @{UEs_info}=    AIC_UE.pioneer.Detect UE and get UEs info
    ${ue_alias}   set variable    UE_${ue_index}
    AIC_UE.pioneer.Prepare UE     imei=${UEs_info[${ue_index}]}[imei]    ue_alias=${ue_alias}

Attach single UE For Dingli
    [Arguments]    ${ue_index}=${0}
    ${ue_alias}   set variable    UE_${ue_index}
    AIC_UE.pioneer.UE Attach    ue_alias=${ue_alias}

Detach single UE For Dingli
    [Arguments]    ${ue_index}=${0}
    ${ue_alias}   set variable    UE_${ue_index}
    AIC_UE.pioneer.UE Detach    ue_alias=${ue_alias}

Start DL Traffic For Dingli
    [Arguments]    ${ue_index}=${0}
    ${ue_alias}   set variable    UE_${ue_index}
    AIC_UE.pioneer.Start DL Traffic    dl_time=90   dl_port=8018   dl_throughput=800M   dl_length=1024B

Start UL Traffic For Dingli
    [Arguments]    ${ue_index}=${0}
    Log    start ul traffic for ue  console=True
    ${ue_alias}   set variable    UE_${ue_index}
    pioneer.Start UL Traffic    address=10.101.2.23    buffersize=100    port=5013    ue_alias=${ue_alias}
    sleep  30s
    AIC_UE.pioneer.Check Throughput    direction=ul   expected_throughput=10   ue_alias=${ue_alias}

Stop single UE For Dingli
    [Arguments]    ${ue_index}=${0}
    ${ue_alias}   set variable    UE_${ue_index}
    Run Keyword And Ignore Error  AIC_UE.pioneer.Stop DL Traffic   ue_alias=${ue_alias}
    Run Keyword And Ignore Error  AIC_UE.pioneer.Stop UL Traffic   ue_alias=${ue_alias}
    Run Keyword And Ignore Error  Detach single UE For Dingli   ue_index=${ue_index}

Make UL for Commercial UE
    log to console    start make Commercial call
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${1}
	set suite variable    ${ue_type}
    Prepare UE    ue_type=${ue_type}    ue_index=${1}
	UE Attach    ue_type=${ue_type}    ue_index=${1}
	sleep    10s
    log to console    start ul
	Run Keyword And Ignore Error    Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M
	...              ue_index=${1}    duration=7200
    sleep    5s
    log to console    start dl
    Run Keyword And Ignore Error  Start traffic    ue_type=${ue_type}    direction=dl    throughput=220M
	...              ue_index=${1}    duration=7200

Stop Commercial UE call
    Run Keyword And Ignore Error    Stop traffic    ue_type=${ue_type}    direction=ul   ue_index=${1}
    Run Keyword And Ignore Error    Stop traffic    ue_type=${ue_type}    direction=dl   ue_index=${1}
    Run Keyword And Ignore Error    UE Detach    ${ue_type}   ue_index=${1}

Activate IQ Data Data Configuration and Delete Operation
    [Arguments]   ${dl_nr_subcell_list}=${None}   ${ul_nr_subcell_list}=${None}  ${ru_iq_data_parameters_list}=${None}
    ...   ${alias}=vdu_con    ${vdu_index}=${0}   ${gnb_index}=${0}   ${capture_on_event_from_l1_hi_and_l1_low}=${False}
    log to console   ${vdu_index}
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}     alias=${alias}
    ${operation_id}   Activate IQ Data Configuration   ru_iq_data_parameters_list=${ru_iq_data_parameters_list}
    ...                        dl_nr_subcell_list=${dl_nr_subcell_list}  ul_nr_subcell_list=${ul_nr_subcell_list}
    ...                        alias=${alias}   capture_on_event=${True}   vdu_index=${vdu_index}
    ...                        capture_on_event_from_l1_hi_and_l1_low=${capture_on_event_from_l1_hi_and_l1_low}
    log to console   ${operation_id}
    ${res_opreation}   Get Operation Status of Activating IQ Data Configuration   operation_id=${operation_id}   alias=${alias}
    log to console    ${res_opreation}
#    should be equal   ${res_opreation['status']}   success
    Delete Operation of Activating IQ Data Configuration   operation_id=${res_opreation['operation_id']}
    ...                                                                              alias=${alias}
    [Teardown]    vDU Logout By Rest   vdu_index=${vdu_index}   alias=${alias}

Deactivate IQ Data Data Configuration and Delete Operation
    [Arguments]   ${alias}=vdu_con   ${vdu_index}=${0}   ${gnb_index}=${0}
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}     alias=${alias}
    ${deactivate_operation_id}   Deactivate IQ Data Configuration   alias=${alias}
    ${res_operation_deactive}   Get Operation Status of Deactivating IQ Data Configuration
    ...                                              operation_id=${deactivate_operation_id}    alias=${alias}
    Delete Operation of Deactivating IQ Data Configuration   operation_id=${deactivate_operation_id}    alias=${alias}
    [Teardown]   vDU Logout By Rest   vdu_index=${0}    alias=${alias}

Collect IQ Data and Delete Operation
   [Arguments]  ${alias}=vdu_con   ${vdu_index}=${0}   ${gnb_index}=${0}   ${local_path}=/home/ute/l1_iq_data
   ...          ${local_filename}=l1_iq_data_file.tgz
#   ...          ${file_id}=IqSamples.tgz
   vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}     alias=${alias}
   ${collect_iq_data_operation_id}   Collect IQ Data   alias=${alias}
   log to console   ${collect_iq_data_operation_id}
   ${status}   ${res_collect}   Run Keyword And Ignore Error   Wait Until Keyword Succeeds    500    50
   ...        Get Operation status of IQ Data Collection And Check File Id
   ...                                                                    operation_id=${collect_iq_data_operation_id}
   ...                                                                    alias=${alias}
   Get IQ Data File   operation_id=${res_collect['operation_id']}   file_id=${res_collect['file_id']}
   ...                local_path=${local_path}   local_filename=${local_filename}   alias=${alias}
   [Teardown]     Teardown For Iq Data Log   operation_id=${res_collect['operation_id']}   alias=${alias}  vdu_index=${0}

Teardown For Iq Data Log
   [Arguments]   ${operation_id}   ${alias}=vdu_con    ${vdu_index}=${0}
   Delete Operation of IQ Data Collection   operation_id=${operation_id}   alias=${alias}
   Run Keyword And Ignore Error   vDU Logout By Rest   vdu_index=${vdu_index}    alias=${alias}

Teardown_For_Event
    [Arguments]     ${alias}
    svdu.logout   coam=${alias}
    svdu.disable_virtual_display

Enable suspicious event
    [Arguments]     ${url}=${oam_url}
    ...   ${object_name}=NrUlPhy
    ...   ${filter_param}=phyEventEnableExt
    ...   ${new_value}=31 - EPhyEvent_PuschSnapshotVerification
    ...   ${timeout}=60   ${alias}=vdu_conn  ${version}=25R1   ${vdu_index}=${0}
    [Documentation]  Keyword for setting rnd parameter values or editing existing parameter values of given object name.
    ${vdu_version}   Get vDU Version local   vdu_index=${vdu_index}
#    ${pattern}   re.compile   vDUCNF(.*?)_
#    ${res}       re.findall   ${pattern}    ${vdu_version}
#    ${version}  Set Variable   ${res[${0}]}
    svdu.Enable Virtual Display
    svdu.login    url=${url}  password=Nokia@123   coam=${alias}    version=${version}
    sleep    10s
    ${res}   svdu.set_rnd_debug_parameters    object_name=${object_name}    filter_param=${filter_param}  new_value=${new_value}
    ...           timeout=${timeout}  coam=${alias}
    log to console   ${res}
    [Teardown]   Teardown_For_Event   alias=${alias}

Get vDU Version local
    [Arguments]    ${vdu_index}=${0}
    vDU Login By Rest  vdu_index=${vdu_index}
    ${vdu_data}=    vdu.get_vdu_state_data
    ${vdu_version}    set variable    ${vdu_data['software_version']}
    [Return]    ${vdu_version}
    [Teardown]    vDU Logout By Rest  vdu_index=${vdu_index}

Set L2PS Rnd Debug Paramters
    [Arguments]    ${url}=${oam_url}     ${timeout}=60   ${alias}=vdu_conn  ${version}=25R1  ${subCellId}=1
    [Documentation]  Keyword for setting rnd parameter values or editing existing parameter values of given object name.
#    ${vdu_version}   Get vDU Version
#    ${pattern}   re.compile   vDUCNF(.*?)_
#    ${res}       re.findall   ${pattern}    ${vdu_version}
#    ${version}  Set Variable   ${res[${0}]}
    svdu.Enable Virtual Display
    svdu.login    url=${url}  password=Nokia@123   coam=${alias}    version=${version}
    sleep    10s
    ${res_1}   svdu.set_rnd_debug_parameters    object_name=L2PS    filter_param=rdAbnormalEventTriggerOnlineEnable  new_value=1
    ...           timeout=${timeout}  coam=${alias}
    ${res_2}   svdu.set_rnd_debug_parameters    object_name=L2PS    filter_param=rdAbnormalEventRlfEnabled  new_value=1
    ...           timeout=${timeout}  coam=${alias}
    ${res_3}   svdu.set_rnd_debug_parameters    object_name=L2PS    filter_param=rdAbnormalEventTriggerNumber  new_value=120
    ...           timeout=${timeout}  coam=${alias}
    ${res_4}    Run Keyword And Ignore Error  svdu.set_rnd_debug_parameters    object_name=L2PS
    ...          filter_param=rdAbnormalEventTriggerSubcellIdForIqCapture  new_value=${subCellId}
    ...           timeout=${timeout}  coam=${alias}
    [Teardown]   Teardown_For_Event   alias=${alias}

Set NrDlPhy Rnd Debug Paramters
    [Arguments]    ${url}=${oam_url}   ${new_value}=1 - ENrDlPhyEventPdschReTxBler   ${timeout}=60   ${alias}=vdu_conn
    ...   ${version}=25R1
    [Documentation]  Keyword for setting rnd parameter values or editing existing parameter values of given object name.
#    ${vdu_version}   Get vDU Version
#    ${pattern}   re.compile   vDUCNF(.*?)_
#    ${res}       re.findall   ${pattern}    ${vdu_version}
#    ${version}  Set Variable   ${res[${0}]}
    svdu.Enable Virtual Display
    svdu.login    url=${url}  password=Nokia@123   coam=${alias}    version=${version}
    sleep    10s
    ${res_1}   svdu.set_rnd_debug_parameters    object_name=NrDlPhy    filter_param=dlPhyEventEnable   new_value=${new_value}
    ...           timeout=${timeout}  coam=${alias}
    ${res_2}   svdu.set_rnd_debug_parameters    object_name=NrDlPhy    filter_param=dlPhyCaptureTriggerTypeSpecificValue  new_value=5
    ...           timeout=${timeout}  coam=${alias}
    [Teardown]   Teardown_For_Event   alias=${alias}

Restore L2PS Rnd Debug Paramters
    [Arguments]    ${url}=${oam_url}      ${timeout}=60   ${alias}=vdu_conn  ${version}=25R1
    [Documentation]  Keyword for setting rnd parameter values or editing existing parameter values of given object name.
#    ${vdu_version}   Get vDU Version
#    ${pattern}   re.compile   vDUCNF(.*?)_
#    ${res}       re.findall   ${pattern}    ${vdu_version}
#    ${version}  Set Variable   ${res[${0}]}
    svdu.Enable Virtual Display
    svdu.login    url=${url}  password=Nokia@123   coam=${alias}    version=${version}
    sleep    10s
    ${res_1}   svdu.restore_rnd_debug_parameters    object_name=L2PS    filter_param=rdAbnormalEventTriggerOnlineEnable
    ...           timeout=${timeout}  coam=${alias}
    ${res_2}   svdu.restore_rnd_debug_parameters    object_name=L2PS    filter_param=rdAbnormalEventRlfEnabled
    ...           timeout=${timeout}  coam=${alias}
    ${res_3}   svdu.restore_rnd_debug_parameters    object_name=L2PS    filter_param=rdAbnormalEventTriggerNumber
    ...           timeout=${timeout}  coam=${alias}
    ${res_4}   Run Keyword And Ignore Error   svdu.restore_rnd_debug_parameters    object_name=L2PS
    ...           filter_param=rdAbnormalEventTriggerSubcellIdForIqCapture
    ...           timeout=${timeout}  coam=${alias}
    [Teardown]   Teardown_For_Event   alias=${alias}

Restore NrDlPhy Rnd Debug Paramters
    [Arguments]    ${url}=${oam_url}     ${timeout}=60   ${alias}=vdu_conn   ${version}=25R1
    [Documentation]  Keyword for setting rnd parameter values or editing existing parameter values of given object name.
#    ${vdu_version}   Get vDU Version
#    ${pattern}   re.compile   vDUCNF(.*?)_
#    ${res}       re.findall   ${pattern}    ${vdu_version}
#    ${version}  Set Variable   ${res[${0}]}
    svdu.Enable Virtual Display
    svdu.login    url=${url}  password=Nokia@123   coam=${alias}    version=${version}
    sleep    10s
    ${res_1}   svdu.restore_rnd_debug_parameters    object_name=NrDlPhy    filter_param=dlPhyEventEnable
    ...           timeout=${timeout}  coam=${alias}
    ${res_2}   svdu.restore_rnd_debug_parameters    object_name=NrDlPhy    filter_param=dlPhyCaptureTriggerTypeSpecificValue
    ...           timeout=${timeout}  coam=${alias}
    [Teardown]   Teardown_For_Event   alias=${alias}


Disable suspicious event
    [Arguments]     ${url}=${oam_url}
    ...   ${object_name}=NrUlPhy
    ...   ${filter_param}=phyEventEnableExt
    ...   ${timeout}=60   ${alias}=vdu_conn  ${version}=25R1
#    ${vdu_version}   Get vDU Version
#    ${pattern}   re.compile   vDUCNF(.*?)_
#    ${res}       re.findall   ${pattern}    ${vdu_version}
#    ${version}  Set Variable   ${res[${0}]}
    svdu.Enable Virtual Display
    svdu.login    url=${url}  password=Nokia@123   coam=${alias}    version=${version}
    sleep    10s
    ${res}   svdu.restore_rnd_debug_parameters    object_name=${object_name}    filter_param=${filter_param}
    ...           timeout=${timeout}  coam=${alias}
    [Teardown]   Teardown_For_Event   alias=${alias}

Set attenuator
    [Arguments]    ${value1}=${120}    ${value2}=${120}  ${value3}=${120}    ${value4}=${120}
    ...  ${value5}=${120}    ${value6}=${120}  ${value7}=${120}    ${value8}=${120}
    ...  ${value9}=${120}    ${value10}=${120}  ${value11}=${120}    ${value12}=${120}
    ...  ${value13}=${120}    ${value14}=${120}  ${value15}=${120}    ${value16}=${120}
    ...  ${RU_id}=${0}    ${du_id}=${0}   ${vendor}=TOPYOUNG   ${model}=${tl.attenuator[0].model}
    ...  ${attenuator_id}=${0}
    Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port    RU_id=${RU_id}    du_id=${du_id}
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=${RU_id}    vendor=${vendor}    du_id=${du_id}  model=${model}
    ...   attenuator_id=${attenuator_id}
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=${value1}    ${attenuation_channels[1]}=${value2}
    ...    ${attenuation_channels[2]}=${value3}    ${attenuation_channels[3]}=${value4}
    ...    ${attenuation_channels[4]}=${value5}    ${attenuation_channels[5]}=${value6}
    ...    ${attenuation_channels[6]}=${value7}    ${attenuation_channels[7]}=${value8}
    ...    ${attenuation_channels[8]}=${value9}    ${attenuation_channels[9]}=${value10}
    ...    ${attenuation_channels[10]}=${value11}    ${attenuation_channels[11]}=${value12}
    ...    ${attenuation_channels[12]}=${value13}    ${attenuation_channels[13]}=${value14}
    ...    ${attenuation_channels[14]}=${value15}    ${attenuation_channels[15]}=${value16}
    Modify Attenuation Value    ${channels_to_modify}    RU_id=${RU_id}    du_id=${du_id}
    sleep    10s
    Log to console    attenuation change complete

Activate Service Port
    [Arguments]       ${actServicePortState}=true
     @{para_list}   Create List   actServicePortState
     @{value_list}   Create List   ${actServicePortState}
     @{mo_list}   Create List   MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
     ${res}   Parameter Operation    operation=parameter_update   product_type=vdu   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}

Parse iqdata Log for UTF
    [Arguments]   ${filter_pattern}=.*E529.*IqSnapshotBuffer.xz
    ...          ${zip_snapshot_path}=zip_snapshot   ${iq_file_name}=MRBTS-${MRBTS_ID}_E529_IqSnapshotBuffer.xz
    [Documentation]  Parse snapshot
     ${save_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
      ...                 directory_name=vdu_snapshot
     ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${argument}
     Log Collection    start    event_based_L1_IQ    product_type=vdu    bts_index=${0}    dict_argument=${dict_argument}
     Attach single UE For Dingli   ue_index=2
     Start UL Traffic For Dingli   ue_index=2
     sleep  30s
     ${local_file_path}    Log Collection    stop_and_download    event_based_L1_IQ    product_type=vdu    bts_index=${0}
     ...   dict_argument=${dict_argument}
     Log To Console    \nlog: ${local_file_path}
     ${snapshot_file}   tti_analysis.extract_files_from_zip_file
     ...   archive=${local_file_path}    directory=${save_path}    postfix=.zip    substring=start_trace_Full_snapshot
     OperatingSystem.Run  unzip ${snapshot_file[0]} -d ${save_path}/
     ${file_name}    basic.find_file_in_zip_archives_in_directory
     ...   dir_zip=${save_path}/   target_file_name_regex=${filter_pattern}
     OperatingSystem.Run  unzip ${save_path}/${file_name} -d ${save_path}/${zip_snapshot_path}/
     ${local_file_size}   basic.verify_local_file_size    local_path=${save_path}/${zip_snapshot_path}/${iq_file_name}
     should be true    ${local_file_size} > 32

Parse iqdata Log
    [Arguments]   ${alias}   ${filter_pattern}=.*E529.*IqSnapshotBuffer.xz
    ...          ${zip_snapshot_path}=zip_snapshot   ${iq_file_name}=MRBTS-${MRBTS_ID}_E529_IqSnapshotBuffer.xz
    ...          ${cudu_index}=${0}
    [Documentation]  Parse snapshot
     ${save_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
      ...                 directory_name=vdu_snapshot
     ${snapshot_file}    Log Collection    start    snapshot    product_type=vdu    bts_index=${0}    cudu_index=${cudu_index}
     OperatingSystem.Run  unzip ${snapshot_file} -d ${save_path}/
     ${file_name}    basic.find_file_in_zip_archives_in_directory
     ...   dir_zip=${save_path}/   target_file_name_regex=${filter_pattern}
     OperatingSystem.Run  unzip ${save_path}/${file_name} -d ${save_path}/${zip_snapshot_path}/
     ${local_file_size}   basic.verify_local_file_size    local_path=${save_path}/${zip_snapshot_path}/${iq_file_name}
     should be true    ${local_file_size} > 32
     Log To Console    \nlog: ${alias}

get alarm for vdu
    [Arguments]  ${vdu_index}=${0}  ${gnb_index}=${0}   ${alias}=vdu_connection  ${expect_fault_id}=49
    ...          ${alarm_exist_flag}=${False}
    vDU Login By Rest    vdu_index=${vdu_index}      gnb_index=${gnb_index}  alias=${alias}
    ${out}    vdu.vdu_get_active_alarms  vdu_connection=${alias}
    ${flag_exist}  set variable   ${False}
    log to console   ${out["alarms"]}
    FOR  ${alarm_dict}  IN   @{out["alarms"]}
       log to console   ${alarm_dict["fault_id"]}
       Run Keyword If   "${alarm_dict["fault_id"]}"=="${expect_fault_id}"  run keywords
       ...     Set Test Variable    ${flag_exist}   ${True}
       ...    AND    exit for loop
    END
    should be equal    ${flag_exist}   ${alarm_exist_flag}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest   vdu_index=${vdu_index}   alias=${alias}

Get Operation status of IQ Data Collection And Check File Id
    [Arguments]  ${operation_id}  ${alias}=vdu_con
    ${res_collect}   Get Operation status of IQ Data Collection   operation_id=${operation_id}   alias=${alias}
    log to console   ${res_collect['file_id']}
    [Return]    ${res_collect}

Download wireshark plugin
    sleep    5s
    ${ver}   Run   ls ${plugin_folder}/
    ${exist_mcshark}   Run   cd ${plugin_folder}/${ver}/epan;ls mcshark*
    Run   cd ${plugin_folder}/${ver}/epan;sudo rm mcshark*
    ${mcshark_plugin_path}   Generate Mcshark path
    ${cmd_2}=    Catenate    wget -r -np -nH  ${mcshark_plugin_path}/ -P /home/ute/mcshark
    Run Keyword If    not os.path.exists("/home/ute/mcshark")   Run  cd /home/ute/;sudo mkdir mcshark
    Run  cd /home/ute/;sudo chmod 777 mcshark
    OperatingSystem.Run    command=cd /home/ute/mcshark
    OperatingSystem.Run    command=${cmd_2}
    ${mcshark_plugin_addr_local}  Replace String    ${mcshark_plugin_path}   https://artifactory-hz1.int.net.nokia.com
    ...  /home/ute/mcshark
    ${mcshark_plugin_path}=    Run Keyword If   "${ver}"=="4.2"  Catenate   ${mcshark_plugin_addr_local}/mcshark-${ver}-*rocky8.so
    ...   ELSE
    ...   Catenate   ${mcshark_plugin_addr_local}/mcshark-${ver}-*buster.so
    OperatingSystem.Run    command=sudo cp ${mcshark_plugin_path} ${plugin_folder}/${ver}/epan

Generate Mcshark path
    ${sw_list}    Split String    ${VDU_VERSION}    _
    ${sw_version}  Replace String    ${VDU_VERSION}   ${sw_list[0]}   vDUCNF00
    ${output}    OperatingSystem.Run    command=tshark -v |grep TShark
    ${lst}    Get Regexp Matches    ${output}    v(\\d{1,3}\.\\d{1,3})\.\\d{1,3}   1
    ${tshark_version}=    set variable    ${lst}[0]
    ${mcshark_plugin_path}    Run Keyword If   "${tshark_version}"=="4.2"
    ...   Set Variable    ${mcshark_plugin_addr}/${sw_version}
    ...   ELSE
    ...   Set Variable   ${mcshark_plugin_addr}/${sw_version}
    [Return]    ${mcshark_plugin_path}

Convert BIP To CSV By MCShark Local
    [Arguments]    ${local_file_path}    ${output_file}    ${filter}     ${csv_title}    ${branch}=22R3
    ${cmd}=    Catenate    tshark -r ${local_file_path} -Y '${filter}' -T fields -e _ws.col.No. ${csv_title}
    ...     -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    Log To Console    \nlog: ${branch}

Enable Disable CB008509
#    [Arguments]   ${actConfDlInterferenceGen}=PDSCH+PDCCH+TRS+SSB    ${actDlRbgRandomization}=enhanced    ${actDtxOptimizedScheduler}=false
#    ...    ${actPdschAllocAroundSsb}=true        ${actPdschAtSsbSlots}=true         ${actPdschRmCsirsForTracking}=true
#    ...    ${mcsIndexForArtificialLoad}=27       ${targetTotalLoadSectorBeam}=100
#    ...   ${mo_list_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1   ${cudu_index}=${0}
#     @{para_list}   Create List   actConfDlInterferenceGen   actDlRbgRandomization    actDtxOptimizedScheduler
#     ...    actPdschAllocAroundSsb     actPdschAtSsbSlots
#	 ...    actPdschRmCsirsForTracking    mcsIndexForArtificialLoad     targetTotalLoadSectorBeam
#     @{value_list}   Create List   ${actConfDlInterferenceGen}  ${actDlRbgRandomization}   ${actDtxOptimizedScheduler}
#     ...    ${actPdschAllocAroundSsb}    ${actPdschAtSsbSlots}
#	 ...    ${actPdschRmCsirsForTracking}    ${mcsIndexForArtificialLoad}     ${targetTotalLoadSectorBeam}
#     @{mo_list}   Create List   ${mo_list_name}  ${mo_list_name}  ${mo_list_name}
#     ...     ${mo_list_name}  ${mo_list_name}  ${mo_list_name}
#     ...     ${mo_list_name}  ${mo_list_name}
#     ${res}   Parameter Operation    operation=parameter_update   product_type=vdu   para_list=${para_list}
#     ...      value_list=${value_list}   mo_list=${mo_list}   cudu_index=${cudu_index}
     [Arguments]  ${delta_file_path}=${case_path}/config/CB008509_on.json
     Parameter Operation    operation=delta_plan_update   product_type=vdu  delta_file_path=${delta_file_path}


Check DU Counter for CB008509
    Log to console    \n***Check counter for CB008509***
    ${du_counter_id_list}    Create List    M55308C00043    M55308C00044    M55308C00045     M55308C00046
    ${du_counter_values_final_list}    Create List
    FOR    ${du_counter_id}    IN    @{du_counter_id_list}
        ${du_counter_values_final_list}    Check Counter For vDU   counter_id=${du_counter_id}
        ...                                            dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
        ...                                            expected_value=0
        ...                                            get_number=2
    END