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
         ...    To verify two RANK 2 UE switching with PM counter check

     ${vendor_update}=    Set Variable    yes
     Log to Console         PM Check Testcase is started :) :)\n
     Get cell On Air      iphy=${CB009527_AP_IPHY}        scf_delta=${CB009527_E_GNB_DELTA_JSON}
     ...     cfg=${CB009527_CFG_WTS}
     ...     vendor_update=${vendor_update}
     ...     bsr=${BSR_FILE_CB009527_AVQL}
     Log to console        Cell is On AIR Check the MIB SIB..!\n
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_SIB1}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Log to console        Cell is on AIR now :) :) MIB SIB is verified :) :)..!\n
     UE1 Register and PDU Session
     Log to console        UE1 Registration completed :)!\n
     CB009527 UE1 Data
     Log to console        UE1 Data is Pumped :)!\n
     CB009527 D5 eCPRI WBtoSB SRS UE1
     Log to console        UE1 CB009527 Basic cmd WBtoSB commands are executed and checked :) :)!\n
     Log to Console     PM Counter Check\n
     PM Check passing dictionary
     Verifying the Counter for CB009527
     ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
     PM Check passing dictionary validate
     Wait For Next Full Pm Interval
     Fetch Key And Value From Dictionary
     Log to Console     Starting log collection\n


