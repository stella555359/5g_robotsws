import sys
import os
import datetime
from lxml import etree
from bcolors import bcolors
from robot.libraries.BuiltIn import BuiltIn
import gnb_handler
import wft_handler
from taf.sw.reporting_portal import reporting_portal as ute_reporting_portal
from taf.config.testline.gnb.networkaddress import NetworkAddress

rf_built_in = BuiltIn()


def _log(message, console=True):
    rf_built_in.log(message=message, console=console)


def check_qc_files(tc_files_or_dirs):
    """
        Checks that qc files are present in each directory, or for each testcase file.
        Raises exception if for a <filename>.robot there is no <filename>.qc found.
    """
    error = False
    if not tc_files_or_dirs:
        _log(bcolors.WARNING_MSG + 'No test case list or directories set. Unable to check .qc files')
    else:
        for tc_file_or_dir in tc_files_or_dirs:
            list_files = [tc_file_or_dir]
            _log(bcolors.INFO_MSG + 'checking ' + tc_file_or_dir)
            base = os.path.realpath(os.path.dirname(tc_file_or_dir)) + '/'
            if os.path.isdir(tc_file_or_dir):
                (list_fil, list_file, list_files) = next(os.walk(tc_file_or_dir))
                base = os.path.realpath(tc_file_or_dir) + '/'
            for tc_file in list_files:
                tc_file = os.path.basename(tc_file)
                if os.path.splitext(tc_file)[1] == '.robot':
                    if os.path.isfile(base + os.path.splitext(tc_file)[0] + ' .qc') is False:
                        _log(bcolors.WARNING_MSG + base + os.path.splitext(tc_file)[0]
                             + '.qc : Not found. Looking for ' + base + tc_file.split('_')[0] + '.qc')
                        if os.path.isfile(base + tc_file.split('_')[0]+'.qc') is False:
                            error = True
                            _log(bcolors.WARNING_MSG + base + tc_file.split('_')[0] + '.qc:'
                                 + bcolors.ERROR + ' Not found ' + bcolors.ENDC)
                        else:
                            _log(bcolors.WARNING_MSG + base + tc_file.split('_')[0] + '.qc:'
                                 + bcolors.SUCCESS + ' found ' + bcolors.ENDC)
                    else:
                        _log(bcolors.INFO_MSG + base + os.path.splitext(tc_file)[0] + '.qc'
                             + bcolors.SUCCESS + ' found ' + bcolors.ENDC)
    if error:
        raise NameError(bcolors.ERROR_MSG +
                        'Every testcase must have associated qc file with same name. Or remove qc-report option')


def prepare_and_run(tlconf, args):
    """
        Prepare gNbs by uprading them, and run testcases.
        If no gNb set, it will get them from conf file (__init__.py).
        If no load set, it will download today promoted loads from wft.
        If qc report is enabled, it will check for qc files.
    """
    f = open(args['conf_dir']+'/__init__.py')
    lines = f.readlines()
    args['tl_label'] = lines[2].lstrip('#').split(' - ')[0].strip()

    builds = args['gnb_builds']
    if builds is None:
        builds = wft_handler.today_builds(promotion_tag=args['gnb_promotion_tag'], build_filter='SBTS')
    if builds is None:
        raise NameError(bcolors.ERROR_MSG + 'No build found for today for ' + args['gnb_promotion_tag'])

    # TODO remove this loop, only one load by run now
    for build in builds:
        _log(bcolors.INFO_MSG + 'Preparing and running testcases for build :' + bcolors.BOLD + build + bcolors.ENDC)

        for gnb in tlconf.tl.gnbs:
            host = gnb.cu.oam_http_connection_details.addr
            if args['gnbs'] is None or (args['gnbs'] is not None and host in args['gnbs']):
                args['gnb_sw'] = build
                args['gnb_delete_sw'] = False
                gnb_handler.update_sw(host, args)

    # TODO remove this loop, only one load by run now
    if args['enb_builds']:
        builds = args['enb_builds']
        for build in builds:
            if hasattr(tlconf.tl, 'enbs'):
                for enb in tlconf.tl.enbs:
                    host = enb.oam_ip
                    if isinstance(enb.oam_ip, NetworkAddress):
                        host = enb.oam_ip.v4
                    if args['enbs'] is None or (args['enbs'] is not None and host in args['enbs']):
                        _log(bcolors.INFO_MSG + 'Enb found :' + bcolors.BOLD + host + bcolors.ENDC)
                        args['enb_sw'] = build
                        args['enb_delete_sw'] = False
                        gnb_handler.update_sw(host, args, enb=True)

    if args['qc_report'] and not args['qc_file']:
        check_qc_files(args['tc_files_or_dirs'])
    run_and_report(tlconf, build, args)


def run_tests(tlconf, build, args):
    """
        Run tests found on tc_files_or_dirs or rerunfailed tests.
        If qc report is enabled, it will send the report to Quality Center via ute reporting portal tool.
    """
    now = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    for tc_file_or_dir in args['tc_files_or_dirs']:
        list_files = [tc_file_or_dir]
        root = ''
        separator = ''
        if os.path.isdir(tc_file_or_dir):
            (root, list_dirs, list_files) = next(os.walk(tc_file_or_dir))
            separator = '/'

        for tc_file in list_files:
            if os.path.splitext(tc_file)[1] == '.robot':
                args['tc_file'] = root + separator + tc_file
                tc_basename = os.path.basename(tc_file)
                tc_basename, tc_extension = os.path.splitext(tc_basename)
                if 'robot' in tc_extension:
                    args['tc_current_log_dir'] = args['tc_log_dir'] + '/'\
                                                + '_' . join(tc_basename.split('_')[0:2]) + '/' + now
                    if not os.path.exists(args['tc_current_log_dir']):
                        os.makedirs(args['tc_current_log_dir'])

                    args['tc_output_file'] = tc_basename + '_output.xml'
                    cmd = ('robot '
                           + args['tc_robot_opts']
                           + ' -V ' + args['conf_dir']
                           + ' -L DEBUG'
                           + ' -v bts_scout_name:' + args['tl_label'].replace('5G_Paris-Saclay', '7_20') + '_5G'
                           + ' -d ' + args['tc_current_log_dir']
                           + ' -b ' + tc_basename + '_debug.log'
                           + ' -r ' + tc_basename + '_report.html'
                           + ' -l ' + tc_basename + '_log.html'
                           + ' -o ' + args['tc_output_file']
                           + ' ' + args['tc_file'])
                    _log(bcolors.INFO_MSG + bcolors.BOLD + 'Running ' + cmd)
                    os.system(cmd)
                    if args['qc_report']:
                        report(tlconf, build, args)


def rerun_failed_tests(tlconf, build, args):
    """
        Run failed tests.
        Check on tc_rerunfailed list the of output.xml files and rerun the failed tests for these files.
        Then, merge the output.xml with the output.xml generated by the rerun to get one unified report.
        If qc report is enabled, it will send the merged results to Quality Center via reporting portal.
    """
    now = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    for tc_file_or_dir in args['tc_rerunfailed']:
        list_files = [tc_file_or_dir]
        root = ''
        separator = ''
        if os.path.isdir(tc_file_or_dir):
            (root, list_dirs, list_files) = next(os.walk(tc_file_or_dir))
            separator = '/'
        for output_file in list_files:
            basename = os.path.basename(output_file)
            basename, extension = os.path.splitext(basename)
            if output_file.endswith(".xml") and os.path.isfile(root+output_file):
                _log(bcolors.INFO_MSG + 'Extracting robot file from output ' + output_file)
                tree = etree.parse(root+output_file)
                for suite in tree.xpath("/robot/suite"):
                    basename = basename.replace('_reruned_', '')
                    basename = basename.replace('_output', '')
                    args['tc_current_log_dir'] = root + 'rerun-' + now + '/'
                    cmd = ('robot '
                           + args['tc_robot_opts']
                           + ' -V ' + args['conf_dir']
                           + ' -L DEBUG'
                           + ' -v bts_scout_name:' + args['tl_label'].replace('5G_Paris-Saclay', '7_20') + '_5G'
                           + ' -d ' + args['tc_current_log_dir']
                           + ' -b ' + basename + '_debug.log'
                           + ' -r ' + basename + '_report.html'
                           + ' -l ' + basename + '_log.html'
                           + ' -o ' + basename + '_output.xml'
                           + ' -S ' + root + output_file
                           + ' ' + suite.get("source"))
                    _log(bcolors.INFO_MSG + 'Running :\n' + cmd)
                    os.system(cmd)
                    cmd = ('robot '
                           + ' -d ' + args['tc_current_log_dir']
                           + ' -r ' + basename + '_report_merged.html'
                           + ' -l ' + basename + '_log_merged.html'
                           + ' -o ' + basename + '_output_merged.xml'
                           + ' --merge ' + root + output_file
                           + ' ' + args['tc_current_log_dir'] + basename + '_output.xml')
                    _log(bcolors.INFO_MSG + 'Merging original output.xml and reruned output.xml:\n' + cmd)
                    os.system(cmd)
                    if args['qc_report']:
                        args['tc_file'] = suite.get("source")
                        args['tc_output_file'] = basename + '_output_merged.xml'
                        report(tlconf, build, args)


def run_and_report(tlconf, build, args):
    """
        Run tests found on tc_files_or_dirs or rerunfailed tests.
    """
    if args['tc_files_or_dirs']:
        run_tests(tlconf, build, args)

    if args['tc_rerunfailed']:
        rerun_failed_tests(tlconf, build, args)


def report(tlconf, build, args):
    """
        Send the report/result via ute_reporting_portal to Quality Center.
    """

    qc_file = args['qc_file']
    error = False
    if qc_file is None:
        base = os.path.dirname(os.path.realpath(args['tc_file'])) + '/'
        qc_file = os.path.splitext(args['tc_file'])[0]+'.qc'
        if not os.path.isfile(qc_file):
            _log(bcolors.WARNING_MSG + qc_file + ' not found. Looking for ' + args['tc_file'].split('_')[0] + '.qc')
            qc_file = base + os.path.basename(args['tc_file']).split('_')[0]+'.qc'
            if not os.path.isfile(qc_file):
                _log(bcolors.WARNING_MSG + qc_file + ' also not found')
                error = True

    if not error:
        _log(bcolors.INFO_MSG + qc_file + bcolors.SUCCESS + ' found' + bcolors.ENDC)

    tc_output_file = args['tc_current_log_dir'] + '/' + args['tc_output_file']
    cmd = ('ute_reporting_portal send'
           + ' -ro ' + tc_output_file
           + ' -l ' + tlconf.tl.tl_cloud_topology
           + ' -tl ' + args['tl_label']
           + ' -qc ' + qc_file
           + ' --sw_version ' + build
           + ' --username ' + args['username'])
    _log(bcolors.INFO_MSG + bcolors.BOLD + 'Reporting cmd : ' + bcolors.ENDC + cmd)

    dryrun = False
    if 'dryrun' in args['tc_robot_opts']:
        dryrun = True

    with open(tc_output_file) as f:
        lines = f.readlines()
        for line in lines:
            if '>All Tests' in line:
                if 'fail="0"' not in line:
                    error = True
                    _log(bcolors.WARNING_MSG + 'Not all tests are passed. No scoring sent')

    if not error and not dryrun:
        os.system(cmd)
    else:
        if dryrun:
            _log(bcolors.WARNING_MSG + 'Dryrun detected : no report sent')
        if error:
            _log(bcolors.WARNING_MSG + 'Reporting not sent due to previous warning/error messages')


if __name__ == '__main__':
    import argparse

    arg = argparse.ArgumentParser(description='Run testcases & send report to Reporting Portal',
                                  formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    # Global parameters
    arg.add_argument('--conf-dir',
                     required=True,
                     help='Pythons or YAMLs files to read variables from. (__init__.py etc.)')

    # Gnb updater parameters
    arg.add_argument('--gnbs',
                     nargs='+',
                     help='If not set, gNBs will be taken from tl config (__init__.py) file.')
    arg.add_argument('--enbs',
                     nargs='+',
                     help='If not set, eNBs will be taken from tl config (__init__.py) file.')
    arg.add_argument('--gnb-builds',
                     nargs='+',
                     help='Builds to be used.\
                     If set it will be downloaded from WFT if not found in target-directory.\
                     If not set, today SBTS software(s) will be automatically downloaded from WFT')
    arg.add_argument('--enb-builds',
                     nargs='+',
                     help='Builds to be used.\
                     If set it will be downloaded from WFT if not found in target-directory.')
    arg.add_argument('--gnb-promotion_tag',
                     choices=wft_handler.default_promotion_tags,
                     default=wft_handler.default_promotion_tags[0],
                     help='Promotion Tags')
    arg.add_argument('--gnb-target-directory',
                     default='/tmp',
                     help='Target directory for downloaded zip builds.\
                      If the file is already found in the target directory, download is skipped')
    arg.add_argument('--enb-target-directory',
                     default='/tmp',
                     help='Target directory for downloaded zip builds.\
                      If the file is already found in the target directory, download is skipped')
    arg.add_argument('--gnb-dl-only',
                     action='store_true',
                     help='Download only load and stop script. (No testcases will be runned)')
    arg.add_argument('--enb-dl-only',
                     action='store_true',
                     help='Only download enb sw, no software upload performed')
    arg.add_argument('--gnb-yaft',
                     action='store_true',
                     help='Yaft it')
    arg.add_argument('-f', '--gnb-force-update',
                     action='store_true',
                     default=False,
                     help='Force update of the gNb')
    arg.add_argument('--enb-force-update',
                     action='store_true',
                     default=False,
                     help='Force update of the eNb')

    # Robot runner parameters
    arg.add_argument('--tc-robot-opts',
                     default='',
                     help="Custom robot options to add to the runner")
    arg.add_argument('--tc-log-dir',
                     default='/tmp',
                     help="Log directory. Ex:/tmp/5GC002515_A/YYYYMMDD-hhiiss/ will be created")
    arg.add_argument('--tc-files-or-dirs',
                     nargs='+',
                     help="Testcases files or directories that contains testcases files")
    arg.add_argument('--tc-rerunfailed',
                     nargs='+',
                     help="Rerun failed suites from *_output.xml found in given directories or files")

    # ReportingPortal/QC parameters
    arg.add_argument('--qc-report',
                     action='store_true',
                     help="Send results to QC via Reporting Portal")
    arg.add_argument('--qc-file',
                     help="Qc file. If not set, it will search for a .qc file with same basename of the robot file.")
    arg.add_argument('--username',
                     default='yleulmi',
                     help="The username associated with the test run. (will be on reporting portal)")

    args = vars(arg.parse_args())
    import json
    print(json.dumps(args, indent=4))
    sys.path.insert(1, args['conf_dir'])
    import __init__ as tlconf
    prepare_and_run(tlconf, args)
