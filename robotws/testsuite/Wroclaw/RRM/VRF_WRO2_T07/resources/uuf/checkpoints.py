from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword, wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.uuf.timeouts import Timeouts
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.update_helpers import RequestsHandler
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl

assert_msg = '\n'.join(['{message}', 'Expected: {expected}', 'But was: {current}'])
ssh_host = tl.gnbs[0].cu.oam_http_connection_details.addr
bts_cfg = tl.gnbs[0]


@logged_keyword
def verify_on_air(additional_reset=False, cell_type='nr'):
    RequestsHandler().wait_until_server_is_reachable(url='https://' + ssh_host)
    if additional_reset:
        RequestsHandler().wait_until_server_is_unreachable(url='https://' + ssh_host)
        RequestsHandler().wait_until_server_is_reachable(url='https://' + ssh_host)
    with AdminApi(bts_host=ssh_host, bts_port=443) as api:
        bbmod_ready(api)
        radio_ready(api)
        cells_ready(api, cell_type=cell_type)
        if cell_type == 'nr' and api.get_bts_info()['gNbCuType'] in ['both', 'NSA', 'SA+NSA']:
            wait_for_x2_link_availability(api)


@logged_keyword
@wait_until_function_succeeds(retry_time_in_seconds=Timeouts.bbmod_available, retry_interval_in_seconds=5)
def bbmod_ready(admin_api=None):
    if admin_api is None:
        with AdminApi(bts_host=ssh_host, bts_port=443) as api:
            bbmod_ready(api)
    else:
        for bbmod in admin_api.get_detected_hw_info()['basebandModules']:
            assert bbmod['status'].get('availabilityStatus') in ['Online', None], assert_msg.format(
                message='BBMOD is not operational',
                expected='availabilityStatus: Online',
                current=str(bbmod['status'].get('availabilityStatus')))


@logged_keyword
@wait_until_function_succeeds(retry_time_in_seconds=Timeouts.radio_available, retry_interval_in_seconds=1)
def radio_ready(admin_api):
    frm_info = admin_api.get_frm()
    assert len(frm_info), 'Radio object not detected'
    for radio in frm_info:
        assert radio['status'].get('availabilityStatus') in ['Online', 'Degraded', None], assert_msg.format(
            message='Not all radios are online',
            expected='availabilityStatus: Online',
            current=str(radio['status'].get('availabilityStatus')))


@logged_keyword
@wait_until_function_succeeds(retry_time_in_seconds=Timeouts.cell_available, retry_interval_in_seconds=1)
def cells_ready(admin_api, cell_type):
    cells_info = admin_api.get_cells_info(cell_type=cell_type)
    assert len(cells_info), 'Cells not detected'
    for cell in cells_info:
        assert cell['status'].get('availabilityStatus') in ['Online', 'Degraded', None], assert_msg.format(
            message='Not all cells are online',
            expected='availabilityStatus: Online',
            current=str(cell['status'].get('availabilityStatus')))


@logged_keyword
@wait_until_function_succeeds(retry_time_in_seconds=Timeouts.x2_link, retry_interval_in_seconds=2)
def wait_for_x2_link_availability(admin_api):
    assert len(admin_api.get_managed_objects(class_name='LTEENB_R', timeout=30)), \
        'Object LTEENB_R not ready on BTS'
    for lteenb in admin_api.get_managed_objects(class_name='LTEENB_R', timeout=30):
        assert lteenb['parameters']['x2LinkStatus'] == 'available', assert_msg.format(
            message='x2LinkStatus is not available',
            expected='x2LinkStatus: available',
            current=lteenb['parameters']['x2LinkStatus'])
