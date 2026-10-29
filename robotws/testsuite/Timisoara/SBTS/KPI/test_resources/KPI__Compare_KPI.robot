*** Settings ***
Documentation
    ...  File targets.py should be imported in Settings section of robot suite file as below:
    ...  ---
    ...  Variables | targets.py
    ...  ---
    ...  Variable REFERENCE_CONFIGURATION_ID must be provided in Variables section of robot suite file.
    ...
    ...  oam_kpi_calculations library is used to calculate each kpi.
    ...  Based on targets.py file, KPIs values of ${KPIS_TO_CALCULATE} list will be reported in Reporting portal
    ...  with REFERENCE_CONFIGURATION_ID and each loop/run KPI value will be compared with target value for each RAT
    ...  if values are provided per RAT in targets file.
    ...  TC will fail if any loop/run value > target value.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
@{KPIS_TO_CALCULATE}  @{EMPTY}  # Mandatory, fill in with kpi name from reference file
# E.g: kpi1a | kpi1b


*** Keywords ***
TC__Compare_delta_files
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18105
    ...
    ...  *********************
    ...  History of changes
    ...  *********************
    ...  - 22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22843 - Adjust delta results to be collected from single runs
    ...  - 30.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22881 - Improve and move Compare_KPI to KPI folder
    ...  - 14.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22968 - Add new variable for KPIs that need to be compared and a new flag
    ...  for moving all delta files
    ...  - 03.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24044 - Add Scout Request SCF keyword
    ...  - 10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  - 18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  - 10.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27327 - Remove the extra 10s from ref KPI
    ...  - 18.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27370 - Drop KPI_ref_file.json
    ...  - 25.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27420 - Compare KPI on specific rat
    ...  - 09.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27420 - Fix variable setting
    ...  - 20.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27960 - Skip iterration when dictionary key is not found.
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30510 - Check each loop KPI value will be compared with target value

    Compare KPIs


Compare KPIs
    Variable Should Exist  ${OAM_KPI_TARGETS}  Please import python reference file in robot suite file.
    Variable Should Exist  ${REFERENCE_CONFIGURATION_ID}  Please provide REFERENCE_CONFIGURATION_ID variable in robot suite file.
    FOR  ${kpi}  IN  @{KPIS_TO_CALCULATE}
        Report KPI  ${kpi}
        Compare KPI For Each RAT If Needed  ${kpi}  ${OAM_KPI_TARGETS}[${kpi}]
    END


Compare KPI For Each RAT If Needed
    [Arguments]  ${kpi}  ${target}

    ${targets_on_each_rat}  ${technologies}  Run Keyword And Ignore Error  Get Dictionary Keys  ${target}
    ${kpi_results}  oam_kpi.Get Results  ${kpi}
    IF  '${targets_on_each_rat}'=='FAIL'
        Compare KPI  ${kpi}  ${kpi_results}  ${target}
    ELSE
        Compare KPI For Each Rat  ${kpi}  ${kpi_results}  ${target}  ${technologies}
    END


Compare KPI For Each Rat
    [Arguments]  ${kpi}  ${results}  ${target}  ${technologies}

    ${rat_correspondence}  Create Dictionary  2G=GSM  3G=WCDMA  4G=LTE  5G=NR
    FOR  ${rat}  IN  @{technologies}
        IF  '${rat}'=='GENERAL'
            Compare KPI  ${kpi}  ${results}  ${target}[GENERAL]
            CONTINUE
        END

        Compare KPI On Rat  ${kpi}  ${results}  ${rat_correspondence}[${rat}]  ${rat}  ${target}[${rat}]
    END


Compare KPI
    [Arguments]  ${kpi}  ${results}  ${ref_value}

    FOR  ${result}  IN  @{results}
        ${status}  ${delta}  Run Keyword And Ignore Error  Set Variable  ${result}[delta]
        IF  '${status}'=='FAIL'  CONTINUE

        ${delta_seconds}  Evaluate  round(${delta.total_seconds()}, 2)
        ${status}  Run Keyword And Return Status  Should Be True  ${delta_seconds} <= ${ref_value}
        IF  not ${status}
            Append To List  ${ERRORS}  ${kpi} loop value ${delta_seconds} is higher than target value ${ref_value}. [NOK]
            Set Test Variable  ${TEST_VERDICT}  failed
        END
    END
    IF  '${TEST_VERDICT}'=='passed'
        Log  \n${kpi} all loop values are within target value ${ref_value}. [OK]  console=true
    END


Compare KPI On Rat
    [Arguments]  ${kpi}  ${results}  ${rat_key}  ${rat_display}  ${ref_value}

    FOR  ${result}  IN  @{results}
        ${status}  ${datetime_delta}  Run Keyword And Ignore Error  Set Variable  ${result}[detailed_results][${rat_key}][delta]
        IF  '${status}'=='FAIL'  CONTINUE

        ${delta_seconds}  Evaluate  round(${datetime_delta.total_seconds()}, 2)
        ${status}  Run Keyword And Return Status  Should Be True  ${delta_seconds} <= ${ref_value}
        IF  not ${status}
            Append To List  ${ERRORS}  ${kpi} ${rat_display} loop value ${delta_seconds} is higher than target value ${ref_value}. [NOK]
            Set Test Variable  ${TEST_VERDICT}  failed
        END
    END

    IF  '${TEST_VERDICT}'=='passed'
        Log  \n${kpi} ${rat_display} all loop values are within target value ${ref_value}. [OK]  console=true
    END


TC Setup
    Set Log Level  INFO
    ${taf_config_model}  Run Keyword And Return Status  Variable Should Exist  ${TL}
    IF  ${taf_config_model} and ${REQUEST_SCF_SCOUT}
        Run Keyword And Ignore Error  Scout Request SCF
    END
    @{errors}  Create List
    Set Test Variable  ${ERRORS}
    Set Test Variable  ${TEST_VERDICT}  passed
    Set Test Variable  ${infomodel_launch}  ${FALSE}


TC Teardown
    Set Log Level  TRACE
    No Operation
    IF  '${TEST_VERDICT}'=='failed'
        FOR  ${msg}  IN  @{ERRORS}
            Fail  ${msg}
        END
    END