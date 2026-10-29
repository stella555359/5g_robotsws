*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case for UTE regression
Resource          ../Resources/common_resource.robot
# Resource          ../Resources/ute_case_common_resource.robot
Library           ute_ue
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown    TL Suite Teardown
Test Setup        _Create Test Directory
Test Teardown     TL Test Teardown
Force Tags              CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIP2_AZHM_AHEGB-ASILR_ABIP2_AZHL_AHEGB
# ...                     SBTS22R4
...                     SBTS00
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
Test Timeout            75h
*** Variables ***
&{Init_Enviroment}      IP=10.56.198.130
...                     USERNAME=root
...                     PASSWORD=uteadmin
...                     Reinstall_Script_Path=${/}root${/}scripts
...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg
${testline_configuration_path}    ~${/}testline_configuration
#storge case file info and path case file : { case path : path, case list: case list}
&{Upgrade_Case_Info}      Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
...                       Case_Tag=Upgrade
&{Rollback_Case_Info}    Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
&{CB008325_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008325${/}CB008325.robot
&{CB005825_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB005825${/}CB005825.robot
&{CB007332_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB007332${/}CB007332.robot
&{CB008541_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008541${/}CB008541.robot
&{CB007742_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB007742${/}CB007742.robot
&{CB009059-D_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB009059-D${/}CB009059-D.robot
&{CB008880_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008880${/}CB008880.robot
&{CB008242_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB008242${/}CB008242.robot
&{CB012582_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB012582-ST${/}CB012582_ST.robot
&{CB012474_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB012474${/}CB012474.robot
&{CNI138886_Case_Info}   Case_Path=${CURDIR}${/}..${/}CNI138886${/}CNI138886.robot
&{Feature_File_INFO}
...    Rollback=&{Rollback_Case_Info}
...    Upgrade=&{Upgrade_Case_Info}
...    CB008325=&{CB008325_Case_Info}
...    CB005825=&{CB005825_Case_Info}
...    CB007332=&{CB007332_Case_Info}
...    CB008541=&{CB008541_Case_Info}
...    CB007742=&{CB007742_Case_Info}
...    CB009059-D=&{CB009059-D_Case_Info}
...    CB008880=&{CB008880_Case_Info}
...    CB008242=&{CB008242_Case_Info}
...    CB012582=&{CB012582_Case_Info}
...    CB012474=&{CB012474_Case_Info}
...    CNI138886=&{CNI138886_Case_Info}
*** Test Cases ***
Init Enviroment
    ReInstall Vm    ${False}
Rollback For Local
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Rollback
Rollback For Remote GNBs
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Rollback
Upgrade
    Compare Release And Choose Suitable Upgrade
    Run Feature Case
CB008325_07_CB007333_Automatic X2 setup for new enbControlled LNADJGNB with IP address retrieval of gNB via S1 interface
    Run Feature Case    CB008325
CB008325_03_ABIP_ENDC mobility_inter_eNB x2 handover
    Run Feature Case    CB008325
# CB005825_17_PLMN selection for NR handover
#     Run Feature Case    CB005825
# CB005825_02_NR neighbor creation when number of unknown B2-NR MRs has crossed threshold no confusion detected
#     Run Feature Case    CB005825
# CB005825_03_NR neighbor creation when number of unknown B2-NR MRs has crossed threshold B1-NR MR already reported
#     Run Feature Case    CB005825
# CB005825_05_LNRELN removal due to insufficient frequency of reports
#     Run Feature Case    CB005825
# CB005825_06_Periodic LNADJN and LNADJNL removal due to no matching LNRELN found
#     Run Feature Case    CB005825
# CB005825_07_NR handover neighbor re-validation when anrNrNbrHoRelVerifyPeriod has elapsed
#     Run Feature Case    CB005825
# CB005825_16_CGI report to be used for both CB007334 and CB005825
#     Run Feature Case    CB005825
# CB005825_13_Verify fault reporting when LNADJL exceeds limit
#     Run Feature Case    CB005825
# CB005825_19_Activation and configuration of ANR for LTE-5G Standalone
#     Run Feature Case    CB005825
CB007332_01_UL data buffer based EN-DC setup without ULCA configured on UE-FDD
    Run Feature Case    CB007332
CB007332_05_UL data buffer based EN-DC setup with ULCA already configured on UE-FDD
    Run Feature Case    CB007332
# CB007332_09_UL data buffer based EN-DC setup interworking with mrWaitTimer setting when lower priority MR received firstly
#     Run Feature Case    CB007332
# CB007332_12_Activation and configuration of feature CB007332 - UL data buffer trigger for EN-DC
#     Run Feature Case    CB007332
CB008541-A_01_SA_2CC_Feature activation and deactivation of the CB008541 feature and Counters update
    Run Feature Case    CB008541
# CB008541-A_05_SA Feature activation and deactivation of the CB008541 feature
#     Run Feature Case    CB008541
# CB007742-SR_22_Handover to 5G-SA non EN-DC case
#     Run Feature Case    CB007742
# CB007742-SR_23_Handover to 5G-SA EN-DC case
#     Run Feature Case    CB007742
# CB007742-SR_24_Legacy PM counter update for handover from LTE to NR without VoLTE
#     Run Feature Case    CB007742
# CB007742-SR_27_New PM counter update for handover from LTE to NR without VoLTE
#     Run Feature Case    CB007742
CB009059_D_02_Interaction of inter-gNB CA release when at least one PDU session modification with CA incompatible DRB addition
    Run Feature Case    CB009059-D
CB009059_BC_01_Interaction with mobility using blind SCell Addition method UE intra-NR incoming handover from other cell
    Run Feature Case    CB009059-D
# CB009059_BF_01_cellAggrLevel is not considered in NSA CA
#     Run Feature Case    CB009059-D
# CB009059_BG_02_Interaction with inter-gNB CA - check Scell addition after PDU modification for different DRBs
#     Run Feature Case    CB009059-D
Case3_Reconfiguration_of_existing_LTE_or_NR_cells_addition_of_cells_or_deletion_of_cells_from_WEBEM
    Run Feature Case    CB008880
CB008242-SR_B_01_01 Upgrade auto UAC triggered by number of RRC connections with static UAC
    Run Feature Case    CB008242
CB008242-SR_E_09_01 gNB stops reserving the cell for operator use for PLMNs when gNB stops max autoUAC
    Run Feature Case    CB008242
CB012582_D_01 Counter update for successful RRC Connection procedures with setup request cause mo_signalling
    Run Feature Case    CB012582
CB012582_A_01 IRAT handover from LTE to SA HO Interruption time Target Range
    Run Feature Case    CB012582
CB012582_B_01 SA in-session 5QI-1 QoS Flow duration update during normal VoNR call
    Run Feature Case    CB012582
CB012582_C_02 VoNR DL and UL MCS counters with 256QAM
    Run Feature Case    CB012582
CB012474_04_Successful reattempt of EN-DC Configuration Update procedure and completion of cell addition upon reattempt timer expiry
    Run Feature Case    CB012474
CB012474_03_CB012474 new counter update check
    Run Feature Case    CB012474
CB012474_16_Successful reattempt of EN-DC Configuration Update procedure with subsequent cell reconfiguration while reattempt timer is running
    Run Feature Case    CB012474
CNI-138886_06_Online modification for feature flag actRlcUmSegSnMgmt
    Run Feature Case    CNI138886