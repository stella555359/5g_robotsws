*** Settings ***
Documentation
...            Keywords for collecting and analyzing PM counters on vRAN
...            author:       Mateusz Michalik, mateusz.michalik@nokia.com
...                          Bartosz Szlezak, bartosz.szlezak@nokia.com
...            maintainer:   Mateusz Michalik, mateusz.michalik@nokia.com
...                          Bartosz Szlezak, bartosz.szlezak@nokia.com

Resource    configurators_vran.robot
Library     OperatingSystem
Library  testsuite.Timisoara.L3.ET.L3_ET_TIM3.resourcesKRK.krk3_common.Python.VRanPmCountersExtension.VRanPmCountersExtension
Library  testsuite.Timisoara.L3.ET.L3_ET_TIM3.resourcesKRK.krk3_common.Python.CounterAnalyzerCloud.CounterAnalyzerCloud  WITH NAME  CounterAnalyzer

*** Variables ***
${EXPECTED_VDU_YAML}    testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/krk3_common/configs/pm_counters_template_vdu_baseline.yaml
${EXPECTED_VCU_YAML}    testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/krk3_common/configs/pm_counters_template_vcu_baseline.yaml

*** Keywords ***
Wait for Next vRAN PM Counters Interval
    [Documentation]    Waits for next vRAN PM counters interval
    ...                - ``vdu_pm_objects_list``: list of PM objects to validate  @\{vDU_PM_OBJECTS\}
    ...                - ``vcu_pm_objects_list``: list of PM objects to validate  @\{vCU_PM_OBJECTS\}
    ...                - ``timeout`` (optional):  default timeout: 60min
    [Arguments]    ${timeout}=3600    ${expected_interval}=5
    wait_for_new_vran_pm_filenames
    ...    timeout=${timeout}
    ...    expected_interval=${expected_interval}

Get Next vRAN XML PM Counters Files
    [Documentation]    Waits for next vRAN PM counters interval and gets PM counters XML files for vDU or vCU or both
    ...                - ``vdu_pm_objects_list``: list of PM objects to validate  @\{vDU_PM_OBJECTS\}
    ...                - ``vcu_pm_objects_list``: list of PM objects to validate  @\{vCU_PM_OBJECTS\}
    ...                - ``dirpath``: Path to directory for the file, Default: ``$\{OUTPUT DIR\}/Logs/$\{TEST NAME\}/``
    ...                - ``timeout`` (optional):  default timeout: 60min
    ...                [Return]  {'vcu': ['pm_vcu.xml', 'pm_vcu2.xml'], 'vdu': ['pm_vdu.xml']}
    [Arguments]    ${dirpath}=${OUTPUT DIR}/Logs/${TEST NAME}/    ${timeout}=3600    ${expected_interval}=5
    Create Directory    ${dirpath}/vcu
    Create Directory    ${dirpath}/vdu
    ${pm_files_dict}=  get_next_vran_unpacked_full_pm_counters_files
    ...    output_dirpath=${dirpath}
    ...    timeout=3600
    ...    expected_interval=${expected_interval}
    [Return]    ${pm_files_dict}

Get vRAN PM Counter Values from XML Files
    [Documentation]    Returns a dict of list PM counter values from XML file specified by counter ID and object ID.
    ...                - ``pm_filepaths_list``: List of XML files with counters for vCU or vDU
    ...                - ``counter_id``: Counter ID
    ...                - ``mo_id``: Object ID
    ...                Example:
    ...                | Get vRAN PM Counter Values from XML File |
    ...                |    |  pm_filepaths_list=['pm_vcu.xml', 'pm_vcu2.xml'] |
    ...                |    |  counter_id=M55335C03001  |  mo_id=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1 |
    [Arguments]    ${pm_filepaths_list}    ${counter_id}    ${mo_id}
    ${values_list}    get_unit_pm_counters_values
    ...    counter=${counter_id}    localmoid=${mo_id}    filepaths_list=${pm_filepaths_list}
    Should Not Be Empty    ${values_list}
    [Return]    ${values_list}

Verify vRAN PM Counters Are Nonzero
    [Documentation]    Verifies if PM counters are larger than zero.
    ...                KW expects counters as dictionaries with ``id``, ``name`` and ``mo_id`` fields.
    ...                Additional fields will be ignored. Continues execution even if verification fails.
    ...                - ``pm_filepaths_dict``: Dict of paths list (vcu,vdu) to XML files with counters
    ...                - ``vdu_counters`` (optional): List of counter dicts with ``id``, ``name`` and ``mo_id`` fields
    ...                - ``vcu_counters`` (optional): List of counter dicts with ``id``, ``name`` and ``mo_id`` fields
    ...                Example:
    ...                | ***** Variables ***** |
    ...                | @\{vCU_PM_OBJECTS\}  |  PDCP2  |  HICPU |
    ...                | @\{vDU_PM_OBJECTS\}  |  RACDU |
    ...                | $\{MO_ID\} | PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1 |
    ...                | $\{MO_ID2\} | PLMN-PLMN/MRBTS-2/NRBTS-1/NRCELL-5 |
    ...                | &\{CNT_1\} | id=M55335C03001 | name=UL_GRANT_AL1_CBWP1 | mo_id=$\{MO_ID\} |
    ...                | &\{CNT_2\} | id=M55335C03002 | name=UL_GRANT_AL2_CBWP1 | mo_id=$\{MO_ID\} |
    ...                | &\{CNT_3\} | id=M55335C03003 | name=UL_GRANT_AL2_CBWP5 | mo_id=$\{MO_ID2\} |
    ...                | &\{CNT_4\} | id=M55335C03004 | name=UL_GRANT_AL2_CBWP6 | mo_id=$\{MO_ID2\} |
    ...                | @\{COUNTERS_vCU\} | &\{CNT_1\} | &\{CNT_2\} |
    ...                | @\{COUNTERS_vDU\} | &\{CNT_3\} | &\{CNT_4\} |
    ...                | ***** Test Cases ***** |
    ...                | Example_test |
    ...                |  | Verify vRAN PM Counters Are Nonzero |
    ...                |  | pm_filepaths_dict={'vcu': ['pm_vcu.xml', 'pm_vcu2.xml'], 'vdu': ['pm_vdu.xml']} |
    ...                |  | vdu_counters=$\{COUNTERS_vDU\} | vcu_counters=$\{COUNTERS_vCU\} |
    [Arguments]    ${pm_filepaths_dict}    ${vdu_counters}=@{EMPTY}    ${vcu_counters}=@{EMPTY}
    Verify vRAN Unit PM Counters Are Nonzero    vdu    ${pm_filepaths_dict}    ${vdu_counters}
    Verify vRAN Unit PM Counters Are Nonzero    vcu    ${pm_filepaths_dict}    ${vcu_counters}

Verify vRAN Unit PM Counters Are Nonzero
    [Documentation]    Auxiliary keyword for ``Verify vRAN PM Counters Are Nonzero``
    [Arguments]    ${unit}    ${pm_filepaths_dict}    ${counters}
    Log to Console    Verifying that ${unit} PM Counters are nonzero
    FOR    ${counter}    IN     @{counters}
      ${out_values_dict}    get_vran_pm_counters_values
      ...    counter=${counter.id}    localmoid=${counter.mo_id}    pm_filepaths_dict=${pm_filepaths_dict}
      Run Keyword And Continue On Failure    Should Not Be Empty    ${out_values_dict['${unit}']}
      ...   msg=PM Counter ${counter.name} (${counter.id}) does not exist in ${pm_filepaths_dict} under ${counter.mo_id}
      Run Keyword And Continue On Failure    Run Keyword Unless    ${out_values_dict['${unit}']} == []
      ...    Should Be True    ${out_values_dict['${unit}']}.count(0) == 0
      ...    msg=PM Counter ${counter.name} (${counter.id}) value is zero
    END

Verify vRAN PM Counters Have Exact Values
    [Documentation]    Verifies if PM counters have exactly specified values.
    ...                KW expects counters as dictionaries with ``id``, ``name`` and ``mo_id`` fields.
    ...                Additional fields will be ignored. Continues execution even if verification fails.
    ...                - ``pm_filepaths_dict``: Dict of paths list (vcu,vdu) to XML files with counters
    ...                - ``vdu_counters`` (optional): List of counter dicts with ``id``, ``name``, ``mo_id`` and ``value`` fields
    ...                - ``vcu_counters`` (optional): List of counter dicts with ``id``, ``name``, ``mo_id`` and ``value`` fields
    ...                Example:
    ...                | ***** Variables ***** |
    ...                | @\{vCU_PM_OBJECTS\}  |  PDCP2  |  HICPU |
    ...                | @\{vDU_PM_OBJECTS\}  |  RACDU |
    ...                | $\{MO_ID\} | PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1 |
    ...                | $\{MO_ID2\} | PLMN-PLMN/MRBTS-2/NRBTS-1/NRCELL-5 |
    ...                | &\{CNT_1\} | id=M55335C03001 | name=UL_GRANT_AL1_CBWP1 | mo_id=$\{MO_ID\} | value=3000 |
    ...                | &\{CNT_2\} | id=M55335C03002 | name=UL_GRANT_AL2_CBWP1 | mo_id=$\{MO_ID\} | value=3220 |
    ...                | &\{CNT_3\} | id=M55335C03003 | name=UL_GRANT_AL2_CBWP5 | mo_id=$\{MO_ID2\} | value=3200 |
    ...                | &\{CNT_4\} | id=M55335C03004 | name=UL_GRANT_AL2_CBWP6 | mo_id=$\{MO_ID2\} | value=3040 |
    ...                | @\{COUNTERS_vCU\} | &\{CNT_1\} | &\{CNT_2\} |
    ...                | @\{COUNTERS_vDU\} | &\{CNT_3\} | &\{CNT_4\} |
    ...                | ***** Test Cases ***** |
    ...                | Example_test |
    ...                |  | Verify vRAN PM Counters Have Exact Values |
    ...                |  | pm_filepaths_dict={'vcu': ['pm_vcu.xml', 'pm_vcu2.xml'], 'vdu': ['pm_vdu.xml']} |
    ...                |  | vdu_counters=$\{COUNTERS_vDU\} | vcu_counters=$\{COUNTERS_vCU\} |
    [Arguments]    ${pm_filepaths_dict}    ${vdu_counters}=@{EMPTY}    ${vcu_counters}=@{EMPTY}
    Log to Console    Verifying that PM Counters have exact values
    Verify vRAN Unit PM Counters Have Exact Values    vdu    ${pm_filepaths_dict}    ${vdu_counters}
    Verify vRAN Unit PM Counters Have Exact Values    vcu    ${pm_filepaths_dict}    ${vcu_counters}


Verify vRAN Unit PM Counters Have Exact Values
    [Documentation]    Auxiliary keyword for ``Verify vRAN PM Counters Have Exact Values``
    [Arguments]    ${unit}    ${pm_filepaths_dict}    ${counters}
    Log to Console    Verifying that ${unit} PM Counters have exact values
    FOR    ${counter}    IN     @{counters}
      ${out_values_dict}    get_vran_pm_counters_values
      ...   counter=${counter.id}    localmoid=${counter.mo_id}    pm_filepaths_dict=${pm_filepaths_dict}
      Run Keyword And Continue On Failure    Should Not Be Empty    ${out_values_dict['${unit}']}
      ...   msg=PM Counter ${counter.name} (${counter.id}) does not exist in ${pm_filepaths_dict} under ${counter.mo_id}
      Run Keyword And Continue On Failure    Run Keyword Unless    ${out_values_dict['${unit}']} == []
      ...   Should Be True    ${out_values_dict['${unit}']}[0] == int(${counter.value})
      ...   msg=PM Counter ${counter.name} (${counter.id}) value: ${out_values_dict['${unit}']}[0] is not expected ${counter.value}
    END

Set New vRAN PM Interval
    [Documentation]    Keyword used to prepare delta commissioning .json files for vDU and vCU using provided interval
    ...                based on the templates:
    ...                ``testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/krk3_common/configs/pm_intervals_delta_vdu.json``
    ...                ``testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/krk3_common/configs/pm_intervals_delta_vcu.json``
    ...                and uploading these files.
    ...                - ``interval``: Length of the interval to be set i.e. "15min"
    [Arguments]    ${interval}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True      '${interval}' in ('5min','15min','30min','60min')    msg=Invalid KW parameter: interval
    #---------------------------------------------------------------------------------------------------------------
    ${path}    CounterAnalyzer.prepare_deltas_for_new_vran_pm_interval    ${interval}
    &{configs}    Create Dictionary    delta_vdu=${path}[0]    delta_vcu=${path}[1]
    Upload Configs    config=${configs}
    ${result}    Run Keyword And Return Status    Should Not Be Equal As Strings    ${interval}    5min
    Run Keyword If    ${result}    Run Keywords
    ...    Log to console    Waiting for delta activation
    ...    AND    Sleep    360s    reason=Wait until the new interval takes effect

Wait For Next vRAN PM Counters Interval With Expected Measurements
    [Documentation]    Keyword used to wait for new pm interval with expected measurement types for vdu and vcu
    ...                - ``pm_structure``: List containing two dictionaries where the first one concerns vdu
    ...                and the second one concerns vcu. Each dictionary contains information about the structure of pm counters
    ...                also in the form of a dictionary and measurement types in the form of a list
    ...                - ``timeout`` (optional):  default timeout: 60min
    [Arguments]    ${pm_structure}    ${timeout}=3600
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${pm_structure}) is list       msg=Invalid KW parameter: pm_structure
    Should Be True    type(${pm_structure}[0]) is dict    msg=Invalid KW parameter: pm_structure
    Should Be True    type(${pm_structure}[1]) is dict    msg=Invalid KW parameter: pm_structure
    Should Be True    type(${timeout}) is int             msg=Invalid KW parameter: timeout
    #---------------------------------------------------------------------------------------------------------------
    wait_for_new_vran_pm_filenames
    ...    vDU=${pm_structure[0]['measurements']}
    ...    vCU=${pm_structure[1]['measurements']}
    ...    timeout=${timeout}

Get Expected PM Counters Dict And Measurement Type List
    [Documentation]    Keyword used to get the structure of pm counters also with measurement types for both vdu an vcu
    ...                based on yaml files.
    ...                - ``expected_yaml_vcu`` (optional): Yaml file with the structure of pm counters to be checked for vcu
    ...                default expected_yaml_vcu:
    ...                testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/krk3_common/configs/pm_counters_template_vcu.yaml
    ...                - ``expected_yaml_vdu`` (optional): Yaml file with the structure of pm counters to be checked for vdu
    ...                default expected_yaml_vdu:
    ...                testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/krk3_common/configs/pm_counters_template_vdu.yaml
    [Arguments]    ${expected_yaml_vcu}=${EXPECTED_VCU_YAML}    ${expected_yaml_vdu}=${EXPECTED_VDU_YAML}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${expected_yaml_vcu}    msg=Invalid KW parameter: expected_yaml_vcu
    File Should Exist    ${expected_yaml_vdu}    msg=Invalid KW parameter: expected_yaml_vdu
    #---------------------------------------------------------------------------------------------------------------
    ${expected_counters_dict_vcu}    ${measurement_type_vcu}
    ...    CounterAnalyzer.fill_counters_dict_and_measurement_type_list    ${expected_yaml_vcu}
    ${expected_counters_dict_vdu}    ${measurement_type_vdu}
    ...    CounterAnalyzer.fill_counters_dict_and_measurement_type_list    ${expected_yaml_vdu}
    &{vcu_dict}    Create Dictionary    counters=${expected_counters_dict_vcu}    measurements=${measurement_type_vcu}
    &{vdu_dict}    Create Dictionary    counters=${expected_counters_dict_vdu}    measurements=${measurement_type_vdu}
    @{pm_structure}    Create List    ${vdu_dict}    ${vcu_dict}
    [Return]    ${pm_structure}

Get Next Full PM Counters Files Dict
    [Documentation]    Keyword used to get the dictionary containing lists of files for both vdu and vcu
    ...                which will be used for performing verification
    ...                - ``pm_structure``: List containing two dictionaries where the first one concerns vdu
    ...                and the second one concerns vcu. Each dictionary contains information about the structure of pm counters
    ...                also in the form of a dictionary and measurement types in the form of a list
    ...                - ``dirpath`` (optional):  Path where file for each measurement should be saved
    [Arguments]    ${pm_structure}    ${dirpath}=${OUTPUT DIR}/Logs/Test_Cases/${TEST NAME}/
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${pm_structure}) is list       msg=Invalid KW parameter: pm_structure
    Should Be True    type(${pm_structure}[0]) is dict    msg=Invalid KW parameter: pm_structure
    Should Be True    type(${pm_structure}[1]) is dict    msg=Invalid KW parameter: pm_structure
    #---------------------------------------------------------------------------------------------------------------
    ${pm_files_dict}    CounterAnalyzer.wait_for_next_pm_interval_and_get_files_dict
    ...    ${pm_structure[0]['measurements']}
    ...    ${pm_structure[1]['measurements']}
    ...    ${dirpath}
    [Return]    ${pm_files_dict}

Perform Pm Counters Verification With Expected Values
    [Documentation]    Keyword used to perform counters verification for both vdu and vcu
    ...                - ``pm_structure``: List containing two dictionaries where the first one concerns vdu
    ...                and the second one concerns vcu. Each dictionary contains information about the structure of pm counters
    ...                also in the form of a dictionary and measurement types in the form of a list
    ...                - ``pm_files_dict``:  Dictionary containing lists of files for each measurement type for both vdu and vcu
    ...                among which the counter values are checked
    [Arguments]    ${pm_structure}    ${pm_files_dict}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${pm_structure}) is list       msg=Invalid KW parameter: pm_structure
    Should Be True    type(${pm_structure}[0]) is dict    msg=Invalid KW parameter: pm_structure
    Should Be True    type(${pm_structure}[1]) is dict    msg=Invalid KW parameter: pm_structure
    Should Be True    type(${pm_files_dict}) is dict      msg=Invalid KW parameter: pm_structure
    #---------------------------------------------------------------------------------------------------------------
    CounterAnalyzer.perform_pm_counters_verification
    ...    ${pm_structure[0]['counters']}
    ...    ${pm_structure[1]['counters']}
    ...    ${pm_files_dict}
