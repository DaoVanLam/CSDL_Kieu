IF OBJECT_ID('Tempdb..#KQ') IS NOT NULL DROP TABLE #KQ
IF OBJECT_ID('Tempdb..#KQ1') IS NOT NULL DROP TABLE #KQ1

SELECT CAST(ROW_NUMBER()OVER(PARTITION BY Ma_Vt ORDER BY Ngay_Ct DESC) AS NVARCHAR(16)) AS STT, Ngay_Ct, ISNULL(Ma_Vt,'') AS Ma_Vt,Loai_Ct,  SL_Nhap, SL_Xuat,  Ton,
		1 AS TT, ROW_NUMBER()OVER(PARTITION BY Ma_Vt ORDER BY Ngay_Ct) AS SX
INTO #KQ
FROM 
(
		SELECT CAST(ROW_NUMBER()OVER(PARTITION BY Ma_Vt ORDER BY Ngay_Ct DESC) AS NVARCHAR(16)) AS STT, Ngay_Ct, ISNULL(Ma_Vt,'') AS Ma_Vt, CAST(Loai_Ct as NVARCHAR(max)) AS Loai_Ct,
							CAST(CASE WHEN Loai_Ct = 0 THEN So_luong ELSE 0 END AS NUMERIC(18,0)) AS SL_Nhap,
							CAST(CASE WHEN Loai_Ct = 1 THEN So_luong ELSE 0 END AS NUMERIC(18,0)) AS SL_Xuat, CAST(So_luong AS NUMERIC(18,0)) AS Ton,
							1 AS TT, ROW_NUMBER()OVER(PARTITION BY Ma_Vt ORDER BY Ngay_Ct) AS SX
		FROM CT ct LEFT JOIN CTCT ctct ON ct.So_Ct = ctct.So_Ct
		UNION ALL
		SELECT '' AS STT, '' AS Ngay_Ct, '' AS Ma_Vt, '' AS Loai_Ct, 0 AS SL_Nhap, 0 AS SL_Xuat, CAST(So_Luong AS NUMERIC(18,0)) AS Ton, '' AS TT, '' AS SX
		FROM Ton_Dau
)A

INSERT INTO #KQ(STT, Ngay_Ct, kq.Ma_Vt, Loai_Ct, SL_Nhap, SL_Xuat,Ton, TT)
SELECT '' AS STT,0 AS Ngay_Ct, VT.Ma_Vt, MAX(Ten_Vt) Loai_Ct, NULL AS SL_Nhap,NULL AS SL_Xuat, ISNULL(SUM(So_Luong),0) AS Ton, MAX(0) AS TT
FROM DMVT VT LEFT JOIN Ton_Dau TD ON VT.Ma_Vt = TD.Ma_Vt
GROUP BY VT.Ma_Vt

SELECT STT, Ma_Vt, Loai_Ct, SL_Nhap, SL_Xuat, Ton
INTO #KQ1
FROM #KQ 
ORDER BY Ma_Vt DESC, TT, SX

DECLARE @STTMAX INT,
		@STT INT,
		@ton NVARCHAR(MAX),
		@mavt NVARCHAR(MAX),
		@mavt1	NVARCHAR(max),
		@sl_nhap NUMERIC(15,3),
		@sl_xuat NUMERIC(15,3),
		@ton1 NUMERIC(15,3)

	SET @STTMAX = (SELECT MAX(STT) FROM #KQ1)
	SET @STT =1
	SET @ton =0
	SET @mavt = ''
WHILE @STT<= @STTMAX
BEGIN
	SELECT @mavt1= ma_vt, @sl_nhap =SL_Nhap, @sl_xuat = SL_Xuat, @ton1 = Ton
	FROM #KQ1 WHERE STT = @STT
	IF @mavt1 <= @mavt
	BEGIN
	SET @mavt = @mavt1
	SET @ton = @ton1
    ELSE
    SET @ton = @ton + @sl_nhap - @sl_xuat
	END
	UPDATE #KQ1 SET @ton = @ton1
	WHERE STT = @STT
	SET @STT = @STT +1
END;
