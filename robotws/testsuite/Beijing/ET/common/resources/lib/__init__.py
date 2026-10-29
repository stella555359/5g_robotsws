import os
import sys

lib_root = os.path.abspath(os.path.dirname(__file__))
# lib_root in sys.path and sys.path.remove(lib_root)
# lib_root in sys.path or sys.path.insert(0, lib_root)
print("lib_root:", lib_root)
