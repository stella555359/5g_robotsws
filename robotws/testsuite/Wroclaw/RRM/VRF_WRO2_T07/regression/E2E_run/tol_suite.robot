*** Settings ***
Documentation
...   maintainer: Bartosz Kozlowski
...   contact: bartosz.1.kozlowski@nokia.com
...   Test suite for tput tests for TOL

Library         Collections
Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/TOL/sfp_monitoring/keywords.py
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/TOL/tol_tput_tests.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/TOL/tol_voice_tests.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/TOL/tol_powersaving_tests.robot

*** Variables ***
${FULL_COMMISSIONING_SCF_PATH}=    /home/ute/scf_25R2_mop_17.xml

@{AHFII_attenuator_ports}     9     10    #cell 41
@{AHLOB_attenuator_ports}     17    18    #cell 11
${AHLOB_BBMOD_dist_name}=    MRBTS-55270/EQM-1/APEQM-1/CABINET-1/BBMOD-1
${AHFII_BBMOD_dist_name}=    MRBTS-55270/EQM-1/APEQM-1/CABINET-1/BBMOD-5
${AHLOB_RU_dist_name}=    MRBTS-55270/EQM-1/APEQM-1/RMOD-1
${AHFII_RU_dist_name}=    MRBTS-55270/EQM-1/APEQM-1/RMOD-4
${AHLOB_powersaving_cell_id}=    11
${AHFII_powersaving_cell_id}=    41
@{NRPGRP_AHLOB}=    0     mixed switch off
@{NRPGRP_AHFII}=    1     cell switch off
${SA_UE_caps}=     SA
${NSA_UE_caps}=    NSA

${RP_CA}                       VRF_RRM
${RP_LOCATION}                 VRF_WRO2
${RP_ORGANIZATION}             VRF_WRO2_T07

${SOURCE_SW}=    SBTS25R1_ENB_0000_000509_000064
${TARGET_SW}=    SBTS25R2_ENB_0000_000397_000000
${SHOULD_BE_REPORTED}=   False
${CUSTOMERS}=            TMO US
@{CRITICAL_FAULTS}=    ${None}
${CUSTOM_ALARMS}=    ${None}

&{GNB1}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}
...         critical_alarms=@{CRITICAL_FAULTS}     custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}                    ${GNB1}

@{BANDS_AHLOB}         ${71}
@{BANDS_AHFII}         ${66}    ${25}
@{BANDS_AEHC}          ${41}
*** Test Cases ***
#OAM Tests
Upgrade_Rollback_ASIM_Webem
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}
    ...  restore_to_target_sw=True

Full_commisioning_LTE_5G_Webem
    AdminUtils.Download Current Scf     ${OUTPUT_DIR}    full_commissioning.xml
    AdminUtils.Perform Commissioning    ${FULL_COMMISSIONING_SCF_PATH}

[1]BTS_OnAir_ASIL_Webem
    AdminUtils.Wait For All Cells On Air State

BTS_Block_Unblock_ASIM_Webem
    E2E TL BTS BLOCK UNBLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

BTS_Power_Reset_ASIM_Webem
    E2E TL POWER SITE RESET WITHOUT HWF WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

BTS_Reset_Site_ASIM_Webem
    E2E TL ACTIVATION RESET TEST
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

RAT_Block_Unblock_NR_ASIM_Webem
    Block And Unblock Rat    NR

RAT_Block_Unblock_LTE_ASIM_Webem
    Block And Unblock Rat    LTE

RAT_LTE_Reset_ASIM_Webem
    Reset RAT    LTE

BBMOD_Lock_Unlock_ASIM_ABIA_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    ${bbmod}    Select Random Bbmod Distname With Name    ABIA
    @{bbmods}    Prepare List Of Modules For Test    ${bbmod}
    Set To Dictionary    ${GNB1}    modules_for_test    ${bbmods}
    E2E TL CAPACITY MODULE LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

BBMOD_Lock_Unlock_ASIM_ABIO_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    ${bbmod}    Select Random Bbmod Distname With Name    ABIO
    @{bbmods}    Prepare List Of Modules For Test    ${bbmod}
    Set To Dictionary    ${GNB1}    modules_for_test    ${bbmods}
    E2E TL CAPACITY MODULE LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

BBMOD_Lock_Unlock_ASIM_ABIP_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    ${bbmod}    Select Random Bbmod Distname With Name    ABIP
    @{bbmods}    Prepare List Of Modules For Test    ${bbmod}
    Set To Dictionary    ${GNB1}    modules_for_test    ${bbmods}
    E2E TL CAPACITY MODULE LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

BBMOD_Reset_ASIM_ABIA_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    ${bbmod}    Select Random Bbmod Distname With Name    ABIA
    @{bbmods}    Prepare List Of Modules For Test    ${bbmod}
    Set To Dictionary    ${GNB1}    modules_for_test    ${bbmods}
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

BBMOD_Reset_ASIM_ABIO_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    ${bbmod}    Select Random Bbmod Distname With Name    ABIO
    @{bbmods}    Prepare List Of Modules For Test    ${bbmod}
    Set To Dictionary    ${GNB1}    modules_for_test    ${bbmods}
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

BBMOD_Reset_ASIM_ABIP_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    ${bbmod}    Select Random Bbmod Distname With Name    ABIP
    @{bbmods}    Prepare List Of Modules For Test    ${bbmod}
    Set To Dictionary    ${GNB1}    modules_for_test    ${bbmods}
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

RMOD_Lock_Unlock_ASIM_AHLOB_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    @{rmods}    Select All Rmods Distnames With Name    AHLOB
    Set To Dictionary    ${GNB1}    modules_for_test    ${rmods}
    E2E TL RU LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

RMOD_Lock_Unlock_ASIM_AHFII_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    @{rmods}    Select All Rmods Distnames With Name    AHFII
    Set To Dictionary    ${GNB1}    modules_for_test    ${rmods}
    E2E TL RU LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

RMOD_Lock_Unlock_ASIM_AEHC_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    @{rmods}    Select All Rmods Distnames With Name    AEHC
    Set To Dictionary    ${GNB1}    modules_for_test    ${rmods}
    E2E TL RU LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

RMOD_Reset_ASIM_AHLOB_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    @{rmods}    Select All Rmods Distnames With Name    AHLOB
    Set To Dictionary    ${GNB1}    modules_for_test    ${rmods}
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

RMOD_Reset_ASIM_AHFII_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    @{rmods}    Select All Rmods Distnames With Name    AHFII
    Set To Dictionary    ${GNB1}    modules_for_test    ${rmods}
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

RMOD_Power_Reset_ASIM_AHLOB_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    @{rmods}    Select All Rmods Distnames With Name    AHLOB
    Set To Dictionary    ${GNB1}    modules_for_test    ${rmods}
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

RMOD_Power_Reset_ASIM_AHFII_Webem
    Remove From Dictionary    ${GNB1}    modules_for_test
    @{rmods}    Select All Rmods Distnames With Name    AHFII
    Set To Dictionary    ${GNB1}    modules_for_test    ${rmods}
    @{RMOD_PDU}    Prepare Rmod Pdu Info By Name    AHFII
    E2E TL RU POWER RESET
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  rmods_with_pdu_ports=${RMOD_PDU}
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

LNCELL_Block_Unblock_ASIM_AHFII_Webem
    Remove From Dictionary    ${GNB1}    cells_to_block
    ${cell}    Select Random Cell On Rmod    AHFII    LTE
    @{cells}    Prepare List Of Modules For Test    ${cell}
    Set To Dictionary    ${GNB1}    cells_to_block    ${cells}
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

LNCELL_Block_Unblock_ASIM_AHLOB_Webem
    Remove From Dictionary    ${GNB1}    cells_to_block
    ${cell}    Select Random Cell On Rmod    AHLOB    LTE
    @{cells}    Prepare List Of Modules For Test    ${cell}
    Set To Dictionary    ${GNB1}    cells_to_block    ${cells}
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

LNCELL_Lock_Unlock_ASIM_AHFII_Webem
    Remove From Dictionary    ${GNB1}    bands_for_test
    Set To Dictionary    ${GNB1}    bands_for_test    ${BANDS_AHFII}
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

LNCELL_Lock_Unlock_ASIM_AHLOB_Webem
    Remove From Dictionary    ${GNB1}    bands_for_test
    Set To Dictionary    ${GNB1}    bands_for_test    ${BANDS_AHLOB}
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${GNB1}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  customers_list=${CUSTOMERS}

### TPUT Tests
BTS_Block_Unblock_Attach_Tput_ASIM_ABIA_AHLOB_Webem
    BTS Block Unblock Attach Tput    ${AHLOB_attenuator_ports}    ${SA_UE_CAPS}

BTS_Block_Unblock_Attach_Tput_ASIM_ABIO_AHFII_Webem
    BTS Block Unblock Attach Tput    ${AHFII_attenuator_ports}    ${SA_UE_CAPS}

RAT_Block_Unblock_Attach_Tput_ASIM_ABIA_AHLOB_Webem
    RAT Block Unblock Attach Tput    ${AHLOB_attenuator_ports}    ${SA_UE_CAPS}

RAT_Block_Unblock_Attach_Tput_ASIM_ABIO_AHFII_Webem
    RAT Block Unblock Attach Tput    ${AHFII_attenuator_ports}    ${SA_UE_CAPS}

BBMOD_Lock_Unlock_Attach_Tput_ASIM_ABIA_AHLOB_Webem
    BBMOD Lock Unlock Attach Tput    ${AHLOB_attenuator_ports}    ${SA_UE_CAPS}    ${AHLOB_BBMOD_dist_name}

BBMOD_Lock_Unlock_Attach_Tput_ASIM_ABIO_AHFII_Webem
    BBMOD Lock Unlock Attach Tput    ${AHFII_attenuator_ports}    ${SA_UE_CAPS}    ${AHFII_BBMOD_dist_name}

RMOD_Lock_Unlock_Attach_Tput_ASIM_ABIA_AHLOB_Webem
    RMOD Lock Unlock Attach Tput    ${AHLOB_attenuator_ports}    ${SA_UE_CAPS}    ${AHLOB_RU_dist_name}

RMOD_Lock_Unlock_Attach_Tput_ASIM_ABIO_AHFII_Webem
    RMOD Lock Unlock Attach Tput    ${AHFII_attenuator_ports}    ${SA_UE_CAPS}    ${AHFII_RU_dist_name}

RMOD_Reset_Attach_Tput_ASIM_ABIA_AHLOB_Webem
    RMOD Reset Attach Tput    ${AHLOB_attenuator_ports}    ${SA_UE_CAPS}    ${AHLOB_RU_dist_name}

RMOD_Reset_Attach_Tput_ASIM_ABIO_AHFII_Webem
    RMOD Reset Attach Tput    ${AHFII_attenuator_ports}    ${SA_UE_CAPS}    ${AHFII_RU_dist_name}

SFP_Monitoring_ASIM_AHLOB_Webem
    ${res}    generic_webem_call    get_sfp_data
    validate_sfp_monitoring_status    ${res}    AHLOB    source
    validate_sfp_monitoring_status    ${res}    AHLOB    destination

SFP_Monitoring_ASIM_AHFII_Webem
    ${res}    generic_webem_call    get_sfp_data
    validate_sfp_monitoring_status    ${res}    AHFII    source
    validate_sfp_monitoring_status    ${res}    AHFII    destination

### VOICE tests
Emergency_Call_ASIM_ABIA_AHLOB
	Emergency Call     ${AHLOB_attenuator_ports}    ${SA_UE_CAPS}

Emergency_Call_ASIM_ABIO_AHFII
	Emergency Call     ${AHFII_attenuator_ports}    ${SA_UE_CAPS}

VoLTE_Call_ASIM_ABIA_AHLOB
	VoLTE Call         ${AHLOB_attenuator_ports}    ${NSA_UE_CAPS}   ${SA_UE_CAPS}

VoLTE_Call_ASIM_ABIO_AHFII
	VoLTE Call         ${AHFII_attenuator_ports}    ${NSA_UE_CAPS}   ${SA_UE_CAPS}

### Power saving tests
Power_Saving_3_CB008951_CB009920_CB010442_CB010443-Coordinated_4G-5G_Power_Saving_Validation_ASIM_AHLOB
    Set up powersaving  ${AHLOB_powersaving_cell_id}    ${NRPGRP_AHLOB}     ${AHLOB_attenuator_ports}    ${SA_UE_CAPS}

Power_Saving_4_CB008951_CB009920_CB010442_CB010443-Coordinated_4G-5G_Power_Saving_Validation_ASIM_AHFII
    Set up powersaving  ${AHFII_powersaving_cell_id}    ${NRPGRP_AHFII}     ${AHFII_attenuator_ports}    ${SA_UE_CAPS}
