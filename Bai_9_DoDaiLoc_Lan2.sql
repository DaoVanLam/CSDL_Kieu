

---- Cách 3:

IF OBJECT_ID ('TempDb..#temp') IS NOT NULL DROP TABLE #temp
SELECT CONVERT(NVARCHAR(15),Ngay_Ct,103) AS Ngay , CTCT.Ma_Vt, CT.Dien_Giai,
		CASE WHEN CT.Loai_Ct = 0 THEN CTCT.So_Luong ELSE 0 END AS SL_Nhap,
		CASE WHEN CT.Loai_Ct = 1 THEN CTCT.So_Luong ELSE 0 END AS SL_Xuat, CAST(0 AS NUMERIC(15,3)) AS Ton
	INTO #temp
	FROM CT INNER JOIN CTCT ON CT.So_Ct = CTCT.So_Ct

INSERT INTO #temp(Ngay, Ma_Vt, Dien_Giai, SL_Nhap, SL_Xuat, Ton)
SELECT '' AS Ngay , A.Ma_Vt AS Ma_Vt, ISNULL(MAX(DMVT.Ten_Vt),N'Không có tên') AS Dien_Giai, 0 AS SL_Nhap, 0 AS SL_Xuat, SUM(A.Ton) AS Ton 
	FROM( SELECT DISTINCT Ma_Vt, 0 AS Ton
			  FROM CTCT
		  UNION ALL
		  SELECT DISTINCT Ma_Vt, So_Luong AS Ton
			  FROM Ton_Dau
		) A LEFT JOIN DMVT ON A.Ma_Vt = DMVT.Ma_Vt
	GROUP BY A.Ma_Vt

IF OBJECT_ID('TempDb..#kq') IS NOT NULL DROP TABLE #kq
SELECT Ngay, Ma_Vt, Dien_Giai, SL_Nhap, SL_Xuat, Ton, ROW_NUMBER() OVER (ORDER BY Ma_Vt,Ngay) AS STT
	INTO #kq
	FROM #temp

DECLARE @_Ton NUMERIC(15,3), @_Ma_Vt NVARCHAR(16)

SET @_Ma_Vt = ''
SET @_Ton = 0

UPDATE #kq
	SET @_Ton = Ton = CASE WHEN Ma_Vt = @_Ma_Vt THEN @_Ton + SL_Nhap - SL_Xuat ELSE Ton END, @_Ma_Vt = Ma_Vt
	FROM #kq

SELECT * FROM #kq

