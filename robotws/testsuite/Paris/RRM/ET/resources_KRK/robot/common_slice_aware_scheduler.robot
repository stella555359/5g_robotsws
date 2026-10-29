*** Settings ***
Documentation
...   author: Jacek Kozmic, Adrianna Pienkowska
...   contact: jacek.kozmic@nokia.com, adrianna.pienkowska@nokia.com
...   description: Common Robot keywords for Slice Aware Scheduler

Library    ute_wtssim
Library    ute_fsmaccess
Library    ute_tshark
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_egate
Library    ta5g_syslog
Library    ta5g_pm_counters
Library    taf.ul.ue.sim.env_setup                                                       WITH NAME    env__
Library    testsuite/Paris/RRM/ET/resources_KRK/python/mcshark_management.py             WITH NAME    mcshark__
Library    testsuite/Paris/RRM/ET/resources_KRK/python/common_gnb.py                     WITH NAME    gnb__
Library    testsuite/Paris/RRM/ET/resources_KRK/python/counters.py                       WITH NAME    counters__
Library    testsuite/Paris/RRM/ET/resources_KRK/python/common_wts.py                     WITH NAME    wts__
Library    testsuite/Paris/RRM/ET/resources_KRK/python/bip_management.py                 WITH NAME    bip__
Library    testsuite/Paris/RRM/ET/resources_KRK/python/slice_scheduling/logs.py          WITH NAME    logs__
Library    testsuite/Paris/RRM/ET/resources_KRK/python/slice_scheduling/suite.py         WITH NAME    suite__

*** Keywords ***

Custom Config Setup
    [Arguments]   ${scf}    ${iphy}
    env__.add_gnb_configuration
    ...  scfc=${scf}
    env__.add_simulator
    ...  sim_type=Airphone
    ...  config=${iphy}
    env__.configure_environment

Prepare Environment For Tests Without Rebooting
    [Arguments]    ${tc}
    wts__.Ensure Wts Is Not Running
    gnb__.Ensure Cplane Flags Existence In Swconfig
    gnb__.Ensure Cp Runtime Ini Has LoggingSeverity Set On Trace
    suite__.Create Output Dir Tc
    ...    tc=${tc}
    suite__.Remove Admin Logs If Exists

Suite Setup Slicing
    [Arguments]    ${eth3_ips}=${None}    ${eth4_ips}=${None}
    suite__.Configure Ips On Eth3 Eth4 Interfaces
    ...    ${eth3_ips}
    ...    ${eth4_ips}
    mcshark__.Download Mcshark If Not Present
    gnb__.Collect Scf File
    ...    final_path=${OUTPUT_DIR}/Default_scf.xml
    ...    set_variable=True

Test Setup Slicing
    [Arguments]    ${tc}     ${cell_technology}=${None}
    suite__.Set Variables Based On Deployment And Release
    suite__.Set Cell Variables Test
    ...    cell_technology=${cell_technology}
    Prepare Environment For Tests Without Rebooting
    ...    tc=${tc}

Test Teardown Slicing
    [Arguments]    ${collect_snapshots}=${False}
    suite__.Try To Send Result To Rep Portal
    Run Keyword And Ignore Error
    ...    logs__.Stop Syscom Collection
    Run Keyword And Ignore Error
    ...    Ng Link Logs Stop
    Run Keyword And Ignore Error
    ...    logs__.Stop Bip Capture
    Run Keyword And Ignore Error
    ...    logs__.Stop Syslog Capture
    Run Keyword And Ignore Error
    ...    wts__.Stop Wts And Clear
    Run Keyword If    ${collect_snapshots}
    ...    logs__.Get Gnb Snapshot
    Run Keyword If    ${collect_snapshots}
    ...    logs__.Get Ap Snapshot
    gnb__.Perform Gnb Commissioning
    ...    scf_file=${COLLECTED_SCF_FILE}
