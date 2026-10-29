import StringTool
import re
import sys


class TxtConfig(object):
    # List of keyword prefix that are UE dependant (and need to be embedded in a loop)
    ListUeKw = ['set_ue', 'ue_param', 'set_bearer', 'set_pdu_gateway']
    # IMSI start default value. Should be retrieved in set_ue command
    DEFAULT_IMSI_START = "12345678"
    # SUCI start default value. Should be retrieved in set_ue command
    DEFAULT_SUCI_START = "12345678"
    # PDN_IP default prefix. Should be found in PDN_IP variable setting
    DEFAULT_PDN_IP_PREFIX = "1.2.3."
    # Prefixes for lua commands language
    PRF_UEID = "ueId"
    PRF_IMSI_FIRST_UE = "IMSI_FIRST_UE"
    PRF_SUCI_FIRST_UE = "SUCI_FIRST_UE"
    PRF_CONTAINER_IP = "CONTAINER_IP"
    PRF_DAEMON_IP = "DAEMON_IP"
    PRF_DAEMON_PORT = "DAEMON_PORT"
    PRF_EDAEMON_PORT = "EDAEMON_PORT"
    PRF_SERVER_IP = "SERVER_IP"
    PRF_PDN_IP = "PDN_IP"
    PRF_PDN_IP_AIC = "PDN_IP1"
    PRF_SA_UE = "MAX_SA_UE"
    PRF_NSA_UE = "MAX_NSA_UE"
    PRF_SANSA = "mode=nr enb=2 cell=1"
    PRF_BEARER = "default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal"       # RDH: New LO_LO Variant

    def __init__(self):
        pass

    def getPath(self):
        return self.path

    def getFile(self):
        return self.name_lua

    def getFilePath(self):
        return "{}/{}".format(self.path, self.name_lua)

    def generateLuaFile(self, path, name, nbUe, nbSaUe=str(0), list_of_UE_tobe_created=None):
        if type(nbUe) is not int and type(nbSaUe) is not int:
            nbUe, nbSaUe = self._parseInputParam(nbUe, nbSaUe)
        print("[generateLuaFile] ----- nbUe={} nbSaUe={}".format(nbUe, nbSaUe))
        if int(nbSaUe) <= int(nbUe):
            self.path = path
            self.name = name
            self.nb_max_ue = nbUe
            self.nb_nsa_ue = int(nbUe) - int(nbSaUe)
            self.nb_sa_ue = nbSaUe
            self.nsa = ""
            self.sa = ""
            self.file_type = ""
            self._getUeIdBounds(self.path, self.name)
            self.name_lua = name.replace(".cfg", ".lua")
            self.is_sa_preambule_set = False
            self.is_nsa_preambule_set = False
            self.pdn_ip_prefix = TxtConfig.DEFAULT_PDN_IP_PREFIX
            self.imsi_start = TxtConfig.DEFAULT_IMSI_START
            self.suci_start = TxtConfig.DEFAULT_SUCI_START
            self.list_of_ue = list_of_UE_tobe_created
            # AiC specific treatments requested by JIRA-37191
            self.is_aic_tl = False
            self.pdu_gw_ueid = ""
            fInPath = "{}/{}".format(path, name)
            fOutPath = "{}/{}".format(path, self.name_lua)
            fIn = open(fInPath, "r")
            fOut = open(fOutPath, "w")
            lines = fIn.readlines()
            for line in lines:
                newLine = self._cfgToLuaLine(line)
                fOut.write(newLine+"\n")
            fOut.close()
            fIn.close()
            return self.name_lua
        else:
            raise Exception("Parameters error : nb of SA UEs is greater than nb max UEs ")

    def _parseInputParam(self, nbUe, nbSaUe):
        """"
        Check if params are like X+Y : if yes, estimate the X+Y and return the new value
        """
        listNbUe = [int(x) for x in nbUe.split("+")]
        listNbSaUe = [int(x) for x in nbSaUe.split("+")]
        newNbUe = sum(listNbUe)
        newNbSaUe = sum(listNbSaUe)
        return newNbUe, newNbSaUe

    def _getUeIdBounds(self, cfg_path, cfg_name):
        self.cfg_path = cfg_path
        self.cfg_name = cfg_name
        self.initial_sa_ueid = 1
        self.initial_nsa_ueid = 1
        fInPath = "{}/{}".format(self.cfg_path, self.cfg_name)
        fIn = open(fInPath, "r")
        lines = fIn.readlines()
        # read the cfg file to find the first SA and NSA Ue Id
        for line in lines:
            # Search NSA Ue Id and keep the lower NSA Ue Id:
            found_imsi = re.search(r"imsi=(\d+):(\d+):(\d+)", line)
            if found_imsi:
                found_imsi_ueid = re.search(r"set_ue simulated id=(\d+)\s", line)
                if self.nsa == "":
                    # it is the first occurrence, then we update initial_nsa_ueid and nsa
                    self.initial_nsa_ueid = found_imsi_ueid.group(1)
                    self.nsa = "NSA"
                elif int(found_imsi_ueid.group(1)) <= int(self.initial_nsa_ueid):
                    # it is not first occurrence: update initial_nsa_ueid only if ue id is less than previous
                    self.initial_nsa_ueid = found_imsi_ueid.group(1)
            # Search SA Ue Id and keep the lower SA Ue Id:
            found_suci = re.search(r"suci=(\d+):(\d+):(\d+):(\d+):(\d+):(\d+):(\d+)", line)
            if found_suci:
                found_suci_ueid = re.search(r"set_ue simulated id=(\d+)\s", line)
                if self.sa == "":
                    # it is the first occurence, then we update initial_nsa_ueid and nsa
                    self.initial_sa_ueid = found_suci_ueid.group(1)
                    self.sa = "SA"
                elif int(found_suci_ueid.group(1)) <= int(self.initial_sa_ueid):
                    # it is not first occurence: update initial_nsa_ueid only if ue id is less than previous
                    self.initial_sa_ueid = found_suci_ueid.group(1)

        # Set the cfg file type:
        self.file_type = self.sa + self.nsa
        # Set the first and last id for SA and NSA UEs:
        if int(self.nb_sa_ue) > 0:
            # case SANSA : 1st NSA UE=1 , last NSA UE = nb_nsa_ue , first SA UE = nb_nsa_ue+1, last SA UE = nbMax
            if int(self.nb_nsa_ue) > 0:
                self.first_nsa_ue_id = 1
                self.last_nsa_ue_id = int(self.nb_nsa_ue)
                self.first_sa_ue_id = int(self.nb_nsa_ue) + 1
                self.last_sa_ue_id = self.nb_max_ue
            else:
                self.first_nsa_ue_id = 0
                self.last_nsa_ue_id = 0
                self.first_sa_ue_id = 1
                self.last_sa_ue_id = self.nb_sa_ue
        else:
            self.first_sa_ue_id = 0
            self.last_sa_ue_id = 0
            self.first_nsa_ue_id = 1
            self.last_nsa_ue_id = self.nb_nsa_ue
        fIn.close()

    def _cfgToLuaLine(self, line):
        # No changes for : empty lines, comments (#)
        line = line.strip()
        if len(line) == 0:
            return line
        # All lines starting with # are comments only
        if line.startswith("#"):
            return "---{}".format(line)
        # for all comment part (#...) in the middle of string, we use lua comment : ---#
        if "#" in line:
            line = line.replace("#", "---#")
        # RDH: New LO_LO Variant:
        # new code to process new param defined without double quote like UE CAPABILITIES:
        if re.match(r"^set ", line) and '="' not in line and '$' not in line:
            line = self._addDoubleQuote(line)

        # Catching PDN_IP if found
        found_pdn_ip = re.search(r" {}=\"(\d+)\.(\d+)\.(\d+).(\d+)\"".format(TxtConfig.PRF_PDN_IP), line)
        if found_pdn_ip:
            self.pdn_ip_prefix = "{}.{}.{}.".format(found_pdn_ip.group(1),
                                                    found_pdn_ip.group(2),
                                                    found_pdn_ip.group(3))

        # AiC specific treatments requested by JIRA-37191
        # To Be Optimized or ReDesigned if the basic_setup.cfg file delivered for AiC is modified
        # Catching PRF_PDN_IP_AIC if found
        found_pdn_ip_aic = re.search(r" {}=\"(\d+)\.(\d+)\.(\d+).(\d+)\"".format(TxtConfig.PRF_PDN_IP_AIC), line)
        if found_pdn_ip_aic:
            self.is_aic_tl = True
            self.pdn_ip_prefix_aic = "{}.{}.{}.".format(found_pdn_ip_aic.group(1),
                                                        found_pdn_ip_aic.group(2),
                                                        found_pdn_ip_aic.group(3))

        # Catching set_nwslice if found
        found_nwslice = re.search(r"set_nwslice id=[0-9]\s", line)
        if found_nwslice:
            line = line.replace("ue=1", "ue=all")
        # Catching Container Ip if found:
        found_container_ip = re.search(r"set CONTAINER_IP=\"(\d+)\.(\d+)\.(\d+).(\d+)\"", line)
        if found_container_ip:
            self.container_ip = "{}.{}.{}.{}"\
                .format(found_container_ip.group(1),
                        found_container_ip.group(2),
                        found_container_ip.group(3),
                        found_container_ip.group(4))
            # Create the new container ip, server ip and daemon ip lines:
            line = "{}=\"{}\"\n{}=\"{}\"\n{}=\"{}\""\
                .format(TxtConfig.PRF_CONTAINER_IP, self.container_ip,
                        TxtConfig.PRF_SERVER_IP, self.container_ip,
                        TxtConfig.PRF_DAEMON_IP, self.container_ip)
            return line
        # Removing the "set SERVER_IP=$CONTAINER_IP" and "set DAEMON_IP=$CONTAINER_IP" lines if found:
        if re.match(r"^set (SERVER|DAEMON)_IP=.*CONTAINER_IP.*$", line):
            return ""
        # Catching EDAEMON_PORT if found:
        found_container_port = re.search(r"set EDAEMON_PORT=\"(\d+)\"", line)
        if found_container_port:
            # Create the new lines daemon port and edaemon port
            line = "{}=\"{}\"\n{}=\"{}\""\
                .format(TxtConfig.PRF_DAEMON_PORT, found_container_port.group(1),
                        TxtConfig.PRF_EDAEMON_PORT, found_container_port.group(1))
            return line
        # Removing the "set DAEMON_PORT=
        if re.match(r"^set DAEMON_PORT=.*EDAEMON_PORT.*$", line):
            return ""
        # AiC specific treatments requested by JIRA-37191
        # To Be Optimized or ReDesigned if the basic_setup.cfg file delivered for AiC is modified
        if self.is_aic_tl:
            # Comment the "set UE2_PDN_IP" line if found:
            found_ue2_pdn_ip = re.search(r"set UE2_PDN_IP=", line)
            if found_ue2_pdn_ip:
                return line.replace(r"set UE2_PDN_IP=", r"---#set UE2_PDN_IP=")
            # Comment the "set_ue simulated id=2 " line if found:
            found_ue2_simulated = re.search(r"set_ue simulated id=2 ", line)
            if found_ue2_simulated:
                return line.replace(r"set_ue simulated id=2 ", r"---#set_ue simulated id=2 ")
            # Comment the "ue_param id=2 " line if found:
            found_ue2_param = re.search(r"ue_param id=2 ", line)
            if found_ue2_param:
                return line.replace(r"ue_param id=2 ", r"---#ue_param id=2 ")
            # Comment the "set_bearer id=2 ue=2 " line if found:
            found_set_bearer_ue2 = re.search(r"set_bearer id=2 ue=2 ", line)
            if found_set_bearer_ue2:
                return line.replace(r"set_bearer id=2 ue=2 ", r"---#set_bearer id=2 ue=2 ")

        # Variable Setting line : removing "set "
        if line.startswith("set "):
            return line.replace("set ", "")
        # Other lines : conversion to exec lua command
        new_line = self._cfgToLuaKw(line)
        # Return modified line
        return new_line

    def _cfgToLuaKw(self, line):
        # Determine if this is a ue KW
        is_ue_kw = self._isUeKw(line)
        # First embrace string with : exec('...')
        new_line = "exec('{}')".format(line)
        # Replace all "daemon=$SERVER_IP" with "daemon=$DAEMON_IP"
        new_line = re.sub(r"daemon=\$SERVER_IP", r"daemon='..DAEMON_IP..'", new_line)
        # Replace all $<var> with '..<var>..'
        new_line = re.sub(r"\$(\w+)", r"'..\1..'", new_line)
        # Put line in a loop if this is a Ue KW
        if is_ue_kw:
            # Catch IMSI if present:
            new_line, imsi_line = self._foundImsi(new_line)
            # Catch SUCI if present:
            new_line, suci_line = self._foundSuci(new_line)
            # Catch SA ue_param if present:
            sa_param = self._getSaUeParam(new_line)
            # Catch NSA ue_param if present:
            nsa_param = self._getNsaUeParam(new_line)
            # Catch PDU Gateway if present:
            new_line, pdugw_line = self._getPduGateway(new_line)
            # Replacing static id for ue with ueId index from for loop
            # For set_bearer, id don't move : this is id for bearer
            # For others, id is ueId, so update it with ueIdIndex
            new_line, bearer_line = self._getBearer(new_line)
            # Replacing static ip with computed one:
            new_line = self._setStaticIp(new_line)

            # AiC specific treatments requested by JIRA-37191
            # To Be Optimized or ReDesigned if the basic_setup.cfg file delivered for AiC is modified
            if self.is_aic_tl:
                new_line = self._setStaticIpAic(new_line)

            # Remove "..''" occurrences, meaning if a variable was in end of setting, no ..' is required:
            new_line = self._removeDot(new_line)

            if self.list_of_ue and line.startswith("set_ue") and suci_line:
                # We must set cell and id as provide in ue list
                ue_line = ''
                for ue in self.list_of_ue:
                    line = re.sub(r"id='..ueId..' ", r"id={} ".format(ue.ue), new_line)
                    line = re.sub(r"cell=(\d+)\s*", r"cell={} ".format(ue.target_cells), line)
                    line = re.sub(r"'\.\.SUCI_FIRST_UE \+ ueId - 1",
                                  r"{}'".format(int(self.suci_start) + int(ue.ue) - 1), line)
                    ue_line = ue_line+'\n'+line
                ue_line = self._addMinMax(ue_line, "SA")
                return ue_line
            else:
                # Put line in a for loop if necessary:
                new_line = self._putLineIntoForLoop(new_line, imsi_line, suci_line,
                                                    nsa_param, sa_param, bearer_line, pdugw_line)
            # Insert MIN and MAX variables if required:
            if not self.is_sa_preambule_set and suci_line and self.first_sa_ue_id != 0:
                new_line = self._addMinMax(new_line, "SA")
            if not self.is_nsa_preambule_set and imsi_line and self.first_nsa_ue_id != 0:
                new_line = self._addMinMax(new_line, "NSA")
        return new_line

    def _isUeKw(self, line):
        for ue_kw in TxtConfig.ListUeKw:
            if line.startswith("{} ".format(ue_kw)):
                return True
        return False

    def _foundImsi(self, line):
        found = re.search(r"imsi=(\d+):(\d+):(\d+)", line)
        if found and self.first_nsa_ue_id != 0:
            self.imsi_start = found.group(3)
            # Replacing static IMSI with computed one
            line = re.sub(r"imsi=(\d+):(\d+):(\d+)",
                          r"imsi=\1:\2:'..{} + {} - 1..'".format(TxtConfig.PRF_IMSI_FIRST_UE, TxtConfig.PRF_UEID),
                          line)
        return line, found

    def _foundSuci(self, line):
        found = re.search(r"suci=(\d+):(\d+):(\d+):(\d+):(\d+):(\d+):(\d+)", line)
        if found and self.first_sa_ue_id != 0:
            self.suci_start = found.group(7)
            self.suci_start = re.sub(r'.', '', self.suci_start, count=1)
            # Replacing static SUCI with computed one
            line = re.sub(r"{}".format(TxtConfig.PRF_SANSA), "", line)
            line = re.sub(r"suci=(\d+):(\d+):(\d+):(\d+):(\d+):(\d+):(\d+)",
                          r"{} suci=\1:\2:\3:\4:\5:\6:0'..{} + {} - 1..'"
                          .format(TxtConfig.PRF_SANSA, TxtConfig.PRF_SUCI_FIRST_UE, TxtConfig.PRF_UEID),
                          line)
        return line, found

    def _getSaUeParam(self, line):
        # RDH: New LO_LO Variant:
        # RDH: remove previous code:
        # return re.search(r"ue_param id=[0-9]+\s+ue_nr_capabilities=[a-fA-F0-9]+",
        #                  line)
        # RDH: add new code:
        found1 = re.search(r"ue_param id=", line)
        found2 = re.search(r"ue_nr_capabilities=", line)
        found3 = re.search(r"ue_eutra_nr_capabilities=", line)
        found4 = re.search(r"ue_nr_capabilities=$", line)
        found5 = re.search(r"ue_nr_capabilities=[\w]+", line)
        found6 = re.search(r"ue_nr_capabilities='\.\.", line)
        if found1 is not None and \
                found2 is not None and \
                found3 is None:
            if found4 is not None:
                return re.sub(r"ue_param id=[0-9]+\s+ue_nr_capabilities=\$(\w+)",
                              r"ue_param id=[0-9]+\s+ue_nr_capabilities='..\1..'",
                              line)
            elif found5 is not None:
                return re.search(r"ue_param id=[0-9]+\s+ue_nr_capabilities=[a-fA-F0-9]+",
                                 line)
            elif found6 is not None:
                return re.search(r"ue_param id=[0-9]+\s+ue_nr_capabilities='..[\w]+..'",
                                 line)
            else:
                print(">>> ERROR UNKNOWN SA UE_PARAM SYNTAX: >>>{}<<<".format(line))
                return None

    def _getNsaUeParam(self, line):
        # RDH: New LO_LO Variant:
        # RDH: remove previous code:
        # return re.search(r"ue_param id=[0-9]+\s+ue_nr_capabilities=[\w]+\s+\w+=\w+\s+ue_eutra_nr_capabilities=[\w]+",
        #                  line)
        # RDH: add new code:
        found1 = re.search(r"ue_param id=", line)
        found2 = re.search(r"ue_nr_capabilities=", line)
        found3 = re.search(r"ue_eutra_nr_capabilities=", line)

        found4 = re.search(r"ue_nr_capabilities=$", line)
        found5 = re.search(r"ue_eutra_nr_capabilities=$", line)

        found6 = re.search(r"ue_nr_capabilities=[\w]+", line)
        found7 = re.search(r"ue_eutra_nr_capabilities=[\w]+", line)

        found8 = re.search(r"ue_nr_capabilities='\.\.", line)
        found9 = re.search(r"ue_eutra_nr_capabilities='\.\.", line)

        if found1 is not None and \
                found2 is not None and \
                found3 is not None:
            # line is an ue_param for NSA UE
            if found4 is not None:
                line_part1 = re.sub(r"ue_param id=[0-9]+\s+ue_nr_capabilities=\$(\w+)\s",
                                    r"ue_param id=[0-9]+\s+ue_nr_capabilities='..\1..'",
                                    line)
            elif found6 is not None:
                line_part1 = re.search(r"(ue_param id=[0-9]+\s+ue_nr_capabilities=[\w]+\s)",
                                       line)
                line_part1 = line_part1.group(0)
            elif found8 is not None:
                line_part1 = re.search(r"ue_param id=[0-9]+\s+ue_nr_capabilities='..[\w]+..'\s",
                                       line)
                line_part1 = line_part1.group(0)
            else:
                print(">>> ERROR UNKNOWN SYNTAX IN NSA UE_PARAM NR_CAPA ITEM: >>>{}<<<".format(line))
                line_part1 = "UNKNOWN NSA UE_NR_CAPA SYNTAX"

            line_part2 = "dual_conn=eutra_nr"

            if found5 is not None:
                line_part3 = re.sub(r"\s+ue_eutra_nr_capabilities=\$(\w+)",
                                    r" ue_eutra_nr_capabilities='..\2",
                                    line)
            elif found7 is not None:
                line_part3 = re.search(r"(\sue_eutra_nr_capabilities=[\w]+)",
                                       line)
                line_part3 = line_part3.group(0)
            elif found9 is not None:
                line_part3 = re.search(r"\sue_eutra_nr_capabilities='..[\w]+..'",
                                       line)
                line_part3 = line_part3.group(0)
            else:
                print(">>> ERROR UNKNOWN SYNTAX IN NSA UE_PARAM EUTRA_NR_CAPA ITEM: >>>{}<<<".format(line))
                line_part3 = "UNKNOWN NSA UE_EUTRA_NR_CAPA SYNTAX"

            line = line_part1 + line_part2 + line_part3
            return line
        return None

    def _getPduGateway(self, line):
        found = re.search(r"set_pdu_gateway id=(\d+)\s", line)
        if found:
            self.pdu_gw_ueid = found.group(1)
            line = re.sub(r"set_pdu_gateway=(\d+) ",
                          r"set_pdu_gateway='..ueId..' ", line)
            # Replacing ue_nat_ip static ip with computed one:
            line = re.sub(r"ue_nat_ip=(\d+).(\d+).(\d+).(\d+)",
                          r"ue_nat_ip=\1.\2.\3.'..{}..'".format(TxtConfig.PRF_UEID), line)
        return line, found

    def _getBearer(self, line):
        found = re.search(r"set_bearer id=[0-9] ue=(\d+)", line)
        if found:
            self.set_bearer_ueid = found.group(1)
            line = re.sub(r"ue=(\d*) ", "ue='..ueId..' ", line)
            # RDH: New LO_LO Variant:
            line = re.sub(r" ip='..PDN_IP(\d*)..' (.+)",
                          " {} ip=4.7.254.'..ueId + 100)".format(TxtConfig.PRF_BEARER),
                          line)
        else:
            line = re.sub(r"id=(\d*) ", "id='..ueId..' ", line)
        return line, found

    def _setStaticIp(self, line):
        return re.sub(r" ip='..{}..' ".format(TxtConfig.PRF_PDN_IP),
                      " ip={}'..ueId..' ".format(self.pdn_ip_prefix), line)

    def _setStaticIpAic(self, line):
        return re.sub(r" ip='..{}..' ".format(TxtConfig.PRF_PDN_IP_AIC),
                      " ip={}'..ueId..' ".format(self.pdn_ip_prefix_aic), line)

    def _removeDot(self, line):
        line = re.sub("..''", "", line)
        line = re.sub("..' '", "", line)
        return line

    def _addMinMax(self, line, file_type):
        if file_type == "SA":
            line = "{} = {}\n{} = {}\n{}".format(TxtConfig.PRF_SA_UE, self.last_sa_ue_id,
                                                 TxtConfig.PRF_SUCI_FIRST_UE, self.suci_start, line)
            self.is_sa_preambule_set = True
        elif file_type == "NSA":
            line = "{} = {}\n{} = {}\n{}" .format(TxtConfig.PRF_NSA_UE, self.last_nsa_ue_id,
                                                  TxtConfig.PRF_IMSI_FIRST_UE, self.imsi_start, line)
            self.is_nsa_preambule_set = True
        return line

    # RDH: New LO_LO Variant
    def _addDoubleQuote(self, line):
        list = line.split("=")
        new_line = list[0] + '="' + list[1] + '"'
        return new_line

    # RDH: New LO_LO Variant : previous function is renamed with _old
    def _putLineIntoForLoop_Old(self, line, imsi_l, suci_l, nsaparam_l, saparam_l, bearer_l, pdugw_l):
        # If basic_wts file is SANSA type:
        if self.file_type == 'SANSA':
            # if the line contains NSA parameters:
            if self.first_nsa_ue_id != 0 and \
                    (imsi_l or nsaparam_l or bearer_l or (pdugw_l and self.pdu_gw_ueid == self.initial_nsa_ueid)):
                line = "for {} = {}, {}\ndo\n\t{}\nend\n".format(TxtConfig.PRF_UEID,
                                                                 self.first_nsa_ue_id,
                                                                 TxtConfig.PRF_NSA_UE, line)
            # if the line contains SA parameters:
            elif self.first_sa_ue_id != 0 and \
                    (suci_l or saparam_l or (pdugw_l and self.pdu_gw_ueid == self.initial_sa_ueid)) and not nsaparam_l:
                line = "for {} = {}, {}\ndo\n\t{}\nend\n".format(TxtConfig.PRF_UEID,
                                                                 self.first_sa_ue_id,
                                                                 TxtConfig.PRF_SA_UE, line)
            elif self.first_sa_ue_id == 0:
                line = ""
            elif self.first_nsa_ue_id == 0:
                line = ""
        # If basic_wts file is SA type:
        elif self.file_type == 'SA':
            print("_putLineIntoForLoop ---- doing SA cause self.file_type: {}".format(self.file_type))
            line = "for {} = {}, {}\ndo\n\t{}\nend\n".format(TxtConfig.PRF_UEID,
                                                             self.initial_sa_ueid,
                                                             TxtConfig.PRF_SA_UE, line)
        # If basic_wts file is NSA type:
        elif self.file_type == 'NSA':
            print("_putLineIntoForLoop ---- doing NSA cause self.file_type: {}".format(self.file_type))
            line = "for {} = {}, {}\ndo\n\t{}\nend\n" .format(TxtConfig.PRF_UEID,
                                                              self.initial_nsa_ueid,
                                                              TxtConfig.PRF_NSA_UE, line)
        return line

    # RDH: New LO_LO Variant: new code for the putLineIntoForLoop
    def _putLineIntoForLoop(self, line, imsi_l, suci_l, nsaparam_l, saparam_l, bearer_l, pdugw_l):
        # If basic_wts file is SANSA type:
        if self.file_type == 'SANSA':
            # if the line contains NSA parameters:
            if (imsi_l is not None or nsaparam_l is not None or bearer_l is not None or
                    (pdugw_l is not None and self.pdu_gw_ueid == self.initial_nsa_ueid)):
                if self.first_nsa_ue_id != 0:
                    line = "for {} = {}, {}\ndo\n\t{}\nend\n".\
                        format(TxtConfig.PRF_UEID,
                               self.first_nsa_ue_id,
                               TxtConfig.PRF_NSA_UE,
                               line)
                else:
                    line = ""
            # if the line contains SA parameters:
            elif (suci_l is not None or saparam_l is not None or
                  (pdugw_l is not None and self.pdu_gw_ueid == self.initial_sa_ueid)):
                if self.first_sa_ue_id != 0:
                    line = "for {} = {}, {}\ndo\n\t{}\nend\n".\
                        format(TxtConfig.PRF_UEID,
                               self.first_sa_ue_id,
                               TxtConfig.PRF_SA_UE,
                               line)
                else:
                    line = ""
            elif self.first_sa_ue_id == 0:
                line = ""
            elif self.first_nsa_ue_id == 0:
                line = ""
        # If basic_wts file is SA type:
        elif self.file_type == 'SA':
            print("_putLineIntoForLoop ---- doing SA cause self.file_type: {}".format(self.file_type))
            line = "for {} = {}, {}\ndo\n\t{}\nend\n".format(TxtConfig.PRF_UEID,
                                                             self.initial_sa_ueid,
                                                             TxtConfig.PRF_SA_UE, line)
        # If basic_wts file is NSA type:
        elif self.file_type == 'NSA':
            print("_putLineIntoForLoop ---- doing NSA cause self.file_type: {}".format(self.file_type))
            line = "for {} = {}, {}\ndo\n\t{}\nend\n" .format(TxtConfig.PRF_UEID,
                                                              self.initial_nsa_ueid,
                                                              TxtConfig.PRF_NSA_UE, line)
        return line
