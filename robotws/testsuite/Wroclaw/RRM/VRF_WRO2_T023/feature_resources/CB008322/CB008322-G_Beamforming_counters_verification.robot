*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library    Collections
Library    SSHLibrary
Library    taf.analyzer.pmcounter
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Library    taf.hw.mcs  WITH NAME   MCS
Library    taf.ue
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.bip_log_collector.BipLogCollector  WITH NAME  BIP
Library    ../../../VRF_WRO2_T01/resources/legacy/ps_csv_parser.py  WITH NAME  parser
Resource   ../../resources/ca_IWK.robot
Resource   ../../../VRF_WRO2_T01/resources/legacy/topyoung_mcs.robot

*** Variables ***
${NR_CELL_ID}                            # ID of tested NR cell
${NR_CALL_CELL_ID}                       # NR cell ID visible at UE
${PS_CONFIG_PATH}                        # Path to Phase Shifter configuration prepared for specific test
${CAPABILITY_NR_UE1}                     # Capability of UE used to first NR DL call
${CAPABILITY_NR_UE2}                     # Capability of UE used to second NR DL call

*** Keywords ***
TC__CB008322-G_Beamforming_counters_verification
    Set Tags    CA-INTER_RAT    AUTHOR-tomasz.stawowczyk@nokia.com    OWNER-piotr.1.maj@nokia.com
    ...         MAINTAINER-tomasz.stawowczyk@nokia.com    PHASE-CRT   SW-SBTS24R2    FEATURE-CB008322   GROUP_IN_CHARGE-Pz_2_WRO_3

    Preconditions
    Step 1: Start Low DT For First UE
    Step 2: Collect Counters And BIP Logs For SB SRS Call
    Step 3: Analyze Counters For SB SRS Call
    Step 4: Start High DT For Second UE
    Step 5: Collect Counters And BIP Logs For SB And WB SRS Calls
    Step 6: Analyze Counters For SB And WB SRS Calls



Preconditions
    Log    === Start Preconditions ===    console=True
    ${nrbts_id}  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}
    Require UE  NR_UE1  capabilities=${CAPABILITY_NR_UE1}
    Require UE  NR_UE2  capabilities=${CAPABILITY_NR_UE2}
    Setup Phaseshifter


Step 1: Prepare Testline Configuration
    Log  === Step 1: Prepare Testline Configuration ===  console=True
    Set Test Variable  ${COMMISIONING_PERFORMED}  True
    Perform Commissioning  ${NRBTS_ID}  ${BTS_CONFIG_PATH}  timeout=600  connection=gNB
    Wait Until Keyword Succeeds  5m  1m  _Verify Bts States For Iwk Test Helper  alias=gNB
    Start Wireshark Log Collection For IWK Test  options=-i any host ${GNB_OAM_IP} and not udp port 2152 -s 0 -W 1
    ...                                          replace_enb=False  replace_gnb=False

Step ${index}: Start ${tput_level} DT For ${ue_no} UE
    Log  === Step ${index}: Start ${tput_level} DT For ${ue_no} UE ===  console=True
    ${tput_value}  Set Variable If  '${index}'=='1'  50  1450
    ${dt_name}     Set Variable If  '${index}'=='1'  NR_DL1  NR_DL2
    ${ue_name}     Set Variable If  '${index}'=='1'  NR_UE1  NR_UE2
    Attach UE  ${ue_name}
    ${current_ue_cell}  Get Ue Info  ${ue_name}  cell_id
    ${ue_ip}  Wait Until Keyword Succeeds  5x  10s  Get UE Info  ${ue_name}  ip
    Should Match Regexp  ${ue_ip}  \\d+\\.\\d+\\.\\d+\\.\\d+
    Should Match  ${current_ue_cell}  ${NR_CALL_CELL_ID}  msg=UE attached to antother cell than expected!
    Start Data Transfer  ${dt_name}  ${ue_name}  dl  throughput=${tput_value} Mbits/sec
    ...  protocol=udp  packet=1400  duration=2400s
    Sleep  10s  reason=Waiting to call stabilize
    Check Data Transfer Is Alive  ${dt_name}
    Log  === Data Transfer Started ===  console=True


Step ${index}: Collect Counters And BIP Logs For SB SRS Call
    Log    === Step ${index}: Collect Counters And BIP Logs For SB SRS Call ===    console=True
    Collect BIP Logs For Specific Amount Of Time  3  ${index}
    Wait Required Period And Collect PM Counters  ${index}
    Log  === PM Counters And BIP Logs Collected ===  console=True


Step 3: Analyze Counters For SB SRS Call
    Log    === Step 3: Analyze Counters For SB SRS Call ===    console=True
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00002']}  300  msg=M55196C00002 has value different than 300!
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00004']}  1    msg=M55196C00004 has value different than 1!
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00009']}  300  msg=M55196C00009 has value different than 300!
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00010']}  0    msg=M55196C00010 has value different than 0!
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00011']}  1    msg=M55196C00011 has value different than 1!
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00012']}  0    msg=M55196C00012 has value different than 0!
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00013']}  300  msg=M55196C00013 has value different than 300!
    ${M55371C_counters_values}  Get Dictionary Values  ${M55371C_COUNTERS_DICT}
    ${M55371C_one_list}  Evaluate  sum(${M55371C_counters_values}, [])
    ${M55371C_int_list}  Evaluate  [int(x) for x in ${M55371C_one_list}]
    ${sum_M55371C_values}  Evaluate  sum(${M55371C_int_list})
    Should Be True  ${sum_M55371C_values}==0  msg=Some of counter's M55371C value is greater than 0!
    Log    === Counters For SB SRS Call Have Expected Values ===    console=True


Step ${index}: Collect Counters And BIP Logs For SB And WB SRS Calls
    Log    === Step ${index}: Collect Counters And BIP Logs For SB And WB SRS Calls ===    console=True
    Collect BIP Logs For Specific Amount Of Time  3  ${index}
    Wait Required Period And Collect PM Counters  ${index}
    Log  === PM Counters And BIP Logs Collected ===  console=True


Step 6: Analyze Counters For SB And WB SRS Calls
    Log    === Step 6: Analyze Counters For SB And WB SRS Calls ===    console=True
    ${M55371C00160_value_str}  Pop From Dictionary  ${M55371C_COUNTERS_DICT}  M55371C00160
    ${M55371C00161_value_str}  Pop From Dictionary  ${M55371C_COUNTERS_DICT}  M55371C00161
    ${M55371C00191_counter_values}  Pop From Dictionary  ${M55371C_COUNTERS_DICT}  M55371C00191
    Set Test Variable   ${M55371C00191_COUNTER_VALUES}  ${M55371C00191_counter_values}
    Check Whether One Of Both Counters Is Grater Than 1000  ${M55371C00160_value_str}  ${M55371C00161_value_str}
    ${M55371C_counters_values}  Get Dictionary Values  ${M55371C_COUNTERS_DICT}
    ${M55371C_one_list}  Evaluate  sum(${M55371C_counters_values}, [])
    ${M55371C_int_list}  Evaluate  [int(x) for x in ${M55371C_one_list}]
    ${sum_M55371C_values}  Evaluate  sum(${M55371C_int_list})
    Should Be True  ${sum_M55371C_values}==0  msg=Some of counter's M55371C value is greater than 0! (excluding M55371C00160 and M55371C00161)
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00002']}  600  msg=M55196C00002 has value different than 600!
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00004']}  2    msg=M55196C00004 has value different than 2!
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00009']}  300  msg=M55196C00009 has value different than 300!
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00010']}  300  msg=M55196C00010 has value different than 300!
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00011']}  1    msg=M55196C00011 has value different than 1!
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00012']}  1    msg=M55196C00012 has value different than 1!
    List Should Contain Value  ${M55196C_COUNTERS_DICT['M55196C00013']}  300  msg=M55196C00013 has value different than 300!
    Additional Step For ABIP Coverage
    Log    === Counters For SB And WB SRS Calls Have Expected Values ===    console=True

Check Whether One Of Both Counters Is Grater Than 1000
    [Arguments]  ${M55371C00160_value_str}  ${M55371C00161_value_str}
    ${greater_than_1000}   Set Variable  ${False}
    FOR  ${M55371C00160_value}  ${M55371C00161_value}  IN ZIP  ${M55371C00160_value_str}  ${M55371C00161_value_str}
         ${M55371C00160_value}   Evaluate  int(${M55371C00160_value})
         ${M55371C00161_value}   Evaluate  int(${M55371C00161_value})
        ${greater_than_1000}   Set Variable If  ${M55371C00160_value} > 1000 or ${M55371C00161_value} > 1000  ${True}  ${False}
        IF  ${greater_than_1000}  BREAK
    END
    Should Be True  ${greater_than_1000}  msg=None of the values of M55371C00160 and M55371C00161 is greater than 1000!


Additional Step For ABIP Coverage
    ${M55371C00191_values_greater_than_2000}  Create List
    FOR  ${value}  IN  @{M55371C00191_COUNTER_VALUES}
         ${value}  Evaluate  int(${value})
         Run Keyword If  ${value}>2000  Append To List  ${M55371C00191_values_greater_than_2000}  ${value}
    END
    Should Not Be Empty  ${M55371C00191_values_greater_than_2000}  msg=None of the values of M55371C00191 is greater than 2000!

Wait Required Period And Collect PM Counters
    [Arguments]  ${index}
    ${waiting_time}  Count Measurement Period  ${GNB_OAM_IP}  5  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}  360
    Log  === Waiting ${waiting_time} seconds till counters will be ready ===  console=true
    Sleep  ${waiting_time}s  reason=Wait till counters will be collected.
    Collect PM Counters  ${LOG_PATH}/pm_counters_s/${index}  xml_files_left=2  time_interval=10 min  intervals=5
    ${M55196C_counter_list}  Create List  M55196C00001  M55196C00002  M55196C00003  M55196C00004  M55196C00005  M55196C00006  M55196C00007
    ...  M55196C00008  M55196C00009  M55196C00010  M55196C00011  M55196C00012  M55196C00013
    ${M55196C_counters_dict}  Get Values Of Counters From List  ${LOG_PATH}/pm_counters_s/${index}  ${M55196C_counter_list}
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    Set Test Variable  ${M55196C_COUNTERS_DICT}  ${M55196C_counters_dict}

    ${M55330C_counter_list}  Create List  M55330C00017  M55330C00018  M55330C00020  M55330C00021
    ${M55330C_counters_dict}  Get Values Of Counters From List  ${LOG_PATH}/pm_counters_s/${index}  ${M55330C_counter_list}
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    Log  === Dictionary with counter M55330C000XX values ${M55330C_counters_dict} ===

    ${M55371C_counter_list}  Create List  M55371C00140  M55371C00141  M55371C00142  M55371C00143  M55371C00144  M55371C00145  M55371C00146
    ...  M55371C00147  M55371C00148  M55371C00149  M55371C00150  M55371C00151  M55371C00152  M55371C00153  M55371C00154  M55371C00155  M55371C00156
    ...  M55371C00157  M55371C00158  M55371C00160  M55371C00161  M55371C00162  M55371C00163  M55371C00164  M55371C00165  M55371C00166
    ...  M55371C00167  M55371C00168  M55371C00169  M55371C00170  M55371C00171  M55371C00172  M55371C00173  M55371C00174  M55371C00175  M55371C00176
    ...  M55371C00177  M55371C00178  M55371C00179  M55371C00180  M55371C00181  M55371C00182  M55371C00183  M55371C00184  M55371C00185  M55371C00186
    ...  M55371C00187  M55371C00188  M55371C00189  M55371C00190  M55371C00191  M55371C00193  M55371C00194  M55371C00195  M55371C00196
    ...  M55371C00197  M55371C00198  M55371C00199  M55371C00200  M55371C00201  M55371C00202
    ${M55371C_counters_dict}  Get Values Of Counters From List  ${LOG_PATH}/pm_counters_s/${index}  ${M55371C_counter_list}
    ...  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}
    Set Test Variable  ${M55371C_COUNTERS_DICT}  ${M55371C_counters_dict}


Setup Phaseshifter
    [Documentation]  Any other connection to phase shifter (even manual connection) must be terminated
    ...              before using KW Setup MCS
    Log  === Start Setting At Phase Shifter ===  console=True
    Setup MCS
    ${att_list}  parser.get_att_output_channel  ${PS_CONFIG_PATH}
    ${phase_list}   parser.get_phase_output_channel  ${PS_CONFIG_PATH}
    Create output channels lists  ${att_list}  ${phase_list}
    ${length}  Get Length  ${ATT_B1}
    Update attenuations  ${length}
    Update phases  ${length}
    Log  === Phase Shifter Is Set! ===  console=True
    [Teardown]  Teardown MCS


Collect BIP Logs For Specific Amount Of Time
    [Arguments]  ${time_in_seconds}  ${step_nr}
    BIP.Start Log Collecting
    Sleep  ${time_in_seconds}s  reason=For BIP collection
    BIP.Stop Log Collecting
    ${PCAP_PATH}  BIP.Download Log  ${LOG_PATH}/misc_logs/${step_nr}
    Log To Console   ${PCAP_PATH}


Create Output Channels Lists
    [Arguments]  ${att}  ${phase}
    FOR  ${i}  IN RANGE  16
        Set Test Variable  ${ATT_B${i}}  ${att}[${i}]
        Set Test Variable  ${PHASE_B${i}}  ${phase}[${i}]
    END


Update Attenuations
    [Arguments]  ${length}
    FOR  ${i}  IN RANGE  0  ${length}
        MCS.set attenuation   ${ATT_B0}[${i}]   ${i+1}    ${1}   MCS_0
        MCS.set attenuation   ${ATT_B1}[${i}]   ${i+1}    ${2}   MCS_0
        MCS.set attenuation   ${ATT_B2}[${i}]   ${i+1}    ${3}   MCS_0
        MCS.set attenuation   ${ATT_B3}[${i}]   ${i+1}    ${4}   MCS_0
        MCS.set attenuation   ${ATT_B4}[${i}]   ${i+1}    ${5}   MCS_0
        MCS.set attenuation   ${ATT_B5}[${i}]   ${i+1}    ${6}   MCS_0
        MCS.set attenuation   ${ATT_B6}[${i}]   ${i+1}    ${7}   MCS_0
        MCS.set attenuation   ${ATT_B7}[${i}]   ${i+1}    ${8}   MCS_0
        MCS.set attenuation   ${ATT_B8}[${i}]   ${i+1}    ${9}   MCS_0
        MCS.set attenuation   ${ATT_B9}[${i}]   ${i+1}    ${10}   MCS_0
        MCS.set attenuation   ${ATT_B10}[${i}]   ${i+1}    ${11}   MCS_0
        MCS.set attenuation   ${ATT_B11}[${i}]   ${i+1}    ${12}   MCS_0
        MCS.set attenuation   ${ATT_B12}[${i}]   ${i+1}    ${13}   MCS_0
        MCS.set attenuation   ${ATT_B13}[${i}]   ${i+1}    ${14}   MCS_0
        MCS.set attenuation   ${ATT_B14}[${i}]   ${i+1}    ${15}   MCS_0
        MCS.set attenuation   ${ATT_B15}[${i}]   ${i+1}    ${16}   MCS_0
    END


Update Phases
    [Arguments]  ${length}
    FOR  ${i}  IN RANGE  0  ${length}
        MCS.set phase   ${PHASE_B0}[${i}]   ${i+1}    ${1}   MCS_0
        MCS.set phase   ${PHASE_B1}[${i}]   ${i+1}    ${2}   MCS_0
        MCS.set phase   ${PHASE_B2}[${i}]   ${i+1}    ${3}   MCS_0
        MCS.set phase   ${PHASE_B3}[${i}]   ${i+1}    ${4}   MCS_0
        MCS.set phase   ${PHASE_B4}[${i}]   ${i+1}    ${5}   MCS_0
        MCS.set phase   ${PHASE_B5}[${i}]   ${i+1}    ${6}   MCS_0
        MCS.set phase   ${PHASE_B6}[${i}]   ${i+1}    ${7}   MCS_0
        MCS.set phase   ${PHASE_B7}[${i}]   ${i+1}    ${8}   MCS_0
        MCS.set phase   ${PHASE_B8}[${i}]   ${i+1}    ${9}   MCS_0
        MCS.set phase   ${PHASE_B9}[${i}]   ${i+1}    ${10}   MCS_0
        MCS.set phase   ${PHASE_B10}[${i}]   ${i+1}    ${11}   MCS_0
        MCS.set phase   ${PHASE_B11}[${i}]   ${i+1}    ${12}   MCS_0
        MCS.set phase   ${PHASE_B12}[${i}]   ${i+1}    ${13}   MCS_0
        MCS.set phase   ${PHASE_B13}[${i}]   ${i+1}    ${14}   MCS_0
        MCS.set phase   ${PHASE_B14}[${i}]   ${i+1}    ${15}   MCS_0
        MCS.set phase   ${PHASE_B15}[${i}]   ${i+1}    ${16}   MCS_0
    END


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log    === TC Teardown ===    console=True
    Run Keyword And Ignore Error  Stop data transfers for all UEs
    Detach UE   NR_UE1
    Detach UE   NR_UE2
    IWK Test Teardown  single_bts=True  local_enb_connection=False
