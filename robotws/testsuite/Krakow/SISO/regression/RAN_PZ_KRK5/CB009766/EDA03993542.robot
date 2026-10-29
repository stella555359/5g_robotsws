*** Settings ***
Documentation
...   Test suite for regression testing of EDA03993542
...   author: Pawel Grabania, Aleksandra Kaim
...   contact: pawel.grabania@nokia.com, aleksandra.kaim@nokia.com

Resource     ./resources/common_keywords.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_timeout_for_update_sw=3600
...               prefix_tag=TRIMODE
Suite Teardown    Common Suite Teardown

*** Test Cases ***
N-1-N_SW_upgrade_EDA_for_03993542
    [Setup]    Actions before test With Checking Configuration and Changing It If Needed     config_name=TRIMODE
    ...     prefix_tag=TRIMODE      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Upgrade]
    logger.log_info_to_console    ENB_BUILD=${ENB_BUILD}
    ${build_dir}=    Set Variable    /home/ute/temp_builds
    @{directory_paths}=    Create List      /home/ute/.ute-ca/cache/bts/    ${build_dir}
    Remove Dirs    directory_paths=${directory_paths}
    ${n}=    Set Variable If    'SBTS00' in '${ENB_BUILD}'    r1    n1
    ${source_build}=    Get source sw version for upgrade    n=${n}    build_version=${ENB_BUILD}
    logger.log_info_to_console    Downloading SW build ${source_build}
    ${sw_package_dir}=    Download SW package    sw_version=${source_build}    target_dir=${build_dir}
    logger.log_info_to_console    Performing configuration reset before downgrade to build ${source_build}
    ...                           log_hierarchy=${3}
    Perform gNB configuration reset
    Wait for sw update possible
    BuiltIn.Sleep    60s
    logger.log_info_to_console    Update to source SW build ${source_build}
    Update gNB software    sw_package_dir=${sw_package_dir}    timeout=3600
    logger.log_info_to_console    Update to source SW build ${source_build} finished
    BuiltIn.Sleep    120s
    Load configuration    build_directory=${build_dir}
    ${param_name}=    Create Dictionary    allocCriterion=L1 balanced    allocPriority=1
    ${param_to_verify}=    Create Dictionary
        ...    MRBTS-76100/LNBTS-76100=${param_name}
    Verify gNB Configuration Parameters Have Expected Values    param_dict=${param_to_verify}

    logger.log_info_to_console    Downloading SW build ${ENB_BUILD}
    ${sw_package_dir}=    Download SW package    sw_version=${ENB_BUILD}    target_dir=/home/ute/temp_builds
    logger.log_info_to_console    Update to SW build ${ENB_BUILD}
    Update gNB software    sw_package_dir=${sw_package_dir}    timeout=3600
    logger.log_info_to_console    Update to SW build ${ENB_BUILD} finished
    logger.log_info_to_console    Waiting 120s for BTS reboot    log_hierarchy=${2}
    BuiltIn.Sleep    300s
    gnb_du.Wait Unitl Connection Via Admin Is Possible      timeout=${600}
    logger.log_info_to_console    Wait until all cells are up
    Wait Until Keyword Succeeds     900 sec     120 sec   gnbcell.Verify All Cells Are Onair
    Verify gNB Configuration Parameters Have Expected Values    param_dict=${param_to_verify}
    Remove Dirs    directory_paths=${directory_paths}
    Delete Builds from Tmp
    BuiltIn.Sleep    120s
    [Teardown]    Actions after test

N-2-N_SW_upgrade_EDA_for_03993542
    [Setup]    Actions before test With Checking Configuration and Changing It If Needed     config_name=TRIMODE
    ...     prefix_tag=TRIMODE     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Upgrade]
    logger.log_info_to_console    ENB_BUILD=${ENB_BUILD}
    ${build_dir}=    Set Variable    /home/ute/temp_builds
    @{directory_paths}=    Create List      /home/ute/.ute-ca/cache/bts/    ${build_dir}
    Remove Dirs    directory_paths=${directory_paths}
    ${source_build}=    Get source sw version for upgrade    n=n2    build_version=${ENB_BUILD}
    logger.log_info_to_console    Downloading SW build ${source_build}
    ${sw_package_dir}=    Download SW package    sw_version=${source_build}    target_dir=${build_dir}
    logger.log_info_to_console    Performing configuration reset before downgrade to build ${source_build}
    ...                           log_hierarchy=${3}
    Perform gNB configuration reset
    Wait for sw update possible
    BuiltIn.Sleep    60s
    logger.log_info_to_console    Update to source SW build ${source_build}
    Update gNB software    sw_package_dir=${sw_package_dir}    timeout=3600
    logger.log_info_to_console    Update to source SW build ${source_build} finished
    BuiltIn.Sleep    120s
    Load configuration    build_directory=${build_dir}
    ${param_name}=    Create Dictionary    allocCriterion=L1 balanced    allocPriority=1
    ${param_to_verify}=    Create Dictionary
        ...    MRBTS-76100/LNBTS-76100=${param_name}
    Verify gNB Configuration Parameters Have Expected Values    param_dict=${param_to_verify}

    logger.log_info_to_console    Downloading SW build ${ENB_BUILD}
    ${sw_package_dir}=    Download SW package    sw_version=${ENB_BUILD}    target_dir=/home/ute/temp_builds
    logger.log_info_to_console    Update to SW build ${ENB_BUILD}
    Update gNB software    sw_package_dir=${sw_package_dir}    timeout=3600
    logger.log_info_to_console    Update to SW build ${ENB_BUILD} finished
    logger.log_info_to_console    Waiting 120s for BTS reboot    log_hierarchy=${2}
    BuiltIn.Sleep    300s
    gnb_du.Wait Unitl Connection Via Admin Is Possible      timeout=${600}
    logger.log_info_to_console    Wait until all cells are up
    Wait Until Keyword Succeeds     900 sec     120 sec   gnbcell.Verify All Cells Are Onair
    Verify gNB Configuration Parameters Have Expected Values    param_dict=${param_to_verify}
    Remove Dirs    directory_paths=${directory_paths}
    Delete Builds from Tmp
    BuiltIn.Sleep    120s
    [Teardown]    Actions after test
