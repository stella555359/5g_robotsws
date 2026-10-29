*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010564
...   author: Marcin Bereznicki
...   contact: marcin.bereznicki@nokia.com

Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup     Common Suite Setup With OnAir Test Line Preparation
...             swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...             increase_timeout_for_update_sw=${1200}
Suite Teardown  Common Suite Teardown

Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${ENABLE_RACH_OBSERVER}                 ${False}
@{CELLS_EARFCN}                         718752    711072    724896

*** Test Cases ***
[1]CB010564-SR-B_1_non_CBRS_Ecpri_NR_AWPTD_ABIP_normal_L3call_Nb
    ${len}=     Get Length    ${CELLS_EARFCN}
    Prepare Ue for L3 Call
    FOR    ${cell_num}    IN RANGE    ${len}
        ue.Set earfcn Lock            UE        network_mode=nr5g    earfcn=${CELLS_EARFCN}[${cell_num}]    scs=30
        Run Keyword And Continue On Failure     Verify L3 Call Data Transfer DL&UL
        ...                                     duration=60s
        ...                                     tput_dl=1500 Mbits/sec
        ...                                     tput_ul=220 Mbits/sec
    END
