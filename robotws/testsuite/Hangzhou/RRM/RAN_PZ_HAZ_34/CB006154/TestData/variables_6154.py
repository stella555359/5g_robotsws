# Different SCF configurations for different bandwidth
modify_scf_paratmer_64 = [
    {'dist_name': 'MRBTS-5956/NRBTS-5956/NRCELL-1', 'parameter': 'actDl256Qam', 'value': 'false'}
]

modify_scf_paratmer_256 = [
    {'dist_name': 'MRBTS-5956/NRBTS-5956/NRCELL-1', 'parameter': 'actDl256Qam', 'value': 'true'}
]

# throughput percentage
TPUT_PERCENTAGE = {
    'min_percent': 0.85,
    'target_avg_percent': 0.95,
}

# send throughput & expect throughput
SA_QAM256_2X2_TPUT = {
    'ul_send': '200M',
    'dl_send': '800M',
    'ul_exp_tp': 76,
    'dl_exp_tp': 481
}

SA_QAM256_4X4_TPUT_TCP = {
    'ul_send': '0M',
    'dl_send': '1000M',
    'ul_exp_tp': 0,
    'dl_exp_tp': 882
}

SA_QAM256_4X4_TPUT = {
    'ul_send': '100M',
    'dl_send': '900M',
    'ul_exp_tp': 76,
    'dl_exp_tp': 878
}

# TTI check value
# TTI_VALUE_64QAM = {
#     'expect_mcs': 27,
#     'expect_cqi': 15,
#     'expect_prbs': 189,
#     'expect_ptrs': 'PTRS_OFF'
# }
#
# TTI_VALUE_256QAM = {
#     'expect_mcs': 27,
#     'expect_cqi': 15,
#     'expect_prbs': 189,
#     'expect_ptrs': 'PTRS_OFF'
# }
#
# TTI_PERCENTAGE_PEAK = {
#     'mcs': 0.9,
#     'cqi': 0.95,
#     'prbs': 0.9
# }
#
# TTI_PERCENTAGE_TRAFFIC = {
#     'mcs': 0.5,
#     'cqi': 0.9,
#     'prbs': 0.9
# }
