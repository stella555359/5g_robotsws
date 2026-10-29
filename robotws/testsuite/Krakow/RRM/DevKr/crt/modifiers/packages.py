import pprint
from robot.api import logger
import sys
import os

cli_args = sys.argv[1:]
PACKAGES_VARIABLE_NAME = 'packages'
MULTIPLE_PACKAGES_SPLITTER = ','
PACKAGE_VERSION_SPLITTER = '-'


class packages(object):
    def __init__(self):
        logger.info('PACKAGES: Analyzing robot cli args:\n{}'.format(pprint.pformat(cli_args)), also_console=True)
        to_update = []
        for argument in cli_args:
            if '{}:'.format(PACKAGES_VARIABLE_NAME) in argument:
                multiple_packages_str = argument.split(':')[1]
                for single_package_version_str in multiple_packages_str.split(MULTIPLE_PACKAGES_SPLITTER):
                    to_update.append(single_package_version_str.split(PACKAGE_VERSION_SPLITTER))
                break
        logger.info('PACKAGES: List of packages to update:\n{}'.format(pprint.pformat(to_update)), also_console=True)
        for (package, version) in to_update:
            os.system('python -m pip install {}=={}'.format(package, version))
        logger.info('PACKAGES: Package installation ended')

    def visit_suite(self, *args, **kwargs):
        pass
