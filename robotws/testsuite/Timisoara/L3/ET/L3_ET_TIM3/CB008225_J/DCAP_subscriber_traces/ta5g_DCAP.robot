*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    5G_RAN_TDD    5G_RAN    SBTS00    SBTS22R4
...           RAN_5G    RAN_5G_TDD    CRT    PY36
...           NoResUsage

Documentation    :testsuite description: Checking the ta5g_dcap library

Resource    5GC000770_Keywords_And_Variables.robot
Library     ta5g_dcap

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...         AND             Reach OnAir    lua_cfg=${CURDIR}/../resources/egate_2c_tdd_sansa.lua
    ...         AND             Perform Parameter Commissioning    parameter=actLocationReportingSA  value=true

Suite Teardown    Run Keywords    Run Keyword And Continue On Failure    Stop DCAP
   ...            AND             Run Keyword And Continue On Failure    Delete DCAP BTS
   ...            AND             Perform Parameter Commissioning    parameter=actLocationReportingSA  value=false
   ...            AND             Stop Default Processes And Gather Logs And Compress Logs
### dodać do keyworda ścieżkę do logów dcapowych? - rozważyć, bo póki co keywordy powinny pakować dcapy do ${OUTPUT_DIR}
### domyślnie libka TAF zbiera do: /tmp/dcap_start_trace_data.zip ?

*** Test Cases ***
DCAP_1_With_5GC000770_A_B1_1_Successful_Location_Reporting_On_Demand_Direct
    [Documentation]  This test case checks successful DCAP collection
#    Get BTS Tracing Profiles
 #   Get 5G Tracing Profiles
  #  Get LTE Tracing Profiles
    Configure DCAP Session
    Create DCAP BTS
    Start DCAP Tracing
    Attach Ue    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Trigger Location Reporting    ue_id=1  event_type=direct
    Verify Ngap Messages    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_DIRECT}  number_of_messages=1
    Verify Ngap Messages    packet_filter=${NGAP_LOCATION_REPORT_ULI}  number_of_messages=1
    Sleep    10s
    Stop DCAP
    Get DCAP Results
    Delete DCAP BTS

DCAP_2_With_5GC000770_A_B1_1_Successful_Location_Reporting_On_Demand_Direct
    [Documentation]  This test case checks successful DCAP setup with 1 keyword
     ...             with custom output folder

    Start DCAP
    Attach Ue    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=2    gw_id=2
    Trigger Location Reporting    ue_id=2  event_type=direct
    Sleep    10s
    Stop DCAP
    Get DCAP Results    output_dirpath=${OUTPUT_DIR}/DCAP_Traces
