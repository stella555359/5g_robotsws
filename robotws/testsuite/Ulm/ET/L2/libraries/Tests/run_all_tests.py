import unittest
import os

loader = unittest.TestLoader()
tests = loader.discover(os.path.dirname(__file__), pattern="*test_*")
unittest.TextTestRunner(verbosity=2).run(tests)
