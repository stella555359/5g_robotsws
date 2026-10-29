*** Settings ***
Documentation
...  Author:        Maciej Cupial, Adam Tokarski
...  Contact:       maciej.cupial@nokia.com, adam.tokarski@nokia.com
...  Feature owner: Karol Malutkiewicz, Witold Galka
...  Description:   Power Saving feature for 5G site, part 2
...                 Feature Corner:     https://feature-corner.nsn-net.net/materials/clchjwwcs374404xkzix2h4shg

Library         taf.sbts.oam.coam.admin                                                WITH NAME     coam
Library         taf.sw.reporting_portal
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.py                  WITH NAME     pcap
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py                  WITH NAME     ah
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py                   WITH NAME     ds
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.PmUtils                         WITH NAME     pu
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010442/resources/keywords_8951.py       WITH NAME     8951_lib
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010442/resources/keywords.py            WITH NAME    10442_lib
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/color_log.py                         WITH NAME    line
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords_1167.py           WITH NAME    1167_lib
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC000570/resources/specific_keywords_570.py   WITH NAME   link_wro4_570
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010442/resources/KPIs_PMs.py


*** Variables ***
${MRBTS_LTE_ID}            ${tl.enbs[0].instance_id}
${LTE_MPLANE}              ${tl.enbs[0].m.v4}
${MAIN_LTE_SCF_PATH}       MRBTS-${MRBTS_LTE_ID}/LNBTS-${MRBTS_LTE_ID}
${BTS_ID}                  ${tl.gnbs[0].instance_id}
${MAIN_SCF_PATH}           MRBTS-${bts_id}/NRBTS-${bts_id}
${LTE_CONNECTION_ALIAS}    eNB
${5G_CONNECTION_ALIAS}     gNB
@{LBPSCELLSOORDERS_10442}  10  100  100  100
@{DAYS}                    Mon  Tue  Wed  Thu  Fri  Sat  Sun
${AB1_counters}            M55112C00020,M55112C00021
${EC1_COUNTER}             M55110C00013
@{energy_saving_PMs}   M55601C01001    M55601C01002    M55601C01003    M55601C01004

${CURRENT_DATETIME_FORMAT}  %Y-%m-%d %H:%M:%S
${BTS_ADDRESS}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${BTS_PORT}       22
${USE_SSL}        True
${scf_file_10766}      testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010442/resources/SCF/7_16_UTE5GCLOUDT161_10766.xml
${scf_file_10683}      testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010442/resources/SCF/7_16_UTE5GCLOUDT151_10683.xml
&{DISABLED_dictionary}

*** Keywords ***
Perform Commissioning 10442 LTE
    [Documentation]
    ...    Prerfomrs delta commissioning for 10442 on LTE site

    [Arguments]
    ...    ${lte_cells_ids}
    ...    ${5g_energy_saving_cell}
    ...    ${lbpsMaxLoad}=17
    ...    ${lbpsMaxLoadNrAct}=3
    ...    ${lbpsMinLoad}=3
    ...    ${lbpsMinNumEndcCapUeNrAct}=1

    Log To Console    __Perform 10442 LTE commissioning
    Log To Console    __Adding PSGRP object
    ${status}	${value} =  Run Keyword And Ignore Error    Add PSGRP Object 10442
                                                            ...    ${lte_cells_ids}
                                                            ...    ${5g_energy_saving_cell}
                                                            ...    lbpsMaxLoad=${lbpsMaxLoad}
                                                            ...    lbpsMaxLoadNrAct=${lbpsMaxLoadNrAct}
                                                            ...    lbpsMinLoad=${lbpsMinLoad}
                                                            ...    lbpsMinNumEndcCapUeNrAct=${lbpsMinNumEndcCapUeNrAct}

    Run Keyword If	'${status}' == 'FAIL'    Perform PSGRP Delta 10442
                                             ...    ${lte_cells_ids}
                                             ...    ${5g_energy_saving_cell}
                                             ...    lbpsMaxLoad=${lbpsMaxLoad}
                                             ...    lbpsMaxLoadNrAct=${lbpsMaxLoadNrAct}
                                             ...    lbpsMinLoad=${lbpsMinLoad}
                                             ...    lbpsMinNumEndcCapUeNrAct=${lbpsMinNumEndcCapUeNrAct}


Perform Commissioning 10442 5G
    [Documentation]
    ...    Prerfomrs delta commissioning for 10442 on 5G site

    [Arguments]
    ...    ${global_5g_cell_id}

    Log To Console    __Perform 10442 5G commissioning
    Log To Console    __Adding NRPGRP object
    ${status}	${value} =  Run Keyword And Ignore Error    Add NRPGRP Object 10442    ${global_5g_cell_id}
    Run Keyword If	'${status}' == 'FAIL'    Perform NRPGRP Delta 10442    ${global_5g_cell_id}


Add NRPGRP Object 10442
    [Documentation]
    ...    Creates NRPGRP object and preforms recommission with delta

    [Arguments]
    ...    ${5g_cell_id}
    ...    ${lbpsLastCellSOEnabled}=true

    &{mnp_dict}    Create Dictionary
    ...            lbpsCSONCtlEnabled=true
    ...            lbpsLastCellMinLoad=1
    ...            lbpsLastCellRTXMinLoad=1
    ...            lbpsLastCellSOEnabled=${lbpsLastCellSOEnabled}
    ...            lbpsLoadCalcMethod=Max(G_N_combined, P)
    ...            lbpsMaxLoad=2
    ...            lbpsMinLoad=1
    ...            lbpsMonWinForCellSOff=60
    ...            lbpsMonWinForCellSOn=60
    ...            lbpsPdcchLoadOffset=4
    ...            lbpsRTXCellCapOffset=80
    ...            lbpsRTXMaxLoad=2
    ...            lbpsRTXMinLoad=1
    ...            lbpsRTXSOffTime=300
    ...            lbpsRTXSOnTime=120
    ...            lbpsSOffTrRule=MaxValueMethod
    ...            lbpsSOMethod=cell switch off
    ...            lbpsSOnTrRule=MinValueMethod

    ds.initialise_delta_store
    ds.add_managed_object_and_parameter_to_delta    dist_name=${MAIN_SCF_PATH}/NRPGRP-1    &{mnp_dict}
    Add NRPGRP Parameters 10442    ${5g_cell_id}

    ${delta}    ds.collect_delta_store
    ah.recommission_with_delta_from_admin    ${delta}
    Verify If All Cells Are Onair


Perform NRPGRP Delta 10442
    [Documentation]
    ...    Preforms delta commissioning for NRPGRP object

    [Arguments]
    ...    ${5g_cell_id}
    ...    ${lbpsLastCellSOEnabled}=true

    ds.initialise_delta_store
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsCSONCtlEnabled        value=true
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsLastCellMinLoad       value=1
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsLastCellRTXMinLoad    value=1
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsLastCellSOEnabled     value=${lbpsLastCellSOEnabled}
#    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsLoadCalcMethod        value=Max(G_N_combined, P)
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsMaxLoad               value=2
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsMinLoad               value=1
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsMonWinForCellSOff     value=60
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsMonWinForCellSOn      value=120
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsPdcchLoadOffset       value=4
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsRTXCellCapOffset      value=80
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsRTXMaxLoad            value=2
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsRTXMinLoad            value=1
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsRTXSOffTime           value=300
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsRTXSOnTime            value=120
#    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsSOffTrRule            value=MaxValueMethod
#    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsSOMethod              value=cell switch off
#    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsSOnTrRule             value=MinValueMethod
    Add NRPGRP Parameters 10442  ${5g_cell_id}

    ${delta}    ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Verify If All Cells Are Onair


Add NRPGRP Parameters 10442
    [Documentation]
    ...    Adds parameters needed for creating NRPGRP object and for preforming NRPGRP delta to delta object

    [Arguments]
    ...    ${5g_cell_id}

    ${lbpsPeriodDaysList}    Create List
    FOR    ${day}    IN    @{DAYS}
        &{lbpsPeriodList}    Create Dictionary
        ...                  lbpsDayOfWeek=${day}
        ...                  lbpsDuration=1440
        ...                  lbpsStartTimeHour=7
        ...                  lbpsStartTimeMinute=0
        ...                  lbpsSuspended=notSuspended

        Append To List    ${lbpsPeriodDaysList}    ${lbpsPeriodList}
    END

    ${lbpsCellList}    Create List

    ${lbpsCell}    Create Dictionary
    ...            lbpsCellSOOrder=10
    ...            lbpsUseExtConfig=false
    ...            nrCellId=${5g_cell_id}
    Append To List    ${lbpsCellList}    ${lbpsCell}

    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1  lbpsCellList          @{lbpsCellList}
    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1  lbpsPeriodList        @{lbpsPeriodDaysList}


Add PSGRP Object 10442
    [Documentation]
    ...    Creates PSGRP object and preforms recommission with delta

    [Arguments]
    ...    ${lte_cells_ids}
    ...    ${5g_energy_saving_cell}
    ...    ${lbpsMaxLoad}=17
    ...    ${lbpsMaxLoadNrAct}=3
    ...    ${lbpsMinLoad}=3
    ...    ${lbpsMinNumEndcCapUeNrAct}=1

    &{mnp_dict}    Create Dictionary
    ...            lbpsCSONCtlEnabled=true
    ...            lbpsGuardTimerNrAct=10
    ...            lbpsLastCellMinLoad=4
    ...            lbpsLastCellRTXMinLoad=2
    ...            lbpsLastCellSOEnabled=false
    ...            lbpsLoadCalcMethod=Max(G, W, P)
    ...            lbpsMaxLoad=${lbpsMaxLoad}
    ...            lbpsMaxLoadNrAct=${lbpsMaxLoadNrAct}
    ...            lbpsMinLoad=${lbpsMinLoad}
    ...            lbpsMinNumEndcCapUeNrAct=${lbpsMinNumEndcCapUeNrAct}
    ...            lbpsMonWinForCellSOff=60
    ...            lbpsMonWinForCellSOn=60
    ...            lbpsMonWinForRtxSOff=60
    ...            lbpsMonWinForRtxSOn=60
    ...            lbpsMonWinNrAct=1
    ...            lbpsPdcchLoadOffset=0
    ...            lbpsRetryTimerNrAct=1
    ...            lbpsRTXCellCapOffset=80
    ...            lbpsRTXMaxLoad=2
    ...            lbpsRTXMinLoad=1
    ...            lbpsSOffTrRule=MaxValueMethod
    ...            lbpsSOnTrRule=MinValueMethod
    ...            lbpsSOMethod=Legacy Mixed Switch Off
#    ...            psGrpId=0

    ds.initialise_delta_store
    ds.add_managed_object_and_parameter_to_delta    dist_name=${MAIN_LTE_SCF_PATH}/PSGRP-0     &{mnp_dict}
    Add PSGRP Parameters 10442    ${lte_cells_ids}    ${5g_energy_saving_cell}

    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin    ${delta}    connection=${LTE_CONNECTION_ALIAS}
    Verify If All Cells Are Onair


Perform PSGRP delta 10442
    [Documentation]
    ...    Preform delta commissioning for NRPGRP object

    [Arguments]
    ...    ${lte_cells_ids}
    ...    ${5g_energy_saving_cell}
    ...    ${lbpsMaxLoad}=17
    ...    ${lbpsMaxLoadNrAct}=3
    ...    ${lbpsMinLoad}=3
    ...    ${lbpsMinNumEndcCapUeNrAct}=1

    ds.initialise_delta_store
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsCSONCtlEnabled        value=true
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsGuardTimerNrAct       value=10
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsLastCellMinLoad       value=4
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsLastCellRTXMinLoad    value=2
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsLastCellSOEnabled     value=false
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsLoadCalcMethod        value=Max(G, W, P)
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsMaxLoad               value=${lbpsMaxLoad}
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsMaxLoadNrAct          value=${lbpsMaxLoadNrAct}
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsMinLoad               value=${lbpsMinLoad}
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsMinNumEndcCapUeNrAct  value=${lbpsMinNumEndcCapUeNrAct}
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsMonWinForCellSOff     value=60
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsMonWinForCellSOn      value=60
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsMonWinForRtxSOff      value=60
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsMonWinForRtxSOn       value=60
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsMonWinNrAct           value=1
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsPdcchLoadOffset       value=0
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsRetryTimerNrAct       value=1
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsRTXCellCapOffset      value=80
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsRTXMaxLoad            value=2
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsRTXMinLoad            value=1
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsSOffTrRule            value=MaxValueMethod
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsSOnTrRule             value=MinValueMethod
    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    lbpsSOMethod              value=Legacy Mixed Switch Off
#    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}/PSGRP-0    psGrpId                   value=0
    Add PSGRP Parameters 10442    ${lte_cells_ids}    ${5g_energy_saving_cell}

    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin    ${delta}    connection=${LTE_CONNECTION_ALIAS}
    Verify If All Cells Are Onair


Add PSGRP Parameters 10442
    [Documentation]
    ...    Adds parameters needed for creating PSGRP object and for preforming PSGRP delta to delta object

    [Arguments]
    ...    ${lte_cells_ids}
    ...    ${5g_energy_saving_cell}
    ...    ${lbpsSuspended}=notSuspended

    ${lbpsPeriodDaysList}    Create List
    FOR    ${day}    IN    @{DAYS}
        &{lbpsPeriodList}    Create Dictionary
        ...                  lbpsDayOfWeek=${day}
        ...                  lbpsDuration=1440
        ...                  lbpsStartTimeHour=7
        ...                  lbpsStartTimeMinute=0
        ...                  lbpsSuspended=${lbpsSuspended}

        Append To List    ${lbpsPeriodDaysList}    ${lbpsPeriodList}
    END

    ${lbpsCellList}    Create List
    FOR    ${index}    ${nr_cell_id}    IN ENUMERATE    @{lte_cells_ids}
        ${lbpsCell}    Create Dictionary
        ...            lbpsCellSOOrder=${LBPSCELLSOORDERS_10442}[${index}]
        ...            lbpsUseExtConfig=false
        ...            lnCelId=${lte_cells_ids}[${index}]
        Append To List    ${lbpsCellList}    ${lbpsCell}
    END

    ${lbpsCellListNrActList}    Create List
    &{lbpsCellListNrActDict}    Create Dictionary
    ...                  gNbIdLength=22
    ...                  mcc=310
    ...                  mnc=260
    ...                  mncLength=3
    ...                  nrCellId=${5g_energy_saving_cell}
    Append To List    ${lbpsCellListNrActList}    ${lbpsCellListNrActDict}

    ds.add_list_of_dictionaries_to_delta  ${MAIN_LTE_SCF_PATH}/PSGRP-0  lbpsCellList           @{lbpsCellList}
    ds.add_list_of_dictionaries_to_delta  ${MAIN_LTE_SCF_PATH}/PSGRP-0  lbpsPeriodList         @{lbpsPeriodDaysList}
    ds.add_list_of_dictionaries_to_delta  ${MAIN_LTE_SCF_PATH}/PSGRP-0  lbpsCellListNrAct      @{lbpsCellListNrActList}


Activate 10442
    [Documentation]
    ...    Preforms delta commissioning with parameters which activates 10442 feature

    [Arguments]
    ...    ${actCoordinated4g5gPowerSaving}=cellDeactAndReact
    ...    ${actNrLBPowerSaving}=true
    ...    ${actLbpsCtrlLogicEnh}=true
    ...    ${actNrMixedSOMethod}=true
    ...    ${lbpsSOMethod}=mixed switch off

    Log To Console    __Activate energy saving (CB010442)
    ds.initialise_delta_store
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actCoordinated4g5gPowerSaving    value=${actCoordinated4g5gPowerSaving}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actNrLBPowerSaving               value=${actNrLBPowerSaving}
    ds.Add Param To Delta    ${MAIN_SCF_PATH}    actLbpsCtrlLogicEnh              value=${actLbpsCtrlLogicEnh}
    ds.Add Param To Delta    ${MAIN_SCF_PATH}              actNrMixedSOMethod     value=${actNrMixedSOMethod}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}/NRPGRP-1     lbpsSOMethod           value=${lbpsSOMethod}
    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Log To Console    __Wait for energy saving activation


Attenuate Cells 10442
    [Documentation]
    ...    Attenuates all ports for 90 dbm except off_attenuated which are attenuated
    ...    for 10 dbm if attenuate_off_attenuated equals 'true'

    [Arguments]
    ...    ${off_attenuated}
    ...    ${attenuate_off_attenuated}=false

    Log To Console               __Attenuate cells for 10442
    ${cells_to_attenuate}        Get Dictionary Keys            ${tl.attenuator.attenuator_ports}
    Remove Values From List      ${cells_to_attenuate}          @{off_attenuated}
    Set Attenuation And Check    lines=${cells_to_attenuate}    value=90
    Run Keyword If    '${attenuate_off_attenuated}' == 'true'   Set Attenuation And Check
                                                                ...    lines=${off_attenuated}
                                                                ...    value=10
     BuiltIn.Sleep    15s


Wait For LTE And 5G Energy Saving Cells Are In Power Saving State
    [Documentation]
    ...    Checks for energy saving state active on given LTE and 5G cells

    [Arguments]
    ...    ${LTE_cell}
    ...    ${5G_cell}
    ...    ${5G_cell_time}=5min
    ...    ${LTE_cell_time}=5min
    ...    ${check_loop}=30sec

    Log To Console    __Wait for LTE energy saving cell status
    Wait Until Keyword Succeeds    ${LTE_cell_time}    ${check_loop}    Check LTE Energy Saving Cell Status    ${LTE_cell}
    Log To Console    __Wait for 5G energy saving cell status
    Wait Until Keyword Succeeds    ${5G_cell_time}    ${check_loop}    Check 5G Energy Saving Cell Status     ${5G_cell}


Check LTE Energy Saving Cell Status
    [Documentation]
    ...    Checks power saving state on given LTE cell

    [Arguments]
    ...    ${lte_energy_saving_cell}

    ${lte_bts_info}    coam.get_bts_info    60    ${LTE_CONNECTION_ALIAS}
    ${lte_cells_info}  Set Variable    ${lte_bts_info['cells']['lte']}
    10442_lib.verify_energy_saving_activation    ${lte_energy_saving_cell}    @{lte_cells_info}


Check 5G Energy Saving Cell Status
    [Documentation]
    ...    Checks power saving state on given 5G cell

    [Arguments]
    ...    ${5g_energy_saving_cell}

    Conect to gNB admin
    ${5g_bts_info}    coam.get_bts_info    60    ${5G_CONNECTION_ALIAS}
    ${5g_cells_info}  Set Variable    ${5g_bts_info['cells']['nr']}
    10442_lib.verify_energy_saving_activation    ${5g_energy_saving_cell}    @{5g_cells_info}


Check 5G Energy Saving Cell Status deactivated
    [Documentation]
    ...    Checks power saving state on given 5G cell

    [Arguments]
    ...    ${5g_energy_saving_cell}

    Conect to gNB admin
    ${5g_bts_info}    coam.get_bts_info    60    ${5G_CONNECTION_ALIAS}
    ${5g_cells_info}  Set Variable    ${5g_bts_info['cells']['nr']}
    10442_lib.verify_energy_saving_deactivation    ${5g_energy_saving_cell}    @{5g_cells_info}


Check 5G reduced Energy Saving Cell Status activated
    [Documentation]
    ...    Checks energy mutting state on given 5G cell

    [Arguments]
    ...    ${5g_energy_saving_cell}

    Conect to gNB admin
    ${5g_bts_info}    coam.get_bts_info    30    ${5G_CONNECTION_ALIAS}
    ${5g_cells_info}  Set Variable    ${5g_bts_info['cells']['nr']}
    10442_lib.verify_if_cell_mutted_state    ${5g_energy_saving_cell}    @{5g_cells_info}


Wait for lbpsGuardTimerNrAct
    [Documentation]
    ...    Because of lbpsGuardTimerNrAct set to 10 min 5G cell cannot be activated earlier than 10min after going to
    ...    energy saving state

    Log To Console    __Waiting 11 min for guard timer deactivation
    BuiltIn.Sleep    11min


Wait for LTE and 5G energy saving cells are on air
    [Documentation]
    ...    Checks if all LTE and 5G cells are on air

    Log To Console    __Wait for all LTE cells on air
    Wait Until Keyword Succeeds    3min    30sec    Wait For LTE Energy Saving Cell On Air
    Log To Console    __Wait for all 5G cells on air
    Wait Until Keyword Succeeds    10min    15sec   Wait For 5G Energy Saving Cell On Air


Wait For LTE Energy Saving Cell On Air
    [Documentation]
    ...    Waits for all LTE cells on air

    ${lte_bts_info}    coam.get_bts_info    60    ${LTE_CONNECTION_ALIAS}
    ${lte_cells_info}  Set Variable    ${lte_bts_info['cells']['lte']}
    10442_lib.verify_on_air_state    @{lte_cells_info}


Wait For 5G Energy Saving Cell On Air
    [Documentation]
    ...    Waits for all 5G cells on air

    ${5g_bts_info}    coam.get_bts_info    60    ${5G_CONNECTION_ALIAS}
    ${5g_cells_info}  Set Variable    ${5g_bts_info['cells']['nr']}
    10442_lib.verify_on_air_state    @{5g_cells_info}


Collect Counters 10442
    [Documentation]
    ...    Collets counters and returns dictionary <counter_id: counter_value>. Because counters can increment
    ...    with some delay it uses 'Wait Until Keyword Succeeds'

    [Arguments]
    ...    ${5g_energy_saving_cell}

    ${counters_values_dict}    Wait Until Keyword Succeeds    16min    30s    Get Counters And Check Incrementation AB1
                                                                             ...    ${5g_energy_saving_cell}

    [Return]    ${counters_values_dict}


Get Counters And Check Incrementation AB1
    [Documentation]
    ...    Collects counters and checks incrementation. Because counters M55112C00020 and M55112C00021
    ...    can appear in WebEM with some delay it uses 'Wait Until Keyword Succeeds'

    [Arguments]
    ...    ${5g_energy_saving_cell}

    &{counters_values}    Wait Until Keyword Succeeds    16min    30s    Get Counters    ${AB1_counters}

    ${counter_path}    Get Counter Path For Release
    ...    SBTS23R4
    ...    ['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${5g_energy_saving_cell}']['NX2CC']
    ...    ['BTS']['CELLS']['NRCELL-${5g_energy_saving_cell}']['NX2CC']


    &{counters_values_dict}   pu.get_last_counters_values
    ...    ${counters_values${counter_path}}

    pu.check_counters_are_greater_than_zero         ${counters_values_dict}

    [Return]    ${counters_values_dict}


Get Counters And Check Incrementation EC1
    [Documentation]
    ...    Collects counter for EC1 tc and checks if counter equals 1

    &{counters_values}        Get Counters    ${EC1_COUNTER}
    &{counters_values_dict}   pu.get_last_counters_values
                              ...    ${counters_values['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NX2CB']}
    Should Be Equal    '${counters_values_dict}[${EC1_COUNTER}]'    '1'


Verify Counters And Pdml AB1
    [Documentation]
    ...    Compares values from given dicts and return result.
    ...    Both dicts should be in format <counter_id: counter_value>

    [Arguments]
    ...    ${5g_energy_saving_cell}
    ...    ${pcap_file_path}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pcap

    ${counters_values}    Collect Counters 10442    ${5g_energy_saving_cell}
    Log To Console                  __Convert pcap to pdml...
    Run Keyword And Ignore Error    Convert Pcap To Pdml      ${pcap_file_path}
    ${pdml_file_path}               pcap.pdml_path_from_pcap_path  ${pcap_file_path}
    ${pdml_dict}    Check Pdml 10442 AB1    ${pdml_file_path}

    ${comparsion_result}    10442_lib.compare_pdml_with_counters    ${counters_values}    ${pdml_dict}

    [Return]    ${comparsion_result}


Verify Counters EC1
    [Documentation]
    ...    Because counter for EC1 tc can increment two/three WebEM slots after performing tput kw for collecting
    ...    counter is called by 'Wait Until Keyword Succeeds'

    Log To Console     __Wait for counter incrementation
    Wait Until Keyword Succeeds    32min    1min    Get Counters And Check Incrementation EC1


Check Pdml 10442 AB1
    [Documentation]
    ...    Counts number of occurrences of needed mesgs and returns dictionary <counter_id: number_of_occurrences>
    ...    Counters names to pdml logs mapping:
    ...    M55112C00020 -> ENDC_CELL_ACT_REQ_X2
    ...    M55112C00021 -> ENDC_CELL_ACT_ACC_X2
    ...    M55113C00011 -> NR_CELL_ACT_MENB_REQ
    ...    M55113C00012 -> NR_CELL_ACT_MENB_SUC

    [Arguments]    ${pdml_file_path}

    ${ENDC_CELL_ACT_REQ_X2}    Run    grep -s "ENDCCellActivationRequest" ${pdml_file_path} | wc -l
    ${ENDC_CELL_ACT_ACC_X2}    Run    grep -s "ENDCCellActivationResponse" ${pdml_file_path} | wc -l
    ${NR_CELL_ACT_MENB_REQ}    Set Variable    ${ENDC_CELL_ACT_REQ_X2}
    ${NR_CELL_ACT_MENB_SUC}    Set Variable    ${ENDC_CELL_ACT_ACC_X2}
    &{pdml_dict}  Create Dictionary
    ...    M55112C00020=${ENDC_CELL_ACT_REQ_X2}
    ...    M55112C00021=${ENDC_CELL_ACT_ACC_X2}
    ...    M55113C00011=${NR_CELL_ACT_MENB_REQ}
    ...    M55113C00012=${NR_CELL_ACT_MENB_SUC}
    [Return]    ${pdml_dict}


Verify Pdml 10442 EC1
    [Documentation]
    ...    Counts number of occurrences of needed mesg and check if occurrences equal 1
    ...    Counters names to pdml logs mapping:
    ...    M55110C00013 -> ErrorIndication

    [Arguments]    ${pcap_file_path}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pcap

    Log To Console                  __Convert pcap to pdml...
    Run Keyword And Ignore Error    Convert Pcap To Pdml      ${pcap_file_path}
    ${pdml_file_path}               pcap.pdml_path_from_pcap_path  ${pcap_file_path}

    ${X2_ERROR_INDICATION_SENT}    Run    grep -s "ErrorIndication" ${pdml_file_path} | wc -l

    Should Be Equal    '${X2_ERROR_INDICATION_SENT}'    '1'


Get cells info 10442
    [Documentation]
    ...    Gets 5G subsells info. Returns all global cell IDs and nr cell IDs


    @{global_cells_ids}    Create List
    @{nr_cells_ids}        Create List

    ${ids}      Create List
    ${cells}    coam.get_subcells_info    connection=${5G_CONNECTION_ALIAS}
    ${all_cells_data}    8951_lib.get_global_cell_id_and_nr_cell_identity     ${cells}

    FOR  ${cell}  IN  @{all_cells_data}
        Append To List    ${global_cells_ids}    ${cell}[0]
        Append To List    ${nr_cells_ids}        ${cell}[1]
    END

    [Return]      ${global_cells_ids}    ${nr_cells_ids}


Wait For Next PM Counter Interval Starts
    [Arguments]
    ...    ${offset_s}=20
    ...    ${interval_m}=15
    line.write line   \n __wait for next PM counter interval starts with: offset: ${offset_s} and interval: ${interval_m}
    10442_lib.sync_to_reporting_interval   offset_s=${offset_s}    interval_m=${interval_m}

Check if PMs incremented properly for energy saving
    line.write line               \n __Check PM counters for energy saving
    &{counters_values}=     Get Scell Add Counter Values    ${energy_saving_PMs}    interval_m=15
    Run Keyword And Continue On Failure
    ...    1167_lib.Counter Incremented Successfully    M55601C01001    cell_id=10    counter_dict=counters_values    operator=>     value=0
    Run Keyword And Continue On Failure
    ...    1167_lib.Counter Incremented Successfully    M55601C01002    cell_id=10    counter_dict=counters_values    operator===
    Run Keyword And Continue On Failure
    ...    1167_lib.Counter Incremented Successfully    M55601C01003    cell_id=10    counter_dict=counters_values    operator===     value=0
    Run Keyword And Continue On Failure
    ...    1167_lib.Counter Incremented Successfully    M55601C01004    cell_id=10    counter_dict=counters_values    operator===     value=0


Wait For 5G Energy Saving Cells Are In Power Saving State
    [Documentation]
    ...    Checks for energy saving state active 5G cells
    [Arguments]
    ...    ${5G_cell}=10
    ...    ${check_time}=5min
    line.write line               \n __Wait for 5G cell-${5G_cell} status change to energy saving
    Wait Until Keyword Succeeds    ${check_time}    30sec    Check 5G Energy Saving Cell Status     ${5G_cell}

Wait For 5G Energy Saving Cells Are Out Power Saving State
    [Documentation]
    ...    Checks for energy saving state deactive 5G cells
    [Arguments]
    ...    ${5G_cell}=10
    ...    ${check_time}=5min
    line.write line               \n __Wait for 5G cell-${5G_cell} status change to notEnergySaving
    Wait Until Keyword Succeeds    ${check_time}    30sec    Check 5G Energy Saving Cell Status deactivated     ${5G_cell}

Wait For 5G reduced Energy Saving Cells Are In
    [Documentation]
    ...    Checks for reduced energy saving state active 5G cell/s
    [Arguments]
    ...    ${5G_cell}=10
    ...    ${check_time}=5min
    line.write line               \n __Wait for 5G cell-${5G_cell} status change to reducedEnergySaving
    Wait Until Keyword Succeeds    ${check_time}    30sec    Check 5G reduced Energy Saving Cell Status activated     ${5G_cell}

Wait For 5G RU Is In Deep Sleep mode
    [Arguments]
    ...    ${timeout}=12min
    ...    ${retry_interval}=90sec
    ...    ${5g_Radio_modules}=AZQJ
    ...    ${RU_status}=SLEEP
    line.write line               \n __Wait for ${RU_status} status on RU
    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}    Check 5G Deep Sleep RU Status     ${5g_Radio_modules}    ${RU_status}


Wait For 5G RU back from Energy Saving and Deep Sleep state to ProceduralStatus Configured
    [Arguments]
    ...    ${timeout}=15min
    ...    ${retry_interval}=30sec
    ...    ${5g_Radio_modules}=AZQJ
    ...    ${RU_ProceduralStatus}=configured
    line.write line               \n __Wait for ${RU_ProceduralStatus} status on RU
    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}    Check 5G Deep Sleep RU Status back to configured
    ...    ${5g_Radio_modules}
    ...    ${RU_ProceduralStatus}


Check 5G Deep Sleep RU Status back to configured
    [Documentation]
    ...    Checks deepsleep for RU, should back to configured

    [Arguments]
    ...    ${5g_Radio_modules}
    ...    ${RU_ProceduralStatus}

    Conect to gNB admin
    ${5g_bts_info}    coam.get_bts_info    30    ${5G_CONNECTION_ALIAS}
    ${5g_RU_info}  Set Variable    ${5g_bts_info['radioModules']['rmod']}
    10442_lib.verify_deep_sleep_Deactivation_due_ES_finished    ${5g_Radio_modules}    ${RU_ProceduralStatus}    @{5g_RU_info}


Check 5G Deep Sleep RU Status
    [Documentation]
    ...    Checks deepsleep for RU

    [Arguments]
    ...    ${5g_Radio_modules}
    ...    ${RU_status}

    Conect to gNB admin
    ${5g_bts_info}    coam.get_bts_info    60    ${5G_CONNECTION_ALIAS}
    ${5g_RU_info}  Set Variable    ${5g_bts_info['radioModules']['rmod']}
    10442_lib.verify_deep_sleep_activation    ${5g_Radio_modules}    ${RU_status}    @{5g_RU_info}


Check X2 during Deepsleep
    [Arguments]
    ...    ${duration}=1200
    ...    ${sleep}=120
    line.write line               \n __X2 Link Status will be check during all time ${duration} seconds, and check every ${sleep} seconds
    verify_x2_link_status_in_loop   eNB_id=${MRBTS_LTE_ID}  expected_status=available    duration=${duration}    sleep=${sleep}


Conect to gNB admin
    [Arguments]    ${connection}=gNB
    coam.connect to        bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
                  ...      username=${tl.gnbs[0].cu.oam_http_connection_details.username}
                  ...      password=${tl.gnbs[0].cu.oam_http_connection_details.password}
                  ...      name=${connection}


Activate 10442 and 10766
    [Documentation]
    ...    Preforms delta commissioning with parameters which activates 10442 feature

    [Arguments]
    ...    ${actCoordinated4g5gPowerSaving}=cellDeactAndReact
    ...    ${actNrLBPowerSaving}=true
    ...    ${actNrMixedSOMethod}=true
    ...    ${lbpsSOMethod}=mixed switch off

    line.write line               \n __Activate energy saving CB010442 feature
    ds.initialise_delta_store
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actCoordinated4g5gPowerSaving    value=${actCoordinated4g5gPowerSaving}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actNrLBPowerSaving               value=${actNrLBPowerSaving}
    ds.Add Param To Delta    ${MAIN_SCF_PATH}    actNrMixedSOMethod               value=${actNrMixedSOMethod}
    ds.Add Param To Delta    MRBTS-${bts_id}/NRBTS-${bts_id}/NRPGRP-1    lbpsSOMethod      value=${lbpsSOMethod}
    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}


Perform basic NRPGRP Delta 10442
    [Documentation]
    ...    Preforms delta commissioning for NRPGRP object

    [Arguments]
    ...    ${lbpsLastCellSOEnabled}=true

    ds.initialise_delta_store
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsCSONCtlEnabled        value=true
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsLastCellMinLoad       value=1
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsLastCellRTXMinLoad    value=1
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsLastCellSOEnabled     value=${lbpsLastCellSOEnabled}
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsMaxLoad               value=2
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsMinLoad               value=1
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsMonWinForCellSOff     value=60
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsMonWinForCellSOn      value=120
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsPdcchLoadOffset       value=4
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsRTXCellCapOffset      value=80
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsRTXMaxLoad            value=2
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsRTXMinLoad            value=1
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsRTXSOffTime           value=300
    ds.add_param_to_delta     ${MAIN_SCF_PATH}/NRPGRP-1    lbpsRTXSOnTime            value=120
    ${delta}    ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Verify If All Cells Are Onair


Create Delta for DeepSleep scheduler
    [Arguments]
    ...    ${dayOfWeek}=Every day
    ...    ${windowDuration}=35
    ...    ${actRadioDeepSleepTimeSchedule}=true
    ...    ${energySavingMode}=DEEPSLEEP
    ...    ${RMOD_id}=5

    ${current_time} =    Get Bts Time    ${BTS_ADDRESS}
    Log    Current Time: ${current_time}
    ${new_time} =    Get Deep Sleep Remaining Time    ${BTS_ADDRESS}
    Log    New Time after adding 5 minutes: ${new_time}
    line.write line       \n __Activate Deep Sleep state CB010766 feature, and prepare dayOfWeek, startTime, windowDuration for DeepSleep mode
    ds.initialise_delta_store
    ds.add_list_parameters_to_delta    dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-${RMOD_id}
    ...    list_name=deepSleepTimeSchedule
    ...    dayOfWeek=${dayOfWeek}
    ...    startTime=${new_time}
    ...    windowDuration=${windowDuration}
    ds.add_param_to_delta
    ...    MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-${RMOD_id}
    ...    energySavingMode
    ...    value=${energySavingMode}
    ds.add_param_to_delta
    ...    MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actRadioDeepSleepTimeSchedule
    ...    value=${actRadioDeepSleepTimeSchedule}
    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}


Add NRPGRP LBPS lists for power saving mode
    [Documentation]
    ...    Adds parameters needed for creating NRPGRP object and for preforming NRPGRP delta to delta object

    [Arguments]    ${nrCellId}=10

    line.write line               \n __Prepare days, time for energy saving state
    ${lbpsPeriodDaysList}    Create List
    FOR    ${day}    IN    @{DAYS}
        &{lbpsPeriodList}    Create Dictionary
        ...                  lbpsDayOfWeek=${day}
        ...                  lbpsDuration=1440
        ...                  lbpsStartTimeHour=7
        ...                  lbpsStartTimeMinute=0
        ...                  lbpsSuspended=notSuspended

        Append To List    ${lbpsPeriodDaysList}    ${lbpsPeriodList}
    END

    ${lbpsCellList}    Create List

    ${lbpsCell}    Create Dictionary
    ...            lbpsCellSOOrder=10
    ...            lbpsUseExtConfig=false
    ...            nrCellId=${nrCellId}
    Append To List    ${lbpsCellList}    ${lbpsCell}
    ds.initialise_delta_store
    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1  lbpsCellList          @{lbpsCellList}
    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1  lbpsPeriodList        @{lbpsPeriodDaysList}
    ${delta}    ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Verify If All Cells Are Onair

Perform commissioning SCF if
    [Arguments]    ${if_10766}=${FALSE}    ${if_10683}=${FALSE}
    Run Keyword If    ${if_10766} == ${TRUE}
    ...    Run Keywords
    ...    Upload scf and perform commissioning  ${scf_file_10766}                                            AND
    ...    line.write line    \n __perform default commissioning with SCF path ${scf_file_10766}              AND
    ...    coam.connect to    name=commissioning_10766                                                        AND
    ...    coam.perform_commissioning    scf_file=${scf_file_10766}    connection=commissioning_10766         AND
    ...    coam.Teardown    connection=commissioning_10766
    Run Keyword If    ${if_10683} == ${TRUE}
    ...    Run Keywords
    ...    Upload scf and perform commissioning  ${scf_file_10683}                                            AND
    ...    line.write line    \n __perform default commissioning with SCF path ${scf_file_10683}              AND
    ...    coam.connect to    name=commissioning_10683                                                        AND
    ...    coam.perform_commissioning    scf_file=${scf_file_10683}    connection=commissioning_10683         AND
    ...    coam.Teardown    connection=commissioning_10683

Add NRPGRP LBPS lists for power saving mode 10683
    [Documentation]
    ...    Adds parameters needed for creating NRPGRP object and for preforming NRPGRP delta to delta object

    [Arguments]    ${nrCellId}=999    ${actNrLBmMimoRTXPowerSaving}=true    ${lbpsSOMethod}=mixed switch off
    ...            ${actNrMixedSOMethod}=true    ${actNrLBPowerSaving}=true    ${lbpsCellDuration}=1440
    ...            ${lbpsCellSOMethod}=TX switch off    ${lbpsUseExtConfig}=false   ${lbpsCellSOOrder}=10
    ...            ${lbpsSuspended}=notSuspended    ${actNrExtCellSOMethod}=false    ${lbpsRTXCellCapOffset}=80
    ...            ${lbpsRTXMinLoad}=30    ${lbpsRTXSOffTime}=90    ${lbpsRTXMaxLoad}=60    ${lbpsRTXSOnTime}=180

    ${curr}    ${new}    ${form}    ${hour}    ${min}=    get_separate_hours_minutes_from_time    ${BTS_ADDRESS}

    ${lbpsPeriodDaysList}    Create List
    FOR    ${day}    IN    @{DAYS}
        &{lbpsPeriodList}    Create Dictionary
        ...                  lbpsDayOfWeek=${day}
        ...                  lbpsDuration=${lbpsCellDuration}
        ...                  lbpsStartTimeHour=${hour}
        ...                  lbpsStartTimeMinute=${min}
        ...                  lbpsSuspended=${lbpsSuspended}

        Append To List    ${lbpsPeriodDaysList}    ${lbpsPeriodList}
    END

    ${lbpsCellList}    Create List
    ${lbpsCell}    Create Dictionary
    ...            lbpsCellSOOrder=${lbpsCellSOOrder}
    ...            lbpsUseExtConfig=${lbpsUseExtConfig}
    ...            nrCellId=${nrCellId}
    Append To List    ${lbpsCellList}    ${lbpsCell}

    ${lbpsCellPeriodDaysList}    Create List
    FOR    ${day}    IN    @{DAYS}
        &{lbpsCellPeriodList}    Create Dictionary
        ...                  lbpsCellDayOfWeek=${day}
        ...                  lbpsCellDuration=${lbpsCellDuration}
        ...                  lbpsCellSOMethod=${lbpsCellSOMethod}
        ...                  lbpsCellStartTimeHour=${hour}
        ...                  lbpsCellStartTimeMinute=${min}
        ...                  nrCellId=${nrCellId}

        Append To List    ${lbpsCellPeriodDaysList}    ${lbpsCellPeriodList}
    END

    ds.initialise_delta_store
    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1   lbpsCellList          @{lbpsCellList}
    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1   lbpsPeriodList        @{lbpsPeriodDaysList}
    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1   lbpsCellPeriodList    @{lbpsCellPeriodDaysList}
    ds.add_param_to_delta                 ${MAIN_SCF_PATH}/NRPGRP-1   lbpsSOMethod          value=${lbpsSOMethod}
    ds.add_param_to_delta                 ${MAIN_SCF_PATH}/NRPGRP-1   lbpsRTXMinLoad        value=${lbpsRTXMinLoad}
    ds.add_param_to_delta                 ${MAIN_SCF_PATH}/NRPGRP-1   lbpsRTXMaxLoad        value=${lbpsRTXMaxLoad}
    ds.add_param_to_delta                 ${MAIN_SCF_PATH}/NRPGRP-1   lbpsRTXCellCapOffset     value=${lbpsRTXCellCapOffset}
    ds.add_param_to_delta                 ${MAIN_SCF_PATH}/NRPGRP-1   lbpsRTXSOffTime          value=${lbpsRTXSOffTime}
    ds.add_param_to_delta                 ${MAIN_SCF_PATH}/NRPGRP-1   lbpsRTXSOnTime           value=${lbpsRTXSOnTime}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actNrLBmMimoRTXPowerSaving      value=${actNrLBmMimoRTXPowerSaving}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actNrMixedSOMethod              value=${actNrMixedSOMethod}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actNrLBPowerSaving              value=${actNrLBPowerSaving}
    ds.add_param_to_delta    ${MAIN_SCF_PATH}    actNrExtCellSOMethod            value=${actNrExtCellSOMethod}

    ${delta}    ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    line.write line               \n __Delta commissioning CB010683 done
    Verify If All Cells Are Onair

show current time
    ${curr}    ${new}    ${form}    ${hour}    ${min}=    get_separate_hours_minutes_from_time    ${BTS_ADDRESS}
    line.write line   \n __Traffic start with time: ${curr}

Get KPIs Report from Scout then Validate them and Send to Reporting Portal
    [Arguments]     ${scout_data_collect_start_time}    ${is_enabled}=${FALSE}
    ${kpi_list}   Get Dictionary Keys   ${KPIs}
    FOR   ${kpi}   IN   @{kpi_list}
        ${sum}  ${avg_value}   link_wro4_570.get_kpi_values
        ...                    kpi=${KPIs}[${kpi}][name]
        ...                    start_time=${scout_data_collect_start_time}
        ...                    level=${KPIs}[${kpi}][level]
        ...                    timeout=2160
        ...                    retry_interval=180
        ${value_to_report}   Convert To String   ${avg_value}
        Run Keyword If    ${is_enabled} == ${FALSE}
        ...    Set To Dictionary    ${DISABLED_dictionary}        ${KPIs}[${kpi}][name]=${avg_value}
        Run Keyword If    ${is_enabled} == ${TRUE}
        ...    Run Keyword And Continue On Failure    Validate KPI   ${kpi}  ${avg_value}    ${DISABLED_dictionary}

        taf.sw.reporting_portal.Report KPI Results
        ...   name=${KPIs}[${kpi}][kpi_id]
        ...   target=${KPIs}[${kpi}][target]
        ...   value=${value_to_report}
        ...   visible_to_db=True
        ...   kpi_type=${KPIs}[${kpi}][type]
        ...   description=${KPIs}[${kpi}][description]
        ...   category=Performance
        ...   unit=${KPIs}[${kpi}][unit]
    END

Validate KPI
    [Arguments]   ${kpi}  ${value_to_report}     ${DISABLED_dictionary}    ${deviation}=3%

    Run Keyword And Continue On Failure    verify_if_KPI_in_deviation
    ...    ${deviation}    ${DISABLED_dictionary}[${kpi}]    ${value_to_report}
    Log To Console
    ...   \n${kpi} measurements:\n MIN ACCEPTED: ${KPIs}[${kpi}][target] ${KPIs}[${kpi}][unit],\n MEASURED: ${value_to_report} ${KPIs}[${kpi}][unit]


Add NRPGRP LBPS lists for power saving mode with real test time
    [Documentation]
    ...    Adds parameters needed for creating NRPGRP object and for preforming NRPGRP delta to delta object

    [Arguments]
    ...    ${nrCellId}=10    ${lbpsDuration}=1440

    ${current_time} =    Get Bts Time    ${BTS_ADDRESS}
    Log    Current Time: ${current_time}
    ${curr}    ${new}    ${form}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}=    get_separate_hours_minutes_from_time    ${BTS_ADDRESS}

    line.write line               \n __Prepare days, time for energy saving state
    ${lbpsPeriodDaysList}    Create List
    FOR    ${day}    IN    @{DAYS}
        &{lbpsPeriodList}    Create Dictionary
        ...                  lbpsDayOfWeek=${day}
        ...                  lbpsDuration=${lbpsDuration}
        ...                  lbpsStartTimeHour=${lbpsStartTimeHour}
        ...                  lbpsStartTimeMinute=${lbpsStartTimeMinute}
        ...                  lbpsSuspended=notSuspended

        Append To List    ${lbpsPeriodDaysList}    ${lbpsPeriodList}
    END

    ${lbpsCellList}    Create List

    ${lbpsCell}    Create Dictionary
    ...            lbpsCellSOOrder=10
    ...            lbpsUseExtConfig=false
    ...            nrCellId=${nrCellId}
    Append To List    ${lbpsCellList}    ${lbpsCell}
    ds.initialise_delta_store
    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1  lbpsCellList          @{lbpsCellList}
    ds.add_list_of_dictionaries_to_delta  ${MAIN_SCF_PATH}/NRPGRP-1  lbpsPeriodList        @{lbpsPeriodDaysList}
    ${delta}    ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}
    Verify If All Cells Are Onair


CHECK TIME
    ${current_time} =    Get Bts Time    ${BTS_ADDRESS}
    Log    Current Time: ${current_time}
    ${curr}    ${new}    ${form}    ${hour}    ${min}=    get_separate_hours_minutes_from_time    ${BTS_ADDRESS}
    Log    current time: ${curr}
    Log    New Time after adding 5 minutes: ${new}
    Log    format new Time: ${form}
    Log    Hour to setup: ${hour}
    Log    Minutes to setup: ${min}
