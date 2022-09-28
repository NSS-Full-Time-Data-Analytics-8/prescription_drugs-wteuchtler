--Prescription Drug Project--
--Q1a. A: npi:1356305197 claims:379
SELECT npi, COUNT(total_claim_count) AS total_claim_per_subscriber
FROM prescription
GROUP BY npi
ORDER BY total_claim_per_subscriber DESC;

--Q1b. - how do you group by including names if it needs to be an aggregate? group by multiple
--columns if the columns have the same npi, last, and first name, which they do because 
-- npi is particular to a person, as is their name
SELECT prescription.npi,COUNT(total_claim_count) AS total_claim_per_subscriber, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
FROM prescription
INNER JOIN prescriber
USING (npi)
GROUP BY prescription.npi,nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY total_claim_per_subscriber DESC;

--Q2a. A:Family Practice

--switched COUNT to SUM
SELECT specialty_description, SUM(total_claim_count) AS claim_count
FROM prescriber
INNER JOIN prescription 
USING (npi)
GROUP BY specialty_description
ORDER BY claim_count DESC;

--Q2b. A: Nurse Practitioner

--switched count of total claim to sum
SELECT specialty_description, SUM(total_claim_count) AS claim_count, COUNT(opioid_drug_flag) AS opioid_flag
FROM prescriber
INNER JOIN prescription 
USING (npi)
INNER JOIN drug
USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY opioid_flag DESC;

--*Q2c. A:
-- So i think i need to do a filter here, where i filter out 
-- all the specialties that have a row with a value for total_claim_count
--and that way i can only look at the specialties that have no rows with a claim (aka
-- a specialty that only has null values)
SELECT DISTINCT specialty_description
FROM prescriber
LEFT JOIN prescription
USING (npi)
WHERE total_claim_count IS NULL;

--*BONUS Q2d. 

--Q3a. A: Pirfenidone
SELECT generic_name, ROUND(total_drug_cost,2)
FROM drug
INNER JOIN prescription
USING (drug_name)
ORDER BY total_drug_cost DESC
LIMIT 10;

--Q3b. A: "IMMUN GLOB G(IGG)/GLY/IGA OV50"
SELECT generic_name, ROUND(total_drug_cost / total_day_supply, 2) AS cost_by_day
FROM drug
INNER JOIN prescription
USING (drug_name)
ORDER BY cost_by_day DESC;

--Q4a. 
SELECT drug_name, opioid_drug_flag, antibiotic_drug_flag,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug;

--showing below that you dont need to keep the columns where you
--pulled the case parameters from 
SELECT drug_name, 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug;

--Q4b. more was spent on antibiotics, could also try to solve as a subquery too
--the ::money changes the cost column from numeric to money just for this query
--which is the same as using CAST(total_drug_cost as money)
SELECT COUNT(total_drug_cost)::money as cost,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug
INNER JOIN prescription 
USING (drug_name)
GROUP BY drug_type
ORDER BY cost DESC;

--Q5a. A: 33
--idk what cbsa is : think of cbsa as a zipcode type of info and 
--fipscounty as a smaller area zipcode
SELECT *
FROM cbsa
LIMIT 10;

SELECT COUNT(cbsa)
FROM cbsa
WHERE cbsaname ILIKE '%TN';

--Q5b. A: minimum population is 116,352 in cbsa 34100
--        maximum population is 1,830,410 in cbsa 34980

--didnt work, saving this mess for later
/*
SELECT cbsa_pop.cbsa, MIN(cbsa_pop.population), MAX(cbsa_pop.populatoin)
FROM (SELECT * --cbsa, SUM(population) AS total_pop, population 
	  FROM cbsa
      INNER JOIN population 
	  USING (fipscounty)) AS cbsa_pop
GROUP BY cbsa_pop.cbsa;
*/

--pulls the smallest and largest populations within each cbsa... not right
SELECT cbsa_pop.cbsa, MIN(cbsa_pop.population), MAX(cbsa_pop.population)
FROM (SELECT *
	  FROM cbsa
      INNER JOIN population 
	  USING (fipscounty)) AS cbsa_pop
GROUP BY cbsa_pop.cbsa;

-- idk a better way than to just re-sort the table asc and desc
SELECT cbsa, SUM(population) AS total_pop
FROM cbsa
INNER JOIN population 
USING (fipscounty)
GROUP BY cbsa
ORDER BY total_pop;

--Q5c A: Sevier, population 95,523
SELECT county, population 
FROM fips_county
LEFT JOIN cbsa
USING (fipscounty)
LEFT JOIN population 
USING (fipscounty)
WHERE cbsa IS NULL
AND population IS NOT NULL
ORDER BY population DESC;

--Q6a. why are some of the same drugs listed and counted twice
-- select distinct does not work because even though the drug name
--is the same, the other columns along with it are different. Just an issue with the data?
SELECT DISTINCT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= '3000';

--Q6b. 
SELECT DISTINCT drug_name, total_claim_count, opioid_drug_flag
FROM prescription
LEFT JOIN drug
USING (drug_name)
WHERE total_claim_count >= '3000';

--Q6c. 
SELECT DISTINCT drug_name, total_claim_count, opioid_drug_flag,nppes_provider_last_org_name ||', '|| nppes_provider_first_name AS provider_name
FROM prescription
LEFT JOIN drug
USING (drug_name)
LEFT JOIN prescriber 
USING(npi)
WHERE total_claim_count >= '3000';

--Q7a. --cross joins dont need an ON or USING line
SELECT npi, drug_name, specialty_description, nppes_provider_city, opioid_drug_flag
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';

--Q7b. 

--needs work...
SELECT prescriber.npi, drug.drug_name, total_claim_count 
FROM prescriber
CROSS JOIN drug
INNER JOIN prescription
USING (npi)
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';

