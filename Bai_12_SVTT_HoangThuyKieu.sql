--BTVN; Hiển thị thông tin MaDt, TenDt, NGayBd, Ngay Nhập vật tư gần nhất, Ngày xuất Vt xa nhất, NGày Kt, (ĐK: Ngày nhâp >= 30 ngày so với ngày Bd, Ngày xuất >=60 ngày so với ngày Bd)
-----------------------cách 1 dùng while------------------------------
IF OBJECT_ID('Tempdb..#tem') IS NOT NULL DROP TABLE #tem
SELECT ROW_NUMBER() OVER(ORDER BY dt.Ma_Dt ASC) AS STT,Ngay_Ct, dt.Ma_Dt, Ten_Dt, Ngay_Bd, CAST(NULL AS DATETIME) AS Ngay_Nhap_GN, CAST(NULL AS DATETIME) AS Ngay_Xuat_XN, Ngay_Kt, Loai_Ct
INTO #tem 
FROM DMDT dt LEFT JOIN CT ON dt.Ma_Dt = ct.Ma_Dt
-- Tạo bảng #tem cast tạo cột Nhập gần nhất và xuất xa nhất
DECLARE @_MIN_NHAP DATETIME,
		@_MAX_XUAT DATETIME
SET @_MIN_NHAP = (SELECT MIN(Ngay_Ct) 
					FROM #tem
					WHERE Loai_Ct = 0)
SET @_MAX_XUAT = (SELECT MAX(Ngay_Ct) 
					FROM #tem
					WHERE Loai_Ct = 1)

IF OBJECT_ID('Tempdb..#NHAP_GN') IS NOT NULL DROP TABLE #NHAP_GN
SELECT DT.Ma_Dt, Ten_Dt, Ngay_Bd, Ngay_Kt, Ngay_Ct
INTO #NHAP_GN
FROM DMDT DT LEFT JOIN CT CT ON DT.Ma_Dt = CT.Ma_Dt
WHERE Loai_Ct = 0 AND @_MIN_NHAP - Ngay_Bd >30
ORDER BY Ngay_Ct ASC
--N'lấy các đối tượng có ngày nhập gần nhất có ngày nhập lớn hơn ngày bd 30 ngày

IF OBJECT_ID('Tempdb..#XUAT_XN') IS NOT NULL DROP TABLE #XUAT_XN
SELECT DT.Ma_Dt, Ten_Dt, Ngay_Bd, Ngay_Kt, Ngay_Ct
INTO #XUAT_XN
FROM DMDT DT LEFT JOIN CT CT ON DT.Ma_Dt = CT.Ma_Dt
WHERE Loai_Ct = 1 AND @_MAX_XUAT - Ngay_Bd >60
ORDER BY Ngay_Ct DESC
--N' lấy các đối tượng có ngày xuất xa nhastt: lớn hơn 60 ngày so với ngày bắt đầu

DECLARE @_MAX_STT INT, @STT INT, @MA NVARCHAR(MAX), @NGAY DATETIME = NULL
SET @STT = 1
SET @_MAX_STT = (SELECT MAX(STT) FROM #tem)

WHILE (@STT <= @_MAX_STT)
BEGIN
		SELECT @MA = Ma_Dt, @NGAY = Ngay_Ct
		FROM #tem
		WHERE STT = @STT
		
		UPDATE #tem SET Ngay_Nhap_GN = (SELECT TOP 1 Ngay_Ct 
										FROM #NHAP_GN
										WHERE Ma_Dt = @MA AND Ngay_Ct >= @NGAY)
				WHERE Ma_Dt = @MA AND STT = @STT

		UPDATE #tem SET Ngay_Xuat_XN = (SELECT TOP 1 Ngay_Ct
										FROM #XUAT_XN
										WHERE Ma_Dt = @MA AND Ngay_Ct >= @NGAY)
				WHERE Ma_Dt = @MA AND STT = @STT

		SET @STT = @STT + 1	
END

SELECT Ma_Dt, Ten_Dt, Ngay_Bd, Ngay_Nhap_GN, Ngay_Xuat_XN, Ngay_Kt
FROM #tem



--------------cách 2----------------
SELECT TEM.Ma_Dt, Ten_Dt, Ngay_bd, Nhap.Ngay_Ct AS Nhap_GN, Xuat.Ngay_Ct AS Xuatt_XN, Ngay_Kt
FROM 
	(
		 SELECT DT.Ma_Dt, Ten_Dt, Ngay_Bd, Ngay_Kt, Ngay_Ct
		 FROM DMDT DT LEFT JOIN CT CT ON DT.Ma_Dt = CT.Ma_Dt
	)TEM
	OUTER APPLY
	(
		SELECT TOP 1 Ngay_Ct 
		FROM DMDT DT LEFT JOIN CT CT ON DT.Ma_Dt = CT.Ma_Dt
		WHERE Loai_Ct = 0  AND TEM.Ma_Dt = CT.Ma_Dt AND TEM.Ngay_Ct - Ngay_Bd>30 
		ORDER BY Ngay_Ct ASC
	)Nhap
	OUTER APPLY
	(
		SELECT TOP 1 Ngay_Ct 
		FROM DMDT DT LEFT JOIN CT CT ON DT.Ma_Dt = CT.Ma_Dt
		WHERE Loai_Ct = 1  AND TEM.Ma_Dt = CT.Ma_Dt AND TEM.Ngay_Ct - Ngay_Bd>30 
		ORDER BY Ngay_Ct DESC
	)Xuat

------------------BÀI 2-----------------------------------------------------


IF OBJECT_ID('Tempdb..#Temp') IS NOT NULL DROP TABLE #Temp
SELECT ct.Ngay_Ct, ctct.Ma_Vt,  ctct.Ma_Vt AS Ma_VT1, ct.Dien_Giai, ctct.So_Luong, Tien,
		ROW_NUMBER() OVER( ORDER BY So_Luong DESC) AS STT				
	INTO #temp
	FROM CT ct INNER JOIN CTCT ctct ON ct.So_Ct = ctct.So_Ct
	WHERE ct.Loai_Ct = 0 AND YEAR(ct.Ngay_Ct) = YEAR(GETDATE())
	
DECLARE @_Top2 NVARCHAR(MAX)
SET @_Top2 = 2
IF OBJECT_ID('Tempdb..#Temp1') IS NOT NULL DROP TABLE #Temp1
SELECT STT, Ma_Vt   
	INTO #Temp1
	FROM (
			SELECT ROW_NUMBER() OVER( ORDER BY SUM(So_Luong) DESC) AS STT, Ma_Vt
				FROM #temp
				GROUP BY Ma_Vt
		 ) X		
	WHERE STT <= @_Top2 

DECLARE @_str_sl NVARCHAR(MAX) ='',
		@_str_tien NVARCHAR(MAX) ='',
		@_str1 NVARCHAR(MAX)='',
		@_str NVARCHAR(MAX),
		@_str2 NVARCHAR(MAX)=''

SELECT @_str_sl += ', ' + QUOTENAME(Ma_Vt + '_SL'), @_str_tien += ', ' + QUOTENAME(Ma_Vt + '_Tien'),
	   @_str1 += ', ' + ''''+ Ma_vt +''''
FROM #Temp1
SELECT @_str2 += ', ' + QUOTENAME(Ma_Vt + '_SL') + ', ' + QUOTENAME(Ma_Vt + '_Tien')
FROM #Temp1

SET @_str1 = STUFF(@_str1, 1, 2, '')
SET @_str_sl = STUFF(@_str_sl, 1, 2, '')
SET @_str_tien = STUFF(@_str_tien, 1, 2, '')

PRINT @_STR1
PRINT @_STR_SL
PRINT @_STR_TIEN
PRINT @_STR2

--UPDATE #Temp
--	SET Ma_Vt1 = 'Khac'
--	WHERE Ma_Vt NOT IN (SELECT Ma_Vt FROM #Temp1)

SET @_str = ' SELECT STT, Ngay_Ct, Ma_Vt, Dien_Giai , '+@_str2+',[Khac_SL], [Khac_Tien]
			FROM 
			(
				SELECT STT, Ngay_CT, Dien_Giai, CASE WHEN Ma_Vt IN ('+ @_str_sl +') THEN Ma_Vt + ''_SL'' ELSE ''Sl_Khac'' END AS Ma_Vt, So_Luong 
				FROM #temp
			)A
			PIVOT
			(
			SUM(So_Luong) FOR Ma_vt IN (' + @_str_sl + ', [Khac_SL])
			) B 
		 INNER JOIN 
				SELECT STT, Ngay_CT, Dien_Giai, CASE WHEN Ma_Vt IN ('+ @_str_tien +') THEN Ma_Vt + ''_Tien'' ELSE ''Khac_Tien'' END AS Ma_vt, Dien_Giai, Tien 
				FROM #temp
				PIVOT
				(
				SUM(Tien) FOR Ma_vt IN (' + @_str_tien + ', [Khac_Tien])
				) C 
				'
EXEC(@_str)