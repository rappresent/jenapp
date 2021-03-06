# ubah custom sql;
DELETE FROM `_` WHERE `id` = 'harga';
INSERT INTO `_` (`id`, `query`, `active`, `notes`)
VALUES
	('harga', 'SELECT\n    a.id_product, a.name, b.name AS \'type\',\n    c.value AS \"product_purchase_price\", c.`id_product_purchase_price` AS \'id_product_purchase_price\',\n    d.value AS \"product_sale_price\", d.`id_product_sale_price` AS \'id_product_sale_price\'\nFROM product AS a\rJOIN `level` AS b ON a.`fk.id_level` = b.`id_level`\rLEFT JOIN (\r    SELECT * FROM (\r        SELECT * FROM product_purchase_price WHERE active = \'1\' ORDER BY `datetime` DESC, `value` DESC\r    ) AS x GROUP BY `fk.id_product`\r) AS c ON a.`id_product` = c.`fk.id_product`\nLEFT JOIN (\r    SELECT * FROM (\r        SELECT * FROM product_sale_price WHERE active = \'1\' ORDER BY `datetime` DESC, `value` DESC\r    ) AS y GROUP BY `fk.id_product`\r) AS d ON a.`id_product` = d.`fk.id_product`\nWHERE a.`active` = \'1\'\nORDER BY `type`, b.`name`;', '0', 'harga jual & harga beli');
## --------------------------------------------------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------------------------------------------------

# tambah data group member;
INSERT INTO `zen`.`member_group` (`id_member_group`, `name`, `active`, `notes`) VALUES ('outlet', 'Outlet', '1', '');
INSERT INTO `zen`.`member_group` (`id_member_group`, `name`, `active`, `notes`) VALUES ('konsinyasi', 'Konsinyasi', '1', '');
## --------------------------------------------------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------------------------------------------------

## Falih views
CREATE 
VIEW `internal_karyawan` AS 
SELECT
  `a`.`id_internal` AS `id`,
  `b`.`first_name` AS `nama_depan`,
  `b`.`last_name` AS `nama_belakang`,
  `c`.`name` AS `cabang`,
  `d`.`name` AS `grup`,
  `a`.`active`
FROM
  (
    (
      (
        `internal` `a`
        RIGHT JOIN `contact` `b` ON (
          (
            `a`.`fk.id_contact` = `b`.`id_contact`
          )
        )
      )
      LEFT JOIN `branch` `c` ON (
        (
          `a`.`fk.id_branch` = `c`.`id_branch`
        )
      )
    )
    LEFT JOIN `internal_group` `d` ON (
      (
        `a`.`fk.id_internal_group` = `d`.`id_internal_group`
      )
    )
  ) ;
  CREATE 
  ## -- view_outlet yang lama dihapus ya broww
VIEW `view_outlet` AS 
SELECT
  a.id_member AS `id`,
  b.first_name AS `nama_outlet`,
  CONCAT(c.address,", ",d.`name`," ",c.zip_code) as `alamat`,
  a.notes,
  a.active
FROM
  member AS a
JOIN contact AS b ON a.`fk.id_contact` = b.id_contact
JOIN contact_addr as c ON c.`fk.id_contact` = b.id_contact
JOIN city as d ON d.id_city = c.`fk.id_city`
WHERE
  a.`fk.id_member_group` = 'outlet' ;
  CREATE 
VIEW `view_supplier` AS 
SELECT
  a.id_supplier,
  b.first_name,
  a.`fk.id_branch`,
  c.`name`,
  a.notes,
  a.active
FROM
  supplier AS a
JOIN contact AS b ON a.`fk.id_contact` = b.id_contact
JOIN supplier_group AS c ON a.`fk.id_supplier_group` = c.id_supplier_group ;
## --------------------------------------------------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------------------------------------------------

# Custom api get product_ex clean
INSERT INTO `_` (`id`, `query`, `active`, `notes`)
VALUES
	('purchase', 'SELECT DISTINCT(X.`fk.id_purchase`) AS \'id_purchase\' FROM (\n    SELECT\n        purchase_ex.`id_purchase_ex`, purchase_ex.`datetime`, purchase_ex.`fk.id_purchase`, purchase_ex.`fk.id_product`,\n        purchase_ex.`modifier`,\n        IF(ISNULL(purchase_ex.`qty` - purchase_bill_ex_.`sum_qty`), purchase_ex.`qty`, (purchase_ex.`qty` - purchase_bill_ex_.`sum_qty`))  AS \'qty\',\n        IF(ISNULL(purchase_bill_ex_.`sum_qty`), 0, purchase_bill_ex_.`sum_qty`)  AS \'sum_qty\',\n        purchase_ex.`fk.id_product_purchase_price`, purchase_ex.`discount`, purchase_ex.`void`, purchase_ex.`complimentary`, purchase_ex.`active`, purchase_ex.`notes`,\n        product.name AS \'name_product\', product_purchase_price.`value`AS \'harga_beli\'\n    FROM purchase_ex\n    LEFT JOIN product ON purchase_ex.`fk.id_product` = product.`id_product`\n    LEFT JOIN product_purchase_price ON purchase_ex.`fk.id_product_purchase_price` = product_purchase_price.`id_product_purchase_price`\n    LEFT JOIN (SELECT *, sum(`qty`) AS \'sum_qty\' FROM purchase_bill_ex WHERE `active` = \'1\' GROUP BY `fk.id_purchase_ex`, `fk.id_product_purchase_price`) AS purchase_bill_ex_\n        ON purchase_ex.`id_purchase_ex` = purchase_bill_ex_.`fk.id_purchase_ex`\n    WHERE purchase_ex.`active` = \'1\'\n) AS X JOIN purchase ON purchase.`id_purchase` = X.`fk.id_purchase` WHERE purchase.`pic` = $id_supplier AND X.`qty` > 0 ORDER BY X.`fk.id_purchase`;', '0', 'clean join with product & product_purchase_price'),
	('purchase_ex', 'SELECT X.* FROM (\n    SELECT\n        purchase_ex.`id_purchase_ex`, purchase_ex.`datetime`, purchase_ex.`fk.id_purchase`, purchase_ex.`fk.id_product`,\n        purchase_ex.`modifier`,\n        IF(ISNULL(purchase_ex.`qty` - purchase_bill_ex_.`sum_qty`), purchase_ex.`qty`, (purchase_ex.`qty` - purchase_bill_ex_.`sum_qty`))  AS \'qty\',\n        IF(ISNULL(purchase_bill_ex_.`sum_qty`), 0, purchase_bill_ex_.`sum_qty`)  AS \'sum_qty\',\n        purchase_ex.`fk.id_product_purchase_price`, purchase_ex.`discount`, purchase_ex.`void`, purchase_ex.`complimentary`, purchase_ex.`active`, purchase_ex.`notes`,\n        product.name AS \'name_product\', product_purchase_price.`value`AS \'harga_beli\'\n    FROM purchase_ex\n    LEFT JOIN product ON purchase_ex.`fk.id_product` = product.`id_product`\n    LEFT JOIN product_purchase_price ON purchase_ex.`fk.id_product_purchase_price` = product_purchase_price.`id_product_purchase_price`\n    LEFT JOIN (SELECT *, sum(`qty`) AS \'sum_qty\' FROM purchase_bill_ex WHERE `active` = \'1\' GROUP BY `fk.id_purchase_ex`, `fk.id_product_purchase_price`) AS purchase_bill_ex_\n        ON purchase_ex.`id_purchase_ex` = purchase_bill_ex_.`fk.id_purchase_ex`\n    WHERE purchase_ex.`fk.id_purchase` = $id_purchase AND purchase_ex.`active` = \'1\' AND !isNULL(purchase_ex.`fk.id_purchase`)\n) AS X WHERE X.`qty` > 0 ORDER BY X.`fk.id_purchase`;', '0', 'join with product & product_purchase_price');
## --------------------------------------------------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------------------------------------------------

# Return tables (sales & purchase)
-- Create syntax for TABLE 'purchase_return'
CREATE TABLE `purchase_return` (
  `id_purchase_return` VARCHAR(50) NOT NULL DEFAULT '',
  `datetime` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
  `fk.id_internal` VARCHAR(30) NOT NULL DEFAULT '',
  `fk.id_supplier` VARCHAR(50) DEFAULT NULL,
  `active` ENUM('0','1') NOT NULL DEFAULT '0',
  `notes` VARCHAR(100) DEFAULT NULL,
  `update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_purchase_return`),
  KEY `fk.id_internal` (`fk.id_internal`),
  KEY `fk.id_supplier` (`fk.id_supplier`),
  CONSTRAINT `purchase_return_ibfk_1` FOREIGN KEY (`fk.id_internal`) REFERENCES `internal` (`id_internal`) ON UPDATE CASCADE,
  CONSTRAINT `purchase_return_ibfk_2` FOREIGN KEY (`fk.id_supplier`) REFERENCES `supplier` (`id_supplier`) ON UPDATE CASCADE
) ENGINE=INNODB DEFAULT CHARSET=latin1;

-- Create syntax for TABLE 'purchase_return_ex'
CREATE TABLE `purchase_return_ex` (
  `id_purchase_return_ex` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `datetime` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
  `fk.id_purchase_return` VARCHAR(50) DEFAULT NULL,
  `fk.id_purchase_bill_ex` BIGINT(20) UNSIGNED DEFAULT NULL,
  `modifier` VARCHAR(255) DEFAULT NULL,
  `qty` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
  `discount` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
  `void` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
  `complimentary` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
  `tax_percent` DOUBLE UNSIGNED DEFAULT '0',
  `tax_amount` DOUBLE UNSIGNED DEFAULT '0',
  `service_percent` DOUBLE UNSIGNED DEFAULT '0',
  `service_amount` DOUBLE UNSIGNED DEFAULT '0',
  `discount_percent` DOUBLE UNSIGNED DEFAULT '0',
  `discount_amount` DOUBLE UNSIGNED DEFAULT '0',
  `active` ENUM('0','1') DEFAULT '0',
  `notes` VARCHAR(255) DEFAULT NULL,
  `update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_purchase_return_ex`),
  KEY `fk.id_purchase_return` (`fk.id_purchase_return`),
  KEY `fk.id_purchase_bill_ex` (`fk.id_purchase_bill_ex`),
  CONSTRAINT `purchase_return_ex_ibfk_1` FOREIGN KEY (`fk.id_purchase_return`) REFERENCES `purchase_return` (`id_purchase_return`) ON UPDATE CASCADE,
  CONSTRAINT `purchase_return_ex_ibfk_2` FOREIGN KEY (`fk.id_purchase_bill_ex`) REFERENCES `purchase_bill_ex` (`id_purchase_bill_ex`) ON UPDATE CASCADE
) ENGINE=INNODB DEFAULT CHARSET=latin1;

-- Create syntax for TABLE 'pos_return'
CREATE TABLE `pos_return` (
  `id_pos_return` VARCHAR(50) NOT NULL DEFAULT '',
  `datetime` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
  `fk.id_internal` VARCHAR(30) NOT NULL DEFAULT '',
  `fk.id_member` VARCHAR(50) DEFAULT NULL,
  `active` ENUM('0','1') NOT NULL DEFAULT '0',
  `notes` VARCHAR(100) DEFAULT NULL,
  `update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pos_return`),
  KEY `fk.id_internal` (`fk.id_internal`),
  KEY `fk.id_member` (`fk.id_member`),
  CONSTRAINT `pos_return_ibfk_1` FOREIGN KEY (`fk.id_internal`) REFERENCES `internal` (`id_internal`) ON UPDATE CASCADE,
  CONSTRAINT `pos_return_ibfk_2` FOREIGN KEY (`fk.id_member`) REFERENCES `member` (`id_member`) ON UPDATE CASCADE
) ENGINE=INNODB DEFAULT CHARSET=latin1;

-- Create syntax for TABLE 'pos_return_ex'
CREATE TABLE `pos_return_ex` (
  `id_pos_return_ex` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `datetime` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00',
  `fk.id_pos_return` VARCHAR(50) DEFAULT NULL,
  `fk.id_pos_bill_ex` BIGINT(20) UNSIGNED DEFAULT NULL,
  `modifier` VARCHAR(255) DEFAULT NULL,
  `qty` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
  `discount` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
  `void` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
  `complimentary` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
  `tax_percent` DOUBLE UNSIGNED DEFAULT '0',
  `tax_amount` DOUBLE UNSIGNED DEFAULT '0',
  `service_percent` DOUBLE UNSIGNED DEFAULT '0',
  `service_amount` DOUBLE UNSIGNED DEFAULT '0',
  `discount_percent` DOUBLE UNSIGNED DEFAULT '0',
  `discount_amount` DOUBLE UNSIGNED DEFAULT '0',
  `active` ENUM('0','1') DEFAULT '0',
  `notes` VARCHAR(255) DEFAULT NULL,
  `update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pos_return_ex`),
  KEY `fk.id_pos_return` (`fk.id_pos_return`),
  KEY `fk.id_pos_bill_ex` (`fk.id_pos_bill_ex`),
  CONSTRAINT `pos_return_ex_ibfk_1` FOREIGN KEY (`fk.id_pos_return`) REFERENCES `pos_return` (`id_pos_return`) ON UPDATE CASCADE,
  CONSTRAINT `pos_return_ex_ibfk_2` FOREIGN KEY (`fk.id_pos_bill_ex`) REFERENCES `pos_bill_ex` (`id_pos_bill_ex`) ON UPDATE CASCADE
) ENGINE=INNODB DEFAULT CHARSET=latin1;
## --------------------------------------------------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO `zen`.`_` (`id`, `query`, `active`, `notes`) VALUES ('get_price_id', 'select * from product_sale_price where `fk.id_product` = $id_product AND value = $value', '0', 'buat cek id harga');

## hapus dulu view 'internal_karyawan', bikin baru lagi. gua gak tau syntax otomatisnya
SELECT
  `a`.`id_internal` AS `id`,
  `b`.`first_name` AS `nama_depan`,
  `b`.`last_name` AS `nama_belakang`,
  `c`.`name` AS `cabang`,
  `d`.`name` AS `grup`,
  `a`.`active`
FROM
  (
    (
      (
        `internal` `a`
        JOIN `contact` `b` ON (
          (
            `a`.`fk.id_contact` = `b`.`id_contact`
          )
        )
      )
      LEFT JOIN `branch` `c` ON (
        (
          `a`.`fk.id_branch` = `c`.`id_branch`
        )
      )
    )
    LEFT JOIN `internal_group` `d` ON (
      (
        `a`.`fk.id_internal_group` = `d`.`id_internal_group`
      )
    )
  ) ;
## --------------------------------------------------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------------------------------------------------

# Query buat stok
INSERT INTO `_` (`id`, `query`, `active`, `notes`)
VALUES
	('stock', 'SELECT \n    ppp.`fk.id_product` AS `code`, p.name, pb.ippp, ppp.value,\n    SUM(pb.qty) AS qty_p, SUM(IF(ISNULL(pr.qty), 0, pr.qty)) AS qty_r,\n    SUM(pb.qty - IF(ISNULL(pr.qty), 0, pr.qty)) AS qty,\n    pb.ipx, pb.ipb, DATE(pb.datetime) AS ipb_date, pb.ipbx, pr.ipr, DATE(pr.datetime) AS ipr_date\nFROM (\n    SELECT\n        pb.`datetime`, pbx.`fk.id_purchase_ex` AS ipx, pb.`id_purchase_bill` AS ipb,\n        pbx.`id_purchase_bill_ex` AS ipbx, pbx.`fk.id_product_purchase_price` AS ippp, pbx.`qty`\n    FROM purchase_bill AS pb\n    JOIN purchase_bill_ex pbx ON pb.`id_purchase_bill` = pbx.`fk.id_purchase_bill`\n    WHERE pb.`active`=\'1\' AND pbx.`active` = \'1\'\n) AS pb\nLEFT JOIN (\n    SELECT\n        pr.`DATETIME`, prx.`fk.id_purchase_bill_ex` AS ipbx, pr.`id_purchase_return` AS ipr,\n        prx.`id_purchase_return_ex` AS iprx, SUM(prx.`qty`) AS `qty`\n    FROM purchase_return AS pr\n    JOIN purchase_return_ex AS prx ON pr.`id_purchase_return` = prx.`fk.id_purchase_return`\n    WHERE pr.`active`=\'1\' AND prx.`active` = \'1\'\n    GROUP BY ipbx\n) AS pr ON pr.ipbx = pb.ipbx\nJOIN product_purchase_price AS ppp ON ppp.`id_product_purchase_price` = pb.ippp\nJOIN product AS p ON p.`id_product` = ppp.`fk.id_product`\nWHERE pb.datetime >= $start\nGROUP BY pb.ippp;', '0', NULL);
## --------------------------------------------------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------------------------------------------------
# Query buat retur pengiriman
INSERT INTO `zen`.`_` (`id`, `query`, `active`, `notes`) VALUES ('get_retur_kirim_detail', 'SELECT\r\n  a.id_pos,\r\n d.id_pos_bill_ex,\r\n b.`fk.id_product` as `id_product`,\r\n  c.`name`,\r\n (d.qty - (select IFNULL(SUM(x.qty),0) FROM pos_return_ex as x WHERE x.`fk.id_pos_bill_ex` = d.id_pos_bill_ex)) as `qty_available`,\r\n  (select IFNULL(SUM(x.qty),0) FROM pos_return_ex as x WHERE x.`fk.id_pos_bill_ex` = d.id_pos_bill_ex) as `qty_retur`,\r\n  f.`value` as `harga`\r\nFROM\r\n  pos AS a\r\nJOIN pos_ex AS b ON a.id_pos = b.`fk.id_pos`\r\nJOIN product AS c ON b.`fk.id_product` = c.id_product\r\nJOIN pos_bill_ex as d ON b.id_pos_ex = d.`fk.id_pos_ex`\r\nJOIN product_sale_price as f ON d.`fk.id_product_sale_price` = f.`id_product_sale_price`\r\nWHERE a.id_pos = $id_pos', '0', 'untuk ambil detail barang yg di retur pengiriman');
## --------------------------------------------------------------------------------------------------------------------------------------------------
## --------------------------------------------------------------------------------------------------------------------------------------------------
