*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    CRT
...           PY36    RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1
...           NoResUsage


Documentation    :author: Maciej Katra, Michal Fluder
...              :email: maciej.katra@nokia.com, michal.fluder@nokia.com
...              :Description: This testsuite replaces old manual-tested 723-Y testcases
...                            Refined to match ET Scope


Resource    ../../resources/5G_SW_WRO_Keywords.robot
Library     ta5g_tshark

Suite Setup    Run Keywords    Start Default Logging
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=default_phrConfig_0sf_20sf_3dB.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
Suite Teardown    Run Keywords    Find Scfc And Send Delta Commissioning    scfc_filename=default_phrConfig_0sf_20sf_3dB.json
...               AND             Deregister UE Without Confirmation    ue_id=1,2
...               AND             Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***

${DEFAULT_phrConfig_IN_RRCSETUP}=    ${RRC_SETUP} && f1ap.GNB_DU_UE_F1AP_ID == 1 &&
...                      nr-rrc.phr_ProhibitTimer == 0 && nr-rrc.phr_PeriodicTimer == 1 && nr-rrc.phr_Tx_PowerFactorChange == 1
${UPDATED_phrConfig_IN_RRCSETUP}=    ${RRC_SETUP} && f1ap.GNB_DU_UE_F1AP_ID != 1 &&
...                      nr-rrc.phr_ProhibitTimer == 1 && nr-rrc.phr_PeriodicTimer == 2 && nr-rrc.phr_Tx_PowerFactorChange == 2

*** Test Cases ***
5GC000723_Y_Online_Modification_of_Parameters_Power_Headroom
    Attach UE     ue_id=1
    Verify Tcpdump Log    packet_filter=${DEFAULT_phrConfig_IN_RRCSETUP}
    Find Scfc And Send Delta Commissioning    scfc_filename=updated_phrConfig_10sf_50sf_6dB.json
    Attach UE     ue_id=2
    Verify Tcpdump Log    packet_filter=${UPDATED_phrConfig_IN_RRCSETUP}
