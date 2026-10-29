*** Settings ***
Documentation
...   General Procedure for testing SW upgrade/rollback with available upgrade paths


Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      get_uuf_builds.py
Library      upgrade_and_commission_bts.py
Library      taf/rfrl/utilities/logger/custom_logger.py
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot


*** Keywords ***
SW_Upgrade_Rollback_with_Upgrade_Paths
    [Documentation]
    ...   Keyword for testing all provided upgrade paths. If not defined will be gather automatically based on CM artifactory
    ...   For manual execution you need to provide the following variables(apart from basic UUF4ALL variables):
    ...   - target_sw
    ...   - builds_to_test - need to be defined as dict eg:
    ...         &{builds_to_test}    n2=SBTS23R2_ENBxxxxx    n1=SBTS23R3_ENBxxxxx
    ...   - qc_upgrade_paths_ids - defined in variables file eg
    ...     _qc_id_mapping = {
    ...         'SBTS00': {
    ...             'qc_upgrade': 732919,
    ...             'qc_site_reset': 732918,
    ...             'upgrade_paths': {
    ...                 'n2': 2,         # qc test instance id for n2 testing
    ...                 'n1': 1,         # qc test instance id for n1 testing
    ...                 'n0': 0,         # qc test instance id for n0 testing
    ...                 'customer': 9,   # qc test instance id for customer testing
    ...             }
    ...         }
    ...     }
    ...   ${qc_upgrade_paths_ids}=${kpi_qc_ids['upgrade_paths']}

    [Arguments]  ${test_iteration}=5
    ...          ${target_sw}=${None}
    ...          ${builds_to_test}=&{EMPTY}
    ...          ${customer_source_build}=${None}
    ...          ${restore_to_target_sw}=${False}
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${True}
    ...          ${customers_list}=@{EMPTY}
    ...          ${qc_upgrade_paths_ids}=${None}
    ...          ${qc_domain}=${None}
    ...          ${qc_project}=${None}

    Set Upgrade Rollback Test Variables
        ...                                 ${target_sw}=${target_sw}
        ...                                 ${builds_to_test}=&{builds_to_test}
        ...                                 ${customer_source_build}=${customer_source_build}
        ...                                 ${custom_alarms}=@{custom_alarms}
        ...                                 ${customers_list}=@{customers_list}

    FOR   ${index}    ${testing_path}    IN ENUMERATE   @{testing_paths}
        ${source_build}    Set Variable       ${builds_to_test['${testing_path}']}
        custom_logger.Log info to Console     Testing SOURCE SOFTWARE: ${source_build}

        IF    ${restore_to_target_sw} and ${index} + 1 == len(${builds_to_test})
            Set Test Variable       ${restore_sw}               ${True}
        END

        ${status}  ${value}    Run Keyword and Ignore Error
        ...                                 UUF4ALL_SW_UPGRADE_TEST
        ...                                     test_iteration=${test_iteration}
        ...                                     customers_list=@{customers_list}
        ...                                     critical_faults=@{critical_faults}
        ...                                     5g_source_sw=${source_build}
        ...                                     5g_target_sw=${target_sw}
        ...                                     use_builds_storage=${False}
        ...                                     restore_to_target_sw=${restore_sw}
        ...                                     qc_domain=${qc_domain}
        ...                                     qc_id=${qc_upgrade_paths_ids['${testing_path}']}
        ...                                     qc_project=${qc_project}
        ...                                     custom_alarms=${custom_alarms}

        IF    "${customer_source_build}" == "${source_build}"
            Set Suite Variable    ${CUSTOMER_BUILD_UPDATE_STATUS}   ${status}
        END

        IF    ${index} + 1 < len(${builds_to_test})
            Set Test Variable            ${next_source_build}       ${builds_to_test['${testing_paths[${index}+1]}']}
            custom_logger.Log info to Console     Upgrade BTS to the next source build: ${next_source_build}
            Upgrade and Wait for OnAir    sw_build=${next_source_build}    delete_sw_package=${True}
        END
    END

Set Upgrade Rollback Test Variables
    [Arguments]
    ...          ${target_sw}=${None}
    ...          ${builds_to_test}=&{EMPTY}
    ...          ${customer_source_build}=${None}
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${customers_list}=@{EMPTY}
    ...          ${customer_configuration_id}=${1}

    Set Test Variable       ${restore_sw}                         ${False}
    Set Suite Variable      ${CUSTOMER_BUILD_UPDATE_STATUS}       ${None}

    IF    ${{$target_sw is None}}
        ${target_sw}                Get Target Build
    END
    IF    not $builds_to_test
        &{builds_to_test}           Get Builds to Testing
    END
    IF    ${{$customer_source_build is None}}
        ${customer_source_build}    Get CM Source Build    customer_name=${customers_list[0]}
        ...                                                configuration_id=${customer_configuration_id}
    END
    Set Test Variable       @{testing_paths}    @{builds_to_test.keys()}
    custom_logger.Log info to Console     TARGET SOFTWARE: ${target_sw}
    custom_logger.Log info to Console     BUILD TO TESTING: ${builds_to_test}
    custom_logger.Log info to Console     CUSTOMER SOURCE BUILD: ${customer_source_build}
