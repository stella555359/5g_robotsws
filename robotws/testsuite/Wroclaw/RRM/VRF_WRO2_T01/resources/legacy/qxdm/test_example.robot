*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  description:   Example of QXDM test.
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/qxdm/qxdm_auto.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/qxdm/UELogAnalyzer.py    WITH NAME    uea
Library  taf.ue
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_L1Camp.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource  testsuite/Wroclaw/RRM/resources/preconditions.robot


Suite Setup  Run keywords
...          setup_teardown.Get BTS id and set as suite variable    AND
...          Require UE    AT_BASED_UE_1    capabilities=REAL_UE_3


Test Setup  Run keywords
...         start syslog capture    AND
...         Attach UE    AT_BASED_UE_1   AND
...         Fast L3Call Check    ue=AT_BASED_UE_1

Test Teardown   Run keywords
...    stop syslog capture    AND
...    Detach UE    AT_BASED_UE_1


*** Variables ***
@{lines_cell1_5G}       1    2    3    4
@{lines_cell2_5G}       5    6    7    8
@{lines_cell3_5G}       9    10   11   12
${wait_timer}    190s
${tput_timer}    400s

*** Test Cases ***
ENDC Test
    Start Max ULDL TCP    tput_duration=${tput_timer}
    Run QXDM logs    180

    sleep    ${wait_timer}
    Stop ULDL

    Parse HDF to TXT
    Copy logs from UEPC to VM

    parse_tput_logs
    uea.generate_tput_chart


