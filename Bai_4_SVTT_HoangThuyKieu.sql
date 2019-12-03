SELECT * 
FROM CT
WHERE Ma_Dt IN('KH001','KH002')

SELECT * 
FROM CT
WHERE Ma_Dt IN (SELECT Ma_Dt FROM CT WHERE Ma_Dt LIKE N'%KH001')

--Hiển thị dữ liệu phiếu xuất có đối tượng là công ty:  soct, ngayct, madt
SELECT So_Ct, Ngay_Ct, Ma_Dt
FROM CT
WHERE Loai_Ct = 0 AND Ma_Dt IN (SELECT Ma_Dt FROM DMDT WHERE Loai_Dt = 2 )


/*BTVN1: Hiển thị danh sách vật tư là sản phẩm được bán cho đối tượng khách lẻ trong tháng hiện tại: Ma_vt, So_Luong, Don_Gia, Thanh_Tiền
Không dùng kết nối JOIN, dùng hàm IN*/
SELECT So_Ct, Ma_Vt, So_luong, Don_Gia, Tien
FROM CTCT
WHERE  Ma_Vt IN(SELECT Ma_Vt 
				FROM DMVT 
				WHERE Loai_Vt =2)
		AND So_Ct IN(SELECT So_Ct 
				FROM CT 
				WHERE Ma_Dt IN(SELECT Ma_Dt 
								FROM DMDT 
								WHERE Loai_Dt=1 
								AND MONTH(DMDT.Ngay_Bd) = MONTH(GETDATE())))


--BTVN2: Hiển thị ds phiếu nhập có phát sinh trong năm 2019 và có đối tượng bắt đâu giao dịch khoảng 1 năm so với thời điểm hiện tại
SELECT Ma_Dt FROM DMDT WHERE Ma_Dt IN(SELECT Ma_Dt FROM CT
									 WHERE Loai_Ct= 1 
									 AND Ngay_Bd BETWEEN (DATEADD(YY,-1,DATEADD(DD, -DAY(GETDATE())+1, GETDATE()))) AND GETDATE())

