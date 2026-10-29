import sys
import re
import os
import robot
import operator
import StringTool
import Version

OPS = {
    '<=':  operator.le,
    '<': operator.lt,
    '>=': operator.ge,
    '~=': operator.ge,
    '==': operator.eq,
    '=': operator.eq,
}

ROOT_PROJECT_NAME = "robotws5g"
citOrCrt = "CITorCRT"
localEnv = "Manual Test - local NON-UTE"

# ======================
# This class is used for pip libs checks
# ======================


class PipRequirements:

    @staticmethod
    def convertName(name):
        # converts name_24-test into name24test
        bad_chars = ['_', '.', '-']
        for i in bad_chars:
            name = name.replace(i, '')
        return name

    @staticmethod
    def getRequirementsCfgInList():
        # makes a list of pip from /robotpath/requirements.cfg
        # [[criptograpfy-2,cryptograpgy2,==,230],[taf.sbts.oam.coam.admin,tafsbtsoamcoamadmin,~=,0.42.1,0421]]
        # under discussion how to get robot path path_dir = os.path.split(path_file)[0] ??
        requirementsList = []
        requirementCfgFile = ""
        try:
            robotPath = SystemArguments.getRobotPath()
            if os.path.isdir(robotPath):
                requirementCfgFile = SystemArguments.getRobotPath() + '/requirements.cfg'
                with open(requirementCfgFile, 'r') as pipRequirementsCfg:
                    for line in pipRequirementsCfg.readlines():
                        if line.startswith("#") or len(line.split()) == 0:
                            continue
                        extractInfo = re.findall(r'[a-zA-Z0-9_\-.]'
                                                 r'+[(==|~=|>=|<|<=|>)]+[(\d|\d\d).(\d|\d\d).(\d|\d\d)]+', line)
                        if len(extractInfo) != 0:
                            info = extractInfo[0]
                            name = re.split('==|~=|>=|<|<=|>', info)[0]
                            sign = re.findall(r'[(==|~=|>=|<|<=|>)]+', info)[0]
                            value = re.findall(r'[0-9]{1,4}[.][0-9]{0,3}[.]?[0-9]{0,3}', info)[0]
                            nameWoSpaces = PipRequirements.convertName(name)
                            pipReqDico = {'name': name, 'nameWoSpaces': nameWoSpaces,
                                          'operator': sign, 'value': value,
                                          'convertedVal': PipRequirements.convertName(value)}
                            requirementsList.append(pipReqDico)
            else:
                print("Unknown Robot path - Requirement list cannot be found")
        except IOError as e:
            print('{} Not found. Exception is: {}'.format(requirementCfgFile, e))
        except Exception as e:
            print('Some other problem . Please contact AF: ', e)
        return requirementsList

    @staticmethod
    def getInstalledPipInList():
        # makes a list starting from output of pip freeze
        # [[criptograpfy-2,cryptograpgy2,2.3.0,230],[taf.sbts.oam.coam.admin,tafsbtsoamcoamadmin,0.42.1,0421]]
        try:
            pipList = os.popen("pip freeze")
            pipListLocal = []
            for line in pipList.readlines():
                name = re.split('==', line)[0]
                value = re.findall(r'[0-9]{1,4}[.][0-9]{0,3}[.]?[0-9]{0,3}', line)[0]
                nameWoSpaces = PipRequirements.convertName(name)
                pipReqDico = {'name': name, 'nameWoSpaces': nameWoSpaces,
                              'value': value, 'convertedVal': PipRequirements.convertName(value)}
                pipListLocal.append(pipReqDico)
            pipList.close()
        except Exception as e:
            print('Pip Freeze command is not working:', e)
        return pipListLocal

    @staticmethod
    def checkPipListAlignement():
        # compares pip freeze output with requirements.cfg
        requirementsList = PipRequirements.getRequirementsCfgInList()
        pipList = PipRequirements.getInstalledPipInList()
        pipToUpdate = []
        if requirementsList:
            for reqDico in requirementsList:
                for pipDico in pipList:
                    if reqDico['nameWoSpaces'] == pipDico['nameWoSpaces']:
                        if OPS[reqDico['operator']](int(pipDico['convertedVal']), int(reqDico['convertedVal'])):
                            continue
                        else:
                            msg = "Please update " + pipDico['name'] + " to " + reqDico['value'] + ".The sign was "\
                                  + reqDico['operator'] + ".Your current version is : " + pipDico['value']
                            pipToUpdate.append(msg)
        else:
            pass
        return pipToUpdate

# ======================
# This class analyises system arguments
# ======================


class SystemArguments:

    @staticmethod
    def getSysArgs():
        """
        :return: ['-v', 'CONFIGURATION:Wroclaw.7_16_CLOUDCLASSTL02',
        '-v', 'ENB_BRANCH:SBTS00', '-v', 'ENB_BUILD:SBTS00_ENB_9999_210524_000005',
         '--listener taf.internal.robot.listener.kafka.robot_listener.RobotListener',
         '-C off', '-d ../test_results', '-L TRACE', '-b debug.log',
        '-t', '?1?5GC001347_B_30_FDD 256QAM DL traffic with additional DMRS',
         '-V', '/home/ute/testline_configuration/7_16_CLOUDCLASSTL02',
         'testsuite/RRM/ECE/UE_Call_Setup/5GC001347/5GC001347_5G_FDD_Classical.robot']
        """
        kindOfRun = getKindOfRun()
        sysEnv = []
        argFilePath = "/home/ute/argfile.txt"
        if kindOfRun == citOrCrt and os.path.exists(argFilePath) and os.stat(argFilePath).st_size != 0:
            argFile = open(argFilePath, 'r')
            lines = argFile.readlines()
            for line in lines:
                line = line.replace("\n", "")
                if line.startswith("-t") or line.startswith("-v") or line.startswith("-V"):
                    element = line.split(' ', 1)
                    sysEnv.append(element[0])
                    sysEnv.append(element[1])
                else:
                    sysEnv.append(line)
            argFile.close()
        else:
            sysEnv = sys.argv
        return sysEnv

    @staticmethod
    def getListOfTests():
        """ returns list of tests ['test1','test2',..] """
        myTestIdx = -1
        testList = []
        sysArgs = SystemArguments.getSysArgs()
        for idx, arg in enumerate(sysArgs):
            if idx == myTestIdx:
                testList.append(arg)
            elif arg == "-t":
                myTestIdx = idx+1
        return testList

    @staticmethod
    def findRobotFilePathFromArg():
        """ will return /ebs/xyz/mxyz/robotws5g/testsuite/RRM/ECE/domain/feature/xyz.robot """
        sysArgs = SystemArguments.getSysArgs()
        lastSysArg = sysArgs[-1]
        if lastSysArg.endswith(".robot"):
            return lastSysArg
        return ""

    @staticmethod
    def getRobotPath():
        # returns /??/xyz/mxyz/robotws5g/
        return os.path.abspath(__file__).split(ROOT_PROJECT_NAME)[0] + ROOT_PROJECT_NAME

    @staticmethod
    def splitRobotPath():
        """ returns a list ['ebs','xyz','testsuite','RRM','ECE','domain','feature','xyz.robot'] """
        robotPath = SystemArguments.findRobotFilePathFromArg()
        robotPathList = re.split('/', robotPath)
        return robotPathList

    @staticmethod
    def getRobotFileName():
        """ returns name.robot """
        robotFilePath = SystemArguments.findRobotFilePathFromArg()
        robotFileName = os.path.basename(robotFilePath)
        return robotFileName

    @staticmethod
    def getFeatureDomain():
        """ returns a dico {'domain':'Beamforming','feature':'5GC00xyz'} """
        splittedRobotPath = SystemArguments.splitRobotPath()
        domainIndex = 0
        featureIndex = 0
        domainAndFeature = {}
        for idx, element in enumerate(splittedRobotPath):
            if element == 'ECE':
                domainIndex = idx+1
            elif idx == domainIndex:
                if element.startswith('CNI') | element.startswith('5GC'):
                    domainAndFeature = {'domain': '', 'feature': element}
                else:
                    domainAndFeature = {'domain': element, 'feature': ''}
                    featureIndex = idx+1
            elif idx == featureIndex:
                domainAndFeature['feature'] = element
        return domainAndFeature


def getPyRoboWiresharkVersion():
    """ will return a list [pythonVersion,robotVersion,wireshark_ver] """
    pythonVersion = str(sys.version).replace("\n", " ")
    robotVersion = robot.version.get_version()
    f = os.popen("wireshark -version | grep Wireshark")
    wireshark_ver = f.read().replace("\n", " ")
    f.close()
    pyRoboWsharkVersion = {'pythonV': pythonVersion, 'robotV': robotVersion, 'wsharkV': wireshark_ver}
    return pyRoboWsharkVersion


def getSherpaVersion():
    """
    :return: will return sherpa version
    """
    sherpaVersion = ""
    if os.path.exists("/opt/Nokia"):
        try:
            f = os.popen("cd /opt/Nokia/Sherpa_5G_18/;./Sherpa.run --version")
            lines = f.readlines()
            for line in lines:
                if line.startswith("Sherpa5G"):
                    line = line.replace("\n", " ")
                    sherpaVersion = line
            f.close()
        except Exception as e:
            print("Sherpa Version cannot be get: ", e)
    return sherpaVersion


def getCurrentGitStatusComplete():
    """ will return :On branch myreportbranch or master """
    currentGitStatus = ''
    try:
        robotPath = SystemArguments.getRobotPath()
        kindOfRun = getKindOfRun()
        if kindOfRun != citOrCrt:
            if os.path.isdir(robotPath):
                f = os.popen("cd "+SystemArguments.getRobotPath()+";git status")
                currentGitStatus = f.readlines()[1]
                f.close()
            else:
                print("Unknown robot path - git status cannot be retreived")
        else:
            currentGitStatus = 'master'
    except Exception as e:
        print('Please contact AF dev. Git status is not working in this configuration: ', e)
    return StringTool.getStringFromCmdReturn(currentGitStatus)


def getKindOfRun():
    """ will return Launched with Jenkins / UTE env /non-UTE /CIT CRT """
    robotPath = SystemArguments.getRobotPath()
    if os.path.isdir(robotPath):
        kindOfRun = ''
        if 'CrtRoot' in robotPath:
            kindOfRun = 'Jenkins'
        elif 'NpsTest' in robotPath:
            kindOfRun = 'VM UTElike'
        elif robotPath.startswith('/ebs'):
            kindOfRun = localEnv
        elif 'Auto5G' in robotPath:
            kindOfRun = citOrCrt
        elif 'home/ute/robo' in robotPath:
            kindOfRun = 'VM UTE'
        else:
            print("Unknown configuration - please investigate this")
    else:
        kindOfRun = "None"
    return kindOfRun


def myPrint(name, val):
    StringTool.datedConsole(StringTool.getHeaderLine(name, val))


def warningPython2(pythonVer):
    if pythonVer.startswith("2"):
        head = "+---------------------------------------------------------------------------------------"
        head += "----------------------------------------+"
        msg = "| BE CAREFUL: Starting from 04/2020, It is HIGHLY RECOMMENDED to migrate to python 3.6.8 !!! "
        msg += "See Davide for any support on this |"
        StringTool.console('\033[41m' + '\033[30m' + head + '\033[0m')
        StringTool.console('\033[41m' + '\033[30m' + msg + '\033[0m')
        StringTool.console('\033[41m' + '\033[30m' + head + '\033[0m')


def generateReport(TLConfig):
    StringTool.printLineWithTitle("Global/system information")
    try:
        pyRobWshark = getPyRoboWiresharkVersion()
        pythonVer = pyRobWshark.get('pythonV')
        warningPython2(pythonVer)
        robotVer = pyRobWshark.get('robotV')
        wSharkVer = pyRobWshark.get('wsharkV')
        testLineReference = TLConfig.configName
        robotFileName = SystemArguments.getRobotFileName()
        cmdArgs = SystemArguments.findRobotFilePathFromArg()
        listOfTests = SystemArguments.getListOfTests()
        cardNbTest = len(listOfTests)
        if cardNbTest == 0:
            cardNbTest = "ALL"
        featureDomain = SystemArguments.getFeatureDomain()
        pipChecks = PipRequirements.checkPipListAlignement()
        myPrint("SYS:SWENG Version", Version.SWENG_VERSION)
        myPrint("SYS:Python Version", pythonVer)
        myPrint("SYS:Robot Version", robotVer)
        myPrint("SYS:Wireshark Version", wSharkVer)
        myPrint("CTX:Sherpa Version", getSherpaVersion())
        myPrint("CTX:Way of test execution", getKindOfRun())
        myPrint("CTX:Git Status", getCurrentGitStatusComplete())
        myPrint("CTX:Requirements.cfg misalignment", "")
        for idx, check in enumerate(pipChecks):
            myPrint("    Package {}".format(idx+1), check)
        myPrint("CMD:Test Line Reference", testLineReference)
        myPrint("CMD:Robot File Name", robotFileName)
        myPrint("CMD:Tests to be executed", cardNbTest)
        for idx, test in enumerate(listOfTests):
            myPrint("    Test {}".format(idx+1), test)
        myPrint("CMD:Command robot path", cmdArgs)
        myPrint("CMD:Tests Domain", featureDomain['domain'])
        myPrint("CMD:Feature", featureDomain['feature'])
    except Exception as e:
        print("Something went wrong, report was not generated: ", e)
