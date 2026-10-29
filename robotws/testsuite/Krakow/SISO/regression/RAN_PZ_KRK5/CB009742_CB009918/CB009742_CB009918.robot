*** Settings ***
Documentation
...   Test suite for regression testing of CB009742 and CB009918
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/bts/robot/common/gnb_cell.robot
Resource     taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
#Resource     taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Resource     taf/rfrl/procedures/resources/robot/LogCollection.robot
Resource     ./resources/common_keywords.robot
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                 WITH NAME    alarm
Library      taf.rfrl.utilities.logger.custom_logger                                    WITH NAME    logger
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py

Suite Setup        Prepare both gnbs
Suite Teardown     Common Suite Teardown

*** Variables ***
@{All_cells}                LNCEL-21     NRCELL-24
@{LTE_cell}                 LNCEL-21
@{NR_cell}                  NRCELL-24
@{RFC_cell}                 NRCELL-24_1
@{pRRH_ANTENNA_PORTS_BTS1}       ASI-1/ASI_R-1/HUBMOD_R-1/ANTPORT_R-1
...                              ASI-1/ASI_R-1/HUBMOD_R-1/ANTPORT_R-2
...                              ASI-1/ASI_R-1/HUBMOD_R-2/ANTPORT_R-1

@{pRRH_ANTENNA_PORTS_BTS2}       ASI-1/ASI_R-1/HUBMOD_R-1/ANTPORT_R-1
...                              ASI-1/ASI_R-1/HUBMOD_R-2/ANTPORT_R-2

${capabilities}             REAL_UE
@{cells_alarm1}             11    12    13    24
@{cells_alarm2}             12    21    24    25    31
@{cells_alarm_diff}         11    13

@{cells_alarm1_lte_only}             11    12
@{cells_alarm2_lte_only}             12    21
@{cells_alarm_diff_lte_only}         11


@{cells_psgrp}             12    24
@{cells_eeagrp}            13    25     31    11   21

@{cells_psgrp_after_reconfig}             12    24     13     11
@{cells_eeagrp_after_reconfig}            25    31    21

#### Setting used for TC: CB009742_moving_cells_from_PSGRP_to_EEAGRP #########

@{cells_energysaving}            12    24     13     11    25    31    21

*** Test Cases ***


# Turn test line on
#    Turn test line on


CB009742-A_Time-based_energy_saving_for_RFCCELLs_in_ASiR
    [Setup]    Actions before test on second gnb        alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Test1]
    Verify rfc cells energy saving state     energy_saving_state=notEnergySaving
    ${measurements}=	Create Dictionary
    ${measurements}=    Get hubs average power consumption     measurements=${measurements}
    ...                                                        power_savings_status=notEnergySaving     bts_id=1
    Activate power savings in asir for rfc
    BuiltIn.Sleep     30s
    Verify rfc cells energy saving state     energy_saving_state=energySaving
    Verify number of rfc cells
    Verify tbEnergySavingEnabled state of rfc cells     tbEnergySavingEnabled=true
    Reset all asir hubs     bts_id=1
    BuiltIn.Sleep     180s
    Verify rfc cells energy saving state     energy_saving_state=energySaving
    ${measurements}=     Get hubs average power consumption     measurements=${measurements}
    ...                                                         power_savings_status=EnergySaving     bts_id=1
    Compare power consumption     measurements=${measurements}     reduction=20%
    Activate power savings in hubs     bts_id=1
    BuiltIn.Sleep     360s
    Wait Until Keyword Succeeds    300 sec    30 sec
    ...     Verify poe status     bts_id=1     antenna_ports=@{pRRH_ANTENNA_PORTS_BTS2}
    Dectivate power savings in asir for rfc
    BuiltIn.Sleep     120s
    Verify rfc cells energy saving state     energy_saving_state=notEnergySaving
    Verify all rfc cells are operational     bts_id=1
    Reset ue proxy
    Run keyword And Continue On Failure     Action with ue      CellIDs=${RFC_cell}
    ...                                                         duration=120s     action=CALL
    [Teardown]    Actions after test on second gnb

CB009742-B_ASiR_Energy-efficient_emergency_activation
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Test1]
    Verify cells energy saving state     energy_saving_state=notEnergySaving
    logger.log_info_to_console    Waiting for next full PM period
    gnb_counter.Wait for PM measurements    interval=15min    measurements=0
    ${measurements}=	Create Dictionary
    ${measurements}=     Get BTS counter with energy consumption    measurements=${measurements}
    ...                                                             power_savings_status=notEnergySaving
    Create external alarms
    Create eeea group    alarm=alarm1
    Create eeea group    alarm=alarm2
    Activate eeea
    Wait Until Keyword Succeeds    420 sec    30 sec
    ...    Verify cells energy saving state     energy_saving_state=energySaving
    logger.log_info_to_console    Waiting for next full PM period
    gnb_counter.Wait for PM measurements    interval=15min    measurements=0
    ${measurements}=     Get BTS counter with energy consumption    measurements=${measurements}
    ...                                                             power_savings_status=EnergySaving
    logger.log_info_to_console     ${measurements}
    Compare power consumption     measurements=${measurements}    reduction=8%
    Activate alarm    alarm=alarm1
    Wait Until Keyword Succeeds    60 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=notEnergySaving    cells_id=${cells_alarm1}
    Verify Alarm is Active on gNB     fault_name=Alarm1
    Activate alarm    alarm=alarm2
    Wait Until Keyword Succeeds    60 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=notEnergySaving
    Verify Alarm is Active on gNB     fault_name=Alarm2
    Reset gNB
    Wait Until Keyword Succeeds    1500 sec    30 sec
    ...    Verify cells energy saving state     energy_saving_state=notEnergySaving
    Dectivate alarm    alarm=alarm1
    Wait Until Keyword Succeeds    180 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=EnergySaving    cells_id=${cells_alarm_diff}
    Verify Alarm is not Active on gNB     fault_name=Alarm1
    Verify cells energy saving state     energy_saving_state=notEnergySaving    cells_id=${cells_alarm2}
    Dectivate alarm    alarm=alarm2
    Wait Until Keyword Succeeds    180 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=EnergySaving
    Verify Alarm is not Active on gNB     fault_name=Alarm2
    ASIR Power    pdu_index=${1}     action=off
    Wait Until Keyword Succeeds    180 sec    10 sec
    ...    Verify Active Alarm Occurrences on gNB     fault_name=No connection to unit     occurrences=${2}
    ASIR Power    pdu_index=1     action=on
    BuiltIn.Sleep     420s
    Wait Until Keyword Succeeds    120 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=EnergySaving
    Verify Alarm is not Active on gNB     fault_name=No connection to unit
    Deactivate eeea
    Wait Until Keyword Succeeds    300 sec    30 sec
    ...    Verify cells energy saving state     energy_saving_state=notEnergySaving
    Reset ue proxy
    Run keyword And Continue On Failure     Action with ue      CellIDs=${All_cells}
    ...                                                        duration=120s     action=CALL
    [Teardown]    Actions after test

CB009742-B_ASiR_Energy-efficient_emergency_activation_only_LTE_EDA_03872974
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Test1_EDA]
    Change BTS configuration        prefix_tag=EDA_LTE
    Verify cells energy saving state     energy_saving_state=notEnergySaving
    Create external alarms
    Create eeea group    alarm=alarm1_lte_only
    Create eeea group    alarm=alarm2_lte_only
    Activate eeea   rat=lte_only
    Wait Until Keyword Succeeds    420 sec    30 sec
    ...    Verify cells energy saving state     energy_saving_state=energySaving
    Activate alarm    alarm=alarm1
    Wait Until Keyword Succeeds    60 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=notEnergySaving    cells_id=${cells_alarm1_lte_only}
    Verify Alarm is Active on gNB     fault_name=Alarm1
    Activate alarm    alarm=alarm2
    Wait Until Keyword Succeeds    60 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=notEnergySaving
    Verify Alarm is Active on gNB     fault_name=Alarm2
    Reset gNB
    Wait Until Keyword Succeeds    1500 sec    30 sec
    ...    Verify cells energy saving state     energy_saving_state=notEnergySaving
    Dectivate alarm    alarm=alarm1
    Wait Until Keyword Succeeds    180 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=EnergySaving    cells_id=${cells_alarm_diff_lte_only}
    Verify Alarm is not Active on gNB     fault_name=Alarm1
    Verify cells energy saving state     energy_saving_state=notEnergySaving    cells_id=${cells_alarm2_lte_only}
    Dectivate alarm    alarm=alarm2
    Wait Until Keyword Succeeds    180 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=EnergySaving
    Verify Alarm is not Active on gNB     fault_name=Alarm2
    ASIR Power    pdu_index=${1}     action=off
    Wait Until Keyword Succeeds    180 sec    10 sec
    ...    Verify Active Alarm Occurrences on gNB     fault_name=Failure in optical interface     occurrences=${3}
    ASIR Power    pdu_index=1     action=on
    BuiltIn.Sleep     420s
    Wait Until Keyword Succeeds    120 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=EnergySaving
    Verify Alarm is not Active on gNB     fault_name=No connection to unit
    Deactivate eeea    rat=lte_only
    Wait Until Keyword Succeeds    300 sec    30 sec
    ...    Verify cells energy saving state     energy_saving_state=notEnergySaving
    Reset ue proxy
    Run keyword And Continue On Failure     Action with ue      CellIDs=${LTE_cell}
    ...                                                        duration=120s     action=CALL
    [Teardown]    Run Keywords     Change BTS configuration     AND     Actions after test

CB009742-D_Time-based_energy_saving_on_SBTS_for_cells_mapped_to_ASiR
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Test3]
    Verify cells energy saving state     energy_saving_state=notEnergySaving
    ${measurements}=	Create Dictionary
    ${measurements}=    Get hubs average power consumption     measurements=${measurements}
    ...                                                        power_savings_status=notEnergySaving
    Reset ue proxy
    Run keyword And Continue On Failure     Action with ue      CellIDs=${All_cells}
    ...                                                        duration=120s     action=CALL
    logger.log_info_to_console     Steps with power savings
    Action with ue      CellIDs=${LTE_cell}     duration=400s     action=ATTACH_ONLY     rat=LTE
    ...                 prepareUE=False
    Action with ue      CellIDs=${NR_cell}     duration=900s     action=ATTACH_ONLY     rat=NR
    ...                 prepareUE=False
    Verify cells energy saving state     energy_saving_state=energySaving
    ASIR Power    pdu_index=${1}     action=off
    Wait Until Keyword Succeeds    180 sec    10 sec
    ...    Verify Active Alarm Occurrences on gNB     fault_name=No connection to unit     occurrences=${2}
    ASIR Power    pdu_index=1     action=on
    BuiltIn.Sleep     480s
    Wait Until Keyword Succeeds    300 sec    30 sec
    ...    Verify cells energy saving state     energy_saving_state=energySaving
    Verify Alarm is not Active on gNB     fault_name=No connection to unit
    BuiltIn.Sleep     60s
    ${measurements}=     Get hubs average power consumption     measurements=${measurements}
    ...                                                         power_savings_status=EnergySaving
    Compare power consumption     measurements=${measurements}     reduction=20%
    Activate power savings in hubs
    BuiltIn.Sleep     360s
    Wait Until Keyword Succeeds    300 sec    30 sec
    ...     Verify poe status     antenna_ports=@{pRRH_ANTENNA_PORTS_BTS1}
    Change lbpsSuspended value     value=suspended
    BuiltIn.Sleep     360s
    Wait Until Keyword Succeeds    60 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=notEnergySaving
    Change lbpsSuspended value     value=notSuspended
    BuiltIn.Sleep     360s
    Wait Until Keyword Succeeds    60 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=energySaving
    Deactivate power savings in bts
    BuiltIn.Sleep     60s
    Deactivate power savings in hubs
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
    Verify cells energy saving state     energy_saving_state=notEnergySaving
    Run keyword And Continue On Failure     Action with ue      CellIDs=${All_cells}
    ...                                                         duration=120s     action=CALL
    ...                                                         prepareUE=False     index_run=2
    [Teardown]    Actions after test

CB009742-C_Micro-DTX_support_in_ASiR_pRRH_gen3
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Test4]
    ${measurements}=	Create Dictionary
    ${measurements_with_call_150}=	Create Dictionary
    ${measurements_with_call_10}=	Create Dictionary
    ${measurements}=    Get hubs average power consumption     measurements=${measurements}
    ...                                                        power_savings_status=notEnergySaving
    Cells Actions       action=Block     cell_list=${cells_to_block_gen3}
    Run keyword And Continue On Failure     Action with ue      CellIDs=${NR_cell}        duration=240s
    ...                                     action=MEASURE_POWER_CONSUMPTION
    ...                                     measure_power_consumption=${measurements_with_call_150}
    ...                                     power_consumption_level=notEnergySaving     tput=150 Mbits/sec
    Run keyword And Continue On Failure     Action with ue      CellIDs=${NR_cell}        duration=240s
    ...                                     action=MEASURE_POWER_CONSUMPTION
    ...                                     measure_power_consumption=${measurements_with_call_10}
    ...                                     power_consumption_level=notEnergySaving     tput=10 Mbits/sec
    ...                                     prepareUE=False     index_run=2
    Cells Actions       action=Unblock     cell_list=${cells_to_block_gen3}
    Activate uDTX       delta=uDTX_activate.json
    ${measurements}=    Get hubs average power consumption     measurements=${measurements}
    ...                                                    power_savings_status=EnergySaving
    Cells Actions       action=Block     cell_list=${cells_to_block_gen3}
    Run keyword And Continue On Failure     Action with ue      CellIDs=${NR_cell}        duration=240s
    ...                                     action=MEASURE_POWER_CONSUMPTION
    ...                                     measure_power_consumption=${measurements_with_call_150}
    ...                                     power_consumption_level=EnergySaving        tput=150 Mbits/sec
    ...                                     prepareUE=False     index_run=3
    Run keyword And Continue On Failure     Action with ue      CellIDs=${NR_cell}        duration=240s
    ...                                     action=MEASURE_POWER_CONSUMPTION
    ...                                     measure_power_consumption=${measurements_with_call_10}
    ...                                     power_consumption_level=EnergySaving        tput=10 Mbits/sec
    ...                                     prepareUE=False     index_run=4
    Cells Actions       action=Unblock     cell_list=${cells_to_block_gen3}
    Compare power consumption     measurements=${measurements}               reduction=10%       hub_id=2
    Compare power consumption     measurements=${measurements_with_call_150}     reduction=1%       hub_id=2
    Compare power consumption     measurements=${measurements_with_call_10}     reduction=5%        hub_id=2
    [Teardown]    Run Keywords     Change BTS configuration     AND     Actions after test

CB009742-C_Micro-DTX_support_in_ASiR_pRRH_gen2
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Test3]
    Change BTS configuration        prefix_tag=gen2
    ${measurements}=	Create Dictionary
    ${measurements}=    Get hubs average power consumption     measurements=${measurements}
    ...                                                        power_savings_status=notEnergySaving
    Activate uDTX       delta=uDTX_activate_gen2.json
    ${measurements}=    Get hubs average power consumption     measurements=${measurements}
    ...                                                    power_savings_status=EnergySaving
    Compare power consumption     measurements=${measurements}     reduction=10%     hub_id=2
    [Teardown]    Run Keywords     Change BTS configuration     AND     Actions after test

###########################################################################################################################
###################################################### CB009918 ###########################################################
###########################################################################################################################
CB009918-B1_Power_Saving_base_on_PSG_min_load_with_Public_Safety_call
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Test3]
    Reset ue proxy
    Apn Change      5gkrk2       UE
    Activate Power Saving CB009918         delta=CB009918_power_saving_activation.json
    Run keyword And Continue On Failure     Action with ue      CellIDs=${LTE_cell}        duration=900s
    ...                                     action=CALL     verify_power_saving_during_test=${CB009918}
    Apn Change      5gbothkrk       UE      prepareUE=False
    [Teardown]    Run Keywords     Change BTS configuration     AND     Actions after test

CB009918-B2_Power_Saving_base_on_RTX_min_load_with_High_priority_ARP_call
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Test3]
    Activate Power Saving CB009918      delta=CB009918_power_saving_activation_hpa.json
    Reset ue proxy
    Run keyword And Continue On Failure     Action with ue      CellIDs=${LTE_cell}        duration=900s
    ...                                     action=CALL         verify_power_saving_during_test=${CB009918_hpa}
    [Teardown]    Run Keywords     Change BTS configuration     AND     Actions after test

CB009742-A_Unsuccessful_activation_of_time-based_energy_saving_for_RFCCELLs_in_ASiR
    [Setup]    Actions before test on second gnb
    Activate power savings in asir for rfc
    BuiltIn.Sleep    30s
    Activate power savings in hubs     bts_id=1
    BuiltIn.Sleep    30s
    ${value_before}=    local_resources.get_asir_parameter_via_gui    bts_id=${1}    dist_name=ASI-1/PSGRP-1
    ...                                                               abbreviation=rfcCellDnList-0
    logger.log_info_to_console    Value before `rfcCellDnList-0`=${value_before}
    local_resources.set_asir_parameter_via_gui    bts_id=${1}    dist_name=ASI-1/PSGRP-1    abbreviation=rfcCellDnList-0
    ...                                           new_value=10
    BuiltIn.Sleep   10s
    Verify that no asir crash occured   bts_id=${1}    timeout=${90}
    ${value_after}=    local_resources.get_asir_parameter_via_gui    bts_id=${1}    dist_name=ASI-1/PSGRP-1
    ...                                                              abbreviation=rfcCellDnList-0
    logger.log_info_to_console    Value after `rfcCellDnList-0`=${value_before}
    Should Be Equal As Strings    ${value_before}    ${value_after}
    BuiltIn.Sleep    240s
    Dectivate power savings in asir for rfc
    [Teardown]    Actions after test on second gnb

CB013258_microDTX_deactivation_attempt
    [Setup]    Actions before test
    @{parameters}    Create List    actMicroDTX    actMicroDTXAdvanced
    Try to change not exist parameter via webem    dist_name=MRBTS-77135/NRBTS-77135    parameter=actMicroDTX
    ...                                            value=false
    Try to change not exist parameters via admin    delta=uDTX_activate_trunk.json    parameters=${parameters}
    Reset gNB
    Wait until bts is on_air
    @{cell_ids}=    Create List    24    25    31
    Verify MicroDTX feature in syslog    cell_ids=@{cell_ids}
    [Teardown]    Actions after test

CB09742_moving_cells_from_EEAGRP_to_PSGRP
    [Setup]    Actions before test
    Change BTS configuration        prefix_tag=EDA_move_cell_from_eeagrp    wait_for_cells=${False}
    BuiltIn.Sleep     360s
    Wait Until Keyword Succeeds    60 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=notEnergySaving    cells_id=${cells_psgrp}
    Wait Until Keyword Succeeds    60 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=EnergySaving    cells_id=${cells_eeagrp}
    Move cells from eeagrp to psgrp     delta=Move_cells_from_eeagrp_to_psgrp.json
    Wait Until Keyword Succeeds    120 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=notEnergySaving    cells_id=${cells_psgrp_after_reconfig}
    Wait Until Keyword Succeeds    60 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=EnergySaving    cells_id=${cells_eeagrp_after_reconfig}
    [Teardown]    Run Keywords     Change BTS configuration     AND     Actions after test



CB009742_moving_cells_from_PSGRP_to_EEAGRP
    [Setup]    Actions before test
    Change BTS configuration        prefix_tag=EDA_move_cell_from_psgrp    wait_for_cells=${False}
    BuiltIn.Sleep     360s
    Wait Until Keyword Succeeds    120 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=EnergySaving    cells_id=${cells_energysaving}
    Move cells from eeagrp to psgrp     delta=Move_cells_from_psgrp_to_eeagrp.json
    Wait Until Keyword Succeeds    600 sec    10 sec
    ...    Verify cells energy saving state     energy_saving_state=EnergySaving    cells_id=${cells_energysaving}
    [Teardown]    Run Keywords     Change BTS configuration     AND     Actions after test

#Turn test line offl
#    Turn test line off
