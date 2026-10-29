*** Settings ***
Documentation    Baseline for all tests in Wroclaw/RRM/WRO_2
Resource    taf/ul/ettf/main.robot

Library    ute_fsmaccess
Library    ute_tshark

Variables     taf/ul/ettf/logging/policies.py
Variables     taf/ul/ettf/log_analysis/policies.py


*** Variables ***
${LOGGING_POLICY}=      SYSLOGS_PER_TEST_SUITE
${LOG_ANALYSIS_POLICY}=      SYSLOG_ANALYSIS_POLICY
