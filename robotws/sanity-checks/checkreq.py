"""
This script checks whether python requirements stated in a given file are met
by the environment. It takes a path to requirement file as its only argument.
"""

import sys
from pkg_resources import (DistributionNotFound, ContextualVersionConflict,
                           VersionConflict, require)
from collections import namedtuple


ReqCheckResult = namedtuple('ReqCheckResult', ['conflicting', 'outdated',
                                               'not_found'])


def check_requirements(requirements):
    """ Check if requirement list is satisfied by the environment.

    requrements - a list of requirements (e.g. ['sphinx>=2.0.0'])

    Returns ReqCheckResult, with lists of requirements that the environment
    didn't met.
    """
    conflicting = []
    outdated = []
    not_found = []

    for requirement in requirements:
        try:
            require(requirement)
        except ContextualVersionConflict:
            conflicting.append(requirement)
        except VersionConflict:
            outdated.append(requirement)
        except DistributionNotFound:
            not_found.append(requirement)

    return ReqCheckResult(conflicting, outdated, not_found)


def print_banner_line():
    BANNER_LEN = 60
    BANNER_CHAR = '='
    print(BANNER_LEN * BANNER_CHAR)


def print_conflicting_results(results):
    print_banner_line()
    msg = ("These requirements are met, but the environment has\n"
           "conflicting versions of underlying dependencies installed\n"
           "(these conflicts may be intended - no action required):")
    print(msg)
    print_banner_line()
    for conflicting in results.conflicting:
        print('\t' + conflicting)


def print_not_found_results(results):
    print_banner_line()
    print("Requirements that weren't met:")
    print_banner_line()
    for not_found in results.not_found:
        print('\t' + not_found)


def print_outdated_results(results):
    print_banner_line()
    msg = ("For these requirements there are distributions installed,\n"
           "but the versions does not match requirements:")
    print(msg)
    print_banner_line()
    for outdated in results.outdated:
        print('\t' + outdated)


def get_requirements(path):
    with open(path) as requirement_file:
        return requirement_file.read().splitlines()


def main():
    requirements_file_path = sys.argv[1]
    requirements = get_requirements(requirements_file_path)
    results = check_requirements(requirements)

    if results.conflicting:
        print_conflicting_results(results)
    if results.outdated:
        print_outdated_results(results)
    if results.not_found:
        print_not_found_results(results)

    if results.not_found or results.outdated:
        exit(1)
    else:
        exit(0)


if __name__ == '__main__':
    main()
