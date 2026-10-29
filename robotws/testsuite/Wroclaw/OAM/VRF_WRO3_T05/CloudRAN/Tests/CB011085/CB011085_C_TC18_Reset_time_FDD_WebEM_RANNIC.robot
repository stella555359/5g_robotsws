*** Settings ***
Documentation
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is used to verify the KPI 30 (RAN NIC reset downtime) for vdu.
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 18.11.2024 - Initial creation
    ...  - 21.03.2025 - Watchdog implementation for alarms handling
    ...  - 16.04.2025 - Removed 20min sleep between resets (backoff time) as it's not valid anymore.

*** Variables ***
${N_rannic_reset_loops}   3     # number of reset loops per RU
${KPI_30_target}          360   # base KPI target in seconds
@{KPI_30_results}               # list to store KPI results

# lists for each excepted RU family containing every model belonging to said family
@{MASTER_family_RUs}  AEQB  AEQE  AEQP  AEQK  AEQH  AEQJ  AEQI  AEQM  AEQU
@{AMBER_family_RUs}  AEQV  AEQY  AEQZ  AEQQ  AEQC  AENB  AEHE  AEQW
@{PULSAR_family_RUs}  AZQH  AZQL  AZQM  AZQG
@{CHILE_family_RUs}  AEHB  AEHC
@{SCORPIO_family_RUs}  AZQP  AZQO  AZQW  AZHM  AZHL  AZQS  AZQU  AZQI  AZQJ  AZHN  AZTA
@{MEGATRON_family_RUs}  AQQE  AQQL  AQQK  AQQN  AQQS  AQNA  AQQT
@{GALVATRON_family_RUs}  AQQY  AQQA  AQQC  AQQQ  AQQJ  AQQH  AQHA  AQHC  AQQF  AQHB  AQQV
@{ZODIAC_family_RUs}  AHEGHA  AHFII  AHLOB  AHFIHA  AHPMDG  AHEGG  AHEGH   AHEGSA  AREC  AHPMDK  AHEGK
@{BARYON_family_RUs}  AWMFIA
@{MAVERICK_family_RUs}  AKQJ  AKQI  AKNB  AKQZ  AKNA  AKQA  AKQL  AKQW  AKHD  AKHM  AKFA  AKHC
@{PHOTON_family_RUs}  AWHQN  AWHQ2  AWHQU  AWHQ2  AWHNB  AWHHJ  AWHNA  AWHQ3
@{YODA_family_RUs}  AVQL  AVQR  AVQE  AVQK  AVHA  AVQG
@{LEPTON_family_RUs}  AEUB  AEWB  AWHHF  AWHHI  AWHQM  AWHQV  AWHQE  AWHQF  AWHKA  AWHKB  AWHHG  AWHHK
@{AEQN_family_RUs}  AEQN

# dictionary for every excepted RU family mapping extra time to target as per OM_GEN_SFS_PERF_CAP.12847
&{EXCEPTION_FAMILY_TIMES_DICT}  MASTER=240  AMBER=240  AEQN=240  PULSAR=NA  CHILE=240  SCORPIO=240  MEGATRON=120  GALVATRON=120  ZODIAC=120
...  BARYON=120  MAVERICK=120  PHOTON=30  YODA=30  LEPTON=240

# dictionary mapping excepted RU family names to model lists
&{FAMILY_DICT}  MASTER=${MASTER_family_RUs}  AMBER=${AMBER_family_RUs}  PULSAR=${PULSAR_family_RUs}  CHILE=${CHILE_family_RUs}
...  SCORPIO=${SCORPIO_family_RUs}  MEGATRON=${MEGATRON_family_RUs}  GALVATRON=${GALVATRON_family_RUs}    ZODIAC=${ZODIAC_family_RUs}
...  BARYON=${BARYON_family_RUs}  MAVERICK=${MAVERICK_family_RUs}  PHOTON=${PHOTON_family_RUs}  YODA=${YODA_family_RUs}
...  LEPTON=${LEPTON_family_RUs}  AEQN=${AEQN_family_RUs}


*** Keywords ***
TC__CB011085_C_TC18_Reset_time_FDD_WebEM_RANNIC
    Step 0: Preconditions
    Step 1: Perform ${N_rannic_reset_loops} Resets Of RAN NIC
    Step 2: Check KPI For Each Reset And Calculate Average


Step 0: Preconditions
    [Documentation]    Description:    RU units, RNIC information, and MRBTS ID of testline are identified and corresponding necessary variables are
    ...                                set. __init__.py is checked to find whether testline uses FHGW or direct connectivity. If necessary, KPI 30
    ...                                target is adjusted as per exceptions in OM_GEN_SFS_PERF_CAP.12847.

    Log  \nStep 0: Preconditions  console=${True}

    #Temporary solution for watchdog, before it will be implemented inside all TCs
    Start Watchdog    hw_type=vCU    log_dir=${TEST_RESULTS_DIR}
    Start Watchdog    hw_type=vDU    log_dir=${TEST_RESULTS_DIR}

    ${rmod_listed}=    vdu_admin.Get Rmods Status    vdu_connection=${vdu_connection}
    Set Test Variable    ${rmod_listed}
    ${ids}=              Create List
    ${product_names}=    Create List

    FOR    ${item}    IN    @{rmod_listed}
        ${product_name}=    Get From Dictionary    dictionary=${item}    key=product_name
        ${dist_names}=      Get From Dictionary    dictionary=${item}    key=dist_names
        ${id}=              Get From Dictionary    dictionary=${item}    key=id
        Append To List    ${product_names}    ${product_name}
        Append To List    ${ids}    ${id}
    END
    Set Test Variable    ${ids}
    Set Test Variable    ${product_names}

    ${rnic_listed}=           vdu_admin.Get Rnic Info From Plan    mrbts_id=${MRBTS}    vdu_connection=${vdu_connection}
    ${rmod_id_product_dict}=  Create Dictionary From Lists    keys=${ids}    values=${product_names}
    Set Test Variable         ${rnic_listed}
    Set Test Variable         ${rmod_id_product_dict}

    IF    ${FHGW_OBJ}
        Log To Console    Testline uses FHGW, RU exceptions are not applicable
        ${additional_time}=    Set Variable    0
    ELSE
        Log To Console    Testline uses direct connectivity, RU exceptions will be considered
        ${additional_time}=    Get Maximum Additional Time For Target Due To Excepted RUs
    END

    ${KPI_30_max_target}=    Evaluate    ${KPI_30_target} + ${additional_time}
    Set Test Variable    ${KPI_30_max_target}

Step 1: Perform ${N_rannic_reset_loops} Resets Of RAN NIC
    [Documentation]     Description:    RAN NIC is reset ${N_rannic_reset_loops} times, the KPI 30 result (startpoint: first cell down,
    ...                                 endpoint: last cell up) is calculated, compared, and saved to list ${KPI_30_results} per each reset.

    Log    \nStep 1: Perform ${N_rannic_reset_loops} Resets Of RAN NIC    console=${TRUE}
    FOR    ${i}    IN RANGE    ${N_rannic_reset_loops}
        Add Alarm to the Allowed List    fault_id=${FAULT_16}[fault_id]    fault_name=${FAULT_16}[fault_name]
        ...                              severity=${FAULT_16}[severity]    hw_type=vDU
        Add Alarm to the Allowed List    fault_id=${FAULT_16_critical}[fault_id]    fault_name=${FAULT_16_critical}[fault_name]
        ...                              severity=${FAULT_16_critical}[severity]    hw_type=vDU
        Add Alarm to the Allowed List    fault_id=${FAULT_7104}[fault_id]    fault_name=${FAULT_7104}[fault_name]
        ...                              severity=${FAULT_7104}[severity]    hw_type=vCU
        Add Alarm to the Allowed List    fault_id=${FAULT_4405}[fault_id]    fault_name=${FAULT_4405}[fault_name]
        ...                              severity=${FAULT_4405}[severity]    hw_type=vDU
        Add Alarm to the Allowed List    fault_id=${FAULT_4298}[fault_id]    fault_name=${FAULT_4298}[fault_name]
        ...                              severity=${FAULT_4298}[severity]    hw_type=vDU
        Add Alarm to the Allowed List    fault_id=${FAULT_4298_critical}[fault_id]    fault_name=${FAULT_4298_critical}[fault_name]
        ...                              severity=${FAULT_4298_critical}[severity]    hw_type=vDU
        Add Alarm to the Allowed List    fault_id=${FAULT_4298_major}[fault_id]    fault_name=${FAULT_4298_major}[fault_name]
        ...                              severity=${FAULT_4298_major}[severity]    hw_type=vDU
        Add Alarm to the Allowed List    fault_id=${FAULT_4647}[fault_id]    fault_name=${FAULT_4647}[fault_name]
        ...                              severity=${FAULT_4647}[severity]    hw_type=vDU
        Log To Console    \nResetting RAN NIC, iteration ${${i}+1}/${N_rannic_reset_loops}
        vdu_admin.Reset Rannic
        ...    rannic_r_dn=${rnic_listed[0]['r_nic_mod_dist_name']}    graceful_cell_shutdown=${FALSE}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    2 minutes    100ms    Check Any Cell Not Enabled
        ${first_cell_down_time}    Get Current Date
        Log To Console    ${first_cell_down_time} - First cell is down
        Wait Until Keyword Succeeds    10 minutes    100ms    Check All Cells Enabled
        ${last_cell_up_time}    Get Current Date
        Log To Console    ${last_cell_up_time} - All cells are enabled
        Remove Alarm from Allowed List    fault_id=${FAULT_16}[fault_id]    fault_name=${FAULT_16}[fault_name]
        ...                               severity=${FAULT_16}[severity]    hw_type=vDU
        Remove Alarm from Allowed List    fault_id=${FAULT_16_critical}[fault_id]    fault_name=${FAULT_16_critical}[fault_name]
        ...                               severity=${FAULT_16_critical}[severity]    hw_type=vDU
        Remove Alarm from Allowed List    fault_id=${FAULT_7104}[fault_id]    fault_name=${FAULT_7104}[fault_name]
        ...                               severity=${FAULT_7104}[severity]    hw_type=vCU
        Remove Alarm from Allowed List    fault_id=${FAULT_4405}[fault_id]    fault_name=${FAULT_4405}[fault_name]
        ...                               severity=${FAULT_4405}[severity]    hw_type=vDU
        Remove Alarm from Allowed List    fault_id=${FAULT_4298}[fault_id]    fault_name=${FAULT_4298}[fault_name]
        ...                               severity=${FAULT_4298}[severity]    hw_type=vDU
        Remove Alarm from Allowed List    fault_id=${FAULT_4298_critical}[fault_id]    fault_name=${FAULT_4298_critical}[fault_name]
        ...                               severity=${FAULT_4298_critical}[severity]    hw_type=vDU
        Remove Alarm from Allowed List    fault_id=${FAULT_4298_major}[fault_id]    fault_name=${FAULT_4298_major}[fault_name]
        ...                               severity=${FAULT_4298_major}[severity]    hw_type=vDU
        Remove Alarm from Allowed List    fault_id=${FAULT_4647}[fault_id]    fault_name=${FAULT_4647}[fault_name]
        ...                               severity=${FAULT_4647}[severity]    hw_type=vDU
        ${downtime}    Subtract Date From Date    ${last_cell_up_time}    ${first_cell_down_time}
        Append To List    ${KPI_30_results}    ${downtime}
        Log To Console    Downtime = ${downtime}s
        Run Keyword And Continue On Failure    Should Be True    ${downtime} < ${KPI_30_max_target}
    END
    Set Test Variable    ${KPI_30_results}

Step 2: Check KPI For Each Reset And Calculate Average
    [Documentation]    Description:     ${KPI_30_results} containing the KPI result for each iteration is used to calculate the average and compare
    ...                                 it to the maximum target.

    Log To Console    \nStep 2: Check KPI For Each Reset And Calculate Average
    Calculate Average And Check Result    ${KPI_30_results}

    #Temporary solution for watchdog, before it will be implemented inside all TCs
    Check if Disallowed Alarm was Detected during Watchdog    hw_type=vCU
    Check if Disallowed Alarm was Detected during Watchdog    hw_type=vDU
    Stop Watchdog    hw_type=vCU
    Stop Watchdog    hw_type=vDU

Create Dictionary From Lists
    [Documentation]    Description:    Creates a dictionary from two lists.
    ...                Input:          keys = desired keys of new dictionary
    ...                                values = desired values of each key in new dictionary
    ...                Output:         dictionary = created dictionary from input key-value pairs

    [Arguments]    ${keys}    ${values}
    ${dictionary}=    Create Dictionary
    ${len_keys}=      Get Length    ${keys}
    FOR    ${i}    IN RANGE    0    ${len_keys}
        Set To Dictionary    ${dictionary}    ${keys}[${i}]    ${values}[${i}]
    END
    [Return]    ${dictionary}

Calculate Average And Check Result
    [Documentation]    Description:    Calculates average value from input list and compares it to the target.
    ...                Input:          kpi_list = list of KPIs

    [Arguments]    ${kpi_list}
    ${total}=    Set Variable    0
    FOR    ${time}    IN    @{kpi_list}
        ${total}=    Set Variable    ${total} + ${time}
    END
    ${average}    Evaluate    (${total}) / len(${kpi_list})
    Log To Console    KPI list (s) = ${kpi_list}
    Log To Console   Average = ${average}s
    Log To Console   Max target = ${KPI_30_max_target}s
    Run Keyword And Continue On Failure    Should Be True    ${average} < ${KPI_30_max_target}

Get Interface Type For RMOD
    [Documentation]    Description:    Returns the interface type for given radio unit
    ...                Input:          RMOD_id = int of ID of desired RU
    ...                Output:         interface_type = str interface type of RU ("CPRI" or "eCPRI")

    [Arguments]    ${RMOD_id}
    FOR    ${item}    IN    @{rmod_listed}
        ${id}=    Get From Dictionary    dictionary=${item}    key=id
        Run Keyword If    ${id} == ${RMOD_id}    Set Test Variable    ${interface_type}    ${item['interface_type']}
    END
    [Return]    ${interface_type}

Check Family And Extra Time If Its Excepted
    [Documentation]    Description:    If ${DC_config} is True, checks the family of input RU and sets ${extra_time} variable accordingly.
    ...                                If ${DC_config} is not True or the radio family is not excepted, ${extra_time} variable is set to 0.
    ...                                Additionally the interface type is checked for PULSAR family as this impacts the exception extra time.
    ...                Input:          id = int of ID of desired RU
    ...                                product_name = str model of RU

    [Arguments]    ${id}    ${product_name}
    Run Keyword And Return If    ${FHGW_OBJ}    Set Test Variable    ${extra_time}    0
    Check RMOD Family    ${product_name}
    IF    ${match}
        Log To Console    \nRMOD ${product_name} belongs to excepted family ${family_name}
        IF    '${family_name}' == 'PULSAR'
            ${interface_type}=    Get Interface Type For RMOD    ${id}
            IF    '${interface_type}' == 'eCPRI'
                ${extra_time}=    Set Variable    60
            ELSE
                ${extra_time}=    Set Variable    240
            END
            Set Test Variable    ${extra_time}
            Log To Console    Additional time for family ${family_name} ${interface_type} is ${extra_time}s
            Return From Keyword If    ${TRUE}
        END
        ${extra_time}=    Get From Dictionary    ${EXCEPTION_FAMILY_TIMES_DICT}    ${family_name}
        Set Test Variable    ${extra_time}
        Log To Console    Additional time for family ${family_name} is ${extra_time}s

    ELSE
        Log To Console    \nRMOD ${product_name} does not belong to an excepted family
        Set Test Variable    ${extra_time}    0
    END

Check RMOD Family
    [Documentation]    Description:    Sets variable ${family_name} which contains the radio family of the input radio unit model.
    ...                Input:          product_name = str RU model

    [Arguments]    ${product_name}
    Set Test Variable    ${match}    ${FALSE}
    FOR    ${family}    IN    &{FAMILY_DICT}
        FOR    ${product}    IN    ${family}[1]
            ${match}=    Run Keyword And Return Status    Should Contain    ${product}    ${product_name}
            IF    ${match}
                Set Test Variable    ${match}
                ${family_name}=    Evaluate    "${family}[0]"
                Set Test Variable    ${family_name}
                Exit For Loop
            END
        IF    ${match}    Exit For Loop
        END
    IF    ${match}    Exit For Loop
    END

Check All Cells Enabled
    [Documentation]    Description:    Checks if all cells of TL are in enabled operational state.

    ${cells_list}=        vdu_admin.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    ${expected_state}=    Set Variable    enabled
    All Cell Operational States Should Be    cells_list=${cells_list}    expected_state=${expected_state}

All Cell Operational States Should Be
    [Documentation]    Description:    Checks if all operational states of every cell in input list is equal to input string.
    ...                Input:          cells_list = list of cells in config
    ...                                expected_state = str of expected cell operational state

    [Arguments]    ${cells_list}    ${expected_state}
    FOR    ${cell}    IN    @{cells_list}
        IF    "${cell['operational_state']}" != "${expected_state}"
            Fail    Operational state of cells is not all '${expected_state}'
        END
    END

Check Any Cell Not Enabled
    [Documentation]    Description:    Checks if any cell of the TL is in disabled operational state.

    Set Test Variable    ${any_cell_disabled}    ${FALSE}
    ${cells_list}=       vdu_admin.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    ${enabled_state}=    Set Variable    enabled
    FOR    ${cell}    IN    @{cells_list}
        IF    "${cell['operational_state']}" != "${enabled_state}"
            Set Test Variable    ${any_cell_disabled}    ${TRUE}
            Exit For Loop
        END
    END
    Run Keyword If    not ${any_cell_disabled}    Fail    All cell operational_states remained enabled, expected disabled

Get Maximum Additional Time For Target Due To Excepted RUs
    [Documentation]    Description:    Makes list which includes all extra times for each excepted RU in config.
    ...                Output:         Max value from the list.

    ${extra_time_list}    Create List
    FOR    ${id}    IN    @{ids}
        ${product_name}=    Get From Dictionary    ${rmod_id_product_dict}    ${id}
        Set Test Variable    ${product_name}
        Check Family And Extra Time If Its Excepted    ${id}    ${product_name}
        Append To List    ${extra_time_list}    ${extra_time}
    END
    ${max_extra_time}   Evaluate   max([int(x) for x in ${extra_time_list}])
    Log To Console    \nMaximum time added to target is ${max_extra_time}s
    [Return]    ${max_extra_time}
