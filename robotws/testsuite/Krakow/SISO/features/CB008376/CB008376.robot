*** Settings ***
Documentation
...   Test suite for regression testing of feature CB008376
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Library      taf.rfrl.utilities.test_config
Resource     ./local_resources/common_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./local_resources/common_variables.py

Suite Setup        Common Suite Setup With OnAir Test Line Preparation    prefix_tag=EDA_03993542
...                                                                       upload_swconfig_to_neighbour=${True}
...                                                                       should_5G_neighbour_be_changed=${True}
Suite Teardown     Test line teardown

*** Test Cases ***
[1][1.0] N-1-N_SW_upgrade_EDA_for_03993542
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Upgrade]
    Set Test Variable    ${gnb_id}    ${1}
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
    Perform gNB configuration reset    gnb_id=${gnb_id}
    Wait for sw update possible    bts_id=${gnb_id}
    BuiltIn.Sleep    60s
    logger.log_info_to_console    Update to source SW build ${source_build}
    Update gNB software    sw_package_dir=${sw_package_dir}    gnb_id=${gnb_id}    timeout=3600
    logger.log_info_to_console    Update to source SW build ${source_build} finished
    Load configuration    bts_id=${gnb_id}    build_directory=${build_dir}
    ${param_name}=    Create Dictionary    allocCriterion=L1 balanced    allocPriority=1
    ${param_to_verify}=    Create Dictionary    MRBTS-77088/LNBTS-77088=${param_name}
    Verify gNB Configuration Parameters Have Expected Values    param_dict=${param_to_verify}    gnb_id=${1}

    logger.log_info_to_console    Downloading SW build ${ENB_BUILD}
    ${sw_package_dir}=    Download SW package    sw_version=${ENB_BUILD}    target_dir=/home/ute/temp_builds
    logger.log_info_to_console    Update to SW build ${ENB_BUILD}
    Update gNB software    sw_package_dir=${sw_package_dir}    gnb_id=${gnb_id}    timeout=3600
    logger.log_info_to_console    Update to SW build ${ENB_BUILD} finished
    logger.log_info_to_console    Waiting 120s for BTS reboot    log_hierarchy=${2}
    BuiltIn.Sleep    300s
    gnb_du.Wait Unitl Connection Via Admin Is Possible    bts_id=${gnb_id}    timeout=${600}
    logger.log_info_to_console    Wait until all cells are up
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair    bts_id=${gnb_id}
    Verify gNB Configuration Parameters Have Expected Values    param_dict=${param_to_verify}    gnb_id=${gnb_id}
    Remove Dirs    directory_paths=${directory_paths}
    BuiltIn.Sleep    120s
    [Teardown]    Actions after test

[1][1.0] N-2-N_SW_upgrade_EDA_for_03993542
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Upgrade]
    Set Test Variable    ${gnb_id}    ${1}
    logger.log_info_to_console    ENB_BUILD=${ENB_BUILD}
    ${build_dir}=    Set Variable    /home/ute/temp_builds
    @{directory_paths}=    Create List      /home/ute/.ute-ca/cache/bts/    ${build_dir}
    Remove Dirs    directory_paths=${directory_paths}
    ${source_build}=    Get source sw version for upgrade    n=n2    build_version=${ENB_BUILD}
    logger.log_info_to_console    Downloading SW build ${source_build}
    ${sw_package_dir}=    Download SW package    sw_version=${source_build}    target_dir=${build_dir}
    logger.log_info_to_console    Performing configuration reset before downgrade to build ${source_build}
    ...                           log_hierarchy=${3}
    Perform gNB configuration reset    gnb_id=${gnb_id}
    Wait for sw update possible    bts_id=${gnb_id}
    BuiltIn.Sleep    60s
    logger.log_info_to_console    Update to source SW build ${source_build}
    Update gNB software    sw_package_dir=${sw_package_dir}    gnb_id=${gnb_id}    timeout=3600
    logger.log_info_to_console    Update to source SW build ${source_build} finished
    Load configuration    bts_id=${gnb_id}    build_directory=${build_dir}
    ${param_name}=    Create Dictionary    allocCriterion=L1 balanced    allocPriority=1
    ${param_to_verify}=    Create Dictionary    MRBTS-77088/LNBTS-77088=${param_name}
    Verify gNB Configuration Parameters Have Expected Values    param_dict=${param_to_verify}    gnb_id=${1}

    logger.log_info_to_console    Downloading SW build ${ENB_BUILD}
    ${sw_package_dir}=    Download SW package    sw_version=${ENB_BUILD}    target_dir=/home/ute/temp_builds
    logger.log_info_to_console    Update to SW build ${ENB_BUILD}
    Update gNB software    sw_package_dir=${sw_package_dir}    gnb_id=${gnb_id}    timeout=3600
    logger.log_info_to_console    Update to SW build ${ENB_BUILD} finished
    logger.log_info_to_console    Waiting 120s for BTS reboot    log_hierarchy=${2}
    BuiltIn.Sleep    300s
    gnb_du.Wait Unitl Connection Via Admin Is Possible    bts_id=${gnb_id}    timeout=${600}
    logger.log_info_to_console    Wait until all cells are up
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair    bts_id=${gnb_id}
    Verify gNB Configuration Parameters Have Expected Values    param_dict=${param_to_verify}    gnb_id=${gnb_id}
    Remove Dirs    directory_paths=${directory_paths}
    BuiltIn.Sleep    120s
    [Teardown]    Actions after test
