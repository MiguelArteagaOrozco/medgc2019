# Ej 1
select name 
from commerce.product

# Ej 2
select name 
from commerce.product
where commerce.product.price > 500

# Ej 3
select name 
from commerce.product
where commerce.product.price > 300 and commerce.product.price < 550

# Alternativa ej 3
where commerce.product.price between 300 and 550

# Ej 4
select name 
from commerce.product
where commerce.product.name like 'F%'

# Ej 5
select name 
from commerce.product
where commerce.product.name like '%e%'

# Ej 6
select name 
from commerce.product
where commerce.product.name like '_a%'

# Ej 7
select distinct c_product.code
from commerce.product as c_product, commerce.sale_item as c_sale_item
where c_product.code = c_sale_item.product_code
# Alternativa profe
select distinct si.product_code
from commerce.sale_item si

# Ej 8
select distinct c_sale.*
from commerce.product as c_product, commerce.sale_item as c_sale_item, commerce.sale as c_sale
where c_sale_item.product_code = 4 and c_sale.code = c_sale_item.sale_code
# Alternativa profe
select s.*
from commerce.sale s 
where exists (select 1
			  from commerce.sale_item si
			  where si.product_code = 4
			  		and si.sale_code = s.code)

# Ej 9
select c_sale.*
from commerce.sale as c_sale
where c_sale.delivery > 30

# Ej 10
select distinct c_customer.name
from commerce.sale as c_sale, commerce.customer as c_customer
where c_sale.discount > 0 and c_sale.customer_code = c_customer.code
# Alternativa profe
select c.name
from commerce.customer c 
where exists (select 1
			  from commerce.sale s 
			  where s.discount is not null 
			  	and s.discount > 0
			  	and s.customer_code = c.code)


# Ej 11
select cproduct.name from
commerce.product as cproduct, commerce.product_supplier as psupplier, commerce.supplier as csupplier
where cproduct.code = psupplier.product_code and psupplier.supplier_code = csupplier.code and csupplier.name = 'Bandera'

# Ej 12
select distinct cproduct.name
from commerce.product as cproduct, 
     commerce.customer as comcustomer, 
     commerce.sale as comsale, 
     commerce.sale_item as comsaleitem
where cproduct.code = comsaleitem.product_code and 
      comsale.code = comsaleitem.sale_code and 
      comcustomer.code = comsale.customer_code and 
      comcustomer.name = 'Arturo Illia'

# Ej 13
select distinct commerce.supplier.name, commerce.warehouse.name
from commerce.supplier
	join commerce.product_supplier
		on commerce.supplier.code = commerce.product_supplier.supplier_code
	join commerce.stock
		on commerce.product_supplier.product_code = commerce.stock.product_code		
	join commerce.warehouse
		on commerce.stock.warehouse_code = commerce.warehouse.code

# Ej 14
select c_product.name
from commerce.product as c_product
where c_product.price = (select max(commerce.product.price) from commerce.product)


# Disgression: sales whose summed prices are above 500
select distinct commerce.sale_item.sale_code
from commerce.sale_item,
    (select commerce.sale_item.sale_code as summed_sale_code, sum(commerce.sale_item.price) as summed_sale_price
     from commerce.sale_item 
     group by commerce.sale_item.sale_code) as summed_sale
where summed_sale.summed_sale_price > 500 and 
      commerce.sale_item.sale_code = summed_sale.summed_sale_code

# Ej 15 ESTA BUGUEADO por eso usa price en vez de cost
select distinct c_sale_item.sale_code
from commerce.sale_item as c_sale_item,
    (select commerce.sale_item.sale_code as summed_sale_code, 
            sum(commerce.sale_item.price * commerce.sale_item.quantity) as summed_sale_sum
     from commerce.sale_item
     group by commerce.sale_item.sale_code) as summed_sales
where c_sale_item.sale_code = summed_sales.summed_sale_code and summed_sales.summed_sale_sum > 500

# Alternativa Profe
select si.sale_code
from commerce.sale_item si
group by si.sale_code having sum(si.price * si.quantity) > 500


# Ej 16
select c_supplier.name 
from commerce.supplier as c_supplier
where c_supplier.city in (select city 
                          from commerce.warehouse)

# Ej 17
select distinct c_customer.name
from commerce.customer as c_customer,
    (select commerce.sale.customer_code as counted_code, count(commerce.sale.code) as sales_count
     from commerce.sale
     group by commerce.sale.customer_code) as counted_sales
where c_customer.code = counted_sales.counted_code and counted_sales.sales_count >= 2
# Alternativa profe
select c.name
from commerce.customer c
	 join commerce.sale s on s.customer_code = c.code
group by c.name having count(s.code) > 2


# Ej 18
select distinct c_store.name
from commerce.store as c_store
where c_store.city not in (select distinct commerce.warehouse.city
      from commerce.warehouse)
# Alternativa profe
select s.name
from commerce.store s 
where not exists (select 1
			      from commerce.warehouse w
			      where w.city = s.city)      

# Ej 19 (mal el enunciado, es por codigo y no por nombre)
select c_warehouse.code
from commerce.warehouse as c_warehouse,
     (select commerce.stock.warehouse_code as warehouse_code, 
             sum(commerce.stock.quantity) as stock_count
      from commerce.stock
      group by commerce.stock.warehouse_code
      ) as warehouses_with_stock_count
where c_warehouse.code = warehouses_with_stock_count.warehouse_code and
      warehouses_with_stock_count.stock_count > 40 and 
      c_warehouse.city = 'Buenos Aires'
# Alternativa profe
select w.code
from commerce.warehouse w
    join commerce.stock s on s.warehouse_code = w.code
where w.city = 'Buenos Aires'
group by w.code having sum(s.quantity) > 40         	

# Ej 20
select commerce.product.name, 
	   max(commerce.sale_item.price), 
	   min(commerce.sale_item.price), 
	   avg(commerce.sale_item.price)
from commerce.product, 
     commerce.sale_item
where commerce.product.code = commerce.sale_item.product_code
group by commerce.product.name

# Ej 21
select commerce.product.name, 
	   max(commerce.sale_item.price) - min(commerce.sale_item.price)
from commerce.product, 
     commerce.sale_item
where commerce.product.code = commerce.sale_item.product_code
group by commerce.product.name

# Ej 22
select c.name, sum(t.total + s.delivery - s.discount)
from commerce.customer c
	 join commerce.sale s on c.code = s.customer_code
	 join (select si.sale_code, sum(si.quantity * si.price) as total
	 	   from commerce.sale_item si 
	 	   group by si.sale_code) t on s.code = t.sale_code
group by c.name

# Ej 23
select commerce.product.name, 
       sum(commerce.stock.quantity)
from commerce.product,
     commerce.stock
where commerce.product.code = commerce.stock.product_code
group by commerce.product.name

# Ej 24
select w.name
from commerce.warehouse w
where not exists (select 1
                  from commerce.product p
                  where not exists (select 1
                                    from commerce.stock st
                                    where st.product_code = p.code and
                                          st.warehouse_code = w.code))

# Ej 25
select commerce.supplier.name, count(products_list.product_code)
from commerce.supplier, 
     (select commerce.supplier.name as supplier_name,
             commerce.product.code as product_code
      from commerce.supplier,
           commerce.product,
           commerce.product_supplier
      where commerce.supplier.code = commerce.product_supplier.supplier_code and
            commerce.product.code = commerce.product_supplier.product_code) products_list
where commerce.supplier.name = products_list.supplier_name
group by commerce.supplier.name

# Ej 26
select c.name, avg(t.total + s.delivery - s.discount)
from commerce.customer c
	 join commerce.sale s on c.code = s.customer_code
	 join (select si.sale_code, sum(si.quantity * si.price) as total
	 	   from commerce.sale_item si 
	 	   group by si.sale_code) t on s.code = t.sale_code
group by c.name

# Ej 27
select c_product.name
from commerce.product as c_product
where c_product.code not in (select distinct commerce.sale_item.product_code
                             from commerce.sale_item)

# Ej 28
select distinct c_customer.name, counted_sales.product_count
from commerce.customer as c_customer,
    (select commerce.sale.customer_code as counted_code, count(distinct commerce.sale_item.product_code) as product_count
     from commerce.sale,
          commerce.sale_item
     where commerce.sale.code = commerce.sale_item.sale_code
     group by commerce.sale.customer_code) as counted_sales
where c_customer.code = counted_sales.counted_code and counted_sales.product_count > 2

# Ej 29
select c_customer.name
from commerce.customer as c_customer
     join commerce.sale s on c_customer.code = s.customer_code
group by c_customer.code
having count(distinct s.store_code) = 1

# Ej 30
select c_customer.name
from commerce.customer as c_customer
     join commerce.sale s on c_customer.code = s.customer_code
group by c_customer.code
having count(distinct s.store_code) = (select count(distinct commerce.sale.store_code) from commerce.sale)

# Ej 31
select distinct c_supplier.name
from commerce.supplier as c_supplier
    join commerce.product_supplier psupplier on psupplier.supplier_code = c_supplier.code
    join commerce.stock c_stock on c_stock.product_code = psupplier.product_code
    join commerce.warehouse c_warehouse on c_stock.warehouse_code = c_warehouse.code and c_warehouse.city = c_supplier.city

# Ej 32
select c_store.name, sum(t.total + s.delivery - s.discount)
from commerce.store c_store
	 join commerce.sale s on c_store.code = s.store_code
	 join (select si.sale_code, sum(si.quantity * si.price) as total
	 	   from commerce.sale_item si 
	 	   group by si.sale_code) t on s.code = t.sale_code
group by c_store.name

# Ej 33
select distinct c_store.name, c_count.customer_count
from commerce.store c_store
	 join commerce.sale s on c_store.code = s.store_code,
	 (select count(distinct commerce.sale.customer_code) as customer_count, 
	              commerce.sale.store_code as c_store_code
	              from commerce.sale
	              group by commerce.sale.store_code) as c_count
where c_store.code = c_count.c_store_code

# Ej 34
select c_store.name, counted_products.product_count
from commerce.store as c_store,
    (select count(distinct c_sale_item.product_code) as product_count, c_sale.store_code as store_code
     from commerce.sale_item c_sale_item 
     join commerce.sale c_sale on c_sale_item.sale_code = c_sale.code
     group by c_sale.store_code) as counted_products
where c_store.code = counted_products.store_code

# Ej 35
select c_product.name
from commerce.product as c_product
    join commerce.stock c_stock on c_product.code = c_stock.product_code
    join commerce.warehouse c_warehouse on c_warehouse.code = c_stock.warehouse_code
where c_warehouse.name = 'Baires I'
