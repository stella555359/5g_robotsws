*** Settings ***
Documentation
...   author:  Jakub Siluch
...   maintainer: Jakub Siluch
...   contact: jakub.siluch@nokia.com

Resource            testsuite/Krakow/resources/UUF_ASIR/uuf_asir_common_keywords.robot

Suite Setup         Run Keywords    change_string_to_list    ${SOURCE_ENB_BUILDS}    AND
...                 change_string_to_dict      ${HUBS_BUILDS}       AND
...                 Suite Setup    ${PATH_TO_BUILDS_STORAGE}    ${DISK_PASSWORD}     ${SOURCE_ENB_BUILDS}
...                 ${TARGET_BUILD}    ${HUBS_BUILDS}   ${PATH_TO_LOCAL_BTS_SCF}    ${PATH_TO_LOCAl_ASIR_SCF}
...                 ${PREFIX_SCF_TAG}  ${HTTPS_PROXY}

*** Variables ***

${UUF4ALL_CHECKED_VERSION}=    2.0.24   # Last checked version of taf.rfrl.uuf4all that is working with this Suite

${HTTPS_PROXY}                 http://proxy-lab.krk-lab.nsn-rdnet.net:8080
${PATH_TO_BUILDS_STORAGE}      /home/ute/UUF_SW/
${PREFIX_SCF_TAG}              ${None}
${PATH_TO_LOCAL_BTS_SCF}       ${None}
${PATH_TO_LOCAl_ASIR_SCF}      ${None}

@{CUSTOM_ALARMS}               61648   # LMP connectivity detected
...                            4681    # Sanity Check Error
...                            61649   # LMP access via port $port
...                            4655    # Service account root access is enabled
...                            61524   # SSH enabled
...                            4654    # Ethernet port security is disabled
...                            4420    # GPS receiver alarm: firmware upgrade ongoing
...                            61652   # R&D Service Port enabled
...                            4700    # TX Power too low
...                            4699    # TX Bias Current too low
...                            4479    # Failure detected on assigned antennas - agreed with dev

@{CRITICAL_FAULTS}             10      # No connection to unit
...                            1806    # Communication failure
...                            4341    # FSP subunit lost Link
...                            4352    # No connection between primary and BTS extension system module
...                            4383    # Virtual node not responding

@{SOURCE_ENB_BUILDS}     SBTS22R3_ENB_0000_001834_000000     SBTS22R4_ENB_0000_001348_000000
${TARGET_BUILD}          SBTS23R1_ENB_0000_001136_000000
${DISK_PASSWORD}
&{HUBS_BUILDS}           APHA=ASIHUB21.05.R06     APHG=ASIHUB2.0_RL21B_21.06.R18
${PERFORM_UBOOT_DOWNGRADE}     ${False}

${SW_UPGRADE_ROLLBACK_ITERATION}    ${10}
${FACTORY_LOAD_ITERATION}           ${3}

*** Test Cases ***

UUF_SW_UPGRADE_ROLLBACK
    [Setup]     Wait For Update Possibility
    @{results}=   Create List
    ${len}=       Get Length   ${SOURCE_ENB_BUILDS}
    ${len}=       Evaluate     ${len} - 1
    Set Test Variable          ${TEST_NAME_BACKUP}     ${TEST_NAME}
    FOR   ${build_num}  IN RANGE    ${len}
          Set Test Variable    ${TEST_NAME}    ${TEST_NAME_BACKUP}_@{SOURCE_ENB_BUILDS}[${build_num}]
          ${result}=    Run Keyword And Ignore Error    UUF4ALL_SW_UPGRADE_TEST
          ...                             custom_alarms=${CUSTOM_ALARMS}
          ...                             critical_faults=${CRITICAL_FAULTS}
          ...                             5g_source_sw=@{SOURCE_ENB_BUILDS}[${build_num}]
          ...                             5g_target_sw=${TARGET_BUILD}
          ...                             should_be_reported=${False}
          ...                             remote_node_update=${False}
          ...                             use_remote_node=${False}
          ...                             test_iteration=${SW_UPGRADE_ROLLBACK_ITERATION}
          ...                             use_builds_storage=${False}
          ...                             restore_to_target_sw=${False}
          ...                             perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
          Append To List       ${results}      ${result}[0]
          Set Test Variable    ${TEST_NAME}    ${TEST_NAME_BACKUP}_@{SOURCE_ENB_BUILDS}[${build_num+1}]_SINGLE
          Run Keyword And Ignore Error    Single Software Update No Rollback
          ...                             5g_target_sw=@{SOURCE_ENB_BUILDS}[${build_num+1}]
          ...                             custom_alarms=${CUSTOM_ALARMS}
          ...                             critical_faults=${CRITICAL_FAULTS}
    END
    Set Test Variable  ${TEST_NAME}  ${TEST_NAME_BACKUP}_@{SOURCE_ENB_BUILDS}[${len}]
    UUF4ALL_SW_UPGRADE_TEST          custom_alarms=${CUSTOM_ALARMS}
    ...                              critical_faults=${CRITICAL_FAULTS}
    ...                              5g_source_sw=@{SOURCE_ENB_BUILDS}[${len}]
    ...                              5g_target_sw=${TARGET_BUILD}
    ...                              should_be_reported=${False}
    ...                              remote_node_update=${False}
    ...                              use_remote_node=${False}
    ...                              test_iteration=${SW_UPGRADE_ROLLBACK_ITERATION}
    ...                              use_builds_storage=${False}
    ...                              restore_to_target_sw=${True}
    ...                              perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
    [Teardown]    Run Keywords     List Should Not Contain Value    ${results}    FAIL
    ...           AND               admin.Teardown All Aliases For Admin

UUF_FACTORY_LOAD
    [Setup]     Run Keywords
    ...                      Check SW And Update If Needed    ${TARGET_BUILD}     ${CUSTOM_ALARMS}    ${CRITICAL_FAULTS}
    ...  AND                 Wait Until Keyword Succeeds   5m   20    gnbbbu.Verify Bts Is Onair

    Factory Load Test Case    custom_alarms=${CUSTOM_ALARMS}
    ...                       critical_faults=${CRITICAL_FAULTS}
    ...                       hub_builds_dict=${HUBS_BUILDS}
    ...                       target_sw_enb=${TARGET_BUILD}
    ...                       proxy_svne=${HTTPS_PROXY}
    ...                       test_iteration=${FACTORY_LOAD_ITERATION}
