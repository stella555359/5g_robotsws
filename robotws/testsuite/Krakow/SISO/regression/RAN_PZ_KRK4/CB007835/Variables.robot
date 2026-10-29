*** Variables ***
################## Call Processing ####################
${interval}                 15min
${throughput_duration}      20min

# single ue tput config ##################
${single_ue_tput_dl}        2000Mbits/sec
${single_ue_tput_ul}        250Mbits/sec

${min_single_ue_tput_dl}    1900Mbits/sec
${min_single_ue_tput_ul}    225Mbits/sec

# endc tput config #######################
${endc_tput_dl}             2400Mbits/sec
${min_endc_tput_dl}         2100Mbits/sec

${endc_tput_ul}             300Mbits/sec
${min_endc_tput_ul}         240Mbits/sec

# multi ue tput config ###################
${multi_ue_tput_dl}         1000Mbits/sec
${multi_ue_tput_ul}         125Mbits/sec

${min_multi_ue_tput_dl}     950Mbits/sec
${min_multi_ue_tput_ul}     115Mbits/sec

############### OAM and UUF #########################

${runs_time_duration}    ${10}
${runs_of_WebEM_access}  ${5}
${runs_of_uuf_reset}     ${20}
@{CUSTOMERS_LIST}=      USCC