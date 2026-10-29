*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]   CB009836-Test-Template-Keywords
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : christophe.samson@nokia.com
...               Creation Date               : 03-01-2024
...               Modified Date               : 03-01-2024
...               Last Modified by            : christophe.samson@nokia.com
...               Version   Date          Author                                   Notes
...               0.1       03-01-2024    christophe.samson@nokia.com              Creation
# --------------------------------------------------------------------------------------------------------------------------------------------------

Library      ta_emss
Library      ta_messaging

# Libraries CB009836
Library      ../python/resources.py
Library      ../python/Dev_lib.py

# Resources CB009836
Resource     configuration_id.robot
Resource     CB009836-Keywords.robot
Resource     CB009836-TL-Preparation-Keywords.robot

*** Variables ***

${path_config_custom}          ${CURDIR}/../config/custom
${LuaFileToUsed_path_ASOE}     ${path_config_custom}/basic_wts_CLOUD_5G_O_E_AP_LOO_8DL8UL_SANSA_FS_ECPRI_CMWV_TDD_6Ues.lua
# CS : 09/01/25 : FS Canada is not supported anymore (see CNI-143799 - Phase out of CNI-110347) => change to FS TddLte_3
${LuaFileToUsed_path_TddLte_3_ASOE}
...                            ${path_config_custom}/basic_wts_CLOUD_5G_O_E_AP_LOO_8DL8UL_SANSA_FS_ECPRI_CMWV_TDD_6Ues_TddLte_3.lua
${LuaFileToUsed_path_TddLte_3_Canada_ASOE}
...                            ${path_config_custom}/basic_wts_CLOUD_5G_O_E_AP_LOO_8DL8UL_SANSA_FS_ECPRI_CMWV_TDD_6Ues_TddLte_3_Canada.lua
${LuaFileToUsed_path_TddLte_3_Canada_ASOE_AP_LOO}
...                            ${path_config_custom}/basic_wts_CLOUD_5G_O_E_AP_LOO_SANSA_FS_ECPRI_CMWV_TDD_6Ues_TddLte_3_Canada.lua
${LuaFileToUsed_path_TddLte_3_Canada_ASOE_TC_B1}
...                            ${path_config_custom}/basic_wts_CLOUD_5G_O_E_AP_LOO_8DL8UL_SANSA_FS_ECPRI_CMWV_TDD_6Ues_TddLte_3_Canada_9836_B_01.lua
${LuaFileToUsed_path_TddLte_3_Canada_ASOE_TC_B1_2}
...                            ${path_config_custom}/basic_wts_CLOUD_5G_O_E_AP_LOO_8DL8UL_SANSA_FS_ECPRI_CMWV_TDD_6Ues_TddLte_3_Canada_9836_B_02.lua
# CS : 09/01/25 : FS Canada is not supported anymore (see CNI-143799 - Phase out of CNI-110347) => change to FS TddLte_3
${LuaFileToUsed_path_TddLte_3_ASOE_TC_B1_2}
...                            ${path_config_custom}/basic_wts_CLOUD_5G_O_E_AP_LOO_8DL8UL_SANSA_FS_ECPRI_CMWV_TDD_6Ues_TddLte_3_9836_B_02.lua
${LuaFileToUsed_path_ABIP}     ${path_config_custom}/basic_wts_CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD_6Ues.lua
${LuaFileToUsed_path_TddLte_3_Canada_ABIP}    ${path_config_custom}/basic_wts_CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD_6Ues_TddLte_3_Canada.lua
${LuaFileToUsed_path_TddLte_3_Canada_DLMUMIMO_ABIP}
...                                  ${path_config_custom}/basic_wts_CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD_6Ues_TddLte_3_Canada_DLMUMIMO.lua
${LuaFileToUsed_path}          ${LuaFileToUsed_path_ASOE}
# ${LuaFileToUsed_path}          ${LuaFileToUsed_path_TddLte_3_Canada_ASOE}

@{PARAMS_IN_VENDOR}                               ${EMPTY}
${PM_COUNTER_INTERVAL}                            5min
${act9836TddCsirsAllocOptimization}               true

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

TC CB009836 3 Cells
    [Documentation]
    ...     test template for CB009836 (Topology to used should be CLOUD_5G_O_E_AP_LOO_8DL8UL)
    ...     Conditions:     it is based on the arguments ${param}  ${dictParam}  ${vendor_custom} ${dict_ues} ${nrCell}
    ...     Actions:        it performs the call setup for multi-ues on different cells with DL traffic
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Arguments]             ${param}
    ...                     ${dictParam}
    ...                     ${vendor_custom}
    ...                     ${dict_ues}
    ...                     ${nrCell}
    ...                     ${Kw TestLine Preparation}=${EMPTY}
    ...                     ${kw Set RAD Params}=${EMPTY}
    ...                     ${kw NIDD Set}=${EMPTY}
    ...                     ${kw NIDD Check}=${EMPTY}
    ...                     ${kw Set TestMode}=${EMPTY}
    ...                     ${kw Active Config}=${EMPTY}
    ...                     ${kw Specific Set TestMode Before Attach}=${EMPTY}
    ...                     ${kw Specific Set TestMode After Attach}=${EMPTY}
    ...                     ${NIDD_9836_PARAMS}=${NIDD_9836_Q_L_PARAMS}
    ...                     ${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}=Convert TTI trace from csv to dict CB009836
    ...                     ${kw Check SCF parameters}=${EMPTY}
    ...                     ${kw Specific Check Tti}=${EMPTY}
    ...                     ${kw Specific Check}=${EMPTY}
    ...                     ${kw Specific Check CPRT}=${EMPTY}
    ...                     ${Kw Update NIDD Test Parameters}=${EMPTY}
    ...                     ${NIDD_9836_TEST_PARAMS}=${EMPTY}
    ...                     ${Json test configuration}=${EMPTY}
    ...                     ${FrameStructure}=5GC001208
    ...                     ${TypeCheck}=allCellsSameSSB
    ...                     ${skip}=${False}

    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    ${topoOK}=      Evaluate     ${topoOK_1} or ${topoOK_2}
    ${msg_err}=     Catenate    topology USED [${topoUsed}] is not CORRECT for this test [${TEST NAME}].
    Run Keyword If            '${topoOK}'=='False'   dated log   ${consTraceColorBgRed}${consTraceColorYellow}${msg_err}${defColor} Plz, Check it...
    Return From Keyword If    '${topoOK}'=='False'
    Init Sequence           ${param}
    Create Header Csv Tput Test result
    ${ull1spcells_syslog}=    Create List
    ${dll1spcells_syslog}=    Create List
    set test variable     ${ull1spcells_syslog}
    set test variable     ${dll1spcells_syslog}
    Run Keyword If    '${Json test configuration}'!='${EMPTY}'    load Json test data   ${Json test configuration}   ${dict_ues}
    ...                                                                                 ${vendor_custom}   ${param}
    StringTool.printLineWithTitle     title=Display NIDD PARAMETERS of the Test TO SET
    FOR    ${item}    IN    @{NIDD_9836_PARAMS}
         continue for loop if     'list_name' in ${item}
         ${msg_display}=    StringTool.getHeaderLine    ${item}[dist_name]/${item}[pname]     ${item}[value]
         dated log      ${msg_display}
         # dated log    dist_name=${item}[dist_name] pname=${item}[pname] value=${item}[value]
    END
    StringTool.printLineWithTitle     title=-
    Step         Init CB009836 Test Variables    vendor_custom=${vendor_custom}    dict_ues=${dict_ues}    totalNbOfUe=${param.totalNbOfUe}
    Run Keyword If    '${kw Set RAD Params}'!='${EMPTY}'     Step         Run Keyword     ${kw Set RAD Params}
    # return from Keyword

    # ${iphy_file} is dediceted to topo ASOE with 4 Cells
    # ${iphy_file_6Cells} is dedicated to topo ASOE with 3 TDD Cells
    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    dated log     Topology is ${topoUsed}
    ${iphy_file_to_use}    Set Variable If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   ${iphy_file_6Cells}
    ...                                                                                             ${iphy_file_4Cells}
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_to_use}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_to_use}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [/tmp/${iphy_filename}] to AirPhone

    # Apply delta commissioning (WITH_APPLY_DELTA_COMMISSIONING=1) if requested
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1' and '${UPDATE_SCF}'=='1' and '${Kw TestLine Preparation}'!='${EMPTY}'
    ...                          Run Keywords       ${Kw TestLine Preparation}      output_scf=${test_scf_file}
    ...                              AND            Set Suite Variable              ${test_scf_file}
    # return from Keyword

    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...                                                Set CB009836 NIDD PARAMETERS VERSION 3 with SET into SCF     list=${NIDD_9836_PARAMS}

    # Set NIDD PARAM If Needed / Kw use ${test_scf_file} file
    Run Keyword If    '${kw NIDD Set}'!='${EMPTY}' and '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'     ${kw NIDD Set}   list=${NIDD_9836_PARAMS}
    # return from Keyword

   # Check if NIDD PARAM are as expected
    Run Keyword If    '${kw NIDD Check}'!='${EMPTY}'      ${kw NIDD Check}  list=${NIDD_9836_PARAMS}

    ${w_getSCF}=    Set Variable If     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'   true
    ...                                                                              false
    Run Keyword If    '${kw Active Config}'!='${EMPTY}'      ${kw Active Config}    w_getSCF=${w_getSCF}
    ...    ELSE                                              CB009836-A-Config-tests-Keywords.Log config in result file

    # update local scf.xml
    ${test_scf_file}      Run Keyword If    '${kw Active Config}'!='${EMPTY}'  COAM Get SCF    file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ...                      ELSE                                              set Variable    ${test_scf_file}
    set suite variable     ${test_scf_file}

    # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure       Admin Validate SCF     scf_path_file=${test_scf_file}
    robot_extension.Run Keyword And Warn On Failure       Get Cipher and Integrity Parameters From SCF

    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    ${cond1}=          Evaluate     '${bts_status.lower()}'=='configured' or '${bts_status.lower()}'=='onair'
    ${condResetTL}=    Evaluate     '${ret.lower()}'=='pass' and not ${cond1}
    dated log     condResetTL=${condResetTL}
    Run Keyword If     ${condResetTL}    Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured/OnAir [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}

    ${test_scf_file}             COAM Get SCF        local_dir_path=${LOG_PATH}      file=SCF.xml   alias=coam_gnb
    Set Suite Variable           ${test_scf_file}
    ${scf_modif_to_commit_present}=    run keyword and return status  Variable Should Exist  ${scf_modif_to_commit}
    run keyword if    ${scf_modif_to_commit_present}    Set Test Variable  ${test_scf_file}     ${scf_modif_to_commit}
    Set Suite Variable           ${test_scf_file}

    ${actTddCsirsAllocOptimization}   set variable     ${act9836TddCsirsAllocOptimization}
    @{PARAMS_IN_VENDOR}    Create List     actTddCsirsAllocOptimization=${actTddCsirsAllocOptimization}
    set test variable     ${PARAMS_IN_VENDOR}
    ${cond1}=          Evaluate     '${bts_status.lower()}'!='configured' or '${bts_status.lower()}'!='onair'
    ${condResetTL}=    Evaluate     '${ret.lower()}'=='pass' and ${cond1}
    dated log     condResetTL=${condResetTL}
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...         Critical Step    CB009836-TL-Preparation-Keywords.Deploy Vendor File to activate CB009836     PARAMS_IN_VENDOR=${PARAMS_IN_VENDOR}
    ...                                                                                                       is_perform_full_commissioning=${True}
    ...   ELSE
    ...          Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'
   ...             Run Keywords    Dated Log new line       ${consTraceColorRed}BEWARE that Deploy Vendor File Config is already DONE!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=4min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter
    # return from Keyword

    Run keyword and continue on failure     Verify actTddCsirsAllocOptimization status    status=${actTddCsirsAllocOptimization}

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER Commissioning / TL Restart${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs
    robot_extension.Run Keyword And Warn On Failure         Extract l2::ps::cnfg::AddressDistributionReq_t from Syslog
    robot_extension.Run Keyword And Warn On Failure         Display PRB POOLING NIDD param
    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    # save some test parameters as vendor file or Ue settings into ${testCaseDir}
    nps_9836_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${vendor_custom}    filename=data_test.json

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER Commissioning / TL Restart${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs
    # robot_extension.Run Keyword And Warn On Failure         Check UL and DL l1Subpool Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure         Display PRB POOLING NIDD param
    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    # save some test parameters as vendor file or Ue settings into ${testCaseDir}
    nps_9836_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${vendor_custom}    filename=data_test.json

    # Configure the current setting for all the ue's
    ${param.totalNbOfUe}    get length          ${dict_ues}
    Step                    Configure the setting for the ${param.totalNbOfUe} UEs
    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${param.totalNbOfUe}
        ${current_ue}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        Set To Dictionary             ${current_ueSetting}          trf_id              1
        Set To Dictionary             ${current_ueSetting}          target_gnb          ${param.targetGnb}
        Set To Dictionary             ${current_ueSetting}          size                ${dict_ues[${current_id}].packet_size}

        # Dispatching each ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ueSetting}          DL_throughput          ${dict_ues[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          UL_throughput          ${dict_ues[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}          protocol               ${dict_ues[${current_id}].protocol}

        Append To List                ${listOfUes}                  ${current_ueSetting}

        # save some test parameters as vendor file or Ue settings into ${testCaseDir}
        add_dictionary_to_json       ${testCaseDir}     'Ue_${current_ue}'   ${current_ueSetting}    data_test.json
    END
    # Dated Log New Line                UE_List=${listOfUes}
    display_list_parameters_w_name      ${listOfUes}   name=Ue   msg=Display Of listOfUes
    CB009836-Keywords.Check Multi Ues Setting In List        multiUesList=${listOfUes}

    set test Variable     ${listOfUes}
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Init   prefix=CellSetup.Attach.SA
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start  actionCORE=${isCaptureCORE}
    ...                                                                                        actionCPRT=${isCaptureCPRT}
    ...                                                                                        actionL1L2=${isCaptureL1L2}
    ...                                                                                        actionTti=${False}

    # ${kw Set TestMode} is a robot Kw that allow to modify cfg file
    Run Keyword If    '${kw Set TestMode}'!='${EMPTY}'       ${kw Set TestMode}

    Setup devices aliases
    robot_extension.Run Keyword And Warn On Failure    Enable internal mirroring for alias    gNB2

    Run Keyword If    '${Kw Update NIDD Test Parameters}'!='${EMPTY}'    Step     Run Keyword   ${Kw Update NIDD Test Parameters}

    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    ${LuaFileToUsed}=      Run Keyword If    '${W_CUSTOM_LUA_FILE_TO_USED}'=='1'       Install lua File into WTS    ${LuaFileToUsed_path}
    ...                        ELSE                                                    Set Variable                 ${EMPTY}

    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog2_beforeCellSetup
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    run Keyword If    '${ret}' == 'FAIL'     BuiltIn.log    btslog.Stop Btslog is ${ret}! with ${syslogpath}     level=ERROR     console=True
    ${fileExists}=     nps_9836_tools.file_exists   ${syslogpath}
    ${ret}    ${syslog_filename}   Run Keyword If   ${fileExists}==${True}
    ...                                           Run Keyword And Ignore Error    nps_9836_tools.return_basename   ${syslogpath}
    ...                              ELSE         ObtainVariablesKeyword
    robot_extension.Run Keyword And Warn On Failure   declare Trace in Trace List    Type=SysLog  Savedir=${dir_syslog}
    ...                          file_name=${syslog_filename}   Trigger=btslog2_beforeCellSetup
    robot_extension.Run Keyword And Warn On Failure   Check UL and DL l1Subpool Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}
    ...         Critical Step           Basic Call to Setup Wtsemu SA           nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${True}
    ...                                                             LuaFileToUsed=${LuaFileToUsed}
    # ...                                                             Kw_TM=${kw Set TestMode}
    ...   ELSE
    ...         Critical Step           CallSetup.Setup Wtsemu SA               nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${False}

    # test works only with CELL1, CELL2 and CELL3 (CELL4 is Locked)
    Dev_lib.start_to_capture_infomodel_log
    Run Keyword If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   CB009836-Keywords.Cell 1 cell 2 cell3 and cell4 Should Be Onair
    ...    ELSE                                                             All Cells Should Be Onair
    Dev_lib.stop_to_capture_infomodel_log

    # take into account SCOUT
    ${host_vm_ip}=  configuration_id.Get Host IP Address  host_index=1
    Run Keyword And Ignore Error    configuration_id.Start Testline Scout Monitor  host_vm_ip=${host_vm_ip}
    # ${return}    ${output}    robot_extension.Run Keyword And Warn On Failure    Setup.Produce Scout Data    timeout=120
    ${return}    ${output}    robot_extension.Run Keyword And Warn On Failure
    ...           CB009836-Test-Template-Keywords.Set SCOUT TC ID for Reporting    timeout=120
    run keyword if    '${return}'=='FAIL'    BuiltIn.log    Set SCOUT TC ID for Reporting ${return}! - reason=${output}
    ...                                                     level=ERROR    console=True

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs
    # robot_extension.Run Keyword And Warn On Failure         Check UL and DL l1Subpool Assignment in Syslogs

    # test all cells mapped on same L1 Pool
    ${isFileNameDLCellMappingPresent}    Run Keyword And Return Status    Should Not Be Empty   ${FileNameDLCellMapping}
    ${fileExists}=     nps_9836_tools.file_exists   ${FileNameDLCellMapping}
    ${FileNameDLCellMapping}=    Set Variable If    ${fileExists}    ${FileNameDLCellMapping}    ${None}
    Run Keyword If   '${isFileNameDLCellMappingPresent}' == 'False' or not ${fileExists}
    ...                BuiltIn.Log    DL Cell mapping file not present (from Syslog), please check the config    level=WARN    console=yes
    ...    ELSE        check Dl Cell mapping from Syslog ${FileNameDLCellMapping}

    ${ret}  ${output}=    robot_extension.Run Keyword And Warn On Failure
    ...                                           Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog     NbrCells=3
    ${sorted_csirsGroups}           Set Variable     ${output[0]}
    ${sorted_cellcsirs_slotoffset}  Set Variable     ${output[1]}
    ${sorted_uecsirs_slotoffset}    Set Variable     ${output[2]}
    ${sorted_trscsirs_slotoffset}    Set Variable     ${output[3]}
    ${sorted_trscsirs_ssb_slotoffset}    Set Variable     ${output[4]}
    Dated Log New Line    sorted_csirsGroups=${sorted_csirsGroups}
    Dated Log New Line    sorted_cellcsirs_slotoffset=${sorted_cellcsirs_slotoffset}
    Dated Log New Line    sorted_trscsirs_slotoffset=${sorted_trscsirs_slotoffset}
    Dated Log New Line    sorted_trscsirs_ssb_slotoffset=${sorted_trscsirs_ssb_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}

    # check that we have all relation cell and csrirspool for all cells
    ${cell_csirsGroups}=  Get length   ${sorted_csirsGroups}
    Dated log    length of cell_csirsGroups = ${sorted_csirsGroups}
    ${List_nrCellIdentity}   Create List     16385    16386    16387    16388
    ${cell_missing_list}=    check_all_cell_csirspool_present      ${output[0]}    ${List_nrCellIdentity}
    ${cell_missing_in_cellcsirs_list}=    check_all_cell_in_cellcsirs_present      ${output[1]}    ${List_nrCellIdentity}
    ${NbrCellNoFound}=       Get length   ${cell_missing_list}
    ${NbrCellNoFound_in_cellcsirslist}=       Get length   ${cell_missing_in_cellcsirs_list}
    ${text}=    Catenate    Nb of cell csirsGroups relation not found = ${NbrCellNoFound} with cell_missing_list=${cell_missing_list}
    ${levellog}=    Set Variable If    '${NbrCellNoFound}' != '${NbrCellNoFound_in_cellcsirslist}'    ERROR    WARN
    Run Keyword If   '${NbrCellNoFound}' != '0'    BuiltIn.Log
    ...    msg=${text}  level=${levellog}
    ${text}=    Catenate     Nb of cellcsirs relation not found=${NbrCellNoFound_in_cellcsirslist}
    ...                      with cell_missing_in_cellcsirs_list=${cell_missing_in_cellcsirs_list}
    Run Keyword If   '${NbrCellNoFound_in_cellcsirslist}' != '0'    BuiltIn.Log
    ...    msg=${text}
    ...    level=${levellog}
    Dated log  Nb of cell csirsGroups relation not found = ${NbrCellNoFound} with cell_missing_list=${cell_missing_list}
    Dated log  Nb of cell cellcsirs relation not found = ${NbrCellNoFound_in_cellcsirslist} with cell_missing_list=${cell_missing_in_cellcsirs_list}
    ${combined_cell_missing_list}    Combine Lists    ${cell_missing_list}    ${cell_missing_in_cellcsirs_list}
    ${combined_cell_missing_list}    Remove Duplicates    ${combined_cell_missing_list}
    ${final_NbrCellNoFound}=         Get length   ${combined_cell_missing_list}
    ${text}=    Catenate    Final decision : Nb of cell csirsGroups/cellcsirs relation not found = ${final_NbrCellNoFound}
    ...                     with cell_missing_list=${combined_cell_missing_list},
    ...                     => Try Lock and Unlock cells ${combined_cell_missing_list}
    Run Keyword If     '${final_NbrCellNoFound}' != '0'       Try Lock and Unlock cells    ${combined_cell_missing_list}
    ${sorted_csirsGroups}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                          ELSE                                               Copy List    ${sorted_csirsGroups}
    ${sorted_cellcsirs_slotoffset}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                                  ELSE                                                Copy List    ${sorted_cellcsirs_slotoffset}
    ${sorted_trscsirs_slotoffset}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                                  ELSE                                               Copy List    ${sorted_trscsirs_slotoffset}
    ${sorted_trscsirs_ssb_slotoffset}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                                      ELSE                                               Copy List    ${sorted_trscsirs_ssb_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}
    Run Keyword If     '${final_NbrCellNoFound}' != '0'       Update csirsGroups and cellcsirs
    # ${sorted_csirsGroups} is used by 'Check cellcsirs Assignement' Kw but also used by 'verify_TTITraces_for_csirs' Kw
    ${cellcsirs_slotoffset_present}   evaluate   len(${sorted_cellcsirs_slotoffset}) != ${0}
    run Keyword If    ${cellcsirs_slotoffset_present}
    ...            Run keyword and continue on failure     Check cellcsirs Assignement  ${sorted_cellcsirs_slotoffset}   ${FrameStructure}
    ...     ELSE   declare Results in Test Results List    Type=SYSLOG : Check Cell Specific CSI-RS allocation
    ...                                                    Result=WARN no cellcsirs_slotoffset_present
    # 08/20/2025 : Trs check is bypassed, only CsiRs position is checked
    # this is due to Introduction of new logging macro for too long strings in syslog
    # (see https://gerrit.ext.net.nokia.com/gerrit/c/MN/5G/NB/gnb/+/8938794/ ) => cellGroupSetupReq print have been changed in syslog!!!
    # Run Keyword If    '${TypeCheck}' == 'allCellsSameSSB'
    # ...   Run keyword and continue on failure     Check TrsCsiRs Assignement     ${sorted_trscsirs_slotoffset}    ${FrameStructure}
    # ...    ELSE
    # ...   Run keyword and continue on failure     Check TrsCsiRs Assignement For 4 Cells  ${sorted_trscsirs_ssb_slotoffset}   ${sorted_csirsGroups}
    # ...                                                                                   ${FrameStructure}
    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Check cellmappingtocsirspoolinggroup Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    ${num_of_cells}=    Get Cell Number
    @{cell_to_bypass}=  Create List    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-4
    Critical Step       Wait gNB cells 5g On air    ${num_of_cells}    cell_to_bypass=${cell_to_bypass}

    ${ret}   ${dll1spcells}    robot_extension.Run Keyword And Warn On Failure         Get dlsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    ${ret}   ${ull1spcells}    robot_extension.Run Keyword And Warn On Failure         Get ulsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    Set Suite Variable      ${dll1spcells}
    Set Suite Variable      ${ull1spcells}
    dated log   dlsubcellSpool0List=${dll1spcells[0]}
    dated log   dlsubcellSpool1List=${dll1spcells[1]}
    dated log   ulsubcellSpool0List=${ull1spcells[0]}
    dated log   ulsubcellSpool1List=${ull1spcells[1]}
    # set test variable    ${dll1spcells[0]}
    # set test variable    ${dll1spcells[1]}
    # set test variable    ${ull1spcells[0]}
    # set test variable    ${ull1spcells[1]}
    robot_extension.Run Keyword And Warn On Failure     update bbpoolInfo Dll1Subpool and Ull1Subpool Assignment

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${False}   Step     CallSetup.WTS Set X2 Link

    Run Keyword If      '${kw Specific Set TestMode Before Attach}'!='${EMPTY}'
    ...                                                    Step   Run specific keywords before attach : ${kw Specific Set TestMode Before Attach}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start    actionTti=${isCaptureTti}

    # Register and launch PDU for all the ue's except for which define on the deleted cell
    ${rntiList}=    create list
    Set Test Variable     ${rntiList}
    FOR    ${current_elem}    IN    @{listOfUes}
        # Run Keyword If      ${current_elem.target_cells} != ${nrCell}    Run Keywords
        BuiltIn.sleep     1
        ${status}   run keyword and return status  CallSetup UE register UeId "${current_elem.ue}" on Target cell "${current_elem.target_cells}"
        run keyword if    not ${status}    BuiltIn.log    Try to register SA UE${current_elem.ue} FAILED!    level=ERROR
        BuiltIn.sleep     1
        IF  ${status}
            ${status_pdu}     run keyword and return status     CallSetup.Launch PDU Session      ue=${current_elem.ue}
            ...                                                                                   pdu=${current_elem.pdu}
            ...                                                                                   gw=${current_elem.ue}
            IF      not ${status_pdu}
                        BuiltIn.log    UE PDU Session Setup on UE${current_elem.ue} FAILED!    level=ERROR
            ELSE
                        BuiltIn.log to console  UE${current_elem.ue} is registered to 5G in SA Mode!
            END
        END
    END
    Set Test Variable     ${rntiList}

    Run Keyword If    '${kw Specific Set TestMode After Attach}'!='${EMPTY}'
    ...                                                   Step   Run specific keywords after attach : ${kw Specific Set TestMode After Attach}

    ${rntiList}=    create list
    FOR    ${current_elem}    IN    @{listOfUes}
        ${UeId}      CB009836-Ue-Commands.Get Crnti From Egate Log     ue_id=${current_elem.ue}
        Dated log       ======> Rnti[UeId=${current_elem.ue}] is ${UeId}
        Append To List                ${rntiList}                  ${UeId}
    END
    Set Test Variable     ${rntiList}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step        Captures CB009836 Stop

    # Start the non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput} > ${0}    DL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.DL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.DL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session

        ${dir}=   set Variable If    ${current_elem.UL_throughput} > ${0}    UL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.UL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.UL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session
    END

    # PDU session modify reserved for the ue's configured with GBR traffic
    ${nbOfUe_traffic_GBR}=   CB009836-Keywords.Get Number Of Ue Configured With GBR Traffic    dict_ues=${listOfUes}
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If    ${current_elem.DL_throughput_GBR} > ${0}    Run Keywords
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=2
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
        ...    AND
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=3
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
    END

    # Start the GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput_GBR} > ${0}    DL
        ...                                                                      NONE
        ${kw to run}=   Catenate    ${dir} Traffic GBR SA Not Stopped with "${current_elem.DL_throughput_GBR}"Mbps "${param.duration}"s duration
        ...                         and "${param.deviation}" percent deviation
        Run Keyword If      '${current_elem.DL_throughput_GBR}' != '0'
        ...    Critical Step   ${kw to run}    depends=CallSetup.Launch PDU Session
    END

    ${tti_trace_path}    ${tti_trace_dict}=    Omit when TtiTrace deactivated
    ...             Process TTI Traces    Kw_Convert_TtiTrace_From_csv_to_Dict=${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}   step=For_Test_Verdict

    # add here Specific Check based on TtiTraces
    run Keyword if     '${kw Specific Check}'!='${EMPTY}'     Omit when TtiTrace deactivated
    ...          Step      ${kw Specific Check}     ttitraceFilename=ttitrace_streaming.pcap
    ...                                             ttitracepath=${tti_trace_path}
    ...                                             vendor_custom=${vendor_custom}
    ...                                             depends=CallSetup.Launch PDU Session

    ${FilePkl}=           Omit when TtiTrace deactivated
    ...      Run keyword and continue on failure      Convert TTI Traces to Dataframe and store as pickle for UL Mimo
    ...                                                                                                     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                                                     ttitracepath=${tti_trace_path}

    ${L1L2_Pcap_File}=   Omit when L1L2BipTrace deactivated    Get L1L2 traces          time=${GetL1L2TraceTime}
    ...                                                                                 prefix=L1L2Bip.wDLTput
    ...                                                                                 msg=take BIP L1L2 traces with DL Tput
    # add here Specific Check based on L1l2Bip pcap
    run Keyword if     '${kw Specific Check}'!='${EMPTY}'     Omit when L1L2BipTrace deactivated
    ...          Step      ${kw Specific Check}     captureL1L2=${L1L2_Pcap_File}.pcap
    ...                    depends=CallSetup.Launch PDU Session

    run Keyword if   '${L1L2_Pcap_File}' != 'None'      Run Keywords     Dated log    gzip -f ${L1L2_Pcap_File}.pcap
    ...                                                         AND      Run    gzip -f ${L1L2_Pcap_File}.pcap

    # Generate Verdict...
    Omit when TtiTrace deactivated      Step      Generate Test Verdict    ${FilePkl}   ${vendor_custom}
    ...                                                                    ${dictExpectedValues}
    ...                                                                    ${kw Check SCF parameters}
    ...                                                                    verify_TTITraces_for_csirs_3cells
    ...                                                                    ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                    ttitracepath=${tti_trace_path}
    ...                                                                    skip=${skip}

    ${cntUes}=    Get length    ${rntiList}
    robot_extension.Run Keyword And Warn On Failure       CB009836-Ue-Commands.Verify Nbr Of ${cntUes}Ues ACTIVE

    # if  '${SKIP_COUNTERS}'=='False' => 'Display PDSCH and PUSCH ue_stats_nr for UEList' allow to Wait time until next PM file
    Run Keyword And Ignore Error     Display PDSCH and PUSCH ue_stats_nr for UEList   UEsList=${listOfUes}    file=${csv_file_tput_results}

    # Collect PM only if  '${SKIP_COUNTERS}'=='False'
    Omit when SKIP_COUNTERS present      robot_extension.Run Keyword And Warn On Failure
    ...                                           CB009836-Keywords.Collect PM Counters and process throughput using PM counters

    # to bypass UE Deregister if needed
    @{listOfUes}    run Keyword if    '${w_ue_detach}' == 'False'    Create List
    ${len}=   Get Length   ${listOfUes}
    run Keyword if    '${len}' != '${0}'    Step    Traced Sleep   duration=3s   msg=deregistering     depends=CallSetup.UE Register
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.target_cells} != ${nrCell}
        ...                 Step      CallSetup.UE Deregister       id=${current_elem.ue}
        ###...                                                      ue_deregister_type=switch_off
        ###...                                                      by=ue
        ...                                                         depends=CallSetup.UE Register
    END
    [Teardown]   Teardow Kw

Try Lock and Unlock cells
    [Arguments]       ${cell_missing_list}
    Dated log     Try Lock and Unlock cells for cell_missing_list=${cell_missing_list}
    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog2_before_Lock_Unlock_Cells
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    run Keyword If    '${ret}' == 'FAIL'     BuiltIn.log    btslog.Stop Btslog is ${ret}! with ${syslogpath}  level=ERROR     console=True
    robot_extension.Run Keyword And Warn On Failure     Display SLOTTYPE configuration from Syslogs
    robot_extension.Run Keyword And Warn On Failure     Extract L2-PS/src/sgnl/psCell/CellSetupLogger from Syslogs
    ${fileExists}=     nps_9836_tools.file_exists   ${syslogpath}
    ${ret}    ${syslog_filename}   Run Keyword If   ${fileExists}==${True}
    ...                                           Run Keyword And Ignore Error    nps_9836_tools.return_basename   ${syslogpath}
    ...                              ELSE         ObtainVariablesKeyword
    robot_extension.Run Keyword And Warn On Failure   declare Trace in Trace List    Type=SysLog  Savedir=${dir_syslog}
    ...                          file_name=${syslog_filename}   Trigger=btslog2_beforeLockUnlockCells
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog
    Dev_lib.start_to_capture_infomodel_log
    FOR     ${cell}     IN     @{cell_missing_list}
        ${cellId}=     Set Variable If    '${cell}'=='16385'     1
        ...                               '${cell}'=='16386'     2
        ...                               '${cell}'=='16387'     3
        ...                               '${cell}'=='16388'     4
        ...                               '${cell}'=='16389'     5
        ...                               '${cell}'=='16390'     6
        Lock Cell${cellId}
        Unlock Cell${cellId}
    END
    [Teardown]     Run Keyword And Ignore Error      Dev_lib.stop_to_capture_infomodel_log

Update csirsGroups and cellcsirs
    [arguments]    ${NbrCells}=4
    dated log     [Update csirsGroups and cellcsirs] csirsGroups=${sorted_csirsGroups}
    ${sorted_csirsGroups}  ${sorted_cellcsirs_slotoffset}  ${uecsirs_slotoffset}  ${sorted_trscsirs_slotoffset}  ${sorted_trscsirs_ssb_slotoffset}
    ...                     Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog     NbrCells=${NbrCells}
    ...                                                     csirsGroups=${sorted_csirsGroups}    cellcsirs=${sorted_cellcsirs_slotoffset}
    ...                                                     trscsirs=${sorted_trscsirs_slotoffset}
    # ...                                                     sysLogsDir=/home/ute/csamson/TRACES_3
    Dated Log New Line    Update csirsGroups and cellcsirs => sorted_csirsGroups=${sorted_csirsGroups}
    Dated Log New Line    Update csirsGroups and cellcsirs => sorted_cellcsirs_slotoffset=${sorted_cellcsirs_slotoffset}
    Dated Log New Line    Update csirsGroups and cellcsirs => sorted_trscsirs_slotoffset=${sorted_trscsirs_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}

check Dl Cell mapping from Syslog ${FileDLCellMapping}
    [documentation]    ${FileDLCellMapping} is created from syslog traces - see extract_l1sp_from_syslog in CB009836-lib.py
    ${isFileNameDLCellMappingPresent}    Run Keyword And Return Status    Should Not Be Empty   ${FileDLCellMapping}
    ${fileExists}=     nps_9836_tools.file_exists   ${FileDLCellMapping}
    Run Keyword If     not ${isFileNameDLCellMappingPresent} or not ${fileExists}
    ...      BuiltIn.Log    DL Cell mapping file not present (from Syslog), please check the config...    level=WARN    console=yes
    return from Keyword if     not ${isFileNameDLCellMappingPresent} or not ${fileExists}
    ${json_string}=    OperatingSystem.Get File    ${FileDLCellMapping}
    ${parsed_json}=    Evaluate    json.loads('''${json_string}''')    json
    dated log    parsed_json=${parsed_json}
    # ${parsed_json}[2] means PoolId
    ${PoolIdList}=    Evaluate    set([a[2] for a in ${parsed_json}])
    ${all_equal}=     Evaluate    len(${PoolIdList}) == ${1}
    ${PoolId}=        Set Variable If    ${all_equal}   ${PoolIdList}    ${None}
    ${num_of_cells}=    Get Cell Number
    robot_extension.Run Keyword And Warn On Failure    Should be True    ${all_equal}
    ...                                                msg=All ${num_of_cells} Cells are NOT mapped on same PoolId [${PoolId}]!!!
    Run Keyword If    ${all_equal}     dated log     All ${num_of_cells} Cells are mapped on same PoolId ${consTraceColor}${PoolId}${defColor}
    Run Keyword If    ${all_equal}     Append To File      ${resultFile}
    ...                            \nAll ${num_of_cells} Cells are mapped on same PoolId ${PoolId} ---> PASSED\n
    ...     ELSE     Append To File      ${resultFile}
    ...                            \nAll ${num_of_cells} Cells are mapped on same PoolId ${PoolId} ---> FAILED\n
    [return]    ${all_equal}    ${PoolId}

Check TrsCsiRs Assignement For 4 Cells
    [Arguments]      ${sorted_trscsirs_ssb_slotoffset}   ${sorted_csirsGroups}   ${framestructure}=5GC001208
    # check Cell50
    Run keyword and continue on failure    Check TrsCsiRs Assignement per SSB   ${sorted_trscsirs_ssb_slotoffset}  ${sorted_csirsGroups}
    ...                                                                         cellId=1   framestructure=${framestructure}
    # check Cell51
    Run keyword and continue on failure    Check TrsCsiRs Assignement per SSB   ${sorted_trscsirs_ssb_slotoffset}  ${sorted_csirsGroups}
    ...                                                                         cellId=2   framestructure=${FrameStructure}
    # check Cell52
    Run keyword and continue on failure    Check TrsCsiRs Assignement per SSB   ${sorted_trscsirs_ssb_slotoffset}  ${sorted_csirsGroups}
    ...                                                                         cellId=3   framestructure=${FrameStructure}
    # check Cell53
    Run keyword and continue on failure    Check TrsCsiRs Assignement per SSB   ${sorted_trscsirs_ssb_slotoffset}  ${sorted_csirsGroups}
    ...                                                                         cellId=4   framestructure=${FrameStructure}

Log config in result env file
    [Arguments]    ${config}=None    ${run}=None
    ${resultEnvFile}    Set Variable     ${testCaseDir}/resultEnvFile_${TEST NAME[0:30]}.log
    Set Test Variable    ${resultEnvFile}
    Append To File   ${resultEnvFile}  ------------------------------------------------------\n
    Append To File   ${resultEnvFile}   TEST NAME: ${TEST NAME}\n
    Append To File   ${resultEnvFile}   TEST CONFIG: ${config}\n
    Append To File   ${resultEnvFile}   TEST RUN: ${run}\n
    Append To File   ${resultEnvFile}  ------------------------------------------------------\n
    Append To File   ${resultEnvFile}   df -kh:\n
    Append To File   ${resultEnvFile}  ------------------------------------------------------\n
    ${cmd}=     OperatingSystem.Run     sudo df -kh
    Append To File   ${resultEnvFile}   ${cmd}\n
    Append To File   ${resultEnvFile}  ------------------------------------------------------\n
    Append To File   ${resultEnvFile}   sudo lsof -w /tmp:\n
    Append To File   ${resultEnvFile}  ------------------------------------------------------\n
    ${cmd}=     OperatingSystem.Run     sudo lsof -w /tmp
    Append To File   ${resultEnvFile}   ${cmd}\n
    Append To File   ${resultEnvFile}  ------------------------------------------------------\n

Log Scout Data Error
    [Arguments]    ${return}
    Run Keyword If    '${return[0]}'=='FAIL'    BuiltIn.log    Produce Scout Data ${return[0]}! - reason=${return[1]}
    ...                                                        level=ERROR    console=True
    ${result}=    set variable if    '${return[0]}'=='PASS'    ${return[1]}     ${EMPTY}
    [return]    ${result}

# replace "Produce Scout Data" kw from SWENG!!!
Set SCOUT TC ID for Reporting
    [Documentation]                 Prepare Scout environment then call Scout service to produce data for Reporting Portal.
    [Arguments]                     ${wait_for_success}=True
    ...                             ${timeout}=60
    ...                             ${alias}=conn_alias
    ${return}=   robot_extension.Run Keyword And Warn On Failure    OsTool.get_testline_name
    ${tl_name}   Log Scout Data Error   ${return}
    ${return}    robot_extension.Run Keyword And Warn On Failure
    ...      scout.setup_scout   scout_testline_name=${tl_name}      alias=conn_alias
    Log Scout Data Error   ${return}
    ${use_scout_internal_id}=       Set Variable                    ${False}
    ${return}    robot_extension.Run Keyword And Warn On Failure
    ...                             setup.Call Scout Services       wait_for_success=${wait_for_success}
    ...                                                             timeout=${timeout}
    ...                                                             use_scout_internal_id=${use_scout_internal_id}
    ...                                                             alias=${alias}
    run keyword if    '${return[0]}'=='PASS'    BuiltIn.log to console  request_scf with use_scout_internal_id=${use_scout_internal_id} succeeded.
    Log Scout Data Error   ${return}
    ${return}    robot_extension.Run Keyword And Warn On Failure    scout.teardown_scout_api        alias=${alias}
    Log Scout Data Error   ${return}


TC CB009836 4 Cells
    [Documentation]
    ...     test template for CB009836 (Topology to used should be CLOUD_5G_O_E_AP_LOO_8DL8UL)
    ...     Conditions:     it is based on the arguments ${param}  ${dictParam}  ${vendor_custom} ${dict_ues} ${nrCell}
    ...     Actions:        it performs the call setup for multi-ues on different cells with DL traffic
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Arguments]             ${param}
    ...                     ${dictParam}
    ...                     ${vendor_custom}
    ...                     ${dict_ues}
    ...                     ${nrCell}
    ...                     ${Kw TestLine Preparation}=${EMPTY}
    ...                     ${kw Set RAD Params}=${EMPTY}
    ...                     ${kw NIDD Set}=${EMPTY}
    ...                     ${kw NIDD Check}=${EMPTY}
    ...                     ${kw Set TestMode}=${EMPTY}
    ...                     ${kw Active Config}=${EMPTY}
    ...                     ${kw Specific Set TestMode Before Attach}=${EMPTY}
    ...                     ${kw Specific Set TestMode After Attach}=${EMPTY}
    ...                     ${NIDD_9836_PARAMS}=${NIDD_9836_Q_L_PARAMS}
    ...                     ${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}=Convert TTI trace from csv to dict CB009836
    ...                     ${kw Check SCF parameters}=${EMPTY}
    ...                     ${kw Specific Check Tti}=${EMPTY}
    ...                     ${kw Specific Check}=${EMPTY}
    ...                     ${kw Specific Check CPRT}=${EMPTY}
    ...                     ${Kw Update NIDD Test Parameters}=${EMPTY}
    ...                     ${NIDD_9836_TEST_PARAMS}=${EMPTY}
    ...                     ${Json test configuration}=${EMPTY}
    ...                     ${FrameStructure}=5GC001208
    ...                     ${TypeCheck}=allCellsSameSSB
    ...                     ${skip}=${False}

    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    ${topoOK}=      Evaluate     ${topoOK_1} or ${topoOK_2}
    ${msg_err}=     Catenate    topology USED [${topoUsed}] is not CORRECT for this test [${TEST NAME}].
    Run Keyword If            '${topoOK}'=='False'   dated log   ${consTraceColorBgRed}${consTraceColorYellow}${msg_err}${defColor} Plz, Check it...
    Return From Keyword If    '${topoOK}'=='False'
    Init Sequence           ${param}
    Create Header Csv Tput Test result
    ${ull1spcells_syslog}=    Create List
    ${dll1spcells_syslog}=    Create List
    set test variable     ${ull1spcells_syslog}
    set test variable     ${dll1spcells_syslog}
    Run Keyword If    '${Json test configuration}'!='${EMPTY}'    load Json test data   ${Json test configuration}   ${dict_ues}
    ...                                                                                 ${vendor_custom}   ${param}
    StringTool.printLineWithTitle     title=Display NIDD PARAMETERS of the Test TO SET
    FOR    ${item}    IN    @{NIDD_9836_PARAMS}
         continue for loop if     'list_name' in ${item}
         ${msg_display}=    StringTool.getHeaderLine    ${item}[dist_name]/${item}[pname]     ${item}[value]
         dated log      ${msg_display}
         # dated log    dist_name=${item}[dist_name] pname=${item}[pname] value=${item}[value]
    END
    StringTool.printLineWithTitle     title=-
    Step         Init CB009836 Test Variables    vendor_custom=${vendor_custom}    dict_ues=${dict_ues}    totalNbOfUe=${param.totalNbOfUe}
    Run Keyword If    '${kw Set RAD Params}'!='${EMPTY}'     Step         Run Keyword     ${kw Set RAD Params}
    # return from Keyword

    # ${iphy_file_4Cells} is dedicated to topo ASOE with 4 Cells
    # ${iphy_file_8Cells} is dedicated to topo ASOE with 8 Cells
    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    dated log     Topology is ${topoUsed}
    dated log     TOPOLOGY_LABEL is ${TOPOLOGY_LABEL}
    dated log     TOPOLOGY_VARIANT is ${TOPOLOGY_VARIANT}
    IF      '${TOPOLOGY_LABEL}'=='CLOUD_5G_O_E_AP_LOO' and '${TOPOLOGY_VARIANT}'=='SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD'
                    ${iphy_file_to_use}=    Set Variable   ${iphy_file_8Cells_VARIANT_SANSA_FS_CPRI_CMWV_FDD_ECPRI_CMWV_TDD}
    ELSE IF    ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'
                    ${iphy_file_to_use}=    Set Variable    ${iphy_file_8Cells}
    ELSE
                    ${iphy_file_to_use}=   Set Variable    ${iphy_file_4Cells}
    END
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_to_use}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_to_use}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [/tmp/${iphy_filename}] to AirPhone

    # Apply delta commissioning (WITH_APPLY_DELTA_COMMISSIONING=1) if requested
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1' and '${UPDATE_SCF}'=='1' and '${Kw TestLine Preparation}'!='${EMPTY}'
    ...                          Run Keywords       ${Kw TestLine Preparation}      output_scf=${test_scf_file}
    ...                              AND            Set Suite Variable              ${test_scf_file}
    # return from Keyword

    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...                                                Set CB009836 NIDD PARAMETERS VERSION 3 with SET into SCF     list=${NIDD_9836_PARAMS}
    # return from Keyword

    # Set NIDD PARAM If Needed / Kw use ${test_scf_file} file
    Run Keyword If    '${kw NIDD Set}'!='${EMPTY}' and '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'     ${kw NIDD Set}   list=${NIDD_9836_PARAMS}

    # Check if NIDD PARAM are as expected
    Run Keyword If    '${kw NIDD Check}'!='${EMPTY}'      ${kw NIDD Check}  list=${NIDD_9836_PARAMS}

    ${w_getSCF}=    Set Variable If     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'   true
    ...                                                                              false
    Run Keyword If    '${kw Active Config}'!='${EMPTY}'      ${kw Active Config}    w_getSCF=${w_getSCF}
    ...    ELSE                                              CB009836-A-Config-tests-Keywords.Log config in result file

    # update local scf.xml
    ${test_scf_file}      Run Keyword If    '${kw Active Config}'!='${EMPTY}'  COAM Get SCF    file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ...                      ELSE                                              set Variable    ${test_scf_file}
    set suite variable     ${test_scf_file}

    # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure       Admin Validate SCF     scf_path_file=${test_scf_file}
    robot_extension.Run Keyword And Warn On Failure       Get Cipher and Integrity Parameters From SCF

    # iPHY gscn update depending of chBwDl
    # get gscn for CELL1 from SCF
    ${gscn_cell1}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell1} for CELL1
    Step           CB009836-Keywords.Set Context_AP IPHY gscn Cell1 with ${gscn_cell1}

    ${gscn_cell2}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell2} for CELL2
    Step           CB009836-Keywords.Set Context_AP IPHY gscn Cell2 with ${gscn_cell2}

    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    ${cond1}=          Evaluate     '${bts_status.lower()}'=='configured' or '${bts_status.lower()}'=='onair'
    ${condResetTL}=    Evaluate     '${ret.lower()}'=='pass' and not ${cond1}
    dated log     condResetTL=${condResetTL}
    Run Keyword If     ${condResetTL}    Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured/OnAir [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}

    ${test_scf_file}             COAM Get SCF        local_dir_path=${LOG_PATH}      file=SCF.xml   alias=coam_gnb
    Set Suite Variable           ${test_scf_file}
    ${scf_modif_to_commit_present}=    run keyword and return status  Variable Should Exist  ${scf_modif_to_commit}
    run keyword if    ${scf_modif_to_commit_present}    Set Test Variable  ${test_scf_file}     ${scf_modif_to_commit}
    Set Suite Variable           ${test_scf_file}

    ${actTddCsirsAllocOptimization}   set variable     ${act9836TddCsirsAllocOptimization}
    @{PARAMS_IN_VENDOR}    Create List     actTddCsirsAllocOptimization=${actTddCsirsAllocOptimization}
    set test variable     ${PARAMS_IN_VENDOR}
    ${cond1}=          Evaluate     '${bts_status.lower()}'!='configured' or '${bts_status.lower()}'!='onair'
    ${condResetTL}=    Evaluate     '${ret.lower()}'=='pass' and ${cond1}
    dated log     condResetTL=${condResetTL}
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...         Critical Step    CB009836-TL-Preparation-Keywords.Deploy Vendor File to activate CB009836     PARAMS_IN_VENDOR=${PARAMS_IN_VENDOR}
    ...                                                                                                       is_perform_full_commissioning=${True}
    ...   ELSE
    ...          Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'
   ...             Run Keywords    Dated Log new line       ${consTraceColorRed}BEWARE that Deploy Vendor File Config is already DONE!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=4min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter
    # return from Keyword

    Run keyword and continue on failure     Verify actTddCsirsAllocOptimization status    status=${actTddCsirsAllocOptimization}

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER Commissioning / TL Restart${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs
    robot_extension.Run Keyword And Warn On Failure         Extract l2::ps::cnfg::AddressDistributionReq_t from Syslog
    robot_extension.Run Keyword And Warn On Failure         Display PRB POOLING NIDD param
    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    # save some test parameters as vendor file or Ue settings into ${testCaseDir}
    nps_9836_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${vendor_custom}    filename=data_test.json

    # Configure the current setting for all the ue's
    ${param.totalNbOfUe}    get length          ${dict_ues}
    Step                    Configure the setting for the ${param.totalNbOfUe} UEs
    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${param.totalNbOfUe}
        ${current_ue}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        Set To Dictionary             ${current_ueSetting}          trf_id              1
        Set To Dictionary             ${current_ueSetting}          target_gnb          ${param.targetGnb}
        Set To Dictionary             ${current_ueSetting}          size                ${dict_ues[${current_id}].packet_size}

        # Dispatching each ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ueSetting}          DL_throughput          ${dict_ues[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          UL_throughput          ${dict_ues[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}          protocol               ${dict_ues[${current_id}].protocol}

        Append To List                ${listOfUes}                  ${current_ueSetting}

        # save some test parameters as vendor file or Ue settings into ${testCaseDir}
        add_dictionary_to_json       ${testCaseDir}     'Ue_${current_ue}'   ${current_ueSetting}    data_test.json
    END
    # Dated Log New Line                UE_List=${listOfUes}
    display_list_parameters_w_name      ${listOfUes}   name=Ue   msg=Display Of listOfUes
    CB009836-Keywords.Check Multi Ues Setting In List        multiUesList=${listOfUes}

    set test Variable     ${listOfUes}
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Init   prefix=CellSetup.Attach.SA
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start  actionCORE=${isCaptureCORE}
    ...                                                                                        actionCPRT=${isCaptureCPRT}
    ...                                                                                        actionL1L2=${isCaptureL1L2}
    ...                                                                                        actionTti=${False}

    # ${kw Set TestMode} is a robot Kw that allow to modify cfg file
    Run Keyword If    '${kw Set TestMode}'!='${EMPTY}'       ${kw Set TestMode}

    Setup devices aliases
    robot_extension.Run Keyword And Warn On Failure    Enable internal mirroring for alias    gNB2

    Run Keyword If    '${Kw Update NIDD Test Parameters}'!='${EMPTY}'      Step      Run Keyword    ${Kw Update NIDD Test Parameters}

    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    ${LuaFileToUsed}=      Run Keyword If    '${W_CUSTOM_LUA_FILE_TO_USED}'=='1'       Install lua File into WTS    ${LuaFileToUsed_path}
    ...                        ELSE                                                    Set Variable                 ${EMPTY}

    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog2_beforeCellSetup
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    run Keyword If    '${ret}' == 'FAIL'     BuiltIn.log    btslog.Stop Btslog is ${ret}! with ${syslogpath}     level=ERROR     console=True
    ${fileExists}=     nps_9836_tools.file_exists   ${syslogpath}
    ${ret}    ${syslog_filename}   Run Keyword If   ${fileExists}==${True}
    ...                                           Run Keyword And Ignore Error    nps_9836_tools.return_basename   ${syslogpath}
    ...                              ELSE         ObtainVariablesKeyword
    robot_extension.Run Keyword And Warn On Failure   declare Trace in Trace List    Type=SysLog  Savedir=${dir_syslog}
    ...                          file_name=${syslog_filename}   Trigger=btslog2_beforeCellSetup
    robot_extension.Run Keyword And Warn On Failure   Check UL and DL l1Subpool Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}
    ...         Critical Step           Basic Call to Setup Wtsemu SA           nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${True}
    ...                                                             LuaFileToUsed=${LuaFileToUsed}
    # ...                                                             Kw_TM=${kw Set TestMode}
    ...   ELSE
    ...         Critical Step           CallSetup.Setup Wtsemu SA               nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${False}
    Dev_lib.wait_ng_link_up
    Dev_lib.start_to_capture_infomodel_log
    Run Keyword If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   CB009836-Keywords.Cell 1 cell 2 cell3 and cell4 Should Be Onair
    ...    ELSE                                                             All Cells Should Be Onair
    Dev_lib.stop_to_capture_infomodel_log

    # take into account SCOUT
    ${host_vm_ip}=  configuration_id.Get Host IP Address  host_index=1
    Run Keyword And Ignore Error    configuration_id.Start Testline Scout Monitor  host_vm_ip=${host_vm_ip}
    # ${return}    ${output}    robot_extension.Run Keyword And Warn On Failure    Setup.Produce Scout Data    timeout=120
    ${return}    ${output}    robot_extension.Run Keyword And Warn On Failure
    ...           CB009836-Test-Template-Keywords.Set SCOUT TC ID for Reporting    timeout=120
    run keyword if    '${return}'=='FAIL'    BuiltIn.log    Set SCOUT TC ID for Reporting ${return}! - reason=${output}
    ...                                                     level=ERROR    console=True

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    # test all cells mapped on same L1 Pool
    ${isFileNameDLCellMappingPresent}    Run Keyword And Return Status    Should Not Be Empty   ${FileNameDLCellMapping}
    ${fileExists}=     nps_9836_tools.file_exists   ${FileNameDLCellMapping}
    ${FileNameDLCellMapping}=    Set Variable If    ${fileExists}    ${FileNameDLCellMapping}    ${None}
    Run Keyword If   '${isFileNameDLCellMappingPresent}' == 'False' or not ${fileExists}
    ...                BuiltIn.Log    DL Cell mapping file not present (from Syslog), please check the config    level=WARN    console=yes
    ...    ELSE        check Dl Cell mapping from Syslog ${FileNameDLCellMapping}

    ${ret}  ${output}=    robot_extension.Run Keyword And Warn On Failure
    ...                                        Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog     NbrCells=4
    ${sorted_csirsGroups}            Set Variable     ${output[0]}
    ${sorted_cellcsirs_slotoffset}   Set Variable     ${output[1]}
    ${sorted_uecsirs_slotoffset}     Set Variable     ${output[2]}
    ${sorted_trscsirs_slotoffset}    Set Variable     ${output[3]}
    ${sorted_trscsirs_ssb_slotoffset}    Set Variable     ${output[4]}
    Dated Log New Line    sorted_csirsGroups=${sorted_csirsGroups}
    Dated Log New Line    sorted_cellcsirs_slotoffset=${sorted_cellcsirs_slotoffset}
    Dated Log New Line    sorted_trscsirs_slotoffset=${sorted_trscsirs_slotoffset}
    Dated Log New Line    sorted_trscsirs_ssb_slotoffset=${sorted_trscsirs_ssb_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}

    # check that we have all relation cell and csrirspool for all cells
    ${cell_csirsGroups}=  Get length   ${sorted_csirsGroups}
    Dated log    length of cell_csirsGroups = ${sorted_csirsGroups}
    ${List_nrCellIdentity}   Create List     16385    16386    16387    16388
    ${cell_missing_list}=    check_all_cell_csirspool_present      ${output[0]}    ${List_nrCellIdentity}
    ${cell_missing_in_cellcsirs_list}=    check_all_cell_in_cellcsirs_present      ${output[1]}    ${List_nrCellIdentity}
    ${NbrCellNoFound}=       Get length   ${cell_missing_list}
    ${NbrCellNoFound_in_cellcsirslist}=       Get length   ${cell_missing_in_cellcsirs_list}
    ${text}=    Catenate    Nb of cell csirsGroups relation not found = ${NbrCellNoFound} with cell_missing_list=${cell_missing_list}
    ${levellog}=    Set Variable If    '${NbrCellNoFound}' != '${NbrCellNoFound_in_cellcsirslist}'    ERROR    WARN
    Run Keyword If   '${NbrCellNoFound}' != '0'    BuiltIn.Log
    ...    msg=${text}  level=${levellog}
    ${text}=    Catenate     Nb of cellcsirs relation not found=${NbrCellNoFound_in_cellcsirslist}
    ...                      with cell_missing_in_cellcsirs_list=${cell_missing_in_cellcsirs_list}
    Run Keyword If   '${NbrCellNoFound_in_cellcsirslist}' != '0'    BuiltIn.Log
    ...    msg=${text}
    ...    level=${levellog}
    Dated log  Nb of cell csirsGroups relation not found = ${NbrCellNoFound} with cell_missing_list=${cell_missing_list}
    Dated log  Nb of cell cellcsirs relation not found = ${NbrCellNoFound_in_cellcsirslist} with cell_missing_list=${cell_missing_in_cellcsirs_list}
    ${combined_cell_missing_list}    Combine Lists    ${cell_missing_list}    ${cell_missing_in_cellcsirs_list}
    ${combined_cell_missing_list}    Remove Duplicates    ${combined_cell_missing_list}
    ${final_NbrCellNoFound}=         Get length   ${combined_cell_missing_list}
    ${text}=    Catenate    Final decision : Nb of cell csirsGroups/cellcsirs relation not found = ${final_NbrCellNoFound}
    ...                     with cell_missing_list=${combined_cell_missing_list},
    ...                     => Try Lock and Unlock cells ${combined_cell_missing_list}
    Run Keyword If     '${final_NbrCellNoFound}' != '0'       Try Lock and Unlock cells    ${combined_cell_missing_list}
    ${sorted_csirsGroups}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                          ELSE                                               Copy List    ${sorted_csirsGroups}
    ${sorted_cellcsirs_slotoffset}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                                  ELSE                                                Copy List    ${sorted_cellcsirs_slotoffset}
    ${sorted_trscsirs_slotoffset}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                                  ELSE                                               Copy List    ${sorted_trscsirs_slotoffset}
    ${sorted_trscsirs_ssb_slotoffset}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                                      ELSE                                               Copy List    ${sorted_trscsirs_ssb_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}
    Run Keyword If     '${final_NbrCellNoFound}' != '0'       Update csirsGroups and cellcsirs
    # ${sorted_csirsGroups} is used by 'Check cellcsirs Assignement' Kw but also used by 'verify_TTITraces_for_csirs' Kw
    ${cellcsirs_slotoffset_present}   evaluate   len(${sorted_cellcsirs_slotoffset}) != ${0}
    run Keyword If    ${cellcsirs_slotoffset_present}
    ...            Run keyword and continue on failure     Check cellcsirs Assignement  ${sorted_cellcsirs_slotoffset}   ${FrameStructure}
    ...     ELSE   declare Results in Test Results List    Type=SYSLOG : Check Cell Specific CSI-RS allocation
    ...                                                    Result=WARN no cellcsirs_slotoffset_present
    # 08/20/2025 : Trs check is bypassed, only CsiRs position is checked
    # this is due to Introduction of new logging macro for too long strings in syslog
    # (see https://gerrit.ext.net.nokia.com/gerrit/c/MN/5G/NB/gnb/+/8938794/ ) => cellGroupSetupReq print have been changed in syslog!!!
    # Run Keyword If    '${TypeCheck}' == 'allCellsSameSSB'
    # ...   Run keyword and continue on failure     Check TrsCsiRs Assignement     ${sorted_trscsirs_slotoffset}    ${FrameStructure}
    # ...    ELSE
    # ...   Run keyword and continue on failure     Check TrsCsiRs Assignement For 4 Cells  ${sorted_trscsirs_ssb_slotoffset}   ${sorted_csirsGroups}
    # ...                                                                                   ${FrameStructure}
    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Check cellmappingtocsirspoolinggroup Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    ${num_of_cells}=    Get Cell Number
    @{cell_to_bypass}=  Create List    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-4
    Critical Step       Wait gNB cells 5g On air    ${num_of_cells}    cell_to_bypass=${cell_to_bypass}

    ${ret}   ${dll1spcells}    robot_extension.Run Keyword And Warn On Failure         Get dlsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    ${ret}   ${ull1spcells}    robot_extension.Run Keyword And Warn On Failure         Get ulsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    Set Suite Variable      ${dll1spcells}
    Set Suite Variable      ${ull1spcells}
    dated log   dlsubcellSpool0List=${dll1spcells[0]}
    dated log   dlsubcellSpool1List=${dll1spcells[1]}
    dated log   ulsubcellSpool0List=${ull1spcells[0]}
    dated log   ulsubcellSpool1List=${ull1spcells[1]}
    # set test variable    ${dll1spcells[0]}
    # set test variable    ${dll1spcells[1]}
    # set test variable    ${ull1spcells[0]}
    # set test variable    ${ull1spcells[1]}
    robot_extension.Run Keyword And Warn On Failure     update bbpoolInfo Dll1Subpool and Ull1Subpool Assignment

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${False}   Step        CallSetup.WTS Set X2 Link

    Run Keyword If      '${kw Specific Set TestMode Before Attach}'!='${EMPTY}'
    ...                                                    Step   Run specific keywords before attach : ${kw Specific Set TestMode Before Attach}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start    actionTti=${isCaptureTti}

    # Register and launch PDU for all the ue's except for which define on the deleted cell
    ${rntiList}=    create list
    Set Test Variable     ${rntiList}
    FOR    ${current_elem}    IN    @{listOfUes}
        # Run Keyword If      ${current_elem.target_cells} != ${nrCell}    Run Keywords
        BuiltIn.sleep     1
        ${status}   run keyword and return status  CallSetup UE register UeId "${current_elem.ue}" on Target cell "${current_elem.target_cells}"
        run keyword if    not ${status}    BuiltIn.log    Try to register SA UE${current_elem.ue} FAILED!    level=ERROR
        BuiltIn.sleep     1
        IF  ${status}
            ${status_pdu}     run keyword and return status     CallSetup.Launch PDU Session      ue=${current_elem.ue}
            ...                                                                                   pdu=${current_elem.pdu}
            ...                                                                                   gw=${current_elem.ue}
            IF      not ${status_pdu}
                        BuiltIn.log    UE PDU Session Setup on UE${current_elem.ue} FAILED!    level=ERROR
            ELSE
                        BuiltIn.log to console  UE${current_elem.ue} is registered to 5G in SA Mode!
            END
        END
    END
    Set Test Variable     ${rntiList}

    Run Keyword If    '${kw Specific Set TestMode After Attach}'!='${EMPTY}'
    ...                                                   Step   Run specific keywords after attach : ${kw Specific Set TestMode After Attach}

    ${rntiList}=    create list
    FOR    ${current_elem}    IN    @{listOfUes}
         ${UeId}      CB009836-Ue-Commands.Get Crnti From Egate Log     ue_id=${current_elem.ue}
         Dated log       ======> Rnti[UeId=${current_elem.ue}] is ${UeId}
         Append To List                ${rntiList}                  ${UeId}
    END
    Set Test Variable     ${rntiList}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step        Captures CB009836 Stop

    # Start the non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput} > ${0}    DL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.DL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.DL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session

        ${dir}=   set Variable If    ${current_elem.UL_throughput} > ${0}    UL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.UL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.UL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session
    END

    # PDU session modify reserved for the ue's configured with GBR traffic
    ${nbOfUe_traffic_GBR}=   CB009836-Keywords.Get Number Of Ue Configured With GBR Traffic    dict_ues=${listOfUes}
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If    ${current_elem.DL_throughput_GBR} > ${0}    Run Keywords
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=2
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
        ...    AND
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=3
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
    END

    # Start the GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput_GBR} > ${0}    DL
        ...                                                                      NONE
        ${kw to run}=   Catenate    ${dir} Traffic GBR SA Not Stopped with "${current_elem.DL_throughput_GBR}"Mbps "${param.duration}"s duration
        ...                         and "${param.deviation}" percent deviation
        Run Keyword If      '${current_elem.DL_throughput_GBR}' != '0'
        ...    Critical Step   ${kw to run}    depends=CallSetup.Launch PDU Session
    END

    ${tti_trace_path}    ${tti_trace_dict}=    Omit when TtiTrace deactivated
    ...             Process TTI Traces    Kw_Convert_TtiTrace_From_csv_to_Dict=${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}   step=For_Test_Verdict

    # add here Specific Check based on TtiTraces
    run Keyword if     '${kw Specific Check Tti}'!='${EMPTY}'     Omit when TtiTrace deactivated
    ...          Step      ${kw Specific Check Tti}     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                 ttitracepath=${tti_trace_path}
    ...                                                 vendor_custom=${vendor_custom}
    ...                                                 depends=CallSetup.Launch PDU Session

    ${FilePkl}=           Omit when TtiTrace deactivated
    ...      Run keyword and continue on failure      Convert TTI Traces to Dataframe and store as pickle for UL Mimo
    ...                                                                                                     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                                                     ttitracepath=${tti_trace_path}

    ${ret}   ${L1L2_Pcap_File}=   Omit when L1L2BipTrace deactivated   BuiltIn.Run Keyword And Warn On Failure     Get L1L2 traces
    ...                                                                                                       time=${GetL1L2TraceTime}
    ...                                                                                                       prefix=L1L2Bip.wDLTput
    ...                                                                                                       msg=take BIP L1L2 traces with DL Tput
    # add here Specific Check based on L1l2Bip pcap
    run Keyword if     '${kw Specific Check}'!='${EMPTY}'     Omit when L1L2BipTrace deactivated
    ...          Step      ${kw Specific Check}     captureL1L2=${L1L2_Pcap_File}.pcap
    ...                    depends=CallSetup.Launch PDU Session

    run Keyword if   '${L1L2_Pcap_File}' != 'None'      Run Keywords     Dated log    gzip -f ${L1L2_Pcap_File}.pcap
    ...                                                         AND      Run    gzip -f ${L1L2_Pcap_File}.pcap

    # Generate Verdict...
    Omit when TtiTrace deactivated      Step      Generate Test Verdict    ${FilePkl}   ${vendor_custom}
    ...                                                                    ${dictExpectedValues}
    ...                                                                    ${kw Check SCF parameters}
    ...                                                                    verify_TTITraces_for_csirs_4cells
    ...                                                                    ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                    ttitracepath=${tti_trace_path}
    ...                                                                    skip=${skip}

    ${cntUes}=    Get length    ${rntiList}
    robot_extension.Run Keyword And Warn On Failure      CB009836-Ue-Commands.Verify Nbr Of ${cntUes}Ues ACTIVE

    # if  '${SKIP_COUNTERS}'=='False' => 'Display PDSCH and PUSCH ue_stats_nr for UEList' allow to Wait time until next PM file
    Run Keyword And Ignore Error     Display PDSCH and PUSCH ue_stats_nr for UEList   UEsList=${listOfUes}    file=${csv_file_tput_results}

    # Collect PM only if  '${SKIP_COUNTERS}'=='False'
    Omit when SKIP_COUNTERS present      robot_extension.Run Keyword And Warn On Failure
    ...                                           CB009836-Keywords.Collect PM Counters and process throughput using PM counters

    # to bypass UE Deregister if needed
    @{listOfUes}    run Keyword if    '${w_ue_detach}' == 'False'    Create List
    ${len}=   Get Length   ${listOfUes}
    run Keyword if    '${len}' != '${0}'    Step    Traced Sleep   duration=3s   msg=deregistering     depends=CallSetup.UE Register
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.target_cells} != ${nrCell}
        ...                 Step      CallSetup.UE Deregister       id=${current_elem.ue}
        ###...                                                      ue_deregister_type=switch_off
        ###...                                                      by=ue
        ...                                                         depends=CallSetup.UE Register
    END
    [Teardown]   Teardow Kw

TC CB009836 6 Cells
    [Documentation]
    ...     test template for CB009836 (Topology to used should be CLOUD_5G_I_MP_AP_LOOO)
    ...     Conditions:     it is based on the arguments ${param}  ${dictParam}  ${vendor_custom} ${dict_ues} ${nrCell}
    ...     Actions:        it performs the call setup for multi-ues on different cells with DL traffic
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Arguments]             ${param}
    ...                     ${dictParam}
    ...                     ${vendor_custom}
    ...                     ${dict_ues}
    ...                     ${nrCell}
    ...                     ${Kw TestLine Preparation}=${EMPTY}
    ...                     ${kw Set RAD Params}=${EMPTY}
    ...                     ${kw NIDD Set}=${EMPTY}
    ...                     ${kw NIDD Check}=${EMPTY}
    ...                     ${kw Set TestMode}=${EMPTY}
    ...                     ${kw Active Config}=${EMPTY}
    ...                     ${kw Specific Set TestMode Before Attach}=${EMPTY}
    ...                     ${kw Specific Set TestMode After Attach}=${EMPTY}
    ...                     ${NIDD_9836_PARAMS}=${NIDD_9836_Q_L_PARAMS}
    ...                     ${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}=Convert TTI trace from csv to dict CB009836
    ...                     ${kw Check SCF parameters}=${EMPTY}
    ...                     ${kw Specific Check Tti}=${EMPTY}
    ...                     ${kw Specific Check}=${EMPTY}
    ...                     ${kw Specific Check CPRT}=${EMPTY}
    ...                     ${NIDD_9836_TEST_PARAMS}=${EMPTY}
    ...                     ${Json test configuration}=${EMPTY}
    ...                     ${FrameStructure}=5GC001208

    ${topoOK}    ${topoUsed}=    check topology used is CLOUD_5G_I_MP_AP_LOOO
    ${msg_err}=     Catenate    topology USED [${topoUsed}] is not CORRECT for this test [${TEST NAME}].
    Run Keyword If            '${topoOK}'=='False'   dated log   ${consTraceColorBgRed}${consTraceColorYellow}${msg_err}${defColor} Plz, Check it...
    Return From Keyword If    '${topoOK}'=='False'
    Init Sequence           ${param}
    Create Header Csv Tput Test result
    ${ull1spcells_syslog}=    Create List
    ${dll1spcells_syslog}=    Create List
    set test variable     ${ull1spcells_syslog}
    set test variable     ${dll1spcells_syslog}
    Run Keyword If    '${Json test configuration}'!='${EMPTY}'    load Json test data   ${Json test configuration}   ${dict_ues}
    ...                                                                                 ${vendor_custom}   ${param}
    StringTool.printLineWithTitle     title=Display NIDD PARAMETERS of the Test TO SET
    FOR    ${item}    IN    @{NIDD_9836_PARAMS}
         continue for loop if     'list_name' in ${item}
         ${msg_display}=    StringTool.getHeaderLine    ${item}[dist_name]/${item}[pname]     ${item}[value]
         dated log      ${msg_display}
         # dated log    dist_name=${item}[dist_name] pname=${item}[pname] value=${item}[value]
    END
    StringTool.printLineWithTitle     title=-
    Step         Init CB009836 Test Variables    vendor_custom=${vendor_custom}    dict_ues=${dict_ues}    totalNbOfUe=${param.totalNbOfUe}
    Run Keyword If    '${kw Set RAD Params}'!='${EMPTY}'     Step         Run Keyword     ${kw Set RAD Params}
    # return from Keyword

    # ${iphy_file_6Cells} is dedicated to topo MP_AP_LOOO with 6 Cells
    ${fileExists}=         nps_9836_tools.file_exists   ${iphy_file_6Cells}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_6Cells}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if   ${fileiphyExistsInTmp}==${False}    BuiltIn.Log  /tmp/${iphy_filename} not PRESENT!!! need to do TL preparation...  level=WARN
    Run Keyword if   ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                      AND         Dated log      copy custom iphy file [/tmp/${iphy_filename}] to AirPhone

    # Apply delta commissioning (WITH_APPLY_DELTA_COMMISSIONING=1) if requested
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1' and '${UPDATE_SCF}'=='1' and '${Kw TestLine Preparation}'!='${EMPTY}'
    ...                          Run Keywords       ${Kw TestLine Preparation}      output_scf=${test_scf_file}
    ...                              AND            Set Suite Variable              ${test_scf_file}
    # return from Keyword

    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...                                                Set CB009836 NIDD PARAMETERS VERSION 3 with SET into SCF     list=${NIDD_9836_PARAMS}
    # return from Keyword

    # Set NIDD PARAM If Needed / Kw use ${test_scf_file} file
    Run Keyword If    '${kw NIDD Set}'!='${EMPTY}' and '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'     ${kw NIDD Set}   list=${NIDD_9836_PARAMS}

    # Check if NIDD PARAM are as expected
    Run Keyword If    '${kw NIDD Check}'!='${EMPTY}'      ${kw NIDD Check}  list=${NIDD_9836_PARAMS}

    ${w_getSCF}=    Set Variable If     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'   true
    ...                                                                              false
    Run Keyword If    '${kw Active Config}'!='${EMPTY}'      ${kw Active Config}    w_getSCF=${w_getSCF}
    ...    ELSE                                              CB009836-A-Config-tests-Keywords.Log config in result file

    # update local scf.xml
    ${test_scf_file}      Run Keyword If    '${kw Active Config}'!='${EMPTY}'  COAM Get SCF    file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ...                      ELSE                                              set Variable    ${test_scf_file}
    set suite variable     ${test_scf_file}

    # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure       Admin Validate SCF     scf_path_file=${test_scf_file}
    robot_extension.Run Keyword And Warn On Failure       Get Cipher and Integrity Parameters From SCF

    # iPHY gscn update depending of chBwDl
    # get gscn for CELL1 from SCF
    ${gscn_cell1}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell1} for CELL1
    Step           CB009836-Keywords.Set Context_AP IPHY gscn Cell1 with ${gscn_cell1}

    ${gscn_cell2}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell2} for CELL2
    Step           CB009836-Keywords.Set Context_AP IPHY gscn Cell2 with ${gscn_cell2}

    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    ${cond1}=          Evaluate     '${bts_status.lower()}'=='configured' or '${bts_status.lower()}'=='onair'
    ${condResetTL}=    Evaluate     '${ret.lower()}'=='pass' and not ${cond1}
    dated log     condResetTL=${condResetTL}
    Run Keyword If     ${condResetTL}   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}

    ${test_scf_file}             COAM Get SCF        local_dir_path=${LOG_PATH}      file=SCF.xml   alias=coam_gnb
    Set Suite Variable           ${test_scf_file}

    ${actTddCsirsAllocOptimization}   set variable     ${act9836TddCsirsAllocOptimization}
    @{PARAMS_IN_VENDOR}    Create List     actTddCsirsAllocOptimization=${actTddCsirsAllocOptimization}
    @{PARAMS_IN_VENDOR_2}    Create List     actTddCsirsAllocOptimization=${actTddCsirsAllocOptimization}
    ${PARAMS_IN_VENDOR_2}    CB009836-TL-Preparation-Keywords.update params List for VendorFile v2    ${vendor_custom}    ${PARAMS_IN_VENDOR_2}
    dated log     PARAMS_IN_VENDOR_2=${PARAMS_IN_VENDOR_2}
    ${PARAMS_IN_VENDOR}    CB009836-TL-Preparation-Keywords.update params List for VendorFile     ${vendor_custom}    ${PARAMS_IN_VENDOR}
    set test variable     ${PARAMS_IN_VENDOR}
    ${cond1}=          Evaluate     '${bts_status.lower()}'!='configured' or '${bts_status.lower()}'!='onair'
    ${condResetTL}=    Evaluate     '${ret.lower()}'=='pass' and ${cond1}
    dated log     condResetTL=${condResetTL}
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...         Critical Step    CB009836-TL-Preparation-Keywords.Deploy Vendor File to activate CB009836     PARAMS_IN_VENDOR=${PARAMS_IN_VENDOR}
    ...                                                                                                       is_perform_full_commissioning=${True}
    ...   ELSE
    ...          Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'
   ...             Run Keywords    Dated Log new line       ${consTraceColorRed}BEWARE that Deploy Vendor File Config is already DONE!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=4min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter
    # return from Keyword

    Run keyword and continue on failure     Verify actTddCsirsAllocOptimization status    status=${actTddCsirsAllocOptimization}

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER Commissioning / TL Restart${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs
    robot_extension.Run Keyword And Warn On Failure         Extract l2::ps::cnfg::AddressDistributionReq_t from Syslog
    robot_extension.Run Keyword And Warn On Failure         Display PRB POOLING NIDD param
    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    # save some test parameters as vendor file or Ue settings into ${testCaseDir}
    nps_9836_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${vendor_custom}    filename=data_test.json

    # Configure the current setting for all the ue's
    ${param.totalNbOfUe}    get length          ${dict_ues}
    Step                    Configure the setting for the ${param.totalNbOfUe} UEs
    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${param.totalNbOfUe}
        ${current_ue}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        Set To Dictionary             ${current_ueSetting}          trf_id              1
        Set To Dictionary             ${current_ueSetting}          target_gnb          ${param.targetGnb}
        Set To Dictionary             ${current_ueSetting}          size                ${dict_ues[${current_id}].packet_size}

        # Dispatching each ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ueSetting}          DL_throughput          ${dict_ues[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          UL_throughput          ${dict_ues[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}          protocol               ${dict_ues[${current_id}].protocol}

        Append To List                ${listOfUes}                  ${current_ueSetting}

        # save some test parameters as vendor file or Ue settings into ${testCaseDir}
        add_dictionary_to_json       ${testCaseDir}     'Ue_${current_ue}'   ${current_ueSetting}    data_test.json
    END
    # Dated Log New Line                UE_List=${listOfUes}
    display_list_parameters_w_name      ${listOfUes}   name=Ue   msg=Display Of listOfUes
    CB009836-Keywords.Check Multi Ues Setting In List        multiUesList=${listOfUes}

    set test Variable     ${listOfUes}
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Init   prefix=CellSetup.Attach.SA
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start  actionCORE=${isCaptureCORE}
    ...                                                                                        actionCPRT=${isCaptureCPRT}
    ...                                                                                        actionL1L2=${isCaptureL1L2}
    ...                                                                                        actionTti=${False}

    # ${kw Set TestMode} is a robot Kw that allow to modify cfg file
    Run Keyword If    '${kw Set TestMode}'!='${EMPTY}'       ${kw Set TestMode}

    Setup devices aliases
    robot_extension.Run Keyword And Warn On Failure     Enable internal mirroring for alias    gNB2

    ${LuaFileToUsed}=      Run Keyword If    '${W_CUSTOM_LUA_FILE_TO_USED}'=='1'       Install lua File into WTS    ${LuaFileToUsed_path_ABIP}
    ...                        ELSE                                                    Set Variable                 ${EMPTY}

    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog2_beforeCellSetup
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    run Keyword If    '${ret}' == 'FAIL'     BuiltIn.log    btslog.Stop Btslog is ${ret}! with ${syslogpath}     Level=ERROR     console=True
    ${fileExists}=     nps_9836_tools.file_exists   ${syslogpath}
    ${ret}    ${syslog_filename}   Run Keyword If   ${fileExists}==${True}
    ...                                           Run Keyword And Ignore Error    nps_9836_tools.return_basename   ${syslogpath}
    ...                              ELSE         ObtainVariablesKeyword
    robot_extension.Run Keyword And Warn On Failure   declare Trace in Trace List    Type=SysLog  Savedir=${dir_syslog}
    ...                          file_name=${syslog_filename}   Trigger=btslog2_beforeCellSetup
    robot_extension.Run Keyword And Warn On Failure   Check UL and DL l1Subpool Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}
    ...         Critical Step           Basic Call to Setup Wtsemu SA           nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${True}
    ...                                                             LuaFileToUsed=${LuaFileToUsed}
    # ...                                                             Kw_TM=${kw Set TestMode}
    ...   ELSE
    ...         Critical Step           CallSetup.Setup Wtsemu SA               nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${False}

    Dev_lib.wait_ng_link_up
    Dev_lib.start_to_capture_infomodel_log
    CB009836-Keywords.All Cells Should Be Onair
    Dev_lib.stop_to_capture_infomodel_log
    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    # test that all cells mapped on same L1 Pool
    ${isFileNameDLCellMappingPresent}    Run Keyword And Return Status    Should Not Be Empty   ${FileNameDLCellMapping}
    ${fileExists}=     nps_9836_tools.file_exists   ${FileNameDLCellMapping}
    ${FileNameDLCellMapping}=    Set Variable If    ${fileExists}    ${FileNameDLCellMapping}    ${None}
    Run Keyword If   '${isFileNameDLCellMappingPresent}' == 'False' or not ${fileExists}
    ...                BuiltIn.Log    DL Cell mapping file not present (from Syslog), please check the config    level=WARN    console=yes
    ...    ELSE        check Dl Cell mapping from Syslog ${FileNameDLCellMapping}

    ${ret}  ${output}=    robot_extension.Run Keyword And Warn On Failure
    ...                                         Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog    NbrCells=6
    ${sorted_csirsGroups}            Set Variable     ${output[0]}
    ${sorted_cellcsirs_slotoffset}   Set Variable     ${output[1]}
    ${sorted_uecsirs_slotoffset}     Set Variable     ${output[2]}
    ${sorted_trscsirs_slotoffset}    Set Variable     ${output[3]}
    ${sorted_trscsirs_ssb_slotoffset}    Set Variable     ${output[4]}
    Dated Log New Line    sorted_csirsGroups=${sorted_csirsGroups}
    Dated Log New Line    sorted_cellcsirs_slotoffset=${sorted_cellcsirs_slotoffset}
    Dated Log New Line    sorted_trscsirs_slotoffset=${sorted_trscsirs_slotoffset}
    Dated Log New Line    sorted_trscsirs_ssb_slotoffset=${sorted_trscsirs_ssb_slotoffset}
    # ${sorted_csirsGroups} is used by 'Check cellcsirs Assignement' Kw but also used by 'verify_TTITraces_for_csirs' Kw
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}

    # check that we have all relation cell and csrirspool for all cells
    ${cell_csirsGroups}=  Get length   ${sorted_csirsGroups}
    Dated log    length of cell_csirsGroups = ${sorted_csirsGroups}
    ${List_nrCellIdentity}   Create List     16385    16386    16387    16388    16389    16390
    ${cell_missing_list}=    check_all_cell_csirspool_present      ${output[0]}    ${List_nrCellIdentity}
    ${NbrCellNoFound}=       Get length   ${cell_missing_list}
    Dated log    Nb of cell csirsGroups relation not found = ${NbrCellNoFound} with cell_missing_list=${cell_missing_list}
    Run Keyword If     '${NbrCellNoFound}' != '0'       Try Lock and Unlock cells    ${cell_missing_list}
    ${sorted_csirsGroups}=   Run Keyword If    '${NbrCellNoFound}' == '6'     Create List
    ...                          ELSE                                         Copy List    ${sorted_csirsGroups}
    ${sorted_cellcsirs_slotoffset}=   Run Keyword If    '${NbrCellNoFound}' == '6'     Create List
    ...                                  ELSE                                          Copy List    ${sorted_cellcsirs_slotoffset}
    ${sorted_trscsirs_slotoffset}=   Run Keyword If    '${NbrCellNoFound}' == '6'     Create List
    ...                                  ELSE                                         Copy List    ${sorted_trscsirs_slotoffset}
    ${sorted_trscsirs_ssb_slotoffset}=   Run Keyword If    '${NbrCellNoFound}' == '6'     Create List
    ...                                      ELSE                                         Copy List    ${sorted_trscsirs_ssb_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}
    Run Keyword If     '${NbrCellNoFound}' != '0'       Update csirsGroups and cellcsirs    NbrCells=6
    # ${sorted_csirsGroups} is used by 'Check cellcsirs Assignement' Kw but also used by 'verify_TTITraces_for_csirs' Kw
    Run keyword and continue on failure     Check cellcsirs Assignement  ${sorted_cellcsirs_slotoffset}    ${FrameStructure}
    # 08/20/2025 : Trs check is bypassed, only CsiRs position is checked
    # this is due to Introduction of new logging macro for too long strings in syslog
    # (see https://gerrit.ext.net.nokia.com/gerrit/c/MN/5G/NB/gnb/+/8938794/ ) => cellGroupSetupReq print have been changed in syslog!!!
    # Run keyword and continue on failure     Check TrsCsiRs Assignement   ${sorted_trscsirs_slotoffset}    ${FrameStructure}

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Check cellmappingtocsirspoolinggroup Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    ${num_of_cells}=    Get Cell Number
    @{cell_to_bypass}=  Create List    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-4
    Critical Step       Wait gNB cells 5g On air    ${num_of_cells}    cell_to_bypass=${cell_to_bypass}

    ${ret}   ${dll1spcells}    robot_extension.Run Keyword And Warn On Failure         Get dlsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    ${ret}   ${ull1spcells}    robot_extension.Run Keyword And Warn On Failure         Get ulsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb

    Set Suite Variable      ${dll1spcells}
    Set Suite Variable      ${ull1spcells}
    dated log   dlsubcellSpool0List=${dll1spcells[0]}
    dated log   dlsubcellSpool1List=${dll1spcells[1]}
    dated log   ulsubcellSpool0List=${ull1spcells[0]}
    dated log   ulsubcellSpool1List=${ull1spcells[1]}
    set test variable    ${dll1spcells[0]}
    set test variable    ${dll1spcells[1]}
    set test variable    ${ull1spcells[0]}
    set test variable    ${ull1spcells[1]}
    robot_extension.Run Keyword And Warn On Failure     update bbpoolInfo Dll1Subpool and Ull1Subpool Assignment

    ${bbpoolInfo_json}  set variable     ${testCaseDir}/bbpoolInfo_cell_setup.json
    # Read the contents of bbpoolInfo_cell_setup.json into the variable json_data
    ${json_data}        OperatingSystem.Get File    ${bbpoolInfo_json}
    # Deserialize the JSON data into a Python dictionary (bbpoolInfo)
    ${bbpoolInfo}=      Evaluate    json.loads('${json_data}')       json
    ${l1SpCells}=       Set Variable     ${bbpoolInfo['l1SpCells']}
    ${dl_l1SpCells_bbpoolInfo}=    Set Variable     ${l1SpCells['dlL1SpCells']}
    ${ul_l1SpCells_bbpoolInfo}=    Set Variable     ${l1SpCells['ulL1SpCells']}
    ${notEmpty}    Run Keyword And Return Status    Should Not Be Empty   ${dl_l1SpCells_bbpoolInfo[0]}
    ${dll1spcells[0]}=    Run Keyword If     ${notEmpty}    Copy List     ${dl_l1SpCells_bbpoolInfo[0]}
    ...                          ELSE                       Copy List     ${dll1spcells[0]}
    ${notEmpty}    Run Keyword And Return Status    Should Not Be Empty   ${dl_l1SpCells_bbpoolInfo[1]}
    ${dll1spcells[1]}=    Run Keyword If     ${notEmpty}    Copy List     ${dl_l1SpCells_bbpoolInfo[1]}
    ...                          ELSE                       Copy List     ${dll1spcells[1]}
    ${notEmpty}    Run Keyword And Return Status    Should Not Be Empty   ${ul_l1SpCells_bbpoolInfo[0]}
    ${ull1spcells[0]}=    Run Keyword If     ${notEmpty}    Copy List     ${ul_l1SpCells_bbpoolInfo[0]}
    ...                          ELSE                       Copy List     ${ull1spcells[0]}
    ${notEmpty}    Run Keyword And Return Status    Should Not Be Empty   ${ul_l1SpCells_bbpoolInfo[1]}
    ${ull1spcells[1]}=    Run Keyword If     ${notEmpty}    Copy List     ${ul_l1SpCells_bbpoolInfo[1]}
    ...                          ELSE                       Copy List     ${ull1spcells[1]}
    set test variable    ${dll1spcells[0]}
    set test variable    ${dll1spcells[1]}
    set test variable    ${ull1spcells[0]}
    set test variable    ${ull1spcells[1]}
    dated log   dlsubcellSpool0List=${dll1spcells[0]}
    dated log   dlsubcellSpool1List=${dll1spcells[1]}
    dated log   ulsubcellSpool0List=${ull1spcells[0]}
    dated log   ulsubcellSpool1List=${ull1spcells[1]}

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${False}   Step                      CallSetup.WTS Set X2 Link

    Run Keyword If      '${kw Specific Set TestMode Before Attach}'!='${EMPTY}'
    ...                                                    Step   Run specific keywords before attach : ${kw Specific Set TestMode Before Attach}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start  actionTti=${isCaptureTti}

    # Register and launch PDU for all the ue's except for which define on the deleted cell
    FOR    ${current_elem}    IN    @{listOfUes}
        # Run Keyword If      ${current_elem.target_cells} != ${nrCell}    Run Keywords
        Run Keywords
        ...                 Critical Step       CallSetup UE register UeId "${current_elem.ue}" on Target cell "${current_elem.target_cells}"
        ...                                     depends=CallSetup.Setup Wtsemu SA
        ...    AND
        ...                 Critical Step     CallSetup.Launch PDU Session
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         gw=${current_elem.ue}
        ###...                                                      nwslice=1
        ...                                   depends=CallSetup UE register UeId
    END

    Run Keyword If    '${kw Specific Set TestMode After Attach}'!='${EMPTY}'
    ...                                                   Step   Run specific keywords after attach : ${kw Specific Set TestMode After Attach}

    ${rntiList}=    create list
    FOR    ${current_elem}    IN    @{listOfUes}
        ${UeId}      CB009836-Ue-Commands.Get Crnti From Egate Log     ue_id=${current_elem.ue}
        Dated log       ======> Rnti[UeId=${current_elem.ue}] is ${UeId}
        Append To List                ${rntiList}                  ${UeId}
    END
    Set Test Variable     ${rntiList}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step        Captures CB009836 Stop

    # Start the non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput} > ${0}    DL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.DL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.DL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session

        ${dir}=   set Variable If    ${current_elem.UL_throughput} > ${0}    UL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.UL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.UL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session
    END

    # PDU session modify reserved for the ue's configured with GBR traffic
    ${nbOfUe_traffic_GBR}=   CB009836-Keywords.Get Number Of Ue Configured With GBR Traffic    dict_ues=${listOfUes}
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If    ${current_elem.DL_throughput_GBR} > ${0}    Run Keywords
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=2
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
        ...    AND
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=3
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
    END

    # Start the GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput_GBR} > ${0}    DL
        ...                                                                      NONE
        ${kw to run}=   Catenate    ${dir} Traffic GBR SA Not Stopped with "${current_elem.DL_throughput_GBR}"Mbps "${param.duration}"s duration
        ...                         and "${param.deviation}" percent deviation
        Run Keyword If      '${current_elem.DL_throughput_GBR}' != '0'
        ...    Critical Step   ${kw to run}    depends=CallSetup.Launch PDU Session
    END

    ${tti_trace_path}    ${tti_trace_dict}=    Omit when TtiTrace deactivated
    ...             Process TTI Traces    Kw_Convert_TtiTrace_From_csv_to_Dict=${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}   step=For_Test_Verdict

    # add here Specific Check based on TtiTraces
    run Keyword if     '${kw Specific Check Tti}'!='${EMPTY}'     Omit when TtiTrace deactivated
    ...          Step      ${kw Specific Check Tti}     ttitraceFilename=ttitrace_streaming.pcap
    ...                                             ttitracepath=${tti_trace_path}
    ...                                             vendor_custom=${vendor_custom}
    ...                                             depends=CallSetup.Launch PDU Session

    ${FilePkl}=           Omit when TtiTrace deactivated
    ...      Run keyword and continue on failure      Convert TTI Traces to Dataframe and store as pickle for UL Mimo
    ...                                                                                                     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                                                     ttitracepath=${tti_trace_path}

    ${L1L2_Pcap_File}=   Omit when L1L2BipTrace deactivated    Get L1L2 traces          time=${GetL1L2TraceTime}
    ...                                                                                 prefix=L1L2Bip.wDLTput
    ...                                                                                 msg=take BIP L1L2 traces with DL Tput

    # add here Specific Check based on L1l2Bip pcap
    run Keyword if     '${kw Specific Check}'!='${EMPTY}'     Omit when L1L2BipTrace deactivated
    ...          Step      ${kw Specific Check}     captureL1L2=${L1L2_Pcap_File}.pcap
    ...                    depends=CallSetup.Launch PDU Session

    run Keyword if   '${L1L2_Pcap_File}' != 'None'      Run Keywords     Dated log    gzip -f ${L1L2_Pcap_File}.pcap
    ...                                                         AND      Run    gzip -f ${L1L2_Pcap_File}.pcap

    # Generate Verdict...
    Omit when TtiTrace deactivated      Step      Generate Test Verdict    ${FilePkl}   ${vendor_custom}
    ...                                                                    ${dictExpectedValues}
    ...                                                                    ${kw Check SCF parameters}
    ...                                                                    verify_TTITraces_for_csirs_6cells
    ...                                                                    ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                    ttitracepath=${tti_trace_path}

    ${cntUes}=    Get length    ${rntiList}
    Step      CB009836-Ue-Commands.Verify Nbr Of ${cntUes}Ues ACTIVE

    # if  '${SKIP_COUNTERS}'=='False' => 'Display PDSCH and PUSCH ue_stats_nr for UEList' allow to Wait time until next PM file
    Run Keyword And Ignore Error     Display PDSCH and PUSCH ue_stats_nr for UEList   UEsList=${listOfUes}    file=${csv_file_tput_results}

    # Collect PM only if  '${SKIP_COUNTERS}'=='False'
    Omit when SKIP_COUNTERS present      robot_extension.Run Keyword And Warn On Failure
    ...                                           CB009836-Keywords.Collect PM Counters and process throughput using PM counters

    # to bypass UE Deregister if needed
    @{listOfUes}    run Keyword if    '${w_ue_detach}' == 'False'    Create List
    ${len}=   Get Length   ${listOfUes}
    run Keyword if    '${len}' != '${0}'    Step    Traced Sleep   duration=3s   msg=deregistering     depends=CallSetup.UE Register
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.target_cells} != ${nrCell}
        ...                 Step      CallSetup.UE Deregister       id=${current_elem.ue}
        ###...                                                      ue_deregister_type=switch_off
        ###...                                                      by=ue
        ...                                                         depends=CallSetup.UE Register
    END
    [Teardown]   Run Keywords    Run Keyword and ignore error    Captures CB009836 Stop
    ...            AND           Teardow Kw

TC CB009836 4 Cells Robustness Test Setup
    [Documentation]
    ...     test template for CB009836 (Topology to used should be CLOUD_5G_O_E_AP_LOO_8DL8UL)
    ...     Conditions:     it is based on the arguments ${param}  ${dictParam}  ${vendor_custom} ${dict_ues} ${nrCell}
    ...     Actions:        it performs the call setup for multi-ues on different cells with DL traffic
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Arguments]             ${param}
    ...                     ${dictParam}
    ...                     ${vendor_custom}
    ...                     ${dict_ues}
    ...                     ${nrCell}
    ...                     ${kw Set RAD Params}=${EMPTY}
    ...                     ${kw NIDD Set}=${EMPTY}
    ...                     ${kw NIDD Check}=${EMPTY}
    ...                     ${kw Set TestMode}=${EMPTY}
    ...                     ${kw Active Config}=${EMPTY}
    ...                     ${kw Specific Set TestMode Before Attach}=${EMPTY}
    ...                     ${kw Specific Set TestMode After Attach}=${EMPTY}
    ...                     ${NIDD_9836_PARAMS}=${NIDD_9836_Q_L_PARAMS}
    ...                     ${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}=Convert TTI trace from csv to dict CB009836
    ...                     ${kw Check SCF parameters}=${EMPTY}
    ...                     ${kw Specific Check Tti}=${EMPTY}
    ...                     ${kw Specific Check}=${EMPTY}
    ...                     ${kw Specific Check CPRT}=${EMPTY}
    ...                     ${Kw TestLine Preparation}=${EMPTY}
    ...                     ${Kw Update NIDD Test Parameters}=${EMPTY}
    ...                     ${NIDD_9836_TEST_PARAMS}=${EMPTY}
    ...                     ${Json test configuration}=${EMPTY}
    ...                     ${FrameStructure}=5GC001208
    ...                     ${Step}=${EMPTY}

    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    ${topoOK}=      Evaluate     ${topoOK_1} or ${topoOK_2}
    ${msg_err}=     Catenate    topology USED [${topoUsed}] is not CORRECT for this test [${TEST NAME}].
    Run Keyword If            '${topoOK}'=='False'   dated log   ${consTraceColorBgRed}${consTraceColorYellow}${msg_err}${defColor} Plz, Check it...
    Return From Keyword If    '${topoOK}'=='False'
    Init Sequence           ${param}
    Create Header Csv Tput Test result
    ${ull1spcells_syslog}=    Create List
    ${dll1spcells_syslog}=    Create List
    set test variable     ${ull1spcells_syslog}
    set test variable     ${dll1spcells_syslog}
    Run Keyword If    '${Json test configuration}'!='${EMPTY}'    load Json test data   ${Json test configuration}   ${dict_ues}
    ...                                                                                 ${vendor_custom}   ${param}
    StringTool.printLineWithTitle     title=Display NIDD PARAMETERS of the Test TO SET
    FOR    ${item}    IN    @{NIDD_9836_PARAMS}
         continue for loop if     'list_name' in ${item}
         ${msg_display}=    StringTool.getHeaderLine    ${item}[dist_name]/${item}[pname]     ${item}[value]
         dated log      ${msg_display}
         # dated log    dist_name=${item}[dist_name] pname=${item}[pname] value=${item}[value]
    END
    StringTool.printLineWithTitle     title=-
    Step         Init CB009836 Test Variables    vendor_custom=${vendor_custom}    dict_ues=${dict_ues}    totalNbOfUe=${param.totalNbOfUe}
    Run Keyword If    '${kw Set RAD Params}'!='${EMPTY}'     Step         Run Keyword     ${kw Set RAD Params}
    # return from Keyword

    # ${iphy_file_4Cells} is dedicated to topo ASOE with 4 Cells
    # ${iphy_file_8Cells} is dedicated to topo ASOE with 8 Cells
    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    dated log     Topology is ${topoUsed}
    ${iphy_file_to_use}    Set Variable If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   ${iphy_file_8Cells}
    ...                                                                                             ${iphy_file_4Cells}
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_to_use}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_to_use}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [/tmp/${iphy_filename}] to AirPhone

    # Apply delta commissioning (WITH_APPLY_DELTA_COMMISSIONING=1) if requested
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1' and '${UPDATE_SCF}'=='1' and '${Kw TestLine Preparation}'!='${EMPTY}'
    ...                          Run Keywords       ${Kw TestLine Preparation}      output_scf=${test_scf_file}
    ...                              AND            Set Suite Variable              ${test_scf_file}
    # return from Keyword

    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...                                                Set CB009836 NIDD PARAMETERS VERSION 3 with SET into SCF     list=${NIDD_9836_PARAMS}
    # return from Keyword

    # Set NIDD PARAM If Needed / Kw use ${test_scf_file} file
    Run Keyword If    '${kw NIDD Set}'!='${EMPTY}' and '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'     ${kw NIDD Set}   list=${NIDD_9836_PARAMS}

    # Check if NIDD PARAM are as expected
    Run Keyword If    '${kw NIDD Check}'!='${EMPTY}'      ${kw NIDD Check}  list=${NIDD_9836_PARAMS}

    ${w_getSCF}=    Set Variable If     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'   true
    ...                                                                              false
    Run Keyword If    '${kw Active Config}'!='${EMPTY}'      ${kw Active Config}    w_getSCF=${w_getSCF}

    # update local scf.xml
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}

    # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure       Admin Validate SCF     scf_path_file=${test_scf_file}
    robot_extension.Run Keyword And Warn On Failure       Get Cipher and Integrity Parameters From SCF

    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}

    ${actTddCsirsAllocOptimization}   set variable     ${act9836TddCsirsAllocOptimization}
    @{PARAMS_IN_VENDOR}    Create List     actTddCsirsAllocOptimization=${actTddCsirsAllocOptimization}
    set test variable     ${PARAMS_IN_VENDOR}
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...         Critical Step    CB009836-TL-Preparation-Keywords.Deploy Vendor File to activate CB009836     PARAMS_IN_VENDOR=${PARAMS_IN_VENDOR}
    ...                                                                                                       is_perform_full_commissioning=${True}
    ...   ELSE
    ...          Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'
   ...             Run Keywords    Dated Log new line       ${consTraceColorRed}BEWARE that Deploy Vendor File Config is already DONE!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=4min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter
    # return from Keyword

    Run keyword and continue on failure     Verify actTddCsirsAllocOptimization status    status=${actTddCsirsAllocOptimization}

    # iPHY gscn update depending of chBwDl
    # get gscn for CELL1 from SCF
    ${gscn_cell1}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell1} for CELL1
    Step           CB009836-Keywords.Set Context_AP IPHY gscn Cell1 with ${gscn_cell1}

    ${gscn_cell2}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell2} for CELL2
    Step           CB009836-Keywords.Set Context_AP IPHY gscn Cell2 with ${gscn_cell2}

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER Commissioning / TL Restart${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs
    robot_extension.Run Keyword And Warn On Failure         Extract l2::ps::cnfg::AddressDistributionReq_t from Syslog
    robot_extension.Run Keyword And Warn On Failure         Display PRB POOLING NIDD param
    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    # save some test parameters as vendor file or Ue settings into ${testCaseDir}
    nps_9836_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${vendor_custom}    filename=data_test.json

    # Configure the current setting for all the ue's
    ${param.totalNbOfUe}    get length          ${dict_ues}
    Step                    Configure the setting for the ${param.totalNbOfUe} UEs
    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${param.totalNbOfUe}
        ${current_ue}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        Set To Dictionary             ${current_ueSetting}          trf_id              1
        Set To Dictionary             ${current_ueSetting}          target_gnb          ${param.targetGnb}
        Set To Dictionary             ${current_ueSetting}          size                ${dict_ues[${current_id}].packet_size}

        # Dispatching each ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ueSetting}          DL_throughput          ${dict_ues[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          UL_throughput          ${dict_ues[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}          protocol               ${dict_ues[${current_id}].protocol}

        Append To List                ${listOfUes}                  ${current_ueSetting}

        # save some test parameters as vendor file or Ue settings into ${testCaseDir}
        add_dictionary_to_json       ${testCaseDir}     'Ue_${current_ue}'   ${current_ueSetting}    data_test.json
    END
    # Dated Log New Line                UE_List=${listOfUes}
    display_list_parameters_w_name      ${listOfUes}   name=Ue   msg=Display Of listOfUes
    CB009836-Keywords.Check Multi Ues Setting In List        multiUesList=${listOfUes}

    set test Variable     ${listOfUes}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Init   prefix=CellSetup.Attach.SA.Traffic
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start  actionCORE=${isCaptureCORE}
    ...                                                                                        actionCPRT=${isCaptureCPRT}
    ...                                                                                        actionL1L2=${isCaptureL1L2}
    ...                                                                                        actionTti=${False}

    Log to console    =================================== TEST SETUP ===================================

    Setup devices aliases
    Enable internal mirroring for alias    gNB2

    Run Keyword If    '${Kw Update NIDD Test Parameters}'!='${EMPTY}'      Step      Run Keyword    ${Kw Update NIDD Test Parameters}
    # Step         Set OnLine maxCsirsNumber on ASOE 4 Cells
    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    ${LuaFileToUsed}=      Run Keyword If    '${W_CUSTOM_LUA_FILE_TO_USED}'=='1'       Install lua File into WTS    ${LuaFileToUsed_path}
    ...                        ELSE                                                    Set Variable                 ${EMPTY}
    set test variable      ${LuaFileToUsed}

    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog2_beforeCellSetup
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    run Keyword If    '${ret}' == 'FAIL'     BuiltIn.log    btslog.Stop Btslog is ${ret}! with ${syslogpath}     Level=ERROR     console=True
    ${fileExists}=     nps_9836_tools.file_exists   ${syslogpath}
    ${ret}    ${syslog_filename}   Run Keyword If   ${fileExists}==${True}
    ...                                           Run Keyword And Ignore Error    nps_9836_tools.return_basename   ${syslogpath}
    ...                              ELSE         ObtainVariablesKeyword
    robot_extension.Run Keyword And Warn On Failure   declare Trace in Trace List    Type=SysLog  Savedir=${dir_syslog}
    ...                          file_name=${syslog_filename}   Trigger=btslog2_beforeCellSetup
    robot_extension.Run Keyword And Warn On Failure   Check UL and DL l1Subpool Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}
    ...         Critical Step           Basic Call to Setup Wtsemu SA           nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${True}
    ...                                                             LuaFileToUsed=${LuaFileToUsed}
    # ...                                                             Kw_TM=${kw Set TestMode}
    ...   ELSE
    ...         Critical Step           CallSetup.Setup Wtsemu SA               nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${False}
    Dev_lib.wait_ng_link_up
    Dev_lib.start_to_capture_infomodel_log
    Run Keyword If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   CB009836-Keywords.Cell 1 cell 2 cell3 and cell4 Should Be Onair
    ...    ELSE                                                             All Cells Should Be Onair
    Dev_lib.stop_to_capture_infomodel_log

    # take into account SCOUT
    ${host_vm_ip}=  configuration_id.Get Host IP Address  host_index=1
    Run Keyword And Ignore Error    configuration_id.Start Testline Scout Monitor  host_vm_ip=${host_vm_ip}
    # ${return}    ${output}    robot_extension.Run Keyword And Warn On Failure    Setup.Produce Scout Data    timeout=120
    ${return}    ${output}    robot_extension.Run Keyword And Warn On Failure
    ...           CB009836-Test-Template-Keywords.Set SCOUT TC ID for Reporting    timeout=120
    run keyword if    '${return}'=='FAIL'    BuiltIn.log    Set SCOUT TC ID for Reporting ${return}! - reason=${output}
    ...                                                     level=ERROR    console=True

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    # test all cells mapped on same L1 Pool
    ${isFileNameDLCellMappingPresent}    Run Keyword And Return Status    Should Not Be Empty   ${FileNameDLCellMapping}
    ${fileExists}=     nps_9836_tools.file_exists   ${FileNameDLCellMapping}
    ${FileNameDLCellMapping}=    Set Variable If    ${fileExists}    ${FileNameDLCellMapping}    ${None}
    Run Keyword If   '${isFileNameDLCellMappingPresent}' == 'False' or not ${fileExists}
    ...                BuiltIn.Log    DL Cell mapping file not present (from Syslog), please check the config    level=WARN    console=yes
    ...    ELSE        check Dl Cell mapping from Syslog ${FileNameDLCellMapping}

    ${ret}  ${output}=    robot_extension.Run Keyword And Warn On Failure
    ...                                        Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog     NbrCells=4
    ${sorted_csirsGroups}            Set Variable     ${output[0]}
    ${sorted_cellcsirs_slotoffset}   Set Variable     ${output[1]}
    ${sorted_uecsirs_slotoffset}     Set Variable     ${output[2]}
    ${sorted_trscsirs_slotoffset}    Set Variable     ${output[3]}
    ${sorted_trscsirs_ssb_slotoffset}    Set Variable     ${output[4]}
    Dated Log New Line    sorted_csirsGroups=${sorted_csirsGroups}
    Dated Log New Line    sorted_cellcsirs_slotoffset=${sorted_cellcsirs_slotoffset}
    Dated Log New Line    sorted_trscsirs_slotoffset=${sorted_trscsirs_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}

    # check that we have all relation cell and csrirspool for all cells
    ${cell_csirsGroups}=  Get length   ${sorted_csirsGroups}
    Dated log    length of cell_csirsGroups = ${sorted_csirsGroups}
    ${List_nrCellIdentity}   Create List     16385    16386    16387    16388
    ${cell_missing_list}=    check_all_cell_csirspool_present      ${output[0]}    ${List_nrCellIdentity}
    ${cell_missing_in_cellcsirs_list}=    check_all_cell_in_cellcsirs_present      ${output[1]}    ${List_nrCellIdentity}
    ${NbrCellNoFound}=       Get length   ${cell_missing_list}
    ${NbrCellNoFound_in_cellcsirslist}=       Get length   ${cell_missing_in_cellcsirs_list}
    ${text}=    Catenate    Nb of cell csirsGroups relation not found = ${NbrCellNoFound} with cell_missing_list=${cell_missing_list}
    Run Keyword If   '${NbrCellNoFound}' != '0'    BuiltIn.Log
    ...    msg=${text}  level=WARN
    ${text}=    Catenate     Nb of cellcsirs relation not found=${NbrCellNoFound_in_cellcsirslist}
    ...                      with cell_missing_in_cellcsirs_list=${cell_missing_in_cellcsirs_list}
    ${levellog}=    Set Variable If    '${NbrCellNoFound}' != '${NbrCellNoFound_in_cellcsirslist}'    ERROR    WARN
    Run Keyword If   '${NbrCellNoFound_in_cellcsirslist}' != '0'    BuiltIn.Log
    ...    msg=${text}
    ...    level=${levellog}
    Dated log    Nb of cell csirsGroups relation not found = ${NbrCellNoFound} with cell_missing_list=${cell_missing_list}
    ${combined_cell_missing_list}    Combine Lists    ${cell_missing_list}    ${cell_missing_in_cellcsirs_list}
    ${combined_cell_missing_list}    Remove Duplicates    ${combined_cell_missing_list}
    ${final_NbrCellNoFound}=         Get length   ${combined_cell_missing_list}
    ${text}=    Catenate    Final decision : Nb of cell csirsGroups/cellcsirs relation not found = ${final_NbrCellNoFound}
    ...                     with cell_missing_list=${combined_cell_missing_list},
    ...                     => Try Lock and Unlock cells ${combined_cell_missing_list}
    Run Keyword If   '${final_NbrCellNoFound}' != '0'    BuiltIn.Log
    ...    msg=${text}  level=WARN
    Run Keyword If     '${final_NbrCellNoFound}' != '0'       Try Lock and Unlock cells    ${combined_cell_missing_list}
    ${sorted_csirsGroups}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                          ELSE                                               Copy List    ${sorted_csirsGroups}
    ${sorted_cellcsirs_slotoffset}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                                  ELSE                                                Copy List    ${sorted_cellcsirs_slotoffset}
    ${sorted_trscsirs_slotoffset}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                                  ELSE                                               Copy List    ${sorted_trscsirs_slotoffset}
    ${sorted_trscsirs_ssb_slotoffset}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                                      ELSE                                               Copy List    ${sorted_trscsirs_ssb_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}
    Run Keyword If     '${final_NbrCellNoFound}' != '0'       Update csirsGroups and cellcsirs
    # ${sorted_csirsGroups} is used by 'Check cellcsirs Assignement' Kw but also used by 'verify_TTITraces_for_csirs' Kw
    ${cellcsirs_slotoffset_present}   evaluate   len(${sorted_cellcsirs_slotoffset}) != ${0}
    run Keyword If    ${cellcsirs_slotoffset_present}
    ...            Run keyword and continue on failure     Check cellcsirs Assignement  ${sorted_cellcsirs_slotoffset}   ${FrameStructure}
    ...                                                                                 step=TestSetup
    ...     ELSE   declare Results in Test Results List    Type=SYSLOG [TestSetup]: Check Cell Specific CSI-RS allocation
    ...                                                    Result=WARN no cellcsirs_slotoffset_present
    # 08/20/2025 : Trs check is bypassed, only CsiRs position is checked
    # this is due to Introduction of new logging macro for too long strings in syslog
    # (see https://gerrit.ext.net.nokia.com/gerrit/c/MN/5G/NB/gnb/+/8938794/ ) => cellGroupSetupReq print have been changed in syslog!!!
    # Run keyword and continue on failure     Check TrsCsiRs Assignement   ${sorted_trscsirs_slotoffset}    ${FrameStructure}
    # ...                                                                  step=TestSetup
    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Check cellmappingtocsirspoolinggroup Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    ${num_of_cells}=    Get Cell Number
    @{cell_to_bypass}=  Create List    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-4
    Critical Step       Wait gNB cells 5g On air    ${num_of_cells}    cell_to_bypass=${cell_to_bypass}

    ${ret}   ${dll1spcells}    robot_extension.Run Keyword And Warn On Failure         Get dlsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    ${ret}   ${ull1spcells}    robot_extension.Run Keyword And Warn On Failure         Get ulsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    Set Suite Variable      ${dll1spcells}
    Set Suite Variable      ${ull1spcells}
    dated log   dlsubcellSpool0List=${dll1spcells[0]}
    dated log   dlsubcellSpool1List=${dll1spcells[1]}
    dated log   ulsubcellSpool0List=${ull1spcells[0]}
    dated log   ulsubcellSpool1List=${ull1spcells[1]}
    # set test variable    ${dll1spcells[0]}
    # set test variable    ${dll1spcells[1]}
    # set test variable    ${ull1spcells[0]}
    # set test variable    ${ull1spcells[1]}
    robot_extension.Run Keyword And Warn On Failure     update bbpoolInfo Dll1Subpool and Ull1Subpool Assignment

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${False}   Step                      CallSetup.WTS Set X2 Link

    Run Keyword If      '${kw Specific Set TestMode Before Attach}'!='${EMPTY}'
    ...                                                    Step   Run specific keywords before attach : ${kw Specific Set TestMode Before Attach}

    [Teardown]    Run Keyword      Log to console    =================================== End Of TEST SETUP ===================================


TC CB009836 4 Cells Robustness Core
    [Documentation]
    ...     test template for CB009836 (Topology to used should be CLOUD_5G_O_E_AP_LOO_8DL8UL)
    ...     Conditions:     it is based on the arguments ${param}  ${dictParam}  ${vendor_custom} ${dict_ues} ${nrCell}
    ...     Actions:        it performs the call setup for multi-ues on different cells with DL traffic
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Arguments]             ${param}
    ...                     ${dictParam}
    ...                     ${vendor_custom}
    ...                     ${dict_ues}
    ...                     ${nrCell}
    ...                     ${kw Set RAD Params}=${EMPTY}
    ...                     ${kw NIDD Set}=${EMPTY}
    ...                     ${kw NIDD Check}=${EMPTY}
    ...                     ${kw Set TestMode}=${EMPTY}
    ...                     ${kw Active Config}=${EMPTY}
    ...                     ${kw Specific Set TestMode Before Attach}=${EMPTY}
    ...                     ${kw Specific Set TestMode After Attach}=${EMPTY}
    ...                     ${NIDD_9836_PARAMS}=${NIDD_9836_Q_L_PARAMS}
    ...                     ${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}=Convert TTI trace from csv to dict CB009836
    ...                     ${kw Check SCF parameters}=${EMPTY}
    ...                     ${kw Specific Check Tti}=${EMPTY}
    ...                     ${kw Specific Check}=${EMPTY}
    ...                     ${kw Specific Check CPRT}=${EMPTY}
    ...                     ${Kw TestLine Preparation}=${EMPTY}
    ...                     ${Kw Update NIDD Test Parameters}=${EMPTY}
    ...                     ${NIDD_9836_TEST_PARAMS}=${EMPTY}
    ...                     ${Json test configuration}=${EMPTY}
    ...                     ${FrameStructure}=5GC001208
    ...                     ${Step}=${EMPTY}

    Run Keyword If    '${kw Active Config}'!='${EMPTY}'     robot_extension.Run Keyword And Warn On Failure
    ...                                                            Log config in result env file     ${kw Active Config}    ${Step}
    Run Keyword If    '${Step}'!='${EMPTY}'                  Append To File      ${resultFile}     \n${Step} ---> STARTED\n
    Run Keyword If    '${kw Active Config}'!='${EMPTY}'      ${kw Active Config}

    # update local scf.xml
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}

    # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure       Admin Validate SCF     scf_path_file=${test_scf_file}
    robot_extension.Run Keyword And Warn On Failure       Get Cipher and Integrity Parameters From SCF

    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    Dev_lib.start_to_capture_infomodel_log
    All Cells Should Be Onair    timeout=300
    Dev_lib.stop_to_capture_infomodel_log

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}

    ${actTddCsirsAllocOptimization}   set variable     ${act9836TddCsirsAllocOptimization}
    @{PARAMS_IN_VENDOR}    Create List     actTddCsirsAllocOptimization=${actTddCsirsAllocOptimization}
    Run keyword and continue on failure     Verify actTddCsirsAllocOptimization status    status=${actTddCsirsAllocOptimization}

    # if gNB restarted .... need to relauch wts!!!
    # ${LuaFileNameToUsed}   Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='onair'
    # ...                                                                    nps_9836_tools.return_basename   ${LuaFileToUsed}
    # Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='onair'
    # ...                                                                    Dev_lib.configure_and_start_wts  ${LuaFileNameToUsed}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Init   prefix=CellSetup.Attach.SA.Traffic
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start  actionCORE=${isCaptureCORE}
    ...                                                                                        actionCPRT=${isCaptureCPRT}
    ...                                                                                        actionL1L2=${isCaptureL1L2}
    ...                                                                                        actionTti=${False}

    Log to console    ========================== CORE RUN [${Step}] ==========================

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    # test all cells mapped on same L1 Pool
    ${isFileNameDLCellMappingPresent}    Run Keyword And Return Status    Should Not Be Empty   ${FileNameDLCellMapping}
    ${fileExists}=     nps_9836_tools.file_exists   ${FileNameDLCellMapping}
    ${FileNameDLCellMapping}=    Set Variable If    ${fileExists}    ${FileNameDLCellMapping}    ${None}
    Run Keyword If   '${isFileNameDLCellMappingPresent}' == 'False' or not ${fileExists}
    ...                BuiltIn.Log    DL Cell mapping file not present (from Syslog), please check the config    level=WARN    console=yes
    ...    ELSE        check Dl Cell mapping from Syslog ${FileNameDLCellMapping}

    ${ret}  ${output}=    robot_extension.Run Keyword And Warn On Failure
    ...                                        Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog     NbrCells=4
    ${sorted_csirsGroups}            Set Variable     ${output[0]}
    ${sorted_cellcsirs_slotoffset}   Set Variable     ${output[1]}
    ${sorted_uecsirs_slotoffset}     Set Variable     ${output[2]}
    ${sorted_trscsirs_slotoffset}    Set Variable     ${output[3]}
    ${sorted_trscsirs_ssb_slotoffset}    Set Variable     ${output[4]}
    Dated Log New Line    sorted_csirsGroups=${sorted_csirsGroups}
    Dated Log New Line    sorted_cellcsirs_slotoffset=${sorted_cellcsirs_slotoffset}
    Dated Log New Line    sorted_trscsirs_slotoffset=${sorted_trscsirs_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}

    # check that we have all relation cell and csrirspool for all cells
    ${cell_csirsGroups}=  Get length   ${sorted_csirsGroups}
    Dated log    length of cell_csirsGroups = ${sorted_csirsGroups}
    ${List_nrCellIdentity}   Create List     16385    16386    16387    16388
    ${cell_missing_list}=    check_all_cell_csirspool_present      ${output[0]}    ${List_nrCellIdentity}
    ${cell_missing_in_cellcsirs_list}=    check_all_cell_in_cellcsirs_present      ${output[1]}    ${List_nrCellIdentity}
    ${NbrCellNoFound}=       Get length   ${cell_missing_list}
    ${NbrCellNoFound_in_cellcsirslist}=       Get length   ${cell_missing_in_cellcsirs_list}
    ${text}=    Catenate    Nb of cell csirsGroups relation not found = ${NbrCellNoFound} with cell_missing_list=${cell_missing_list}
    ${levellog}=    Set Variable If    '${NbrCellNoFound}' != '${NbrCellNoFound_in_cellcsirslist}'    ERROR    WARN
    Run Keyword If   '${NbrCellNoFound}' != '0'    BuiltIn.Log
    ...    msg=${text}  level=${levellog}
    ${text}=    Catenate     Nb of cellcsirs relation not found=${NbrCellNoFound_in_cellcsirslist}
    ...                      with cell_missing_in_cellcsirs_list=${cell_missing_in_cellcsirs_list}
    Run Keyword If   '${NbrCellNoFound_in_cellcsirslist}' != '0'    BuiltIn.Log
    ...    msg=${text}
    ...    level=${levellog}
    Dated log  Nb of cell csirsGroups relation not found = ${NbrCellNoFound} with cell_missing_list=${cell_missing_list}
    Dated log  Nb of cell cellcsirs relation not found = ${NbrCellNoFound_in_cellcsirslist} with cell_missing_list=${cell_missing_in_cellcsirs_list}
    ${combined_cell_missing_list}    Combine Lists    ${cell_missing_list}    ${cell_missing_in_cellcsirs_list}
    ${combined_cell_missing_list}    Remove Duplicates    ${combined_cell_missing_list}
    ${final_NbrCellNoFound}=         Get length   ${combined_cell_missing_list}
    ${text}=    Catenate    Final decision : Nb of cell csirsGroups/cellcsirs relation not found = ${final_NbrCellNoFound}
    ...                     with cell_missing_list=${combined_cell_missing_list},
    ...                     => Try Lock and Unlock cells ${combined_cell_missing_list}
    Run Keyword If   '${final_NbrCellNoFound}' != '0'    BuiltIn.Log
    ...    msg=${text}  level=${levellog}
    Run Keyword If     '${final_NbrCellNoFound}' != '0'       Try Lock and Unlock cells    ${combined_cell_missing_list}
    ${sorted_csirsGroups}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                          ELSE                                               Copy List    ${sorted_csirsGroups}
    ${sorted_cellcsirs_slotoffset}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                                  ELSE                                                Copy List    ${sorted_cellcsirs_slotoffset}
    ${sorted_trscsirs_slotoffset}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                                  ELSE                                               Copy List    ${sorted_trscsirs_slotoffset}
    ${sorted_trscsirs_ssb_slotoffset}=   Run Keyword If    '${final_NbrCellNoFound}' == '4'     Create List
    ...                                      ELSE                                               Copy List    ${sorted_trscsirs_ssb_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}
    Run Keyword If     '${final_NbrCellNoFound}' != '0'       Update csirsGroups and cellcsirs
    # ${sorted_csirsGroups} is used by 'Check cellcsirs Assignement' Kw but also used by 'verify_TTITraces_for_csirs' Kw
    ${cellcsirs_slotoffset_present}   evaluate   len(${sorted_cellcsirs_slotoffset}) != ${0}
    run Keyword If    ${cellcsirs_slotoffset_present}
    ...            Run keyword and continue on failure     Check cellcsirs Assignement  ${sorted_cellcsirs_slotoffset}   ${FrameStructure}
    ...                                                                                 step=Run${Step}
    ...     ELSE   declare Results in Test Results List    Type=SYSLOG [Run${Step}]: Check Cell Specific CSI-RS allocation
    ...                                                    Result=WARN no cellcsirs_slotoffset_present
    # 08/20/2025 : Trs check is bypassed, only CsiRs position is checked
    # this is due to Introduction of new logging macro for too long strings in syslog
    # (see https://gerrit.ext.net.nokia.com/gerrit/c/MN/5G/NB/gnb/+/8938794/ ) => cellGroupSetupReq print have been changed in syslog!!!
    # Run keyword and continue on failure     Check TrsCsiRs Assignement   ${sorted_trscsirs_slotoffset}    ${FrameStructure}    step=Run${Step}

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Check cellmappingtocsirspoolinggroup Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    ${num_of_cells}=    Get Cell Number
    @{cell_to_bypass}=  Create List    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-4
    Critical Step       Wait gNB cells 5g On air    ${num_of_cells}    cell_to_bypass=${cell_to_bypass}

    ${ret}   ${dll1spcells}    robot_extension.Run Keyword And Warn On Failure         Get dlsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    ${ret}   ${ull1spcells}    robot_extension.Run Keyword And Warn On Failure         Get ulsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    Set Suite Variable      ${dll1spcells}
    Set Suite Variable      ${ull1spcells}
    dated log   dlsubcellSpool0List=${dll1spcells[0]}
    dated log   dlsubcellSpool1List=${dll1spcells[1]}
    dated log   ulsubcellSpool0List=${ull1spcells[0]}
    dated log   ulsubcellSpool1List=${ull1spcells[1]}
    # set test variable    ${dll1spcells[0]}
    # set test variable    ${dll1spcells[1]}
    # set test variable    ${ull1spcells[0]}
    # set test variable    ${ull1spcells[1]}
    robot_extension.Run Keyword And Warn On Failure     update bbpoolInfo Dll1Subpool and Ull1Subpool Assignment

    Run Keyword If      '${kw Specific Set TestMode Before Attach}'!='${EMPTY}'
    ...                                                    Step   Run specific keywords before attach : ${kw Specific Set TestMode Before Attach}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start  actionTti=${isCaptureTti}

    # Register and launch PDU for all the ue's except for which define on the deleted cell
    # FOR    ${current_elem}    IN    @{listOfUes}
        # Run Keyword If      ${current_elem.target_cells} != ${nrCell}    Run Keywords
    #     Run Keywords
    #    ...                 Critical Step       CallSetup UE register UeId "${current_elem.ue}" on Target cell "${current_elem.target_cells}"
    #    ...                                     depends=CallSetup.Setup Wtsemu SA
    #    ...    AND
    #    ...                 Critical Step     CallSetup.Launch PDU Session
    #    ...                                                         ue=${current_elem.ue}
    #    ...                                                         pdu=${current_elem.pdu}
    #    ...                                                         gw=${current_elem.ue}
        ###...                                                      nwslice=1
    #    ...                                   depends=CallSetup UE register UeId
    # END

    # Register and launch PDU for all the ue's except for which define on the deleted cell
    ${rntiList}=    create list
    Set Test Variable     ${rntiList}
    FOR    ${current_elem}    IN    @{listOfUes}
        # Run Keyword If      ${current_elem.target_cells} != ${nrCell}    Run Keywords
        BuiltIn.sleep     1
        ${status}   run keyword and return status  CallSetup UE register UeId "${current_elem.ue}" on Target cell "${current_elem.target_cells}"
        run keyword if    not ${status}    BuiltIn.log    Try to register SA UE${current_elem.ue} FAILED!    level=ERROR
        BuiltIn.sleep     1
        IF  ${status}
            ${status_pdu}     run keyword and return status     CallSetup.Launch PDU Session      ue=${current_elem.ue}
            ...                                                                                   pdu=${current_elem.pdu}
            ...                                                                                   gw=${current_elem.ue}
            IF        not ${status_pdu}
                        BuiltIn.log    UE PDU Session Setup on UE${current_elem.ue} FAILED!    level=ERROR
            ELSE
                        BuiltIn.log to console  UE${current_elem.ue} is registered to 5G in SA Mode!
            END
        END
    END
    Set Test Variable     ${rntiList}

    Run Keyword If    '${kw Specific Set TestMode After Attach}'!='${EMPTY}'
    ...                                                   Step   Run specific keywords after attach : ${kw Specific Set TestMode After Attach}

    ${rntiList}=    create list
    FOR    ${current_elem}    IN    @{listOfUes}
        ${UeId}      CB009836-Ue-Commands.Get Crnti From Egate Log     ue_id=${current_elem.ue}
        Dated log       ======> Rnti[UeId=${current_elem.ue}] is ${UeId}
        Append To List                ${rntiList}                  ${UeId}
    END
    Set Test Variable     ${rntiList}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step        Captures CB009836 Stop

    # Start the non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput} > ${0}    DL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.DL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.DL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session

        ${dir}=   set Variable If    ${current_elem.UL_throughput} > ${0}    UL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.UL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.UL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session
    END

    # PDU session modify reserved for the ue's configured with GBR traffic
    ${nbOfUe_traffic_GBR}=   CB009836-Keywords.Get Number Of Ue Configured With GBR Traffic    dict_ues=${listOfUes}
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If    ${current_elem.DL_throughput_GBR} > ${0}    Run Keywords
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=2
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
        ...    AND
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=3
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
    END

    # Start the GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput_GBR} > ${0}    DL
        ...                                                                      NONE
        ${kw to run}=   Catenate    ${dir} Traffic GBR SA Not Stopped with "${current_elem.DL_throughput_GBR}"Mbps "${param.duration}"s duration
        ...                         and "${param.deviation}" percent deviation
        Run Keyword If      '${current_elem.DL_throughput_GBR}' != '0'
        ...    Critical Step   ${kw to run}    depends=CallSetup.Launch PDU Session
    END

    ${tti_trace_path}    ${tti_trace_dict}=    Omit when TtiTrace deactivated
    ...             Process TTI Traces For test Robustness    step=For_Test_Verdict_Run${Step}

    # add here Specific Check based on TtiTraces
    run Keyword if     '${kw Specific Check Tti}'!='${EMPTY}'     Omit when TtiTrace deactivated
    ...          Step      ${kw Specific Check Tti}     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                 ttitracepath=${tti_trace_path}
    ...                                                 vendor_custom=${vendor_custom}
    ...                                                 depends=CallSetup.Launch PDU Session

    ${FilePkl}=           Omit when TtiTrace deactivated
    ...      Run keyword and continue on failure      Convert TTI Traces to Dataframe and store as pickle for UL Mimo
    ...                                                                                                     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                                                     ttitracepath=${tti_trace_path}

    ${L1L2_Pcap_File}=   Omit when L1L2BipTrace deactivated    Get L1L2 traces          time=${GetL1L2TraceTime}
    ...                                                                                 prefix=L1L2Bip.wDLTput.Run${Step}
    ...                                                                                 msg=take BIP L1L2 traces with DL Tput
    # add here Specific Check based on L1l2Bip pcap
    run Keyword if     '${kw Specific Check}'!='${EMPTY}'     Omit when L1L2BipTrace deactivated
    ...          Step      ${kw Specific Check}     captureL1L2=${L1L2_Pcap_File}.pcap     step=Run${Step}
    ...                    depends=CallSetup.Launch PDU Session

    run Keyword if   '${L1L2_Pcap_File}' != 'None'      Run Keywords     Dated log    gzip -f ${L1L2_Pcap_File}.pcap
    ...                                                         AND      Run    gzip -f ${L1L2_Pcap_File}.pcap

    # Generate Verdict...
    Omit when TtiTrace deactivated      Step      Generate Test Verdict For Test Robustness    ${FilePkl}   ${vendor_custom}
    ...                                                                                        ${dictExpectedValues}
    ...                                                                                        ${kw Check SCF parameters}
    ...                                                                                        verify_TTITraces_for_csirs_4cells
    ...                                                                                        Run${Step}

    ${cntUes}=    Get length    ${rntiList}
    robot_extension.Run Keyword And Warn On Failure      CB009836-Ue-Commands.Verify Nbr Of ${cntUes}Ues ACTIVE

    # if  '${SKIP_COUNTERS}'=='False' => 'Display PDSCH and PUSCH ue_stats_nr for UEList' allow to Wait time until next PM file
    Run Keyword And Ignore Error     Display PDSCH and PUSCH ue_stats_nr for UEList   UEsList=${listOfUes}    file=${csv_file_tput_results}

    # Collect PM only if  '${SKIP_COUNTERS}'=='False'
    # Omit when SKIP_COUNTERS present      robot_extension.Run Keyword And Warn On Failure
    # ...                                           CB009836-Keywords.Collect PM Counters and process throughput using PM counters

    Omit when SKIP_COUNTERS present      run Keyword and continue on failure
    ...                                           CB009836-Keywords.Collect PM Counters and process with counters verification

    # to bypass UE Deregister if needed
    @{listOfUes}    run Keyword if    '${w_ue_detach}' == 'False'    Create List
    ...                ELSE                                          Copy List     ${listOfUes}
    ${len}=   Get Length   ${listOfUes}
    run Keyword if    '${len}' != '${0}'    Step    Traced Sleep   duration=3s   msg=deregistering     depends=CallSetup.UE Register
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{listOfUes}
        Step      CallSetup.UE Deregister       id=${current_elem.ue}
        ###...                                  ue_deregister_type=switch_off
        ###...                                  by=ue
        ...                                     depends=CallSetup.UE Register
    END

    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog2_Run${Step}
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    run Keyword If    '${ret}' == 'FAIL'     BuiltIn.log    btslog.Stop Btslog is ${ret}! with ${syslogpath}     level=ERROR     console=True
    ${fileExists}=     nps_9836_tools.file_exists   ${syslogpath}
    ${ret}    ${syslog_filename}   Run Keyword If   ${fileExists}==${True}
    ...                                           Run Keyword And Ignore Error    nps_9836_tools.return_basename   ${syslogpath}
    ...                              ELSE         ObtainVariablesKeyword
    robot_extension.Run Keyword And Warn On Failure   declare Trace in Trace List    Type=SysLog  Savedir=${dir_syslog}
    ...                          file_name=${syslog_filename}   Trigger=btslog2_Run${Step}
    # robot_extension.Run Keyword And Warn On Failure   Check UL and DL l1Subpool Assignment in Syslogs
    [Teardown]   Teardow Kw


TC CB009836 4 Cells Robustness
    [Documentation]
    ...     test template for CB009836 (Topology to used should be CLOUD_5G_O_E_AP_LOO_8DL8UL)
    ...     Conditions:     it is based on the arguments ${param}  ${dictParam}  ${vendor_custom} ${dict_ues} ${nrCell}
    ...     Actions:        it performs the call setup for multi-ues on different cells with DL traffic
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Arguments]             ${param}
    ...                     ${dictParam}
    ...                     ${vendor_custom}
    ...                     ${dict_ues}
    ...                     ${nrCell}
    ...                     ${kw Set RAD Params}=${EMPTY}
    ...                     ${kw NIDD Set}=${EMPTY}
    ...                     ${kw NIDD Check}=${EMPTY}
    ...                     ${kw Set TestMode}=${EMPTY}
    ...                     ${kw Active Config}=${EMPTY}
    ...                     ${kw Specific Set TestMode Before Attach}=${EMPTY}
    ...                     ${kw Specific Set TestMode After Attach}=${EMPTY}
    ...                     ${NIDD_9836_PARAMS}=${NIDD_9836_Q_L_PARAMS}
    ...                     ${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}=Convert TTI trace from csv to dict CB009836
    ...                     ${kw Check SCF parameters}=${EMPTY}
    ...                     ${kw Specific Check Tti}=${EMPTY}
    ...                     ${kw Specific Check}=${EMPTY}
    ...                     ${kw Specific Check CPRT}=${EMPTY}
    ...                     ${Kw TestLine Preparation}=${EMPTY}
    ...                     ${Kw Update NIDD Test Parameters}=${EMPTY}
    ...                     ${NIDD_9836_TEST_PARAMS}=${EMPTY}
    ...                     ${Json test configuration}=${EMPTY}
    ...                     ${FrameStructure}=5GC001208
    ...                     ${Step}=${EMPTY}

    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    ${topoOK}=      Evaluate     ${topoOK_1} or ${topoOK_2}
    ${msg_err}=     Catenate    topology USED [${topoUsed}] is not CORRECT for this test [${TEST NAME}].
    Run Keyword If            '${topoOK}'=='False'   dated log   ${consTraceColorBgRed}${consTraceColorYellow}${msg_err}${defColor} Plz, Check it...
    Return From Keyword If    '${topoOK}'=='False'
    Init Sequence           ${param}
    Create Header Csv Tput Test result
    ${ull1spcells_syslog}=    Create List
    ${dll1spcells_syslog}=    Create List
    set test variable     ${ull1spcells_syslog}
    set test variable     ${dll1spcells_syslog}
    Run Keyword If    '${Json test configuration}'!='${EMPTY}'    load Json test data   ${Json test configuration}   ${dict_ues}
    ...                                                                                 ${vendor_custom}   ${param}
    StringTool.printLineWithTitle     title=Display NIDD PARAMETERS of the Test TO SET
    FOR    ${item}    IN    @{NIDD_9836_PARAMS}
         continue for loop if     'list_name' in ${item}
         ${msg_display}=    StringTool.getHeaderLine    ${item}[dist_name]/${item}[pname]     ${item}[value]
         dated log      ${msg_display}
         # dated log    dist_name=${item}[dist_name] pname=${item}[pname] value=${item}[value]
    END
    StringTool.printLineWithTitle     title=-
    Step         Init CB009836 Test Variables    vendor_custom=${vendor_custom}    dict_ues=${dict_ues}    totalNbOfUe=${param.totalNbOfUe}
    Run Keyword If    '${kw Set RAD Params}'!='${EMPTY}'     Step         Run Keyword     ${kw Set RAD Params}
    # return from Keyword

    # ${iphy_file_4Cells} is dedicated to topo ASOE with 4 Cells
    # ${iphy_file_8Cells} is dedicated to topo ASOE with 8 Cells
    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    dated log     Topology is ${topoUsed}
    ${iphy_file_to_use}    Set Variable If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   ${iphy_file_8Cells}
    ...                                                                                             ${iphy_file_4Cells}
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_to_use}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_to_use}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [/tmp/${iphy_filename}] to AirPhone

    # Apply delta commissioning (WITH_APPLY_DELTA_COMMISSIONING=1) if requested
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1' and '${UPDATE_SCF}'=='1' and '${Kw TestLine Preparation}'!='${EMPTY}'
    ...                          Run Keywords       ${Kw TestLine Preparation}      output_scf=${test_scf_file}
    ...                              AND            Set Suite Variable              ${test_scf_file}
    # return from Keyword

    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...                                                Set CB009836 NIDD PARAMETERS VERSION 3 with SET into SCF     list=${NIDD_9836_PARAMS}
    # return from Keyword

    # Set NIDD PARAM If Needed / Kw use ${test_scf_file} file
    Run Keyword If    '${kw NIDD Set}'!='${EMPTY}' and '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'     ${kw NIDD Set}   list=${NIDD_9836_PARAMS}

    # Check if NIDD PARAM are as expected
    Run Keyword If    '${kw NIDD Check}'!='${EMPTY}'      ${kw NIDD Check}  list=${NIDD_9836_PARAMS}

    ${w_getSCF}=    Set Variable If     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'   true
    ...                                                                              false
    Run Keyword If    '${kw Active Config}'!='${EMPTY}'      ${kw Active Config}    w_getSCF=${w_getSCF}

    # update local scf.xml
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}

    # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure       Admin Validate SCF     scf_path_file=${test_scf_file}
    robot_extension.Run Keyword And Warn On Failure       Get Cipher and Integrity Parameters From SCF

    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}

    ${actTddCsirsAllocOptimization}   set variable     ${act9836TddCsirsAllocOptimization}
    @{PARAMS_IN_VENDOR}    Create List     actTddCsirsAllocOptimization=${actTddCsirsAllocOptimization}
    set test variable     ${PARAMS_IN_VENDOR}
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...         Critical Step    CB009836-TL-Preparation-Keywords.Deploy Vendor File to activate CB009836     PARAMS_IN_VENDOR=${PARAMS_IN_VENDOR}
    ...                                                                                                       is_perform_full_commissioning=${True}
    ...   ELSE
    ...          Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'
   ...             Run Keywords    Dated Log new line       ${consTraceColorRed}BEWARE that Deploy Vendor File Config is already DONE!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=4min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter
    # return from Keyword

    Run keyword and continue on failure     Verify actTddCsirsAllocOptimization status    status=${actTddCsirsAllocOptimization}

    # Set NIDD PARAM If Needed / Kw use ${test_scf_file} file
    # Run Keyword If    '${kw NIDD Set}'!='${EMPTY}' and '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'     ${kw NIDD Set}   list=${NIDD_9836_PARAMS}

    # Check if NIDD PARAM are as expected
    # Run Keyword If    '${kw NIDD Check}'!='${EMPTY}'      ${kw NIDD Check}  list=${NIDD_9836_PARAMS}

    # Run Keyword If    '${kw Active Config}'!='${EMPTY}' and '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'      ${kw Active Config}
    #   list=${NIDD_9836_PARAMS}
    # Run Keyword If    '${kw Active Config}'!='${EMPTY}'      ${kw Active Config}

    # update local scf.xml
    # ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    # set suite variable     ${test_scf_file}

    # add here check of NIDD configuration
    # robot_extension.Run Keyword And Warn On Failure       Admin Validate SCF     scf_path_file=${test_scf_file}
    # robot_extension.Run Keyword And Warn On Failure       Get Cipher and Integrity Parameters From SCF

    # iPHY gscn update depending of chBwDl
    # get gscn for CELL1 from SCF
    ${gscn_cell1}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell1} for CELL1
    Step           CB009836-Keywords.Set Context_AP IPHY gscn Cell1 with ${gscn_cell1}

    ${gscn_cell2}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell2} for CELL2
    Step           CB009836-Keywords.Set Context_AP IPHY gscn Cell2 with ${gscn_cell2}

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER Commissioning / TL Restart${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs
    robot_extension.Run Keyword And Warn On Failure         Extract l2::ps::cnfg::AddressDistributionReq_t from Syslog
    robot_extension.Run Keyword And Warn On Failure         Display PRB POOLING NIDD param
    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    # save some test parameters as vendor file or Ue settings into ${testCaseDir}
    nps_9836_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${vendor_custom}    filename=data_test.json

    # Configure the current setting for all the ue's
    ${param.totalNbOfUe}    get length          ${dict_ues}
    Step                    Configure the setting for the ${param.totalNbOfUe} UEs
    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${param.totalNbOfUe}
        ${current_ue}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        Set To Dictionary             ${current_ueSetting}          trf_id              1
        Set To Dictionary             ${current_ueSetting}          target_gnb          ${param.targetGnb}
        Set To Dictionary             ${current_ueSetting}          size                ${dict_ues[${current_id}].packet_size}

        # Dispatching each ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ueSetting}          DL_throughput          ${dict_ues[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          UL_throughput          ${dict_ues[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}          protocol               ${dict_ues[${current_id}].protocol}

        Append To List                ${listOfUes}                  ${current_ueSetting}

        # save some test parameters as vendor file or Ue settings into ${testCaseDir}
        add_dictionary_to_json       ${testCaseDir}     'Ue_${current_ue}'   ${current_ueSetting}    data_test.json
    END
    # Dated Log New Line                UE_List=${listOfUes}
    display_list_parameters_w_name      ${listOfUes}   name=Ue   msg=Display Of listOfUes
    CB009836-Keywords.Check Multi Ues Setting In List        multiUesList=${listOfUes}

    set test Variable     ${listOfUes}
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Init   prefix=CellSetup.Attach.SA.Traffic
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start  actionCORE=${isCaptureCORE}
    ...                                                                                        actionCPRT=${isCaptureCPRT}
    ...                                                                                        actionL1L2=${isCaptureL1L2}
    ...                                                                                        actionTti=${isCaptureTti}

    Log to console    ============================= STEP 1 =============================

    # ${kw Set TestMode} is a robot Kw that allow to modify cfg file
    Run Keyword If    '${kw Set TestMode}'!='${EMPTY}'       ${kw Set TestMode}

    Setup devices aliases
    Enable internal mirroring for alias    gNB2

    Run Keyword If    '${Kw Update NIDD Test Parameters}'!='${EMPTY}'      Step      Run Keyword    ${Kw Update NIDD Test Parameters}
    # Step         Set OnLine maxCsirsNumber on ASOE 4 Cells
    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    ${LuaFileToUsed}=      Run Keyword If    '${W_CUSTOM_LUA_FILE_TO_USED}'=='1'       Install lua File into WTS    ${LuaFileToUsed_path}
    ...                        ELSE                                                    Set Variable                 ${EMPTY}

    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog2_beforeCellSetup
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    run Keyword If    '${ret}' == 'FAIL'     BuiltIn.log    btslog.Stop Btslog is ${ret}! with ${syslogpath}     level=ERROR  console=True
    ${fileExists}=     nps_9836_tools.file_exists   ${syslogpath}
    ${ret}    ${syslog_filename}   Run Keyword If   ${fileExists}==${True}
    ...                                           Run Keyword And Ignore Error    nps_9836_tools.return_basename   ${syslogpath}
    ...                              ELSE         ObtainVariablesKeyword
    robot_extension.Run Keyword And Warn On Failure   declare Trace in Trace List    Type=SysLog  Savedir=${dir_syslog}
    ...                          file_name=${syslog_filename}   Trigger=btslog2_beforeCellSetup
    robot_extension.Run Keyword And Warn On Failure   Check UL and DL l1Subpool Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}
    ...         Critical Step           Basic Call to Setup Wtsemu SA           nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${True}
    ...                                                             LuaFileToUsed=${LuaFileToUsed}
    # ...                                                             Kw_TM=${kw Set TestMode}
    ...   ELSE
    ...         Critical Step           CallSetup.Setup Wtsemu SA               nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${False}
    Dev_lib.wait_ng_link_up
    Dev_lib.start_to_capture_infomodel_log
    Run Keyword If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   CB009836-Keywords.Cell 1 cell 2 cell3 and cell4 Should Be Onair
    ...    ELSE                                                             All Cells Should Be Onair
    Dev_lib.stop_to_capture_infomodel_log

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    # test all cells mapped on same L1 Pool
    ${isFileNameDLCellMappingPresent}    Run Keyword And Return Status    Should Not Be Empty   ${FileNameDLCellMapping}
    ${fileExists}=     nps_9836_tools.file_exists   ${FileNameDLCellMapping}
    ${FileNameDLCellMapping}=    Set Variable If    ${fileExists}    ${FileNameDLCellMapping}    ${None}
    Run Keyword If   '${isFileNameDLCellMappingPresent}' == 'False' or not ${fileExists}
    ...                BuiltIn.Log    DL Cell mapping file not present (from Syslog), please check the config    level=WARN    console=yes
    ...    ELSE        check Dl Cell mapping from Syslog ${FileNameDLCellMapping}

    ${ret}  ${output}=    robot_extension.Run Keyword And Warn On Failure
    ...                                        Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog     NbrCells=4
    ${sorted_csirsGroups}            Set Variable     ${output[0]}
    ${sorted_cellcsirs_slotoffset}   Set Variable     ${output[1]}
    ${sorted_uecsirs_slotoffset}     Set Variable     ${output[2]}
    ${sorted_trscsirs_slotoffset}    Set Variable     ${output[3]}
    Dated Log New Line    sorted_csirsGroups=${sorted_csirsGroups}
    Dated Log New Line    sorted_cellcsirs_slotoffset=${sorted_cellcsirs_slotoffset}
    Dated Log New Line    sorted_trscsirs_slotoffset=${sorted_trscsirs_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}

    # check that we have all relation cell and csrirspool for all cells
    ${cell_csirsGroups}=  Get length   ${sorted_csirsGroups}
    Dated log    length of cell_csirsGroups = ${sorted_csirsGroups}
    ${List_nrCellIdentity}   Create List     16385    16386    16387    16388
    ${cell_missing_list}=    check_all_cell_csirspool_present      ${output[0]}    ${List_nrCellIdentity}
    ${NbrCellNoFound}=       Get length   ${cell_missing_list}
    Dated log    Nb of cell csirsGroups relation not found = ${NbrCellNoFound} with cell_missing_list=${cell_missing_list}
    Run Keyword If     '${NbrCellNoFound}' != '0'       Try Lock and Unlock cells    ${cell_missing_list}
    Run Keyword If     '${NbrCellNoFound}' != '0'       Update csirsGroups and cellcsirs
    # ${sorted_csirsGroups} is used by 'Check cellcsirs Assignement' Kw but also used by 'verify_TTITraces_for_csirs' Kw
    ${cellcsirs_slotoffset_present}   evaluate   len(${sorted_cellcsirs_slotoffset}) != ${0}
    run Keyword If    ${cellcsirs_slotoffset_present}
    ...            Run keyword and continue on failure     Check cellcsirs Assignement  ${sorted_cellcsirs_slotoffset}   ${FrameStructure}
    ...     ELSE   declare Results in Test Results List    Type=SYSLOG : Check Cell Specific CSI-RS allocation
    ...                                                    Result=WARN no cellcsirs_slotoffset_present
    # 08/20/2025 : Trs check is bypassed, only CsiRs position is checked
    # this is due to Introduction of new logging macro for too long strings in syslog
    # (see https://gerrit.ext.net.nokia.com/gerrit/c/MN/5G/NB/gnb/+/8938794/ ) => cellGroupSetupReq print have been changed in syslog!!!
    # Run keyword and continue on failure     Check TrsCsiRs Assignement   ${sorted_trscsirs_slotoffset}    ${FrameStructure}

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Check cellmappingtocsirspoolinggroup Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    ${num_of_cells}=    Get Cell Number
    @{cell_to_bypass}=  Create List    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-4
    Critical Step       Wait gNB cells 5g On air    ${num_of_cells}    cell_to_bypass=${cell_to_bypass}

    ${ret}   ${dll1spcells}    robot_extension.Run Keyword And Warn On Failure         Get dlsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    ${ret}   ${ull1spcells}    robot_extension.Run Keyword And Warn On Failure         Get ulsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    Set Suite Variable      ${dll1spcells}
    Set Suite Variable      ${ull1spcells}
    dated log   dlsubcellSpool0List=${dll1spcells[0]}
    dated log   dlsubcellSpool1List=${dll1spcells[1]}
    dated log   ulsubcellSpool0List=${ull1spcells[0]}
    dated log   ulsubcellSpool1List=${ull1spcells[1]}
    set test variable    ${dll1spcells[0]}
    set test variable    ${dll1spcells[1]}
    set test variable    ${ull1spcells[0]}
    set test variable    ${ull1spcells[1]}
    robot_extension.Run Keyword And Warn On Failure     update bbpoolInfo Dll1Subpool and Ull1Subpool Assignment

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${False}   Step                      CallSetup.WTS Set X2 Link

    Run Keyword If      '${kw Specific Set TestMode Before Attach}'!='${EMPTY}'
    ...                                                    Step   Run specific keywords before attach : ${kw Specific Set TestMode Before Attach}

    # Register and launch PDU for all the ue's except for which define on the deleted cell
    FOR    ${current_elem}    IN    @{listOfUes}
        # Run Keyword If      ${current_elem.target_cells} != ${nrCell}    Run Keywords
        Run Keywords
        ...                 Critical Step       CallSetup UE register UeId "${current_elem.ue}" on Target cell "${current_elem.target_cells}"
        ...                                     depends=CallSetup.Setup Wtsemu SA
        ...    AND
        ...                 Critical Step     CallSetup.Launch PDU Session
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         gw=${current_elem.ue}
        ###...                                                      nwslice=1
        ...                                   depends=CallSetup UE register UeId
    END

    Run Keyword If    '${kw Specific Set TestMode After Attach}'!='${EMPTY}'
    ...                                                   Step   Run specific keywords after attach : ${kw Specific Set TestMode After Attach}

    ${rntiList}=    create list
    FOR    ${current_elem}    IN    @{listOfUes}
        ${UeId}      CB009836-Ue-Commands.Get Crnti From Egate Log     ue_id=${current_elem.ue}
        Dated log       ======> Rnti[UeId=${current_elem.ue}] is ${UeId}
        Append To List                ${rntiList}                  ${UeId}
    END
    Set Test Variable     ${rntiList}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step        Captures CB009836 Stop

    # Start the non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput} > ${0}    DL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.DL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.DL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session

        ${dir}=   set Variable If    ${current_elem.UL_throughput} > ${0}    UL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.UL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.UL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session
    END

    # PDU session modify reserved for the ue's configured with GBR traffic
    ${nbOfUe_traffic_GBR}=   CB009836-Keywords.Get Number Of Ue Configured With GBR Traffic    dict_ues=${listOfUes}
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If    ${current_elem.DL_throughput_GBR} > ${0}    Run Keywords
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=2
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
        ...    AND
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=3
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
    END

    # Start the GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput_GBR} > ${0}    DL
        ...                                                                      NONE
        ${kw to run}=   Catenate    ${dir} Traffic GBR SA Not Stopped with "${current_elem.DL_throughput_GBR}"Mbps "${param.duration}"s duration
        ...                         and "${param.deviation}" percent deviation
        Run Keyword If      '${current_elem.DL_throughput_GBR}' != '0'
        ...    Critical Step   ${kw to run}    depends=CallSetup.Launch PDU Session
    END

    ${tti_trace_path}    ${tti_trace_dict}=    Omit when TtiTrace deactivated
    ...             Process TTI Traces    Kw_Convert_TtiTrace_From_csv_to_Dict=${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}   step=For_Test_Verdict

    # add here Specific Check based on TtiTraces
    run Keyword if     '${kw Specific Check Tti}'!='${EMPTY}'     Omit when TtiTrace deactivated
    ...          Step      ${kw Specific Check Tti}     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                 ttitracepath=${tti_trace_path}
    ...                                                 vendor_custom=${vendor_custom}
    ...                                                 depends=CallSetup.Launch PDU Session

    ${FilePkl}=           Omit when TtiTrace deactivated
    ...      Run keyword and continue on failure      Convert TTI Traces to Dataframe and store as pickle for UL Mimo
    ...                                                                                                     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                                                     ttitracepath=${tti_trace_path}

    ${L1L2_Pcap_File}=   Omit when L1L2BipTrace deactivated    Get L1L2 traces          time=${GetL1L2TraceTime}
    ...                                                                                 prefix=L1L2Bip.wDLTput
    ...                                                                                 msg=take BIP L1L2 traces with DL Tput
    # add here Specific Check based on L1l2Bip pcap
    run Keyword if     '${kw Specific Check}'!='${EMPTY}'     Omit when L1L2BipTrace deactivated
    ...          Step      ${kw Specific Check}     captureL1L2=${L1L2_Pcap_File}.pcap
    ...                    depends=CallSetup.Launch PDU Session

    run Keyword if   '${L1L2_Pcap_File}' != 'None'      Run Keywords     Dated log    gzip -f ${L1L2_Pcap_File}.pcap
    ...                                                         AND      Run    gzip -f ${L1L2_Pcap_File}.pcap

    # Generate Verdict...
    Omit when TtiTrace deactivated      Step      Generate Test Verdict    ${FilePkl}   ${vendor_custom}
    ...                                                                    ${dictExpectedValues}
    ...                                                                    ${kw Check SCF parameters}
    ...                                                                    verify_TTITraces_for_csirs_4cells
    ...                                                                    ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                    ttitracepath=${tti_trace_path}

    ${cntUes}=    Get length    ${rntiList}
    Step      CB009836-Ue-Commands.Verify Nbr Of ${cntUes}Ues ACTIVE

    # if  '${SKIP_COUNTERS}'=='False' => 'Display PDSCH and PUSCH ue_stats_nr for UEList' allow to Wait time until next PM file
    Run Keyword And Ignore Error     Display PDSCH and PUSCH ue_stats_nr for UEList   UEsList=${listOfUes}    file=${csv_file_tput_results}

    # Collect PM only if  '${SKIP_COUNTERS}'=='False'
    Omit when SKIP_COUNTERS present      robot_extension.Run Keyword And Warn On Failure
    ...                                           CB009836-Keywords.Collect PM Counters and process throughput using PM counters

    # to bypass UE Deregister if needed
    @{listOfUes}    run Keyword if    '${w_ue_detach}' == 'False'    Create List
    ${len}=   Get Length   ${listOfUes}
    run Keyword if    '${len}' != '${0}'    Step    Traced Sleep   duration=3s   msg=deregistering     depends=CallSetup.UE Register
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.target_cells} != ${nrCell}
        ...                 Step      CallSetup.UE Deregister       id=${current_elem.ue}
        ###...                                                      ue_deregister_type=switch_off
        ###...                                                      by=ue
        ...                                                         depends=CallSetup.UE Register
    END

    Log to console   ===================================== STEP 2 =====================================

    Run Keyword If    '${kw Active Config}'!='${EMPTY}'
    ...            09_CB009836_A01_01_BW_100_80_60_100_5GC001116_3_Canada_4ssb_80sl_ASOE    w_getSCF=${w_getSCF}
    # update local scf.xml
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}

    Dev_lib.start_to_capture_infomodel_log
    Run Keyword If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   CB009836-Keywords.Cell 1 cell 2 cell3 and cell4 Should Be Onair
    ...    ELSE                                                             All Cells Should Be Onair
    Dev_lib.stop_to_capture_infomodel_log

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure       Admin Validate SCF     scf_path_file=${test_scf_file}

    # Register and launch PDU for all the ue's except for which define on the deleted cell
    FOR    ${current_elem}    IN    @{listOfUes}
        # Run Keyword If      ${current_elem.target_cells} != ${nrCell}    Run Keywords
        Run Keywords
        ...                 Critical Step       CallSetup UE register UeId "${current_elem.ue}" on Target cell "${current_elem.target_cells}"
        ...                                     depends=CallSetup.Setup Wtsemu SA
        ...    AND
        ...                 Critical Step     CallSetup.Launch PDU Session
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         gw=${current_elem.ue}
        ###...                                                      nwslice=1
        ...                                   depends=CallSetup UE register UeId
    END

    Run Keyword If    '${kw Specific Set TestMode After Attach}'!='${EMPTY}'
    ...                                                   Step   Run specific keywords after attach : ${kw Specific Set TestMode After Attach}

    ${rntiList}=    create list
    FOR    ${current_elem}    IN    @{listOfUes}
        ${UeId}      CB009836-Ue-Commands.Get Crnti From Egate Log     ue_id=${current_elem.ue}
        Dated log       ======> Rnti[UeId=${current_elem.ue}] is ${UeId}
        Append To List                ${rntiList}                  ${UeId}
    END
    Set Test Variable     ${rntiList}

    [Teardown]   Teardow Kw

postProcess TtiTrace
    [Arguments]             ${ttitraceFilename}=ttitrace_streaming.pcap    ${ttitracepath}=${EMPTY}
    ...                     ${Kw_Convert_TtiTrace_From_csv_to_Dict}=Convert TTI trace from csv to dict CB009836
    ${TTIcsv}  ${UL_TTIcsv}   Run keyword and continue on failure         Convert TTI trace from pcap to excelCsv CB009836
    ...                                                           ttitraceFilename=${ttitraceFilename}   ttitracepath=${ttitracepath}
    ${file_exists}=  Run Keyword and Return Status    File Should Exist    ${TTIcsv}
    ${CsvFilename}      Remove String      ${ttitraceFilename}     .pcap
    ${ttiLog}  set variable if   not(${file_exists})    ${ttitracepath}/${CsvFilename}.dl.csv
    ...   ${TTIcsv}
    dated log   ttiLog is ${ttiLog}
    set test Variable     ${ttiLog}
    # ${TTIcsv} is used by "Check cellcsirs Assignement" Kw
    set test Variable     ${TTIcsv}
    Run Keywords       dated log    Tti csv file converted using TtiTraceDecoder.py legacyCsv ${TTIcsv}
    ...      AND       dated log    Tti csv file converted using TtiTraceDecoder.py legacyCsv ${UL_TTIcsv}
    Set Log Level    NONE
    ${tti_trace_dict_dl}=      Run keyword and continue on failure   ${Kw_Convert_TtiTrace_From_csv_to_Dict}    TTITraceCsv=${TTIcsv}
    ...                                                                                                 num_of_events=${GetTtiTraceNumOfEvent}
    ${tti_trace_dict_ul}=   Run keyword and continue on failure   Convert TTI trace from csv to dict CB007713    TTITraceCsv=${UL_TTIcsv}
    ...                                                                                                 num_of_events=${GetTtiTraceNumOfEvent}
    Set Log Level    TRACE
    robot_extension.Run Keyword And Warn On Failure      Check PRB Assignment CB008940        ${tti_trace_dict_dl}
    robot_extension.Run Keyword And Warn On Failure      Check UL PRB Assignment CB007113     ${tti_trace_dict_ul}
    [return]    ${tti_trace_dict_dl}

Get TtiTrace and L1L2Bip
    [Arguments]     ${step}=${EMPTY}    ${duration}=1s    ${Kw_Convert_TtiTrace_From_csv_to_Dict}=Convert TTI trace from csv to dict CB009836
    ${if_TtiTrace_not_skip}=     Evaluate     '${w_GetTtiTrace}' == 'True' and '${duration}' != '0'
    ${if_l1l2Bip_not_skip}=      Evaluate     '${w_GetL1L2Bip}' == 'True' and '${duration}' != '0'
    Captures CB009836 Init   prefix=${step}
    Captures CB009836 Start  actionCORE=${False}
    ...                      actionCPRT=${False}
    ...                      actionL1L2=${if_l1l2Bip_not_skip}
    ...                      actionTti=${if_TtiTrace_not_skip}
    Traced Sleep   duration=${duration}   msg=${step}
    ${ret_tti}   ${tti_trace_path}     Omit when TtiTrace deactivated    Run Keyword And Ignore Error    Stop and Get TTI traces    suffix=${step}
    CB009836-Keywords.Captures Stop         actionCORE=${False}
    ...                                     actionCPRT=${False}
    ...                                     actionL1L2=${if_l1l2Bip_not_skip}
    set Test Variable       ${sw_generic_capture_started}     ${False}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CaptureCPRT.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${CaptureCPRT.path}    ${testCaseDir}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CaptureCORE.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${CaptureCORE.path}    ${testCaseDir}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CaptureL1L2.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${CaptureL1L2.path}    ${testCaseDir}
    Run Keyword If    ${if_l1l2Bip_not_skip}    declare Trace in Trace List  Type=L1L2Bip   Savedir=${testCaseDir}
    ...                          file_name=${CaptureL1L2.name}.pcap   Trigger=${step}
    Run Keyword If       '${ret_tti}' == 'FAIL'    BuiltIn.Log    Failed to get TTI traces !!!!   level=ERROR
    Should Not be True   '${ret_tti}' == 'FAIL'
    Run Keyword If    ${if_TtiTrace_not_skip}   declare Trace in Trace List  Type=TtiTrace   Savedir=${tti_trace_path}
    ...                          file_name=ttitrace_streaming.pcap    Trigger=${step}
    Omit when TtiTrace deactivated    postProcess TtiTrace
    ...                                     ttitraceFilename=ttitrace_streaming.pcap    ttitracepath=${tti_trace_path}
    ...                                     Kw_Convert_TtiTrace_From_csv_to_Dict=${Kw_Convert_TtiTrace_From_csv_to_Dict}
    [return]   ${tti_trace_path}    ${testCaseDir}/${CaptureL1L2.name}

TC CB009836 4 Cells For Precheck3
    [Documentation]
    ...     test template for CB009836 (Topology to used should be CLOUD_5G_O_E_AP_LOO_8DL8UL)
    ...     Conditions:     it is based on the arguments ${param}  ${dictParam}  ${vendor_custom} ${dict_ues} ${nrCell}
    ...     Actions:        it performs the call setup for multi-ues on different cells with DL traffic
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Arguments]             ${param}
    ...                     ${dictParam}
    ...                     ${vendor_custom}
    ...                     ${dict_ues}
    ...                     ${nrCell}
    ...                     ${Kw TestLine Preparation}=${EMPTY}
    ...                     ${kw Set RAD Params}=${EMPTY}
    ...                     ${kw NIDD Set}=${EMPTY}
    ...                     ${kw NIDD Check}=${EMPTY}
    ...                     ${kw Set TestMode}=${EMPTY}
    ...                     ${kw Active Config}=${EMPTY}
    ...                     ${kw Specific Set TestMode Before Attach}=${EMPTY}
    ...                     ${kw Specific Set TestMode After Attach}=${EMPTY}
    ...                     ${NIDD_9836_PARAMS}=${NIDD_9836_Q_L_PARAMS}
    ...                     ${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}=Convert TTI trace from csv to dict CB009836
    ...                     ${kw Check SCF parameters}=${EMPTY}
    ...                     ${kw Specific Check Tti}=${EMPTY}
    ...                     ${kw Specific Check}=${EMPTY}
    ...                     ${kw Specific Check CPRT}=${EMPTY}
    ...                     ${Kw Update NIDD Test Parameters}=${EMPTY}
    ...                     ${NIDD_9836_TEST_PARAMS}=${EMPTY}
    ...                     ${Json test configuration}=${EMPTY}
    ...                     ${FrameStructure}=5GC001208
    ...                     ${TypeCheck}=allCellsSameSSB

    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    ${topoOK}=      Evaluate     ${topoOK_1} or ${topoOK_2}
    ${msg_err}=     Catenate    topology USED [${topoUsed}] is not CORRECT for this test [${TEST NAME}].
    Run Keyword If            '${topoOK}'=='False'   dated log   ${consTraceColorBgRed}${consTraceColorYellow}${msg_err}${defColor} Plz, Check it...
    Return From Keyword If    '${topoOK}'=='False'
    Init Sequence           ${param}
    Create Header Csv Tput Test result
    ${ull1spcells_syslog}=    Create List
    ${dll1spcells_syslog}=    Create List
    set test variable     ${ull1spcells_syslog}
    set test variable     ${dll1spcells_syslog}
    Run Keyword If    '${Json test configuration}'!='${EMPTY}'    load Json test data   ${Json test configuration}   ${dict_ues}
    ...                                                                                 ${vendor_custom}   ${param}
    StringTool.printLineWithTitle     title=Display NIDD PARAMETERS of the Test TO SET
    FOR    ${item}    IN    @{NIDD_9836_PARAMS}
         continue for loop if     'list_name' in ${item}
         ${msg_display}=    StringTool.getHeaderLine    ${item}[dist_name]/${item}[pname]     ${item}[value]
         dated log      ${msg_display}
         # dated log    dist_name=${item}[dist_name] pname=${item}[pname] value=${item}[value]
    END
    StringTool.printLineWithTitle     title=-
    Step         Init CB009836 Test Variables    vendor_custom=${vendor_custom}    dict_ues=${dict_ues}    totalNbOfUe=${param.totalNbOfUe}
    Run Keyword If    '${kw Set RAD Params}'!='${EMPTY}'     Step         Run Keyword     ${kw Set RAD Params}
    # return from Keyword

    # ${iphy_file_4Cells} is dedicated to topo ASOE with 4 Cells
    # ${iphy_file_8Cells} is dedicated to topo ASOE with 8 Cells
    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    dated log     Topology is ${topoUsed}
    ${iphy_file_to_use}    Set Variable If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   ${iphy_file_8Cells}
    ...                                                                                             ${iphy_file_4Cells}
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_to_use}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_to_use}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [/tmp/${iphy_filename}] to AirPhone

    # Apply delta commissioning (WITH_APPLY_DELTA_COMMISSIONING=1) if requested
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1' and '${UPDATE_SCF}'=='1' and '${Kw TestLine Preparation}'!='${EMPTY}'
    ...                          Run Keywords       ${Kw TestLine Preparation}      output_scf=${test_scf_file}
    ...                              AND            Set Suite Variable              ${test_scf_file}
    # return from Keyword

    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...                                                Set CB009836 NIDD PARAMETERS VERSION 3 with SET into SCF     list=${NIDD_9836_PARAMS}
    # return from Keyword

    # Set NIDD PARAM If Needed / Kw use ${test_scf_file} file
    Run Keyword If    '${kw NIDD Set}'!='${EMPTY}' and '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'     ${kw NIDD Set}   list=${NIDD_9836_PARAMS}

    # Check if NIDD PARAM are as expected
    Run Keyword If    '${kw NIDD Check}'!='${EMPTY}'      ${kw NIDD Check}  list=${NIDD_9836_PARAMS}

    ${w_getSCF}=    Set Variable If     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'   true
    ...                                                                              false
    Run Keyword If    '${kw Active Config}'!='${EMPTY}'      ${kw Active Config}    w_getSCF=${w_getSCF}
    ...    ELSE                                              CB009836-A-Config-tests-Keywords.Log config in result file

    # update local scf.xml
    ${test_scf_file}      Run Keyword If    '${kw Active Config}'!='${EMPTY}'  COAM Get SCF    file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ...                      ELSE                                              set Variable    ${test_scf_file}
    set suite variable     ${test_scf_file}

    # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure       Admin Validate SCF     scf_path_file=${test_scf_file}
    robot_extension.Run Keyword And Warn On Failure       Get Cipher and Integrity Parameters From SCF

    # iPHY gscn update depending of chBwDl
    # get gscn for CELL1 from SCF
    ${gscn_cell1}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell1} for CELL1
    Step           CB009836-Keywords.Set Context_AP IPHY gscn Cell1 with ${gscn_cell1}

    ${gscn_cell2}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell2} for CELL2
    Step           CB009836-Keywords.Set Context_AP IPHY gscn Cell2 with ${gscn_cell2}

    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    ${cond1}=          Evaluate     '${bts_status.lower()}'=='configured' or '${bts_status.lower()}'=='onair'
    ${condResetTL}=    Evaluate     '${ret.lower()}'=='pass' and not ${cond1}
    dated log     condResetTL=${condResetTL}
    Run Keyword If     ${condResetTL}    Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured/OnAir [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}

    ${test_scf_file}             COAM Get SCF        local_dir_path=${LOG_PATH}      file=SCF.xml   alias=coam_gnb
    Set Suite Variable           ${test_scf_file}

    ${actTddCsirsAllocOptimization}   set variable     ${act9836TddCsirsAllocOptimization}
    @{PARAMS_IN_VENDOR}    Create List     actTddCsirsAllocOptimization=${actTddCsirsAllocOptimization}
    set test variable     ${PARAMS_IN_VENDOR}
    ${cond1}=          Evaluate     '${bts_status.lower()}'!='configured' or '${bts_status.lower()}'!='onair'
    ${condResetTL}=    Evaluate     '${ret.lower()}'=='pass' and ${cond1}
    dated log     condResetTL=${condResetTL}
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...         Critical Step    CB009836-TL-Preparation-Keywords.Deploy Vendor File to activate CB009836     PARAMS_IN_VENDOR=${PARAMS_IN_VENDOR}
    ...                                                                                                       is_perform_full_commissioning=${True}
    ...   ELSE
    ...          Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'
   ...             Run Keywords    Dated Log new line       ${consTraceColorRed}BEWARE that Deploy Vendor File Config is already DONE!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=4min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter
    # return from Keyword

    Run keyword and continue on failure     Verify actTddCsirsAllocOptimization status    status=${actTddCsirsAllocOptimization}

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER Commissioning / TL Restart${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs
    robot_extension.Run Keyword And Warn On Failure         Extract l2::ps::cnfg::AddressDistributionReq_t from Syslog
    robot_extension.Run Keyword And Warn On Failure         Display PRB POOLING NIDD param
    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    # save some test parameters as vendor file or Ue settings into ${testCaseDir}
    nps_9836_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${vendor_custom}    filename=data_test.json

    # Configure the current setting for all the ue's
    ${param.totalNbOfUe}    get length          ${dict_ues}
    Step                    Configure the setting for the ${param.totalNbOfUe} UEs
    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${param.totalNbOfUe}
        ${current_ue}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        Set To Dictionary             ${current_ueSetting}          trf_id              1
        Set To Dictionary             ${current_ueSetting}          target_gnb          ${param.targetGnb}
        Set To Dictionary             ${current_ueSetting}          size                ${dict_ues[${current_id}].packet_size}

        # Dispatching each ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ueSetting}          DL_throughput          ${dict_ues[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          UL_throughput          ${dict_ues[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}          protocol               ${dict_ues[${current_id}].protocol}

        Append To List                ${listOfUes}                  ${current_ueSetting}

        # save some test parameters as vendor file or Ue settings into ${testCaseDir}
        add_dictionary_to_json       ${testCaseDir}     'Ue_${current_ue}'   ${current_ueSetting}    data_test.json
    END
    # Dated Log New Line                UE_List=${listOfUes}
    display_list_parameters_w_name      ${listOfUes}   name=Ue   msg=Display Of listOfUes
    CB009836-Keywords.Check Multi Ues Setting In List        multiUesList=${listOfUes}

    set test Variable     ${listOfUes}
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Init   prefix=CellSetup.Attach.SA
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start  actionCORE=${isCaptureCORE}
    ...                                                                                        actionCPRT=${isCaptureCPRT}
    ...                                                                                        actionL1L2=${isCaptureL1L2}
    ...                                                                                        actionTti=${False}

    # ${kw Set TestMode} is a robot Kw that allow to modify cfg file
    Run Keyword If    '${kw Set TestMode}'!='${EMPTY}'       ${kw Set TestMode}

    Setup devices aliases
    robot_extension.Run Keyword And Warn On Failure    Enable internal mirroring for alias    gNB2

    Run Keyword If    '${Kw Update NIDD Test Parameters}'!='${EMPTY}'      Step      Run Keyword    ${Kw Update NIDD Test Parameters}

    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    ${LuaFileToUsed}=      Run Keyword If    '${W_CUSTOM_LUA_FILE_TO_USED}'=='1'       Install lua File into WTS    ${LuaFileToUsed_path}
    ...                        ELSE                                                    Set Variable                 ${EMPTY}

    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog2_beforeCellSetup
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    run Keyword If    '${ret}' == 'FAIL'     BuiltIn.log    btslog.Stop Btslog is ${ret}! with ${syslogpath}     level=ERROR     console=True
    ${fileExists}=     nps_9836_tools.file_exists   ${syslogpath}
    ${ret}    ${syslog_filename}   Run Keyword If   ${fileExists}==${True}
    ...                                           Run Keyword And Ignore Error    nps_9836_tools.return_basename   ${syslogpath}
    ...                              ELSE         ObtainVariablesKeyword
    robot_extension.Run Keyword And Warn On Failure   declare Trace in Trace List    Type=SysLog  Savedir=${dir_syslog}
    ...                          file_name=${syslog_filename}   Trigger=btslog2_beforeCellSetup
    robot_extension.Run Keyword And Warn On Failure   Check UL and DL l1Subpool Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}
    ...         Critical Step           Basic Call to Setup Wtsemu SA           nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${True}
    ...                                                             LuaFileToUsed=${LuaFileToUsed}
    # ...                                                             Kw_TM=${kw Set TestMode}
    ...   ELSE
    ...         Critical Step           CallSetup.Setup Wtsemu SA               nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${False}
    Dev_lib.wait_ng_link_up
    Dev_lib.start_to_capture_infomodel_log
    Run Keyword If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   CB009836-Keywords.Cell 1 cell 2 cell3 and cell4 Should Be Onair
    ...    ELSE                                                             All Cells Should Be Onair
    Dev_lib.stop_to_capture_infomodel_log

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    # test all cells mapped on same L1 Pool
    ${isFileNameDLCellMappingPresent}    Run Keyword And Return Status    Should Not Be Empty   ${FileNameDLCellMapping}
    ${fileExists}=     nps_9836_tools.file_exists   ${FileNameDLCellMapping}
    Run Keyword If   '${isFileNameDLCellMappingPresent}' == 'False' or not ${fileExists}
    ...                BuiltIn.Log    DL Cell mapping file not present (from Syslog), please check the config...    level=WARN    console=yes
    ...    ELSE        check Dl Cell mapping from Syslog ${FileNameDLCellMapping}

    ${ret}  ${output}=    robot_extension.Run Keyword And Warn On Failure
    ...                                        Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog     NbrCells=4
    ${sorted_csirsGroups}            Set Variable     ${output[0]}
    ${sorted_cellcsirs_slotoffset}   Set Variable     ${output[1]}
    ${sorted_uecsirs_slotoffset}     Set Variable     ${output[2]}
    ${sorted_trscsirs_slotoffset}    Set Variable     ${output[3]}
    ${sorted_trscsirs_ssb_slotoffset}    Set Variable     ${output[4]}
    Dated Log New Line    sorted_csirsGroups=${sorted_csirsGroups}
    Dated Log New Line    sorted_cellcsirs_slotoffset=${sorted_cellcsirs_slotoffset}
    Dated Log New Line    sorted_trscsirs_slotoffset=${sorted_trscsirs_slotoffset}
    Dated Log New Line    sorted_trscsirs_ssb_slotoffset=${sorted_trscsirs_ssb_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}

    # check that we have all relation cell and csrirspool for all cells
    ${cell_csirsGroups}=  Get length   ${sorted_csirsGroups}
    Dated log    length of cell_csirsGroups = ${sorted_csirsGroups}
    ${List_nrCellIdentity}   Create List     16385    16386    16387    16388
    ${cell_missing_list}=    check_all_cell_csirspool_present      ${output[0]}    ${List_nrCellIdentity}
    ${NbrCellNoFound}=       Get length   ${cell_missing_list}
    Dated log    Nb of cell csirsGroups relation not found = ${NbrCellNoFound} with cell_missing_list=${cell_missing_list}
    Run Keyword If     '${NbrCellNoFound}' != '0'       Try Lock and Unlock cells    ${cell_missing_list}
    ${sorted_csirsGroups}=   Run Keyword If    '${NbrCellNoFound}' == '4'     Create List
    ...                          ELSE                                         Copy List    ${sorted_csirsGroups}
    ${sorted_cellcsirs_slotoffset}=   Run Keyword If    '${NbrCellNoFound}' == '4'     Create List
    ...                                  ELSE                                          Copy List    ${sorted_cellcsirs_slotoffset}
    ${sorted_trscsirs_slotoffset}=   Run Keyword If    '${NbrCellNoFound}' == '4'     Create List
    ...                                  ELSE                                         Copy List    ${sorted_trscsirs_slotoffset}
    ${sorted_trscsirs_ssb_slotoffset}=   Run Keyword If    '${NbrCellNoFound}' == '4'     Create List
    ...                                      ELSE                                         Copy List    ${sorted_trscsirs_ssb_slotoffset}
    Set test Variable     ${sorted_csirsGroups}
    Set Test Variable     ${sorted_cellcsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_slotoffset}
    Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}
    Run Keyword If     '${NbrCellNoFound}' != '0'       Update csirsGroups and cellcsirs
    # ${sorted_csirsGroups} is used by 'Check cellcsirs Assignement' Kw but also used by 'verify_TTITraces_for_csirs' Kw
    ${cellcsirs_slotoffset_present}   evaluate   len(${sorted_cellcsirs_slotoffset}) != ${0}
    run Keyword If    ${cellcsirs_slotoffset_present}
    ...            Run keyword and continue on failure     Check cellcsirs Assignement  ${sorted_cellcsirs_slotoffset}   ${FrameStructure}
    ...     ELSE   declare Results in Test Results List    Type=SYSLOG : Check Cell Specific CSI-RS allocation
    ...                                                    Result=WARN no cellcsirs_slotoffset_present
    # 08/20/2025 : Trs check is bypassed, only CsiRs position is checked
    # this is due to Introduction of new logging macro for too long strings in syslog
    # (see https://gerrit.ext.net.nokia.com/gerrit/c/MN/5G/NB/gnb/+/8938794/ ) => cellGroupSetupReq print have been changed in syslog!!!
    # Run Keyword If    '${TypeCheck}' == 'allCellsSameSSB'
    # ...   Run keyword and continue on failure     Check TrsCsiRs Assignement     ${sorted_trscsirs_slotoffset}    ${FrameStructure}
    # ...    ELSE
    # ...   Run keyword and continue on failure     Check TrsCsiRs Assignement For 4 Cells  ${sorted_trscsirs_ssb_slotoffset}   ${sorted_csirsGroups}
    # ...                                                                                   ${FrameStructure}
    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Check cellmappingtocsirspoolinggroup Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    ${num_of_cells}=    Get Cell Number
    @{cell_to_bypass}=  Create List    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-4
    Critical Step       Wait gNB cells 5g On air    ${num_of_cells}    cell_to_bypass=${cell_to_bypass}

    ${ret}   ${dll1spcells}    robot_extension.Run Keyword And Warn On Failure         Get dlsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    ${ret}   ${ull1spcells}    robot_extension.Run Keyword And Warn On Failure         Get ulsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    Set Suite Variable      ${dll1spcells}
    Set Suite Variable      ${ull1spcells}
    dated log   dlsubcellSpool0List=${dll1spcells[0]}
    dated log   dlsubcellSpool1List=${dll1spcells[1]}
    dated log   ulsubcellSpool0List=${ull1spcells[0]}
    dated log   ulsubcellSpool1List=${ull1spcells[1]}
    set test variable    ${dll1spcells[0]}
    set test variable    ${dll1spcells[1]}
    set test variable    ${ull1spcells[0]}
    set test variable    ${ull1spcells[1]}
    robot_extension.Run Keyword And Warn On Failure     update bbpoolInfo Dll1Subpool and Ull1Subpool Assignment

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${False}   Step                      CallSetup.WTS Set X2 Link

    Run Keyword If      '${kw Specific Set TestMode Before Attach}'!='${EMPTY}'
    ...                                                    Step   Run specific keywords before attach : ${kw Specific Set TestMode Before Attach}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start    actionTti=${isCaptureTti}

    # Register and launch PDU for all the ue's except for which define on the deleted cell
    FOR    ${current_elem}    IN    @{listOfUes}
        # Run Keyword If      ${current_elem.target_cells} != ${nrCell}    Run Keywords
        Run Keywords
        ...                 Critical Step       CallSetup UE register UeId "${current_elem.ue}" on Target cell "${current_elem.target_cells}"
        ...                                     depends=CallSetup.Setup Wtsemu SA
        ...    AND
        ...                 Critical Step     CallSetup.Launch PDU Session
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         gw=${current_elem.ue}
        ###...                                                      nwslice=1
        ...                                   depends=CallSetup UE register UeId
    END

    Run Keyword If    '${kw Specific Set TestMode After Attach}'!='${EMPTY}'
    ...                                                   Step   Run specific keywords after attach : ${kw Specific Set TestMode After Attach}

    ${rntiList}=    create list
    FOR    ${current_elem}    IN    @{listOfUes}
        ${UeId}      CB009836-Ue-Commands.Get Crnti From Egate Log     ue_id=${current_elem.ue}
        Dated log       ======> Rnti[UeId=${current_elem.ue}] is ${UeId}
        Append To List                ${rntiList}                  ${UeId}
    END
    Set Test Variable     ${rntiList}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step        Captures CB009836 Stop

    # Start the non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput} > ${0}    DL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.DL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.DL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session

        ${dir}=   set Variable If    ${current_elem.UL_throughput} > ${0}    UL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.UL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.UL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session
    END

    # PDU session modify reserved for the ue's configured with GBR traffic
    ${nbOfUe_traffic_GBR}=   CB009836-Keywords.Get Number Of Ue Configured With GBR Traffic    dict_ues=${listOfUes}
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If    ${current_elem.DL_throughput_GBR} > ${0}    Run Keywords
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=2
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
        ...    AND
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=3
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
    END

    # Start the GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput_GBR} > ${0}    DL
        ...                                                                      NONE
        ${kw to run}=   Catenate    ${dir} Traffic GBR SA Not Stopped with "${current_elem.DL_throughput_GBR}"Mbps "${param.duration}"s duration
        ...                         and "${param.deviation}" percent deviation
        Run Keyword If      '${current_elem.DL_throughput_GBR}' != '0'
        ...    Critical Step   ${kw to run}    depends=CallSetup.Launch PDU Session
    END

    ${tti_trace_path}    ${L1L2_Pcap_File}=    Get TtiTrace and L1L2Bip     step=For_Test_Verdict   duration=${GetTtiTraceTime}
    ...                                                   Kw_Convert_TtiTrace_From_csv_to_Dict=${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}

    # add here Specific Check based on TtiTraces
    run Keyword if     '${kw Specific Check Tti}'!='${EMPTY}'     Omit when TtiTrace deactivated
    ...          Step      ${kw Specific Check Tti}     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                 ttitracepath=${tti_trace_path}
    ...                                                 vendor_custom=${vendor_custom}
    ...                                                 depends=CallSetup.Launch PDU Session

    ${FilePkl}=           Omit when TtiTrace deactivated
    ...      Run keyword and continue on failure      Convert TTI Traces to Dataframe and store as pickle for UL Mimo
    ...                                                                                                     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                                                     ttitracepath=${tti_trace_path}

    # add here Specific Check based on L1l2Bip pcap
    run Keyword if     '${kw Specific Check}'!='${EMPTY}'     Omit when L1L2BipTrace deactivated
    ...          Step      ${kw Specific Check}     captureL1L2=${L1L2_Pcap_File}.pcap
    ...                    depends=CallSetup.Launch PDU Session

    run Keyword if   '${L1L2_Pcap_File}' != 'None'      Run Keywords     Dated log    gzip -f ${L1L2_Pcap_File}.pcap
    ...                                                         AND      Run    gzip -f ${L1L2_Pcap_File}.pcap

    # Generate Verdict...
    Omit when TtiTrace deactivated      Step      Generate Test Verdict    ${FilePkl}   ${vendor_custom}
    ...                                                                    ${dictExpectedValues}
    ...                                                                    ${kw Check SCF parameters}
    ...                                                                    verify_TTITraces_for_csirs_4cells
    ...                                                                    ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                    ttitracepath=${tti_trace_path}

    ${cntUes}=    Get length    ${rntiList}
    Step      CB009836-Ue-Commands.Verify Nbr Of ${cntUes}Ues ACTIVE

    # if  '${SKIP_COUNTERS}'=='False' => 'Display PDSCH and PUSCH ue_stats_nr for UEList' allow to Wait time until next PM file
    Run Keyword And Ignore Error     Display PDSCH and PUSCH ue_stats_nr for UEList   UEsList=${listOfUes}    file=${csv_file_tput_results}

    # Collect PM only if  '${SKIP_COUNTERS}'=='False'
    Omit when SKIP_COUNTERS present      robot_extension.Run Keyword And Warn On Failure
    ...                                           CB009836-Keywords.Collect PM Counters and process throughput using PM counters

    # to bypass UE Deregister if needed
    @{listOfUes}    run Keyword if    '${w_ue_detach}' == 'False'    Create List
    ${len}=   Get Length   ${listOfUes}
    run Keyword if    '${len}' != '${0}'    Step    Traced Sleep   duration=3s   msg=deregistering     depends=CallSetup.UE Register
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.target_cells} != ${nrCell}
        ...                 Step      CallSetup.UE Deregister       id=${current_elem.ue}
        ###...                                                      ue_deregister_type=switch_off
        ###...                                                      by=ue
        ...                                                         depends=CallSetup.UE Register
    END
    [Teardown]   Teardow Kw

TC CB009836 4 Cells For Precheck3 Light
    [Documentation]
    ...     test template for CB009836 (Topology to used should be CLOUD_5G_O_E_AP_LOO_8DL8UL)
    ...     Conditions:     it is based on the arguments ${param}  ${dictParam}  ${vendor_custom} ${dict_ues} ${nrCell}
    ...     Actions:        it performs the call setup for multi-ues on different cells with DL traffic
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Arguments]             ${param}
    ...                     ${dictParam}
    ...                     ${vendor_custom}
    ...                     ${dict_ues}
    ...                     ${nrCell}
    ...                     ${Kw TestLine Preparation}=${EMPTY}
    ...                     ${kw Set RAD Params}=${EMPTY}
    ...                     ${kw NIDD Set}=${EMPTY}
    ...                     ${kw NIDD Check}=${EMPTY}
    ...                     ${kw Set TestMode}=${EMPTY}
    ...                     ${kw Active Config}=${EMPTY}
    ...                     ${kw Specific Set TestMode Before Attach}=${EMPTY}
    ...                     ${kw Specific Set TestMode After Attach}=${EMPTY}
    ...                     ${NIDD_9836_PARAMS}=${NIDD_9836_Q_L_PARAMS}
    ...                     ${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}=Convert TTI trace from csv to dict CB009836
    ...                     ${kw Check SCF parameters}=${EMPTY}
    ...                     ${kw Specific Check Tti}=${EMPTY}
    ...                     ${kw Specific Check}=${EMPTY}
    ...                     ${kw Specific Check CPRT}=${EMPTY}
    ...                     ${Kw Update NIDD Test Parameters}=${EMPTY}
    ...                     ${NIDD_9836_TEST_PARAMS}=${EMPTY}
    ...                     ${Json test configuration}=${EMPTY}
    ...                     ${FrameStructure}=5GC001208
    ...                     ${TypeCheck}=allCellsSameSSB

    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    ${topoOK}=      Evaluate     ${topoOK_1} or ${topoOK_2}
    ${msg_err}=     Catenate    topology USED [${topoUsed}] is not CORRECT for this test [${TEST NAME}].
    Run Keyword If            '${topoOK}'=='False'   dated log   ${consTraceColorBgRed}${consTraceColorYellow}${msg_err}${defColor} Plz, Check it...
    Return From Keyword If    '${topoOK}'=='False'
    Init Sequence           ${param}
    Create Header Csv Tput Test result
    ${ull1spcells_syslog}=    Create List
    ${dll1spcells_syslog}=    Create List
    set test variable     ${ull1spcells_syslog}
    set test variable     ${dll1spcells_syslog}
    Run Keyword If    '${Json test configuration}'!='${EMPTY}'    load Json test data   ${Json test configuration}   ${dict_ues}
    ...                                                                                 ${vendor_custom}   ${param}
    StringTool.printLineWithTitle     title=Display NIDD PARAMETERS of the Test TO SET
    FOR    ${item}    IN    @{NIDD_9836_PARAMS}
         continue for loop if     'list_name' in ${item}
         ${msg_display}=    StringTool.getHeaderLine    ${item}[dist_name]/${item}[pname]     ${item}[value]
         dated log      ${msg_display}
         # dated log    dist_name=${item}[dist_name] pname=${item}[pname] value=${item}[value]
    END
    StringTool.printLineWithTitle     title=-
    Step         Init CB009836 Test Variables    vendor_custom=${vendor_custom}    dict_ues=${dict_ues}    totalNbOfUe=${param.totalNbOfUe}
    Run Keyword If    '${kw Set RAD Params}'!='${EMPTY}'     Step         Run Keyword     ${kw Set RAD Params}
    # return from Keyword

    # ${iphy_file_4Cells} is dedicated to topo ASOE with 4 Cells
    # ${iphy_file_8Cells} is dedicated to topo ASOE with 8 Cells
    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    dated log     Topology is ${topoUsed}
    ${iphy_file_to_use}    Set Variable If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   ${iphy_file_8Cells}
    ...                                                                                             ${iphy_file_4Cells}
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_to_use}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_to_use}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [/tmp/${iphy_filename}] to AirPhone

    # Apply delta commissioning (WITH_APPLY_DELTA_COMMISSIONING=1) if requested
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1' and '${UPDATE_SCF}'=='1' and '${Kw TestLine Preparation}'!='${EMPTY}'
    ...                          Run Keywords       ${Kw TestLine Preparation}      output_scf=${test_scf_file}
    ...                              AND            Set Suite Variable              ${test_scf_file}
    # return from Keyword

    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...                                                Set CB009836 NIDD PARAMETERS VERSION 3 with SET into SCF     list=${NIDD_9836_PARAMS}
    # return from Keyword

    # Set NIDD PARAM If Needed / Kw use ${test_scf_file} file
    Run Keyword If    '${kw NIDD Set}'!='${EMPTY}' and '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'     ${kw NIDD Set}   list=${NIDD_9836_PARAMS}

    # Check if NIDD PARAM are as expected
    Run Keyword If    '${kw NIDD Check}'!='${EMPTY}'      ${kw NIDD Check}  list=${NIDD_9836_PARAMS}

    ${w_getSCF}=    Set Variable If     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'   true
    ...                                                                              false
    Run Keyword If    '${kw Active Config}'!='${EMPTY}'      ${kw Active Config}    w_getSCF=${w_getSCF}
    ...    ELSE                                              CB009836-A-Config-tests-Keywords.Log config in result file

    # update local scf.xml
    ${test_scf_file}      Run Keyword If    '${kw Active Config}'!='${EMPTY}'  COAM Get SCF    file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ...                      ELSE                                              set Variable    ${test_scf_file}
    set suite variable     ${test_scf_file}

    # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure       Admin Validate SCF     scf_path_file=${test_scf_file}
    robot_extension.Run Keyword And Warn On Failure       Get Cipher and Integrity Parameters From SCF

    # iPHY gscn update depending of chBwDl
    # get gscn for CELL1 from SCF
    ${gscn_cell1}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell1} for CELL1
    Step           CB009836-Keywords.Set Context_AP IPHY gscn Cell1 with ${gscn_cell1}

    ${gscn_cell2}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell2} for CELL2
    Step           CB009836-Keywords.Set Context_AP IPHY gscn Cell2 with ${gscn_cell2}

    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    ${cond1}=          Evaluate     '${bts_status.lower()}'=='configured' or '${bts_status.lower()}'=='onair'
    ${condResetTL}=    Evaluate     '${ret.lower()}'=='pass' and not ${cond1}
    dated log     condResetTL=${condResetTL}
    Run Keyword If     ${condResetTL}    Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured/OnAir [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}

    ${test_scf_file}             COAM Get SCF        local_dir_path=${LOG_PATH}      file=SCF.xml   alias=coam_gnb
    Set Suite Variable           ${test_scf_file}

    ${actTddCsirsAllocOptimization}   set variable     ${act9836TddCsirsAllocOptimization}
    @{PARAMS_IN_VENDOR}    Create List     actTddCsirsAllocOptimization=${actTddCsirsAllocOptimization}
    set test variable     ${PARAMS_IN_VENDOR}
    ${cond1}=          Evaluate     '${bts_status.lower()}'!='configured' or '${bts_status.lower()}'!='onair'
    ${condResetTL}=    Evaluate     '${ret.lower()}'=='pass' and ${cond1}
    dated log     condResetTL=${condResetTL}
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...         Critical Step    CB009836-TL-Preparation-Keywords.Deploy Vendor File to activate CB009836     PARAMS_IN_VENDOR=${PARAMS_IN_VENDOR}
    ...                                                                                                       is_perform_full_commissioning=${True}
    ...   ELSE
    ...          Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'
   ...             Run Keywords    Dated Log new line       ${consTraceColorRed}BEWARE that Deploy Vendor File Config is already DONE!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=4min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter
    # return from Keyword

    Run keyword and continue on failure     Verify actTddCsirsAllocOptimization status    status=${actTddCsirsAllocOptimization}

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB009836-Keywords.Set Reset Loop Counter

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER Commissioning / TL Restart${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs
    robot_extension.Run Keyword And Warn On Failure         Extract l2::ps::cnfg::AddressDistributionReq_t from Syslog
    robot_extension.Run Keyword And Warn On Failure         Display PRB POOLING NIDD param
    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    # save some test parameters as vendor file or Ue settings into ${testCaseDir}
    nps_9836_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${vendor_custom}    filename=data_test.json

    # Configure the current setting for all the ue's
    ${param.totalNbOfUe}    get length          ${dict_ues}
    Step                    Configure the setting for the ${param.totalNbOfUe} UEs
    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${param.totalNbOfUe}
        ${current_ue}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        Set To Dictionary             ${current_ueSetting}          trf_id              1
        Set To Dictionary             ${current_ueSetting}          target_gnb          ${param.targetGnb}
        Set To Dictionary             ${current_ueSetting}          size                ${dict_ues[${current_id}].packet_size}

        # Dispatching each ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ueSetting}          DL_throughput          ${dict_ues[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          UL_throughput          ${dict_ues[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}          protocol               ${dict_ues[${current_id}].protocol}

        Append To List                ${listOfUes}                  ${current_ueSetting}

        # save some test parameters as vendor file or Ue settings into ${testCaseDir}
        add_dictionary_to_json       ${testCaseDir}     'Ue_${current_ue}'   ${current_ueSetting}    data_test.json
    END
    # Dated Log New Line                UE_List=${listOfUes}
    display_list_parameters_w_name      ${listOfUes}   name=Ue   msg=Display Of listOfUes
    CB009836-Keywords.Check Multi Ues Setting In List        multiUesList=${listOfUes}

    set test Variable     ${listOfUes}
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Init   prefix=CellSetup.Attach.SA
    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start  actionCORE=${isCaptureCORE}
    ...                                                                                        actionCPRT=${isCaptureCPRT}
    ...                                                                                        actionL1L2=${isCaptureL1L2}
    ...                                                                                        actionTti=${False}

    # ${kw Set TestMode} is a robot Kw that allow to modify cfg file
    Run Keyword If    '${kw Set TestMode}'!='${EMPTY}'       ${kw Set TestMode}

    Setup devices aliases
    robot_extension.Run Keyword And Warn On Failure    Enable internal mirroring for alias    gNB2

    Run Keyword If    '${Kw Update NIDD Test Parameters}'!='${EMPTY}'      Step      Run Keyword    ${Kw Update NIDD Test Parameters}

    robot_extension.Run Keyword And Warn On Failure         Display periodicCsiAcquisition NIDD parameters

    ${LuaFileToUsed}=      Run Keyword If    '${W_CUSTOM_LUA_FILE_TO_USED}'=='1'       Install lua File into WTS    ${LuaFileToUsed_path}
    ...                        ELSE                                                    Set Variable                 ${EMPTY}

    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog2_beforeCellSetup
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    run Keyword If    '${ret}' == 'FAIL'     BuiltIn.log    btslog.Stop Btslog is ${ret}! with ${syslogpath}     level=ERROR     console=True
    ${fileExists}=     nps_9836_tools.file_exists   ${syslogpath}
    ${ret}    ${syslog_filename}   Run Keyword If   ${fileExists}==${True}
    ...                                           Run Keyword And Ignore Error    nps_9836_tools.return_basename   ${syslogpath}
    ...                              ELSE         ObtainVariablesKeyword
    robot_extension.Run Keyword And Warn On Failure   declare Trace in Trace List    Type=SysLog  Savedir=${dir_syslog}
    ...                          file_name=${syslog_filename}   Trigger=btslog2_beforeCellSetup
    robot_extension.Run Keyword And Warn On Failure   Check UL and DL l1Subpool Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}
    ...         Critical Step           Basic Call to Setup Wtsemu SA           nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${True}
    ...                                                             LuaFileToUsed=${LuaFileToUsed}
    # ...                                                             Kw_TM=${kw Set TestMode}
    ...   ELSE
    ...         Critical Step           CallSetup.Setup Wtsemu SA               nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${False}
    Dev_lib.wait_ng_link_up
    Dev_lib.start_to_capture_infomodel_log
    Run Keyword If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   CB009836-Keywords.Cell 1 cell 2 cell3 and cell4 Should Be Onair
    ...    ELSE                                                             All Cells Should Be Onair
    Dev_lib.stop_to_capture_infomodel_log

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    # test all cells mapped on same L1 Pool
    ${isFileNameDLCellMappingPresent}    Run Keyword And Return Status    Should Not Be Empty   ${FileNameDLCellMapping}
    ${fileExists}=     nps_9836_tools.file_exists   ${FileNameDLCellMapping}
    Run Keyword If   '${isFileNameDLCellMappingPresent}' == 'False' or not ${fileExists}
    ...                BuiltIn.Log    DL Cell mapping file not present (from Syslog), please check the config...    level=WARN    console=yes
    ...    ELSE        check Dl Cell mapping from Syslog ${FileNameDLCellMapping}

    # ${ret}  ${output}=    robot_extension.Run Keyword And Warn On Failure
    # ...                                        Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog     NbrCells=4
    # ${sorted_csirsGroups}            Set Variable     ${output[0]}
    # ${sorted_cellcsirs_slotoffset}   Set Variable     ${output[1]}
    # ${sorted_uecsirs_slotoffset}     Set Variable     ${output[2]}
    # ${sorted_trscsirs_slotoffset}    Set Variable     ${output[3]}
    # ${sorted_trscsirs_ssb_slotoffset}    Set Variable     ${output[4]}
    # Dated Log New Line    sorted_csirsGroups=${sorted_csirsGroups}
    # Dated Log New Line    sorted_cellcsirs_slotoffset=${sorted_cellcsirs_slotoffset}
    # Dated Log New Line    sorted_trscsirs_slotoffset=${sorted_trscsirs_slotoffset}
    # Dated Log New Line    sorted_trscsirs_ssb_slotoffset=${sorted_trscsirs_ssb_slotoffset}
    # Set test Variable     ${sorted_csirsGroups}
    # Set Test Variable     ${sorted_cellcsirs_slotoffset}
    # Set Test Variable     ${sorted_trscsirs_slotoffset}
    # Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}

    # check that we have all relation cell and csrirspool for all cells
    # ${cell_csirsGroups}=  Get length   ${sorted_csirsGroups}
    # Dated log    length of cell_csirsGroups = ${sorted_csirsGroups}
    # ${List_nrCellIdentity}   Create List     16385    16386    16387    16388
    # ${cell_missing_list}=    check_all_cell_csirspool_present      ${output[0]}    ${List_nrCellIdentity}
    # ${NbrCellNoFound}=       Get length   ${cell_missing_list}
    # Dated log    Nb of cell csirsGroups relation not found = ${NbrCellNoFound} with cell_missing_list=${cell_missing_list}
    # Run Keyword If     '${NbrCellNoFound}' != '0'       Try Lock and Unlock cells    ${cell_missing_list}
    # ${sorted_csirsGroups}=   Run Keyword If    '${NbrCellNoFound}' == '4'     Create List
    # ...                          ELSE                                         Copy List    ${sorted_csirsGroups}
    # ${sorted_cellcsirs_slotoffset}=   Run Keyword If    '${NbrCellNoFound}' == '4'     Create List
    # ...                                  ELSE                                          Copy List    ${sorted_cellcsirs_slotoffset}
    # ${sorted_trscsirs_slotoffset}=   Run Keyword If    '${NbrCellNoFound}' == '4'     Create List
    # ...                                  ELSE                                         Copy List    ${sorted_trscsirs_slotoffset}
    # ${sorted_trscsirs_ssb_slotoffset}=   Run Keyword If    '${NbrCellNoFound}' == '4'     Create List
    # ...                                      ELSE                                         Copy List    ${sorted_trscsirs_ssb_slotoffset}
    # Set test Variable     ${sorted_csirsGroups}
    # Set Test Variable     ${sorted_cellcsirs_slotoffset}
    # Set Test Variable     ${sorted_trscsirs_slotoffset}
    # Set Test Variable     ${sorted_trscsirs_ssb_slotoffset}
    # Run Keyword If     '${NbrCellNoFound}' != '0'       Update csirsGroups and cellcsirs
    # ${sorted_csirsGroups} is used by 'Check cellcsirs Assignement' Kw but also used by 'verify_TTITraces_for_csirs' Kw
    # ${cellcsirs_slotoffset_present}   evaluate   len(${sorted_cellcsirs_slotoffset}) != ${0}
    # run Keyword If    ${cellcsirs_slotoffset_present}
    # ...            Run keyword and continue on failure     Check cellcsirs Assignement  ${sorted_cellcsirs_slotoffset}   ${FrameStructure}
    # ...     ELSE   declare Results in Test Results List    Type=SYSLOG : Check Cell Specific CSI-RS allocation
    # ...                                                    Result=WARN no cellcsirs_slotoffset_present
    # Run Keyword If    '${TypeCheck}' == 'allCellsSameSSB'
    # ...   Run keyword and continue on failure     Check TrsCsiRs Assignement     ${sorted_trscsirs_slotoffset}    ${FrameStructure}
    # ...    ELSE
    # ...   Run keyword and continue on failure     Check TrsCsiRs Assignement For 4 Cells  ${sorted_trscsirs_ssb_slotoffset}   ${sorted_csirsGroups}
    # ...                                                                                   ${FrameStructure}
    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    # bypassed for PR investigation case
    # robot_extension.Run Keyword And Warn On Failure         Check cellmappingtocsirspoolinggroup Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    ${num_of_cells}=    Get Cell Number
    @{cell_to_bypass}=  Create List    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-4
    Critical Step       Wait gNB cells 5g On air    ${num_of_cells}    cell_to_bypass=${cell_to_bypass}

    ${ret}   ${dll1spcells}    robot_extension.Run Keyword And Warn On Failure         Get dlsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    ${ret}   ${ull1spcells}    robot_extension.Run Keyword And Warn On Failure         Get ulsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    Set Suite Variable      ${dll1spcells}
    Set Suite Variable      ${ull1spcells}
    dated log   dlsubcellSpool0List=${dll1spcells[0]}
    dated log   dlsubcellSpool1List=${dll1spcells[1]}
    dated log   ulsubcellSpool0List=${ull1spcells[0]}
    dated log   ulsubcellSpool1List=${ull1spcells[1]}
    set test variable    ${dll1spcells[0]}
    set test variable    ${dll1spcells[1]}
    set test variable    ${ull1spcells[0]}
    set test variable    ${ull1spcells[1]}
    robot_extension.Run Keyword And Warn On Failure     update bbpoolInfo Dll1Subpool and Ull1Subpool Assignment

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${False}   Step                      CallSetup.WTS Set X2 Link

    Run Keyword If      '${kw Specific Set TestMode Before Attach}'!='${EMPTY}'
    ...                                                    Step   Run specific keywords before attach : ${kw Specific Set TestMode Before Attach}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step      Captures CB009836 Start    actionTti=${isCaptureTti}

    # Register and launch PDU for all the ue's except for which define on the deleted cell
    FOR    ${current_elem}    IN    @{listOfUes}
        # Run Keyword If      ${current_elem.target_cells} != ${nrCell}    Run Keywords
        Run Keywords
        ...                 Critical Step       CallSetup UE register UeId "${current_elem.ue}" on Target cell "${current_elem.target_cells}"
        ...                                     depends=CallSetup.Setup Wtsemu SA
        ...    AND
        ...                 Critical Step     CallSetup.Launch PDU Session
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         gw=${current_elem.ue}
        ###...                                                      nwslice=1
        ...                                   depends=CallSetup UE register UeId
    END

    Run Keyword If    '${kw Specific Set TestMode After Attach}'!='${EMPTY}'
    ...                                                   Step   Run specific keywords after attach : ${kw Specific Set TestMode After Attach}

    ${rntiList}=    create list
    FOR    ${current_elem}    IN    @{listOfUes}
        ${UeId}      CB009836-Ue-Commands.Get Crnti From Egate Log     ue_id=${current_elem.ue}
        Dated log       ======> Rnti[UeId=${current_elem.ue}] is ${UeId}
        Append To List                ${rntiList}                  ${UeId}
    END
    Set Test Variable     ${rntiList}

    Run Keyword if   '${w_generic_capture}' == 'True'       Step        Captures CB009836 Stop

    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog2_beforeStartTraffic
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    run Keyword If    '${ret}' == 'FAIL'     BuiltIn.log    btslog.Stop Btslog is ${ret}! with ${syslogpath}     level=ERROR     console=True
    ${fileExists}=     nps_9836_tools.file_exists   ${syslogpath}
    ${ret}    ${syslog_filename}   Run Keyword If   ${fileExists}==${True}
    ...                                           Run Keyword And Ignore Error    nps_9836_tools.return_basename   ${syslogpath}
    ...                              ELSE         ObtainVariablesKeyword
    robot_extension.Run Keyword And Warn On Failure   declare Trace in Trace List    Type=SysLog  Savedir=${dir_syslog}
    ...                          file_name=${syslog_filename}   Trigger=btslog2_beforeStartTraffic
    robot_extension.Run Keyword And Warn On Failure   btslog.Start Btslog

    # start TtiTrace and L1L2Bip
    Captures CB009836 Init   prefix=wTraffic
    Captures CB009836 Start  actionCORE=${False}
    ...                      actionCPRT=${False}
    ...                      actionL1L2=${True}
    ...                      actionTti=${True}

    # Start the non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput} > ${0}    DL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.DL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.DL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session

        ${dir}=   set Variable If    ${current_elem.UL_throughput} > ${0}    UL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.UL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.UL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session
    END

    CB009836-Keywords.Captures Stop         actionCORE=${False}
    ...                                     actionCPRT=${False}
    ...                                     actionL1L2=${True}
    set Test Variable       ${sw_generic_capture_started}     ${False}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CaptureCPRT.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${CaptureCPRT.path}    ${testCaseDir}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CaptureCORE.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${CaptureCORE.path}    ${testCaseDir}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CaptureL1L2.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${CaptureL1L2.path}    ${testCaseDir}
    ${tti_trace_path}    Run Keyword And Ignore Error    Stop and Get TTI traces      suffix=DuringTraffic
    declare Trace in Trace List  Type=L1L2Bip   Savedir=${testCaseDir}
    ...                          file_name=${CaptureL1L2.name}.pcap   Trigger=DuringTraffic
    declare Trace in Trace List  Type=TtiTrace   Savedir=${tti_trace_path}
    ...                          file_name=ttitrace_streaming.pcap    Trigger=DuringTraffic

    ${dir_syslog}=    Prepare Logs Directory Path     resultDir=${testCaseDir}    subdir=btslog2_wTraffic
    ${ret}    ${syslogpath}=     robot_extension.Run Keyword And Warn On Failure   btslog.Stop Btslog    target_dir=${dir_syslog}
    run Keyword If    '${ret}' == 'FAIL'     BuiltIn.log    btslog.Stop Btslog is ${ret}! with ${syslogpath}     level=ERROR     console=True
    ${fileExists}=     nps_9836_tools.file_exists   ${syslogpath}
    ${ret}    ${syslog_filename}   Run Keyword If   ${fileExists}==${True}
    ...                                           Run Keyword And Ignore Error    nps_9836_tools.return_basename   ${syslogpath}
    ...                              ELSE         ObtainVariablesKeyword
    robot_extension.Run Keyword And Warn On Failure   declare Trace in Trace List    Type=SysLog  Savedir=${dir_syslog}
    ...                          file_name=${syslog_filename}   Trigger=btslog2_wTraffic

    ${L1L2_Pcap_File}=     set variable      ${testCaseDir}/${CaptureL1L2.name}
    run Keyword if   '${L1L2_Pcap_File}' != 'None'      Run Keywords     Dated log    gzip -f ${L1L2_Pcap_File}.pcap
    ...                                                         AND      Run    gzip -f ${L1L2_Pcap_File}.pcap

    ${FilePkl}=           Omit when TtiTrace deactivated
    ...      Run keyword and continue on failure      Convert TTI Traces to Dataframe and store as pickle for UL Mimo
    ...                                                                                                     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                                                     ttitracepath=${tti_trace_path}

    # Generate Verdict...
    Omit when TtiTrace deactivated      Step      Generate Test Verdict    ${FilePkl}   ${vendor_custom}
    ...                                                                    ${dictExpectedValues}
    ...                                                                    ${kw Check SCF parameters}
    ...                                                                    verify_TTITraces_for_csirs_4cells
    ...                                                                    ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                    ttitracepath=${tti_trace_path}

    ${cntUes}=    Get length    ${rntiList}
    Step      CB009836-Ue-Commands.Verify Nbr Of ${cntUes}Ues ACTIVE

    # if  '${SKIP_COUNTERS}'=='False' => 'Display PDSCH and PUSCH ue_stats_nr for UEList' allow to Wait time until next PM file
    Run Keyword And Ignore Error     Display PDSCH and PUSCH ue_stats_nr for UEList   UEsList=${listOfUes}    file=${csv_file_tput_results}

    # Collect PM only if  '${SKIP_COUNTERS}'=='False'
    Omit when SKIP_COUNTERS present      robot_extension.Run Keyword And Warn On Failure
    ...                                           CB009836-Keywords.Collect PM Counters and process throughput using PM counters

    # to bypass UE Deregister if needed
    @{listOfUes}    run Keyword if    '${w_ue_detach}' == 'False'    Create List
    ${len}=   Get Length   ${listOfUes}
    run Keyword if    '${len}' != '${0}'    Step    Traced Sleep   duration=3s   msg=deregistering     depends=CallSetup.UE Register
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.target_cells} != ${nrCell}
        ...                 Step      CallSetup.UE Deregister       id=${current_elem.ue}
        ###...                                                      ue_deregister_type=switch_off
        ###...                                                      by=ue
        ...                                                         depends=CallSetup.UE Register
    END
    [Teardown]   Teardow Kw

# ------------------------------------------------------------------------------------------------------------------------------------


