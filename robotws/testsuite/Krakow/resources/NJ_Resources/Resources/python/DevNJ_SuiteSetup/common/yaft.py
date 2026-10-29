import time
import pexpect
import re
import os
from robot.api import logger
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SuiteSetup.configure.server import *


def parse_yaft_stage(to_parse):
    parsed = re.search("\n\r.+\n\r", to_parse)
    if parsed is not None:
        return str(parsed)
    else:
        return to_parse


def use_yaft(yaft_dir, ip_addr, port, load_file, image_dir):
    logger.debug("Build to YAFT path: " + load_file)
    command = "python {} --ip {} -P {} -d {} --NO_lockfile --ignore_FSPs --ask_for_password --clean_to_default -z {}".\
        format(yaft_dir, ip_addr, port, image_dir, load_file)
    logger.info("Command to run: {}".format(command), also_console=True)

    child = pexpect.spawn(command)

    failed = False

    timeout = 3600
    start_time = time.time()
    while time.time() < start_time + timeout:
        i = child.expect(['(\\*\\*+\r\n.*\r\n.?(\\*)*)', 'Error:.*\r\n', 'Password:', '\\** Script takes .* \\**',
                          pexpect.EOF], timeout=None)
        if i == 0 or i == 1:
            found = str(child.after)
            if re.search("\\*.*FAILED.*\\*", found) or re.search("No space left on device", found):
                # build failed
                failed = True
                logger.info(found, also_console=True)
            else:
                logger.info(parse_yaft_stage(found), also_console=True)

        elif i == 2:
            child.sendline("oZPS0POrRieRtu")
        elif i == 3 or i == 4:
            logger.info("YAFT logfile located at: not yet implemented", also_console=True)
            logger.info(str(child.after))
            break
    else:
        logger.info("Yaft dont finished in {}s".format(timeout), also_console=True)

    if failed:
        return False
    else:
        return True


def yaft(ip_addr, port, loadpkg):
    # Need download yaft package from load server
    if not os.path.exists(yaft_file):
        raise Exception("{} does not exist.".format(yaft_file))

    i = 0
    while i < 1:
        i += 1
        logger.info("Start: yaft at time: {}".format(time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime())),
                    also_console=True)
        success = use_yaft(yaft_dir=yaft_file, ip_addr=ip_addr, port=port, load_file=loadpkg, image_dir=image_dir)
        logger.info("End: yaft at time: {}".format(time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime())),
                    also_console=True)
        if not success:
            logger.info("INFO_AICT: FAILED! yaft upgrade failed, try again after sleep 30s", also_console=True)
            time.sleep(30)
        else:
            break
    else:
        raise Exception("INFO_AICT: FAILED! yaft upgrade failed after try 5 times")
