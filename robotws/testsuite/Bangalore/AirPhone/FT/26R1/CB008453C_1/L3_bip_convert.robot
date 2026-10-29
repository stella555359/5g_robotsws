*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD
...           SBTS00     CONFIGURED

Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : Sharanya Arvind Bhadrapur
                 ...              :Description  : This script is to validate CB008235-A
                 ...                               03 test cases
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com

Resource          ./resources/Keywords/L3_Keywords.robot
Resource          ../../resources/Variables/general_common_variables.robot
Resource          ./resources/Variables/L3_variables.robot

Suite Setup       L3 Suite Setup
#Suite Teardown    L3 Suite Teardown

*** Test Cases ***
L3 Call
    [Documentation]
         ...    author: vadivelan.manickavasagam@nokia.com
         ...    history change, <date>,<who>,<what and how>
         ...    Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com
         ...    This is basic L3 Call with new 2025 common keywords
     Get cell On Air     iphy=${CFG_AP_IPHY}     scf_delta=${CFG_GNB_SCF_DELTA_JSON}
     ...     cfg=${CFG_WTS_CFG}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Sleep     30
     Start Logs     ${L_GNB_BIP}
     UE Register and PDU Session
     UL Data
     DL Data
     Collect BIP and decode          test_scenario=TestCase_gnbbip
     UE Deregister
     Sleep     120
     Stop Logs     ${L_GNB_BIP}
     Convert BIP To CSV By MCShark       bip_file=${path_SCN_1}/BIP_L1L2.pcap     output_file=${path_SCN_1}/${BIP_CSV_NAME}
     ...                              filter=${FILTER_B005}    csv_title_list=${COLUMN_NAME}
