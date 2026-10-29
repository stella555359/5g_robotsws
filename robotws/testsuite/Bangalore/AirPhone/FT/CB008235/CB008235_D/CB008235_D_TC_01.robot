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
CB008235_D_TC_01_B1_1_Interworking with CB006062 FDM of DMRS and PUSH data in UL ulDMRSAdditionalPosition pos1
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,17.04.2025,vadivelan.manickavasagam@nokia.com
         ...    To verify IWK 8235 with CB00602 Adaptive Retx enabled
         ...    8 RANK 1 UE NSA  PAIR
#For the UEs whose capability could support two front loaded DMRS symbols,
# "Antenna port(s)" in DCI 1_0 shall follow Table 7.3.1.1.2-12 and Table 7.3.1.1.2-13 in 38.212.
     ${vendor_update}=    Set Variable    yes
     Get cell On Air     iphy=${CFG_CB008235_A_TC_01_IPHY}     scf_delta=${CFG_CB008235_D_TC_01A_GNB_SCF}
     ...     cfg=${CFG_CB008235_A_TC_08_NSA_WTS}
     ...     vendor_update=${vendor_update}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
#     Collect And Validate      log=${L_GNB_SYS}      element=${VAL_UL_SUBCELLTYPE_C16_8}
#     ...     value=none      logfile_with_path=${ONLINE_AP_SYS_LOG}
     Start SOS with BIP     ${sos_script_path}
     CB008235 X2 link up
     CB008235 Ul Sinr Profile Act
     NSA Call UE11 to UE14
     Validate     log=${L_EGATE_CONSOLE}      element=dmrs-AdditionalPosition pos1
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=maxLength len2
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     NSA Call UE15 to UE18
     NSA UE11 to UE18 Beam Pos Activation
     Sleep      5
     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
     Sleep      60
     Start Logs     ${L_GNB_TTI}
     Sleep      1
     Stop Logs     ${L_GNB_TTI}
#    Validation of DMRS , ant port to be added if needed
     Validate 8UE RANK1 Paired in TTI logs
     Validate NSA 8 UE RANK1 Paired Data Rate
     NSA Detach UE11 to UE14
     NSA Detach UE15 to UE18
