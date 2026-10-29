import unittest
import testsuite.Ulm.ET.L2.libraries.new_class_libraries.ue as UE


class TestUeClass(unittest.TestCase):
    def setUp(self) -> None:
        return super().setUp()

    def test_simple_ue_creation(self):
        group = "ue_group_1"
        new_ue_instance = UE.UE(group=group)
        self.assertEqual(group, new_ue_instance.group)

    def test_sa_ue_creation(self):
        group = "ue_group_1"
        pdu = 2
        sa_ue_instance = UE.SaUE(group=group, pdu=pdu)
        self.assertLess(sa_ue_instance.id, 100)
        self.assertEqual(group, sa_ue_instance.group)
        self.assertEqual(pdu, sa_ue_instance.pdu)

    def test_nsa_ue_creation(self):
        group = "ue_group_1"
        bearers = 2
        nsa_ue_instance = UE.NsaUE(group=group, bearers=bearers)
        self.assertGreater(nsa_ue_instance.id, 100)
        self.assertEqual(group, nsa_ue_instance.group)
        self.assertEqual(list(str(bearers)), nsa_ue_instance.bearers)

    def test_basic_ue_group(self):
        ue_group_instance = UE.UeGroup(name="ue_group_1", type="group")
        sa_ue = UE.SaUE("ue_group_1")
        ue_group_instance.add_ue(sa_ue)
        self.assertIn(sa_ue, ue_group_instance.related_ues,
                      msg="the UE seems not be be attached to the group.")

    def test_ue_group_size(self):
        ue_group_instance = UE.UeGroup(name="ue_group_1", type="group")
        ue_list = []
        num_ues = 10
        for id in range(1, num_ues + 1):
            ue_list.append(UE.SaUE("ue_group_1"))
        for ue in ue_list:
            ue_group_instance.add_ue(ue)
        self.assertEqual(num_ues, ue_group_instance.ue_group_size)


if __name__ == '__main__':
    suite = unittest.TestSuite()
    # suite.addTest(TestJsonAnalyzer('test_ue_dict_generator'))
    # runner = unittest.TextTestRunner()
    # runner.run(suite)
    suite = unittest.TestLoader().loadTestsFromTestCase(TestUeClass)
    unittest.TextTestRunner(verbosity=2).run(suite)
