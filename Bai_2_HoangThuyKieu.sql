--Bài 2: Hiển thị danh sách những Vât tư theo chuỗi trèn vào, (vidu sắt, đồng) 
DECLARE @_Code NVARCHAR(100),
		@_rep NVARCHAR(100),
		@_Lenh NVARCHAR(100)
SET @_Code = N'VT001,Thép,Đồng'
SET @_rep = REPLACE(@_Code,',','%''OR Ten_VT LIKE N''%')
SET @_Code = 'SELECT * 
				FROM DMVT'
IF @_Code <> ''
	SET @_rep = @_rep +'
				WHERE Ten_Vt LIKE N'''+ '%' + @_rep + '%'+''''
EXEC(@_Lenh)
PRINT(@_Lenh)
--Bài 1: Xóa tất cả các khoảng trống
--Loại bỏ khoảng trắng bên trái và bên phải chuỗi
DECLARE @_Hoten NVARCHAR(100)			 
SET @_Hoten = N' Hoàng      Thúy  Kiều  '
SET @_Hoten = LTRIM(RTRIM(@_Hoten))
PRINT @_Hoten
DECLARE @_kc1 NVARCHAR(100),
		@_kc2 NVARCHAR(100),
		@_kc3 NVARCHAR(100)
--thay kc bằng *#*
SET @_kc1 = REPLACE(@_Hoten,' ', '*#*')
--thay #** bằng không có gì
SET @_kc2 = REPLACE(@_kc1, '#**','')
--Thay *#* bằng kt
SET @_kc3 = REPLACE(@_kc2,'*#*',' ')
--SET @_kc3 = REPLACE(@_kc2,'*#*,'')
PRINT @_kc3

--Bài 3: Hiển thị kí tự hoa của họ, ten đêm, tên (tên gồm 3 từ)
DECLARE @_Ten_DD NVARCHAR(100),
		@_KT1 INT,
		@_KT2 INT,
		--@_kc1 NVARCHAR(100),
		--@_kc2 NVARCHAR(100),
		@_kc3 NVARCHAR(100)
SET @_Ten_DD = N'NiNh     NgỌc HiếU'

--xóa khoảng cách
SET @_kc3 = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(@_Ten_DD,' ','*#*'),'#**',''),'*#*',' ')))
--SET @_Ten_DD = LTRIM(RTRIM(@_Ten_DD))
--SET @_kc1 = REPLACE(@_Ten_DD,' ', '*#*')
--SET @_kc2 = REPLACE(@_kc1, '#**','')
--SET @_kc3 = REPLACE(@_kc2,'*#*',' ')
PRINT @_kc3
--chuyển thành chữ thường
SET @_KT1 = CHARINDEX(' ', @_kc3)
SET @_KT2 = CHARINDEX(' ',REVERSE(@_kc3))
SET @_kc3 = LOWER(@_kc3)

--viết hoa chữ caasi đầu tiên của họ
SET @_kc3 = STUFF(@_kc3,1,1,UPPER(LEFT(@_kc3,1)))
print @_kc3
--Viết hoa chữ cái đầu tiên của đệm
SET @_kc3 = STUFF(@_kc3,@_KT1 +1, 1, UPPER(SUBSTRING(@_kc3, @_KT1+1,1)))

--VIẾT HOA CHỮ CÁI ĐẦU TIÊN CỦA TÊN
SET @_kc3 = STUFF(REVERSE(@_KC3),@_kt2-1, 1, UPPER(SUBSTRING(REVERSE(@_KC3),@_KT2 -1, 1)))
PRINT REVERSE(@_KC3)

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

