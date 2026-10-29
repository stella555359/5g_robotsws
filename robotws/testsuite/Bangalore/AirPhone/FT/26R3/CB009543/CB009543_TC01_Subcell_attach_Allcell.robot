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

Resource          ./resources/Keywords/CB009543_Keywords.robot
Resource           ../../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/CB009543_variables.robot
Resource          ./resources/Keywords/CB009543_gnbbip_convert.robot
Library          ./resources/Keywords/CB009543_SUBCELL_Validation.py



Suite Setup       CB009543 Suite Setup
Suite Teardown    CB009543 Suite Teardown


*** Test Cases ***
CB009543 TC01 SUBCELL ATTACH ALL CELL
    [Documentation]
         ...    author: shivalingesh.sheelavantar@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,21.01.2026,shivalingesh.sheelavantar@nokia.com
         ...    This is basic L3 Call with new 2026 common keywords

     Get cell On Air        iphy=${CFG_AP_IPHY}       scf_delta=${CB009543_GNB_SCF_DELTA_JSON}        cfg=${CFG_WTS_CFG}
     Start Logs     ${L_GNB_BIP}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     CB009543 PROFILE BASIC UE1
     UE1 UL Data
     UE1 DL Data
     CB009543 PROFILE BASIC UE2
     CB009543 PROFILE BASIC UE3
     CB009543 PROFILE BASIC UE4
     CB009543 PROFILE BASIC UE6
     CB009543 PROFILE BASIC UE7
     CB009543 PROFILE BASIC UE8
     CB009543 PROFILE BASIC UE9
     CB009543 PROFILE BASIC UE10
     CB009543 PROFILE BASIC UE11
     CB009543 PROFILE BASIC UE12
     Stop Logs     ${L_GNB_BIP}
     Convert BIP To CSV By MCShark with column         ${CB009543_BIP_SCN_TC01}/BIP_L1L2.pcap
     ...     ${CB009543_BIP_SCN_TC01}/${BIP_CSV_SUBCELL_1}       filter=${FILTER_CB009543_2}
     ...     csv_title_list=${COLUMN_NAME5}
     ${CSV_FILE_1}=     Set Variable
     ...       /home/ute/logs/CB009543_TC01_SUBCELL_ATTACH_ALL_CELL/gNB/biptaf/TestCase_gnbbip/BIP_L1L2_SUBCELL_1.csv
     ${result}=       Validate Subcells      ${CSV_FILE_1}
     log to console     ${result}
     Should Be Equal    ${result}    4 SUBCELL IDS are DETECTED AND PASSED
