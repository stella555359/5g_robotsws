<?xml version="1.0" encoding="UTF-8"?>
<!-- Scenario created in date 2020-01-04 13:12:21 by AirMosaicLTEUu 8.12.0RC12 (Build 201911211444)-->
<TestScenario Version="7" Repetitions="1" RepetitionsDelay="1000" Looped="false" DurationEnable="false" Annotation="" GlobalVariables="" cellbinding="" nrcellbinding="" AppVersion="AirMosaicLTEUu 8.12.0RC12 (Build 201911211444)" TstmName="LTE_Tm">
  <Bearer>
    <db name="Bearer" formatname="Bearer" version="1.0 1.0" />
  </Bearer>
  <Flow>
    <db name="Flow" formatname="Flow" version="1.0 1.0" />
  </Flow>
  <BearerModificationProfileList>
    <db name="Bearer 0" formatname="BearerModDb" version="1.0" />
    <looped name="Bearer 0" value="false" />
    <db name="Bearer 1" formatname="BearerModDb" version="1.0" />
    <looped name="Bearer 1" value="false" />
  </BearerModificationProfileList>
  <Groups>
    <Group name="Group1" extensible="true" enableGroup="true" loopenGroupRepetitions="false">
      "user 001"
      <TemplateProfileMobility lsuLteCell="2" lsuNrCell="1" property="true" mobilityNameProperty="Static Legacy Mobility" name="com.prisma.mobility.mobilityplugin.fixedmobility.staticmobility.StaticLegacyMobility">
        <FiveGNrTable>
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="4.0">
            <record name="0" modifiable="true">
              <Integer name="PosId" value="0" />
              <Integer name="NextPosId" value="0" />
              <Integer name="Interval" value="250" />
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
              <Boolean name="AWGNEnable" value="false" />
              <Integer name="AWGN" value="-150" />
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
              <Integer name="Ri" value="1" />
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
              <Integer name="GoodLine" value="0" />
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
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="4.0">
            <record name="0" modifiable="true">
              <Integer name="RSRP" value="90" />
              <Integer name="RSRQ" value="90" />
              <Integer name="SNR" value="100" />
              <Integer name="Pathloss" value="20" />
              <Integer name="BeamListLen" value="0" />
              <String name="BeamId_0" value="0-0" />
              <String name="BeamId_1" value="0-0" />
              <String name="BeamId_2" value="0-0" />
              <String name="BeamId_3" value="0-0" />
              <String name="BeamId_4" value="0-0" />
              <String name="BeamId_5" value="0-0" />
              <String name="BeamId_6" value="0-0" />
              <String name="BeamId_7" value="0-0" />
              <String name="BeamId_8" value="0-0" />
              <String name="BeamId_9" value="0-0" />
              <String name="BeamId_10" value="0-0" />
              <String name="BeamId_11" value="0-0" />
              <String name="BeamId_12" value="0-0" />
              <String name="BeamId_13" value="0-0" />
              <String name="BeamId_14" value="0-0" />
              <String name="BeamId_15" value="0-0" />
            </record>
          </db>
        </FirstBeamTable>
        <SecondBeamTable>
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="4.0">
            <record name="0" modifiable="true">
              <Integer name="RSRP" value="90" />
              <Integer name="RSRQ" value="90" />
              <Integer name="SNR" value="100" />
              <Integer name="Pathloss" value="20" />
              <Integer name="BeamListLen" value="0" />
              <String name="BeamId_0" value="0-0" />
              <String name="BeamId_1" value="0-0" />
              <String name="BeamId_2" value="0-0" />
              <String name="BeamId_3" value="0-0" />
              <String name="BeamId_4" value="0-0" />
              <String name="BeamId_5" value="0-0" />
              <String name="BeamId_6" value="0-0" />
              <String name="BeamId_7" value="0-0" />
              <String name="BeamId_8" value="0-0" />
              <String name="BeamId_9" value="0-0" />
              <String name="BeamId_10" value="0-0" />
              <String name="BeamId_11" value="0-0" />
              <String name="BeamId_12" value="0-0" />
              <String name="BeamId_13" value="0-0" />
              <String name="BeamId_14" value="0-0" />
              <String name="BeamId_15" value="0-0" />
            </record>
          </db>
        </SecondBeamTable>
        <ThirdBeamTable>
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="4.0">
            <record name="0" modifiable="true">
              <Integer name="RSRP" value="90" />
              <Integer name="RSRQ" value="90" />
              <Integer name="SNR" value="100" />
              <Integer name="Pathloss" value="20" />
              <Integer name="BeamListLen" value="0" />
              <String name="BeamId_0" value="0-0" />
              <String name="BeamId_1" value="0-0" />
              <String name="BeamId_2" value="0-0" />
              <String name="BeamId_3" value="0-0" />
              <String name="BeamId_4" value="0-0" />
              <String name="BeamId_5" value="0-0" />
              <String name="BeamId_6" value="0-0" />
              <String name="BeamId_7" value="0-0" />
              <String name="BeamId_8" value="0-0" />
              <String name="BeamId_9" value="0-0" />
              <String name="BeamId_10" value="0-0" />
              <String name="BeamId_11" value="0-0" />
              <String name="BeamId_12" value="0-0" />
              <String name="BeamId_13" value="0-0" />
              <String name="BeamId_14" value="0-0" />
              <String name="BeamId_15" value="0-0" />
            </record>
          </db>
        </ThirdBeamTable>
        <OtherBeamTable>
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="4.0">
            <record name="0" modifiable="true">
              <Integer name="RSRP" value="90" />
              <Integer name="RSRQ" value="90" />
              <Integer name="SNR" value="100" />
              <Integer name="Pathloss" value="20" />
              <Integer name="BeamListLen" value="0" />
              <String name="BeamId_0" value="0-0" />
              <String name="BeamId_1" value="0-0" />
              <String name="BeamId_2" value="0-0" />
              <String name="BeamId_3" value="0-0" />
              <String name="BeamId_4" value="0-0" />
              <String name="BeamId_5" value="0-0" />
              <String name="BeamId_6" value="0-0" />
              <String name="BeamId_7" value="0-0" />
              <String name="BeamId_8" value="0-0" />
              <String name="BeamId_9" value="0-0" />
              <String name="BeamId_10" value="0-0" />
              <String name="BeamId_11" value="0-0" />
              <String name="BeamId_12" value="0-0" />
              <String name="BeamId_13" value="0-0" />
              <String name="BeamId_14" value="0-0" />
              <String name="BeamId_15" value="0-0" />
            </record>
          </db>
        </OtherBeamTable>
        <LteTable>
          <db name="mapDrivenParams" formatname="mapDrivenParams" version="1.0">
            <record name="0" modifiable="true">
              <Integer name="PosId" value="0" />
              <Integer name="NextPosId" value="0" />
              <Integer name="Interval" value="250" />
              <Integer name="Time" value="0" />
              <String name="AfterBeforeWaypoints" value="-" />
              <Double name="Longitude" value="0.0" />
              <Double name="Latitude" value="0.0" />
              <Integer name="PathLenght" value="0" />
              <Double name="RSRP" value="0.0" />
              <Double name="RSRQ" value="0.0" />
              <Integer name="AWGN" value="-122" />
              <Integer name="radial_speed" value="0" />
              <Integer name="distance" value="0" />
              <Integer name="wb_cqi_cw1" value="15" />
              <Integer name="wb_cqi_cw2" value="15" />
              <Integer name="pathloss" value="20" />
              <Integer name="pmi" value="0" />
              <Integer name="ri" value="1" />
              <Double name="snr" value="30.0" />
              <Integer name="dl_bler_txd_00" value="0" />
              <Integer name="dl_bler_txd_01" value="0" />
              <Integer name="dl_bler_txd_02" value="0" />
              <Integer name="dl_bler_txd_03" value="0" />
              <Integer name="dl_bler_txd_04" value="0" />
              <Integer name="dl_bler_txd_05" value="0" />
              <Integer name="dl_bler_txd_06" value="0" />
              <Integer name="dl_bler_txd_07" value="0" />
              <Integer name="dl_bler_txd_08" value="0" />
              <Integer name="dl_bler_txd_09" value="0" />
              <Integer name="dl_bler_txd_10" value="0" />
              <Integer name="dl_bler_txd_11" value="0" />
              <Integer name="dl_bler_txd_12" value="0" />
              <Integer name="dl_bler_txd_13" value="0" />
              <Integer name="dl_bler_txd_14" value="0" />
              <Integer name="dl_bler_txd_15" value="0" />
              <Integer name="dl_bler_txd_16" value="0" />
              <Integer name="dl_bler_txd_17" value="0" />
              <Integer name="dl_bler_txd_18" value="0" />
              <Integer name="dl_bler_txd_19" value="0" />
              <Integer name="dl_bler_txd_20" value="0" />
              <Integer name="dl_bler_txd_21" value="0" />
              <Integer name="dl_bler_txd_22" value="0" />
              <Integer name="dl_bler_txd_23" value="0" />
              <Integer name="dl_bler_txd_24" value="0" />
              <Integer name="dl_bler_txd_25" value="0" />
              <Integer name="dl_bler_txd_26" value="0" />
              <Integer name="dl_bler_txd_27" value="0" />
              <Integer name="dl_bler_txd_28" value="0" />
              <Integer name="dl_bler_mimo_00" value="0" />
              <Integer name="dl_bler_mimo_01" value="0" />
              <Integer name="dl_bler_mimo_02" value="0" />
              <Integer name="dl_bler_mimo_03" value="0" />
              <Integer name="dl_bler_mimo_04" value="0" />
              <Integer name="dl_bler_mimo_05" value="0" />
              <Integer name="dl_bler_mimo_06" value="0" />
              <Integer name="dl_bler_mimo_07" value="0" />
              <Integer name="dl_bler_mimo_08" value="0" />
              <Integer name="dl_bler_mimo_09" value="0" />
              <Integer name="dl_bler_mimo_10" value="0" />
              <Integer name="dl_bler_mimo_11" value="0" />
              <Integer name="dl_bler_mimo_12" value="0" />
              <Integer name="dl_bler_mimo_13" value="0" />
              <Integer name="dl_bler_mimo_14" value="0" />
              <Integer name="dl_bler_mimo_15" value="0" />
              <Integer name="dl_bler_mimo_16" value="0" />
              <Integer name="dl_bler_mimo_17" value="0" />
              <Integer name="dl_bler_mimo_18" value="0" />
              <Integer name="dl_bler_mimo_19" value="0" />
              <Integer name="dl_bler_mimo_20" value="0" />
              <Integer name="dl_bler_mimo_21" value="0" />
              <Integer name="dl_bler_mimo_22" value="0" />
              <Integer name="dl_bler_mimo_23" value="0" />
              <Integer name="dl_bler_mimo_24" value="0" />
              <Integer name="dl_bler_mimo_25" value="0" />
              <Integer name="dl_bler_mimo_26" value="0" />
              <Integer name="dl_bler_mimo_27" value="0" />
              <Integer name="dl_bler_mimo_28" value="0" />
              <Integer name="radio_off" value="0" />
              <String name="FadingIndex" value="No Fading" />
              <Integer name="abs_wb_cqi_cw1" value="15" />
              <Integer name="abs_wb_cqi_cw2" value="15" />
              <Integer name="abs_sb_cqi_cw1" value="15" />
              <Integer name="abs_sb_cqi_cw2" value="15" />
              <Integer name="absRi" value="1" />
            </record>
          </db>
        </LteTable>
      </TemplateProfileMobility>
    </Group>
  </Groups>
  <SessionList>
    <Session name="New session 10" ACCESS_NETWORK="LTE" InterarrivalTime="1000" RandomRate="false" Repetitions="1" groupRate="1000" groupRep="1" groupBlockLoop="false" groupMode="Variable Rate" SessionMode="Normal" SchedulingKind="Timer Triggered" StartSession="0006Group10014New session 1000000000000100000" loop="false" Group="Group1">
      <TestTraceManager masterTraceLength="5" traces="1">
        <TestTrace>
          <TemplateProfile name="Attach" instance="" Mandatory="false" SuccessPercentage="100.0" />
          <TemplateProfile name="IP Passthrough start" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" APN="Default APN" FlowType="Default flow" APC_IP=";user 001:192.168.60.2" APC_IP_NETMASK="" />
          <TemplateProfile name="Delay" instance="" Mandatory="true" SuccessPercentage="100.0" DELAY="720000000" />
          <TemplateProfile name="IP Passthrough stop" instance="" Mandatory="false" SuccessPercentage="100.0" BEARER_TAG="NONE" FLOW_TAG="NONE" />
          <TemplateProfile name="Detach" instance="" Mandatory="false" SuccessPercentage="100.0" DETACH_SWOFF="false" />
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

