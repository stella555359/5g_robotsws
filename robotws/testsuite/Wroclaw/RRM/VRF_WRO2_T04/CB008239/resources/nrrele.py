import os
import json
from jinja2 import Template
from ute_admin_infomodel import ute_admin_infomodel
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession

ALLOWED_NRRELS_IDS = (1, 2)
NRREL_DISTNAME_FORMAT = 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}'
DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_templates')

IP_VM_5G = '127.0.0.1'
IP_VM_LTE = '10.42.194.10'
VM_PASS = 'Ut3pa5s#1be1'
LNBTS_ID = 40085
LTE_CELLS = (1, 2, 3, 4)


def change_maxNumRrc():
    with AdminSession(remote_host=IP_VM_LTE, remote_pass=VM_PASS) as admin:
        admin.perform_parameter_recommissioning(dist_name='MRBTS-40085/LNBTS-40085/LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0',
                                                parameter='maxNumRrc', value='0',
                                                operation='update', skip_parameter_relation_errors=True,
                                                should_activate=True, timeout=300)


def modify_maxNumRrc():
    with AdminSession(remote_host=IP_VM_LTE, remote_pass=VM_PASS) as admin:
        admin.perform_parameter_recommissioning(dist_name='MRBTS-40085/LNBTS-40085/LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0',
                                                parameter='maxNumRrc', value='0',
                                                operation='update', skip_parameter_relation_errors=True,
                                                should_activate=True, timeout=300)


def restore_maxNumRrc():
    with AdminSession(remote_host=IP_VM_LTE, remote_pass=VM_PASS) as admin:
        admin.perform_parameter_recommissioning(dist_name='MRBTS-40085/LNBTS-40085/LNCEL-4/LNCEL_FDD-0/MPUCCH_FDD-0',
                                                parameter='maxNumRrc', value='105',
                                                operation='update', skip_parameter_relation_errors=True,
                                                should_activate=True, timeout=300)


def cell_barred():
    with AdminSession(remote_host=IP_VM_LTE, remote_pass=VM_PASS) as admin:
        admin.perform_parameter_recommissioning(dist_name='MRBTS-40085/LNBTS-40085/LNCEL-4/SIB-0',
                                                parameter='cellBarred', value='barred',
                                                operation='update', skip_parameter_relation_errors=True,
                                                should_activate=True, timeout=300)


def cell_notbarred():
    with AdminSession(remote_host=IP_VM_LTE, remote_pass=VM_PASS) as admin:
        admin.perform_parameter_recommissioning(dist_name='MRBTS-40085/LNBTS-40085/LNCEL-4/SIB-0',
                                                parameter='cellBarred', value='notBarred',
                                                operation='update', skip_parameter_relation_errors=True,
                                                should_activate=True, timeout=300)


def load_delta_template(filename):
    delta_filepath = os.path.join(DELTA_DIR, filename)
    with open(delta_filepath) as f:
        return Template(json.dumps(json.load(f)))


def find_existing_nrreles_ids(cell_id):
    def get_nrrele_id(dist_name):
        return int(dist_name.split('-')[-1])

    admin = ute_admin_infomodel()
    try:
        admin.setup_infomodel()
        admin.connect_infomodel()
        nrreles = admin.query_infomodel(query='get list /MRBTS-*//NRBTS_A-*/NRCELL_A-{}/NRRELE_A-*'
                                              .format(cell_id), allow_negative_result=True)
        return [get_nrrele_id(item['dist_name']) for item in nrreles]
    except IndexError:
        raise RuntimeError("There is no NRRELEs for cell {}".format(cell_id))
    finally:
        admin.teardown_infomodel()
