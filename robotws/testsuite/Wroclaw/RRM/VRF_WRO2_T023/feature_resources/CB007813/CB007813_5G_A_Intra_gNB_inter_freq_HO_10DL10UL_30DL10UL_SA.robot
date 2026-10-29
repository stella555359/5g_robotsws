*** Settings ***
Documentation
...  contact: Szymon Startek

Library     testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB007813/resources/license_wrapper.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB007813/resources/feature_verificator.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.bip_log_collector.BipLogCollector  WITH NAME  BIP
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/swconfig_operations/SwconfigOperations.py

*** Variables ***
${NR_CELL_ID}                          #Source Cell Number
${ASYMM_CELL_ATTEN_ALIAS}              #Asymmetric cell alias for attenuator defined in yaml file
${SYMM_CELL_ATTEN_ALIAS}               #Symmetric cell alias for attenuator defined in yaml file
${CAPABILITY_NR_UE}                    #Qualcomm UE capability defined in yaml file
${NR_CALL_CELL_ID}                     #Source Cell PCI
${UE_ALIAS}                            #Qualcomm UE alias
${GNB_ID}                              #ID of gNB BTS
${LARGE_BWP_COUNTER}                   #Counter to verify data traffic with large BWP
${TEST_SPECIFIC_COUNTER_INTERVAL}      #Required counter interval on TL (value of parameter miNrRSADU)


*** Keywords ***
TC__CB007813_5G_A_Intra_gNB_inter_freq_HO_10DL10UL_30DL10UL_SA
    Set Tags    CA-INTER_RAT    AUTHOR-lukasz.parzybut@nokia.com    OWNER-anna.konior@nokia.com
    ...    MAINTAINER-szymon.startek@nokia.com    PHASE-CRT    SW-SBTS24R1    FEATURE-CBOO7813
    ...    GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Attach UE
    Step 2: Collect Counters
    Step 3: Perform HO And Collect RRC Logs
    Step 4: Analyze Logs


Preconditions
    Log    ${\n}=== Preconditions ===    console=True
    ${_}  ${scf} =  Save And Parse SCF  SCF_miNrRSADU  alias=gNB
    Check Element In SCF  ${scf}  NRPMRNL  NRPMRNL-1  /p[@name='miNrRSADU']
    ...  <p name="miNrRSADU">${TEST_SPECIFIC_COUNTER_INTERVAL}min</p>  dist_name_substring=True
    Set Attenuation    ${ASYMM_CELL_ATTEN_ALIAS}    0%
    Set UE_PC Variables
    Wait Until Keyword Succeeds  10x  10s  Get Qualcomm License
    Require UE    ${UE_ALIAS}    capabilities=${CAPABILITY_NR_UE}
    Log    === Preconditions Finished ===    console=True


Step 1: Attach UE
    Log    ${\n}=== Step 1: Attach UE ===    console=True
    ${sleep_time} =  ca_IWK.Count Measurement Period    ip=${GNB_OAM_IP}    counter_period=${TEST_SPECIFIC_COUNTER_INTERVAL}
    ${end_of_sleep_date} =  Get Current Date  increment=${sleep_time}s  result_format=%H:%M:%S
    Log  \nWaiting for new counters interval until ${end_of_sleep_date}  console=True
    Sleep  ${sleep_time}s  reason=Wait till new counters interval.

    Prepare UE For Data Transfer    ${UE_ALIAS}    ${NR_CALL_CELL_ID}    connection=gNB




Step 2: Collect Counters
    Log    ${\n}=== Step 2: Collect Counters ===    console=True
    ${sleep_time} =  ca_IWK.Count Measurement Period    ip=${GNB_OAM_IP}    counter_period=${TEST_SPECIFIC_COUNTER_INTERVAL}    delta=60
    ${end_of_sleep_date} =  Get Current Date  increment=${sleep_time}s  result_format=%H:%M:%S
    Log  \nWaiting for counters collection until ${end_of_sleep_date}  console=True
    Sleep  ${sleep_time}s  reason=Wait till new counters interval.

    Collect PM Counters    ${LOG_PATH}/pm_counters_s    xml_files_left=1    time_interval=${TEST_SPECIFIC_COUNTER_INTERVAL} min
    ...  intervals=${TEST_SPECIFIC_COUNTER_INTERVAL}


Step 3: Perform HO And Collect RRC Logs
    Log    ${\n}=== Step 2: Perform HO And Collect RRC Logs ===    console=True
    Start RRC Logs    ${UE_ALIAS}
    Start Data Transfer    NR_DL    ${UE_ALIAS}    dl    duration=300s    protocol=tcp    buffer=32M    max_segment_size=1400
    Set Attenuation    ${SYMM_CELL_ATTEN_ALIAS}    0%
    FOR    ${attenuation}    IN RANGE    0    91    10
        Set Attenuation    ${ASYMM_CELL_ATTEN_ALIAS}    ${attenuation}dB
        Sleep   1
    END
    Set Attenuation    ${ASYMM_CELL_ATTEN_ALIAS}    0%
    FOR    ${attenuation}    IN RANGE    0    91    10
        Set Attenuation    ${SYMM_CELL_ATTEN_ALIAS}    ${attenuation}dB
        Sleep   1
    END
    [Teardown]    Step3 Teardown


Step 4: Analyze Logs
    Log    ${\n}=== Step 3: Analyze Logs ===    console=True
    ${extracted_file_path}    Unzip And Return Txt File Path    ${LOG_PATH}/misc_logs/rrc_logs.zip
    ${verdict}    Verify CB007813    ${extracted_file_path}
    Should Be True    ${verdict}    msg=Rach Trigger/Attempt not visible in RRC Logs
    ${M55139C02502} =    Get Counters Values    ${LOG_PATH}/pm_counters_s    ${LARGE_BWP_COUNTER}
    ...    MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${NR_CELL_ID}
    ${M55139C02502} =    Evaluate    [int(i) for i in ${M55139C02502}]
    ${M55139C02502_sum} =    Evaluate    sum(${M55139C02502})
    Should Be True    ${M55139C02502_sum}>0    msg=Data was not transmitted through Large BWP.


Get Qualcomm License
    Log To Console    Get Qualcomm License
    Get 5g Qxdm And Qcat License
    ...    pc_ip=${UE_PC_HOST_IP}
    ...    pc_login=${UE_PC_HOSTNAME}
    ...    pc_password=${UE_PC_PASS}
    ...    username=igor.kleschenok@nokia.com
    ...    password=asdasdd


Release Qualcomm License
    Log To Console    Release Qualcomm License
    Release 5g Qxdm And Qcat License
    ...    pc_ip=${UE_PC_HOST_IP}
    ...    pc_login=${UE_PC_HOSTNAME}
    ...    pc_password=${UE_PC_PASS}


Set UE_PC Variables
    ${UE_PC_HOST_IP}    Evaluate    $tl.ues[0].ssh_connection_details.addr
    Set Test Variable    ${UE_PC_HOST_IP}    ${UE_PC_HOST_IP}
    ${UE_PC_HOSTNAME}    Evaluate    $tl.ues[0].ssh_connection_details.username
    Set Test Variable    ${UE_PC_HOSTNAME}    ${UE_PC_HOSTNAME}
    ${UE_PC_PASS}    Evaluate    $tl.ues[0].ssh_connection_details.password
    Set Test Variable    ${UE_PC_PASS}    ${UE_PC_PASS}
    ${UE_SN}    Evaluate    $tl.ues[0].serial_number
    Set Test Variable    ${UE_SN}    ${UE_SN}


Get Counters Values
    [Arguments]    ${files_path}    ${counter}    ${dist_name}    ${counters_amount}=all
    ${counter_list} =    Create List    ${counter}
    ${pi_dict} =    Get PI Value
    ...    pi_list=${counter_list}
    ...    pi_dir=${files_path}
    ...    pi_file_pattern=PM*
    ${pi_dict}    Set Variable If    '${counters_amount}'.lower() == 'all'
    ...    ${pi_dict}
    ...    ${pi_dict[-${counters_amount}:]}
    ${all_counters_dicts}    Evaluate    [list(x.values())[0] for x in ${pi_dict}]
    ${counter_values}    Evaluate    [x['${counter}']['${dist_name}'] for x in ${all_counters_dicts} if '${counter}' in x.keys()]
    [Return]    ${counter_values}


Change Value of reportingIntervalPm Parameter
    [Arguments]  ${parameter_value}  ${delta_name}=interval_delta  ${connection}=gNB

    Create Delta  delta_id=${delta_name}
    Append Parameter Update To Delta
    ...  MRBTS-${GNB_ID}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm  ${parameter_value}  delta_id=${delta_name}
    ${delta} =  Get Delta  delta_id=${delta_name}
    Perform Delta Recommissioning  ${delta}  connection=${connection}

    ${_}  ${scf} =  Save And Parse SCF  SCF_${parameter_value}  alias=${connection}
    Check Element In SCF  ${scf}  PMCADM  PMCADM-1  /p[@name='reportingIntervalPm']
    ...  <p name="reportingIntervalPm">${parameter_value}</p>  dist_name_substring=True
    [Teardown]  Remove Delta  delta_id=${delta_name}


Step3 Teardown
    Run Keyword And Ignore Error    Stop Data Transfer    NR_DL
    Stop RRC Logs
    ...    ${UE_ALIAS}
    ...    timeout=900
    ...    logs_download_directory=${LOG_PATH}/misc_logs/


TC Setup
    Log    === TC Setup ===    console=True
    IWK Test Setup    local_enb_connection=False    start_wireshark=False    single_bts=True
    ${_}  ${scf} =  Save And Parse SCF  SCF_setup  alias=gNB
    ${initial_counter_interval} =  Get Parameter Value From SCF  ${scf}  PMCADM  PMCADM-1  /p[@name='reportingIntervalPm']
    ...  dist_name_substring=True
    Set Test Variable  ${INITIAL_COUNTER_INTERVAL}  ${initial_counter_interval}
    Change Value of reportingIntervalPm Parameter  parameter_value=${TEST_SPECIFIC_COUNTER_INTERVAL}min


TC Teardown
    Log    === TC Teardown ===    console=True
    Change Value of reportingIntervalPm Parameter  parameter_value=${INITIAL_COUNTER_INTERVAL}
    Set Attenuation For All Cells    100%
    Run Keyword And Ignore Error    Detach UE    ${UE_ALIAS}
    Release Qualcomm License
    IWK Test Teardown    single_bts=True    stop_wireshark=False    local_enb_connection=False

