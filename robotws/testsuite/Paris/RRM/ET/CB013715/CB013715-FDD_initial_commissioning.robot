*** Settings ***
Documentation       Scenario specific keywords for feature CB013715
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library       resources/TARF/python/tools.py       WITH NAME          nps_tarf_tools

# TARF resources
Resource      resources/TARF/robot/Scenario-Common-Keywords.robot

# CB013715 resources
Resource      ./CB013715_initial_commissioning.robot
Resource      ./CB013715_scenario_modifications.robot

# Variables     ./CB013715_variables.yaml

*** Variables ***
&{5GC001116_0_fs}  frameStructureType=tdLte
    ...     guardPeriodLength=4Symbols
    ...     lteToNrFrameShift=0ms
    ...     tdLteUlDlConfig=tdLteConfig2
    ...     ulDlDataSlotRatio=1/4

&{5GC001116_3_fs}   frameStructureType=tdLte
    ...     guardPeriodLength=4Symbols
    ...     lteToNrFrameShift=3ms
    ...     tdLteUlDlConfig=tdLteConfig2
    ...     ulDlDataSlotRatio=1/4

&{5GC001116_3_Canada_fs}   frameStructureType=tdLte
    ...     guardPeriodLength=4Symbols
    ...     lteToNrFrameShift=3ms
    ...     tdLteUlDlConfig=tdLteConfig2
    ...     ulDlDataSlotRatio=1/4

&{5GC001208_fs}     frameStructureType=semiStatic
    ...     guardPeriodLength=2Symbols
    ...     ulDlDataSlotRatio=1/4

&{5GC001070_fs}      frameStructureType=semiStatic
    ...     guardPeriodLength=2Symbols
    ...     ulDlDataSlotRatio=3/7

&{5GC001116_0_inf_fs}  infFrameStructureType=tdLte
    ...     infGuardPeriodLength=4Symbols
    ...     infLteToNrFrameShift=0ms
    ...     infScs=30 KHz
    ...     infTddFrameMutingBiAgreement=true
    ...     infTdLteUlDlConfig=tdLteConfig2
    ...     infUlDlDataSlotRatio=1/4

&{5GC001116_3_inf_fs}  infFrameStructureType=tdLte
    ...     infGuardPeriodLength=4Symbols
    ...     infLteToNrFrameShift=3ms
    ...     infScs=30 KHz
    ...     infTddFrameMutingBiAgreement=true
    ...     infTdLteUlDlConfig=tdLteConfig2
    ...     infUlDlDataSlotRatio=1/4

&{5GC001208_inf_fs}  infFrameStructureType=semiStatic
    ...     infGuardPeriodLength=2Symbols
    ...     infScs=30 KHz
    ...     infTddFrameMutingBiAgreement=true
    ...     infUlDlDataSlotRatio=1/4

&{cSrs}   10MHz=7
    ...   15MHz=10
    ...   20MHz=13
    ...   30MHz=20
    ...   40MHz=25
    ...   50MHz=33
    ...   60MHz=42
    ...   70MHz=45
    ...   80MHz=51
    ...   90MHz=56
    ...   100MHz=63

# defined in yaml file
# @{nrCellId_List}   1   2   3
# @{nrCellGrplId}    0   1   2

${actBeamforming}                   true
${actCsirsMultiplexing}             true
${actCellCsirsTddOnSsbBf}           false
${actCellCsiRsImTddNonBf}           false
${actNonVoNRGBRService}             false    # actNonVoNRGBRService per Cell
${actAdaptiveReTxResMcs}            false    # actAdaptiveReTxResMcs per Cell, recommended value (not supported by AP)
${actPdcchSharingWithPdsch}         false
${actEnhancedPDSCHSchSplSlot}       false    #CB009007 - PDSCH scheduling in special slot - FR1 TDD
${actFdmEnhancedScheduling}         true
${actInfTddFrameMuting}             false    # actInfTddFrameMuting per Cell
${frameStructure}                   5GC001208    # 5GC001208 means SemiStatic 1:4
@{actUlSrsBm}                       false    false    false
@{actDlSrsBm}                       false    false    false
@{chBw}                             100MHz          80MHz          60MHz
@{type0CoresetConfigurationIndex}         10    10    10
@{type0SearchSpaceConfigurationIndex}     5     5    5
@{prach}                            93      93      93
${rbAllocation}                     BWP   #BWP per Cell
# @{nrCellType}                       8DL8UL      8DL8UL      8DL8UL
@{nrCellType}                       4DL4UL      4DL4UL      4DL4UL
# @{dlMimoMode}                       8x4 Closed Loop Spatial Multiplexing      8x4 Closed Loop Spatial Multiplexing
# ...                                 8x4 Closed Loop Spatial Multiplexing
@{dlMimoMode}                       4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
...                                 4x4 or 4x2 Closed Loop Spatial Multiplexing

@{csiReportPeriodicity}             slots80   slots80  slots80

&{reqMinNumPuschPrb}    10MHz=12
    ...   15MHz=24
    ...   20MHz=37
    ...   30MHz=62
    ...   40MHz=84
    ...   50MHz=103
    ...   60MHz=126
    ...   70MHz=153
    ...   80MHz=181
    ...   90MHz=209
    ...   100MHz=237

# initial commissioning, actHighSpeedCell is false
@{actHighSpeedCell}                 true    true    true
# "pdl":"Assertion not met: NRCELL(actHighSpeedCell = 'true' and cellTechnology = 'TDD') have ulDMRSAdditionalPosition
#  in range 'Two additional DMRS'|'Automatic'",
# initial commissioning , actHighSpeedCell is false
# @{ulDMRSAdditionalPosition}         Two additional DMRS     Two additional DMRS    Two additional DMRS
# @{dlDMRSAdditionalPosition}         Two additional DMRS     Two additional DMRS    Two additional DMRS

@{ulDMRSAdditionalPosition}         Automatic     Two additional DMRS    Two additional DMRS
@{dlDMRSAdditionalPosition}         Two additional DMRS     Two additional DMRS    Two additional DMRS

@{actUlPtrs}                        true        false      false
@{actDlPtrs}                        false        false      false

# "feedback":"Whenever NRCELL-1 having ${NRCELL-1.actHighSpeedCell} (value: false) equal to false,
#  it is required that ${NRCELL-1.dlDMRSAdditionalPosition} (value: Two additional DMRS) not equal to Two additional DMRS and
#  ${NRCELL-1.ulDMRSAdditionalPosition} (value: Two additional DMRS) not equal to Two additional DMRS
# and ${NRCELL-1.prachSequenceType} (value: Unrestricted) not equal to RestrictedTypeB",

@{prachSequenceType}       Unrestricted    Unrestricted    Unrestricted
@{zeroCorrelationZoneConfig}    14            14               14

@{dmrsTypeAPosition}         pos2    pos2    pos2

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]
Make necessary changes to SCF
    [Arguments]   ${w_calculate_delta_scf}=false
    ${variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${tdd_cell_1}
    ${isEmpty}             Run Keyword And Return Status    Should Be Empty          ${tdd_cell_1}
    run keyword if   ${variable_exists} and not ${isEmpty}    dated log    ${consTraceColorYellow}translated tdd_cell_1 to ${tdd_cell_1}${defColor}
    ${variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${tdd_cell_2}
    ${isEmpty}             Run Keyword And Return Status    Should Be Empty          ${tdd_cell_2}
    run keyword if    ${variable_exists} and not ${isEmpty}    dated log   ${consTraceColorYellow}translated tdd_cell_2 to ${tdd_cell_2}${defColor}
    ${variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${fdd_cell_1}
    ${isEmpty}             Run Keyword And Return Status    Should Be Empty          ${fdd_cell_1}
    run keyword if    ${variable_exists} and not ${isEmpty}    dated log    ${consTraceColorYellow}translated fdd_cell_1 to ${fdd_cell_1}${defColor}
    ${variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${fdd_cell_2}
    ${isEmpty}             Run Keyword And Return Status    Should Be Empty          ${fdd_cell_2}
    run keyword if    ${variable_exists} and not ${isEmpty}    dated log    ${consTraceColorYellow}translated fdd_cell_2 to ${fdd_cell_2}${defColor}
    IF    not 'CRT' in '${SUITE_NAME}'
        ${relative_CB0013715_Counters_definition_path}      set variable  ../../../../../CB013715/resources/counters/Counter_Definitions.csv
        ${relative_CB0013715_Counters_definition_path_ref}
        ...          set variable  ../../../../../../../resources/SWENG/config/KPI/SBTS00/Counter_Definitions.csv
        ${CB0013715_Counters_definition}=        nps_tarf_tools.get_file_path     relative_path=${relative_CB0013715_Counters_definition_path}
        ${CB0013715_Counters_definition_ref}=    nps_tarf_tools.get_file_path     relative_path=${relative_CB0013715_Counters_definition_path_ref}
        Copy If Not Equal    REF_FILE=${CB0013715_Counters_definition_ref}    WORK_FILE=${CB0013715_Counters_definition}
    END
    robot_extension.Run Keyword And Warn On Failure  Change RD Parameters in swconfig File for CB013715
    robot_extension.Run Keyword And Warn On Failure  CB013715_scenario_modifications.Add RD Parameters in AP swconfig File
    ${gnb_scf}    COAM Get SCF   local_dir_path=${LOG_PATH}   file=SCF.xml   alias=coam_gnb
    Set Suite Variable              ${test_scf_file}    ${gnb_scf}
    ${cellDepType}=   DSS_Kw_TestSetup.get cellDepType from SCF
    # prepare TL for DSS
    ${cell2_is_Dss}=     set variable if   '2Cells-Dss' in '${SUITE_NAME}'     ${True}    ${False}
    set suite variable     ${cell2_is_Dss}
    # BEWARE : cell3 is DSS for CA test because 2TDD+2FDD configuration used (cell1/cell2 are TDD abd cell3/cell4 are FDD)
    ${cell3_is_Dss}=     set variable if   'CA' in '${SUITE_NAME}'     ${True}    ${False}
    set suite variable     ${cell3_is_Dss}
    ${TestDSSContext}    set variable if   '10MHz' in '${SUITE_NAME}'    ${TestDSS10Mhz}
    ...                                    '15MHz' in '${SUITE_NAME}'    ${TestDSS15Mhz_NO_BL}
    ...                                                                  ${TestDSS20Mhz_NO_BL}
    # ${TestDSSContext}   set variable if   '10MHz' in '${SUITE_NAME}' and '${w_actPRBBlanking}'=='True'  ${TestDSS10Mhz_BLE}
    ${TestDSSContext}   set variable if   '10MHz' in '${SUITE_NAME}' and '${w_actPRBBlanking}'=='True'  ${TestDSS10Mhz_BLE_2}
    ...                                                                                                 ${TestDSSContext}
    ${TestDSSContext}   set variable if   '15MHz' in '${SUITE_NAME}' and '${w_actPRBBlanking}'=='True'  ${TestDSS15Mhz_BLE}
    ...                                                                                                 ${TestDSSContext}
    ${TestDSSContext}   set variable if   '20MHz' in '${SUITE_NAME}' and '${w_actPRBBlanking}'=='True'  ${TestDSS20Mhz_BLE}
    ...                                                                                                 ${TestDSSContext}
    ${TestDSSContextCell2}    set variable if  ${cell2_is_Dss} and '20MHz' in '${SUITE_NAME}'  ${TestDSS20Mhz_BLE_Cell2}
    ...                                                                                        ${None}
    ${TestDSSContext.Context.cellDepType}          set variable    ${cellDepType}
    ${TestDSSContext.scfFile.nrdsslte.eNodeBId}    set variable    ${TestDSS10Mhz.Context.eNBId}
    IF   '20MHz-CA' in '${SUITE_NAME}' and '${w_actPRBBlanking}'=='True'
        Update nrCellType into "${TestDSSContext}" for cellID "3"
    ELSE
        Update nrCellType into "${TestDSSContext}" for cellID "1"
    END
    set suite variable   ${TestDSSContext}
    IF   '20MHz-CA' in '${SUITE_NAME}' and '${w_actPRBBlanking}'=='True'
        set suite variable    ${gscn_fdd_cell_1}    ${TestDSSContext.scfFile.nrcell.gscn}
    ELSE
        set suite variable    ${gscn_fdd_cell_1}    ${TestDSSContext.scfFile.nrcell.gscn}
    END
    IF    ${cell2_is_Dss}
        Update nrCellType into "${TestDSSContextCell2}" for cellID "2"
        set suite variable   ${TestDSSContextCell2}
        set suite variable   ${gscn_fdd_cell_2}    ${TestDSSContextCell2.scfFile.nrcell.gscn}
    END
    ${tc_name}    Set variable    TestLine_preparation
    ${tc_status}    getTcStatusByName    name=${tc_name}
    ${gnb_scf}    Run keyword if    '${tc_status}'!='PASS' and '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...                          DSS_Kw_TestSetup.Test Line Preparation    ${TestDSSContext}
    ...              ELSE        set variable     ${test_scf_file}
    IF    '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'
        BuiltIn.log    [ INFO ] Test Line Preparation Not Needed...    console=True
    END
    ${gnb_scf}    COAM Get SCF   local_dir_path=${LOG_PATH}   file=SCF.xml   alias=coam_gnb
    Fetch Nidd Version From SCF File     scf_gnb=${gnb_scf}
    IF    '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0' and '${UPDATE_SCF}'=='0'
        run keyword if    '10MHz' in '${SUITE_NAME}'    Modify iphy.xml for 2FDD Setup for 10MHz
        run keyword if    '15MHz' in '${SUITE_NAME}'    Modify iphy.xml for 2FDD Setup for 15MHz
        run keyword if    '20MHz' in '${SUITE_NAME}' and 'CA' not in '${SUITE_NAME}'    Modify iphy.xml for 2FDD Setup for 20MHz
        Set SW POSTFIX Variable equaled to cellTechnology    gnb_scf=${gnb_scf}
    END
    # need to update blanked Prb into TestDSSContext
    IF    '${w_actPRBBlanking}'=='True' and '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0' and '${UPDATE_SCF}'=='0'
        set suite variable     ${test_scf_file}    ${configuration_directory}/SCFC_gNB0_DU_orig.xml
        DSS_keywords.Update Blanked PRBs into "${TestDSSContext}" for cellID "${fdd_cell_1}"
        IF    ${cell2_is_Dss}
            DSS_keywords.Update Blanked PRBs into "${TestDSSContextCell2}" for cellID "${fdd_cell_2}"
        END
    END
    Return From Keyword If    '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0' and '${UPDATE_SCF}'=='0'
    scf.load_scf    ${gnb_scf}
        Set SW POSTFIX Variable equaled to cellTechnology    gnb_scf=${gnb_scf}
        Change Reporting Interval for CB013715  interval_duration=${pm_reporting_interval}    gnb_scf=${gnb_scf}
        Disable some Functionality according to CFAM    gnb_scf=${gnb_scf}
        Configure BWP_PDCCH    gnb_scf=${gnb_scf}
        DSS_Kw_TestSetup.Test Setup DSS      ${TestDSSContext}     gnb_scf=${gnb_scf}
        run keyword if    '20MHz' in '${SUITE_NAME}' and ${cell2_is_Dss}
        ...   DSS_Kw_TestSetup.Test Setup DSS Cell2      ${TestDSSContextCell2}     gnb_scf=${gnb_scf}
        run keyword if    '10MHz' in '${SUITE_NAME}'   Modify iphy.xml for 2FDD Setup for 10MHz
        run keyword if    '15MHz' in '${SUITE_NAME}'   Modify iphy.xml for 2FDD Setup for 15MHz
        run keyword if    '20MHz' in '${SUITE_NAME}' and 'CA' not in '${SUITE_NAME}'   Modify iphy.xml for 2FDD Setup for 20MHz
        run keyword if    '10MHz' in '${SUITE_NAME}' and not 'NSAOnly' in '${SUITE_NAME}'
        ...                                        Modify scf.xml for 2FDD Setup with Cell1 FDD Dss 10MHz  ${TestDSSContext}  gnb_scf=${gnb_scf}
        run keyword if    '10MHz' in '${SUITE_NAME}' and 'NSAOnly' in '${SUITE_NAME}'
        ...                            Modify scf.xml for 2FDD Setup with Cell1 cellDepType=NSA FDD Dss 10MHz  ${TestDSSContext}  gnb_scf=${gnb_scf}
        run keyword if    '15MHz' in '${SUITE_NAME}'   Modify scf.xml for 2FDD Setup with Cell1 FDD Dss 15MHz  ${TestDSSContext}  gnb_scf=${gnb_scf}
        run keyword if    '20MHz' in '${SUITE_NAME}' and 'CA' not in '${SUITE_NAME}'   Modify scf.xml for 2FDD Setup with Cell1 FDD Dss 20MHz
        ...                                                                                                    ${TestDSSContext}  gnb_scf=${gnb_scf}
        run keyword if    '20MHz' in '${SUITE_NAME}' and ${cell2_is_Dss}
        ...                                       Modify scf.xml for 2FDD Setup with Cell2 FDD Dss 20MHz  ${TestDSSContextCell2}  gnb_scf=${gnb_scf}
        IF   '10MHz' in '${SUITE_NAME}' and not 'NSAOnly' in '${SUITE_NAME}' and '${w_actPRBBlanking}'=='True'
            CB013715_initial_commissioning.Initial commissioning for Cell1 with PRB Blanking    ${TestDSSContext}     gnb_scf=${gnb_scf}
        END
        IF   '10MHz' in '${SUITE_NAME}' and 'NSAOnly' in '${SUITE_NAME}' and '${w_actPRBBlanking}'=='True'
            CB013715_initial_commissioning.Initial commissioning for Cell1 with PRB Blanking for cellDepType=NSA  ${TestDSSContext}
            ...                                                                                                   gnb_scf=${gnb_scf}
        END
        IF   '15MHz' in '${SUITE_NAME}' and '${w_actPRBBlanking}'=='True'
            CB013715_initial_commissioning.Initial commissioning for Cell1 with PRB Blanking    ${TestDSSContext}     gnb_scf=${gnb_scf}
        END
        IF   '20MHz' in '${SUITE_NAME}' and 'CA' not in '${SUITE_NAME}' and '${w_actPRBBlanking}'=='True'
            CB013715_initial_commissioning.Initial commissioning for Cell1 with PRB Blanking    ${TestDSSContext}     gnb_scf=${gnb_scf}
        END
        IF   '20MHz' in '${SUITE_NAME}' and '${w_actPRBBlanking}'=='True' and ${cell2_is_Dss}
            CB013715_initial_commissioning.Initial commissioning for Cell2 with PRB Blanking    ${TestDSSContextCell2}   gnb_scf=${gnb_scf}
        END
    scf.save_scf    ${configuration_directory}/SCFC_gNB0_DU_orig_updated_2.xml

   # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure   TARF-Keywords.Admin Validate SCF
    ...                                                                    scf_path_file=${configuration_directory}/SCFC_gNB0_DU_orig_updated_2.xml
    ...                                                                    dir=${LOG_PATH}

    Run Keyword If    '${w_calculate_delta_scf}'=='true'     Dated log     calculate_delta_scf...
    ...    ELSE                                              Dated log     no calculate_delta_scf...
    ${delta_scf_path}=    Set variable    ${configuration_directory}/delta_SCF_updated.xml
    Run Keyword If    '${w_calculate_delta_scf}'=='true'    scf.calculate_delta_scf
    ...                                                                 target_scf_path=${configuration_directory}/SCFC_gNB0_DU_orig_updated_2.xml
    ...                                                                 actual_scf_path=${gnb_scf_updated}    delta_scf_path=${delta_scf_path}
    ${is_commissioning_needed}=    Run Keyword If    '${w_calculate_delta_scf}'=='true'    Check if commissioning is needed    ${delta_scf_path}
    ...                               ELSE                                                 set Variable     ${True}

    Return from keyword if    not ${is_commissioning_needed}

    # for testing purpose
    # Return from keyword

    # ${oam_alias}=    connect.Setup OAM http session
    ${oam_alias}=    set variable     coam_gnb
    nps_tarf_tools.log_to_console_with_time_prefix   perform_commissioning [${configuration_directory}/SCFC_gNB0_DU_orig_updated_2.xml]   level=INFO
    admin.perform_commissioning  scf_file=${configuration_directory}/SCFC_gNB0_DU_orig_updated_2.xml  connection=${oam_alias}
    ...  skip_parameter_relation_errors=true  timeout=600
    # connect.Teardown OAM http session

    # need to update blanked Prb into TestDSSContext
    IF    '${w_actPRBBlanking}'=='True'
        set suite variable     ${test_scf_file}    ${configuration_directory}/SCFC_gNB0_DU_orig_updated_2.xml
        DSS_keywords.Update Blanked PRBs into "${TestDSSContext}" for cellID "${fdd_cell_1}"
        IF    ${cell2_is_Dss}
            DSS_keywords.Update Blanked PRBs into "${TestDSSContextCell2}" for cellID "${fdd_cell_2}"
        END
    END

Copy If Not Equal
    [arguments]    ${REF_FILE}    ${WORK_FILE}
    ${ref_content}=    OperatingSystem.Get File    ${REF_FILE}
    ${work_content}=   OperatingSystem.Get File    ${WORK_FILE}
    ${filename}        nps_tarf_tools.return_basename             ${WORK_FILE}
    ${msg}    Catenate     ${filename} not equal to reference file! reference version updated with working version
    ${status}    ${value}=    Run Keyword And Ignore Error    Should Be Equal    ${ref_content}    ${work_content}
    Run Keyword If    '${status}' == 'FAIL'   Run Keywords    OperatingSystem.Copy File   ${WORK_FILE}  ${REF_FILE}
    ...                                           AND         BuiltIn.log    ${msg}  level=WARN

Prepare testCase Execution
    [arguments]    ${w_calculate_delta_scf}=false    ${set_active_configuration}=CB007491-TDD_initial_commissioning.Init NIDD params
    ...            ${w_set_config}=True
    ${gnb_scf_updated}    COAM Get SCF   local_dir_path=${configuration_directory}
    ...                                  file=SCFC_gNB0_DU_orig_updated_for_tc_${set_active_configuration}.xml
    ...                                  alias=coam_gnb
    scf.load_scf    ${gnb_scf_updated}
        Activate and Disable some Functionality according to CFAM    set_active_configuration=${set_active_configuration}
        ...                                                          w_set_config=${w_set_config}
    scf.save_scf    ${configuration_directory}/SCFC_gNB0_DU_orig_updated_for_tc_${set_active_configuration}.xml
    # ${w_testCase_preparation} and ${w_force_active_config} are defined into yaml variables file
    nps_tarf_tools.log_to_console_with_time_prefix     w_testCase_preparation is ${w_testCase_preparation}    level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     w_force_active_config is ${w_force_active_config}      level=INFO
    return from keyword if    '${w_testCase_preparation}'=='False' and '${w_force_active_config}'=='False'
    # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure   TARF-Keywords.Admin Validate SCF
    ...      scf_path_file=${configuration_directory}/SCFC_gNB0_DU_orig_updated_for_tc_${set_active_configuration}.xml
    ...      dir=${LOG_PATH}

    Run Keyword If    '${w_calculate_delta_scf}'=='true'     Dated log     calculate_delta_scf...
    ...    ELSE                                              Dated log     no calculate_delta_scf...
    ${delta_scf_path}=    Set variable    ${configuration_directory}/delta_SCF_updated_for_tc_${set_active_configuration}.xml
    Run Keyword If    '${w_calculate_delta_scf}'=='true'    scf.calculate_delta_scf
    ...                              target_scf_path=${configuration_directory}/SCFC_gNB0_DU_orig_updated_for_tc_${set_active_configuration}.xml
    ...                              actual_scf_path=${gnb_scf_updated}    delta_scf_path=${delta_scf_path}
    ${is_commissioning_needed}=    Run Keyword If    '${w_calculate_delta_scf}'=='true'    Check if commissioning is needed    ${delta_scf_path}
    ...                               ELSE                                                 set Variable     ${True}

    Return from keyword if    not ${is_commissioning_needed}

    Dated log     performing_commissioning...
    # ${oam_alias}=    connect.Setup OAM http session
    ${oam_alias}=    set variable     coam_gnb
    admin.perform_commissioning  scf_file=${configuration_directory}/SCFC_gNB0_DU_orig_updated_for_tc_${set_active_configuration}.xml
    ...  connection=${oam_alias}
    ...  skip_parameter_relation_errors=true  timeout=600
    # connect.Teardown OAM http session
    Return From Keyword

Check if commissioning is needed
    [Arguments]    ${delta_config_file}
    ${delta_size}=    Get file size    ${delta_config_file}
    ${is_commissioning_needed}=    Evaluate    ${delta_size} > 2
    [Return]    ${is_commissioning_needed}

Delta Json Commission With NIDD Default Value
    [Arguments]    ${delta_file_name}
    #     ${gnb_id}=${0}    ${port}=3600    ${alias}=cOAM
    ${oam_alias}=    connect.Setup OAM http session
    coam.perform_delta_recommissioning    delta_file=${CURDIR}/../resources/config/custom/${delta_file_name}
    ...    skip_parameter_relation_errors=true
    ...    connection=${oam_alias}
    connect.Teardown OAM http session

Set SW POSTFIX Variable equaled to cellTechnology
    [arguments]     ${gnb_scf}
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${cellTechnology}=    scf.get_value_from_scf    p_name=cellTechnology    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}
    ${SW_POSTFIX}=    set variable if    '${cellTechnology}'=='FDD'    FDD    TDD
    set suite variable    ${SW_POSTFIX}

Change Reporting Interval for CB013715
    [Arguments]    ${interval_duration}     ${gnb_scf}
    ${distName_NRPMRNL}=    Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                                 regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  create list
    ...    miNrCellAvailability
    ...    miNrCellUtilization
    ...    miNrPdcch
    ...    miNrResourceUtilizationPerCell
    ...    miNrEnDssPerCell

    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=${pname}
    END
    ${distName_PMCADM}=  Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...                                                                              regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm

Log config in result file
    [Arguments]    ${config}=None
    ${resultFile}    Set Variable     ${testCaseDir}/resultFile_${TEST NAME[0:30]}.log
    Set Test Variable    ${resultFile}
    Append To File   ${resultFile}  ------------------------------------------------------\n
    Append To File   ${resultFile}   TEST NAME: ${TEST NAME}\n
    Append To File   ${resultFile}   TEST CONFIG: ${config}\n
    Append To File   ${resultFile}   TEST active_configuration_used: ${active_configuration_used}\n
    Append To File   ${resultFile}  ------------------------------------------------------\n
    Append To File   ${resultFile}   \nFrame structure: @{frameStructure_cell}
    Append To File   ${resultFile}   \nbasicBeamSet: @{beamSet}
    Append To File   ${resultFile}   \nbeams [numberOfTransmittedSsBlocks]: @{beams}
    Append To File   ${resultFile}   \ndlMimoMode @{dlMimoMode}
    Append To File   ${resultFile}   \nnrCellType @{nrCellType}
    Append To File   ${resultFile}   \nchBw @{chBw}
    Append To File   ${resultFile}   \nprachConfigurationIndex @{prach}
    Append To File   ${resultFile}   \ntype0CoresetConfigurationIndex @{type0CoresetConfigurationIndex}
    Append To File   ${resultFile}   \ntype0SearchSpaceConfigurationIndex @{type0SearchSpaceConfigurationIndex}
    # FOR     ${i}   IN RANGE  len(@{nrCellId_List})
    #     Append To File   ${resultFile}   \nCellId=${nrCellId_List}[${i}] srsForBeamMgmt:cSRS=${cSRS['${chBw}[${i}]']}
    # END
    Append To File   ${resultFile}   \nactDlSrsBm @{actDlSrsBm}
    Append To File   ${resultFile}   \nactUlSrsBm @{actUlSrsBm}
    Append To File   ${resultFile}   \nactBeamforming: ${actBeamforming}
    Append To File   ${resultFile}   \nactCsirsMultiplexing ${actCsirsMultiplexing}
    Append To File   ${resultFile}   \nactCellCsirsTddOnSsbBf ${actCellCsirsTddOnSsbBf}
    Append To File   ${resultFile}   \nactCellCsiRsImTddNonBf ${actCellCsiRsImTddNonBf}
    Append To File   ${resultFile}   \nactAdaptiveReTxResMcs ${actAdaptiveReTxResMcs}
    Append To File   ${resultFile}   \nactEnhancedPDSCHSchSplSlot ${actEnhancedPDSCHSchSplSlot}
    Append To File   ${resultFile}   \nactAdaptiveReTxResMcs ${actAdaptiveReTxResMcs}
    Append To File   ${resultFile}   \nactEnhancedPDSCHSchSplSlot ${actEnhancedPDSCHSchSplSlot}
    # Append To File   ${resultFile}   \nnrCellType @{nrCellType}
    # Append To File   ${resultFile}   \ndlMimoMode @{dlMimoMode}
    Append To File   ${resultFile}   \nmsg1FrequencyStart @{msg1FrequencyStart}
    Append To File   ${resultFile}   \nactHighSpeedCell @{actHighSpeedCell}
    Append To File   ${resultFile}   \nulDMRSAdditionalPosition @{ulDMRSAdditionalPosition}
    Append To File   ${resultFile}   \ndlDMRSAdditionalPosition @{dlDMRSAdditionalPosition}
    Append To File   ${resultFile}   \nactUlPtrs @{actUlPtrs}
    Append To File   ${resultFile}   \nactDlPtrs @{actDlPtrs}
    Append To File   ${resultFile}   \nprachSequenceType @{prachSequenceType}\n
    Append To File   ${resultFile}   \nzeroCorrelationZoneConfig @{zeroCorrelationZoneConfig}\n


Set Frame Structure
    [Arguments]   ${nrCellId}    ${param_list}
    ${tddFrameParam}     convert to String      ${${frameStructure}_fs}
    ${tddFrameParam}     Replace String         ${tddFrameParam}           '    "
    ${tddFrameStructure}      Set Variable      NRCELL-${nrCellId}:tddFrameStructure
    Append To List       ${param_list}   delete:${tddFrameStructure}
    Append To List       ${param_list}   add:${tddFrameStructure}
    Append To List       ${param_list}   add:${tddFrameStructure}:${tddFrameParam}
    [return]  ${param_list}

Set Interfering Frame Structure
    [Arguments]   ${nrCellId}    ${param_list}
    ${infTddFrameParam}     convert to String      ${${infTddFrameStructure}_inf_fs}
    ${infTddFrameParam}     Replace String         ${infTddFrameParam}           '    "
    ${infTddFrameStructure}      Set Variable      NRCELL-${nrCellId}:infTddFrameStructure
    Append To List       ${param_list}   delete:${infTddFrameStructure}
    Append To List       ${param_list}   add:${infTddFrameStructure}
    Append To List       ${param_list}   add:${infTddFrameStructure}:${infTddFrameParam}
    log to console       \ninfTddFrameStructure : ${infTddFrameStructure}
    log to console       \ninfTddFrameParam: ${infTddFrameParam}

Compare value with current configuration
    [Arguments]  ${xml_root}  ${dist_name}  ${param_name}  ${param_value}
    ${xpath}=  set variable  .//managedObject[@distName="${dist_name}"]/p[@name="${param_name}"]
    ${value}=  XML.Get Element Text  ${xml_root}  ${xpath}
    ${status}=  run keyword and return status  should be equal    ${param_value}   ${value}
    run keyword if   not(${status})
    ...    run keywords   Append To File      ${resultFile}     \n${dist_name}/${param_name} must be set to ${param_value}
    ...      AND          set test variable   ${testCheck}      testNotOK


Init NIDD params
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!! and used by 5GC001070 60MHz
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     100MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001116_0    5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31
    set suite variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set suite variable   @{beams}     6 beams  6 beams  6 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    set suite variable   @{msg1FrequencyStart}      23      23      23
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    # short rach format if prachconfigurationidex > 87
    # issues with this settings (not attach on cell2 !!!)
    # set suite variable   @{prach}                   97      93      104
    # set suite variable   @{prach}                   97      104      104
    set suite variable   @{prach}                   9      7      104
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{prachSequenceType}       Unrestricted    Unrestricted    Unrestricted

Disable some Functionality according to CFAM
    [arguments]     ${gnb_scf}
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRBTS[0]}     actMultiDrbNSA    true
    # issue with Ul BLER (puschMappingType=TypeA + actPucchAdditionalDmrs=True) lead to 10% Ul BLER with Dss scenario!!!)
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actPucchAdditionalDmrs        true
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actPucchF3EnhanceDTX          false
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actPucchAdditionalDmrs        false
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actPucchF3EnhanceDTX          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    pucchF3MaxCodeRate            zeroDot25
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actDisableFoeProtection       false
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actBeamforming                false
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    numberOfRxBeamforming         2Rx
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actRel16DmrsForPucchF3        false
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actUlSrsBm         ${actUlSrsBm}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actDl256Qam        true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actUl256Qam        true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actDlMuMimo        false
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actLAForHiReliab    false
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actCceSplit    true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actAdaptiveReTxResMcs         ${actAdaptiveReTxResMcs}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actEnhancedPDSCHSchSplSlot    ${actEnhancedPDSCHSchSplSlot}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actPdcchSharingWithPdsch      ${actPdcchSharingWithPdsch}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    scalingStepdownHREnabled    false
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    dlMcsDowngradeForHr    disabled
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    ulMcsDowngradeForHr    disabled
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actDynUlResAlloc    false
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    dlDMRSAdditionalPosition    No additional DMRS
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actDynUlDataSplitMode    false
    # issue with Ul BLER (puschMappingType=TypeA + actPucchAdditionalDmrs=True) lead to 10% Ul BLER with Dss scenario!!!)
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}    puschMappingType    TypeA
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}    puschMappingType    TypeB
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actUlPtrs    true
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actDlMuMimo    false
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actUlMuMimo    false
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}    actDlMuMimoEnh    false
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}    ulTransPrecodePi2Bpsk    true
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRBTS[0]}     actMultiDrbNSA    true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actPucchAdditionalDmrs        false
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actPucchF3EnhanceDTX          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    pucchF3MaxCodeRate            zeroDot25
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actDisableFoeProtection       false
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actBeamforming                false
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    numberOfRxBeamforming         2Rx
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actRel16DmrsForPucchF3        false
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actUlSrsBm        ${actUlSrsBm}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actDl256Qam        true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actUl256Qam        true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actDlMuMimo        false
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actLAForHiReliab    false
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actCceSplit    true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actAdaptiveReTxResMcs         ${actAdaptiveReTxResMcs}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actEnhancedPDSCHSchSplSlot    ${actEnhancedPDSCHSchSplSlot}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actPdcchSharingWithPdsch      ${actPdcchSharingWithPdsch}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    scalingStepdownHREnabled    false
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    dlMcsDowngradeForHr    disabled
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    ulMcsDowngradeForHr    disabled
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actDynUlResAlloc    false
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    dlDMRSAdditionalPosition    No additional DMRS
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actDynUlDataSplitMode    false
    # issue with Ul BLER
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}    puschMappingType    TypeA
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}    puschMappingType    TypeB
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actUlPtrs    true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actDlMuMimo    false
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actUlMuMimo    false
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}    actDlMuMimoEnh    false
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}    ulTransPrecodePi2Bpsk    true
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

Mandatory feature activation checks
    [Arguments]    ${scf}
    ${xml_root} =   XML.parse xml   ${scf}
    set test variable  ${testCheck}  testOK
    ${nrCellId_List_length}=    Get Length    ${nrCellId_List}
    dated log      nrCellId_List_length=${nrCellId_List_length}
    ${index_cell}=    set variable     ${0}
    FOR  ${cellID}  IN   @{nrCellId_List}
        ${index_cell}=    Evaluate    ${cellID} - ${1}
        ${dist_name}=     Set Variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellID}
        Compare value with current configuration  ${xml_root}   ${dist_name}   actPucchAdditionalDmrs  true
        Compare value with current configuration  ${xml_root}   ${dist_name}   actPucchF3EnhanceDTX  false
        Compare value with current configuration  ${xml_root}   ${dist_name}   pucchF3MaxCodeRate  zeroDot25
        Compare value with current configuration  ${xml_root}   ${dist_name}   actDisableFoeProtection  false
        Compare value with current configuration  ${xml_root}   ${dist_name}   actBeamforming  true
        Compare value with current configuration  ${xml_root}   ${dist_name}   actRel16DmrsForPucchF3  false
        Compare value with current configuration  ${xml_root}   ${dist_name}   actUlSrsBm  ${actUlSrsBm[${index_cell}]}
        Compare value with current configuration  ${xml_root}   ${dist_name}   actDlSrsBm  ${actDlSrsBm[${index_cell}]}
    END
    run keyword if  '${testCheck}' == 'testNotOK'
    ...     Run Keywords     Append To File   ${resultFile}
    ...                   \n\nCheck Mandatory Config--> FAILED\nWrong Mandatory Config (UL/DL MIMO, PucchAdditionDmrs, PucchF3)\n
    ...        AND           fail   \nWrong Mandatory Config (UL/DL MIMO, PucchAdditionDmrs, PucchF3)
    Append To File   ${resultFile}   \n\nCheck Mandatory Config--> PASSED\n(UL/DL MIMO, PucchAdditionDmrs, PucchF3)\n

# Basic Reliability
Configure SCF File for subfeature BR CB012738 TDD
    Configure BWP_PDCCH
    Configure BWP_PDCCH_CONFIG_DEDICATED
    Configure NRCELL
    Configure NRBTS

# High Reliability
Configure SCF File for subfeature HR CB012738
    Configure HR BWP_PDCCH
    Configure BWP_PDCCH_CONFIG_DEDICATED
    Configure HR NRCELL
    Configure NRBTS


Configure HR BWP_PDCCH
    ${distName_PDCCH_Init}=   Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{1}/PDCCH-[0-9]+
    ${distName_PDCCH_Dedicated}=    Scenario-Common-Keywords.Get distNames from gNB SCF
    ...                                                                            regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}/PDCCH-[0-9]+
    # Initial BWP_PROFILE with ID < 10
    Set Element     dist_name=${distName_PDCCH_Init[0]}      p_name=dciDedicatedAggregationLevelHR      value=AL4
    # Dedicated BWP_PROFILE with ID >= 10
    Set Element     dist_name=${distName_PDCCH_Dedicated[0]}      p_name=alSelection      value=dynamic
    Set Element     dist_name=${distName_PDCCH_Dedicated[0]}      p_name=dciDedicatedAggregationLevelHR      value=AL4

    Set List      dist_name=${distName_PDCCH_Dedicated[0]}  list_name=dynamicAggregationLevelHRSet
    ${dynamicAggregationLevelHRSet_item}=  create dictionary
    ...    aggregationLevelListHR    AL1_AL2_AL4_AL8
    ...    cqiCorrectionUpHR         40
    ...    cqiDciCssAl1HR            ${cqiDciCssAl1HR}
    ...    cqiDciCssAl2HR            ${cqiDciCssAl2HR}
    ...    cqiDciCssAl4HR            ${cqiDciCssAl4HR}
    ...    cqiDciCssAl8HR            ${cqiDciCssAl8HR}
    ...    cqiDciCssAl16HR           0
    ...    highOlcCqiOffsetHR        1
    ...    lowOlcCqiOffsetHR         5
    ...    pCqiErasureActTimerHR     10
    ...    pCqiErasureReductionHR    50
    ...    pdcchCqiOffsetHR          0
    scf.add_item_to_list
    ...    dist_name=${distName_PDCCH_Dedicated[0]}   list_name=dynamicAggregationLevelHRSet   elements=${dynamicAggregationLevelHRSet_item}

    # scaling factor means that the value used in the script has to be divided by the factor below to get the actual value, e.g. seen in WebEM
    # cqiDciCssAl1 to cqiDciCssAl16 : scaling factor of 10
    # cqiCorrectionUp : scaling factor of 1000
    # lowOlcCqiOffset and highOlcCqiOffset : scaling factor of 100
    # pCqiErasureActReduction : scaling factor of 10
    # pdcchOffsetHR : scaling factor of 10

    Set List      dist_name=${distName_PDCCH_Dedicated[0]}  list_name=dynamicAggregationLevelSet
    ${dynamicAggregationLevelSet_item}=  create dictionary
    ...    aggregationLevelList    AL1_AL2
    ...    cqiCorrectionUp         100
    ...    cqiDciCssAl1            10
    ...    cqiDciCssAl2            10
    ...    cqiDciCssAl4            10
    ...    cqiDciCssAl8            10
    ...    cqiDciCssAl16           10
    ...    highOlcCqiOffset        200
    ...    lowOlcCqiOffset         1000
    ...    pCqiErasureActTimer     1000
    ...    pCqiErasureReduction    100
    # INFO:
    # If both PDCCH.dynamicAggregationLevelHRSet.pCqiErasureActTimerHR and PDCCH.dynamicAggregationLevelSet.pCqiErasureActTimer
    # are not equal to 0, then PDCCH.dynamicAggregationLevelHRSet.pCqiErasureActTimerHR shall be less than or equal
    # to PDCCH.dynamicAggregationLevelSet.pCqiErasureActTimer.
    scf.add_item_to_list
    ...    dist_name=${distName_PDCCH_Dedicated[0]}   list_name=dynamicAggregationLevelSet   elements=${dynamicAggregationLevelSet_item}

Configure BWP_PDCCH
    [arguments]     ${gnb_scf}
    # @{distName_PDCCH_Init}=  Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{1}/PDCCH-[0-9]+
    # @{distName_PDCCH_Dedicated}=  Scenario-Common-Keywords.Get distNames from gNB SCF
    # ...                                                                           regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}/PDCCH-[0-9]+

    ${distName_PDCCH_Init}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                           regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{1}/PDCCH-[0-9]+
    ${distName_PDCCH_Dedicated}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...                                                                           regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}/PDCCH-[0-9]+
    # Initial BWP_PROFILE with ID < 10
    FOR    ${dist_name}    IN    @{distName_PDCCH_Init}
        Set Element     dist_name=${dist_name}      p_name=dciDedicatedAggregationLevelHR      value=AL4
    END

    # Dedicated BWP_PROFILE with ID >= 10
    FOR    ${dist_name}    IN    @{distName_PDCCH_Dedicated}
        Set Element     dist_name=${dist_name}      p_name=alSelection      value=dynamic
        Set Element     dist_name=${dist_name}      p_name=dciDedicatedAggregationLevelHR      value=AL4

        ${list_exist}=            scf.is_list_in_object  dist_name=${dist_name}  list_name=dynamicAggregationLevelHRSet
        run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${dist_name}  list_name=dynamicAggregationLevelHRSet
        Set List      dist_name=${dist_name}  list_name=dynamicAggregationLevelHRSet
        &{dynamicAggregationLevelHRSet_item}=  create dictionary
        ...    aggregationLevelListHR    AL1_AL2_AL4_AL8
        ...    cqiCorrectionUpHR         40
        ...    cqiDciCssAl1HR            ${cqiDciCssAl1HR}
        ...    cqiDciCssAl2HR            ${cqiDciCssAl2HR}
        ...    cqiDciCssAl4HR            ${cqiDciCssAl4HR}
        ...    cqiDciCssAl8HR            ${cqiDciCssAl8HR}
        ...    cqiDciCssAl16HR           0
        ...    highOlcCqiOffsetHR        1
        ...    lowOlcCqiOffsetHR         5
        ...    pCqiErasureActTimerHR     10
        ...    pCqiErasureReductionHR    50
        ...    pdcchCqiOffsetHR          0
        scf.add_item_to_list
        ...    dist_name=${dist_name}   list_name=dynamicAggregationLevelHRSet   elements=${dynamicAggregationLevelHRSet_item}

        ${list_exist}=            scf.is_list_in_object  dist_name=${dist_name}  list_name=dynamicAggregationLevelSet
        run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${dist_name}  list_name=dynamicAggregationLevelSet
        Set List      dist_name=${dist_name}  list_name=dynamicAggregationLevelSet
        &{dynamicAggregationLevelSet_item}=  create dictionary
        ...    aggregationLevelList    AL1_AL2_AL4_AL8
        ...    cqiCorrectionUp         8
        ...    cqiDciCssAl1            ${cqiDciCssAl1}
        ...    cqiDciCssAl2            ${cqiDciCssAl2}
        ...    cqiDciCssAl4            ${cqiDciCssAl4}
        ...    cqiDciCssAl8            ${cqiDciCssAl8}
        ...    cqiDciCssAl16           0
        ...    highOlcCqiOffset        100
        ...    lowOlcCqiOffset         1100
        ...    pCqiErasureActTimer     160
        ...    pCqiErasureReduction    10

        scf.add_item_to_list
        ...    dist_name=${dist_name}   list_name=dynamicAggregationLevelSet   elements=${dynamicAggregationLevelSet_item}
    END

Configure HR NRCELL
    ${distName_NRCELL}=     Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    FOR  ${cell}  IN  @{distName_NRCELL}
        Set Element    dist_name=${cell}     p_name=actLAForHiReliab           value=true
        Set Element    dist_name=${cell}     p_name=scalingStepdownHREnabled   value=true
        Set Element    dist_name=${cell}     p_name=actCceSplit                value=false
        Set Element    dist_name=${cell}     p_name=dlMcsDowngradeForHr        value=disabled
        Set Element    dist_name=${cell}     p_name=ulMcsDowngradeForHr        value=disabled

        # default values
        ${list_exist}=            scf.is_list_in_object  dist_name=${cell}  list_name=puschHrLaConfig
        run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${cell}  list_name=puschHrLaConfig
        Set List      dist_name=${cell}  list_name=puschHrLaConfig
        ${puschHrLaConfig_item}=  create dictionary
        ...    iniDeltaSinrHR            -50
        ...    ullaDeltaSinrMaxHR        150
        ...    ullaDeltaSinrMinHR        -300
        ...    ullaDeltaSinrStepdownHR   2000
        ...    ullaIniMcsHR              0
        ...    ullaSinrOffsetHR          20
        ...    ullaMcsMax64qamLowSERANK1HR  25
        ...    ullaMcsMax64qamLowSERANK2HR  25
        ...    ullaMcsMax64qamRANK1HR    25
        ...    ullaMcsMax64qamRANK2HR    25
        ...    ullaSinrOffsetHR          20
        scf.add_item_to_list    dist_name=${cell}   list_name=puschHrLaConfig   elements=${puschHrLaConfig_item}

        # default values
        ${list_exist}=            scf.is_list_in_object  dist_name=${cell}  list_name=pdschHrLaConfig
        run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${cell}  list_name=pdschHrLaConfig
        Set List      dist_name=${cell}  list_name=pdschHrLaConfig
        ${pdschHrLaConfig_item}=  create dictionary
        ...    dllaCqiOffsetHR          0
        ...    dllaDeltaCqiMaxHR        150
        ...    dllaDeltaCqiMinHR        -150
        ...    dllaDeltaCqiStepdownHR   2000
        ...    dllaIniDeltaCqiHR        -50
        ...    dllaIniMcsHR             3
        ...    dllaMcsMax64qamLowSERANK1HR  25
        ...    dllaMcsMax64qamLowSERANK2HR  25
        ...    dllaMcsMax64qamLowSERANK3HR  20
        ...    dllaMcsMax64qamLowSERANK4HR  20
        ...    dllaMcsMax64qamRANK1HR   25
        ...    dllaMcsMax64qamRANK2HR   25
        ...    dllaMcsMax64qamRANK3HR   20
        ...    dllaMcsMax64qamRANK4HR   20
        scf.add_item_to_list    dist_name=${cell}   list_name=pdschHrLaConfig   elements=${pdschHrLaConfig_item}

        ${distName_BWP_Init_tmp}=     Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{1}/
        ${distName_BWP_Init}=    Get Substring    ${distName_BWP_Init_tmp[0]}    0    -1
        ${distName_BWP_Dedicated}=    Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}

        ${list_exist}=            scf.is_list_in_object  dist_name=${cell}  list_name=cellBwpList
        run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${cell}  list_name=cellBwpList
        Set List      dist_name=${cell}  list_name=cellBwpList
        ${cellBwpList_item1}=  create dictionary
        ...    actPdcchCceFragmentControl   false
        ...    actUpperThrAckNackFiltering  true
        ...    actUpperThrAckNackHrFiltering  true
        ...    bwpDN                        ${distName_BWP_Init}
        ...    cellBwpId                    0
        ...    pdcchResourcePreference      peakRate
        scf.add_item_to_list    dist_name=${cell}   list_name=cellBwpList   elements=${cellBwpList_item1}

        ${cellBwpList_item2}=  create dictionary
        ...    actPdcchCceFragmentControl   false
        ...    actUpperThrAckNackFiltering  true
        ...    actUpperThrAckNackHrFiltering  true
        ...    bwpDN            ${distName_BWP_Dedicated[0]}
        ...    cellBwpId        1
        ...    pdcchResourcePreference     peakRate
        scf.add_item_to_list    dist_name=${cell}   list_name=cellBwpList   elements=${cellBwpList_item2}

        # default values
        ${list_exist}=            scf.is_list_in_object  dist_name=${cell}  list_name=dlDataDmrsFdm
        run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${cell}  list_name=dlDataDmrsFdm
        Set List      dist_name=${cell}  list_name=dlDataDmrsFdm
        ${dlDataDmrsFdm_item}=  create dictionary
        ...    actDlDataDmrsFdm                 true
        ...    dlDataDmrsFdmThres256QamMcs      27
        ...    dlDataDmrsFdmThres64QamLowSEMcs  20
        ...    dlDataDmrsFdmThres64QamMcs       28
        ...    redCap1RxUesEnabled              false
        ...    thres256QamMcsRedCap1Rx          20
        scf.add_item_to_list    dist_name=${cell}   list_name=dlDataDmrsFdm   elements=${dlDataDmrsFdm_item}

        # default values
        ${list_exist}=            scf.is_list_in_object  dist_name=${cell}  list_name=ulDataDmrsFdm
        run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${cell}  list_name=ulDataDmrsFdm
        Set List      dist_name=${cell}  list_name=ulDataDmrsFdm
        ${ulDataDmrsFdm_item}=  create dictionary
        ...    actUlDataDmrsFdm                 true
        ...    ulDataDmrsFdmThres256QamMcs      27
        ...    ulDataDmrsFdmThres64QamLowSEMcs  20
        ...    ulDataDmrsFdmThres64QamMcs       28
        scf.add_item_to_list    dist_name=${cell}   list_name=ulDataDmrsFdm   elements=${ulDataDmrsFdm_item}
    END

Configure NRCELL
    ${distName_NRCELL}=     Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    FOR  ${cell}  IN  @{distName_NRCELL}
        Set Element    dist_name=${cell}     p_name=actLAForHiReliab           value=false
        Set Element    dist_name=${cell}     p_name=scalingStepdownHREnabled   value=false
        Set Element    dist_name=${cell}     p_name=actCceSplit                value=false
        Set Element    dist_name=${cell}     p_name=dlMcsDowngradeForHr        value=disabled
        Set Element    dist_name=${cell}     p_name=ulMcsDowngradeForHr        value=disabled

        # default values
        ${list_exist}=            scf.is_list_in_object  dist_name=${cell}  list_name=puschHrLaConfig
        run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${cell}  list_name=puschHrLaConfig
        Set List      dist_name=${cell}  list_name=puschHrLaConfig
        ${puschHrLaConfig_item}=  create dictionary
        ...    iniDeltaSinrHR            -50
        ...    ullaDeltaSinrMaxHR        150
        ...    ullaDeltaSinrMinHR        -300
        ...    ullaDeltaSinrStepdownHR   2000
        ...    ullaIniMcsHR              0
        ...    ullaSinrOffsetHR          20
        ...    ullaMcsMax64qamLowSERANK1HR  25
        ...    ullaMcsMax64qamLowSERANK2HR  25
        ...    ullaMcsMax64qamRANK1HR    25
        ...    ullaMcsMax64qamRANK2HR    25
        ...    ullaSinrOffsetHR          20
        scf.add_item_to_list    dist_name=${cell}   list_name=puschHrLaConfig   elements=${puschHrLaConfig_item}

        # default values
        ${list_exist}=            scf.is_list_in_object  dist_name=${cell}  list_name=pdschHrLaConfig
        run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${cell}  list_name=pdschHrLaConfig
        Set List      dist_name=${cell}  list_name=pdschHrLaConfig
        ${pdschHrLaConfig_item}=  create dictionary
        ...    dllaCqiOffsetHR          0
        ...    dllaDeltaCqiMaxHR        150
        ...    dllaDeltaCqiMinHR        -150
        ...    dllaDeltaCqiStepdownHR   2000
        ...    dllaIniDeltaCqiHR        -50
        ...    dllaIniMcsHR             3
        ...    dllaMcsMax64qamLowSERANK1HR  25
        ...    dllaMcsMax64qamLowSERANK2HR  25
        ...    dllaMcsMax64qamLowSERANK3HR  20
        ...    dllaMcsMax64qamLowSERANK4HR  20
        ...    dllaMcsMax64qamRANK1HR   25
        ...    dllaMcsMax64qamRANK2HR   25
        ...    dllaMcsMax64qamRANK3HR   20
        ...    dllaMcsMax64qamRANK4HR   20
        scf.add_item_to_list    dist_name=${cell}   list_name=pdschHrLaConfig   elements=${pdschHrLaConfig_item}

        ${distName_BWP_Init_tmp}=     Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{1}/
        ${distName_BWP_Init}=    Get Substring    ${distName_BWP_Init_tmp[0]}    0    -1
        ${distName_BWP_Dedicated}=    Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}

        ${list_exist}=            scf.is_list_in_object  dist_name=${cell}  list_name=cellBwpList
        run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${cell}  list_name=cellBwpList
        Set List      dist_name=${cell}  list_name=cellBwpList
        ${cellBwpList_item1}=  create dictionary
        ...    actPdcchCceFragmentControl   false
        ...    actUpperThrAckNackFiltering  true
        ...    actUpperThrAckNackHrFiltering  true
        ...    bwpDN                        ${distName_BWP_Init}
        ...    cellBwpId                    0
        ...    pdcchResourcePreference      peakRate
        scf.add_item_to_list    dist_name=${cell}   list_name=cellBwpList   elements=${cellBwpList_item1}

        ${cellBwpList_item2}=  create dictionary
        ...    actPdcchCceFragmentControl   false
        ...    actUpperThrAckNackFiltering  true
        ...    actUpperThrAckNackHrFiltering  true
        ...    bwpDN            ${distName_BWP_Dedicated[0]}
        ...    cellBwpId        1
        ...    pdcchResourcePreference     peakRate
        scf.add_item_to_list    dist_name=${cell}   list_name=cellBwpList   elements=${cellBwpList_item2}

        # default values
        ${list_exist}=            scf.is_list_in_object  dist_name=${cell}  list_name=dlDataDmrsFdm
        run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${cell}  list_name=dlDataDmrsFdm
        Set List      dist_name=${cell}  list_name=dlDataDmrsFdm
        ${dlDataDmrsFdm_item}=  create dictionary
        ...    actDlDataDmrsFdm                 true
        ...    dlDataDmrsFdmThres256QamMcs      27
        ...    dlDataDmrsFdmThres64QamLowSEMcs  20
        ...    dlDataDmrsFdmThres64QamMcs       28
        ...    redCap1RxUesEnabled              false
        ...    thres256QamMcsRedCap1Rx          20
        scf.add_item_to_list    dist_name=${cell}   list_name=dlDataDmrsFdm   elements=${dlDataDmrsFdm_item}

        # default values
        ${list_exist}=            scf.is_list_in_object  dist_name=${cell}  list_name=ulDataDmrsFdm
        run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${cell}  list_name=ulDataDmrsFdm
        Set List      dist_name=${cell}  list_name=ulDataDmrsFdm
        ${ulDataDmrsFdm_item}=  create dictionary
        ...    actUlDataDmrsFdm                 true
        ...    ulDataDmrsFdmThres256QamMcs      27
        ...    ulDataDmrsFdmThres64QamLowSEMcs  20
        ...    ulDataDmrsFdmThres64QamMcs       28
        scf.add_item_to_list    dist_name=${cell}   list_name=ulDataDmrsFdm   elements=${ulDataDmrsFdm_item}
    END

Configure NRBTS
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRPDSCHHRLA    dist_name=${dist_name}    version=NRBTSCL23R2_2302_100
    # add default values
    FOR   ${p_name}              ${value}      IN
    ...   dlHRBlerOutageMcsThresh64qam          3
    ...   dlHRBlerOutageMcsThresh64qamLowSE     0
    ...   dlHRBlerOutagePercentage              90
    ...   dlHRBlerOutagePeriod                  20
    ...   dlHRBlerRecoverMcsThresh64qam         5
    ...   dlHRBlerRecoverMcsThresh64qamLowSE    1
    ...   dlHRBlerRecoverPercentage             10
    ...   dlHRBlerRecoverPeriod                 30
    ...   dllaBlerTargetHR                      10
    ...   scalFactorForHRGbrDl                  110
            scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRPUSCHHRLA    dist_name=${dist_name}    version=NRBTSCL23R2_2302_100
    # add default values
    FOR   ${p_name}              ${value}      IN
    ...   scalFactorForHRGbrUl             110
    ...   ulHRBlerOutagePercentage         90
    ...   ulHRBlerOutagePeriod             20
    ...   ulHRBlerOutageTbsThresh          808
    ...   ulHRBlerOutageTbsThresh64qam     1000
    ...   ulHRBlerRecoverPercentage        60
    ...   ulHRBlerRecoverPeriod            30
    ...   ulHRBlerRecoverTbsThresh         10000
    ...   ulHRBlerRecoverTbsThresh64qam    7000
    ...   ullaBlerTargetHR                 10
            scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
    scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRPDCCHHRLA    dist_name=${dist_name}    version=NRBTSCL23R2_2302_100
    # add default values
    FOR   ${p_name}     ${value}    IN
    ...   nrPdcchHRLaId                     1
    ...   pdcchHRBlerOutagePercentage       90
    ...   pdcchHRBlerOutagePeriod           20
    ...   pdcchHRBlerRecoverPercentage      60
            scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

    ${distName_NRDRB}=     Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDRB-11
    FOR  ${dist_name}  IN   @{distName_NRDRB}
        Set Element    dist_name=${dist_name}     p_name=nrPdschHRLaDN    value=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
        Set Element    dist_name=${dist_name}     p_name=nrPdcchHRLaDN    value=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
        Set Element    dist_name=${dist_name}     p_name=nrPuschHRLaDN    value=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
    END

Configure SCF File for subfeature CB007090
    ${distName_NRCELL}=     gnb.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-1
    ${distName_BWP_Init_tmp}=     gnb.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{1}/
    ${distName_BWP_Init}=    Get Substring    ${distName_BWP_Init_tmp[0]}    0    -1
    ${distName_BWP_Dedicated}=    gnb.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}

    Set Element   dist_name=${distName_NRCELL[0]}   p_name=actDynPdcchTdMode   value=largestBWP

    Set List      dist_name=${distName_NRCELL[0]}  list_name=cellBwpList
    ${cellBwpList_item1}=  create dictionary
    ...    actPdcchCceFragmentControl   false
    ...    actUpperThrAckNackFiltering  false
    ...    actUpperThrAckNackHrFiltering  false
    ...    bwpDN                        ${distName_BWP_Init}
    ...    cellBwpId                    0
    ...    pdcchResourcePreference      peakRate
    scf.add_item_to_list    dist_name=${distName_NRCELL[0]}   list_name=cellBwpList   elements=${cellBwpList_item1}

    ${cellBwpList_item2}=  create dictionary
    ...    actPdcchCceFragmentControl   false
    ...    actUpperThrAckNackFiltering  false
    ...    actUpperThrAckNackHrFiltering  false
    ...    bwpDN            ${distName_BWP_Dedicated[0]}
    ...    cellBwpId        1
    ...    pdcchBlockingThresholdDL    30
    ...    pdcchBlockingThresholdUL    30
    ...    pdcchFreeThresholdDL        50
    ...    pdcchFreeThresholdUL        50
    ...    pdcchResourcePreference     peakRate
    scf.add_item_to_list    dist_name=${distName_NRCELL[0]}   list_name=cellBwpList   elements=${cellBwpList_item2}


#    ----------SCF changes for BW configuration--------------------------------------------------------------------------------------[150 characters]

#FDD case
Modify dynamic pdcch parameters for 20MHz bandwidth
    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=NRBTS-\\d+/NRCELL-3
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-4    dist_name=${distName_NRCELL[0]}
    ...    p_name=bwpDN    list_name=cellBwpList    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    p_name=cellBwpId    list_name=cellBwpList    index=0
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-33    dist_name=${distName_NRCELL[0]}
    ...    p_name=bwpDN    list_name=cellBwpList    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    p_name=cellBwpId    list_name=cellBwpList    index=1

#TDD case
Modify dynamic pdcch parameters for 100MHz bandwidth
    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=NRBTS-\\d+/NRCELL-1
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-0    dist_name=${distName_NRCELL[0]}
    ...    p_name=bwpDN    list_name=cellBwpList    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    p_name=cellBwpId    list_name=cellBwpList    index=0
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-44    dist_name=${distName_NRCELL[0]}
    ...    p_name=bwpDN    list_name=cellBwpList    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    p_name=cellBwpId    list_name=cellBwpList    index=1
    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    MRBTS-1/NRBTS-1/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    scf.modify scf element    value=192    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size

Modify dynamic pdcch parameters for 40MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${object_BWP_PROFILE-9_exists}=    scf.is object in scf    dist_name=NRBTS-1/BWP_PROFILE-9
    Run keyword if    not ${object_BWP_PROFILE-9_exists}    Update BWP_PROFILE objects for 40MHz bandwidth    gnb_id=${gnb_id}

    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-1/NRCELL-1    gnb_id=${gnb_id}
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-9    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=0
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-30    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=1

Modify dynamic pdcch parameters for TDD 20MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${object_BWP_PROFILE-8_exists}=    scf.is object in scf    dist_name=NRBTS-1/BWP_PROFILE-8
    Run keyword if    not ${object_BWP_PROFILE-8_exists}    Update BWP_PROFILE objects for TDD 20MHz bandwidth    gnb_id=${gnb_id}

    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-1/NRCELL-1    gnb_id=${gnb_id}
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-8    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=0
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-31    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=1

Modify dynamic pdcch parameters for TDD 90MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${object_BWP_PROFILE-10_exists}=    scf.is object in scf    dist_name=NRBTS-1/BWP_PROFILE-10
    Run keyword if    not ${object_BWP_PROFILE-10_exists}    Update BWP_PROFILE objects for TDD 90MHz bandwidth    gnb_id=${gnb_id}

    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-1/NRCELL-1    gnb_id=${gnb_id}
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-10    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=0
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-35    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=1

Modify dynamic pdcch parameters for TDD 10MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${object_BWP_PROFILE-1_exists}=    scf.is object in scf    dist_name=NRBTS-1/BWP_PROFILE-1
    Run keyword if    not ${object_BWP_PROFILE-1_exists}    Update BWP_PROFILE objects for TDD 10MHz bandwidth    gnb_id=${gnb_id}

    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-1/NRCELL-1    gnb_id=${gnb_id}
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=0
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-11    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=1

Update BWP_PROFILE objects for 40MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-0    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-9
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-44    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-30
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    scf.modify scf element    value=96    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL4
    scf.modify scf element    value=n1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL8
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL1
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL2
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL4
    scf.modify scf element    value=n1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL8

Update BWP_PROFILE objects for TDD 10MHz bandwidth_version1
    [Arguments]    ${gnb_id}=${0}
    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-0    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-1
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-44    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-11
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    scf.modify scf element    value=24    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size

    scf.modify scf element    value=0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=coresetId
    scf.modify scf element    value=formats0-0-And-1-0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=dciFormat
    scf.modify scf element    value=39    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=duration
    scf.modify scf element    value=symbol_0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=n0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL1
    scf.modify scf element    value=n4    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL2
    scf.modify scf element    value=n3    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL4
    scf.modify scf element    value=n1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL8
    scf.modify scf element    value=Type3    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=searchSpaceType

    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=coresetId
    scf.modify scf element    value=formats0-0-And-1-0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=dciFormat
    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=duration
    scf.modify scf element    value=symbol_0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=n0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL1
    scf.modify scf element    value=n4    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL2
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL4
    scf.modify scf element    value=n1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL8
    scf.modify scf element    value=UE-Specific    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=searchSpaceType

Remove Object with Log
    [Arguments]      ${dist_name}   ${padding}=${4}
    ${object_exist}    scf.is_object_in_scf    dist_name=${dist_name}
    run keyword if    ${object_exist}    scf.remove_mo_with_descendant_mos    dist_name=${dist_name}
    ${msg}    Format String    {: >${padding}}- Reset {}      ${EMPTY}    ${dist_name}
    run keyword if    ${object_exist}    BuiltIn.Log    ${msg}    console=True

Remove List with Log
    [Arguments]      ${dist_name}   ${list_name}    ${padding}=${4}
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}         list_name=${list_name}
    Run Keyword if            ${list_exist}             scf.remove_list_from_scf       dist_name=${dist_name}        list_name=${list_name}
    ${msg}    Format String    {: >${padding}}- Reset {}      ${EMPTY}    ${dist_name}/${list_name}
    BuiltIn.Log    ${msg}    console=True
    # Set Suite Variable    $GNB_SCF_IS_MODIFIED    ${TRUE}

Set List with Log
    [Arguments]      ${dist_name}   ${list_name}    ${padding}=${4}
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}         list_name=${list_name}
    Run Keyword if            ${list_exist}             scf.remove_list_from_scf       dist_name=${dist_name}        list_name=${list_name}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=${list_name}
    ${msg}    Format String    {: >${padding}}- Reset {}      ${EMPTY}    ${dist_name}/${list_name}
    BuiltIn.Log    ${msg}    console=True
    # Set Suite Variable    $GNB_SCF_IS_MODIFIED    ${TRUE}

Add Dict to List
    [Arguments]    ${dist_name}    ${list_name}    ${elements}    ${padding}=${4}
    ${msg}    Format String    {: >${padding}}- Add to list {}:     ${EMPTY}    ${dist_name}/${list_name}
    BuiltIn.Log    ${msg}    console=True
    FOR    ${key}    IN    @{elements}
        ${status}   ${readValue}   Run Keyword And Ignore Error   scf.get_value_from_scf
        ...                                                       dist_name=${dist_name}
        ...                                                       list_name=${list_name}
        ...                                                       p_name=${key}
        ${readValue}    Set Variable if     "${status}"=="PASS"    ${readValue}    ${empty}

        ${msg}    Format String    {: >${padding+4}}- Set {} to {} {}     ${EMPTY}    ${dist_name}/${list_name}/${key}
        ...                                                               ${elements['${key}']}    (orig.: ${readValue})
        BuiltIn.Log    ${msg}    console=True
    END
    scf.add_item_to_list  dist_name=${dist_name}  list_name=${list_name}  elements=${elements}

Set List Value
    [Arguments]      ${dist_name}    ${list_name}    ${value}    ${p_name}=${none}    ${padding}=${4}
    BuiltIn.Log    dist_name:${dist_name}, list_name:${list_name}, value:${value}, p_name:${p_name}    console=False    level=DEBUG
    ${list_exist}=            scf.is_list_in_object  dist_name=${dist_name}     list_name=${list_name}

    Run Keyword IF         not ${list_exist}
    ...    Run Keywords    BuiltIn.Log    [Set List Value Failed] list_name:${dist_name}, list_name:${list_name}, value:${value}, p_name:${p_name}
    ...                    level=WARN
    ...    AND             Return from keyword    ${none}

    ${status}   ${readValue}   Run Keyword And Ignore Error   scf.get_all_values_from_scf
    ...                                                       dist_name=${dist_name}    list_name=${list_name}
    ...                                                       p_name=${p_name}
    ${readValue}    Set Variable if     "${status}"=="PASS"    ${readValue}    ${empty}

    scf.modify_scf_element    dist_name=${dist_name}    list_name=${list_name}    p_name=${p_name}     value=${value}

    ${msg}    Format String    {: >${padding}}- Set {} to {} {}    ${EMPTY}    ${dist_name}/${list_name}/${p_name}
    ...                                                            ${value}    (orig.: ${readValue})
    BuiltIn.Log    ${msg}    console=True

Update BWP_PROFILE objects for TDD 10MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-0    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-1
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_COMMON}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    scf.modify scf element    value=5    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=duration
    scf.modify scf element    value=sl10  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=periodicity
    scf.modify scf element    value=5    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=duration
    scf.modify scf element    value=sl10  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=periodicity

    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-44    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-11
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_COMMON}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    scf.modify scf element    value=5    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=duration
    scf.modify scf element    value=sl10  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=periodicity
    scf.modify scf element    value=5    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=duration
    scf.modify scf element    value=sl10  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=periodicity

    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    scf.modify scf element    value=24    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size
    scf.modify scf element    value=2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=duration

    Set List with Log   dist_name=${distName_PDCCH_CONFIG_DEDICATED}   list_name=searchSpaceDedicated
    ${searchSpaceDedicated_item1}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     39
    ...      monitoringSymbolWithinSlot   symbol_0
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n3
    ...      numOfPdcchCandidatesInAL8    n1
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl40
    ...      searchSpaceId                7
    ...      searchSpaceType              Type3
    ...      slotOffset                   1
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item1}
    ${searchSpaceDedicated_item2}=  Create Dictionary
    ...      coresetId                    1
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_0
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n1
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl40
    ...      searchSpaceId                8
    ...      searchSpaceType              Type3
    ...      slotOffset                   0
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item2}
    ${searchSpaceDedicated_item3}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     39
    ...      monitoringSymbolWithinSlot   symbol_0
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n3
    ...      numOfPdcchCandidatesInAL8    n1
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl40
    ...      searchSpaceId                9
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   1
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item3}
    ${searchSpaceDedicated_item4}=  Create Dictionary
    ...      coresetId                    1
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_0
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n1
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl40
    ...      searchSpaceId                10
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   0
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item4}



Update BWP_PROFILE objects for TDD 20MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-0    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-8
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-44    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-31
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    scf.modify scf element    value=48    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL4
    scf.modify scf element    value=n1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL8
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL1
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL2
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL4
    scf.modify scf element    value=n1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL8

Update BWP_PROFILE objects for TDD 90MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-0    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-10
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-44    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-35
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    scf.modify scf element    value=192    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL4
    scf.modify scf element    value=n0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL8
    scf.modify scf element    value=n0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL1
    scf.modify scf element    value=n4    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL2
    scf.modify scf element    value=n3    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL4
    scf.modify scf element    value=n0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL8

Modify scf.xml for 2TDD+2FDD Setup with Cell1 TDD 40MHz
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  78
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                chBw                               40MHz
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                nrarfcn                              531000
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_2}
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  78
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                chBw                                 40MHz
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                nrarfcn                              368500
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Modify dynamic pdcch parameters for 40MHz bandwidth
    ${param_list}    Create List
    ${scf_modifs}    create list
    ...    modify:NRCELL-${fdd_cell_1}:srsForBeamMgmt:cSRS=${cSRS['40MHz']}
    Append To List       ${param_list}     @{scf_modifs}
    scf.perform_scf_modification    modification_strings=${param_list}

Modify scf.xml for 2TDD+2FDD Setup with Cell1 TDD 10MHz
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    # BEWARE that for 10MHz Tdd BW , type0CoresetConfigurationIndex = 5 setting which maps to coreset0 duration = 3
    # with coreset0 duration = 3, dmrsTypeAPostion shall be "pos3"
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                dmrsTypeAPosition                    pos3
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  41
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                chBw                                 10MHz
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                nrarfcn                              519000
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0CoresetConfigurationIndex       5
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0SearchSpaceConfigurationIndex   4
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                msg1FrequencyStart                   7
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1    p_name=prodCodePlanned    value=475124A
    Modify dynamic pdcch parameters for TDD 10MHz bandwidth
    # ${param_list}    Create List
    # ${scf_modifs}    create list
    # ...    modify:NRCELL-${fdd_cell_1}:srsForBeamMgmt:cSRS=${cSRS['10MHz']}
    # Append To List       ${param_list}     @{scf_modifs}
    # scf.perform_scf_modification    modification_strings=${param_list}

Modify scf.xml for 2TDD+2FDD Setup with Cell1 TDD 20MHz
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  78
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                chBw                               20MHz
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                nrarfcn                              531000
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_2}
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  78
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                chBw                                 40MHz
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                nrarfcn                              368500
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Modify dynamic pdcch parameters for TDD 20MHz bandwidth
    ${param_list}    Create List
    ${scf_modifs}    create list
    ...    modify:NRCELL-${fdd_cell_1}:srsForBeamMgmt:cSRS=${cSRS['20MHz']}
    Append To List       ${param_list}     @{scf_modifs}
    scf.perform_scf_modification    modification_strings=${param_list}

Modify scf.xml for 2TDD+2FDD Setup with Cell1 TDD 90MHz
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  78
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                chBw                               90MHz
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                nrarfcn                              531000
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_2}
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  78
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                chBw                                 40MHz
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                nrarfcn                              368500
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Modify dynamic pdcch parameters for TDD 90MHz bandwidth
    ${param_list}    Create List
    ${scf_modifs}    create list
    ...    modify:NRCELL-${fdd_cell_1}:srsForBeamMgmt:cSRS=${cSRS['90MHz']}
    Append To List       ${param_list}     @{scf_modifs}
    scf.perform_scf_modification    modification_strings=${param_list}

Modify scf.xml for 2TDD+2FDD Setup with Cell1 TDD 100MHz
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  78
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                chBw                               100MHz
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                nrarfcn                              531000
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_2}
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  78
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                chBw                                 40MHz
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                nrarfcn                              368500
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Modify dynamic pdcch parameters for 100MHz bandwidth

#    ----------SCF changes for MultiBWP----------------------------------------------------------------------------------------------[150 characters]
Modify scf.xml for 2TDD+2FDD Setup with Cell1 TDD 40MHz version 1
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  78
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                chBw                               40MHz
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                nrarfcn                              531000
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_2}
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  78
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                chBw                                 40MHz
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                nrarfcn                              368500
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-0    list_name=locationAndBandwidthDl
    ${locationAndBandwidthDl}=  create dictionary
    ...    cRbSizeDl             n106
    ...    cRbStartDl            crb0
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-0    list_name=locationAndBandwidthDl   elements=${locationAndBandwidthDl}
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-0    list_name=locationAndBandwidthUl
    ${locationAndBandwidthUl}=  create dictionary
    ...    cRbSizeUl             sameAsDl
    ...    cRbStartUl            sameAsDl
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-0    list_name=locationAndBandwidthUl   elements=${locationAndBandwidthUl}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-44    list_name=locationAndBandwidthDl
    ${locationAndBandwidthDl}=  create dictionary
    ...    cRbSizeDl             n106
    ...    cRbStartDl            crb0
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-44    list_name=locationAndBandwidthDl   elements=${locationAndBandwidthDl}
    Set List      dist_name=${distName_NRBTS[0]}/BWP_PROFILE-44    list_name=locationAndBandwidthUl
    ${locationAndBandwidthUl}=  create dictionary
    ...    cRbSizeUl             sameAsDl
    ...    cRbStartUl            sameAsDl
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-44    list_name=locationAndBandwidthUl   elements=${locationAndBandwidthUl}

Modify scf.xml for 2TDD+2FDD Setup for Cell1 TDD 20MHz
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  78
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                chBw                                 20MHz
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}              nrarfcn                              531000
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_2}
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  78
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                chBw                                 50MHz
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                nrarfcn                              368500
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-0    list_name=locationAndBandwidthDl
    ${locationAndBandwidthDl}=  create dictionary
    ...    cRbSizeDl             n106
    ...    cRbStartDl            crb0
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-0    list_name=locationAndBandwidthDl   elements=${locationAndBandwidthDl}
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-0    list_name=locationAndBandwidthUl
    ${locationAndBandwidthUl}=  create dictionary
    ...    cRbSizeUl             sameAsDl
    ...    cRbStartUl            sameAsDl
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-0    list_name=locationAndBandwidthUl   elements=${locationAndBandwidthUl}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-44    list_name=locationAndBandwidthDl
    ${locationAndBandwidthDl}=  create dictionary
    ...    cRbSizeDl             n106
    ...    cRbStartDl            crb0
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-44    list_name=locationAndBandwidthDl   elements=${locationAndBandwidthDl}
    Set List      dist_name=${distName_NRBTS[0]}/BWP_PROFILE-44    list_name=locationAndBandwidthUl
    ${locationAndBandwidthUl}=  create dictionary
    ...    cRbSizeUl             sameAsDl
    ...    cRbStartUl            sameAsDl
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-44    list_name=locationAndBandwidthUl   elements=${locationAndBandwidthUl}

Modify scf.xml for 2TDD+2FDD Setup with Cell2 TDD 80MHz
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_2}
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  78
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                chBw                               80MHz
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                nrarfcn                              531000
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_2}
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  78
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                chBw                                 40MHz
    # ...    ${distName_NRCELL[${fdd_cell_2}-1]}                nrarfcn                              368500
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Modify dynamic pdcch parameters for TDD 80MHz bandwidth
    # srsForBeamMgmt is deasctivated - actUlSrsBM = false
    # ${param_list}    Create List
    # ${scf_modifs}    create list
    # ...    modify:NRCELL-${fdd_cell_2}:srsForBeamMgmt:cSRS=${cSRS['80MHz']}
    # Append To List       ${param_list}     @{scf_modifs}
    # scf.perform_scf_modification    modification_strings=${param_list}


Modify dynamic pdcch parameters for TDD 80MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${object_BWP_PROFILE-6_exists}=    scf.is object in scf    dist_name=NRBTS-1/BWP_PROFILE-6
    Run keyword if    not ${object_BWP_PROFILE-6_exists}    Update BWP_PROFILE objects for TDD 80MHz bandwidth    gnb_id=${gnb_id}

    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-1/NRCELL-2    gnb_id=${gnb_id}
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-6    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=0
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-36    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=1

Update BWP_PROFILE objects for TDD 80MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-0    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-6
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-44    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-36
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    scf.modify scf element    value=192    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL4
    scf.modify scf element    value=n1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL8
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL1
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL2
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL4
    scf.modify scf element    value=n1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL8

Modify scf.xml for 2TDD+2FDD Setup with Cell3 TDD 60MHz
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_3}
    # ...    ${distName_NRCELL[${fdd_cell_3}-1]}                freqBandIndicatorNR                  78
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}                chBw                               60MHz
    # ...    ${distName_NRCELL[${fdd_cell_3}-1]}                nrarfcn                              531000
    # ...    ${distName_NRCELL[${fdd_cell_3}-1]}                actDl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_3}-1]}                actUl256Qam                          true
    # ...    ${distName_NRCELL[${fdd_cell_3}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_3}
    # ...    ${distName_NRCELL[${fdd_cell_3}-1]}                freqBandIndicatorNR                  78
    # ...    ${distName_NRCELL[${fdd_cell_3}-1]}                chBw                                 40MHz
    # ...    ${distName_NRCELL[${fdd_cell_3}-1]}                nrarfcn                              368500
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Modify dynamic pdcch parameters for TDD 60MHz bandwidth
    # srsForBeamMgmt is deasctivated - actUlSrsBM = false
    # ${param_list}    Create List
    # ${scf_modifs}    create list
    # ...    modify:NRCELL-${fdd_cell_3}:srsForBeamMgmt:cSRS=${cSRS['60MHz']}
    # Append To List       ${param_list}     @{scf_modifs}
    # scf.perform_scf_modification    modification_strings=${param_list}


Modify dynamic pdcch parameters for TDD 60MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${object_BWP_PROFILE-8_exists}=    scf.is object in scf    dist_name=NRBTS-1/BWP_PROFILE-8
    Run keyword if    not ${object_BWP_PROFILE-8_exists}    Update BWP_PROFILE objects for TDD 60MHz bandwidth    gnb_id=${gnb_id}

    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-1/NRCELL-3    gnb_id=${gnb_id}
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-8    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=0
    scf.modify scf element    value=MRBTS-1/NRBTS-1/BWP_PROFILE-31    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=1

Update BWP_PROFILE objects for TDD 60MHz bandwidth
    [documentation]    for 5GC001070 FS (SemiStatic 3/7) on Cell3
    [Arguments]    ${gnb_id}=${0}
    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-0    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-8
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_COMMON}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    scf.modify scf element    value=2    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=duration
    scf.modify scf element    value=sl5  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=periodicity
    scf.modify scf element    value=2    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=duration
    scf.modify scf element    value=sl5  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=periodicity

    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-44    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-31
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_COMMON}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    scf.modify scf element    value=2    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=duration
    scf.modify scf element    value=sl5  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=periodicity
    scf.modify scf element    value=2    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=duration
    scf.modify scf element    value=sl5  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=periodicity

    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    scf.modify scf element    value=162    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL4
    scf.modify scf element    value=n1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=0
    ...    p_name=numOfPdcchCandidatesInAL8
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL1
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL2
    scf.modify scf element    value=n2    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL4
    scf.modify scf element    value=n1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=searchSpaceDedicated    index=1
    ...    p_name=numOfPdcchCandidatesInAL8

#-----------For iphy.xml Changes-----------------------------------------------------------------------------------------------------[150 characters]
Dedicated Set Context_AP IPHY
    [Arguments]          ${gscn}=7880
    DedicatedXmlConfig.startSession iphy
    #set GSCN
    # update only gscn for fdd cell1
    DedicatedXmlConfig.dedicated setListEltText iphy         //RE[1]//GSCN                   ${gscn}
    DedicatedXmlConfig.stopSession iphy

Dedicated Set Context_AP IPHY Cell2
    [Arguments]          ${gscn}=7880
    DedicatedXmlConfig.startSession iphy
    #set GSCN
    # update only gscn for fdd cell2
    DedicatedXmlConfig.dedicated setListEltText iphy         //RE[2]//GSCN                   ${gscn}
    DedicatedXmlConfig.stopSession iphy

Dedicated Set Context_AP IPHY Cell3
    [Arguments]          ${gscn}=7880
    DedicatedXmlConfig.startSession iphy
    #set GSCN
    # update only gscn for fdd cell3
    DedicatedXmlConfig.dedicated setListEltText iphy         //RE[3]//GSCN                   ${gscn}
    DedicatedXmlConfig.stopSession iphy

Dedicated Set Context_AP IPHY Cell4
    [Arguments]          ${gscn}=7880
    DedicatedXmlConfig.startSession iphy
    #set GSCN
    # update only gscn for fdd cell4
    DedicatedXmlConfig.dedicated setListEltText iphy         //RE[4]//GSCN                   ${gscn}
    DedicatedXmlConfig.stopSession iphy

Set Context_AP IPHY AEHC Cell1
    DedicatedXmlConfig.startSession iphy
    DedicatedXmlConfig.dedicated setListEltText         //RE[1]//cardName                   AEHC
    DedicatedXmlConfig.dedicated setListEltText         //RE[1]//productCode                475124A
    DedicatedXmlConfig.dedicated setListEltText         //RE[1]//resourceBuildKey           LTX_AEHC
    DedicatedXmlConfig.stopSession iphy

Modify iphy.xml for 2FDD Setup for 20MHz
    # iPHY gscn update depending of chBw
    Dated Log      iPHY gscn update with ${gscn_fdd_cell_1} : chBw=${20}
    CB013715-FDD_initial_commissioning.Dedicated Set Context_AP IPHY    ${gscn_fdd_cell_1}
    IF     ${cell2_is_Dss}
        Dated Log      iPHY gscn update with ${gscn_fdd_cell_2} : chBw=${20}
        CB013715-FDD_initial_commissioning.Dedicated Set Context_AP IPHY Cell2    ${gscn_fdd_cell_2}
    END
    CB013715-FDD_initial_commissioning.backup new iphy.xml

Modify iphy.xml for 2TDD+2FDD Setup for 20MHz
    # iPHY gscn update depending of chBw
    Dated Log      iPHY gscn update with ${gscn_fdd_cell_1} : chBw=${20}
    CB013715-FDD_initial_commissioning.Dedicated Set Context_AP IPHY Cell3    ${gscn_fdd_cell_1}
    IF     ${cell2_is_Dss}
        Dated Log      iPHY gscn update with ${gscn_fdd_cell_2} : chBw=${20}
        CB013715-FDD_initial_commissioning.Dedicated Set Context_AP IPHY Cell4    ${gscn_fdd_cell_2}
    END
    CB013715-FDD_initial_commissioning.backup new iphy.xml


Modify iphy.xml for 2FDD Setup for 15MHz
    # iPHY gscn update depending of chBw
    Dated Log      iPHY gscn update with ${gscn_fdd_cell_1} : chBw=${15}
    CB013715-FDD_initial_commissioning.Dedicated Set Context_AP IPHY    ${gscn_fdd_cell_1}
    CB013715-FDD_initial_commissioning.backup new iphy.xml

Modify iphy.xml for 2FDD Setup for 10MHz
    # iPHY gscn update depending of chBw
    Dated Log      iPHY gscn update with ${gscn_fdd_cell_1} : chBw=${10}
    CB013715-FDD_initial_commissioning.Dedicated Set Context_AP IPHY    ${gscn_fdd_cell_1}
    CB013715-FDD_initial_commissioning.backup new iphy.xml


#-----------For iphy.xml Changes other way-------------------------------------------------------------------------------------------[150 characters]
Modify iphy.xml for 2TDD+2FDD Setup version2
    ${ru_version}  ${frm_sw}    testline-Keywords.Get RU Info from TargetBD    ru_type=AEQE
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${ap_alias}    connect.Connect to Airphone Common Unit
    ssh.Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/new_iphy_orig.xml    connection=${ap_alias}
        ${contents}    OperatingSystem.get file    ${configuration_directory}/new_iphy_orig.xml
        ${all_parts}    split string      ${contents}     </RE>
        ${p0}   set variable   ${all_parts}[0]    # 1st TDD Cell
        ${p1}   set variable   ${all_parts}[1]    # 2nd TDD Cell
        ${p2}   set variable   ${all_parts}[2]    # 1st FDD Cell
        ${p3}   set variable   ${all_parts}[3]    # 2nd FDD Cell
        ${p4}   set variable   ${all_parts}[4]    # last part of the iphy.xml file
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p2}   replace string using regexp   ${p0}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_1}<\/GSCN>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${new contents}      catenate         SEPARATOR=</RE>    ${p0}    ${p1}    ${p2}    ${p3}    ${p4}
        OperatingSystem.create file    ${configuration_directory}/new_iphy_updated.xml    ${new contents}
    ssh.Upload File       ${configuration_directory}/new_iphy_updated.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}


backup new iphy.xml
    ${ap_alias}    connect.Connect to Airphone Common Unit
    ssh.Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/new_iphy_updated.xml    connection=${ap_alias}

#-----------Misc---------------------------------------------------------------------------------------------------------------------[150 characters]

Save RNTIs
    ${rntis_dict}=    template.get_rntis_for_ue_group    scenario_name=${scenario_name}
    tools_py.write_dictionary_to_json    dir_path=${ts_log_dir}/
    ...                                  dictionary=${rntis_dict}
    ...                                  filename=rntis_${scenario_name}.json


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
