import taf.transport.ssh
import json
import re
from datetime import datetime

HOST = "192.168.255.129"
USR = "toor4nsn"
PASS = "oZPS0POrRieRtu"
PORT = "15007"


class Hanging():

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

    def aashell(self, connection, command, f):
        resp = connection.execute(("echo '" + command + "' | nc 127.0.0.1 " + PORT + "\n").encode(),
                                  timeout=60)
        f.write("Command: {}".format(("echo '" + command + "' | nc 127.0.0.1 " + PORT + "\n")).encode())
        f.write("Command response: {}".format(resp).encode())
        out = connection.read_output()
        f.write("'connection.read_output()' output: {}".format(out).encode())
        f.write(resp.encode())
        return resp.encode()

    def check_hanging(self, log_file):
        connection = taf.transport.ssh.connect(HOST, USR, PASS)
        try:
            with open(log_file + ".raw", "wb") as f:
                f.write("Connection: {}".format(connection).encode())
                resp = self.aashell(connection, "nodes -p", f)
                f.write("'nodes -p' response: {}".format(resp).encode())
                if resp:
                    self.rrom = self.find_process("RROMexe", resp.decode().splitlines())[0]
                    if self.rrom:
                        resp = self.aashell(connection, "getResourcesUsage -a -j @RROMexe #" + self.rrom, f)
                        f.write("'getResourcesUsage -a -j @RROMexe #' response: {}".format(resp).encode())
                        self.aashell(connection, "quit", f)
                        return self.hanging_parse(resp, log_file)
                else:
                    resp = self.aashell(connection, "quit", f)
                    f.write("'quit' response: {}".format(resp).encode())
                    print("No response for hanging user check.")
        finally:
            connection.disconnect()

    def hanging_parse(self, data, output_file):
        a = re.search(r'({"ResourcesUsage.*]})[.\t\r\n]*', data.decode())
        hanging_users = False
        success = True
        if a:
            j = json.loads(a.group(1))
            with open(output_file, 'wb') as f:
                f.write(json.dumps(j, indent=4).encode())
                f.write(b'\n')
                for a in self.__dict_generator(j):
                    try:
                        if "num" in a[-2] and not a[-2] in ['numCells', 'numS1Links', 'numX2Links']:
                            if a[-1] != u'0' or a[-1] != "0":
                                text = "Possibly hanging users: {}".format(a)
                                f.write((text + '\n').encode())
                                hanging_users = True
                    except TypeError:
                        pass
                if not hanging_users:
                    text = "No hanging users detected"
                    f.write((text + '\n').encode())
                    print(text)
                else:
                    text = "Hanging users, check output from {}".format(output_file)
                    f.write((text + '\n').encode())
                    print(text)
            print("Data written to", output_file)
        elif "is not a valid command" in data:
            success = True
        else:
            print("Data couldn't be fetched")
            success = False
        return success and not hanging_users


t = Hanging()
t.check_hanging('hanging_resource_check_' + datetime.now().strftime("%Y%m%d_%H%M%S") + '.log')
