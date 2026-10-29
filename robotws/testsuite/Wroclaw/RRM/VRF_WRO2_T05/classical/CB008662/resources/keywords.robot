*** Settings ***
Documentation
...   author: PZ_2_WRO_5

*** Keywords ***

Set attenuation for 8622-A_1
    [Arguments]    ${ABIP}=False
    Log to Console    >Setting initial attenuation for this test case...<
    Run Keyword If  ${ABIP}
    ...    Set attenuation and check  lines=@{lines_gNB_205_AHFIB_1}      value=0
    ...    ELSE
    ...    Set attenuation and check  lines=@{lines_gNB_184_AHLOA_1}    value=0
    Sleep  3s
    Log to Console  >Attenuators have been set for 8622-A_1.<

Set attenuation for 8622-A_8
    [Arguments]    ${ABIP}=False
    Log to Console    >Setting initial attenuation for this test case...<
    Run Keyword If  ${ABIP}
    ...    Set attenuation and check  lines=@{lines_gNB_205_AHFIB_1}      value=0
    ...    ELSE
    ...    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}    value=0
    Sleep  3s
    Run Keyword If  ${ABIP}
    ...    Set attenuation and check  lines=@{lines_gNB_205_AHFIB_1}      value=0
    ...    ELSE
    ...    Set attenuation and check  lines=${lines_gNB_184_AHLOA_3}    value=0
    Log to Console  >Attenuators have been set for 8622-A_8 CA cells.<

Set attenuation for 8622-AD_1
    Log to Console    >Setting initial attenuation for this test case...<
    Set attenuation and check  lines=@{lines_gNB_153_AHLOA_2}    value=0
    Sleep  3s
    Log to Console  >Attenuators have been set for 8622-AD_1.<

Decrease radio conditions 0 to -25dB
    [Arguments]    ${ABIP}=False
    Log to Console    >Decreasing radio conditions without cell release...<
    Run Keyword If  ${ABIP}
    ...    Set attenuation and check  lines=@{lines_gNB_205_AHFIB_1}      value=80
    ...    ELSE
    ...    Set attenuation and check  lines=@{lines_gNB_184_AHLOA_1}    value=50
    # :FOR    ${index}   IN RANGE    ${start_cnt}    ${stop_cnt}
    #    ${attenuate}=   Evaluate    ${index} * 5
    #    Log to console  Set - ${attenuate} dB
    #    Run Keyword If  ${ABIP}
    #    ...    Set attenuation and check  lines=@{lines_gNB_205_AHFIB_1}      value=${attenuate}
    #    ...    ELSE
    #    ...    Set attenuation and check  lines=@{lines_gNB_184_AHLOA_1}    value=${attenuate}
	#    Log to Console    Decreasing conditions loop: ${index}
	#    ${current_date}= 	Get Current Date   result_format=epoch
    #    ${time} = 	Subtract Time From Time 	${current_date}  ${start_tput_date}
	#    ${omitting}=     Convert To Integer  ${time}
	#    ${ending}=       Convert To Integer  ${time}
    #    ${omitting}=     Evaluate  ${ending} - 12
    #    ${ending}=       Evaluate  ${ending} - 11
	#    ${avgtput}      Get Average Throughput    dt_name=DT_DL_SA    omit=${omitting}  end=${ending}
	#    Sleep  3s
    #    Exit For Loop If   ${avgtput} <= 4000
    # END
	Sleep  1s

Increase radio conditions -25 to 0dB
    [Arguments]   ${ABIP}=False
    Log to Console    >Increasing radio conditions...<
    Run Keyword If  ${ABIP}
    ...    Set attenuation and check  lines=@{lines_gNB_205_AHFIB_1}      value=0
    ...    ELSE
    ...    Set attenuation and check  lines=@{lines_gNB_184_AHLOA_1}    value=0
    Sleep  1s

Continuous change of radio conditions
    [Arguments]    ${ABIP}=False
    FOR    ${index}   IN RANGE    1    10
#           Decrease radio conditions 0 to -25dB  start_tput_date=${start_tput_date}    ABIP=${ABIP}
           Decrease radio conditions 0 to -25dB  ABIP=${ABIP}
           Increase radio conditions -25 to 0dB  ABIP=${ABIP}
    END
    Log to Console    >Radio conditions change has been finished.<

Decrease radio conditions 0 to -25dB for 8662-AD
    [Arguments]   ${start_cnt}=1   ${stop_cnt}=7
    Log to Console    >Decreasing radio conditions without cell release...<
    FOR    ${index}   IN RANGE    ${start_cnt}    ${stop_cnt}
       ${attenuate}=   Evaluate    ${index} * 5
       Log to console  Set - ${attenuate} dB
	   Set attenuation and check  lines=@{lines_gNB_153_AHLOA_2}     value=${attenuate}
	   Log to Console    Decreasing conditions loop: ${index}
	   Sleep  2s
	END
    Sleep  3s

Increase radio conditions -25 to 0dB for 8662-AD
    [Arguments]   ${start_cnt}=6   ${stop_cnt}=-1
    Log to Console    >Increasing radio conditions...<
    FOR    ${index}   IN RANGE    ${start_cnt}    ${stop_cnt}    -1
       ${attenuate}=   Evaluate    ${index} * 5
       Log to console  Set - ${attenuate} dB
	   Set attenuation and check  lines=@{lines_gNB_153_AHLOA_2}    value=${attenuate}
	   Log to Console    Increasing conditions loop: ${index}
	   Sleep  2s
    END
    Sleep  3s

Continuous change of radio conditions for 8662-AD
    FOR    ${index}   IN RANGE    1    10
           Decrease radio conditions 0 to -25dB for 8662-AD
           Increase radio conditions -25 to 0dB for 8662-AD
    END
    Log to Console    >Radio conditions change has been finished.<

Increase radio conditions -25 to 0dB for 8662 CA
    [Arguments]   ${ABIP}=False
    Log to Console    >Increasing radio conditions...<
    Run Keyword If  ${ABIP}
    ...    Set attenuation and check  lines=@{lines_gNB_205_AHFIB_1}    value=0
    ...    ELSE    Run keywords
    ...    Set attenuation and check  lines=@{lines_gNB_184_AHLOA_1}    value=0  AND
    ...    Set attenuation and check  lines=@{lines_gNB_184_AHLOA_3}    value=0
    Sleep  1s

Decrease radio conditions 0 to -25dB for 8662 CA
    [Arguments]  ${ABIP}=False
#    ... ${start_tput_date}=0   ${start_cnt}=1   ${stop_cnt}=4
    Log to Console    >Decreasing radio conditions without cell release...<
    Run Keyword If  ${ABIP}
    ...    Set attenuation and check  lines=@{lines_gNB_205_AHFIB_1}    value=70
    ...    ELSE    Run keywords
    ...    Set attenuation and check  lines=@{lines_gNB_184_AHLOA_1}    value=40  AND
    ...    Set attenuation and check  lines=@{lines_gNB_184_AHLOA_3}    value=40

    # :FOR    ${index}   IN RANGE    ${start_cnt}    ${stop_cnt}
    #    ${attenuate}=   Evaluate    ${index} * 5
    #    Log to console  Set - ${attenuate} dB
    #    Set attenuation and check  lines=@{lines_gNB_153_AHLOA_2}    value=${attenuate}
    #    Set attenuation and check  lines=@{lines_gNB_153_AHLOA_1}    value=${attenuate}
	#    Log to Console    Decreasing conditions loop: ${index}
	#    ${current_date}= 	Get Current Date   result_format=epoch
    #    ${time} = 	Subtract Time From Time 	${current_date}  ${start_tput_date}
	#    ${omitting}=     Convert To Integer  ${time}
	#    ${ending}=       Convert To Integer  ${time}
    #    ${omitting}=     Evaluate  ${ending} - 12
    #    ${ending}=       Evaluate  ${ending} - 11
	#    ${avgtput}      Get Average Throughput    dt_name=DT_DL_SA    omit=${omitting}  end=${ending}
	#    Sleep  3s
    #    Exit For Loop If   ${avgtput} <= 4000
	# END
    Sleep  1s

Continuous change of radio conditions for CA
    [Arguments]     ${ABIP}=False
    FOR    ${index}   IN RANGE    1    10
#           Decrease radio conditions 0 to -25dB for 8662 CA   start_tput_date=${start_tput_date}   ABIP=${ABIP}
           Decrease radio conditions 0 to -25dB for 8662 CA   ABIP=${ABIP}
           Increase radio conditions -25 to 0dB for 8662 CA   ABIP=${ABIP}
    END
    Log to Console    >Radio conditions change has been finished.<

Verify reserved MCS for uplink
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/${test_name}.pcap
    ${res_mcs_ul}    check_reserved_mcs_ul  ${dir}
    should be true   ${res_mcs_ul}
    Log to Console   >Uplink reserved MCS are observed in pcap file.<

Verify reserved MCS for downlink
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/${test_name}.pcap
    ${res_mcs_dl}    check_reserved_mcs_dl  ${dir}
    should be true   ${res_mcs_dl}
    Log to Console   >Uplink and downlink reserved MCS are observed in pcap file.<

Verify reserved MCS for downlink CA
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/${test_name}.pcap
    ${res_mcs_dl_ca}    check_reserved_mcs_dl_ca  ${dir}
    should be true   ${res_mcs_dl_ca}
    Log to Console   >Uplink and downlink reserved MCS are observed in pcap file.<

Verify PM counters 8662-A
    log to console      Verify PM counters values, wait 305 seconds
    Sleep  400s
    ${counters}         Read Counters Value 8662
    ${counter_check}    check_counters_8662    ${counters}
    Should be True      ${counter_check}

Verify PM counters 8662-A for CA case
    log to console      Verify PM counters values, wait 305 seconds
    Sleep  305s
    ${counters}         Read Counters Value 8662
    ${counter_check}    check_counters_8662_ca    ${counters}
    Should be True      ${counter_check}

Read counters value 8662
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55300C06031  M55300C06030  M55300C06029  M55300C06028  M55304C06031  M55304C06030
    ...   M55304C06029  M55304C06028
    FOR    ${counter}    IN      @{counters}
       ${value}    Get sum of n last counter values   4  ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}


Delta commissioning
    [Arguments]     ${parameter}=True   ${ABIP}=False
    Run Keyword If  ${ABIP}
    ...    Delta commissioning ABIP  ${parameter}
    ...    ELSE
    ...    Delta commissioning ABIO  ${parameter}

Delta commissioning for CA
    [Arguments]     ${parameter}=True   ${ABIP}=False
    Run Keyword If  ${ABIP}
    ...    Delta commissioning for CA ABIP  ${parameter}
    ...    ELSE
    ...    Delta commissioning for CA ABIO  ${parameter}

Delta commissioning ABIO
    [Arguments]  ${parameter}=True
    ...          ${cell_1_path}=MRBTS-51003/NRBTS-51003/NRCELL-1
    ...          ${cell_2_path}=MRBTS-51003/NRBTS-51003/NRCELL-2
    ...          ${cell_3_path}=MRBTS-51003/NRBTS-51003/NRCELL-3
    ...          ${bts_path}=MRBTS-51003/NRBTS-51003/NRDU-1
    ${cASupportList}    Create list    none
    Initialise delta store
    Run keyword if      ${parameter}   Run keywords
    # For CB008662-A_2_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_DftSOfdm
    ...    Add param to delta       ${cell_1_path}          actUlDftSOfdm           value=true   AND
    ...    Add param to delta       ${cell_2_path}          actUlDftSOfdm           value=true   AND
    ...    Add param to delta       ${cell_3_path}          actUlDftSOfdm           value=true   AND
    ...    Add param to delta       ${cell_1_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_2_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_3_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${bts_path}             flexibleCAMode          value=BasicCAMode   AND
    ...    Add param to delta       ${cell_1_path}          targetPctResourceReservedMcsUl           value=80   AND
    ...    Add param to delta       ${cell_2_path}          targetPctResourceReservedMcsUl           value=80   AND
    ...    Add param to delta       ${cell_3_path}          targetPctResourceReservedMcsUl           value=80   AND
    ...    Add param to delta       ${cell_1_path}          targetPctResourceReservedMcsDl           value=80   AND
    ...    Add param to delta       ${cell_2_path}          targetPctResourceReservedMcsDl           value=80   AND
    ...    Add param to delta       ${cell_3_path}          targetPctResourceReservedMcsDl           value=80   AND
    ...    Add param to delta       ${cell_1_path}          minPctResourceReservedMcsUl           value=60   AND
    ...    Add param to delta       ${cell_2_path}          minPctResourceReservedMcsUl           value=60   AND
    ...    Add param to delta       ${cell_3_path}          minPctResourceReservedMcsUl           value=60   AND
    ...    Add param to delta       ${cell_1_path}          minPctResourceReservedMcsDl           value=60   AND
    ...    Add param to delta       ${cell_2_path}          minPctResourceReservedMcsDl           value=60   AND
    ...    Add param to delta       ${cell_3_path}          minPctResourceReservedMcsDl           value=60
    ...    ELSE  Run keywords
    # For CB008662-A_1_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_LOKI
    ...    Add param to delta       ${cell_1_path}          actUlDftSOfdm           value=false   AND
    ...    Add param to delta       ${cell_2_path}          actUlDftSOfdm           value=false   AND
    ...    Add param to delta       ${cell_3_path}          actUlDftSOfdm           value=false   AND
    ...    Add param to delta       ${cell_1_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_2_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_3_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${bts_path}             flexibleCAMode          value=BasicCAMode   AND
    ...    Add param to delta       ${cell_1_path}          targetPctResourceReservedMcsUl           value=100   AND
    ...    Add param to delta       ${cell_2_path}          targetPctResourceReservedMcsUl           value=100   AND
    ...    Add param to delta       ${cell_3_path}          targetPctResourceReservedMcsUl           value=100   AND
    ...    Add param to delta       ${cell_1_path}          targetPctResourceReservedMcsDl           value=100   AND
    ...    Add param to delta       ${cell_2_path}          targetPctResourceReservedMcsDl           value=100   AND
    ...    Add param to delta       ${cell_3_path}          targetPctResourceReservedMcsDl           value=100   AND
    ...    Add param to delta       ${cell_1_path}          minPctResourceReservedMcsUl           value=50   AND
    ...    Add param to delta       ${cell_2_path}          minPctResourceReservedMcsUl           value=50   AND
    ...    Add param to delta       ${cell_3_path}          minPctResourceReservedMcsUl           value=50   AND
    ...    Add param to delta       ${cell_1_path}          minPctResourceReservedMcsDl           value=50   AND
    ...    Add param to delta       ${cell_2_path}          minPctResourceReservedMcsDl           value=50   AND
    ...    Add param to delta       ${cell_3_path}          minPctResourceReservedMcsDl           value=50   AND
    ...    Add param to delta       ${bts_path}       carrierAggregationSupportList         value=${cASupportList}
    ${delta}                 Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}

Delta commissioning ABIP
    [Arguments]  ${parameter}=True
    ...          ${cell_5001_path}=MRBTS-50017/NRBTS-50017/NRCELL-5001
    ...          ${cell_5002_path}=MRBTS-50017/NRBTS-50017/NRCELL-5002
    ...          ${bts_path}=MRBTS-50017/NRBTS-50017/NRDU-1
    ${cASupportList}    Create list    none
    Initialise delta store
    Run keyword if      ${parameter}   Run keywords
    # For CB008662-A_2_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_DftSOfdm
    ...    Add param to delta       ${cell_5001_path}       actUlDftSOfdm           value=true   AND
    ...    Add param to delta       ${cell_5002_path}       actUlDftSOfdm           value=true   AND
    ...    Add param to delta       ${bts_path}             flexibleCAMode          value=BasicCAMode   AND
    ...    Add param to delta       ${cell_5001_path}       actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_5002_path}       actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_5001_path}       targetPctResourceReservedMcsUl           value=80   AND
    ...    Add param to delta       ${cell_5002_path}       targetPctResourceReservedMcsUl           value=80   AND
    ...    Add param to delta       ${cell_5001_path}       targetPctResourceReservedMcsDl           value=80   AND
    ...    Add param to delta       ${cell_5002_path}       targetPctResourceReservedMcsDl           value=80   AND
    ...    Add param to delta       ${cell_5001_path}       minPctResourceReservedMcsUl           value=60   AND
    ...    Add param to delta       ${cell_5002_path}       minPctResourceReservedMcsUl           value=60   AND
    ...    Add param to delta       ${cell_5001_path}       minPctResourceReservedMcsDl           value=60   AND
    ...    Add param to delta       ${cell_5002_path}       minPctResourceReservedMcsDl           value=60
    ...    ELSE  Run keywords
    # For CB008662-A_1_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_LOKI
    ...    Add param to delta       ${cell_5001_path}          actUlDftSOfdm           value=false   AND
    ...    Add param to delta       ${cell_5002_path}          actUlDftSOfdm           value=false   AND
    ...    Add param to delta       ${cell_5001_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_5002_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${bts_path}                flexibleCAMode          value=BasicCAMode   AND
    ...    Add param to delta       ${cell_5001_path}       targetPctResourceReservedMcsUl           value=100   AND
    ...    Add param to delta       ${cell_5002_path}       targetPctResourceReservedMcsUl           value=100   AND
    ...    Add param to delta       ${cell_5001_path}       targetPctResourceReservedMcsDl           value=100   AND
    ...    Add param to delta       ${cell_5002_path}       targetPctResourceReservedMcsDl           value=100   AND
    ...    Add param to delta       ${cell_5001_path}       minPctResourceReservedMcsUl           value=50   AND
    ...    Add param to delta       ${cell_5002_path}       minPctResourceReservedMcsUl           value=50   AND
    ...    Add param to delta       ${cell_5001_path}       minPctResourceReservedMcsDl           value=50   AND
    ...    Add param to delta       ${cell_5002_path}       minPctResourceReservedMcsDl           value=50   AND
    ...    Add param to delta       ${bts_path}       carrierAggregationSupportList         value=${cASupportList}
    ${delta}                 Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}


Delta commissioning for CA ABIO
    [Arguments]
    ...          ${cell_1_path}=MRBTS-51003/NRBTS-51003/NRCELL-1
    ...          ${cell_2_path}=MRBTS-51003/NRBTS-51003/NRCELL-2
    ...          ${cell_3_path}=MRBTS-51003/NRBTS-51003/NRCELL-3
    ...          ${bts_path}=MRBTS-51003/NRBTS-51003/NRDU-1
    Initialise delta store
    Run keywords
    ...    Add param to delta       ${cell_1_path}          actUlDftSOfdm        value=true   AND
    ...    Add param to delta       ${cell_2_path}          actUlDftSOfdm        value=true   AND
    ...    Add param to delta       ${cell_3_path}          actUlDftSOfdm        value=true   AND
    ...    Add param to delta       ${bts_path}             flexibleCAMode       value=MixedCAMode   AND
    ...    Add param to delta       ${bts_path}             actInterNumerologyCa   value=true   AND
    ...    Add param to delta       ${cell_1_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_2_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_3_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_1_path}          targetPctResourceReservedMcsUl           value=100   AND
    ...    Add param to delta       ${cell_2_path}          targetPctResourceReservedMcsUl           value=100   AND
    ...    Add param to delta       ${cell_3_path}          targetPctResourceReservedMcsUl           value=100   AND
    ...    Add param to delta       ${cell_1_path}          targetPctResourceReservedMcsDl           value=60   AND
    ...    Add param to delta       ${cell_2_path}          targetPctResourceReservedMcsDl           value=60   AND
    ...    Add param to delta       ${cell_3_path}          targetPctResourceReservedMcsDl           value=60   AND
    ...    Add param to delta       ${cell_1_path}          minPctResourceReservedMcsUl           value=60   AND
    ...    Add param to delta       ${cell_2_path}          minPctResourceReservedMcsUl           value=60   AND
    ...    Add param to delta       ${cell_3_path}          minPctResourceReservedMcsUl           value=60   AND
    ...    Add param to delta       ${cell_1_path}          minPctResourceReservedMcsDl           value=50   AND
    ...    Add param to delta       ${cell_2_path}          minPctResourceReservedMcsDl           value=50   AND
    ...    Add param to delta       ${cell_3_path}          minPctResourceReservedMcsDl           value=50
    ${delta}                 Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}

Delta commissioning for CA ABIP
    [Arguments]
    ...          ${cell_5001_path}=MRBTS-50017/NRBTS-50017/NRCELL-5001
    ...          ${cell_5002_path}=MRBTS-50017/NRBTS-50017/NRCELL-5002
    ...          ${bts_5002_path}=MRBTS-50017/NRBTS-50017/NRDU-1
    Initialise delta store
    Run keywords
    ...    Add param to delta       ${cell_5001_path}       actUlDftSOfdm        value=true   AND
    ...    Add param to delta       ${cell_5002_path}       actUlDftSOfdm        value=true   AND
    ...    Add param to delta       ${bts_5002_path}        flexibleCAMode       value=MixedCAMode   AND
    ...    Add param to delta       ${bts_5002_path}        actInterNumerologyCa   value=true   AND
    ...    Add param to delta       ${cell_5001_path}       actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_5002_path}       actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_5001_path}       targetPctResourceReservedMcsUl           value=100   AND
    ...    Add param to delta       ${cell_5002_path}       targetPctResourceReservedMcsUl           value=100   AND
    ...    Add param to delta       ${cell_5001_path}       targetPctResourceReservedMcsDl           value=60   AND
    ...    Add param to delta       ${cell_5002_path}       targetPctResourceReservedMcsDl           value=60   AND
    ...    Add param to delta       ${cell_5001_path}       minPctResourceReservedMcsUl           value=60   AND
    ...    Add param to delta       ${cell_5002_path}       minPctResourceReservedMcsUl           value=60   AND
    ...    Add param to delta       ${cell_5001_path}       minPctResourceReservedMcsDl           value=50   AND
    ...    Add param to delta       ${cell_5002_path}       minPctResourceReservedMcsDl           value=50
    ${delta}                 Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}


Delta commissioning 8663 T153
    [Arguments]
    ...          ${cell_1_path}=MRBTS-51006/NRBTS-51006/NRCELL-1
    ...          ${cell_2_path}=MRBTS-51006/NRBTS-51006/NRCELL-2
    ...          ${bts_path}=MRBTS-51006/NRBTS-51006/NRDU-1
    ${cASupportList}    Create list    none
    Initialise delta store
    Run keywords
    ...    Add param to delta       ${cell_1_path}          actDl256Qam             value=true   AND
    ...    Add param to delta       ${cell_2_path}          actUl256Qam             value=true   AND
    ...    Add param to delta       ${cell_1_path}          actDl256Qam             value=true   AND
    ...    Add param to delta       ${cell_2_path}          actUl256Qam             value=true   AND
    ...    Add param to delta       ${cell_1_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${cell_2_path}          actAdaptiveReTxResMcs   value=true   AND
    ...    Add param to delta       ${bts_path}             actInterNumerologyCa    value=true   AND
    ...    Add param to delta       ${bts_path}             flexibleCAMode          value=BasicCAMode   AND
    ...    Add param to delta       ${cell_1_path}          targetPctResourceReservedMcsDl           value=70   AND
    ...    Add param to delta       ${cell_2_path}          targetPctResourceReservedMcsDl           value=70   AND
    ...    Add param to delta       ${cell_1_path}          minPctResourceReservedMcsDl           value=50   AND
    ...    Add param to delta       ${cell_2_path}          minPctResourceReservedMcsDl           value=50   AND
    ...    Add param to delta       ${bts_path}             carrierAggregationSupportList         value=${cASupportList}
    ${delta}                 Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}
