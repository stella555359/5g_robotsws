class TableMatcher:
    map_mhz_to_column_ul = {'5': 7, '10': 10, '15': 12, '20': 13}
    map_mhz_to_column_dl = {'5': 5, '10': 6, '15': 7, '20': 8}

    def __init__(self, processed_msg, mcs_tables, direction, expected_ptrs,
                 expected_qam, expected_bandwidth, expected_rank):
        self.processed_msg = processed_msg
        self.mcs_tables = mcs_tables
        self.expected_qam = expected_qam
        expected_table_parameters = [direction, expected_ptrs, expected_qam, expected_rank]
        self.matching_table = self.get_matching_table(expected_table_parameters)
        self.matching_column = self.get_matching_column(expected_bandwidth, direction)

    def get_matching_table(self, expected_table_parameters):
        table_name = self.find_matching_table_name(self.mcs_tables, expected_table_parameters)
        return self.mcs_tables[table_name]

    @staticmethod
    def find_matching_table_name(mcs_tables, expected_table_parameters):
        for table_name in mcs_tables.keys():
            if all(parameter.lower() in table_name.lower() for parameter in expected_table_parameters):
                return table_name
        raise Exception('There is no matching table for parameters: ' + str(expected_table_parameters))

    def get_matching_column(self, bandwidth, direction):
        if direction.lower() == 'ul':
            return [row[TableMatcher.map_mhz_to_column_ul[bandwidth]] for row in self.matching_table]
        elif direction.lower() == 'dl':
            return [row[TableMatcher.map_mhz_to_column_dl[bandwidth]] for row in self.matching_table]
        else:
            raise Exception('Unrecognised traffic direction provided.')

    @staticmethod
    def map_sinr_to_mcs(processed_msg, matching_column, expected_qam):
        mcs = 0
        for idx, value in enumerate(matching_column):
            if float(processed_msg.sinr) >= float(value):
                mcs = idx

        if expected_qam.lower() == '64qam' and (mcs == 10 or mcs == 17):
            return mcs - 1

        return mcs

    def is_mcs_correct(self):
        used_mcs = self.processed_msg.used_mcs
        proposed_mcs = self.processed_msg.proposed_mcs
        expected_mcs = self.map_sinr_to_mcs(self.processed_msg, self.matching_column, self.expected_qam)
        is_mcs_correct = int(expected_mcs) == int(proposed_mcs)

        if int(expected_mcs) == 28 and int(proposed_mcs) == 27:
            return True

        if not is_mcs_correct:
            self.log_results(self.processed_msg.ptrs, self.processed_msg.sinr, expected_mcs,
                             used_mcs, proposed_mcs)
        return is_mcs_correct

    @staticmethod
    def log_results(ptrs, sinr, expected, used, proposed):
        print('PTRS: ' + ptrs, 'sinr: ' + str(sinr), 'expected: ' +
              str(expected), 'used: ' + str(used), 'proposed: ' + str(proposed))
