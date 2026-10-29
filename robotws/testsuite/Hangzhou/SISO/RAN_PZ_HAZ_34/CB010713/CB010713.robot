*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         300 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource             ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
#Resource             ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource             ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource             ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource             ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource             ${BASIC_PATH_5G}/BTS/General_SiSo_RAT_Block_Unblock.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008952_SG05/resource/resource.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008238_A/resource/CB008238_Common_KW.robot
Resource             ./Resource/CB010713_Common_KW.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB010713 NR ABIP BB cell sets 6 cells FR1 TDD eCPRI 16DL in 24R2 program phase which including sub-features:
...    CB010713-SR-A CB010713 NR FR1 TDD ABIP BB cell set type A supporting max 6 cells up to 100MHz 16DL MIMO layers on full ABIP
...                  with 4Rx IRC receiver
...    CB010713-SR-B CB010713 NR FR1 TDD ABIP BB cell set type A supporting max 6 cells up to 100MHz 16DL MIMO layers on full ABIP
...                  with 8Rx IRC receiver(or 8Rx/4Rx mixed IRC receiver)
...    CB010713-SR-C NR FR1 TDD ABIP BB cell set type B supporting max 3 cells up to 100MHz 8DL MIMO layers on half ABIP
...                  with 8Rx IRC receiver(or 8Rx/4Rx mixed IRC receiver)
...    CB010713-SR-D ABIP concurrent mode between CB010713 ABIP BB cell set type B with 8Rx IRC receiver
...                  (or 8Rx/4Rx mixed IRC receiver) and CB009142 ABIP BB cell set
...    CB010713-SR-E ABIP concurrent mode between CB010713 ABIP BB cell set type B with 8Rx IRC receiver
...                  (or 8Rx/4Rx mixed IRC receiver) and CB009014 ABIP BB cell set
...    CB010713-SR-F ABIP concurrent mode between CB010713 ABIP BB cell set type B with 8Rx IRC receiver
...                  (or 8Rx/4Rx mixed IRC receiver) and CB009015 ABIP BB cell set
...    CB010713-SR-G BB cell set change between CB010713 and CB009142 BB cell sets
...    CB010713-SR-Q CSM alignment for ABIQ
...                  (CB010548 NR ABIQ BB cell sets 3 cells FR1 TDD eCPRI 16DL)
...    Configuration:
...                  bbmodBoardConfigType (EQM/APEQM/CABINET/BBMOD) = NRTDD or Auto for -C/D
...                  bbmodBoardConfigType (EQM/APEQM/CABINET/BBMOD) = NRFDD_NRTDD for -E/F/Q
...    swconfig:     with addtional falg BEFORE 24R2 BO: 0x42008C=1  #rd8DL8RxonHalfAbip=true to active CB010713-C(8Rx IRC)
...                                                      0x420089=1  #rd16DLon6SPforABIP=true to active CB010713-A(16DL)

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all

*** Variables ***
@{flagSwconfig}      0x42008C=1   0x420089=1
@{key_flagSwconfig}  0x42008C   0x420089

*** Test Cases ***
# PC and UE to be updated
[1]CB010713-SR-A-01-General_SiSo_Cell_block_and_unblock
    [Documentation]  with addtional falg: 0x420089=1  #rd16DLon6SPforABIP=true active CB010713-A (16DL)
    [Tags]    6S-1CC-16D8U_100M_4Rx-IRC_CB010713-A    CIT_24R2    CRT_TRUNK
#    [Setup]    Run Keywords    CB008238_Common_KW.Update SW Config file on System Module    param_list=${flagSwconfig}
#    ...    AND    SISO Coam Test Setup
    [Setup]    SISO Coam Test Setup
    #General_SiSo_Cell_block_and_unblock    with_call=${False}
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${False}
    [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${49}   AND
    ...    SISO Coam Test Teardown
#    [Teardown]    Run Keywords    CB008238_Common_KW.Update SW Config file on System Module    del_param_list=${key_flagSwconfig}
#    ...    AND    SISO Coam Test Teardown

[1]CB010713-SR-B-24-General_SiSo_RAT_Block_Unblock_with_L3Call
    [Documentation]  with addtional falg: 0x42008C=1  #rd8DL8RxonHalfAbip=true active CB010713-C
    ...                                   0x420089=1  #rd16DLon6SPforABIP=true active CB010713-A (16DL)
    [Tags]    6S-1CC-16D8U_100M_8Rx-IRC_CB010713-B_UC-B-1    CIT_24R2    CRT_TRUNK
#    [Setup]    Run Keywords    CB008238_Common_KW.Update SW Config file on System Module    param_list=${flagSwconfig}
#    ...    AND    SISO Coam Test Setup
    [Setup]    SISO Coam Test Setup
    ${fault_list}    Create List    4614
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RAT_Block_Unblock    with_call=${False}
    [Teardown]    SISO Coam Test Teardown
#    [Teardown]    Run Keywords    CB008238_Common_KW.Update SW Config file on System Module    del_param_list=${key_flagSwconfig}
#    ...    AND    SISO Coam Test Teardown

[1]CB010713-SR-C-01-General_SiSo_Cell_block_and_unblock
    [Documentation]  with addtional falg: 0x42008C=1  #rd8DL8RxonHalfAbip=true active CB010713-C
    [Tags]    3S-1CC-8D8U_100M_8Rx-4Rx-mixedIRC_CB010713-C    CRT_24R2    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    #General_SiSo_Cell_block_and_unblock    with_call=${False}
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${False}
    [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${49}   AND
    ...    SISO Coam Test Teardown

[1]CB010713-SR-D-03-Manual_SiSo_SM_RF_Module_lock_unlock
    [Documentation]  with addtional falg: 0x42008C=1  #rd8DL8RxonHalfAbip=true
    [Tags]    1S-1CC-8RxIRC_2S-4CC-4RxIRC_CB0010713-D_CB009142-A    CRT_24R2    CRT_TRUNK
    [Setup]    Run Keywords    CB008238_Common_KW.Update SW Config file on System Module    param_list=${flagSwconfig}
    ...    AND    SISO Coam Test Setup
    ${radMasterValue}    CB008238_Common_KW.Get AaShell SW Config    rad_param=0x42008C
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
    [Teardown]    Run Keywords    CB008238_Common_KW.Update SW Config file on System Module    del_param_list=${key_flagSwconfig}
    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB010713-SR-E-03-Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]  with addtional falg: 0x42008C=1  #rd8DL8RxonHalfAbip=true
    [Tags]    5S-CB0010713-E_CB009014-A1    CRT_24R2    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Auto_BTS_site_reset    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB010713-SR-F-10-Manual_SiSo_SM_RF_Module_lock_unlock
    [Documentation]  with addtional falg: 0x42008C=1  #rd8DL8RxonHalfAbip=true
    [Tags]    5S-CB0010713-F_CB009015-B    CRT_24R2    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB010713-SR-G-05-BB_cell_set_change_between_CB010713_BB_cell_set_A_and_CB010713_BB_cell_set_B_CB009142_BB_cell_set_A_UC-G-1-5
    [Documentation]  with addtional falg: 0x42008C=1  #rd8DL8RxonHalfAbip=true active CB010713-C (8Rx IRC)
    ...                                   0x420089=1  #rd16DLon6SPforABIP=true active CB010713-A (16DL)
    [Tags]    6S-1CC_100M_4Rx-IRC_CB010713-G_UC-G-1-5    CIT_24R2    CRT_TRUNK
#    [Setup]    Run Keywords    CB008238_Common_KW.Update SW Config file on System Module    param_list=${flagSwconfig}
#    ...    AND    SISO Coam Test Setup
    [Setup]    SISO Coam Test Setup
    Reconfigure 16DL cell to 8DL cell with 4Rx IRC receiver
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown
#    [Teardown]    Run Keywords    CB008238_Common_KW.Update SW Config file on System Module    del_param_list=${key_flagSwconfig}
#    ...    AND    SISO Coam Test Teardown

[1]CB010713-SR-Q-07-General_SiSo_RU_module_reset_from_GUI
    [Documentation]  with addtional falg: 0x42008C=1  #rd8DL8RxonHalfAbip=true
    [Tags]    3S-1CC-16D8U-8D8U_CB010713-Q_CB010548-C    CRT_24R2    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_module_reset_from_GUI    with_call=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

#[1]CB008997-SR_48_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100M+100M_peak_tput
#    [Tags]    1S-2CC-8D4U_A5_100-100M_C2-191_TA-3000    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#    [Teardown]    SISO Coam Test Teardown

