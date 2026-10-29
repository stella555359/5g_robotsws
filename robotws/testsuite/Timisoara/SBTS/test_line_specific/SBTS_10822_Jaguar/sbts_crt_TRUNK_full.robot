*** Settings ***
Documentation     TCs Jaguar
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLWG_10822_lASIL_1ABIP_1ABIO_1ABIA_2AHEH_2AHEGB    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Blackbox_log_creation.robot
Resource          ../../LOGS/LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S.robot
Resource          ../../LOGS/LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.robot
Resource          ../../LOGS/LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD.robot
Resource          ../../LOGS/LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs.robot
Resource          ../../LOGS/LOGS__Reset_during_the_ongoing_snapshot_procedure.robot
Resource          ../../LOGS/LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_with_delay.robot
Resource          ../../LOGS/LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit.robot
Resource          ../../LOGS/LOGS__Snapshot_BBOX5_File_Check.robot
Resource          ../../LOGS/LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622.robot
Resource          ../../LOGS/LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_BBMOD.robot
Resource          ../../LOGS/LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD.robot
Resource          ../../LOGS/LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD.robot
Resource          ../../LOGS/LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD.robot
Resource          ../../LOGS/LOGS__CB008064_17_ASIL_check_Alarm_when_TCE_Connect_failed.robot
Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10822_Jaguar/commissioning/SCF_01_TRUNK.xml

${COMMISSIONING_PATH_actEcpri72e}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10822_Jaguar/commissioning/SCF_01_TRUNK_actEcpri72e.xml

${NETACT_LAB}    &{srnclab1047}

*** Test Cases ***
[1]Automated__LOGS__Blackbox_log_creation
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_EXTRACTED}    ${FALSE}
    ...    AND    Set Test Variable    ${RESET_TYPE}    power_reset
    ...    AND    Set Test Variable    ${RESET_DATE}
    ...    AND    Set Test Variable    ${BLACKBOX_INFO}
    ...    AND    Set Test Variable    ${MATCHES}
    ...    AND    Set Test Variable    ${check_blackbox_date}
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    LOGS__Blackbox_log_creation.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Blackbox_log_creation
    ...    AND    Set Library Search Order    LOGS__Blackbox_log_creation
    [Timeout]    14400
    TC__LOGS__BlackBox
    [Teardown]    Run Keywords    LOGS__Blackbox_log_creation.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S
    [Timeout]    14400
    TC__LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S
    [Teardown]    Run Keywords    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Setup]    Run Keywords    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    ...    AND    Set Library Search Order    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Timeout]    14400
    TC__LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Teardown]    Run Keywords    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD
    [Tags]      gm
    [Setup]    Run Keywords    Set Test Variable    ${DSP_ID}    0x1431
    ...    AND    Set Test Variable    ${SITE_RESET}    False
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    Set Test Variable    ${FAULT_TIMEOUT}    15
    ...    AND    Set Test Variable    ${VERIFICATION_TIMEOUT}    3
    ...    AND    Set Test Variable    ${MEMDUMP_PATTERN}    (\\d{4})\\w+MEMDUMP\\.bin\\.xz$
    ...    AND    Set Test Variable    ${DSP_MEMDUMPER_PATTERN}    memdumper_{}.+\\.log\\.xz$
    ...    AND    Set Test Variable    ${DSP_RUNTIME_PATTERN}    [1-2]011_crash_{}00_RT\\.log\\.zip$
    ...    AND    Set Test Variable    ${DSP_MEMDUMP_PATTERN}    {}00\\w+MEMDUMP\\.bin.*
    ...    AND    Set Test Variable    ${SRIO_DIO_INTERFACE_PATERN}    riomemfs-logdump
    ...    AND    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD
    ...    AND    Set Library Search Order    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD
    [Timeout]    14400
    TC__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD
    [Teardown]    Run Keywords    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]13_CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    [Setup]    Run Keywords    LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    ...    AND    Set Library Search Order    LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    [Timeout]    14400
    TC__LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    [Teardown]    Run Keywords    LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB009514_KA_CB006483_5G_C_Reset_during_the_ongoing_snapshot_procedure
    [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}    ${CURDIR}/commissioning/SCF_01_TRUNK_actEcpri72e.xml
    ...    AND    LOGS__Reset_during_the_ongoing_snapshot_procedure.TC Setup
    ...    AND    Modify Vendor File And Do Full Commissioning    scf_file=${COMMISSIONING_PATH_actEcpri72e}
    ...    AND    Modify Resource Search Order    LOGS__Reset_during_the_ongoing_snapshot_procedure
    ...    AND    Set Library Search Order    LOGS__Reset_during_the_ongoing_snapshot_procedure
    [Timeout]    14400
    TC__LOGS__Reset_during_the_ongoing_snapshot_procedure
    [Teardown]    Run Keywords    Revert Vendor File And Do Full Commissioning
    ...    AND    LOGS__Reset_during_the_ongoing_snapshot_procedure.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB009514_KA_CB006483_5G_C_Parameter_snapshotUploadDelayForFault6450
    [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}    ${CURDIR}/commissioning/SCF_01_TRUNK_actEcpri72e.xml
    ...    AND    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_with_delay.TC Setup
    ...    AND    Modify Vendor File And Do Full Commissioning    scf_file=${COMMISSIONING_PATH_actEcpri72e}
    ...    AND    Modify Resource Search Order    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_with_delay
    ...    AND    Set Library Search Order    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_with_delay
    [Timeout]    14400
    TC__LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_with_delay
    [Teardown]    Run Keywords    Revert Vendor File And Do Full Commissioning
    ...    AND    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_with_delay.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB009514_KA_CB006483_5G_D_Max_number_of_snapshots_per_day_exceeded_the_max_limit
    [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}    ${CURDIR}/commissioning/SCF_01_TRUNK_actEcpri72e.xml
    ...    AND    LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit.TC Setup
    ...    AND    Modify Vendor File And Do Full Commissioning    scf_file=${COMMISSIONING_PATH_actEcpri72e}
    ...    AND    Modify Resource Search Order    LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit
    ...    AND    Set Library Search Order    LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit
    [Timeout]    14400
    TC__LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit
    [Teardown]    Run Keywords    Revert Vendor File And Do Full Commissioning
    ...    AND    LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB009514_KA_CB006622_Snapshot_BBOX5_File_Check
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    2400
    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}    ${CURDIR}/commissioning/SCF_01_TRUNK_actEcpri72e.xml
    ...    AND    LOGS__Snapshot_BBOX5_File_Check.TC Setup
    ...    AND    Modify Vendor File And Do Full Commissioning    scf_file=${COMMISSIONING_PATH_actEcpri72e}
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_BBOX5_File_Check
    ...    AND    Set Library Search Order    LOGS__Snapshot_BBOX5_File_Check
    [Timeout]    14400
    TC_LOGS__Snapshot_BBOX5_File_Check
    [Teardown]    Run Keywords    Revert Vendor File And Do Full Commissioning
    ...    AND    LOGS__Snapshot_BBOX5_File_Check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB009514_KA_parity_legacy_black_box_5_function_of_CB006622
    [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}    ${CURDIR}/commissioning/SCF_01_TRUNK_actEcpri72e.xml
    ...    AND    LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622.TC Setup
    ...    AND    Modify Vendor File And Do Full Commissioning    scf_file=${COMMISSIONING_PATH_actEcpri72e}
    ...    AND    Set Library Search Order    LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622
    ...    AND    Modify Resource Search Order    LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622
    [Timeout]    14400
    TC__LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622
    [Teardown]    Run Keywords    Revert Vendor File And Do Full Commissioning
    ...    AND    LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated_CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_BBMOD
    [Setup]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_BBMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_BBMOD
    ...    AND    Set Library Search Order    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_BBMOD
    [Timeout]    14400
    TC__LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_BBMOD    FSP_ID=fsp-1-1a    board_pos=1    SMOD_side=1
    [Teardown]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_BBMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated_CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD
    [Setup]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD
    ...    AND    Set Library Search Order    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD
    [Timeout]    14400
    TC__LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD    SMOD_side=1
    [Teardown]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated_CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD
    [Setup]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD
    ...    AND    Set Library Search Order    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD
    [Timeout]    14400
    TC__LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD    FSP_ID=fsp-1-1a    board_pos=1    SMOD_side=1
    [Teardown]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated_CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD
    [Setup]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD
    ...    AND    Set Library Search Order    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD
    [Timeout]    14400
    TC__LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD    SMOD_side=1
    [Teardown]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB008064_17_ASIL_check_Alarm_when_TCE_Connect_failed
    [Setup]    Run Keywords    LOGS__CB008064_17_ASIL_check_Alarm_when_TCE_Connect_failed.TC Setup
    ...    AND    Modify Resource Search Order    CB008064_17_ASIL_check_Alarm_when_TCE_Connect_failed
    ...    AND    Set Library Search Order    LOGS__CB008064_17_ASIL_check_Alarm_when_TCE_Connect_failed
    [Timeout]    14400
    TC__LOGS__CB008064_17_ASIL_check_Alarm_when_TCE_Connect_failed
    [Teardown]    Run Keywords    LOGS__CB008064_17_ASIL_check_Alarm_when_TCE_Connect_failed.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
