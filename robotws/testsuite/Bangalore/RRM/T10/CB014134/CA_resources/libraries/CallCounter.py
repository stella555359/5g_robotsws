# -*- coding: utf-8 -*-
"""
Robotframework library for counting keyword calls during test suite execution
"""
import collections
import logging

from robot.libraries.BuiltIn import BuiltIn, register_run_keyword

logger = logging.getLogger(__name__)


class CallCounter:
    ROBOT_LIBRARY_SCOPE = "TEST SUITE"
    ROBOT_LIBRARY_DOC_FORMAT = "reST"
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self

        self.counters = collections.defaultdict(int)

    def _start_keyword(self, name, attributes):
        kwname = attributes["kwname"].lower()
        self.counters[kwname] += 1

    def _never_called(self, name):
        return not self.counters[name.lower()]

    def run_keyword_unless_was_run_before(self, name, *args):
        """Run the given keyword with the given arguments only if never ran before.

        A rough equivalent of wrapping *every single keyword* in a following way:

        .. sourcecode:: robotframework

            *** Keywords ***
            Keyword
                # do stuff

            Wrapped Keyword
                RUN KEYWORD IF    not ${Keyword Was Run Before}
                ...    RUN KEYWORDS
                ...    Keyword
                ...    AND    SET SUITE VARIABLE    ${Keyword Was Run Before}    ${TRUE}

        Use this keyword to make sure that keyword will not be run multiple times
        during single suite execution.

        Note that using this keyword does not prevent you from executing keywords with
        name embedded arguments multiple times.

        In following example, both messages will be logged once:

        .. sourcecode:: robotframework

            *** Test Cases ***
            Log Message Once
                Say "Hi!" to Pekka
                Run Keyword Unless Was Run Before    Say "Hi!" to Pekka
                Run Keyword Unless Was Run Before    Say "Bye!" to Rajeev
                Run Keyword Unless Was Run Before    SAY "BYE!" TO RAJEEV

            *** Keywords ***
            Say ${message} to ${person}
                Log    @${person}: ${message}

        Note: keyword name is case insensitive.
        """
        if self._never_called(name):
            BuiltIn().run_keyword(name, *args)
        else:
            logger.info("Skipping execution of `{}` keyword.".format(name))


register_run_keyword(
    "CallCounter", CallCounter.run_keyword_unless_was_run_before.__name__, 1, False
)
