import os
import os.path
import re
import math

from robot.libraries.BuiltIn import BuiltIn
rob = BuiltIn()


def convert_sinr2level(sinr):
    """
    Convert a sinr as a floating representation with 4 decimals to a level as an integer
    Here is the definition of the level:
        Level1: [SINR <= -8dB]
        Level2: [-8dB < SINR <= -6dB]
        ...
        Level24: [36dB < SINR <= 38dB]
        Level25: [38dB < SINR]
    :param sinr: value of the sinr in floating format
    :return level: value of the level in integer format
    """
    level = int(max(min(sinr/2 + 5.9999999, 25.0), 1.0))
    return level


def count_sinr_singletx(file_path, file_name, lua_path):
    """
    First convert the pcap file in pdml format.
    Keep only lines with the fields : sinr, dtx and ulrank of the message UlData_PuschReceiveRespPs
    Then go through every line of the pdml:
    - if it is the DTX value, store it
    - if it is the SINR value for antenna 0 store it (except for the first one that shall be ignored)
    - if it is the UL rank and if it is equal to -1 and if there is no DTX
        - compute the average of both antenna values, convert this average to level and
          increase the associated counter
    It should assert if the file_name does not exist
    It should assert if the file luashark.lua is not found
    It should assert if no record has been found
    :param file_path: path of the pcap file to be inspected
    :param file_name: name of the pcap file to be inspected
    :param lua_path: path of the luashark.lua file to be used for decoding
    :return Table with the number of times a certain level has been reported in case of rank1
    """

    full_name = file_path + '/' + file_name
    # Assert if the file does not exist
    assert os.path.exists(full_name), 'The file {} does not exist'.format(full_name)
    # Assert if the lua file does not exist
    lua = lua_path + 'luashark.lua'
    assert os.path.exists(lua), 'The file {} does not exist'.format(lua)

    # Convert the pcap file into pdml file and keep only lines for UlData_PuschReceiveRespPs
    pdml_name = file_path + '/' + 'l1l2_filtered.pdml'
    pcap_filter = 'UlData_PuschReceiveRespPs.sinr.sinr_item_0|UlData_PuschReceiveRespPs.grants_item_'
    os.system('tshark -r "{}" -X lua_script:{} -T pdml | grep -E "{}" > "{}"'.
              format(full_name, lua, pcap_filter, pdml_name))
    # Read the pdml file
    input_file = open(pdml_name)
    # Define the regex for the interesting lines
    re_sinrmimo2x2 = re.compile(r'UlData_PuschReceiveRespPs.sinr.sinr_item_0.+ show="([0-9.]+)"')
    re_dtxmimo2x2 = re.compile(r'UlData_PuschReceiveRespPs.grants_item_[0-9]+.dtx".+ show="([0-9]+)"')
    re_rankmimo2x2 = re.compile(r'UlData_PuschReceiveRespPs.grants_item_[0-9]+.ulRank".+ show="([0-9]+)"')

    nb_rank1 = 0
    first_sinr = True
    sinr0 = None
    dtx = -1
    nb_dtx = 0
    nb_line = 0
    cpt_level_rank1 = 26 * [0]
    # For each packet
    for line in input_file:
        nb_line += 1

        # Look for the DTX MIMO 2x2 in the line
        group_list = re_dtxmimo2x2.search(line)
        # If something has been found
        if group_list:
            # Retrieve the value of the parameter
            data_value = group_list.groups()[0]
            dtx = int(data_value)

        # Look for the SINR MIMO2x2 in the line
        group_list = re_sinrmimo2x2.search(line)
        # If something has been found
        if group_list:
            # Retrieve the name and the value of the parameter
            data_value = group_list.groups()[0]
            if not first_sinr:
                sinr0 = float(data_value)
            else:
                first_sinr = False

        # Look for the UL GRANT MIMO 2x2 in the line
        group_list = re_rankmimo2x2.search(line)
        # If something has been found
        if group_list:
            # Retrieve the value of the parameter
            data_value = group_list.groups()[0]
            rank = int(data_value)
            if rank == 255:
                if sinr0:
                    if dtx == 0:
                        nb_rank1 += 1
                        level = convert_sinr2level(sinr0)
                        cpt_level_rank1[level] += 1
                    else:
                        nb_dtx += 1
                sinr0 = None
                dtx = -1

    # Assert if no line has been filtered in the trace
    assert nb_line > 0, 'No line with "{}" has been found in file {}'.format(pcap_filter, file_name)
    rob.log('No error detected. lines analysed {} - rank1: {} - dtx: {}'.
            format(nb_line, nb_rank1, nb_dtx), 'INFO')

    return cpt_level_rank1


def count_sinr_rank2(file_path, file_name, lua_path):
    """
    First convert the pcap file in pdml format.
    Keep only lines with the fields : ulPmiRank2Sinr, dtx and ulrank of the message UlData_PuschReceiveRespPs
    Then go through every line of the pdml:
    - if it is the DTX value, store it
    - if it is the SINR MIMO 2x2 value for antenna 0 store it
    - if it is the SINR MIMO 2x2 value for antenna 1 store it
    - if it is the UL rank and if it is equal to 2 and if there is no DTX
        - compute the average of both antenna values, convert this average to level and
          increase the associated counter
    It should assert if the file_name does not exist
    It should assert if the file luashark.lua is not found
    It should assert if no record has been found
    :param file_path: path of the pcap file to be inspected
    :param file_name: name of the pcap file to be inspected
    :param lua_path: path of the luashark.lua file to be used for decoding
    :return Table with the number of times a certain level has been reported in case of rank2
    """

    full_name = file_path + '/' + file_name
    # Assert if the file does not exist
    assert os.path.exists(full_name), 'The file {} does not exist'.format(full_name)
    # Assert if the lua file does not exist
    lua = lua_path + 'luashark.lua'
    assert os.path.exists(lua), 'The file {} does not exist'.format(lua)

    # Convert the pcap file into pdml file and keep only lines for UlData_PuschReceiveRespPs
    pdml_name = file_path + '/' + 'l1l2_filtered.pdml'
    pcap_filter = 'UlData_PuschReceiveRespPs.ulPmiRank2Sinr|UlData_PuschReceiveRespPs.grants_item_'
    os.system('tshark -r "{}" -X lua_script:{} -T pdml | grep -E "{}" > "{}"'.
              format(full_name, lua, pcap_filter, pdml_name))
    # Read the pdml file
    input_file = open(pdml_name)
    # Define the regex for the interesting lines
    re_sinrmimo2x2 = re.compile(r'UlData_PuschReceiveRespPs.ulPmiRank2Sinr.([A-Za-z0-9_]+).+ show="([0-9.]+)"')
    re_dtxmimo2x2 = re.compile(r'UlData_PuschReceiveRespPs.grants_item_[0-9]+.dtx".+ show="([0-9]+)"')
    re_rankmimo2x2 = re.compile(r'UlData_PuschReceiveRespPs.grants_item_[0-9]+.ulRank".+ show="([0-9]+)"')

    nb_rank2 = 0
    sinr0 = None
    sinr1 = None
    dtx = -1
    nb_dtx = 0
    nb_line = 0
    cpt_level_rank2 = 26 * [0]
    # For each packet
    for line in input_file:
        nb_line += 1

        # Look for the DTX MIMO 2x2 in the line
        group_list = re_dtxmimo2x2.search(line)
        # If something has been found
        if group_list:
            # Retrieve the value of the parameter
            data_value = group_list.groups()[0]
            dtx = int(data_value)

        # Look for the SINR MIMO2x2 in the line
        group_list = re_sinrmimo2x2.search(line)
        # If something has been found
        if group_list:
            # Retrieve the name and the value of the parameter
            data_name = group_list.groups()[0]
            data_value = group_list.groups()[1]
            if data_name == 'ulPmiRank2Sinr_item_0':
                sinr0 = float(data_value)
            elif data_name == 'ulPmiRank2Sinr_item_1':
                sinr1 = float(data_value)

        # Look for the UL GRANT MIMO 2x2 in the line
        group_list = re_rankmimo2x2.search(line)
        # If something has been found
        if group_list:
            # Retrieve the value of the parameter
            data_value = group_list.groups()[0]
            rank = int(data_value)
            if rank == 2:
                if sinr0 and sinr1:
                    if dtx == 0:
                        nb_rank2 += 1
                        sinr = 10 * math.log10((math.pow(10, sinr0 / 10.0) + math.pow(10, sinr1 / 10.0)) / 2.0)
                        level = convert_sinr2level(sinr)
                        cpt_level_rank2[level] += 1
                    else:
                        nb_dtx += 1
                sinr0 = None
                sinr1 = None
                dtx = -1

    # Assert if no line has been filtered in the trace
    assert nb_line > 0, 'No line with "{}" has been found in file {}'.format(pcap_filter, file_name)
    rob.log('No error detected. lines analysed {} - rank2: {} - dtx: {}'.
            format(nb_line, nb_rank2, nb_dtx), 'INFO')

    return cpt_level_rank2


def count_sinr_rank1(file_path, file_name, lua_path):
    """
    First convert the pcap file in pdml format.
    Keep only lines containing the field ulPmiRank1Sinr and dtx of the message UlData_SrsReceiveRespPs
    Then go through every line of the pdml:
    - if it is the SINR single TX store it
    - if it is the DTX and it is equal to NO DTX:
        - convert it to level and increase the associated counter
    It should assert if the file_name does not exist
    It should assert if the file luashark.lua is not found
    It should assert if no record has been found
    :param file_path: path of the pcap file to be inspected
    :param file_name: name of the pcap file to be inspected
    :param lua_path: path of the luashark.lua file to be used for decoding
    :return Table with the number of times a certain level has been reported in case of rank1
    """

    full_name = file_path + '/' + file_name
    # Assert if the file does not exist
    assert os.path.exists(full_name), 'The file {} does not exist'.format(full_name)
    # Assert if the lua file does not exist
    lua = lua_path + 'luashark.lua'
    assert os.path.exists(lua), 'The file {} does not exist'.format(lua)

    # Convert the pcap file into pdml file and keep only lines for UlData_PuschReceiveRespPs
    pdml_name = file_path + '/' + 'l1l2_filtered.pdml'
    pcap_filter = \
        'UlData_SrsReceiveRespPs.subcells_item_3.ulPmiRank1Sinr|UlData_SrsReceiveRespPs.subcells_item_3.dtx\\"'
    os.system('tshark -r "{}" -X lua_script:{} -T pdml | grep -E "{}" > "{}"'.
              format(full_name, lua, pcap_filter, pdml_name))
    # Read the pdml file
    input_file = open(pdml_name)
    # Define the regex for the interesting lines
    re_sinrsingtx = re.compile(r'UlData_SrsReceiveRespPs.subcells_item_3.ulPmiRank1Sinr.+ show="([0-9.]+)"')
    re_dtxsingtx = re.compile(r'UlData_SrsReceiveRespPs.subcells_item_3.dtx.+ show="([0-9]+)"')

    nb_singtx = 0
    sinr0 = None
    nb_dtx = 0
    nb_line = 0
    cpt_level_rank = 26 * [0]
    # For each packet
    for line in input_file:
        nb_line += 1

        # Look for the SINR SingleTx in the line
        group_list = re_sinrsingtx.search(line)
        # If something has been found
        if group_list:
            # Retrieve the value of the parameter
            data_value = group_list.groups()[0]
            sinr0 = float(data_value)

        # Look for the DTX SingleTx in the line
        group_list = re_dtxsingtx.search(line)
        # If something has been found
        if group_list:
            # Retrieve the value of the parameter
            data_value = group_list.groups()[0]
            dtx = int(data_value)
            if sinr0:
                nb_singtx += 1
                if dtx == 0:
                    level = convert_sinr2level(sinr0)
                    cpt_level_rank[level] += 1
                else:
                    nb_dtx += 1
                sinr0 = None

    # Assert if no line has been filtered in the trace
    assert nb_line > 0, 'No line with "{}" has been found in file {}'.format(pcap_filter, file_name)
    rob.log('No error detected. lines analysed {} - Single Tx: {} - dtx: {}'.
            format(nb_line, nb_singtx, nb_dtx), 'INFO')

    return cpt_level_rank
