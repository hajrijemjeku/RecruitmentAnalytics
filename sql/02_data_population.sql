/* 
   RECRUITMENT & HIRING ANALYTICS
   Data Population & Backfill Logic

   File: 02_data_population.sql

   Purpose:
   1. Populate 6 primary tables from raw CSV datasets (or bulk inserts).
   2. Execute deterministic T-SQL rules to populate engineered tables:
      - dbo.Departments
      - dbo.Recruiters
      - dbo.Assessments
   3. Backfill foreign key relationships (Jobs.department_id, Applications.recruiter_id).

   Database: RecruitmentAnalytics
*/

USE RecruitmentAnalytics;
GO

-- 
-- STEP 1: BULK LOAD CSV DATA INTO SOURCE TABLES
-- (Replace file paths with your local relative or absolute CSV path)
-- 


BULK INSERT dbo.Candidates
FROM '\candidates.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

-- 1. Create a staging view matching the 11 CSV columns
CREATE OR ALTER VIEW dbo.vw_Jobs_BulkImport AS
SELECT 
    job_id,
    company_id,
    posted_at,
    title,
    role_family,
    level,
    location_type,
    employment_type,
    salary_low,
    salary_high,
    status
FROM dbo.Jobs;
GO

-- 2. Bulk insert into the view (leaves department_id as NULL)
BULK INSERT dbo.vw_Jobs_BulkImport
FROM '\jobs.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

-- 3. Clean up the temporary view
DROP VIEW dbo.vw_Jobs_BulkImport;
GO

-- 1. Create a staging view matching the 7 CSV columns
CREATE OR ALTER VIEW dbo.vw_Applications_BulkImport AS
SELECT 
    application_id,
    job_id,
    candidate_id,
    applied_at,
    source,
    stage,
    score
FROM dbo.Applications;
GO

-- 2. Bulk insert into the view (leaves recruiter_id as NULL)
BULK INSERT dbo.vw_Applications_BulkImport
FROM '\applications.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

-- 3. Clean up the temporary view
DROP VIEW dbo.vw_Applications_BulkImport;
GO

BULK INSERT dbo.Interviews
FROM '\interviews.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO
ALTER TABLE dbo.Offers
ALTER COLUMN accepted VARCHAR(10) NOT NULL;
BULK INSERT dbo.Offers
FROM '\offers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

-- Step 1: Convert string text ('TRUE' / 'FALSE') into '1' and '0'
UPDATE dbo.Offers
SET accepted = CASE 
    WHEN LOWER(TRIM(accepted)) IN ('true', '1') THEN '1'
    ELSE '0'
END;
GO

-- Step 2: Alter the column data type back to BIT
ALTER TABLE dbo.Offers
ALTER COLUMN accepted BIT NOT NULL;
GO



-- Insert Into SQL statements per Companies table

INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (1, 'Rodriguez, Figueroa and Sanchez', 'software', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (2, 'Doyle Ltd', 'fintech', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (3, 'Mcclain, Miller and Henderson', 'fintech', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (4, 'Davis and Sons', 'logistics', 'startup', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (5, 'Guzman, Hoffman and Baldwin', 'logistics', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (6, 'Gardner, Robinson and Lawrence', 'retail', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (7, 'Blake and Sons', 'software', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (8, 'Henderson, Ramirez and Lewis', 'fintech', 'enterprise', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (9, 'Garcia-James', 'healthcare', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (10, 'Abbott-Munoz', 'software', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (11, 'Blair PLC', 'logistics', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (12, 'Dudley Group', 'retail', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (13, 'Arnold Ltd', 'fintech', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (14, 'Mcclure, Ward and Lee', 'fintech', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (15, 'Williams and Sons', 'fintech', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (16, 'Galloway-Wyatt', 'fintech', 'startup', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (17, 'James Group', 'logistics', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (18, 'Flowers, Martin and Kelly', 'software', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (19, 'Adams, Zuniga and Wong', 'retail', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (20, 'Reid, Ferguson and Sanchez', 'logistics', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (21, 'Gray-Mayo', 'logistics', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (22, 'Watts, Robinson and Nguyen', 'healthcare', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (23, 'Perez Inc', 'software', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (24, 'Morales-Jones', 'retail', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (25, 'Walter, Edwards and Rios', 'fintech', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (26, 'Wilkerson-Day', 'fintech', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (27, 'Baker and Sons', 'logistics', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (28, 'Hoffman, Baker and Richards', 'retail', 'startup', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (29, 'Ross, Robinson and Bright', 'logistics', 'enterprise', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (30, 'Snyder, Campos and Callahan', 'logistics', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (31, 'Burton Ltd', 'logistics', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (32, 'Carlson-Cruz', 'healthcare', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (33, 'Ferrell, Rice and Maddox', 'software', 'startup', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (34, 'Frazier Inc', 'logistics', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (35, 'Dyer, Potter and Mack', 'retail', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (36, 'Rodriguez-Graham', 'software', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (37, 'Smith-Bowen', 'retail', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (38, 'Baker, Mason and White', 'retail', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (39, 'Harrell LLC', 'healthcare', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (40, 'Romero, Gonzalez and Brooks', 'fintech', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (41, 'Ryan PLC', 'software', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (42, 'George Group', 'fintech', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (43, 'Rodriguez LLC', 'fintech', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (44, 'Allen-Allen', 'healthcare', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (45, 'Arroyo, Miller and Tucker', 'software', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (46, 'Spence PLC', 'retail', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (47, 'Anderson Group', 'logistics', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (48, 'Martin, Rose and Obrien', 'retail', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (49, 'Hickman Ltd', 'fintech', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (50, 'Harris, Collins and Carney', 'fintech', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (51, 'Brooks, Lam and Hayes', 'fintech', 'enterprise', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (52, 'Walker LLC', 'software', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (53, 'Chapman and Sons', 'healthcare', 'startup', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (54, 'Robinson, Jones and Welch', 'logistics', 'enterprise', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (55, 'Jones Inc', 'logistics', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (56, 'Jones-Young', 'software', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (57, 'Washington, Ryan and Cummings', 'logistics', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (58, 'Johnston, Sanchez and Kennedy', 'software', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (59, 'Lee-Davis', 'fintech', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (60, 'Gomez-Jenkins', 'fintech', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (61, 'Brown, Valdez and Lucas', 'retail', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (62, 'Powell LLC', 'fintech', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (63, 'Wright and Sons', 'healthcare', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (64, 'West, Henderson and Ramirez', 'retail', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (65, 'Baxter Inc', 'logistics', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (66, 'Morton-Chase', 'healthcare', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (67, 'Williams PLC', 'retail', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (68, 'Novak and Sons', 'healthcare', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (69, 'Russell Group', 'software', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (70, 'Hancock Inc', 'logistics', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (71, 'Gray Group', 'fintech', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (72, 'House-Glover', 'software', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (73, 'Henderson-Bernard', 'logistics', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (74, 'Stanley, Tucker and Lee', 'software', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (75, 'Novak PLC', 'fintech', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (76, 'Daniels, Adkins and Brown', 'logistics', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (77, 'Woods, Calhoun and Schmidt', 'healthcare', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (78, 'Yu Inc', 'healthcare', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (79, 'Jones Inc', 'logistics', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (80, 'Hensley, Powell and David', 'fintech', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (81, 'Sanchez, Wheeler and Harvey', 'retail', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (82, 'Sandoval-Cunningham', 'logistics', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (83, 'Donovan-Harris', 'software', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (84, 'Edwards, Baker and Anderson', 'retail', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (85, 'Evans, Stewart and Walton', 'fintech', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (86, 'Smith PLC', 'fintech', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (87, 'Ferrell, Jones and Lewis', 'software', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (88, 'Anderson-Bailey', 'healthcare', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (89, 'Suarez LLC', 'fintech', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (90, 'Moore-Bass', 'retail', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (91, 'Turner, Riggs and Roman', 'logistics', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (92, 'Smith, Montoya and Evans', 'retail', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (93, 'Garcia, Humphrey and Baker', 'retail', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (94, 'Newton and Sons', 'healthcare', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (95, 'Campbell-Clark', 'retail', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (96, 'Harris-Walters', 'healthcare', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (97, 'Wagner-King', 'healthcare', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (98, 'Davis Group', 'fintech', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (99, 'Williams-Cook', 'fintech', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (100, 'Walsh LLC', 'software', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (101, 'Figueroa PLC', 'retail', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (102, 'Patterson, Smith and Jones', 'software', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (103, 'Mckee, Gardner and Davenport', 'retail', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (104, 'Tran, Jordan and Williams', 'software', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (105, 'Nolan-Flynn', 'fintech', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (106, 'Nolan and Sons', 'fintech', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (107, 'Wright, Garcia and Deleon', 'fintech', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (108, 'Dickson-Brady', 'fintech', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (109, 'Hancock and Sons', 'logistics', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (110, 'Johnson-Doyle', 'fintech', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (111, 'Patton-Jenkins', 'healthcare', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (112, 'Shields, Cochran and Adams', 'fintech', 'startup', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (113, 'Rodriguez, Brennan and Garrison', 'logistics', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (114, 'Gonzalez Group', 'logistics', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (115, 'Torres-Pope', 'logistics', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (116, 'Walker Ltd', 'logistics', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (117, 'Ross LLC', 'software', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (118, 'Rasmussen LLC', 'software', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (119, 'May-Ross', 'healthcare', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (120, 'Rivera, Johnson and Wiley', 'software', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (121, 'White-Estes', 'logistics', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (122, 'Johnson-Carlson', 'fintech', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (123, 'Chandler-Edwards', 'fintech', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (124, 'Joyce, Wilson and Lam', 'logistics', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (125, 'Scott Ltd', 'retail', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (126, 'Smith-Frost', 'logistics', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (127, 'Mcdaniel, Bentley and Mclaughlin', 'software', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (128, 'Diaz Inc', 'fintech', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (129, 'Mccall, Hanson and Alvarado', 'logistics', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (130, 'Cortez LLC', 'fintech', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (131, 'Parker, Ortiz and Powell', 'logistics', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (132, 'Spencer-Lee', 'logistics', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (133, 'Bentley, Byrd and Orr', 'software', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (134, 'Carroll, Sullivan and Bass', 'logistics', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (135, 'Mitchell-Jordan', 'fintech', 'enterprise', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (136, 'Lawson, Morris and Ramos', 'healthcare', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (137, 'Lewis, Kennedy and Santana', 'fintech', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (138, 'Jackson, Miller and Robertson', 'software', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (139, 'Harvey, Davis and Crane', 'healthcare', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (140, 'Chambers and Sons', 'logistics', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (141, 'Hernandez Inc', 'retail', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (142, 'Riggs PLC', 'healthcare', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (143, 'Gibson Ltd', 'healthcare', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (144, 'Lee, Horton and Snyder', 'logistics', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (145, 'Hernandez Ltd', 'retail', 'enterprise', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (146, 'Stafford Inc', 'retail', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (147, 'Robinson-Brock', 'software', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (148, 'Holmes, Williams and Wright', 'healthcare', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (149, 'Bryant Group', 'retail', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (150, 'Schmidt, Hansen and Stewart', 'software', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (151, 'Salazar-Ball', 'retail', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (152, 'Simmons, Meadows and Griffin', 'healthcare', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (153, 'Manning Group', 'retail', 'startup', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (154, 'Green-Wright', 'healthcare', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (155, 'Ramirez, Strickland and Washington', 'logistics', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (156, 'Hill Inc', 'fintech', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (157, 'Mitchell, Nelson and Flores', 'software', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (158, 'Miller, Hernandez and Reyes', 'logistics', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (159, 'Mccarthy Inc', 'logistics', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (160, 'Russell-Daniels', 'fintech', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (161, 'Brown-Wall', 'retail', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (162, 'Stein-Silva', 'fintech', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (163, 'Smith, Gilmore and Johnston', 'logistics', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (164, 'Smith-Bell', 'logistics', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (165, 'Castaneda-Ashley', 'logistics', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (166, 'Medina-Navarro', 'retail', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (167, 'Hurst, Freeman and Nelson', 'healthcare', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (168, 'Johnson-Rogers', 'software', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (169, 'Yates, Ramsey and Pittman', 'healthcare', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (170, 'Hooper PLC', 'software', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (171, 'Meadows PLC', 'software', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (172, 'Alvarado, Miller and Patterson', 'software', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (173, 'White-Green', 'fintech', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (174, 'Lewis-Murphy', 'fintech', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (175, 'Ramirez-Bean', 'fintech', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (176, 'King-Miller', 'logistics', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (177, 'Curry Inc', 'fintech', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (178, 'Walker-Jones', 'software', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (179, 'Williams, Johnson and Wright', 'retail', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (180, 'Howell and Sons', 'logistics', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (181, 'Wells Inc', 'retail', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (182, 'Gould, Marshall and Scott', 'software', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (183, 'Jackson-Lawson', 'logistics', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (184, 'Higgins, Strickland and Martin', 'fintech', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (185, 'Rodriguez-Johnson', 'logistics', 'enterprise', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (186, 'Johnston-Odonnell', 'logistics', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (187, 'Sanders-Espinoza', 'software', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (188, 'Vargas Ltd', 'healthcare', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (189, 'Garcia LLC', 'healthcare', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (190, 'Burke, Martinez and Riggs', 'healthcare', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (191, 'Reed Group', 'fintech', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (192, 'Wood, Hunter and Peterson', 'fintech', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (193, 'Short-Garcia', 'fintech', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (194, 'Reid-Poole', 'healthcare', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (195, 'Hernandez, Thompson and Boyd', 'retail', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (196, 'Nelson, Morton and Medina', 'software', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (197, 'Marshall-Petersen', 'healthcare', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (198, 'Adams, Christian and Rivas', 'software', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (199, 'Ramirez Group', 'healthcare', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (200, 'Christensen PLC', 'retail', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (201, 'Barnett, Rogers and Snyder', 'healthcare', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (202, 'White-Lewis', 'retail', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (203, 'Peterson-Beard', 'logistics', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (204, 'Beard, Peters and Black', 'fintech', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (205, 'Miller Ltd', 'logistics', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (206, 'Freeman-Chang', 'healthcare', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (207, 'Alvarez, Joseph and West', 'fintech', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (208, 'Davis and Sons', 'retail', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (209, 'Holt-Torres', 'healthcare', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (210, 'Wood, Tran and Cooper', 'fintech', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (211, 'Pierce, Bell and Chavez', 'healthcare', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (212, 'King-Martinez', 'fintech', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (213, 'Stewart Ltd', 'fintech', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (214, 'Tapia, Vaughn and Lee', 'logistics', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (215, 'Washington, Hardy and Bray', 'fintech', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (216, 'Carlson, Hooper and Wall', 'healthcare', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (217, 'Perez-White', 'software', 'enterprise', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (218, 'Erickson and Sons', 'software', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (219, 'Williams-Brown', 'logistics', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (220, 'Terry-Martinez', 'retail', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (221, 'Garcia-Smith', 'software', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (222, 'Harrison-Alexander', 'logistics', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (223, 'Sheppard LLC', 'fintech', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (224, 'Wilson-Jones', 'healthcare', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (225, 'Jones-Soto', 'fintech', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (226, 'Hernandez PLC', 'healthcare', 'enterprise', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (227, 'Miller-Wright', 'retail', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (228, 'Duran, Obrien and Gibbs', 'logistics', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (229, 'Rowe Group', 'logistics', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (230, 'Kerr-Evans', 'software', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (231, 'Branch, Torres and Oliver', 'logistics', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (232, 'Choi, Garcia and Farmer', 'retail', 'startup', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (233, 'Clark, Guerrero and Moore', 'software', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (234, 'Arnold and Sons', 'fintech', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (235, 'Ortiz Ltd', 'logistics', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (236, 'Harrison, Johnson and Roberts', 'fintech', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (237, 'Warner-Gibson', 'fintech', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (238, 'Hall, Baker and Moody', 'logistics', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (239, 'Guerrero, Peck and Coleman', 'healthcare', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (240, 'Walker, Hernandez and Baker', 'fintech', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (241, 'Jones and Sons', 'software', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (242, 'Larson-Holloway', 'logistics', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (243, 'Gonzales-Harrison', 'software', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (244, 'Lyons-Bender', 'fintech', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (245, 'Fernandez, Kim and George', 'fintech', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (246, 'Navarro-Munoz', 'software', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (247, 'Davis Ltd', 'fintech', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (248, 'Matthews, Smith and Hubbard', 'logistics', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (249, 'Johnston-Hines', 'fintech', 'startup', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (250, 'Ruiz Ltd', 'software', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (251, 'Moon-White', 'software', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (252, 'Graham, Olsen and Costa', 'logistics', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (253, 'Bailey-Cook', 'software', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (254, 'Garcia, Martin and Jenkins', 'healthcare', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (255, 'Roberts-Landry', 'fintech', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (256, 'Johnson, Miller and King', 'software', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (257, 'Cordova Group', 'fintech', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (258, 'Bryan, Smith and Booth', 'software', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (259, 'Gutierrez-Lopez', 'software', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (260, 'Dean-Jimenez', 'logistics', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (261, 'Wolf-Harris', 'fintech', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (262, 'Anderson, Roberts and Gilmore', 'software', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (263, 'Martinez-Dudley', 'healthcare', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (264, 'Lloyd, Mckinney and Collins', 'retail', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (265, 'Tran Inc', 'retail', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (266, 'Gay Inc', 'logistics', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (267, 'Valentine-Holland', 'logistics', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (268, 'Jimenez Ltd', 'healthcare', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (269, 'Hicks-Hill', 'fintech', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (270, 'Baird-Sanchez', 'logistics', 'enterprise', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (271, 'Thomas, Lee and Greene', 'healthcare', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (272, 'Suarez, Shields and Hill', 'software', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (273, 'Morgan-French', 'software', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (274, 'Hoover-Campbell', 'retail', 'enterprise', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (275, 'Monroe-Carpenter', 'logistics', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (276, 'Burns, Hernandez and Ryan', 'logistics', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (277, 'Cook-Hines', 'logistics', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (278, 'Gibson-Morris', 'fintech', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (279, 'Pollard and Sons', 'software', 'enterprise', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (280, 'Reyes, Chase and Jenkins', 'software', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (281, 'Garner-Thornton', 'healthcare', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (282, 'Hughes-Alvarado', 'logistics', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (283, 'Pollard, Simpson and Johnson', 'fintech', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (284, 'Sanford, Rivera and Garcia', 'logistics', 'startup', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (285, 'Garcia-Lozano', 'logistics', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (286, 'Bowen Group', 'retail', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (287, 'Booker, Jones and Harrington', 'software', 'enterprise', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (288, 'Morgan-Schwartz', 'logistics', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (289, 'Miller, Murphy and Craig', 'logistics', 'startup', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (290, 'James, Stewart and Higgins', 'logistics', 'growth', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (291, 'Brennan-Johnson', 'retail', 'startup', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (292, 'Young Ltd', 'healthcare', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (293, 'Bright-Francis', 'retail', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (294, 'Good-Hodges', 'healthcare', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (295, 'Brennan, Wallace and Benson', 'logistics', 'startup', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (296, 'Williams Inc', 'logistics', 'startup', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (297, 'Howard-Jordan', 'retail', 'enterprise', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (298, 'Schmidt PLC', 'logistics', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (299, 'Sparks, Jackson and Miller', 'healthcare', 'enterprise', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (300, 'Harvey-Allen', 'software', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (301, 'Thomas, Murray and King', 'healthcare', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (302, 'Estrada-Nolan', 'retail', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (303, 'Santana-Byrd', 'software', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (304, 'Jones LLC', 'retail', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (305, 'Evans, Hayden and Vaughn', 'logistics', 'growth', 'Chicago');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (306, 'Bruce-Gonzalez', 'software', 'enterprise', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (307, 'Castaneda-Rodriguez', 'healthcare', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (308, 'Armstrong-Andrews', 'logistics', 'enterprise', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (309, 'Phillips, Spence and Barrett', 'healthcare', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (310, 'Smith-Grimes', 'software', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (311, 'Beltran, Lozano and Mcgee', 'fintech', 'growth', 'Denver');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (312, 'Parsons-Hall', 'fintech', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (313, 'Robinson-Lee', 'software', 'startup', 'Boston');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (314, 'Byrd-Le', 'healthcare', 'startup', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (315, 'Becker, Taylor and Davis', 'healthcare', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (316, 'Lucas, Parker and Alexander', 'fintech', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (317, 'Diaz, Anderson and Browning', 'fintech', 'growth', 'Atlanta');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (318, 'Burgess-Thompson', 'fintech', 'growth', 'Seattle');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (319, 'Buchanan LLC', 'retail', 'growth', 'Austin');
INSERT INTO dbo.Companies (company_id, company_name, industry, company_size, hq_city) VALUES (320, 'Shaw, Nelson and Martin', 'fintech', 'growth', 'Boston');



-- 
-- STEP 2: POPULATE DEPARTMENTS (1 per Company + Role Family)
-- 
INSERT INTO dbo.Departments (company_id, department_name)
SELECT DISTINCT 
    j.company_id,
    CASE LOWER(TRIM(j.role_family))
        WHEN 'operations'       THEN 'Operations'
        WHEN 'engineering'      THEN 'Engineering'
        WHEN 'data'             THEN 'Data & Analytics'
        WHEN 'product'          THEN 'Product'
        WHEN 'customer_success' THEN 'Customer Success'
        WHEN 'sales'            THEN 'Sales'
        ELSE 'General Operations'
    END AS department_name
FROM dbo.jobs j
WHERE NOT EXISTS (
    SELECT 1 
    FROM dbo.Departments d 
    WHERE d.company_id = j.company_id 
      AND d.department_name = CASE LOWER(TRIM(j.role_family))
        WHEN 'operations'       THEN 'Operations'
        WHEN 'engineering'      THEN 'Engineering'
        WHEN 'data'             THEN 'Data & Analytics'
        WHEN 'product'          THEN 'Product'
        WHEN 'customer_success' THEN 'Customer Success'
        WHEN 'sales'            THEN 'Sales'
        ELSE 'General Operations'
    END
);
GO

-- 
-- STEP 3: BACKFILL JOBS.DEPARTMENT_ID
-- 
UPDATE j
SET j.department_id = d.department_id
FROM dbo.jobs j
INNER JOIN dbo.Departments d 
    ON j.company_id = d.company_id
   AND d.department_name = CASE LOWER(TRIM(j.role_family))
        WHEN 'operations'       THEN 'Operations'
        WHEN 'engineering'      THEN 'Engineering'
        WHEN 'data'             THEN 'Data & Analytics'
        WHEN 'product'          THEN 'Product'
        WHEN 'customer_success' THEN 'Customer Success'
        WHEN 'sales'            THEN 'Sales'
        ELSE 'General Operations'
    END
WHERE j.department_id IS NULL;
GO

-- 
-- STEP 4: POPULATE RECRUITERS (Scaled by Application Volume)
-- 
WITH CompanyVolume AS (
    SELECT 
        c.company_id,
        COUNT(a.application_id) AS app_count
    FROM dbo.companies c
    INNER JOIN dbo.jobs j ON c.company_id = j.company_id
    INNER JOIN dbo.applications a ON j.job_id = a.job_id
    GROUP BY c.company_id
)
INSERT INTO dbo.Recruiters (company_id, recruiter_name, hire_date, termination_date)
SELECT 
    cv.company_id,
    CONCAT('Recruiter_', cv.company_id, '_', r_num.n) AS recruiter_name,
    DATEADD(
        DAY, 
        ABS(CHECKSUM(HASHBYTES('MD5', CONCAT(cv.company_id, '_', r_num.n)))) % 550, 
        CAST('2022-06-01' AS DATE)
    ) AS hire_date,
    NULL AS termination_date
FROM CompanyVolume cv
CROSS JOIN (VALUES (1), (2), (3)) AS r_num(n)
WHERE r_num.n <= CASE 
    WHEN cv.app_count > 50 THEN 3 
    WHEN cv.app_count > 20 THEN 2 
    ELSE 1 
END
AND NOT EXISTS (
    SELECT 1 FROM dbo.Recruiters r 
    WHERE r.company_id = cv.company_id 
      AND r.recruiter_name = CONCAT('Recruiter_', cv.company_id, '_', r_num.n)
);
GO

-- 
-- STEP 5: BACKFILL APPLICATIONS.RECRUITER_ID (Employer Boundary)
-- 
WITH RecruiterMapping AS (
    SELECT 
        a.application_id,
        r.recruiter_id,
        ROW_NUMBER() OVER (
            PARTITION BY a.application_id 
            ORDER BY r.recruiter_id
        ) AS rn
    FROM dbo.applications a
    INNER JOIN dbo.jobs j ON a.job_id = j.job_id
    INNER JOIN dbo.Recruiters r ON j.company_id = r.company_id
)
UPDATE a
SET a.recruiter_id = rm.recruiter_id
FROM dbo.applications a
INNER JOIN RecruiterMapping rm ON a.application_id = rm.application_id
WHERE rm.rn = 1 
  AND a.recruiter_id IS NULL;
GO


-- Evenly distribute applications across all recruiters within each company
with companyrecruiters as (
    select 
        recruiter_id,
        company_id,
        row_number() over (partition by company_id order by recruiter_id) - 1 as recruiter_idx,
        count(*) over (partition by company_id) as total_recruiters
    from dbo.recruiters
),
applist as (
    select 
        a.application_id,
        j.company_id,
        row_number() over (partition by j.company_id order by a.application_id) - 1 as app_idx
    from dbo.applications a
    inner join dbo.jobs j on a.job_id = j.job_id
)
update a
set a.recruiter_id = cr.recruiter_id
from dbo.applications a
inner join applist al on a.application_id = al.application_id
inner join companyrecruiters cr 
    on al.company_id = cr.company_id 
   and (al.app_idx % cr.total_recruiters) = cr.recruiter_idx;

-- 
-- STEP 6: POPULATE ASSESSMENTS (Screened + Stage Candidates)
-- 
INSERT INTO dbo.Assessments (application_id, assessment_date, assessment_type, score, result)
SELECT 
    a.application_id,
    DATEADD(
        DAY, 
        1 + (ABS(CHECKSUM(HASHBYTES('MD5', CAST(a.application_id AS VARCHAR(36))))) % 7), 
        a.applied_at
    ) AS assessment_date,
    CASE LOWER(TRIM(j.role_family))
        WHEN 'engineering'      THEN 'Coding & System Design Test'
        WHEN 'data'             THEN 'SQL & Data Analysis Case'
        WHEN 'product'          THEN 'Product Case Study'
        WHEN 'sales'            THEN 'Sales Presentation'
        WHEN 'operations'       THEN 'Operations & Problem Solving Assessment'
        WHEN 'customer_success' THEN 'Customer Service & Communication Assessment'
        ELSE 'General Aptitude Assessment'
    END AS assessment_type,
    CAST(a.score * 100.0 AS DECIMAL(5,2)) AS score,
    CASE 
        WHEN a.score >= 0.70 THEN 'Pass'
        ELSE 'Fail'
    END AS result
FROM dbo.applications a
INNER JOIN dbo.jobs j ON a.job_id = j.job_id
WHERE a.stage IN ('Screened', 'Interview', 'Offer') 
  AND a.score IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 
      FROM dbo.Assessments ass 
      WHERE ass.application_id = a.application_id
  );
GO




   -- Verify recruiter application counts for Company 10
select 
    r.company_id,
    a.recruiter_id,
    r.recruiter_name,
    r.hire_Date,
    count(a.application_id) as total_applications
from dbo.applications a
inner join dbo.recruiters r on a.recruiter_id = r.recruiter_id
where r.company_id = 10
group by r.company_id, a.recruiter_id, r.recruiter_name, r.hire_Date
order by a.recruiter_id;