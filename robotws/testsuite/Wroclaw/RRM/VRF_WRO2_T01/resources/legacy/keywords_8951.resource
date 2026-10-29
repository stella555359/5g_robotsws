*** Settings ***
Documentation
...  Author:        Maciej Cupial, Adam Tokarski
...  Contact:       maciej.cupial@nokia.com, adam.tokarski@nokia.com
...  Feature owner: Karol Malutkiewicz, Witold Galka
...  Description:   Power Saving feature for 5G site
...                 Feature Corner:     https://feature-corner.nsn-net.net/materials/clbkj7uvc2084464wkzdj046wlm

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_9920.resource
Library         Collections
Library         String
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py         WITH NAME    ah
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py          WITH NAME    ds
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_8951.py             WITH NAME    8951_lib
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot


*** Variables ***
${BTS_ID}                ${tl.gnbs[0].instance_id}
${MRBTS_LTE_ID}          ${tl.enbs[0].instance_id}
${MAIN_SCF_PATH}         MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
${MAIN_LTE_SCF_PATH}     MRBTS-${MRBTS_LTE_ID}/LNBTS-${MRBTS_LTE_ID}
@{DAYS}                  Mon  Tue  Wed  Thu  Fri  Sat  Sun
@{LBPSCELLSOORDERS}      10  100
${LTE_CONNECTION_ALIAS}  eNB

@{global_cells_ids}
@{nr_cells_ids}


*** Keywords ***
Perform Commissioning 8951 LTE
    Log To Console  __Performing 8951 LTE commissioning

    ${lte_cells_ids}         Get LTE Cells Ids

    ds.initialise_delta_store
    ds.add_param_to_delta        ${MAIN_LTE_SCF_PATH}    actLteNrDualConnectivity              value=true
    ds.add_param_to_delta        ${MAIN_LTE_SCF_PATH}    actCoordinated4g5gPowerSaving         value=cellDeactivation
    ds.add_param_to_delta        ${MAIN_LTE_SCF_PATH}    actDynTrigLteNrDualConnectivity       value=false

    FOR    ${cell_id}    IN    @{lte_cells_ids}
        ds.add_param_to_delta        ${MAIN_LTE_SCF_PATH}/LNCEL-${cell_id}    defaultLnRelGnbCellId       value=${0}
    END

    ${delta}    ds.collect_delta_store
    ah.recommission_with_delta_from_admin    ${delta}    connection=${LTE_CONNECTION_ALIAS}
    Verify If All Cells Are Onair


Get Cells Info
    [Documentation]
    ...    Get subsells info. Return two Global Cell IDs and NR Cell IDs

    [Arguments]    ${alias}=cOAM

    @{global_cells_ids}    Create List
    @{nr_cells_ids}    Create List

    ${ids}    Create List
    Connect With Runtime Release    ${alias}
    ${cells}    coam.get_subcells_info    connection=${alias}
    ${all_cells_data}    8951_lib.get_global_cell_id_and_nr_cell_identity     ${cells}

    Append To list    ${global_cells_ids}    ${all_cells_data}[0][0]
    Append To list    ${nr_cells_ids}        ${all_cells_data}[0][1]
    Append To list    ${global_cells_ids}    ${all_cells_data}[1][0]
    Append To list    ${nr_cells_ids}        ${all_cells_data}[1][1]

    Log To Console
    ...  __Cells adding to power saving group:${\n}Global Cell ID: ${global_cells_ids} | NR Cell ID: ${nr_cells_ids}
    [Return]      ${global_cells_ids}    ${nr_cells_ids}
    [Teardown]    coam.teardown          connection=cOAM


Get Global Cell Id
    [Arguments]    ${nrcell_path}    ${nrcell_list}
    ${global_cell_id}    Fetch From Right  ${nrcell_path}  -
    Append To list    ${nrcell_list}    ${global_cell_id}


Perform Commissioning 8951 5G
    [Documentation]
    ...  Prepare BTS with specific parameters

    [Arguments]
    ...    ${nrCellIds}
    ...    ${actCoordinated4g5gPowerSaving}=disabled
    ...    ${configuredEpsTac}=7152

    Log To Console     __Adding NRPGRP object
    ${status}	${value} =  Run Keyword And Ignore Error    Add NRPGRP Object    ${nrCellIds}
    Run Keyword If	'${status}' == 'FAIL'    Perform NRPGRP Delta    ${nrCellIds}

    Log To Console     __Perform commissioning 8951
    ds.initialise_delta_store
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actCoordinated4g5gPowerSaving    value=${actCoordinated4g5gPowerSaving}
#    ds.add_param_to_delta    ${MAIN_SCF_PATH}    gNbCuType                        value=${gNbCuType}

    FOR    ${cell_id}    IN    @{nrCellIds}
#        ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRCELL-${cell_id}    cellDepType         value=${cellDepType}
        ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRCELL-${cell_id}    configuredEpsTac    value=${configuredEpsTac}
    END

    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Verify If All Cells Are Onair


Add NRPGRP Object
    [Arguments]
    ...    ${nrCellIds}
    ...    ${lbpsLastCellSOEnabled}=false
    ...    ${lbpsSuspended}=notSuspended
    ...    ${lbpsDuration}=1440
    ...    ${lbpsStartTimeHour}=7
    ...    ${lbpsStartTimeMinute}=0

    ${lbpsPeriodDaysList}    Create List
    FOR    ${day}    IN    @{DAYS}
        &{lbpsPeriodList}    Create Dictionary
        ...                  lbpsDayOfWeek=${day}
        ...                  lbpsDuration=${lbpsDuration}
        ...                  lbpsStartTimeHour=${lbpsStartTimeHour}
        ...                  lbpsStartTimeMinute=${lbpsStartTimeMinute}
        ...                  lbpsSuspended=${lbpsSuspended}

        Append To list    ${lbpsPeriodDaysList}    ${lbpsPeriodList}
    END

    ${lbpsCellList}    Create List
    FOR    ${index}    ${nr_cell_id}    IN ENUMERATE    @{nrCellIds}
        ${lbpsCell}    Create Dictionary
        ...            lbpsCellSOOrder=${LBPSCELLSOORDERS}[${index}]
        ...            lbpsUseExtConfig=false
        ...            nrCellId=${nr_cell_id}
        Append To list    ${lbpsCellList}    ${lbpsCell}
    END

    &{mnp_dict}    Create Dictionary
    ...            lbpsCSONCtlEnabled=true
    ...            lbpsLastCellMinLoad=0
    ...            lbpsLastCellRTXMinLoad=0
    ...            lbpsLastCellSOEnabled=${lbpsLastCellSOEnabled}
    ...            lbpsMaxLoad=100
    ...            lbpsMinLoad=90
    ...            lbpsMonWinForCellSOff=60
    ...            lbpsMonWinForCellSOn=60
    ...            lbpsPdcchLoadOffset=4
    ...            lbpsSOMethod=cell switch off

    ds.initialise_delta_store

    ds.add_managed_object_and_parameter_to_delta    dist_name=${MAIN_SCF_PATH}/NRPGRP-1    &{mnp_dict}
    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1  lbpsCellList          @{lbpsCellList}
    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1  lbpsPeriodList        @{lbpsPeriodDaysList}
    ds.add_param_to_delta                 ${MAIN_SCF_PATH}/NRPGRP-1  lbpsLoadCalcMethod    value=Max(G_N_combined, P)
    ds.add_param_to_delta                 ${MAIN_SCF_PATH}/NRPGRP-1  lbpsSOffTrRule        value=MaxValueMethod
    ds.add_param_to_delta                 ${MAIN_SCF_PATH}/NRPGRP-1  lbpsSOnTrRule         value=MinValueMethod


    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Verify If All Cells Are Onair


Perform NRPGRP Delta
    [Arguments]
    ...    ${nrCellIds}
    ...    ${lbpsLastCellSOEnabled}=true
    ...    ${lbpsSuspended}=notSuspended
    ...    ${lbpsDuration}=1440
    ...    ${lbpsStartTimeHour}=7
    ...    ${lbpsStartTimeMinute}=0

    ${lbpsPeriodDaysList}    Create List
    FOR    ${day}    IN    @{DAYS}
        &{lbpsPeriodList}    Create Dictionary
        ...                  lbpsDayOfWeek=${day}
        ...                  lbpsDuration=${lbpsDuration}
        ...                  lbpsStartTimeHour=${lbpsStartTimeHour}
        ...                  lbpsStartTimeMinute=${lbpsStartTimeMinute}
        ...                  lbpsSuspended=${lbpsSuspended}

        Append To list    ${lbpsPeriodDaysList}    ${lbpsPeriodList}
    END

    ${lbpsCellList}    Create List

    FOR    ${index}    ${nr_cell_id}    IN ENUMERATE    @{nrCellIds}
        ${lbpsCell}    Create Dictionary
        ...            lbpsCellSOOrder=${LBPSCELLSOORDERS}[${index}]
        ...            lbpsUseExtConfig=false
        ...            nrCellId=${nr_cell_id}
        Append To list    ${lbpsCellList}    ${lbpsCell}
    END

    ds.initialise_delta_store

    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsCSONCtlEnabled           value=true
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsLastCellMinLoad          value=0
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsLastCellRTXMinLoad       value=0
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsLastCellSOEnabled        value=${lbpsLastCellSOEnabled}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsMaxLoad                  value=100
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsMinLoad                  value=90
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsMonWinForCellSOff        value=60
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsMonWinForCellSOn         value=60
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsPdcchLoadOffset          value=4
#    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsSOMethod                 value=cell switch off
#    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsLoadCalcMethod           value=Max(G_N_combined, P)
#    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsSOffTrRule               value=MaxValueMethod
#    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1    lbpsSOnTrRule                value=MinValueMethod

    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1  lbpsCellList          @{lbpsCellList}
    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1  lbpsPeriodList        @{lbpsPeriodDaysList}

    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Verify If All Cells Are Onair


Activate 8951
    Log To Console    __Activate energy saving
    ds.initialise_delta_store
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actCoordinated4g5gPowerSaving    value=cellDeactivation
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actNrLBPowerSaving               value=true
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actLbpsCtrlLogicEnh              value=true
    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Log To Console    __Wait for cell deactivation


Activate 8951 EC1
    Log To Console    __Activate energy saving
    ds.initialise_delta_store
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actCoordinated4g5gPowerSaving    value=cellDeactivation
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actNrLBPowerSaving               value=true
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actLbpsCtrlLogicEnh              value=true
    ds.add_param_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1  lbpsSOMethod  mixed switch off
    ds.add_param_to_delta  ${MAIN_SCF_PATH}  actNrMixedSOMethod  true
    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Log To Console    __Wait for cell deactivation




Deactivate 8951
    Log To Console    __Deactivate energy saving (part CB008951_A#B2 ongoing)
    ds.initialise_delta_store
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actCoordinated4g5gPowerSaving    value=disabled
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actLbpsCtrlLogicEnh              value=false
#    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actNrLBPowerSaving               value=false

    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Log To Console    __Wait for cells activation


Check if 5G 8951 is deactivated as initial status
    Log To Console    __Be sure if 5G 8951 is deactivated as initial status
    ds.initialise_delta_store
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actCoordinated4g5gPowerSaving    value=disabled
#    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actLbpsCtrlLogicEnh              value=false
#    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actNrLBPowerSaving               value=false
    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Wait Until Cells Status    ${global_cells_ids}[0]    power_saving_status=off
    Log To Console    __5G 8951 is deactivated as initial status


Wait Until Cells Status
    [Arguments]
    ...    ${cell_id}
    ...    ${power_saving_status}
    ...    ${duration}=900 sec
    ...    ${interval}=60 sec
    Wait Until Keyword Succeeds  ${duration}  ${interval}    Check Cells Statuses  ${cell_id}  ${power_saving_status}


Check Cells Statuses
    [Arguments]
    ...    ${cell_id}
    ...    ${power_saving_status}
    ${bts_info}=  coam.get bts info  60  gNB
    ${bts_info}=  Set Variable  ${bts_info}[cells][nr]
    FOR  ${cell}  IN  @{bts_info}
        Run Keyword If    ${cell}[globalCellId] == ${cell_id}
        ...    Power Saving Status Verification    ${cell}    ${power_saving_status}
    END


Power Saving Status Verification
    [Arguments]
    ...    ${cell}
    ...    ${power_saving_status}
    Run Keyword If    '${power_saving_status}'=='on'
    ...    Check Power Saving On    ${cell}
    ...    ELSE
    ...    Check Power Saving Off    ${cell}


Check Power Saving On
    [Arguments]
    ...    ${cell}
    Should Be True    '${cell['energySavingState']}'=='energySaving'
    Should Be True    '${cell['status']['availabilityStatus']}'=='off line'


Check Power Saving Off
    [Arguments]
    ...    ${cell}
    Should Be True    '${cell['energySavingState']}'=='notEnergySaving'
    Should Be True    '${cell['status']['operationalState']}'=='enabled'


Verify If nrDeactivationIndication Is Deactivated
    [Arguments]    ${pdml_file_path}
    Log To Console                  __Verifying if 'nrDeactivationIndication: deactivated (0)'
    ${nrdeact_flag}                 8951_lib.check_nrdeactivationindication  ${pdml_file_path}
    Should Be True                  ${nrdeact_flag}


Verify If nRcellIdentifier Is Equal To Power Saving Nr Cell Id
    [Arguments]    ${pdml_file_path}    ${cell}
    Log To Console                  __Verifying if 'decimal value ${cell}' in 'x2ap.nRcellIdentifier'
    ${nrcell_flag}                  8951_lib.check_nRcellIdentifier  ${pdml_file_path}    ${cell}
    Should Be True                  ${nrcell_flag}
