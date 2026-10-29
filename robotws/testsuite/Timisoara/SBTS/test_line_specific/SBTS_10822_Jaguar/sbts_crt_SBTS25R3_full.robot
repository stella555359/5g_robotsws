*** Settings ***
Documentation     TCs Jaguar
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLWG_10822_lASIL_1ABIP_1ABIO_1ABIA_2AHEH_2AHEGB    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Reset_during_the_ongoing_snapshot_procedure.robot
Resource          ../../LOGS/LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10822_Jaguar/commissioning/SCF_01_TRUNK.xml

${COMMISSIONING_PATH_actEcpri72e}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10822_Jaguar/commissioning/SCF_01_SBTS25R3_actEcpri72e.xml

${NETACT_LAB}    &{srnclab1044}

*** Test Cases ***
[1]CB009514_KA_CB006483_5G_C_Reset_during_the_ongoing_snapshot_procedure
    [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}    ${CURDIR}/commissioning/SCF_01_SBTS25R3_actEcpri72e.xml
    ...    AND    LOGS__Reset_during_the_ongoing_snapshot_procedure.TC Setup
    ...    AND    Modify Vendor File And Do Full Commissioning    scf_file=${COMMISSIONING_PATH_actEcpri72e}
    ...    AND    Modify Resource Search Order    LOGS__Reset_during_the_ongoing_snapshot_procedure
    ...    AND    Set Library Search Order    LOGS__Reset_during_the_ongoing_snapshot_procedure
    [Timeout]    14400
    TC__LOGS__Reset_during_the_ongoing_snapshot_procedure
    [Teardown]    Run Keywords    Revert Vendor File And Do Full Commissioning
    ...    AND    LOGS__Reset_during_the_ongoing_snapshot_procedure.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB009514_KA_parity_legacy_black_box_5_function_of_CB006622
    [Setup]    Run Keywords    Set Test Variable    ${COMMISSIONING_PATH}    ${CURDIR}/commissioning/SCF_01_SBTS25R3_actEcpri72e.xml
    ...    AND    LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622.TC Setup
    ...    AND    Modify Vendor File And Do Full Commissioning    scf_file=${COMMISSIONING_PATH_actEcpri72e}
    ...    AND    Set Library Search Order    LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622
    ...    AND    Modify Resource Search Order    LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622
    [Timeout]    14400
    TC__LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622
    [Teardown]    Run Keywords    Revert Vendor File And Do Full Commissioning
    ...    AND    LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
