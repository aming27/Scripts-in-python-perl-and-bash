USE OptaIntegrated;

#######################################################################################

DELIMITER //
DROP PROCEDURE IF EXISTS OptaIntegrated.OPTA_BIGINT_SWITCH_TABLES //
CREATE PROCEDURE OptaIntegrated.OPTA_BIGINT_SWITCH_TABLES ()
BEGIN
	RENAME TABLE OptaIntegrated.Event TO OptaIntegrated.Event_OLD, OptaIntegrated.Event_Type_Qualifier TO OptaIntegrated.Event_Type_Qualifier_OLD;
	RENAME TABLE OptaIntegrated.Event_BIGINT TO OptaIntegrated.Event, OptaIntegrated.Event_Type_Qualifier_BIGINT TO OptaIntegrated.Event_Type_Qualifier;
	DROP TABLE IF EXISTS Event_OLD,Event_Type_Qualifier_OLD,GameInformationStatus_OLD;
	
END //
DELIMITER ;

#######################################################################################

DELIMITER //
DROP PROCEDURE IF EXISTS OptaIntegrated.OPTA_BIGINT_PREPARE_TABLES //
CREATE PROCEDURE OptaIntegrated.OPTA_BIGINT_PREPARE_TABLES ()
BEGIN

	SET @COUNT_OF_NEEDED_TABLES=0;
	SELECT COUNT(*) INTO @COUNT_OF_NEEDED_TABLES
	FROM information_schema.TABLES T
	WHERE T.TABLE_SCHEMA LIKE 'OptaIntegrated'
	AND ( TABLE_NAME LIKE 'Event_BIGINT'
			OR TABLE_NAME LIKE 'Event_Type_Qualifier_BIGINT' 
			OR TABLE_NAME LIKE 'GameInformationStatus_OLD' 
			OR TABLE_NAME LIKE 'Control_Proc_BIGINT' 
			);

	IF @COUNT_OF_NEEDED_TABLES<>4 THEN
	
		DROP TABLE IF EXISTS OptaIntegrated.Control_Proc_BIGINT;
		CREATE TABLE OptaIntegrated.Control_Proc_BIGINT (
			game_id INT NOT NULL
			,start_timestamp DATETIME
			,end_timestamp DATETIME
			,`proc_status` ENUM('PROCESSING','COMPLETE','FAILED') NULL DEFAULT NULL COLLATE 'utf8_unicode_ci'
			,PRIMARY KEY (`game_id`)
			,INDEX iStatus (proc_status)
		);
		
		DROP TABLE IF EXISTS OptaIntegrated.Event_BIGINT;
		CREATE TABLE OptaIntegrated.Event_BIGINT (
			`id` BIGINT NOT NULL AUTO_INCREMENT,
			`event_id` INT(16) NOT NULL DEFAULT '0',
			`game_id` INT(16) NOT NULL DEFAULT '0',
			`event_type_id` INT(16) NOT NULL DEFAULT '0',
			`period_id` SMALLINT(6) NOT NULL DEFAULT '0',
			`period_minute` SMALLINT(6) NOT NULL DEFAULT '0',
			`period_second` SMALLINT(6) NOT NULL DEFAULT '0',
			`player_id` INT(16) NULL DEFAULT NULL,
			`team_id` INT(16) NULL DEFAULT NULL,
			`outcome` TINYINT(3) UNSIGNED NULL DEFAULT NULL,
			`x` FLOAT NULL DEFAULT NULL,
			`y` FLOAT NULL DEFAULT NULL,
			`timestamp` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
			`timestamp_milliseconds` INT(16) NOT NULL DEFAULT '0',
			`flag_event` TINYINT(3) UNSIGNED NULL DEFAULT NULL,
			`last_modified` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			`tracab_frame` INT(10) NULL DEFAULT NULL,
			`tracab_playerinfo` TEXT NULL,
			`tracab_ballinfo` TEXT NULL,
			`move_id` INT(10) NULL DEFAULT NULL,
			`event_move_idx` INT(11) NULL DEFAULT NULL,
			PRIMARY KEY (`id`),
			INDEX `iEvent_Id` (`event_id`),
			INDEX `iGame_Id` (`game_id`),
			INDEX `iPlayer_Id` (`player_id`)
		)
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM
		AUTO_INCREMENT=2147474119
		;
	
		DROP TABLE IF EXISTS OptaIntegrated.Event_Type_Qualifier_BIGINT;
		CREATE TABLE OptaIntegrated.Event_Type_Qualifier_BIGINT (
			`id` BIGINT NOT NULL AUTO_INCREMENT,
			`game_id` INT(16) NOT NULL DEFAULT '0',
			`event_id` BIGINT NOT NULL DEFAULT '0',
			`event_type_id` INT(16) NOT NULL DEFAULT '0',
			`qualifier_id` INT(16) NOT NULL DEFAULT '0',
			`value` VARCHAR(255) NULL DEFAULT NULL,
			PRIMARY KEY (`id`),
			INDEX `iGame` (`game_id`),
			INDEX `iEvent` (`event_id`),
			INDEX `iQualifier` (`qualifier_id`)
		)
		COLLATE='utf8_general_ci'
		ENGINE=MyISAM
		AUTO_INCREMENT=2147478084
		;
	
		DROP TABLE IF EXISTS OptaIntegrated.GameInformationStatus_OLD;
		CREATE TABLE OptaIntegrated.GameInformationStatus_OLD (
			`game_id` INT(11) NOT NULL COMMENT 'References Game.id',
			`last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			`optagame_status` ENUM('MISSING','READY','PROCESSING','COMPLETE','FAILED') NOT NULL DEFAULT 'MISSING' COMMENT 'Synchronization status of Opta game related data.' COLLATE 'utf8_unicode_ci',
			`optagame_version` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '0',
			`optagame_errormessage` TEXT NULL COLLATE 'utf8_unicode_ci',
			`optagame_timestamp` DATETIME NULL DEFAULT NULL COMMENT 'Last update timestamp of optagame_status',
			`optagame_start_timestamp` DATETIME NULL DEFAULT NULL COMMENT 'Timestamp of import process start',
			`optagame_end_timestamp` DATETIME NULL DEFAULT NULL COMMENT 'Timestamp of import process end',
			`moves_status` ENUM('MISSING','READY','PROCESSING','COMPLETE','FAILED') NOT NULL DEFAULT 'MISSING' COMMENT 'Status of Moves for the given game.' COLLATE 'utf8_unicode_ci',
			`moves_version` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '0',
			`moves_errormessage` TEXT NULL COLLATE 'utf8_unicode_ci',
			`moves_timestamp` DATETIME NULL DEFAULT NULL COMMENT 'Last update timestamp of moves_status',
			`moves_start_timestamp` DATETIME NULL DEFAULT NULL COMMENT 'Timestamp of process start',
			`moves_end_timestamp` DATETIME NULL DEFAULT NULL COMMENT 'Timestamp of process end',
			`tracabsynch_status` ENUM('MISSING','READY','PROCESSING','COMPLETE','FAILED') NOT NULL DEFAULT 'MISSING' COMMENT 'Status of Tracab data at soccer Event level.' COLLATE 'utf8_unicode_ci',
			`tracabsynch_version` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '0',
			`tracabsynch_errormessage` TEXT NULL COLLATE 'utf8_unicode_ci',
			`tracabsynch_timestamp` DATETIME NULL DEFAULT NULL COMMENT 'Last update timestamp of tracabsynch_status',
			`tracabsynch_start_timestamp` DATETIME NULL DEFAULT NULL COMMENT 'Timestamp of process start',
			`tracabsynch_end_timestamp` DATETIME NULL DEFAULT NULL COMMENT 'Timestamp of process end',
			`tracabstats_status` ENUM('MISSING','READY','PROCESSING','COMPLETE','FAILED') NOT NULL DEFAULT 'MISSING' COMMENT 'Status of Tracab statistics.' COLLATE 'utf8_unicode_ci',
			`tracabstats_version` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '0',
			`tracabstats_errormessage` TEXT NULL COLLATE 'utf8_unicode_ci',
			`tracabstats_timestamp` DATETIME NULL DEFAULT NULL COMMENT 'Last update timestamp of tracabstats_status',
			`tracabstats_start_timestamp` DATETIME NULL DEFAULT NULL COMMENT 'Timestamp of process start',
			`tracabstats_end_timestamp` DATETIME NULL DEFAULT NULL COMMENT 'Timestamp of process end',
			`tracabstats_module_version` VARCHAR(20) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
			`tracabstats_statisticsset_version` VARCHAR(20) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
			PRIMARY KEY (`game_id`)
		)
		COLLATE='utf8_unicode_ci'
		ENGINE=MyISAM
		;
		
	END IF;
	
	
	SET @GIS_ROWS=0;
	SELECT COUNT(*) INTO @GIS_ROWS FROM OptaIntegrated.GameInformationStatus_OLD;
	
	IF @GIS_ROWS=0 THEN
		INSERT INTO OptaIntegrated.GameInformationStatus_OLD (game_id,last_update,optagame_status,optagame_version,optagame_errormessage,optagame_timestamp,optagame_start_timestamp,optagame_end_timestamp,moves_status,moves_version,moves_errormessage,moves_timestamp,moves_start_timestamp,moves_end_timestamp,tracabsynch_status,tracabsynch_version,tracabsynch_errormessage,tracabsynch_timestamp,tracabsynch_start_timestamp,tracabsynch_end_timestamp,tracabstats_status,tracabstats_version,tracabstats_errormessage,tracabstats_timestamp,tracabstats_start_timestamp,tracabstats_end_timestamp,tracabstats_module_version,tracabstats_statisticsset_version)
			SELECT game_id,last_update,optagame_status,optagame_version,optagame_errormessage,optagame_timestamp,optagame_start_timestamp,optagame_end_timestamp,moves_status,moves_version,moves_errormessage,moves_timestamp,moves_start_timestamp,moves_end_timestamp,tracabsynch_status,tracabsynch_version,tracabsynch_errormessage,tracabsynch_timestamp,tracabsynch_start_timestamp,tracabsynch_end_timestamp,tracabstats_status,tracabstats_version,tracabstats_errormessage,tracabstats_timestamp,tracabstats_start_timestamp,tracabstats_end_timestamp,tracabstats_module_version,tracabstats_statisticsset_version
			FROM OptaIntegrated.GameInformationStatus WHERE optagame_status = 'COMPLETE';
	END IF;
	
	DELETE FROM Event_BIGINT WHERE game_id IN (	SELECT game_id FROM OptaIntegrated.Control_Proc_BIGINT WHERE proc_status<>'COMPLETE' );
	DELETE FROM Event_Type_Qualifier_BIGINT WHERE game_id IN (	SELECT game_id FROM OptaIntegrated.Control_Proc_BIGINT WHERE proc_status<>'COMPLETE' );
	DELETE FROM OptaIntegrated.Control_Proc_BIGINT WHERE proc_status<>'COMPLETE';
	
END //
DELIMITER ;

#######################################################################################

DELIMITER //
DROP PROCEDURE IF EXISTS OptaIntegrated.OPTA_BIGINT_COPY_RECORDS //
CREATE PROCEDURE OptaIntegrated.OPTA_BIGINT_COPY_RECORDS (numGames INT)
BEGIN

	REPEAT
		SET numGames=numGames-1;
		
		SET @paramGameId=NULL;
		SELECT game_id INTO @paramGameId
			FROM GameInformationStatus_OLD
			WHERE game_id NOT IN (SELECT game_id FROM Control_Proc_BIGINT)
			LIMIT 1;
			
		IF @paramGameId IS NOT NULL THEN
			REPLACE INTO Control_Proc_BIGINT(game_id,start_timestamp,end_timestamp,proc_status) VALUES (@paramGameId,now(),NULL,'PROCESSING');
			INSERT INTO Event_BIGINT(id,event_id,game_id,event_type_id,period_id,period_minute,period_second,player_id,team_id,outcome,x,y,timestamp,timestamp_milliseconds,flag_event,last_modified,tracab_frame,tracab_playerinfo,tracab_ballinfo,move_id,event_move_idx)
				SELECT id,event_id,game_id,event_type_id,period_id,period_minute,period_second,player_id,team_id,outcome,x,y,timestamp,timestamp_milliseconds,flag_event,last_modified,tracab_frame,tracab_playerinfo,tracab_ballinfo,move_id,event_move_idx
				FROM Event WHERE game_id=@paramGameId;
			INSERT INTO Event_Type_Qualifier_BIGINT(id,game_id,event_id,event_type_id,qualifier_id,value)
				SELECT id,game_id,event_id,event_type_id,qualifier_id,value
				FROM Event_Type_Qualifier WHERE game_id=@paramGameId;

			SET @eventMismatchingRecords=1;
			SET @eventCount=0;
			SELECT COUNT(*) INTO @eventCount FROM Event WHERE game_id=@paramGameId;
			SET @eventCountBigInt=0;
			SELECT COUNT(*) INTO @eventCountBigInt FROM Event_BIGINT WHERE game_id=@paramGameId;

			SELECT ABS(COUNT(*)-@eventCount)+ABS(@eventCountBigInt-@eventCount) INTO @eventMismatchingRecords
			FROM
			(
			  SELECT *
			  FROM Event
			  WHERE game_id=@paramGameId
			  UNION
			  SELECT *
			  FROM Event_BIGINT
			  WHERE game_id=@paramGameId
			)  t;

			SET @eventTypeQualifierMismatchingRecords=1;
			SET @etqCount=0;
			SELECT COUNT(*) INTO @etqCount FROM Event_Type_Qualifier WHERE game_id=@paramGameId;
			SET @etqCountBigInt=0;
			SELECT COUNT(*) INTO @etqCountBigInt FROM Event_Type_Qualifier_BIGINT WHERE game_id=@paramGameId;
			
			SELECT ABS(COUNT(*)-@etqCount)+ABS(@etqCountBigInt-@etqCount) INTO @eventTypeQualifierMismatchingRecords
			FROM
			(
			  SELECT *
			  FROM Event_Type_Qualifier
			  WHERE game_id=@paramGameId
			  UNION
			  SELECT *
			  FROM Event_Type_Qualifier_BIGINT
			  WHERE game_id=@paramGameId
			)  t;

			
			IF @eventMismatchingRecords=0 AND @eventTypeQualifierMismatchingRecords=0 THEN
				UPDATE Control_Proc_BIGINT
					SET end_timestamp=NOW()
						,proc_status='COMPLETE'
					WHERE game_id=@paramGameId;
			ELSE
				UPDATE Control_Proc_BIGINT
					SET end_timestamp=NOW()
						,proc_status='FAILED'
					WHERE game_id=@paramGameId;
			END IF;		
			
		ELSE
			SET numGames=0;
			SET @mismatchingGames=1;
			SELECT COUNT(*) INTO @mismatchingGames	FROM Control_Proc_BIGINT WHERE proc_status<>'COMPLETE';
			IF @mismatchingGames=0 THEN
				CALL OptaIntegrated.OPTA_BIGINT_SWITCH_TABLES();
			END IF;
		END IF;
	UNTIL numGames<=0
	END REPEAT;


END //
DELIMITER ;

#######################################################################################

DELIMITER //
DROP PROCEDURE IF EXISTS OptaIntegrated.OPTA_BIGINT_START //
CREATE PROCEDURE OptaIntegrated.OPTA_BIGINT_START(IN numGames INT)
BEGIN

	SET @COUNT_OF_EVENT_TABLES_TO_CHANGE=0;
	SELECT COUNT(*) INTO @COUNT_OF_EVENT_TABLES_TO_CHANGE
	FROM information_schema.TABLES T
	WHERE T.TABLE_SCHEMA = 'OptaIntegrated'
	AND ( TABLE_NAME = 'Event' OR TABLE_NAME = 'Event_Type_Qualifier' );
	
	SET @COUNT_OF_BIGINT_COLUMNS=0;
	SELECT COUNT(*) INTO @COUNT_OF_BIGINT_COLUMNS
	FROM information_schema.COLUMNS C
	WHERE C.TABLE_SCHEMA = 'OptaIntegrated'
		AND C.DATA_TYPE = 'bigint'
		AND (
			C.TABLE_NAME = 'Event' AND C.COLUMN_NAME = 'id'
			OR C.TABLE_NAME = 'Event_Type_Qualifier' AND ( C.COLUMN_NAME = 'id' OR C.COLUMN_NAME = 'event_id' )
	 	);

	SET @COUNT_OF_BIGINT_TABLES=0;
	SELECT COUNT(*) INTO @COUNT_OF_BIGINT_TABLES
	FROM information_schema.TABLES T
	WHERE T.TABLE_SCHEMA = 'OptaIntegrated'
	AND ( T.TABLE_NAME = 'Event_BIGINT' OR T.TABLE_NAME = 'Event_Type_Qualifier_BIGINT'
	 );
	

	IF @COUNT_OF_EVENT_TABLES_TO_CHANGE=2 THEN
		IF @COUNT_OF_BIGINT_COLUMNS=3 THEN
			DROP TABLE IF EXISTS OptaIntegrated.Event_OLD,OptaIntegrated.Event_Type_Qualifier_OLD,OptaIntegrated.GameInformationStatus_OLD;
		ELSE
			CALL OptaIntegrated.OPTA_BIGINT_PREPARE_TABLES();
			CALL OptaIntegrated.OPTA_BIGINT_COPY_RECORDS(numGames);
		END IF;
		SELECT 'PROCESSED FINISHED';
	#THE OLD TABLES ARE RENAMED IN A SINGLE STATEMENT, SO THERE IS NO NEED TO WORRY THAT ONE MIGHT HAVE BEEN RENAMED WHILE THE OTHER NOT.
	ELSE
		#SAME APPLIES TO BIGINT TABLES
		IF @COUNT_OF_BIGINT_TABLES=2 THEN
			RENAME TABLE OptaIntegrated.Event_BIGINT TO OptaIntegrated.Event, OptaIntegrated.Event_Type_Qualifier_BIGINT TO OptaIntegrated.Event_Type_Qualifier;
			DROP TABLE IF EXISTS OptaIntegrated.Event_OLD,OptaIntegrated.Event_Type_Qualifier_OLD,OptaIntegrated.GameInformationStatus_OLD;
			SELECT 'PROCESSED FINISHED';
		ELSE
			SELECT 'FATAL ERROR: AT LEAST ONE OF THE TABLES TO MODIFY WAS LOST';
		END IF;
	END IF;


END //
DELIMITER ;

#######################################################################################

CALL OptaIntegrated.OPTA_BIGINT_START(8000);