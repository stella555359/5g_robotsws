from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib

tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
BTS_ID = str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
LNBTS_NAME = 'LNBTS-' + str(tl.enbs[0].global_bts_id)
carrierAggregationSupportList_With_T_F = BuiltIn().get_variable_value('${carrierAggregationSupportList_With_T_F}')


# for enb config change
ENABLE_B1_MEAS = [dict(value='true',
                       dist_name=LNBTS_NAME,
                       parameter='actDynTrigLteNrDualConnectivity')
                  ]

DISABLE_B1_MEAS = [dict(value='false', dist_name=LNBTS_NAME, parameter='actDynTrigLteNrDualConnectivity')]

Only_report_one_cell_B1 = [dict(value='true',
                                dist_name=LNBTS_NAME,
                                parameter='actDynTrigLteNrDualConnectivity'),
                           dict(dist_name=LNBTS_NAME + '/NRDCDPR-0/ENDCDMEASCONF-1',
                                parameter="carrierFreqNrCell",
                                value="125599")
                           ]

MOD_SCF_WEIGHTOFFR1PSCELL = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         p_name="weightOfFr1PSCell",
         value="1"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         p_name="weightOfFr1PSCell",
         value="100"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-3',
         p_name="weightOfFr1PSCell",
         value="100"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4',
         p_name="weightOfFr1PSCell",
         value="100"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         p_name="weightOfFr1PSCell",
         value="100"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         p_name="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         p_name="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-3',
         p_name="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4',
         p_name="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         p_name="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         p_name="actCaAwarePsCellSelectionFr1",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         p_name="actCaAwarePsCellSelectionFr1",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-3',
         p_name="actCaAwarePsCellSelectionFr1",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4',
         p_name="actCaAwarePsCellSelectionFr1",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         p_name="actCaAwarePsCellSelectionFr1",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME,
         p_name="actNsaPSCellLoadBalancingInFR1",
         value="false")
]

ADD_SCF_DEFAULT = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRPMRNL-1',
         p_name="miNrRacCu",
         value="5min"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRPMRNL-1',
         p_name="miNrRacDu",
         value="5min"),
    dict(dist_name='MNL-1/MNLENT-1/PMCADM-1',
         p_name="reportingIntervalPm",
         value="5min"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1',
         list_name="carrierAggregationSupportList",
         elements=carrierAggregationSupportList_With_T_F),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1',
         p_name="actConnectedModeMobilityCA",
         value="true"),
    # TL049 PDL error
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1',
         p_name="flexibleCAMode",
         value="ConfigurationIndependent"),

    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         p_name="eblRplCellSelectionWithCA",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         p_name="eblRplCellSelectionWithCA",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-3',
         p_name="eblRplCellSelectionWithCA",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4',
         p_name="eblRplCellSelectionWithCA",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         p_name="eblRplCellSelectionWithCA",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         p_name="minRsrpRplCellForPSCell",
         value="60"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         p_name="minRsrpRplCellForPSCell",
         value="60"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-3',
         p_name="minRsrpRplCellForPSCell",
         value="60"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4',
         p_name="minRsrpRplCellForPSCell",
         value="60"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         p_name="minRsrpRplCellForPSCell",
         value="60")
]

REST_API_ACT_9311 = [
    dict(dist_name=MR_NR_BTS_NAME, parameter="actNsaPSCellLoadBalancingInFR1", value="true")
]

REST_API_ACT_9311_CA_T1_F4 = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="actCaAwarePsCellSelectionFr1",
         value="true"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="actCaAwarePsCellSelectionFr1",
         value="true"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="weightOfFr1PSCell",
         value="30")
]
# REST_API_ACT_9311-B
REST_API_ACT_9311_B_T1 = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1' + '/NRREL-1',
         parameter="isRplCellForPSCell",
         value="true"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1' + '/NRREL-2',
         parameter="isRplCellForPSCell",
         value="true"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1' + '/NRREL-3',
         parameter="isRplCellForPSCell",
         value="true"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1' + '/NRREL-4',
         parameter="isRplCellForPSCell",
         value="true")
]

REST_API_ACT_9311_C = [
    dict(dist_name=MR_NR_BTS_NAME, parameter="deltaRsrpFromBestCell", value="-40"),
    dict(dist_name=MR_NR_BTS_NAME, parameter="deltaRsrqFromBestCell", value="-40"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="weightOfFr1PSCell",
         value="60"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="weightOfFr1PSCell",
         value="100"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="ccLoadThreshold",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="ccLoadThreshold",
         value="100"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="actCaAwarePsCellSelectionFr1",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="actCaAwarePsCellSelectionFr1",
         value="false")
]

# T1(cell1):F4(cell2),T2(cell4),T3(cell5),F5(cell3)
# enable eblRplCellSelectionWithCA on T1(cell1) F4(cell2)
# enable actCaAwarePsCellSelectionFr1 on T1(cell1),T2(cell4),T3(cell5),F5(cell3)
REST_API_ENABLE_A_CA_T1_T2_T3_F5 = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="actCaAwarePsCellSelectionFr1",
         value="true"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4',
         parameter="actCaAwarePsCellSelectionFr1",
         value="true"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="actCaAwarePsCellSelectionFr1",
         value="true"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-3',
         parameter="actCaAwarePsCellSelectionFr1",
         value="true"),
]

REST_API_ENABLE_B_CA_T1_F4 = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="eblRplCellSelectionWithCA",
         value="true"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="eblRplCellSelectionWithCA",
         value="true")
]

# T1,T2 over load
REST_API_T1_T2_OVERLOAD = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="ccLoadThreshold",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4',
         parameter="ccLoadThreshold",
         value="0")
]

REST_API_T1_F1_notOVERLOAD = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="ccLoadThreshold",
         value="90")
]

# T1(cell1):T3(cell5),F4(cell2),F4(cell2),F5(cell3)
# T1(cell1) T2(cell4) overload, and disable eblRplCellSelectionWithCA on T1(cell1)
# T3 not overload  ,REST_API_ACT_T1_RAC_REJECT_MODIFY_F4_MIN_RSRP
# F4 rsrp/rsrq+offset <minRsrpRplCell
REST_API_DISABLE_T1_B_CA_MODIFY_F4_MIN_RSRP = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="eblRplCellSelectionWithCA",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="minRsrpRplCellForPSCell",
         value="120")
]

# T1(cell1),T3(cell5) RAC reject and not overload
# F5(cell3) over load
# adjust F4 rsrp < minRsrpRplCellForPSCell
REST_API_T1_T3_RAC_REJECT_F5_OVERLOAD_MODIFY_F4_MIN_RSRP = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-3',
         parameter="ccLoadThreshold",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="minRsrpRplCellForPSCell",
         value="120"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfCaUsersNRCell",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfUsersPerNRCell",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfUsersPerCell",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfSCellAlloc",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfRrcSA",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfNrDcSnUsers",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0',
         parameter="maxNumOfUsers",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="maxNumOfCaUsersNRCell",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="maxNumOfUsersPerNRCell",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="maxNumOfUsersPerCell",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="maxNumOfSCellAlloc",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="maxNumOfRrcSA",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="maxNumOfNrDcSnUsers",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-4',
         parameter="maxNumOfUsers",
         value="0")
]

# T1(cell1):F4(cell2),T2(cell4),T3(cell5),F5(cell3)
# T1 cell1 RAC reject and eblRplCellSelectionWithCA change to false
# F4(cell2) rsrp < minrsrp
# T2(cell4) overload
REST_API_ACT_T1_RAC_REJECT_MODIFY_F4_MIN_RSRP = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="eblRplCellSelectionWithCA",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="minRsrpRplCellForPSCell",
         value="120"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="weightOfFr1PSCell",
         value="80"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfCaUsersNRCell",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfUsersPerNRCell",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfUsersPerCell",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfSCellAlloc",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfRrcSA",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfNrDcSnUsers",
         value="0"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0',
         parameter="maxNumOfUsers",
         value="0")
]

REST_API_DISABLE_9311 = [
    dict(dist_name=MR_NR_BTS_NAME, parameter="actNsaPSCellLoadBalancingInFR1", value="false")
]


REST_API_RESTORE_MEASCONF = [
   dict(dist_name=LNBTS_NAME + '/NRDCDPR-0/ENDCDMEASCONF-1',
        parameter="carrierFreqNrCell",
        value="125570"),
]

REST_API_DISABLE_9311_CA = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="actCaAwarePsCellSelectionFr1",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="actCaAwarePsCellSelectionFr1",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-3',
         parameter="actCaAwarePsCellSelectionFr1",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4',
         parameter="actCaAwarePsCellSelectionFr1",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="actCaAwarePsCellSelectionFr1",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="eblRplCellSelectionWithCA",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="eblRplCellSelectionWithCA",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-3',
         parameter="eblRplCellSelectionWithCA",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4',
         parameter="eblRplCellSelectionWithCA",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="eblRplCellSelectionWithCA",
         value="false"),
]

REST_API_DISABLE_9311_B_T1 = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1' + '/NRREL-1',
         parameter="isRplCellForPSCell",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1' + '/NRREL-2',
         parameter="isRplCellForPSCell",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1' + '/NRREL-3',
         parameter="isRplCellForPSCell",
         value="false"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1' + '/NRREL-4',
         parameter="isRplCellForPSCell",
         value="false")
]

REST_API_ACT_9311_A01_TEARDOWN = {
    'param_to_upd': REST_API_DISABLE_9311 + [
        dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
             parameter="actCaAwarePsCellSelectionFr1",
             value="false"),
        dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
             parameter="actCaAwarePsCellSelectionFr1",
             value="false"),
        dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
             parameter="weightOfFr1PSCell",
             value="1"),
    ],
    'param_to_del': [
        dict(dist_name=MR_NR_BTS_NAME,
             parameter="deltaRsrpFromBestCell"),
        dict(dist_name=MR_NR_BTS_NAME,
             parameter="deltaRsrqFromBestCell")
    ],
}

REST_API_ACT_9311_B_T11_TEARDOWN = REST_API_DISABLE_9311 + REST_API_DISABLE_9311_B_T1 + REST_API_DISABLE_9311_CA + [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4',
         parameter="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfCaUsersNRCell",
         value="250"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfUsersPerNRCell",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfUsersPerCell",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfSCellAlloc",
         value="250"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfRrcSA",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfNrDcSnUsers",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0',
         parameter="maxNumOfUsers",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="minRsrpRplCellForPSCell",
         value="60"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="weightOfFr1PSCell",
         value="100"),
]

REST_API_ACT_9311_B_T05_TEARDOWN = REST_API_DISABLE_9311 + REST_API_DISABLE_9311_B_T1 + REST_API_DISABLE_9311_CA + [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         parameter="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-3',
         parameter="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4',
         parameter="ccLoadThreshold",
         value="90"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfCaUsersNRCell",
         value="250"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfUsersPerNRCell",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfUsersPerCell",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfSCellAlloc",
         value="250"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfRrcSA",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         parameter="maxNumOfNrDcSnUsers",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0',
         parameter="maxNumOfUsers",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="maxNumOfCaUsersNRCell",
         value="250"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="maxNumOfUsersPerNRCell",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="maxNumOfUsersPerCell",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="maxNumOfSCellAlloc",
         value="250"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="maxNumOfRrcSA",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5',
         parameter="maxNumOfNrDcSnUsers",
         value="275"),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-4',
         parameter="maxNumOfUsers",
         value="275")
]

CB009311_B_B1_05_MODIFY_PARAMS = REST_API_ACT_9311 + REST_API_ACT_9311_B_T1 \
                                + REST_API_T1_T2_OVERLOAD

CB009311_B_B1_11_MODIFY_PARAMS = REST_API_ACT_9311 + REST_API_ACT_9311_B_T1 \
                                + REST_API_ENABLE_A_CA_T1_T2_T3_F5 \
                                + REST_API_ENABLE_B_CA_T1_F4 + REST_API_T1_F1_notOVERLOAD

INIT_PA_F1_F2_T1_T2 = {0: [0, 0, 0, 0]}
