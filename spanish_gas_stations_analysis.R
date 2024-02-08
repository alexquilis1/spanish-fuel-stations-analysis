# This script analyzes fuel station data retrieved from a REST API
# It perfroms data cleaning, analysis, and visualization tasks


# Libraries ---------------------------------------------------------------

library(tidyverse)
library(janitor)
library(leaflet)
library(readr)
library(jsonlite)
library(stringi)
library(readxl)
library(ggplot2)
library(ggiraph)
library(sf)
library(leaflet.extras)
library(shiny)

# Function to load data from the REST API
load_data <- function(url) {
  data <- tryCatch(
    expr = jsonlite::fromJSON(url),
    error = function(e) {
      message("Error loading data: ", conditionMessage(e))
      return(NULL)
    }
  )
  return(data)
}

# Load data from the REST API
data <- load_data("https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/")

if (!is.null(data)) {
  # Extract data from the JSON object
  df <- data$ListaEESSPrecio
}

head(df)
summary(df)



# The first approach is to clean the data, specifically cleaning the column names and converting the data types.
# We also convert the data to a tibble for easier manipulation.

# Function to clean data
clean_data <- function(df) {
  # Clean column names
  cleaned_data <- df %>% 
    janitor::clean_names() %>% 
    # Convert data types
    readr::type_convert(locale = readr::locale(decimal_mark = ",")) %>%
    # Convert to tibble for easier manipulation
    as_tibble()
  
  return(cleaned_data)
}

cleaned_data <- clean_data(df)

# Let's analyze certain columns: margen, remision, tipo venta, % bio etanol, % ester metilico

# Functoin to calculate proportion tables
get_prop_table <- function(data, column) {
  prop_table <- table(data[[column]]) / nrow(data) * 100
  return(prop_table)
}

get_prop_table(cleaned_data, "margen")
get_prop_table(cleaned_data, "remision")
get_prop_table(cleaned_data, "tipo_venta")
get_prop_table(cleaned_data, "percent_bio_etanol")
get_prop_table(cleaned_data, "percent_ester_metilico")

# We cannot infer the meaning of margen and remision. Also, tipo_venta is unclear, so we'll remove these columns.
# For percent of bio_etanol and ester_metilico, we observe that more than 99% of values are 0, so we'll remove these columns as well.
# After research, we discovered that 'IDMunicipio' and 'IDProvincia' represent municipality and province IDs respectively, which are not relevant for analysis.
# These columns are redundant as we already have city and province names. However, we'll retain 'IDCCAA' to add a column with the region name later.

# Let's add a column with the name of the region.
# We'll use IDCCAA to retrieve the region name from an Excel file provided by the INE.
ccaa <- read_excel("codccaa_OFFCIAL.xls", skip=1)

cleaned_data <- cleaned_data %>% 
  left_join(ccaa, by = c("idccaa" = "CODIGO")) %>% 
  rename("comunidad_autonoma" = LITERAL) %>% 
  mutate(
    'comunidad_autonoma' = case_when(
      idccaa == "07" ~ "Castilla-La Mancha",
      idccaa == "08" ~ "Castilla y León",
      TRUE ~ comunidad_autonoma
    )
  )



# Analyzing the prices of different fuel types

# Select the specified columns for analysis
selected_columns <- c("precio_biodiesel", "precio_bioetanol", "precio_gas_natural_comprimido", 
                      "precio_gas_natural_licuado", "precio_gases_licuados_del_petroleo", 
                      "precio_gasoleo_a", "precio_gasoleo_b", "precio_gasoleo_premium", 
                      "precio_gasolina_95_e10", "precio_gasolina_95_e5", 
                      "precio_gasolina_95_e5_premium", "precio_gasolina_98_e10", 
                      "precio_gasolina_98_e5", "precio_hidrogeno")

# mean of selected_columns from the df
mean_values <- colMeans(cleaned_data[selected_columns], na.rm = TRUE)

# let's check the NaN and null values for the selected columns
nan_values <- colSums(sapply(cleaned_data[selected_columns], is.nan))

# Function to count null values for numeric columns
null_values <- colSums(sapply(cleaned_data[selected_columns], is.na))

null_percentage <- round((null_values/nrow(cleaned_data)), 4)


# Combine results into a single data frame
data_quality <- data.frame(
  column_names = selected_columns,
  mean = mean_values,
  nan_values = nan_values,
  null_values = null_values,
  null_percentage = null_percentage
)

# Print data quality metrics
data_quality %>% View()

# Check if any selected columns have a high proportion of NaN or null values
columns_to_remove <- data_quality$column_names[
  data_quality$null_percentage > 0.75
]

if (length(columns_to_remove) > 0) {
  message("The following columns have a high proportion of NaN or null values and may be candidates for removal:")
  print(columns_to_remove)
} else {
  message("No columns have a high proportion of NaN or null values.")
}

# We remove the columns with a high proportion of NaN or null values
# in order to focus on the columns with more complete data about fuel prices
# also we remove the columns we previously identified as not relevant for the analysis
columns_to_remove <- c(columns_to_remove_1, columns_to_remove_2)
# Seleccionar columnas en el orden especificado
cleaned_data <- cleaned_data %>%
  select(-all_of(columns_to_remove))
cleaned_data <- cleaned_data %>%
  select(ideess, c_p, direccion, latitud, longitud_wgs84, localidad, municipio, provincia, comunidad_autonoma, 
         rotulo, precio_gasoleo_a, precio_gasoleo_premium, precio_gasolina_95_e5, precio_gasolina_98_e5)
cleaned_data %>% View()

# bar graph of the average price of gasoil a and gasolina 95 e5 by comunidad_autonoma
# Calculate the average price of gasoil a and gasolina 95 e5 by comunidad_autonoma
average_prices <- cleaned_data %>%
  group_by(comunidad_autonoma) %>%
  summarise(
    avg_precio_gasoleo_a = round(mean(precio_gasoleo_a, na.rm = TRUE),4),
    avg_precio_gasolina_95_e5 = round(mean(precio_gasolina_95_e5, na.rm = TRUE),4) 
  )

# Create a bar graph of the average price of gasoil a and gasolina 95 e5 by comunidad_autonoma
# show the value of each avg price when hovering with the mouse, make it small so it doesn't cover the graph
# go from lowest price to highest
average_prices %>%
  gather(key = "fuel_type", value = "average_price", -comunidad_autonoma) %>%
  ggplot(aes(x = reorder(comunidad_autonoma, average_price), y = average_price, fill = fuel_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Average Fuel Prices by Region",
       x = "Region",
       y = "Average Price (€/L)",
       fill = "Fuel Type") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_text(aes(label = round(average_price, 2)), position = position_dodge(width = 0.9), vjust = -0.25, size = 3) +
  scale_fill_manual(values = c("darkorange", "dodgerblue")) +
  guides(fill = guide_legend(title = "Fuel Type")) +
  coord_flip()

mapa_calor <- leaflet() %>%
  setView(lng = -4.0, lat = 40.0, zoom = 6) %>%  # Centrar el mapa en España
  addProviderTiles("CartoDB.Positron") %>%  # Añadir capa base
  addHeatmap(data = cleaned_data, lng = ~longitud_wgs84, lat = ~latitud, intensity = ~precio_gasoleo_a, blur = 20, radius = 15)
print(mapa_calor)


# cambiar el valor de la latitud y una longitud de un rotulo
cleaned_data$latitud[cleaned_data$ideess == 11988] <- 41.32255489106866
cleaned_data$longitud_wgs84[cleaned_data$ideess == 11988] <- 2.1341602391592818

cleaned_data$latitud[cleaned_data$ideess == 13745] <- 38.03643632969041
cleaned_data$longitud_wgs84[cleaned_data$ideess == 13745] <- -4.038429171140354

cleaned_data$latitud[cleaned_data$ideess == 12883] <- 40.17238230211872
cleaned_data$longitud_wgs84[cleaned_data$ideess == 12883] <- -3.6656475095835437

# Function to filter data by city
filter_by_city <- function(data, city) {
  # Normalize city name and convert to lowercase
  normalized_city <- tolower(stri_trans_nfkd(city))
  # Filter data by the normalized city name
  filtered_data <- data %>% 
    filter(tolower(stri_trans_nfkd(localidad)) == normalized_city)
  
  return(filtered_data)
}



# Prompt user to enter a city name
city_name <- readline(prompt = "Enter the name of a city to view gas stations: ")

# Filter data by the entered city name
city_data <- filter_by_city(cleaned_data, city_name)

if (nrow(city_data) > 0){
  print(city_data)
  
  # Create a Leaflet map
  map <- leaflet(city_data) %>% 
    addTiles() %>% 
    addMarkers(~longitud_wgs84, ~latitud, 
               popup = ~paste("<strong>", rotulo, "</strong><br>", 
                              "Dirección:", direccion, "<br>", 
                              "Precio gasóleo A:", precio_gasoleo_a, "€<br>", 
                              "Precio gasolina E95:", precio_gasolina_95_e5, "€")) %>% 
    addHeatmap(
      lat = ~latitud,
      lng = ~longitud_wgs84,
      intensity = ~precio_gasoleo_a+precio_gasolina_95_e5,
      blur = 20,
      radius = 15,
      max = 0.7
    )
  print(map)
  
} else {
  message("No gas stations found in the entered city.")
}

