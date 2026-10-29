import os
import StringTool
import EnvironmentManager
from robot.libraries.BuiltIn import BuiltIn
import re
import json


# =================================================================================================
class Tag(object):
    def __init__(self, tag, name=None):
        self.tag = tag
        self.name = name
        if name is None:
            self.name = tag

    def __str__(self):
        return self.name

    def __eq__(self, other):
        return self.tag == other.tag

    # def matches(self, str):
    #     return "_{}_".format(self.tag) in str or str.endswith("_{}".format(self.tag))
    def matches(self, str):
        # Standard cases: tag surrounded by underscores, at the end, or with 'x' prefix (e.g. 3xAP_LOOO)
        if f"_{self.tag}_" in str or str.endswith(f"_{self.tag}") or f"x{self.tag}" in str:
            return True
        # Handle cases like _AP_<number>[TAG] or _AP_[TAG] (e.g. _AP_3[LOOO], _AP_[LOOO], _AP_6[LOOO])
        import re
        tag_core = self.tag
        if tag_core.startswith("AP_"):
            tag_core = tag_core[3:]
        pattern = fr"_AP_\d*\[{tag_core}]"
        if re.search(pattern, str):
            return True
        return False


# =================================================================================================
class ChoiceOf(object):
    def __init__(self, listKw):
        self.tag = self.getTagFromList(listKw, self.getListTag())

    def __str__(self):
        return self.tag.name

    def getTagFromList(self, str, listTag):
        for tag in listTag:
            if tag.matches(str):
                return tag
        if len(tag.tag) == 0:
            return listTag[0]
        myStr = ','.join(x.tag for x in listTag)
        raise Exception(f"Unable to get {type(self)} in '{str}'. Possible tags are : {myStr}")
        return None

    def removeTag(self, str):
        return str.replace(f"_{self.tag.tag}", "")

    def getTag(self):
        return self.tag.tag


# =================================================================================================
class Archi(ChoiceOf):
    CLASSICAL = "Classical"
    # CLOUD_BTS = "CloudBTS"
    AIC_BTS = "AicBTS_vRAN NIC"
    AIC_RINLINE2 = "AicBTS_vRAN NIC RINLINE2"
    AIC_RINLINE2_DC = "AicBTS_vRAN NIC RINLINE2 DC"
    AIC_RINLINE2_LOO_DC = "AicBTS_vRAN NIC RINLINE2 LOO DC"
    TAG_ARCHI_CLASSICAL = Tag("5G", CLASSICAL)
    TAG_ARCHI_AIC_BTS = Tag("5GC_dRNIC_1vDU_O_AP_LO", AIC_BTS)
    TAG_ARCHI_AIC_RINLINE2 = Tag("5GC_dRNIC_1vDU_P_AP_LO_SWFH", AIC_RINLINE2)
    TAG_ARCHI_AIC_RINLINE2_DC = Tag("5GC_dRNIC_1vDU_P_AP_LO_DC", AIC_RINLINE2_DC)
    TAG_ARCHI_AIC_RINLINE2_LOO_DC = Tag("5GC_dRNIC_1vDU_P_AP_LOO_DC", AIC_RINLINE2_LOO_DC)

    def getListTag(self):
        return [Archi.TAG_ARCHI_AIC_BTS,
                Archi.TAG_ARCHI_CLASSICAL,
                Archi.TAG_ARCHI_AIC_RINLINE2_DC,
                Archi.TAG_ARCHI_AIC_RINLINE2_LOO_DC,
                Archi.TAG_ARCHI_AIC_RINLINE2
                ]

    def isClassical(self):
        return self.tag == Archi.TAG_ARCHI_CLASSICAL

    def isAic(self):
        return self.tag == Archi.TAG_ARCHI_AIC_RINLINE2 or self.tag == Archi.TAG_ARCHI_AIC_BTS or \
               self.tag == Archi.TAG_ARCHI_AIC_RINLINE2_DC or self.tag == Archi.TAG_ARCHI_AIC_RINLINE2_LOO_DC

    def isRinLine2(self):
        return self.tag == Archi.TAG_ARCHI_AIC_RINLINE2 or self.tag == Archi.TAG_ARCHI_AIC_RINLINE2_DC or \
               self.tag == Archi.TAG_ARCHI_AIC_RINLINE2_LOO_DC


# =================================================================================================
class GnbHw(ChoiceOf):
    def getListTag(self):
        return [Tag("BL", "ASIB/ABIL"), Tag("BLL", "ASIB/2ABIL"), Tag("BLLL", "ASIB/3ABIL"),
                Tag("BO", "ASIB/ABIO"), Tag("BOO", "ASIB/2ABIO"), Tag("BOOO", "ASIB/3ABIO"),
                Tag("BN", "ASIB/ABIN"), Tag("BNN", "ASIB/2ABIN"), Tag("BNNN", "ASIB/3ABIN"),
                Tag("KL", "ASIK/ABIL"), Tag("KLL", "ASIK/2ABIL"), Tag("KLLL", "ASIK/3ABIL"),
                Tag("LO", "ASIL/ABIO"), Tag("LOO", "ASIL/2ABIO"), Tag("LOOO", "ASIL/3ABIO"),
                Tag("LN", "ASIL/ABIN"), Tag("LNN", "ASIL/2ABIN"), Tag("LNNN", "ASIL/3ABIN"),
                Tag("LP", "ASIL/ABIP"), Tag("LPP", "ASIL/2ABIP"), Tag("LPPP", "ASIL/3ABIP"),
                Tag("LPQ", "ASIL/ABIP/ABIQ"),
                Tag("MO", "ASIM/ABIO"), Tag("MOO", "ASIM/2ABIO"), Tag("MOOO", "ASIM/3ABIO"),
                Tag("MP", "ASIM/ABIP"), Tag("MPP", "ASIM/2ABIP"), Tag("MPPP", "ASIM/3ABIP"),
                Tag("O_E", "ASOE"), Tag("1vDU", "1 VDU"),
                Tag("O_H", "ASOH"), Tag("1vDU", "1 VDU")]

    @staticmethod
    def bracketedStrToList(str):
        # convert a str : "[xx][yy]..[zz]" into a list : xx,yy,zz
        return str.replace("][", "*").replace("]", "").replace("[", "").split("*")

    @staticmethod
    def getGnbs(topoStr):
        match = re.match(".*_I_([A-Z\\[\\]]*)_.*", topoStr)
        if not match:
            return [GnbHw(topoStr)]
        else:
            return [GnbHw(f"_{x}_") for x in GnbHw.bracketedStrToList(match.group(1))]

    @staticmethod
    def getAps(topoStr):
        """
        Extract number of WTS (Airphones) from topology string.
        Supported formats (after last '_AP_'):
          - CLOUD_..._AP_3[LOOO]            -> 3
          - CLOUD_..._AP_[LOOO][LOOO]      -> 2 (any number of bracketed AP tags)
        Legacy formats (no trailing '_AP_' segment logic):
          - CLOUD_..._3xAP_LOOO            -> 3
          - CLOUD_..._AP_LOOO              -> 1 (any occurrence of 'AP' when no brackets/number patterns detected)
        """
        parts = topoStr.rsplit('_AP_', 1)
        if len(parts) == 2:
            right = parts[1]
            # Format: 3[LOOO] (number directly followed by one bracketed token)
            match = re.match(r"(\d+)\[[A-Z]+\]", right)
            if match:
                return int(match.group(1))
            # Format: [LOOO][LOOO][LOOO] (no leading number, count brackets)
            bracket_count = right.count('[')
            if bracket_count > 0:
                return bracket_count
        # Old format: 3xAP_
        match = re.search(r"(\d+)xAP_", topoStr)
        if match:
            return int(match.group(1))
        # Old format: generic AP presence (fallback)
        if "AP" in topoStr:
            return 1
        # No WTS detected
        return 0

    def getBB(self):
        bb = self.tag.name
        # taking baseband part, after "/"
        if "/" in self.tag.name:
            bb = self.tag.name.split("/")[1]
        # Removing numeric (2ABIL -> ABIL)
        return ''.join([i for i in bb if not i.isdigit()])


# =================================================================================================
class SimuHw(ChoiceOf):
    def getListTag(self):
        return [Tag("AP_KL", "AP ASIK/ABIL"), Tag("AP_KLL", "AP ASIK/2ABIL"), Tag("AP_KLLL", "AP ASIK/3ABIL"),
                Tag("AP_BL", "AP ASIB/ABIL"), Tag("AP_BLL", "AP ASIB/2ABIL"), Tag("AP_BLLL", "AP ASIB/3ABIL"),
                Tag("AP_LO", "AP ASIL/ABIO"), Tag("AP_LOO", "AP ASIL/2ABIO"), Tag("AP_LOOO", "AP ASIL/3ABIO"),
                Tag("AP", "Airphone")]

    @staticmethod
    def removeBracket(str):
        # We translate a : "..._AP_[xxx]_..." into "..._AP_xxx_..."
        return re.sub("_AP_\\[([A-Z]*)\\]_", "_AP_\\1_", str)


# =================================================================================================
class Deployment(ChoiceOf):
    TAG_DEP_SA_NSA = Tag("SA+NSA", "SA NSA")
    TAG_DEP_SA = Tag("SA", "Standalone")
    TAG_DEP_NSA = Tag("NSA", "Non-Standalone")
    TAG_DEP_SANSA = Tag("SANSA", "Standalone/Non-Standalone")

    def getListTag(self):
        return [Deployment.TAG_DEP_SA_NSA, Deployment.TAG_DEP_SA, Deployment.TAG_DEP_NSA, Deployment.TAG_DEP_SANSA]

    def isSANSA(self):
        return self.tag == Deployment.TAG_DEP_SANSA or self.tag == Deployment.TAG_DEP_SA_NSA

    def isDeploySA(self):
        deploy = ""
        try:
            deploy = BuiltIn().get_variable_value("${deploy}")
        except Exception:
            deploy = "NSA"
        if self.tag == Deployment.TAG_DEP_SANSA:
            return deploy == Deployment.TAG_DEP_SA.tag
        return self.tag == Deployment.TAG_DEP_SA


# =================================================================================================
class L1(ChoiceOf):
    def getListTag(self):
        return [Tag("L1B", "L1ByPass"), Tag("FS", "Full-Stack"), Tag("ECPRI", "VARIANT-Full-Stack")]


# =================================================================================================
class FH_Mode(ChoiceOf):
    def getListTag(self):
        return [Tag("CPRI"), Tag("ECPRI"), Tag("")]


# =================================================================================================
class RF_Mode(ChoiceOf):
    def getListTag(self):
        return [Tag("CMWV"), Tag("MMWV"), Tag("")]


# =================================================================================================
class Duplex(ChoiceOf):
    TAG_DUPLEX_TDD = "TDD"
    TAG_DUPLEX_FDD = "FDD"

    def getListTag(self):
        return [Tag(Duplex.TAG_DUPLEX_FDD), Tag(Duplex.TAG_DUPLEX_TDD), Tag("")]

    def isFDD(self):
        return self.tag.tag == Duplex.TAG_DUPLEX_FDD

    def isTDD(self):
        return self.tag.tag == Duplex.TAG_DUPLEX_TDD


# =================================================================================================
class RanType(ChoiceOf):
    TAG_ORAN_TYPE = "ORAN"

    def getListTag(self):
        return [Tag("RAN", "Nokia RAN"), Tag(RanType.TAG_ORAN_TYPE, "Open RAN"), Tag("")]

    def isORAN(self):
        return self.tag.tag == RanType.TAG_ORAN_TYPE


# =================================================================================================
class Topology(object):
    # Cloud Manager JSON path (primary source)
    CM_JSON_PATH = "/opt/ute/reservation.context.json"

    def __init__(self):
        self.gnbVersion = self.simuVersion = self.archi = self.simuHw = self.deployement = self.l1 = None
        self.gnbHws = []
        self.ApsHws = []
        self.FH_Mode = self.RF_Mode = self.duplex = self.ranType = self.rinline2 = None
        self.variantSource = None  # Track source: cloud-manager or fallback
        self.isTopoFromVM = False
        self.isTopoWithVariant = False

    @classmethod
    def quick_topology_detection(cls):
        """Lightweight instance for early Suite Setup; only LABEL:/VARIANT: parsing."""
        obj = cls.__new__(cls)
        obj.isTopoFromVM = False
        obj.isTopoWithVariant = False
        obj.topoStr = ""
        obj.archi = None
        try:
            topo_str = obj.getTopoStr()
            obj.topoStr = topo_str
            if topo_str:
                localTopoStr = SimuHw.removeBracket(topo_str)
                obj.archi = Archi(localTopoStr)
        except Exception:
            obj.topoStr = ""
            obj.archi = None
        return obj

    def set(self):
        self.isTopoFromVM = False
        self.isTopoWithVariant = False
        self.topoStr = self.getTopoStr()
        StringTool.datedConsole(f"    Topology detected:                          ={self.topoStr}")
        if len(self.topoStr) != 0:
            # we first remove brackets around AP topo
            localTopoStr = SimuHw.removeBracket(self.topoStr)
            self.archi = Archi(localTopoStr)
            # Searching for Simu HW BEFORE gnb HW since simu HW is not exclusive from
            # some occurences of gnb HW (ex: KL is included in AP_KL)
            self.simuHw = SimuHw(localTopoStr)
            localTopoStr = self.simuHw.removeTag(localTopoStr)
            self.gnbHws = GnbHw.getGnbs(localTopoStr)
            # self.ApsHws = GnbHw.getAps(localTopoStr)
            self.ApsHws = GnbHw.getAps(self.topoStr)
            self.deployement = Deployment(localTopoStr)
            self.l1 = L1(localTopoStr)
            self.FH_Mode = FH_Mode(localTopoStr)
            self.RF_Mode = RF_Mode(localTopoStr)
            self.duplex = Duplex(localTopoStr)
            # Detection ran type. For the moment : ORAN or not
            self.ranType = RanType(localTopoStr)
            # CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD_ORAN
        # Backward compatibility: expose snake_case alias if older tests rely on it
        try:
            self.gnb_version = self.gnbVersion
        except Exception:
            pass
        return self

    def __str__(self):
        return self.topoStr

    def readFromCloudManagerJSON(self):
        """
        Read topology, variant, and versions from Cloud Manager JSON.
        Returns tuple: (topology_name, variant, gnbVersion, simuVersion)
        or (None, None, None, None) if not available.
        Cloud Manager path: /opt/ute/reservation.context.json
        """
        json_path = "/opt/ute/reservation.context.json"
        if not os.path.isfile(json_path):
            return None, None, None, None

        try:
            with open(json_path, "r") as f:
                cm_context = json.load(f)

            # Extract topology name from CM_TOPOLOGY_NAME
            topology_name = cm_context.get("CM_TOPOLOGY_NAME")

            # Extract variant from CM_TAGS (tag starting with VARIANT_)
            variant = None
            cm_tags = cm_context.get("CM_TAGS", [])
            for tag in cm_tags:
                if isinstance(tag, str) and tag.startswith(
                    "VARIANT_"
                ):
                    # Remove VARIANT_ prefix to get clean variant string
                    variant = tag.replace("VARIANT_", "", 1)
                    break

            # Extract versions from CM_ARTIFACTS
            gnbVersion = None
            simuVersion = None
            cm_artifacts = cm_context.get("CM_ARTIFACTS", [])
            for artifact in cm_artifacts:
                artifact_name = artifact.get("name", "")
                if "SBTS" in artifact_name or "vDUCNF" in artifact_name:
                    if artifact_name.startswith("SBTS"):
                        gnbVersion = "SBTS" + artifact_name.split(
                            "SBTS"
                        )[1]
                    else:
                        gnbVersion = artifact_name
                elif ("airphone" in artifact_name or
                      "5G_4" in artifact_name):
                    simuVersion = artifact_name

            if topology_name:
                StringTool.datedConsole(
                    f"    Topology from Cloud Manager JSON: "
                    f"={topology_name}"
                )
                if variant:
                    StringTool.datedConsole(
                        f"    VARIANT from Cloud Manager JSON: "
                        f"={variant}"
                    )
                if gnbVersion:
                    StringTool.datedConsole(
                        f"    GNB Version from CM_ARTIFACTS: "
                        f"={gnbVersion}"
                    )
                if simuVersion:
                    StringTool.datedConsole(
                        f"    AP Version from CM_ARTIFACTS: "
                        f"={simuVersion}"
                    )
            return topology_name, variant, gnbVersion, simuVersion

        except Exception as e:
            StringTool.datedConsole(
                f"    WARNING: Failed to read Cloud Manager JSON: "
                f"{e}\n"
            )
            return None, None, None, None

    def readFieldFromAgentLog(self, fieldname):
        """
        Read a single field from agent.log (fallback only).
        Used when Cloud Manager JSON and environment variables not available.
        """
        user = os.environ.get('USER', 'ute')
        test_line_paths = [
            f"/home/{user}/testline_init_results/agent.log",
            f"/home/{user}/agent.log"
        ]

        for path in test_line_paths:
            if os.path.isfile(path):
                try:
                    field_pattern = re.escape(
                        fieldname
                    ).rstrip(':')
                    field_regex = re.compile(
                        fr'^\s*{field_pattern}:\s*(.*)'
                    )
                    with open(path, "r") as f:
                        for line in f:
                            match = field_regex.match(line)
                            if match:
                                return match.group(1).strip()
                except Exception:
                    pass
        return None

    def getVersionFallback(self):
        """
        Attempt to retrieve gNB and AP versions from fallback sources.
        Priority:
        1. Robot variables (ENB_BUILD from Jenkins, sweng_AP_Build)
        2. Environment variables (GNB_VERSION, SIMU_VERSION)
        3. Agent.log (last resort if available)
        Note: "notFilled" is treated as empty/None (Jenkins default when field
        is empty).
        Returns tuple: (gnbVersion, simuVersion) or (None, None)
        """
        gnb_version = None
        simu_version = None

        # Try Jenkins Robot variables first
        try:
            gnb_jenkins = BuiltIn().get_variable_value(
                "${ENB_BUILD}"
            )
            # Treat "notFilled" as None
            if gnb_jenkins and gnb_jenkins != "notFilled":
                gnb_version = gnb_jenkins
                StringTool.datedConsole(
                    f"    GNB Version from Variable ENB_BUILD: "
                    f"={gnb_version}"
                )
        except Exception:
            pass

        try:
            simu_jenkins = BuiltIn().get_variable_value(
                "${sweng_AP_Build}"
            )
            # Treat "notFilled" as None
            if simu_jenkins and simu_jenkins != "notFilled":
                simu_version = simu_jenkins
                StringTool.datedConsole(
                    f"    AP Version from Variable sweng_AP_Build: "
                    f"={simu_version}"
                )
        except Exception:
            pass

        # Fallback to environment variables
        if not gnb_version:
            gnb_version = os.environ.get('GNB_VERSION')
            if gnb_version:
                StringTool.datedConsole(
                    f"    GNB Version from Variable GNB_VERSION: "
                    f"={gnb_version}"
                )
        if not simu_version:
            simu_version = os.environ.get('SIMU_VERSION')
            if simu_version:
                StringTool.datedConsole(
                    f"    AP Version from Variable SIMU_VERSION: "
                    f"={simu_version}"
                )

        # Try agent.log as last resort (if env vars not enough)
        if not gnb_version:
            gnb_from_log = (
                self.readFieldFromAgentLog("GNB BUILD:") or
                self.readFieldFromAgentLog("SM BUILD:") or
                self.readFieldFromAgentLog("BUILD:")
            )
            if gnb_from_log:
                gnb_version = gnb_from_log
                StringTool.datedConsole(
                    f"    GNB Version from Variable agent.log: "
                    f"={gnb_version}"
                )

        if not simu_version:
            simu_from_log = (
                self.readFieldFromAgentLog("AP BUILD:") or
                self.readFieldFromAgentLog("AIRPHONE:")
            )
            if simu_from_log:
                simu_version = simu_from_log
                StringTool.datedConsole(
                    f"    AP Version from Variable agent.log: "
                    f"={simu_version}"
                )

        return gnb_version, simu_version

    def getVariantFallback(self):
        """
        Attempt to retrieve variant string from fallback sources when missing
        from Cloud Manager JSON. Tries in order:
        1. Robot variable ${sweng_VARIANT} (from Jenkins)
        2. Robot variable ${variant_fallback} (backward compat)
        3. Environment variable TOPO_VARIANT
        Returns variant string or None if not found.
        Note: "notFilled" is treated as empty/None (Jenkins default when field
        is empty).
        """
        # Try Jenkins Robot variable first
        try:
            variant_jenkins = BuiltIn().get_variable_value(
                "${sweng_VARIANT}"
            )
            # Treat "notFilled" (Jenkins default for empty field) as None
            if variant_jenkins and variant_jenkins != "notFilled":
                StringTool.datedConsole(
                    f"    VARIANT from Jenkins "
                    f"(${{sweng_VARIANT}}): ={variant_jenkins}"
                )
                return variant_jenkins
        except Exception:
            pass

        # Try fallback Robot variable (backward compatibility)
        try:
            variant_fallback = BuiltIn().get_variable_value(
                "${variant_fallback}"
            )
            if variant_fallback and variant_fallback != "notFilled":
                StringTool.datedConsole(
                    f"    VARIANT from fallback "
                    f"(${{variant_fallback}}): "
                    f"={variant_fallback}"
                )
                return variant_fallback
        except Exception:
            pass

        # Try environment variable last
        variant_env = os.environ.get('TOPO_VARIANT')
        if variant_env:
            StringTool.datedConsole(
                f"    VARIANT from fallback (TOPO_VARIANT env): "
                f"={variant_env}"
            )
            return variant_env

        return None

    def getTopoStr(self):
        # Priority 1: Cloud Manager JSON (if running on Cloud Manager)
        (topoVM_cm, variant_cm, gnb_v_cm,
         simu_v_cm) = self.readFromCloudManagerJSON()

        if topoVM_cm:
            # Cloud Manager JSON found, use it exclusively
            # Try Jenkins variable first, fallback to ${topo}
            # Note: treat "notFilled" (Jenkins default for empty field) as None
            topoArg = None
            try:
                topoArg = BuiltIn().get_variable_value(
                    "${sweng_TOPOLOGY}"
                )
                # Treat "notFilled" as None
                if topoArg == "notFilled":
                    topoArg = None
            except Exception:
                pass
            if not topoArg:
                topoArg = BuiltIn().get_variable_value("${topo}")
                if topoArg == "notFilled":
                    topoArg = None
            variant = variant_cm  # Already extracted from JSON

            # Import versions from Cloud Manager JSON
            # or use fallback sources (env vars, agent.log)
            if gnb_v_cm:
                self.gnbVersion = gnb_v_cm
            if simu_v_cm:
                self.simuVersion = simu_v_cm

            # If CM JSON didn't provide versions, try fallback
            if not gnb_v_cm or not simu_v_cm:
                gnb_fallback, simu_fallback = (
                    self.getVersionFallback()
                )
                if not self.gnbVersion:
                    self.gnbVersion = gnb_fallback
                if not self.simuVersion:
                    self.simuVersion = simu_fallback

            # Use Cloud Manager topology if no ${topo} override
            if not topoArg:
                topoVM = topoVM_cm
                self.isTopoFromVM = True
            else:
                topoVM = topoArg

            # Try fallback sources if variant still not found
            if not variant or variant == "None" or variant == "fs":
                variant = self.getVariantFallback()
                self.variantSource = "fallback"
            else:
                self.variantSource = "cloud-manager"

            if variant and variant != "None" and variant != "fs":
                StringTool.datedConsole(
                    f"    VARIANT detected:                          "
                    f"={variant}"
                )
                self.isTopoWithVariant = True
                if topoArg:
                    return topoArg + "_" + variant
                return topoVM + "_" + variant

            if topoArg:
                return topoArg
            return topoVM

        # Cloud Manager JSON not found - try fallback sources only
        # (try Jenkins var, then Robot var, env vars and agent.log)
        # Note: treat "notFilled" (Jenkins default for empty field) as None
        topoArg = None
        try:
            topoArg = BuiltIn().get_variable_value(
                "${sweng_TOPOLOGY}"
            )
            # Treat "notFilled" as None
            if topoArg == "notFilled":
                topoArg = None
        except Exception:
            pass
        if not topoArg:
            topoArg = BuiltIn().get_variable_value("${topo}")
            if topoArg == "notFilled":
                topoArg = None

        if topoArg is None:
            StringTool.datedConsole(
                "WARNING: Cloud Manager JSON not found AND topo "
                "argument were not set!"
            )
            return ""

        # Try to get versions from fallback sources when CM JSON not available
        gnb_fallback, simu_fallback = self.getVersionFallback()
        if not self.gnbVersion:
            self.gnbVersion = gnb_fallback
        if not self.simuVersion:
            self.simuVersion = simu_fallback

        # Use only ${topo} variable when CM JSON not available
        variant = self.getVariantFallback()
        if variant:
            self.variantSource = "fallback"
            if variant != "None" and variant != "fs":
                StringTool.datedConsole(
                    f"    VARIANT detected:                          "
                    f"={variant}"
                )
                self.isTopoWithVariant = True
                return topoArg + "_" + variant

        return topoArg

    def display(self, isConsole=True):
        variant_source = self.variantSource if self.variantSource else "unknown"
        StringTool.printLineWithTitle(
            f"TOPOLOGY:[{self.topoStr}] (from VM:{self.isTopoFromVM})"
            f"(with Variant:{self.isTopoWithVariant}, source:{variant_source})",
            isConsole=isConsole
        )
        StringTool.printHeaderLine("Archi", self.archi, isConsole=isConsole)
        for idx, gnb in enumerate(self.gnbHws):
            StringTool.printHeaderLine(f"GnbHw[{idx+1}]", gnb, isConsole=isConsole)
        StringTool.printHeaderLine("SimuHw", self.simuHw, isConsole=isConsole)
        StringTool.printHeaderLine("Deployment", self.deployement, isConsole=isConsole)
        StringTool.printHeaderLine("L1", self.l1, isConsole=isConsole)
        StringTool.printHeaderLine("FH_Mode", self.FH_Mode, isConsole=isConsole)
        StringTool.printHeaderLine("RF_Mode", self.RF_Mode, isConsole=isConsole)
        StringTool.printHeaderLine("Duplex", self.duplex, isConsole=isConsole)
        StringTool.printHeaderLine("Ran Type", self.ranType, isConsole=isConsole)
        StringTool.printHeaderLine("GNB Version", self.gnbVersion, isConsole=isConsole)
        StringTool.printHeaderLine("AP Version", self.simuVersion, isConsole=isConsole)

    def printTLInfoInLog(self, tlconfig, isConsole=False):
        EnvironmentManager.reportTestEnvironment(tlconfig, isConsole=isConsole)
        self.display(isConsole=isConsole)

    def isSANSA(self):
        if self.deployement is None:
            return False
        return self.deployement.isSANSA()

    def isDeploySA(self):
        if self.deployement is None:
            return False
        return self.deployement.isDeploySA()

    def getSimuTag(self):
        if self.simuHw is None:
            return None
        return self.simuHw.getTag()

    def isAic(self):
        return self.archi.isAic()

    def isRinLine2(self):
        return self.archi.isRinLine2()

    def isClassical(self):
        return self.archi.isClassical()

    def isTDD(self):
        return self.duplex.isTDD()

    def isFDD(self):
        return self.duplex.isFDD()

    def getDuplexMode(self):
        return self.duplex

    def getBranchName(self):
        return self.gnbVersion.split("_")[0]

    def getBB(self, index=0):
        return self.gnbHws[index].getBB()

    def getNbGNB(self):
        return len(self.gnbHws)

    def getnbVMwts(self):
        return self.ApsHws  # return number of Airphone based on topology name _AP_ or >nbr<xAP_

    def isORAN(self):
        return self.ranType.isORAN()
