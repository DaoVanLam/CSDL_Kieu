--BTVN1: Hiện thị các chứng từ phiếu xuất có phát sinh từ ngày hiện tại đến 60 ngày trở về trước gồm : So_Ct, Ngay_Ct, Loai_Ct
SELECT So_Ct, Ngay_Ct,
	(CASE Loai_Ct
	WHEN 0 THEN N'Bán'
	END) as Loai_CT
FROM CT
WHERE DATEDIFF(DD,Ngay_Ct,GETDATE())>60 AND Loai_Ct = 0

----BTVN2: Hiển thị ngày đầu quý và ngày cuối quý của tháng hiện tại
--Ngày đầu quý
DECLARE @DQ DATETIME
SET @DQ = DATEADD(MM,-1,DATEADD(DD,-DAY(GETDATE())+1,GETDATE()))
PRINT @DQ
--CHỮA
DECLARE @_QHT DATETIME,
		@NGAYDT DATETIME,
		@HT DATETIME
SET @HT= GETDATE()
SET @NGAYDT = DATEADD(DD,-DAY(GETDATE()+1),GETDATE())
SET @_QHT = DATEPART(QQ,GETDATE())
DECLARE @_DQ DATETIME
SET @_DQ = DATEADD(MM, - (MONTH(@HT) - ((@_QHT -1)*3+1)), @NGAYDT)
--TỐI ƯU
SELECT DATEADD(QQ,DATEDIFF(QQ, 0,GETDATE()),0) AS NGAYDAUQUY
SELECT DATEADD(QQ,DATEDIFF(QQ, 0, GETDATE())+1,-1) AS NGAYCUOIQUY

--SELECT DATEADD(MM,-1,DATEADD(DD,-DAY(GETDATE())+1,GETDATE()))
--Ngày cuối quý
DECLARE @CQ DATETIME
SET @CQ = DATEADD(DD, -1, DATEADD(MM,2,DATEADD(DD, -DAY(GETDATE()) + 1 ,GETDATE())))
PRINT @CQ

----BTVN3: Hiển thị các Ma_Dt xuất hiện trong phiếu suất có chuỗi sau:
--> Đối tượng các phiếu xuất gồm có : DT01, DT02, DT03, DT04
DECLARE @MIN SMALLDATETIME,
		@MAX SMALLDATETIME,
		@MADT NVARCHAR(50),
		@SOCT NVARCHAR(50),
		@NGAYCT DATETIME
SET @MADT=''
SET @MAX = (SELECT MAX(Ngay_Ct) 
			FROM CT WHERE Loai_Ct =1)
SET @MIN = (SELECT MIN(Ngay_Ct) 
			FROM CT WHERE Loai_Ct=1)
WHILE (@MIN<=@MAX) 
BEGIN 
--chọn ra bản ghi đầu tiên	
		SELECT TOP 1
		@MADT = Ma_Dt,
		@SOCT = So_Ct,
		@NGAYCT = Ngay_Ct
		FROM CT
	
		SET @MAX= @MAX -1
		SET @MADT = (SELECT Ma_Dt FROM CT WHERE Loai_Ct = 1 AND Ngay_Ct = @MAX)
		IF @MADT <>''
		SET @b = @b + @MADT + ','
END;
IF @b <>''
SET @b = LEFT(@b,LEN(@b)-1)
PRINT N'Đối tượng các phiếu xuất gồm có:' + (@b)

--
