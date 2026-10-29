<?xml version="1.0" encoding="UTF-8"?>
<!-- Scenario created in date 2018-10-29 10:30:06 by AirMosaic LTE Uu 7.4.0RC6 (Build 201809241454)-->
<TestScenario Version="7" Repetitions="1" RepetitionsDelay="1000" Looped="false" DurationEnable="false" DetachShutdown="false" Annotation="" GlobalVariables="" cellbinding="" AppVersion="AirMosaic LTE Uu 7.4.0RC6 (Build 201809241454)" TstmName="LTE_Tm">
  <Bearer>
    <db name="Bearer" formatname="Bearer" version="1.0 1.0">
      <record name="Bearer 0" modifiable="true">
        <String name="instance" value="Bearer 0" />
        <Boolean name="Mandatory" value="false" />
        <Double name="SuccessPercentage" value="100.0" />
        <String name="QCI_MODE" value="Standard 3GPP QCI" />
        <String name="REQ_QCI" value="9" />
        <Integer name="OP_QCI" value="128" />
        <Object name="TFA" value="20" />
        <link name="REQ_MAX_BR_UL" value="Subscribed bitrate" />
        <link name="REQ_MAX_BR_DL" value="Subscribed bitrate" />
        <link name="REQ_GUAR_BR_UL" value="Subscribed bitrate" />
        <link name="REQ_GUAR_BR_DL" value="Subscribed bitrate" />
        <Object name="MOD_PROFILE" value="" />
        <Integer name="IDX_FOR_REORDER" value="-1" />
        <Boolean name="L1L2BearerEnable" value="true" />
        <Integer name="L1L2EPSBearerId" value="5" />
        <Integer name="T_ACT_OFFSET" value="0" />
        <String name="DEACT_FLAG_ENUM" value="UE triggered deactivation" />
      </record>
    </db>
  </Bearer>
  <BearerModificationProfileList>
    <db name="Bearer 0" formatname="BearerModDb" version="1.0" />
    <looped name="Bearer 0" value="false" />
  </BearerModificationProfileList>
  <Groups>
    <Group name="Attach_Lte" extensible="true" enableGroup="true" loopenGroupRepetitions="false" groupRepetitionsNumber="1">
      "user 0001"
      <TemplateProfileMobility name="Mobility.FixedPosition" Cell="10" RadioCondition="NOHO%normal%1000,15,0,15,0,1,2,Disabled,0.0,0.0,0.0,None,Disabled,0.0,0.0,No Fading,Not Applicable" ForcedRRCConnReestProc="None">
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
    <Session name="New session 1" InterarrivalTime="1000" RandomRate="false" Repetitions="1" groupRate="1000" groupRep="1" groupBlockLoop="false" groupMode="Variable Rate" SessionMode="Normal" SchedulingKind="Timer Triggered" StartSession="0010Attach_Lte0013New session 100000000000100000" loop="false" Group="Attach_Lte">
      <TestTraceManager masterTraceLength="3" traces="1">
        <TestTrace>
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

