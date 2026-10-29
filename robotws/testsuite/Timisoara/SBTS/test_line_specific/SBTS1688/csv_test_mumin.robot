*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             Collections

#Suite Setup  Setup Mumin

*** Variables ***
# Mandatory variables to send report to Reporting Portal
# Competence Area from Force Tags will be ignored
# Allowed values: ["VRF_OAM", "VRF_ORAN", "VRF_RRM", "VRF_SiSo", "VRF_TRS", "VRF_VNF", "CIS_*"]
${RP_CA}   VRF_OAM

# Allowed values: ['VRF_BLR1', 'VRF_BLR2', 'VRF_WRO1', 'VRF_WRO2', 'VRF_WRO3', 'VRF_WRO4', 'VRF_HAZ1', 'VRF_HAZ2',
                  # 'VRF_HAZ3', 'VRF_HAZ4', 'VRF_KRK', 'VRF_NPS', 'VRF_DAL', 'VRF_ULM', 'VRF_TSR1', 'VRF_TSR2',
                  # 'VRF_ESP', 'CIS_NPI_GCHN', "CIS_*"]
${RP_LOCATION}    VRF_TSR1

# Allowed values: ${RP_LOCATION} + Team prefix
${RP_ORGANIZATION}    VRF_TSR1_T02

# Email recipients for notifications (use nokia.com or internal.nsn.com domains)
# Multiple emails can be defined by separating them with commas
# Notifications include test start/end and failures
${EMAIL_RECIPIENTS}         None
@{CUSTOMERS_LIST}         Generic
# Software versions used in node definitions
${INITIAL_SW}               None
${TARGET_SW}                None

# Test iteration count used in keyword call
${ITERATIONS}               1

# Node definitions for the test configuration
# Single BTS or fullrack (dualcore, including Airscale + FSM3) configurations require one node
# 4G5G configurations require two nodes
# Define nodes based on logical BTS count
# Node information includes mainly VM IP and software versions; other details are fetched automatically

# UTE testline initialization (VM definition in init must have a Connection object linking VM to BTS)
&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
#...                         mumin_config=/home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1688/csv_test_mumin.robot
# Each node can have its own set of allowed faults during test operation
# Temporary: Expected during upgrade/reset of adjacent node, will be ignored only during its downtime
# Custom: Will be ignored throughout the entire test execution
# Allowed alarms can be passed as e.g 1234,2345 or ${1234, 2345} or @{1234, 2345} or ${CUSTOM_ALLOWED}
@{CUSTOM_ALLOWED}    3456  4567
# List of nodes passed to test keywords
@{NODES}                    ${NODE1}
@{UPGRADE_NODES}            ${NODE1}

*** Test Cases ***
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI    ${NODES}  ${NODE1}   ${ITERATIONS}  customers_list=${CUSTOMERS_LIST}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}  customers_list=${CUSTOMERS_LIST}

*** Keywords ***
Setup Mumin
    log variables
    ${mumin_all}  create dictionary
    set suite variable    ${mumin_all}
    FOR  ${enb}  IN  @{tl.enbs}
      FOR  ${rm}  IN  @{enb.rms}
        ${mumin}  create dictionary  ${rm.lmi.uart_mapping.port}=${rm.radio_type}
        ${mumin_single}  create dictionary
        ...  RMODs=${mumin}
        ...  host=${rm.lmi.host.default_ssh_connection_details.addr}
        ...  user=ute
        ...  password=UTE.debian12
        ...  port=9092
        ...  remote_dir=/home/ute/mumin_test
        ...  python_path=/usr/bin/python3
        Set To Dictionary  ${mumin_all}  ${rm.serial_number}=${mumin_single}
      END
    END
    Set To Dictionary  ${NODE1}  mumin_config=${mumin_all}
