-- tạo 1 trigger khi insert vào bảng employees nếu salary nhập vào 
-- không nằm trong khoảng min max của bảng jobs thì thông báo lỗi
delimiter $$
create trigger check_salary
before insert on employees
for each row
begin
	declare min_salary int;
    declare max_salary int;
    set min_salary = (select max from jobs where job_id = new.job_id);
    set max_salary = (select min from jobs where job_id = new.job_id);
    if new.salary < min_salary or new.salary > max_salary then signal sqlstate '45000'
    set message_text = 'Salary not in range';
    end if;
end; $$

-- tạo 1 trigger khi insert vào bảng employees thì tự động insert vào bảng dependents với employee_id là id của employee vừa insert
-- và first_name, last_name, relationship là tự nhập vào
delimiter $$
create trigger insert_dependents
after insert on employees
for each row
begin
   insert into dependents(employee_id, first_name, last_name, relationship) 
   values (new.employee_id, '', '', '');
end; $$

-- tạo 1 sự kiện sau 1 tháng thì xóa các nhân viên trong bảng employees có salary nhỏ nhất ở khu vực asia
create event if not exists delete_employee_asia
on schedule every 1 month
starts current_timestamp
ends current_timestamp + interval 1 month
do
	 DELETE FROM employees WHERE employee_id IN (
		SELECT employee_id FROM employees WHERE region_id = '2' ORDER BY salary ASC LIMIT 1
	);
-- tạo 1 sự kiện sau mỗi năm thưởng 9000000 cho nhân viên có lương cao nhất với công việc là Maketing Manager
create event if not exists bonus_employee
on schedule every 1 year
starts current_timestamp
ends current_timestamp + interval 1 year
do
	 UPDATE employees SET salary = salary + 9000000 WHERE employee_id IN (
		SELECT employee_id FROM employees WHERE job_id = '10' ORDER BY salary DESC LIMIT 1
	);

