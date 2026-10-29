*** Settings ***
Library    XML    use_lxml=True    WITH NAME    Myxml
Library    ../lib/CB007308.py

Documentation
...    author: Ren zhenzhen
...    contact: zhenzhen.ren@nokia-sbell.com
...    squad group: SG_08
...    feature : CB007308:5GC002452&5GC000614

*** Variables ***

@{compliance_Code_list}        SFF_8472_REV_9_3  SFF_8472_REV_9_5  SFF_8472_REV_10_2  SFF_8472_REV_10_4  SFF_8472_REV_11_0
                        ...    SFF_8636_REV_2_7   SFF_8472_REV_11_3  SFF_8472_REV_11_4  SFF_8472_REV_12_3  SFF_8472_REV_12_4
                        ...    SFF_8636_REV_2_5,2_6,2_7  UNKNOWN    N/A    0
@{vendor_list}           FINISAR CORP.    FINISAR CORP    SOURCEPHOTONICS    WTD    HG GENUINE    NOKIA     WTD:NOKIA
@{txPower_list}          None    N/A    ${None}    -
@{params}                miNrSfpBbmod    miNrSfpRmod    miNrSfpSmod

*** Keywords ***

SFP parameter preparation
    [Documentation]    Author: zhenzhen.ren@nokia-sbell.com
    [Arguments]   ${dist_name}=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1    ${new_value}=15min
    log to console    ******trun on SFP parameter********
    COAM Navigate to login page via webUI
    Close Start Up View    timeout=60
    ${current_value_RMOD}    selenium_coam.get_parameter_value    dist_name=${dist_name}
	...    filter_param=SBTS SFP RMOD monitoring
    run keyword if  not '${current_value_RMOD}'=='${new_value}'
    ...    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=SBTS SFP RMOD monitoring
    ...    new_value=${new_value}
    ${current_value_SMOD}    selenium_coam.get_parameter_value    dist_name=${dist_name}
	...    filter_param=SBTS SFP SMOD Monitoring
    run keyword if  not '${current_value_SMOD}'=='${new_value}'
    ...    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=SBTS SFP SMOD Monitoring
    ...    new_value=${new_value}
    ${flag}    checkflag     rmod=${current_value_RMOD}     smod=${current_value_SMOD}    newvalue=${new_value}
    run keyword if    ${flag}==0    selenium_coam.validate_plan
    run keyword if    ${flag}==0    activate_plan_despite_errors=${True}
    sleep    15min
    [Teardown]    Selenium Logout And Close Browser


Check if dynamic parameters have a valid value for ports
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check dynamic parameters
     ...    and return it in dictionary to compare whether are refreshed
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    &{dynamic_port}=    Create Dictionary
    FOR    ${port}    IN    @{list_of_links}
        ${dynamic_direction}=    Check if dynamic parameters have a valid value for directions   links=${links}
    ...    dict_of_links=${dict_of_links}    port=${port}
        Set To Dictionary    ${dynamic_port}    ${port}    ${dynamic_direction}
    END
    [Return]    ${dynamic_port}


Check if dynamic parameters have a valid value for directions
   [Documentation]
    ...     This keyword make a for loop to select a proper direction to check dynamic parameters and return it in dictionary
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    &{dynamic_direction}=    Create Dictionary
    @{list_of_dynamic_params}=    Create List
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Run Keyword If   '${direction}'=='source'    Set Suite Variable    ${initial_direction}    initialSource
        Run Keyword If   '${direction}'=='destination'    Set Suite Variable    ${initial_direction}    initialDestination
        Set Suite Variable   ${moduleTemperature}
    ...    ${links["connected"][${port}]["data"]["measurements"]["moduleTemperature"]["${direction}"]}
        Should Be True  20<=${moduleTemperature}<=65
        Set Suite Variable   ${TXSupplyVoltage}
    ...    ${links["connected"][${port}]["data"]["measurements"]["TXSupplyVoltage"]["${direction}"]}
        Should Be True  2000<=${TXSupplyVoltage}<=4500
        Set Suite Variable   ${TXBiasCurrent}
    ...    ${links["connected"][${port}]["data"]["measurements"]["TXBiasCurrent"]["${direction}"][0]}
        Should Be True  0<=${TXBiasCurrent}<=50
        Set Suite Variable   ${TXOpticalPower}
    ...    ${links["connected"][${port}]["data"]["measurements"]["TXOpticalPower"]["${initial_direction}"][0]}
        Should Be True  300<=${TXOpticalPower}<=2000
        Set Suite Variable   ${RXOpticalPower}
    ...    ${links["connected"][${port}]["data"]["measurements"]["RXOpticalPower"]["${initial_direction}"][0]}
        Should Be True    100<=${RXOpticalPower}<=2000
        Append To List    ${list_of_dynamic_params}    ${moduleTemperature}    ${TXSupplyVoltage}
    ...    ${TXBiasCurrent}    ${RXOpticalPower}
    ...    ${TXBiasCurrent}    ${TXOpticalPower}    ${RXOpticalPower}
        Set To Dictionary    ${dynamic_direction}    ${direction}    ${list_of_dynamic_params}
    END
    [Return]    ${dynamic_direction}



Check if Tx parameters have a valid value for ports
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if Tx parameters have a valid value for directions   links=${links}    dict_of_links=${dict_of_links}    port=${port}
    END


Check if Tx parameters have a valid value for directions
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check Tx parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${txPowerHighAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighAlarmThreshold"]["${direction}"]}
        Should Be True  -100<=${txPowerHighAlarmThreshold}<=100
        Set Suite Variable   ${txPowerLowAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerLowAlarmThreshold"]["${direction}"]}
        Should Be True  -100<=${txPowerLowAlarmThreshold}<=100
        Set Suite Variable   ${txPowerHighWarnThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerHighWarnThreshold"]["${direction}"]}
        Should Be True  -100<=${txPowerHighWarnThreshold}<=100
        Set Suite Variable   ${txPowerLowWarnThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["txPowerLowWarnThreshold"]["${direction}"]}
        Should Be True  -100<=${txPowerLowWarnThreshold}<=100
    END



Get snapshot and return RD files
    [Arguments]  ${connection}=GNB_OAM
    ${time}=    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    set suite variable    ${snapshot_path}    /home/ute/Downloads/s${time}/Snapshot_${time}.zip
    set suite variable    ${unzipped}    /home/ute/Downloads/s${time}
    set suite variable    ${unzipped_PM}    ${unzipped}/PM
    coam.get_snapshot    target_file_name=${snapshot_path}   timeout=480    connection=${connection}
    OperatingSystem.Run    unzip ${snapshot_path} -d ${unzipped}
    ${PM_file}    Get snapshot part of RD files    /home/ute/Downloads/s${time}
    OperatingSystem.Run    unzip ${unzipped}/${PM_file} -d ${unzipped_PM}
    ${RD_files}=    OperatingSystem.Run    ls ${unzipped_PM} | grep RD.BTS
    @{RD_files_list}=    Split String    ${RD_files}    \n
    ${parsed_files_list}=    Extract and parsed RD file    RD_files_list=${RD_files_list}    unzipped_PM=${unzipped_PM}
    [Return]     ${parsed_files_list}


Extract and parsed RD file
    [Arguments]    ${RD_files_list}    ${unzipped_PM}
    ${parsed_files_list}    Create List
    FOR    ${file}    IN    @{RD_files_list}
        Run    gzip -d ${unzipped_PM}/${file}
        ${extracted_file}    Fetch From Left    ${file}    .gz
        ${parsed_files}    Myxml.Parse Xml    ${unzipped_PM}/${extracted_file}
        Append To List    ${parsed_files_list}    ${parsed_files}
    END
    [Return]    ${parsed_files_list}


Get snapshot part of RD files
    [Arguments]  ${file_path}
    ${output}    evaluate    '${file_path}/snapshot_file_list.txt'
    log to console    ${output}
    ${part}    get_part_id    ${output}
    [Return]     ${part}


Check counters from SFP monitoring- file iteration_2452
    [Arguments]    ${parsed_files}    ${MOD_SFP_dict}    ${measurementType}    ${SBTSmeasT}
    FOR    ${file}    IN    @{parsed_files}
        ${MOD_list}    Get Dictionary Keys    ${MOD_SFP_dict}
        Check counters from SFP monitoring- MOD iteration_2452    MOD_SFP_dict=${MOD_SFP_dict}    MOD_list=${MOD_list}
    ...    file=${file}    measurementType=${measurementType}    SBTSmeasT=${SBTSmeasT}
    END


Check counters from SFP monitoring- MOD iteration_2452
    [Arguments]    ${MOD_SFP_dict}    ${MOD_list}    ${file}    ${measurementType}    ${SBTSmeasT}
    FOR    ${MOD}    IN    @{MOD_list}
        @{SFP_list}    Get From Dictionary    ${MOD_SFP_dict}    ${MOD}
        Check counters from SFP monitoring- SFP iteration_2452    MOD_SFP_dict=${MOD_SFP_dict}    MOD=${MOD}    file=${file}
    ...    measT=${measurementType}    SFP_list=${SFP_list}    SBTSmeasT=${SBTSmeasT}
    END


Check counters from SFP monitoring- SFP iteration_2452
    [Documentation]    author: Bangzheng.Wan
    [Arguments]    ${MOD_SFP_dict}    ${MOD}    ${file}    ${measT}    ${SFP_list}    ${SBTSmeasT}
    FOR    ${SFP}    IN    @{SFP_list}
#        ${SFP}    check_sfp    sfp_wr=${SFP}    modinfo=${MOD}
        @{TEMPERATURE_LIST}    Myxml.Get Elements Texts    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${SBTSmeasT}_TEMPERATURE
        @{XCVR_TX_SUPPLY_VOLTAGE_LIST}   Myxml.Get Elements Texts    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${SBTSmeasT}_XCVR_TX_SUPPLY_VOLTAGE
        @{XCVR_TX_BIAS_CURRENT_LIST}    Myxml.Get Elements Texts    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${SBTSmeasT}_XCVR_TX_BIAS_CURRENT
        @{XCVR_TX_PWR_LIST}    Myxml.Get Elements Texts    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${SBTSmeasT}_XCVR_TX_PWR
        @{XCVR_RX_OPT_PWR_LIST}   Myxml.Get Elements Texts    ${file}
    ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${SBTSmeasT}_XCVR_RX_OPT_PWR
        Check Value Not Empty And In Scope    Value_list=${TEMPERATURE_LIST}    min=-128    max=128
        Check Value Not Empty And In Scope    Value_list=${XCVR_TX_SUPPLY_VOLTAGE_LIST}     min=0    max=100
        Check Value Not Empty And In Scope And small Than Max    Value_list=${XCVR_TX_BIAS_CURRENT_LIST}    min=0    max=1000
        Check Value Not Empty And In Scope    Value_list=${XCVR_TX_PWR_LIST}    min=-100    max=100
        Check Value Not Empty And In Scope    Value_list=${XCVR_RX_OPT_PWR_LIST}    min=-100    max=100
    END


Check Value Not Empty And In Scope
    [Arguments]    ${Value_list}    ${min}    ${max}
    ${length}    Get Length    ${Value_list}
    Should Be True    ${length} > 0
    FOR    ${Value}    IN    @{Value_list}
        Should Be True    ${min}<=${Value}<=${max}
    END


Check Value Not Empty And In Scope And small Than Max
    [Arguments]    ${Value_list}    ${min}    ${max}
    ${length}    Get Length    ${Value_list}
    Should Be True    ${length} > 0
    FOR    ${Value}    IN    @{Value_list}
        Should Be True    ${min}<=${Value}<${max}
    END


Get Certain RMOD_SFP_Dict
    [Documentation]    the value of ${MOD_type} should be in the list of [BBMOD, RMOD]
    ...    author: Zhenzhen.Ren
    [Arguments]    ${SFP_dict}    ${MOD_Seq}=1    ${MOD_type}=BBMOD
    ${MOD_SFP}     Create Dictionary
    ${MOD_key_list}    Get Dictionary Keys    ${SFP_dict}
    FOR    ${MOD_key}    IN    @{MOD_key_list}
        ${MOD_key_split}    Split String    ${MOD_key}     /
        ${result}    Run Keyword And Ignore Error    Should contain    ${MOD_key_split}    ${MOD_type}-${MOD_Seq}
        Continue For Loop If    '${result[0]}'=='FAIL'
        ${BBMOD_value}    Get From Dictionary    ${SFP_dict}    ${MOD_key}
        Set To Dictionary   ${MOD_SFP}    ${MOD_key}=${BBMOD_value}
    END
    [Return]    ${MOD_SFP}


Check if temperature parameters have a valid value for ports
    [Documentation]
    ...     This keyword make a for loop to select a proper link to check static parameters
    [Arguments]    ${links}    ${dict_of_links}
    ${list_of_links}    Get Dictionary Keys    ${dict_of_links}
    FOR    ${port}    IN    @{list_of_links}
        Check if temperature parameters have a valid value for directions   links=${links}    dict_of_links=${dict_of_links}
    ...    port=${port}
    END


Check if temperature parameters have a valid value for directions
    [Documentation]
    ...     This keyword make a for loop to select a proper direction to check static parameters
    [Arguments]    ${links}    ${dict_of_links}    ${port}
    ${list_of_directions}=    Get From Dictionary    ${dict_of_links}    ${port}
    FOR    ${direction}    IN    @{list_of_directions}
        Set Suite Variable   ${temperatureHighAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["temperatureHighAlarmThreshold"]["${direction}"]}
        Should Be True  -128<=${temperatureHighAlarmThreshold}<=128
        Set Suite Variable   ${temperatureLowAlarmThreshold}
    ...    ${links["connected"][${port}]["details"]["thresholds"]["temperatureLowAlarmThreshold"]["${direction}"]}
        Should Be True  -128<=${temperatureLowAlarmThreshold}<=128
    END



Get SMODs info
    [Arguments]  ${connection}=GNB_OAM
    ${hw_info}   coam.get_detected_hw_info    connection=${connection}    timeout=20
    ${smod_info}   Create Dictionary
    FOR    ${smod}   IN   @{hw_info['systemModules']}
        ${SFP}=    Get SMOD SFP info
#        Continue For Loop If    '${smod['status']['usageState']}'=='Idle'
        Set To Dictionary   ${smod_info}    ${smod['id']['configuration']}=${SFP}
    END
    [Return]   ${smod_info}


Get SMOD SFP info
    [Documentation]  Note:this keyword is only suitable for single SMOD
    ...    author: zhenzhen.ren
    [Arguments]    ${connection}=GNB_OAM
    ${scf_file_path}     Set Variable     ${unzipped}/runtime.xml
    coam.collect_scf    target_file_name=${scf_file_path}    export_type=runtimeObjects    connection=${connection}
    @{RF_ports}    Myxml.Get Elements Texts    ${scf_file_path}    .//p[@name="physicalPort"]
    ${sfplist}    get_sfp_info    portlist=${RF_ports}
    log to console    ${sfplist}
    [Return]    ${sfplist}

Get Certain SMOD_SFP_Dict
    [Documentation]    the value of ${MOD_type} should be in the list of [SMOD, RMOD]
    ...    author: Bangzheng.Wan
    [Arguments]    ${SFP_dict}    ${MOD_Seq}=1    ${MOD_type}=SMOD
    ${MOD_SFP}     Create Dictionary
    ${MOD_key_list}    Get Dictionary Keys    ${SFP_dict}
    FOR    ${MOD_key}    IN    @{MOD_key_list}
        ${MOD_key_split}    Split String    ${MOD_key}     /
        ${result}    Run Keyword And Ignore Error    Should contain    ${MOD_key_split}    ${MOD_type}-${MOD_Seq}
        Continue For Loop If    '${result[0]}'=='FAIL'
        ${SMOD_value}    Get From Dictionary    ${SFP_dict}    ${MOD_key}
        Set To Dictionary   ${MOD_SFP}    ${MOD_key}=${SMOD_value}
    END
    [Return]    ${MOD_SFP}
