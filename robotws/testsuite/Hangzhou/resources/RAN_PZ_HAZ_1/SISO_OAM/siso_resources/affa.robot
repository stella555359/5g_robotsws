*** Settings ***
Documentation
...    Author:        amy.wu@nokia-sbell.com
...    Maintainer:    amy.wu@nokia-sbell.com

Library    taf.transport.ssh    WITH NAME    csn
Library    SSHLibrary
Library    OperatingSystem

Resource   bts_common_interface.robot
Resource   common_setup.robot

*** Variables ***
${fault_10}    {"faultId": "10"}
${FID3030_NAME}     Failure in optical interface
${FID2002_NAME}     Receiving failure in Optical Interface
${FID10_NAME}       No connection to unit
${FID1956_NAME}     FHS autonomous reset as recovery action
${FID1868_NAME}     BTS configuration error (not enough HW for LCR)

*** Keywords ***
Get Bts Id with FHS Serial Number
    [Arguments]    ${fhs_serial_number}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        Return From Keyword If    "${fhs_serial_number}" in ${NODE_CFG['${bts_id}'].fhs_sn_list}    ${bts_id}
    END

Get FHS IP
    [Arguments]    ${fhs_serial_number}
    ${bts_id}    Get Bts Id with FHS Serial Number    ${fhs_serial_number}
    ${object_info}    Get RRU Object Info With Serialnum    class_name=FHS_L    serial_num=${fhs_serial_number}
    ...     connection=${CASE_NAME}_${bts_id}
    ${ip}    Set Variable    ${object_info["parameters"]["ipAddress"]}
    [Return]    ${ip}

Flash Radio Module with new SW via bci command
    [Arguments]    ${host_ip}    ${rf_ip_address}    ${file}
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=flash_radio_module
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    SSHLibrary.Write    ssh toor4nsn@${BTS_HOST}
    ${status}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    Run Keyword If    ${status}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    SSHLibrary.Read Until    >
    Run Keyword And Ignore Error    SSHLibrary.Read Until    >
    SSHLibrary.Write    lxc-ls --active
    ${ret}    SSHLibrary.Read Until    >
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword And Ignore Error    Should Match Regexp    ${ret}    0x1018
    Run Keyword If    '${ret1[0]}'=='PASS'    SSHLibrary.Write    lxc-attach -n 0x2018
    Run Keyword If    '${ret2[0]}'=='PASS'    SSHLibrary.Write    lxc-attach -n 0x1018
    SSHLibrary.Read Until    >
    SSHLibrary.Write    ifconfig
    ${out}    SSHLibrary.Read Until    root
    ${match}    ${rlan0_cpri_ip}     Should Match Regexp    ${out}    inet (172\\.\\d+\\.\\d+\\.\\d+)
    SSHLibrary.Write    telnet ${rf_ip_address}
    SSHLibrary.Read Until    login:
    SSHLibrary.Write    asb
    SSHLibrary.Read Until    Password:
    SSHLibrary.Write    asb#1234
    SSHLibrary.Read Until    >
    SSHLibrary.Write    bci
    SSHLibrary.Read Until    login:
    SSHLibrary.Write    asb
    SSHLibrary.Read Until    Password for asb:
    SSHLibrary.Write    asb#1234
    SSHLibrary.Read Until    >
    SSHLibrary.Write    /pltf/flashdev/trxProgramFlash ${rlan0_cpri_ip}:${file} toor4nsn oZPS0POrRieRtu no y
    Sleep    3 min
    SSHLibrary.Read Until    >
    SSHLibrary.Write    /pltf/flashdev/activateMod
    SSHLibrary.Read Until    >
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

SW Update Due to Fault 0023
    [Arguments]    ${bts_id}    ${sw_builds_dir_path}
    ${status}    Run Keyword And Return Status    OperatingSystem.Directory Should Not Exist   ${sw_builds_dir_path}
    Run Keyword If    ${status}    OperatingSystem.Create Directory    ${sw_builds_dir_path}
    ${files}    OperatingSystem.List Files In Directory    ${sw_builds_dir_path}
    ${sw_downloaded}    Run Keyword And Return Status    Should Contain Match    ${files}
    ...    regexp=${NODE_CFG['${bts_id}'].software_active}
    ${package_type}    Get Variable Value    ${tl_config.PACKAGE_TYPE}    Normal
    Run Keyword If    '${sw_downloaded}'=='False'    Sw Package Download    ${NODE_CFG['${bts_id}'].software_active}
    ...    target_dir=${sw_builds_dir_path}    package_type=${package_type}
    ${files}    OperatingSystem.List Files In Directory    ${sw_builds_dir_path}
    ${matched_file}    Get Matches   ${files}    ${NODE_CFG['${bts_id}'].software_active}*
    Set To Dictionary    ${NODE_CFG['${bts_id}']}    active_file_path=${matched_file[0]}
    Wait Until Keyword Succeeds    20 min    30 sec    coam.Update Software    ${sw_builds_dir_path}/${matched_file[0]}
    ...    connection=${CASE_NAME}_${bts_id}

Get Storage Info From Testline Config File
    ${login}=          Get From Dictionary  ${tl_config.RF_FACTORY_SW_STORAGE}  LOGIN
    ${passwd}=         Get From Dictionary  ${tl_config.RF_FACTORY_SW_STORAGE}  PASSWORD
    ${ip}=             Get From Dictionary  ${tl_config.RF_FACTORY_SW_STORAGE}  HOST_IP
    ${sw_path}=        Get From Dictionary  ${tl_config.RF_FACTORY_SW_STORAGE}  SW_PATH
    ${config_path}=    Get From Dictionary  ${tl_config.RF_FACTORY_SW_STORAGE}  CONFIG_PATH
    ${config_file}=    Get From Dictionary  ${tl_config.RF_FACTORY_SW_STORAGE}  CONFIG_FILE
    [Return]  ${login}  ${passwd}  ${ip}  ${sw_path}  ${config_path}  ${config_file}

Get Product Name If Serial Number Given
    [Arguments]    ${bts_id}    ${fr_serial_number_or_variant}
    ${status}   ${result}=    Run Keyword And Ignore Error
    ...    SCFC Get Product Name For FR Serial Number    ${NODE_CFG["${bts_id}"]["scf_file_path"]}    ${fr_serial_number_or_variant}
    ${product_name}    Set Variable If    '${status}'=='PASS'    ${result}    ${fr_serial_number_or_variant}
    [Return]  ${product_name}

SCFC Get Product Name For FR Serial Number
    [Arguments]    ${scfc_file_path}    ${fr_serial_number}
    ${out_product_name}=    Evaluate Xpath    ${scfc_file_path}
    ...     string(.//managedObject[@class="com.nokia.srbts.eqmr:RMOD_R" and p[@name="serialNumber"]="${fr_serial_number}"]/p[@name="productName"])
    [Return]    ${out_product_name}

Download Factory Radio Bin From Storage
    [Arguments]  ${bts_id}    ${fr_serial_number_or_variant}  ${additional_grep}=${EMPTY}
    ${out_login}  ${out_passwd}  ${out_ip}  ${out_sw_path}  ${out_config_path}  ${out_config_file}=
    ...               Get Storage Info From Testline Config File
    ${out_radio}=     Get Product Name If Serial Number Given  ${bts_id}    ${fr_serial_number_or_variant}
    SSHLibrary.Open Connection  ${out_ip}  alias=factory
    SSHLibrary.Login            ${out_login}  ${out_passwd}
    ${out_files_matching_grep}=      SSHLibrary.List Files In Directory  ${out_sw_path}     pattern=*${additional_grep}*
    ${out_files_matching_radio}=     Get Matches   ${out_files_matching_grep}   regexp=.*${out_radio}${additional_grep}.bin
    SSHLibrary.Get File    ${out_sw_path}${out_files_matching_radio[0]}    ${SW_BUILDS_DIR_PATH}
    OperatingSystem.File Should Exist  ${SW_BUILDS_DIR_PATH}${out_files_matching_radio[0]}
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection
    [Return]  ${SW_BUILDS_DIR_PATH}    ${out_files_matching_radio[0]}

RU_Support_for_old_FirmWare_version
    [Arguments]    ${bts_id}
    ${fr_serial_number_list}    Get From Dictionary    ${factory_load_radios}    ${bts_id}
    FOR    ${fr_serial_number}    IN    @{fr_serial_number_list}
        ${remote_host}    Set Variable    ${NODE_CFG["${bts_id}"]["host_ip"]}
        ${rf_ip_address}    Get RRU IP    ${fr_serial_number}
        ${file_path}    ${file_name}    Download Factory Radio Bin From Storage    ${bts_id}    ${fr_serial_number}
        Setup Enb Fsm Access    host=${BTS_HOST}    remote_host=${remote_host}
        Put Enb File    ${file_path}${file_name}    /tmp/${file_name}
        Teardown Enb Fsm Access
        Flash Radio Module with new SW via bci command    ${remote_host}    ${rf_ip_address}    /tmp/bts_tmp/${file_name}
        coam.reset unit    dist_name=${NODE_CFG["${bts_id}"]["rmod_info"]["${fr_serial_number}"]["distName"]}
        ...    reset_type=Soft    timeout=1000    connection=${CASE_NAME}_${bts_id}
        coam.assert_alarm_active    parameters=faultId=23, serialNo=${fr_serial_number}    timeout=180    connection=${CASE_NAME}_${bts_id}
    END
    SW Update Due to Fault 0023    ${bts_id}    ${SW_BUILDS_DIR_PATH}/
    Wait For All Cells OnAir

Get Epimc Distname
    [Arguments]    ${scfc_file_path}    ${fhs_serial_number}
    ${fhs_r_dist_name}    Evaluate Xpath    ${scfc_file_path}
    ...    .//managedObject[@class="com.nokia.srbts.eqmr:FHS_R" and p[@name="serialNumber"]="${fhs_serial_number}"]/@distName
    ${fhs_dist_name}    Evaluate Xpath    ${scfc_file_path}
    ...     .//managedObject[@class="com.nokia.srbts.eqmr:FHS_R" and p[@name="serialNumber"]="${fhs_serial_number}"]/p[@name="configDN"]/text()
    ${epimc_path}    Evaluate Xpath    ${scfc_file_path}    .//managedObject[contains(@distName, "${fhs_dist_name[0]}/EPIMC")]/@distName
    ${epimc_r_path}    Evaluate Xpath    ${scfc_file_path}    .//managedObject[contains(@distName, "${fhs_r_dist_name[0]}/EPIMC_R")]/@distName
    [Return]    ${epimc_path[0]}    ${epimc_r_path[0]}

Check Pim Parameters Value
    [Documentation]    This keyword can validate if EPIMC-specific parameters have expected values. User needs to specify
    ...    expected values inside the arguments. If a parameter doesn't need to be verified, please set its expected
    ...    value to 'none'.
    [Arguments]    ${bts_id}    ${fhs_serial_number}    ${exp_activation_flag}    ${exp_enabling_flag}
    ...    ${exp_calibration_status}    ${exp_operational_status}
    ${scfc_file_path}    Get Current Scfc    ${bts_id}
    ${epimc_dist_name}    ${epimc_r_dist_name}    Get Epimc Distname    ${scfc_file_path}    ${fhs_serial_number}
    Run Keyword If    '${exp_activation_flag}'!='none'    Compare Element Parameter Value To Actual Configuration
    ...    scfc=${scfc_file_path}    element=${epimc_dist_name}    parameter=actExtPIMCancellation
    ...    expected_value=${exp_activation_flag}
    Run Keyword If    '${exp_enabling_flag}'!='none'    Compare Element Parameter Value To Actual Configuration
    ...    scfc=${scfc_file_path}    element=${epimc_dist_name}    parameter=extPIMCancellingEnabled
    ...    expected_value=${exp_enabling_flag}
    Run Keyword If    '${exp_calibration_status}'!='none'    Compare Element Parameter Value To Actual Configuration
    ...    scfc=${scfc_file_path}    element=${epimc_r_dist_name}    parameter=extPIMCCalibrationStatus
    ...    expected_value=${exp_calibration_status}
    Run Keyword If    '${exp_operational_status}'!='none'    Compare Element Parameter Value To Actual Configuration
    ...    scfc=${scfc_file_path}    element=${epimc_r_dist_name}    parameter=extPIMCOperationStatus
    ...    expected_value=${exp_operational_status}

Compare Element Parameter Value To Actual Configuration
    [Documentation]    Comparing given parameter to actual value on eNB
    ...                Requires include Library  XML  use_lxml=True inside test
    ...                Author: artur.czainski@nokia.com
    [Arguments]    ${scfc}    ${element}    ${parameter}    ${expected_value}
    ${parameter_xpath}=    Set Variable    .//managedObject[@distName="${element}"]/p[@name="${parameter}"]
    ${actual_value}=    Get Element Text    ${scfc}    ${parameter_xpath}
    ${actual_value}=    Convert to String    ${actual_value}
    ${expected_value}=    Convert to String    ${expected_value}
    Should Be Equal as Strings     ${actual_value}    ${expected_value}

Online Set RTC Relevant Parameters
    [Arguments]    ${scfc_file_path}    ${fhs_serial_number}    ${connection}
    Log    ${fhs_serial_number}
    ${lcell_list}    Get Elements    ${scfc_file_path}    xpath=//managedObject[@class='NOKLTE:LNCEL']/@distName
    ${out_antl_list}=    Get Elements    ${scfc_file_path}    xpath=//managedObject[@class='com.nokia.srbts.eqm:ANTL']/@distName
    ${antennaPathDelayDL_list}    Evaluate Xpath   ${scfc_file_path}
    ...    .//managedObject[@class='com.nokia.srbts.eqm:ANTL']/p[@name='antennaPathDelayDL']/text()
    ${antennaPathDelayDL}    Convert To Integer    ${antennaPathDelayDL_list[0]}
    ${new_antennaPathDelayDL}    Set Variable If    ${antennaPathDelayDL} > 180    20    3600
    coam.Create delta
    FOR    ${lcell_distname}    IN    @{lcell_list}
        ${lcell_distname}    Convert To String    ${lcell_distname}
        coam.append_parameter_update_to_delta    ${lcell_distname}    dlInterferenceEnable    true
        coam.append_parameter_update_to_delta    ${lcell_distname}    dlInterferenceLevel    100
    END
    FOR    ${antl_distname}    IN    @{out_antl_list}
        ${antl_distname}    Convert To String    ${antl_distname}
        coam.append_parameter_update_to_delta    ${antl_distname}    antennaPathDelayDL    ${new_antennaPathDelayDL}
    END
    ${delta_update}=    coam.Get delta
    coam.Perform delta recommissioning    ${delta_update}    timeout=600    connection=${connection}
    Run Keyword And Continue On Failure    Wait For All Cells OnAir
    [Teardown]    coam.Remove delta

RTC Trigger Check
    [Arguments]    ${host_ip}    ${fhs_ip}
    SSHLibrary.Open Connection    ${host_ip}    timeout=30   alias=flash_radio_module
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    SSHLibrary.Write    ssh toor4nsn@${BTS_HOST}
    ${status}    Run Keyword And Return Status    SSHLibrary.Read Until    Password:
    Run Keyword If    ${status}    SSHLibrary.Write    oZPS0POrRieRtu    ELSE    SSHLibrary.Write    \n
    SSHLibrary.Read Until    >
    Run Keyword And Ignore Error    SSHLibrary.Read Until    >
    SSHLibrary.Write    lxc-ls --active
    ${ret}    SSHLibrary.Read Until    >
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${ret}    0x2018
    ${ret2}    Run Keyword And Ignore Error    Should Match Regexp    ${ret}    0x1018
    Run Keyword If    '${ret1[0]}'=='PASS'    SSHLibrary.Write    lxc-attach -n 0x2018
    Run Keyword If    '${ret2[0]}'=='PASS'    SSHLibrary.Write    lxc-attach -n 0x1018
    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    rm /user/toor4nsn/.ssh/known_hosts
    ${out}    SSHLibrary.Read Until    >
    ${out}    SSHLibrary.Write    ssh serviceuser@${fhs_ip}
    ${ret}    Run Keyword And Return Status    SSHLibrary.Read Until    (yes/no/[fingerprint])?
    ${out}    Run Keyword If    ${ret}    SSHLibrary.Write    yes    ELSE    SSHLibrary.Write    \n
    ${out}    SSHLibrary.Read Until    password:
    ${out}    SSHLibrary.Write    Pl(FzaYj5~c5;q
    ${out}    SSHLibrary.Read Until    $
    ${out}    SSHLibrary.Write    su toor4nsn
    ${out}    SSHLibrary.Read Until    Password:
    ${out}    SSHLibrary.Write    oZPS0POrRieRtu
    ${out}    SSHLibrary.Read Until    \#
    Wait Calibration For Specific State    RUNNING    cycle_index=6     cycle_interval=5min
    Wait Calibration For Specific State    COMPLETE    cycle_index=20    cycle_interval=10min
    ${out}    SSHLibrary.Write    pimc -rcdump 1 1
    ${out}    SSHLibrary.Read Until    \#
    ${match}    ${rtc_counter}    Should Match Regexp    ${out}    RTC counter = (\\d+)
    ${rtc_counter}    Convert To Integer    ${rtc_counter}
    should not be equal    ${rtc_counter}    ${0}
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Wait Calibration For Specific State
    [Arguments]    ${state}    ${cycle_index}=5    ${cycle_interval}=5min
    FOR    ${index}    IN RANGE    ${cycle_index}
        ${out}    SSHLibrary.Write    pimc -rcdump 1 1
        ${out}    SSHLibrary.Read Until    \#
        ${match}    ${runtime_calibrate_state}    Should Match Regexp    ${out}    runtime calibration State = (\\w+)
        ${runtime_calibrate_state}    Convert To String    ${runtime_calibrate_state}
        Exit For Loop If     "${runtime_calibrate_state}" == "${state}"
        Sleep    ${cycle_interval}
    END
    Should Be True    "${runtime_calibrate_state}" == "${state}"

Calibrate EPIMC FHS Enabled
    [Arguments]    ${bts_id}    ${fhs_serial_number}    ${connection}
    ${epimc_enabled}    Run Keyword And Return Status    Check Pim Parameters Value    ${bts_id}    ${fhs_serial_number}
    ...    exp_activation_flag=true    exp_enabling_flag=true
    ...    exp_calibration_status=calibrated    exp_operational_status=active_enabled
    Return From Keyword If    "${epimc_enabled}" == "True"
    ${out_dist_name}=    Get R Object Distname By SN    FHS_R    ${fhs_serial_number}    ${connection}
    Run keyword And Ignore Error    coam.calibrate_epimc_fhs    dist_name=${out_dist_name}    timeout=4800    connection=${connection}
    Wait Until Keyword Succeeds    60 min    1 min    Check Pim Parameters Value    ${bts_id}    ${fhs_serial_number}
    ...    exp_activation_flag=true    exp_enabling_flag=true
    ...    exp_calibration_status=calibrated    exp_operational_status=active_enabled

Online Set Epimc Parameters
    [Arguments]    ${epimc_dist_name}    ${exp_activation_flag}    ${exp_enabling_flag}    ${connection}
    coam.Create delta
    coam.append_parameter_update_to_delta    ${epimc_dist_name}    actExtPIMCancellation    ${exp_activation_flag}
    coam.append_parameter_update_to_delta    ${epimc_dist_name}    extPIMCancellingEnabled    ${exp_enabling_flag}
    ${delta_update}=    coam.Get delta
    coam.Perform delta recommissioning    ${delta_update}    timeout=600    connection=${connection}
    [Teardown]    coam.Remove delta

Get Specific Cells Info on AFAA
    [Arguments]   ${scfc_file_path}    ${fhs_serial_number}    ${rmod_distname}    ${antl_info}
    ${epimc_dist_name}    ${epimc_r_dist_name}    Get Epimc Distname    ${scfc_file_path}    ${fhs_serial_number}
    ${items}    Evaluate Xpath    ${scfc_file_path}    .//managedObject[@distName='${epimc_r_dist_name}']/list/item
    ${cells_info}    Create List
    FOR    ${item}    IN    @{items}
        ${targetedRadioDN}    Get Element    ${item}    p[@name='targetedRadioDN']/text()
        Continue For Loop If    '${targetedRadioDN}' != '${rmod_distname}'
        ${targetedCellDN}    Get Element    ${item}    p[@name='targetedCellDN']/text()
        ${pre_cell_id}    ${cell_id}    Split String From Right    ${targetedCellDN}    -    1
        ${targetedRXEarfcn}     Get Element    ${item}    p[@name='contributedTXEarfcn']/text()
        ${band}    earfcn.Get Band With Earfcn    ${targetedRXEarfcn}
        Append To List    ${cells_info}    ${antl_info}: LNCEL-${cell_id}(B${band})
    END
    [Return]    ${cells_info}

Check Calibration Results
    [Arguments]    ${scfc_file_path}    ${fhs_serial_number}    ${calibration_results}
    ${epimc_dist_name}    ${epimc_r_dist_name}    Get Epimc Distname    ${scfc_file_path}    ${fhs_serial_number}
    ${rmods_on_afaa}    Evaluate Xpath   ${scfc_file_path}
    ...    .//managedObject[@distName='${epimc_r_dist_name}']/list/item/p[@name='targetedRadioDN']/text()
    ${rmods_on_afaa}    Remove Duplicates    ${rmods_on_afaa}
    ${all_antls}    Evaluate Xpath    ${scfc_file_path}    .//managedObject[@class='com.nokia.srbts.eqmr:ANTL_R']/@distName
    ${epimc_affact_cells_info}    Create List
    FOR    ${antl_distname}    IN    @{all_antls}
        ${rmod_distname}    ${antl_r}    Split String From Right   ${antl_distname}    /    1
        Continue For Loop If    '${rmod_distname}' not in ${rmods_on_afaa}
        ${rxCapable}    Evaluate Xpath    ${scfc_file_path}    .//managedObject[@distName='${antl_distname}']/p[@name='rxCapable']/text()
        Continue For Loop If    '${rxCapable[0]}'=='false'
        ${productName}    Evaluate Xpath    ${scfc_file_path}    .//managedObject[@distName='${rmod_distname}']/p[@name='productName']/text()
        ${pre_rmod_r}    ${rmod_r}    Split String From Right    ${rmod_distname}    /    1
        ${antl}    Remove String    ${antl_r}    L_R-
        ${antl_info}    Set Variable    ${productName[0]} ${rmod_r} ${antl}
        ${cells_info_from_scfc}    Get Specific Cells Info on AFAA    ${scfc_file_path}    ${fhs_serial_number}    ${rmod_distname}    ${antl_info}
        Append To List    ${epimc_affact_cells_info}    @{cells_info_from_scfc}
    END
    ${measure_gain_values}    Create List    Not application    Expected gain    Low gain    No gain
    FOR    ${cr}     IN     @{calibration_results}
        ${cell_info}    ${measure_gain}    Split String From Right    ${cr}    :    1
        ${measure_gain}    Strip String    ${measure_gain}
        List Should Contain Value    ${epimc_affact_cells_info}    ${cell_info}
        Remove Values From List    ${epimc_affact_cells_info}    ${cell_info}
        List Should Contain Value    ${measure_gain_values}    ${measure_gain}
    END
    Should Be Empty    ${epimc_affact_cells_info}

FHS Should Be off With Admin
    [Arguments]    ${dist_name}    ${bts_id}
    ${current_SW_release}    Set Variable    ${NODE_CFG["${bts_id}"]["software_release"]}
    ${availability_status_notinstall}    Set Variable If    "${current_SW_release}"=="SBTS22R2"    NotInstalled    not installed
    ${fhs_r_info}    coam.get parameters    dist_name=${dist_name}    connection=${CASE_NAME}_${bts_id}
    ${opertional_state}    Convert To Lowercase    ${fhs_r_info["operationalState"]}
    Should Be Equal As Strings    ${opertional_state}    disabled
    Should Be Equal As Strings    ${fhs_r_info["availabilityStatus"]}    ${availability_status_notinstall}

FHS Should Be On With Admin
    [Arguments]    ${dist_name}    ${bts_id}
    ${fhs_r_info}    coam.get parameters    dist_name=${dist_name}    connection=${CASE_NAME}_${bts_id}
    ${opertional_state}    Convert To Lowercase    ${fhs_r_info["operationalState"]}
    Should Be Equal As Strings    ${opertional_state}    enabled

Get Rmod On AFAA
    [Arguments]    ${scfc_file_path}    ${fhs_serial_number}    ${connection}
    ${fhs_r_dist_name}    Get R Object Distname By SN    FHS_R    ${fhs_serial_number}    connection=${connection}
    ${out_rmod_path_list}    Evaluate Xpath   ${scfc_file_path}
    ...  .//managedObject[contains(p[@name='firstEndpointDN'], 'FHS_R')]/p[@name='secondEndpointDN']/text()
    ${out_rmod_ser_num_list}    Create List
    FOR    ${rmod_path}    IN    @{out_rmod_path_list}
         ${serial_number}    Evaluate Xpath   ${scfc_file_path}
         ...    .//managedObject[@distName='${rmod_path}']/p[@name='serialNumber']/text()
         Append To List    ${out_rmod_ser_num_list}    ${serial_number[0]}
    END
    [Return]    ${out_rmod_ser_num_list}

Get BBMOD of AFAA
    [Arguments]    ${scfc_file_path}    ${fhs_serial_number}
    Log    ${fhs_serial_number}
    ${out_bbmod_path}    Evaluate Xpath   ${scfc_file_path}
    ...  .//managedObject[contains(p[@name='secondEndpointDN'], 'FHS_R')]/p[@name='firstEndpointDN']/text()
    ${serial_number}    Evaluate Xpath   ${scfc_file_path}
    ...    .//managedObject[@distName='${out_bbmod_path[0]}']/p[@name='serialNumber']/text()
    [Return]    ${serial_number[0]}

AFAA Power off and on
    [Arguments]    ${fhs_serial_number}
    ${bts_id}    Get Bts Id with FHS Serial Number    ${fhs_serial_number}
    ${scfc_file_path}    Get Current Scfc    ${bts_id}
    ${epimc_dist_name}    ${epimc_r_dist_name}    Get Epimc Distname    ${scfc_file_path}    ${fhs_serial_number}
    ${fhs_r_dist_name}    Get R Object Distname By SN    FHS_R    ${fhs_serial_number}    connection=${CASE_NAME}_${bts_id}
    ${out_rmod_ser_num_list}    Get Rmod On AFAA    ${scfc_file_path}    ${fhs_serial_number}    connection=${CASE_NAME}_${bts_id}
    PDU Turn Off Unit    ${BTS_CONFIG['FHS']['${fhs_serial_number}']['pdu']['type']}
    ...                  ${BTS_CONFIG['FHS']['${fhs_serial_number}']['pdu']['ip_addr']}
    ...                  ${BTS_CONFIG['FHS']['${fhs_serial_number}']['pdu']['port']}
    coam.assert_alarm_active    parameters=faultId=10, configObjectName=[BTS${bts_id}] ${epimc_dist_name}
    ...    timeout=120    connection=${CASE_NAME}_${bts_id}
    FHS Should Be off With Admin    ${fhs_r_dist_name}    ${bts_id}
    FOR    ${fr_serial_number}    IN    @{out_rmod_ser_num_list}
         Radio Should Be Off    ${fr_serial_number}    ${bts_id}
         coam.assert_alarm_active    parameters=faultId=10, serialNo=${fr_serial_number}    timeout=180    connection=${CASE_NAME}_${bts_id}
    END
    Sleep    30 sec
    PDU Turn On Unit     ${BTS_CONFIG['FHS']['${fhs_serial_number}']['pdu']['type']}
    ...                  ${BTS_CONFIG['FHS']['${fhs_serial_number}']['pdu']['ip_addr']}
    ...                  ${BTS_CONFIG['FHS']['${fhs_serial_number}']['pdu']['port']}
    Wait Until Keyword Succeeds    30 min    1 min    FHS Should Be On With Admin    ${fhs_r_dist_name}    ${bts_id}
    FOR    ${fr_serial_number}    IN    @{out_rmod_ser_num_list}
        Radio Should Be On    ${fr_serial_number}    ${bts_id}
    END
    [Teardown]    Run Keyword If    "${KEYWORD STATUS}"=="FAIL"
    ...    PDU Turn On Unit    ${BTS_CONFIG['FHS']['${fhs_serial_number}']['pdu']['type']}
    ...                        ${BTS_CONFIG['FHS']['${fhs_serial_number}']['pdu']['ip_addr']}
    ...                        ${BTS_CONFIG['FHS']['${fhs_serial_number}']['pdu']['port']}

Get Topo Dict
    [Arguments]    ${connection}    ${fhs}=${False}
    ${cablink_r_list}    coam.get_managed_objects    class_name=CABLINK_R    connection=${connection}
    ${rmod_r_list}    coam.get_managed_objects    class_name=RMOD_R    connection=${connection}
    ${smod_r_list}    coam.get_managed_objects    class_name=SMOD_R    connection=${connection}
    ${bbmod_r_list}    coam.get_managed_objects    class_name=BBMOD_R    connection=${connection}
    ${fhs_r_list}    Run Keyword If    ${fhs}    coam.get_managed_objects    class_name=FHS_R    connection=${connection}
    ${topo_dict}    get_current_topo    ${cablink_r_list}    ${rmod_r_list}    ${bbmod_r_list}    ${smod_r_list}    ${fhs_r_list}
    [Return]    ${topo_dict}

Cell Should Have Disabled And Enabled State
    [Arguments]    ${bts_id}
    ${enabled_cell_count}    Set Variable    ${0}
    ${cell_count}    Set Variable    ${0}
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${cell_count}    Evaluate    ${cell_count}+1
        Continue For Loop If    "${cell_info['btsId']}" != "${bts_id}"
        ${cell_R_info}    coam.Get Cell Specific Info    cell_id=${cell_info["distName"]}    connection=${CASE_NAME}_${bts_id}
        ${operational_state}    Convert To Lowercase    ${cell_R_info["status"]["operationalState"]}
        ${status}    Run Keyword And Return Status    Should Be Equal As Strings  ${operational_state}   enabled
        ${enabled_cell_count}    Run Keyword If    ${status}    Evaluate    ${enabled_cell_count}+1
        ...    ELSE    Set Variable    ${enabled_cell_count}
    END
    Should Not Be Equal As Integers    ${enabled_cell_count}    ${0}
    Should Not Be Equal As Integers    ${cell_count}    ${enabled_cell_count}

Radios Should Be off With Admin
    [Arguments]    ${fr_sn_list}    ${bts_id}
    FOR    ${fr_serial_number}    IN    @{fr_sn_list}
        Radio Should Be Off    ${fr_serial_number}    ${bts_id}
        coam.assert_alarm_active    parameters=faultId=10, serialNo=${fr_serial_number}    timeout=180    connection=${CASE_NAME}_${bts_id}
    END

AFAA and RRUs Fibers Remove Insert One Node
    [Arguments]    ${fr_serial_number_list}    ${bts_id}
    ${connection}    Set Variable    ${CASE_NAME}_${bts_id}
    ${fw_info}    Set Variable    ${tl_config.FW_INFO}
    ${topo_dict}    Get Topo Dict    connection=${connection}    fhs=${True}
    ${all_links}    Set Variable
    ${all_break_links}    Set Variable
    FOR    ${fr_sn}    IN    @{fr_serial_number_list}
        ${fiber_link}    Get From Dictionary    ${FW_INFO}    ${fr_sn}
        ${fiber_port}    Get Dictionary Keys    ${fiber_link}
        ${fiber_count}    Get Length    ${fiber_port}
        ${primary_fiber_link}    ${link_speed}    get_selected_link    ${topo_dict}    ${tl_config.FW_INFO}
        ...    filters=${fr_sn}    link=primary
        ${secondary_fiber_link}    ${link_speed}    Run Keyword If    ${fiber_count} > 1    get_selected_link
        ...    ${topo_dict}    ${tl_config.FW_INFO}    filters=${fr_sn}    link=secondary
        ${all_links}    Catenate    SEPARATOR=;    ${all_links}    ${primary_fiber_link}
        ${all_links}    Run Keyword If    ${fiber_count} > 1    Catenate    SEPARATOR=;    ${all_links}    ${secondary_fiber_link}
        ...    ELSE    Set Variable    ${all_links}
        Break Link    ${fw_info["IP"]}    ${fw_info["USERNAME"]}    ${fw_info["PASSWORD"]}    ${primary_fiber_link}    FW_type=${fw_info["TYPE"]}
        Run Keyword If    ${fiber_count} > 1    Break Link    ${fw_info["IP"]}    ${fw_info["USERNAME"]}    ${fw_info["PASSWORD"]}
        ...    ${secondary_fiber_link}    FW_type=${fw_info["TYPE"]}
        Run Keyword And Continue On Failure    Radio Should Be Off    ${fr_sn}    ${bts_id}
        Run Keyword And Continue On Failure    coam.assert_alarm_active    parameters=faultId=10, serialNo=${fr_sn}
        ...    timeout=20    connection=${connection}
    END
    ${all_break_links}    Strip String    ${all_links}    characters=;
    ${fr_sn_list}    Create List    @{NODE_CFG["${bts_id}"]["fr_sn_list"]}
    Remove Values From List    ${fr_sn_list}    @{fr_serial_number_list}
    FOR    ${fr_sn}    IN    @{fr_sn_list}
        Check Cells State On Specific FR    ${fr_sn}     enabled
    END
    @{mandatory_fault10}    Create List    ${fault_10}
    Admin Alarms Get And Check    ${GLO_ADMIN_ALLOWED_ALARM}    ${mandatory_fault10}   alias=${connection}
    Connect Link    ${fw_info["IP"]}    ${fw_info["USERNAME"]}    ${fw_info["PASSWORD"]}    ${all_break_links}    FW_type=${fw_info["TYPE"]}
    Wait For All Cells OnAir
    Admin Alarms Get And Check    ${GLO_ADMIN_ALLOWED_ALARM}   alias=${connection}
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}'=='FAIL'    Run Keyword And Ignore Error    Connect Link    ${fw_info["IP"]}
        ...    ${fw_info["USERNAME"]}    ${fw_info["PASSWORD"]}    ${all_break_links}    FW_type=${fw_info["TYPE"]}

Hot remove insert fibers between AFAA and RRUs
    [Arguments]    ${fr_serial_numbers}=${FRs_UNDER_TEST_SERIAL_NUMBER}    ${make_call}=False
    ...    ${required_cells}=${EMPTY}
    ${fr_serial_numbers}    Evaluate    ${fr_serial_numbers}
    Set Test Variable    ${fr_serial_numbers}
    ${bts_id_list}    Get Dictionary Keys    ${fr_serial_numbers}
    FOR    ${bts_id}    IN    @{bts_id_list}
        ${fr_sn_list}    Get From Dictionary    ${fr_serial_numbers}    ${bts_id}
        AFAA and RRUs Fibers Remove Insert One Node    ${fr_sn_list}    ${bts_id}
    END
    Run Keyword If    "${make_call}"=="True"    Make L3Call    required_cells=${required_cells}
    Check Historical Alarms    additional_allowed_alarms=No connection to unit:Failure in optical interface
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

Hot remove insert fibers between AFAA and BBU
    [Arguments]    ${make_call}=False    ${required_cells}=${EMPTY}
    FOR    ${fhs_serial_number}    IN    @{USED_FHS_SN_LIST}
        ${bts_id}    Get Bts Id with FHS Serial Number    ${fhs_serial_number}
        ${connection}    Set Variable    ${CASE_NAME}_${bts_id}
        ${scfc_file_path}    Get Current Scfc    ${bts_id}
        ${epimc_dist_name}    ${epimc_r_dist_name}    Get Epimc Distname    ${scfc_file_path}    ${fhs_serial_number}
        ${fhs_r_dist_name}    Get R Object Distname By SN    FHS_R    ${fhs_serial_number}    connection=${connection}
        ${rmod_affa_ser_num_list}    Get Rmod On AFAA    ${scfc_file_path}    ${fhs_serial_number}    connection=${connection}
        ${bbmod_affa_ser_num}    Get BBMOD of AFAA    ${scfc_file_path}    ${fhs_serial_number}
        ${fw_info}    Set Variable    ${tl_config.FW_INFO}
        ${topo_dict}    Get Topo Dict    ${connection}    fhs=${True}
        ${primary_fiber_link}    ${link_speed}    get_selected_link    ${topo_dict}    ${tl_config.FW_INFO}
        ...    filters=${bbmod_affa_ser_num}    link=primary
        ${secondary_fiber_link}    ${link_speed}    get_selected_link    ${topo_dict}    ${tl_config.FW_INFO}
        ...    filters=${bbmod_affa_ser_num}    link=secondary
        @{allowed}    Create List    @{GLO_ADMIN_ALLOWED_ALARM}
        ...    Receiving failure in Optical Interface    Not able to synchronize baseband bus
        ...    BTS config error .*
        Break Link    ${fw_info["IP"]}    ${fw_info["USERNAME"]}    ${fw_info["PASSWORD"]}    ${secondary_fiber_link}    FW_type=${fw_info["TYPE"]}
        coam.assert_alarm_active    parameters=faultId=regex"1815|2002"    timeout=500    connection=${connection}
        Wait Until Keyword Succeeds    15 min    30 sec    Cell Should Have Disabled And Enabled State    ${bts_id}
        Admin Alarms Get And Check    ${allowed}    alias=${connection}
        Connect Link    ${fw_info["IP"]}    ${fw_info["USERNAME"]}    ${fw_info["PASSWORD"]}    ${secondary_fiber_link}    FW_type=${fw_info["TYPE"]}
        Wait For All Cells OnAir
        Admin Alarms Get And Check    ${GLO_ADMIN_ALLOWED_ALARM}   alias=${connection}
        Break Link    ${fw_info["IP"]}    ${fw_info["USERNAME"]}    ${fw_info["PASSWORD"]}    ${primary_fiber_link}    FW_type=${fw_info["TYPE"]}
        coam.assert_alarm_active    parameters=faultId=10, configObjectName=[BTS${bts_id}] ${epimc_dist_name}
        ...    timeout=120    connection=${CASE_NAME}_${bts_id}
        FHS Should Be off With Admin    ${fhs_r_dist_name}    ${bts_id}
        Radios Should Be off With Admin    ${rmod_affa_ser_num_list}    ${bts_id}
        @{mandatory_fault10}    Create List    ${fault_10}
        Admin Alarms Get And Check    ${GLO_ADMIN_ALLOWED_ALARM}    ${mandatory_fault10}   alias=${connection}
        coam.assert_alarm_inactive    parameters=faultId=10    timeout=1000     connection=${connection}
        coam.assert_alarm_active    parameters=faultId=regex"1815|2002"    timeout=500    connection=${connection}
        Wait Until Keyword Succeeds    15 min    30 sec    Cell Should Have Disabled And Enabled State    ${bts_id}
        Admin Alarms Get And Check    ${allowed}        alias=${connection}
        Connect Link    ${fw_info["IP"]}    ${fw_info["USERNAME"]}    ${fw_info["PASSWORD"]}    ${primary_fiber_link}    FW_type=${fw_info["TYPE"]}
        Wait For All Cells OnAir
        Admin Alarms Get And Check    ${GLO_ADMIN_ALLOWED_ALARM}   alias=${connection}
        Run Keyword If    "${make_call}"=="True"    Make L3Call    required_cells=${required_cells}
    END
    Check Historical Alarms    additional_allowed_alarms=${FID10_NAME}:${FID3030_NAME}:${FID2002_NAME}:${FID1868_NAME}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}'=='FAIL'    Run Keyword And Ignore Error    Connect Link    ${fw_info["IP"]}
        ...    ${fw_info["USERNAME"]}    ${fw_info["PASSWORD"]}    ${primary_fiber_link};${secondary_fiber_link}    FW_type=${fw_info["TYPE"]}

AFAA_Epimc_Calibrate_Functional_Verification
    [Arguments]    ${make_call}=${False}    ${required_cells}=${EMPTY}
    FOR    ${fhs_serial_number}    IN    @{USED_FHS_SN_LIST}
        ${bts_id}    Get Bts Id with FHS Serial Number    ${fhs_serial_number}
        ${connection}    Set Variable    ${CASE_NAME}_${bts_id}
        Check Pim Parameters Value    ${bts_id}    ${fhs_serial_number}
        ...    exp_activation_flag=false    exp_enabling_flag=false
        ...    exp_calibration_status=none    exp_operational_status=inactive
        Verify All Cells OnAir
        ${scfc_file_path}    Get Current Scfc    ${bts_id}
        ${epimc_dist_name}    ${epimc_r_dist_name}    Get Epimc Distname    ${scfc_file_path}    ${fhs_serial_number}
        Online Set Epimc Parameters    ${epimc_dist_name}   exp_activation_flag=true    exp_enabling_flag=true    connection=${connection}
        Verify All Cells OnAir
        coam.assert_alarm_active    parameters=faultId=4549, configObjectName=[BTS${bts_id}] ${epimc_dist_name}
        ...    timeout=120    connection=${connection}
        Check Pim Parameters Value    ${bts_id}    ${fhs_serial_number}
        ...    exp_activation_flag=true    exp_enabling_flag=true
        ...    exp_calibration_status=need_calibration    exp_operational_status=active_disabled
        ${out_dist_name}=    Get R Object Distname By SN    FHS_R    ${fhs_serial_number}    ${connection}
        ${calibration_results}    coam.calibrate_epimc_fhs    dist_name=${out_dist_name}    timeout=4800    connection=${connection}
        Wait Until Keyword Succeeds    15 min    1 min    Check Pim Parameters Value    ${bts_id}    ${fhs_serial_number}
        ...    exp_activation_flag=true    exp_enabling_flag=true
        ...    exp_calibration_status=calibrated    exp_operational_status=active_enabled
        ${scfc_file_path}    Get Current Scfc    ${bts_id}
        Check Calibration Results    ${scfc_file_path}    ${fhs_serial_number}    ${calibration_results}
        Check Multinode Without Unexpect Alarm
        Verify All Cells OnAir
    END
    Run Keyword If    ${make_call}    Make L3Call    required_cells=${required_cells}
    Check Historical Alarms    additional_allowed_alarms=External PIM Calibration Needed:Calibration Ongoing
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

AFAA_support_for_UHLB_UHLC_with_old_FirmWare_version
    [Documentation]    ${FACTORY_LOAD_RADIOS}={"bts_id": [fr_sn_list]}
    ${factory_load_radios}    Evaluate    ${FACTORY_LOAD_RADIOS}
    Set Test Variable    ${factory_load_radios}
    ${bts_id_list}    Get Dictionary Keys    ${factory_load_radios}
    FOR    ${bts_id}    IN    @{bts_id_list}
        RU_Support_for_old_FirmWare_version    ${bts_id}
    END
    Check Historical Alarms    additional_allowed_alarms=Incompatible SW version detected:No connection to unit:Failure in optical interface
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0

AFAA_Epimc_Runtime_Calibrate_Verification
    FOR    ${fhs_serial_number}    IN    @{USED_FHS_SN_LIST}
        ${bts_id}    Get Bts Id With FHS Serial Number    ${fhs_serial_number}
        ${fhs_ip}    Get FHS IP    ${fhs_serial_number}
        ${scfc_file_path}    Get Current Scfc    ${bts_id}
        Calibrate EPIMC FHS Enabled    ${bts_id}    ${fhs_serial_number}    connection=${CASE_NAME}_${bts_id}
        Online Set RTC Relevant Parameters    ${scfc_file_path}    ${fhs_serial_number}    connection=${CASE_NAME}_${bts_id}
        RTC Trigger Check    ${NODE_CFG["${bts_id}"]["host_ip"]}    ${fhs_ip}
    END
    Check Historical Alarms    additional_allowed_alarms=Calibration Ongoing
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=1

Automated SiSo Operational AFAA power off then on
    [Arguments]    ${make_call}=${False}    ${required_cells}=${EMPTY}
    FOR    ${fhs_serial_number}    IN    @{USED_FHS_SN_LIST}
        AFAA Power off and on    ${fhs_serial_number}
    END
    Wait For All Cells OnAir    timeout=2 min
    Check Multinode Without Unexpect Alarm
    Run Keyword If    ${make_call}    Make L3Call    required_cells=${required_cells}
    Check Historical Alarms    additional_allowed_alarms=${FID10_NAME}:${FID3030_NAME}:${FID1956_NAME}
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
