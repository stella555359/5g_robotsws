*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${TRAFFIC_DURATION_SEC_B_B9}=   10m

*** Keywords ***
CB008717-B_B9_Mue_Nrdc_Ues
    Attach Multiple 5g Nrdc Ues
    Start Udp Traffic 85Mbps In DL
    Check Data Traffic On Mcg And Scg Leg For MUE

Attach Multiple 5g Nrdc Ues
    [Arguments]    ${num_of_ues}=${10}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Set Internal Traffic Type To UEs    ue_id=${ue_id}    pdu_id=${ue_id}
        Attach Ue    ue_id=${ue_id}
        Establish Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}    gw_id=${ue_id}
        Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 ${A4_param}
    END

Start Udp Traffic 85Mbps In DL
    [Arguments]    ${num_of_ues}=${10}
    Execute Egate Command    cmd=sim_debug_log level=6
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=1 dir=dl mbps=85
    END

Check Data Traffic On Mcg And Scg Leg For MUE
    [Arguments]    ${num_of_ues}=${10}
    Sleep    ${TRAFFIC_DURATION_SEC_B_B9}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} cell_group=MCG type=pdsch
        Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} cell_group=SCG type=pdsch scell=1
        Execute Egate Command And Wait For Data    cmd=qfi_stats ue=${ue_id} pdu=${ue_id} qfi=1 dir=dl
        Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}    pdu_id=${ue_id}    qfi_id=1
    ...    expected_throughput=85    unit=mbps    margin=0.2    direction=dl
    END
