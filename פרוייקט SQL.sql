
--ותק העובדים בחברה (Seniority)
select FirstName,LastName, DATEDIFF(year,HireDate,GETDATE()) as seniority 
from NorthWind.dbo.Employees


-- בכמה הזמנות טיפל כל עובד בשנת 2020 (הביצועים של סטיבן בוצאנן לא נראים טוב ( 
select Orders.EmployeeID,Employees.firstname+' '+Employees.lastname as fullName,COUNT(OrderID) as orderPerEmployee
from NorthWind.dbo.Employees join 
		NorthWind.dbo.Orders on Employees.EmployeeID = Orders.EmployeeID
where year(OrderDate) = 2020
GROUP BY Orders.EmployeeID, Employees.firstname, Employees.lastname
order by orderPerEmployee desc

--מספר ההזמנות הכולל עבור כל שנה 
--מגמת שיפור נראתה בכמות ההזמנות בשנת 2019 וירידה ב2020 כנראה בגלל שיש נתונים חלקיים לשנה זו
select year(orderdate) as year,count(OrderID) as totalOrder
from NorthWind.dbo.Orders
group by year(OrderDate)
order by year(OrderDate)

-- (סך כל ההזמנות בשנה לפי מדינות (גרמניה וארצות הברית הן הקונות העיקריות שלנו
select year(orderdate) as year,Country,count(OrderID) as totalOrder
from NorthWind.dbo.Orders join 
	NorthWind.dbo.Customers on Orders.CustomerID = Customers.CustomerID
group by year(OrderDate),Country
order by year(OrderDate),totalOrder desc

--סך כל הרווחים שכל מוצר עשה לשנת 2020 
select ProductName,sum((OrderDetails.UnitPrice*OrderDetails.Quantity)*(1-OrderDetails.Discount)) as TotalSale
from NorthWind.dbo.Orders join 
	NorthWind.dbo.OrderDetails on orders.OrderID = OrderDetails.OrderID join 
		NorthWind.dbo.Products on OrderDetails.ProductID = Products.ProductID
where year(OrderDate) = 2020
group by ProductName
order by TotalSale desc 

--(המוצרים שנרכשו גם בשנת 2018 גם 2019 וגם 2020 (מוצרים פופולארים 
select ProductName,Products.ProductID
from NorthWind.dbo.Products join 
	NorthWind.dbo.OrderDetails on OrderDetails.ProductID = Products.ProductID
	join NorthWind.dbo.Orders on Orders.OrderID = OrderDetails.OrderID
where year(OrderDate) = 2018

intersect 

select ProductName,Products.ProductID
from NorthWind.dbo.Products join 
	NorthWind.dbo.OrderDetails on OrderDetails.ProductID = Products.ProductID
	join NorthWind.dbo.Orders on Orders.OrderID = OrderDetails.OrderID
where year(OrderDate) = 2019

intersect

select ProductName,Products.ProductID
from NorthWind.dbo.Products join 
	NorthWind.dbo.OrderDetails on OrderDetails.ProductID = Products.ProductID
	join NorthWind.dbo.Orders on Orders.OrderID = OrderDetails.OrderID
where year(OrderDate) = 2020

--לקוחות שעשו יותר הזמנות מלקוח 'ALFKI' בשנת 2020
select CompanyName, count(o.OrderID) numOfOrders
from NorthWind.dbo.Customers c join NorthWind.dbo.Orders o on  c.CustomerID = o.CustomerID
where year(o.OrderDate) = 2020 
group by CompanyName 
having count(o.OrderID) > (
							select count(o.OrderID)
							from NorthWind.dbo.Orders o join NorthWind.dbo.Customers c
									on o.CustomerID = c.CustomerID
							where year(OrderDate) = 2020 and c.CustomerID = 'ALFKI'
						)
-- מספר ההזמנות שעשה ALFKI בשנת 2020
select count(o.OrderID)
from NorthWind.dbo.Orders o join NorthWind.dbo.Customers c
		on c.CustomerID = o.CustomerID
where o.CustomerID = 'ALFKI' and year(OrderDate) = 2020

-- הזמנות שבוצעו ב2020 שהסכום ששולם עבורם גדול מהסכום של ההזמנה המקסימאלית בשנת 2019
select o.OrderID
from NorthWind.dbo.Orders o join NorthWind.dbo.OrderDetails ord 
		on o.OrderID = ord.OrderID
where year(OrderDate) = 2020 and
		UnitPrice*Quantity*(1-ord.Discount) > (
												select max(UnitPrice*Quantity*(1-Discount)) 
												from NorthWind.dbo.OrderDetails join 
														NorthWind.dbo.Orders on orders.OrderID = OrderDetails.OrderID
												where year(OrderDate) = 2019
												)

--בדיקה אם התוצאה שקיבלנו אכן נכונה
select UnitPrice*Quantity*(1-ord.Discount) test
from  NorthWind.dbo.Orders o join NorthWind.dbo.OrderDetails ord 
		on o.OrderID = ord.OrderID

--סיווג העובדים לפי כמות ההזמנות שביצעו במהלך שנת 2020
select FirstName + ' ' +LastName as fullName,count(o.OrderID) numOfOrders,
			case
				when (count(o.OrderID) < 30) then 'below average'
				when (count(o.OrderID) between 30 and 40) then 'average'
				else  'above average'
			end as rankOfEmployee
from NorthWind.dbo.Employees e join NorthWind.dbo.Orders o
		on e.EmployeeID = o.EmployeeID
where year(o.OrderDate) = 2020
group by FirstName, LastName
order by numOfOrders