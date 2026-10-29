import unittest
import json
import glob


class Test(unittest.TestCase):
    def test_all_json_are_ok(self):
        for th_file in glob.glob("threshold/*.json"):
            print(f"checking {th_file} format...")
            with open(th_file, "r") as f_h:
                content = json.load(f_h)
            self.assertIsInstance(content, dict)
            self.assertTrue(content)

    def test_all_decoder_json_are_ok(self):
        for th_file in glob.glob("decoder/*.json"):
            print(f"checking {th_file} format...")
            with open(th_file, "r") as f_h:
                content = json.load(f_h)
            self.assertIsInstance(content, dict)
            self.assertTrue(content)
