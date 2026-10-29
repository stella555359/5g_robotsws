import os
from jinja2 import Template
from taf.sbts.oam.coam.admin import AdminConnection
import testsuite.Wroclaw.RRM.resources.webUI_operations as webUI
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.tl_configuration import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals


# DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_templates')
mrbts_id = tl.gnbs[0].global_bts_id


def get_sw_release():
    bts = AdminConnection()
    sw_release = bts.get_sw_release_name()
    return sw_release


def load_delta_template(filename):
    sw = get_sw_release()
    if sw == "SBTS23R4":
        DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_templates/'+sw)
    else:
        DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_templates')
    delta_filepath = os.path.join(DELTA_DIR, filename)
    with open(delta_filepath) as f:
        return Template(f.read())


def delta_commisioning(json_delta):
    template = load_delta_template('{}.json'.format(json_delta))
    delta = template.render(mrbts_id=mrbts_id)
    __perform_delta(delta)


def __perform_delta(delta_str):
    with webUI.WebUIOperations() as coam:
        coam.perform_delta_recommissioning(delta_file=delta_str, skip_parameter_relation_errors=False,
                                           should_activate=True, timeout=300)


def read_csv_dcap_file(tti_collector_name='DCAPs', decoded_output_file=None):
    outputdir = robot_globals.outputdir()
    testname = robot_globals.testname()
    decoded_output_file = os.path.join(tti_collector_name, testname) if decoded_output_file is None \
        else os.path.join(tti_collector_name, '{}_{}'.format(testname, decoded_output_file))
    file_csv = os.path.join(outputdir, decoded_output_file + '.csv')
    print("file_csv: ", file_csv)
    with open(file_csv, 'r') as csv_content:
        content = csv_content.read()
    return content


def check_antennaSwitching_exit_csv():
    tti_content = read_csv_dcap_file()
    if 'usage antennaSwitching' in tti_content:
        return True
    return False


def check_codebook_exit_csv():
    tti_content = read_csv_dcap_file()
    if 'usage codebook' in tti_content:
        return True
    return False
