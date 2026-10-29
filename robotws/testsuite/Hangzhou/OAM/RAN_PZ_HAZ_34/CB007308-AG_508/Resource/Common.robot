*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.collectors.btslog       WITH NAME    btslog
Library     taf.collectors.core         WITH NAME    core
Resource    ../../common/taf_coam.robot
Resource    ../../common/qc_tag.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Variables   ../../libraries/global_vars.py

*** Variables ***

*** Keyword ***
Common Setup
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    ${gnb_release}   Get gnb release
    Wait Until Keyword Succeeds   10m   1m   COAM WEBUI Login
    Wait Until Keyword Succeeds   10m   1m   COAM Login
#    COAM Backup SCF
#    Wait Until Keyword Succeeds   3x   30s   Perform sub-feature SCF   feature_name=CB007308
#    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
#    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    COAM WEBUI Whether Close Start Up View Window
    Modify Parameter enableDefaultPasswdAlarm   Active_Value=false
    Config LSS Server on WebEM
    Run Keyword And Ignore Error   Validate and Activate Parameter
    Check Fault 4459 Clear Status
    Remove LSS Snapshot
#    Add COAM User at VM
    # Set QC Instance ID Test Tag

Common Teardown
    # Run Keyword And Ignore Error   COAM Login
    # wait until keyword succeeds     5x    5min   COAM SCF Commission
    Run Keyword And Ignore Error   COAM WEBUI Logout
    Run Keyword And Ignore Error   COAM Logout
    CI_interface.Common Case Teardown

Set QC Instance ID Test Tag
    ${qc_def}   Get Common Tags Info By SMOD and Release   file_path=${CURDIR}${/}qc_id_def.csv
    Set Case Common Tags By Test Aggregate   qc_def=${qc_def}

Case Setup
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}
    ...                                filter_param=BTS name
    ...                                new_value=MRBTS-${BTS}
    run keyword and ignore error     selenium_coam.delete_parameter     dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Fault snapshot triggers
     run keyword and ignore error     selenium_coam.delete_parameter     dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    filter_param=Syslog substring trigger
    Run Keyword And Ignore Error   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/AMGR-1
    ...                                filter_param=Enable default password alarm
    ...                                new_value=false
    sleep    2s
    Validate and Activate Parameter
#    sleep    30s
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Syslog substring trigger
    ...                                new_value=active 4459
    run keyword and ignore error     selenium_coam.add_element    dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
     ...    filter_param=Local symptoms server configuration   timeout=${100}
    sleep    2s
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Diagnostic Snapshot destination
    ...                                new_value=lss
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Local symptoms server IP address
    ...                                new_value=${LSS_Server_ip}
    Run Keyword And Ignore Error    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                filter_param=Local symptoms server IP port number
    ...                                new_value=${LSS_Server_Port_Num}
    Validate and Activate Parameter
#    Check Fault 4459 Clear Status
    Remove LSS Snapshot
