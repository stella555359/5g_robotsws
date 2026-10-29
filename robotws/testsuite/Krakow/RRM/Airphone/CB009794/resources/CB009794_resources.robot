*** Settings ***
Documentation
...      == COPYRIGHT ==
...          Nokia Networks
...      == AUTHORS ==
...        - Jakub Grela <jakub.grela@nokia.com>
...        - Krzysztof Korczak <krzysztof.korczak@nokia.com>
...        - Maciej Majewski <maciej.majewski@nokia.com>
...        - Michal Obszarny <michal.obszarny@nokia.com>
...        - Tomasz Siuta <tomasz.siuta@nokia.com>
...        - Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
...        - Patryk Wojcik <patryk.wojcik@nokia.com>
...      == MAINTAINER ==
...        - Jakub Grela <jakub.grela@nokia.com>
...        - Krzysztof Korczak <krzysztof.korczak@nokia.com>
...        - Maciej Majewski <maciej.majewski@nokia.com>
...        - Michal Obszarny <michal.obszarny@nokia.com>
...        - Tomasz Siuta <tomasz.siuta@nokia.com>
...        - Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
...        - Patryk Wojcik <patryk.wojcik@nokia.com>

#todo
Library     OperatingSystem
Library     ute_fsmaccess
Library     ute_wtssim
Library     ta5g_egate
Library     ta5g_iphy
Library     ta5g_pm_counters
Library     ta5g_testline_management
Library     ta_emss
Library     ta_messaging
Library     taf.sbts.oam.coam.admin    WITH NAME   coam
Library     CB009794_resources.py
Resource    ../../resources/former_l2_sw1/robot/collectors.robot
Resource    ../../resources/former_l2_sw1/robot/common_keywords.robot
Resource    ../../resources/former_l2_sw1/robot/ssh.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     ../../resources/former_l2_sw1/python/traffic_handling.py
Library     ../../resources/former_l2_sw1/python/common_keywords.py

*** Keywords ***
Activate feature in oran
    Configure  ${CURDIR}/../config/feature_activation.yaml

Setup test environment
    Prepare suite environment  egate_config=${lua_cfg_file}
    Configure  ${CURDIR}/../config/activating_rtwp_counters.yaml

Deactivate srs beam profile${profile} for UE${UE}
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=${UE} testmode=ul_mimo_srs_beam_pos action=deactivate profile_id=${profile}

Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Log to console  Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Configure  {'MOC': '${MOC}', 'ID': '${ID}', '${parameter}': '${value}'}

Collect BIP logs
    [Arguments]  ${alias}  ${duration}
    Sleep  5s  reason=to stabilize measurements
    Start collecting BIP logs    ${alias}
    Stop collecting BIP logs    dir_path=${OUTPUT_DIR}/BIP_LOGS  delay=${duration}  alias=${alias}

Prepare BIP column for PUSCH
    @{BIP_columns_pusch}  Create List
    Append To List  ${BIP_columns_pusch}  3gpp.subcellid
    Append To List  ${BIP_columns_pusch}  3gpp.sfn
    Append To List  ${BIP_columns_pusch}  3gpp.slot
    Append To List  ${BIP_columns_pusch}  3gpp.rnti
    Append To List  ${BIP_columns_pusch}  UlData_puschReceiveReqGrant_t.numOfPrb
    Append To List  ${BIP_columns_pusch}  UlData_puschReceiveReqGrant_t.startPrb
    Append To List  ${BIP_columns_pusch}  UlData_puschReceiveReqGrant_t.fakeUe
    Append To List  ${BIP_columns_pusch}  UlData_puschReceiveReqGrant_t.pairedUe
    Append To List  ${BIP_columns_pusch}  UlData_puschAntMeas_t.linRssiOfAnt
    Append To List  ${BIP_columns_pusch}  UlData_puschAntMeas_t.linNoiseOfAnt
    Set test variable  @{BIP_columns_pusch}

Convert BIP logs
    [Arguments]  ${alias}  ${num_of_ues}=1
    Convert BIP logs pcap to csv
    ...  pcap_path=${OUTPUT_DIR}/BIP_LOGS/${alias}/tcpdump.pcap
    ...  filter=uldata_puschreceiverespps || uldata_puschreceivereq
    ...  dir_path=${OUTPUT_DIR}/BIP_LOGS/${alias}
    ...  columns=@{BIP_columns_pusch}
    ...  csv_log_name=BIP_PUSCH.csv
    fix csv headers  ${OUTPUT_DIR}/BIP_LOGS/${alias}/BIP_PUSCH.csv  ${num_of_ues}
    fix csv values for uldata  ${OUTPUT_DIR}/BIP_LOGS/${alias}/BIP_PUSCH.csv  ${num_of_ues}

Set ${noise_channel} to value ${noise_value} for CELL-${cell_ID}
    Execute egate command  cmd=ul_cell_noise_testmode_nr profile_id=1 ${noise_channel}=${noise_value}
    Sleep  1s
    Execute egate command
    ...    cmd=cell_testmode_set_nr gnb=2 cell_id=${cell_ID} testmode=ul_cell_noise action=activate profile_id=1
    Sleep  1s
    Execute egate command  cmd=ul_cell_noise_testmode_nr profile_id=1

Deactivate ul_cell_noise
    Execute egate command
    ...    cmd=cell_testmode_set_nr gnb=2 cell_id=1 testmode=ul_cell_noise action=deactivate profile_id=1

Get and Update BSR File
    [Arguments]  ${download_path}  ${token}  ${bsr_file_path}=${CURDIR}/../config/BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    Run  sudo wget -d --header='Authorization:Bearer ${token}' ${download_path} -O ${bsr_file_path}
    coam.setup admin
    ${ret}     coam.Update Software      ${bsr_file_path}
    coam.teardown admin

Get Value From Dictionary
    [Arguments]    ${dictionary_name}    ${dict_key}
    ${key_present}=    Run Keyword And Return Status       Dictionary Should Contain Key       ${dictionary_name}      ${dict_key}
    ${pm_value}=           Run Keyword If      ${key_present}     Get From Dictionary             ${dictionary_name}      ${dict_key}
    Return From Keyword         ${pm_value}

Generate High external interference for PUSCH
    [Arguments]    ${CELL_ID}=1
    Set noise_pusch to value -400 for CELL-${CELL_ID}

Clean up external interference and deregister UEs
    Deregister UE  UE_ID=1
    Remove High external interference for PUSCH

Remove High external interference for PUSCH
    Execute egate command  cmd=ul_cell_noise_testmode_nr profile_id=1 delete=on

Collect PM Counters values are correct for High external interference
    Wait for next full pm interval
    ${High_Int_counters}=  get next_unpacked full pm counters file
    [Return]  ${High_Int_counters}

Collect PM Counters values are correct for no external interference
    Wait for next full pm interval
    ${Low_Int_counters}=  get next_unpacked full pm counters file
    [Return]  ${Low_Int_counters}

Clean up external interference and detach NSA UEs
    Detach UE  UE_ID=101
    Remove High external interference for PUSCH

Activate beamforming on specific position for one subcell
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=1 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=2 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=2 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2

Activate beamforming on specific position for two subcells
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 step=5 trigger_puxch_update=0
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=2 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2

Start TTI trace collection
    ${configurations}=  core.Load Configurations     ${CURDIR}/../config/tti_config.yaml
    core.Create Collectors    names=l2stream3    configurations=${configurations['collectors']}
    l2stream3.Set Suite Alias     alias=l2stream3
    core.Setup Collectors    names=l2stream3
    core.Start Collectors    names=l2stream3
    Log to console    ${\n}TTI traces collecting started

Stop TTI trace collection
    Log to console    Stopping TTI traces collecting
    core.Stop Collectors    names=l2stream3
    core.Collect Collectors    names=l2stream3
    core.Teardown Collectors    names=l2stream3

Convert TTI trace from pcap
    [Arguments]  ${format}  ${directory_name}
    Log to console    Converting TTI traces to ${format}
    eventdecoder.Create eventDecoder Converter
    ...  name=ttitrace_converter
    ...  input_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l2stream3/tcpdump/tcpdump.pcap
    ...  output_file_format=${format}
    ...  output_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output
    eventdecoder.Convert
    ...  name=ttitrace_converter
    Remove Directory  ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/    recursive=True
    Move Files	    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output*     ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/
    Move Directory	${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l2stream3/  ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/

Collect TTI Traces during ${duration} seconds and save to directory ${directory_name}
    ${parent_directory}  Set variable  ${directory_name}
    Set Test Variable  ${parent_directory}
    Start TTI trace collection
    Log to console    Collecting duration is ${duration}
    Sleep  ${duration}
    Stop TTI trace collection
    Convert TTI trace from pcap  format=excelCsv  directory_name=${directory_name}

Activate automatic PM Stats
    Run Emssim Command    auto_stats    params=on
