-- MySQL dump 10.13  Distrib 5.7.10, for Linux (x86_64)
--
-- mysqldump -p -u 5gadm_user --add-drop-table --databases perf_5g --no-data > perf_portal_table_creation.sql
--
-- Host: localhost    Database: perf_5g
-- ------------------------------------------------------
-- Server version	5.7.10

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `perf_5g`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `perf_5g` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `perf_5g`;

--
-- Table structure for table `CrontabLastRefresh`
--

DROP TABLE IF EXISTS `CrontabLastRefresh`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CrontabLastRefresh` (
  `action` enum('checkBoxPlotIncrease','checkDelFileOnDD','trendMonitoring') NOT NULL DEFAULT 'checkBoxPlotIncrease',
  `lastRefreshDate` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` enum('OK','NOK') NOT NULL,
  KEY `action_idx` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `KpiLeadTime`
--

DROP TABLE IF EXISTS `KpiLeadTime`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `KpiLeadTime` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `testId` int(10) unsigned NOT NULL,
  `component` varchar(50) NOT NULL,
  `cellGroupInstance` int(2) unsigned NOT NULL DEFAULT '1',
  `name` varchar(200) NOT NULL,
  `min` double unsigned NOT NULL,
  `avg` double unsigned NOT NULL,
  `95p` double unsigned NOT NULL,
  `max` double unsigned NOT NULL,
  `nbSlots` int(10) unsigned DEFAULT NULL,
  `createdDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastUpdateDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `test_id_idx` (`testId`),
  KEY `created_idx` (`createdDateTime`),
  KEY `update_idx` (`lastUpdateDateTime`),
  CONSTRAINT `testId_FGK` FOREIGN KEY (`testId`) REFERENCES `Test` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30315187 DEFAULT CHARSET=utf8mb4 COMMENT='New Kpi Format';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `KpiLeadTimeEndurance`
--

DROP TABLE IF EXISTS `KpiLeadTimeEndurance`;
/*!50001 DROP VIEW IF EXISTS `KpiLeadTimeEndurance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `KpiLeadTimeEndurance` AS SELECT 
 1 AS `id`,
 1 AS `testId`,
 1 AS `component`,
 1 AS `cellGroupInstance`,
 1 AS `name`,
 1 AS `min`,
 1 AS `avg`,
 1 AS `95p`,
 1 AS `max`,
 1 AS `createdDateTime`,
 1 AS `lastUpdateDateTime`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `KpiLeadTimeNotEndurance`
--

DROP TABLE IF EXISTS `KpiLeadTimeNotEndurance`;
/*!50001 DROP VIEW IF EXISTS `KpiLeadTimeNotEndurance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `KpiLeadTimeNotEndurance` AS SELECT 
 1 AS `id`,
 1 AS `testId`,
 1 AS `component`,
 1 AS `cellGroupInstance`,
 1 AS `name`,
 1 AS `min`,
 1 AS `avg`,
 1 AS `95p`,
 1 AS `max`,
 1 AS `nbSlots`,
 1 AS `createdDateTime`,
 1 AS `lastUpdateDateTime`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `KpiMiddleware`
--

DROP TABLE IF EXISTS `KpiMiddleware`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `KpiMiddleware` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `testId` int(10) unsigned NOT NULL,
  `component` varchar(50) NOT NULL,
  `cellGroupInstance` int(2) unsigned NOT NULL DEFAULT '1',
  `name` varchar(200) NOT NULL,
  `min` double unsigned NOT NULL,
  `avg` double unsigned NOT NULL,
  `95p` double unsigned NOT NULL,
  `max` double unsigned NOT NULL,
  `createdDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastUpdaateDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `test_id_idx` (`testId`),
  KEY `created_idx` (`createdDateTime`),
  KEY `updted_idx` (`lastUpdaateDateTime`),
  CONSTRAINT `middleware_test_fgk` FOREIGN KEY (`testId`) REFERENCES `Test` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4435232 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `KpiMiddlewareNotEndurance`
--

DROP TABLE IF EXISTS `KpiMiddlewareNotEndurance`;
/*!50001 DROP VIEW IF EXISTS `KpiMiddlewareNotEndurance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `KpiMiddlewareNotEndurance` AS SELECT 
 1 AS `id`,
 1 AS `testId`,
 1 AS `component`,
 1 AS `cellGroupInstance`,
 1 AS `name`,
 1 AS `min`,
 1 AS `avg`,
 1 AS `95p`,
 1 AS `max`,
 1 AS `createdDateTime`,
 1 AS `lastUpdaateDateTime`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `KpiProcTimePerEO`
--

DROP TABLE IF EXISTS `KpiProcTimePerEO`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `KpiProcTimePerEO` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `testId` int(10) unsigned NOT NULL,
  `component` varchar(50) NOT NULL,
  `cellGroupInstance` int(2) unsigned NOT NULL DEFAULT '1',
  `ventilated` enum('True','False') NOT NULL,
  `coreId` varchar(50) DEFAULT NULL,
  `eoNameAndInstance` varchar(200) DEFAULT NULL,
  `isProbe` enum('True','False') NOT NULL,
  `subComponent1` varchar(200) DEFAULT NULL,
  `subComponent2` varchar(200) DEFAULT NULL,
  `subComponent3` varchar(200) DEFAULT NULL,
  `subComponent4` varchar(200) DEFAULT NULL,
  `subComponent5` varchar(200) DEFAULT NULL,
  `min` double unsigned NOT NULL,
  `avg` double unsigned NOT NULL,
  `95p` double unsigned NOT NULL,
  `max` double unsigned NOT NULL,
  `nbSlots` int(10) unsigned DEFAULT NULL,
  `createdDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastUpdateDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `test_id_idx` (`testId`),
  KEY `created_idx` (`createdDateTime`),
  KEY `update_idx` (`lastUpdateDateTime`),
  KEY `subComponent3_idx` (`subComponent3`),
  KEY `subComponent4_idx` (`subComponent4`),
  CONSTRAINT `ProcPerEOTestId_FGK` FOREIGN KEY (`testId`) REFERENCES `Test` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=127072408 DEFAULT CHARSET=utf8mb4 COMMENT='New Kpi Format';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `KpiProcTimePerEOEndurance`
--

DROP TABLE IF EXISTS `KpiProcTimePerEOEndurance`;
/*!50001 DROP VIEW IF EXISTS `KpiProcTimePerEOEndurance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `KpiProcTimePerEOEndurance` AS SELECT 
 1 AS `id`,
 1 AS `testId`,
 1 AS `component`,
 1 AS `cellGroupInstance`,
 1 AS `ventilated`,
 1 AS `coreId`,
 1 AS `eoNameAndInstance`,
 1 AS `isProbe`,
 1 AS `subComponent1`,
 1 AS `subComponent2`,
 1 AS `subComponent3`,
 1 AS `subComponent4`,
 1 AS `subComponent5`,
 1 AS `min`,
 1 AS `avg`,
 1 AS `95p`,
 1 AS `max`,
 1 AS `nbSlots`,
 1 AS `createdDateTime`,
 1 AS `lastUpdateDateTime`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `KpiProcTimePerEONotEndurance`
--

DROP TABLE IF EXISTS `KpiProcTimePerEONotEndurance`;
/*!50001 DROP VIEW IF EXISTS `KpiProcTimePerEONotEndurance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `KpiProcTimePerEONotEndurance` AS SELECT 
 1 AS `id`,
 1 AS `testId`,
 1 AS `component`,
 1 AS `cellGroupInstance`,
 1 AS `ventilated`,
 1 AS `coreId`,
 1 AS `eoNameAndInstance`,
 1 AS `isProbe`,
 1 AS `subComponent1`,
 1 AS `subComponent2`,
 1 AS `subComponent3`,
 1 AS `subComponent4`,
 1 AS `subComponent5`,
 1 AS `min`,
 1 AS `avg`,
 1 AS `95p`,
 1 AS `max`,
 1 AS `nbSlots`,
 1 AS `createdDateTime`,
 1 AS `lastUpdateDateTime`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `KpiProcessingTime`
--

DROP TABLE IF EXISTS `KpiProcessingTime`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `KpiProcessingTime` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `testId` int(10) unsigned NOT NULL,
  `component` varchar(50) NOT NULL,
  `cellGroupInstance` int(2) unsigned NOT NULL DEFAULT '1',
  `name` varchar(200) NOT NULL,
  `min` double unsigned NOT NULL,
  `avg` double unsigned NOT NULL,
  `95p` double unsigned NOT NULL,
  `max` double unsigned NOT NULL,
  `nbSlots` int(10) unsigned DEFAULT NULL,
  `createdDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastUpdateDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `tets_id_idx` (`testId`),
  KEY `created_idx` (`createdDateTime`),
  KEY `updated_idx` (`lastUpdateDateTime`),
  CONSTRAINT `ProcTime_testId_FGK` FOREIGN KEY (`testId`) REFERENCES `Test` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11841520 DEFAULT CHARSET=utf8mb4 COMMENT='New Kpi Format';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `KpiProcessingTimeEndurance`
--

DROP TABLE IF EXISTS `KpiProcessingTimeEndurance`;
/*!50001 DROP VIEW IF EXISTS `KpiProcessingTimeEndurance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `KpiProcessingTimeEndurance` AS SELECT 
 1 AS `id`,
 1 AS `testId`,
 1 AS `component`,
 1 AS `cellGroupInstance`,
 1 AS `name`,
 1 AS `min`,
 1 AS `avg`,
 1 AS `95p`,
 1 AS `max`,
 1 AS `createdDateTime`,
 1 AS `lastUpdateDateTime`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `KpiProcessingTimeNotEndurance`
--

DROP TABLE IF EXISTS `KpiProcessingTimeNotEndurance`;
/*!50001 DROP VIEW IF EXISTS `KpiProcessingTimeNotEndurance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `KpiProcessingTimeNotEndurance` AS SELECT 
 1 AS `id`,
 1 AS `testId`,
 1 AS `component`,
 1 AS `cellGroupInstance`,
 1 AS `name`,
 1 AS `min`,
 1 AS `avg`,
 1 AS `95p`,
 1 AS `max`,
 1 AS `nbSlots`,
 1 AS `createdDateTime`,
 1 AS `lastUpdateDateTime`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `KpiValues`
--

DROP TABLE IF EXISTS `KpiValues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `KpiValues` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `testId` int(10) unsigned NOT NULL,
  `component` varchar(50) NOT NULL,
  `cellGroupInstance` int(2) unsigned NOT NULL DEFAULT '1',
  `ventilated` enum('True','False') NOT NULL,
  `subComponent1` varchar(200) DEFAULT NULL,
  `subComponent2` varchar(200) DEFAULT NULL,
  `min` double unsigned NOT NULL,
  `avg` double unsigned NOT NULL,
  `95p` double unsigned NOT NULL,
  `max` double unsigned NOT NULL,
  `nbSlots` int(10) unsigned DEFAULT NULL,
  `createdDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastUpdateDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `test_id_idx` (`testId`),
  KEY `created_idx` (`createdDateTime`),
  KEY `update_idx` (`lastUpdateDateTime`),
  CONSTRAINT `ValuestestId_FGK` FOREIGN KEY (`testId`) REFERENCES `Test` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=99134043 DEFAULT CHARSET=utf8mb4 COMMENT='New Kpi Format';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `KpiValuesEndurance`
--

DROP TABLE IF EXISTS `KpiValuesEndurance`;
/*!50001 DROP VIEW IF EXISTS `KpiValuesEndurance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `KpiValuesEndurance` AS SELECT 
 1 AS `id`,
 1 AS `testId`,
 1 AS `component`,
 1 AS `cellGroupInstance`,
 1 AS `ventilated`,
 1 AS `subComponent1`,
 1 AS `subComponent2`,
 1 AS `min`,
 1 AS `avg`,
 1 AS `95p`,
 1 AS `max`,
 1 AS `createdDateTime`,
 1 AS `lastUpdateDateTime`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `KpiValuesNotEndurance`
--

DROP TABLE IF EXISTS `KpiValuesNotEndurance`;
/*!50001 DROP VIEW IF EXISTS `KpiValuesNotEndurance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `KpiValuesNotEndurance` AS SELECT 
 1 AS `id`,
 1 AS `testId`,
 1 AS `component`,
 1 AS `cellGroupInstance`,
 1 AS `ventilated`,
 1 AS `subComponent1`,
 1 AS `subComponent2`,
 1 AS `min`,
 1 AS `avg`,
 1 AS `95p`,
 1 AS `max`,
 1 AS `nbSlots`,
 1 AS `createdDateTime`,
 1 AS `lastUpdateDateTime`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `RelatedCommit`
--

DROP TABLE IF EXISTS `RelatedCommit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RelatedCommit` (
  `softwareBranch` varchar(50) NOT NULL DEFAULT 'master',
  `softwareCommit` varchar(100) NOT NULL,
  `softwareCommitDate` datetime NOT NULL,
  `relatedCommit` varchar(100) NOT NULL,
  `createdDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastUpdateDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `commitIdx` (`softwareCommit`,`softwareBranch`) USING BTREE,
  KEY `createdDateTimeIdx` (`createdDateTime`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Test`
--

DROP TABLE IF EXISTS `Test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Test` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `board` varchar(10) NOT NULL,
  `CCNumber` int(2) NOT NULL,
  `UENumber` int(2) NOT NULL,
  `DDtype` varchar(10) NOT NULL,
  `TTIDuration` int(2) NOT NULL,
  `UESchedNumber` int(2) NOT NULL,
  `beamNumber` int(2) NOT NULL,
  `feature` varchar(50) DEFAULT NULL,
  `configKey` varchar(250) DEFAULT NULL,
  `softwareBranch` varchar(50) NOT NULL,
  `softwareCommit` varchar(100) NOT NULL,
  `softwareCommitDate` datetime NOT NULL,
  `testDate` datetime NOT NULL,
  `testType` enum('Post','Continuous','Endurance','Manual','CRT','ET') DEFAULT 'Post',
  `testEnv` enum('SCT','L1L2 Pairwise') NOT NULL DEFAULT 'SCT',
  `testStatus` enum('NA','FAILED','PASSED') NOT NULL DEFAULT 'NA',
  `fileKPI` varchar(250) NOT NULL,
  `fileSnapshot` varchar(250) DEFAULT NULL,
  `fileMiddleware` varchar(250) DEFAULT NULL,
  `fileChromeTracing` varchar(250) DEFAULT NULL,
  `userCSL` varchar(20) DEFAULT NULL,
  `jenkinsJob` varchar(50) DEFAULT NULL,
  `jenkinsJobId` int(10) unsigned DEFAULT NULL,
  `jenkinsURL` varchar(300) DEFAULT NULL,
  `createdDateTime` datetime DEFAULT CURRENT_TIMESTAMP,
  `lastUpdateDateTime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_test_discriminent` (`fileKPI`),
  KEY `ciTestType_idx` (`testType`),
  KEY `test_name` (`board`,`CCNumber`,`UENumber`,`DDtype`,`TTIDuration`,`UESchedNumber`,`beamNumber`,`feature`,`configKey`),
  KEY `created_idx` (`createdDateTime`),
  KEY `updated_idx` (`lastUpdateDateTime`),
  KEY `softDte_idx` (`softwareCommitDate`),
  KEY `jenkinsJob_idx` (`jenkinsJob`)
) ENGINE=InnoDB AUTO_INCREMENT=9423380 DEFAULT CHARSET=utf8mb4 COMMENT='Contain test identification and description';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ThresholdAlarm`
--

DROP TABLE IF EXISTS `ThresholdAlarm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ThresholdAlarm` (
  `testId` int(10) unsigned NOT NULL,
  `thresholdType` varchar(50) NOT NULL,
  `message` varchar(500) NOT NULL,
  `criticity` enum('Minor','Major','Critical') NOT NULL DEFAULT 'Minor',
  `createdDateTime` datetime DEFAULT CURRENT_TIMESTAMP,
  `lastUpdateDateTime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `Index 1` (`testId`),
  KEY `criticity_idx` (`criticity`),
  KEY `created_idx` (`createdDateTime`),
  KEY `updated_idx` (`lastUpdateDateTime`),
  CONSTRAINT `FK_ThresholdAlarm_Test` FOREIGN KEY (`testId`) REFERENCES `Test` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `relationCommitWith3PreviousAnd3Next`
--

DROP TABLE IF EXISTS `relationCommitWith3PreviousAnd3Next`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relationCommitWith3PreviousAnd3Next` (
  `softwareCommitName` varchar(100) NOT NULL DEFAULT 'TOTO',
  `FormatedCommitName` varchar(35) NOT NULL,
  `relatedCommitName` varchar(100) NOT NULL,
  `createdDateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `relatedCreatedDateTime` (`createdDateTime`),
  KEY `CommitnameIdx` (`softwareCommitName`),
  KEY `RelatedCommitNamrIdx` (`relatedCommitName`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Current Database: `perf_5g`
--

USE `perf_5g`;

--
-- Final view structure for view `KpiLeadTimeEndurance`
--

/*!50001 DROP VIEW IF EXISTS `KpiLeadTimeEndurance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`5gadm_user`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `KpiLeadTimeEndurance` AS select `k`.`id` AS `id`,`k`.`testId` AS `testId`,`k`.`component` AS `component`,`k`.`cellGroupInstance` AS `cellGroupInstance`,`k`.`name` AS `name`,`k`.`min` AS `min`,`k`.`avg` AS `avg`,`k`.`95p` AS `95p`,`k`.`max` AS `max`,`k`.`createdDateTime` AS `createdDateTime`,`k`.`lastUpdateDateTime` AS `lastUpdateDateTime` from `KpiLeadTime` `k` where `k`.`testId` in (select `t`.`id` from `Test` `t` where ((`t`.`testType` = 'Endurance') and (`t`.`createdDateTime` > subtime(`k`.`createdDateTime`,'00:05:00')) and (`t`.`configKey` = 'SA_LA_HARQ_REF'))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `KpiLeadTimeNotEndurance`
--

/*!50001 DROP VIEW IF EXISTS `KpiLeadTimeNotEndurance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`5gadm_user`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `KpiLeadTimeNotEndurance` AS select `KpiLeadTime`.`id` AS `id`,`KpiLeadTime`.`testId` AS `testId`,`KpiLeadTime`.`component` AS `component`,`KpiLeadTime`.`cellGroupInstance` AS `cellGroupInstance`,`KpiLeadTime`.`name` AS `name`,`KpiLeadTime`.`min` AS `min`,`KpiLeadTime`.`avg` AS `avg`,`KpiLeadTime`.`95p` AS `95p`,`KpiLeadTime`.`max` AS `max`,`KpiLeadTime`.`nbSlots` AS `nbSlots`,`KpiLeadTime`.`createdDateTime` AS `createdDateTime`,`KpiLeadTime`.`lastUpdateDateTime` AS `lastUpdateDateTime` from `KpiLeadTime` where `KpiLeadTime`.`testId` in (select `t`.`id` from `Test` `t` where (`t`.`testType` <> 'Endurance')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `KpiMiddlewareNotEndurance`
--

/*!50001 DROP VIEW IF EXISTS `KpiMiddlewareNotEndurance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`5gadm_user`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `KpiMiddlewareNotEndurance` AS select `KpiMiddleware`.`id` AS `id`,`KpiMiddleware`.`testId` AS `testId`,`KpiMiddleware`.`component` AS `component`,`KpiMiddleware`.`cellGroupInstance` AS `cellGroupInstance`,`KpiMiddleware`.`name` AS `name`,`KpiMiddleware`.`min` AS `min`,`KpiMiddleware`.`avg` AS `avg`,`KpiMiddleware`.`95p` AS `95p`,`KpiMiddleware`.`max` AS `max`,`KpiMiddleware`.`createdDateTime` AS `createdDateTime`,`KpiMiddleware`.`lastUpdaateDateTime` AS `lastUpdaateDateTime` from `KpiMiddleware` where `KpiMiddleware`.`testId` in (select `t`.`id` from `Test` `t` where (`t`.`testType` <> 'Endurance')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `KpiProcTimePerEOEndurance`
--

/*!50001 DROP VIEW IF EXISTS `KpiProcTimePerEOEndurance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`5gadm_user`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `KpiProcTimePerEOEndurance` AS select `k`.`id` AS `id`,`k`.`testId` AS `testId`,`k`.`component` AS `component`,`k`.`cellGroupInstance` AS `cellGroupInstance`,`k`.`ventilated` AS `ventilated`,`k`.`coreId` AS `coreId`,`k`.`eoNameAndInstance` AS `eoNameAndInstance`,`k`.`isProbe` AS `isProbe`,`k`.`subComponent1` AS `subComponent1`,`k`.`subComponent2` AS `subComponent2`,`k`.`subComponent3` AS `subComponent3`,`k`.`subComponent4` AS `subComponent4`,`k`.`subComponent5` AS `subComponent5`,`k`.`min` AS `min`,`k`.`avg` AS `avg`,`k`.`95p` AS `95p`,`k`.`max` AS `max`,`k`.`nbSlots` AS `nbSlots`,`k`.`createdDateTime` AS `createdDateTime`,`k`.`lastUpdateDateTime` AS `lastUpdateDateTime` from `KpiProcTimePerEO` `k` where (`k`.`testId` in (select `t`.`id` from `Test` `t` where ((`t`.`testType` = 'Endurance') and (`t`.`createdDateTime` > subtime(`k`.`createdDateTime`,'00:05:00')) and (`t`.`configKey` = 'SA_LA_HARQ_REF'))) and (`k`.`ventilated` <> 'True') and (`k`.`subComponent3` in ('PRE_SCHEDULER','TD_SCHEDULER','FIFO_PROCESSING','POST_SCHEDULE','FD_PROCESSING')) and isnull(`k`.`subComponent4`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `KpiProcTimePerEONotEndurance`
--

/*!50001 DROP VIEW IF EXISTS `KpiProcTimePerEONotEndurance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`5gadm_user`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `KpiProcTimePerEONotEndurance` AS select `K`.`id` AS `id`,`K`.`testId` AS `testId`,`K`.`component` AS `component`,`K`.`cellGroupInstance` AS `cellGroupInstance`,`K`.`ventilated` AS `ventilated`,`K`.`coreId` AS `coreId`,`K`.`eoNameAndInstance` AS `eoNameAndInstance`,`K`.`isProbe` AS `isProbe`,`K`.`subComponent1` AS `subComponent1`,`K`.`subComponent2` AS `subComponent2`,`K`.`subComponent3` AS `subComponent3`,`K`.`subComponent4` AS `subComponent4`,`K`.`subComponent5` AS `subComponent5`,`K`.`min` AS `min`,`K`.`avg` AS `avg`,`K`.`95p` AS `95p`,`K`.`max` AS `max`,`K`.`nbSlots` AS `nbSlots`,`K`.`createdDateTime` AS `createdDateTime`,`K`.`lastUpdateDateTime` AS `lastUpdateDateTime` from `KpiProcTimePerEO` `K` where `K`.`testId` in (select `T`.`id` from `Test` `T` where (`T`.`testType` <> 'Endurance')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `KpiProcessingTimeEndurance`
--

/*!50001 DROP VIEW IF EXISTS `KpiProcessingTimeEndurance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`5gadm_user`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `KpiProcessingTimeEndurance` AS select `k`.`id` AS `id`,`k`.`testId` AS `testId`,`k`.`component` AS `component`,`k`.`cellGroupInstance` AS `cellGroupInstance`,`k`.`name` AS `name`,`k`.`min` AS `min`,`k`.`avg` AS `avg`,`k`.`95p` AS `95p`,`k`.`max` AS `max`,`k`.`createdDateTime` AS `createdDateTime`,`k`.`lastUpdateDateTime` AS `lastUpdateDateTime` from `KpiProcessingTime` `k` where `k`.`testId` in (select `t`.`id` from `Test` `t` where ((`t`.`testType` = 'Endurance') and (`t`.`createdDateTime` > subtime(`k`.`createdDateTime`,'00:05:00')) and (`t`.`configKey` = 'SA_LA_HARQ_REF'))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `KpiProcessingTimeNotEndurance`
--

/*!50001 DROP VIEW IF EXISTS `KpiProcessingTimeNotEndurance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`5gadm_user`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `KpiProcessingTimeNotEndurance` AS select `K`.`id` AS `id`,`K`.`testId` AS `testId`,`K`.`component` AS `component`,`K`.`cellGroupInstance` AS `cellGroupInstance`,`K`.`name` AS `name`,`K`.`min` AS `min`,`K`.`avg` AS `avg`,`K`.`95p` AS `95p`,`K`.`max` AS `max`,`K`.`nbSlots` AS `nbSlots`,`K`.`createdDateTime` AS `createdDateTime`,`K`.`lastUpdateDateTime` AS `lastUpdateDateTime` from `KpiProcessingTime` `K` where `K`.`testId` in (select `T`.`id` from `Test` `T` where (`T`.`testType` <> 'Endurance')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `KpiValuesEndurance`
--

/*!50001 DROP VIEW IF EXISTS `KpiValuesEndurance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`5gadm_user`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `KpiValuesEndurance` AS select `k`.`id` AS `id`,`k`.`testId` AS `testId`,`k`.`component` AS `component`,`k`.`cellGroupInstance` AS `cellGroupInstance`,`k`.`ventilated` AS `ventilated`,`k`.`subComponent1` AS `subComponent1`,`k`.`subComponent2` AS `subComponent2`,`k`.`min` AS `min`,`k`.`avg` AS `avg`,`k`.`95p` AS `95p`,`k`.`max` AS `max`,`k`.`createdDateTime` AS `createdDateTime`,`k`.`lastUpdateDateTime` AS `lastUpdateDateTime` from `KpiValues` `k` where `k`.`testId` in (select `t`.`id` from `Test` `t` where ((`t`.`testType` = 'Endurance') and (`t`.`createdDateTime` > subtime(`k`.`createdDateTime`,'00:05:00')) and (`t`.`configKey` = 'SA_LA_HARQ_REF'))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `KpiValuesNotEndurance`
--

/*!50001 DROP VIEW IF EXISTS `KpiValuesNotEndurance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`5gadm_user`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `KpiValuesNotEndurance` AS select `KpiValues`.`id` AS `id`,`KpiValues`.`testId` AS `testId`,`KpiValues`.`component` AS `component`,`KpiValues`.`cellGroupInstance` AS `cellGroupInstance`,`KpiValues`.`ventilated` AS `ventilated`,`KpiValues`.`subComponent1` AS `subComponent1`,`KpiValues`.`subComponent2` AS `subComponent2`,`KpiValues`.`min` AS `min`,`KpiValues`.`avg` AS `avg`,`KpiValues`.`95p` AS `95p`,`KpiValues`.`max` AS `max`,`KpiValues`.`nbSlots` AS `nbSlots`,`KpiValues`.`createdDateTime` AS `createdDateTime`,`KpiValues`.`lastUpdateDateTime` AS `lastUpdateDateTime` from `KpiValues` where `KpiValues`.`testId` in (select `T`.`id` from `Test` `T` where (`T`.`testType` <> 'Endurance')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-03-02 16:51:11
