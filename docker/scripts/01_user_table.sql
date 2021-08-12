CREATE TABLE `user` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(150) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO `user` (`id`, `username`) VALUES (1, 'maria');
INSERT INTO `user` (`id`, `username`) VALUES (2, 'carla');
INSERT INTO `user` (`id`, `username`) VALUES (3, 'beatriz');

ALTER TABLE user
  ADD UNIQUE INDEX idx_username (username);
