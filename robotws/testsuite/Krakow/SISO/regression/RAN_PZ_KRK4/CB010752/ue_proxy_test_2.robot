*** Settings ***
Documentation
...    author: genhao zhai
...    contact: genhao.zhai.ext@nokia-sbell.com
...    Feature: 5GC002097
Library     BuiltIn
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource    taf/rfrl/ue/robot/REAL_UE.robot


*** Variables ***
${SEND_TRUCK_ROLL_EMAIL}         ${False}
*** Test Cases ***

ue_test
    ue.Require UE  UE  capabilities=REAL_ANDROID_UE
    ue.Attach UE    UE
    Start Data Transfer on Real UE    dt_name=DT_UL    ue_alias=UE    direction=ul    protocol=tcp    duration=120s
    ...  tput=60 Mbits/sec
    ...  size_packet=1400B
    #    ...  buffer_client=500K
    #    ...  buffer_server=500K
    ...  parallel_streams=4
    Start Data Transfer on Real UE    dt_name=DT_DL    ue_alias=UE    direction=dl    protocol=tcp    duration=120s
    ...  tput=175 Mbits/sec
    ...  size_packet=1400B
    ...  parallel_streams=4
    ...  linux_congestion=cubic
    Wait for truput stabilization
    ue.Await Data Transfer Finish       dt_name=DT_UL
    ue.Await Data Transfer Finish       dt_name=DT_DL
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=175 Mbits/sec   deviation=10%
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=60 Mbits/sec   deviation=10%

