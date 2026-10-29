*** Settings ***
Documentation
...    author:  Aleksandra Bialas
...    maintener: Aleksandra Bialas
...    contact: aleksandra.bialas@nokia.com

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ./Resources/CB008794-B5.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library     ute_ue
Library     testsuite/Krakow/SISO/features/CB008794/8794_keywords.py
Library     testsuite/Krakow/resources/ue_proxy_wsl/ue_proxy_wsl.py

Suite Setup      Common Suite Setup With OnAir Test Line Preparation
...  swconfig_from_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
Suite Teardown   Common Suite Teardown
Test Setup       Run Keywords
...              start ue proxy on ue pc
...              AND  ute_ue.Require UE     UE     capabilities=QUECTEL_UE
...              AND  Common Preconditions With Watching Alarms
...              AND  CB008794-B5_1_RFC2.0_unencrypted_Private_Keys_and_access_right_check
...              AND  CB008794-B5_2_RFC2.0_Default_users_password_check_unprotected_files
...              AND  CB008794-B5_3_RFC2.0_Local_Account_Check_for_No_Extra_users
...              AND  CB008794-B5_4_RFC2.0_Authorization_policy
...              AND  CB008794-B5_9_RFC2.0_Check_Authorization_Privileges
...              AND  CB008794-B5_13_RFC2.0_Check_Only_Exe_Rights_In_CGI_Scripting_Directory
Test Teardown    Run Keywords
...              ute_ue.Stop Using Ue    UE
...              AND  stop ue proxy on ue pc
...              AND  Set attenuator configuration    attenuation_config=CB008794_att_default
...              AND  Common Postconditions With Watching Alarms


*** Variables ***
${gnb_id}                               ${tl.gnbs[0].dus[0].global_bts_id}

*** Test Cases ***
[1][1.0] CB008794-A_07_ASiR site startup with 5G TDD 4 1 frame structure RFC cell from APHH
    Set attenuator configuration    attenuation_config=CB008794_att_cell_22
    ute_ue.Attach UE    UE
    check_cell_id    ue_alias=UE    expected_cell_id=1248198678
    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=UE
    ...                           direction=dl
    ...                           duration=60s
    ...                           packet=1400B
    ...                           throughput=25 MBytes/sec
    ...                           protocol=tcp
    ...                           parallel_streams=2
    ...                           max_segment_size=1408
    ute_ue.Await Data Transfer Finish       dt_name=DT_DL
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=25 MBytes/sec   deviation=20%
    ute_ue.Detach Ue     UE
    Set attenuator configuration    attenuation_config=CB008794_att_cell_230
    ute_ue.Attach UE    UE
    check_cell_id    ue_alias=UE    expected_cell_id=1248198886
    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=UE
    ...                           direction=dl
    ...                           duration=60s
    ...                           packet=1400B
    ...                           throughput=175 MBytes/sec
    ...                           protocol=tcp
    ...                           parallel_streams=2
    ...                           max_segment_size=1408
    ute_ue.Await Data Transfer Finish       dt_name=DT_DL
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=175 MBytes/sec   deviation=20%
    ute_ue.Detach Ue     UE
    Set attenuator configuration    attenuation_config=CB008794_att_cell_0
    ute_ue.Attach UE    UE
    check_cell_id    ue_alias=UE    expected_cell_id=1248165888
    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=UE
    ...                           direction=dl
    ...                           duration=60s
    ...                           packet=1400B
    ...                           throughput=55 MBytes/sec
    ...                           protocol=tcp
    ...                           parallel_streams=2
    ...                           max_segment_size=1408
    ute_ue.Await Data Transfer Finish       dt_name=DT_DL
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=55 MBytes/sec   deviation=20%
    ute_ue.Detach Ue     UE
    check_snapshot_8794
