create database dbQuanLyCongTacGiaoHang
go
use dbQuanLyCongTacGiaoHang
go
--KhachHang
create table KhachHang
(
makhachhang varchar(10) primary key,
tencongty nvarchar(20),
tengiaodich nvarchar(20),
diachi nvarchar(20),
email varchar(20),
dienthoai varchar(11),
fax varchar(11)
)
go
--NhanVien
create table NhanVien
(
manhanvien varchar(10) primary key,
ho nvarchar(20),
ten nvarchar(20),
ngaysinh date,
ngaylamviec date,
diachi nvarchar(20),
dienthoai varchar(11),
luongcoban float,
phucap float
)
--LoaiHang
create table LoaiHang
(
maloaihang varchar(10) primary key,
tenloaihang nvarchar(20),
)


--Nha Cung Cap
create table NhaCungCap
(
macongty varchar(10) primary key,
tencongty nvarchar(20),
tengiaodich nvarchar(20),
diachi nvarchar(20),
dienthoai varchar(11),
fax varchar(11),
email nvarchar(20)
)

--MatHang
create table MatHang
(
mahang varchar(10) primary key,
tenhang nvarchar(20),
macongty varchar(10),
maloaihang varchar(10),
soluong int,
donvitinh varchar(10),
giahang float,
constraint fk_H foreign key(maloaihang) references LoaiHang(maloaihang),
constraint fk_C foreign key(macongty) references NhaCungCap(macongty)
)
go

--DonDatHang
create table DonDatHang
(
sohoadon varchar(10) primary key,
makhachhang varchar(10),
manhanvien varchar(10),
ngaydathang date,
ngaygiaohang date,
ngaychuyenhang date,
noigiaohang nvarchar(20),
constraint FK_KH foreign key(makhachhang)  references KhachHang(makhachhang),
constraint FK_NV foreign key(manhanvien)  references NhanVien(manhanvien)
)
--ChiTietDonHang
create table CHITIETDONHANG
(
sohoadon varchar(10),
mahang varchar(10),
giaban float,
spluong int,
mucgiamgia float,
constraint PK_HD primary key (sohoadon,mahang),
constraint FK_HD foreign key (sohoadon) references DonDatHang(sohoadon),
constraint FK_HG foreign key (mahang) references MatHang(mahang)
)
go
--5.1 T?o th? t?c lưu tr? đ? thông qua th? t?c này có th? b? sung thêm m?t b?n ghi m?i
--cho b?ng MATHANG (th? t?c ph?i th?c hi?n ki?m tra tính h?p l? c?a d? li?u c?n
--b? sung: không trùng khoá chính và đ?m b?o toàn v?n tham chi?u)
create proc p_1
(@mahang varchar(10),
@tenhang nvarchar(20),
@macongty varchar(10),
@maloaihang varchar(10),
@soluong int,
@donvitinh varchar(10),
@giahang float
)
as
 begin
  if exists(select * from MatHang where mahang=@mahang)
  begin 
  print (N'Trùng khóa chính');
  end
  if not exists(select *from NhaCungCap where macongty = @macongty )
  begin
  print (N'Không tồn tại mã công ty');
  end
  if not exists(select *from LoaiHang where maloaihang = @maloaihang)
  begin
  print (N'không tồn tại mã loại hàng');
  end
  insert into MatHang values(@mahang, @tenhang, @macongty,@maloaihang, @soluong,@donvitinh,@giahang)
 end
 go


  p_1 'H09','Banh mi','C01','L01',100,'cai',10000
  select * from MatHang

 -- --5.2 Tạo thủ tục lưu trữ có chức năng thống kê tổng số lượng hàng bán được của một
--mặt hàng có mã bất kỳ (mã mặt hàng cần thống kê là tham số của thủ tục).
create procedure sp_TongSoLuongHangBanDuoc(@mahang varchar(10))
as
begin
select sum(spluong) as 'TongSoLuongHangBanDuoc' from CHITIETDONHANG where mahang = @mahang
end
go
-- gọi thủ tục
sp_TongSoLuongHangBanDuoc 'H01'
go
--5.3
CREATE FUNCTION func_banhang()
RETURNS TABLE
AS
RETURN (SELECT mh.mahang,tenhang,
CASE
WHEN sum(soluong) IS NULL THEN 0
ELSE sum(soluong)
END AS tongsl
FROM MatHang mh LEFT OUTER JOIN CHITIETDONHANG ct
ON mh.mahang = ct.mahang
GROUP BY mh.mahang,tenhang)
go
--
select * from func_banhang()
go
--5.4
--Khi một bản ghi mới được bổ sung vào bảng này thì giảm số lượng hàng
--hiện có nếu số lượng hàng hiện có lớn hơn hoặc bằng số lượng hàng được
--bán ra. Ngược lại thì huỷ bỏ thao tác bổ sung.


create trigger trigg_2
on CHITIETDONHANG
for insert
as
  begin
  declare @mahang varchar(10)
  declare @spluong int
  declare @soluongban int
  select @mahang = mahang, @soluongban = spluong from inserted
  select @spluong = soluong from MatHang where @mahang = mahang
  if(@soluongban < @spluong)
  update MatHang set soluong =@spluong -  @soluongban  where @mahang = mahang
  else
  rollback transaction
  end

--Thuc thi trigger
select *from CHITIETDONHANG
go
select * from MatHang
go
select * from DonDatHang
insert into CHITIETDONHANG(sohoadon,mahang,giaban,spluong,mucgiamgia) 
values('002','001',230000, 4 ,34)