-- 1. Which menu items generate the most revenue for the restaurant?
SELECT * FROM menu_items;
SELECT * FROM order_details;

SELECT mi.item_name, SUM(mi.price) AS total_revenue
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.item_name
ORDER BY total_revenue DESC
LIMIT 5;

-- 2. What is the average revenue per order?
SELECT AVG(order_total) AS avg_revenue_per_order
FROM (
  SELECT od.order_id, SUM(mi.price) AS order_total
  FROM order_details od
  JOIN menu_items mi ON od.item_id = mi.menu_item_id
  GROUP BY od.order_id
) AS subquery;

-- 3. What is the restaurant's monthly revenue trend?
SELECT MONTHNAME(od.order_date) AS month, SUM(mi.price) AS total_revenue
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY month
ORDER BY FIELD(month, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');

-- 4. Are there any items with high sales but low revenue (potential loss leaders?)
SELECT mi.item_name, COUNT(od.item_id) AS total_sold, SUM(mi.price) AS total_revenue
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.item_name
HAVING total_revenue < 100
ORDER BY total_sold DESC;

-- 5. What percentage of total revenue comes from each item category?
SELECT mi.category, SUM(mi.price) AS category_revenue,
       (SUM(mi.price) / (SELECT SUM(price) FROM order_details od JOIN menu_items mi ON od.item_id = mi.menu_item_id)) * 100 AS revenue_percentage
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.category
ORDER BY revenue_percentage DESC;

-- 6. Which items have seen a decline in sales over the last 6 months?
SELECT mi.item_name, COUNT(od.item_id) AS total_sold
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
WHERE od.order_date BETWEEN CURDATE() - INTERVAL 6 MONTH AND CURDATE()
GROUP BY mi.item_name
HAVING total_sold < 10
ORDER BY total_sold ASC;

-- 7. What are the most frequent item combinations in a single order?
SELECT mi1.item_name AS item_1, mi2.item_name AS item_2, COUNT(*) AS times_ordered_together
FROM order_details od1
JOIN order_details od2 ON od1.order_id = od2.order_id AND od1.item_id < od2.item_id
JOIN menu_items mi1 ON od1.item_id = mi1.menu_item_id
JOIN menu_items mi2 ON od2.item_id = mi2.menu_item_id
GROUP BY item_1, item_2
ORDER BY times_ordered_together DESC
LIMIT 10;

-- 8. What are the top 5 best-selling items and their corresponding categories?
SELECT mi.item_name, mi.category, COUNT(od.item_id) AS total_sold
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY mi.item_name, mi.category
ORDER BY total_sold DESC
LIMIT 5;

-- 9. How does revenue vary by day of the week?
SELECT DAYNAME(od.order_date) AS day_of_week, SUM(mi.price) AS total_revenue
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- 10. What is the restaurant's total revenue growth rate over the past year?
SELECT (SUM(CASE WHEN YEAR(od.order_date) = YEAR(CURDATE()) THEN mi.price ELSE 0 END) /
       SUM(CASE WHEN YEAR(od.order_date) = YEAR(CURDATE()) - 1 THEN mi.price ELSE 0 END) - 1) * 100 AS revenue_growth_percentage
FROM order_details od
JOIN menu_items mi ON od.item_id = mi.menu_item_id;

