"""
        Keywords Purpose:
            Keywords to manage logs
            initialy created as Keywords_509.py

        AUTHOR:
            Yves Gorjux       yves.gorjux@nokia.com

        Last update 15.10.20 : annie.wong@nokia.com (add check_slot_distribution)
"""

import pyshark
import requests
import time
import re
import os
import os.path
from collections import defaultdict

from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn


rob = BuiltIn()
ssh_mgt = ssh()


def look_for_length(cap):
    """
    This function count the number of records of a pcap file loaded into memory thanks to pyshark.FileCapture
    This is a workaround because the function len(cap) reports 0
    :param cap: pcap file loaded into memory
    :return: number of records
    """
    # Try to read the records one by one.
    idx = 0
    while True:
        try:
            a = cap[idx]
            idx += 1
        except KeyError:
            # This record idx does not exist. So it is the number of records in the pcap file
            return idx


def check_pcap_traces(file_path, file_name, protocol, filter_pcap, check_list=(), not_check_list=()):
    """
    First clean up the pcap file (as the tcpdump process is kill, last packet may be truncated)
    Then, from this cleanup file, filter messages and check for these messages in the dissection of
    the required protocol
    if a list of string is present and if a list of string is not present.
    It should assert if the number of messages filtered is not equal to the size of the check list and the size
    of the not check list
    It should assert if one string of the check_list is not present in dissection of the message for the protocol
    It should assert if one string of the not_check_list is present in dissection of the message for the protocol
    :param file_path: path of the pcap file to be inspected
    :param file_name: name of the pcap file to be inspected
    :param protocol: protocol to be inspected (should be X2AP or F1AP)
    :param filter_pcap: pcap filter to be applied on the pcap file
            for instance:
            (x2ap.procedureCode == 30) || (x2ap.procedureCode == 27)
    :param check_list: for each message filtered, list of strings that shall be present
    :param not_check_list: for each message filtered, list of strings that shall not be present
    """
    full_name = file_path + '/' + file_name
    rob.log('Clean up the file {}'.format(full_name))
    clean_full_name = file_path + '/Clean_' + file_name
    os.system('editcap "{}" "{}"'.format(full_name, clean_full_name))
    rob.log('Read the cleanup file {}'.format(clean_full_name))
    cap = pyshark.FileCapture(clean_full_name, display_filter=filter_pcap)
    rob.log('File captured. Official length: {}'.format(len(cap)))
    len_cap = look_for_length(cap)
    assert len_cap == len(check_list), '{} records were captured in PCAP while check_list expect {}'. \
        format(len_cap, len(check_list))
    assert len_cap == len(not_check_list), '{} records were captured in PCAP while not_check_list expect {}'. \
        format(len_cap, len(not_check_list))
    rob.log('{} records were captured in PCAP for protocol {}'.format(len_cap, protocol))
    for pkt_idx in range(len(check_list)):
        pkt = str(cap[pkt_idx][protocol]).split('\n')
        for check in check_list[pkt_idx]:
            found = False
            for line in pkt:
                if check in line:
                    found = True
                    break
            assert found, 'String "{}" is not found in PCAP record {}'.format(check, pkt_idx)
            if found:
                rob.log('String "{}" is found in PCAP record {}'.format(check, pkt_idx))
        for not_check in not_check_list[pkt_idx]:
            found = False
            for line in pkt:
                if not_check in line:
                    found = True
                    break
            assert not found, 'String "{}" is found in PCAP record {}'.format(not_check, pkt_idx)
            if not found:
                rob.log('String "{}" is not found in PCAP record {}'.format(not_check, pkt_idx))


def look_ues_in_pcap_traces(file_path, file_name, protocol, filter_pcap, expected_ue_nb):
    """
    Return the list of UE identifiers found in a pcap file, after applying a filter.
    It should assert if the number of UE identifiers is not expected one to guarantee the size of the list
    UE identifiers are listed accordingly to the number of messages captured, in decreasing order
    :param file_path: path of the pcap file to be inspected
    :param file_name: name of the pcap file to be inspected
    :param protocol: protocol to be inspected (should be X2AP or F1AP)
    :param filter_pcap: pcap filter to be applied on the pcap file
            for instance:
            (x2ap.procedureCode == 30) || (x2ap.procedureCode == 27)
    :param expected_ue_nb: number of UE identifiers we are expected. if it is equal to -1, we are expected at least
            one UE
    :return: list of UE identifiers sorted accordingly to the number of messages captured for this identifier
    """
    # Initialise the dictionary that will contain all UE identifiers and the number of messages per identifier
    ues_dict = defaultdict(int)
    # Build the full name of the pcap file
    full_name = file_path + '/' + file_name
    # Cleanup the file by removing truncated records
    rob.log('Clean up the file {}'.format(full_name))
    clean_full_name = file_path + '/Clean_' + file_name
    os.system('editcap "{}" "{}"'.format(full_name, clean_full_name))
    rob.log('Read the cleanup file {}'.format(clean_full_name))
    # Read the pcap file in memory by applying the filter given in argument
    cap = pyshark.FileCapture(clean_full_name, display_filter=filter_pcap)
    rob.log('File captured. Official length: {}'.format(len(cap)))
    # Compute the number of pcap records stored in memory
    len_cap = look_for_length(cap)
    rob.log('{} records were captured in PCAP for protocol {}'.format(len_cap, protocol))
    # For each pcap record in memory
    for pkt_idx in range(len_cap):
        # Take the protocol layer decoding and split it into lines
        pkt = str(cap[pkt_idx][protocol]).split('\n')
        # For each line of the layer
        for line in pkt:
            # We are looking for a line containing the UE identifier
            if protocol == 'X2AP':
                re_ue_id = re.compile(r'\sUE-X2AP-ID: ([0-9]+)')
            elif protocol == 'F1AP':
                re_ue_id = re.compile(r'\sGNB-CU-UE-F1AP-ID: ([0-9]+)')
            group_list = re_ue_id.search(line)
            # We have found this line if the group list is not empty
            if group_list:
                # The value of the UE identifier is in the first element of the group list
                ues_dict[group_list.groups()[0]] += 1
    # Build the list of UE from the UE dictionary sorted by value in reverse order
    list_ues = []
    for ue_id in sorted(ues_dict, key=ues_dict.get, reverse=True):
        list_ues += [ue_id, ]
        rob.log('ue_id: {}, number of messages: {}'.format(ue_id, ues_dict[ue_id]))
    rob.log('list of UEs detected in the pcap: {}'.format(list_ues))
    # Assert if the number of X2 UE identifier found is not the expected one
    if int(expected_ue_nb) >= 0:
        assert len(list_ues) == int(expected_ue_nb), '{} were detected in the trace while {} were expected'. \
            format(len(list_ues), expected_ue_nb)
    else:
        assert len(list_ues) > 0, 'no UE is detected in the trace while at least one is expected'
    return list_ues


def configure_mirroring(addr, user, password, local_asik_script, local_loner_script):
    """
    Configure the mirroring to capture L1L2 traces
    :param addr: IP address of ASIK on which mirroring shall be configured
    :param user: user name to be used for the connection to this ASIK
    :param password: password to be used for the connection to this ASIK
    :param local_asik_script: name of the script to be launched on ASIK
    :param local_loner_script: name of the script launched on the loner by the ASIK script
    :return: none
    """
    # Open the connection to the ASIK of the gNB
    cnx = ssh_mgt.connect_to(addr, user, password)
    rob.log('Session opened to ASIK: {}'.format(cnx), 'DEBUG')
    # Look for mirroring scripts
    remote_path = '/ffs/run/config/scripts'
    remote_asik_script = remote_path + '/' + os.path.basename(local_asik_script)
    remote_loner_script = remote_path + '/' + os.path.basename(local_loner_script)
    cmd = 'ls -lrt {}'.format(remote_path)
    result = ssh_mgt.execute(cmd, connection=cnx)
    rob.log('List of available scripts: {}'.format(result), 'DEBUG')
    # If the two mirroring scripts are not available:
    if (os.path.basename(local_loner_script) not in result) or (os.path.basename(local_asik_script) not in result):
        # Create the directory for the scripts. If it already exists, the command is rejected
        cmd = 'mkdir {}'.format(remote_path)
        result = ssh_mgt.execute(cmd, connection=cnx)
        rob.log('Creation of the directory scripts: {}'.format(result), 'DEBUG')
        # Upload the scripts
        ssh_mgt.upload_file(local_asik_script, remote_asik_script, connection=cnx)
        ssh_mgt.upload_file(local_loner_script, remote_loner_script, connection=cnx)
        # Change the scripts access rights
        cmd = 'chmod 777 {}/*.sh'.format(remote_path)
        result = ssh_mgt.execute(cmd, connection=cnx)
        rob.log('Change the scripts access rights: {}'.format(result), 'DEBUG')
    # Execute the scripts
    cmd = '{}'.format(remote_asik_script)
    result = ssh_mgt.execute(cmd, connection=cnx)
    rob.log('Execute the script for mirroring: {}'.format(result), 'DEBUG')
    # Disconnect the connection to the ASIK
    ssh_mgt.disconnect(connection=cnx)


def start_tcpdump(name, host, user, password, options):
    # Open the connection to the machine hosting the tcpdump
    cnx = ssh_mgt.connect_to(host, user, password)
    rob.log('Session opened: {}'.format(cnx), 'DEBUG')
    # Send the command to start the tcpdump
    cmd = 'sudo tcpdump {} -w /tmp/tcpdump_{}.pcap &'.format(options, name)
    result = ssh_mgt.execute(cmd, connection=cnx)
    rob.log('Start the Tcpdump: {}\n    {}'.format(cmd, result), 'DEBUG')
    # Disconnect the connection
    ssh_mgt.disconnect(connection=cnx)


def stop_tcpdump(name, host, user, password):
    rob.log('parameters: name:{} host:{} user:{} password:{}'.format(name, host, user, password), 'DEBUG')
    # Open the connection to the machine hosting the tcpdump
    cnx = ssh_mgt.connect_to(host, user, password)
    rob.log('Session opened: {}'.format(cnx), 'DEBUG')
    # Look for the pid of the tcpdump process
    cmd = 'ps -ef | grep tcpdump'
    result = ssh_mgt.execute(cmd, connection=cnx)
    rob.log('Look for Tcpdump processes: {}'.format(result), 'DEBUG')
    # Retrieve the PID of the process
    regex = r'[\w]+[\s]+([\d]+)[\s]+[\d]+[\s]+[\d]+[\s]+[\d:]+[\s]+[\w\?/]+[\s]+[\d:]+[\s]+tcpdump' + \
            ' -w /tmp/tcpdump_' + name + '.pcap'
    rob.log('regex for the PID search: {}'.format(regex), 'INFO')
    re_pid = re.compile(regex)
    group_list = re_pid.search(result)
    # If a PID is found, the group list is not empty
    assert group_list, 'No TCPDUMP process has been found'
    pid = group_list.groups()[0]
    rob.log('PID of the tcpdump process: {}'.format(pid), 'INFO')
    # Send the command to stop the tcpdump process
    cmd = 'sudo kill {}'.format(pid)
    result = ssh_mgt.execute(cmd, connection=cnx)
    rob.log('Stop the tcpdump with sudo: {}'.format(result), 'DEBUG')
    if 'sudo: command not found' in result:
        cmd = 'kill {}'.format(pid)
        result = ssh_mgt.execute(cmd, connection=cnx)
        rob.log('Stop the tcpdump without sudo: {}'.format(result), 'DEBUG')
    # Disconnect the connection
    ssh_mgt.disconnect(connection=cnx)
    return


def collect_tcpdump(name, host, user, password, target_dir, target_file):
    # Open the connection to the machine hosting the PM reports
    cnx = ssh_mgt.connect_to(host, user, password)
    rob.log('Session opened: {}'.format(cnx), 'DEBUG')

    # Download the file
    file_name = 'tcpdump_{}.pcap'.format(name)
    full_local_name = target_dir + '/' + target_file
    full_remote_name = '/tmp/' + file_name
    rob.log('Try to download the file: {}'.format(full_local_name), 'DEBUG')
    ssh_mgt.download_file(full_remote_name, full_local_name, connection=cnx)
    rob.log('Tcpdump pcap file {} has been transferred to {}'.format(full_remote_name, full_local_name))
    # Disconnect the connection
    ssh_mgt.disconnect(connection=cnx)
    return full_local_name


def check_slot_distribution(file_path, file_name, frm_profile, nb_of_beams):
    """
    First convert the pcap file in pdml format by keeping only lines for DlData_SlotTypeReq
    Then check that SlotTypeReq on a slot is aligned with the profile defined in 3GPP.
    It should assert if the file_path is empty
    It should assert if the file_name does not exist
    It should assert if the frm profile is unknown
    It should assert if at least one error has been detected
    :param file_path: path of the pcap file to be inspected
    :param file_name: name of the pcap file to be inspected
    :param frm_profile: prachconfig index value (98, 152 or 161 is allowed)
    :param nb_of_beams: number of beams defined in the configuration ('8 beams' and '1 beam' is allowed)
    """
    # Assert if the file_path is empty
    assert file_path, 'The file path is empty'
    full_name = file_path + '/' + file_name
    # Assert if the file does not exist
    assert os.path.exists(full_name), 'the file {} does not exist'.format(full_name)
    # Assert if frm_profile has unknown value
    assert frm_profile in ('98', '152', '161'), \
        'Only prachConfigIndex 98, 152 and 161 are allowed: {} is unknown'.format(frm_profile)
    # Assert if nb_of_beams has unknown value
    assert nb_of_beams in ('1 beam', '2 beams', '8 beams'), \
        'Only beam configuration "1 beam", "2 beams" or "8 beams" are allowed: {} is unknown'.format(nb_of_beams)

    # Define the different available profiles (3GPP 38.211 figure 6.3.3.2-3)
    profile = {'98-8 beams': ((2, 2, 2, 2, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                              (27, 27, 41, 41, 32, 27, 33, 28, 32, 32, 27, 27, 41, 41, 32, 27, 33, 28, 32, 0),
                              (2, 2, 2, 2, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                              (27, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 0),
                              (2, 2, 2, 2, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                              (27, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 0),
                              (2, 2, 2, 2, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                              (27, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32)),
               '98-2 beams': ((2, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                              (27, 27, 41, 41, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 0),
                              (2, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                              (27, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 0),
                              (2, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                              (27, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 0),
                              (2, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                              (27, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 0)),
               '152-8 beams': ((2, 2, 2, 2, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                               (27, 27, 41, 41, 32, 27, 27, 28, 0, 0, 27, 27, 41, 41, 32, 27, 27, 28, 0, 0),
                               (2, 2, 2, 2, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                               (27, 27, 33, 28, 32, 27, 27, 28, 0, 0, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                               (2, 2, 2, 2, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                               (27, 27, 33, 28, 32, 27, 27, 28, 0, 0, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                               (2, 2, 2, 2, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                               (27, 27, 33, 28, 32, 27, 27, 28, 0, 0, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0)),
               '152-2 beams': ((2, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                               (27, 27, 41, 41, 32, 27, 27, 28, 0, 0, 27, 27, 41, 41, 32, 27, 27, 28, 0, 0),
                               (2, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                               (27, 27, 33, 28, 32, 27, 27, 28, 0, 0, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                               (2, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                               (27, 27, 33, 28, 32, 27, 27, 28, 0, 0, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                               (2, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 33, 28, 32, 32),
                               (27, 27, 33, 28, 32, 27, 27, 28, 0, 0, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0)),
               '161-8 beams': ((2, 2, 2, 2, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                               (27, 27, 41, 41, 32, 27, 33, 28, 32, 32, 27, 27, 41, 41, 32, 27, 27, 28, 0, 0),
                               (2, 2, 2, 2, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                               (27, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                               (2, 2, 2, 2, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                               (27, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                               (2, 2, 2, 2, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                               (27, 27, 33, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0)),
               '161-1 beam': ((2, 41, 27, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                              (2, 27, 27, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                              (2, 27, 27, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                              (2, 27, 27, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                              (2, 27, 27, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                              (2, 27, 27, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                              (2, 27, 27, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0),
                              (2, 27, 27, 28, 32, 27, 33, 28, 32, 32, 27, 27, 33, 28, 32, 27, 27, 28, 0, 0))
               }
    # By default no error are detected
    error = 0
    # Convert the pcap file into pdml file and keep only lines for DlData_SlotTypeReq
    pdml_name = file_path + '/' + 'l1l2_filtered.pdml'
    # lua = '/home/localuser/generated_luashark/luashark.lua'
    # lua = ${Lua_Path} + '/' + 'luashark.lua'
    lua = '/home/localuser/LUA/generated_luashark/luashark.lua'
    pcap_filter = 'DlData_SlotTypeReq.SlotTypeReq'
    os.system('tshark -r "{}" -X lua_script:{} -T pdml | grep "{}" > "{}"'.
              format(full_name, lua, pcap_filter, pdml_name))
    # Read the pdml file
    input_file = open(pdml_name)
    # Define the regex for the interesting lines
    re_slot_type_req = re.compile(r'DlData_SlotTypeReq.SlotTypeReq.([A-Za-z]+).+ show="([0-9A-Fa-fx]+)"')

    sfn = 0
    slot = 0
    key = frm_profile + '-' + nb_of_beams
    prof = profile[key]
    rob.log('Use profile {}'.format(key), 'INFO')
    nb_slot_type = 0
    nb_line = 0
    # For each packet
    for line in input_file:
        nb_line += 1
        # Extract the useful data in the line
        group_list = re_slot_type_req.search(line)
        # If something has been found
        if group_list:
            # Retrieve the name and the value of the parameter
            data_name = group_list.groups()[0]
            data_value = group_list.groups()[1]
            if data_value[0:2] == '0x':
                base = 16
            else:
                base = 10
            if data_name == 'sfn':
                sfn = int(data_value, base)
                sfn_mod8 = sfn % 8
            elif data_name == 'slot':
                slot = int(data_value, base)
            elif data_name == 'slotType':
                slot_type = int(data_value, base)
                nb_slot_type += 1
                if prof[sfn_mod8][slot] != slot_type:
                    if error < 50:
                        rob.log('sfn: {} - slot: {} - type: {} - expected type: {} => NOK'.
                                format(sfn, slot, slot_type, prof[sfn_mod8][slot]), 'ERROR')
                    error += 1

    # Assert if one error has been detected
    assert error == 0, '{} error has been detected in file {}'.format(error, file_name)
    # Assert if no slot type req has been found in the trace
    assert nb_slot_type > 0, 'No Data_SlotTypeReq has been found in file {}'.format(file_name)
    rob.log('No error detected. lines analysed {} - slot_type_req analysed: {}'.format(nb_line, nb_slot_type), 'INFO')
