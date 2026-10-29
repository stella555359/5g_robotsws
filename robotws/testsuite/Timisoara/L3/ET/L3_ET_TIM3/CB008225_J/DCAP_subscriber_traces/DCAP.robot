*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    5G_RAN_TDD    5G_RAN    SBTS00    SBTS22R4
...           RAN_5G    RAN_5G_TDD    CRT    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Katarzyna Wisniewska
...              :contact: katarzyna.wisniewska@nokia.com
...              :testsuite description: The feature 5GC000770 provides the UE location information at cell level. It can be provided
...              by the gNB to the AMF through different messages and on demand after AMF request (Location Reporting Control
...              message). The feature can be enabled/disabled per gNB by an activation flag.

Resource    5GC000770_Keywords_And_Variables.robot
Library     taf.sw.dcap.rd    WITH NAME    rd

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...         AND             Reach OnAir    lua_cfg=${CURDIR}/../resources/egate_2c_tdd_sansa.lua
    ...         AND             Perform Parameter Commissioning    parameter=actLocationReportingSA  value=true
    ...         AND             Configure DCAP Session    host=10.42.188.186
### Host IP powinien być wyciągany z informacji o test linii.
    ...         AND             Create DCAP BTS
#    ...         AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

#Test Setup    Run Keywords      Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
#    ...          AND            Start DCAP Traces

#Test Teardown    Run Keywords   Deregister Ue Without Confirmation    ue_id=1
#    ...          AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
#    ...          AND            Stop DCAP Traces

Suite Teardown    Run Keywords  Dcap Delete BTS
    ...         AND             Perform Parameter Commissioning    parameter=actLocationReportingSA  value=false
    ...           AND           Stop Default Processes And Gather Logs And Compress Logs
### dodać do keyworda ścieżkę do logów dcapowych
### /tmp/dcap_start_trace_data.zip

*** Test Cases ***
5GC000770_A_B1_1_Successful_Location_Reporting_On_Demand_Direct
    [Documentation]  This test case checks successful location reporting on-demand procedure while feature flag
    ...              is activated and stored in UE context Location Reporting Request Type IE is set to direct.
    ...              gNB-CU-CP gets Location Report Request and shall respond to AMF with one Location Report.
    ...              Test case covers requirement: 5G_RAN_USR_RRM_1981
    Get BTS Tracing Profiles
    Get 5G Tracing Profiles
    Get LTE Tracing Profiles
    Start DCAP Traces
    Attach Ue    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Trigger Location Reporting    ue_id=1  event_type=direct
    Verify Ngap Messages    packet_filter=${NGAP_LOCATION_REPORTING_CONTROL_DIRECT}  number_of_messages=1
    Verify Ngap Messages    packet_filter=${NGAP_LOCATION_REPORT_ULI}  number_of_messages=1
    Sleep    10s
    Stop DCAP Traces
    Get DCAP Results

*** Keywords ***
Configure DCAP Session
    [Arguments]      ${host}   ${port}=9443   ${username}=dcapuser   ${password}=dcapadmin!
    ...              ${rd_version}=dcapv3   ${secure}=True    ${alias}=${None}
    ${dcap_conn}=    rd.connect_to          host=${host}   port=${port}   username=${username}   password=${password}
    ...                                     rd_version=${rd_version}   secure=${secure}    alias=${alias}
    [Return]    ${dcap_conn}

Create DCAP BTS
    [Arguments]      ${host}=10.0.1.2    ${port}=443    ${username}=Nemuadmin    ${password}=nemuuser    ${bts_alias}=target_bts
    ...              ${connection}=${None}    ${timeout}=30
    ${extended_bts_info}=     rd.create_bts    host=${host}    port=${port}    username=${username}
    ...              password=${password}    bts_alias=${bts_alias}    connection=${connection}    timeout=${timeout}
#    Log To Console    ${extended_bts_info}
    [Return]    ${extended_bts_info}

Dcap Delete BTS
    [Arguments]      ${bts_id}=${None}   ${connection}=${None}   ${timeout}=30
    ${status}=       rd.delete_bts    bts_id=${bts_id}   connection=${connection}   timeout=${timeout}
    [Return]    ${status}

Start DCAP Traces
### Zahardcodowane dane bts i rodzaj zbieranych logów -> trzeba dodać kolejne keywordy na pobieranie dostępnych profili logowania
### i umożliwienie podania innych profili do keywordu Start DCAP Traces
    Log To Console    Starting Start DCAP Traces
    ${bts}=     Create Dictionary    alias=target_bts
    ...                              host=10.0.1.2
    ...                              port=443
    ...                              username=Nemuadmin
    ...                              password=nemuuser
    ${status}=    rd.start_trace    ${bts}    gnb_trace_profile=dcap-lite-default    enb_trace_profile=dcap-lite-default
    ...                             bts_trace_profile=dcap-lite-default    duration=-1    wait_for_activation=True
    ...                             allow_start_failures=True
    [Return]    ${status}

Stop DCAP Traces
### Keyword powinien czekać aż status tracowania będzie "Ready", aktualnie wygląda na to, że czeka aż zmieni się status "Stopping" co nie jest
### wystarczające dla zebrania logów - wymaga dodania ręcznie sztywnego sleepa, inaczej wywala się keyword Get DCAP Results.

    Log To Console    Starting Stop DCAP Traces
    [Arguments]      ${trace_id}=${None}   ${connection}=${None}    ${timeout}=300
    ${status}=       rd.stop_trace    trace_id=${trace_id}   connection=${connection}  timeout=${timeout}
    Sleep    300s
    [Return]    ${status}

Get DCAP Results
### Pakuje logi dcapowe i zostawia zipa: /tmp/dcap_start_trace_data.zip
### Trzeba dodać do naszych keywordów ściąganie tego zipa razem z resztą logów i usuwanie go z /tmp.
    Log To Console    Starting Get DCAP Results
    [Arguments]      ${result_id}=${None}   ${target_dir}=${None}   ${connection}=${None}    ${timeout}=100
    ${filepath}=     rd.get_results      result_id=${result_id}   target_dir=${target_dir}
    ...                                  connection=${connection}  timeout=${timeout}
    [Return]   ${filepath}

### Ogólny komentarz: jeśli sfailuje jakiś keyword po rozpoczęciu tracingu za pomocą Start DCAP Traces i reszta keywordów się nie odpali,
### w tym Stop Dcap Traces to tracing leci aż do śmierci test linii (jeśli oczywiście duration w start jest ustawiony na -1),
### to powoduje, że wszystkie kolejne tasty z dcapem będą stadać z rowerka -> trzeba do teardowna dawać stoppowania tracingu i zbieranie logów.

Get BTS Tracing Profiles
    [Arguments]    ${connection}=${None}    ${timeout}=30
    ${bts_profiles}=    rd.get_bts_profiles    connection=${connection}    timeout=${timeout}
    Log To Console    ${bts_profiles}
    [Return]   ${bts_profiles}

Get 5G Tracing Profiles
    [Arguments]    ${connection}=${None}    ${timeout}=30
    ${5g_profiles}=    rd.get_5g_profiles    connection=${connection}    timeout=${timeout}
    Log To Console    ${5g_profiles}
    [Return]   ${5g_profiles}

Get LTE Tracing Profiles
    [Arguments]    ${connection}=${None}    ${timeout}=30
    ${lte_profiles}=    rd.get_lte_profiles    connection=${connection}    timeout=${timeout}
    Log To Console    ${lte_profiles}
    [Return]   ${lte_profiles}

