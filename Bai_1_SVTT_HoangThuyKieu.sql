CREATE DATABASE QuanLyBanHang
GO
USE QuanLyBanHang
GO
Create table DMVT(
   Ma_Vt nvarchar(16) primary key not null,
   Ten_Vt nvarchar(96),
   Dvt nvarchar(10),
   Loai_Vt int,
   Dinh_Chi int ,
   )
CREATE TABLE DMDT(
    Ma_Dt NVARCHAR(16) PRIMARY KEY not null,
	Ten_Dt nvarchar(96) not null,
	Loai_Dt int not null,
	Dinh_Chi int,
	Ngay_Bd Datetime,
	Ngay_Kt Datetime
   )
--Chứng từ
CREATE TABLE CT(
    So_Ct nvarchar(10) primary key not null,
	Ngay_Ct datetime not null,
	Ma_Dt nvarchar(16) not null,
	Loai_Ct int not null,
	Dien_Giai nvarchar(256),
	Dinh_Chi int
)
--Chi tiết chứng từ
CREATE TABLE CTCT(
    So_Ct nvarchar(10) foreign key references dbo.CT(So_Ct),
	Ma_Vt nvarchar(16) not null,
	So_luong numeric(15,3),
	Don_gia numeric(15,3),
	Tien numeric(15,3),
)

--Tồn Đầu
CREATE TABLE Ton_Dau(
    Ma_Vt nvarchar(16) primary key not null,
	So_luong numeric(15,3),
	Tien numeric(18,2)
     )
	--BUỔI 1--
SELECT * FROM CTCT
--Hiển thị thông tin Ma_vt, So_luong, Don_gia, tiền, và thành tiền thực tế. TTTT = SL*DG dữ liệu trong bảng CTCT
--round số 0 đằng sau làm tròn k có dấu phẩy đằng sau, 2 làm tròn đến 2 số sau dấu phẩy
--CAST AS NUMRIC(18,0) định dang lại kiểu dữ liệu 0 có số 0 đằng sau
SELECT Ma_Vt, So_luong, Don_Gia,Tien,CAST(ROUND(So_luong * Don_gia,0) AS NUMERIC(18,0)) AS Tien_TT
FROM CTCT

--Hiển thị cột có dữ liệu và k hiển thị không có dữ liệu
SELECT So_Ct, Ma_Vt, Don_Gia, Tien 
FROM CTCT
WHERE So_Ct IS NOT NULL AND Ma_Vt IS NOT NULL AND Don_gia IS NOT NULL AND Tien IS NOT NULL
--Ví dụ: SELECT Ma_Vt, Don_Gia, Tien
--FROM CTCT
--WHERE ABS(So_Ct) + ABS(Don_Gia) + ABS(Tien) <> 0

DECLARE @chuoi1 nvarchar(256), @chuoi2 nvarchar(20)
SET @chuoi1 = N'Hà Nội '
SET @chuoi2 = N'Hải Phòng'
SELECT @chuoi1 + '-' + @chuoi2 --Ngoài select có thể dùng print

SELECT LEN(N'Hà Nội ') --ĐẾM TỪ


DECLARE @ten nvarchar(50), @vt int
SET @ten = N'Ninh Ngọc Hiếu'
PRINT CHARINDEX(' ', @ten)
SET @vt =CHARINDEX(' ',@ten)
SELECT LEFT(@ten,@vt-1)
---


--BT1: Hiện thị thông tin : Mã vật tư, Số lượng, Đơn giá, Tiền, Đơn giá thực tế ( = Tiền / Số lượng) Một số trường hợp số lượng bằng 0, trong các hoạt động kế toán, có các trường hợp khấu hao trong quá trình lưu kho 
SELECT Ma_Vt, So_luong, Don_Gia, Tien, CASE WHEN So_luong = 0 THEN 0 ELSE CAST(Tien /So_luong AS NUMERIC(18,5)) END AS DonGiaTT 
FROM CTCT

--BT2: Hiển thị Mã vật tư , Mã vật tư đầy đủ ( có dấu gạch ngang là tên Vật tư ) , Độ rộng của Mã vật tư đầy đủ ( Mã vật tư đó có bao nhiêu kí tự ) .
SELECT N'Hà Nôi' + '-' + N'Hải Phòng'
Select Ma_Vt,Ma_Vt + '-' + Ten_Vt As Ten_DD, LEN(Ma_Vt + '-' + Ten_Vt) AS Do_rong From DMVT

--BT3 : Cho một chuỗi gồm họ tên , viết ra chương trình lấy tên đệm và tên
-- mail to: svtt@bravo.com.vn
--cc: hieunn@Bravo.com.vn,, quyendv@bravo.com.vn
-- Thuật toán dùng Replace(Thay thế ký tự A thành  ký tự B
--Lấy họ:Ninh
--Dùng replace Ninh ->'' Ngọc Hiếu
--Lấy tên(chưa nói): Hiếu
--> Replace Hiếu ->' ' Ngọc 
--Sai; trường hợp tên ví dụ có tên Nguyễn Ly Ly

DECLARE @_Ten nvarchar(50), @_vt int
SET @_Ten = N'Ninh Ngọc Hiếu'
PRINT CHARINDEX(' ', @_Ten)
SET @_vt =CHARINDEX(' ',@_Ten)
Select SUBSTRING(@_Ten,@_vt,20)


DECLARE @_tencuoi nvarchar(50), @_vt1 int
SET @_tencuoi = N'Ninh Ngọc Hiếu'
PRINT CHARINDEX(' ', @_tencuoi)
SET @_vt1 =CHARINDEX(' ',@_tencuoi)
SELECT Right(@_tencuoi,@_vt1-1)

DECLARE @Hoten nvarchar(20)
DECLARE @VT1 int, @VT2 int
DECLARE @Ho nvarchar(50), @Dem nvarchar(20), @Ten nvarchar(20)
SET @Hoten =N'Ninh Cong Ngoc Hieu'
--tìm vị trsi các khoảng trăng trong tên
SET @VT1 = CHARINDEX(' ', @Hoten)
SET @VT2 = CHARINDEX(' ', REVERSE(@Hoten))
--Lay ra ho
SELECT @Ho = LEFT(@Hoten, @VT1)
PRINT @Ho
--Lay ra dem
SET @Dem = SUBSTRING(@Hoten, @VT1+1, LEN(@Hoten) - LEN(LEFT(@Hoten, @VT1))-LEN(RIGHT(@Hoten, @VT2)))
PRINT @Dem

--Buổi 2
--bài 1: Bo tat ca ki tu khoang trang thu trong chuoi Ninh ngoc hieu

DECLARE @_Chuoi1 nvarchar(50)
SET @_Chuoi1 =N'Hà nội và những cơn mưa'
Print REPLACE(@_Chuoi1,N'Hà Nôi',N'Hải Phòng')

-- CHO LIST Ma_Vt hiển thị danh sách vật tư tương ứng
DECLARE @_List_Code nvarchar(100),
		@_Srt nvarchar(100),
		@lenh nvarchar(100)
		
SET @_List_Code = 'CT001,CT002,CT003' 
SET @_Srt  = REPLACE(@_List_Code, ',', '''OR Ma_Vt =''')
PRINT @_Srt
SET @lenh = 'SELECT * 
			FROM DMVT 
			WHERE Ma_Vt = ''' + @_Srt + ''''
PRINT @lenh
EXEC(@lenh) 

-- Hiển thị danh sách những Vât tư theo chuỗi trèn vào, (vidu sắt, đồng) 
--sử dụng hàm LIKE
-- Bài 3: Hiển thị kí tự hoa đầu tiên của Họ Tên Đệm  cho 1 tên có 3 từ

--BUỔI 3
--Hiển thị những chứng từ phiếu nhập có tháng bằng tháng hiện tại 
--soosct, ngayct,loai ct
SELECT So_Ct, Ngay_Ct, Loai_Ct
FROM CT 
WHERE Loai_Ct = 0 AND
	MONTH(Ngay_Ct) = MONTH(GETDATE()) AND YEAR(Ngay_Ct) = YEAR(GETDATE())

--Hiển thị ngày đầu tiên của tháng hiện tại
SELECT DATEADD(DD,-DAY(GETDATE())+1,GETDATE())

-- Hiển thị ngày cuối cùng của tháng hiện tại
--lấy ngày đầu tiên của tháng sau -1
SELECT DATEADD(DD,-1, DATEADD(mm, DATEDIFF(mm, 0 ,GETDATE())+1, 0))
SELECT DATEADD(mm, DATEDIFF(mm, 0 ,GETDATE())+1, 0)

SELECT DATEADD(MM,-1,DATEADD(DD,-DAY(GETDATE())+1,GETDATE()))
SELECT DATEADD(DD, -DAY(GETDATE()),(DATEADD(MM,1,GETDATE())))
--BTVN1: Hiện thị các chứng từ phiếu xuất có phát sinh từ ngày hiện tại đến 60 ngày trở về trước gồm : So_Ct, Ngay_Ct, Loai_Ct
--BTVN2: Hiển thị ngày đầu quý và ngày cuối quý của tháng hiện tại

--Hieenr thị những dũ lieeuk khách hàng có phát sinh giao dịch với công ty lớn hơn 100 ngày:

--Cách 1:
SELECT  Ma_Dt, Ten_Dt
	FROM DMDT
		WHERE DATEDIFF(DD,Ngay_Bd,Ngay_Kt) > 100 AND Ngay_Kt <> ''

UNION ALL

SELECT  Ma_Dt, Ten_Dt
	FROM DMDT
		WHERE DATEDIFF(DD,Ngay_Bd,GETDATE()) > 100 AND Ngay_Kt = ''
--Cách 2: 

SELECT  Ma_Dt, Ten_Dt
	FROM DMDT
		WHERE (DATEDIFF(DD,Ngay_Bd,Ngay_Kt) > 100 AND Ngay_Kt <> '')
			OR (DATEDIFF(DD,Ngay_Bd,GETDATE()) > 100 AND Ngay_Kt = '')

--Cách 3 :

SELECT  Ma_Dt, Ten_Dt
	FROM DMDT
		WHERE DATEDIFF(DD,Ngay_Bd, ISNULL(Ngay_kt,GETDATE())) > 100

--Hiển thị giá trị ngày nhỏ nhất và ngày lớn nhất trong phiếu xuất: ngày ct, soct, loaict
SELECT MIN(Ngay_Ct) AS Ngay_xuat_min, MAX(Ngay_Ct) AS Ngay_xuat_max
FROM CT
WHERE Loai_Ct = 1

--Luyện tập câu lệnh không mang tính chất tối ưu 

--Dựa vào bài trên dùng WHILE giải quyết BTVN3

--BTVN3: Hiển thị các Ma_Dt xuất hiện trong phiếu có chuỗi sau:
--> Đối tượng các phiếu xuất gồm có : DT01, DT02, DT03, DT04
WHILE 