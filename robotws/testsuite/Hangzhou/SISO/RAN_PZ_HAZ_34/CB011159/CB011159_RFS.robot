*** Settings ***
Suite Setup          Run keywords
...    Perform Site Power Off    gnb_index=${1}
...    model=${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
...    AND    SBTS Suite Setup
Suite Teardown       SBTS Suite Teardown
#Test Setup           SBTS Test Setup
#Test Teardown        SBTS Test Teardown
Test Timeout         3h

Resource      ./resource/CB011159_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB011159-CA RF sharing in SBTS25R1 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Test Cases ***
[1]CB011159_SR_CA_1_Verify_CellSetup_With_NR-1cc-8d8u+LTE-1cc-8D8U-RFS-mode
    [Tags]    1S-1CC-8D8U-NR-LTE-RFS   CRT_TRUNK
    [Setup]     SBTS Test Setup
    add fault to the allowed fault list    faultId=${16}
    ${fault_list}    Create List    16    4220
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Commissioning SCF And Check On Air For RF Sharing   RFSmode=NR_LTE
    ${cell_list}    create list    ${1}
    set test variable   ${SAVE LOG DIRECTORY}    ${CASE_LOG_PATH}
    # Run Keyword If    ${MRBTS_ID}==${2168}    Samsung open screen
    # Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}    4G_check=${False}
    # Run Keyword If    ${MRBTS_ID}==${2168}    Samsung open screen
    Start L3Call And Send DL UL Packet    dl_throughput=200M   ul_throughput=20M   ue_index=0
    ...   buffer_size=1400   gnb_index=1
    [Teardown]   Run Keywords   Stop L3Call And DL UL Traffic   ue_index=0
    ...   AND   SBTS Test Teardown    AND    SBTS Test Teardown With GNB Index

[1]CB011159_SR_CA_2_Verify_Tput_With_1UE
    [Tags]    1S-1CC-8D8U-NR-LTE-RFS   CRT_TRUNK
    [Setup]    SBTS Test Setup
    ${cell_list}    create list    ${1}
    set test variable   ${SAVE LOG DIRECTORY}    ${CASE_LOG_PATH}
    # Run Keyword If    ${MRBTS_ID}==${2168}    Samsung open screen
    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}    4G_check=${False}
    [Teardown]    Run Keywords   SBTS Test Teardown    AND    SBTS Test Teardown With GNB Index

[1]CB011159_SR_E1_1_Verify_CellSetup_With_NR+NR_RFS_full_panel
    [Tags]    1S-1CC-8D8U-NR-NR-RFS   CRT_TRUNK
    [Setup]     run keywords   Perform Site Power Off    gnb_index=${1}
    ...   model=${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    ...   AND   SBTS Test Setup
    add fault to the allowed fault list    faultId=${16}
    ${fault_list}    Create List    16    4220
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Commissioning SCF And Check On Air For RF Sharing   RFSmode=NR_NR_AEQE
    ${cell_list}    create list    ${1}
    set test variable   ${SAVE LOG DIRECTORY}    ${CASE_LOG_PATH}
#    Start L3Call And Send DL UL Packet    dl_throughput=200M   ul_throughput=20M   ue_index=0
#    ...   buffer_size=1400   cell_index=1   gnb_index=1
#    Stop L3Call And DL UL Traffic   ue_index=0
    [Teardown]   Run Keywords   SBTS Test Teardown    AND    SBTS Test Teardown With GNB Index

[1]CB011159_SR_E2_4_Verify_CellSetup_NR+NR_split_mode
    [Tags]    1S-1CC-8D8U-NR-NR-RFS   CRT_TRUNK
    [Setup]     run keywords   Perform Site Power Off    gnb_index=${1}
    ...   model=${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    ...   AND   SBTS Test Setup
    add fault to the allowed fault list    faultId=${16}
    ${fault_list}    Create List    16    4220
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Commissioning SCF And Check On Air For RF Sharing   RFSmode=NR_NR_AEQE_Split
    ${cell_list}    create list    ${1}
    set test variable   ${SAVE LOG DIRECTORY}    ${CASE_LOG_PATH}
#    Start L3Call And Send DL UL Packet    dl_throughput=200M   ul_throughput=20M   ue_index=0
#    ...   buffer_size=1400   cell_index=1   gnb_index=1
#    Stop L3Call And DL UL Traffic   ue_index=0
    [Teardown]   Run Keywords   SBTS Test Teardown    AND    SBTS Test Teardown With GNB Index
