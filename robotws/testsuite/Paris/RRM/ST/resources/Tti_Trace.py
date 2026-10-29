"""
        Keywords Purpose:
            Keywords to start, stop and collect TTI traces

        AUTHOR:
            Yves Gorjux       yves.gorjux@nokia.com
            Annie WONG        annie.wong@nokia.com

        13/Dec/2019: Automatic selection of the decoder script (19A or 19B)
        13/Dec/2019: Addition of the parameter trace_duration in the start_tti_traces
        12/Mar/2020: the regex to get the process id is updated as /bin/ is optional
        02/07/2020: remove bin0.gz (annie.wong@nokia.com)
        14/12/2020: container mode, get correct tti tool path on gNB (annie.wong@nokia.com)
        07/04/2021: add lxc containerization
"""

import re
import os.path
from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn

rob = BuiltIn()
ssh_mgt = ssh()


# TTI_TRACE_SCRIPT_DIR = '/opt/tools/ttiTrace'
TTI_TRACE_START_SCRIPT = 'eventsCollect.sh'
TTI_TRACE_DIR = '/var/eventsTrace'
TTI_TRACE_PREFIX = 'L2TtiTrace_EventsSnapshot.bin'
TTI_TRACE_RESULT_DIR = '/tmp/tti_traces'
TTI_TRACE_DL_SUFFIX = 'dl.csv'
TTI_TRACE_UL_SUFFIX = 'ul.csv'
TTI_TRACE_OUTPUTDL = 'combined_dl_trace.csv'
TTI_TRACE_OUTPUTUL = 'combined_ul_trace.csv'


def get_container_l2rt(cnx, type_info):
    # lrwxrwxrwx  1 root     btssw     16 Mar 29 17:09    node_0x1730 -> /ram/node_L2RT20
    cmd = "ls -lrt /tmp/. | grep /ram/node_L2RT"
    result = ssh_mgt.execute(cmd, connection=cnx)
    for line in result.split("\n"):
        ret = re.match(r"l.* node_(0x[0-9a-fA-F]+) .*/ram/node_(L2RT[\d]+)", line)
        if ret:
            if type_info == "nodeid":
                res = ret.group(1)
            if type_info == "nodename":
                res = ret.group(2)
            return res
    return False


def get_ttiTrace_tool_path(cnx):
    """
    :param cnx: connection to be used to send the commands
    """
    # get tti_trace_tool_path
    cmd = 'find / -name ttiTrace'
    result = ssh_mgt.execute(cmd, connection=cnx)
    list_path = result.split('\n')
    rob.log('List TTI trace tool dir: {}'.format(list_path), 'DEBUG')

    regex = r'(/tmp/node_L2RT[\d]+/opt/tools/ttiTrace|/opt/tools/ttiTrace)'
    regx = re.compile(regex)
    for path in list_path:
        ret = re.match(regx, path)
        if ret:
            res = path.strip()
            rob.log('Find TTI trace tool dir = {}'.format(res), 'DEBUG')
            return res
    return False


def start_tti_traces(cnx, trace_nbfiles=None, tti_trace_tool_path=False):
    """
    This keyword starts the collection of TTI traces
    :param cnx: connection to be used to send the commands to start TTI traces
    :param trace_nbfiles: if it is not None, the parameter DELETE_AFTER of the eventsCollect.sh script will be
           updated accordingly. It is the maximum number of TTI_Traces files to be used for the test.
           By default it is set to 120 files and the capture duration per file is 0.1s
    """
    if not tti_trace_tool_path:
        tti_trace_tool_path = get_ttiTrace_tool_path(cnx)
        if not tti_trace_tool_path:
            raise AssertionError("Error: tti trace tool not found in gNB")

    # Set the number of files to be kept if it is specified
    if trace_nbfiles:
        cmd = 'sed -i "s/DELETE_AFTER=[0-9][0-9]*/DELETE_AFTER={}/" {}/{}'\
            .format(trace_nbfiles, tti_trace_tool_path, TTI_TRACE_START_SCRIPT)
        rob.log('Configuring the TTI trace number of files: {}'.format(cmd), 'DEBUG')
        result = ssh_mgt.execute(command=cmd, connection=cnx).strip()
        rob.log('Configuring the TTI trace number of files: {}'.format(result), 'DEBUG')

    # Kill the potential on-going TTI traces to avoid interferences
    stop_tti_traces(cnx)
    # Clean the TTI traces files
    cmd = "rm {}/{}.*".format(TTI_TRACE_DIR, TTI_TRACE_PREFIX)
    result = ssh_mgt.execute(command=cmd, connection=cnx).strip()
    rob.log('Cleaning of TTI traces result: {}'.format(result), 'DEBUG')
    # Launch the command on the ABIL to start the TTI traces
    rob.log('Start TTI traces', 'INFO')
    cmd = "bash -mc \"cd {} ; ./{} < /dev/null > /dev/null 2>&1 & echo $!\"".\
        format(tti_trace_tool_path, TTI_TRACE_START_SCRIPT)
    rob.log('ABIL command to be launched: "{}"'.format(cmd), 'DEBUG')
    result = ssh_mgt.execute(command=cmd, connection=cnx).strip()
    rob.log('Starting TTI traces result: {}'.format(result), 'DEBUG')


def stop_tti_traces(cnx):
    """
    This keyword stop the TTI traces collection by kill#ing the corresponding process
    :param cnx: connection to be used to send the commands to stop TTI traces
    """
    rob.log('Stop TTI traces', 'INFO')
    # Look for the TTI trace processes
    cmd = 'ps -ef | grep {}'.format(TTI_TRACE_START_SCRIPT)
    result = ssh_mgt.execute(cmd, connection=cnx)
    list_process = result.split('\n')
    rob.log('List of all TTI trace processes:\n {}'.format(list_process), 'DEBUG')

    # For each TTI Trace, retrieve the PID of the process
    regex = r'[\w]+[\s]+([\d]+)[\s]+[\d]+[\s]+[\d]+[\s]+[\d:]+[\s]+[\w\?/]+[\s]+[\d:]+[\s]+(/bin/)?bash ./{}'.\
        format(TTI_TRACE_START_SCRIPT)
    for process in list_process:
        re_pid = re.compile(regex)
        group_list = re_pid.search(process)
        # If a PID is found, the group list is not empty
        if group_list:
            pid = group_list.groups()[0]
            # Send the command to stop the TTI Trace process
            cmd = 'kill {}'.format(pid)
            result = ssh_mgt.execute(cmd, connection=cnx).strip()
            rob.log('Killing the TTI trace process {} result:\n{}'.format(pid, result), 'DEBUG')


def collect_all_tti_traces(cnx, target_dir, tti_trace_tool_path=False):
    """
    This keyword decode all collected TTI trace and download the merge of decoded files
    It asserts if no TTI trace file are found or if only TTI trace file number 0 is found
    :param cnx: connection to be used to send commands and to download the decoded file
    :return: full_local_name: name of the downloaded decoded file with its full path name
    """
    rob.log('Collect TTI traces', 'INFO')

    if not tti_trace_tool_path:
        tti_trace_tool_path = get_ttiTrace_tool_path(cnx)
        if not tti_trace_tool_path:
            raise AssertionError("Error: tti trace tool not found in gNB")

    # Look for the TTI decoder
    cmd = 'ls -1 {}'.format(tti_trace_tool_path)
    result = ssh_mgt.execute(cmd, connection=cnx).strip()
    if 'eventDecoder' in result:
        tti_trace_decode_script = 'eventDecoder'
    elif 'eventSnapshotDecoder' in result:
        tti_trace_decode_script = 'eventSnapshotDecoder'
    else:
        assert False, 'No known TTI decoder has been found in {}: \n{}'.format(tti_trace_tool_path, result)
    rob.log('Looking for the TTI decoder result:\n{}'.format(result), 'DEBUG')

    # Clean the temporary directory
    cmd = 'mkdir -p {}/ ; rm {}/*'.format(TTI_TRACE_RESULT_DIR, TTI_TRACE_RESULT_DIR)
    result = ssh_mgt.execute(cmd, connection=cnx).strip()
    rob.log('Cleaning of temporary directory {} result:\n{}'.format(TTI_TRACE_RESULT_DIR, result), 'DEBUG')

    # modif 20B : remove L2TtiTrace_EventsSnapshot.bin.0.tar.gz
    cmd = 'rm {}/{}.0.tar.gz'.format(TTI_TRACE_DIR, TTI_TRACE_PREFIX)
    result = ssh_mgt.execute(command=cmd, connection=cnx).strip()
    rob.log('Cleaning of L2TtiTrace_EventsSnapshot.bin.0.tar.gz result: {}'.format(result), 'DEBUG')

    # Retrieve the list of TTI trace files
    cmd = 'ls -1 {}/{}*'.format(TTI_TRACE_DIR, TTI_TRACE_PREFIX)
    ls = ssh_mgt.execute(cmd, connection=cnx)
    rob.log('List of TTI trace files are:\n{}'.format(ls), 'DEBUG')
    # Convert the ls result into a list of files:
    list_tti_files = ls.split()

    # Set the minimum and maximum TTI trace file number
    min_file_num = 999999
    max_file_num = -1

    # For each file of the list:
    for tti_file in list_tti_files:
        # Unzip this file
        cmd = 'cd {} ; tar xzvf {}'.format(TTI_TRACE_DIR, tti_file)
        result = ssh_mgt.execute(cmd, connection=cnx).strip()
        rob.log('Uncompressing the trace file {} result:\n{}'.format(tti_file, result), 'DEBUG')
        # the unzip file name is the same as the zip file but the two last extension (.tar.gz) have to be removed
        tti_file_unzip = '.'.join(tti_file.split('.')[:-2])

        # Decode the unzip file
        tti_file_decode = TTI_TRACE_RESULT_DIR + '/' + os.path.basename(tti_file_unzip)
        cmd = '{}/{} {} {}'.\
            format(tti_trace_tool_path, tti_trace_decode_script, tti_file_unzip, tti_file_decode)
        result = ssh_mgt.execute(cmd, connection=cnx).strip()
        rob.log('Decoding the file {} result:\n{}'.format(tti_file_decode, result), 'DEBUG')

        # Extract the file number (it is the last extension of the unzip file name) and update the min and max value
        file_num = int(tti_file_unzip.split('.')[-1])
        if file_num > max_file_num:
            max_file_num = file_num
        if file_num < min_file_num:
            min_file_num = file_num

    # Assert if no TTI trace file has been found or if only TTI trace file number 0 is found
    assert max_file_num != -1, 'No TTI file has been found in {}'.format(TTI_TRACE_DIR)
    assert max_file_num != 0, 'Only TTI file 0 has been found in {}'.format(TTI_TRACE_DIR)
    # Continue if at least one TTI trace file has been found
    rob.log('Decoded files are in the range: [{}-{}]'.format(min_file_num, max_file_num), 'DEBUG')

    # I don't know why, but the TTI trace file number 0 is ignored:
    if min_file_num == 0:
        min_file_num += 1
    # Combine all decoded TTI Traces file into one file for UL and one for DL
    for i in range(min_file_num, max_file_num + 1):
        tti_file = TTI_TRACE_PREFIX + '.' + str(i)
        # For the first file, the header shall be taken into account but it shall be ignored for the others
        if i == min_file_num:
            cmd = 'cat'
        else:
            cmd = 'tail -n +2'
        full_cmd = 'cd {} ; {} {}.{} >> {} ; {} {}.{} >> {}'.\
            format(TTI_TRACE_RESULT_DIR,
                   cmd, tti_file, TTI_TRACE_DL_SUFFIX, TTI_TRACE_OUTPUTDL,
                   cmd, tti_file, TTI_TRACE_UL_SUFFIX, TTI_TRACE_OUTPUTUL
                   )
        result = ssh_mgt.execute(full_cmd, connection=cnx).strip()
        rob.log('Combining the files {} result:\n{}'.format(tti_file, result), 'DEBUG')

    # Download the results
    full_local_name = target_dir + '/' + TTI_TRACE_OUTPUTDL
    full_remote_name = TTI_TRACE_RESULT_DIR + '/' + TTI_TRACE_OUTPUTDL
    ssh_mgt.download_file(full_remote_name, full_local_name, connection=cnx)
    rob.log('TTI decoded trace file {} has been downloaded'.format(full_remote_name), 'INFO')
    full_local_name = target_dir + '/' + TTI_TRACE_OUTPUTUL
    full_remote_name = TTI_TRACE_RESULT_DIR + '/' + TTI_TRACE_OUTPUTUL
    ssh_mgt.download_file(full_remote_name, full_local_name, connection=cnx)
    rob.log('TTI decoded trace file {} has been downloaded'.format(full_remote_name), 'INFO')
