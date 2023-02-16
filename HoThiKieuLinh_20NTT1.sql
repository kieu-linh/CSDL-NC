CREATE DATABASE db_DATHANG
GO
USE db_DATHANG
GO
CREATE TABLE tb_KHACHHANG(
	MaKH VARCHAR(50) not null primary key,
	TenKH NVARCHAR(Max) not null,
	Email VARCHAR(50),
	SoDT  VARCHAR(50),
	DiaChi VARCHAR(50) 
)
CREATE TABLE tb_DMSANPHAM(
	MaDM VARCHAR(50) not null primary key,
	TenDM NVARCHAR(Max) not null,
	MoTa VARCHAR(50), 
)

CREATE TABLE tb_THANHTOAN(
	MaTT VARCHAR(50) not null primary key,
	PhuongThucTT NVARCHAR(Max) not null,
)
CREATE TABLE tb_SANPHAM(
	MaSP VARCHAR(50) not null primary key,
	TenSP NVARCHAR(Max) not null,
	GiaTien INT,
	SoLuongCon INT,
	XuatXu VARCHAR(50) ,
	MaDM VARCHAR(50) not null foreign key REFERENCES tb_DMSANPHAM
)
CREATE TABLE tb_DONHANG(
	MaDH VARCHAR(50) not null primary key,
	NgayDat DATE,
	MaKH VARCHAR(50) not null foreign key REFERENCES tb_KHACHHANG,
	MaTT VARCHAR(50) not null foreign key REFERENCES tb_THANHTOAN
)
CREATE TABLE tb_CHITIETDONHANG(
	MaDH VARCHAR(50) not null primary key,
	MaSP VARCHAR(50) not null foreign key REFERENCES tb_SANPHAM,
	SoLuong INT,
	TongTien FLOAT
)

SELECT * FROM tb_SANPHAM
SELECT * FROM tb_DONHANG
SELECT * FROM tb_CHITIETDONHANG
SELECT * FROM tb_KHACHHANG
SELECT * FROM tb_THANHTOAN
SELECT * FROM tb_DMSANPHAM
--Câu 2:
--a) 
GO
CREATE TRIGGER DH_1
ON tb_DONHANG
FOR INSERT
AS
BEGIN 
	DECLARE @MaKH INT, @NgayDat DATE
	SELECT MaKH=@MaKH,NgayDat=@NgayDat
	FROM INSERTED
	IF @NgayDat>GETDATE()
	BEGIN
		PRINT N'Ngày đặt phải nhỏ hơn hoặc bằng ngày hiện tại'
		ROLLBACK TRANSACTION
	END
	IF NOT EXISTS(SELECT MaKH FROM tb_KHACHHANG WHERE MaKH=@MaKH)
	BEGIN
		PRINT N'Mã khách hàng không tồn tại'
		ROLLBACK TRANSACTION
	END
END
GO
--test
INSERT INTO tb_DONHANG(MaKH,MaTT,NgayDat)
VALUES('KH007','TT001','2018-01-01')
--Cau2: b
GO
CREATE TRIGGER DH_2
ON tb_CHITIETDONHANG
FOR INSERT,UPDATE
AS
BEGIN
    DECLARE @maDH varchar(50), @soLuong int,@soLuongCon int,@maSP varchar(50)
         SELECT @maDH=MaDH,@soLuong=SoLuong,@maSP=MaSP FROM inserted
            IF @soLuong<=0
            BEGIN
               PRINT 'Số lượng phải lớn hơn 0';
                rollback transaction
            END
            SELECT @soLuongCon=SoLuongCon FROM tb_SANPHAM WHERE MaSP=@maSP
            IF @soLuong>@soLuongCon
            BEGIN
                 PRINT 'Số lượng không đủ';
                rollback transaction
            END
            update tb_SANPHAM set SoLuongCon = SoLuongCon-@soLuong where MaSP=@maSP
END
-- GỌI TRIGGER TRÊN BẢNG CHITIETDONHANG
INSERT INTO tb_CHITIETDONHANG(MaDH,MaSP,SoLuong,TongTien)
VALUES('DH001','SP002',10,1000000)
GO
--Cau3 a
CREATE PROCEDURE DH_1
@MaKH VARCHAR(50),
@MaTT VARCHAR(50),
@NgayDat DATE
AS
BEGIN
    IF NOT EXISTS(SELECT MaKH FROM TB_KHACHHANG WHERE MaKH=@MaKH)
       BEGIN
             PRINT 'Mã khách hàng không tồn tại';
             ROLLBACK TRANSACTION
      END
   IF @NgayDat>GETDATE()
     BEGIN
                PRINT 'Ngày đặt phải nhỏ hơn ngày hiện tại'
                ROLLBACK TRANSACTION
     END
   INSERT INTO TB_DONHANG(MaKH,MaTT,NgayDat)
   VALUES(@MaKH,@MaTT,@NgayDat)
END
GO
-- GỌI THỦ TỤC
EXEC DH_1 'KH002','TT002', '2022-12-29'
GO
--Cau3 b
CREATE PROCEDURE SP_CHITIETDONHANG
@MaDH INT,
@MaSP INT,
@SoLuong INT,
@TongTien MONEY
AS
BEGIN
    DECLARE @soLuongCon int
        IF @SoLuong<=0
            BEGIN
                PRINT 'Số lượng phải lớn hơn 0';
                rollback transaction
            END
            SELECT @soLuongCon=SoLuongCon FROM tb_SANPHAM WHERE MaSP=@MaSP
            IF @SoLuong>@soLuongCon
            BEGIN
                PRINT 'Số lượng không đủ';
                rollback transaction
            END
			SELECT 
            UPDATE tb_CHITIETDONHANG SET MaSP=@MaSP,SoLuong=@SoLuong,TongTien=@TongTien WHERE MaDH=@MaDH
            UPDATE tb_SANPHAM SET SoLuongCon=SoLuongCon-@SoLuong WHERE MaSP=@MaSP
END
GO
-- GỌI THỦ TỤC
SELECT * FROM tb_CHITIETDONHANG
SELECT * FROM tb_SANPHAM
EXEC tb_CHITIETDONHANG 'SP001','40','20000'
GO
--CÂU 4: 
CREATE FUNCTION Func_1(@min int,@max int)
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM tb_DMSANPHAM
    WHERE MaDM IN
               (  SELECT MaDM FROM tb_SANPHAM WHERE SoLuongCon BETWEEN @min AND @max)
)
GO
-- GỌI HÀM
SELECT * FROM Func_1(1,10)
--