*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : Sharanya
                 ...              :Description  : This script is to validate L3 call in
                 ...                               LO_AP_LO TL with sos report / bip
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Resource          ./resources/Keywords/L3_Keywords.robot
Resource          ../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/L3_variables.robot

Suite Setup       L3 Suite Setup
Suite Teardown    L3 Suite Teardown

*** Test Cases ***
CNI122836
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com
         ...    This is basic L3 Call with new 2025 common keywords

#     Start SOS with BIP     ${sos_script_path}
     Start Logs     ${L_AP_GNB_SYS}
     Get cell On Air     iphy=${CFG_AP_IPHY}    scf_delta=${CFG_GNB_SCF_DELTA_JSON}
     ...     cfg=${CFG_WTS_CFG}
     Start Logs     ${L_GNB_L3} ${L_WTS_L3}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE1 Register and PDU Session
     UE1 UL Data
     UE1 DL Data
     UE1 SRB2 drop 1st time
     UE1 SRB2 drop 2nd time
     UE1 Deregister
     UE2 Register and PDU Session
     UE2 UL Data
     UE2 DL Data
     UE2 SRB2 drop 1st time
     UE2 SRB2 drop 2nd time
     UE2 Deregister
     UE3 Register and PDU Session
     UE3 UL Data
     UE3 DL Data
     UE3 SRB2 drop 1st time
     UE3 SRB2 drop 2nd time
     UE3 Deregister
     Stop Logs     ${L_GNB_L3} ${L_WTS_L3}
     Stop Logs     ${L_AP_GNB_SYS}
#     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
