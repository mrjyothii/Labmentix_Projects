import numpy as np
import pandas as pd
import streamlit as st
import matplotlib.pyplot as plt


df = pd.read_csv("cleaned_new.csv")

# ---------------------------
# Page Config
# ---------------------------


page = st.sidebar.selectbox("Select Page",["Home", "Analysis", "Output"])

if page == "Home":
    st.header("Real Estate Investment Analysis",text_alignment="center")
    st.subheader("Business Objective")
    st.write("""
    -   Identify good properties to invest in
    -   Understand factors affecting property prices""")
    
    st.subheader("Business Problem")
    st.write("""
    People invest without proper analysis, we are analysing which property is a good investment:
    
    -  Undervalued price (cheaper than similar properties nearby)
    -  High demand drivers (transport, schools, hospitals)
    -  Future appreciation potential (developing locality, newer property)
    -  Rental attractiveness (amenities, furnishing, accessibility)""")
    # st.write("Details")

# ---------------------------
# Sidebar Inputs
# ---------------------------
if page == "Analysis":
    st.set_page_config(
    page_title="Real Estate Investment Advisor",
    layout="wide")
    st.sidebar.title("Property Details")

    ## Selectbox

    State = st.sidebar.selectbox("State",["All"] +sorted(df["State"].unique()))
    city = st.sidebar.selectbox("City", ["All"] + (df[df["State"] == State]["City"].unique().tolist()))
    Locality = st.sidebar.selectbox("Locality", ['All']+ sorted(df["Locality"].unique()))
    property_type = st.sidebar.selectbox("Property Type",['All']+ sorted(df["Property_Type"].unique()))

    ## Slider

    min_bhk, max_bhk = st.sidebar.slider(
        "BHK",
        int(df["BHK"].min()),
        int(df["BHK"].max()),
        (int(df["BHK"].min()), int(df["BHK"].max()))
    )

    min_year, max_year = st.sidebar.slider(
        "Year Built",
        int(df["Year_Built"].min()),
        int(df["Year_Built"].max()),
        (int(df["Year_Built"].min()), int(df["Year_Built"].max()))
    )

    min_schools, max_schools = st.sidebar.slider(
        "Nearby Schools (count)",
        int(df["Nearby_Schools"].min()),
        int(df["Nearby_Schools"].max()),
        (int(df["Nearby_Schools"].min()), int(df["Nearby_Schools"].max()))
    )

    min_hospitals, max_hospitals = st.sidebar.slider(
        "Nearby Hospitals (count)",
        int(df["Nearby_Hospitals"].min()),
        int(df["Nearby_Hospitals"].max()),
        (int(df["Nearby_Hospitals"].min()), int(df["Nearby_Hospitals"].max()))
    )


    ## Selectbox

    Furnished_status = st.sidebar.selectbox("Furnished Status",["All"] +sorted(df["Furnished_Status"].unique()))
    Floor_no = st.sidebar.selectbox("Floor_No",["All"] +sorted(df["Floor_No"].unique()))
    Total_floors = st.sidebar.selectbox("Total_Floors ",["All"] +sorted(df["Total_Floors"].unique()))


    ## slider


    min_price_per_sqft, max_price_per_sqft = st.sidebar.slider(
        "Price_per_SqFt",
        int(df["Price_per_SqFt"].min()),
        int(df["Price_per_SqFt"].max()),
        (int(df["Price_per_SqFt"].min()), int(df["Price_per_SqFt"].max()))
    )

    min_age, max_age = st.sidebar.slider(
        "Age of Property (Years)",
        int(df["Age_of_Property"].min()),
        int(df["Age_of_Property"].max()),
        (int(df["Age_of_Property"].min()), int(df["Age_of_Property"].max()))
    )


    min_size, max_size = st.sidebar.slider(
        "Size (SqFt)",
        int(df["Size_in_SqFt"].min()),
        int(df["Size_in_SqFt"].max()),
        (int(df["Size_in_SqFt"].min()), int(df["Size_in_SqFt"].max()))
    )

    min_price, max_price = st.sidebar.slider(
        "Price (Lakhs)",
        int(df["Price_in_Rs"].min()),
        int(df["Price_in_Rs"].max()),
        (int(df["Price_in_Rs"].min()), int(df["Price_in_Rs"].max()))
    )



    ## Selectbox

    transport = st.sidebar.selectbox("Public Transport Accessibility",['All'] + sorted(df["Public_Transport_Accessibility"].unique()))
    Parking_space = st.sidebar.selectbox("Parking_Space", ['All'] + sorted(df["Parking_Space"].unique()))
    Security = st.sidebar.selectbox("Security",['All'] + sorted(df["Security"].unique()))
    # Amenities = st.sidebar.selectbox("Amenities",['All'] + sorted(df["Amenities"].unique()))
    Facing = st.sidebar.selectbox("Facing",['All'] + sorted(df["Facing"].unique()))
    Owner_Type = st.sidebar.selectbox("Owner_Type",['All'] + sorted(df["Owner_Type"].unique()))
    Availability_Status = st.sidebar.selectbox("Availability_Status",['All'] + sorted(df["Availability_Status"].unique()))

    options = ["Clubhouse", "Garden", "Gym", "Playground", "Pool"]

    selected = st.sidebar.multiselect(
        "Select amenities:",
        options
    )

    # -------------------------------
    # Prepare Input Data
    # -------------------------------

    st.title("🏠 Real Estate Data Analysis",text_alignment="center")

    st.subheader("📊 Input Details")

    input_data = pd.DataFrame({
        "State": [State],
        "City": [city],
        "Locality": [Locality],
        "Type": [property_type],
        "BHK": [f"{min_bhk}-{max_bhk}"],
        "Size (SqFt)": [f"{min_size}-{max_size}"],
        "Price (Rs)": [f"{min_price}-{max_price}"],
        "Price_per_SqFt": [f"{min_price_per_sqft}-{max_price_per_sqft}"],
        "Year_Built": [f"{min_year}-{ max_year}"],
        "Furnished": [Furnished_status],
        "Floor_No": [Floor_no],
        "Total_Floors": [Total_floors],
        "Age": [f"{min_age}-{ max_age}"],
        "Schools": [f"{min_schools}-{ max_schools}"],
        "Hospitals": [f"{min_hospitals}-{ max_hospitals}"],
        "Public_Transport": [transport],
        "Parking_Space": [Parking_space],
        "Security": [Security],
        # "Amenities": [", ".join(Amenities)],
        "Facing": [Facing],
        "Owner_Type": [Owner_Type],
        "Availability_Status": [Availability_Status]
    })

    st.dataframe(input_data)

    # -------------------------------
    # Apply filters safely
    # -------------------------------
    filtered_df = df.copy()

    if selected:
        filtered_df = df[filtered_df[selected].eq(1).all(axis=1)]
    else:
        filtered_df = filtered_df

    if State != "All":
        filtered_df = filtered_df[filtered_df["State"] == State]

    if city != "All":
        filtered_df = filtered_df[filtered_df["City"] == city]

    if Locality != "All":
        filtered_df = filtered_df[filtered_df["Locality"] == Locality]

    if property_type != "All":
        filtered_df = filtered_df[filtered_df["Property_Type"] == property_type]

    if Furnished_status != "All":
        filtered_df = filtered_df[filtered_df["Furnished_Status"] == Furnished_status]

    if Floor_no != "All":
        filtered_df = filtered_df[filtered_df["Floor_No"] == Floor_no]

    if Total_floors != "All":
        filtered_df = filtered_df[filtered_df["Total_Floors"] == Total_floors]

    if transport != "All":
        filtered_df = filtered_df[filtered_df["Public_Transport_Accessibility"] == transport]

    if Parking_space != "All":
        filtered_df = filtered_df[filtered_df["Parking_Space"] == Parking_space]

    if Security != "All":
        filtered_df = filtered_df[filtered_df["Security"] == Security]

    if Facing != "All":
        filtered_df = filtered_df[filtered_df["Facing"] == Facing]

    if Owner_Type != "All":
        filtered_df = filtered_df[filtered_df["Owner_Type"] == Owner_Type]

    if Availability_Status != "All":
        filtered_df = filtered_df[filtered_df["Availability_Status"] == Availability_Status]

                            
    ## Sliders


    filtered_df = filtered_df [(filtered_df ["Nearby_Schools"] >= min_schools) 
                            & (filtered_df ["Nearby_Schools"] <= max_schools)]


    filtered_df = filtered_df [(filtered_df ["Nearby_Hospitals"] >= min_hospitals) 
                            & (filtered_df ["Nearby_Hospitals"] <= max_hospitals)]

    filtered_df = filtered_df [(filtered_df ["Age_of_Property"] >= min_age) 
                            & (filtered_df ["Age_of_Property"] <= max_age)]

    filtered_df = filtered_df [(filtered_df ["BHK"] >= min_bhk) 
                            & (filtered_df ["BHK"] <= max_bhk)]


    filtered_df = filtered_df [(filtered_df ["Year_Built"] >= min_year) 
                            & (filtered_df ["Year_Built"] <= max_year)]


    filtered_df = filtered_df [(filtered_df ["Size_in_SqFt"] >= min_size) 
                            & (filtered_df ["Size_in_SqFt"] <= max_size)]

    filtered_df = filtered_df [(filtered_df ["Price_in_Rs"] >= min_price) 
                            & (filtered_df ["Price_in_Rs"] <= max_price)]

    filtered_df = filtered_df [(filtered_df ["Price_per_SqFt"] >= min_price_per_sqft) 
                            & (filtered_df ["Price_per_SqFt"] <= max_price_per_sqft)]


    st.subheader("🏠 Filtered Properties")

    st.write(f"Total results: {len(filtered_df)}")

    cols = [
    "State","City","Locality","Property_Type","BHK","Size_in_SqFt",
    "Price_in_Rs","Price_per_SqFt","Year_Built","Age_of_Property",
    "Nearby_Schools","Nearby_Hospitals","Public_Transport_Accessibility",
    "Parking_Space","Security","Amenities","Facing","Owner_Type",
    "Availability_Status","amenities_count","local_avg_price", 'undervalued', 'location_score',
    "age_score", "livability_score", "investment_score",
    "appreciation_rate"
]

    filtered_df = filtered_df[cols]
    st.session_state["filtered_df"] = filtered_df

    st.dataframe(filtered_df[["State","City","Locality","Property_Type","BHK","Size_in_SqFt","Price_in_Rs","Price_per_SqFt","Year_Built","Age_of_Property","Nearby_Schools",
                    "Nearby_Hospitals","Public_Transport_Accessibility","Parking_Space","Security","Amenities","Facing","Owner_Type",
                    "Availability_Status","amenities_count"]], use_container_width=True)

# -------------------------------
# Output
# -------------------------------

if page == "Output":
    st.subheader("Good_props")

    if "filtered_df" in st.session_state:
        df1 = st.session_state["filtered_df"]

        good_props = df1[df1['investment_score'] > df1['investment_score'].quantile(0.75)]

        top5 = good_props.sort_values(by="investment_score", ascending=False).head(5)
        st.write(len(good_props))
        st.dataframe(top5[["City","Locality","Property_Type","BHK","Size_in_SqFt","Price_per_SqFt","Price_in_Rs","Nearby_Schools",
                    "Nearby_Hospitals","Public_Transport_Accessibility","Parking_Space","Security","Amenities","Facing",
                    "Availability_Status","investment_score","undervalued"]])
        st.subheader("High_growth")
        threshold = 0.10
        high_growth = good_props[good_props['appreciation_rate'] > threshold]

        top5h = high_growth.sort_values(by="appreciation_rate", ascending=False).head(5)
        st.write(len(high_growth))
        st.dataframe(top5h[["City","Locality","Property_Type","Year_Built","Price_per_SqFt","Price_in_Rs","appreciation_rate"]])

    st.write("The above are the list of properties based on your selection criteria")
    

    



