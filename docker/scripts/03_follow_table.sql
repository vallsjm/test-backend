CREATE TABLE `follow` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_follower_id` INT(11) NOT NULL,
  `user_followed_id` INT(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO `follow` (`id`, `user_follower_id`, `user_followed_id`) VALUES (1, 3, 1);
INSERT INTO `follow` (`id`, `user_follower_id`, `user_followed_id`) VALUES (2, 3, 2);
INSERT INTO `follow` (`id`, `user_follower_id`, `user_followed_id`) VALUES (3, 2, 1);

ALTER TABLE follow ADD CONSTRAINT fk_user_follower_id FOREIGN KEY (user_follower_id) REFERENCES user(id);
ALTER TABLE follow ADD CONSTRAINT fk_user_followed_id FOREIGN KEY (user_followed_id) REFERENCES user(id);
