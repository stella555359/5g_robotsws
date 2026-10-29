from testsuite.Ulm.resources.Common.python import pmcounters

try:
    import unittest2 as unittest
except ImportError:
    import unittest

try:
    import unittest.mock as mock
except ImportError:
    import mock


reference_table = \
    [
        'M55318C00002', '==', 'M55318C00006',                      'Description of the first condition',
        'M55318C00008', '>=', 'M55318C00001 - (4 + M55318C00005)', 'This is another condition',
        'M55318C00012', '==', '40',                                'the last condition'
    ]


reference_table_with_distnames = \
    [
        '(NRCELL-1)M55318C00002', '>', '(NRCELL-2)M55318C00006',                                 'Description 1',
        '(NRCELL-1)M55318C00008', '>=', '(NRCELL-2)M55318C00001 - (4 + (NRCELL-2)M55318C00005)', 'Another condition',
        '(NRCELL-1)M55318C00012', '==', '100',                                                   'the last condition',
        '(NRCELL-2)M55318C00012', '==', '70',                                                    'the very last one'
    ]


reference_table_with_distnames_and_no_distnames = \
    [
        '(NRCELL-1)M55318C00002', '>', '(NRCELL-2)M55318C00006',             'Description of the first condition',
        '(NRCELL-1)M55318C00008', '>=', 'M55318C00001 - (4 + M55318C00005)', 'This is another condition',
        '(NRCELL-1)M55318C00012', '==', '100',                               'the last condition',
        '(NRCELL-2)M55318C00012', '==', '70',                                'another last condition'
    ]


pmcounter_list = \
    [
        'M55318C00002',
        'M55318C00006',
        'M55318C00008',
        'M55318C00001',
        'M55318C00005',
        'M55318C00012'
    ]


pmcounter_list_distnames = \
    [
        '(NRCELL-1)M55318C00002',
        '(NRCELL-2)M55318C00006',
        '(NRCELL-1)M55318C00008',
        '(NRCELL-2)M55318C00001',
        '(NRCELL-1)M55318C00012',
        '(NRCELL-2)M55318C00005)',
        '(NRCELL-2)M55318C00012'
    ]


reference_table_no_description = \
    [
        'M55318C00002', '==', 'M55318C00006',
        'M55318C00008', '>=', 'M55318C00001 - (4 + M55318C00005)',
        'M55318C00012', '==', '40',
    ]

description_list = \
    [
        'Description of the first condition',
        'This is another condition',
        'the last condition',
        'another last condition'
    ]


reference_table_pass = \
    [
        'M55318C00002', '>=', 'M55318C00006',
        'M55318C00008', '>=', 'M55318C00001 - (4 + M55318C00005)',
        'M55318C00012', '==', '100',
    ]


reference_table_pass_mixed_datatypes = \
    [
        'M55318C00002', '>=', 'M55318C00006',
        'M55318C00008', '>=', 'M55318C00001 - (4 + M55318C00005)',
        'M55318C00012', '==', 100,
    ]


resolved_table = \
    [
        '200000', '==', '40',
        '60', '>=', '0 - (4 + 0)',
        '100', '==', '40'
    ]


reference_table_wrong_format = \
    [
        'M55318C00002', '==', 'M55318C00006',
        'M55318C00008', '>=', 'M55318C00001 - (4 + M55318C00005)',  'This is another condition',
        'M55318C00012', '==', '40',
    ]


pm_counter_dict_nrcell_1 = \
    {
        'M55318C00002': '200000',
        'M55318C00006': '40',
        'M55318C00008': '60',
        'M55318C00001': '0',
        'M55318C00005': '0',
        'M55318C00012': '100'
    }


pm_counter_dict_nrcell_2 = \
    {
        'M55318C00002': '200001',
        'M55318C00006': '45',
        'M55318C00008': '65',
        'M55318C00001': '30',
        'M55318C00005': '24',
        'M55318C00012': '70'
    }


class Log_entries():
    def get_pi_value(self, pi_id, dn_re):
        if 'NRCELL-1' in dn_re:
            return pm_counter_dict_nrcell_1[pi_id]
        if 'NRCELL-2' in dn_re:
            return pm_counter_dict_nrcell_2[pi_id]
        if 'NRCELL-1' in pi_id:
            return pm_counter_dict_nrcell_1[pi_id.split(')')[1]]
        if 'NRCELL-2' in pi_id:
            return pm_counter_dict_nrcell_2[pi_id.split(')')[1]]


class Test_pmcounters(unittest.TestCase):

    def setUp(self):
        pass
        builtin_patcher = mock.patch("testsuite.Ulm.resources.Common.python.pmcounters.BuiltIn")

        builtin_mock = builtin_patcher.start()

        builtin_mock.BuiltIn.return_value.fail.side_effect = AssertionError

        self.addCleanup(builtin_patcher.stop)

    def tearDown(self):
        pass

    def test_reference_table_has_description(self):
        # reference table with description
        self.assertTrue(pmcounters.reference_table_has_description(reference_table))
        # reference table without description
        self.assertFalse(pmcounters.reference_table_has_description(reference_table_no_description))
        # table with wrong format expect robot BuiltIn.fail() to be called
        self.assertRaises(AssertionError, pmcounters.reference_table_has_description, reference_table_wrong_format)

    def test_remove_description_from_reference_table(self):
        table_without_description, _ = pmcounters.remove_description_from_reference_table(reference_table)

        self.assertEqual(
            table_without_description,
            reference_table_no_description
        )

    def test_get_pmcounter_ids_in_reference_table(self):
        self.assertEqual(pmcounters.get_pmcounter_ids_in_reference_table(reference_table).sort(),
                         pmcounter_list.sort())

    def test_get_pmcounter_ids_in_reference_table_distnames(self):
        self.assertEqual(pmcounters.get_pmcounter_ids_in_reference_table(reference_table_with_distnames).sort(),
                         pmcounter_list_distnames.sort())

    def test_get_pmcounter_ids_in_reference_table_distnames_and_no_distnames(self):
        # this is not allowed. Expect failure
        with self.assertRaises(AssertionError):
            pmcounters.get_pmcounter_ids_in_reference_table(reference_table_with_distnames_and_no_distnames)

    def test_resolve_reference_table(self):
        self.assertEqual(
            pmcounters.resolve_reference_table(reference_table_no_description, pm_counter_dict_nrcell_1),
            resolved_table
        )

    def test_validate_reference_table_against_pmcounter_values(self):
        # expect that robot BuiltIn.should_be_empty() fails the test because there is at least one false condition
        with self.assertRaises(AssertionError):
            pmcounters.validate_reference_table_against_pmcounter_values(
                reference_table_no_description,
                pm_counter_dict_nrcell_1,
                description_list
            )

        # expect that robot BuiltIn.should_be_empty() not fail the test since table is correct
        pmcounters.validate_reference_table_against_pmcounter_values(
            reference_table_pass,
            pm_counter_dict_nrcell_1,
            description_list
        )

    @mock.patch('testsuite.Ulm.resources.Common.python.pmcounters.PMCounterLogReader.from_dir',
                mock.MagicMock(return_value=[Log_entries()]))
    def test_get_pmcounter_values_from_log(self):
        self.assertEqual(
            pmcounters.get_pmcounter_values_from_log(pmcounter_list, './', 'NRCELL-1'),
            pm_counter_dict_nrcell_1
        )

    @mock.patch('testsuite.Ulm.resources.Common.python.pmcounters.PMCounterLogReader.from_dir',
                mock.MagicMock(return_value=[Log_entries()]))
    def test_validate_pm_counter_reference_table(self):
        with self.assertRaises(AssertionError):
            pmcounters.validate_pm_counter_reference_table(reference_table, './', 'NRCELL-1')

    @mock.patch('testsuite.Ulm.resources.Common.python.pmcounters.PMCounterLogReader.from_dir',
                mock.MagicMock(return_value=[Log_entries()]))
    def test_validate_pm_counter_reference_table_pass(self):
        pmcounters.validate_pm_counter_reference_table(reference_table_pass, './', 'NRCELL-1')

    @mock.patch('testsuite.Ulm.resources.Common.python.pmcounters.PMCounterLogReader.from_dir',
                mock.MagicMock(return_value=[Log_entries()]))
    def test_validate_pm_counter_reference_table_with_distnames_in_argument_and_table(self):
        # Distnames in both table and argument are not accepted. Only one of this is allowed
        with self.assertRaises(AssertionError):
            pmcounters.validate_pm_counter_reference_table(reference_table_with_distnames, './', 'NRCELL-1')

    @mock.patch('testsuite.Ulm.resources.Common.python.pmcounters.PMCounterLogReader.from_dir',
                mock.MagicMock(return_value=[Log_entries()]))
    def test_validate_pm_counter_reference_table_distnames_table_pass(self):
        pmcounters.validate_pm_counter_reference_table(reference_table_with_distnames, './')

    @mock.patch('testsuite.Ulm.resources.Common.python.pmcounters.PMCounterLogReader.from_dir',
                mock.MagicMock(return_value=[Log_entries()]))
    def test_validate_pm_counter_reference_table_pass_mixed_types(self):
        pmcounters.validate_pm_counter_reference_table(reference_table_pass_mixed_datatypes, './', 'NRCELL-1')


if __name__ == '__main__':
    unittest.main()
