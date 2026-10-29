*** Settings ***
Documentation  Tests for Fiat
Force Tags       QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_NL_10824_1ASIL_1ABIP_1ABIQ_1AVQL_1AHBCC    SBTS00
Library          XML  use_lxml=True
Resource         taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource         ../../LOGS/LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs.robot
Resource         ../../LOGS/LOGS__Reset_during_the_ongoing_snapshot_procedure.robot
Resource         ../../LOGS/LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_with_delay.robot
Resource         ../../LOGS/LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit.robot
Resource         ../../LOGS/LOGS__Snapshot_BBOX5_File_Check.robot
Resource         ../../LOGS/LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622.robot
Resource         ../../LOGS/LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_BBMOD.robot
Resource         ../../LOGS/LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD.robot
Resource         ../../LOGS/LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD.robot
Resource         ../../LOGS/LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10824_Fiat/commissioning/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab1015}

*** Test Cases ***
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
    ...    AND    Modify Vendor File And Do Full Commissioning
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
    ...    AND    Modify Vendor File And Do Full Commissioning
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
    ...    AND    Modify Vendor File And Do Full Commissioning
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
    ...    AND    Modify Vendor File And Do Full Commissioning
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
    ...    AND    Modify Vendor File And Do Full Commissioning
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
    TC__LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_BBMOD    FSP_ID=fsp-2-5a
    [Teardown]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_BBMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated_CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD
    [Setup]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD
    ...    AND    Set Library Search Order    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD
    [Timeout]    14400
    TC__LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD
    [Teardown]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated_CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD
    [Setup]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD
    ...    AND    Set Library Search Order    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD
    [Timeout]    14400
    TC__LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD    FSP_ID=fsp-2-5a
    [Teardown]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated_CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD
    [Setup]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD
    ...    AND    Set Library Search Order    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD
    [Timeout]    14400
    TC__LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD
    [Teardown]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
