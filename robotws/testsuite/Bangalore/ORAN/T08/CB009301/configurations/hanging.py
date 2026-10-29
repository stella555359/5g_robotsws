import telnetlib
import json
import re
from datetime import datetime
# import sys

HOST = "192.168.255.1"
port = 15007


class hanging():

    def __dict_generator(self, indict, pre=None):
        pre = pre[:] if pre else []
        if isinstance(indict, dict):
            for key, value in list(indict.items()):
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
        connection.write((command + "\n").encode())
        # resp = connection.expect(["AaShell>"], 60)
        resp = connection.read_until(b"AaShell")
        f.write(resp)
        return resp

    def check_hanging(self, log_file):
        connection = telnetlib.Telnet(HOST, port)
        resp = connection.read_until("AaShell".encode(), 10)

        with open(log_file + ".raw", "wb") as f:
            # resp = self.aashell(connection, "telnet 0 15007", f)
            if resp:
                resp = self.aashell(connection, "nodes -p", f)
                self.rrom = self.find_process("RROMexe", resp.decode().splitlines())[0]
                if self.rrom:
                    resp = self.aashell(connection, "getResourcesUsage -a -j @RROMexe #" + self.rrom, f)
                    self.aashell(connection, "quit", f)
                    return self.hanging_parse(resp, log_file)
            else:
                resp = self.aashell(connection, "quit", f)
                print("No response for hanging user check.")

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
                            if a[-1] != '0' or a[-1] != "0":
                                text = "Possibly hanging users: {}".format(a)
                                f.write(text + '\n')
                                # print text
                                hanging_users = True
                    except TypeError:
                        pass
                if not hanging_users:
                    text = "No hanging users detected"
                    f.write((text + '\n').encode())
                    print(text)
                else:
                    text = "Hanging users, check output from {}".format(output_file)
                    f.write(text + '\n')
                    print(text)
            print(("Data written to", output_file))
        elif "is not a valid command" in data:
            success = True
        else:
            print("Data couldn't be fetched")
            success = False
        return success and not hanging_users


t = hanging()
t.check_hanging('hanging_resource_check_' + datetime.now().strftime("%Y%m%d_%H%M%S") + '.log')
# if sys.version_info.major >= 3:
#     eval(input('Press enter to continue...'))
# else:
#     input('Press enter to continue...')
