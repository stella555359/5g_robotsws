from robot.libraries.BuiltIn import BuiltIn


class TestCaseRequirement(object):
    """
    This class is responsible for the compliance with dependencies between TCs. This results in dependent TC's failing,
    when a prerequisite failed but only a warning message will be displayed if a prerequisite was not run in
    the current scope
    of a testsuite

    The :func:`requires_tc` method is dedicated for use in the TC's [Setup] section.

      :Example:

      | Example dependent TC
      | | [Setup] | Requires TC | required TC
      | | some keywords

    """
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.test_status = {}

    def requires_tc(self, name):
        """
        :param name: here goes required TC's name
        :return: status depending on the required TC's result
        """
        test_name_lower_case = name.lower()
        if test_name_lower_case not in self.test_status:
            BuiltIn().log('required TC not run during this testsuite execution: {}'.format(name), "WARN")
        elif self.test_status[test_name_lower_case] != "PASS":
            BuiltIn().fail('required TC failed: {}'.format(name))

        return True
