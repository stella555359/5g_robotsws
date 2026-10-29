*** Settings ***
Documentation
...  Author:        Maciej Cupial, Adam Tokarski
...  Contact:       maciej.cupial@nokia.com, adam.tokarski@nokia.com
...  Feature owner: Karol Malutkiewicz, Witold Galka
...  Description:   Power Saving feature for 5G site
...                 Feature Corner:     https://feature-corner.nsn-net.net/materials/clbkj7uvc2084464wkzdj046wlm

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         Collections
Library         String
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py            WITH NAME    ah
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py            WITH NAME    ds
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010443/resources/keywords_9920.py                WITH NAME    9920_lib
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.py      WITH NAME    pcap
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010442/resources/keywords_8951.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/logs_collection.robot

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_cplane.py
Library         pcap_cplane.pdml            WITH NAME   pdmlp
Library         taf.converters.pcaptopdml   WITH NAME   pcaptopdml


*** Variables ***
${BTS_ID}                ${tl.gnbs[0].instance_id}
${MRBTS_LTE_ID}          ${tl.enbs[0].instance_id}
${LTE_MPLANE}            ${tl.enbs[0].m.v4}
${MAIN_SCF_PATH}         MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
${MAIN_LTE_SCF_PATH}     MRBTS-${MRBTS_LTE_ID}/LNBTS-${MRBTS_LTE_ID}
${LTE_CONNECTION_ALIAS}  eNB
@{ALLOWED_FAULTS_IDS}    4655  61524  4654  61649  61652  8150  4681
${cell_to_lock}           MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-3
${global_cells_ids}
${nr_cells_ids}


*** Keywords ***
Prepare and activate feature 8951 and 9920
    [Documentation]
    ...    Part of [1]CB008951_A#B1_A#B2 responsible for activating feature 8951 with logs checking

    [Arguments]
    ...    ${pcap_file_path}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pcap
    ${global_cells_ids}     ${nr_cells_ids}        Get cells info
    Set Suite Variable     ${global_cells_ids}    ${global_cells_ids}
    Set Suite Variable     ${nr_cells_ids}        ${nr_cells_ids}
    Check If 5G 8951 Is Deactivated As Initial Status
    Perform Commissioning 8951 5G   ${global_cells_ids}    actCoordinated4g5gPowerSaving=disabled
    Setup Cplane Tcpdump Collector
    Start Cplane Logs
    Activate 8951
    Activate 9920
    Wait Until Cells Status         ${global_cells_ids}[0]    power_saving_status=on
    Stop Cplane Logs
    Log To Console                  __Convert pcap to pdml
    Run Keyword And Ignore error    Convert pcap to pdml      ${pcap_file_path}
    ${pdml_file_path}               pcap.pdml_path_from_pcap_path  ${pcap_file_path}
    Verify If nRcellIdentifier Is Equal To Power Saving Nr Cell Id    ${pdml_file_path}    ${nr_cells_ids}[0]
    Verify If nrDeactivationIndication Is Deactivated    ${pdml_file_path}
    Log To Console  __Feature CB008951 activated with success!


Deactivate 9920
    [Documentation]
    ...    Set param LNBTS-actCoordinated4g5gPowerSaving = 0 (disabled)

    Log To Console    __Deactivate 9920
    ds.initialise_delta_store
    ds.add_param_to_delta        ${MAIN_LTE_SCF_PATH}    actCoordinated4g5gPowerSaving         value=disabled
    ${delta}    ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}      connection=${LTE_CONNECTION_ALIAS}
    Verify If All Cells Are Onair


Check If Counter M8080C163 Is Available
    coam.connect_to   bts_host=${LTE_MPLANE}
    &{counters}       coam.get_pm_counters    M8080C163
    ${lte_cells_ids}  Get LTE Cells Ids

    ${is_higher}    check_release_is_higher_than    SBTS23R4

    ${lte_cell_list}         9920_lib.get_lte_cell_list                ${lte_cells_ids}
    ${last_counter_value}    9920_lib.get_counter_for_all_lte_cells
    ...  ${is_higher}
    ...  ${MRBTS_4G_ID}
    ...  ${counters}
    ...  M8080C163
    ...  ${lte_cell_list}

    ${result}    9920_lib.return_counter_sum_value_from_all_lte_cells  ${last_counter_value}
    [Return]     ${result}
    [Teardown]   run keyword and ignore error    coam.teardown


Check if initial M8080C163 counter value is zero
    [Documentation]
    ...    Wait for counter appearance and check if initial value is equal zero

    [Arguments]  ${duration}=5min
    ...          ${interval}=1min
    Log To Console       __Check if counter M8080C163 equals zero
    ${counter_value}=    Wait Until Keyword Succeeds
    ...    ${duration}
    ...    ${interval}
    ...    Check If Counter M8080C163 Is Available

    Should Be Equal    '${counter_value}'    '0'
    Log To Console     __Counter value OK (equals 0)


Collect Counter M8080C163 And Check Value
    [Documentation]
    ...    Collect M8080C163 from all LTE cells and check if the sum is more than zero

    [Arguments]  ${duration}=5min
    ...          ${interval}=1min
    Log To Console       __Check if counter M8080C163 differs from zero
    ${counter_value}=    Wait Until Keyword Succeeds
    ...    ${duration}
    ...    ${interval}
    ...    Check If Counter M8080C163 Is Available

    # TODO: check if value equals attach count and check value in cplane; write separate kw for this
    Should Not Be Equal    '${counter_value}'    '0'    __Counter value not OK (counter value Should Not Be Equal 0)
    Log To Console         __Counter value OK (counter value: ${counter_value})


Activate 9920
    [Documentation]
    ...    Set param LNBTS-actCoordinated4g5gPowerSaving = 1 (cellDeactivation)

    Log To Console    __Activate 9920
    ds.initialise_delta_store
    ds.add_param_to_delta        ${MAIN_LTE_SCF_PATH}    actCoordinated4g5gPowerSaving         value=cellDeactivation
    ${delta}    ds.collect_delta_store
    ah.recommission_with_delta_from_admin  ${delta}      connection=${LTE_CONNECTION_ALIAS}
    Verify If All Cells Are Onair


Verify 9920_1 Activation
    [Documentation]
    ...    Verify if CB009920 was activated with success with no alarms and errors

    ${ids}              Create List
    coam.connect_to     bts_host=${LTE_MPLANE}
    ${lnrelgnbcells}    coam.get_managed_objects        class_name=LNRELGNBCELL_A
    ${9920_activated}   9920_lib.check_9920_activation  ${nr_cells_ids}[0]  @{lnrelgnbcells}
    Should be true      ${9920_activated}
    [Teardown]          coam.teardown


Verify 9920_2 Activation
    [Documentation]
    ...    The only way we know to check 9920 activation is checking unexpected fauls (mainly X2 faults)

    # Check 5G site
    coam.connect_to     name=5G
    FOR  ${faultId}   IN   @{ALLOWED_FAULTS_IDS}
        coam.add_allowed_alarm    faultId=${faultId}   connection=5G
    END
    coam.assert_no_unexpected_active_alarms   connection=5G
    coam.teardown      connection=5G
    # Check LTE site
    coam.connect_to     bts_host=${LTE_MPLANE}    name=LTE
    FOR  ${faultId}   IN   @{ALLOWED_FAULTS_IDS}
        coam.add_allowed_alarm    faultId=${faultId}   connection=LTE
    END
    coam.assert_no_unexpected_active_alarms   connection=LTE
    coam.teardown      connection=LTE


Get LTE Cells Ids
    ${ids}     Create List
    coam.connect_to    bts_host=${LTE_MPLANE}
    ${cells}    coam.get_managed_objects    class_name=LNCEL_A
    FOR    ${cell_id}    IN    @{cells}
        ${id}    Fetch From Right    ${cell_id}[distName]    LNCEL_A-
        Append To List    ${ids}     ${id}
    END
    [Return]      ${ids}


Prepare And Deactivate Feature 8951
    [Documentation]
    ...    Part of [1]CB008951_A#B1_A#B2 responsible for deactivating feature 8951 with checking cells

    Deactivate 8951
    Wait Until Cells Status    ${global_cells_ids}[0]    power_saving_status=off
    Log To Console  __Feature CB008951 deactivated with success!


Triggering Counter By Attach Loop
    Set Attenuation And Check     ${cells_to_deactivate}     ${90}
    Sleep    5sec
    FOR    ${idx}  IN RANGE    ${7}
        Log To Console    attach no.${idx} is ongoing...
        Attach Ue  ${ue_alias}
        Sleep      3sec
        Detach UE  ${ue_alias}
    END


Check Lte Cells
    ${ids}              Create List
    coam.connect_to     bts_host=${LTE_MPLANE}
    ${lnrelgnbcells}    coam.get_managed_objects        class_name=LNRELGNBCELL_A
    ${cells_to_attenuate}   9920_lib.check_where_ue_should_be_attached     ${nr_cells_ids}[0]     @{lnrelgnbcells}
    Set Attenuation And Check     ${cells_to_attenuate}     ${90}
    [Teardown]          coam.teardown


Commissioning 9920 7 LTE
    Log To Console    __Perform commissioning on LTE site
    ds.initialise_delta_store

    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}          actLteNrDualConnectivity         value=true
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}          actUeBasedAnrNr                  value=true
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}          actCoordinated4g5gPowerSaving    value=cellDeactivation
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}          endcAnrAutoRemDisallNrCellEss    value=true
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}/ANR-0    actAutoNrNeighRemoval            value=true
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}/ANR-0    anrNrNbrRelRemGuardTime          value=2
    # Due to Trunk relation error
    run keyword if  '${TEST_NAME}' == '[1]CB009920_7_power_saving_Removal_of_LNRELGNBCELL_negative'
    ...  ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}  actDynTrigLteNrDualConnectivity  value=true


    ${anrNrParamList}    Create List
    &{anrNrParamListParams}    Create Dictionary
    ...                        gNBIdLength=22
    ...                        paramMeasConfId=1
    ...                        anrDefRelDcAllowed=true
    ...                        frqNrCarSelect=All
    ...                        paramPlmnId=0
    Append To List    ${anrNrParamList}    ${anrNrParamListParams}

    ${anrNrMeasConfList}    Create List
    &{anrNrMeasConfListParams}    Create Dictionary
    ...                        paramMeasConfId=1
    ...                        thresholdNrRsrp=66     # -90 in dBm
    ...                        thresholdNrRsrq=-80    # -40 in dB
    Append To List    ${anrNrMeasConfList}    ${anrNrMeasConfListParams}

    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}/ANR-0    anrNrParamList       ${anrNrParamList}
    ds.add_param_to_delta   ${MAIN_LTE_SCF_PATH}/ANR-0    anrNrMeasConfList    ${anrNrMeasConfList}

    ${delta}    ds.collect_delta_store
    ah.recommission_with_delta_from_admin    ${delta}    connection=${LTE_CONNECTION_ALIAS}


Commissioning 9920 7 5G
    [Arguments]
    ...    ${nrCellIds}

    Log To Console    __Perform commissioning on 5G site
    ${status}	${value} =  Run Keyword And Ignore Error    Add NRPGRP Object    ${nrCellIds}
    Run Keyword If	'${status}' == 'FAIL'    Perform NRPGRP Delta    ${nrCellIds}

    ds.initialise_delta_store
    ds.add_param_to_delta   ${MAIN_SCF_PATH}    actCoordinated4g5gPowerSaving    value=cellDeactivation
    ds.add_param_to_delta   ${MAIN_SCF_PATH}    actNrLBPowerSaving               value=true
    ${delta}       ds.collect_delta_store
    ah.recommission_with_delta_from_admin    ${delta}


Deactivate endcAnrAutoRemDisallNrCellEss
    ds.initialise_delta_store

    ds.add_param_to_delta    ${MAIN_LTE_SCF_PATH}    endcAnrAutoRemDisallNrCellEss    value=false

    ${delta}    ds.collect_delta_store
    ah.recommission_with_delta_from_admin    ${delta}    connection=${LTE_CONNECTION_ALIAS}


Wait for anrNrNbrRelRemGuardTime and Verify LNRELGNBCELL Removal
    [Arguments]
    ...    ${cell_id}

    Log To Console    __Waiting for anrNrNbrRelRemGuardTime runs out
    Wait Until Keyword Succeeds    2h 15m    15m    LNRELGNBCELL removal verification    ${cell_id}


Get LNRELGNBCELL statuses
    coam.connect_to     bts_host=${LTE_MPLANE}  name=LTE
    ${objects}          coam.Get managed objects    class_name=LNRELGNBCELL_A   connection=LTE
    coam.teardown       connection=LTE
    [Return]            ${objects}


Verify LNRELGNBCELL pwSavingDeactInd
    [Arguments]
    ...    ${cell_id}
    ...    ${expected_value}

    ${data}    Get LNRELGNBCELL statuses
    ${result}    verify_lnrelgnbcell    ${cell_id}    ${expected_value}    @{data}
    Should Be True    ${result}


LNRELGNBCELL removal verification
    [Arguments]
    ...    ${cell_id}

    ${data}    Get LNRELGNBCELL statuses
    ${result}    verify_lnrelgnbcell_removal    ${cell_id}    @{data}
    Should Be True    ${result}


Set default lnRelGnbCellId
    [Documentation]  Set defaultLnRelGnbCellId=0 to make default NSA cell relation with 1st 5G cell. It will trigger
    ...              sGnb Reject with Cell No Available resason. LNRELCELL-0 is usualy related with 1st 5G cell in our
    ...              configurations.

    ds.initialise_delta_store
    ${lte_cells_ids}         Get LTE Cells Ids

    FOR    ${cell_id}    IN    @{lte_cells_ids}
        ds.add_param_to_delta        ${MAIN_LTE_SCF_PATH}/LNCEL-${cell_id}    defaultLnRelGnbCellId       value=${0}
    END

    ${delta}    ds.collect_delta_store
    ah.recommission_with_delta_from_admin    ${delta}    connection=${LTE_CONNECTION_ALIAS}


Lock non energy saving nr cells
    [Documentation]  This keyword should be performed before M8080C163 collection. If BTS has active cells other than
    ...              X2 default realtion. Counter won't be triggered.
    coam.connect_to     name=cell_lock
    log to console  Locking other NR cells -> ${cell_to_lock} ....
    coam.lock  ${cell_to_lock}  timeout=400  connection=cell_lock
    [Teardown]          coam.teardown  connection=cell_lock
