import sys
import re
import os
import robot
import operator
import StringTool
import Version
import packaging.version
import importlib.metadata
import traceback

OPS = {
    '<=':  operator.le,
    '<': operator.lt,
    '>=': operator.ge,
    '~=': operator.ge,
    '==': operator.eq,
    '=': operator.eq,
}

ROOT_PROJECT_NAME = "robotws"
citOrCrt = "CITorCRT"
localEnv = "Manual Test - local NON-UTE"

# ======================
# This class is used for pip libs checks
# ======================


class PipRequirements:
    # Cache duration in minutes - if pip was updated within this time, skip update
    CACHE_DURATION_MINUTES = 60

    @staticmethod
    def convertName(name):
        # converts name_24-test into name24test and normalizes to lowercase
        bad_chars = ['_', '.', '-']
        for i in bad_chars:
            name = name.replace(i, '')
        return name.lower()

    @staticmethod
    def getRequirementsCfgInList():
        """
        Parses requirements.cfg and returns a list of dicts for each requirement.
        Each dict contains: name, nameWoSpaces, operator, value, convertedVal.
        Handles multiple version specifiers per line and includes only packages with a version.
        """
        requirementsList = []
        requirementCfgFile = ""
        try:
            robotPath = SystemArguments.getRobotPath()
            if os.path.isdir(robotPath):
                requirementCfgFile = os.path.join(robotPath, 'requirements.cfg')
                with open(requirementCfgFile, 'r') as pipRequirementsCfg:
                    for line in pipRequirementsCfg:
                        orig_line = line
                        line = line.strip()
                        if not line or line.startswith("#"):
                            continue
                        # Remove inline comments
                        line = line.split("#")[0].strip()
                        # Extract package name and version specifiers
                        match = re.match(r'^([a-zA-Z0-9_.\-]+)(.*)$', line)
                        if not match:
                            continue
                        name = match.group(1)
                        version_part = match.group(2)
                        # Find all version specifiers (e.g. <4.1.0, >=4.0.4)
                        versions = re.findall(r'([<>=!~]+)\s*([\d\.]+)', version_part)
                        nameWoSpaces = PipRequirements.convertName(name)
                        if versions:
                            for operator_str, value in versions:
                                pipReqDico = {
                                    'name': name,
                                    'nameWoSpaces': nameWoSpaces,
                                    'operator': operator_str,
                                    'value': value,
                                    'convertedVal': PipRequirements.convertName(value)
                                }
                                requirementsList.append(pipReqDico)
        except IOError as e:
            StringTool.console(f"[DEBUG] IOError: {requirementCfgFile} Not found. Exception is: {e}")
            StringTool.console(f"{requirementCfgFile} Not found. Exception is: {e}")
        except Exception as e:
            StringTool.console(f"[DEBUG] Exception in getRequirementsCfgInList: {e}")
            StringTool.console(f"Error in getRequirementsCfgInList: {e}")
            StringTool.console(traceback.format_exc())
        return requirementsList

    @staticmethod
    def updateRequirementsWithLockVersions(requirementsList, python_version):
        """
        For each requirement in requirementsList, update the 'value' field with the version found in the
        dependencies.py*-rf*.lock file for the given python_version (e.g., 'py310', 'py311', 'py312', 'py39').
        """
        import glob
        try:
            # Find the correct lock file
            py_tag = f"py{python_version.replace('.', '')}"
            lock_files = glob.glob(os.path.join(SystemArguments.getRobotPath(), f"dependencies.{py_tag}-rf*.lock"))
            if not lock_files:
                # fallback: try to find any matching lock file with the python tag
                path_lock = os.path.join(SystemArguments.getRobotPath(), "dependencies.py*-rf*.lock")
                lock_files = [f for f in glob.glob(path_lock) if py_tag in os.path.basename(f)]
                lock_files = [f for f in lock_files if py_tag in f]
            if not lock_files:
                print(f"No lock file found in Robotws root dir for Python version {python_version} (tag: {py_tag})")
                return requirementsList
            lock_file = lock_files[0]
            # Parse the lock file for package versions
            lock_versions = {}
            with open(lock_file, "r") as lf:
                for line in lf:
                    line = line.strip()
                    if not line or line.startswith("#"):
                        continue
                    if "==" in line:
                        pkg, ver = line.split("==", 1)
                        lock_versions[pkg.lower()] = ver.strip()
                    elif ">=" in line or "<=" in line or "~=" in line or "<" in line or ">" in line or "=" in line:
                        # handle other version specifiers if needed
                        parts = re.split(r"(==|~=|>=|<=|<|>|=)", line, maxsplit=1)
                        if len(parts) >= 3:
                            pkg = parts[0].strip()
                            ver = parts[2].strip()
                            lock_versions[pkg.lower()] = ver
            # Update requirementsList with locked versions
            for req in requirementsList:
                pkg_name = req['name'].lower()
                if pkg_name in lock_versions:
                    req['value'] = lock_versions[pkg_name]
                    req['convertedVal'] = PipRequirements.convertName(lock_versions[pkg_name])
        except Exception as e:
            print(f"Error updating requirements with lock versions: {e}")
            traceback.print_exc()
            print("Continuing with original requirementsList")
        return requirementsList

    @staticmethod
    def getInstalledPackagesList():
        """
        Returns a list of dicts for each installed package using importlib.metadata.
        Each dict contains: name, nameWoSpaces, value (version), convertedVal.
        """
        pipListLocal = []
        try:
            for dist in importlib.metadata.distributions():
                name = dist.metadata['Name'] if 'Name' in dist.metadata else dist.metadata['name']
                value = dist.version
                nameWoSpaces = PipRequirements.convertName(name)
                pipReqDico = {
                    'name': name,
                    'nameWoSpaces': nameWoSpaces,
                    'value': value,
                    'convertedVal': PipRequirements.convertName(value)
                }
                pipListLocal.append(pipReqDico)
        except Exception as e:
            print('Could not get installed packages:', e)
        return pipListLocal

    @staticmethod
    def shouldSkipLibraryUpdate(python_version):
        """
        Check if library update should be skipped based on:
        1. Recent pip install log exists
        2. requirements.cfg hasn't been modified since last install
        Returns: (should_skip, reason)
        """
        import glob
        import time

        try:
            robot_path = SystemArguments.getRobotPath()
            if not os.path.isdir(robot_path):
                return (False, "Robot path not found")

            # Find pip install log files
            log_pattern = "/tmp/pip3_install.*.log"
            log_files = glob.glob(log_pattern)

            if not log_files:
                return (False, "No previous pip install log found")

            # Get the most recent log file
            latest_log = max(log_files, key=os.path.getmtime)
            log_time = os.path.getmtime(latest_log)

            # Check requirements.cfg modification time
            req_file = os.path.join(robot_path, "requirements.cfg")
            if not os.path.exists(req_file):
                return (False, "requirements.cfg not found")

            req_time = os.path.getmtime(req_file)

            # Calculate time differences
            current_time = time.time()
            time_since_install = (current_time - log_time) / 60  # in minutes

            # Skip if recent install AND requirements.cfg is older than log
            if time_since_install < PipRequirements.CACHE_DURATION_MINUTES and req_time <= log_time:
                return (True, f"Libraries updated {time_since_install:.1f} minutes ago, requirements.cfg unchanged")

            # Don't skip if requirements.cfg was modified after last install
            if req_time > log_time:
                return (False, f"requirements.cfg modified after last install")

            return (False, f"Last install was {time_since_install:.1f} minutes ago (cache expired)")

        except Exception as e:
            print(f"Error checking library update cache: {e}")
            return (False, f"Cache check failed: {e}")

    @staticmethod
    def checkPipListAlignement(python_version=None, updateLibraries=True):
        # Check if we should skip library update based on cache
        if updateLibraries:
            should_skip, reason = PipRequirements.shouldSkipLibraryUpdate(python_version)
            if should_skip:
                print(f"Skipping library update: {reason}")
                updateLibraries = False  # Override to skip actual updates

        requirementsList = PipRequirements.getRequirementsCfgInList()
        if python_version:
            requirementsList = PipRequirements.updateRequirementsWithLockVersions(requirementsList, python_version)
        pipList = PipRequirements.getInstalledPackagesList()  # Use new method
        pipToUpdate = []
        pipToUpdateBeforeUpdate = []  # Track misalignments before update
        updateFailed = []
        updateOk = []
        if requirementsList:
            for reqDico in requirementsList:
                # Only check requirements with a supported operator
                if not reqDico['operator'] or reqDico['operator'] not in OPS:
                    continue
                for pipDico in pipList:
                    # Use full package name for matching
                    if reqDico['nameWoSpaces'] == pipDico['nameWoSpaces']:
                        needsUpdate = PipRequirements.versions_compare(reqDico, pipDico, pipToUpdate)
                        # If updateLibraries is True and package needs update, try to update it
                        if updateLibraries and needsUpdate:
                            success = PipRequirements.updatePackage(pipDico['name'], reqDico['value'], python_version)
                            if not success:
                                updateFailed.append(f"{pipDico['name']} update to {reqDico['value']} failed")
                            else:
                                updateOk.append(f"{pipDico['name']} successfully updated to {reqDico['value']}")
        # Store misalignments found before update
        pipToUpdateBeforeUpdate = pipToUpdate.copy()
        # Refresh pipList after updates to re-check alignment
        if updateLibraries:
            pipList = PipRequirements.getInstalledPackagesList()
            pipToUpdate = []
            if requirementsList:
                for reqDico in requirementsList:
                    if not reqDico['operator'] or reqDico['operator'] not in OPS:
                        continue
                    for pipDico in pipList:
                        if reqDico['nameWoSpaces'] == pipDico['nameWoSpaces']:
                            PipRequirements.versions_compare(reqDico, pipDico, pipToUpdate)
        # Return misalignments found before update (to show what was wrong) plus any remaining issues
        return pipToUpdateBeforeUpdate + updateFailed, updateOk

    @staticmethod
    def versions_compare(reqDico, pipDico, pipToUpdate):
        """Returns True if package needs update, False otherwise"""
        try:
            installed_ver = packaging.version.parse(pipDico['value'])
            required_ver = packaging.version.parse(reqDico['value'])
            if OPS[reqDico['operator']](installed_ver, required_ver):
                return False  # Version is compliant
            else:
                msg = f"Please update {pipDico['name']} to {reqDico['value']}. Current: {pipDico['value']}"
                pipToUpdate.append(msg)
                return True  # Needs update
        except Exception as e:
            pipToUpdate.append(f"Version comparison failed for {pipDico['name']}: {e}")
            return False

    @staticmethod
    def updatePackage(package_name, target_version, python_version):
        """
        Attempts to update a package to the target version using pip.
        Uses the appropriate lock file based on python_version.
        Creates a timestamp log file for cache management.
        Returns True if successful, False otherwise (best-effort).
        """
        import subprocess
        import time
        try:
            print(f"[INFO] Attempting to update {package_name} to {target_version}...")
            # Construct the package specification
            package_spec = f"{package_name}=={target_version}"

            # Create log file path with timestamp
            log_file = f"/tmp/pip3_install.{int(time.time())}.log"

            # Run pip install command
            result = subprocess.run(
                [sys.executable, "-m", "pip", "install", package_spec, "--upgrade"],
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )

            # Write result to log file
            with open(log_file, 'w') as f:
                f.write(f"Package: {package_name}\n")
                f.write(f"Target Version: {target_version}\n")
                f.write(f"Timestamp: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write(f"Return Code: {result.returncode}\n")
                f.write(f"STDOUT:\n{result.stdout}\n")
                f.write(f"STDERR:\n{result.stderr}\n")

            if result.returncode == 0:
                print(f"[SUCCESS] Updated {package_name} to {target_version}")
                return True
            else:
                print(f"[WARNING] Failed to update {package_name}: {result.stderr}")
                return False
        except subprocess.TimeoutExpired:
            print(f"[WARNING] Timeout while updating {package_name}")
            return False
        except Exception as e:
            print(f"[WARNING] Exception while updating {package_name}: {e}")
            traceback.print_exc()
            return False

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
         'testsuite/Paris/RRM/ET/5GC001347/5GC001347_5G_FDD_Classical.robot']
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
        """ will return /ebs/xyz/mxyz/robotws/testsuite/Paris/RRM/domain/feature/xyz.robot """
        sysArgs = SystemArguments.getSysArgs()
        lastSysArg = sysArgs[-1]
        if lastSysArg.endswith(".robot"):
            return lastSysArg
        return ""

    @staticmethod
    def getRobotPath():
        # returns /??/xyz/mxyz/robotws/
        return os.path.abspath(__file__).split(ROOT_PROJECT_NAME)[0] + ROOT_PROJECT_NAME

    @staticmethod
    def splitRobotPath():
        """ returns a list ['ebs','xyz','testsuite','Paris','RRM','domain','feature','xyz.robot'] """
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
            if element == 'RRM':
                domainIndex = idx+1
            elif idx == domainIndex:
                if element.startswith('CNI') | element.startswith('5GC') | element.startswith('CB'):
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


def getKindOfRun(errorToBeDisplayed=False):
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
            kindOfRun = 'VM UTE Standard'
        elif robotPath.startswith('/home/ute/'):
            kindOfRun = 'VM UTE Other'
        else:
            if errorToBeDisplayed:
                print("Unknown configuration - please investigate this")
    else:
        kindOfRun = "None"
    return kindOfRun


def report_print(name, val, isConsole=True):
    StringTool.datedConsole(StringTool.getHeaderLine(name, val), isConsole=isConsole)


def warning_obsolete_python(pythonVer):
    head = "+=============================================================================================="
    head += "========================================+"
    msg = "| BE CAREFUL: Starting from november 2025, It is HIGHLY RECOMMENDED to migrate to python >= 3.11.9 !!!"
    msg += "See with AF team for any support on this |"
    obsolete_versions = ["2", "3.6", "3.7", "3.8", "3.9", "3.10"]
    condition = any(pythonVer.startswith(ver) for ver in obsolete_versions)
    if condition:
        StringTool.console('\033[41m' + '\033[30m' + head + '\033[0m')
        StringTool.console('\033[41m' + '\033[30m' + msg + '\033[0m')
        StringTool.console('\033[41m' + '\033[30m' + head + '\033[0m')


def reportTestEnvironment(TLConfig, isConsole=True, updateLibraries=True):
    print(f"reportTestEnvironment called with TLConfig: {TLConfig}, isConsole: {isConsole}, "
          f"updateLibraries: {updateLibraries}")
    if isConsole:
        StringTool.printLineWithTitle("Global/system information")
    try:
        pyRobWshark = getPyRoboWiresharkVersion()
        pythonVer = pyRobWshark.get('pythonV')
        if isConsole:
            warning_obsolete_python(pythonVer)
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
        noPythonUpdate = os.environ.get('NO_PYTHON_UPDATE', '')
        if noPythonUpdate.lower() in ['true', '1', 'yes']:
            pythonUpdateStatus = "Disabled (NO_PYTHON_UPDATE=True)"
        else:
            pythonUpdateStatus = "Enabled"
        pipChecks, updatedLibs = PipRequirements.checkPipListAlignement(
            python_version=pythonVer, updateLibraries=updateLibraries)
        report_print("SYS:SWENG Version", Version.SWENG_VERSION, isConsole=isConsole)
        report_print("SYS:Python Version", pythonVer, isConsole=isConsole)
        report_print("SYS:Robot Version", robotVer, isConsole=isConsole)
        report_print("SYS:Wireshark Version", wSharkVer, isConsole=isConsole)
        report_print("CTX:Way of test execution", getKindOfRun(True), isConsole=isConsole)
        report_print("CTX:Git Status", getCurrentGitStatusComplete(), isConsole=isConsole)
        report_print("CTX:Python Libraries Update", pythonUpdateStatus, isConsole=isConsole)
        report_print("CTX:Requirements.cfg misalignment", "" if pipChecks else "NO MISALIGNEMENT", isConsole=isConsole)
        for idx, check in enumerate(pipChecks):
            report_print("    Package {}".format(idx+1), check, isConsole=isConsole)
        report_print("CTX:Updated Libraries", "" if updatedLibs else "NO LIBRARY UPDATED", isConsole=isConsole)
        for idx, updated in enumerate(updatedLibs):
            report_print("    Updated Package {}".format(idx+1), updated, isConsole=isConsole)
        report_print("CMD:Test Line Reference", testLineReference, isConsole=isConsole)
        report_print("CMD:Robot File Name", robotFileName, isConsole=isConsole)
        report_print("CMD:Tests to be executed", cardNbTest, isConsole=isConsole)
        for idx, test in enumerate(listOfTests):
            report_print("    Test {}".format(idx+1), test, isConsole=isConsole)
        report_print("CMD:Command robot path", cmdArgs, isConsole=isConsole)
        report_print("CMD:Tests Domain", featureDomain['domain'], isConsole=isConsole)
        report_print("CMD:Feature", featureDomain['feature'], isConsole=isConsole)
    except Exception as e:
        print("Something went wrong, report was not generated: ", e)
