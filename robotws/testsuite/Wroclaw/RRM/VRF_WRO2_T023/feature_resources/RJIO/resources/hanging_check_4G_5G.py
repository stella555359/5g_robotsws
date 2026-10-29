import json
import re
from datetime import datetime
import time
import taf.transport.ssh
import sys

HOST = "192.168.255.1" if len(sys.argv) == 1 else sys.argv[1]
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
        self.fct4a_conn = None
        if self.conn:
            print("fct-0a connection succesful")
        else:
            print("fct-0a connection not successful")
            self.conn = None
            return self
        output = self.conn.execute('cat /etc/hosts | grep fct-4a -o'.encode())
        if output:
            self.fct4a_conn = taf.transport.ssh.connect(
                hostname=output.strip(), username=USR, password=PASS, proxy=self.conn)
            if self.fct4a_conn:
                print("fct-4a connection succesful")
            else:
                print("fct-4a connection not successful")
                self.fct4a_conn = None
                return self
        output = self.conn.execute('cat /var/dt/module-identity/unit-id'.encode())  # output = 'ASIK\x00'
        self.smod = output[:4]
        print(f'Type of System Module: {self.smod}')
        self.log = open(self.output_file, "a+")
        self.debug = open(self.debug_file, "w")
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.fct4a_conn:
            self.fct4a_conn.disconnect()
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
        if 'nodes -p' in command or 'RROMexe' in command:
            resp = self.conn.execute(("echo '" + command + "' | nc 127.0.0.1 " + PORT + "\n").encode(),
                                     timeout=60)
        else:
            self.conn.execute(("echo '" + command + "' | nc 127.0.0.1 " + PORT + "\n").encode(),
                              timeout=60)
            loc = re.search(r'#(0x[1-2]\d{3})', command).group(1)
            fct_cmd = f'cat /tmp/node_{loc}/tmp/5gcp_GetResourceUsage/{loc}.txt'
            conn = self.fct4a_conn if loc.startswith('0x2') or loc.startswith('0x4') else self.conn
            if self.smod == 'ASIK':
                """
                https://confluence.ext.net.nokia.com/display/5GHAN/CNI-68640
                if the board type is ASIK, the three nodes ("cp_nb","cp-nrt","Cprt") are running on
                the ASIK slave board
                root@fct-0a:~ >cat /etc/hosts | grep -E fct.*0b|awk '{print $2}'
                fct-1-0b
                root@fct-0a:~ > ssh toor4nsn@fct-1-0b
                (toor4nsn@fct-1-0b) Password:
                root@fct-0b:/tmp/node_0x2512/tmp/5gcp_GetResourceUsage >ls
                """
                slave_host = conn.execute(
                    "cat /etc/hosts | grep -E fct-[0-9]-.*[0-9]b|awk '{print $2}'".encode()).strip()
                slave_conn = taf.transport.ssh.connect(hostname=slave_host, username=USR, password=PASS, proxy=conn)
                resp = slave_conn.execute(fct_cmd.encode())
                slave_conn.disconnect()
            else:
                resp = conn.execute(fct_cmd.encode())
        self.debug.write("Command: {}".format(("echo '" + command + "' | nc 127.0.0.1 " + PORT + "\n").encode()))
        self.debug.write("Command response: {}".format(resp))
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
                        # resp = self.aashell("getResourcesUsage -l @{} #{}".format(process, loc))
                        resp = self.aashell(f"getResourcesUsage -l -f {loc} @{process} #{loc}")
                    n += 1
                    a, b = self.hanging_parse(resp, process)
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

    def hanging_parse(self, data, process):
        nr_fields = ['admittedNsaUsers', 'admittedSaUsers', 'numOfUsers', 'numOfNonGbrBearers',
                     'countUsedSrbIndex', 'numberOfActiveUeSa', 'numberOfActiveUeNsa',
                     'allocatedNumOfBearers', 'allocatedNumOfPduSessions', 'currentRohcCtxNumber',
                     'allocatedDrbNumber', 'allocatedSrbNumber', 'currentUeNumber',
                     'allocatedShortPCsiNumber', 'allocatedLongPCsiNumber', 'allocatedShortSRNumber',
                     'allocatedLongSRNumber', 'ueCount', 'bearerCount', 'numOfResources',
                     'nbOfActiveUEs', 'nbOfActiveSRBs', 'nbOfActiveDRBs', 'tempUeCount',
                     'activeUEsPerCell', 'allocatedNumPCsiResource', 'nbOfTemporaryUEs',
                     'usedCFPreamble', 'allocatedNumSR', 'numberOfAllocatedTeid', 'admittedNrdcUsers',
                     'sCellUlCounter', 'pSCellCounter', 'numberOfActiveUeNrdc', 'numberOfInactiveUes',
                     'sCellDlCounter', 'pSCellCaCounter', 'activeUes', 'usedHarqCount',
                     'bitMapOfDrbUsage', 'bitMapOfUeUsage', 'bitMapOfBWPUsage', 'bitMapOfDUDrbUsage']
        exclude_res_type = ['poolPayload', 'poolCtrl', 'poolPayloadRlcBundles', 'poolInd']
        hanging_users = False
        success = True
        nr = bool(process != "RROMexe")
        a = re.search(r'(AaShell>[\s\S]*?)?({[\s\S]*})', data)
        if a:
            j = json.loads(a.group(2))
            self.log.write(json.dumps(j, indent=4) + '\n')
            not_checked = []
            res_type = ""
            for a in self.__dict_generator(j):
                try:
                    if a[-2] == "resourceType":
                        res_type = a[-1]
                    elif (
                         "num" in a[-2] and
                         not a[-2] in ['numCells', 'numS1Links', 'numX2Links'] and
                         not nr) or (a[-2] in nr_fields and res_type not in exclude_res_type):
                        if str(a[-1]) != u'0' or str(a[-1]) != "0":
                            text = "Possibly hanging users: {}, resourceType: {}".format(a, res_type)
                            self.log.write(text + '\n')
                            print(text)
                            hanging_users = True
                        res_type = ""
                    else:
                        not_checked.append(a[-2] + ":" + str(a[-1]))
                        res_type = ""
                except TypeError:
                    pass

            if hanging_users:
                text = "Hanging users, check output from {}".format(self.output_file)
                self.log.write(text + '\n')
                print(text)
            self.log.write("Not checked fields: " + str(set(not_checked)))
        elif "is not a valid command" in data:
            success = True
        else:
            print("Data couldn't be fetched for hanging user check")
            success = False
        return success, hanging_users


with Hanging(datetime.now().strftime("%Y%m%d_%H%M%S") + '_hanging_resource_check_' + HOST + '.log',
             datetime.now().strftime("%Y%m%d_%H%M%S") + '_hanging_debug_' + HOST + '.txt') as t:
    if t.check_hanging():
        print("There were hanging resources")
    else:
        print("No hanging resources")
