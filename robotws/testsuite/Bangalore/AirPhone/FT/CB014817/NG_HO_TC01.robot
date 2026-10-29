*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Deepthi A
                 ...              :contact      : Deepthi A
                 ...              :Description  : This script is to validate NRDC release during HO in
                 ...                               MP_AP_LO TL with sos report / bip
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,28.07.2025,deepthi.a@nokia.com

Resource          ./resources/Keywords/CB014817_Keywords.robot
Resource          ../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB014817_Variables.robot


Suite Setup       L3 Suite Setup
Suite Teardown    L3 Suite Teardown

*** Test Cases ***
CB014871
    [Documentation]
         ...    author: deepthi.a@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,07.08.2025,deepthi.a@nokia.com
         ...    This is Verification of feature activation with new 2025 common keywords

     Start SOS with BIP     ${sos_script_path}
     Start Logs     ${L_AP_GNB_SYS}
     Create Interface for NG HO
     Get cell On Air     iphy=${NG_HO_TC02_IPHY}     scf_delta=${CFG_GNB_SCF_DELTA_JSON}
     ...     cfg=${NG_HO_TC02_CFG}
     Start Logs     ${L_GNB_L3} ${L_WTS_L3}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
	 Attach UE to RANSIM
	 UE Register and PDU Session
	 Send DL Data
	 Send UL Data
	 Configure sourceSCG-NR-Config in HO preparation msg
	 Trigger NG-HO
     Deregister UE
     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
     Stop Logs     ${L_AP_GNB_SYS}
	 Validate     log=${L_GNB_L3}     logfile_with_path=/home/ute/logs/gnbl3/gnbl3.pcap
    ...     filter=ngap          element=nr-rrc.sourceSCG_NR_Config == 08:0d:44:40:e1:c6:32:08:6e:c6:1b:01:18:6a:18
	 Validate     log=${L_GNB_L3}     logfile_with_path=/home/ute/logs/gnbl3/gnbl3.pcap
    ...     filter=ngap          element=nr-rrc.mrdc_SecondaryCellGroupConfig == 0
	 Delete Interface for NG HO
     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
