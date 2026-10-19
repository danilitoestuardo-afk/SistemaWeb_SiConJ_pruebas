CREATE DATABASE  IF NOT EXISTS `catalogo_coleccionables` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `catalogo_coleccionables`;
-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: catalogo_coleccionables
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin_acceso`
--

DROP TABLE IF EXISTS `admin_acceso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_acceso` (
  `id_admin` int NOT NULL,
  `pin_hash` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `clave_hash` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `intentos_fallidos` int NOT NULL DEFAULT '0',
  `bloqueado_hasta` datetime DEFAULT NULL,
  PRIMARY KEY (`id_admin`),
  CONSTRAINT `chk_admin_unico` CHECK ((`id_admin` = 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_acceso`
--

LOCK TABLES `admin_acceso` WRITE;
/*!40000 ALTER TABLE `admin_acceso` DISABLE KEYS */;
INSERT INTO `admin_acceso` VALUES (1,'$2a$11$h8VW5pwjayukfh/VnKz/H.kgpN/AXTfgo6BvstMg5/.xmhnRwpG6m','$2a$11$jO.q.ouZeQdcP9E8kTdPh.O3gZ1bUjNsez0iTMcbcPftQCYx9XGd2',0,NULL);
/*!40000 ALTER TABLE `admin_acceso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `nombre_categoria` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `imagen_icon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre_categoria` (`nombre_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

LOCK TABLES `categoria` WRITE;
/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
INSERT INTO `categoria` VALUES (1,'Videojuegos','Videojuegos fÃ­sicos',NULL,'2026-10-16 16:30:47'),(2,'Tarjetas coleccionables','PokÃ©mon, Magic, Yu-Gi-Oh! y mÃ¡s',NULL,'2026-10-16 16:30:47'),(3,'Autos a escala','Hot Wheels y die-cast',NULL,'2026-10-16 16:30:47'),(4,'Figuras y otros','Figuras de acciÃ³n y artÃ­culos variados',NULL,'2026-10-16 16:30:47');
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `clave_hash` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `acepta_ofertas` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `correo` (`correo`),
  UNIQUE KEY `clave_hash` (`clave_hash`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES (1,'DANILO ESTUARDO MAZARIEGOS DEL CID','dmazariegosd4@miumg.edu.gt','984038E42402A14515178CEF642AED4251579AD6B8E5316B622C8582441738AD',1,'2026-10-16 23:38:28');
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `condicion`
--

DROP TABLE IF EXISTS `condicion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `condicion` (
  `id_condicion` int NOT NULL AUTO_INCREMENT,
  `nombre_condicion` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `escala` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_condicion`),
  UNIQUE KEY `nombre_condicion` (`nombre_condicion`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `condicion`
--

LOCK TABLES `condicion` WRITE;
/*!40000 ALTER TABLE `condicion` DISABLE KEYS */;
INSERT INTO `condicion` VALUES (1,'Nuevo sellado','Sin abrir, en su empaque original',NULL,'2026-10-16 16:30:47'),(2,'Como nuevo','Abierto, sin seÃ±ales de uso',NULL,'2026-10-16 16:30:47'),(3,'Usado buen estado','Uso normal, sin daÃ±os importantes',NULL,'2026-10-16 16:30:47'),(4,'Usado con detalles','Tiene detalles visibles (ver notas)',NULL,'2026-10-16 16:30:47');
/*!40000 ALTER TABLE `condicion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estado_disponibilidad`
--

DROP TABLE IF EXISTS `estado_disponibilidad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estado_disponibilidad` (
  `id_estado` int NOT NULL AUTO_INCREMENT,
  `nombre_estado` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_estado`),
  UNIQUE KEY `nombre_estado` (`nombre_estado`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estado_disponibilidad`
--

LOCK TABLES `estado_disponibilidad` WRITE;
/*!40000 ALTER TABLE `estado_disponibilidad` DISABLE KEYS */;
INSERT INTO `estado_disponibilidad` VALUES (1,'Disponible','Hay unidades para vender','2026-10-16 16:30:47'),(2,'Reservado','Pedida por un cliente, venta aÃºn no confirmada','2026-10-16 16:30:47'),(3,'Agotado','Vendida o sin existencias','2026-10-16 16:30:47');
/*!40000 ALTER TABLE `estado_disponibilidad` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fabricante`
--

DROP TABLE IF EXISTS `fabricante`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fabricante` (
  `id_fabricante` int NOT NULL AUTO_INCREMENT,
  `nombre_fabricante` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `web_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_fabricante`),
  UNIQUE KEY `nombre_fabricante` (`nombre_fabricante`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fabricante`
--

LOCK TABLES `fabricante` WRITE;
/*!40000 ALTER TABLE `fabricante` DISABLE KEYS */;
/*!40000 ALTER TABLE `fabricante` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `franquicia`
--

DROP TABLE IF EXISTS `franquicia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `franquicia` (
  `id_franquicia` int NOT NULL AUTO_INCREMENT,
  `nombre_franquicia` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pais_origen` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_franquicia`),
  UNIQUE KEY `nombre_franquicia` (`nombre_franquicia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `franquicia`
--

LOCK TABLES `franquicia` WRITE;
/*!40000 ALTER TABLE `franquicia` DISABLE KEYS */;
/*!40000 ALTER TABLE `franquicia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `imagen_adicional_inventario`
--

DROP TABLE IF EXISTS `imagen_adicional_inventario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `imagen_adicional_inventario` (
  `id_imagen_adicional` int NOT NULL AUTO_INCREMENT,
  `imagen_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fk_instancia` int NOT NULL,
  PRIMARY KEY (`id_imagen_adicional`),
  KEY `fk_img_instancia` (`fk_instancia`),
  CONSTRAINT `fk_img_instancia` FOREIGN KEY (`fk_instancia`) REFERENCES `instancia_inventario` (`id_instancia`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `imagen_adicional_inventario`
--

LOCK TABLES `imagen_adicional_inventario` WRITE;
/*!40000 ALTER TABLE `imagen_adicional_inventario` DISABLE KEYS */;
/*!40000 ALTER TABLE `imagen_adicional_inventario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `imagen_archivo`
--

DROP TABLE IF EXISTS `imagen_archivo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `imagen_archivo` (
  `id_imagen` int NOT NULL AUTO_INCREMENT,
  `contenido` mediumblob NOT NULL,
  `tipo_mime` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_imagen`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `imagen_archivo`
--

LOCK TABLES `imagen_archivo` WRITE;
/*!40000 ALTER TABLE `imagen_archivo` DISABLE KEYS */;
INSERT INTO `imagen_archivo` VALUES (1,_binary 'ÿ\Øÿ\à\0JFIF\0\0\0\0\0\0ÿ\Û\0„\0		\n\n	\r\r\r \"\" $(4,$&1\'-=-157:::#+?D?8C49:7\n\n\n\r\r\Z\Z7%%77777777777777777777777777777777777777777777777777ÿÀ\0#m\0ÿ\Ä\0\0\0\0\0\0\0\0\0\0\0\0\0\0ÿ\Ä\0M\0\0\0!1AQ\"aq2‘¡±Á#BR\Ñ3br²ğ$c‚’¢\Â\á%4CSsñDd\ÒT£³\Ó5ÿ\Ä\0\0\0\0\0\0\0\0\0\0\0\0ÿ\Ä\0;\0\0\0\0!1\"AQq2a‘¡±Áğ#3B\ÑRbr\áñ$C¢\Â\Òÿ\Ú\0\0\0?\0\î(\0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ <¸@.|±·\Öx÷¬\ål#\Ë,£\'ÁEõ‘\Z®yk©\Ì\ÑS&Qus¾\ãmæ¹¥\Ú?\é‰uG«(¾¦gs²ç–¶\épğhªŠ\'\Å\ä5\Î-\'\ç\Õuiµ’“éŸ™œ\ëKt_C p \è\á\Ä/F2\É\Íç‚ª°. \0€ \0€ \0€ \0€ \0€ \0€ \0€ Ë ÀqP\Ú\\‚›\ê\"g…Œµ5G–]W\'\äP}s>\ãIó\\\Ò\í/…d\ÑPü\Ê.¬ú 5r\Ï_cøv.¨Š):Y\\{\Ï\'\Ûe\Ï+\ì—\Ä\Í\"¼ˆx¬›\É`€!!J ôq\nw[ \Ìh\í©ÿ\0\é™k(\ä’9`-—4|mÀ¯z‰¼©/3Ï”WS‰Ê¨öóhi\0Ëˆ\Ì@\à¨÷\×\Õ\êŠtü\Ì\í\'k\Ü6§›Í–ùYUû\â3´}¯B\à^\Z\á\Ô\ÆôÁ‘£\í7gg\0I,Ğ¸ñ\à{“¤u¯C5Iµ¸\rg\êq8?¶K>vQ‚z‘•†®šqxj\"~\ËÁPNJ·BE\Ğ =@\0@\0@\0@\0@\0@òVA›²\â]{Ö“o;pöª\Êq,²„Ÿ¬¾>KzÊ£\æYU&Ruq>£=\ëš}¡ş”h¨õe\ÕJï½—\ÉsOYl¼ğh©Š)9\Îw¬\âVr—,ºŠ\\*’\0 =\Í`»œ\0ñ6R¢\Ø,\'\Æğ\Êpw•‘\\q»¸]k=’\á.\Ú\á,6`©—÷cü\×Lt|´U·ä‹¼3i°¼Iû¸j7rÿ\0Ó˜d\'Ë‘U³ClVV\å{Ä¶–\Æc¢\å\Æ•‘\Ä\évSMbw‘>;y· ñVŸ¡Á¨ğ\ÍHù\Ö@ü\Ç7\ê:/w¡k©\ä•&%t\â\nXZ\é,M¯m´iR–)9ª\Öd^R\áT\îƒ{(-\Ó^ÿ\0\ì\×\Ùúg\ÜK®2z\Ü2–G†\Å<¬.\Ü\Í6w•Â§ğ\Zi<G`œe\æz\ì¥º\Å;O˜²\Æ}“ğÈ‚˜µG\Æñ\ÈBâ·²m[\Çr˜I—”›c´T:2¶¥ r=à¸§£º<Ä¶\İj¸\Ü6@üq\Øü;®K”0Ñ¡\íz3aWB\ßş…PŒ³=G\Ún=·®–oòQ‘\Ôf\é6·«¶\ë†ç““$\å8k)¦ıUDOı×‚¤’¸7\à€ @xü $€ \0€ \0€ \0€ ‚X-Y\'°u¾‹\Æ\×T\í§\à)…\Äh ‹\äk\Ü\à\Ñ\âQ&øY*\Ú\\˜ª\í¦Á\è]–¢¾,ß…óğ[×¦º|D§}[xL\ÆK·Ò†‚º¨ò´yA]³\çı\Í#X\Â\Éü1b\ÎM§\Ú\Z)pªzP~ô\Ï\ÌG³E¬t5.[f\Ñ\Ñ\ŞùI}Ánù6‚¬ÿ\0I\Å\Ì±~K¢4U†&±\ìù=\å2½>4\ÍSWPOoeu\\¼–	p\ÓU´\å÷fN›eŸk\nF\ÖB­\Ü\Ë\Ì\ÎZ\í$8yüL„;/&£<1ø\İ[ºEkÖ#cñ}•F\ç>&L\Ûzñ‹9¾)\Ò\×\Âm^›S\àš\Ãıù’À±Y©\ÌtX”±º1İŠs\İq\è\Ò9ù®]F™[(\í$r_L´ó\ÆsÁ²¼|2¥\İ»^\Ó\Ö\ë\Ô\ìùa4r\êWùóji\Ğb4\á¹C*m8\\\Ü/¥“I\'ò0„¶6İ‡\Ù\áLö\ÖU\Õrû£ [ô÷pù³‚\ÍG{œp‹¼[À©qúg\ÔI=9c¤š\"ş\ë\Ü¶u$ù-k¶\×SŠ\ä˜J\Ç[H\Õ\ã8n`¤ª§¨¨\Î\İ\ÃbÔ´\ß\à,©¤Š\äÈ¢S\İ\ny£dÑº@CÁp<\Âö\ç\ÓHöb‘¹b›?…\Ô>G¶\Û#ö°\Ø<[N–:¯\n½m±Lvtg9ô¹n\Útk\ÎØ¶5ÎóHj]EÀn\Ò|ôQ-l\ÛN\'}\Zj\åWS^Y\çç‚Œ\Ûš7‰\Ë%19’4\rA\Ô«Z©7¾Ÿ\á4\í¸\åò–Vüıd\Û3f™\İ\È”4µ¾±\"\à,gl(ª\ìúÿ\0Õ…ó1\r\Ùú©i„ôô’:2\\Wjx\è:,¤ª\ÎÁ-*–:*º\Z\Ú+\"©„€†Š\Ë\áfVh\î®)\ÉÅˆ\×S:\Ñ\Ï+-\àG\ÉGw\æ\Ç;Œ¢ğ\Ö\æ^l±\Êbu\äÛ“ùª¸\ÉÉ¥\í\'`“fo‹ı\n®Z\äu|Ì„}£\Å#­<s@m÷lG\ÇUeb^Ep\å\æNn\Ò(\è\Ò>¢XÉ±\Ğq\é\Ô-–\Ø*º\Ó\Ûs£`½>5†SWQÉÙ™„ññ\Ä\ß\é\äÉ©$ \0€ \0€ \0€N\"rTß«Ì¯´vœYÛ§Ya5\\q\Èö´u%pd\éN\\\Z†3µ¯¨¬v„\Ê[¤µ#[~\Ë|W},)Mg<\"\Õ\é¥tœbğ—/\Ğ\È\áx1©§\Í;\'šÿ\0zgq]ÎFvŠ‰\ä\ßOfu\åË­û\å~l¨‘\í,lx\å¹Z×¦Ÿ÷\Èé£µ4ºhô\ÕQ¥Ù¨\0\Ù\äwƒ@t*£.Üºk1ŠFF›\Ã\ã?¨=^n˜HÁö†®oy}‘š2EP\Û(\Ë2•“Ÿ\Ä\ÈUVRS\ßSyE\Îyl:©I³³%òSšº–(c”\Ê\Ò\É=B\Îö}9[Š²‹ot½ğ\Üş_™\Òt\Ã5\Ì~xm¥¸“\Ò\İy*´tUM\Î\í/§ùX¤uRM‰\Í|gÕ¸9‡T\éÁ6W:\à¦\Ö\ÌÀm^\r\rU;ªak£c\Ï~\Â\Ù\\88{TI4òz:J¾·EŸB\çgk};fñ×¨‡\ì¦X\æı£U\åk(P³+†d³\ã.Q›¥\ÒB:…:O\Ì\î\Ş\'6\ÛH›Mµù^\Ö>´\Ä\ç±\Ã\ï\Ş\Í#\Ú\×ibÿ\0‡SòOñu1n=HÀ\í\Ô\ÉE$´8[·r‚[,\â\ÓøGD²\è¹(­\ÙM-\Ã/ƒ/…a\Ì\Âö’I_F÷1\Ñ5ñº{¸9ÎŒ\é˜ó¾\åybU\Ë÷“¾I\ãmŒl”3\áÔ¦Š}1•2=Ì¥q•\á¤\Ü7A«u\Z‹J\å\Ñb”™hu6c\İ\\\Â\ç1ÀµÃ‹\\2‘\æ\ê\ÃYL\Ö\Ì\×ttª:¿K ŠA©©\Ã\ïı¦\å|\İ\ë¦Æ—«;\é\ÇJo\ÊKÿ\0È¼y¤¾G\Ì!a\Ü\Ô\æ\'N\×Ü¹3óùY*¢¢£—\â\ï\îA\ÙP—¸\Ù\äa\çpöfù¬\ìyf½\ëpÏû<sŸ\è‚QÉ‘Mı\×Xü<¥\áÉº}s\èù\É}\ÑJ¢:º˜Ù ehu‡0ö\Û\æª\æòıÿ\03(\×¿Xş(¨\èb•‘¶F‰\"·€uµ\Ù%qÁ\Ñ(\åıÿ\0,–uXEõõ¦c\åc\Ã\İ\Ğ\åu\ÇÁV-¸\àˆA9\'\ë\Çş\Íji))jDt0³w˜–\Ì\Ç\\<r\ê.»t÷u\ågƒ\Æ\í$¨qma2…q\n:‰ ¨&¢\è\Ú¥µä¹®Ôº­\Ã[3\çmÕª\'5³%Q‡VE†Çˆ\Ê\Ù\Ê\ZGhO†¡[¾‡x£\äü\Ë\×|{\Î\ïİ˜|K+ kfh¹ x\ÑĞ³±\Ó.¥ğòuN\Âq\rşÌ¾”ºî¤¬smÑ¯‹Ê™¬|-XpW4\0€ \0€ \0€ ‚X\Ú\ê\ÖĞ˜#²‡5\Ã\Íy¡úZ=>ÏŠ’iœ\Ïjq§>Y\ã\Ì2‹0\Å\Ç@¹\è§2Hô¬}}<ğb¶VJj\Z¸_Y3Z\çpÏ¯©÷¯¦\ÑWx\æ÷||‘ó½µmóŠ\Ò\é“q8ó|o\r\ÅiYM\å¦s\áqn«K\Ú\ÎOK¦º]	G\ã\ã\ç¾?2F\Ò1´¦ZX3½³67²We°:ƒ +\É#Ö§²­Šx\Êo\×e\ä!\Æ\ë”eŠ2*·N!¤İÓ¡\â£+|³TbÛ—öumùo’n\Æf›Àğ!mIŒ²\ÜYn?2¡µ\Ò^Ÿ\Ö|]\n_\\¿Ğ´\Ææ˜…\\S\ÊrÍ”F	$¡°ö]W8\ÉÕ¦ªºeÒ¹yûH°²\"\íé»œø›6\×=‡\ä¡M/±ÔªqŒR\áO?Mÿ\0\É8\ë\ØwM•û¸\éšç¿†º\ß\ãe0–\\Q†¦\î«\æ¼\Úı?\í”\ÛZ] \å\î¿\Ï\ì·ŸV\Ø;{¥\ß÷¾x2xEcj*\ßYB\à{\Ö1¼‹–ğ7\é\Â\ëu\Èñ\íŸÿ\00|\çõf\Û+QNX\áÜ‘¼<\n§\àŒ\Ü\ZœyF›„1\Ô;K4\'F\Ô\Æoû\Ìÿ\0EÍª†kö=mNV/5ûüÿ\0kˆ\ÚF¥qW\ášg,·M\Z7i\Øo§bfI]e2B\Æ\İıÑ˜~|W\Ò\é-j©U\ÆN8E7ƒŸ\à\Ô\Ğ\Ò\íûÚš?´’9\Ë9\Ò4_+\à\àF¡Eu¾ó+\Ï÷÷Â¸6Lc´J\nŠh\á|\ÒE Go29œû¤s^0|\îQ<¶Ì®\Ì!˜X“•\Ó	]4’[yœñ°Kn\Â\É\×L“\Ø×»J†IGX2¶£}º6\â\æØŸ…—57Ë¼Ø›R/¶*°K‚a¹ÍŒ5/\×?uÀılš‹\Z³÷\æmF]RK\Ñ?ªfb!½ \Ü÷©\å€ù°\Ø.dò±\î¾\Çt§\ÑoW¤¢şü“t¥Ô­©¾»¸g\ÃcğTr\ÌsòD(¥c¯\ç(ı÷EY›¼ŠHy“4B\İ\Ìd³•\î¿R°›„\Ô\ßû_\ÛfQ‰\íuK\ä:oh™(·\âaâ¹¤\Ş=?#·¡%³Rk\èË™\àhû ,Û¼7\Ûg…e‡Áj¬mu{‚…s\æ{$4\Ì\Ï&v¸7¨sl~I/\n\Â5©E4¦ö\Ç\ä\Í;j©\Ú\Ùh\åc2\Ã+ÿ\0u\Ü\É_O…/›<\ÎÚœ\çNøj-£\r„G/¦Ú‰¡.o8º\×\0ø]k|c-™óöS\ÅuG(\ÙYV#\Ã\İG?ôŠQ©¸es\Zl\è	Ş¸.©\átùv£H—Lª\Ø\Óö£––†j˜›z7=­d—\æu·\Ãâº´wõ\â2\ä\é\Ó_\Ş4Ÿ&w°z\Ã/ŠP¸\é$,™‚ü\Ø\í~akoÄ™\Üù;ú±`€ \0€ \0€ \0x 4~\Ô}\n†Kz²¸{\Â\æ\Ô\Ç1G¡\Ù\Ò\Ä\Ú9N5ye¤§oŞ“1\\>k=5y‘\éY5¤ÿ\0µ7ö[ø‹·0e\Ú\Ã\åš\Ë\×Ö¤šÇ£G•\Øv¹FR\Îı\ä_\ÜØ°\ìRb,®Ü¿Éºƒğ\\Sµ\Ë9óH÷\ê\ÒW„¿¶S\Ç\×/Ü•Æ¡ÁĞ‡G÷kšM\Í\Ú4¹÷¥’m¼y\àhª\Ä!Õ»]K\î\ÊôS¾jƒI};œ|]¦ªz[ù™(.ˆÿ\0\Ã‘|\'\È\ÊL\ßb`2e·\Ş\ár9>œ|\Ê(¯\âzÿ\0\Ûú–”Ns¨°û¸ºÒ†ÜV*\Ó{³2\Åûÿ\0’¿\ë\".i\n±o\ï*cs|¦¶õıJUnd”˜‘i¸\å\àÕ¢°\âelóU­ygğH¹±•´ù\ÎQ$9A=T%±¬¦¡bO\Í~Fb£\Ã<mnl\ï.½¬E´]\ny<-^—£^yüÙ·†Z6g\æqµ±¬c#\ÑñúI›meh\áø»ª\'¼±\èÁõi¢ıµ¸/-#3P\íY‡†º\'–IMP\Ù\à/nFş\Z¯^«3\áóg#\Ê{\Z~\Ê\í-<u¬¤u\ç\Ó%\Ì\\7A\Ö\ä\çnºœ\ã\r\Z\ÂŞ­Œ¦\ĞlM$³\à\í0W_3X^wn\ê,x)“Rx‘‚\É\Í\êiñœ\ÄX\Û\ËKTöİ¢7_8\é\Ğù. \à÷(\â\ÑkUˆ\Ö\âSƒ]<’¹€†‡J\ÔaK\"R\Ê\Ëez	e¦;3š\Ñ\Äf\Ë\íZ\êjWC\ä\ßG¬Zkz\ëƒ+;$E…•‹\\İ®<J\àz;—±\Ô\Ó\ÍbQüˆ¶f4±µRn\Ër‘¥‰\Ô*½5ñ[¢R÷\ã\Í\í\Úy¤õ\êXH{^`-akıR¯P¼‹\ÂZœK\×ñ%\Ó:)T\ç\ÆòØŒb>Ä›ğóPªµ\Ï\r–§J¨—Kó^ùF\Ä\í¢6)L,\Ëfğw0-ñNQm4uÑ¢‚‹Qyüw-Û\å¶X»ı\ÓÇ7ÿ\0E.\ÙcƒYi\ãœgöö,ñZª<NŠF°97¹‡8¿\é\ÍZt\Ù\ÏY\\¥D£\r\Ókğÿ\0³%±¥Ÿ†F1\Ò5\Çy¹‹ñ[Ø³4ü;Kfq\\\Ëjg`¸^(úB}\äS1\Ñ70\Ò>÷ÿ\0<”I¾QË«®ì™¥cğOV†¢’‘\æH¥n °¹Z˜¥gQ\Ï\nW[œQm\Ù%W£mõ	³jc–\"\æ>-mJ\Øßƒ\é¨š\Ï\"Ğ‰\åd’¢\0@\0@\0@j=¦2û?\í|•->\Ë\ë\Âvh^-ú’@$Å©ƒ\İi¡ö„úh³\Ûv[\íyec\ÇP~!v\ë?´\á\ìI¥=\âş\Ì\Èa\í\É.œªşl^c\ã\è}„Zr’ÿ\0wÿ\0©‘fä¾ŸÑ¬\Ùln´Z.-§Wú—8;.\È}\r;˜B\n\Ñl™Â¢Ü¢ü±\ÅT\Çú])?z–\Ê%\Ã)›bıcú¢•²aô¤qm@5¤¾&a§\ÏsòW•‚\ZyC4\rªi\Ò?5^Y¶SÇªüpS­hl¨h° <BE\ïºˆ¥M\Ïò=¥óá·ˆ\ÌÆ°9ñ\Üwš-u¥SQ\ÎL5\Úy\ßÒ¡\Î\æÕ³\Ô\ÏÃ«M=²´<¹Ÿº\íGÀ­\ÙÁ,½\no•Ÿ\ÌÜ†­?3ƒ”jûT\ÛUQ¸r’3ş0­\å÷ü\í;ÿ\0\ãK\İ~h\Î©^aš1[eDq-—\Ä)€»\Í;\Ï7_¢\ëª\\3–Í¤|õLLakõ‰\ÜAÛ£WN1\"²][£bÃ¶\ç\Ãbl1\ÔGS}V\Õfhğp\ÔûV³–•\ïı\Ñu\'Œ˜\î\Ù\â´‡-=<g\Ö\İ\æ.#\Ìğ\\w¸\Éc(6\Ú\ÆLRK”–Ü­ae’pFN¸º)¯v\Æ÷ó¾R¶‘õ-C+Æcı «õ\ÇÔ“\ĞıupFQÁ³x”4qTF÷	,D€´‘`t±\"\ácl[\à´d’Á³Ç‰RL>Õ´’\Ú\ï¦a¿´\Î\ã/R½\â\ê\ä³Ç™‡M‚\ï)\é\ØÊ¸e\ÍE ´\èsr\éeX§\Õ\â)d¼jK\ÌÖ˜\ç°÷e#¦ª\î1\Ç‘ºi\ìÊšH\ãsX\ã©\ë\ÅQ\Â/vŠ+\'’{¾V?xÇ½²¼\Ób«8\í°rr““\ä\Ë`›?>-+%y÷¹w—Š\çoU÷\Äğ³Áğ¬:†!<¤±‘w›™R5÷®^ı©b\Ë)dû¯\Ü\ã9R0\íª\Â\êo¤Uq\ê:^\ßU\ê^²·!\ï¹õ	µ8o\áq\Ë\éğ²Æ§˜ \\­\0@\0@\0@­v†\Ì\Û)R\ïÀøø\Ú>«;Vbti^-G&\Ø\Å9\ëZèŸ{›vôY\ì¿2Xş°5\Ü-\Íu\ê—\Âyİ•,F\Åò\É{C%\Æ\çş\"7{À\Íke\íşO¯…¸œ¿\å\Å$_S³)N¿\Å\'\ÈQ//÷?Ô¹\Â\î\ÆS|Œ*H¯u¯\æV¤9¤ x½·ò²?3*×Š¼§ÿ\0ä· q8l\\ÿ\0¥6\Şõi|F:}\éXÿ\0W\ê^V»©×°ğ¢[£i\í\î¿A\\\İ1¼\Ê\ã£oc¥ú\è¦1{K\æR\éÅ©\Ã>_¡8\Éd\Ô\í9]Œº\Úf\Ğ\Û\à/¥²]±±­½ñş\r‡¯š²±²\Î\Ö\ç\İ÷xXµò<\íMj­7Fy“üÿ\0\èİ‡ªY\å\ã»´\ã\íi´û\íş0¯\ß\Ø\ë§ú÷_¡—^c*‹lY\îfPc\Ñ\âB\Ó\â\Õp—¹\Ëz\Ë>S‚)]L\Çeœµ­m\È°\'‚\ïŒs¿‘-`­,2F\ĞO¥0;†h\È\×\Úø1±œd½KGHöğ•\ŞÖ…›Á®	E_,:µ\ì>lW`®\Üb©¤º&ôû;}Sqe\í>\Õ\âtö\É$\İcÿ\0T\Â(è‰”§\íˆYô\Ôi\n0Š=*ç©—ñö’\á¥F\Í\á’øg·ùJ’Ÿ\ÃK\Êl½¤\í\n™û™öB\×7-± x\Æ-\Ğ(y\ÆJN‰\Åuud«\Úl“ƒŒ»!39\Û\ã÷zÁoÌ\îÍ“k÷ô*G´û6’`Œ7ğ\äò\ËÔ¿E\Éú•¿Jöv\æ\İ\Ñ\âp§\ê¤#\áu™8·\ĞôI°\ë-W\ï±\Ã\æ\ÕS#ù…ü8®\Î\Ò@bÁöš‹7®\à\Ğ\\\ã\ãu\Î\èÌº¥–D]‰ğ\ÌeN…\ârª6¶š¦b,)iÓ§¬,º!.…\Z»œ¾$s}¥£f\r‹IOO[^\ê\Ò6h½S\Ìs+W.¥Á¬_R\ÉõVP*°\Úy\Çü\èc—\Ş\Ñù,*X#&µ\0@\0@\0@m\ã\Şl¦\":EŸû¤¢¬¸5¡\â\Äp\É\Î\\Jò¹o\É4Gfµf›?\âÿ\0B¾5’RK²‚\\.–^…\Ñ\êŠùŠ\è\Ò\åŸ5‚\ï¨{ 2nqË«µ³MŠ\çZi5\É\ê¾Ù®2{>cøn\ÌÃ„Ûšª†\Ç¡‘’89\æöp\Ğ\r\å¥\Î\ÍùC¶”r\ãe~X$\ÖO†\ä«7Z\Ü\ê\ë\ë\ä“Ò¯Rj\í¹l”}_\æS\Ã\ášD™\Î\ÏN+\Í4±‘ ½¸‡U\Â\È]¥rBô\Êúÿ\0‚ş—l\nZØ¤1WöQ6;‹fµú\éôQ*\â\æök­®­p_3©5µ\ØSj\ß|ot¼;§İ­ıZ0‚M™Û­ºR‹o\Íşÿ\0o±\Ò@\Ú_G4\Â[”µÀw‡Š\Ã>…g9NNO–iõ;?,¦š º–<E\à\æ&û²\Ğ\î>Orİ¸\à\Í\ÎrŸSg˜U\ØN-]D7®–7FM\Îf’x‡šºQk©œ\ä\ÚM›»æ½±‘¥®W3K.›O\Ãm0°„ô{ˆ+@\í©ÿ\0*O\Ğ\É\Ü/-‚\×?\Ğ$ÿ\0µ ÷…v\ÚQ9\î\\œefi¤tYc¶g\Ê\0¿a\æ«¾w\Æ\îß›üM\\\Ôp›\ä\Ú)\Ë\ê!>\Î7\Ï]¡.¶­ö\Ø{—“k	\ìONP{>\r/¦}=K\êM²\Êÿ\0R\Ö \Úö^‚­ºúşg½¥·«\Â\ÌC¦ jGUF°u2ƒ\ëÿ\0uT#\Ø\Øg•±2&9\Î6\0€\Ï\rNˆ\Ë\Æ=[#aÀğª-N;J\Ö2’ o˜\æ\\\Ú\Â\ÂÃËòY·‘\İV*·).\Zü›p\Â`¥£d/1ú\ìqwv\ç\Ì\Û\Ûeh¬,3Í²oÁ€\ËIDö2:‡4\ÏS)wv6Z\á§N\ë€ş.\n\Ò\Î61v.œ™büu$”X\\P³S1\Íq‘\Í\Ìr¶£ˆ\Ö9q—IÈ¦\ë±\×åŸ\ïÌ·v‡×¼Ë…C do\ÉQqû=l\Şyœyè“›‚r;\Ô\á·b.h©0*Šù\"t5&(\r\rÄ÷®nú\Ú\×Uœ?‘Š³º„l»|úy\ZŒŠ¶­\ÌÁ\ã©\ÉœI#Iı\ÔJ\n/¥\Ô\Ñt·1Ø¦\ÇWañ¥Š D\ËÀ\âµVK\Í1sø[5aŒ‹+ü\áÃ˜X\Ë%lŠ‹\Ø\Ä8Y°¶Š\Æg×›!\İÁ©ø)aoøU!ğ0gUÀ@\0@\0@‹Ú–6o`\âid·R¡ğ^§‰£€V:\Ó\Ò?ú\Ï\ÉeKÄ‘\éjc%ê™˜xl‘º7z®t!z\Øò>Mz›>\Ë`”O£\Û\ÃöF/[\î\Ş\ëvº`°qJ\ÉJÆŸ©µÃ€\áş4F\'J\Z\ß:Ár\Ê\Éd\ì©,¼N§fè¤–	©\äc ’Há¹³†€’H\0\ë\ÕRW8¿ÁÛ¥\Ğ_|:«Ş­¥ù—˜%nUš–šŸp\é¤:\Ù\ë?øNœŠÏ­\Ëtòiv’\ê?©/¿\äg%§kƒY\r$O¦h°ˆÙ¢\à\Ü\éù&}XI¿‡‚¬¥†³\ìad.\ëf†’@\çÔ«<ôd\Ê\ï:w´X\Æ;„\Ú\ÅÄ•/‘­œpEÁY<´Lù(5fj\r¢ˆô ÿ\0ˆ- tUı)}‚òòX·\Ä\Æj\'\Ø\Éi•ó0»\Ì\ãT¸}=\Ã\0¼v@MÈ¿k\ÃUô]§Ù±\î%*V\ë±\à[t\ìM¾C+ Z&\Î\Ò\Óp÷zi\Õ|\åTY©m\×\çŒ²¶ò\Ùsµ\ÔX\\ø|\Å\Îı6ö‰‰\0–x´ı\ĞH]4A\ÆOÿ\0N\ê?ø\Õ\î\'§ †–=Óª\"«¼sY\ÂFş \á ş}ºJ‹Yó;kµO\á0\Ïq8¬\Í\Ó7Z™!\ÙLJh\ã|µu\Ş9,q\â6\á—\ÅU\Å=Í¡5•É¸\à8@†ó¶–h\'€8Ò˜.\È\İ`G-\Z\Ør¾š*$²]\ëŸN%²üÿ\0Á§b;­š|Î¦¤JJ‰\Ë\'\×ö\à!¶\rÓ­Ö¸X<ù¥3\'®“\Z\Ä\Ü÷9ò²Gˆuœ\íE¾ğ°\0\ßN\n©\ïƒ8¼5\È\Ùú‰°\à1–8µ”\Ù5sC\ä:5—o•úh«Œ\ìQÖ§\'ÿ\0…|\"Waõ±WarÃ„Œs³§¸\á\Ìt>\\\Â\Æ\×\àj_½\Ê\×túºfüKŒyü\Ñw³Ş]ŠE»£ƒ-#ys\\I°>¯5Mj\Åf]«cT,\êÚˆ¤¨q•Ñ´\ä\Zó^|!cø<š*¶1ğdº\Ãe.|¥”7WG Œ\èE®‡?j\Ò¶]Y:cm\Úi¼¶s½¼\Ã\ÛCŠC$,-¦«‹?t«}‡E\ê\×%%±\îWgx²a\Í.£‰CC\ëıšnL= }Ö±¾\æ\ÍeW-#0µ*\0@\0@\0@[bQ\ïpú˜ÿ\0N¡ğLyG\Íøƒ¾Æ™\İÀ¬kø^Å½r¿3óF\Ó}l½†·>><fŠRa\Ôm–¶¢8Xtiy¶c\Ğ-ş(s‹VìŒ…^\Ó\ÒVE[EN\â\èLÚ¨\ß\İs´¸ÈW5µ\Î0\ëG£\ÙĞšŠ\ág\r£[\ÂğK{\å¥`‘ŒqI»a×…\ìI\á\È.\Ó\×\âo>şÓ†š}\Ûñ5¶\Û$³Á²`!C‹0WQµŒÉ¾‰\á\ì&Öµô7×˜ZB¥Ô™É­\í(j4\î	4\ÛY7Ü¢\Ö\"üµU8JN¥o¥\ÇQ£œ\İ\rÆ¶ğVSğ¸–PI\ä­+.56mş\n‰‰¬¢ ²\rŠnõ®¤\ÎK|“\'E™5ı®vZxÿ\0a^\']+ù3ú;‹h¼†\Ë`£]Ş¥ğ³Á>Å´%ˆ§ó1²9\É\Ãh1šJ\ìAR¿\Ò#–x\Ü\Ö\é\ç©â¾º­k¾şŒmƒÆ¿M\İU”dX\ÈiU(Ñ„‹ronœøVÑ®e.?#ŠnV%4;·T\É<\ï{…C\Z\ÇŸT`\à8\\\0/\à¾+´50¶ö«øJ\êl²n0ô5La”Õ³Ùˆ\Ğ\Â\êg\É÷\îp½œxY¦\ã\Åzr»®¸E.\íij\î\â\Şv{£\Zpúr;\Ø\Ön}ù¿şk\Î\Å\Óóûh)p\ÜA´”ø†;Njc;¶·®\Ş4›€K˜2I\×B¤”Ñ\Å1±D\Èğ/\Ò02—ƒ‹K,4kœ.xAeerŸ9\Æ\á\êôù}<\Í^¶*z·ºzœrˆ}K*\r¼\0\İø­T\\Vt\Ö1¿¡,.x0\é\è\ÛCB ™¡’±\Ô\ÕcÀ7³›»\ïª8·\äRpr\ß•qj\Ú:ñ§\Ú<4¶<±S\ÃCQlu\É6h\Ş*Wa	\å\í\ÈÀe¡£¯iı5­“¹ \Ï\ŞO½¹ñ)8õGµµ©CÄ¸\İ}\r\î£b‡‡‰\Z÷÷1\ÃF¢\ÛÊ”‘·\Ö\Ú\ë/°Í›Ág¡ª™\Âs \Ì\ì‚\ŞĞŠqß¥¤o\ÎK1\Ù{:JJxv†aò¶H]Pø\Â\à\ëmVW%(´÷8õ*R®Q—8É®v›\ér²\Û\æ5€\ß+n7\ÂOfYšº}\r\"Œ\ÕÀ·‘£\âº¤}‚ÿ\0Á\ÚÀX§î…•\Âi>Q‘[\0€ \0€ \0€ !3sDöõi%r|×Œ7#^\Ë~®k{—<~#\×ÿ\0Kù¯ğ[c5\ÅI!‘Ñ—»W0\Ø\Ú\ËÚŸ\Ê\Ñ\ŞI?,“À*\ê+%c*\å2\îFV_\Ç\æ|WN9m1lTw™¹l\ÕT^3‡2 E3\ßœma›™¿+\é\íZ\êãŠ’F}R2•ø\æ#†\ã5¥‚˜\äòDK\\N¤‚š\é`¹©\Ó+\ãœ\îe©\Ïû¸ö6]œ\ÇjkjE/LF—E$7\Èûq\Zğpùy.{ôî¥”^M\à\Ùw¥\İ=’r-i 1Áq\ã;y\Ç%i\ŞNç“–\Â÷\è¢?¯+c	&4Ú©E,m~¾´‘Oƒ}\ËZ£\'\"Úšmª¨\ÊKŸ#/Bü\Ô\×t»\×n\ë[Ø©bñqƒ?	Uº\èyª±ö$•É­m»²\Ñ0ø˜HòF…ü™ı°:/²pQ®ÖŒÿ\0kä·¯\àú˜\Ù\Éó\Í\âa\Õ1O;ö\î²İ¢å‡¨ºötÚ‡Dú°r\İJ¶=-™¶b­¬®¯©§’}\ÄtYò¿»\Ş£PŠf¦Z„óÁJôµG’ó-´¾ˆ\Ú\ÆE˜o\Z\ÖÀú“\ì^R\ÒgĞÑ¦­N¥Y\\zRúgş\ÍT8õ$õ]½&¨“]\ÕI(¨	°\äG\Í÷¥\ç3õw7%N\Ï$•¦\'0´_ˆP\Ğ\Ã!#\Úb\Ê\Ût\n00\Å:º¹*wy\ÛDQˆÛ‘·­¸ŸXÁ\"•Ö¡õÜ¦\Òó{k¡\âT´\Ò6*ı±\Æ\ë°\Æ\ĞT\ËNa³E\ÙW\éÃ¼\n»µµ‚Š˜¢µX\Ş+5S¤cÛ‘\Ñ\ÏöŒpò<<Å”Fj>DºcŒ­—\Ä\ævIúEò\ËS,\Î4À»(cºh=«–÷´œv:tºj¿ˆ‚’O;nkû`Úˆá¤‰\ï\É|a®¸³ùõ\åÁWL\Ş\Ì\ßQ^šqw\Ñ\ÜZòÙ´š_<,)¹ñJ6½Qñ…\Õ.\ë\ìZŒ®wÀ\Ûè³§\àDË’ıj@@\0@\0@\á@|á´±\î\ê+\Út,¨wñ®uñ¾s¿bÆµ°\Õ\Ò\î] l™7\ê<Wµ´«K\Ï\Ê\ÍJ»\å/,\à\Ç\àµqQ\ŞIsY ´e®øT¼F÷\×)/\n6\n<E¸\å\\Xki\ØÖ¼¸\ïf\ÔF\Ğ	.°\ã W·_,(•\Óh\Ü\ìK«\ÅZ\êJŒ7”b5BIƒ\îùš\ÜÎö·w…õ¿EZq\Ñ\Öåƒ«¢UX«„:°\ÓúyıM\Ûyt¸<¡\×;\æZ\×\Ğzø-\íK¸—±\æÍ®õ´±¿N»\ì^=Á­b¢¶·3\ß#3\ãl\Z\0>\Ëğ]¸8o±\Z]S£Q\Ö\ÖQ_f°\Éi\ïQV\Ğ$µš:,zUq\éO,\ë\Õk?‹–R\ÂFvÁ­\Ğssnª»œ¯dx•EQ\Â\ê¦\Ñ^f­·¶xı\×|\Â.Qİ§şŸC(ƒ\Éx²{–Á\niO›¾K¢Ÿƒ\êcbñ+º†¦–)¥‹\ìYö½§\Ú\ÒEü§$s¦‹\ì™©ñ\\\Ú4Ñnm÷Ú«‘\'Ò²[Í‡D\ì>J\ïJ€H&İ˜3\İ\çK\æ\0q–q›\ê\é8»ù»:pc21¼I\ê\Åk¹Ô²Ê‚1lÁN\æ9Y.Œ(¦A\×\Z!\rH\âHŠ\"\â\Ëü•\0:Ù”U§a/»m \Ö\ë92\è¨ø^[`\Ö\Úú‹¢h—¹I\Ñ\Ì\Ò\\\ã`TõDƒ{\Ä=“PÀ\é§¦cZ¥\É`\Í\Ç\Åyò”üX=%\Z|\Â\ÉO\Ç\éŸ/ü5ı¥˜MC{œec#Î/w¼\æùú\ÅmG_ZO‚—U¦¯I\'D›Ì–3³LÏ\á¬\ëUñ\Ó.\å$}u‡€)[o\Ä\ï\â**ø”pğ]­\0€ \0€ \0€ <<:\í~¸.-o·üI\\\ßı\ÃÕ‹şJfª¢F\á\æ)\\Æ²},×´\\£ºl½µ\'zMğq²iñ’ûc\"“’\\(S°\Ò\Ïv\Ô\ÍÁ\ÌÓ»—\È\ÙR[O\'^™J\Ø:ñ·™¸\Òö&ˆ\ÑT\Ò\Îj¢s\Ìu\r#)lni\ÃŞ´L…¥\î\ìN/o2–!(¶,6£úWô6B\çÀ\çQ\å`´:Rgv‚ij\\\Z\æ+ğ/°\ÃˆRSµ¯ôh\ë#µ\İ}\ĞsI\âO®\æÛ¡£\Â\íZ!V¯XX\É\Ö#p s\Ñx\Ì@µlE“\Ë&{‡\ÚÍ·«e®r’9\Zñ6\\\Â\0nœ\Ör\ä\è«\á=yäˆ™³\Ä!G«eSxğj»®\Ùw\Ñ(\î\ÓF\Ïc$\Ãv4ø\àË“B5ú)ı\ãò]4\Ëù_\Ğç·“\æº	§Ã£|o¯Ãª.\Ù÷G5\Çƒ\É\Ãı¢­pZ\Í±­O^«¸¤§u=.1\r\É;–\0H¶`dm¼E–‰e\áM-‹OAŸsŸ%›ï²¿tóÁD\Óe\ì+‹UD\ï\\eˆ­(\í\Ã\Æ\Ö\ì–,ge(\Ã\ç39™\Äf2–ö½ºk\Åe5\ÑÉ£ ¤VvÁc±MRaó\Î\ëGp\0ö›\é\íQÁµt\å\ì\Èc\Û\àxy®¯£Àœ$k­\"´p^Ló\Ô\Ôd$ZÇš ó(\ÙA\'‡e‘uC©•–.Š5R;|r¸€¯°LO \Ó>*zQ\ì\ÙE\r|d‡\Ğ\Ú\Éa{ò–¼c\Ö\Äkæ¸­\Är±\Ïw³*®vw°k)<\ç\×~¦¿´øœ•u&\İ\ÛY—3ƒ3Z\Z>5\ÑRx\Ë8µ—.\îGq\ëşv%›İ­Á£<\ê\Ùz¼ö‹gv>³\ÃÅ¨¢ñmıú¥kÀˆ.U\È\0€ \0€ \0€ <(Ÿ6\â-\Ş\Ñ\ã1ÛŒ\Ï#Û¯\ÕsKi¥O4ı«\ÉSp8cm{Ÿ,\Ó%„4U\İE\ìeGŸªy±›g´—Š\îUQ‡÷I{\Ã|\Í ‹kªg34rp«1\Ûşcs\Ğ`ô\Ó2¡†¥µp°:vT5\Äj\Ñ\Ñ\Í7Z®	ïº¡\æ\ÚE\Õ^\Î\Ôm\ÑS\Ï]\ë\r¦d¬d\ĞUd•\î%£QmÁ\àT9\â8E,²Q·1xÁƒ\Äğšj\\K\Ã\ë\\\ê\È!\Éª`.Ë”Ø“Àù¯SI.º÷<¾Ğ¾\Ë&¤ı0nŸJ\êv¾WGM ˆoI%§(\Ì.x‹\Ş\ËÉ³|3ªXRi	\â|\Ğ\âehôj«\ä\é¯\á\"ı\\ˆ¤\ŞY\ëQ–\åeS \Õvöß¢\ÍùFóğR¹^\ç^™ÿ\0*\ßbú7^6‘øBù\éüL\İ\"nŒ\ËNZ5\Åù\èº(Ş·\ïú\×Ë¥œ\ìİ½\ì°Ü¼–¹¥£C}õyŸ](\â8ò|—etXn)P\Í,\rl2€Cò\Ë`°¯R¶Ï³¦¹\áoŒ™:ş\Ò\ê+©G†Ó²Qb[q-}>}ùl\æ”\Ş87\Çq\Ìod*ıR1\ZB	d1†¸rmœ<¹*\ÊI¼\àæŒ¦¢\Òf‰]µxóñ!5]lŞ“h\Ú\à/\Ç@<Mm±\ÕB„Ÿ‹t\Ìuv;‹\Õ\Æ\ÏJ\Ä*d-q#<‡D‹Ä¶&zxÂ½\Ö\æö\ì\nŸh6O\Ò)±lBY]}\Üó·x\ßY¤[¨\ÑVwt½\Ï=\Î1“H\ã5t\Æ\'¹®8\n\É\äôp·-2\ß1ä¥”Ø†]T2\é¢ò”\Ú³+u}\ï\Ì,$\ãf+pKü–5™\\|V‹ƒÈˆ\ïd\'ehsƒI·›$d7…“e\ÃA«tó\Ø\Çhc=\İX\ŞF¼\áºRN8\\\îyú™\Î\n\n>{˜½«ôÓµ&š]\ë\\\ë¹ù³]\Ö\ÕvA¼\ë;—·6\Û\àÀ÷÷4•üº\äú¾„e¢€t¿%h|(>J\ê\Ä\0@\0@\0@\n\í=\Ş\Ù\âb\Ú8°lmú\İsYñ™\æ“Q\Â[L\Ú6ºª‘\Ó\Æv¾6\æ|³€\æ4\Zx.\ÈV\å£ƒSb\Ê2óI™\È\İIO,˜¤R\ËO1•®	_\İsd\íw\á\ïk\ÉB{™N^>Lqµ\Ù\ê:¸48}<­e<o}\İC{®<\Çx»N\\¼5MK%,ª\Ê\êSùÿ\0Œ\n‹h¢¡‹ı\å^\È\ß5#%§¤\å¹kËw«›5­\×@œà¶¦P˜\Ï;–8\äX~\Ñ\ãˆ¦\Æàª›3=jj†İ‘s\"÷M\È:Ÿ^öp{®¨Y©²\ìõv\'K@e§£‚¶…\ÓJ\æº\0Y!ˆ½ıWkS\Âñ)Y>·\áÙ›\r%K]zy‡\íFş\ë\Øz9§P|\n³‹\\™>pd\ØFQÁfÎ¨pS\'¼UŒ3¹R!uFmZó*\n\rMK´|\ZCı[şJ_+\Ü\ìĞ¼\×oüKø?Q\î’ù\Ûv²GB\àœŸğ\ç÷\Ç\ÉtQı7\ïúÚ²\Ñ\Âñg\ÃKó\Å0{·„27r\ât)R”§†¡\Ôj\çES‡\ãûeœ´Pa´-ˆŠzi)¡{\Ú~\Ì\Í\Ş/±\àMÀ½¼©¹ò0j\Ù-Ñ‚tC0ûFs±\à·\Ï\È\ÕSı\È\Ï\àş!€>GaÕ¦ø\Ë4:ö>!Y7\Æ†«9\ëûª\ê_Tú©\\\çH÷]\ç(<\ÒJO“j•\ì›.jD/§‹wND w‰:ü•œ`ò{:\İE¦)G\Åÿ\0EMœ¯¨Ã±ziœ\çˆ#”…¼‡6iº\âö\Üù\Û\ï,”{AÁÿ\0Fc“>¸S\Ïö±:\ÚzrU¥>œ?\"”\ê¹l\Ó\ÜÜºkV\ndj¨Ë¢\âœ}>+)òhƒ\âg¢şJ‰°ev[¤Åªj\âœz”\å\í±µ\Ö\Z›§œYÃ®\ÔKO\Éz›t‘\ÒÕ±ĞšiZ^:Ã§ú.:­•’Y8j²V[\ß\ç5\ŞU\Îÿ\0\Å+\İ\ï%{\'´l½˜0¿np²>\ã¤qöF\åÿ\0\Óe£ñ,ŸUÓ‹Aı‘òZ®|•\0@\0@\0@xPWµx÷{b\ãø\éb\Å\Íÿ\0*\æ»\â=-*\Íf™ƒ\è²\ßV‰\r—£¤šÃ™\äö¤_T%òıYJj-Ä“>™\înñš\Æ\íZV\Ò\Ó\Å\î%«’Šƒ\à\Ú¬›e«i\\E…6fû\Â\ã­\àú=Lz¨’ù\Z\åF3Y†aTTX|î“@&•\ä\\\âNšğ\r\0-\ZO“\æ,\ÓWeŠsİ¥‚\Ã\Ú8\ÙT\Öcx}.#I›PøZ$eù´ğ?›X{³E˜\æ™8\Ë\ßc¼l\Ş!I4õ˜[\Ùú:¡­c4ky\Ê\Üüµyº\rL«Ÿsoş3#´»3‡\â¯et\Ôõ5Q#\Ş3ğùó\èU¡6¶\É\ë]S²8Eœ[/G•³R\Ó\Ô\Ä\Ò.\ßG«{Eˆ\éš\É\×%³g\'ğ÷\"R`u\ì\Ğ\â¸\Õ1qÑ{^Á\ïiù©\ï\í\î®\ÏÓŸŠ\ÑSG%]5|ñ¸™}(n\Ü\æò\İ¿;pQ˜·–¾\Æ\Î\×\"¥.\ÑBù\ÛI‰SÉ‡Õ¼ÙŒ˜÷$?°şò\ã\à¥W\ã¹gr’Áa·\Ö8\×\á»ğ•G\å\îz]Ÿğ[ÿ\0^R?5$¬mù/œµÿ\02^\çb*¸ııñò+£O¼%ô2œºd™Áj¶~¾*\Éj\êq8¢s%‘Ñ°\Ê\Ì\ÃS`Ñ›S¯E\è&\ã\ÄW\Üóu\Z\ë¦ñ7œz²tt³R~‚Ã±/I’Y™$\ÔÄ‹5\â\â\í=u\Ö÷\åÁ4÷JV¥5„ü\Ï6\Z©\Ê]R†\ã\ælt”\âo°X!¿W‚~\Ö]\Ò\å\ä\êrµú\"\Çkv\Û9E®¨lù\É´—\ÃUV£-\àQJQ±)<\äl=.\Î\Õ	ÿ\0OT¾2º0`î¼‚²“K1Yf­7,nn-¨\ØJk†\Ï\Îı\ã’³vó²*\æ\ìof\Ëwmf\É@ Á³\ÛK¹ƒ_yS›21\Æ_Àj{{µ8õ,\Ò\Ğú9§\')¸\àm¥¬¨ğ“YÉ¥5\É<´—±\Ï&n«tD¢}eF‹§’ú&n9.irj\Ş\é°×’¦I7ü\n•ğ\Ğ\ï0ˆ[<b7¼	\ÊO™\à¼\î\î\É\É\Êg‘f\ÍFg>‹\Å+\"f1KNùŒ/Ü™^\ç7d4\Ø;®šh\îüH\ì§C\nfŸ\Ës;\Ö:\ß^=W tŸdq\çÛŠB>\ä2»ü6ú¬u(ú’?Õ·\È-‘\0@\0@\0@\"\í’,¸õ¼\ä¥-ş\ëÿ\0%\Ïy\èhŸ…£K\ÙØ„\Ô\Õ\Ğ\ÚÅ²İ¾z¬\ås¦\èMq\Ãö1\ÖW\ŞV£\ïù“.\ë´Õ¼—\ĞÁ§¿‘ò³–d\ê\ç6JX\î\Ù3<Y¡¼.O’ó\Z\Ä\Ş¡¯]\éús¿¾wWU½\Ğ2ñDÀ\Æ5ŒÑ¬o\Ñ_98š\É\0®\ÇñH(\é\æ6iwF¡Ñ“\r¯bx^Ã‡VÎš\ÖV\çTÀ\è\Ã\ãñ\ìü•›†b19ğHö†–\Ê\İ\Âš£XY<Ô¥^<®}¿\è\Şp™$l.§\ßJN\í\İó’K~\é>Ï\Õ[9i\ÔY¤dğ\Ê\È\é_%=DÁ¡\Ä\É{¹\ŞóñR÷=M&§ª-M\îe›#^NWG UN\ä\Ó\à‹\Ù³\Ú\×W4¼\Ì}~\rE;\á{,.õ¡“P|”§ƒš\Í2Æ¥´tµ˜5U;ª_5 û¶Í¬‘œ§»›˜\é\Ï\Í,Z\É\İ\ÙokT¹Á™Ãûº”ÿ\0RÏ’ù»ö¶^\ç|x.I¼ı\áõ]:W˜\Ë\èa—\Ô\ãC0¦l\æ&µ‘Á£¨%EQ\ê³\È\Ó[w4ßŸ\êi;;<\Ğb\Ñ>7\á\'½\Ä\Ş×¿¼/Z\çˆey`öµQ\ÍO\èmU;aŒÔ´\â5Ó“\ËGÁz1—\ÈJ¨ccúŠŠ—\ŞG8\æ\âzûUœòŒû¨®7\Æø h$\æ‡\0²I¹\Ê]¿Wùi£\Â4&\Åhòr\Æ\Å\Ìö\Ğ\ìuV€Aˆ\Ë(;\ëf`\â\ËğóYFj[#7bÏ¹¦H	o\ÜqViùW$ò™¤q\n­nK-]\Åf\ÉEq\\\Z\01ğŠ\Å×“DÁ\Ä :\æ•N\í–É½\á.›Ù‡cF\Øæ’˜\Ó\Ä\Æ»\ÜÎ³\\\ï}<\Ö2Y}%eŒ˜üZš\n\Ú\Ö\Æ×Œ\Ôñng¨\æ2½­\Äÿ\0<\Õ]½¦¯S\İ6šÿ\0³G¬…\Õ>6µ¦Ëª\êŠb¹7Ù»ö,\Ì\Ûk{z´r‹G\Õg¨øRù—>œ\Z-À@\0@\0@\0@·¶¨¾\×	Ÿ ‘ü§è°¿ƒ»F÷h\ĞvY\Ùkk˜·q\ê¾²\×l¶õfCŒ\Å(‘¢\íx ù¯[²õp\î\ß(ù\ívB]H\Ó1‰†˜}\ÛG^\n20\Ó/½\ÈAERT2I\"vP\Î\áµór>\Åx’G¯^Ÿ4\Êo\èv\î\Ïk#¨\Ø\ì::cŠ!¼pH\Ğp¾‡Ş¬B\á3\Ú\í/£\ì\Í/LZÊœ:ª)\ZZ=|\İ\Ò=ºb—ÁIÁYç±Á1U\ÍKS*\Ú`ğy\\Xƒ¹gœŸ#D¥	º\å\Ê\Û\ìg]’ +$\ÍöN³H\êt\×\ÃòDz•\â½~\\{‡G¦ò\ÆÇŸ\Úh*2g–\ŞYV0\èÿ\0S#\ãğ¸÷9:+¾pá—W\î\êZ\Zy=¼\ä§£V¦3\Ú[3·lo\èI\Ş\Ê\á¥U¾‰g¯ş,¥…›\átg¬ù/\ÔV^\æ\Ğ\à»o\êŸûÁm¥\â_CC\Æ\Äñù©\êê«©c¦`g\î4ÜŒ·[\×B]Mm”|Â„\ë±Í¯?\Ô\Öö&š:\Ì~\Óÿ\0\Â\ÄC\æw,¤c\çu\è\Şñˆ.[=cj¼/6‘Ö¶§³pù£“\0ˆ†¼œ\Ìu²³¥¼©]•\Î8\Í¾´ü+(³¡ìº¹öôª\È#•ó‚·{Bõeqc\ç\Ì\rÁh\Ë_‰b¨\áf³\æUcjş\È	¶ş)•…6\Å\á\Ì Ë¾-ı¢\ïR\ås\á`\ÏùKmÙ\Û-ªÁ±,ôt\Ì{œ-»qK{n³®=3Ì‹I7ˆ\á“£\Ù\'áŸ™\í©7a6¼ˆ°ºİ¹qŠ\Ê\êÉ¢mT\ÅjG›Ó—\İÿ\0\r\ÖV\ã&õ¶\â›0r+›¢\İê…ŠNmÅ•x,™¼a½n3%4‘=‘PB\0§uŒ’€K‰\á`~+ŠüCYÏ¨½\×º\çc5\Î\âQSE,¡ú’O\î%qJS“ñ-ızºÎ©=¼‘¢\í5©1WB\êx\éœ\Ö4˜\Ù dõ^¥R\ê‚h÷\è¾6Ö¥\rÏ°ˆ7›WV\án\í%µñxü•.Y\é÷5\ê\İdú1t\0€ \0€ \0€ œö\Óğ¬6^L© ûZV7¯	×£~&rıœv\\f©£\ïD\n\ä¿z‘½\Ş~ÿ\0¡²\ÔC¿§|v\0‘\İ\'ª\ËM{¦\Ø\Ù\é\É\Ãm]\ìNu4†D±kœ\Ë5\ëÅ¦\ÛG§MY(²\êI}&€\Ë­½%¾$o¢\Â{Y¹ôzT\å§j<\åc\Ü\Û6;k©vnw\Ñ\ÔD÷Š«>\Çøø—\ĞûJU,\'’5”ôÛ…\æaqK\Ú\Z~5€*,1C ;†lµİ–\ã‘\Ğ+wñs\Âf¯²\îT+:rÿ\0Cd\Ø\\GıÏ…3x£\Î#p#¼\Ïv©œIŸ\ë¡Ñ¬›^k?“:]¥ ,Ğ“<,A+C©\Ï5E|‰Àüñ1ıZ\n‚c\Â+.‰Xe ‹ù©É¢1T÷şƒ’+\æe®u\Z<TIŸCØ¶9\Êq~Œ–\Â(³q\Ü3\ä\Ïj1\ŞÉ¯SÑóU\'˜Zi?»\èc¨\á=b\Í\Ã\èv‹¨ı!)©e\\lLƒ»r\ãpI\ä½G\Ş\Ù½\Ï\Åu¡\Åtû•\ß_ÿ\0N·\Ğ)YKUK·¶õœ\æ\0F½.~\n\Ú=<¡wy9g§©\Õ¸iRjYû¯ı6öM#2C\r0Rmk\ê½t«\ç¡9y˜º½¬\Æj›ı\"¾¡Ù¾\îğ\î\nz\Ò\Ù,\èQû³qJ—<“#µ\ê¢V7\æUV£\Â\Äf{K]!>\ÅVÍ·Á0\É&€\Ø\İ^v%J=\Ó\ÉR.ºrØ¢òÉ­Zªe\É\Ç+`P\Æ0j\ì$0\×\Ó\ÉğÀö‘u”£¶S/	õmŒ\Z\ì×¹\Ì-\Ñ`Î˜¬\"\ÕüU¡L•VI\ÙÊ¨›\Ğ\Ô\ÄQ1pm\İ\Ä\\|—.¥f;rö9µ}N·rö3u\rªs«Ä“\ÇFø\İ\Ã;\\89À›û\È\\\ÕS®‰,³“I¢}2Šx\Æş^\ËÕšT\åÏ¨y‘\âG\ŞÙ‡»\ÒIlIE%ˆğu>À™+1œIÍ¾C-qöŠ\Ê\Æú¢¾e|.I3\èÁt\Z„\0@\0@\0@£v\Ãm–[kS¼²»\á:tù§Á]“o\íEe\ËvôıN»–\Òú~¦\Ú\Ó\Õpyœ†“µ4®5uks\à{GP\ï\ä¯WI<Ö™\ä]\ïW\îcpüô“\ËÅ¥­³œæ›†ßš\Úè¶²_Er„º%\ÆH\âR‡H™kXC{\Ä?OW¡ñY\Ã1Gn±\Â\ë\Î\Ë\Ï\×\Ğ\İ(£Ÿ‘‚†7\î\ÃCs‘f1¡ jz\èM—-tI£\ÖU¥£§9—¡iašˆ$•¹)«X8˜ıWCMK\ç¦¿‰\Ö\Ø\â¹Oo¡\Ö(qh**\0˜oX\Ğ\Ó\Ş\ÇtB\éYÁ\æM\Ù]\ÍI<|ıŒ\Zo‡\Ó\ê\ÛòC¦½â‹  º&\n\Z\"\Ã\Z„TR²\". Ëš\Æùt\Ã\'¹\ØR\éºoı¤\î\0Ó‡%ó­\å\äöÊŒ?g\'³\æºôŸ\İ\íú™[&“>p\Ú\ZI*v\Ë§„\\š\É5\ä\îJ÷¨‹œb‘\å\ê-]R|/¢’<&’—\×xªœ\Ñ\ÇÔ²\İV\á9G\ÓP¹Y\\d¼Ì†²µ•txh¸c[w;§x\Ær;´\Ô\Ö\ëwZğ——©[\Ùf‹~!UDø m®\\lu\á¢\İU²\Ï>Ëº¥–¶5‡›,Ytx\ÉC^\Òx]S$µ±\Òökk¶gÁ | \Ï^\Ğws\ZCÍ\É\énK£©\ËûğYFKnœ—U=«>0c\Ãğø!oÿ\0\"Ê®ù¶\Êô\Ûå·±¤\íV\ÔW\í£uqi\İ\Ü7#m`TJQQ\é«­§™<³Q¨=\åƒgLKW,™¢.°|6l[§¡‚H£’gX>Sf·K’O>\åY<,‘9ôG,\ê[5”U¿£\é¦8,6¨“tgn~7·\Ş\0‘ş«šÈ¼\åV¢«©¾Z_o±©b0UT\â‘\å4\Î2B\à\İ!.$\î\È\Ôo+(\Ê³¦+t}>÷4«±\ã	b?“_/\Û4Ö¶\Öè»™ç³²³ı+&)T\×7ºø\Ø[Ï™¿\Åa(\æÈ”:\â8.ƒC\Ô\0@\0@\0@©ö§óbkk\î\İÿ\0ü\"Vvü,\ßLñj8N\ì¸\íüA\Í\\²Ş™ö®}¿Á¸´¯5³‰#@\ÜÌ¬6\î°\Æ\ïğúû\×fŠ{¸œZ\èl­ô4\Z-™Ì’\n—<–½®µ›\×N¿E\ë\'”RRŠ’ó ú9i$—Y\ím½g}†\Ë)\Ë¡¥Ó¹Å·,z\ÛL;\Â#eK\äk\âİ†q \à46\Ö\Üa¶\ÆÚŠe)9züÑ«\ã\Õ9ğ—Lü\Í}L¦L®7\"÷pÁ`ª·›g\ËR»\Íd¤¼¿ğ°Gm\r<´Ñµ¦VC3Fø¾\Ã+x»Ã—³’Š\Ü÷¡¥–©º—ŸŸ¡\Ğ\à\Äf¯dQ\ÏQQ,l³}w1–òi…ø\ÜğY9³\Ö\Óv>Š……/œ–\é¾ŠAI³ô\Ïc\ÍK\Ç\Ø\ÇN\Îù.u<|J\Õq–|…úYO]:jXÌ=\Ï?$¿ğ]68\æ6J\ÌM´ow\nj@\ÒX9f.ÿ\0m.kK\Ù\Zf±&\äıx_Lo÷+aM®l…µ5î«ˆ·{CÁóù.u¹¯]}VšNu\ç}Œ‘+Å—\'AR/VO\İ5×£\æ^ß©Íª\Ú(\ã\Ø\í\r-;ŠUe~ùò½ò¸l\Ï/bú\İ\'uUQ›|£ä¯•ú«e\\VTYNœbb‰Ï§ÂŸ^ı\àv€ckOy\×\åË†ª\Ñ\Ö\Ö\ç²\ä\ï«Eli›”³\Ì\Ä]¤\â<o¡\r¡\Í ¶W\Ø\ìm®­t+\ë1\Ò\Ê\éÔ›5\ìoo1Œb™ô\Õ4@ıch\Ü:•N¨\Ç\á[*©g-š‹\ŞJ\ÂL\èHƒ®8¬\Û/‚M‘k\İ:\ÇNIÇ¼{\Ã#kœ\ï\Â\ĞIP\ì\Ç#»o„o4\ÔO\ì\à)\á§\Äi¦vr\æ$ƒ6<÷.wzvt£šT\Ûr\âğ¿Sœ\Î\ášÁno‚\ÜóP\ÉFG\r\Â\æ›\rª\Å\ÅN\â\ZI\Ê\é\á¨i¸\Ö\ß5V÷Á?#«\Ñ7ÙŒ\nz˜ie\Ï1:3¼Ö­\Ä]¾\Ë\à¹$Ü¥†r:\å¨\ÔF0\åşÿ\0\É\Ë*\'¬\Ü\Zv\È\è\ãsÌ­„¸†1½\à‰¬:j´‡B—Rÿ\0\Ó\×u\Û\İ÷r\æ?‚ıùf´\Ínr«ıŸ3n1\'\İ5,ÿ\0aa?\êÄ§J\êL\í£‚\è.\0@\0@\0@naô\Æc\ç\èr8yµ·%I¬ÅšTñb>v‰ùqJÿ\0[oz\åK5\É¥»ı™°\áø‘©¬–™\ícH\'!¸\İc~—»ª6\'\É\åU\\œ}\n´Šª\n˜\'q!\Ï{I¾¢Ç’\çœû¶šù\Z¨õ\ÅÅš;†\É3Œ7ª\å\éŸ\Ç\Û\Éz•ØšÏ©\ãe\él\èŸ*¦¹…Á²5\ì!\×p:l\å,\àöôúˆF§°À\ÜGe‰\Ü\ÆÀ\\\×+sU\ÏDw9ûSV¶”W(\Ø!ŠŸÅ…-\\Y\â‚\'86ú\Ü‚T°\'I\\¼\ß\äaŸ0\\V®\'±\æR\×kc\Ã\Û\ËØ­d\\°{ıŸ¬®¥b\ÏR\Ä&©°‘\Çw~\ìc@=ŸU¤\"¢ev¢Ë\ïoC¨vcKO…\àU»IRÖµÀº8\ï»a\ŞrMï“£O\\\\|ò\ßüS\ã\î™y‚\âOÇ©\êñX±)#•\Åæˆ´et}\\x’G0t:yÃ¯œ–v¥°\Õ\Æ+h<,|ß·\Ã‚®H‹³Ào\çªòõûE#Ú”º\à¤\\¼–÷3Ez!˜\È6ıWf‰nı-{\é«&“]A\êñ:Z\×6õuxm\ì\ç0[Û¢õSx_#Š¹E@´~1v\Î7¡Ô¦‘´²8kg‡\\\Úı\×]]Í£¯G¸\Ù\Zn\Ú\ìıKK5¥\Í,…l\Í}	\Íg\ÅtWd¤÷9\ç\Å,\Z\Ìµ5N\ËO\ä?²\ÒU§j/B©O\á\Ü\ÉA³¬Í»¡d\"ö¼²ğ?asOW\\~gL47K\ËZ›cZ\ĞUV\çk«be¾\'^œ@\é\â¹g®ÿ\0J;!\Ù\Ûx\ß\ï÷ûò/ÿ\0A\à¸{sM	\æg’ÿ\03oüx²w\İ3u¤¢²\Ş] \Â)^)©‹^ó£b¦‹\Ö\è-\Ã\çù•Ë’%~¾\ÙœWª®¥šš>awn\Übæ»¥¹-\ê¦5\Íu=\Ì.²v\Ñ)\Æ>\Ë5\é0é£·¥º*[ÿ\0Ö˜\î?ÙŸC\É\Ê)\î°Èi+**< ‡ ÷¿_ğ©\Ë™:8\àus\ÓÑ““\ä1K+¤\İ\â4·½ae2\ÆNı•]I¬\áÇ›3˜LõX\Íc°ú‡\æ£\Ã\ÙöMk\0i\ï4Ø\Â\Úe’ñF-ù™\ê#ü¥ªx\İ,ò¶\Ég¶\Ø\Í=T,££l[º#“F‹\ë¦P|-¯ˆZ\Â\ØÎˆ÷p™\ÏW\ï&\Z[K¹ğ[\à\ê¿\ìıˆ\Ç-‰\áò:Î–6OO2\Óg|YÙ„Ô™V·Lï£€[=@\0@\0@\0@˜¬\"£«€ğ’°ûZB‰pJ\äùl8Bñ1\ÅrC‰/‘\ìÛ´’2:‡’f4lŞ ®¨A]¥P\ÉóN«òŠ¬•ï¨’¢7¾)\ì\á§P\Ã\Ğ}|\Ö=\Ìzze¹·x\Ö\è\Ê\ÔÑ·£Š¥¤GT\Ñf¿[­=Bó²\Ó\Ø\à÷GE´\ÃQ_ˆ\Ö\ëiemM,8…#\ØD\Â\î#3\ä\ïü/F«!?…œš\éÔ®¿„¾Å©w\Ô\æh,ÊˆFh\Ş\Ñ\ïĞµ\\\áŸA®\ÓFúš’\Ü\ÃQWKE-\rT”Å”s™¼.»Ÿ˜I\ØU”pÏ\Ç/<•ö\Ê\Íèµ°89¯ihpƒ\Ì}U‰¯+f[\â¸si	¢k\åd°¹À\íø¨M.MS[¹3¢W6FöI…ÁO÷\â3\Ê0d\×\à£+­}OW»“\Ó\ÏJ?’lÒ°júŒ>¤KM(i{LOœ\×hA]<—\Ø\Ö}Q\ŞËšúç½®j€^\'hòv9U$ı_\æH•ä°‹Š}£\ÇVıWnŠXo\Ø\á\íæŸ©\Ê;VÁ\êjq)«\é½*7@\İ\ŞV¶\â\\Ç‘k®8s\Zè½˜<#Ê®\ØaG\Ì\ÓvKh1<Jš:jHÏ…\ÍpsĞ¯$ç¥¥²Pm%\Ê7W\×Ò²’\Z¥§‹}0s2f4:\\8ªÖ““^F=O+\èYUmFJ\â#‘ÒM÷,\Òş\Ûùµ\Â\ãz{d\Ù\ìÿ\0L3Ÿo\Ş>ŸTbßµ•µ`œ/{‡)${\Ç\Ôø+-\Z_0—h¯\í_\ßÜ²š§¨5Q±³Zñ˜û,\Üù\Ùjª¦\æq]\ÚSO\r\ã>ˆ³‡¢7\ÎúŠª§]\Í´5¯p¶¤Ÿjµ“U\Ç\Ğ\ÛE\\õVã”·İ³k\Ù)\épü	¯¬Š\ÇZ\Âá¼”\ë\èA:€@²9e\×S8\Ù(%Á†\Å1ªGU\ZÆ¶z¹\'•ÀDö›jM…«J¤bİŸ#­NÑ¸¥†ö÷H\Ö\á\Ã\ß+‚2“5ø/kÛ«£)n\á§À\ê#•ñ´\Û5ô>JØ£zôöO\È\Ï\î\ÙI†\ÓH\ËTD\Ö\å|`\åto·>­6N+\ÌO“¿G+ôù„^ú\ç\Z	\'¤‚¾® \ÖúT&<Ù­f¾ƒ­ÇŠ£–\ZŠ#Q\n\î¶\ÆòŸ\éû\Ü\×%h”€\Z9•\ÓzX\ÄJx–OHdLswM¿´‰Áb\ÃÁ=\Å\çÀqªLN”\İôò\\·ñ4\èG´2Š”Z3kcê½–\Çi1\Ì&²Ša$2¶\ì<üZ|GXK\È\Êomj\0€ \0€ \0€ 273H\ê,€ùcf\â¢xønjœÁ\ìy’=‰?_±—Æ¢\ÑC;E¥-\é{ù\ÛÄªh\ç$\å#\Ç\ÔEu&Z‹5¡i’\é™\ÂÀ›s²\élÇ–y=tğÑº27rŸ\\“˜ŸE§…–©²et£_B$\ê\É²µqd|=\èù–\Ú\Ä{—=õF\ZÈ¸í“ª‹$\é\Ëò.(jb«¥h\Í\Øö\ê.¡tµ†{\Õ\Í[×™ˆ\Ã);ˆG‚Õ»wOHe!NÜ®c¸‡¿MAµ¸­8Gƒ(ø\Ú~E=|=\Ô\Õ7’’)Àdœ7rrµş\é\áÿ\0•,\Êt\ÉÁØŒö*\êŠ*\Ú\\AòS°\ß\0»s>:\Ø,\æ³†ú;úk›Ä™‡>¨\îY&F\Ê-–Ò»C\ì+K©.ù>Ã³ci_^\ØQ\Ï\Ò)~„e\Âöw€\ÍL\Êm\æf\ŞHbÛ¸H\æÕ¹§ƒ+\ë¢\ÈõG\Üğ¼&—	©ª†‰“G d‘\å\Ü9\ë\Â\ë\Ï\í#8\ã»Oò/\ÜW’\ËhÚ»÷WN•øŸ±Í«ş™¬bó\â²\âu´Tbï½’2\ã x\êt\Ñ{ZIJ\éô\ãÂ—×­>…t›\ë|%ø¿’5i)\Ä„³—\Ëó3w3›3‹¥ó\å¯N×„<g›´\îº\Å\Ü\çu\î`v†šª*jg{	ğJqó7:œ\Äk`°\Ôlú¢°™\Ñ\Ù6\Ùddóƒ	-‡Q:ô\Ødy\Ç8;\Şü\Ä{,¹Zo\Ìöd²ŠuCU#ˆîµ·¸°\ÌGµ\×øYF,’Ö¾cw—8.MÊ‡RPR{¥}kKY÷t\\X4\Z7T›„–ß¥W\Õ>¸\í\å\èmXI+**\à…\Ì\éEó>ÿ\0‡^\'óXNO-PÕº®ºüO\×sú£¬xşğ89\ÎÑ¾\ÛrVrilOq\'),ıÿ\0ölF”o7-$¼>á°\ßs¯\n»¾HIE%ûØ°­óJ÷—1¸\ŞÃ’‚\Ê})$YÏ½]\î\'\ËEd‘9›2X\Ø423/\ÎòYº/x[ñWQ\Ïóµ3¶-`¼¯\Â0¹\è\Ë#Pƒó8~«xwrX{3É·W¨ª}kxú0ì£ª_4RN\Ğö·4d‘gk\Â\Ç_r¬—C4ÿ\0ı\'gN!³\ç9(Ë°õLŒå•¦^ q\ïY÷’O‹\Îç£±-Ç¶‹a\êóD\Ç\Zg:òÓ¸\Ş7ø\Â|EŠ¶c7·$\Â\ÈI\í\ÉÙ¶Sµl,‚ª£\Ğ\êœ?WQ\İ>õOÀ­~f\à\ß\â–9ZÃ\èU‚y*!!\0@\0@\0@\Ì\Ûmƒ\Æbn©\çüW\\«kY<ÒŸ\ï’\â²ò\ÑSH\Ò\ã\Ü\0e\Ö\æ\Ë;Å’G›©[³SP \Åù†`-üø.Î—\'±\ÆÚ‰/\Ñò\×\ÃX14ó\á…\îµ\í\Ç_Ÿú-Q\å«\ëS6,2ˆÇ…\Zz€\Ü\ï¸\Z\Úü—ƒ¬·:¯CÒª®šºNKQY³X‹\éjYv^0twG5{1”m‡\\H¦ù\é\å#f§}cD¯\Âe¦Š*\æ‚ùŒW• şùğ\Õ½N\Ët\ÉuE\ì\Ìv\Õ9\Ôxm-53d\ä$q6\Z)‚\Ë\É]{\è®0\\\ì\"¤b˜$RL·‘–J7p?š3Ä–T¶\'DŸ¡šù>\Ğ\Äøªõ\ÃûÌ¿ö—-m&\×ú[=¾™\ê4¶\Ó‡(\í\ï\ÊıQ‡Ú‡\Å\Ô\Õ\ÉLr²\\³1\Ì\ÓG4ñºôa,£\æû6R––9Ù¬¯³;†\\\Ü6‰µ3‰ª\Ì\r2<ñ}\ÅÁ÷\äv”wS>–µ%Ÿ4V%x\ï“d\\a\Îh©9›˜V¥g‰d\æ\Öÿ\0E²µLQBÉ\ï<\æq¶§K\0¾‹N£±Áò=£,Å¾^?hå¸´\î\Ãqºi\ÄÁÒ‰s\åhÑš/\ÌØŸ%m{œ”Ó“¿ÿ\0¢\è¦\ÉØ¬øºV?_\ĞÕ¶²j\\^Hğ\Ö5Á’\È\ëqs{k\à\n™\ê \é„rv\×Ù·\ÇUl\ã\ÎÆ¸\Ü=ö¼…Œ\ëÌ®I_Á\èCA/\îe\ÜXd%¡\ç<„õô\0,e|²i-P–\ë%b\Ø`\î<µ*)J1†\ëb¬PNá½‚)\r\Ã\ßf´y“`¯\ZÙŒõ5-²W4nyt•3°8÷ˆŸ\"mù-UHç»ı(£#[|A\ä\0Ÿµ‘\Ò>\İl\Ûš\ÑVy\êì—™E’C4›¶	şc)-?QñG#©\Ç\ÅÀ\İH\ì¦(‹óps{Àù²k\ß\ÅV£”]Å‚\×\È\Òd&s/6X»`ÁokB>ó\ìbkhh\å1C‰\Æ^Æó¥¬Næ·…“ŠÌ¢s;¬³\Ä\âm´¸uKpÖŠZ¸\ÍS˜2Ô¹¹´\åoh¸%b•$xó»®\ÇÖ¶ô3Ì­\Æ1\n°üC;CAª@H¦€‹\Ùu«[Oºl\ív\Â\Èb¼\çĞ¨i+ §sã’Y\Ç,ovbGK-:’‚\ê[”ƒ”~7‚„8\\¸¡s¥iŒ°\0\Ö\å=\á}t<Q.ñccI\Â’]K\Ü\Äc=ŸÁ;¥}<e’C²xs·ºµ\ê‹\Ê\ZŠs\ÕC‹m^Æ½¦¹\Ó\Ò4\ëûÌ·—ûZB}kŒ\ZUbŸ–\Í\Ù\î\ÛÃµtO}²OƒfŒXO~`ğVSjXgF\r\ÙjT \0€ \0€ \n\ç^\Ô!\Ü\í~5­˜‡û\Ø\Óõ\\òş¡\é\ÒóF6\Ö\Â0jx\äp\Î\ènÖƒ­\Ç\Ï\Z¦\î\êŠ\Û\'ªqM¦a\ë%ad\Ğ\ÓcÌ£†\Ï6[™:xŸKH\É$––§zc\Ìdi\ãn„*\Ïcz¦ºq\èg°\ÌX\\15\ÙIh-&Ö¿£\É|şµÿ\0>Lô\ê~k{OH\ÌO–)ú¼­Š75\ÃW}EøXñ+\Ò\Ğ)F•—±œû¹ug“\ÌÄ°VŠ\Ó\ÉR\Ø\ä\Î×°B\à›^ÿ\0%\Ó=÷GN†\Õ\á\'\Ï?k\ëY,Œ¢k^$‰ÙœH\ê4²¼7+\Ú6©K»óE}”¨¨š”\át‚?H^\é—\Õc2’\â|,Ks\Ì\èë‘š¤¦Ä°†\ÈÊ˜£“¡“q4‚]Dr£AÔ¶\å®U\Ï8ÁI\ÉyT\ê3Iú¯§¡†\Ú\\6¦‚¼=\Å\ÒÓ¹­H5y{5\Óı´\Íc¥šj´ñŒ»Ú—†O>\Ï\ÍÒ’H\ê(\è)coô\áCğ›ú\Ù[g3\Î\Ê.©]É¼›¥õKŒ´ÿ\0\èH%h‘§Gù/œ±4ğÎ˜¬lU¢2®\"\ã`MŠ¶]6Å¿S=D:ª’-¶Ö®¯\rˆºŠzx÷\ì³L\Íq\r#¬9‚9…ô3³¸YXúŸ)~•\ÛjŠoô\ç\èrJú\é#³\ê\á‚Qù\à”<<»Oš\ÖZõm}8\Üô»/³—g\ê\á|_TW—šılf²’±\æ¦8F\Ş\r\Ê|üBá±©M¸­©”\â\à\åeg?>qK²¸´ô\î©|añ\å\Í«62ß§?ª•_«<»»EE\íö1õ8eV6\ïŠX3\ß,}˜\ï-5÷«8¤*º7¯’÷\Ø\ÇÙ™\ŞÖğ\İs3\np\ÈrÇš+„Á¬œº@Ñ•¯kò½ƒ <ÇWRh\Ætõn_njpehµ\Û9¬:´“b\Ú+©eBPx“-d\æ\ßSœ\äü{²À\ß¬½J\ã\ÉaÏ¡Ş¹Ø­;ˆ\Ówº~­\ët{“‚\ÚJ\ê*:\ç»\nlÌ…\î½\Şó˜+\ë\íº«I\ì\Èykc7…c±œ\ÚúyD#@ø™\ÃÀ‹®+´ıOÃ³<\İEOl[=²\ØËQccqv»°\à} p>\ÅWUáœ¿\Ê\İE+\à\Ùpü>Š–&ED9#õD™¸yYf§WS—,Á\ê+MË§,¼1T¹ÛºI\é[½\Ò\ï— õHÉ¹xYm5´\Ù<\Ú\Úö\Ûñ#5$¸d…˜•e3M¯Ş‘­ö‹ñõ²¦Y6\Ô(Xÿ\0—[Xú\äµ~;’–#1üE\Ö¦\ÄDtû\'7ƒ\Ã[[R\Ã\é›ûpmı€Ü«½Dq„oi†\Ê_™¯\â˜\İ”\ÒÁ;\Ñk»@:›[‘Œ¹{\Ç\È~\Ñ\Ö\ÇÃ¢\",\Ùš¼$ó\áÉ®O G\Òfz€ \0€ \0€ \r\Û½µ˜\ÛI©\"“\Ï\ÖoùW=›K\'¥¦Ş¬\Zsb{°ªYZ{­%·-V\ÔØ•’ƒ÷<\Í|T‘l\á©.i-µ³ròºİµœ\îqa­Ì–N\Ø\ã$¹\Ïh\ã\Éq[6\Ş=¥ƒ?…>\Òòp½¼Gş~\Î\ÖÁt\ÆG¥¥–V]t,¦\Å\Äû\È`™’cy\ÒI.\Û\04sš\ë\ÑX¥B^‚Å‰ˆ\Ñc8c\Ø\Ö\r\ÑfIé®‹M\08®Ÿ_K£l’R6¦ª93³ƒ¨-&\Üôö¨\á\àô±kŒñ—²ÿ\0\'›+‡µ˜ıc>ˆ[-.{\ê\×=·hø\æ¬\Ş\Èóe\É.½{±‰pWV\Ôú-5æ™®€ºL¥ 9§•Í»§¢¬’9\ïM\Ö\ÈA‹\n9\Î;D¶\ÒA#°Ü›·÷o\î\\\Ò\ŞGoaöœKQ,y{úg\çóô7,:¼G3=v•\Í:\"¢»O¬¶ˆ[‡³_s?ƒ\Ö\ÅWE½†g\È/³³%Á\Ú]*\ï¢<Zc$š—“™t\é,t:¯;;›(•ö¦š\\wdjM+£•¹_vn8rú\nš\ÔÓ—ò>sU¥›–3\Ñ\Ã*hji\ç{·õNcg{WDjJ]/b‘\íJ]\ì?ğ¸\Äp¹) iv]R‰]6SÇ“Ÿ³{bw\Ü\á%•ùû`¥†cu8{\ï\ruKch´a\í\ÎQcq\È.L3\è”iß®//Ñ–õ\Õõ¬¦w™\Şı	\'Vó\Ğr\è¯\å\ç6^\ë®Q‰<\Ñ\ç‚X#eP¬\Ñ\ì’74±û\Å\Ü\ÏOj\Ş;&—‘\ãKS:ŸZ\Ã_2úxc¤¨\İİ¦–°÷/Qh«­g0zûnx\ÏJù¨+„¬)\Ä_#{®]¨…¸’ğ\ç\Ğö5:^Ë³H\å\ãK\×|—RSš°Zcs¤wªø\Î<E¾ ¯J\İ-3ñ\'ƒ\æ©\Ô[„²c&\Â\ë‰ŠI\å \ê\Øb\ï\Û\Äq>\Å\æİ§²¿š=\ëk³fğşeƒ²²A%MDY\Ùf\å‰\ì\Ì-\áõ\\\ÙF«ÃŒN\î_;/3‹ƒ³\îò<\Ó(\Î*>e›^\Æ?yH&}\ÈtG3ş<¬­\áh\é[¯‘³\àx$Ü¬¯1HÏºû¼K’\İ-r\İlrY¢®\Í\Ö\Æ\Ğúˆ\'Œ¸TˆÁ\0ei\é\âU\áV¶5§O\Z£„·0¥Md\r\îw“÷u*e&l–80\Õ8\Óiq¬‹öŸ«Š¯K‘f½L\rf8ù\\K{\äı\é\Ñjª^d\ä\ÅU\ÖTT²É¥\ïa Z(¥ÁRÿ\0g¸\Ä1	^À\îó\Ó\ÓB~‹)ÿ\0R%\ã-™\ßG±@€ \0€ \0€ /Û„6¨ÿ\0«FYıÇ“şu…Ü£\Ğ\Ñü2G2¦¯¨£¼L-tDœ\Ñ\È34ûQ±g\Ì\ÊÕ¹«Å ¯Ã(¦,”Z\Öú¾wä²¯O([Õœœ×¯[†OD2µ\åñ4Ø´·\ÕÜ«¨±F\î–a\Zú«\ê3H.˜\Û.F‰¶‡Ü¸õ\ÒJ\nÍZX\ãs%<\Ô\Äc•·i\ày´õ\\\å[\ê‰\Ù(\ÆKÔ±<*£ª‚¯¨œ7Q½Ğ¹®±6=Zz[è½&¯¾Ê—\'-±\èYF&jŠ\ÉY$Ë½ÏœÔ±\å†ò¥­k]vmÉ§z\à•Kç‡’\ïe\ê\Îdš¡­|5,»ÀHi\ì}¼\Ç\Î\ê\Î\Æ}\rG,\ÉCA]³u˜Y£¢¹\Õ{DC<Mq~`\à\î\0[%¿Áœ“œ0‘…\Ú	_T±\Ö†Ä\ç\ÅR¸\å4yz8)V\ã#`\ÙA†nC\Æ!1ª\È_\èÁ\Ä0óYO©gc§³uºú»Fª–Õ¹aıM\Ûbd	œÿ\0«”û\Í×—¯şªöG\ÖC\Ä\çÿ\0\'ù™\ÇÈ¸<\Í\ÔK¬ô9ŒrŸ±“Gx«·I¨\î\ÛO†q\ë´n\êó\âF3kğ±ŞŸ¾tt¯p\Í#\Z\\\æ_Kx’½\È\ÂwôŸ=4tsŠğ¿/G\æZP\àø}[]“Š\Ø41\n·’XmøA\r+¾:IGi\í(Aÿ\0&=\íûû–Ø–\Ç\Ï$.m3Œ?3b\Ğ4ô \0º)Qxq%ö¯\'ö\ä\ÒvšŸi)HŒFñ¬@ û\r¾JÚŠº°\ê\à\ì\Ğİ¤“\Ìö—Ô·\Ù\é1wT4-»°HôK\'[\Û^+›MT÷\Î>fúÅ¦š\Ú\ÍşO&\ëO‡WKsX\Ú\ZXÀ¹3%\Õ;\áœU™uiSY~\åµ-NJ\éM}+*^4f\å­k™²µĞŸNz”WÌ5WY.˜E\Éü˜n\ÒÌ­ ¡‚•²\0	knl<lÁeUT\Ù<6\åù£³µ´S\×)(ü²²c¦ª’[‡9ö&\î\0\Úş}W¨ªŒW\Zòò÷e«¨á¯”	 2¹¿ó/g#ù\İyZ¾\ã;sò=\Í|–g\Ç\Ì\É\Òl´’½®¡\Ä;P2€M¾G\Éyk¥ruY¥ŠjM\å\nœ7Ã˜†(y»™Q+XË‡&º¢\æ-Œ»)°/6o¹QK¨\Ö2\êó5ª¼u¥Å¦L\âÿ\0«‹A\ïZ(6jšF&\\Vw\çkch\Ô{VŠ´ŠO{I{‹‰WDR\nrÜ¨$\íÿ\0\ì÷N†UO¡t\Õn\Ü@có.+&ÿ\0˜½Š¤Ü›òGg¥P\0@\0@\Ê;v„dÁ\êH\Ô>H¯\æÿ\0*\Æ\ï#»D÷’8\İ[rM\à\îğù)¦YE¯%(g0\Ê$e‰œ4>j\Ù\ÍÓ•† ª		Ši›ˆC\æSŠŸ%\ã¨ô™\ì#i}†¦™¢?\Å‡\Ú9®+´]Oª,ºIplô%kA¦¯<\Û{8{—m¯\âFˆ¡´´ş“ƒIvB_×·x-tO¯¯\äe¨x†MJJ\n\Ê2a-6P\Ğ\Æë›¨òÿ\0U\îœJŞ¬IòŠ=\Ò\Ò\Ú¹‰\ån#èª¹;¦ú£˜gå‚£CiœÑ’XZ=Gõ>E|ö®®\ßÉ¥n3†\Ç>\Ú8²\ÓCq¬Ot~\í>‹İ¢Yú¤x4.\îù\Öc°J·S\âQl´Yil|ôôOUSô’gJ\ØZ\ë\ÒÕ´nù5xzõã²ıO¥¢6/÷?\ĞÚŸ/À\ÑĞ¢P|¾*$e0¬x\Ó7ÑªÛ¾¥v–p¾Q\å\Ì/GK®•^n/_\Ùq¿\Ç\r¥ù”1\r˜‚_\éøƒ\Ø\ë\r²ş\ïä¾“M\Ú>¹>_\ÙV«\Z~–m69[FótO\É\İ1\ÈK\\-û\Ü«\Ñ	¬´|ú„«o{\r\Åb\Ä’Zi\Ø\çXj	\ßÁr\Û^\êF\Õ\Õ;:3ù˜Ê¨²Óµ”Ï·\ÜÙ½\ë¨·™nw\ÎVÖºjO\ëûúš†\'³ØŒD¹ğ2©œœ\ÂAÀW£]•µÒ¶9÷B]Voø£]’aqôˆ¥_ô!bôôWâœ³\î{±\íuñ\èÓ¥òXüKYgn`\Úh\Ş?jFX|\n¤ûB0X®%c¡¶\Éu\ê%—\ïşKº\ZW¹¦i{\ín®\È=Q\Ö\ÜWŸfºs{³ª\Ñ[Q\Æõ/5†\Ñ4891‚\å\Ë3¶º§9(\Ä\Ã\â»y1f\ê—-<C@ş.*#\Í\ï{En’û¿SU«\Úç¸±¯šSÿ\06côWUz˜m\äbjkj*ši\\\âu\"öåªŒW‘E½Ô’.€)N_Y@>‚\ìœG³q\Émdt²kƒGÀ,–ö2|¬¤\0@\0@\0@s®\Ûi÷›9I?ı\Z¶Ÿ\ï4…•\ß	Õ¤~<|Y’5su·\Íc†wZ²²c\ÜÌ Àó]—K\"B¹<tBÄš\\ÇµÍ¾a¨sMˆò*\Z\Î\Å\ÓÁ“ıkh\îÇ¦\\ş° \ÜX®\ákSSK¥ª.Ø¨ª[UNÙ™q˜j\×‡¢\Ú\\KX-\å\Âhj*\Ì\ïa¸/k@w\ï\ÅN^Fr^f_\nx‹\Z­@C…ÿ\0	|\ÊóûB)Ô›ò™×£—‰£¶„IˆD\Ñ{Ú¡šr<G¼;Ş­¢a±Å«]Ö±KÉš=#­W¿5\è\ÍxY\è\é^5÷_™¾\ì„\Æ1Zÿ\0Ô“ş¼]rË·ù>—Oñ\Ûÿ\0/\Ñ…=Vv\Øü×œ\Ñ\ÔI\Ò_šª@ğ=NuG[5$™\é\ä,\'¸>ªõ\Ù*\ŞS1¾Š\ïM‹&iõ8~=‡`§©µ™;zùı\nöô}§(\Ëgô>[´¿ú~2NIgóF+ô\ì”¸¬Õ”û	\\\Â,yp\àz.ûeMş$°\Ï+KUúYxe\ÆÅ¾µ±5ğ´zS	³š–x_‰ö•HÇ£†_S\\o\æ){~ÿ\0#7‡cµ/sc­‰¬i6\Î¨I]O*\İ ¶–\Æ\Ç.‡UA¼1\Ç+œ4uµRÒ–\æµ\éjU\æ©nÿ\0|\Z6\Ó\ìØ¢£¨«§„7v\Ò\ë»F€-Špk\ĞÊV¢»-^3ó9MN\ÑJ\ÉÄ˜—°÷rpòZ*ú–\çº\á	ÁÅ­™†©\Å%šIbkø†rÀ[F´ad¡”\Ë\"\â\\O2®S  @.€) õ	(\Êuº€}9\Ø\í?£\ì¥(Ë¯£FO™\ÌO\Ì,¡¼¤Ç‘¿P\0@\0@¦v¹÷bjo\ÕIÿ\0\Ä\ÕRÏ„\ßLÿ\0š\Æzè²¬‹u\Şn±ŸğŸ\Éo]™Xg-Q\çƒ\Zö½®\Ík¡jšg,ªœw[¢L”;òR\ĞS\ÉY®…ó(4M†L\ÕP\Ø	w;@5\ê†Y\áhØ±™\ßJ\Ç\Ô@LR=\Â\'9½\àGSĞ…	\îğdh(`£\Ğ0u{Î®y\êJ¦Ho\'”X½6\ĞK\é.sDq5\à] Mş—[L\í­(ú(l\äd6ES\r5u<Œ–-b{\Øn,\îš\ã\Ñ\æp’ÁjT\åRš\å\ÎjcK‰¿\Â\ŞW\Ñ{Y\êmr®_5ù›fÌ»+\ë‡õ÷ÿ\0^N¯û\ËüŸUGõm_?\Ñ,[š\àh\ë.„Ê˜Ä—@Uk\Ô`.Uó$\Ùğ*ˆñ|2|/\È\Ã,µ¸\å\î^¦–\æ\Ö(ùş\ÔÑ¨Ë®g:\Ä\êb\Âd|GHöƒ \Ò\Ä\ï±M³\ç©sm©.=şf] ¨qp|Û¶ô\æ\Êı,\ÒÊ½²»VÈ°jx!fi2\êù\rõòV¥´š‘òÚl´mÂ•Ÿ<¿\Ğ\ÑûS\Çk«¡l2\Õ<³=ò5\Ù[ks\Õ\Ö\\·:û&\ë5÷–¼ş\Ç2%l}\å\Ğ\0„(Ğ =\â¤ PQ\Ä\èëƒ¥ô]Ÿ‰¼¬\Ğ=Œhù‚±£-7\êÈ‹mnlkbB\0€ \0€ \0€ 5¾Ñ¡\ß\ì>6\ÑÅ”®—û\ïòª\Ëx³Jv±9‚¸eĞ‹\nly’\á\ãWS<FO\İ\"\í>\ÎKH\Ûş£\'Cô\Ş?#<[¢ñ˜\Ï\â\Z´­Tó\Ã0œ+{Mt¿_\"›˜ø\ßXŠ\êI˜\ËOd7\å\Ù\"%ñ¸–»ú«#p”w*\ÒM4Í’ ¼öf6}¸\'j*L\Üğº†\×P67¿\íY\İx¹ip:|ùª3qq{šôñ\ÉuNñ¬c·—\Ê\ÂH:\ru\ê¤ôôŸÌ¨\Ç<¹\ì\Í\Ç+¸_®ª­&òÎ‹ §yŠF*M]\æ\'ÿ\05X¾œ\ÄğôMÕ¨\î_ª\Ç\Ü\Ê`‡,\ÕÜ¯#OÁp\êwŒ}´¥:\Ïuù¸\ße\Âu¢\á¯ñTh˜õV†9C@­›EPf6Uÿ\0\ï\Ú?EÕ¦{³\Ï\í‚>ÿ\0¡É¶\ëûMˆ\Ä\Ò\Ø\ÙÏˆH¹?2½ªkJ)Ÿ-(go&¶\ÉKcpµËó¨|niŸX\ä\Ù0|x\ÒB;\ä\Ö}\'«\Ğ÷“\Ùrañ¼N\\F­\Ò\È\í9\0´ŠHôtzU§‡J1ªN°„~ =[C\ÕæœÔƒ\Ä¼ƒ-³[?ˆm.\'\\÷º\Î{ıVu$ø•K‚NÏ€v!„P\ÔCS‹W\ÔW\É³n\ØÁd\Z\\ŸŠªApBØ¢`dmk@\ĞK\0¨€ \0€ \0€ ´TÂ·\0\Ä\é»úIcşóú¨|ƒÄ‘ò\ä.\Ï]\Ô¸Y\í¢«T&£\Ò\Z\æ\æ‡‡še®	i5†YÉ‡e\ïR<0óÚ´ùtZ«¿\Ôa\ÜJ\Ôñòò,ff\íÖ©Œ\Â\îN\Zµ\ŞÕ´e\âòe%	mb\éBJc©\×\ï7‚\ÑM3š\İ£º\à„2\Ô\ÒLÙ¢–K·L\Ì~¿mIVüË¯O}eKŸ1\Ë@\ÌE‹­\à4Uh\×Mˆ·ö2lª\Î\Ô\\S\Ê\Ğ_\ÛvJ/nA\ÃóYØ¼\Î)\èİºÊ§UŸ¹wœÏ¬““¦\Ë\îhü\×&«n”}õYd¿\İù#.\×.,h®\Ç*Vk¬¡ Vd¢üUZa\'Š¦3{&\ìØ£‡X\Ñt\é¾&yı¡ğG\İklŸjqgu¬—ø—¿_Ác\æŸ\Ä\Ì@\â®C\'}¦\nd¡c\Ä$õ\ëM®€ô[/òxmüóBB’—[Ÿ±A%7É›\0r\Z]>Š\ì+“ga¬1·};…\Ö×¼\ãoƒB\Æª\É|‰M3¨­€@\0@\0@\0@BA™®oPP(\Ï¢\Ô\ÍL8C#\ãş\ëˆú.,6{pyI†•VhLV]T¹0¡’N\Í{r¼`ğ*3\Ñ-&°\Ëp¶ƒš‘û£ø¬?’\Õj<¦ŒU¼\Òñòò1ó°\ÂûU\Ä\è\\\æ\rZ}«¢2\Êğ¼™I\Ö\Ş.K~~DwnaÍ£šx8~¤ö\"ziGu†½Kˆ‰\äS%c\äT’f\Ó\Â\é£¸5¼\ÉYüO\\q¥­\Ù.|Œ\Ö©\è#dŸ¬=\çù•\ç\ê\'\Õ7ƒ§I[®¤Ÿ%ğ+u\Z\ë*´IPH«€H=&\Ê@\â£›\Ä?y‹9·ÿ\0”~‹j6ló»E\â4r\r¬s´Ø³\Ø,Y)YŠ÷køóMcLJ¹PJ\Ä\0²\0¤ƒ\ĞuP	8[šx€ƒ¸…\0¢x!\'Ö½œÓ¶›f\é\"krˆ\à‰™zwÿ\02\ç£|¿™kl³j]\0@\0@\0@\0@|»µpz.\Ô\ãZ\Ù+$>óª\ã±n\Ïb§˜&cšVl\İU—DÂ©ra(¨\ÅF2T\n¥\Ó=sZö–=¡\Í:X6Q|),3.ÖœôOt.ü\'VŸg%¼uSY9¿…”h–>^E¹ƒa\Ê\ÚX\Üy8e¢²–³\ÔUÛ®[t/r\êƒ	”\ÌÚœA\Í{šn#\à,\í\ÔG0-V–\Ù\ÉY{\Ëôò3w\Ô\ØYq‰ ªYA\'·\Ñ&•\rj \ÙvŸÒ“›\î>¡oB\Üó»Ef0÷ı;´œw\'‰ª’ÿ\0\Ş+Ü‡Âœ–\ï&9XĞ«PXé¥‘¥\Ú5£›´Q’\0\ÛA­ø¦Ju2Ÿ5%Á@Sy\Õ[¤u~#KGn\é\æd`u¹C\à‰¼E³\ì,\nŸÑ¨Dyr\â\Ò?wº>\r:WL0V”úy2KS@€ \0€ \0€ \0€ >o\í6GÛ¼Y§\ï\È\Ù=\írÚ¼G©¦y­\Z\ÓN‹#©c-\îŠ¥½‰\é}8*²\ë8\Üô(.Wƒ¼\àrx3±\ád­#2:Ê±yD\Õ>¥’!IĞ™!\ÑTĞ˜\à«\æY\n	$I$\n€L\0ô`›\\ªX\Û{;§uN%R@\"~aoBm\ì?´Z„#\'\ëú[c\àHª“¼9÷Šö¡\Â>zİ\Æ=\\\Är@#…òp°™FÁs#ˆ‹$Wø*\ä\Ïqki$VC4s\ÚÇ·)-<’”\Ó[šk(µ\"\ÊBdJ’OtÒ¶	·¯Š)@i´r‹µÄ‹}n¢[•œ\\–3ƒ\'±.\Úü ^Õ‘Ÿq¿\ÑR×ˆ6SQ\êI[aŸğP“\Å\Í\Ì|Î¿U5¼Á6j“Š\Ã.\Õ\É\0€ \0€ \0€ \ç\î\Ú!\Ü\íÜ\å=$2Ê¹\î\äôt¯ùx4–•ØŠP]U—DÁU,VˆØ‚«%‘%•‚\âI7†\åd£ƒ*¡Ó±\0®u¦H*&\n‚Q%‘ T$\n†	’F	=	€H\\m\Û+£¹\ÍqˆGEÓ¦n9ÁÅ¯Ã‚O\Ü\âXŒ…õ\Õ.q½\æyÿ\0^\ÌVóS““\Ë-”™„˜\Å\Ğ^\Ïl~1\Ì\Öz%:©Å‡öG{4YN\ÈÇ’ĞŒ¬—LY²\×\Óa\Û‡š¬*„\Õ\âA®­mòÍ¬\àQ“³|\ì\'Rvwr|y\Z¶\Ô\ËQŠ\Ô\áuµµ|µ\0ù\\\àCHu\íÀ­+i\'±\ÎÚ‡V¹R\Ö\ÅQ,L•’µs[#=W€l<´x/\ÜSk\"¤°¾Š	(¿Šf\ì\Ö#.\Úa\Ö\ïd>\È\ÜG\Åcô\ÙYy~üÏ¬i[’&Ûƒ\0ø-b°°]¼•”\0@\0@\0@\í\æ˜G´U]µš‘ñŸ\ì>\ãÿ\0\ØV6£»Höh\æ+£µZUM0 ºdÁUe‰´¨,UUh$Hˆ+6]Y\n¤’BS$`’@ª’H$ô‚‚M¯b4\îş¯\èV\Ôy~½\â8•A\ÍQ3¹]ó^\Ò>h¦¤‡¼<—b1|F·¥¦§\ï3r\èœ4\î´®¼‚’r=¾Î•\r·(¨\ã\rc\Í\ç\ÏÔ°\ÚÌ²\Ğú!R\ìùš\ZÖŒ\Îs¼TÖ’øN\ÒU×«•‘K}\Í•Ñ¶*R\É\0¤\Ì\Ùÿ\0XsXœ\İ/a¢\Ş+\Ï\'œ³7–\Ì!Zš <<R<P\çcT¦£k\îL§s|‹ˆoæ±¿„¾e%\ä}BŠØ¹\ê\0€ \0€ \0€ \0€ 9?o”\á\Ô=UµeC\âö9·ÿ\0(Y[Á×¤~&q\æ¬\Z;\Ó&\ÕF*\Ñ ª\Ë\"`ª—D\ÚT2I‚¡–DTeŠ€ª´Y2`¨,z\n‚I‚„\äö\ê	=CD…FÜ›6\äù&Ir]7i©öw\r¬\ä:¶v\å\ÄhE\Ï@»t\Ô\ÉóÁ\ãv–¢\rtEœÀÜ›O^«\Ó<P€õ£1\à_©²-\â¾Ç·š‡Ñ°\Æz<&Cš²Qİ±¶\Ê\ÎIr\Ë\Âù\×ğ<#g6N—x!\Æj\ê \İ\åL\İ\é\Z8›rhY·—ò8§\'dº\Ş\ë\Ëüœï´©)Y\âQEsoÛ‘\Î\"\ÍC\Ë\Åko\Ò\Ë\äÑœnJĞ¹\0ğP\nE\Õ{¥\Æ*¦<\ß²\ï?%›\Î(Œdú%lH@\0@\0@\0@=\í¾&\Æ	ˆ\Ö\Z¸\Ü=¦\ßUK>£Lÿ\0˜pv•\Îz(¨\n«.‰‚¨h‰¡—D‚¡tI¥	*¨YAdTT²&\n‚Ç ¨PXPJ$\n½®®(¡y\â¦+/wY\İ\Ö\å\èkûqPú|nj\ni¤dP5­!®\"\î\"\æöó×¢	G\'\Ë[t\ç,¶k=|x­Œ‚H\Z \çf\æ\Ãğˆ\Ã1JX\áœ\ét·Ke`üO\ïK3D\ÇûGÄª]484®§‚Q•óå´³øG¼«¨/3^”h\Ò9Ï»\ç<Iq&\ëBJjI<P¸ ) ;wû>S\r\Ô\Ó\ÆWºşM\rÿ\02\Å\ïoĞ”–>gp[\0@\0@\0@©v¥û`±}.cŒH<2¸\ÍV{\ÄÒ—‹ó€+˜õ0UYtM¥P\ÑC.‰¢«,‰ ±6•±0UYdM§ERI‚¡’H(,HAP2J\èJ3;\"7˜õ8<\ÏÁ^¿ˆ\æÖ¬\Ğ\Í#n\Íö\Ãÿ\0¿şP½j¾|Ìd\ÌÔ©\ê\0€ğğBX.õ—–®¼\Ó\Âù\'¨1ŒGr\ë\n0‘#g¡\Ù\Ê,,GQ´o2Já™˜t\ï»÷\Ü=Pª\ä\ß\ÂQ·-–ÆŸ1a’CCX^KZ\rò‹\è.®\\¦¤ 2€ú\'°JaÌ²R\Ów\çuÏ‹\Èÿ\0*\Æ;\Ø\É\éxÏ‘\ÕV\Ä\0@\0@\0@\0@aöÂ˜\Õ\ì3N\Ğ¤¡™­¿\\†\ß‚\Ğx’g\Ë»3\ëª\ågªLVhŠ*¬\ÑU–DÁUe\É ”L‘ T2È˜*¥‰‚ ’`¡)‚ª\Ë‚ \"WPX\Í\ìoÿ\0\ï\Ãû®ù+Ã“^ñC4]¶vm­Åş\à€^½_>mòa„ ZV	*#c‰\Î\r$\Ø(ñ\'O„0Rl\í1\Î!²\ÖÍ¬\Ï\ëoÀ<•{¶÷f})¼È¡6¹§}n!P\ÊHœ\âak†g\Ì\ïšu¥²D\ç|\ZkÁ·j\åŠhHPt@Sº\êN\ÈiM6\ÈÒƒ\Çu>v\Ì‰e_-ü\Ë6ğ‘½-J„\0@\0@\0@\0@BV	\"{.\Ò@|„b};\İš>\İ\æ\Ócò\\²\äõ£\Â$Ò¨\Í*4ªš&Lº&\n«-’@ª–DÁP\Ë#Ğ ±0T2\ÄÁP\É$\n‚I£\0•\ÔLô™íŠ±\Úq\ÅZœz\í\éÁ¡m‰Ú¼X”õ\ë\Õğ#\ç,Ã­\n„$\n\ÃÁ^„W	?Œ(\ÍW‰at0º:H\ÅmS\Å\ßQ ´pÏŠ«\ê‘N–k³\Ô\ÍU>b\ç\É!\Ç[xt\nVb”‘µ!\ÎûNƒ€óSR²r\ÈÙ¼‘‘ó{ƒ}\ê>¼Øˆ[\ÏSˆï”’ø÷{¿\åY\Óğd–lR\0€ \0€ \0€ \0€ ”¶²œ\ÒmN1\â\Ú\ÙO½\Å\ßP¹§\É\êTüÆµP\ÕQš\"aAdL‘ U\r0 ²$…‰…’@ª’‰ ’@¡9$ “ĞŒ“?±øüöŞ¦œ]¡ı©\Ï6™\Ùö—?û¹?ˆ¯^\n>uòcÀ¸¸\à\Ù\0\Ø\Ş\×PL^Cœ\âr\ÛÃ¢\"Ó—T›\Æ’…I\ÆC;\Ä\çp„\ìWd.š\Îtk9\ÏÀj3‚TSó.Z\Ø\é\ã9\î\Æ~{\Î>=<”-j&l£3\"lmn‚ÃŠ²X$·R€A\È\ÌH\Ç(!üu¿½V_\×\Ø{¼\Z¼/qó:ŸšŠş&E\\\0@\0@\0@\0@4v«M\è»Šú®d¾ö\És\Ù\É\èPój¡fÎ„LV]\ZUK¢@¨,‰‚ªË¢AAtL(,z’LRQ …‰…RI “Ğ Â÷\è=\"w\Ñ^œ=¢ÿ\0“õ9\Æ>obg­d\ß\ÆW¯…?.K¬@BO\0.tB¸ i6°{ü}VùõU`­5K\"qûI-bó\ËÀ&2=\Ï7y¹V\î{P’$¨\'-¬!€\Ïl.›kpğ\Ãl®s‰òiY\İı61“\ëªfn\é\â`\ÊÀ>D\nˆ\0€ \0€ \0€ \0€ Ÿ;r§\Ü\í»eó\è£yö7è±µnviŸ‡€\'Z&\Õº&pX›J‚è’†‹\"@ªš&L²J\ê0I0 œ’	$\n©dH(,zƒd\Ø-q\Ó~—}Ç“‡´_ò—¹\Íq\Íq¼Dõ«—ø\Êõ\ã\Â<\Éd¬@@Û‚U‘Q}x•>jHI\"l=¨r@Srnİ\ÓzF×²\à±X_‘sš?5›\á|Áõ:\Ğ\0@\0@\0@\0@ÿ\0h6BpŒUŒ¼m\ŞSJ\î„\Ù\Ìöhÿ\0xT±e\Ñ,<€.vw¢aAtH*–DÁPYAt\É«‚\é’AdÉ…‰´¨%\İ\n¤\ä˜*	\É\ê‚rm–nS#K‡£»·0­¹\æö¦{•‡\Îc‹›\âµÇ­L¿\ÆW­\â2Ó»Ô«x€!\"\Ê\ê\Å \È\à¦¦I*\é™P\Æ\Æl\É\r˜S\×\ÉV\\°¹,\ÄÛ…ôº”Aq²¨v	Fg\Ú	f\ËvµÍ¹\è\Z¾yVr\ŞH”}\Z8-\0€ \0€ \0€ \0€ g\n¢\Æp\ÉğüF54\Í\Êöoh<Š›[£ç½\ØJí’Ÿz\Ìõ8\\‡\ì\êm«\áC\ãÀ¬%\ÔÚ¥³\ä\Ôù¬”\É²&\n‚\ÄÁU.J\êt\É,ªX*dĞœ‚ ²dÂŒ’\n\"@¨$\Û;:ı39‘\Ö\ÆÀq\Ô!\æv–ñŒ|W‰›\âu‡­DŸ\ÄW¯\ãªÀ \n\0@z€)@ `Y	\'--KX\ÙM4\Â\'\Û+\Ìn±ò<\nµ³\Ö]\0¬\Å*!’*W°\Ç	~‚BH$ı‘ª®<Y\'\È\íŠ\Ä\0@\0@\0@\0@F®\Zªw\Ó\Ô\ÄÉ¡¾7·3\\\"´N\Íf\Ùüø–\É\'Â¯w\ÄIs\é‡\Í\ÍñÔ|\Ê\Æuù£¶›ó´zb$2\ÄÂ©tMAcĞ º$\n†X˜*$Ò…‰’`ª–LPI¶vv/‹T\ê6œ¹\Ç\Â\êQ\æv¬ºk®v9Mi½mI\ë3ÿ\0ˆ¯^<#\Ç(\0@\n\0 Y@ “`	\'@4 ì½švJ\ê­\Î/µp¹›:\Zh_\Ğ\É\Ğ~Ï¿¢½´\Ğ\Û\æ=\Û@\rnQa\ä’«Z\Ö45\rh\à\0°@z€ \0€ \0€ \0€ \0€ .nm¤X‚€ã½£ö`ZdÅ¶bÜ—TP·\â\èş­÷,§^x;(\Ôc\Ã#’‹\ÜXƒbW;;“&\n©tL(.B©$‚†Y\n	$œ’Y\n¬²%u›Og\îp\ÄjÀ\àiõñ\Ô+G“\Î\í,tE¿S–U\Ô\Ìz\È\ï™^¯‘\ã€ñ\ê\0€õ£7$\ÆH\Út\Ï\'\0„nN†««Š’‚JŠ™•‘FÛ¹\Ç\É	>…\ì×²ªmbx\àeV+`Y\éüº»\ÇÜ€\é¶@z€ \0€ \0€ \0€ \0€ \0€ ,€\æİ£vm6d\Å0@\Èq>2EÁ•}\ãÏš\Îp\ê:)½\ÃgÁ\Ã\æ†jiä‚¦)!š\'>9•\Íp\äGU\Í%ƒÓ‹Me¨i’@¡9$\n©)’AdH($˜B\ÄÁPXô(d£i\Ø#j\Ú\ÓÒ˜ü\ÔÇ“\Î\í\áó9Tº\Ë\'ïŸšõOŠ\Ä\0	5¹µXq=—£P=˜Ù¼Oj1A„S™d\ã#\Í\Ã\"o\âq\ä>h¥ö`pÍ£û·\Ä$m§«x\Ôø4}\Öø 6\ä\0@\0@\0@\0@\0@\0@\å\Zv\ß\ì\ÕS\ï£-¥\Å>Ê 7Gş\Ëú#O#IÁHÚ«o\äpW­Áq	°üRCU®\Ş ƒÁÀóª\å”\\Y\ê\×8\Íe¡P\Ñ\n(¨©l’²’A2_$‚‚ÈPI³l8û|A\İ)şª\Ñ\äóûC\á‰\Ë$ıc\íøŠõ@¡7J÷°5Çº9 6Í\ØKlªsGzl63ij\ÜÛ\İgW|—@}+³;;†l\Ö\Z\Ú&œE\Õ\Î:¾G~\'e–\Ü \0€ \0€ \0€ \0€ \0€ \0€ \0€À\ív\Ëa\ÛSA\è\Õñ–\ÈÛ˜j#<G¨ğ\ê9¨qM®\ÉVòŸ6£f±˜\Ä}e\Ú\ë\îg`\îL:‡¨\â<µ\\sƒ‰\ëUtl[rbXLØ¬Ğª2IAd¹\èBÈB\ÆÏ±O)Ä¤„\ÖS\á\ç¡S¹\åö•±Jg*®\ï2½C\Ë\"€ ¨vk\ÙMN>#\Å1ñ%.pcƒÕ’¤•‡¯\Ê\ÜPBP\ÒS\Ğ\ÓGMG §¹Yf´x\Â\0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ 1ø\ÖEaóPbp6jy9O\"\":…\rgfZ2qyG\Û}Š®\Ù:ıjp\ÙhªCui<\Zñ\Èøğ?\ÉeMnR›Õ‹“[k…¸…Ò¢H\\F\'¡Al\0@l\Û}\Ş(G*cõW‡\'\Ú\ÂG*&\äù¯LòY\â\Ë_DH£|²2(˜\é${ƒX\Æ— \0s(\íÙŸdl¢\ÜcSdª<4.lG‘\âw‡\ã\È\Â@\0@\0@\0@\0@\0@\0@\0@\0@Pª¤‚®šJz¨™4´±ñ\ÈÛ‡È…e<£‡vƒ\Ù\Üû>eÄ°€é°¯ZFj_L9ù°u\åñ\\\Ö\Ó\ç\Ô\Óê”¼3\ä\Ñ\ëê¹š=$Ê€ª²\è˜*AB!£d\Ù–›?ûsõZC“\Í\í´NW}¦y#Šÿ\0Á\ëñ\ÌJ*.œ\ÔT\ÉÁ£€\É<€ñ@}Ù¿f´;\'++rU\ã$w§-\î\Ã~\"?ş\\O€\Ñ¿ad¨\0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€‹š7@r\Ñ{7trIŠ\ì\Üwl\ÓQF5\\Á\Ó\ÃÜ¹\í§;£\Ğ\Ójú|39cJ\ähõ£,¢«\\«ƒD\É\İA,\Øv_J]Ü…?\æ¯O+´¶Q9hÕ¡zg’l›±¸®\×\â‡02\È\ß\Ô\ÈH‡\Ôô.(¥ö7dp­’ ô\\6+\Êğ7\Õ/i)OMxp\r„p@z€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ \0€ 9\ÏhœCŒ\ï1\rŒ§\Äx¾/U“şNñ\çÏª\ÆÊº·G^ŸT\êx—¨†jJ‡ÁU\áš3•ñ¼X´®6±±\ì\ÂjK1<P\Ñ3g\ÙpüfY\\l\Úcf{›müñS\âG\Ú\ÊrQP1}œvg_µoŠ¶´>“\æR,ù¼:~×º\ë\Ô8£°l&‡\Ã\â\Ãğºh\é\é¢k-¯2z“Ô /\Ğ\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\Z¦\Ú\ìE\ÔS—\Ú|Aƒ\ìªZ5òwQòYÎµ3z5¥\åpp\\g\Ä0\Z\×Qben·\â×­<\Â\ã”^\íUtlYFwaò\ÏM#\ÄòEa\Z8j=\Éº8õÏƒ\èXcd0²(X\ÖFÆ†±Œ\r€z”M\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@xEÁN\Ñl\æ´t^‹‰\Â\ZoƒG\Æ\î­?\ÈQ(©,2ğ²U¼Å˜}’\ìÿ\0\rÙš‡TE<\ÕS\Üt\Ö@sñ*‘ª1/mÒµ\æF\Ş†!\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@\0@ÿ\Ù','image/jpeg','2026-10-16 23:36:42'),(2,_binary 'ÿ\Øÿ\à\0JFIF\0\0\0\0\0\0ÿ\Û\0„\0		\n\n	\r\r\r \"\" $(4,$&1\'-=-157:::#+?D?8C49:7\n\n\n\r\r\Z\Z7%%77777777777777777777777777777777777777777777777777ÿÀ\0¿¿\"\0ÿ\Ä\0\0\0\0\0\0\0\0\0\0\0\0\0\0ÿ\Ä\0Q\0\r\0\0\0!1AQaq\"‘¡±23RbrÁ#$B¢²\Ñ’\Ò%4Scds‚”\Â\áğ&\'CDE£ñ5TUÿ\Ä\0\0\0\0\0\0\0\0\0\0\0\0ÿ\Ä\0(\0\0\0\0\0\0\0\01!2q3AQB±Caÿ\Ú\0\0\0?\0\î \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0¦J\ä\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0(\Şs‚\Ä\î;!\Ç\ÄÒ’\\\Ù	VK’É¤\Û\â\É\Z\ígj¹Iö±gRR•jueJXO¾-&Ÿ\å\ì(F\Ù\î\ßUÚ¥\îr_\Èeš\02 \0\0\0\0#9¨&\ä\Ò]\ìBJqŞ‹M>X@\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0””W$ZX\Ç)qeª•›\á´jb•Y\ÊSy“ö*\Ê\Z\Ò%d L¦•G\éV\Ôt\è\íOK’õ%(Ö§%˜Ô‡\î\æ{x—jú.\Í\Ûİµ½\nW”\ÕE\ß	z¯\æKö{¥MŸ\Ô\ä­\ï\ê\ËL¼\ä\é\Ü}ü\'\Ëßƒ\Ü[\İ[\ÜÁJŞ½:±|œ&Ÿ\Èùº›§_B\â\Îşj[\Ô\Å*\Ğ{³\Ü|W\Õ\Ì\Âşö®me½¥k5\è,\åE\ÊQøÅ“´•õ!IIEfM%\ŞÏ—·6Îœ\\a´•·{ı2¡[N\×\î—\ë\ÛC^¢\íNµI~c²®\ßO­J\Å\×T#yn\ë>PUVóöº¹ig•¿\ÖTû1\ì>h·\ÙûKzŠ´\în*V‹Êœe¸\Ó\ï\Ê\âtM\"ı\Ü\ÙÓœ\êJsú2o›kµ\Ä\îz\ÛıV\âş¤T\ç»ğ¦]¤6\ì\á¼ø¤sûI\ïÖ¤±Ÿ5\ät=6)ZC¨¹MEŒ \Í@\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Q²\İIğõD‚µ*(ğ\\\Ìy\É\Éñ(\Û\"t˜³j Ue\n²„UcÌ¸[2\àG\é~\ß\Ò:=\Õ{\é\Æ5²Hö(\Ğ\íõs±\Z\í$²İV—Š‹k\äAÁª\\õuiW\ã½ZŞ›—¸Ÿô–?iû\Íui9Xi\Ó|\åiƒhÁ«&™½9Û¦òZŒ\í*jIvš)Õ’\í1\çV_i3\Ü\İUÔŸc=F\Æ\İÊ¶ŸU·\Ú\Í/r9¼§.ó\Ül$·4º²µY\ãÜŠ\Ö.›£~’½%\à‘h±o\às™ı\Å¹´tš+\â¼yº\ÄÀ5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\nd©j£À‰T©,¼™\",\é\" ù€ùƒL€ZŠ2…YB\æ]\\‹K™q$cj´UÆ•{Aò©oR\ÛŒ”$·¢\âù>–\Ş\Ğô\É5†©J=\êlÀªÍ¾£K\Ñ\ìUc©»º§î¨¿™¤¨Î•\Ç.V*3L½6Y‘{}õtˆı\ê’ù!³\Ûì¯«¥\Û%ûM¿ˆ\ÇY\ÙoV§\á¢Ç’G‚Ø¸f¦WrÁ\ïQÏ©Ë¦*€m\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0š¼\ËÅŠ\ÍG‹i$¸\ä±+Q¥jW:£k^\Ô-äº™C9qÌ£\ëx\æ/‘³g™Ğ«Ô«­]U¡Æ•IÏ¬rM\É\Å<\Çq™vó\ÏfLÎ‘˜ƒ‚(T£Te\n²„E\ÅÈ´]$Q4Alƒ\æı®¥\Ô]\ë»)\ê\Õ\ÒğŞ„dy*+\ïúJ¡\Õkš\ì\çy\nŸÖ£ÿ\0#ŸTgl¸9r³\"Ô‹’-H\ÊDY\îvY~§i»Ÿ‰\áY\ï6WŒ-c÷#ò,\ÇhØª~®|‘\ì\Ï+±pı]>ö\ÏT]OS¦*€m\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0=\İ8V¥:5iÔ‹Œ—zk\È,\Õ\æX•ƒcak§Æ¢µ¦\ã\ÖKzrrm·ŒsfD™.\Â2:2ƒ\0€…£(\n\0.EğE¢\ä92I{\n@Óˆt³Kshµ.ß£kS\Ï=d#•Iğ;/L¶\éj’­5,¨¯\êÕ—ö0ò\ÙzqpË”$\Ëm“‘m˜X‹\í}Ç¿\ÙXş±B\ÑKÜ.)£¡\ìŠŞ¾\ÇvM\àÓ¹\ì}<YB^¢4\Û/\r\Í>Ÿ\áF\å|ıN¸ğ¨\0Â€\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Š¿H¾X­ôc\ÊU²2$\È3£*\0G%Y((\È\Èr-—)4K$Q$Š9‡M4ÿ\0CBªÿ\0õjG\İ:oùœ&¯\n“]\Ò3\èN™i\çA§Q.*5W\î\çò>z¯Â¬óö™\Úı¼k…æ­²$\È3­\éEw´‘±qŞ¼o\Ï\æsšk\Ò_}|Î›°\Ífü6«»hİ°§øW\È\Ù#I\íœšys\æº\Î\0P\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0±_\é\"ó,Wúf±\å*\Û M\í:0*D‰VQP\0\0¹L¶\\¦\n¸Š”EKQ\ãzY£\Öl¥Yc.;ÿ\0Hù²\ãë¥“\ê‘iu»%v»–#\åÛ5[\ïK\ävÿ\0T÷r¾¥¦E•(\Ì,\\µY¸§ø§\Ñü34û\ÜQ\Ëmnaÿ\0]‡[\è\âô©?¼½?\Éyvû‹hy%›eŠO¸¼xò\å\Úp\0 \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0qôÌ–b\Ü}3Xò•i°\nE”*\ÙÌª‘FÊ¾DX\â€	§\Ï´\\§ô\ĞyE\n¢\Ôiv\Òf\Ë\ê+º–O”\ëğŸû(úwlö—Dµ\Ónô\Úú»¼¹¤\éÓ¡	\ïM¶°¸.GÌ—±p­‡\Ïi¿ñ|¹e\êX\"\Êä‰…Œ‹ñ¨ø&şd\èÆU<œsOY¹ÿ\0e·£\Zx…&\Î\İ?M§\å\×\èğ§\à‹„`±Hğ»@\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Fb\×ú\Ã,Ã¯õ¬\Ö<¥\áŒ«\"m(\ÊPŠ6D>`\0qx@V<‰)Âšsœ£\Åe\ÊO	;kºC\Ñ6f¥:\Ê\êõ.\Ô^Zyöÿ\0iv¿¤K\×gaF¯£·‡olœiÁ}ù0i\Õ6¯¥Ÿ\Ğ÷\è\Ù\ÏúF\î9[”¨ŸŒWª\íş\ÙmÃ³\Óú\èSŸª­túrm§\Ş\×o\Ö\ì\ÇC6°P­´·R­.~‹l÷`¼¹¿f«£\év\Z=º·\Ò\ì\èZ\Ñ_³J	g\Íö”qM˜\è“i+W…ş¥:;²SP«\':²k±\ã‚÷œûUM]I>i\Ê/\ÍI£\ë\èrHù#h\éu:\Õõ<}ª\Ë\İRGI•\ì\ís\ÊM\íª|Še	\Ì\Ò\ã)\İ(B.R’ÂŒV[\â¸Gts³—z}\Z÷±t\ä\ã\Â¾Ó’t)\è4ö²\æ\ëS•([\Ú\ØÎ«•G\Â/z+?·\èºû\Ö\ï\\­¢\ágŠq|¸óÈ½\ÙvÙŠ\ê=R*\æu\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0:ÿ\0Z\Ì\Ã\n·\Ö\È\Ö<¥A”\ÉR,\Ò(È¶H‹€£j)\ÊM(®mòG6\Ûn–,4}û=röñp•M\ï\Ñ\Ó~}¬s®kzng+½R\ê\nk’oŒŸrG\Ú^’õ½§¹zN\Ë\ÛÖ¡F«\İJŠŞ¯UÂ‹z.\Ã\í6\İ]\ÇV\Ú[ª¶–³õ£:±\ÍIG\îC±x¿‰\×öwfô­›µô}&\Ö4³ô\ê¾5*~)v…s]“\èŠsq¼Úº\ï\Ö{\ÎÊŒø¿\Ç?\É{Î«§\ØZi¶µ°¶¥oB?F(\î¯ùûL—È¢\ä]\"p2)˜ğ2)—Bü9Ÿ*mı>§kµZx\Æ.\êüeŸ\Ìúª\'\Ì},S\ê¶\ëTX\Æk\ï{\ã9bÇ\0\ZFEœœ*)E´÷\à¾\'\Ñı\Ã—„\"|\áf³Vš\ï­ó>™\èö-\Óòù§—K#ó\à\0x]€\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0aVú\Ùy™¬Á­õ²ó,Jƒ\æE’|Š6¢œ¤\ÒIe¶ù#h¡¥\ÚM§Ò¶j\Ï\ÒuKˆÅ¿¡Iqœß‚<f\Üô©o¦¿\èí¦\ï/\çêª©f~iù\Z\è\ÓV\Ú;\Ïé¹¹ª£?YZ\ïş’^b>ˆV»Q\ÚMª\é2òz~ƒo;m=?_\ÄR\ï©>\Ï${½‰\è\ÏIÙµN\æ÷vÿ\0R\\z\Ù\Çôt\ßÜ\æ\Ïe§\ØZi–”\ìôûjV\Öô\Ö#N”p—óó2\Ğ2˜\ìšˆ£(U”p2 cÄ¿\0/Ç™óMtú½º½ï’§?|ò>ó\ÏO÷6Ù¾\É\ÚÑ—ñ¯\ÈNR¹À\0\Ó\İ*;×–ş5\ãògÓ›\Ôÿ\0®G\Ìú\Zr\Ôl\×}lû‘ôş\Â\ÃwN‹]\Ç[\åĞ´şQ\ê@‰\Ø\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\00*}9y™Ï‘\â:HÚŠû)¤úUµœ®.+\ÖTh\'\Ë}ò\á\ÚX•³\Ú \Ó6v\ÊWz­\Ìh\ÓI\â9õ§\à—i\È5\r Ú“oga³´§e¤\Æ[µj¹8\Ç~KøQ ô{­m]\ìu½½º­I\ïB\É\Ë\Ök¹ı…\á\Ì\ë66Vºm¥;Kjvöô\Ö!N”p‘±\åö+`4­”¥\nÑŠ»\Ôp·®ª\Åz¯·q~\Êø±²¬‰b\0>E\n‚™”A„\Ä_¦X2ı0/\Ä\àÿ\0\İ	MCi¬jcKş\ì\çü\Îñ‰tU<jz%L}+z±÷J?Ì“”®>(Œ6û7\í^\Í}ù?‚>¡Ø¸n\étüb|Ç²±\Ş\Ö-?\Û#\ê-“\î“Gğ#¯S\Ë\Ãü˜ú\ÛÀ\áv\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\re\å*7UiT­F•	9R”£—	c]\Ï\Éòf\æü\Íc6ˆ7ÄŒ‰2/‘½\"$	>dX€¡EH\È2€\0).Ä¿L±_¦A~\'\Zş\è\Úow@­Øx?ş7ù‘Ÿû¢i\çC\Ñ\ê}›©\Ç\ßşA(\0ua\èv6;\Úİ²\îŒşhú‹f£»¥\Ñ\Ï=\Ä|Ã±1Î±KÂ›ş$}G¡-\İ6Šû‹\äu\ëyx|}\Ó¸\Ù\0¸\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0‘¯f\Â_EšöoE‘d™	\ZD2…[\"\0£”@À0Pvøğ2)_‰\Ìÿ\0º\nŠ\ÈY\Ôÿ\0\'}ïŒ‘\Ó\"s\î!½°R—Øº¤ş8ù\ÌÀuŒ½VÁ\Ç{Xú¥üG\ÔzJİ°¤¾\êù1ôw\ë0üùŸO\Ø,Z\Ó^_\å\ĞÁŒ>\åe\0\Ğ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0O¡/#_\Øg\Õú¹y,\Ş	PdeÈ“##h¶\ÊdXd\n²Œ\n\0\0\0\0¹\"™\"˜\æx›)õ_}Ú´¥\î’=¼\'\Ò\ä:Îõ~F—\ï##\åöP¯á‡·\è\Ú9\Öc\åñ>›³ÿ\0‡‘óOE\Ñ\Ş\Ö\á\ç\é‹eŠ0^oöºq—y/\0\Ğ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0·_ê™„\ÌËŸ©f7ŠTYM–Ù¤E‘d™	\"-”@\0ª( dS1\àdS\"œ\é:gGºò\î¶o\Ü\Ó=M6\ŞC¬Øvö5_î™£\ä\Ä\nG’*ubºE1Î»Ä¾HúR‡\Ô\Ã\ÈùÇ¢H\ç[§æ¿…G\Ñ\áJÀ\ï\ã½=?g>‡«?tÀ\Ïz@\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0n~¯&2\îş‚ó1\r\â•[‘q–™¤El”ˆ2ˆ€\0\0\0\0\0¹FDxr2)‘]µtúİ”\Öaö¬k/\Üf\Â>µ³D\Ôiı«Z«÷š>:OM¬ğ2o\éB…\ÕHRmÁqy\àÆ¦””c9n\Å\á9c8]\æN¡*U.ªJß$ñŒe.\Ü\ZŒº?CñÎ³o\ÉD\Ã\èG\Èùó¡\Øÿ\0†¹r\Şü \ãôW‘\êñüa\ì\ã\áù\Ë\İ óŞ \0\0\0\0\0\0\0\0>\0³sW«‡o\Z¶\Ğ\é\Ú]EF\â¬\ê\\5•oBœª\Ôk¿v+‚ñ|\r+\Ú]~ó?Ñ›-Z\Î#SP¹…®ıÕ¼\Í\Ì#NsŒ#Tyœ’I\Éø÷ûJ¹\ã´\×jmkw´Ó”]\å\r\"„3\ë\Æj\ÎXğ{©¿K¥JS–\ê‚\Ël\×Õ¨\ãJRŠ\ËQm.ó_­S•ŞyJ—Ó«m\'Oø\Êø\à\Ş8n\éœò¸\ËcĞ»¥\Ù¯2\ç¹\Z-\Zû\Óô›;¥,ª\Ôc?™¾û\ÅÃ¶\è\Ã.\é+?\Ò_r)\é\ï^\ã}•\ßd\íkl\ïHŸz÷ô‰w¯q…¾\Êo¾ñ¨m°ô‰}Ò¾‘\Äk÷\ÙN±÷“Q6Ø»\ÊPI\ÕjmE6û_$[»ºš§8\Ú:}v=^±=\ßn8ch\ëN¥}\"\Æ-\æ\æö.\\f	\Íü¼j\ç\Ö\ÂË¨â½†\ïORW<z¶\åf¸`\Îÿ\0k\è\É\î\Øh·\ìÜº©NO\Øã‰8mMİ«Æ±³ú…´{k[¥q\İõ¾\Å\ÕQY“+N¼fø6i\íu\Û/NÔ¬õ:}…\Ä+\Ó\Î‹\äûš\ì~\Ë5ŒhÕjP‚©,o\ÉEfiw¾\Óc	)E5É™³J\0€\0\0\0\íú©x˜†M\ß\ì˜\Ì\Ş<%FOm’‘i‘NL´\Ê‚€\0\0T*\é™4\Ìhr2)°2 R\ê;öW|¥JK\à\ÊÀ¹%šrzfhøº/\Õ^E_&F-Áq\\c\ØÌ­F0\İUJ*0o*)a,ø\ÇôÎO¡x\çWŸ‚Ÿñö?Ey\'¡Xÿ\0„\ê¿	\İ\ÏO\Ô}X{G/\rü½\Õ\0=\é\0\0\0\0\0\0\0\0«¹­\ÖU}Ë‚2\ïjºVòk›\à,\êMuq¤“”\Ş3.QXo?{Mc®\İÖ•+Z“†7¢¸xx–U´úö¥qu%öÔ’^X,Õ\åZU#½Bµ)E§E\ÆR\ï\Ã\Î\î!+\êŞ‚š\àß«\×aq\ãŒ(ó\ß\Ïwø2lªÎµ\Z•>”£\Å÷ø’·¡Jò§)s\â\ß\ÌÄ£ºT¡*6ô\ÒQŒ\\¤—f^q’õ¥i\Ôu\éUk~N­´±½ÁI<yIÍµ{ú½>\â\Éó²»«C\Ë;\Ñı\Ù#z\Ù\æô›ˆQ\Ûv\Åp\ë)[\İ%\Ş\Úq—ğ\ÄôO™Ó­\ë\ß\íË¥5’\ÈL‚*s±<Œ\È\È\ÉB#˜F’£ô­µ¡\Æ66R¨\×tªK\á\ï70¡NeUG“\Ëy#\Îl\å\Ä.5¤½\ŞÊ…\ÔhG\Â4\é®ü›©N\æJu\"\ÜTsœ(µ\ÃÏ\È\ë\Õ\æOÓ[ÿ\0¬Š\Îpœe¦šqYxI¾L-\ê^¬iğx\Â\ßO\Ö\ï\áñ%FnP\ÅD·“Ä—gıq\'ı%\îÓ“«%LÊ³©ÎŸµ\Z‡Z¤\çŠ\r>y\áÙœ?q‘iVy\Ì\ÒSƒ\â\×iœ¢·H‹\ÊM9¨\0\0\0\íú\Éx²2.Ÿ\é}…‰\'	V\åÈƒ&\È6TBD&\Èe2Q\\•\"W8¥Jp2)˜ğ/À˜a\Íy– ^š>5º§\Zz\Å9E¸B´ÓŠx\à¤øÚ¾‘yV¦â¦¥?V\ÎaZU´\Z‚|o*¯\ßfi\Õmrr\ànO$v^„£½Z_qÿ\0Ü#\Ğ|sq]ı\ßø™\ÛOO\Ô~\æ>\Ñ\Ç\Ãq—½H\0|÷¤\0\0\0\0\0\0\0©\Õ\êúĞ¦¿g‹5ósNœ\é\ÅJPyqo\Ë\ç\Ş]½©\Ö]N~8öT¸\Ï&*\Í\Õ\Åzv•$©FÚœbÜ§oI.\İ\Õ\Ë/\ÌÇ…¥\Ì-³*¬}emb8y\Îö3¿9\åŸ&\é:¶òŠ[\Üb÷{ñ$ñğ-»\Ú}dš¥|\ÛX\êİ´\Ò÷µ‰¥\\¡u^­\ns\ê©×Œ’”jon·Ú›X\æJš\ê!^½yBsu&ó\êÁ(¥\ÏÁD·g	Pµ£JXŞ„x9H{Zõšš™<\ÚE\â\î´_\ÖK¶šğ\ï÷\Z{ı´¯ıûW\Öô\êT\ÓT\é*‹Õ©M,b]©>y\ì\àûÎ…C¤}\nT\ãéµ	´#O­š”2™\É\ásck˜NiÏµB\Ø/Ê–Ÿ}AÎ›Œ\á\Û(z®/\ÄÕ¶ò‘\ÖH{4ÿ\0õ•ÿ\0\İ*d”zAÙ¹=\Ø\İ\×o»\Ñjÿ\0d\à\×Ö³²«º\ç)SFY\âaÊµXM:u$¸w¾dWÑµv\ËG£N5k;\Út\åôg;\Z\É?&\âc\Ú\Í.wµ\İjd\à5µF½(R«¨]Ô¥£Nu$\Ò\Çr\Éj5*5™NMûˆ>‚ÿ\0´=š_ú\Ê\ß\îµ?²j6‡¤«JVSZ$g*\ÓXjğpŒ<T_­\'ğ8õ”z\Éæ¤<\Í\Ô+\ÚZb5e‰µ\Ø\Ãy\à©^·¢m ¦µ\İ*öx•ôº\ÚNo\é\Ë”|\Ú\ã\ï:œcQFQ\ßmK<V95X84\'e~”\íªb½&¥¹R\rrx:\Ä\íK\Ö(\Ê\ÎûÔ­\ã\ëc‚­\É\Å|\×c\ÛwVG­¦•(7)e·–ñŒö£qF«\Å:°“\íIñ1kIJ¤#7ˆ4òû8~d*9:nu}YSY§ÃŸü‚³q(MÎŠ^·5\Ïùh)A¹I\å¾\ÏËŸ‘(K‰\ê\Î[\ÔR\í\\ƒ_§OÖœ_vQ°9V€\0\0\r\Ï\ÖÈ°\Ë\×ô²ó,3¤\ád$I“4ˆ2-•dX(22\0©L•¨©DT	ÀÉ¦c@È¦L\Ğ\æYƒ.Ä”¯6¢;›Q¬\Ã\ì\ß\×^\êŒ\×Sú\Èş$mö\Ö^\Ùk‘ÿ\0N¬ıòl\ÔRú\Ø~%ó58J\íı,ºÏ³r?6v“t\Ğ\Öv?™\Ù\èú\ŞøŸÓ†ô\ßz\0ğ= \0\0\0\0\0n¼·)N]\Ë%\ÃS–\í¤ñ\Íğ,\ä­Ÿ÷‘\ÉYov\ŞÁG%Èƒy,\İ\ÜÑ³µ«ss5\nT`\ç9>J)e²+\Êt™µ2\Ğt¿E´©Bò-S\Ã\ãNœ¿—‰\Çô\éf¬¡Å=­“\Ú=Z®½¬\Ü\êU²ºÇŠq±ôW»\âÙ­§ZV·Q›\Î\ì’y]«ZÑ££Áöø’„\â®ú\È,)ÁÆ¢\ì}Ì·úµ\ÒUqV2—\Òt°\âı‘‰wNŞŸWIbO±¼·\æM¦‹«—ZÒ›©†\ä°ü\×i€\Û\á²\Ê\Ê;Ğ¥\Çw´­9ÎE:o^*¦º¹\Ğİ­h×§\éFmÅ¯µ”ı¸ğ-JXM—h\Ü\Ü\Ñnt*ºR|\å\Ó\Ì\â\ä¼{ûÉ¡~Ê¯\éh\Å\ã\Öy‘¸§W¨«/¶ù¾\Ó\Îq¢\á>È¾&öZ”\ã)\ï¹%²‹Y~i¢ıJ»\×«\ÓÂ«$\Ú\í^$\ãªÖ°¿õ”·k\Ú\Õ\Ì[\å%\Û\à\×şŒ\Z÷l\á\ê©eöÍ­\ç\ì0c9:m\Ï\éT–XWÑº¯m®iVú…³Nhñx\Â]«\Í3d§””¤\åóŠôS¯=;V–•s$­¯eú6\ßÑ«õ\Ã\ÏeLª¾¥’q|LxÈ»±±+Á¾×ƒryúÄ¢ûO@r\É`\02¡FT£\äÀ\×Uy©/2Ì™9¼É–\äuœ2‹-É““-²Š2\r•‘m€\È\È\0UDJ¦‘\"šp2 cC™‘L˜¢Y¦^‰)_&ô…İ¹\×\å\é“fŠ\×Cñ/™\èºJJ;{®¯ô§òG£õ\ĞüH\Ö?„®\í\ĞJıZ»ğ\ævr>‚W\êUŸ„>G\\G¨ı\ï‰ı9xoG\ÍH\0x^€\0\0\0\0\0\0\×\ëı#\ß?\È\Ø\Z½eúô—ƒeÇ”­L¹–¦Ë²,Í’#“t·­*V4tZ2ı%\Î*\Ö\Çe4ø{\ä¾¿œ\Ô#)\É\î\Æ)¹>\äp\r¡\Ô\å­k—š„Ÿ«Vx¦» ¸E{—\Ä\rd!œ¢°·\ë`\á4ü›j.¥U¸·„—\ÓK\Ø\r~æ‚«\r.²Œ¹uG>\Æ\ÉlG:zlÔŸWSÄ½o¦¨<\É\ï?#¤\Ô\è÷_‡ş\×QùJ/ó,Kav‚)¨\éş\Ü<\Ş­,K‰¯\r<gÁ\Ş]m$^—_\àEôy´xÿ\0ñUş\Ü5^>¤·¡G¥\r\ï\Ú\\\Ñj0\ã“\ÙG£İ¦\Ë\ß\Ó+µØ”R\ÇÄ’\èóhÿ\0şUr†J6ñœ0\ÖS1*imK4\å3\ß\Ñ\Ø-¤§ÿ\0µ\×ø?\Ş&½</\èš\éöòşdò5\\Ş™(¼\Î[\Å\ÙS”¦”—«GI‡G[@\ÖV›%\ç8ÿ\03K¯l¯£ÁÕ¾±«J—ùLf+Í®E\ÜMWJT\å\Ón3‹R‹\îk“ùódµ•®\èV×«cN5—t\ã\ÂG\r©O\Ó\ÙtWªz&­_L©/\Ñİ­úkü\äWzş®\İe2\ä>%\Ø>!Y”™\èhKzŒ\İGœ¢ø›û›h?Qc \0aB3x‹ò$[®ñJoÀ\rc\äA’\ì \ÎÑ”$\È6U²2dC\æP\0)’ T	¢¨†I .ÀÈ¦cÄ¿M•L½\Å6^‰)_+t¤±\Òº¿\Ò?á‰¡¸_\á	~3\Ñt±Ş‘5¿\Z±¹\ÎV”g\'”\çÁšÅš\îı,iµŸ\áùh\å\Çü9wµò:¹\×\ê}{ğÇ†š\Ã\æª\0<n\à\0\0\0\0\0§\Ö_é ¾\é¸4º\ç\×\ÃğšÇ”­d\ÙjL”\ÙjL\ê)\ÒN©ı³\éB[µo\Z¡Ûºø\Ë\àšöœj\Ãö)\ê^—´0³¦\ßUcM)xÔ’\Ş~\ä\âkv#Hz\Î\Ğ[Ñ’\Í\nMU­\ä¹/k\ÇÄ‰]_¡ı£gaoQ£^Vy¡¬õ0\ïógO\Â,\Ù\ĞVöÔ©G	B)p/œ›S`¨ \0\0*\0\0\0…JP«	B¤T\á%‰FK)¢`ŸúU\Ù(h\Z¢º°†,.x¨/ü©ö¯.\ã\Â\Ú\ÜÔ±¼¡wG\ë-\êF¤q\àù{Wiô¶\ŞhôõŸ¸·¨–Zõeö_cö<4\ÜÑ©BµZ\Ö\íJrp’ñG\\n\ã\ß-.i\Ş[Q¹¢óN¬\âü&‰\â:0\Ô]Öƒ;9¼Ô³ª\à¿¸\Çó^\Ã\ÚEšXÍ¢øƒNyµ‡ƒg› øKÿ\0‡›1—\n\Ì\0\Ô,]¼[\Ï\Ü_1¯\ß\è}¥‰Zì”Š¶[“:\ÄRL·&VLµ&È¦H¶S O#$2T	dª\"Š\ä¢D“\"‰\"\"\ìY‘LÆ\"ı02 _‹,S/DU|Á\Ò\î#\Ò>¬\Ú\á¿\áG’†\ï¤Gs‚\É\ì:dX\éT\ÇoVÿ\0u2\ÖÁø—¯¡ú\rX\ĞS\ï‘Ôa\Ğzÿ\0»´\ßy\Ó\×\"ø¬»º»N”\ÔT\0y\İ\0\0\0\0\0\0M¯¬J”»\ÓF\ä\Õm3i	¯ØŸ&Y\ÊV†ObµXÑ§:“\á\')y.$§#\Ít}+\r”¾”*UJ„1\Ï\×xoú»\ÌìŸ‡Ô®\å¨\İ]\É\å×«*œ{›\áğ\Âö{¡mÓ³…\íXq¸›«‡\Ùğ½ú\ŞÓ\éö³½½·´¥ô\ëT8û_ÿ\0g\Ôa-.‘IaBŠ\Çó3•òHô\0“`\0\0\0\0\0\0\0\0\0w\Õj3¥.S‹GÎ\'i2°×•Ê\è\îc\ë¬ğ\Ã>g4\é{Fô*µzpÌ©b¼Z\ï\\%ğ5ŠW7\è\Ú÷\ÑvÛ·\ê\ŞRp\Ç|£\ë/\Ì\ë	ñ8•Ü´ûû[\èğvõcQù\'\Ç\á”wˆ\ÉI)E\æ2Y‹]«°ê‘—E«L_©RñY<)`öv\Ğ\ê¨S‡ÙŠL\Æj¼\ï\ßG5LÆ½„§C\ÕYi\äº\ê.ôBUâ»€\ÔO+šhµ\'\Ã&Ò¥\ä8ûY¬\Ôu\Z(Uª¬•N®.X\Î\îö;÷3bÌ¤Zr9®\Òt£ycJœ\íöy\Û*’\Ç\ëœ²±Ç’ü\Ì>™!Œ_hò]\î•\\ü\Ë\İN®gÒ¾\Í\×Â¯é–¯ü\å\åû­ü\å\Ûl\Õ\æ:f\×/’¨\İ7\î’F·¡\ÉT\Ìj7v÷z…\Å*©ö\Âj_\"÷\Ô\ĞØ¹™o>%s‚‹\Ù$™e2qa•ø3\"›1`\Ëğ`e\ÓfDLZlÈ‹%W\Í4/üC\Ô?\r7û§Š£õ±ó=\ÇMkÿ\0\ï¼iRş\Ä\ÛÓ•JÑŒ\"Ü›\à‘1\á+èƒ—ıÙ£\í:r9¯D1›³\Æb£\Ï8:-½\Íš{öõcR=ñfz—y.</\04\0\0\0\0\0\0®h\Æ\âŒ\éMz²XeÒ’mrY\Å\ß[Tµ«*uSû¯²H\æ=+\ê\n¥KM2Ë†k\ÔK±µˆ\çÙ“¼×‡]Ú´#5\İ.\'‹\×:5\Ñuz\Õ+Æ…{KŠ2*\ÎI¿,¯v\rÌ™®S\Ñv•-CicSw{\Ñ\â\Ü<%.	û²}oFhS§ˆ\Â8G\Ø]‰§²“.¹\ÜU«<\Æn8İ9yó=ó\å‚[µ‘0C2\î}\ÆU0C/¸e÷0C/¸e÷0C/¸f]ÀLÌ»†ô»€˜!½.\â›\Ó\î\áª\Ú8\Şiµbá½„ò»\ÓXk\Ülªw“ª\Ö7P)jv~¨\\\Ù\Ïÿ\0&¤¡‡\İ\ÙğÁÕ¶#QZ†\Î[JRŞ«Au5<\ã\ËŞ°Í¦µÑ…¾¯¯U\Ô*\\Ô£Fª‹•\ZqM\ås\â\ÏC³\Û£\è;\Î\Ê\ÂN¤\Ö\'Rµg7/fqğ:w³¥4M>w£Zq\Å¼\åş\Óğ=;Y+\î\Å$”qØ»\n˜·m-4\ËS\ÊfNs†H1d™f¤^35\Ó(\é\Ëõ-¦\Úk]¥¯J\ÓH¡¨i«Ñ•:˜©EpO}s\\xñXñ,\í\Û\Ùiš«°\Ôo.,\ZŠn­8\Õ|{7¥œT\è÷úŸ¨q»´§RK”¸\ÆKÚ¸šú\Û-	\Çv•õÒ‡Øª£^?¾˜\"©±»Em\è÷ºµkø\'¼•\í:‰g½zŠ&\ÇG{}\Æ\Ò\â›ÿ\0\'qù3\Ø\Ïbi¦Úµ\Ò*¾\Ö\ì\İ\'\ïƒF=\Æ\È\ÜB+\Ñt»>\Ü^Õ‡»)”x¾ˆ-je\ØkJ¦¡½\è“hh\å\ÛJ\Ş\â+\ì\Í#ªOfµ(ó\Ğ\çŸó:„ñE%£jùhz\Êÿ\0W^\Ş_ñ¡±\Å\î67j´\Æ\åıuö¨\Ë?&F†­µ\Ú[\Å;­V\ïd·\Úøğ;_¡j4ğıh`¼#N_*…%J\íp•\ryyÙ¹|¤\Æ\Ç&µ\é+k­xUº…uş~\Ú?4“760\ê0Œcy¥[T\ït\ç(g\Øò{\í\Ù\ÅbTõœø\és\"–\íE*”uw²ôŠ¿È»£\ÍZôÅ¦É¥u¦\İS]ğœdn-:RÙŠ\Øß¸¹£Ÿ·o\'ü96VÒ¶§R´§cªTU\'½ôzª\ÂX\åŞ=ş…w©jµ®­µf\Ê\İ\Ê-[-.JI&—¼wQè¬¶\ßeî¢v\Ég²¬\'\îšFö\×T\Ó\îh_\Ú\ÕO“…h¿“4ö:~¡¦;+\í*\ê\â·\Ğ\Ü^y\Ê÷B¾\Ã\é0«\'»«Fõc\è±x]\Ùl½É§`¥8\Ë²Rü/%Ú•aBœª×œiÓŠËœ\Ş8ı\rN¶\ÇU-s+².0ùkj³‹=Z\ë·NQ^K¸\ÓKw\r#j6\Ò÷R\Ú&ö\ÛFšİ†¡)J9\Â\Ä}\\egf\ê†\Ë\ì[	h•+T¸ı‰MM¥\ïÁrö\Ú\ZŒ\è;½ŸEG\ê\ãV¥Wø\î©$ß2mô­%\\N;·oKIıM>’~[óŒ™;6\Ñntı­:In¤§Ağk»Ì—GS½”¯}:Ú•´£\ÍJ\\\âğ\Ş9öñ6ôvSN“S¼«{/ô«™\Ê?\Õ\Ê_uomBÚ’¥oJ©®Q‚\Â%¤‹À(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Q¢ \n``¨›¥7I\0#º7 w\ÜD€ÜpÜ‰ 7#\âWr$€\ê\â:¸÷\0Cª‡\ÙE:˜>qEÀ®¢ŸØ¸ª£Oüœ}\ÅÀ¾ªšıˆûŠªp\\¢—°˜‰`¨\0\0\0\0\0\0\0ÿ\Ù','image/jpeg','2026-10-16 23:59:21');
/*!40000 ALTER TABLE `imagen_archivo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `instancia_inventario`
--

DROP TABLE IF EXISTS `instancia_inventario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `instancia_inventario` (
  `id_instancia` int NOT NULL AUTO_INCREMENT,
  `precio_venta` decimal(10,2) NOT NULL,
  `cantidad_stock` int NOT NULL DEFAULT '1',
  `notas_condicion` text COLLATE utf8mb4_unicode_ci,
  `fecha_ingreso` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fk_producto_catalogo` int NOT NULL,
  `fk_condicion` int NOT NULL,
  `fk_estado_disponibilidad` int NOT NULL,
  PRIMARY KEY (`id_instancia`),
  KEY `idx_fk_producto` (`fk_producto_catalogo`),
  KEY `idx_fk_condicion` (`fk_condicion`),
  KEY `idx_fk_estado` (`fk_estado_disponibilidad`),
  CONSTRAINT `fk_inv_condicion` FOREIGN KEY (`fk_condicion`) REFERENCES `condicion` (`id_condicion`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_inv_estado` FOREIGN KEY (`fk_estado_disponibilidad`) REFERENCES `estado_disponibilidad` (`id_estado`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_inv_producto` FOREIGN KEY (`fk_producto_catalogo`) REFERENCES `producto_catalogo` (`id_producto_catalogo`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `instancia_inventario_chk_1` CHECK ((`precio_venta` >= 0)),
  CONSTRAINT `instancia_inventario_chk_2` CHECK ((`cantidad_stock` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `instancia_inventario`
--

LOCK TABLES `instancia_inventario` WRITE;
/*!40000 ALTER TABLE `instancia_inventario` DISABLE KEYS */;
INSERT INTO `instancia_inventario` VALUES (1,2100.00,10,'desgaste por uso','2026-10-16 17:36:42',1,3,1),(2,8000.00,1,'pateado por el anterior dueÃ±o','2026-10-16 17:59:20',2,4,1);
/*!40000 ALTER TABLE `instancia_inventario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido`
--

DROP TABLE IF EXISTS `pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido` (
  `id_pedido` int NOT NULL AUTO_INCREMENT,
  `estado` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pendiente',
  `nota` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `fk_cliente` int NOT NULL,
  PRIMARY KEY (`id_pedido`),
  KEY `idx_ped_cliente` (`fk_cliente`),
  KEY `idx_ped_estado` (`estado`),
  CONSTRAINT `fk_ped_cliente` FOREIGN KEY (`fk_cliente`) REFERENCES `cliente` (`id_cliente`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_ped_estado` CHECK ((`estado` in (_utf8mb4'Pendiente',_utf8mb4'Completado',_utf8mb4'Cancelado')))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido`
--

LOCK TABLES `pedido` WRITE;
/*!40000 ALTER TABLE `pedido` DISABLE KEYS */;
INSERT INTO `pedido` VALUES (1,'Completado','mi sobrio lo trae',2000.00,'2026-10-16 23:39:11',1),(2,'Completado',NULL,2000.00,'2026-10-16 23:44:50',1);
/*!40000 ALTER TABLE `pedido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido_detalle`
--

DROP TABLE IF EXISTS `pedido_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido_detalle` (
  `id_detalle` int NOT NULL AUTO_INCREMENT,
  `cantidad` int NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `fk_pedido` int NOT NULL,
  `fk_instancia` int NOT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `idx_det_pedido` (`fk_pedido`),
  KEY `idx_det_instancia` (`fk_instancia`),
  CONSTRAINT `fk_det_instancia` FOREIGN KEY (`fk_instancia`) REFERENCES `instancia_inventario` (`id_instancia`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_det_pedido` FOREIGN KEY (`fk_pedido`) REFERENCES `pedido` (`id_pedido`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `pedido_detalle_chk_1` CHECK ((`cantidad` > 0)),
  CONSTRAINT `pedido_detalle_chk_2` CHECK ((`precio_unitario` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido_detalle`
--

LOCK TABLES `pedido_detalle` WRITE;
/*!40000 ALTER TABLE `pedido_detalle` DISABLE KEYS */;
INSERT INTO `pedido_detalle` VALUES (1,1,2000.00,1,1),(2,1,2000.00,2,1);
/*!40000 ALTER TABLE `pedido_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `producto_catalogo`
--

DROP TABLE IF EXISTS `producto_catalogo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto_catalogo` (
  `id_producto_catalogo` int NOT NULL AUTO_INCREMENT,
  `nombre_producto` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion_corta` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `descripcion_extendida` text COLLATE utf8mb4_unicode_ci,
  `ano_lanzamiento` int DEFAULT NULL,
  `imagen_base` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'default.png',
  `ean_upc` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipo_articulo` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fk_categoria` int NOT NULL,
  `fk_franquicia` int DEFAULT NULL,
  `fk_fabricante` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_producto_catalogo`),
  KEY `fk_cat_fabricante` (`fk_fabricante`),
  KEY `idx_nombre_cat` (`nombre_producto`),
  KEY `idx_fk_categoria` (`fk_categoria`),
  KEY `idx_fk_franquicia` (`fk_franquicia`),
  CONSTRAINT `fk_cat_categoria` FOREIGN KEY (`fk_categoria`) REFERENCES `categoria` (`id_categoria`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_cat_fabricante` FOREIGN KEY (`fk_fabricante`) REFERENCES `fabricante` (`id_fabricante`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_cat_franquicia` FOREIGN KEY (`fk_franquicia`) REFERENCES `franquicia` (`id_franquicia`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto_catalogo`
--

LOCK TABLES `producto_catalogo` WRITE;
/*!40000 ALTER TABLE `producto_catalogo` DISABLE KEYS */;
INSERT INTO `producto_catalogo` VALUES (1,'Arcade vintage Mario Bros','arcade de famoso juego mario bros, 2 jugadores controles konami arcade',NULL,NULL,'/api/imagenes/1',NULL,NULL,1,NULL,NULL,'2026-10-16 17:36:42','2026-10-16 17:59:29'),(2,'Pisa-papeles-5','Consola sobrevalorada',NULL,NULL,'/api/imagenes/2',NULL,NULL,1,NULL,NULL,'2026-10-16 17:59:20','2026-10-16 17:59:20');
/*!40000 ALTER TABLE `producto_catalogo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'catalogo_coleccionables'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-18 12:03:54
