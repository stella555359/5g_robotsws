import os
import ta5g_syslog
import StringTool
from datetime import datetime
import re
import operator
import subprocess

syslog = ta5g_syslog.ta5g_syslog()


# =================================================================================================
# SyslogLine : Line of a syslog file
#              part between < and > contains the timestamp. example : <2022-04-22T15:14:09.555958Z>
# =================================================================================================
class SyslogLine:
    DATETIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%fZ"

    def __init__(self, str):
        self.str = str

    def __str__(self):
        return self.str

    def getNbSec(self):
        if '<' in self.str and '>' in self.str:
            tsStr = self.str.split('<')[1].split('>')[0]
            try:
                return datetime.strptime(tsStr, SyslogLine.DATETIME_FORMAT).timestamp()
            except ValueError:
                return None

    def isError(self, exclusions):
        return (("ERR" in self.str) or ("WRN" in self.str)) and not self.shouldBeExcluded(exclusions)

    def shouldBeExcluded(self, exclusions):
        for pattern in exclusions:
            if pattern.match(self.str):
                pattern.newOcc()
                return True
        return False

    def anonymize(self):
        cleanHex = re.sub("0[xX][0-9a-fA-F]+", "hex*", self.str[41:])
        return re.sub("[0-9]+", "*", cleanHex)


# =================================================================================================
# SyslogFile : File in syslog traces in each line
# =================================================================================================
class SyslogFile:
    EXT = ".log"

    def __init__(self, path, exclusions, maxRate, nolimit=False):
        self.path = path
        self.exclusions = exclusions
        self.maxRate = maxRate
        self.errors = []
        self.dist = {}
        self.noLimit = nolimit

    def open(self):
        self.handle = open(self.path, "r", encoding="iso-8859-1")
        self.min = 1000000000000000000000
        self.max = 0
        self.nbLine = 0
        return self.handle

    def getLine(self):
        try:
            self.line = SyslogLine(self.handle.readline().strip())
            self.nbLine += 1
            self.updateMinMax()
            self.updateDist()
            return self.line
        except UnicodeDecodeError:
            StringTool.datedConsole("ERROR: UnicodeDecodeError on file {}:{}".format(self.path, self.nbLine))
        return None

    def addError(self, log):
        self.errors.append(log)

    def close(self):
        self.handle.close()
        self.duration = self.max - self.min
        self.rate = int(self.nbLine / self.duration)

    def parse(self):
        self.open()
        log = self.getLine()
        while log.str:
            if log.isError(self.exclusions):
                self.addError(log.str)
                if not self.noLimit and len(self.errors) >= Syslog.MAX_OCC:
                    StringTool.datedConsole("ERROR:Exit parsing of SYSYLOG file due to max error reached ({})"
                                            .format(Syslog.MAX_OCC))
                    ExclusionFile.listExclusions(self.exclusions)
                    break
            log = self.getLine()
        self.close()
        if self.rate > self.maxRate:
            self.addError("Too high SYSLOG rate {} traces/sec [max allowed:{}]".format(self.rate, self.maxRate))

    def updateDist(self):
        line = self.line.anonymize()
        if line not in self.dist:
            self.dist[line] = 0
        self.dist[line] += 1

    def updateMinMax(self):
        nbSec = self.line.getNbSec()
        if nbSec is not None:
            self.min, self.max = min(nbSec, self.min), max(nbSec, self.max)

    def synthesis(self):
        return "NB LINE={} ERR={} RATE={} Traces/sec DURATION={} sec"\
            .format(self.nbLine, len(self.errors), self.rate, self.duration)

    def listErrors(self, header):
        if len(self.errors) > 0:
            StringTool.datedConsole("{}:List of ERRORS:".format(header))
            for idx, error in enumerate(self.errors):
                StringTool.datedConsole("   {:2}:{}".format(idx + 1, error))


# =================================================================================================
# StatFile : File with stats on syslogs
# =================================================================================================
class StatFile:
    TS_FORMAT = "%Y%m%d_%Hh%M"

    def __init__(self, syslogFile):
        self.syslogFile = syslogFile
        self.step = 0
        self.path = syslogFile.path.replace(SyslogFile.EXT,
                                            ".{}.STATS{}".format(StatFile.ext(), SyslogFile.EXT))
        StringTool.datedConsole("Generating Stats file:{}".format(self.path))
        self.handle = open(self.path, "w")
        # Synthesis
        self.title("Synthesis")
        self.writeln(syslogFile.synthesis())
        # Occurrence of exclusion patterns
        self.title("Occurrences per exclusion pattern:")
        for exclusion in syslogFile.exclusions:
            if exclusion.occ != 0:
                self.writeln("  {:3};{}".format(exclusion.occ, exclusion.str))
        # Errors
        self.title("Error list:")
        for idx, error in enumerate(syslogFile.errors):
            self.writeln("  {:2}:{}".format(idx + 1, error))
        # Distribution in case of too much traces
        if syslogFile.rate > syslogFile.maxRate:
            self.title("Trace distribution:")
            for trace, occurrence in sorted(syslogFile.dist.items(), key=operator.itemgetter(1), reverse=True):
                self.writeln("  {}: {}".format(occurrence, trace))
        self.handle.close()
        # No more used => put in comment
        # self.sendSyslogToEspooVM(self.path)

    def writeln(self, str):
        self.handle.write("{}\n".format(str))

    def sep(self):
        self.writeln("=" * 100)

    def title(self, str):
        self.step += 1
        self.sep()
        self.writeln("{} - {}".format(self.step, str))
        self.sep()

    def sendSyslogToEspooVM(self, syslogFile):
        # self.destination = 'ca_psci5g@10.183.33.106:/var/fpwork/ca_psci5g/SWENG_Syslog'
        # self.destination = 'ca_psci5g@10.183.36.241:/var/fpwork/ca_psci5g/SWENG_Syslog'
        self.destination = 'ca_psci5g@10.181.49.46:/var/fpwork/ca_psci5g/SWENG_Syslog'
        self.sshpass = 'sshpass -p Welcome123'
        self.options = '-oStrictHostKeyChecking="no" -P 22 -oUserKnownHostsFile="/dev/null" -oLogLevel="QUIET"'
        self.source = syslogFile
        cmd = "{} scp {} {} {}".format(self.sshpass, self.options, self.source, self.destination)
        cmd_return = self.execute_command(cmd)

    def execute_command(self, command):
        pipes = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, stderr = pipes.communicate()
        if pipes.returncode != 0:
            exception = subprocess.CalledProcessError(pipes.returncode, command, output=output)
            error_msg = 'ERROR occurred\nstderr: {}:\nRC: {}'.format(stderr.strip(), pipes.returncode)
            raise exception
        return output.decode('utf-8')

    @staticmethod
    def ext():
        return datetime.now().strftime(StatFile.TS_FORMAT)


# =================================================================================================
# ExclusionPattern : element of exclusion in a file exclusion
#                    Contains a pattern, an associated comment, reference on file exclusion,
#                    and concerned line
# =================================================================================================
class ExclusionPattern:
    def __init__(self, str, comment=None, exclusionFile=None, line=0):
        self.str = str
        self.exclusionFile = exclusionFile
        self.comment = comment
        self.line = line
        self.occ = 0

    def __str__(self):
        file = "{}:{}".format(self.exclusionFile, self.line)
        return "{:25} Occ={:3} Pattern={}".format(file, self.occ, self.str)

    def __eq__(self, other):
        return self.str == other.str

    def match(self, str):
        return self.str in str

    def newOcc(self):
        self.occ += 1


# =================================================================================================
# ExclusionFile : Csv File with a list of exclusion pattern (with associated comment)
#                 Also include directives are allowed : include <Scope>.<file>
#                 where scope in either "SWENG" or a feature name (ex: 5GC001527)
#                 File are searched in <scope>/config/syslog/exclusion directory
#                 Empty lines or lines starting with # are ignored
# =================================================================================================
class ExclusionFile:
    SWENG_DIRNAME = "SWENG"
    EXCLUSION_REL_DIR = "config/syslog/exclusion"
    RESOURCES_DIRNAME = "resources"
    ET_ROOT_REL_DIR = "RRM/ET"
    INCLUDE_KW = "include"

    def __init__(self, exclusion, history):
        self.exclusion = exclusion
        self.filePath = ExclusionFile.exclusionToPath(exclusion)
        self.list = []
        with open(self.filePath) as file:
            for idx, line in enumerate(file.readlines()):
                line = line.strip()
                if len(line) == 0 or line.startswith("#"):
                    continue
                if line.startswith(ExclusionFile.INCLUDE_KW):
                    includeExclusion = line.split(ExclusionFile.INCLUDE_KW)[1].strip()
                    self.list += ExclusionFile(includeExclusion, history + self.list).list
                else:
                    pattern = line.split(";", 1)[1].strip()
                    comment = line.split(";", 1)[0].strip()
                    item = ExclusionPattern(str=pattern, comment=comment, exclusionFile=self, line=idx+1)
                    if item not in self.list and item not in history:
                        self.list.append(item)

    def __str__(self):
        return self.exclusion

    @staticmethod
    def currentPath():
        return os.path.dirname(os.path.abspath(__file__))

    @staticmethod
    def rootToPath(root):
        if root == ExclusionFile.SWENG_DIRNAME:
            rootPath = ExclusionFile.currentPath().split(ExclusionFile.SWENG_DIRNAME)[0]
        else:
            rootPath = "{}{}".format(ExclusionFile.currentPath().split(ExclusionFile.RESOURCES_DIRNAME)[0],
                                     ExclusionFile.ET_ROOT_REL_DIR)
        return "{}/{}/{}".format(rootPath, root, ExclusionFile.EXCLUSION_REL_DIR)

    @staticmethod
    def exclusionToPath(exclusion):
        root = exclusion.split(".")[0]
        path = ExclusionFile.rootToPath(root)
        fileName = exclusion.replace("{}.".format(root), "")
        return "{}/{}".format(path, fileName)

    @staticmethod
    def listExclusions(exclusions):
        StringTool.datedConsole("List of exclusions ({}):".format(len(exclusions)))
        for idx, exclusion in enumerate(exclusions):
            StringTool.datedConsole("  {:2}:{}".format(idx+1, exclusion))


# =================================================================================================
# Syslog : system logs manager. Offer services to start/stop/retrieve syslogs on GNB
#          Syslog files are stored SYSLOG/SYSLOG.<HostAlias>.<Name>.log
#          <Name> is an input argument for file differentiator in case of several files.
#          Can be a step a test name, ...
# =================================================================================================
class Syslog:
    DIRNAME = "SYSLOG"
    PREFIX = "SYSLOG."
    HOSTS = "127.0.0.1"
    MAX_OCC = 10

    def __init__(self, path, name, alias):
        self.path = "{}/{}".format(path, Syslog.DIRNAME)
        self.name = name
        self.alias = alias
        self.start()

    @property
    def header(self):
        return "SYSLOG({}) Name={}".format(self.alias, self.name)

    @property
    def internalPath(self):
        return "{}/{}{}{}".format(self.path, Syslog.PREFIX, Syslog.HOSTS, SyslogFile.EXT)

    @property
    def externalPath(self):
        return "{}/{}{}.{}{}".format(self.path, Syslog.PREFIX, self.alias, self.name, SyslogFile.EXT)

    def trace(self, str):
        StringTool.datedConsole("{}:{}".format(self.header, str))

    def start(self):
        self.trace("START")
        syslog.start_syslog_for_enb(logs_dirpath=self.path,
                                    log_filename_prefix=Syslog.PREFIX,
                                    remote_hosts=Syslog.HOSTS,
                                    alias=self.alias)

    def stop(self):
        self.trace("STOP")
        syslog.stop_syslog(alias=self.alias)
        self.trace("SAVED in {}".format(self.externalPath))
        os.system("mv {} {}".format(self.internalPath, self.externalPath))
        return self.externalPath

    def evaluate(self, exclusion, maxRate=400, nolimit=False):
        exclusions = ExclusionFile(exclusion, []).list
        return self.analyse(exclusions, int(maxRate), nolimit)

    def analyse(self, exclusions, maxRate, nolimit=False):
        syslogFile = SyslogFile(self.externalPath, exclusions, maxRate, nolimit)
        # syslogFile = SyslogFile("/home/ute/Syslog.log", exclusions, maxRate)
        syslogFile.parse()
        syslogFile.listErrors(self.header)
        self.trace(syslogFile.synthesis())
        StatFile(syslogFile)
        return syslogFile.errors


def newSyslog(path, name, alias):
    return Syslog(path, name, alias)
