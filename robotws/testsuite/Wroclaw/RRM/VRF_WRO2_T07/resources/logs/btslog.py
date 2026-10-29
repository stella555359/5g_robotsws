from taf.collectors.btslog.interface import btslog as btslog_collector
from taf.collectors.core import CollectorKeywords
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
import os
import tarfile

"""
Usage:          start_btslog_on_local_machine    log_name=my_log_name
                Sleep    4s
                ${btslog_path}=    stop_and_collect_btslog    log_name=my_log_name

Description:    output file structure follows this pattern:
                "target_dir/log_name/target_file_name.tgz"

Limitation:     You cannot start more than one btslog collector on a single BTS VM
"""


@logged_keyword
def start_btslog_on_remote_machine(log_name='btslog', host=None, user=None, password=None):
    target_file_name = log_name + '.tgz'
    executor = {'host': host, 'user': user, 'password': password}
    btslog = btslog_collector()
    btslog.create_btslog_collector(name=log_name,
                                   btslog_path='/opt/btslog/btslog',
                                   btslog_launcher_path='/opt/btslog/btslog_launcher',
                                   executor=executor,
                                   log_dir='/tmp/btslog2',
                                   target_file_name=target_file_name
                                   )
    core = CollectorKeywords()
    core.setup_collectors(names=log_name)
    core.start_collectors(names=log_name)


@logged_keyword
def start_btslog_on_local_machine(log_name='btslog'):
    target_file_name = log_name + '.tgz'
    btslog = btslog_collector()
    btslog.create_btslog_collector(name=log_name, log_dir='/tmp/btslog2', target_file_name=target_file_name)

    core = CollectorKeywords()
    core.setup_collectors(names=log_name)
    core.start_collectors(names=log_name)
    blog('BTSLOG collection has started.')


@logged_keyword
def pause_btslog(log_name='btslog'):
    core = CollectorKeywords()
    core.stop_collectors(names=log_name)
    blog('BTSLOG collection has paused.')


@logged_keyword
def unpause_btslog(log_name='btslog'):
    core = CollectorKeywords()
    core.start_collectors(names=log_name)
    blog('BTSLOG collection has unpaused.')


@logged_keyword
def stop_and_collect_btslog(log_name='btslog', target_dir=None, attempt_number='one'):
    outputdir = robot_globals.outputdir()
    testname = robot_globals.testname()
    target_dir = os.path.join(outputdir, testname, attempt_number) if target_dir is None else target_dir
    target_file_name = log_name + '.tgz'

    core = CollectorKeywords()
    core.stop_collectors(names=log_name)
    core.collect_collectors(names=log_name, target_dir=target_dir)
    core.teardown_collectors(names=log_name)

    btslog_log_dir = os.path.join(target_dir, log_name)
    btslog_log_tgz = os.path.join(btslog_log_dir, target_file_name)
    extract_btslog_from_tgz(btslog_log_tgz, btslog_log_dir)
    blog('BTSLOG collection has finished successfully!')

    return btslog_log_dir


def extract_btslog_from_tgz(btslog_tgz, target_dir=None):
    outputdir = robot_globals.outputdir()
    testname = robot_globals.testname()
    target_dir = os.path.join(outputdir, testname) if target_dir is None else target_dir

    if btslog_tgz.endswith('tgz'):
        tar = tarfile.open(btslog_tgz, 'r:gz')
        tar.extractall(target_dir)
        tar.close()
        blog('BTSLOG files were successfully extracted from tgz.')
    else:
        blog('no files were extracted.')


def teardown_btslog(log_name='btslog', target_dir=None):
    try:
        stop_and_collect_btslog(log_name=log_name, target_dir=target_dir)
    except Exception:
        blog('BTSLOG has already been collected. Teardown will not download BTSLOG.')
