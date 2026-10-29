"""
Keywords for parsing NetAct outputs related to CM operations history.

:copyright: Nokia Networks
:author: Lukasz Rzodeczko
:contact: lukasz.rzodeczko@nokia.com
:maintainer: Grzegorz Kaczor
:contact: grzegorz.kaczor@nokia.com

"""
import re
from functools import wraps
from datetime import datetime
from taf.nms.netact.interface import netact
from taf.rfrl.utilities.robot.general import get_builtin_value


def connect_disconnect_netact(netact_function):
    @wraps(netact_function)
    def wrapper(self, *args, **kwargs):
        self.netact.add_node('cmwas', self.cmwas_node_ip, self.cmwas_username,
                             self.cmwas_passwd)
        netact_url = "https://{}/authentication/Login".format(self.netact.detect_web_url())
        self.netact.add_web_url(netact_url, self.cmwas_username, self.cmwas_passwd)
        try:
            result = netact_function(self, *args, **kwargs)
            return result
        finally:
            self.netact.delete_node('cmwas')
            self.netact.clean_all()
    return wrapper


class NetactOperations(object):
    def __init__(self):
        self.netact = netact()
        tl = get_builtin_value(param_name="tl")
        self.cmwas_node_ip = tl.nms[0].nom.ssh_connections_info.addr
        self.cmwas_passwd = tl.nms[0].nom.ssh_connections_info.password
        self.cmwas_username = tl.nms[0].nom.ssh_connections_info.username

    @connect_disconnect_netact
    def get_detailed_operations_history_parser(self, plan_names, mo_id, operations_count=1):
        """
        This function gets given number NetAct CM operations, filter them by given plan name/names
        and convert the output from string/list of strings to dictionary
        :param plan_names: name of plan/plans which will be parsed by this function
        :type plan_names: str or list
        :param mo_id: NetAct managed object id eg. PLMN-PLMN/MRBTS-{CU_ID}
        :type mo_id: str
        :param operations_count: parameter defines the number of CM operations which should be returned by NetAct
        :type operations_count: int
        :return: plan_name_dict: dictionary with parsed NetAct's output for given plan/plans
        :type plan_name_dict: dict
        """
        netact_output = self.netact.get_detailed_operations_history(operations_count=operations_count)
        netact_output_parsed = self.__parse_netact_output(netact_output, plan_names, mo_id)
        return netact_output_parsed

    def get_random_cell_id(self, mrbts, bts_id=0, du_id=0):
        from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations as GnbCell
        cell_interface = GnbCell()
        random_cell = cell_interface.get_random_cell_dist_name(bts_id=bts_id, du_id=du_id)
        random_cell = random_cell.format(int(mrbts), int(mrbts))
        return random_cell

    def __is_date(self, date_text):
        """
        Return whether the string can be interpreted as a date.

        :param date_text: string to check for date
        :type date_text: str
        :return: True or False
        """
        try:
            date_text = re.sub(': .*', '', date_text)
            datetime.strptime(date_text, "%m/%d/%y %I:%M:%S %p")
            return True
        except ValueError:
            return False

    def __parse_netact_status(self, feedback, mo_id):
        """
        Converts NetAct's output 'Feedback' section, related to CM operations, from list of new lines to dictionary
        to get  netact statuses
        :param feedback: NetAct's output related to "Feedback" section,
         where each element of list is one line of "Feedback" section
        :type feedback: list
        :param mo_id: NetAct managed object id eg. PLMN-PLMN/MRBTS-{CU_ID}
        :type mo_id: str
        :return: dictionary of NetAct's statuses
        """
        netact_status = [x for x in feedback if mo_id not in x]
        netact_status = [re.sub('\n.*\n', '\n', x) for x in netact_status]
        netact_status = [re.sub('M: .*', 'M', x) for x in netact_status]
        return dict(x.split('\n') for x in netact_status)

    def __parse_gnb_status_details(self, gnb_status):
        """
        Converts NetAct's output related to gnb part of "Feedback" section, from list of new lines to dictionary
        to get gnb detail statuses.
        :param gnb_status: NetAct's output related to gnb part of "Feedback" section
        where each element of list is one line of "Feedback" section
        :type gnb_status: list
        :return gnb_status_details_dict: dictionary of gNB's detail statuses
        :type gnb_status_details_dict: dict
        """
        gnb_status_details = [x for x in gnb_status if x.count('\n') > 4]
        status_message = [re.search('(?<=MESSAGE)(.*\n)*(?=STATUS)', x, re.DOTALL).group(0).replace('\n', ' ')
                          for x in gnb_status_details]
        gnb_status_details = [re.sub('MESSAGE(.*\n)*STATUS', 'MESSAGE' + y + '\nSTATUS', x) for (x, y) in
                              zip(gnb_status_details, status_message)]
        gnb_status_details_dict = {
            x.split(' ', 1)[0]: {y for y in list(filter(None, x.splitlines()))[1::]}
            for x in gnb_status_details}
        for elm in gnb_status_details_dict:
            for elm2 in gnb_status_details_dict[elm]:
                gnb_status_details_dict[elm].remove(elm2)
                elm3 = elm2.strip()
                if self.__is_date(elm3):
                    gnb_status_details_dict[elm].add("DATE  : " + re.sub(': .*', '', elm3))
                else:
                    elm3 = re.sub(r"\s{2,}", '  ', elm3)
                    gnb_status_details_dict[elm].add(elm3)
            gnb_status_details_dict[elm] = dict(x.split('  : ') for x in gnb_status_details_dict[elm])
        return gnb_status_details_dict

    def __parse_gnb_status(self, feedback, mo_id):
        """
        Converts NetAct's output 'Feedback' section, related to CM operations, from list of new lines to dictionary
        to get gnb statuses.
        :param feedback: NetAct's output related to "Feedback" section,
        where each element of list is one line of "Feedback" section
        :type feedback: list
        :param mo_id: NetAct managed object id eg. PLMN-PLMN/MRBTS-{CU_ID}
        :type mo_id: str
        :return mo_id_dict: dictionary of gNB's statuses
        :type mo_id_dict: dict
        """
        gnb_status = [re.search(mo_id + '\n(.*)', x, re.DOTALL).group(1)
                      for x in feedback if mo_id in x and not mo_id + '/' in x]
        gnb_status_5G = [re.sub('M: .*', 'M', x) for x in gnb_status if x.count('\n') < 4]
        gnb_status_dict_5G = dict(x.split('\n') for x in gnb_status_5G)
        gnb_status_details_dict = self.__parse_gnb_status_details(gnb_status)
        mo_id_dict = {"Operations": gnb_status_dict_5G,
                      "Operations details": gnb_status_details_dict}
        return mo_id_dict

    def __parse_operations(self, netact_output, mo_id):
        """
        Converts NetAct's outputs related to CM operations of given plan, from string or list of strings to dictionary.
        :param netact_output: NetAct's output related to CM operations of given plan
        :type netact_output: list
        :param mo_id: NetAct managed object id eg. PLMN-PLMN/MRBTS-{DU_ID}
        :type mo_id: str
        :return operation_dict: dictionary with parsed NetAct's output for given plan
        :type operation_dict: dict
        """
        operation_dict = dict()
        for operation in netact_output:
            operation = re.sub('\t', '', operation)
            netact_output_dict = {
                'Operation Group information': re.search('\n(.+?)Feedback Summary', operation,
                                                         re.DOTALL).group(1).split("\n"),
                'Feedback Summary': re.search('Feedback Summary\n(.+?)Feedbacks', operation,
                                              re.DOTALL).group(1).split("\n"),
                'Feedbacks': re.search('Feedbacks\n(.*)', operation, re.DOTALL).group(1).split("\n\n")}

            netact_output_dict['Operation Group information'] = dict(x.split(': ')
                                                                     for x in netact_output_dict[
                                                                         'Operation Group information'] if x)

            netact_output_dict['Feedback Summary'] = dict(
                x.split(': ') for x in netact_output_dict['Feedback Summary'] if x)
            netact_status_dict = self.__parse_netact_status(netact_output_dict['Feedbacks'], mo_id)
            mo_id_dict = self.__parse_gnb_status(netact_output_dict['Feedbacks'], mo_id)

            netact_output_dict['Feedbacks'] = {"Netact Status": netact_status_dict,
                                               mo_id: mo_id_dict}
            operation_dict[netact_output_dict['Operation Group information']['Type']] = netact_output_dict
        return operation_dict

    def __parse_netact_output(self, netact_output, plan_names, mo_id):
        """
        Converts NetAct's outputs related to CM operations of given plan/plans,
        from string or list of strings to dictionary.
        :param netact_output: NetAct's outputs/output related to CM operations
        :type netact_output: str or list
        :param plan_names: name of plan/plans which will be parsed by this function
        :type plan_names: str or list
        :param mo_id: NetAct managed object id eg. PLMN-PLMN/MRBTS-{CU_ID}
        :type mo_id: str
        :return plan_name_dict: dictionary with parsed NetAct's output for given plan/plans
        :type plan_name_dict: dict
        """
        if type(plan_names) is str or isinstance(plan_names, type(u"Python2 workaround")):
            plan_names = [plan_names]
        elif type(plan_names) is not list:
            raise ValueError('plan_names variable should be string or list of strings not ' + str(type(plan_names)))
        plan_name_dict = dict()
        for plan_name in plan_names:
            netact_output = [x for x in netact_output if plan_name + '\n' in x]
            if not netact_output:
                raise ValueError('No plan name ' + plan_name + ' in the given output')
            plan_name_dict[plan_name] = self.__parse_operations(netact_output, mo_id)
        return plan_name_dict
