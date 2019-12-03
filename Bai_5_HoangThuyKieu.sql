--BTVN1: làm thế nào để cho dòng vật tư luôn luôn nằm ở trên, k phụ thuộc vào dữ liệu nào đổ trước dữ liệu nào đổ sau
SELECT Ma_Vt, Ten_Vt
 INTO #_KetQua
 FROM  DMVT
 INSERT INTO #_KetQua(Ma_Vt, Ten_Vt)
 SELECT Ma_Vt, N'Số lượng:'+ CAST(So_Luong AS NVARCHAR(50)) + ', ' + N' Tiền: '+ CAST(Tien AS  NVARCHAR(50)) AS Ten_Vt, 2 AS SX
 FROM CTCT
 WHERE So_Ct IN
	(
		SELECT So_Ct
		FROM CT
		WHERE Loai_Ct = 1
	)
INSERT INTO #_KetQua (Ma_Vt, Ten_Vt)
SELECT Ma_Vt, Ten_Vt, 1 AS SX
FROM #_KetQua
ORDER BY Ma_Vt, Ten_Vt
DROP TABLE #_KetQua

--Chữa
SELECT '' AS Ma_Vt, N'Nhóm vật tư: ' + 
			CASE 
			WHEN Loai_Vt = 2 THEN N'Nhóm vật tư: Sản phẩm ' 
			WHEN Loai_Vt = 1 THEN N'Nhóm vật tư: Vật tư'
			WHEN Loai_Vt = 0 THEN N'Nhóm vật tư: Dịch vụ'
			END AS Ten_Vt, Loai_Vt AS Loai_Vt, 2 AS SX
INTO #_Kq1
FROM DMVT
INSERT INTO #_Kq1 (Ma_Vt, Ten_Vt, SX)
SELECT Ma_Vt, N'Số lượng:'+ CAST(So_Luong AS NVARCHAR(50)) + ', ' + N' Tiền: '+ CAST(Tien AS  NVARCHAR(50)) AS Ten_Vt,Ma_Vt AS SX1, 1 AS SX2
FROM CTCT
WHERE So_Ct IN
	(
		SELECT So_Ct
		FROM CT
		WHERE Loai_Ct = 1
	)
SELECT Ma_Vt, Ten_Vt
FROM #_Kq1
ORDER BY SX,Ma_Vt

--BTVN2: Hiển thị đối tượng là công ty có phát sinh chứng từ trong năm 2019 dữ liệu chi tiết được sắp xếp ngày_ct giảm dần có dang sau dùng insert into
/*Ma_DT   Ten _Dt
DT001  
001     Phiếu nhập ngày :...
002     Phiếu xuất ngày: ...
DT002 
006     Phiesu nhập ngày:...*/

SELECT Ma_Dt, Ngay_Ct
INTO #_CT
FROM CT

INSERT INTO #_CT(Ma_Dt, Ngay_Ct)
SELECT Ma_DT, IIF(Loai_Ct =1, N'Phiếu xuất ngày: ', N'Phiếu nhập ngày: ') + CONVERT(NVARCHAR(10),Ngay_Ct,103) AS TT
FROM CT
WHERE YEAR(CT.Ngay_Ct) = 2019
	AND Ma_Dt IN 
	( SELECT Ma_Dt 
	FROM DMDT 
	WHERE Loai_Dt =1
	)
	 
SELECT Ma_Dt, Ngay_Ct
FROM #_CT
ORDER BY Ngay_Ct ASC
DROP TABLE #_CT
-- --Bài 3: Hiển thị ký tự đầu viết hoa, ký tự sau viết thương trong chuỗi Họ và tên( Không xđ: VD: 'Ninh Công Ngọc Hiếu), chuỗi k xác định
DECLARE @_Ten NVARCHAR(50),
		@_xkt NVARCHAR(100),
		@_kt  NVARCHAR(10)
SET @_Ten = N' Ninh   công ngọc HiếU'
--xóa khoảng trắng trong chuỗi
SET @_xkt = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(@_Ten,' ','*#*'),'#**',''),'*#*',' ')))
PRINT @_xkt
--chuyển sang chữ thường
SET @_xkt = LOWER(@_xkt)
PRINT @_xkt
WHILE @_kt = ' ' AND @_kt =''
BEGIN
	SET @_xkt = STUFF(@_xkt,1,1,UPPER(LEFT(@_xkt,1)))
	print @_xkt
END
--Em thử dùng while nhưng mà không được ạ :(((


--CHƯA
IF OBJECT_ID('Tempdb..#temp') IS NOT NULL DROP TABLE #temp
SELECT Ma_Dt, So_Ct, Ngay_Ct
INTO #temp
FROM CT
WHERE YEAR(Ngay_Ct) = 2019
AND Ma_Dt IN (SELECT Ma_Dt FROM DMDT WHERE Loai_Dt=2)
INSERT INTO #temp(Ma_Dt, So_Ct

