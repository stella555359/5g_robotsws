<?xml version="1.0" encoding="UTF-8"?>
<!-- Scenario created in date 2019-07-09 16:57:10 by AirMosaic LTE Uu 7.8.0RC8 (Build 201906051119)-->
<TestScenario Version="7" Repetitions="1" RepetitionsDelay="1000" Looped="false" DurationEnable="false" DetachShutdown="false" Annotation="" GlobalVariables="" cellbinding="" nrcellbinding="" AppVersion="AirMosaic LTE Uu 7.8.0RC8 (Build 201906051119)" TstmName="LTE_Tm">
  <Bearer>
    <db name="Bearer" formatname="Bearer" version="1.0 1.0" />
  </Bearer>
  <Flow>
    <db name="Flow" formatname="Flow" version="1.0 1.0" />
  </Flow>
  <Groups>
    <Group name="1" extensible="true" enableGroup="true" loopenGroupRepetitions="false">
      "user 001"
      <TemplateProfileMobility lsuNrCell="1" property="true" mobilityNameProperty="Static 5GNr Mobility" name="com.prisma.mobility.mobilityplugin.fixedmobility.staticmobility.StaticFiveGNrMobility">
        <FiveGNrTable>
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="2.0">
            <record name="0" modifiable="true">
              <Integer name="PosId" value="0" />
              <Integer name="NextPosId" value="0" />
              <Integer name="Interval" value="-1" />
              <Integer name="Time" value="0" />
              <Integer name="Distance" value="0" />
              <Integer name="RadialSpeed" value="0" />
              <Integer name="RLF_HARQ_OFF" value="0" />
              <Boolean name="RLF_HARQ_OFF_SHOW" value="false" />
              <Integer name="RLF_CSI_OFF" value="0" />
              <Boolean name="RLF_CSI_OFF_SHOW" value="false" />
              <Integer name="RLF_UE_TRIGGERED" value="0" />
              <Boolean name="RLF_UE_TRIGGERED_SHOW" value="false" />
              <Integer name="BeamFailureRecovery" value="0" />
              <Boolean name="BeamFailureRecoveryShow" value="false" />
              <Integer name="DlSNR" value="0" />
              <Integer name="UlSNR" value="0" />
              <Integer name="DlMcsBler_0" value="0" />
              <Integer name="DlMcsBler_1" value="0" />
              <Integer name="DlMcsBler_2" value="0" />
              <Integer name="DlMcsBler_3" value="0" />
              <Integer name="DlMcsBler_4" value="0" />
              <Integer name="DlMcsBler_5" value="0" />
              <Integer name="DlMcsBler_6" value="0" />
              <Integer name="DlMcsBler_7" value="0" />
              <Integer name="DlMcsBler_8" value="0" />
              <Integer name="DlMcsBler_9" value="0" />
              <Integer name="DlMcsBler_10" value="0" />
              <Integer name="DlMcsBler_11" value="0" />
              <Integer name="DlMcsBler_12" value="0" />
              <Integer name="DlMcsBler_13" value="0" />
              <Integer name="DlMcsBler_14" value="0" />
              <Integer name="DlMcsBler_15" value="0" />
              <Integer name="DlMcsBler_16" value="0" />
              <Integer name="DlMcsBler_17" value="0" />
              <Integer name="DlMcsBler_18" value="0" />
              <Integer name="DlMcsBler_19" value="0" />
              <Integer name="DlMcsBler_20" value="0" />
              <Integer name="DlMcsBler_21" value="0" />
              <Integer name="DlMcsBler_22" value="0" />
              <Integer name="DlMcsBler_23" value="0" />
              <Integer name="DlMcsBler_24" value="0" />
              <Integer name="DlMcsBler_25" value="0" />
              <Integer name="DlMcsBler_26" value="0" />
              <Integer name="DlMcsBler_27" value="0" />
              <Integer name="DlMcsBler_28" value="0" />
              <Integer name="UlMcsBler_0" value="0" />
              <Integer name="UlMcsBler_1" value="0" />
              <Integer name="UlMcsBler_2" value="0" />
              <Integer name="UlMcsBler_3" value="0" />
              <Integer name="UlMcsBler_4" value="0" />
              <Integer name="UlMcsBler_5" value="0" />
              <Integer name="UlMcsBler_6" value="0" />
              <Integer name="UlMcsBler_7" value="0" />
              <Integer name="UlMcsBler_8" value="0" />
              <Integer name="UlMcsBler_9" value="0" />
              <Integer name="UlMcsBler_10" value="0" />
              <Integer name="UlMcsBler_11" value="0" />
              <Integer name="UlMcsBler_12" value="0" />
              <Integer name="UlMcsBler_13" value="0" />
              <Integer name="UlMcsBler_14" value="0" />
              <Integer name="UlMcsBler_15" value="0" />
              <Integer name="UlMcsBler_16" value="0" />
              <Integer name="UlMcsBler_17" value="0" />
              <Integer name="UlMcsBler_18" value="0" />
              <Integer name="UlMcsBler_19" value="0" />
              <Integer name="UlMcsBler_20" value="0" />
              <Integer name="UlMcsBler_21" value="0" />
              <Integer name="UlMcsBler_22" value="0" />
              <Integer name="UlMcsBler_23" value="0" />
              <Integer name="UlMcsBler_24" value="0" />
              <Integer name="UlMcsBler_25" value="0" />
              <Integer name="UlMcsBler_26" value="0" />
              <Integer name="UlMcsBler_27" value="0" />
              <Integer name="UlMcsBler_28" value="0" />
              <Integer name="Li" value="0" />
              <Integer name="Ri" value="2" />
              <Integer name="WbCqi" value="15" />
              <Integer name="FreqSelectivity" value="0" />
              <String name="FREQ_SELECTIVITY_SHOW" value="flat" />
              <Integer name="LoS" value="0" />
              <Boolean name="LOS_SHOW" value="true" />
              <Integer name="WbPmiX1i1" value="0" />
              <Integer name="WbPmiX1i2" value="0" />
              <Integer name="WbPmiX1i3" value="0" />
              <Integer name="WbPmiX2" value="0" />
              <Integer name="NumCsiRs" value="0" />
              <Integer name="Index_0" value="0" />
              <Integer name="L1Rsrp_0" value="126" />
              <Integer name="Index_1" value="0" />
              <Integer name="L1Rsrp_1" value="0" />
              <Integer name="Index_2" value="0" />
              <Integer name="L1Rsrp_2" value="0" />
              <Integer name="Index_3" value="0" />
              <Integer name="L1Rsrp_3" value="0" />
              <String name="empty" value=" " />
            </record>
          </db>
        </FiveGNrTable>
        <FirstBeamTable>
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="2.0">
            <record name="0" modifiable="true">
              <Integer name="RSRP" value="90" />
              <Integer name="RSRQ" value="90" />
              <Integer name="SNR" value="100" />
              <Integer name="Pathloss" value="20" />
              <Integer name="BeamListLen" value="0" />
              <Integer name="BeamId_0" value="0" />
              <Integer name="BeamId_1" value="0" />
              <Integer name="BeamId_2" value="0" />
              <Integer name="BeamId_3" value="0" />
              <Integer name="BeamId_4" value="0" />
              <Integer name="BeamId_5" value="0" />
              <Integer name="BeamId_6" value="0" />
              <Integer name="BeamId_7" value="0" />
              <Integer name="BeamId_8" value="0" />
              <Integer name="BeamId_9" value="0" />
              <Integer name="BeamId_10" value="0" />
              <Integer name="BeamId_11" value="0" />
              <Integer name="BeamId_12" value="0" />
              <Integer name="BeamId_13" value="0" />
              <Integer name="BeamId_14" value="0" />
              <Integer name="BeamId_15" value="0" />
            </record>
          </db>
        </FirstBeamTable>
        <SecondBeamTable>
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="2.0">
            <record name="0" modifiable="true">
              <Integer name="RSRP" value="90" />
              <Integer name="RSRQ" value="90" />
              <Integer name="SNR" value="100" />
              <Integer name="Pathloss" value="20" />
              <Integer name="BeamListLen" value="0" />
              <Integer name="BeamId_0" value="0" />
              <Integer name="BeamId_1" value="0" />
              <Integer name="BeamId_2" value="0" />
              <Integer name="BeamId_3" value="0" />
              <Integer name="BeamId_4" value="0" />
              <Integer name="BeamId_5" value="0" />
              <Integer name="BeamId_6" value="0" />
              <Integer name="BeamId_7" value="0" />
              <Integer name="BeamId_8" value="0" />
              <Integer name="BeamId_9" value="0" />
              <Integer name="BeamId_10" value="0" />
              <Integer name="BeamId_11" value="0" />
              <Integer name="BeamId_12" value="0" />
              <Integer name="BeamId_13" value="0" />
              <Integer name="BeamId_14" value="0" />
              <Integer name="BeamId_15" value="0" />
            </record>
          </db>
        </SecondBeamTable>
        <ThirdBeamTable>
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="2.0">
            <record name="0" modifiable="true">
              <Integer name="RSRP" value="90" />
              <Integer name="RSRQ" value="90" />
              <Integer name="SNR" value="100" />
              <Integer name="Pathloss" value="20" />
              <Integer name="BeamListLen" value="0" />
              <Integer name="BeamId_0" value="0" />
              <Integer name="BeamId_1" value="0" />
              <Integer name="BeamId_2" value="0" />
              <Integer name="BeamId_3" value="0" />
              <Integer name="BeamId_4" value="0" />
              <Integer name="BeamId_5" value="0" />
              <Integer name="BeamId_6" value="0" />
              <Integer name="BeamId_7" value="0" />
              <Integer name="BeamId_8" value="0" />
              <Integer name="BeamId_9" value="0" />
              <Integer name="BeamId_10" value="0" />
              <Integer name="BeamId_11" value="0" />
              <Integer name="BeamId_12" value="0" />
              <Integer name="BeamId_13" value="0" />
              <Integer name="BeamId_14" value="0" />
              <Integer name="BeamId_15" value="0" />
            </record>
          </db>
        </ThirdBeamTable>
        <OtherBeamTable>
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="2.0">
            <record name="0" modifiable="true">
              <Integer name="RSRP" value="90" />
              <Integer name="RSRQ" value="90" />
              <Integer name="SNR" value="100" />
              <Integer name="Pathloss" value="20" />
              <Integer name="BeamListLen" value="0" />
              <Integer name="BeamId_0" value="0" />
              <Integer name="BeamId_1" value="0" />
              <Integer name="BeamId_2" value="0" />
              <Integer name="BeamId_3" value="0" />
              <Integer name="BeamId_4" value="0" />
              <Integer name="BeamId_5" value="0" />
              <Integer name="BeamId_6" value="0" />
              <Integer name="BeamId_7" value="0" />
              <Integer name="BeamId_8" value="0" />
              <Integer name="BeamId_9" value="0" />
              <Integer name="BeamId_10" value="0" />
              <Integer name="BeamId_11" value="0" />
              <Integer name="BeamId_12" value="0" />
              <Integer name="BeamId_13" value="0" />
              <Integer name="BeamId_14" value="0" />
              <Integer name="BeamId_15" value="0" />
            </record>
          </db>
        </OtherBeamTable>
      </TemplateProfileMobility>
    </Group>
  </Groups>
  <SessionList>
    <Session name="New session 8" ACCESS_NETWORK="NR" InterarrivalTime="1000" RandomRate="false" Repetitions="1" groupRate="10000" groupRep="1" groupBlockLoop="false" groupMode="Variable Rate" SessionMode="Normal" SchedulingKind="Timer Triggered" StartSession="000110013New session 800000000000100000" loop="false" Group="1">
      <TestTraceManager masterTraceLength="11" traces="1">
        <TestTrace>
          <TemplateProfile name="Registration" instance="" Mandatory="false" SuccessPercentage="100.0" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="2000000000" />
          
        </TestTrace>
      </TestTraceManager>
    </Session>
  </SessionList>
  <globals />
  <SmartphoneSimulator userLibraryFilename="" />
  <cell_list />
  <func_low_list />
  <MdmCellBinding>&lt;?xml version="1.0" encoding="UTF-8" standalone="yes"?&gt;
&lt;RadioConditionCellBinding&gt;
    &lt;cellBindingMap/&gt;
    &lt;autoCellBinding&gt;false&lt;/autoCellBinding&gt;
&lt;/RadioConditionCellBinding&gt;</MdmCellBinding>
  <MdmCellBindingNr>&lt;?xml version="1.0" encoding="UTF-8" standalone="yes"?&gt;
&lt;RadioConditionNrCellBinding&gt;
    &lt;nrCellBindingMap/&gt;
&lt;/RadioConditionNrCellBinding&gt;</MdmCellBindingNr>
  <AmmExternalLinkedFiles />
</TestScenario>

