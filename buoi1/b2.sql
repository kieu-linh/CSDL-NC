select r.region_name, e.first_name, e.last_name
from employees as e
join departments as d on e.department_id = d.department_id
join locations as l on l.location_id = d.location_id
join countries as c on c.country_name = l.country_id
join regions as r on r.region_id = c.region_id
group by r.region_name
having region_name like N'Asia'

select * from 
DELIMITER $$
CREATE TRIGGER `Insert_Job`
before insert on jobs
FOR each row
BEGIN
	if (NEW.min_salary <= 0 OR max_salary <= 0 ) THEN
		set MESSAGE_TEXT = 'The min_salary or max_salary value is ';
	end if;
end; $$


-- GỌI TRIGGER TRÊN BẢNG CHITIETDONHANG
INSERT INTO tb_CHITIETDONHANG(MaDH,MaSP,SoLuong,TongTien)
VALUES('DH001','SP002',10,1000000)