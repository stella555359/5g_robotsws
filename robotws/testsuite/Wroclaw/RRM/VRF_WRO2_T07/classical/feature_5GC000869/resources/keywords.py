import time
from taf.config.scf import scf
from testsuite.Wroclaw.RRM.resources.scf_verification.scf_verifier import \
    setup_and_check_preconditions_in_scf
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
    remove_luashark_loading_from_output
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import prepare_testline, \
    wait_for_x2_link_availability
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog as btslog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as tafue
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils, AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator

l1l2 = L1L2()
tcpdump = TcpdumpSmod()
scf = scf()

num_of_ues = 1
# dl_mcs_field = 'DlData_PdschSendReq.grants_item_0.mcs'    # LuaShark
# ul_mcs_field = 'UlData_PuschReceiveReq.grants_item_0.mcs' # LuaShark
dl_mcs_field = 'DlData_PdschGrant.mcs'                      # McShark
ul_mcs_field = 'UlData_puschReceiveReqGrant_t.mcs'          # McShark

# todo : prepare objects comparison at the end wireshark filters for all branches (using OR)


def suite_setup():
    prepare_testline()


def test_setup():
    btslog.start_btslog_on_local_machine()


def test_teardown():
    tafue.detach_ues(num_of_ues)
    btslog.stop_and_collect_btslog()
    l1l2.teardown_gnbmirroring()
    tcpdump.teardown_tcpdump_on_smod()
    attenuator = Attenuator()
    attenuator.nullify_attenuation_on_all_ports()
    attenuator.release_attenuator()


def attach_to_single_subcell_configured_in_lower_nrarfcn():
    change_to_lower_nrarfcn()
    attach_with_logs()


def attach_to_single_subcell_configured_in_higher_nrarfcn():
    change_to_higher_nrarfcn()
    attach_with_logs()


def check_la_with_64_qam():
    change_to_middle_nrarfcn()
    test_mcs_values_on_different_tputs()


def check_la_with_256_qam():
    # change_to_middle_nrarfcn(actDl256Qam='true')
    test_mcs_values_on_different_tputs()


@logged_keyword
def attach_with_logs():
    l1l2.start_gnbmirroring()
    tcpdump.start_tcpdump_on_smod(smod_slave=False)

    tafue.require_ues(num_of_ues)
    tafue.attach_ues(num_of_ues)

    tcpdump.stop_tcpdump_and_download_logs_from_smod()
    l1l2.stop_gnbmirroring_and_download_logs()


class McsExtractor:
    def __init__(self, ul_value, dl_value, attenuation):
        self.ul_value = ul_value
        self.dl_value = dl_value
        self.attenuation = attenuation
        self.logfile_path = None
        self.ul_mcs_avg = None
        self.dl_mcs_avg = None

    @logged_keyword
    def get_l1l2_log_from_given_traffic(self):
        set_attenuation_to(self.attenuation)
        start_ul_dl_tput('{}Mbits/sec'.format(self.ul_value), '{}Mbits/sec'.format(self.dl_value))
        check_ul_dl_is_alive()
        l1l2.start_gnbmirroring(filename='LA_{}_{}.pcap'.format(self.ul_value, self.dl_value),
                                capturing_time_seconds='10')
        sleep(25, 'ongoing data transfer')
        self.logfile_path = l1l2.stop_gnbmirroring_and_download_logs()
        stop_ul_dl_tput()
        return self.logfile_path

    @logged_keyword
    def get_ul_dl_mcs_average(self, ul_field_name='UlData_PuschReceiveReq.grants_item_7.mcs',
                              dl_field_name='DlData_PdschSendReq.PdschSendReq.mcs'):
        self.ul_mcs_avg = self._get_mcs_average(ul_field_name)
        self.dl_mcs_avg = self._get_mcs_average(dl_field_name)
        return self.ul_mcs_avg, self.dl_mcs_avg

    @logged_keyword
    def _get_mcs_average(self, field_name='DlData_PdschSendReq.PdschSendReq.mcs'):
        output = TSharkCommandAssembler() \
            .with_pcap_file(self.logfile_path) \
            .with_filter(field_name) \
            .inject_additional_parameters('-T fields -e {}'.format(field_name)) \
            .build()
        output = remove_luashark_loading_from_output(output)
        if len(output) == 0:
            blog(level='WARN', message="{} logs not found in {}.".format(field_name, self.logfile_path))
            return 0
        mcs_sum = 0
        mcs_decimals = []
        for mcs in output:
            val = int(mcs, 0)
            mcs_sum += val
            mcs_decimals.append(val)
        blog("mcs sum = {}".format(mcs_sum))
        blog("len = {}, output = {}".format(len(output), mcs_decimals))
        return mcs_sum / float(len(output))


@logged_keyword
def test_mcs_values_on_different_tputs():
    attach_with_logs()
    mcs_values = [McsExtractor(ul_value=1, dl_value=20, attenuation=17),
                  McsExtractor(ul_value=30, dl_value=200, attenuation=10),
                  McsExtractor(ul_value=120, dl_value=500, attenuation=0),
                  McsExtractor(ul_value=31, dl_value=201, attenuation=9),
                  McsExtractor(ul_value=1, dl_value=21, attenuation=16)]
    for tput in mcs_values:
        tput.get_l1l2_log_from_given_traffic()

    for tput in mcs_values:
        tput.get_ul_dl_mcs_average(ul_field_name=ul_mcs_field, dl_field_name=dl_mcs_field)

    compare_mcs_values(mcs_values[0], mcs_values[1])
    compare_mcs_values(mcs_values[1], mcs_values[2])
    compare_mcs_values(mcs_values[3], mcs_values[2])
    compare_mcs_values(mcs_values[4], mcs_values[3])


@logged_keyword
def check_ul_dl_is_alive():
    tafue.check_ul_transfer_is_alive(num_of_ues=num_of_ues)
    tafue.check_dl_transfer_is_alive(num_of_ues=num_of_ues)


@logged_keyword
def start_ul_dl_tput(ul_value, dl_value):
    tafue.start_ul_data_transfer_on_ues(num_of_ues=num_of_ues, duration='150s', throughput=ul_value)
    tafue.start_dl_data_transfer_on_ues(num_of_ues=num_of_ues, duration='150s', throughput=dl_value)
    sleep(25, 'ongoing data transfer')


@logged_keyword
def stop_ul_dl_tput():
    tafue.stop_ul_data_transfer_on_ues(num_of_ues=num_of_ues)
    tafue.stop_dl_data_transfer_on_ues(num_of_ues=num_of_ues)


@logged_keyword
def set_attenuation_to(attenuation):
    attenuator = Attenuator()
    attenuator.set_attenuation(attenuation)
    attenuator.release_attenuator()


@logged_keyword
def change_to_lower_nrarfcn():
    change_carrierFreqNrCell_on_lte(carrier_fq='643392')
    change_nrarfcn(nrarfcn='643478', gscn='7951')


@logged_keyword
def change_to_middle_nrarfcn(actDl256Qam=None):
    change_carrierFreqNrCell_on_lte(carrier_fq='646656')
    change_nrarfcn(nrarfcn='646666', gscn='7985', actDl256Qam=actDl256Qam)


@logged_keyword
def change_to_higher_nrarfcn():
    change_carrierFreqNrCell_on_lte(carrier_fq='649824')
    change_nrarfcn(nrarfcn='649872', gscn='8018')


@logged_keyword
def change_carrierFreqNrCell_on_lte(carrier_fq):
    admin_utils = AdminUtils(bts_host=tl.enbs[0].x2_link_addr.v4)
    distname = 'MRBTS-{enb_id}/LNBTS-{enb_id}/NRDCDPR-0/ENDCDMEASCONF-0'.format(enb_id=tl.enbs[0].global_bts_id)
    scffile = '/tmp/lte_scf.xml'

    admin_utils.download_current_scf(local_dir_path="/tmp", file_name='lte_scf.xml')
    scf.load_scf(file_path=scffile)
    scf.modify_scf_element(value=carrier_fq, dist_name=distname, p_name='carrierFreqNrCell')
    scf.save_scf(scffile)
    admin_utils.perform_commissioning(scf_file=scffile, skip_parameter_relation_errors=True)


@logged_keyword
def change_nrarfcn(nrarfcn, gscn, actDl256Qam=None):
    parameters_dict = {'nrarfcn': nrarfcn, 'gscnOrSsPbchArfcn': gscn, 'actDl256Qam': actDl256Qam}
    if actDl256Qam is None:
        parameters_dict.pop('actDl256Qam')
    setup_and_check_preconditions_in_scf(parameters_dict)
    wait_for_x2_link_availability()


@logged_keyword
def sleep(time_in_seconds, reason):
    time.sleep(time_in_seconds)
    blog("{} slept, because of: {}".format(time_in_seconds, reason))


@logged_keyword
def compare_mcs_values(arg1, arg2):
    assert arg1.ul_mcs_avg < arg2.ul_mcs_avg
    assert arg1.dl_mcs_avg < arg2.dl_mcs_avg
