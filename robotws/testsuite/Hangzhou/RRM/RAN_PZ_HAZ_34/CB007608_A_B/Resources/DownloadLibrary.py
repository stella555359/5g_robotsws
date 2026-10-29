import os


class DownloadLibrary:
    def __init__(self):
        self.path = "/home/ute"
        self.files = None

    def get_file_for_Trunk_Load(self, package, type):
        os.chdir(self.path)
        release1, gnb, brand, packet, names = package.split("_", 4)
        release1 = release1.lstrip("SBTS")
        package = package.replace(release1, "00")
        release, num = package.split("_", 1)
        for i in range(0, 3):
            packet1 = packet.lstrip("0")
            packet = int(packet1) - i
            packet1 = "%06d" % packet
            packet = str(packet1)
            names = names.lstrip("0")
            for m in range(0, 15):
                if i == 0:
                    name = int(names) - m
                else:
                    name = 15 - m
                if name == 0:
                    break
                name1 = "%06d" % name
                name1 = str(name1)
                if type.find("ADMIN") >= 0:
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
                else:
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
                        + "_luashark.zip"
                    )
            os.system(
                "sudo wget https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/%s/%s"
                % (release, files)
            )
            file_path = os.path.join(self.path, files)
            if os.access(file_path, os.F_OK):
                break
        self.files = files

    def get_file_for_22R1_Load(self, package, type):
        os.chdir(self.path)
        release1, gnb, brand, packet, names = package.split("_", 4)
        release, num = package.split("_", 1)
        for i in range(0, 50):
            packet1 = packet.lstrip("0")
            packet = int(packet1) - i
            packet1 = "%06d" % packet
            packet = str(packet1)
            if type.find("ADMIN") >= 0:
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
            else:
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
                    + "_luashark.zip"
                )
            os.system(
                "sudo wget https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/%s/%s"
                % (release, files)
            )
            file_path = os.path.join(self.path, files)
            if os.access(file_path, os.F_OK):
                break
        self.files = files

    def unzip_file(self, type):
        if type.find("ADMIN") >= 0:
            os.system("rm -rf /home/ute/current/*")
            os.system("mv %s /home/ute/current/" % self.files)
            os.chdir("/home/ute/current/")
            os.system("unzip *")
            os.system("chmod 777 admin-cli.sh")
            os.system("chmod 777 node/linux/bin/node")
            os.system("chmod 777 agent-cli/agent-cli.sh")
            os.system("chmod 777 agent-cli/node/linux/bin/node")
        else:
            os.system("rm -rf /home/ute/luashark/*")
            os.system("mv %s /home/ute/luashark/" % self.files)
            os.chdir("/home/ute/luashark/")
            os.system("unzip *")
