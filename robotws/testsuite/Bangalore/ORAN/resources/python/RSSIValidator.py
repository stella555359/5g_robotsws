class RSSIValidator(object):
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def validate_rssi(self, cell_info):
        trx_with_none_zero_rssi = {}
        carriers = dict([(tx['trxId'], tx['carriers']) for tx in cell_info["trxInformation"]])
        for trx, rssi_info in carriers.items():
            rssi_value = [True if isinstance(item['rssi'], int) and item['rssi'] != 0 else False for item in rssi_info]
            if not rssi_value.count(rssi_value[0]) == len(rssi_value):
                return False, 'some RSSI value in same TRX are zero', carriers
            if False in rssi_value:
                continue
            trx_with_none_zero_rssi[trx] = rssi_info
        return (False, 'RSSI is not found in any TRX', carriers) if not trx_with_none_zero_rssi else \
            self.check_for_range(trx_with_none_zero_rssi)

    def check_for_range(self, carrier):
        for trx in carrier:
            for item in carrier[trx]:
                if not -100 < item['rssi'] < -60:
                    return False, 'RSSI is not in range', carrier
            rssi_list = sorted([item['rssi'] for item in carrier[trx]])
            if abs(rssi_list[0] - rssi_list[-1]) > 10:
                return False, 'RSSI difference is more than {}'.format(10), carrier
        return True, 'validated correctly', carrier
