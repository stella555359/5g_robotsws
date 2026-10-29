*** Settings ***
Documentation
...    author: Michal Halucha
...    contact: michal.halucha@nokia.com

Library     ute_syslog
Library     taf.ue
Library     ta_attenuator
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     ./test_specific_keywords_cloud.py
Library     OperatingSystem
Library     DateTime
Library     ute_admin_infomodel
Library     testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector.EltLogCollector   WITH NAME   ELT
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/CB008409/resources/test_variables_cloud.py


*** Variables ***
${LOG_PATH}          ${OUTPUT DIR}
&{CONFIGURATION}     pyro_port=9092    com_port=COM5    python=python
${CELL_504}          GNB_1_CELL_504
${CELL_604}          GNB_1_CELL_604

*** Keywords ***
Test Setup
    Initialize Attenuators
    Prepare Ue


Teardown
    Run Keyword And Ignore Error    Detach Ue    UE_1
    Run Keyword And Ignore Error    Detach Ue    UE_2
    Run Keyword If Test Failed      Collect Snapshot For Cloud Tl
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=admin_gnb
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Teardown Utf
    Setup Vdu Parameters    DISABLED


Prepare Ue
    Require Ue    UE_1    capabilities=REAL_UE
    Require Ue    UE_2    capabilities=REAL_UE
    Detach Ue     UE_1
    Detach Ue     UE_2


Release Attenuator
    Set Attenuation For All Cells  90dB


CB008409_A_1_CSI_IM_randomization_in_FDD_cell_with_PDL_rule_verification_feature_activation_and_deactivation
    Setup Vdu Parameters    DISABLED
    Sleep  70s
    Start Utf Tracing
    Sleep  10s
    Attenuate Cell    504    0dB
    Attach Ue    UE_1
    Attenuate Cell    504    20dB
    Attenuate Cell    604    0dB
    Attach Ue    UE_2
    Attenuate Cell    504    0dB
    Verify Uplink and Downlink Throughput   500Mbits/sec    20MHz_feature_disabled    ${LOG_PATH}    UE_1    UE_2
    Detach Ue    UE_1
    Detach Ue    UE_2
    Setup Vdu Parameters    ENABLED
    Sleep  70s
    Attenuate Cell    504    0dB
    Attach Ue    UE_1
    Attenuate Cell    504    20dB
    Attenuate Cell    604    0dB
    Attach Ue    UE_2
    Attenuate Cell    504    0dB
    Verify Uplink and Downlink Throughput   500Mbits/sec    20MHz_feature_enabled    ${LOG_PATH}    UE_1    UE_2
    Detach Ue    UE_1
    Detach Ue    UE_2
    Stop Utf Tracing
    Unzip Results
    Prepare Emil Logs
    Analyze Emil Log    ${timeResPatternEnabled}
    Analyze Emil Log    ${csi_rs_Pattern}
    Analyze Emil Log    ${csi_im_Pattern}


CB008409_B_2_Enhanced_ReTransmission_when_SRB1_and_SRB2_is_being_retransmitted_with_non_VoNR_UEs
    Start Utf Tracing
    Sleep  10s
    Attenuate Cell    506    0dB
    Attach Ue    UE_2
    Trigger Retransmissions    200Mbits/sec    UE_2
    Detach Ue    UE_2
    Attach Ue    UE_2
    Stop Utf Tracing
    Unzip Results
    Prepare Emil Logs
    Find Syslog Files From Utf
    Merge Syslog
    Verify Syslog    ${B_2}
