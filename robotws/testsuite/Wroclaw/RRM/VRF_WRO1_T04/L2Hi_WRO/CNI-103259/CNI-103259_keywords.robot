*** Settings ***
Documentation
...    This file contains general keywords used for testing Feature CNI-103259.

*** Variables ***
${HO_PARAM_GNB2}=    event=A5 srsrp_nr=19 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=50

*** Keywords ***
Enable CNI-103259 Pm Counters
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_miNrNRPFW.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_miNrPDCPCell.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_miNrHighRlcCell.json

Register Ue With Default Pdu Session On Sim Gnb3
    Execute Egate Command    cmd=ue_change_location id=1 enb=3 cell=1
    ...                      pass_regexp=location updated to eNB-3 cell 1
    ...                      timeout=10
    Register Ue With Default Pdu Session

Add Item To UE History Information List
    Execute Egate Command    cmd=ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute Egate Command And Wait For Data    cmd=ue_history_information_list id=1 action=commit
    Execute Egate Command    cmd=ue_enb_param id=1 ue_history_list=1

Start 5Mbps Udp Dl And Ul Traffic
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=5
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=5

Trigger Handover To Gnb 2
    Add Item To UE History Information List
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 ${HO_PARAM_GNB2}
