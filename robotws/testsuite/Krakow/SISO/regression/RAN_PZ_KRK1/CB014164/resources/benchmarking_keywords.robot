*** Settings ***
Documentation
...   contact: julia.luszcz@nokia.com
...   author: Julia Luszcz

*** Keywords ***
Prepare Test Line
    [Arguments]    ${prefix_tag}=${None}
    ...            ${scfs_path}=${False}
    ...            ${swconfig_from_path}=commissionings/Krakow/swconfig/default_swconfig.txt
    ...            ${upload_swconfig_to_neighbour}=${False}
    ...            ${should_LTE_neighbour_be_changed}=${False}
    ...            ${should_5G_neighbour_be_changed}=${False}
    ...            ${incompatible_error_timer}=${False}
    ...            ${increase_timeout_for_update_sw}=${False}
    ...            ${increase_time_for_checking_bbmod}=${False}
    ...            ${increase_time_for_checking_radios}=${False}
    ...            ${increase_time_for_checking_cells}=${False}
    ...            ${increase_time_for_checking_X2link}=${False}
    ...            ${neighbour_incompatible_error_timer}=${False}
    ...            ${neighbour_increase_timeout_for_update_sw}=${False}
    ...            ${increase_time_for_checking_neighbour_bbmod}=${False}
    ...            ${increase_time_for_checking_neighbour_radios}=${False}
    ...            ${increase_time_for_checking_neighbour_cells}=${False}
    ...            ${list_of_additional_allowed_alarms}=${False}
    ...            ${check_truck_roll}=${True}
    ...            ${wait_for_on_air}=${True}
    ...            ${wtd_sfp_wa_support}=${False}
    ...            ${bsr_config_file}=${None}
    ...            ${scf_name}=${None}

    [Documentation]    Function to prepare main BTS to On-Air state.
    ...     :param scf_path:                                Path to SCF file,
    ...     :param scf_prefix_tag:                          scf prefix tag - to indicate specific SCF eg: scf_prefix_tag=4CC --> 4CC_GNB0_SCF.xml
    ...     :param swconfig_from_path:                      Path to sw_config.txt file,
    ...     :param upload_swconfig_to_neighbour:            Upload sw_config.txt file to neighbours
    ...     :param should_LTE_neighbour_be_changed:         Should LTE neighbour be changed,
    ...     :param should_5G_neighbour_be_changed:          Should 5G neighbour be changed,
    ...     :param incompatible_error_timer:                Increase time to wait for "Incopatible SW detected",
    ...     :param increase_timeout_for_update_sw:          Increase time to wait for update SW on BTS,
    ...     :param increase_time_for_checking_bbmod:        Increase timeout for checking BBMOD,
    ...     :param increase_time_for_checking_radios:       Increase timeout for checking Radios,
    ...     :param increase_time_for_checking_cells:        Increase timeout for checking Cells,
    ...     :param increase_time_for_checking_X2link:       Increase timeout for checking X2 Link,
    ...     :param neighbour_incompatible_error_timer:      Increase time to wait for "Incopatible SW detected" for neighbour,
    ...     :param neighbour_increase_timeout_for_update_sw: Increase time to wait for update SW on neighbour,
    ...     :param increase_time_for_checking_neighbour_bbmod: Increase timeout for checking neighbour BBMOD,
    ...     :param increase_time_for_checking_neighbour_radios:  Increase timeout for checking neighbour Radios,
    ...     :param increase_time_for_checking_neighbour_cells:   Increase timeout for checking neighbour Cells,
    ...     :param list_of_additional_allowed_alarms:       List of additional allowed alarms,
    ...     :param bool check_truck_roll:                   Check TRUCK ROLL alarms and Stop Execution If TRUCK ROLL alarms detected,
    ...     :param wait_for_on_air:                         wait till BTS is in On-Air state. If False - waiting till SMOD/BBMOD/RMOD are up.
    ...     :param wtd_sfp_wa_support:                      Specifies whether WTD SFP workaround should be enabled
    ...     :param bsr_config_file:                         Path to BSR configuration file.
    ...     :param scf_name:                                Name of scf file.

    tl_prep.Power On All PDU Ports

    Run Keyword If    '${prefix_tag}' != 'None'               Set Global Variable    ${current_config}    ${prefix_tag}
    Add to Allowed Alarms During TL Preparation    additional_allowed_alarms=${list_of_additional_allowed_alarms}
    gnb_alarm.Start watching alarms     allowed_alarms=${ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...                                 interface=lmp
    ...                                 log_dir=${LOG_PATH}/preparation

    ${scf_dir}                  def_file_location.get_commissioning_dir
    ${base_5g_scf}              Set Variable    ${scf_dir}/${scf_name}
    Set Global Variable         ${base_5g_scf}
    tl_prep.prepare_testline    scfs_path=${scfs_path}
    ...                         scf_prefix_tag=${prefix_tag}
    ...                         swconfig_from_path=${swconfig_from_path}
    ...                         upload_swconfig_to_neighbour=${upload_swconfig_to_neighbour}
    ...                         wait_for_on_air=${wait_for_on_air}
    ...                         should_LTE_neighbour_be_changed=${should_LTE_neighbour_be_changed}
    ...                         should_5G_neighbour_be_changed=${should_5G_neighbour_be_changed}
    ...                         incompatible_error_timer=${incompatible_error_timer}
    ...                         increase_timeout_for_update_sw=${increase_timeout_for_update_sw}
    ...                         increase_time_for_checking_bbmod=${increase_time_for_checking_bbmod}
    ...                         increase_time_for_checking_radios=${increase_time_for_checking_radios}
    ...                         increase_time_for_checking_cells=${increase_time_for_checking_cells}
    ...                         increase_time_for_checking_X2link=${increase_time_for_checking_X2link}
    ...                         neighbour_incompatible_error_timer=${neighbour_incompatible_error_timer}
    ...                         neighbour_increase_timeout_for_update_sw=${neighbour_increase_timeout_for_update_sw}
    ...                         increase_time_for_checking_neighbour_bbmod=${increase_time_for_checking_neighbour_bbmod}
    ...                         increase_time_for_checking_neighbour_radios=${increase_time_for_checking_neighbour_radios}
    ...                         increase_time_for_checking_neighbour_cells=${increase_time_for_checking_neighbour_cells}
    ...                         wtd_sfp_wa_support=${wtd_sfp_wa_support}
    ...                         bsr_config_file=${bsr_config_file}

    [Teardown]    Common Suite Setup With OnAir Test Line Preparation Teardown    check_truck_roll=${check_truck_roll}


Prepare Test Line RFS
    [Arguments]     ${prefix_tag}=${None}
    ...             ${scf_name}=${None}
    ...             ${increase_timeout_for_update_sw}=${False}
    ...             ${increase_time_for_checking_radios}=${False}

    [Documentation]    Function to prepare RFS setup to On-Air state.
    ...     :param scf_prefix_tag:                          scf prefix tag - to indicate specific SCF eg: scf_prefix_tag=4CC --> 4CC_GNB0_SCF.xml
    ...     :param scf_name:                                Name of scf file.
    ...     :param increase_timeout_for_update_sw:          Increase time to wait for update SW on BTS,
    ...     :param increase_time_for_checking_radios:       Increase timeout for checking Radios,

    Prepare Test Line       prefix_tag=${prefix_tag}
    ...                     scf_name=${scf_name}
    ...                     should_5G_neighbour_be_changed=${True}
    ...                     increase_timeout_for_update_sw=${increase_timeout_for_update_sw}
    ...                     increase_time_for_checking_radios=${increase_time_for_checking_radios}