import argparse
import os
import shutil
import mimetypes

MIG_EXT = ".old"

global Verbose
global NumError
global ListFileCreated
global ListDirCreated
global ListError

NumError = 0
ListFileCreated = []
ListDirCreated = []
ListError = []


def info(str):
    print(str)


def verbose(str):
    if Verbose:
        print(str)


def error(str):
    global NumError
    NumError += 1
    error = "ERROR[{}]:{}".format(NumError, str)
    ListError.append(error)
    info(error)


def fatal(str):
    error(str)
    exit(-1)


def bar():
    return "=" * 100


def title(str):
    info(bar())
    info("STEP : {}".format(str))
    info(bar())


def toRelPath(srcPath, dstPath):
    relPath = os.path.relpath(dstPath, srcPath)
    return relPath


class MyFile():
    def __init__(self, path, file):
        self.path = path
        self.file = file
        self.fullPath = "{}/{}".format(path, file)
        self.ext = os.path.splitext(file)[1]

    def __str__(self):
        return self.fullPath


class MigrateFile():
    def __init__(self, srcPath, srcFile):
        self.src = MyFile(srcPath, srcFile)
        self.dst = self.migrate()

    def migrate(self):
        self.feature = "None"
        # SWENG
        if "/resources/sites/NPS/SWENG" in self.src.fullPath:
            self.type = "SWENG"
            newPath = self.src.path.replace("/resources/sites/NPS/SWENG",
                                            "/testsuite/Paris/resources/SWENG")
            return MyFile(newPath, self.src.file)
        # CRT
        if "/testsuite/CRT/ParisSaclay/tools" in self.src.fullPath:
            self.type = "CRTTOOL"
            newPath = self.src.path.replace("/testsuite/CRT/ParisSaclay/tools",
                                            "/testsuite/Paris/resources/SWENG/tools")
            return MyFile(newPath, self.src.file)
        # PYTHONLIB
        if "robotws/resources/python_libs/luashark_tools.py" in self.src.fullPath or \
           "robotws/resources/python_libs/luashark_filter.py" in self.src.fullPath or \
           "robotws/resources/python_libs/linux_cmds.py" in self.src.fullPath:
            self.type = "PYLIBS"
            newPath = self.src.path.replace("robotws/resources/python_libs",
                                            "robotws/testsuite/Paris/RRM/ET/resources/python")
            return MyFile(newPath, self.src.file)
        if "robotws/resources/python_libs/" in self.src.fullPath:
            self.type = "PYLIBSOTH"
            newPath = self.src.path.replace("robotws/resources/python_libs",
                                            "robotws/testsuite/Paris/RRM/ET/resources/python")
            return MyFile(newPath, self.src.file)
        # COMMON
        if "/testsuite/RRM/ECE/Resource" in self.src.fullPath:
            self.type = "COMMON"
            newPath = self.src.path.replace("/testsuite/RRM/ECE/Resource",
                                            "/testsuite/Paris/RRM/ET/resources")
            return MyFile(newPath, self.src.file)
        # TESTS
        if "/testsuite/RRM/ECE" in self.src.fullPath:
            fields = self.src.path.split("/")
            ln = len(fields)
            idxEce = fields.index("ECE")
            if ln <= idxEce+2:
                self.type = "TOOSHORT"
                return None
            self.feature = fields[idxEce+2]
            if not self.feature.startswith("5GC") and \
               not self.feature.startswith("CNI") and \
               not self.feature.startswith("CB"):
                self.type = "NO_TFEAT"
                return None
            self.type = "TESTS"
            fields.pop(idxEce+1)
            rebuiltPath = "/".join(fields)
            newPath = rebuiltPath.replace("/testsuite/RRM/ECE",
                                          "/testsuite/Paris/RRM/ET")
            return MyFile(newPath, self.src.file)

        # Other files
        self.type = "UNKNOWN"
        return None

    def copyToDst(self, index, toAdapt=False):
        title = "CopyToDst"
        if toAdapt:
            title = "AdaptToDst"
        info("{}[{}]:{}".format(title, index, self.src.fullPath))
        if self.dst is None:
            return
        if not os.path.isdir(self.dst.path):
            ListDirCreated.append(self.dst.path)
        if not os.path.isfile(self.dst.fullPath):
            ListFileCreated.append(self.dst.fullPath)
        os.makedirs(self.dst.path, exist_ok=True)
        src = open(self.src.fullPath)
        dst = open(self.dst.fullPath, "+w")
        try:
            lines = src.readlines()
        except Exception as e:
            error("Unable to read {} as a text file".format(self.src.fullPath))
            return
        for idx, line in enumerate(lines):
            prefix = "    {}:{}".format(self.src.fullPath, idx+1)
            newLine = line
            toRemove = False
            if toAdapt:
                tmpLine = " ".join(line.split())
                fields = tmpLine.split(" ")
                if len(fields) >= 2:
                    kw = fields[0]
                    path = fields[1]
                    if kw in ["Library", "Resource", "Variables"]:
                        if path.startswith("../"):
                            verbose(prefix)
                            fullPath = os.path.abspath("{}/{}".format(self.src.path, path))
                            # remove  TestCaseRequirement
                            if fullPath.endswith("TestCaseRequirement.py"):
                                toRemove = True
                                verbose("        REMOVING [{:10}] {}".format(kw, path))
                            if not toRemove:
                                if not os.path.isfile(fullPath):
                                    error("{} : Import [{}]:{} does not exist".format(prefix, path, fullPath))
                                importFile = MigrateFile(os.path.dirname(fullPath), os.path.basename(fullPath))
                                if importFile.dst is None:
                                    error("{} : Not allow to have reference to {} [{}]".
                                          format(prefix, fullPath, importFile.type))
                                else:
                                    dstPath = importFile.dst.fullPath
                                    if not os.path.isfile(dstPath):
                                        error("{} : target file [{}] does not exist".format(prefix, dstPath))
                                    relPath = toRelPath(self.dst.path, os.path.dirname(dstPath))
                                    newLine = newLine.replace(os.path.dirname(path), relPath)
                                    verbose("        [{:10}] {}".format(kw, path))
                                    verbose("        CHANGE INTO  {}/{}".format(relPath, importFile.dst.file))
                    if "TestCaseRequirement.requires TC" in line:
                        newLine = self.changeInto(prefix, newLine, "TestCaseRequirement.requires TC", "depends")
                    elif "requires TC" in line:
                        newLine = self.changeInto(prefix, newLine, "requires TC", "depends")
            if not toRemove:
                dst.write(newLine)
        src.close()
        dst.close()

    def changeInto(self, prefix, line, src, dst):
        line = line.replace(src, dst)
        verbose(prefix)
        verbose("        Change [{}] into [{}]".format(src, dst))
        return line

    def __str__(self):
        return "[{:8}] FEAT={:10} {}".format(self.type, self.feature, self.src.fullPath)

    def fullDesc(self, index=0):
        info("FILE[{:4}]:SRC={}".format(index, self.src))
        info("           DST={}".format(self.dst))


def getFiles(srcPath, ext=""):
    listFile = []
    for file in os.listdir(srcPath):
        fullPath = os.path.abspath("{}/{}".format(srcPath, file))
        if os.path.isfile(fullPath):
            if len(ext) == 0 or file.endswith(ext):
                listFile.append(MigrateFile(srcPath, file))
        if os.path.isdir(fullPath):
            listFile += getFiles(fullPath, ext)
    return listFile


def renameSource(srcPath, isDir=True):
    toRename = False
    if isDir:
        toRename = True
        source = srcPath
    else:
        source = srcPath.src.fullPath
        if not source.endswith(".robot"):
            return
        f = open(source, "r")
        for line in f.readlines():
            line = line.upper()
            if line.startswith("*** TEST CASES ***"):
                toRename = True
        f.close()
    if toRename:
        info("Rename:{} (->{})".format(source, MIG_EXT))
        os.rename(source, "{}{}".format(source, MIG_EXT))


def readArguments():
    parser = argparse.ArgumentParser(description="", formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("path",  help='path or list pf paths (separated with ","')
    parser.add_argument("-v", "--verbose",  help='More detailed traces on changes done',
                        action='store_true', dest='verbose')
    parser.add_argument("-e", "--execute",  help='really does migration (not only show)',
                        action='store_true', dest='execute')
    parser.add_argument("-r", "--rename",   help='rename source files', action='store_true', dest='rename')
    return parser.parse_args()


# ===========================================================================================================
# MAIN
# ===========================================================================================================
args = readArguments()
Verbose = args.verbose
Execute = args.execute
Rename = args.rename
listPathStr = args.path
ListSrcPath = []
for pathStr in listPathStr.split(","):
    srcPath = os.path.abspath(pathStr)
    if not os.path.isdir(srcPath):
        fatal("Unable to find path:{}".format(srcPath))
    ListSrcPath.append(srcPath)

listFiles = []
for srcPath in ListSrcPath:
    listFiles += getFiles(srcPath=srcPath)

title("List FILES to move [{}]".format(len(listFiles)))
for idx, file in enumerate(listFiles):
    file.fullDesc(idx+1)

title("Copy FILES to migration/Paris [{}]".format(len(listFiles)))
for idx, file in enumerate(listFiles):
    file.copyToDst(idx+1, toAdapt=False)

title("Update FILES import in migration/Paris [{}]".format(len(listFiles)))
for idx, file in enumerate(listFiles):
    file.copyToDst(idx+1, toAdapt=True)

title("Summary of ERRORS [{}]".format(NumError))
for error in ListError:
    info("SHOW {}".format(error))

if not Execute:
    title("CLEANING Files:[{}] Dir:[{}]".format(len(ListFileCreated), len(ListDirCreated)))
    for idx, file in enumerate(ListFileCreated):
        info("remove FILE[{}]:{}".format(idx+1, file))
        os.remove(file)
    ListDirCreated.reverse()
    for idx, dir in enumerate(ListDirCreated):
        if os.path.isdir(dir):
            info("remove DIR [{}]:{}".format(idx+1, dir))
            shutil.rmtree(dir, ignore_errors=True)

if Rename:
    title("Renaming source files")
    for file in listFiles:
        renameSource(srcPath=file, isDir=False)
    for path in ListSrcPath:
        renameSource(srcPath=path, isDir=True)
