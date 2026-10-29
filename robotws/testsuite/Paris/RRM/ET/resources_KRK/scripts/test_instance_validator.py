#!/usr/bin/python3
"""
:copyright: Nokia Networks
:author: Dawid Chuchnowski  <dawid.chuchnowski@nokia.com>
:maintainer: Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
"""

import datetime
import os
import re
import requests
import smtplib
import sys
from dataclasses import dataclass
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


output_dict = {}

"""
Script for verifying QC Test Instances. Requires activated test_repo virtual environment.

Example of usage:
python test_instance_validator.py [PowerBI token] [email address]   (Note: email address is optional)

Script validates:
- repository path in AO
- suite existence (based on path provided in AO)
- test existence in test suite
- test options, version and timeout
- platform
- test entity
- test level and area
- competence area and organization
- Detailed Automation Level
- test subarea
- backlog ID and feature
- approve state
"""


class MissingToken(Exception):
    """Exception raised when PowerBI token is not provided i.e. no arguments are provided"""


if len(sys.argv) == 1:
    print('Missing powerBI token argument. \nExample of usage: \n    python test_instance_validator.py [PowerBI token] '
          '[email address]     (Note: email address is optional)\n')
    raise MissingToken


@dataclass
class TestInstance:
    full_name: str
    name: str
    repo_path: str
    suite_path: str
    tc_name_AO: str
    test_options: list
    res_tester: str
    version: str
    timeout: str
    platform: str
    topology: str
    test_entity: str
    test_lab_path: str
    test_lvl_area: str
    ca: str
    org: str
    dal: str
    approval: str
    test_subarea: str
    variant: str
    backlog_ids: str
    feature: str
    terminal: str


def get_all_test_instances():
    """
    Fetches QC test instance data
    """
    token = sys.argv[1]
    response = requests.get(
        f"https://rep-portal.wroclaw.nsn-rdnet.net/api/qc-beta/instances/batch/powerbi.1698933650897.json?ti_scope=true"
        f"&origin__domain__pos_neg=MN_RAN&origin__project__pos_neg=RAN_ET&m_path__pos_neg=Root%5CTest_Sets%5CTrunk"
        f"%5CRAN_L2_SW_KRK_1%5C&limit=5000&fields=id%2Cm_path%2Ctest_set__name%2Cname%2Curl%2Cstatus%2Cstatus_color"
        f"%2Cplatform%2Ctest_subarea%2Cautomation_options__test_options%2Ctest_object%2Ctest_entity%2Ctest_lvl_area"
        f"%2Cca%2Corganization%2Cphase%2Cdet_auto_lvl%2Cres_tester%2Cfeature%2Cbacklog_id%2Crequirement"
        f"%2Cfault_report_id_link%2Csuspended%2Cautomation_options%2Cautomation_options__version"
        f"%2Cautomation_options__repository_name%2Cautomation_options__repository_file_path"
        f"%2Cautomation_options__test_case_name%2Cautomation_options__timeout%2Cterminal%2Ctest_case__approval"
        f"%2Ctest_model&powerBIToken={token}")
    results = response.json()['results']
    return results


def create_test_instance_dataclass(tc):
    test_instance = TestInstance(full_name=tc['name'],
                                 name=_remove_prefix_from_tc(tc['name']),
                                 repo_path=tc['automation_options']['repository_name'],
                                 suite_path=f"/home/ute/{tc['automation_options']['repository_name']}/"
                                 f"{tc['automation_options']['repository_file_path']}",
                                 tc_name_AO=_remove_prefix_from_tc(tc['automation_options']['test_case_name']),
                                 test_options=tc['automation_options']['test_options'],
                                 res_tester=tc['res_tester'],
                                 version=tc['automation_options']['version'],
                                 timeout=tc['automation_options']['timeout'],
                                 platform=tc['platform'],
                                 topology=_get_tl_type_from_AO(tc),
                                 test_entity=tc['test_entity'],
                                 test_lab_path=tc['m_path'],
                                 test_lvl_area=tc['test_lvl_area'],
                                 ca=tc['ca'],
                                 org=tc['organization'],
                                 dal=tc['det_auto_lvl'],
                                 approval=tc['test_case']['approval'],
                                 test_subarea=tc['test_subarea'],
                                 variant=''.join([to for to in tc['automation_options']['test_options'] if
                                                  to.startswith('VARIANT')]) or 'None',
                                 backlog_ids=' '.join([x['id'] for x in tc['backlog_id']]),
                                 feature=tc['feature'],
                                 terminal=tc['terminal'])
    return test_instance


def check_AO_paths(tc_name, repo_path, suite_path):
    """
    Verifies file path provided in Automation Options.
    """

    if os.path.isdir(f"/home/ute/{repo_path}") and repo_path == 'MN/UTE/robotws':
        if os.path.isfile(suite_path):
            with open(suite_path, 'r') as file:
                if tc_name not in file.read():
                    output_dict[ti.name]['problems'].append(f'Test name not found in suite path provided in AO '
                                                            f'({suite_path})')
        else:
            output_dict[ti.name]['problems'].append(f'Wrong suite path in AO - file {suite_path} not exist')
    else:
        output_dict[ti.name]['problems'].append('Wrong repository path in AO - should be MN/UTE/robotws')


def _remove_prefix_from_tc(tc):
    return tc[tc.rfind(']') + 1:].strip()


def check_AO_test_case_name(name, tc_name_AO):
    """
    Compares test name from AO with 'Name' of test instance.
    """
    if tc_name_AO != name:
        output_dict[ti.name]['problems'].append(f'Test name provided in AO does not match test instance name '
                                                f'({tc_name_AO} vs {name}')


def check_AO_test_options(suite_path, test_options):
    """
    Verifies that test options are filled and checks that mandatory tags are present.
    """

    mandatory_tags = ['OPTION_RELATED_ARTIFACTS_5G', 'PY39']
    optional_tags = ['STATE_CONFIGURED', 'SKIP_INSTALL_TOOLS', 'SKIP_INSTALL_MCSHARK', 'SKIP_INSTALL_WTS',
                     'SKIP_INSTALL_TTI_DEC', 'SKIP_INSTALL_TTI_TRACE', 'SKIP_INSTALL_TTI_TRACER',
                     'TOOLS_PROFILE_TTI_LEGACY']
    if test_options:
        if set(mandatory_tags) - set(test_options):
            output_dict[ti.name]['problems'].append(f'Missing test options: '
                                                    f'{set(mandatory_tags) - set(test_options)}')
        elif 'CLOUD' not in ' '.join(test_options):
            output_dict[ti.name]['problems'].append('Missing topology in test options')
        elif 'SA' not in ' '.join(test_options):
            output_dict[ti.name]['problems'].append('Missing variant (or non common agent tl type) in test options')
        if os.path.isfile(suite_path):
            for option in set(test_options) - set(mandatory_tags) - set(optional_tags):
                if option.startswith('CLOUD') or option.startswith('VARIANT'):
                    with open(suite_path, 'r') as file:
                        if option not in file.read():
                            output_dict[ti.name]['problems'].append(f"{option} tag is missing/mismatched in "
                                                                    f"suite path ({suite_path})")
                else:
                    output_dict[ti.name]['problems'].append(f"Unrecognized {option} tag in test options")
        else:
            output_dict[ti.name]['problems'].append(f'Wrong suite path in AO - file {suite_path} not exist')
    else:
        output_dict[ti.name]['problems'].append(f"Test options are missing")


def check_AO_version_and_timeout(version, timeout):
    """
    Verifies that timeout and version are filled
    """
    if not version:
        output_dict[ti.name]['problems'].append(f"Version missing in automation options")
    elif not timeout:
        output_dict[ti.name]['problems'].append(f"Timeout missing in automation options")


def check_terminal(terminal, topology):
    if 'AP' not in terminal and 'FS' not in terminal:
        output_dict[ti.name]['problems'].append(f"Incorrect terminal '{terminal}'")
    terminal_short = re.findall(r'L[O]+', terminal)[0]
    topology_short = re.findall(r'L[O]+', topology.split('_AP_')[1])[0]
    if topology_short != terminal_short:
        output_dict[ti.name]['problems'].append(f"Provided terminal '{terminal}' does not match provided topology "
                                                f"'{topology}'")


def _get_tl_type_from_AO(tc):
    test_options = tc['automation_options']['test_options']
    topology = [option for option in test_options if option.startswith('CLOUD')]
    if topology:
        return topology[0]
    else:
        return None


def _get_hw_list_from_topology(topology):
    gnb_hw_letters = topology.split('_AP_')[0].split('_')[-1]
    smod_list = []
    bbmod_list = []
    if '[' in gnb_hw_letters:
        hw_groups = gnb_hw_letters[1:-1].split('][')
    else:
        hw_groups = [gnb_hw_letters]
    for group in hw_groups:
        smod_list.append(group[0])
        bbmod_list += list(group[1:])
    return sorted(smod_list), sorted(bbmod_list)


def _get_hw_list_from_platform(platform):
    smod_list = []
    bbmod_list = []
    platform = [hw.strip() for hw in platform.split(',')]
    platform.remove('Airscale') if 'Airscale' in platform else platform
    platform.remove('AMIA') if 'AMIA' in platform else platform
    hw_found = re.findall(r"[A-Z]{4}", ' '.join(platform))
    for hw in hw_found:
        if hw.startswith('AS'):
            smod_list.append(hw[-1])
        elif hw.startswith('AB'):
            bbmod_list.append((hw[-1]))
    return sorted(smod_list), sorted(bbmod_list)


def compare_platform_with_AO(topology, platform):
    """
    Verifies that platform and topology provided in AO are in line.
    """
    smod_list, bbmod_list = _get_hw_list_from_topology(topology)
    smod_list_platform, bbmod_list_platform = _get_hw_list_from_platform(platform)
    if (smod_list != smod_list_platform or bbmod_list != bbmod_list_platform) and ('5GC' not in topology):
        output_dict[ti.name]['problems'].append(f"Mismatch between platform ({platform}) and topology ({topology})")


def compare_test_entity_with_test_lab_path(test_entity, test_lab_path):
    """
    Verifies test entity.
    """
    if test_entity not in test_lab_path:
        output_dict[ti.name]['problems'].append(f"Wrong test entity ({test_entity}) for this test lab path "
                                                f"({test_lab_path})")


def check_test_level_and_area(test_lvl_area):
    """
    Verifies Test Level and Area.
    """
    if 'EnTe' not in test_lvl_area:
        output_dict[ti.name]['problems'].append(
            f"Wrong Test Level and Area ({test_lvl_area}). Should be EnTe - Functional Test, EnTe - Dependency Testing,"
            f"EnTe - Performance Verification, EnTe - Predicted Robustness or EnTe - Unforeseen Robustness.")


def check_competence_area_and_organization(ca, org):
    """
    Verifies Competence Area and Organization.
    """

    if ca != 'RAN_L2_SW_KRK_1':
        output_dict[ti.name]['problems'].append(f"Wrong Competence Area ({ca}). Should be RAN_L2_SW_KRK_1")
    elif org != 'RAN_L2_SW_KRK_1_VRF':
        output_dict[ti.name]['problems'].append(f"Wrong Organization ({org}). Should be RAN_L2_SW_KRK_1_VRF")


def check_DAL(dal):
    """
    Verifies that Detailed Automation Level is set to 23.
    """
    if '23' not in dal:
        output_dict[ti.name]['problems'].append(f"Wrong DAL ({dal}). Should be 23 - Test is cloudified and fully "
                                                f"automated. Analysis is fully automated")


def check_approval(approval):
    """
    Verifies that test instance is approved.
    """
    if approval != 'Approved':
        output_dict[ti.name]['problems'].append(f"Test case is not approved ({approval})")


def compare_test_subarea_with_AO(test_subarea, topology, variant):
    """
    Verifies that test subarea is in line with AO.
    """
    duplex_list = re.findall(r'[TF]DD', test_subarea)
    missing_tags = []
    if ('SBTS' not in test_subarea) and ('CloudRAN' not in test_subarea):
        missing_tags.append('SBTS/CloudRAN')
    elif 'SA' not in test_subarea:
        missing_tags.append('SA/NSA')
    elif '5G_' not in test_subarea:
        missing_tags.append('TDD/FDD CPRI/eCPRI')
    if missing_tags:
        output_dict[ti.name]['problems'].append(f"Test subarea incomplete - {missing_tags} tags are missing")
    else:
        for duplex in duplex_list:
            if duplex not in topology + variant:
                output_dict[ti.name]['problems'].append(f"Mismatch between test subarea ({test_subarea}) and "
                                                        f"topology ({topology}) or variant ({variant})")


def check_backlog_ID_and_feature(backlog_ids, feature):
    """
    Verifies if feature and backlog id are set and Epic key is provided in backlog id.
    """
    if 'FCA' not in backlog_ids:
        output_dict[ti.name]['problems'].append(f"Epic key (e.g. FCA_5G_L2L3_123456) is missing in Backlog ID "
                                                f"({backlog_ids})")
    elif not feature:
        output_dict[ti.name]['problems'].append(f"Feature field is not filled")


def prepare_output_dict_per_tester(output_dict):
    """
    Regenerates output dict to structure  'tester':{'test':'problems_list'}
    """
    new_dict = {v['tester']: {} for (k, v) in output_dict.items()}
    for test, values in output_dict.items():
        if values['problems']:
            new_dict[values['tester']][test] = values['problems']
    return new_dict


def print_output(tester_dict):
    """
    Prints script results
    """
    counter = 0
    tests = 0
    for name, content in tester_dict.items():
        if content:
            tests_number = f"{len(content)} tests" if len(content) != 1 else f"{len(content)} test"
            print(f"\033[94m{name} - {tests_number}:\033[0m")
            tests += len(content)
            for test, problems in content.items():
                counter += len(set(problems))
                print(f"\033[91m{test}\033[0m")
                for problem in sorted(set(problems)):
                    print(f"  -  {problem}")
                print('')
            print('')
    print(f"Found {counter} problems in {tests} test{'s' * bool(tests - 1)}")


def prepare_email_message(tester_dict):
    """
    Returns output string with html list formatting and heading
    """
    msg = ''
    counter = 0
    tests = 0
    for name, content in tester_dict.items():
        if content:
            tests_number = f"{len(content)} tests" if len(content) != 1 else f"{len(content)} test"
            msg += f'<h2>{name} - {tests_number} </h2><ul>\n'
            tests += len(content)
            for test, problems in content.items():
                counter += len(set(problems))
                msg += f'</ul><h4>{test}:</h4><ul>\n'
                for problem in sorted(set(problems)):
                    msg += f"<li>{problem}</li>"
            msg += "</ul>"
        msg += "<br>"
    prefix = f"<h2> Found {counter} problems in {tests} test{'s' * bool(tests - 1)}: </h2><br>"

    return prefix + msg


def send_email(message, email_address, subject='Test Instance Validator'):
    """
    Asks user for email address and sends script output via email or skips when email adress is not provided.
    """
    msg = MIMEMultipart('mixed')
    msg['From'] = "Test_instance_validator@nokia.com"
    msg['To'] = email_address
    msg['Subject'] = f"{subject} - {datetime.date.today()}"
    body = MIMEText(message, 'html')
    msg.attach(body)
    with smtplib.SMTP('10.130.128.21') as server:
        server.ehlo()
        server.sendmail(msg['From'], [msg['To']], msg.as_string().encode("utf8"))
        server.quit()
    print(f"\nEmail sent out successfully to {email_address}")


results = get_all_test_instances()
for test_instance in results:
    ti = create_test_instance_dataclass(test_instance)
    output_dict[ti.name] = {'tc_name': ti.name, 'tester': ti.res_tester, 'problems': []}

    check_AO_paths(ti.name, ti.repo_path, ti.suite_path)
    check_AO_test_case_name(ti.name, ti.tc_name_AO)
    check_AO_test_options(ti.suite_path, ti.test_options)
    check_AO_version_and_timeout(ti.version, ti.timeout)
    compare_platform_with_AO(ti.topology, ti.platform)
    compare_test_entity_with_test_lab_path(ti.test_entity, ti.test_lab_path)
    check_test_level_and_area(ti.test_lvl_area)
    check_competence_area_and_organization(ti.ca, ti.org)
    check_DAL(ti.dal)
    compare_test_subarea_with_AO(ti.test_subarea, ti.topology, ti.variant)
    check_backlog_ID_and_feature(ti.backlog_ids, ti.feature)
    check_approval(ti.approval)
    check_terminal(ti.terminal, ti.topology)

tester_dict = prepare_output_dict_per_tester(output_dict)
msg = prepare_email_message(tester_dict)
print_output(tester_dict)

if len(sys.argv) > 2:
    send_email(msg, sys.argv[2])
