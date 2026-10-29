import os
import sys
import linux_cmds as linux
from robot.libraries.BuiltIn import BuiltIn
import csv
import re


# =================================================================================================
# Installer : generic class to install a shark tool
# =================================================================================================
class Installer(object):
    MSG_ID_FILENAME = "msg_ids_raw.csv"

    def __init__(self, analyzer):
        self.analyzer = analyzer
        self.installed = False

    @staticmethod
    def getSharkTool():
        sharkTool = BuiltIn().get_variable_value("${SharkTool}")
        testSharkTool = BuiltIn().get_variable_value("${TestSharkTool}")
        if testSharkTool is None:
            tool = sharkTool
        else:
            tool = testSharkTool
        # linux.console("Detecting correct tool for Captures:ShartTool={}, TestSharkTool={}, FINAL CHOICE={}".
        #               format(sharkTool, testSharkTool, tool))
        # 02-Aug-2022: As LUA_SHARK is definitly removed, MC_SHARK becomes the default tool
        tool = "MC_SHARK"
        # linux.console("Forcing {} tool for Captures".format(tool))
        return tool

    @staticmethod
    def getInstaller(analyzer):
        sharkTool = Installer.getSharkTool()
        if sharkTool == "MC_SHARK":
            return McSharkInstaller(analyzer)
        return LuaSharkInstaller(analyzer)

    def install(self):
        raise NotImplementedError

    def setScriptName(self, name):
        raise NotImplementedError

    def appendMsgIdRaw(self):
        """
        check a csv file,then retrieve list of column
        with a row of <message name>,<decimal message id>,
        and <hexa message id>
        Then, update listOfAllMsgAndId table attribute from analyzer
        """
        msgIdFile = "{}/{}".format(self.getMsgIdFilePath(), Installer.MSG_ID_FILENAME)
        linux.fatal_if(not os.path.exists(msgIdFile),
                       "{} file {} not found".format(Installer.MSG_ID_FILENAME, msgIdFile))
        linux.info("Parsing MsgId File :{}".format(msgIdFile))
        with open(msgIdFile, 'r') as file:
            csv_reader = csv.DictReader(file, delimiter=';', fieldnames=["msgName", "msgIdDec", "msgIdHex"])
            for column in csv_reader:
                my_unwanted_feature = 'ft1120'
                if my_unwanted_feature not in column['msgName']:
                    messageName = linux.get_name_from_extension(column['msgName'])
                    messagePrefix = column['msgName'].rsplit('/')[-2]
                    splittingMessageName = column['msgName'].split('/', 2)[-1].replace('/', '_').split('.lua')[0]
                    self.analyzer.listOfAllMsgAndId.append([column['msgName'], messagePrefix.lower(),
                                                            messageName.lower(), column['msgIdHex'],
                                                            splittingMessageName.lower()])

    def get_shark_option(self):
        raise NotImplementedError

    def getMsgIdFilePath(self):
        raise NotImplementedError


# =================================================================================================
# LuasharkInstaller : to install luashark either in home/generated_luashark/<version> or in
#                     /opt/luashark/generated_luashark (UTE)
# =================================================================================================
class LuaSharkInstaller(Installer):
    # Root name for Luashark package on WFT
    LUASHARK_NAME = "luashark"
    # Prefix for directory name in which luashark.zip will deploy its content
    LUASHARK_PREFIX = "generated_luashark"
    # Name of script to provide to tshark for analysis of Nokia dedicated field
    LUASHARK_SCRIPT = "luashark.lua"
    # Temporary file for luashark.zip
    LUASHARK_ZIP = "TMP_LUASHARK.zip"
    # Full path to Luashark for UTE case
    LUASHARK_PATH_UTE = "/opt/luashark/generated_luashark"

    def __init__(self, analyzer):
        super(LuaSharkInstaller, self).__init__(analyzer)
        self.version = None
        self.luashark_root = None
        self.luashark_path = None
        self.luashark_script = None
        self.luashark_url = None
        if self.analyzer.isSharkRequired:
            if self.analyzer.af_path is not None:
                self.af_path = self.analyzer.af_path
            else:
                self.af_path = BuiltIn().get_variable_value("${AF_PATH}")
            if "--dryrun" not in sys.argv and not self.analyzer.isUTE:
                assert self.af_path is not None, "luashark_tools Library was invoked without AF_PATH"

    def get_shark_option(self):
        return "-X lua_script:{}".format(self.luashark_script)

    def getMsgIdFilePath(self):
        return self.luashark_path

    def setScriptName(self, name):
        linux.info("Setting Luashark script name to :{}".format(name))
        self.LUASHARK_SCRIPT = name

    def setLuasharkPathsNoneUTE(self):
        # From AF_PATH, we extract last two directories
        twords = self.af_path.split('/')
        self.luashark_url = self.af_path
        if "SBTS" in self.af_path:
            # https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_210605_000013_luashark.zip
            self.version = twords[-1].replace("_luashark.zip", "")
        else:
            # https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/
            # System_Release/0.800.4501/luashark-0.800.4501.zip
            #  Version is second previous field
            self.version = twords[-2]
            # Replace last field with "luashark-<version>.zip"
            self.luashark_url = self.af_path.replace(
                twords[-1],
                "{}-{}.zip".format(LuaSharkInstaller.LUASHARK_NAME, self.version))
        linux.info("luashark_url={}".format(self.luashark_url))
        # Then, building path to Luashark, path to Luashark.lua script
        root = get_root_path()
        self.luashark_root = "{}/tools/{}"\
            .format(root, LuaSharkInstaller.LUASHARK_NAME)
        self.luashark_path = "{}/{}-{}"\
            .format(self.luashark_root, LuaSharkInstaller.LUASHARK_PREFIX, self.version)

    def setLuasharkPathsUTE(self):
        self.luashark_root = self.luashark_path = LuaSharkInstaller.LUASHARK_PATH_UTE

    def is_luashark_installed(self):
        """
        Check if luashark is installed for this version
        Also check if luashark.lua script is present inside
        """
        # First check if path to luashark exists
        prefix = LuaSharkInstaller.LUASHARK_NAME
        if not self.analyzer.isUTE:
            prefix += " for {}".format(self.version)
        if not os.path.isdir(self.luashark_path):
            linux.info("{} not installed".format(prefix))
            return False
        # Also verify if luashark/lua script exists inside it
        assert os.path.exists(self.luashark_script), \
            "Path for luashark {} exists, but not {} script."\
            .format(self.luashark_path, LuaSharkInstaller.LUASHARK_SCRIPT)
        # Luashark now properly installed
        linux.info("{} already installed in {}"
                   .format(prefix, self.luashark_script))
        self.installed = True
        return True

    def install_luashark(self):
        """
        Install luashark in :
        /home/<user>/tools/luashark/generated_luashark-<version>
        """
        targetZipFile = ""
        try:
            # Create root path to Luashark in case it does not exist
            linux.execute("mkdir -p {}".format(self.luashark_root))
            # Remove temporary zip file if exists
            targetZipFile = "{}/{}"\
                .format(self.luashark_root, LuaSharkInstaller.LUASHARK_ZIP)
            linux.rm_if_exist(targetZipFile)
            # Launch wget command to dowwnload luashark-<version>.zip
            # into targetZipFile
            linux.execute("wget {} -O {} -o {}".format(
                self.luashark_url, targetZipFile, self.analyzer.tmp_file))
            # Check no error occured during download
            with open(self.analyzer.tmp_file) as resFile:
                for line in resFile:
                    assert "ERROR" not in line, \
                        "Error while downloading {}:\n{}"\
                        .format(self.luashark_url, line)
            # Unzip downloaded zip file and rename it with version as suffix
            linux.unzip_file(targetZipFile, self.luashark_root)
            os.rename("{}/{}".
                      format(self.luashark_root, LuaSharkInstaller.LUASHARK_PREFIX),
                      self.luashark_path)
            assert os.path.exists(self.luashark_script), "Unable to find {} in {}"\
                .format(LuaSharkInstaller.LUASHARK_SCRIPT, self.luashark_path)
            self.installed = True
        finally:
            os.remove(targetZipFile)

    def install(self):
        """
        Compute all analyzer attributes (paths, version,...)
        and install dedicated luashark  if required
        """
        # If Luashark, removing McShark driver as both are exclusive
        McSharkInstaller.removeMcShark(self)

        # Compute all attributes (upon ute or not)
        if self.af_path is not None:
            self.setLuasharkPathsNoneUTE()
        else:
            self.setLuasharkPathsUTE()

        # Compute final attributes (whatever cases)
        self.luashark_script = "{}/{}"\
            .format(self.luashark_path, LuaSharkInstaller.LUASHARK_SCRIPT)
        linux.info("version={} luashark_path={}"
                   .format(self.version, self.luashark_path))
        # console("DEBUG:ANALYZER={} version={}".format(self,self.version))

        # Install Luashark if required
        if not self.is_luashark_installed():
            assert self.af_path is not None, "FATAL ERROR:No luashark found at {}".format(self.luashark_path)
            self.install_luashark()


# =================================================================================================
# McCharkInstaller : to install McShark
# =================================================================================================
class McSharkInstaller(Installer):
    # Root path for wireshark plugins
    WIRESHARK_PLUGINS_ROOT_PATH = "/home/ute/.local/lib/wireshark/plugins"
    # Name of script used to deploy McShark driver
    INSTALL_SCRIPT = "install_wslte_plugins.bash"
    # URL where to catch Mc Shark driver
    URL_ARTIFACTORY_ESPOO = "http://artifactory-espoo1.int.net.nokia.com/artifactory"
    # Entry point directory where are coded tests
    RRM_DIRNAME = "RRM/ET"
    # Entry point directory where shark config files are stored
    SHARK_REL_PATH = "resources/SWENG/config/shark"

    @staticmethod
    def get_wireshark_main_version():
        # launch a command to catch full line of version for wireshark
        # Should return something like :
        #    Wireshark 3.6.3.lte.2206.01 (v3.6.3.lte.2206.01+buster-0-g41e89ab7dad4)
        ret = linux.exec_w_ret("wireshark --version  | head -1")
        assert ret.startswith("Wireshark "), "Unable to find wireshark version"
        # Extract long version string : 3.6.3.lte.2206.01
        longVersion = ret.split(" ")[1]
        match = re.match("^([0-9])[.]([0-9]*)[.].*$", longVersion)
        assert match, "Wireshark version [{}] is not matching x.y start pattern".format(longVersion)
        return "{}.{}".format(match.group(1), match.group(2))

    def getMsgIdFilePath(self):
        return McSharkInstaller.sharkPathInSweng()

    def setScriptName(self, name):
        pass

    def get_shark_option(self):
        return ""

    @staticmethod
    def buildToMainBuild(build):
        # in case build is SBTS00_xxx, we keep it since in trunk, all build are supposed to have a MC_SHARK
        # otherwise, in branch (22R2, ...), we take main build, meaning build ending with _000000
        # ex: SBTS22R2_ENB_0000_001671_000007 -> SBTS22R2_ENB_0000_001671_000000  (_000007 replaced with _000000)
        # ex: SBTS00_ENB_0000_220613_000010   -> SBTS00_ENB_0000_220613_000010    (no change)
        branch = build.split("_")[0]
        if branch.endswith("00"):
            return build
        else:
            return re.sub(pattern="_[0-9]*$", repl="_000000", string=build)

    def getBuild(self):
        # Here, we return build as extracted in topo file
        build = BuiltIn().get_variable_value("${TLConfig.topo.gnbVersion}")
        mainBuild = McSharkInstaller.buildToMainBuild(build)
        linux.info("Main build selected for MC_SHARK:{}".format(mainBuild))
        return mainBuild

    def get_driver_path(self):
        self.mcSharkPath = "{}/{}/epan".format(McSharkInstaller.WIRESHARK_PLUGINS_ROOT_PATH,
                                               McSharkInstaller.get_wireshark_main_version())
        linux.info("Searching for McShark in {}".format(self.mcSharkPath))
        if not os.path.isdir(self.mcSharkPath):
            linux.info("No directory {} found. So, no McShark driver found".format(self.mcSharkPath))
            return None
        for file in os.listdir(self.mcSharkPath):
            match = re.match("^mcshark-(.*)-(.*)so$", file)
            if match:
                mcSharkVersion = match.group(1)
                buildFound = match.group(2)
                linux.info("Found McShark driver:[{}] Version={} Build={}".format(file, mcSharkVersion, buildFound))
                build = self.getBuild()
                if build not in buildFound:
                    linux.console("WARNING:McShark driver:[{}]. Found build {} is not matching current build ({})"
                                  .format(file, buildFound, build))
                return "{}/{}".format(self.mcSharkPath, file)
        linux.info("No McShark driver found in {}".format(self.mcSharkPath))
        return None

    def is_mcshark_installed(self):
        return self.get_driver_path() is not None

    @staticmethod
    def sharkPathInSweng():
        sharkPath = "{}/{}".format(os.path.dirname(os.path.abspath(__file__)).split(McSharkInstaller.RRM_DIRNAME)[0],
                                   McSharkInstaller.SHARK_REL_PATH)
        # linux.console("sharkPath={}".format(sharkPath))
        return sharkPath

    def script_install(self):
        cmd = "{}/{} -B {} -A {} > {} 2>&1 ".format(McSharkInstaller.sharkPathInSweng(),
                                                    McSharkInstaller.INSTALL_SCRIPT,
                                                    self.getBuild(), McSharkInstaller.URL_ARTIFACTORY_ESPOO,
                                                    self.analyzer.tmp_file)
        linux.execute(cmd)
        with open(self.analyzer.tmp_file) as f:
            for line in f.readlines():
                if line.startswith("ERROR:"):
                    linux.info("ERROR found:{}".format(line))
                    return False
        return self.is_mcshark_installed()

    def install(self):
        if self.is_mcshark_installed():
            self.installed = True
        else:
            self.installed = self.script_install()
            assert self.installed, "MC_SHARK driver not properly installed"
        return self.installed

    @staticmethod
    def removeMcShark(analyzer):
        installer = McSharkInstaller(analyzer)
        path = installer.get_driver_path()
        if path is not None:
            cmd = "rm {}".format(path)
            linux.console("Removing McShark driver:{}".format(path))
            linux.execute(cmd)


# =================================================================================================
# External functions
# =================================================================================================
def get_root_path():
    """
    computing root path where to deploy Luashark
    Strategy is :
        if /home/<user> exists, it will be root path
        otherwise, retrieve TEMP_PATH robot variable as root path
    """
    root = "/home/{}".format(linux.get_user())
    if os.path.isdir(root):
        return root
    output_dir = BuiltIn().get_variable_value("${TEMP_PATH}")
    assert output_dir is not None, \
        "${TEMP_PATH} robot variable was not set in robot context"
    return output_dir
