library(shiny)
library(ggplot2)
library(dplyr)
library(shinydashboard)
library(readxl)

# Load and parse Excel data
pizza_data <- read_excel("pizza_sell_data.xlsx")

# Parse Order Time from ISO format (with T)
pizza_data$`Order Time` <- as.POSIXct(pizza_data$`Order Time`, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC")

# Extract Year
pizza_data$Order_Year <- format(pizza_data$`Order Time`, "%Y")

# Create month label and date
pizza_data$Order_MonthDate <- as.Date(format(pizza_data$`Order Time`, "%Y-%m-01"))
pizza_data$Order_MonthLabel <- format(pizza_data$Order_MonthDate, "%B %Y")

shinyServer(function(input, output, session) {
  
  # Update dropdown filters
  observe({
    updateSelectInput(session, "locationInput",
                      choices = c("All", unique(pizza_data$Location)),
                      selected = "All")
    
    updateSelectInput(session, "orderYearInput",
                      choices = c("All", sort(unique(pizza_data$Order_Year))),
                      selected = "All")
  })
  
  # Reactive filtering
  filtered_data <- reactive({
    data <- pizza_data
    if (input$locationInput != "All") {
      data <- data %>% filter(Location == input$locationInput)
    }
    if (input$orderYearInput != "All") {
      data <- data %>% filter(Order_Year == input$orderYearInput)
    }
    return(data)
  })
  
  output$totalOrders <- renderValueBox({
    valueBox(nrow(filtered_data()), "Total Orders", icon = icon("receipt"), color = "blue")
  })
  
  output$avgDelay <- renderValueBox({
    avg_delay <- round(mean(filtered_data()$`Delay (min)`, na.rm = TRUE), 2)
    valueBox(paste(avg_delay, "min"), "Avg Delay", icon = icon("clock"), color = "red")
  })
  
  output$avgDistance <- renderValueBox({
    avg_dist <- round(mean(filtered_data()$`Distance (km)`, na.rm = TRUE), 2)
    valueBox(paste(avg_dist, "km"), "Avg Distance", icon = icon("map-marker-alt"), color = "green")
  })
  
  output$ordersByRestaurant <- renderPlot({
    filtered_data() %>%
      count(`Restaurant Name`) %>%
      ggplot(aes(x = reorder(`Restaurant Name`, n), y = n, fill = `Restaurant Name`)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      labs(x = "Restaurant", y = "Orders", title = "Orders by Restaurant") +
      theme_minimal()
  })
  
  output$monthlyTrend <- renderPlot({
    filtered_data() %>%
      count(Order_MonthDate, Order_MonthLabel) %>%
      ggplot(aes(x = reorder(Order_MonthLabel, Order_MonthDate), y = n, group = 1)) +
      geom_line(color = "steelblue") +
      geom_point() +
      labs(x = "Month", y = "Orders", title = "Monthly Orders Trend") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  output$durationByType <- renderPlot({
    filtered_data() %>%
      group_by(`Pizza Type`) %>%
      summarise(avg_duration = mean(`Delivery Duration (min)`, na.rm = TRUE)) %>%
      ggplot(aes(x = reorder(`Pizza Type`, avg_duration), y = avg_duration, fill = `Pizza Type`)) +
      geom_col() +
      coord_flip() +
      labs(x = "Pizza Type", y = "Avg Delivery Duration", title = "Delivery Duration by Pizza Type") +
      theme_minimal()
  })
  
  output$delayPie <- renderPlot({
    filtered_data() %>%
      count(`Is Delayed`) %>%
      ggplot(aes(x = "", y = n, fill = `Is Delayed`)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar(theta = "y") +
      theme_void() +
      labs(title = "Delivery Delay Distribution")
  })
  
  output$toppingDensity <- renderPlot({
    filtered_data() %>%
      group_by(`Pizza Type`) %>%
      summarise(avg_density = mean(`Topping Density`, na.rm = TRUE)) %>%
      ggplot(aes(x = reorder(`Pizza Type`, avg_density), y = avg_density, fill = `Pizza Type`)) +
      geom_col() +
      coord_flip() +
      labs(x = "Pizza Type", y = "Avg Topping Density", title = "Topping Density by Pizza Type") +
      theme_minimal()
  })
  
  output$trafficVsComplexity <- renderPlot({
    ggplot(filtered_data(), aes(x = as.numeric(`Traffic Impact`), y = as.numeric(`Pizza Complexity`))) +
      geom_jitter(alpha = 0.5, color = "darkorange") +
      labs(x = "Traffic Impact", y = "Pizza Complexity", title = "Traffic Impact vs Pizza Complexity") +
      theme_minimal()
  })
})
