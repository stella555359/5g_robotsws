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
CB008235_D_TC_04_16RX_To Verify IWK with CB010708-D#B6 selection of 16RX MU-IRC receiver for MU-MIMO, 16RX SU-IRC for SU-MIMO UEs
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,11.02.2025,vadivelan.manickavasagam@nokia.com
         ...    To verify Eight RANK 1 UE
     ${vendor_update}=    Set Variable    yes
     Add Rad Param Or Modify GNB swconfig    0x580935=16
     Get cell On Air     iphy=${CFG_CB008235_A_TC_01_IPHY}     scf_delta=${CFG_CB008235_A_TC_02_GNB_SCF}
     ...     cfg=${CFG_CB008235_D_TC_04_WTS}
     ...     vendor_update=${vendor_update}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Collect And Validate      log=${L_GNB_SYS}      element=${VAL_UL_SUBCELLTYPE_C16_8}
     ...     value=none      logfile_with_path=${ONLINE_AP_SYS_LOG}
     Start SOS with BIP     ${sos_script_path}
     CB008235 Ul Sinr Profile Act
     CB008235 SA Call UE1 to UE8
# collect and validate BIP log of gnb for 16RX IRC usage
     Collect And Check gnbBIP     /home/ute/logs/gNBbip/set1/
     Validate 8 UE RANK1 Paired Data Rate
     CB008235 SA Call UE9
     Sleep      1
     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
     Start Logs     ${L_GNB_TTI}
     Sleep      2
     Stop Logs     ${L_GNB_TTI}
     Validate 8UE RANK1 Paired in TTI logs
     CB008235 SA Deregister UE 1 to 8
     CB008235 SA Deregister UE 9

#CB008235_D_TC_04_8RX_To Verify IWK with CB010708-D#B6 selection of 16RX MU-IRC receiver for MU-MIMO, 16RX SU-IRC for SU-MIMO UEs
#    [Documentation]
#         ...    author: vadivelan.manickavasagam@nokia.com
#         ...    history change, <date>,<who>,<what and how>
#         ...    Drafted,11.02.2025,vadivelan.manickavasagam@nokia.com
#         ...    To verify Eight RANK 1 UE
#     ${vendor_update}=    Set Variable    yes
##     Add Rad Param Or Modify GNB swconfig    0x580935=8
##     Get cell On Air     iphy=${CFG_CB008235_A_TC_01_IPHY}     scf_delta=${CFG_CB008235_A_TC_01_GNB_SCF}
#     ...     cfg=${CFG_CB008235_A_TC_04_WTS}
#     ...     vendor_update=${vendor_update}
#     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
#     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
#     Collect And Validate      log=${L_GNB_SYS}      element=${VAL_UL_SUBCELLTYPE_C16_8}
#     ...     value=none      logfile_with_path=${ONLINE_AP_SYS_LOG}
#     Start SOS with BIP     ${sos_script_path}
#     CB008235 Ul Sinr Profile Act
#     CB008235 SA Call UE1 to UE8
# collect and validate BIP log of gnb for 16RX IRC usage 8RX
#     Collect And Check gnbBIP     /home/ute/logs/gNBbip/set1/
#     Validate 8 UE RANK1 Paired Data Rate
#     CB008235 SA Call UE9
#    Sleep      1
#     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
#     Start Logs     ${L_GNB_TTI}
#     Sleep      2
#     Stop Logs     ${L_GNB_TTI}
#     Validate 8UE RANK1 Paired in TTI logs
#     CB008235 SA Deregister UE 1 to 8
#     CB008235 SA Deregister UE 9
