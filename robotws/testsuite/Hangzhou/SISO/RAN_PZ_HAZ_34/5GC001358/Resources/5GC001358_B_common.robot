*** Settings ***
Documentation
...    author: Guo Zhenzhen
...    contact: zhenzhen.guo@nokia-sbell.com
...    squad group: SG_03
...    Feature : 5GC001358

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    5GC001358_A_common.robot

*** Variables ***

*** Keywords ***
Check RF config via WebEM
    log to console    Check RF config via WebEM
    #get RF SW from TargetBD
    log to console    \nget RF SW from TargetBD
    ${ruSW_expect}=    5GC001358_B_common.get RFSW version in TargetBD
    #get RF SW from RF module
    log to console    \nget RF SW from RF module
    ${ruSW_fromModule}=    5GC001358_B_common.get RFSW version from radio module
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
    5GC001358_B_common.define BPF params value from spec
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

get RFSW version in TargetBD
    [Arguments]   ${radio_type}=${ru_type_init}
    ${TargetBD_FileName}   ${save_path}    5GC001358_B_common.check TargetBD exist and match
    set test variable    ${resBuild_key}    LTX_${radio_type}
    ${cmd_grep}   set variable   cat ${save_path}/${TargetBD_FileName}|grep 'hwResource resourceBuildKey="${resBuild_key}'
    ${result}=    Run Process    ${cmd_grep}    shell=True   timeout=30s   alias=myproc
    ${output_resBuildKey}=    Get Process Result     myproc
    @{ru_version}    Get Regexp matches    ${output_resBuildKey.stdout}    resourceSWVersion="(.*)"    1
    set test variable    ${ruSW_TargetBD}    ${ru_version}[1]
    [Return]    ${ruSW_TargetBD}

check TargetBD exist and match
    @{version}=    5GC001358_A_common.check SW version    Active
    set test variable    ${active_version}    ${version}[0]
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=gNB_target
    sleep   2s
    csn.send command    command=cd /ffs/run/;ls TargetBD_*.xml    connection=gNB_target
    ${TargetBD_FileName}=    csn.read output    connection=gNB_target
    run keyword and ignore error    csn.download file
    ...    /ffs/run/TargetBD_${active_version}.xml    ${TS_CASE_LOG_PATH}TargetBD_${active_version}.xml
    ...    connection=gNB_target
    csn.disconnect    connection=gNB_target
    @{TargetBD_FileName}    string.split string    ${TargetBD_FileName}    separator=\
    ${TargetBD_FileName}    set variable    ${TargetBD_FileName}[0]
    should be equal as strings    '${TargetBD_FileName}'   'TargetBD_${active_version}.xml'
    ${save_path}    set variable    ${TS_CASE_LOG_PATH}
    [Return]    ${TargetBD_FileName}    ${save_path}

get RFSW version from radio module
    [Arguments]   ${ru_ip}=${ru_addr}
    Connect to gnb coam via ssl
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=asik
    #Connect to RU With Allocated IP     ru_alias=ru    asik_alias=asik
    ${FHNETcontainer_id}     Get FHNET Container ID    asik_alias=asik
    5GC001358_A_common.Connect to AZQG With Allocated IP
    ...     ru_alias=ru
    ...     asik_alias=asik
    ...     container_id=${FHNETcontainer_id}
    set test variable    ${cmd_ruSW}    cat /etc/version
    ${output_cmd_ruSW}    csn.execute    command=${cmd_ruSW}    connection=ru    timeout=60s
    ${ruSW_fromModule}    Fetch from left   string=${output_cmd_ruSW}    marker=${SPACE}
    ${ruSW_fromModule}    Strip string    ${ruSW_fromModule}
    run keyword and ignore error    csn.disconnect    connection=ru
    run keyword and ignore error    csn.disconnect    connection=asik
    [Return]    ${ruSW_fromModule}

define BPF params value from spec
    [Documentation]   This keyword defines BPF params value from Spec pov, such as
    ...    unit name, type, variant, product code, supported technologies, bands, bandwidth, powers, antennas, optical ports
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    Example
    ...    |     | define BPF params value from spec | AWHQG |
    [Arguments]   ${radio_type}=${ru_type_init}
    set test variable   ${radio_type}
    run keyword if     '${radio_type}'=='AZQG'         run keywords
    ...    set test variable    ${ProductCode_expect}   <p Name="Visible.Product.Code">474994A</p>    AND
    ...    set test variable    ${unitType_expect}      <unitType>AZ</unitType>    AND
    ...    set test variable    ${variant_expect}       <variant>QG</variant>    AND
    ...    set test variable    ${SuppTech_expect}      <list Name="Supported.Technology"><p>5G</p></list>    AND
    ...    set test variable    ${FreqBand_expect}      <list Name="Frequency.Band"><p>3500</p>    AND
    ...    set test variable    ${optical_expect}       <p Name="Opt.Interfaces">0;1</p>    AND
    ...    set test variable    ${NumTRX_expect}        <p Name="Num.Of.RX">16</p><p Name="Num.Of.TX">16</p>    AND
    ...    set test variable    ${Bandwidth_expect}     <p Name="Max.Total.Bandwidth">100</p>    AND
    ...    set test variable    ${NRFreqBand_expect}    <list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>    AND
    ...    set test variable    ${MinFreq_expect}       <p Name="Min.Frequency">3400.0</p>    AND
    ...    set test variable    ${MaxFreq_expect}       <p Name="Max.Frequency">3599.9</p>
    ...    ELSE   log to console    not AZQG

399 Case Setup
    COAM Create log directory
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to Common Unit Master
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Check GNB cell on air
    #Wait Until Keyword Succeeds    300 sec   5 sec     Check Gnb Type Via Webui
    ${exist_fault}    coam_gnb_classical.COAM Get active alarms
    Set test variable    ${exist_fault}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}

399 Case TearDown
    [Arguments]     ${gnb_index}=0    ${du_index}=0    ${ru_index}=1
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run Keyword And Ignore Error    coam_gnb_classical.COAM Get active alarms
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error   csn.disconnect    connection=RU
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master
    run keyword and ignore error   COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    CI_interface.Common Case Teardown


Restore Parameter If Test Case Failed
    [Arguments]     ${parameters_to_update_via_webui}=None     ${download_dir}=${TS_CASE_LOG_PATH}
    Run Keyword If Test Failed     Run Keyword And Ignore Error    Run Keyword    COAM Update several parameters via webUI
    ...                            parameters_to_update_via_webui=${parameters_to_update_via_webui}
    ...                            download_dir=${download_dir}
    ...                            is_gnb_restrat_after_online_modify=${True}
    Run Keyword And Ignore Error    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min


Set parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}
    ...              ${download_dir}=${TS_CASE_LOG_PATH}
    ...              ${is_gnb_restrat_after_online_modify}=${False}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
        selenium_coam.set_parameter_value
        ...    abbr=${cur_para_to_update['abbr']}
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        ...    new_value=${cur_para_to_update['new_value']}
    END

Validate And activate Plan
    [Arguments]    ${is_need_to_check_validation_errors}=False    ${activate_plan_despite_errors}=True
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    COAM selenium logout
