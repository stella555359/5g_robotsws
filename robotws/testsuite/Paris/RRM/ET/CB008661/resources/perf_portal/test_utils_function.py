import unittest
from utils_function import get_from_insensitive_key


class Test(unittest.TestCase):
    def test_get_from_insensitive_key(self):
        dict_to_check = {
            "name": "MyName",
            "VaLue": "MyValue",
        }

        self.assertEqual(get_from_insensitive_key("name", dict_to_check), "MyName")
        self.assertEqual(get_from_insensitive_key("value", dict_to_check), "MyValue")
        self.assertRaisesRegex(
            KeyError,
            "insensitive key WorK not found",
            get_from_insensitive_key,
            "WorK",
            dict_to_check,
        )
