*** Settings ***
Documentation
...    copyright: Nokia

Library      ../../CB007262/CB007262_A/CB007262_keywords.py

*** Keywords ***
Enable PDSCH decoding in the multiplexed slots
    Execute Egate Command    cmd=ue_testmode_decode_muxphychan decode_mux_phy_chan=decode_PDSCH

Set Internal Traffic Type To UE
    [Arguments]   ${ue}=1    ${pdu}=1
    Execute Egate Command   cmd=set_pdu_param ue=${ue} pdu=${pdu} trf_type=internal

Start DL and UL Data Traffic
    [Arguments]   ${dl_tput}    ${ul_tput}    ${ue}=1    ${pdu}=1    ${quantity}=1
    FOR    ${i}    IN RANGE    ${quantity}
        Execute Egate Command And Wait For Data
        ...    cmd=trf_data_start ue=${ue} pdu=${pdu} qfi=1 trf_id=${i+1} mbps=${dl_tput} dir=dl seconds=180 size=8000
        ...    pass_regexp=UE${ue}: Started Downlink Internal traffic Receiver on Ue:${ue} Pdu:${pdu} Qfi:1 TrfId:${i+1}
        Execute Egate Command And Wait For Data
        ...    cmd=trf_data_start ue=${ue} pdu=${pdu} qfi=1 trf_id=${i+1} mbps=${ul_tput} dir=ul seconds=180 size=8000
        ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue} UpfId:1 Pdu:${pdu} Qfi:1 TrfId:${i+1}
        Sleep    1s
    END

Verify Max Tput For UE SA
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}    ${accuracy}=87
    ${max_tput}=    Get Max Data Traffic For Given Cc    ue_id=${ue_id}   cc=0-1   direction=${dir}    unit=Mbps
    Should Be True    ${max_tput} > ${expected_tput}*0.${accuracy}

Verify Average Tput For UE SA
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}    ${accuracy}=99
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}*0.${accuracy}

Verify Average Tput For UE NSA
    [Arguments]   ${ue_id}    ${id}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Nsa    ue_id=${ue_id}    id=${id}    dir=${dir}    unit=${unit}
    Run Keyword And Continue on Failure    Should Be True    ${avg_tput} > ${expected_tput}

Stop All Data Transfers And Detach UE NSA
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=trf_data_stop id=2 ue=${ue_id}
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=${ue_id}

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Set X2 interface
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2

Install ORAN RU
    [Arguments]
    ...    ${iphy_path}
    ...    ${iphy_filename}
    ...    ${sh_path}=${CURDIR}/install_ofegsa.sh
    Run    chmod +x ${sh_path}
    Run    sh ${sh_path} ${iphy_path} ${iphy_filename}
    Log to console    \ninstalling ORAN RU
