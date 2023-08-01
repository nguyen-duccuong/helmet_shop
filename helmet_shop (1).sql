-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 29, 2022 at 08:01 AM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `helmet_shop`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DOANH_THU` (IN `ngaybatdau` DATE, IN `ngayketthuc` DATE)  NO SQL SELECT MONTH(created_at) AS THANG, YEAR(created_at) AS NAM, ROUND(SUM(total),2) AS DOANHTHU
		FROM orders as O
		WHERE DATE(O.created_at)>= ngaybatdau AND DATE(O.created_at)<= ngayketthuc AND status != '4'
		GROUP BY MONTH(created_at)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GIAO_HANG` (IN `maquan` VARCHAR(20) CHARSET utf8)  NO SQL SELECT id_employee, E.name, ifnull(A.chuagiao,0) DONCHUAGIAO, ifnull(B.hoantat,0) DONHOANTAT, ifnull((ifnull(A.chuagiao,0) + ifnull(B.hoantat,0)),0) TONGSODON
FROM division_detail DV
LEFT JOIN employee E ON E.id = DV.id_employee

LEFT JOIN (SELECT id_shipper, COUNT(id_shipper) chuagiao FROM orders WHERE status=1 OR status=2 GROUP BY id_shipper) A ON A.id_shipper = DV.id_employee

LEFT JOIN (SELECT id_shipper, COUNT(id_shipper) hoantat FROM orders WHERE status=3 GROUP BY id_shipper) B ON B.id_shipper = DV.id_employee

WHERE district_code = maquan COLLATE utf8_unicode_ci 
ORDER BY A.chuagiao ASC, TONGSODON ASC, B.hoantat ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LOI_NHUAN` (IN `ngaybatdau` DATE)  NO SQL SELECT P.product_code, P.name, ifnull(SL,0) TSL, ifnull(XTB,0) DGXTB, ifnull(NTB,0) DGNTB, ifnull(X.SL*(X.XTB - L.NTB),0) LN
FROM products P
INNER JOIN (select IDT.product_code PI, ROUND((SUM(ifnull(IDT.price,0)*ifnull(IDT.quantity_in,0))/ SUM(ifnull(IDT.quantity_in,1))),2) NTB 
           FROM import_detail IDT WHERE import_code in 
           (select import_code from import AS I where DATE(I.created_at) <= ngaybatdau )
           GROUP BY IDT.product_code) L on P.product_code = PI
           
LEFT JOIN (select OD.product_code PC, ROUND((sUM(ifnull(OD.price,0)*ifnull(OD.quantity_out,0))/ SUM(ifnull(quantity_out,1))),2) XTB , SUM(ifnull(OD.quantity_out,0)) SL 
           FROM orders_detail OD WHERE id_order in 
           (select id from orders AS O where O.status != '4' AND DATE(O.created_at) <= ngaybatdau )
           GROUP BY OD.product_code) X on  P.product_code = PC
           ORDER BY product_code$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SAN_PHAM_BAN` (IN `ngaybatdau` DATE, IN `ngayketthuc` DATE)  NO SQL SELECT od.product_code,p.name, sum(od.quantity_out) AS SLB
		FROM orders_detail od, orders o, products p 
		WHERE od.id_order=o.id AND p.product_code = od.product_code AND o.status != '4' AND DATE(o.created_at) >= ngaybatdau AND DATE(o.created_at)<=ngayketthuc
		GROUP BY od.product_code 
		ORDER BY od.product_code$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_TON_KHO` (IN `ngaybatdau` DATE)  NO SQL SELECT C.cate_code, C.name AS cate_name, P.product_code, P.name, ifnull(L.QI,0)AS tongnhap, ifnull(X.QO,0) AS tongxuat, (ifnull(L.QI,0) - ifnull(X.QO,0)) AS tonkho
FROM products P 

LEFT JOIN (select OD.product_code PC, SUM(quantity_out) QO FROM orders_detail OD WHERE id_order in 
           (select id from orders AS O where DATE(O.created_at) <= ngaybatdau and O.status != '4')
           GROUP BY OD.product_code) X on  P.product_code = PC 
           
LEFT JOIN (select IDT.product_code PI, SUM(quantity_in) QI FROM import_detail IDT WHERE import_code in 
           (select import_code from import AS I where DATE(I.created_at) <= ngaybatdau)
           GROUP BY IDT.product_code) L on P.product_code = PI
           
INNER JOIN categories C 
ON P.cate_code = C.cate_code
ORDER BY C.cate_code, P.product_code$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `bills`
--

CREATE TABLE `bills` (
  `bill_code` varchar(20) NOT NULL,
  `created_at` date NOT NULL,
  `fax` int(11) DEFAULT NULL,
  `id_order` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `bills`
--

INSERT INTO `bills` (`bill_code`, `created_at`, `fax`, `id_order`) VALUES
('HD-180', '2022-11-25', NULL, 180),
('HD-181', '2022-11-25', NULL, 181),
('HD-182', '2022-11-25', NULL, 182),
('HD-183', '2022-11-25', NULL, 183),
('HD-184', '2022-11-25', NULL, 184),
('HD-185', '2022-11-25', NULL, 185),
('HD-190', '2022-11-25', NULL, 190),
('HD-192', '2022-11-25', NULL, 192),
('HD-194', '2022-11-25', NULL, 194),
('HD-195', '2022-11-25', NULL, 195),
('HD-196', '2022-11-25', NULL, 196),
('HD-197', '2022-11-25', NULL, 197),
('HD-198', '2022-11-25', NULL, 198),
('HD-199', '2022-11-25', NULL, 199),
('HD-200', '2022-11-25', NULL, 200),
('HD-201', '2022-11-25', NULL, 201);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `cate_code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` int(1) NOT NULL COMMENT '0: chưa xóa, 1: đã xóa'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`cate_code`, `name`, `status`) VALUES
('BT', 'Mũ 3/4 đầu', 0),
('FF', 'Mũ Fullface', 0),
('LC', 'Mũ lật cằm', 0),
('ND', 'Mũ 1/2 đầu', 0);

-- --------------------------------------------------------

--
-- Table structure for table `comment`
--

CREATE TABLE `comment` (
  `cmt_code` varchar(20) NOT NULL,
  `contents` varchar(500) NOT NULL,
  `product_code` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `comment_customer`
--

CREATE TABLE `comment_customer` (
  `id_customer` int(12) NOT NULL,
  `comment_code` varchar(20) NOT NULL,
  `contents` varchar(500) NOT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `comment_employee`
--

CREATE TABLE `comment_employee` (
  `id_employee` int(12) NOT NULL,
  `comment_code` varchar(20) NOT NULL,
  `contents` varchar(500) NOT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` int(12) NOT NULL,
  `username` varchar(12) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(12) NOT NULL,
  `name` varchar(50) NOT NULL,
  `gender` enum('Nam','Nữ') DEFAULT NULL,
  `address` varchar(100) NOT NULL,
  `district_code` varchar(20) NOT NULL,
  `phone` varchar(10) NOT NULL,
  `status` enum('0','1') NOT NULL COMMENT '0=Chưa kích hoạt\r\n1=Đã kích hoạt',
  `id_role` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `username`, `email`, `password`, `name`, `gender`, `address`, `district_code`, `phone`, `status`, `id_role`) VALUES
(6, 'phipgn', 'phipgn@gmail.com', '123456', 'Gia Phi', 'Nam', '147 triều khúc', 'QTX', '0982769791', '1', 5),
(38, 'phipgn2', 'phipgn2@gmail.com', '123456', 'Gia Phi', 'Nam', '138 triều khúc', 'QTX', '0123123123', '0', 5),
(39, 'hoailinh', 'hoailinh@gmail.com', '123456', 'Hoài Linh', 'Nam', '30 đống đa', 'QDD', '0333789987', '0', 5),
(41, 'hongtham', 'hongtham@gmail.com', '123456', 'Hồng Thắm', 'Nữ', '36 hoàn kiếm', 'QHK', '0333344466', '1', 5),
(46, 'nguyenlam', 'nguyenlam@gmail.com', '123456', 'Nguyễn Tùng Lâm', 'Nam', 'Hà Nội', 'TXST', '0333639679', '1', 5),
(49, 'Tham98', 'phamtram291195@gmail.com', '123456', 'Hồng Thắm', 'Nữ', '37 hoàng mai', 'QHM', '0333639679', '1', 5),
(53, 'Quynh98', 'quynhfl39@gmail.com', '123456', 'Phạm Quỳnh', 'Nữ', '52 triều khúc', 'QTX', '0333347268', '1', 5),
(55, 'thanhloan', 'thanhloann13.13.2002@gmail.com', '123456', 'Trịnh Thanh Loan', 'Nữ', '83b,tân triều', 'QTX', '0989859490', '1', 5),
(57, 'tuglam', 'nguyenlam16072002@gmail.com', '123456', 'Tung lam nguyen', 'Nam', '83b tân triều', 'QTX', '0353088306', '1', 5);

-- --------------------------------------------------------

--
-- Table structure for table `district`
--

CREATE TABLE `district` (
  `district_code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `district`
--

INSERT INTO `district` (`district_code`, `name`) VALUES
('HBV', 'H. Ba Vì'),
('HBC', 'H. Bình Chánh'),
('HCG', 'H. Cần Giờ'),
('HCM', 'H. Chương Mỹ'),
('HCC', 'H. Củ Chi'),
('HDP', 'H. Đan Phượng'),
('HDA', 'H. Đông Anh'),
('HGL', 'H. Gia Lâm'),
('HHD', 'H. Hoài Đức'),
('HHM', 'H. Hóc Môn'),
('HML', 'H. Mê Linh'),
('HNB', 'H. Nhà Bè'),
('QBD', 'Q. Ba Đình'),
('QBTL', 'Q. Bắc Từ Liêm'),
('QBTA', 'Q. Bình Tân'),
('QBTH', 'Q. Bình Thạnh'),
('QCG', 'Q. Cầu Giấy'),
('QDD', 'Q. Đống Đa'),
('QGV', 'Q. Gò Vấp'),
('QHD', 'Q. Hà Đông'),
('QHBT', 'Q. Hai Bà Trưng'),
('QHK', 'Q. Hoàn Kiếm'),
('QHM', 'Q. Hoàng Mai'),
('QLB', 'Q. Long Biên'),
('QNTL', 'Q. Nam Từ Liêm'),
('QPN', 'Q. Phú Nhuận'),
('QTB', 'Q. Tân Bình'),
('QTP', 'Q. Tân Phú'),
('QTH', 'Q. Tây Hồ'),
('QTX', 'Q. Thanh Xuân'),
('QTD', 'Q. Thủ Đức'),
('Q01', 'Q.1'),
('Q10', 'Q.10'),
('Q11', 'Q.11'),
('Q12', 'Q.12'),
('Q02', 'Q.2'),
('Q03', 'Q.3'),
('Q04', 'Q.4'),
('Q05', 'Q.5'),
('Q06', 'Q.6'),
('Q07', 'Q.7'),
('Q08', 'Q.8'),
('Q09', 'Q.9'),
('TXST', 'TX. Sơn Tây');

-- --------------------------------------------------------

--
-- Table structure for table `division_detail`
--

CREATE TABLE `division_detail` (
  `district_code` varchar(20) NOT NULL,
  `id_employee` int(12) NOT NULL,
  `status` enum('0','1') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `division_detail`
--

INSERT INTO `division_detail` (`district_code`, `id_employee`, `status`) VALUES
('HBC', 4, '1'),
('HBC', 8, '1'),
('HCC', 3, '1'),
('HCC', 8, '1'),
('HCG', 3, '1'),
('HCG', 8, '1'),
('HHM', 3, '1'),
('HNB', 3, '1'),
('Q01', 3, '1'),
('Q01', 4, '1'),
('Q01', 8, '1'),
('Q02', 3, '1'),
('Q02', 4, '1'),
('Q02', 6, '1'),
('Q03', 4, '1'),
('Q03', 8, NULL),
('Q04', 4, '1'),
('Q05', 4, '1'),
('Q06', 4, '1'),
('Q06', 5, '1'),
('Q07', 4, '1'),
('Q07', 5, '1'),
('Q08', 5, '1'),
('Q09', 4, NULL),
('Q09', 5, NULL),
('Q09', 8, NULL),
('Q10', 5, '1'),
('Q11', 5, '1'),
('Q11', 6, '1'),
('Q12', 5, '1'),
('Q12', 6, '1'),
('QBTA', 6, '1'),
('QBTH', 6, '1'),
('QGV', 6, '1'),
('QPN', 6, '1'),
('QPN', 8, '1'),
('QTB', 6, '1'),
('QTB', 8, '1'),
('QTD', 8, '1'),
('QTP', 8, '1');

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE `employee` (
  `id` int(12) NOT NULL,
  `username` varchar(12) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(12) NOT NULL,
  `name` varchar(50) NOT NULL,
  `gender` enum('Nam','Nữ') NOT NULL,
  `address` varchar(100) NOT NULL,
  `phone` varchar(10) NOT NULL,
  `status` int(1) NOT NULL,
  `id_role` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`id`, `username`, `email`, `password`, `name`, `gender`, `address`, `phone`, `status`, `id_role`) VALUES
(1, 'admin', 'nguyenlam16072002@gmail.com', '123456', 'Nguyễn Tùng Lâm', 'Nam', 'Hà Nội', '0353088306', 1, 1),
(2, 'manager', 'manager@gmail.com', '123456', 'Trịnh Loan', 'Nữ', 'Hải Dương', '0333836638', 1, 2),
(3, 'chaukietluan', 'vietanh@gmail.com', '123456', 'VIệt Anh', 'Nam', 'Hưng Yên', '0333222444', 1, 4),
(4, 'sontung', 'sontung@gmail.com', '123456', 'Đức Anh', 'Nam', 'Thái bình', '0394000123', 1, 4),
(5, 'ducphuc', 'ducphuc@gmail.com', '123456', 'Đức Phúc', 'Nam', 'Hà Nội', '0333836632', 1, 4),
(6, 'vinhhung', 'damvinhhung@gmail.com', '123456', 'Đàm Vĩnh Hưng', 'Nam', 'Thành phố HCM', '0333375123', 1, 4),
(7, 'approver', 'approver@gmail.com', '123456', 'Đức Hiệp', 'Nam', 'Hà Nội', '0333484725', 1, 3),
(8, 'khacviet', 'khacviet@gmail.com', '123456', 'Khắc Việt', 'Nam', 'Hà Nội', '0373484296', 1, 4);

-- --------------------------------------------------------

--
-- Table structure for table `function`
--

CREATE TABLE `function` (
  `id_function` int(11) NOT NULL,
  `id_category` int(11) DEFAULT NULL,
  `url` varchar(50) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `display_on_homepage` enum('0','1') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `function`
--

INSERT INTO `function` (`id_function`, `id_category`, `url`, `title`, `display_on_homepage`) VALUES
(1, 1, 'manage-bill.php?status=0', 'Đơn chưa duyệt', '1'),
(2, 2, 'add-type.php', 'Thêm loại sản phẩm', '0'),
(3, 2, 'edit-type.php', 'Sửa loại sản phẩm', '0'),
(4, 3, 'add-product.php', 'Thêm sản phẩm', '0'),
(5, 3, 'edit-product.php', 'Sửa sản phẩm', '0'),
(6, 3, 'list-products.php', 'Danh sách sản phẩm', '1'),
(7, 5, 'statistical.php', 'Báo cáo sản phẩm', '1'),
(8, 5, 'statistical-revenue.php', 'Báo cáo doanh thu', '1'),
(9, 4, 'import-products.php', 'Danh sách nhập hàng', '1'),
(10, 8, 'list-orders.php?status=0', 'Đang xử lý', '1'),
(13, 8, 'add-order.php', 'Tạo đặt hàng', '0'),
(14, 2, 'list-type.php', 'Danh sách loại sản phẩm', '1'),
(16, 1, 'manage-bill.php?status=2', 'Đơn đang giao', '1'),
(17, 1, 'manage-bill.php?status=3', 'Đơn hoàn tất', '1'),
(18, 1, 'manage-bill.php?status=4', 'Đơn đã hủy', '1'),
(19, 1, 'manage-bill.php?status=5', 'Đơn của tôi', '1'),
(22, 6, 'employees.php', 'Danh sách nhân viên', '1'),
(23, 7, 'customers.php', 'Danh sách khách hàng', '1'),
(24, 5, 'statistical-inventory.php', 'Báo cáo tồn kho', '1'),
(25, 5, 'statistical-interest.php', 'Báo cáo lợi nhuận', '1'),
(26, 8, 'list-orders.php?status=1', 'Đã hoàn tất', '1'),
(27, 8, 'list-orders.php?status=2', 'Đã hủy', '1'),
(28, 9, 'suppliers.php', 'Danh sách NCC', '1'),
(30, 10, 'division-delivery.php', 'Phân công giao hàng', '1'),
(31, 11, 'functions.php?type=2', 'Phân quyền', '1'),
(32, 11, 'functions.php?type=0', 'Danh sách URL', '1'),
(33, 11, 'functions.php?type=1', 'Danh mục', '1'),
(34, 12, 'my-account.php', 'Tài khoản của tôi', '0'),
(36, 14, 'promotions.php', 'Chương trình khuyến mãi', '1');

-- --------------------------------------------------------

--
-- Table structure for table `function_categories`
--

CREATE TABLE `function_categories` (
  `id_category` int(11) NOT NULL,
  `cate_name` varchar(100) NOT NULL,
  `ordering` int(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `function_categories`
--

INSERT INTO `function_categories` (`id_category`, `cate_name`, `ordering`) VALUES
(1, 'Quản lý đơn hàng', 1),
(2, 'Quản lý loại sản phẩm', 2),
(3, 'Quản lý sản phẩm', 3),
(4, 'Quản lý nhập hàng', 5),
(5, 'Quản lý thống kê', 6),
(6, 'Quản lý nhân viên', 7),
(7, 'Quản lý khách hàng', 8),
(8, 'Quản lý đặt hàng', 4),
(9, 'Quản lý NCC', 9),
(10, 'Quản lý phân công', 10),
(11, 'Quản lý phân quyền', 11),
(12, 'Quản lý tài khoản', 12),
(14, 'Quản lý khuyến mãi', 13);

-- --------------------------------------------------------

--
-- Table structure for table `function_detail`
--

CREATE TABLE `function_detail` (
  `id_function` int(11) NOT NULL,
  `id_role` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `function_detail`
--

INSERT INTO `function_detail` (`id_function`, `id_role`) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 1),
(2, 2),
(2, 3),
(3, 1),
(3, 2),
(3, 3),
(4, 1),
(4, 2),
(4, 3),
(5, 1),
(5, 2),
(5, 3),
(6, 1),
(6, 2),
(6, 3),
(7, 1),
(7, 2),
(8, 1),
(8, 2),
(9, 1),
(9, 2),
(9, 3),
(10, 1),
(10, 2),
(10, 3),
(13, 1),
(13, 2),
(13, 3),
(14, 1),
(14, 2),
(14, 3),
(16, 1),
(16, 2),
(16, 3),
(17, 1),
(17, 2),
(17, 3),
(18, 1),
(18, 2),
(18, 3),
(19, 4),
(22, 1),
(23, 1),
(24, 1),
(24, 2),
(25, 1),
(25, 2),
(26, 1),
(26, 2),
(26, 3),
(27, 1),
(27, 2),
(27, 3),
(28, 1),
(28, 2),
(30, 1),
(30, 2),
(31, 1),
(32, 1),
(33, 1),
(34, 1),
(34, 2),
(34, 3),
(34, 4),
(36, 1);

-- --------------------------------------------------------

--
-- Table structure for table `import`
--

CREATE TABLE `import` (
  `import_code` varchar(20) NOT NULL,
  `created_at` datetime NOT NULL,
  `id_employee` int(12) NOT NULL,
  `total` float NOT NULL,
  `place_order_code` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `import`
--

INSERT INTO `import` (`import_code`, `created_at`, `id_employee`, `total`, `place_order_code`) VALUES
('20201222122245', '2022-11-25 12:22:53', 1, 1025.44, '20201222120135'),
('20201222122300', '2022-11-25 12:22:53', 1, 2694.64, '20201222115824'),
('20201222122349', '2022-11-25 12:22:53', 1, 4366, '20201222114707'),
('20201223101237', '2022-11-25 12:22:53', 1, 173.4, '20201223101053'),
('20201223101413', '2022-11-25 12:22:53', 1, 338.6, '20201223100829'),
('20201223185936', '2022-11-25 12:22:53', 1, 156, '20201223185913'),
('20201228215441', '2022-11-25 12:22:53', 1, 214.4, '20201228215259'),
('20201229150659', '2022-11-25 12:22:53', 1, 355, '20201229150409'),
('20221125230243', '2022-11-25 23:02:58', 1, 105, '20221124204220'),
('20221125231428', '2022-11-25 23:14:45', 1, 105, '20221125230957'),
('20221126150806', '2022-11-26 15:08:19', 1, 105, '20221126150738');

-- --------------------------------------------------------

--
-- Table structure for table `import_detail`
--

CREATE TABLE `import_detail` (
  `import_code` varchar(20) NOT NULL,
  `product_code` varchar(20) NOT NULL,
  `price` float NOT NULL,
  `quantity_in` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `import_detail`
--

INSERT INTO `import_detail` (`import_code`, `product_code`, `price`, `quantity_in`) VALUES
('20201222122245', 'MH01', 16.88, 8),
('20201222122245', 'MH03', 15, 6),
('20201222122245', 'MH04', 10.5, 12),
('20201222122245', 'MH05', 9.56, 15),
('20201222122245', 'MH06', 8, 6),
('20201222122245', 'MH08', 23.8, 5),
('20201222122245', 'MH09', 26, 14),
('20201222122300', 'MH02', 18.8, 20),
('20201222122300', 'MH10', 28.6, 25),
('20201222122300', 'MH11', 30.2, 10),
('20201222122300', 'MH16', 19, 15),
('20201222122300', 'MH18', 24.68, 18),
('20201222122300', 'MH19', 28.62, 20),
('20201222122349', 'MH07', 30, 30),
('20201222122349', 'MH12', 32, 20),
('20201222122349', 'MH13', 34.4, 20),
('20201222122349', 'MH14', 10, 25),
('20201222122349', 'MH15', 11, 20),
('20201222122349', 'MH17', 29, 30),
('20201222122349', 'MH20', 26.6, 30),
('20201223101237', 'MH04', 10.88, 5),
('20201223101237', 'MH08', 23.8, 5),
('20201223101413', 'MH12', 31.12, 5),
('20201223101413', 'MH17', 30.5, 6),
('20201223185936', 'MH01', 15.6, 10),
('20201228215441', 'MH08', 20.6, 4),
('20201228215441', 'MH09', 22, 6),
('20201229132119', 'MH04', 10.56, 10),
('20201229150659', 'MH01', 22, 5),
('20201229150659', 'MH03', 24.5, 10),
('20221125230243', 'MH01', 10.5, 10),
('20221125231428', 'MH22', 10.5, 10),
('20221126150806', 'MH23', 10.5, 10);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `id_customer` int(12) NOT NULL,
  `id_employee` int(12) DEFAULT NULL,
  `id_shipper` int(12) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `name` varchar(50) NOT NULL,
  `address` varchar(100) NOT NULL,
  `district_code` varchar(100) NOT NULL,
  `phone` varchar(10) NOT NULL,
  `date_receive` date NOT NULL,
  `status` int(1) NOT NULL COMMENT '0: chưa duyệt, 1: chờ shipper xác nhận, 2: đang giao, 3: hoàn tất, 4: hủy',
  `total` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `id_customer`, `id_employee`, `id_shipper`, `created_at`, `name`, `address`, `district_code`, `phone`, `date_receive`, `status`, `total`) VALUES
(180, 46, 1, 4, '2022-11-25 12:39:15', 'Trịnh Thanh Loan', '83b triều khúc', 'QTX', '0333639679', '2022-11-25', 3, 196.84),
(181, 46, 1, 5, '2022-11-25 12:42:09', 'Nguyễn Khánh', '333 nguyễn xiển hà nội', 'QTX', '0969399121', '2022-11-25', 3, 135.74),
(182, 46, 1, 5, '2022-11-25 12:45:26', 'Anh Quân', '52 triều khúc', 'QTX', '0986624416', '2022-11-25', 3, 344.4),
(183, 46, 1, 4, '2022-11-25 12:53:41', 'Mỹ Kiều', '77 tây hồ', 'QTH', '0335998119', '2022-11-25', 3, 81.05),
(184, 53, 1, 4, '2020-12-23 17:37:06', 'Minh Duy', '80 Đường Số 23, Phường 10', 'Q06', '0333347268', '2020-12-26', 3, 87.4),
(185, 53, 1, 4, '2022-11-25 17:49:25', 'Hồng Sương', '54 triều khúc', 'QTX', '0333347268', '2022-12-25', 3, 30.24),
(186, 53, 1, 5, '2022-12-25 18:02:18', 'Hồng Thắm', '6 hoàng mai', 'QHM', '0333347268', '2022-11-26', 3, 26.32),
(187, 46, 1, 5, '2022-11-25 18:30:54', 'Phạm Quỳnh', '6 sơn tây', 'TXST', '0333347268', '2022-11-26', 3, 70.89),
(190, 46, 1, 4, '2022-11-25 20:49:43', 'Hoàng Thương', '45 sơn tây', 'TXST', '0333639679', '2022-11-25', 3, 47.88),
(191, 46, 1, 1, '2022-11-25 05:31:33', 'Thiên An', '6 sơn tây', 'TXST', '0333639679', '2022-11-25', 4, 89.97),
(192, 46, 1, 4, '2022-11-25 07:27:03', 'Kim Long', '135 thanh trì', 'QTX', '0333639679', '2022-11-26', 3, 48.16),
(193, 46, 1, 8, '2020-12-25 07:29:44', 'Lan Anh', '138 thanh trì', 'QTX', '0333639679', '2022-11-25', 3, 120.12),
(194, 46, 1, 5, '2022-11-25 07:33:54', 'Linh Chi', '147 triều khúc', 'QTX', '0333639679', '2022-11-25', 3, 80.14),
(195, 46, 1, 4, '2022-11-25 08:02:59', 'Trịnh Thanh Loan', '83b tân triều', 'QTX', '0333639679', '2022-11-25', 3, 120.96),
(196, 46, 1, 4, '2022-11-25 21:26:40', 'Thanh Tâm', '50 triều khúc', 'QTX', '0333639679', '2022-11-25', 3, 76.1),
(197, 46, 1, 4, '2022-11-25 11:19:32', 'Lan Phương', '138 tân triều', 'QTX', '0333639679', '2022-11-25', 3, 59.98),
(198, 46, 1, 5, '2022-11-25 22:09:06', 'Ngọc Tú', 'khu tái định cư', 'QTX', '0333639679', '2022-11-25', 3, 156.18),
(199, 46, 1, 4, '2022-11-25 13:17:28', 'Đức Cường', '129/12 sơn tây', 'TXST', '0333639679', '2022-11-25', 3, 87.92),
(200, 46, 1, 5, '2022-11-25 13:25:05', 'Linh Chi', '54 triều khúc', 'QTX', '0333639679', '2022-11-25', 3, 132.78),
(201, 46, 1, 4, '2022-11-25 14:40:48', 'Thanh Tuyền', 'hà nội', 'QTX', '0333639679', '2022-11-25', 3, 123.8);

-- --------------------------------------------------------

--
-- Table structure for table `orders_detail`
--

CREATE TABLE `orders_detail` (
  `id_order` int(11) NOT NULL,
  `product_code` varchar(20) NOT NULL,
  `price` float NOT NULL,
  `quantity_out` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `orders_detail`
--

INSERT INTO `orders_detail` (`id_order`, `product_code`, `price`, `quantity_out`) VALUES
(180, 'MH02', 26.32, 2),
(180, 'MH03', 21, 3),
(180, 'MH17', 40.6, 2),
(181, 'MH08', 33.32, 2),
(181, 'MH18', 34.55, 2),
(182, 'MH11', 42.28, 5),
(182, 'MH16', 26.6, 5),
(183, 'MH06', 10.08, 2),
(183, 'MH18', 31.1, 1),
(183, 'MH20', 29.79, 1),
(184, 'MH14', 12.6, 2),
(184, 'MH18', 31.1, 2),
(185, 'MH06', 10.08, 3),
(186, 'MH02', 26.32, 1),
(187, 'MH01', 23.63, 3),
(188, 'MH09', 36.4, 1),
(189, 'MH11', 38.05, 1),
(190, 'MH16', 23.94, 2),
(191, 'MH08', 29.99, 3),
(192, 'MH01', 21.84, 1),
(192, 'MH02', 26.32, 1),
(193, 'MH10', 40.04, 3),
(194, 'MH19', 40.07, 2),
(195, 'MH02', 26.32, 3),
(195, 'MH03', 21, 2),
(196, 'MH11', 38.05, 2),
(197, 'MH08', 29.99, 2),
(198, 'MH10', 40.04, 2),
(198, 'MH11', 38.05, 2),
(199, 'MH02', 26.32, 1),
(199, 'MH09', 30.8, 2),
(200, 'MH02', 26.32, 2),
(200, 'MH19', 40.07, 2),
(201, 'MH09', 30.8, 2),
(201, 'MH18', 31.1, 2);

-- --------------------------------------------------------

--
-- Table structure for table `place_order`
--

CREATE TABLE `place_order` (
  `place_order_code` varchar(20) NOT NULL,
  `created_at` datetime NOT NULL,
  `id_employee` int(12) NOT NULL,
  `supp_code` varchar(20) NOT NULL,
  `import_code` varchar(20) DEFAULT NULL,
  `status` int(1) DEFAULT NULL COMMENT '0: đang xử lý, 1: hoàn tất, 2: đã hủy'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `place_order`
--

INSERT INTO `place_order` (`place_order_code`, `created_at`, `id_employee`, `supp_code`, `import_code`, `status`) VALUES
('20201222114707', '2022-11-25 12:22:53', 1, 'S189', '20201222122349', 1),
('20201222115824', '2022-11-25 12:22:53', 1, 'P247', '20201222122300', 1),
('20201222120135', '2022-11-25 12:22:53', 1, 'ASA', '20201222122245', 1),
('20201223100829', '2022-11-25 12:22:53', 1, 'S189', '20201223101413', 1),
('20201223101053', '2022-11-25 12:22:53', 1, 'ASA', '20201223101237', 1),
('20201223185913', '2022-11-25 12:22:53', 1, 'ASA', '20201223185936', 1),
('20201224174806', '2022-11-25 12:22:53', 1, 'S189', NULL, 2),
('20201226104547', '2022-11-25 12:22:53', 1, 'S189', NULL, 2),
('20201228215259', '2022-11-25 12:22:53', 1, 'ASA', '20201228215441', 1),
('20201229150409', '2022-11-25 12:22:53', 1, 'ASA', '20201229150659', 1),
('20221124204220', '2022-11-25 12:22:53', 1, 'ASA', '20221125230243', 1),
('20221125230957', '2022-11-25 23:11:57', 1, 'AH1', '20221125231428', 1),
('20221126001252', '2022-11-26 00:13:20', 1, 'AH1', NULL, 0),
('20221126001403', '2022-11-26 00:14:18', 1, 'AH1', NULL, 0),
('20221126150738', '2022-11-26 15:07:48', 1, 'AH1', '20221126150806', 1),
('DH001', '2022-11-25 12:22:53', 1, 'ASA', NULL, 2);

-- --------------------------------------------------------

--
-- Table structure for table `place_order_detail`
--

CREATE TABLE `place_order_detail` (
  `place_order_code` varchar(20) NOT NULL,
  `product_code` varchar(20) NOT NULL,
  `quantity_ord` int(11) NOT NULL,
  `price_ord` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `place_order_detail`
--

INSERT INTO `place_order_detail` (`place_order_code`, `product_code`, `quantity_ord`, `price_ord`) VALUES
('20201222114707', 'MH07', 30, 30),
('20201222114707', 'MH12', 20, 32),
('20201222114707', 'MH13', 20, 34.4),
('20201222114707', 'MH14', 25, 10),
('20201222114707', 'MH15', 20, 11),
('20201222114707', 'MH17', 30, 29),
('20201222114707', 'MH20', 30, 26.6),
('20201222115824', 'MH02', 20, 18.8),
('20201222115824', 'MH10', 25, 28.6),
('20201222115824', 'MH11', 10, 30.2),
('20201222115824', 'MH16', 15, 19),
('20201222115824', 'MH18', 18, 24.68),
('20201222115824', 'MH19', 20, 28.62),
('20201222120135', 'MH01', 8, 16.88),
('20201222120135', 'MH03', 6, 15),
('20201222120135', 'MH04', 12, 10.5),
('20201222120135', 'MH05', 15, 9.56),
('20201222120135', 'MH06', 6, 8),
('20201222120135', 'MH08', 5, 23.8),
('20201222120135', 'MH09', 14, 26),
('20201223100829', 'MH12', 5, 31.12),
('20201223100829', 'MH17', 6, 30.5),
('20201223101053', 'MH04', 5, 10.88),
('20201223101053', 'MH08', 5, 23.8),
('20201223185913', 'MH01', 10, 15.6),
('20201224174806', 'MH07', 10, 10.5),
('20201224174806', 'MH13', 10, 12),
('20201226104547', 'MH07', 10, 10.5),
('20201228215259', 'MH08', 4, 20.6),
('20201228215259', 'MH09', 6, 22),
('20201229131921', 'MH01', 10, 16),
('20201229131921', 'MH04', 10, 10.56),
('20201229150409', 'MH01', 15, 22),
('20201229150409', 'MH03', 20, 24.5),
('20221124204220', 'MH01', 10, 10.5),
('20221125230957', 'MH22', 10, 10.5),
('20221126001252', 'MH22', 10, 10.5),
('20221126001403', 'MH22', 10, 10.5),
('20221126150738', 'MH23', 10, 10.5),
('DH001', 'MH01', 10, 23.66);

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(900) NOT NULL,
  `price` float NOT NULL,
  `image` varchar(100) DEFAULT NULL,
  `quantity_exist` int(11) NOT NULL,
  `new` tinyint(1) NOT NULL COMMENT '0: cũ, 1: mới',
  `status` tinyint(1) NOT NULL COMMENT '0: chưa xóa, 1: đã xóa',
  `cate_code` varchar(20) NOT NULL,
  `supp_code` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_code`, `name`, `description`, `price`, `image`, `quantity_exist`, `new`, `status`, `cate_code`, `supp_code`) VALUES
('MH01', 'Mũ bảo hiểm 3/4 BT01-ASA màu đen, kính âm', 'Có độ bền cao và chịu va đập tốt.\nMút xốp bằng EPS hấp thụ chấn động khi có sự cố.\nQuai mũ dệt 2 lớp bằng sợi tổng hợp, chịu lực giật kéo tốt.', 14.7, 'BT01.jpg', 29, 1, 0, 'BT', 'ASA'),
('MH02', 'Mũ bảo hiểm 3/4 đầu BT02-P247 màu trắng, kính âm', 'Có độ bền cao và chịu va đập tốt.\r\nMút xốp bằng EPS hấp thụ chấn động khi có sự cố.\r\nQuai mũ dệt 2 lớp bằng sợi tổng hợp, chịu lực giật kéo tốt.', 26.32, 'BT02.jpg', 10, 1, 0, 'BT', 'P247'),
('MH03', 'Mũ bảo hiểm 3/4 BT03-ASA màu vàng, kính âm', 'Có độ bền cao và chịu va đập tốt.\r\nMút xốp bằng EPS hấp thụ chấn động khi có sự cố.\r\nQuai mũ dệt 2 lớp bằng sợi tổng hợp, chịu lực giật kéo tốt.', 34.3, 'BT03.jpg', 11, 1, 0, 'BT', 'ASA'),
('MH04', 'Mũ bảo hiểm ND04-ASA màu trắng, có kính', 'Mũ được làm từ chất liệu ABS cao cấp. Vải lót êm ái, kính che tiện dụng. Đảm bảo an toàn khi tham gia giao thông.', 14.78, 'ND04.jpg', 27, 0, 0, 'ND', 'ASA'),
('MH05', 'Mũ bảo hiểm ND05-ASA màu vàng, có kính', 'Mũ được làm từ chất liệu ABS cao cấp. Vải lót êm ái, kính che tiện dụng. Đảm bảo an toàn khi tham gia giao thông.', 13.38, 'ND05.jpg', 15, 0, 0, 'ND', 'ASA'),
('MH06', 'Mũ bảo hiểm 1/2 đầu ND06-ASA màu đen, có kính', 'Mũ được làm từ chất liệu ABS cao cấp. Vải lót êm ái, kính che tiện dụng. Đảm bảo an toàn khi tham gia giao thông.', 11.2, 'ND06.jpg', 1, 0, 0, 'ND', 'ASA'),
('MH07', 'Mũ lật cằm LC07-S189 Tem Nhám màu đen', 'Chất liệu nhựa ABS bền đẹp.\r\nKết cấu bền chắc, an toàn và hợp thời trang.\r\nLót đệm bên trong dày và hút ẩm thoải mái khi sử dụng.', 42, 'LC07.jpg', 30, 0, 0, 'LC', 'S189'),
('MH08', 'Mũ bảo hiểm Full Face FF08-ASA AGU Tem sói', 'Vỏ bằng nhựa ABS nguyên sinh có độ bền cao và chịu va đập tốt.\r\nMiếng lót bên trong nón có thể được tháo rời giúp việc vệ sinh dễ dàng.', 28.84, 'FF08.jpg', 10, 1, 0, 'FF', 'ASA'),
('MH09', 'Mũ bảo hiểm Full Face FF09-ASA AGU Tem Racing', 'Vỏ bằng nhựa ABS nguyên sinh có độ bền cao và chịu va đập tốt.\r\nMiếng lót bên trong nón có thể được tháo rời giúp việc vệ sinh dễ dàng.', 30.8, 'FF09.jpg', 16, 1, 0, 'FF', 'ASA'),
('MH10', 'Mũ bảo hiểm lật cằm LC10-P247 Tem Carbon màu đỏ/đen', 'Vỏ bằng nhựa ABS nguyên sinh có độ bền cao và chịu va đập tốt.\r\nMiếng lót bên trong nón có thể được tháo rời giúp việc vệ sinh dễ dàng.', 40.04, 'LC10.jpg', 20, 0, 0, 'LC', 'P247'),
('MH11', 'Mũ bảo hiểm lật cằm LC11-P247 LS2 màu trắng', 'Vỏ bằng nhựa ABS nguyên sinh có độ bền cao và chịu va đập tốt.\r\nMiếng lót bên trong nón có thể được tháo rời giúp việc vệ sinh dễ dàng.', 42.28, 'LC11.jpg', 1, 1, 0, 'LC', 'P247'),
('MH12', 'Mũ bảo hiểm lật cằm LC12-S189 EGO', 'Vỏ bằng nhựa ABS nguyên sinh có độ bền cao và chịu va đập tốt.\r\nMiếng lót bên trong nón có thể được tháo rời giúp việc vệ sinh dễ dàng.', 43.57, 'LC12.jpg', 25, 0, 0, 'LC', 'S189'),
('MH13', 'Mũ bảo hiểm lật cằm LC13-S189 Yohe 950', 'Vỏ bằng nhựa ABS nguyên sinh có độ bền cao và chịu va đập tốt.\r\nMiếng lót bên trong nón có thể được tháo rời giúp việc vệ sinh dễ dàng.', 48.16, 'LC13.jpg', 20, 0, 0, 'LC', 'S189'),
('MH14', 'Mũ bảo hiểm 1/2 đầu ND14-S189 màu hồng, có kính', 'Mũ được làm từ chất liệu ABS cao cấp. Vải lót êm ái, kính che tiện dụng. Đảm bảo an toàn khi tham gia giao thông.', 14, 'ND14.jpg', 23, 0, 0, 'ND', 'S189'),
('MH15', 'Mũ bảo hiểm 1/2 đầu ND15-S189 màu đỏ/trắng, không kính', 'Mũ được làm từ chất liệu ABS cao cấp. Vải lót êm ái, kính che tiện dụng. Đảm bảo an toàn khi tham gia giao thông.', 15.4, 'ND15.jpg', 20, 0, 0, 'ND', 'S189'),
('MH16', 'Mũ bảo hiểm 3/4 BT16-P247 màu cam', 'Có độ bền cao và chịu va đập tốt.\r\nMút xốp bằng EPS hấp thụ chấn động khi có sự cố.\r\nQuai mũ dệt 2 lớp bằng sợi tổng hợp, chịu lực giật kéo tốt.', 26.6, 'BT16.jpg', 8, 1, 0, 'BT', 'P247'),
('MH17', 'Mũ bảo hiểm 3/4 BT17-S189 màu trắng/xanh dương', 'Có độ bền cao và chịu va đập tốt.\r\nMút xốp bằng EPS hấp thụ chấn động khi có sự cố.\r\nQuai mũ dệt 2 lớp bằng sợi tổng hợp, chịu lực giật kéo tốt.', 42.7, 'BT17.jpg', 34, 1, 0, 'BT', 'S189'),
('MH18', 'Mũ bảo hiểm FullFace FF18-P247 Andes Tem Nhám', 'Chất liệu nhựa ABS bền đẹp.\r\nKết cấu bền chắc, an toàn và hợp thời trang.\r\nLót đệm bên trong dày và hút ẩm thoải mái khi sử dụng.', 34.55, 'FF18.jpg', 11, 0, 0, 'FF', 'P247'),
('MH19', 'Mũ bảo hiểm FullFace FF19-P247 AGU Tem 46 xanh dương', 'Chất liệu nhựa ABS bền đẹp.\r\nKết cấu bền chắc, an toàn và hợp thời trang.\r\nLót đệm bên trong dày và hút ẩm thoải mái khi sử dụng.', 40.07, 'FF19.jpg', 16, 1, 0, 'FF', 'P247'),
('MH20', 'Mũ bảo hiểm FullFace FF20-S189 Tem Avengers', 'Chất liệu nhựa ABS bền đẹp.\r\nKết cấu bền chắc, an toàn và hợp thời trang.\r\nLót đệm bên trong dày và hút ẩm thoải mái khi sử dụng.', 37.24, 'FF20.jpg', 29, 1, 0, 'FF', 'S189'),
('MH22', 'MŨ NỬA ĐẦU BULLDOG GANG - XÁM', 'Mũ được làm từ chất liệu ABS cao cấp. Vải lót êm ái, kính che tiện dụng. Đảm bảo an toàn khi tham gia giao thông.', 14.7, 'ND16.jpg', 10, 1, 0, 'ND', 'AH1'),
('MH23', 'MŨ NỬA ĐẦU BULLDOG GANG - ĐEN NHÁM', 'Mũ làm bằng nhựa Abs.Dáng OKK', 14.7, 'ND17.jpg', 10, 1, 0, 'ND', 'AH1');

-- --------------------------------------------------------

--
-- Table structure for table `promotion`
--

CREATE TABLE `promotion` (
  `promotion_code` varchar(20) NOT NULL,
  `date_start` date NOT NULL,
  `date_end` date NOT NULL,
  `description` varchar(500) NOT NULL,
  `id_employee` int(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `promotion`
--

INSERT INTO `promotion` (`promotion_code`, `date_start`, `date_end`, `description`, `id_employee`) VALUES
('KM01', '2022-01-01', '2022-12-31', 'Khuyến mãi cuối năm', 1),
('KM02', '2023-01-01', '2023-02-02', 'Khuyễn mãi đầu năm mới', 1);

-- --------------------------------------------------------

--
-- Table structure for table `promotion_detail`
--

CREATE TABLE `promotion_detail` (
  `promotion_code` varchar(20) NOT NULL,
  `product_code` varchar(20) NOT NULL,
  `percent` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `promotion_detail`
--

INSERT INTO `promotion_detail` (`promotion_code`, `product_code`, `percent`) VALUES
('KM01', 'MH06', 0.1),
('KM01', 'MH08', 0.1),
('KM01', 'MH11', 0.1),
('KM01', 'MH14', 0.1),
('KM01', 'MH16', 0.1),
('KM01', 'MH18', 0.1),
('KM01', 'MH20', 0.2),
('KM02', 'MH01', 0.1),
('KM02', 'MH03', 0.1);

-- --------------------------------------------------------

--
-- Table structure for table `returns_product`
--

CREATE TABLE `returns_product` (
  `return_code` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `created_at` date NOT NULL,
  `id_employee` int(12) NOT NULL,
  `bill_code` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

-- --------------------------------------------------------

--
-- Table structure for table `returns_product_detail`
--

CREATE TABLE `returns_product_detail` (
  `return_code` varchar(20) NOT NULL,
  `product_code` varchar(20) NOT NULL,
  `quantity_return` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `role`
--

CREATE TABLE `role` (
  `id_role` int(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `description` varchar(400) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `role`
--

INSERT INTO `role` (`id_role`, `name`, `description`) VALUES
(1, 'Admin', 'Toàn quyền: Quyền của Approver + Manager + quyền quản lý khách hàng, nhân viên'),
(2, 'Manager', 'Quyền của Approver + quyền xem thống kê + CTKM + phân công'),
(3, 'Approver', 'Quyền duyệt đơn hàng + quản lý loại sản phẩm + quản lý sản phẩm + quản lý đặt/nhập+ quản lý NCC '),
(4, 'Shipper', ''),
(5, 'Customer', '');

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `supp_code` varchar(20) NOT NULL,
  `name` varchar(50) NOT NULL,
  `address` varchar(100) NOT NULL,
  `email` varchar(50) NOT NULL,
  `phone` varchar(10) NOT NULL,
  `status` int(1) NOT NULL COMMENT '1: chưa xóa, 0: xóa'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`supp_code`, `name`, `address`, `email`, `phone`, `status`) VALUES
('AH1', 'Asian Helmet', 'Thanh Xuân, Hà Nội', 'asianhelmet@gmail.com', '0333224455', 1),
('ASA', 'ASA Helmet', '5 Hoàn Kiếm, Hà Nội', 'asa_helmet1@gmail.com', '0333444555', 1),
('P247', 'Phượt 247', '35 Tây Hồ , Hà Nội', 'phuot247@gmail.com', '0333444666', 1),
('S189', 'Store 189', '52 Triều khúc,  Hà Nội', 'store_189@gmail.com', '0333444777', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bills`
--
ALTER TABLE `bills`
  ADD PRIMARY KEY (`bill_code`),
  ADD UNIQUE KEY `id_order_2` (`id_order`),
  ADD KEY `id_order` (`id_order`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`cate_code`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `comment`
--
ALTER TABLE `comment`
  ADD PRIMARY KEY (`cmt_code`),
  ADD KEY `product_code` (`product_code`);

--
-- Indexes for table `comment_customer`
--
ALTER TABLE `comment_customer`
  ADD PRIMARY KEY (`id_customer`,`comment_code`) USING BTREE,
  ADD KEY `comment_code` (`comment_code`,`id_customer`) USING BTREE;

--
-- Indexes for table `comment_employee`
--
ALTER TABLE `comment_employee`
  ADD PRIMARY KEY (`id_employee`,`comment_code`) USING BTREE,
  ADD KEY `comment_code` (`comment_code`,`id_employee`) USING BTREE;

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `district_code` (`district_code`),
  ADD KEY `id_role` (`id_role`);

--
-- Indexes for table `district`
--
ALTER TABLE `district`
  ADD PRIMARY KEY (`district_code`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `division_detail`
--
ALTER TABLE `division_detail`
  ADD PRIMARY KEY (`district_code`,`id_employee`) USING BTREE,
  ADD KEY `id_employee` (`id_employee`,`district_code`) USING BTREE;

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD KEY `id_role` (`id_role`);

--
-- Indexes for table `function`
--
ALTER TABLE `function`
  ADD PRIMARY KEY (`id_function`),
  ADD UNIQUE KEY `url` (`url`),
  ADD UNIQUE KEY `title` (`title`),
  ADD KEY `id_category` (`id_category`);

--
-- Indexes for table `function_categories`
--
ALTER TABLE `function_categories`
  ADD PRIMARY KEY (`id_category`),
  ADD UNIQUE KEY `cate_name` (`cate_name`);

--
-- Indexes for table `function_detail`
--
ALTER TABLE `function_detail`
  ADD PRIMARY KEY (`id_function`,`id_role`) USING BTREE,
  ADD KEY `id_role` (`id_role`,`id_function`) USING BTREE;

--
-- Indexes for table `import`
--
ALTER TABLE `import`
  ADD PRIMARY KEY (`import_code`),
  ADD UNIQUE KEY `place_order_code_2` (`place_order_code`),
  ADD KEY `place_order_code` (`place_order_code`),
  ADD KEY `id_employee` (`id_employee`);

--
-- Indexes for table `import_detail`
--
ALTER TABLE `import_detail`
  ADD PRIMARY KEY (`import_code`,`product_code`) USING BTREE,
  ADD KEY `product_code` (`product_code`,`import_code`) USING BTREE;

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `district_code` (`district_code`),
  ADD KEY `id_customer` (`id_customer`),
  ADD KEY `id_employee` (`id_employee`),
  ADD KEY `id_shipper` (`id_shipper`);

--
-- Indexes for table `orders_detail`
--
ALTER TABLE `orders_detail`
  ADD PRIMARY KEY (`id_order`,`product_code`) USING BTREE,
  ADD KEY `product_code` (`product_code`,`id_order`) USING BTREE;

--
-- Indexes for table `place_order`
--
ALTER TABLE `place_order`
  ADD PRIMARY KEY (`place_order_code`),
  ADD UNIQUE KEY `import_code` (`import_code`),
  ADD KEY `supp_code` (`supp_code`),
  ADD KEY `id_employee` (`id_employee`);

--
-- Indexes for table `place_order_detail`
--
ALTER TABLE `place_order_detail`
  ADD PRIMARY KEY (`place_order_code`,`product_code`) USING BTREE,
  ADD KEY `product_code` (`product_code`,`place_order_code`) USING BTREE;

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_code`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `cate_code` (`cate_code`),
  ADD KEY `supp_code` (`supp_code`);

--
-- Indexes for table `promotion`
--
ALTER TABLE `promotion`
  ADD PRIMARY KEY (`promotion_code`),
  ADD KEY `id_employee` (`id_employee`);

--
-- Indexes for table `promotion_detail`
--
ALTER TABLE `promotion_detail`
  ADD PRIMARY KEY (`promotion_code`,`product_code`) USING BTREE,
  ADD KEY `product_code` (`product_code`,`promotion_code`) USING BTREE;

--
-- Indexes for table `returns_product`
--
ALTER TABLE `returns_product`
  ADD PRIMARY KEY (`return_code`),
  ADD KEY `bill_code` (`bill_code`),
  ADD KEY `id_employee` (`id_employee`);

--
-- Indexes for table `returns_product_detail`
--
ALTER TABLE `returns_product_detail`
  ADD PRIMARY KEY (`return_code`,`product_code`),
  ADD KEY `product_code` (`product_code`,`return_code`) USING BTREE;

--
-- Indexes for table `role`
--
ALTER TABLE `role`
  ADD PRIMARY KEY (`id_role`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`supp_code`),
  ADD UNIQUE KEY `name` (`name`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `phone` (`phone`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int(12) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT for table `employee`
--
ALTER TABLE `employee`
  MODIFY `id` int(12) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `function`
--
ALTER TABLE `function`
  MODIFY `id_function` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `function_categories`
--
ALTER TABLE `function_categories`
  MODIFY `id_category` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=202;

--
-- AUTO_INCREMENT for table `role`
--
ALTER TABLE `role`
  MODIFY `id_role` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bills`
--
ALTER TABLE `bills`
  ADD CONSTRAINT `bills_ibfk_1` FOREIGN KEY (`id_order`) REFERENCES `orders` (`id`);

--
-- Constraints for table `comment`
--
ALTER TABLE `comment`
  ADD CONSTRAINT `comment_ibfk_3` FOREIGN KEY (`product_code`) REFERENCES `products` (`product_code`);

--
-- Constraints for table `comment_customer`
--
ALTER TABLE `comment_customer`
  ADD CONSTRAINT `comment_customer_ibfk_1` FOREIGN KEY (`comment_code`) REFERENCES `comment` (`cmt_code`),
  ADD CONSTRAINT `comment_customer_ibfk_2` FOREIGN KEY (`id_customer`) REFERENCES `customers` (`id`);

--
-- Constraints for table `comment_employee`
--
ALTER TABLE `comment_employee`
  ADD CONSTRAINT `comment_employee_ibfk_1` FOREIGN KEY (`comment_code`) REFERENCES `comment` (`cmt_code`),
  ADD CONSTRAINT `comment_employee_ibfk_2` FOREIGN KEY (`id_employee`) REFERENCES `employee` (`id`);

--
-- Constraints for table `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`district_code`) REFERENCES `district` (`district_code`),
  ADD CONSTRAINT `customers_ibfk_2` FOREIGN KEY (`id_role`) REFERENCES `role` (`id_role`);

--
-- Constraints for table `division_detail`
--
ALTER TABLE `division_detail`
  ADD CONSTRAINT `division_detail_ibfk_1` FOREIGN KEY (`district_code`) REFERENCES `district` (`district_code`),
  ADD CONSTRAINT `division_detail_ibfk_2` FOREIGN KEY (`id_employee`) REFERENCES `employee` (`id`);

--
-- Constraints for table `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`id_role`) REFERENCES `role` (`id_role`);

--
-- Constraints for table `function`
--
ALTER TABLE `function`
  ADD CONSTRAINT `function_ibfk_1` FOREIGN KEY (`id_category`) REFERENCES `function_categories` (`id_category`);

--
-- Constraints for table `function_detail`
--
ALTER TABLE `function_detail`
  ADD CONSTRAINT `function_detail_ibfk_1` FOREIGN KEY (`id_function`) REFERENCES `function` (`id_function`),
  ADD CONSTRAINT `function_detail_ibfk_2` FOREIGN KEY (`id_role`) REFERENCES `role` (`id_role`);

--
-- Constraints for table `import`
--
ALTER TABLE `import`
  ADD CONSTRAINT `import_ibfk_3` FOREIGN KEY (`place_order_code`) REFERENCES `place_order` (`place_order_code`),
  ADD CONSTRAINT `import_ibfk_4` FOREIGN KEY (`id_employee`) REFERENCES `employee` (`id`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`district_code`) REFERENCES `district` (`district_code`),
  ADD CONSTRAINT `orders_ibfk_4` FOREIGN KEY (`id_customer`) REFERENCES `customers` (`id`),
  ADD CONSTRAINT `orders_ibfk_5` FOREIGN KEY (`id_employee`) REFERENCES `employee` (`id`),
  ADD CONSTRAINT `orders_ibfk_6` FOREIGN KEY (`id_shipper`) REFERENCES `employee` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
