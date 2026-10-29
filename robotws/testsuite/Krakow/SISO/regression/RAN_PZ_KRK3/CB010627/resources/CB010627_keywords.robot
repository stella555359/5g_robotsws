*** Settings ***
Documentation
...   Resource files for regression testing of feature CB010627 (AWHQC support for BW 50MHz)
...   author: Marek Bodziony
...   contact: marek.bodziony@nokia.com

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/resources/robot/L3Call.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning          WITH NAME   gnb_scf
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations       WITH NAME   gnb_cell
Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations     WITH NAME   ASiR_HUB
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.CB010627.resources.automation_helper.AsirHelper    WITH NAME   ASiR_helper
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.CB010627.resources.automation_helper.BtsHelper     WITH NAME   BTS_helper
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   asir_deltas.py

*** Variables ***
${capabilities}     REAL_UE
${tput_dl}          150 MBits/sec
${tput_ul}          45 MBits/sec
${duration}         30s
${deviation_dl}     25%
${deviation_ul}     40%

*** Keywords ***
TC01 test setup
    Run keywords
    ...         Common Preconditions with watching alarms
    ...         Allow alarm 'Failure detected on assigned antennas' on BTS during test
    ...         Load Config1 for BTS and ASiR and wait for onair
    ...         Disable PoE for AWHQC-1 and AWHQC-2
    ...         Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-1 and AWHQC-2
    ...         Verify if Cell-0 and Cell-1 are disabled

TC02 test setup
    Run keywords
    ...         Common Preconditions with watching alarms
    ...         Allow alarm 'Failure detected on assigned antennas' on BTS during test
    ...         Load Config2 for BTS and ASiR and wait for onair
    ...         Disable PoE for AWHQC-1 and AWHQC-2 (supercell)
    ...         Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-1 and AWHQC-2 (supercell)
    ...         Verify if Cell-0 is disabled

TC03 test setup
    Run keywords
    ...         Load Config2 for BTS and ASiR and wait for onair
    ...         Common Preconditions with watching alarms
    ...         Allow alarm 'Cell blocked' on BTS during test
    ...         Prepare UE for test

TC04 test setup
    Run keywords
    ...         Load Config1 for BTS and ASiR and wait for onair
    ...         Common Preconditions with watching alarms
    ...         Prepare UE for test

TC01 test teardown
    Run keywords
    ...         Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-1 and AWHQC-2
    ...         Verify if Cell-0 and Cell-1 are enabled
    ...         Disallow alarm 'Failure detected on assigned antennas' on BTS after test
    ...         Common Postconditions with watching alarms

TC02 test teardown
    Run keywords
    ...         Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-1 and AWHQC-2 (supercell)
    ...         Verify if Cell-0 is enabled
    ...         Disallow alarm 'Failure detected on assigned antennas' on BTS after test
    ...         Common Postconditions with watching alarms

TC03 test teardown
    Run keywords
    ...         Unblock Cell-0 after test if blocked
    ...         Unblock Cell-1 after test if blocked
    ...         Disallow alarm 'Cell blocked' on BTS after test
    ...         Common Postconditions with watching alarms

Allow alarm 'Failure detected on assigned antennas' on BTS during test
    gnb_alarm.Allow Alarm         Failure detected on assigned antennas

Disallow alarm 'Failure detected on assigned antennas' on BTS after test
    gnb_alarm.Disallow Alarm      Failure detected on assigned antennas

Allow alarm 'Cell blocked' on BTS during test
    gnb_alarm.Allow Alarm         Cell blocked

Disallow alarm 'Cell blocked' on BTS after test
    gnb_alarm.Disallow Alarm      Cell blocked

Set SCF path for current SW release
    ${release}       BTS_helper.get_current_sw_release
    Set Test Variable   ${config1_GNB_scf_path}         commissionings/Krakow/7_7_UTE5GCLOUDT4SK146/${release}/SCF_gnb_config1.xml
    Set Test Variable   ${config1_ASiR_scf_path}        commissionings/Krakow/7_7_UTE5GCLOUDT4SK146/${release}/SCF_asir_config1.xml
    Set Test Variable   ${config2_GNB_scf_path}         commissionings/Krakow/7_7_UTE5GCLOUDT4SK146/${release}/SCF_gnb_config2.xml
    Set Test Variable   ${config2_ASiR_scf_path}        commissionings/Krakow/7_7_UTE5GCLOUDT4SK146/${release}/SCF_asir_config2.xml

Load Config1 for BTS and ASiR and wait for onair
    Set SCF path for current SW release
    Load Config1 for BTS
    Load Config1 for ASiR

Load Config2 for BTS and ASiR and wait for onair
    Set SCF path for current SW release
    Load Config2 for BTS
    Load Config2 for ASiR

Load Config1 for BTS
    gnb_scf.perform_bts_full_commissioning  scf_file=${config1_GNB_scf_path}
    Wait Until Keyword Succeeds	    5 min	15 sec      Verify if all sHUB's are operational

Load Config1 for ASiR
    ASiR_HUB.perform_asir_commissioning     scf_path=${config1_ASiR_scf_path}
    Wait Until Keyword Succeeds	    5 min	15 sec      Verify if all sHUB's are operational
    Wait Until Keyword Succeeds	    3 min	15 sec      Verify if AWHQC-1 is enabled
    Wait Until Keyword Succeeds	    1 min	15 sec      Verify if AWHQC-2 is enabled
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if Cell-0 is enabled
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if Cell-1 is enabled

Load Config2 for BTS
    gnb_scf.perform_bts_full_commissioning  scf_file=${config2_GNB_scf_path}
    Wait Until Keyword Succeeds	    5 min	15 sec      Verify if all sHUB's are operational

Load Config2 for ASiR
    ASiR_HUB.perform_asir_commissioning     scf_path=${config2_ASiR_scf_path}
    Wait Until Keyword Succeeds	    5 min	15 sec      Verify if all sHUB's are operational
    Wait Until Keyword Succeeds	    3 min	15 sec      Verify if AWHQC-1 is enabled
    Wait Until Keyword Succeeds	    1 min	15 sec      Verify if AWHQC-2 is enabled
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if Cell-1 is enabled

Enable PoE for AWHQC-1
    ASiR_HUB.perform_asir_recommissioning       delta=${enable_PoE_for_AWHQC_1}
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if AWHQC-1 is enabled

Enable PoE for AWHQC-2
    ASiR_HUB.perform_asir_recommissioning       delta=${enable_PoE_for_AWHQC_2}
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if AWHQC-2 is enabled

Enable PoE for AWHQC-1 (supercell)
    ASiR_HUB.perform_asir_recommissioning       delta=${enable_PoE_for_AWHQC_1_supercell}
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if AWHQC-1 is enabled

Enable PoE for AWHQC-2 (supercell)
    ASiR_HUB.perform_asir_recommissioning       delta=${enable_PoE_for_AWHQC_2_supercell}
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if AWHQC-2 is enabled (supercell)

Disable PoE for AWHQC-1
    ASiR_HUB.perform_asir_recommissioning       delta=${disable_PoE_for_AWHQC_1}
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if AWHQC-1 is disabled

Disable PoE for AWHQC-2
    ASiR_HUB.perform_asir_recommissioning       delta=${disable_PoE_for_AWHQC_2}
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if AWHQC-2 is disabled

Disable PoE for AWHQC-1 (supercell)
    ASiR_HUB.perform_asir_recommissioning       delta=${disable_PoE_for_AWHQC_1_supercell}
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if AWHQC-1 is disabled

Disable PoE for AWHQC-2 (supercell)
    ASiR_HUB.perform_asir_recommissioning       delta=${disable_PoE_for_AWHQC_2_supercell}
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if AWHQC-2 is disabled (supercell)

Disable PoE for AWHQC-1 and AWHQC-2
    Disable PoE for AWHQC-1
    Disable PoE for AWHQC-2

Disable PoE for AWHQC-1 and AWHQC-2 (supercell)
    Disable PoE for AWHQC-1 (supercell)
    Disable PoE for AWHQC-2 (supercell)

Verify if AWHQC-1 is enabled
    @{AWHQC_id}=     Create List   ${1}
    ASiR_HUB.verify_antennas_are_enabled   ant_ids=${AWHQC_id}

Verify if AWHQC-2 is enabled
    @{AWHQC_id}=     Create List   ${3}
    ASiR_HUB.verify_antennas_are_enabled   ant_ids=${AWHQC_id}

Verify if AWHQC-2 is enabled (supercell)
    @{AWHQC_id}=     Create List   ${2}
    ASiR_HUB.verify_antennas_are_enabled   ant_ids=${AWHQC_id}

Verify if AWHQC-1 is disabled
    @{AWHQC_id}=     Create List   ${1}
    ASiR_HUB.verify_antennas_are_disabled   ant_ids=${AWHQC_id}

Verify if AWHQC-2 is disabled
    @{AWHQC_id}=     Create List   ${3}
    ASiR_HUB.verify_antennas_are_disabled   ant_ids=${AWHQC_id}

Verify if AWHQC-2 is disabled (supercell)
    @{AWHQC_id}=     Create List   ${2}
    ASiR_HUB.verify_antennas_are_disabled   ant_ids=${AWHQC_id}

Verify if all sHUB's are operational
    ASiR_HUB.verify_status_of_all_hubmods   expected_statuses=${sHUB_enabled_status}

Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-1
    ${fault_4480_on_AWHQC_1}=   ASiR_helper.verify_if_fault_4480_antmod_not_detected_is_active_on_awhqc   ant_id=1
    Should be True              ${fault_4480_on_AWHQC_1}   msg=Fault 4480 'ANTMOD not detected' is not active on AWHQC-1

Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-2
    ${fault_4480_on_AWHQC_2}=   ASiR_helper.verify_if_fault_4480_antmod_not_detected_is_active_on_awhqc   ant_id=3
    Should be True              ${fault_4480_on_AWHQC_2}   msg=Fault 4480 'ANTMOD not detected' is not active on AWHQC-2

Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-2 (supercell)
    ${fault_4480_on_AWHQC_2}=   ASiR_helper.verify_if_fault_4480_antmod_not_detected_is_active_on_awhqc   ant_id=2
    Should be True              ${fault_4480_on_AWHQC_2}   msg=Fault 4480 'ANTMOD not detected' is not active on AWHQC-2

Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-1
    ${fault_4480_on_AWHQC_1}=   ASiR_helper.verify_if_fault_4480_antmod_not_detected_is_active_on_awhqc   ant_id=1
    Should not be True          ${fault_4480_on_AWHQC_1}    msg=Fault 4480 'ANTMOD not detected' is active on AWHQC-1

Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-2
    ${fault_4480_on_AWHQC_2}=   ASiR_helper.verify_if_fault_4480_antmod_not_detected_is_active_on_awhqc   ant_id=3
    Should not be True          ${fault_4480_on_AWHQC_2}    msg=Fault 4480 'ANTMOD not detected' is active on AWHQC-2

Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-2 (supercell)
    ${fault_4480_on_AWHQC_2}=   ASiR_helper.verify_if_fault_4480_antmod_not_detected_is_active_on_awhqc   ant_id=2
    Should not be True          ${fault_4480_on_AWHQC_2}    msg=Fault 4480 'ANTMOD not detected' is active on AWHQC-2

Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-1 and AWHQC-2
    Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-1
    Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-2

Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-1 and AWHQC-2
    Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-1
    Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-2

Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-1 and AWHQC-2 (supercell)
    Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-1
    Verify if fault 4480 'ANTMOD not detected' is active for AWHQC-2 (supercell)

Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-1 and AWHQC-2 (supercell)
    Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-1
    Verify if fault 4480 'ANTMOD not detected' is NOT active for AWHQC-2 (supercell)

Verify if Cell-0 is enabled
    @{cell_id}=     Create List   ${0}
    ASiR_HUB.verify_status_of_asir_cells    cell_ids=${cell_id}   expected_asir_cell_status=operational

Verify if Cell-1 is enabled
    @{cell_id}=     Create List   ${1}
    ASiR_HUB.verify_status_of_asir_cells    cell_ids=${cell_id}   expected_asir_cell_status=operational

Verify if Cell-0 is disabled
    sleep   5s
    @{cell_id}=     Create List   ${0}
    ASiR_HUB.verify_status_of_asir_cells    cell_ids=${cell_id}   expected_asir_cell_status=failed

Verify if Cell-1 is disabled
    sleep   5s
    @{cell_id}=     Create List   ${1}
    ASiR_HUB.verify_status_of_asir_cells    cell_ids=${cell_id}   expected_asir_cell_status=failed

Wait for Cell-0 to be onair
    Wait Until Keyword Succeeds	    2 min	10 sec      Verify if Cell-0 is enabled

Wait for Cell-1 to be onair
    Wait Until Keyword Succeeds	    2 min	10 sec      Verify if Cell-1 is enabled

Verify if Cell-0 and Cell-1 are disabled
    Verify if Cell-0 is disabled
    Verify if Cell-1 is disabled

Verify if Cell-0 and Cell-1 are enabled
    Verify if Cell-0 is enabled
    Verify if Cell-1 is enabled

Prepare UE for test
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${False}

Perform L3 call on Cell-0
    Block Cell-1
    L3 Call verification
    Unblock Cell-1

Perform L3 call on Cell-1
    Block Cell-0
    L3 Call verification
    Unblock Cell-0

Perform L3 call on Cell-0 (supercell)
    L3 Call verification

L3 Call verification
    Verify L3 Call Data Transfer DL&UL
    ...         duration=${duration}
    ...         tput_dl=${tput_dl}
    ...         tput_ul=${tput_ul}
    ...         deviation_dl=${deviation_dl}
    ...         deviation_ul=${deviation_ul}

Block Cell-0
    gnb_cell.block_cell    cell_id=0
    Verify if Cell-0 is disabled

Block Cell-1
    gnb_cell.block_cell    cell_id=1
    Verify if Cell-1 is disabled

Unblock Cell-0
    gnb_cell.unblock_cell    cell_id=0
    Wait for Cell-0 to be onair

Unblock Cell-1
    gnb_cell.unblock_cell    cell_id=1
    Wait for Cell-1 to be onair

Unblock Cell-0 after test if blocked
    Run Keyword And Ignore Error    Unblock Cell-0

Unblock Cell-1 after test if blocked
    Run Keyword And Ignore Error    Unblock Cell-1
