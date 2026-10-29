*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Resource containing KWs for KPI calculations and reporting


Library    taf.ul.oam_kpi_calculations      WITH NAME    kpi
Library    taf.sw.reporting_portal          WITH NAME    rp

*** Keywords ***

KPI Validate Results
    [Arguments]  ${kpi_result_list}  ${kpi_name}  ${ref_value}
    [Documentation]    Universal keyword for validation kpi results. If ref_value is 'None' keyword always pass.
    ...  Keyword always prints calculated kpi result.
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | kpi_resul_list         | Yes  | result from KW 'kpi.Get All Deltas'                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | kpi_name               | Yes  | kpi name, ex: kpi16a, kpi54b, kpirmodreset                         |
    ...  |                        |      | each name is taken from 'taf.ul.oam_kpi_calculations'              |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | ref_value              | Yes  | integer value; if not aplicable use 'None'                         |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${kpi_result}=  Set Variable If  '${kpi_result_list}'=='@{EMPTY}'  ${NONE}  ${kpi_result_list[0]}
    ${unit}=  Set Variable  ${KPIs['${kpi_name}']['unit']}
    ${validation_status}=  IF  '${ref_value}'!='${NONE}'  Run Keyword And Return Status  Should Be True  ${kpi_result} <= ${ref_value}
    ...  ELSE  Set Variable  ${TRUE}
    IF  not ${validation_status}  Run Keyword And Continue On Failure
    ...  Fail  ${kpi_name} OUTCOME:\n ACCEPTABLE: ${ref_value} ${unit}\n KPI RESULT: ${kpi_result}${unit}
    IF  not ${validation_status}  Logging With Timestamp
    ...  message=${kpi_name} OUTCOME: TARGET=${ref_value}${unit}, KPI_RESULT=${kpi_result}${unit}
    ...  style=WARNING
    ...  ELSE IF  ${validation_status} and ${ref_value}
    ...  Logging With Timestamp
    ...  message=${kpi_name} OUTCOME: TARGET=${ref_value}${unit}, KPI_RESULT=${kpi_result}${unit}
    ...  style=DONE
    ...  ELSE
    ...  Logging With Timestamp
    ...  message=${kpi_name} OUTCOME: KPI_RESULT=${kpi_result}${unit}
    ...  style=DONE

KPI Execute Calculation For KPI54a KPI54b
    [Arguments]  ${ru_startup_start_date}  ${bts_id}  ${ims_directory}  ${calc_dict}=&{EMPTY}
    [Documentation]  Keyword for calculate and validate kpi results (kpi54a and kpi54b).
    ...  'calc_dict' structure:
    ...  calc_dict = {
    ...        'kpi54a': ['ref_time', 'tc_verdict'],
    ...         }
    ...  key - kpi_name (contains list with two values), ref_time - time/None, tc_verdict - ${TRUE}/${FALSE}
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | ru_startup_start_date  | Yes  | UTC time gathered when power on                                    |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | bts_id                 | Yes  | bts_id for ims2 collection                                         |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | ims_directory          | Yes  | directory to save ims file                                         |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | calc_dict              | No   | contains ref_time/verdict for particular kpi                       |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...  | Return Value       | Description                                                                   |
    ...  +====================+===============================================================================+
    ...  | kpi_result_dict    | returns calculated kpi, kpi_ref, verdict                                      |
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...
    ...  Example dict output:
    ...  kpi_result_dict = {
    ...        'kpi54a': {'kpi_ref': '234', 'kpi_result': ['123'], 'kpi_verdict': 'PASS'},
    ...        'kpi54b': {'kpi_ref': 'None', 'kpi_result': ['231'], 'kpi_verdict': 'FAIL'}
    ...         }
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${kpi_result_dict}=  Create Dictionary  kpi54a=&{EMPTY}  kpi54b=&{EMPTY}
    ${ims_path}=  Set Variable  ${ims_directory}/BTSFiles/${bts_id}/ims_kpi54a_kpi54b.ims2
    admin.Collect Infomodel Log From Current Session
    ...  connection=${bts_id}
    ...  target_file_name=${ims_path}
    ...  timeout=120
    Run Keyword And Continue On Failure  kpi.Calculate kpi54a
    ...  ims_file_path=${ims_path}
    ...  start_point_timestamp=${ru_startup_start_date}
    Run Keyword And Continue On Failure  kpi.Calculate kpi54b
    ...  ims_file_path=${ims_path}
    ...  start_point_timestamp=${ru_startup_start_date}
    ${kpi_list}=  Create List  kpi54a  kpi54b
    FOR  ${kpi_name}  IN  @{kpi_list}
      ${tmp_dict}=  Create Dictionary
      ${kpi_calc_params_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${calc_dict}  ${kpi_name}
      ${kpi_calc_params_dict}=  IF  not ${kpi_calc_params_status}  Create Dictionary  ref_time=None  tc_verdict=${FALSE}
      ...  ELSE  Create Dictionary  ref_time=${calc_dict['${kpi_name}'][0]}  tc_verdict=${calc_dict['${kpi_name}'][1]}
      ${kpi_result}=  kpi.Get All Deltas  kpi_name=${kpi_name}
      ${validation_result}=  Run Keyword And Return Status  KPI Validate Results
      ...  kpi_result_list=${kpi_result}
      ...  kpi_name=${kpi_name}
      ...  ref_value=${kpi_calc_params_dict['ref_time']}
      IF  ${kpi_calc_params_dict['tc_verdict']} and not ${validation_result}
      ...  Run Keyword And Continue On Failure  Fail  ${kpi_name} failed
      ${final_kpi_verdict}=  IF  ${kpi_calc_params_dict['tc_verdict']} and not ${validation_result}
      ...  Set Variable  FAIL
      ...  ELSE
      ...  Set Variable  PASS
      Set To Dictionary  ${kpi_result_dict['${kpi_name}']}
      ...  kpi_result=${kpi_result}
      ...  kpi_ref=${kpi_calc_params_dict['ref_time']}
      ...  kpi_verdict=${final_kpi_verdict}
    END
    [Return]  ${kpi_result_dict}

KPI Report Results
    [Arguments]  ${kpi_result_dict}  ${variant}=&{EMPTY}  ${visible_to_db}=${TRUE}
    [Documentation]    Universal keyword for reporting kpi results. Mandatory global variable 'KPIs' should be filled in
    ...  regarding used kpi (examples in variables_global.py). Detailed parameter description is available in library
    ...  documentation 'taf.sw.reporting_portal'
    ...  'kpi_result_dict' structure:
    ...  kpi_result_dict = {
    ...        'kpi54a': {'kpi_ref': '234', 'kpi_result': ['123'], 'kpi_verdict': 'PASS'},
    ...        'kpi54b': {'kpi_ref': 'None', 'kpi_result': ['231'], 'kpi_verdict': 'FAIL'}
    ...         }
    ...  key - kpi_name, kpi_ref - time/None, kpi_result - output from 'kpi.Get All Deltas'

    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | kpi_result_dict        | Yes  | dictionary with calculated results                                 |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | variant                | No   | dictionary with HW impacted by KPI; default empty                  |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | visible_to_db          | No   | defines visibility for db ${TRUE}/${FALSE}                         |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    FOR  ${kpi_name}  IN  @{kpi_result_dict}
      IF  '${kpi_result_dict['${kpi_name}']['kpi_result']}'=='@{EMPTY}'
        Logging With Timestamp
        ...  message=${kpi_name} won't be reported. Calculation empty.
        ...  style=WARN
        Continue For Loop
      END
      rp.Report KPI Results
      ...  name=${kpi_name}
      ...  target=${kpi_result_dict['${kpi_name}']['kpi_ref']}
      ...  value=${kpi_result_dict['${kpi_name}']['kpi_result'][0]}
      ...  kpi_type=${KPIs['${kpi_name}']['kpi_type']}
      ...  visible_to_db=${visible_to_db}
      ...  description=${KPIs['${kpi_name}']['description']}
      ...  category=${KPIs['${kpi_name}']['category']}
      ...  unit=${KPIs['${kpi_name}']['unit']}
      ...  variant=${variant}
      Logging With Timestamp
      ...  message=${kpi_name} reported succesfuly.
      ...  style=DONE
    END

KPI Save KPI Calculations To File
    [Arguments]  ${file_path}  ${kpi_result_dict}  ${bts_id}  ${object_dscrp}
    [Documentation]  Universal keyword for saving KPIs to dedicated file
    ...  'kpi_result_dict' structure:
    ...  kpi_result_dict = {
    ...        'kpi54a': {'kpi_ref': '234', 'kpi_result': ['123'], 'kpi_verdict': 'PASS'},
    ...        'kpi54b': {'kpi_ref': 'None', 'kpi_result': ['231'], 'kpi_verdict': 'FAIL'}
    ...         }
    ...  key - kpi_name, kpi_ref - time/None, kpi_result - output from 'kpi.Get All Deltas', kpi_verdict - PASS/FAIL
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | file_path              | Yes  | path to kpi file                                                   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | kpi_result_dict        | Yes  | dictionary with calculated results                                 |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | bts_id                 | Yes  | bts_id                                                             |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | object_dscrp           | Yes  | short description of measured object (sn or distname or other)     |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    Append To File  ${file_path}  BTS_ID : ${bts_id}${\n}
    Append To File  ${file_path}  OBJECT : ${object_dscrp}${\n}
    FOR  ${kpi_name}  IN  @{kpi_result_dict}
      ${result}=  Set Variable  ${kpi_result_dict['${kpi_name}']['kpi_result']}
      ${ref_time}=  Set Variable  ${kpi_result_dict['${kpi_name}']['kpi_ref']}
      ${verdict}=  Set Variable  ${kpi_result_dict['${kpi_name}']['kpi_verdict']}
      Append To File  ${file_path}  --${verdict}-- ${kpi_name} : ${result} (ref_time: ${ref_time})${\n}
    END

KPI Execute Calculation For KPI3
    [Arguments]  ${bts_startup_start_date}  ${bts_id}  ${ims_directory}  ${calc_dict}=&{EMPTY}
    [Documentation]  Keyword for calculate and validate kpi results (kpi3).
    ...  'calc_dict' structure:
    ...  calc_dict = {
    ...        'kpi3': ['ref_time', 'tc_verdict'],
    ...         }
    ...  key - kpi_name (contains list with two values), ref_time - time/None, tc_verdict - ${TRUE}/${FALSE}
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_startup_start_date | Yes  | UTC time gathered when power on                                    |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | bts_id                 | Yes  | bts_id for ims2 collection                                         |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | ims_directory          | Yes  | directory to save ims file                                         |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | calc_dict              | No   | contains ref_time/verdict for particular kpi                       |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...  | Return Value       | Description                                                                   |
    ...  +====================+===============================================================================+
    ...  | kpi_result_dict    | returns calculated kpi, kpi_ref, verdict                                      |
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...
    ...  Example dict output:
    ...  kpi_result_dict = {
    ...        'kpi3': {'kpi_ref': '234', 'kpi_result': ['123'], 'kpi_verdict': 'PASS'}
    ...         }
    ...
    ...  | **Author:** przemyslaw.kempa@nokia.com
    ...  | **Maintainer:** przemyslaw.kempa@nokia.com

    ${kpi_result_dict}=  Create Dictionary  kpi3=&{EMPTY}
    ${ims_path}=  Set Variable  ${ims_directory}/BTSFiles/${bts_id}/ims_kpi3.ims2
    admin.Collect Infomodel Log From Current Session
    ...  connection=${bts_id}
    ...  target_file_name=${ims_path}
    ...  timeout=120
    Run Keyword And Continue On Failure  kpi.Calculate kpi3
    ...  ims_file_path=${ims_path}
    ...  start_point_timestamp=${bts_startup_start_date}
    ${kpi_list}=  Create List  kpi3
    FOR  ${kpi_name}  IN  @{kpi_list}
      ${tmp_dict}=  Create Dictionary
      ${kpi_calc_params_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${calc_dict}  ${kpi_name}
      ${kpi_calc_params_dict}=  IF  not ${kpi_calc_params_status}  Create Dictionary  ref_time=None  tc_verdict=${FALSE}
      ...  ELSE  Create Dictionary  ref_time=${calc_dict['${kpi_name}'][0]}  tc_verdict=${calc_dict['${kpi_name}'][1]}
      ${kpi_result}=  kpi.Get All Deltas  kpi_name=${kpi_name}
      ${validation_result}=  Run Keyword And Return Status  KPI Validate Results
      ...  kpi_result_list=${kpi_result}
      ...  kpi_name=${kpi_name}
      ...  ref_value=${kpi_calc_params_dict['ref_time']}
      IF  ${kpi_calc_params_dict['tc_verdict']} and not ${validation_result}
      ...  Run Keyword And Continue On Failure  Fail  ${kpi_name} failed
      ${final_kpi_verdict}=  IF  ${kpi_calc_params_dict['tc_verdict']} and not ${validation_result}
      ...  Set Variable  FAIL
      ...  ELSE
      ...  Set Variable  PASS
      Set To Dictionary  ${kpi_result_dict['${kpi_name}']}
      ...  kpi_result=${kpi_result}
      ...  kpi_ref=${kpi_calc_params_dict['ref_time']}
      ...  kpi_verdict=${final_kpi_verdict}
    END
    [Return]  ${kpi_result_dict}