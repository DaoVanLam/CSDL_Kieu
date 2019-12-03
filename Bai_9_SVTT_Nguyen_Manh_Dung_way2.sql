
-- Bảng thông tin lấy một lần duy nhất
IF OBJECT_ID('Tempdb..#tt') IS NOT NULL DROP TABLE #tt
SELECT  Ngay_Ct , Loai_ct, ctct.Ma_vt,ctct.So_Luong, ISNULL(td.So_Luong,0) AS Ton
INTO #tt
FROM CT ct INNER JOIN CTCT ctct  ON ct.So_Ct = ctct.So_Ct	
		   LEFT JOIN Ton_Dau td ON ctct.Ma_Vt = td.Ma_Vt
UNION ALL
SELECT '12-12-2800' AS Ngay_Ct, NULL AS Loai_ct, Ma_Vt, NULL AS So_luong, So_Luong AS Ton
FROM Ton_Dau	

	 
-- Lấy bảng tồn động ( lượng tồn biến động mỗi lần có phát sinh )
IF OBJECT_ID('Tempdb..#td') IS NOT NULL DROP TABLE #td
SELECT Ma_Vt, Ton
INTO #td
FROM #tt
GROUP BY Ma_Vt,Ton

-- Lấy bảng kết quả ( chút update)
IF OBJECT_ID('Tempdb..#kq') IS NOT NULL DROP TABLE #kq

SELECT ROW_NUMBER() OVER(PARTITION BY Ma_Vt ORDER BY Ngay_ct) AS STT, Ngay_Ct,Loai_Ct, Ma_Vt, Dien_giai,
																		 Nhap, Xuat, Ton, So_Luong
INTO #kq
FROM
(
	SELECT Ngay_Ct, Loai_ct, Ma_Vt, ' ' AS Dien_giai, CASE WHEN Loai_Ct = 0 THEN So_Luong ELSE 0 END AS Nhap,  
													 CASE WHEN Loai_Ct = 1 THEN So_Luong ELSE 0 END AS Xuat, 
													 0 AS Ton, So_Luong
	FROM #tt
	WHERE Ngay_Ct <> '12-12-2800'

) A
UNION ALL
SELECT 0 AS STT, NULL AS Ngay_Ct, NULL AS Loai_ct, tt.Ma_Vt, ISNULL( MAX(vt.Ten_Vt),'') AS Dien_Giai,
									NULL AS nhap, NULL AS xuat, tt.Ton, NULL AS So_Luong
FROM #tt tt LEFT JOIN DMVT vt ON tt.Ma_Vt = vt.Ma_Vt
GROUP BY tt.Ma_Vt, tt.Ton
ORDER BY Ma_Vt, STT

--Bảng đệ quy
IF OBJECT_ID('Tempdb..#dq') IS NOT NULL DROP TABLE #dq
SELECT STT, Ma_Vt,  CASE WHEN Loai_Ct = 0 THEN  So_Luong ELSE - So_Luong END AS So_Luong,
					CASE WHEN Loai_Ct = 0 THEN  N'Nhập hàng hóa' ELSE N'Bán hàng hóa' END AS DG
INTO #dq
FROM #kq
WHERE STT <> 0

SELECT STT, Ngay_Ct, Ma_Vt, Dien_Giai, Nhap, Xuat, Ton 
FROM #kq

DECLARE @_Ton NUMERIC(18,6)

UPDATE #kq
SET @_Ton = ton = CASE WHEN STT = 0 THEN ton ELSE @_Ton + nhap - xuat END
FROM #kq



SELECT STT, Ngay_Ct, Ma_Vt, Dien_Giai, Nhap, Xuat, Ton 
FROM #kq

DROP TABLE #tt, #td, #kq, #dq

--Sử dụng vòng lặp while
--DECLARE @_STT INT,
--		@_Mavt NVARCHAR(15),
--		@_Soluong INT, 
--		@_ton_dong INT ,
--		@_DG NVARCHAR(50)

--WHILE ( EXISTS ( SELECT 1 FROM #dq) )
--BEGIN
--	SELECT TOP 1 @_STT = STT, @_Mavt = Ma_Vt,  @_Soluong = So_Luong, @_DG = DG
--	FROM #dq

--	-- Update bảng tồn động
--	UPDATE #td
--	SET ton = ton + @_Soluong
--	WHERE Ma_Vt = @_Mavt

--	-- Lấy kết quả từ bảng động
--	SET @_ton_dong = ( SELECT ton
--							FROM #td
--								WHERE Ma_Vt = @_Mavt)
--	-- Đưa vào bảng kết quả
--	UPDATE #kq
--	SET Ton = @_ton_dong, Dien_giai = @_DG
--	WHERE STT = @_STT AND Ma_vt = @_Mavt
--	--Xóa bản ghi từ bảng đệ quy
--	DELETE FROM #dq
--	WHERE STT = @_STT AND Ma_Vt = @_Mavt
--END


