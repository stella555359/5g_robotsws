*** Settings ***
Library   ute_ue    WITH NAME    ue
Library   taf/rfrl/bts/devices/ru/ru_operations.py
Library   ./keywords.py
Library   taf.rfrl.bts.commissioning
Resource  taf/rfrl/bts/robot/gnb.robot
Resource  taf/rfrl/bts/robot/logs_collecting.robot

*** Variables ***
${capabilities_ue}     REAL_UE
${message}             Received X2AP SgNbReconfigurationComplete
${log}                 /tmp/startup_cp_ue.log


*** Keywords ***
Start DL and UL Data Transfer
    [Arguments]  ${duration}=150s    ${tpt_dl}=200 Mbits/sec    ${tpt_ul}=50 Mbits/sec    ${protocol}=udp
    ...          ${deviation}=30%
    Prepare UE
    ue.Reboot Ue    UE       timeout=120
    Sleep  5
    ue.Detach Ue  UE
    Sleep  10
    ue.Attach Ue    UE
    Start DL Data Transfer   duration=${duration}   throughput=${tpt_dl}
    ...                      protocol=${protocol}   deviation=${deviation}
    Sleep   10
    Start UL Data Transfer   duration=${duration}   throughput=${tpt_ul}
    ...                      protocol=${protocol}   deviation=${deviation}
    ue.Detach Ue    UE

Attach and Detach
    Prepare UE
    ue.Attach Ue  UE
    Sleep  10
    ue.Detach Ue  UE

Prepare UE
    ue.Require UE  UE  capabilities=${capabilities_ue}

Start DL Data Transfer
    [Arguments]  ${duration}    ${throughput}    ${protocol}    ${deviation}    ${ue_alias}=UE
    ...          ${parallel_streams}=1
    ue.Start Data Transfer    dt_name=DT_DL   ue_alias=${ue_alias}    direction=dl    duration=${duration}
    ...          throughput=${throughput}   protocol=${protocol}    parallel_streams=${parallel_streams}
    ue.Check Data Transfer is Alive   dt_name=DT_DL
    ue.Await Data Transfer Finish    dt_name=DT_DL
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${throughput}   deviation=${deviation}

Start UL Data Transfer
    [Arguments]  ${duration}    ${throughput}    ${protocol}    ${deviation}    ${ue_alias}=UE
    ...          ${parallel_streams}=1
    ue.Start Data Transfer    dt_name=DT_UL   ue_alias=${ue_alias}    direction=ul    duration=${duration}
    ...          throughput=${throughput}    protocol=${protocol}    parallel_streams=${parallel_streams}
    ue.Check Data Transfer is Alive  dt_name=DT_UL
    ue.Await Data Transfer Finish    dt_name=DT_UL
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${throughput}   deviation=${deviation}

Lock Unlock Cells
    Lock All Cells
    Verify All Cells Are Locked
    Unlock All Cells
    Verify All Cells Are Unlocked
    Wait For Site To Be Onair

Perform RU reset
    Reset gNB Radio Unit from GUI
    Sleep    30
    Wait For Site To Be Onair

Perform gNB reset
    Reset gNB
    Sleep  30
    Wait For Site To Be Onair

Verify SgNBAddition
    [Arguments]    ${msg}=${message}
    Reset CU
    Sleep   30
    Wait For Site To Be Onair
    Prepare UE
    ue.Attach Ue    UE
    Start DL Data Transfer   duration=30s  throughput=200 Mbits/sec   protocol=udp   deviation=10%
    Verify Message in Log      log_name=${log}     msg=${msg}
    ue.Detach Ue    UE
