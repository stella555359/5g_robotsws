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
CB008235-SR-A_TC_01_cell_onair_with_nrcelltype_8DL8UL
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,11.02.2025,vadivelan.manickavasagam@nokia.com
         ...    To verify two RANK 2 UE pairing

     ${vendor_update}=    Set Variable    yes

     Get cell On Air     iphy=${CFG_CB008235_A_TC_01_IPHY}     scf_delta=${CFG_CB008235_A_TC_01_GNB_SCF}
     ...     cfg=${CFG_CB008235_A_TC_01_WTS}
     ...     vendor_update=${vendor_update}
#     ...     bsr=${CFG_BSR_AVQL_2_H2_A60_60_P02}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Collect And Validate      log=${L_AP_SYS}      element=${VAL_UL_SUBCELLTYPE_C16_8}
     ...     value=none      logfile_with_path=${ONLINE_AP_SYS_LOG}
