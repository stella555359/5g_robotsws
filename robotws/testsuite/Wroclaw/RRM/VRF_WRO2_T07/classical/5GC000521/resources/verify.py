import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
    remove_luashark_loading_from_output
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi


@fixture.logged_keyword
def verify_mib_information(l1l2_pcap):
    cellBarred_field = 'nr-rrc.cellBarred'
    intraFreqReselection_field = 'nr-rrc.intraFreqReselection'
    barringstatus_to_int = {'barred': 0, 'unbarred': 1}
    intraFreqReselection_to_int = {'allowed': 0, 'notAllowed': 1}
    mib_barringstatus_to_str = {0: 'barred', 1: 'notBarred'}
    with AdminApi() as web_api:
        barringStatus = list(set([cell['status']['barringStatus'] for cell in web_api.get_cells_info()]))
        assert len(barringStatus) == 1, 'Cells have different barringStatus'
    cellBarred_output = get_mib_value(l1l2_pcap, cellBarred_field)
    intraFreqReselection_output = get_mib_value(l1l2_pcap, intraFreqReselection_field)

    assert int(cellBarred_output[0]) == int(barringstatus_to_int[barringStatus[0]]), fixture.assert_equal_msg.format(
        message="cellBarred values should be different",
        p1_name="Value from L1L2 log",
        p1_value="{}({})".format(int(cellBarred_output[0]), mib_barringstatus_to_str[int(cellBarred_output[0])]),
        p2_name="Value from WebEM",
        p2_value="{}({})".format(int(barringstatus_to_int[barringStatus[0]]), barringStatus[0]))
    assert int(intraFreqReselection_output[0]) == intraFreqReselection_to_int['allowed'], fixture.assert_msg.format(
        message="{} value is not as expected".format(intraFreqReselection_field),
        expected=intraFreqReselection_to_int['allowed'],
        current=int(intraFreqReselection_output[0]))


def get_mib_value(l1l2_pcap, nr_rrc_field_filter):
    output = TSharkCommandAssembler() \
        .with_pcap_file(l1l2_pcap) \
        .with_filter(nr_rrc_field_filter) \
        .inject_additional_parameters('-T fields -e {}'.format(nr_rrc_field_filter)) \
        .build()
    output = remove_luashark_loading_from_output(output)
    assert len(output), "{} logs not found in {}.".format(nr_rrc_field_filter, l1l2_pcap)
    output = list(set(output))
    assert len(output) == 1, fixture.assert_msg.format(
        message="Not all {} values are as expected".format(nr_rrc_field_filter),
        expected="Same values in all logs",
        current=output)
    fixture.log_message(message="{} values = {}".format(nr_rrc_field_filter, output))
    return output
