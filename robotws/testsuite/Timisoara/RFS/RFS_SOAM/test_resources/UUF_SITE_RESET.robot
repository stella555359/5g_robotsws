*** Settings ***
Documentation    TC__UUF_SITE_RESET
Resource    ../../resources/rfs_general.robot
Resource    ../../resources/rfs_uuf.robot
Library     ../../resources/python_resources/RfsListenerLib.py
Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Library     Collections
Library     String

*** Variables ***
${BTS1_testline_object}    # Link to BTS1 declaration form init.py. ex:${tl.enbs[0]} or ${tl.gnbs[0]}
${BTS2_testline_object}    # Link to BTS2 declaration form init.py if present. ex:${tl.enbs[1]} or ${tl.gnbs[1]}, etc.
${BTS3_testline_object}    # Link to BTS3 declaration form init.py if present. ex:${tl.enbs[2]}
${BTS4_testline_object}    # Link to BTS4 declaration form init.py if present. ex:${tl.enbs[3]}

${BTS1_source_sw}    # BTS1 initial SW name. Possible Values:
                     # - Leave default value Empty for automatic detection based on Single run form
                     # - Custom SW name; ex: SBTS00_ENB_9999_240906_000008
${BTS2_source_sw}    # BTS2 initial SW name. Possible Values:
                     # - Leave default value Empty for automatic detection based on Single run form
                     # - Custom SW name; ex: SBTS00_ENB_9999_240906_000008
${BTS3_source_sw}    # BTS3 initial SW name. Possible Values:
                     # - Leave default value Empty for automatic detection based on Single run form
                     # - Custom SW name; ex: SBTS00_ENB_9999_240906_000008
${BTS4_source_sw}    # BTS4 initial SW name. Possible Values:
                     # - Leave default value Empty for automatic detection based on Single run form
                     # - Custom SW name; ex: SBTS00_ENB_9999_240906_000008

${BTS1_target_sw}    # BTS1 target SW name. Possible Values:
                     # - Leave default value Empty for automatic detection based on Single run form
                     # - Custom SW name; ex: SBTS00_ENB_9999_240910_000009
${BTS2_target_sw}    # BTS2 target SW name. Possible Values:
                     # - Leave default value Empty for automatic detection based on Single run form
                     # - Custom SW name; ex: SBTS00_ENB_9999_240910_000009
${BTS3_target_sw}    # BTS3 target SW name. Possible Values:
                     # - Leave default value Empty for automatic detection based on Single run form
                     # - Custom SW name; ex: SBTS00_ENB_9999_240910_000009
${BTS4_target_sw}    # BTS4 target SW name. Possible Values:
                     # - Leave default value Empty for automatic detection based on Single run form
                     # - Custom SW name; ex: SBTS00_ENB_9999_240910_000009

${BTS1_temporary_allowed_alarms}    # Temporary ignored alarms should be separated by comma without spaces between them (ex: 4773,1898).
                                    # Default value: Empty, no alarms will be ignored
${BTS2_temporary_allowed_alarms}    # Temporary ignored alarms should be separated by comma without spaces between them (ex: 4773,1898).
                                    # Default value: Empty, no alarms will be ignored
${BTS3_temporary_allowed_alarms}    # Temporary ignored alarms should be separated by comma without spaces between them (ex: 4773,1898).
                                    # Default value: Empty, no alarms will be ignored
${BTS4_temporary_allowed_alarms}    # Temporary ignored alarms should be separated by comma without spaces between them (ex: 4773,1898).
                                    # Default value: Empty, no alarms will be ignored

${BTS1_custom_allowed_alarms}    # Custom ignored alarms should be separated by comma without spaces between them (ex: 4773,1898).
                                 # Default value: Empty, no alarms will be ignored
${BTS2_custom_allowed_alarms}    # Custom ignored alarms should be separated by comma without spaces between them (ex: 4773,1898).
                                 # Default value: Empty, no alarms will be ignored
${BTS3_custom_allowed_alarms}    # Custom ignored alarms should be separated by comma without spaces between them (ex: 4773,1898).
                                 # Default value: Empty, no alarms will be ignored
${BTS4_custom_allowed_alarms}    # Custom ignored alarms should be separated by comma without spaces between them (ex: 4773,1898).
                                 # Default value: Empty, no alarms will be ignored
&{BTS1_node_parameters}         &{EMPTY}    # BTS1 node parameters. Possible values: &{EMPTY}
                                            # or set additional node options according with UUF documentation and RFS examples
&{BTS2_node_parameters}         &{EMPTY}    # BTS2 node parameters. Possible values: &{EMPTY}
                                            # or set additional node options according with UUF documentation and RFS examples
&{BTS3_node_parameters}         &{EMPTY}    # BTS3 node parameters. Possible values: &{EMPTY}
                                            # or set additional node options according with UUF documentation and RFS examples
&{BTS4_node_parameters}         &{EMPTY}    # BTS4 node parameters. Possible values: &{EMPTY}
                                            # or set additional node options according with UUF documentation and RFS examples

${TEST_NODES_DETAILS_LIST}      ALL        # Indicate on which BTS to run the actual test. Possible values:
                                           # - ALL: run test on ALL BTS
                                           # - list of selected BTS separated by comma without spaces between them (ex: BTS1,BTS3). By default: ALL
${ITERATIONS_PER_NODE}          1          # Number of SW Upgrade Iterations; by default: 1
${CUSTOMERS_LIST}               Generic    # If specific customer, set name of customer or list of customers. List of customers should be
                                           # separated by comma without spaces between them (ex: Generic,TMO US)
${CALCULATE_KPI}                True       # Calculate KPI. Possible values: True or False; Default Value: True
${KPI_NAMES}                               # KPI name to be reported in UUF dashboard. Can be one or a list of kpi names. In case of a list, the
                                           # elements should be separated by a comma (ex. kpi1a,kpi2a,kpi3a).
${KPI_THRESHOLDS}                          # KPI thresholeds to be reported in UUF dashboard. Can be one or a list of thresholds. In case of a list,
                                           # the elements should be separated by a comma (ex. 600,600,600). They should respect the order of its
                                           # corresponding KPI_NAMES list.
${USE_DCAP}                     False      # Use DCAP. Possible values: True or False; Default Value: False
${L3_CALL_METHOD}               ${None}    # L3 Call Method
${STOP_TEST_AFTER_FAIL}         False      # Stop test after fail. Possible values: True or False; Default Value: False
${REPORT}                       True       # Report for UUF dashboard. Possible Values: True or False. By default: True
${QC_PROJECT}                   ${None}       # QC Project Name for reporting purpose
${QC_DOMAIN}                    ${None}       # QC Domain Name for reporting purpose
${QC_ID}                        ${None}       # QC Id for reporting purpose
${SW_BUILD}                     ${None}       # SW Build Name for reporting purpose
${TOPOLOGY}                     ${None}       # Topology Name for reporting purpose
${RP_CA}                        VRF_SiSo    # Test competence area, by default VRF_SiSo
${RP_LOCATION}                  VRF_TSR2    # Departament location, by default VRF_TSR2
${RP_ORGANIZATION}              VRF_TSR2_T06  # Name of the team labeled as VRF_TSR2_X, replace X with team number/name, example VRF_TSR2_T06
&{TEST_PARAMETERS}              &{EMPTY}    # Add additional test parameters according with UUF options. Default values: &{EMPTY}

*** Keywords ***
TC__UUF_SITE_RESET
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28244
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28244 - Create RFS TC based on UUF PRELIMINARY UPGRADE and SITE RESET WITHOUT HWF
    ...  - 20.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28500 -
    ...  UUF tests, add test variables: ${RP_CA}, ${RP_ORGANIZATION}, ${RP_LOCATION}
    ...  - 13.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28733 - RFS UUF update with new kpi_targets argument

    TC preconditions and parameters check
    RFS Set Initial And Candidate SW
    Check Default Values and set Parameters
    Log Variables  level=TRACE
    SITE RESET WITHOUT HWF

TC preconditions and parameters check
    ${BTS_LIST}=  Create List  BTS1  BTS2  BTS3  BTS4
    ${nodes_details}=  Create List

    FOR  ${BTS}  IN  @{BTS_LIST}

        Run Keyword If  '${${BTS}_testline_object}' == ''  Run Keywords
        ...  Remove Values From List  ${BTS_LIST}  ${BTS}
        ...  AND  Continue For Loop

        ${temporary_allowed_alarms}=  Run Keyword If  '${${BTS}_temporary_allowed_alarms}' != ''
        ...  Split String  ${${BTS}_temporary_allowed_alarms}  ,
        ...  ELSE  Create List

        ${custom_allowed_alarms}=  Run Keyword If  '${${BTS}_custom_allowed_alarms}' != ''
        ...  Split String  ${${BTS}_custom_allowed_alarms}  ,
        ...  ELSE  Create List

        ${node}=  Create Dictionary  node_alias=${BTS}  testline_object=${${BTS}_testline_object}
        ...  temporary_allowed_alarms=@{temporary_allowed_alarms}  custom_allowed_alarms=@{custom_allowed_alarms}

        Run Keyword If  &{${BTS}_node_parameters} is not &{EMPTY}  Set To Dictionary  ${node}  &{${BTS}_node_parameters}

        Set Test Variable  ${${BTS}_node}  ${node}
        Append To List  ${nodes_details}  ${${BTS}_node}

    END

    ${BTS_list_status}=  Run Keyword And Return Status  Should Not Be Empty  ${BTS_LIST}
    Run Keyword If  not ${BTS_list_status}
    ...  Fail  Improper value for input parameter \${BTS*_testline_object}. Please populate it accordingly with your configuration!

    Set Test Variable  ${BTS_LIST}
    Set Test Variable  ${nodes_details}

    Run Keyword If  '${TEST_NODES_DETAILS_LIST}' == 'ALL'
    ...  Set Test Variable  ${test_nodes_details}  ${nodes_details}
    ...  ELSE
    ...  Set custom test nodes details

    ${CUSTOMERS_LIST}=  Split String  ${CUSTOMERS_LIST}  ,
    Set Test Variable  ${CUSTOMERS_LIST}

    ${CALCULATE_KPI}=  Set Variable  ${CALCULATE_KPI.title()}
    Set Test Variable  ${CALCULATE_KPI}

    Run Keyword If  '${CALCULATE_KPI}' not in ['True','False']
    ...  Fail  Improper value for argument! Please select a proper value for test argument \${CALCULATE_KPI}

    Run Keyword If  ('${KPI_NAMES}' or '${KPI_THRESHOLDS}') != ''
    ...  Check kpi threshold list
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${kpi_targets}  ${None}
    ...  AND  Log  Test Argument \${KPI_NAMES} or \${KPI_THRESHOLDS} is empty. KPI name and threshhold will not be reported!  console=True

    ${USE_DCAP}=  Set Variable  ${USE_DCAP.title()}
    Set Test Variable  ${USE_DCAP}

    Run Keyword If  '${USE_DCAP}' not in ['True','False']
    ...  Fail  Improper value for argument! Please select a proper value for test argument \${USE_DCAP}

    ${STOP_TEST_AFTER_FAIL}=  Set Variable  ${STOP_TEST_AFTER_FAIL.title()}
    Set Test Variable  ${STOP_TEST_AFTER_FAIL}

    Run Keyword If  '${STOP_TEST_AFTER_FAIL}' not in ['True','False']
    ...  Fail  Improper value for argument! Please select a proper value for test argument \${STOP_TEST_AFTER_FAIL}

    ${REPORT}=  Set Variable  ${REPORT.title()}
    Set Test Variable  ${REPORT}

    Run Keyword If  '${REPORT}' not in ['True','False']
    ...  Fail  Improper value for argument! Please select a proper value for test argument \${REPORT}

Check Default Values and set Parameters
    &{USER_TEST_PARAMETERS}=  Create Dictionary
    Run Keyword if  '${QC_DOMAIN}' != 'None'  Set To Dictionary  ${USER_TEST_PARAMETERS}  qc_domain=${QC_DOMAIN}
    Run Keyword if  '${QC_ID}' != 'None'  Set To Dictionary  ${USER_TEST_PARAMETERS}  qc_id=${QC_ID}
    Run Keyword if  '${QC_PROJECT}' != 'None'  Set To Dictionary  ${USER_TEST_PARAMETERS}  qc_project=${QC_PROJECT}
    Run Keyword if  '${L3_CALL_METHOD}' != 'None'  Set To Dictionary  ${USER_TEST_PARAMETERS}  l3_call_method=${L3_CALL_METHOD}
    Run Keyword if  '${SW_BUILD}' != 'None'  Set To Dictionary  ${USER_TEST_PARAMETERS}  sw_build=${SW_BUILD}
    Run Keyword if  '${TOPOLOGY}' != 'None'  Set To Dictionary  ${USER_TEST_PARAMETERS}  topology=${TOPOLOGY}

    Set To Dictionary  ${TEST_PARAMETERS}  &{USER_TEST_PARAMETERS}
    Log  Test Parameters dictionary: ${TEST_PARAMETERS}  level=DEBUG

SITE RESET WITHOUT HWF
    e2e_tl_site_reset_with_oam_kpi
    ...  nodes_details=${nodes_details}
    ...  test_nodes_details=${test_nodes_details}
    ...  iterations_per_node=${ITERATIONS_PER_NODE}
    ...  report=${REPORT}
    ...  customers_list=${CUSTOMERS_LIST}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  kpi_targets=${kpi_targets}
    ...  use_dcap=${USE_DCAP}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  &{TEST_PARAMETERS}

TC Setup
    Log  TC Setup

TC Teardown
    Log  TC Teardown
