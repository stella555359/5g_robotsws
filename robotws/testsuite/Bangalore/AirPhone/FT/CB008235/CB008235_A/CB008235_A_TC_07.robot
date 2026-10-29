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
CB008235_A_007_SU_MU_MIMO_MIX_8_RANK2_UEs
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,11.02.2025,vadivelan.manickavasagam@nokia.com
         ...    To verify RANK 2 UE pairing with UE 1 - 4 : 2 FL UL DMRS
         ...    UE 5 , 6, 8 : 1 FL UL DMRS
         ...    UE 7 : 2 FL UL DMRS
         ...    UE 1 to 4 : PAIRED ; UE 5 , UE 6 : PAIRED ; UE 7, 8 : SUMIMIO No Pairing FDMed.

     ${vendor_update}=    Set Variable    yes
     Get cell On Air     iphy=${CFG_CB008235_A_TC_01_IPHY}     scf_delta=${CFG_CB008235_A_TC_02_GNB_SCF}
     ...     cfg=${CFG_CB008235_A_TC_07_WTS}
     ...     vendor_update=${vendor_update}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Collect And Validate      log=${L_GNB_SYS}      element=${VAL_UL_SUBCELLTYPE_C16_8}
     ...     value=none      logfile_with_path=${ONLINE_AP_SYS_LOG}
     CB008235 SA Call UE1 to UE8
     Sleep      1
     Validate UE1 To UE4 Paired Data Rate
     Validate UE5 UE6 RANK2 Paired Data Rate
     Validate UE7 UE8 In SUMIMO Data Rate
#     Start Logs     ${L_GNB_TTI}
#     Sleep      2
#     Stop Logs     ${L_GNB_TTI}
#     Validate CB008235 TC07 TTI Logs For Pairing
     CB008235 SA Deregister UE 1 to 8
