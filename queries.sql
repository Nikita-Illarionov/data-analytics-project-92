SELECT count(customer_id) as customers_count FROM customers; -- вывести количество строк из таблицы customers, т.е. с учетом контекста - количество покупателей


/*Берем таблицу с продавцами, джойним с таблицей продаж и таблицу продаж с таблицей продуктов */
select e.first_name || ' ' || e.last_name as seller, count(s.sales_id) as operations, sum(s.quantity * p.price) as income from employees e join sales s on e.employee_id = s.sales_person_id 
						join products p on s.product_id = p.product_id group by e.first_name || ' ' || e.last_name order by sum(s.quantity * p.price) desc limit 10;
					
					
					
/*В подзапросе для всех строк выводим средний показатель с помощью аналитической функции, чтобы в итоговом запросе можно было сделать фильтр*/
with cte as (
select e.first_name || ' ' || e.last_name as seller, p.price, s.quantity, avg(p.price*s.quantity) over () as avg_revenue
	from employees e join sales s on e.employee_id = s.sales_person_id 
						join products p on s.product_id = p.product_id 
)
select seller, floor(avg(price * quantity)) as average_income from cte group by seller, avg_revenue having avg(price * quantity) < avg_revenue order by average_income;


/* здесь просто функции агрегации и группировка, сортировка */
select e.first_name || ' ' || e.last_name as seller, to_char(s.sale_date, 'Day') as day_of_week, floor(sum(s.quantity * p.price)) as income from employees e join sales s on e.employee_id = s.sales_person_id 
						join products p on s.product_id = p.product_id group by e.first_name || ' ' || e.last_name, to_char(s.sale_date, 'Day'), EXTRACT(ISODOW FROM sale_date) order by EXTRACT(ISODOW FROM sale_date), seller; 

					