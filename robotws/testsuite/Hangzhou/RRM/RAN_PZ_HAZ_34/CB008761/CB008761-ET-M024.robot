*** Settings ***
Documentation
...    author:  dandan.chen@nokia-sbell.com
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv_tmo_65    ue_count=32
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_LOO_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    7305    7107    7523    7308    7304    10
@{PARAMS_IN_SWCONFIG}
...    0x590072=2
...    0x58057a=4
...    0x580580=3145728
...    0x890003=0
...    0x1002B = 0x17FB    # ERadCcs_AaTraceSwConfId1 - (API_NRTAIML_DATA_PUSH_IND_MSG)
...    0x1005A = 1      # ERadCcs_AaTraceTracingMode (Message trace is printed in all nodes)
...    0x100CE = 0      # ERadCcs_AaTraceRestrictToOwnDomain (Trace all messages)
...    0x1002A = 2      # ERadCcs_AaTraceSwConfUsed (AaTrace enabled in swconfig-only mode. Cannot be reconfigured by external tools)
...    0x890073=0
#...    0x9D0000=5

${ue_capa_4cc}    SEPARATOR=
...    E1A03E00474F7AEF7FFFAF084000F05C0407824F7CFFFFFF002600C6F3E00050370300FC7016A2F831EF13843B102087E5068020B65474031
...    27D620F2107840A12DF3F013FF0FC000FFC3F0000BC0001C00140A8BE147BC4E10EC40821F941A0082D951D00C49F5883C841E10284B7CFC0
...    2EEE3BE003BB8EF8002F500070005001B2800028000001000200002A2F85FEF13843B102087E5068020B6547403127D620F2107840A12DF3F
...    013F9EE7800FE7B9E000BC0001C00140A8BE20FBC4E10EC40821F941A0082D951D00C49F5883C841E10284B7CFC04FFC3F0003FF0FC0002F0
...    0007000502A2F88DEF13843B102087E5068020B6547403127D620F2107840A12DF3F0108002000BC0001C00140A8BE267BC4E10EC40821F94
...    1A0082D951D00C49F5883C841E10284B7CFC0220008002F500070005001B28000280000010002000003141E0C000611800007A27541C0C01C
...    460000027A27541E14000611800047A27541C1401C460000067A27541E140007118000021E89D50788C00184600029E89D503850100018C44
...    EA83C18000C140001CF44EA8381803850000020F44EA83C18000E140000093D13AA0F0A0003050000A3113EA170A0203830001C460000167A
...    274014046805100605D8822C190A74ED927C0853A76C93E0428D3B649F0214E9DB24F810A14ED927C0853A76C93E0408DB24F810A74ED927C
...    0853A36C93E0429D03649F021469DB24F811234E9DB24F8004C306318C6318C6318C07C0C09048641209048641219048641200C07F3000002
...    F003E002800301C1401C0C4270070007000603E058820000004100000220800002104000018820000104100000A2080000610400003882001
...    010041040020200A208004050104100080A0280EC19AC99AC0DAC8DAC1DBCA9AC0CAC8CA0382000012CB28080000CB2CA02000052CB280800
...    01CB2CA02000092CB2A080002CB2CA820000D2CB28080003CB2CA00EA0D1549A2A81C55238AA0F574AAAA83C5D2A8A16010805F82C1E0B078
...    2C1E0B0783C1E0B00002C20E00400C008018020050040081C0180080400100600201000041C00800801001004002008000380300700801200
...    C01C0200408380500B00A01601803403006070060020100040180080400010700A002014004030008060000E00C01C0200480300700801020
...    E01403C0280780601100C0201C0180380400900600E01002041C03803807007010012020020380700101000201C0040400000380900B01401
...    602C03406006083801003002006008014010020700A00201800402800806000107002002004004010008020000E01402C0300680500B00C01
...    820E00400C008018020050040081C0280780601100A01E01804041C0280580500B00C01A018030380500100C0020140040300010080C00C02
...    00C01808030062160E02060816305E828CEE00000004

@{ue_4CC_expect_regexp}
...    pcid:53, scellIdx:

${ue_id}    1
${j}    1
${file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008761/test_data/SBTS00/SCellActivationTrainingConfiguration.json

${sed_hour_cmd}    SEPARATOR=
...    cd /rom/ml_data/bundle/SCellActivation_*/SCellActivation/;
...    sed -i -E 's/"hours": [0-9]+,/"hours": 0,/g' SCellActivationTrainingConfiguration.json

${sed_minute_cmd}    SEPARATOR=
...    cd /rom/ml_data/bundle/SCellActivation_*/SCellActivation/;
...    sed -i -E ' /"initialPeriod"/,/\}/ s/"minutes": [0-9]+/"minutes": 20/;
...    /"accuracyCheckPeriod"/,/\}/ s/"minutes": [0-9]+/"minutes": 20/;
...    /"trainingPeriod"/,/\}/ s/"minutes": [0-9]+/"minutes": 40/' SCellActivationTrainingConfiguration.json

&{CELLS_CARRIER_FREQ}
...     2=502110
...     3=520110
...     7=396970
...     10=125290

*** Test Cases ***
CB008761-ET-M024-ASIL
    [Documentation]
    ...    1. This user scenario describes activation of CB008761 feature.
    ...    3. Test Case Steps:
    ...           a. site all cell setup, lock/unlock all TDD cell, check mlTrainingState state
    ...           b. disable/enable feature flag, check mlTrainingState state
    ...           c. preparework and wait trained success
    ...           d. check counter after trained for pcell TDD
    ...           e. check counter after trained for pcell FDD
    ...           f. check counter for 4CC 2T2F with covbasedA1 and A2release
    ...           g. check stable after trained for many UEs
    ...           h. check counter for 4CC 2T2F with covbasedA1 after flag disable
    ...    4. Expected Results:
    ...           a. mlTrainingState state set to Training when at least one TDD cell setup
    ...           b. mlTrainingState state set to Training when feature enable
    ...           c. set mlTrainingStartTime and wait training success
    ...           d. pcell TDD UE, counter as expected
    ...           e. pcell FDD UE, counter as expected
    ...           f. 4CC 2T2F with covbasedA1 and A2release, counter as expected
    ...           g. check no abnormal log when many UEs
    ...           h. 4CC 2T2F with covbasedA1 after flag disable, counter as expected
    [Tags]    QC_362171    CA_LABEL-2T2F(2_100M_TDD_n41+1_20M_FDD_n25+1_20M_FDD_n71)
    online modify flag and check state
    preparework and wait trained success
    check counter after trained for two UEs
    check counter for 4CC 2T2F with covbasedA1 and A2release
    check stable after trained for many UEs
    check counter for 4CC 2T2F with covbasedA1 after flag disable

*** Keywords ***
preparework and wait trained success
    preparework for training
    log to console    wait for state to be trained
    Clear Counter Files
    Make CA call and show traffic
    wait until keyword succeeds    9200    600s    Get mlstate    expect_state=Trained    expect_inference=available
    log to console    Current expect_state: Trained
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_N1}

online modify flag and check state
    Get mlstate    expect_state=Training    expect_inference=unavailable
    Delta Commission Parameters    ${PARAMS_actMLScellAct_disable}
    wait care cell mibsib
    Get mlstate    expect_state=Idle    expect_inference=unavailable
    Delta Commission Parameters    ${PARAMS_actMLScellAct_enable}
    wait care cell mibsib
    Get mlstate    expect_state=Training    expect_inference=unavailable

check counter after trained for two UEs
    log to console    check counter after trained for two UEs
    Clear Counter Files
    UE 4CC 2T2F    ue_id=1    send_large_traffic=True    target_cell=3    bufferbase=True
    UE 4CC 2T2F    ue_id=2    send_large_traffic=True    target_cell=10    bufferbase=True    carrierfreq=125290
    Release ues    ue_type=all
    Check Counters    ${PM_Counters_Check_after_trained}

check counter for 4CC 2T2F with covbasedA1 and A2release
    log to console    check counter for 4CC 2T2F with covbasedA1 and A2release
    UE 4CC 2T2F covBasedA1 and A2release    ue_id=1

check counter for 4CC 2T2F with covbasedA1 after flag disable
    log to console    check counter for 4CC 2T2F with covbasedA1 after flag disable
    Delta Commission Parameters    ${PARAMS_actMLScellAct_disable}
    wait care cell mibsib
    Get mlstate    expect_state=Idle    expect_inference=unavailable
    4CC 2T2F with covbasedA1 after flag disable    ue_id=1

4CC 2T2F with covbasedA1 after flag disable
    [Arguments]    ${ue_id}=1    ${target_cell}=3    ${pdu_id}=1
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${ue_capa_4cc}
    Clear Counter Files
    Execute Egate Command    ue_change_location id=${ue_id} cell=${target_cell} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1
    ...    pass_regexp=Initial Context Setup Successful
    Traffic some traffic For UE    ue_id=${ue_id}
    ${meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    event_type=A1    carrierfreq=520110
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=100
    ...    pass_regexp=${ue_4CC_expect_regexp}    timeout=20s
    Traffic Send For UE    ue_id=${ue_id}    send_large_traffic=True    bufferbase=True
    Check Counters    ${PM_Counters_Check_2T2F_covbase_flagdisable}
    Release ues    ue_type=all

preparework for training
    Execute Cmd On Pc  sudo timedatectl set-timezone Etc/UTC
#    put_enb_file    ${file}    /tmp/
#    execute cmd on bts  mv /tmp/SCellActivationTrainingConfiguration.json /rom/ml_data/bundle/SCellActivation_*/SCellActivation/
    execute cmd on bts    ${sed_hour_cmd}
    execute cmd on bts    ${sed_minute_cmd}
    execute cmd on bts    cd /rom/ml_data/bundle/SCellActivation_*/SCellActivation/;cat SCellActivationTrainingConfiguration.json
    ${time}=    Get Time    format=%H:%M
    log to console    Current time: ${time}
    ${hour}=    Evaluate    int(str("${time}").split(":")[0].split(" ")[1])
    ${minute}=    Evaluate    int(str("${time}").split(":")[1])
    log to console    Current hour: ${hour}, Current minute: ${minute}
    ${set_hour1}=    Evaluate    ${hour}+1
    ${set_hour2}=    Evaluate    ${hour}+2
    Run Keyword If    ${minute} >= 30    Delta Commission Parameters
    ...    MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:mlTrainingParams:mlTrainingStartTime=${set_hour2}
    Run Keyword If    ${minute} < 30    Delta Commission Parameters
    ...    MNL-1/MNLENT-1/FEATCADM-1/MLCADM-1:mlTrainingParams:mlTrainingStartTime=${set_hour1}
    sleep    240s
    Execute Egate Command    re
    admin.reset_site    connection=${BTS1_ALIAS}
    sleep    300s
    Execute Egate Command    cfg file=/opt/wts/latest/wts.cfg
    wait care cell mibsib
    Execute Egate Command    enb_x2_link_up enb=1 target=2
    sleep    10s
    Execute Egate Command    debug_log level=4

wait care cell mibsib
    wait until keyword succeeds    1200    60s    Cells Should Be Onair    cell_id=3    check_sib=${True}    timeout=1600
    wait until keyword succeeds    1200    60s    Cells Should Be Onair    cell_id=2    check_sib=${True}    timeout=1600
    wait until keyword succeeds    1200    60s    Cells Should Be Onair    cell_id=7    check_sib=${True}    timeout=1600
    wait until keyword succeeds    1200    60s    Cells Should Be Onair    cell_id=10    check_sib=${True}    timeout=1600

Make CA call and show traffic
    Setup 4CC UEs
    sleep    60s
    Show each UE traffic pdsch

Get mlstate
    [Arguments]    ${expect_state}=Training    ${expect_inference}=unavailable
    ${mlTrainingState}    Get Scf Parameter Value    NRDU-1:mlScellActParamSet1:mlTrainingState
    Should Be Equal    ${mlTrainingState}    ${expect_state}
    ${mlinferencestate-2}    Get Scf Parameter Value    NRCELL-2:mlScellActParamSet2:mlInferenceState
    Should Be Equal    ${mlinferencestate-2}    ${expect_inference}
    ${mlinferencestate-3}    Get Scf Parameter Value    NRCELL-3:mlScellActParamSet2:mlInferenceState
    Should Be Equal    ${mlinferencestate-3}    ${expect_inference}

Setup 4CC UEs
    UE 4CC 2T2F    ue_id=1
    UE 4CC 2T2F    ue_id=2
    UE 4CC 2T2F    ue_id=10
    UE 4CC 2T2F    ue_id=11
    UE 4CC 2T2F    ue_id=20
    UE 4CC 2T2F    ue_id=21
    UE 4CC 2T2F    ue_id=30
    UE 4CC 2T2F    ue_id=31

UE 4CC 2T2F
    [Arguments]    ${ue_id}=81    ${send_large_traffic}=False    ${target_cell}=3    ${bufferbase}=False    ${carrierfreq}=520110
    Set UE Capability    ue_id=${UE_ID}    UE_Capabilities=${ue_capa_4cc}
    SA UE attach Scell Addition   ue_id=${UE_ID}    cell_id=${target_cell}    carrierfreq=${carrierfreq}
    Traffic Send For UE    ue_id=${UE_ID}    send_large_traffic=${send_large_traffic}    bufferbase=${bufferbase}

UE 4CC 2T2F covBasedA1 and A2release
    [Arguments]    ${ue_id}=81    ${target_cell}=3    ${pdu_id}=1
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${ue_capa_4cc}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${target_cell} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1
    ...    pass_regexp=Initial Context Setup Successful
    Traffic some traffic For UE    ue_id=${ue_id}
    FOR    ${I}    IN RANGE    1    2
      covbaseA1 scell and ulscell active and A2release    ue_id=${ue_id}
    END
    Release ues    ue_type=all

covbaseA1 scell and ulscell active and A2release
    [Arguments]    ${ue_id}=81    ${send_large_traffic}=True    ${pass_regexp}=${ue_4CC_expect_regexp}
    Clear Counter Files
    ${meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    event_type=A1    carrierfreq=520110
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=100
    ...    pass_regexp=${pass_regexp}    timeout=20s
    Traffic Send For UE    ue_id=${ue_id}    send_large_traffic=${send_large_traffic}    bufferbase=True
    Check Counters    ${PM_Counters_Check_2T2F_covbase}
    Release Scell    scell_index=1    scell_id=2    ue_id=${ue_id}
    sleep    7s
    Release Scell    scell_index=2    scell_id=7    ue_id=${ue_id}
    sleep    7s
    Release Scell    scell_index=3    scell_id=10    ue_id=${ue_id}
    sleep    7s


Release Scell
    [Arguments]    ${scell_index}    ${scell_id}    ${ue_id}=81
    ${carrier_freq}     Get From Dictionary    ${CELLS_CARRIER_FREQ}     ${scell_id}
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A2
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_index} scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList

SA CA UE Setup PDU Session
    [Arguments]    ${ue_id}=${SA_UE1_ID}    ${wait_timer}=1    ${cell_id}=1    ${UE_Capabilities}=none
    ...    ${expect_passlog}=QoS Routing Table
    [Return]    ${msg}
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${UE_Capabilities}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered    sleep_time=${wait_timer}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${wait_timer}
    ${msg}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${expect_passlog}
    ...    sleep_time=${wait_timer}

Traffic Send
    [Arguments]    ${ue_id}=81    ${send_large_traffic}=False    ${CC_num}=5    ${bufferbase}=False
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=50    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=9 mbps=3    UE ${ue_id}: UDP UL
    Run Keyword If    ${send_large_traffic}==True    Send More traffic    ue_id=${ue_id}    bufferbase=${bufferbase}
    Run Keyword If    ${send_large_traffic}==True    Wait traffic is as expected    ue_id=${ue_id}    CC_num=${CC_num}

Send More traffic
    [Arguments]    ${ue_id}=81    ${bufferbase}=False
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=10 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=9 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=8 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=7 mbps=150    UE ${ue_id}: UDP DL
    sleep    10s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=6 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=5 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Run Keyword If    ${bufferbase}==True    Send More traffic for bufferbase mode    ue_id=${ue_id}

Send More traffic for bufferbase mode
    [Arguments]    ${ue_id}=81
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=11 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=12 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=13 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=14 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=15 mbps=150    UE ${ue_id}: UDP DL
    sleep    5s

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${ue_capa}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}


Traffic some traffic For UE
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL

Traffic Send For UE
    [Arguments]    ${ue_id}=1    ${send_large_traffic}=False    ${bufferbase}=False
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=10    UE ${ue_id}: UDP UL
    Run Keyword If    ${send_large_traffic}==True    Send More traffic    ue_id=${ue_id}    bufferbase=${bufferbase}
    Run Keyword If    ${send_large_traffic}==True    Wait traffic is as expected    ue_id=${ue_id}

Wait traffic is as expected
    [Arguments]    ${ue_id}=1    ${CC_num}=4
    wait until keyword succeeds    600    10s    Check Traffic    ue_id=${ue_id}    Tput_dl=220    CC_num=${CC_num}

SA UE attach Scell Addition
    [Arguments]    ${ue_id}=1    ${cell_id}=3    ${pdu_id}=1    ${pass_regexp}=${ue_4CC_expect_regexp}    ${carrierfreq}=520110
    Set UE Capability    ue_id=${ue_id}    UE_Capabilities=${ue_capa_4cc}
    sleep    2s
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    sleep    2s
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    sleep    2s
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    sleep    2s
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1
    ...    pass_regexp=Initial Context Setup Successful
    Traffic some traffic For UE    ue_id=${ue_id}
    ${meas_id}    get nr meas id for specific type and frequency    ue_id=${ue_id}    event_type=A1    carrierfreq=${carrierfreq}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100 srsrq_nr=100
    ...    pass_regexp=${pass_regexp}    timeout=20s

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${True}    timeout=600

Check Traffic
    [Arguments]    ${ue_id}=1    ${Tput_dl}=150    ${CC_num}=5
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    ${alldl_tput}    set variable    0
    FOR    ${scellid}    IN RANGE    0    ${CC_num}
        ${scellid}=    convert to string    ${scellid}
        ${ue_id}=    convert to string    ${ue_id}
        ${cell_tput}    Get Scell Throughput    ${ue_id}    ${scellid}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
    END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Get Scell Throughput
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
#    Should Be True    ${scell_tput}/1000 > 0

Show each UE traffic pdsch
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pdsch    Throughput
    Execute Egate Command    ue_stats_nr id=2 scell=0-7 type=pdsch    Throughput
    Execute Egate Command    ue_stats_nr id=10 scell=0-7 type=pdsch    Throughput
    Execute Egate Command    ue_stats_nr id=11 scell=0-7 type=pdsch    Throughput
    Execute Egate Command    ue_stats_nr id=20 scell=0-7 type=pdsch    Throughput
    Execute Egate Command    ue_stats_nr id=21 scell=0-7 type=pdsch    Throughput
    Execute Egate Command    ue_stats_nr id=30 scell=0-7 type=pdsch    Throughput
    Execute Egate Command    ue_stats_nr id=31 scell=0-7 type=pdsch    Throughput

check stable after trained for many UEs
    log to console    check stable after trained for many UEs
    Clear Counter Files
    Setup 4CC UEs
    sleep    60s
    Show each UE traffic pdsch
    Check Counters    ${PM_Counters_Check_after_trained_manyUEs}
    Release ues    ue_type=all




