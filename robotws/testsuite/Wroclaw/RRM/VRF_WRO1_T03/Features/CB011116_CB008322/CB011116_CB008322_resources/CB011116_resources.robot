*** Settings ***
Documentation
...     Set of keywords using in CB011116 feature test cases

Library    Collections
Library    SSHLibrary
Resource    ../../../Resources/cm_operations/cm_operations.robot
Resource    ../../../Resources/logs_collecting/logs_collecting.robot
Resource    ../../../Resources/phase_shifter/phase_shifter.robot
Resource    ../../../Resources/pm_counters/pm_counters.robot
Resource    ../../../Resources/ue_keywords/ue_keywords.robot
Library    ../../../Resources/tti/TtiAnalysing.py

*** Variables ***
@{expected_step_1}    58000000
@{expected_step_2}    58000000    1080000000
@{expected_step_2_2}    470000000
@{expected_step_34_2}    115000000    115000000    115000000    115000000
@{expected_step_34_1}    305000000    305000000    305000000    305000000

*** Keywords ***
Set CB011116 Test Variables
    ${timestamp}  OperatingSystem.Run    date +%F_%H-%M-%S
    ${LOG_PATH}   OperatingSystem.Join Path    ${OUTPUT DIR}    ${timestamp}_${TEST NAME}
    Create Directory     ${LOG_PATH}
    Set Test Variable    ${LOG_PATH}
    Set Test Variable    ${NR_CELL_ID}         2
    Set Test Variable    ${NR_CALL_CELL_ID}    828375041
    Set Test Variable    &{CAPABILITY_NR_UE1}  REAL_UE_1=NR_UE1
    Set Test Variable    &{CAPABILITY_NR_UE2}  REAL_UE_2=NR_UE2
    Set Test Variable    &{CAPABILITY_NR_UE3}  REAL_UE_3=NR_UE3
    Set Test Variable    &{CAPABILITY_NR_UE4}  REAL_UE_4=NR_UE4
    Set Test Variable    ${PORT_AT_LEONI}      1
    Set Test Variable    ${IP_CHECK}           True

    Create Directory     ${LOG_PATH}/CB011116
    Create Directory     ${LOG_PATH}/CB011116/BIP
    Create Directory     ${LOG_PATH}/CB011116/TTI
    Create Directory     ${LOG_PATH}/CB011116/PMs/Step_1
    Create Directory     ${LOG_PATH}/CB011116/PMs/Step_2
    Create Directory     ${LOG_PATH}/CB011116/PMs/Step_3
    Create Directory     ${LOG_PATH}/CB011116/PMs/Step_4

    Start Syslog    ${LOG_PATH}/CB011116

CB011116 Test Case Scenario
    Setup PS    ${CURDIR}/CB011116_phase_shifter_settings.csv
    Set CB011116 Test Variables
    Activate Tti Collecting
    Prepare Ues For CB011116
    Preconditions For CB008322
    Step 1 CB008322 Scenario
    Preconditions For CB008322    ${True}
    Step 2 CB008322 Scenario
    Preconditions For CB011116    1
    Step 3 CB011116 Scenario
    Preconditions For CB011116    2
    Step 4 CB011116 Scenario
    [Teardown]    Run Keywords    Stop Syslog    AND    Collect Snapshot    ${LOG_PATH}/CB011116_snapshot

Prepare Ues For CB011116
    Log    === Preparing Ues for CB011116 ===    console=True
    Prepare UEs    ${CAPABILITY_NR_UE1}    attach=${False}    detach=${True}
    Prepare UEs    ${CAPABILITY_NR_UE2}    attach=${False}    detach=${True}
    Prepare UEs    ${CAPABILITY_NR_UE3}    attach=${False}    detach=${True}
    Prepare UEs    ${CAPABILITY_NR_UE4}    attach=${False}    detach=${True}
    Log    === Ues for CB011116 prepared ===    console=True

Preconditions For CB008322
    [Arguments]    ${used_2_ues}=${False}
    Log    === Preparing preconditions for CB008322, barr cell 2, attach ues to cell 1, barr cell 1 ===    console=True
    Log    === Barr cell 2, unbarr cell 1 ===    console=True
    Barr Cell    2
    Unbarr Cell    1
    Sleep    60s
    Log    === Attach UE1 and UE2 ===    console=True
    ${attach_ues}    Run Keyword if    ${used_2_ues}    Create List    NR_UE1  NR_UE2  ELSE     Create List    NR_UE1
    Attach UEs    ${attach_ues}
    Sleep    20s
    Log    === Barr cell 1 ===    console=True
#    Barr Cell    1
    Log    === Validate UE info about attached cell id ===    console=True
    Validate UE Info    NR_UE1    CELL_ID    828375041
    Run Keyword if  ${used_2_ues}    Validate UE Info    NR_UE2    CELL_ID    828375041
    Log    === Precondition for CB008322 finished ===    console=True

Preconditions For CB011116
    [Arguments]    ${cell_id}=1
    ${barr_cell}    ${unbarr_cell}=    Run Keyword If    '${cell_id}'=='1'    Set Variable    2    1
    ...     ELSE IF    '${cell_id}'=='2'    Set Variable    1    2
    Log    === Preparing preconditions for CB011116, barr cell ${barr_cell},    console=True
    Log    attach ues to cell ${unbarr_cell}, barr cell ${unbarr_cell} ===    console=True
    Log    === Barr cell ${barr_cell}, unbarr cell ${unbarr_cell} ===    console=True
    Barr Cell    ${barr_cell}
    Unbarr Cell    ${unbarr_cell}
    Sleep    60s
    Log    === Attach UE1, UE2, UE3 and UE4 ===    console=True
    ${attach_ues}=    Create List    NR_UE1    NR_UE2    NR_UE3    NR_UE4
    Attach UEs    ${attach_ues}
    Sleep    20s
    Log    === Barr cell ${unbarr_cell} ===    console=True
#    Barr Cell    ${unbarr_cell}
    Log    === Validate UE info about attached cell id ===    console=True
    Validate UE Info    NR_UE1    CELL_ID    82837504${unbarr_cell}
    Validate UE Info    NR_UE2    CELL_ID    82837504${unbarr_cell}
    Validate UE Info    NR_UE3    CELL_ID    82837504${unbarr_cell}
    Validate UE Info    NR_UE4    CELL_ID    82837504${unbarr_cell}
    Log    === Precondition for CB011116 finished ===    console=True

Step 1 CB008322 Scenario
    [Arguments]    ${tti_name}=CB008322_step_1
    Remove Old Logs From Tmp    ${tti_name}
    Log    === Start first step for CB008322 feature ===    console=True
    Adjust Time To New Pm Interval
    Start Tput    ue=NR_UE1    dt_name=NR_DL1    tput_dl=50    direction=dl    apn=5gwrowpt1
#    Sleep    70s
#    Log    === Collect BIP logs ===    console=True
#    Collect Bip    Bip_step_1    ${LOG_PATH}/CB011116_CB008322/BIP
#    Log    === Stop Collecting BIP logs ===    console=True
    Sleep    50s
    Log    === Collect TTI logs ===    console=True
    Collect TTI    ${tti_name}
    Check Average Tput 8322  expected=${expected_step_1}   primary_cell=1    file_name=${tti_name}
    Check Counter Condition    ${LOG_PATH}/CB011116/PMs/Step_1      M55196C00002/NRCELL-1>=300
    ...                                                             M55196C00004/NRCELL-1>=1
    ...                                                             M55196C00009/NRCELL-1>=290
    ...                                                             M55196C00010/NRCELL-1=0
    ...                                                             M55196C00011/NRCELL-1>=1
    ...                                                             M55196C00012/NRCELL-1=0
    ...                                                             M55196C00013/NRCELL-1>=300

    [Teardown]    Run Keywords
    ...    Stop Data Transfer For All Ues    AND    Detach ues    NR_UE1    AND
    ...    Log    === First step for CB008322 feature finished ===    console=True

Step 2 CB008322 Scenario
    [Arguments]    ${tti_name}=CB008322_step_2
    Remove Old Logs From Tmp    ${tti_name}
    Log    === Start second step for CB008322 feature ===    console=True
    Adjust Time To New Pm Interval
    Log    === Start throughput (CB008322) ===    console=True
    Start Tput    ue=NR_UE1    dt_name=NR_DL1    tput_dl=50    direction=dl    apn=5gwrowpt1
    Start Tput    ue=NR_UE2    dt_name=NR_DL2    tput_dl=1450    direction=dl    apn=5gwrowpt1
#    Sleep    70s
#    Log    === Collect BIP logs ===    console=True
#    Collect Bip    Bip_step_2    ${LOG_PATH}/CB011116_CB008322/BIP
#    Log    === Stop Collecting BIP logs ===    console=True
    Sleep    50s
    Log    === Collect TTI logs ===    console=True
    Collect TTI    ${tti_name}
    Check Average Tput 8322    expected=${expected_step_2}   primary_cell=1    file_name=${tti_name}
    Check Average Tput 8322    expected=${expected_step_2_2}    secondary_cell=2  file_name=${tti_name}
    Check Counter Condition    ${LOG_PATH}/CB011116/PMs/Step_2      M55196C00002/NRCELL-1>=600
    ...                                                             M55196C00004/NRCELL-1>=2
    ...                                                             M55196C00009/NRCELL-1>=230
    ...                                                             M55196C00010/NRCELL-1>=230
    ...                                                             M55196C00011/NRCELL-1>=1
    ...                                                             M55196C00012/NRCELL-1>=1
    ...                                                             M55196C00013/NRCELL-1>=300
    ...                                                             M55371C00157/NRCELL-1>=900
#    ...                                                             M55371C00191/LNCELL-1>=2000
    [Teardown]    Run Keywords
    ...    Stop Data Transfer For All Ues    AND    Detach ues    NR_UE1    AND
    ...    Detach ues    NR_UE2    AND
    ...    Log    === Second step for CB008322 feature finished ===    console=True

Step 3 CB011116 Scenario
    [Arguments]    ${tti_name}=CB011116_step_3
    Log    === Start third step for CB011116 feature ===    console=True
    Log    === Remove old logs ===    console=True
    Remove Old Logs From Tmp    ${tti_name}
    Log    === Old logs removed ===    console=True
    Log    === Wait for new pm interval ===    console=True
    Adjust Time To New Pm Interval
    Log    === Start throughput (CB011116) ===    console=True
    Start Tput    NR_UE1    NR_DL1    tput_dl=600    duration=2400s    direction=dl    apn=5gwrowpt1
    Start Tput    NR_UE2    NR_DL2    tput_dl=600    duration=2400s    direction=dl    apn=5gwrowpt1
    Start Tput    NR_UE3    NR_DL3    tput_dl=600    duration=2400s    direction=dl    apn=5gwrowpt1
    Start Tput    NR_UE4    NR_DL4    tput_dl=600    duration=2400s    direction=dl    apn=5gwrowpt1
#    Sleep    10s    reason=Waiting to call stabilize
#    Log    === Collect BIP logs ===    console=True
#    Collect Bip    Bip_step_3    ${LOG_PATH}/CB011116_CB008322/BIP
#    Log    === Stop Collecting BIP logs ===    console=True
    Sleep    10s
    Log    === Collect tti logs ===    console=True
    Collect TTI    ${tti_name}
    Log    === Collect and check pm counters ===    console=True
    Verify subband with tti logs on Cell    1    ${tti_name}
    Check Average Tput    ${expected_step_34_1}    primary_cell=1    file_name=${tti_name}
    Check Average Tput    ${expected_step_34_2}    primary_cell=2    file_name=${tti_name}
    [Teardown]    Run Keywords
    ...    Stop Data Transfer For All Ues    AND    Detach ues    NR_UE1    AND
    ...    Detach ues    NR_UE2    AND    Detach ues    NR_UE3    AND    Detach ues    NR_UE4    AND
    ...    Log    === Third step for CB011116 feature finished ===    console=True

Step 4 CB011116 Scenario
    [Arguments]    ${tti_name}=CB011116_step_4
    Log    === Start fourth step for CB011116 feature ===    console=True
    Log    === Remove old logs ===    console=True
    Remove Old Logs From Tmp    ${tti_name}
    Log    === Old logs removed ===    console=True
    Log    === Wait for new pm interval ===    console=True
    Adjust Time To New Pm Interval
    Log    === Start throughput (CB011116) ===    console=True
    Start Tput    NR_UE1    NR_DL1    tput_dl=600    duration=2400s    direction=dl    apn=5gwrowpt1
    Start Tput    NR_UE2    NR_DL2    tput_dl=600    duration=2400s    direction=dl    apn=5gwrowpt1
    Start Tput    NR_UE3    NR_DL3    tput_dl=600    duration=2400s    direction=dl    apn=5gwrowpt1
    Start Tput    NR_UE4    NR_DL4    tput_dl=600    duration=2400s    direction=dl    apn=5gwrowpt1
#    Sleep    10s    reason=Waiting to call stabilize
#    Log    === Collect BIP logs ===    console=True
#    Collect Bip    Bip_step_4    ${LOG_PATH}/CB011116_CB008322/BIP
#    Log    === Stop Collecting BIP logs ===    console=True
    Sleep    10s
    Log    === Collect tti logs ===    console=True
    Collect TTI    ${tti_name}
    Log    === Collect and check pm counters ===    console=True
    Verify subband with tti logs on Cell    2    ${tti_name}
    Check Average Tput    ${expected_step_34_1}    primary_cell=1    file_name=${tti_name}
    Check Average Tput    ${expected_step_34_2}    primary_cell=2    file_name=${tti_name}
    [Teardown]    Run Keywords
    ...    Stop Data Transfer For All Ues    AND    Detach ues    NR_UE1    AND
    ...    Detach ues    NR_UE2    AND    Detach ues    NR_UE3    AND    Detach ues    NR_UE4    AND
    ...    Log    === Fourth step for CB011116 feature finished ===    console=True

Verify subband with tti logs on Cell
    [Arguments]    ${cell_id}    ${tti_name}
    Log    KW TO DO
    Check Counter Condition    ${LOG_PATH}/CB011116/PMs/Step_3      M55124C03001/NRCELL-${cell_id}>0
    ...                                                             M55124C03002/NRCELL-${cell_id}>0
    ${primary_cell}=    Set Variable If    ${cell_id}==1    1    2
    ${secondary_cell}=    Set Variable If    ${cell_id}==1    2    1
    ${primary}=    Create Dictionary    lcrId=${primary_cell}
    ${secondary}=    Create Dictionary    lcrId=${secondary_cell}
    ${sw}=  admin.get_sw_version
    setup tti    input_file=/tmp/${tti_name}.pcap    output_folder=/home/ute/tests/11116/fail
    ...    output_format=legacyCsv    sw_version=${sw}  message_filter=dlFdSchedData    alias=subband_${cell_id}
    Check Subband Status    beamType  SUBBAND  dlFdSchedData    90%    ${primary}    alias=subband_${cell_id}
    Check Subband Status    beamType  PMI  dlFdSchedData    90%    ${secondary}    alias=subband_${cell_id}
    [Teardown]    delete_alias    subband_${cell_id}

Check Average Tput
    [Arguments]    ${expected}    ${primary_cell}=${False}    ${secondary_cell}=${False}    ${file_name}=dry_run
    Log    KW TO DO
    ${sw}=  admin.get_sw_version
    ${cell_1}=    Create Dictionary    lcrId=${primary_cell}
    ${cell_2}=    Create Dictionary    lcrId=${secondary_cell}
    setup tti    input_file=/tmp/${file_name}.pcap    output_folder=${LOG_PATH}/CB011116/TTI
    ...    output_format=legacyCsv    sw_version=${sw}  message_filter=dlFdSchedData    alias=${file_name}
    Run Keyword If  ${primary_cell}  count average tput  ${expected}    group_by=${cell_1}    alias=${file_name}
    Run Keyword If  ${secondary_cell}    count average tput  ${expected}    group_by=${cell_2}    alias=${file_name}
    [Teardown]    delete_alias    ${file_name}

Check Average Tput 8322
    [Arguments]    ${expected}    ${primary_cell}=${False}    ${secondary_cell}=${False}    ${file_name}=dry_run
    Log    KW TO DO
    ${sw}=  admin.get_sw_version
    ${cell_1}=    Create Dictionary    lcrId=${primary_cell}
    ${cell_2}=    Create Dictionary    lcrId=${secondary_cell}
    setup tti    input_file=/tmp/${file_name}.pcap    output_folder=${LOG_PATH}/CB011116/TTI
    ...    output_format=legacyCsv    sw_version=${sw}  message_filter=dlFdSchedData    alias=${file_name}
    Run Keyword If  ${primary_cell}  count average tput  ${expected}    group_by=${cell_1}  alias=${file_name}
    Run Keyword If  ${secondary_cell}    count average tput  ${expected}    group_by=${cell_2}  alias=${file_name}
    [Teardown]    delete_alias    ${file_name}
