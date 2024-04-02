# dbt_zero_to_hero

DBT otherwise known as data build tool is a tool we use in the **modern data stack** otherwise known formally as **ELT** for transformation of data .In this repo we will just be looking at all the transformation that we can do to any data and we will learn best industry practices for using dbt and advantages of using this specific tool in our data pipelines for data engineers and analytics engineers.

The data we have is one large CSV file, which we will model to create dimensional tables and fact tables. We will establish relationships from our fact tables to our dimension tables. Then, we need to visualize the fact tables and ensure that the relationships have been detected in **Power BI.**

![overview](https://github.com/stilinsk/dbt_zero_to_hero/assets/113185012/45deddbc-78d5-4e5c-a7df-c6b5a11d83b8)

We will then proceed to perform DAX calculations for our modeled data in Power BI. Remember, all these visualizations will be available in the DBT documentation. You can simply fork the repo to your machine, create an environment, and then generate the documentation and serve it to localhost. However, everything you need will be available.

We will also discuss ways to orchestrate the model. We will discuss the pros and cons of different frameworks and why we will proceed with the chosen one.

I have provided the data in this repository that will be used. Now, a question that you may have is why we have an added column such as a timestamp. Well, we will be creating snapshots. These are tables that we use to track changes in our data. Whether we have changed a column's details, such as a product ID, it will keep track of that. It will also track any deleted columns and any additional data that may be present. However, all data must fall within the schema of our data.


##### pre -requisites for the project

1. Snowflake account
2. vscode
3. python =<3.11
4. powerbi
5. prior knowledge of data modelling techniques and knowledge preferrrably upto 3rd NF

We will start by creating  a snowflake account ,snowflake provieds a 30 daya free trial that you can just use for learning for this course and also they provide 400 dollar credit for the entire duration of th free trial ,when creating a free trial let the preference be th aws  and let the region be any ,but if you use the AWS cloud services it would be standard practice to set the same region for the aws and for the snowflake.This will definitely ease any future pipelines  you may want to create in future and you might want to use both aws cloud and snowflake as your data warehouse.


![DBT3](https://github.com/stilinsk/dbt_zero_to_hero/assets/113185012/3223cf36-7c4c-4587-ba6e-a50ea0f2f2ef)

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
We will then load the data thta i will also be providing for this course 


###### Connecting vscode to snowflake

We will be using vs code for this project and we will need to install python version greter or eqaul to 3.11 since 3.12 some of the packages that we will be needing for this project are still ot compatible.

dbt can be used in all the operating systems and the code is almost the same. we will be creating a dbt project folder in the desktop then we will need to create and activate the environment.
```
cd Desktop
mkdir course
cd course

python3 -m venv ( name of environment)  this case we assume we name our environment venv
venv\Scripts\activate
\(for linux/mac)   source venv/bin/activate

```
We will need to install the dbt snowflake package

`pip install dbt-snowflake==1.7.1`

we will need to initialize a dbt project folder in mc/linux we use 

`mkdir ~/.dbt`

in windows we use the following command

`mkdir ~/.dbt`

we will then create a dbt prject using the following code  

`dbt init dbtlearn`
after this we will navigate to the dbtlearn folder using the command `cd` and then use `dbt debug` to create the connection .Remember the roles,the warehouse the schema ,password that we used when creating the datawarehouse in snowflake and the inforamtion should be similar  after providing the correct details  the connection passes but note that if you don't have Git installed on your machine or if you are using Windows, this connection may fail initially. However, in the end, the connection should still be established and it should ideally work. Then, you will simply use the command code . to open the code editor installed on your machine, you should now be in vs code and  the connection must be set to the data warehouse .

Hope we have all reaches at this stage  and if you have then clap for yourself. and if you have not repeat the steps that we have carried out so far in this project and you should be good to go.



There are some of the folders that probably by now if you have open the text editor are visible to you. we will look at them and understand what they each entail.

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


11. **MATERIALIZATIONS**: Materializing tables involves determining how we will view the models in the data warehouse, and materializations include three main types:
   - **Table**: This type is used for creating the final dimensional tables and fact tables that we want to view as tables in our data warehouse.
   - **View**: The other type of materialization is the view, where these are tables that we want to retain in our data warehouse but are not as critical as we will not be actively using them, given that we already have the dimension and fact tables. For this project, as we will see in the `src` folder models, we will be materializing them as views.
   - **Ephemeral**: This type involves reducing the code to just a Common Table Expression (CTE), and we can delete this data from our data warehouse. This may be used in cases where we need to save on space and cost, such as with the original data from tables. However, one should be extremely cautious before implementing this, as it becomes permanent.

#### sources 
These is where we define and direct dbt to access our files and folders from in the datawarehouse

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
### MODELS
##### models/src/src_customers
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

we will just be selecting the above columns from our main dataset  and this will form part of our dim_customers table upon further cleaning and transformation.

##### models/src/src_dates
```
with raw_dates as(
    select * from {{source ('shop','dates')}}
)
select
Date

from raw_dates
```
we will just be selecting the above columns from our main dataset  and this will form part of our dim_dates table upon further cleaning and transformation.


##### models/src/src_products
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
we will just be selecting the above columns from our main dataset  and this will form part of our dim_products table upon further cleaning and transformation.

#### dimension tables models

##### models/dim/dim_customers
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
It selects all columns from the src_customers table using the ref() function to reference the source.

It selects specific columns from the src_customers CTE.
The NVL() function is used to replace any null values with the specified default value ('Anonymous') for the following columns: EmailName, District, City, State, Region, and Country.
Columns CustomerID, ZipCode, and TIMESTAMP_COLUMN are selected as is.

The {% if is_incremental() %} block is a conditional statement that checks if the current execution is incremental. If it is, the subsequent WHERE clause filters the data to include only records with a TIMESTAMP_COLUMN value greater than the maximum TIMESTAMP_COLUMN value from the src_customers table. This ensures that only newly updated or inserted records are included in incremental loads.

##### models/dim/dim_products
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

It selects all columns from the src_products table using the ref() function to reference the source.
The CTE serves as a data source for the main query.


It selects specific columns from the src_products CTE.
The NVL() function is used to replace any null values with the specified default value ('Anonymous') for the following columns: Product, Category, and Segment.

##### models/dim/dim_dates
```
WITH src_dates AS (
    SELECT 
        *,
        {{ dbt_utils.generate_surrogate_key(['Date']) }} AS date_id
    FROM 
        {{ ref("src_date") }}
    WHERE 
        Date IS NOT NULL -- Filter out rows with null dates
)
SELECT 
    date_id,
    Date,
    TO_DATE(
        CONCAT_WS('-', CAST(EXTRACT(YEAR FROM Date) AS STRING), 
                        CAST(EXTRACT(MONTH FROM Date) AS STRING), 
                        CAST(EXTRACT(DAY FROM Date) AS STRING)
        )
    ) AS sales_date
    
FROM
    src_dates
```

   - It selects all columns from the `src_date` table using the `ref()` function to reference the source.
   - The `dbt_utils.generate_surrogate_key(['Date'])` function generates a surrogate key for each date.
   - The `WHERE` clause filters out rows where the `Date` column is null.

   - It selects columns from the `src_dates` CTE.
   - The `date_id` column contains the surrogate keys generated for each date.
   - The `Date` column contains the original date values.
   - The `CONCAT_WS()` function concatenates the extracted year, month, and day components of the `Date` column into a string with the format 'YYYY-MM-DD'.
   - The `TO_DATE()` function converts the concatenated string back into a `DATE` data type.

Overall, this SQL code generates surrogate keys for dates and converts the `Date` column into a valid `DATE` data type with the format 'YYYY-MM-DD'. This transformation prepares the data for further analysis or visualization, ensuring consistency and compatibility with date-related operations. for this operation to work we will need to run `dbt deps`  to install the **dbt utils package** in the package.yml

#### Fact sales
##### models/fct/fact_sales
```
WITH fct_sales AS (
    SELECT 
        CustomerID,
        ProductID,
        {{ dbt_utils.generate_surrogate_key(['Date']) }} AS date_id,
        {{ dbt_utils.generate_surrogate_key(['Date','CustomerID','ProductID','Product','CampaignID']) }} as sales_id,
        UnitCost,  
        UnitPrice, 
        CampaignID
    FROM SHOP.RAW.SHOP
)

SELECT  DISTINCT
    fs.sales_id,
    c.CustomerID,
    p.ProductID,
    d.date_id,
    fs.UnitCost AS unit_cost, 
    fs.UnitPrice AS unit_price, 
    fs.CampaignID
FROM fct_sales fs
INNER JOIN {{ ref('dim_dates') }} d ON fs.date_id = d.date_id
INNER JOIN {{ ref('dim_products') }} p ON fs.ProductID = p.ProductID
INNER JOIN {{ ref('dim_customers') }} c ON fs.CustomerID = c.CustomerID

```

 It starts with a Common Table Expression (CTE) named `fct_sales`, where data is extracted from the `SHOP.RAW.SHOP` table.
   - Columns selected include `CustomerID`, `ProductID`, and `CampaignID`.
   - A surrogate key for dates is generated using `dbt_utils.generate_surrogate_key(['Date'])` and stored in the `date_id` column.
   - Unit cost (`UnitCost`) and unit price (`UnitPrice`) are selected for further analysis.

The main query selects distinct values from the following tables:
   - `dim_dates`: This dimension table likely contains details about dates, including the `date_id`.
   - `dim_products`: This dimension table likely contains details about products, including the `ProductID`.
   - `dim_customers`: This dimension table likely contains details about customers, including the `CustomerID`.

 The main query performs an inner join on the `fct_sales` CTE with each dimension table (`dim_dates`, `dim_products`, and `dim_customers`) based on their respective keys (`date_id`, `ProductID`, and `CustomerID`). This join combines the sales data with additional information from the dimension tables.

Overall, this code retrieves sales data from the `SHOP.RAW.SHOP` table, assigns surrogate keys for dates, and then enriches the sales data by joining it with dimension tables (`dim_dates`, `dim_products`, and `dim_customers`).

You may be asking why we are creating joins in all our tables and the fact is that we need to define relationships in our dataset and we do this by creating joins and also also as you xcan see we have only selected distinct columns that we will be using in our joins as this removes duplicates from our main fact table.This helps to optimize storage space in our data warehouse and optimize perfomance of our queries.


We would want to track changes in our customers table and we will need to create snapsots for this table as we will be using the type 2 slowly changing dimensions this keeps data of both old and new changes and tracks these changes ,conforms to the schema of the file and data formats and also any deltes that are made to the data in the customers table while in the data waehouse this becomes visible and this is good for tracking fraud cases  and tracking inconsistencies.

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

This code is a Jinja template used in a DBT project to define a snapshot named `scd_src_customers`. Here's a brief explanation of each part:

1. `{% snapshot scd_src_customers %}`: This line marks the beginning of the snapshot block named `scd_src_customers`. Snapshots are used to capture historical states of tables and track changes over time.

2. `config(...)`: This block sets configuration options for the snapshot. Here are the options specified:
   - `target_schema='DEV'`: Specifies the schema where the snapshot table will be created (in this case, the `DEV` schema).
   - `unique_key='CustomerID'`: Specifies the column(s) used as the unique identifier for each record in the snapshot (in this case, the `CustomerID` column).
   - `strategy='timestamp'`: Specifies the strategy for detecting changes in data. In this case, the strategy is based on timestamps.
   - `updated_at='TIMESTAMP_COLUMN'`: Specifies the column in the source data that contains timestamps indicating when each record was last updated.
   - `invalidate_hard_deletes=True`: Indicates that hard deletes (permanent removal of records) should be invalidated in the snapshot.

3. `select * FROM {{ source('shop', 'customers') }}`: This SQL query selects all columns from the `customers` table in the `shop` source. The `source()` function is used to reference tables from the defined sources in the DBT project.

4. `{% endsnapshot %}`: This line marks the end of the snapshot block.

Overall, this code defines a DBT snapshot named `scd_src_customers`, which captures historical states of the `customers` table from the `shop` source. The configuration options specify how changes in the data will be tracked and stored in the snapshot table.

#### Tests

We will be implemnting some data quality tests on our data and we will be using a package commonly known as **dbt great expectations** and its an opensource library for implementing these data tests in dbt.[Link to dbt-expectations GitHub Repository](https://github.com/calogica/dbt-expectations).we will need to install the package using the `dbt deps` command nad after installing it then we can implement some of the tests .the tests that we have are defined in the **schema.yml** and  the tests are as followa

![repo](https://github.com/stilinsk/dbt_zero_to_hero/assets/113185012/4e5f3e49-3124-4863-84d0-47d9a70d9aef)


#### MACROS

##### macros/no_nulls_in_columns
These are singular tests that are are linked to the tests folder

```{% macro no_nulls_in_columns(model) %}
    SELECT * FROM {{ model }} WHERE
    {% for col in adapter.get_columns_in_relation(model) -%}
        {{ col.column }} IS NULL OR
    {% endfor %}
    FALSE
{% endmacro %}
```
we will be iterating through a= the fact sales table and look and assertaing that there are no nulls in our model fact sales and we will need to link it to a file in tests folder for the macro to work

#### TESTS

##### tests/no_nulls_in_fact_sales
```
{{ no_nulls_in_columns(ref('fct_sales'))}}
```
#### packages.yml
```
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
    
  - package: calogica/dbt_expectations
    version: [">=0.9.0", "<0.10.0"]
    # <see https://github.com/calogica/dbt-expectations/releases/latest> for the latest version tag
```
to install we run the `dbt deps` command

#### dbt_projects.yml
This is where we define the connection of all our folder in dbt and we define also the materializations of our project 
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
### schema.yml
This file contains the documentation that you may want (this is used to describe columns and any transformations that may happen) and also defines the normal tests we have in our data ,a very important file and the documentation will be visible when we generate it and serve it on localhost
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

#### ORCHESTRATION
While performing data engineering projects, such processes can be automated, and there are various factors that influence the orchestration of a particular project. You can find information on this in the following [article](https://www.linkedin.com/feed/update/urn:li:activity:7180776074341982209/), which will provide clear insights.

In the following project, we will be orchestrating our workflow using Dagster. Although there are other orchestration tools available, I will also explain why we have chosen this particular tool. We will focus on some of the tools that offer this integration.
 ##### Apache airflow
- The installation can be challenging; to run it normally on our machine, it requires a Docker container, which can be challenging to set up.
- If run through the cloud, it becomes very expensive. Running it on an Amazon Redshift container incurs charges that can become prohibitive, especially when keeping the Airflow instance running for different data synchronizations at various time frames.
- Airflow does not integrate seamlessly with the dbt instance; it primarily focuses on running jobs, making it difficult to debug projects and identify errors. Thus, it is not an ideal tool to use. However, recent technological advancements have addressed this challenge, allowing integration with **Cosmos** to overcome this issue.
- On the positive side, this tool is open source, making it easy to use.

##### Prefect
- It has a simple integration
- it is also opensource

##### Azure data factory
- does not really have a good integration
- its nnot open source

##### dbt cloud
- Has a very tight and good integration and you can use the commands that you want to put  and use
- not open source its paid for


##### DAGSTER
- Has a very great UI and very user friendly
- very easy to debug
- Its opensource
- No prior codig of jobs and tasks thuas with  jsut very fwe lines of code it is up and running


##### dbt orchestration
5o you have forked the repo you will need to go one directory upwards  to the dbt project folder using the follwoing command

```
cd..
```
You will find the `requirements.txt` file using the command  ` pip install -r requirements.txt` ,in the requirements.txt we are installing the 
```
dbt-snowflake
dagster-dbt
dagster-webserver

```

While still in the dbt_project folder you  execute the follwong command to start the dagster ptoject

```
dagster-dbt project scaffold --project-name dbt_dagster_project --dbt-project-dir=dbtlearn

```
You then need to to the `dbtlearn` folder and do a `dbt debug ` command to start the project.

Go back to the main folder `dbt_project` folder  and then move to the new dagster project using the following command
```
cd dbt_dagster_project

```
You will then move to the  schedules.py` file and uncomment the schedules ,you will then save the project  and then while still in this folder file path run the following commands to start the instance of the dagster project

```

$env:DAGSTER_DBT_PARSE_PROJECT_ON_LOAD = 1
dagster dev

```
![dbts](https://github.com/stilinsk/dbt_zero_to_hero/assets/113185012/52d9d206-edde-483c-8764-1aec6f2b40d4)

The dagster UI will be accessible from localhost and you can move there and start orchestrating the project

#### Powerbi
After the materialization of the data models, the data is already in Snowflake. You will just need to integrate Snowflake with Power BI and load the data models. After loading, you can view the data model page, and all the connections should be connected with the dataset. If this is not the case, then you may have missed a step, and you will need to repeat the project more carefully.
  
![DBT1](https://github.com/stilinsk/dbt_zero_to_hero/assets/113185012/c45fc3f4-8270-476d-8bff-b0f79f9b52f3)


 i have done some basic visaulizations,you can try to do more advanced visualizations of the project


 All the best in this project and hope now this gives you a good basic understanding of DBT to now use it comfortbaly in the future for your own projects.

 ![power](https://github.com/stilinsk/dbt_zero_to_hero/assets/113185012/342b421e-0384-4d28-bd13-fce9fcbb1fe3)


