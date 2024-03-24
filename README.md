# dbt_zero_to_hero

In the following code, we will implement an ETL project where we load data into a data warehouse, in this case, Snowflake. Then, we will use the Data Build Tool (DBT) for data transformation and Power BI for visualization.


The data we have is one large CSV file, which we will model to create dimensional tables and fact tables. We will establish relationships from our fact tables to our dimension tables. Then, we need to visualize the fact tables and ensure that the relationships have been detected in Power BI.


We will then proceed to perform DAX calculations for our modeled data in Power BI. Remember, all these visualizations will be available in the DBT documentation. You can simply fork the repo to your machine, create an environment, and then generate the documentation and serve it to localhost. However, everything you need will be available.

We will also discuss ways to orchestrate the model. We will discuss the pros and cons of different frameworks and why we will proceed with the chosen one.
#### Prerequisites for the project
1.vs code ( either using linux/max/windows)

2.snowflake account (its a free account valid for 30 days)

3.dbt( but we will install it tin the code editor

4.Powerbi

5.Dagster ( this will be our preffered tool for orchestration)

We will need to create the snowflake account  then create the datawarehouse and thn the schema in snowflake an then the table .Now we will be using the code below
```
-- Use an admin role
USE ROLE ACCOUNTADMIN;

-- Create the `transform` role
CREATE ROLE IF NOT EXISTS data;
GRANT ROLE data TO ROLE ACCOUNTADMIN;

-- Create the default warehouse if necessary
CREATE WAREHOUSE IF NOT EXISTS COMPUTE;
GRANT OPERATE ON WAREHOUSE COMPUTE TO ROLE data;

-- Create the `dbt` user and assign to role
CREATE USER IF NOT EXISTS deta
  PASSWORD='1234'SHOP.RAW.SHOP
  LOGIN_NAME='deta'
  MUST_CHANGE_PASSWORD=FALSE
  DEFAULT_WAREHOUSE='COMPUTE'
  DEFAULT_ROLE='data'
  DEFAULT_NAMESPACE='SHOP.RAW'
  COMMENT='DBT user used for data transformation';
GRANT ROLE data to USER deta;

-- Create our database and schemas
CREATE DATABASE IF NOT EXISTS SHOP;
CREATE SCHEMA IF NOT EXISTS SHOP.RAW;

-- Set up permissions to role `transform`
GRANT ALL ON WAREHOUSE COMPUTE TO ROLE data; 
GRANT ALL ON DATABASE SHOP to ROLE data;
GRANT ALL ON ALL SCHEMAS IN DATABASE SHOP to ROLE data;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE SHOP to ROLE data;
GRANT ALL ON ALL TABLES IN SCHEMA SHOP.RAW to ROLE data;
GRANT ALL ON FUTURE TABLES IN SCHEMA SHOP.RAW to ROLE data;


ALTER TABLE shop.raw.shop
ADD COLUMN timestamp_column TIMESTAMP;


UPDATE shop.raw.shop
SET timestamp_column = CURRENT_TIMESTAMP;


CREATE TABLE IF NOT EXISTS SHOP.RAW.SHOP (
    ProductID INT,
    Date DATE,
    CustomerID INT,
    CampaignID INT,
    Units INT,
    Product VARCHAR(255),
    Category VARCHAR(255),
    Segment VARCHAR(255),
    ManufacturerID INT,
    Manufacturer VARCHAR(255),
    UnitCost DECIMAL(18, 2),
    UnitPrice DECIMAL(18, 2),
    ZipCode INT,
    EmailName VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    Region VARCHAR(255),
    District VARCHAR(255),
    Country VARCHAR(255)
);
```

I have provided the data in this repository that will be used. Now, a question that you may have is why we have an added column such as a timestamp. Well, we will be creating snapshots. These are tables that we use to track changes in our data. Whether we have changed a column's details, such as a product ID, it will keep track of that. It will also track any deleted columns and any additional data that may be present. However, all data must fall within the schema of our data.

### Python and virtual env environments set up on windows/mac and linux
We will need to download the python installer if you still dont have this is the link you will be using [This link](https://www.python.org/downloads/).

whichever operating system you are using create a folder and then create and activate an environment

```
---in windows 
python3 -m venv (name of environment)

name of env\Scripts\activate

---in linux 

python3 -m venv (name of env)
source (name of env)/bin/activate

```
Web will need to create a dbt file also i windows we will be using this 

`mkdir ~/.dbt`

In linux

`mkdir %userprofile%\.dbt`

 we will then create a dbt project in our case ideally would be 

 `dbt init dbtlearn`

Then we will need to navigate to the project page using the cd command. After that, we will use the dbt debug command. This will establish a connection to Snowflake and DBT. All the connections should pass, but note that if you don't have Git installed on your machine or if you are using Windows, this connection may fail initially. However, in the end, the connection should still be established and it should ideally work. Then, you will simply use the command code . to open the code editor installed on your machine.
 
 With this you have reached part on e of our whole project .isnt dbt amazing and simple,well if you have reaached  at this point clap for yourself you have really done amazing and if you have connected ubnsuccesfully well you can try to repeat the project again keenly or try to use another operating system such as linux .I have used both the windows and linux operating systems and found that they bothe work awesomely and you can try ton work with both,only some minor commands will change here and there but it will wotked effectively on my machine.

 We will first discuss some of the folders that will be visible in dbt once you create the connection 

1. **SNAPSHOT**: This is a table-like construct created in DBT to track changes in data. We use Slowly Changing Dimension 2 when we want to preserve old data. It tracks changes, including when data was altered or deleted. This feature can be useful for detecting fraud or data manipulation. Additionally, it ensures the schema of the data remains consistent for new entries, simplifying data cleaning. We run snapshots using the command `dbt snapshot`.

2. **SOURCES**: This is an abstraction layer on top of input tables in the data warehouse. Essentially, it defines where the table data will be accessed from in the data warehouse, guiding the model on where to find the data it needs.

3. **SEEDS**: These are CSV files uploaded from DBT to Snowflake via VS Code. Once uploaded, they become seeds. We run seeds using the command `dbt seed`.

4. **TESTS**: There are generic and singular tests. Generic tests include unique values, not null, accepted values, and relationships. Singular tests can be created and linked to macros. An example is a test that iterates over all columns in a table to ensure there are no null values.

5. **SCHEMA.YML**: This file is crucial for the project. It contains additional information such as column descriptions (visible in documentation) and test placements.

6. **MACROS**: These are Jinja templates used in SQL and created in macro files. Macros can be used as singular tests by linking to another file in the tests folder where the macro test is defined.

7. **PACKAGES.YML**: This is where we install packages used in the project, such as dbt utils and Great Expectations.

8. **ASSETS**: This file is not visible in the project's path but needs to be added, along with the connection to the `dbt_project.yml` path. It may contain an overview of the project after documentation in the localhost, such as a model's photo, accurately representing the project.

9. **DBT_PROJECTS.YML**: This file defines the entire project, including configurations, setting paths, and defining materializations (e.g., table, view, or ephemeral). Materializations depend on visualization needs; for dimensional tables, set materializations as tables, while for original tables not used in visualizations, set materializations as ephemeral. Incremental materializations are suitable for tables likely to have additional data.

10. **HOOKS AND EXPOSURES**: These are connections that link the BI tool to a webpage or visualization tool. This integration allows visualization to be part of the project and deployed through tools and exposures.

These are some of the pprojets that we will be implememting in the above project and we will be covering them in depth in subsquent projects

### MODELS
The data is in one big csv file  and so follwoing th procedures of data normalisaiton to the 3rd Normal Form we will be creating 3 tables and adding specific columns as we start data modelling

**This is the code used in this project**
#### src_customers
``models\src\src_customers``:
```
with raw_customers as (select * from {{source ('shop','customers')}}
)
select 
CustomerID,
EmailName,
City,
State,
Region,
District,
Country,
ZipCode,
TIMESTAMP_COLUMN



from raw_customers
```

#### src_products
`` models\src\src_products``:
```
with raw_products as(
    select * from {{source ('shop','products')}}
)
select
ProductID,
Product,
Category,
Segment
from raw_products
```
#### src_products
``models\src\src_customers``:
```
with raw_dates as(
    select * from {{source ('shop','dates')}}
)
select
Date

from raw_dates
```

The  above are source tables that are used to create  the original tables from the bigger csv file. we will then start creating the dimensional tables that we  will be loading to the BI tool for visualization

#### dim_customers
``models\dim\dim_customers``:
```
WITH src_customers AS (
    SELECT 
        *
    FROM {{ ref("src_customers") }}
)
SELECT  
    CustomerID,
    NVL(EmailName, 'Anonymous') AS EMAIL,
    NVL(District, 'Anonymous') AS District,
    NVL(City, 'Anonymous') AS City,
    NVL(State, 'Anonymous') AS State,
    NVL(Region, 'Anonymous') AS Region,
    NVL(Country, 'Anonymous') AS Country,
    ZipCode,
    TIMESTAMP_COLUMN  
FROM src_customers 
{% if is_incremental() %}
WHERE TIMESTAMP_COLUMN > (SELECT MAX(TIMESTAMP_COLUMN) FROM src_customers)
{% endif %}
```
The code above retrieves the column values, renames the columns, and then replaces any null values in each column with the word "anonymous", ensuring there are no nulls in the specified columns. As you can see, Jinja templates are used to reference our column

#### dim_products

``models\dim\dim_products``:
```
with src_products as (
   SELECT 
        *
    
    
     from {{ ref("src_products") }}
)
select 
   ProductID,
    NVL(Product, 'Anonymous') AS Product,
    NVL(Category, 'Anonymous') AS Category,
    NVL(Segment, 'Anonymous') AS Segment
   
FROM src_products

```
we also have created the dim_products using theabove columns and also replacing nulls using the word anonymous

#### dim_dates
``models\dim\dim_dates.sql``:
```
WITH src_dates AS (
    SELECT 
        *,
        {{ dbt_utils.generate_surrogate_key(['Date']) }} AS date_id
    FROM 
        {{ ref("src_date") }}
    WHERE 
        Date IS NOT NULL -- Filter out rows with null SHIP_DATE
)
SELECT 
    date_id,
    Date,
    EXTRACT(YEAR FROM Date) AS sales_year,
    EXTRACT(MONTH FROM Date) AS sales_month,
    EXTRACT(DAY FROM Date) AS sales_day
    
FROM
    src_dates
```
 This CTE adds a new column date_id, generated using the dbt_utils.generate_surrogate_key() function, which creates a surrogate key based on the values in the Date column. Rows where the Date column is null are filtered out.

The main query selects columns from the src_dates CTE and performs additional transformations:

date_id: The generated surrogate key for each date.
Date: The original date value from the source table.
sales_year: Extracts the year component from the Date column.
sales_month: Extracts the month component from the Date column.
sales_day: Extracts the day component from the Date column.


### fact table(fact_sales)
`` models\fct\fct_sales``
```
WITH fct_sales AS (
    SELECT 
        CustomerID,
        ProductID,
        {{ dbt_utils.generate_surrogate_key(['Date']) }} AS date_id,
       
        UnitCost AS unit_cost,  
        UnitPrice AS unit_price, 
        CampaignID
    FROM SHOP.RAW.SHOP
)

SELECT distinct
    c.CustomerID,
    p.ProductID,
    d.date_id,
   
    fs.unit_cost, 
    fs.unit_price, 
    fs.CampaignID
FROM fct_sales fs
INNER JOIN {{ ref('dim_dates') }} d ON fs.date_id = d.date_id
INNER JOIN {{ ref('dim_products') }} p ON fs.ProductID = p.ProductID
INNER JOIN {{ ref('dim_customers') }} c ON fs.CustomerID = c.CustomerID

```
Columns selected include CustomerID, ProductID, and CampaignID.
A surrogate key for dates is generated using dbt_utils.generate_surrogate_key(['Date']) and stored in the date_id column.
Unit cost (UnitCost) and unit price (UnitPrice) are selected for further analysis.
The main query selects distinct values from the following tables:

dim_dates: This dimension table likely contains details about dates, including the date_id.
dim_products: This dimension table likely contains details about products, including the ProductID.
dim_customers: This dimension table likely contains details about customers, including the CustomerID.
The main query performs an inner join on the fct_sales CTE with each dimension table (dim_dates, dim_products, and dim_customers) based on their respective keys (date_id, ProductID, and CustomerID). This join combines the sales data with additional information from the dimension tables.

#### snapshots
We will be creating a snapshot to track historical changes in our customers table

```
{% snapshot scd_src_customers %}

{{
   config(
       target_schema='DEV',
       unique_key='CustomerID',
       strategy='timestamp',
       updated_at='TIMESTAMP_COLUMN',
       invalidate_hard_deletes=True
   )
}}

select * FROM {{ source('shop', 'customers') }}

{% endsnapshot %}
```
 Jinja template used in a DBT project to define a snapshot named scd_src_customers. Here's a brief explanation of each part:

{% snapshot scd_src_customers %}: This line marks the beginning of the snapshot block named scd_src_customers. Snapshots are used to capture historical states of tables and track changes over time.

config(...): This block sets configuration options for the snapshot. Here are the options specified:

target_schema='DEV': Specifies the schema where the snapshot table will be created (in this case, the DEV schema).
unique_key='CustomerID': Specifies the column(s) used as the unique identifier for each record in the snapshot (in this case, the CustomerID column).
strategy='timestamp': Specifies the strategy for detecting changes in data. In this case, the strategy is based on timestamps.
updated_at='TIMESTAMP_COLUMN': Specifies the column in the source data that contains timestamps indicating when each record was last updated.
invalidate_hard_deletes=True: Indicates that hard deletes (permanent removal of records) should be invalidated in the snapshot.
select * FROM {{ source('shop', 'customers') }}: This SQL query selects all columns from the customers table in the shop source. The source() function is used to reference tables from the defined sources in the DBT project.

{% endsnapshot %}: This line marks the end of the snapshot block.

Overall, this code defines a DBT snapshot named scd_src_customers, which captures historical states of the customers table from the shop source. The configuration options specify how changes in the data will be tracked and stored in the snapshot table.


#### Sources.yml
```
version: 2

sources:
  - name: shop
    schema: raw
    tables:
      - name: products
        identifier: SHOP

      - name: dates
        identifier: SHOP

      - name: customers
        identifier: SHOP
        loaded_at_field: timestamp_column
        freshness:
          warn_after: {count: 1, period: hour}
          error_after: {count: 24, period: hour}
```
it directs our model the loactions where it will be getting the data from in the model


#### dbt_project.yml
briefly details the outine of our project as i had already detailes above including the materealizations
```


# Name your project! Project names should contain only lowercase characters
# and underscores. A good package name should reflect your organization's
# name or the intended use of these models
name: 'dbtlearn'
version: '1.0.0'
config-version: 2

# This setting configures which "profile" dbt uses for this project.
profile: 'dbtlearn'

# These configurations specify where dbt should look for different types of files.
# The `model-paths` config, for example, states that models in this project can be
# found in the "models/" directory. You probably won't need to change these!
model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]
asset-paths: ["assets"]

clean-targets:         # directories to be removed by `dbt clean`
  - "target"
  - "dbt_packages"


# Configuring models
# Full documentation: https://docs.getdbt.com/docs/configuring-models

# In this example config, we tell dbt to build all models in the example/
# directory as views. These settings can be overridden in the individual model
# files using the `{{ config(...) }}` macro.
models:
  dbtlearn:
    # Config indicated by + and applies to all files under models/example/
    dim:
      +materialized: table
    fct:
      +materialized: table
```
#### macros (custom generic tests)
`macro\no_nulls_in_columns`

```
{% macro no_nulls_in_columns(model) %}
    SELECT * FROM {{ model }} WHERE
    {% for col in adapter.get_columns_in_relation(model) -%}
        {{ col.column }} IS NULL OR
    {% endfor %}
    FALSE
{% endmacro %}
```
`tests\no_nulls_in_fct_sales`

``{{ no_nulls_in_columns(ref('fct_sales'))}}``
The above code macro is made to a similar tests that iterates over the fct table and looks for nulls in my table .this is one way in which you can create custom generic tests in our data

#### Packages.yml
```
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
    
  - package: calogica/dbt_expectations
    version: [">=0.9.0", "<0.10.0"]
```
The dbt utils is there as we have used it to create  the surrogate key for the dim_dates and fact_sales while the dbt_expectations we have used it for creating further tests that we will see in the schema.yml.Keep in mind of how thorough i have done the documentation,be as descriptive as possible

#### schema.ym (defining tests and also documentation)
```
version: 2
models:
  - name: fct_sales
    tests:
      - dbt_expectations.expect_table_row_count_to_equal_other_table:
          compare_model: ref('dim_customers')
    columns:
      - name: CUSTOMERID
        description: This is a unique identifier for each customer. It is a numeric
          field and is used to join the fact sales table with the customer
          dimension table.
        data_type: NUMBER
      - name: PRODUCTID
        description: This is a unique identifier for each product sold. It is a foreign
          key that links to the product dimension table.
        data_type: NUMBER
      - name: DATE_ID
        description: This column represents the unique identifier for the date of the
          sale. It is generated by applying the MD5 hash function to the date.
          If the date is null, a placeholder value
          '_dbt_utils_surrogate_key_null_' is used instead.
        data_type: VARCHAR
      - name: UNIT_COST
        description: This column represents the cost of a single unit of a product. It
          is derived from the 'UnitCost' column in the raw shop data.
        data_type: NUMBER
      - name: UNIT_PRICE
        description: This column represents the price per unit of the product sold. It
          is derived from the 'UnitPrice' column in the raw shop data.
        data_type: NUMBER
      - name: CAMPAIGNID
        description: The CAMPAIGNID column represents the unique identifier for the
          marketing campaign associated with each sale. This ID can be used to
          link sales data with specific marketing campaigns.
        data_type: NUMBER
    description: "The fct_sales model is a fact table that contains sales data. It
      includes the following columns: CustomerID, ProductID, date_id, unit_cost,
      unit_price, and CampaignID. The model is created by joining the raw sales
      data from the SHOP.RAW.SHOP source with the dim_dates, dim_products, and
      dim_customers dimension tables from the SHOP.DEV schema. The date_id
      column is created by hashing the Date column from the raw sales data. If
      the Date column is null, a placeholder value is used for the hash. The
      unit_cost and unit_price columns are directly taken from the raw sales
      data. The CustomerID, ProductID, and CampaignID columns are also taken
      from the raw sales data, but they are used to join with the dimension
      tables to ensure that only valid sales data is included in the model."
  - name: dim_customers
    columns:
      - name: CUSTOMERID
        description: The CUSTOMERID column is a unique identifier for each customer.
          This is a primary key for the dim_customers table.
        data_type: NUMBER
        tests:
          - not_null
      - name: EMAIL
        description: The EMAIL column contains the email addresses of the customers. If
          the email address is not available, the value is set to 'Anonymous'.
        data_type: VARCHAR
      - name: DISTRICT
        description: The DISTRICT column represents the district where the customer
          resides. If the district information is not available, the value is
          set to 'Anonymous'.
        data_type: VARCHAR
      - name: CITY
        description: The city where the customer resides. If the city is not provided,
          the value will be 'Anonymous'.
        data_type: VARCHAR
      - name: STATE
        description: The STATE column represents the state where the customer resides.
          If the state information is not available, the value is set to
          'Anonymous'.
        data_type: VARCHAR
      - name: REGION
        description: The REGION column represents the geographical region where the
          customer is located. If the region information is not available, the
          value is set to 'Anonymous'.
        data_type: VARCHAR
        tests:
          - accepted_values:
              values:
                - East
                - West
                - Central
      - name: COUNTRY
        description: The COUNTRY column represents the country where the customer
          resides. If the country information is not available, the value is set
          to 'Anonymous'.
        data_type: VARCHAR
      - name: ZIPCODE
        description: The ZIPCODE column contains the postal code for the customer's
          location. This data is sourced from the src_customers table in the
          SHOP.DEV schema. If the original data is null, the ZIPCODE will be set
          to 'Anonymous'.
        data_type: NUMBER
      - name: TIMESTAMP_COLUMN
        description: This column represents the timestamp when the record was created or
          last updated. It is useful for tracking changes over time.
        data_type: TIMESTAMP_NTZ
  - name: dim_products
    columns:
      - name: PRODUCTID
        description: This is the unique identifier for each product. It is a primary key
          in the dim_products model and is used to link to other tables in the
          database.
        data_type: NUMBER
      - name: PRODUCT
        description: This column contains the name of the product. If the product name
          is not available, the value is set to 'Anonymous'.
        data_type: VARCHAR
      - name: CATEGORY
        description: This column contains the category to which the product belongs. If
          the category is not available, the value is set to 'Anonymous'.
        data_type: VARCHAR
        tests:
          - not_null
      - name: SEGMENT
        description: The 'SEGMENT' column represents the market segment to which the
          product belongs. If the segment information is not available, the
          value is set to 'Anonymous'.
        data_type: VARCHAR
    description: ""
  - name: dim_dates
    description: "The 'dim_dates' model is a transformation of the 'src_date' source
      table from the 'SHOP.DEV' database. It is designed to provide a dimension
      table for dates, which can be used in sales analysis. The model includes
      the following columns: 'date_id', 'Date', 'sales_year', 'sales_month', and
      'sales_day'. The 'date_id' column is a unique identifier for each date,
      generated using the MD5 hash function. The 'Date' column is the original
      date from the source table. The 'sales_year', 'sales_month', and
      'sales_day' columns are extracted from the 'Date' column using the
      DATE_PART function. The model filters out any rows from the source table
      where the 'Date' is NULL."
    columns:
      - name: DATE_ID
        description: A unique identifier for each date. It is generated using the MD5
          hash function on the date. If the date is null, a placeholder value
          '_dbt_utils_surrogate_key_null_' is used instead.
        data_type: VARCHAR
      - name: DATE
        description: This column represents the date of the sales transaction. It is
          extracted from the 'src_date' table in the 'SHOP.DEV' database. The
          column values are not null and are of date data type.
        data_type: DATE
      - name: SALES_YEAR
        description: This column represents the year extracted from the 'Date' column in
          the source data. It is used to analyze sales data on a yearly basis.
        data_type: NUMBER
      - name: SALES_MONTH
        description: The 'SALES_MONTH' column represents the month of the sale. It is
          extracted from the 'Date' column of the 'src_date' table in the
          'SHOP.DEV' database. The value ranges from 1 to 12, where 1 represents
          January and 12 represents December.
        data_type: NUMBER
      - name: SALES_DAY
        description: This column represents the day part of the date. It is extracted
          from the 'Date' column in the source table using the DATE_PART
          function.
        data_type: NUMBER
```
 look  at the tests that i have implemented
 ```
(dbt) C:\Users\stilinski\Documents\dbt_project\dbtlearn>dbt test
09:33:45  Running with dbt=1.7.9
09:33:46  Registered adapter: snowflake=1.7.1
09:33:47  Found 7 models, 1 snapshot, 5 tests, 3 sources, 0 exposures, 0 metrics, 781 macros, 0 groups, 0 semantic models
09:33:47
09:33:53  Concurrency: 1 threads (target='dev')
09:33:53
09:33:53  1 of 5 START test accepted_values_dim_customers_REGION__East__West__Central .... [RUN]
09:34:00  1 of 5 PASS accepted_values_dim_customers_REGION__East__West__Central .......... [PASS in 6.74s]
09:34:00  2 of 5 START test dbt_expectations_expect_table_row_count_to_equal_other_table_fct_sales_ref_dim_customers_  [RUN]
09:34:08  2 of 5 PASS dbt_expectations_expect_table_row_count_to_equal_other_table_fct_sales_ref_dim_customers_  [PASS in 8.34s]
09:34:08  3 of 5 START test no_nulls_in_fact_sales ....................................... [RUN]
09:34:14  3 of 5 PASS no_nulls_in_fact_sales ............................................. [PASS in 6.12s]
09:34:14  4 of 5 START test not_null_dim_customers_CUSTOMERID ............................ [RUN]
09:34:19  4 of 5 PASS not_null_dim_customers_CUSTOMERID .................................. [PASS in 4.26s]
09:34:19  5 of 5 START test not_null_dim_products_CATEGORY ............................... [RUN]
09:34:23  5 of 5 PASS not_null_dim_products_CATEGORY ..................................... [PASS in 4.37s]
09:34:23
09:34:23  Finished running 5 tests in 0 hours 0 minutes and 36.24 seconds (36.24s).
09:34:23
09:34:23  Completed successfully
09:34:23
09:34:23  Done. PASS=5 WARN=0 ERROR=0 SKIP=0 TOTAL=5
```

#### assets
we willl add an assets folder and add the layout guide of the project it may be infrom of a picture that as you will see in the project how my layout will be .For us it will be  an overview.png

we then create ``models\overview.md` and  code the following
```
{% docs __overview__ %}
# shop pipeline

Hey, welcome to our shop data pipeline documentation!

Here is the schema of our input data:
![input schema](assets/overview.png)

{% enddocs %}
```
We will be adding exposures 


### dbt orchestration
 There are many ways to orchestrate data pipelines in data engineering,Dbt can integrate in many orchestration tools and thus very favourable to use as as transformation tool.we will discuss the following ways of orchestrating these data pipelines.
 
 1 **Apache Airflow**
 
 - The installation can be challenging -Remember if we are not running it on cloud such as using aws to run a cluster we will then have to run it on docker.Also even after setting it to run  we have to  create the dags for our project to run smoothly.
 
 - Does not really integrate with dbt it only does  the dbt run commands and  incase of fails it does not really check for  the specific models thT Hve failed thus not ideal ,however you can use  **cosmos**  to run dbt this solves this issue.

2 .**Prefect**

- it has simple integration 

- it  is opensource

3.**Azure data factory**

- its really good

- does not have a tight integration


**dbt cloud**

- very good and you can run the commands you wants any command thus very goood integration

- it is not opensource ,it is paid for

  **dagster**
  
- Easy to debug and to run commands

- Has a great UI very user friendly and even a begginner can use it comfortably

- very easy integration as you will see in the below lines of code how easy i will integrate it
 
- No need of coding the dags as everything has been done for you you will just need to set the orchestration time and then run it

 






