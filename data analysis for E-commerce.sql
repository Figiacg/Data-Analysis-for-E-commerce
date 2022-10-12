CREATE SCHEMA ecomdqlab;

CREATE TABLE `ecomdqlab`.`users` (
  `user_id` INT NOT NULL,
  `nama_user` VARCHAR(255) NULL,
  `kodepos` VARCHAR(10) NULL,
  `email` VARCHAR(255) NULL,
  PRIMARY KEY (`user_id`));
  
CREATE TABLE `ecomdqlab`.`products` (
  `product_id` INT NOT NULL,
  `desc_product` VARCHAR(255) NULL,
  `category` VARCHAR(255) NULL,
  `base_price` INT NULL,
  PRIMARY KEY (`product_id`));

CREATE TABLE `ecomdqlab`.`orders` (
  `order_id` INT NOT NULL,
  `seller_id` INT NULL,
  `buyer_id` INT NULL,
  `kodepos` VARCHAR(10) NULL,
  `subtotal` INT NULL,
  `discount` INT NULL,
  `total` INT NULL,
  `created_at` VARCHAR(45) NULL,
  `paid_at` VARCHAR(45) NULL,
  `delivery_at` VARCHAR(45) NULL,
  PRIMARY KEY (`order_id`));
  
UPDATE ecomdqlab.orders SET created_at = STR_TO_DATE(created_at, '%Y-%m-%d');
ALTER TABLE ecomdqlab.orders CHANGE COLUMN created_at created_at DATE;

UPDATE ecomdqlab.orders SET paid_at = STR_TO_DATE(paid_at, '%Y-%m-%d') WHERE paid_at != 'NA';
UPDATE ecomdqlab.orders SET paid_at = '0000-00-00' WHERE paid_at = 'NA';
ALTER TABLE ecomdqlab.orders CHANGE COLUMN paid_at paid_at DATE;

UPDATE ecomdqlab.orders SET delivery_at = STR_TO_DATE(delivery_at, '%Y-%m-%d') WHERE delivery_at != 'NA';
UPDATE ecomdqlab.orders SET delivery_at = '0000-00-00' WHERE delivery_at = 'NA';
ALTER TABLE ecomdqlab.orders CHANGE COLUMN delivery_at delivery_at DATE;

CREATE TABLE `ecomdqlab`.`order_details` (
  `order_detail_id` INT NOT NULL,
  `order_id` INT NULL,
  `product_id` INT NULL,
  `price` INT NULL,
  `quantity` INT NULL,
  PRIMARY KEY (`order_detail_id`));
  
----------------------------------------------------------------------------------------------------------------------------------------

-- DATA PRODUCTS --

-- ada 4 kolom data products
SELECT * FROM ecomdqlab.products;
-- ada 1145 baris pada data products
SELECT COUNT(*) AS total_data FROM ecomdqlab.products;
-- ada 12 jenis kategori products
SELECT COUNT(DISTINCT(category)) AS total_category FROM ecomdqlab.products;
-- tidak ada variabel yang mempunyai nilai NULL/kosong
SELECT * FROM ecomdqlab.products
WHERE product_id IS NULL
OR desc_product IS NULL
OR category IS NULL
OR base_price IS NULL;

-- DATA ORDERS --

-- ada 10 kolom/variabel pada data orders
SELECT * FROM ecomdqlab.orders;
-- ada 74874 baris pada data orders
SELECT COUNT(*) AS total_data FROM ecomdqlab.orders;
-- ada 2 variabel yang mempunyai nilai NULL / kosong
SELECT * FROM ecomdqlab.orders
WHERE order_id IS NULL
OR seller_id IS NULL
OR buyer_id IS NULL
OR kodepos IS NULL
OR subtotal IS NULL
OR discount IS NULL
OR total IS NULL
OR created_at IS NULL
OR paid_at = '0000-00-00'
OR delivery_at = '0000-00-00';

-- JUMLAH TRANSAKSI BULANAN --

-- ada 4327 transaksi di bulan September 2019
SELECT COUNT(order_id) AS jumlah_transaksi FROM ecomdqlab.orders WHERE created_at BETWEEN '2019-09-01' AND '2019-09-30';
-- ada 7162 transaksi di bulan November 2019
SELECT COUNT(order_id) AS jumlah_transaksi FROM ecomdqlab.orders WHERE created_at BETWEEN '2019-11-01' AND '2019-11-30';
-- ada 5062 transaksi di bulan Januari 2020
SELECT COUNT(order_id) AS jumlah_transaksi FROM ecomdqlab.orders WHERE created_at BETWEEN '2020-01-01' AND '2020-01-31';
-- ada 7323 transaksi di bulan Maret 2020
SELECT COUNT(order_id) AS jumlah_transaksi FROM ecomdqlab.orders WHERE created_at BETWEEN '2020-03-01' AND '2020-03-31';
-- ada 10026 transaksi di bulan Mei 2020
SELECT COUNT(order_id) AS jumlah_transaksi FROM ecomdqlab.orders WHERE created_at BETWEEN '2020-05-01' AND '2020-05-31';

-- STATUS TRANSAKSI --

-- ada 5046 transaksi yang tidak dibayar
SELECT COUNT(order_id) AS jumlah_transaksi FROM ecomdqlab.orders WHERE paid_at = '0000-00-00';
-- ada 4744 transaksi yang sudah dibayar tapi tidak dikirim
SELECT COUNT(order_id) AS jumlah_transaksi FROM ecomdqlab.orders WHERE paid_at != '0000-00-00' AND delivery_at = '0000-00-00';
-- ada total 9790 transaksi yang tidak dikrim, baik sudah dibayar maupun belum
SELECT COUNT(order_id) AS jumlah_transaksi FROM ecomdqlab.orders WHERE delivery_at = '0000-00-00';
-- ada 4588 transaksi yang dikirim pada hari yang sama dengan tangal dibayar
SELECT COUNT(order_id) AS jumlah_transaksi FROM ecomdqlab.orders WHERE delivery_at = paid_at AND delivery_at != '0000-00-00' AND paid_at != '0000-00-00';

-- PENGGUNA BERTRANSAKSI --

-- ada 17936 total pengguna
SELECT COUNT(DISTINCT user_id) AS total_pengguna FROM ecomdqlab.users;
-- ada 17877 pengguna yang pernah bertransaksi sebagai pembeli
SELECT COUNT(DISTINCT buyer_id) AS total_pengguna FROM ecomdqlab.orders;
-- ada 69 pengguna yang pernah bertransaksi sebagai penjual
SELECT COUNT(DISTINCT seller_id) AS total_pengguna FROM ecomdqlab.orders;
-- ada 69 pengguna yang pernah bertransaksi sebagai pembeli dan pernah sebagai penjual
SELECT COUNT(DISTINCT seller_id) AS total_pengguna FROM ecomdqlab.orders WHERE seller_id IN (SELECT buyer_id FROM ecomdqlab.orders);
-- ada 59 pengguna yang tidak pernah bertransaksi sebagai pembeli maupun penjual
SELECT COUNT(DISTINCT user_id) AS total_pengguna FROM ecomdqlab.users
WHERE user_id NOT IN (SELECT buyer_id FROM ecomdqlab.orders)
AND user_id NOT IN (SELECT seller_id FROM ecomdqlab.orders);

-- TOP BUYER ALL TIME --

-- 5 pembeli dengan dengan total pembelian terbesar
SELECT buyer_id, nama_user, SUM(total) AS total FROM ecomdqlab.orders AS a
LEFT JOIN ecomdqlab.users AS b ON a.buyer_id = b.user_id
GROUP BY buyer_id
ORDER BY SUM(total) DESC
LIMIT 5;

-- FREQUENT BUYER --

-- 5 pembeli dengan transaksi terbanyak dan tidak pernah menggunakan diskon
SELECT buyer_id, nama_user, SUM(discount) as total_diskon, SUM(paid_at) AS total_transaksi FROM ecomdqlab.orders AS a
LEFT JOIN ecomdqlab.users AS b ON a.buyer_id = b.user_id
GROUP BY buyer_id
ORDER BY SUM(paid_at) DESC 
LIMIT 10;

-- BIG FREQUENT BUYER 2020 --

-- pengguna yang bertransaksi setidaknya 1 kali setiap bulan di tahun 2020 dengan rata-rata total amount per transaksi lebih dari 1 Juta
SELECT buyer_id, email, rata_rata, month_count
FROM (SELECT a.buyer_id, rata_rata, jumlah_transaksi, month_count
FROM (SELECT buyer_id, ROUND(AVG(total), 2) AS rata_rata FROM ecomdqlab.orders
		WHERE DATE_FORMAT(created_at, '%Y') = '2020'
        GROUP BY buyer_id
        HAVING rata_rata > 1000000
        ORDER BY buyer_id) AS a
JOIN (SELECT buyer_id, COUNT(order_id) AS jumlah_transaksi, COUNT(DISTINCT DATE_FORMAT(created_at, '%m')) AS month_count
		FROM ecomdqlab.orders
		WHERE DATE_FORMAT(created_at, '%Y') = '2020'
        GROUP BY buyer_id
        HAVING month_count >= 5
			   AND
               jumlah_transaksi >= month_count
		ORDER BY buyer_id) AS b
ON a.buyer_id = b.buyer_id) as c
JOIN ecomdqlab.users ON buyer_id = user_id;

-- DOMAIN EMAIL DARI PENJUAL --

SELECT DISTINCT SUBSTR(email, INSTR(email, '@') + 1) AS domain_email, COUNT(user_id) AS total_pengguna
FROM ecomdqlab.users
WHERE user_id IN (SELECT seller_id FROM ecomdqlab.orders)
GROUP BY SUBSTR(email, INSTR(email, '@') + 1);

-- TOP 5 PRODUCT DECEMBER 2019 --

-- top 5 produk yang dibeli di bulan desember 2019 berdasarkan total quantity
SELECT desc_product, SUM(quantity) AS total_quantity FROM ecomdqlab.order_details AS a
JOIN ecomdqlab.products AS b
ON a.product_id = b.product_id
JOIN ecomdqlab.orders AS c
ON a.order_id = c.order_id
WHERE created_at BETWEEN '2019-12-01' AND '2019-12-31'
GROUP BY desc_product
ORDER BY SUM(quantity) DESC
LIMIT 5;

-- 10 TRANSAKSI TERBESAR USER 12476 --

SELECT seller_id, buyer_id, total AS nilai_transaksi, created_at AS tanggal_transaksi
FROM ecomdqlab.orders
WHERE buyer_id = 12476
ORDER BY 3 DESC
LIMIT 10;

-- TRANSAKSI PER BULAN DI TAHUN 2020 --

SELECT EXTRACT(YEAR_MONTH FROM created_at) AS tahun_bulan, COUNT(1) AS jumlah_transaksi, SUM(total) AS total_nilai_transaksi
FROM ecomdqlab.orders
WHERE created_at >= '2020-01-01'
GROUP BY 1
ORDER BY 1;

-- PENGGUNA DENGAN RATA-RATA TRANSAKSI TERBESAR DI JANUARI 2020 --

-- 10 pembeli dengan rata-rata nilai transaksi terbesar yang bertransaksi minimal 2 kali di Januari 2020
SELECT buyer_id, COUNT(1) AS jumlah_transaksi, AVG(total) AS avg_nilai_transaksi
FROM ecomdqlab.orders
WHERE created_at >= '2020-01-01' AND created_at < '2020-02-01'
GROUP BY 1
HAVING COUNT(1) >= 2
ORDER BY 3 DESC
LIMIT 10;

-- TRANSAKSI BESAR DI DESEMBER 2019 --

-- nilai transaksi minimal 20000000 di bulan Desember 2019
SELECT nama_user AS nama_pembeli, total AS nilai_transaksi, created_at AS tanggal_transaksi
FROM ecomdqlab.orders
INNER JOIN ecomdqlab.users ON buyer_id = user_id
WHERE created_at >= '2019-12-01' AND created_at < '2020-01-01'
AND total >= 20000000
ORDER BY 1;

-- KATEGORI PRODUK TERLARIS DI 2020 --

-- 5 Kategori dengan total quantity terbanyak di tahun 2020, hanya untuk transaksi yang sudah terkirim ke pembeli
SELECT category, SUM(quantity) AS total_quantity, SUM(price) AS total_price
FROM ecomdqlab.orders
INNER JOIN ecomdqlab.order_details USING(order_id)
INNER JOIN ecomdqlab.products USING(product_id)
WHERE created_at >= '2020-01-01'
AND delivery_at IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- MENCARI PEMBELI HIGH VALUE --

-- pembeli yang sudah bertransaksi lebih dari 5 kali, dan setiap transaksi lebih dari 2000000
SELECT nama_user AS nama_pembeli, COUNT(1) AS jumlah_transaksi, SUM(total) AS total_nilai_transaksi, MIN(total) AS min_nilai_transaksi
FROM orders
INNER JOIN users ON buyer_id = user_id
GROUP BY user_id, nama_user
HAVING COUNT(1) > 5 AND MIN(total) > 2000000
ORDER BY 3 DESC;

-- MENCARI DROPSHIPPER --

-- pembeli dengan 10 kali transaksi atau lebih yang alamat pengiriman transaksi selalu berbeda setiap transaksi
SELECT nama_user AS nama_pembeli, COUNT(1) AS jumlah_transaksi, COUNT(DISTINCT orders.kodepos) AS distinct_kodepos,
	   SUM(total) AS total_nilai_transaksi, AVG(total) AS avg_nilai_transaksi
FROM ecomdqlab.orders
INNER JOIN ecomdqlab.users ON buyer_id = user_id
GROUP BY user_id, nama_user
HAVING COUNT(1) >= 10 AND COUNT(1) = COUNT(DISTINCT orders.kodepos)
ORDER BY 2 DESC;

-- MENCARI RESELLER OFFLINE --

-- pembeli yang punya 8 atau lebih transaksi yang alamat pengiriman transaksi sama dengan alamat pengiriman utama,
-- dan rata-rata total quantity per transaksi lebih dari 10
SELECT nama_user AS nama_pembeli, COUNT(1) AS jumlah_transaksi, SUM(total) AS total_nilai_transaksi,
	   AVG(total) AS avg_nilai_transaksi, AVG(total_quantity) AS avg_quantity_per_transaksi
FROM ecomdqlab.orders
INNER JOIN ecomdqlab.users ON buyer_id = user_id
INNER JOIN (SELECT order_id, SUM(quantity) AS total_quantity FROM ecomdqlab.order_details GROUP BY 1) AS summary_order USING(order_id)
WHERE orders.kodepos = users.kodepos
GROUP BY user_id, nama_user
HAVING COUNT(1) >= 8 AND AVG(total_quantity) > 10
ORDER BY 3 DESC;

-- PEMBELI SEKALIGUS PENJUAL --

-- penjual yang juga pernah bertransaksi sebagai pembeli minimal 7 kali
SELECT nama_user AS nama_pengguna, jumlah_transaksi_beli, jumlah_transaksi_jual
FROM ecomdqlab.users
INNER JOIN (SELECT buyer_id, COUNT(1) AS jumlah_transaksi_beli FROM ecomdqlab.orders GROUP BY 1) AS buyer ON buyer_id = user_id
INNER JOIN (SELECT seller_id, COUNT(1) AS jumlah_transaksi_jual FROM ecomdqlab.orders GROUP BY 1) AS seller ON seller_id = user_id
WHERE jumlah_transaksi_beli >= 7
ORDER BY 1;

-- LAMA TRANSAKSI DIBAYAR --

-- menghitung rata-rata lama waktu dari transaksi dibuat sampai dibayar, dikelompokkan per bulan
SELECT EXTRACT(YEAR_MONTH FROM created_at) AS tahun_bulan, COUNT(1) AS jumlah_transaksi,
	   AVG(datediff(paid_at, created_at)) AS avg_lama_dibayar,
       MIN(datediff(paid_at, created_at)) AS min_lama_dibayar,
       MAX(datediff(paid_at, created_at)) AS max_lama_dibayar
FROM ecomdqlab.orders
WHERE paid_at IS NOT NULL
GROUP BY 1
ORDER BY 1;