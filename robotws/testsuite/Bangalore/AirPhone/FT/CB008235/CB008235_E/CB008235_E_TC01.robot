*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This script is to validate CB008235-A
                 ...                               03 test cases
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Resource          ../resources/Keywords/CB008235_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          ../resources/Variables/CB008235_variables.robot

Suite Setup       CB008235 Suite Setup
Suite Teardown    CB008235 Suite Teardown

*** Test Cases ***
CB008235_A_004_Eight_Rank1_UEs_with_non_GBR_high_load_are_paired_in_single_cell_AVQL_16TRX_RRU
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,11.02.2025,vadivelan.manickavasagam@nokia.com
         ...    To verify Eight RANK 1 UE
     ${vendor_update}=    Set Variable    yes
     Get cell On Air     iphy=${CFG_CB008235_A_TC_01_IPHY}     scf_delta=${CFG_CB008235_E_TC_01_GNB_SCF}
     ...     cfg=${CFG_CB008235_E_TC_01_WTS}
     ...     vendor_update=${vendor_update}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Collect And Validate      log=${L_GNB_SYS}      element=${VAL_UL_SUBCELLTYPE_C16_8}
     ...     value=none      logfile_with_path=${ONLINE_AP_SYS_LOG}
     Start SOS with BIP     ${sos_script_path}
     CB008235 Ul Sinr Profile Act
     CB008235 SA Call UE1 to UE8
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PUSCHTYPEA_1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PUSCHTYPEA_2}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}

     Sleep      1
     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
     Validate 8 UE RANK1 Paired Data Rate
     Start Logs     ${L_GNB_TTI}
     Sleep      2
     Stop Logs     ${L_GNB_TTI}
     Validate 8UE RANK1 Paired in TTI logs
     CB008235 SA Deregister UE 1 to 8
