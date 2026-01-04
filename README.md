# Labmentix_Projects
**SQL querying, data preprocessing, Power BI visualization, Streamlit app development, and business intelligence insights.**
                                                                          
                                                                          **OLA_Ride_Insights**
**Problem Statement:**
The rise of ride-sharing platforms has transformed urban mobility, offering convenience and affordability to millions of users. OLA, a leading ride-hailing service, generates vast amounts of data related to ride bookings, driver availability, fare calculations, and customer preferences. However, deriving actionable insights from this data remains a challenge. To enhance operational efficiency, improve customer satisfaction, and optimize business strategies, this project focuses on analyzing OLA’s ride-sharing data. By leveraging data analytics, visualization techniques, and interactive applications, the goal is to extract meaningful insights that can drive data-informed decisions. The project will involve cleaning and processing raw ride data, performing exploratory data analysis (EDA), developing a dynamic Power BI dashboard, and creating a Streamlit-based web application to present key findings in an interactive and user-friendly manner.


**Insights**
**Cancellations**:
--  Almost 38% rides are lost due to cancellations
--  We can see cancellations are high on Monday, Tuesday and Wednesday
--  Out of total cancellations we can see
    --  47% Cancelled by driver 
    --  27% cancelled by customer
    --  26%  driver not found 
--We have vehicle breakdown cases of 1591 but they come under successful bookings
**Ratings**
--Customer Ratings are low for bike and ebike
--Driver ratings are low for primesedan and bike
**Revenue**
--We are losing 2.14 cr approx due to cancellations
--We lost 1.01 cr approx due to driver cancellations
--Driver not found 54.99 lakhs revenue lost
**Timing**:
--1-4 pm we can see the high rate of success bookings
--9-12 am Bookings are high and cancellations are high
**Vehicle type**
--We are earning more revenue by travelling less distance is through **auto** where  its avg_distance is 6.24 which is almost half of other vehicles but is in top 3 by revenue rate but     travelled  < 50% distance travelled by other vehicles. The cost of per km for auto is more than double compared to other types.
--Prime sedan and ebike stays on top 2  places based on the booking values. 
**Based on july month days**
--Revenue generation we can see **prime sedan** rank is in no1 position on Sunday,Monday,Tuesday 
--Wednesday and Thrusday **auto** is no 1
--Friday and Saturday **bike** is in no 1
--Check why prime sedan performance reduced drastically to 6 th position on Saturday
**Payments**
--We can see cash payments are high. Try to increase UPI by giving offers
