"""
:copyright: Nokia Networks
:author: Damian Zak, Mateusz Plinta, Mateusz Pajor
:maintainer: Damian Zak, Mateusz Plinta, Mateusz Pajor
:contact: damian.zak@nokia.com, mateusz.plinta@nokia.com, mateusz.pajor@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG, MN_RAN_L2_SW_2_KRK_Vrf_SG
"""

import os

from robot.libraries.BuiltIn import BuiltIn


def get_builtin_value(param_name, default=None):
    return BuiltIn().get_variable_value("${{{}}}".format(param_name), default)


tl = get_builtin_value(param_name="tl")

# AP Hardware
AP_HARDWARE = tl.ues[0].l1.common_units[0].hardware_type

# PDU
PDU_MODEL = tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.__class__.__name__
GNB_PORT = tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port
AP_PORT = tl.ues[0].l1.common_units[0].pdu_port
SWITCH_IP = tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr

# General vars
WEBEM_USERNAME = tl.gnbs[0].cu.oam_http_connection_details.username
WEBEM_PASSWORD = tl.gnbs[0].cu.oam_http_connection_details.password
NOKIA_USERNAME = tl.gnbs[0].cu.oam_ssh_connection_details.username
NOKIA_PASS = tl.gnbs[0].cu.oam_ssh_connection_details.password
GNB_IP = tl.gnbs[0].cu.oam_ssh_connection_details.addr
AP_IP = tl.ues[0].l1.common_units[0].lmp_connection.addr
AP_PASSWD = tl.ues[0].l1.common_units[0].lmp_connection.password

RESOURCES_PATH = os.path.dirname(os.path.abspath(__file__))
SCFS_DIRECTORY_PATH = os.path.join(RESOURCES_PATH, "scf_config")
BASE_SCF_PATH = os.path.join(SCFS_DIRECTORY_PATH, "base_scf.xml")
BASE_IPHY_PATH = os.path.join(
    BuiltIn().get_variable_value("${OUTPUT_DIR}"),
    BuiltIn().get_variable_value("${SUITE_NAME}"),
    "base_iphy.xml"
)
K2MIN_RDNUMOFSCELLCHECKS = ["0x58012d=4", "0x58010B=1"]

DEFAULT_PCELL_PCI = 51
DEFAULT_CELL_SUBCELL_MAP = {
    51: ["DL", "UL"],
    52: ["DL", "UL"],
    53: ["DL", "UL"],
    54: ["DL", "UL"],
    55: ["DL"],
    56: ["DL"],
    57: ["DL"],
    58: ["DL"]
}

B6_B7_CELL_SUBCELL_MAP = {
    51: ["DL", "UL"],
    52: ["DL", "UL"],
    53: ["DL", "UL"],
    54: ["DL", "UL"],
    55: ["DL"],
    56: ["DL"],
    57: ["DL"],
    58: ["DL"],
    59: ["DL", "UL"],
    60: ["DL", "UL"]
}

CELL_SUBCELL_2CC_NSA_MAP = {
    59: ["DL", "UL"],
    60: ["DL", "UL"]
}
CELL_SUBCELL_2CC_SA_MAP = {
    59: ["DL", "UL"],
    60: ["DL", "UL"]
}

CELL_ID_TO_PCI_MAP = {
    1: 51,
    2: 52,
    3: 53,
    4: 54,
    5: 55,
    6: 56,
    7: 57,
    8: 58,
    9: 59,
    10: 60
}

PCI_TO_CELL_ID_MAP = {value: key for key, value in CELL_ID_TO_PCI_MAP.items()}

# Tcpdump filters
RRC_RECONFIGURATION_OVERHEATING_TCPDUMP_FILTER = "nr-rrc.rrcReconfiguration_element &&" \
                                  " nr-rrc.overheatingAssistanceConfig == 1"
UE_CAPABILITIES_OVERHEATING_TCPDUMP_FILTER = "nr-rrc.ueCapabilityInformation_element && nr-rrc.overheatingInd == 0"

TCPDUMP_ALIAS = "tcpdump_alias"
DCAP_RESULTS_COLLECTED = None

AEQE_RADIO_HEAD = """
    <RE>
        <identity>
          <cardName>AEQE</cardName>
          <bldVersion>{build_version}</bldVersion>
          <productCode>474750A</productCode>
          <resourceBuildKey>LTX_AEQE_E1</resourceBuildKey>
          <serialno>6Q182502974</serialno>
        </identity>
        <hardware>
          <scs>30</scs>
          <optlink_List>
            <optlink>
              <physicalId>1.1</physicalId>
              <virtualId>1</virtualId>
              <linkRate>25</linkRate>
              <rat>5G</rat>
            </optlink>
            <optlink>
              <physicalId>1.2</physicalId>
              <virtualId>2</virtualId>
              <linkRate>25</linkRate>
              <rat>5G</rat>
            </optlink>
          </optlink_List>
          <vcellList>
            <vcell>
              <cell>2.9</cell>
              <phy_cell_id>59</phy_cell_id>
              <GSCN>8019</GSCN>
              <SCS_SSB>30</SCS_SSB>
            </vcell>
            <vcell>
              <cell>2.10</cell>
              <phy_cell_id>60</phy_cell_id>
              <GSCN>7915</GSCN>
              <SCS_SSB>30</SCS_SSB>
            </vcell>
          </vcellList>
        </hardware>
        <soap-config>
          <software>
            <file>
              <name>{sw_version}</name>
              <usageStatus>active</usageStatus>
              <version>{build_version}</version>
            </file>
            <file>
              <name>{sw_version}</name>
              <usageStatus>passive</usageStatus>
              <version>{build_version}</version>
            </file>
          </software>
          <defaults>
            <!-- default values of managed object parameters and states -->
            <managedObject class="Module" distName="module">
              <state>
                <stateType>operational</stateType>
                <initState>disabled</initState>
              </state>
            </managedObject>
          </defaults>
        </soap-config>
        <ecpri>true</ecpri>
      </RE>
"""

AWEUA_RADIO_HEAD = """
    <RE>
        <identity>
          <cardName>AWEUA</cardName>
          <bldVersion>{build_version}</bldVersion>
          <productCode>475166A</productCode>
          <resourceBuildKey>LTX_AWEUA</resourceBuildKey>
          <serialno>6Q182502974</serialno>
        </identity>
        <hardware>
          <scs>120</scs>
          <optlink_List>
            <optlink>
              <physicalId>1.1</physicalId>
              <virtualId>1</virtualId>
              <linkRate>25</linkRate>
              <rat>5G</rat>
            </optlink>
            <optlink>
              <physicalId>1.2</physicalId>
              <virtualId>2</virtualId>
              <linkRate>25</linkRate>
              <rat>5G</rat>
            </optlink>
          </optlink_List>
          <vcellList>
            <vcell>
              <cell>2.9</cell>
              <phy_cell_id>59</phy_cell_id>
              <GSCN>22402</GSCN>
              <SCS_SSB>240</SCS_SSB>
            </vcell>
            <vcell>
              <cell>2.10</cell>
              <phy_cell_id>60</phy_cell_id>
              <GSCN>22408</GSCN>
              <SCS_SSB>240</SCS_SSB>
            </vcell>
          </vcellList>
        </hardware>
        <soap-config>
          <software>
            <file>
              <name>{sw_version}</name>
              <usageStatus>active</usageStatus>
              <version>{build_version}</version>
            </file>
            <file>
              <name>{sw_version}</name>
              <usageStatus>passive</usageStatus>
              <version>{build_version}</version>
            </file>
          </software>
          <defaults>
            <!-- default values of managed object parameters and states -->
            <managedObject class="Module" distName="module">
              <state>
                <stateType>operational</stateType>
                <initState>disabled</initState>
              </state>
            </managedObject>
          </defaults>
        </soap-config>
        <ecpri>true</ecpri>
      </RE>
"""

AWEUB_RADIO_HEAD = """
      <RE>
        <identity>
            <cardName>AWEUB</cardName>
            <bldVersion>{build_version}</bldVersion>
            <productCode>475167A</productCode>
            <resourceBuildKey>LTX_AWEUB</resourceBuildKey>
            <serialno>6Q182502980</serialno>
        </identity>
        <hardware>
            <scs>120</scs>
            <optlink_List>
                <optlink>
                    <physicalId>1.1</physicalId>
                    <virtualId>1</virtualId>
                    <linkRate>25</linkRate>
                    <rat>5G</rat>
                </optlink>
                <optlink>
                    <physicalId>1.7</physicalId>
                    <virtualId>2</virtualId>
                    <linkRate>25</linkRate>
                    <rat>5G</rat>
                </optlink>
            </optlink_List>
            <vcellList>
                <vcell>
                    <cell>2.9</cell>
                    <phy_cell_id>59</phy_cell_id>
                    <GSCN>22512</GSCN>
                    <SCS_SSB>240</SCS_SSB>
                </vcell>
                <vcell>
                    <cell>2.10</cell>
                    <phy_cell_id>60</phy_cell_id>
                    <GSCN>22518</GSCN>
                    <SCS_SSB>240</SCS_SSB>
                </vcell>
                <vcell>
                    <cell>2.11</cell>
                    <phy_cell_id>61</phy_cell_id>
                    <GSCN>22536</GSCN>
                    <SCS_SSB>240</SCS_SSB>
                </vcell>
                <vcell>
                    <cell>2.12</cell>
                    <phy_cell_id>62</phy_cell_id>
                    <GSCN>22542</GSCN>
                    <SCS_SSB>240</SCS_SSB>
                </vcell>
            </vcellList>
        </hardware>
        <soap-config>
            <software>
                <file>
                    <name>{sw_version}</name>
                    <usageStatus>active</usageStatus>
                    <version>{build_version}</version>
                </file>
            </software>
            <defaults>
                <managedObject class="Module" distName="module">
                    <state>
                        <stateType>operational</stateType>
                        <initState>disabled</initState>
                    </state>
                </managedObject>
            </defaults>
        </soap-config>
        <ecpri>true</ecpri>
      </RE>
"""
