WITH PMC_all AS (
    SELECT 
    LOWER(doi) AS doi_pmc 

    FROM `utrecht-university.COVID_PMC.PMC_all_2021-11`
),

UPW_current AS (
    SELECT 
    a.*,
    b.genre as publication_type,
    b.published_date as published_date,
    b.oa_status as upw_current,
    DATE(b.updated) as last_updated_current,
    IF((SELECT COUNT(1) FROM UNNEST(b.oa_locations) AS location WHERE 
    (location.host_type = 'repository' AND location.url LIKE 'https://www.ncbi.nlm.nih.gov/pmc/%')) > 0, TRUE, FALSE)  as upw_green_pmc_current,


    FROM PMC_all as a
    LEFT JOIN `academic-observatory.our_research.unpaywall`  as b
    ON a.doi_pmc = b.doi      
),

UPW_20210702 AS (
    SELECT 
    a.*,
    b.oa_status as upw_20210702,
    DATE(b.updated) as last_updated_20210702,
    IF((SELECT COUNT(1) FROM UNNEST(b.oa_locations) AS location WHERE 
    (location.host_type = 'repository' AND location.url LIKE 'https://www.ncbi.nlm.nih.gov/pmc/%')) > 0, TRUE, FALSE)  as upw_green_pmc_20210702

    FROM UPW_current as a
    LEFT JOIN `academic-observatory.our_research.unpaywall_snapshot20210702`  as b
    ON a.doi_pmc = b.doi      
),

UPW_20210218 AS (
    SELECT 
    a.*,
    b.oa_status as upw_20210218,
    DATE(b.updated) as last_updated_20210218,
    IF((SELECT COUNT(1) FROM UNNEST(b.oa_locations) AS location WHERE 
    (location.host_type = 'repository' AND location.url LIKE 'https://www.ncbi.nlm.nih.gov/pmc/%')) > 0, TRUE, FALSE)  as upw_green_pmc_20210702


    FROM UPW_20210702 as a
    LEFT JOIN `academic-observatory.our_research.unpaywall_snapshot20210218`  as b
    ON a.doi_pmc = b.doi      
),

UPW_20201009 AS (
    SELECT 
    a.*,
    b.oa_status as upw_20201009,
    DATE(b.updated) as last_updated_20201009,
    IF((SELECT COUNT(1) FROM UNNEST(b.oa_locations) AS location WHERE 
    (location.host_type = 'repository' AND location.url LIKE 'https://www.ncbi.nlm.nih.gov/pmc/%')) > 0, TRUE, FALSE)  as upw_green_pmc_20201009


    FROM UPW_20210218 as a
    LEFT JOIN `academic-observatory.our_research.unpaywall_snapshot20201009`  as b
    ON a.doi_pmc = b.doi      
),

UPW_20200427 AS (
    SELECT 
    a.*,
    b.oa_status as upw_20200427,
    DATE(b.updated) as last_updated_20200427,
    IF((SELECT COUNT(1) FROM UNNEST(b.oa_locations) AS location WHERE 
    (location.host_type = 'repository' AND location.url LIKE 'https://www.ncbi.nlm.nih.gov/pmc/%')) > 0, TRUE, FALSE)  as upw_green_pmc_20200427


    FROM UPW_20201009 as a
    LEFT JOIN `academic-observatory.our_research.unpaywall_snapshot20200427`  as b
    ON a.doi_pmc = b.doi      
),

UPW_20200225 AS (
    SELECT 
    a.*,
    b.oa_status as upw_20200225,
    DATE(b.updated) as last_updated_20200225,
    IF((SELECT COUNT(1) FROM UNNEST(b.oa_locations) AS location WHERE 
    (location.host_type = 'repository' AND location.url LIKE 'https://www.ncbi.nlm.nih.gov/pmc/%')) > 0, TRUE, FALSE)  as upw_green_pmc_20200225


    FROM UPW_20200427 as a
    LEFT JOIN `academic-observatory.our_research.unpaywall_snapshot20200225`  as b
    ON a.doi_pmc = b.doi      
),

UPW_20191122 AS (
    SELECT 
    a.*,
    b.oa_status as upw_20191122,
    DATE(b.updated) as last_updated_20191122,
    IF((SELECT COUNT(1) FROM UNNEST(b.oa_locations) AS location WHERE 
    (location.host_type = 'repository' AND location.url LIKE 'https://www.ncbi.nlm.nih.gov/pmc/%')) > 0, TRUE, FALSE)  as upw_green_pmc_20191122


    FROM UPW_20200225 as a
    LEFT JOIN `academic-observatory.our_research.unpaywall_snapshot20191122`  as b
    ON a.doi_pmc = b.doi      
)

SELECT * FROM UPW_20191122