*** Settings ***
Documentation
...    author:  Aleksandra Bialas
...    maintener: Aleksandra Bialas
...    contact: aleksandra.bialas@nokia.com

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library     testsuite/Krakow/resources/ue_proxy_wsl/ue_proxy_wsl.py
Library     taf.rfrl.bts.devices.ru.ru_operations
Library     taf.rfrl.bts.devices.du.cell_operations
Library     ute_ue

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...  swconfig_from_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
Suite Teardown    Common Suite Teardown
Test Setup        7536_preconditions
Test Teardown     7536_postconditions


*** Test Cases ***
Common_SiSo_State Management_Cell block_Then_RF reset_Then_Cell unblock
    ute_ue.Require UE     UE     capabilities=QUECTEL_UE
    ute_ue.Attach UE    UE
    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=UE
    ...                           direction=dl
    ...                           duration=60s
    ...                           packet=1400B
    ...                           protocol=tcp
    ...                           parallel_streams=2
    ute_ue.Await Data Transfer Finish       dt_name=DT_DL
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_DL    tput=90000 kbits/sec    deviation=35%
    ute_ue.Detach Ue     UE
    gnb_cells.block_all_cells
    gnb_cells.verify_all_cells_are_blocked
    Reset both APHGs
    wait until keyword succeeds    5min    10sec    gnbru.verify_all_radio_units_statuses    operational_state=enabled
    ...    procedural_status=configured
    ...    administrative_state=unlocked
    ...    usage_state=idle
    gnb_cells.unblock_all_cells
    Wait Until Keyword Succeeds     300 sec     5 sec    gnb_cells.Verify All Cells Are Onair
    ute_ue.Attach UE    UE
    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=UE
    ...                           direction=dl
    ...                           duration=60s
    ...                           packet=1400B
    ...                           protocol=tcp
    ...                           parallel_streams=2
    ute_ue.Await Data Transfer Finish       dt_name=DT_DL
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_DL    tput=90000 kbits/sec    deviation=35%
    ute_ue.Detach Ue     UE


*** Keywords ***
Reset both APHGs
     gnbru.Reset Radio Unit    radio_unit_id=2
     gnbru.Reset Radio Unit    radio_unit_id=1

7536_preconditions
    Common Preconditions
    start_ue_proxy_on_ue_pc

7536_postconditions
    Common Postconditions
    ute_ue.Stop Using Ue     UE
    stop_ue_proxy_on_ue_pc
