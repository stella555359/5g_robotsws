from __future__ import absolute_import
from builtins import object
import os
import sys
import re
from robot.api import logger
import logging
import psutil
import linux_cmds as linux
import taf.analyzer.pdml as pdml
import csv
from robot.libraries.BuiltIn import BuiltIn
from functools import wraps
from luashark_filter import Filter
from itertools import chain
from robot.libraries.BuiltIn import BuiltIn


def need_luashark_installed(method):
    """
    Decorator to force luashark installation if not still done
    before execution of any service
    """
    @wraps(method)
    def wrapper(self, *args, **kwargs):
        if not self.installed and self.isLuaSharkRequired:
            self.do_install_analyzer()
        return method(self, *args, **kwargs)
    return wrapper


class analyzer(object):
    """
    Class to manipulate tshark anlyzer
        To perform a deep decoding, proper Luashark script
        associated to Airframe version need to be installed
        This is retrieved onto WFT, knowing the dedicated version.
        At init(), this will be downloaded into
            /home/<userName>/tools/generated_luashark-<version>
        Location on WFT is deduced from robot framework AF_PATH variable,
        so af_path value should be provided at library import

        Main services are :
        - pcap_to_pdml :  to convert a pcap file into a pdml file
        - check_field  : check a pdml file to retrieve a field
                         in a packet and check its value
        - check_field_exists_once  :
                         checks a pdml file to verify a field
                         in a packet has at least once a given value
    """
    # Class constants
    # Root name for Luashark package on WFT
    LUASHARK_NAME = "luashark"
    # Prefix for directory name in which luashark.zip will deploy its content
    LUASHARK_PREFIX = "generated_luashark"
    # Name of script to provide to tshark for analysis of Nokia dedicated field
    LUASHARK_SCRIPT = "luashark.lua"
    # Temporary file for luashark.zip
    LUASHARK_ZIP = "TMP_LUASHARK.zip"
    # Extension for PCAP files
    PCAP_EXT = ".pcap"
    # Extension for PDML files
    PDML_EXT = ".pdml"
    # Start TAG for pdml part
    XML_START = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    # Full path to Luashark for UTE case
    LUASHARK_PATH_UTE = "/opt/luashark/generated_luashark"

    # Attributes for analyzer object :
    #    isUTE           : Flag to indicate if TL is an UTE one
    #    af_path         : URL to AirFrame as set in robot framework context
    #    version         : Version extracted from af_path
    #    installed       : Flag indicating if luashark is intalled
    #    luashark_url    : URL to get luashark on WFT
    #    luashark_root   : Root path for all luashark
    #    luashark_path   : Path for dedicated luashark (for this version)
    #    luashark_script : Path for luashark script

    def __init__(self, isLuaSharkRequired=False, af_path=None):
        """
        Set default value for attributes
        Set af_path attribute by retrieving corresponding robot variable
        """
        # Init by default of all attributes
        self.version = None
        self.luashark_root = None
        self.luashark_path = None
        self.luashark_script = None
        self.luashark_url = None
        self.installed = False
        self.isLuaSharkRequired = isLuaSharkRequired
        user = linux.get_user()
        self.tmp_file = "/tmp/analyzer_{}.tmp".format(user)
        self.isUTE = self.isUTE()
        if self.isLuaSharkRequired:
            if af_path is not None:
                self.af_path = af_path
            else:
                self.af_path = BuiltIn().get_variable_value("${AF_PATH}")
            if "--dryrun" not in sys.argv and not self.isUTE:
                assert self.af_path is not None, "luashark_tools Library was invoked without AF_PATH"
        self.filter_file = "/tmp/{}.luashark_filter.log".format(user)
        self.listOfAllMsgAndId = []
        linux.rm_if_exist(self.filter_file)

    def __str__(self):
        return "isUTE={} AF_PATH={} version={} installed={} URL={} SCRIPT={}".\
            format(self.isUTE, self.af_path, self.version, self.installed, self.luashark_url, self.luashark_script)

    def isUTE(self):
        build = BuiltIn().get_variable_value("${ENB_BUILD}")
        return build is not None and len(build) > 0

    def setLuasharkScriptName(self, name):
        linux.info("Setting Luashark script name to :{}".format(name))
        analyzer.LUASHARK_SCRIPT = name

    def is_luashark_installed(self):
        """
        Check if luashark is installed for this version
        Also check if luashark.lua script is present inside
        """
        # First check if path to luashark exists
        prefix = analyzer.LUASHARK_NAME
        if not self.isUTE:
            prefix += " for {}".format(self.version)
        if not os.path.isdir(self.luashark_path):
            linux.info("{} not installed".format(prefix))
            return False
        # Also verify if luashark/lua script exists inside it
        assert os.path.exists(self.luashark_script), \
            "Path for luashark {} exists, but not {} script."\
            .format(self.luashark_path, analyzer.LUASHARK_SCRIPT)
        # Luashark now properly installed
        linux.info("{} already installed in {}"
                   .format(prefix, self.luashark_script))
        self.installed = True
        return True

    def install_luashark(self):
        """
        Install luashark in :
        /home/<user>/tools/luashark/generated_luashark-<version>
        """
        try:
            # Create root path to Luashark in case it does not exist
            linux.execute("mkdir -p {}".format(self.luashark_root))
            # Remove temporary zip file if exists
            targetZipFile = "{}/{}"\
                .format(self.luashark_root, analyzer.LUASHARK_ZIP)
            linux.rm_if_exist(targetZipFile)
            # Launch wget command to dowwnload luashark-<version>.zip
            # into targetZipFile
            linux.execute("wget {} -O {} -o {}".format(
                self.luashark_url, targetZipFile, self.tmp_file))
            # Check no error occured during download
            with open(self.tmp_file) as resFile:
                for line in resFile:
                    assert "ERROR" not in line, \
                        "Error while downloading {}:\n{}"\
                        .format(self.luashark_url, line)
            # Unzip downloaded zip file and rename it with version as suffix
            linux.unzip_file(targetZipFile, self.luashark_root)
            os.rename("{}/{}".
                      format(self.luashark_root, analyzer.LUASHARK_PREFIX),
                      self.luashark_path)
            assert os.path.exists(self.luashark_script),\
                "Unable to find {} in {}"\
                .format(analyzer.LUASHARK_SCRIPT, self.luashark_path)
            self.installed = True
        finally:
            os.remove(targetZipFile)

    def appendMsgIdRaw(self):
        """
        check a csv file,then retrieve list of column
        with a row of <message name>,<decimal message id>,
        and <hexa message id>
        :return: list of all messages and ids
        """
        msgIds_file = self.luashark_path + '/msg_ids_raw.csv'
        linux.fatal_if(not os.path.exists(msgIds_file),
                       "msg_ids_raw.csv file {} not found".format(msgIds_file))
        with open(msgIds_file, 'r') as file:
            csv_reader = csv.DictReader(file, delimiter=';', fieldnames=["msgName", "msgIdDec", "msgIdHex"])
            for column in csv_reader:
                my_unwanted_feature = 'ft1120'
                if my_unwanted_feature not in column['msgName']:
                    messageName = linux.get_name_from_extension(column['msgName'])
                    messagePrefix = column['msgName'].rsplit('/')[-2]
                    splittingMessageName = column['msgName'].split('/', 2)[-1].replace('/', '_').split('.lua')[0]
                    self.listOfAllMsgAndId.append([column['msgName'], messagePrefix.lower(), messageName.lower(),
                                                   column['msgIdHex'], splittingMessageName.lower()])

    def setLuasharkPathsNoneUTE(self):
        # From AF_PATH, we extract last two directories
        twords = self.af_path.split('/')
        self.luashark_url = self.af_path
        if "SBTS" in self.af_path:
            # https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_210605_000013_luashark.zip
            self.version = twords[-1].replace("_luashark.zip", "")
        else:
            # https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/
            # System_Release/0.800.4501/luashark-0.800.4501.zip
            #  Version is second previous field
            self.version = twords[-2]
            # Replace last field with "luashark-<version>.zip"
            self.luashark_url = self.af_path.replace(
                twords[-1],
                "{}-{}.zip".format(analyzer.LUASHARK_NAME, self.version))
        linux.info("luashark_url={}".format(self.luashark_url))
        # Then, building path to Luashark, path to Luashark.lua script
        root = get_root_path()
        self.luashark_root = "{}/tools/{}"\
            .format(root, analyzer.LUASHARK_NAME)
        self.luashark_path = "{}/{}-{}"\
            .format(self.luashark_root, analyzer.LUASHARK_PREFIX, self.version)

    def setLuasharkPathsUTE(self):
        self.luashark_root = self.luashark_path = analyzer.LUASHARK_PATH_UTE

    def do_install_analyzer(self):
        """
        Compute all analyzer attributes (paths, version,...)
        and install dedicated luashark  if required
        """
        # Compute all attributes (upon ute or not)
        if self.af_path is not None:
            self.setLuasharkPathsNoneUTE()
        else:
            self.setLuasharkPathsUTE()

        # Compute final attributes (whatever cases)
        self.luashark_script = "{}/{}"\
            .format(self.luashark_path, analyzer.LUASHARK_SCRIPT)
        linux.info("version={} luashark_path={}"
                   .format(self.version, self.luashark_path))
        # console("DEBUG:ANALYZER={} version={}".format(self,self.version))

        # Install Luashark if required
        if not self.is_luashark_installed():
            assert self.af_path is not None, "FATAL ERROR:No luashark found at {}".format(self.luashark_path)
            self.install_luashark()
        self.appendMsgIdRaw()

    @need_luashark_installed
    def pcap_to_pdml(self, pcapFile, filterexp=None):
        """
        Translate a .pcap file into a pdml file (xml format)
        pcap file is a binary file obtained thanks to a tcpdump capture
        it provides a dump of all packets captured on an ethernet interface
        during a time
        But this format can not be read directly, it required to
        translate it into a text format
        pdml is a pertinent xml format for this
        """
        # Compute name of pdml file.
        # will be located at the same location, but with .pdml extenstion
        extension = linux.get_extension(pcapFile)
        assert extension == analyzer.PCAP_EXT, \
            "pcap_to_pdml:{} is not a pcap file".format(pcapFile)
        if filterexp is None:
            pdmlFile = pcapFile.replace(analyzer.PCAP_EXT, analyzer.PDML_EXT)
            cmd = "tshark -r '{}' {} -T pdml > {} 2>&1" \
                .format(pcapFile, self.get_lua_option(), self.tmp_file)
        else:
            pdmlFile = pcapFile.replace(analyzer.PCAP_EXT, '_' + filterexp + analyzer.PDML_EXT)
            cmd = "tshark -r '{}' {} -Y '{}' -T pdml > {} 2>&1" \
                .format(pcapFile, self.get_lua_option(), filterexp, self.tmp_file)
        linux.info("Translating PCAP file {} into PDML file {}"
                   .format(pcapFile, pdmlFile))
        # Compute and launch tshark command
        assert os.path.exists(pcapFile), "Pcap file {} not found !"\
            .format(pcapFile)
        linux.execute(cmd)
        # Split result : first part (until xml...) in header (for print),
        # last part in pdml file as xml part
        found_xml_tag = False
        header = ""
        with open(self.tmp_file, 'r') as tmp, open(pdmlFile, 'w') as file:
            for line in tmp:
                if found_xml_tag or analyzer.XML_START in line:
                    found_xml_tag = True
                    file.write(line)
                else:
                    header = header + line
        linux.verbose("Header of tshark command is :{}".format(header))
        return pdmlFile

    def get_lua_option(self):
        if self.isLuaSharkRequired:
            return "-X lua_script:{}".format(self.luashark_script)
        return ""

    @need_luashark_installed
    def filter_pcap(self, pcapInFile, filterName=None, filterExp=None):
        """
        This method apply a filter on a pcap file and generate a new pcap
        containing only selected packets
        :param pcapInFile: input pcap file
        :param filterName: name of filter to add in root name of pcap
        :param filterExp: litteral expression of filter to apply
        :return: path of generated pcap file
        """
        pcapOutFile = os.path.abspath(
            pcapInFile.replace(analyzer.PCAP_EXT,
                               ".{}{}".format(filterName, analyzer.PCAP_EXT)))
        linux.rm_if_exist(pcapOutFile)
        linux.info("Applying filter [{}] on {}->{}"
                   .format(filterExp, pcapInFile, pcapOutFile))
        cmd = "tshark -r '{}' {} -Y '{}' -w '{}' > {} 2>&1"\
            .format(pcapInFile,
                    self.get_lua_option(),
                    filterExp,
                    pcapOutFile,
                    self.tmp_file)
        linux.execute(cmd)
        # if output file does not exists, it means an error occured on filter
        linux.fatal_if(not os.path.isfile(pcapOutFile),
                       "File {} absent:Bad filtering [{}]".format(pcapOutFile, filterExp))
        return pcapOutFile

    @need_luashark_installed
    def get_id_by_messages(self, msg_names=list):
        msg_id_list = []
        for msg_name in msg_names:
            if msg_name.lower() in chain(*self.listOfAllMsgAndId):
                for key in self.listOfAllMsgAndId:
                    if msg_name.lower() == key[4].lower():
                        msg_id_list.append(key[3])
            else:
                print("this message {} doesn't exist".format(msg_name))
        if msg_id_list == []:
            print("Nothing")
        return msg_id_list

    @need_luashark_installed
    def get_message_Id(self, msg_names=list):
        """
        parse a csv file,and from list of  messages taken in input,
        get ids message.
        :param: list of message names taken in input eg: DlData_SlotTypeReq Input Message is Case sensitive!
        :return:ids message in decimal
        """
        returnError = "Message : {} does not exists. Check correct name in generated_luashark/msg_ids_raw.csv"
        output_msg_id_list = []
        for input_msg_name in msg_names:
            if re.compile(r'[_]').search(input_msg_name):
                messagePrefix = input_msg_name.rsplit('_')[0]
                messageName = input_msg_name.rsplit('_')[1]
                if messageName.lower() in chain(*self.listOfAllMsgAndId) \
                        and messagePrefix.lower() in chain(*self.listOfAllMsgAndId):
                    for msgAttribute in self.listOfAllMsgAndId:
                        if messageName.lower() == msgAttribute[2].lower() \
                                and messagePrefix.lower() == msgAttribute[1].lower():
                            output_msg_id_list.append(msgAttribute[3])
                elif messageName.lower() in chain(*self.listOfAllMsgAndId):
                    for key in self.listOfAllMsgAndId:
                        if messageName.lower() == key[2].lower():
                            print("INFO: Message {}. You may want type like this {}_{}".
                                  format(input_msg_name, key[1], key[2]))
                            self.write_to_console("\n *WARN* Message {}. You may want type like this {}_{}".
                                                  format(input_msg_name, key[1], key[2]))
                else:
                    print(returnError.format(input_msg_name))
            else:
                if input_msg_name.lower() in chain(*self.listOfAllMsgAndId):
                    for key in self.listOfAllMsgAndId:
                        if input_msg_name.lower() == key[2].lower():
                            output_msg_id_list.append(key[3])
                else:
                    print(returnError.format(input_msg_name))
        if input_msg_name == []:
            print('None of the messages introduced were found')
        return output_msg_id_list

    def write_to_console(self, text):
        BuiltIn().log_to_console(text)

    @need_luashark_installed
    def get_match_from_path(self, pdmlFile, packetName=None,
                            filter="",
                            path=None, noPathIsError=True,
                            startPacket=1, endPacket=-1,
                            debugFilter=False, count_pkt=-1, verbose=True):
        """
        Parse a pdml file, select packets matching <packetName>,
        then retrieve list of paths matching <path> expression
        :param pdmlFile: full path of pdml file to parse
        :param packetName: name of packet(s) to retrieve
        :param path: path expression to search in pertinent packets
        :param noPathIsError: indicate if an error should be raised
             in case no path were found
        :return: list of paths matching searched expression
        """
        linux.reset_error()
        packetParser = PacketParser(pdmlFile, packetName, startPacket, endPacket)
        if packetParser.isEmpty():
            return []
        # Apply filter if required

        packetParser.listSubPacket = self.apply_filter(packetParser.listSubPacket, filter, debugFilter, verbose)

        if count_pkt == -1:
            listSubPacket = packetParser.getMatchFromPath(pathExp=path)
        else:
            listSubPacket = packetParser.listSubPacket
        linux.error_if(len(listSubPacket) == 0 and noPathIsError,
                       "No field found matching path : {}".format(path))

        return listSubPacket

    @need_luashark_installed
    def get_match_from_paths(self, pdmlFile, packetName=None,
                             filter="",
                             pathList=[], startPacket=1, endPacket=-1,
                             debugFilter=False, verbose=True):
        """
        Parse a pdml file, select packets matching <packetName>,
        then retrieve list of paths matching a list of <path> expression
        :param pdmlFile: full path of pdml file to parse
        :param packetName: name of packet(s) to retrieve
        :param pathList: list of path expression to search in pertinent packets
        :return: list of FilteredPacket
        """
        linux.reset_error()
        packetParser = PacketParser(pdmlFile, packetName=packetName,
                                    startPacket=startPacket, endPacket=endPacket)
        if packetParser.isEmpty():
            return []
        # Apply filter if required
        packetParser.listSubPacket = self.apply_filter(packetParser.listSubPacket, filter, debugFilter)
        # Retrieve required list of fields
        return packetParser.getMatchFromPaths(pathExpList=pathList, verbose=verbose)

    def check_field(self, pdmlFile, packetName=None,
                    fieldName=None, value=None, test="==", kind="show"):
        """
        Check a pdml file, retrieving a particular packet,
        and verifying a field exists and is set to expected value
        :param pdmlFile: path of pdml file to parse
        :param packetName: name of packet to retrieve
        :param fieldName: name of field to retrieve
        :param value: expected value
        :param test: kind of comparison to do
         one of : ==, !=, <=, >=, <, >, MATCH (for string)
        :param kind: kind of field to compare
        should be one of : "show", "showname" or "value"
        ERROR : if pdml file does not exist
        ERROR : if no packet matching <packetName> is found
        ERROR : if no field matching <fieldName> was found in packet
        ERROR : if obtained value different from expected one
        """
        self.check_list(pdmlFile, packetName=packetName, path=".*/{}$".format(fieldName),
                        kind=kind, test=test, value=value)

    def check_field_exists_once(self, pdmlFile, packetName=None, filter="",
                                fieldName=None, value=None,
                                test="==", kind="show"):
        """
        Check a pdml file, retrieving a particular packet,
        and verifying a field exists and
        is set to expected value at list in one of them
        :param pdmlFile: path of pdml file to parse
        :param packetName: name of packet to retrieve
        :param fieldName: name of field to retrieve
        :param value: expected value
        :param test: kind of comparison to do
         one of : ==, !=, <=, >=, <, >, MATCH (for string)
        :param kind: kind of field to compare
        should be one of : "show", "showname" or "value"

        ERROR : if pdml file does not exist
        ERROR : if no packet matching <packetName> is found
        ERROR : if no field matching <fieldName> was found in packet
        ERROR : if no field matching <fieldName> with given exists
        """
        self.check_exists_once(pdmlFile=pdmlFile, packetName=packetName, filter=filter,
                               path=".*/{}$".format(fieldName), kind=kind, test=test, value=value)

    def check_path(self, pdmlFile, packetName=None,
                   path=None, kind="show", test="==", value=None):
        """
        Should be DEPRECATED : use check_list instead
        """
        self.check_list(pdmlFile=pdmlFile, packetName=packetName,
                        path=path, kind=kind, test=test, value=value)

    def check_list(self, pdmlFile, packetName=None, filter="",
                   path=None, kind="show", test="==", value=None,
                   startPacket=1, endPacket=-1):
        """
        Check a pdml file, retrieving a particular packet,
        and verifying a path exists and is set to expected value
        path can be a regular expresion (using ^, *, $, ...)
        :param pdmlFile: path of pdml file to parse
        :param packetName: name of packet to retrieve
        :param path: regular expression of paths to retrieve
        :param value: expected value
        :param test: kind of comparison to do
         one of : ==, !=, <=, >=, <, >, MATCH (for string)
        :param kind: kind of field to compare
        should be one of : "show", "showname" or "value"
        :param startPacket: index of starting packet to be considered
        :param endPacket: index of ending packet to be considered

        packets are numbered as in wireshark, starting at 1
        endPacket set to -1 means until last packet
        """
        linux.info("CHECK_LIST:PACKET:{}[{}..{}] Path:{} TEST:'{}' '{}' '{}'".
                   format(packetName, startPacket, endPacket,
                          path, kind, test, value))
        listSubPacket = self.get_match_from_path(pdmlFile=pdmlFile,
                                                 packetName=packetName, filter=filter, path=path,
                                                 startPacket=startPacket, endPacket=endPacket)
        for idx, subPacket in enumerate(listSubPacket):
            for idy, path in enumerate(subPacket.fields.keys()):
                comparison = Comparison(path, subPacket.fields[path], kind, test, value)
                res = comparison.do()
                prefixStr = subPacket.prefixStr(idx, idy)
                subPacket.printWithPrefix(prefixStr, path)
                linux.error_if_else_info(not res, "{}DIAG  :{}".format(prefixStr, comparison.get_diag_res()))
        linux.final_diag()

    def check_exists_once(self, pdmlFile, packetName=None, filter="",
                          path=None, kind="show", test="==",
                          value=None, startPacket=1, endPacket=-1):
        """
        Check a pdml file, retrieving a particular packet,
        and verifying a field exists at least once with a given value
        :param pdmlFile: path of pdml file to parse
        :param packetName: name of packet to retrieve
        :param path: regular expression of paths to retrieve
        :param value: expected value
        :param test: kind of comparison to do
         one of : ==, !=, <=, >=, <, >, MATCH (for string)
        :param kind: kind of field to compare
        should be one of : "show", "showname" or "value"
        :param startPacket: index of starting packet to be considered
        :param endPacket: index of ending packet to be considered
        ERROR : if pdml file does not exist
        ERROR : if no packet matching <packetName> is found
        ERROR : if one field matching <fieldName> with given <value>
                was NOT found in ANY packet
        """
        linux.info(
            "CHECK_EXISTS_ONCE:PACKET:{}[{}..{}] Path:{} TEST:'{}' '{}' '{}'"
            .format(packetName, startPacket, endPacket,
                    path, kind, test, value))
        listSubPacket = self.get_match_from_path(pdmlFile=pdmlFile,
                                                 packetName=packetName, filter=filter,
                                                 path=path, startPacket=startPacket, endPacket=endPacket)
        existsOnce = False
        for idx, subPacket in enumerate(listSubPacket):
            for idy, path in enumerate(subPacket.fields.keys()):
                comparison = Comparison(path, subPacket.fields[path], kind, test, value)
                existsOnce = existsOnce or comparison.do()
                prefixStr = subPacket.prefixStr(idx, idx)
                subPacket.printWithPrefix(prefixStr, path)
                linux.error_if_else_info(not existsOnce, "{}DIAG  :{}".format(prefixStr, comparison.get_diag_res()))
            if existsOnce:
                linux.reset_error()
                break
        linux.final_diag()

    def get_unique(self, pdmlFile, packetName=None, filter="", path=None,
                   kind="show", startPacket=1, endPacket=-1):
        """
        Return value of a unique path in some particular packet
        :param pdmlFile: path of pdml file to parse
        :param packetName: name of packet to retrieve
        :param path: regular expression of paths to retrieve
        :param kind: kind of field to get
               should be one of : "show", "showname" or "value"
        :param startPacket: index of starting packet to be considered
        :param endPacket: index of ending packet to be considered
        ERROR : if pdml file does not exist
        ERROR : if no packet matching <packetName> is found
        ERROR : if number of occurences of matching paths is not equal to 1
        """
        linux.info("GET_UNIQUE:PACKET:{} Path:{} KIND:{}"
                   .format(packetName, path, kind))
        listSubPacket = self.get_match_from_path(pdmlFile=pdmlFile,
                                                 packetName=packetName, filter=filter,
                                                 path=path, startPacket=startPacket, endPacket=endPacket)
        value = ""
        MatchingPacketInBounds = 0
        for idx, subPacket in enumerate(listSubPacket):
            MatchingPacketInBounds = MatchingPacketInBounds + 1
            MatchingField = 0
            for idy, path in enumerate(subPacket.fields.keys()):
                MatchingField = MatchingField + 1
                prefixStr = subPacket.prefixStr(idx, idy)
                subPacket.printWithPrefix(prefixStr, path)
                value = get_value_from_kind(subPacket.fields[path], kind)
                linux.info("{}{}[{}] = '{}'".format(prefixStr, last_elt_from_path(path), kind, value))
            linux.error_if(MatchingField > 1,
                           "Found {} Path (expected 1) in packet {}"
                           .format(len(subPacket.fields.keys()), subPacket.namedPacket))
        linux.error_if(len(value) == 0, "Found no Path (expected 1)")
        linux.error_if(MatchingPacketInBounds != 1,
                       "Found {} packet (expected 1)"
                       .format(len(listSubPacket)))
        linux.final_diag()
        return value

    def get_unique_showname(self, pdmlFile, packetName=None, filter="", path=None,
                            kind="showname", startPacket=1, endPacket=-1):
        """
        Return value of a unique path in some particular packet
        :param pdmlFile: path of pdml file to parse
        :param packetName: name of packet to retrieve
        :param path: regular expression of paths to retrieve
        :param kind: kind of field to get
               should be one of : "show", "showname" or "value"
        :param startPacket: index of starting packet to be considered
        :param endPacket: index of ending packet to be considered
        ERROR : if pdml file does not exist
        ERROR : if no packet matching <packetName> is found
        ERROR : if number of occurences of matching paths is not equal to 1
        """
        linux.info("GET_UNIQUE:PACKET:{} Path:{} KIND:{}"
                   .format(packetName, path, kind))
        listSubPacket = self.get_match_from_path(pdmlFile=pdmlFile,
                                                 packetName=packetName, filter=filter,
                                                 path=path, startPacket=startPacket, endPacket=endPacket)
        value = ""
        MatchingPacketInBounds = 0
        for idx, subPacket in enumerate(listSubPacket):
            MatchingPacketInBounds = MatchingPacketInBounds + 1
            MatchingField = 0
            for idy, path in enumerate(subPacket.fields.keys()):
                MatchingField = MatchingField + 1
                prefixStr = subPacket.prefixStr(idx, idy)
                subPacket.printWithPrefix(prefixStr, path)
                value = get_value_from_kind(subPacket.fields[path], kind)
                linux.info("{}{}[{}] = '{}'".format(prefixStr, last_elt_from_path(path), kind, value))
            linux.error_if(MatchingField > 1,
                           "Found {} Path (expected 1) in packet {}"
                           .format(len(subPacket.fields.keys()), subPacket.namedPacket))
        linux.error_if(len(value) == 0, "Found no Path (expected 1)")
        linux.error_if(MatchingPacketInBounds != 1,
                       "Found {} packet (expected 1)"
                       .format(len(listSubPacket)))
        linux.final_diag()
        return value

    def get_shownames(self, pdmlFile, packetName=None, filter="", path=None, kind="showname", startPacket=1,
                      endPacket=-1, verbose=False):
        """
        Return value of a unique path in some particular packet
        :param pdmlFile: path of pdml file to parse
        :param packetName: name of packet to retrieve
        :param path: regular expression of paths to retrieve
        :param kind: kind of field to get
               should be one of : "show", "showname" or "value"
        :param startPacket: index of starting packet to be considered
        :param endPacket: index of ending packet to be considered
        ERROR : if pdml file does not exist
        ERROR : if no packet matching <packetName> is found
        ERROR : if number of occurences of matching paths is not equal to 1
        """
        linux.info("GET_UNIQUE:PACKET:{} Path:{} KIND:{}"
                   .format(packetName, path, kind))
        listSubPacket = self.get_match_from_path(pdmlFile=pdmlFile,
                                                 packetName=packetName, filter=filter,
                                                 path=path, startPacket=startPacket, endPacket=endPacket, verbose=False)

        value = []
        MatchingPacketInBounds = 0

        for idx, subPacket in enumerate(listSubPacket):
            MatchingPacketInBounds = MatchingPacketInBounds + 1
            MatchingField = 0
            for idy, path in enumerate(subPacket.fields.keys()):
                MatchingField = MatchingField + 1
                prefixStr = subPacket.prefixStr(idx, idy)
                if verbose:
                    subPacket.printWithPrefix(prefixStr, path)
                tmp = get_value_from_kind(subPacket.fields[path], kind)
                value.append(tmp)
                if verbose:
                    linux.info("{}{}[{}] = '{}'".format(prefixStr, last_elt_from_path(path), kind, value))
            linux.error_if(MatchingField == 0,
                           "Found {} Path (expected 1) in packet {}"
                           .format(len(subPacket.fields.keys()), subPacket.namedPacket))
        linux.error_if(len(value) == 0, "Found no Path (expected 1)")
        linux.error_if(MatchingPacketInBounds == 0,
                       "Found {} packet (expected at least 1)"
                       .format(len(listSubPacket)))

        linux.final_diag()
        return value

    def count_path(self, pdmlFile, packetName=None, filter="",
                   path=None, startPacket=1, endPacket=-1, pkt_count=-1):
        """
        Count number of paths matching a particular pattern
        (for a particular packet name)
        :param pdmlFile: path of pdml file to parse
        :param packetName: name of packet to retrieve
        :param path: regular expression of paths to retrieve
        should be one of : "show", "showname" or "value"
        ERROR : if pdml file does not exist
        ERROR : if no packet matching <packetName> is found
        ERROR : if number of occurences of matching paths is not equal to 1
        """
        linux.info("COUNT_PATHS:PACKET:{} Path:{}".format(packetName, path))
        listSubPacket = self.get_match_from_path(pdmlFile=pdmlFile,
                                                 packetName=packetName, filter=filter,
                                                 path=path, noPathIsError=False,
                                                 startPacket=startPacket, endPacket=endPacket, count_pkt=pkt_count,
                                                 verbose=False)
        count = 0
        if pkt_count == -1:
            for subPacket in listSubPacket:
                count = count + len(subPacket.fields.keys())
        linux.final_diag()
        if pkt_count == -1:
            return count
        else:
            total_filtered_pkt_count = len(listSubPacket)
            return total_filtered_pkt_count

    def apply_filter(self, listSubPacket, filter="", debugFilter=False, verbose=True):

        linux.info("Applying filter:{}".format(filter))
        self.filter = Filter(filter)
        if self.filter.isOK():
            if debugFilter:
                handle = self.filter.initDebugFile(self.filter_file)
                self.filter.traceDebug("HEAD:FILTER={} INPUT={}".format(filter, len(listSubPacket)))
            newListSubPacket = self.filter.apply(listSubPacket)
            if debugFilter:
                handle.write("TAIL:FILTER={} OUTPUT={} ".
                             format(filter, len(newListSubPacket)))
                handle.close()
            if verbose:
                linux.info("  Found {} packets matching filter \"{}\":{}"
                           .format(len(newListSubPacket), self.filter.name,
                                   PacketParser.toPacketList(newListSubPacket)))

        return newListSubPacket

    def newListParser(self, listPacket):
        return ListParser(listPacket)

    def getNextFromlistParser(self, parser, filter, maxDeep=10, debugFilter=False):
        return parser.getNext(filter, maxDeep, debugFilter)


# =====================================================================================
# Set of tests methods for Comparison class
# =====================================================================================


def TestEqual(obt, exp):
    return obt == exp


def TestNotEqual(obt, exp):
    return obt != exp


def TestMatch(obt, exp):
    return re.search(exp, obt) is not None


def TestLE(obt, exp):
    return obt <= exp


def TestLT(obt, exp):
    return obt < exp


def TestGE(obt, exp):
    return obt >= exp


def TestGT(obt, exp):
    return obt > exp


# =====================================================================================
class Comparison(object):
    """
    Class to perform a comparison of a particular field
    A comparison is specified with :
    - fields extracted from a packet. It contains the full field name,
      its "show" value, its "showname" value and its "value"
    - a kind : string indicating which value
               we want to compare ("show", "showname", "value")
    - a test string : one of  ==, !=, <=, >=, <, >, MATCH
    - an expected value
    The "do()" method will perform the proper
    expected comparison and compute diagnosis
    """
    listOp = [{"op": "==", "chk": str, "meth": TestEqual},
              {"op": "!=", "chk": int, "meth": TestNotEqual},
              {"op": "<=", "chk": int, "meth": TestLE},
              {"op": "<", "chk": int, "meth": TestLT},
              {"op": ">=", "chk": int, "meth": TestGE},
              {"op": ">", "chk": int, "meth": TestGT},
              {"op": "MATCH", "chk": str, "meth": TestMatch}
              ]

    def __init__(self, path, fields, kind, testStr, expected):
        self.op = None
        self.path = path
        self.fields = fields
        self.kind = kind
        self.obtained = get_value_from_kind(fields, kind)
        self.expected = expected
        self.testStr = testStr
        self.error = ""
        self.res = False
        for op in Comparison.listOp:
            if op["op"] == testStr:
                self.op = op
        if self.op is None:
            self.error = "Operator ({}) not supported".format(testStr)

    def do(self):
        if self.op is None:
            return self.res
        if self.op["chk"] == str:
            self.res = self.op["meth"](self.obtained, self.expected)
            return self.res
        try:
            obtInt = int(self.obtained)
        except ValueError:
            self.error = "Field [{}] is not an integer".format(self.obtained)
            return self.res
        try:
            expInt = int(self.expected)
            self.res = self.op["meth"](obtInt, expInt)
        except ValueError:
            self.error = "Expected value [{}] is not an integer"\
                .format(self.expected)
        return self.res

    def get_diag_res(self):
        str = "{} : {}[{}]:'{}' {} '{}'".\
            format(self.res, last_elt_from_path(self.path),
                   self.kind, self.obtained, self.testStr, self.expected)
        if len(self.error) > 0:
            str = str + " : {}".format(self.error)
        return str


# =====================================================================================
class NamedPacket(object):
    """
    Class NamedPacket is encapsulating :
    - a packet from pdml parsing
    - a name
    - its range in pdml file (starting from 1)
    """
    def __init__(self, packet, path, index):
        self.packet = packet
        self.path = path
        # index + 1 because python loop from 0
        # while numbering starts from 1 in a pcap
        self.index = index + 1
        self.name = last_elt_from_path(path)

    def __str__(self):
        return "{}({})".format(self.name, self.index)


# =====================================================================================
class PacketParser(object):
    """
    Class PacketParser embeds algorithm for pdml parsing
    - init method allows to get packets matching a packet firltering upon name
    - () methods allows to get
      list a fields matching a particular pattern
    """
    def __init__(self, pdmlFile, packetName=None, startPacket=1, endPacket=-1):
        self.pdmlFile = pdmlFile
        self.listSubPacket = []
        startPacket = int(startPacket)
        endPacket = int(endPacket)
        linux.fatal_if(not os.path.exists(pdmlFile),
                       "PDML file {} not found".format(pdmlFile))
        candidate = 0
        with open(pdmlFile, "rb") as file_obj:
            for idx, entry in enumerate(pdml.PdmlReader(file_obj=file_obj)):
                if len(entry.packet.findall(packetName)) > 0:
                    candidate = candidate + 1
                    if (candidate >= startPacket) and ((candidate <= endPacket) or (endPacket == -1)):
                        self.listSubPacket.append(
                            SubPacket(NamedPacket(entry.packet,
                                      entry.packet.paths(packetName)[0], idx)))

        linux.error_if(
            len(self.listSubPacket) == 0,
            "  Found {} packets matching \"{}\" in {}:{}"
            .format(len(self.listSubPacket),
                    packetName,
                    pdmlFile,
                    PacketParser.toPacketList(self.listSubPacket)))

    def isEmpty(self):
        return len(self.listSubPacket) == 0

    @staticmethod
    def toPacketList(listSubPacket):
        return [subPacket.namedPacket.index for subPacket in listSubPacket]

    def getMatchFromPath(self, pathExp=None):
        listSubPacket = []
        for subPacket in self.listSubPacket:
            newSubPacket = SubPacket(subPacket.namedPacket)
            for pathFound in newSubPacket.namedPacket.packet.paths(pathExp):
                listField = newSubPacket.namedPacket.packet.xpath(pathFound)
                newSubPacket.addFields(pathFound, listField)
            if len(newSubPacket.fields) > 0:
                listSubPacket.append(newSubPacket)
        return listSubPacket

    def getMatchFromPaths(self, pathExpList=[], verbose=True):
        listSubPacket = []
        for subPacket in self.listSubPacket:
            newSubPacket = SubPacket(subPacket.namedPacket)
            for path in pathExpList:
                if verbose:
                    linux.info("PACKET={} PathExp={}".format(newSubPacket.namedPacket, path))
                try:
                    listPathFound = newSubPacket.namedPacket.packet.paths(path)
                    for pathFound in listPathFound:
                        listField = newSubPacket.namedPacket.packet.xpath(pathFound)
                        fields = newSubPacket.addFields(pathFound, listField)
                        if verbose:
                            linux.info("  Path Found={} SHOW={} SHOWNAME={} VALUE={}".
                                       format(pathFound, fields.show, fields.showname, fields.value))
                except Exception:
                    pass
            listSubPacket.append(newSubPacket)
        return listSubPacket


class SubPacket(object):
    """
    A SubPacket is containing :
    - a named packet
    - a dictionary: each key is a path, each fields contain the show,showname and value
    We can retrieve them with :
    <subPacket>.fields['<path>'].show
    <subPacket>.fields['<path>'].showname
    <subPacket>.fields['<path>'].value
    """
    def __init__(self, namedPacket):
        self.namedPacket = namedPacket
        self.fields = {}

    def addFields(self, path, listField):
        self.fields['{}'.format(path)] = listField[0]
        return listField[0]

    def pathToStr(self, path):
        return "PACKET:{} PATH:{}".format(self.namedPacket, path)

    def printWithPrefix(self, prefix, path):
        linux.info("{}PACKET:{}".format(prefix, self.namedPacket))
        linux.info("{}PATH  :{}".format(prefix, path))

    def prefixStr(self, indexPacket, indexPath):
        return "    Packet[{}] Path[{}]:".format(indexPacket + 1, indexPath + 1)

# =====================================================================================


class ListParser():
    def __init__(self, listPacket):
        self.listPacket = listPacket
        self.cursor = 0

    def getNext(self, filter, maxDeep=10, debugFilter=False):
        maxDeep = int(maxDeep)
        self.filter = Filter(filter)
        if self.filter.isOK():
            for current in range(self.cursor, min(self.cursor+maxDeep, len(self.listPacket)-1)):
                listAlone = []
                listAlone.append(self.listPacket[current])
                if debugFilter:
                    handle = self.filter.initDebugFile(self.filter_file)
                    self.filter.traceDebug("HEAD:FILTER={} INPUT={}".format(filter, len(listAlone)))
                newListSubPacket = self.filter.apply(listAlone)
                if debugFilter:
                    handle.write("TAIL:FILTER={} OUTPUT={} ".
                                 format(filter, len(newListSubPacket)))
                    handle.close()
                if len(newListSubPacket) > 0:
                    self.cursor = current
                    return newListSubPacket
        return []


def get_root_path():
    """
    computing root path where to deploy Luashark
    Strategy is :
        if /home/<user> exists, it will be root path
        otherwise, retrieve TEMP_PATH robot variable as root path
    """
    root = "/home/{}".format(linux.get_user())
    if os.path.isdir(root):
        return root
    output_dir = BuiltIn().get_variable_value("${TEMP_PATH}")
    assert output_dir is not None, \
        "${TEMP_PATH} robot variable was not set in robot context"
    return output_dir


def get_value_from_kind(field, kind):
    if kind == "show":
        return field.show
    elif kind == "showname":
        return field.showname
    return field.value


def last_elt_from_path(path):
    return path.split("/")[-1]


def console(str):
    logger.console(str)
    logging.info(str)


def create_analyzer(isLuaSharkRequired=True, af_path=None):
    return analyzer(isLuaSharkRequired, af_path)
