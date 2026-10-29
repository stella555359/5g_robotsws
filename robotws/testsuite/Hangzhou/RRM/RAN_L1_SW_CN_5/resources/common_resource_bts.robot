*** Settings ***
Documentation    Common resource about bts operation
Library           ./python/sftp_service.py
Library           ./python/coam_gnb_classical.py
Library           ./python/swconfig_update.py

*** Variables ***
${gNB_IP_MPLANE_LOCAL}    192.168.255.129
${gNB_MPLANE_IF_PORT}    443
${close_start-up_view}    ${False}

*** Keywords ***
########################################################################
##                           bts connection                           ##
########################################################################

ADMIN CLI connection
    [Documentation]    Common keyword to established connection with ADMIN API of tested gNB
    Wait until keyword succeeds    3x    20s    sbts_admin.connect_to    bts_host=${gNB_IP_MPLANE_LOCAL}    bts_port=${gNB_MPLANE_IF_PORT}
    Log to console    \n[INFO]:ADMIN is connected successfully

ADMIN CLI disconnection
    [Documentation]    Disconnects connection to gNB ADMIN
    sbts_admin.teardown
    Log to console    \n[INFO]:ADMIN is disconnection

WebUI connection
    [Arguments]    ${alias}
    _Get version for IQ capture
    selenium_coam.Enable Virtual Display    width=2220    height=1580
    Wait until keyword succeeds    3x    20s    selenium_coam.Login
    ...    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    download_dir=${SUITE_LOG_DIRECTORY}
    # ...    browser=Chrome
    ...    version=${version}
    ...    alias=${alias}
    selenium_coam.disable_screen_lock    sbts=${alias}
    selenium_coam.Disable Message Box    sbts=${alias}

WebUI disconnection
    [Arguments]    ${alias}
    _close startup-up view
    selenium_coam.Logout    sbts=${alias}
    selenium_coam.disable_virtual_display

#########################################################################
##                             get build info                          ##
#########################################################################
get L3 sw version
    ${active_sw}=    sbts_admin.get_sw_version
    Log    INFO:activeBuildVersion=${active_sw}    console=true
    Set Test Variable    ${active_sw}
    [Return]    ${active_sw}

get loki l1sw version
    [Arguments]    ${loki_ip}=fsp1s1icom    ${file}=${SUITE_LOG_DIRECTORY}${/}l1sw_version.txt
    ${l1sw_version}=    get_l1sw_version    ${loki_ip}    ${file}
    Log to console    \n[INFO]:L1sw version is ${l1sw_version}
    [Return]    ${l1sw_version}

Get L3 build from TargetBD file
    ${cmd}    Set Variable   sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 cat /ffs/run/TargetBD_*.xml | grep swReleaseVersionPackageName
    ${output}    Run    ${cmd}
    ${status}    ${match_group_PackageName}    Should Match Regexp    ${output}    swReleaseVersionPackageName="([^"]*)
    ${PackageName}    Set Variable    ${match_group_PackageName.split('_release')[0]}
    Log    INFO:TargetBD::swReleaseVersionPackageName=${PackageName}    console=true
    ${status}    ${match_group_VersionName}    Should Match Regexp    ${output}    swReleaseVersionName="([^"]*)
    Set Suite Variable    ${active_sw}    ${match_group_VersionName}
    Log    INFO:activeBuildVersion=${active_sw}    console=true
    ${build_info_dict}    Create Dictionary    PackageName=${PackageName}    VersionName=${active_sw}
    [Return]    ${build_info_dict}

#########################################################################
##                    modify and Full commission scf                   ##
#########################################################################
Full Commission gNB SCFC and wait for onair
    [Arguments]    ${scf_file}    ${reportingIntervalPm}=15min    ${timeout}=300
    [Documentation]    Perform gNB Full Commissioning
    Log To Console    \n[INFO] Perform full commissioning ... ...
    # SCF modification #
    scf.load_scf    ${scf_file}
    @{mod_string}=    Create List    modify:MRBTS-${btsid}/MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=${reportingIntervalPm}
    ...    modify:MRBTS-${btsid}/NRBTS-${btsid}/SERVEDAMF-1:amfIPAddress=${amfIPAddress}
    scf.perform_scf_modification      ${mod_string}
    # save SCF #
    ${scf_file_modified}    Catenate    SEPARATOR=_    ${scf_file.split('/')[-1].strip('.xml')}    modified.xml
    scf.save_scf    file_path=${TEST_LOG_DIR}/${scf_file_modified}
    sbts_admin.perform_commissioning    scf_file=${TEST_LOG_DIR}/${scf_file_modified}    skip_parameter_relation_errors=true    timeout=${timeout}
    Sleep    180s
    Wait Until Keyword Succeeds     ${timeout}    30s    Check If All Cells Are OnAir
    Log To Console    \n[INFO] Perform full commission DONE and cells are OnAir.
    Close Startup View Window

reconfig SCFC and wait for onair
    [Arguments]    ${org_scfc}    ${mod_scfc}    @{parameters}    ${modify_list}
    ${modify_list}    create list    @{parameters}
    modify_xml    ${org_scfc}    ${mod_scfc}    ${modify_list}
    ${scfc_path}=    Set Variable    ${mod_scfc}
    Full Commission gNB SCFC and wait for onair    ${scfc_path}

Online change SCFC parameter
    [Arguments]    ${dist_name}    ${parameter}    ${value}
    Log To Console    [ INFO ] Online change [ ${parameter} ] to [ ${value} ] under MO [ ${dist_name} ]
    sbts_admin.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    operation=update    value=${value}     skip_parameter_relation_errors=${True}

Get Current Scfc
    [Arguments]    ${isParsed}=True
    ${date}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    sbts_admin.get_current_scf_file    ${TEST_LOG_DIR}    SCFC_${date}.xml    export_type=configurationAndRuntimeObjects
    Sleep    2s
    ${xml}=    XML.Parse Xml    ${TEST_LOG_DIR}/SCFC_${date}.xml
    ${return_result}    Set Variable If    ${isParsed}    ${xml}    ${TEST_LOG_DIR}/SCFC_${date}.xml
    [Return]    ${return_result}

Get Value From SCF By Class
    [Documentation]    this keyword is used to get para from XML file
    ...    for example-1:
    ...    scf_file=<Get Current Scfc>
    ...    class=BBPOOL
    ...    distName=BBPOOL-1
    ...    para=bbPoolCellsList
    [Arguments]    ${scf_file}    ${class}    ${distName}    ${para}
    #${text}=   XML.Evaluate Xpath    ${scf_file}
    #...    string(.//managedObject[contains(@class, "${class}") and contains(@distName, "${distName}")]/p[@name='${para}'])
    ${isList}    Run Keyword And Return Status    Should Contain    ${para.lower()}    list
    ${regx}    Set Variable If    ${isList}
    ...    .//managedObject[contains(@class, "${class}") and contains(@distName, "${distName}")]/list[@name='${para}']
    ...    .//managedObject[contains(@class, "${class}") and contains(@distName, "${distName}")]/p[@name='${para}']
    ${result}=   Run Keyword And Ignore Error    XML.Get Element Text    ${scf_file}    ${regx}
    ${tmp}=    Run Keyword If    ${isList} and '${result}[0]'=='PASS'    Replace String Using Regexp    ${result[1].strip()}    \\s+    |
    ${text}=    Set Variable If    ${isList} and '${result}[0]'=='PASS'    ${tmp.split('|')}    ${result[1].strip()}
    [Return]    ${text}

Get ${key} From ${rat} Cells
    ${cells_list}    Set Variable If    '${rat.upper()}'=='LTE'    ${LTE_cells}    ${NR_cells}
    ${keys_list}    Get Dictionary Keys    ${cells_list}[0]
    Should Contain    ${keys_list}    ${key}
    ${cell_value_dict}    Create Dictionary
    FOR    ${cell}    IN    @{cells_list}
        ${cellid}=    Set Variable     ${cell}[globalCellId]
        ${value}=    Set Variable     ${cell}[${key}]
        Set To Dictionary    ${cell_value_dict}    ${cellid}    ${value}
    END
    [Return]    ${cell_value_dict}

perform delta scf recommission
    [Arguments]    ${delta_file}    ${skip_parameter_relation_errors}=True    ${should_activate}=True
    ...            ${timeout}=300    ${connection}=default
    Log To Console    [INFO] Perform delta recommission ${delta_file} ... ...
    sbts_admin.perform_delta_recommissioning    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    should_activate=${should_activate}
    ...    timeout=${timeout}    connection=${connection}
    Wait Until Keyword Succeeds     ${timeout}    30s    Check If All Cells Are OnAir
    Log To Console    [INFO] Perform delta recommission finished and cells are OnAir.

modify swconfig file
    [Documentation]    The keyword is used to backup, modify, upload swconfig.txt.
    ...    | arguments | default | mandatory | description |
    ...    | flags_dict | None | No | if flags_dict=None, only default flags to be added. it should be a dict, like as {'0x1234':'1', '0x5678':'2'} |
    ...    | local_path | swconfig_new.txt | No | local path to store backup and generate swconfig.txt file |

    [Arguments]    ${flags_dict}=${None}    ${local_path}=${TEST_LOG_DIR}
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt ${local_path}/swconfig_backup.txt

    swconfig_update    ${flags_dict}    ${local_path}/swconfig_new.txt
    Run Keyword If     ${flags_dict}    Log To Console    \n[ INFO ] swconfig will be added some flags:\n${flags_dict}

    File Should Exist    ${local_path}/swconfig_new.txt    [ ERROR ] Failed to generate swconfig_new.txt in ${local_path}.
    Run    sshpass -p oZPS0POrRieRtu scp ${local_path}/swconfig_new.txt toor4nsn@192.168.255.1:/ffs/run/swconfig.txt
    execute command on BTS via ssh    crasign /ffs/run/swconfig.txt

execute command on BTS via ssh
    [Arguments]    ${command}
    Log To Console    \n[INFO]Execute command [${command}] via ssh...
    ${access_info}    Catenate    SEPARATOR=${SPACE}    You are about to access a private system.
    ...    This system is for the use of authorized users only.
    ...    All connections are logged to the extent and by means acceptable by the local legislation.
    ...    Any unauthorized access or access attempts may be punished to the fullest extent possible under the applicable local legislation.\\n
    ${status}    Run And Return Rc And Output
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 '${command}'
    ${result}    Set Variable    ${status[1].split('${access_info}')}[-1]
    ${isSuccess}    Set Variable    ${status}[0]
    Run Keyword If    ${isSuccess}==0    Log To Console    [INFO]Execute command sucessfully.
    ...    ELSE    Log To Console    [ERROR]Failed to execute command OR no response: ${result}
    [Return]    ${result}

Configure TDDFrameStructure For NR Cells
    [Arguments]    ${tddPatternType}
    [Documentation]    To configure different TDD pattern for all NR cells.
    ...    | NIDD parameter | A1 | A2 | A3 | A4 | A5 | A6 | A7 | A8 |
    ...    | | 1208 GP1 | 1208 GP2 | 1070 GP1 | 1070 GP2 | 1116_3ms GP1 | 1116_3ms GP2 | 1116_0ms GP | 1116_0ms GP1 |
    ...    | frameStructureType | semiStatic | semiStatic | semiStatic | semiStatic | tdLte | tdLte | tdLte | tdLte |
    ...    | guardPeriodLength | 2Symbols | 4Symbols | 2Symbols | 4Symbols | 4Symbols | 6Symbols | 6Symbols | 4Symbols |
    ...    | lteToNrFrameShift | NA | NA | NA | NA | 3ms | 3ms | 0ms | 0ms |
    ...    | tdLteUlDlConfig | NA | NA | NA | NA | tdLteConfig2 | tdLteConfig2 | tdLteConfig2 | tdLteConfig2 |
    ...    | ulDlDataSlotRatio | 1/4 | 1/4 | 3/7 | 3/7 | NA | NA | NA | NA |

    ${pattern_print_dict}    Create Dictionary    A1=1208 GP1    A2=1208 GP2    A3=1070 GP1    A4=1070 GP2
    ...    A5=1116_3ms GP1    A6=1116_3ms GP2   A7=1116_0ms GP    A8=1116_0ms GP1

    ${tddPatternType}    Set Variable    ${tddPatternType.upper()}

    Should Be True    '${tddPatternType}' in ('A1','A2','A3','A4','A5','A6','A7','A8',)    [ERROR] The tddPattern is out of range: A1~A8.

    Log To Console    \n[INFO] Configure TDDPattern :: ${tddPatternType} :: ${pattern_print_dict['${tddPatternType}']}\n
    ${frameStructureType}    Set Variable If    '${tddPatternType}' in ('A1','A2','A3','A4')    semiStatic    tdLte
    ${guardPeriodLength}    Run Keyword If    '${tddPatternType}' in ('A1','A3')    Set Variable    2Symbols
    ...    ELSE IF    '${tddPatternType}' in ('A6','A7')    Set Variable    6Symbols
    ...    ELSE    Set Variable    4Symbols
    ${lteToNrFrameShift}    Run Keyword If    '${tddPatternType}' in ('A5','A6')    Set Variable    3ms
    ...    ELSE IF    '${tddPatternType}' in ('A7',)    Set Variable    0ms
    ...    ELSE    Set Variable    None
    ${tdLteUlDlConfig}    Run Keyword If    '${tddPatternType}' in ('A5','A6','A7',)    Set Variable    tdLteConfig2
    ...    ELSE    Set Variable    None
    ${ulDlDataSlotRatio}    Run Keyword If    '${tddPatternType}' in ('A1','A2')    Set Variable    1/4
    ...    ELSE IF    '${tddPatternType}' in ('A3','A4')    Set Variable    3/7
    ...    ELSE    Set Variable    None
    ${prachConfigurationIndex}    Run Keyword If    '${tddPatternType}' in ('A8',)    Set Variable    150
    ...    ELSE IF    '${tddPatternType}' in ('A1','A3')    Set Variable    98
    ...    ELSE    Set Variable    98

    Run Keyword If    '${tddPatternType}'=='A8'    perform delta scf recommission    ${SCFC_path}${/}Robustness${/}tdd_pattern_A8_10420.json
    ...    ELSE    Run Keywords    Configure TddFrameStructure    frameStructureType=${frameStructureType}
    ...                            guardPeriodLength=${guardPeriodLength}
    ...                            lteToNrFrameShift=${lteToNrFrameShift}
    ...                            tdLteUlDlConfig=${tdLteUlDlConfig}
    ...                            ulDlDataSlotRatio=${ulDlDataSlotRatio}
    ...                            prachConfigurationIndex=${prachConfigurationIndex}
    ...                            skip_errors=False
    ...    AND    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir

Create TddFrameStructure Parameters List
    [Arguments]     ${frameStructureType}     ${guardPeriodLength}    ${lteToNrFrameShift}
    ...             ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}
    [Documentation]      List containing tddframestructure parameters
    ${tddFrameStructure_values_dict}     Create Dictionary    frameStructureType=${frameStructureType}
    ...    guardPeriodLength=${guardPeriodLength}
    Run Keyword If    '${lteToNrFrameShift}'!='None'    Set To Dictionary    ${tddFrameStructure_values_dict}
    ...    lteToNrFrameShift=${lteToNrFrameShift}
    Run Keyword If    '${tdLteUlDlConfig}'!='None'    Set To Dictionary    ${tddFrameStructure_values_dict}
    ...    tdLteUlDlConfig=${tdLteUlDlConfig}
    Run Keyword If    '${ulDlDataSlotRatio}'!='None'    Set To Dictionary    ${tddFrameStructure_values_dict}
    ...    ulDlDataSlotRatio=${ulDlDataSlotRatio}
    ${tddFrameStructure_values_list}     Create List    ${tddFrameStructure_values_dict}
    ${tddFrameStructure_param}    Create Dictionary    parameterName=tddFrameStructure
    ...    value=${tddFrameStructure_values_list}    operation=update
    ${tddFrameStructure_parameters_list}    Create List    ${tddFrameStructure_param}
    [Return]    ${tddFrameStructure_parameters_list}

Configure TddFrameStructure
    [Arguments]     ${frameStructureType}     ${guardPeriodLength}    ${lteToNrFrameShift}
    ...             ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}    ${skip_errors}
    [Documentation]      Configure tddframestructure.
    ${cell_id_dict}    Get id From NR Cells
    ${cell_id_list}    Create List
    FOR    ${id}    IN     @{cell_id_dict.values()}
        Append To List    ${cell_id_list}    ${id['configuration']}
    END
    ${tddFrameStructure_parameters_list}    Create tddFrameStructure Parameters List    ${frameStructureType}
    ...    ${guardPeriodLength}    ${lteToNrFrameShift}    ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}

    ${prachConfiguration_param}    Create Dictionary    parameterName=prachConfigurationIndex
    ...    value=${prachConfigurationIndex}    operation=update
    Append To List    ${tddFrameStructure_parameters_list}    ${prachConfiguration_param}
    Log To Console    [INFO] ${tddFrameStructure_parameters_list}
    FOR    ${cell_mo}    IN    @{cell_id_list}
        Log To Console    \n[INFO] Configure TDDPattern for ${cell_mo} ... ...\n
        sbts_admin.Perform Object Recommissioning
        ...    dist_name=${cell_mo}
        ...    parameter=${tddFrameStructure_parameters_list}
        ...    operation=update
        ...    skip_parameter_relation_errors=${skip_errors}
    END

#########################################################################
##                        check gNB and cell state                     ##
#########################################################################
Get BTS information by MO
    [Arguments]    ${MO_name}=NRCELL_R
    [Documentation]    use to get the parameters by MO including NRCELL_R runtime information,return a list.
    ${MO_info_list}    sbts_admin.Get Managed Objects    class_name=${MO_name}
    [Return]    ${MO_info_list}

Get All Cells Runtime Information
    ${nrcells_info_list}    Get BTS information by MO    MO_name=NRCELL_R
    ${ltecell_info_list}    Get BTS information by MO    MO_name=LNCEL_R

    ${NrCellsNotExists}    Run Keyword And Return Status    Should Be True    '${nrcells_info_list}' == 'None'
    ${LTECellNotExists}    Run Keyword And Return Status    Should Be True    '${ltecell_info_list}' == 'None'

    ${cells_status_dict}    Create Dictionary

    # Process NR cells if they exist
    FOR    ${nrcell_r}    IN    @{nrcells_info_list}
        Exit For Loop If    ${NrCellsNotExists}
        ${status}    Create List
        ${cellid}    Set Variable    ${nrcell_r['parameters']['nrCellIdentity']}
        Run Keyword If    '${nrcell_r}[parameters][barringStatus]'!='unbarred'    Append To List    ${status}    barred
        Run Keyword If    '${nrcell_r}[parameters][blockingState]'!='Unblocked'    Append To List    ${status}    blocked
        Run Keyword If    '${nrcell_r}[parameters][operationalState]'!='enabled'    Append To List    ${status}    disabled
        Run Keyword If    '${nrcell_r}[parameters][administrativeState]'!='Unlocked'    Append To List    ${status}    locked
        ${tmp_dict}    Create Dictionary    rat=NR    status=${status}    arfcnSsbPbch=${nrcell_r["parameters"]["arfcnSsbPbch"]}
        Set To Dictionary    ${cells_status_dict}    ${cellid}    ${tmp_dict}
    END

    # Process LTE cells if they exist
    FOR    ${lncel_r}    IN    @{ltecell_info_list}
        Exit For Loop If    ${LTECellNotExists}
        ${status}    Create List
        ${cellid}    Set Variable    ${lncel_r['parameters']['eutraCelId']}
        Run Keyword If    '${lncel_r}[parameters][blockingState]'!='Unblocked'    Append To List    ${status}    blocked
        Run Keyword If    '${lncel_r}[parameters][operationalState]'!='enabled'    Append To List    ${status}    disabled
        Run Keyword If    '${lncel_r}[parameters][administrativeState]'!='unlocked'    Append To List    ${status}    locked
        ${tmp_dict}    Create Dictionary    rat=LTE    status=${status}    arfcnSsbPbch=None
        Set To Dictionary    ${cells_status_dict}    ${cellid}    ${tmp_dict}
    END
    [Return]    ${cells_status_dict}

Calculate nrCellIdentity or eutraCelId via Global cell ID
    [Arguments]    ${cell_Id}=${None}    ${rat}=5G
    [Documentation]    Keyword is used to calculate nrCellIdentity (5G) or eutraCelId (4G):
    ...    | Condition | Result |
    ...    | IF      : cell_id = None |  Nothing to do, return from keyword. |
    ...    | ELSE IF : length of cell_id >= 4 |  Nothing to do, return from keyword. |
    ...    | ELSE IF : rat = 5G | nrCellIdentity = bts_id * 2**14 + cell_id |
    ...    | ELSE IF : rat = 4G | eutraCelId = bts_id * 2**8 + cell_id |

    Return From Keyword If    '${cell_Id}' == 'None'

    ${tmp_cell_id}    Convert To String    ${cell_id}
    ${IDlength}    Get Length    ${tmp_cell_id}

    ${cellId_name}    Set Variable If    '${rat.upper()}' in ('5G', 'NR')    nrCellIdentity    eutraCelId
    ${bitLen}    Set Variable If    '${rat.upper()}' in ('5G', 'NR')    14    8

    Run Keyword If    ${IDlength} >= 4    Log To Console    [ INFO ] ${rat} ${cellId_name} is ${cell_Id}
    ...    ELSE    Log To Console    [ INFO ] Calculate ${rat} ${cellId_name} via Global cell ID [ ${cell_Id} ] = 2**${bitLen}*${bts_id}+${cell_Id}

    ${calcCellId}    Run Keyword If    ${IDlength} < 4    Evaluate    2**${bitLen}*${bts_id}+${cell_Id}
    ...    ELSE    Set Variable    ${cell_Id}
    [Return]    ${calcCellId}

Get Runtime arfcnSsbPbch
    [Arguments]    ${cell_Id}=${None}    ${rat}=5G
    ${cells_status_dict}    Get All Cells Runtime Information
    ${cellId_list}    Get Dictionary Keys    ${cells_status_dict}

    ${nrcell_ok_dict}    Create Dictionary
    ${nrcell_nok_dict}    Create Dictionary
    ${ltecell_ok_dict}    Create Dictionary
    ${ltecell_nok_dict}    Create Dictionary

    FOR    ${cell}    IN    @{cellId_list}
        ${isLTE}    Run Keyword And Return Status    Should Be True    '${cells_status_dict}[${cell}][rat]' == 'LTE'
        ${isNR}    Run Keyword And Return Status    Should Be True    '${cells_status_dict}[${cell}][rat]' == 'NR'
        ${isOnAir}    Run Keyword And Return Status    Should Be Empty    ${cells_status_dict}[${cell}][status]
        ${isNotOnAir}    Run Keyword And Return Status    Should Not Be Empty    ${cells_status_dict}[${cell}][status]
        Run Keyword IF    ${isOnAir} and ${isLTE}    Set To Dictionary    ${ltecell_ok_dict}    ${cell}    ${cells_status_dict}[${cell}]
        ...    ELSE IF    ${isOnAir} and ${isNR}    Set To Dictionary    ${nrcell_ok_dict}    ${cell}    ${cells_status_dict}[${cell}]
        ...    ELSE IF    ${isNotOnAir} and ${isLTE}    Set To Dictionary    ${ltecell_nok_dict}    ${cell}    ${cells_status_dict}[${cell}]
        ...    ELSE IF    ${isNotOnAir} and ${isNR}    Set To Dictionary    ${nrcell_nok_dict}    ${cell}    ${cells_status_dict}[${cell}]
        ...    ELSE    Log To Console    [ WARN ] T.B.D ... ...
    END

    ${cell_OnAir_list}    Run Keyword If    '${rat.upper()}' in ('NR', '5G')    Get Dictionary Keys    ${nrcell_ok_dict}
    ...    ELSE    Get Dictionary Keys    ${ltecell_ok_dict}
    ${cell_NotOnAir_list}    Run Keyword If    '${rat.upper()}' in ('NR', '5G')    Get Dictionary Keys    ${nrcell_nok_dict}
    ...    ELSE    Get Dictionary Keys    ${ltecell_nok_dict}

    ${idName}    Set Variable If    '${rat.upper()}' in ('NR', '5G')    nrCellIdentity    eutraCelId

    # Check if there are any OnAir cells
    Should Not Be Empty    ${cell_OnAir_list}    [ ERROR ] No OnAir ${rat} cells found:\n${cells_status_dict}

    ${calc_cell_Id}    Calculate nrCellIdentity or eutraCelId via Global cell ID    ${cell_Id}    ${rat}

    # Assign random_cellId or use calc_cell_Id
    ${calc_cell_Id}    Run Keyword If    '${calc_cell_Id}' != 'None'    Convert To Integer    ${calc_cell_Id}
    ${selected_cell}    Run Keyword If    '${calc_cell_Id}' == 'None' or ${calc_cell_Id} in ${cell_NotOnAir_list}
    ...    Evaluate    random.choice(${cell_OnAir_list})    modules=random
    ...    ELSE IF    '${calc_cell_Id}' != 'None' and ${calc_cell_Id} not in ${cellId_list}    Set Variable    None
    ...    ELSE    Set Variable    ${calc_cell_Id}

    ${arfcnSsbPbch}    Set Variable If    '${selected_cell}' == 'None'    None    ${cells_status_dict}[${selected_cell}][arfcnSsbPbch]

    Run Keyword If    '${calc_cell_Id}' == 'None'    Log To Console
    ...    \n[ WARN ] Given ${rat} Cell ${calc_cell_Id} is None, random selection [ ${selected_cell} ] from:\n${cell_OnAir_list}.
    ...    ELSE IF    ${calc_cell_Id} in ${cell_NotOnAir_list}    Log To Console
    ...    [ ERROR ] ${rat} cell [${calc_cell_Id}] is NOT OnAir.\nRandomly replace with:[${idName}|arfcnSsbPbch :: ${selected_cell}|${arfcnSsbPbch}]
    ...    ELSE IF    '${calc_cell_Id}' != 'None' and ${calc_cell_Id} not in ${cellId_list}
    ...    Log To Console    [ ERROR ] Given ${rat} cell [ ${calc_cell_Id} ] is NOT found from bts: ${cellId_list}.
    ...    ELSE    Log To Console    [ INFO ] Given ${rat} cell [${calc_cell_Id}] is OnAir.

    Run Keyword If    '${arfcnSsbPbch}' == 'None'
    ...    Log To Console    [ INFO ] UE attach will be performed with other mode, such as Band Lock.
    ...    ELSE    Log To Console    [ INFO ] UE attach with ARFCN Lock: [ ${idName} | arfcnSsbPbch :: ${selected_cell} | ${arfcnSsbPbch} ]
    [Return]    ${arfcnSsbPbch}    ${cellId_list}

gNB in onAir state
    [Documentation]    Keyword check if gNB is in configured state
    ${gNB_statuses}=    sbts_admin.get_bts_statuses
    ${state}    get from dictionary    ${gNB_statuses}    key=proceduralState
    Should Be Equal    ${state}    OnAir
    [Return]    ${state}

Check Cell while OnAir
    [Arguments]    ${component_index}
    ${states}    Get Cell Statuses    ${component_index}
    log    ${states}
    Set Test Variable    ${states}
    Check operationalState enabled
    Check administrativeState Unlocked
    Check proceduralStatus configured

Check Cell while Cell locked
    [Arguments]    ${component_index}
    ${states}    Get Cell Statuses    ${component_index}
    Check availabilityStatus offline
    Check operationalState disabled
    Check administrativeState locked
    Check proceduralStatus initialization required    ${states}

Get Cell Statuses
    [Arguments]    ${component_id}
    ${Cell_statuses_response}=    sbts_admin.get_cells_info
    log    ${Cell_statuses_response}
    ${specific}=    get_info_on_specific_component    ${Cell_statuses_response}    ${component_id}
    [Return]    ${specific['status']}

Check availabilityStatus is either online or degraded
    ${success}    run keyword and return status    Check availabilityStatus online
    run keyword if    ${success}==False    Check availabilityStatus degraded

Check administrativeState ${administrativeState}
    Check Status Value    ${states}    administrativeState    ${administrativeState}
    Log to console    \n[INFO]:proceduralStatus is ${administrativeState}

Check proceduralStatus ${proceduralStatus}
    Check Status Value    ${states}    proceduralStatus    ${proceduralStatus}
    Log to console    \n[INFO]:proceduralStatus is ${proceduralStatus}

Check proceduralStatus initialization required
    [Arguments]    ${states}
    Check Status Value    ${states}    proceduralStatus    initialization required
    Log to console    \n[INFO]:proceduralStatus is initialization required

Check If All Cells Are OnAir
    [Arguments]       ${connection}=${NONE}
    [Documentation]   Check status of all cells configured on testline.

    ${LTE_cells}=     sbts_admin.get_cells_info  lte    connection=${connection}
    ${NR_cells}=      sbts_admin.get_cells_info  nr     connection=${connection}

    ${LTE_exists}     Get Length            ${LTE_cells}
    ${NR_exists}      Get Length            ${NR_cells}
    Should Be True    ${LTE_exists}+${NR_exists}>0    [ERROR] No cells be detected!
    ${LTE_cells_paras}    Run Keyword If    ${LTE_exists} > 0    Get Dictionary Keys    ${LTE_cells[0]}
    ${NR_cells_paras}     Run Keyword If    ${NR_exists} > 0     Get Dictionary Keys    ${NR_cells[0]}
    Run Keyword If    ${LTE_exists} > 0     Run Keywords    Set Suite Variable    ${LTE_cells}
    ...    AND    Log    ${LTE_cells_paras}
    ...    AND    Check If LTE Cells Are Enabled
    Run Keyword If    ${NR_exists} > 0      Run Keywords    Set Suite Variable    ${NR_cells}
    ...    AND    Log    ${NR_cells_paras}
    ...    AND    Check If 5G Cells Are Enabled

Check If ${rat} Cells Are Enabled
    ${cells_status_dict}    Create Dictionary
    ${cells_administrativeState_dict}    Create Dictionary
    ${cells_operationalState_dict}    Create Dictionary
    ${cells_blockingState_dict}    Create Dictionary
    ${cell_type}    Set Variable If    '${rat.upper()}'=='LTE'    LNCEL    NRCELL
    ${cells_list}    Set Variable If    '${rat.upper()}'=='LTE'    ${LTE_cells}    ${NR_cells}
    FOR    ${item}    IN    @{cells_list}
        ${status_dict}    Set Variable    ${item['status']}
        Set To Dictionary    ${cells_administrativeState_dict}    ${cell_type}-${item['globalCellId']}    ${status_dict['administrativeState']}
        Set To Dictionary    ${cells_operationalState_dict}    ${cell_type}-${item['globalCellId']}    ${status_dict['operationalState']}
        Set To Dictionary    ${cells_blockingState_dict}    ${cell_type}-${item['globalCellId']}    ${status_dict['blockingState']}
    END
    ${cells_administrativeState}    Get Dictionary Values     ${cells_administrativeState_dict}    sort_keys=False
    ${cells_operationalState}       Get Dictionary Values     ${cells_operationalState_dict}    sort_keys=False
    ${cells_blockingState}          Get Dictionary Values     ${cells_blockingState_dict}    sort_keys=False
    Run Keyword And Continue On Failure    Run Keyword If    'Locked' in ${cells_administrativeState}
    ...    Run Keywords    Log    Some ${rat} cells is locked: administrativeState=${cells_administrativeState_dict}    level=WARN    AND    Fail
    Run Keyword And Continue On Failure    Run Keyword If    'disabled' in ${cells_operationalState}
    ...    Run Keywords    Log    Some ${rat} cells is disabled: blockingState=${cells_operationalState_dict}    level=WARN    AND    Fail
    Run Keyword And Continue On Failure    Run Keyword If    'Blocked' in ${cells_blockingState}
    ...    Run Keywords    Log    Some ${rat} cells is Blocked: operationalState=${cells_blockingState_dict}    level=WARN    AND    Fail

Assert Every Class Item
    [Arguments]    ${class_name}    ${parameters}    ${timeout}=120s    ${connection}=${NONE}
    sbts_admin.assert_every    class_name=${class_name}
    ...                   parameters=${parameters}
    ...                   timeout=${timeout}
    ...                   connection=${connection}

Check If Specific Cell Is OnAir
    [Arguments]    ${specific_cell}=${None}    ${rat}=5G
    [Documentation]    Keyword is used to check if the specific cell is OnAir or not. if the specific_cell is Global cell ID,
    ...    calculate nrCellIdentity (5G) or eutraCelId (4G).
    ...    | Arguments | Mandatory | Default | Description |
    ...    | specific_cell | No | None | If rat is 5G, it's nrCellIdentity; if rat is 4G, it's eutraCelId; if None, all cells will be checked. |
    ...    | rat | No | 5G | If rat is 5G, Calculate nrCellIdentity via Global cell ID; if rat is 4G, Calculate eutraCelId via Global cell ID. |

    ${cells_status_dict}    Get All Cells Runtime Information

    ${cells_list}    Get Dictionary Keys    ${cells_status_dict}

    ${calc_cell_Id}    Calculate nrCellIdentity or eutraCelId via Global cell ID    ${specific_cell}    ${rat}

    ${specific_cell}    Run Keyword If    '${calc_cell_Id}'!='${None}'    Convert To Integer    ${calc_cell_Id}
    ${isSpecifiedCell}    Run Keyword And Return Status    List Should Contain Value    ${cells_list}    ${specific_cell}

    Run Keyword If    ${isSpecifiedCell}    Should Be Empty    ${cells_status_dict}[${specific_cell}][status]
    ...    [ ERROR ] ${cells_status_dict}[${specific_cell}][rat] Cell [${specific_cell}] is NOT OnAir: ${cells_status_dict}[${specific_cell}][status]

    FOR    ${cellid}    IN    @{cells_list}
        Exit For Loop If    ${isSpecifiedCell}
        ${tmp}=    Get From Dictionary    ${cells_status_dict}    ${cellid}
        Run Keyword And Continue On Failure    Should Be Empty    ${tmp}[status]
        ...    [ ERROR ] ${tmp}[rat] Cell [ ${cellid} ] is NOT OnAir: ${tmp}[status].
    END

#########################################################################
##                             reset operation                         ##
#########################################################################
Reset BBMODs
    [Arguments]    ${str_bbmods_list}=null
    [Documentation]    Reset BBMODs
    ...    Description: Reset BBMODs via Gnb according to a given BBMODs list, or reset all BBMODs if no parameter
    ...    Example 1: Reset 1 BBMOD with id 2.
    ...    Reset BBMODs 2
    ...    Example 2: Reset 2 BBMODs with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Reset BBMODs 1 2
    ...    Example 3: Reset all BBMODs
    ...    Reset BBMODs
    ${bbmods_list}    string.split string    ${str_bbmods_list}
    Run Keyword If    '${str_bbmods_list}' == 'null'    Log To Console    [INFO]Reset All BBMODS
    ...    ELSE    Log To Console    [INFO]Reset BBMODs in list @{bbmods_list}
    ${fbb_info}=    sbts_admin.Get fbb info
    FOR    ${fbb}    IN    @{fbb_info}
        ${prefix}    ${fbb_full_id} =    string.Split String From Right    ${fbb['id']['internal']}    separator=/    max_split=${1}
        ${prefix}    ${fbb_id} =    string.Split String From Right    ${fbb_full_id}    separator=-    max_split=${1}
        Run Keyword If    '${fbb_id}' in @{bbmods_list} or '${str_bbmods_list}' == 'null'    run keywords
        ...    Log To Console    [INFO]Reset BBMOD ${fbb_full_id}
        ...    AND    sbts_admin.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}
    END

Site Reset Via WebUI
    [Arguments]    ${with_graceful}=False    ${without_radio_reset}=True
    Close Startup View Window
    selenium_coam.reset_site    with_graceful=${with_graceful}    without_radio_reset=${without_radio_reset}    sbts=suite

Close Startup View Window
    ${isSuccess}    Run Keyword If    '${close_start-up_view}'=='False'    _close startup-up view
    Run Keyword If    ${isSuccess}    Run Keywords    Set Test Variable    ${close_start-up_view}    ${True}
    ...    AND    Log To Console    [WARN] BTS start-up view window is openning and will be closed.
    ...    ELSE    Log To Console    [INFO] BTS start-up view window is NOT openned or already closed.

_close startup-up view
    ${isSuccess}    Run Keyword And Return Status    selenium_coam.close_start_up_view_window    sbts=suite
    [Return]    ${isSuccess}

Site Reset Via AdminCLI
    [Arguments]    ${with_graceful}=False    ${reset_without_ru}=True
    sbts_admin.reset_site    graceful_cell_shutdown=${with_graceful}    reset_without_ru=${reset_without_ru}

##########################################################################
##                        check SMOD and BBMOD                          ##
##########################################################################

Check SMOD and BBMOD
    Check SMOD
    Check BBMOD

Check SMOD
    ${bts_info}=    sbts_admin.get_fsm_info
    set suite variable    ${SMOD_status}    valid
    FOR    ${SMOD}    IN    @{bts_info}
        set suite variable    ${operationalState}    ${SMOD["status"]["operationalState"]}
        #    set suite variable    ${availabilityStatus}    ${SMOD["status"]["availabilityStatus"]}
        run keyword if    '${operationalState}'!='enabled'    set suite variable    ${SMOD_status}    invalid
    END
    #    run keyword if    '${availabilityStatus}'!='Online'    set suite variable    ${SMOD_status}    invalid
    should be equal as strings    ${SMOD_status}    valid

Check BBMOD
    ${bts_info}=    sbts_admin.get_fbb_info
    set suite variable    ${BBMOD_status}    valid
    FOR    ${BBMOD}    IN    @{bts_info}
        set suite variable    ${operationalState}    ${BBMOD["status"]["operationalState"]}
        #    set suite variable    ${availabilityStatus}    ${BBMOD["status"]["availabilityStatus"]}
        run keyword if    '${operationalState}'!='enabled'    set suite variable    ${BBMOD_status}    invalid
    END
    #    run keyword if    '${availabilityStatus}'!='Online'    set suite variable    ${BBMOD_status}    invalid
    should be equal as strings    ${BBMOD_status}    valid

Check ping on SMOD
    ${output}    Run    ping -c 1 -W 10 192.168.255.129
    Should contain    ${output}    1 packets transmitted, 1 received

Create connection to Asix
    ${129_ready}=    run keyword and return status    ssh.Connect To    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    alias=asik
    run keyword if    '${129_ready}'=='False'    ssh.Connect To    hostname=192.168.255.1
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    alias=asik

Power reset SMOD during preparation
    [Arguments]    ${model}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.__class__.__name__}
    ...    ${ip_pdu}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ...    ${port}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ...    ${version}=${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.version}
    run keyword if    "Gude"=="${model}"    Set Gude PDU power off RU    ${model}    ${ip_pdu}    ${version}    ${port}
    ...    ELSE    Set PDU power off RU    ${model}    ${ip_pdu}    ${port}
    sleep    10s
    run keyword if    "Gude"=="${model}"    Set Gude PDU power on RU    ${model}    ${ip_pdu}    ${version}    ${port}
    ...    ELSE    Set PDU power on RU    ${model}    ${ip_pdu}    ${port}
    ${is_SMOD_pingable}=    run keyword and return status    wait until keyword succeeds    5 min    30 sec    Check ping on SMOD
    run keyword if    '${is_SMOD_pingable}'=='False'    run keywords
    ...    log    SMOD is not responding still after power reset. Test suite is canceled.    level=WARN    AND    FAIL
    ${adminCLI_1_try}=    run keyword and return status    wait until keyword succeeds    5 min    30 sec    ADMIN CLI connection
    run keyword if    '${adminCLI_1_try}'=='True'    run keywords    set suite variable    ${adminCLI_ready}    True
    ...    AND    return from keyword
    ${ssh_asix_ready}=    run keyword and return status    Create connection to Asix
    run keyword if    '${ssh_asix_ready}'=='False'    run keywords
    ...    log    SMOD is not responding still after power reset. Test suite is canceled.    level=WARN    AND    FAIL

Check BTS and reboot
    ${active_partition}=    ssh.execute    ls /ffs/run    connection=asik
    ${valid_partition}=    run keyword and return status    Check partition    ${active_partition}
    run keyword if    '${valid_partition}'=='False'    run keywords    log    Files are missing on active partition    level=WARN
    ...    AND    FAIL
    #ssh.execute    rm /ffs/run/config/users.json    connection=asik
    ssh.Send Command    /sbin/reboot    connection=asik
    ${adminCLI_2_try}=    run keyword and return status    wait until keyword succeeds    5 min    30 sec    ADMIN CLI connection
    run keyword if    '${adminCLI_2_try}'=='True'    set suite variable    ${adminCLI_ready}    True

Check partition
    [Arguments]    ${to_check}
    should contain X times    ${to_check}    HashContainer    6
    should contain X times    ${to_check}    TargetBD    2

Check bbPool Cell Mapping
    [Arguments]    ${bbpool}    ${excepted_cells_list}    ${loki}=Loki-A
    ${scf_file}    Get Current Scfc
    ${get_cells_list}    Get Value From SCF By Class    ${scf_file}    BBPOOL    ${bbpool}    bbPoolCellsList
    Get Value From SCF By Class    ${scf_file}    BBPOOL    ${bbpool}    bbPwrGroupDNList
    Get Value From SCF By Class    ${scf_file}    BBPOOL    ${bbpool}    bbPoolTech
    Get Value From SCF By Class    ${scf_file}    BBPOOL    ${bbpool}    operationalState

    FOR    ${cell}    IN    @{excepted_cells_list}
        Run Keyword If    '${cell}' in ${get_cells_list} or '${cell}' in '${get_cells_list}[0]'
        ...    Log To Console    [INFO] cell-${cell} is existed on ${loki}
        ...    ELSE    Fail    [ERROR] cell-${cell} is NOT existed on ${loki}.
    END

#################################################################################
##                               PDU power off/on                              ##
#################################################################################
Set Gude PDU power off RU
    [Arguments]    ${model}    ${host}    ${version}    ${port}
    pdu.setup_pdu    model=${model}    host=${host}    version=${version}    alias=pdu
    pdu.power_off    port=${port}    pdu_device=pdu

Set PDU power off RU
    [Arguments]    ${model}    ${host}    ${port}
    pdu.setup_pdu    model=${model}    host=${host}    alias=pdu
    pdu.power_off    port=${port}    pdu_device=pdu

Set Gude PDU power on RU
    [Arguments]    ${model}    ${host}    ${version}    ${port}
    pdu.setup_pdu    model=${model}    host=${host}    version=${version}    alias=pdu
    pdu.power_on    port=${port}    pdu_device=pdu

Set PDU power on RU
    [Arguments]    ${model}    ${host}    ${port}
    pdu.setup_pdu    model=${model}    host=${host}    alias=pdu
    pdu.power_on    port=${port}    pdu_device=pdu

#################################################################################
##                              availabl status                                ##
#################################################################################
Check availabilityStatus ${availabilityStatus}
    Check Status Value    ${states}    availabilityStatus    ${availabilityStatus}
    Log to console    \n[INFO]:availabilityStatus is ${availabilityStatus}

Check Status Value
    [Arguments]    ${statuses_container}    ${status}    ${value}
    ${actual_value}=    get from dictionary    ${statuses_container}    ${status}
    run keyword and continue on failure    should be equal    ${actual_value.lower()}    ${value.lower()}

Check operationalState ${operationalState}
    Check Status Value    ${states}    operationalState    ${operationalState}
    Log to console    \n[INFO]:operationalState is ${operationalState}

################################################################################
##                                 cell lock unlock                           ##
################################################################################

Perform ${rat} Cell ${operate} ${cells} via AdminCLI
    Should Be True    '${rat.upper()}' in ('4G', 'LTE', '5G', 'NR')    [ERROR]${rat.upper()} should be '4G' |'LTE' |'5G' | 'NR'.
    Should Be True    '${operate.lower()}' in ('lock', 'unlock', 'block', 'unblock', 'reset')
    ...    [ERROR]${operate.lower()} should be lock/unlock or block/unblock or reset.
    Log To Console    \n[INFO] Perform ${rat} Cell ${operate} ${cells} ... ...
    ${specific_rat_cells}    Set Variable If    '${rat.upper()}' in ('4G', 'LTE')    ${LTE_cells}    ${NR_cells}
    ${cells_MO_dict}    Get Cells ID MO Dict    ${specific_rat_cells}
    ${status}    ${isList}    Run Keyword And Ignore Error    Robot Isinstance    ${cells}    List
    ${status}    ${isInt}    Run Keyword And Ignore Error    Robot Isinstance    ${cells}    Int
    ${status}    ${isStr}    Run Keyword And Ignore Error    Robot Isinstance    ${cells}    Str
    ${cells_id_list}    Run Keyword If    ${isList}    Set Variable    ${cells}
    ...    ELSE IF    ${isInt}    Create List    ${cells}
    ...    ELSE IF    ${isStr}    Split String    ${cells}   ,
    ...    ELSE    Log To Console    [ERROR] ${cells} should be int | str | list. such as 1 | 1,2 | [1,2].
    FOR    ${cell}    IN    @{cells_id_list}
        ${cell}    Convert To Integer    ${cell}
        ${object}    Get From Dictionary    ${cells_MO_dict}    ${cell}
        Run Keyword If    '${operate.lower()}'=='lock'    sbts_admin.lock    dist_name=${object}    timeout=60
        ...    ELSE IF    '${operate.lower()}'=='unlock'    sbts_admin.unlock    dist_name=${object}    timeout=60
        ...    ELSE IF    '${operate.lower()}'=='block'    sbts_admin.block_cell    dist_name=${object}    timeout=60
        ...    ELSE IF    '${operate.lower()}'=='unblock'    sbts_admin.unblock_cell    dist_name=${object}    timeout=60
        ...    ELSE IF    '${operate.lower()}'=='reset'    sbts_admin.reset_cell    cell_id=${cell}    timeout=60
        ...    ELSE    Log To Console    [ERROR] ${operate} is NOT supported, need to be developed.
    END
    Log To Console    \n[INFO] Perform ${rat} Cell ${operate} ${cells} Done.

Get Cells ID MO Dict
    [Arguments]    ${cells_info_list}    ${id_type}=internal
    ${cells_MO_dict}    Create Dictionary
    FOR    ${cell_info}    IN    @{cells_info_list}
        ${nrcell_id}     Set Variable    ${cell_info['id']}
        Set To Dictionary    ${cells_MO_dict}    ${cell_info['globalCellId']}    ${nrcell_id['${id_type}']}
    END
    [Return]    ${cells_MO_dict}

Perform ${operate} ${rat} Cell ${cells} via WebUI
    Should Be True    '${rat.upper()}' in ('LTE', 'NR')    [ERROR]${rat.upper()} should be 'LTE' | 'NR'.
    Should Be True    '${operate.lower()}' in ('block', 'unblock', 'reset')
    ...    [ERROR]${operate.lower()} should be block/unblock or reset.
    Log To Console    \n[INFO] Perform ${rat} Cell ${operate} ${cells} ... ...

    ${status}    ${isList}    Run Keyword And Ignore Error    Robot Isinstance    ${cells}    List
    ${status}    ${isInt}    Run Keyword And Ignore Error    Robot Isinstance    ${cells}    Int
    ${status}    ${isStr}    Run Keyword And Ignore Error    Robot Isinstance    ${cells}    Str
    ${cells_id_list}    Run Keyword If    ${isList}    Set Variable    ${cells}
    ...    ELSE IF    ${isInt}    Create List    ${cells}
    ...    ELSE IF    ${isStr}    Split String    ${cells}   ,
    ...    ELSE    Log To Console    [ERROR] ${cells} should be int | str | list. such as 1 | 1,2 | [1,2].
    FOR    ${cell}    IN    @{cells_id_list}
        ${cell}    Convert To Integer    ${cell}
        Run Keyword If    '${operate.lower()}'=='block'    selenium_coam.block_cell    cell_idx=${cell}    technology=${rat.upper()}    sbts=suite
        ...    ELSE IF    '${operate.lower()}'=='unblock'    selenium_coam.unblock_cell    cell_idx=${cell}    technology=${rat.upper()}    sbts=suite
        ...    ELSE IF    '${operate.lower()}'=='reset'    selenium_coam.reset_cell    cell_idx=${cell}    with_graceful=False    sbts=suite
        ...    ELSE    Log To Console    [ERROR] ${operate} is NOT supported, need to be developed.
    END
    Log To Console    \n[INFO] Perform ${rat} Cell ${operate} ${cells} via WebUI Done.


################################################################################
##                      cell deletion and addition                            ##
################################################################################
online cell deletion for NR
    [Arguments]    ${deletion_cell}=1  ${deletion_cellgrp}=0
    ${mrbtsID}    set Variable    ${btsid}
    ${nrbtsID}    set Variable    ${btsid}
    # ADMIN CLI connection
    ${cell_grp}    Get All NR Cell Group Id
    Selenium Coam Login And Disable Screen Lock
    log to console    [INFO]delete NR cell object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${deletion_cell}    timeout=15
    ...    sbts=suite
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${deletion_cell}    timeout=15    sbts=suite
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${deletion_cellgrp}    timeout=15    sbts=suite
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}    sbts=suite
        run keyword if    '${value}'=='${deletion_cellgrp}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}    sbts=suite
        Exit For Loop If    '${value}'=='${deletion_cellgrp}'
    END
    selenium_coam.validate_plan    sbts=suite
    selenium_coam.activate_plan    activate_plan_despite_errors=True    sbts=suite

Online Add Cell Based On Existing Cell
    [Documentation]    online add one cell based on an existing cell on the same radio
    ...    Example params
    ...    add FDD cell info ${cell_info}
    ...    &{cell_info}    cell_id=4
    ...                    lcrId=4
    ...                    cell_group_id=4
    ...                    nrarfcnDl=369000
    ...                    nrarfcnUl=349800
    ...                    gscnOrSsPbchArfcn=1
    ...                    physCellId=14
    ...                    type0CoresetConfigurationIndex=6
    ...                    prachConfigurationIndex=9
    ...                    cell_id_to_copy_from=1
    ...                    cell_grp_id_to_copy_from=1
    ...                    duplex=FDD
    ...    add TDD cell info ${cell_info}
    ...    &{cell_info}   cell_id=12
    ...                   lcrId=12
    ...                   cell_group_id=12
    ...                   nrarfcn=636524
    ...                   gscnOrSsPbchArfcn=1
    ...                   physCellId=112
    ...                   type0CoresetConfigurationIndex=10
    ...                   prachConfigurationIndex=9
    ...                   cell_id_to_copy_from=11
    ...                   cell_grp_id_to_copy_from=11
    ...                   duplex=TDD
    [Arguments]    ${cell_info}    ${nrcell_include_subobject}=False
    ${mrbtsID}    set Variable    ${btsid}
    ${nrbtsID}    set Variable    ${btsid}
    ${cell_ids}    Get All Cell Id
    ${cell_count}    Get Length    ${cell_ids}
    ${cell_id}    Get From Dictionary    ${cell_info}    cell_id
    ${cell_group_id}    Get From Dictionary    ${cell_info}    cell_group_id
    ${cell_id_to_copy_from}    Get From Dictionary    ${cell_info}    cell_id_to_copy_from
    ${cell_grp_id_to_copy_from}    Get From Dictionary    ${cell_info}    cell_grp_id_to_copy_from
    ${dist_name}    Set Variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ${cell_dist_name}    Set Variable    ${dist_name}/NRCELL-${cell_id}
    ${cell_group_dist_name}    Set Variable    ${dist_name}/NRCELLGRP-${cell_group_id}
    ${cell_grp}    Get All NR Cell Group Id
    # ADMIN CLI connection
    # Selenium Coam Login And Disable Screen Lock
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id_to_copy_from}    include_subobject=True
    ...    id_value=${cell_id}    sbts=suite
    selenium_coam.add_object    object_name=${dist_name}
    ...    object_class_name=NRCELL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=${dist_name}/NRCELL-${cell_id_to_copy_from}    include_subobject=True
    ...    id_value=${cell_id}    sbts=suite
    ${physCellId}    Get From Dictionary    ${cell_info}    physCellId
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=Physical cell identifier   new_value=${physCellId}    abbr=physCellId    sbts=suite
    ${duplex}    Get From Dictionary    ${cell_info}    duplex
    Run Keyword If    '${duplex}'=='TDD'    Run Keyword    Set NR TDD nrarfcn    cell_info=&{cell_info}
    ...    cell_dist_name=${cell_dist_name}
    ...    ELSE IF    '${duplex}'=='FDD'    Run Keyword    Set NR FDD nrarfcn    cell_info=&{cell_info}
    ...    cell_dist_name=${cell_dist_name}
    ${gscnOrSsPbchArfcn}    Get From Dictionary    ${cell_info}    gscnOrSsPbchArfcn
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=Synchronization channel number   new_value=${gscnOrSsPbchArfcn}    abbr=gscnOrSsPbchArfcn    sbts=suite
    ${lcrId}    Get From Dictionary    ${cell_info}    lcrId
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=Local cell resource ID    new_value=${lcrId}    abbr=lcrId    sbts=suite
    ${type0CoresetConfigurationIndex}    Get From Dictionary    ${cell_info}    type0CoresetConfigurationIndex
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=Coreset configuration Index   new_value=${type0CoresetConfigurationIndex}    abbr=type0CoresetConfigurationIndex
    ...    sbts=suite
    ${prachConfigurationIndex}    Get From Dictionary    ${cell_info}    prachConfigurationIndex
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=PRACH configuration index   new_value=${prachConfigurationIndex}    abbr=prachConfigurationIndex    sbts=suite
    selenium_coam.add_object    object_name=${dist_name}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=${dist_name}/NRCELLGRP-${cell_grp_id_to_copy_from}    include_subobject=${nrcell_include_subobject}
    ...    id_value=${cell_group_id}    timeout=15    sbts=suite
    selenium_coam.add_element    dist_name=${dist_name}/NRDU-1
    ...    filter_param=Reference to cell group    abbr=refNrCellGroup
    ...    timeout=15    sbts=suite
    # ${cell_count_new}    Evaluate    ${cell_count}+1
    ${cell_id}     convert to integer    ${cell_id}
    selenium_coam.set_parameter_value    dist_name=${dist_name}/NRDU-1
    ...    filter_param=Reference to cell group    new_value=${cell_group_id}     node_index=${cell_count}    sbts=suite
    selenium_coam.set_parameter_value    dist_name=${cell_group_dist_name}
    ...    filter_param=List of NR cells assigned to cell group    node_index=${0}    new_value=${cell_id}    abbr=nrCellList    sbts=suite
    selenium_coam.validate_plan    sbts=suite
    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=300    sbts=suite

Set NR TDD nrarfcn
    [Arguments]    ${cell_info}    ${cell_dist_name}
    ${nrarfcn}    Get From Dictionary    ${cell_info}    nrarfcn
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${nrarfcn}    abbr=nrarfcn    sbts=suite

Set NR FDD nrarfcn
    [Arguments]    ${cell_info}    ${cell_dist_name}
    ${nrarfcnDl}    Get From Dictionary    ${cell_info}    nrarfcnDl
    ${nrarfcnUl}    Get From Dictionary    ${cell_info}    nrarfcnUl
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in downlink   new_value=${nrarfcnDl}    abbr=nrarfcnDl    sbts=suite
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in uplink   new_value=${nrarfcnUl}    abbr=nrarfcnUl    sbts=suite

Get All NR Cell Group Id
    ${cell_info}   sbts_admin.get_subcells_status   timeout=20
    Log Many      ${cell_info}    level=DEBUG
    ${number_of_cell_group_info}    get length    ${cell_info}
    ${cellgrp_list}    Get Dictionary Keys    ${cell_info}
    @{cellgrp_index_list}    create list
    FOR    ${cellgrp}    IN    @{cellgrp_list}
        ${cellgrp_index}    Fetch from right    ${cellgrp}    -
        ${cellgrp_index}  convert to integer  ${cellgrp_index}
        Append to list    ${cellgrp_index_list}    ${cellgrp_index}
    END
    Sort List   ${cellgrp_index_list}
    [Return]    ${cellgrp_index_list}

Get All Cell Id
    [Documentation]  ru_index=None: get all gnb cells, ru_index=ru_index: get all cells under RU
    [Arguments]  ${ru_index}=${None}    ${cell_type}=nr
    ${output}=    sbts_admin.get_cells_info    cell_type=${cell_type}
    Log Many      ${output}    level=DEBUG
    ${cell_list}  create list
    FOR  ${cell}  IN  @{output}
        run keyword if  ${ru_index}==${None}    append to list  ${cell_list}  ${cell['globalCellId']}
        ${carrier}    set variable  ${cell['carrierList'][0]}
        ${status}  run keyword if  ${ru_index}!=${None}    run keyword and return status
        ...    should contain    ${carrier['antennaLineId']['configuration']}    RMOD-${ru_index}
        run keyword if    ${status}    append to list  ${cell_list}  ${cell['globalCellId']}
    END
    Sort List   ${cell_list}
    [Return]  ${cell_list}

Selenium Coam Login And Disable Screen Lock
    selenium_coam.disable_screen_lock    sbts=suite
    Close Startup View Window


##########################################################################
##                  Get RMODs and Cells Mapping                         ##
##########################################################################

Get RMODs IP from Info Model
    [Documentation]    This keyword is to get ipAddress, productName, serialNumber for all RMODs.
    ${get_rmod_l}    Run keyword and continue on failure    sbts_admin.get_managed_objects    RMOD_L    timeout=600s
    ${rmod_l_dict}    Create Dictionary
    FOR    ${rmod_l}    IN    @{get_rmod_l}
        ${serialNumber}    Set Variable    ${rmod_l}[parameters][serialNumber]
        ${ipAddress}    Set Variable    ${rmod_l}[parameters][ipAddress]
        ${productName}    Set Variable     ${rmod_l}[parameters][productName]
        ${tmp_rmod_l_dict}    Create Dictionary    ipAddress=${ipAddress}    productName=${productName}
        Set To Dictionary    ${rmod_l_dict}    ${serialNumber}=${tmp_rmod_l_dict}
    END
    [Return]    ${rmod_l_dict}

Get RMODs Cells mapping from Info Model
    [Documentation]    This keyword is to get all cells that's allocated on RMODs.
    ${get_rmod_r}    Run keyword and continue on failure    sbts_admin.get_managed_objects    RMOD_R    timeout=600s
    ${rmod_r_dict}    Create Dictionary
    FOR    ${rmod_r}    IN    @{get_rmod_r}
        ${serialNumber}    Set Variable    ${rmod_r}[parameters][serialNumber]
        ${activeLteCellsList}    Set Variable    ${rmod_r}[parameters][activeLteCellsList]
        ${activeNrCellsList}    Set Variable    ${rmod_r}[parameters][activeNrCellsList]
        ${distName}    Set Variable    ${rmod_r}[distName]
        ${tmp_rmod_r_dict}    Create Dictionary    activeLteCellsList=${activeLteCellsList}    activeNrCellsList=${activeNrCellsList}
        ...    distName=${distName}
        Set To Dictionary    ${rmod_r_dict}    ${serialNumber}=${tmp_rmod_r_dict}
    END
    [Return]    ${rmod_r_dict}

Get RMODs Cells carriers
    ${rmod_r_dict}    Get RMODs Cells mapping from Info Model
    ${keys_list}    Get Dictionary Keys    ${rmod_r_dict}
    FOR    ${key}    IN    @{keys_list}
        ${lte_cellid_list}    Set Variable    ${rmod_r_dict}[${key}][activeLteCellsList]
        ${nr_cellid_list}    Set Variable    ${rmod_r_dict}[${key}][activeNrCellsList]
    END

Get Cells TxRx Info
    [Arguments]    ${cells_list}
    [Documentation]    This keyword is to get all LTE and NR cells TRx info.
    ...    The ${LTE_cells} and ${NR_cells} is from keyword 'Check If All Cells Are OnAir', that's in 'Common Test Setup'
    ...    or 'Full Commission gNB SCFC and wait for onair'.
    ...    | Get Cells TxRx Info | ${LTE_cells} |
    ...    | Get Cells TxRx Info | ${NR_cells} |
    ${rat_existed}    Run Keyword And Ignore Error    Get Length    ${cells_list}
    ${cells_txrx_dict}    Run Keyword If    '${rat_existed[0]}'=='PASS'    Get Cells carriers    ${cells_list}
    [Return]    ${cells_txrx_dict}

Get Cells carriers
    [Arguments]    ${cells_list}
    ${cells_txrx_dict}    Create Dictionary
    FOR    ${cell}    IN    @{cells_list}
        ${carrierList}     Set Variable    ${cell}[carrierList]
        ${globalCellId}    Set Variable    ${cell}[globalCellId]
        ${configuration}   Set Variable    ${cell}[id][configuration]
        ${TXRX_dict}    Get Cell Carriers    ${carrierList}
        Set To Dictionary    ${cells_txrx_dict}    '${globalCellId}'=${TXRX_dict}
    END
    [Return]    ${cells_txrx_dict}

Get Cell Carriers
    [Arguments]    ${carrierList}
    ${tx_configuration_list}    Create List
    ${rx_configuration_list}    Create List
    ${RMOD_internal_list}    Create List
    ${RMOD_R_list}    Create List
    FOR    ${carrier}    IN    @{carrierList}
        ${configuration}    Set Variable    ${carrier}[antennaLineId][configuration]
        ${internal}    Set Variable    ${carrier}[antennaLineId][internal]
        ${direction}    Set Variable    ${carrier}[direction]
        Append To list    ${RMOD_internal_list}    ${internal}
        ${RMOD_internal_list}    Remove Duplicates    ${RMOD_internal_list}
        Run Keyword If    '${direction}'=='TX'    Append To List    ${tx_configuration_list}    ${configuration}
        Run Keyword If    '${direction}'=='RX'    Append To List    ${rx_configuration_list}    ${configuration}
    END
    FOR    ${internal}    IN    @{RMOD_internal_list}
        ${rmod_r}    Set Variable     ${internal.split('/ANTL_R-')[0]}
        Append To list    ${RMOD_R_list}    ${rmod_r}
        ${RMOD_R_list}    Remove Duplicates    ${RMOD_R_list}
    END
    FOR    ${rmod_r}    IN    @{RMOD_R_list}
        ${antl_dict}    Get RMOD_R and ANTL_R of Cell    ${rmod_r}    ${RMOD_internal_list}
    END
    ${tx_nums}    Get Length    ${tx_configuration_list}
    ${rx_nums}    Get Length    ${tx_configuration_list}
    ${TXRX_dict}    Create Dictionary    TX=${tx_nums}    RX=${rx_nums}    RMOD_R=${RMOD_R_list}    ANTL_R=${antl_dict}
    [Return]    ${TXRX_dict}

Get RMOD_R and ANTL_R of Cell
    [Arguments]    ${rmod_r}    ${RMOD_internal_list}
    ${antl_list}    Create List
    FOR    ${internal}    IN    @{RMOD_internal_list}
        Append To List    ${antl_list}    ${internal.split('${rmod_r}/ANTL_R-')[-1]}
    END
    ${antl_dict}    Create Dictionary    ${rmod_r}=${antl_list}
    [Return]    ${antl_dict}

##########################################################################
##                              alarm                                   ##
##########################################################################
get coam alarms
    [Arguments]    ${alarm_management}=Active
    [Documentation]    This keyword is used to get active alarms
    sbts_admin.Setup Admin    bts_host=${gNB_IP_MPLANE_LOCAL}    bts_port=${gNB_MPLANE_IF_PORT}    timeout=120    name=alarm
    ${alarms}=    Run Keyword If    '${alarm_management.lower()}'=='active'    sbts_admin.Get Active Alarms    connection=alarm
    ...    ELSE    sbts_admin.Get Historic Alarms    load_history=True    timeout=60    connection=alarm
    [Teardown]    sbts_admin.teardown admin    connection=alarm
    [Return]    ${alarms}

Check If Alarm Appeared
    [Arguments]    ${fault_id}
    [Documentation]    This keyword is used to check if alarm appeared
    sbts_admin.Setup Admin    bts_host=${gNB_IP_MPLANE_LOCAL}    bts_port=${gNB_MPLANE_IF_PORT}    timeout=120    name=alarm
    @{alarms}=    sbts_admin.Get Active Alarms    connection=alarm    # both $ and @ are OK
    @{active_fault_list}=    Create List
    FOR    ${alarm}    IN    @{alarms}    # get list right, must @
        ${fault}=    Get From Dictionary    ${alarm}    faultId
        Append To List    ${active_fault_list}    ${fault}    # ${fault} is a number,not a string
    END
    ${fault_id}=    Convert To Integer    ${fault_id}    # ${fault_id} is a string,it must be changed to number
    List Should Contain Value    ${active_fault_list}    ${fault_id}
    [Teardown]    sbts_admin.teardown admin    connection=alarm

Check If Alarm Disappeared
    [Arguments]    ${fault_id}
    [Documentation]    This keyword is used to check if alarm disappeared
    sbts_admin.Setup Admin    bts_host=${gNB_IP_MPLANE_LOCAL}    bts_port=${gNB_MPLANE_IF_PORT}    timeout=120    name=alarm
    @{alarms}=    sbts_admin.Get Active Alarms    connection=alarm    # both $ and @ are OK
    @{active_fault_list}=    Create List
    FOR    ${alarm}    IN    @{alarms}    # get list right, must @
        ${fault}=    Get From Dictionary    ${alarm}    faultId
        Append To List    ${active_fault_list}    ${fault}    # ${fault} is a number,not a string
    END
    ${fault_id}=    Convert To Integer    ${fault_id}    # ${fault_id} is a string,it must be changed to number
    List Should Not Contain Value    ${active_fault_list}    ${fault_id}
    [Teardown]    sbts_admin.Teardown Admin    connection=alarm

Get Alarms State
    [Arguments]    ${alarm_management}=Active
    Log To Console    \n[ INFO ] Get ${alarm_management} Alarms and Checking ... ...

    ${idDefined}    run keyword and return status    Variable Should Exist    ${ALLOWED_FAULT}
    ...    msg=[ ERROR ] {ALLOWED_FAULT} list should be difined in Variables of .suite
    ${defined_allowed_list}    Set Variable If    ${idDefined}    ${ALLOWED_FAULT}    []

    ${allowed_faults}     Create List    61524    62524    61652    61649    61631    4592    4655    4654    4459    7316    49
    ${allowed_faults_final}     Combine Lists    ${allowed_faults}    ${defined_allowed_list}

    ${not_allowed_active_fault}    Create List    10    1806    4341    4352    4383    1898
    ${not_allowed_histor_fault}    Create List    4590    2087    1981    10

    ${alarmTimeType}    Set Variable If    '${alarm_management.lower()}'=='active'    btsLastUpdateTime    clearedTime
    ${alarms_state}=    get coam alarms    ${alarm_management}

    &{all_alarms_dict}    Create Dictionary
    FOR    ${alarm}    IN    @{alarms_state}
        ${alarmLastUpdateTime}    Get From Dictionary    ${alarm}    ${alarmTimeType}
        ${btsObservationTime}    Get From Dictionary    ${alarm}    btsObservationTime
        ${alarmId}    Get From Dictionary    ${alarm}    alarmId
        ${alarmName}    Get From Dictionary    ${alarm}    alarmName
        ${faultId}    Get From Dictionary    ${alarm}    faultId
        ${faultName}    Get From Dictionary    ${alarm}    faultName
        ${severity}    Get From Dictionary    ${alarm}    severity
        ${configObjectName}    Get From Dictionary    ${alarm}    configObjectName
        ${tmp_dict}    Create Dictionary   alarmId=${alarmId}    alarmName=${alarmName}    faultId=${faultId}    faultName=${faultName}
        ...    severity=${severity}    configObjectName=${configObjectName}    btsObservationTime=${btsObservationTime}
        Set To Dictionary    ${all_alarms_dict}    ${alarmLastUpdateTime}    ${tmp_dict}
    END
    Log    ${all_alarms_dict}

    @{notAllowedAlarms}    Create List
    FOR    ${updatetime}    ${alarm_dict}    IN    &{all_alarms_dict}
        Set To Dictionary    ${alarm_dict}    ${alarmTimeType}    ${updatetime}
        ${faultId}    Get From Dictionary    ${alarm_dict}    faultId
        ${faultName}    Get From Dictionary    ${alarm_dict}    faultName
        ${severity}    Get From Dictionary    ${alarm_dict}    severity
        Continue For Loop If    '${faultId}' in ${allowed_faults_final} or '${faultName}' in ${allowed_faults_final}
        Append To List    ${notAllowedAlarms}    ${alarm_dict}
    END
    log    ${notAllowedAlarms}

    FOR    ${fault}    IN    @{notAllowedAlarms}
        ${se}    Set Variable    ${fault}[severity]
        ${fi}    Set Variable    ${fault}[faultId]
        ${fn}    Set Variable    ${fault}[faultName]
        ${con}    Set Variable    ${fault}[configObjectName]
        ${appear}    Set Variable    ${fault}[btsObservationTime]
        ${lastUpdateTime}    Set Variable    ${fault}[${alarmTimeType}]
        ${msg}    Set Variable    | ${se} | ${fi} | ${fn} | ${con} | Appeared : ${appear} | ${alarmTimeType} : ${lastUpdateTime}
        Run Keyword And Continue On Failure    Run Keyword If    '${fi}' in ${not_allowed_active_fault}
        ...    Fail    msg=[ ERROR ] Trunk Roll Alarms ${msg}
        ...    ELSE IF    '${fi}' in ${not_allowed_histor_fault}    Fail   msg=[ ERROR ] SW reset recovery ${msg}
        ...    ELSE    Fail   msg=[ ERROR ] Not Allowed Alarm ${msg}
    END

#####################################################################################
##                                     PMcounter                                   ##
#####################################################################################
Verify DL and UL throughput
    [Arguments]    ${refresh_period}    ${dltp_threshold}    ${ultp_threshold}    ${cell_id}=1
    ${pm_counter_file}=    get PM counter file    ${refresh_period}
    ${PDCP_DATA_RATE_MEAN_UL}=    get_counter_value_from_counter_file    ${pm_counter_file}    M8012C23    cell_id=${cell_id}
    ${PDCP_DATA_RATE_MEAN_DL}=    get_counter_value_from_counter_file    ${pm_counter_file}    M8012C26    cell_id=${cell_id}
    Run Keyword And Continue On Failure    Should Be True    ${PDCP_DATA_RATE_MEAN_UL}>=${ultp_threshold}
    ...    msg=[ERROR]PDCP_DATA_UL is NOT on Target: | PDCP_DATA_UL: ${PDCP_DATA_RATE_MEAN_UL} | ULTP_Threshold: ${ultp_threshold} |.
    Run Keyword And Continue On Failure    Should Be True    ${PDCP_DATA_RATE_MEAN_DL}>=${dltp_threshold}
    ...    msg=[ERROR]PDCP_DATA_DL is NOT on Target: | PDCP_DATA_DL: ${PDCP_DATA_RATE_MEAN_DL} | DLTP_Threshold: ${dltp_threshold} |.

Get PM Counter File
    [Documentation]    To get the latest PM counter file. 1-to get current time; 2-to calculate the remain time before end of current period;
    ...    3-to sleep (refresh_period + remain time + 30s time buffer)
    ...    | Arguments | Default | Mandatory | Description |
    ...    | refresh_period | NA | Y | the refresh period (minutes) of pm counter. such as 3, 5, 15 .etc |
    [Arguments]    ${refresh_period}
    ${remain_time}=    get_counter_file_remaining_time    counter_refresh_period=${refresh_period}min
    ##    the actual remain time is ${remain_time}-80, the addtional 80s is due to time buffer
    ${sleep_time}=    evaluate    ${remain_time} + ${refresh_period} * 60 + 30
    ## add 30s, in order to get the latest pmcounter file correct
    Log To Console    \n[INFO]:Start to get latest PM file, Waiting ${sleep_time}s ...
    sleep    ${sleep_time}
    ${pm_counter_file}=    Download Latest Pmcounter    local_path=${TEST_LOG_DIR}/
    [Return]    ${pm_counter_file}

#####################################################################################
##                        HBTE Programable attenuation                             ##
#####################################################################################
Adjust HBTE attenuation values
    [Arguments]    ${ip}    ${ports_and_values}
    [Documentation]    | The Keyword is only used to set HBTE attenuator valuses.
    ...    ${ports_and_values} should be : p1:v1; p2:v2; p3,v3 |
    ...    | ${ip} | 10.108.241.30 |
    ...    | ${ports_and_values} | 1:15; 2:20; 3:127 |
    ${tmp_ports_values}    Set Variable    ${ports_and_values.replace(' ','')}
    ${ports_values}    Set Variable    ${tmp_ports_values.replace(':',' ')}
    Telnet.Open connection    ${ip}    prompt=Radio Rack>
    Telnet.set timeout    5s
    Telnet.Login    username=USER1    password=''    login_prompt=UserName:    password_prompt=Radio Rack>    login_timeout=10s
    Telnet and execute command    att
    Telnet and execute command    att ${ports_values}
    Telnet and execute command    att
    [Teardown]    Telnet.close connection

Adjust TOPYOUNG attenuation values
    [Arguments]    ${ip}    ${ports_and_values}
    [Documentation]    | The Keyword is only used to set RF matrix values.
    ...    ${ports_and_values} should be : c1:v1; c2:v2; c3:v3 |
    ...    | ${ip} | 10.68.139.140 |

    ${tmp_ports_values}    Set Variable    ${ports_and_values.replace(' ','')}
    ${ports_values}    Set Variable    ${tmp_ports_values.replace(';','|').replace(',','|')}
    ${ports_values_list}    Set Variable    ${ports_values.split('|')}
    Telnet.Open connection    ${ip}    prompt=>
    Telnet.set timeout    5s
    Telnet.Login    username=    password=    login_prompt=>    password_prompt=    login_timeout=10s
    FOR    ${p_v}    IN    @{ports_values_list}
        ${channel}    Set Variable    ${p_v.split(':')[0]}
        Telnet TOPYOUNG and execute command   READ:${channel}
        Telnet TOPYOUNG and execute command   SET:${p_v}
        Telnet TOPYOUNG and execute command   READ:${channel}
        Log To Console    TOPYOUNG: SET:${p_v} successfully
    END
    [Teardown]    Telnet.close connection

Telnet And Execute Command
    [Arguments]    ${command}
    ${result}    Telnet.Execute Command    ${command}    strip_prompt=True
    Run Keyword If    '${result.strip()}'!=''    Run Keywords    log to console    ${result}    AND    Fail    Set ATT value failed.

HBTE Power Switch
    [Arguments]    ${ip}    ${ports_on_off}
    [Documentation]    | The Keyword is only used to set HBTE attenuator valuses.
    ...    ${ports_on_off} should be : p1:on, p2:off, p3,off |
    ...    | ${ip} | 10.108.241.6 |
    ...    | ${ports_on_off} | 1:on; 2:off; 3:off |
    ${tmp_ports_values}    Set Variable    ${ports_on_off.replace(' ','')}
    ${ports_values_list}    Set Variable    ${tmp_ports_values.split(';')}
    Telnet.Open connection    ${ip}    prompt=HBTE >
    Telnet.set timeout    5s
    ${telnet_wo_user}    Run Keyword And Return Status    Telnet.Login
    ...    username=admin    password=admin    login_prompt=user:    password_prompt=password:    login_timeout=10s
    Run Keyword If    not ${telnet_wo_user}    Telnet.Login
    ...    username=    password=    login_prompt=    password_prompt=    login_timeout=10s
    Run Keyword If    ${telnet_wo_user}    Telnet.Execute command    get
    FOR    ${power}    IN    @{ports_values_list}
        ${cmd_value}    Set Variable If    'on' in '${power.lower()}'    ${power.strip().replace(':on',' 1')}
        ...    ${power.strip().replace(':off',' 0')}
        log to console    HBTE command: set ${cmd_value}
        Telnet.Write Bare    set ${cmd_value}
    END
    Run Keyword If    ${telnet_wo_user}    Telnet.Execute command    get
    [Teardown]    Telnet.close connection

#####################################################################################
##                                    RF Matrix                                    ##
#####################################################################################
Adjust RF Matrix Values
    [Arguments]    ${ip}    ${ports_and_values}
    [Documentation]    | The Keyword is only used to set RF matrix values.
    ...    ${ports_and_values} should be : a1b2:v1; A2B2:v2; A5B3,v3 |
    ...    | ${ip} | 10.68.139.140 |
    ...    | ${ports_and_values} | A1B2:15; A2B2:20; A3B2:127 |
    ${tmp_ports_values}    Set Variable    ${ports_and_values.replace(' ','')}
    ${ports_values}    Set Variable    ${tmp_ports_values.replace(';','|').replace(',','|')}
    ${ports_values_list}    Set Variable    ${ports_values.split('|')}
    Telnet.Open connection    ${ip}    prompt=>
    Telnet.set timeout    5s
    Telnet.Login    username=    password=    login_prompt=>    password_prompt=    login_timeout=10s
    FOR    ${port}    IN    @{ports_values_list}
        ${index}    Get channel index    ${port.split(':')[0]}
        ${value}    Set Variable    ${port.split(':')[1]}
        Telnet TOPYOUNG and execute command   READ:${index}
        Telnet TOPYOUNG and execute command   SET:${index}:${value}
        Telnet TOPYOUNG and execute command   READ:${index}
        Log To Console    RF matrix: SET:${port.split(':')[0]}:${value} successfully
    END
    [Teardown]    Telnet.close connection

Get Channel Index
    [Arguments]    ${channel}
    ${x}    Set Variable    ${channel.strip('A').split('B')}
    ${A}    Evaluate    int(${x}[0])
    ${B}    Evaluate    int(${x}[1])
    Should Be True    ${A}<=32 and ${B}<=16     [ERROR]channel shoud be in range A32B16
    ${v}    Evaluate    ${B}%17 + (${A}-1)*16
    [Return]    ${v}

Telnet TOPYOUNG And Execute Command
    [Arguments]    ${command}
    ${out}    Telnet.Execute Command    ${command}
    ${out}    Telnet.Read Until Prompt
    Telnet.Write Bare    \r\n
    Should Contain    ${out}    ${command.split(':')[0]}    [ERROR]Execute command FAILED on TOPYOUNG: ${command}

Get sysbsh Info
    ${result}    execute command on BTS via ssh    chk sysbsh
    ${tmp_list}    Split String    ${result}    \n
    ${modules_info_list}    Create List
    FOR    ${line}    IN    @{tmp_list}
        ${isMatched}    Run Keyword And Return Status    Should Match Regexp    ${line}    A[S|B]I\\w
        Run Keyword If    ${isMatched}    Append To List    ${modules_info_list}    ${line.strip()}
    END
    Log    ${modules_info_list}

    ${result_dict}    Create Dictionary

    FOR    ${line}    IN    @{modules_info_list}
        ${hex_list}    Get Regexp Matches    ${line}    \\[([0x[0-9A-Fa-f]+)\\]    1
        ${hex}    Set Variable    ${hex_list}[0]

        ${module_list}    Get Regexp Matches    ${line}    (A[SB]I\\w)    1
        ${module}    Set Variable    ${module_list}[0]

        ${core_list}    Get Regexp Matches    ${line}    \\[0x[0-9A-Fa-f]+\\]\\s+(\\S+)    1
        ${core}    Set Variable    ${core_list}[0]

        ${bsh_list}    Get Regexp Matches    ${line}    (ssh \\S+|\\d+:\\d+)    1
        ${bsh}    Set Variable    ${bsh_list}[0]

        # Extract digit from bsh and append to core if not lfs
        ${indexed_core}    Set Variable    ${core}
        IF    '${core}' != 'lfs'
            ${digit_list}    Get Regexp Matches    ${bsh}    ([0-9]+)(?!.*[0-9])    1
            IF    ${digit_list}
                ${digit}    Set Variable    ${digit_list}[0]
                ${indexed_core}    Set Variable    ${core}-${digit}
            END
        END

        ${entry}    Create Dictionary    module=${module}    core=${indexed_core}    bsh=${bsh}
        Set To Dictionary    ${result_dict}    ${hex}    ${entry}
    END

    RETURN    ${result_dict}

Get Node Id
    [Arguments]    ${bbmod_smod}    ${core}
    Should Be True    '${bbmod_smod.upper()}' in ('ASIM', 'ASIL', 'ABIO', 'ABIP', 'ABIQ')
    ...    [ERROR] ${bbmod_smod} in NOT included in ('ASIM', 'ASIL', 'ABIO', 'ABIP', 'ABIQ').
    ${core}    Set Variable    ${core.replace('_', '-')}
    ${isNotExisted}    Run Keyword And Return Status    Variable Should Not Exist    ${modules_info_dict}
    IF    ${isNotExisted}
        ${modules_info_dict}    Get sysbsh Info
        Set Test Variable    ${modules_info_dict}
    END
    FOR    ${key}    IN    @{modules_info_dict}
        ${value}    Get From Dictionary    ${modules_info_dict}    ${key}
        ${nodeId}    Set Variable If    '${bbmod_smod}'=='${value['module']}' and '${core}'=='${value['core']}'    ${key}    ${None}
        Exit For Loop If    '${nodeId}'!='None'
    END
    Run Keyword If    '${nodeId}'=='None'
    ...    Fail    [ERROR] No nodeId is matched [ 'module': '${bbmod_smod}', 'core': '${core}' ] in ${modules_info_dict}
    [Return]    ${nodeId}


#####################################################################################
##                                RnD debug parameters                             ##
#####################################################################################

ADMIN Get RAD SW Domains
    [Arguments]    ${Detailed_Output}=true    ${timeOut}=30    ${connecTion}=default
    ${rad_domain_results}    sbts_admin.Get RAD SW Domains
    ...    detailed_output=${Detailed_Output}
    ...    timeout=${timeOut}
    ...    connection=${connecTion}
    [Return]    ${rad_domain_results}

ADMIN Set RAD debug parameters
    [Arguments]    ${Domain}    ${Name}    ${Value}    ${Persistency}=NotPersistent    ${timeOut}=30    ${connecTion}=default
    [Documentation]    [DEPRECATION WARNING] This keyword is deprecated. Use 'ADMIN Set Multiple RAD debug parameters' instead.
    sbts_admin.Set Rad Debug Parameters
    ...    domain=${Domain}
    ...    persistency=${Persistency}
    ...    name=${Name}
    ...    value=${Value}
    ...    timeout=${timeOut}
    ...    connection=${connecTion}

ADMIN Set Multiple RAD debug parameters
    [Arguments]    ${Domain}    ${rad_parameters_list}    ${Persistency}=NotPersistent    ${timeOut}=30    ${connecTion}=default
    [Documentation]    This keyword is used to configure debug parameters for a domain.
    ...    | Arguments | Mandatory | Defalt | Description |
    ...    | Domain | Yes | NA | domain name for R&D debug parameter |
    ...    | rad_parameters_list | Yes | NA | e.g.NrUlPhy: [{"name":"enableRespCapture","value":'1'},{"name":"phyEventEnableExt","value":'32768'}]. |
    ...    | Persistency | No | NotPersistent | One of < Persistent / OneReset / NotPersistent >. |
    ...    | timeOut | No | 30 | Defalt is 30s. Time in seconds to wait for positive procedure result. |
    ...    | ConecTion | No | defalt | AdminConnection connection: AdminConnection. |
    ${rad_parameters_list}    Convert To String    ${rad_parameters_list}
    ${rad_parameters}    Evaluate    ${rad_parameters_list}
    sbts_admin.set_multiple_rad_debug_parameters
    ...    domain=${Domain}
    ...    persistency=${Persistency}
    ...    rad_parameters=${rad_parameters}
    ...    timeout=${timeOut}
    ...    connection=${connecTion}

ADMIN Get RAD debug parameter
    [Arguments]    ${Domain}    ${timeOut}=30    ${Detailed_Output}=true    ${connecTion}=default
    ${rad_debug_parameters_results}    sbts_admin.Get Rad Debug Parameters
    ...    domain=${Domain}
    ...    timeout=${timeOut}
    ...    detailed_output=${Detailed_Output}
    ...    connection=${connecTion}
    [Return]    ${rad_debug_parameters_results}

ADMIN Get RAD debug parameter details
    [Arguments]    ${Domain}    ${parameter_Name}    ${timeOut}=30    ${Detailed_Output}=true    ${connecTion}=default
    ${rad_debug_parameters_detail_results}    sbts_admin.Get RAD debug parameter details
    ...    domain=${Domain}
    ...    parameter_name=${parameter_Name}
    ...    timeout=${timeOut}
    ...    detailed_output=${Detailed_Output}
    ...    connection=${connecTion}
    [Return]    ${rad_debug_parameters_detail_results}

ADMIN Reset All Rad Debug Parameters
    [Arguments]    ${timeOut}=30    ${Detailed_Output}=true    ${connecTion}=default
    ${reset_all_rad_debug_parameters_results}    sbts_admin.Reset All Rad Debug Parameters
    ...    timeout=${timeOut}
    ...    detailed_output=${Detailed_Output}
    ...    connection=${connecTion}
    [Return]    ${reset_all_rad_debug_parameters_results}

ADMIN Reset Rad Debug Parameters
    [Arguments]    ${Domain}    ${Name}    ${timeOut}=30    ${Detailed_Output}=true    ${connecTion}=default
    ${reset_rad_debug_parameters_results}    sbts_admin.Reset Rad Debug Parameters
    ...    domain=${Domain}
    ...    name=${Name}
    ...    timeout=${timeOut}
    ...    detailed_output=${Detailed_Output}
    ...    connection=${connecTion}
    [Return]    ${reset_rad_debug_parameters_results}

ADMIN Change Bts Rad Parameters
    [Arguments]    ${component}    ${params}
    sbts_admin.change_bts_rad_parameters
    ...    component=${Component}
    ...    params=${Params}

#####################################################################################
##                           BSR package download and active                       ##
#####################################################################################

Get BSR package
    ${issftp}     Run Keyword And Return Status    Get BSR package from sftp
    Run Keyword If    not ${issftp}    Get BSR package from ROTTA

Get BSR package from sftp
    [Arguments]    ${bsr_file}=BSR_AEQE_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001.zip    ${local_file}=/home/ute/logs/
    ...    ${ftp_ip}=10.69.6.6    ${user}=ute    ${pwd}=Cdslabadmin@    ${port}=22
    [Documentation]  To download BSR file from sftp server.
    ...    | Input Parameters | Man | Default | Description |
    ...    | bsr_file | No | BSR_AEQE_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001.zip | BSR name. Default is from sftp://ute@10.69.6.6/home/ute/hhh/ |
    ...    | local_file | No | /home/ute/logs/ | the local path to store BSR file |
    ...    | ftp_ip | No  | 10.69.6.6 | ip address of sftp server |
    ...    | user | No | ute | username of sftp server |
    ...    | pwd | No | Cdslabadmin@ | password of sftp server |
    ...    | port | No | 22 | sftp port |
    ${isExisted}    Run Keyword And Return Status    Check BSR size    ${local_file}${bsr_file}
    ${download_file}    Run Keyword If    not ${isExisted}    sftp_download    ${ftp_ip}    ${port}    ${user}    ${pwd}
    ...    /home/ute/hhh/${bsr_file}    ${local_file}
    Run Keyword If    not ${isExisted}    Check BSR size    ${download_file}
    Log To Console    \n[INFO]BSR file from sftp: ${bsr_path}
    Set Suite Variable    ${bsr_path}

Get BSR package from ROTTA
    [Arguments]    ${bsr_file}=BSR_AEQE_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001.zip    ${local_file}=/mnt/rotta/BSR/
    [Documentation]  To download BSR file from ROTTA server.
    ${isExisted}    Run Keyword And Return Status    Check BSR size    ${local_file}${bsr_file}
    Run Keyword If    not ${isExisted}    Mount ROTTA network drive to the mounting point
    Run Keyword If    not ${isExisted}    Check BSR size    ${local_file}${bsr_file}
    Log To Console    \n[INFO]BSR file from ROTTA: ${bsr_path}
    Set Suite Variable    ${bsr_path}

Mount ROTTA network drive to the mounting point
    [Arguments]    ${local_file}=/mnt/rotta/BSR/    ${rotta_link}=//eseefsn50.emea.nsn-net.net/rotta4internal/Rotta4internal_5G/hangzhou/BSR/
    ${cifs}     ${output}    Run and Return RC and Output    sudo apt install cifs-utils
    Run Keyword If    ${cifs}!=0    Log To Console    [ERROR] ${output}
    ${mkdir}    ${output}    Run and Return RC and Output    sudo mkdir -p ${local_file}
    Run Keyword If    ${mkdir}!=0    Log To Console    [ERROR] ${output}
    ${mount}    ${output}    Run and Return RC and Output
    ...    sudo mount -t cifs -o user=yughou,pass=Nokia202502@,domain=NSN-INTRA,vers=1.0 ${rotta_link} ${local_file}
    Should Be True    ${mount}==0    [ERROR] ${output}
    ${df}    ${output}    Run and Return RC and Output    df -h -F cifs
    Run Keyword If    ${df}==0    Log To Console    [SUCCESSED]\n${output}

Umount ROTTA
    [Arguments]    ${local_file}=/mnt/rotta/BSR/
    ${umount}     ${output}    Run and Return RC and Output    sudo umount ${local_file}
    Should Be True    ${umount}==0    [ERROR] ${output}

Check BSR size
    [Arguments]    ${file}
    ${du}     ${output}    Run and Return RC and Output    du ${file}
    Should Be True    ${du}==0    [ERROR] ${output}
    Run Keyword If    ${output.split('\t')[0]}==0     Run Keywords    Run    rm -rf ${file}
    ...    AND    Fail    [ERROR] BSR file size is 0.    ELSE    Set Suite Variable    ${bsr_path}    ${file}

Load and active BSR
    [Arguments]    ${bsr_file}=${bsr_path}
    [Documentation]  To load and active BSR package.
    ...    | Input Parameters | Man | Default | Description |
    ...    | bsr_file | Yes | NO | BSR file from 'Get BSR package from sftp' |
    ...    Example:
    ...    | ${bsr} | Get BSR package from sftp |
    ...    | Load and active BSR | ${bsr} |
    sbts_admin.update_software    ${bsr_file}

########################################################################
##                         BBMOD lock and unlock                      ##
########################################################################

Get Board Info By Index
    [Documentation]
    ...    Description: Get SMOD/BBMOD/RMOD detail info by index
    ...    ${board_index} Should be 'int' and start from 1, should match the value with SMOS-* or BBMOD-* or RMOD-*.
    ...    ${board_type} Should be SMOD | BBMOD | RMOD.
    [Arguments]    ${board_type}    ${board_index}=${None}
    ${isNumber}    Robot Isinstance    ${board_index}    int
    Run Keyword If    ${isNumber}    Log To Console    \n[INFO] Get ${board_type}-${board_index} infomation ...
    ...    ELSE    Run Keywords    Set Test Variable    ${board_index}    ${EMPTY}
    ...    AND     Log To Console    \n[WARN] The board_index::${board_index} is NOT 'int', and will get all ${board_type}s infomations.
    &{hw_info}    sbts_admin.get_detected_hw_info
    ${hw_alais_1st}    Run Keyword If    '${board_type.lower()}'=='bbmod'    Set Variable    basebandModules
    ...    ELSE IF    '${board_type.lower()}'=='rmod'    Set Variable    radioModules
    ...    ELSE    Set Variable    systemModules
    @{list_boards}    Set variable If    '${board_type.lower()}'=='rmod'    ${hw_info['${hw_alais_1st}']['rmod']}    ${hw_info['${hw_alais_1st}']}
    ${count_boards}    Get length    ${list_boards}
    Should be true    ${count_boards}>=1    msg=[ERROR] No ${board_type} found.
    &{dict_boards_detail_info}   Create dictionary
    FOR    ${board}    IN    @{list_boards}
        ${board_configuration}    Set Variable    ${board['id']['configuration']}
        ${status}    Run Keyword And Return Status    Should Contain   ${board_configuration}   ${board_type}-${board_index}
        ${index}    Set Variable If    ${isNumber}    ${board_index}    ${board_configuration.split('-', -1)[-1]}
        Run keyword if   '${status}'=='True'    Set to dictionary    ${dict_boards_detail_info}    ${index}    ${board}
    END
    ${result}    Set Variable If    ${isNumber}    ${dict_boards_detail_info['${board_index}']}    ${dict_boards_detail_info}
    [Return]  ${result}

Get BBMOD ID
    [Arguments]    ${bbmod_name}
    [Documentation]    To get configuration or runtime id of BMOD.
    ...    {bbmod_name} should be ABIX or ABIX_R. such as ABIN or ABIN_R
    ${bbmod_info_dict}    Get Board Info By Index    BBMOD
    ${bbmod_info_list}    Get Dictionary Values    ${bbmod_info_dict}
    ${bbmod_name_list}    Set Variable    ${bbmod_name.upper().split('_')}
    ${id_type}    Set Variable If    '${bbmod_name_list[-1]}'=='R'    runtime    configuration
    FOR    ${bbmod}    IN    @{bbmod_info_list}
        ${abix_info}    Set Variable If    '${bbmod_name_list[0]}' in '${bbmod['productName']}'    ${bbmod['id']['${id_type}']}    None
        Exit For Loop If    '${abix_info}'!='None'
    END
    ${abix_r_id}    Run Keyword If    '${abix_info}'!='None'    Set Variable    ${abix_info.split('/')[-1]}
    ...    ELSE    Fail    msg=[ERROR] Can NOT find ${bbmod_name.upper()} to installed.
    [Return]    ${abix_r_id}

BBMOD operation via WebUI
    [Arguments]    ${operation_type}    ${bbmod_name_or_id}
    [Documentation]    To lock/unlock/reset BBMOD via WebUI.
    ...    {operation_type} should be locked | unlocked | reset.
    ...    {bbmod_name_or_id} is bbmod name or id. if bbmod name, it will get 'baseband_id' by bbmod name, then operate bbmod by 'baseband_id'.
    ${operation_type_list}    Create List    Locked    Unlocked    Reset
    Should Contain    ${operation_type_list}    ${operation_type.title()}
    ...    [ERROR] The operation_type::${operation_type} should be in ('Locked', 'Unlocked', 'Reset').
    ${isID}    Run Keyword And Return Status    Convert To Integer    ${bbmod_name_or_id}
    ${isName}    Run Keyword And Return Status    Should be True    'ABI' in '${bbmod_name_or_id}'
    ...    [ERROR] ${bbmod_name_or_id} is NOT a id or ABIx, it's should be bbmod id or bbmod name.
    ${abix_id}    Run Keyword If    ${isName}    Get BBMOD ID    ${bbmod_name_or_id}
    ${bbmod_idx}    Set Variable If    ${isID}    ${bbmod_name_or_id}    ${abix_id.split('-')[-1]}
    ${BBMOD_dist_name}    Set Variable    MRBTS-${btsid}/EQM-1/APEQM-1/BBMOD-${bbmod_idx}

    Close Startup View Window

    Run Keyword If    '${operation_type.lower()}'=='reset'    selenium_coam.reset_baseband    baseband_index=${bbmod_idx}    sbts=suite
    ...    ELSE    Run Keywords    selenium_coam.set_parameter_value    dist_name=${BBMOD_dist_name}
    ...    filter_param=Administrative state    new_value=${operation_type.title()}   abbr=administrativeState    sbts=suite
    ...    AND    selenium_coam.validate_plan    sbts=suite
    ...    AND    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=300    sbts=suite
