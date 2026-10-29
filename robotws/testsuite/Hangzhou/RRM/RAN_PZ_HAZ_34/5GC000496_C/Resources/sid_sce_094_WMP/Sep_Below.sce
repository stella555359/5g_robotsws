<?xml version="1.0" encoding="UTF-8"?>
<!-- Scenario created in date 2018-12-07 13:44:07 by AirMosaic LTE Uu 7.5.0RC6 (Build 201811271623)-->
<TestScenario Version="7" Repetitions="1" RepetitionsDelay="1000" Looped="false" DurationEnable="false" DetachShutdown="false" Annotation="" GlobalVariables="" cellbinding="" AppVersion="AirMosaic LTE Uu 7.5.0RC6 (Build 201811271623)" TstmName="LTE_Tm">
  <Bearer>
    <db name="Bearer" formatname="Bearer" version="1.0 1.0" />
  </Bearer>
  <BearerModificationProfileList>
    <db name="Bearer 0" formatname="BearerModDb" version="1.0" />
    <looped name="Bearer 0" value="false" />
    <db name="Bearer 1" formatname="BearerModDb" version="1.0" />
    <looped name="Bearer 1" value="false" />
  </BearerModificationProfileList>
  <Groups>
    <Group name="Group1" extensible="true" enableGroup="true" loopenGroupRepetitions="false" groupRepetitionsNumber="1">
      "user 001"
      <TemplateProfileMobility name="Mobility.FixedPosition" Cell="2" RadioCondition="NOHO%normal%1000,15,0,15,0,1,2,Disabled,0.0,0.0,0.0,None,Disabled,0.0,0.0,No Fading,Not Applicable" ForcedRRCConnReestProc="None">
        <LoopedMode enable="false" />
        <SpeedModeEditable enable="false" />
        <db name="BRCDb" formatname="BRCDb" version="1.0">
          <record name="0" modifiable="true">
            <String name="Timestamp" value="1000" />
            <String name="WB_CQI_CW1" value="15" />
            <String name="SB_CQI_CW1" value="0" />
            <String name="WB_CQI_CW2" value="15" />
            <String name="SB_CQI_CW2" value="0" />
            <Integer name="PMI" value="1" />
            <String name="RI" value="2" />
            <String name="Pathloss" value="Disabled" />
            <Double name="UL_BLER_Coeff" value="0.0" />
            <Double name="DL_BLER_CoeffTxDiv" value="0.0" />
            <Double name="DL_BLER_CoeffMIMO" value="0.0" />
            <String name="NormPowHeadr" value="None" />
            <String name="AWGN" value="Disabled" />
            <Double name="RadialSpeed" value="0.0" />
            <Double name="Position" value="0.0" />
            <link name="FadingProfileIndex" value="No Fading" />
            <String name="RadioOff" value="Not Applicable" />
          </record>
        </db>
      </TemplateProfileMobility>
    </Group>
  </Groups>
  <SessionList>
    <Session name="New session 10" InterarrivalTime="1000" RandomRate="false" Repetitions="1" groupRate="1000" groupRep="1" groupBlockLoop="false" groupMode="Variable Rate" SessionMode="Normal" SchedulingKind="Timer Triggered" StartSession="0006Group10014New session 1000000000000100000" loop="false" Group="Group1">
      <TestTraceManager masterTraceLength="5" traces="1">
        <TestTrace>
          <TemplateProfile name="Attach" instance="" Mandatory="false" SuccessPercentage="100.0" />
          <TemplateProfile name="IP Passthrough start" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" TIME_TO_WAIT_VIDEO="100" APN="Default APN" APC_IP=";user 001:192.168.60.2" APC_IP_NETMASK="" />
          <TemplateProfile name="Delay" instance="" Mandatory="true" SuccessPercentage="100.0" DELAY="6000000" />
          <TemplateProfile name="IP Passthrough stop" instance="" Mandatory="false" SuccessPercentage="100.0" BEARER_TAG="NONE" />
          <TemplateProfile name="Detach" instance="" Mandatory="false" SuccessPercentage="100.0" DETACH_SWOFF="false" />
        </TestTrace>
      </TestTraceManager>
    </Session>
  </SessionList>
  <globals />
  <SmartphoneSimulator userLibraryFilename="" />
  <cell_list />
  <func_low_list />
</TestScenario>

