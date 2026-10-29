from cloud5g.commissioning import CustomCommissioningBase
from taf.internal.scf.managed_object import ManagedObject
from taf.internal.scf.list import P
from taf.internal.scf.list import List
from taf.internal.scf.exceptions import ElementNotFound


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        scf = self.scf_handler
        mrbts = scf.raml.cmData.MRBTS[0]
        mrbts_id = mrbts.dist_name.split("-")[-1]

        # Add ETHLK MO
        tnl_ver = mrbts.TNLSVC[0].TNL[0]._tree.attrib["version"]
        ethlk = ManagedObject().create(
            klass="com.nokia.srbts.tnl:ETHLK",
            dist_name="MRBTS-{}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2".format(mrbts_id),
            version=tnl_ver,
            operation="create"
        )
        ethlk.append(P().create(name="administrativeState", value="unlocked"))
        ethlk.append(P().create(name="connectorLabel", value="EIF2"))
        ethlk.append(P().create(name="l2IngressRate", value="1000000"))
        ethlk.append(P().create(name="modDN", value="MRBTS-{}/EQM-1/APEQM-1/CABINET-1/SMOD-1".format(mrbts_id)))
        ethlk.append(P().create(name="speedAndDuplex", value="AUTODETECT"))
        self.scf_handler.raml.cmData.append(ethlk)

        # Add ETHMIRROR MO
        ethmirror = ManagedObject().create(
            klass="com.nokia.srbts.tnl:ETHMIRROR",
            dist_name="MRBTS-{}/TNLSVC-1/TNL-1/ETHSVC-1/ETHMIRROR-1".format(mrbts_id),
            version=tnl_ver,
            operation="create"
        )
        ethmirror.append(P().create(name="portMirroringEnabled", value="true"))
        self.scf_handler.raml.cmData.append(ethmirror)

        # Add ETHMIRRORSET MO
        ethmirrorset = ManagedObject().create(
            klass="com.nokia.srbts.tnl:ETHMIRRORSET",
            dist_name="MRBTS-{}/TNLSVC-1/TNL-1/ETHSVC-1/ETHMIRROR-1/ETHMIRRORSET-1".format(mrbts_id),
            version=tnl_ver,
            operation="create"
        )
        ethmirrorset.append(P().create(name="destinationDN",
                                       value="MRBTS-{}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2".format(mrbts_id)))
        ethmirrorset.append(P().create(name="sourceDirection", value="INGRESS and EGRESS"))
        new_list = List().create(name="sourceDN")
        new_list.append(P().create(value="MRBTS-{}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1".format(mrbts_id)))
        ethmirrorset.append(new_list)
        self.scf_handler.raml.cmData.append(ethmirrorset)
