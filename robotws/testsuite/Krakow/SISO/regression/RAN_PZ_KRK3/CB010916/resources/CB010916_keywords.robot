*** Settings ***
Documentation
...   Resource files for regression testing of feature CB010916 (Antenna port re-mapping)
...   author: Marek Bodziony, Piotr Suski
...   contact: marek.bodziony@nokia.com, piotr.suski@nokia.com

Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning          WITH NAME   gnb_scf
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations       WITH NAME   gnb_cell
Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations     WITH NAME   ASiR_HUB
Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.CB010916.resources.automation_helper.BtsHelper     WITH NAME   BTS_helper
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/resources/robot/L3Call.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   deltas/asir_deltas.py

*** Variables ***
${capabilities}     REAL_UE
${tput_dl}          100 MBits/sec
${tput_ul}          50 MBits/sec
${tput_dl_DMIMO}    100 MBits/sec
${tput_ul_DMIMO}    20 MBits/sec
${duration}         20s
${deviation_dl}     30%
${deviation_ul}     30%

${change_qRxLevMin_for_UE_attach_on_Config1}         ${CURDIR}/deltas/change_qRxLevMin_for_UE_attach_on_Config1.json
${change_qRxLevMin_for_UE_attach_on_Config2}         ${CURDIR}/deltas/change_qRxLevMin_for_UE_attach_on_Config2.json
${change_qRxLevMin_for_UE_attach_on_Config3}         ${CURDIR}/deltas/change_qRxLevMin_for_UE_attach_on_Config3.json

${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${false}
${ENABLE_RACH_OBSERVER}                 ${false}
${SEND_CONFIGURATION_VALIDATION_EMAIL}  ${False}

*** Keywords ***
Load Config${id} for BTS and ASiR and wait for onair
    Set SCF path for current SW release
    Load Config${id} for BTS
    Load Config${id} for ASiR

Set SCF path for current SW release
    ${release}       BTS_helper.get_current_sw_release
    Set Test Variable   ${config1_GNB_scf_path}         commissionings/Krakow/7_7_UTE5GCLOUDT4SK149/${release}/SCF_gnb_config1.xml
    Set Test Variable   ${config1_ASiR_scf_path}        commissionings/Krakow/7_7_UTE5GCLOUDT4SK149/${release}/SCF_asir_config1.xml
    Set Test Variable   ${config2_GNB_scf_path}         commissionings/Krakow/7_7_UTE5GCLOUDT4SK149/${release}/SCF_gnb_config2.xml
    Set Test Variable   ${config2_ASiR_scf_path}        commissionings/Krakow/7_7_UTE5GCLOUDT4SK149/${release}/SCF_asir_config2.xml
    Set Test Variable   ${config3_GNB_scf_path}         commissionings/Krakow/7_7_UTE5GCLOUDT4SK149/${release}/SCF_gnb_config3.xml
    Set Test Variable   ${config3_ASiR_scf_path}        commissionings/Krakow/7_7_UTE5GCLOUDT4SK149/${release}/SCF_asir_config3.xml

Load Config${id} for BTS
    gnb_scf.perform_bts_full_commissioning  scf_file=${config${id}_GNB_scf_path}
    Wait Until Keyword Succeeds	    5 min	15 sec      Verify if all sHUB's are operational

Load Config${id} for ASiR
    Run keyword IF     ${id}==1       Load Config1 for ASiR
    ...    ELSE IF     ${id}==2       Load Config2 for ASiR
    ...    ELSE IF     ${id}==3       Load Config3 for ASiR

Load Config1 for ASiR
    ASiR_HUB.perform_asir_commissioning     scf_path=${config1_ASiR_scf_path}
    Wait Until Keyword Succeeds	    5 min	15 sec      Verify if all sHUB's are operational
    Wait Until Keyword Succeeds	    3 min	15 sec      Verify if AWHENHD-1 is enabled
    Wait Until Keyword Succeeds	    1 min	15 sec      Verify if AWHENHD-2 is enabled
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if Cell-0 is enabled
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if Cell-1 is enabled

Load Config2 for ASiR
    ASiR_HUB.perform_asir_commissioning     scf_path=${config2_ASiR_scf_path}
    Wait Until Keyword Succeeds	    5 min	15 sec      Verify if all sHUB's are operational
    Wait Until Keyword Succeeds	    3 min	15 sec      Verify if AWHENHD-1 is enabled
    Wait Until Keyword Succeeds	    1 min	15 sec      Verify if AWHENHD-2 is enabled
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if Cell-1 is enabled

Load Config3 for ASiR
    ASiR_HUB.perform_asir_commissioning     scf_path=${config3_ASiR_scf_path}
    Wait Until Keyword Succeeds	    5 min	15 sec      Verify if all sHUB's are operational
    Wait Until Keyword Succeeds	    3 min	15 sec      Verify if AHFII-1 is enabled
    Wait Until Keyword Succeeds	    1 min	15 sec      Verify if AHFII-2 is enabled
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if Cell-0 is enabled

Verify if all sHUB's are operational
    ASiR_HUB.verify_status_of_all_hubmods   expected_statuses=${sHUB_enabled_status}

Verify if AWHENHD-${id} is enabled
    @{AWHENHD_id}=     Create List   ${${id}}
    ASiR_HUB.verify_antennas_are_enabled   ant_ids=${AWHENHD_id}

Verify if AHFII-${id} is enabled
    @{AHFII_id}=     Create List   ${${id}}
    ASiR_HUB.verify_antennas_are_enabled   ant_ids=${AHFII_id}

Block Cell-${id}
    gnb_cell.block_cell    cell_id=${id}
    Verify if Cell-${id} is disabled

Unblock Cell-${id}
    gnb_cell.unblock_cell    cell_id=${id}
    Wait for Cell-${id} to be onair

Enable antenna port mapping [${port_mapping}] on Cell-${id}
    ${detla_port_mapping}=    BTS_helper.prepare_delta_for_ant_mapping      cell_id=${id}   port_mapping=${port_mapping}
    gnb_scf.perform_bts_delta_json_commissioning    delta_file=${detla_port_mapping}    bts_id=0    du_id=0
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${120}

Enable antenna port mapping [${port_mapping}] on Supercell
    ${detla_port_mapping}=    BTS_helper.prepare_delta_for_ant_mapping      port_mapping=${port_mapping}    supercell=${true}
    gnb_scf.perform_bts_delta_json_commissioning    delta_file=${detla_port_mapping}    bts_id=0    du_id=0
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${120}

Disable antenna port mapping on Cell-${id}
    ${detla_port_mapping}=    BTS_helper.prepare_delta_for_ant_mapping   cell_id=${id}  enable_port_mapping=${false}
    gnb_scf.perform_bts_delta_json_commissioning    delta_file=${detla_port_mapping}    bts_id=0    du_id=0
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${120}

Disable antenna port mapping on Supercell
    ${detla_port_mapping}=    BTS_helper.prepare_delta_for_ant_mapping   enable_port_mapping=${false}    supercell=${true}
    gnb_scf.perform_bts_delta_json_commissioning    delta_file=${detla_port_mapping}    bts_id=0    du_id=0
    ...     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${120}

Enable antenna port re-mapping [${port_mapping}] on Cell-${id} and verify cell lock/unlock
    Enable antenna port mapping [${port_mapping}] on Cell-${id}
    Verify if Cell-${id} is disabled
    Wait for Cell-${id} to be onair

Enable antenna port re-mapping [${port_mapping}] on Supercell and verify Supercell lock/unlock
    Enable antenna port mapping [${port_mapping}] on Supercell
    Verify if Cell-1 is disabled
    Wait for Cell-1 to be onair

Disable antenna port re-mapping on Cell-${id} and verify cell lock/unlock
    Disable antenna port mapping on Cell-${id}
    Verify if Cell-${id} is disabled
    Wait for Cell-${id} to be onair

Disable antenna port re-mapping on Supercell and verify Supercell lock/unlock
    Disable antenna port mapping on Supercell
    Verify if Cell-1 is disabled
    Wait for Cell-1 to be onair

Modify antenna port re-mapping [${port_mapping}] on Cell-${id} and verify cell lock/unlock
    Enable antenna port re-mapping [${port_mapping}] on Cell-${id} and verify cell lock/unlock

Modify antenna port re-mapping [${port_mapping}] on Supercell and verify Supercell lock/unlock
    Enable antenna port re-mapping [${port_mapping}] on Supercell and verify Supercell lock/unlock

Verify if Cell-${id} is enabled
    @{cell_id}=     Create List   ${${id}}
    ASiR_HUB.verify_status_of_asir_cells    cell_ids=${cell_id}   expected_asir_cell_status=operational

Verify if Cell-${id} is disabled
    sleep   5s
    @{cell_id}=     Create List   ${${id}}
    ASiR_HUB.verify_status_of_asir_cells    cell_ids=${cell_id}   expected_asir_cell_status=failed

Wait for Cell-${id} to be onair
    Wait Until Keyword Succeeds	    30 sec	5 sec      Verify if Cell-${id} is enabled

Prepare UE for test
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${False}

Perform L3 call on Cell-${id}
    ${cell_to_block}=  BTS_helper.get_cell_to_block_for_L3call   cell_for_l3call=${id}
    Block Cell-${cell_to_block}
    L3 Call verification
    Unblock Cell-${cell_to_block}

Perform L3 call on Cell-1 (supercell)
    L3 Call verification

Perform L3 call on Cell-0 (D-MIMO)
    L3 Call verification DMIMO

L3 Call verification
    Verify L3 Call Data Transfer DL&UL
    ...         duration=${duration}
    ...         tput_dl=${tput_dl}
    ...         tput_ul=${tput_ul}
    ...         deviation_dl=${deviation_dl}
    ...         deviation_ul=${deviation_ul}

L3 Call verification DMIMO
    Verify L3 Call Data Transfer DL&UL
    ...         duration=${duration}
    ...         tput_dl=${tput_dl_DMIMO}
    ...         tput_ul=${tput_ul_DMIMO}
    ...         deviation_dl=${deviation_dl}
    ...         deviation_ul=${deviation_ul}
TC03 test setup
    Run keywords
    ...         Load Config1 for BTS and ASiR and wait for onair
    ...         Enable antenna port re-mapping [1,2,0,3] on Cell-0 and verify cell lock/unlock
    ...         Enable antenna port re-mapping [3,2,0,1] on Cell-1 and verify cell lock/unlock
    ...         Common Preconditions with watching alarms
    ...         Allow alarm 'Cell blocked' on BTS during test
    ...         Change param 'qRxLevMin' to '-50' for UE attach on Config1
    ...         Prepare UE for test
    ...         Start Collecting gNB Syslog

TC03 test teardown
    Run keywords
    ...         After test unblock Cell-0 if blocked
    ...         After test unblock Cell-1 if blocked
    ...         Disallow alarm 'Cell blocked' on BTS after test
    ...         Disable antenna port re-mapping on Cell-0 and verify cell lock/unlock
    ...         Disable antenna port re-mapping on Cell-1 and verify cell lock/unlock
    ...         Common Postconditions with watching alarms

TC06 test setup
    Run keywords
    ...         Load Config2 for BTS and ASiR and wait for onair
    ...         Enable antenna port re-mapping [0,2,1,3] on Supercell and verify Supercell lock/unlock
    ...         Common Preconditions with watching alarms
    ...         Change param 'qRxLevMin' to '-50' for UE attach on Config2
    ...         Prepare UE for test
    ...         Start Collecting gNB Syslog

TC06 test teardown
    Run keywords
    ...         Disable antenna port re-mapping on Supercell and verify Supercell lock/unlock
    ...         Common Postconditions with watching alarms

TC07 test setup
    Run keywords
    ...         Load Config3 for BTS and ASiR and wait for onair
    ...         Common Preconditions with watching alarms
    ...         Change param 'qRxLevMin' to '-50' for UE attach on Config3
    ...         Prepare UE for test
    ...         Start Collecting gNB Syslog

TC07 test teardown
    Run keywords
    ...         Common Postconditions with watching alarms

Allow alarm 'Cell blocked' on BTS during test
    gnb_alarm.Allow Alarm         Cell blocked

Disallow alarm 'Cell blocked' on BTS after test
    gnb_alarm.Disallow Alarm      Cell blocked

After test unblock Cell-${id} if blocked
    Run Keyword And Ignore Error    Unblock Cell-${id}

Change param 'qRxLevMin' to '-50' for UE attach on Config${id}
    gnb_scf.perform_bts_delta_json_commissioning    delta_file=${change_qRxLevMin_for_UE_attach_on_Config${id}}
    ...     bts_id=0  du_id=0   skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Verify correct port mapping [${port_mapping}] on CPRI cell in SYSLOG
    ${output}=  Get matching string from syslog     string_to_find=SBbbAxcConfiguration2     syslog_dir=/tmp/btslog2
    BTS_helper.check_correct_port_mapping_for_cpri  syslog=${output}    port_mapping=${port_mapping}

Verify correct port mapping [${port_mapping}] on eCPRI cell in SYSLOG
    ${output}=  Get matching string from syslog     string_to_find=dlSubcellType     syslog_dir=/tmp/btslog2
    BTS_helper.check_correct_port_mapping_for_ecpri  syslog=${output}    port_mapping=${port_mapping}
