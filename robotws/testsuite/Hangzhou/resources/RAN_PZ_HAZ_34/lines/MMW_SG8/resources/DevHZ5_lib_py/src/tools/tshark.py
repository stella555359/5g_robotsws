from .check_cap import CapPacket
from ..common_lib import common_lib
from robot.libraries.BuiltIn import BuiltIn
import re
import logging

comm_obj = common_lib()
builtin_obj = BuiltIn()


class check_by_tshark(object):
    def __init__(self):
        self.cap = CapPacket()

    def wireshark_check_by_tshark(self, pcap, *expression):
        """
        :param pcap:
        :param expression: list of wireshark msg expression, if end with @<num>, then it will check that such msg
        should be found the equalivent number
        :return:
        """
        msg_check_failed_list = []
        for exp in expression:
            print(exp)
            builtin_obj.log('start to check {} by filter {}'.format(pcap, exp))
            num = exp.split('@')[-1] if '@' in exp else ''
            exp2 = exp.split('@')[0]
            cmd = 'tshark -r {} -Y "{}"'.format(pcap, exp2)
            output = comm_obj.execute_cmd_on_pc(cmd)
            builtin_obj.log(output)
            if not output.strip():
                if num != '0':
                    ''' workaround for xnap filter problem which should be
                    # removed after wireshark update
                    #if 'xnap.' in cmd:
                    #    print(
                    #        "use the workaround to replace xnap to xnap_17_3_0_2212_p120-n05")
                    #    cmd = cmd.replace('xnap.', 'xnap_17_3_0_2212_p120-n05.')
                    #    result, output = self.linux.execute_local_cmd(cmd)
                    #    logging.info(output)
                    #    if not result or not output.strip():
                    #        msg_check_failed_list.append(exp)
                    #else:
                    #    msg_check_failed_list.append(exp)'''
                    msg_check_failed_list.append(exp)
            if output.strip() and num:
                messge_list = output.split('\n')
                mesg_max = len(messge_list) - 1
                new_mesg_list = []
                for index in range(mesg_max):
                    if (messge_list[index] != '' and
                            'been cut short in the middle' not in messge_list[index] and
                            messge_list[index] != '\r'):
                        new_mesg_list.append(messge_list[index])
                finded_num = len(new_mesg_list)
                builtin_obj.log(
                      'find mesg list {} length is {}'.format(
                            new_mesg_list, len(new_mesg_list)))
                if finded_num != int(num):
                    msg_check_failed_list.append(exp)
                    builtin_obj.log(
                        'find {} msgs while expected {} msgs'.format(
                            finded_num, num))
        if msg_check_failed_list:
            builtin_obj.log(
                'These msg {} check failed'.format(msg_check_failed_list))
            raise Exception


if __name__ == "__main__":
    tshark = check_by_tshark()
    help(check_by_tshark)
