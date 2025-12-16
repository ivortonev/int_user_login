SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Table structure for table `login`
--

CREATE TABLE `login` (
  `time` int(16) NOT NULL,
  `login` varchar(20) NOT NULL,
  `source_ip` varchar(42) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
COMMIT;
