*** Settings ***
Documentation       Test suite for SBTS37376
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Suite Teardown    Common Suite Teardown
Test Timeout      24h
Variables         My_Variables.py
Variables         ../Variables/NetActs.py
Resource          ../../test_resources/SyVe/SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored.robot
Resource          ../../test_resources/SyVe/SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled.robot
Resource          ../../test_resources/SyVe/SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost.robot
Resource          ../../test_resources/SyVe/SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts.robot
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
#Resource          ../../test_resources/CM/CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI.robot
#Resource          ../../test_resources/CM/CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI.robot
#Resource          ../../test_resources/CM/CM__Lock_And_Unlock_LTE_Cell_During_Cell_Block_And_Unblock_Via_WebEM.robot
#Resource          ../../test_resources/CM/CM__Lock_And_Unlock_NR_Cell_During_Cell_Block_And_Unblock_Via_WebEM.robot
#Resource          ../../test_resources/CM/CM__Lock_And_Unlock_Cell_During_Cell_Block_And_Unblock_Via_WebEM.robot

*** Variables ***
${SRNCLAB}        SRNCLAB1028    # Netact info defined in NetActs.py under Variables folder
${NETACT}         &{${SRNCLAB}}
${SCF_ID}         01
#${SEND_REP_PYTHON_CODE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources/python/UploadTCDataToRep_CRT.py

*** Test Cases ***
SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_100818    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Timeout]    3h
    [Setup]    Run Keywords    Set Test Variable
    ...    ${test_run}    [1.0] RAN_ST_CB012523-B_001_Cell graceful shutdown when M-Plane connection toward NMS is lost.
    ...    AND    Set Test Variable    ${qc_instance_id}    100818
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    ...    AND    Set Library Search Order    SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    [Teardown]    Run Keywords    SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_100820    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Timeout]    3h
    [Setup]    Run Keywords    Set Test Variable
    ...    ${test_run}    [1.0] RAN_ST_CB012523-B_005_Prevent enable cells that has been disabled for another reason
    ...    AND    Set Test Variable    ${qc_instance_id}    100820
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    ...    AND    Set Library Search Order    SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    [Teardown]    Run Keywords    SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_100819    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Timeout]    3h
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_ST_CB012523-B_004_Enable feature when NMS connection is already lost
    ...    AND    Set Test Variable    ${qc_instance_id}    100819
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    ...    AND    Set Library Search Order    SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    [Teardown]    Run Keywords    SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost.TC Teardown
    ...    AND    Restore Resource Search Order

SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_100870    CA_RAN_PZ_HAZ_1
    ...    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Timeout]    3h
    [Setup]    Run Keywords    Set Test Variable
    ...    ${test_run}    [1.0] RAN_ST_CB012523-B_006_Prevent enable cells with status unlocked in case gNB restarts
    ...    AND    Set Test Variable    ${qc_instance_id}    100870
    ...    AND    Set Library Search Order    XML
    ...    AND    SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts.TC Setup
    ...    AND    Modify Resource Search Order    SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    ...    AND    Set Library Search Order    SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    [Teardown]    Run Keywords    SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts.TC Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-A_001_003_BTS_Startup_When_Peer_BTS_Is_Existing
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33053    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}    [1.0] RAN_SyVe_CB009939-A-B1_001_CM_Standby BTS startup when peer BTS is existing
    ...    AND    Set Test Variable    ${qc_instance_id}    33053
    ...    AND    Set Test Variable    ${BTS2_scf_active}    /home/ute/testline_configuration/10_5_UTESRAN37376/commissioning/37377_scf_active.xml
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
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
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.68.161.96
    ...    AND    Set Test Variable    ${MRBTS_ID_1}    37376
    ...    AND    Set Test Variable    ${MRBTS_ID_2}    37377
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
    ...    AND    Modify Resource Search Order    CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset
    ...    AND    Set Library Search Order    CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset
    [Teardown]    Run Keywords    CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-A_005_Configure_BTS_Redundancyrole_As_Standby_Without_Site_Reset
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33045    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
    ...    [1.0] RAN_SyVe_CB009939-A-B3_005_CM_Configure BTS redundancyrole as standby without site reset
    ...    AND    Set Test Variable    ${qc_instance_id}    33045
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.68.161.96
    ...    AND    Set Test Variable    ${MRBTS_ID_1}    37376
    ...    AND    Set Test Variable    ${MRBTS_ID_2}    37377
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
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
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.68.161.96
    ...    AND    Set Test Variable    ${MRBTS_ID_1}    37376
    ...    AND    Set Test Variable    ${MRBTS_ID_2}    37377
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
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
    ...    AND    Set Test Variable    ${REMOTE_HOST_IP}    10.68.161.96
    ...    AND    Set Test Variable    ${MRBTS_ID_1}    37376
    ...    AND    Set Test Variable    ${MRBTS_ID_2}    37377
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
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
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
    ...    AND    Modify Resource Search Order    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    ...    AND    Set Library Search Order    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    [Teardown]    Run Keywords    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy.Case Special Teardown
    ...    AND    Restore Resource Search Order

CM__CB009939-A_012_Forced_Active_BTS_Startup_When_Peer_BTS_Is_Existing
    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33049    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
    [Setup]    Run Keywords    Set Test Variable    ${test_run}
	...    [1.0] RAN_SyVe_CB009939-A-B8_012_CM_Forced active BTS startup when peer BTS is existing
    ...    AND    Set Test Variable    ${qc_instance_id}    33049
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
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
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
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
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
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
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
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
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
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
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
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
    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
    ...    AND    Modify Resource Search Order    CM__CB009939-D_008_Check_Automatic_Switchover_After_Peer_BTS_Update_To_Standby_Role
    ...    AND    Set Library Search Order    CM__CB009939-D_008_Check_Automatic_Switchover_After_Peer_BTS_Update_To_Standby_Role
    ...    AND    Common Test Setup SBTS    scf_check=${FALSE}
    [Timeout]    2h
    CM__CB009939-D_008_Check_Automatic_Switchover_After_Peer_BTS_Update_To_Standby_Role
    [Teardown]    Run Keywords    CM__CB009939-D_008_Check_Automatic_Switchover_After_Peer_BTS_Update_To_Standby_Role.Case Special Teardown
    ...    AND    Restore Resource Search Order

#CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI
#    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33048    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
#    [Setup]    Run Keywords    Set Test Variable    ${test_run}
#	...    [1.0] RAN_SyVe_CM_Repeat_Recommission_with_HWRESET_via_WebEM
#    ...    AND    Set Test Variable    ${qc_instance_id}    33048
#    ...    AND    Set Test Variable    ${REPEAT_TIME}    20
#    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
#    ...    AND    Modify Resource Search Order    CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI
#    ...    AND    Set Library Search Order    CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI
#    ...    AND    CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI.SetUp
#    [Timeout]    10h
#    CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI
#    [Teardown]    Run Keywords    CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI.CaseTearDown
#    ...    AND    Restore Resource Search Order
#
#CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI
#    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33048    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
#    [Setup]    Run Keywords    Set Test Variable    ${test_run}
#	...    [1.0] RAN_SyVe_CM_Repeat_Recommission_with_HWRESET_via_WebEM
#    ...    AND    Set Test Variable    ${qc_instance_id}    33048
#    ...    AND    Set Test Variable    ${REPEAT_TIME}    20
#    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
#    ...    AND    Modify Resource Search Order    CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI
#    ...    AND    Set Library Search Order    CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI
#    ...    AND    CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI.SetUp
#    [Timeout]    10h
#    CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI
#    [Teardown]    Run Keywords    CM__Repeat_RF_BB_Module_Reset_By_HWRESET_via_AdminAPI.CaseTearDown
#    ...    AND    Restore Resource Search Order
#
#CM__Lock_And_Unlock_Cell_During_Cell_Block_And_Unblock_Via_WebEM
#    [Tags]    SRAN    QCD_MN_RAN    QCP_RAN_VRF    QC_33047    CA_RAN_PZ_HAZ_1    CLOUD_SRAN_NL_37376_1ASIM_1ABIP_1ABIO_1AZHM_1AHCF
#    [Setup]    Run Keywords    Set Test Variable    ${test_run}
#	...    [1.0] Automated_CM_Cell_Lock_and_Unlock_cell_during_Cell_Block_and_Unblock_via_WebEM
#    ...    AND    Set Test Variable    ${qc_instance_id}    33047
#    ...    AND    Set Test Variable    ${REPEAT_TIME}    20
#    ...    AND    Set Test Variable    ${tl_name}    SRAN_Hangzhou_UTESRAN37376
#    ...    AND    Modify Resource Search Order    CM__Lock_And_Unlock_Cell_During_Cell_Block_And_Unblock_Via_WebEM
#    ...    AND    Set Library Search Order    CM__Lock_And_Unlock_Cell_During_Cell_Block_And_Unblock_Via_WebEM
#    ...    AND    CM__Lock_And_Unlock_Cell_During_Cell_Block_And_Unblock_Via_WebEM.SetUp
#    [Timeout]    10h
#    CM__Lock_And_Unlock_Cell_During_Cell_Block_And_Unblock_Via_WebEM
#    [Teardown]    Run Keywords    CM__Lock_And_Unlock_Cell_During_Cell_Block_And_Unblock_Via_WebEM.CaseTearDown
#    ...    AND    Restore Resource Search Order
