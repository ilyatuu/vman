/* 
 * Name: init_views.sql
 * Created by: Isaac Lya2, Patrick Larbi-Debrah
 * Email: ilyatuu@gmail.com
 * Date: Feb 9th, 2018 
 * Purpose: Run this to initialize mysql views for the va dashboard management app to run.
 * */

-- Drop tables if exist
DROP VIEW IF EXISTS view_va,view_summary_va,view_summary_coding;
DROP VIEW IF EXISTS view_interviewer,view_individual_va,view_coded_va,view_assignments;


CREATE OR REPLACE VIEW view_assignments AS
SELECT b.coder1_id,
    b.coder2_id,
    c.fullname AS coder1,
    d.fullname AS coder2,
    a.`_URI`,
    a.`RESPONDENT_BACKGR_ID10010` AS interviewer_name,
    a.`PHONENUMBER` AS interviewer_phone,
    date_format(a.`RESPONDENT_BACKGR_ID10012`,'%Y-%m-%d') AS interview_date,
    a.`RESPONDENT_BACKGR_ID10013` AS interview_consent,
    e.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10058` AS death_location,
    e.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10057_GROUP_ID10057_R` AS death_loc_level1, -- region
    e.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10057_GROUP_ID10057_D` AS death_loc_level2, -- district
    e.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10057_GROUP_ID10057_V` AS death_loc_level3, -- village, notice ward is skipped
        CASE
            WHEN e.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_CHILD`= '1' THEN 'CHILD'
            WHEN e.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_NEONATAL` = '1' THEN 'NEONATAL'
            WHEN e.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_ADULT` = '1' THEN 'ADULT'
            ELSE 'UNKNOWN'
        END AS death_category
   FROM VAWHOV151_CORE a
     LEFT JOIN _web_assignment b ON a.`_URI`= b.va_uri
     LEFT JOIN _web_users c ON b.coder1_id = c.id
     LEFT JOIN _web_users d ON b.coder2_id = d.id
     LEFT JOIN VAWHOV151_CORE4 e ON a.`_URI`= e.`_PARENT_AURI`;
     

CREATE OR REPLACE VIEW view_individual_va AS
 SELECT 
 	a.`_URI`,
    a.`RESPONDENT_BACKGR_ID10010` AS interviewer_name,
    a.`PHONENUMBER` AS interviewer_phone,
    date_format(a.`RESPONDENT_BACKGR_ID10012`,'%Y-%m-%d') AS interview_date,
   TIME_FORMAT(a.START_TIME, '%H:%i') as interview_start,
   TIME_FORMAT(a.END, '%H:%i') as interview_end,
   TIME_FORMAT(TIMEDIFF(a.END,a.START_TIME),'%H:%i:%S') as interview_time,
   LENGTH(a.`CONSENTED_NARRAT_ID10476`) as narrative_chars,
    a.`RESPONDENT_BACKGR_ID10013` AS interview_consent,
    CONCAT(c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10017`,' ',c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10018`) AS deceased_name,
    c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10019`AS deceased_gender,
    c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10058` AS death_location,
    c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10057_GROUP_ID10057_R` AS death_loc_level1, -- region
    c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10057_GROUP_ID10057_D` AS death_loc_level2, -- ward
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10057_GROUP_ID10057_V` AS death_loc_level3, -- village, notice ward is skipped
        CASE
            WHEN c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_CHILD` = '1'THEN 'CHILD'
            WHEN c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_NEONATAL` = '1'THEN 'NEONATAL'
            WHEN c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_ADULT` = '1'THEN 'ADULT'
            ELSE NULL
        END AS death_category,
    c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_IN_YEARS` AS age_in_years1, -- calculated age in years. both dob and dod present
    c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_IN_MONTHS` AS age_in_months1,
    c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_IN_DAYS` AS age_in_days1,
    c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_ADULT` AS age_in_years2,	-- entered age in years, either dob or dod is missing
    c1a.icdname AS c1coda,
    c1a.id AS c1codaid,
    c1b.icdname AS c1codb,
    c1b.id AS c1codbid,
    c1c.icdname AS c1codc,
    c1c.id AS c1codcid,
    c1d.icdname AS c1codd,
    c1d.id AS c1coddid,
    b.coder1_comments AS c1comments,
        CASE
            WHEN b.coder1_codd IS NOT NULL THEN c1d.icdname
            WHEN b.coder1_codc IS NOT NULL THEN c1c.icdname
            WHEN b.coder1_codb IS NOT NULL THEN c1b.icdname
            WHEN b.coder1_coda IS NOT NULL THEN c1a.icdname
            ELSE NULL
        END AS c1ucd,
    c2a.icdname AS c2coda,
    c2a.id AS c2codaid,
    c2b.icdname AS c2codb,
    c2b.id AS c2codbid,
    c2c.icdname AS c2codc,
    c2c.id AS c2codcid,
    c2d.icdname AS c2codd,
    c2d.id AS c2coddid,
    b.coder2_comments AS c2comments,
        CASE
            WHEN b.coder2_codd IS NOT NULL THEN c2d.icdname
            WHEN b.coder2_codc IS NOT NULL THEN c2c.icdname
            WHEN b.coder2_codb IS NOT NULL THEN c2b.icdname
            WHEN b.coder2_coda IS NOT NULL THEN c2a.icdname
            ELSE NULL        END AS c2ucd,
    b.coder1_id AS c1id,
    c1.fullname AS c1name,
    b.coder2_id AS c2id,
    c2.fullname AS c2name
   FROM `VAWHOV151_CORE` a
     LEFT JOIN _web_assignment b ON a.`_URI` = b.va_uri
     LEFT JOIN _web_users c1 ON b.coder1_id = c1.id
     LEFT JOIN _web_users c2 ON b.coder2_id = c2.id
     LEFT JOIN _web_icd10 c1a ON b.coder1_coda = c1a.id
     LEFT JOIN _web_icd10 c1b ON b.coder1_codb = c1b.id
     LEFT JOIN _web_icd10 c1c ON b.coder1_codc = c1c.id
     LEFT JOIN _web_icd10 c1d ON b.coder1_codd = c1d.id
     LEFT JOIN _web_icd10 c2a ON b.coder2_coda = c2a.id
     LEFT JOIN _web_icd10 c2b ON b.coder2_codb = c2b.id
     LEFT JOIN _web_icd10 c2c ON b.coder2_codc = c2c.id
     LEFT JOIN _web_icd10 c2d ON b.coder2_codd = c2d.id
     LEFT JOIN `VAWHOV151_CORE4` c on a.`_URI` = c.`_PARENT_AURI`;
 

CREATE OR REPLACE VIEW view_summary_va AS
 SELECT 1 AS "#",
    'Today' AS label,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_ADULT`= '1' THEN 1
            ELSE NULL
        END) AS adult,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_CHILD` = '1' THEN 1
            ELSE NULL
        END) AS child,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_NEONATAL` = '1' THEN 1
            ELSE NULL
        END) AS neonatal
   FROM VAWHOV151_CORE4
 WHERE DATE(`_CREATION_DATE`) = CURDATE()
UNION
 SELECT 2 AS "#",
    'This week' AS label,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_ADULT` = '1' THEN 1
            ELSE NULL
        END) AS adult,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_CHILD` = '1' THEN 1
            ELSE NULL
        END) AS child,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_NEONATAL` = '1' THEN 1
            ELSE NULL
        END) AS neonatal
   FROM VAWHOV151_CORE4
  WHERE WEEK(DATE(`_CREATION_DATE`)) = WEEK(CURDATE())
UNION
 SELECT 3 AS "#",
    'This month' AS label,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_ADULT` = '1' THEN 1
            ELSE NULL
        END) AS adult,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_CHILD` = '1' THEN 1
            ELSE NULL
        END) AS child,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_NEONATAL` = '1' THEN 1
            ELSE NULL
        END) AS neonatal
   FROM VAWHOV151_CORE4
 WHERE MONTH(DATE(`_CREATION_DATE`)) = MONTH(CURDATE())
UNION
 SELECT 4 AS "#",
    'This year' AS label,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_ADULT` = '1' THEN 1
            ELSE NULL
        END) AS adult,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_CHILD` = '1' THEN 1
            ELSE NULL
        END) AS child,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_NEONATAL` = '1' THEN 1
            ELSE NULL
        END) AS neonatal
   FROM VAWHOV151_CORE4
  WHERE YEAR(DATE(`_CREATION_DATE`)) = YEAR(CURDATE())
UNION
 SELECT 5 AS "#",
    'Total' AS label,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_ADULT` = '1' THEN 1
            ELSE NULL
        END) AS adult,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_CHILD` = '1' THEN 1
            ELSE NULL
        END) AS child,
    count(
        CASE
            WHEN `CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_NEONATAL` = '1' THEN 1
            ELSE NULL
        END) AS neonatal
   FROM VAWHOV151_CORE4
  ORDER BY 1;
  
 CREATE OR REPLACE VIEW view_coded_va AS
 SELECT 
 	a.`_URI` AS va_id,
    a.death_loc_level1,
    a.death_loc_level2,
    a.deceased_gender AS gender,
    a.death_category AS category,
    a.age_in_years1,
   	a.age_in_years2,
    a.age_in_months1,
    a.age_in_days1,
    a.c1ucd AS ucd
  FROM view_individual_va a
  WHERE a.c1ucd = a.c2ucd;
  
  
  CREATE OR REPLACE VIEW view_summary_coding AS 
 SELECT a.fullname,
    count(a.fullname) AS assigned,
    sum(
        CASE
            WHEN b.c1coda IS NOT NULL AND b.c1id = a.id OR b.c2coda IS NOT NULL AND b.c2id = a.id THEN 1
            ELSE 0
        END) AS attempted,
    sum(
        CASE
            WHEN b.c1ucd = b.c2ucd THEN 1
            ELSE 0
        END) AS concordant,
    sum(
        CASE
            WHEN b.c1ucd <> b.c2ucd THEN 1
            ELSE 0
        END) AS discordant,
    sum(
        CASE
            WHEN b.c1coda IS NOT NULL AND b.c1id = a.id AND b.c2coda IS NULL OR b.c2coda IS NOT NULL AND b.c2id = a.id AND b.c1coda IS NULL THEN 1
            ELSE 0
        END) AS pending,
    sum(
        CASE
            WHEN b.c1coda IS NULL AND b.c1id = a.id THEN 1
            ELSE 0
        END) AS incomplete_c1,
    sum(
        CASE
            WHEN b.c2coda IS NULL AND b.c2id = a.id THEN 1
            ELSE 0
        END) AS incomplete_c2
   FROM _web_users a
     RIGHT JOIN view_individual_va b ON a.id = b.c1id OR a.id = b.c2id
  WHERE a.id IS NOT NULL
  GROUP BY a.id;
  
  
  create or replace view view_interviewer as
  select
  a.`RESPONDENT_BACKGR_ID10010` AS interviewer_name,
  a.`RESPONDENT_BACKGR_ID10005_R` as death_loc_level1, -- region
  a.`RESPONDENT_BACKGR_ID10005_W` as death_loc_level2, -- district
  SUM( CASE WHEN MONTH(DATE(`_CREATION_DATE`)) = 1 THEN 1 ELSE 0 END ) as jan,
  SUM( CASE WHEN MONTH(DATE(`_CREATION_DATE`)) = 2 THEN 1 ELSE 0 END ) as feb,
  SUM( CASE WHEN MONTH(DATE(`_CREATION_DATE`)) = 3 THEN 1 ELSE 0 END ) as mar,
  SUM( CASE WHEN MONTH(DATE(`_CREATION_DATE`)) = 4 THEN 1 ELSE 0 END ) as apr,
  SUM( CASE WHEN MONTH(DATE(`_CREATION_DATE`)) = 5 THEN 1 ELSE 0 END ) as may,
  SUM( CASE WHEN MONTH(DATE(`_CREATION_DATE`)) = 6 THEN 1 ELSE 0 END ) as jun,
  SUM( CASE WHEN MONTH(DATE(`_CREATION_DATE`)) = 7 THEN 1 ELSE 0 END ) as jul,
  SUM( CASE WHEN MONTH(DATE(`_CREATION_DATE`)) = 8 THEN 1 ELSE 0 END ) as aug,
  SUM( CASE WHEN MONTH(DATE(`_CREATION_DATE`)) = 9 THEN 1 ELSE 0 END ) as sep,
  SUM( CASE WHEN MONTH(DATE(`_CREATION_DATE`)) = 10 THEN 1 ELSE 0 END ) as oct,
  SUM( CASE WHEN MONTH(DATE(`_CREATION_DATE`)) = 11 THEN 1 ELSE 0 END ) as nov,
  SUM( CASE WHEN MONTH(DATE(`_CREATION_DATE`)) = 12 THEN 1 ELSE 0 END ) as dece,
  count(*) as tot,
  YEAR(DATE(`_CREATION_DATE`)) as interview_year
  from `VAWHOV151_CORE` a
  group by interviewer_name, interview_year, death_loc_level1, death_loc_level2;
  
  
create view view_va as
select 
	a.`_URI`,
	a.`CONSENTED_NARRAT_ID10476`,
	a.`CONSENTED_BACK_CONTEXT_ID10457`,
	a.`CONSENTED_BACK_CONTEXT_ID10458`,
	a.`CONSENTED_BACK_CONTEXT_ID10455`,
	a.`CONSENTED_BACK_CONTEXT_ID10456`,
	a.`CONSENTED_STILLBIRTH_ID10113`,
	a.`CONSENTED_STILLBIRTH_ID10112`,
	a.`CONSENTED_STILLBIRTH_ID10111`,
	a.`CONSENTED_BACK_CONTEXT_ID10459`,
	a.`CONSENTED_STILLBIRTH_ID10110`,
	a.`RESPONDENT_BACKGR_ID10010`,
	a.`CONSENTED_BACK_CONTEXT_ID10450`,
	a.`RESPONDENT_BACKGR_ID10012`,
	a.`CONSENTED_STILLBIRTH_ID10115`,
	a.`RESPONDENT_BACKGR_ID10011`,
	a.`CONSENTED_BACK_CONTEXT_ID10453`,
	a.`RESPONDENT_BACKGR_ID10013`,
	a.`CONSENTED_BACK_CONTEXT_ID10454`,
	a.`CONSENTED_BACK_CONTEXT_ID10451`,
	a.`CONSENTED_BACK_CONTEXT_ID10452`,
	a.`RESPONDENT_BACKGR_ID10007`,
	a.`RESPONDENT_BACKGR_ID10009`,
	a.`RESPONDENT_BACKGR_ID10008`,
	a.`CONSENTED_STILLBIRTH_ID10106`,
	a.`CONSENTED_STILLBIRTH_ID10105`,
	a.`CONSENTED_STILLBIRTH_ID10104`,
	a.`CONSENTED_STILLBIRTH_ID10109`,
	a.`CONSENTED_STILLBIRTH_ID10107`,
	a.`PRESETS_ID10004`,
	a.`CONSENTED_ID10481`,
	a.`CONSENTED_DEATHCERT_ID10462`,
	b.`CONSENTED_ILLHISTORY_ID10408`,
	b.`CONSENTED_ILLHISTORY_ILLDUR_ID10120_UNIT`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10139`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10138`,
	b.`CONSENTED_ILLHISTORY_RISK_FACTORS_ID10416`,
	b.`CONSENTED_ILLHISTORY_RISK_FACTORS_ID10414`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10135`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10134`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10137`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10136`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10131`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10130`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10419`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10133`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10418`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10132`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10423`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10422`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10421`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10420`,
	b.`CONSENTED_ILLHISTORY_ID10123`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10128`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10127`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10129`,
	b.`CONSENTED_ILLHISTORY_ILLDUR_ID10122`,
	b.`CONSENTED_ILLHISTORY_ILLDUR_ID10121`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10126`,
	b.`CONSENTED_ILLHISTORY_ILLDUR_ID10120`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10125`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10446`,
	b.`CONSENTED_ILLHISTORY_RISK_FACTORS_ID10413`,
	b.`CONSENTED_ILLHISTORY_RISK_FACTORS_ID10412`,
	b.`CONSENTED_ILLHISTORY_RISK_FACTORS_ID10411`,
	b.`CONSENTED_ILLHISTORY_ILLDUR_ID10120_0`,
	b.`CONSENTED_ILLHISTORY_ILLDUR_ID10120_1`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10437`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10436`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10435`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10445`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10427`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10425`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10424`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10142`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10141`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10144`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10429`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10143`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10428`,
	b.`CONSENTED_ILLHISTORY_MED_HIST_FINAL_ILLNESS_ID10140`,
	b.`CONSENTED_ILLHISTORY_HEALTH_SERVICE_UTILIZATION_ID10432`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_CHILD1`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_ADULT`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_CHILD2`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_IN_MONTHS`,
	c.`CONSENTED_DECEASED_CRVS_VITAL_REG_CERTIF_ID10069_A`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_CHILD_YEARS`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_IN_DAYS`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_CHILD_UNIT`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_IN_YEARS2`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_IN_MONTHS_REMAIN`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_IN_YEARS`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10063`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10020`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10064`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10021`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10065`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10022`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10023`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_IN_YEARS_REMAIN`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_IN_DAYS_NEONATE`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_GROUP`,
	c.`CONSENTED_INJURIES_ACCIDENTS_ID10077`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_NEONATAL`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_ADULT`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_IS_CHILD`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10051`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10052`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10053`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10054_GROUP_ID10054_R`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10054_GROUP_ID10054_W`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10054_GROUP_ID10054_K`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10055`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10057`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10058`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10059`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10017`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10018`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10019`,
	c.`CONSENTED_DECEASED_CRVS_VITAL_REG_CERTIF_ID10069`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10023_A`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_ID10023_B`,
	c.`CONSENTED_DECEASED_CRVS_INFO_ON_DECEASED_AGE_IN_MONTHS_BY_YEAR`
from VAWHOV151_CORE a
left join VAWHOV151_CORE2 b on a._URI = b.`_PARENT_AURI`
left join VAWHOV151_CORE4 c on a.`_URI` = c.`_PARENT_AURI`;