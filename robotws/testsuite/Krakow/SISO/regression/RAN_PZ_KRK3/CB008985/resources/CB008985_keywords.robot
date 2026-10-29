*** Settings ***
Documentation
...    Maintainer: szymon.laba@nokia.com
...    Team in charge: MN RAN Pz Krk 3 SG

Library     ute_ue
Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning          WITH NAME   gnb_scf
Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations     WITH NAME   ASiR_HUB
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    asir_deltas.py

*** Variables ***

@{CUSTOM_ALARMS}=       8000  4592  7107  7523

@{allowed_alarms}=   Ethernet port security is disabled   SSH enabled   R&D Service Port enabled
               ...   Service account root access is enabled   Service account root access is enabled   LMP connectivity detected
               ...   Failure in connection between BTS and 3rd party tool    Cell Activation timeout at gNB-DU    BTS Reset Cause
               ...   Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability    LMP access via port 443

${ASIR_ALLOWED_ALARMS}=    ${EMPTY}

${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${reboot_ue}              False
${size_packet_dl}         1436B
${protocol}               udp
${parallel_streams_ul}    2
${parallel_streams_dl}    2

${ue_alias}			UE_1

${capabilities}     REAL_UE
${tput_dl}          150 MBits/sec
${tput_ul}          45 MBits/sec
${duration}         5s
${deviation}        50%
${deviation_dl}     50%
${deviation_ul}     50%


*** Keywords ***

Load Config1 for BTS and ASiR and wait for onair
    Set SCF path for current SW release
    Load Config1 for BTS
    Load Config1 for ASiR


Set SCF path for current SW release
    Set Test Variable   ${config1_GNB_scf_path}         commissionings/Krakow/7_7_UTE5GCLOUDT4SK079/Trunk/GNB.xml
    Set Test Variable   ${config1_ASiR_scf_path}        commissionings/Krakow/7_7_UTE5GCLOUDT4SK079/Trunk/GNB_ASIR.xml

Load Config1 for BTS
    gnb_scf.perform_bts_full_commissioning  scf_file=${config1_GNB_scf_path}
    Wait Until Keyword Succeeds	    5 min	15 sec      Verify if all sHUB's are operational


Load Config1 for ASiR
    ASiR_HUB.perform_asir_commissioning     scf_path=${config1_ASiR_scf_path}
    Wait Until Keyword Succeeds	    5 min	15 sec      Verify if all sHUB's are operational
    Wait Until Keyword Succeeds	    2 min	15 sec      Verify if Cell-0 is enabled


Verify if all sHUB's are operational
    ASiR_HUB.verify_status_of_all_hubmods    expected_statuses=${sHUB_enabled_status}

Verify if Cell-0 is enabled
    @{cell_id}=     Create List   ${0}
    ASiR_HUB.verify_status_of_asir_cells    cell_ids=${cell_id}   expected_asir_cell_status=operational


Prepare UE for test
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${False}

Perform L3 call on Cell-0 (supercell)
    L3 Call verification

L3 Call verification
    Verify L3 Call Data Transfer DL&UL
    ...		    alias=${ue_alias}
    ...         duration=${duration}
    ...         tput_dl=${tput_dl}
    ...         tput_ul=${tput_ul}
    ...		    interval=1
    ...         deviation=${deviation}

Prepare Ue
    ute_ue.Require Ue    ue_alias=${ue_alias}    capabilities=${capabilities}
    ute_ue.Detach Ue    ${ue_alias}
    Sleep    1s
    ute_ue.Attach Ue    ${ue_alias}
    Sleep    3s
    ute_ue.Log Ue Info    ${ue_alias}    ALL
