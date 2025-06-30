# ⛽ Spanish Fuel Stations Data Analysis

> Real-time analysis and visualization of fuel prices across Spain using official government data

![R](https://img.shields.io/badge/R-4.0+-276DC3.svg)
![Data Source](https://img.shields.io/badge/Data-Spanish_Government_API-red.svg)
![License](https://img.shields.io/badge/License-Custom-red.svg)

## 🎯 What it does

This R-powered data analysis project provides comprehensive insights into Spanish fuel prices by:
- 📊 **Real-time data fetching** from the Spanish Ministry's official REST API
- 🗺️ **Interactive maps** showing fuel station locations and price heat maps  
- 📈 **Regional price comparisons** across Spain's autonomous communities
- 🔍 **City-specific searches** to find the best fuel prices near you
- 🧹 **Smart data cleaning** with geographic coordinate validation

## ✨ Key Features

- **🌐 Live Government Data** - Direct connection to official Spanish fuel price API
- **📍 Interactive Mapping** - Leaflet-powered maps with location markers and heat maps
- **📊 Price Analytics** - Compare diesel and gasoline prices across regions
- **🔎 City Search** - Filter stations by any Spanish city
- **📈 Visual Insights** - Beautiful ggplot2 charts showing price distributions
- **🧹 Data Quality Control** - Automated cleaning and geographic validation

## 🛠️ Built With

- **[R](https://www.r-project.org/)** - Statistical computing and data analysis
- **[tidyverse](https://www.tidyverse.org/)** - Data manipulation and visualization ecosystem
- **[leaflet](https://rstudio.github.io/leaflet/)** - Interactive web maps
- **[ggplot2](https://ggplot2.tidyverse.org/)** - Grammar of graphics for data visualization
- **[jsonlite](https://cran.r-project.org/package=jsonlite)** - JSON data parsing
- **[shiny](https://shiny.rstudio.com/)** - Web application framework (ready for deployment!)

## 🚀 Getting Started

### Prerequisites

- R 4.0 or higher
- Internet connection (for live API data)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/spanish-fuel-stations-analysis.git
   cd spanish-fuel-stations-analysis
   ```

2. **Install required packages**
   ```r
   install.packages(c(
     "tidyverse", "janitor", "leaflet", "readr", 
     "jsonlite", "stringi", "readxl", "ggplot2", 
     "ggiraph", "sf", "leaflet.extras", "shiny"
   ))
   ```

3. **Run the analysis**
   ```r
   source("gas_stations_analysis.R")
   ```

## 📊 What You'll Get

### Regional Price Analysis
Beautiful visualizations comparing fuel prices across Spain's autonomous communities

### Interactive Heat Maps
Real-time price heat maps showing where to find the cheapest fuel

### City-Specific Search
Enter any Spanish city name to see local gas stations with:
- Exact locations on interactive maps
- Current prices for different fuel types
- Station brands and addresses

## 🗂️ Project Structure

```
spanish-fuel-stations-analysis/
├── gas_stations_analysis.R    # Main analysis script
├── codccaa_OFFCIAL.xls       # Spanish regions reference data
├── README.md                 # This file
└── LICENSE                   # MIT license
```

## 📈 Sample Insights

The analysis reveals fascinating patterns in Spanish fuel markets:
- Regional price variations across autonomous communities
- Geographic clustering of price trends
- Brand-specific pricing strategies
- Urban vs. rural pricing differences

## 🔮 Future Vision: Web Application

This project is perfectly positioned to become a public web application! Potential features:
- 🌐 **Real-time price tracking** with automatic updates
- 📱 **Mobile-responsive design** for on-the-go price checking
- 🗺️ **Route optimization** to find cheapest stations along your journey
- 📊 **Price alerts** when fuel drops below your target price
- 📈 **Historical price trends** and predictions
- 🚗 **Fuel calculator** for trip cost estimation

*Interested in collaborating on the web version? Let's connect!*

## 🎓 What I Learned

This project helped me master:
- RESTful API integration and data pipeline development
- Advanced geospatial data analysis and visualization
- Real-time data processing and quality validation
- Interactive mapping with R and Leaflet
- Statistical analysis of economic data patterns

## 🤝 Contributing

Contributions are welcome! Here are some ideas:
- [ ] Add price prediction models
- [ ] Implement historical data tracking
- [ ] Create automated price alerts
- [ ] Add more fuel types analysis
- [ ] Build the Shiny web application
- [ ] Add English translations

## 📄 License
This project is licensed under a Custom License - see the [LICENSE](LICENSE) file for details.

**Note:** Commercial use requires notification and may require permission. Contact for commercial licensing inquiries.

## 🙏 Acknowledgments

- **Spanish Ministry of Industry, Commerce and Tourism** for providing the open API
- **National Institute of Statistics (INE)** for regional code mappings
- **R Community** for the amazing ecosystem of data analysis tools

---

⭐ **Found this useful?** Give it a star and help others discover affordable fuel prices in Spain!
