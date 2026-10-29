*** Settings ***
Documentation
...   author: PZ_2_WRO_5

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000545/resources/545-keywords.py

*** Variables ***

${545_path}=       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000545/resources


*** Keywords ***

Decreasing Radio Conditions To Activate Transform Precoder At Cell
    [Arguments]  ${start_tput_date}=0  ${start_cnt}=1   ${stop_cnt}=42  ${cell}=${lines_gNB_184_AHLOA_2}
    FOR    ${index}   IN RANGE    ${start_cnt}   ${stop_cnt}
       Check Data Transfer Is Alive   DT_UL_SA
       Get Average Throughput         DT_UL_SA
       ${attenuate}=   Evaluate    ${index} * 2
       Log to console  Set ${attenuate} dB
	   Set attenuation and check  lines=${cell}    value=${attenuate}
       ${current_date}= 	Get Current Date   result_format=epoch
       ${time} = 	Subtract Time From Time 	${current_date}  ${start_tput_date}
	   ${omitting}=     Convert To Integer  ${time}
	   ${ending}=       Convert To Integer  ${time}
       ${omitting}=     Evaluate  ${ending} - 10
       ${ending}=       Evaluate  ${ending} - 8
	   ${avgtput}      Get Average Throughput    dt_name=DT_UL_SA    omit=${omitting}  end=${ending}
	   Sleep  3s
       Exit For Loop If   ${avgtput} <= 10000
    END

Decreasing Radio Conditions To Activate Transform Precoder At First Cell
    [Arguments]  ${start_tput_date}=0  ${start_cnt}=1   ${stop_cnt}=42  ${cell}=${lines_gNB_184_AHLOA_3}
    FOR    ${index}   IN RANGE    ${start_cnt}   ${stop_cnt}
       Check Data Transfer Is Alive   DT_UL_SA
       Get Average Throughput         DT_UL_SA
       ${attenuate}=   Evaluate    ${index} * 2
       Log to console  Set ${attenuate} dB
	   Set attenuation and check  lines=${cell}    value=${attenuate}
       ${current_date}= 	Get Current Date   result_format=epoch
       ${time} = 	Subtract Time From Time 	${current_date}  ${start_tput_date}
	   ${omitting}=     Convert To Integer  ${time}
	   ${ending}=       Convert To Integer  ${time}
       ${omitting}=     Evaluate  ${ending} - 10
       ${ending}=       Evaluate  ${ending} - 8
	   ${avgtput}      Get Average Throughput    dt_name=DT_UL_SA    omit=${omitting}  end=${ending}
	   Sleep  3s
       Exit For Loop If   ${avgtput} <= 6000
    END

Decreasing Radio Conditions To Activate Transform Precoder At Third Cell
    [Arguments]  ${start_tput_date}=0  ${start_cnt}=1   ${stop_cnt}=42
    FOR    ${index}   IN RANGE    ${start_cnt}   ${stop_cnt}
       Check Data Transfer Is Alive   DT_UL_SA
       ${attenuate}=   Evaluate    ${index} * 2
       Log to console  Set ${attenuate} dB
	   Set attenuation and check  lines=${lines_gNB_184_AHLOA_3}    value=${attenuate}
       ${current_date}= 	Get Current Date   result_format=epoch
       ${time} = 	Subtract Time From Time 	${current_date}  ${start_tput_date}
	   ${omitting}=     Convert To Integer  ${time}
	   ${ending}=       Convert To Integer  ${time}
       ${omitting}=     Evaluate  ${ending} - 10
       ${ending}=       Evaluate  ${ending} - 8
	   ${avgtput}      Get Average Throughput    dt_name=DT_UL_SA    omit=${omitting}  end=${ending}
	   Sleep  3s
       Exit For Loop If   ${avgtput} <= 1700
    END

Decreasing Radio Conditions To Activate Transform Precoder At 159
    FOR    ${index}   IN RANGE    ${start_cnt}   ${stop_cnt}
       ${attenuate}=   Evaluate    ${index} * 2
	   Set attenuation and check  lines=${lines_gNB_159_AHCA_1}    value=${attenuate}
	   Sleep  1s
	END

Check Transform Precoder off Into L1L2 log
     [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}_off.pcap
    ${msgs}   check_transform_precoder_off   ${dir}
     should be true    ${msgs}

Check Transform Precoder on Into L1L2 log
     [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}_on.pcap
    ${msgs}   check_transform_precoder_on   ${dir}
     should be true    ${msgs}

Check DCI 0_1 for Transform Precoder disabled
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}_off.pcap
    ${msgs}  check_dci_for_tp_off   ${dir}
    should be true    ${msgs}

Check DCI 0_1 for Transform Precoder enabled
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}_on.pcap
    ${msgs}  check_dci_for_tp_on   ${dir}
    should be true    ${msgs}

Check DCI 0_1 for Transform Precoder disabled 20MHz
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}_off.pcap
    ${msgs}  check_dci_for_tp_off_20MHz   ${dir}
    should be true    ${msgs}

Check DCI 0_1 for Transform Precoder enabled 20MHz
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}_on.pcap
    ${msgs}  check_dci_for_tp_on_20MHz   ${dir}
    should be true    ${msgs}

Set SRB3
    [Arguments]   ${SRB3}=false
    Log to console  Setting SRB3 at gNB
    ${response_tp}  coam.Perform parameter recommissioning    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}
    ...                                       parameter=srb3SupportEnabled
    ...                                       operation=update
    ...                                       value=${SRB3}
    ...                                       connection=cOAM
    Log to console  SRB3 is set to ${SRB3}

Set chbw for PCI 158
    [Arguments]     ${chBwDl}=20MHz
    ...             ${chBwUl}=20MHz
    log to console                  Perform parameters recommissioning
    initialise delta store
    ${object_path}      Set variable    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-1/NRCELL_FDD-1
    Add param to delta            ${object_path}      chBwDl            value=${chBwDl}
    Add param to delta            ${object_path}      chBwUl            value=${chBwUl}

    ${delta}            Collect delta store
    AdminHelper.Recommission with delta from admin    ${delta}
    Sleep     30s
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    log to console      all cells are onair
