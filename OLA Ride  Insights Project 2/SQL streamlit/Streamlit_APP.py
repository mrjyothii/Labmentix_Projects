import streamlit as st
import pyodbc
import matplotlib.pyplot as plt
import plotly.express as px
from streamlit_option_menu import option_menu

# 1. As sidebar menu
with st.sidebar:
    selected = option_menu(
        menu_title="Main Menu", #required
        options=["SQL","PowerBI","Insights"],
        styles={"menu-title": {"font-size": "15px","font_weight": 700},
                "nav-link-selected": {"font-size": "13px"}}
    )

if selected == "Insights":
    with st.container(width ="stretch"):
        st.title("OLA rides insights",text_alignment="center")
        st.write("**Cancellations**")
        st.markdown("""        
                -   Almost 38% rides are lost due to cancellations.
                -   We can see cancellations are high on Monday, Tuesday and Wednesday.
                -   Out of total cancellations we can see: 47% Cancelled by driver,27% cancelled by customer,26%  driver not found.
                -   We have vehicle breakdown cases of 1591 but they come under successful bookings""")
    
        st.write("**Ratings**")
        st.markdown("""
                    -  Customer Ratings are low for bike and ebike
                    -  Driver ratings are low for primesedan and bike""")
        st.write("**Revenue**")
        st.markdown("""
                    -   We are losing 2.14 cr approx due to cancellations
                    -   We lost 1.01 cr approx due to driver cancellations
                    -   Driver not found 54.99 lakhs revenue lost""")
        st.write("**Timing**")
        st.markdown("""
                    -   1-4 pm we can see the high rate of success bookings
                    -   9-12 am Bookings are high and cancellations are high""")
        st.write("**Vehicle type**")
        st.markdown("""
                    -   We are earning more revenue by travelling less distance is through **auto** where  its avg_distance is 6.24 which is almost half of other vehicles but is in top 3 by revenue rate but travelled  < 50% distance travelled by other vehicles. The cost of per km for auto is more than double compared to other types.
                    -   Prime sedan and ebike stays on top 2  places based on the booking values.""")
        st.write("**Based on July month days**")
        st.markdown("""
                    -   Revenue generation we can see **prime sedan** rank is in no1 position on Sunday,Monday,Tuesday. 
                    -   Wednesday and Thrusday **auto** is no 1.
                    -   Friday and Saturday **bike** is in no 1.
                    -   Check why prime sedan performance reduced drastically to 6 th position on Saturday""")
        st.write("**Payments**")
        st.markdown("""
                    -   We can see cash payments are high. Try to increase UPI by giving offers""")
        st.subheader("Actionable Insights")
        st.markdown(""" 
                    -   Cancellations are to be taken care to increase Revenue. Mostly Driver and few Customer cancellations can be avoided 
                    -   Check the AC,Tracking issues and other issues to avoid cancellations from customer
                    -   Mention the capacity(limit of people) for bookings
                    -   Reduce cancellations between 9-12am and on Monday,Tuesday and Wednesday 
                    -   Increase Auto Ride_distance >20km as it is limted to <20km and its per km earning is 2x compared to other vehicles
                    -   Provide offers to encourage UPI payments""")



if selected == "SQL":
    st.title("SQL",text_alignment="center")

    Questions = ["1. Retrieve all successful bookings:",
    "2. Find the average ride distance for each vehicle type:",
    "3. Get the total number of cancelled rides by customers:",
    "4. List the top 5 customers who booked the highest number of rides:",
    "5. Get the number of rides cancelled by drivers due to personal and car-related issues:",
    "6. Find the maximum and minimum driver ratings for Prime Sedan bookings:",
    "7. Retrieve all rides where payment was made using UPI:",
    "8. Find the average customer rating per vehicle type:",
    "9. Calculate the total booking value of rides completed successfully:",
    "10. List all incomplete rides along with the reason",
    "11.Total Rides by Booking_status"
    ]


    conn = st.connection("sql") # Test connection
    selected_option = st.selectbox("Which Question would you like me to answer",Questions)
        
    if selected_option  == "1. Retrieve all successful bookings:":
        success = conn.query(
        """SELECT COUNT(*) AS Successful_booking 
        FROM OLA_DataSet 
        WHERE Booking_Status = 'Success'""")
        st.dataframe(success,hide_index=True)

    if selected_option  == "2. Find the average ride distance for each vehicle type:":
        avg_ride_distance = conn.query(
        """SELECT Vehicle_Type,
        ROUND(AVG(Ride_Distance),2) AS Avg_distance 
        FROM OLA_DataSet 
        WHERE Booking_Status = 'success' 
        GROUP BY Vehicle_Type
        ORDER BY Avg_distance""")
        avg_ride_distance.index += 1
        st.dataframe(avg_ride_distance)
        # Plot bar chart
        fig = px.bar(
        avg_ride_distance,
        x='Vehicle_Type',
        y='Avg_distance',
        text='Avg_distance',  # show value on top of bars
        title='Average Distance by Vehicle Type')
        # color='Avg_distance', # optional: color by rating
        #color_continuous_scale='Blues')
        st.plotly_chart(fig, use_container_width=True)

    if selected_option  == "3. Get the total number of cancelled rides by customers:":
        cancel_cust_rides = conn.query(
        """SELECT Count(*) as 'Rides canceled by customer' 
        FROM OLA_DataSet 
        WHERE Booking_Status = 'Canceled by customer'""")
        st.dataframe(cancel_cust_rides,hide_index=True)

    if selected_option  == "4. List the top 5 customers who booked the highest number of rides:":
        highest_cust_rides = conn.query(
        """SELECT TOP 5 Customer_ID,
        COUNT(Customer_ID) AS No_of_rides
        FROM OLA_DataSet 
        WHERE Booking_Status = 'success'
        GROUP BY Customer_ID
        ORDER BY No_of_rides DESC""")
        st.dataframe(highest_cust_rides,hide_index=True)

    if selected_option  == "5. Get the number of rides cancelled by drivers due to personal and car-related issues:":
        driver_cancel_rides = conn.query(
        """SELECT Count(*) as 'Rides canceled by driver' 
        FROM OLA_DataSet 
        WHERE Booking_Status = 'Canceled by driver' AND Canceled_Rides_by_Driver = 'Personal & Car related issue'"""
        )
        st.dataframe(driver_cancel_rides,hide_index=True)

    if selected_option  == "6. Find the maximum and minimum driver ratings for Prime Sedan bookings:":
        sedan_ratings = conn.query(
        """SELECT Vehicle_Type,
        MAX(Driver_Ratings) AS Max_Ratings, 
        MIN(Driver_Ratings) AS Min_Ratings 
        FROM OLA_DataSet 
        WHERE Booking_Status = 'Success' 
        GROUP BY Vehicle_Type 
        HAVING Vehicle_Type = 'Prime Sedan'"""
        )
        st.dataframe(sedan_ratings,hide_index=True)

    if selected_option  == "7. Retrieve all rides where payment was made using UPI:":
        UPI_payments = conn.query(
        """SELECT COUNT(*) AS UPI_Payments 
        FROM OLA_DataSet 
        WHERE Payment_Method = 'UPI'"""
        )
        st.dataframe(UPI_payments,hide_index=True)

    if selected_option  == "8. Find the average customer rating per vehicle type:":
        cust_ratings = conn.query(
        """SELECT Vehicle_Type,
        ROUND(AVG(Customer_Rating),3) AS Avg_customer_rating 
        FROM OLA_DataSet 
        GROUP BY Vehicle_Type"""
        )
        cust_ratings.index += 1
        st.dataframe(cust_ratings)
        # Plot line chart
        fig = px.line(
        cust_ratings,
        x='Vehicle_Type',
        y='Avg_customer_rating',
        markers=True,  # show points
        title='Average Ratings by Vehicle Type'
        )
        st.plotly_chart(fig, use_container_width=True)

    if selected_option  == "9. Calculate the total booking value of rides completed successfully:":
        Revenue = conn.query(
        """SELECT SUM(Booking_value) as Total_booking_value 
        FROM OLA_DataSet 
        WHERE Booking_Status = 'Success'"""
        )
        st.dataframe(Revenue,hide_index=True)

    if selected_option  == "10. List all incomplete rides along with the reason":
        incomplete_rides = conn.query(
        """SELECT DISTINCT(Incomplete_Rides_Reason),
        COUNT(*) OVER (PARTITION BY Incomplete_Rides_Reason) AS TOTAL
        FROM OLA_DataSet
        WHERE Incomplete_Rides = 'yes'
        UNION 
        SELECT 'TOTAL' as TOTAL,
        COUNT(*) OVER () AS TOTAL
        FROM OLA_DataSet
        WHERE Incomplete_Rides = 'yes'
        ORDER BY TOTAL """
        )
        incomplete_rides.index += 1
        st.dataframe(incomplete_rides)

    if selected_option  == "11.Total Rides by Booking_status":
        total_rides = conn.query(
        """ SELECT 
        sum(CASE WHEN Booking_status = 'Success' then 1 else 0 end) AS 'Success',
        sum(CASE WHEN Booking_status = 'Canceled by Customer' then 1 else 0 end) AS 'Canceled by Customer',
        sum(CASE WHEN Booking_status = 'Canceled by Driver' then 1 else 0 end) AS 'Canceled by Driver',
        Sum(CASE WHEN Booking_status = 'Driver Not Found' then 1 else 0 end) AS 'Driver Not Found'
        from OLA_DataSet"""
        )
        st.dataframe(total_rides,hide_index = True)

        labels = total_rides.columns
        sizes = total_rides.iloc[0]

        fig, ax = plt.subplots(figsize=(3, 3))
        ax.pie(
            sizes,
            labels=labels,
            autopct="%1.1f%%",
            startangle=90,
            textprops={'fontsize': 8}
        )
        ax.axis("equal")
        st.pyplot(fig)

import streamlit as st

if selected == "PowerBI":
    st.header("OLA insights with PowerBI",text_alignment="center")

    powerbi_report_url = (
        "https://app.powerbi.com/reportEmbed?reportId=b6f68a5b-962b-4eb8-951f-ed4758ca6051&autoAuth=true&ctid=6fdd89fc-5692-40ea-9147-b126edab3a49")
    st.components.v1.iframe(
        powerbi_report_url,
        height=500,
        scrolling=True
    )
    st.set_page_config(
        layout="wide",
        page_title="Power BI Dashboard"
    )