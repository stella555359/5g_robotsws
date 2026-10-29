import os
import shutil


ATTENUATION_VALUE_default = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 5,
    'atten_value_of_port3': 5,
    'atten_value_of_port4': 126,
    'atten_value_of_port5': 126,
    'atten_value_of_port6': 126,
    'atten_value_of_port7': 126,
    'atten_value_of_port8': 0,
    'atten_value_of_port9': 5,
    'atten_value_of_port10': 10,
    'atten_value_of_port11': 0,
    'atten_value_of_port12': 127,
    'atten_value_of_port13': 127,
    'atten_value_of_port14': 0,
    'atten_value_of_port15': 0
}

# tput_define = {
#     63: {
#         'dl_exp': 1415,
#         'dl_tp': '1500M',
#         'ul_exp': 215,
#         'ul_tp': '300M',
#         'ue_index': 0
#     },
#     72: {
#         'dl_exp': 99,
#         'dl_tp': '120M',
#         'ul_exp': 44,
#         'ul_tp': '100M',
#         'ue_index': 0
#     },
# }
cell_list = {
}

tput_define = {
    63: {
        'dl_exp': 200,
        'dl_tp': '300M',
        'ul_exp': 100,
        'ul_tp': '200M',
        'ue_index': 0
    },
    72: {
        'dl_exp': 99,
        'dl_tp': '120M',
        'ul_exp': 44,
        'ul_tp': '100M',
        'ue_index': 0
    },
}

tput_define_single_cell = {
    63: {
        'dl_exp': 1400,
        'dl_tp': '1500M',
        'ul_exp': 200,
        'ul_tp': '300M',
        'ue_index': 0
    },
    72: {
        'dl_exp': 99,
        'dl_tp': '120M',
        'ul_exp': 44,
        'ul_tp': '100M',
        'ue_index': 0
    },
}

tput_define_HO = {
    63: {
        'dl_exp': 200,
        'dl_tp': '300M',
        'ul_exp': 50,
        'ul_tp': '100M',
        'ue_index': 0
    },
    72: {
        'dl_exp': 50,
        'dl_tp': '100M',
        'ul_exp': 20,
        'ul_tp': '100M',
        'ue_index': 0
    },
}

rate_for_stream = {
    'SBTS22R4': '0.9',
    'master': '0.8'
}

rate_for_stream_min = {
    'SBTS22R4': '0.8',
    'master': '0.8'
}


def replace_scf_file_to_current_bts(current_path_file, new_file):
    '''
    this function's purpose:
        replacing the scf under the current robotws/commissionings with the scf download from the current BTS
    Param:
        Param current_path_file: current scf under robotws/commissionings path
        Param new_file: the scf download from current BTS
    '''
    current_path = os.path.abspath(current_path_file)
    father_path = os.path.dirname(current_path)
    new_path_file = os.path.abspath(new_file)
    new_father_path = os.path.dirname(new_path_file)
    re = os.path.exists(path=current_path)
    print(re)
    print(current_path, father_path)
    print(new_path_file, new_father_path)
    if re:
        os.remove(path=current_path)
        shutil.copy(src=new_path_file, dst=father_path)
    else:
        shutil.copy(src=new_path_file, dst=father_path)
