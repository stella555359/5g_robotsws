import json
import re
from datetime import datetime
import time
import taf.transport.ssh

HOST = "192.168.255.1"
USR = "toor4nsn"
PASS = "oZPS0POrRieRtu"
PORT = "15007"
UE_PROCESSES = ["RROMexe", "cp_nb", "cp-nrt", "Cprt"]


class Hanging(object):
    def __init__(self, logfile, debug_log):
        self.output_file = logfile
        self.debug_file = debug_log
        self.hanging = False
        self.ue_processes = UE_PROCESSES
        self.checked_processes = {}

    def __enter__(self):
        self.conn = taf.transport.ssh.connect(HOST, USR, PASS)
        if self.conn:
            print("connection succesful")
        else:
            print("connection not successful")
        self.log = open(self.output_file, "a+")
        self.debug = open(self.debug_file, "w")
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.conn.disconnect()
        self.log.close()
        self.debug.close()

    def __dict_generator(self, indict, pre=None):
        pre = pre[:] if pre else []
        if isinstance(indict, dict):
            for key, value in indict.items():
                if isinstance(value, dict):
                    for d in self.__dict_generator(value, [key] + pre):
                        yield d
                elif isinstance(value, (list, tuple)):
                    for v in value:
                        for d in self.__dict_generator(v, [key] + pre):
                            yield d
                else:
                    yield pre + [key, value]
        else:
            yield indict

    def find_process(self, p_name, input_data):
        r = re.compile(r".*node:\s?(\w*)\s?")
        results = []
        for line in input_data:
            a = r.search(line)
            if a:
                n = a.group(1)
            if p_name in line and n != "":
                results.append(n)
        return results

    def aashell(self, command):
        resp = self.conn.execute(("echo '" + command + "' | nc 127.0.0.1 " + PORT + "\n").encode(), timeout=60)
        self.debug.write("Command: {}".format(("echo '" + command + "' | nc 127.0.0.1 " + PORT + "\n").encode()))
        self.debug.write("Command response: {}".format(resp))
        out = self.conn.read_output()
        self.debug.write("self.conn.read_output(): {}".format(out))
        self.debug.write(resp)
        return resp

    def find_ue_processing(self):
        process_dict = {}
        resp = self.aashell("nodes -p")
        for a in self.ue_processes:
            try:
                b = self.find_process(a, resp.splitlines())
            except IndexError:
                b = []
            process_dict[a] = b
        return process_dict

    def check_hanging(self):
        check_ok = True
        for process, locations in self.find_ue_processing().items():
            self.checked_processes[process] = []
            for loc in locations:
                n = 0
                while n < 2:
                    if process == "RROMexe":
                        resp = self.aashell("getResourcesUsage -a -j @{} #{}".format(process, loc))
                    else:
                        resp = self.aashell("getResourcesUsage -l @{} #{}".format(process, loc))
                    n += 1
                    a, b = self.hanging_parse(resp)
                    if a:
                        self.checked_processes[process].append(loc)
                        check_ok = check_ok and a
                        if b:
                            self.hanging = True
                        break
                    else:
                        print("Hanging user check not successful, trying again after 10 seconds")
                        time.sleep(10)
        if check_ok:
            print("Checked processes: " + str(self.checked_processes))
            return self.hanging
        else:
            print("Hanging user check couldn't be performed")

    def hanging_parse(self, data):
        a = re.search(r'({"ResourcesUsage.*]})[.\t\r\n]*', data)
        nr_fields = ['admittedNsaUsers', 'admittedSaUsers', 'numOfUsers', 'numOfNonGbrBearers', 'countUsedSrbIndex',
                     'numberOfActiveUeSa', 'numberOfActiveUeNsa', 'allocatedNumOfBearers', 'allocatedNumOfPduSessions',
                     'currentRohcCtxNumber', 'allocatedDrbNumber', 'allocatedSrbNumber', 'currentUeNumber',
                     'allocatedShortPCsiNumber', 'allocatedLongPCsiNumber', 'allocatedShortSRNumber',
                     'allocatedLongSRNumber']
        hanging_users = False
        success = True
        if not a:
            a = re.search(r'AaShell>[\s\S]*?({[\s\S]*})', data)
        if a:
            j = json.loads(a.group(1))
            self.log.write(json.dumps(j, indent=4) + '\n')
            for a in self.__dict_generator(j):
                try:
                    if ("num" in a[-2] and not a[-2] in ['numCells', 'numS1Links', 'numX2Links']) or a[-2] in nr_fields:
                        if str(a[-1]) != u'0' or str(a[-1]) != "0":
                            text = "Possibly hanging users: {}".format(a)
                            self.log.write(text + '\n')
                            print(text)
                            hanging_users = True
                except TypeError:
                    pass
            if hanging_users:
                text = "Hanging users, check output from {}".format(self.output_file)
                self.log.write(text + '\n')
                print(text)
        elif "is not a valid command" in data:
            success = True
        else:
            print("Data couldn't be fetched for hanging user check")
            success = False
        return success, hanging_users


with Hanging('hanging_resource_check_' + datetime.now().strftime("%Y%m%d_%H%M%S") + '.log', 'hanging_debug.txt') as t:
    if t.check_hanging():
        print("There were hanging resources")
    else:
        print("No hanging resources")
