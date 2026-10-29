import os
import re
import StringTool


class Setting(object):
    def __init__(self, name, val):
        self.name = name
        self.val = val

    def getVal(self):
        if self.val == "True":
            return True
        if self.val == "False":
            return False
        if self.val == "None":
            return None
        return self.val


class Debug(object):
    FILE_NAME = "Debug.cfg"

    def __init__(self):
        self.settings = []
        self.path = "{}/../config/{}".format(os.path.dirname(os.path.realpath(__file__)), Debug.FILE_NAME)
        if os.path.isfile(self.path):
            f = open(self.path)
            for line in f.readlines():
                line = (line.split("#")[0]).replace(" ", "")
                m = re.match("^(\\w*)=(\\w*)$", line)
                if m:
                    self.settings.append(Setting(m.group(1), m.group(2)))
            f.close()
        self.displayAll()

    def getSetting(self, name):
        for setting in self.settings:
            if setting.name == name:
                return setting.getVal()
        return None

    def displayAll(self):
        StringTool.printLineWithTitle("DEBUG FLAGS ({})".format(self.path))
        for setting in self.settings:
            StringTool.datedConsole("   {}={}".format(setting.name, setting.val))


DebugSettings = Debug()
