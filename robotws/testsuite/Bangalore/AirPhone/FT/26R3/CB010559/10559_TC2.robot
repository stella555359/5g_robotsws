*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : Sharanya
                 ...              :Description  : This script is to validate L3 call in
                 ...                               LO_AP_LO TL with sos report / bip
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Resource          ./resources/Keywords/CB010559_L3_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB010559_L3_variables.robot

Suite Setup       CB010559 Suite Setup
Suite Teardown    CB010559 Suite Teardown

*** Test Cases ***
CB010559 Call Test
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com
         ...    This is basic L3 Call with new 2025 common keywords

#     Start SOS with BIP     ${sos_script_path}
     ${vendor_update}=    Set Variable    yes
#     Start Logs     ${L_AP_GNB_SYS}
     Get cell On Air        iphy=${CB010559_CFG_AP_IPHY_TC02}       scf_delta=${CB010559_CFG_GNB_SCF_2}        cfg=${CFG_WTS_CFG_TC02}
     ...        vendor_update=${vendor_update}
#     ...        bsr=${BSR_FILE_AVQL}
#     Start Logs     ${L_GNB_L3} ${L_WTS_L3}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     CB010559 TC02 TESTCASE
#     Validate     log=${L_EGATE_CONSOLE}      element=${CB010559_TC02_RRC_Reestablishment}
#     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${CB010559_TC02_PATH_SWITCH_REQUEST_Check}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${CB010559_TC02_rrcReconfiguration}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Validate     log=${L_EGATE_CONSOLE}      element=${CB010559_TC02_RetriveUE}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
#     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
#     Stop Logs     ${L_AP_GNB_SYS}
#     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
