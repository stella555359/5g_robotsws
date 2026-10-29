import os.path
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SuiteSetup.configure.server import *
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SuiteSetup.common.ssh import SshClient
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SuiteSetup.common.helper import *
from robot.api import logger
from .util import get_release, get_wft_buildinfo


class LoadMgr(object):
    def __init__(self, loadname, loadserver="10.66.11.28", user="scpadm", passwd="M%ACTfVV&U!k3qqL#1r4", port="22",
                 remote_base_path=LOAD_ROOT_PATH_5G):
        logger.info("load server is {}.".format(loadserver))
        self.loadserver = SshClient(loadserver, user, passwd, port)
        self.remote_base_path = remote_base_path

        # access load server to create load info
        self.info = self._parseloadinfo(loadname)

        # this load release is one on load server, not activetion release on eNB
        self.release = self.info["release"]

        # loadname
        # 5G: SBTS00_ENB_9999_210308_000018
        self.loadname = loadname

        # load on gNB
        # 5G: SBTS00_ENB_9999_210308_000018
        self.gnb_loadname = loadname

    def downloadpkg(self):
        path = self.info["path"]
        asimgr = self.info["asimgr"]
        asicli = self.info["asicli"]

        local = os.path.join(PKG_LOCAL_ROOTPATH, self.loadname)
        if not os.path.exists(local):
            os.makedirs(local)

        # download load packages
        remote_files = os.path.join(path, self.loadname)
        logger.info("download {}".format(remote_files))
        self.loadserver.get_files(remote_files, "_release_BTSSM_downloadable_A54", local)

        if asimgr is not None:
            if "_x64.bin" not in asimgr:
                asimgr = "{}_x64.bin".format(asimgr)

            self.loadserver.get(os.path.join(path, "ASI_Manager", asimgr), os.path.join(local, asimgr))
            run("chmod +x {}".format(os.path.join(local, asimgr)))

        if asicli is not None:
            self.loadserver.get(os.path.join(path, "ASI_CLI", asicli, "asi-cli.tgz"),
                                os.path.join(local, "asi-cli.tgz"))

    @classmethod
    def deleteload(cls, loadname):
        load_dir = os.path.join(PKG_LOCAL_ROOTPATH, loadname)
        logger.info("delete bin and zip files in dir: {}".format(load_dir))
        if not os.path.exists(load_dir):
            logger.info("local path {} doesn't exist.".format(load_dir))
            return

        files = [f for f in os.listdir(load_dir) if os.path.isfile(os.path.join(load_dir, f))]
        for file in files:
            logger.debug(file)
            _, ext = os.path.splitext(file)
            if ext in (".bin", ".zip", ".tgz"):
                os.remove(os.path.join(load_dir, file))
                logger.info("delete file {}.".format(file))

    def prepare_yaft(self):
        logger.info("Download yaft from svn: {}".format(yaft_svn_url), also_console=True)
        # yaft_pkg = "newest_yaft.tar.gz"
        # self.loadserver.get(
        #     "/home/scpadm/SPACE/COMMON/tools/{}".format(yaft_pkg),
        #     "/home/ute/{}".format(yaft_pkg),
        # )
        # run("cd /home/ute && tar zxf {}".format(yaft_pkg))

        if os.path.exists(yaft_file):
            logger.info("Yaft package exists in path: {}, wont download again!".
                        format(yaft_file), also_console=True)
        else:
            run("rm -rf {0} && mkdir -p {0}".format(yaft_latest_path))
            run("svn checkout --username {} --password {} --ignore-externals "
                "{} {}".format(yaft_svn_user, yaft_svn_passwd, yaft_svn_url, yaft_latest_path))

    @classmethod
    def get_loaddir(cls, loadname):
        return os.path.join(PKG_LOCAL_ROOTPATH, loadname)

    def _parseloadinfo(self, loadname):
        # load: SBTS00_ENB_9999_210308_000018
        release, asirmgr, asicli = self._getloadinfo(loadname)
        logger.info("release: {}, asirmgr: {}, asicli: {}".format(release, asirmgr, asicli))

        if asirmgr is not None:
            parts = asirmgr.split("_")
            asirmgr = "ASIRMGR-{}-{}".format(parts[0], "_".join(parts[2:]))

        release = release.upper()

        return {
            "release": release,
            "path": self.remote_base_path,
            "asimgr": asirmgr,
            "asicli": asicli,
        }

    # get load info from wft
    def _getloadinfo(self, loadname):
        # get release form coop
        release = get_release(loadname)
        asirmgr, asicli = get_wft_buildinfo(loadname)
        return release, asirmgr, asicli
