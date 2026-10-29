*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    force_reboot=${True}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown    debug
#
#Force Tags         SBTS00    SBTS23R1    SBTS22R4    5GC002534
#...               STATE_CONFIGURED    CRT        RAN_5G    RAN_5G_TDD
#...                 CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#
#*** Variables ***
#${RD_PARAM}            0x58012B=1
#${SCF_PATH}            ./../CUDU_L2/config
#${DELTA_FILE}          Delta_Conf.json
#${UE_ID}               1
#${UE_ID_2}             1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#@{LOG_NAME_LIST}       btslog    bip
#${COUNT}               0
#${dist_name}           MRBTS-1/NRBTS-1/NRCELL-1
#${parameter}           actPdschAtSsbSlots
#${value}               true
#
#
#
#*** Test Cases ***
#5GC002534_A003_Activate_PDSCH_at_SSBslot_20MHz_csirsTrackingPeriod_40ms
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    SA Start DL Traffic    900    10
#    ${Tput_1}    SA Get UE Average Traffic    dl
#    SA Check Average Traffic Bigger Than Target    dl    200
#    SA Stop DL Traffic
#    SA 5G Detach    ${UE_ID}
#    Online Change One Para With Admin    ${dist_name}    ${parameter}    ${value}
#    Sleep    60s    reason=Wait for online changed stable
#    SA 5G Attach    ${UE_ID_2}
#    SA 5G PDU Session Setup    ${UE_ID_2}
#    SA Start DL Traffic    900    10
#    ${Tput_2}    SA Get UE Average Traffic    dl
#    SA Check Average Traffic Bigger Than Target    dl    200
#    SA Stop DL Traffic
#    Should Be True    ${Tput_1}<${Tput_2}    Throughtput is bigger than the ssb not scheduled setting!
