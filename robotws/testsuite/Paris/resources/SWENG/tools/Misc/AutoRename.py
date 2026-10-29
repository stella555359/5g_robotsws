import argparse
import os

BLACK = "\033[30m"
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
PINK = "\033[35m"
CYAN = "\033[36m"
WHITE = "\033[37m"
BG_BLACK = "\033[40m"
BG_RED = "\033[41m"
BG_GREEN = "\033[42m"
BG_YELLOW = "\033[43m"
BG_BLUE = "\033[44m"
BG_PINK = "\033[45m"
BG_CYAN = "\033[46m"
BG_WHITE = "\033[47m"
NORMAL = "\033[0m"

ListError = []

ListPatternStr = [
    "GNB_CU",               "GNB_DU",
    "GNB_BTS_INFO_CU",      "GNB_BTS_INFO",
    "MRBTS_ID_CU",          "MRBTS_ID",
    "NRBTS_ID_CU",          "NRBTS_ID",
    "NRCELL_DIST_NAME_CU",  "NRCELL_DIST_NAME",
    "NRCELL_DN_LIST_CU",    "NRCELL_DN_LIST",
    "NRCELL_DN_CU",         "NRCELL_DN",
    "NRCELL_GRP_CU",        "NRCELL_GRP",
    "NRCELL_ID_LIST_CU",    "NRCELL_ID_LIST",
    "NRCELL_ID_CU",         "NRCELL_ID",
    "SCF_SETUP_PATH",       "SCF_CU_SETUP_PATH"
    ]
ListPattern = []

ListImpactedFile = []
BlackListFile = ["AutoRename.py"]


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


# ===========================================================================================================
# PATTERN
# ===========================================================================================================
class Pattern:
    def __init__(self, str):
        self.str = str
        self.occs = []

    def __str__(self):
        return self.str

    @staticmethod
    def initPatternList(inListStr, exListStr):
        inList = inListStr.split(",")
        exList = exListStr.split(",")
        for str in ListPatternStr:
            if (str in inList or inListStr == "ALL") and str not in exList:
                ListPattern.append(Pattern(str))
        for idx, pattern in enumerate(ListPattern):
            info("    PATTERN {:2}/{}: {}".format(idx+1, len(ListPattern), pattern.str))

    def display(self, index):
        str = "PATTERN {:2}/{}: [{}]".format(index+1, len(ListPattern), self.str)
        n = 200 - len(str)
        info(str + "_" * n)
        if len(self.occs) > 0:
            file = ""
            for occ in self.occs:
                if occ.line.file != file:
                    file = occ.line.file
                    info("    FILE:{}".format(file))
                occ.line.display(self)

    def displayStats(self):
        info("      PATTERN:{:30} Occurences:{}".format(self.str, len(self.occs)))


# ===========================================================================================================
# OCC
# ===========================================================================================================
class Occ:
    START_OK = ["{",  # ex:${GNB_DU}                                 : nominal case
                " ",  # ex: " GNB_DU                                 : libelle
                "\"",  # ex: "GNB_DU..."                              : libelle
                "#",  # ex: #GNB_DU                                  : commentaire
                "(",  # ex: (GNB_DU                                  : commentaire
                "<"]  # ex: <MRBTS_ID...                             : commentaire
    START_KO = ["_",  # ex: MODIFIED_SCF_CU_SETUP_PATH}              : autre variable
                ".",  # ex: ${DSS_Counter_Expectation.NRCELL_ID}     : c'est un sous champ
                "S",  # ex: SGNB_DU_ADMISSION_MOD_REQ_SA             : autre variable
                "T",  # ex: ${TGNB_DU[0].oam}                        : code deja remplace
                "t"]  # ex:\tMRBTS_ID=                               : tabulation devant libelle
    END_OK = ["}",  # ex:${NRCELL_ID}                                : fin de variable
              " ",  # ex:GNB_DU and ...                              : dans commentaire
              "\"",  # ex:
              ",",  # ex:such as NRBTS_ID, MRBTS_ID,                 : dans commentaire
              ".",  # ex:${GNB_DU.oam}                               : nominal case avec champ derriere
              ":",  # ex:GNB_DU: ${GNB_DU.name}                      : log to console
              ">",  # ex:<MRBTS_ID> and <NRCELL_DIST_NAME> are ...   : Dans commentaire
              ")"]  # ex:(MRBTS_ID)                                  : Dans commentaire
    END_KO = ["\"",  # ex:self._setGlobalVar(name="GNB_BTS_INFO",    : code special de Oam.py : NE PAS TOUCHER
              "=",  # ex:&{DSS_Counter_Expectation}       NRCELL_ID=1: champ dans un dictionnaire : NE PAS TOUCHER
              "[",  # ex:${NRCELL_ID_LIST[${Cell}-1]}                : debut de tableau: à valider avant
              "_",  # ex:MRBTS_ID_CU                                 : autre variable
              "R"]  # ex:CM_ACTIVATION_GNB_DURATION                  : autre variable

    def __init__(self, line, pattern, pos):
        self.line = line
        self.pattern = pattern
        self.pos = pos

    def __lt__(self, other):
        return self.pos < other.pos

    def isCharValid(self, isStart, c):
        str = "char=[{}] ({}) Start:{} PATTERN=[{}] line=[{}] in {}".\
            format(c, ord(c), isStart, self.pattern.str, self.line.line, self.line.file)
        verbose("DEBUG:{}".format(str))

        if isStart:
            if c in Occ.START_OK:
                return True
            if c in Occ.START_KO:
                return False
            raise Exception("Unexpected {}".format(str))
        else:
            if c in Occ.END_OK:
                return True
            if c in Occ.END_KO:
                return False
            raise Exception("Unexpected {}".format(str))

    def getBefore(self):
        if (self.pos == 0):
            return None
        return self.pos-1

    def getAfter(self):
        pos = self.pos+len(self.pattern.str)
        if (pos == len(self.line.line)):
            return None
        return pos

    def isValid(self):
        before = self.getBefore()
        after = self.getAfter()
        return (before is None or self.isCharValid(isStart=True, c=self.line.line[before])) and \
               (after is None or self.isCharValid(isStart=False, c=self.line.line[after]))


# ===========================================================================================================
# LINE
# ===========================================================================================================
class Line:
    def __init__(self, file, index, line):
        self.file = file
        self.index = index
        self.line = line.replace("\n", "").replace("\r", "")
        self.occs = self.getOccs()

    def hasOccs(self):
        return len(self.occs) > 0

    def getOccsMatchingPattern(self, line, pattern):
        startPos = 0
        listOcc = []
        while True:
            pos = line.find(pattern.str, startPos)
            if pos >= 0:
                occ = Occ(self, pattern, pos)
                if occ.isValid():
                    listOcc.append(occ)
                startPos += pos + 1
            else:
                break
        return listOcc

    def getOccs(self):
        listOccs = []
        for pattern in ListPattern:
            occs = self.getOccsMatchingPattern(self.line, pattern)
            if len(occs) > 0:
                listOccs += occs
        listOccs.sort()
        finalListOccs = []
        for idx, occ in enumerate(listOccs):
            if (idx > 0 and listOccs[idx-1].pos < occ.pos) or (idx == 0):
                finalListOccs.append(occ)
                occ.pattern.occs.append(occ)
        return finalListOccs

    def getColor(self, occ, pattern, hl=True, replace=False):
        if not hl:
            return ""
        if occ.pattern == pattern:
            if replace:
                return "{}{}".format(BG_GREEN, BLACK)
            else:
                return "{}{}".format(BG_YELLOW, BLACK)
        else:
            return "{}{}".format(BG_BLUE, CYAN)

    def getTerminator(self, hl):
        if not hl:
            return ""
        return NORMAL

    def getLine(self, pattern, hl=True, replace=False):
        if len(self.occs) == 0:
            return self.line
        str = ""
        pos = 0
        for idx, occ in enumerate(self.occs):
            if replace:
                newPattern = self.getNewPattern(occ)
            else:
                newPattern = occ.pattern.str
            str += "{}{}{}{}".format(self.line[pos:occ.pos],
                                     self.getColor(occ, pattern, hl, replace),
                                     newPattern,
                                     self.getTerminator(hl))
            pos = occ.pos + len(occ.pattern.str)
        str += self.line[pos:]
        return str

    def getNewPattern(self, occ):
        return "T{}[0]".format(occ.pattern.str)

    def display(self, pattern=None):
        info("        LINE {:4}:[{}]".format(self.index, self.getLine(pattern, hl=True)))
        self.newLine = self.getLine(pattern, hl=False, replace=True)
        if DoReplace:
            info("        REPL {:4}:[{}]".format(self.index, self.getLine(pattern, hl=True, replace=True)))
        return self.newLine + "\n"


# ===========================================================================================================
def readArguments():
    parser = argparse.ArgumentParser(description="", formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("path",  help='path or list pf paths')
    parser.add_argument("-v", "--verbose",  help='More detailed traces on changes done',
                        action='store_true', dest='verbose')
    parser.add_argument("-i", "--include",  help='Specify pattern(s) to include',
                        type=str, required=False, default="ALL")
    parser.add_argument("-e", "--exclude",  help='Specify pattern(s) to exclude',
                        type=str, required=False, default="")
    parser.add_argument("-r", "--replace",  help='Execute REALLY replacement',
                        action='store_true', dest='replace')
    parser.add_argument("-p", "--pause",  help='Execute a keyboard pause after each step',
                        action='store_true', dest='pause')
    return parser.parse_args()


def getSrcFiles(entryPath, extList=[]):
    listFile = []
    for file in os.listdir(entryPath):
        fullPath = os.path.abspath("{}/{}".format(entryPath, file))
        ext = os.path.splitext(fullPath)[1]
        if os.path.isfile(fullPath):
            if ext in extList:
                listFile.append(fullPath)
        if os.path.isdir(fullPath):
            listFile += getSrcFiles(fullPath, extList)
    return listFile


def searchPattern(file):
    TMP_FILE = "/tmp/replacePattern.txt"
    atLeastOneChange = False
    if os.path.basename(file) in BlackListFile:
        info("File won't be parsed (blacklist)")
        return
    src = open(file)
    dst = open(TMP_FILE, "+w")
    for idx, line in enumerate(src.readlines()):
        newLine = line
        treatLine = Line(file, idx+1, line)
        if treatLine.hasOccs():
            atLeastOneChange = True
            newLine = treatLine.display()
        dst.write(newLine)
    src.close()
    dst.close()
    if atLeastOneChange:
        ListImpactedFile.append(file)
        if DoReplace:
            # CODE LINE TO REALLY TO REPLACE IN FINAL FILE !!!!!!
            os.system("mv {} {}".format(TMP_FILE, file))
            # FOR TEST : only copy into .new
            # os.system("mv {} {}.new".format(TMP_FILE, file))


def header(str):
    bar = "=" * 100
    info("{}{}{}{}".format(BG_CYAN, BLUE, bar, NORMAL))
    info("{}{}{:100}{}".format(BG_CYAN, BLUE, str, NORMAL))
    info("{}{}{}{}".format(BG_CYAN, BLUE, bar, NORMAL))


def pause():
    if Pause:
        input("<Press Return>")


# ===========================================================================================================
# MAIN
# ===========================================================================================================
args = readArguments()
Verbose = args.verbose
DoReplace = args.replace
Pause = args.pause
IncludeListStr = args.include
ExcludeListStr = args.exclude
Path = args.path
extList = ['.py', '.robot']
header("1 - CONTEXT")
info("PATH={}".format(Path))
info("INCLUDE={} EXCLUDE={} VERBOSE={} REPLACE={} PAUSE={}".
     format(IncludeListStr, ExcludeListStr, Verbose, DoReplace, Pause))
listSrcFile = getSrcFiles(entryPath=Path, extList=extList)
info("Found {} files matching {}".format(len(listSrcFile), extList))
Pattern.initPatternList(IncludeListStr, ExcludeListStr)
pause()

header("2 - PARSING ALL FILES FROM :{}".format(Path))
for idx, file in enumerate(listSrcFile):
    info("PARSING FILE {:4}/{:4}:{}".format(idx+1, len(listSrcFile), file))
    searchPattern(file=file)
pause()
header("3 - LISTING IMPACTED FILES")
for idx, file in enumerate(ListImpactedFile):
    info("      FILE {}/{}:{}".format(idx+1, len(ListImpactedFile), file))
pause()

header("4 - LISTING PATTERN MATCHING")
for idx, pattern in enumerate(ListPattern):
    pattern.display(idx)
pause()

header("5 - STATICSTICS ON PATTERNS")
for pattern in ListPattern:
    pattern.displayStats()
