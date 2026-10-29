import time
from decimal import *
import re
import os
import subprocess
import csv
import math
from itertools import islice

# import linux_cmds as linux

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem

# TAF & UTE Libraries:
from robot.api import logger
from taf.converters.eventdecoder import EventDecoderConverter
from taf.converters.eventdecoder import EventDecoderConverterFactory

from taf.analyzer.ttitrace import TtitraceReader
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReaderEvtDec

""" num_of_events -> None is the default value, i.e. all events in the tti trace are decoded,
if a number 'x' is defined then only the first x elements of the tti trace will be decoded """

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

logLevel = "INFO"
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()


def get_root_path():
    """
    computing root path where to deploy Luashark
    Strategy is :
        if /home/<user> exists, it will be root path
        otherwise, retrieve TEMP_PATH robot variable as root path
    """
    # root = "/home/{}".format(linux.get_user())
    root = "/home/{}".format(os.getlogin())
    if os.path.isdir(root):
        return root
    output_dir = BuiltIn().get_variable_value("${TEMP_PATH}")
    assert output_dir is not None, \
        "${TEMP_PATH} robot variable was not set in robot context"
    return output_dir


def install_multidynamic_if_needed():
    # Author : Nikolay Shkulepov
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Private Keyword: Install Multidynamic if neeeded
    # It helps to check whether MULTI is installed and install it if not
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        import multi
    except ImportError:
        try:
            if os.getenv("VIRTUAL_ENV"):
                pip_path = os.path.join(os.getenv("VIRTUAL_ENV"), "bin", "pip")
            else:
                pip_path = "pip"
            cmdStr = "sudo mkdir /opt/tti_dissectors ; sudo chmod 777 /opt/tti_dissectors ; cd /opt/tti_dissectors"
            rbi.log("install_multidynamic_if_neeeded(): cmdStr = %s" %
                    cmdStr, "TRACE")
            swVersion = rbi.run_keyword("Get gNB Software Version")
            rbi.log("install_multidynamic_if_neeeded(): swVersion = %s" %
                    swVersion, "TRACE")
            os.chdir("/opt/tti_dissectors")
            if swVersion.startswith("SBTS"):
                cmdStr1 = "wget https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/"
                cmdStr2 = "%s_tti-dissectors.zip" % swVersion
                zipFileName = "%s_tti-dissectors.zip" % swVersion
            else:
                swVersion = rbi.run_keyword("Get gNB SW version").split("_")[1]
                cmdStr1 = "wget https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/"
                cmdStr2 = "System_Release/%s/tti-dissectors-%s.zip" % (
                    swVersion, swVersion)
                zipFileName = "tti-dissectors-%s.zip" % swVersion
            try:
                os.system(cmdStr)
                cmdStr = cmdStr1 + cmdStr2
                rbi.log("install_multidynamic_if_neeeded(): cmdStr = %s" %
                        cmdStr, "TRACE")
                subprocess.run(cmdStr, timeout=30)
            except Exception as e:
                rbi.log(e)
                rbi.log("tti dissectors are already installed")
            cmdStr1 = "unzip -n %s ; " % zipFileName
            cmdStr2 = "chmod 777 * ; " + pip_path + \
                " install --no-index -f . multidynamic.zip"
            cmdStr = cmdStr1 + cmdStr2
            rbi.log("install_multidynamic_if_neeeded(): cmdStr = %s" %
                    cmdStr, "TRACE")
            os.system(cmdStr)
        except Exception as e:
            rbi.log("install_multidynamic_if_neeeded(): Exception = <%s>" % str(e))


def logException(functionNameStr, e, silent=False):
    rbi.log("%s(): Exception = <%s>" % (functionNameStr, str(e)), "TRACE")
    if not silent:
        rbi.log_to_console("  %s: exception happened (see log.html)" % functionNameStr)


def decode_tti_traces_in_streaming_mode(desired_storage_directory="", num_of_events=None):
    # ------------------------------------------------------------------------------------------------[120 characters]
    rbi.log_to_console("TTI Trace decoding .", no_newline=True)
    root = get_root_path()
    tti_dissectors_root = "{}/tools/tti_dissectors".format(root)
    if not desired_storage_directory:
        desired_storage_directory = rbi.run_keyword("Get tc log directory")
    pcapPathName = desired_storage_directory + "/ttitrace_streaming.pcap"
    rbi.log("stop_tti_traces_in_streaming_mode(): pcapPathName = %s" % pcapPathName)
    udpPathName = pcapPathName.replace(".pcap", ".udp")
    if num_of_events is not None:
        num_of_events = int(num_of_events)
    if os.path.exists(pcapPathName) and os.path.getsize(pcapPathName) > 24:
        try:
            rbi.log_to_console(".1.", no_newline=True)
            cmdStr1 = "tshark -r %s --disable-protocol swe --disable-protocol syscom -T fields -e data" % pcapPathName
            cmdStr2 = " | perl -0ne's/\\n//g;print pack\"H*\",$_' > %s" % udpPathName
            cmdStr = cmdStr1 + cmdStr2
            rbi.log("stop_tti_traces_in_streaming_mode(): cmdStr = %s" % cmdStr)
            stdoutStr = os.system(cmdStr)
            rbi.log("stop_tti_traces_in_streaming_mode(): stdoutStr = %s" % stdoutStr)
            rbi.log_to_console(".2.", no_newline=True)
        except Exception as e:
            logException("decode_tti_traces_in_streaming_mode [1]", e)
            rbi.log_to_console(".ERROR")
            return
    rbi.log("stop_tti_traces_in_streaming_mode(): udpPathName = %s" % udpPathName)
    if os.path.exists(udpPathName) and os.path.getsize(udpPathName) > 24:
        try:
            # os.system("rm %s >/dev/null 2>&1" % pcapPathName)
            rbi.log_to_console(".3.", no_newline=True)
            file_name = udpPathName
            msgFile_all = open(desired_storage_directory + "/msg_all.csv", "w")
            with open(file_name, 'rb') as file_obj:
                startTime = int(time.time())
                msgFile_all.write("-;" * 10 + "\n")
                for event in islice(TtitraceReader(multi_base_folder=tti_dissectors_root, file_obj=file_obj),
                                    num_of_events):
                    if event.type != "ttiStartInd":
                        outStr = str(event.type) + ";" + repr(event.data) + "\n"
                        outStr = outStr.replace("{u'", "").replace(" u'", "")
                        outStr = outStr.replace("{", "").replace("}", "").replace(" ", "")
                        outStr = outStr.replace("[", "").replace("]", "").replace("'", "")
                        outStr = outStr.replace(":", ";").replace(",", ";")
                        msgFile_all.write(outStr)
            msgFile_all.close()
            rbi.log_to_console(".4.", no_newline=True)
            os.system("zip -mj %s/ttiTrace_stream_udp.zip %s >/dev/null 2>&1" % (desired_storage_directory,
                                                                                 udpPathName))
        except Exception as e:
            logException("decode_tti_traces_in_streaming_mode [2]", e)
            rbi.log_to_console(".ERROR")
            return
    rbi.log_to_console(".done")


def decode_tti_traces(desired_storage_directory="", num_of_events=None):
    # ------------------------------------------------------------------------------------------------[120 characters]
    rbi.log_to_console("TTI Trace decoding .", no_newline=True)
    if not desired_storage_directory:
        desired_storage_directory = rbi.run_keyword("Get tc log directory")
    pcapPathName = desired_storage_directory + "/ttitrace_streaming.pcap"
    rbi.log("decode_tti_traces(): pcapPathName = %s" % pcapPathName)
    udpPathName = pcapPathName.replace(".pcap", ".udp")
    if num_of_events is not None:
        num_of_events = int(num_of_events)
    if os.path.exists(pcapPathName) and os.path.getsize(pcapPathName) > 24:
        try:
            rbi.log_to_console(".1.", no_newline=True)
            cmdStr1 = "tshark -r %s --disable-protocol swe --disable-protocol syscom -T fields -e data" % pcapPathName
            cmdStr2 = " | perl -0ne's/\\n//g;print pack\"H*\",$_' > %s" % udpPathName
            cmdStr = cmdStr1 + cmdStr2
            rbi.log("decode_tti_traces(): cmdStr = %s" % cmdStr)
            stdoutStr = os.system(cmdStr)
            rbi.log("decode_tti_traces(): stdoutStr = %s" % stdoutStr)
            rbi.log_to_console(".2.", no_newline=True)
        except Exception as e:
            logException("decode_tti_traces [1]", e)
            rbi.log_to_console(".ERROR")
            return
    rbi.log("decode_tti_traces(): udpPathName = %s" % udpPathName)
    if os.path.exists(udpPathName) and os.path.getsize(udpPathName) > 24:
        try:
            # os.system("rm %s >/dev/null 2>&1" % pcapPathName)
            rbi.log_to_console(".3.", no_newline=True)
            file_name = udpPathName
            msgFile_all = open(desired_storage_directory + "/msg_all.csv", "w")
            with open(file_name, 'rb') as file_obj:
                startTime = int(time.time())
                msgFile_all.write("-;" * 10 + "\n")
                for event in islice(TtitraceReader(file_obj=file_obj), num_of_events):
                    if event.type != "ttiStartInd":
                        outStr = str(event.type) + ";" + repr(event.data) + "\n"
                        outStr = outStr.replace("{u'", "").replace(" u'", "")
                        outStr = outStr.replace("{", "").replace("}", "").replace(" ", "")
                        outStr = outStr.replace("[", "").replace("]", "").replace("'", "")
                        outStr = outStr.replace(":", ";").replace(",", ";")
                        msgFile_all.write(outStr)
            msgFile_all.close()
            rbi.log_to_console(".4.", no_newline=True)
            os.system("zip -mj %s/ttiTrace_stream_udp.zip %s >/dev/null 2>&1" % (desired_storage_directory,
                                                                                 udpPathName))
        except Exception as e:
            logException("decode_tti_traces [2]", e)
            rbi.log_to_console(".ERROR")
            return
    rbi.log_to_console(".done")


def decode_tti_traces_using_TtitraceReaderEvtDec(desired_storage_directory="",
                                                 desired_file_name="ttitrace_streaming.pcap",
                                                 num_of_events=None):
    # ------------------------------------------------------------------------------------------------[120 characters]
    rbi.log_to_console("TTI Trace decoding .", no_newline=True)
    if not desired_storage_directory:
        desired_storage_directory = rbi.run_keyword("Get tc log directory")
    pcapPathName = desired_storage_directory + "/" + desired_file_name
    rbi.log("decode_tti_traces(): pcapPathName = %s" % pcapPathName)
    udpPathName = pcapPathName.replace(".pcap", ".udp")
    basicName = pcapPathName.replace(".pcap", "")
    jsonPathName = pcapPathName.replace(".pcap", ".json")
    if num_of_events is not None:
        num_of_events = int(num_of_events)
    if os.path.exists(pcapPathName) and os.path.getsize(pcapPathName) > 24:
        try:
            rbi.log_to_console(".1.", no_newline=True)
            cmdStr1 = "tshark -r %s --disable-protocol swe --disable-protocol syscom -T fields -e data" % pcapPathName
            cmdStr2 = " | perl -0ne's/\\n//g;print pack\"H*\",$_' > %s" % udpPathName
            cmdStr = cmdStr1 + cmdStr2
            rbi.log("decode_tti_traces(): cmdStr = %s" % cmdStr)
            stdoutStr = os.system(cmdStr)
            rbi.log("decode_tti_traces(): stdoutStr = %s" % stdoutStr)
            rbi.log_to_console(".2.", no_newline=True)
        except Exception as e:
            logException("decode_tti_traces [1]", e)
            rbi.log_to_console(".ERROR")
            return
    rbi.log("decode_tti_traces(): udpPathName = %s (%s)" % (udpPathName, os.path.getsize(udpPathName)))
    if os.path.exists(pcapPathName) and os.path.getsize(pcapPathName) > 24:
        try:
            rbi.log_to_console(".3.", no_newline=True)
            tti_dec_path = "/opt/tti-dec/tti-dec-bin/"
            jsonDecoder = EventDecoderConverterFactory().create(configuration=dict(input_file_path=pcapPathName,
                                                                                   output_file_path=basicName,
                                                                                   output_file_format="json",
                                                                                   tti_dec_path=tti_dec_path),
                                                                existing_arguments={})
            jsonDecoder.convert()
            rbi.log_to_console(".4.", no_newline=True)
        except Exception as e:
            logException("decode_tti_traces [2]", e)
            rbi.log_to_console(".ERROR")
            return
    rbi.log("decode_tti_traces(): jsonPathName = %s (%s)" % (jsonPathName, os.path.getsize(jsonPathName)))
    if os.path.exists(jsonPathName) and os.path.getsize(jsonPathName) > 24:
        try:
            # os.system("rm %s >/dev/null 2>&1" % pcapPathName)
            rbi.log_to_console(".5.", no_newline=True)
            file_name = jsonPathName
            msgFile_all = open(desired_storage_directory + "/msg_all.csv", "w")
            with open(file_name, 'rb') as file_obj:
                startTime = int(time.time())
                msgFile_all.write("-;" * 10 + "\n")
                for event in islice(TtitraceReaderEvtDec(file_obj=file_obj), num_of_events):
                    if event.type != "ttiStartInd":
                        outStr = str(event.type) + ";" + repr(event.data) + "\n"
                        outStr = outStr.replace("{u'", "").replace(" u'", "")
                        outStr = outStr.replace("{", "").replace("}", "").replace(" ", "")
                        outStr = outStr.replace("[", "").replace("]", "").replace("'", "")
                        outStr = outStr.replace(":", ";").replace(",", ";")
                        msgFile_all.write(outStr)
            msgFile_all.close()
            rbi.log_to_console(".6.", no_newline=True)
            os.system("zip -mj %s/ttiTrace_stream_udp.zip %s >/dev/null 2>&1" % (desired_storage_directory,
                                                                                 udpPathName))
            os.system("zip -mj %s/ttiTrace_stream_json.zip %s >/dev/null 2>&1" % (desired_storage_directory,
                                                                                  jsonPathName))
        except Exception as e:
            logException("decode_tti_traces [3]", e)
            rbi.log_to_console(".ERROR")
            return
    rbi.log_to_console(".done")
    return msgFile_all


def decode_tti_traces_json_using_TtitraceReaderEvtDec(jsonPathName, num_of_events=None):
    rbi.log("decode_tti_traces(): jsonPathName = %s (%s)" % (jsonPathName, os.path.getsize(jsonPathName)))
    if os.path.exists(jsonPathName) and os.path.getsize(jsonPathName) > 24:
        try:
            if num_of_events is not None:
                num_of_events = int(num_of_events)
            rbi.log_to_console("Generate csv from json ...", no_newline=True)
            csvPathName = jsonPathName.replace(".json", ".csv")
            csvFile = open(csvPathName, "w")
            with open(jsonPathName, 'rb') as file_obj:
                csvFile.write("-;" * 10 + "\n")
                for event in islice(TtitraceReaderEvtDec(file_obj=file_obj), num_of_events):
                    if event.type != "ttiStartInd":
                        outStr = str(event.type) + ";" + repr(event.data) + "\n"
                        outStr = outStr.replace("{u'", "").replace(" u'", "")
                        outStr = outStr.replace("{", "").replace("}", "").replace(" ", "")
                        outStr = outStr.replace("[", "").replace("]", "").replace("'", "")
                        outStr = outStr.replace(":", ";").replace(",", ";")
                        csvFile.write(outStr)
            csvFile.close()
        except Exception as e:
            logException("decode_tti_traces_json", e)
            rbi.log_to_console(".ERROR")
            return
    return csvPathName


def add_File_ending_if_missing(file_path, file_ending):
    if file_ending not in file_path:
        file_path += file_ending
    return file_path


def get_source_IP_address(raw_ip):
    try:
        searchObject = re.search("inet [0-9,.]*", raw_ip)
        source_ip = searchObject.string[searchObject.span()[0]+5:searchObject.span()[1]]
    except AttributeError:
        logging.warning("Did not recieve usable input -AttributeError-, defaulting to ip 10.0.1.2")
        source_ip = "10.0.1.2"
    except TypeError:
        logging.warning("Wrong Input Type was given. setting IP to 10.0.1.2")
        source_ip = "10.0.1.2"
    return source_ip


def find_sfn_slot_pairs_ForAValue_KnowingRnti(file_path, search_value='UL_00_FORCE', physCellId=50, rnti=None):
    """
    Find first and last 'sfn' and 'slot' pairs in a CSV file.

    This function reads a CSV file and finds the first and last pairs of 'sfn'
    and 'slot' where 'physCellId' matches the provided 'physCellId', 'rnti'
    matches the provided 'rnti' and 'ulFdSchedData.dciFormat' matches the
    provided 'search_value'.

    Parameters:
    file_path (str): Path to the CSV file.
    search_value (str): Value to match in 'ulFdSchedData.dciFormat'.
    physCellId (str, optional): 'physCellId' to match. Defaults to None.
    rnti (str, optional): 'rnti' to match. Defaults to None.

    Returns:
    tuple: First and last pairs of 'sfn' and 'slot' that match the conditions.
    If no match is found, returns (None, None).
    """
    first_pair = None
    last_pair = None

    with open(file_path, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            if (row['physCellId'] == physCellId and row['rnti'] == rnti and
               row['ulFdSchedData.dciFormat'] == search_value):
                sfn_slot_pair = (row['sfn'], row['slot'])
                if first_pair is None:
                    first_pair = sfn_slot_pair
                last_pair = sfn_slot_pair

    return first_pair, last_pair


def find_sfn_slot_pairs_ForAValue_WOrnti(file_path, search_value='UL_00_FORCE', physCellId=50):
    """
    Find first and last 'sfn' and 'slot' pairs in a CSV file.

    This function reads a CSV file and finds the first and last pairs of 'sfn'
    and 'slot' where 'physCellId' matches the provided 'physCellId' and
    'ulFdSchedData.dciFormat' matches the provided 'search_value'.

    Parameters:
    file_path (str): Path to the CSV file.
    search_value (str): Value to match in 'ulFdSchedData.dciFormat'.
    physCellId (str, optional): 'physCellId' to match. Defaults to None.

    Returns:
    tuple: First and last pairs of 'sfn' and 'slot' that match the conditions.
    If no match is found, returns (None, None).
    """
    first_pair = None
    last_pair = None

    with open(file_path, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            if row['physCellId'] == physCellId and row['ulFdSchedData.dciFormat'] == search_value:
                sfn_slot_pair = (row['sfn'], row['slot'])
                if first_pair is None:
                    first_pair = sfn_slot_pair
                last_pair = sfn_slot_pair

    return first_pair, last_pair


def check_DL_10_or_DL_11_between_pairs(file_path, start_pair=None, end_pair=None, physCellId=50):
    """
    Check if DL_10 or DL_11 values between pairs in a CSV file for a dedicated cell.

    This function reads a CSV file and checks if any row between the start_pair
    and end_pair (inclusive) with a matching 'physCellId' has 'DL_11' or 'DL_10'
    in 'dlPdcchDciData.ueDciInfoList'. The pairs are tuples of ('sfn', 'slot').

    Parameters:
    file_path (str): Path to the CSV file.
    start_pair (tuple, optional): Start pair of ('sfn', 'slot'). Defaults to None.
    end_pair (tuple, optional): End pair of ('sfn', 'slot'). Defaults to None.
    physCellId (str, optional): 'physCellId' to match. Defaults to None.

    Returns:
    tuple: A tuple of (False, last pair checked) if a match is found, otherwise
    (True, last pair checked).
    """
    last_pair = None
    with open(file_path, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            current_pair = (int(row['sfn']) % 1024, int(row['slot']))
            if ((int(start_pair[0]) % 1024, int(start_pair[1])) <= current_pair
                    <= (int(end_pair[0]) % 1024, int(end_pair[1]))):
                last_pair = current_pair
                if row['physCellId'] == physCellId:
                    if (re.search(r'\bDL_11\b', row['dlPdcchDciData.ueDciInfoList']) or
                            re.search(r'\bDL_10\b', row['dlPdcchDciData.ueDciInfoList'])):
                        return False, last_pair

    return True, current_pair
