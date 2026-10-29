from testsuite.Krakow.RRM.RAN_PZ.resources.log.helper import LogHelper
from testsuite.Krakow.RRM.RAN_PZ.resources.log.matchers import PcapMessageMatcher as Matcher
from moler.util.moler_test import MolerTest
from taf.rfrl.utilities.robot.general import get_builtin_value, set_robot_suite_variable
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations
from taf.rfrl.bts.devices.du.commissioning import GenericCommissioning
import re

current_lua = True
SCF_PROFILE = r'^\s+<p\sname=\"drxControl\">{}</p>'
ANR_PROFILE_MSG = r'.*?(Choosen|chosen)\s{}\sANR\sprofile'
RECEIVED_NRCGI_MSG = r'.*?MeasurementReport(HandleService|HandlerServiceNsa).cpp:\d+\s' \
                     r'Received\s(Inter|Intra)FreqNrcgiReport'


def _file_reader(filename):
    with open(filename, 'r') as f:
        for line in f:
            yield line


def _get_scf():
    log_dir = get_builtin_value('OUTPUT_DIR')
    du_connection = GenericDuOperations(bts_type="GNB")
    scf_path = du_connection.get_bts_configuration_file(bts_id=0, local_dir=log_dir, config_type="configuration")
    return scf_path


def _find_profile_in_scf(profile, path):
    found_profile = None
    scf_profile_pattern = re.compile(SCF_PROFILE.format(profile), re.IGNORECASE)
    MolerTest.info('Checking if ANR Profile pattern: "{}" exist in SCF "{}"'.format(scf_profile_pattern, path))
    for line in _file_reader(path):
        if scf_profile_pattern.match(line):
            found_profile = profile
            MolerTest.info("ANR Profile: '{}' found in line: '{}'".format(found_profile, line))
            break
    return found_profile


def verify_anr_profile(profile_name, syslog_path):
    found_anr_profile_pattern = False
    anr_profile_pattern = re.compile(ANR_PROFILE_MSG.format(profile_name), flags=re.IGNORECASE)

    for line in _file_reader(syslog_path):
        if anr_profile_pattern.match(line):
            found_anr_profile_pattern = True
            MolerTest.info('ANR profile pattern found in syslog: "{}"'.format(line))
            break
    if not found_anr_profile_pattern:
        raise ValueError('Not found ANR profile pattern: "{}" in syslog: "{}"'.format(anr_profile_pattern,
                                                                                      syslog_path))


def verify_nrcgi_report_not_received(syslog_path):
    nrcgi_recived_pattern = re.compile(RECEIVED_NRCGI_MSG, flags=re.IGNORECASE)
    for line in _file_reader(syslog_path):
        if nrcgi_recived_pattern.match(line):
            raise ValueError('NRCGI Received pattern "{}" found in syslog: "{}"'.format(nrcgi_recived_pattern, line))
    MolerTest.info('Verification success. '
                   '"NRCGI Received" pattern "{}" not found in syslog: "{}"'.format(RECEIVED_NRCGI_MSG, syslog_path))


@MolerTest.raise_background_exceptions()
def verify_drx_config_release(pcap, lua=None):
    pattern = "drx-Config: release (0)"
    msg_type = 'UEContextModificationResponse'
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap, lua=lua, shark_filter='',
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
        msgs = finder.find_all([
            Matcher(msg_type, name_line_pattern='empty')], output='tag_list')

        if msgs:
            drx_rls_msg = [msg for msg in msgs if repr(msg).find(pattern) != -1]
            if drx_rls_msg:
                MolerTest.info('Found "{}" pattern in "{}" message: "{}"'.format(pattern, msg_type, drx_rls_msg))
            else:
                MolerTest.error('Not found pattern "{}" among "{}" messages in pcap file "{}"'
                                ''.format(pattern, msg_type, pcap), raise_exception=True)
        else:
            MolerTest.error('Not found "{}" messages in pcap file: "{}"'.format(msg_type, pcap),
                            raise_exception=True)


@MolerTest.raise_background_exceptions()
def get_highest_priority_anr_profile_from_scf(freq_type):
    found_highest_priority_profile = None
    freq_specific_profiles = {'InterFreq': 'intraNRNSAinterFreq',
                              'IntraFreq': 'intraNRNSAintraFreq'}
    anr_profiles = ['any', 'intraNR', 'intraNRFR2', 'intraNRNSA']

    if freq_type in freq_specific_profiles.keys():
        anr_profiles.append(freq_specific_profiles[freq_type])
    else:
        MolerTest.error("Given HO type not supported '{}'. "
                        "Supported types: '{}'".format(freq_type, freq_specific_profiles.keys()), raise_exception=True)
    scf_path = _get_scf()
    MolerTest.info("SCF used for ANR Profile detection: '{}'".format(scf_path))
    for profile in reversed(anr_profiles):
        found_highest_priority_profile = _find_profile_in_scf(profile, scf_path)
        if found_highest_priority_profile:
            break
    if not found_highest_priority_profile:
        MolerTest.error('Not Found any of ANR Profiles "{}" in SCF "{}"'.format(anr_profiles, scf_path))
    else:
        set_robot_suite_variable("anr_profile", found_highest_priority_profile)
        return found_highest_priority_profile


def set_ul_proactive_grant_parameters(teardown=False):
    cell_id = get_builtin_value('GNB_CELL_ID')
    gnb_id = get_builtin_value('GNB_ID')
    gnb_scf = GenericCommissioning(bts_type='GNB')
    params = {'actProactUlScheduling': 'MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(gnb_id, gnb_id, cell_id),
              'actDisableUlProactGrantAnr': 'MRBTS-{}/NRBTS-{}'.format(gnb_id, gnb_id)
              }
    for param, dist in params.items():
        gnb_scf.perform_configuration_parameter_recommissioning(
            dist_name=dist,
            parameter=param,
            operation='update',
            value='false' if teardown else 'true')
