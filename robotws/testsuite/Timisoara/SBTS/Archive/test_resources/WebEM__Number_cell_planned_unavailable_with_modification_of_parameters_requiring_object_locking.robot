*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Number_cell_planned_unavailable_with_modification_of_parameters_requiring_object_locking
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21285
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC will check if counter M55601C01002 is incremented by 1 when NR cell becomes unavailable by modifying
    ...  actAperCsi parameter.
	...  When actAperCsi parameter is modified, NR cell becomes automatically unavailable and after successfull
    ...  activation of actAperCsi, NR cell should be on air.
    ...  actAperCsi parameter is set to True and afterwards is set to False. Cells status is verified for both cases.
    ...  The 2 modifications of actAperCsi parameter are repeated one more time.
    ...  In the last step counter M55601C01002 is verified.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21285 - Initial creation
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 20.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23300 - Delete verification for usageState
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 21.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26540 - Adapt TC to CB009480
    ...  - 05.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26673 - Add suport for branch

    Set Tags    CA-WebEM    OWNER-tatiana.bechet@nokia.com   AUTHOR-andrada-lavinia.baleti@nokia.com
    ...    MAINTAINER-andrada-lavinia.baleti@nokia.com   GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS21

    Step 0: Check if NR cell exists
    Step 1: Set actAperCsi parameter to False if needed and Check Cells Status
    FOR  ${index}  IN RANGE  2  5  2
        Step ${index}: Set actAperCsi parameter to True and Check Cells Status
        ${next_index}  Evaluate  ${INDEX}+1
        Step ${next_index}: Set actAperCsi parameter to False and Check Cells Status
    END
    Step 6: Check PM counter M55601C01002


Step 0: Check if NR cell exists
    Log  Step 0: Check if NR cell exists  console=true
    Run Keyword Unless  ${SCF_COUNT_NR}
    ...  Fail  NR cells does not exist!

Step 1: Set actAperCsi parameter to False if needed and Check Cells Status
    Log  Step 1: Set actAperCsi parameter to False if needed and Check Cells Status  console=true
    ${COUNTER_DICT}  Create dictionary
    Set Test Variable  ${COUNTER_DICT}
    ${nr_cell_object_list}  query infomodel  get list //NRCELL_A-*
    Get NRBTS ID  ${nr_cell_object_list}
	Sleep until new 15 minutes cycle
	Get time before parameter changes
    FOR  ${nr_cell_object}  IN  @{nr_cell_object_list}
        ${cell_id}  Run Keyword Unless  '${nr_cell_object.actAperCsi}'=='${EMPTY}'
        ...  Fetch from right  ${nr_cell_object.dist_name}  -
        Run Keyword Unless  '${cell_id}'=='${EMPTY}'  Run Keywords
        ...  Initialize dictionary for counter  ${nr_cell_object.dist_name}
        ...  AND
        ...  Run Keyword Unless  ${nr_cell_object.actAperCsi}==${FALSE}
        ...  Change parameter for one cell  false  actAperCsi  ${cell_id}
    END
    ${COUNTER_DICT_KEYS_LIST}  Get dictionary keys  ${COUNTER_DICT}  sort_keys=False
    Set test variable  ${COUNTER_DICT_KEYS_LIST}
    ${nr_cell_object_list}  Query infomodel  get list //NRCELL_A-*
    FOR  ${nr_cell_object}  IN  @{nr_cell_object_list}
        Run Keyword Unless  '${nr_cell_object.actAperCsi}'=='${EMPTY}'
        ...  should be equal  ${nr_cell_object.actAperCsi}  ${FALSE}
    END
    Wait until keyword succeeds  1200  10  Check NR Cells  ${Enabled_}

Step ${nr}: Set actAperCsi parameter to True and Check Cells Status
    Log  \n Step ${nr}: Set actAperCsi parameter to True and Check Cells Status  console=true
    Change parameter  true  actAperCsi
    Wait until keyword succeeds  1200  10  Check NR Cells  ${Enabled_}

Step ${nr}: Set actAperCsi parameter to False and Check Cells Status
    Log  Step ${nr}: Set actAperCsi parameter to False and Check Cells Status  console=true
    Change parameter  false  actAperCsi
    Wait until keyword succeeds  1200  10  Check NR Cells  ${Enabled_}

Step 6: Check PM counter M55601C01002
    Log  Step 6: Check PM counter M55601C01002  console=true
    ${time}  Get Time  hour min sec
    ${TIME_AFTER_CHANGES}  Set variable  ${time}[0]:${time}[1]:${time}[2]
    ${difference}  Subtract Time From Time    ${time_after_changes}    ${TIME_BEFORE_CHANGES}
    ...    timer    exclude_millis=yes
    Run Keyword If  '${difference}'<'00:14:20'
    ...  Sleep until new 15 minutes cycle
    ${last_cell_id}    Get from list     ${COUNTER_DICT_KEYS_LIST}    -1
    ${expect_counter_for_last_cell}    Get from dictionary    ${COUNTER_DICT}    ${last_cell_id}
    ${counter_list}    Get NR_CELL PM Counter    ${last_cell_id}    counter_id=M55601C01002
    Run keyword if  ${counter_list}[-1]<${expect_counter_for_last_cell}
    ...  Sleep until new 15 minutes cycle
    FOR  ${NRCELL_id}  IN  @{COUNTER_DICT_KEYS_LIST}
        Check M55601C01002 Counter Success  ${NRCELL_id}  expect_counter=${COUNTER_DICT}[${NRCELL_id}]
    END

Check NR Cells
    [Arguments]     ${operationalState}
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Assert Every  NRCEL  operationalState=${operationalState}  timeout=60

Get NRBTS ID
    [Arguments]    ${nr_cell_object_list}
    ${first_NR_cell_object}  Get from list  ${nr_cell_object_list}  0
	${first_NR_cell_dn}  Run keyword unless  '${first_NR_cell_object.dist_name}'=='${EMPTY}'
	...  Set variable  ${first_NR_cell_object.dist_name}
    @{split_path}  Split string  ${first_NR_cell_dn}  /
    ${NRBTS_ID}  Get from list  ${split_path}  -2
    ${NRBTS_ID}  Fetch from right  ${nrbts_id}  -
	Set test variable  ${NRBTS_ID}

Get time before parameter changes
    ${time}  Get Time  hour min sec
    ${TIME_BEFORE_CHANGES}  Set Variable  ${time}[0]:${time}[1]:${time}[2]
    Set test variable  ${TIME_BEFORE_CHANGES}

Initialize dictionary for counter
    [Arguments]  ${dist_name}
    ${cell_id}  Fetch from right  ${dist_name}  -
    Set to dictionary  ${COUNTER_DICT}  ${cell_id}  0

Update counter value for one cell
    [Arguments]  ${cell_id}
    ${counter_value}  Get from dictionary  ${COUNTER_DICT}  ${cell_id}
    ${counter_value}  Evaluate  ${counter_value} + 1
    Set to dictionary  ${COUNTER_DICT}  ${cell_id}  ${counter_value}

Get counter value for one cell
    [Arguments]  ${cell_id}
    ${counter_value}  Get from dictionary  ${COUNTER_DICT}  ${cell_id}
    [Return]  ${counter_value}

Change parameter for one cell
    [Documentation]
    ...  This KW is created to change parameter actAperCsi for just one cell
    [Arguments]   ${value}  ${parameter_name}  ${cell_id}
    ${IM_BTS_ID}   Admin Get BTS Id
    Set Test Variable    ${IM_BTS_ID}
    Perform Parameter Recommissioning  MRBTS-${IM_BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...  ${parameter_name}  update  ${value}  skip_parameter_relation_errors=True  should_activate=True  timeout=300
    Log  ${parameter_name} for cell ${cell_id} will be changed to ${value}  console=true
    Update counter value for one cell  ${cell_id}

Change parameter
    [Documentation]
    ...  This KW is created to change parameter actAperCsi
    [Arguments]   ${value}  ${parameter_name}
	FOR  ${NRCELL_id}  IN  @{COUNTER_DICT_KEYS_LIST}
	    Change parameter for one cell  ${value}  ${parameter_name}  ${NRCELL_id}
	END
    FOR  ${NRCELL_id}  IN  @{COUNTER_DICT_KEYS_LIST}
      ${nr_cell_object}  query infomodel  get object //MRBTS_A-${IM_BTS_ID}/NRBTS_A-${NRBTS_ID}/NRCELL_A-${NRCELL_id}
      Log  Parameter actAperCsi after change for cell ${NRCELL_id} is ${nr_cell_object.actAperCsi}  console=true
    END

Check M55601C01002 Counter Success
    [Arguments]    ${NRCELL_id}    ${expect_counter}
    Log    \n Check M55601C01002 Counter Success    console=true
    ${counter_list}    Get NR_CELL PM Counter    ${NRCELL_id}    counter_id=M55601C01002
    ${counter_value}  Run keyword if  ${counter_list}[-1]<${expect_counter}
    ...  Evaluate  ${counter_list}[-1]+${counter_list}[-2]
    ...  ELSE
    ...  Set variable  ${counter_list}[-1]
    should be true    ${counter_value} == ${expect_counter}

Get NR_CELL PM Counter
    [Arguments]    ${NRCELL_id}    ${counter_id}    ${alias}=default
    Log    Get NR_CELL PM Counter    console=true
    ${dist_name}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
    ...  BTS/MRBTS-${IM_BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_id}/NCAV/${counter_id}
    ...  BTS/CELLS/NRCELL-${NRCELL_id}/NCAV/${counter_id}
	${result}    get_counters_info    dist_name=${dist_name}    timeout=60
	${dict}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
	...  ${result}[BTS][MRBTS-${IM_BTS_ID}][NRBTS-${NRBTS_ID}][NRCELL-${NRCELL_id}][NCAV][${counter_id}]
	...  ${result}[BTS][CELLS][NRCELL-${NRCELL_id}][NCAV][${counter_id}]
    ${counter_list}    get dictionary values    ${dict}
    [Return]    ${counter_list}


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
