*** Settings ***

Documentation    Script for CB011066_CB009169_Simulated_Environment
...   author: nikhil.ghadge@nokia.com
...   Description: NR FDD ORAN FJT and NR TDD AZQI Radios configured for TDD + FDD Uplink Carrier Aggregation
...   and Test case to verify CB009169: Single UE connection setup with TDD FR1-FDD UL CA.
...   Exe cmd:robot  --outputdir /home/ute/results -L TRACE -b debug.log -d ~/logs/CB011066_CB009169_ET_$(date +%y%m%d) CB011066_CB009169.robot


Resource          CB011066_resource.robot

Suite setup        Suite setup
Test Setup         Test Preconditions
Test Teardown      Test Postconditions
Suite Teardown     Suite Teardown

Force Tags        CLOUD_5G_I_LOO_AP_LOO    SBTS00    CB011066     NR_TDD_FDD_ULCA

*** Test Cases ***
CB011066_Verify_single_UE_A1MR_scell_addition_and_bufferBbased_activation_by_DLUL_data_and_A2MR_Scell_release
    [Tags]    VRF_BLR1    RAN_ST    QC_252475    CRT
    [Documentation]
    ...    lcrId/cellTechnology/Band/physCellId/NR cell ID/chBw
    ...    cell1    FDD    n1    50    16385    20MHz
    ...    cell2    TDD    n78    52    16387    100MHz
    L3 Call For DLCA
    SA 5G Detach
    Activate UL CA Feature    ${NRDU_dist}    carrierAggregationSupportList    ${ca_list1}
    ADMIN Assert All NRCells Are In Enabled State    timeout=900
    L3 Call For ULCA
    SA 5G Detach
    Counter Verification
    ADMIN Assert BTS is onAir    timeout=900
	ADMIN Assert All NRCells Are In Enabled State    timeout=900