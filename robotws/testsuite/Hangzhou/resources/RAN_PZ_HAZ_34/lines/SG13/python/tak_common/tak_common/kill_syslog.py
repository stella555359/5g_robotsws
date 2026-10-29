# -*- coding: utf-8 -*-
"""
:created on: 10-02-2023
:copyright: Nokia
:author: Shao Yanyan
:contact: yanyan.shao@nokia-sbell.com
"""
import logging
import os
import re
import subprocess


class KillSyslog(object):
    def kill_ute_syslog_process(self):
        """
        kill ute syslog process and print crash field
        :param dir: directory of ute syslog
        """
        process_name = 'cli_syslog.py'
        child = subprocess.Popen(["pgrep", "-a", process_name], stdout=subprocess.PIPE, shell=False)
        response = str(child.communicate()[0], encoding='utf8')
        print("process info>>" + response)
        pid_pattern = r'(\b\d\S*) /home\b'
        pids = re.findall(pid_pattern, response)

        if pids:
            for pid in pids:
                result = os.system("kill -9 " + str(pid))
                if result == 0:
                    print('ute_syslog pid  {} kill success'.format(pid))
            dir_pattern = r'-d (.+) -l'
            dir = re.findall(dir_pattern, response)[0]
            self.get_field(dir)
        else:
            print("no target pid to kill")

    def get_field(self, dir):
        print("directory of syslog >>" + dir)
        files = os.listdir(dir)
        all_file = []
        for file in files:
            print("syslog >>" + file)
            if file.endswith("tar.gz"):
                continue
            if "_gnb_" in file or "_ap_" in file:
                file_path = os.path.join(dir, file)
                all_file.append(file_path)
        for file in all_file:
            with open(file) as fp:
                contents = fp.read()
                patterns = ["CCSRT ERR: (.+?)ity", "fatal error (.+?)ary"]
                for pattern in patterns:
                    result = re.search(pattern, contents)
                    if result:
                        logging.warning(file + ">>>" + result.group())


if __name__ == '__main__':
    pass
