*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO


Documentation    :copyright: Nokia
...              :authors: Andrzej Stachowiak
...              :contact: andrzej.stachowiak@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/traffic.robot
Resource    ../keywords/tshark_verifying.robot
Resource     CB009854_keywords.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    ta5g_global_var
Library      ta5g_ue_mobility


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB009854_B9b_AP_LOO.xml
...            AND             Find Scfc And Fix And Send Full Commissioning
...    scf_CB009854_B9b_AP_LOO.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${BASIC_SETUP}=       ${CURDIR}/config/wts_9854_AA_B9b_AP_LOO.cfg
${UE_ID}=   3
${A1_meas_id}=   1
${A6_meas_id}=   2
${Veryfication_A6_measurement}=
...    nr-rrc.measResultServingMOList == 5 &&
...    nr-rrc.physCellId == 53 &&
...    nr-rrc.physCellId == 51 &&
...    nr-rrc.physCellId == 52 &&
...    nr-rrc.physCellId == 54 &&
...    nr-rrc.physCellId == 55 &&
...    nr-rrc.measResultListNR == 1 &&
...    nr-rrc.physCellId == 56
${Veryfication_scell_swap}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.sCellToAddModList == 1 &&
...    nr-rrc.sCellIndex == 5 &&
...    nr-rrc.physCellId == 56 &&
...    nr-rrc.absoluteFrequencySSB == 506430 &&
...    nr-rrc.FreqBandIndicatorNR == 41 &&
...    nr-rrc.sCellToReleaseList == 1 &&
...    nr-rrc.SCellIndex == 3
${A6_cmd}=
...  id=${UE_ID} meas_id=${A6_meas_id} event=A6 srsrp_nr=70 srsrq_nr=70 scell=1 scell_rsrp=20 scell_rsrq=20
...  scell=2 scell_rsrp=20 scell_rsrq=20
...  scell=3 scell_rsrp=20 scell_rsrq=20
...  scell=4 scell_rsrp=20 scell_rsrq=20
...  phycell_id=56 nrsrp_nr=90 nrsrq_nr=95


*** Test Cases ***
CB009854-AA-B9b_SCell_Swap_is_performed_to_lower_priority_SCell_based_on_A6_measurement_while_maintaining_5CC_DL_CA_with_3_FDD_and_2_TDD_serving_cells
    Register UE To gNB    UE_Id=${UE_ID}
    Trigger A1 Measurement    ue_id=${UE_ID}     meas_id=${A1_meas_id}
    Start Data Traffic
    Verify If Traffic Is Scheduled On All Cells 5CC DL And 2CC UL
    Trigger A6 Measurement    A6_cmd=${A6_cmd}
    Verify A6 Measurement    Verify_A6_Measurement=${Veryfication_A6_measurement}
    Verify Scell Swap    Verify_Scell_Swap=${Veryfication_scell_swap}

*** Keywords ***
Verify If Traffic Is Scheduled On All Cells 5CC DL And 2CC UL
    Verify DL Traffic Is Scheduled On All Cells 5CC
    Sleep    10s
    Verify UL Traffic Is Scheduled On All Cells 2CC
