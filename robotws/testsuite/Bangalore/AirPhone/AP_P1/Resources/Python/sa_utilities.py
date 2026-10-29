import time
import re


class sa_utilities(object):
    def __init__(self):
        self.NG_link_up = False
        self.SIB_update = False

    def check_if_NG_link_is_up(self):
        pattern_ng = "NG link is Up"
        try:
            amf_log_file = open("/opt/wts/latest/amf_1.log", "r")
            for line in amf_log_file:
                if re.search(pattern_ng, line):
                    print(line)
                    self.NG_link_up = True
            amf_log_file.close()
        except IOError:
            pass

    def check_if_SIB_update_recieved(self):
        pattern = "SystemInformationBlockType1-NR"
        try:
            uec_log_file = open("/opt/wts/latest/uec_1.log", "r")
            for line in uec_log_file:
                if re.search(pattern, line):
                    print(line)
                    self.SIB_update = True
            uec_log_file.close()
        except IOError:
            pass

    def wait_until_NGLink_SIB_is_recieved(self):
        timeout = time.time() + 60*7         # 7 minutes timeout
        while (not self.NG_link_up or not self.SIB_update):
            if not self.NG_link_up:
                self.check_if_NG_link_is_up()
            if not self.SIB_update:
                self.check_if_SIB_update_recieved()
            time.sleep(10)
            if (time.time() > timeout and (not self.NG_link_up or not self.SIB_update)):
                if not self.NG_link_up and not self.SIB_update:
                    raise Exception("NG link didnt come up and SIB update was not recieved")
                elif not self.SIB_update:
                    raise Exception("SIB update was not recieved")
                elif not self.NG_link_up:
                    raise Exception("NG link didnt come up")
