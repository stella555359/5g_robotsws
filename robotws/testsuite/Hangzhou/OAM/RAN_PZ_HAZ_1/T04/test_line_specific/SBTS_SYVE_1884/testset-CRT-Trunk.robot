*** Settings ***
Documentation       Test suite for SBTS1884
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout      2h
Variables         My_Variables.py
Variables         ../Variables/NetActs.py
Resource          ../../test_resources/CM/CM__CB009939-A_001_003_BTS_Startup_When_Peer_BTS_Is_Existing.robot
Resource          ../../test_resources/CM/CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset.robot
Resource          ../../test_resources/CM/CM__CB009939-A_005_Configure_BTS_Redundancyrole_As_Standby_Without_Site_Reset.robot
Resource          ../../test_resources/CM/CM__CB009939-A_007_Configure_BTS_Redundancyrole_As_Active_With_Site_Reset.robot
Resource          ../../test_resources/CM/CM__CB009939-A_008_Configure_BTS_Redundancyrole_As_Active_Without_Site_Reset.robot
Resource          ../../test_resources/CM/CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy.robot
Resource          ../../test_resources/CM/CM__CB009939-A_012_Forced_Active_BTS_Startup_When_Peer_BTS_Is_Existing.robot
Resource          ../../test_resources/CM/CM__CB009939-D_001_Setup_OAM_To_OAM_Link_Between_Active_And_Standby_BTS.robot
Resource          ../../test_resources/CM/CM__CB009939-D_003_Verify_Fault4780_With_Different_Additional_Info.robot
Resource          ../../test_resources/CM/CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met.robot
Resource
...    ../../test_resources/CM/CM__CB009939-D_005_CM_Trigger_Automatic_Switchover_When_priorityLteCellsList_Or_priorityNrCellsList_Is_Met.robot
Resource          ../../test_resources/CM/CM__CB009939-D_007_Check_Automatic_Switchover_After_BTS_Update_To_Active_Role.robot
Resource          ../../test_resources/CM/CM__CB009939-D_008_Check_Automatic_Switchover_After_Peer_BTS_Update_To_Standby_Role.robot

*** Variables ***
${SRNCLAB}        SRNCLAB1028    # Netact info defined in NetActs.py under Variables folder
${NETACT}         &{${SRNCLAB}}
${SCF_ID}         01
#${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py

*** Test Cases ***
CM__CB009939-A_001_003_BTS_Startup_When_Peer_BTS_Is_Existing
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33053    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CB009939-A-B1_001_CM_Standby BTS startup when peer BTS is existing
    ...    AND    Set Test Variable    ${qc_instance_id}    33053
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.106.245.37
    ...    AND    Modify Resource Search Order    CM__CB009939-A_001_003_BTS_Startup_When_Peer_BTS_Is_Existing
    ...    AND    Set Library Search Order    CM__CB009939-A_001_003_BTS_Startup_When_Peer_BTS_Is_Existing
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-A_001_003_BTS_Startup_When_Peer_BTS_Is_Existing
    [Teardown]    Run Keywords    CM__CB009939-A_001_003_BTS_Startup_When_Peer_BTS_Is_Existing.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33046    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB009939-A-B3_004_CM_Configure BTS redundancyrole as standby with site reset
    ...    AND    Set Test Variable    ${qc_instance_id}    33046
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.106.245.37
    ...    AND    Set Test Variable    ${MRBTS_ID_1}    1883
    ...    AND    Set Test Variable    ${MRBTS_ID_2}    1884
    ...    AND    Modify Resource Search Order    CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset
    ...    AND    Set Library Search Order    CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset
    [Teardown]    Run Keywords    CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-A_005_Configure_BTS_Redundancyrole_As_Standby_Without_Site_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33046    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB009939-A-B3_005_CM_Configure BTS redundancyrole as standby without site reset
    ...    AND    Set Test Variable    ${qc_instance_id}    33046
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.106.245.37
    ...    AND    Set Test Variable    ${MRBTS_ID_1}    1883
    ...    AND    Set Test Variable    ${MRBTS_ID_2}    1884
    ...    AND    Modify Resource Search Order    CM__CB009939-A_005_Configure_BTS_Redundancyrole_As_Standby_Without_Site_Reset
    ...    AND    Set Library Search Order    CM__CB009939-A_005_Configure_BTS_Redundancyrole_As_Standby_Without_Site_Reset
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-A_005_Configure_BTS_Redundancyrole_As_Standby_Without_Site_Reset
    [Teardown]    Run Keywords    CM__CB009939-A_005_Configure_BTS_Redundancyrole_As_Standby_Without_Site_Reset.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-A_007_Configure_BTS_Redundancyrole_As_Active_With_Site_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33050    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB009939-A-B4_007_CM_Configure BTS redundancyrole as active with site reset
    ...    AND    Set Test Variable    ${qc_instance_id}    33050
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.106.245.37
    ...    AND    Set Test Variable    ${MRBTS_ID_1}    1883
    ...    AND    Set Test Variable    ${MRBTS_ID_2}    1884
    ...    AND    Modify Resource Search Order    CM__CB009939-A_007_Configure_BTS_Redundancyrole_As_Active_With_Site_Reset
    ...    AND    Set Library Search Order    CM__CB009939-A_007_Configure_BTS_Redundancyrole_As_Active_With_Site_Reset
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-A_007_Configure_BTS_Redundancyrole_As_Active_With_Site_Reset
    [Teardown]    Run Keywords    CM__CB009939-A_007_Configure_BTS_Redundancyrole_As_Active_With_Site_Reset.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-A_008_Configure_BTS_Redundancyrole_As_Active_Without_Site_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33051    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB009939-A-B4_008_CM_Configure BTS redundancyrole as active without site reset
    ...    AND    Set Test Variable    ${qc_instance_id}    33051
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.106.245.37
    ...    AND    Set Test Variable    ${MRBTS_ID_1}    1883
    ...    AND    Set Test Variable    ${MRBTS_ID_2}    1884
    ...    AND    Modify Resource Search Order    CM__CB009939-A_008_Configure_BTS_Redundancyrole_As_Active_Without_Site_Reset
    ...    AND    Set Library Search Order    CM__CB009939-A_008_Configure_BTS_Redundancyrole_As_Active_Without_Site_Reset
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-A_008_Configure_BTS_Redundancyrole_As_Active_Without_Site_Reset
    [Teardown]    Run Keywords    CM__CB009939-A_008_Configure_BTS_Redundancyrole_As_Active_Without_Site_Reset.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33052    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
	...    [1.0] RAN_SyVe_CB009939-A-B5_009_CM_Controlled switchover manually when BTS1 is standby and BTS2 is active
    ...    AND    Set Test Variable    ${qc_instance_id}    33052
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.106.245.37
    ...    AND    Modify Resource Search Order    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    ...    AND    Set Library Search Order    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    1.5h
    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    [Teardown]    Run Keywords    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-A_012_Forced_Active_BTS_Startup_When_Peer_BTS_Is_Existing
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33049    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
	...    [1.0] RAN_SyVe_CB009939-A-B8_012_CM_Forced active BTS startup when peer BTS is existing
    ...    AND    Set Test Variable    ${qc_instance_id}    33049
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.106.245.37
    ...    AND    Modify Resource Search Order    CM__CB009939-A_012_Forced_Active_BTS_Startup_When_Peer_BTS_Is_Existing
    ...    AND    Set Library Search Order    CM__CB009939-A_012_Forced_Active_BTS_Startup_When_Peer_BTS_Is_Existing
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-A_012_Forced_Active_BTS_Startup_When_Peer_BTS_Is_Existing
    [Teardown]    Run Keywords    CM__CB009939-A_012_Forced_Active_BTS_Startup_When_Peer_BTS_Is_Existing.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-D_001_Setup_OAM_To_OAM_Link_Between_Active_And_Standby_BTS
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_50491    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
	...    [1.0] RAN_SyVe_CB009939-D_001_CM_Setup OAM to OAM link between active and standby BTS
    ...    AND    Set Test Variable    ${qc_instance_id}    50491
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.106.245.37
    ...    AND    Set Test Variable    ${NonMplane_BTS2_IP}    10.56.201.20
    ...    AND    Set Test Variable    ${BTS2_Mplane_IP}    10.56.201.207
    ...    AND    Modify Resource Search Order    CM__CB009939-D_001_Setup_OAM_To_OAM_Link_Between_Active_And_Standby_BTS
    ...    AND    Set Library Search Order    CM__CB009939-D_001_Setup_OAM_To_OAM_Link_Between_Active_And_Standby_BTS
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-D_001_Setup_OAM_To_OAM_Link_Between_Active_And_Standby_BTS
    [Teardown]    Run Keywords    CM__CB009939-D_001_Setup_OAM_To_OAM_Link_Between_Active_And_Standby_BTS.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-D_003_Verify_Fault4780_With_Different_Additional_Info
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_50492    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
	...    [1.0] RAN_SyVe_CB009939-D_003_CM_Verify fault 4780 raised with different additional info
    ...    AND    Set Test Variable    ${qc_instance_id}    50492
    ...    AND    Modify Resource Search Order    CM__CB009939-D_003_Verify_Fault4780_With_Different_Additional_Info
    ...    AND    Set Library Search Order    CM__CB009939-D_003_Verify_Fault4780_With_Different_Additional_Info
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-D_003_Verify_Fault4780_With_Different_Additional_Info
    [Teardown]    Run Keywords    CM__CB009939-D_003_Verify_Fault4780_With_Different_Additional_Info.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_50493    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
	...    [1.0] RAN_SyVe_CB009939-D_004_CM_Trigger successful automatic switchover when minCellAvailability condition is met
    ...    AND    Set Test Variable    ${qc_instance_id}    50493
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.106.245.37
    ...    AND    Set Test Variable    ${BTS2_Mplane_IP}    10.56.201.207
    ...    AND    Set Test Variable    ${minCellAvailability1}    80
    ...    AND    Set Test Variable    ${minCellAvailability2}    30
    ...    AND    Modify Resource Search Order    CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met
    ...    AND    Set Library Search Order    CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met
    [Teardown]    Run Keywords    CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-D_005_CM_Trigger_Automatic_Switchover_When_priorityLteCellsList_Or_priorityNrCellsList_Is_Met
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_50494    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
	...    [1.0] RAN_SyVe_CB009939-D_005_CM_Trigger successful automatic switchover when priorityLteCellsList or priorityNrCellsList condition is met
    ...    AND    Set Test Variable    ${qc_instance_id}    50494
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.106.245.37
    ...    AND    Set Test Variable    ${BTS2_Mplane_IP}    10.56.201.207
    ...    AND    Modify Resource Search Order
    ...    CM__CB009939-D_005_CM_Trigger_Automatic_Switchover_When_priorityLteCellsList_Or_priorityNrCellsList_Is_Met
    ...    AND    Set Library Search Order
    ...    CM__CB009939-D_005_CM_Trigger_Automatic_Switchover_When_priorityLteCellsList_Or_priorityNrCellsList_Is_Met
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-D_005_CM_Trigger_Automatic_Switchover_When_priorityLteCellsList_Or_priorityNrCellsList_Is_Met
    [Teardown]    Run Keywords
	...    CM__CB009939-D_005_CM_Trigger_Automatic_Switchover_When_priorityLteCellsList_Or_priorityNrCellsList_Is_Met.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-D_007_Check_Automatic_Switchover_After_BTS_Update_To_Active_Role
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_50495    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
	...    [1.0] RAN_SyVe_CB009939-D_007_CM_Check automatic switchover after BTS is update to active role
    ...    AND    Set Test Variable    ${qc_instance_id}    50495
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.106.245.37
    ...    AND    Set Test Variable    ${BTS2_Mplane_IP}    10.56.201.207
    ...    AND    Modify Resource Search Order    CM__CB009939-D_007_Check_Automatic_Switchover_After_BTS_Update_To_Active_Role
    ...    AND    Set Library Search Order    CM__CB009939-D_007_Check_Automatic_Switchover_After_BTS_Update_To_Active_Role
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-D_007_Check_Automatic_Switchover_After_BTS_Update_To_Active_Role
    [Teardown]    Run Keywords    CM__CB009939-D_007_Check_Automatic_Switchover_After_BTS_Update_To_Active_Role.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-D_008_Check_Automatic_Switchover_After_Peer_BTS_Update_To_Standby_Role
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_50496    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
	...    [1.0] RAN_SyVe_CB009939-D_008_CM_Check automatic switchover after peer BTS is update to standby role
    ...    AND    Set Test Variable    ${qc_instance_id}    50496
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.106.245.37
    ...    AND    Set Test Variable    ${BTS2_Mplane_IP}    10.56.201.207
    ...    AND    Modify Resource Search Order    CM__CB009939-D_008_Check_Automatic_Switchover_After_Peer_BTS_Update_To_Standby_Role
    ...    AND    Set Library Search Order    CM__CB009939-D_008_Check_Automatic_Switchover_After_Peer_BTS_Update_To_Standby_Role
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-D_008_Check_Automatic_Switchover_After_Peer_BTS_Update_To_Standby_Role
    [Teardown]    Run Keywords    CM__CB009939-D_008_Check_Automatic_Switchover_After_Peer_BTS_Update_To_Standby_Role.Case Special Teardown
    ...    AND    Restore Resource Search Order