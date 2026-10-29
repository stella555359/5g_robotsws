*** Settings ***
Documentation
...  Author:        Pawel Wisniewski
...  Contact:       pawel.1.wisniewski@nokia.com
...  Description:   Automated test cases for CB009235 feature. Scenario is based on test plan provided in QC test cases.
...                 Target test line is located in WPT. BTS_51015 | MRBTS-51015_7_16_MRBTS-51015 |  PhaseShifter 6 REG 2

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/PmUtils.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/topyoung_mcs.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/ps_csv_parser.py   WITH NAME   parser


*** Variables ***
${SCF_9235}=        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB009235/resources/CB009235.xml
${pair_counters}    M55308C34013
${unpair_counters}  M55308C34034
${all_counters}     M55308C34013,M55308C34034
${active_cellID}    501
${feature_param_path}    MRBTS-51015/NRBTS-51015/NRCELL-501/NRDLMUMIMO-1
${eda_counters}    M55308C36001

${ps6_mcs_server}  10.44.234.46
${ps6_mcs_server_port}  ${28888}
${ps6_mcs_vendor}  TOPYOUNG
${ps6_mcs_model}  MCS2350A2-128B16-A5
${ps6_mcs_freq}  ${3550}
${on_air_timer}  25min


*** Keywords ***
Perform commissioning CB009235
    Log to console                      __Performing CB009235 SCF commissioning
    coam.connect to                     name=get_sw
    ${release}                          coam.Get sw release name  connection=get_sw
    coam.Teardown                       connection=get_sw
    coam.connect_to                     name=comm         release=${release}
    coam.perform commissioning          ${MRBTS_5G_ID}  ${SCF_9235}  ${True}  ${True}  600  comm
    Wait until keyword succeeds         ${on_air_timer}   10sec   Verify all cells are onair with admin
    coam.teardown  connection=comm


Check Pair Counters Value
    Log To Console    __Check M55308C34013 values
    &{counter_value}            Get counters    ${pair_counters}
    &{last_counter_value}   PmUtils.get last counters values
    ...  ${counter_value['BTS']['MRBTS-${bts_id}']['NRBTS-${bts_id}']['NRCELL-${active_cellID}']['NCELA']}
    PmUtils.check_counters_are_greater_than_zero  ${last_counter_value}


Check Unpair Counters Value
    Log To Console    __Check M55308C34034 values
    &{counter_value}            Get counters    ${unpair_counters}
    &{last_counter_value}   PmUtils.get last counters values
    ...  ${counter_value['BTS']['MRBTS-${bts_id}']['NRBTS-${bts_id}']['NRCELL-${active_cellID}']['NCELA']}
    run keyword and ignore error  PmUtils.check_counters_are_greater_than_zero  ${last_counter_value}

Check counters are zero after call
    Log To Console    __Check M55308C34013 values
    &{counter_value}            Get counters    ${all_counters}
    &{last_counter_value}   PmUtils.get last counters values
    ...  ${counter_value['BTS']['MRBTS-${bts_id}']['NRBTS-${bts_id}']['NRCELL-${active_cellID}']['NCELA']}
    PmUtils.check_counters_are_zero  ${last_counter_value}

Setup MCS PS6
    Setup MCS
    ...            server_ip=${ps6_mcs_server}
    ...            server_port=${ps6_mcs_server_port}
    ...            vendor=${ps6_mcs_vendor}
    ...            model=${ps6_mcs_model}

Set pair phaseshifter config
    Setup MCS PS6

    ${att_list}    parser.get_att_output_channel
    ...    testsuite/Wroclaw/RRM/VRF_WRO2_T01 /utilities/resources/PhaseShifter_csv/9235_controller_pair.csv
    ${phase_list}   parser.get_phase_output_channel
    ...    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/PhaseShifter_csv/9235_controller_pair.csv

    Create output channels lists  ${att_list}   ${phase_list}
    ${length}=    Get Length    ${att_B1}
    Update attenuations   ${length}
    Update phases   ${length}
    Teardown MCS

Set non pair phaseshifter config
    Setup MCS PS6

    ${att_list}    parser.get_att_output_channel
    ...    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/PhaseShifter_csv/9235_controller_nopair.csv
    ${phase_list}   parser.get_phase_output_channel
    ...    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/PhaseShifter_csv/9235_controller_nopair.csv

    Create output channels lists  ${att_list}   ${phase_list}
    ${length}=    Get Length    ${att_B1}
    Update attenuations   ${length}
    Update phases   ${length}
    Teardown MCS

Deactivate feature
    log to console    Deactivating feature
    Initialise delta store
    Connect with runtime release
    add param to delta        ${feature_param_path}   actMuAwareTdSch       false
    ${delta}                             Collect delta store
    Recommission with delta from admin   ${delta}
    Wait until keyword succeeds         ${on_air_timer}   10sec   Verify all cells are onair with admin
    check alarms

Activate feature
    log to console    Activating feature
    Initialise delta store
    Connect with runtime release
    add param to delta        ${feature_param_path}   actMuAwareTdSch       true
    ${delta}                             Collect delta store
    Recommission with delta from admin   ${delta}
    Wait until keyword succeeds         ${on_air_timer}   10sec   Verify all cells are onair with admin
    check alarms

Check Alarms
    log to console    Check alarms
    coam.connect to
    coam.add allowed alarm    parameters=faultId=61649
    coam.add allowed alarm    parameters=faultId=4655
    coam.add allowed alarm    parameters=faultId=4654
    coam.add allowed alarm    parameters=faultId=61524
    coam.add allowed alarm    parameters=faultId=61652
    coam.add allowed alarm    parameters=faultId=1898
    coam.assert no unexpected active alarms

Check EDA 03529075 counters
    Log To Console    __Check M55308C36001 values
    &{counter_value}            Get counters    ${eda_counters}
    &{last_counter_value}   PmUtils.get last counters values
    ...  ${counter_value['BTS']['MRBTS-${bts_id}']['NRBTS-${bts_id}']['NRCELL-${active_cellID}']['NCELA']}
    PmUtils.check_counters_are_greater_than_zero  ${last_counter_value}


Check EDA 03529075 counters after call
    Log To Console    __Check M55308C36001 values
    &{counter_value}            Get counters    ${eda_counters}
    &{last_counter_value}   PmUtils.get last counters values
    ...  ${counter_value['BTS']['MRBTS-${bts_id}']['NRBTS-${bts_id}']['NRCELL-${active_cellID}']['NCELA']}
    PmUtils.check_counters_are_zero  ${last_counter_value}
