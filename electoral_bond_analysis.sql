--Answering Queries on electoralbonds.
--1. Find out how much donors spent on bonds.
select sum(a.Denominations) as totalamountbought
from bonddata as a
join donordata as b
on a.unique_key = b.unique_key;

--2. Find out total funds politicians got.
select sum(a.Denominations) as totalamountreceived
from bonddata as a
join receiverdata as b
on a.unique_key = b.unique_key;

--3. Find out the total amount of unaccounted money received by parties (bonds without donors).
select sum(Denominations) as unaccountedmoney
from donordata as d
right join receiverdata as r
on r.unique_key = d.unique_key
join bonddata as b 
on r.unique_key = b.unique_key
where purchaser is null;

--4. Find year-wise how much money is spent on bonds.
select extract(year from d.PurchaseDate) as year,sum(b.denominations) as yearwise_bondspend
from donordata as d
join bonddata as b
on b.unique_key=d.unique_key
group by year
order by yearwise_bondspend desc;

--5. In which month was the most amount spent on bonds?
select extract(month from d.PurchaseDate) as month, sum(b.denominations) as bondvalue
from donordata as d 
join bonddata as b
on b.unique_key = d.unique_key
group by month
order by bondvalue desc limit 1;

--6. Find out which company bought the highest number of bonds.
select purchaser,count(b.unique_key) as companybondcount
from donordata as d
join bonddata as b
on d.unique_key=b.unique_key
group by purchaser
order by count(b.unique_key) desc limit 1;

--7. Find out which company spent the most on electoral bonds.
select purchaser,sum(b.denominations) as companyspent
from donordata as d
join bonddata as b
on d.unique_key=b.unique_key
group by purchaser
order by sum(b.denominations) desc limit 1; 

--8. List companies which paid the least to political parties.
select purchaser, sum(denominations) as companyspending
from donordata as d
join bonddata as b
on d.unique_key=b.unique_key
group by purchaser
having sum(denominations)=(
select min(moneyspent) from (
select purchaser,sum(denominations) as moneyspent from donordata as d
join bonddata as b
on d.unique_key=b.unique_key
group by purchaser) as subquery);

--9. Which political party received the highest cash?
select partyname,sum(denominations) as fundreceiver 
from receiverdata as r
join bonddata as b
on r.unique_key=b.unique_key
group by partyname 
order by sum(denominations) desc;

--10. Which political party received the highest number of electoral bonds?
select partyname,count(b.unique_key) as bondcount 
from receiverdata as r
join bonddata as b
on r.unique_key=b.unique_key
group by partyname 
order by count(b.unique_key) desc;

--11. Which political party received the least cash?
--using cte

with spendingcounts as(
select partyname,sum(denominations) as encashment
from receiverdata as r
join bonddata as b
on r.unique_key = b.unique_key
group by partyname 
order by sum(denominations))
select partyname,encashment as fundreceived
from spendingcounts where encashment =(select min(encashment) from spendingcounts);

--12. Which political party received the least number of electoral bonds?
with spendingcounts as(
select partyname,count(denominations) as encashmentcount
from receiverdata as r
join bonddata as b
on r.unique_key = b.unique_key
group by partyname 
order by count(denominations))
select partyname,encashmentcount as companyspend
from spendingcounts where encashmentcount =(select min(encashmentcount) from spendingcounts);


--13. Find the 2nd highest donor in terms of the amount paid.

with main as(
select purchaser,sum(denominations) as total
from donordata as d
join bonddata as b
on d.unique_key=b.unique_key
group by 1
order by 2),
sub_cte as (select *,dense_rank()over(order by total desc) as ranks
from main)
select purchaser,total from sub_cte where ranks=2;

--14. Find the party which received the second-highest donations.
select partyname, sum(denominations) as donations 
from receiverdata as r
join bonddata as b
on r.unique_key = b.unique_key
group  by 1
order by 2 desc limit 1 offset 1;

--15. Find the party which received the second-highest number of bonds.
select partyname, count(b.unique_key) as donationcount
from receiverdata as r
join bonddata as b
on r.unique_key = b.unique_key
group  by 1
order by 2 desc limit 1 offset 1;

--16. In which city were the most number of bonds purchased?

with city_bond_count as (
select b.city,count(c.denominations) as citybondspending
from donordata as d
join bankdata as b
on d.paybranchcode=b.branchcodeno
join bonddata as c 
on c.unique_key=d.unique_key
group by b.city)
select * from city_bond_count where citybondspending =
(select max(citybondspending) from city_bond_count);

--17. In which city was the highest amount spent on electoral bonds?

with city_bond_total as (
select b.city,sum(c.denominations) as citybondspending
from donordata as d
join bankdata as b
on d.paybranchcode=b.branchcodeno
join bonddata as c 
on c.unique_key=d.unique_key
group by b.city)
select * from city_bond_total where citybondspending =
(select max(citybondspending) from city_bond_total);


--18. In which city were the least number of bonds purchased?

with city_bond_count as (
select b.city,count(c.denominations) as citybondspending
from donordata as d
join bankdata as b
on d.paybranchcode=b.branchcodeno
join bonddata as c 
on c.unique_key=d.unique_key
group by b.city)
select * from city_bond_count where citybondspending =
(select min(citybondspending) from city_bond_count);

--19.In which city were the most number of bonds encashed?

with city_bond_amt as (
select b.city,count(r.unique_key) as citybondencashment
from receiverdata as r 
join bankdata as b
on r.paybranchcode=b.branchcodeno
join bonddata as c
on c.unique_key = r.unique_key
group by b.city)
select * from city_bond_amt  where citybondencashment =
(select max(citybondencashment) from city_bond_amt);

--20. In which city were the least number of bonds encashed?

with city_bond_amt as (
select b.city,count(r.unique_key) as citybondencashment
from receiverdata as r 
join bankdata as b
on r.paybranchcode=b.branchcodeno
join bonddata as c
on c.unique_key = r.unique_key
group by b.city)
select * from city_bond_amt  where citybondencashment =
(select min(citybondencashment) from city_bond_amt);
