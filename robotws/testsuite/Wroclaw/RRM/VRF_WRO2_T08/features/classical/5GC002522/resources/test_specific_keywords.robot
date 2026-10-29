*** Settings ***
Documentation
...    author:  Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Library    ute_ue
Library    taf.sw.syslog    WITH NAME   taf_syslog
Library    ta_attenuator
Library    ./test_specific_keywords.py
Library    testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/ue_logs/ue_logs.py
Resource   testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource   testsuite/Wroclaw/RRM/resources/logs.robot
Resource   taf/rfrl/common_resources/common_step/interface.robot

*** Keywords ***
Test Setup For Attach Scenario With Higher Nrarfcn
    Set Initial Attenuation
    Set TESTNAME Without Spaces
    Start Collecting Syslog
    Change To Higher Nrarfcn
    X2 Link Is Available


Test Setup For Attach Scenario With Lower Nrarfcn
    Set Initial Attenuation
    Set TESTNAME Without Spaces
    Start Collecting Syslog
    Change To Lower Nrarfcn
    X2 Link Is Available


Test Setup For UL And DL With 64QAM
    Set Initial Attenuation
    Set TESTNAME Without Spaces
    Set Test Variable  ${QAM}  64QAM
    Start Collecting Syslog
    Change To Middle Nrarfcn
    Change To 256QAM Disable
    X2 link is available
    Wait Until Keyword Succeeds  20x  5 sec  Get QXDM License


Test Setup For UL And DL With 256QAM
    Set Initial Attenuation
    Set TESTNAME without spaces
    Set Test Variable  ${QAM}  256QAM
    Start Collecting Syslog
    Change To Middle Nrarfcn
    Change To 256QAM Enable
    X2 Link Is Available
    Wait Until Keyword Succeeds  20x  5 sec  Get QXDM License


Test Teardown
    Run Keyword And Continue On Failure  Detach Ue  UE_1
    taf_syslog.Collect Syslog Results
    Stop L1L2 logs
    Release Attenuator
    Run Keyword If Test Failed  Log To Console  Collecting BTS Snapshot!
    Make Snapshot In Case Of Error
    Run Keyword And Ignore Error    interface.Common Step Trigger


Set Initial Attenuation
    ${cell_list}=  Create List  GNB_1_CELL_1  GNB_1_CELL_2  GNB_1_CELL_3  GNB_1_CELL_4
    Set Global Variable  ${gnb_cells}  ${cell_list}
    Load Attenuation Config  ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of  ${gnb_cells}
    Set Attenuation  ${CELL_1_ALIAS}  10dB
    Set Attenuation  ${CELL_2_ALIAS}  10dB
    Set Attenuation  ${CELL_3_ALIAS}  10dB
    Set Attenuation  ${CELL_4_ALIAS}  10dB
    Sleep  2s


Release Attenuator
    Release Attenuator Cell  ${gnb_cells}


Prepare Ue
    Require Ue  UE_1  capabilities=REAL_ANDROID_UE
    Detach Ue  UE_1


Reboot Ue
    [Documentation]  Perform adb reboot command
    [Arguments]  ${alias}=UEPC
    ssh.Connect To  hostname=10.42.22.159
    ...             username=wro5grrm
    ...             password=5gpass!1
    ...             alias=${alias}
    RETURN  ${alias}
    ssh.Execute  command=adb reboot  connection=${alias}
    Sleep  50s


Start Collecting Syslog
    taf_syslog.Start Syslog  log_dir=${LOGPATH}/syslog  log_name=${test_name}_syslog.log
    ...           ip=${tl.test_pc[0].default_ssh_connection_details.addr}


Attach UE And Save L1L2 Log
    Kill Tcpdump On CU
    Start gnbMirroring
    Start Tcpdump On CU  filename=${test_name}_SCTP_ASIK.pcap
    Wait Until Keyword Succeeds  3x  20 sec  Attach
    Stop And Collect Tcpdump On CU
    ${l1l2_log}=  Stop gnbMirroring And Gather L1L2 Logs
    Run  zip ${LOG_PATH}/${l1l2_log}.zip ${LOG_PATH}/${l1l2_log}
    Run  rm ${LOG_PATH}/${l1l2_log}
    Check Attach Sctp Msgs  in_pcap=${SCTP_ASIK_PATH}


Attach
    Attach Ue  UE_1
    Sleep  10s


Connect To UEPC With AndroidUe Yaml
    [Arguments]  ${alias}=UEPC
    ssh.Connect To  hostname=10.42.22.159
    ...             username=wro5grrm
    ...             password=5gpass!1
    ...             alias=${alias}
    RETURN  ${alias}


Check Maximum Throughput And Average Mcs For 64QAM
    ${max_tput_mcs}=  Get Mcs Average For Maximum Throughput  ul_value=60Mbits/sec  dl_value=450Mbits/sec
    ...                                                       attenuation_1=0db  attenuation_2=0db
    ...                                                       attenuation_3=0db  attenuation_4=0db
    Should Be True  27 < ${max_tput_mcs[0]} and ${max_tput_mcs[0]} <= 28
    Should Be True  27 < ${max_tput_mcs[1]} and ${max_tput_mcs[1]} <= 28


Check Maximum Throughput And Average Mcs For 256QAM
    ${max_tput_mcs}=  Get Mcs Average For Maximum Throughput  ul_value=60Mbits/sec  dl_value=650Mbits/sec
    ...                                                       attenuation_1=10db  attenuation_2=10db
    ...                                                       attenuation_3=10db  attenuation_4=10db
    Should Be True  27 < ${max_tput_mcs[0]} and ${max_tput_mcs[0]} <= 28
    Should Be True  26 < ${max_tput_mcs[1]} and ${max_tput_mcs[1]} <= 27


Get Avg MCS
    [Arguments]  ${filename}
    ${qcat_file}=  Start QXDM Logging  duration=10  filename=${filename}  ue_id=${1}
    Set Test Variable  ${qcat_file}
    ${avg_mcs}=  Get MCS From Qcat File  ${qcat_file}
    RETURN  ${avg_mcs}

Get Mcs Average For Maximum Throughput
    [Arguments]  ${ul_value}=55Mbits/sec  ${dl_value}=550Mbits/sec  ${deviation}=20%  ${attenuation_1}=15db
    ...          ${attenuation_2}=15db  ${attenuation_3}=15db  ${attenuation_4}=15db
    Set Attenuation  ${CELL_1_ALIAS}  ${attenuation_1}
    Set Attenuation  ${CELL_2_ALIAS}  ${attenuation_2}
    Set Attenuation  ${CELL_3_ALIAS}  ${attenuation_3}
    Set Attenuation  ${CELL_4_ALIAS}  ${attenuation_4}
    Log  Start Data Transfer  console=yes
    Start Data Transfer  dt_name=DT_DL  ue_alias=UE_1  duration=500s  direction=dl  throughput=${dl_value}  protocol=udp
    Start Data Transfer  dt_name=DT_UL  ue_alias=UE_1  duration=500s  direction=ul  throughput=${ul_value}  protocol=udp
    Sleep  10s  reason=data transfer
    Check Data Transfer Is Alive  DT_DL
    Check Data Transfer Is Alive  DT_UL
    ${mcs_avg}=  Get Avg MCS  filename=${QAM}_${attenuation_1}
    Log To Console  UL mcs average for ${attenuation_1} attenuation and ${ul_value} is ${mcs_avg[0]}
    Log To Console  DL mcs average for ${attenuation_1} attenuation and ${dl_value} is ${mcs_avg[1]}
    Verify Avg Tput from Qcat File  qcat_file_path=${LOG_PATH}/${QAM}_${attenuation_1}.txt
    ...                             ul_tput=${ul_value}  dl_tput=${dl_value}  deviation=${deviation}
    Log  Stop Data Transfer  console=yes
    Stop Data Transfer  DT_UL
    Stop Data Transfer  DT_DL
    RETURN  ${mcs_avg}


Check Average MCS From Given Traffic For 64QAM
    ${LA_1_20}=  Get Mcs Average From Given Traffic  ul_value=1Mbits/sec  dl_value=20Mbits/sec  attenuation_1=65db
    ...                                              attenuation_2=65db  attenuation_3=65db  attenuation_4=65db
    ${LA_20_200}=  Get Mcs Average From Given Traffic  ul_value=20Mbits/sec  dl_value=200Mbits/sec  attenuation_1=55db
    ...                                                attenuation_2=55db  attenuation_3=55db  attenuation_4=55db
    ${LA_55_450}=  Get Mcs Average From Given Traffic  ul_value=55Mbits/sec  dl_value=450Mbits/sec  attenuation_1=0db
    ...                                                attenuation_2=0db  attenuation_3=0db  attenuation_4=0db
    ${LA_21_201}=  Get Mcs Average From Given Traffic  ul_value=21Mbits/sec  dl_value=201Mbits/sec  attenuation_1=55db
    ...                                                attenuation_2=55db  attenuation_3=55db  attenuation_4=55db
    ${LA_1_21}=  Get Mcs Average From Given Traffic  ul_value=1Mbits/sec  dl_value=21Mbits/sec  attenuation_1=65db
    ...                                              attenuation_2=65db  attenuation_3=65db  attenuation_4=65db
    Compare MCS Values  ${LA_1_20}  ${LA_20_200}
    Compare MCS Values  ${LA_20_200}  ${LA_55_450}
    Compare MCS Values  ${LA_21_201}  ${LA_55_450}
    Compare MCS Values  ${LA_1_21}  ${LA_21_201}


Get Mcs Average From Given Traffic
    [Arguments]  ${ul_value}=1Mbits/sec  ${dl_value}=20Mbits/sec  ${deviation}=20%  ${attenuation_1}=20db
    ...          ${attenuation_2}=20db  ${attenuation_3}=20db  ${attenuation_4}=20db
    Set Attenuation  ${CELL_1_ALIAS}  ${attenuation_1}
    Set Attenuation  ${CELL_2_ALIAS}  ${attenuation_2}
    Set Attenuation  ${CELL_3_ALIAS}  ${attenuation_3}
    Set Attenuation  ${CELL_4_ALIAS}  ${attenuation_4}
    Log  Start Data Transfer  console=yes
    Start Data Transfer  dt_name=DT_DL  ue_alias=UE_1  duration=500s  direction=dl  throughput=${dl_value}  protocol=udp
    Start Data Transfer  dt_name=DT_UL  ue_alias=UE_1  duration=500s  direction=ul  throughput=${ul_value}  protocol=udp
    Sleep  10s  reason=data transfer
    Check Data Transfer Is Alive  DT_DL
    Check Data Transfer Is Alive  DT_UL
    ${mcs_avg}=  Get Avg MCS  filename=${QAM}_${attenuation_1}
    Log To Console  UL mcs average for ${attenuation_1} attenuation and ${ul_value} is ${mcs_avg[0]}
    Log To Console  DL mcs average for ${attenuation_1} attenuation and ${dl_value} is ${mcs_avg[1]}
    Verify Avg Tput From Qcat File  qcat_file_path=${LOG_PATH}/${QAM}_${attenuation_1}.txt
    ...                             ul_tput=${ul_value}  dl_tput=${dl_value}  deviation=${deviation}
    Log  Stop Data Transfer  console=yes
    Stop Data Transfer  DT_UL
    Stop Data Transfer  DT_DL
    RETURN  ${mcs_avg}

Check Average MCS From Given Traffic For 256QAM
    ${LA_1_20}=  Get Mcs Average From Given Traffic  ul_value=1Mbits/sec  dl_value=20Mbits/sec  attenuation_1=65db
    ...                                              attenuation_2=65db  attenuation_3=65db  attenuation_4=65db
    ${LA_20_200}=  Get Mcs Average From Given Traffic   ul_value=20Mbits/sec  dl_value=200Mbits/sec  attenuation_1=55db
    ...                                                 attenuation_2=55db  attenuation_3=55db  attenuation_4=55db
    ${LA_55_550}=  Get Mcs Average From Given Traffic   ul_value=55Mbits/sec  dl_value=650Mbits/sec  attenuation_1=0db
    ...                                                 attenuation_2=0db  attenuation_3=0db  attenuation_4=0db
    ${LA_21_201}=  Get Mcs Average From Given Traffic   ul_value=21Mbits/sec  dl_value=201Mbits/sec  attenuation_1=55db
    ...                                                 attenuation_2=55db  attenuation_3=55db  attenuation_4=55db
    ${LA_1_21}=  Get Mcs Average From Given Traffic   ul_value=1Mbits/sec  dl_value=21Mbits/sec  attenuation_1=65db
    ...                                               attenuation_2=65db  attenuation_3=65db  attenuation_4=65db
    Compare MCS Values  ${LA_1_20}  ${LA_20_200}
    Compare MCS Values  ${LA_20_200}  ${LA_55_550}
    Compare MCS Values  ${LA_21_201}  ${LA_55_550}
    Compare MCS Values  ${LA_1_21}  ${LA_21_201}


Stop L1L2 Logs
    ${ASIK}=  Connect to ASIK
    ${ABIL_SLAVE}=  Connect to ABIL SLAVE
    ssh.Execute  command=killall tcpdump  connection=${ABIL_SLAVE}


Compare MCS Values
    [Arguments]  ${LA_1}  ${LA_2}
    Should Be True  ${LA_1[0]}<${LA_2[0]}
    Should Be True  ${LA_1[1]}<${LA_2[1]}


Stop And Collect Tcpdump On CU
    Stop Tcpdump On CU And Download Logs  filename=${test_name}_SCTP_ASIK.pcap
    Set Test Variable  ${SCTP_ASIK_PATH}  ${LOGPATH}/${test_name}_SCTP_ASIK.pcap


Release QXDM License
     Run Keyword And Ignore Error  Release 5g QXDM And QCAT License  ue_id=${1}

Get QXDM License
    Get 5g QXDM And QCAT License  username=lukasz.klosinski@nokia.com
    ...                           password=Lukas12#
    ...                           ue_id=${1}
