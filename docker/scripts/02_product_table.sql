CREATE TABLE `product` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `date` DATE NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO `product` (`id`, `user_id`, `name`, `date`) VALUES (1, 1, 'zapatos rojos', '2021-05-01');
INSERT INTO `product` (`id`, `user_id`, `name`, `date`) VALUES (2, 1, 'zapatos rojos', '2021-05-20');
INSERT INTO `product` (`id`, `user_id`, `name`, `date`) VALUES (3, 2, 'zapatos rojos', '2021-05-21');
INSERT INTO `product` (`id`, `user_id`, `name`, `date`) VALUES (4, 2, 'zapatos rojos', '2021-05-21');
INSERT INTO `product` (`id`, `user_id`, `name`, `date`) VALUES (5, 1, 'zapatos rojos', '2021-05-22');

ALTER TABLE product
  ADD INDEX idx_date (date);

ALTER TABLE product ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES user(id);
