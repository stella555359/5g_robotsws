# -*- coding: utf-8 -*-
"""
this file include keywords for TRS CA
Author chris.l.cao@nokia.com

"""

from pprint import pprint
from lxml import etree
import os
import os.path
import datetime
import xml.etree.ElementTree as ET
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')


try:
    import yaml
    from robot.libraries.BuiltIn import BuiltIn
except Exception as e:
    pprint(e)


class translib(object):
    _TRANS_DEBUG = 0

    def __init__(self):
        pass

    def _general_log_path(self, BuiltIn_obj):
        output_dir = BuiltIn_obj.get_variable_value("${OUTPUT_DIR}")
        suite_name = BuiltIn_obj.get_variable_value("${SUITE_NAME}")
        test_name = BuiltIn_obj.get_variable_value("${TEST_NAME}")
        print(test_name)
        timestamp = BuiltIn_obj.get_variable_value("${START_TIME}")
        if timestamp is None:
            timestamp = datetime.datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
            BuiltIn_obj.set_suite_variable("${START_TIME}", timestamp)
        if test_name:
            log_path = os.path.join(output_dir, timestamp, "TESTSUITE__"+str(suite_name), "TESTCASE__"+str(test_name))
        else:
            log_path = os.path.join(output_dir, timestamp, "TESTSUITE__"+str(suite_name))

        return log_path.replace(" ", "_").replace(":", "_").replace("-", "_")

    def trans_get_a_file(self, *path):
        """to get a file,
        *AUTHOR* chris.l.cao@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | path   | Yes  | file or path name |
        *RETURN VALUE*
        path string

        Example
        | ${myfile}  | trans_get_a_directory | path1 | myfile.txt |
        | ${myfile}  | trans_get_a_directory | path1 | path2 | myfile.txt |
        """
        BuiltIn_obj = BuiltIn()
        try:
            log_path = self._general_log_path(BuiltIn_obj)
            file_abs_path = os.path.join(log_path, os.path.sep.join(path))
            file_dir, file_name = os.path.split(file_abs_path)

            if not os.path.exists(file_dir):
                os.makedirs(file_dir)
            if not os.path.exists(file_abs_path):
                os.system("touch %s" % file_abs_path)
            return file_abs_path
        except Exception as e:
            pprint(e)

    def trans_get_a_directory(self, *path):
        """to get a directory,
        *AUTHOR* chris.l.cao@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | path   | Yes  | file path name |
        *RETURN VALUE*
        path string

        Example
        | ${mypath}  | trans_get_a_directory | path1 |
        | ${mypath}  | trans_get_a_directory | path1 | path2 |
        """
        BuiltIn_obj = BuiltIn()
        try:
            log_path = self._general_log_path(BuiltIn_obj)
            abs_path = os.path.join(log_path, os.path.sep.join(path))
            if not os.path.exists(abs_path):
                os.makedirs(abs_path)
            return abs_path
        except Exception as e:
            pprint(e)

    def get_distName_by_xpath_filter(self, scf_content, xpath):
        """to get the managedObject of the parameter belongs to via XML parsing, parameter filtering,
        distName filtering.

        *AUTHOR* chris.l.cao@nokia-sbell.com

        | Input Parameters | Man. | Description |
        | scf_content   | Yes  | Current SCF content fetched by REST, can be fetched via kw rest_get_scf_content |
        | xpath      | Yes | xpath expression |
        |           |    | if any duplicate may happen, using multiple parameters filtering and distName filtering |
        |           |     | in Xpath expression, e.g. distName=TNL-5   |


        *RETURN VALUE*
        distName, e.g, MRBTS-3006/TNLSVC-1/TNL-5/IPNO-1/IPRT-1

        Example
        | ${scf_content}=                  | rest get scf content |
        | get_distName_by_xpath_filter     | ${scf_content} | ${xpath} |

        """
        utf8_scf_content = scf_content.encode("utf-8")
        utf8_parser = etree.XMLParser(ns_clean=True, recover=True, encoding="utf-8")
        scf_root = etree.fromstring(utf8_scf_content, parser=utf8_parser)

        print(xpath)

        para_mo_list = scf_root.xpath(xpath,  namespaces={"ns": "raml21.xsd"})

        if len(para_mo_list) == 0:
            err = "No distName found"
            raise Exception(err)
        elif len(para_mo_list) == 1:
            return para_mo_list[0].get("distName")
        else:
            err = "Found {} distName!".format(len(para_mo_list))
            raise Exception(err)

    def get_multi_distName_by_xpath_filter(self, scf_content, xpath):
        """to get the managedObject of the parameter belongs to via XML parsing, parameter filtering,
          distName filtering.

        *AUTHOR* chris.l.cao@nokia-sbell.com

        | Input Parameters | Man. | Description |
        | scf_content      | Yes  | Current SCF content fetched by REST, can be fetched via kw rest_get_scf_content |
        | xpath         | Yes | xpath expression |
        |        |    | if any duplicate may happen, using multiple parameters filtering and distName filtering |
        |  |   |   in Xpath expression, e.g. distName=TNL-5   |


        *RETURN VALUE*
        list of distName, e.g, ['MRBTS-3006/TNLSVC-1/TNL-5/IPNO-1/IPRT-1','MRBTS-3006/TNLSVC-1/TNL-5/IPNO-1/IPRT-1']

        Example
        | ${scf_content}=                  | rest get scf content |
        | get_multi_distName_by_xpath_filter | ${scf_content} | ${xpath} |

        """
        rtn = []
        utf8_scf_content = scf_content.encode("utf-8")
        utf8_parser = etree.XMLParser(ns_clean=True, recover=True, encoding="utf-8")
        scf_root = etree.fromstring(utf8_scf_content, parser=utf8_parser)

        print(xpath)

        para_mo_list = scf_root.xpath(xpath,  namespaces={"ns": "raml21.xsd"})
        mo_list_len = len(para_mo_list)
        if mo_list_len == 0:
            print("No distName found")
        else:
            for item in para_mo_list:
                rtn.append(item.get("distName"))
        return rtn

    def Read_TRANS_Conf_Misc(self, yaml_file):
        rtn = {}
        # conffile=os.path.split(os.path.realpath(__file__))[0] + '/aa.conf'
        if not os.path.exists(yaml_file):
            print("{} not exists!".format(yaml_file))
            return {}

        try:
            with open(yaml_file) as f:
                rtn = yaml.load(f)
            print("======Read_TRANS_Conf_Misc result:==========")
            pprint(rtn)
            print("================")
        except Exception as e:
            print("chris")
            pprint(e)

        return rtn

    def get_trans_level_counter(self, file_name, distname, counter_id, PMSetup_index=None):
        """to get the managedObject of the parameter belongs to via XML parsing, \
        parameter filtering, distName filtering.

        *AUTHOR* chris.l.cao@nokia-sbell.com

        | Input Parameters | Man. | Description |
        | file_name      | Yes  | PM file name with full path in UTE server |
        | distname       | Yes | distName, e.g, MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1  |
        | counter_id    |  Yes  |  counter_name, e.g, M51301C0 |
        | PMSetup_index |  No  | PMSetup_index |

        *RETURN VALUE*
        return counter value and timestamp. Return type is tuple.

        Example
        | ${file}  |  set variable | /ute/home/btsauto/hran_ta/abc.xml |
        |  ${result}  |  get_trans_level_counter | ${file} | MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1 | M51301C7 |
        |  ${counter_value}  |  set variable | ${result[0]} |
        |  ${counter_timestamp}  |  set variable | ${result[1]} |
        """
        counters_all = self.get_specified_counters(file_name, counter_id)
        pprint(counters_all)

        counter_trans_level = {}
        if distname.startswith("/"):
            full_distname = "PLMN-PLMN" + distname.upper()
        else:
            full_distname = "PLMN-PLMN/" + distname.upper()
        pprint(full_distname)

        for key in counters_all.keys():
            if key[0] == full_distname:
                counter_trans_level[key[2]] = counters_all[key]
        counter_trans_level = sorted(counter_trans_level.iteritems(), key=lambda dictPara: dictPara[0], reverse=False)

        # print(counter_trans_level[-1])
        if len(counter_trans_level) == 0:
            raise Exception("distname '%s' is incorrect or '%s' is not a TRANS level counter" % (distname, counter_id))
        elif len(counter_trans_level) == 1:
            return counter_trans_level[-1][-1], counter_trans_level[-1][0]
        else:
            if PMSetup_index is None:
                # print(counter_trans_level[-1][0])
                return counter_trans_level[-1][-1], counter_trans_level[-1][0]
            elif PMSetup_index == "None":
                # print(counter_trans_level[-1][0])
                return counter_trans_level[-1][-1], counter_trans_level[-1][0]
            else:
                PMSetup_index = int(PMSetup_index)
                # print(counter_trans_level[PMSetup_index][0])
                return counter_trans_level[PMSetup_index][-1], counter_trans_level[PMSetup_index][0]

    def trans_counter_should_exist(self, file_name, distname, counter_id):
        """counter should exist.
        *AUTHOR* chris.l.cao@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | file_name      | Yes  | PM file name with full path in UTE server |
        | distname       | Yes | distName, e.g, MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1  |
        | counter_id    |  Yes  |  counter_name, e.g, M51301C0 |
        *RETURN VALUE*
        return true if counter exist, otherwise return false.
        Return type is boolean.
        Example
        | ${file}  |  set variable | /ute/home/btsauto/hran_ta/abc.xml |
        | ${result} | trans_counter_should_exist | ${file} | MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1 | M51301C7 |
        """
        counters_all = self.get_specified_counters(file_name, counter_id)
        pprint(counters_all)

        if distname.startswith("/"):
            full_distname = "PLMN-PLMN" + distname.upper()
        else:
            full_distname = "PLMN-PLMN/" + distname.upper()

        for key in counters_all.keys():
            if key and key[0] == full_distname and key[1] == counter_id:
                print("Found {} {}".format(full_distname, counter_id))
                return True
        return False

    def trans_counter_should_not_exist(self, file_name, distname, counter_id):
        """counter should not exist.
        *AUTHOR* chris.l.cao@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | file_name      | Yes  | PM file name with full path in UTE server |
        | distname       | Yes | distName, e.g, MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1  |
        | counter_id    |  Yes  |  counter_name, e.g, M51301C0 |
        *RETURN VALUE*
        return true if counter does not exist, otherwise return false.
        Return type is boolean.
        Example
        | ${file} | set variable | /ute/home/btsauto/hran_ta/abc.xml |
        | ${mo} | set variable | MRBTS-3006/TNLSVC-1/TNL-6/ETHSVC-1/ETHLK-1 |
        | ${result} | trans_counter_should_not_exist | ${file} | ${mo} | M51301C7 |
        """
        result = self.trans_counter_should_exist(file_name, distname, counter_id)
        if not result:
            print("Not found {} {}".format(distname, counter_id))
        return not result

    def get_specified_counters(self, file_path, counter_id):
        """This keyword is to get counters by specified counter id , lee enhances it in cbts18
        *AUTHOR* lingting.sun@nokia.com
        |  Input Parameters  |  Man. |  Description   |
        |  file_path         |  Yes  |  Uncompressed pm file path  |
        |  counter_id        |  Yes  |  Counter ID  |

        Example
        |  get_specified_counters  |  /root  |  BTS2103_PM_20160719_100000_SRAN_xml.gz  |  M8001C10  |  51852  |
        |  $result}=    |  ('CellID:51852', 'M8001C10', '2016-07-19T09:30:00.000+02:00:00') ['90001']  |
        """
        # print file_path
        root = ET.parse(file_path).getroot()
        result_list_1 = []
        self._find_node(root, "PMSetup", result_list_1)
        counters_all = {}
        for node in result_list_1:
            result_list_2 = []
            self._find_node(node, "PMMOResult", result_list_2)
            for node_2 in result_list_2:
                result_list_3 = []
                result_list_4 = []
                result_list_5 = []
                self._find_node(node_2, "MO", result_list_3)
                self._find_node(node_2, "NE-WBTS_1.0", result_list_4)
                # self._find_node(node_2, "PMTarget", result_list_4)
                for node_3 in result_list_4:
                    self._find_node(node_3, counter_id, result_list_5)
                    for i in result_list_5:
                        node_name = result_list_3[0].getchildren()[0].text
                        counters_all[node_name, i.tag, node.attrib['startTime']] = i.text
        return counters_all

    def _find_node(self, node, tag_name, result_list):
        """This keyword is used to find the target node
        *AUTHOR* lingting.sun@nokia.com
        |  Input Parameters  |  Man.  |  Description   |
        |  node              |  Yes   |  The started parent element for element searching  |
        |  tag_name          |  Yes   |  Tag for element searching  |
        |  result_list       |  Yes   |  The founded element list  |
        Example
        |  self._find_node  |  root  |  "PMSetup"  |
        """
        if node.tag.lower() == tag_name.lower():
            result_list.append(node)
        else:
            childern = node.getchildren()
            for child in childern:
                self._find_node(child, tag_name, result_list)


if __name__ == "__main__":
    t = translib()
    '''
    scf_path="/tmp/tmpghHJc2taf_selenium_coam_download/
    Configuration_scf_MRBTS-3002_5G19B_Classic_AEQA_DZR_20190916-0847.xml"
    a=t.get_bts_id(scf_path)
    '''
    a = t.get_trans_level_counter("PM.BTS-3002.20190924.092000.ANY.xml",
                                  "/MRBTS-3002/TNLSVC-1/TNL-1/IPNO-1", "M51325C0")
    print(a)
