library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Pizza Sales Dashboard"),
  dashboardSidebar(
    selectInput("locationInput", "Filter by Location:",
                choices = NULL, selected = "All"),
    selectInput("orderYearInput", "Filter by Year:",
                choices = NULL, selected = "All"),
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("chart-bar")),
      menuItem("Delivery", tabName = "delivery", icon = icon("truck")),
      menuItem("Toppings", tabName = "toppings", icon = icon("pizza-slice"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "overview",
              fluidRow(
                valueBoxOutput("totalOrders"),
                valueBoxOutput("avgDelay"),
                valueBoxOutput("avgDistance")
              ),
              fluidRow(
                box(title = "Orders by Restaurant", width = 6, plotOutput("ordersByRestaurant")),
                box(title = "Monthly Order Trend", width = 6, plotOutput("monthlyTrend"))
              )
      ),
      tabItem(tabName = "delivery",
              fluidRow(
                box(title = "Delivery Duration by Type", width = 6, plotOutput("durationByType")),
                box(title = "Delay Distribution", width = 6, plotOutput("delayPie"))
              )
      ),
      tabItem(tabName = "toppings",
              fluidRow(
                box(title = "Topping Density by Pizza Type", width = 6, plotOutput("toppingDensity")),
                box(title = "Pizza Complexity vs Traffic", width = 6, plotOutput("trafficVsComplexity"))
              )
      )
    )
  )
)


