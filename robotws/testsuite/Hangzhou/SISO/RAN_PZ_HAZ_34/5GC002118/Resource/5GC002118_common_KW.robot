*** Settings ***
Documentation     author: shasha liu
...               Group: HGZ_SG5
...               contact: shasha.liu@nokia-sbell.com


Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/siso_resource.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

Library           ../../5GC001278/Library/get_bts_info.py    WITH NAME    lib
#Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
Library           XML   WITH NAME    ParseXML
Library           OperatingSystem
Library           Process
Library           Collections
Library           DateTime
Library           String
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.collectors.snapshot      WITH NAME    snapshot
#Variables        variable/made_variable.py



*** Variables ***
&{fault_10}                 faultId=${10}    source=RMOD_R-1    severity=Critical    # No connection to unit
${alarm_filter_0}           1807
${alarm_filter_1}           No connection to unit
${CPRI_link_status}         /tmp/CPRI_link.log
${VM_CPRI_link}             /tmp/CPRI/
${vm_path}                  /home/ute/
${create_backup_dir}        backupscf/
${bandwidth}              100MHz
${if_commissioning}      False
${testline_name}      null
${CONFIGURATION}      null
@{timezone_list}      (GMT+8) Asia/Shanghai    (GMT-11) Pacific/Apia
@{btslog_dirs}        /opt/btslog     /opt/ute/tools/btslog      none


# RU log
${ru_runtime_zip}     1011_runtime.zip
${ru_runtime_xz}      runtime_DEFAULT.log.xz
${ru_runtime_log}     runtime_DEFAULT.log
${TS_LOG_PATH_BASE}   %{HOME}/workspace/CIT/Master/Case_Logs

#ssh gNB
${asik_addr}          ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}      #toor4nsn
${asik_password}      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}      #oZPS0POrRieRtu

#RU info
${ru_addr}            ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${ru_username}        ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
${ru_password}        ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
${ru_type_init}       ${tl.gnbs[0].dus[0].rus[0].radio_type.value}  # the 1st RU by default if mulitiple RUs used
${ru_pb_model}           ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.__class__.__name__}

*** Keywords ***
Check Given RU Led State
    [Arguments]    ${ru}
    ${RU_state}         selenium_coam.get_led_status_of_an_unit     unit=RMOD-${ru}
    Log to console      RU state: ${RU_state}
    [Return]            ${RU_state}

Check Given ASIK Led State
    [Arguments]    ${asik}
    ${ASIK_state}       selenium_coam.get_led_status_of_an_unit     unit=SMOD-${asik}
    Log to console      ASIK state: ${ASIK_state}
    [Return]            ${ASIK_state}

Check Given ABIL Led State
    [Arguments]    ${abil}
    ${ABIL_state}       selenium_coam.get_led_status_of_an_unit     unit=BBMOD-${abil}
    Log to console      ABIL state: ${ABIL_state}
    [Return]            ${ABIL_state}

Login WebEM Check HW and LED status
    WEBUI Login
    Check ASIK is UP
    Check ABIL is UP
    check RU STATUS
    ${led_RU}     Check Given RU LED State    1
    should be equal   ${led_RU}     Online
    ${led_ASIK}   Check Given ASIK Led State    1
    should be equal   ${led_ASIK}   Online
    ${led_ABIL}   Check Given ABIL Led State    1
    should be equal   ${led_ABIL}   Online
    WEBUI Logout

Check Parameter via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ${current_val}    Get Parameter via webUI     dist_name=${dist_name}
    ...                                           filter_param=${filter_param}
    ...                                           p_name=${p_name}
    should be equal    ${current_val}    ${expected_val}

Get Parameter via webUI
    [Arguments]    ${dist_name}    ${filter_param}    ${p_name}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    ...                                                      timeout=${120}
    [Return]    ${current_val}

Set Parameter value via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    Run Keyword and Ignore Error    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...                              filter_param=${filter_param}
    ...                              new_value=${expected_val}
    ...                              abbr=${p_name}
    ...                              timeout=${120}
    selenium_coam.validate_plan
    ${errors}    Get Validate error
    Run keyword if    ${is_need_to_check_validation_errors}==${True}
    ...    Should be empty    ${errors}
    Run keyword if    ${need_active}==${True}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Return]    ${errors}

#Get Validate error
#    ${defination_errors}    selenium_coam.get_definition_errors    timeout=${120}
#    ${relation_errors}      selenium_coam.get_relation_errors    timeout=${120}
#    ${hardware_errors}      selenium_coam.get_hardware_errors    timeout=${120}
#    ${errors}    Catenate    ${defination_errors}   ${relation_errors}    ${hardware_errors}
#    [Return]    ${errors}

Get Validate error
    ${defination_errors}    selenium_coam.get_definition_errors    timeout=${120}
    ${relation_errors}      selenium_coam.get_relation_errors    timeout=${120}
    ${hardware_errors}      selenium_coam.get_hardware_errors    timeout=${120}
#    ${errors}    Catenate    ${defination_errors}   ${relation_errors}    ${hardware_errors}
    [Return]    ${defination_errors}   ${relation_errors}   ${hardware_errors}


Change Parameter via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    ${errors}    run keyword if  not '${current_val}'=='${expected_val}'
    ...                     Set Parameter value via webUI     expected_val=${expected_val}
    ...                                                       dist_name=${dist_name}
    ...                                                       filter_param=${filter_param}
    ...                                                       p_name=${p_name}
    ...                                                       is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    ...                                                       need_active=${need_active}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    Run keyword if    ${need_active}==${True}
    ...    should be equal    ${current_val}    ${expected_val}
    [Return]    ${current_val}    ${errors}

Check RU Alarm Info
    Wait Until Keyword Succeeds    15min    10s    Check Alarm Info     alarm_filter=${alarm_filter_1}

Check Alarm Info
    [Arguments]    ${alarm_filter}
    log    ${alarm_filter}
    @{alarms}    selenium_coam.get_active_alarm_info    timeout=${100}    #alarm_filter=${alarm_filter}
    sleep    1s
    log     ${alarms}
    ${alarms_string}=    Convert To String    ${alarms}
    Should Contain    ${alarms_string}    No connection to unit
    #should not be empty    ${alarms}

Check RU Disabled
    [Arguments]    ${ru_index}=${1}
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${output_tmp}    selenium_coam.get_ru_info    ru_index=${ru_index}
    ${RU_info}    set variable    ${output_tmp}[Status]
    should match regexp    ${RU_info}[Operational state]    Disabled
    Check RU Alarm Info

Get frm status
    [Arguments]     ${status_holder}     ${oam_connection}
    ${frm_info_dict_list} =    coam.get_frm    timeout=90    connection=${oam_connection}
    ${frm_statuses_dict} =    Get From List     ${frm_info_dict_list}    0
    ${frm_statuses} =    Get From Dictionary    ${frm_statuses_dict}    status
    ${frm_status} =    Get From Dictionary    ${frm_statuses}    ${status_holder}
    [return]    ${frm_status}

Check Cell Be Locked
    [Arguments]  ${cell_idx}=${1}   #${cell_group_idx}=${0}
    ${is_startup_window_exist}=    Run Keyword And Ignore Error   selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${output_tmp}    selenium_coam.get_cell_info    cell_idx=${cell_idx}    #cell_group_idx=${cell_group_idx}
    ${cell_info}    set variable    ${output_tmp}[Status]
    should be equal      ${cell_info}[Administrative state]    Locked
    should be equal      ${cell_info}[Availability status]     Offline
    should be equal      ${cell_info}[Operational state]        Disabled

Check RU Be Locked
    [Arguments]    ${ru_index}=${1}
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${output_tmp}    selenium_coam.get_ru_info    ru_index=${ru_index}
    ${RU_info}    set variable    ${output_tmp}[Status]
    should match regexp    ${RU_info}[Operational state]    Enabled
    should match regexp    ${RU_info}[Availability status]    Online
    should match regexp    ${RU_info}[Administrative state]    Locked
    should match regexp    ${RU_info}[Procedural status]    configured

Test Precondition
    log to console    Precondition
    Login WebEM Check HW and LED status
    Run Keyword And Ignore Error    run process    taskkill /f /im firefoxdriver.exe    shell=True
    Run Keyword And Ignore Error    run process    ps -ef|grep firefox | awk '{print $2}' |xargs kill -9    shell=True
    csn.Connect to    ${host_addr}    ${host_username}    ${host_password}    alias=VM
    sleep    2s
    csn.execute    killall -9 /opt/firefox/firefox    connection=VM
    sleep    2s
    csn.disconnect    connection=VM

Get Gnb BTS ID
    coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...               bts_port=${443}  name=coam
    &{bts_info}   coam.get_bts_info   connection=coam   timeout=10
    ${mrbts_id}    set variable     ${bts_info['mrbtsID']}
    ${nrbts_id}    set variable     ${bts_info['nrBtsId']}
    coam.teardown          connection=coam
    [Return]    ${mrbts_id}    ${nrbts_id}


#### [Start] step level kw ####
##General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
"${Step}" login webui and check RU status
    log to console           \n"${Step}": login webui and check RU status
    WEBUI Login
    check RU STATUS

"${Step}" verify content of TargetBD file
    log to console           \n"${Step}": verify content of TargetBD file
    ${TargetBD_FileName}   ${save_path}    check TargetBD exist and match
    ${regist_info}=          check RU registration info    ${TargetBD_FileName}

"${Step}" verify content of BPF file
    log to console           \n"${Step}": verify content of BPF file
    ${bpf_gzfileName}=         get bpf gz fileName
    ${bpf_content}    ${bpf_file}     get BPF file content    ${bpf_gzfileName}
    verify BPF params        ${bpf_content}

##General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
"${Step}" Login WebEM and check gNB onair
    log to console           \n"${Step}": Login WebEM and check gNB onair
    Wait Until Keyword Succeeds    2min    30s    WEBUI Login
    ${mrbts_id}  ${nrbts_id}    Get Gnb BTS ID
    set suite variable    ${mrbts_id}
    set suite variable    ${nrbts_id}
    check gNB Staus onAir    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}    search_text=Operational state

"${Step}" Backup SCF with current config
    log to console           \n"${Step}": Backup SCF with current config
    ${scfFile}=    backup commission file via WebUI    ${SAVE LOG DIRECTORY}
    set test variable    ${scfFile}

"${Step}" Modify pMax to tirgger fault
    log to console           \n"${Step}": Modify pMax to tirgger fault
#   get original pMax
    ${pMax_origin_dBm}   selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1    filter_param=Maximum output power   timeout=30
    ${pattern}   Set Variable    (\\d*\.?\\d).*
    ${orig_value_list}    Get Regexp Matches     ${pMax_origin_dBm}    ${pattern}    1
    ${orig_value}    set variable     ${orig_value_list}[0]
   set test variable    ${pMax_origin}    ${orig_value}
#   get norminal pMax
    ${bpf_gzfileName}=         get bpf gz fileName
    ${bpf_content}   ${bpf_file}   get BPF file content    ${bpf_gzfileName}
    ${xml handler}=    ParseXML.Parse Xml    ${bpf_content}
    ${MaxPapower_list}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power"]/p
    Collections.Sort List    ${MaxPapower_list}
    set test variable    ${MaxPower}    ${MaxPapower_list}[-1]
    ${MaxPapower_list_5G}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power.5G"]/p
    Collections.Sort List    ${MaxPapower_list_5G}
    ${Len}=    Get Length    ${MaxPapower_list_5G}
    ${MaxPower}    Set Variable If    '${len}'!='0'    ${MaxPapower_list_5G}[-1]    ${MaxPower}
    #PowerAllocated <= 10*log10(PowerRated*1000)+DLPowerAccuracy; DLPowerAccuracy is set 0.1dB #PR509046
    ${MaxPower} =    Evaluate    ${MaxPower} + 0.1
    set test variable    ${MinPower}    ${MaxPapower_list}[0]
    ${pMax_modify_f} =    Evaluate    ${MaxPower} + 0.1
    ${pMax_modify}    convert to string    ${pMax_modify_f}
    set test variable    ${pMax_modify}
    wait until keyword succeeds    1min    20s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1    filter_param=Maximum output power
    ...    new_value=${pMax_modify}    abbr=pMax
    Validate and activate and check activate plan status

#"${step}" Check Fault 1900 via WebEM
#    log to console           \n"${Step}": Check Fault 1900 via WebEM
#    wait until keyword succeeds    8min    1min    WEBUI Login
#    Run Keyword and Ignore Error    selenium_coam.refresh_page
#    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
#    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
#    ${BTS_Name}    wait until keyword succeeds    2min    30s
#    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}    filter_param=BTS name
#    set test variable     ${BTS_Name}
#    wait until keyword succeeds     20min    1min    Check active fault on WebUI
#    ...    alarm_filter=RF Module configuring failed
#    ...    Severity_expect=critical
#    ...    AlarmID_expect=7116
#    ...    AlarmName_expect=BASE STATION SERVICE PROBLEM
#    ...    FaultID_expect=1900
#    ...    FaultName_expect=RF Module configuring failed
#    ...    AlarmOB_expect=[${BTS_Name}] MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1

"${step}" Check Fault 1900 via WebEM
    log to console           \n"${Step}": Check Fault 1900 or Fault 4008 via WebEM
    wait until keyword succeeds    8min    1min    WEBUI Login
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${BTS_Name}    wait until keyword succeeds    2min    30s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}    filter_param=BTS name
    set test variable     ${BTS_Name}
    ${Cell_Name}    wait until keyword succeeds    2min    30s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1    filter_param=Cell name
    set test variable     ${Cell_Name}
    ${status_1900}   Run Keyword And Return Status    wait until keyword succeeds     15min    1min    Check active fault on WebUI
    ...    alarm_filter=RF Module configuring failed
    ...    Severity_expect=critical
    ...    AlarmID_expect=7116
    ...    AlarmName_expect=BASE STATION SERVICE PROBLEM
    ...    FaultID_expect=1900
    ...    FaultName_expect=RF Module configuring failed
    ...    AlarmOB_expect=[${BTS_Name}] MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
    ${status_4008}   Run Keyword And Return Status    wait until keyword succeeds     2min    30s    Check active fault on WebUI
    ...    alarm_filter=Power level not supported
    ...    Severity_expect=critical
    ...    AlarmID_expect=7112
    ...    AlarmName_expect=BASE STATION CONFIGURATION PROBLEM
    ...    FaultID_expect=4008
    ...    FaultName_expect=Power level not supported
    ...    AlarmOB_expect=[${BTS_Name}][${Cell_Name}] MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    should be true   '${status_1900}'=='True' or '${status_4008}'=='True'

"${Step}" Modify pMax to Min Power
    log to console           \n"${Step}" Modify pMax to Min Power: ${MinPower} - started
    wait until keyword succeeds    1min    20s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1    filter_param=Maximum output power
    ...    new_value=${MinPower}    abbr=pMax
    Validate and activate and check activate plan status
    Wait Until Keyword Succeeds    8min    1min    WEBUI Login
    ${flag}    Run Keyword And Return Status    wait until keyword succeeds    10min    1min
    ...    "StepX" Login WebEM and check gNB onair
    run keyword if     '${flag}'=='False'    reload scf
    #start l3call and check Tput
    log to console           \n"${Step}" Modify pMax to Min Power: ${MinPower} - completed

"${Step}" Modify pMax to Max Power
    log to console           \n"${Step}" Modify pMax to Max Power: ${MaxPower} - started
    wait until keyword succeeds    1min    20s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1    filter_param=Maximum output power
    ...    new_value=${MaxPower}    abbr=pMax
    Validate and activate and check activate plan status
    Wait Until Keyword Succeeds    8min    1min    WEBUI Login
    ${flag}    Run Keyword And Return Status    wait until keyword succeeds    10min    1min
    ...    "StepX" Login WebEM and check gNB onair
    run keyword if     '${flag}'=='False'    reload scf
    #start l3call and check Tput
    log to console           \n"${Step}" Modify pMax to Max Power: ${MaxPower} - completed

##General_SiSo_RF_module_addition_in_BIM_and_WebUI
"${step}" Check HW modules detection
    log to console           \n"${Step}": Check HW modules detection
    Wait Until Keyword Succeeds    10min    1min    WEBUI Login
    wait until keyword succeeds    10min    30s    Check ASIK is UP
    wait until keyword succeeds    10min    30s    Check ABIL is UP
    wait until keyword succeeds    10min    30s    Check Cell is UP
    wait until keyword succeeds    5min     30s     Check RU STATUS

"${step}" Check RF config from webui
    log to console           \n"${Step}": Check RF config from webui
    #get RF SW from TargetBD
    log to console    \nget RF SW from TargetBD
    ${ruSW_expect}=    get RFSW version from TargetBD
    #get RF SW from RF module
    log to console    \nget RF SW from RF module
    ${ruSW_fromModule}=    get RFSW version from radio module
    #get RF configuration from webui
    log to console    \nget RF configuration from webui
    ${output_ru}      selenium_coam.get_ru_info
    ${output_cell}    selenium_coam.get_cell_info
    &{rmodInfo_webui}    selenium_coam.get_hw_parameters     hw_type=RMOD    ###index=1
    ${pCode_webui}     set variable      ${output_ru}[Product code]    # 474877A.X21
    ${pName_webui}     set variable      ${output_ru}[Product name]    # AWHQG
    ${serNum_webui}    set variable      ${output_ru}[Serial number]   # EB193764266
    ${hwVer_webui}     set variable      ${output_ru}[HW version]      # X21
    ${nrBand_webui}    set variable      ${output_cell}[Band]          # n78
    ${runtimeParam_ru}     set variable    ${rmodInfo_webui}[Runtime parameters]
    ${ruSW_webui}          set variable    ${runtimeParam_ru}[RU active SW version]    # MRM69.11.R03
    #get RF configuration from M-Plane (OAM)
    log to console    \nget RF configuration from M-Plane (OAM)
    coam.connect_to    bts_host=${asik_addr}    name=GNB_OAM
    &{hw_info}       coam.get_detected_hw_info    connection=GNB_OAM
    ${pCode_oam}    set variable    ${hw_info.radioModules.rmod[0].productCode}    # 474877A.X21
    ${pName_oam}    set variable    ${hw_info.radioModules.rmod[0].productName}    # AWHQG
    ${serNum_oam}   set variable    ${hw_info.radioModules.rmod[0].serialNumber}   # EB193764266
    @{tmp}          split string    ${pCode_oam}    separator=.
    ${hwVer_oam}    set variable    ${tmp}[-1]       # X21
    coam.teardown    connection=GNB_OAM
    #get RF configuration from spec
    log to console    \nget RF configuration from spec
    define BPF params value from spec
    @{prodCode_tmp}    Get Regexp matches    ${ProductCode_expect}    <p Name="Visible.Product.Code">(.*)</p>   1
    set test variable    ${prodCode_expect}    ${prodCode_tmp}[0]
    @{unitType_tmp}    Get Regexp matches    ${unitType_expect}    <unitType>(.*)</unitType>   1
    set test variable    ${unitType_expect}    ${unitType_tmp}[0]
    @{variant_tmp}    Get Regexp matches    ${variant_expect}    <variant>(.*)</variant>   1
    set test variable    ${variant_expect}    ${variant_tmp}[0]
    ${pName_expect}    Catenate   SEPARATOR=   ${unitType_expect}    ${variant_expect}
    @{NRFreqBand_tmp}    Get Regexp matches    ${NRFreqBand_expect}   <list Name="NR.Frequency.Band"><p>(.*)</p><p>(.*)</p></list>  1
    set test variable    ${NRFreqBand_expect}    ${NRFreqBand_tmp}[0]
    ${NRFreqBand_expect}    Catenate   SEPARATOR=   n   ${NRFreqBand_expect}
    #compare RF configuration
    log to console    \ncompare RF configuration
    should be true    '${ruSW_fromModule}'=='${ruSW_webui}' and '${ruSW_webui}'=='${ruSW_expect}'
    should be true    '${serNum_webui}'=='${serNum_oam}'
    should be true    '${hwVer_webui}'=='${hwVer_oam}'
    should be true    '${pCode_webui}'=='${pCode_oam}' and '${pCode_oam}'=='${prodCode_expect}.${hwVer_webui}'
    should be true    '${pName_webui}'=='${pName_oam}' and '${pName_oam}'=='${pName_expect}'
    should be true    '${nrBand_webui}'=='${NRFreqBand_expect}'

##General_SiSo_CPRI_link_configuration
"${step}" Site reset from webui
    log to console           \n"${Step}": Site reset from webui
    Wait Until Keyword Succeeds    1min    30s   selenium_coam.reset_site
    sleep   2min

"${step}" Verify CPRI link status
    log to console           \n"${Step}": Verify CPRI link status
    Wait Until Keyword Succeeds    6min    30s    check ping is enabled    Unit_ip=${asik_addr}
    Wait Until Keyword Succeeds    5min    30s    WEBUI Login
    Wait Until Keyword Succeeds    15min    30s    Check ASIK is UP
    Wait Until Keyword Succeeds    15min    30s    Check ABIL is UP
    Wait Until Keyword Succeeds    5min    30s    check RU STATUS
    ${output_links}=    Get cpri Link State from BTSOM
    verify cpri link state from BTSOM    output_links=${output_links}

"${Step}" Verify CPRI link status via loner register
    log to console           \n"${Step}": Verify CPRI link status via loner register
    Wait Until Keyword Succeeds    6min    30s    check ping is enabled    Unit_ip=${asik_addr}
    Wait Until Keyword Succeeds    5min    30s    WEBUI Login
    Wait Until Keyword Succeeds    15min    30s    Check ASIK is UP
    Wait Until Keyword Succeeds    15min    30s    Check ABIL is UP
    Wait Until Keyword Succeeds    2min    30s    check RU STATUS
    Verify CPRI link status via loner register    cpri_state_register=0xdf261004 32
    Verify CPRI link status via loner register    cpri_state_register=0xdf271004 32

"${step}" check status after site reset
    log to console           \n"${Step}": check status after site reset
    BuiltIn.Log    Start checking bts reset result.
    Wait Until Keyword Succeeds    6min    30s    check ping is enabled    Unit_ip=${asik_addr}
    Wait Until Keyword Succeeds    5min    30s    WEBUI Login
    Wait Until Keyword Succeeds    15min    30s    Check ASIK is UP
    Wait Until Keyword Succeeds    15min    30s    Check ABIL is UP
    Wait Until Keyword Succeeds    5min    30s    check RU STATUS
    Wait Until Keyword Succeeds    5min    30s    Check Cell is UP
    BuiltIn.Log    BTS reset check finished, reset successfully.

##General_SiSo_RF_module_IP_adress_allocation
"${step}" check ru ip allocation
    log to console           \n"${Step}": check ru ip allocation
    Wait Until Keyword Succeeds    20min    1min    check ru ip allocation
    run keyword and ignore error   should be equal as strings    ${ru_ip}   ${ru_addr}
    ...    msg=Waring: please double check your ru addr in init.py

"${step}" verify RF module accessible
    log to console           \n"${Step}": verify RF module accessible
    #Wait Until Keyword Succeeds    5min    30s    check ru ping is enabled    Unit_ip=${ru_ip}
    Connect to gnb coam via ssl
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=asik
    Wait Until Keyword Succeeds    5min    30s    Check RU Connection    ru_alias=ru    asik_alias=asik
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    run keyword and ignore error    csn.disconnect    connection=ru
    run keyword and ignore error    csn.disconnect    connection=asik
    Wait Until Keyword Succeeds    5min    30s    WEBUI Login
    Wait Until Keyword Succeeds    15min   1min   check RU STATUS
    ${ruSW_fromModule}    get RFSW version from radio module    ru_ip=${ru_ip}

##General_SiSo_Cell_lock_and_unlock_under_creation
#"${step}" Lock Cell
#    log to console        \n"${step}": Lock Cell
#    Perform Cell Lock      cell_idx=${1}     download_dir=${SAVE LOG DIRECTORY}
#    WEBUI Login
#    Wait Until Keyword Succeeds    5min    30s    Check Cell Be Locked     cell_idx=${1}
#    WEBUI Logout

"${step}" Lock Cell
    log to console        \n"${step}": Lock Cell
    Perform Cell Lock      cell_idx=${1}     download_dir=${SAVE LOG DIRECTORY}
    WEBUI Login
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Wait Until Keyword Succeeds    5min    30s    Check Cell Be Locked     cell_idx=${1}
    WEBUI Logout

"${step}" Unlock Cell
    log to console        \n"${step}": Unlock Cell
    #Run Keyword And Ignore Error       selenium_coam.logout
    WEBUI Login
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    WEBUI Logout
    Perform Cell Unlock    cell_idx=${1}     download_dir=${SAVE LOG DIRECTORY}
    WEBUI Login
    Wait Until Keyword Succeeds    15min    1min    Check RU STATUS
    Wait Until Keyword Succeeds    10min    10s     Check Cell is UP

##  General_SiSo_RU_block_unblock_under_creation
#"${step}" Lock RU
#    log to console        \n"${step}": Lock RU
#    Perform RU Lock    ru_index=${1}   download_dir=${SAVE LOG DIRECTORY}
#    WEBUI Login
#    Wait Until Keyword Succeeds    5min    10s    Check RU Be Locked
#    WEBUI Logout
#    sleep    10s

"${step}" Lock RU
    log to console        \n"${step}": Lock RU
    Wait Until Keyword Succeeds    5min    10s    lock RU via webui
    run keyword and ignore error   WEBUI Login
    Wait Until Keyword Succeeds    15min    10s    check RU STATUS    expected_status=Locked

#"${step}" Unlock RU
#    log to console        \n"${step}": Unlock RU
#    Run Keyword And Ignore Error       selenium_coam.logout
#    Perform RU Unlock    ru_index=${1}    download_dir=${SAVE LOG DIRECTORY}
#    WEBUI Login
#    Wait Until Keyword Succeeds    15min   1min    check RU STATUS
#    Wait Until Keyword Succeeds    5min    30s    Check Cell is UP

"${step}" Unlock RU
    log to console        \n"${step}": Unlock RU
    Wait Until Keyword Succeeds    5min    10s    unlock RU via webui
    run keyword and ignore error   WEBUI Login
    Wait Until Keyword Succeeds    15min   1min    check RU STATUS    expected_status=Unlocked
    Wait Until Keyword Succeeds    10min    10s    Check Cell is UP

##General_SiSo_BTS_startup_with_RF_delayed_startup
"${step}" Perform RU Power Off
    log to console    \n"${step}": Perform RU Power Off
    Perform RU Power Off    ru_index=${1}    model=${ru_pb_model}
    WEBUI Login
    Check RU Disabled

"${step}" Perform RU Power On
    log to console    \n"${step}": Perform RU Power On
    sleep    10s
    Perform RU Power On    ru_index=${1}    model=${ru_pb_model}
    Wait Until Keyword Succeeds    15min    1min    check RU STATUS
    Wait Until Keyword Succeeds    5min    30s    Check Cell is UP

"${step}" Perform RAC and RAU Power Off
    log to console    \n"${step}": Perform RAC and RAU Power Off
    Perform Site Power Off
    Perform RU Power Off    ru_index=${1}
    sleep    15s

"${step}" Perform RAC and RU Power On
    log to console    \n"${step}": Perform RAC and RU Power On
    Perform Site Power On
    #sleep    2min
    Wait Until Keyword Succeeds    5min     30s     WEBUI Login
    Check RU Disabled
    Wait Until Keyword Succeeds    15min    1min    Check ASIK is UP
    Wait Until Keyword Succeeds    15min    1min    Check ABIL is UP

"${step}" Check RF Delayed Startup
    log to console    \n"${step}": Check RF Delayed Startup
    Perform RU Power On    ru_index=${1}
    Wait Until Keyword Succeeds    15min    1min    check RU STATUS
    Wait Until Keyword Succeeds    5min     30s     Check Cell is UP

"${step}" Check Bts and RU Status Recovery
    log to console    \n"${step}": Check Bts and RU Status Recovery
    sleep    60s
    Wait Until Keyword Succeeds    5min     10s     admin_login
    ${frm_status_value}    Get frm status     status_holder=operationalState    oam_connection=admin_GNB_OAM
    admin_logout
    should match regexp    ${frm_status_value}    Disabled
    Wait Until Keyword Succeeds    5min    10s    Check ASIK is UP
    Wait Until Keyword Succeeds    5min    10s    Check ABIL is UP
    Wait Until Keyword Succeeds    5min    10s    check RU STATUS
    Wait Until Keyword Succeeds    5min    10s    Check Cell is UP

##General_SiSo_NR-ARFCN_check
"${step}" get necessary param values and bkp scf
    log to console    \n"${step}" get necessary param values and backup scf

    ${nrarfcn_orig}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number
    set test variable    ${nrarfcn_orig}
    log to console    \nnrarfcn_orig: ${nrarfcn_orig}
    ${gscn_orig}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Global synchronization channel number
    set test variable    ${gscn_orig}
    log to console    \ngscn_orig: ${gscn_orig}
    ${ssbScs_orig}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=SS Block Subcarrier Spacing
    set test variable    ${ssbScs_orig}
    log to console    \nssbScs_orig: ${ssbScs_orig}
    ${scs_orig}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELLGRP-0
    ...    filter_param=SCS
    set test variable    ${scs_orig}
    log to console    \nscs_orig: ${scs_orig}
    ${opt_cell}    selenium_coam.get_cell_info
    set test variable     ${nrBand_orig}    ${opt_cell}[Band]          # n78
    ${chBw}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Channel bandwidth

    @{chBw}    Get Regexp matches    ${chBw}   (.*)MHz    1
    set test variable    ${chBw}    ${chBw}[0]
    ${chBw}=    convert to integer    ${chBw}
    log to console    \nchBw: ${chBw} MHz

    define nrarfcn range from 3GPP FR1    operateBand=${nrBand_orig}      scs_param=${scs_orig}
    define GSCN range from 3GPP FR1       NRoperateBand=${nrBand_orig}    ssbSCS_param=${ssbScs_orig}

    #In case of 'mod(nrarfcn,2)!=0', e.g. nrarfcn = 6340003,
    #convert to 634004   #suppose current nrarfcn is not nearest to boundary
    ${nrarfcn_orig_tmp}=    Evaluate    ${nrarfcn_orig}/${NrarfcnStep_3gpp}    # 6340003/2= 317001
    ${mod_orig}=    Evaluate        ${nrarfcn_orig}-${nrarfcn_orig_tmp}*${NrarfcnStep_3gpp}  #1
    ${mod_orig_zero}    set variable      ${nrarfcn_orig}
    ${mod_orig_nonzero}=    Evaluate      ${nrarfcn_orig}+(${NrarfcnStep_3gpp}-${mod_orig})  #634004
    run keyword if    '${mod_orig}' == '0'
    ...    set test variable    ${nrarfcn_orig}    ${mod_orig_zero}
    ...    ELSE    set test variable    ${nrarfcn_orig}    ${mod_orig_nonzero}

    #In case of 'original gscn' is not align with 'original nrarfcn'
    ${gscn_calculate}     get gscn align with nrarfcn from 3gpp FR1   ${nrarfcn_orig}
    run keyword if    '${gscn_orig}' != '${gscn_calculate}'    run keywords
    ...     log to console    \nWarning: the gscn: ${gscn_orig} is not align with nrarfcn: ${nrarfcn_orig}   AND
    ...     set test variable     ${gscn_orig}    ${gscn_calculate}

    ${scfFile}=    backup commission file via WebUI    scfSaved_dir=${SAVE LOG DIRECTORY}
    set test variable    ${scfFile}

"${step}" verify nrarfcn out of TX/RX range
    log to console    \n"${step}" verify nrarfcn out of TX/RX range

    ######## out of min NRARFCN #########
    log to console   \n"${step}"-1 out of min NRARFCN: ${minNrarfcn_1807}
    should be true    ${minNrarfcn_3gpp}<=${minNrarfcn_1807}<=${maxNrarfcn_3gpp}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${minNrarfcn_1807}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Global synchronization channel number    new_value=${minNrarfcn_1807_gscn}
    Validate and activate and check activate plan status
    sleep   60s
    #Check fault 1807 on WebUI
    log to console    \nCheck fault 1807 on WebUI
    wait until keyword succeeds    8min    1min    WEBUI Login
    ${BTS_Name}    wait until keyword succeeds    2min    30s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}    filter_param=BTS name
    set test variable     ${BTS_Name}
    wait until keyword succeeds     20min    1min    Check active fault on WebUI
    ...    alarm_filter=Invalid frequency channel for the BTS HW
    ...    Severity_expect=critical
    ...    AlarmID_expect=7112
    ...    AlarmName_expect=BASE STATION CONFIGURATION PROBLEM
    ...    FaultID_expect=1807
    ...    FaultName_expect=Invalid frequency channel for the BTS HW
    ...    AlarmOB_expect=[${BTS_Name}] MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    #check cell status - should be faulty
    log to console    \ncheck cell should be faulty
    ${result_cell}    selenium_coam.get_cell_info
    set test variable     ${cellState_list}       ${result_cell}[Status]
    set test variable     ${operational_state}    ${cellState_list}[Operational state]
    set test variable     ${availability_status}    ${cellState_list}[Availability status]
    should be equal as strings     ${operational_state}      Disabled
    should be equal as strings     ${availability_status}    Failed

    #recover with min NRARFCN considering chBw
    log to console    \nrecover with min NRARFCN considering chBw
    get nrarfcn recovery TX/RX frequency range
#    ${minNrarfcn_recover}=    Evaluate     ${minNrarfcn_1807}+${NrarfcnStep_3gpp}
    ${minNrarfcn_recover}=    Evaluate     ${minNrarfcn_pbf_chBw}+${NrarfcnStep_3gpp}
    ${minNrarfcn_recover_gscn}     get gscn align with nrarfcn from 3gpp FR1   ${minNrarfcn_recover}
    set test variable    ${minNrarfcn_recover}
    set test variable    ${minNrarfcn_recover_gscn}
    log to console    \nrecover with min NRARFCN: ${minNrarfcn_recover} and gscn: ${minNrarfcn_recover_gscn}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${minNrarfcn_recover}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Global synchronization channel number    new_value=${minNrarfcn_recover_gscn}
    Validate and activate and check activate plan status
    sleep    60s
    #check fault 1807 on webui - should not visible
    log to console    \ncheck fault 1807 should not visible
    wait until keyword succeeds    8min    1min    WEBUI Login
    @{alarm_info}=    wait until keyword succeeds    30min    1min    selenium_coam.get_active_alarm_info
    ...    alarm_filter=Invalid frequency channel for the BTS HW    timeout=60
    should be empty    ${alarm_info}
    #check cell status - should be onair
    log to console    \ncheck cell should be onair
    wait until keyword succeeds     20min    30s    Check Cell is UP

    ########## out of max NRARFCN ##########
    log to console   \n"${step}"-2 out of max NRARFCN: ${maxNrarfcn_1807}
    #should be true    ${minNrarfcn_3gpp}<=${maxNrarfcn_1807}<=${maxNrarfcn_3gpp}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${maxNrarfcn_1807}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Global synchronization channel number    new_value=${maxNrarfcn_1807_gscn}
    Validate and activate and check activate plan status
    sleep   60s
    #Check fault 1807 on WebUI
    log to console    \nCheck fault 1807 on WebUI
    wait until keyword succeeds    8min    1min    WEBUI Login
    ${BTS_Name}    wait until keyword succeeds    2min    30s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}    filter_param=BTS name
    set test variable     ${BTS_Name}
    wait until keyword succeeds     20min    1min    Check active fault on WebUI
    ...    alarm_filter=Invalid frequency channel for the BTS HW
    ...    Severity_expect=critical
    ...    AlarmID_expect=7112
    ...    AlarmName_expect=BASE STATION CONFIGURATION PROBLEM
    ...    FaultID_expect=1807
    ...    FaultName_expect=Invalid frequency channel for the BTS HW
    ...    AlarmOB_expect=[${BTS_Name}] MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    #check cell status - should be faulty
    log to console    \ncheck cell should be faulty
    ${result_cell}    selenium_coam.get_cell_info
    set test variable     ${cellState_list}       ${result_cell}[Status]
    set test variable     ${operational_state}    ${cellState_list}[Operational state]
    set test variable     ${availability_status}    ${cellState_list}[Availability status]
    should be equal as strings     ${operational_state}      Disabled
    should be equal as strings     ${availability_status}    Failed

    #recover with max NRARFCN considering chBw
    log to console    \nrecover with max NRARFCN considering chBw
#    ${maxNrarfcn_recover}=    Evaluate     ${maxNrarfcn_1807}-${NrarfcnStep_3gpp}
    ${maxNrarfcn_recover}=    Evaluate     ${maxNrarfcn_pbf_chBw}-${NrarfcnStep_3gpp}
    ${maxNrarfcn_recover_gscn}     get gscn align with nrarfcn from 3gpp FR1   ${maxNrarfcn_recover}
    set test variable    ${maxNrarfcn_recover}
    set test variable    ${maxNrarfcn_recover_gscn}
    log to console     \nrecover with max NRARFCN: ${maxNrarfcn_recover} and gscn: ${maxNrarfcn_recover_gscn}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${maxNrarfcn_recover}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Global synchronization channel number    new_value=${maxNrarfcn_recover_gscn}
    Validate and activate and check activate plan status
    sleep    60s
    #check fault 1807 on webui - should not visible
    log to console    \ncheck fault 1807 should not visible
    wait until keyword succeeds    8min    1min    WEBUI Login
    @{alarm_info_tmp}=    wait until keyword succeeds    30min    1min    selenium_coam.get_active_alarm_info
    ...    alarm_filter=Invalid frequency channel for the BTS HW    timeout=60
    should be empty    ${alarm_info_tmp}
    #check cell status - should be onair
    log to console    \ncheck cell should be onair
    wait until keyword succeeds     15min    30s    Check Cell is UP

"${step}" verify nrarfcn out of band boundary
    log to console    \n"${step}" verify nrarfcn out of band boundary
    # maxNrarfcn_validateErr
    log to console    \n"${step}"-1 maxNrarfcn_validateErr: ${maxNrarfcn_validateErr}
    should be true    ${minNrarfcn_General}<=${maxNrarfcn_validateErr}<=${maxNrarfcn_General}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${maxNrarfcn_validateErr}
    ${status}    ${paramErrInfo}    run keyword and ignore error    selenium_coam.get_error_info_after_set_parameter
    run keyword and ignore error    should be true    '${status}' == 'FAIL'
    run keyword and continue on failure    selenium_coam.validate_plan
    ${relErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${relErrs_str}    convert to string    ${relErrs_dic}
    @{nrarfcnRang_list}    Get Regexp matches    ${relErrs_str}    \\d+
    List Should Contain Value    ${nrarfcnRang_list}    ${maxNrarfcn_3gpp}
    # recover to origial Actual value
    log to console    \nrecover nrarfcn to origial Actual value:${nrarfcn_orig} and gscn: ${gscn_orig}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${nrarfcn_orig}
    ${status}    ${paramErrInfo}    run keyword and ignore error    selenium_coam.get_error_info_after_set_parameter
    run keyword and ignore error    should be true    '${status}' == 'FAIL'
    run keyword and continue on failure    selenium_coam.validate_plan
    ${relErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${relErrs_str}    convert to string    ${relErrs_dic}
    @{nrarfcnRang_list}    Get Regexp matches    ${relErrs_str}    \\d+
    List Should Not Contain Value    ${nrarfcnRang_list}    ${maxNrarfcn_3gpp}

    # minNrarfcn_validateErr
    log to console    \n\n"${step}"-2 minNrarfcn_validateErr: ${minNrarfcn_validateErr}
    should be true    ${minNrarfcn_General}<=${minNrarfcn_validateErr}<=${maxNrarfcn_General}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${minNrarfcn_validateErr}
    ${status}    ${paramErrInfo}    run keyword and ignore error    selenium_coam.get_error_info_after_set_parameter
    run keyword and ignore error    should be true    '${status}' == 'FAIL'
    run keyword and continue on failure    selenium_coam.validate_plan
    ${relErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${relErrs_str}    convert to string    ${relErrs_dic}
    @{nrarfcnRang_list}    Get Regexp matches    ${relErrs_str}    \\d+
    List Should Contain Value    ${nrarfcnRang_list}    ${minNrarfcn_3gpp}
    # recover to origial Actual value
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${nrarfcn_orig}
    ${status}    ${paramErrInfo}    run keyword and ignore error    selenium_coam.get_error_info_after_set_parameter
    run keyword and ignore error    should be true    '${status}' == 'FAIL'
    run keyword and continue on failure    selenium_coam.validate_plan
    ${relErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${relErrs_str}    convert to string    ${relErrs_dic}
    @{nrarfcnRang_list}    Get Regexp matches    ${relErrs_str}    \\d+
    List Should Not Contain Value    ${nrarfcnRang_list}    ${minNrarfcn_3gpp}

"${step}" get nrarfcn boudary values and GSCN
    log to console    \n"${step}" get nrarfcn boudary values and GSCN
    get nrarfcn general range from OAM webui
    get nrarfcn range from TX/RX frequency
    get nrarfcn out of band boundary from 3gpp
    get nrarfcn out of TX/RX frequency range
    ${maxNrarfcn_pbf_gscn}     get gscn align with nrarfcn from 3gpp FR1   ${maxNrarfcn_pbf}
    ${minNrarfcn_pbf_gscn}     get gscn align with nrarfcn from 3gpp FR1   ${minNrarfcn_pbf}
    ${maxNrarfcn_1807_gscn}    get gscn align with nrarfcn from 3gpp FR1   ${maxNrarfcn_1807}
    ${minNrarfcn_1807_gscn}    get gscn align with nrarfcn from 3gpp FR1   ${minNrarfcn_1807}
    set test variable    ${maxNrarfcn_pbf_gscn}
    set test variable    ${minNrarfcn_pbf_gscn}
    set test variable    ${maxNrarfcn_1807_gscn}
    set test variable    ${minNrarfcn_1807_gscn}

#General_SiSo_Commissioning_BTS_Template_Commissioning
"${Step}" gNB configuration reset
    log to console    \n"${Step}" gNB configuration reset
    ${Status}    selenium_coam.configuration_reset
    run keyword if   '${Status}' != 'Execution succeeded'   gNB uncommission via scf deletion
    sleep   20s

"${Step}" gNB commission with loading scf via LMP
    log to console    \n"${Step}" gNB commission with loading scf via LMP port
    gNB commission with loading scf via LMP

"${Step}" verify parameter modification
    log to console    \n"${Step}" verify parameter modification
    ${mrbts_id}  ${nrbts_id}    Get Gnb BTS ID
    set suite variable    ${mrbts_id}
    set suite variable    ${nrbts_id}
    #Modification type - online
    log to console    \nModification type - online : "BTS name"
    wait until keyword succeeds     2min    30s   siso_resource.WEBUI Login
    ${btsNameDetails}    selenium_coam.get_parameter_details   dist_name=MRBTS-${mrbts_id}    filter_param=BTS name
    set test variable    ${btsNameActu}    ${btsNameDetails}[Actual value]
    set test variable    ${btsNameModifyType}    ${btsNameDetails}[Modification type]
    should be equal      ${btsNameModifyType}    Online
    ${START_TIME}=    Get time    exclude_millis=yes
    set test variable    ${START_TIME}
    ${timestamp}=    Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    set test variable    ${btsNameModify}    ${btsNameActu}_${timestamp}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}    filter_param=BTS name    new_value=${btsNameModify}
    sleep    3s
    Validate and activate and check activate plan status
    sleep    3s
    ${output}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}    filter_param=BTS name   timeout=10
    should be equal      ${output}    ${btsNameModify}
    #Modification type - Definition Errors
    log to console    \nModification type - Definition Errors : NRARFCN=-1
    wait until keyword succeeds     2min    30s   siso_resource.WEBUI Login
    ${fcnDetails}    selenium_coam.get_parameter_details   dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number
    set test variable    ${fcnActu}    ${fcnDetails}[Actual value]
    set test variable    ${fcnModifyType}    ${fcnDetails}[Modification type]
    should be equal    ${fcnModifyType}    Conditional BTS restart
    set test variable    ${fcnRang}    ${fcnDetails}[Range]
    @{result_tmp}    string.split string    ${fcnRang}    separator=...
    set test variable    ${minNrarfcn}    ${result_tmp}[0]   #0
    set test variable    ${maxNrarfcn}    ${result_tmp}[-1]  #3279165
    ${minNrarfcn_modify}=    Evaluate    ${minNrarfcn}-1     #-1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${minNrarfcn_modify}
    ${paramErrInfo}    selenium_coam.get_error_info_after_set_parameter
    Should be equal as strings    ${paramErrInfo}    Given value is too small. The minimum value of the parameter is${minNrarfcn}.
    ...             msg=Validate Definition Errors for min NRARFCN failed.
    selenium_coam.undo_changes
#    #Modification type - Conditional BTS restart
#    log to console    \nModification type - Conditional BTS restart: "NRARFCN"
#    ${fcnActu_modify}=    Evaluate    ${fcnActu}+2
#    set test variable    ${fcnActu_modify}
#    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
#    ...    filter_param=NR Absolute radio frequency channel number    new_value=${fcnActu_modify}
#    sleep    3s
#    Validate and activate and check activate plan status
#    sleep    60s
#    wait until keyword succeeds     8min    1min    WEBUI Login
#    wait until keyword succeeds     20min    30s    Check Cell is UP

#General_SiSo_RF_module_reset_from_GUI
"${Step}": Perform RF Module Reset from GUI
    log to console    \n"${Step}": Perform RF Module Reset from GUI - started
    ${ru_list}    Get list of all ru
    set test variable    ${ru_list}
    FOR    ${ru_id}    IN    @{ru_list}
         Perform RU Reset    ru_index=${ru_id}   download_dir=${SAVE LOG DIRECTORY}
         sleep    5s
    END
    WEBUI Login
    Run Keyword and Ignore Error    Wait Until Keyword Succeeds    2min    5s    Check all RUs Disabled
    log to console    \n"${Step}": Perform RF Module Reset from GUI - completed

"${Step}": Check RF Startup and Gnb Status
    log to console    \n"${Step}": Check RF Startup and Gnb Status - started
    ${led_ASIK}    run keyword and ignore error       Check Given ASIK Led State    asik=1
    should be equal   ${led_ASIK[1]}   Online
    ${led_ABIL}    run keyword and ignore error       Check Given ABIL Led State    abil=1
    should be equal   ${led_ABIL[1]}   Online
    Wait Until Keyword Succeeds    18min    10s    check RU STATUS
    Wait Until Keyword Succeeds    5min    10s    Check Cell is UP
    log to console    \n"${Step}": Check RF Startup and Gnb Status - completed

#General_SiSo_xxx


Check RU Connection
    [Arguments]    ${ru_alias}    ${asik_alias}
    ${FHNETcontainer_id}     Get FHNET Container ID    asik_alias=asik
    Connect to RU With Allocated IP
    ...     ru_alias=${ru_alias}
    ...     asik_alias=${asik_alias}
    ...     container_id=${FHNETcontainer_id}

case teardown
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If   '${is_startup_window_exist[0]}'=='True'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    run keyword and ignore error     WEBUI Logout
    csn.reset cache

Data transfer with Check Throughput
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to frame structure
    ...    ******************
    ...    History of changes
    ...    ******************
    #${both_name}  ${bandwidth}  split String From Right  ${TEST_NAME}  _  1
    ${pattern_1}   Set Variable    ^[0-9]+
    @{match_1}    Get Regexp Matches     ${bandwidth}    ${pattern_1}
    set test variable  ${band}  ${match_1[0]}
    ${test_flag}  set variable  PASS
    FOR  ${frame_structure}  IN  @{frame_structure_list_${band}MHz}
       set test variable  ${frame_structure}
       ${status}  run keyword and ignore error  Modify Frame Structure And Check Throughput
       ${test_flag}  set variable  ${status[0]}
    END
    run keyword if  '${test_flag}'=='FAIL'  fail   not all frame structure pass

Modify Frame Structure And Check Throughput
    log to console    \n***Modify Frame Structure And Check Throughput***
    Get Modify Params And Expected Tput
    Modify SCF and Wait gnb Onair
    Data Transfer with Check Peak Throughput

Get Modify Params And Expected Tput
    log to console    \n***Get Modify Params And Expected Tput***
    ${program}    gnb_classical_hangzhou.Get program version based on stream version
    import variables  ${CURDIR}/variable/frame_structure_variables_${program}.py
    ${Modify_Params}  get from dictionary  ${Band_Tput_${band}_${frame_structure}}  Modify_Params
    ${Peak_Tput_DL}  get from dictionary  ${Band_Tput_${band}_${frame_structure}}  Peak_Tput_DL
    ${Peak_Tput_UL}  get from dictionary  ${Band_Tput_${band}_${frame_structure}}  Peak_Tput_UL
    ${Expect_Rate}  get from dictionary  ${Band_Tput_${band}_${frame_structure}}  Expect_Rate
    ${Duration}  get from dictionary  ${Band_Tput_${band}_${frame_structure}}  Duration
    set test variable  ${Modify_Params}
    set test variable  ${Duration}
    ${status}  ${output}  run keyword and ignore error  variable should exist  ${rate_for_stream}
    ${case_rate}    run keyword if  '${status}'=='PASS'  get from dictionary  ${rate_for_stream}  ${program}
    ...                       ELSE  set variable  peak
    ${actual_rate}      set variable if      '${case_rate}'=='peak'    ${Expect_Rate}    ${case_rate}
    ${Tput_DL}  ${Tput_UL}  ${Expect_Tput_DL}  ${Expect_Tput_UL}  Calculate Send Tput And Expected Tput    ${Peak_Tput_DL}
    ...    ${Peak_Tput_UL}  ${actual_rate}
    set test variable  ${Tput_DL}
    set test variable  ${Tput_UL}
    set test variable  ${Expect_Tput_DL}
    set test variable  ${Expect_Tput_UL}
    set test variable  ${actual_rate}

Modify SCF and Wait gnb Onair
     log to console    \n***Modify SCF and Wait gnb Onair***
     Modify Case SCF and Commission  ${Modify_Params}
     COAM Wait For Gnb Ready And Cell Setup    timeout=15 min

Modify Case SCF and Commission
    [Arguments]  ${modify_params}  ${cell_id}=1
    ${mrbts_id}  ${nrbts_id}  Get mrbtsID and nrbtsID for gNB
    Connect to gnb coam via ssl
    ${dist_name}  set variable  MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    ${scf_file}  COAM Download scf from cluster  scf_dir_path=${SAVE LOG DIRECTORY}
    ${scf_file_name}    Fetch from right    ${scf_file}    /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${time}  get time  epoch
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    ${time}.xml
    ${scf_file_update_path}    set variable    ${SAVE LOG DIRECTORY}/${scf_name_for_update}
    scf.Load scf    ${scf_file}
    # modify p under object
    ${modify_list}    get from dictionary    ${modify_params}    p_under
    FOR  ${item}  IN  @{modify_list}
        scf.modify_scf_element  dist_name=${dist_name}    p_name=${item}[p_name]    value=${item}[value]
    END
    # modify list under object
    ${result}  scf.is_list_in_object  dist_name=${dist_name}     list_name=${list_name}
    run keyword if    ${result}==True    scf.remove_list_from_scf  dist_name=${dist_name}   list_name=${list_name}
    scf.add list to scf  dist_name=${dist_name}   list_name=${list_name}
    ${modify_list}    get from dictionary    ${modify_params}    list_under
    FOR  ${item}  IN  @{modify_list}
        scf.add_item_to_list  dist_name=${dist_name}   list_name=${list_name}  elements=${item}[elements]
    END
    scf.Save scf    ${scf_file_update_path}
    COAM Commission with scf file    scf_file_path=${scf_file_update_path}     is_pdl_checking_needed=${False}     timeout=600


Data Transfer with Check Peak Throughput
    log to console    \n***Data Transfer with Check Peak Throughput***
    ${status}    set variable
    FOR  ${i}  IN RANGE  ${3}
       ${status}  run keyword and return status  L3 Call And Throughput  dl_tp=${Tput_DL}  ul_tp=${Tput_UL}
       ...        duration=${Duration}  dl_exp=${Expect_Tput_DL}  ul_exp=${Expect_Tput_UL}   actual_rate=${actual_rate}
       exit for loop if    ${status}
    END
    run keyword if      not ${status}    FAIL

L3 Call And Throughput
    [Arguments]  ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=100M    ${duration}=${30}
    ...    ${dl_exp}=60    ${ul_exp}=20    ${actual_rate}=0.1
    log    ${4G_check}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    Teardown the Aasyslog save progress
#   power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=${4G_check}
    ${traffic_duration}  evaluate  ${duration}*10+100
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${traffic_duration}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${traffic_duration}
#    ${dl_status}  ${output}  run keyword and ignore error  power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#    ...    throughput=${dl_exp}    sample=${duration}    start_offset=${duration}
#    ${ul_status}  ${output}  run keyword and ignore error  power_ue.Check throughput    ue_type=${ue_type}    direction=ul
#    ...    throughput=${ul_exp}    sample=${duration}    start_offset=${duration}
    Verify tput from GNB within duration and record data to csv    total_time=60    exp_dl_tput=${dl_exp}
    ...    exp_ul_tput=${ul_exp}    interval=10    duration_time_for_once=200s
    ...    tput_percentage=${actual_rate}    is_need_to_capture_log=${False}
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
#    run keyword if  '${dl_status}'=='FAIL' or '${ul_status}'=='FAIL'  FAIL  throughput are less than expect
    [Teardown]  run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    run keyword and ignore error   power_ue.UE Detach  ue_type=${ue_type}

SISO Test Setup
    log to console    \n***SISO Test Setup***
    Generate test case log path
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Connect to gnb coam via ssl
    ${ru_info}    COAM get all ru detail info
    &{ru_info}    Set variable    ${ru_info['1']}
    run keyword and ignore error  should contain  ${TEST_NAME}  ${ru_info}[productName]
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    #${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
    #Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False} or ${alarm_status}==${False}  Commissioning SCF And Check On Air
    #Start Btslog With Path Check
    #Run Keyword And Ignore Error  COAM selenium logout
    Run Keyword And Ignore Error  Coam Logout And Kill Browser

SISO Test Teardown
    log to console    \n***SISO Test Teardown***
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    should be true    ${cell_status}
    #${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
    #should be true    ${alarm_status}
    #${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    #run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    #run keyword if test failed     Collect Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
    COAM Teardown gnb connections


Coam Logout And Kill Browser
    Run Keyword And Ignore Error    coam selenium logout
    #Run Keyword And Ignore Error    Run    ps -ef|grep chrome | awk '{print $2}' |xargs kill -9
    #Run Keyword And Ignore Error    Run    ps -ef|grep firefox | awk '{print $2}' |xargs kill -9
    Run Keyword And Ignore Error     selenium_coam.close_browser

Calculate Send Tput And Expected Tput
    [Arguments]   ${dl_tp}  ${ul_tp}  ${rate}
    log    ${rate}
    ${unit}  Get Substring  ${dl_tp}  -1
    ${value}  Get Substring  ${dl_tp}  0  -1
    ${value}  convert to number  ${value}
    ${dl_exp}  run keyword if  '${unit.upper()}'=='G'  evaluate  ${value}*1024
    ...                ELSE  evaluate  ${value}*1.0
#    ${dl_exp}  run keyword if  '${unit.upper()}'=='G'  evaluate  ${value}*1024*${rate}
#    ...                ELSE  evaluate  ${value}*${rate}
    ${dl_tp}  evaluate  ${value}*1.25
    ${dl_tp}  set variable  ${dl_tp}${unit}
    ${unit}  Get Substring  ${ul_tp}  -1
    ${value}  Get Substring  ${ul_tp}  0  -1
    ${value}  convert to number  ${value}
    ${ul_exp}  run keyword if  '${unit.upper()}'=='G'  evaluate  ${value}*1024
    ...                ELSE  evaluate  ${value}*1.0
#    ${ul_exp}  run keyword if  '${unit.upper()}'=='G'  evaluate  ${value}*1024*${rate}
#    ...                ELSE  evaluate  ${value}*${rate}
    ${ul_tp}  evaluate  ${value}*1.25
    ${ul_tp}  set variable  ${ul_tp}${unit}
    [Return]  ${dl_tp}  ${ul_tp}  ${dl_exp}  ${ul_exp}

Collect Coam Snapshot
    [Arguments]        ${gnb_id}=0    ${name}=gnb_coam_snapshot     ${coverage}=Full    ${force}=0     ${timeout}=480
    ...                ${port}=443    ${target_dir}=${OUTPUT DIR}
    [Documentation]    Collects the snapshot files to OUTPUT DIR.
    ...                gnb_id: gnb_id default value:0
    ...                name: name of the collector. Ex: gnb_coam_snapshot
    &{webservice}=    create dictionary    host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...                                    user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...                                    password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...                                    port=${port}
    snapshot.create_sbts_snapshot_collector         name=${name}     webservice=${webservice}   coverage=${coverage}
    ...                                    force=${force}   timeout=${timeout}
    core.setup_collectors                       names=${name}
    core.collect_collectors                     names=${name}    target_dir=${target_dir}
    core.teardown_collectors                    names=${name}

Stop Btslog Collect
    [Timeout]  3 hours
    [Arguments]               ${names}=btslog     ${target_dir}=${OUTPUT DIR}
    run keyword and ignore error      core.stop_collectors    names=${names}
    run keyword and ignore error      core.collect_collectors      names=${names}    target_dir=${target_dir}
    core.teardown_collectors      names=${names}

Get mrbtsID and nrbtsID for gNB
    [Arguments]  ${cell_id}=1
    Connect to gnb coam via ssl
    ${scf_path}  COAM Download scf from cluster
    ${nrcell_info}    Run    cat ${scf_path} | grep -oE "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-${cell_id}" | head -n 1
    ${mrbtsID}    Run    echo ${nrcell_info}|grep -oE "MRBTS-[0-9]+"| awk -F '-' '{print $2}'
    ${nrbtsID}    Run    echo ${nrcell_info}|grep -oE "NRBTS-[0-9]+"| awk -F '-' '{print $2}'
    set test variable  ${mrbtsID}
    set test variable  ${nrbtsID}
    [Return]    ${mrbtsID}    ${nrbtsID}
    [Teardown]    COAM Teardown gnb connections


SISO Suite Setup
    log to console    \n***SISO Suite Setup***
    Run Keyword And Ignore Error    run process    ps -ef|grep chrome | awk '{print $2}' |xargs kill -9    shell=True
    Run Keyword And Ignore Error    run process    ps -ef|grep firefox | awk '{print $2}' |xargs kill -9    shell=True
    run keyword if    '${testline_name}' == 'null'
    ...    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ELSE         Connect to gnb coam via ssl
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM
    @{result}    string.split string    ${sw_version}    separator=_
    ${length}    Get Length    ${result}
    ${i} =    Set Variable    ${1}
    ${SW_vesion_tmp}    convert to integer     ${result}[2]
    FOR    ${i}    IN RANGE    1    ${length} - ${2}
         ${j} =    Evaluate    ${i} + ${2}
         ${build}    set variable    ${result}[${j}]
         ${build}    Run Keyword If    ${j} < 5    convert to integer    ${result}[${j}]    ELSE    set variable    ${result}[${j}]
         ${SW_vesion_tmp}    set variable    ${SW_vesion_tmp}.${build}
    END
    set suite variable    ${Active_SW_version}    ${SW_vesion_tmp}
    run keyword if     ${if_commissioning}    Commissioning SCF And Check On Air
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}

Commissioning SCF And Check On Air
    Log to console    \n***Commissioning SCF And Check On Air***
    ${rest}    ${last}     String.split string from right    string=${Active_SW_version}    separator=.    max_split=${1}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -31
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    ${GOLDEN_FULL_SCF}   Set Variable    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_${rest}.xml
    COAM Commission with scf file  scf_file_path=${GOLDEN_FULL_SCF}    timeout=600
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min

SISO Suite Teardown
    log to console    \n***SISO Suite Teardown***
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

Start Btslog With Path Check
    [Documentation]    Need to set suite variable for stopping btslog in teardown
    FOR   ${btslog_dir}     IN     @{btslog_dirs}
          ${file_exist}=    Run Keyword And Return Status    File Should Exist    ${btslog_dir}/btslog
          run keyword if      '${file_exist}'=='True'       run keywords       Start Btslog Collect
          ...    btslog_dir=${btslog_dir}    AND    Exit For Loop
    END
    Set Suite Variable    ${btslog_dir}
    run keyword if    '${btslog_dir}'=='none'    Log    Can't find btslog.    WARN

Start Btslog Collect
    [Arguments]      ${names}=btslog     ${btslog_dir}=/opt/btslog     ${log_dir}=/tmp/btslog2
    btslog.create_btslog_collector    name=${names}    btslog_path=${btslog_dir}/btslog
    ...                               btslog_launcher_path=${btslog_dir}/btslog_launcher
    ...                               log_dir=${log_dir}
    core.setup_collectors      names=${names}
    core.start_collectors      names=${names}
    btslog.Set Suite Alias     ${names}
