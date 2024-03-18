# dbt_zero_to_hero

In the following code we will be implementing an ETL project where we will be loading data into a datawarehouse in this case it will be  SNOWFLAKE and then use DATA BUILD TOOL DBT to do data transformation and then use  POERBI  to do the vizualization .

The data we have is one big csv file which we will be modelling to create dimensional tables and fact tables where we will be creating relationships from our fact tables to our dimension tables.We will then have to visualzie the fact tables and whether the relationships have been detected in powerbi

We will then proceed to do dax calculations for our modelled data in powerbi.Rememember all these visualizations will be available in the dbt documentation.Remember you can just fork the repo to your machine and create an environmentand then afterwards you can generate the documentataion and serve to local host although everything that you need will be available.We will also discusiing ways on how to orchestrate the model we will discuss prons and cons of either framewroks and why we will proceed with the choosen one.

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
I have provided the data in this repo that will be used .Well  a question that you probably have is why we have t=an added column such as timestamp,well we will be creating  snapshots(well this are tables that we use to track the changes in our data,Whether we have changed a columns details such as product id it will keep track of that and the columns that you have deleted and any additional data that may there it must fall  within the schema of our data)

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

 then we will need to move into the project page using the `cd` command then we will be using the `dbt debug ` this will create a coonection to snowflake and  dbt .all the connections should pass but ote if you dont have git intalled in the machine and if maybe you are using windows this connection maya fail but in the end the connection will still be connected and it should wor ideally nonetheless.Then you will just use the command `code .` to open the code editoer installed in your machine .
 
 With this you have reached part on e of our whole project .isnt dbt amazing and simple,well if you have reaached  at this point clap for yourself you have really done amazing and if you have connected ubnsuccesfully well you can try to repeat the project again keenly or try to use another operating system such as linux .I have used both the windows and linux operating systems and found that they bothe work awesomely and you can try ton work with both,only some minor commands will change here and there but it will wotked effectively on my machine.

 We will first discuss some of the folders that will be visible in dbt once you create the connection 

 1.SNAPSHOT - This is form of like table that we create in dbt to track changes in dbt .we have the Slowly Chnaging Dimension 2 where we can chnage the attributes of a specific column .When we dont want to loose the old data , we use this type 2 changing dimension to track changes like when it was changed  and it also tracks deletion thus someone can track deletion in the data so of someone deletes data you will know and this can be used to track fraud cases or cases  where there is data manipulation.One can aslo make sure the schema  of data does not change for nnew data and you can set to fail if the schema changes making data cleanning simplified. We run using the command `dbt snapshot`

2.Seeds -This is a file that you upload to vs code a csv file that you upload from dbt to snowflake .Then it becomes seed  we run using the command dbt `dbt seed`

3. sources - wellits defined as an abstraction layer that is on top of input tables in the datawarehouses or in simple terms it defines where the table will be accessed from in the datawarehouse.It guides the model on where it will the data it will use 




