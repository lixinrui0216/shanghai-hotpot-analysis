-- 1.打开数据表
SELECT * FROM hotpot_analysis.huoguo;

-- 2.建立新表并插入清洗后的数据，同时加入新的星级数字列
create table huoguo1 as
select 
    name, 
    url, 
    star, 
    comment,
    case when avg_price = 1 then 111 else avg_price end as avg_price,
    taste, 
    environment, 
    services, 
    recommend,
    case 
        when star = '五星商户' then 5.0
        when star = '准五星商户' then 4.5
        when star = '四星商户' then 4.0
        when star = '准四星商户' then 3.5
        else null
    end as star_num
from huoguo
where name is not null 
  and star is not null 
  and comment is not null 
  and avg_price is not null;
  
-- 3. 查看数据是否完整
select * from hotpot_analysis.huoguo1 limit 10;

-- 4. 价格最贵的5家店
select name, avg_price 
from huoguo1 
order by avg_price desc 
limit 5;

-- 5. 评论最多的5家店
select name, comment 
from huoguo1 
order by comment desc 
limit 5;

-- 6. 各星级餐厅数量分布
select star, count(*) as count 
from huoguo1
group by star 
order by count desc;

-- 7. 口味最佳10家
select name, star, avg_price, taste, environment, services
from huoguo1
where taste >= 9.0
order by taste desc, avg_price asc
limit 10;

-- 8. 选择条件进行推荐
select 
    name, 
    star, 
    avg_price, 
    taste, 
    environment, 
    services, 
    comment,
    round((taste + environment + services) / 3, 2) as 综合评分
from huoguo1
where star_num >= 4.5
  and avg_price between 50 and 300
  and taste >= 8.5
  and environment >= 8.5
  and services >= 8.5
  and recommend like '%胡椒%'
order by 综合评分 desc, comment desc;

-- 9. 总店数，人均消费，最低价，最高价，平均评论数，口味评分，环境均分，服务均分 
select 
    count(*) as 总店数,
    round(avg(avg_price), 0) as 人均消费,
    min(avg_price) as 最低价,
    max(avg_price) as 最高价,
    round(avg(comment), 0) as 平均评论数,
    round(avg(taste), 2) as 口味均分,
    round(avg(environment), 2) as 环境均分,
    round(avg(services), 2) as 服务均分
from huoguo1;

-- 10. 价格区间分布
select 
    case 
        when avg_price < 50 then '0-50'
        when avg_price < 100 then '50-100'
        when avg_price < 200 then '100-200'
        when avg_price < 300 then '200-300'
        when avg_price < 500 then '300-500'
        else '500+'
    end as 价格区间,
    count(*) as 店铺数量
from huoguo1
group by 价格区间
order by min(avg_price) asc;