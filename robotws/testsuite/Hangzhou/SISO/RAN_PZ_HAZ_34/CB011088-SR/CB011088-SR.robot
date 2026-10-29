*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout         300 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource             ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource             ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB011088 NR ASOG/H BB cell sets FR1 TDD 4 cells 16DL and 8 cells 8DL in 25R1 program which including sub-features:
...    CB011088-SR-B: CB011088 NR FR1 TDD eCPRI ASOG/H BB cell set type B supporting max 3 cells up to 100MHz 8DL MIMO layers
...                   on half ASOG/H with 8Rx IRC receiver (or 8Rx/4Rx mixed IRC receiver) per BB cell set
...    CB011088-SR-G: ASOG/H concurrent mode between two CB011088 ASOG/H BB cell sets except CB011088 BB cell set type A/F
...
...    Configuration:
...    CB011088-SR-B:
...                  UC-B-3: 3 cells with different cell type and BF type mixing
...                  smodBoardConfigType (EQM/APEQM/CABINET/SMOD/BBCAP) = "NRFDD_NRTDD" or "LTEFDD_NRTDD"
...    CB011088-G-3:
...                  ASOG/H concurrent mode between one CB011088 ASOG/H BB cell set B and one CB011088 BB cell set E
...                  smodBoardConfigType (EQM/APEQM/CABINET/SMOD/BBCAP) = "NRTDD" or "Auto"
...                  3 x NR FR1 TDD eCPRI 8DL cells with 8Rx IRC receiver + 1 x NR FR1 TDD CPRI/eCPRI super cell with 2 sub-cells
...    CB011088-G-5:
...                  ASOG/H concurrent mode between one CB011088 ASOG/H BB cell set C and one CB011088 BB cell set E
...                  smodBoardConfigType (EQM/APEQM/CABINET/SMOD/BBCAP) = "NRTDD" or "Auto"
...                  4 x NR FR1 TDD eCPRI 8DL/4DL cells with 4Rx IRC receiver + 1 x NR FR1 TDD CPRI/eCPRI super cell with 2 sub-cells

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***

*** Test Cases ***
# PC and UE to be updated
[1]CB011088-G3-03_Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    3S-1CC-8D8U_8Rx-IRC_1-SupCell_CB011088-G-3    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Auto_BTS_site_reset    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB011088-G5-02_General_SiSo_Cell_block_and_unblock
    [Tags]    4S-1CC-8D8U_4Rx-IRC_1-SupCell_CB011088-G-5    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Cell_block_and_unblock    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
