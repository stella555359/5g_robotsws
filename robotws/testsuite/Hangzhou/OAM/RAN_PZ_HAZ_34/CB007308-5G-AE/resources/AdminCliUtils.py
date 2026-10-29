from SSHLibrary import SSHLibrary
from robot.api import logger
from json import JSONDecoder
from copy import deepcopy
import os

ssh = SSHLibrary()


class AdminCliUtils:

    def __init__(self, debug=False, console=False):
        # Because of Robot retarded limitations we have to handle this
        # ourselves.
        if isinstance(debug, bool):
            self._debug = debug
        else:
            if debug == "True":
                self._debug = True
            else:
                self._debug = False
        if isinstance(console, bool):
            self._console = console
        else:
            if console == "True":
                self._console = True
            else:
                self._console = False
        self.path = "/home/ute"
        self.files = None

    def admincliutils_debug(self, msg):
        if self._debug:
            logger.info(msg, html=True, also_console=self._console)

    def get_full_http(self, ip):
        self.admincliutils_debug("Get full http for {}".format(ip))
        if ":" in ip:
            return "[{}]".format(ip)
        else:
            return ip

    def configure_cli_host(self, host, user, pwd, logdir):
        self.admincliutils_debug(
            "Configuring: {}: {}({})".format(
                host, user, pwd))
        ssh.open_connection(host)
        ssh.login(user, pwd)
        ssh.execute_command("rm -f {}/*".format(logdir))

    def unconfigure_cli_host(self):
        ssh.close_connection()

    def parse_output(self, out):
        d = JSONDecoder()
        while len(out) > 0:
            (jdata, index) = d.raw_decode(out)
            if jdata["requestStatus"] != "ongoing":
                self.admincliutils_debug("Returned output: {}".format(out))
                return jdata
            out = out[index + 1:].strip()
        return {}

    def extract_result_from(self, data):
        (data, trash) = data.rsplit("}", 1)
        self.admincliutils_debug(
            "extract_result_from:\n{}\n{}\n".format(
                data, trash))
        return self.parse_output(data + "}")

    def run_cli_cmd(self, cmd, port, data, opts=""):
        (out, err) = ssh.execute_command(
            "{} --cli-port={} --data={} {}".format(cmd, port, data, opts),
            return_stderr=True,
        )
        if len(err) == 0:
            self.admincliutils_debug(
                "run_cli_cmd: Stripping result until final update")
            return self.parse_output(out)
        self.admincliutils_debug("run_cli_cmd: Error\n{}".format(err))
        return {}

    def dictify(self, lst, value):
        if not lst:
            return value
        sub_dict = self.dictify(lst[1:], value)
        return {lst[0]: deepcopy(sub_dict)}

    def add_to_dict(self, dct, lst, value):
        if not lst[0] in dct.keys():
            dct[lst[0]] = self.dictify(lst[1:], value)
        else:
            self.add_to_dict(dct[lst[0]], lst[1:], value)

    def list_to_dict(self, lst, common_index):
        d = dict()
        for item in lst:
            d[item.pop(common_index)] = item
        return d

    def str_to_dict(self, s, sep):
        d = dict()
        for element in s.split(sep):
            if "=" in element:
                (index, value) = element.split("=")
                d[index.strip()] = value.strip()
        return d

    def get_cert_info(self, certfile, opt):
        self.admincliutils_debug("Getting {} from {}".format(opt, certfile))
        out = ssh.execute_command(
            "openssl x509 -in {} -{}".format(certfile, opt))
        (name, result) = out.split("\n", 1)[0].split("=", 1)
        return result

    def compare_DN(self, s1, s2):
        self.admincliutils_debug("Comparing {} to {}".format(s1, s2))
        DN1 = self.str_to_dict(s1, ",")
        DN2 = self.str_to_dict(s2, "/")
        if DN1 != DN2:
            raise ValueError("DN mismatch {} and {}".format(s1, s2))

    def compare_date(self, d1, d2):
        if d1 != d2:
            raise ValueError("Date mismatch {} and {}".format(d1, d2))

    def read_measurements(self, reads_list):
        self.admincliutils_debug("Filing: {}".format(reads_list))
        power = dict()
        vswr = dict()
        temp = dict()
        types = {"ENERGY_EFFICIENCY": power, "VSWR": vswr, "TEMPERATURE": temp}
        for reading in reads_list:
            read_index = list(reading.keys())[0]
            read_value = reading[read_index]
            mkeys = read_index.split("/")
            for key in types.keys():
                if mkeys[0] == key:
                    self.add_to_dict(types[key], mkeys[1:], read_value)
        self.admincliutils_debug("power: {}".format(power))
        self.admincliutils_debug("vswr: {}".format(vswr))
        self.admincliutils_debug("temp: {}".format(temp))
        return power, vswr, temp

    def status_should_be(self, status, expected_list):
        self.admincliutils_debug(
            "status_should_be: {} / {}".format(status, expected_list)
        )
        if status not in expected_list:
            raise ValueError("Not expected Status")

    def data_checkup(self, key_list, d1, d2):
        self.admincliutils_debug(
            "Comparing data for keys: {}".format(key_list))
        for key in key_list:
            if d1[key] != d2[key]:
                raise ValueError(
                    "Data mismatch for {}: {} =/= {}".format(key, d1[key], d2[key])
                )

    def check_output_file(self, filename):
        self.admincliutils_debug("Checking host for file: {}".format(filename))
        ssh.file_should_exist(filename)

    def compare_content(self, f1, f2):
        self.admincliutils_debug(
            "Compare content from files {} and {}".format(
                f1, f2))
        out = ssh.execute_command("diff {} {}".format(f1, f2))
        if out:
            raise ValueError("Files {} and {} not identical".format(f1, f2))

    def should_only_contain_certificates(
            self, chain_type, msg_list, *cert_list):
        self.admincliutils_debug("Checking BTS certificates")
        if len(msg_list) != len(cert_list):
            raise ValueError("Not the expected number of certificates")
        msg_certs = self.list_to_dict(msg_list, "serialNumber")
        cmp_certs = dict()
        for cert in cert_list:
            cmp_certs[self.get_cert_info(cert, "serial")] = {
                "fingerPrint": self.get_cert_info(cert, "fingerprint"),
                "issuedTo": self.get_cert_info(cert, "subject"),
                "issuer": self.get_cert_info(cert, "issuer"),
                "validFrom": self.get_cert_info(cert, "startdate"),
                "validTo": self.get_cert_info(cert, "enddate"),
            }
        self.admincliutils_debug("msg_certs: {}".format(msg_certs))
        self.admincliutils_debug("cmp_certs: {}".format(cmp_certs))

        for serial in msg_certs.keys():
            if msg_certs[serial]["fingerPrint"] != cmp_certs[serial]["fingerPrint"]:
                raise ValueError("Wrong fingerprint for {}".format(serial))
            self.compare_DN(
                msg_certs[serial]["issuedTo"], cmp_certs[serial]["issuedTo"]
            )
            self.compare_DN(
                msg_certs[serial]["issuer"],
                cmp_certs[serial]["issuer"])
            self.compare_date(
                msg_certs[serial]["validFrom"], cmp_certs[serial]["validFrom"]
            )
            self.compare_date(
                msg_certs[serial]["validTo"], cmp_certs[serial]["validTo"]
            )
            if msg_certs[serial]["source"] != "Operator":
                raise ValueError("Wrong source for {}".format(serial))
            if msg_certs[serial]["chain"] != chain_type:
                raise ValueError("Wrong chain for {}".format(serial))

    def get_file_for_Trunk_Load(self, package):
        os.chdir(self.path)
        release1, gnb, brand, packet, names = package.split("_", 4)
        print(names)
        release1 = release1.lstrip("SBTS")
        package = package.replace(release1, "00")
        release, num = package.split("_", 1)

        packet1 = packet.lstrip("0")
        packet = int(packet1)
        packet1 = "%06d" % packet
        packet = str(packet1)
        names = names.lstrip("0")
        print(names)
        for m in range(0, 15):
            name = int(names) - m
            print(name)
            if name == 0:
                break
            name1 = "%06d" % name
            name1 = str(name1)
            print(name1)
            files = (
                release
                + "_"
                + gnb
                + "_"
                + brand
                + "_"
                + packet
                + "_"
                + name1
                + "_ADMIN_CLI.zip"
            )
            print(files)
            file_name = (
                release + "_" + gnb + "_" + brand + "_" + packet + "_" + name1
            )
            print(file_name)
            os.system(
                "sudo wget https://artifactory-espoo2.int.net.nokia.com/artifactory/"
                "mn-cosi-sran-central-public-local/build/%s/%s/%s"
                % (release, file_name, files)
            )
            file_path = os.path.join(self.path, files)
            if os.access(file_path, os.F_OK):
                break

        self.files = files

    def get_file_for_21B_Load(self, package):
        os.chdir(self.path)
        release1, gnb, brand, packet, names = package.split("_", 4)
        release, num = package.split("_", 1)
        for i in range(0, 50):
            packet1 = packet.lstrip("0")
            packet = int(packet1) - i
            packet1 = "%06d" % packet
            packet = str(packet1)
            files = (
                release1
                + "_"
                + gnb
                + "_"
                + brand
                + "_"
                + packet
                + "_"
                + names
                + "_ADMIN_CLI.zip"
            )
            file_name = release1 + "_" + gnb + "_" + brand + "_" + packet + "_" + names
            os.system(
                "sudo wget https://artifactory-espoo2.int.net.nokia.com/artifactory/"
                "mn-cosi-sran-central-public-local/build/%s/%s/%s"
                % (release, file_name, files)
            )
            file_path = os.path.join(self.path, files)
            if os.access(file_path, os.F_OK):
                break
        self.files = files

    def get_file_for_21A_Load(self, package):
        release, gnb, brand, packet, names = package.split("_", 4)
        os.chdir(self.path)
        for i in range(0, 50):
            names = names.lstrip("0")
            name = int(names) - i
            name1 = "%06d" % name
            name = str(name)
            name1 = str(name1)
            file = brand.lstrip("0") + "." + packet.lstrip("0") + "." + name
            files = (
                release
                + "_"
                + gnb
                + "_"
                + brand
                + "_"
                + packet
                + "_"
                + name1
                + "_ADMIN_CLI.zip"
            )
            os.system(
                "sudo wget https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/"
                "System_Release/%s/%s" %
                (file, files))
            file_path = os.path.join(self.path, files)
            if os.access(file_path, os.F_OK):
                break
        self.files = files

    def get_file_for_20B_Load(self, package):
        release, gnb, brand, packet, names = package.split("_", 4)
        os.chdir(self.path)
        for i in range(0, 50):
            names = names.lstrip("0")
            name = int(names) - i
            name = str(name)
            file = brand.lstrip("0") + "." + packet.lstrip("0") + "." + name
            files = release + "_" + file + "_ADMIN_CLI.zip"
            os.system(
                "sudo wget https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/"
                "System_Release/%s/%s" %
                (file, files))
            file_path = os.path.join(self.path, files)
            if os.access(file_path, os.F_OK):
                break
        self.files = files

    def unzip_file(self):
        if not os.path.exists('/home/ute/ADMIN_CLI/'):
            os.makedirs('/home/ute/ADMIN_CLI/')
        os.system("rm -rf /home/ute/ADMIN_CLI/*")
        os.system("mv %s /home/ute/ADMIN_CLI/" % self.files)
        os.chdir("/home/ute/ADMIN_CLI/")
        os.system("unzip *")
        os.system("chmod 777 admin-cli.sh")
        os.system("chmod 777 node/linux/bin/node")
        os.system("chmod 777 agent-cli/agent-cli.sh")
        os.system("chmod 777 agent-cli/node/linux/bin/node")
