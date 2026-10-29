*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Sharanya Arvind Bhadrapur
                 ...              :contact      : Sharanya
                 ...              :Description  : This script is to validate L3 call in
                 ...                               LO_AP_LO TL with sos report / bip
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Resource          ./resources/Keywords/L3_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/L3_variables.robot

Suite Setup       L3 Suite Setup
Suite Teardown    L3 Suite Teardown


*** Test Cases ***
L3 Call
    [Documentation]
         ...    author: sharanya.arvind_bhadrapur@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com
         ...    This is basic L3 Call with new 2025 common keywords

#     Start SOS with BIP     ${sos_script_path}
#     Start Logs     ${L_AP_GNB_SYS}

     Get cell On Air     iphy=${CFG_AP_IPHY}     scf_delta=${CFG_GNB_SCF_DELTA_JSON}
     ...     cfg=${CFG_WTS_CFG}

#     Start Logs     ${L_GNB_L3} ${L_WTS_L3}
#     Start Logs     ${L_WTS_L3}
     Sleep    300s

     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
#     UE Register and PDU Session
     Lock cell    MRBTS-1/NRBTS-1/NRCELL-1
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-2
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-3
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-4
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-5
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-6
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-7
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-8
     Sleep    10s
     Unlock cell    MRBTS-1/NRBTS-1/NRCELL-1
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-2
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-3
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-4
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-5
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-6
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-7
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-8
     UE Register and PDU Session for Multiple UEs with Range    1     5
#     UL Data
     Sleep    10s
     Lock cell    MRBTS-1/NRBTS-1/NRCELL-1
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-2
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-3
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-4
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-5
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-6
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-7
	 Lock cell    MRBTS-1/NRBTS-1/NRCELL-8
     Sleep    10s
     Unlock cell    MRBTS-1/NRBTS-1/NRCELL-1
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-2
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-3
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-4
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-5
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-6
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-7
	 Unlock cell    MRBTS-1/NRBTS-1/NRCELL-8
     UE Register and PDU Session for Multiple UEs with Range    1     5
     DL Data for Multiple Cells with Range    1     5     1     5
     Sleep    10s
     Validate     log=${L_EGATE_CONSOLE}      element=${SCELL1_ACTIVATION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${SCELL2_ACTIVATION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${SCELL3_ACTIVATION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${SCELL4_ACTIVATION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${SCELL5_ACTIVATION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${SCELL6_ACTIVATION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${SCELL7_ACTIVATION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     PDSCH throughput
     Validate     log=${L_EGATE_CONSOLE}      element=${CELL_INDEX}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Sleep    60s
     Extract Full Cell Lines
     UE Deregister
#     Stop Logs     ${L_WTS_L3}
#     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
#     Stop Logs     ${L_AP_GNB_SYS}
#     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
