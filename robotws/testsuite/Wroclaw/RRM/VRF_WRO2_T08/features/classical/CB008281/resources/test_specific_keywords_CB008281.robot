*** Settings ***
Documentation
...   author: Michal Halucha
...   contact: michal.halucha@nokia.com

Library     taf.ue
Library     SSHLibrary
Library     OperatingSystem
Library     testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008281/resources/test_specific_keywords_CB008281.py
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${LOG_PATH}               ${OUTPUT DIR}
${ABSTRACT_LIB_CONFIG}   /home/ute/testline_configuration/7_16_UTE5GCLOUDWPT3/ue_config.yaml


*** Keywords ***
Test Setup
    Collect Scf Before Test
    Initialize Attenuator
    Set Attenuation For Cell    GNB_1_CELL_591    5dB
    Set Attenuation For Cell    GNB_1_CELL_592    0dB
    Set Nls Parameters
    Setup Dcap Controller


Test Teardown
    Run Keyword And Ignore Error    interface.Common Step Trigger
    Run Keyword And Ignore Error    Clear Admin Logs
    Run Keyword If Test Failed      Make Webui Snapshot
    Run Keyword If Test Failed      Stop And Collect Logs  ${TRACE_ID}
    Release Attenuator
    Teardown Nls


Prepare UE
    Require UE    UE_1  UE_1
    Detach Ue    UE_1
    Sleep    10s


Prepare Logs
    ${path}=  Get Path
    Unzip Results
    Find Pcap Files In Dcap Folders
    Convert Pdml


CB008281_A_B_Activation_and_Verification
    Verify Administrative State  Locked  NRCELL-1  NRCELL-2  NRCELL-3  NRCELL-4
    Verify Feature Flag  NRCELL-591  NRCELL-592
    Prepare UE
    Execute Trigger From Lmf And Collect Logs
    Prepare Logs
    Check E Cid Measurements Flow
    Check Position Measurement
    Check Failure Case


CB008281_A_D_Activation_And_MDT_Trace_Interaction
    Verify MDT Cell Tracing
    Verify RRC Reconfiguration Cell Tracing
