----BTVN1: Ảnh: sử dụng insert into
IF OBJECT_ID('Tempdb..#_kq1') IS NOT NULL DROP TABLE #_kq1
SELECT Ngay_Ct, ct.So_Ct,Ten_Dt,
		CASE WHEN Loai_Ct = 0 THEN N'Mua hàng hóa' ELSE N'Bán hàng hóa' END AS Dien_Giai,
		vt.Ma_Vt,ISNULL(Ten_Vt, N'không có mã vật tư') AS Ten_Vt, 
		CASE WHEN Loai_Ct = 0 THEN So_luong ELSE 0 END AS SL_NHAP, 
		CASE WHEN Loai_Ct = 1 THEN So_luong ELSE 0 END AS SL_XUAT
INTO #_kq1
FROM Ct ct INNER JOIN CTCT ctCT ON ct.So_Ct = ctct.So_Ct
	LEFT JOIN DMVT vt On ctct.Ma_Vt = vt.Ma_Vt
	LEFT JOIN DMDT dt ON ct.Ma_Dt = dt.Ma_Dt
INSERT INTO #_kq1 
SELECT Ten_Dt 
FROM DMDT
WHERE Ma_Dt IN (SELECT Ma_Dt FROM #_kq1)

SELECT * 
FROM #_kq1
ORDER BY So_Ct
--bài 1: sai bét nhè 

--Bài 2: Ảnh: Dùng group by..
IF OBJECT_ID('Tempdb..#_kq2') IS NOT NULL DROP TABLE #_kq2
IF OBJECT_ID('Tempdb..#KQ3') IS NOT NULL DROP TABLE #KQ3
CREATE TABLE #_kq2
		(Ma_Vt NVARCHAR(16) NOT NULL, 
		 Ton_dau INT,
		 SL_Nhap INT, 
		 SL_Xuat INT,
		 Ton_Cuoi INT
		 )
INSERT INTO #_kq2 (Ma_Vt, Ton_dau, SL_Nhap, SL_Xuat, Ton_Cuoi)
SELECT Ma_Vt, So_luong, '' AS SL_Nhap,'' AS SL_Xuat,'' AS Ton_Cuoi
FROM Ton_Dau
INSERT INTO #_kq2 (Ma_Vt, Ton_dau, SL_Nhap, SL_Xuat, Ton_Cuoi)
SELECT Ma_Vt, 0 AS Ton_dau, 
				CASE WHEN Loai_Ct = 0 THEN So_luong ELSE 0 END,
				CASE WHEN Loai_Ct = 1 THEN So_luong ELSE 0 END, 0
FROM CTCT ctct LEFT JOIN CT ct ON ctct.So_Ct = ct.So_Ct

SELECT kq.Ma_Vt, Ten_Vt, SUM(Ton_dau) AS Ton_Dau, SUM(SL_Nhap) AS SL_Nhap, SUM(SL_Xuat) AS SL_Xuat, (SUM(Ton_dau) + SUM(SL_Nhap) - SUM(SL_Xuat)) AS Ton_Cuoi
INTO #KQ3
FROM #_kq2 kq LEFT JOIN DMVT vt ON kq.Ma_Vt = vt.Ma_Vt
GROUP BY kq.Ma_Vt, Ten_Vt

INSERT INTO #KQ3 (Ma_Vt,Ten_Vt, Ton_dau, SL_Nhap, SL_Xuat, Ton_Cuoi)
SELECT '', N'Tổng cộng' AS Ten_Vt, SUM(Ton_dau) AS Ton_Dau, SUM(SL_Nhap) AS SL_Nhap, SUM(SL_Xuat) AS SL_Xuat, (SUM(Ton_dau) + SUM(SL_Nhap) - SUM(SL_Xuat)) AS Ton_Cuoi
FROM #_kq2

SELECT * FROM #KQ3
