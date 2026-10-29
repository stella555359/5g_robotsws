frequency_3550_3600 = 1023
# frequency_3550_3600 = [
#     'frequency range 3550 - 3555',
#     'frequency range 3555 - 3560',
#     'frequency range 3560 - 3565',
#     'frequency range 3565 - 3570',
#     'frequency range 3570 - 3575',
#     'frequency range 3575 - 3580',
#     'frequency range 3580 - 3585',
#     'frequency range 3585 - 3590',
#     'frequency range 3590 - 3595',
#     'frequency range 3595 - 3560'
# ]

TPUT = {
    'ul_send': '50M',
    'dl_send': '300M',
    'ul_exp_tp': 10,
    'dl_exp_tp': 252
}

tput_define = {
    'common': {1: {
        'dl_exp': 275,
        'dl_tp': '400M',
        'ul_exp': 29.3,
        'ul_tp': '50M',
        'ue_index': 0
    }, 2: {
        'dl_exp': 275,
        'dl_tp': '400M',
        'ul_exp': 29.3,
        'ul_tp': '50M',
        'ue_index': 1
    }, },
    'SBTS00': {1: {
        'dl_exp': 275,
        'dl_tp': '400M',
        'ul_exp': 29.3,
        'ul_tp': '50M',
        'ue_index': 0
    }, 2: {
        'dl_exp': 275,
        'dl_tp': '400M',
        'ul_exp': 29.3,
        'ul_tp': '50M',
        'ue_index': 1
    }, },
    'SBTS23R4': {1: {
        'dl_exp': 275,
        'dl_tp': '400M',
        'ul_exp': 29.3,
        'ul_tp': '50M',
        'ue_index': 0
    }, 2: {
        'dl_exp': 275,
        'dl_tp': '400M',
        'ul_exp': 29.3,
        'ul_tp': '50M',
        'ue_index': 1
    }, },
    'SBTS23R3': {1: {
        'dl_exp': 278.4,
        'dl_tp': '400M',
        'ul_exp': 26.8,
        'ul_tp': '50M',
        'ue_index': 0
    }, 2: {
        'dl_exp': 278.4,
        'dl_tp': '400M',
        'ul_exp': 26.8,
        'ul_tp': '50M',
        'ue_index': 1
    }, },
}
