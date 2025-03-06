 Create Database zomato;
 Use zomato;
 
# 1. Count of Restaurants by Country

SELECT 
    c.Country_Name,
    COUNT(r.Restaurant_ID) AS Restaurant_Count
FROM Restaurants r
JOIN Country_Code c 
    ON r.Country_Code = c.Country_Code
GROUP BY c.Country_Name
ORDER BY Restaurant_Count DESC;

# 2. Unique Cuisines Available

SELECT DISTINCT Cuisines FROM Restaurants;

# 3. Average Cost of Dining by Country

SELECT 
    c.Country_Name,
    ROUND(AVG(f.Average_Cost_for_Two), 2) AS Avg_Cost
FROM Fact_Table f
JOIN Country_Code c 
    ON f.Country_Code = c.Country_Code
GROUP BY c.Country_Name
ORDER BY Avg_Cost DESC;

# 4. Top 5 Most Popular Cuisines in Each Country

WITH CuisineRank AS (
    SELECT 
        c.Country_Name,
        r.Cuisines,
        COUNT(*) AS Cuisine_Count,
        RANK() OVER (PARTITION BY c.Country_Name ORDER BY COUNT(*) DESC) AS Rank
    FROM Restaurants r
    JOIN Country_Code c 
        ON r.Country_Code = c.Country_Code
    GROUP BY c.Country_Name, r.Cuisines
)
SELECT * FROM CuisineRank WHERE Rank <= 5;

# 5. Do Restaurants with Online Delivery Have Higher Ratings?

SELECT 
    CASE 
        WHEN f.Has_Online_Delivery = 'Yes' THEN 'Online Delivery'
        ELSE 'No Online Delivery'
    END AS Delivery_Status,
    ROUND(AVG(f.Aggregate_Rating), 2) AS Avg_Rating
FROM Fact_Table f
GROUP BY Delivery_Status;

# 6. Does Restaurant Cost Affect Ratings?

SELECT 
    CASE 
        WHEN Average_Cost_for_Two < 500 THEN 'Budget'
        WHEN Average_Cost_for_Two BETWEEN 500 AND 1500 THEN 'Mid-Range'
        ELSE 'Luxury'
    END AS Price_Category,
    ROUND(AVG(Aggregate_Rating), 2) AS Avg_Rating
FROM Fact_Table
GROUP BY Price_Category
ORDER BY Avg_Rating DESC;

#7. Top 5 Highest Rated Restaurants in Each Country

WITH TopRestaurants AS (
    SELECT 
        r.Restaurant_ID,
        r.Restaurant_Name,
        c.Country_Name,
        f.Aggregate_Rating,
        RANK() OVER (PARTITION BY c.Country_Name ORDER BY f.Aggregate_Rating DESC) AS Rank
    FROM Fact_Table f
    JOIN Country_Code c 
        ON f.Country_Code = c.Country_Code
    JOIN Restaurants r 
        ON f.Restaurant_ID = r.Restaurant_ID
)
SELECT * FROM TopRestaurants WHERE Rank <= 5;

# 8. Correlation Between Ratings & Customer Engagement

SELECT 
    f.Aggregate_Rating,
    COUNT(f.Votes) AS Vote_Count
FROM Fact_Table f
GROUP BY f.Aggregate_Rating
ORDER BY f.Aggregate_Rating DESC;

# 9. How Price Range Affects Online Delivery

SELECT 
    f.Price_Range,
    COUNT(CASE WHEN f.Has_Online_Delivery = 'Yes' THEN 1 END) AS Online_Delivery_Count,
    COUNT(f.Has_Online_Delivery) AS Total_Restaurants,
    ROUND((COUNT(CASE WHEN f.Has_Online_Delivery = 'Yes' THEN 1 END) * 100.0) / COUNT(f.Has_Online_Delivery), 2) AS Percentage
FROM Fact_Table f
GROUP BY f.Price_Range
ORDER BY f.Price_Range;