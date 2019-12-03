
---------------------------------------------------Cách 1 : Dùng WHILE -----------------------------------------------------------------------------
-- Giá trị truyền vào
DECLARE @_max INT
SET @_max = 2

-- Chọn  ra top 2 ( ko lấy trùng)
IF OBJECT_ID('Tempdb..#Top2') IS NOT NULL DROP TABLE #Top2
SELECT RANK, Ma_Vt, So_luong 
INTO  #Top2
FROM 
(
	SELECT ROW_NUMBER() OVER(ORDER BY SUM(So_luong) DESC) AS RANK, Ma_Vt, SUM(So_Luong) AS So_luong -- Nếu muốn lấy tất thì dùng hàm RANK
	FROM CT ct INNER JOIN CTCT ctct ON ct.So_ct = ctct.So_ct
	WHERE Loai_Ct = 0
	GROUP BY  Ma_Vt
) R
WHERE RANK < @_max + 1 

-- Bảng kết quả
IF OBJECT_ID('Tempdb..#kq') IS NOT NULL DROP TABLE #kq
SELECT ctct.So_Ct, ct.Ngay_Ct, Ma_Vt, ctct.So_Luong, ct.Dien_Giai
INTO #kq
FROM CT ct INNER JOIN CTCT ctct ON ct.So_ct = ctct.So_ct

--Thêm cột, update dữ liệu vào bảng kết quả bằng vòng lặp while
DECLARE @_STT INT = 1,
		@_Ma_vt NVARCHAR(50),
		@_lenh_add_cot NVARCHAR(MAX),
		@_lenh_update_cot NVARCHAR(MAX)

WHILE (@_STT < @_max +1)
BEGIN 
	SELECT @_Ma_vt = Ma_Vt
	FROM #Top2
	WHERE RANK  = @_STT
	
	SET @_lenh_add_cot = 
	'
		ALTER TABLE #kq
		ADD ' + @_Ma_vt +' INT
	'
	EXEC (@_lenh_add_cot)

	SET @_lenh_update_cot =
	'
		UPDATE #kq
		SET ' + @_Ma_vt + ' = #kq.So_luong
		FROM #kq INNER JOIN CTCT ON #kq.So_ct = CTCT.so_ct AND #kq.Ma_vt = ''' + @_Ma_vt + '''
	'
	EXEC (@_lenh_update_cot)

	SET @_STT = @_STT + 1
END

-- Thêm cột 'khác'
ALTER TABLE #kq
ADD Khac INT
-- UPDATE dữ liệu cột 'khác'
UPDATE #kq
SET khac = #kq.So_Luong
FROM #kq INNER JOIN CTCT ON #kq.So_ct = CTCT.so_ct AND #kq.Ma_vt NOT IN (SELECT Ma_Vt
																			FROM #Top2)

-- Lọc dữ liệu như yêu cầu đề bài
DECLARE @_name NVARCHAR(MAX) = '',
		@_cmd NVARCHAR(MAX)

SELECT @_name += ', ' + Ma_Vt
FROM #Top2

SET @_cmd =
'
SELECT  So_ct, Ngay_Ct, Ma_Vt, So_Luong, Dien_Giai ' + @_name + ', khac
FROM #kq
'
EXEC(@_cmd)
DROP TABLE #kq, #Top2
---------------------------------------------------Cách 2: Dùng PIVOT -----------------------------------------------------------------------------

-- Giá trị truyền vào
DECLARE @_max1 INT
SET @_max1 = 2

-- Chọn  ra top 2 ( ko lấy trùng)
IF OBJECT_ID('Tempdb..#Top2') IS NOT NULL DROP TABLE #Top2
SELECT RANK, Ma_Vt, So_luong 
INTO  #Top2
FROM 
(
	SELECT ROW_NUMBER() OVER(ORDER BY SUM(So_luong) DESC) AS RANK, Ma_Vt, SUM(So_Luong) AS So_luong -- Nếu muốn lấy tất thì dùng hàm RANK
	FROM CT ct INNER JOIN CTCT ctct ON ct.So_ct = ctct.So_ct
	WHERE Loai_Ct = 0
	GROUP BY  Ma_Vt
) R
WHERE RANK < @_max1 + 1

IF OBJECT_ID('Tempdb..#temp') IS NOT NULL DROP TABLE #temp
SELECT ROW_NUMBER() OVER(ORDER BY ctct.So_Ct) AS STT, ct.Ngay_Ct, ctct.So_Ct, Ma_Vt, ct.Dien_Giai, ctct.So_Luong
INTO #temp
FROM CT ct INNER JOIN CTCT ctct ON ct.So_ct = ctct.So_ct

IF OBJECT_ID('Tempdb..#temp_copy') IS NOT NULL DROP TABLE #temp_copy
SELECT STT, Ngay_Ct, So_Ct, Ma_Vt, Dien_Giai, So_Luong
INTO #temp_copy
FROM #temp

UPDATE #temp_copy
SET Ma_Vt = 'Khac'
WHERE Ma_Vt NOT IN (SELECT Ma_Vt	
						FROM #Top2)

-- SET Lệnh PIVOT động
DECLARE @_name1 NVARCHAR(MAX) ='',
		@_cmd1 NVARCHAR(MAX)

SELECT @_name1 += ', ' + QUOTENAME(Ma_Vt)
FROM #Top2

SET @_name1 = STUFF(@_name1, 1, 2, '')

SET @_cmd1 =
'
SELECT B.Ngay_Ct, #temp.Ma_Vt, B.Dien_Giai, ' + @_name1 + ', [khac]
FROM #temp_copy
PIVOT
(
	SUM(So_Luong) FOR Ma_vt IN (' + @_name1 + ', [khac])
) B INNER JOIN #temp ON B.STT = #temp.STT AND B.So_Ct = #temp.So_Ct
'
EXEC(@_cmd1)