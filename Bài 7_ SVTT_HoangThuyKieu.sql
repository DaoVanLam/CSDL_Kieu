-- UNION: cột giống nhau, kiểu dư liệu của 2 cột ở 2 cậu select giống nhau
--UNION ALL: k loại bỏ kết quả trùng lặp, 
IF OBJECT_ID('Tempdb..#_kq2') IS NOT NULL DROP TABLE #_kq2
IF OBJECT_ID('Tempdb..#KQ3') IS NOT NULL DROP TABLE #KQ3
CREATE TABLE #_kq2
		(Ma_Vt NVARCHAR(16) NOT NULL, 
		 Ton_dau INT,
		 SL_Nhap INT, 
		 SL_Xuat INT,
		 Ton_Cuoi INT,
		 Thu_Tu INT
		 )

INSERT INTO #_kq2 (Ma_Vt, Ton_dau, SL_Nhap, SL_Xuat, Ton_Cuoi,Thu_Tu)
SELECT Ma_Vt, So_luong, 0 AS SL_Nhap, 0 AS SL_Xuat,'' AS Ton_Cuoi,''
FROM Ton_Dau

INSERT INTO #_kq2 (Ma_Vt, Ton_dau, SL_Nhap, SL_Xuat, Ton_Cuoi, Thu_Tu)
SELECT Ma_Vt, 0 AS Ton_dau, 
			CASE WHEN Loai_Ct = 0 THEN So_luong ELSE 0 END,
			CASE WHEN Loai_Ct = 1 THEN So_luong ELSE 0 END, 0,''
FROM CTCT ctct LEFT JOIN CT ct ON ctct.So_Ct = ct.So_Ct

SELECT kq.Ma_Vt, Ten_Vt, SUM(Ton_dau) AS Ton_Dau, SUM(SL_Nhap) AS SL_Nhap, SUM(SL_Xuat) AS SL_Xuat, (SUM(Ton_dau + SL_Nhap - SL_Xuat)) AS Ton_Cuoi, Loai_Vt AS Thu_Tu
INTO #KQ3
FROM #_kq2 kq LEFT JOIN DMVT vt ON kq.Ma_Vt = vt.Ma_Vt
GROUP BY kq.Ma_Vt, Ten_Vt , Loai_Vt
SELECT * FROM #KQ3

INSERT INTO #KQ3 (Ma_Vt,Ten_Vt, Ton_dau, SL_Nhap, SL_Xuat, Ton_Cuoi, Thu_Tu)
SELECT '', N'Nhóm dịch vụ' AS Ten_Vt, SUM(Ton_dau) AS Ton_Dau, SUM(SL_Nhap) AS SL_Nhap, SUM(SL_Xuat) AS SL_Xuat, (SUM(Ton_dau + SL_Nhap- SL_Xuat)) AS Ton_Cuoi, 0
FROM #_kq2 kq LEFT JOIN DMVT vt ON kq.Ma_Vt = vt.Ma_Vt
WHERE Loai_Vt = 0

INSERT INTO #KQ3 (Ma_Vt,Ten_Vt, Ton_dau, SL_Nhap, SL_Xuat, Ton_Cuoi,Thu_Tu)
SELECT '', N'Nhóm Sản phẩm' AS Ten_Vt, SUM(Ton_dau) AS Ton_Dau, SUM(SL_Nhap) AS SL_Nhap, SUM(SL_Xuat) AS SL_Xuat, (SUM(Ton_dau + SL_Nhap- SL_Xuat)) AS Ton_Cuoi, 2
FROM #_kq2 kq LEFT JOIN DMVT vt ON kq.Ma_Vt = vt.Ma_Vt
WHERE Loai_Vt = 2

INSERT INTO #KQ3 (Ma_Vt,Ten_Vt, Ton_dau, SL_Nhap, SL_Xuat, Ton_Cuoi, Thu_Tu)
SELECT '', N'Nhóm vật tư' AS Ten_Vt, SUM(Ton_dau) AS Ton_Dau, SUM(SL_Nhap) AS SL_Nhap, SUM(SL_Xuat) AS SL_Xuat, (SUM(Ton_dau + SL_Nhap- SL_Xuat)) AS Ton_Cuoi, 1
FROM #_kq2 kq LEFT JOIN DMVT vt ON kq.Ma_Vt = vt.Ma_Vt
WHERE Loai_Vt = 1

INSERT INTO #KQ3 (Ma_Vt,Ten_Vt, Ton_dau, SL_Nhap, SL_Xuat, Ton_Cuoi, Thu_Tu)
SELECT '', N'Tổng cộng' AS Ten_Vt, SUM(Ton_dau) AS Ton_Dau, SUM(SL_Nhap) AS SL_Nhap, SUM(SL_Xuat) AS SL_Xuat, (SUM(Ton_dau + SL_Nhap- SL_Xuat)) AS Ton_Cuoi,3
FROM #_kq2

SELECT Ma_Vt, Ten_Vt, Ton_Dau, SL_Nhap, SL_Xuat, Ton_Cuoi FROM #KQ3
ORDER BY Thu_Tu, Ma_Vt

--;with a as (select....
-- BTVN: NHÓM VẬT TƯ: Loai_Vt
