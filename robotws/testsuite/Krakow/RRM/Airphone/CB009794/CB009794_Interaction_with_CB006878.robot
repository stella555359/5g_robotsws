*** Settings ***
Force Tags    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Library         ../resources/former_l2_sw1/python/traffic_handling.py
Library         ../resources/former_l2_sw1/python/common_keywords.py
Resource        resources/CB009794_resources.robot

Suite Setup     Run keywords    Setup test
...        AND  Enable feature CB006878 Dynamic UL resources allocation for both TDD Cells

Suite Teardown  Run keywords    Disable feature CB006878 Dynamic UL resources allocation for both TDD Cells
...        AND  Clean suite environment

Documentation
...      INTRODUCTION:
...         This feature will introduce cell level NR RTWP PM Counters for each UL spatial stream (AxC or eAxC):
...                         - Minimum RTWP per spatial stream
...                         - Maximum RTWP per spatial stream
...                         - Average RTWP per spatial stream
...         The spatial stream number is dependent on deployments and configurations.
...         RTWP measurement is executed in the UL slots with PUSCH traffic and with no PUSCH traffic (with best effort method).
...         Measurement shall be handled on the spatial streams for carrying PUSCH and is not required for the dedicated
...         streams of carrying PRACH/SRS.
...         RTWP (Received Total Wideband Power) is the sum of the received user signal power of the cell
...         plus all interference and thermal noise power that fall into the UL system bandwidth (S+I+N).
...         In CB009794, measurement is done and reported only on configured PUSCH area. PUCCH is excluded from measurement.
...
...      TEST SET NAME:    CB009794-SR-F NR RTWP PM Counters - PMO#8 Interaction with CB006878 "Dynamic UL resources allocation" on RTWP counters
...
...      TESTING SCOPE:    CB009794-F NR RTWP PM Counters is divided for 5 items(user scenarios)
...                         - CB009794-Feature_and_NR_RTWP_measurement_activation
...                         - CB009794-NR_RTWP_counters_reflects_high_interference_during_a_specific_period
...                         - CB009794-NR_RTWP_increases_with_increase_in_UL_traffic
...                         - CB009794-NR_RTWP_measurement_with_MU-MIMO
...                         - CB009794-Interaction_with_CB006878_Dynamic_UL_resources_allocation_on_NR_RTWP_counters
...                        Under this robot file CB009794-Interaction_with_CB006878_Dynamic_UL_resources_allocation_on_NR_RTWP_counters is tested
...
...      *PRECONDTIONS AND DEPENDENCIES (New Feature only)
...        *PRECONDTIONS:  N/A
...        *DEPENDENCIES:  N/A
...
...      *TEST INSTANCE SPECIFIC NOTES:  N/A
...
...      CONTACTS:         Obszarny, Michal (Nokia - PL/Krakow) <michal.obszarny@nokia.com>
...
...      REFERENCES:       CFAM for CB009794: https://gates.nsn-net.net/view/00026627#o=0
...
...      *TERMS AND ABBREVIATIONS:
...        FR1 - Frequency Range 1
...        SA - Stand Alone
...        PRB - Physical Resource Group
...        PUSCH - Physical Uplink Shared Channel
...        PUCCH - Physical Uplink Control Channel
...        RTWP - Received Total Wideband Power
...
...      HISTORY:
...        V 0.1: 10.02.2023: Michal Obszarny: test case draft
...        V 0.2: 14.02.2023: Michal Obszarny: review created (https://collab.ext.net.nokia.com/ui#review:id=878799)
...        V 0.3: 03.03.2023: Michal Obszarny: review done
...        V 1.0: 21.04.2023: Michal Obszarny: test case finished (documentation completed)

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_TDD_FR1_two_cells.cfg
${scfc}=           ${CURDIR}/config/SCFC_AEQE_2CELLS_ECPRI.xml
${iphy}=           ${CURDIR}/config/IPHY_AEQE_2CELLS_ECPRI.xml
${counters}=       M55369C00000,M55369C00001,M55369C00100,M55369C00101,M55369C00200,M55369C00201

*** Test Cases ***
CB009794-Interaction_with_CB006878_Dynamic_UL_resources_allocation_on_NR_RTWP_counters_TDD_eCPRI_FR1_SA
    [Documentation]
    ...  DESCRIPTION:
    ...      This user scenario is to check interaction with CB006878 "Dynamic UL resources allocation" on RTWP counters.
    ...
    ...  PRECONDITION:
    ...      - gNB configured with TDD cell operating in SA mode
    ...      - MRBTS/NRBTS.actRtwpMeasurement parameter is set to True
    ...      - MRBTS/NRBTS/NRPMRNL.miNrRtwp parameter is set to 5min
    ...      - MRBTS/NRBTS/NRCELL.pucchModeSelect parameter is set to longPucch
    ...      - MRBTS/NRBTS/NRCELL.actDynUlResAlloc parameter is set to True
    ...
    ...  POSTCONDITION:
    ...      Collected PM counters shall not show increase in values when interference is generated on PUCCH area.
    ...
    ...      COUNTER group to verification:
    ...        - M55369C00000 - M55369C00007 (NR_AVG_UL_RTWP_STR_x)
    ...        - M55369C00100 - M55369C00107 (NR_MAX_UL_RTWP_STR_x)
    ...        - M55369C00200 - M55369C00207 (NR_MIN_UL_RTWP_STR_x)
    ...
    ...      SW config debugs:
    ...        - 0x58057E = 128
    ...        - 0x58057A = 4

    [Setup]  Prepare BIP column for PUSCH

    Register 5 UEs to 5G Cell-1
    Establish PDU Sessions for each of 5 UEs
    Start 55Mbps UL data traffic for each of 5 UEs

    Set noise_pucch to value -400 for CELL-1
    Wait for next full PM interval
    Sleep  10s  reason=tput stabilization

    Collect BIP logs  alias=CB009794-DynUlResAlloc  duration=2s
    ${pm_counters}=  Wait for next pm interval and get counters
    Convert BIP logs  alias=CB009794-DynUlResAlloc  num_of_ues=5
    ${bip_counters}=  Calculate RTWP    csv_path=${OUTPUT_DIR}/BIP_LOGS/CB009794-DynUlResAlloc/BIP_PUSCH.csv
    ...                                 num_of_ues=5    long_pucch_start=13    long_pucch_num=247

    Verify counter value  counter=M55369C00000  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=2
    Verify counter value  counter=M55369C00001  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=2

    Verify counter value  counter=M55369C00100  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=2
    Verify counter value  counter=M55369C00101  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=2

    Verify counter value  counter=M55369C00200  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=2
    Verify counter value  counter=M55369C00201  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=2
    Get counters value and report to rp  counters=${counters}  filepath=${pm_counters}  localmoid=NRCELL-1


    Set noise_pucch to value -725 for CELL-1
    Wait for next full PM interval
    Sleep  10s  reason=tput stabilization

    Collect BIP logs  alias=CB009794-DynUlResAlloc  duration=2s
    ${pm_counters}=  Wait for next pm interval and get counters
    Convert BIP logs  alias=CB009794-DynUlResAlloc  num_of_ues=5
    ${bip_counters}=  Calculate RTWP    csv_path=${OUTPUT_DIR}/BIP_LOGS/CB009794-DynUlResAlloc/BIP_PUSCH.csv
    ...                                 num_of_ues=5    long_pucch_start=13    long_pucch_num=247

    Verify counter value  counter=M55369C00000  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=3
    Verify counter value  counter=M55369C00001  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=3

    Verify counter value  counter=M55369C00100  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=3
    Verify counter value  counter=M55369C00101  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=3

    Verify counter value  counter=M55369C00200  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=3
    Verify counter value  counter=M55369C00201  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=3

    Deregister 5 UEs

    Disable feature CB006878 Dynamic UL resources allocation for both TDD Cells
    Wait for gNB reach OnAir after cells parameter update with BTS restart required

    Register 5 UEs to 5G Cell-1
    Establish PDU Sessions for each of 5 UEs
    Start 55Mbps UL data traffic for each of 5 UEs
    Set noise_pucch to value -400 for CELL-1

    Wait for next full PM interval
    Sleep  10s  reason=tput stabilization

    Collect BIP logs  alias=CB009794-DynUlResAlloc  duration=2s
    ${pm_counters}=  Wait for next pm interval and get counters
    Convert BIP logs  alias=CB009794-DynUlResAlloc  num_of_ues=5
    ${bip_counters}=  Calculate RTWP    csv_path=${OUTPUT_DIR}/BIP_LOGS/CB009794-DynUlResAlloc/BIP_PUSCH.csv
    ...                                 num_of_ues=5    long_pucch_start=13    long_pucch_num=247

    Verify counter value  counter=M55369C00000  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=3
    Verify counter value  counter=M55369C00001  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=3

    Verify counter value  counter=M55369C00100  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=3
    Verify counter value  counter=M55369C00101  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=3

    Verify counter value  counter=M55369C00200  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=3
    Verify counter value  counter=M55369C00201  pm_counter_value=${pm_counters}  bip_calculated_value=${bip_counters}  expected_value=-54  margin=3

    [Teardown]  Run keywords
    ...         Deregister 5 UEs
    ...  AND    Deactivate ul_cell_noise
    ...  AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report


*** Keywords ***
Setup test
    Prepare suite environment  egate_config=${lua_cfg_file}  scfc=${scfc}  ap_xml=${iphy}
    Configure  ${CURDIR}/config/activating_rtwp_counters.yaml

Enable feature CB006878 Dynamic UL resources allocation for both TDD Cells
    Set feature flag NRCELL-1/actDynUlResAlloc to True
    Set feature flag NRCELL-2/actDynUlResAlloc to True

Disable feature CB006878 Dynamic UL resources allocation for both TDD Cells
    Set feature flag NRCELL-1/actDynUlResAlloc to False
    Set feature flag NRCELL-2/actDynUlResAlloc to False

Wait for gNB reach OnAir after cells parameter update with BTS restart required
    Check radios availability
    Wait for MIB reception  timeout=60
    Wait for SIB1 reception  timeout=15

Verify counter value
    [Arguments]   ${counter}  ${pm_counter_value}  ${bip_calculated_value}  ${expected_value}  ${margin}
    Verify counter  counter=${counter}  gnb_counters=${pm_counter_value}  margin=${margin}  expected_value=${expected_value}
    Verify counter  counter=${counter}  gnb_counters=${pm_counter_value}  margin=${margin}  expected_value=${bip_calculated_value}

Register 5 UEs to 5G Cell-1
    Set pdu param for internal traffic  UE_ID=1
    Register UE  UE_ID=1  CELL_ID=1
    Set pdu param for internal traffic  UE_ID=2
    Register UE  UE_ID=2  CELL_ID=1
    Set pdu param for internal traffic  UE_ID=3
    Register UE  UE_ID=3  CELL_ID=1
    Set pdu param for internal traffic  UE_ID=4
    Register UE  UE_ID=4  CELL_ID=1
    Set pdu param for internal traffic  UE_ID=5
    Register UE  UE_ID=5  CELL_ID=1

Establish PDU Sessions for each of 5 UEs
    Establish PDU session  UE_ID=1
    Establish PDU session  UE_ID=2
    Establish PDU session  UE_ID=3
    Establish PDU session  UE_ID=4
    Establish PDU session  UE_ID=5

Start ${UL_tput_Mbps} UL data traffic for each of 5 UEs
    Start SA traffic  ue=1  dir=ul  traffic_rate=${UL_tput_Mbps}
    Start SA traffic  ue=2  dir=ul  traffic_rate=${UL_tput_Mbps}
    Start SA traffic  ue=3  dir=ul  traffic_rate=${UL_tput_Mbps}
    Start SA traffic  ue=4  dir=ul  traffic_rate=${UL_tput_Mbps}
    Start SA traffic  ue=5  dir=ul  traffic_rate=${UL_tput_Mbps}

Release PDU Sessions for each of 5 UEs
    Release PDU session  UE_ID=1
    Release PDU session  UE_ID=2
    Release PDU session  UE_ID=3
    Release PDU session  UE_ID=4
    Release PDU session  UE_ID=5

Deregister 5 UEs
    Deregister UE  UE_ID=1
    Deregister UE  UE_ID=2
    Deregister UE  UE_ID=3
    Deregister UE  UE_ID=4
    Deregister UE  UE_ID=5
