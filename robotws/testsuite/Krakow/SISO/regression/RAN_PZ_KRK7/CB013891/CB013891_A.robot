*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO

Documentation
...            author:       Marcin Duplaga, marcin.duplaga@nokia.com
...            maintainer:   Marcin Duplaga, marcin.duplaga@nokia.com

Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK7/CB013891/resources/CB013891_common.robot
Resource    testsuite/Krakow/resources/former_l3_sw2/main_cls.robot

Suite Setup       Run Keywords
...               Testline Setup    reach_on_air=no    wts=${WTS_CFG}    config=${SUITE_CONFIG}    reboot_after_config=yes
...      AND      Configure WTS
...      AND      Combine All UEs List

Suite Teardown    Testline Teardown

Test Setup        Run Keywords
...               Test Case Setup
...      AND      Start WTS and Reach Onair State
Test Teardown     Run Keywords
...               Test Case Teardown    teardown_wts=yes_with_reboot    detach_ues=no
...      AND      Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main Bts Metadata To Report

*** Variables ***
${2_CELLS_SCF}          ${CURDIR}/configs/2_cells_scf_config.xml
${3_CELLS_SCF}          ${CURDIR}/configs/3_cells_scf_config.xml
${WTS_CFG}              ${CURDIR}/configs/basic_setup.cfg
${IPHY_XML}             ${CURDIR}/configs/iphy.xml
${ADD_CELLS_DELTA}      ${CURDIR}/configs/add_cells_delta.json
${DEL_CELLS_DELTA}      ${CURDIR}/configs/delete_cells_delta.json
@{IP_ADDR_SIM_GNB}      eth3:10.0.1.4/24
&{SUITE_CONFIG}         scf=${3_CELLS_SCF}    iphy=${IPHY_XML}    ip_addr=${IP_ADDR_SIM_GNB}    wait_for_state=Configured
@{SA_UE_IDS_CELL_1}     1     2     3
@{SA_UE_IDS_CELL_2}     4     5     6
@{SA_UE_IDS_CELL_3}     7     8     9
@{NSA_UE_IDS_CELL_1}    11    12    13
@{NSA_UE_IDS_CELL_2}    21    22    23
@{NSA_UE_IDS_CELL_3}    31    32    33
${TOTAL_TIMEOUT}        ${3600}
${OPERATIONS}           ['reset_bbmod', 'rat_reset', 'cell_lock_unlock', 'cell_block_unblock']
${OPERATION_KWARGS}     ${None}
${RANDOM_SEED}          ${None}
${L3_CALL}              ${True}
${EMAIL_NOTIFICATION_WHEN_FAIL}    ${False}

*** Test Cases ***
[1]CB013891_General_SiSo_Commissioning_BTS_Template_Commissioning
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{SA_UEs}      call_type=SA
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{NSA_UEs}     call_type=NSA
    Change NIDD Parameter Online    dist=MRBTS-1/MNL-1/MNLENT-1/SYNC-1/CLOCK-1    param=holdOverModeUsed    value=false     timeout=600s
    gnbcell.Wait For All Cells Statuses    availability_status=offline    timeout=360s
    Restart WTS and Wait For All Cells To Be OnAir
    Start Multiple UEs L3 Call And Verify Traffic    ue_ids=@{NSA_UEs}     call_type=NSA
    Start Multiple UEs L3 Call And Verify Traffic    ue_ids=@{SA_UEs}      call_type=SA
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-2    param=expectedCellSize    value=10km
    Verify If All UEs Are Still Active
    Stop Multiple UEs L3 Call    ue_ids=@{SA_UEs}      call_type=SA
    Stop Multiple UEs L3 Call    ue_ids=@{NSA_UEs}     call_type=NSA

[1]CB013891_General_SiSo_Online_Cell_Addition_Deletion
    [Setup]       Run Keywords
    ...           Test Case Setup
    ...    AND    gnbru.Wait For All Radio Units To Be Online    timeout=600
    ...    AND    Fix and Upload SCF    scf=${2_CELLS_SCF}    skip_errors=no    activate=yes
    ...    AND    Wait for All Cells to be Configured    timeout=600
    ...    AND    Start WTS and Reach Onair State
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{SA_UE_IDS_CELL_2}      call_type=SA
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{SA_UE_IDS_CELL_3}      call_type=SA
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{NSA_UE_IDS_CELL_2}     call_type=NSA    target_cells=2
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{NSA_UE_IDS_CELL_3}     call_type=NSA    target_cells=3
    Upload Delta         delta=${ADD_CELLS_DELTA}
    gnbcell.Wait For All Cells To Be OnAir    timeout=360s
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{SA_UEs}      call_type=SA
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{NSA_UEs}     call_type=NSA
    Upload Delta         delta=${DEL_CELLS_DELTA}
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{SA_UE_IDS_CELL_1}      call_type=SA
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{SA_UE_IDS_CELL_2}      call_type=SA
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{NSA_UE_IDS_CELL_1}     call_type=NSA    target_cells=1
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{NSA_UE_IDS_CELL_2}     call_type=NSA    target_cells=2
    [Teardown]    Run Keywords
    ...           Test Case Teardown    teardown_wts=yes    detach_ues=no
    ...    AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main Bts Metadata To Report
    ...    AND    Fix and Upload SCF    scf=${3_CELLS_SCF}    skip_errors=no    activate=yes
    ...    AND    Wait for All Cells to be Configured    timeout=600

[1]CB013891_Manual_SiSo_SM_BTS_Site_Reset
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{SA_UEs}      call_type=SA
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{NSA_UEs}     call_type=NSA
    Reset gNB via GUI and Wait For All Cells To Be OnAir
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{SA_UEs}      call_type=SA
    Start And Stop Multiple UEs L3 Call With Traffic Verification    ue_ids=@{NSA_UEs}     call_type=NSA

[1]CB013891_Robustness
    [Timeout]    2h
    Run Random OAM Operations       operations=${OPERATIONS}
    ...                             timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             operation_kwargs=${OPERATION_KWARGS}
    ...                             random_seed=${RANDOM_SEED}
    ...                             l3_call=${L3_CALL}
    ...                             l3_call_keywords=${L3_CALL_KEYWORDS}
