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

Resource          ./resources/Keywords/CB009527_D_Keywords.robot
Resource          ../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB009527_D_variable.robot

Suite Setup       CB009527 Suite Setup
Suite Teardown    CB009527 Suite Teardown

*** Test Cases ***
CB009527-E
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,11.02.2025,vadivelan.manickavasagam@nokia.com
         ...    To verify two RANK 2 UE pairing

     ${vendor_update}=    Set Variable    yes
     Start SOS with BIP     ${sos_script_path}
     Start Logs     ${L_AP_GNB_SYS}
     Get cell On Air      iphy=${CB009527_AP_IPHY}        scf_delta=${CB009527_E_GNB_DELTA_JSON}
     ...     cfg=${CB009527_CFG_WTS}
     ...     vendor_update=${vendor_update}
     ...     bsr=${BSR_FILE_CB009527_AVQL}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     UE1 Register and PDU Session
     CB009527 UE1 Data
     CB009527 D5 eCPRI WBtoSB SRS UE1
     UE2 Register and PDU Session
     CB009527 UE2 Data
     CB009527 D5 eCPRI WBtoSB SRS UE2
     UE3 Register and PDU Session
     CB009527 UE3 Data
     CB009527 D5 eCPRI WBtoSB SRS UE3
     UE4 Register and PDU Session
     CB009527 UE4 Data
     CB009527 D5 eCPRI WBtoSB SRS UE4
     UE5 Register and PDU Session
     CB009527 UE5 Data
     CB009527 D5 eCPRI WBtoSB SRS UE5
     UE6 Register and PDU Session
     CB009527 UE6 Data
     CB009527 D5 eCPRI WBtoSB SRS UE5
     UE7 Register and PDU Session
     CB009527 UE7 Data
     CB009527 D5 eCPRI WBtoSB SRS UE5
     UE8 Register and PDU Session
     CB009527 UE8 Data
     CB009527 D5 eCPRI WBtoSB SRS UE5
     UE9 Register and PDU Session
     CB009527 UE9 Data
     CB009527 D5 eCPRI WBtoSB SRS UE5
     UE10 Register and PDU Session
     CB009527 UE10 Data
     CB009527 D5 eCPRI WBtoSB SRS UE5
     UE11 Register and PDU Session
     CB009527 UE11 Data
     CB009527 D5 eCPRI WBtoSB SRS UE5
     UE12 Register and PDU Session
     CB009527 UE12 Data
     CB009527 D5 eCPRI WBtoSB SRS UE5
     UE13 Register and PDU Session
     CB009527 UE13 Data
     CB009527 D5 eCPRI WBtoSB SRS UE5
     UE14 Register and PDU Session
     CB009527 UE14 Data
     CB009527 D5 eCPRI WBtoSB SRS UE5
     UE15 Register and PDU Session
     CB009527 UE15 Data
     CB009527 D5 eCPRI WBtoSB SRS UE5
     UE16 Register and PDU Session
     CB009527 UE16 Data
     CB009527 D5 eCPRI WBtoSB SRS UE5
     Verifying the Counter for CB009527
