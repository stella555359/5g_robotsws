*** Settings ***
Documentation
...   feature keywords

Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB007877/resources/keywords.py
Library    testsuite/Wroclaw/RRM/resources/webUI_operations.py

*** Keywords ***
Test Teardown
    Detach Ue   ue_alias=UE_1
    Tcpdump.Teardown Tcpdump On Smod
    change a1 measurment configuration      rsrp

Prepare Attenuator
    Initialise Attenuator
    ${CELL_1}   Create List   1   2   3   4
    ${CELL_2}   Create List   5   6   11    12
    ${CELL_3}   Create List   7   8   9    10
    Set test variable   ${CELL_1}
    Set test variable   ${CELL_2}
    Set test variable   ${CELL_3}

Verify 3CC
    [Arguments]    ${log_path}=${log_path}/${test_name}_SMOD.pcap
    Verify CA      ${log_path}   2

Prepare TL for 3CC
    switch scell addition method    1    2
    Initialise Attenuator
    Set Attenuation  40dB  ${CELL_1}  confirm=${TRUE}
    Set Attenuation  19dB  ${CELL_2}  confirm=${TRUE}
    Set Attenuation  19dB  ${CELL_3}  confirm=${TRUE}

Prepare Preventive HO For 3CC
    Change A1 measurment configuration      rsrp
    Activate PCellSwitch
    Initialise Attenuator
    Set Attenuation  40dB  ${CELL_1}  confirm=${TRUE}
    Set Attenuation  25dB  ${CELL_2}  confirm=${TRUE}
    Set Attenuation  25dB  ${CELL_3}  confirm=${TRUE}

Trigger Better Conditions On Scell 3CC
    Initialise Attenuator
    Set Attenuation  17dB  ${CELL_2}  confirm=${TRUE}
    Set Attenuation  17dB  ${CELL_3}  confirm=${TRUE}
    BuiltIn.Sleep    2

Trigger Scell Addition
    Initialise Attenuator
    Set Attenuation  16dB  ${CELL_1}  confirm=${TRUE}
    BuiltIn.Sleep    2

Perform Data Transfer
    [Arguments]             ${dt_alias}
	... 				    ${ue_alias}
    ...                     ${direction}
    ...                     ${duration}
    ...                     ${throughput}
    ...                     ${protocol}
    Log to console      Perform ${throughput} ${direction} data transfer for ${duration}
    Start Data Transfer  dt_name=DT_DL_1  ue_alias=UE_1  direction=dl  duration=${duration}    throughput=${throughput}  packet_size=1400
    ...                 dt_name=${dt_alias}
    ...                 ue_alias=${ue_alias}
    ...                 direction=${direction}
    ...                 duration=${duration}
    ...                 throughput=${throughput}
    ...                 protocol=${protocol}
    ...                 packet_size=1400

Verify A1 Event Values RSRP
    [Arguments]
    ...                     ${pname_Threshold}=a1ThresholdSCellAddSsbRsrpFDD
    ...                     ${pname_hysteresis}=a1HysteresisSCellAddSsbRsrp
    ...                     ${pname_TimeToTrigger}=a1TimeToTriggerSCellAddSsbRsrp
    ...                     ${a1Meas_list}=a1MeasSCellAddSsbRsrp
    ...                     ${nrcellId}=1
    ...                     ${filter}=nr-rrc.eventA1_element
    ...                     ${message}=UEContextSetupRequest
    ...                     ${pcap_file}=${log_path}/${test_name}_SMOD.pcap
    ${A1Threshold}        collect A1 setup from SCF    ${nrcellId}    ${pname_Threshold}         ${a1Meas_list}
    ${A1hysteresis}       collect A1 setup from SCF    ${nrcellId}    ${pname_hysteresis}        ${a1Meas_list}    ${log path}/scf.xml
    ${A1TimeToTrigger}    collect A1 setup from SCF    ${nrcellId}    ${pname_TimeToTrigger}     ${a1Meas_list}    ${log path}/scf.xml
    Run Keyword And Continue On Failure    verify RRC A1 event         ${message}    ${filter}    ${A1Threshold}
    ...                                    ${A1hysteresis}    ${A1TimeToTrigger}    ${pcap_file}

Verify A1 Event Values RSRQ
    Verify A1 Event Values RSRP
    ...    a1ThresholdSCellAddSsbRsrq    a1HysteresisSCellAddSsbRsrq    a1TimeToTriggerSCellAddSsbRsrq     a1MeasSCellAddSsbRsrq

Activate PCellSwitch
    [Arguments]         ${action}=true     ${nrcellId}=1      ${pname}=a1BasedPCellSwitchEnabled
    change parameter    ${action}    ${nrcellId}    ${pname}

Deactivate PCellSwitch
    [Arguments]         ${action}=false     ${nrcellId}=1    ${pname}=a1BasedPCellSwitchEnabled
    change parameter    ${action}    ${nrcellId}    ${pname}
