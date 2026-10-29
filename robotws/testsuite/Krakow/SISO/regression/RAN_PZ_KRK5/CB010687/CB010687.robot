*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010687
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Library      taf.rfrl.utilities.test_config
Library      taf.ue     WITH NAME   ue
Resource     ./local_resources/common_keywords.robot
Resource     testsuite/Krakow/resources/RAN_VRF_KRK5/robot/call_procedure/call_procedure_keywords.robot
Resource     testsuite/Krakow/resources/RAN_VRF_KRK5/robot/snapshot_validation/snapshot_validation_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./local_resources/common_variables.py

Force Tags    CA_VRF_KRK

Suite Setup        Prepare test line
Suite Teardown     Test line teardown

*** Variables ***
@{CellIDs}      NRCELL-0    NRCELL-1    NRCELL-2
...             NRCELL-11   NRCELL-21   NRCELL-31
...             LNCEL-10    LNCEL-20    LNCEL-30
@{SupercellNR}  NRCELL-0
...             NRCELL-11   NRCELL-21   NRCELL-31
...             LNCEL-10    LNCEL-20    LNCEL-30
@{SupercellLTE}      LNCEL-10
${capabilities}      REAL_UE
${hostFPFH1}         fpfh-zb12-46-p04.p04-leg.ska-lab.nsn-rdnet.net
${hostFPFH2}         fpfh-zb12-34-p04.p04-leg.ska-lab.nsn-rdnet.net


*** Test Cases ***
[1][1.0] CB010687_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Setup]    Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Snapshot]
    Verify snapshot
    [Teardown]      Actions after test


[1][1.0] CB010687_General_SiSo_Energy_Efficiency_Features_Activation
    [Setup]    Actions before test
    Recommission    prefix_tag=POWER_SAVING
    gnb_counter.Wait for PM measurements    interval=15min    measurements=0
    pm_verifier.verify_counters    counters=${counters}
    Recommission
    [Teardown]      Actions after test


[1][1.0] CB010687_Manual_SiSo_CALL_L3_data_call
    [Setup]    Actions before test
    ${traffic_matrix1}    Convert To Dictionary    ${TPUT_MATRIX1}
    Call To Selected Cells      cells_list=@{CellIDs}     duration=60s     traffic_matrix=${traffic_matrix1}     ue_capabilities=${capabilities}
    [Teardown]      Actions after test

[1][1.0] CB010687_General_SiSo_NR_TDD_SuperCell_activation_deactivation
    [Setup]    Actions before test
    Load basic commissioning change parameters and verify cells are on air
    ...     delta_file=actSupercell.json
    Load basic commissioning change parameters and verify cells are on air
    ...     delta_file=deactSupercell.json
    [Teardown]      Actions after test

[1][1.0] CB010687_General_SiSo_SuperCell_Subcell_failure_statemangement
    [Setup]    Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Supercell]
    Recommission    prefix_tag=LTE_FDD_supercell
    power off       host=${hostFPFH2}   port=1  alias=FPFH2  model=FPFH
    Sleep    180s
    verify_cell_statuses
    ...     cell_id=10
    ...     availability_status=degraded
    ...     operational_state=enabled
    ...     cell_type=lte
    power off       host=${hostFPFH2}   port=2  alias=FPFH2  model=FPFH
    Sleep    180s
    verify_cell_statuses
    ...     cell_id=10
    ...     availability_status=degraded
    ...     operational_state=enabled
    ...     cell_type=lte
    power off       host=${hostFPFH1}   port=5  alias=FPFH1  model=FPFH
    Sleep    180s
    verify_cell_statuses
    ...     cell_id=10
    ...     availability_status=failed
    ...     operational_state=disabled
    ...     cell_type=lte
    power on        host=${hostFPFH2}   port=1  alias=FPFH2  model=FPFH
    power on        host=${hostFPFH2}   port=2  alias=FPFH2  model=FPFH
    power on        host=${hostFPFH1}   port=5  alias=FPFH1  model=FPFH
    Sleep    180s
    verify_cell_statuses
    ...     cell_id=10
    ...     operational_state=enabled
    ...     cell_type=lte
    Recommission
    [Teardown]      Actions after test
