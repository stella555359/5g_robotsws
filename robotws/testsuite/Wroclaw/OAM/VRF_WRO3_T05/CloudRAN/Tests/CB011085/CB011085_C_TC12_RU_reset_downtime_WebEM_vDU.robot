*** Settings ***
Documentation
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is used to verify the KPI 51a (RU reset downtime) for every radio configured on vDU.
    ...
    ...  Step 0 - RU units of testline are identified and corresponding necessary variables are set.
    ...  Step 1 - Each RU is reset ${N_RU_reset_loops} times. Each reset time is compared to the target value ${KPI_51a_target}. After
    ...           ${N_RU_reset_loops} resets of RU, an average value of KPI 51a is calculated for given radio and compared to target. This process is
    ...           repeated for every radio unit.
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 13.11.2024 - Initial creation

*** Variables ***
${N_RU_reset_loops}        3    # number of reset loops per RU
${KPI_51a_target}          240  # base KPI target in seconds
${RMOD_excepted}           ${FALSE}
@{RESULTS}
@{AVERAGES}
@{TARGETS}
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
TC__CB011085_C_TC12_RU_reset_downtime_WebEM_vDU
    Step 0: Preconditions
    Step 1: Perform ${N_RU_reset_loops} Resets For Each RU, Calculate And Check KPI


Step 0: Preconditions
    [Documentation]    Description:    RU units of testline are identified and corresponding necessary variables are set

    Log To Console    \nStep 0: Preconditions
    ${rmod_listed}=    vdu_admin.Get Rmods Status    vdu_connection=${vdu_connection}
    Set Test Variable    ${rmod_listed}
    ${ids}=    Create List
    ${product_names}=      Create List

    FOR    ${item}    IN    @{rmod_listed}
        ${product_name}=    Get From Dictionary    ${item}    product_name
        ${id}=    Get From Dictionary    ${item}    id
        Append To List    ${product_names}    ${product_name}
        Append To List    ${ids}    ${id}
    END

    ${rmod_id_product_dict}=    Create Dictionary From Lists    keys=${ids}    values=${product_names}
    Set Test Variable    ${ids}
    Set Test Variable    ${product_names}
    Set Test Variable    ${rmod_id_product_dict}

Step 1: Perform ${N_RU_reset_loops} Resets For Each RU, Calculate And Check KPI
    [Documentation]    Description:    Each RU is reset ${N_RU_reset_loops} times. Each reset time is compared to the target value ${KPI_51a_target}.
    ...                                After ${N_RU_reset_loops} resets of RU, an average value of KPI 51a is calculated for given radio and
    ...                                compared to target. This process is repeated for every radio unit.

    Log To Console    \nStep 1: Perform ${N_RU_reset_loops} Resets For Each RU, Calculate And Check KPI  console=${True}
    FOR    ${id}    IN    @{ids}
        ${product_name}=    Get From Dictionary    ${rmod_id_product_dict}    ${id}
        Set Test Variable    ${product_name}
        ${downtimes}=    Create List
        Check Family And Extra Time If Its Excepted    ${id}    ${product_name}
        FOR    ${i}    IN RANGE    ${N_RU_reset_loops}
            Log To Console    \nResetting radio ${product_name} with id: ${id}, iteration ${${i}+1}/${N_RU_reset_loops}
            ${id_as_list}=    Create List    ${id}
            vdu_admin.Reset Rmods    ${id_as_list}    vdu_connection=${vdu_connection}
            Wait Until Keyword Succeeds    2 minutes    200ms    Check Any Cell Not Enabled
            ${first_cell_down_time}=    Get Current Date
            Log To Console    ${first_cell_down_time} - First cell is down
            Wait Until Keyword Succeeds    10 minutes    200ms    Check All Cells Enabled
            ${last_cell_up_time}=    Get Current Date
            Log To Console    ${last_cell_up_time} - All cells are enabled
            ${RU_downtime}=    Subtract Date From Date    ${last_cell_up_time}    ${first_cell_down_time}
            Append To List    ${downtimes}    ${RU_downtime}
            Log To Console    RU ${product_name} with id ${id}, iteration ${${i}+1} downtime = ${RU_downtime}s
            ${max_target}=    Evaluate    ${KPI_51a_target} + ${extra_time}
            Set Test Variable    ${max_target}
            Run Keyword And Continue On Failure    Should Be True    ${RU_downtime} < ${max_target}
        END
        ${average_result}=    Calculate Average And Check Result    ${downtimes}
        ${result_string}=    Catenate    SEPARATOR=    ${product_name} id ${id} =    ${downtimes}
        Append To List    ${RESULTS}    ${result_string}
        ${average_string}=    Catenate    SEPARATOR=    ${product_name} id ${id} =    ${average_result}
        Append To List    ${AVERAGES}    ${average_string}
        ${target_string}=    Catenate    SEPARATOR=    ${product_name} id ${id} =    ${max_target}
        Append To List    ${TARGETS}    ${target_string}
    END
    Create Results File    test_results=${RESULTS}     average_results=${AVERAGES}    target_values=${TARGETS}

Create Dictionary From Lists
    [Documentation]    Description:    Creates a dictionary from two lists.
    ...                Input:          keys = desired keys of new dictionary
    ...                                values = desired values of each key in new dictionary
    ...                Output:         dictionary = created dictionary from input key-value pairs

    [Arguments]    ${keys}    ${values}
    ${dictionary}=    Create Dictionary
    ${len_keys}=    Evaluate    len(${keys})
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
    ${average}=    Evaluate    (${total}) / len(${kpi_list})
    Log To Console  Average for RU = ${average}s
    Log To Console  Max target = ${max_target}s
    Run Keyword And Continue On Failure    Should Be True    ${average} < ${max_target}
    [Return]    ${average}

Get Interface Type For RMOD
    [Documentation]    Description:    Returns the interface type for given radio unit
    ...                Input:          RMOD_id = int of ID of desired RU
    ...                Output:         interface_type = str interface type of RU ("CPRI" or "eCPRI")

    [Arguments]    ${RMOD_id}
    FOR    ${item}    IN    @{rmod_listed}
        ${id}=    Get From Dictionary    ${item}    id
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

#    Run Keyword And Return If    ${FHGW_OBJ}    Set Test Variable    ${extra_time}    0
    Check RMOD Family    ${product_name}
    IF    ${RMOD_excepted}
        Log To Console  \nRMOD ${product_name} belongs to excepted family ${family_name}
        IF    '${family_name}' == 'PULSAR'
            ${interface_type}=    Get Interface Type For RMOD    ${id}
            IF    '${interface_type}' == 'eCPRI'
                ${extra_time}=    Set Variable    60
            ELSE
                ${extra_time}=    Set Variable    240
            END
            Set Test Variable    ${extra_time}
            Log To Console  Additional time for family ${family_name} ${interface_type} as per OAM_GEN_SFS_PERF_CAP.12847 is ${extra_time}s
            Return From Keyword If    ${TRUE}
        END
        ${extra_time}=    Get From Dictionary    ${EXCEPTION_FAMILY_TIMES_DICT}    ${family_name}
        Set Test Variable    ${extra_time}
        Log To Console  Additional time for family ${family_name} as per OAM_GEN_SFS_PERF_CAP.12847 is ${extra_time}s

    ELSE
        Log To Console  RMOD ${product_name} does not belong to an excepted family
        Set Test Variable    ${extra_time}    0
    END

Check RMOD Family
    [Documentation]    Description:    Sets variable ${family_name} which contains the radio family of the input radio unit model.
    ...                Input:          product_name = str RU model

    [Arguments]    ${product_name}
    Set Test Variable    ${match}    ${FALSE}
    Set Test Variable    ${RMOD_excepted}    ${FALSE}
    FOR    ${family}    IN    &{FAMILY_DICT}
        FOR    ${product}    IN    ${family}[1]
            ${match}=    Run Keyword And Return Status    Should Contain    ${product}    ${product_name}
            IF    ${match}
                Set Test Variable    ${RMOD_excepted}  ${TRUE}
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

    ${cells_list}=    vdu_admin.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    ${expected_state}=    Set Variable    enabled
    All Cell Operational States Should Be    ${cells_list}    ${expected_state}

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
    ${cells_list}=    vdu_admin.Get Vdu Cells Status    vdu_connection=${vdu_connection}
    ${enabled_state}=    Set Variable    enabled
    FOR    ${cell}    IN    @{cells_list}
        IF    "${cell['operational_state']}" != "${enabled_state}"
            Set Test Variable    ${any_cell_disabled}    ${TRUE}
            Exit For Loop
        END
    END
    Run Keyword If    not ${any_cell_disabled}    Fail    All cell operational_states remained enabled, expected disabled
