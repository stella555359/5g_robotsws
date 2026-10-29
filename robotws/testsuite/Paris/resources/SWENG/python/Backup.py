from ReadConfig import TLConfig
import Connect

TYPE_FILE = 1
TYPE_LINK = 2
FD_ALL = []


# ===================================================================
# Class for Backup File description
# ===================================================================
class FileDesc(object):
    def __init__(self, name, path=None, fileName=None, type=TYPE_FILE, host=None):
        self.name = name
        self.path = path
        self.fileName = fileName
        self.type = type
        self.host = host

    @staticmethod
    def add(fileDesc):
        FD_ALL.append(fileDesc)


# ===================================================================
# Definition of files description for backup
# ===================================================================
def initBackupFilesDesc():
    ap = Connect.AP_DU().sys[0].M
    tl = TLConfig.getTL()
    FileDesc.add(FileDesc(name="AP_SWCONFIG", path="/ffs/run", fileName="swconfig.txt", host=ap))
    FileDesc.add(FileDesc(name="AP_PHY_XML", path="/rom/simmode", fileName="iphy.xml", type=TYPE_LINK, host=ap))
    FileDesc.add(FileDesc(name="WTS_CFG", path=tl.core.dir_path, fileName=tl.core.cfg_filename,
                          host=Connect.HOST_EPCSIM))
    if not TLConfig.topo.isAic():
        for idx in range(0, TLConfig.topo.getNbGNB()):
            FileDesc.add(FileDesc(name="TGNB{}_SWCONFIG".format(idx), path="/ffs/run", fileName="swconfig.txt",
                                  host=Connect.TGNB_DU(idx).sys[0].M))


def getFileDescByName(name):
    for fileDesc in FD_ALL:
        if fileDesc.name == name:
            return fileDesc
    return None
