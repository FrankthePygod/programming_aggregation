-----naming mapping

select sld_menu_itm_id,
sld_menu_itm_na,
case when sld_menu_itm_na ilike 'glazed %4%' then 'glazed 4 pc'
when sld_menu_itm_na ilike 'glazed %6%' then 'glazed 6 pc'
when sld_menu_itm_na ilike 'glazed %10%' then 'glazed 10 pc'
when sld_menu_itm_na ilike '2 %' then '2 pc bct'
when sld_menu_itm_na ilike '4%' then '4 pc bct'
when sld_menu_itm_na ilike '6%' then '6 pc bct'
when sld_menu_itm_na ilike '10%' then '10 pc bct'
else 'other size' end as size,
case when sld_menu_itm_na ilike '%tender' or sld_menu_itm_na ilike '%tender-%' then'BCT'
when sld_menu_itm_na ilike '%glazed%' then 'GCT' else 'other' end as campaign_name
into gct_name_mapping
from public.sld_menu_itm
where sld_menu_itm_na ilike '%tender'
or sld_menu_itm_na ilike '%tender-%'
or  sld_menu_itm_na ilike '%glazed%'
order by 3;

delete from gct_name_mapping
where size = 'other size';

-------Q1
select pos_ord_dt,
campaign_name,
size,
sum(tot_sld_qt) as 'Quantity',
count(distinct mcd_gbal_lcat_id_nu||pos_busn_dt||pos_ord_key_id) as "guest count"
from pos_trn_lvl_hdr
left join pos_trn_lvl_dtl
using (mcd_gbal_lcat_id_nu,pos_ord_key_id,pos_busn_dt)
where pos_ord_dt between '2018-03-05' and '2018-03-25'
or pos_ord_dt between '2018-08-27' and '2018-09-30'
and b.pos_evnt_typ_id = 1;

--------Q1 - GMA/MOP only customers

set wlm_query_slot_count to 5;
drop table if exists pca_gct_q1a;
select pos_ord_dt,
campaign_name,
size,
sum(tot_sld_qt) as "Quantity",
count(distinct mcd_gbal_lcat_id_nu||pos_busn_dt||pos_ord_key_id) as "guest count"
into pca_gct_q1a
from pos_trn_lvl_hdr b
left join pos_trn_lvl_dtl
using (mcd_gbal_lcat_id_nu,pos_ord_key_id,pos_busn_dt)
join gct_name_mapping
using (sld_menu_itm_id)
where (pos_ord_dt between '2018-03-05' and '2018-03-25'
or pos_ord_dt between '2018-08-27' and '2018-09-30')
and b.pos_evnt_typ_id = 1
and srce_indv_id is not null
group by 1,2,3;
select *
from pca_gct_q1
where ((campaign_name = 'GCT' and pos_ord_dt >= '2018-08-27')
or (campaign_name = 'BCT')) and size is not null
order by pos_ord_dt, size;


select *
from pca_gct_q1a
where ((campaign_name = 'GCT' and pos_ord_dt >= '2018-08-27')
or (campaign_name = 'BCT')) and size is not null
order by pos_ord_dt, size;




--------investigation on why the sales are the same during 2018-03-05 to 2018-03-25



select count(*) as 'Total rows',
count(case when srce_indv_id is not null then 1 end) as "GMA rows"
count(case when srce_indv_id = '' then 1 end) as "GMA empty rows"
count(case when srce_indv_id = 0) as "GMA 0 rows"
from pos_trn_lvl_hdr
where pos_ord_dt between '2018-03-05' and '2018-03-25';



------Q2
-------------
d123 chicken sales
-------------

set wlm_query_slot_count to 5;
drop table if exists pca_gct_q2;
select pos_ord_dt,
'd123' as campaign,
sum(tot_sld_qt) as "quantity",
count(distinct mcd_gbal_lcat_id_nu||pos_busn_dt||pos_ord_key_id) as "guest count"
into pca_gct_q2
from pos_trn_lvl_hdr
left join pos_trn_lvl_dtl
using (mcd_gbal_lcat_id_nu,pos_ord_key_id,pos_busn_dt)
where pos_ord_dt between '2018-07-27' and '2018-10-30'
and sld_menu_itm_id in (4314,9931)
and pos_prmo_shrt_ds is null
group by 1,2;

set wlm_query_slot_count to 5;
drop table if exists pca_gct_q2a;
select pos_ord_dt,
'd123' as campaign,
sum(tot_sld_qt) as "quantity",
count(distinct mcd_gbal_lcat_id_nu||pos_busn_dt||pos_ord_key_id) as "guest count"
into pca_gct_q2a
from pos_trn_lvl_hdr
left join pos_trn_lvl_dtl
using (mcd_gbal_lcat_id_nu,pos_ord_key_id,pos_busn_dt)
where pos_ord_dt between '2018-07-27' and '2018-10-30'
and sld_menu_itm_id in (4314,9931)
and pos_prmo_shrt_ds is null
and srce_indv_id is not null
group by 1,2;


-------------
ROD chicken sales
-------------

set wlm_query_slot_count to 5;
insert into pca_gct_q2
select pos_ord_dt,
'rod' as campaign,
sum(tot_sld_qt) as "quantity",
count(distinct mcd_gbal_lcat_id_nu||pos_busn_dt||pos_ord_key_id) as "guest count"
from pos_trn_lvl_hdr
left join pos_trn_lvl_dtl
using (mcd_gbal_lcat_id_nu,pos_ord_key_id,pos_busn_dt)
where pos_ord_dt between '2018-07-27' and '2018-10-30'
and pos_prmo_shrt_ds = '2 for $5 Mix and Match'
and sld_menu_itm_id in (5280,9931)
group by 1,2;

set wlm_query_slot_count to 5;
insert into pca_gct_q2a
select pos_ord_dt,
'rod' as campaign,
sum(tot_sld_qt) as "quantity",
count(distinct mcd_gbal_lcat_id_nu||pos_busn_dt||pos_ord_key_id) as "guest count"
from pos_trn_lvl_hdr
left join pos_trn_lvl_dtl
using (mcd_gbal_lcat_id_nu,pos_ord_key_id,pos_busn_dt)
where pos_ord_dt between '2018-07-27' and '2018-10-30'
and pos_prmo_shrt_ds = '2 for $5 Mix and Match'
and sld_menu_itm_id in (5280,9931)
and srce_indv_id is not null
group by 1,2;


----------
GCT sales
----------


set wlm_query_slot_count to 5;
insert into pca_gct_q2
select pos_ord_dt,
'GCT' as campaign,
sum(tot_sld_qt) as "quantity",
count(distinct mcd_gbal_lcat_id_nu||pos_busn_dt||pos_ord_key_id) as "guest count"
from pos_trn_lvl_hdr a
left join pos_trn_lvl_dtl
using (mcd_gbal_lcat_id_nu,pos_ord_key_id,pos_busn_dt)
where pos_ord_dt between '2018-07-27' and '2018-10-30'
and sld_menu_itm_id in (select sld_menu_itm_id from gct_name_mapping where campaign_name = 'GCT')
and a.pos_evnt_typ_id = 1
group by 1,2;

set wlm_query_slot_count to 5;
insert into pca_gct_q2a
select pos_ord_dt,
'GCT' as campaign,
sum(tot_sld_qt) as "quantity",
count(distinct mcd_gbal_lcat_id_nu||pos_busn_dt||pos_ord_key_id) as "guest count"
from pos_trn_lvl_hdr a
left join pos_trn_lvl_dtl
using (mcd_gbal_lcat_id_nu,pos_ord_key_id,pos_busn_dt)
where pos_ord_dt between '2018-07-27' and '2018-10-30'
and sld_menu_itm_id in (select sld_menu_itm_id from gct_name_mapping where campaign_name = 'GCT')
and a.pos_evnt_typ_id = 1
and srce_indv_id is not null
group by 1,2;


----Q3
select sld_menu_itm_id,
sld_menu_itm_na
into chicken_mapping
from civis_menu_v2
where category in ('McNuggets','McChicken','Grilled Chicken','Crispy Chicken','Buttermilk Crispy Tenders');

-----define buyers during campaign
select srce_indv_id
into gct_buyer
from pos_trn_lvl_hdr
left join pos_trn_lvl_dtl
using (terr_cd,mcd_gbal_lcat_id_nu,pos_ord_key_id,pos_busn_dt,pos_evnt_typ_id)
where pos_ord_dt between '2018-08-27' and '2018-09-30'
and pos_evnt_typ_id = 1
and sld_menu_itm_id in (select sld_menu_itm_id from gct_name_mapping where campaign_name = 'GCT')
group by 1;

----get all possible chicken pre purchase first


select a.srce_indv_id,
'chicken buyer' as segment
into gct_buyer_pre_purchase
from gct_buyers a
left join pos_trn_lvl_hdr
using (srce_indv_id)
left join pos_trn_lvl_dtl b
using (terr_cd,mcd_gbal_lcat_id_nu,pos_ord_key_id,pos_busn_dt,pos_evnt_typ_id)
where pos_ord_dt between '2018-07-27' and '2018-08-26'
and (sld_menu_itm_id in select * from chicken_mapping)
group by 1;


select distinct a.srce_indv_id,
case when b.pos_ord_key_id is null then 'lapsed' else 'other mcd buyers' end as other_buyer_flag
into gct_other_mcd_buyer
from gct_buyer a
left join pos_trn_lvl_hdr b
using (srce_indv_id)
where pos_ord_dt between '2018-07-27' and '2018-08-26'
and srce_indv_id not in (select distinct srce_indv_id from gct_buyer_pre_purchase);


select srce_indv_id,
'other mcd buyers' as segment
into pca_gct_buyer
from gct_other_mcd_buyer;

insert into pca_gct_buyer
select srce_indv_id,
'Chicken Buyer' as segment
from gct_buyer_pre_purchase;

insert into pca_gct_buyer
select srce_indv_id,
'lapsed' as segment
from gct_buyer
where srce_indv_id not in (select distinct srce_indv_id from gct_buyer_pre_purchase)
and srce_indv_id not in (select distinct srce_indv_id from gct_other_mcd_buyer);


------------------------------IPSOS and race indexes


select ipsossegment,
count(distinct srce_indv_id) as "total user count"
from (select srce_indv_id,
ipsossegment
from pca_gct_buyer
left join
(select srce_indv_id,
'bb' as ipsossegment
from deliver_test
where bb_flag is not null
union
select srce_indv_id,
'ff' as ipsossegment
from deliver_test
where ff_flag is not null
union
select srce_indv_id,
'ts' as ipsossegment
from deliver_test
where ts_flag is not null
union
select srce_indv_id,
'kp' as ipsossegment
from deliver_test
where kp_flag is not null
union
select srce_indv_id,
'sd' as ipsossegment
from deliver_test
where sd_flag is not null
union
select srce_indv_id,
'hf' as ipsossegment
from deliver_test
where hf_flag is not null)
using (srce_indv_id))
group by 1
order by 1
;

select race,
count(distinct srce_indv_id)
from segment_app.mcdonalds_base_26w_demo
group by 1;

select
segment,
race,
count(distinct srce_indv_id) as "user count"
from pca_gct_buyer
left join segment_app.mcdonalds_base_26w_demo
using (srce_indv_id)
group by 1,2
order by 1,2;

race_count	uu
1	1	1113128
2	2	54441
3	3	224

select race_count,
count(distinct srce_indv_id) as UU
from (
select srce_indv_id,count(distinct race) as race_count
from segment_app.mcdonalds_base_26w_demo
group by 1
)
group by 1
order by 1
asc

select AfAm,
Asian,
White,
Hispanic,
Native,
count(distinct srce_indv_id)
from(
select srce_indv_id
sum(distinct AfAm) as AfAm,
sum(distinct Asian) as Asian
sum(distinct White) as White
sum(distinct Hispanic) as Hispanic
sum(Native) as Native
from(
select distinct srce_indv_id,
case when race = 'AfAm' then 1 else 0 end as AfAm
when race = 'Asian' then 1 else 0 end as Asian
when race = 'White' then 1 else 0 end as White
when race = 'Hispanic' then 1 else 0 end as Hispanic
when race = 'Native' then 1 else 0 end as Native
from segment_app.mcdonalds_base_26w_demo
)
group by 1)
group by 1,2,3,4,5;


afam	asian	white	hispanic	native	count
1	0	0	1	0	0	765907
2	1	0	0	0	0	174372
3	0	0	0	1	0	127801
4	0	1	0	0	0	43634
5	1	0	1	0	0	24948
6	0	0	1	1	0	16928
7	0	1	1	0	0	6455
8	1	0	0	1	0	2910
9	0	0	0	0	1	1414
10	0	1	0	1	0	1405
11	1	1	0	0	0	1125
12	0	0	1	0	1	501
13	1	0	1	1	0	118
14	1	0	0	0	1	87
15	0	0	0	1	1	56
16	1	1	1	0	0	47
17	0	1	1	1	0	36
18	0	1	0	0	1	26
19	1	1	0	1	0	12
20	1	0	1	0	1	9
21	0	0	1	1	1	1
22	0	1	0	1	1	1


----------------------------------------

select srce_indv_id
into bct_buyers
from pos_trn_lvl_hdr
left join pos_trn_lvl_dtl
using (terr_cd,mcd_gbal_lcat_id_nu,pos_ord_key_id,pos_busn_dt,pos_evnt_typ_id)
where pos_ord_dt between '2018-03-05' and '2018-03-25'
and pos_evnt_typ_id = 1
and sld_menu_itm_id in (select sld_menu_itm_id from gct_name_mapping where campaign_name = 'BCT')
group by 1;


select a.srce_indv_id,
'chicken buyer' as segment
into bct_buyer_pre_purchase
from bct_buyers a
left join pos_trn_lvl_hdr
using (srce_indv_id)
left join pos_trn_lvl_dtl b
using (terr_cd,mcd_gbal_lcat_id_nu,pos_ord_key_id,pos_busn_dt,pos_evnt_typ_id)
where pos_ord_dt between '2017-12-05' and '2018-03-04'
and sld_menu_itm_id in (select distinct sld_menu_itm_id from chicken_mapping)
group by 1;

select distinct a.srce_indv_id,
case when b.pos_ord_key_id is null then 'lapsed' else 'other mcd buyers' end as other_buyer_flag
into bct_other_mcd_buyer
from temp_bct_buyer a
left join pos_trn_lvl_hdr b
using (srce_indv_id)
where pos_ord_dt between '2017-12-05' and '2018-03-04'
and srce_indv_id not in (select distinct srce_indv_id from bct_buyer_pre_purchase);


delete from bct_buyer_pre_purchase where srce_indv_id is null;
delete from bct_other_mcd_buyer where srce_indv_id is null;
delete from bct_buyers where srce_indv_id is null;

    select srce_indv_id,
    'other mcd buyers' as segment
    into pca_bct_buyer
    from bct_other_mcd_buyer;

    insert into pca_bct_buyer
    select srce_indv_id,
    'Chicken Buyer' as segment
    from bct_buyer_pre_purchase;

    insert into pca_bct_buyer
    select srce_indv_id,
    'lapsed' as segment
    from bct_buyers
    where srce_indv_id not in (select distinct srce_indv_id from bct_buyer_pre_purchase)
    and srce_indv_id not in (select distinct srce_indv_id from bct_other_mcd_buyer);

