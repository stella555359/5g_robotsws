*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    release: 25R1

*** Variables ***
${TRAFFIC_DURATION_AFTER_PSCELL_D_B14}=   10s

*** Keywords ***
CB008490-D_B14_Initial_DL_Traffic_Routing_post_NR-DC_PSCell_Addition
    Register Nrdc Ue With Default Pdu Session
    Send A4 Measurement And Trigger Pscell Addition
    Start Udp Traffic 110Mbps In DL
    Check Initial DL Traffic Routing Visible On Scg    min_packets=800    max_packets=1500
    Deregister Ue   ue_id=1
    Sleep    3s    Waiting for deregister

    Set Initial DL Traffic Routing To initDLdynamic
    Register Nrdc Ue With Default Pdu Session
    Send A4 Measurement And Trigger Pscell Addition
    Start Udp Traffic 110Mbps In DL
    Check Initial DL Traffic Routing Visible On Scg    min_packets=0    max_packets=10
    Deregister Ue   ue_id=1
    Sleep    3s    Waiting for deregister

    Set Initial DL Traffic Routing To initDLoverSecondary
    Register Nrdc Ue With Default Pdu Session
    Send A4 Measurement And Trigger Pscell Addition
    Start Udp Traffic 110Mbps In DL
    Check Initial DL Traffic Routing Visible On Scg    min_packets=0    max_packets=10

Start Udp Traffic 110Mbps In DL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=110

Check Initial DL Traffic Routing Visible On Scg
    [Arguments]    ${min_packets}    ${max_packets}
    Sleep    ${TRAFFIC_DURATION_AFTER_PSCELL_D_B14}    Waiting for new packets
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl
    Run Keyword And Continue On Failure    Check Packets In Range
    ...    ue_id=1    pdu_id=1    qfi_id=1    min_packets=${min_packets}     max_packets=${max_packets}
    ...    direction=dl    optional_params=dc_cell_group=scg
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=110    unit=mbps    margin=0.2    direction=dl

Set Initial DL Traffic Routing To initDLoverSecondary
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_NRDRB-11_initDLdynamic.json
    ...    remote_host=${REMOTE_HOST_1_IP}

Set Initial DL Traffic Routing To initDLdynamic
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_NRDRB-11_initDLoverSecondary.json
    ...    remote_host=${REMOTE_HOST_1_IP}


