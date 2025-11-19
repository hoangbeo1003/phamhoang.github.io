
-- BTL: Quản lý bán hàng tại siêu thị


IF DB_ID(N'Qly_sieu_thi') IS NOT NULL
BEGIN
    ALTER DATABASE Qly_sieu_thi SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Qly_sieu_thi;
END
GO

CREATE DATABASE Qly_sieu_thi;
GO
USE Qly_sieu_thi;
GO

-- 1. TẠO CÁC BẢNG

CREATE TABLE LoaiSP (
    MaLoai INT IDENTITY(1,1) PRIMARY KEY,
    TenLoai NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE NhaCungCap (
    MaNCC INT IDENTITY(1,1) PRIMARY KEY,
    TenNCC NVARCHAR(150) NOT NULL,
    SDT VARCHAR(15),
    DiaChi NVARCHAR(200)
);
GO

CREATE TABLE KhachHang (
    MaKH INT IDENTITY(1,1) PRIMARY KEY,
    TenKH NVARCHAR(100) NOT NULL,
    GioiTinh NVARCHAR(10),
    SDT VARCHAR(15),
    DiaChi NVARCHAR(200)
);
GO

CREATE TABLE NhanVien (
    MaNV INT IDENTITY(1,1) PRIMARY KEY,
    TenNV NVARCHAR(100) NOT NULL,
    GioiTinh NVARCHAR(10),
    ChucVu NVARCHAR(50),
    Luong DECIMAL(18,2)
);
GO

CREATE TABLE SanPham (
    MaSP INT IDENTITY(1,1) PRIMARY KEY,
    TenSP NVARCHAR(150) NOT NULL,
    MaLoai INT NULL,
    MaNCC INT NULL,
    DonGia DECIMAL(18,2) NOT NULL DEFAULT 0,
    SoLuongTon INT NOT NULL DEFAULT 0,
    DonViTinh NVARCHAR(50),
    CONSTRAINT FK_SanPham_LoaiSP FOREIGN KEY (MaLoai) REFERENCES LoaiSP(MaLoai),
    CONSTRAINT FK_SanPham_NhaCungCap FOREIGN KEY (MaNCC) REFERENCES NhaCungCap(MaNCC)
);
GO

CREATE TABLE PhieuNhap (
    MaPN INT IDENTITY(1,1) PRIMARY KEY,
    MaNCC INT,
    MaNV INT,
    NgayNhap DATE DEFAULT GETDATE(),
    GhiChu NVARCHAR(500),
    FOREIGN KEY (MaNCC) REFERENCES NhaCungCap(MaNCC),
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

CREATE TABLE ChiTietNhap (
    MaPN INT,
    MaSP INT,
    SoLuong INT,
    DonGiaNhap DECIMAL(18,2),
    PRIMARY KEY (MaPN, MaSP),
    FOREIGN KEY (MaPN) REFERENCES PhieuNhap(MaPN),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

CREATE TABLE HoaDon (
    MaHD INT IDENTITY(1,1) PRIMARY KEY,
    MaKH INT,
    MaNV INT,
    NgayLap DATETIME DEFAULT GETDATE(),
    GhiChu NVARCHAR(500),
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
GO

CREATE TABLE ChiTietHoaDon (
    MaHD INT,
    MaSP INT,
    SoLuong INT,
    DonGia DECIMAL(18,2),
    PRIMARY KEY (MaHD, MaSP),
    FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

-- 2. DỮ LIỆU MẪU

INSERT INTO LoaiSP(TenLoai) VALUES (N'Thực phẩm'), (N'Gia dụng'), (N'Đồ uống');
INSERT INTO NhaCungCap(TenNCC, SDT, DiaChi) VALUES 
(N'Công ty A', '0901000001', N'Hà Nội'),
(N'Công ty B','0901000002',N'Đà Nẵng');
INSERT INTO SanPham(TenSP, MaLoai, MaNCC, DonGia, SoLuongTon, DonViTinh) VALUES
(N'Sữa tươi',1,1,25000,120,N'Hộp'),
(N'Mì ăn liền',1,2,3500,500,N'Gói'),
(N'Bánh kẹo',1,1,15000,200,N'Gói');
INSERT INTO KhachHang(TenKH, GioiTinh, SDT, DiaChi) VALUES
(N'Nguyễn Văn A', N'Nam','0901234567',N'Hà Nội');
INSERT INTO NhanVien(TenNV, GioiTinh, ChucVu, Luong) VALUES
(N'Nguyễn Thị B', N'Nữ', N'Thu ngân', 7000000);

INSERT INTO PhieuNhap(MaNCC, MaNV, NgayNhap, GhiChu) VALUES (1,1,GETDATE(),N'Nhập hàng tháng 10');
INSERT INTO ChiTietNhap(MaPN, MaSP, SoLuong, DonGiaNhap) VALUES (1,1,100,23000),(1,3,50,14000);

INSERT INTO HoaDon(MaKH, MaNV, NgayLap, GhiChu) VALUES (1,1,GETDATE(),N'Bán hàng cho KH A');
INSERT INTO ChiTietHoaDon(MaHD, MaSP, SoLuong, DonGia) VALUES (1,1,2,25000),(1,2,5,3500);
GO

-- 3. TRIGGER & VIEW

CREATE TRIGGER trg_AfterInsert_ChiTietNhap
ON ChiTietNhap
AFTER INSERT
AS
BEGIN
    UPDATE sp SET sp.SoLuongTon = sp.SoLuongTon + i.SoLuong
    FROM SanPham sp JOIN inserted i ON sp.MaSP = i.MaSP;
END;
GO

CREATE TRIGGER trg_BeforeInsert_ChiTietHoaDon
ON ChiTietHoaDon
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS(SELECT 1 FROM inserted i JOIN SanPham sp ON i.MaSP = sp.MaSP WHERE i.SoLuong > sp.SoLuongTon)
    BEGIN
        RAISERROR('Số lượng bán vượt quá tồn kho.',16,1);
        ROLLBACK TRANSACTION; RETURN;
    END
    INSERT INTO ChiTietHoaDon(MaHD, MaSP, SoLuong, DonGia)
    SELECT MaHD, MaSP, SoLuong, sp.DonGia FROM inserted i JOIN SanPham sp ON i.MaSP = sp.MaSP;
    UPDATE sp SET sp.SoLuongTon = sp.SoLuongTon - i.SoLuong FROM SanPham sp JOIN inserted i ON sp.MaSP = i.MaSP;
END;
GO

CREATE VIEW vw_DoanhThu_Ngay AS
SELECT CONVERT(DATE, h.NgayLap) AS Ngay, COUNT(DISTINCT h.MaHD) AS SoHD, SUM(ct.SoLuong * ct.DonGia) AS DoanhThu
FROM HoaDon h JOIN ChiTietHoaDon ct ON h.MaHD = ct.MaHD
GROUP BY CONVERT(DATE, h.NgayLap);
GO

  -- 4. VIEW & INDEX 


-- View sản phẩm đầy đủ
CREATE VIEW vw_SanPham_DayDu AS
SELECT sp.MaSP, sp.TenSP, sp.DonGia, sp.SoLuongTon,
       l.TenLoai, n.TenNCC, sp.DonViTinh
FROM SanPham sp
LEFT JOIN LoaiSP l ON sp.MaLoai = l.MaLoai
LEFT JOIN NhaCungCap n ON sp.MaNCC = n.MaNCC;
GO

-- View tổng tiền phiếu nhập
CREATE VIEW vw_TongTien_PhieuNhap AS
SELECT pn.MaPN, pn.NgayNhap, ncc.TenNCC, nv.TenNV,
       SUM(ct.SoLuong * ct.DonGiaNhap) AS TongTien
FROM PhieuNhap pn
JOIN ChiTietNhap ct ON pn.MaPN = ct.MaPN
JOIN NhaCungCap ncc ON pn.MaNCC = ncc.MaNCC
JOIN NhanVien nv ON pn.MaNV = nv.MaNV
GROUP BY pn.MaPN, pn.NgayNhap, ncc.TenNCC, nv.TenNV;
GO

-- Index tối ưu
CREATE INDEX idx_SanPham_MaLoai ON SanPham(MaLoai);
GO
CREATE INDEX idx_SanPham_MaNCC ON SanPham(MaNCC);
GO
CREATE INDEX idx_HoaDon_NgayLap ON HoaDon(NgayLap);
GO

  --5. PRODUCER & CURSOR

-- Proc thêm sản phẩm
CREATE PROCEDURE sp_ThemSanPham
    @TenSP NVARCHAR(150),
    @MaLoai INT,
    @MaNCC INT,
    @DonGia DECIMAL(18,2),
    @SoLuongTon INT,
    @DonViTinh NVARCHAR(50)
AS
BEGIN
    INSERT INTO SanPham(TenSP, MaLoai, MaNCC, DonGia, SoLuongTon, DonViTinh)
    VALUES (@TenSP, @MaLoai, @MaNCC, @DonGia, @SoLuongTon, @DonViTinh);
END;
GO

-- Proc cập nhật tồn kho
CREATE PROCEDURE sp_CapNhat_TonKho
    @MaSP INT,
    @SoLuongThem INT
AS
BEGIN
    UPDATE SanPham 
    SET SoLuongTon = SoLuongTon + @SoLuongThem
    WHERE MaSP = @MaSP;
END;
GO

-- Cursor tính doanh thu khách hàng
DECLARE @MaKH INT, @TongTien DECIMAL(18,2);

DECLARE cur_DoanhThu CURSOR FOR
SELECT MaKH FROM KhachHang;

OPEN cur_DoanhThu;
FETCH NEXT FROM cur_DoanhThu INTO @MaKH;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @TongTien = SUM(ct.SoLuong * ct.DonGia)
    FROM HoaDon h JOIN ChiTietHoaDon ct ON h.MaHD = ct.MaHD
    WHERE h.MaKH = @MaKH;

    PRINT 'KH ' + CAST(@MaKH AS VARCHAR) + ' - DT: ' + CAST(ISNULL(@TongTien,0) AS VARCHAR);

    FETCH NEXT FROM cur_DoanhThu INTO @MaKH;
END;

CLOSE cur_DoanhThu;
DEALLOCATE cur_DoanhThu;
GO


  --6. TRIGGER 


-- Trigger nhập hàng cập nhật tồn
CREATE TRIGGER trg_AfterInsert_ChiTietNhap_2
ON ChiTietNhap
AFTER INSERT
AS
BEGIN
    UPDATE sp 
    SET sp.SoLuongTon = sp.SoLuongTon + i.SoLuong
    FROM SanPham sp 
    JOIN inserted i ON sp.MaSP = i.MaSP;
END;
GO

-- Trigger kiểm tra tồn kho bán hàng
CREATE TRIGGER trg_BeforeInsert_ChiTietHoaDon_2
ON ChiTietHoaDon
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS(
        SELECT 1 
        FROM inserted i 
        JOIN SanPham sp ON i.MaSP = sp.MaSP
        WHERE i.SoLuong > sp.SoLuongTon
    )
    BEGIN
        RAISERROR('Số lượng vượt quá tồn kho.',16,1);
        RETURN;
    END

    INSERT INTO ChiTietHoaDon(MaHD, MaSP, SoLuong, DonGia)
    SELECT i.MaHD, i.MaSP, i.SoLuong, sp.DonGia
    FROM inserted i JOIN SanPham sp ON i.MaSP = sp.MaSP;

    UPDATE sp 
    SET sp.SoLuongTon = sp.SoLuongTon - i.SoLuong
    FROM SanPham sp JOIN inserted i ON sp.MaSP = i.MaSP;
END;
GO

   --7. PHÂN QUYỀN & BẢO MẬT

CREATE LOGIN NhanVienBanHang WITH PASSWORD = '123456';
GO
CREATE USER NhanVienBanHang FOR LOGIN NhanVienBanHang;
GO

GRANT SELECT ON SanPham TO NhanVienBanHang;
GRANT SELECT, INSERT ON HoaDon TO NhanVienBanHang;
GRANT SELECT, INSERT ON ChiTietHoaDon TO NhanVienBanHang;
GO

-- Mã hóa SDT NCC
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '123@123';
GO

CREATE CERTIFICATE NCC_Cert WITH SUBJECT = 'Encrypt NCC phone';
GO

CREATE SYMMETRIC KEY NCC_Key 
WITH ALGORITHM = AES_256 
ENCRYPTION BY CERTIFICATE NCC_Cert;
GO

ALTER TABLE NhaCungCap ADD SDT_enc VARBINARY(MAX);
GO

OPEN SYMMETRIC KEY NCC_Key DECRYPTION BY CERTIFICATE NCC_Cert;

UPDATE NhaCungCap
SET SDT_enc = EncryptByKey(Key_GUID('NCC_Key'), SDT);

CLOSE SYMMETRIC KEY NCC_Key;
GO



   --PHẦN SELECT KIỂM TRA & BÁO CÁO 

-- 1. Danh sách khách hàng
SELECT * FROM KhachHang;

-- 2. Danh sách nhân viên
SELECT * FROM NhanVien;

-- 3. Danh sách sản phẩm kèm loại và nhà cung cấp
SELECT sp.MaSP, sp.TenSP, sp.DonGia, sp.SoLuongTon, l.TenLoai, n.TenNCC
FROM SanPham sp
LEFT JOIN LoaiSP l ON sp.MaLoai = l.MaLoai
LEFT JOIN NhaCungCap n ON sp.MaNCC = n.MaNCC;

-- 4. Phiếu nhập và tổng tiền
SELECT pn.MaPN, pn.NgayNhap, ncc.TenNCC, nv.TenNV,
       SUM(ctn.SoLuong * ctn.DonGiaNhap) AS TongTienNhap
FROM PhieuNhap pn
JOIN NhaCungCap ncc ON pn.MaNCC = ncc.MaNCC
JOIN NhanVien nv ON pn.MaNV = nv.MaNV
JOIN ChiTietNhap ctn ON pn.MaPN = ctn.MaPN
GROUP BY pn.MaPN, pn.NgayNhap, ncc.TenNCC, nv.TenNV;

-- 5. Hóa đơn bán hàng
SELECT hd.MaHD, hd.NgayLap, kh.TenKH, nv.TenNV, SUM(ct.SoLuong * ct.DonGia) AS TongTien
FROM HoaDon hd
JOIN NhanVien nv ON hd.MaNV = nv.MaNV
LEFT JOIN KhachHang kh ON hd.MaKH = kh.MaKH
JOIN ChiTietHoaDon ct ON hd.MaHD = ct.MaHD
GROUP BY hd.MaHD, hd.NgayLap, kh.TenKH, nv.TenNV
ORDER BY hd.NgayLap DESC;

-- 6. Chi tiết hóa đơn (ví dụ MaHD=1)
DECLARE @MaHD INT = 1;
SELECT ct.MaSP, sp.TenSP, ct.SoLuong, ct.DonGia, (ct.SoLuong * ct.DonGia) AS ThanhTien
FROM ChiTietHoaDon ct JOIN SanPham sp ON ct.MaSP = sp.MaSP
WHERE ct.MaHD = @MaHD;

-- 7. Doanh thu theo ngày
SELECT * FROM vw_DoanhThu_Ngay ORDER BY Ngay DESC;

-- 8. Top 5 sản phẩm bán chạy nhất
SELECT TOP 5 sp.TenSP, SUM(ct.SoLuong) AS TongBan
FROM ChiTietHoaDon ct JOIN SanPham sp ON ct.MaSP = sp.MaSP
GROUP BY sp.TenSP
ORDER BY TongBan DESC;

-- 9. Doanh thu theo nhân viên
SELECT nv.TenNV, SUM(ct.SoLuong * ct.DonGia) AS DoanhThu
FROM HoaDon hd JOIN NhanVien nv ON hd.MaNV = nv.MaNV
JOIN ChiTietHoaDon ct ON hd.MaHD = ct.MaHD
GROUP BY nv.TenNV ORDER BY DoanhThu DESC;

-- 10. Tồn kho theo loại sản phẩm
SELECT l.TenLoai, SUM(sp.SoLuongTon) AS TongTon
FROM SanPham sp JOIN LoaiSP l ON sp.MaLoai = l.MaLoai
GROUP BY l.TenLoai;


