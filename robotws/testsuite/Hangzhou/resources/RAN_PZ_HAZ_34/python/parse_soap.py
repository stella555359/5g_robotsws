# -*- coding: utf-8 -*
"""
Author: Wang Yixiang
Contacts: yixiang.x.wang@nokia-sbell.com
Description: Parse UnitOAM_SOAP_Log.xml to get values as request

"""
import logging
import re
from robot.libraries.XML import XML
from taf.transport.ssh import ssh
import os
import gzip

ssh = ssh()
logger = logging.getLogger(__name__)


class SOAPParser(object):

    def __init__(self):
        self.xml = XML()

    def get_soap_msg_modify_parameter_req(self, log_path, distName_value):
        """
        get modifyParameterReq value
        :param log_path:log_path=path+soaplogName,
        :param distName_value:attribute(distName) of managedObject, and it will get newValue text of the item
        :return: the text value of item <newValue>TRUE</newValue>
        """
        msg_type_xpath = "Envelope/Body/modifyParameterReq"
        value_dict = self._parse_soap_log_get_dict(log_path=log_path, attribute_name='distName',
                                                   attribute_value=distName_value, msg_type_xpath=msg_type_xpath)
        if "subscribe" in value_dict.keys():
            return value_dict["subscribe"]
        elif "active" in value_dict.keys():
            return value_dict["active"]
        else:
            return "Not Found"

    def get_soap_msg_par_value_change_ind(
        self, log_path, distName_value, parameter_name=None
    ):
        """
        get parValueChangeInd value
        :param log_path:log_path:log_path=path+soaplogName,
        :param distName_value:attribute(distName) of managedObject, and it will get newValue text of the item
        :return:the text value of item <newValue>TRUE</newValue>
        """
        msg_type_xpath = "Envelope/Body/parValueChangeInd"
        value_dict = self._parse_soap_log_get_dict(log_path=log_path, attribute_name='distName',
                                                   attribute_value=distName_value, msg_type_xpath=msg_type_xpath)
        if parameter_name is not None:
            return value_dict[parameter_name]
        elif "subscribe" in value_dict.keys():
            return value_dict["subscribe"]
        elif "active" in value_dict.keys():
            return value_dict["active"]
        else:
            return "Not Found"

    def get_soap_msg_supported_feature(self, log_path, distName_value):
        """
        get parValueChangeInd value
        :param log_path:log_path:log_path=path+soaplogName,
        :param distName_value:attribute(distName) of managedObject, and it will get newValue text of the item
        :return:the text value of item <newValue>TRUE</newValue>
        """
        msg_type_xpath = "Envelope/Body/retrieveParameterRsp"
        value_dict = self._parse_soap_log_get_dict(log_path=log_path, attribute_name='distName',
                                                   attribute_value=distName_value, msg_type_xpath=msg_type_xpath)
        if value_dict != {}:
            return value_dict["feature"]
        else:
            return "Not Found"

    def check_soapmsg_parvaluechangeind(self, log_path, class_value, parameterName, newValue):
        """
        get parValueChangeInd value
        :param log_path:log_path:log_path=path+soaplogName,
        :param class_value:attribute(class) of managedObject, and it will get newValue text of the item
        :param parameterName:parameterName
        :param newValue:the new value of parameterName
        """
        msg_type_xpath = "Envelope/Body/parValueChangeInd"
        value_dict = self._parse_soap_log_get_dict(log_path=log_path, attribute_name='class',
                                                   attribute_value=class_value, msg_type_xpath=msg_type_xpath)
        try:
            if value_dict[parameterName] == newValue:
                return True
            else:
                print("%s value is not equal to %s" % (parameterName, newValue))
                return False
        except Exception:
            print("Not Found %s" % parameterName)
            return False

    def get_soap_msg_sw_inventory_rsp(self, log_path):
        """
        Get values of swInventoryRsp
        :param log_path: log_path=path+soaplogName,
        :return: dict of swInventoryRsp
        """
        sw_inventory_rsp_dict = {}
        msg_type_xpath = "Envelope/Body/swInventoryRsp/bldData"
        rsp_elements = self._parse_soap_log_get_elements(log_path, msg_type_xpath)

        for ack_element in rsp_elements:
            if ack_element.tag == 'fileData':
                file_data_dict = {}
                file_data_elements = self.xml.get_child_elements(ack_element, ".")
                for file_data_element in file_data_elements:
                    file_data_dict[file_data_element.tag] = file_data_element.text
                if 'active' in file_data_dict.values():
                    sw_inventory_rsp_dict = dict(sw_inventory_rsp_dict.items() + file_data_dict.items())
            else:
                sw_inventory_rsp_dict[ack_element.tag] = ack_element.text

        return sw_inventory_rsp_dict

    def get_soap_msg_module_ready_ack(self, log_path):
        """
        Get values of moduleReadyAck
        :param log_path: log_path=path+soaplogName
        :return: dict of moduleReadyAck
        """
        module_ready_act_dict = {}
        msg_type_xpath = "Envelope/Body/moduleReadyAck"
        ack_elements = self._parse_soap_log_get_elements(log_path, msg_type_xpath)

        for ack_element in ack_elements:
            module_ready_act_dict[ack_element.tag] = ack_element.text
        return module_ready_act_dict

    def get_soap_msg_module_ready_ind(self, log_path):
        """
        Get values of moduleReadyInd
        :param log_path: log_path=path+soaplogName
        :return: dict of moduleReadyInd
        """
        module_ready_ind_dict = {}
        msg_type_xpath = "Envelope/Body/moduleReadyInd"
        ind_elements = self._parse_soap_log_get_elements(log_path, msg_type_xpath)

        for ack_element in ind_elements:
            module_ready_ind_dict[ack_element.tag] = ack_element.text
        return module_ready_ind_dict

    def get_carrier_info(self, log_path, distName_value):
        """
        get TX carrier parameter info, include:power, channel bandwidth, frequency, type
        :param log_path:log_path=path+soaplogName
        :param distName_value:attribute(distName) of managedObject
        :return:dict of parameters
        """
        msg_type_path = "Envelope/Body/parValueChangeInd"
        carrier_info_dict = self._parse_soap_log_get_dict(log_path, "distName", distName_value, msg_type_path)

        return carrier_info_dict

    def _parse_soap_log_get_elements(self, log_path, msg_type_xpath):
        """
        parse soap log and get elements
        :param log_path: log_path=path+soaplogName,
        :param msg_type_xpath: message type of xpath
        :return: item of msg_type_xpath
        """
        xml_root = self._get_soap_log_xml_root(log_path)
        elements = []

        xpath_elements = self.xml.get_elements(source=xml_root, xpath=msg_type_xpath)
        for element in xpath_elements:
            child_elements = self.xml.get_child_elements(source=element, xpath=".")
            elements = elements + child_elements
        return elements

    def _parse_soap_log_get_dict(self, log_path, attribute_name, attribute_value, msg_type_xpath):
        """
        parse soap log and get value dictionary from xml
        :param log_path:log_path:log_path=path+soaplogName,
        :param attribute_name:attribute of managedObject
        :param attribute_value:attribute value of attribute name
        :param msg_type_xpath: message type of xpath
        :return:dict of give xpath and attribute
        """
        info_dict = {}
        xml_root = self._get_soap_log_xml_root(log_path)
        object_xpath = ("{}/managedObject[@{}='{}']").format(msg_type_xpath,
                                                             attribute_name, attribute_value)
        object_elements = self.xml.get_elements(source=xml_root, xpath=object_xpath)
        for elements in object_elements:
            para_elements = self.xml.get_child_elements(elements, ".")
            for para_element in para_elements:
                name_elements = self.xml.get_elements(source=para_element, xpath="./parameterName")
                value_elements = self.xml.get_elements(source=para_element, xpath="./newValue")
                for i, name in enumerate(name_elements):
                    if value_elements[i].text is not None:
                        info_dict[name.text] = value_elements[i].text
                    else:
                        value_child = {}
                        value_child_elements = self.xml.get_child_elements(value_elements[i], ".")
                        for j, value_sub_element in enumerate(value_child_elements):
                            if value_sub_element.text is not None:
                                value_child[value_sub_element.tag] = value_sub_element.text
                            else:
                                value_sub_child_elements = self.xml.get_child_elements(value_sub_element, ".")
                                for value_sub_sub_element in value_sub_child_elements:
                                    value_child[value_sub_sub_element.tag] = value_sub_sub_element.text
                        info_dict[name.text] = value_child
        return info_dict

    def _get_soap_log_xml_root(self, log_path):
        """
        read soap log content and convert to standard xml format and parse xml with xml library
        :param log_path: log_path=log_path+log_name
        :return: self.xml_root
        """
        soap_log_content = "<root>\n"
        with open(log_path) as f:
            lines = f.readlines()
            for line in lines:
                timestamp_reg = re.search('timestamp value=(\\d+.*?Z)', line)
                # if timestamp is not string, change to string, or else xml library cannot parse
                if timestamp_reg:
                    timestamp_str = timestamp_reg.group(1)
                    line = line.replace(timestamp_str, '"' + timestamp_str + '"')
                soap_log_content = soap_log_content + line
            soap_log_content = soap_log_content + "\n</root>"
        try:
            xml_root = self.xml.parse_xml(source=soap_log_content)
        except Exception as e:
            logging.info("str(e):{}".format(str(e)))
            raise AttributeError("Parse soap log failed, please check! {}".format(log_path))
        return xml_root

    def calculate_NRARFCN_based_on_5g_frequency(self, frequency):
        """
        Author: Ding Binmei
        Description: Calculate nrarfcn
        :param frequency: 5G frequency
        :return:
        """
        frequency = int(frequency)/1000.0/1000.0
        if 0 <= frequency < 3000:
            N_ref_offs = 0
            F_ref_offs = 0
            deltaF_global = 5
        elif 3000 <= frequency < 24250:
            N_ref_offs = 600000
            F_ref_offs = 3000
            deltaF_global = 15
        elif 24250 <= frequency < 100000:
            N_ref_offs = 2016667
            F_ref_offs = 24250.08
            deltaF_global = 60
        else:
            raise Exception("Unsupported frequency range")
        nrarfcn = int(N_ref_offs + (frequency - F_ref_offs)*1000.0/deltaF_global)
        return nrarfcn

    def tansfer_carrier_info_to_webUI_format(self, carrier_info_dict):
        """
        tansfer value to the same unit, include: channel bandwidth, frequency
        2019-11-21: Ding Binmei: change implementation for calculate nrarfcn to support all frequency range
        :param carrier_info_dict: info get from soap log
        :return: the transfered value
        """
        if "bandwidth" in carrier_info_dict:
            carrier_info_dict["bandwidth"] = str(int(carrier_info_dict.get("bandwidth", 0)) / 1000000)
            frequency = carrier_info_dict["frequency"]
        else:
            carrier_info_dict["bandwidth"] = str(int(carrier_info_dict.get("channels").get("bandwidth")) / 1000000)
            frequency = carrier_info_dict["channels"]["frequency"]
        nrarfcn = self.calculate_NRARFCN_based_on_5g_frequency(frequency=frequency)
        carrier_info_dict["frequency"] = str(nrarfcn)
        return carrier_info_dict

    def get_number_of_item(self, log_path, tag_name):
        """
        To count the number of moduleReadyInd and moduleReadyAck, can use to verify periodlly send.
        :param log_path: log_path=log_path+log_name
        :param tag_name: tag name
        :return: the times of item appearence
        """
        self.xml_root = self._get_soap_log_xml_root(log_path)
        msg_type_xpath = ("Envelope/Body/{}").format(tag_name)
        elements = self.xml.get_elements(source=self.xml_root, xpath=msg_type_xpath)
        return len(elements)

    def parse_soap_log_return_dict(self, log_path, attribute_name, attribute_value, msg_type_xpath):
        """
        parse soap log and get value dictionary from xml
        :param log_path:log_path:log_path=path+soaplogName,
        :param attribute_name:attribute of managedObject
        :param attribute_value:attribute value of attribute name
        :param msg_type_xpath: message type of xpath
        :return:dict of give xpath and attribute
        example:
        log_path=r'UnitOAM_SOAP_Log.xml'
        attribute_name='distName'
        attribute_value='FR1_TxArrayCarrier4'
        msg_type_xpath='Envelope/Body/parValueChangeInd'

        return:
        {'power': '20', 'cyclicPrefix': 'NORMAL_CP', 'defaultSubcarrierSpacing': 'KHZ_120', 'state': 'READY',
        'sfnOffsets': {'alpha': '0', 'beta': '0'}, 'subscribe': 'TRUE', 'bandwidth': '100000000',
        'frequency': '27836640000', 'active': 'TRUE', 'array': 'txArray2', 'type': 'NR'}
        """
        info_dict = self._parse_soap_log_get_dict(log_path=log_path, attribute_name=attribute_name,
                                                  attribute_value=attribute_value, msg_type_xpath=msg_type_xpath)
        return info_dict

    def search_distname_tx_carrier(self, log_path):
        """
        search distname because of different RU and programe have different name
        AEQB:distName="TxArrayCarrier1_1"
        AWHHD(19A):distName="NR45.TX1_1_1"
        AWHHD(19B):distName="NR45.TX16383_1_1"
        :param log_path:soap log full path
        :return:distName, such as TxArrayCarrier1_1, NR45.TX1_1_1 or NR45.TX16383_1_1
        """
        dist_name = "Not found"
        with open(log_path) as f:
            for line in f.readlines():
                match_reg = re.search('.*modifyParameterReq.*distName="(.{0,5}TX.{0,12}1_1)?".*',
                                      line, re.IGNORECASE)
                if match_reg:
                    dist_name = match_reg.group(1)
                    break
        return dist_name

    def _parse_soap_log_get_dict_include_pre(self, log_path, attribute_name, attribute_value, msg_type_xpath):
        """
        parse soap log and get value dictionary from xml
        :param log_path:log_path:log_path=path+soaplogName,
        :param attribute_name:attribute of managedObject
        :param attribute_value:attribute value of attribute name
        :param msg_type_xpath: message type of xpath
        :return:dict of give xpath and attribute
        """
        info_dict_total = []
        xml_root = self._get_soap_log_xml_root(log_path)
        object_xpath = ("{}/managedObject[@{}='{}']").format(msg_type_xpath, attribute_name, attribute_value)
        object_elements = self.xml.get_elements(source=xml_root, xpath=object_xpath)
        for elements in object_elements:
            info_dict = {}
            para_elements = self.xml.get_child_elements(elements, ".")
            for para_element in para_elements:
                name_elements = self.xml.get_elements(source=para_element, xpath="./parameterName")
                value_elements = self.xml.get_elements(source=para_element, xpath="./newValue")
                for i, name in enumerate(name_elements):
                    if value_elements[i].text is not None:
                        info_dict[name.text] = value_elements[i].text
                    else:
                        value_child = {}
                        value_child_elements = self.xml.get_child_elements(value_elements[i], ".")
                        for j, value_sub_element in enumerate(value_child_elements):
                            if value_sub_element.text is not None:
                                if value_sub_element.tag in value_child.keys():
                                    value_child[value_sub_element.tag] = value_child[value_sub_element.tag] + \
                                                                         "," + value_sub_element.text
                                else:
                                    value_child[value_sub_element.tag] = value_sub_element.text
                            else:
                                value_sub_child_elements = self.xml.get_child_elements(value_sub_element, ".")
                                for value_sub_sub_element in value_sub_child_elements:
                                    value_child[value_sub_sub_element.tag] = value_sub_sub_element.text
                        if len(value_child) == 0:
                            value_child = ""
                        info_dict[name.text] = value_child
            info_dict_total.append(info_dict)
        return info_dict_total

    def getacceptclockclass(self, logpath):
        result = self._parse_soap_log_get_dict_include_pre(
            log_path=logpath,
            attribute_name="distName",
            attribute_value="ptpConfig",
            msg_type_xpath="Envelope/Body/parValueChangeInd")
        tmp = []
        for item in result:
            if 'acceptedClockClasses' in item.keys():
                tmp.append(item['acceptedClockClasses']['clockClass'])
        clockclass = []
        if len(tmp) == 0:
            clockclass.append(' ')
            clockclass.append(' ')
        elif len(tmp) == 1:
            newValue = tmp[0]
            clockclass.append(' ')
            clockclass.append(newValue)
        elif len(tmp) >= 2:
            tmp = tmp[-2:]
            clockclass.append(tmp[1])
        return clockclass

    def getsyncstate(self, logpath):
        result = self._parse_soap_log_get_dict_include_pre(
            log_path=logpath,
            attribute_name="distName",
            attribute_value="synchronization",
            msg_type_xpath="Envelope/Body/parValueChangeInd")
        syncstate = []
        if len(result) == 0:
            syncstate.append(' ')
            syncstate.append(' ')
        elif len(result) == 1:
            newValue = result[0]['state']
            syncstate.append(' ')
            syncstate.append(newValue)
        elif len(result) >= 2:
            result = result[-2:]
            syncstate.append(result[0]['state'])
            syncstate.append(result[1]['state'])
        return syncstate

    def getlockstate(self, logpath):
        result = self._parse_soap_log_get_dict_include_pre(
            log_path=logpath,
            attribute_name="distName",
            attribute_value="ptpStatus",
            msg_type_xpath="Envelope/Body/parValueChangeInd")
        tmp = []
        for item in result:
            if 'lockState' in item.keys():
                tmp.append(item['lockState'])
        lockstate = []
        if len(result) == 0:
            lockstate.append(' ')
            lockstate.append(' ')
        elif len(tmp) == 1:
            newValue = tmp[0]
            lockstate.append(' ')
            lockstate.append(newValue)
        elif len(tmp) >= 2:
            tmp = tmp[-2:]
            lockstate.append(tmp[0])
            lockstate.append(tmp[1])
        return lockstate


def __return_str(input_value):
    if isinstance(input_value, bytes):
        return input_value.decode('utf-8')
    elif isinstance(input_value, str):
        return input_value
    else:
        try:
            return str(input_value)
        except Exception as e:
            logger.error(e)
            logger.warning('Return ""')
            return ''


def __list_dir_over_ssh(file_name, directory='.', connection=None):
    # cmd_list_dir = "ls -lt {} | grep {}[0-9] | awk '{{print $9}}'".format(directory, file_name)
    cmd_list_dir = "ls -lt {} | grep {}.*Log[0-9] | awk '{{print $9}}'".format(directory, file_name)
    output = ssh.execute(cmd_list_dir, connection=connection, timeout=10)
    list_dir = re.split('\r\n|\n', output)
    logger.debug("files in {}: {}".format(directory, list_dir))
    return map(__return_str, list_dir)


def __download_soap_and_get_content(connection, local_dir, remote_dir, file_name):
    content = ''
    if file_name:
        logger.debug("Get soap file: {}".format(file_name))
        local_path = os.path.join(local_dir, file_name)
        ssh.download_file(remote_path=os.path.join(remote_dir, file_name),
                          local_path=local_path,
                          connection=connection)
        if os.path.isfile(local_path):
            name, extension = os.path.splitext(local_path)
            if 'gz' in extension:
                with gzip.GzipFile(local_path, 'r') as g:
                    content = g.read()
            elif 'xml' in extension:
                with open(local_path, 'r') as f:
                    content = f.read()
    return __return_str(content)


def getsoapfile(connection, subdir='*'):
    remote_dir = '/run'
    local_dir = '/tmp'
    latest_zip = ''
    latest_xml = ''
    # soap_name = 'UnitOAM_SOAP_Log'
    soap_name = 'UnitOAM_SOAP'
    os.system('rm -rf {}/{}*'.format(local_dir, soap_name))
    output_soap_file = '{}/{}.xml'.format(local_dir, soap_name)
    cmd = 'ls -l /ram/{}/UnitOAM_SOAP*'.format(subdir)
    output = ssh.execute(cmd, connection=connection, timeout=10)
    if 'No such file or directory' not in output:
        result = re.search(pattern=r'/ram/(.*)/UnitOAM_SOAP*', string=output)
        mid_dir = result.group(1)
        remote_dir = remote_dir + "/"+mid_dir
    for file in __list_dir_over_ssh(soap_name, remote_dir, connection):
        if 'gz' in file and latest_zip == '':
            latest_zip = file
        elif 'xml' in file and latest_xml == '':
            latest_xml = file
    zip_content = __download_soap_and_get_content(connection, local_dir, remote_dir, latest_zip)
    xml_content = __download_soap_and_get_content(connection, local_dir, remote_dir, latest_xml)
    with open(output_soap_file, 'w') as f:
        f.writelines(zip_content)
        f.writelines(xml_content)
    return output_soap_file


def checkuptime(uptime):
    if 'day' in uptime:
        uptime = uptime.replace(' ', '')
        if 'min' in uptime:
            day = int(re.match(r'(.*)day', uptime).group(1))
            minutes = int(re.search(r',(.*)min', uptime).group(1))
            time = day * 24 * 3600 + minutes * 60
        else:
            day = int(re.match(r'(.*)day', uptime).group(1))
            hours = int(re.search(r',(.*):', uptime).group(1))
            minutes = int(re.search(r':(.*)', uptime).group(1))
            time = day * 24 * 3600 + hours * 3600 + minutes * 60
    elif 'min' in uptime:
        uptime = uptime.replace(' ', '')
        minutes = int(re.search(r'(.*)min', uptime).group(1))
        time = minutes * 60
    else:
        hours = int(re.search(r'(.*):', uptime).group(1))
        minutes = int(re.search(r':(.*)', uptime).group(1))
        time = hours*3600+minutes*60
    return time


def getusefulid(list1, list2):
    flag = 1
    for i in list1:
        if i in list2:
            list2.remove(i)
        else:
            continue
    if list2 == []:
        flag = 0
    return flag, list2


def samelist(list1):
    list2 = list1[:]
    return list2


def checkuenumber(object1):
    try:
        number1 = len(object1)
    except Exception:
        number1 = 1
    return number1


def getallsoapfiles(connection, local_dir, subdir='*'):
    remote_dir = '/run'
    # soap_name = 'UnitOAM_SOAP_Log'
    soap_name = 'UnitOAM_SOAP'
    os.system('rm -rf {}/{}*'.format(local_dir, soap_name))
    output_soap_file = '{}/{}.xml'.format(local_dir, soap_name)
    cmd = 'ls -l /ram/{}/UnitOAM_SOAP*'.format(subdir)
    output = ssh.execute(cmd, connection=connection, timeout=10)
    if 'No such file or directory' not in output:
        result = re.search(pattern=r'/ram/(.*)/UnitOAM_SOAP*', string=output)
        mid_dir = result.group(1)
        remote_dir = remote_dir + "/"+mid_dir
    f = open(output_soap_file, 'w')
    for file in __list_dir_over_ssh(soap_name, remote_dir, connection):
        xml_content = __download_soap_and_get_content(connection, local_dir, remote_dir, file)
        f.writelines(xml_content)
    return output_soap_file
