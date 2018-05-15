-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 15-05-2018 a las 05:20:13
-- Versión del servidor: 10.1.21-MariaDB
-- Versión de PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `the3be`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_favorite` (`user_id` INT, `product_id` INT)  BEGIN
  insert into favorite (user_id,product_id) values (user_id,product_id);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_local` (`user_id` INT(8), `name` VARCHAR(45), `address` VARCHAR(45), `schedule` VARCHAR(23), `phone` INT(8))  BEGIN
  insert into local (user_id, name, address, schedule, phone) values(user_id,name,address,schedule,phone);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_product` (`user_id` INT(10), `name` VARCHAR(100), `type` VARCHAR(45), `date_ini` DATE, `date_end` DATE, `price` FLOAT(11), `stock` INT(11), `info` TEXT, `img` VARCHAR(50), `status` INT(11), `local_id` INT(10), `category` INT(10))  BEGIN
  insert into product (user_id,name,type,date_ini,date_end,price,stock,info,img,status,local_id,category_id)values(user_id,name,type,date_ini,date_end,price,stock,info,img,status,local_id,category);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_purchase` (`user_id` INT(11), `product_id` INT(11))  BEGIN
  insert into purchase (user_id,product_id,date,status) values (user_id,product_id,CURDATE(),1);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_user` (`name` VARCHAR(45), `email` VARCHAR(100), `pass` VARCHAR(50), `status` INT(11), `sub_state` INT(11))  BEGIN
	
	SET @mail=(select mail from user where mail=email);
	IF @mail=email then
		update user set name=name where mail=@mail;
		update user set pass=pass where mail=@mail;
		update user set status=status where mail=@mail;
	ELSE
			insert into user (name,mail,pass,status,sub_state) values(name,email,pass,status,sub_state);
	END IF; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_best5_category` ()  BEGIN
	select distinct category_id,count(purchase.id) as cantidad from purchase,product where product.id=purchase.product_id and purchase.status=2 group by product_id order by cantidad desc LIMIT 4;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_bestseller_product` ()  BEGIN
	select distinct product.id,product.name,category_id,category.name as category,type,info,price,img,product_id, count(product_id) as cantidad
from purchase,category,product
where product.id=product_id and category.id=category_id and purchase.status=2
group by product_id,product.id,category.id
order by cantidad desc limit 15;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_category` ()  BEGIN
  select id,name from category;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_filtered_product` (IN `nombre` VARCHAR(50), IN `price_min` FLOAT(10), IN `price_max` FLOAT(10), IN `category` INT(10))  BEGIN
  set @today=CURDATE();
  IF (nombre = -1 and category = -1 and price_min = -1 and price_max = -1) THEN
    select * from product where status <> -1 and date_end <= @today;
  ELSE 
  SET @consulta= "select * from product  where";
  IF  (nombre <> -1) THEN
    SET @consulta=CONCAT(@consulta," name like'%",nombre,"%'");
  END IF;
    
  IF  (category <> -1) THEN
    IF (nombre <> -1) THEN
      SET @consulta=CONCAT(@consulta," and");
    END IF;
  SET @consulta=CONCAT(@consulta," category_id = ",category,"");
  END IF;
    
    
  IF  (price_min <> -1 and price_max <> -1) THEN
    IF (nombre <> -1 or category <> -1) THEN
      SET @consulta=CONCAT(@consulta," and");
    END IF;
    
    SET @consulta=CONCAT(@consulta," price <= '",price_max,"' and price >= '",price_min,"';");
  END IF;
    PREPARE stmt FROM @consulta;
    EXECUTE stmt;
  
  
  
  END IF;

  

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_local` (`u_id` INT(8))  BEGIN
  select * from local where user_id=u_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_product_from_id` (`id` INT)  BEGIN
select product.id,product.name,category_id,category.name as category,type,info,price,img from product,category where product.id=id and category_id=category.id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_prox_to_end` ()  BEGIN
SET @today = CURDATE();
  select * from product where state <> -1 and date_end <= @today order by date_end  LIMIT 5;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user` (`email` VARCHAR(100), `password` VARCHAR(50))  BEGIN
  select * from user where mail=email and pass=password;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_products` (`user_id` INT)  BEGIN
	select * from product where user_id=user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_state` (`date_ini` VARCHAR(8), `id` INT(50), `hour_ini` VARCHAR(8), `state` INT(50))  BEGIN
  update user_states set date_end=date_ini where user_id=id and date_end is null;
    update user_states set hour_end=hour_ini where user_id=id and hour_end is null;
  insert into user_states (user_id,date_ini,date_end,hour_ini,hour_end,state) VALUES (id,date_ini,null,hour_ini,null,state);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `category`
--

CREATE TABLE `category` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `category`
--

INSERT INTO `category` (`id`, `name`) VALUES
(1, 'Tecnologia'),
(2, 'Salud y Belleza'),
(3, 'Entretenimiento'),
(4, 'Hogar'),
(5, 'Alimentos y Bebidas'),
(6, 'Inmuebles'),
(7, 'Vehiculos'),
(8, 'Animales y Mascotas'),
(9, 'Arte y Antiguedades'),
(10, 'Adultos');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `favorite`
--

CREATE TABLE `favorite` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `local`
--

CREATE TABLE `local` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(45) DEFAULT NULL,
  `address` varchar(45) DEFAULT NULL,
  `schedule` varchar(23) DEFAULT NULL,
  `phone` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `local`
--

INSERT INTO `local` (`id`, `user_id`, `name`, `address`, `schedule`, `phone`) VALUES
(1, 1, 'McDrogals', 'Turuia', 'De 18:20 a 23:50', 23113803),
(2, 2, 'Centro', '18 de julio 1234', 'de 9 a 18hrs', 98183725);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product`
--

CREATE TABLE `product` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `type` varchar(45) DEFAULT NULL COMMENT 'Oferta/Producto',
  `date_ini` date DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `price` float DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `info` text,
  `img` varchar(50) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `local_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `product`
--

INSERT INTO `product` (`id`, `user_id`, `name`, `type`, `date_ini`, `date_end`, `price`, `stock`, `info`, `img`, `status`, `local_id`, `category_id`) VALUES
(1, 1, 'Chupetines', 'Producto', '2018-04-05', '2018-05-20', 14, 30, 'Asdadsadasd', 'askjdbajsd .jpg', 1, 1, 5),
(2, 1, 'Chocolates', 'OFERTA', '2018-04-05', '2018-05-20', 18, 36, 'Bdasdadssd', 'askjdbajsd .jpg', 1, 1, 5),
(3, 1, 'Vestidos', 'Producto', '2018-04-05', '2018-05-20', 45, 40, 'Cadasdsd', 'askjdbajsd .jpg', 1, 1, 3),
(4, 1, 'Motocicleta', 'OFERTA', '2018-04-05', '2018-05-20', 89, 89, 'Dasdadsdas', 'askjdbajsd .jpg', 1, 1, 2),
(5, 1, 'Core I3', 'Producto', '2018-04-05', '2018-05-20', 118, 15, 'Easdadasd', 'askjdbajsd .jpg', 1, 1, 6),
(6, 1, 'Cerveza', 'Producto', '2018-04-05', '2018-05-20', 180, 200, 'Fasdadasd', 'askjdbajsd .jpg', 1, 1, 1);

--
-- Disparadores `product`
--
DELIMITER $$
CREATE TRIGGER `product_AFTER_INSERT` AFTER INSERT ON `product` FOR EACH ROW BEGIN
  insert into product_updates (product_id,date_ini,date_end,hour_ini,hour_end,state,price) values (NEW.id,now(),null,time(now()),null,NEW.status,NEW.price);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `product_BEFORE_UPDATE` BEFORE UPDATE ON `product` FOR EACH ROW BEGIN
  IF (NEW.stock='0' or NEW.date_end < CURDATE()) THEN
    SET NEW.status = '-1';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `product_after_update` AFTER UPDATE ON `product` FOR EACH ROW BEGIN
set @today= CURDATE();
  
  IF (new.status <> old.status or new.price <> old.price) THEN BEGIN
        update product_updates set date_end=now() where product_id=new.id and date_end is null;
    update product_updates set hour_end=time(now()) where product_id=new.id and hour_end is null;
    insert into product_updates (product_id,date_ini,date_end,hour_ini,hour_end,state,price) VALUES (new.id,now(),null,time(now()),null,new.status,new.price);
    END; END IF;
  
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product_updates`
--

CREATE TABLE `product_updates` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `date_ini` date NOT NULL,
  `date_end` date DEFAULT NULL,
  `hour_ini` varchar(8) NOT NULL,
  `hour_end` varchar(8) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  `price` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `product_updates`
--

INSERT INTO `product_updates` (`id`, `product_id`, `date_ini`, `date_end`, `hour_ini`, `hour_end`, `state`, `price`) VALUES
(1, 1, '2018-05-10', NULL, '10:32:40', NULL, 1, 14),
(2, 2, '2018-05-10', NULL, '10:32:40', NULL, 1, 18),
(3, 3, '2018-05-10', '2018-05-14', '11:15:49', '21:44:55', 1, 18),
(4, 4, '2018-05-10', '2018-05-14', '11:15:49', '21:44:55', 1, 18),
(5, 5, '2018-05-10', '2018-05-14', '11:15:49', '21:44:55', 1, 18),
(6, 6, '2018-05-10', '2018-05-14', '11:24:21', '21:44:55', 1, 18),
(7, 3, '2018-05-14', NULL, '21:44:55', NULL, 1, 45),
(8, 4, '2018-05-14', NULL, '21:44:55', NULL, 1, 89),
(9, 5, '2018-05-14', NULL, '21:44:55', NULL, 1, 118),
(10, 6, '2018-05-14', NULL, '21:44:55', NULL, 1, 180);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `purchase`
--

CREATE TABLE `purchase` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `date` date DEFAULT NULL,
  `status` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `purchase`
--

INSERT INTO `purchase` (`id`, `user_id`, `product_id`, `date`, `status`) VALUES
(1, 1, 1, '2018-05-10', 2),
(2, 2, 2, '2018-05-10', 2),
(3, 3, 2, '2018-05-10', 1),
(4, 3, 4, '2018-05-10', 1),
(5, 3, 5, '2018-05-10', 1),
(6, 2, 5, '2018-05-10', 1),
(7, 1, 5, '2018-05-10', 1),
(8, 1, 4, '2018-05-10', 1),
(9, 1, 3, '2018-05-10', 1),
(10, 1, 6, '2018-05-10', 1);

--
-- Disparadores `purchase`
--
DELIMITER $$
CREATE TRIGGER `purchase_after_insert` AFTER INSERT ON `purchase` FOR EACH ROW BEGIN
  insert into purchase_states (purchase_id,date_ini,date_end,hour_ini,hour_end,state) values (NEW.id,now(),null,time(now()),null,NEW.status);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `purchase_after_update` AFTER UPDATE ON `purchase` FOR EACH ROW BEGIN
  IF (new.status = 2) THEN
    SET @id=(select product_id from purchase where id=new.id);
      update product set stock = stock-1 where id=@id;
  END IF;
    IF (new.status <> old.status) THEN BEGIN
        update purchase_states set date_end=now() where purchase_id=new.id and date_end is null;
    update purchase_states set hour_end=time(now()) where purchase_id=new.id and hour_end is null;
    insert into purchase_states (purchase_id,date_ini,date_end,hour_ini,hour_end,state) VALUES (new.id,now(),null,time(now()),null,new.status);
    END; END IF;
    
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `purchase_states`
--

CREATE TABLE `purchase_states` (
  `id` int(11) NOT NULL,
  `purchase_id` int(11) NOT NULL,
  `date_ini` date NOT NULL,
  `date_end` date DEFAULT NULL,
  `hour_ini` varchar(8) NOT NULL,
  `hour_end` varchar(8) DEFAULT NULL,
  `state` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `purchase_states`
--

INSERT INTO `purchase_states` (`id`, `purchase_id`, `date_ini`, `date_end`, `hour_ini`, `hour_end`, `state`) VALUES
(1, 1, '2018-05-10', '2018-05-10', '10:41:23', '11:28:14', 1),
(2, 2, '2018-05-10', '2018-05-14', '10:41:32', '20:23:56', 1),
(3, 3, '2018-05-10', NULL, '10:41:36', NULL, 1),
(4, 4, '2018-05-10', NULL, '11:15:53', NULL, 1),
(5, 5, '2018-05-10', NULL, '11:15:58', NULL, 1),
(6, 6, '2018-05-10', NULL, '11:16:47', NULL, 1),
(7, 7, '2018-05-10', NULL, '11:16:51', NULL, 1),
(8, 8, '2018-05-10', NULL, '11:17:06', NULL, 1),
(9, 9, '2018-05-10', NULL, '11:24:30', NULL, 1),
(10, 10, '2018-05-10', NULL, '11:24:37', NULL, 1),
(11, 1, '2018-05-10', NULL, '11:28:14', NULL, 2),
(12, 2, '2018-05-14', '2018-05-14', '20:23:56', '21:49:53', 0),
(13, 2, '2018-05-14', NULL, '21:49:53', NULL, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `name` varchar(45) DEFAULT NULL COMMENT 'nombre',
  `mail` varchar(100) NOT NULL COMMENT 'email',
  `pass` varchar(50) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `sub_state` int(11) DEFAULT NULL COMMENT 'estado de la suscripcion'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`id`, `name`, `mail`, `pass`, `status`, `sub_state`) VALUES
(1, 'Matias Gazani', 'mgs@gmail.com', '1272c19590c3d44ce33ba054edfb9c78', 1, 1),
(2, 'John Gallo', 'jg@gmail.com', '1272c19590c3d44ce33ba054edfb9c78', 1, 1),
(3, 'German Perez', 'gp@gmail.com', '1272c19590c3d44ce33ba054edfb9c78', 1, 1),
(9, 'pepe', 'pepe@gmail.com', '1234', 2, 1);

--
-- Disparadores `user`
--
DELIMITER $$
CREATE TRIGGER `state_change` AFTER INSERT ON `user` FOR EACH ROW BEGIN
insert into user_states (user_id,date_ini,date_end,hour_ini,hour_end,state) values(NEW.id,now(),null,time(now()),null,NEW.status);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `state_change2` AFTER UPDATE ON `user` FOR EACH ROW BEGIN
    IF new.status <> old.status THEN BEGIN
        call sp_update_state(now(),NEW.id,time(now()),NEW.status);
    END; END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_states`
--

CREATE TABLE `user_states` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date_ini` date NOT NULL,
  `date_end` date DEFAULT NULL,
  `hour_ini` varchar(8) NOT NULL,
  `hour_end` varchar(8) DEFAULT NULL,
  `state` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `user_states`
--

INSERT INTO `user_states` (`id`, `user_id`, `date_ini`, `date_end`, `hour_ini`, `hour_end`, `state`) VALUES
(1, 1, '2018-05-10', NULL, '10:31:30', NULL, 1),
(2, 2, '2018-05-10', NULL, '10:40:52', NULL, 1),
(3, 3, '2018-05-10', NULL, '10:40:52', NULL, 1),
(7, 9, '2018-05-14', '0000-00-00', '21:22:15', '21:22:31', 4),
(8, 9, '0000-00-00', NULL, '21:22:31', NULL, 2);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `favorite`
--
ALTER TABLE `favorite`
  ADD PRIMARY KEY (`id`,`user_id`,`product_id`),
  ADD KEY `fk_favorite_product1_idx` (`product_id`),
  ADD KEY `fk_favorite_user1_idx` (`user_id`);

--
-- Indices de la tabla `local`
--
ALTER TABLE `local`
  ADD PRIMARY KEY (`id`,`user_id`),
  ADD KEY `fk_local_user1_idx` (`user_id`);

--
-- Indices de la tabla `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id`,`user_id`,`local_id`,`category_id`),
  ADD KEY `fk_product_user1_idx` (`user_id`),
  ADD KEY `fk_product_category1_idx` (`category_id`),
  ADD KEY `fk_product_local1_idx` (`local_id`);

--
-- Indices de la tabla `product_updates`
--
ALTER TABLE `product_updates`
  ADD PRIMARY KEY (`id`,`product_id`),
  ADD KEY `fk_product_updates_product1_idx` (`product_id`);

--
-- Indices de la tabla `purchase`
--
ALTER TABLE `purchase`
  ADD PRIMARY KEY (`id`,`user_id`,`product_id`),
  ADD KEY `fk_purchase_user1_idx` (`user_id`),
  ADD KEY `fk_purchase_product1_idx` (`product_id`);

--
-- Indices de la tabla `purchase_states`
--
ALTER TABLE `purchase_states`
  ADD PRIMARY KEY (`id`,`purchase_id`),
  ADD KEY `fk_purchase_states_purchase1_idx` (`purchase_id`);

--
-- Indices de la tabla `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `mail` (`mail`);

--
-- Indices de la tabla `user_states`
--
ALTER TABLE `user_states`
  ADD PRIMARY KEY (`id`,`user_id`),
  ADD KEY `fk_states_user_idx` (`user_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `category`
--
ALTER TABLE `category`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT de la tabla `favorite`
--
ALTER TABLE `favorite`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `local`
--
ALTER TABLE `local`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `product`
--
ALTER TABLE `product`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT de la tabla `product_updates`
--
ALTER TABLE `product_updates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT de la tabla `purchase`
--
ALTER TABLE `purchase`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT de la tabla `purchase_states`
--
ALTER TABLE `purchase_states`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
--
-- AUTO_INCREMENT de la tabla `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT de la tabla `user_states`
--
ALTER TABLE `user_states`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `favorite`
--
ALTER TABLE `favorite`
  ADD CONSTRAINT `fk_favorite_product1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_favorite_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `local`
--
ALTER TABLE `local`
  ADD CONSTRAINT `fk_local_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `fk_product_category1` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_product_local1` FOREIGN KEY (`local_id`) REFERENCES `local` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_product_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `product_updates`
--
ALTER TABLE `product_updates`
  ADD CONSTRAINT `fk_product_updates_product1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `purchase`
--
ALTER TABLE `purchase`
  ADD CONSTRAINT `fk_purchase_product1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_purchase_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `purchase_states`
--
ALTER TABLE `purchase_states`
  ADD CONSTRAINT `fk_purchase_states_purchase1` FOREIGN KEY (`purchase_id`) REFERENCES `purchase` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `user_states`
--
ALTER TABLE `user_states`
  ADD CONSTRAINT `fk_states_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
