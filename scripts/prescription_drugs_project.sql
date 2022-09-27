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

--Q2a. A:Nurse Practitioner

--SUM instead of count?
SELECT specialty_description, COUNT(total_claim_count) AS claim_count
FROM prescriber
INNER JOIN prescription 
USING (npi)
GROUP BY specialty_description
ORDER BY claim_count DESC;

--Q2b. A: Nurse Practitioner

--sum instead of count?
SELECT specialty_description, COUNT(total_claim_count) AS claim_count, COUNT(opioid_drug_flag) AS opioid_flag
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

--Q4b. more was spent on antibiotics
--the ::money changes the cost column from numeric to money just for this query
SELECT COUNT(total_drug_cost)::money as cost,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug
INNER JOIN prescription 
USING (drug_name)
GROUP BY drug_type
ORDER BY cost DESC;

--Q5a. A:
--idk what cbsa is : think of cbsa as a zipcode type of info and fipscounty as a smaller area zipcode
SELECT *
FROM cbsa
LIMIT 10;

SELECT cbsa, cbsaname 
FROM cbsa
WHERE cbsaname ILIKE '%TN';

