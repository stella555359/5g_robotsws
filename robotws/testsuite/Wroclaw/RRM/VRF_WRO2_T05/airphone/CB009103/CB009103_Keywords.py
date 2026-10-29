from ta5g_ue_measurements import ta5g_ue_measurements
import time

ta5g_ue_meas_instance = ta5g_ue_measurements()


def wait_for_event_a4_and_send_ue_measurement_nr_with_aligned_meas_id(ue_id, trigger_type='RSRP',
                                                                      carrier_freq='636576', alias=None,
                                                                      timeout=300, pass_regexp=None,
                                                                      get_ue_meas_cfg=None, **kwargs):

    meas_id = wait_for_event_A4_and_return_meas_id(ue_id=ue_id, trigger_type=trigger_type,
                                                   carrier_freq=carrier_freq, timeout=timeout,
                                                   alias=alias)
    ta5g_ue_meas_instance.send_ue_measurement_nr_for_specific_event(ue_id=ue_id, meas_id=meas_id, event='A4',
                                                                    timeout=timeout, pass_regexp=pass_regexp,
                                                                    get_ue_meas_cfg=get_ue_meas_cfg, **kwargs)


def wait_for_event_A4_and_return_meas_id(ue_id, trigger_type='RSRP', carrier_freq='636576', timeout=300, alias=None):
    ta5g_ue_meas_instance.get_ue_measurement_configuration(ue_id, alias)
    return wait_for_event_A4_and_get_meas_id(ue_id, trigger_type, carrier_freq, timeout)


def wait_for_event_A4_and_get_meas_id(ue_id, trigger_type='RSRP', carrier_freq='636576', timeout=300):
    start_time = time.time()
    while True:
        try:
            meas_id_event_A4 = ta5g_ue_meas_instance.get_meas_id_for_event_A4(ue_id, trigger_type, carrier_freq)
            return meas_id_event_A4
        except Exception as e:
            if time.time() - start_time > timeout:
                raise TimeoutError(f"Timeout exceeded after {timeout} seconds: {str(e)}")
            time.sleep(0.1)
