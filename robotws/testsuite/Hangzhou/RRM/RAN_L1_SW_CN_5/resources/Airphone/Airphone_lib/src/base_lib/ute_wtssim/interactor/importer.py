# -*- coding: utf-8 -*-

from importlib import import_module


class NonDotClientImporter(object):
    def import_client(self, module_name):
        module = import_module(module_name)
        if hasattr(module, module_name):
            return getattr(module, module_name)()
        return module


class DotClientImporter(object):
    def import_client(self, path):
        module_part, class_part = path.rsplit('.', 1)
        try:
            module = import_module(path)
            if hasattr(module, class_part):
                return getattr(module, class_part)()
            return module
        except ImportError:
            module = import_module(module_part)
            if hasattr(module, class_part):
                return getattr(module, class_part)()
