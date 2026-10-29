# Different SCF configurations for different bandwidth
modify_scf_paratmer_64_1987 = [
    {'dist_name': 'MRBTS-ID/NRBTS-ID/NRCELL-1', 'parameter': 'actDl256Qam', 'value': 'false'}
]

modify_scf_paratmer_256_1987 = [
    {'dist_name': 'MRBTS-ID/NRBTS-ID/NRCELL-1', 'parameter': 'actDl256Qam', 'value': 'true'}
]

# throughput percentage
TPUT_PERCENTAGE_1987 = {
    'min_percent': 0.85,
    'target_avg_percent': 0.95,
}

# NSA send throughput & expect throughput
NSA_QAM256_2X2_TPUT_1987 = {
    'ul_send': '100M',
    'dl_send': '700M',
    'ul_exp_tp': 69,
    'dl_exp_tp': 419
}

NSA_QAM64_2X2_TPUT_1987 = {
    'ul_send': '100M',
    'dl_send': '700M',
    'ul_exp_tp': 69,
    'dl_exp_tp': 317
}

NSA_QAM256_4X4_TPUT_1987 = {
    'ul_send': '100M',
    'dl_send': '1000M',
    'ul_exp_tp': 69,
    'dl_exp_tp': 837
}

NSA_QAM256_4X4_TPUT_TCP_1987 = {
    'ul_send': '0M',
    'dl_send': '1000M',
    'ul_exp_tp': 0,
    'dl_exp_tp': 837
}

# SA send throughput & expect throughput
SA_QAM64_2X2_TPUT_1987 = {
    'ul_send': '200M',
    'dl_send': '500M',
    'ul_exp_tp': 139,
    'dl_exp_tp': 312
}

SA_QAM256_4X4_TPUT_1987 = {
    'ul_send': '200M',
    'dl_send': '1000M',
    'ul_exp_tp': 139,
    'dl_exp_tp': 810
}

# TTI check value
TTI_VALUE_64QAM_1987 = {
    'expect_mcs': 28,
    'expect_cqi': 15,
    'expect_prbs': 189,
    'expect_ptrs': 'PTRS_OFF'
}

TTI_VALUE_256QAM_1987 = {
    'expect_mcs': 27,
    'expect_cqi': 15,
    'expect_prbs': 189,
    'expect_ptrs': 'PTRS_OFF'
}

TTI_PERCENTAGE_PEAK_1987 = {
    'mcs': 0.9,
    'cqi': 0.95,
    'prbs': 0.9
}

TTI_PERCENTAGE_TRAFFIC = {
    'mcs': 0.5,
    'cqi': 0.9,
    'prbs': 0.9
}

SRS_check_1987 = {
    'freqDomainPosition_exp': 0,
    'c_SRS_exp': 45,
    'b_SRS_exp': 0,
    'b_hop_exp': 0
}
