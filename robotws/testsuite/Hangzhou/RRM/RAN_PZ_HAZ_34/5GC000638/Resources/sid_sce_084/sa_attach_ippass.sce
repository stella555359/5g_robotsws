<?xml version="1.0" encoding="UTF-8"?>
<!-- Scenario created in date 2019-05-22 20:44:23 by AirMosaic LTE Uu 7.7.0RC10 (Build 201904121131)-->
<TestScenario Version="7" Repetitions="1" RepetitionsDelay="1000" Looped="false" DurationEnable="false" DetachShutdown="false" Annotation="" GlobalVariables="" cellbinding="" nrcellbinding="" AppVersion="AirMosaic LTE Uu 7.7.0RC10 (Build 201904121131)" TstmName="LTE_Tm">
  <Bearer>
    <db name="Bearer" formatname="Bearer" version="1.0 1.0" />
  </Bearer>
  <Groups>
    <Group name="1" extensible="true" enableGroup="true" loopenGroupRepetitions="false" groupRepetitionsNumber="1">
      "user 001"
      <TemplateProfileMobility lsuNrCell="1" name="com.prisma.mobility.mobilityplugin.fixedmobility.staticmobility.StaticFiveGNrMobility">
        <FiveGNrTable>
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="1.0">
            <record name="0" modifiable="true">
              <Integer name="PosId" value="0" />
              <Integer name="NextPosId" value="-1" />
              <Integer name="Interval" value="200" />
              <Integer name="Time" value="0" />
              <Integer name="Distance" value="0" />
              <Integer name="RadialSpeed" value="0" />
              <Integer name="PathLenght" value="0" />
              <Integer name="RLF_HARQ_OFF" value="0" />
              <Boolean name="RLF_HARQ_OFF_SHOW" value="false" />
              <Integer name="RLF_CSI_OFF" value="0" />
              <Boolean name="RLF_CSI_OFF_SHOW" value="false" />
              <Integer name="RLF_UE_TRIGGERED" value="0" />
              <Boolean name="RLF_UE_TRIGGERED_SHOW" value="false" />
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
              <Integer name="Ri" value="0" />
              <Integer name="WbCqi" value="0" />
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
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="1.0">
            <record name="0" modifiable="true">
              <Integer name="RSRP" value="0" />
              <Integer name="RSRQ" value="0" />
              <Integer name="SNR" value="0" />
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
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="1.0">
            <record name="0" modifiable="true">
              <Integer name="RSRP" value="0" />
              <Integer name="RSRQ" value="0" />
              <Integer name="SNR" value="0" />
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
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="1.0">
            <record name="0" modifiable="true">
              <Integer name="RSRP" value="0" />
              <Integer name="RSRQ" value="0" />
              <Integer name="SNR" value="0" />
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
          <db name="mapDrivenParamsNR" formatname="mapDrivenParamsNR" version="1.0">
            <record name="0" modifiable="true">
              <Integer name="RSRP" value="0" />
              <Integer name="RSRQ" value="0" />
              <Integer name="SNR" value="0" />
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
    <Session name="New session 8" InterarrivalTime="1000" RandomRate="false" Repetitions="1" groupRate="10000" groupRep="1" groupBlockLoop="false" groupMode="Variable Rate" SessionMode="Normal" SchedulingKind="Timer Triggered" StartSession="000110013New session 800000000000100000" loop="false" Group="1">
      <TestTraceManager masterTraceLength="10" traces="1">
        <TestTrace>
          <TemplateProfile name="Attach" instance="" Mandatory="false" SuccessPercentage="100.0" />
          <TemplateProfile name="PDN Connection Activation" instance="SA" Mandatory="false" SuccessPercentage="100.0" REQUEST_TYPE="InitialRequest" PDN_TYPE="IPv4" ESM_INFO_TRANSFER_FLAG="false" APN="wap1.nokia.com" PCO="" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="60000" />
          <TemplateProfile name="IP Passthrough start" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" TIME_TO_WAIT_VIDEO="100" APN="wap1.nokia.com" APC_IP=";user 001:192.168.60.2" APC_IP_NETMASK="255.255.255.0" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="2147483647" />
          <TemplateProfile name="IP Passthrough stop" instance="" Mandatory="false" SuccessPercentage="100.0" BEARER_TAG="NONE" />
          <TemplateProfile name="FTP Session" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" TIME_TO_WAIT_VIDEO="100" APN="5gcn" Operation="Download" User="user" Password="user" Hostname="10.9.34.12" RemotePath="test" WriteDownload="false" URL_DEL="0" FTP_MODE="false" TEST_TIMEOUT="0" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="600000000" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="2147483647" />
          <TemplateProfile name="Detach" instance="" Mandatory="false" SuccessPercentage="100.0" DETACH_SWOFF="true" />
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

