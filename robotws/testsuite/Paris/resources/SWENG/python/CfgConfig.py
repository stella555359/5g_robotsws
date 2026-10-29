import os
import re
import Topology


class CfgConfig():
    """
    This class encapsulates a modificator object, that offers capabilities to
    - start a modification session on CFG config file
    - perform get/set values of a specific parameters
    - remove configuration line from WTS CFG file
    - insert a configuration line at a specific position on WTS CFG file
    - replace the old value of a parameter with a new one
    - end modification session (flush modifications in file)
    """
    def __init__(self):
        self.ismodified = False

    def startSession(self, path):
        """
        Start a modification session on a WTS CFG file
        """
        self.local_path = path
        with open(self.local_path, "r") as cfg_file:
            self.config = cfg_file.readlines()

    def stopSession(self):
        """
        End a modification session on the WTS CFG config file
        This session should have been previously begun by a startSession() call
        It will write the modified configuration in the local file
        """
        if self.ismodified:
            with open(self.local_path, "w") as new_cfg:
                new_cfg.write("".join(self.config))
        return self.ismodified

    def stopSessionInNewFile(self, newFile):
        """
        End a modification session on the WTS XML config file
        This session should have been previously begun by a startSession() call
        It will flush all modifications in new specified file
        """
        with open(newFile, 'w') as new_cfg:
            new_cfg.write("".join(self.config))
        return newFile

    def insertConfig(self, cfg, line):
        """
        insert a configuration at a specific line on the WTS CFG file
        """
        self.config.insert(int(line), cfg + "\n")
        self.ismodified = True

    def appendConfig(self, cfg, line):
        """
        add a configuration at the end of the line in cfg WTS file
        """
        self.config[int(line)] = self.config[int(line)].strip("\n")
        self.config[int(line)] = self.config[int(line)]+" "+cfg+"\n"
        self.ismodified = True

    def getIndex(self, prefix, param, occurrence=1, ignoreComments="false"):
        """
        each parameter is identified by a prefix
        if occurrence is positive, it will return the i th first occurrence
        if it is negative it will retur the i th last occurrence
        Exemple:
        if occurrence =-1, it will return the line of the last occurrence of this param
        """
        ignore_com = True if ignoreComments.lower() == "true" else False
        occ = 0
        if occurrence > 0:
            rg = range(len(self.config))
        else:
            rg = reversed(range(len(self.config)))
        for index in rg:
            if param in self.config[index] and prefix in self.config[index] and \
               (not (self.config[index].startswith("#") and ignore_com)):
                occ += 1
            if occ == abs(occurrence):
                return index
        raise Exception(' {} not found in cfg file '.format(param))

    def getCellsList(self, prefix, param="id", arfcn="nr_arfcn"):
        """
        ...
        """
        cell_list = list()
        ignore_com = True
        rg = range(len(self.config))
        for index in rg:
            if param in self.config[index] and prefix in self.config[index] and arfcn in self.config[index] and \
               (not (self.config[index].startswith("#") and ignore_com)):
                params = dict((j.split("=")[0], j.split("=")[1]) for j in self.config[index].split() if "=" in j)
                cell = params[param]
                cell_list.append(cell)
        return cell_list

    def replaceValue(self, prefix, param, oldValue, newValue, occurrence=1, ignoreComments="false"):
        """"
        replace the old value of a parameter with a new value
        """
        topo = Topology.Topology()
        if prefix == 'ue_param' and 'SANSA' in topo.getTopoStr():
            # WA needed for SANSA topology since there are 2 UE's: id 1 and 11
            # RDH - New LO_AP_LO Variant
            # Issue : the following code should be adapted as UE Ids are changed in new basic_setup.cfg
            # Pb: how to remove the hardcoded values 1 and 11 ?
            # RDH: "old" hardcoded code:
            ind = self.getIndexUsingParam(prefix, "id", "1", "true")
            self.config[ind] = self.config[ind].replace(oldValue, newValue, 1)
            ind = self.getIndexUsingParam(prefix, "id", "11", "true")
            # RDH: "new" hardcoded code:
            # ind = self.getIndexUsingParam(prefix, "id", "1", "true")
            # ind = self.getIndexUsingParam(prefix, "id", "101", "true")
            # oldValue = self.getValue(prefix, param, -1)
            self.config[ind] = self.config[ind].replace(oldValue, newValue, 1)
        else:
            ind = self.getIndex(prefix, param, int(occurrence), ignoreComments)
            # replace "$" by "\$" (otherwise operation is failed if the old value contains '$')
            tmpOldValue = oldValue.replace("$", "\\$")
            self.config[ind] = re.sub(
                 '{}={}( |$)'.format(param, tmpOldValue),
                 '{}={} '.format(param, newValue), self.config[ind])
        self.ismodified = True

    def deleteConfig(self, line):
        """"
        delete a configuration line from WTS CFG file
        """
        del self.config[int(line)]
        self.ismodified = True

    def getValue(self, prefix, param, occurrence=1, ignoreComments="false"):
        """
        return the value of a parameter
        """
        ind = self.getIndex(prefix, param, int(occurrence), ignoreComments)
        line = self.config[ind][1:]
        params = dict((j.split("=")[0], j.split("=")[1]) for j in line.split() if "=" in j)
        return params[param]

    def appendStringToFile(self, string):
        """"
        append the string to the end of file
        """
        with open(self.local_path, "a") as cfg_file:
            cfg_file.write(string)
            cfg_file.close()

        with open(self.local_path, "r") as cfg_file:
            self.config = cfg_file.readlines()

    def addStringBeforeLine(self, string, line):
        """"
        append the string before the given line
        string = string to be added
        line = regular expression corresponding to the line to be searched
        """

        tmp_cfg_file = "{}.tmp".format(self.local_path)

        # Read each line L of the config file
        #     If the line matches the regular expression given by "line" parameter
        #        Add the "string" given as parameter to the temporary file
        #     Write L to the temporary file
        with open(tmp_cfg_file, "w") as tmp_cfg_file_fd:
            with open(self.local_path, "r") as cfg_file_fd:
                for cfg_line in cfg_file_fd:
                    if (re.match(line, cfg_line) is not None):
                        tmp_cfg_file_fd.write(string+"\n")
                    tmp_cfg_file_fd.write(cfg_line)
                cfg_file_fd.close()
            tmp_cfg_file_fd.close()

        # copy/rename the temporary file
        os.rename(tmp_cfg_file, self.local_path)

        with open(self.local_path, "r") as cfg_file_fd:
            self.config = cfg_file_fd.readlines()

    def getIndexUsingParam(self, prefix, paramId, paramVal, ignoreComments="false"):
        """
        return the index of the line containing the provided parameters
        prefix   : the pattern found at the beginning of line
        paramId  : the parameter identifier
        paramVal : the parameter value
        ignoreComments : set to True to ignore all comments
        """
        ignore_com = True if ignoreComments.lower() == "true" else False
        nbLine = range(len(self.config))
        for index in nbLine:
            if paramId in self.config[index] and prefix in self.config[index] and \
               (not (self.config[index].startswith("#") and ignore_com)):
                line = self.config[index][1:]
                paramList = dict((j.split("=")[0], j.split("=")[1]) for j in line.split() if "=" in j)
                if paramList[paramId] == paramVal:
                    return index
        raise Exception(' {} {} not found in cfg file '.format(prefix, paramId))

    def getListIdxsUsingListParam(self, listParams, ignoreComments="false"):
        """
        return the index of the list of lines containing the provided parameters
        prefix   : the pattern found at the beginning of line
        listParams  : list of elements to identify the line
        ignoreComments : set to True to ignore all comments
        """
        ignore_com = True if ignoreComments.lower() == "true" else False
        nbLine = range(len(self.config))
        listIdx = []
        for index in nbLine:
            found = 0
            for param in listParams:
                if param in self.config[index]:
                    # line = self.config[index][0:]
                    found += 1
            if found == len(listParams):
                listIdx.append(index)
        return listIdx

    def getConfigLineUsingIndex(self, index, startingChar=1):
        """
        return the line corresponding to the index given as parameter
        index : index of the line to be retrieved
        """

        line = self.config[index][startingChar:]

        return line

    def getConfigLineUsingParam(self, prefix, paramId, paramVal, ignoreComments="false"):
        """
        return the line corresponding to the given parameters
        prefix   : the pattern found at the beginning of line
        paramId  : the parameter identifier
        paramVal : the parameter value
        ignoreComments : set to True to ignore all comments
        """

        index = self.getIndexUsingParam(prefix, paramId, paramVal, ignoreComments)
        line = self.getConfigLineUsingIndex(index)

        return line
