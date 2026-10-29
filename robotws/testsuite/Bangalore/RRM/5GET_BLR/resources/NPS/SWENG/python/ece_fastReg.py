from taf.transport.ssh import ssh
from taf.config.cbts import CbtsProvider
from taf.config.scf import scf
import re
import os
import sys
import logging
import datetime
import robot
import lxml.etree as tree
from functools import wraps
import json
import unicodedata
import time
# import commands

from robot.libraries.BuiltIn import BuiltIn

bi = BuiltIn()

try:
    import robot.api.logger as logging
except ImportError:
    import logging

csn = ssh()
scf_manipulator = scf()


class AbstractObjectComparator:
    """
    Implements __cmp__ method which compares all the object's attributes.

    In case the object has list variable _compare_attributes, the variables
    in that list are checked when objects are compared. Otherwise all the
    object's attributes that does not start with underscore '_' are compared
    excluding methods.

    If there are any exceptions during this comparison, -1 will be returned.
    """

    def __cmp__(self, other):
        try:
            if hasattr(self, '_compare_attributes'):
                attributes = getattr(self, '_compare_attributes')
            else:
                attributes = [attr for attr in dir(self)
                              if not attr.startswith('_') and
                              not isinstance(getattr(self, attr), MethodType)]
            for attr in attributes:
                difference = cmp(getattr(self, attr), getattr(other, attr))
                if difference != 0:
                    return difference
            return 0
        except KeyboardInterrupt:
            raise
        except BaseException:
            return -1


class CommonItem(AbstractObjectComparator):
    """ base class for items contained in CommonDict """

    def __str__(self):
        """ support a nice string representation with all attribute values"""
        tmp = ",".join(
            sorted(
                [
                    "%s=%s" %
                    (item,
                     getattr(
                         self,
                         item)) for item in dir(self) if not item.startswith("_") and getattr(
                        self,
                        item) is not None and not isinstance(
                        getattr(
                            self,
                            item),
                        MethodType)]))
        for i in range(len(tmp)):
            if ord(tmp[i]) > 127:
                tmp = tmp.replace(tmp[i], " ")
        return tmp

    def __repr__(self):
        return self.__str__()

    def __unicode__(self):
        return self.__str__()

    def __iter__(self):
        try:
            if hasattr(self, '_compare_attributes'):
                attributes = getattr(self, '_compare_attributes')
            else:
                attributes = [attr for attr in dir(self)
                              if not attr.startswith('_') and
                              not isinstance(getattr(self, attr), MethodType)]
        except KeyboardInterrupt:
            raise
        self._attributes = attributes
        self._max = len(attributes)
        self._index = 0

        return self

    def next(self):
        if self._index < self._max:
            result = self._attributes[self._index]
            self._index += 1
            return result
        else:
            raise StopIteration

    def __getitem__(self, key, value=''):
        if not self:
            return None
        try:
            if hasattr(self, key):
                return getattr(self, key)
        except KeyError:
            pass
            return value
        return None

    def __setitem__(self, *args):
        items = [arg for arg in args]
        if len(items) % 2 != 0:
            raise ValueError(
                'There should be an even number of key-value-pairs')
        iter_items = iter(items)
        for arg in iter_items:
            setattr(self, arg, iter_items.next())
        return self

    def get(self, key, value=''):
        return self.__getitem__(key, value='')


def create_common_item(*key_value_pairs):
    if len(key_value_pairs) % 2 != 0:
        raise ValueError(
            "Adding data to a common item failed. There should be an even number of key-value-pairs.")
    item = CommonItem()
    item.__setitem__(*key_value_pairs)
    return item


def update_common_item(item, *key_value_pairs):
    if len(key_value_pairs) % 2 != 0:
        raise ValueError(
            "Adding data to a common item failed. There should be an even number of key-value-pairs.")
    if not item:
        item = CommonItem()
    item.__setitem__(*key_value_pairs)
    return item


def compare_common_item(one, other):
    result = CommonItem()
    result.info = ''
    result.success = False
    differences = {}
    diff_keys = set(one).symmetric_difference(set(other))
    for attr in diff_keys:
        if attr in one.__iter__():
            differences[attr] = str(one.get(attr)) + "!=" + \
                str(other.get(attr)) + "  #second_value_missing"
        else:
            differences[attr] = str(one.get(attr)) + "!=" + \
                str(other.get(attr)) + "  #first_value_missing"
    for attr in set(one.__iter__()) - diff_keys:
        difference = cmp(str(one.get(attr)), str(other.get(attr)))
        if difference != 0:
            differences[attr] = str(one.get(
                attr)) + "!=" + str(other.get(attr)) + " #first_value_different_from_second_value"
    if len(differences.keys()) == 0:
        result.success = True

    for key in differences.keys():
        result.info += "\"" + key + "\": \"" + differences.get(key) + "\"\n"
    return result


class CommonDict(dict):
    """ A specialization of generic python dict with the following extensions/differences:
    - if a key/index does not exits Common dict will not raise KeyError but return None
    - may be used like a list an element is addressed via an integer as index
      (does not work if you use integers as keys)
    - support a list of keys in the order they have been inserted: ordered_keys
    - supporting sorting of this ordered_keys attribute and thus the "list" CommonDict itself
    - nice string representation also if objects are contained
    - contained object should be derived from CommonItem (not mandatory)
    """

    def __init__(self, *args):
        """ should also be called by subclasses,
        otherwise you might have problems with empty CommonDicts when the attribute ordered_keys is not present
        """
        dict.__init__(self, *args)
        self.ordered_keys = []

    def __str__(self):
        """ support a nice string representation """
        try:
            tmp = "\n".join([str(key) + ':' + str(self[key])
                             for key in self.ordered_keys])
            for i in range(len(tmp)):
                if ord(tmp[i]) > 127:
                    tmp = tmp.replace(tmp[i], " ")
            return tmp
        except AttributeError:
            return ""

    def __repr__(self):
        return self.__str__()

    def __unicode__(self):
        return self.__str__()

    def __getitem__(self, key):
        """ access the item identified by key, either behave like a dictionary or like a list
        return None is no item is found
        """
        if len(self) == 0:
            return None
        try:
            return dict.__getitem__(self, key)
        except KeyError:
            pass
        if isinstance(key, type(1)):
            try:
                return dict.__getitem__(self, self.ordered_keys[key])
            except IndexError:
                pass
        return None

    def __setitem__(self, key, item):
        """ store the new item in the dictionary and append the key to ordered_list """
        if isinstance(key, type(1)):
            raise RuntimeError("CommonDict does not support integer as key")
        dict.__setitem__(self, key, item)
        try:
            if key in self.ordered_keys:
                self.ordered_keys.remove(key)
            self.ordered_keys.append(key)
        except AttributeError:
            self.ordered_keys = [key, ]

    def __delitem__(self, key):
        """ remove the new item from the dictionary and remove the key from ordered_list,
        works both with key and index """
        try:
            dict.__delitem__(self, key)
            self.ordered_keys.remove(key)
        except KeyError:
            if isinstance(key, type(1)):
                dict.__delitem__(self, self.ordered_keys[key])
                del(self.ordered_keys[key])

    def __getattr__(self, name):
        """ support direct access to the item's attributes if only a single item is contained """
        if len(self) != 1:
            raise AttributeError
        return getattr(self.values()[0], name)

    def length(self):
        """ only because x.length() looks nicer than x.__len__()"""
        return len(self)

    def _get_empty_container(self):
        """ needed so that select_entries_from_list can return the correct type of container,
        can be overwritten by subclasses """
        return CommonDict()

    def sort(self, *args):
        """ sorts attribute orderd_keys and thus also CommonDict itself if used as a list
        can be overwritten by subclasses if a special sorting algortihm is needed. """
        try:
            self.ordered_keys.sort(*args)
        except AttributeError:
            pass


def run_keyword_with_variables(kw_name, *args, **kwargs):
    '''set inst = 'Y' to control the keyword invoke mode.
    if Y, robot will execute keyword's instance, no log node is generated.
    default is to use robot's run_keyword and log node is generated
    sample:
    no_log_kw = kw('Config SCF file', 'Config_File_Name', inst = 'Y')
    logged_kw = kw('Config SCF file', 'Config_File_Name')

    author: Cai Hongkun
    '''
    output = None
    kw_fname = kw_name.replace(' ', '_').lower()
    is_ignore = 'ignore_error' in kwargs and kwargs['ignore_error'] == 'Y' or False
    try:
        if 'inst' in kwargs and kwargs['inst'] == 'Y':
            try:
                if robot.__version__.startswith('3.0'):
                    libs = bi._get_context().namespace._kw_store.libraries
                    func = None
                    for lib in libs.values():
                        if lib.handlers.__contains__(kw_name):
                            func = lib.handlers[kw_name]._method
                    if func is None:
                        raise KeyError('[%s] is not found!' % kw_name)
                else:
                    func = bi._context.get_handler(kw_name)._method
            except Exception as e:
                print(e)
                output = bi.run_keyword(kw_name, *args)
            else:
                output = func(*args)
        else:
            output = bi.run_keyword(kw_name, *args)
    except Exception as e:
        if not is_ignore:
            raise Exception(e)
    return output


def check_the_files_with_connection(keyword):
    """Decorate the given keyword to check the file is exist.
    Modifies the keyword "conn" parameter, so that its value
    is passed to a subroutine (csn.assert_file_exists) first,
    and used for check the file. The value returned by the
    subroutine will influence on next step.
    """

    @wraps(keyword)
    def check_the_files(*args, **kwargs):
        remote_path = args[0]
        conn = "CTRL"
        run_keyword_with_variables("csn.assert_file_exists", remote_path,
                                   "connection={}".format(conn))
        return keyword(*args, **kwargs)

    return check_the_files


def update_scf_parameter_of_interface(scf_local_path, scf_para_list):
    """Update related scf parameters.
    This keyword update dist_name and LTE_x2_p_name according to scf_local_path.
    """
    interface_distname = check_out_dist_name_for_interfaces(scf_local_path)
    dist_keys = interface_distname.keys()
    return_scf_para_list = scf_para_list
    for index, param_dict in enumerate(scf_para_list):
        if param_dict['dist_name'] in dist_keys:
            if param_dict['dist_name'] == "LTE_x2":
                param_dict['p_name'] = interface_distname['LTE_x2_p_name']
            param_dict['dist_name'] = interface_distname[param_dict['dist_name']]
            return_scf_para_list[index] = param_dict
    return return_scf_para_list


def check_out_dist_name_for_interfaces(scf_local_path):
    """This keyword will find out the related dist_name of interfaces from scf.
    The interfaces are "f1Cplane", "f1Mplane", "f1Uplane", "x2Cplane",
    "s1Uplane" and "LTE_x2".
    The p_name of "LTE_x2" maybe changed, you can update list of lte_x2_p_names.
    """
    namespaces = {'ns': 'raml21.xsd'}
    listnames = ["f1Cplane", "f1Mplane", "f1Uplane",
                 "x2Cplane", "s1Uplane", "x2Uplane"]
    return_dict = {}
    scfinfo = tree.parse(scf_local_path)
    for listname in listnames:
        distnames = scfinfo.xpath("//ns:list[@name='{l_n}']/../@distName"
                                  .format(l_n=listname), namespaces=namespaces)
        for distname in distnames:
            p_name = scfinfo.xpath(
                "//ns:managedObject[@distName='{d_n}']//ns:list[@name='{l_n}']//ns:p" .format(
                    d_n=distname, l_n=listname), namespaces=namespaces)
            last_name = distname.split("/")[-1]
            if last_name.find("DU") != -1:
                if listname == "f1Cplane":
                    return_dict['DU_f1Cplane'] = p_name[0].text
                elif listname == "f1Mplane":
                    return_dict['DU_f1Mplane'] = p_name[0].text
                elif listname == "f1Uplane":
                    return_dict['DU_f1Uplane'] = p_name[0].text
                else:
                    raise Exception("Invalid listname!", listname)
            else:
                if listname == "f1Cplane":
                    return_dict['CU_f1Cplane'] = p_name[0].text
                elif listname == "f1Mplane":
                    return_dict['CU_f1Mplane'] = p_name[0].text
                elif listname == "f1Uplane":
                    return_dict['CU_f1Uplane'] = p_name[0].text
                elif listname == "x2Cplane":
                    return_dict['CU_x2Cplane'] = p_name[0].text
                elif listname == "s1Uplane":
                    return_dict['CU_s1Uplane'] = p_name[0].text
                elif listname == "x2Uplane":
                    return_dict['CU_x2Uplane'] = p_name[0].text
                else:
                    raise Exception("Invalid listname!", listname)

    lte_x2_p_names = ["amfIPAddress", "ipAddrPrim"]
    return_dict['LTE_x2'] = None
    ok = False
    try_times = 0
    while try_times < 1 and not ok:
        for lte_x2_p_name in lte_x2_p_names:
            if not ok:
                lte_distname = scfinfo.xpath(
                    "//ns:p[@name='{p_name}']/../@distName".format(
                        p_name=lte_x2_p_name), namespaces=namespaces)
                try:
                    return_dict['LTE_x2'] = lte_distname[0]
                except Exception as e:
                    msg = "Fail to get the distname of p_name: '{}'"
                    logging.debug(msg.format(lte_x2_p_name))
                else:
                    return_dict['LTE_x2_p_name'] = lte_x2_p_name
                    ok = return_dict['LTE_x2'] is not None
                finally:
                    try_times += 1
            else:
                break
    else:
        if not ok:
            msg = "Get the LTEx2 distname fail"
            raise LookupError(msg)
    return return_dict


def check_out_test_states_distname(scf_local_path):
    namespaces = {'ns': 'raml21.xsd'}
    scfinfo = tree.parse(scf_local_path)
    profile_name = "rapProfile"
    test_states_distname = scfinfo.xpath("//ns:p[@name='{p_name}']/../@distName"
                                         .format(p_name=profile_name), namespaces=namespaces)
    return test_states_distname[0]


def get_dist_name_NRCELL_elements(scf_local_path):
    ''' Find out all below elements and return:
        <managedObject distName="MRBTS-1900/NRBTS-1/NRCELL-1" ...>
    '''
    scf_manipulator.load_scf(scf_local_path)
    nrCell_elements = []
    nrCell_elements.append(scf_manipulator.scf_operations._get_all_elements(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1")[0].getparent())
    nrCell_elements.append(scf_manipulator.scf_operations._get_all_elements(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-2")[0].getparent())
    nrCell_elements.append(scf_manipulator.scf_operations._get_all_elements(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-3")[0].getparent())
    nrCell_elements.append(scf_manipulator.scf_operations._get_all_elements(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-4")[0].getparent())
    return nrCell_elements


def get_nrCell_elements(scf_local_path):
    ''' Find out below
        <list name="nrCellList">
                <p>1</p>
                <p>2</p>
                <p>3</p>
                <p>4</p>
        </list>
        ==> <p>0</p> '''
    scf_manipulator.load_scf(scf_local_path)
    logging.info('---load ok--')
    logging.info(scf_manipulator.__dict__.items())
    nrCell_elements = scf_manipulator.scf_operations._get_all_elements(
        dist_name="MRBTS-1900/NRBTS-1/NRCELLGRP-0", list_name="nrCellList")
    return nrCell_elements


def remove_children_elements(
        scf_local_path,
        elements,
        range=[],
        distName=None):
    ''' This is a common function, maybe merged into taf.config.scf.scf_operations.py in future.
        This function will remove XML elements which belongs to elements[] and its text/distName
        belongs to the given range.
        Eg: elements=[el1, el2, el3, el4], if to remove el2, el3 and el4, range=['2', '3', '4']
            if range is not specified, all children in elements[] will be removed.
            For distName like 'MRBTS-1900/NRBTS-1/NRCELL-1', the last number 1 will be
            taken into consideration and compared to range[].
    '''
    parent_node = elements[0].getparent()

    for child in parent_node.getchildren():
        if distName and child.get("distName"):
            matchObj = re.match(distName, child.get("distName"))
            matchNum = re.findall(r'\d', child.get("distName"))
            if matchObj and matchNum and (
                    child in elements) and (matchNum[-1] in range):
                parent_node.remove(child)
        elif range:
            if (child in elements) and (child.text in range):
                parent_node.remove(child)
        else:
            parent_node.remove(child)

    scf_manipulator.save_scf(scf_local_path)


def scf_elements_remove(flag):
    if 'SBTS5G18A_5g_pid12' in flag:
        remove_els = [
            dict(
                dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
            dict(
                dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
            dict(
                dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0',
                list_name='nrCellList',
                index=1)]
    else:
        remove_els = [
            dict(
                dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
            dict(
                dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
            dict(
                dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),
            dict(
                dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
            dict(
                dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
            dict(
                dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1'),
            dict(
                dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0',
                list_name='nrCellList',
                index=1),
            dict(
                dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0',
                list_name='nrCellList',
                index=1),
            dict(
                dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0',
                list_name='nrCellList',
                index=1)]
    return remove_els


def upgrade_du_via_yaft(
        connection,
        version,
        du_lmp_ip,
        username='toor4nsn',
        password='oZPS0POrRieRtu',
        extra_para='',
        attempt_times=5,
        yaft_path=None,
        file_path=None
):
    """
    This keyword will upgrade DU via yaft.

    | Parameters      | Man. | Description
    | connection      |Yes |the ssh connection to the server which will execute yaft|
    | version    | Yes  | the expect version |
    | du_lmp_ip      | Yes  | the du lmp ip |
    | username       | No   | the username for login the du lmp |
    | password     | No   | the password for login the du lmp |
    |extra_para    |No    | other para for the yaft command, such as "--ignore_slaves" |

    author = Shen Jianfen
    """
    attempt_times = int(attempt_times)
    if yaft_path is None:
        yaft_path = "/opt/backups/Downloads/yaft"
    if file_path is None:
        file_path = "/opt/backups/Downloads/{}".format(version)
    command = "python {yaft_p}/yaft.py -i {du_ip} {para} -z {file_p}/AirScaleASIK-{v}.zip"\
        .format(yaft_p=yaft_path, du_ip=du_lmp_ip, para=extra_para, file_p=file_path, v=version)
    result = csn.execute(command, connection=connection)
    for times in range(attempt_times):
        if 'Flashing done' not in result:
            result_ping = ping_opposite_terminal(du_lmp_ip, connection)
            if 'bytes from' not in result_ping:
                raise Exception("ping du failed!")
            else:
                logging.info("The attempt times {} of yaft".format(times))
                result = csn.execute(command, connection=connection)
    if 'Flashing done' not in result:
        raise Exception("yaft failed!")
    return result


def ping_opposite_terminal(ip, connection, times=60, interval='5'):
    """
    This keyword will ping Opposite terminal for some times.
    author = Shen Jianfen
    | ip      | Yes  | the Opposite terminal ip |
    | connection       | Yes   | the ssh connection to the server which will execute ping command |
    | times     | No   | the attempt times to ping|
    | interval  | No   | the  interval to ping |
    """
    command = "ping {} -c 1 -i {}".format(ip, interval)
    result = csn.execute(command, connection=connection)
    for i in range(times):
        if 'bytes from' not in result:
            result = csn.execute(command, connection=connection)
    return result


def uncompress_logfile_when_needed(filepath, connection):
    """ This function will check whether the given file exists or not, if it exists, return file;
        otherwise, uncompress file.xz or file.gz or file.zip and return the compressed file.
        author = Jia Wei
    """
    path_exist = int(csn.execute(
        "ls {}>/dev/null 2>&1; echo $?".format(filepath), connection=connection))
    path_xz_exist = int(csn.execute(
        "ls {}>/dev/null 2>&1; echo $?".format(filepath + "*.xz"), connection=connection))
    path_gz_exist = int(csn.execute(
        "ls {}>/dev/null 2>&1; echo $?".format(filepath + "*.gz"), connection=connection))
    path_zip_exist = int(csn.execute(
        "ls {}>/dev/null 2>&1; echo $?".format(filepath + "*.zip"), connection=connection))
    if path_exist and not path_xz_exist:
        logging.debug("Command: xz -d {}*.xz".format(filepath))
        csn.execute("xz -d {}*.xz".format(filepath), connection=connection)
    if path_exist and not path_gz_exist:
        logging.debug("Command: gzip -d {}*.gz".format(filepath))
        csn.execute("gzip -d {}*.gz".format(filepath), connection=connection)
    if path_exist and not path_zip_exist:
        logging.debug("Command: unzip {}*.zip".format(filepath))
        csn.execute("unzip {}*.zip".format(filepath), connection=connection)
    return filepath
    # filelist = csn.execute("ls {}".format(filepath + "*"), connection=connection)
    # return filelist


def map_version_to_stream_name(version):
    stream_dict = {
        # cloud
        '0.1351': '0.1351_master_cloudbts_l1r51_tdd',
        '6.1351': '6.1351_19A_cloudbts_l1r51_tdd',
        '1351': '0.1351_master_cloudbts_l1r51_tdd',
        '7135': 'b7_cloudbts_l1r5_tdd',
        # classical
        '0.18351': '0.18351_master_coam_classicalbts_l1r51_tdd',
        '6.8351': '6.8351_19A_classicalbts_l1r51_tdd',
        '8351': '0.8351_master_classicalbts_l1r51_tdd',
        '7835': 'b7_classicalbts_l1r5_tdd',
        '6835': 'b6_classicalbts_l1r5_tdd',
    }
    sub_version = version.split('.')[0] + "." + version.split('.')[1]
    logging.debug(sub_version)
    if sub_version in stream_dict.keys():
        return stream_dict[sub_version]
    else:
        raise Exception('package version is wrong')


def get_containers_on_asik(connection):
    """ This keyword is used to get the current containers on ASIK's master or slave XEON
    Return the container list"""
    command = 'lxc-ls --active'
    output = csn.execute(command, connection=connection)
    containers = output.split()
    return containers


def get_pstree_info_on_asik(connection, service, line_number='0'):
    """ This keyword is used to get the specific service info on ASIK's master or slave XEON
    Return the container list"""
    command = 'pstree'
    if int(line_number) != 0:
        command = '%s%s%s%s%s' % (
            command, ' | grep -', line_number, ' ', service)
    else:
        command = '%s%s%s' % (command, ' | grep ', service)
    output = csn.execute(command, connection=connection)
    return output


def check_board_status_on_asik(connection):
    """ This keyword is used to get the board status, including ASIK and ABIK/ABIL from ASIK
    Return the board status"""
    command = 'export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -p 15004'
    output = csn.send_command(command, connection=connection, timeout=300)
    output = csn.read_output(connection=connection)
    re_command = r'0x\d+\s+FSM1_FCT\s+(\w+)\[\d\]'
    fct_result = re.findall(re_command, output)
    re_command = r'0x\d+\s+FSM1_FSP1\s+(\w+)\[\d\]'
    fsp_result = re.findall(re_command, output)
    return ''.join(fct_result), ''.join(fsp_result)


def get_active_disk(connection):
    """ This keyword is used to get the current active disk on ASIK
    Return the active disk"""
    command = "ls -lrt /ffs | grep run | awk '{print $11}'"
    output = csn.execute(command, connection=connection)
    return output


def disconnect_all_connections():
    for k in list(csn.store._store.keys()):
        try:
            csn.disconnect(str(k))
        except Exception as e:
            msg = "Exception while disconnection: {}"
            logging.debug(msg.format(str(k)))


def get_asik_abil_status(connection, CCS_Daemon_node_id='0x1011', *args):
    csn.force_reconnect(connection=connection)
    csn.send_command(
        "export PYTHONPATH=/opt/hwmt/python;"
        " python3 /opt/hwmt/python/hwapi/AdetS.py -s -p 15004 -n {}".format(CCS_Daemon_node_id),
        connection=connection, timeout=300)
    output = csn.read_output(connection=connection)
    print(output)

    airscaleStatus = {}
    if len(output) < 10:
        for nID in args:
            airscaleStatus[nID] = "NOT EXIST"
    else:
        output = re.sub('.*Storing.*\n', '', output)
        for nID in args:
            status = "NOT EXIST"
            try:
                status = re.search(r'{}\s*\S*\s*\S*'.format(nID),
                                   output).group(0).split()[2][:-3]
            except KeyError:
                logging.warn("status for {} is NOT exist!".format(nID))
                status = "NOT EXIST"
            finally:
                airscaleStatus[nID] = status
    return airscaleStatus


def reset_abil_if_abil_status_not_ready(
        connection,
        board_id='0x12',
        CCS_Daemon_node_id='0x1011'):
    s = get_asik_abil_status(connection, CCS_Daemon_node_id, board_id)
    logging.info("abil status = {}".format(s[board_id]), also_console=True)

    while s[board_id] == "swupgrade":
        time.sleep(30)
        s = get_asik_abil_status(connection, CCS_Daemon_node_id, board_id)
        logging.info("abil status = {}".format(s[board_id]), also_console=True)

    if s[board_id] == "ready":
        return
    else:
        logging.info("start to reset abil", also_console=True)
        reset_abil(connection)


def reset_abil(connection):
    csn.send_command("ddal -s ddal_power_set DDAL_POWER_FSP1 DDAL_POWER_OFF",
                     connection=connection)
    print(csn.read_output(connection=connection))
    time.sleep(10)
    csn.send_command("ddal -s ddal_power_set DDAL_POWER_FSP1 DDAL_POWER_ON",
                     connection=connection)
    time.sleep(10)
    print(csn.read_output(connection=connection))


def check_file(
        filename=r'/root/VirtualNodeConfig.xml',
        con_flag='ALARMNODE',
        con_check='BoardConfigId="1"',
        num=4):
    f_read = open(filename, 'r')
    flag = False
    while True:
        if con_flag in f_read.readline():
            for i in range(num):
                if con_check in f_read.readline():
                    flag = True
            break
    f_read.close()
    return flag


def update_variables_for_log_collector(log_collector):
    """ This function will read ASIK, LTEemu and Airphone IP, username, password info
        from TL __init__.py and update them into all_log_collector_run_on_EECLOUD.sh
    """
    ASIK_IP = run_keyword_with_variables(
        'get variable value', "${tl.gnbs[0].cu.oam_ssh_connection_details.addr}")
    ASIK_user = run_keyword_with_variables(
        'get variable value', "${tl.gnbs[0].cu.oam_ssh_connection_details.username}")
    ASIK_password = run_keyword_with_variables(
        'get variable value', "${tl.gnbs[0].cu.oam_ssh_connection_details.password}")
    LTEemu_IP = run_keyword_with_variables(
        'get variable value', "${tl.core.default_ssh_connection_details.addr}")
    LTEemu_user = run_keyword_with_variables(
        'get variable value', "${tl.core.default_ssh_connection_details.username}")
    LTEemu_password = run_keyword_with_variables(
        'get variable value', "${tl.core.default_ssh_connection_details.password}")
    LTEemu_path = run_keyword_with_variables(
        'get variable value', "${tl.core.dir_path}")
    AP_IP = run_keyword_with_variables(
        'get variable value', "${tl.ues[0].l2_ssh_connection_details.addr}")
    AP_user = run_keyword_with_variables(
        'get variable value', "${tl.ues[0].l2_ssh_connection_details.username}")
    AP_pwd = run_keyword_with_variables(
        'get variable value', "${tl.ues[0].l2_ssh_connection_details.password}")
    # os.system("echo {} > /tmp/LTEemu_path".format(LTEemu_path))
    # LTEemu_path = commands.getoutput("sed -e 's/\//\\\\\//g' /tmp/LTEemu_path")
    LTEemu_path = LTEemu_path.replace("/", "\\/")
    os.system(
        "sed -i 's/ASIK_IP=.*$/ASIK_IP={}/g' {}".format(ASIK_IP, log_collector))
    os.system(
        "sed -i 's/ASIK_user=.*$/ASIK_user={}/g' {}".format(ASIK_user, log_collector))
    os.system(
        "sed -i 's/ASIK_password=.*$/ASIK_password={}/g' {}".format(ASIK_password, log_collector))
    os.system(
        "sed -i 's/LTEemu_IP=.*$/LTEemu_IP={}/g' {}".format(LTEemu_IP, log_collector))
    os.system(
        "sed -i 's/LTEemu_user=.*$/LTEemu_user={}/g' {}".format(LTEemu_user, log_collector))
    os.system(
        "sed -i 's/LTEemu_password=.*$/LTEemu_password={}/g' {}".format(LTEemu_password, log_collector))
    os.system(
        "sed -i 's/LTEemu_path=.*$/LTEemu_path={}/g' {}".format(LTEemu_path, log_collector))
    os.system(
        "sed -i 's/Airphone_BB2_IP=.*$/Airphone_BB2_IP={}/g' {}".format(AP_IP, log_collector))
    os.system(
        "sed -i 's/Airphone_BB2_user=.*$/Airphone_BB2_user={}/g' {}".format(AP_user, log_collector))
    os.system(
        "sed -i 's/Airphone_BB2_password=.*$/Airphone_BB2_password={}/g' {}".format(AP_pwd, log_collector))


def get_CCS_Daemon_node_id(connection):
    """ This function will query out the CCS Daemon node on ASIK, then this nodeid can be used in AdetS.py
        such as: export PYTHONPATH=/opt/hwmt/python;
        python3 /opt/hwmt/python/hwapi/AdetS.py -s -p 15004 -n <CCS_Daemon_node>
    """
    command = "sh /usr/bin/ownnid"
    result = csn.execute(command, connection=connection)
    CCS_Daemon_node_id = result.split('\r\n')[0]
    return CCS_Daemon_node_id


def get_board_id(connection, board_type):
    """This keyword is to query the  board id via AdetS.py
       board_type: FCT | FSM
       FCT --> ASIK,  FSM --> ABIL
    """
    CCS_Daemon_node_id = get_CCS_Daemon_node_id(connection=connection)
    command = "export PYTHONPATH=/opt/hwmt/python; "
    command = command + "python3 /opt/hwmt/python/hwapi/AdetS.py -s -p 15004 -n {} | grep {}".format(
        CCS_Daemon_node_id, board_type.upper())
    result = csn.send_command(command, connection=connection, timeout=300)
    result = csn.read_output(connection=connection)
    board_id = re.search(r'0x\d{2}', result).group(0)
    return board_id


def remount_for_yaft(connection):
    """ This function will umount and mount bcerts to get yaft running again
    """
    try:
        result = csn.execute("touch /tmp/test", connection=connection)
        result = csn.execute("crasign /tmp/test", connection=connection)
        if 'could not read certificate, /etc/keys.d/certs/sigcert.pem' in result:
            # give additional information for debugging purposes
            result = csn.execute("dmesg | tail -n 20", connection=connection)
            result = csn.execute("systemctl status -l etc-keys.d-bcerts.mount > /tmp/out.txt", connection=connection)
            result = csn.execute("cat /tmp/out.txt", connection=connection)
            result = csn.execute("systemctl status -l certs-update.service > /tmp/out.txt", connection=connection)
            result = csn.execute("cat /tmp/out.txt", connection=connection)
            result = csn.execute("ls /etc/keys.d/bcerts", connection=connection)
            result = csn.execute("od -c /etc/keys.d/bcerts/sigcert.pem | head -n 10", connection=connection)
            result = csn.execute("mount", connection=connection)
            result = csn.execute("cat /proc/mtd", connection=connection)
            result = csn.execute("fsck.cramfs /dev/mtdblock2", connection=connection)
            result = csn.execute("fsck.cramfs /dev/mtdblock3", connection=connection)

            # check that this command is enough to repair
            result = csn.execute("mount -o remount /etc/keys.d/bcerts", connection=connection)
            result = csn.execute("touch /tmp/test", connection=connection)
            result = csn.execute("crasign /tmp/test", connection=connection)

            if 'could not read certificate, /etc/keys.d/certs/sigcert.pem' in result:
                result = csn.execute("mount | grep keys.d | grep bcerts", connection=connection)
                device = result.split(' ')[0]
                result = csn.execute("umount " + device, connection=connection)
                result = csn.execute("mount " + device + " /etc/keys.d/bcerts -o ro,relatime", connection=connection)
                result = "umount + mount executed"
            else:
                result = "remount executed"
        else:
            result = "no remount executed"
    except Exception as e:
        print(e)
        result = "no remount executed"
    return result


def get_profile_from_scf_file(scf_local_path):
    dist_name = check_out_test_states_distname(scf_local_path)
    scf_manipulator.load_scf(scf_local_path)
    rapProfile = scf_manipulator.get_value_from_scf(dist_name=dist_name, p_name='rapProfile')
    return rapProfile


def get_nidd_from_scf(scf_local_path, dist_name):
    scfInfo = tree.parse(scf_local_path)
    niddVersion = scfInfo.xpath(".//*[@distName='%s']/@version" % dist_name)[0]
    return niddVersion


def has_a_tty():
    """ Check if has connected tty device for yaft"""
    return sys.stdin.isatty()
