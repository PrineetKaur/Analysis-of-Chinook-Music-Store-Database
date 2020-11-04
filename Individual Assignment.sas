libname Chinook "C:\Users\pbhurji\Desktop\Course Materials\4) Business Reporting Tools (Matthijs Meire) [DBMS,SQL,Tablaeu]\Datasets for Assignments\Chinook dataset-20200923";

/*****************/
/****FINANCIAL****/
/*****************/

/*What about company sales (and the evolution over the years, or eg per month)? Make sure to accurately sort your results*/

PROC SQL;
title "Yearly Trend of Invoices";
SELECT Year(datepart(InvoiceDate)) as Year, Count(DISTINCT(b.InvoiceID)) 'Nbr_of_Orders', 
		Sum(b.Quantity)/Count(DISTINCT(b.InvoiceID)) 'Avg_Nbr_Tracks_per_Order', 
		Sum(b.UnitPrice)/Count(DISTINCT(b.InvoiceID)) 'Avg_Revenue_per_Order' 
	FROM chinook.invoice_items as b, chinook.invoices as a
	WHERE a.invoiceID = b.invoiceID
	GROUP BY Year; 
QUIT;


PROC SQL;
title 'Monthy Sales and Number of Invoices';
SELECT DISTINCT(MONTH(DATEPART(InvoiceDate))) as Month, Year(DATEPART(InvoiceDate)) as Year, 
		Sum(TOTAL) as TotalSales, Count(InvoiceID) as Nbr_of_Invoices
	FROM chinook.invoices
	GROUP BY Month, Year
	ORDER BY Year, Month;
QUIT;

/*How many purchases are made per invoice?*/

PROC SQL;
title 'Revenue and Quantity per Invoice';
SELECT DISTINCT(InvoiceID) as Invoice_ID, Count(Quantity) as PurchasesMade, Sum(UnitPrice) as OrderCost
	FROM chinook.invoice_items
	GROUP BY InvoiceID;
QUIT;

PROC SQL;
title 'Overview of Invoices';
SELECT Count(DISTINCT(InvoiceID)) as Nbr_of_Orders, Sum(Quantity)/Count(DISTINCT(InvoiceID)) as Average_QuantityPerOrder, SUM(UnitPrice)/Count(DISTINCT(InvoiceID)) as Average_RevenuePerOrder
	FROM chinook.invoice_items; 
QUIT;

/*Summary of the complete Sales Data*/

PROC SQL;
title 'Overall Sales Overview';
SELECT Count(Distinct(a.InvoiceID)) 'Nbr_of_Orders(Invoices)', Count(Distinct(a.CustomerID)) 'Nbr_of_Customers', 
	   Count(Distinct(b.TrackID)) 'Nbr_TracksSold', Sum(b.Quantity) 'Total_Quantity', Sum(a.Total) 'Total_Revenue', 
	   Count(Distinct(A.BillingCountry)) 'Nbr_of_Countries', 
	   int(max(datepart(a.invoicedate)) - min(datepart(a.invoicedate)))/365.25 'Total_Years'
	FROM chinook.invoices as a, chinook.invoice_items as b
	WHERE a.invoiceID = b.invoiceID; 
QUIT;


/*****************/
/****CUSTOMERS****/
/*****************/

/*How many customers do we have? Are they company clients or not?*/

PROC SQL;
title 'No. of Customers per Company';
SELECT Count(CUSTOMERID) as Number_of_Customers, Company 
	FROM chinook.customers
	GROUP BY Company;
QUIT; 

/*Give insight into the tenure of customers (how long are they already with the company).*/

PROC SQL outobs=10;
title 'Top 10 Customers by Tenure';
SELECT CustomerID, Count(InvoiceID) as Number_Of_Orders, Max(InvoiceDate) as Most_Recent_Order format = DATETIME7. , Min(InvoiceDate) as First_Order format = datetime7., int((Max(Datepart(InvoiceDate)) - Min(Datepart(InvoiceDate))))/365.25 as Tenure,  Mean(Total) as Average_Sales
	FROM chinook.invoices
	GROUP BY CustomerID
	ORDER BY Tenure DESC;
QUIT;

/*Where are our customers located and what is our biggest market (sales per market)? Note that a market may also be US/Europe/Asia.*/

PROC SQL;
title 'Customer distribution Countrywise';
SELECT DISTINCT(a.Country), Count(a.CustomerID) as Number_Of_Customers, Sum(b.Total) as Total, 
		case when a.country = 'USA' or a.country = 'Canada' or a.country = 'Brazil' or a.country = 'Argentina' or a.country = 'Chile' then 'Americas'
          	 when a.country = 'France' or a.country = 'Germany' or a.country = 'Spain' or a.country = 'Poland' or a.country = 'United Kingdom' or a.country = 'Portugal' or a.country = 'Czech Republic' or a.country = 'Austria' or a.country = 'Hungary' or a.country = 'Finland' or a.country = 'Belgium' or a.country = 'Italy' or a.country = 'Sweden' or a.country = 'Denmark' or a.country = 'Norway' or a.country = 'Netherlands' or a.country = 'Ireland' then 'Europe'
			 else 'Asia' end as Region                                                                                       
	FROM chinook.customers as a, chinook.invoices as b
	GROUP BY Country
	ORDER BY Total desc;
QUIT;

PROC SQL;
title 'Customer distribution Regionwise';
SELECT Count(b.InvoiceID) as Number_Of_Orders, Sum(b.Total) as Total, 
		case when a.country = 'USA' or a.country = 'Canada' or a.country = 'Brazil' or a.country = 'Argentina' or a.country = 'Chile' then 'Americas'
             when a.country = 'France' or a.country = 'Germany' or a.country = 'Spain' or a.country = 'Poland' or a.country = 'United Kingdom' or a.country = 'Portugal' or a.country = 'Czech Republic' or a.country = 'Austria' or a.country = 'Hungary' or a.country = 'Finland' or a.country = 'Belgium' or a.country = 'Italy' or a.country = 'Sweden' or a.country = 'Denmark' or a.country = 'Norway' or a.country = 'Netherlands' or a.country = 'Ireland' then 'Europe'
			 else 'Asia' end as Region                                                                                       
	FROM chinook.customers as a, chinook.invoices as b
	GROUP BY Region
	ORDER BY Total desc;
QUIT;

/************************************/
/****INTERNAL BUSINESS PROCESSING****/
/************************************/

/*Give insight into the genres, tracks and media types that are bought most/least*/

PROC SQL;
title 'Insights on Genres, Tracks and Media types';
SELECT DISTINCT (a.Quantity) as Nbr_SongCopiesSold, 
		b.name as TrackName, b.Composer as TrackComposer, 
		(b.Milliseconds)/60000 as Song_Minutes, (b.Bytes)/1000000 as Megabytes, 
		c.Name as MediaType, f.Genre as AlbumGenre, I.title as AlbumTitle, g.Name as TrackGenre
	FROM chinook.invoice_items as a, chinook.tracks as b, chinook.media_types as c, chinook.playlist_track as d, 
		 chinook.playlists as e, chinook.album_genre as f, chinook.ALBUMS as I, chinook.genres as g
	WHERE a.trackId = b.trackId 
		and b.mediatypeid = c.mediatypeid 
		and b.trackID = d.trackID 
		and d.playlistid = e.playlistid 
		and b.albumID = i.albumID 
		and i.albumID = f.albumID 
		and b.genreID = g.genreID
	GROUP BY TrackName;
QUIT;

/*Yearly Purchasing Trend of High Priced Tracks (i.e Unit Price = 1.99 or != 0.99)*/

PROC SQL;
title 'Yearly purchase trend of High Price Tracks';
SELECT year(datepart(c.invoicedate)) as Year, count(a.invoiceID) 'Nbr_Tracks', b.unitprice
	FROM chinook.invoice_items as a, chinook.tracks as b, chinook.invoices as c
	WHERE a.trackid = b.trackid and a.invoiceid = c.invoiceid
	GROUP BY b.UnitPrice, Year
	Having b.UnitPrice > 1;
QUIT;

/*Are there tracks that have no sales? How many bytes do we save by deleting them?*/

PROC SQL;
title 'List of Unsold Songs';
SELECT unique(b.trackID) 'Track_ID', b.name 'Track_Name', (b.bytes)/1000000 'Track_Size_in_MB'
	FROM chinook.tracks as b
	WHERE b.trackID NOT IN (SELECT trackID FROM chinook.invoice_items);
QUIT;

PROC SQL;
title 'Bytes Saved by Deleting Unsold Tracks';
SELECT count(unique(b.trackID)) 'Number of Unsold Tracks', sum((b.bytes)/1000000) 'Total_Bytes_Saved in MB'
	FROM chinook.tracks as b
	WHERE b.trackID NOT IN (SELECT trackID FROM chinook.invoice_items);
QUIT;

/* Are there any characteristics related to these tracks? (Analyzed as per AlbumID, MediaType and GenreID)*/

PROC SQL outobs=5;
title 'Top 5 Albums with MAX Unsold Songs';
SELECT b.albumid as AlbumID, count(b.albumid) as Nbr_UnsoldSongs
	FROM chinook.tracks as b
	WHERE b.trackID NOT IN (SELECT trackID FROM chinook.invoice_items)
	GROUP BY b.albumid
	ORDER BY 2 desc;
QUIT;

PROC SQL outobs=5;
title 'Top 5 Genres with MAX Unsold Songs';
SELECT b.genreid as GenreID, count(b.genreid) as Nbr_UnsoldSongs
	FROM chinook.tracks as b
	WHERE b.trackID NOT IN (SELECT trackID FROM chinook.invoice_items)
	GROUP BY b.genreid
	ORDER BY 2 desc;
QUIT;

PROC SQL outobs=5;
title 'Top 5 MediaTypes with MAX Unsold Songs';
SELECT b.mediatypeid as MediaTypeID, count(b.mediatypeid) as Nbr_UnsoldSongs
	FROM chinook.tracks as b
	WHERE b.trackID NOT IN (SELECT trackID FROM chinook.invoice_items)
	GROUP BY b.mediatypeid
	ORDER BY 2 desc;
QUIT;

/*****************/
/****EMPLOYEES****/
/*****************/

/*How many employees do we have, how many are about to retire (age > 60), how long are they in the company?*/

PROC SQL;
title 'Total number of Employees';
SELECT COUNT(employeeID)
	FROM chinook.employees;
QUIT;

PROC SQL;
title 'Employees about to Retire';
SELECT employeeID, Lastname, Firstname, title as Employee_Title
	FROM chinook.employees 
	WHERE (floor(yrdif(datepart(birthdate),today(),"AGE"))) >= 60;
QUIT;

PROC SQL;
title 'Employee Tenure Data';
SELECT employeeID, Lastname, Firstname, title as Employee_Title, 
		abs(int((Datepart(hiredate)) - (Datepart(today())))/365.25) as Tenure_of_Emp
	FROM chinook.employees ;
QUIT;

/*Country wise employee performance (helps understand which employee performs better where)*/

PROC SQL;
title 'Employee Performance across Countries';
SELECT unique(a.FirstName) 'First Name', a.LastName 'Last Name', 
		a.EmployeeID, COUNT(c.InvoiceID) 'Orders(Invoices made)', 
		Count(DISTINCT(C.CustomerID)) 'Nbr_CustomersServed', Sum(c.Total) 'Revenue_Generated', 
		Sum(c.Total)/COUNT(c.InvoiceID) 'Avg_Revenue per Order', c.BillingCountry 'Billing_Country'
	FROM chinook.EMPLOYEES as a, chinook.CUSTOMERS as b, chinook.INVOICES as c
	WHERE a.employeeID = b.supportrepid and c.customerID = b.customerID
	GROUP BY a.employeeID, c.BillingCountry
	ORDER BY a.employeeID;
QUIT;

/*How many sales does each of the salespeople have? How many sales does each of the supervisors have? What areas do they serve?*/

PROC SQL;
title 'Total Sales done by each Salesperson';
SELECT b.supportRepID as EmployeeID, count(distinct(a.InvoiceID)) as Invoices_Made, Sum(a.Total) as TotalSales
	FROM chinook.invoices as a, chinook.customers as b 
	WHERE a.customerID = b.customerID
	GROUP BY b.supportrepID;
QUIT;

PROC SQL;
title 'Total Sales for Supervisors (Sales Manager & General Manager)';
SELECT count(distinct(a.InvoiceID)) as Invoices_Made, Sum(a.Total) as TotalSales
	FROM chinook.invoices as a, chinook.customers as b 
	WHERE a.customerID = b.customerID;
QUIT;

/*Overall employee performance over the years*/

PROC SQL;
title 'Summary of Employee Performance';
SELECT unique(a.FirstName) 'First Name', a.LastName 'Last Name', a.EmployeeID, COUNT(c.InvoiceID) 'Orders(Invoices made)', Count(DISTINCT(C.CustomerID)) 'Customers served', Sum(c.Total) 'Revenue Generated', Sum(c.Total)/COUNT(c.InvoiceID) 'Average revenue per order'
	FROM chinook.EMPLOYEES as a, chinook.CUSTOMERS as b, chinook.INVOICES as c
	WHERE a.employeeID = b.supportrepid and c.customerID = b.customerID
	GROUP BY a.employeeID;
QUIT;


/*************************************/
/****KEY STRATEGIC RECOMMENDATIONS****/
/*************************************/

PROC SQL;
title'Table for Purchase Strategy';
	SELECT distinct g.Name as Genre_name, count(i.invoiceId) as Nbr_of_Orders, i.billingcountry as Country
		from chinook.playlists as p,
			 chinook.playlist_track as pt,
			 chinook.genres as g,
			 chinook.tracks as t,
			 chinook.invoice_items as itm,
			 chinook.invoices as i
	where p.playlistID = pt.playlistID
		and g.genreID = t.genreID
		and pt.trackID = t.trackID
		and itm.trackID = t.trackID
		and itm.invoiceID = i.invoiceID
		and  i.billingcountry = 'USA'
	GROUP BY g.Name
	ORDER BY 2 desc;
QUIT;


PROC SQL;
title'Table for Product Sales Strategy';
SELECT Sales_Type,count(invoiceID) as Count_of_Product_Purchased
	FROM 
		(SELECT invoiceID, "Single Track Purchase" as Sales_Type
			FROM chinook.invoice_items
			GROUP BY invoiceID
			HAVING count(distinct TrackID) = 1
		UNION
		SELECT invoiceID, "Multiple Track Purchase" as Sales_Type
			FROM chinook.invoice_items
			GROUP BY invoiceID
			HAVING count(distinct TrackID) ne 1)
GROUP BY Sales_Type;
QUIT;


PROC SQL OUTOBS=20;
title'Table for New Product Development';
	SELECT distinct g.Name as Genre_name, a.Name as Artist_Name, count(i.invoiceId) as Nbr_of_Orders
		from chinook.playlists as p,
			 chinook.playlist_track as pt,
			 chinook.genres as g,
			 chinook.tracks as t,
			 chinook.invoice_items as itm,
			 chinook.invoices as i,
			 chinook.artists as a,
			 chinook.albums as alb
	where p.playlistID = pt.playlistID
		and g.genreID = t.genreID
		and pt.trackID = t.trackID
		and itm.trackID = t.trackID
		and itm.invoiceID = i.invoiceID
		and a.artistID = alb.artistID
		and alb.albumID = t.albumID
		and  i.billingcountry = 'Canada'
	GROUP BY a.Name
	ORDER BY 3 desc;
QUIT;

QUIT;

PROC SQL outobs=10;
title'Table for Operational Efficiency';
SELECT DISTINCT(a.Country), Sum(b.Total) as Total_Sales                                                                                     
	FROM chinook.customers as a, chinook.invoices as b
	GROUP BY Country
	ORDER BY Total_Sales desc;
QUIT;

PROC SQL outobs=5;
title 'Table1 for Marketing Campaigns (Top 5 Countries with Least Customers)';
SELECT DISTINCT(a.Country), Count(a.CustomerID) as Number_Of_Customers                                                                                    
	FROM chinook.customers as a, chinook.invoices as b
	GROUP BY Country
	ORDER BY 2;
QUIT;

PROC SQL;
title'Table2 for Marketing Campaigns (Customers for Target Campaigns)';
SELECT FirstName,LastName,Country
	FROM chinook.customers
WHERE Country IN("Austria","Finland","Spain","Chile", "Norway"); 
QUIT;


PROC SQL outobs=5;
title'Table for Loyalty Rewards';
SELECT DISTINCT i.customerID, c.FirstName as First_Name, c.LastName as Last_Name, 
			 int((Max(Datepart(InvoiceDate)) - Min(Datepart(InvoiceDate))))/365.25 as Loyalty_Period,
			 Count(InvoiceID) as Number_Of_Orders
	FROM chinook.invoices as i,
		 chinook.customers as c
	WHERE i.customerID = c.customerID
	GROUP BY i.CustomerID
	ORDER BY Loyalty_Period DESC;
QUIT;


PROC SQL;
title'Table for Product Marketing Strategy';
SELECT mt.Name as Media_Type_Name, count(distinct t.TrackID) as Nbr_of_Tracks_Sold
	FROM chinook.Tracks as t,
		 chinook.Media_Types as mt
	WHERE t.MediaTypeID = mt.MediaTypeID
	GROUP BY 1
	ORDER BY 2 desc;
QUIT;


PROC SQL;
title'Table for Employee Recognition';
SELECT b.supportRepID as EmployeeID, count(distinct(a.InvoiceID)) as Invoices_Made, Sum(a.Total) as TotalSales
	FROM chinook.invoices as a, chinook.customers as b, chinook.employees as c
	WHERE a.customerID = b.customerID
	GROUP BY b.supportrepID;
QUIT;


PROC SQL;
title'Table for Customer Service';
SELECT DISTINCT e.employeeID as SupportRepID, e.title as Title, e.country as Country, e.Firstname, e.Lastname, 
	year(today()) - year(datepart(e.BirthDate)) as Age, abs(int((Datepart(hiredate)) - (Datepart(today())))/365.25) as Tenure_of_Agent, Sum(i.Total) as Total_Sales
	FROM chinook.employees as e,
		 chinook.customers as c,
		 chinook.invoices as i
	WHERE e.employeeID = c.supportRepID
		AND c.customerID = i.customerID
		AND title contains "Sales Support Agent"
	GROUP BY 1;
QUIT;









