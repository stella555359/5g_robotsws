import unittest
from testsuite.Ulm.resources.Common.python import testline


class TestTestline(unittest.TestCase):
    def test_reform_coam_sw_version(self):
        version = testline.reform_coam_sw_version('vCUCNF22R1_0.300.1234')
        self.assertEqual(version, 'vCUCNF00_0.300.1234')

        version = testline.reform_coam_sw_version('vCUCNF_0.300.1234')
        self.assertEqual(version, 'vCUCNF00_0.300.1234')

        version = testline.reform_coam_sw_version('vDUCNF22R1_0.300.1234')
        self.assertEqual(version, 'vDUCNF00_0.300.1234')

        version = testline.reform_coam_sw_version('vDUCNF_0.300.1234')
        self.assertEqual(version, 'vDUCNF00_0.300.1234')

        version = testline.reform_coam_sw_version('vDUCNF22R1_9.300.1234')
        self.assertEqual(version, 'vDUCNF22R1_9.300.1234')


if __name__ == '__main__':
    unittest.main()
