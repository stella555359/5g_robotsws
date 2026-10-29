from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
from abc import ABCMeta, abstractmethod

"""
Usage:       robot_globals should be imported from this module.
Description: robot_globals is assigned depending on execution context, so that it can be used both
             when using robot framework and pure python using hardcoded values.
"""


class SingletonGlobals(ABCMeta):
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super(SingletonGlobals, cls).__call__(*args, **kwargs)
        return cls._instances[cls]


class AbstractGlobals(object):
    __metaclass__ = ABCMeta

    @abstractmethod
    def execdir(self):
        pass

    @abstractmethod
    def outputdir(self):
        pass

    @abstractmethod
    def testname(self):
        pass

    @abstractmethod
    def suitename(self):
        pass


class HardcodedGlobals(AbstractGlobals):
    __metaclass__ = SingletonGlobals

    def execdir(self):
        print('WARNING: using hardcoded EXECDIR: /home/ute/robotws5g')
        return '/home/ute/robotws5g'

    def outputdir(self):
        print('WARNING: using hardcoded OUTPUTDIR: /home/ute/robotws5g')
        return '/home/ute/robotws5g'

    def testname(self):
        print('WARNING: using hardcoded TESTNAME: TESTNAME')
        return 'TESTNAME'

    def suitename(self):
        print('WARNING: using hardcoded SUITENAME: SUITENAME')
        return 'SUiTENAME'


class RobotGlobals(AbstractGlobals):
    __metaclass__ = SingletonGlobals

    def execdir(self):
        return BuiltIn().get_variable_value('${execdir}')

    def outputdir(self):
        return BuiltIn().get_variable_value('${outputdir}')

    def testname(self):
        return BuiltIn().get_variable_value('${testname}')

    def suitename(self):
        return BuiltIn().get_variable_value('${suitename}')

    def __getattr__(self, item):
        value = self.__dict__.get(item)
        if not value:
            return BuiltIn().get_variable_value('${{{}}}'.format(item))
        return value


try:
    BuiltIn().get_variable_value('${xxx}')  # check if robot is running
    robot_globals = RobotGlobals()
except RobotNotRunningError:
    robot_globals = HardcodedGlobals()
