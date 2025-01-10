SELECT count(customer_id) as customers_count FROM customers; -- вывести количество строк из таблицы customers, т.е. с учетом контекста - количество покупателей



----------------Анализ отдела продаж---------------

-- ОТЧЕТ 1
/*Берем таблицу с продавцами, джойним с таблицей продаж и таблицу продаж с таблицей продуктов */
select e.first_name || ' ' || e.last_name as seller, count(s.sales_id) as operations, sum(s.quantity * p.price) as income from employees e join sales s on e.employee_id = s.sales_person_id 
						join products p on s.product_id = p.product_id group by e.first_name || ' ' || e.last_name order by sum(s.quantity * p.price) desc limit 10;
					
					
-- ОТЧЕТ 2			
/*В подзапросе для всех строк выводим средний показатель с помощью аналитической функции, чтобы в итоговом запросе можно было сделать фильтр*/
with cte as (
select e.first_name || ' ' || e.last_name as seller, p.price, s.quantity, avg(p.price*s.quantity) over () as avg_revenue
	from employees e join sales s on e.employee_id = s.sales_person_id 
						join products p on s.product_id = p.product_id 
)
select seller, floor(avg(price * quantity)) as average_income from cte group by seller, avg_revenue having avg(price * quantity) < avg_revenue order by average_income;


-- ОТЧЕТ 3
/* здесь просто функции агрегации и группировка, сортировка */
select e.first_name || ' ' || e.last_name as seller, to_char(s.sale_date, 'Day') as day_of_week, floor(sum(s.quantity * p.price)) as income from employees e join sales s on e.employee_id = s.sales_person_id 
						join products p on s.product_id = p.product_id group by e.first_name || ' ' || e.last_name, to_char(s.sale_date, 'Day'), EXTRACT(ISODOW FROM sale_date) order by EXTRACT(ISODOW FROM sale_date), seller; 


					
----------------Анализ покупателей--------------------
					
-- ОТЧЕТ 1
select '16-25' as age_category, count(1) as count from customers where age between 16 and 25
union 
select '26-40', count(1) from customers where age between 26 and 40
union 
select '40+', count(1) from customers where age > 40 order by age_category;


-- ОТЧЕТ 2
select to_char(sale_date, 'yyyy-dd'), count(distinct customer_id), sum(p.price * s.quantity) as income 
from sales s join products p on s.product_id = p.product_id group by to_char(sale_date, 'yyyy-dd');


-- ОТЧЕТ 3
-- в подзапросе добавляем нумерацию для каждого покупателя с сортировкой по дате
-- затем в итоговом запросе добавляем условие одновременно на первую покупку и то, что товар стоил 0.
with cte as (
select c.first_name || ' ' || c.last_name as customer, e.first_name || ' ' || e.last_name as seller, p.price, 
		row_number() over (partition by s.customer_id order by s.sale_date) as rn, s.* 
		from sales s join products p on s.product_id = p.product_id 
						join customers c on c.customer_id = s.customer_id 
						join employees e on e.employee_id  = s.sales_person_id )
	select customer, sale_date, seller from cte where rn = 1 and price = 0 order by customer_id;
					
					


