from SIC_addresses import ASIA, ASIB, ASIK, ASIL, ASIM, ABIA, ABIC, ABIL, ABIN, ABIO, ABIP, ABIQ, ASOE, ASOF
import json
import re

'''[Documentation]
Author: Damian Kotula
Maintainer: Damian Kotula
This script is used to verify if snapshot files from SMOD/BBMODs have node_id's according to
specification scheme described in RPREQ_8838.'''


def compile_Physical_NodeID_regex(board_model, board_position):
    '''This function compiles allowed Physical_NodeID regex for BBmod/Smod taking into account their position in rack'''
    module = eval(board_model)
    module['Physical_NodeID']['Domain_ID'] = board_position[0]  # horizontal position
    if board_model[1] == 'B':  # checks if it's baseband module
        module['Physical_NodeID']['Board_ID'] = board_position[1]  # vertical position
    Physical_NodeID = f"[{module['Physical_NodeID']['Domain_ID']}][{module['Physical_NodeID']['Board_ID']}]"\
                      f"[{module['Physical_NodeID']['SoC_IDs']}][{module['Physical_NodeID']['Core_IDs']}]"
    regex = re.compile(rf"^{Physical_NodeID}$")
    return regex


def compile_VirtualNodeID_BoardID_regex(board_model, board_position):
    '''This function compiles allowed VirtualNodeID BoardID rule regex for BBmod/Smod taking into account
     their position in rack'''
    module = eval(board_model)
    if board_model[1] == 'B':  # checks if it's baseband module
        module['Virtual_NodeID_BoardID']['Board_ID'] = board_position[1]  # vertical position
    VirtualNodeID_BoardID = f"[{module['Virtual_NodeID_BoardID']['Domain_ID']}]"\
                            f"[{module['Virtual_NodeID_BoardID']['Board_ID']}]"\
                            f"[{module['Virtual_NodeID_BoardID']['SoC_IDs']}]"\
                            f"[{module['Virtual_NodeID_BoardID']['Offset_IDs']}]"
    regex = re.compile(rf"^{VirtualNodeID_BoardID}$")
    return regex


def compile_VirtualNodeID_CommonPool_regex(board_model, board_position):
    '''This function compiles allowed VirtualNodeID CommonPool rule regex for BBmod/Smod taking into account
     their position in rack'''
    module = eval(board_model)
    if board_model[1] == 'B':  # checks if it's baseband module
        if board_position[1] == '2':  # vertical position
            module['Virtual_NodeID_CommonPool']['Board_ID'] = '7C'
        elif board_position[1] == '3':  # vertical position
            module['Virtual_NodeID_CommonPool']['Board_ID'] = '8D'
        elif board_position[1] == '4':  # vertical position
            module['Virtual_NodeID_CommonPool']['Board_ID'] = '9E'
    VirtualNodeID_CommonPool = f"[{module['Virtual_NodeID_CommonPool']['Domain_ID']}]"\
                               f"[{module['Virtual_NodeID_CommonPool']['Board_ID']}]"\
                               f"[{module['Virtual_NodeID_CommonPool']['SoC_IDs']}]"\
                               f"[{module['Virtual_NodeID_CommonPool']['Offset_IDs']}]"
    regex = re.compile(rf"^{VirtualNodeID_CommonPool}$")
    return regex


def compile_ABIA_DSP_regex(board_position):
    '''This function compiles allowed regex for ABIA DSP taking into account their position in rack'''
    Domain_ID = board_position[0]  # horizontal position
    Board_ID = board_position[1]  # vertical position
    ABIA_DSP = f"[{Domain_ID}][{Board_ID}][3-6][1-8]"
    regex = re.compile(rf"^{ABIA_DSP}$")
    return regex


def compile_patterns_for_ABIA_DSP(ABIA_positions):
    '''This function compiles additional regex for SMODs that have ABIA in their subrack - DSP files from ABIA
    are saved on SMOD'''
    left_smod = ''
    right_smod = ''
    for position in ABIA_positions:
        dsp_regex = compile_ABIA_DSP_regex(position)
        if position[0] == '1':
            left_smod += f'{dsp_regex.pattern}' + '|'
        else:
            right_smod += f'{dsp_regex.pattern}' + '|'
    regex_for_left_SMOD = re.compile(f'{left_smod.rstrip("|")}')
    regex_for_right_SMOD = re.compile(f'{right_smod.rstrip("|")}')
    return regex_for_left_SMOD, regex_for_right_SMOD


def compile_board_regex(board_model, board_position):
    '''This function compiles total allowed regex for BBmod/Smod including Physical_NodeID, VirtualNodeID BoardID,
    VirtualNodeID CommonPool regexes based on SIC_adresses for each board'''
    if board_model in ['ASIA', 'ABIA']:
        Physical_NodeID = compile_Physical_NodeID_regex(board_model, board_position)
        VirtualNodeID_BoardID = compile_VirtualNodeID_BoardID_regex(board_model, board_position)
        allowed_regex = re.compile(f'{Physical_NodeID.pattern}|{VirtualNodeID_BoardID.pattern}')
        return allowed_regex
    elif board_model in ['ABIC', 'ABIL']:
        Physical_NodeID = compile_Physical_NodeID_regex(board_model, board_position)
        VirtualNodeID_CommonPool = compile_VirtualNodeID_CommonPool_regex(board_model, board_position)
        allowed_regex = re.compile(f'{Physical_NodeID.pattern}|{VirtualNodeID_CommonPool.pattern}')
        return allowed_regex
    else:
        Physical_NodeID = compile_Physical_NodeID_regex(board_model, board_position)
        VirtualNodeID_BoardID = compile_VirtualNodeID_BoardID_regex(board_model, board_position)
        VirtualNodeID_CommonPool = compile_VirtualNodeID_CommonPool_regex(board_model, board_position)
        allowed_regex = re.compile(f'{Physical_NodeID.pattern}|{VirtualNodeID_BoardID.pattern}|'
                                   f'{VirtualNodeID_CommonPool.pattern}')
        return allowed_regex


def create_snapshot_filelist_dict(file_path):
    '''This function transforms txt filelist to a dictionary saved in json for further processing.'''
    filelist_dict = {}
    with open(file_path, 'r') as file_list:
        current_zip = None
        current_files = []

        for line in file_list:
            stripped_line = line.strip()
            if stripped_line.endswith(':') or not line.startswith((' ', '\t')):
                if current_zip is not None:
                    filelist_dict[current_zip] = current_files
                current_zip = stripped_line.rstrip(':')
                current_files = []
            else:
                current_files.append(stripped_line)

        if current_zip is not None:
            filelist_dict[current_zip] = current_files

    output_filename = f"{output_dir}/snapshot_filelist_dict.json"
    with open(output_filename, 'w') as json_file:
        json.dump(filelist_dict, json_file, indent=2)
    return output_filename


def get_files_from_board(filename, board_location):
    '''This fuction gathers all log files from the same board into separate dictionary and saves as json file.'''
    with open(filename, 'r') as snapshot_dict:
        snapshot_dict = json.load(snapshot_dict)
        position = str(board_location) + "\\w{2}" + "_part_"
        files_from_position = {}
        for zip_container, board_files in snapshot_dict.items():
            match = re.search(position, zip_container)
            if match:
                files_from_position[zip_container] = board_files
    output_filename = f"{output_dir}/files_from_position_{board_location}.json"
    with open(output_filename, 'w') as board_json:
        json.dump(files_from_position, board_json, indent=2)
    return output_filename


def count_files_from_board(json_file_dict):
    '''This function counts all log files from each board before verifying, it is used to check If all logs
    were checked correctly.'''
    with open(json_file_dict, 'r') as filelist:
        log_files = json.load(filelist)
    file_count = 0
    for key in log_files.keys():
        files = log_files[key]
        file_count += len(files)
    return file_count


def find_nodeid_pattern(filename):
    '''This function is used to find files which filenames have format BTS_ID_NODE_ID'''
    match = re.search(btsid+r'_([a-zA-Z\d]{4})_', filename)
    if match:
        return match.group(1)
    return None


def verify_nodes(filelist_path, allowed_regex, board_model):
    '''This function is used to verify if every log file from particular system/baseband module has NodeID
    in filename assigned according to specification for that particular module.'''
    allowed_node_ids = []
    not_allowed_node_ids = []
    other = []
    with open(filelist_path, 'r') as filelist:
        filelist = json.load(filelist)
        for zip_container, log_files in filelist.items():
            for log_file in log_files:
                node_id = find_nodeid_pattern(log_file)
                if node_id is not None:
                    if allowed_regex.match(node_id):
                        allowed_node_ids.append(log_file)
                    else:
                        not_allowed_node_ids.append(log_file)
                        print(f"Not allowed node_id in {log_file}")
                else:
                    other.append(log_file)
                    print(f"Not expected file found, check manually: {log_file}")

    with open(f"{output_dir}/allowed_node_ids_{board_model}.txt", 'w') as allowed_file:
        allowed_file.write('\n'.join(allowed_node_ids))
    with open(f"{output_dir}/not_allowed_node_ids_{board_model}.txt", 'w') as not_allowed_file:
        not_allowed_file.write('\n'.join(not_allowed_node_ids))
    if other:
        with open(f"{output_dir}/other_files_{board_model}.txt", 'w') as other_file:
            other_file.write('\n'.join(other))


def run_node_id_verification(bts_id, tl_configuration_dict, snapshot_filelist_path, output_folder):
    '''This is main function to run node_id_verification. Logs from snapshot filelist are splited here into
    separate files based on board position they come from and then verified against NodeID regex allowed on that board.
    If ABIA is in configuration, regex of ABIA DSP logs are added to SMOD regex, as DSP files are saved on SMOD'''
    global btsid
    global output_dir
    btsid = bts_id
    output_dir = output_folder
    smods_with_ABIA = []
    snapshot_filelist_dict = create_snapshot_filelist_dict(snapshot_filelist_path)

    if 'ABIA' in tl_configuration_dict.values():
        ABIA_positions = [key for key, value in tl_configuration_dict.items() if value == 'ABIA']
        smods_with_ABIA = {(key[0] + '0') for key in ABIA_positions}
        left_smod_additional_regex, right_smod_additional_regex = compile_patterns_for_ABIA_DSP(ABIA_positions)

    for board_position, board_type in tl_configuration_dict.items():
        board_name = f'{tl_configuration_dict[board_position]}_{board_position}'
        files_from_board = get_files_from_board(snapshot_filelist_dict, board_position)
        allowed_regex = compile_board_regex(board_type, board_position)
        if board_position == '10' and board_position in smods_with_ABIA:
            allowed_regex = re.compile(f'{allowed_regex.pattern}|{left_smod_additional_regex.pattern}')
        if board_position == '20' and board_position in smods_with_ABIA:
            allowed_regex = re.compile(f'{allowed_regex.pattern}|{right_smod_additional_regex.pattern}')
        print(f'{board_type} in position {board_position} regex: {allowed_regex}')
        verify_nodes(files_from_board, allowed_regex, board_name)
