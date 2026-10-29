*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../SWM/BOAM_ET/RP002324/RP002324_ASIL.robot
Resource          ../SWM/CB007821/CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource          ../SWM/CB007821/CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.robot
Resource          ../SWM/CB007821/CB007821_CB006147_SFP_QSFP_control.robot
Resource          ../SWM/CB007500/CB007500.robot
Resource          ../SWM/CB007500/CB007500ET.robot
Resource          ../HWM/LBT5358/TD_OM_LBT5358_SFP_Monitoring.robot
Resource          ../SWM/BOAM_ET/RP002324/Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors.robot
Resource          ../SWM/BOAM_ET/RP002324/ABIO_OAM_LBT2679_Collect_SW_download_and_activation_files_after_SW_update_fails.robot
Resource          ../SWM/SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned.robot
Resource          ../SWM/SWM__SW_update_for_new_RF_unit_uncommissioned.robot
Resource          ../SWM/RP001362.robot
Resource 	      ../SWM/BOAM_ET/RP002324/Automated__FPGA_SW_Update_and_Activation.robot


*** Variables ***
${target_release}    SBTS25R2
${sw_package_path}     /home/ute/btsauto
${Target SW dir}       /home/ute/btsauto/TARGET_SW


*** Test Cases ***
[CB007821] LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    [Tags]    QC_684680    original:3_5_UTE4G243     1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    ...    AND    CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    [Teardown]    CB007821_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown

[CB007821] LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
    [Tags]    QC_684684        original:3_5_UTE4G243    1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...   AND    Set Library Search Order    CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
    ...     AND    CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Setup
    LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS
    [Teardown]    CB007821_LTE4934-C_ST_05_16_Flat_SOAM_Software_Management_SWM_rollback_Software_for_multi-MRBTS.TC_Custom Teardown

[CB007821] CB007821_CB006147_SFP_QSFP_control
    [Tags]    QC_416820        original:3_5_UTE4G243     1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB007821_CB006147_SFP_QSFP_control   taf.sbts.oam.coam.admin
    ...    AND    TC Setup
    TC_CB006147_05_01_Lock_Unlock_of_SFP
    [Teardown]    TC Teardown

CB007500_ST_05_05_PNP start with configuration reset to D&RSW with Multi_NMS
    [Tags]    QC_581823    original:3_5_UTE4G502     1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords    set library search order    CB007500      CB007500ET     taf.sbts.oam.coam.admin
    ...    AND    TC Setup
    CB007500_ST_05_05_PNP start with configuration reset to D&RSW with Multi_NMS
    [Teardown]  CB007500 TC teardown

CB007500_ET_05_04_Execute shell script to trigger configuration reset
    [Tags]    QC_547595     original:3_5_UTE4G502    1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords    set library search order    CB007500     CB007500ET    taf.sbts.oam.coam.admin
    ...    AND    TC Setup
    CB007500_ET_05_04_Execute shell script to trigger configuration reset
    [Teardown]  TC teardown

OAM_LBT2679_Collect SW download and activation files after SW update fails
    [Tags]    QC_475192    original:3_5_UTE4G204    1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords          Set Library Search Order
    ...    ABIO_OAM_LBT2679_Collect_SW_download_and_activation_files_after_SW_update_fails
    ...    AND       TC Setup
    OAM_LBT2679_Collect SW download and activation files after SW update fails
   [Teardown]    TC Teardown

Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
    [Tags]    QC_475196        original:3_5_UTE4G502    1st:3_5_UTE4G243     prio-2
    [Setup]    run keywords       Set Library Search Order
    ...    Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
    ...    AND     TC Setup
    Automated__SW_Management__Failure_In_Nyquist_DSP_Runtime_SW_Download_Caused_By_Checksum_Errors
   [Teardown]    TC Teardown

SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
    [Tags]    QC_71210    original:3_5_UTE4G502    1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords     Set Library Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
    ...     AND      SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned.TC_Custom Setup
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
    [Teardown]    SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned.TC_Custom Teardown

RP001362_SWM__fallback_to_3rd_Airscale_partition
    [Tags]    QC_71242    original:3_5_UTE4G502    1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords    Set Library Search Order    RP001362      taf.sbts.oam.coam.admin    AND   TC Setup
    RP001362_SWM__fallback_to_3rd_Airscale_partition
    [Teardown]    TC Teardown

Automated__FPGA_SW_Update_and_Activation
    [Tags]    QC_475201    original:3_5_UTE4G502    1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords    Set Library Search Order     Automated__FPGA_SW_Update_and_Activation
    ...    AND   TC Setup
    Automated_FPGA_SW_Update_and_Activation
   [Teardown]    Custom TC Teardown

SWM__SW_update_for_new_RF_unit_uncommissioned
    [Tags]    QC_71212    original:3_5_UTE4G502    1st:3_5_UTE4G243       prio-2     fpgab
    [Setup]    run keywords    Set Library Search Order    SWM__SW_update_for_new_RF_unit_uncommissioned      CB007500
    ...    AND    SWM__SW_update_for_new_RF_unit_uncommissioned.TC_Custom Setup
    TC__SWM__SW_update_for_new_RF_unit_uncommissioned
    [Teardown]    SWM__SW_update_for_new_RF_unit_uncommissioned.TC_Custom Teardown

[1]CB008962_configuration reset to D&RSW
    [Tags]    QC_601418      original:3_5_UTE4G502     1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords    set library search order    CB007500    taf.sbts.oam.coam.admin     AND    TC Setup
    [Timeout]    3600s
    CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    ${ConfigReset_KPI_check}=    Operation_KPI_Check    ${ConfigResetEndTime}    ${ConfigResetStartTime}
    ...    ${ConfigReset_expect_time}    ConfigReset_BTS_KPI
    [Teardown]  TC teardown

[1]CB007215_ST_PnP_05_01 Autoconnection Performance (e2e) less than 10min
    [Tags]    QC_601417         original:3_5_UTE4G502     1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords    set library search order    CB007500    taf.sbts.oam.coam.admin     AND    TC Setup
    [Timeout]    600s
    ${Autoconn_KPI_check}=    Operation_KPI_Check    ${AutoconnEndTime}    ${AutoconnStartTime}
    ...    ${Autoconn_expect_time}    Autoconn_BTS_KPI
    set suite variable    ${Autoconn_KPI_check}
    [Teardown]  TC teardown

[1]CB007215_ST_PnP_05_04 Autoconfiguration performance (provision of target SW and configuration plan)
    [Tags]    QC_601415      original:3_5_UTE4G502     1st:3_5_UTE4G243       prio-2
    [Setup]    run keywords    set library search order    CB007500    taf.sbts.oam.coam.admin     AND    TC Setup
    [Timeout]    600s
    ${Autoconf_KPI_check}=    Operation_KPI_Check    ${AutoconfEndTime}    ${AutoconfStartTime}
    ...    ${Autoconf_expect_time}    Autoconf_BTS_KPI
    set suite variable    ${Autoconf_KPI_check}
    [Teardown]  TC teardown
