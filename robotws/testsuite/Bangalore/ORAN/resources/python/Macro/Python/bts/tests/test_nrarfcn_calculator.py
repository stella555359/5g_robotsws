from parameterized import parameterized
from unittest import TestCase
from ..nrarfcn_calculator import NrarfcnCalculator


class TestNrarfcnCalculator(TestCase):
    def setUp(self):
        self.calc = NrarfcnCalculator()

    @parameterized.expand([
        [26550, 120, 240, 22390, 2055259],
        [24300, 120, 120, 22259, 2017531],
    ])
    def test_get_aligned_gscn_and_nrarfcn(
            self, frequency, scs, scs_ssb, expected_gscn, expected_nrarfcn):
        gscn, nrarfcn = self.calc.get_aligned_gscn_and_nrarfcn(
            frequency, scs, scs_ssb)
        assert gscn == expected_gscn
        assert nrarfcn == expected_nrarfcn

    @parameterized.expand([
        [2000, 400000],
        [10000, 1066667],
        [27990.06, 2079000],
    ])
    def test_calculate_nrarfcn(self, freq, expected_nrarfcn):
        nrarfcn = self.calc.calculate_nrarfcn(freq)
        assert nrarfcn == expected_nrarfcn

    @parameterized.expand([
        [300000, 1500],
        [800000, 6000],
        [2079000, 27990.06],
    ])
    def test_calculate_frequency_based_on_nrarfcn(self,
                                                  nrarfcn,
                                                  expected_freq):
        freq = self.calc.calculate_frequency_based_on_nrarfcn(nrarfcn)
        assert freq == expected_freq

    @parameterized.expand([
        [399.85, 998],
        [3721.44, 8000],
        [28466.4, 22500],
    ])
    def test_calculate_gscn(self, freq, expected_gscn):
        gscn = self.calc.calculate_gscn(freq)
        assert gscn == expected_gscn

    @parameterized.expand([
        [500, 200.45],
        [10000, 6601.44],
        [23000, 37106.4],
    ])
    def test_calculate_frequency_based_on_gscn(self, gscn, expected_freq):
        freq = self.calc.calculate_frequency_based_on_gscn(gscn)
        assert freq == expected_freq

    @parameterized.expand([
        [500, 60, False],
        [500, 120, True],
        [501, 60, False],
        [501, 120, False],
    ])
    def test_is_nrarfcn_need_alignment(self, nrarfcn, scs, expected_value):
        is_needed = self.calc.is_nrarfcn_need_alignment(nrarfcn, scs)
        assert is_needed == expected_value

    @parameterized.expand([
        [500, 120, False],
        [500, 240, False],
        [501, 120, False],
        [501, 240, True],
    ])
    def test_is_gscn_need_alignment(self, gscn, scs_ssb, expected_value):
        is_needed = self.calc.is_gscn_need_alignment(gscn, scs_ssb)
        assert is_needed == expected_value
