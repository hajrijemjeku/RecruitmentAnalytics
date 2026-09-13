/* ============================================================
   RECRUITMENT & HIRING ANALYTICS
   SQL Server Database Setup

   File: 01_database_setup.sql

   Purpose:
   - Reset and recreate the project database
   - Create the six original/source tables
   - Add source-table constraints and relationships
   - Create three new project tables
   - Alter existing tables with new columns
   - Add new relationships and constraints

   Database: JobRecruitmentDB
   ============================================================ */


/* ============================================================
   1. RESET DATABASE
   ============================================================ */

USE master;
GO

IF DB_ID('RecruitmentAnalytics') IS NOT NULL
BEGIN
    ALTER DATABASE RecruitmentAnalytics
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE RecruitmentAnalytics;
END;
GO


/* ============================================================
   2. CREATE DATABASE
   ============================================================ */

CREATE DATABASE RecruitmentAnalytics;
GO

USE RecruitmentAnalytics;
GO


/* ============================================================
   3. CREATE SOURCE TABLE: Companies
   ============================================================ */

CREATE TABLE dbo.Companies
(
    company_id INT NOT NULL,
    company_name NVARCHAR(200) NOT NULL,
    industry NVARCHAR(100) NOT NULL,
    company_size NVARCHAR(50) NOT NULL,
    hq_city NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Companies
        PRIMARY KEY (company_id)
);
GO


/* ============================================================
   4. CREATE SOURCE TABLE: Candidates
   ============================================================ */

CREATE TABLE dbo.Candidates
(
    candidate_id INT NOT NULL,
    candidate_name NVARCHAR(200) NOT NULL,
    year_experience INT NOT NULL,
    current_city NVARCHAR(100) NOT NULL,
    top_skill_area NVARCHAR(100) NOT NULL,
    summary NVARCHAR(1000) NULL,

    CONSTRAINT PK_Candidates
        PRIMARY KEY (candidate_id),

    CONSTRAINT CK_Candidates_Experience
        CHECK (year_experience >= 0)
);
GO


/* ============================================================
   5. CREATE SOURCE TABLE: Jobs
   ============================================================ */

CREATE TABLE dbo.Jobs
(
    job_id INT NOT NULL,
    company_id INT NOT NULL,
    posted_at DATETIME NOT NULL,
    title NVARCHAR(200) NOT NULL,
    role_family NVARCHAR(100) NOT NULL,
    level NVARCHAR(50) NOT NULL,
    location_type NVARCHAR(50) NOT NULL,
    employment_type NVARCHAR(50) NOT NULL,
    salary_low DECIMAL(12,2) NULL,
    salary_high DECIMAL(12,2) NULL,
    status NVARCHAR(50) NOT NULL,
    notes NVARCHAR(500) NULL,

    CONSTRAINT PK_Jobs
        PRIMARY KEY (job_id),

    CONSTRAINT CK_Jobs_Salary
        CHECK (
            salary_low IS NULL
            OR salary_high IS NULL
            OR salary_low <= salary_high
        )
);
GO


/* ============================================================
   6. CREATE SOURCE TABLE: Applications
   ============================================================ */

CREATE TABLE dbo.Applications
(
    application_id INT NOT NULL,
    job_id INT NOT NULL,
    candidate_id INT NOT NULL,
    applied_at DATETIME NOT NULL,
    source NVARCHAR(50) NOT NULL,
    stage NVARCHAR(50) NOT NULL,
    score DECIMAL(5,4) NULL,

    CONSTRAINT PK_Applications
        PRIMARY KEY (application_id),

    CONSTRAINT CK_Applications_Score
        CHECK (
            score IS NULL
            OR (score >= 0.00 AND score <= 1.00)
        )
);
GO


/* ============================================================
   7. CREATE SOURCE TABLE: Interviews
   ============================================================ */

CREATE TABLE dbo.Interviews
(
    interview_id INT NOT NULL,
    application_id INT NOT NULL,
    round_name NVARCHAR(100) NOT NULL,
    scheduled_at DATETIME NOT NULL,
    result NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_Interviews
        PRIMARY KEY (interview_id)
);
GO


/* ============================================================
   8. CREATE SOURCE TABLE: Offers
   ============================================================ */

CREATE TABLE dbo.Offers
(
    offer_id INT NOT NULL,
    application_id INT NOT NULL,
    offered_at DATETIME NOT NULL,
    base_salary DECIMAL(12,2) NOT NULL,
    accepted BIT NOT NULL,
    accepted_at DATETIME NULL,

    CONSTRAINT PK_Offers
        PRIMARY KEY (offer_id)
);
GO


/* ============================================================
   9. ADD FOREIGN KEY: Jobs → Companies
   ============================================================ */

ALTER TABLE dbo.Jobs
ADD CONSTRAINT FK_Jobs_Companies
    FOREIGN KEY (company_id)
    REFERENCES dbo.Companies(company_id);
GO


/* ============================================================
   10. ADD FOREIGN KEY: Applications → Jobs
   ============================================================ */

ALTER TABLE dbo.Applications
ADD CONSTRAINT FK_Applications_Jobs
    FOREIGN KEY (job_id)
    REFERENCES dbo.Jobs(job_id);
GO


/* ============================================================
   11. ADD FOREIGN KEY: Applications → Candidates
   ============================================================ */

ALTER TABLE dbo.Applications
ADD CONSTRAINT FK_Applications_Candidates
    FOREIGN KEY (candidate_id)
    REFERENCES dbo.Candidates(candidate_id);
GO


/* ============================================================
   12. ADD FOREIGN KEY: Interviews → Applications
   ============================================================ */

ALTER TABLE dbo.Interviews
ADD CONSTRAINT FK_Interviews_Applications
    FOREIGN KEY (application_id)
    REFERENCES dbo.Applications(application_id);
GO


/* ============================================================
   13. ADD FOREIGN KEY: Offers → Applications
   ============================================================ */

ALTER TABLE dbo.Offers
ADD CONSTRAINT FK_Offers_Applications
    FOREIGN KEY (application_id)
    REFERENCES dbo.Applications(application_id);
GO


/* ============================================================
   14. CREATE NEW TABLE: Departments
   ============================================================ */

CREATE TABLE dbo.Departments
(
    department_id INT IDENTITY(1,1)
        CONSTRAINT PK_Departments PRIMARY KEY,

    company_id INT NOT NULL,

    department_name NVARCHAR(100) NOT NULL,

    CONSTRAINT FK_Departments_Companies
        FOREIGN KEY (company_id)
        REFERENCES dbo.Companies(company_id)
);
GO


/* ============================================================
   15. CREATE NEW TABLE: Recruiters
   ============================================================ */

CREATE TABLE dbo.Recruiters
(
    recruiter_id INT IDENTITY(1,1)
        CONSTRAINT PK_Recruiters PRIMARY KEY,

    company_id INT NOT NULL,

    recruiter_name NVARCHAR(100) NOT NULL,

    hire_date DATE NOT NULL,

    termination_date DATE NULL,

    CONSTRAINT CK_Recruiters_Dates
        CHECK (
            termination_date IS NULL
            OR termination_date >= hire_date
        ),

    CONSTRAINT FK_Recruiters_Companies
        FOREIGN KEY (company_id)
        REFERENCES dbo.Companies(company_id)
);
GO


/* ============================================================
   16. CREATE NEW TABLE: Assessments
   ============================================================ */

CREATE TABLE dbo.Assessments
(
    assessment_id INT IDENTITY(1,1)
        CONSTRAINT PK_Assessments PRIMARY KEY,

    application_id INT NOT NULL,

    assessment_date DATE NOT NULL,

    assessment_type NVARCHAR(100) NOT NULL,

    score DECIMAL(5,2) NULL,

    result NVARCHAR(50) NOT NULL,

    CONSTRAINT CK_Assessments_Score
        CHECK (
            score IS NULL
            OR (score >= 0.00 AND score <= 100.00)
        ),

    CONSTRAINT FK_Assessments_Applications
        FOREIGN KEY (application_id)
        REFERENCES dbo.Applications(application_id)
);
GO


/* ============================================================
   17. ALTER JOBS: ADD DEPARTMENT COLUMN
   ============================================================ */

ALTER TABLE dbo.Jobs
ADD department_id INT NULL;
GO


/* ============================================================
   18. ADD FOREIGN KEY: Jobs → Departments
   ============================================================ */

ALTER TABLE dbo.Jobs
ADD CONSTRAINT FK_Jobs_Departments
    FOREIGN KEY (department_id)
    REFERENCES dbo.Departments(department_id);
GO


/* ============================================================
   19. ALTER APPLICATIONS: ADD RECRUITER COLUMN
   ============================================================ */

ALTER TABLE dbo.Applications
ADD recruiter_id INT NULL;
GO


/* ============================================================
   20. ADD FOREIGN KEY: Applications → Recruiters
   ============================================================ */

ALTER TABLE dbo.Applications
ADD CONSTRAINT FK_Applications_Recruiters
    FOREIGN KEY (recruiter_id)
    REFERENCES dbo.Recruiters(recruiter_id);
GO


/* ============================================================ 
   21. ALTER TABLE EXAMPLE: DROP COLUMN 
   ============================================================ */

ALTER TABLE dbo.Jobs 
DROP COLUMN notes; 
GO


/* ============================================================
   22. FINAL STRUCTURE CHECK
   ============================================================ */

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;
GO


/* ============================================================
   23. FINAL TABLE LIST
   ============================================================ */

SELECT
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
    AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

