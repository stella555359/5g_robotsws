import os


class Downloadluashark:
    def __init__(self):
        self.path = "/home/ute"
        self.files = None

    def get_file_for_Trunk_Load(self, package):
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
            files = files = "luashark-" + file + ".zip"
            os.system(
                "sudo wget https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/"
                "System_Release/%s/%s" % (file, files)
            )
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
            files = "luashark-" + file + ".zip"
            os.system(
                "sudo wget https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/"
                "System_Release/%s/%s" % (file, files)
            )
            file_path = os.path.join(self.path, files)
            if os.access(file_path, os.F_OK):
                break
        self.files = files

    def unzip_file(self):
        os.system("rm -rf /home/ute/luashark/*")
        os.system("mv %s /home/ute/luashark/" % self.files)
        os.chdir("/home/ute/luashark/")
        os.system("unzip *")
        os.chdir("/home/ute/")
        os.system("rm -rf %s" % self.files)
