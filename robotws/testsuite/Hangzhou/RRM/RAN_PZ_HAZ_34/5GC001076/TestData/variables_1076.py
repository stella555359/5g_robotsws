# Different SCF configurations for different bandwidth
modify_scf_paratmer_64 = [
    {'dist_name': 'MRBTS-5943/NRBTS-5943/NRCELL-1', 'parameter': 'dlDMRSAdditionalPosition', 'value': 'Automatic'},
    {'dist_name': 'MRBTS-5943/NRBTS-5943/NRCELL-1', 'parameter': 'ulDMRSAdditionalPosition', 'value': 'Automatic'},
    {'dist_name': 'MRBTS-5956/NRBTS-5956/NRCELL-1', 'parameter': 'actDl256Qam', 'value': 'false'}
]

modify_scf_paratmer_256 = [
    {'dist_name': 'MRBTS-5943/NRBTS-5943/NRCELL-1', 'parameter': 'dlDMRSAdditionalPosition', 'value': 'Automatic'},
    {'dist_name': 'MRBTS-5943/NRBTS-5943/NRCELL-1', 'parameter': 'ulDMRSAdditionalPosition', 'value': 'Automatic'},
    {'dist_name': 'MRBTS-5956/NRBTS-5956/NRCELL-1', 'parameter': 'actDl256Qam', 'value': 'true'}
]

# throughput percentage
TPUT_PERCENTAGE = {
    'min_percent': 0.85,
    'target_avg_percent': 0.95,
}

# send throughput & expect throughput
NSA_QAM256_2X2_TPUT = {
    'ul_send': '100M',
    'dl_send': '500M',
    'ul_exp_tp': 24,
    'dl_exp_tp': 328
}

NSA_QAM64_2X2_TPUT = {
    'ul_send': '100M',
    'dl_send': '500M',
    'ul_exp_tp': 24,
    'dl_exp_tp': 249
}

SA_QAM64_2X2_TPUT = {
    'ul_send': '100M',
    'dl_send': '500M',
    'ul_exp_tp': 48,
    'dl_exp_tp': 259
}

NSA_QAM256_4X4_TPUT = {
    'ul_send': '100M',
    'dl_send': '1000M',
    'ul_exp_tp': 24,
    'dl_exp_tp': 650
}

NSA_QAM256_4X4_TPUT_TCP = {
    'ul_send': '0M',
    'dl_send': '1000M',
    'ul_exp_tp': 0,
    'dl_exp_tp': 650
}

SA_QAM256_4X4_TPUT = {
    'ul_send': '100M',
    'dl_send': '1000M',
    'ul_exp_tp': 48,
    'dl_exp_tp': 686
}

# TTI check value
TTI_VALUE_64QAM = {
    'expect_mcs': 28,
    'expect_cqi': 15,
    'expect_prbs': 133,
    'expect_ptrs': 'PTRS_OFF'
}

TTI_VALUE_256QAM = {
    'expect_mcs': 27,
    'expect_cqi': 15,
    'expect_prbs': 133,
    'expect_ptrs': 'PTRS_OFF'
}

TTI_PERCENTAGE_PEAK = {
    'mcs': 0.9,
    'cqi': 0.95,
    'prbs': 0.9
}

TTI_PERCENTAGE_TRAFFIC = {
    'mcs': 0.5,
    'cqi': 0.9,
    'prbs': 0.9
}

SRS_check = {
    'freqDomainPosition_exp': 0,
    'c_SRS_exp': 33,
    'b_SRS_exp': 0,
    'b_hop_exp': 0
}
