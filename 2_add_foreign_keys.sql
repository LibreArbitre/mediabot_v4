-- This script adds foreign key constraints to the mediabot database
-- to improve data integrity. It is recommended to back up your database
-- before running this script.

-- Note: All foreign keys are created with ON DELETE CASCADE, which means
-- that if a parent record is deleted, all corresponding child records
-- will be automatically deleted. For example, deleting a USER will delete
-- all of their quotes, hostmasks, and channel associations.

-- Make sure all tables use the InnoDB storage engine, as it's required for FKs.
-- ALTER TABLE `some_table` ENGINE=InnoDB;

START TRANSACTION;

-- In ACTIONS_LOG, link to USER and CHANNEL
ALTER TABLE `ACTIONS_LOG`
  ADD CONSTRAINT `fk_actions_log_user`
    FOREIGN KEY (`id_user`)
    REFERENCES `USER` (`id_user`)
    ON DELETE CASCADE,
  ADD CONSTRAINT `fk_actions_log_channel`
    FOREIGN KEY (`id_channel`)
    REFERENCES `CHANNEL` (`id_channel`)
    ON DELETE CASCADE;

-- In CHANNEL_LOG, link to CHANNEL
ALTER TABLE `CHANNEL_LOG`
  ADD CONSTRAINT `fk_channel_log_channel`
    FOREIGN KEY (`id_channel`)
    REFERENCES `CHANNEL` (`id_channel`)
    ON DELETE CASCADE;

-- In PUBLIC_COMMANDS, link to USER and PUBLIC_COMMANDS_CATEGORY
-- We use SET NULL for user deletion, so commands aren't lost.
ALTER TABLE `PUBLIC_COMMANDS`
  ADD CONSTRAINT `fk_public_commands_user`
    FOREIGN KEY (`id_user`)
    REFERENCES `USER` (`id_user`)
    ON DELETE SET NULL,
  ADD CONSTRAINT `fk_public_commands_category`
    FOREIGN KEY (`id_public_commands_category`)
    REFERENCES `PUBLIC_COMMANDS_CATEGORY` (`id_public_commands_category`)
    ON DELETE CASCADE;

-- In SERVERS, link to NETWORK
ALTER TABLE `SERVERS`
  ADD CONSTRAINT `fk_servers_network`
    FOREIGN KEY (`id_network`)
    REFERENCES `NETWORK` (`id_network`)
    ON DELETE CASCADE;

-- In USER, link to USER_LEVEL
-- Note: You cannot delete a USER_LEVEL if users still reference it.
ALTER TABLE `USER`
  ADD CONSTRAINT `fk_user_user_level`
    FOREIGN KEY (`id_user_level`)
    REFERENCES `USER_LEVEL` (`id_user_level`);

-- In USER_HOSTMASK, link to USER
ALTER TABLE `USER_HOSTMASK`
  ADD CONSTRAINT `fk_user_hostmask_user`
    FOREIGN KEY (`id_user`)
    REFERENCES `USER` (`id_user`)
    ON DELETE CASCADE;

-- In USER_CHANNEL, link to USER and CHANNEL
ALTER TABLE `USER_CHANNEL`
  ADD CONSTRAINT `fk_user_channel_user`
    FOREIGN KEY (`id_user`)
    REFERENCES `USER` (`id_user`)
    ON DELETE CASCADE,
  ADD CONSTRAINT `fk_user_channel_channel`
    FOREIGN KEY (`id_channel`)
    REFERENCES `CHANNEL` (`id_channel`)
    ON DELETE CASCADE;

-- In CHANNEL_SET, link to CHANNEL and CHANSET_LIST
ALTER TABLE `CHANNEL_SET`
  ADD CONSTRAINT `fk_channel_set_channel`
    FOREIGN KEY (`id_channel`)
    REFERENCES `CHANNEL` (`id_channel`)
    ON DELETE CASCADE,
  ADD CONSTRAINT `fk_channel_set_chanset_list`
    FOREIGN KEY (`id_chanset_list`)
    REFERENCES `CHANSET_LIST` (`id_chanset_list`)
    ON DELETE CASCADE;

-- In QUOTES, link to CHANNEL and USER
ALTER TABLE `QUOTES`
  ADD CONSTRAINT `fk_quotes_channel`
    FOREIGN KEY (`id_channel`)
    REFERENCES `CHANNEL` (`id_channel`)
    ON DELETE CASCADE,
  ADD CONSTRAINT `fk_quotes_user`
    FOREIGN KEY (`id_user`)
    REFERENCES `USER` (`id_user`)
    ON DELETE CASCADE;

-- In MP3, link to USER
ALTER TABLE `MP3`
  ADD CONSTRAINT `fk_mp3_user`
    FOREIGN KEY (`id_user`)
    REFERENCES `USER` (`id_user`)
    ON DELETE CASCADE;

-- In HAILO_CHANNEL, link to CHANNEL
ALTER TABLE `HAILO_CHANNEL`
  ADD CONSTRAINT `fk_hailo_channel_channel`
    FOREIGN KEY (`id_channel`)
    REFERENCES `CHANNEL` (`id_channel`)
    ON DELETE CASCADE;
    
-- In RESPONDERS, link to CHANNEL
ALTER TABLE `RESPONDERS`
  ADD CONSTRAINT `fk_responders_channel`
    FOREIGN KEY (`id_channel`)
    REFERENCES `CHANNEL` (`id_channel`)
    ON DELETE CASCADE;

-- In BADWORDS, link to CHANNEL
ALTER TABLE `BADWORDS`
  ADD CONSTRAINT `fk_badwords_channel`
    FOREIGN KEY (`id_channel`)
    REFERENCES `CHANNEL` (`id_channel`)
    ON DELETE CASCADE;

-- In IGNORES, link to CHANNEL
ALTER TABLE `IGNORES`
  ADD CONSTRAINT `fk_ignores_channel`
    FOREIGN KEY (`id_channel`)
    REFERENCES `CHANNEL` (`id_channel`)
    ON DELETE CASCADE;

-- In CHANNEL_FLOOD, link to CHANNEL
ALTER TABLE `CHANNEL_FLOOD`
  ADD CONSTRAINT `fk_channel_flood_channel`
    FOREIGN KEY (`id_channel`)
    REFERENCES `CHANNEL` (`id_channel`)
    ON DELETE CASCADE;

COMMIT;
